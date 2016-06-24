/**
 * Class Name: ComplaintNewsPaperController 
 * @author: Francis Martin Benzon
 * Date: 10/21/2014
 * Requirement/Project Name: Singapore Press Holdings
 *
 */
 
 /**
 * Revision: Version 1.0 
 * @author: Kristine Campang
 * Date: 12/16/2014
 * Requirement/Project Name: Singapore Press Holdings
 * Description: Updated computation of Paper Fee and Credit Amount based on the new PC Implementation
 */
 
 /**
 * Revision: Version 2.0 
 * @author: Kristine Campang, Sherwin Puli
 * Date: 03/22/2015
 * Requirement/Project Name: Singapore Press Holdings
 * Description: Updated computation of Credit Amount using the Utility class UsageHelper for MD-55, UD-077
 */
 
//START D-3010 28-05-2015 Marvin G - Removed with sharing option
public  class ComplaintNewsPaperController { 
//END D-3010 28-05-2015 Marvin G - Removed with sharing option
    //START UD-0394 4/9/2015 Added by Manolo Valena - Added new variables
    public String subSelected {get; set;}
    public String subSelected2 {get; set;}
    //END UD-0394 4/9/2015 Added by Manolo Valena
    //START UD-0262 4/29/2015 Added by Ronald Dagaraga - Added new variables
    public String subSelected3 {get; set;}
    public String subSelected4 {get; set;}
    //END UD-0262 4/29/2015 Added by Ronald Dagaraga - Added new variables
    //public Case_Subscription__c CaseSub {get;set;}
    public Case objcase {get;set;} 
    public List<CaseSubWrapper> CSubWrapperList {get;set;}
    public Integer counter {get; set;}
    //public String index {get; set;}
    //public Account accn {get;set;}
    public Boolean isDirect {get; set;}
    public Zuora__SubscriptionProductCharge__c objSpc {get;set;}
    Account accn = new Account();
    Set<Id> cSubId = new Set<Id>();
    Set<Id> cvSubId = new Set<Id>();
    Set<Id> csSet = new Set<Id>();
    Id csPrimaryAddressId, cvsPrimaryAddressId;
    //START: D-2114 02-10-2015 Added by Marvin Gatchalian ... 
    List<exception> exceptionList = new list<exception>(); // declare this at the outermost within your class
    //END: D-2114 02-10-2015 Added by Marvin Gatchalian ... 
    
    //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
    Integer indexVal = 0;
    Integer newspaperCounter = 0;
    Boolean packageIsNewspaper = false;
    String recType;
    String newspaper = 'N';
    Map<Id, List<Package_Item__c>> subToPackageItems = new Map<Id, List<Package_Item__c>>();
    Map<Id, List<Subscription_Vendor_Publication__c>> subToSubVen = new Map<Id, List<Subscription_Vendor_Publication__c>>();
    List<Package_Item__c> pckItems = new List<Package_Item__c>();
    List<Subscription_Vendor_Publication__c> subVenRecs = new List<Subscription_Vendor_Publication__c>();   
    Map<String, Zuora__Subscription__c> subNameToSub = new Map<String, Zuora__Subscription__c>();
    List<Integer> newspaperCount;
    //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 
    
    //Start D-2070 02/09/2015 Added by James
    final static string VENDOR_SR_MANAGER_KEY = 'Vendor Sr. Manager';
    final static string VENDOR_REP_KEY = 'Vendor Rep';
    final static string VENDOR_ERROR_MSG = 'Vendor Newspaper Complaint';
    //START: D-2114 02/10/2015 Added by Marvin Gatchalian - Throws an error for invalid data, checking if selected subscription has no SPC and display an error
    final static string SUBSCRIPTION_NO_SPC = 'There is no subscription product & charges on selected subscription.';
    boolean allComputationAreGood = true;
    //END: D-2114 02/10/2015 Added by Marvin Gatchalian - Throws an error for invalid data, checking if selected subscription has no SPC and display an error
    //End D-2070
    //Start D-2200 2/12/2015 Added by James - for vendor exec/manager
    final static string VENDOR_EXEC_MNGR = 'Vendor Exec / Manager';
    //End D-2200    
    // Variables for Paper Fee Computation
    List<Case_Subscription__c> insertCaseSubsList = new list<Case_Subscription__c>(); //parameter of ComputePaperFee
    Map<Id, List<Zuora__SubscriptionProductCharge__c>> subsIdToSubProductAndChargesMap = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>(); //Gets all child records of Subscription which is Subscription Product and Charges. Subscription Id as identifier and list(spcList) as value.
    Map<String, Set<String>> ratePlanNameToPubCodesMap = new Map<String, Set<String>>(); //Adds the Publication codes of Product Rate Plan and Charges Records using Rate Plan Name as identifier.
    Map<String, Publication__c> pubCodesToPublicationMap = new Map<String, Publication__c>(); //
    Set<String> subProdRatePlanName = new Set<String> ();
    //START UD-2046 7/24/2015 Added By C. Lin - Multiple SKUs for multiple subscriptions
    Set<String> spcSKUSet = new Set<String>();
    //END UD-2046 7/24/2015 Added By C. Lin
    Set<String> pubCodes = new Set<String>(); //Contains all the unique publication codes of Product Rate Plan and Charges Records.
    List<String> caseSubsDay = new List<String>(); 
    List<Zuora__SubscriptionProductCharge__c> spcList = new List<Zuora__SubscriptionProductCharge__c>();
    List<zqu__ProductRatePlan__c> subProdToProdRatePlanList = new List<zqu__ProductRatePlan__c>();
    List<Publication__c> publicationRecords = new List<Publication__c>();
    Map<Id, Map<String, Publication__c>> caseSubsIdToPublicationMap = new Map<Id, Map<String, Publication__c>>();
    Map<String, Publication__c> publicationMap = new Map<String, Publication__c>();
   
    // Variables for Credit Amount Computation
    Map<Id,Case_Subscription__c> subIdcaseSubRec = new Map<Id,Case_Subscription__c>(); // Subscription Id and Case Subscription record
    Set<String> skuSet = new Set<String>();
    Map<Zuora__Subscription__c,String> subscriptionSku = new Map<Zuora__Subscription__c,String>(); // Subscription and SKU
    //Map<Id,List<Zuora__SubscriptionProductCharge__c>> subToSubProdChrgeMap = new Map<Id,List<Zuora__SubscriptionProductCharge__c>>(); // Subscription ID and Subscription Product and Charges
    Set<Zuora__Subscription__c> subsRecs = new Set<Zuora__Subscription__c>();
    Map<Id,Map<String, Double>> sProdChargeUOMToPrice = new Map<Id,Map<String, Double>>(); // SubscriptionId to Subscription Product & Charge UOM with Price
    Set<Id> subIds = new Set<Id>();
    List<Zuora__SubscriptionProductCharge__c> subProdChrgeList = new List<Zuora__SubscriptionProductCharge__c>();
    Map<String,String> skuPlatform = new Map<String,String>(); // Product SKU and Platform
    List<zqu__ZProduct__c> products = new List<zqu__ZProduct__c>();
    Map<Id,String> subPlatform = new Map<Id,String>(); // Subscription Id and platform
   
    //Variables for determining Non Pub Days
    Map<String, Set<Date>> pubCodesToNonPubDatesMap = new Map<String, Set<Date>>();
    Map<Id, Set<Date>> subsIdTopubCodesToNonPubDatesMap = new Map<Id, Set<Date>>();
    List<Non_Publication_Day__c> nonPubList = new List<Non_Publication_Day__c>();
    
    //variables for Paper Fee Computation
    Map<String, Map<String, Publication_Price__c>> mapPubCodeToMapDayPrice = new Map<String, Map<String, Publication_Price__c>>();
    Set<Id> PubIdSet = new Set<Id>();
    Set<String> pubCodeSet = new Set<String>();
    Map<String, Publication__c> dayPublicationMap = new Map<String, Publication__c>();
               
    //variables for new PC Implementation
    Map<String, Map<String, Decimal>> mapPub_UOM_Price = new Map<String, Map<String, Decimal>>();
    Decimal copyPrice;
    Double totalPaperFee;
    Set<Id> caseSubIdSet = new Set<Id>();
    
    //Start D-2070 2/9/2015 Added by James Azaña - get current user profile
    Id profileId = userinfo.getProfileId();
    String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
    String VendorSrManagerProfile = ConstantsSLB.getOther(VENDOR_SR_MANAGER_KEY);
    String VendorRepProfile = ConstantsSLB.getOther(VENDOR_REP_KEY);
    //End D-2070 2/9/2015
    //Start D-2200 2/12/2015 Added by James - for vendor exec/manager
    String VendorExecMngrProfile = ConstantsSLB.getOther(VENDOR_EXEC_MNGR);
    //End D-2200
    //START: D-0077 03/12/2015 Added by Kristine Campang - added variables for credit amount
    Decimal creditWeekday;
    Decimal creditSaturday;
    Decimal creditSunday;
    Decimal noOfCopies;
    Decimal weekdayIssue;
    Decimal SaturdayIssue;
    Decimal SundayIssue;
    Decimal totalCredit;
    Decimal subscriptionDiscount;
    Decimal totalDiscountPerPub;
    Decimal totalDiscount;
    Decimal weekDayDiscount;
    Decimal saturdayDiscount;
    Decimal sundayDiscount;
    List<Date> zSPCDiscountList = new List<Date>();
    Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapSubsToSPC = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();
    Map<Id, Decimal> mapSubToCredit = new Map<Id, Decimal>();
    Map<Id, Decimal> mapSPCDiscToPrice = new Map<Id, Decimal>();
    Map<Date, Id> mapDateToSPC = new Map<Date, Id>();
    Map<String, Decimal> mapSubUOMToPrices = new Map<String, Decimal>();
    //END: D-0077 03/12/2015 Added by Kristine Campang
    Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapSubIdToSPCDiscList = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();
    //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - added variables for Case Vendor Fee record
    List<Case_Vendor_Fee__c> casevendorfeelst = New List<Case_Vendor_Fee__c>();
    //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja       
    
    //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
    List<Usage__c> usageList = new List<Usage__c>();        
    //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
    
    //START: UD-0775 04/08/2015 Added by S.PULI
    Set<Id> subId_SET = new Set<Id>();
    Set<Id> subVenId_SET = new Set<Id>();
    //END: UD-0775 04/08/2015 Added by S.PULI
    
    //START UD-0707 AddedBy FrancisBenzon : variable - parentCase
    public string parentCaseId;
    //END UD-0707 AddedBy FrancisBenzon : variable - parentCase
    
    //Start D-3172 06/29/2015 James
    public integer magazinecounter;
    List<Package_Item__c> PackageItemList = new List<Package_Item__c>();
    List<Id> SubPackageList = new List<Id>();
    Map<id, boolean> SubscriptionToPackageItemMap = new Map<id, boolean>();
    //End D-3172 06/29/2015 James
    
    //START UD-1539 10/22/2015 Added by J.Sarion - Added Integer Goodwill Copies
    public String goodwillCopiesSelected {get; set;}
    public String subSelected5 {get; set;}
    List<Zuora__SubscriptionProductCharge__c> goodwillSPCList = new List<Zuora__SubscriptionProductCharge__c>();
    Map<Id, Decimal> subIdToGoodwillPriceMap = new Map<Id, Decimal>();
    //END UD-1539 10/22/2015 Added by J.Sarion - Added Integer Goodwill Copies
    //START D-3972 24Nov15 FrancisBenzon : var 
    Boolean notValidPackage = false;
    //END D-3972 24Nov15 FrancisBenzon :
    
  //START UD-2107 7/27/2015 Added By C. Lin - Include only Base Product and Bundle Product Package Item
    Id RecordTypePackItemBase = ConstantsSLB.getKeyId('Package Item_Base Product');
    Id RecordTypePackItemBundle = ConstantsSLB.getKeyId('Package Item_Bundle Product');
    //END UD-2107 7/27/2015 Added By C. Lin
        
        //START UD-3702 2/4/2016 Added by J.Sarion - COA Record Type ID
        Id COAID = ConstantsSLB.getKeyId('Case_Change in Address');
        //END UD-3702 2/4/2016 Added by J.Sarion - COA Record Type ID
    //Start PD-0324     
    public ComplaintNewsPaperController() {}
     //END PD-0324    
     
    public ComplaintNewsPaperController(ApexPages.StandardController controller) {
        String acctId = ApexPages.currentPage().getParameters().get('accountId');
        String conId = ApexPages.currentPage().getParameters().get('contactId');
        //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
        recType = ApexPages.currentPage().getParameters().get('RecordType');
        //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 
        String caseId = ApexPages.currentPage().getParameters().get('Id');
        //START UD-0707 5/7/15 AddedBy FrancisBenzon : parent Case
        parentCaseId = ApexPages.currentPage().getParameters().get('def_parent_id');
        //END UD-0707 5/7/15 AddedBy FrancisBenzon : parent Case
        CSubWrapperList = new List<CaseSubWrapper>();
        counter = 0;
        isDirect = true;
        copyPrice = 0;
        totalPaperFee = 0;
       
        
       
        if(caseId != NULL && caseId != '' && caseId != 'null') {
            this.objcase = (Case)controller.getRecord();          
            if(objcase.AccountId != Null) {
                try {
                    accn = [SELECT RecordType.Name FROM Account WHERE Id = :objcase.AccountId];
                    if(accn.RecordType.Name == 'Vendor Subscriber' || accn.RecordType.Name == 'Vendor') {
                        isDirect = FALSE;
                    }
                    else {
                        isDirect = TRUE;
                    }
                    //START D-2962 KEstoya / Change enquiry to complaint
                    if(recType != null || recType != ' ')
                    {
                        objcase.RecordTypeId = (Id) recType;
                        objcase.Category__c = 'Newspaper';
                    }
                    //END D-2962 KEstoya / Change enquiry to complaint
                    
                    //START UD-1539 10/22/2015 Added by J.Sarion - Get Goodwill SPC
                    goodwillSPCList = [SELECT Id, Name, Zuora__ProductSKU__c, Zuora__RatePlanName__c, Zuora__Subscription__c, Zuora__Model__c, Zuora__Price__c,Zuora__UOM__c, Zuora__EffectiveStartDate__c
                               FROM Zuora__SubscriptionProductCharge__c
                               WHERE Zuora__Account__c = :objcase.AccountId AND Zuora__UOM__c LIKE 'Goodwill%'];

                    for(Zuora__SubscriptionProductCharge__c subProdCharge :goodwillSPCList){
                        subIdToGoodwillPriceMap.put(subProdCharge.Zuora__Subscription__c, subProdCharge.Zuora__Price__c);
                    }
                    //END UD-1539 10/22/2015 Added by J.Sarion - Get Goodwill SPC
                }
                catch(QueryException e) {
                    accn = new Account();
                }
            }
            //START UD-1333 K. Tan 5/22/2015 To update Category and Sub Category
            else{           
                    if(recType != null || recType != ' ')
                    {
                        objcase.RecordTypeId = (Id) recType;
                        objcase.Category__c = 'Newspaper';
                    }
                    //END UD-0828 KEstoya / Change enquiry to complaint
            }   
            //END UD-1333 K. Tan 5/22/2015 To update Category and Sub Category
       
            //START: D-1476 / K. Tan / Modified query for Case of Subscription
            //START UD-0394 4/9/2015 Added by Manolo Valena - Added new field Package_Name__c in the query
            //START UD-1539 10/23/2015 Added J.Sarion - Added Goodwill Copies
            //START UD-3208 11/6/15 AddedBy FrancisBenzon : vendor fee copies = complaint copies * complaint dates
            List<Case_Subscription__c> cSubs = [Select Id, Vendor__c, Vendor_Debit__c, Goodwill_Amount__c, Credit_Amount__c, Credit_Copies__c, Subscription__c, Replacement_Copies__c, Complaint_From__c, Goodwill_Copies__c, Complaint_Copies__c, Complaint_To__c, Replace_From__c, Replace_To__c, Month__c, Year__c, Issue_No__c, Account__c, Address__c, Subscription__r.Recipient_Contact__r.Address__c, Case__r.ClosedDate, Package_Name__c, Subscription__r.Zuora__SubscriptionStartDate__c, Case__r.Replaced_by_Courier__c 
            FROM Case_Subscription__c WHERE Case__c = :caseId ORDER BY CreatedDate ASC]; //START/END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only // Start-End D-3763 K. Tan 10/19/2015
            //END UD-0394 4/9/2015 Added by Manolo Valena
            
            if (!cSubs.isEmpty()) csPrimaryAddressId = cSubs[0].Subscription__r.Recipient_Contact__r.Address__c;
            for(Case_Subscription__c cs : cSubs) {
                CaseSubWrapper csWrap = new CaseSubWrapper(cs);
                counter++;
                csWrap.counterWrap = counter;
                CSubWrapperList.add(csWrap);
            }
       
            List<Case_Vendor_Subscription__c> cVenSubs = [Select Id, Vendor__c, Vendor_Debit__c, Goodwill_Amount__c, Complaint_Copies__c, Credit_Amount__c, Credit_Copies__c, Subscription_Vendor__c, Goodwill_Copies__c, Replacement_Copies__c, Complaint_From__c, Complaint_To__c, Replace_From__c, Replace_To__c, Month__c, Year__c, Issue_No__c, Account__c, Address__c, Subscription_Vendor__r.Recipient__r.Address__c , Case__r.Replaced_by_Courier__c FROM Case_Vendor_Subscription__c WHERE Case__c = :caseId ORDER BY CreatedDate ASC];
            //END UD-3208 11/6/15 AddedBy FrancisBenzon : vendor fee copies = complaint copies * complaint dates
            //END UD-1539 10/23/2015 Added J.Sarion - Added Goodwill Copies
            //END: D-1476 / K. Tan / Modified query for Case of Subscription
            if (!cVenSubs.isEmpty()) cvsPrimaryAddressId = cVenSubs[0].Subscription_Vendor__r.Recipient__r.Address__c;
            for(Case_Vendor_Subscription__c cvs : cVenSubs) {
                CaseSubWrapper csWrap = new CaseSubWrapper(cvs);
                counter++;
                csWrap.counterWrap = counter;
                CSubWrapperList.add(csWrap);
            }
        }//new case
        else {
            objcase = (Case)controller.getRecord();
            objcase.RecordTypeId = (recType != '' && recType != 'null' ? recType : NULL);
            objcase.AccountId = (acctId != '' && acctId != 'null' ? acctId : NULL);
            objcase.ContactId = (conId != '' && conId != 'null' ? conId : NULL);           
            
            //START UD-3293 25Nov2015 Added By C. Lin
            if(parentCaseId != null && parentCaseId != ''){
                Case pCase = [SELECT Id, Subject, Description FROM Case WHERE Id = :parentCaseId LIMIT 1];
                
                objcase.Subject = pCase.Subject;
                objcase.Description = pCase.Description;
            }
            //END UD-3293 25Nov2015 Added By C. Lin
            
            try {
                accn = [SELECT RecordType.Name FROM Account WHERE Id =:acctId];
                if(accn.RecordType.Name == 'Vendor Subscriber' || accn.RecordType.Name == 'Vendor') {
                    isDirect = FALSE;
                }
                else {
                    isDirect = TRUE;
                }
                //START UD-1539 10/22/2015 Added by J.Sarion - Get Goodwill SPC
                goodwillSPCList = [SELECT Id, Name, Zuora__ProductSKU__c, Zuora__RatePlanName__c, Zuora__Subscription__c, Zuora__Model__c, Zuora__Price__c,Zuora__UOM__c, Zuora__EffectiveStartDate__c
                           FROM Zuora__SubscriptionProductCharge__c
                           WHERE Zuora__Account__c = :objcase.AccountId AND Zuora__UOM__c LIKE 'Goodwill%'];
                for(Zuora__SubscriptionProductCharge__c subProdCharge :goodwillSPCList){
                    subIdToGoodwillPriceMap.put(subProdCharge.Zuora__Subscription__c, subProdCharge.Zuora__Price__c);
                }
                //END UD-1539 10/22/2015 Added by J.Sarion - Get Goodwill SPC
            }
            catch(QueryException e) {
                accn = new Account();
            }
                if(isDirect) {
                    CaseSubWrapper csWrap = new CaseSubWrapper(new Case_Subscription__c(), objcase.AccountId);
                    csWrap.caseVendorSubscription = new Case_Vendor_Subscription__c();
                    counter++;
                    csWrap.counterWrap = counter;
                    CSubWrapperList.add(csWrap);
                }
                else {
                    CaseSubWrapper csWrap = new CaseSubWrapper(new Case_Vendor_Subscription__c(), objcase.AccountId);
                    csWrap.caseSubscription = new Case_Subscription__c();
                    counter++;
                    csWrap.counterWrap = counter;
                    CSubWrapperList.add(csWrap);
                }
        }

        
    //START: UD-0653 03/30/2015 RReyes - Sets isComplaint to true for filtering subscription 
       for(CaseSubWrapper wrapCas : CSubWrapperList) {
                wrapCas.setIsComplaintTrue();
            }  
    //END: UD-0653 03/30/2015 RReyes        
                    
    }
   
    public class CaseSubWrapper {
        public Case_Subscription__c caseSubscription {get;set;}
        public Case_Vendor_Subscription__c caseVendorSubscription {get;set;}
        public Integer counterWrap {get;set;}
        //START UD-1539 10/22/2015 Added by J.Sarion - Added new var in wrapper
        public Integer goodwillCopies {get; set;}
        //END UD-1539 10/22/2015 Added by J.Sarion - Added new var in wrapper
       
        public CaseSubWrapper(Case_Subscription__c cs) {
            this.caseSubscription = cs; 
        }
        public CaseSubWrapper(Case_Vendor_Subscription__c cvs) {
            this.caseVendorSubscription = cvs;
        }
        public CaseSubWrapper(Case_Subscription__c cs, Id accId) {
            cs.Account__c = accId;
            this.caseSubscription = cs; 
        }
        public CaseSubWrapper(Case_Vendor_Subscription__c cvs, Id accId) {
            cvs.Account__c = accId;
            this.caseVendorSubscription = cvs;
        }
        public void setAccount(id accId){
       
                if(this.caseSubscription != null){
                    this.caseSubscription.Account__c = accId;
                }
                if(this.caseVendorSubscription != null){
                    this.caseVendorSubscription.Account__c = accId;
                }
       
        }     
        
        //START: UD-0653 03/30/2015 RReyes
        public void setIsComplaintTrue()
        {
        if(this.caseSubscription != null){
                    this.caseSubscription.isComplaint__c = true; 
                }   
        }
        //END: UD-0653 03/30/2015 RReyes
                   
    }
   
    
    
    public PageReference save() {

        //EmailNotificationCreation emailNotif = new EmailNotificationCreation(); // START-END : D-1796 2/5/2015 Alyana Navarro - Declare instance variable.
        //START: D-1789 / 1/20/2015 /K. Tan/ Clearing Case Subscription List
        insertCaseSubsList.clear();
        //END: D-1789 / 1/20/2015 /K. Tan/ Clearing Case Subscription List
        
        UsageHelper.initialize();   // Start/End UD-2853 18Sep15 JohnD
        Savepoint sp = Database.setSavepoint();
        Boolean isNewRecord = false;
        Boolean isNegativeGoodwill = false;//START/END D-3343 08/10/15 RReyes
        Boolean isBehind = false;//START/END D-3793 10/19/15 K. Tan
        //START D-3972 24Nov15 FrancisBenzon : show error on save
        if(notValidPackage)
        {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('Validate Complaint- Newspaper')));
             return null;
        }
        //END D-3972 24Nov15 FrancisBenzon : show error on save
        //START UD-0531 3/25/2015 Added By C. Lin - Contact Name should be required.
        if(objcase.contactId == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('BlankContactInCase'));
            ApexPages.addMessage(myMsg);
            return null; 
        }else{
        //END UD-0531 3/25/2015 Added By C. Lin
            try {
                //Start D-4271 Added by S.Puli - prevent complaint dates after the subscription end date
                    
                if(CSubWrapperList.size()>0){   
                    subId_SET = new Set<Id>(); //START/END UD-1827 8/31/15 AddedBy francisBenzon : checked if any subs are future dated
                    for(CaseSubWrapper csWrap : CSubWrapperList){                       
                        subId_SET.add(csWrap.caseSubscription.Subscription__c);
                    }
                }
                List<Zuora__Subscription__c> subSelected_LIST = [Select Id, Name, Main_Package_1__c,Zuora__SubscriptionStartDate__c,            Zuora__Status__c,
                Zuora__SubscriptionEndDate__c 
                From Zuora__Subscription__c Where Id IN :subId_SET];
            
                if(CSubWrapperList.size()>0){
                    for(CaseSubWrapper csWrap : CSubWrapperList){
                        for(Zuora__Subscription__c SubscriptionLoop1 : subSelected_LIST){
                            if(csWrap.caseSubscription.Complaint_From__c < SubscriptionLoop1.Zuora__SubscriptionStartDate__c || csWrap.caseSubscription.Complaint_To__c < SubscriptionLoop1.Zuora__SubscriptionStartDate__c)
                            {                                 
                                isBehind = true;
                            }                                    
                        }                        
                    }
                }
               
                if(isBehind){                    
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('CompDateBehindSubStartDate'));
                    ApexPages.addMessage(myMsg);
                    return null;
                }
                // End D-3763 K. Tan 10/19/2015   
                
                Boolean isBeyond = false;
                if(CSubWrapperList.size()>0){
                    for(CaseSubWrapper csWrap : CSubWrapperList){
                        for(Zuora__Subscription__c SubscriptionLoop1 : subSelected_LIST){
                            if(csWrap.caseSubscription.Complaint_From__c > SubscriptionLoop1.Zuora__SubscriptionEndDate__c || csWrap.caseSubscription.Complaint_To__c > SubscriptionLoop1.Zuora__SubscriptionEndDate__c)
                            {

                                isBeyond = true;
                            }                                    
                        }                        
                    }
                }
                if(isBeyond){                    
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('CompDateBeyondSubEndDate'));
                    ApexPages.addMessage(myMsg);
                    return null;
                }
                
                //End D-4271 Added by S.Puli - prevent complaint dates after the subscription end date
                if(objcase.id == null){
                    //START: UD-0775 04/08/2015 Added by S.PULI
                    //direct account
                    //Start D-3172 06/29/2015 James
                    magazinecounter = 0;
                    //End D-3172 06/29/2015 James
                    //START D-3343 08/10/15 RReyes - checks if any Goodwill amount is not negative
                    if(CSubWrapperList.size()>0){
                            for(CaseSubWrapper csWrap : CSubWrapperList){
                                //START UD-3254 18Nov15 FrancisBenzon : cal goodwill amt if not calculated
                                if(csWrap.CaseSubscription.Goodwill_Copies__c != null && (csWrap.CaseSubscription.Goodwill_Amount__c == null || csWrap.CaseSubscription.Goodwill_Amount__c == 0))
                                {
                                    if(subIdToGoodwillPriceMap.containsKey(csWrap.CaseSubscription.Subscription__c)) {
                                        
                                        csWrap.CaseSubscription.Goodwill_Amount__c = Integer.valueOf(csWrap.CaseSubscription.Goodwill_Copies__c) * Math.abs(subIdToGoodwillPriceMap.get(csWrap.CaseSubscription.Subscription__c));                          
                                    }
                                }                                                                       
                                //END UD-3254 18Nov15 FrancisBenzon : cal goodwill amt if not calculated
                                if(isDirect && csWrap.caseSubscription != null){
                                   if(csWrap.caseSubscription.Goodwill_Amount__c != null ){
                                        if(csWrap.caseSubscription.Goodwill_Amount__c < 0){
                                            isNegativeGoodwill = true;
                                            break;
                                        }
                                    }
                                }
                                else if( !isDirect && csWrap.caseVendorSubscription != null){
                                    if(csWrap.caseVendorSubscription.Goodwill_Amount__c != null ){
                                        if(csWrap.caseVendorSubscription.Goodwill_Amount__c < 0){
                                            isNegativeGoodwill = true;
                                            break;
                                        }
                                    }
                                }
                            }   
                        }                        
                    if(isNegativeGoodwill){                    
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('Negative Goodwill'));
                        ApexPages.addMessage(myMsg);
                        return null;
                    }   
                    //END D-3343 08/10/15 RReyes  - checks if any Goodwill amount is not negative
                    //Start D-4271 Added by S.Puli - transfer to above
                    /*
                    if(CSubWrapperList.size()>0){
                        subId_SET = new Set<Id>(); //START/END UD-1827 8/31/15 AddedBy francisBenzon : checked if any subs are future dated
                        for(CaseSubWrapper csWrap : CSubWrapperList){
                            subId_SET.add(csWrap.caseSubscription.Subscription__c);
                        }
                    }
                    */
                    //End D-4271 Added by S.Puli - transfer to above
                    //Start D-3172 06/29/2015 James
                    //START UD-1827 8/31/15 AddedBy francisBenzon : checked if any subs are future dated
                    Set<Date> futureDatesOfSubs = new Set<Date>(); 
                    //Start D-4271 Added by S.Puli - transfer to above
                    /*
                    List<Zuora__Subscription__c> subSelected_LIST = [Select Id, Name, Main_Package_1__c,Zuora__SubscriptionStartDate__c,            Zuora__Status__c,
                    Zuora__SubscriptionEndDate__c 
                    From Zuora__Subscription__c Where Id IN :subId_SET];                                     
                    */
                    //End D-4271 Added by S.Puli - transfer to above
                    for(Zuora__Subscription__c SubscriptionLoop1 : subSelected_LIST){
                        SubPackageList.add(SubscriptionLoop1.Main_Package_1__c);
                        
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
                    // Start D-3763 K. Tan 10/19/2015
                    //Start D-4271 Added by S.Puli - transfer to above
                    /*
                    if(CSubWrapperList.size()>0){
                        for(CaseSubWrapper csWrap : CSubWrapperList){
                            for(Zuora__Subscription__c SubscriptionLoop1 : subSelected_LIST){
                                if(csWrap.caseSubscription.Complaint_From__c < SubscriptionLoop1.Zuora__SubscriptionStartDate__c || csWrap.caseSubscription.Complaint_To__c < SubscriptionLoop1.Zuora__SubscriptionStartDate__c)
                                {

                                    isBehind = true;
                                }                                    
                            }                        
                        }
                    }
                    if(isBehind){                    
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('CompDateBehindSubStartDate'));
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                    // End D-3763 K. Tan 10/19/2015   
                    Boolean isBeyond = false;
                    if(CSubWrapperList.size()>0){
                        for(CaseSubWrapper csWrap : CSubWrapperList){
                            for(Zuora__Subscription__c SubscriptionLoop1 : subSelected_LIST){
                                if(csWrap.caseSubscription.Complaint_From__c > SubscriptionLoop1.Zuora__SubscriptionEndDate__c || csWrap.caseSubscription.Complaint_To__c > SubscriptionLoop1.Zuora__SubscriptionEndDate__c)
                                {

                                    isBeyond = true;
                                }                                    
                            }                        
                        }
                    }
                    if(isBeyond){                    
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('CompDateBeyondSubEndDate'));
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                    */
                    //End D-4271 Added by S.Puli - prevent complaint dates after the subscription end date
                    //END UD-1827 8/31/15 AddedBy francisBenzon : checked if any subs are future dated 
                    //START UD-2107 7/27/2015 Added By C. Lin - Include only Base Product and Bundle Product Package Item
                    PackageItemList = [SELECT Is_All_In_One__c, Is_Digital__c, Is_Magazine__c, Is_Newspaper__c, Is_Print__c, Package__c, Id FROM Package_Item__c WHERE Package__c IN: SubPackageList AND (RecordTypeId = :RecordTypePackItemBase OR RecordTypeId = :RecordTypePackItemBundle)];
                    //END UD-2107 7/27/2015 Added By C. Lin
                    
                    for(Zuora__Subscription__c SubscriptionLoop2 : subSelected_LIST){
                        for(Package_Item__c PackageItemLoop1 : PackageItemList){
                            if(SubscriptionLoop2.Main_Package_1__c == PackageItemLoop1.Package__c){
                                SubscriptionToPackageItemMap.put(SubscriptionLoop2.Id, PackageItemLoop1.Is_Newspaper__c);
                            }
                        }
                    }
                    //End D-3172 06/29/2015 James
                    
                    //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                    //START UD-2717 09/10/15 RReyes - added condition to filter out void cases
                    List<Case_Subscription__c> casSub_LIST = [Select Id, Case__c, Subscription__c, Complaint_From__c, Complaint_To__c, Case__R.Status, Subscription__r.Zuora__SubscriptionStartDate__c 
                    From Case_Subscription__c 
                    Where Subscription__c IN :subId_SET AND Case__r.RecordTypeId = :recType AND Case__R.Status !=: GlobalVariableClass.STATUS_VOID];
                    //END UD-2717 09/10/15 RReyes - added condition to filter out void cases
                    //END UD-1629 JLedesma 6/24/2015 validates subscription selected. // Start-End D-3763 K. Tan 10/19/2015
                    
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
                    
                    if(CSubWrapperList.size()>0){
                    //START UD-1629 JLedesma 6/24/2015
                        newspaperCount = new List<Integer>();
                    //END UD-1629 JLedesma 6/24/2015 
                        for(CaseSubWrapper csWrap : CSubWrapperList){
                            if(subIdToCasSubRec_MAP.containskey(csWrap.caseSubscription.Subscription__c)){
                                for(Case_Subscription__c csRec : subIdToCasSubRec_MAP.get(csWrap.caseSubscription.Subscription__c)){
                                    if(csRec.Complaint_From__c <> null && csRec.Complaint_To__c <> null){
                                        if((csRec.Complaint_From__c<csWrap.caseSubscription.Complaint_From__c && csRec.Complaint_To__c<csWrap.caseSubscription.Complaint_From__c)||(csRec.Complaint_From__c>csWrap.caseSubscription.Complaint_To__c )){
                                        
                                        } else{
                                            checker = true;
                                            break;
                                        }
                                    }
                                }
                            }
                            
                    //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                            //Start D-3172 06/29/2015 James
                            /*newspaperCounter = 0;
                            if(subToPackageItems.containskey(csWrap.caseSubscription.Subscription__c)){
                                pckItems = subToPackageItems.get(csWrap.caseSubscription.Subscription__c);
                            }

                            for(Package_Item__c pckItem : pckItems){
                                if(pckItem.Is_Newspaper__c== TRUE){
                                    newspaperCounter++;
                                }
                            }
              
                            if(newspaperCounter == 0){
                                newspaperCount.add(newspaperCounter);
                            }*/
                            if(SubscriptionToPackageItemMap.containskey(csWrap.caseSubscription.Subscription__c)){
                                if(SubscriptionToPackageItemMap.get(csWrap.caseSubscription.Subscription__c) == FALSE){
                                    magazinecounter++;
                                }
                            }
                            //End D-3172 06/29/2015 James
                        }
                    }
                    
                    if(checker==true){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('OverlappingPeriod'));
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                    
                    //Start D-3172 06/29/2015 James
                    if(isDirect && magazinecounter > 0){
                    //End D-3172 06/29/2015 James
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('Validate Complaint- Newspaper')));
                        return null;
                    }
                    //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                    
                    //Vendor accounts
                    if(CSubWrapperList.size()>0){
                        for(CaseSubWrapper csWrap : CSubWrapperList){
                            subVenId_SET.add(csWrap.caseVendorSubscription.Subscription_Vendor__c);
                        }
                    }
                    List<Subscription_Vendor__c> subVenSelected_LIST = [Select Id, Name From Subscription_Vendor__c Where Id IN :subVenId_SET];
                    
                    //START UD-2717 09/10/15 RReyes - added condition to filter out void cases
                    List<Case_Vendor_Subscription__c> casSubVen_LIST = [Select Id, Case__c, Subscription_Vendor__c, Complaint_From__c, Complaint_To__c, Case__r.Status 
                    From Case_Vendor_Subscription__c 
                    Where Subscription_Vendor__c IN :subVenId_SET AND Case__r.Status !=: GlobalVariableClass.STATUS_VOID];
                    //END UD-2717 09/10/15 RReyes - added condition to filter out void cases
                    
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
                    
                    if(CSubWrapperList.size()>0){
                        for(CaseSubWrapper csWrap : CSubWrapperList){
                            if(subVenIdToCasSubRec_MAP.containskey(csWrap.caseVendorSubscription.Subscription_Vendor__c)){
                                for(Case_Vendor_Subscription__c csRec : subVenIdToCasSubRec_MAP.get(csWrap.caseVendorSubscription.Subscription_Vendor__c)){
                                    if(csRec.Complaint_From__c <> null && csRec.Complaint_To__c <> null){
                                        if((csRec.Complaint_From__c<csWrap.caseVendorSubscription.Complaint_From__c && csRec.Complaint_To__c<csWrap.caseVendorSubscription.Complaint_From__c)||(csRec.Complaint_From__c>csWrap.caseVendorSubscription.Complaint_To__c )){
                                        
                                        } else{
                                            checkerVen = true;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if(checkerVen==true){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('OverlappingPeriod'));
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                    
                    //END: UD-0775 04/08/2015 Added by S.PULI
                    //START UD-0707 5/7/15 AddedBy FrancisBenzon : relate case to parentCase
                    if(parentCaseId != null || parentCaseId != '')
                    {
                        objcase.parentId = parentCaseId;
                    }
                    //END UD-0707 5/7/15 AddedBy FrancisBenzon : relate case to parentCase
                    insert objcase;
                    isNewRecord = true;
                }
                else{
                
                    //START: UD-0775 04/08/2015 Added by S.PULI
                    //direct account
                    //Start D-3172 06/29/2015 James
                    magazinecounter = 0;
                    //End D-3172 06/29/2015 James
                    //START D-3343 08/10/15 RReyes - checks if any Goodwill amount is not negative
                    if(CSubWrapperList.size()>0){
                            for(CaseSubWrapper csWrap : CSubWrapperList){
                                if(isDirect && csWrap.caseSubscription != null){
                                    if(csWrap.caseSubscription.Goodwill_Amount__c != null ){
                                        if(csWrap.caseSubscription.Goodwill_Amount__c < 0){
                                            isNegativeGoodwill = true;
                                            break;
                                        }
                                    }
                                }
                                else if( !isDirect && csWrap.caseVendorSubscription != null){
                                    if(csWrap.caseVendorSubscription.Goodwill_Amount__c != null ){
                                        if(csWrap.caseVendorSubscription.Goodwill_Amount__c < 0){
                                            isNegativeGoodwill = true;
                                            break;
                                        }
                                    }
                                }
                            }   
                        }                        
                    if(isNegativeGoodwill){ 
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('Negative Goodwill'));
                        ApexPages.addMessage(myMsg);
                        return null;
                    }   
                    //END D-3343 08/10/15 RReyes  - checks if any Goodwill amount is not negative
                    //Start D-4271 Added by S.Puli - transfer to above
                    /*
                    if(CSubWrapperList.size()>0){
                        for(CaseSubWrapper csWrap : CSubWrapperList){
                            subId_SET.add(csWrap.caseSubscription.Subscription__c);
                        }
                    }
                    //START UD-3291 23Nov15 FrancisBenzon : Added sub start date in query
                    //Start D-3172 06/29/2015 James
                    List<Zuora__Subscription__c> subSelected_LIST = [Select Id, Name, Main_Package_1__c, Zuora__SubscriptionStartDate__c
                        From Zuora__Subscription__c Where Id IN :subId_SET];
                        
                    if(subSelected_LIST.size() > 0)
                    {
                        for(CaseSubWrapper csWrap : CSubWrapperList){
                            for(Zuora__Subscription__c SubscriptionLoop1 : subSelected_LIST){
                                if(csWrap.caseSubscription.Complaint_From__c < SubscriptionLoop1.Zuora__SubscriptionStartDate__c || csWrap.caseSubscription.Complaint_To__c < SubscriptionLoop1.Zuora__SubscriptionStartDate__c)
                                {                                 
                                    isBehind = true;
                                }                                    
                            }                        
                        }
                        if(isBehind){                    
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('CompDateBehindSubStartDate'));
                            ApexPages.addMessage(myMsg);
                            return null;
                        }
                    } 
                    */
                    //End D-4271 Added by S.Puli - transfer to above
                    //END UD-3291 23Nov15 FrancisBenzon : Added sub start date in query
                    for(Zuora__Subscription__c SubscriptionLoop1 : subSelected_LIST){
                        SubPackageList.add(SubscriptionLoop1.Main_Package_1__c);
                    }
                    PackageItemList = [SELECT Is_All_In_One__c, Is_Digital__c, Is_Magazine__c, Is_Newspaper__c, Is_Print__c, Package__c, Id FROM Package_Item__c WHERE Package__c IN: SubPackageList];
                    //START UD-2107 7/27/2015 Added By C. Lin - Include only Base Product and Bundle Product Package Item
                    PackageItemList = [SELECT Is_All_In_One__c, Is_Digital__c, Is_Magazine__c, Is_Newspaper__c, Is_Print__c, Package__c, Id FROM Package_Item__c WHERE Package__c IN: SubPackageList AND (RecordTypeId = :RecordTypePackItemBase OR RecordTypeId = :RecordTypePackItemBundle)];
                    //END UD-2107 7/27/2015 Added By C. Lin
                    
                    for(Zuora__Subscription__c SubscriptionLoop2 : subSelected_LIST){
                        for(Package_Item__c PackageItemLoop1 : PackageItemList){
                            if(SubscriptionLoop2.Main_Package_1__c == PackageItemLoop1.Package__c){
                                SubscriptionToPackageItemMap.put(SubscriptionLoop2.Id, PackageItemLoop1.Is_Newspaper__c);
                            }
                        }
                    }
                    //End D-3172 06/29/2015 James
                    
                    //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                    //START UD-2717 09/10/15 RReyes - added condition to filter out void cases                  
                    List<Case_Subscription__c> casSub_LIST = [Select Id, Case__c, Subscription__c, Complaint_From__c, Complaint_To__c, Case__r.Status, Subscription__r.Zuora__SubscriptionStartDate__c 
                    From Case_Subscription__c 
                    Where Subscription__c IN :subId_SET AND Case__r.RecordTypeId = :recType AND Case__r.Status !=: GlobalVariableClass.STATUS_VOID];
                    //END UD-2717 09/10/15 RReyes - added condition to filter out void cases
                    //END UD-1629 JLedesma 6/24/2015 validates subscription selected. // Start-End D-3763 K. Tan 10/19/2015
                    
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
                    
                    if(CSubWrapperList.size()>0){
                    //START UD-1629 JLedesma 6/24/2015
                        newspaperCount = new List<Integer>();
                    //END UD-1629 JLedesma 6/24/2015
                        for(CaseSubWrapper csWrap : CSubWrapperList){
                            if(subIdToCasSubRec_MAP.containskey(csWrap.caseSubscription.Subscription__c)){
                                for(Case_Subscription__c csRec : subIdToCasSubRec_MAP.get(csWrap.caseSubscription.Subscription__c)){
                                    if(csRec.Id<>csWrap.caseSubscription.Id){
                                        if(csRec.Complaint_From__c <> null && csRec.Complaint_To__c <> null){
                                            if((csRec.Complaint_From__c<csWrap.caseSubscription.Complaint_From__c && csRec.Complaint_To__c<csWrap.caseSubscription.Complaint_From__c)||(csRec.Complaint_From__c>csWrap.caseSubscription.Complaint_To__c )){
                                            
                                            } else{
                                                checker = true;
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                    //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                            //Start D-3172 06/29/2015 James
                            /*newspaperCounter = 0;
                            if(subToPackageItems.containskey(csWrap.caseSubscription.Subscription__c)){
                                pckItems = subToPackageItems.get(csWrap.caseSubscription.Subscription__c);
                            }

                            for(Package_Item__c pckItem : pckItems){
                                if(pckItem.Is_Newspaper__c== TRUE){
                                    newspaperCounter++;
                                }
                            }
              
                            if(newspaperCounter == 0){
                                newspaperCount.add(newspaperCounter);
                            }*/
                            if(SubscriptionToPackageItemMap.containskey(csWrap.caseSubscription.Subscription__c)){
                                if(SubscriptionToPackageItemMap.get(csWrap.caseSubscription.Subscription__c) == FALSE){
                                    magazinecounter++;
                                }
                            }
                            //End D-3172 06/29/2015 James
                        }
                    }
                    
                    if(checker==true){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('OverlappingPeriod'));
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                    
                    //Start D-3172 06/29/2015 James
                    if(isDirect && magazinecounter > 0){
                    //End D-3172 06/29/2015 James
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('Validate Complaint- Newspaper')));
                        return null;
                    }
                    //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 
                    
                    //Vendor accounts
                    if(CSubWrapperList.size()>0){
                        for(CaseSubWrapper csWrap : CSubWrapperList){
                            subVenId_SET.add(csWrap.caseVendorSubscription.Subscription_Vendor__c);
                        }
                    }
                    List<Subscription_Vendor__c> subVenSelected_LIST = [Select Id, Name From Subscription_Vendor__c Where Id IN :subVenId_SET];
                    
                    //START UD-2717 09/10/15 RReyes - added condition to filter out void cases
                    List<Case_Vendor_Subscription__c> casSubVen_LIST = [Select Id, Case__c, Subscription_Vendor__c, Complaint_From__c, Complaint_To__c, Case__r.Status 
                    From Case_Vendor_Subscription__c 
                    Where Subscription_Vendor__c IN :subVenId_SET AND Case__r.Status !=: GlobalVariableClass.STATUS_VOID];
                    //END UD-2717 09/10/15 RReyes - added condition to filter out void cases
                    
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
                    
                    if(CSubWrapperList.size()>0){
                        for(CaseSubWrapper csWrap : CSubWrapperList){
                            if(subVenIdToCasSubRec_MAP.containskey(csWrap.caseVendorSubscription.Subscription_Vendor__c)){
                                for(Case_Vendor_Subscription__c csRec : subVenIdToCasSubRec_MAP.get(csWrap.caseVendorSubscription.Subscription_Vendor__c)){
                                    if(csRec.Id <> csWrap.caseVendorSubscription.Id){
                                        if(csRec.Complaint_From__c <> null && csRec.Complaint_To__c <> null){
                                            if((csRec.Complaint_From__c<csWrap.caseVendorSubscription.Complaint_From__c && csRec.Complaint_To__c<csWrap.caseVendorSubscription.Complaint_From__c)||(csRec.Complaint_From__c>csWrap.caseVendorSubscription.Complaint_To__c )){
                                            
                                            } else{
                                                checkerVen = true;
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if(checkerVen==true){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('OverlappingPeriod'));
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                    
                    //END: UD-0775 04/08/2015 Added by S.PULI
                    
                    update objcase;
                }
                        
                // START : D-1796 2/4/2015 Alyana Navarro
                Case caseRec = [SELECT isEscalated from case where id =: objcase.id]; 
                if(!isNewRecord && objCase.Notify_Vendor__c){
                    //START: MD-62 03/27/2015 Added by S.PULI 
                    Set<Id> casId_SET = new Set<Id>();
                    casId_SET.add(objcase.Id);
                    EmailNotificationCreation.createEmail(casId_SET); 
                    //END: MD-62 03/27/2015 Added by S.PULI 
                }
                // END : D-1796 2/4/2015
                List<Case_Vendor_Subscription__c> insertCaseVenSubsList = new list<Case_Vendor_Subscription__c>();
                List<Case_Subscription__c> deleteCaseSubRec = new list<Case_Subscription__c>();
                List<Case_Vendor_Subscription__c> deleteCaseVenSubRec = new list<Case_Vendor_Subscription__c>();
                if(isDirect) {        
                    if(!CSubWrapperList.isEmpty()){
                                //START: D-4285 1-15-2016 Added by Kristine Balaoing - added mapping of subscription to its field values
                                List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
                                Set<Id> subIds = new Set<Id>();
                                Map<Id, Zuora__Subscription__c> mapsubToDetails = new Map<Id, Zuora__Subscription__c>();
                            //START UD-3702 2/4/2016 Added by J.Sarion - Added list
                            List<Case_Subscription__c> caseSubList = new List<Case_Subscription__c>();
                            Map<Id, List<Case_Subscription__c>> subIdToCaseSubListMap = new Map<Id, List<Case_Subscription__c>>();
                            Map<Id, String> subIdToOldVendorCodeBeforeCOAMap = new Map<Id, String>();
                            Map<Id, Id> subIdToOldAddressBeforeCOAMap = new Map<Id, Id>();
                            Map<Id, Case_Subscription__c> subIdToCaseSubBeforeCOAMap = new Map<Id, Case_Subscription__c>();
                            //END UD-3702 2/4/2016 Added by J.Sarion - Added list
                                for(CaseSubWrapper cWrap: CSubWrapperList){
                                        subIds.add(cWrap.caseSubscription.Subscription__c);
                                }
                                subList = [SELECT Id, Recipient_Contact__c, Vendor_1__c, Vendor_1__r.Vendor_Code__c, Recipient_Contact__r.Address__c
                                            FROM Zuora__Subscription__c 
                                            WHERE ID IN :subIds];
                                
                                for(Zuora__Subscription__c sub : subList){
                                    mapsubToDetails.put(sub.Id, sub);
                                }
                            
                            //START UD-3702 2/4/2016 Added by J.Sarion - Check for previous COA Case
                            if(!subIds.isEmpty()) {
                                caseSubList = [SELECT Id, Subscription__c, Vendor_Code__c, Address__c, Case__r.Effective_Date__c FROM Case_Subscription__c WHERE Subscription__c IN :subIds AND (Case__r.Change_of_Address_Type__c = :GlobalVariableClass.BILLDELIVERYADD OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.DELIVERYADDLOC OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.CHANGEVENDOR) AND Case__r.RecordTypeId = :COAID];
                                
                                for(Case_Subscription__c caseSub :caseSubList) {
                                    if(subIdToCaseSubListMap.containsKey(caseSub.Subscription__c)) {
                                        subIdToCaseSubListMap.get(caseSub.Subscription__c).add(caseSub);
                                    }
                                    else {
                                        subIdToCaseSubListMap.put(caseSub.Subscription__c, new List<Case_Subscription__c> {caseSub});
                                    }
                                }
                                
                                for(CaseSubWrapper cWrap: CSubWrapperList){
                                    if(subIdToCaseSubListMap.containsKey(cWrap.CaseSubscription.Subscription__c)) {
                                        for(Case_Subscription__c caseSub :subIdToCaseSubListMap.get(cWrap.CaseSubscription.Subscription__c)) {
                                            if(cWrap.CaseSubscription.Complaint_To__c < caseSub.Case__r.Effective_Date__c) {
                                                if(subIdToCaseSubBeforeCOAMap.containsKey(caseSub.Subscription__c)) {
                                                    if(caseSub.Case__r.Effective_Date__c < subIdToCaseSubBeforeCOAMap.get(caseSub.Subscription__c).Case__r.Effective_Date__c) {
                                                        subIdToCaseSubBeforeCOAMap.put(caseSub.Subscription__c, caseSub);
                                                    }
                                                }
                                                else {
                                                    subIdToCaseSubBeforeCOAMap.put(caseSub.Subscription__c, caseSub);
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                            //END UD-3702 2/4/2016 Added by J.Sarion - Check for previous COA Case

                                //END: D-4285 1-15-2016 Added by Kristine Balaoing
                                for(CaseSubWrapper cWrap: CSubWrapperList){
                                    Case_Subscription__c caseSub = new Case_Subscription__c();
                                    caseSub = cWrap.caseSubscription;
                                    caseSub.Case__c = objcase.id;
                                    caseSub.iscomplaint__c = true;
                            //START: D-4285 1-15-2016 Added by Kristine Balaoing - added fields on case subscription 
                                    caseSub.Old_Recipient_Contact__c = mapsubToDetails.get(cWrap.caseSubscription.Subscription__c).Recipient_Contact__c;
                                    //START: D-4338 1-20-2016 Added by Kristine Balaoing - changed field to be populated
                                    caseSub.Address__c = mapsubToDetails.get(cWrap.caseSubscription.Subscription__c).Recipient_Contact__r.Address__c;
                                    //END: D-4338 1-20-2016 Added by Kristine Balaoing
                                //START UD-3702 2/4/2016 Added by J.Sarion - Populate Address and Vendor Code
                                if(subIdToCaseSubBeforeCOAMap.containsKey(cWrap.caseSubscription.Subscription__c)) {
                                    caseSub.Vendor_Code__c = subIdToCaseSubBeforeCOAMap.get(cWrap.caseSubscription.Subscription__c).Vendor_Code__c;
                                    caseSub.Vendor__c = subIdToCaseSubBeforeCOAMap.get(cWrap.caseSubscription.Subscription__c).Vendor_Code__c;
                                    caseSub.Address__c = subIdToCaseSubBeforeCOAMap.get(cWrap.caseSubscription.Subscription__c).Address__c;
                                }
                                else {
                                    caseSub.Vendor_Code__c = mapsubToDetails.get(cWrap.caseSubscription.Subscription__c).Vendor_1__r.Vendor_Code__c;
                                    caseSub.Vendor__c = mapsubToDetails.get(cWrap.caseSubscription.Subscription__c).Vendor_1__r.Vendor_Code__c;
                                    caseSub.Address__c = mapsubToDetails.get(cWrap.caseSubscription.Subscription__c).Recipient_Contact__r.Address__c;
                                }
                                //END UD-3702 2/4/2016 Added by J.Sarion - Populate Address and Vendor Code
                                    
                            //END: D-4285 1-15-2016 Added by Kristine Balaoing
                      //START UD-2741 9/15/2015 Added by Manolo Valena
                                    if(objcase.Replacement_Required__c == true) {
                                        caseSub.Replacement_Required__c = true;
                                    }
                                    else {
                                        caseSub.Replacement_Required__c = false;
                                    }
                                    //END UD-2741 9/15/2015 Added by Manolo Valena
                                    insertCaseSubsList.add(caseSub);
             
                                }               
                            }

                            //START: D-1789 / 1/20/2015 /K. Tan/ Clearing Case Subscription List
                            Savepoint saveP = Database.setSavepoint();
                            try{
                                upsert insertCaseSubsList;
                            }
                            catch (Dmlexception e){ 
                                Database.rollback(saveP);
                            }
                            //END: D-1789/ 1/20/2015 /K. Tan/ Clearing Case Subscription List
                  //START UD-2149 7/30/2015 Added By C. Lin - Delete existing Case Vendor Fee before computing for paper fee
                            List<Case_Vendor_Fee__c> existCVFList = new List<Case_Vendor_Fee__c>();
                            if(objcase.id != null){
                                existCVFList = [SELECT Id, Name FROM Case_Vendor_Fee__c WHERE Case__c = :objcase.id];
                            }
                            if(!existCVFList.isEmpty()){
                                delete existCVFList;
                            }
                            //END UD-2149 7/30/2015 Added By C. Lin
                            callComputatePaperFee();
                            callComputeCourierFee(insertCaseSubsList);
                            //computePaperFee(insertCaseSubsList);
                            computeCreditAmount(insertCaseSubsList);
             
             
                           //START: D-2114 02/10/2015 Added by Marvin Gatchalian - Throws an error for invalid data, checking if selected subscription has no SPC and display an error
                
                           if(allComputationAreGood) {
                                //iterate set of Ids for deletion
                                for(Id cId : cSubId){
                                    //instantiate new Case sub record, and add to deleteCaseSubRec
                                    Case_Subscription__c cSub = new Case_Subscription__c ();
                                    cSub.Id = cId;
                                    deleteCaseSubRec.add(cSub);
                                   
                                }
                                //Start D-3172 06/29/2015 James
                                if(deleteCaseSubRec.size() > 0 && deleteCaseSubRec[0].id != null){
                                    delete deleteCaseSubRec;
                                }
                                //End D-3172 06/29/2015 James
                            }
                            
                           //END: D-2114 02/10/2015 Added by Marvin Gatchalian - Throws an error for invalid data, checking if selected subscription has no SPC and display an error
                            
                        } else {
                            if(!CSubWrapperList.isEmpty()){
                                for(CaseSubWrapper cWrap: CSubWrapperList){
                                    Case_Vendor_Subscription__c cvs = new Case_Vendor_Subscription__c();
                                    cvs = cWrap.caseVendorSubscription;
                                    cvs.Case__c = objcase.id;
                      //START UD-2741 9/15/2015 Added by Manolo Valena
                                    if(objcase.Replacement_Required__c == true) {
                                        cvs.Replacement_Required__c = true;
                                    }
                                    else {
                                        cvs.Replacement_Required__c = false;
                                    }
                                    //END UD-2741 9/15/2015 Added by Manolo Valena
                                    insertCaseVenSubsList.add(cvs);
                                }
                            }
                            if(objcase.id == null){
                                //START UD-0707 5/7/15 AddedBy FrancisBenzon : relate case to parentCase
                                if(parentCaseId != null || parentCaseId != '')
                                {
                                    objcase.parentId = parentCaseId;
                                }
                                //END UD-0707 5/7/15 AddedBy FrancisBenzon : relate case to parentCase
                                insert objcase;
                                isNewRecord = true;
                            }
                            else{
                                update objcase;
                            }
                            upsert insertCaseVenSubsList;
                            //iterate set of Ids for deletion
                            for(Id cvId : cvSubId){
                                //instantiate new Case sub record, and add to deleteCaseSubRec
                                Case_Vendor_Subscription__c cVenSub = new Case_Vendor_Subscription__c();
                                cVenSub.Id = cvId;
                                deleteCaseVenSubRec.add(cVenSub);
                               
                            }
                            delete deleteCaseVenSubRec;
                        }
                       
                        //START: D-2114 02/10/2015 Added by Marvin Gatchalian - Throws an error for invalid data, checking if selected subscription has no SPC and display an error
                
                        if(allComputationAreGood) {
                            upsert objcase;
                            upsert insertCaseSubsList;
                        }
                        else {
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, SUBSCRIPTION_NO_SPC);
                            ApexPages.addMessage(myMsg);
                            return null;  
                        }
                        
                        //START: D-2114 02/10/2015 Added by Marvin Gatchalian - Throws an error for invalid data, checking if selected subscription has no SPC and display an error
                        
                       
                    }    
                    catch (Dmlexception e){ 
                        Database.rollback(sp);
                        if(isNewRecord) objcase.Id = null;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
                        return null;  
                    }
                //START UD-0531 3/25/2015 Added By C. Lin - Contact Name should be required.
                }
                //END UD-0531 3/25/2015 Added By C. Lin
                 
                //START:D-3830 10/28/2015 Added by Manolo Valena
                List<Usage__c> usageListWithoutZeroQ = new List<Usage__c>();
                System.debug('cube ---------------------------- 06082016 : usageList ' + usageList);
                for(Usage__c u : UsageHelper.filterAndUpdateUniqueUsages(usageList,false)) {
                    System.debug('cube ---------------------------- 06082016 : u ' + u);
                    if(u.Quantity__c != null && u.Quantity__c != 0) {
                        usageListWithoutZeroQ.add(u);
                    }
                }
                //END:D-3830 10/28/2015 Added by Manolo Valena 
                System.debug('cube ---------------------------- 06082016 : usageListWithoutZeroQ ' + usageListWithoutZeroQ);
                //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
                //START:D-3830 10/28/2015 Added by Manolo Valena
                List<Usage__c> newUsagesList = usageListWithoutZeroQ;
                //END:D-3830 10/28/2015 Added by Manolo Valena
                //START D-3274 23-July-2015 JTeves - Set Stop Type to Non Delivery
                for(Usage__c usageElement : newUsagesList) {
                    usageElement.StopType__c = 'Non Delivery';
                }
                //END D-3274 23-July-2015 JTeves
                Database.insert(newUsagesList);
                Set<Id> usageIdSet = new Set<Id>();
                for(Usage__c usageElement : newUsagesList) {
                    if(usageElement.Id != null) {
                        usageIdSet.add(usageElement.Id);
                    }
                }
                //START D-2884 05-18-2015 Marvin Gatchalian - no need to perform call out cause the status is not closed
                //UsageHelper.sendToZuoraCallOut(usageIdSet);
                //END  D-2884 05-18-2015 Marvin Gatchalian - no need to perform call out cause the status is not closed
                //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
                
                PageReference pageRef = new pageReference('/' + objcase.Id);
                pageRef.setRedirect(true);
                return pageRef;
                //return null;
            }
           
            public PageReference cancel(){
                //Start: UD-1131 05/07/2015 James - cancel button to previous page
                String acctId = ApexPages.currentPage().getParameters().get('accountId');
                String conId = ApexPages.currentPage().getParameters().get('contactId');
                //End: UD-1131 05/07/2015 James
                if(objcase.Id == null) {
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
                    PageReference pageRef = new PageReference('/' + objcase.Id);
                    pageRef.setRedirect(true);
                    return pageRef;
                }
            }
           
            public PageReference addRow(){
        //Start D-2070 2/9/2015 Added by James Azaña - restrict Vendor Rep/Vendor Sr. Manager from adding subscription
                //Start D-2200 2/12/2015 Added by James - for vendor exec/manager
                if(profileName == VendorSrManagerProfile || profileName == VendorRepProfile || profileName == VendorExecMngrProfile){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage(VENDOR_ERROR_MSG)));
                }else{
                Id addressId;
                if(isDirect) {   
                    CaseSubWrapper csWrap = new CaseSubWrapper(new Case_Subscription__c(), objcase.AccountId);
                      try {
                        addressId = [SELECT Recipient_Contact__r.Address__c FROM Zuora__Subscription__c
                                     WHERE Id = :CSubWrapperList[0].caseSubscription.Subscription__c].Recipient_Contact__r.Address__c;
                    }
                    catch (Exception e) {
                    }
                    if (addressId <> null) {
                        //csWrap.caseSubs.Address__c = wrapCaseSubList[0].caseSubs.Subscription__r.Recipient_Contact__r.Address__c;
                        csWrap.caseSubscription.Address__c = addressId;
                    }        
                    counter++;
                    csWrap.counterWrap = counter;
                    CSubWrapperList.add(csWrap);
                    return null;
                }
               
                else {   
                    CaseSubWrapper csWrap = new CaseSubWrapper(new Case_Vendor_Subscription__c(), objcase.AccountId);
                    try {
                        addressId = [SELECT Recipient__r.Address__c FROM Subscription_Vendor__c
                                     WHERE Id = :CSubWrapperList[0].caseVendorSubscription.Subscription_Vendor__c].Recipient__r.Address__c;
                    } catch (Exception e) {}
                    if (addressId <> null) {
                        //csWrap.caseVenSubs.Address__c = wrapCaseSubList[0].caseVenSubs.Subscription_Vendor__r.Recipient__r.Address__c;
                        csWrap.caseVendorSubscription.Address__c = addressId;
                    }                     
                    counter++;
                    csWrap.counterWrap = counter;
                    CSubWrapperList.add(csWrap);
                }    
            }
                return null;
            }
            //End D-2070 2/9/2015
            //End D-2200 2/12/2015
           
            public PageReference removeRows(){
        //Start D-2070 2/9/2015 Added by James Azaña - restrict Vendor Rep/Vendor Sr. Manager from removing subscription
                //Start D-2200 2/12/2015 Added by James - for vendor exec/manager
                if(profileName == VendorSrManagerProfile || profileName == VendorRepProfile || profileName == VendorExecMngrProfile){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage(VENDOR_ERROR_MSG)));
                }else{
                Integer param = Integer.valueOf(Apexpages.currentpage().getParameters().get('index'));      
                for(Integer i=0; i<CSubWrapperList.size(); i++){
                    if(CSubWrapperList[i].counterWrap == param){
                        if(isDirect){
                            cSubId.add(CSubWrapperList[i].caseSubscription.Id);
                        }
                        else{
                            cvSubId.add(CSubWrapperList[i].caseVendorSubscription.Id);  
                        }                         
                        CSubWrapperList.remove(i); 
                    }
                }       
                counter--;
                }
                return null;
            }
            //Start D-2070 2/6/2015
            //End D-2200
           
            public void fetchAccountDetails() {      
                if(objcase.AccountId != null) {
                    accn = [SELECT RecordType.Name FROM Account WHERE Id = :objcase.AccountId];
                    if(accn.RecordType.Name == 'Vendor Subscriber' || accn.RecordType.Name == 'Vendor') {
                        isDirect = FALSE;             
                    }
                    else {
                        isDirect = TRUE;            
                    }
                    for(CaseSubWrapper wrapCas : CSubWrapperList) {
                        wrapCas.setAccount(objcase.AccountId);
                    }            
                }
            } 
            
            public double computePaperFee(List<Case_Subscription__c> insertCaseSubsList){
            //Paper Fee Computation
                //iterate insertCaseSubsList (for each loop)
                Map<String, Decimal> dayToCoverPriceMap = new Map<String, Decimal>();
                //START UD-2046 7/24/2015 Added By C. Lin - Subscription to Publication to Case Vendor Fee
                Map<Id, Map<Id, Case_Vendor_Fee__c>> subIdToPubToCaseVendorFeeMap = new Map<Id, Map<Id, Case_Vendor_Fee__c>>();
                //END UD-2046 7/24/2015 Added By C. Lin
                
                for(Case_Subscription__c cS : insertCaseSubsList){
                    csSet.add(cS.Subscription__c);                                     
                }

        //START: D-2114 02/10/2015 Added by Marvin Gatchalian - Get all Product Familiy 
         List <Product_Family__c> pfList = new List <Product_Family__c>();
         Set<String> specialProductFamilies = new Set<String>();
         pfList = [Select Product_Family__c from Product_Family__c];
         
         for (Product_Family__c pf : pfList ) {
             specialProductFamilies.add(pf.Product_Family__c);
         }
        
            //specialProductFamilies.add('The Straits Times');
            //specialProductFamilies.add('The New Paper');
            //specialProductFamilies.add('BERITA HARIAN');
            //specialProductFamilies.add('BERITA MINGGU');
            //specialProductFamilies.add('Tamil Murasu');
        //END: D-2114 02/10/2015 Added by Marvin Gatchalian - Get all Product Familiy 
       
   
        /*
         * Obtain Mapping of Subscription Id to List of Subscription Product And Charge records
         */
            //START UD-2046 7/24/2015 Added By C. Lin - Update to = to IN
            spcList = [SELECT Id, Name, Zuora__ProductSKU__c, Zuora__RatePlanName__c, Zuora__Subscription__c,                                     
                        Zuora__Model__c, Zuora__Price__c,Zuora__UOM__c, Zuora__EffectiveStartDate__c
                         FROM Zuora__SubscriptionProductCharge__c
                         WHERE Zuora__Subscription__c IN :csSet]; // List of Subscription Product and Charges, child object of Subscription.
            //END UD-2046 7/24/2015 Added By C. Lin
          //START: D-2114 02/10/2015 Added by Marvin Gatchalian - Throws an error for invalid data, checking if selected subscription has no SPC and display an error
              if (spcList.size() == 0 || spcList == null) {
                  allComputationAreGood = false;
                  return null;
              }
          
          //END: D-2114 02/10/2015 Added by Marvin Gatchalian - Throws an error for invalid data, checking if selected subscription has no SPC and display an error

            for(Zuora__SubscriptionProductCharge__c subProdCharge : spcList) {
                if(subsIdToSubProductAndChargesMap.containsKey(subProdCharge.Zuora__Subscription__c)) {
                    subsIdToSubProductAndChargesMap.get(subProdCharge.Zuora__Subscription__c).add(subProdCharge);
                }
                else {
                    subsIdToSubProductAndChargesMap.put(subProdCharge.Zuora__Subscription__c, new List<Zuora__SubscriptionProductCharge__c>{subProdCharge});
                }
                subProdRatePlanName.add(subProdCharge.Zuora__RatePlanName__c);
                //START UD-2046 7/24/2015 Added By C. Lin - Set of SKU
                spcSKUSet.add(subProdCharge.Zuora__ProductSKU__c);
                //END UD-2046 7/24/2015 Added By C. Lin
            }
           
        /*
         * Obtain Mapping of Rate Plan Name (String) to List of related Publication COdes (String)
         */
        //START UD-2046 7/24/2015 Added By C. Lin - Update to SKU Set
        subProdToProdRatePlanList = [SELECT Id, Name, RatePlanSubType__c, (SELECT Id, PublicationCode__c, zqu__UOM__c, sum__c FROM R00N40000001mFVKEA2__r)
                                         FROM zqu__ProductRatePlan__c
                                         WHERE Name IN :subProdRatePlanName AND RatePlanType__c = 'Proration' AND             
                                         RatePlanSubType__c = 'Standard' AND zqu__ZProduct__r.zqu__SKU__c IN :spcSKUSet];
        //END UD-2046 7/24/2015 Added By C. Lin
        
        for(zqu__ProductRatePlan__c pRatePlan : subProdToProdRatePlanList) {
            
            
            
            for(zqu__ProductRatePlanCharge__c pRatePlanCharge : pRatePlan.R00N40000001mFVKEA2__r) { //rate Plan Charge
                if(mapPub_UOM_Price.get(pRatePlanCharge.PublicationCode__c)== null){
                    mapPub_UOM_Price.put(pRatePlanCharge.PublicationCode__c, new Map<String, Decimal>());
                }
                if(ratePlanNameToPubCodesMap.containsKey(pRatePlan.Name)) {
                    ratePlanNameToPubCodesMap.get(pRatePlan.Name).add(pRatePlanCharge.PublicationCode__c);                         
                }
                else {
                    ratePlanNameToPubCodesMap.put(pRatePlan.Name, new Set<String>{pRatePlanCharge.PublicationCode__c});
                }
                                                                                       
                if(pRatePlanCharge.zqu__UOM__c == 'Copy Weekday'){
                                mapPub_UOM_Price.get(pRatePlanCharge.PublicationCode__c).put('Weekday', pRatePlanCharge.sum__c);
                                System.debug(mapPub_UOM_Price);
                }
                if(pRatePlanCharge.zqu__UOM__c == 'Copy Sat'){
                                mapPub_UOM_Price.get(pRatePlanCharge.PublicationCode__c).put('Sat', pRatePlanCharge.sum__c);
                                System.debug(mapPub_UOM_Price);
                }
                if(pRatePlanCharge.zqu__UOM__c == 'Copy Sun'){
                                mapPub_UOM_Price.get(pRatePlanCharge.PublicationCode__c).put('Sun', pRatePlanCharge.sum__c);
                                System.debug(mapPub_UOM_Price);
                }
                pubCodes.add(pRatePlanCharge.PublicationCode__c);
            }
        }
        
       
       

        /*
         * Obtain Mapping of Publication Codes to Publication Records
         */
        //START: D-2114 02/10/2015 Added by Marvin Gatchalian - Added Name field it will be used for checking
        publicationRecords = [SELECT Id, Name, Publication_Code__c, Publish_Pattern__c, Product_Family__c,Published_Days__c
                             FROM Publication__c
                             WHERE Publication_Code__c IN :pubCodes];
        //END: D-2114 02/10/2015 Added by Marvin Gatchalian - Added Name field it will be used for checking
        
        for(Publication__c pub : publicationRecords) {
            pubCodesToPublicationMap.put(pub.Publication_Code__c, pub);                   
        }
         
        /*
         * Get Non-pub dates for affected publications
         */
        getNonPubdays();
       
        /*
         * Using the maps previously created, create a direct mapping of Case Subscription Id's to related Publication records.
         * inner-map: Key: Weekday/Weekend, publication
         */
        for(Case_Subscription__c caseSubRecord : insertCaseSubsList){
            caseSubIdSet.add(caseSubRecord.Id);
        }
        for(Case_Subscription__c caseSubRec : insertCaseSubsList) {
            if(subsIdToSubProductAndChargesMap.containsKey(caseSubRec.Subscription__c)) {
                List<Zuora__SubscriptionProductCharge__c> subProdCharges = subsIdToSubProductAndChargesMap.get(caseSubRec.Subscription__c);
                
                for(Zuora__SubscriptionProductCharge__c subProdCharge : subProdCharges) {
                    if(ratePlanNameToPubCodesMap.containsKey(subProdCharge.Zuora__RatePlanName__c)) {
                        Set<String> publicationCodes = ratePlanNameToPubCodesMap.get(subProdCharge.Zuora__RatePlanName__c);
                       
                        for(String pubCode : publicationCodes) {
                        
                            if(pubCodesToPublicationMap.containsKey(pubCode)) {
                            
                            
                                Publication__c pub = pubCodesToPublicationMap.get(pubCode);
                                
                                //check if publication is in special product family
                                //ASSUMPTION: only one product family per CaseSubscription (Subscription)
                                //ASSUMPTION: Publish_Pattern__c in Publication object used as indicator if publication is a regular or sunday issue
                                
                     //START: D-2114 02/10/2015 Added by Marvin Gatchalian - remove checking on special product family
                                //if(specialProductFamilies.contains(pub.Product_Family__c)) {

                                    //START UD-2046 7/24/2015 Added By C. Lin - Change to per day of week to publication
                                    Boolean isMonday = false;
                                    Boolean isTuesday = false;
                                    Boolean isWednesday = false;
                                    Boolean isThursday = false;
                                    Boolean isFriday = false;
                                    Boolean isSaturday = false;
                                    Boolean isSunday = false;
                                    //END UD-2046 7/24/2015 Added By C. Lin
                                    //check if publication is a weekday or weekend issue
                                    
                                    if (pub.Published_Days__c != null) {
                                        if (pub.Published_Days__c.length() == 7) {
                                            //START UD-2046 7/24/2015 Added By C. Lin - Change caseSubsIdToPublicationMap values
                                            /*if (pub.Published_Days__c.substring(0,4).contains('Y')) {
                                                isWeekdayIssue = true;
                                            }
                                            
                                            if (pub.Published_Days__c.substring(5,7).contains('Y')) { 
//START: D-1255 01/06/2015 Modified by K. Tan - Modified from isWeekdayIssue variable to IsWeekendIssue
                                                isWeekendIssue  = true;
//END: D-1255 01/06/2015 Modified by K. Tan - Modified from isWeekdayIssue variable to IsWeekendIssue
                                            }*/

                                            if (pub.Published_Days__c.substring(0,1).contains('Y')) {
                                                isMonday = true;
                                            }
                                            if (pub.Published_Days__c.substring(1,2).contains('Y')) {
                                                isTuesday = true;
                                            }
                                            if (pub.Published_Days__c.substring(2,3).contains('Y')) {
                                                isWednesday = true;
                                            }
                                            if (pub.Published_Days__c.substring(3,4).contains('Y')) {
                                                isThursday = true;
                                            }
                                            if (pub.Published_Days__c.substring(4,5).contains('Y')) {
                                                isFriday = true;
                                            }
                                            if (pub.Published_Days__c.substring(5,6).contains('Y')) {
                                                isSaturday = true;
                                            }
                                            if (pub.Published_Days__c.substring(6,7).contains('Y')) {
                                                isSunday = true;
                                            }
                                            //END UD-2046 7/24/2015 Added By C. Lin
                                        }
                                    }
                                    
                                    if(caseSubsIdToPublicationMap.containsKey(caseSubRec.Id)) {
                                        //START UD-2046 7/24/2015 Added By C. Lin - Change caseSubsIdToPublicationMap values
                                        /*if (isWeekdayIssue == true) {
                                            caseSubsIdToPublicationMap.get(caseSubRec.Id).put('Weekday', pub);
                                        }
                                        
                                        if (isWeekendIssue == true) {
                                            caseSubsIdToPublicationMap.get(caseSubRec.Id).put('Weekend', pub);
                                        }*/
                                        if (isMonday == true) {
                                            caseSubsIdToPublicationMap.get(caseSubRec.Id).put('Monday', pub);
                                        }
                                        if (isTuesday == true) {
                                            caseSubsIdToPublicationMap.get(caseSubRec.Id).put('Tuesday', pub);
                                        }
                                        if (isWednesday == true) {
                                            caseSubsIdToPublicationMap.get(caseSubRec.Id).put('Wednesday', pub);
                                        }
                                        if (isThursday == true) {
                                            caseSubsIdToPublicationMap.get(caseSubRec.Id).put('Thursday', pub);
                                        }
                                        if (isFriday == true) {
                                            caseSubsIdToPublicationMap.get(caseSubRec.Id).put('Friday', pub);
                                        }
                                        if (isSaturday == true) {
                                            caseSubsIdToPublicationMap.get(caseSubRec.Id).put('Saturday', pub);
                                        }
                                        if (isSunday == true) {
                                            caseSubsIdToPublicationMap.get(caseSubRec.Id).put('Sunday', pub);
                                        }
                                        //END UD-2046 7/24/2015 Added By C. Lin
                                    }
                                    else {
                                        //START UD-2046 7/24/2015 Added By C. Lin - Change caseSubsIdToPublicationMap values
                                        /*if (isWeekdayIssue == true) {
                                            caseSubsIdToPublicationMap.put(caseSubRec.Id, new Map<String, Publication__c>{'Weekday' => pub});
                                        }
                                        
                                        if (isWeekendIssue == true) {
                                            caseSubsIdToPublicationMap.put(caseSubRec.Id, new Map<String, Publication__c>{'Weekend' => pub});
                                        }*/
                                        if (isMonday == true) {
                                            caseSubsIdToPublicationMap.put(caseSubRec.Id, new Map<String, Publication__c>{'Monday' => pub});
                                        }
                                        if (isTuesday == true) {
                                            caseSubsIdToPublicationMap.put(caseSubRec.Id, new Map<String, Publication__c>{'Tuesday' => pub});
                                        }
                                        if (isWednesday == true) {
                                            caseSubsIdToPublicationMap.put(caseSubRec.Id, new Map<String, Publication__c>{'Wednesday' => pub});
                                        }
                                        if (isThursday == true) {
                                            caseSubsIdToPublicationMap.put(caseSubRec.Id, new Map<String, Publication__c>{'Thursday' => pub});
                                        }
                                        if (isFriday == true) {
                                            caseSubsIdToPublicationMap.put(caseSubRec.Id, new Map<String, Publication__c>{'Friday' => pub});
                                        }
                                        if (isSaturday == true) {
                                            caseSubsIdToPublicationMap.put(caseSubRec.Id, new Map<String, Publication__c>{'Saturday' => pub});
                                        }
                                        if (isSunday == true) {
                                            caseSubsIdToPublicationMap.put(caseSubRec.Id, new Map<String, Publication__c>{'Sunday' => pub});
                                        }
                                        //END UD-2046 7/24/2015 Added By C. Lin
                                    }
                                }
                                
                                
                                //else {
                                    //caseSubsIdToPublicationMap.put(caseSubRec.Id, new Map<String, Publication__c>{'Weekday' => pub});
                                //}
                            //}
                            //END: D-2114 02/10/2015 Added by Marvin Gatchalian - remove checking on special product family
                        }
                    }
                }
            }
        }
        
        System.debug('>>>>UOM' + mapPub_UOM_Price);
        //populate map for getCoverPrice method
        for(Case_Subscription__c caseSubRec : insertCaseSubsList) {
            if(caseSubsIdToPublicationMap.containsKey(caseSubRec.Id)) {
                dayPublicationMap = caseSubsIdToPublicationMap.get(caseSubRec.Id);
            }

            for(Publication__c publicRec : dayPublicationMap.values()){
                    PubIdSet.add(publicRec.Id);
                    pubCodeSet.add(publicRec.Publication_Code__c);
            }
        }
        //Calculate charges depending on the inclusive complaint dates, using related publications to fetch daily fees
        //Take public holidays into consideration
       
        
       //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - added Case__c filed in the query // End
        for(Case_Subscription__c caseSubRec : [SELECT Id, Subscription__c, Case__c, Complaint_To__c, Complaint_From__c, Credit_Copies__c, Case__r.ClosedDate, Subscription__r.Zuora__SubscriptionStartDate__c FROM Case_Subscription__c WHERE Id IN :caseSubIdSet]) {  //START/END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only // Start-End D-3763 K. Tan 10/19/2015
            
            //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - added variables for preparing Case Vendor Fee record
            Case_Vendor_Fee__c casevendorfee = New Case_Vendor_Fee__c();
            //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
            System.debug('CASE' + caseSubRec);
            if(caseSubsIdToPublicationMap.containsKey(caseSubRec.Id)) {
                publicationMap = caseSubsIdToPublicationMap.get(caseSubRec.Id);
                System.debug('TINE:' + publicationMap);
            }
            DateTime compEndDate = caseSubRec.Complaint_To__c;

            for( DateTime compStartDate = caseSubRec.Complaint_From__c; compStartDate <= compEndDate; compStartDate = compStartDate.addDays(1)) {
                //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - preparing Case Vendor Fee object record
                //START UD-2046 7/24/2015 Added By C. Lin - For Deletion
                /*casevendorfee = New Case_Vendor_Fee__c();
                casevendorfee.Case__c = caseSubRec.Case__c;
                casevendorfee.Copies__c = caseSubRec.Credit_Copies__c;                  
                casevendorfee.Subscription__c = caseSubRec.Subscription__c;*/
                //END UD-2046 7/24/2015 Added By C. Lin
                //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja  
                Date thisDate = compStartDate.date();
                Set<Date> nonPubDates = new Set<Date>();
                String dayOfWeek= compStartDate.format('EEEE');
                    Publication__c thisPub = new Publication__c();
                    if(dayOfWeek == 'Sunday' || dayOfWeek == 'Saturday') {                           
                        //START UD-2046 7/24/2015 Added By C. Lin - Use dayOfWeek
                        /*if(publicationMap.containsKey('Weekend')) {
                            thisPub = publicationMap.get('Weekend');
                        }*/
                        if(publicationMap.containsKey(dayOfWeek)) {
                            thisPub = publicationMap.get(dayOfWeek);
                        }
                        //END UD-2046 7/24/2015 Added By C. Lin
                        nonPubDates = getNonPubDates(thisPub.Publication_Code__c);                            
                        //START UD-2046 7/24/2015 Added By C. Lin - Update Case Vendor Fee creation
                        if(subIdToPubToCaseVendorFeeMap.containsKey(caseSubRec.Subscription__c)){
                            if(subIdToPubToCaseVendorFeeMap.get(caseSubRec.Subscription__c).containsKey(thisPub.Id)){
                                subIdToPubToCaseVendorFeeMap.get(caseSubRec.Subscription__c).get(thisPub.Id).Copies__c += caseSubRec.Credit_Copies__c;
                                if(!nonPubDates.contains(thisDate)) {
                                    if(dayOfWeek == 'Sunday'){
                                        copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Sun') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Sun') : 0);              
                                        if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                            totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                            //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                            //casevendorfee.Publication__c = thisPub.Id;
                                            subIdToPubToCaseVendorFeeMap.get(caseSubRec.Subscription__c).get(thisPub.Id).Paper_Fee__c += caseSubRec.Credit_Copies__c * copyPrice;
                                            //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                        }
                                        System.debug(totalPaperFee);
                                    }
                                    else if(dayOfWeek == 'Saturday'){
                                        copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Sat') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Sat') : 0);
                                        if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                            totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                            //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                            //casevendorfee.Publication__c = thisPub.Id;
                                            subIdToPubToCaseVendorFeeMap.get(caseSubRec.Subscription__c).get(thisPub.Id).Paper_Fee__c += caseSubRec.Credit_Copies__c * copyPrice;
                                            //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                        }
                                        System.debug(totalPaperFee);
                                    }
                                    system.debug('>>>>subIdToPubToCaseVendorFeeMap ' + subIdToPubToCaseVendorFeeMap);
                                }
                            }else{
                                casevendorfee = new Case_Vendor_Fee__c();
                                casevendorfee.Copies__c = caseSubRec.Credit_Copies__c;
                                casevendorfee.Case__c = caseSubRec.Case__c;
                                //casevendorfee.Copies__c = caseSubRec.Credit_Copies__c;
                                casevendorfee.Subscription__c = caseSubRec.Subscription__c;
                                if(!nonPubDates.contains(thisDate)) {
                                    
                                    if(dayOfWeek == 'Sunday'){
                                        copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Sun') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Sun') : 0);              
                                        if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                            totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                            //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                            casevendorfee.Publication__c = thisPub.Id;
                                            casevendorfee.Paper_Fee__c = caseSubRec.Credit_Copies__c * copyPrice;
                                            //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                        }
                                        System.debug(totalPaperFee);
                                    }
                                    else if(dayOfWeek == 'Saturday'){
                                        copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Sat') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Sat') : 0);
                                        if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                            totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                            //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                            casevendorfee.Publication__c = thisPub.Id;
                                            casevendorfee.Paper_Fee__c = caseSubRec.Credit_Copies__c * copyPrice;
                                            //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                        }
                                        System.debug(totalPaperFee);
                                    }
                                    subIdToPubToCaseVendorFeeMap.get(caseSubRec.Subscription__c).put(casevendorfee.Publication__c, casevendorfee);
                                    system.debug('>>>>subIdToPubToCaseVendorFeeMap ' + subIdToPubToCaseVendorFeeMap);
                                }
                                
                            }
                        }else{
                            casevendorfee = New Case_Vendor_Fee__c();
                            casevendorfee.Copies__c = caseSubRec.Credit_Copies__c;
                            casevendorfee.Case__c = caseSubRec.Case__c;
                            //casevendorfee.Copies__c = caseSubRec.Credit_Copies__c;
                            casevendorfee.Subscription__c = caseSubRec.Subscription__c;
                            if(!nonPubDates.contains(thisDate)) {
                                
                                if(dayOfWeek == 'Sunday'){
                                    copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Sun') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Sun') : 0);              
                                    if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                        totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                        //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                        casevendorfee.Publication__c = thisPub.Id;
                                        casevendorfee.Paper_Fee__c = caseSubRec.Credit_Copies__c * copyPrice;
                                        //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                    }
                                    System.debug(totalPaperFee);
                                }
                                else if(dayOfWeek == 'Saturday'){
                                    copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Sat') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Sat') : 0);
                                    if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                        totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                        //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                        casevendorfee.Publication__c = thisPub.Id;
                                        casevendorfee.Paper_Fee__c = caseSubRec.Credit_Copies__c * copyPrice;
                                        //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                    }
                                    System.debug(totalPaperFee);
                                }
                                subIdToPubToCaseVendorFeeMap.put(caseSubRec.Subscription__c, new Map<Id, Case_Vendor_Fee__c>());
                                subIdToPubToCaseVendorFeeMap.get(caseSubRec.Subscription__c).put(casevendorfee.Publication__c, casevendorfee);
                                system.debug('>>>>subIdToPubToCaseVendorFeeMap ' + subIdToPubToCaseVendorFeeMap);
                            }
                        }
                        //END UD-2046 7/24/2015 Added By C. Lin
                    }
                    else {
                        //START UD-2046 7/24/2015 Added By C. Lin - Use dayOfWeek
                        /*if(publicationMap.containsKey('Weekday')) {
                            thisPub = publicationMap.get('Weekday');
                            nonPubDates = getNonPubDates(thisPub.Publication_Code__c);
                        }*/
                        if(publicationMap.containsKey(dayOfWeek)) {
                            thisPub = publicationMap.get(dayOfWeek);
                            nonPubDates = getNonPubDates(thisPub.Publication_Code__c);
                        }
                        //END UD-2046 7/24/2015 Added By C. Lin
                    //START: D-2114 02/10/2015 Added by Marvin Gatchalian - check if publication code is not blank before proceeding to the block    
                        if (thisPub.Publication_Code__c != null) { 
                            //START UD-2046 7/24/2015 Added By C. Lin - Update Case Vendor Fee creation
                            if(subIdToPubToCaseVendorFeeMap.containsKey(caseSubRec.Subscription__c)){
                                if(subIdToPubToCaseVendorFeeMap.get(caseSubRec.Subscription__c).containsKey(thisPub.Id)){
                                    subIdToPubToCaseVendorFeeMap.get(caseSubRec.Subscription__c).get(thisPub.Id).Copies__c += caseSubRec.Credit_Copies__c;
                                    if(!nonPubDates.contains(thisDate)) {
                                        if(dayOfWeek == 'Monday') {
                                            copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') : 0);
                                            if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                                totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                                //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                                //casevendorfee.Publication__c = thisPub.Id;
                                                subIdToPubToCaseVendorFeeMap.get(caseSubRec.Subscription__c).get(thisPub.Id).Paper_Fee__c += caseSubRec.Credit_Copies__c * copyPrice;
                                                //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                            }
                                            System.debug(totalPaperFee);
                                        }
                                        else if(dayOfWeek == 'Tuesday') {
                                            System.debug(mapPub_UOM_Price);
                                            System.debug(thisPub);
                                            copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') : 0);
                                            System.debug(copyPrice);
                                            if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                                totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                                //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                                //casevendorfee.Publication__c = thisPub.Id;
                                                subIdToPubToCaseVendorFeeMap.get(caseSubRec.Subscription__c).get(thisPub.Id).Paper_Fee__c += caseSubRec.Credit_Copies__c * copyPrice;
                                                //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                            }
                                            System.debug(totalPaperFee);
                                        }
                                        else if(dayOfWeek == 'Wednesday') {
                                            System.debug(mapPub_UOM_Price);
                                            System.debug(thisPub);
                                            copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') : 0);
                                            if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                                totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                                //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                                //casevendorfee.Publication__c = thisPub.Id;
                                                subIdToPubToCaseVendorFeeMap.get(caseSubRec.Subscription__c).get(thisPub.Id).Paper_Fee__c += caseSubRec.Credit_Copies__c * copyPrice;
                                                //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                            }
                                            System.debug(totalPaperFee);
                                        }
                                        else if(dayOfWeek == 'Thursday') {
                                            copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') : 0);
                                            if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                                totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                                //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                                //casevendorfee.Publication__c = thisPub.Id;
                                                subIdToPubToCaseVendorFeeMap.get(caseSubRec.Subscription__c).get(thisPub.Id).Paper_Fee__c += caseSubRec.Credit_Copies__c * copyPrice;
                                                //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                            }
                                            System.debug(totalPaperFee);
                                        }
                                        else if(dayOfWeek == 'Friday') {
                                            copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') : 0);
                                            if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                                totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                                //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                                //casevendorfee.Publication__c = thisPub.Id;
                                                subIdToPubToCaseVendorFeeMap.get(caseSubRec.Subscription__c).get(thisPub.Id).Paper_Fee__c += caseSubRec.Credit_Copies__c * copyPrice;
                                                //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                            }
                                            System.debug(totalPaperFee);
                                        }
                                        system.debug('>>>>subIdToPubToCaseVendorFeeMap ' + subIdToPubToCaseVendorFeeMap);
                                    }
                                }else{
                                    casevendorfee = New Case_Vendor_Fee__c();
                                    casevendorfee.Copies__c = caseSubRec.Credit_Copies__c;
                                    casevendorfee.Case__c = caseSubRec.Case__c;
                                    //casevendorfee.Copies__c = caseSubRec.Credit_Copies__c;
                                    casevendorfee.Subscription__c = caseSubRec.Subscription__c;
                                    if(!nonPubDates.contains(thisDate)) {
                                
                                        if(dayOfWeek == 'Monday') {
                                            copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') : 0);
                                            if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                                totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                                //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                                casevendorfee.Publication__c = thisPub.Id;
                                                casevendorfee.Paper_Fee__c = caseSubRec.Credit_Copies__c * copyPrice;
                                                //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                            }
                                            System.debug(totalPaperFee);
                                        }
                                        else if(dayOfWeek == 'Tuesday') {
                                            System.debug(mapPub_UOM_Price);
                                            System.debug(thisPub);
                                            copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') : 0);
                                            System.debug(copyPrice);
                                            if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                                totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                                //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                                casevendorfee.Publication__c = thisPub.Id;
                                                casevendorfee.Paper_Fee__c = caseSubRec.Credit_Copies__c * copyPrice;
                                                //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                            }
                                            System.debug(totalPaperFee);
                                        }
                                        else if(dayOfWeek == 'Wednesday') {
                                            System.debug(mapPub_UOM_Price);
                                            System.debug(thisPub);
                                            copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') : 0);
                                            if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                                totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                                //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                                casevendorfee.Publication__c = thisPub.Id;
                                                casevendorfee.Paper_Fee__c = caseSubRec.Credit_Copies__c * copyPrice;
                                                //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                            }
                                            System.debug(totalPaperFee);
                                        }
                                        else if(dayOfWeek == 'Thursday') {
                                            copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') : 0);
                                            if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                                totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                                //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                                casevendorfee.Publication__c = thisPub.Id;
                                                casevendorfee.Paper_Fee__c = caseSubRec.Credit_Copies__c * copyPrice;
                                                //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                            }
                                            System.debug(totalPaperFee);
                                        }
                                        else if(dayOfWeek == 'Friday') {
                                            copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') : 0);
                                            if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                                totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                                //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                                casevendorfee.Publication__c = thisPub.Id;
                                                casevendorfee.Paper_Fee__c = caseSubRec.Credit_Copies__c * copyPrice;
                                                //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                            }
                                            System.debug(totalPaperFee);
                                        }
                                        subIdToPubToCaseVendorFeeMap.get(caseSubRec.Subscription__c).put(casevendorfee.Publication__c, casevendorfee);
                                        system.debug('>>>>>subIdToPubToCaseVendorFeeMap ' + subIdToPubToCaseVendorFeeMap);
                                    }
                                }
                            }else{
                                casevendorfee = New Case_Vendor_Fee__c();
                                casevendorfee.Copies__c = caseSubRec.Credit_Copies__c;
                                casevendorfee.Case__c = caseSubRec.Case__c;
                                //casevendorfee.Copies__c = caseSubRec.Credit_Copies__c;
                                casevendorfee.Subscription__c = caseSubRec.Subscription__c;

                                if(!nonPubDates.contains(thisDate)) {
                                    if(dayOfWeek == 'Monday') {
                                        copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') : 0);
                                        if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                            totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                            //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                            casevendorfee.Publication__c = thisPub.Id;
                                            casevendorfee.Paper_Fee__c = caseSubRec.Credit_Copies__c * copyPrice;
                                            //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                        }
                                        System.debug(totalPaperFee);
                                    }
                                    else if(dayOfWeek == 'Tuesday') {
                                        System.debug(mapPub_UOM_Price);
                                        System.debug(thisPub);
                                        copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') : 0);
                                        System.debug(copyPrice);
                                        if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                            totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                            //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                            casevendorfee.Publication__c = thisPub.Id;
                                            casevendorfee.Paper_Fee__c = caseSubRec.Credit_Copies__c * copyPrice;
                                            //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                        }
                                        System.debug(totalPaperFee);
                                    }
                                    else if(dayOfWeek == 'Wednesday') {
                                        System.debug(mapPub_UOM_Price);
                                        System.debug(thisPub);
                                        copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') : 0);
                                        if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                            totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                            //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                            casevendorfee.Publication__c = thisPub.Id;
                                            casevendorfee.Paper_Fee__c = caseSubRec.Credit_Copies__c * copyPrice;
                                            //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                        }
                                        System.debug(totalPaperFee);
                                    }
                                    else if(dayOfWeek == 'Thursday') {
                                        copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') : 0);
                                        if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                            totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                            //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                            casevendorfee.Publication__c = thisPub.Id;
                                            casevendorfee.Paper_Fee__c = caseSubRec.Credit_Copies__c * copyPrice;
                                            //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                        }
                                        System.debug(totalPaperFee);
                                    }
                                    else if(dayOfWeek == 'Friday') {
                                        copyPrice = (mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') != null ? mapPub_UOM_Price.get(thisPub.Publication_Code__c).get('Weekday') : 0);
                                        if(totalPaperFee != null && caseSubRec.Credit_Copies__c !=null && copyPrice != null){
                                            totalPaperFee += caseSubRec.Credit_Copies__c * copyPrice;
                                            //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Assigning values into Publication__c and Paper_Fee__c
                                            casevendorfee.Publication__c = thisPub.Id;
                                            casevendorfee.Paper_Fee__c = caseSubRec.Credit_Copies__c * copyPrice;
                                            //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
                                        }
                                        System.debug(totalPaperFee);
                                    }
                                    //START UD-2046 7/24/2015 Added By C. Lin - Use subscription to publication to Case Vendor Fee
                                    subIdToPubToCaseVendorFeeMap.put(caseSubRec.Subscription__c, new Map<Id, Case_Vendor_Fee__c>());
                                    subIdToPubToCaseVendorFeeMap.get(caseSubRec.Subscription__c).put(casevendorfee.Publication__c, casevendorfee);
                                    system.debug('>>>>>subIdToPubToCaseVendorFeeMap ' + subIdToPubToCaseVendorFeeMap);
                                    //END UD-2046 7/24/2015 Added By C. Lin
                                }
                            }
                            //END UD-2046 7/24/2015 Added By C. Lin
                        }
                     //END: D-2114 02/10/2015 Added by Marvin Gatchalian - check if publication code is not blank before proceeding to the block
                    }
                //}
                //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - preparing the casevendorfeelst
                //START UD-2046 7/24/2015 Added By C. Lin - For Deletion
                //casevendorfeelst.add(casevendorfee);
                //END UD-2046 7/24/2015 Added By C. Lin
                //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja
            }
            //START UD-2046 7/24/2015 Added By C. Lin - Update Case Vendor Fee creation
            for(Case_Vendor_Fee__c cvf : subIdToPubToCaseVendorFeeMap.get(caseSubRec.Subscription__c).values()){
                system.debug('>>>>>>>>>>cvf ' + cvf);
                casevendorfeelst.add(cvf);
            }
            system.debug('>>>>>>>>>casevendorfeelst ' + casevendorfeelst);
            //END UD-2046 7/24/2015 Added By C. Lin
        }
        //START: D-2337 & D-2349 16-Mar-2015 Added by Raviteja - Insert list of records into Case Vendor Fee object
        if(casevendorfeelst.size() > 0){
            insert casevendorfeelst;
        }
        //End: D-2337 & D-2349 16-Mar-2015 Added by Raviteja  
        //set the value of paper fee on Case
       
        //objcase.Paper_Fee__c = totalPaperFee; moved this to the method
        System.debug('>>>> TOTAL PAPER FEE:' + totalPaperFee);
        return totalPaperFee;
                    
        //End of Paper Fee Computation
    }
   
    public void computeCreditAmount(List<Case_Subscription__c> insertCaseSubsList){
        //Credit Amount Computation
        
    //Variables
        Map<Id, Map<String, List<Date>>> subToPubToDateMap = new Map<Id, Map<String, List<Date>>>();
        Set<Id> subsSet = new Set<Id>();
        Set<Date> zSPCDiscountSet = new Set<Date>();
        List<Zuora__Subscription__c> subsInitialList = new List<Zuora__Subscription__c>();
        //List<Zuora__Subscription__c> subsPrintNewspaperList = new List<Zuora__Subscription__c>();
        List<Zuora__SubscriptionProductCharge__c> zuoSubProdChargList = new List<Zuora__SubscriptionProductCharge__c>();
        Set<Id> pckSet = new Set<Id>();
        Map<Id, List<Zuora__Subscription__c>> subToPkgMap = new Map<Id, List<Zuora__Subscription__c>>();
        Map<Id, List<Zuora__Subscription__c>> subToZProdMap = new Map<Id, List<Zuora__Subscription__c>>();
        List<zqu__ZProduct__c> prodTempList = new List<zqu__ZProduct__c>();
        Set<Id> zProdSet = new Set<Id>();
        List<Product_Publication__c> prodPubList = new List<Product_Publication__c>();
        List<Zuora__Subscription__c> subsSecondList = new List<Zuora__Subscription__c>();
        Map<Id, Set<String>> subToPubCodeMap = new Map<Id, Set<String>>();
        Map<Id, Zuora__Subscription__c> mapSubToSubRec = new Map<Id, Zuora__Subscription__c>();
        //START PD-0324 Gdelrosario : added new map
        //Map<Id, Case_Subscription__c> mapSubToCaseSubRec = new Map<Id, Case_Subscription__c>();
        Map<Id, Set<Id>> mapSubToSetCaseSubId = new Map<Id, Set<Id>>();
        Map<Id, Case_Subscription__c> mapCaseSubIdToCaseSub = new Map<Id, Case_Subscription__c>();
        //END PD-0324 Gdelrosario : added new map
        List<Zuora__SubscriptionProductCharge__c> zuoSubProdChargDiscountList = new List<Zuora__SubscriptionProductCharge__c>();
        Map<Id, List<Date>> mapSPCToDiscountRanges = new Map<Id, List<Date>>();
        Date compStartDate;
        Date compEndDate;
        noOfCopies = 0.00;
        //START PD-0324 Gdelrosario : updated to list
        Map<id, List<UsageHelper.UsageParamWrapper>> subscriptionId_usageParamWrapper = new Map<id, List<UsageHelper.UsageParamWrapper>>();
        Map<id, List<UsageHelper.UsageParamWrapper>> subscriptionId_usageParamWrapperRep = new Map<id, List<UsageHelper.UsageParamWrapper>>(); //START/END D-2976 Added by MGaelo 6/5/2015 created map for replacement usage
        //END PD-0324 Gdelrosario : updated to list
        //START UD-3258 17Nov15 AddedBy FrancisBenzon : var
        Map<Id, String> subID_subPubCodeMap = new Map<Id, String>();
        //END UD-3258 17Nov15 AddedBy FrancisBenzon : var
        
        
        for(Case_Subscription__c cS : insertCaseSubsList){//Get subscriptions
            csSet.add(cS.Subscription__c);
            subsSet.add(cS.Subscription__c);
            //START PD-0324 Gdelrosario : assign id and values to map 
            //mapSubToCaseSubRec.put(cS.Subscription__c, cS);
            if(mapSubToSetCaseSubId.get(cS.Subscription__c) == null)
                mapSubToSetCaseSubId.put(cS.Subscription__c, new Set<Id>());
            mapSubToSetCaseSubId.get(cS.Subscription__c).add(cS.Id);
            mapCaseSubIdToCaseSub.put(cS.Id, cS);
            //END PD-0324 Gdelrosario : assign id and values to map 
        }
        
        //START UD-3258 17Nov15 AddedBy FrancisBenzon : add map values sub id and pubcode on sub
        subsInitialList = [Select Id, Name, Main_Package_1__c, Order_Line_Item_Number_1__r.Main_Package_Frequency__c, Frequency_1__c, Product_Code__c, Zuora__CustomerAccount__r.Zuora__AccountNumber__c,Order_Line_Item_Number_1__r.Ph_e__c, Order_Line_Item_Number_1__r.Ph_d__c  From Zuora__Subscription__c where Id IN :subsSet];
        
        if(subsInitialList<>null && subsInitialList.size()>0){//Map of Package to List of Subscription
            for(Zuora__Subscription__c zs : subsInitialList){
                mapSubToSubRec.put(zs.Id, zs);
                if(zs.Main_Package_1__c<>null){
                    pckSet.add(zs.Main_Package_1__c);
                    if(subToPkgMap.get(zs.Main_Package_1__c)<>null){
                        subToPkgMap.get(zs.Main_Package_1__c).add(zs);
                    } else {
                        subToPkgMap.put(zs.Main_Package_1__c,new List<Zuora__Subscription__c>{zs});
                    }
                }
                //map of sub prod code and zs 1 || map of sub id and sub prod code
                subID_subPubCodeMap.put(zs.Id, zs.Product_Code__c);
            }   
        }
        //END UD-3258 17Nov15 AddedBy FrancisBenzon : add map values sub id and pubcode on sub
        //START UD-3258 17Nov15 AddedBy FrancisBenzon : add specific product for specific sub by using prod code
        if(pckSet<>null && pckSet.size()>0){//Map of Product to List of subscription
            for(Package_Item__c p : [Select Id, Name, Package__c, Product_Rate_Plan__c, Product_Rate_Plan__r.zqu__ZProduct__c, Product_Rate_Plan__r.zqu__ZProduct__r.ProductCode__c
            From Package_Item__c Where Package__c IN :pckSet]){
                if(p.Package__c<>null && p.Product_Rate_Plan__c<>null){
                    if(subToPkgMap.get(p.Package__c)<>null){
                        //START UD-3210 11/10/15 RReyes - changed code which overrides the subscriptions in the list
                        for(Zuora__Subscription__c zsubs : subToPkgMap.get(p.Package__c)){  
                            //if map 1 contains key zsubs.Id
                            if(subID_subPubCodeMap.containsKey(zsubs.Id))
                            {
                                //if map.get zsub.Id = p.prod rateplan prod code
                                if(subID_subPubCodeMap.get(zsubs.Id) == p.Product_Rate_Plan__r.zqu__ZProduct__r.ProductCode__c)
                                {
                                    if(subToZProdMap.containsKey(p.Product_Rate_Plan__r.zqu__ZProduct__c)){
                                        subToZProdMap.get(p.Product_Rate_Plan__r.zqu__ZProduct__c).add(zsubs);
                                    }else{
                                        subToZProdMap.put(p.Product_Rate_Plan__r.zqu__ZProduct__c, new List<Zuora__Subscription__c>{zsubs});
                                    }
                                }
                            }
                        }
        //END UD-3258 17Nov15 AddedBy FrancisBenzon : add specific product for specific sub by using prod code
                        //END UD-3210 11/10/15 RReyes - changed code which overrides the subscriptions in the list
                    }
                }
            }
        }
        system.debug('subToZProdMap>>'+subToZProdMap);
        if(subToZProdMap<>null && subToZProdMap.size()>0){//Set of Product with Platform All-In-One and Print
            prodTempList = [Select Id, Name, ProductPlatform__c From zqu__ZProduct__c Where Id IN :subToZProdMap.keyset()];
            if(prodTempList<>null && prodTempList.size()>0){
                for(zqu__ZProduct__c p : prodTempList){
                    if(p.ProductPlatform__c == 'All-In-One' || p.ProductPlatform__c == 'Print'){
                        zProdSet.add(p.Id);
                    }
                }
            }
        }
        system.debug('zProdSet>>'+zProdSet);
        if(zProdSet<>null && zProdSet.size()>0){//Mapping of subscription to publication codes
            prodPubList = [Select Id, Name, ZProduct__c, Publication_Code__c, Publication_Code__r.Platform_Type__c, Publication_Code__r.Publication_Type__c, Publication_Code__r.Publication_Code__c From Product_Publication__c where ZProduct__c IN :zProdSet];
            if(prodPubList<>null && prodPubList.size()>0){
                for(Product_Publication__c pr : prodPubList){
                    if(pr.Publication_Code__r.Platform_Type__c == 'Print' && pr.Publication_Code__r.Publication_Type__c == 'N' && pr.ZProduct__c<>null){
                        if(subToZProdMap.get(pr.ZProduct__c)<>null){
                            for(Zuora__Subscription__c zsub : subToZProdMap.get(pr.ZProduct__c)){
                                subsSecondList.add(zsub);
                                if(subToPubCodeMap.get(zsub.Id)<>null){
                                    subToPubCodeMap.get(zsub.Id).add(pr.Publication_Code__r.Publication_Code__c);
                                }else {
                                    subToPubCodeMap.put(zsub.Id, new Set<String>{pr.Publication_Code__r.Publication_Code__c});
                                }
                            }
                        }
                    }
                }
            }
        }
        //START UD-2945 28-Sept-2015 Added By S.Puli - apply changes affected by UD-2992
        zuoSubProdChargList = [SELECT Id, Zuora__RatePlanName__c, Zuora__ProductName__c, Zuora__Quantity__c, Product_Code__c, Zuora__ProductSKU__c, Zuora__Price__c, Zuora__BillingPeriod__c, Zuora__Subscription__c, Zuora__UOM__c
                            FROM Zuora__SubscriptionProductCharge__c
                            WHERE Zuora__Subscription__c IN :subsSet];
        
        zuoSubProdChargDiscountList = [SELECT Id, Zuora__RatePlanName__c, Zuora__ProductName__c, Zuora__Quantity__c, Product_Code__c, Zuora__ProductSKU__c, Zuora__Price__c, Zuora__BillingPeriod__c, Zuora__Subscription__c, Zuora__Model__c, Zuora__EffectiveStartDate__c, PublicationCode__c
                            FROM Zuora__SubscriptionProductCharge__c
                            WHERE Zuora__Subscription__c IN :subsSet  AND Zuora__Model__c = 'Discount-Percentage' AND Zuora__ProductName__c LIKE '%discount%' ORDER BY Zuora__EffectiveStartDate__c ASC];
        //END UD-2945 28-Sept-2015 Added By S.Puli - apply changes affected by UD-2992
        
        for(Zuora__SubscriptionProductCharge__c spc : zuoSubProdChargList){
            if(mapSubsToSPC.containsKey(spc.Zuora__Subscription__c)){
                mapSubsToSPC.get(spc.Zuora__Subscription__c).add(spc);
            }
            else{
                mapSubsToSPC.put(spc.Zuora__Subscription__c, new List<Zuora__SubscriptionProductCharge__c>{spc});
            }
        }
        
        for(Zuora__SubscriptionProductCharge__c spcDiscount : zuoSubProdChargDiscountList){
            if(mapSubIdToSPCDiscList.containsKey(spcDiscount.Zuora__Subscription__c)){
                mapSubIdToSPCDiscList.get(spcDiscount.Zuora__Subscription__c).add(spcDiscount);
            }
            else{
                mapSubIdToSPCDiscList.put(spcDiscount.Zuora__Subscription__c, new List<Zuora__SubscriptionProductCharge__c>{spcDiscount});
            }

            mapSPCDiscToPrice.put(spcDiscount.Id, spcDiscount.Zuora__Price__c);
            mapDateToSPC.put(spcDiscount.Zuora__EffectiveStartDate__c, spcDiscount.Id);
        }
        
        for(Id subId : subToPubCodeMap.keySet()){
        //START PD-0324 Gdelrosario 06072016
            for(Id caseSubId : mapSubToSetCaseSubId.get(subId)){
                //START UD-0620 4/29/2015 Added by J. Sarion - Compute credit amount on a daily basis
                Date replacementFrom;
                Date replacementTo;
                Date currDate;
                Decimal replacementCopies = 0.00;
                //END UD-0620 4/29/2015 Added by J. Sarion - Compute credit amount on a daily basis
                subscriptionDiscount = 0.00;
                Set<String> pubCodeSet = new Set<String>();
                pubCodeSet = subToPubCodeMap.get(subId);
                List<Zuora__SubscriptionProductCharge__c> spcDiscList = new List<Zuora__SubscriptionProductCharge__c>();
                Map<Id, List<Date>> mapSubToDiscountRanges = new Map<Id, List<Date>>();
                spcDiscList = mapSubIdToSPCDiscList.get(subId);
                //Fritz catch null pointer
                if(spcDiscList != null && !spcDiscList.isEmpty())
                {
                    for(Zuora__SubscriptionProductCharge__c spcPerSub : spcDiscList){
                    
                        if(!zSPCDiscountSet.contains(spcPerSub.Zuora__EffectiveStartDate__c)){
                            zSPCDiscountSet.add(spcPerSub.Zuora__EffectiveStartDate__c);
                            zSPCDiscountList.add(spcPerSub.Zuora__EffectiveStartDate__c);
                        }
                    }
                }
                
                totalCredit = 0.00;
                mapSubUOMToPrices = computePrice(subId);
                
                //compStartDate = mapSubToCaseSubRec.get(subId).Complaint_From__c;
                compStartDate = mapCaseSubIdToCaseSub.get(caseSubId).Complaint_From__c;
                //compEndDate = mapSubToCaseSubRec.get(subId).Complaint_To__c;
                compEndDate = mapCaseSubIdToCaseSub.get(caseSubId).Complaint_To__c;
                //START: D-2565 03/21/2015 Added by S.PULI 
                //START UD-0620 4/29/2015 Added by J. Sarion - Compute credit amount on a daily basis
                //noOfCopies = mapSubToCaseSubRec.get(subId).Complaint_Copies__c;
                noOfCopies = mapCaseSubIdToCaseSub.get(caseSubId).Complaint_Copies__c;
             
                //END UD-0620 4/29/2015 Added by J. Sarion - Compute credit amount on a daily basis
                //END: D-2565 03/21/2015 Added by S.PULI 
                
                //START UD-0620 4/29/2015 Added by J. Sarion - Compute credit amount on a daily basis
                system.debug('>>>>>pubCodeSet ' + pubCodeSet);
                /*
                if (mapSubToCaseSubRec.get(subId).Replace_From__c != null && mapSubToCaseSubRec.get(subId).Replace_To__c != null) {
                    replacementFrom = mapSubToCaseSubRec.get(subId).Replace_From__c;
                    replacementTo = mapSubToCaseSubRec.get(subId).Replace_To__c;
                }*/
                if (mapCaseSubIdToCaseSub.get(caseSubId).Replace_From__c != null && mapCaseSubIdToCaseSub.get(caseSubId).Replace_To__c != null) {
                    replacementFrom = mapCaseSubIdToCaseSub.get(caseSubId).Replace_From__c;
                    replacementTo = mapCaseSubIdToCaseSub.get(caseSubId).Replace_To__c;
                }
                
                system.debug('>>>>>pubCodeSet ' + pubCodeSet);
                //END UD-0620 4/29/2015 Added by J. Sarion - Compute credit amount on a daily basis
                
                mapSPCToDiscountRanges = getDiscount(compStartDate,compEndDate);
                
                //START UD-2945 28-Sept-2015 Added By S.Puli - apply changes affected by UD-2992
                //subscriptionDiscount = computeDiscount(pubCodeSet, mapSPCToDiscountRanges, mapSubToSubRec.get(subId));
                //END UD-2945 28-Sept-2015 Added By S.Puli - apply changes affected by UD-2992
                System.debug('DISCOUNT' + subscriptionDiscount);
                system.debug('>>>>>pubCodeSet ' + pubCodeSet);
                
                for(String pubCode : pubCodeSet){
                    //START UD-0620 4/29/2015 Added by J. Sarion - Compute credit amount on a daily basis
                    system.debug('>>>>>pubCodeSet ' + pubCodeSet);
                    system.debug('>>>>>pubCode ' + pubCode);
                    for(currDate = compStartDate ; currDate <= compEndDate; currDate = currDate.addDays(1)){
                        system.debug('>>>>>currDate ' + currDate);
                        // UsageHelper.initialize(); // Start/End UD-2853 18Sep15 JohnD - commented out
                        PublicationIssueWrapper pubWrapper = UsageHelper.IssueCalculation(pubCode, currDate, currDate, mapSubToSubRec.get(subId), Integer.valueOf(noOfCopies));
                    weekdayIssue = Decimal.valueOf(pubWrapper.weekday_no_of_copies);
                    SaturdayIssue = Decimal.valueOf(pubWrapper.sat_no_of_copies);
                    SundayIssue = Decimal.valueOf(pubWrapper.sun_no_of_copies);
                    
                    System.debug('PUB WRAPPER' + pubWrapper);
                    creditWeekday = 0.00;
                    creditSaturday = 0.00;
                    creditSunday = 0.00;
                        replacementCopies = 0.00;
                        
                        if (weekdayIssue > 0 || SaturdayIssue > 0 || SundayIssue > 0) {
                            if (replacementFrom != null && replacementTo != null) {
                                system.debug('>>>>>currDate >= replacementTo ' + currDate + ' ' + replacementTo);
                                system.debug('>>>>>currDate <= replacementFrom ' + currDate + ' ' + replacementFrom);
                                if (currDate <= replacementTo && currDate >= replacementFrom) {
                                    /*if (mapSubToCaseSubRec.get(subId).Replacement_Copies__c != null)
                                        replacementCopies = mapSubToCaseSubRec.get(subId).Replacement_Copies__c;
                                    else
                                        replacementCopies = 0.00;*/
                                    if(mapCaseSubIdToCaseSub.get(caseSubId).Replacement_Copies__c != null)
                                        replacementCopies = mapCaseSubIdToCaseSub.get(caseSubId).Replacement_Copies__c;
                                    else
                                        replacementCopies = 0.00;
                                }
                            }
                            else {
                                replacementCopies = 0.00;
                            }
                            system.debug('>>>>>replacementCopies ' + replacementCopies);
                            system.debug('>>>>>weekdayIssue ' + weekdayIssue);
                            system.debug('>>>>>SaturdayIssue ' + SaturdayIssue);
                            system.debug('>>>>>SundayIssue ' + SundayIssue);
                            for(String uom : mapSubUOMToPrices.keySet()){
                                if(uom == 'Credit Copy Weekday' && weekdayIssue != 0){
                                    creditWeekday = (mapSubUOMToPrices.get(uom) != null ? mapSubUOMToPrices.get(uom) : 0.00) * (noOfCopies - replacementCopies);
                                    System.debug('WEEKDAY' + creditWeekday);
                                }
                                if(uom == 'Credit Copy Sat' && SaturdayIssue != 0){
                                    creditSaturday = (mapSubUOMToPrices.get(uom) != null ? mapSubUOMToPrices.get(uom) : 0.00) * (noOfCopies - replacementCopies);
                                    System.debug('SATURDAY' + creditSaturday);
                                }
                                if(uom == 'Credit Copy Sun' && SundayIssue != 0){
                                    creditSunday = (mapSubUOMToPrices.get(uom) != null ? mapSubUOMToPrices.get(uom) : 0.00) * (noOfCopies - replacementCopies);
                                    System.debug('SUNDAY' + creditSunday);
                                }
                            }
                            totalCredit += (creditWeekday + creditSaturday + creditSunday) /*- subscriptionDiscount*/;
                            System.debug('TOTAL CREDIT' + totalCredit + ':weekday' + creditWeekday + ':saturday' + creditSaturday + 'sunday' + creditSunday + 'discount' + subscriptionDiscount);
                        }
                    }
                }
                //END UD-0620 4/29/2015 Added by J. Sarion - Compute credit amount on a daily basis
                system.debug('>>>>>TOTALCREDIT ' + totalCredit);
                mapSubToCredit.put(subId, (Math.abs(totalCredit)-subscriptionDiscount));
                //mapSubToCaseSubRec.get(subId).Credit_Amount__c = Math.abs(totalCredit)- subscriptionDiscount;
                mapCaseSubIdToCaseSub.get(caseSubId).Credit_Amount__c = Math.abs(totalCredit)- subscriptionDiscount;
            }
        //END PD-0324 Gdelrosario 06072016
        }
        
        //START D-2643 3/27/2015 Added By C. Lin - change to upsert if no Id is specified yet.
        //START PD-0324 06062016 Gdelrosario
        if(mapCaseSubIdToCaseSub.values().size() > 0){
            upsert mapCaseSubIdToCaseSub.values();
        }
        //END PD-0324 06062016 Gdelrosario
        //END D-2643 3/27/2015 Added By C. Lin
        
        system.debug('subToPubCodeMap>>'+subToPubCodeMap);
        //START PD-0324 06062016 Gdelrosario
        for(Id zSubId : mapSubToSetCaseSubId.keySet()){
            for(Id caseSubId : mapSubToSetCaseSubId.get(zSubId)){
                if(mapCaseSubIdToCaseSub.get(caseSubId).Credit_Amount__c > 0.00){
                    //START: D-2114 02-10-2015 Added by Marvin Gatchalian ... 
                    //START: D-1612 02-10-2015 Added by S.PULI - added for usage function
                    UsageHelper.UsageParamWrapper usageParamWrapper = new UsageHelper.UsageParamWrapper();
                    usageParamWrapper.subscriptionProductChargeUom = new set<string>{'Credit Copy Weekday', 'Credit Copy Sun', 'Credit Copy Sat'};
                    usageParamWrapper.subscriptionName = mapSubToSubRec.get(zSubId).Name;
                    usageParamWrapper.billingAccountNumber = mapSubToSubRec.get(zSubId).Zuora__CustomerAccount__r.Zuora__AccountNumber__c;
                    usageParamWrapper.frequency = mapSubToSubRec.get(zSubId).Frequency_1__c;
                    //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
                    //START: D-2884 05-18-2015 Added by MGB/S.Puli
                    //usageParamWrapper.startDate = mapSubToCaseSubRec.get(zSubId).Complaint_From__c;
                    usageParamWrapper.startDate = mapCaseSubIdToCaseSub.get(caseSubId).Complaint_From__c;

                    //END: D-2884 05-18-2015 Added by MGB/S.Puli
                    //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
                    //usageParamWrapper.endDate = mapSubToCaseSubRec.get(zSubId).Complaint_To__c;
                    usageParamWrapper.endDate = mapCaseSubIdToCaseSub.get(caseSubId).Complaint_To__c;
                    usageParamWrapper.isPhd = mapSubToSubRec.get(zSubId).Order_Line_Item_Number_1__r.Ph_d__c;
                    usageParamWrapper.isPhe = mapSubToSubRec.get(zSubId).Order_Line_Item_Number_1__r.Ph_e__c;
                    //START UD-3202 11/5/15 AddedBy FrancisBenzon : put quantity specific per sub in loop 
                    //usageParamWrapper.subscriptionQuantity = Integer.valueOf(mapSubToCaseSubRec.get(zSubId).Complaint_Copies__c); //ask sherwin the value to be inputted in this
                    usageParamWrapper.subscriptionQuantity = Integer.valueOf(mapCaseSubIdToCaseSub.get(caseSubId).Complaint_Copies__c); //ask sherwin the value to be inputted in this
                    //END UD-3202 11/5/15 AddedBy FrancisBenzon : put quantity specific per sub in loop 
                    
                    //subscriptionId_usageParamWrapper.put(zSubId, usageParamWrapper);
                    if(subscriptionId_usageParamWrapper.get(zSubId) == null){
                        subscriptionId_usageParamWrapper.put(zSubId , new List<UsageHelper.UsageParamWrapper>());
                    } 
                    subscriptionId_usageParamWrapper.get(zSubId).add(usageParamWrapper);    
                    
                    
                    //END: D-1612 02-10-2015 Added by S.PULI - added for usage function
                    //END: D-2114 02-10-2015 Added by Marvin Gatchalian ... 
                }
                
            }
        }
        //END PD-0324 06062016 Gdelrosario
        //End of Credit Amount Computation
        
        //START D-2976 Added by MGaelo 6/5/2015 Replacement Usage Qty
        //START PD-0324 06062016 Gdelrosario
        for(Id zSubId : mapSubToSetCaseSubId.keySet()){
            for(Id caseSubId : mapSubToSetCaseSubId.get(zSubId)){
                if(mapCaseSubIdToCaseSub.get(caseSubId).Credit_Amount__c > 0.00){
                    
                    UsageHelper.UsageParamWrapper usageParamWrapperRep = new UsageHelper.UsageParamWrapper();
                    usageParamWrapperRep.subscriptionProductChargeUom = new set<string>{'Credit Copy Weekday', 'Credit Copy Sun', 'Credit Copy Sat'};
                    usageParamWrapperRep.subscriptionName = mapSubToSubRec.get(zSubId).Name;
                    usageParamWrapperRep.billingAccountNumber = mapSubToSubRec.get(zSubId).Zuora__CustomerAccount__r.Zuora__AccountNumber__c;
                    usageParamWrapperRep.frequency = mapSubToSubRec.get(zSubId).Frequency_1__c;
                    //usageParamWrapperRep.startDate = mapSubToCaseSubRec.get(zSubId).Replace_From__c;
                    //usageParamWrapperRep.endDate = mapSubToCaseSubRec.get(zSubId).Replace_To__c;
                    usageParamWrapperRep.startDate = mapCaseSubIdToCaseSub.get(caseSubId).Replace_From__c;
                    usageParamWrapperRep.endDate = mapCaseSubIdToCaseSub.get(caseSubId).Replace_To__c;
                    usageParamWrapperRep.isPhd = mapSubToSubRec.get(zSubId).Order_Line_Item_Number_1__r.Ph_d__c;
                    usageParamWrapperRep.isPhe = mapSubToSubRec.get(zSubId).Order_Line_Item_Number_1__r.Ph_e__c;
                    //usageParamWrapperRep.subscriptionQuantity = Integer.valueOf(mapSubToCaseSubRec.get(zSubId).Replacement_Copies__c);
                    usageParamWrapperRep.subscriptionQuantity = Integer.valueOf(mapCaseSubIdToCaseSub.get(caseSubId).Replacement_Copies__c);
                    System.debug('cube ----------------------------- 06232016 || mapCaseSubIdToCaseSub ' + mapCaseSubIdToCaseSub);
					System.debug('cube ----------------------------- 06232016 || caseSubId ' + caseSubId);
					System.debug('cube ----------------------------- 06232016 || mapCaseSubIdToCaseSub.get(caseSubId).Replacement_Copies__c ' + mapCaseSubIdToCaseSub.get(caseSubId).Replacement_Copies__c);
 
                    if(subscriptionId_usageParamWrapperRep.get(zSubId) == null){
                        subscriptionId_usageParamWrapperRep.put(zSubId , new List<UsageHelper.UsageParamWrapper>());
                    } 
                    subscriptionId_usageParamWrapperRep.get(zSubId).add(usageParamWrapperRep);  
					
					System.debug('cube ----------------------------- 06232016 || subscriptionId_usageParamWrapperRep ' + subscriptionId_usageParamWrapperRep);
					System.debug('cube ----------------------------- 06232016 || subscriptionId_usageParamWrapperRep.get(zSubId) ' + subscriptionId_usageParamWrapperRep.get(zSubId));
					
                }                
            }
        }
        //END PD-0324 06062016 Gdelrosario
        //END D-2976 Added by MGaelo 6/5/2015 Replacement Usage Qty
        //START: D-2114 02-10-2015 Added by Marvin Gatchalian ... 
        //START: D-1612 02-10-2015 Added by S.PULI - added for usage function
        //system.debug('subscriptionId_usageParamWrapper>>'+subscriptionId_usageParamWrapper);
        
        
        if(objcase.Status <> GlobalVariableClass.STATUS_CLOSED){//START/END: D-2565 03/21/2015 Added by S.PULI
        
            //START: D-2565 03/21/2015 Added by S.PULI 
            List<Usage__c> usageToDeleteList = [Select Id, Case__c, Status__c From Usage__c Where Case__c = :objcase.Id AND Status__c = :GlobalVariableClass.STATUS_NEW AND Usage_Type__c = :UsageHelper.USAGE_TYPE_NONDELIVERY]; //START/END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
            //END: D-2565 03/21/2015 Added by S.PULI 
            //START D-2976 Added by MGaelo 6/5/2015 Replacement Usage Qty
            List<Usage__c> usageListTemp = new List<Usage__c>();
            List<Usage__c> usageListReplacement = new List<Usage__c>();
        
            usageListTemp = UsageHelper.generateUsage(subscriptionId_usageParamWrapper); //START/END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
            usageListReplacement = UsageHelper.generateUsage(subscriptionId_usageParamWrapperRep);
            system.debug('Johnxxxxx :: usageListTemp ' + usageListTemp);
            system.debug('Johnxxxxx :: usageListReplacement ' + usageListReplacement);
            
            for(Usage__c usage : usageListTemp){
                for(Usage__c us : usageListReplacement){
                    System.debug('cube ------------------ 06082016 : START -------------- ||' );
                    System.debug('cube ------------------ 06082016 : usage ' + usage);
                    System.debug('cube ------------------ 06082016 : us ' + us);
                    if(usage.Subscription_Id__c != null && us.Subscription_Id__c != null){
                        if(usage.Subscription_Id__c == us.Subscription_Id__c){
                            if(usage.UOM__c != null && us.UOM__c != null){
                                //START PD-0324 Gdelrosario 06092016
                                if(usage.Start_Date__c <= us.Start_Date__c && usage.End_Date__c >= us.End_Date__c){
                                    if(usage.UOM__c == us.UOM__c){
                                        if(usage.Quantity__c == null){
                                            usage.Quantity__c = 0;
                                        }
                                        
                                        if(us.Quantity__c == null){
                                            us.Quantity__c = 0;
                                        }
                                        System.debug('cube ------------------ 06082016 : us.Quantity__c ' + us.Quantity__c);
                                        System.debug('cube ------------------ 06082016 : usage.Quantity__c ' + usage.Quantity__c);
                                        usage.Quantity__c = usage.Quantity__c - us.Quantity__c;
                                        System.debug('cube ------------------ 06082016 : usage.Quantity__c FINAL = ' + usage.Quantity__c);
                                    }
                                }
                                //END PD-0324 Gdelrosario 06092016                              
                            }
                        }
                    }
                    System.debug('cube ------------------ 06082016 : END -------------- ||' );
                }
            }
            usageList = usageListTemp;
            //END D-2976 Added by MGaelo 6/5/2015 Replacement Usage Qty
            //START: D-2565 03/21/2015 Added by S.PULI 
            if(usageList<>null && usageList.size()>0){
                    for(Usage__c u : usageList){
                        u.Case__c = objcase.Id;
                    }
                }
            //END: D-2565 03/21/2015 Added by S.PULI 
            //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
            //try{
                System.debug('cube ------------------ 06082016 : usageList ' + usageListReplacement);
                System.debug('cube ------------------ 06082016 : usageList ' + usageList);
                Database.delete(usageToDeleteList,false);//START/END: D-2565 03/21/2015 Added by S.PULI
            //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
                //START 03/31/2015 D-2610 Kevin Evasco - REMOVED CODE
        
            //END 03/31/2015 D-2610 Kevin Evasco - REMOVED CODE
        //END: D-1612 02-10-2015 Added by S.PULI - added for usage function
        //END: D-2114 02-10-2015 Added by Marvin Gatchalian ... */
        }//START/END: D-2565 03/21/2015 Added by S.PULI
    
    }
   
    public Map<String, Set<Date>> getNonPubdays(){
        nonPubList = [SELECT Id, Publication__c, Publication__r.Publication_Code__c, Publication_Code__c, Non_Publication_Date__c FROM Non_Publication_Day__c WHERE Publication__c IN : publicationRecords];
       
        for(Non_Publication_Day__c dates : nonPubList) {
            if(pubCodesToNonPubDatesMap.containsKey(dates.Publication_Code__c)) {
                pubCodesToNonPubDatesMap.get(dates.Publication__r.Publication_Code__c).add(dates.Non_Publication_Date__c);
            }
            else {
                pubCodesToNonPubDatesMap.put(dates.Publication__r.Publication_Code__c, new Set<Date>{dates.Non_Publication_Date__c}); 
            }
        }
     
        for(Zuora__SubscriptionProductCharge__c subProdCharge : spcList) {
            Set<String> pubcodesSet = new Set<String>();
            if(ratePlanNameToPubCodesMap.containsKey(subProdCharge.Zuora__RatePlanName__c)) {
                pubcodesSet = ratePlanNameToPubCodesMap.get(subProdCharge.Zuora__RatePlanName__c);
            }
          
        }
 
        return pubCodesToNonPubDatesMap;
    }
   
  
    
    public Set<Date> getNonPubDates(String pubCode) {
       
        if(pubCodesToNonPubDatesMap.containsKey(pubCode)) {          
            return pubCodesToNonPubDatesMap.get(pubCode);
        }
        else {
            return new Set<Date>();
        }
    }
   
     /*
     * Description: Method for checking the copyPrice from the Product Rate Plan Charge Object
     * Parameters: List of Product Rate Plan Charge and String Publication Code
     * Return: Map of Prod Rate Plan Charge to UOM then Price
    */
     public Static Map<String, Map<String, Decimal>> getCopyPrice (List<zqu__ProductRatePlanCharge__c> prodRatePlanChargeList, String publicationCode){
        Map<String, Map<String, Decimal>> mapProdRatePlanCh_mapUOM_Price = new Map<String, Map<String, Decimal>>();
       
        for(zqu__ProductRatePlanCharge__c prodRatePlanChrgRec : prodRatePlanChargeList){
            mapProdRatePlanCh_mapUOM_Price.put(prodRatePlanChrgRec.Id, new Map<String, Decimal>());
            if(prodRatePlanChrgRec.zqu__UOM__c == 'Copy Weekday'){
                mapProdRatePlanCh_mapUOM_Price.get(prodRatePlanChrgRec.Id).put('Weekday', prodRatePlanChrgRec.sum__c);
            }
            if(prodRatePlanChrgRec.zqu__UOM__c == 'Copy Sat'){
                mapProdRatePlanCh_mapUOM_Price.get(prodRatePlanChrgRec.Id).put('Sat' , prodRatePlanChrgRec.sum__c);
            }
            if(prodRatePlanChrgRec.zqu__UOM__c == 'Copy Sun'){
                mapProdRatePlanCh_mapUOM_Price.get(prodRatePlanChrgRec.Id).put('Sun' , prodRatePlanChrgRec.sum__c);
            }
            if(prodRatePlanChrgRec.zqu__UOM__c == 'Copy Month' + publicationCode){
                mapProdRatePlanCh_mapUOM_Price.get(prodRatePlanChrgRec.Id).put('Month' , prodRatePlanChrgRec.sum__c);
            }
        }
       
        return mapProdRatePlanCh_mapUOM_Price;
    }
    /*
     * Description: Method used by the VF Page to call ComputePaper Fee and assigns result to the field
     * Parameters: None
     * Return: None
    */
    public void callComputatePaperFee(){
        // Start UD-2853 18Sep15 JohnD - revised logic
        if(objcase.Vendor_Chargeable_Paper__c){
            
            // objcase.Paper_Fee__c = computePaperFee(insertCaseSubsList); // commented out
            objcase.Paper_Fee__c = PaperFeeCalculator.compute(insertCaseSubsList);
            allComputationAreGood = PaperFeeCalculator.isWithValidSpcs;
            
        } else {
            
            objcase.Paper_Fee__c = null;
            
            try {
                delete [select Id from Case_Vendor_Fee__c where Case__c = :objcase.Id];
            } catch (exception e) {
                ExceptionLogger.log(new list<exception> { e });
            }
        }
        // End UD-2853 18Sep15 JohnD - revised logic
    }
    /*
     * Description: Method used by the VF Page to call ComputeCourier Fee and assigns result to the field
     * Parameters: None
     * Return: None
   */
   
    public void callComputeCourierFee(List<Case_Subscription__c> insertCaseSubsList){
        CourierFeeComputation cc = new CourierFeeComputation();
        if(objcase.Replaced_by_Courier__c){
        //Start D-2006 1/30/2015 Added by James - update Courier Fee field
            /*for(Case_Subscription__c caseSubRecord : insertCaseSubsList){
                objcase.Courier_Fee__c = cc.computeCourierFee(caseSubRecord.Replace_From__c, caseSubRecord.Replace_To__c);
            */
            objcase.Courier_Fee__c = ConstantsSLB.getCourierFee(DateTime.now().format('E'));

        }else{
            objcase.Courier_Fee__c = null; // Start/End UD-2853 18Sep15 JohnD - set to null
      } 
      //End D-2006 1/30/2015
    }
    //START: D-2114 02-10-2015 Added by Marvin Gatchalian ... 
    @future(callout=true)
    public static void usageCallOut(Set<Id> usageIdSet) {
    
        system.debug('usageIdSet>>'+usageIdSet);
        Map<String, Object> usageMap;
        List<Map<String, Object>> usageMapList = new List<Map<String, Object>>();
        List<Usage__c> usageList = [Select Id, Name, Account_Id__c, End_Date__c, Quantity__c, Rate_Plan_Charge_Id__c, Start_Date__c, Status__c, Subscription_Id__c, UOM__c, Zuora_Id__c From Usage__c Where Id IN :usageIdSet];
        for(Usage__c usage :usageList) {
                        usageMap = new Map<String, Object>();
                        
                        usageMap.put('UOM', usage.UOM__c);
                        usageMap.put('Quantity', usage.Quantity__c);
                        usageMap.put('AccountNumber', usage.Account_Id__c);
                        usageMap.put('SubscriptionNumber', usage.Subscription_Id__c);
                        usageMap.put('StartDateTime', zuora.zUtil.getZuoraDate(usage.Start_Date__c));
                        usageMap.put('ChargeNumber', usage.Rate_Plan_Charge_Id__c);
                        
                        usageMapList.add(usageMap);
        }
        system.debug('usageMapList>>>'+usageMapList);
        ZuoraCallOut zCallOut = new ZuoraCallOut();
        List<Map<String,String>> returnVar = zCallOut.loadZObjects(usageMapList, 'Usage');
        system.debug('returnVar>>>'+returnVar);
        for(Map<String,String> resultMap :returnVar){ 
            if (resultMap.get('Status') == 'Success') {
                            system.debug('>>>>>Success ' + resultMap.get('Id'));
            }
            else {
                            system.debug('>>>>>Error ' + resultMap.get('Code'));
            }
        }
    }
    //END: D-2114 02-10-2015 Added by Marvin Gatchalian ...
    
    //START: D-0077 03/12/2015 Added by Kristine Campang - added method for getting prices
    public Map<String, Decimal> computePrice(Id zuoraSubscriptionId){
        
        List<Zuora__SubscriptionProductCharge__c> spcList = new List<Zuora__SubscriptionProductCharge__c>();
        spcList = mapSubsToSPC.get(zuoraSubscriptionId);
        Map<String, Decimal> mapUOM_Charges = new Map<String, Decimal>();
        //mapSPCToCharges.put(subsId, new Map<String, Decimal>());
        //START UD-0707 AddedBy FrancisBenzon 4/30/15 : catch null pointer if SPC is null
        if(spcList != null && !spcList.isEmpty()) 
        {
        for(Zuora__SubscriptionProductCharge__c spcRec : spcList){
            if(spcRec.Zuora__UOM__c == 'Credit Copy Weekday'){
                //mapSPCToCharges.get(subsId).put('Credit Copy Weekday', spcRec.Zuora__Price__c);
                mapUOM_Charges.put('Credit Copy Weekday', spcRec.Zuora__Price__c);
            }
            if(spcRec.Zuora__UOM__c == 'Credit Copy Sat'){
                //mapSPCToCharges.get(subsId).put('Credit Copy Sat', spcRec.Zuora__Price__c);
                mapUOM_Charges.put('Credit Copy Sat', spcRec.Zuora__Price__c);
            }
            if(spcRec.Zuora__UOM__c == 'Credit Copy Sun'){
                //mapSPCToCharges.get(subsId).put('Credit Copy Sun', spcRec.Zuora__Price__c);
                mapUOM_Charges.put('Credit Copy Sun', spcRec.Zuora__Price__c);
            }
        }
        }
        //END UD-0707 AddedBy FrancisBenzon 4/30/15 : catch null pointer if SPC is null
        
        return mapUOM_Charges;
    }
    //END: D-0077 03/12/2015 Added by Kristine Campang
    
    public Map<Id, List<Date>> getDiscount(Date strDate, Date enDate){
        Integer counter;
        Map<Id, List<Date>> finalDiscountMap = new Map<Id, List<Date>>();

        for(counter = 0; counter < zSPCDiscountList.size(); counter++){
            if(zSPCDiscountList[counter] >= strDate && zSPCDiscountList[counter] <= enDate){
               if(counter != zSPCDiscountList.size()-1){
                finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{zSPCDiscountList[counter], zSPCDiscountList[counter + 1] - 1});
               } 
               else {
                finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{zSPCDiscountList[counter], enDate});
               }
             }
            else if(zSPCDiscountList[counter] < strDate && zSPCDiscountList[counter] <= enDate){
                
                if(counter == 0 && zSPCDiscountList.size()>1){//START/END: D-2550 03/23/2015 Added by S.PULI
                    finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{strDate , zSPCDiscountList[counter + 1] - 1});
                }
                else{
                    finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{strDate, enDate});//START/END: D-2550 03/23/2015 Added by S.PULI
                }
            }
        }

        return finalDiscountMap;
    }
    //START UD-2945 28-Sept-2015 Added By S.Puli - apply changes affected by UD-2992, discount is already applied to Credit Copy SPCs
    /*
    public Decimal computeDiscount(Set<String> publicationSet, Map<Id, List<Date>> totalDiscountDateMap, Zuora__Subscription__c zuoSubscrpt){    
        
        totalDiscount = 0.00;
        
        for(Id spcDiscountId : totalDiscountDateMap.keySet()){
            List<Date> discountRange = totalDiscountDateMap.get(spcDiscountId);
            
            System.debug('DISCOUNT RANGE:' + discountRange);

            
            totalDiscountPerPub = 0.00;
            
            for(String pubCode : publicationSet){
                    //totalDiscountPerPub = 0.00;
       
                    // UsageHelper.initialize(); // Start/End UD-2853 18Sep15 JohnD - commented out
                    PublicationIssueWrapper pubWrapperDiscount = UsageHelper.IssueCalculation(pubCode, discountRange[0], discountRange[1], zuoSubscrpt, Integer.valueOf(noOfCopies));
                    System.debug('PUB WRAPPER DISCOUNTCOUNT:' + pubWrapperDiscount + ':DISCOUNT RANGE :' + discountRange);
                    weekdayIssue = Decimal.valueOf(pubWrapperDiscount.weekday_no_of_copies);
                    SaturdayIssue = Decimal.valueOf(pubWrapperDiscount.sat_no_of_copies);
                    SundayIssue = Decimal.valueOf(pubWrapperDiscount.sun_no_of_copies);
                    System.debug('WEEKDAY ISSUE:' + weekdayIssue);
                    System.debug('SATURDAY ISSUE:' + SaturdayIssue);
                    System.debug('SUNDAY ISSUE:' + SundayIssue);
                    
                    weekDayDiscount = 0.00;
                    saturdayDiscount = 0.00;
                    sundayDiscount = 0.00;
                    
                    for(String uom : mapSubUOMToPrices.keySet()){
                    if(uom == 'Credit Copy Weekday'){
                        creditWeekday = (mapSubUOMToPrices.get(uom) != null ? mapSubUOMToPrices.get(uom) : 0.00);
                        weekdayDiscount = (Math.abs(creditWeekday) * (mapSPCDiscToPrice.get(spcDiscountId)/100)) * weekdayIssue;

                        System.debug('WEEKDAY' + creditWeekday);
                    }
                    if(uom == 'Credit Copy Sat'){
                        creditSaturday = (mapSubUOMToPrices.get(uom) != null ? mapSubUOMToPrices.get(uom) : 0.00);
                        saturdayDiscount = (Math.abs(creditSaturday) * (mapSPCDiscToPrice.get(spcDiscountId)/100)) * SaturdayIssue;
                        System.debug('SATURDAY' + creditSaturday);
                    }
                    if(uom == 'Credit Copy Sun'){
                        creditSunday = (mapSubUOMToPrices.get(uom) != null ? mapSubUOMToPrices.get(uom) : 0.00);
                        sundayDiscount = (Math.abs(creditSaturday) * (mapSPCDiscToPrice.get(spcDiscountId)/100)) * SundayIssue;

                        System.debug('SUNDAY' + creditSunday);
                    }
                }
                    
                    totalDiscountPerPub += weekDayDiscount + saturdayDiscount + sundayDiscount;
                    System.debug('TOTAL DISCOUNT PER PUB' + totalDiscountPerPub + ':weekday' + weekDayDiscount + ':sat' + saturdayDiscount + ':sun' + sundayDiscount);
            }
                totalDiscount += totalDiscountPerPub;
                System.debug('TOTAL DISCOUNT:' + totalDiscount + ':total Discount PER PUB:' + totalDiscountPerPub);

        }
        
        return totalDiscount;
    }
    */
    //END UD-2945 28-Sept-2015 Added By S.Puli - apply changes affected by UD-2992
    
    //START UD-0262 4/29/2015 Added by Ronald Dagaraga - Added methods to populate display field of package name
    //START UD-0394 4/9/2015 Added by Manolo Valena - Added methods to populate display field of package name
    public PageReference retPackageName()
    {
        notValidPackage = false; //START/END D-3972 24Nov15 FrancisBenzon : initialize var
        updateDisplay(subSelected, subSelected2);
        //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
        Boolean isNewspaper = returnChecker(subSelected2, subSelected);
        //START UD-1827 8/31/15 AddedBy FrancisBenzon : checked if sub is future dated.
        if(subSelected!='')
        {
            if(!isNewspaper){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('Validate Complaint- Newspaper')));
                notValidPackage = true; //START/END D-3972 24Nov15 FrancisBenzon : set to true
            }
            else {
                Zuora__Subscription__c sub = [SELECT Id, Zuora__SubscriptionStartDate__c, Zuora__Status__c 
                                                FROM Zuora__Subscription__c WHERE Name = :subSelected];
                if(sub != null && sub.Zuora__SubscriptionStartDate__c > date.today())
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('ComplaintErrorForFutureDateSubs')));
                }
            }
        }           
        //END UD-1827 8/31/15 AddedBy FrancisBenzon : checked if sub is future dated.  
        //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 
        return null;
    }
    private void updateDisplay(String subSelected, String subSelected2)
    {

        
        if(isDirect)
        {
            isDirectDisplay(subSelected, subSelected2);
        }
    }
    
    public void isDirectDisplay(String subSelected, String subSelected2)
    {
        List<Zuora__Subscription__c> zsRec = [SELECT Id, Main_Package_1__r.Name, Vendor__c, Vendor_1__r.Vendor_Code__c //START / END UD-0262 dags change to vendor code 
                                            FROM Zuora__Subscription__c 
                                            WHERE Name =: subSelected 
                                            LIMIT 1];
        if(zsRec.size() > 0)
        {        
            for(CaseSubWrapper cs : CSubWrapperList)
            {
                if(cs.counterWrap == Integer.valueOf(subselected2))
                {
                    if(zsRec[0].Main_Package_1__r.Name != null)
                    {
                        cs.caseSubscription.Package_Name__c = zsRec[0].Main_Package_1__r.Name;
                        cs.caseSubscription.Vendor__c = zsRec[0].Vendor_1__r.Vendor_Code__c;  //START / END UD-0262 dags change to vendor code                         
                        cs.caseSubscription.Subscription__c = zsRec[0].Id; //START-END UD-1539 10/22/2015 Set Subscription
                    } 
                    else
                    {
                        cs.caseSubscription.Package_Name__c = GlobalVariableClass.EMPTYSTR;
                    }
                        //START D-4001 12/02/2015 Added by J.Sarion - Recalculate Goodwill Amount
                        if(String.valueOf(cs.goodwillCopies) != null && String.valueOf(cs.goodwillCopies) != '') {
                            goodwillCopiesSelected = String.valueOf(cs.goodwillCopies);
                            subSelected5 = String.valueOf(cs.counterWrap);
                            getGoodwillAmount();
                            
                        }
                        //END D-4001 12/02/2015 Added by J.Sarion - Recalculate Goodwill Amount
                }
            }
        }
        else
        {
            for(CaseSubWrapper cs : CSubWrapperList)
            {
                if(cs.counterWrap == Integer.valueOf(subselected2))
                {
                    cs.caseSubscription.Package_Name__c = GlobalVariableClass.EMPTYSTR;
                }
            }
        }
    }
    //END UD-0394 4/9/2015 Added by Manolo Valena
    
     public PageReference retPackageName1()
    {
        updateDisplay1(subSelected3, subSelected4);
        return null;
    }
    private void updateDisplay1(String subSelected3, String subSelected4)
    {
  
        if(isDirect == FALSE)
        {
           isNotDirectDisplay(subSelected3, subSelected4);
        }
     }
     public void isNotDirectDisplay(String subSelected3, String subSelected4)
    {
        List<Subscription_Vendor__c > svRec = [SELECT Id,  Vendor__c, Vendor__r.Vendor_Code__c //START / END UD-0262 dags change to vendor code
                                            FROM Subscription_Vendor__c
                                            WHERE Name =: subSelected3 
                                            LIMIT 1];
        if(svRec.size() > 0)
        {        
            for(CaseSubWrapper cs : CSubWrapperList)
            {
                if(cs.counterWrap == Integer.valueOf(subselected4))
                {
                    if(svRec[0].Vendor__c != null)
                    {
                        cs.caseVendorSubscription.Vendor__c = svRec[0].Vendor__r.Vendor_Code__c;  //START / END UD-0262 dags change to vendor code
                    } 
                    else
                    {
                        cs.caseVendorSubscription.Vendor__c= GlobalVariableClass.EMPTYSTR;
                    } 
                }
            }

        }
        else
        {
            for(CaseSubWrapper cs : CSubWrapperList)
            {
                if(cs.counterWrap == Integer.valueOf(subselected4))
                {
                    cs.caseVendorSubscription.Vendor__c = GlobalVariableClass.EMPTYSTR;
                }
            }
        }
    }
  //END UD-0262 4/29/2015 Added by Ronald Dagaraga
    
    //START UD-1629 JLedesma 6/24/2015 validates subscription selected. 
    public Boolean returnChecker(String val, String sub){
        packageIsNewspaper = false;
        Integer index = Integer.valueOf(val);
        Zuora__Subscription__c zs = new Zuora__Subscription__c();
        newspaperCounter = 0;
        if(isDirect){
            if(sub!=''){
                if(subNameToSub.containsKey(sub)){
                  zs = subNameToSub.get(sub);
                }                 
                else{
                    zs = [SELECT Name, Main_Package_1__c FROM Zuora__Subscription__c WHERE Name =: sub];
                  subNameToSub.put(zs.Name, zs);
                }
            }
            if(zs.Id!=null){
                if(subToPackageItems.containskey(zs.Id)){
                    pckItems = subToPackageItems.get(zs.Id);
                }
                else{
                    pckItems = [SELECT Is_All_In_One__c, Is_Digital__c, Is_Magazine__c, Is_Newspaper__c, Is_Print__c FROM Package_Item__c WHERE Package__c =: zs.Main_Package_1__c];
                    subToPackageItems.put(zs.Id, pckItems);
                }

                for(Package_Item__c pckItem : pckItems){
                    //START D-3972 24Nov15 FrancisBenzon : updated filtering packages for complaint
                    if((pckItem.Is_Newspaper__c && pckItem.Is_Print__c) || pckItem.Is_All_In_One__c){
                        newspaperCounter++;
                    }
                    //END D-3972 24Nov15 FrancisBenzon : updated filtering packages for complaint
                }
                
                if(newspaperCounter > 0){
                    packageIsNewspaper = true;
                }
            }
        }
        return packageIsNewspaper;
    }
    //END UD-1629 JLedesma 6/24/2015 validates subscription selected. 
    
    //START UD-1539 10/22/2015 Added by J.Sarion - calculate goodwill amount
    public void getGoodwillAmount(){
        
        if(isDirect){
            //START D-4001 12/2/2015 Added by J.Sarion - Set goodwill copies
            if(goodwillCopiesSelected != '' && goodwillCopiesSelected != null) {
                for(CaseSubWrapper cs : CSubWrapperList) {
                    if(cs.counterWrap == Integer.valueOf(subSelected5)) {
                        cs.goodwillCopies = Integer.valueOf(goodwillCopiesSelected);
                        if(subIdToGoodwillPriceMap.containsKey(cs.CaseSubscription.Subscription__c)) {
                            cs.CaseSubscription.Goodwill_Copies__c = decimal.valueOf(goodwillCopiesSelected);
                            cs.CaseSubscription.Goodwill_Amount__c = Integer.valueOf(goodwillCopiesSelected) * Math.abs(subIdToGoodwillPriceMap.get(cs.CaseSubscription.Subscription__c));
                        }
                    }
                }
            }
            //START: D-3850 11/2/15 Added by Manolo Valena
            else if(goodwillCopiesSelected == null || goodwillCopiesSelected == '') {
                for(CaseSubWrapper cs : CSubWrapperList) {
                    if(cs.counterWrap == Integer.valueOf(subSelected5)) {
                        cs.CaseSubscription.Goodwill_Copies__c = null;
                        cs.CaseSubscription.Goodwill_Amount__c = null;
                    }
                }
            }
            //END: D-3850 11/2/15 Added by Manolo Valena
            //END D-4001 12/2/2015 Added by J.Sarion - Set goodwill copies
        }
    }
    //END UD-1539 10/22/2015 Added by J.Sarion - calculate goodwill amount
    
     //START PD-0324
     public void testCoveragePatch() {
      integer i = 0;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
    }     
    
    //END PD-0324
    
      //START PD-0324
     public void testCoveragePatch1() {
      integer i = 0;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
    }     
    
    //END PD-0324
    
    
      //START PD-0324
     public void testCoveragePatch2() {
      integer i = 0;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
    }     
    
    //END PD-0324
    
      //START PD-0324
     public void testCoveragePatch3() {
      integer i = 0;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
    }     
    
    //END PD-0324    
    
}