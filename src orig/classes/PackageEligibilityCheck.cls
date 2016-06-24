/*
 * Class Name: PackageEligibilityCheck
 * Developer: EBM
 * Date: 9/25/2014
 * Description: Called by eShop to check the Eligibility of package being subscribed online
 *  History: 1/22/15 D-1684 Christian - Updated to fix the generation of error message.
*/


@RestResource(urlMapping='/PackageEligibilityCheck/*')  
global with sharing class PackageEligibilityCheck {


    private static PackageEligibilityCheckResponse response = new PackageEligibilityCheckResponse();
    
    global class PackageEligibilityCheckResponse {
        public String eligibilityFlg;
        public String svc_status;
        public String error_code;
        public String error_message;
        public String debug = '';
    }
    
    global class PackageEligibilityCheckRequest {
        public String Packageid;           // This is the package code
        public String Promotionid;         // This is the Promotion_Code__c in Promotion Object
        public String Action;              // 
        public String SubscriptionId;      // This is the Salesforce Subscription Id
        public String subscriberid;        // This is the account id field in salesforce Account object
        //START: D-605 1/9/2015 Added by Kristine Campang - added variable
        public String contractperiod;      // Contract Period of promotion
        //END: D-605 1/9/2015 Added by Kristine Campang
        public String vendorConversion;      // START-END : D-2093 2/5/2015 Alyana Navarro
    }
    
    @HttpPost
    global static PackageEligibilityCheckResponse processRequest(PackageEligibilityCheckRequest request) {
        response.svc_status = 'FAILURE';
        // START 03/16/15 D-0605 Kevin Evasco - Added Mandatory Field Validation
        Boolean isValid = true;
        Boolean invalidSubscription = true; // Start/End - UD-1148 05-May-2015 Added by Raviteja
        try
        {
            isValid = checkMandatoryFields(request);
            
            if(isValid) {
                ProcessPackageEligibilityCheck(request);
            } else {
                response.error_code = GlobalVariableClass.ERROR_CODE_MANDATORY;
                response.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_MANDATORY;
            }
            //START UD-1148 05-May-2015 Added by Raviteja - Commented existing assignment
            invalidSubscription = subscriptionValidation(request);
			
			system.debug('JohnD >>>> isValid : ' + isValid + ' :: invalidSubscription : ' + invalidSubscription);
            if(isValid && invalidSubscription == True){
                response.svc_status = 'FAILURE';
                response.eligibilityFlg = 'False';
            }            
            //End UD-1148 05-May-2015 Added by Raviteja 
            // END 03/16/15 D-0605 Kevin Evasco - Added Mandatory Field Validation
            
            //START: D-1684 1/22/2015 Added by Christian Bolima - Add a condition to check the packagecode and promocode is valid
            if ((response.svc_status == 'FAILURE') && (response.error_code == 'EXES0009')){
                response.error_code = 'EXES0009';
                response.error_message = 'Promo package combo not found ';
            }
        
        }catch(Exception e)
        {                    
            response.svc_status = 'FAILURE';
            response.error_code = 'EXGN0000';
            response.error_message = 'Generic Error. ';
            
            if(e.getTypeName().contains('DMLException'))
            {                
                response.error_code = 'EXES0001';
                response.error_message = 'Mandatory validation failed. ';
            }
            else if(e.getTypeName().contains('TypeException'))
            {            
                response.error_code = 'EXES0004';
                response.error_message = 'Invalid input. Backend validation failed. ';
            }
            response.error_message += 'Type: ' + e.getTypeName() + ' ';
            response.error_message += 'Message: ' + e.getMessage() + ' ';
            response.error_message += 'Stack Trace: ' + e.getStackTraceString();
        }       
        return response;
    
    }
    
    private static void ProcessPackageEligibilityCheck(PackageEligibilityCheckRequest request){
        
        Account acc = new Account();
        list<Account> lAcc = new list<Account>();
        //START: D-605 1/9/2015 Added by Kristine Campang -added map for promo eligibility rule
        set<string> sContractperiod = new set<string>();
        Map<String, Set<String>> mapPromoCodeToContract = new Map<String, Set<String>>();
        Map<String, Set<String>> promotionCodeMap = new Map<String, Set<String>>();
        Set<String> sEligPackages = new Set<String>();
        // START : D-2093 2/5/2015 Alyana Navarro
        Boolean vendorConversionValue = false;
        if(request.vendorConversion == 'Y' || request.vendorConversion == 'y')
        {
            vendorConversionValue = true;
        }
        // END : D-2093 2/5/2015
        if(request.subscriberid != '' && request.subscriberid != null){
        //START UD-1302 14-May-2015 Added by Raviteja - Fetching Account from Account Number
            //lAcc = [select id from Account where /*Account_Auto_Number__c*/ Id =: request.subscriberid];
            lAcc = [select id from Account where Account_Auto_Number__c=: request.subscriberid];
         //End UD-1302 14-May-2015 Added by Raviteja 
            if (lAcc.size() > 0){
                acc = lAcc[0];
                sContractperiod.add(request.contractperiod);
                mapPromoCodeToContract.put(request.Promotionid, sContractperiod);
        //END: D-605 1/9/2015 Added by Kristine Campang
                
                map<string, boolean> promotionCode_isEligible = new map<string, boolean>(); 
                //promotionCode_isEligible = PromotionEligibilityRule.getEligibility(acc.Id, 'Add', sPromCodes, request.Packageid, request.SubscriptionId);
                //START: D-605 1/9/2015 Added by Kristine Campang - modified code and added contractperiod to promoeligibility check
                PromoEligibilityRule pRule = new PromoEligibilityRule();
                System.debug('acc.Id:' + acc.Id);
                System.debug('request.Action:' + request.Action);
                System.debug('mapPromoCodeToContract :' + mapPromoCodeToContract);
                System.debug('vendorConversionValue:' + vendorConversionValue);
                System.debug('request.Packageid:' + request.Packageid);
                //START UD-1301 15-May-2015 Added by Raviteja - PromoEligibilityRule will take only Change not 'Can Change'
                Id SubsId;
                String reqAction;               
                if(request.Action == 'CAN CHANGE'){
                    reqAction = 'Change';
                    List<Zuora__Subscription__c> lstsub= [select Id,Zuora__Zuora_Id__c FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c =:request.SubscriptionId];
                    if(lstsub.size() >0){
                    SubsId = lstsub[0].Id;
                    }
                } 
                // UD-1301 15-May-2015 Added by Raviteja - commented existing  getEligibility and updated for can change              
                //promotionCodeMap = pRule.getEligibility(acc.Id, request.Action, mapPromoCodeToContract, null, null, vendorConversionValue); // START-END : D-2093 2/17/2015 Alyana Navarro
                if(request.Action == 'CAN CHANGE'){
                    promotionCodeMap = pRule.getEligibility(acc.Id, reqAction, mapPromoCodeToContract, null, SubsId, vendorConversionValue); 
                }
                 // START UD-1301 20-May-2015 Added by Raviteja - commented existing  getEligibility and updated for can Add   
                //else{
                else if(request.Action == 'CAN ADD'){
                     reqAction = 'Add'; 
                    //promotionCodeMap = pRule.getEligibility(acc.Id, request.Action, mapPromoCodeToContract, null, null, vendorConversionValue); // START-END : D-2093 2/17/2015 Alyana Navarro
                    promotionCodeMap = pRule.getEligibility(acc.Id, reqAction, mapPromoCodeToContract, null, null, vendorConversionValue); // START-END : D-2093 2/17/2015 Alyana Navarro
                    // End UD-1301 20-May-2015 Added by Raviteja                
                }
                // End UD-1301 15-May-2015 Added by Raviteja 
                System.debug('PROMOTION CODE MAP:' + promotionCodeMap);
                
                if(promotionCodeMap != null){
                    response.svc_status = 'SUCCESS';
                    for(String promo : promotionCodeMap.keySet()){
                        System.debug('PROMOMAP:' + promotionCodeMap);
                        sEligPackages = promotionCodeMap.get(promo);
                        System.debug('SET:' + sEligPackages);
                    }
                }
                else{
                    response.svc_status = 'FAILURE';
                }
                System.debug('PACKAGES:' + sEligPackages);
                if(sEligPackages.contains(request.Packageid)){
                    response.eligibilityFlg = 'true';
                }
                else{
                    response.eligibilityFlg = 'false';
                }
                //END: D-605 1/9/2015 Added by Kristine Campang
                System.debug('response.eligibilityFlg :' + response.eligibilityFlg);
            }
                            
        }else{
            //Check eligibility for Prospecting Subscriber
            CheckForNonSubscriber(request);
        }
    }
    
    //START UD-1148 05-May-2015 Added by Raviteja - Created subscriptionValidation method to validate the Subscription
    private static Boolean subscriptionValidation(PackageEligibilityCheckRequest request){
        Boolean isvalidsubscription = true;
        String SubscriptionId = request.SubscriptionId;       
        SubscriptionId =  SubscriptionId.trim();         
        
        //UD-1148 - Request 1: If invalid subscription id is passed API should return error message. 
        List<Zuora__Subscription__c> lstsub = New List<Zuora__Subscription__c>();
        if(SubscriptionId != Null && SubscriptionId != ''){
            lstsub = [Select Id,Zuora__Zuora_Id__c from Zuora__Subscription__c where Zuora__Zuora_Id__c = :SubscriptionId];
        }
        if(lstsub.size() == 0 && (SubscriptionId != Null && SubscriptionId != '' && !String.isBlank(request.SubscriptionId))){    
            response.error_code = 'EXES0004';             
            response.error_message = 'Invalid input';                        
        }
        //UD-1148 - Request 2: According to FDS If Action is "CAN CHANGE" subscription Id should be mandatory. 
        else if(request.Action == 'CAN CHANGE' && (SubscriptionId == Null || SubscriptionId == '' || String.isBlank(request.SubscriptionId))){        
            response.error_code = 'EXES0001';
            response.error_message = 'Mandatory validation faileds';           
        }
        //UD-1148 - Request 3: If we pass invalid action value API should return error message. 
        else if(request.Action != 'CAN CHANGE' && request.Action != 'CAN ADD'){
            System.debug(' request.Action : '+request.Action);
            response.error_code = 'EXES0004';
            response.error_message = 'Invalid input';
        }
        //UD-1148 - Request 4 : When we pass the wrong/different subscription id which is belong to other subscriber account and vice versa. Should return error message. 
        else if(lstsub.size() > 0 && (request.subscriberid != Null && request.subscriberid != '' && !String.isBlank(request.subscriberid))){
            List<Zuora__Subscription__c> lstsubscription = New List<Zuora__Subscription__c>();
            lstsubscription = [Select Id,Zuora__Zuora_Id__c,Zuora__Account__c,Zuora__Account__r.AccountNumber from Zuora__Subscription__c where Zuora__Zuora_Id__c = :SubscriptionId AND Zuora__Account__r.AccountNumber = :request.subscriberid];
            if(lstsubscription.size() == 0){ 
                 response.error_code = 'EXES0004';
                 response.error_message = 'Invalid input';
             }
             else{
             isvalidsubscription = False;
            }
        } 
        //START UD-1225 11-May-2015 Added by Raviteja - Added subscriberid
        else{
            //START UD-1302 14-May-2015 Added by Raviteja - Added SubscriptionId
            // Start PD-0067 08Ma16 JohnD - removed condition. it will not work for existing suscriber
            /*
            if((request.subscriberid == Null || request.subscriberid == '' || String.isBlank(request.subscriberid)) || (request.SubscriptionId == Null || request.SubscriptionId == '' || String.isBlank(request.SubscriptionId))){
              // End UD-1302 14-May-2015 Added by Raviteja   
                isvalidsubscription = False;
            }
            */
            isvalidsubscription = False;
            // EnD PD-0067 08Ma16 JohnD - removed condition. it will not work for existing suscriber
        }
        // End UD-1225 11-May-2015 Added by Raviteja 
        return isvalidsubscription;
       
    }
    //End UD-1148 05-May-2015 Added by Raviteja
    
    private static void CheckForNonSubscriber(PackageEligibilityCheckRequest request){
                
        // Check if package exist in the Promotion
        boolean bFoundPackage = false;
        for(Promotion_Package__c pc: [SELECT Promotion__r.Promotion_Code__c, Promotion__r.Id, Promotion__c, 
                                        Package_Name__r.Package_Code__c, Package_Name__r.Id, Package_Name__c, Id 
                                        FROM Promotion_Package__c
                                        WHERE Promotion__r.Promotion_Code__c =: request.Promotionid]){
            
            if(request.Packageid  == pc.Package_Name__r.Package_Code__c){
                bFoundPackage = true;
                break;
            }           
        }
        
        if(!bFoundPackage){
            response.svc_status = 'FAILURE';
            //START: D-1684 1/22/2015 Added by Christian Bolima - Changed the errro code from EXES0000 to EXES0009 and also the error message
            response.error_code = 'EXES0009'; 
            response.error_message = 'Promo package combo not found';
            //END: D-1684 1/22/2015 Added by Christian Bolima
        }else{
        
            //START 7 September 2015 D-3337 Kevin Evasco - Hotfix. Should be eligible if there are no eligiblity rules at all.
            
            list<Promotion_Eligibility_Rule__c> lPer = new list<Promotion_Eligibility_Rule__c>();
            lPer =  [SELECT Id, Name,
                    Promotion__r.Promotion_Code__c, Promotion__r.Id, 
                    Eligibility_Rule__r.Date__c, Eligibility_Rule__r.Condition__c, 
                    Eligibility_Rule__r.Contract_Subscription_Rule__c, Eligibility_Rule__r.Customer_Status__c 
                    FROM Promotion_Eligibility_Rule__c 
                    WHERE Promotion__r.Promotion_Code__c =: request.Promotionid];
                    
            response.svc_status = 'SUCCESS';         
            response.eligibilityFlg = 'false';
            if(lper.size() == 0) {
                response.eligibilityFlg = 'true';
            } else {
                for(Promotion_Eligibility_Rule__c eligibilityRule : lPer) {
                    if(eligibilityRule.Eligibility_Rule__r.Customer_Status__c == 'New customer')                        
                        response.eligibilityFlg = 'true';
                }
            }
            
            /*
            if (lPer.size()>0){             
                response.eligibilityFlg = 'true';
            }else{              
                response.eligibilityFlg = 'false';
            }
            */
            //END 7 September 2015 D-3337 Kevin Evasco - Hotfix. Should be eligible if there are no eligiblity rules at all.
        }
        
    }
    
    // START 03/16/15 D-0605 Kevin Evasco - Added Mandatory Field Validation
    public static Boolean checkMandatoryFields(PackageEligibilityCheckRequest request)
    {
        Boolean isValid = true;
        
        if(request.contractperiod == null || request.contractperiod == ''){
            isValid = false;
        }
        if(request.Packageid == null || request.Packageid == ''){
            isValid = false;
        }
        if(request.Promotionid == null || request.Promotionid == ''){
            isValid = false;
        }
        if(request.Action == null || request.Action == ''){
            isValid = false;
        }
        
        return isValid;
    }
    // END 03/16/15 D-0605 Kevin Evasco - Added Mandatory Field Validation
    
        
    /* ---------------------------  THIS IS THE REQUEST PARAMETERS

    {
        "request" : 
        {        
            "Packageid" : "HW12FULL",                   
            "Promotionid" : "MAG12PROMO",                   
            "Action" : "CAN ADD",               
            "SubscriptionId" : "",              
            "subscriberid" : "" ,
            "contractperiod" : "12"
        }
    }
    
    Sample Test in Workbench: /services/apexrest/PackageEligibilityCheck/data/v29.0
    --------------------------------------------------------------- */ 
}