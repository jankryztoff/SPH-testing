/**
 * Class Name: <CaseVendorSubscriptionTriggerHandler>
 * @author: <Jinky Salvador>
 * Date: <8/18/2014>
 * Requirement/Project Name: <SPH>
 * @description<Add Case team member>
 */
 public class CaseVendorSubscriptionTriggerHandler implements TriggerHandlerInterface{
 
 //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    
    Set<Id> caseIdCir = new Set<Id>();
    Set<Id> caseIdOpsRep = new Set<Id>();
    Set<Id> subId = new Set<Id>();
    Set<Id> caseIds = new Set<Id>();
    Set<Id> caseIdCsoAdmin = new Set<Id>(); 
    Map<Id,Id> subCaseMap = new Map<Id ,Id>(); // Map of SubscriptionId and CaseId
    Map<Id,Id> contactCaseMap = new Map<Id,Id>(); // Map of ContactId and CaseId
    Map<Integer,Id> sectorCase = new Map<Integer,Id>(); // Map of Sector and caseID
    Map<Id,Id> newCaseTeam = new Map<Id,Id>(); // CaseID and User 
    List<Post_Sector_Ops_Rep_Mapping__c> vendorOps = new List<Post_Sector_Ops_Rep_Mapping__c>();
    
    Map<Id,CaseTeamMember> newCaseTeamMap = new Map<Id,CaseTeamMember>();
    Map<Id,CaseTeamTemplateRecord> newPredefinedCaseTeamMap = new Map<Id,CaseTeamTemplateRecord>(); 
    Id cirRepQueueId;
    Id csoAdminTeamId;
    Cir_Planner_Schedule__c c;
    Map<Id, Case> casesToUpdateMap = new Map<Id, Case>(); //START-END D-4076 12-10-2015 added by Jason A. for code review
    String days;
    Set<Id> allCaseIds = new Set<Id>();
    List<Case> updateCases = new List<Case>();
    //START: D-3140 20/06/2015 Added by S.Puli
    List<Case> tempStopToUpdate_LIST = new List<Case>();
    List<Case> tempWithCoaToUpdate_LIST = new List<Case>();
    //END: D-3140 20/06/2015 Added by S.Puli
    
     //START 18/02/15 Wenjun : Fix Code Bug - Incorrect referring to CaseTriggerHandler
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !CaseVendorSubscriptionTriggerHandler.isBeforeInsertTriggerCalled;
        CaseVendorSubscriptionTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !CaseVendorSubscriptionTriggerHandler.isBeforeUpdateTriggerCalled;
        CaseVendorSubscriptionTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !CaseVendorSubscriptionTriggerHandler.isBeforeDeleteTriggerCalled;
        CaseVendorSubscriptionTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !CaseVendorSubscriptionTriggerHandler.isAfterInsertTriggerCalled;
        CaseVendorSubscriptionTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !CaseVendorSubscriptionTriggerHandler.isAfterUpdateTriggerCalled;
        CaseVendorSubscriptionTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !CaseVendorSubscriptionTriggerHandler.isAfterDeleteTriggerCalled;
        CaseVendorSubscriptionTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    //END 18/02/15 Wenjun : Fix Code Bug - Incorrect referring to CaseTriggerHandler

    public void bulkBefore() {
        
        //START: D-3140 20/06/2015 Added by S.Puli
        
        List<Case_Vendor_Subscription__c> checkForVendorTempStop_LIST = new List<Case_Vendor_Subscription__c>();
        List<Case_Vendor_Subscription__c> checkForVendorCOA_LIST = new List<Case_Vendor_Subscription__c>();
        List<Case> checkForVendorTempStopFinal_LIST = new List<Case>();
        Set<Id> coaCaseIds = new Set<Id>();
        Map<Id, Set<Id>> tempToSubsIds_MAP = new Map<Id, Set<Id>>();
        //START D-3727 16-Oct-2015 Added by S.Puli
        Map<Id, Set<Id>> caseVendorSubToVenSub_MAP = new Map<Id, Set<Id>>();
        //END D-3727 16-Oct-2015 Added by S.Puli
        Set<Id> tempStopIds_SET = new Set<Id>();
        List<Case_Vendor_Subscription__c> checkSubsWithCoa_LIST = new List<Case_Vendor_Subscription__c>();
        List<Case> tempStop_LIST = new List<Case>();
        Map<Id, Case> tempIdToCase_MAP = new Map<Id, Case>();
        Set<Id> subsIdSet = new Set<Id>();
        
        Map<Id, Id> checkerMap = new Map<Id,Id>();
        if (trigger.isInsert || trigger.isUpdate){

            for(SObject newCase : Trigger.new) {
                Case_Vendor_Subscription__c caseToCheck = (Case_Vendor_Subscription__c)newCase; 
                if(caseToCheck.Case_Record_Type__c == (Id)ConstantsSLB.getKeyId('Case_Change in Address')){
                    checkForVendorTempStop_LIST.add(caseToCheck);
                }
                if(caseToCheck.Case_Record_Type__c == (Id)ConstantsSLB.getKeyId('Case_Temp Stop')){
                    checkForVendorCOA_LIST.add(caseToCheck);
                    tempStopIds_SET.add(caseToCheck.Case__c);
                }
            }
        }
        if(checkForVendorTempStop_LIST.size()>0){
            for(Case_Vendor_Subscription__c csvrec : checkForVendorTempStop_LIST){
                coaCaseIds.add(csvrec.Case__c);
                //caseVendorSubToVenSub_MAP.put(csvrec.Case__c, csvrec.Subscription_Vendor__c);
            }
            //Start UD-3379 20-Jan-2016 Added By S.Puli
            checkForVendorTempStopFinal_LIST = [Select Id, RecordTypeId, Effective_Date__c, AccountId, Change_of_Address_Type__c, Vendor__c, Vendor__r.RecordType.Name, Vendor__r.Email__c, New_Address__r.Postal_Code__c From Case Where Id IN :coaCaseIds AND RecordTypeId = :ConstantsSLB.getKeyId('Case_Change in Address') AND Effective_Date__c >= TODAY AND (Change_of_Address_Type__c = :GlobalVariableClass.CHANGEVENDOR OR Change_of_Address_Type__c = :GlobalVariableClass.DELIVERYADDLOC OR Change_of_Address_Type__c = :GlobalVariableClass.BILLDELIVERYADD) AND Sub_Status__c != :GlobalVariableClass.SUB_STATUS_COA_REJECTED];
            //End UD-3379 20-Jan-2016 Added By S.Puli
            if(checkForVendorTempStopFinal_LIST.size()>0){
                //START D-3727 16-Oct-2015 Added by S.Puli
                for(Case c : checkForVendorTempStopFinal_LIST){
                    for(Case_Vendor_Subscription__c csvrec : checkForVendorTempStop_LIST){
                        if(c.Id == csvrec.Case__c){
                            if(!caseVendorSubToVenSub_MAP.containsKey(csvrec.Case__c)){
                                caseVendorSubToVenSub_MAP.put(csvrec.Case__c, new Set<Id>{csvrec.Subscription_Vendor__c});
                            }
                            else{
                                caseVendorSubToVenSub_MAP.get(csvrec.Case__c).add(csvrec.Subscription_Vendor__c);
                            }
                        }
                    }
                }
                //END D-3727 16-Oct-2015 Added by S.Puli
            }
            if(checkForVendorTempStopFinal_LIST.size()>0){
                checkForVendorTempStop(checkForVendorTempStopFinal_LIST, caseVendorSubToVenSub_MAP);
            }
        }
        
        if(tempStopIds_SET.size()>0){
            tempStop_LIST = [Select Id, Temp_Stop_Date__c, Restart_Date__c From Case Where Id IN :tempStopIds_SET];
        }
        if(checkForVendorCOA_LIST.size()>0 && tempStop_LIST.size()>0){
            for(Case c : tempStop_LIST){
                tempIdToCase_MAP.put(c.Id, c);
            }
            for(Case_Vendor_Subscription__c cvRec : checkForVendorCOA_LIST){
                subsIdSet.add(cvRec.Subscription_Vendor__c);
                if(!tempToSubsIds_MAP.containsKey(cvRec.Case__c)){
                    tempToSubsIds_MAP.put(cvRec.Case__c, new Set<Id>{cvRec.Subscription_Vendor__c});
                }
                else{
                    tempToSubsIds_MAP.get(cvRec.Case__c).add(cvRec.Subscription_Vendor__c);
                }
            }
            
        }
        Date curDate;
        if(tempToSubsIds_MAP.size()>0 && subsIdSet.size()>0){
            checkSubsWithCoa_LIST = [Select Id,Subscription_Vendor__c,Case__c,Case_Record_Type__c, Case__r.Change_of_Address_Type__c,Case__r.Sub_Status__c, Case__r.Effective_Date__c From Case_Vendor_Subscription__c Where Subscription_Vendor__c IN :subsIdSet AND Case__r.RecordTypeId = :ConstantsSLB.getKeyId('Case_Change in Address') AND (Case__r.Change_of_Address_Type__c = :GlobalVariableClass.CHANGEVENDOR OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.DELIVERYADDLOC OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.BILLDELIVERYADD) AND Case__r.Sub_Status__c != :GlobalVariableClass.SUB_STATUS_WAITING_FOR_COA_APPROVAL AND Case__r.Sub_Status__c != :GlobalVariableClass.SUB_STATUS_COA_REJECTED];

            if(checkSubsWithCoa_LIST.size()>0){
                for(Id temp : tempToSubsIds_MAP.keySet()){
                    for(Id subId : tempToSubsIds_MAP.get(temp)){
                        for(Case_Vendor_Subscription__c cvCoaRec : checkSubsWithCoa_LIST){
                            if(subId == cvCoaRec.Subscription_Vendor__c){
                                if(tempIdToCase_MAP.containsKey(temp)){
                                    for(curDate = tempIdToCase_MAP.get(temp).Temp_Stop_Date__c; curDate <= tempIdToCase_MAP.get(temp).Restart_Date__c; curDate = curDate.addDays(1)){
                                        if(curDate == cvCoaRec.Case__r.Effective_Date__c){
                                            if(!checkerMap.containsKey(temp)){
                                                checkerMap.put(temp, subId);
                                                Case tempWithCoa = tempIdToCase_MAP.get(temp);
                                                tempWithCoa.COA__c = true;
                                                tempWithCoaToUpdate_LIST.add(tempWithCoa);
                                            }
                                        }                                                                               
                                    }
                                }
                                        
                            }
                        }
                    }
                }
            }
        }
        //tempWithCoaToUpdate_LIST
        //END: D-3140 20/06/2015 Added by S.Puli
    }
        
    public void bulkAfter() {
    if (trigger.isInsert){
        
            for(SObject newCase : Trigger.new) {
                Case_Vendor_Subscription__c newCompCase = (Case_Vendor_Subscription__c)newCase;                
                if(newCompCase.Case_Record_Type__c == (Id)ConstantsSLB.getKeyId('Complaint_Newspaper')){                                      
                    //caseIdOpsRep.add(newCompCase.Case__c); 
                    subCaseMap.put(newCompCase.Subscription_Vendor__c,newCompCase.Case__c);                
                    allCaseIds.add(newCompCase.Case__c);
                    if(newCompCase.case_Replacement_Required__c && newCompCase.Case_Within_Cir_Schedule__c){ 
                    caseIdCir.add(newCompCase.Case__c);
                    }                   
                }
                else if(newCompCase.Case_Record_Type__c == (Id)ConstantsSLB.getKeyId('Case_Complaint Magazine') && newCompCase.case_Replacement_Required__c) {
                   caseIdCsoAdmin.add(newCompCase.Case__c);
                   allCaseIds.add(newCompCase.Case__c); 
                }
                                                                                             
            }
                subId = subCaseMap.keySet();
                for( Subscription_Vendor__c subVen : [Select Recipient__c from Subscription_Vendor__c where Id IN: subId]){
                    //START:Code Review Implementation 2/18/15 Added by Manolo Valeña - Checks if subVen.Recipient__c is not equal to null.
                    if(subVen.Recipient__c != null){
                        contactCaseMap.put(subVen.Recipient__c,subCaseMap.get(subVen.Id));
                    }
                    //END:Code Review Implementation 2/18/15 Added by Manolo Valeña
                }

                //START:Code Review Implementation 2/18/15 Added by Manolo Valeña - Checks if contactCaseMap is not empty.
                if(contactCaseMap.size() > 0){
                    Set<Id> recipients = contactCaseMap.keySet();
                    List<Integer> sector = new List<Integer>();
                    List<Contact> contacts = [Select Id, Address__r.Postal_Code__r.Name from Contact where Id IN: recipients];
                    for(Contact recipient : contacts){            
                        String subStrPostal = recipient.Address__r.Postal_Code__r.Name.substring(0,2); 
                        //START:Code Review Implementation 2/18/15 Added by Manolo Valeña - Checks if subStrPostal is not equal to null.
                        if(subStrPostal != null){
                            sector.add(integer.valueOf(subStrPostal));
                            sectorCase.put(integer.valueOf(subStrPostal),contactCaseMap.get(recipient.Id));
                        }
                        //END:Code Review Implementation 2/18/15 Added by Manolo Valeña
                    }
                    
                    //START:Code Review Implementation 2/18/15 Added by Manolo Valeña - Checks if sector is not empty.
                    if(sector.size() > 0){
                        vendorOps = [Select Postal_Sector_Code__c, Vendor_Ops__c from Post_Sector_Ops_Rep_Mapping__c where Postal_Sector_Code__c IN: sector];
                        for (Post_Sector_Ops_Rep_Mapping__c opsRepMap : vendorOps){
                            //START:Code Review Implementation 2/18/15 Added by Manolo Valeña - Prevents code inside if statement to run if values are null.
                            if(sectorCase.containsKey(integer.valueOf(opsRepMap.Postal_Sector_Code__c)) && opsRepMap.Vendor_Ops__c != null){
                                newCaseTeam.put(sectorCase.get(integer.valueOf(opsRepMap.Postal_Sector_Code__c)),opsRepMap.Vendor_Ops__c);              
                                System.debug('line 133');
                            }
                            //END:Code Review Implementation 2/18/15 Added by Manolo Valeña
                        }
                        caseIds = newCaseTeam.keySet();
                    }
                    //END:Code Review Implementation 2/18/15 Added by Manolo Valeña
                }
                //END:Code Review Implementation 2/18/15 Added by Manolo Valeña
            }
            if (caseIdCir.size() > 0){
                CaseTeamTemplate cirRepTeam = [Select id from CaseTeamTemplate where Name =: ConstantsSLB.getKeyId('Cir Predefined Case Team')LIMIT 1];
                cirRepQueueId = cirRepTeam.id;
                System.debug('line 141');
           }
            if (caseIdCsoAdmin.size() > 0){
                CaseTeamTemplate csoAdminTeam = [Select id from CaseTeamTemplate where Name =: ConstantsSLB.getKeyId('CSO Predefined Case Team')LIMIT 1];
                csoAdminTeamId = csoAdminTeam.id;
                System.debug('line 146');
            }                                                                               
        }            
          
    public void beforeInsert(SObject so) {
        
    }
        
    public void beforeUpdate(SObject oldSo, SObject so) {
        
    }
    
    public void beforeDelete(SObject so) {
        
    }
    
    public void afterInsert(SObject so) {
         Set<Id> teamMemberIds = new Set<Id>();
         List<CaseTeamMember> newCaseTeamAdd = new List<CaseTeamMember>();
             
             if (caseIds.size() > 0){
                for (Id caseIdOpsRep : caseIds ){
                CaseTeamMember newMember = new CaseTeamMember();
                newMember.ParentId = caseIdOpsRep;
                newMember.MemberId = newCaseTeam.get(caseIdOpsRep);
                newMember.TeamRoleId = ConstantsSLB.getKeyId('Vendor Rep Role'); 
                newCaseTeamMap.put(newCaseTeam.get(caseIdOpsRep),newMember);
                system.debug('Vendor Rep------' + newCaseTeamMap);
                } 
            }       
            
            if (caseIdCir.size() > 0){        
                for(Id caseIdCirRep : caseIdCir){
                CaseTeamTemplateRecord newTeam = new CaseTeamTemplateRecord();
                newTeam.ParentId =  caseIdCirRep;
                newTeam.TeamTemplateId = cirRepQueueId;
                newPredefinedCaseTeamMap.put(cirRepQueueId,newTeam);
                system.debug('CIR------' + newPredefinedCaseTeamMap);
                }
            }
            if (caseIdCsoAdmin.size() > 0){          
                for(Id caseIdCsoAd : caseIdCsoAdmin){
                CaseTeamTemplateRecord newCSOTeam = new CaseTeamTemplateRecord();
                newCSOTeam.ParentId =  caseIdCsoAd;
                newCSOTeam.TeamTemplateId = csoAdminTeamId;
                newPredefinedCaseTeamMap.put(csoAdminTeamId,newCSOTeam);
                system.debug('CSO Admin------' + newPredefinedCaseTeamMap);
                }
            }        
         
    }    

    public void afterUpdate(SObject oldSo, SObject so) {

    }

    public void afterDelete(SObject so) {
        
    }

    public void andFinally() {     
        try{
            //START: D-3140 20/06/2015 Added by S.Puli
            if(tempStopToUpdate_LIST.size()>0){
                update tempStopToUpdate_LIST;
            }
            if(tempWithCoaToUpdate_LIST.size()>0){
                update tempWithCoaToUpdate_LIST;
            }
            //END: D-3140 20/06/2015 Added by S.Puli
            if(trigger.isAfter && trigger.isInsert){
            List<Case> updateCaserecords = new List<Case>();
            updateCases = [Select id, Notification_Sent_Indicator__c,RecordTypeID,Replacement_Required__c,Within_Circulation_Planning_Schedule__c from Case where Id IN: allCaseIds];
            for (Case updateCase : updateCases ){
                updateCase.Notification_Sent_Indicator__c = TRUE;
                updateCaserecords.add(updateCase);
            }
            //THIS IS MOVED to below update  updateCaserecords;
            //List<sObject> sObjToInsert = new List<sObject>();
                if(newCaseTeamMap.values().size() > 0){
                   //sObjToInsert.addAll(newCaseTeamMap.values());
                   insert newCaseTeamMap.values();
                }
                if(newPredefinedCaseTeamMap.values().size() > 0){ 
                   //sObjToInsert.addAll(newPredefinedCaseTeamMap.values());
                   insert newPredefinedCaseTeamMap.values();  
                }
                
                update updateCaserecords;
            }
        }catch (exception e){
            
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }

    //START: D-3140 20/06/2015 Added by S.Puli
        //START D-3727 16-Oct-2015 Added by S.Puli
    public void checkForVendorTempStop(List<Case> checkForVendorTemp_LIST, Map<Id,Set<Id>> caseVenSubToSub_MAP){
        
        Set<Id> subCoaIds = new Set<Id>();
        List<Case> tempStopCases_LIST = new List<Case>();
        if(caseVenSubToSub_MAP.size()>0){
            for(Id idString : caseVenSubToSub_MAP.keySet()){
                for(Id subIdString : caseVenSubToSub_MAP.get(idString)){
                    subCoaIds.add(subIdString);
                }
            }
            if(subCoaIds.size()>0){
                tempStopCases_LIST = [Select Id, COA__c, Case_Sub_Status__c, Temp_Stop_Date__c, Restart_Date__c, Temp_Stop_VSub__c, Temp_Stop__r.Temp_Stop_Status__c From Case Where Temp_Stop_VSub__c IN :subCoaIds AND Sub_Status__c <> :GlobalVariableClass.TS_URGENT_APPROVAL_STATUS  AND Temp_Stop__r.Temp_Stop_Status__c != :GlobalVariableClass.COMPLETED AND Temp_Stop__r.Temp_Stop_Status__c != :GlobalVariableClass.TS_STATUS_CANCELLED];
            }
            Date currDate;
            if(tempStopCases_LIST.size()>0){
                if(checkForVendorTemp_LIST.size()>0){
                    for(Case coaCase : checkForVendorTemp_LIST){
                        for(Case tempCase : tempStopCases_LIST){
                            if(caseVenSubToSub_MAP.containskey(coaCase.Id)){
                                //if(caseVenSubToSub_MAP.get(coaCase.Id) == tempCase.Temp_Stop_VSub__c){
                                for(Id subId : caseVenSubToSub_MAP.get(coaCase.Id)){
                                    if(subId == tempCase.Temp_Stop_VSub__c){
                                        for(currDate = tempCase.Temp_Stop_Date__c; currDate <= tempCase.Restart_Date__c; currDate = currDate.addDays(1)){
                                            if(coaCase.Effective_Date__c == currDate){  
                                                tempCase.COA__c = true;
                                                tempStopToUpdate_LIST.add(tempCase);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        //END D-3727 16-Oct-2015 Added by S.Puli
    }
    //END: D-3140 20/06/2015 Added by S.Puli
 }