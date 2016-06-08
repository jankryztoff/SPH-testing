/*
 * Class Name: EshopFetchSubscriptionDetails
 * @Author: Nitin B Khanna
 * @Date: 04/11/2014
 * @Description: This class is for updating billing account details sent from ARMS
 * History: 06/02/2015 :Krithika D D-2113 Added new fields
 */    
@RestResource(urlMapping='/FetchSubscriptionService/*')                        
global with sharing class EshopFetchSubscriptionDetails {
    
    global class EshopFetchSubscriptionDetailsRequest{
        String subscriberId;
         public String getSubscriberId(){
            return this.subscriberId;
        }
        
        public void setSubscriberId(String subscriberId){
            this.subscriberId = subscriberId;
        }


    }
    
    global class SubscriptionDetails{
        String subscriberId;
        String recipientId; 
        String recipientName;
        String subscriptionId;
        String packageCode;
        String productCode;
        String billingAccount;
        String onlineOrderNumber; 
        Date stopDate; 
        Date startDate; 
        Date contractEndDate;
        String subscriptionStatus; 
        Date createDate;
        String productFamily;
        String subsSubStatus;
        String classification;
        String subClassification;
        String ldapId;
        Decimal noofCopies;//START-END Krithika D D-2113 Added new fields
    }
        
    global class EshopFetchSubscriptionDetailsResponse {
        List<SubscriptionDetails> subDetails = new List<SubscriptionDetails>(); //START-END D-4080 12-14-2015 added by Jason A. for code review
        ErrorResponseWrapper eRW;
        
        public EshopFetchSubscriptionDetailsResponse(List<SubscriptionDetails> subDetails, ErrorResponseWrapper eRW){
            this.subDetails = subDetails;
            this.eRW = eRW;
        }
    }
    
    //START D-4717 22 April 22, 2016 Kevin Evasco - Removed SQL within loop and corrected code structure
    public static List<SubscriptionDetails> fetchSubscriptionDetailsForSubs(EshopFetchSubscriptionDetailsRequest req){
        Set<Id> subIdSet = new Set<Id>();
        Set<Id> recipientConIdSet = new Set<Id>();
        Set<String> prodFamilySet = new Set<String>();
        List<SubscriptionDetails> sDetails = new  List<SubscriptionDetails>();
        List<zqu__ZProduct__c> prodList = new List<zqu__ZProduct__c>();
        List<Zuora__Subscription__c> subscriptions = new List<Zuora__Subscription__c>();
        
        Map<String, Asia1_Subscription__c> asia1SubMap = new Map<String, Asia1_Subscription__c>();
        Map<String, zqu__ZProduct__c> prodMap = new Map<String, zqu__ZProduct__c>();
        
        String subscriberId = req.subscriberId;
        String queryString0 = 'SELECT Zuora__Account__r.Account_Auto_Number__c,Recipient_Contact__c,Recipient_Contact__r.name,';
        queryString0 += ' Zuora__Zuora_Id__c,Main_Package__c,Product_Code__c,Zuora__CustomerAccount__r.Zuora__AccountNumber__c,';
        queryString0 += ' zuora__SubscriptionStartDate__c,Zuora__SubscriptionEndDate__c,Order_Number__c,Zuora__TermEndDate__c,';
        queryString0 += ' Zuora__Status__c,Number_of_Copies__c,Main_Package_1__r.Package_Code__c,Qty__c,Classification__c,Sub_Classification__c,Order_Line_Item_Number_1__r.Contract_End_Date__c'; //start-end KRITHIKA D D-2113 Fields added
        queryString0 += ' FROM Zuora__Subscription__c';
        queryString0 += ' where zuora__Account__r.Account_Auto_Number__c=:subscriberId';
        //Start/End Raviteja 30Mar2016 Added Subscription_Type_1__c filter
        queryString0 += ' and Subscription_Type_1__c =\'Publication\'';
        queryString0 += ' and Zuora__Status__c=\'Active\'';
        queryString0 += ' ORDER BY CreatedDate ASC NULLS FIRST';
        
        subscriptions = Database.query(queryString0);           
        //system.assertequals(subscriptions , null);
        
        if(subscriptions.size()>0){
        
            //Start Raviteja 30Mar2016 - Implemeted the logic of Aisa1subscriptions 
            List<Asia1_Subscription__c> lstasia1sub = New List<Asia1_Subscription__c>();            
            Set<Id> setasia1Ids = New Set<Id>();
            for(Zuora__Subscription__c tempSub : subscriptions){
                subIdSet.add(tempSub.Id);
                recipientConIdSet.add(tempSub.Recipient_Contact__c);
                prodFamilySet.add(tempSub.Product_Code__c);
            }
             
            lstasia1sub = [Select Id, Asia1__c, Asia1__r.User_ID_LDAP_ID__c, Subscription__c, Asia1__r.Contact__c  from Asia1_Subscription__c where Subscription__c IN :subIdSet AND Asia1__r.Contact__c IN :recipientConIdSet AND Asia1__r.Enabled__c = TRUE AND Status__c = 'Enabled'];
            prodList = [select ProductFamily__c, ProductCode__c from zqu__ZProduct__c where ProductCode__c = :prodFamilySet];
              
            for(Asia1_Subscription__c asobj : lstasia1sub){
                setasia1Ids.add(asobj.Asia1__c);
                asia1SubMap.put('' + asobj.Subscription__c + asobj.Asia1__r.Contact__c, asobj);
            }            
            
            for(zqu__ZProduct__c prod : prodList) {
                prodMap.put(prod.ProductCode__c, prod);
            }
            //End Raviteja 30Mar2016 Added Enabled__c 
            
                        
            for(Zuora__Subscription__c tempSub : subscriptions){
                String productCode = tempSub.Product_Code__c;
                zqu__ZProduct__c product = prodMap.get(productCode);
                String productFamily = null;
                if(product != null)
                    productFamily = product.ProductFamily__c;
                
                Asia1_Subscription__c asia1Sub = asia1SubMap.get('' + tempSub.Id + tempSub.Recipient_Contact__c);
                String ldapId = null;
                if(asia1Sub != null)
                    ldapId = asia1Sub.Asia1__r.User_ID_LDAP_ID__c;
            
                SubscriptionDetails subDetail = new SubscriptionDetails();
                
                subDetail.subscriberId = tempSub.Zuora__Account__r.Account_Auto_Number__c;
                subDetail.recipientId = tempSub.Recipient_Contact__c; 
                subDetail.recipientName = tempSub.Recipient_Contact__r.name;
                subDetail.subscriptionId = tempSub.Zuora__Zuora_Id__c;
                subDetail.packageCode = tempSub.Main_Package_1__r.Package_Code__c;//start-end KRITHIKA D D-2113 Fields added
                subDetail.productCode = tempSub.Product_Code__c;
                subDetail.billingAccount = tempSub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c;
                subDetail.onlineOrderNumber = tempSub.Order_Number__c; 
                subDetail.stopDate = tempSub.Zuora__SubscriptionEndDate__c; 
                subDetail.startDate = tempSub.zuora__SubscriptionStartDate__c; 
                subDetail.contractEndDate = tempSub.Order_Line_Item_Number_1__r.Contract_End_Date__c;//start-end KRITHIKA D D-2113 Fields added
                subDetail.subscriptionStatus = tempSub.Zuora__Status__c; 
                subDetail.productFamily = productFamily;
                subDetail.subsSubStatus = '';
                subDetail.classification = tempSub.Classification__c;//start-end KRITHIKA D D-2113 Fields added
                subDetail.subClassification =tempSub.Sub_Classification__c;//start-end KRITHIKA D D-2113 Fields added
                subDetail.ldapId = ldapId;
                subDetail.noofCopies = tempSub.Qty__c;//start-end KRITHIKA D D-2113 Fields added
                sDetails.add(subDetail);
            }
        }
        return sDetails;
    }
    //END D-4717 22 April 22, 2016 Kevin Evasco - Removed SQL within loop and corrected code structure
        
    private static boolean validateMandatoryParameters(EshopFetchSubscriptionDetailsRequest req){
    //    if(req.subscriberId != null){
    //            return true;
      //  }
       // return false;
    //   System.debug('***************************************************jwaelisdhfsdjkj : '+req.subscriberId );
        if(req.subscriberId == null){
            System.debug('***************************************************true : '+req.subscriberId );
            return false;
        }
        if(req.subscriberId == ''){
            System.debug('***************************************************true : '+req.subscriberId );
            return false;
        }
        System.debug('**************************************************false : '+req.subscriberId );
        return true; 
    }

    @HttpPost
    global static EshopFetchSubscriptionDetailsResponse fetchSubscriptionDetails(EshopFetchSubscriptionDetailsRequest req) {
        List<SubscriptionDetails> details = new List<SubscriptionDetails>();
        ErrorResponseWrapper eRW = null;
        
        boolean isReqValid = validateMandatoryParameters(req);
        
        if(isReqValid == false){
            eRW = new ErrorResponseWrapper(OnlineExceptions.FAILURE,'EXES0001',OnlineExceptions.getErrorMessage('EXES0001'));
            return (new EshopFetchSubscriptionDetailsResponse(details, eRW));
        }
        
        details = fetchSubscriptionDetailsForSubs(req);  
              
        Integer noOfDetails =  details.size();
        
        if(noOfDetails == 0){
            eRW = new ErrorResponseWrapper(OnlineExceptions.SUCCESS,'EXES0007',OnlineExceptions.getErrorMessage('EXES0007'));
        }else if(noOfDetails > 0){
            eRW = new ErrorResponseWrapper(OnlineExceptions.SUCCESS,OnlineExceptions.SUCCESS,OnlineExceptions.SUCCESS);
        }
        
        return (new EshopFetchSubscriptionDetailsResponse(details, eRW));
    }
    
}