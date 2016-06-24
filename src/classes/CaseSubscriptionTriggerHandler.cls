/**
 * Class Name: <CaseSubscriptionTriggerHandler>
 * @author: <Jinky Salvador>
 * Date: <8/18/2014>
 * Requirement/Project Name: <SPH>
 * @description<Add Case team member>
 *
 * History: D-2323 Wenjun 23/Feb/2015 - Code Review Fix - SQL 101
 */
 public class CaseSubscriptionTriggerHandler{
    
    Set<Id> caseIdCir = new Set<Id>();
    Set<Id> caseIdOpsRep = new Set<Id>();
    Set<Id> caseIdCsoAdmin = new Set<Id>(); 
    Map<Id,CaseTeamMember> newCaseTeamMap = new Map<Id,CaseTeamMember>();
    Map<Id,CaseTeamTemplateRecord> newPredefinedCaseTeamMap = new Map<Id,CaseTeamTemplateRecord>(); 
    Set<Id> allCaseIds = new Set<Id>();

    //START: MD-61 03/23/2015 Added by S.PULI - COA checkbox
    Set<Id> coaNewCase_SET = new Set<Id>();
    Set<Id> coaNewSet = new Set<Id>();
    List<Case_Subscription__c> coaNewCaseSub_LIST = new List<Case_Subscription__c>();
    //start D-3388 11-Sept-2015 Added by S.Puli
    Map<Id, Set<Id>> coaCaseToSub_MAP = new Map<Id, Set<Id>>();
    //end D-3388 11-Sept-2015 Added by S.Puli
    List<Case> tempStopExt_LIST = new List<Case>();
    List<Case> tempStopToUpdate_LIST = new List<Case>();
    List<Case> coaNewCaseList = new List<Case>();
    Id CASE_COA  = (Id) ConstantsSLB.getKeyId('Case_Change in Address');
    List<Case> coaNewList = new List<Case>();
    //END: MD-61 03/23/2015 Added by S.PULI - COA checkbox
    
    //Before Insert logic - Call separate method for detail processing - Leave Blank for not in use
    public void doBeforeInsert(List<Case_Subscription__c> lstNewCaseSubs)
    {
        // Start UD-1926 VPernicia 07/20/15 
        updateVendorCode(lstNewCaseSubs);
        // End UD-1926 VPernicia 07/20/15  
    }
    
    //After Insert logic - Call separate method for detail processing - Leave Blank for not in use
    public void doAfterInsert(List<Case_Subscription__c> lstNewCaseSubs, Map<Id, Case_Subscription__c> mapNewCaseSubs)
    {
        //START D-1258 Added by Francis Benzon - Adding of case team member  
        addTeamMembers(lstNewCaseSubs);
        //END D-1258 Added by Francis Benzon - Adding of case team member 
        
        //START: MD-61 03/23/2015 Added by S.PULI - COA checkbox
        for(Case_Subscription__c cs : lstNewCaseSubs){
            coaNewCase_SET.add(cs.Case__c);
        }
        if(coaNewCase_SET.size()>0){    
            checkForTempStop(coaNewCase_SET);
        }
     
        //END: MD-61 03/23/2015 Added by S.PULI - COA checkbox
        
        andFinallyAfterInsert();
    }
    
    //Before Update logic - Call separate method for detail processing - Leave Blank for not in use
    public void doBeforeUpdate(List<Case_Subscription__c> lstNewCaseSubs, Map<Id, Case_Subscription__c> mapNewCaseSubs,
                               List<Case_Subscription__c> lstOldCaseSubs, Map<Id, Case_Subscription__c> mapOldCaseSubs)
    {
        // Start UD-1926 VPernicia 07/20/15 
        list<Case_Subscription__c> lstCaseSubisChange = new list<Case_Subscription__c>();
        for (Case_Subscription__c casSub: lstNewCaseSubs) {
            
            if (casSub.Subscription__c != mapOldCaseSubs.get(casSub.id).Subscription__c) {
                lstCaseSubisChange.add(casSub);
            }
        }
        
        if (!lstCaseSubisChange.isEmpty()) {
            updateVendorCode(lstCaseSubisChange);
        }
        // End UD-1926 VPernicia 07/20/15 
    }
    
    // Start UD-1926 VPernicia 07/20/15 
    public void updateVendorCode(List<Case_Subscription__c> lstNewCaseSubs) {
            
        list<id> lstSubID = new list<id>();
        
        for (Case_Subscription__c Subs: lstNewCaseSubs) {
            lstSubID.add(Subs.Subscription__c);
        }
        
        map<id, Zuora__Subscription__c> mapSubVedorCode = new Map<Id, Zuora__Subscription__c>(
                [SELECT Id, Vendor_1__c, Vendor_1__r.Vendor_Code__c FROM Zuora__Subscription__c 
                WHERE Id IN :lstSubID]);    // Start/End UD-2865 13Oct15 JohnD - added Vendor_1__c field
        
        if (!mapSubVedorCode.isEmpty()) {
            for(Case_Subscription__c cs : lstNewCaseSubs){
                // Start UD-2865 13Oct15 JohnD - added null trapping
                if (mapSubVedorCode.get(cs.Subscription__c) != null && mapSubVedorCode.get(cs.Subscription__c).Vendor_1__c != null) {
                    //START D-3851 11/02/2015 Added by J.Sarion - Check Vendor Code if NULL
                    if(mapSubVedorCode.get(cs.Subscription__c).Vendor_1__r.Vendor_Code__c != null){
                        cs.Vendor_Code__c = mapSubVedorCode.get(cs.Subscription__c).Vendor_1__r.Vendor_Code__c;
                    }
                    //END D-3851 11/02/2015 Added by J.Sarion - Check Vendor Code if NULL
                }
                // End UD-2865 13Oct15 JohnD - added null trapping
            }
        }
    }
    // End UD-1926 VPernicia 07/20/15  

    //After Update logic - Call separate method for detail processing - Leave Blank for not in use
    public void doAfterUpdate(List<Case_Subscription__c> lstNewCaseSubs, Map<Id, Case_Subscription__c> mapNewCaseSubs,
                              List<Case_Subscription__c> lstOldCaseSubs, Map<Id, Case_Subscription__c> mapOldCaseSubs)
    {
        //START D-1258 Added by Francis Benzon - Adding of case team member  
        addTeamMembers(lstNewCaseSubs);
        //END D-1258 Added by Francis Benzon - Adding of case team member 
        andFinallyAfterUpdate();
    }
    
    //Before Delete logic - Call separate method for detail processing - Leave Blank for not in use
    public void doBeforeDelete(List<Case_Subscription__c> lstOldCaseSubs, Map<Id, Case_Subscription__c> mapOldCaseSubs)
    {}
    
    //After Delete logic - Call separate method for detail processing - Leave Blank for not in use
    public void doAfterDelete(List<Case_Subscription__c> lstOldCaseSubs, Map<Id, Case_Subscription__c> mapOldCaseSubs)
    {}
    
    private void addTeamMembers(List<Case_Subscription__c> lstNewCaseSubs) {
        Map<Id,Id> subCaseMap = new Map<Id ,Id>(); // Map of SubscriptionId and CaseId
        Map<Id,Integer> mapCaseIdToSector = new Map<Id,Integer>(); // Map of Case ID to Postal Sector
        Map<Integer,Id> mapSectorToOps = new Map<Integer,Id>(); // Map of Postal Sector to Vendor Ops
        Map<Id,Id> newCaseTeam = new Map<Id,Id>(); // CaseID and User 
        Set<Id> caseIdSet = new Set<Id>();
            
        for(Case_Subscription__c newCaseSub : lstNewCaseSubs) {               
            if(newCaseSub.Case_Record_Type_ID__c == (Id)ConstantsSLB.getKeyId(GlobalVariableClass.COMPNEWS)){                                      
                subCaseMap.put(newCaseSub.Subscription__c,newCaseSub.Case__c);
                allCaseIds.add(newCaseSub.Case__c);                
                if(newCaseSub.Case_Replacement_Required__c && newCaseSub.Case_Within_Cir_Schedule__c)
                    caseIdCir.add(newCaseSub.Case__c);                                      
            }
            else if(newCaseSub.Case_Record_Type_ID__c == (Id)ConstantsSLB.getKeyId(GlobalVariableClass.CASECOMPMAG)) { 
                //&& newCaseSub.Case_Replacement_Required__c)  D-2127 02/10/2015 updated by James 
                caseIdCsoAdmin.add(newCaseSub.Case__c);
                allCaseIds.add(newCaseSub.Case__c); 
            }                                                                        
        }    
        
        Set<Id> subIdSet = subCaseMap.keySet();
        if (subIdSet != null && !subIdSet.isEmpty())
        {
            for( Zuora__Subscription__c subDir : [SELECT Id, Recipient_Contact__r.Address__r.Postal_Code__r.Name 
                                                  FROM Zuora__Subscription__c WHERE Id IN: subIdSet])
            {
                if(subDir.Recipient_Contact__r.Address__r.Postal_Code__r.Name != null)
                {
                    String subStrPostal = subDir.Recipient_Contact__r.Address__r.Postal_Code__r.Name.substring(0,2); 
                    Integer postSectorCode = Integer.valueOf(subStrPostal);
                    mapCaseIdToSector.put(subCaseMap.get(subDir.Id), postSectorCode);
                }
            }
            
            for (Post_Sector_Ops_Rep_Mapping__c opsRepMap : [SELECT Postal_Sector_Code__c, Vendor_Ops__c 
                            FROM Post_Sector_Ops_Rep_Mapping__c WHERE Postal_Sector_Code__c IN: mapCaseIdToSector.values()])
            {
                mapSectorToOps.put(Integer.valueOf(opsRepMap.Postal_Sector_Code__c), opsRepMap.Vendor_Ops__c);
            }
            
            for(Id subId : subIdSet)
            {
                Id caseId = subCaseMap.get(subId);
                if(mapCaseIdToSector.containsKey(caseId))
                {
                    Integer intCode = mapCaseIdToSector.get(caseId);
                    if(mapSectorToOps.containsKey(intCode))
                        newCaseTeam.put(caseId, mapSectorToOps.get(intCode));
                }
            }
            caseIdSet = newCaseTeam.keySet(); 
       }

        //START D-1258 Added by Francis Benzon - Adding of case team member
        if (!caseIdSet .isEmpty()){
            for (Id caseIdOpsRep : caseIdSet){
            CaseTeamMember newMember = new CaseTeamMember();
            newMember.ParentId = caseIdOpsRep;   
            newMember.MemberId = newCaseTeam.get(caseIdOpsRep);
            newMember.TeamRoleId = ConstantsSLB.getKeyId('Vendor Rep Role');                 
            newCaseTeamMap.put(newCaseTeam.get(caseIdOpsRep),newMember);
            }              
        }       

        if (!caseIdCir.isEmpty()){
            CaseTeamTemplate cirRepTemplate = [SELECT id FROM CaseTeamTemplate 
                                               WHERE Name =: ConstantsSLB.getKeyId('Cir Predefined Case Team') LIMIT 1];
            
            for(Id caseIdCirRep : caseIdCir){
                CaseTeamTemplateRecord newTeam = new CaseTeamTemplateRecord();
                newTeam.ParentId =  caseIdCirRep;
                newTeam.TeamTemplateId = cirRepTemplate.id;
                newPredefinedCaseTeamMap.put(cirRepTemplate.id,newTeam);
            }
        }
        
        if (!caseIdCsoAdmin.isEmpty()){
            CaseTeamTemplate csoAdminTemplate = [SELECT id FROM CaseTeamTemplate 
                                                WHERE Name =: ConstantsSLB.getKeyId('CSO Predefined Case Team')LIMIT 1];
            for(Id caseIdCsoAd : caseIdCsoAdmin){
                CaseTeamTemplateRecord newCSOTeam = new CaseTeamTemplateRecord();
                newCSOTeam.ParentId =  caseIdCsoAd;
                newCSOTeam.TeamTemplateId = csoAdminTemplate.id;
                newPredefinedCaseTeamMap.put(csoAdminTemplate.id,newCSOTeam);
            }
        }        
        //END D-1258 Added by Francis Benzon - Adding of case team member       
    }      
    
    public void andFinallyAfterInsert() //START/END: MD-61 03/25/2015 Added by S.PULI 
    {  
        if(newCaseTeamMap.values().size() > 0)
           database.insert(newCaseTeamMap.values(), false); //START/END UD-2722 09/14/15 RReyes - changed to database.insert

        if(newPredefinedCaseTeamMap.values().size() > 0)
           database.insert(newPredefinedCaseTeamMap.values(), false);  //START/END UD-2722 09/14/15 RReyes - changed to database.insert
     
        if (!allCaseIds.isEmpty()) 
        { 
            List<Case> lstCasesToUpd = new List<Case>();  
            for (Case updateCase : [Select id, Notification_Sent_Indicator__c,RecordTypeID,Replacement_Required__c,
                                      Within_Circulation_Planning_Schedule__c from Case where Id IN: allCaseIds] )
            {
                updateCase.Notification_Sent_Indicator__c = TRUE;
                lstCasesToUpd.add(updateCase);
            }
            
            if(!lstCasesToUpd.isEmpty())
                UPDATE lstCasesToUpd;
        }
        //START: MD-61 03/25/2015 Added by S.PULI
        if(tempStopToUpdate_LIST.size()>0){
            update tempStopToUpdate_LIST;
        }
        //END: MD-61 03/25/2015 Added by S.PULI
    }
    
    private void andFinallyAfterUpdate() {    
        try
        { 
            //Start D-2127 02/10/2015 Added by James - Add case team member after update
            if(newPredefinedCaseTeamMap.values().size() > 0){ 
               INSERT newPredefinedCaseTeamMap.values();  
            }
            //End D-2127
        }
        Catch(Exception e)
        {
            System.debug(LoggingLevel.WARN, 'Error when creating new Case Team');
        }
    }
    
    //START: MD-61 03/25/2015 Added by S.PULI 
    /*
     * @description : method to check for Temp Stop case
     * @param : list of COA case for checking
     * @return : none 
     */

    public void checkForTempStop(Set<Id> coaIdSet){  
        //START PD-0359 13Jun2016 Added By C. Lin - Excluded Void Cases
        //START D-3388 11-Sept-2015 Added By S.Puli
        //Start UD-3379 20-Jan-2016 Added By S.Puli
        coaNewList = [Select Id, RecordTypeId, Effective_Date__c, AccountId, Change_of_Address_Type__c From Case Where Id IN :coaIdSet AND RecordTypeId = :CASE_COA AND Effective_Date__c >= TODAY AND (Change_of_Address_Type__c = :GlobalVariableClass.CHANGEVENDOR OR Change_of_Address_Type__c = :GlobalVariableClass.DELIVERYADDLOC OR Change_of_Address_Type__c = :GlobalVariableClass.BILLDELIVERYADD) AND Status != :GlobalVariableClass.STATUS_VOID];
        //End UD-3379 20-Jan-2016 Added By S.Puli
        //END PD-0359 13Jun2016 Added By C. Lin
        if(coaNewList.size()>0){
            for(Case c : coaNewList){
                if(c.Change_of_Address_Type__c == GlobalVariableClass.CHANGEVENDOR || c.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC || c.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD){
                    coaNewCaseList.add(c);
                }
            }
        }
        
        for(Case c : coaNewCaseList){
            coaNewSet.add(c.Id);
        }
        Set<Id> subsIdSet = new Set<Id>();
        //START PD-0288 10Jun2016 Added By C. Lin - Added Billing_Address_Change_Only__c
        coaNewCaseSub_LIST = [Select Id, Case__c, Case__r.Effective_Date__c, Subscription__c, Billing_Address_Change_Only__c From Case_Subscription__c Where Case__c IN :coaNewSet];
        //END PD-0288 10Jun2016 Added By C. Lin
        system.debug('coaNewCaseSub_LIST>>>'+coaNewCaseSub_LIST);
        if(coaNewCaseSub_LIST.size()>0){
            for(Case_Subscription__c cs : coaNewCaseSub_LIST){
                //START PD-0288 10Jun2016 Added By C. Lin - Exclude Case Sub with Billing Address == true
                if(cs.Billing_Address_Change_Only__c == false){
                    if(!coaCaseToSub_MAP.containsKey(cs.Case__c)){
                        coaCaseToSub_MAP.put(cs.Case__c, new Set<Id>{cs.Subscription__c});
                    }
                    else{
                        coaCaseToSub_MAP.get(cs.Case__c).add(cs.Subscription__c);
                    }
                    subsIdSet.add(cs.Subscription__c);
                }
                //END PD-0288 10Jun2016 Added By C. Lin
            }
        }
        
        tempStopExt_LIST = [Select Id, COA__c, Case_Sub_Status__c, Temp_Stop_Date__c, Restart_Date__c, Temp_Stop_Sub__c, Temp_Stop__r.Temp_Stop_Status__c From Case Where Temp_Stop_Sub__c IN :subsIdSet AND Sub_Status__c <> :GlobalVariableClass.TS_URGENT_APPROVAL_STATUS  AND Temp_Stop__r.Temp_Stop_Status__c != :GlobalVariableClass.COMPLETED AND Temp_Stop__r.Temp_Stop_Status__c != :GlobalVariableClass.TS_STATUS_CANCELLED];
        Date currDate;
        if(tempStopExt_LIST.size()>0){
            for(Case c : tempStopExt_LIST){
                for(Case coa : coaNewCaseList){
                    if(coaCaseToSub_MAP.containsKey(coa.Id)){
                        for(Id subId : coaCaseToSub_MAP.get(coa.Id)){
                            if(c.Temp_Stop_Sub__c == subId){
                                for(currDate = c.Temp_Stop_Date__c; currDate <= c.Restart_Date__c; currDate = currDate.addDays(1)){
                                    if(coa.Effective_Date__c == currDate){
                                        c.COA__c = true;
                                        tempStopToUpdate_LIST.add(c);
                                    }
                                }   
                            }
                        }
                    }
                }
            }
        }
        //END D-3388 11-Sept-2015 Added By S.Puli
    }
    //END: MD-61 03/24/2015 Added by S.PULI 
 }