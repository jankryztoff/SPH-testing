/**
 * Class Name: SM_SubscriptionCancellationHelper 
 * @author: John Dacutan
 * Date: 10/21/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description: Class for Cancellation of Subscription, related subscriptions and Delivery Charge (if applicable) 
 * History: 16/12/2014 Kastine Campang: Added @future, creation, and loading of Usage to Zuora
 * History: 15/01/2015 Wenjun : Postage Charge and fix bugs
 * History: 01/29/2015 D-2534 Kevin Evasco Isolate Callout Method from Future Method. This way the callout can be done without executing an async method.
 */
public class SM_SubscriptionCancellationHelper {
    //START D-1977 D-2003 D-2134 Added by FrancisBenzon 2/18/15 : do not cancel delivery sub
    //END D-1977 D-2003 D-2134 Added by FrancisBenzon 2/18/15 : do not cancel delivery sub    
    /*
    *   @description : This method will retrieve all related subscriptions based from 
    *           Order Line Item field in Subscription object. Also try to retrieve the 
    *           Subscription Delivery Charge for respective Address. If no other active subscription
    *           on the associated delivery charge, the subscription delivery charge will also be stopped
    *   @param : map of subscription id and its corresponding stop date
    *   @return : map of zuora subscription id and its corresponding stop date
    */
    // Start D-2593 26Mar15 JohnD
    public static Order__c associatedOrder;
    public static boolean isSuccess;
    public static string errorMessage;
    private static final string CANCELLATION_AMENDMENT_NAME = globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT + ' - ' + datetime.now().format('yyyMMddHmmss');
    // End D-2593 26Mar15 JohnD
    //START Added By FrancisBenzon 6/8/2015 UD-1044 : global variable for stop usage creation
    public static Map<String, Date> stopDateEffectiveDate = new Map<String, Date>();
    //END Added By FrancisBenzon 6/8/2015 UD-1044 : global variable for stop usage creation
    public static Logger logger = new Logger(SM_SubscriptionCancellationHelper.class.getName());  //START/END UD-3337 12/11/15 RReyes: log error on amendment
    
    @future(callout=true)
        //START D-2003 2/18/15 AddedBy FrancisBenzon : handling of cancellation of Delivery Subscription
    public static void cancel(map<id, date> subscriptionId_effectiveDate, String origin) {
        cancelSubscriptions(subscriptionId_effectiveDate, origin); // START/END 01/29/2015 D-2534 Kevin Evasco Isolate Callout Method from Future Method. This way the callout can be done without executing an async method.
    }
    
    //START UD-1595 JTeves/FBenzon 19-June-2015 Cancel Urgent COS subscription only after approval
    @future(callout=true)
    public static void cosCancel(map<id, date> subscriptionId_effectiveDate, String origin, Id orderId) {
        string queryStr = SM_SubscriptionHelper.generateOrderSoqlStr();
        queryStr += ' where Id = :orderId';
        associatedOrder = (Order__c) Database.query(queryStr);
        cancelSubscriptions(subscriptionId_effectiveDate, origin); 
    }
    //END UD-1595 JTeves/FBenzon 19-June-2015 Cancel Urgent COS subscription only after approval
    // START 01/29/2015 D-2534 Kevin Evasco Isolate Callout Method from Future Method. This way the callout can be done without executing an async method.
    public static void cancelSubscriptions(map<id, date> subscriptionId_effectiveDate, String origin) {
        system.debug(':::SUBidDate' + ' ' + subscriptionId_effectiveDate);
        //END D-2003 2/18/15 AddedBy FrancisBenzon : handling of cancellation of Delivery Subscription
        Zuora.zApi.AmendResult result;
        id accountId;
        map<string, date> returnZuoraSubscriptionId_effectiveDate = new map<string, date>();
        map<string, string> returnZuoraEffectiveToSubscriptionName = new map<string, string>();
        map<string, date> orderLineItemId_effectiveDate = new map<string, date>();
        //START D-2330 Added By K.Campang - Cancel selected Subscriptions
        Map<Id, String> subIdToSubNameMap = new Map<Id, String>();
        //END D-2330 Added By K.Campang
        string addressUnique = '';
        //variables for Usage
        Map<String, object> usageMap = new Map<String, object>(); //START-END D-4080 12-11-2015 added by Jason A. for code review
        List<Map<String, object>> listMap = new List<Map<String, object>>(); //START-END D-4080 12-11-2015 added by Jason A. for code review
        List<Usage__c> usageToZuora = new List<Usage__c>(); //START-END D-4080 12-11-2015 added by Jason A. for code review
        //START D-2330 Added By K.Campang - Cancel selected Subscriptions
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        //END D-2330 Added By K.Campang
        List<Map<String,String>> resultMap_Usage = new List<Map<String,String>>();
        Date startDate;
        Set<Id> subsIdSet = new Set<Id>();
        List<Id> subsIdList = new List<Id>();
        
        //START D-1545 1/29/2015 Added By C. Lin - Variables for Admin Charge Ammendment.
        Map<Id, String> mapSubsId_ZuoraId = new Map<Id, String>();
        //START D-3278 7/27/2015 Added By C. Lin - Change Decimal to Order_Line_Item__c
        Map<Id, Order_Line_Item__c> mapSubsId_OLI = new Map<Id, Order_Line_Item__c>();
        //END D-3278 7/27/2015 Added By C. Lin
        List<Zuora__Subscription__c> currentSubsList = new List<Zuora__Subscription__c>(); // Start/End D-2593 26Mar15 JohnD moved variable here.
        Decimal adminFee = 0;
        //END D-1545 1/29/2015 Added By C. Lin
        
        //START UD-1044 6/4/15 AddedBy FrancisBenzon : variables for new implementation
        Set<Id> billingAccountIdSet = new Set<Id>();
        List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>();
        List<Invoice_Line_Item__c> invoiceLineItemList = new List<Invoice_Line_Item__c>();
        List<Zuora__Subscription__c> delPostageSubsList = new List<Zuora__Subscription__c>();
        List<Zuora__Subscription__c> pubDelPostageSubs = new List<Zuora__Subscription__c>();
        Set<Id> pubDelSubsIds = new Set<Id>();
        Map<String, List<String>> subZuoraId_InvoiceZuoraID = new Map<String, List<String>>();
        Map<String, List<Date>> invoiceZuoraId_TargetDate = new Map<String, List<Date>>();
        Map<String, List<Date>> billingAccount_invoiceTargetDates = new Map<String, List<Date>>();      
        //END UD-1044 6/4/15 AddedBy FrancisBenzon : variables for new implementation
        //START D-4324 RReyes 01/26/16 - added try catch in case of error
        Set<String> setSubZuoraId = new Set<String>();
        List<Case> caseToUpdate = new List<Case>();
        Id cosCase = ConstantsSLB.getKeyId('Case_Change of Subscription');
        //END D-4324 RReyes 01/26/16 - added try catch in case of error
        // start current subscription retrieval
        //START UD-1044 6/4/15 AddedBy FrancisBenzon : added billing account in query
        //START UD-3371 added new field query
        for (Zuora__Subscription__c tmp : [select Id, Name, Recipient_Contact__r.Address_Unique_Id__c, Zuora__Account__c,   
                Order_Line_Item_Number__c, Zuora__Zuora_Id__c, Zuora__SubscriptionStartDate__c, Promotion_1__c, 
                Zuora__CustomerAccount__c,Subscription_Type_1__c, Order_Number_1__r.Latest_Start_Date__c 
                from Zuora__Subscription__c 
                where Id in :subscriptionId_effectiveDate.keySet()]) // Start/End D-2593 26Mar15 JohnD added Promotion_1__c field
        {  
        //END UD-3371 added new field query
        //END UD-1044 6/4/15 AddedBy FrancisBenzon : added billing account in query
            //for Usage
            startDate = tmp.Zuora__SubscriptionStartDate__c;
            subsIdSet.add(tmp.Id);
            currentSubsList.add(tmp);
            //START D-1545 1/29/2015 Added By C. Lin - Subscription Zuora Id Map to be used in Admin Charge Ammendment.
            mapSubsId_ZuoraId.put(tmp.Id, tmp.Zuora__Zuora_Id__c);
            //END D-1545 1/29/2015 Added By C. Lin
            //START UD-1044 6/4/15 AddedBy FrancisBenzon : added billing account Id in set
            billingAccountIdSet.add(tmp.Zuora__CustomerAccount__c); 
            pubDelSubsIds.add(tmp.Id);      
            pubDelPostageSubs.add(tmp);
            stopDateEffectiveDate.put(tmp.Zuora__Zuora_Id__c, subscriptionId_effectiveDate.get(tmp.Id));
            //END UD-1044 6/4/15 AddedBy FrancisBenzon : added billing account Id in set
            //start of Cancel    
            accountId = tmp.Zuora__Account__c;
            
            // initialize address to stop
            
            // initialize order line item effective date
            // assuming that only 1 subscription per order line item has been passed in the parameter
            orderLineItemId_effectiveDate.put(tmp.Order_Line_Item_Number__c, subscriptionId_effectiveDate.get(tmp.Id));
            // end initialize order line item effective date
            //START Added By FrancisBenzon 6/8/2015 UD-1044 : move this population to counter check invoice target date. query invoice using billing acct
            /*
            //START D-2597 Added By J.Sarion - Stop Date for COS is 1 day before the Start Date of the New Subscription         
            if (origin == 'Change of Subscription' || origin == 'ESHOP Change of Subscription') //START/END 05/15/2015 Kevin Evasco - ESHOP Hotfix 
                returnZuoraSubscriptionId_effectiveDate.put(tmp.Zuora__Zuora_Id__c, subscriptionId_effectiveDate.get(tmp.Id).addDays(-1));
            else
                returnZuoraSubscriptionId_effectiveDate.put(tmp.Zuora__Zuora_Id__c, subscriptionId_effectiveDate.get(tmp.Id));
            
            //END D-2597 Added By J.Sarion - Stop Date for COS is 1 day before the Start Date of the New Subscription
            */
            //START Added By FrancisBenzon 6/8/2015 UD-1044 : move this population to counter check invoice target date. query invoice using billing acct
            returnZuoraEffectiveToSubscriptionName.put(tmp.Zuora__Zuora_Id__c, tmp.Name);
        }
        //START Added By FrancisBenzon 6/8/2015 UD-1044 : moved code here
        // Start D-2351 24/02/2015 JohnD remove null key on orderLineItemId_effectiveDate and subscriptionId_effectiveDate
        orderLineItemId_effectiveDate.remove(null);
        subscriptionId_effectiveDate.remove(null);
        //START Added By FrancisBenzon 6/8/2015 UD-1044 : moved code here
        
        //START Added By FrancisBenzon 6/8/2015 UD-1044 : new implementation for cancellation of subscription anytime
        //START UD-2738 Wenjun 18/Sep/15: For FPP, Set Cancel Date = 1st Day of next month if stop in the same month as start
        //START UD-3371 added new field query
        //START D-4077 15Dec15 : added new field query
        delPostageSubsList = [SELECT Id, Name, Zuora__Zuora_Id__c, Subscription_Type_1__c, Order_Line_Item_Number__c,
                                Zuora__SubscriptionStartDate__c, Zuora__CustomerAccount__c, Billing_Type__c, Order_Number_1__r.Latest_Start_Date__c,
                                Zuora__SubscriptionEndDate__c, Term_Length__c
                                FROM Zuora__Subscription__c 
                                WHERE Order_Line_Item_Number_1__c in :orderLineItemId_effectiveDate.keySet() 
                                AND Id not in :subscriptionId_effectiveDate.keySet() and Zuora__Status__c = 'Active'];
        //END UD-3371 added new field query
        //END D-4077 15Dec15 : added new field query
        for(Zuora__Subscription__c otherSub : delPostageSubsList)
        {
            pubDelSubsIds.add(otherSub.Id);
            pubDelPostageSubs.add(otherSub);
            
            Date defaultStopDate = orderLineItemId_effectiveDate.get(otherSub.Order_Line_Item_Number__c);
            
            stopDateEffectiveDate.put(otherSub.Zuora__Zuora_Id__c, defaultStopDate); //START END D-3609 Wenjun 24/09/15 Move code here
            
            if(otherSub.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID)
            {
                //START UD-3371 10Dec15 FrancisBenzon : replaced reference to latest start date amongst OLIs
                //Check if Stop Date is in the same month or even before the Start Date
                if(otherSub.Order_Number_1__r.Latest_Start_Date__c.monthsBetween(defaultStopDate) <= 0)
                    defaultStopDate = otherSub.Order_Number_1__r.Latest_Start_Date__c.toStartOfMonth().addMonths(1);
                //START D-4077 15Dec15 : change othersub field 
                if(defaultStopDate > otherSub.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueof(otherSub.Term_Length__c)))
                    defaultStopDate = otherSub.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueof(otherSub.Term_Length__c));
                //END D-4077 15Dec15 : change othersub field 
                //END UD-3371 10Dec15 FrancisBenzon : replaced reference to latest start date amongst OLIs
            }
            
            //stopDateEffectiveDate.put(otherSub.Zuora__Zuora_Id__c, defaultStopDate); //START END D-3609 Wenjun 24/09/15 Move code above
            subscriptionId_effectiveDate.put(otherSub.Id, defaultStopDate);
        }
        //END UD-2738 Wenjun 18/Sep/15
                
        
        //START D-3609 29/09/15 Wenjun : Remove Invoice Target Date Checking
        /*
        invoiceLineItemList = [Select Invoice_ID__c, Subscription_ID__c From Invoice_Line_Item__c Where Subscription__c IN : pubDelSubsIds];
        
        
        Set<String> invoiceIds = new Set<String>();
        for(Invoice_Line_Item__c ili : invoiceLineItemList) {
            if(ili.Invoice_ID__c != NULL && ili.Invoice_ID__c != '') {
                invoiceIds.add(ili.Invoice_ID__c);
            }
        }
        
        Map<String, Zuora__ZInvoice__c> invoiceMap = new Map<String, Zuora__ZInvoice__c>();
        for(Zuora__ZInvoice__c inv : [SELECT Id, Zuora__TargetDate__c, Zuora__BillingAccount__c, Zuora__Zuora_Id__c
                                        From Zuora__ZInvoice__c 
                                        Where Zuora__Zuora_Id__c IN :invoiceIds 
                                        ORDER by Zuora__TargetDate__c Desc]) {
            invoiceMap.put(inv.Zuora__Zuora_Id__c, inv);
        }
        Map<String, Date> subIdToLatestInvoiceDateMap = new Map<String, Date>();
        for(Invoice_Line_Item__c ili : invoiceLineItemList) {
            if(invoiceMap.containsKey(ili.Invoice_ID__c)) {
                //subscription already in Map
                if(subIdToLatestInvoiceDateMap.containsKey(ili.Subscription_ID__c)) {
                    if(invoiceMap.get(ili.Invoice_ID__c).Zuora__TargetDate__c > subIdToLatestInvoiceDateMap.get(ili.Subscription_ID__c)) 
                    {
                        subIdToLatestInvoiceDateMap.put(ili.Subscription_ID__c, invoiceMap.get(ili.Invoice_ID__c).Zuora__TargetDate__c);
                    }
                }
                else {
                    subIdToLatestInvoiceDateMap.put(ili.Subscription_ID__c, invoiceMap.get(ili.Invoice_ID__c).Zuora__TargetDate__c);
                }
            }
        }
    */
    //END D-3609 29/09/15 Wenjun : Remove Invoice Target Date Checking
        
        //START D-3224 Rebuild CommentedOut By FrancisBenzon : remove query from Invoice. Always use INV Line Item. If none then use inputted date
        /*
        //validate checking below
        if(invoiceLineItemList.isEmpty()) {
            invoiceList = [Select Id, Zuora__TargetDate__c, Zuora__BillingAccount__c, Zuora__Zuora_Id__c
                            From Zuora__ZInvoice__c 
                            Where Zuora__BillingAccount__c IN :billingAccountIdSet 
                            ORDER by Zuora__TargetDate__c Desc];
            for(Zuora__ZInvoice__c inv : invoiceList)
            {
                if(billingAccount_invoiceTargetDates.containsKey(inv.Zuora__BillingAccount__c))
                {
                    billingAccount_invoiceTargetDates.get(inv.Zuora__BillingAccount__c).add(inv.Zuora__TargetDate__c);
                }
                else {
                    billingAccount_invoiceTargetDates.put(inv.Zuora__BillingAccount__c, new List<Date>{inv.Zuora__TargetDate__c});
                }
            }
        }
        */
        //END D-3224 Rebuild CommentedOut By FrancisBenzon : remove query from Invoice. Always use INV Line Item. If none then use inputted date
        
    //START D-3609 29/09/15 Wenjun : Remove Invoice Target Date Checking
        /*
        
        //loop for both publication and delivery subs since they have the same start date
        //list of subs for del and pub
        for(Zuora__Subscription__c pubSubs : pubDelPostageSubs)
        {
            //START D-3224 7/7/15 AddedBy FrancisBenzon : cater subs with invoice line items
            if(subIdToLatestInvoiceDateMap.containsKey(pubSubs.Zuora__Zuora_Id__c) && subscriptionId_effectiveDate.get(pubSubs.Id) <= subIdToLatestInvoiceDateMap.get(pubSubs.Zuora__Zuora_Id__c))
            {
                //START/END UD-1044 Hotfix
                //START D-3224 AddedBy FrancisBenzon : removed plus invoice target date + 1, cancellation date can be = INV Target Date
                returnZuoraSubscriptionId_effectiveDate.put(pubSubs.Zuora__Zuora_Id__c, subIdToLatestInvoiceDateMap.get(pubSubs.Zuora__Zuora_Id__c));//END D-3224 AddedBy FrancisBenzon : removed plus invoice target date + 1, cancellation date can be = INV Target Date                                       
            }
            else {                  
                returnZuoraSubscriptionId_effectiveDate.put(pubSubs.Zuora__Zuora_Id__c, subscriptionId_effectiveDate.get(pubSubs.Id));                 
            }
            //END D-3224 7/7/15 AddedBy FrancisBenzon : cater subs with invoice line items   
    */
        for(Zuora__Subscription__c pubSubs : pubDelPostageSubs)
        {   
            //Convert to Zuora ID for Cancellation Callout
            returnZuoraSubscriptionId_effectiveDate.put(pubSubs.Zuora__Zuora_Id__c, subscriptionId_effectiveDate.get(pubSubs.Id));                       
        }
    //END D-3609 29/09/15 Wenjun : Remove Invoice Target Date Checking
        
        //START D-3224 Rebuild CommentedOut By FrancisBenzon : remove query from Invoice. Always use INV Line Item. If none then use inputted date
            /*
            else {
                if(billingAccount_invoiceTargetDates.get(pubSubs.Zuora__CustomerAccount__c) != null && !billingAccount_invoiceTargetDates.get(pubSubs.Zuora__CustomerAccount__c).isEmpty())
                {                   
                    if(billingAccount_invoiceTargetDates.containsKey(pubSubs.Zuora__CustomerAccount__c))
                    {
                        //pubsubs should not be checked cause those are old subs. 
                        //use this subscriptionId_effectiveDate.get(pubSubs.Id)
                        //Fritz
                        //START/END UD-1044 Hotfix
                        if(subscriptionId_effectiveDate.get(pubSubs.Id)  <= billingAccount_invoiceTargetDates.get(pubSubs.Zuora__CustomerAccount__c)[0])
                        {
                            returnZuoraSubscriptionId_effectiveDate.put(pubSubs.Zuora__Zuora_Id__c, billingAccount_invoiceTargetDates.get(pubSubs.Zuora__CustomerAccount__c)[0].addDays(1));
                        }
                        //add filter for subscription type
                        else {
                            if(pubSubs.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION)
                            {
                                returnZuoraSubscriptionId_effectiveDate.put(pubSubs.Zuora__Zuora_Id__c, subscriptionId_effectiveDate.get(pubSubs.Id));
                            }
                            else {
                                returnZuoraSubscriptionId_effectiveDate.put(pubSubs.Zuora__Zuora_Id__c, orderLineItemId_effectiveDate.get(pubSubs.Order_Line_Item_Number__c));
                            }
                        }
                    }                                                   
                }
            } 
            */
            //END D-3224 Rebuild CommentedOut By FrancisBenzon : remove query from Invoice. Always use INV Line Item. If none then use inputted date
        //}  //START END D-3609 29/09/15 Wenjun : Remove Invoice Target Date Checking
        //END Added By FrancisBenzon 6/8/2015 UD-1044 : new implementation for cancellation of subscription anytime
        
        //START D-3609 Wenjun 24/09/15 - No longer needed
        /*
         //START UD-1595 AddedBy FBenzon/JTeves : for recurring subs
        system.debug(':::STOPDATEEFFECTIVEDATE' + stopDateEffectiveDate);
        if(returnZuoraSubscriptionId_effectiveDate.isEmpty())
        {
            //returnZuoraSubscriptionId_effectiveDate.put(pubSubs.Zuora__Zuora_Id__c, subscriptionId_effectiveDate.get(pubSubs.Id));            
            returnZuoraSubscriptionId_effectiveDate.putAll(stopDateEffectiveDate);
        }
        //END UD-1595 AddedBy FBenzon/JTeves : for recurring subs
        */
        //END D-3609 Wenjun 24/09/15 - No longer needed
        
        // end current subscription retrieval
        
        //START D-3411 Wenjun 03/Sep/15 : Waive Charge for COS 
        //START: D-1356 1/30/2015 Added by Kristine Campang - added query for case retrieval
        /* Wenjun 03/Sep/15 Not in use
        List<Order_Line_Item__c> orderLine = [SELECT Id, Subscription__c, Case__c, Case__r.Sub_Category__c, 
                                        Case__r.Sub_Status__c,  Case__r.Status
                                        FROM Order_Line_Item__c 
                                        WHERE Subscription__c =:subscriptionId_effectiveDate.keySet() AND Case__r.Sub_Category__c =:GlobalVariableClass.SUBCATEGORY_STOP_SUBCRIPTION];
        */
        //START: New PC Implementation Added by Kristine Campang - usage creation transferred tp Submit button
        
        //START D-1545 1/29/2015 Added By C. Lin - Admin Charge value from Order Line Item of Stop Subscription to be used in Admin Charge Ammendment.
        //START D-3278 7/27/2015 Added By C. Lin - Update Query to add Fee_Waiver__c
        //START: D-3941 11/16/15 Added by Manolo Valena - Added Fee_Override__c and Fee_Override_Amount__c fields to the query.
        for(Order_Line_Item__c oli : [SELECT Id, Admin_Charge__c, Subscription__c, Fee_Waiver__c, Order__r.Subscription__c, 
                                             Fee_Override__c, Fee_Override_Amount__c 
                                      FROM Order_Line_Item__c 
                                      WHERE Subscription__c IN :subscriptionId_effectiveDate.keySet() OR Order__r.Subscription__c IN :subscriptionId_effectiveDate.keySet()])
        {
            if(oli.Subscription__c != NULL)
                mapSubsId_OLI.put(oli.Subscription__c, oli); 
            else if(oli.Order__r.Subscription__c != NULL)
                mapSubsId_OLI.put(oli.Order__r.Subscription__c, oli); 
        }
        //END: D-3941 11/16/15 Added by Manolo Valena
        
        //END D-3278 7/27/2015 Added By C. Lin
        //END D-1545 1/29/2015 Added By C. Lin
        //END D-3411 Wenjun 03/Sep/15 : Waive Charge for COS 


        // Start D-2593 26Mar15 JohnD moved code here
        //START D-2567 6/29/2015 Added By C. Lin - Move this method after admin charge amendment
        //processCancellation(returnZuoraSubscriptionId_effectiveDate, returnZuoraEffectiveToSubscriptionName);
        //END D-2567 6/29/2015 Added By C. Lin
        // End D-2593 26Mar15 JohnD moved code here
        
        //START D-2567 6/29/2015 Added By C. Lin - Remove && isSuccess == true
        system.debug('-----CHA subsIdSet ' + subsIdSet);
        system.debug('-----CHA subsIdSet.size() ' + subsIdSet.size());
        if(subsIdSet.size() > 0) {
        //END D-2567 6/29/2015 Added By C. Lin
            //START D-1545 1/29/2015 Added By C. Lin - Admin Charge Ammendment function for the subscription.             
            system.debug('-----CHA currentSubsList ' + currentSubsList);
            for(Zuora__Subscription__c subs : currentSubsList){
                //Admin Fee
                system.debug('-----CHA subs ' + subs);
                system.debug('-----CHA subs.Promotion_1__c ' + subs.Promotion_1__c);
                system.debug('-----CHA mapSubsId_OLI.containsKey(subs.Id) ' + mapSubsId_OLI.containsKey(subs.Id));
                if(subs.Promotion_1__c != Null && mapSubsId_OLI.containsKey(subs.Id)){ //START/END UD-2152 AddedBy FrancisBenzon 7/28/15 : added map checking to void attempt to dereference null
                    //START D-3278 7/27/2015 Added By C. Lin - Check if Fee_Waiver__c is false
                    //START: D-3941 11/16/15 Added by Manolo Valena - Updated condition.
                    system.debug('-----CHA mapSubsId_OLI.get(subs.Id).Fee_Waiver__c ' + mapSubsId_OLI.get(subs.Id).Fee_Waiver__c);
                    system.debug('-----CHA mapSubsId_OLI.get(subs.Id).Fee_Override__c ' + mapSubsId_OLI.get(subs.Id).Fee_Override__c);
                    if(mapSubsId_OLI.get(subs.Id).Fee_Waiver__c == false && mapSubsId_OLI.get(subs.Id).Fee_Override__c == false){
                    //END: D-3941 11/16/15 Added by Manolo Valena
                        system.debug('-----CHA mapSubsId_ZuoraId.get(subs.Id) ' + mapSubsId_ZuoraId.get(subs.Id));
                        system.debug('-----CHA mapSubsId_OLI.get(subs.Id).Admin_Charge__c ' + mapSubsId_OLI.get(subs.Id).Admin_Charge__c);
                        system.debug('-----CHA subscriptionId_effectiveDate.get(subs.Id).addDays(-1) ' + subscriptionId_effectiveDate.get(subs.Id).addDays(-1));
                        //START D-3411 Wenjun 03/Sep/15 : Code Optimization - No future call for Admin Charge by reviewing all scenarios
                        try{ //CHA
                        AdminCharge_Amendment adminChargeCall = new AdminCharge_Amendment();
                        adminChargeCall.amendForNewProduct(mapSubsId_ZuoraId.get(subs.Id), mapSubsId_OLI.get(subs.Id).Admin_Charge__c,
                                    subscriptionId_effectiveDate.get(subs.Id).addDays(-1), subscriptionId_effectiveDate.get(subs.Id).addDays(-1), 
                                    subscriptionId_effectiveDate.get(subs.Id).addDays(-1), subscriptionId_effectiveDate.get(subs.Id).addDays(-1));
                        }catch(Exception e){ //CHA
                            system.debug('-----CHA ADMIN CHARGE ERROR ' + e);
                        }
                       //END D-3411 Wenjun 03/Sep/15 : Code Optimization
                    }
                    //END D-3278 7/27/2015 Added By C. Lin
                    //START: D-3941 11/16/15 Added by Manolo Valena - Added condition.
                    else if(mapSubsId_OLI.get(subs.Id).Fee_Waiver__c == false && mapSubsId_OLI.get(subs.Id).Fee_Override__c == true) {
                        try{ //CHA
                        AdminCharge_Amendment adminChargeCall = new AdminCharge_Amendment();
                        adminChargeCall.amendForNewProduct(mapSubsId_ZuoraId.get(subs.Id), mapSubsId_OLI.get(subs.Id).Fee_Override_Amount__c,
                                    subscriptionId_effectiveDate.get(subs.Id).addDays(-1), subscriptionId_effectiveDate.get(subs.Id).addDays(-1), 
                                    subscriptionId_effectiveDate.get(subs.Id).addDays(-1), subscriptionId_effectiveDate.get(subs.Id).addDays(-1));
                        }catch(Exception e){ //CHA
                            system.debug('-----CHA ADMIN CHARGE ERROR2 ' + e);
                        }
                    }
                    //END: D-3941 11/16/15 Added by Manolo Valena
                }
            }
            //END D-1545 1/29/2015 Added By C. Lin
     
            //START UD-1595 JTeves/FBenzon 19-June-2015 Move the Case Creation to COS Controller, and Subscription Creation to Queueable class
            //remove the entire block
            // Start D-2593 26Mar15 JohnD create the new subscription
            //if (origin == 'Change of Subscription') {
            //    Subscription_Handler sh = new Subscription_Handler();
            //    sh.origin = origin;              
            //    sh.Subscription_Handler_Direct(associatedOrder);
            //}
            // End D-2593 26Mar15 JohnD create the new subscription
            //END UD-1595 JTeves/FBenzon 19-June-2015 Move the Case Creation to COS Controller, and Subscription Creation to Queueable class
        } else {
            
            // Start D-2593 26Mar15 JohnD create the new subscription
            if (origin == 'Change of Subscription' || origin == 'ESHOP Change of Subscription') {//START/END 05/15/2015 Kevin Evasco - ESHOP Hotfix
                
            }
            // End D-2593 26Mar15 JohnD create the new subscription
        }
        //END: New PC Implementation Added by Kristine Campang

        //START D-2567 6/29/2015 Added By C. Lin - Move after amendment of Admin Charge
        //START D-4324 RReyes 01/26/16 - added try catch. in case of error, update case sub status
        try{
            processCancellation(returnZuoraSubscriptionId_effectiveDate, returnZuoraEffectiveToSubscriptionName);
        }catch(Exception e){
            logger.log(false, '[Subscription Cancellation Error] : [' + returnZuoraSubscriptionId_effectiveDate + '] - Error: ' + e);
            isSuccess = false;
            errorMessage = 'Zuora Issue: An error was encountered while trying to cancel subscriptions in Zuora.';
            for(String zSubId : returnZuoraEffectiveToSubscriptionName.keySet()){
                if(zSubId != null){
                    setSubZuoraId.add(zSubId);
                }
            }
        }
        
        if(!setSubZuoraId.isEmpty()){
            caseToUpdate = [SELECT Id, Sub_Status__c FROM Case WHERE RecordTypeId=:cosCase AND Status =:GlobalVariableClass.STATUS_PENDING AND Subscription_Name__r.Zuora__Zuora_Id__c IN: setSubZuoraId];
        }
        System.debug('>>> rr: caseToUpdate: before:  ' + caseToUpdate);
        if(caseToUpdate.size() > 0){
            for(Case caseRec: caseToUpdate){
                caseRec.Sub_Status__c = GlobalVariableClass.ZUORA_ISSUE_CANCELLATION;
            }
            try{
                System.debug('>>> rr: caseToUpdate: updated:  ' + caseToUpdate);
                update caseToUpdate;
            }catch(Exception e){
                logger.log(false, 'Error updating case: ' + caseToUpdate);
            }
        }
        logger.save();
        //END D-4324 RReyes 01/26/16 - added try catch. in case of error, update case sub status
        //END D-2567 6/29/2015 Added By C. Lin

        // ZuoraCallOut zuorCall = new ZuoraCallOut(); - JohnD 26Mar15 remove this cause there is no use in this method
        //END D-2330 Added By K.Campang
        //START: New PC Implementation Added by Kristine Campang - for response map of callout
        //END: New PC Implementation Added by Kristine Campang - for response map of callout
    }
    // END 01/29/2015 D-2534 Kevin Evasco Isolate Callout Method from Future Method. This way the callout can be done without executing an async method.  
     
    /*
    *   @description : This method will call the zuora api and it  
    *           will be executed separately from where it was invoked. 
    */
    public static void processCancellation(map<string, date> zuoraSubscriptionId_effectiveDate, map<String, String> returnZuoraEffectiveToSubName) {
        //START D-2330 Added By K.Campang - Cancel selected Subscriptions
        ZuoraCallOut zuorCall = new ZuoraCallOut();
        //END D-2330 Added By K.Campang
        Zuora.zApi.AmendResult sample;
        list<String> subNameList = new list<String>();
        Id stopCase = ConstantsSLB.getKeyId('Case_Stop');
        list<Zuora.zObject> amendmentList = new list<Zuora.zObject>();
        //START D-2330 Added By K.Campang - Cancel selected Subscriptions 
 
        // Start D-2660 02Apr15 JohnD refactored code
        isSuccess = true;
        errorMessage = '';
        string amendmentZuoraIds = '';
        list<Zuora.zObject> amendmentRequests;
        list<string> amendmentIdList = new list<string>();
        string errorMessageToSkip;
        //START UD-3337 FrancisBenzon 16Dec15 : error message var
        List<String> retryErrorsList = new List<String>();
        Boolean retryAmendCall = false;
        String numberOfRetries = ConstantsSLB.getkeyId('ZUORA_RETRY_TIMES');
        String errorForRetry = ConstantsSLB.getErrorMessage('ZUORA_AMEND_RETRY_MSG');
        system.debug(':::ERRORMESSAGE  ' + errorForRetry);
        retryErrorsList = errorForRetry.split(';');
        Integer errorSize = retryErrorsList.size();
        Set<String> configurableErrorSet = new Set<String>();
        system.debug(':::ERRORLIST  ' + retryErrorsList);
        //END UD-3337 FrancisBenzon 16Dec15 : error message var
        
        System.debug('=====> zuoraSubscriptionId_effectiveDate: '+ zuoraSubscriptionId_effectiveDate); //START END UD-1676 Wenjun 24/06/15 : Add Debug Statement
        //START UD-3337 FrancisBenzon 16Dec15 : error message var
        for(String retryError : retryErrorsList)
        {
            configurableErrorSet.add(retryError);
        }
        //END UD-3337 FrancisBenzon 16Dec15 : error message var
        
        try {
            errorMessageToSkip = Error_Messages__c.getValues('Zuora Cancellation Error 1').Message__c;
        } catch (exception e) {
            errorMessageToSkip = '';
        }
        
        
        List<Map<String, Object>> amendMapList = new List<Map<String, Object>>();
        for (string tmp : zuoraSubscriptionId_effectiveDate.keySet()) {
            
            if (tmp != null) {
                
                amendmentRequests = new list<Zuora.zObject>{ generateZuoraAmendmentObject(tmp, zuoraSubscriptionId_effectiveDate.get(tmp)) };
               
                //START UD-3337 12/11/15 RReyes/Fritz: log error on amendment
                try 
                {
                    Zuora.zApi.AmendResult result  = amendApiCall(amendmentRequests);
                    System.debug('=========> Amend Result: '+ result); //START END UD-1676 Wenjun 24/06/15 : Add Debug Statement
                     if (result.success == true) {
                    amendmentIdList.addAll(result.amendmentIds);
                    } else {
                        
                        for (Zuora.zObject o : result.errors) {
                            if((string)o.getValue('Message') != null){
                                errorMessage = 'Subscription ID: ' + tmp + ' Error: '  + (string)o.getValue('Message');
                                if ((string)o.getValue('Message') != errorMessageToSkip) {
                                    isSuccess = false;
                                }
                                logger.log(false, errorMessage);
                                //START UD-3337 FrancisBenzon 16Dec15 : check error message for retry mechanism.
                                for(String retryError : retryErrorsList)
                                {
                                    logger.log(false, (string)o.getValue('Message'));
                                    if((string)o.getValue('Message') == retryError)
                                    {
                                        retryAmendCall = true;
                                        isSuccess = false;                                  
                                        break;
                                    }
                                }
                                //END UD-3337 FrancisBenzon 16Dec15 : check error message for retry mechanism.
                            }                           
                        }
                        //START UD-3337 FrancisBenzon 16Dec15 : retry amendApiCall
                        if(retryAmendCall)
                        {
                            Integer numOfAttempts = 0;
                                                                                                        
                            While(numOfAttempts <= integer.valueOf(numberOfRetries))
                            {
                                Zuora.zApi.AmendResult result2  = amendApiCall(amendmentRequests);
                                if (result2.success == true) {
                                    amendmentIdList.addAll(result2.amendmentIds);
                                    break;
                                }
                                else {                                                                                                  
                                    for(Zuora.zObject o : result2.errors)
                                    {
                                        if((string)o.getValue('Message') != null)
                                        {
                                            if(configurableErrorSet.contains((string)o.getValue('Message')))
                                            {
                                                numOfAttempts++;
                                                break;
                                            }                                           
                                        }                                       
                                    }
                                }
                                
                            }
                        }
                        //END UD-3337 FrancisBenzon 16Dec15 : retry amendApiCall
                    }
                }
                catch(exception e) {
                    ExceptionLogger.log(new list<exception> { e });
                }
                //END UD-3337 12/11/15 RReyes/Fritz: log error on amendment
                for(String r : returnZuoraEffectiveToSubName.keySet()){
                    
                    if(r == tmp){
                        subNameList.add(returnZuoraEffectiveToSubName.get(r));
                    }
                }
                
                if (isSuccess == false) {
                    break;
                }
            }
        }

        // start revert the ammendment if one was failed
        if (isSuccess == false && !amendmentIdList.isEmpty()) {
            ZuoraAmendmentHelper.deleteAmendment(amendmentIdList);
        } else {
           // START : D-2691 4/6/2015 K. Tan Creation of Usage record.
            usageCreationForStopSubscription usageStop = new usageCreationForStopSubscription();
            //START Added By FrancisBenzon 6/8/2015 UD-1044 : throw inputted dates of user for usage creation
            //usageStop.createUsage(zuoraSubscriptionId_effectiveDate);
            //START D-3228 7/10/15 Added By C. Lin - Hotfix by Fritz Support 7/10/15
            if(!stopDateEffectiveDate.isempty())
            {
                usageStop.createUsage(stopDateEffectiveDate);
            }
            else
            {
                usageStop.createUsage(zuoraSubscriptionId_effectiveDate);
            }           
            //END D-3228 7/10/15 Added By C. Lin hotfix Support 7/10/15
            //END Added By FrancisBenzon 6/8/2015 UD-1044 : throw inputted dates of user for usage creation
           // END : D-2691 4/6/2015 K. Tan Creation of Usage record.
            
            list<Zoura_Amendment__c> zouraAmendmentList = new list<Zoura_Amendment__c>();
            
            for (string amendmentId : amendmentIdList) {
                
                Zoura_Amendment__c za = new Zoura_Amendment__c();
                
                if (associatedOrder != null) {
                    za.Order__c = associatedOrder.Id;
                }
                za.Amendment_Id__c = amendmentId;
                zouraAmendmentList.add(za);
            }
            
            if (zouraAmendmentList.size() > 0) {
                
                try {
                    insert zouraAmendmentList;
                } catch (exception e) {
                    ExceptionLogger.log(new list<exception> { e });
                }
                
            }
        }
        // end revert the ammendment if one was failed
        // End D-2660 02Apr15 JohnD refactored code
    
        String pending = 'Pending';
        List<Order_Line_Item__c> oliList = [SELECT Id, Case__r.CreatedDate, Case__c, Case__r.RecordTypeId, Case__r.Status, Name FROM Order_Line_Item__c WHERE Subscription_Name__c!=NULL AND Subscription_Name__c IN :subNameList AND Case__r.RecordTypeId = :stopCase AND Case__r.Status = :pending ORDER BY Case__r.CreatedDate DESC];
        Case caseRec = new Case();
        Id caseId;
        system.debug('>>>>>oliList ' + oliList);
        if(oliList.size()>0){
            caseId = oliList[0].Case__c;
            system.debug('>>>>>caseId ' + caseId);
            if(caseId!=NULL){
                caseRec = [SELECT Status FROM Case WHERE Id = :caseId];
                system.debug('-------------------sample result' + sample);
                system.debug('>>>>>isSuccess ' + isSuccess);
                if(isSuccess){
                        caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING; // Start/End MD-2660 02Apr15 JohnD changed from case.Status 
                }
                else{
                    caseRec.Status = 'Failed';
                }
                update caseRec;
                System.debug('CaseId: ' + caseRec);
            }
                        
        }
        System.debug('oliList *********' + oliList);
        logger.save(); //START UD-3337 12/11/15 RReyes - added logging for processCancellation method
    }      
    //END D-2330 Added By K.Campang

    /*
    *   @description : This method will invoke a webservice call to zuora to cancel the subscription
    *           using the zuora api installed manage class
    */
    private static Zuora.zApi.AmendResult amendApiCall(list<Zuora.zObject> amendmentList) {
        Zuora.zApi zuorApi = new Zuora.zApi();
        //START D-3268 7/21/2015 Modified By C.I.Salas - Test Coverage
        if (!Test.isRunningTest()) {
            zuorApi.zlogin();
        }
        //END D-3268 7/21/2015 Modified By C.I.Salas - Test Coverage
        list<Zuora.zApi.AmendRequest> amendmentRequestList = new list<Zuora.zApi.AmendRequest>();
        Zuora.zApi.AmendResult result = new Zuora.zApi.AmendResult();
        
        for (Zuora.zObject tmp : amendmentList) {

            // Amend Request
            Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
            Zuora.zObject[] amendments = new List < Zuora.zObject >{ tmp };
            amendRequest.amendments = amendments;
            
            // Amend Options
            Zuora.zApi.AmendOptions amendmentOption = new Zuora.zApi.AmendOptions();
            amendmentOption.GenerateInvoice = false;
            amendmentOption.ProcessPayments = false;
            amendRequest.amendOptions = amendmentOption;
    
            // Amend Preview
            Zuora.zApi.PreviewOptions previewOptions = new Zuora.zApi.PreviewOptions();
            previewOptions.EnablePreviewMode = false;
            amendRequest.previewOptions = previewOptions;
            
            amendmentRequestList.add(amendRequest);
            result = zuorApi.zamend(amendmentRequestList);
            system.debug(':::RESULT' + result);
        }
        
        return result;
    }

    /**
    * Create basic infomation for amendment.
    */
    private static Zuora.zObject generateZuoraAmendmentObject(string zuoraId, date stopDate) {
        system.debug(':::ZUORAID' + zuoraId);
        String zuoraDate =  Zuora.Zutil.getZuoraDate(stopDate); //START END UD-2738 Wenjun 21/Sep/15 : Code Optimization  
        Zuora.zObject amendment = new Zuora.zObject(globalvariableclass.AMENDMENT);
        amendment.setValue(globalvariableclass.CONTRACT_EFFECTIVEDATE, zuoraDate);
        amendment.setValue(globalvariableclass.DESCRIPTION, globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
        amendment.setValue(globalvariableclass.EFFECTIVE_DATE, zuoraDate);
        amendment.setValue(globalvariableclass.NAME, CANCELLATION_AMENDMENT_NAME);
        amendment.setValue(globalvariableclass.STATUS, globalvariableclass.COMPLETED);
        amendment.setValue(globalvariableclass.SUBSCRIPTION_ID, zuoraId);
        amendment.setValue(globalvariableclass.TYPE, globalvariableclass.CANCELATION);
        system.debug(':::AMEND' + amendment);
        return amendment;
    } 
    
    //START D-2330 Added By K.Campang - Cancel selected Subscriptions
    /**
    * Create basic infomation for amendment.
    /*private static Map<String, Object> generateZuoraAmendmentObjectMap(string zuoraId, date stopDate) {
        String zuoraDate =  Zuora.Zutil.getZuoraDate(stopDate);  //START END UD-2738 Wenjun 21/Sep/15 : Code Optimization  
        Map<String, Object> amendMap = new Map<String, Object>();
        amendMap.put(globalvariableclass.CONTRACT_EFFECTIVEDATE, zuoraDate);
        amendMap.put(globalvariableclass.DESCRIPTION, globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
        amendMap.put(globalvariableclass.EFFECTIVE_DATE, zuoraDate);
        amendMap.put(globalvariableclass.NAME, CANCELLATION_AMENDMENT_NAME);
        amendMap.put(globalvariableclass.STATUS, globalvariableclass.COMPLETED);
        amendMap.put(globalvariableclass.SUBSCRIPTION_ID, zuoraId);
        amendMap.put(globalvariableclass.TYPE, globalvariableclass.CANCELATION);
        return amendMap;
    }
    //END D-2330 Added By K.Campang
    
    /*Convert Date to Format in Zoura
    */
    //START UD-2738 Wenjun 21/Sep/15 : Code Optimization - using Zuora Util instead
    /*
    private static String formatDateToZuora(date formatDate){

        dateTime stp = (datetime)formatDate;
        //START 15/01/2015 Wenjun : Fix Bug - Wrong Date Format causes API Exception
        string mydate = string.valueof(stp.format('YYYY-MM-dd'));
        //END 15/01/2015 Wenjun
        string d = mydate+'T00:00:00';
        return d;
    }
    */
    //END UD-2738 Wenjun 21/Sep/15
}