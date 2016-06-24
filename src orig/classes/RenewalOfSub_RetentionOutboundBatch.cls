/**
 * Class Name: RenewalOfSub_RetentionOutboundBatch
 * @author: FrancisMartinBenzon
 * Date: 8/21/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Batch Process to create Retention Cases based on subscriptions nearing end date to be followed up by Retention Queue.
 * History: D-2770 KRITHIKA DHARMARAJAN 4/17/2015
 * History: D-3667 LISEN 10/6/2015 - Enable on demand batch call
 */

//START D-3667 LISEN 10/6/2015 - Enable on demand batch call for recovery
global class RenewalOfSub_RetentionOutboundBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
//END D-3667 LISEN 10/6/2015 - Enable on demand batch call for recovery

////START-END KRITHIKA DHARMARAJAN 4/17/2015 D-2770
    //START D-3667 LISEN 10/6/2015 - Enable on demand batch call for recovery
    Date referenceDate = Date.Today();
    Set<Id> subscriptionIds = null;
    
    Boolean isApexJobSuccessful = true;
    //START PD-0248 31May2016 Added By C. Lin
    final Static String CHANGE_OF_SUBSCRIPTION = GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION;
    final Static String STOP_SUBSCRIPTION = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
    //END PD-0248 31May2016 Added By C. Lin
    
    // Default Constructor 
    global RenewalOfSub_RetentionOutboundBatch(){
    }
    
    // Constructor for adhoc batch run using specific date
    global RenewalOfSub_RetentionOutboundBatch(Date batchRunDate){
        this.referenceDate = batchRunDate;
    }
    
    // Constructor for adhoc batch run using specific subscriptionIds
    global RenewalOfSub_RetentionOutboundBatch(Set<Id> subscriptionIds){
        this.subscriptionIds = subscriptionIds;
    }
    //END D-3667 LISEN 10/6/2015 - Enable on demand batch call
    
    global Database.QueryLocator start(Database.BatchableContext BC){       
        Id recordTypeAcctDirect = ConstantsSLB.getKeyId('Account_Direct Individual');
        // START: UD-1094  5/4/2015 K. Tan - Updated Custom Settings 
        Integer configurableNumberOfDays = Integer.valueOf(ConstantsSLB.getKeyId('RetentionOutboundSixWeeks'));
        // END: UD-1094 5/4/2015 K. Tan - Updated Custom Settings       
        Date sixWeeksBefore = referenceDate.addDays(configurableNumberOfDays);
        //START D-2497 &&   Added by J. Sarion 04/27/2015 - Only Publication Subscriptions are eligible for Retention Outbound
        //START PD-0248 31May2016 Added By C. Lin
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        Set<Id> subIdSet = new Set<Id>();
        Set<Id> subIdWithStopCOSSet = new Set<Id>();
        //END PD-0248 31May2016 Added By C. Lin
        
        //START D-3667 LISEN 10/6/2015 - Enable on demand batch call
        String query = '';
        if(subscriptionIds == null){
        // run by using list of subscriptionIds
        //START PD-0248 31May2016 Added By C. Lin
        subList = [SELECT Id, Name FROM Zuora__Subscription__c WHERE Zuora__Account__r.RecordTypeId = :recordTypeAcctDirect AND Zuora__SubscriptionEndDate__c = :sixWeeksBefore AND RenewalRequestDateNull__c = true AND Zuora__AutoRenew__c = FALSE AND Subscription_Type_1__c = 'Publication' AND Grace_Period_Subscription__c = null];
        
        if(!subList.isEmpty()){
            for(Zuora__Subscription__c sub : subList){
                subIdSet.add(sub.Id);
            }
        }
        
        List<Order_Line_Item__c> lstOliStopCOS = [SELECT Id, Order__c, Subscription__c, Order__r.Subscription__c, Case__r.Status FROM Order_Line_Item__c WHERE ((Subscription__c IN :subIdSet AND Case__r.RecordType.Name = :STOP_SUBSCRIPTION) OR (Order__r.Subscription__c IN :subIdSet AND Case__r.RecordType.Name = :CHANGE_OF_SUBSCRIPTION)) AND Case__r.Status != 'Void'];
        
        if(!lstOliStopCOS.isEmpty()){
            for(Order_Line_Item__c oli : lstOliStopCOS){
                if(oli.Subscription__c != null){
                    subIdWithStopCOSSet.add(oli.Subscription__c);
                }
                
                if(oli.Order__r.Subscription__c != null){
                    subIdWithStopCOSSet.add(oli.Order__r.Subscription__c);
                }
            }
        }
        //END PD-0248 31May2016 Added By C. Lin
            // START: UD-1094  5/4/2015 K. Tan - Add Main Package field
            query = 'SELECT Id, Name,  Zuora__Account__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Renewal_Request_Date__c, '+ 
                            'Order_Number__c, Zuora__AutoRenew__c, Main_Package_1__r.Name, Main_Package__c, Subscriber_Contact__c, Recipient_Contact__c, Full_Address__c, Order_Number_1__c FROM Zuora__Subscription__c '+
                            'WHERE Zuora__Account__r.RecordTypeId = :recordTypeAcctDirect AND Zuora__SubscriptionEndDate__c = :sixWeeksBefore '+ 
                            'AND RenewalRequestDateNull__c = true AND Zuora__AutoRenew__c = FALSE AND Subscription_Type_1__c = \'Publication\' AND Grace_Period_Subscription__c = null AND Id NOT IN :subIdWithStopCOSSet'; //START END PD-0248 31May2016 Added By C. Lin
            // END: UD-1094 5/4/2015 K. Tan - Add Main Package field
        }else{
        // run by using referenceDate
            query = 'SELECT Id, Name,  Zuora__Account__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Renewal_Request_Date__c, '+ 
                            'Order_Number__c, Zuora__AutoRenew__c, Main_Package_1__r.Name, Main_Package__c, Subscriber_Contact__c, Recipient_Contact__c, Full_Address__c, Order_Number_1__c FROM Zuora__Subscription__c '+
                            'WHERE Zuora__Account__r.RecordTypeId = :recordTypeAcctDirect AND Id IN :subscriptionIds '+ 
                            'AND RenewalRequestDateNull__c = true AND Zuora__AutoRenew__c = FALSE AND Subscription_Type_1__c = \'Publication\' AND Grace_Period_Subscription__c = null';
        }
        //END D-3667 LISEN 10/6/2015 - Enable on demand batch call
        //END D-2497 &&   Added by J. Sarion 04/27/2015 - Only Publication Subscriptions are eligible for Retention Outbound
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> scope){  
        //START D-3667 LISEN 10/6/2015 - Enable on demand batch call for recovery
        Logger logger = new Logger(RenewalOfSub_RetentionOutboundBatch.class.getName(), 'SP042', BC.getJobID());
        
        Savepoint sp = Database.setSavepoint();
        try{
            List<Case> casesToBeCreated = new List<Case>();
            Id recordTypeRetention = ConstantsSLB.getKeyId('Case_Retention');
            Id ownerRetentionQueue = ConstantsSLB.getKeyId('Retention_Outbound_Queue');
            map<id, id> recipientId_addressId = new map<id, id>();
            set<id> recipientIds = new set<id>();
            
            for (Zuora__Subscription__c z: scope) {
                if (z.Recipient_Contact__c != null) {
                    recipientIds.add(z.Recipient_Contact__c);
                }
            }
            //Start Code Review 2/19/2015 James
            if (recipientIds.size() > 0){
                for (Contact c : [select Id, Address__c from Contact where Id in :recipientIds]) {
                    recipientId_addressId.put(c.Id, c.Address__c);
                }
            }
            //End Code Review 2/19/2015 James
            
            for(Zuora__Subscription__c zSub : scope) {
                Case cases = new Case();
                cases.RecordTypeId = recordTypeRetention;
                cases.OwnerId = ownerRetentionQueue;
                cases.Origin = 'Scheduled Process';
                cases.Status = 'New';
                cases.Category__c = 'Subscription Request';
                cases.Subject = 'Renewal';
                cases.AccountId = zSub.Zuora__Account__c;
                cases.Order_Number__c = zSub.Order_Number_1__c;
                cases.Subscriber__c = zSub.Subscriber_Contact__c;
                cases.Subscription_Name__c = zSub.Id;
                cases.Recipient__c = zSub.Recipient_Contact__c;
                    // START: UD-1094 5/4/2015 K. Tan - Add Main Package field
                    if(zSub.Main_Package__c != null){   
                        cases.Main_Package__c = zSub.Main_Package_1__r.Name ;   
                    }
                    // END: UD-1094 5/4/2015 K. Tan - Add Main Package field
                //cases.Subscription_Start_Date__c = zSub.Zuora__SubscriptionStartDate__c;
                //cases.Subscription_End_Date__c = zSub.Zuora__SubscriptionEndDate__c;           
                cases.Recipient_Address__c = recipientId_addressId.get(zSub.Recipient_Contact__c);
                casesToBeCreated.add(cases);
                system.debug('>>>>THIS CASES' + casesToBeCreated);
            }
            insert casesToBeCreated;
        }catch(Exception e){
            Database.rollback(sp);
            logger.logBatchFailure(e, scope);
            logger.save();
            
            isApexJobSuccessful = false;
        }
        //END D-3667 LISEN 10/6/2015 - Enable on demand batch call for recovery
    }
    
    global void finish(Database.BatchableContext BC){
        //START D-3667 LISEN 10/6/2015 - Enable on demand batch call for recovery
        if(!isApexJobSuccessful){
            BatchJobHelper.updateJobStatus(BC.getJobId(), false); //START-END KRITHIKA DHARMARAJAN 4/17/2015 D-2770
        }else{
            BatchJobHelper.updateJobStatus(BC.getJobId(), true);
        }
        //END D-3667 LISEN 10/6/2015 - Enable on demand batch call for recovery
    }
}