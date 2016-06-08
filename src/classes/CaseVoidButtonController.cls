/**
* Class Name: <CaseVoidButtonController>
* @authors: <Rom Edison Reyes>
* Date: <01/28/2016>
* Requirement/Project Name: <SPH>
* @description: Handles validation logic when "Void" Case button is clicked
* UD-3424 & UD-3425
*/
global class CaseVoidButtonController{
    
   webService static String voidCase(Id caseId, Id userId) {
        //START UD-3911 FrancisBEnzon 9Apr16 : added status in query
        Case caseRec =  [SELECT Id, Status, RecordType.Name, Owner.Name, Owner.Id, Effective_Date__c FROM Case WHERE Id=:caseId];
        Boolean isCaseClosed = false;
        //END UD-3911 FrancisBEnzon 9Apr16 : added status in query
        List<Order_Line_Item__c> lstOLIs = new List<Order_Line_Item__c>();
        Set<String> mainPackageIds = new Set<String>();
        String result = '';
        
        if(caseRec.RecordType.Name == GlobalVariableClass.RECTYPE_COMPLAINT_NEWSPAPER){
            if(caseRec.Owner.Id != userId){
                result = 'You don\'t have permission to void this case record.';
            }else{
                result = updateCase(caseRec);
            }
        }else if(caseRec.RecordType.Name == GlobalVariableClass.RECTYPE_COA){
            if(caseRec.Owner.Id != userId){
                result = 'You don\'t have permission to void this case record.';
            }else{
                Date dateTomorrow = Date.TODAY().addDays(1);
                if(caseRec.Effective_Date__c != null){
                    if(caseRec.Effective_Date__c <= dateTomorrow){
                        result = 'You can only VOID the case if COA effective date is after tomorrow.';
                    }else{
                        result = updateCase(caseRec);
                    }
                }else{
                    result = 'Case has no COA Effective Date. This data is invalid.';
                }
                
            }
        }else if(caseRec.RecordType.Name == GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION || caseRec.RecordType.Name == GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION){
            
            Date earliestStartStopDate;
            Boolean startStopDateError = false;
            String startStop = '';
            
            lstOLIs = [SELECT Id, Main_Package_ID__c, Start_Date__c, Stop_Request_Date__c FROM Order_Line_Item__c WHERE Case__c =:caseId];
            
            if(caseRec.RecordType.Name == GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION){
                startStop = 'Start';
            }else{
                startStop = 'Stop';
            }
            if(!lstOLIs.isEmpty()){
                for(Order_Line_Item__c oli:lstOLIs){
                    if(oli.Main_Package_ID__c != null){
                        mainPackageIds.add(oli.Main_Package_ID__c);
                    }
                }
                if(!mainPackageIds.isEmpty()){
                    earliestStartStopDate = getEarliestStopStartDate(mainPackageIds);
                    if(earliestStartStopDate != null){
                        if(startStop == 'Start'){
                            for(Order_Line_Item__c oli:lstOLIs){
                                if(oli.Start_Date__c != null){
                                    if(oli.Start_Date__c < earliestStartStopDate){
                                        startStopDateError = true;
                                        break;
                                    }
                                }
                            }
                        }else if(startStop == 'Stop'){
                            for(Order_Line_Item__c oli:lstOLIs){
                                if(oli.Stop_Request_Date__c != null){
                                    if(oli.Stop_Request_Date__c < earliestStartStopDate){
                                        startStopDateError = true;
                                        break;
                                    }
                                }
                            }
                        }
                        
                        if(startStopDateError){
                            result = 'This case cannot be VOIDED – the ' + startStop + ' Date is before the Earliest ' +  + startStop +  ' Date';
                        }else{
                            //START UD-3911 13Apr16 FrancisBenzon : reverted original logic as per new new design
                            result = updateCase(caseRec);
                            /*
                            //START UD-3911 9Apr16 FrancisBenzon : check case status
                             if(caseRec.Status == GlobalVariableClass.STATUS_CLOSED)
                            {
                                result = 'Cannot void closed case.';
                                isCaseClosed = true;
                            }else {
                                result = updateCase(caseRec);
                            }*/ 
                            //END UD-3911 9Apr16 FrancisBenzon : check case status
                            //END UD-3911 13Apr16 FrancisBenzon : reverted original logic as per new new design
                        }
                    }else{
                        result = 'No Earliest ' + startStop + ' Date. This data is invalid.';
                    }
                }else{
                    result = 'Order Line Items of Case has no Main Package. This data is invalid.';
                }
            }else{
                result = 'Case has no related Order Line Item. This data is invalid.';
            }
        }
        return result;
   }
   
   public static String updateCase(Case caseRecord){
       
        String updateResult = '';
        
        Case caseToUpdate = new Case();
        caseToUpdate.Id = caseRecord.Id; 
        caseToUpdate.Status = GlobalVariableClass.STATUS_VOID; 
        caseToUpdate.Void_By__c = caseRecord.Owner.Name; 
        caseToUpdate.Void_date__c = Date.TODAY(); 
        
        try{
            update caseToUpdate;
            updateResult = 'The void was successful. Case is now void.';
        
        }catch(Exception e){
            updateResult = 'Error on Updating Case: ' + e.getMessage();
        }
        return updateResult;
   }
   
   public static Date getEarliestStopStartDate(Set<String> setPackageIds){
        List<Package_Item__c> lstPackItems = new List<Package_Item__c>();
        Map<Id, List<zqu__ProductRatePlanCharge__c>> prodRatePlanIdToprodRatePlanMap = new Map<Id, List<zqu__ProductRatePlanCharge__c>>(); 
        Map<String, Date> mapPubIdtoPubRecord = new Map<String, Date>();
        Set<Id> setProdRatePlan = new Set<Id>();
        Date earliestDate;
        List<String> lstPubCodes = new List<String>();
        List<Date> lstEarliestDates = new List<Date>();
        
        for(Publication__c publication : [SELECT Id, Name, Publication_Code__c, Earliest_Start_Date__c from Publication__c]){
            mapPubIdtoPubRecord.put(publication.Publication_Code__c, publication.Earliest_Start_Date__c);
        }
        
        lstPackItems = [SELECT Id, Package__c, Product_Rate_Plan__c, Name FROM Package_Item__c WHERE Package__c IN:setPackageIds];
        
        for(Package_Item__c pkgItem: lstPackItems){
            if(pkgItem.Product_Rate_Plan__c != null){
                setProdRatePlan.add(pkgItem.Product_Rate_Plan__c);
            }
        }

        for(zqu__ProductRatePlanCharge__c prodRatePlan : [SELECT Name, PublicationCode__c, zqu__ProductRatePlanCharge__c.zqu__ProductRatePlan__c 
                                                            FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__c  IN:setProdRatePlan]){
            if(prodRatePlanIdToprodRatePlanMap.containsKey(prodRatePlan.zqu__ProductRatePlan__c)) {
                prodRatePlanIdToprodRatePlanMap.get(prodRatePlan.zqu__ProductRatePlan__c).add(prodRatePlan);
            }                                       
            else {
                prodRatePlanIdToprodRatePlanMap.put(prodRatePlan.zqu__ProductRatePlan__c, new List<zqu__ProductRatePlanCharge__c>{prodRatePlan});        
            }
        }
        
        for(Package_Item__c pkgItem: lstPackItems){
            Id ratePlanId;
            if(pkgItem.Product_Rate_Plan__c != null){
                ratePlanId = pkgItem.Product_Rate_Plan__c;
                if(prodRatePlanIdToprodRatePlanMap.containsKey(ratePlanId)){
                    for(zqu__ProductRatePlanCharge__c prpc: prodRatePlanIdToprodRatePlanMap.get(ratePlanId)){
                        lstPubCodes.add(prpc.PublicationCode__c);
                    }
                }
            }
            
        }
        
        for(String pubCode : lstPubCodes){
            if(pubCode != null) {
                if(mapPubIdtoPubRecord.get(pubCode) != null){
                    lstEarliestDates.add(mapPubIdtoPubRecord.get(pubCode));
                }
            }
        }
        
        if(!lstEarliestDates.isEmpty()){    
            lstEarliestDates.sort();
            earliestDate = lstEarliestDates[0];
        }
        else{
            earliestDate = NULL;
        }   
        
        return earliestDate;
   }
}