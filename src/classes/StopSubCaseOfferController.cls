public with sharing class StopSubCaseOfferController{
    public String promotionId {get; set;}
    public String packageId {get; set;}
    public String addOnId {get; set;}
    public String searchFrom {get; set;}
    public String searchText {get; set;}
    public String searchBillingType {get; set;}
  //START: UD-3471 1/12/16 Added by Manolo Valena
    public String searchTextPack {get; set;}
    public String searchBillingTypePack {get; set;}
    //END: UD-3471 1/12/16 Added by Manolo Valena
    public String billingTypeFromPromotion {get; set;}
    public Case caseRecord {get; set;}
    public Case existingCase {get; set;}
    //START: UD-3473 1/29/16 Added by Manolo Valena
    public Package__c addOnRecord {get; set;}
    //END: UD-3473 1/29/16 Added by Manolo Valena
    public List<Promotion_Package__c> promotionRecordList {get; set;}
    public List<Promotion_Package__c> packageRecordList {get; set;}
    public static map<string, decimal> packageId_subscriptionCharge { get; set; }
    public transient string billingType { get; set; }
    public Promotion__c promoRecord {get; set;}  
    public Package__c packageRecord {get; set;}
    //START: UD-3473 1/29/16 Added by Manolo Valena
    public Package__c addOnSelectedRecord {get; set;}
    //END: UD-3473 1/29/16 Added by Manolo Valena
    public String promoId;
    public String packId;
    public String addId;
    public transient boolean isRemoveEligibilityRuleSearchFilter { get; set; }
    public transient map<string, boolean> promotionCode_isEligible { get; set; }
    //public transient list<Promotion_Package__c> promotionResultList { get; set; }
    
    //START: D-0566 12/2/2104 Added by C. Lin For Eligibility Rule and Searching Promotion
    public transient list<SObject> promotionResultList { get; set; }
    public transient Map<String, Set<String>> promotionCodeMap {get; set;}
    //END: D-0566 12/2/2104 Added by C. Lin
    
    private class RelatedPackageWrapper {        
        string packageId;
        string packageName;
        string packageType;
        string packageSubscriptionType;
        string packageSubscriptionPeriod;
        decimal packageSubscriptionRate;        
    }
    
    public StopSubCaseOfferController(){
        caseRecord = new Case();        
        getCase();
        getSelectedId();
        getSelectedPromotion();        
        getPackages();   
        getSelectedPackage();
        getSelectedAddOn();       
        
    }
    //START UD-3471 5/1/2016 Gdelrosario : this method is called when by the vf page if packageRecordList = null
    public ApexPages.StandardSetController setPack {
        get {
            if(setPack == null) {
                //START: UD-3471 1/12/16 Added by Manolo Valena
                if(promoId != 'null') {
                    if(searchTextPack != null && searchTextPack != GlobalVariableClass.EMPTYSTR && searchTextPack != ' ') {      
                        String qry = 'SELECT Id, Name, Package_Name__c, Package_Name__r.Id, Package_Name__r.Name, ';
                        qry += 'Package_Name__r.Package_Type__c, Package_Name__r.Subscription_Period__c, Package_Name__r.Subscription_Type__c ';
                        qry += 'FROM Promotion_Package__c ';
                        qry += 'WHERE Package_Name__r.Name LIKE \'%' + searchTextPack + '%\'';
                        qry += ' AND Promotion__c = \'' + promoId + '\'';
                        qry += ' AND Package_Name__r.Billing_Type__c = \'' + searchBillingTypePack + '\'';
                        List<Promotion_Package__c> queriedList = Database.query(qry);
                        setPack = new ApexPages.StandardSetController(queriedList);
                        packageRecordList = queriedList;
                    }
                }
                else {
                    //START: UD-3471 1/12/16 Added by Manolo Valena
                    if (searchTextPack != null && searchTextPack != GlobalVariableClass.EMPTYSTR  && searchTextPack != ' ') {
                        String qry = 'SELECT Id, Name, Package_Name__c, Package_Name__r.Id, Package_Name__r.Name, ';
                        qry += 'Package_Name__r.Package_Type__c, Package_Name__r.Subscription_Period__c, Package_Name__r.Subscription_Type__c ';
                        qry += 'FROM Promotion_Package__c ';
                        qry += 'WHERE Package_Name__r.Name LIKE \'%' + searchTextPack + '%\'';
                        qry += ' AND Package_Name__r.Billing_Type__c = \'' + searchBillingTypePack + '\'';
                        List<Promotion_Package__c> queriedList = Database.query(qry);
                        setPack = new ApexPages.StandardSetController(queriedList);
                    }
                    //END: UD-3471 1/12/16 Added by Manolo Valena
                }
                //END: UD-3471 1/12/16 Added by Manolo Valena
            }
            return setPack;
        }
        set;
    } 

    public List<Promotion_Package__c> getPromo() {
        //START: UD-3471 1/12/16 Added by Manolo Valena
        if(setPack != null) {
            setPack.setpagesize(200);
            return (List<Promotion_Package__c>) setPack.getRecords();
        }
        else {
            return null;
        }
        //END: UD-3471 1/12/16 Added by Manolo Valena
    }  
    //END UD-3471 5/1/2016 Gdelrosario : this method is called when by the vf page if packageRecordList = null        
    
  //START: UD-3471 1/12/16 Added by Manolo Valena
    public void getPackageRecords() {
        setPack = null;
    }   
    //END: UD-3471 1/12/16 Added by Manolo Valena
  
    public void getSelectedId(){
        if(promoId == null){
            promoId = ApexPages.currentPage().getParameters().get('promoId');
        }
        if(packId == null){
            packId = ApexPages.currentPage().getParameters().get('packageId'); 
        }
        if(addId == null){
            addId = ApexPages.currentPage().getParameters().get('addOnId'); 
        }
    }
    
    public void getSelectedPromotion(){                    
        if(promoId != null && promoId != 'null'){
            promoRecord = [SELECT id, name FROM Promotion__c WHERE id =: promoId];
            existingCase.Offer_Promotion__c = promoRecord.id;
        } else {
            promoRecord = new Promotion__c();
            promoRecord.id = null;
        }
    }
    
    public void getSelectedPackage(){               
        if(packId != null && packId != 'null'){
            packageRecord = [SELECT id, name FROM Package__c WHERE id =: packId];
            existingCase.Offer_Package__c = packageRecord.id;
        } else {
            packageRecord = new Package__c();
            packageRecord.id = null;
        }
    }  
    
    public void getSelectedAddOn(){ 
        
        //START: UD-3473 1/29/16 Added by Manolo Valena
        if(addId != null && addId != 'null'){
            addOnSelectedRecord = [SELECT Id, Name FROM Package__c WHERE id =: addId];
            existingCase.Add_On_Package__c = addOnSelectedRecord.id;
        } else {
            addOnSelectedRecord = new Package__c();
            addOnSelectedRecord.id = null;
        }
        //END: UD-3473 1/29/16 Added by Manolo Valena
    }
    
    public void getCase(){
        String caseId = ApexPages.currentPage().getParameters().get('id');
        
        if(caseId != null){        
            existingCase = [SELECT id, owner.name, category__c, casenumber, sub_category__c, order_number__c, recordtype.name, earliest_stop_date__c, 
                            status, stop_request_date__c, sub_status__c, accountId, reason_code__c, contactId, reason_for_terminating__c, 
                            charges_waived__c, parentId, eligible_for_retention_offer__c, amount_to_refund__c, Overridden_Admin_Charges_Amount__c,
                            reason_for_overriding__c, offer_type__c, outcome__c, origin, priority, subject, description, admin_charges__c, 
                            //START: UD-3473 1/29/16 Added by Manolo Valena
                            //START: UD-3473 2/3/16 Added by Manolo Valena
              Offer_Promotion__c, Offer_Package__c, Add_On_Package__c, Route_to_Retention__c, Send_to_Retention__c, Offer_Package_Product_Family__c
                            //END: UD-3473 2/3/16 Added by Manolo Valena
                            //END: UD-3473 1/29/16 Added by Manolo Valena
              FROM Case
                            WHERE id =: caseId];
                            
            //START: D-4313 1/15/16 Added by Manolo Valena - added filter.      
            //START: D-4306 1/14/16 Added by Manolo Valena - added filter.      
            if(ApexPages.currentPage().getParameters().get('promoId') == null || 
               ApexPages.currentPage().getParameters().get('promoId') == GlobalVariableClass.NULLVALUE) {  
                promoId = existingCase.Offer_Promotion__c;
            }
            //END: D-4306 1/14/16 Added by Manolo Valena
      if(ApexPages.currentPage().getParameters().get('packageId') == null || 
               ApexPages.currentPage().getParameters().get('packageId') == GlobalVariableClass.NULLVALUE) {  
        packId = existingCase.Offer_Package__c;
      }
      if(ApexPages.currentPage().getParameters().get('addOnId') == null || 
               ApexPages.currentPage().getParameters().get('addOnId') == GlobalVariableClass.NULLVALUE) {
        //START: UD-3473 1/29/16 Added by Manolo Valena
                addId = existingCase.Add_On_Package__c;
                //END: UD-3473 1/29/16 Added by Manolo Valena
      }
      //END: D-4313 1/15/16 Added by Manolo Valena
        }
    }
    
    //START: UD-3473 1/29/16 Added by Manolo Valena
    //START: UD-3473 2/3/16 Added by Manolo Valena
    public void getAddOnRecord(){                     
        if(existingCase.Add_On_Package__c!=null){ // 2/17/2015 - Joban - Code Review Activity : Added null check
            addOnRecord = [SELECT Id, Name FROM Package__c WHERE id = :existingCase.Add_On_Package__c];
            addOnId = addOnRecord.id;
        }
    }
    //END: UD-3473 2/3/16 Added by Manolo Valena
    //END: UD-3473 1/29/16 Added by Manolo Valena

    public void getPromotions(){
        //START: D-0566 12/2/2104 Added by C. Lin Modified for getting or searching for promotions
        promotionResultList = new list<SObject>();
        Map<String, Set<String>> mapPromoCodeContract = new Map<String, Set<String>>();
        
        if (searchText.length() > 1) {
            string qry = 'select Promotion__c promoId, Promotion__r.Promotion_Code__c promoCode, Promotion__r.Name promoName, Promotion__r.Effective_Start_Date__c promoStartDate, Promotion__r.Effective_End_Date__c promoEndDate, ';
            qry += 'Promotion__r.Contract_Period__c promoContractPeriod from Promotion_Package__c where Promotion__r.Name like \'%' + searchText + '%\'';
            qry +=' and Package_Name__r.Billing_Type__c=\'' + searchBillingType + '\' group by Promotion__c, Promotion__r.Effective_Start_Date__c,';
            qry += ' Promotion__r.Effective_End_Date__c, Promotion__r.Promotion_Code__c, Promotion__r.Contract_Period__c, Promotion__r.Name limit 101';
            
            //START UD-3474 6/1/2016 Gdelrosario : added for converting the date from string to date for comparing
            List<SObject> initialResult = Database.query(qry);
            List<SObject> finalResult = new List<SObject>();
            for(SObject initResult : initialResult ){
                date now = date.today();
                date dts = date.valueOf(initResult.get('promoStartDate'));
                date dte = date.valueOf(initResult.get('promoEndDate'));
                
                if(dts < dte && dte > now){
                    finalResult.add(initResult);
                    for(SObject t :finalResult){
                        
                    }
                }
                
            }
            
            list<SObject> searchResults = finalResult.clone();
            //END UD-3474 6/1/2016 Gdelrosario : added for converting the date from string to date for comparing
            if (searchResults.size() > 0) {
                //Retrieve Eligibility Rule
                set<string> promoCodes = new set<string>();
                Set<String> promoId = new Set<String>();
                promotionCode_isEligible = new map<string, boolean>();
                promotionCodeMap = new Map<String, Set<String>>();
                
                for (SObject tmp : searchResults) {
                    //for ineligible
                    if(tmp.get('promoId') != null){
                        promoId.add((string)tmp.get('promoId'));
                    }
                    if (tmp.get('promoCode') != null) {
                        promoCodes.add((string)tmp.get('promoCode'));
                        //Start Eligibility Rule reused from KCampang's code from Start Subscription
                        if(mapPromoCodeContract.containsKey((string)tmp.get('promoCode'))){
                            mapPromoCodeContract.get((string)tmp.get('promoCode')).add((string)tmp.get('promoContractPeriod'));

                        }
                        else{
                            mapPromoCodeContract.put((string)tmp.get('promoCode'), new Set<String>{(string)tmp.get('promoContractPeriod')});
                        }
                        //End Eligibility Rule
                    }
                }
                
                //Reused from KCampang's code from Start Subscription
                PromoEligibilityRule pRule = new PromoEligibilityRule();
                //START: D-1404 2/9/2015 Added by Kristine Campang - added parameter
                promotionCodeMap = pRule.getEligibility(existingCase.accountId, 'Add', mapPromoCodeContract, null, null, false);
                //END: D-1404 2/9/2015 Added by Kristine Campang
                
                for(String promoCode : promotionCodeMap.Keyset()){
                    if(promotionCodeMap.get(promoCode )!=null){
                        promotionCode_isEligible.put(promoCode , true);
                        promotionCode_isEligible.put(promoCode , true);
                    }
                    else{
                        promotionCode_isEligible.put(promoCode , false);
                    }
                }
                //End from KCampang's
                //End Retrieve Eligibility Rule
                
                if(!(promoId.containsAll(promotionCode_isEligible.KeySet()) && promotionCode_isEligible.KeySet().containsAll(promoId))){
                    for(Id promId: promoId){
                        if(!promotionCode_isEligible.KeySet().contains(promId)){
                            promotionCode_isEligible.put(promId, false);
                        }
                    }
                    
                }
                
                if (isRemoveEligibilityRuleSearchFilter == true) {
                    promotionResultList = searchResults;
                } else {
                    promotionResultList = new list<SObject>();
                    for (SObject tmp : searchResults) {
                        string pc = (string)tmp.get('promoId');
                        if (promotionCode_isEligible.get(pc) == true) {
                            promotionResultList.add(tmp);
                        }
                    }
                }
            }
        }
        //END: D-0566 12/2/2104 Added by C. Lin
    }
    
    public void getPackages(){
        if(promoId != 'null'){
            packageRecordList = [SELECT id, name, package_name__c, package_name__r.id, package_name__r.name, package_name__r.package_type__c,
                             package_name__r.subscription_period__c, package_name__r.Subscription_Type__c
                             FROM Promotion_Package__c
                             WHERE promotion__c =: promoRecord.id];
        } else {
        //START UD-3471 5/1/2016 Gdelrosario : set packageRecordList = null to trigger the getPromo() method
            /*packageRecordList = [SELECT id, name, package_name__c, package_name__r.id, package_name__r.name, package_name__r.package_type__c, 
                             package_name__r.subscription_period__c, package_name__r.Subscription_Type__c
                             FROM Promotion_Package__c];*/
            packageRecordList = null;                 
        //END UD-3471 5/1/2016 Gdelrosario : set packageRecordList = null to trigger the getPromo() method
        }
    }    

    @remoteAction
    public static string retrieveRelatedPackages(String promotionId, String billingType){        
        packageId_subscriptionCharge = new map<string, decimal>();
        
        list<Promotion_Package__c> promotionPackages = [select Package_Name__c, Package_Name__r.Name, Package_Name__r.Package_Type__c, 
                Package_Name__r.Subscription_Type__c, Package_Name__r.Subscription_Period__c 
                from Promotion_Package__c where Promotion__c = :promotionId and Package_Name__r.Billing_Type__c = :billingType];
        
        
        set<id> packageIds = new set<id>();
        for (Promotion_Package__c tmp : promotionPackages) {
            packageIds.add(tmp.Package_Name__c);
        }
        
        retrievePackageSubscriptionRate(packageIds, billingType);
        
        list<RelatedPackageWrapper> relatedPackages = new list<RelatedPackageWrapper>();
        
        for (Promotion_Package__c tmp : promotionPackages) {
            RelatedPackageWrapper rpw = new RelatedPackageWrapper();
            rpw.packageId = tmp.Package_Name__c;
            rpw.packageName = tmp.Package_Name__r.Name;
            rpw.packageType = tmp.Package_Name__r.Package_Type__c;
            rpw.packageSubscriptionType = tmp.Package_Name__r.Subscription_Type__c;
            rpw.packageSubscriptionPeriod = tmp.Package_Name__r.Subscription_Period__c;
            rpw.packageSubscriptionRate = packageId_subscriptionCharge.get(tmp.Package_Name__c);
            
            relatedPackages.add(rpw);
        }

        return JSON.serialize(relatedPackages);
    }
    
    private static void retrievePackageSubscriptionRate(set<id> packageIds, string billingType) {
        
        packageId_subscriptionCharge = new map<string, decimal>();
        
        // retrieve subscription rate
        map<string, list<string>> packageId_productRatePlanIds = new map<string, list<string>>();
        set<id> productRatePlanIds = new set<id>();
        
        for (Package__c pkg : [select Id, (select Id, Product_Rate_Plan__c from Package_Items__r) from Package__c 
                where Id in :packageIds]) {                            
            list<string> productRatePlanIdsTmp = new list<string>();
            
            // retrieve product plan ids
            for (Package_Item__c tmp : pkg.Package_Items__r) {
                
                if (tmp.Product_Rate_Plan__c != null) {
                    
                    productRatePlanIdsTmp.add(tmp.Product_Rate_Plan__c);
                    productRatePlanIds.add(tmp.Product_Rate_Plan__c);
                }
            }
            // end retrieve product plan ids
            packageId_productRatePlanIds.put(pkg.Id, productRatePlanIdsTmp);
        }
            
        // retrieve product rate plan charge
        map<id, decimal> productRatePlanId_TotalCharges = new map<id, decimal>();
        for (zqu__ProductRatePlanCharge__c tmp : [select zqu__ProductRatePlan__c, sum__c from zqu__ProductRatePlanCharge__c 
                where zqu__ProductRatePlan__c in :productRatePlanIds and zqu__ProductRatePlan__r.BillingType__c = :billingType]) {            
            decimal charges = 0;    
            if (productRatePlanId_TotalCharges.get(tmp.zqu__ProductRatePlan__c) != null) {
                charges = productRatePlanId_TotalCharges.get(tmp.zqu__ProductRatePlan__c);
            }
            if (tmp.sum__c != null) {
                charges += tmp.Sum__c;
                productRatePlanId_TotalCharges.put(tmp.zqu__ProductRatePlan__c, charges);
            }            
        }
        for (string tmp : packageId_productRatePlanIds.keySet()) {            
            decimal charges = 0;
            if (packageId_subscriptionCharge.get(tmp) != null) {
                charges = packageId_subscriptionCharge.get(tmp);
            }
            for (string tmp2 : packageId_productRatePlanIds.get(tmp)) {
                if (productRatePlanId_TotalCharges.get(tmp2) != null) {
                    charges += productRatePlanId_TotalCharges.get(tmp2);
                }
            }            
            packageId_subscriptionCharge.put(tmp, charges.setScale(2));            
        }        
    }
    
    
    public void executeSearch() {
        getPromotions();
        //billingTypeFromPromotion = searchBillingType;
    }       
    
    public PageReference caseView(){
        update existingCase;
        String retUrl = '/' + existingCase.id;
        PageReference pgRef = new PageReference(retUrl);
        pgRef.setRedirect(true);
        
        return pgRef;
    }
    
    public PageReference xsetPromotion(){
        String retUrl = '/apex/StopSubEditPage_Case?id=' + existingCase.id + '&promoId=' + promotionId + '&packageId=' + packageId + '&addOnId=' + addOnId;
        PageReference pgRef = new PageReference(retUrl);
        pgRef.setRedirect(true);
        
        return pgRef;
        
        //return Page.StopSubEditPage_Case;
    }
    
    public PageReference setPackage(){         
        String retUrl = '/apex/StopSubEditPage_Case?id=' + existingCase.id + '&promoId=' + promoRecord.id + '&packageId=' + packageId + '&addOnId=' + addOnId;
        PageReference pgRef = new PageReference(retUrl);
        pgRef.setRedirect(true);
        
        //START: UD-3473 2/3/16 Added by Manolo Valena
        String packRecProductFamily;
        List<Case> cList = new List<Case>();
        
        for(Package__c packRec : [SELECT Id, Product_Family_Current_Package__c FROM Package__c WHERE Id =: packageId LIMIT 1]) {
            packRecProductFamily = packRec.Product_Family_Current_Package__c;
        }
        
        for(Case cRec : [SELECT Id, Offer_Package__c, Offer_Package_Product_Family__c FROM Case WHERE Id =: existingCase.id LIMIT 1]) {
            cRec.Offer_Package_Product_Family__c = packRecProductFamily;
            cList.add(cRec);
        }
        if(cList.size() > 0) {
            Database.update(cList, false); 
        }
        //END: UD-3473 2/3/16 Added by Manolo Valena
        
        return pgRef;
        
        //return Page.StopSubEditPage_Case;
    }
    
    //START: UD-3473 2/3/16 Added by Manolo Valena
    public PageReference setAddOn(){
        if(packageRecord.Id != null) {
            String retUrl = '/apex/StopSubEditPage_Case?id=' + existingCase.id + '&promoId=' + promoRecord.id + '&packageId=' + packageRecord.Id + '&addOnId=' + addOnId;
            PageReference pgRef = new PageReference(retUrl);
            pgRef.setRedirect(true);
            
            return pgRef;
        
        //return Page.StopSubEditPage_Case;
        }
        else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, GlobalVariableClass.ADDON_ERR);
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    //END: UD-3473 2/3/16 Added by Manolo Valena    
    
    public PageReference doCancel(){
        String retUrl = '/apex/StopSubEditPage_Case?id=' + existingCase.id + '&promoid=' + promoRecord.id + '&packageId=' + packageRecord.Id + '&addOnId=' + addOnSelectedRecord.Id;
        PageReference pgRef = new PageReference(retUrl);
        pgRef.setRedirect(true);
        
        return pgRef;
        
        //return Page.StopSubEditPage_Case;
    }
    
    public PageReference cancelEditCase(){
        String retUrl = '/' + existingCase.id;
        PageReference pgRef = new PageReference(retUrl);
        pgRef.setRedirect(true);
        
        //START: UD-3473 2/3/16 Added by Manolo Valena
        List<Case> caseList = new List<Case>();
        
        for(Case caseR : [SELECT Id, Offer_Package_Product_Family__c, Offer_Package__c, Offer_Package__r.Product_Family_Current_Package__c FROM Case WHERE Id =: existingCase.id LIMIT 1]) {
            if(caseR.Offer_Package_Product_Family__c != null && 
               caseR.Offer_Package__c == null) {
                caseR.Offer_Package_Product_Family__c = null;
                caseList.add(caseR);
            }
            else if(caseR.Offer_Package_Product_Family__c != null && 
                    caseR.Offer_Package__c != null) {
                caseR.Offer_Package_Product_Family__c = caseR.Offer_Package__r.Product_Family_Current_Package__c;
                caseList.add(caseR);
            }
        }
        if(caseList.size() > 0) {
            Database.update(caseList, false); 
        }
        //END: UD-3473 2/3/16 Added by Manolo Valena
        
        return pgRef;
    }
    
    public PageReference redirectToOfferPromotion(){
        String retUrl = '/apex/StopSub_SearchPromotion?id=' + existingCase.id + '&promoId=' + promoRecord.id + '&packageId=' + packageRecord.Id + '&addOnId=' + addOnSelectedRecord.Id;
        PageReference pgRef = new PageReference(retUrl);
        pgRef.setRedirect(true);
        
        return pgRef;
        
       // return Page.StopSub_SearchPromotion;
    }   
        
    public PageReference redirectToOfferPackage(){
        String retUrl = '/apex/StopSub_SearchPackage?id=' + existingCase.id + '&promoId=' + promoRecord.id + '&packageId=' + packageRecord.id + '&addOnId=' + addOnSelectedRecord.Id;            
        PageReference pgRef = new PageReference(retUrl);
        pgRef.setRedirect(true);
        
        return pgRef;
        
       // return Page.StopSub_SearchPromotion;
    }
    
    public PageReference redirectToOfferAddOn(){
        String retUrl = '/apex/StopSub_Search_Add_On?id=' + existingCase.id + '&promoId=' + promoRecord.id + '&packageId=' + packageRecord.id + '&addOnId=' + addOnId;            
        PageReference pgRef = new PageReference(retUrl);
        pgRef.setRedirect(true);
        
        return pgRef;
        
       // return Page.StopSub_SearchPromotion;
    }
}