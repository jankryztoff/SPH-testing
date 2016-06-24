/**
 * Class Name: SP_ProrationUtility
 * @author: Karl Tan
 * Date: 
 * Requirement/Project Name: CRSM Project
 * @description Apex Utility Class to utilized by other class for Real Time creation of Usage Record 
 * 
 * History: D-1757 14/01/2015 Wenjun : Postage Charge
 * History: D-1862 26/01/2015 Marvin : POP for Print platform
 */
public class SP_ProrationUtility {
    
    //START D-1615, D-1618, D-1619 30/01/2015 Jeffrey Teves : Initialize a Usage Record if conditions match criteria. Used for Proration Batch.
    final static String RECURRING_PREPAID = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
    final static String RECURRING_POSTPAID = GlobalVariableClass.RECURRING_POSTPAID;
    final static String STATUS_ACTIVE = GlobalVariableClass.STATUS_ACTIVE;
    final static String STATUS_EXPIRED = GlobalVariableClass.STATUS_EXPIRED;
    final static String MONDAY_STRING = GlobalVariableClass.MONDAY_STRING;
    final static String TUESDAY_STRING = GlobalVariableClass.TUESDAY_STRING;
    final static String WEDNESDAY_STRING = GlobalVariableClass.WEDNESDAY_STRING;
    final static String THURSDAY_STRING = GlobalVariableClass.THURSDAY_STRING;
    final static String FRIDAY_STRING = GlobalVariableClass.FRIDAY_STRING;
    final static String SATURDAY_STRING = GlobalVariableClass.SATURDAY_STRING;
    final static String SUNDAY_STRING = GlobalVariableClass.SUNDAY_STRING;
    final static String WEEKDAY_UOM_STRING = GlobalVariableClass.WEEKDAY_UOM_STRING;
    final static String SATURDAY_UOM_STRING = GlobalVariableClass.SATURDAY_UOM_STRING;
    final static String SUNDAY_UOM_STRING = GlobalVariableClass.SUNDAY_UOM_STRING;
    //END D-1615, D-1618, D-1619 30/01/2015 Jeffrey Teves

    public static List<Usage__c> getNonDeliverCredit (Set<Id> subIds, Date startDate, Date endDate) {   
        List<Usage__c> usageList = new List<Usage__c>();   

        //START D-1757 14/01/2015 Wenjun : Retrieve Billing Type, Delivered By, Subscription End Date
        List<Zuora__Subscription__c> subList = [SELECT Id, Name, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Zuora__SubscriptionStartDate__c,
                                                Billing_Type__c, Delivered_By_1__c,Zuora__SubscriptionEndDate__c,
                                                (SELECT Zuora__Quantity__c, Zuora__RatePlanName__c, Name, Id, Zuora__ProductSKU__c, Zuora__ChargeNumber__c, Zuora__UOM__c, Zuora__Type__c 
                                                 FROM Zuora__Subscription_Product_Charges__r) x 
                                                FROM Zuora__Subscription__c WHERE Id IN : subIds];
        //END D-1757 14/01/2015 Wenjun
        /*
        Map< Subscription Ids to Subscriptions>     
        */              
        
        Set<String> ratePlanCharges = new Set<String>();
        List<Zuora__SubscriptionProductCharge__c> subProdChaList = new List<Zuora__SubscriptionProductCharge__c> ();
        /*
        Map<Subscription Ids under Subscription Product and Charges>    
        */          
        Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapSubsIdToSubProdCharges = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();
        
        //START 15/01/15 Wenjun : Fix Bug - values never get populated as it is local varible
        //populateSubscriptionToSpC(mapSubsIdToSubProdCharges, subList, ratePlanCharges, subProdChaList);
         for(Zuora__Subscription__c zSub : subList ) {
            try{
                if(zSub.Zuora__Subscription_Product_Charges__r.size() > 0) {
                    mapSubsIdToSubProdCharges.put(zSub.id, zSub.Zuora__Subscription_Product_Charges__r);
                    subProdChaList.addAll(zSub.Zuora__Subscription_Product_Charges__r);
                }
            
                for(Zuora__SubscriptionProductCharge__c spc : zSub.Zuora__Subscription_Product_Charges__r ) {               
                    ratePlanCharges.add(spc.Name); 
                }
            }           
            catch (Exception e){            
                System.debug(LoggingLevel.ERROR, 'Exception when processing Zuora__Subscription_Product_Charges__r');
            }
        }
        //END 15/01/15 Wenjun
        
        //START D-1620 1/27/15 J.Sarion : Update WHERE clause to Name
        Set<String> pubCodes = new Set<String>();
        List<zqu__ProductRatePlanCharge__c> prodRatePlanCharges = [SELECT Id, Name, PublicationCode__c, zqu__ProductRatePlan__r.Name, zqu__ProductRatePlan__r.SubscriptionFrequency__c, zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c FROM zqu__ProductRatePlanCharge__c WHERE Name IN : ratePlanCharges];
        //END D-1620 1/27/15 J.Sarion
        
        /*
        Map< Subscription Product and Charges Ids under Product Rate Plan and Charges>      
        */          
        Map<Id, zqu__ProductRatePlanCharge__c> mapSubProdChargeIdToProdRatePlanCharge = new Map<Id, zqu__ProductRatePlanCharge__c>();
        
        //START 15/01/15 Wenjun : Fix Bug - values never get populated as it is local varible
        //populateSpCToRatePlanCharge(mapSubProdChargeIdToProdRatePlanCharge, prodRatePlanCharges, pubCodes, subProdChaList);
        for(zqu__ProductRatePlanCharge__c zPRPCharge : prodRatePlanCharges) {
            for(Zuora__SubscriptionProductCharge__c spc : subProdChaList) {
                /*      
                Check if Subscription Product and Charges Name is equal to Product Rate Plan Charge Name
                and Subscription Product and Charges Product SKU is equal to Product SKU
                */  
                if(spc.Name == zPRPCharge.Name && spc.Zuora__ProductSKU__c == zPRPCharge.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c) {
                    mapSubProdChargeIdToProdRatePlanCharge.put(spc.id, zPRPCharge); 
                }   
            }
            pubCodes.add(zPRPCharge.PublicationCode__c);
        } 
        //END 15/01/15 Wenjun
        
        //START D-1757 15/01/15 Wenjun : Retrieve Publication_Type__c, Frequency_Code__c, Publication_Next_Start_Date__c 
        List<Publication__c> pubList = [SELECT id, Publication_Code__c, Published_Days__c, Sunday_Publication__c, 
                                        Publication_Type__c, Frequency_Code__c, Publication_Next_Start_Date__c,  
                                        (SELECT Id, Cover_Price__c, Day_of_Week__c, Publication_Code__c FROM Publication_Prices__r) 
                                        FROM Publication__c WHERE Publication_Code__c IN : pubCodes];
        //END D-1757 15/01/15 Wenjun
        /*
        Map<Publication Code under Publication>
        */      
        Map<String, Publication__c> mapPubCodeToPublication = new Map<String, Publication__c>();
        
        //START 15/01/15 Wenjun : Fix Bug - values never get populated as it is local varible
        //populatePubCodeToPublication(mapPubCodeToPublication, pubList);
        for(Publication__c pub : pubList) {
            if(pub.Publication_Code__c != null) 
                mapPubCodeToPublication.put(pub.Publication_Code__c, pub);
        }
        //END 15/01/15 Wenjun
        
        /*
        Map<Publication Code under Set of Non Publication Dates>        
        */          
        Map<String, Set<Date>> mapPubCodeToNonPubDates = new Map<String, Set<Date>>();
        List<Non_Publication_Day__c> nonPubDayList = [SELECT Id, Publication__c, Publication_Code__c, Non_Publication_Date__c FROM Non_Publication_Day__c WHERE Publication_Code__c IN : pubCodes];
        
        //START 15/01/15 Wenjun : Fix Bug - values never get populated as it is local varible
        for(Non_Publication_Day__c nonPubDay : nonPubDayList) {
            /*
            Check if line item is linked to Publication Day then add Non Publication Dates to the Set of Dates      
            */                      
            if(mapPubCodeToNonPubDates.containsKey(nonPubDay.Publication_Code__c)) 
                mapPubCodeToNonPubDates.get(nonPubDay.Publication_Code__c).add(nonPubDay.Non_Publication_Date__c);
            else 
                mapPubCodeToNonPubDates.put(nonPubDay.Publication_Code__c, new Set<Date>{nonPubDay.Non_Publication_Date__c});
        }                 
        //END 15/01/15 Wenjun
        
        for(Zuora__Subscription__c sub : subList) {
            List<Zuora__SubscriptionProductCharge__c> spcList = new List<Zuora__SubscriptionProductCharge__c>();
            /*
            Check if line item is linked to Subscriptions       
            */              
            if(mapSubsIdToSubProdCharges.containsKey(sub.id)) {
                spcList = mapSubsIdToSubProdCharges.get(sub.id);
            }
            //START D-1757 15/01/15 Wenjun : Rate Plan for calculating Postage Charge Usage
            zqu__ProductRatePlan__c ratePlan = NULL;
            //END D-1757 15/01/15 Wenjun
            /*
            Map<Day of Week under Subscription Product and Charges>     
            */          
            //START: New PC Implementation 12/11/2014 Modified by Kristine Campang - modified code according new PC configuration
            Map<String, Zuora__SubscriptionProductCharge__c> mapDOWToSubProdCharges = new Map<String, Zuora__SubscriptionProductCharge__c>();
            for(Zuora__SubscriptionProductCharge__c spc : spcList ) {
                if(spc.Zuora__UOM__c == ConstantsSLB.getUOM('Credit Copy Weekday')) {
                    mapDOWToSubProdCharges.put('Weekday', spc);
                }
                else if(spc.Zuora__UOM__c == ConstantsSLB.getUOM('Credit Copy Sat')) {
                    mapDOWToSubProdCharges.put('Saturday', spc);
                }
                else if(spc.Zuora__UOM__c == ConstantsSLB.getUOM('Credit Copy Sun')) {
                    mapDOWToSubProdCharges.put('Sunday', spc);
                }               
            } 
            //END: New PC Implementation 12/11/2014 Modified by Kristine Campang
            for(Zuora__SubscriptionProductCharge__c spc : spcList) {
                if(spc.Zuora__Type__c != 'Usage') {
                    /*
                    Check if line item is linked to Subscriptions Product and Charges       
                    */              
                    if(mapSubProdChargeIdToProdRatePlanCharge.containsKey(spc.Id)) 
                    {
                        zqu__ProductRatePlanCharge__c pRpCharge = mapSubProdChargeIdToProdRatePlanCharge.get(spc.Id);
                        /*
                        Map <Publication Code to Map of Day of Week to counter> 
                        */
                        Map<String, Map<String, Integer>> mapPubCodeToDoW = new Map<String, Map<String, Integer>>();
                        Map<String, Map<String, Integer>> mapPubCodeToDoWCopy = new Map<String, Map<String, Integer>>();
                        /*
                        Check if line item is linked to Product Rate Plan Charge Publication Code       
                        */                          
                        if(mapPubCodeToPublication.containsKey(pRpCharge.PublicationCode__c)) {
                            Publication__c pub = mapPubCodeToPublication.get(pRpCharge.PublicationCode__c);
                            String subfreq = refundComputation.convertSubFreq(mapPubCodeToPublication.get(pRpCharge.PublicationCode__c), new zqu__ProductRatePlan__c(SubscriptionFrequency__c = pRpCharge.zqu__ProductRatePlan__r.SubscriptionFrequency__c));
                            
                            //START D-1757 15/01/15 Wenjun : Rate Plan for calculating Postage Charge Usage
                            //Note: temp solution to minimise change to existing codes. Need review
                            ratePlan = new zqu__ProductRatePlan__c(
                                SubscriptionFrequency__c = pRpCharge.zqu__ProductRatePlan__r.SubscriptionFrequency__c);
                            //END D-1757 15/01/15 Wenjun
            
                            if (mapPubCodeToDoW.get(pRpCharge.PublicationCode__c) == null) {
                                mapPubCodeToDoW.put(pRpCharge.PublicationCode__c, new Map<String, Integer>());
                            }
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
                            
                            Date compStartDate = startDate;
                            Date compEndDate = endDate;
                            Set<Date> nonPubDates = new Set<Date>();
                            String dayOfWeek;
                            if(mapPubCodeToNonPubDates.containsKey(pub.Publication_Code__c)) {
                                nonPubdates = mapPubCodeToNonPubDates.get(pub.Publication_Code__c);
                            }
                            //START: New PC Implementation 12/11/2014 Modified by Kristine Campang - modification for new PC configuration
                            for(compStartDate = compStartDate; compStartDate <= compEndDate; compStartDate = compStartDate.addDays(1)) {    
                                if(!nonPubDates.contains(compStartDate)){
                                    dayOfWeek = ((DateTime)compStartDate).format('EEEE');            
                                    if(mapPubCodeToDoW.get(pub.Publication_Code__c).containsKey(dayOfWeek)) {
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
                                        // End: D- 0462 / 1-8-2015 / K. Tan / DOW Modification Counter
    
                                        }
                                    }
                                }
                            }   
                        } //End of if(mapPubCodeToPublication.containsKey)
                        for(String pubCode : mapPubCodeToDoWCopy.keySet()) {
                            for(String dayOfWeek : mapPubCodeToDoWCopy.get(pubCode).keySet()){
                                if(mapPubCodeToDoWCopy.get(pubCode).get(dayOfWeek) != 0){
                                    Zuora__SubscriptionProductCharge__c Zspc = new Zuora__SubscriptionProductCharge__c();
                                    if(mapDOWToSubProdCharges.containsKey(dayOfWeek)) {
                                        Zspc = mapDOWToSubProdCharges.get(dayOfWeek);
                                    }
                                    Usage__c usageRec = new Usage__c();
                                    usageRec.Quantity__c = (mapPubCodeToDoWCopy.get(pubCode).get(dayOfWeek));
                                    usageRec.UOM__c = Zspc.Zuora__UOM__c;
                                    //START D-2332 and D-2406 / 3-3-2015 / Von Alvin Pernicia / Change sub.id to Sub.Name
                                    usageRec.Subscription_Id__c = String.valueOf(sub.Name);
                                    //END D-2332 and D-2406 / 3-3-2015 / Von Alvin Pernicia / Change sub.id to Sub.Name
                                    usageRec.Account_Id__c = sub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c;
                                    usageRec.Start_Date__c = startDate;
                                    usageRec.Rate_Plan_Charge_Id__c = Zspc.Zuora__ChargeNumber__c;
                                    // Start: D- 0462 / 12-8-2014 / K. Tan / Populate Status on Usage
                                    usageRec.Status__c = 'New'; 
                                   // End: D- 0462 / 12-8-2014 / K. Tan / Populate Status on Usage
                                    usageList.add(usageRec);
                                }
                            }
                        } //End of for Loop
                        //END: New PC Implementation 12/11/2014 Modified by Kristine Campang
                    } 
                }  //END of if(spc.Zuora__Type__c != 'Usage') 
            } // End of For Loop  
            //START D-1757 15/01/15 Wenjun : Usage for Postage Charge
            if(sub.Delivered_By_1__c == 'Mailing Agent')
            {
                if(sub.Billing_Type__c == 'Full Prepaid')
                {
                    Integer remainingMths = endDate.monthsBetween(sub.Zuora__SubscriptionEndDate__c);
                    //Check if this month copy is Not issued, add 1 month refund
                    if(!SP_ProrationUtility.isIssuedInPeriod(sub.ID, pubList, endDate.toStartOfMonth(), endDate, nonPubDayList, ratePlan))
                        { remainingMths += 1;}
                    
                    usageList.add(createPostageUsage(remainingMths, ConstantsSLB.getUOM('CreditPostageCharge'),sub.Name,
                                      sub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c, endDate));
                }
                else if (sub.Billing_Type__c =='Recurring Prepaid')
                {
                    //Check if this month copy is NOT issued, refund 1 month
                    if(!SP_ProrationUtility.isIssuedInPeriod(sub.ID, pubList, endDate.toStartOfMonth(), endDate, nonPubDayList, ratePlan))
                    { 
                        usageList.add(createPostageUsage(1, ConstantsSLB.getUOM('CreditPostageCharge'),sub.Name,
                                                         sub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c, endDate));
                    }
                }
                else if (sub.Billing_Type__c =='Recurring Postpaid')
                {
                    //Check if this month copy is already issued, send 1 mth usage
                    if(SP_ProrationUtility.isIssuedInPeriod(sub.ID, pubList, endDate.toStartOfMonth(), endDate, nonPubDayList, ratePlan))
                    { 
                        usageList.add(createPostageUsage(1, ConstantsSLB.getUOM('PostageCharge'),sub.Name,
                                                         sub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c, endDate));
                    }    
                }
            }
            //END D-1757 15/01/15 Wenjun
        } //End of for(Zuora__Subscription__c sub : subList)
    return usageList;   
    }

    public static void populateSubscriptionToSpC(Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapSubsIdToSubProdCharges, List<Zuora__Subscription__c> subList, Set<String> ratePlanCharges, List<Zuora__SubscriptionProductCharge__c> subProdChaList) {
        
        //START D-1862 01/24/2015 Marvin Gatchalian - Added piece of code to change the approach of retrieving SPC related list
            set <id> mySetSubs = new set <id>();
            
            for(Zuora__Subscription__c zSub : subList ) {
                 mySetSubs.add(zSub.id);
            }
            
            List <Zuora__SubscriptionProductCharge__c> spcList = new List <Zuora__SubscriptionProductCharge__c>();
            spcList = [select id, name, Zuora__Subscription__c, Zuora__ProductSKU__c, Zuora__Quantity__c
                         from Zuora__SubscriptionProductCharge__c where Zuora__Subscription__c IN :mysetSubs];
    
            Map <id, List<Zuora__SubscriptionProductCharge__c>> subToSPC = new Map <id, List<Zuora__SubscriptionProductCharge__c>>(); 
    
            
            for(Zuora__SubscriptionProductCharge__c spc : spcList ) {
                if (subToSPC.containskey(spc.Zuora__Subscription__c)) {
                    subToSPC.get(spc.Zuora__Subscription__c).add(spc);
    
                }
                else {
                    subToSPC.put(spc.Zuora__Subscription__c, new List <Zuora__SubscriptionProductCharge__c> {spc});
                }
                
            }
            List <Zuora__SubscriptionProductCharge__c> getSPCfromMapList;
        
        //END-1862 01/24/2015 Marvin Gatchalian - Added piece of code to change the approach of retrieving SPC related list
        
        for(Zuora__Subscription__c zSub : subList ) {
            
            //START D-1862 01/24/2015 Marvin Gatchalian - Added piece of code to change the approach of retrieving SPC related list
                /*try{
    
                    getSPCfromMapList = SubToSPC.get(zSub.id);
     
                    if(zSub.Zuora__Subscription_Product_Charges__r.size() > 0) {
                            mapSubsIdToSubProdCharges.put(zSub.id, zSub.Zuora__Subscription_Product_Charges__r);
                            subProdChaList.addAll(zSub.Zuora__Subscription_Product_Charges__r);
                        }
         
                        for(Zuora__SubscriptionProductCharge__c spc : zSub.Zuora__Subscription_Product_Charges__r ) {               
                              ratePlanCharges.add(spc.Name); 
                        }
                     }
                }   
                catch (Exception e){            
                } */
           
                getSPCfromMapList = SubToSPC.get(zSub.id);
                if (getSPCfromMapList != null) {
                    if(getSPCfromMapList.size() > 0) {
                        mapSubsIdToSubProdCharges.put(zSub.id, getSPCfromMapList);
                        subProdChaList.addAll(getSPCfromMapList);
                    }
                    for(Zuora__SubscriptionProductCharge__c spc : getSPCfromMapList ) {               
                        ratePlanCharges.add(spc.Name); 
                    }
                }
            //END D-1862 01/24/2015 Marvin Gatchalian - Added piece of code to change the approach of retrieving SPC related list
        }   

    }
    
    public static void populateSpCToRatePlanCharge(Map<Id, zqu__ProductRatePlanCharge__c> mapSubProdChargeIdToProdRatePlanCharge, List<zqu__ProductRatePlanCharge__c> prodRatePlanCharges, Set<String> pubCodes, List<Zuora__SubscriptionProductCharge__c> subProdChaList) {
        for(zqu__ProductRatePlanCharge__c zPRPCharge : prodRatePlanCharges) {
            for(Zuora__SubscriptionProductCharge__c spc : subProdChaList) {
                /*      
                Check if Subscription Product and Charges Name is equal to Product Rate Plan Charge Name
                and Subscription Product and Charges Product SKU is equal to Product SKU
                */  
                if(spc.Name == zPRPCharge.Name && spc.Zuora__ProductSKU__c == zPRPCharge.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c) {
                    mapSubProdChargeIdToProdRatePlanCharge.put(spc.id, zPRPCharge); 
                }   
            }
            pubCodes.add(zPRPCharge.PublicationCode__c);
        }       
    }   
    public static void populatePubCodeToPublication(Map<String, Publication__c> mapPubCodeToPublication, List<Publication__c> pubList) {
        for(Publication__c pub : pubList) {
            if(pub.Publication_Code__c != null) {
                mapPubCodeToPublication.put(pub.Publication_Code__c, pub);
            }
        }
    }
    public static void populatePubCodeToNonPubDates(Map<String, Set<Date>> mapPubCodeToNonPubDates, List<Non_Publication_Day__c> nonPubDayList) {
        for(Non_Publication_Day__c nonPubDay : nonPubDayList) {
            /*
            Check if line item is linked to Publication Day then add Non Publication Dates to the Set of Dates      
            */                      
            if(mapPubCodeToNonPubDates.containsKey(nonPubDay.Publication_Code__c)) {
                mapPubCodeToNonPubDates.get(nonPubDay.Publication_Code__c).add(nonPubDay.Non_Publication_Date__c);
            }
            else {
                mapPubCodeToNonPubDates.put(nonPubDay.Publication_Code__c, new Set<Date>{nonPubDay.Non_Publication_Date__c});
            }
        } 
    }
    
    //START 15/01/15 Wenjun : Add few Utility Methods 
    //To check if the Publication is issued during the Period
    //Note: temp solution to minimise change to existing codes. Need review e.g. passing one Rate Plan?
    public static Boolean isIssuedInPeriod(ID subID, List<Publication__c> lstPubs, Date startDate, Date endDate, 
                                    List<Non_Publication_Day__c> nonPubDateList, zqu__ProductRatePlan__c prodRatePlan)
    {

        //Get non Publication Dates within the period
        Set<Date> setAffectedPubDates = getPubDaysInPeriod(nonPubDateList,startDate, endDate);
        Boolean isMagazine = false;
        
        //Check if the Publication is Magazine or Newspaper
        //Assumption: one subscription can only contain either Magazine or Newspaper
        for(Publication__c pub : lstPubs)
        {
            if(pub.Publication_Type__c == 'M')  //Magazine 
            {
                isMagazine = true;
                break;
            }
        }
        //START: D - 2551 03/18/2015 Added by Kristine Campang - changed logic for postage issuance 
        if(isMagazine)
        {
            for(Publication__c pub : lstPubs)
            {
                Date lastIssueDate = getLastIssueDate(pub.Frequency_Code__c, pub.Publication_Next_Start_Date__c);
                if(lastIssueDate != NULL)
                {
                    if(setAffectedPubDates.contains(lastIssueDate))
                        continue;
                    else if(startDate < lastIssueDate && lastIssueDate <= endDate) //removed equal as per Joban's code
                        return true;
                }
            }            
        } else // Newspaper
        {
            //Get overlapping Temp Stop Dates if any
            Set<Date> setTSDates = getTempStopDateSet(subID, startDate, endDate);
            
            for(Date theDate = startDate; theDate <= endDate; theDate = theDate.addDays(1)) 
            { 
                if(setTSDates.contains(theDate))
                    continue;
                if(setAffectedPubDates.contains(theDate))
                    continue;
                
                String dayOfWeek = ((DateTime)theDate).format('EEE');   
                
                for(Publication__c pub : lstPubs){
                    if(isSubscriptionDate(pub, prodRatePlan, dayOfWeek))
                        return true;
                }
            }
        }
        return false;
        //END: D - 2551 03/18/2015 Added by Kristine Campang - changed logic for postage issuance 
    }
    
    //Generate the set which contains the Non-Publish Days during the period
    public Static Set<Date> getPubDaysInPeriod(List<Non_Publication_Day__c> nonPubDateList, Date startDate, Date endDate){
        Set<Date> setReturnDates = new Set<Date>();
        for(Non_Publication_Day__c nonPubDate : nonPubDateList){
            if(startDate <= nonPubDate.Non_Publication_Date__c && nonPubDate.Non_Publication_Date__c <= endDate)
                setReturnDates.add(nonPubDate.Non_Publication_Date__c);            
        }
        return setReturnDates;
    }
    
    public Static Boolean isSubscriptionDate(Publication__c publicationRec, zqu__ProductRatePlan__c prodRatePlanRec, String paramDOW ){
        Boolean returnVal = false;
        
        //convert Subscription Frequency to equivalent YYYYYNN
        String defaultFreq = publicationRec.Published_Days__c;
        String subFreq = convertSubFreq(publicationRec, prodRatePlanRec);
        
     
        
        if(defaultFreq != null && paramDOW != null && subFreq != null && subFreq.length() == 7)
        { 
            if((defaultFreq.substring(0,1)== 'Y' && subfreq.substring(0,1)=='Y' && paramDOW == 'MON')
             ||(defaultFreq.substring(1,2)== 'Y' && subfreq.substring(1,2)== 'Y' && paramDOW =='TUE')
             ||(defaultFreq.substring(2,3)== 'Y' && subfreq.substring(2,3)== 'Y' && paramDOW =='WED') 
             ||(defaultFreq.substring(3,4)== 'Y' && subfreq.substring(3,4)== 'Y' && paramDOW =='THU')
             ||(defaultFreq.substring(4,5)== 'Y' && subfreq.substring(4,5)== 'Y' && paramDOW =='FRI')
             ||(defaultFreq.substring(5,6)== 'Y' && subfreq.substring(5,6)== 'Y' && paramDOW =='SAT')
             ||(defaultFreq.substring(6,7)== 'Y' && subfreq.substring(6,7)== 'Y' && paramDOW =='SUN'))
            {
                   returnVal = true;
            }
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Publication or Subscription Frequency');
            ApexPages.addMessage(myMsg);   
        } 
            
        return returnVal;
    }
    
    public Static String convertSubFreq(Publication__c pubObj, zqu__ProductRatePlan__c prodRatePlan){
        String returnVal = '';
        
        if(prodRatePlan != NULl && pubObj != NULL)
        {
            if(prodRatePlan.SubscriptionFrequency__c == '0')
                returnVal = pubObj.Published_Days__c;
            else if(prodRatePlan.SubscriptionFrequency__c == '1')
                returnVal = 'YYYYYNN';
            else if(prodRatePlan.SubscriptionFrequency__c == '2')
                returnVal = 'NNNNNYY';
            else if(prodRatePlan.SubscriptionFrequency__c == '3')
                returnVal = 'YYYYYYN';
        }

        return returnVal;
    }
    
    //Check if there is Temp Stop request. If yes, return the Temp Stop Date 
    public Static Set<Date> getTempStopDateSet(ID subID, Date fromDt, Date toDt)
    {
        Set<Date> setTSDates = new Set<Date>();
        Set<ID> setTempStopID = new Set<ID>();
        for(Subscription_Temp_Stop__c subTempStop : [SELECT Id, Name, Subscription__c, Temp_Stop__c, Temp_Stop__r.Id
                                            FROM Subscription_Temp_Stop__c WHERE Subscription__r.Id =: subID])
        {
            if (subTempStop.Temp_Stop__c!= null)
                setTempStopID.add(subTempStop.Temp_Stop__c);
        }
        
        if(!setTempStopID.isEmpty()) 
        { 
            //Retrieve all temp stops which are overlapping with this Period
            for(Temp_Stop__c tempStopObj: [SELECT Id, Name, Restart_Date__c, Temp_Stop_Date__c, Temp_Stop_Qty__c, Temp_Stop_Status__c
                                        FROM Temp_Stop__c WHERE Id IN :setTempStopID AND Cancelled__c = false 
                                        AND Temp_Stop_Date__c <= :toDt AND Restart_Date__c > = :fromDt])
            {
                Date stopDate = tempStopObj.Temp_Stop_Date__c;
                Date restartDate = tempStopObj.Restart_Date__c;
                if(stopDate != NULL && restartDate != NULL)
                {
                    for(Date theDate = stopDate; theDate <= restartDate; theDate = theDate.addDays(1)) 
                        setTSDates.add(theDate);
                }
            }
        }
        
        return setTSDates;
    }
    //START: D-2551 03/20/2015 Added by Kristine Campang - added frequency codes for magazine    
    public static Date getLastIssueDate(String strFrequency, Date nextIssueDate)
    {
        Date dateReturn = NULL;
        if(strFrequency != NULL && nextIssueDate != NULL)
        {   
            //START: D-2551 03/18/2015 Added by Kristine Campang - added conditions for updated list of frequency code
            if(strFrequency.equalsIgnoreCase('F')) //Fortnightly
                dateReturn = nextIssueDate.addDays(-1);
            else if(strFrequency.equalsIgnoreCase('W')) //Weekly
                dateReturn = nextIssueDate.addDays(-14);
            else if(strFrequency.equalsIgnoreCase('M')) //Monthly
                dateReturn = nextIssueDate.addMonths(-1);
            else if(strFrequency.equalsIgnoreCase('Y')) //Yearly
                dateReturn = nextIssueDate.addYears(-1);
            else if(strFrequency.equalsIgnoreCase('B')) //Bi-Monthly
                dateReturn = nextIssueDate.addMonths(-2);
            else if(strFrequency.equalsIgnoreCase('Q')) //Quarterly
                dateReturn = nextIssueDate.addMonths(-3);
            else if(strFrequency.equalsIgnoreCase('H')) //Half-Yearly
                dateReturn = nextIssueDate.addMonths(-6);
            //END: D-2551 03/18/2015 Added by Kristine Campang
        }
        return dateReturn;
    }
    //END: D-2551 03/20/2015 Added by Kristine Campang   
                         
    public static Usage__c createPostageUsage(Integer qty, String strUOM, String subName, String accountId, Date startDate)
    {
        Usage__c usageRec = new Usage__c();
        usageRec.Quantity__c = qty;
        usageRec.UOM__c = strUOM;
        usageRec.Subscription_Id__c = subName;
        usageRec.Account_Id__c = accountId;
        usageRec.Start_Date__c = startDate;
        return usageRec;
    }
    //END 15/01/15 Wenjun
    
    //START D-1615, D-1618, D-1619 30/01/2015 Jeffrey Teves : Initialize a Usage Record if conditions match criteria. Used for Proration Batch.
    /*
    *[K. Tan 3/9/2015] - D-1968
    * History to Modify existing parameters to capture Grace Period Subscriptions
    */
    public static Usage__c createUsage(Set<Date> nonPubDates, Zuora__SubscriptionProductCharge__c spc, Usage__c usageRec, Date subStartDate, Date subEndDate, Date graceEndDate, 
        String subStatus, String billingType, Id graceSub, Decimal zuoraQty, Boolean isInCopyUom, Boolean isInCreditCopyUom, Boolean isInIssueUom, Boolean isInNoCreditUOM,  Boolean hasMondayIssue, 
        Boolean hasTuesdayIssue, Boolean hasWednesdayIssue, Boolean hasThursdayIssue, Boolean hasFridayIssue, Boolean hasSaturdayIssue, Boolean hasSundayIssue) {
        Date startDate;
        Date endDate;
        
        // Scenario 1: Recurring Prepaid: Create Copy-Based UOM's with quantity based on delivery days
        if(billingType == RECURRING_PREPAID && subStatus == STATUS_ACTIVE && isInCopyUom && graceSub == null) { 
            //load copy UOM
            usageRec = new Usage__c();
            startDate = subStartDate;
            endDate = refundComputation.getlastDayOfTheMonth(Date.today());
        }
        
        // Scenario 2: Recurring Prepaid: Mid-Month Expiry: Create Credit-Copy-Based UOM's with quantity based on end date to end of month
        else if(billingType == RECURRING_PREPAID && subStatus == STATUS_EXPIRED && isInCreditCopyUom && graceSub == null) {
            //load credit copy UOM
            usageRec = new Usage__c();
            startDate = subEndDate;
            endDate = refundComputation.getlastDayOfTheMonth(Date.today());
        }
        
        // Scenario 3: Recurring Postpaid: Create Issue-Based UOM's with quantity based on delivery days
        else if(billingType == RECURRING_POSTPAID && isInIssueUom && graceSub == null) {
            //load issue UOM
            usageRec = new Usage__c();
            Date startOfTheMonth = refundComputation.getfirstDayOfTheMonth();
            Date endOfTheMonth = refundComputation.getlastDayOfTheMonth(Date.today());
            if(subStartDate > startOfTheMonth) {
                startDate = subStartDate;
            }
            else {
                startDate = startOfTheMonth;
            }
            
            if(subEndDate < endOfTheMonth) {
                endDate = subEndDate;
            }
            else {
                endDate = endOfTheMonth;    
            }
        }
        //START: D-1968 / 3-9-2015/ K. Tan/ Modify existing condition to capture Grace Period Subscriptions 

        // Scenario 4: Grace Period Subscription Create No Credit UOM's with quantity based on delivery days
        else if(graceSub != null && isInNoCreditUOM) {
            //load issue UOM
            usageRec = new Usage__c();
            Date startOfTheMonth = refundComputation.getfirstDayOfTheMonth();
            Date endOfTheMonth = refundComputation.getlastDayOfTheMonth(Date.today());
            if(subStartDate > startOfTheMonth) {
                startDate = subStartDate;
            }
            else {
                startDate = startOfTheMonth;
            }
            
            if(graceEndDate < endOfTheMonth) {
                endDate = graceEndDate;
            }
            else {
                endDate = endOfTheMonth;    
            }
        }        
        //END: D-1968 / 3-9-2015/ K. Tan/ Modify existing condition to capture Grace Period Subscriptions 
        
        if(usageRec != NULL) {  
            usageRec.UOM__c = spc.Zuora__UOM__c;
            usageRec.Rate_Plan_Charge_Id__c = spc.Zuora__ChargeNumber__c;
            
            Integer usageQty = 0;
            String dayOfWeek = '';
            
            for(startDate = startDate; startDate <= endDate; startDate = startDate.addDays(1)) {
                //count the quantity if the current date is not a non-pub date and has a delivery/publication on the current day of the week
                dayOfWeek = ((DateTime)startDate).format('EEEE');
                if(!nonPubDates.contains(startDate) && 
                    ((dayOfWeek.equalsIgnoreCase(MONDAY_STRING) && hasMondayIssue) ||
                    (dayOfWeek.equalsIgnoreCase(TUESDAY_STRING) && hasTuesdayIssue) ||
                    (dayOfWeek.equalsIgnoreCase(WEDNESDAY_STRING) && hasWednesdayIssue) ||
                    (dayOfWeek.equalsIgnoreCase(THURSDAY_STRING) && hasThursdayIssue) ||
                    (dayOfWeek.equalsIgnoreCase(FRIDAY_STRING) && hasFridayIssue) ||
                    (dayOfWeek.equalsIgnoreCase(SATURDAY_STRING) && hasSaturdayIssue) ||
                    (dayOfWeek.equalsIgnoreCase(SUNDAY_STRING) && hasSundayIssue))) {
                    
                    
                    if((usageRec.UOM__c.contains(WEEKDAY_UOM_STRING) && 
                        (dayOfWeek.equalsIgnoreCase(MONDAY_STRING) ||
                        dayOfWeek.equalsIgnoreCase(TUESDAY_STRING) ||
                        dayOfWeek.equalsIgnoreCase(WEDNESDAY_STRING) ||
                        dayOfWeek.equalsIgnoreCase(THURSDAY_STRING) ||
                        dayOfWeek.equalsIgnoreCase(FRIDAY_STRING))) ||
                        (usageRec.UOM__c.contains(SATURDAY_UOM_STRING) && dayOfWeek.equalsIgnoreCase(SATURDAY_STRING)) ||
                        (usageRec.UOM__c.contains(SUNDAY_UOM_STRING) && dayOfWeek.equalsIgnoreCase(SUNDAY_STRING)) ||
                        (!usageRec.UOM__c.contains(WEEKDAY_UOM_STRING) && !usageRec.UOM__c.contains(SATURDAY_UOM_STRING) &&
                        !usageRec.UOM__c.contains(SUNDAY_UOM_STRING))) {
                        usageQty += (Integer) zuoraQty;
                    }
                }
            }
            usageRec.Quantity__c = usageQty;
        }
        return usageRec;
    }
    
    //END D-1615, D-1618, D-1619 30/01/2015 Jeffrey Teves
}