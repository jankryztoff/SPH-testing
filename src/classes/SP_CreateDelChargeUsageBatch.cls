/*
 * Class Name: SP_CreateDelChargeUsageBatch
 * @author: Jayson Sarion
 * Date: 
 * Requirement/Project Name: CRSM Project
 * @description Batch Apex Class to Create Usage Records Delivery Charge Subscriptions
 * Considerations: Create 1 UNder DC Subscription if there are no Full Prepaid Subs on the same address + account 
 * and the Subscriptions are not under temp stop for the whole month
 *
 * History: MD-18 | Jeff Teves
 * -- Restructured entire code for logic updates based on MD-18 design
 */
    
    
global class SP_CreateDelChargeUsageBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {    // Start/End D-3478 28Sep15 JohnD - added  Database.AllowsCallouts
    
    global final static String SUBTYPE_DEL = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
    global final static String STATUS_ACTIVE = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
    global final static String STATUS_CANCELLED = GlobalVariableClass.STATUS_CANCELLED;
    global final static String FULL_PRE = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
    global final static String MR_PRE = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
    global final static String MR_POST = GlobalVariableClass.RECURRING_POSTPAID;
    global final static String LANDED = 'Landed';
    global final static String APT = 'Apt';
    global final static String HDB = 'HDB';
    
    Date today = date.today();    
    
    //START D-3341 08/11/2015 Added by J.Sarion - Contact Id for 2nd query. list of contact id are those in SCOPE but ( not in 1st query or with Bill Type not as Prepaid )
    Set<Id> firstQueryConIdSet = new Set<Id>();
    //END D-3341 08/11/2015 Added by J.Sarion - Contact Id for 2nd query. list of contact id are those in SCOPE but ( not in 1st query or with Bill Type not as Prepaid )

    /*//Date dt = date.newinstance(Today.year(),today.MONTH() , 1);
    Date firstDayOfMonth = System.today().toStartOfMonth();
    Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
    Date firstDayOfNextMonth = firstDayOfMonth.addMonths(1).toStartOfMonth();
    Date lastDayOfNextMonth = firstDayOfNextMonth.addDays(Date.daysInMonth(firstDayOfNextMonth.year(), firstDayOfNextMonth.month()) - 1);*/
    
    //START 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches  
    private final static Date referenceDate = UsageHelper.getUsageReferenceDate(); 
    //END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches    
    
    // START D-3647 LISEN 10/8/2015 - Enable on demand batch call
    //START D-3647 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
    //START D-4080 Gdelrosario : added instantiation for code review
    private Set<String> referenceIdsAsString = new Set<String>();
    //END D-4080 Gdelrosario : added instantiation for code review
    private Set<Id> referenceIdsAsId;
    private Integer type;
    Set<Id> contactIdSet = new Set<Id>();
    Boolean isApexJobSuccessful = true;
    
    //START PD-0354 31May16 FrancisBenzon : variables
    Set<Id> acctIdSet = new Set<Id>();
    Set<String> acctRecTypeSet = new Set<String>{GlobalVariableClass.ACCRECTYPEDI, GlobalVariableClass.ACCRECTYPEDC, GlobalVariableClass.ACCRECTYPEDSID};
    //END PD-0354 31May16 FrancisBenzon : variables
    
    // Default Constructor
    global SP_CreateDelChargeUsageBatch(){
    }
    
    // Constructor for adhoc batch run using specific accountNumbers
    global SP_CreateDelChargeUsageBatch(Set<String> referenceIds, Integer type){
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        this.referenceIdsAsString = referenceIds;   
        if(type == 1){
            referenceIdsAsId = new Set<Id>();
            for(String refId :referenceIds){
                referenceIdsAsId.add(Id.valueOf(refId));
            } 
            //START PD-0354 31May16 FrancisBenzon : get sub accts instead of contacts
            for(Zuora__Subscription__c sub :[SELECT Id, Recipient_Contact__c, Zuora__Account__c FROM Zuora__Subscription__c WHERE Id IN :referenceIdsAsId]){
                acctIdSet.add(sub.Zuora__Account__c);
            }
        }
        else if(type == 2){
            for(Zuora__Subscription__c sub :[SELECT Id, Recipient_Contact__c, Zuora__Account__c FROM Zuora__Subscription__c WHERE Zuora__CustomerAccount__r.Zuora__AccountNumber__c IN :referenceIdsAsString]){
                acctIdSet.add(sub.Zuora__Account__c);
            }
            //END PD-0354 31May16 FrancisBenzon : get sub accts instead of contacts
        }
        this.type = type;
    }
    //END D-3647 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
    // END  D-3647 LISEN 10/8/2015 - Enable on demand batch call
    
    /* @description Called at the beginning of the apex job to collect the objects    
     * to be passed to the execute method    
     * @param bc - predefined parameter     
     * @return list of objects from Account Object    
     */
    global Database.QueryLocator start(Database.BatchableContext BC){
        //START PD-0354 31May16 FrancisBenzon : query from account to avoid duplicate del usages
        String  query = 'SELECT ID FROM Account Where RecordType.Name IN :acctRecTypeSet';
        // START D-3647 LISEN 10/8/2015 - Enable on demand batch call
        //START D-3647 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
        if(!acctIdSet.isEmpty()){
            query += ' AND Id IN :acctIdSet';
        }
        //END PD-0354 31May16 FrancisBenzon : query from account to avoid duplicate del usages
        //END D-3647 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
        // END D-3647 LISEN 10/8/2015 - Enable on demand batch call
        return Database.getQueryLocator(query);
    }

    /* @description Executes the business logic and creates USAGE object  
     * @param bc - predefined parameter    
     * @param scope - a list of sObjects from the initial database query
     * @return void     
     */
    global void execute(Database.BatchableContext BC, List<Account> scope1){
        // START D-3647 LISEN 10/8/2015 - Enable on demand batch call for recovery
        Logger logger = new Logger(SP_CreateDelChargeUsageBatch.class.getName(), 'SP004', BC.getJobID()); //START-END D-3647 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
        Savepoint sp = Database.setSavepoint();
        
        //START PD-0354 31May16 FrancisBenzon : variables
        Set<Id> setAcctIds = new Set<Id>();
        List<Contact> scope = new List<Contact>();
        //END PD-0354 31May16 FrancisBenzon : variables
        
        try{
            //map of <account Id> + <Delivery address> and matching delivery Charge Subscription
            //create 1 usage for every subscription added to this map
            Map<String, Zuora__Subscription__c> accountIdAddress_zSub_Map = new Map<String, Zuora__Subscription__c>();
            Map<String, Zuora__Subscription__c> accountIdAddress_zSub_nextMonth_Map = new Map<String, Zuora__Subscription__c>();
            Set<String> addressWithFullSub = new Set<String>();
            List<Zuora__Subscription__c> subLIST = new List<Zuora__Subscription__c>();
            List<Zuora__Subscription__c> subLIST_2 = new List<Zuora__Subscription__c>();
            List<Zuora__Subscription__c> subLIST_nextMonth = new List<Zuora__Subscription__c>();
            Map<Id, Zuora__SubscriptionProductCharge__c> subIdToSpcMap = new Map<Id, Zuora__SubscriptionProductCharge__c>();
            Set<Id> subIds = new Set<Id>();
            Set<Id> conIdSET = new Set<Id>();
            List<Usage__c> usageLIST = new List<Usage__c>();

            //START 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches  
            //Reference_Date__c refd = Reference_Date__c.getInstance('Singapore Press Holdings Ltd');
            Date firstDayOfMonth;
            Date lastDayOfMonth;
            Date firstDayOfNextMonth;
            Date lastDayOfNextMonth; 
            
            //START UD-1522 06/21/2015 Added by J.Sarion - Set of subscription Id start date first day of month
            Set<String> subZuoraIdSet = new Set<String>();
            Set<String> subIdFirtsofMonthSet = new Set<String>();
            List<Invoice_Line_Item__c> invoiceLineItemList = new List<Invoice_Line_Item__c>();
            Map<String, String> subZuoraIdToNameMap = new Map<String, String>();
            //END UD-1522 06/21/2015 Added by J.Sarion - Set of subscription Id start date first day of month           
            
            if(referenceDate != null) {
                firstDayOfMonth = referenceDate.toStartOfMonth();
                lastDayOfMonth = referenceDate.addMonths(1).toStartOfMonth().addDays(-1);
                firstDayOfNextMonth = referenceDate.addMonths(1).toStartOfMonth();
                lastDayOfNextMonth = referenceDate.addMonths(2).toStartOfMonth().addDays(-1);
            } else {
                firstDayOfMonth = System.today().toStartOfMonth();
                lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
                firstDayOfNextMonth = firstDayOfMonth.addMonths(1).toStartOfMonth();
                lastDayOfNextMonth = firstDayOfNextMonth.addDays(Date.daysInMonth(firstDayOfNextMonth.year(), firstDayOfNextMonth.month()) - 1); 
            }
            //END 03/30/2015 D-2606 Kevin Evasco added condition for Custom Setting for Reference Date for all month-end batches    
            
            //START PD-0354 31May16 FrancisBenzon : uery from account to avoid duplicate del usages
            for (Account acc : scope1) {
                setAcctIds.add(acc.Id);
            }
            
            scope = [Select Id From Contact Where AccountId IN :setAcctIds AND Recipient_Indicator__c = true];
            
            if(scope.size() > 0)
            {
                 for (Contact con : scope) {
                    conIdSET.add(con.Id);
                }
            }           
            //END PD-0354 31May16 FrancisBenzon : uery from account to avoid duplicate del usages
            
            if (!conIdSET.isEmpty()) {
                //fetch DC Subs for CURRENT MONTH
                //START D-2732 13-Apr-2015 Added by Raviteja - Added Recipient_Contact__c field in the SOQL // End
                subLIST = [SELECT Id, Name, Zuora__Account__c, Recipient_Address_ID__c, Subscription_Type_1__c, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, 
                            Billing_Type__c, Zuora__SubscriptionStartDate__c, New_Contract_Period_1__c, Contract_End_Date_1__c,Recipient_Contact__c
                            FROM Zuora__Subscription__c
                            WHERE
                                Recipient_Contact__c IN :conIdSET AND
                                Subscription_Type_1__c = :SUBTYPE_DEL AND 
                                (
                                    (   //1
                                        Zuora__Status__c = :STATUS_ACTIVE AND
                                        Billing_Type__c = :FULL_PRE AND
                                        Zuora__SubscriptionStartDate__c <= :firstDayOfMonth AND 
                                       //START D-2732 13-Apr-2015 Added by Raviteja  - commented and Update new logic for 'EVERGREEN Subscription'
                                        // Zuora__SubscriptionEndDate__c >= :firstDayOfMonth
                                        (Zuora__SubscriptionEndDate__c >= :firstDayOfMonth OR Zuora__SubscriptionEndDate__c = null)
                                       //End D-2732 13-Apr-2015 Added by Raviteja      
                                    )
                                    OR
                                    (
                                        //2
                                        Zuora__Status__c = :STATUS_ACTIVE AND
                                        Billing_Type__c = :MR_PRE AND
                                        Zuora__SubscriptionStartDate__c <= :firstDayOfMonth AND 
                                        //START D-2732 13-Apr-2015 Added by Raviteja  - commented and Update new logic for 'EVERGREEN Subscription'
                                        //Zuora__SubscriptionEndDate__c >= :firstDayOfMonth AND
                                        (Zuora__SubscriptionEndDate__c >= :firstDayOfMonth OR Zuora__SubscriptionEndDate__c = null) AND
                                        //End D-2732 13-Apr-2015 Added by Raviteja 
                                        Order_Number_1__r.CreatedDate < :firstDayOfMonth
                                    )
                                    OR
                                    (   //3
                                        Zuora__Status__c = :STATUS_ACTIVE AND
                                        Billing_Type__c = :MR_POST AND
                                        Zuora__SubscriptionStartDate__c <= :firstDayOfMonth AND // START/END UD-1767 1/7/2015 GDelRosario/WenJun : change the zuora subscription date as per wen jun
                                        //START D-2732 13-Apr-2015 Added by Raviteja  - commented and Update new logic for 'EVERGREEN Subscription'
                                        // Zuora__SubscriptionEndDate__c >= :firstDayOfMonth AND
                                        (Zuora__SubscriptionEndDate__c >= :firstDayOfMonth OR Zuora__SubscriptionEndDate__c = null)AND
                                        //End D-2732 13-Apr-2015 Added by Raviteja 
                                        Order_Number_1__r.CreatedDate < :firstDayOfMonth
                                    )
                                    OR
                                    (   //4
                                        Zuora__Status__c = :STATUS_CANCELLED AND 
                                       //START D-2732 13-Apr-2015 Added by Raviteja  - commented and Update new logic for 'EVERGREEN Subscription'
                                      //Zuora__SubscriptionEndDate__c > :firstDayOfMonth AND 
                                       Zuora__SubscriptionEndDate__c >= :firstDayOfMonth  AND // START/END UD-1767 1/7/2015 GDelRosario/WenJun : change the zuora subscription date as per wen jun
                                       //End D-2732 13-Apr-2015 Added by Raviteja 
                                        Order_Number_1__r.CreatedDate < :firstDayOfMonth
                                    )
                                )
                            ORDER BY Zuora__Account__c, Billing_Type__c, Recipient_Address_ID__c, Billing_Type__c, New_Contract_Period_1__c];

                //fetch DC Subs for NEXT MONTH
                //START D-2732 13-Apr-2015 Added by Raviteja - Added Recipient_Contact__c field in the SOQL // End
                //START UD-1522 06/21/2015 Added by J.Sarion - Added Zuora ID
                //START D-3225 07/09/2015 Added by J.Sarion - Added Zuora__SubscriptionEndDate__c
                subLIST_nextMonth = [SELECT Id, Name, Zuora__Account__c, Recipient_Address_ID__c, Subscription_Type_1__c, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, 
                            Billing_Type__c, Zuora__SubscriptionStartDate__c, New_Contract_Period_1__c, Contract_End_Date_1__c,Recipient_Contact__c, Zuora__Zuora_Id__c, Zuora__SubscriptionEndDate__c
                //END D-3225 07/09/2015 Added by J.Sarion - Added Zuora__SubscriptionEndDate__c
                            FROM Zuora__Subscription__c
                            WHERE
                                Recipient_Contact__c IN :conIdSET AND
                                Subscription_Type_1__c = :SUBTYPE_DEL AND 
                                (
                                    (   //1,2
                                        Zuora__Status__c = :STATUS_ACTIVE AND 
                                        Billing_Type__c IN (:FULL_PRE, :MR_PRE) AND
                                        Zuora__SubscriptionStartDate__c <= :firstDayOfNextMonth AND 
                                       //START D-2732 13-Apr-2015 Added by Raviteja  - commented and Update new logic for 'EVERGREEN Subscription'
                                      //Zuora__SubscriptionEndDate__c >= :firstDayOfNextMonth
                                      ( Zuora__SubscriptionEndDate__c >= :firstDayOfNextMonth OR Zuora__SubscriptionEndDate__c = null)
                                      //End D-2732 13-Apr-2015 Added by Raviteja 
                                    )
                                    OR 
                                    (   //3
                                        Zuora__Status__c = :STATUS_ACTIVE AND
                                        Billing_Type__c = :MR_POST AND
                                        //START D-3225 07/09/2015 Added by J.Sarion - Create usage for the current month
                                        //START UD-1680 06/21/2015 Added by J.Sarion - No usage will be created on the month of start date for Postpaid started mid month
                                        Zuora__SubscriptionStartDate__c <= :lastDayOfMonth AND //UD-1680
                                        //Zuora__SubscriptionStartDate__c <= :firstDayOfMonth AND
                                        //END UD-1680 06/21/2015 Added by J.Sarion - No usage will be created on the month of start date for Postpaid started mid month
                                        //END D-3225 07/09/2015 Added by J.Sarion - Create usage for the current month
                                       ( Zuora__SubscriptionEndDate__c >= :firstDayOfMonth OR Zuora__SubscriptionEndDate__c = null)
                                      //End D-2732 13-Apr-2015 Added by Raviteja 
                                    )
                                    OR 
                                    (   //4,5,6
                                        Zuora__Status__c = :STATUS_CANCELLED AND
                                        //START D-2732 13-Apr-2015 Added by Raviteja  - commented and Update new logic for 'EVERGREEN Subscription'
                                        //Zuora__SubscriptionEndDate__c > :firstDayOfNextMonth
                                        //START D-4061 12/10/2015 Added by Manolo Valena
                                        Zuora__SubscriptionEndDate__c >= :firstDayOfNextMonth AND// START/END UD-1767 1/7/2015 GDelRosario/WenJun : change the zuora subscription date as per wen jun
                                        Zuora__SubscriptionStartDate__c <= :firstDayOfNextMonth
                                        //End D-2732 13-Apr-2015 Added by Raviteja
                                        //END D-4061 12/10/2015 Added by Manolo Valena 
                                    )
                                )
                            ORDER BY Zuora__Account__c, Billing_Type__c, Recipient_Address_ID__c, Billing_Type__c, New_Contract_Period_1__c];
                //END UD-1522 06/21/2015 Added by J.Sarion - Added Zuora ID
            }
            
            //map hierarchy for Subscriptions THIS MONTH - initial
            for (Zuora__Subscription__c dcSub : subLIST) {
                String uniqueKey = dcSub.Zuora__Account__c + dcSub.Recipient_Address_ID__c;
                //map the Address + account unique identifier to the highest sub in hierarchy
                if(!accountIdAddress_zSub_Map.containsKey(uniqueKey)) {
                    accountIdAddress_zSub_Map.put(uniqueKey, dcSub);
                }
                else if(DeliveryChargeHelper.isHigherInHierarchy(dcSub, accountIdAddress_zSub_Map.get(uniqueKey))) {
                    accountIdAddress_zSub_Map.put(uniqueKey, dcSub);
                }
                
            }
            
            //retrieve Id's of recipient contacts without Full Prepaid/MR PRE created on 1st of month
            conIdSet = new Set<Id>();
            for(Zuora__Subscription__c zSub : accountIdAddress_zSub_Map.values()) {
                //START D-3341 08/11/2015 Added by J.Sarion - Contact Id for 2nd query. list of contact id are those in SCOPE but ( not in 1st query or with Bill Type not as Prepaid )
                if(zSub.Billing_Type__c == FULL_PRE || zSub.Billing_Type__c == MR_PRE){
                    firstQueryConIdSet.add(zSub.Recipient_Contact__c);
                }
                //END D-3341 08/11/2015 Added by J.Sarion - Contact Id for 2nd query. list of contact id are those in SCOPE but ( not in 1st query or with Bill Type not as Prepaid )
            }
            
            //START D-3341 08/11/2015 Added by J.Sarion - Contact Id for 2nd query. list of contact id are those in SCOPE but ( not in 1st query or with Bill Type not as Prepaid )
            for(Contact contactRec: scope){
                if(!firstQueryConIdSet.contains(contactRec.Id))
                    conIdSet.add(contactRec.Id);
            }
            //END D-3341 08/11/2015 Added by J.Sarion - Contact Id for 2nd query. list of contact id are those in SCOPE but ( not in 1st query or with Bill Type not as Prepaid )
            
            //retrieve set of MR-Pre and MR POST DC Sub under recipient contacts without Full Prepaid/MR PRE created on 1st of month
            //START D-2732 13-Apr-2015 Added by Raviteja - Added Recipient_Contact__c field in the SOQL // End
            //START UD-1522 06/21/2015 Added by J.Sarion - Added Zuora ID
            //START D-3225 07/09/2015 Added by J.Sarion - Added Zuora__SubscriptionEndDate__c
            subLIST_2 = [SELECT Id, Name, Zuora__Account__c, Recipient_Address_ID__c, Subscription_Type_1__c, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, 
                            Billing_Type__c, Zuora__SubscriptionStartDate__c, New_Contract_Period_1__c, Contract_End_Date_1__c,Recipient_Contact__c, Zuora__Zuora_Id__c, Zuora__SubscriptionEndDate__c
            //END D-3225 07/09/2015 Added by J.Sarion - Added Zuora__SubscriptionEndDate__c
                            FROM Zuora__Subscription__c
                            WHERE
                                Recipient_Contact__c IN :conIdSET AND
                                Subscription_Type_1__c = :SUBTYPE_DEL AND 
                                (
                                    (   //1
                                        Zuora__Status__c = :STATUS_ACTIVE AND
                                        Billing_Type__c = :MR_PRE AND
                                        Zuora__SubscriptionStartDate__c <= :firstDayOfMonth AND 
                                        Order_Number_1__r.CreatedDate >= :firstDayOfMonth
                                    )
                                    OR
                                    (
                                        //2
                                        Billing_Type__c = :MR_POST AND
                                        //START UD-1680 06/21/2015 Added by J.Sarion - No usage will be created on the month of start date for Postpaid started mid month 
                                        //Zuora__SubscriptionStartDate__c <= :lastDayOfMonth AND //UD-1680
                                        Zuora__SubscriptionStartDate__c <= :firstDayOfMonth AND 
                                        //END UD-1680 06/21/2015 Added by J.Sarion - No usage will be created on the month of start date for Postpaid started mid month
                                        //START D-2732 13-Apr-2015 Added by Raviteja  - commented and Update new logic for 'EVERGREEN Subscription'
                                      //Zuora__SubscriptionEndDate__c >= :lastDayOfMonth
                    ( Zuora__SubscriptionEndDate__c >= :firstDayOfMonth OR Zuora__SubscriptionEndDate__c = null) // START/END UD-1767 1/7/2015 GDelRosario/WenJun : change the zuora subscription date as per wen jun
                                      //End D-2732 13-Apr-2015 Added by Raviteja 
                                    )
                                )
                            ORDER BY Zuora__Account__c, Billing_Type__c, Recipient_Address_ID__c, Billing_Type__c, New_Contract_Period_1__c];
            //END UD-1522 06/21/2015 Added by J.Sarion - Added Zuora IDQ
            
            //map hierarchy for Subscriptions THIS MONTH - FINAL
            accountIdAddress_zSub_Map = new Map<String, Zuora__Subscription__c>();
            for (Zuora__Subscription__c dcSub : subLIST_2) {
                String uniqueKey = dcSub.Zuora__Account__c + dcSub.Recipient_Address_ID__c;
                //map the Address + account unique identifier to the highest sub in hierarchy
                if(!accountIdAddress_zSub_Map.containsKey(uniqueKey)) {
                    accountIdAddress_zSub_Map.put(uniqueKey, dcSub);
                }
                else if(DeliveryChargeHelper.isHigherInHierarchy(dcSub, accountIdAddress_zSub_Map.get(uniqueKey))) {
                    accountIdAddress_zSub_Map.put(uniqueKey, dcSub);
                }
            }
            
            
            //map hierarchy for Subscriptions NEXT MONTH
            for (Zuora__Subscription__c dcSub : subLIST_nextMonth) {
                String uniqueKey = dcSub.Zuora__Account__c + dcSub.Recipient_Address_ID__c;

                //map the Address + account unique identifier to the highest sub in hierarchy
                if(!accountIdAddress_zSub_nextMonth_Map.containsKey(uniqueKey)) {
                    accountIdAddress_zSub_nextMonth_Map.put(uniqueKey, dcSub);
                }
                else if(DeliveryChargeHelper.isHigherInHierarchy(dcSub, accountIdAddress_zSub_nextMonth_Map.get(uniqueKey))) {
                    accountIdAddress_zSub_nextMonth_Map.put(uniqueKey, dcSub);
                }

            }
            
            //START UD-1522 06/21/2015 Added by J.Sarion - Check for Recurring Prepaid Subscriptions started first day of the month
            for(Zuora__Subscription__c zSub : accountIdAddress_zSub_nextMonth_Map.values()) {
                if (zSub.Billing_Type__c == MR_PRE && zSub.Zuora__SubscriptionStartDate__c == firstDayOfMonth) {
                    subZuoraIdSet.add(zSub.Zuora__Zuora_Id__c);
                    subIdFirtsofMonthSet.add(zSub.Name);
                    subZuoraIdToNameMap.put(zSub.Zuora__Zuora_Id__c, zSub.Name);
                }
            }
            
            if (!subZuoraIdSet.isEmpty()) {
                invoiceLineItemList = [SELECT Id, Subscription_ID__c FROM Invoice_Line_Item__c WHERE Subscription_ID__c IN :subZuoraIdSet];
            }
            
            for(Invoice_Line_Item__c inv :invoiceLineItemList) {
                if (subZuoraIdToNameMap.containsKey(inv.Subscription_ID__c)) {
                    subIdFirtsofMonthSet.remove(subZuoraIdToNameMap.get(inv.Subscription_ID__c));
                }
            }
            //END UD-1522 06/21/2015 Added by J.Sarion - Check for Recurring Prepaid Subscriptions started first day of the month
            
            // Start D-3687 03Oct15 JohnD - replaced logic
            /* commented out
            //retrieve related subscription product and charge records
            for(Zuora__Subscription__c sub : subLIST) {
                subIds.add(sub.Id);
            }
            for(Zuora__Subscription__c sub : subLIST_nextMonth) {
                subIds.add(sub.Id);
            }
            */
            for(Zuora__Subscription__c sub : accountIdAddress_zSub_Map.values()) {
                subIds.add(sub.Id);
            }
            
            for(Zuora__Subscription__c sub : accountIdAddress_zSub_nextMonth_Map.values()) {
                subIds.add(sub.Id);
            }
            // End D-3687 03Oct15 JohnD - replaced logic
            
            Set<String> delUoms = new Set<String>{LANDED, APT, HDB};
            for(Zuora__SubscriptionProductCharge__c spc : [SELECT Zuora__UOM__c, Zuora__ChargeNumber__c, Zuora__Subscription__c, PublicationCode__c FROM Zuora__SubscriptionProductCharge__c //START/END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier
                WHERE Zuora__Subscription__c IN :subIds AND Zuora__UOM__c IN :delUoms]) {
                subIdToSpcMap.put(spc.Zuora__Subscription__c, spc);
            }
            
            //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
            Date startDate;
            //START-END D-3225 07/09/2015 Added by J.Sarion - Moved inside for loop
            //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
            
            
            //generate usage for CURRENT MONTH
            for(Zuora__Subscription__c zSub : accountIdAddress_zSub_Map.values()) {
                //START D-3225 07/09/2015 Added by J.Sarion - Update Usage Start Date
                if(referenceDate != null) {
                    startDate = referenceDate.addMonths(1).toStartofMonth().addDays(-1);
                } else {
                    startDate = Date.today().addMonths(1).toStartofMonth().addDays(-1);
                }
                if(zSub.Zuora__SubscriptionEndDate__c != null){
                    if(zSub.Billing_Type__c == MR_PRE && ((zSub.Zuora__SubscriptionEndDate__c.month()-1) == (referenceDate.month()-1) && zSub.Zuora__SubscriptionEndDate__c.year() == referenceDate.year())){
                        startDate = zSub.Zuora__SubscriptionStartDate__c;
                    }
                    if(zSub.Billing_Type__c == MR_POST && zSub.Zuora__SubscriptionEndDate__c.month() == referenceDate.month() && zSub.Zuora__SubscriptionEndDate__c.year() == referenceDate.year()){
                        startDate = zSub.Zuora__SubscriptionEndDate__c;
                    }
                }
                //END D-3225 07/09/2015 Added by J.Sarion - Update Usage Start Date
                if(zSub.Billing_Type__c == MR_PRE || zSub.Billing_Type__c == MR_POST) {
                    if(subIdToSpcMap.containsKey(zSub.Id)) {
                        Zuora__SubscriptionProductCharge__c spc = subIdToSpcMap.get(zSub.Id);
                        usageLIST.add(
                            new Usage__c(
                                Status__c = 'New',
                                //START UD-1522 06/21/2015 Added by J.Sarion - Check for Recurring Prepaid Subscriptions started first day of the month
                                Quantity__c = (subIdFirtsofMonthSet.contains(zSub.Name) ? 2 : 1),
                                //END UD-1522 06/21/2015 Added by J.Sarion - Check for Recurring Prepaid Subscriptions started first day of the month
                                Account_Id__c = zSub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c,
                                Subscription_Id__c = zSub.Name,
                                UOM__c = (spc.Zuora__UOM__c != null ? spc.Zuora__UOM__c : ''),
                                Rate_Plan_Charge_Id__c = (spc.Zuora__ChargeNumber__c != null ? spc.Zuora__ChargeNumber__c : ''), 
                                Publication_Code__c = spc.PublicationCode__c, //START/END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier
                                //START: D-1568 01/12/2015 Added By Jayson Sarion - Add Start Date in creation of Usage record
                                //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
                                Start_Date__c = startDate,
                                Usage_Type__c = UsageHelper.USAGE_TYPE_DELIVERY_CHARGE,
                                Case__c = null // Start/End D-4470 05Apr16 JohnD
                                //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
                                //END: D-1568 01/12/2015 Added By Jayson Sarion
                            )
                        );
                    }
                }
            }
            
            //generate usage for NEXT MONTH
            for(Zuora__Subscription__c zSub : accountIdAddress_zSub_nextMonth_Map.values()) {
                //START D-3225 07/09/2015 Added by J.Sarion - Update Usage Start Date
                if(referenceDate != null) {
                    startDate = referenceDate.addMonths(1).toStartofMonth().addDays(-1);
                } else {
                    startDate = Date.today().addMonths(1).toStartofMonth().addDays(-1);
                }
                if(zSub.Zuora__SubscriptionEndDate__c != null){
                    if(zSub.Billing_Type__c == MR_PRE && ((zSub.Zuora__SubscriptionEndDate__c.month()-1) == (referenceDate.month()-1) && zSub.Zuora__SubscriptionEndDate__c.year() == referenceDate.year())){
                        startDate = zSub.Zuora__SubscriptionStartDate__c;
                    }
                    if(zSub.Billing_Type__c == MR_POST && zSub.Zuora__SubscriptionEndDate__c.month() == referenceDate.month() && zSub.Zuora__SubscriptionEndDate__c.year() == referenceDate.year()){
                        startDate = zSub.Zuora__SubscriptionEndDate__c;
                    }
                }
                //END D-3225 07/09/2015 Added by J.Sarion - Update Usage Start Date

                //START UD-2340 Wenjun 14 Oct: the only scenario is recurring prepaid with start date as 1st day of next month. 
                //We will still set usage start date to end of this month in order to bill customer in this month
                /*
                // Start D-3569 15Sep15 JohnD
                if (zSub.Zuora__SubscriptionStartDate__c > startDate) {
                    startDate = zSub.Zuora__SubscriptionStartDate__c;
                }
                // End  D-3569 15Sep15 JohnD
                */
                //END UD-2340 Wenjun 14 Oct

                //START: D-3250 7/15/2015 K. Tan to create only for Recurrung Prepaid scenario
                if(zSub.Billing_Type__c == MR_PRE) {
                //END: D-3250 7/15/2015 K. Tan to create only for Recurrung Prepaid scenario

                    if(subIdToSpcMap.containsKey(zSub.Id)) {
                        Zuora__SubscriptionProductCharge__c spc = subIdToSpcMap.get(zSub.Id);
                        usageLIST.add(
                            new Usage__c(
                                Status__c = 'New',
                                //START UD-1522 06/21/2015 Added by J.Sarion - Check for Recurring Prepaid Subscriptions started first day of the month
                                Quantity__c = (subIdFirtsofMonthSet.contains(zSub.Name) ? 2 : 1),
                                //END UD-1522 06/21/2015 Added by J.Sarion - Check for Recurring Prepaid Subscriptions started first day of the month
                                Account_Id__c = zSub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c,
                                Subscription_Id__c = zSub.Name,
                                UOM__c = (spc.Zuora__UOM__c != null ? spc.Zuora__UOM__c : ''),
                                Rate_Plan_Charge_Id__c = (spc.Zuora__ChargeNumber__c != null ? spc.Zuora__ChargeNumber__c : ''), Publication_Code__c = spc.PublicationCode__c, //START/END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier
                                //START: D-1568 01/12/2015 Added By Jayson Sarion - Add Start Date in creation of Usage record
                                //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
                                Start_Date__c = startDate,
                                Usage_Type__c = UsageHelper.USAGE_TYPE_DELIVERY_CHARGE,
                                Case__c = null // Start/End D-4470 05Apr16 JohnD
                                //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
                                //END: D-1568 01/12/2015 Added By Jayson Sarion
                            ) 
                        );
                    }
                }
            }
            
            //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
            UsageHelper.insertUniqueUsages(usageList);
            //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
        }catch(Exception e){
            Database.rollback(sp);
            logger.logBatchFailure(e, scope);
            logger.save();
            
            isApexJobSuccessful = false;
        }
        // END D-3647 LISEN 10/8/2015 - Enable on demand batch call for recovery
    }
    
    global void finish(Database.BatchableContext BC){
        // Start D-3478 28Sep15 Johnd - commented out old logic and replace by calling the helper class
        //START D-3647 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
        if(!isApexJobSuccessful){
            BatchJobHelper.updateJobStatus(BC.getJobId(), false);
        }else{
            BatchJobHelper.updateJobStatus(BC.getJobId(), true);
        }
        //END D-3647 10/14/2015 Added by J.Sarion - Run batch for selected billing accounts/Ids
        /* commented out
        String shortID = String.valueOf(BC.getJobId()).subString(0,15);
        List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortID OR SFDC_Job_id__c = :BC.getJobId()];

        if(batchJobSchedulerList.size() > 0)
        {
            BATCH_JOB_SCHEDULER__c batchJobScheduler = batchJobSchedulerList.get(0);
            batchJobScheduler.Status__c = 'SUCCESS';
            batchJobScheduler.End_Time__c = DateTime.now();
            update batchJobScheduler;           
            
            BatchServiceFacade a1F = new BatchServiceFacade();
            BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
            serviceRequestVO.setJobStatus(0);
            serviceRequestVO.setJobID(batchJobScheduler.Batch_Code__c);
            serviceRequestVO.setJobDate(batchJobScheduler.Batch_Run_Date__c);
            a1F.delegateBatchCall(serviceRequestVO);
        }
        */
        // End D-3478 28Sep15 Johnd - commented out old logic and replace by calling the helper class       

    }
}