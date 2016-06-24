/**
* Class Name: SP_MonthlyDeliveryFeeBatch
* @author: Lloyd De Castro
* Date: 
* Requirement/Project Name: CRSM Project
* @description Batch Apex Class to create Vendor Monthly Data and calculate Vendor's Monthly Delivery Fee. 

* History: [D-2105] Wenjun 16-03-15 - Rewrite the class for VDC & Delivery Charge Design Change
* History: [E2E Hotfix] Wenjun 29-07-15 - COA/COV Credit to Old Vendor
* History: [UD-3780] Raviteja 15-Jan-2016 - Updated the logic of Vendors when rerun the job
*/

global class SP_MonthlyDeliveryFeeBatch implements Database.Batchable<sObject>
{   
    global final static String SUB_TYPE_DEL = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;
    global final static String SUB_TYPE_PUB = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
    global final static String FULL_PRE = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
    global final static String MR_PRE = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
    global final static String MR_POST = GlobalVariableClass.RECURRING_POSTPAID;
    global final static String ACTIVE = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
    global final static String CANCELLED = GlobalVariableClass.ZUORA_STATUS_CANCEL;
    global final Date monthStart;
    global final Date monthEnd;     

    //START D-3657 LISEN 20-Oct-2015 - Enable on demand batch based on selective contacts
    Set<String> selectiveIds = null;
    Boolean isApexJobSuccessful = true;
    
    //Default Constructor
    global SP_MonthlyDeliveryFeeBatch()
    {
        this.monthStart = Date.today().toStartOfMonth();
        this.monthEnd = monthStart.addMonths(1).addDays(-1);
    }
    
    //Constructor accepting End Date
    global SP_MonthlyDeliveryFeeBatch(Date dtMthEnd)
    {
        this.monthEnd = dtMthEnd;
        this.monthStart = dtMthEnd.toStartOfMonth();
    }

    global SP_MonthlyDeliveryFeeBatch(Set<String> selectiveIds, Date dtMthEnd){
        this.selectiveIds = selectiveIds;
        this.monthEnd = dtMthEnd;
        this.monthStart = dtMthEnd.toStartOfMonth();
    }
    
    //Start Method : define the scope - Retrieves all the Recipient Contacts
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT ID FROM Contact WHERE Recipient_Indicator__c = true';
        //String query = 'SELECT ID FROM Contact WHERE Recipient_Indicator__c = true AND Id = \'0039000001cems6\' '; // 21Dec2015 Added 0039000001cems6 by Raviteja - for testing purpose
        if(this.selectiveIds != null){
            query += ' AND ID = :selectiveIds';
        }

        return Database.getQueryLocator(query);
    }
    //END D-3657 LISEN 20-Oct-2015 - Enable on demand batch based on selective contacts

    global void execute(Database.BatchableContext BC, List<Contact> lstContacts){
        //START D-3657 LISEN 20-Oct-2015 - Enable on demand batch based on selective contacts
        Logger logger = new Logger(SP_MonthlyDeliveryFeeBatch.class.getName(), 'SP011', BC.getJobID());
        try{
            Map<ID, Zuora__Subscription__c> mapRecipientToDelSub = new Map<ID, Zuora__Subscription__c>();
            List<BT_CO_VSS_CreditDebit__c> lstVSSRecords = new List<BT_CO_VSS_CreditDebit__c>();
            //START D-2731 13-Apr-2015 Added by Raviteja  - Created New Variables
            List<Zuora__Subscription__c> subLIST_2 = new List<Zuora__Subscription__c>();
            Map<ID, Zuora__Subscription__c> mapPreRecipientToDelSub = new Map<ID, Zuora__Subscription__c>();
            Map<ID, Zuora__Subscription__c> mapPosRecipientToDelSub = new Map<ID, Zuora__Subscription__c>();
            //End D-2731 13-Apr-2015 Added by Raviteja
            Set<ID> setPendingContactIDs = new Set<ID>();
            
            //START/End D-3686 - Hotfix Raviteja - 02Oct2015 - Adding Recipient_Contact__r.Address in SOQL
            for(Zuora__Subscription__c delSub :[SELECT ID, Billing_Type__c,Contract_End_Date_1__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Number_of_Copies__c, Order_Line_Item_Number_1__c, Recipient_Contact__r.Address__c,  
                                                            Recipient_Contact__c, New_Contract_Period_1__c, Vendor_Credit_1__c, Vendor_1__r.Vendor_Code__c, Vendor_1__r.Vendor_Group__c,Zuora__Status__c,Order_Number_1__r.CreatedDate 
                                                    FROM Zuora__Subscription__c WHERE Recipient_Contact__c in :lstContacts AND Subscription_Type_1__c = :SUB_TYPE_DEL AND Vendor_1__c != null
                                                        AND((Zuora__Status__c = :ACTIVE AND((Billing_Type__c = :FULL_PRE AND Zuora__SubscriptionStartDate__c <= :monthStart AND (Zuora__SubscriptionEndDate__c = null OR Zuora__SubscriptionEndDate__c >= :monthStart))                                       
                                                        OR(Billing_Type__c = :MR_PRE  AND Zuora__SubscriptionStartDate__c <= :monthStart AND (Zuora__SubscriptionEndDate__c = null OR Zuora__SubscriptionEndDate__c >= :monthStart) AND  Order_Number_1__r.CreatedDate < :monthStart)
                                                        OR(Billing_Type__c = :MR_POST AND Zuora__SubscriptionStartDate__c <= :monthStart   AND (Zuora__SubscriptionEndDate__c = null OR Zuora__SubscriptionEndDate__c >= :monthStart) AND  Order_Number_1__r.CreatedDate < :monthStart)))
                                                        OR(Zuora__Status__c = :CANCELLED AND Zuora__SubscriptionEndDate__c > :monthStart  AND  Order_Number_1__r.CreatedDate < :monthStart))])
            {
                if(mapPreRecipientToDelSub.containsKey(delSub.Recipient_Contact__c))
                {
                    Zuora__Subscription__c prevDelSub = mapPreRecipientToDelSub.get(delSub.Recipient_Contact__c);                
                    if(DeliveryChargeHelper.isHigherInHierarchy(delSub,prevDelSub))                 
                          mapPreRecipientToDelSub.put(delSub.Recipient_Contact__c, delSub);             
                }
                else    
                    mapPreRecipientToDelSub.put(delSub.Recipient_Contact__c, delSub); 
            }                                         
            
            //Process the map : Full Pre and MR Pre - Set to Final Map; MR Post - To Compare with sublist 2
            for(Id contactID : mapPreRecipientToDelSub.keySet())
            {
                Zuora__Subscription__c delSub = mapPreRecipientToDelSub.get(contactID); 
                if(delSub.Billing_Type__c == FULL_PRE || delSub.Billing_Type__c == MR_PRE)
                    mapRecipientToDelSub.put(contactID, delSub);
                else //Postpaid
                    mapPosRecipientToDelSub.put(contactID, delSub);
            }
            
            //Get remaining contact set
            for(Contact contactRec: lstContacts)
            {
                if(!mapRecipientToDelSub.containsKey(contactRec.ID))
                    setPendingContactIDs.add(contactRec.ID);
            }
            //START/End D-3686 - Hotfix Raviteja - 02Oct2015 - Adding Recipient_Contact__r.Address in SOQL             
            subLIST_2 = [SELECT ID, Billing_Type__c,Contract_End_Date_1__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Number_of_Copies__c,Recipient_Contact__r.Address__c,  
                          Recipient_Contact__c, New_Contract_Period_1__c, Vendor_Credit_1__c, Vendor_1__r.Vendor_Code__c, Vendor_1__r.Vendor_Group__c,
                          Zuora__Status__c,Order_Number_1__r.CreatedDate, Order_Line_Item_Number_1__c                                         
                        FROM Zuora__Subscription__c
                        WHERE Recipient_Contact__c IN : setPendingContactIDs AND Subscription_Type_1__c = :SUB_TYPE_DEL AND Vendor_1__c != null 
                        AND (
                                (   //MR Prepaid: Status = Active and Subscription Start Date = 1st day of the month and Order.CreatedDate = 1st day of the month 
                                    Zuora__Status__c = :ACTIVE AND
                                    Billing_Type__c = :MR_PRE AND
                                    Zuora__SubscriptionStartDate__c <= :monthStart AND 
                                    Order_Number_1__r.CreatedDate >= :monthStart
                                )
                                OR
                                (
                                    //OR MR Postpaid: Subscription Start Date <= last day of the Month and Subscription End date >= 1st Day of the month 
                                    Billing_Type__c = :MR_POST AND
                                    Zuora__SubscriptionStartDate__c <= :monthStart AND 
                                    (Zuora__SubscriptionEndDate__c >= :monthStart OR Zuora__SubscriptionEndDate__c = null)
                                )
                            )
                       ]; 
            
            for (Zuora__Subscription__c delSub : subLIST_2) {
                if(mapRecipientToDelSub.containsKey(delSub.Recipient_Contact__c)) 
                    continue;
                else if (mapPosRecipientToDelSub.containsKey(delSub.Recipient_Contact__c))
                {
                    Zuora__Subscription__c prevDelSub = mapPosRecipientToDelSub.get(delSub.Recipient_Contact__c);                
                    if(DeliveryChargeHelper.isHigherInHierarchy(delSub,prevDelSub))                 
                        mapPosRecipientToDelSub.put(delSub.Recipient_Contact__c, delSub);   
                }
                else
                    mapPosRecipientToDelSub.put(delSub.Recipient_Contact__c, delSub); 
            }
                
            //Process the map to build final data set
            for(Id contactID : mapPosRecipientToDelSub.keySet())
            {
                mapRecipientToDelSub.put(contactID, mapPosRecipientToDelSub.get(contactID));
            }
            //End D-2731 13-Apr-2015 Added by Raviteja  
            
            //Compile Order Line Item Set
            Set<ID> setOlis = new Set<ID>();
            for(Zuora__Subscription__c subRec : mapRecipientToDelSub.values())
            {
                setOlis.add(subRec.Order_Line_Item_Number_1__c);
            }
            
            System.debug(' Ravi setOlis : '+setOlis);
            System.debug(' Ravi SUB_TYPE_PUB : '+SUB_TYPE_PUB);
            
            //Get Related Publication Subscriptions
            List<Zuora__Subscription__c> lstPubSubs = [SELECT Id, Name from Zuora__Subscription__c WHERE Order_Line_Item_Number_1__c in :setOlis
                                                        AND Subscription_Type_1__c = :SUB_TYPE_PUB];
            System.debug(' Ravi lstPubSubs : '+lstPubSubs);                                           
            //Get COA/COV Data
            Map<ID, Case_Subscription__c> mapOliIDToCaseSub = getRelatedCOAs(lstPubSubs);
            
            for(Zuora__Subscription__c subObj : mapRecipientToDelSub.values())
            {
                BT_CO_VSS_CreditDebit__c vssRecord = new BT_CO_VSS_CreditDebit__c();
                //START UD-2896 22-Sep-2015 Added by Raviteja  - copies should not be shown for delivery records
                //vssRecord.Copies__c = subObj.Number_of_Copies__c;
                //End UD-2896 22-Sep-2015 Added by Raviteja  -
                vssRecord.Credit_Debit__c = GlobalVariableClass.CREDIT_IND;
                vssRecord.Delivery__c = subObj.Vendor_Credit_1__c;
                vssRecord.Posting_Date__c = monthEnd;
                vssRecord.Recipient_Contact__c = subObj.Recipient_Contact__c;
                vssRecord.Total_Amount__c = subObj.Vendor_Credit_1__c;
                //Check if any COA/COV event during the period
                if(mapOliIDToCaseSub.containsKey(subObj.Order_Line_Item_Number_1__c))
                {
                    vssRecord.Vendor_Group__c = 'V';
                    vssRecord.Vendor_Number__c = mapOliIDToCaseSub.get(subObj.Order_Line_Item_Number_1__c).Vendor_Code__c;                   
                    vssRecord.Address__c= mapOliIDToCaseSub.get(subObj.Order_Line_Item_Number_1__c).Address__c;               
                    vssRecord.Delivery__c = mapOliIDToCaseSub.get(subObj.Order_Line_Item_Number_1__c).Old_Vendor_Credit__c;                    
                    vssRecord.Total_Amount__c = mapOliIDToCaseSub.get(subObj.Order_Line_Item_Number_1__c).Old_Vendor_Credit__c;
                    //START/End UD-3393_UD-3702_D-4287 18-Jan-2016 - Hotfix Raviteja - Adding Old_Recipient_Contact__c in VSS records
                    vssRecord.Recipient_Contact__c = mapOliIDToCaseSub.get(subObj.Order_Line_Item_Number_1__c).Old_Recipient_Contact__c;
                }
                else
                {
                    vssRecord.Vendor_Group__c = subObj.Vendor_1__r.Vendor_Group__c;
                    vssRecord.Vendor_Number__c = subObj.Vendor_1__r.Vendor_Code__c;
                    vssRecord.Address__c= subObj.Recipient_Contact__r.Address__c; //START/End D-3686 - Hotfix Raviteja - 02Oct2015 - Adding Addressid in VSS records
                }
                vssRecord.Job_Id__c = 'SP011'; //START/END 03/19/2015 MD-50 Kevin Evasco Credit Note Generation
                //START D-3621 - Hotfix Raviteja - 28Sep2015 - Handling REQUIRED_FIELD_MISSING, Required fields are missing  [Vendor_Group__c, Vendor_Number__c] Error
                //lstVSSRecords.add(vssRecord);
                if(vssRecord.Vendor_Group__c != Null && vssRecord.Vendor_Number__c != Null)
                    lstVSSRecords.add(vssRecord);
                //End D-3621 - Hotfix Raviteja - 28Sep2015 - 
            }
            
            INSERT lstVSSRecords;
        }catch(Exception e){
            logger.logBatchFailure(e, lstContacts);
            
            isApexJobSuccessful = false;
        }finally{
            logger.save();
        }
        //END D-3657 LISEN 20-Oct-2015 - Enable on demand batch based on selective contacts
    }
    
    global void finish (Database.BatchableContext BC){
        Id jobID = BC.getJobId();
        
        //Start the VBS Processing Batch - Default Size 2
        //START / End UD-2896 22-Sep-2015 Added by Raviteja - Added this.monthEnd
        SP_VBSDeliveryFeeBatch batchJob = new SP_VBSDeliveryFeeBatch(jobID, this.monthEnd);
        Database.executeBatch(batchJob, 2);
    }
    
    //Get old vendor provided this old vendor have delivered at least for 1 day
    public Map<Id,Case_Subscription__c> getRelatedCOAs(List<Zuora__Subscription__c> lstPubSubs)
    {
        Map<ID, Case_Subscription__c> mapOliIDToCaseSub = new Map<ID, Case_Subscription__c>();
        //START/End D-3686 - Hotfix Raviteja - 02Oct2015 - Adding Address in SOQL
        //START/End UD-3007 - Hotfix Raviteja - 13Oct2015 - Adding Old Vendor Credit in SOQL
        //Fetch all the COA/COV Cases - the earliest record will take precedence 
        
        //START-End UD-3393_UD-3702_D-4287 18-Jan-2016 Added by Raviteja - added Old_Recipient_Contact__c in SOQL
        for(Case_Subscription__c caseSub : [SELECT ID, Case__r.Effective_Date__c, Vendor_Code__c, Subscription__r.Order_Line_Item_Number_1__c, Address__c, Old_Vendor_Credit__c
                                                     ,Old_Recipient_Contact__c    
                       FROM Case_Subscription__c WHERE Subscription__c in :lstPubSubs AND Case__r.Status = :GlobalVariableClass.STATUS_CLOSED 
                       //START UD-3780 15-Jan-2016 Added by Raviteja  - Adding dtToday and sorting by Lastmodifieddate in SOQL
                       // AND Case__r.Effective_Date__c > :monthStart AND Case__r.Effective_Date__c <= :monthEnd                       
                       AND Case__r.Effective_Date__c > :monthStart 
                       AND (Case__r.Change_of_Address_Type__c = :GlobalVariableClass.BILLDELIVERYADD 
                            OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.DELIVERYADDLOC
                            //OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.CHANGEVENDOR)])
                            OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.CHANGEVENDOR) Order by LastmodifiedDate ASC])
                      //END UD-3780 15-Jan-2016 Added by Raviteja      
        {
            ID oliID = caseSub.Subscription__r.Order_Line_Item_Number_1__c;
            if(mapOliIDToCaseSub.containsKey(oliID))
            {
                Case_Subscription__c curRec = mapOliIDToCaseSub.get(oliID);
                if(caseSub.Case__r.Effective_Date__c < curRec.Case__r.Effective_Date__c) //Earlier than existing 
                    mapOliIDToCaseSub.put(oliID, caseSub);
            }
            else
                mapOliIDToCaseSub.put(oliID, caseSub);
        }
        
        return mapOliIDToCaseSub;
    }
}