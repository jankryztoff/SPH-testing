/**
     * Class Name: ComplaintMagazineExtensionEdit 
     * @author: Karl Tan
     * Date: 8/4/2014
     * Requirement/Project Name: <SPH>
     * @description Extension Controller for ComplaintMagazineEditPage 
     * History : 2/16/2015 - Joban - Code Review Activity : Modified code to prevent SOQL errors
     */
     //START: D-3051 K. Tan  - to remove class sharing syntax

public class ComplaintMagazineExtensionEdit {
     //END: D-3051 K. Tan  - to remove class sharing syntax
    //START UD-1629 JLedesma 6/24/2015 validates subscription selected.     
    Integer indexVal = 0;
    String mag = 'M';
    Map<Id, List<Package_Item__c>> subToPackageItems = new Map<Id, List<Package_Item__c>>();
    Map<Id, List<Subscription_Vendor_Publication__c>> subToSubVen = new Map<Id, List<Subscription_Vendor_Publication__c>>();
    List<Package_Item__c> pckItems = new List<Package_Item__c>();
    List<Subscription_Vendor_Publication__c> subVenRecs = new List<Subscription_Vendor_Publication__c>();
    Integer magazineCounter = 0;
  List<Integer> magazineCount;
    Boolean packageIsMagazine = FALSE;
    //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 
    public Case cas {get;set;}     
    public List<WrapCaseSubscription> wrapCaseSubList {get;set;} 
    public Integer counter{get;set;}
    public Boolean isDirect{get;set;}
    Account acc = new Account(); 
    Set<Id> caseSubId = new Set<Id>();
    Set<Id> caseVenSubId = new Set<Id>();
    Id csPrimaryAddressId, cvsPrimaryAddressId;
    String acctId;
    String recType;
    String casId;
    String conId;    
    
    //Start D-1992 1/30/2015 Added by James Aza?a - get current user profile
    Id profileId = userinfo.getProfileId();
    String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
    String CSOAdminProfile = ConstantsSLB.getOther('CSO Admin');
    //End D-1992 1/30/2015 Added by James Aza?a
    
    //START: UD-0775 04/08/2015 Added by S.PULI
    Set<Id> subId_SET = new Set<Id>();
    Set<Id> subVenId_SET = new Set<Id>();
    //END: UD-0775 04/08/2015 Added by S.PULI
    
    //START UD-0707 AddedBy FrancisBenzon : variable - parentCase
    public string parentCaseId;
    //END UD-0707 AddedBy FrancisBenzon : variable - parentCase
    
    public ComplaintMagazineExtensionEdit(ApexPages.StandardController controller) {
        acctId = ApexPages.currentPage().getParameters().get('accountId');   
        recType = ApexPages.currentPage().getParameters().get('RecordType');    
        casId = ApexPages.currentPage().getParameters().get('id');
        conId = ApexPages.currentPage().getParameters().get('contactId'); 
        //START UD-0707 5/7/15 AddedBy FrancisBenzon : parent Case
        parentCaseId = ApexPages.currentPage().getParameters().get('def_parent_id');
        //END UD-0707 5/7/15 AddedBy FrancisBenzon : parent Case
        wrapCaseSubList = new List<WrapCaseSubscription>();
        counter = 0;
        isDirect = TRUE;
        if(casId != NULL && casId != '' && casId != 'null') {//edit mode
            this.cas = (Case)controller.getRecord();
            if(cas.AccountId != Null) {
        
                try {
                    acc = [SELECT RecordType.Name FROM Account WHERE Id = :cas.AccountId];
                    if(acc.RecordType.Name == 'Vendor Subscriber' || acc.RecordType.Name == 'Vendor') {
                        isDirect = FALSE;
                    }
                    else {
                        isDirect = TRUE;
                    }
                    //START D-2962 KEstoya / Change enquiry to complaint
                    if(recType != null || recType != ' ')
                    {
                        cas.RecordTypeId = (Id) recType;
                        cas.Category__c = 'Magazine';
                    }
                    //END D-2962 KEstoya / Change enquiry to complaint
                }
                catch(QueryException e) {
                    acc = new Account();
                }
        
            }   
            List<Case_Subscription__c> cSubs = new List<Case_Subscription__c>(); // 2/16/2015 - Joban - Code Review Activity : Added null check
            if(casId!=null){ // 2/16/2015 - Joban - Code Review Activity : Added null check
                //START UD-2486 8/22/2015 Added by C. Lin - Added Package_Name__c
                cSubs = [SELECT Id, Subscription__c, Complaint_From__c, Complaint_To__c, Replace_From__c, Replace_To__c, 
                                                    Month__c, Year__c, Issue_No__c, Account__c, Subscription__r.Recipient_Contact__r.Address__c, Address__c, Package_Name__c  
                                                    FROM Case_Subscription__c WHERE Case__c = :casId ORDER BY CreatedDate ASC];
                //END UD-2486 8/22/2015 Added by C. Lin
            }
            if (!cSubs.isEmpty()) csPrimaryAddressId = cSubs[0].Subscription__r.Recipient_Contact__r.Address__c; 
            for(Case_Subscription__c cs : cSubs) {
                WrapCaseSubscription csWrap = new WrapCaseSubscription(cs);
                counter++;
                csWrap.counterWrap = counter;
                wrapCaseSubList.add(csWrap);
            }
            List<Case_Vendor_Subscription__c> cVenSubs = new List<Case_Vendor_Subscription__c>();  // 2/16/2015 - Joban - Code Review Activity : Added null check
            if(casId!=null){ // 2/16/2015 - Joban - Code Review Activity : Added null check
                cVenSubs = [SELECT Id, Subscription_Vendor__c, Complaint_From__c, Complaint_To__c, Replace_From__c, Replace_To__c, 
                                                              Month__c, Year__c, Issue_No__c, Account__c, Subscription_Vendor__r.Recipient__r.Address__c, Address__c 
                                                              FROM Case_Vendor_Subscription__c WHERE Case__c = :casId ORDER BY CreatedDate ASC];
            }
            if (!cVenSubs.isEmpty()) cvsPrimaryAddressId = cVenSubs[0].Subscription_Vendor__r.Recipient__r.Address__c; 
            for(Case_Vendor_Subscription__c cvs : cVenSubs) {
                WrapCaseSubscription csWrap = new WrapCaseSubscription(cvs);
                counter++;
                csWrap.counterWrap = counter;
                wrapCaseSubList.add(csWrap); 
            }        
        }
        else {//new case
            cas = (Case)controller.getRecord(); 
            cas.RecordTypeId = (recType != '' && recType != 'null' ? recType : NULL);
            cas.AccountId = (acctId != '' && acctId != 'null' ? acctId : NULL);
            cas.ContactId = (conId != '' && conId != 'null' ? conId : NULL);
            
            //START UD-3293 25Nov2015 Added By C. Lin
            if(parentCaseId != null && parentCaseId != ''){
                Case pCase = [SELECT Id, Subject, Description FROM Case WHERE Id = :parentCaseId LIMIT 1];
                
                cas.Subject = pCase.Subject;
                cas.Description = pCase.Description;
            }
            //END UD-3293 25Nov2015 Added By C. Lin
            
                try {
                    if(acctId!=null){  // 2/16/2015 - Joban - Code Review Activity : Added null check
                        acc = [SELECT RecordType.Name FROM Account WHERE Id =:acctId];
                    }
                    if(acc.RecordType.Name == 'Vendor Subscriber' || acc.RecordType.Name == 'Vendor') {
                        isDirect = FALSE;
                    }
                    else {
                        isDirect = TRUE;
                    }
                }
                catch(QueryException e) {
                    acc = new Account();
                }
            if(isDirect) {
                WrapCaseSubscription csWrap = new WrapCaseSubscription(new Case_Subscription__c(),cas.AccountId);
                csWrap.caseVenSubs = new Case_Vendor_Subscription__c();
                counter++;
                csWrap.counterWrap = counter;
                wrapCaseSubList.add(csWrap);
            }
            else {
                WrapCaseSubscription csWrap = new WrapCaseSubscription(new Case_Vendor_Subscription__c(),cas.AccountId);
                csWrap.caseSubs = new Case_Subscription__c();
                counter++;
                csWrap.counterWrap = counter;
                wrapCaseSubList.add(csWrap);
            }
        }

    //START: UD-0653 03/30/2015 RReyes - Sets isComplaint to true for filtering subscription 
       for(WrapCaseSubscription wrapCas : wrapCaseSubList) {
                wrapCas.setIsComplaintTrue();
            }   
    //END: UD-0653 03/30/2015 RReyes        
            
    }
    
    public PageReference addRow(){
        //Start D-1992 1/30/2015 Added by James Aza?a - restrict CSO Admin from adding subscription
        if(profileName == CSOAdminProfile){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('CSO Admin Edit Complaint Magazine')));
        }else{
        Id addressId;
        if(isDirect) {    
            WrapCaseSubscription csWrap = new WrapCaseSubscription(new Case_Subscription__c(), cas.AccountId);
            try {
                if(wrapCaseSubList[0].caseSubs.Subscription__c!=null){ // 2/16/2015 - Joban - Code Review Activity : Added null check
                    addressId = [SELECT Recipient_Contact__r.Address__c FROM Zuora__Subscription__c 
                                 WHERE Id = :wrapCaseSubList[0].caseSubs.Subscription__c].Recipient_Contact__r.Address__c;
                }
            } catch (Exception e) {}
            if (addressId <> null) {
                
                csWrap.caseSubs.Address__c = addressId;
            }
            counter++;
            csWrap.counterWrap = counter; 
            wrapCaseSubList.add(csWrap); 
            return null;
        }
        
        else {    
            WrapCaseSubscription csWrap = new WrapCaseSubscription(new Case_Vendor_Subscription__c(), cas.AccountId);
            try {
                if(wrapCaseSubList[0].caseVenSubs.Subscription_Vendor__c!=null){ // 2/16/2015 - Joban - Code Review Activity : Added null check
                    addressId = [SELECT Recipient__r.Address__c FROM Subscription_Vendor__c 
                                 WHERE Id = :wrapCaseSubList[0].caseVenSubs.Subscription_Vendor__c].Recipient__r.Address__c;
                }
            } 
            catch (Exception e) {
            }
            if (addressId <> null) {
                
                csWrap.caseVenSubs.Address__c = addressId;
            }
            
            
            counter++;
            csWrap.counterWrap = counter; 
            wrapCaseSubList.add(csWrap); 
        }    
    }
        return null;
    }
        //End D-1992 1/30/2015 Added by James Aza?a     
    
    public PageReference removeRow(){
        //Start D-1992 1/30/2015 Added by James Aza?a - restrict CSO Admin from removing subscription
        if(profileName == CSOAdminProfile){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('CSO Admin Edit Complaint Magazine')));
        }else{
        Integer param = Integer.valueOf(Apexpages.currentpage().getParameters().get('index'));        
        for(Integer i=0; i<wrapCaseSubList.size(); i++){
            if(wrapCaseSubList[i].counterWrap == param ){
                if(isDirect){
                    caseSubId.add(wrapCaseSubList[i].caseSubs.Id);
                }
                else{
                    caseVenSubId.add(wrapCaseSubList[i].caseVenSubs.Id);
                }
                wrapCaseSubList.remove(i);     
            }
        }        
        counter--;
        }
        return null;    
    }
        //End D-1992 1/30/2015 Added by James Aza?a     
    


    public PageReference save(){
        if(recType != null && recType != '') {
            cas.RecordTypeId = recType;
        }
      
        Savepoint sp = Database.setSavepoint();
        Boolean isNewRecord = false;
        //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
        magazineCounter = 0;
        //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 
        try{
            if(cas.id == null){
            
                //START: UD-0775 04/08/2015 Added by S.PULI
                //direct account
                if(wrapCaseSubList.size()>0){
                    for(WrapCaseSubscription csWrap : wrapCaseSubList){
                        subId_SET.add(csWrap.caseSubs.Subscription__c);
                    }
                }
                //START UD-1827 8/31/15 AddedBy francisBenzon : checked if any subs are future dated
                List<Zuora__Subscription__c> subSelected_LIST = [Select Id, Name, Zuora__SubscriptionStartDate__c From Zuora__Subscription__c Where Id IN :subId_SET];
                Set<Date> futureDatesOfSubs = new Set<Date>(); 
                for(Zuora__Subscription__c SubscriptionLoop1 : subSelected_LIST){                                   
                    if(SubscriptionLoop1.Zuora__SubscriptionStartDate__c > date.today())
                    {
                        futureDatesOfSubs.add(SubscriptionLoop1.Zuora__SubscriptionStartDate__c);
                    }                                  
                }
                if(futureDatesOfSubs.size() > 0)
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('ComplaintErrorForFutureDateSubs')));                                                  
                    subSelected_LIST = new List<Zuora__Subscription__c>();
                    subId_SET = new Set<Id>();
                    database.rollback(sp);
                    return null;
                }
                //END UD-1827 8/31/15 AddedBy francisBenzon : checked if any subs are future dated 
                //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                //START UD-2717 09/10/15 RReyes - added condition to filter out void cases
                    List<Case_Subscription__c> casSub_LIST = [Select Id, Case__c, Subscription__c, Complaint_From__c, Complaint_To__c, Case__R.Status 
                    From Case_Subscription__c 
                    Where Subscription__c IN :subId_SET AND Case__r.RecordTypeId = :recType AND Case__R.Status !=: GlobalVariableClass.STATUS_VOID];
                //END UD-2717 09/10/15 RReyes - added condition to filter out void cases
                //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                
                Map<Id, List<Case_Subscription__c>> subIdToCasSubRec_MAP = new Map<Id, List<Case_Subscription__c>>();
                boolean checker = false;
                
                if(casSub_LIST.size()>0){
                    for(Case_Subscription__c cs : casSub_LIST){
                        if(subIdToCasSubRec_MAP.containskey(cs.Subscription__c)){
                            subIdToCasSubRec_MAP.get(cs.Subscription__c).add(cs);
                        } else{
                            subIdToCasSubRec_MAP.put(cs.Subscription__c, new List<Case_Subscription__c>{cs});
                        }
                    }                       
                }
                
                if(wrapCaseSubList.size()>0){
        //START UD-1629 JLedesma 6/24/2015 
          magazineCount = new List<Integer>();
        //END UD-1629 JLedesma 6/24/2015
                    for(WrapCaseSubscription csWrap : wrapCaseSubList){
                        if(subIdToCasSubRec_MAP.containskey(csWrap.caseSubs.Subscription__c)){
                            for(Case_Subscription__c csRec : subIdToCasSubRec_MAP.get(csWrap.caseSubs.Subscription__c)){
                                if(csRec.Complaint_From__c <> null && csRec.Complaint_To__c <> null){
                                    if((csRec.Complaint_From__c<csWrap.caseSubs.Complaint_From__c && csRec.Complaint_To__c<csWrap.caseSubs.Complaint_From__c)||(csRec.Complaint_From__c>csWrap.caseSubs.Complaint_To__c )){
                                    
                                    } else{
                                        checker = true;
                                        break;
                                    }
                                }
                            }
                        }
                        //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                        magazineCounter = 0;
                        if(subToPackageItems.containskey(csWrap.caseSubs.Subscription__c)){
                            pckItems = subToPackageItems.get(csWrap.caseSubs.Subscription__c);
                            
                            if(pckItems.size() > 0){
                                for(Package_Item__c p : pckItems){
                                    if(p.Is_Magazine__c == TRUE){
                                        magazineCounter++;
                                    }
                                }
                            }
              
              if(magazineCounter == 0){
                magazineCount.add(magazineCounter);
              }
              
                        }
                    //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                    }
                }
                
                if(checker==true){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('OverlappingPeriod'));
                    ApexPages.addMessage(myMsg);
                    return null;
                }
                
                //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                if(isDirect && magazineCount.size() > 0){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('Validate Complaint- Magazine'));
                    ApexPages.addMessage(myMsg);
                    return null;
                }
                //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                
                //Vendor accounts
                if(wrapCaseSubList.size()>0){
                    for(WrapCaseSubscription csWrap : wrapCaseSubList){
                        subVenId_SET.add(csWrap.caseVenSubs.Subscription_Vendor__c);
                    }
                }
                List<Subscription_Vendor__c> subVenSelected_LIST = [Select Id, Name From Subscription_Vendor__c Where Id IN :subVenId_SET];
                
                //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                //START UD-2717 09/10/15 RReyes - added condition to filter out void cases
                    List<Case_Vendor_Subscription__c> casSubVen_LIST = [Select Id, Case__c, Subscription_Vendor__c, Complaint_From__c, Complaint_To__c , Case__R.Status 
                    From Case_Vendor_Subscription__c 
                    Where Subscription_Vendor__c IN :subVenId_SET AND Case__r.RecordTypeId = :recType AND Case__R.Status !=: GlobalVariableClass.STATUS_VOID];
                //END UD-2717 09/10/15 RReyes - added condition to filter out void cases
                //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                
                Map<Id, List<Case_Vendor_Subscription__c>> subVenIdToCasSubRec_MAP = new Map<Id, List<Case_Vendor_Subscription__c>>();
                boolean checkerVen = false;
                
                if(casSubVen_LIST.size()>0){
                    for(Case_Vendor_Subscription__c cs : casSubVen_LIST){
                        if(subVenIdToCasSubRec_MAP.containskey(cs.Subscription_Vendor__c)){
                            subVenIdToCasSubRec_MAP.get(cs.Subscription_Vendor__c).add(cs);
                        } else{
                            subVenIdToCasSubRec_MAP.put(cs.Subscription_Vendor__c, new List<Case_Vendor_Subscription__c>{cs});
                        }
                    }                       
                }
                
                if(wrapCaseSubList.size()>0){
                    for(WrapCaseSubscription csWrap : wrapCaseSubList){
                        if(subVenIdToCasSubRec_MAP.containskey(csWrap.caseVenSubs.Subscription_Vendor__c)){
                            for(Case_Vendor_Subscription__c csRec : subVenIdToCasSubRec_MAP.get(csWrap.caseVenSubs.Subscription_Vendor__c)){
                                if(csRec.Complaint_From__c <> null && csRec.Complaint_To__c <> null){
                                    if((csRec.Complaint_From__c<csWrap.caseVenSubs.Complaint_From__c && csRec.Complaint_To__c<csWrap.caseVenSubs.Complaint_From__c)||(csRec.Complaint_From__c>csWrap.caseVenSubs.Complaint_To__c )){
                                    
                                    } else{
                                        checkerVen = true;
                                        break;
                                    }
                                }
                            }
                        }

                        //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                        if(subToSubVen.containskey(csWrap.caseVenSubs.Subscription_Vendor__c)){
                            subVenRecs  = subToSubVen.get(csWrap.caseVenSubs.Subscription_Vendor__c);
                        }
                    }
                }
                
                if(!isDirect && subVenRecs.size() == 0){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('Validate Complaint- Magazine'));
                    ApexPages.addMessage(myMsg);
                    return null;
                }
                //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                
                if(checkerVen==true){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('OverlappingPeriod'));
                    ApexPages.addMessage(myMsg);
                    return null;
                }
                
                //END: UD-0775 04/08/2015 Added by S.PULI
                //START UD-0707 5/7/15 AddedBy FrancisBenzon : relate case to parentCase
                if(parentCaseId != null || parentCaseId != '')
                {
                    cas.parentId = parentCaseId;
                }
                //END UD-0707 5/7/15 AddedBy FrancisBenzon : relate case to parentCase
                insert cas;  
                isNewRecord = true;
            }
            else{
            
                //START: UD-0775 04/08/2015 Added by S.PULI
                //direct account
                if(wrapCaseSubList.size()>0){
                    for(WrapCaseSubscription csWrap : wrapCaseSubList){
                        subId_SET.add(csWrap.caseSubs.Subscription__c);
                    }
                }
                List<Zuora__Subscription__c> subSelected_LIST = [Select Id, Name From Zuora__Subscription__c Where Id IN :subId_SET];
                
                //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                //START UD-2717 09/10/15 RReyes - added condition to filter out void cases
                    List<Case_Subscription__c> casSub_LIST = [Select Id, Case__c, Subscription__c, Complaint_From__c, Complaint_To__c, Case__R.Status 
                    From Case_Subscription__c 
                    Where Subscription__c IN :subId_SET AND Case__r.RecordTypeId = :recType AND Case__R.Status !=: GlobalVariableClass.STATUS_VOID];
                //END UD-2717 09/10/15 RReyes - added condition to filter out void cases
                //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                
                Map<Id, List<Case_Subscription__c>> subIdToCasSubRec_MAP = new Map<Id, List<Case_Subscription__c>>();
                boolean checker = false;

                //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                packageIsMagazine = false;
                //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                
                if(casSub_LIST.size()>0){
                    for(Case_Subscription__c cs : casSub_LIST){
                        if(subIdToCasSubRec_MAP.containskey(cs.Subscription__c)){
                            subIdToCasSubRec_MAP.get(cs.Subscription__c).add(cs);
                        } else{
                            subIdToCasSubRec_MAP.put(cs.Subscription__c, new List<Case_Subscription__c>{cs});
                        }
                    }                       
                }
                
                //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                if(wrapCaseSubList.size()>0){               
          magazineCount = new List<Integer>();
                    for(WrapCaseSubscription csWrap : wrapCaseSubList){
                        if(subToPackageItems.containskey(csWrap.caseSubs.Subscription__c)){
                            pckItems = subToPackageItems.get(csWrap.caseSubs.Subscription__c);
                            if(pckItems.size() > 0){
                                for(Package_Item__c p : pckItems){
                                    if(p.Is_Magazine__c == TRUE){
                                        magazineCounter++;
                                    }
                                }
                
                if(magazineCounter == 0){
                  magazineCount.add(magazineCounter);
                }
                            }
                        }
                //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                        
                        if(subIdToCasSubRec_MAP.containskey(csWrap.caseSubs.Subscription__c)){
                            for(Case_Subscription__c csRec : subIdToCasSubRec_MAP.get(csWrap.caseSubs.Subscription__c)){
                                if(csRec.Id<>csWrap.caseSubs.Id){
                                    if(csRec.Complaint_From__c <> null && csRec.Complaint_To__c <> null){
                                        if((csRec.Complaint_From__c<csWrap.caseSubs.Complaint_From__c && csRec.Complaint_To__c<csWrap.caseSubs.Complaint_From__c)||(csRec.Complaint_From__c>csWrap.caseSubs.Complaint_To__c )){
                                        
                                        } else{
                                            checker = true;
                                            break;
                                        }
                                    }
                                }
                            }
                //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                        }   
                    }
                }
                
                if(isDirect && magazineCount.size() > 0){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('Validate Complaint- Magazine'));
                    ApexPages.addMessage(myMsg);
                    return null;
                }
                
                if(checker==true){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('OverlappingPeriod'));
                    ApexPages.addMessage(myMsg);
                    return null;
                }
                //END UD-1629 JLedesma 6/24/2015 validates subscription selected.                 
                
                
                //Vendor accounts
                if(wrapCaseSubList.size()>0){
                    for(WrapCaseSubscription csWrap : wrapCaseSubList){
                        subVenId_SET.add(csWrap.caseVenSubs.Subscription_Vendor__c);
                    }
                }
                List<Subscription_Vendor__c> subVenSelected_LIST = [Select Id, Name From Subscription_Vendor__c Where Id IN :subVenId_SET];
                
                //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                //START UD-2717 09/10/15 RReyes - added condition to filter out void cases
                List<Case_Vendor_Subscription__c> casSubVen_LIST = [Select Id, Case__c, Subscription_Vendor__c, Complaint_From__c, Complaint_To__c , Case__R.Status 
                From Case_Vendor_Subscription__c 
                Where Subscription_Vendor__c IN :subVenId_SET AND Case__r.RecordTypeId = :recType AND Case__R.Status !=: GlobalVariableClass.STATUS_VOID];
                //END UD-2717 09/10/15 RReyes - added condition to filter out void cases
                //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                
                Map<Id, List<Case_Vendor_Subscription__c>> subVenIdToCasSubRec_MAP = new Map<Id, List<Case_Vendor_Subscription__c>>();
                boolean checkerVen = false;
                //START D-3280 27/7/2015 GDelrosario - added a variable flag
                Boolean caseVenSubsnotNull = false;
                //END D-3280 27/7/2015 GDelrosario - added a variable flag
                
                if(casSubVen_LIST.size()>0){
                    for(Case_Vendor_Subscription__c cs : casSubVen_LIST){
                        if(subVenIdToCasSubRec_MAP.containskey(cs.Subscription_Vendor__c)){
                            subVenIdToCasSubRec_MAP.get(cs.Subscription_Vendor__c).add(cs);
                        } else{
                            subVenIdToCasSubRec_MAP.put(cs.Subscription_Vendor__c, new List<Case_Vendor_Subscription__c>{cs});
                        }
                    }                       
                }
                
                if(wrapCaseSubList.size()>0){
                    for(WrapCaseSubscription csWrap : wrapCaseSubList){
                        //START D-3280 27/7/2015 GDelrosario - if filter to check if vendor
                        if(csWrap.caseVenSubs.Subscription_Vendor__c != null){
                            caseVenSubsnotNull = true;
                        //END D-3280 27/7/2015 GDelrosario - if filter to check if vendor
                            if(subVenIdToCasSubRec_MAP.containskey(csWrap.caseVenSubs.Subscription_Vendor__c)){
                            for(Case_Vendor_Subscription__c csRec : subVenIdToCasSubRec_MAP.get(csWrap.caseVenSubs.Subscription_Vendor__c)){
                                if(csRec.Id <> csWrap.caseVenSubs.Id){
                                    if(csRec.Complaint_From__c <> null && csRec.Complaint_To__c <> null){
                                        if((csRec.Complaint_From__c<csWrap.caseVenSubs.Complaint_From__c && csRec.Complaint_To__c<csWrap.caseVenSubs.Complaint_From__c)||(csRec.Complaint_From__c>csWrap.caseVenSubs.Complaint_To__c )){
                                        
                                        } else{
                                            checkerVen = true;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                        //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                        
                        
                            if(subToSubVen.containskey(csWrap.caseVenSubs.Subscription_Vendor__c)){
                                subVenRecs  = subToSubVen.get(csWrap.caseVenSubs.Subscription_Vendor__c);
                                
                            } //START/END D-3280 27/7/2015 GDelrosario - closing tag for the if filter above
                        }
                    }
                }
                
                //START D-3280 27/7/2015 GDelrosario - added in the if condition the filter
                if(subVenRecs.size() == 0 && caseVenSubsnotNull== true){
                //END D-3280 27/7/2015 GDelrosario - added in the if condition the filter
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('Validate Complaint- Magazine'));
                    ApexPages.addMessage(myMsg);
                    return null;
                }
                //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                
                if(checkerVen==true){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('OverlappingPeriod'));
                    ApexPages.addMessage(myMsg);
                    return null;
                }
                
                //END: UD-0775 04/08/2015 Added by S.PULI
                
                update cas;
            }
            
            List<Case_Subscription__c> insertCaseSubsList = new list<Case_Subscription__c>();
            List<Case_Vendor_Subscription__c> insertCaseVenSubsList = new list<Case_Vendor_Subscription__c>();
            List<Case_Subscription__c> deleteCaseSubsList = new list<Case_Subscription__c>();
            List<Case_Vendor_Subscription__c> deleteCaseVenSubsList = new list<Case_Vendor_Subscription__c>();

            if(isDirect) {         
                if(!wrapCaseSubList.isEmpty()){
                    for(WrapCaseSubscription caseSubWrapper: wrapCaseSubList){
                        Case_Subscription__c caseSub = new Case_Subscription__c();
                        caseSub = caseSubWrapper.caseSubs;
                        caseSub.Case__c = cas.id;
						//START UD-2741 9/15/2015 Added by Manolo Valena
                        if(cas.Replacement_Required__c == true) {
                            caseSub.Replacement_Required__c = true;
                        }
                        else {
                            caseSub.Replacement_Required__c = false;
                        }
                        //END UD-2741 9/15/2015 Added by Manolo Valena
                        insertCaseSubsList.add(caseSubWrapper.caseSubs);
                    }                
                }
                 
                upsert insertCaseSubsList;
                
                
                for(Id caseId : caseSubId){
                    Case_Subscription__c cSub = new Case_Subscription__c();
                    cSub.Id = caseId;
                    deleteCaseSubsList.add(cSub);                   
                }
                delete deleteCaseSubsList;
               
            }
            else { 
                if(!wrapCaseSubList.isEmpty()){
                    for(WrapCaseSubscription caseSubWrapper: wrapCaseSubList){
                        Case_Vendor_Subscription__c casVenSub = new Case_Vendor_Subscription__c();
                        casVenSub = caseSubWrapper.caseVenSubs;
                        casVenSub.Case__c = cas.id;
                        insertCaseVenSubsList.add(caseSubWrapper.caseVenSubs);
                    }
                } 
                upsert insertCaseVenSubsList;
                
                
                for(Id caseVenId : caseVenSubId){
                    Case_Vendor_Subscription__c cvSub = new Case_Vendor_Subscription__c();
                    cvSub.Id = caseVenId;
                    deleteCaseVenSubsList.add(cvSub);
                }
                delete deleteCaseVenSubsList;
            }
            
        }
        catch (Dmlexception e){  
            Database.rollback(sp);
            if(isNewRecord) cas.Id = null;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
            return null;   
        }

        PageReference pageRef = new pageReference('/' + cas.Id);
        pageRef.setRedirect(true);
        return pageRef; 

    }
    
    public PageReference cancel(){
        //Start: UD-1131 05/07/2015 James - cancel button to previous page
        String acctId = ApexPages.currentPage().getParameters().get('accountId');
        String conId = ApexPages.currentPage().getParameters().get('contactId');
        //End: UD-1131 05/07/2015 James
        if(cas.Id == null) {
            //Start: UD-1131 05/07/2015 James - cancel button to previous page
            //PageReference pageRef = new PageReference('/500/o');
            PageReference pageRef;
            if(acctId != null){
                if(conId != null){
                    pageRef = new PageReference('/' + conId);
                }else{
                    pageRef = new PageReference('/' + acctId);
                }
            }else{
                pageRef = new PageReference('/500/o');
            }
            //End: UD-1131 05/07/2015 James
            pageRef.setRedirect(true);
            return pageRef;
        }
        else {
            PageReference pageRef = new PageReference('/' + cas.Id);
            pageRef.setRedirect(true);
            return pageRef;
        }       
    }


    public class WrapCaseSubscription{
        public Case_Subscription__c caseSubs {get;set;}
        public Case_Vendor_Subscription__c caseVenSubs {get;set;}
        public Integer counterWrap {get;set;}        
        public WrapCaseSubscription (Case_Subscription__c CasSub){
            this.caseSubs = CasSub;
        }              
        public WrapCaseSubscription (Case_Subscription__c CasSub, Id accId){
            CasSub.Account__c = accId;
            this.caseSubs = CasSub;
        }      
        public WrapCaseSubscription(Case_Vendor_Subscription__c CasVenSub){
            this.caseVenSubs = CasVenSub;      
        }
        public WrapCaseSubscription(Case_Vendor_Subscription__c CasVenSub, Id accId){
            CasVenSub.Account__c = accId;
            this.caseVenSubs = CasVenSub;      
        }       
        public void setAccount(id accId){
        
                if(this.caseSubs != null){
                    this.caseSubs.Account__c = accId;
                }
                if(this.caseVenSubs != null){
                    this.caseVenSubs.Account__c = accId;
                }
        
        }
        
        //START: UD-0653 03/30/2015 RReyes
        public void setIsComplaintTrue(){
        if(this.caseSubs!= null){
                    this.caseSubs.isComplaint__c = true; 
                }   
        }
        //END: UD-0653 03/30/2015 RReyes
 
    }    

    public void fetchAccountDetails() {
  
        if(cas.AccountId != null) {
            acc = [SELECT RecordType.Name FROM Account WHERE Id = :cas.AccountId];
            
            if(acc.RecordType.Name == 'Vendor Subscriber' || acc.RecordType.Name == 'Vendor') {               
                isDirect = FALSE;
            }
            else {
                isDirect = TRUE;
            }
            
            for(WrapCaseSubscription wrapCas : wrapCaseSubList) {
                wrapCas.setAccount(cas.AccountId);
            }    

               
        }
    //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
    }
    
    public void checkPlatformType(){
        indexVal = Integer.valueOf(Apexpages.currentpage().getParameters().get('indexValue'));
        Boolean ismagazine = returnChecker(indexVal);
       
        if(!ismagazine){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('Validate Complaint- Magazine')));
        }
        //START UD-1827 8/31/15 AddedBy FrancisBenzon : checked if sub is future dated.
        else if(wrapCaseSubList[indexVal-1].caseSubs.Subscription__c!=null)
        {
            Zuora__Subscription__c sub = [SELECT Id, Zuora__SubscriptionStartDate__c, Zuora__Status__c  FROM Zuora__Subscription__c WHERE Id =: wrapCaseSubList[indexVal-1].caseSubs.Subscription__c];
            if(sub != null && sub.Zuora__SubscriptionStartDate__c > date.today())
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('ComplaintErrorForFutureDateSubs')));
            }
        }
        //END UD-1827 8/31/15 AddedBy FrancisBenzon : checked if sub is future dated.
        //START UD-2486 8/22/2015 Added By C. Lin - get Package Name of selected subscription
        getPackageName();
        //END UD-2486 8/22/2015 Added By C. Lin
    }
    //START UD-2486 8/22/2015 Added By C. Lin - get Package Name of selected subscription
    public void getPackageName(){
        Set<Id> subIdSet = new Set<Id>();
        Map<Id, String> subIdToPackageMap = new Map<Id, String>();
        
        for(WrapCaseSubscription wCasSub : wrapCaseSubList){
            if(wCasSub.caseSubs.Subscription__c != null){
                subIdSet.add(wCasSub.caseSubs.Subscription__c);
            }
        }
        
        List<Zuora__Subscription__c> subList = [SELECT Id, Name, Main_Package_1__r.Name FROM Zuora__Subscription__c WHERE Id IN :subIdSet];
        
        for(Zuora__Subscription__c s : subList){
            if(s.Main_Package_1__r.Name != null){
                subIdToPackageMap.put(s.Id, s.Main_Package_1__r.Name);
            }
        }
        
        for(WrapCaseSubscription wCSub : wrapCaseSubList){
            wCSub.caseSubs.Package_Name__c = subIdToPackageMap.get(wCSub.caseSubs.Subscription__c);
        }
    }
    //END UD-2486 8/22/2015 Added By C. Lin
    public Boolean returnChecker(Integer val){
        packageIsMagazine = false;
    magazineCounter = 0;
        if(isDirect){
            if(wrapCaseSubList[val-1].caseSubs.Subscription__c!=null){
                if(subToPackageItems.containskey(wrapCaseSubList[val-1].caseSubs.Subscription__c)){
                    pckItems = subToPackageItems.get(wrapCaseSubList[val-1].caseSubs.Subscription__c);
                }
                else{
                    Zuora__Subscription__c zs = [SELECT Main_Package_1__c FROM Zuora__Subscription__c WHERE Id =: wrapCaseSubList[val-1].caseSubs.Subscription__c];
                    pckItems = [SELECT Is_All_In_One__c, Is_Digital__c, Is_Magazine__c, Is_Newspaper__c, Is_Print__c FROM Package_Item__c WHERE Package__c =: zs.Main_Package_1__c];
                    subToPackageItems.put(wrapCaseSubList[val-1].caseSubs.Subscription__c, pckItems);
                }
                for(Package_Item__c pckItem : pckItems){
                    if(pckItem.Is_Magazine__c== TRUE){
                        magazineCounter++;
                    }
                }
                if(magazineCounter > 0){
                    packageIsMagazine = true;
                }
            }
        }
        else{
            if(wrapCaseSubList[val-1].caseVenSubs.Subscription_Vendor__c!=null){
                
                if(subToSubVen.containskey(wrapCaseSubList[val-1].caseVenSubs.Subscription_Vendor__c)){
                    subVenRecs = subToSubVen.get(wrapCaseSubList[val-1].caseVenSubs.Subscription_Vendor__c);
                }
                else{
                    subVenRecs = [SELECT Publication__r.Publication_Type__c, Subscription_Vendor__c FROM Subscription_Vendor_Publication__c WHERE Publication__r.Publication_Type__c = :mag AND Subscription_Vendor__c = :wrapCaseSubList[val-1].caseVenSubs.Subscription_Vendor__c];
                    subToSubVen.put(wrapCaseSubList[val-1].caseVenSubs.Subscription_Vendor__c, subVenRecs);
                }

                if(subVenRecs.size() > 0){
                    packageIsMagazine = true;
                }
            }
        }
        
        return packageIsMagazine;
    }
    //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 

}