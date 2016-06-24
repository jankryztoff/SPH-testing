/**
 * Class Name: UsageCreationForGoodwill
 * @author: Kristine Campang
 * Date: 12/14/2014
 * Requirement/Project Name: CRSM Project
 * @description class that sends goodwill amount as Usage to Zuora 
 * @Author : Jason Abolac / Jayson Sarion
 * @history : additional callout for goodwill usage
 * @date : 03/20/2015
 */
public class UsageCreationForGoodwill{
    
    //variables
    
    @future(callout=true)
    public static void createUsageForGoodwill(Set<Id> caseIdSet){ 
        Zuora__SubscriptionProductCharge__c spc;
        Map<String, object> usageMap;
        String startDate;
        Set<Id> subIdSet = new Set<Id>();
        list<case> scase = new list<case>();
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        startDate = zuora.zUtil.getZuoraDate(date.today());
        Map<Id, id> subIdToCaseMap = new Map<Id, id>();
        Map<id, Case> caseidtocasemap = new Map<Id, Case>();
        
        //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
        List<Usage__c> usageList = new List<Usage__c>();        
        //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
        
        Map<Id, List<Case_Subscription__c>> subIdToCaseSubListMap = new Map<Id, List<Case_Subscription__c>>(); //START-END D-4001 12/1/2015 Added by J.Sarion - sub Id to List of Case Subscription
        
        //START D-4001 12/1/2015 Added by J.Sarion - sub Id to List of Case Subscription
        //START D-2884 05-18-2015 Marvin Gatchalian added condition status = closed
        scase = [SELECT id, Goodwill_Amount_Newspaper__c, Goodwill_Amount__c, 
                    RecordType.Name, Subscription_Name__c, ClosedDate, (SELECT ID, 
                    Subscription__c, Goodwill_Amount__c FROM Case_Subscriptions__r) from case where id in: 
                    caseIdSet and Status = 'Closed']; //START/END 03/31/2015 D-2684 Kevin Evasco - No usage for goodwill are being created
        //END D-2884 05-18-2015 Marvin Gatchalian added condition status = closed
        system.debug('>>>CHA scase ' + scase);
        for (case vcase : scase)
        {
            caseidtocasemap.put(vcase.id, vcase);
            
            if (vcase.RecordType.Name =='Complaint - Digital') {
                subIdSet.add(vcase.Subscription_Name__c);
                subIdToCaseMap.put(vcase.Subscription_Name__c, vcase.Id);
            }
            
            for (case_subscription__c casSub :vcase.Case_Subscriptions__r) {
                subIdToCaseMap.put(casSub.Subscription__c, vcase.Id);
                subIdSet.add(casSub.Subscription__c);
                
                if(subIdToCaseSubListMap.containsKey(casSub.Subscription__c)) {
                    subIdToCaseSubListMap.get(casSub.Subscription__c).add(casSub);
                }
                else {
                    subIdToCaseSubListMap.put(casSub.Subscription__c, new List<Case_Subscription__c>());
                    subIdToCaseSubListMap.get(casSub.Subscription__c).add(casSub);
                }
            }
        }
        //END D-4001 12/1/2015 Added by J.Sarion - sub Id to List of Case Subscription
        //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only  
        //START 03/31/2015 D-2684 Kevin Evasco - No usage for goodwill are being created        
        if (!subIdSet.isEmpty()) {
            subList = [SELECT Id, Name, Zuora__External_Id__c, zuora__customeraccount__c , Zuora__CustomerAccount__r.Zuora__AccountNumber__c , (SELECT Id, Name, Zuora__UOM__c , Zuora__Price__c, Zuora__ChargeNumber__c, PublicationCode__c //START/END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier              
                FROM Zuora__Subscription_Product_Charges__r
                WHERE Zuora__Subscription__c in: subIdSet AND Name LIKE :'Goodwill%') from zuora__subscription__c where id in: subIdSet];
            
        }       
        //END 03/31/2015 D-2684 Kevin Evasco - No usage for goodwill are being created
        //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
        
        system.debug('sublist' + sublist);
        //START D-4001 12/2/2015 Added by J.Sarion - Moved creation of usage 
        for (zuora__subscription__c sub : subList)
        {
            system.debug('>>>CHA sub.Zuora__Subscription_Product_Charges__r[0].Zuora__Price__c ' + sub.Zuora__Subscription_Product_Charges__r[0].Zuora__Price__c);
            Decimal price = sub.Zuora__Subscription_Product_Charges__r[0].Zuora__Price__c;
            Decimal goodwill = 0;
            Case c = new Case();
            system.debug('>>>CHA subIdToCaseMap ' + subIdToCaseMap);
            if (subIdToCaseMap.containsKey(sub.Id)) 
            {
                c = caseidtocasemap.get(subIdToCaseMap.get(sub.Id));
            }
            //START D-4001 12/1/2015 Added by J.Sarion - Compute for goodwill
            if (c.RecordType.Name == 'Complaint - Digital') {
                if (c.Goodwill_Amount__c != null && c.Goodwill_Amount__c != 0)
                    goodwill = math.ceil(math.abs(c.Goodwill_Amount__c / price)); //START/END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
                
                Usage__c usageRecord = createUsage(sub, c, goodwill);
                if(usageRecord != null) {
                    usageList.add(usageRecord);
                }
            }
            else if(subIdToCaseSubListMap.containsKey(sub.Id) && !sub.Zuora__Subscription_Product_Charges__r.isEmpty()) {
                for (Case_Subscription__c caseSub : subIdToCaseSubListMap.get(sub.Id))
                {
                    goodwill = 0;
                    system.debug('>>>CHA caseSub.Goodwill_Amount__c ' + caseSub.Goodwill_Amount__c);
                    if (caseSub.Goodwill_Amount__c != null && caseSub.Goodwill_Amount__c != 0) {
                        goodwill = math.ceil(math.abs(caseSub.Goodwill_Amount__c / price)); //START/END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
                    }
                    //START 03/31/2015 D-2610 Kevin Evasco - REMOVED CODE
                    /* REMOVED CODE FOR D-2610
                    usageMap = new Map<String, object>();
                    usageMap.put(globalvariableclass.UOM, subpro.Zuora__UOM__c); 
                    usageMap.put(globalvariableclass.QUANTITY, goodwill); 
                    usageMap.put(globalvariableclass.STARTDATETIME, startDate); 
                    usageMap.put(globalvariableclass.ACCOUNTID, sub.Zuora__CustomerAccount__r.Zuora__External_Id__c); 
                    usageMap.put(globalvariableclass.SUBSCRIPTIONID, sub.Zuora__External_Id__c); 
                    
                    if (goodwill != 0) {
                        listMap.add(usageMap);
                    }
                    REMOVED CODE FOR D-2610 */
                    //END 03/31/2015 D-2610 Kevin Evasco - REMOVED CODE
                    
                    //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
                    /*
                    if(goodwill != 0) {
                        Usage__c usageRecord = new Usage__c();  
                        usageRecord.UOM__c = sub.Zuora__Subscription_Product_Charges__r[0].Zuora__UOM__c;
                        usageRecord.Account_Id__c = sub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c;
                        usageRecord.Subscription_Id__c = sub.Name;
                        if(c.ClosedDate != NULL) {
                            DateTime closeDateTime = c.ClosedDate;
                            usageRecord.Start_Date__c = date.newinstance(closeDateTime.year(), closeDateTime.month(), closeDateTime.day());
                        } else {
                            usageRecord.Start_Date__c = Date.today();
                        }
                        usageRecord.Quantity__c = goodwill;
                        usageRecord.Status__c = UsageHelper.USAGE_STATUS;   
                        usageRecord.Rate_Plan_Charge_Id__c = sub.Zuora__Subscription_Product_Charges__r[0].Zuora__ChargeNumber__c;    
                        usageRecord.Publication_Code__c = sub.Zuora__Subscription_Product_Charges__r[0].PublicationCode__c; //START/END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier              
                        usageRecord.Usage_Type__c = UsageHelper.USAGE_TYPE_GOODWILL;
                        
                        //START UD-2913 25-Sept-2015 Added by S.Puli - populate StopType__c
                        usageRecord.StopType__c = UsageHelper.USAGE_TYPE_GOODWILL;
                        //END UD-2913 25-Sept-2015 Added by S.Puli
                        
                        usageList.add(usageRecord);
                    }
                    */
                    //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
                    
                    Usage__c usageRecord = createUsage(sub, c, goodwill);
                    if(usageRecord != null) {
                        usageList.add(usageRecord);
                    }
                }
            }
            //END D-4001 12/1/2015 Added by J.Sarion - Compute for goodwill
        }

        
        //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
        try{
            system.debug('>>>CHA usageList ' + usageList);
            
            //Start D-4452 02-Apr-2016 Added By S.Puli
            //UsageHelper.loadUniqueUsages(usageList,false);
            UsageHelper.insertUniqueUsages(usageList);
            //End D-4452 02-Apr-2016 Added By S.Puli
        } catch(Exception e){
            system.debug('>>>>>ERROR ' + e);
        }
        //END D-4001 12/2/2015 Added by J.Sarion - Moved creation of usage 
        //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only       
    }
    
    //START D-4001 12/2/2015 Added by J.Sarion - Moved creation of usage 
    public static Usage__c createUsage(Zuora__Subscription__c sub, Case c, Decimal goodwill) {
        Usage__c usageRecord;
        if(goodwill != 0) {
            usageRecord = new Usage__c();
            usageRecord.UOM__c = sub.Zuora__Subscription_Product_Charges__r[0].Zuora__UOM__c;
            usageRecord.Account_Id__c = sub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c;
            usageRecord.Subscription_Id__c = sub.Name;
            if(c.ClosedDate != NULL) {
                DateTime closeDateTime = c.ClosedDate;
                usageRecord.Start_Date__c = date.newinstance(closeDateTime.year(), closeDateTime.month(), closeDateTime.day());
            } else {
                usageRecord.Start_Date__c = Date.today();
            }
            usageRecord.Quantity__c = goodwill;
            usageRecord.Status__c = UsageHelper.USAGE_STATUS;   
            usageRecord.Rate_Plan_Charge_Id__c = sub.Zuora__Subscription_Product_Charges__r[0].Zuora__ChargeNumber__c;    
            usageRecord.Publication_Code__c = sub.Zuora__Subscription_Product_Charges__r[0].PublicationCode__c; //START/END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier              
            usageRecord.Usage_Type__c = UsageHelper.USAGE_TYPE_GOODWILL;
            
            //START UD-2913 25-Sept-2015 Added by S.Puli - populate StopType__c
            usageRecord.StopType__c = UsageHelper.USAGE_TYPE_GOODWILL;
            //END UD-2913 25-Sept-2015 Added by S.Puli
            //START PD-0324 GDelrosario 06092016
            usageRecord.Case__c = c.Id;
            //END PD-0324 GDelrosario 06092016
            
        }
        
        return usageRecord;
    }
    //END D-4001 12/2/2015 Added by J.Sarion - Moved creation of usage 
}