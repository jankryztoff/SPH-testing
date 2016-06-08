/**
 * Class Name: SP_MidMonthNonCreditProrationBatch
 * @author: Karl Tan
 * Date: 01/09/2015
 * Requirement/Project Name: CRSM Project
 * @description Batch Apex Class to Create Usage Records for SP_MidMonthNonCreditProrationBatch
 * 
 */
global class SP_MidMonthNonCreditProrationBatch implements Database.Batchable<sObject> {
    global Batch_Configuration_Settings__c batchSettings; //configuration data for SP_MidMonthStartProrationBatch
    
    
   /* @description Called at the beginning of the apex job to collect the objects
    * to be passed to the execute method
    * @param bc- predefined parameter 
    * @return list of objects from Subscription Object
    */     
   
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //batchSettings = Batch_Configuration_Settings__c.getInstance('SP_MidMonthNonCreditProrationBatch');
        String query = 'SELECT Id, Case__c, Case__r.RecordType.Name,  Complaint_Copies__c, Complaint_From__c, Complaint_To__c, Subscription__c FROM Case_Subscription__c WHERE Subscription__r.Billing_Type__c = \'Recurring Prepaid\' AND Case__c.RecordType.Name = \'Complaint - Newspaper\' AND CreatedDate = THIS_MONTH';
        return Database.getQueryLocator(query);
    }
    
    /* @description Executes the business logic and creates Usage object
     * 
     * @param bc- predefined parameter 
     * @param allScopes - a list of sObjects from the initial database query
     * @return void
     */    
    
    global void execute(Database.BatchableContext BC, List<Case_Subscription__c> caseSubList) {
    
        List<Usage__c> usageList = new List<Usage__c>();       
        Set<Id> subIds = new Set<Id>();
        
        for(Case_Subscription__c caseSub : caseSubList) {
            if(caseSub.Subscription__c != NULL){
                subIds.add(caseSub.Subscription__c);    
            }
        }
        List<Zuora__Subscription__c> subList = [SELECT Id, Name, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Zuora__SubscriptionStartDate__c, (SELECT Zuora__Quantity__c, Zuora__RatePlanName__c, Name, Id, Zuora__ProductSKU__c, Zuora__ChargeNumber__c, Zuora__UOM__c, Zuora__Type__c FROM Zuora__Subscription_Product_Charges__r) FROM Zuora__Subscription__c WHERE Id IN : subIds]; 
        
        Set<String> ratePlanCharges = new Set<String>();
        List<Zuora__SubscriptionProductCharge__c> subProdChaList = new List<Zuora__SubscriptionProductCharge__c> ();        
        Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapSubsIdToSubProdCharges = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();
        Set<String> pubCodes = new Set<String>();
        Map<Id, zqu__ProductRatePlanCharge__c> mapSubProdChargeIdToProdRatePlanCharge = new Map<Id, zqu__ProductRatePlanCharge__c>();
        Map<String, Publication__c> mapPubCodeToPublication = new Map<String, Publication__c>();
        Map<String, Set<Date>> mapPubCodeToNonPubDates = new Map<String, Set<Date>>();
        
        SP_ProrationUtility.populateSubscriptionToSpC(mapSubsIdToSubProdCharges, subList, ratePlanCharges, subProdChaList);
        List<zqu__ProductRatePlanCharge__c> prodRatePlanCharges = [SELECT Id, Name, PublicationCode__c, zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c, zqu__ProductRatePlan__r.Name, zqu__ProductRatePlan__r.SubscriptionFrequency__c  FROM zqu__ProductRatePlanCharge__c WHERE Name IN : ratePlanCharges]; 

        SP_ProrationUtility.populateSpCToRatePlanCharge(mapSubProdChargeIdToProdRatePlanCharge, prodRatePlanCharges, pubCodes, subProdChaList);
        List<Publication__c> pubList = [SELECT id, Publication_Code__c, Published_Days__c, Sunday_Publication__c, (SELECT Id, Cover_Price__c, Day_of_Week__c, Publication_Code__c FROM Publication_Prices__r) FROM Publication__c WHERE Publication_Code__c IN : pubCodes];

        
        SP_ProrationUtility.populatePubCodeToPublication(mapPubCodeToPublication, pubList);

        List<Non_Publication_Day__c> nonPubDayList = [SELECT Id, Publication__c, Publication_Code__c, Non_Publication_Date__c FROM Non_Publication_Day__c WHERE Publication_Code__c IN : pubCodes];
                   
        SP_ProrationUtility.populatePubCodeToNonPubDates(mapPubCodeToNonPubDates, nonPubDayList);
        
        for(Case_Subscription__c cSub : caseSubList) {
            List<Zuora__SubscriptionProductCharge__c> spcList = new List<Zuora__SubscriptionProductCharge__c>();
            /*
            Check if line item is linked to Subscriptions       
            */          
            if(mapSubsIdToSubProdCharges.containsKey(cSub.Subscription__c)) {
                spcList = mapSubsIdToSubProdCharges.get(cSub.Subscription__c);
            }
            /*
            Map<Day of Week under Subscription Product and Charges>     
            */
            //START: New PC Implementation 12/12/2014 Modified by Karl Tan - modified code according new PC configuration           
            Map<String, Zuora__SubscriptionProductCharge__c> mapDOWToSubProdCharges = new Map<String, Zuora__SubscriptionProductCharge__c>();
            for(Zuora__SubscriptionProductCharge__c spc : spcList ) {
                if(spc.Zuora__UOM__c == ConstantsSLB.getUOM('Copy Weekday')) {
                    mapDOWToSubProdCharges.put('Weekday', spc);
                    
                }
                else if(spc.Zuora__UOM__c == ConstantsSLB.getUOM('Copy Sat')) {
                    mapDOWToSubProdCharges.put('Saturday', spc);

                }
                else if(spc.Zuora__UOM__c == ConstantsSLB.getUOM('Copy Sun')) {
                    mapDOWToSubProdCharges.put('Sunday', spc);
                }               
            }
            //END: New PC Implementation 12/12/2014 Modified by Karl Tan - modified code according new PC configuration
            for(Zuora__SubscriptionProductCharge__c spc : spcList) {
                if(spc.Zuora__Type__c != 'Usage') {
                    /*
                    Check if line item is linked to Subscriptions Product and Charges       
                    */
                    if(mapSubProdChargeIdToProdRatePlanCharge.containsKey(spc.Id)) {
                        zqu__ProductRatePlanCharge__c pRpCharge = mapSubProdChargeIdToProdRatePlanCharge.get(spc.Id); 
                        /*
                        Check if line item is linked to Product Rate Plan Charge Publication Code       
                        */
                        /*
                        Map <Publication Code to Map of Day of Week to counter> 
                        */                      
                        Map<String, Map<String, Integer>> mapPubCodeToDoW = new Map<String, Map<String, Integer>>();            
                        
                        //START: New PC Implementation 12/12/2014 Modified by Karl Tan - modified code according new PC configuration           
                        Map<String, Map<String, Integer>> mapPubCodeToDoWCopy = new Map<String, Map<String, Integer>>();
                        //END: New PC Implementation 12/12/2014 Modified by Karl Tan - modified code according new PC configuration 
               
                        if(mapPubCodeToPublication.containsKey(pRpCharge.PublicationCode__c)) { 
                            system.debug(pRpCharge.PublicationCode__c);

                            Publication__c pub = mapPubCodeToPublication.get(pRpCharge.PublicationCode__c);
                            String subfreq = RefundComputation.convertSubFreq(mapPubCodeToPublication.get(pRpCharge.PublicationCode__c), new zqu__ProductRatePlan__c(SubscriptionFrequency__c = pRpCharge.zqu__ProductRatePlan__r.SubscriptionFrequency__c));
                            if (mapPubCodeToDoW.get(pRpCharge.PublicationCode__c) == null) {
                                mapPubCodeToDoW.put(pRpCharge.PublicationCode__c, new Map<String, Integer>());
                            }
                            /*                            
                            Logic that converts Subscription Frequency to Published Days                               
                            */              
                            /*if(pub.Publication_Code__c == 'ST') {
                                system.assertEquals(subfreq, '0');
                            
                            }*/
                            
                            
                            if(pub.Published_Days__c.substring(0,1)== 'Y' && subfreq.substring(0,1)=='Y') {
                                mapPubCodeToDoW.get(pub.Publication_Code__c).put('Monday', 0 ); 
                                
                            }
                            if(pub.Published_Days__c.substring(1,2)== 'Y' && subfreq.substring(1,2)=='Y') {
                                mapPubCodeToDoW.get(pub.Publication_Code__c).put('Tuesday', 0 );    
                            }
                            if(pub.Published_Days__c.substring(2,3)== 'Y' && subfreq.substring(2,3)=='Y') {
                                mapPubCodeToDoW.get(pub.Publication_Code__c).put('Wednesday', 0 );  
                            }
                            if(pub.Published_Days__c.substring(3,4)== 'Y' && subfreq.substring(3,4)=='Y') {
                                mapPubCodeToDoW.get(pub.Publication_Code__c).put('Thursday', 0 );   
                            }
                            if(pub.Published_Days__c.substring(4,5)== 'Y' && subfreq.substring(4,5)=='Y') {
                                mapPubCodeToDoW.get(pub.Publication_Code__c).put('Friday', 0 ); 
                            }                   
                            if(pub.Published_Days__c.substring(5,6)== 'Y' && subfreq.substring(5,6)=='Y') {
                                mapPubCodeToDoW.get(pub.Publication_Code__c).put('Saturday', 0 );   
                            }
                            if(pub.Published_Days__c.substring(6,7)== 'Y' && subfreq.substring(6,7)=='Y') {
                                mapPubCodeToDoW.get(pub.Publication_Code__c).put('Sunday', 0 ); 
                            }
                            /*
                            Declaration of variables for start date, end date, non- pub dates and day of week     
                            */
                            // Start: D-0462 / 1/8/2015/ K. Tan / Update Dates

                            
                            Date subStartDate = cSub.Complaint_From__c;
                            Date compEndDate = cSub.Complaint_To__c;
                            // End: D-0462 / 1/8/2015/ K. Tan / Update Dates

                            Set<Date> nonPubDates = new Set<Date>();
                            String dayOfWeek;
                            /*
                            Check if line item is linked to Publication Code       
                            */                            
                            if(mapPubCodeToNonPubDates.containsKey(pub.Publication_Code__c)) {
                                nonPubdates = mapPubCodeToNonPubDates.get(pub.Publication_Code__c);
                            }
                            Integer x = 0;
                            String strBuilder = '';
                            for(subStartDate = subStartDate; subStartDate <= compEndDate; subStartDate = subStartDate.addDays(1)) 
                            {
                                x+=1;
                                /*
                                Check non pub date if within the subscription start date       
                                */                             
                                if(!nonPubDates.contains(subStartDate)){
                                    dayOfWeek = ((DateTime)subStartDate).format('EEEE');
                                    strBuilder += dayOfWeek + '|';
                                    /*
                                    Check line item if linked to day of week       
                                    */
                                    
                                    if(mapPubCodeToDoW.get(pub.Publication_Code__c).containsKey(dayOfWeek)) {
                                        //START: New PC Implementation 12/12/2014 Modified by Karl Tan - modified code according new PC configuration           
                                                        
                                        if (mapPubCodeToDoWCopy.get(pub.Publication_Code__c) == null) {
                                            mapPubCodeToDoWCopy.put(pub.Publication_Code__c, new Map<String, Integer>());
                                        }
                                        
                                        // Start: D- 0462 / 1-8-2015 / K. Tan / DOW Modification Counter

                                        if(dayOfWeek == 'Monday' || dayOfWeek == 'Tuesday' || dayOfWeek == 'Wednesday' || dayOfWeek == 'Thursday' || dayOfWeek == 'Friday'){
                                            Integer count;
                                            if(mapPubCodeToDoWCopy.get(pub.Publication_Code__c).containsKey('Weekday')) {
                                                count = mapPubCodeToDoWCopy.get(pub.Publication_Code__c).get('Weekday') + Integer.valueOf(spc.Zuora__Quantity__c);
                                            }
                                            else {
                                                count = Integer.valueOf(spc.Zuora__Quantity__c);
                                            }
                                            system.debug(count);
                                            system.debug(mapPubCodeToDoWCopy.get(pub.Publication_Code__c));
                                            mapPubCodeToDoWCopy.get(pub.Publication_Code__c).put('Weekday', count);
                                            system.debug(count);
    
                                        }
                                        if(dayOfWeek == 'Saturday'){
                                            Integer count;
                                            if(mapPubCodeToDoWCopy.get(pub.Publication_Code__c).containsKey(dayOfWeek)) {
                                                count = mapPubCodeToDoWCopy.get(pub.Publication_Code__c).get(dayOfWeek) + Integer.valueOf(spc.Zuora__Quantity__c);
                                            }
                                            else {
                                                count = Integer.valueOf(spc.Zuora__Quantity__c);
                                            }
                                            mapPubCodeToDoWCopy.get(pub.Publication_Code__c).put('Saturday', count);
                                        }
                                        if(dayOfWeek == 'Sunday'){
                                            Integer count;
                                            if (mapPubCodeToDoWCopy.get(pub.Publication_Code__c).containsKey(dayOfWeek)) {
                                                count = mapPubCodeToDoWCopy.get(pub.Publication_Code__c).get(dayOfWeek) + Integer.valueOf(spc.Zuora__Quantity__c);
                                            }
                                            else {
                                                count = Integer.valueOf(spc.Zuora__Quantity__c);
                                            }
                                            mapPubCodeToDoWCopy.get(pub.Publication_Code__c).put('Sunday', count);
                                        }
                                        // END: D- 0462 / 1-8-2015 / K. Tan / DOW Modification Counter
 
                                        //END: New PC Implementation 12/12/2014 Modified by Karl Tan - modified code according new PC configuration         

                                    }
                                }
                            }
                        
                        } 
                        //START: New PC Implementation 12/12/2014 Modified by Karl Tan - modified code according new PC configuration           
                        for(String pubCode : mapPubCodeToDoWCopy.keySet()) {
                            for(String dayOfWeek : mapPubCodeToDoWCopy.get(pubCode).keySet()){
                                if(mapPubCodeToDoWCopy.get(pubCode).get(dayOfWeek) != 0){
                                    Zuora__SubscriptionProductCharge__c Zspc = new Zuora__SubscriptionProductCharge__c();
                                    /*
                                    Check if line item is linked to day of week       
                                    */                                     
                                    if(mapDOWToSubProdCharges.containsKey(dayOfWeek)) {
                                        Zspc = mapDOWToSubProdCharges.get(dayOfWeek);
                                    
                                        Usage__c usageRec = new Usage__c();
                                        usageRec.Quantity__c = (mapPubCodeToDoWCopy.get(pubCode).get(dayOfWeek));
                                        usageRec.UOM__c = Zspc.Zuora__UOM__c;
                                        usageRec.Subscription_Id__c = String.valueOf(cSub.Subscription__r.Name);
                                        usageRec.Account_Id__c = cSub.Subscription__r.Zuora__CustomerAccount__r.Zuora__AccountNumber__c;
                                        usageRec.Start_Date__c = cSub.Subscription__r.Zuora__SubscriptionStartDate__c;
                                        usageRec.Rate_Plan_Charge_Id__c = Zspc.Zuora__ChargeNumber__c;
                                        usageRec.Start_Date__c = cSub.Subscription__r.Zuora__SubscriptionStartDate__c;
                                        // Start: D- 0462 / 12-8-2014 / K. Tan / Populate Status on Usage
                                        usageRec.Status__c = 'New'; 
                                       // End: D- 0462 / 12-8-2014 / K. Tan / Populate Status on Usage;
                                        usageList.add(usageRec);    
                                    }                           
                                }
                            }
                        } 
                        //END: New PC Implementation 12/12/2014 Modified by Karl Tan - modified code according new PC configuration         
    
                    }
                }   
            }   
        }
        try {                
            insert usageList;
        }
        catch(Exception e) {
        //Generic exception handling code here
        }
    } 
 
    global void finish(Database.BatchableContext BC) {

    }
}