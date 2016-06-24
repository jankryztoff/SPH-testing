/**
 * Class Name: <MigrationCaseTriggerHandler>
 * @author: <Christopher Camilon>
 * Date: <04/19/2016>
 * Requirement/Project Name: <SPH>
 * @description<To populate the necesarry fields for Case temp Stop> 
 *
 */
public class MigrationCaseTriggerHandler implements TriggerHandlerInterface{

    public static Boolean preventExecution = FALSE;
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    Id CASE_TEMP_STOP_TYPE_ID  = (Id) ConstantsSLB.getKeyId('Case_Temp Stop');
    Static Set<Id> subIds = new Set<Id>();
    Static Set<Id> pckIds = new Set<Id>();
    Static Set<Id> tempStopIdSet = new Set<Id>();
    Static Map<Id, Temp_Stop__c> tempStopMap = new Map<Id, Temp_Stop__c>();
    Static Map<String, Zuora__Subscription__c> subMap = new Map<String, Zuora__Subscription__c>();
    Static Map<Id, Set<String>> spcMap = new Map<Id, Set<String>>();
    Static Map<Id, Id> subPackageMap = new Map<Id, Id>();
    Static Map<String, List<Package_Item__c>> packPackageItemMap = new Map<String, List<Package_Item__c>>();
    //Static List<Zuora__Subscription__c> updSubList = new List<Zuora__Subscription__c>();
    Static Map<Id, Zuora__Subscription__c> updSubMap = new Map<Id, Zuora__Subscription__c>();
    
    
   
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !MigrationCaseTriggerHandler.isBeforeInsertTriggerCalled;
        MigrationCaseTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !MigrationCaseTriggerHandler.isBeforeUpdateTriggerCalled;
        MigrationCaseTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !MigrationCaseTriggerHandler.isBeforeDeleteTriggerCalled;
        MigrationCaseTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !MigrationCaseTriggerHandler.isAfterInsertTriggerCalled;
        MigrationCaseTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !MigrationCaseTriggerHandler.isAfterUpdateTriggerCalled;
        MigrationCaseTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !MigrationCaseTriggerHandler.isAfterDeleteTriggerCalled;
        MigrationCaseTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;
    }
    
    public void bulkBefore() {
    
        
        if (Trigger.isUpdate) {
        
            for (Case curCase : (list<Case>)trigger.new) {
                if(curCase.RecordTypeId == CASE_TEMP_STOP_TYPE_ID && curCase.Case_Legacy_Id__c != null && curCase.Temp_Stop_Sub__c != null && curCase.Current_Date_for_Year_To_Date__c == null){ 
                    subIds.add(curCase.Temp_Stop_Sub__c);                
                }
                if(curCase.Temp_Stop__c != null && curCase.Case_Legacy_Id__c != null && curCase.Temp_Stop_Date__c == null && curCase.Restart_Date__c == null){
                    tempStopIdSet.add(curCase.Temp_Stop__c);
                }
            }
            System.debug('Ids are ' + subIds);
            List<Temp_Stop__c> tsList = new List<Temp_Stop__c>();
            
            if(!tempStopIdSet.isEmpty()){
                tsList = [SELECT Id, Name, Temp_Stop_Date__c, Restart_Date__c, Qty__c FROM Temp_Stop__c where Id IN :tempStopIdSet];
            }
            for(Temp_Stop__c tStop : tsList){
                tempStopMap.put(tStop.id,tStop);
            
            }
            if(!subIds.isEmpty()){
            
            List<Zuora__SubscriptionProductCharge__c> spcList = new List<Zuora__SubscriptionProductCharge__c>();            
            spcList = [SELECT Id, PublicationCode__c, Zuora__Subscription__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c IN :subIds];
            for(Zuora__SubscriptionProductCharge__c spc : spcList){
                if(spc.PublicationCode__c != null && spc.PublicationCode__c != ''){
                    if(!spcMap.containsKey(spc.Zuora__Subscription__c)){
                        spcMap.put(spc.Zuora__Subscription__c, new Set<String>());  
                        spcMap.get(spc.Zuora__Subscription__c).add(spc.PublicationCode__c);  
                    }else{
                        spcMap.get(spc.Zuora__Subscription__c).add(spc.PublicationCode__c); 
                    } 
                }
            }
            List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
            subList = [SELECT Id, Main_Package_1__c, Next_Year_Temp_Stop_Days__c, Year_to_Date_Temp_Stop_Days__c, Frequency_1__c, Order_Line_Item_Number_1__r.Ph_e__c, Order_Line_Item_Number_1__r.Ph_d__c  FROM Zuora__Subscription__c WHERE Id IN :subIds];
            for(Zuora__Subscription__c sub : subList){
                pckIds.add(sub.Main_Package_1__c);
                subPackageMap.put(sub.id, sub.Main_Package_1__c);
                subMap.put(sub.id, sub);
            }
            List<Package_Item__c> pckItemList = new List<Package_Item__c>();
            pckItemList = [SELECT Id, Is_All_In_One__c, Package__c FROM Package_Item__c WHERE Package__c IN :pckIds];
            for(Package_Item__c pckItem : pckItemList){
            
                if(!packPackageItemMap.containsKey(pckItem.Package__c)){                  
                    packPackageItemMap.put(pckItem.Package__c, new List<Package_Item__c>());
                    packPackageItemMap.get(pckItem.Package__c).add(pckItem);  
                }else{
                    packPackageItemMap.get(pckItem.Package__c).add(pckItem);  
                }
            }
            }
        } 
      
                                             
        
    }
    public void bulkAfter(){
    
    }
    
    public void beforeDelete(SObject so){
        
    }
    
    public void beforeInsert(SObject so) {
        Case newCase = (Case)so;
        if(newCase.RecordTypeId == CASE_TEMP_STOP_TYPE_ID && newCase.Case_Legacy_Id__c != null){
                newCase.Status = 'Closed';
                newCase.Sub_Status__c = 'Temp Stop Approved';
                newCase.Temp_Stop_Type__c = 'Create';
                
        }

    
    }
    
    public void beforeUpdate(SObject oldSo,SObject so){
    
        //for(Case updCase : lstUpdCases)
        Case updCase = (Case)so;
            if(updCase.RecordTypeId == CASE_TEMP_STOP_TYPE_ID && updCase.Case_Legacy_Id__c != null ){
                
                if(updCase.Temp_Stop__c != null && updCase.Temp_Stop_Date__c == null && updCase.Restart_Date__c == null ){    
                    
                    if(tempStopMap.containsKey(updCase.Temp_Stop__c)){
                        Temp_Stop__c tStop = tempStopMap.get(updCase.Temp_Stop__c);
                        updCase.Temp_Stop_Date__c = tStop.Temp_Stop_Date__c;     
                        updCase.Restart_Date__c = tStop.Restart_Date__c; 
                        updCase.Qty__c = tStop.Qty__c;
                    }
                }
                if(updCase.Temp_Stop_Sub__c != null && updCase.Current_Date_for_Year_To_Date__c == null){    
                    UsageHelper.initialize();
                    Integer currentYear = 0;
                    Integer nextYear = 0;
                    Integer AccumulatedNextYear = 0;
                    Integer AccumulatedCurrentYear = 0;
                        
                    Integer counterAllInOne = 0;
                    
                    for(Package_Item__c pckItem : packPackageItemMap.get(subPackageMap.get(updCase.Temp_Stop_Sub__c))){                 
                        if(pckItem.Is_All_In_One__c == true){
                            counterAllInOne++;
                        }                           
                    }
                    
                    if(counterAllInOne == 0){   
                    
                        for(Date tempDate = updCase.Temp_Stop_Date__c; tempDate<updCase.Restart_Date__c; tempDate=tempDate.addDays(1)){
                            
                            for(String pubCode : spcMap.get(updCase.Temp_Stop_Sub__c)){
                                currentYear = 0; 
                                nextYear = 0;
                                Zuora__Subscription__c checkSub = subMap.get(updCase.Temp_Stop_Sub__c);

                                
                                PublicationIssueWrapper pubWrapperDiscount = UsageHelper.IssueCalculation(pubCode, tempDate, tempDate, checkSub, Integer.valueOf(updCase.Qty__c));
                               
                                currentYear = pubWrapperDiscount.current_year_days;  
                                nextYear = pubWrapperDiscount.next_year_days;
                                
                                if(updCase.Temp_Stop_Type__c == 'Create'){                              
                                    if(AccumulatedCurrentYear < 30){
                                        AccumulatedCurrentYear += currentYear;
                                    }
                                    if(AccumulatedNextYear < 30){
                                        AccumulatedNextYear += nextYear;
                                    }                               
                                }
                            }                           
                        }                                   
                    }
                    Zuora__Subscription__c sub;
                    if(updSubMap.containsKey(updCase.Temp_Stop_Sub__c)){
                        sub = updSubMap.get(updCase.Temp_Stop_Sub__c);              
                    }else{
                        sub = subMap.get(updCase.Temp_Stop_Sub__c);
                    }
                    
                    Decimal subYearToDateCount;
                    
                    Decimal subNextYearToDateCount;
                    if(sub.Year_to_Date_Temp_Stop_Days__c != null){
                        subYearToDateCount = sub.Year_to_Date_Temp_Stop_Days__c;
                    }
                    if(sub.Next_Year_Temp_Stop_Days__c != null){
                        subNextYearToDateCount = sub.Next_Year_Temp_Stop_Days__c;
                    }
                    
                    if (AccumulatedCurrentYear == null) {
                        AccumulatedCurrentYear = 0;
                    }
                    
                    if (AccumulatedNextYear == null) {
                        AccumulatedNextYear = 0;
                    }
                    
                    if (subYearToDateCount == null) {
                        subYearToDateCount = 0;
                    }
                    
                    if (subNextYearToDateCount == null) {
                        subNextYearToDateCount = 0;
                    }
                    
                    if(updCase.Temp_Stop_Type__c == 'Create'){
                        if((AccumulatedCurrentYear + subYearToDateCount) > 30){
                            AccumulatedCurrentYear = 30 - Integer.valueOf(subYearToDateCount);
                        }
                        if((AccumulatedNextYear + subNextYearToDateCount) > 30){
                            AccumulatedNextYear = 30 - Integer.valueOf(subNextYearToDateCount);
                        }                   
                    }
                    
                    if(updCase.Temp_Stop_Date__c.daysBetween(updCase.Restart_Date__c) >= 8){
                        updCase.Next_Year_for_Year_To_Date__c =  AccumulatedNextYear;
                        updCase.Current_Date_for_Year_To_Date__c = AccumulatedCurrentYear;
                        sub.Year_to_Date_Temp_Stop_Days__c = subYearToDateCount + AccumulatedCurrentYear;
                        sub.Next_Year_Temp_Stop_Days__c = subNextYearToDateCount + AccumulatedNextYear;
                        updSubMap.put(sub.id,sub);                       
                        //updSubList.add(sub);
                    }
                    else{
                        updCase.Next_Year_for_Year_To_Date__c =  0;
                        updCase.Current_Date_for_Year_To_Date__c = 0;
                    }
                    
                }
                
            }
        
        
    
    }
    
    public void afterUpdate(SObject oldSo,SObject so){
        
    }
    
    public void afterDelete(SObject so){
        
    }
    public void afterInsert(SObject so){
        
    }
    
    public void andFinally() {
        List<Zuora__Subscription__c> updSubList = new List<Zuora__Subscription__c>();
        for(Id updSubId : updSubMap.KeySet()){
            updSubList.add(updSubMap.get(updSubId));
        }
        System.debug('update list is: ' + updSubList);
        if(!updSubList.isEmpty()){        
            try {
                update updSubList;    
            } catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }                       
        }
    
    }
}