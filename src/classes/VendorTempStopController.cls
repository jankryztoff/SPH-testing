/**
* Class Name: VendorTempStopController
* @author: Kay Lorica & Rowena Empenado
* Date: 09-08-2014
* Requirement/Project Name: <SPH>
* @description Controller for VendorTempStopSubs page
* 
*/


public class VendorTempStopController {
    Integer crsmMonths = integer.valueOf(ConstantsSLB.getKeyId('CRSMDuration'));  
    public Boolean followUpTask { get; set; }
    List<Case> trythis = new List<Case>();
    public Boolean dateUrgent {get; set;}
    public String vfSubId {get; set;}
    public String tstopId {get; set;}    
    public String myId {get; set;}
    public String myIdUpdate {get; set;} 
    public String myIdCancel {get; set;} 
    public String tempStop {get; set;}
    public String restartDate {get; set;}
    public Account thisAccount {get; set;}
    public List<String> subscriptionId = new List<String>();
    public Case thisCase {get; set;}
    public Temp_Stop__c thisTempStop {get; set;}
    public Vendor_Temp_Stop__c vendorTempStop {get; set;}
    public Order__c order {get; set;}
    public String requestSource {get;set;}
    public Subscription_Vendor__c thisSub {get;set;}
    public List<Subscription_Vendor__c> subList {get;set;}
    public String selectedTempStopType {get; set;}
    public Set<ID> subsID = new Set<ID>();
    public Set<Date> tsDateT = new Set<Date>();
    public Set<Date> tsDateR = new Set<Date>();
    public List<Vendor_Temp_Stop__c> vendorTempStopRecList {get;set;}
    public List<Subscription_Vendor_Publication__c> subvenpub {get; set;}
    public Map<ID,List<Subscription_Vendor_Publication__c>> svPubMap = new Map<ID,List<Subscription_Vendor_Publication__c>>(); 
    public SubscriptionWrapper wrapper;
    public SelectedWrapper tempstopwrapper;
    public SelectedWrapper wrapperSelected; 
    public String subfreq {get; set;}
    public Boolean isPubDay {get; set;}
    public String vendStopId {get; set;}
    public List<Vendor_Temp_Stop__c> vToUpdate {get; set;} 
    public List<Vendor_Temp_Stop__c> vToCancel {get; set;} 
    public String myColor {get; set;}
    public List<String> checker = new List<String>();
    public Boolean duplicateChecker;
    final Id accountId = ApexPages.currentPage().getParameters().get('accountId');
    
    //START: D-3040 JLedesma 6/5/2014 Validation for Update overlapping
    public Map<ID,List<Case>> subToPendingCasesMap = new Map<ID,List<Case>>(); 
    //END: D-3040 JLedesma 6/5/2014 Validation for Update overlappingninjerella
    //START: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop
    public Map<ID,Date> subToPubEarliestMap = new Map<ID,Date>();
    //END: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop
    //Start UD-0298 03/10/2015 James - Temp Stop Settings View for Reference Data
    List<Temp_Stop_Setting__c> tempstopsettings = [SELECT Name, TempStop_Min_Gap_Days__c, TemStop_Max_Issues__c, TemStop_Min_Issues__c from Temp_Stop_Setting__c LIMIT 1];
    //End UD-0298 03/10/2015 James - Temp Stop Settings View for Reference Data
    //START: D-1808 JLedesma 2/2/2015 Check non publication dates.
    Map<Id, Set<String>> subToPub = new Map<Id, Set<String>>();
    Set<String> pubCodes = new Set<String>();
    Set<Id> pubId = new Set<Id>();
    Map<String, Set<Date>> pubToPub = new Map<String, Set<Date>>();
    List<Non_Publication_Day__c> nonPubDates = new List<Non_Publication_Day__c>();
    Map<String, List<Date>> pubToNonPubDates = new Map<String, List<Date>>();
    //END: D-1808 JLedesma 2/2/2015 Check non publication dates.
    //Start: UD-1191/1192 05/15/2015 James
    Map<Id,SubscriptionWrapper> pubDates = new Map<Id,SubscriptionWrapper>();
    //End: UD-1191/1192 05/15/2015 James
    Id parentCaseId;//START/END UD-3293 11/25/15 RReyes 
    //START PD-0001 03May2016 Added By C. Lin - Bypass Migrated Data for Overlapping Validation
    Map<Id, Vendor_Temp_Stop__c> vtsIdToVtsMap = new Map<Id, Vendor_Temp_Stop__c>();
    //END PD-0001 03May2016 Added By C. Lin
    // ------------  Subscription Wrapper  ------------ //
    public class SubscriptionWrapper{
        public String id {get; set;}
        public String venPubId {get; set;}
        public String subId {get; set;}
        public String subscriptionName {get; set;}
        public String status {get; set;}
        public Decimal mon {get; set;}
        public Decimal tue {get; set;}
        public Decimal wed {get; set;}
        public Decimal thu {get; set;}
        public Decimal fri {get; set;}
        public Decimal sat {get; set;}
        public Decimal sun {get; set;}
        public Decimal tempStopQty {get; set;}
        public Date earliestStartDate {get; set;}
        public Date tempStopDate {get; set;}
        public Date restartDate {get; set;}  
        public Temp_Stop__c tp {get;set;}       
        //START: D-1808 JLedesma 2/2/2015 Check non publication dates.
        public Date subStartDate {get; set;}
        public Date subEndDate {get; set;}
        public String pub {get; set;}
        public String pubCode {get; set;}
        public Id pubId {get; set;}
        //END: D-1808 JLedesma 2/2/2015 Check non publication dates.
        //START: D-1950 2/10/15 JLedesma - Update old temp stop status
        public Id tempStopToUpdate {get; set;}
        //END: D-1950 2/10/15 JLedesma - Update old temp stop status
        //START: UD-1359 / JLedesma 6/3/2015 / entry/selection not avail for certain publications
        public Boolean isShown {get;set;}
        //END: UD-1359 / JLedesma 6/3/2015 / entry/selection not avail for certain publications
    }
    public List<SubscriptionWrapper> subscriptionResultList {get;set;}
    
    // ------------  Selected Wrapper  ------------ //
    public class SelectedWrapper{
        public String id {get; set;}
        public String subId {get; set;} 
        public String tempStopId {get; set;} 
        public String subscriptionName {get; set;}
        public String tempStopStatus {get; set;} 
        public Date earliestStartDate {get; set;} 
        public Date tempStopDate {get; set;}
        public Date restartDate {get; set;}
        public String remarks {get; set;}
        public Decimal tempStopQty {get; set;}  
        public Temp_Stop__c tp1 {get;set;}  
       //START: D-1808 JLedesma 2/2/2015 Check non publication dates.
        public Date subStartDate {get; set;}
        public Date subEndDate {get; set;}
        public String pub {get; set;}
        public String pubCode {get; set;}
        public Id pubId {get; set;}
        //END: D-1808 JLedesma 2/2/2015 Check non publication dates.
        //START: D-1950 2/10/15 JLedesma - Update old temp stop status
        public Id tempStopToUpdate {get; set;}
        //END: D-1950 2/10/15 JLedesma - Update old temp stop status
        //START: UD-1359 / JLedesma 6/3/2015 / entry/selection not avail for certain publications
        public Boolean isShown {get;set;}
        //END: UD-1359 / JLedesma 6/3/2015 / entry/selection not avail for certain publications
    }
    public List<SelectedWrapper> tempStopRequestList {get;set;} 
    public List<SelectedWrapper> updateListWrapper {get;set;} 
    public List<SelectedWrapper> cancelListWrapper {get;set;}   
    
    public VendorTempStopController(){        
        thisTempStop = new Temp_Stop__c();
        subscriptionResultList = new List<SubscriptionWrapper>();    
        tempStopRequestList = new List<SelectedWrapper>();
        updateListWrapper = new List<SelectedWrapper>(); 
        cancelListWrapper = new List<SelectedWrapper>();  
        thisSub = new Subscription_Vendor__c();
        thisCase = new Case();
        getAccount();
        getRequestSources();
        getSubscriptions();
        getTempStop();        
        setSubscriptionRecords();
        //START UD-3293 11/25/15 RReyes
        parentCaseId = ApexPages.currentPage().getParameters().get('def_parent_id');
        if (parentCaseId != null) {
                string tmp = parentCaseId;
                tmp.toLowerCase();
                if (tmp == 'null') {
                    parentCaseId = null;
                }
        }  
        //END UD-3293 11/25/15 RReyes

    }
    
    /*Description: This displays the values of picklist Request Sources used in VF page
    *Parameter: NA
    *Return: options
    */ 
    public List<SelectOption> getRequestSources() {
        List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption(globalvariableclass.TS_OPTION_CALL, 'Call'));
            options.add(new SelectOption(globalvariableclass.TS_OPTION_EMAIL, 'Email'));
            options.add(new SelectOption(globalvariableclass.TS_OPTION_FAX, 'Fax'));
            options.add(new SelectOption(globalvariableclass.TS_OPTION_MAIL, 'Mail'));
            options.add(new SelectOption(globalvariableclass.TS_OPTION_ESHOP, 'Eshop'));
        return options;
    } 
    
    /*Description: This displays the values of picklist Temp Stop Type used in VF Page
    *Parameter: NA
    *Return:
    */ 
    public List<SelectOption> getListTempStopType() {
        List<SelectOption> options = new List<SelectOption>(); 
            options.add(new SelectOption(globalvariableclass.TS_RADIO_CREATE_TEMP_STOP,'Create New Temp Stop')); 
            options.add(new SelectOption(globalvariableclass.TS_RADIO_UPDATE_TEMP_STOP,'Update Temp Stop Request')); 
            options.add(new SelectOption(globalvariableclass.TS_RADIO_CANCEL_TEMP_STOP,'Cancel Temp Stop Request'));
        return options; 
    }
    
    public String getselectedTempStopType() {
       return selectedTempStopType;
    }
    
    public void setTempStopType(String selectedTempStopType) {    
        this.selectedTempStopType = selectedTempStopType; 
    }
    
    /*Description:
    *Parameter: NA
    *Return: Void
    */  
    public void getAccount() {
        // START: Code Review Implementation 2/17/2015 JAlejandro
        if (accountId != null)
        {
            thisAccount = [SELECT Id, Name, Date_Since__c,Contact_Person__c, AccountNumber, RecordType.Name FROM Account WHERE (RecordType.Name = 'Vendor' OR RecordType.Name = 'Vendor Subscriber') AND  Id = :accountId]; 
        }// END: Code Review Implementation 2/17/2015 JAlejandro        
    } 
     
     //START: JLedesma D-3040 6/5/2015 validation for overlapping temps stop/restart dates against other Temp Stop subscriptions
    public Boolean pendingCaseChecker(Id subid){
        Boolean hasPending = FALSE;
        if(subToPendingCasesMap.containsKey(subid)){
            hasPending = TRUE;
        }
        
        return hasPending;
    }       
    //END: JLedesma D-3040 6/5/2015 validation for overlapping temps stop/restart dates against other Temp Stop subscriptions    
    /*Description: This method will retrieve all active subscriptions of the account.
    *Parameter: NA
    *Return: Void
    */ 
    public void getSubscriptions() {    
        Boolean flag = false;
        //START: D-2029 2/11/15 JLedesma - Filter validations for input.
        // START: Code Review Implementation 2/17/2015 JAlejandro
        if (thisAccount.Id != null)
        {
            subList = [SELECT Id, Subscription_Stop_Date__c, Subscription_Start_Date__c, Name, Recipient__c, Account__c, Status__c FROM Subscription_Vendor__c WHERE Account__c = :thisAccount.Id AND  Status__c='Active'];               
            //END: D-2029 2/11/15 JLedesma - Filter validations for input.
                for (Subscription_Vendor__c sub : subList) {
                    subsID.add(sub.ID);
                }
        }
        // END: Code Review Implementation 2/17/2015 JAlejandro
        //START: D-3040 JLedesma 6/5/2014 Validation for Update overlapping
        List<Case> pendingCases = [SELECT Id, Temp_Stop_VSub__c FROM Case WHERE Temp_Stop_VSub__c =: subsID AND Status = 'Pending' ];
        
        for(Case c: pendingCases){
            if(subToPendingCasesMap.containsKey(c.Temp_Stop_VSub__c)){
                subToPendingCasesMap.get(c.Temp_Stop_VSub__c).add(c);
            }
            else{
                subToPendingCasesMap.put(c.Temp_Stop_VSub__c, new List<Case>());
                subToPendingCasesMap.get(c.Temp_Stop_VSub__c).add(c);
            }
        }
        //END: D-3040 JLedesma 6/5/2014 Validation for Update overlapping
        getSubVenPub();
        
        if(!(subList == null)){
            for(Integer counter = 0; counter < subList.size(); counter++){
                for(Integer innerLoop = 0; innerLoop < subvenpub.size(); innerLoop++){
                    if(subList[counter].id == subvenpub[innerLoop].Subscription_Vendor__c){                        
                        flag = true;
                        break;
                    }
                }
                
                if(flag == false){
                    subList.remove(counter);
                }
                flag = false;
            }
        } 
        vToUpdate = new List<Vendor_Temp_Stop__c>(); 
        vToCancel = new List<Vendor_Temp_Stop__c>(); 
    }
    
    /*Description: This method displays the list of existing temp stop requests
    *Parameter: NA
    *Return: Void
    */ 
    //START: D-1808 JLedesma 2/2/2015 Check non publication dates.
    public void getTempStop() {  
        //START: D-2029 2/11/15 JLedesma - Filter validations for input.
        // START: Code Review Implementation 2/17/2015 JAlejandro
        if (thisAccount.Id != null)
        {
            //START PD-0001 03May2016 Added By C. Lin - Add Vendor_Sub_Temp_Stop_Legacy_Id__c
            //START: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop
            vendorTempStopRecList = [SELECT Temp_Stop__r.Cancelled__c, Subscription_Vendor__r.Subscription_Start_Date__c, Subscription_Vendor__r.Subscription_Stop_Date__c, id, Publication__c, Publication__r.Name, Publication__r.Publication_Code__c, Name, Subscription_Vendor__r.Name, Subscription_Vendor__r.Id, Subscription_Vendor__r.Status__c, Temp_Stop__c, Temp_Stop__r.Id, Temp_Stop__r.Temp_Stop_Qty__c, Temp_Stop__r.POP_Start_Date__c, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Remarks__c, Temp_Stop__r.Temp_Stop_Status__c, Temp_Stop__r.Case__r.Temp_Stop_Type__c, Temp_Stop__r.Case__r.POP_Start_Date__c, Temp_Stop__r.Pop_Start__c, Vendor_Sub_Temp_Stop_Legacy_Id__c
                                    FROM Vendor_Temp_Stop__c WHERE Subscription_Vendor__r.Account__c = :thisAccount.Id AND Subscription_Vendor__r.Status__c='Active'];    
            //END: D-2029 2/11/15 JLedesma - Filter validations for input.
            //END PD-0001 03May2016 Added By C. Lin
                if (vendorTempStopRecList != null) {
                    for (Vendor_Temp_Stop__c tmpdate : vendorTempStopRecList) {
                        tsDateT.add(tmpdate.Temp_Stop__r.Temp_Stop_Date__c);
                        tsDateR.add(tmpdate.Temp_Stop__r.Restart_Date__c);
                    }           
                    for(Vendor_Temp_Stop__c vUpd: vendorTempStopRecList){
                            if((vUpd.Temp_Stop__r.Temp_Stop_Status__c == globalvariableclass.TS_STATUS_ONGOING || vUpd.Temp_Stop__r.Temp_Stop_Status__c == globalvariableclass.TS_STATUS_NOTSTARTED) ) {
                                vUpd.Temp_Stop__r.Pop_Start__c = subToPubEarliestMap.get(vUpd.Subscription_Vendor__r.Id);
                                vToUpdate.add(vUpd);
                                
                                //START PD-0001 03May2016 Added By C. Lin - Bypass Migrated Data for Overlapping Validation
                                vtsIdToVtsMap.put(vUpd.Id, vUpd);
                                //END PD-0001 03May2016 Added By C. Lin
                                
                            }  
                    }
                        
                    for(Vendor_Temp_Stop__c vCan: vendorTempStopRecList){
                            if(vCan.Temp_Stop__r.Temp_Stop_Status__c == globalvariableclass.TS_STATUS_NOTSTARTED) {
                                vCan.Temp_Stop__r.Pop_Start__c = subToPubEarliestMap.get(vCan.Subscription_Vendor__r.Id);
                                vToCancel.add(vCan);
                            }
                    }
                }
        }// END: Code Review Implementation 2/17/2015 JAlejandro
    }
    //END: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop

    
    /*Description: This method displays the list of subscription vendor publication
    *Parameter: NA
    *Return: Void
    */ 
    public void getSubVenPub() {      
        pubToNonPubDates = new Map<String, List<Date>>();
        // START: Code Review Implementation 2/17/2015 JAlejandro
        if (!subsID.isEmpty())
        {
            //START: UD-1359 / JLedesma 6/3/2015 / entry/selection not avail for certain publications
            subvenpub = [SELECT id, Name, Mon__c, Tue__c, Wed__c, Thu__c, Fri__c, Sat__c, Sun__c, Publication__r.Sunday_Publication__c, Publication__c, Publication__r.Name, Publication__r.Publication_Code__c, Publication__r.Earliest_Start_Date__c, Subscription_Vendor__c FROM Subscription_Vendor_Publication__c WHERE Subscription_Vendor__c IN :subsID];
            //END: UD-1359 / JLedesma 6/3/2015 / entry/selection not avail for certain publications
            subToPub = new Map<Id, Set<String>>(); 
            //START: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop

            Date earliest;
            for (Subscription_Vendor_Publication__c svc: subvenpub)
            {
                pubCodes.add(svc.Publication__r.Publication_Code__c);
                pubId.add(svc.Publication__c);
                if(svc.Publication__c != NULL && svc.Subscription_Vendor__c != NULL){
                    if(subToPub.containsKey(svc.Subscription_Vendor__c)){
                        subToPub.get(svc.Subscription_Vendor__c).add(svc.Publication__r.Publication_Code__c);
                    }
                    else{
                        subToPub.put(svc.Subscription_Vendor__c, new Set<String> { svc.Publication__r.Publication_Code__c});
                    }
                    
                    if(subToPubEarliestMap.containsKey(svc.Subscription_Vendor__c)){
                        earliest = subToPubEarliestMap.get(svc.Subscription_Vendor__c);
                        if(svc.Publication__r.Earliest_Start_Date__c < earliest){
                            subToPubEarliestMap.put(svc.Subscription_Vendor__c, svc.Publication__r.Earliest_Start_Date__c);
                        }
                    }
                    else{
                        subToPubEarliestMap.put(svc.Subscription_Vendor__c, svc.Publication__r.Earliest_Start_Date__c);
                    }                   
                }
                //END: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop

                List<Subscription_Vendor_Publication__c> pubList = svPubMap.get(svc.Subscription_Vendor__c);
                if(pubList == null){
                    pubList = new List<Subscription_Vendor_Publication__c>();
                }
                pubList.add(svc);
                svPubMap.put(svc.Subscription_Vendor__c,pubList);
            }
        }
        
        if (!pubId.isEmpty())
        {
            nonPubDates = [SELECT Id, Non_Publication_Date__c, Publication__c, Publication__r.Publication_Code__c, Publication_Code__c, Publication__r.Published_Days__c FROM Non_Publication_Day__c
                                    WHERE Publication__c IN : pubId];

            for(Non_Publication_Day__c nonPub : nonPubDates){
                if(nonPub.Publication__r.Publication_Code__c!=NULL && nonPub.Non_Publication_Date__c!=NULL){
                    if(pubToNonPubDates.containsKey(nonPub.Publication__r.Publication_Code__c)){
                        pubToNonPubDates.get(nonPub.Publication__r.Publication_Code__c).add(nonPub.Non_Publication_Date__c);
                    } 
                    else {
                        pubToNonPubDates.put(nonPub.Publication__r.Publication_Code__c, new List<Date>());
                        pubToNonPubDates.get(nonPub.Publication__r.Publication_Code__c).add(nonPub.Non_Publication_Date__c);
                    }
                }
            }
        }// END: Code Review Implementation 2/17/2015 JAlejandro
    }
    //END: D-1808 JLedesma 2/2/2015 Check non publication dates.
    
    /*Description: This displays the list of subscriptions under customer Account and the publications and earliest start day of each subscription
    *Parameter: NA
    *Return: Void
    */ 
    public void setSubscriptionRecords() {            
        //START: UD-1359 / JLedesma 6/3/2015 / entry/selection not avail for certain publications
        for (Subscription_Vendor__c subven : subList) {
            //Start: UD-1191/1192 05/15/2015 James
            SubscriptionWrapper vendorSubWrapper = new SubscriptionWrapper();
            //START: UD-1359 / JLedesma 6/4/2015 / entry/selection not avail for certain publications
            Integer counter = 0;
            //END: UD-1359 / JLedesma 6/3/2015 / entry/selection not avail for certain publications
            //End: UD-1191/1192 05/15/2015 James
            if (svPubMap.containsKey(subven.ID)) {
                for (Subscription_Vendor_Publication__c svpub : svPubMap.get(subven.ID)) {
                    wrapper = new SubscriptionWrapper();                       
                    wrapper.venPubId = svpub.id;                                                                                           
                    wrapper.mon = svpub.Mon__c;
                    wrapper.tue = svpub.Tue__c;
                    wrapper.wed = svpub.Wed__c;
                    wrapper.thu = svpub.Thu__c;
                    wrapper.fri = svpub.Fri__c;
                    wrapper.sat = svpub.Sat__c;
                    wrapper.sun = svpub.Sun__c;    
                    //START: D-1808 JLedesma 2/2/2015 Check non publication dates.
                    wrapper.id = subven.Id;                   
                    wrapper.subscriptionName = subven.Name;
                    wrapper.status = subven.Status__c;
                    //START: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop
                    wrapper.earliestStartDate = subToPubEarliestMap.get(subven.Id);
                    //END: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop

                    wrapper.tp = new Temp_Stop__c();  
                    wrapper.pub = svpub.Publication__r.Name;
                    wrapper.pubCode = svpub.Publication__r.Publication_Code__c;
                    wrapper.pubId = svpub.Publication__c;
                    //END: D-1808 JLedesma 2/2/2015 Check non publication dates.
                    //START: D-2029 2/11/15 JLedesma - Filter validations for input.
                    wrapper.subStartDate = subven.Subscription_Start_Date__c;
                    wrapper.subEndDate = subven.Subscription_Stop_Date__c;
                    //START: UD-1359 / JLedesma 6/4/2015 / entry/selection not avail for certain publications
                    counter = 0;
                    for (Subscription_Vendor_Publication__c svpubRec : svPubMap.get(subven.ID)) {
                         if(svpub.Publication__r.Sunday_Publication__c!=null){
                            counter++;
                        }
                    }
                    
                    if(counter > 0 || svPubMap.get(subven.ID).size() == 1){
                        wrapper.isShown = true;
                    }
                    else{
                        wrapper.isShown = false;
                    }
                    //END: UD-1359 / JLedesma 6/4/2015 / entry/selection not avail for certain publications
                    //END: D-2029 2/11/15 JLedesma - Filter validations for input.
            //Start: UD-1191/1192 05/15/2015 James
                    subscriptionResultList.add(wrapper);
                    
                    if(pubDates.containsKey(subven.id)){            
                    
                        vendorSubWrapper = pubDates.get(subven.id);
                        System.debug('aaaa ' + vendorSubWrapper + 'subid ' + subven.id);
                        if(svpub.Mon__c > 0){   
                            vendorSubWrapper.mon = svpub.Mon__c;
                        }
                        if(svpub.Tue__c > 0){
                            vendorSubWrapper.tue = svpub.Tue__c;
                        }
                        if(svpub.Wed__c > 0){
                            vendorSubWrapper.wed = svpub.Wed__c;
                        }
                        if(svpub.Thu__c > 0){
                            vendorSubWrapper.thu = svpub.Thu__c;
                        }
                        if(svpub.Fri__c > 0){
                            vendorSubWrapper.fri = svpub.Fri__c;
                        }
                        if(svpub.Sat__c > 0){
                            vendorSubWrapper.sat = svpub.Sat__c;
                        }
                        if(svpub.Sun__c > 0){
                            vendorSubWrapper.sun = svpub.Sun__c;
                        }
                        pubDates.put(subven.id,vendorSubWrapper);
                    } 
                    else {
                        pubDates.put(subven.id, new SubscriptionWrapper());
                        vendorSubWrapper.mon = 0;
                        vendorSubWrapper.tue = 0;
                        vendorSubWrapper.wed = 0;
                        vendorSubWrapper.thu = 0;
                        vendorSubWrapper.fri = 0;
                        vendorSubWrapper.sat = 0;
                        vendorSubWrapper.sun = 0;
                        
                        if(svpub.Mon__c > 0){   
                            vendorSubWrapper.mon = svpub.Mon__c;
                        }
                        if(svpub.Tue__c > 0){
                            vendorSubWrapper.tue = svpub.Tue__c;
                        }
                        if(svpub.Wed__c > 0){
                            vendorSubWrapper.wed = svpub.Wed__c;
                        }
                        if(svpub.Thu__c > 0){
                            vendorSubWrapper.thu = svpub.Thu__c;
                        }
                        if(svpub.Fri__c > 0){
                            vendorSubWrapper.fri = svpub.Fri__c;
                        }
                        if(svpub.Sat__c > 0){
                            vendorSubWrapper.sat = svpub.Sat__c;
                        }
                        if(svpub.Sun__c > 0){
                            vendorSubWrapper.sun = svpub.Sun__c;
                        }
                        
                        pubDates.put(subven.id,vendorSubWrapper);
                    }
                }
            }
            //End: UD-1191/1192 05/15/2015 James
        }
        //END: UD-1359 / JLedesma 6/3/2015 / entry/selection not avail for certain publications
    }
    
    /*Description: This method check if the existing temp stop request do not overlap with the new temp stop request
    *Parameter: startinput, endinput, myID
    *Return: Result
    */     
    //START: D-2322 02/23/2015 JLedesma Updated logic for overlapping entries.
    public Boolean validateOverlapping(List<Vendor_Temp_Stop__c> subtempList, Date startinput, Date endinput, Id myID, Id pub){
        Vendor_Temp_Stop__c tempStopRecord = new Vendor_Temp_Stop__c();
        Boolean result = FALSE;
        Date endprev;
        Date startprev;
        List<String> overlapped = new List<String>();
        for(Vendor_Temp_Stop__c st : subtempList){
            if(st.Subscription_Vendor__c == Id.valueOf(myId) && st.Temp_Stop__r.Temp_Stop_Status__c!= globalvariableclass.TS_STATUS_CANCELLED && st.Publication__c == pub){
                startprev = st.Temp_Stop__r.Temp_Stop_Date__c;
                endprev = st.Temp_Stop__r.Restart_Date__c;
                if((startprev >= startinput && startprev <= endinput) ||(endprev >= startinput && endprev <= endinput) ||(startprev <= startinput && endprev >= endinput)){
                    result = TRUE;
                    overlapped.add(string.valueOf(result));
                }
            }
        }  
        //END: D-2322 02/23/2015 JLedesma Updated logic for overlapping entries.

        
        if(overlapped.size() > 0){
            result = TRUE;
        }
        else{
            result = FALSE;
        }
        return Result;
        
    }
    //START: JLedesma D-3023 5/28/2015 Validation for date inputs per subscription    
    //START: JLedesma UD-1146 5/21/2015 3 days interval for request dates
        public Boolean checkIntervalDate(Date restardDate, Date tempStopDate, Id sub, String selectedType, Id vendorTemp){
            Boolean isTrue = FALSE;
            
            if(vendorTempStopRecList.size() > 0){
                for(Vendor_Temp_Stop__c vts : vendorTempStopRecList){
                    if(vts.Temp_Stop__r.Temp_Stop_Status__c != 'Cancelled' && vts.Subscription_Vendor__r.Id == sub){
                        if(selectedType == globalvariableclass.TS_RADIO_UPDATE_TEMP_STOP){  
                            for(integer counter = 1; counter <= 3; counter++){
                                if((((vts.Temp_Stop__r.Restart_Date__c + counter) == tempStopDate) || (restardDate == (vts.Temp_Stop__r.Temp_Stop_Date__c - counter))) && (vendorTemp != vts.Id)){
                                    isTrue = TRUE;
                                }
                            }
                        }
                        else{
                            for(integer counter = 1; counter <= 3; counter++){
                                if(((vts.Temp_Stop__r.Restart_Date__c + counter) == tempStopDate) || (restardDate == (vts.Temp_Stop__r.Temp_Stop_Date__c - counter))){
                                    isTrue = TRUE;
                                }
                            }
                        }
                    }
                }
            }
            
            
            return isTrue;
        }
        //END: JLedesma UD-1146 5/21/2015 3 days interval for request dates
        //END: JLedesma D-3023 5/28/2015 Validation for date inputs per subscription
    //START: D-1808 JLedesma 2/2/2015 Check non publication dates.
    /*Description: This method displays the separate list of selected subscription with populated temp stop date and restart and executes the validation for the populated Temp Stop date and Restart date
    *Parameter: NA
    *Return: Void
    */
    public void setSelectedRecords() {  
        Boolean isNonPub;
        if(checkDuplicateSubscription()) {  
            for (SubscriptionWrapper subven : subscriptionResultList) {
                //Start UD-0298 03/10/2015 James - Temp Stop Settings View for Reference Data
                Integer numberDays;
                Integer cancelled = 0;
                date TempStopDateTempStopSettings;
                date DateTempStopSettings;
                List<Date> DateTempStopSettingsList = new List<Date>();
                //START: JLedesma D-3023 5/28/2015 Validation for date inputs per subscription
                Boolean isWithinInterval = false;
                if(subven.tp.Restart_Date__c!=null && subven.tp.Temp_Stop_Date__c!=null){
                    isWithinInterval = checkIntervalDate(subven.tp.Restart_Date__c, subven.tp.Temp_Stop_Date__c, subven.id, null, null);
                }

                //END: JLedesma D-3023 5/28/2015 Validation for date inputs per subscription
                //End UD-0298 03/10/2015 James - Temp Stop Settings View for Reference Data              
                //START: D-2029 2/11/15 JLedesma - Filter validations for input.
                //START: UD-1359 / JLedesma 6/3/2015 / entry/selection not avail for certain publications
                if(vfSubId == subven.id){   
                //END: UD-1359 / JLedesma 6/3/2015 / entry/selection not avail for certain publications
                    DateTime restartDate;
                    //START: D-2209 2/13/15 JLedesma - Re-arranged validations
                    //START: D-3040 JLedesma 6/5/2014 Validation for Update overlapping
                    if(subven.tp.Restart_Date__c!=null){
                        isNonPub = nonPublishDayChecker(subven.id, subven.tp.Restart_Date__c);
                    }
                    //Start: UD-1191/1192 05/15/2015 James
                    pubDates.get(subven.id);
                    system.debug('pubDates>>>> ' + pubDates);
                    //End: UD-1191/1192 05/15/2015 James                    
                    //START: UD-1359 / JLedesma 6/3/2015 / entry/selection not avail for certain publications                    
                    restartDate = subven.tp.Restart_Date__c;
                    //END: UD-1359 / JLedesma 6/3/2015 / entry/selection not avail for certain publications                        
                    if(pendingCaseChecker(subven.Id)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Temp Stop Pending Cases')));
                    }
                    else if(restartDate != null){
                        String dayOfWeek = restartDate.format('EEE');                    
                        //Start: UD-1191/1192 05/15/2015 James
                        //START: UD-1359 / JLedesma 6/3/2015 / entry/selection not avail for certain publications
                        if(isNonPub) {                         
                    //END: D-3040 JLedesma 6/5/2014 Validation for Update overlapping
                            //END: UD-1359 / JLedesma 6/3/2015 / entry/selection not avail for certain publications
                            //END: UD-1359 / JLedesma 6/3/2015 / entry/selection not avail for certain publications
                            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, '' + ConstantsSLB.getErrorMessage('Invalid Restart Date')); 
                            ApexPages.addMessage(msg);  
                        }
                        //End: UD-1191/1192 05/15/2015 James
                    
                    else if(subven.tp.Temp_Stop_Date__c == NULL || subven.tp.Restart_Date__c == NULL || subven.tp.Temp_Stop_Qty__c == NULL ){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Incomplete Inputs')));
                    }
                    //END: D-2209 2/13/15 JLedesma - Re-arranged validations
                    else if(subven.tp.Temp_Stop_Date__c <= Date.TODAY()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Temp Stop Date 1')));
                    }
                    
                    else if(subven.subEndDate <= subven.tp.Temp_Stop_Date__c){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Temp Stop Date 2')));
                    }
                    else if(subven.subStartDate > subven.tp.Temp_Stop_Date__c){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Temp Stop Date 3')));
                    }       
                    else if(subven.subStartDate >= subven.tp.Restart_Date__c){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Restart Date 1')));
                    }   
                    else if(subven.subEndDate < subven.tp.Restart_Date__c){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Restart Date 2')));
                    }
                    else if(subven.subEndDate <= subven.tp.Restart_Date__c){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Restart Date 3')));
                    }
                    
                    //START: D-1896 1/30/2015 Added error message to custom settings
                    else if (subven.earliestStartDate == Null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('Missing Earliest Start Date')));
                    }
                    //END: D-1896 1/30/2015 Added error message to custom settings
                    
                    else if(subven.tp.Restart_Date__c <= Date.TODAY() || subven.tp.Temp_Stop_Date__c >= subven.tp.Restart_Date__c){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Invalid Restart Date Input'))); 
                    }
                    //START: D-2322 02/23/2015 JLedesma Updated logic for overlapping entries.
                    
                    else if((vendorTempStopRecList != null) && validateOverlapping(vendorTempStopRecList, subven.tp.Temp_Stop_Date__c, subven.tp.Restart_Date__c, vfSubId, subven.pubId)){
                     ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, '' + ConstantsSLB.getErrorMessage('Invalid Temp Stop Request Dates'));  
                    ApexPages.addMessage(msg);
                    //END: D-2322 JLedesma Updated logic for overlapping entries.
                    }
                    else if(requestSource != 'Eshop' && subven.tp.Temp_Stop_Date__c.monthsBetween(subven.tp.Restart_Date__c) > crsmMonths) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('InvalidTempStopDurationCRSM')));
                    }
                    
                    else if (subven.tp.Restart_Date__c < subven.tp.Temp_Stop_Date__c) {
                        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, '' + ConstantsSLB.getErrorMessage('Invalid Restart Date 3'));
                        ApexPages.addMessage(msg);
                    } 
                    //Start UD-0298 03/10/2015 James - Temp Stop Settings View for Reference Data
                    //START: JLedesma D-3023 5/28/2015 Validation for date inputs per subscription
                    else if(isWithinInterval){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('TempStopMinGapDaysPart1') + ' ' + tempstopsettings[0].TempStop_Min_Gap_Days__c + ' ' + ConstantsSLB.getErrorMessage('TempStopMinGapDaysPart2')));
                    }
                    //END: JLedesma D-3023 5/28/2015 Validation for date inputs per subscription
                    else if(tempstopsettings.size() > 0 &&  subven.tp.Temp_Stop_Date__c.daysbetween(subven.tp.Restart_Date__c) < tempstopsettings[0].TempStop_Min_Gap_Days__c){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('TempStopDateRestartDatePart1') + ' ' + tempstopsettings[0].TempStop_Min_Gap_Days__c + ' ' + ConstantsSLB.getErrorMessage('TempStopDateRestartDatePart2')));
                    }       
                    //End UD-0298 03/10/2015 James - Temp Stop Settings View for Reference Data
                    //START:D-3339 8/11/2015 Added by Manolo Valena
                    else if(subven.tp.Temp_Stop_Qty__c > highestQuantity(subven.id, subven.tp.Temp_Stop_Date__c, subven.tp.Restart_Date__c)) {
                        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, GlobalVariableClass.SPACE + ConstantsSLB.getErrorMessage('VendorTStopQuantity') + GlobalVariableClass.SPACE + highestQuantity(subven.id, subven.tp.Temp_Stop_Date__c, subven.tp.Restart_Date__c) + GlobalVariableClass.PERIOD);
                        ApexPages.addMessage(msg);
                    }
                    //END:D-3339 8/11/2015 Added by Manolo Valena
                    else {
                        tempstopwrapper = new SelectedWrapper();
                        tempstopwrapper.id = myId;
                        tempstopwrapper.subId = subven.Id;
                        tempstopwrapper.subscriptionName = subven.subscriptionName;
                        tempstopwrapper.earliestStartDate = subven.earliestStartDate;
                        tempstopwrapper.tempStopDate  = subven.tp.Temp_Stop_Date__c;
                        tempstopwrapper.restartDate  = subven.tp.Restart_Date__c;
                        tempstopwrapper.tempStopQty  = subven.tp.Temp_Stop_Qty__c;
                        //jerella
                        tempstopwrapper.pub = subven.pub;
                        tempstopwrapper.pubId = subven.pubId;
                        //jerella
                        tempStopRequestList.add(tempstopwrapper);
                    }
                    }
                    //END: D-2029 2/11/15 JLedesma - Filter validations for input.  
                }
                
            }
        }
    }
    
    /*Description: This method identifies if the temp stop date or restart date is urgent
    *Parameter: NA
    *Return: Void
    */
    //START: D-3040 JLedesma 6/5/2014 Validation for Update overlapping
    public Boolean nonPublishDayChecker(Id subId, Date restart) {
        Boolean returnValue = FALSE;
        DateTime restartDate;
        restartDate = restart;
        String dayOfWeek = restartDate.format('EEE');      
        if(((pubDates.get(subId).mon == null || pubDates.get(subId).mon == 0) && (dayOfWeek == 'Mon'))|| 
           ((pubDates.get(subId).tue == null || pubDates.get(subId).tue == 0) && (dayOfWeek == 'Tue')) ||
           ((pubDates.get(subId).wed == null || pubDates.get(subId).wed == 0) && (dayOfWeek == 'Wed')) ||
           ((pubDates.get(subId).thu == null || pubDates.get(subId).thu == 0) && (dayOfWeek == 'Thu')) ||
           ((pubDates.get(subId).fri == null || pubDates.get(subId).fri == 0) && (dayOfWeek == 'Fri')) || 
           ((pubDates.get(subId).sat == null || pubDates.get(subId).sat == 0) && (dayOfWeek == 'Sat')) ||
           ((pubDates.get(subId).sun == null || pubDates.get(subId).sun == 0) && (dayOfWeek == 'Sun'))) {                         
                returnValue = TRUE;
        }

        return returnValue;
    }
   //END: D-3040 JLedesma 6/5/2014 Validation for Update overlapping
    
    //START:D-3339 8/11/2015 Added by Manolo Valena
    public Decimal highestQuantity(Id subId, Date tsDate, Date rsDate) {
        Set<String> daysOfWeekNum = new Set<String>();
        Integer daysBet = tsDate.daysBetween(rsDate);
        Decimal highestQ = 0.00;
        
        for(Integer i = daysBet; i >= 0; i--) {
            DateTime dt = tsDate.addDays(i);
            if(!daysOfWeekNum.contains(dt.format('u'))) {   
                daysOfWeekNum.add(dt.format('u'));
            }
        }
        
        for(String d : daysOfWeekNum) {
            if(Integer.valueOf(d) == 1) {
                if(highestQ < pubDates.get(subId).mon) {
                    highestQ = pubDates.get(subId).mon;
                }
            }
            else if(Integer.valueOf(d) == 2) {
                if(highestQ < pubDates.get(subId).tue) {
                    highestQ = pubDates.get(subId).tue;
                }
            }
            else if(Integer.valueOf(d) == 3) {
                if(highestQ < pubDates.get(subId).wed) {
                    highestQ = pubDates.get(subId).wed;
                }
            }
            else if(Integer.valueOf(d) == 4) {
                if(highestQ < pubDates.get(subId).thu) {
                    highestQ = pubDates.get(subId).thu;
                }
            }
            else if(Integer.valueOf(d) == 5) {
                if(highestQ < pubDates.get(subId).fri) {
                    highestQ = pubDates.get(subId).fri;
                }
            }
            else if(Integer.valueOf(d) == 6) {
                if(highestQ < pubDates.get(subId).sat) {
                    highestQ = pubDates.get(subId).sat;
                }
            }
            else if(Integer.valueOf(d) == 7) {
                if(highestQ < pubDates.get(subId).sun) {
                    highestQ = pubDates.get(subId).sun;
                }
            }
        }
        
        return highestQ;
    }
    //END:D-3339 8/11/2015 Added by Manolo Valena
    
    /*Description: This method identifies if the temp stop date or restart date is urgent
    *Parameter: NA
    *Return: Void
    */
    //END: D-1808 JLedesma 2/2/2015 Check non publication dates.
    public void getDateUrgency() {
        for(SubscriptionWrapper sub : subscriptionResultList) {
            //START: UD-1332 5/20/2015 JLedesma urgent approval criteria.
            if(sub.restartDate < sub.earliestStartDate) {
            //END: UD-1332 5/20/2015 JLedesma urgent approval criteria.
                dateUrgent = true;
            }
        } 
        dateUrgent = false;
    }
    
    /*Description: This method stops adding of record in the separate list of selected records in Create Temp Stop Type
    *Parameter: NA
    *Return: Boolean
    */
    public Boolean checkDuplicateSubscription() {
        for(SelectedWrapper sub : tempStopRequestList) {
            if(sub.id.equals(myId)) {
                checker.add(myId);
            }
        }
        if(checker.size()>0){
            duplicateChecker = False;
        }
        else{
            duplicateChecker = True;
        }
        return duplicateChecker;
    }
    
    /*Description: This method executes removing the selected subscription from the selected list in Create Selected Table
    *Parameter: NA
    *Return: Void
    */
    public void removeSubscriptionRecord() {
        for(Integer counter = 0; counter < tempStopRequestList.size(); counter++) {
            if(tempStopRequestList[counter].id == tstopId) {
                tempStopRequestList.remove(counter);
            }
        }
    }
    
    /*Description: This method displays the list of temp stop requests record used in Update and Cancel Temp Stop Type
    *Parameter: NA
    *Return: Void
    */
    public void setVendorTempStopRecords(){
        if (selectedTempStopType == globalvariableclass.TS_RADIO_UPDATE_TEMP_STOP){       
            if(checkDuplicateTempStopToUpdate()){
                //START: JLedesma D-3023 5/28/2015 Validation for date inputs per subscription            
                Boolean isWithinInterval = false;
            
                for(Vendor_Temp_Stop__c v1: vToUpdate){
                    if(v1.Id == myIdUpdate){
                        vendorTempStop = v1;
                        break; 
                    }
                }  
                //START: D-3040 JLedesma 6/5/2014 Validation for Update overlapping
                Boolean isNonPub = false;
                isNonPub = nonPublishDayChecker(vendorTempStop.Subscription_Vendor__r.Id, vendorTempStop.Temp_Stop__r.Restart_Date__c);                 
                DateTime restartDate =vendorTempStop.Temp_Stop__r.Restart_Date__c;
                String dayOfWeek = restartDate.format('EEE');    
    
                if(vendorTempStop.Temp_Stop__r.Restart_Date__c!=null && vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c!=null){
                    isWithinInterval = checkIntervalDate(vendorTempStop.Temp_Stop__r.Restart_Date__c, vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c, vendorTempStop.Subscription_Vendor__r.Id, selectedTempStopType, vendorTempStop.Id);

                }
                
                if(pendingCaseChecker(vendorTempStop.Subscription_Vendor__r.Id)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Temp Stop Pending Cases')));

                }

                else if(isNonPub) {                         
                    ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, '' + ConstantsSLB.getErrorMessage('Invalid Restart Date')); 
                    ApexPages.addMessage(msg);  

                    System.debug('aaa ' + pubDates.get(vendorTempStop.Subscription_Vendor__r.Id));
                }

                    else if(isWithinInterval){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('TempStopMinGapDaysPart1') + ' ' + tempstopsettings[0].TempStop_Min_Gap_Days__c + ' ' + ConstantsSLB.getErrorMessage('TempStopMinGapDaysPart2')));
                    }
                
                //END: JLedesma D-3023 5/28/2015 Validation for date inputs per subscription
                //START: D-2029 2/11/15 JLedesma - Filter validations for input.    
                else if(vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c == NULL || vendorTempStop.Temp_Stop__r.Restart_Date__c == NULL || vendorTempStop.Temp_Stop__r.Temp_Stop_Qty__c == NULL ){
                //END: D-3040 JLedesma 6/5/2014 Validation for Update overlapping                
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Incomplete Inputs')));
                }
                //START: D-2229 JLedesma 2/16/2015 Validation for on-going records considered.
                else if(vendorTempStop.Temp_Stop__r.Temp_Stop_Status__c == globalvariableclass.TS_STATUS_NOTSTARTED  && vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c <= Date.TODAY()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Temp Stop Date 1')));
                }
                //END: D-2229 JLedesma 2/16/2015 Validation for on-going records considered.
                
                else if(vendorTempStop.Subscription_Vendor__r.Subscription_Stop_Date__c <= vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Temp Stop Date 2')));
                }
                else if(vendorTempStop.Subscription_Vendor__r.Subscription_Start_Date__c > vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Temp Stop Date 3')));
                }       
                else if(vendorTempStop.Subscription_Vendor__r.Subscription_Start_Date__c >= vendorTempStop.Temp_Stop__r.Restart_Date__c){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Restart Date 1')));
                }   
                else if(vendorTempStop.Subscription_Vendor__r.Subscription_Stop_Date__c < vendorTempStop.Temp_Stop__r.Restart_Date__c){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Restart Date 2')));
                }
                else if(vendorTempStop.Subscription_Vendor__r.Subscription_Stop_Date__c <= vendorTempStop.Temp_Stop__r.Restart_Date__c){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Validate Restart Date 3')));
                }
                else if (requestSource != 'Eshop' && vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c.monthsBetween(vendorTempStop.Temp_Stop__r.Restart_Date__c) > crsmMonths) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('InvalidTempStopDurationCRSM')));
                }
                //START: JLedesma D-3023 5/28/2015 Validation for date inputs per subscription
                else if(isWithinInterval){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('TempStopMinGapDaysPart1') + ' ' + tempstopsettings[0].TempStop_Min_Gap_Days__c + ' ' + ConstantsSLB.getErrorMessage('TempStopMinGapDaysPart2')));
                }
                //END: JLedesma D-3023 5/28/2015 Validation for date inputs per subscription
                //START: D-2322 02/23/2015 JLedesma Updated logic for overlapping entries.
                //START: D-3040 JLedesma 6/5/2014 Validation for Update overlapping
                //START PD-0001 03May2016 Added By C. Lin - Bypass Migrated Data for Overlapping Validation
                //else if(vtsIdToVtsMap.get(vendorTempStop.Id).Vendor_Sub_Temp_Stop_Legacy_Id__c == null){
                else if(validateOverlapUpdate(vendorTempStopRecList, vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c, vendorTempStop.Temp_Stop__r.Restart_Date__c, vendorTempStop.Id, vendorTempStop.Subscription_Vendor__c) && vtsIdToVtsMap.get(vendorTempStop.Id).Vendor_Sub_Temp_Stop_Legacy_Id__c == null){
                        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, '' + ConstantsSLB.getErrorMessage('Invalid Temp Stop Request Dates'));  
                        ApexPages.addMessage(msg);
                    //END: D-3040 JLedesma 6/5/2014 Validation for Update overlapping
                    //}
                    //END: D-2322 JLedesma Updated logic for overlapping entries.
                }
                //END PD-0001 03May2016 Added By C. Lin
                /*if(vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c < Date.TODAY() || vendorTempStop.Temp_Stop__r.Restart_Date__c < Date.TODAY()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Invalid Date Input')));
                }
                
                if (vendorTempStop.Temp_Stop__r.Restart_Date__c < vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c) {
                    ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, '' + ConstantsSLB.getErrorMessage('Invalid Restart Date 3')); 
                            ApexPages.addMessage(msg);
                } else if (vendorTempStop.Temp_Stop__r.Restart_Date__c == vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c) {
                    ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, '' + ConstantsSLB.getErrorMessage('Invalid Restart Date 4')); 
                            ApexPages.addMessage(msg);
                } else if (vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c == Date.TODAY()) {
                    ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, '' + ConstantsSLB.getErrorMessage('Invalid Temp Stop Date2')); 
                            ApexPages.addMessage(msg);
                } 
                */
                else {             
                wrapperSelected = new SelectedWrapper();
                wrapperSelected.id = myIdUpdate; 
                wrapperSelected.subId = vendorTempStop.Subscription_Vendor__r.Id;
                wrapperSelected.subscriptionName = vendorTempStop.Subscription_Vendor__r.Name;
                wrapperSelected.tempStopQty = vendorTempStop.Temp_Stop__r.Temp_Stop_Qty__c;
                //START: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop
                wrapperSelected.earliestStartDate = vendorTempStop.Temp_Stop__r.POP_Start__c; 
                //END: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop

                wrapperSelected.tempStopDate = vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c;
                wrapperSelected.restartDate = vendorTempStop.Temp_Stop__r.Restart_Date__c;            
                wrapperSelected.tempStopId = vendorTempStop.Temp_Stop__c;
                //START: D-1950 2/10/15 JLedesma - Update old temp stop status
                wrapperSelected.pubId = vendorTempStop.Publication__c;
                //END: D-1950 2/10/15 JLedesma - Update old temp stop status
                //START: D-1808 JLedesma 2/2/2015 Check non publication dates.
                wrapperSelected.tempStopStatus = vendorTempStop.Temp_Stop__r.Temp_Stop_Status__c;   
                wrapperSelected.pub = vendorTempStop.Publication__r.Name;           
                wrapperSelected.tempStopToUpdate = vendorTempStop.Temp_Stop__c;         
                wrapper.subStartDate = vendorTempStop.Subscription_Vendor__r.Subscription_Start_Date__c;
                wrapper.subEndDate = vendorTempStop.Subscription_Vendor__r.Subscription_Stop_Date__c;
                //END: D-2029 2/11/15 JLedesma - Filter validations for input.
                updateListWrapper.add(wrapperSelected);}
                }           
        } else if (selectedTempStopType == globalvariableclass.TS_RADIO_CANCEL_TEMP_STOP) { 
            if(checkDuplicateTempStopToCancel()) {       
                for(Vendor_Temp_Stop__c v2: vToCancel ) {
                    if(v2.Id == myIdCancel) {
                        vendorTempStop = v2;
                        break; 
                    }
                }                
                wrapperSelected= new SelectedWrapper();
                wrapperSelected.id = myIdCancel;
                wrapperSelected.subId = vendorTempStop.Subscription_Vendor__r.Id;
                wrapperSelected.subscriptionName = vendorTempStop.Subscription_Vendor__r.Name;
                wrapperSelected.tempStopQty = vendorTempStop.Temp_Stop__r.Temp_Stop_Qty__c;
                wrapperSelected.earliestStartDate = vendorTempStop.Temp_Stop__r.POP_Start_Date__c; 
                wrapperSelected.tempStopDate = vendorTempStop.Temp_Stop__r.Temp_Stop_Date__c;
                wrapperSelected.restartDate = vendorTempStop.Temp_Stop__r.Restart_Date__c;            
                wrapperSelected.tempStopId = vendorTempStop.Temp_Stop__c;
                wrapperSelected.tempStopStatus = vendorTempStop.Temp_Stop__r.Temp_Stop_Status__c;          
                wrapperSelected.pub = vendorTempStop.Publication__r.Name;   
                wrapperSelected.pubId = vendorTempStop.Publication__c;
                //END: D-1808 JLedesma 2/2/2015 Check non publication dates.          
                cancelListWrapper.add(wrapperSelected);                        
                } 
        }  
    }
    //START: D-3040 JLedesma 6/5/2014 Validation for Update overlapping    
    public Boolean validateOverlapUpdate(List<Vendor_Temp_Stop__c> vendorTempList, Date startinput, Date endinput, Id vtempId, Id subId){
        Boolean isOverlapping = FALSE;
        Date startprev;
        Date endprev;
        for(Vendor_Temp_Stop__c vt : vendorTempList){
            startprev = vt.Temp_Stop__r.Temp_Stop_Date__c;
            endprev = vt.Temp_Stop__r.Restart_Date__c;
            //START: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop
            if(vtempId != vt.Id && vt.Subscription_Vendor__r.Id == subId && vt.Temp_Stop__r.Cancelled__c!=TRUE){
            //END: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop
                if((startprev >= startinput && startprev <= endinput) ||(endprev >= startinput && endprev <= endinput) ||(startprev <= startinput && endprev >= endinput)){
                    isOverlapping = TRUE;
                }
            }
        }
        
        return isOverlapping;
    }
    //END: D-3040 JLedesma 6/5/2014 Validation for Update overlapping    
    
    /*Description: This method stops adding of record in the separate list of selected records in Update Temp Stop Type
    *Parameter: NA
    *Return: Boolean
    */
    public Boolean checkDuplicateTempStopToUpdate() {
        for(SelectedWrapper w1 : updateListWrapper) {
            if(w1.id.equals(myIdUpdate)) {
                checker.add(myIdUpdate);
            }
        }
        if(checker.size()>0){
            duplicateChecker = False;
        }
        else{
            duplicateChecker = True;
        }
        return duplicateChecker;
    }
    
    /*Description: This method stops adding of record in the separate list of selected records in Cancel Temp Stop Type
    *Parameter: NA
    *Return: Boolean
    */
    public Boolean checkDuplicateTempStopToCancel() {
        for(SelectedWrapper w2 : cancelListWrapper) {
            if(w2.id.equals(myIdCancel)){
                checker.add(myIdCancel);
            }
        }
        if(checker.size()>0){
            duplicateChecker = False;
        }
        else{
            duplicateChecker = True;
        }
        return duplicateChecker;
    }
    
    
    
    /*Description: This method executes removing the selected subscription from the selected list in Update Selected Table
    *Parameter: NA
    *Return: Void
    */
    public void removeTempStopToUpdate() {
        for(Integer counter = 0; counter < updateListWrapper.size(); counter++){
            if(updateListWrapper[counter].id == myIdUpdate){
                updateListWrapper.remove(counter);
            }
        }
    }
    
    /*Description: This method executes removing the selected subscription from the selected list in Cancel Selected Table
    *Parameter: NA
    *Return: Void
    */
    public void removeTempStopToCancel() {
        for(Integer counter = 0; counter < cancelListWrapper.size(); counter++){
            if(cancelListWrapper[counter].id == myIdCancel){
                cancelListWrapper.remove(counter);
            }
        }
    }
    
    /*Description: 
    *Parameter:
    *Return:
    */
    //For Cancel button
    public PageReference cancel() {
        PageReference pRef = new PageReference('/' + thisAccount.Id);
        return pRef;    
    }
    
    /*Description:
    *Parameter:
    *Return:
    */
    //For Submit button
    public PageReference submit() {
        PageReference pRef;
        trythis = createRecordsOnSave(); 
        //START: D-2322 02/23/2015 JLedesma Updated logic for overlapping entries.
        if(trythis.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('Temp Stop Blank Values')));
        }
        else if(trythis.size()>0){
            pref= new PageReference('/' + trythis[0].Id );
        }
        //END: D-2322 JLedesma Updated logic for overlapping entries.
        else{
            pref= new PageReference('/' + globalvariableclass.TS_REDIRECT_TO_RECORD );
        }
        return pRef;        
    }
    
    /*Description:
    *Parameter:
    *Return:
    */  
    public List<Case> createRecordsOnSave(){
        List<Order__c> orderInsertList = new List<Order__c>();
        List<Case> caseList = new List<Case>();
        List<Task> taskList = new List<Task>(); 
        List<Temp_Stop__c> tempStopInsertList = new List<Temp_Stop__c>();
        List<Temp_Stop__c> oldTempStopUpdateList = new List<Temp_Stop__c>();
        List<Vendor_Temp_Stop__c> vendorTempStopList = new List<Vendor_Temp_Stop__c>();
        List<Case_Vendor_Subscription__c> vendorCaseSubs = new List<Case_Vendor_Subscription__c>();    
        Set<Id> subVendId = new Set<Id> ();
        Set<Decimal> postalSectorCodeSet = new Set<Decimal> ();
        Map<Decimal,String> postalSectorCodeSet_vendorOps_map = new Map<Decimal,String>();
        //START D-4387 04Feb2016 Added By C. Lin - Separate Approved Case List
        List<Case> caseListApproved = new List<Case>();
        //END D-4387 04Feb2016 Added By C. Lin
    
    if (selectedTempStopType == globalvariableclass.TS_RADIO_UPDATE_TEMP_STOP){
                       
        for (SelectedWrapper Upd : updateListWrapper ){
            
            //Create new order record                        
            Order__c order = new Order__c();
            order.Account__c = thisAccount.Id;
            order.Order_Type__c =  globalvariableclass.TS_TEMP_STOP;
            order.Temp_Stop_Type__c = globalvariableclass.TS_UPDATE;
            order.Status__c = globalvariableclass.TS_NEW;
            order.Informed_Customer__c = true;
            order.Case_Record_Type__c = ConstantsSLB.getKeyId('Temp Stop Subscription');
            order.Credit_Balance__c = 0; 
            order.Delivery_Charge__c = 0; 
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Request_Source__c = requestSource;  
            order.Subscriber_Account__c = thisAccount.Id;
            orderInsertList.add(order);
                
            //Create new case Record
            thisCase = new Case(); 
            //START: D-1950 2/10/15 JLedesma - Update old temp stop status
            thisCase.Publication__c = Upd.pubId;
            //END: D-1950 2/10/15 JLedesma - Update old temp stop status
            thisCase.Create_Follow_Up_Task__c = followUpTask;
            thisCase.Temp_Stop_Type__c = globalvariableclass.TS_UPDATE;
            thisCase.RecordTypeID = ConstantsSLB.getKeyId('Temp Stop Subscription');
            thisCase.Category__c =  globalvariableclass.TS_SUBSCRIPTION_REQUEST;
            thisCase.Subject = globalvariableclass.TS_SUBJECT;
            thisCase.Temp_Stop_Date__c = Upd.tempStopDate;
            thisCase.POP_Start_Date__c = Upd.earliestStartDate;
            thisCase.Temp_Stop_Qty__c = Upd.tempStopQty;
            thisCase.Restart_Date__c = Upd.restartDate;
            thisCase.Remarks__c = Upd.remarks;
            thisCase.Temp_Stop_VSub__c = wrapperSelected.subId;
            thisCase.AccountId = thisAccount.Id;            
            //START: D-1950 2/10/15 JLedesma - Update old temp stop status
            thisCase.Temp_Stop_Updated__c = Upd.tempStopToUpdate;
            //END: D-1950 2/10/15 JLedesma - Update old temp stop status
            //START UD-3293 11/25/15 RReyes
            if(parentCaseId != null){
                thisCase.ParentId = parentCaseId;
            }
            //END UD-3293 11/25/15 RReyes
                //Case urgency
                //START: UD-1332 5/20/2015 JLedesma urgent approval criteria.
                if (Upd.tempStopDate < Upd.earliestStartDate || Upd.restartDate < Upd.earliestStartDate ){
                //END: UD-1332 5/20/2015 JLedesma urgent approval criteria.
                        thisCase.Requires_Urgent_Approval__c = true;
                        //START: D-1483 1/8/15 Added by J.Ledesma ? Create follow up task.
                        thisCase.Create_Follow_Up_Task__c = true;
                        //END: D-1483 1/8/15 Added by J.Ledesma ? Create follow up task.
                        thisCase.Status =  globalvariableclass.TS_PENDING;
                        thisCase.Sub_Status__c = globalvariableclass.WAITING_URGENT_TEMPSTOP_RESTART_APPROVAL;
                } else {
                        thisCase.Requires_Urgent_Approval__c = false;
                        thisCase.Status = globalvariableclass.TS_CLOSED; 
                        thisCase.Sub_Status__c = globalvariableclass.TEMP_STOP_APPROVED;
                    //START D-4387 04Feb2016 Added By C. Lin - Separate Approved Case List
                    caseListApproved.add(thisCase);
                    //END D-4387 04Feb2016 Added By C. Lin
                }
            caseList.add(thisCase);
            
            //Create new temp stop record
            Temp_Stop__c tpRecord = new Temp_Stop__c ();
            tpRecord.Temp_Stop_Date__c = wrapperSelected.tempStopDate; 
            tpRecord.Restart_Date__c = wrapperSelected.restartDate; 
            tpRecord.Remarks__c = wrapperSelected.remarks;
            tpRecord.Temp_Stop_Qty__c = wrapperSelected.tempStopQty;

            if (thisCase.Status == globalvariableclass.TS_CLOSED){
                tempStopInsertList.add(tpRecord);
            }
            
            // Update Old Temp Stop Record (applicable only to Update and Cancel Temp Stop Request)
            Temp_Stop__c thisTempStop = new Temp_Stop__c ();
            //START: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop

            if(thisCase.Status == globalvariableclass.TS_CLOSED ){
                thisTempStop.Id = Upd.tempStopId;
                thisTempStop.Cancelled__c = True;
                oldTempStopUpdateList.add(thisTempStop);
            }
            //END: UD-1327 6/22/2015 / JLedesma / Remove Auto Approval of Update Temp Stop

            //Create new Vendor Subscription Temp Stop Record(junction object) to associate Temp Stop to Subscription Vendor
            Vendor_Temp_Stop__c thisSubTemp = new Vendor_Temp_Stop__c ();
            thisSubTemp.Subscription_Vendor__c = Upd.subId;
            thisSubTemp.Temp_Stop__c = tpRecord.Id;
            //START: D-1808 JLedesma 2/2/2015 Check non publication dates.
            thisSubTemp.Publication__c = Upd.pubId;
            //END: D-1808 JLedesma 2/2/2015 Check non publication dates.
            //Start: UD-1191/1192 James 05/15/2015  
            if (thisCase.Status == globalvariableclass.TS_CLOSED){
                vendorTempStopList.add(thisSubTemp);
            }
            //End: UD-1191/1192 James 05/15/2015
            //Create new Case Subscription (Vendor) record                      
            Case_Vendor_Subscription__c casSub = new Case_Vendor_Subscription__c();
            casSub.Case__c = thisCase.Id;
            casSub.Account__c = thisAccount.Id;
            casSub.Subscription_Vendor__c = Upd.subId; 
            vendorCaseSubs.add(casSub);
            
        }
    } else if (selectedTempStopType == globalvariableclass.TS_RADIO_CANCEL_TEMP_STOP){
     
        for (SelectedWrapper Can : cancelListWrapper ){
                
            //Create new order record                        
            Order__c order = new Order__c();
            order.Account__c = thisAccount.Id;
            order.Order_Type__c = globalvariableclass.TS_TEMP_STOP;
            order.Temp_Stop_Type__c = globalvariableclass.TS_CANCEL;
            order.Status__c = globalvariableclass.TS_NEW;
            order.Informed_Customer__c = true;
            order.Case_Record_Type__c = ConstantsSLB.getKeyId('Temp Stop Subscription');
            order.Credit_Balance__c = 0; 
            order.Delivery_Charge__c = 0; 
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Request_Source__c = requestSource;  
            order.Subscriber_Account__c = thisAccount.Id;
            orderInsertList.add(order);
            
            //Create new case Record
            thisCase = new Case(); 
            thisCase.Create_Follow_Up_Task__c = followUpTask;
            thisCase.Temp_Stop__c = Can.tempstopid;
            thisCase.Temp_Stop_Type__c = globalvariableclass.TS_CANCEL;
            thisCase.RecordTypeID = ConstantsSLB.getKeyId('Temp Stop Subscription');
            thisCase.Category__c = globalvariableclass.TS_SUBSCRIPTION_REQUEST;
            thisCase.Subject = globalvariableclass.TS_SUBJECT;
            thisCase.Temp_Stop_Date__c = Can.tempStopDate;
            thisCase.POP_Start_Date__c = Can.earliestStartDate;
            thisCase.Temp_Stop_Qty__c = Can.tempStopQty;
            thisCase.Restart_Date__c = Can.restartDate;
            thisCase.Remarks__c = Can.remarks;
            thisCase.Temp_Stop_VSub__c = wrapperSelected.subId;
            //START: D-2163 JLedesma 2/11/2015 Added Account field.
            thisCase.AccountId = thisAccount.Id;
            //END: D-2163 JLedesma 2/11/2015 Added Account field.
            //START UD-3293 11/25/15 RReyes
            if(parentCaseId != null){
                thisCase.ParentId = parentCaseId;
            }
            //END UD-3293 11/25/15 RReyes            
                //Case urgency
                if (Can.tempStopDate == Date.Today() + 1){
                    thisCase.Requires_Urgent_Approval__c = true;
                    //START: D-1483 1/8/15 Added by J.Ledesma ? Create follow up task.
                    thisCase.Create_Follow_Up_Task__c = true;
                    //END: D-1483 1/8/15 Added by J.Ledesma ? Create follow up task.
                    thisCase.Status = globalvariableclass.TS_PENDING;
                    thisCase.Sub_Status__c = globalvariableclass.WAITING_URGENT_TEMPSTOP_RESTART_APPROVAL;
                } else {
                    thisCase.Requires_Urgent_Approval__c = false;
                    thisCase.Status =  globalvariableclass.TS_CLOSED;
                    thisCase.Sub_Status__c = globalvariableclass.TEMP_STOP_APPROVED;
                    //START D-4387 04Feb2016 Added By C. Lin - Separate Approved Case List
                    caseListApproved.add(thisCase);
                    //END D-4387 04Feb2016 Added By C. Lin
                }
            caseList.add(thisCase);
            // Update Old Temp Stop Record (applicable only to Update and Cancel Temp Stop Request)
            Temp_Stop__c thisTempStop = new Temp_Stop__c ();
            thisTempStop.Id = Can.tempStopId;
            thisTempStop.Cancelled__c = True;

            //Create new Case Subscription (Vendor) record                      
            Case_Vendor_Subscription__c casSub = new Case_Vendor_Subscription__c();
            casSub.Case__c = thisCase.Id;
            casSub.Account__c = thisAccount.Id;
            casSub.Subscription_Vendor__c = Can.subId; 
            vendorCaseSubs.add(casSub);   
            //D-0689
            if(thisCase.Status ==  globalvariableclass.TS_CLOSED){
                oldTempStopUpdateList.add(thisTempStop);
            }              
        }
    } else {
    
        for (SelectedWrapper tsList : tempStopRequestList) {
                subVendId.add(tsList.subId);
        }

            List<Subscription_Vendor__c> subVenList = [SELECT Id, Recipient__r.Address__r.Postal_Code__r.Name FROM Subscription_Vendor__c WHERE Id IN: subVendId];
            if(subVenList.size()>0) {
                    try {   
                        for (Subscription_Vendor__c sv: subVenList) {
                            String pCode = sv.Recipient__r.Address__r.Postal_Code__r.Name;
                            postalSectorCodeSet.add(Decimal.valueOf(pCode.subString(0,2)));
                        }
                        List<Post_Sector_Ops_Rep_Mapping__c> psormList = [SELECT Id, Vendor_Ops__c, Postal_Sector_Code__c FROM Post_Sector_Ops_Rep_Mapping__c WHERE Postal_Sector_Code__c = :postalSectorCodeSet];
                        for(Post_Sector_Ops_Rep_Mapping__c psorm : psormList) {
                            postalSectorCodeSet_vendorOps_map.put(psorm.Postal_Sector_Code__c, psorm.Vendor_Ops__c);
                        }
                    }
                    catch(Exception e) {
                    }
                }
        
            for (SelectedWrapper tempstop : tempStopRequestList ){ 
            
                //Create new order record                        
                Order__c order = new Order__c();
                order.Account__c = thisAccount.Id;
                order.Order_Type__c = globalvariableclass.TS_TEMP_STOP;
                order.Temp_Stop_Type__c = globalvariableclass.TS_CREATE;
                order.Status__c = globalvariableclass.TS_NEW;
                order.Informed_Customer__c = true;
                order.Case_Record_Type__c = ConstantsSLB.getKeyId('Temp Stop Subscription');
                order.Credit_Balance__c = 0; 
                order.Delivery_Charge__c = 0; 
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                order.Request_Source__c = requestSource;  
                order.Subscriber_Account__c = thisAccount.Id;
                orderInsertList.add(order);
                
                //Create new case Record
                thisCase = new Case(); 
                //START: D-1950 2/10/15 JLedesma - Update old temp stop status
                thisCase.Publication__c = tempstop.pubId;
                //END: D-1950 2/10/15 JLedesma - Update old temp stop status
                thisCase.Create_Follow_Up_Task__c = followUpTask;
                thisCase.Temp_Stop_Type__c = globalvariableclass.TS_CREATE;
                thisCase.RecordTypeID = ConstantsSLB.getKeyId('Temp Stop Subscription');
                thisCase.Category__c = globalvariableclass.TS_SUBSCRIPTION_REQUEST;
                thisCase.Subject = globalvariableclass.TS_SUBJECT;
                thisCase.Temp_Stop_Date__c = tempstop.tempStopDate;
                thisCase.POP_Start_Date__c = tempstop.earliestStartDate;
                thisCase.Temp_Stop_Qty__c = tempstop.tempStopQty;
                thisCase.Restart_Date__c = tempstop.restartDate;
                thisCase.Remarks__c = tempstop.remarks;
                thisCase.Temp_Stop_VSub__c = tempstop.subId;
                thisCase.AccountId = thisAccount.Id;
                //START UD-3293 11/25/15 RReyes
                if(parentCaseId != null){
                    thisCase.ParentId = parentCaseId;
                }
                //END UD-3293 11/25/15 RReyes
                    //Case urgency
                    //START: UD-1332 5/20/2015 JLedesma urgent approval criteria.
                    if (tempstop.tempStopDate < tempstop.earliestStartDate || tempstop.restartDate < tempstop.earliestStartDate ){
                    //END: UD-1332 5/20/2015 JLedesma urgent approval criteria.
                            thisCase.Requires_Urgent_Approval__c = true;
                            //START: D-1483 1/8/15 Added by J.Ledesma ? Create follow up task.
                            thisCase.Create_Follow_Up_Task__c = true;
                            //END: D-1483 1/8/15 Added by J.Ledesma ? Create follow up task.
                            thisCase.Status = globalvariableclass.TS_PENDING;
                            thisCase.Sub_Status__c = globalvariableclass.WAITING_URGENT_TEMPSTOP_RESTART_APPROVAL;
                    } else {
                            thisCase.Requires_Urgent_Approval__c = false;
                            thisCase.Status = globalvariableclass.TS_CLOSED;
                            thisCase.Sub_Status__c = globalvariableclass.TEMP_STOP_APPROVED;
                        //START D-4387 04Feb2016 Added By C. Lin - Separate Approved Case List
                        caseListApproved.add(thisCase);
                        //END D-4387 04Feb2016 Added By C. Lin
                    }
                caseList.add(thisCase);
                
            
                //Create new temp stop record
                Temp_Stop__c tpRecord = new Temp_Stop__c ();
                tpRecord.Temp_Stop_Date__c = thisCase.Temp_Stop_Date__c; 
                tpRecord.Restart_Date__c = thisCase.Restart_Date__c; 
                tpRecord.Remarks__c = thisCase.Remarks__c;
                tpRecord.Temp_Stop_Qty__c = tempstopwrapper.tempStopQty;
                
                if (thisCase.Status == globalvariableclass.TS_CLOSED){
                    tempStopInsertList.add(tpRecord);
                }
                
                Decimal postalSectorCode;
                //Create Task assigned to Vendor Ops
                for (Subscription_Vendor__c sv: subVenList) {
                    String pCode = sv.Recipient__r.Address__r.Postal_Code__r.Name;
                    if(pCode!=NULL){
                        postalSectorCode = Decimal.valueOf(pCode.subString(0,2));
                    }
                    Id vendorOpId = postalSectorCodeSet_vendorOps_map.get(postalSectorCode);
                    
                    //Case urgency
                    if (tempstop.tempStopDate <= tempstop.earliestStartDate || tempstop.restartDate <= tempstop.earliestStartDate ){
                        Task t= new task();
                        t.OwnerId = vendorOpId;
                        t.Subject = globalvariableclass.TS_TASK_SUBJECT;
                        t.ActivityDate = system.today();
                        t.WhatId = thisCase.Id;
                        t.Status = 'Open';
                        
                        if (thisCase.Status == 'Pending') {
                        taskList.add(t);
                        }
                    }
                }
                
                //Create new Vendor Subscription Temp Stop Record(junction object) to associate Temp Stop to Subscription Vendor
                Vendor_Temp_Stop__c thisSubTemp = new Vendor_Temp_Stop__c ();
                thisSubTemp.Subscription_Vendor__c = tempstop.subId;
                thisSubTemp.Temp_Stop__c = tpRecord.Id;
               //START: D-1808 JLedesma 2/2/2015 Check non publication dates.
                thisSubTemp.Publication__c = tempstop.pubId;
                //END: D-1808 JLedesma 2/2/2015 Check non publication dates.
                //Start: UD-1191/1192 James 05/15/2015  
                if (thisCase.Status == globalvariableclass.TS_CLOSED){
                    vendorTempStopList.add(thisSubTemp);
                }
                //End: UD-1191/1192 James 05/15/2015
                //Create new Case Subscription (Vendor) record                      
                Case_Vendor_Subscription__c casSub = new Case_Vendor_Subscription__c();
                casSub.Case__c = thisCase.Id;
                casSub.Account__c = thisAccount.Id;
                casSub.Subscription_Vendor__c = tempstop.subId; 
                vendorCaseSubs.add(casSub);
            }
        
    
     }  
    //Insert Orders
        insert orderInsertList;
        
    //Relate cases to orders then insert these cases
        Integer indexNumber = 0;
        for(Case c : caseList) {
            c.Order__c = orderInsertList[indexNumber].Id;
            indexNumber++;
        }
        insert caseList;
              
    //Insert Task
   /* indexNumber = 0;
        for(Task tk : taskList) {
            tk.WhatId = caseList[indexNumber].Id;
            tk.WhoId = caseList[IndexNumber].OwnerId;
            tk.Subject = 'Follow up';
            tk.Status = 'Open';
            tk.Priority = 'Normal';
            indexNumber++;
        }
        insert taskList;*/
        
    //Relate temp stops to cases then insert them
        //if (thisCase.Status == 'Closed') { //START END D-4387 04Feb2016 Added By C. Lin - Remove condition since there can be multiple cases
            //START D-4387 04Feb2016 Added By C. Lin - Map temp stop to correct approved Case
            /*indexNumber = 0;
            
            for(Temp_Stop__c ts : tempStopInsertList) {
                ts.Order__c = orderInsertList[indexNumber].Id;
                ts.Case__c = caseList[indexNumber].Id;
                indexNumber = indexNumber +1;
                
                system.debug('insert recordddd '+ indexNumber + ' ' + ts.Case__c);
            }*/
            
            if(caseListApproved.size() == tempStopInsertList.size()) {
                for(Integer i = 0; i < caseListApproved.size(); i++) {
                    tempStopInsertList[i].Order__c = caseListApproved[i].Order__c;
                    tempStopInsertList[i].Case__c = caseListApproved[i].Id;
                }
            }
            //END D-4387 04Feb2016 Added By C. Lin

        insert tempStopInsertList; //} //START END D-4387 04Feb2016 Added By C. Lin
        
        map<Id, Id> mTSCas = new map<Id, Id>();
         if(tempStopInsertList.size()>0){
                for(Temp_Stop__c t: tempStopInsertList){
                    mTSCas.put(t.case__c,t.Id);
                }
            }
                for(Case c : caseList) {
                //START: D-2322 02/23/2015 JLedesma Updated logic for overlapping entries.
                    if(c.status == 'Closed' && c.Temp_Stop_Type__c != 'Cancel') {
                //END: D-2322 JLedesma Updated logic for overlapping entries.
                       c.Temp_stop__c = mTSCas.get(c.Id);     
                    } 
                    else {
                    }
                }
                update caseList;
        
    //Relate vendor subscription to temp stop records 
        //if (thisCase.Status == globalvariableclass.TS_CLOSED) { //START END D-4387 04Feb2016 Added By C. Lin - Remove condition since there can be multiple cases
            indexNumber = 0;
            for(Vendor_Temp_Stop__c vts : vendorTempStopList) {
                vts.Temp_Stop__c = tempStopInsertList[indexNumber].Id;
                indexNumber++;
            }
        insert vendorTempStopList;    //} //START END D-4387 04Feb2016 Added By C. Lin
        
    //Relate vendor subscription to cases
        indexNumber = 0;
        for(Case_Vendor_Subscription__c cvs : vendorCaseSubs) {
            cvs.Case__c = caseList[indexNumber].Id;
            indexNumber++;
        }
        insert vendorCaseSubs;
        
    //Update old temp stop records (for update and cancel only)
        if (selectedTempStopType == globalvariableclass.TS_RADIO_UPDATE_TEMP_STOP || selectedTempStopType == globalvariableclass.TS_RADIO_CANCEL_TEMP_STOP) {
            indexNumber = 0;
            for(Temp_Stop__c oldtemp : oldTempStopUpdateList) {
                oldtemp.Id = oldTempStopUpdateList[indexNumber].Id;
                indexNumber++;
            }
        update oldTempStopUpdateList; 
    }

return caseList;
}
}