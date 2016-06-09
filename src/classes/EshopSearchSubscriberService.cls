/*
 * Class Name: EshopSearchSubscriberService
 * @Author: Nitin B Khanna
 * @Date: 17/09/2014
 * @Description: This class is for Eshop Service:Search Subscriber
 * History: 19/01/2015 :Krithika D D-1569 added new string to store the status
 * History: 28/01/2015 :Krithika D D-1569 Retest Failed modifications added
 * History: 28/01/2015 :Joban D-1525 Changed the error code.
 * History: 4/15/2015 :Krithika Dharmarajan UD-0923 UD-0924 UD-0925 UD-0942  
 */
@RestResource(urlMapping='/SearchSubscriberService/*')                        
global with sharing class EshopSearchSubscriberService {
    
    global class SubscriberDetails {
        String subscriberId;
        String status;//19/01/2015 :Krithika D D-1569 Added parameter for status // 28/01/2015 Krithika.D D-1569 Retest failed Changed isActive to status
        String subscriberType;
        String subscriberSubGroup;
        
        public SubscriberDetails(){
            this.subscriberId = '';
            this.status = ''; //19/01/2015 :Krithika D D-1569 Addeed parameter for status
            this.subscriberType = '';
            this.subscriberSubGroup = '';
        }
        
        public SubscriberDetails(String subscriberId, String status, String subscriberType, String subscriberSubGroup){ //19/01/2015 :Krithika D D-1569 Addeed parameter for status
            this.subscriberId = subscriberId;
            this.status = status;//UD-0978 KRITHIKA D 4/27/2015 START END
            this.subscriberType = subscriberType;
            this.subscriberSubGroup = subscriberSubGroup;
        }
    }
    
    global class SearchSubscriberServiceResponse {
        SearchSubscriberServiceRequest req;
        List<SubscriberDetails> subsDetailsArray = new List<SubscriberDetails> (); //START-END D-4080 12-14-2015 added by Jason A. for code review
        ErrorResponseWrapper errResp;
        
        public SearchSubscriberServiceResponse (SearchSubscriberServiceRequest req, List<SubscriberDetails> subsDetailsList, ErrorResponseWrapper errResp){
            this.req = req;
            this.subsDetailsArray = subsDetailsList;
            this.errResp = errResp;
        }
    }
    
    global class SearchSubscriberServiceRequest {
        public String icNo;
        public String passportNo;
        public String email;
        public String legacyAccNo;
        public String contactNo;
        public String status;
        public String subscriberType;
        public String ldapId;
        public String eshopRefNo;
        public String addrType;
        public String postalCode;
        public String blockNo;
        public String levelNo;
        public String streetName;
        public String bldName;
        public String unitNo;
        public String country;
        public String recipientInd;
        public String billingInd;
        public String subGroup;
       
    }
    //START-END 28/01/2015 Krithika.D Removed getters and setters
    private static boolean validateMandatoryParameters(SearchSubscriberServiceRequest req){
        if ((req.email != '') || (req.ldapId != '') || ( (req.blockNo != '') && (req.postalCode != '') && ((req.billingInd != 'N')  ||(req.recipientInd != 'N')))){
                return true;
        }
        return false;
    }
    //4/15/2015 :Krithika Dharmarajan UD-0923 UD-0924 UD-0925 UD-0942
    private static void validateNullreqparams(SearchSubscriberServiceRequest req){
        req.icNo=(req.icNo == null ? '' : req.icNo);
        req.passportNo=(req.passportNo == null ? '' : req.passportNo);
        req.email=(req.email == null ? '' : req.email);
        req.legacyAccNo=(req.legacyAccNo == null ? '' : req.legacyAccNo);
        req.contactNo=(req.contactNo == null ? '' : req.contactNo);
        req.status=(req.status == null ? '' : req.status);
        req.subscriberType=(req.subscriberType == null ? '' : req.subscriberType);
        req.ldapId=(req.ldapId == null ? '' : req.ldapId);
        req.eshopRefNo=(req.eshopRefNo == null ? '' : req.eshopRefNo);
        req.addrType=(req.addrType == null ? '' : req.addrType);
        req.postalCode=(req.postalCode == null ? '' : req.postalCode);
        req.blockNo=(req.blockNo == null ? '' : req.blockNo);
        req.levelNo=(req.levelNo == null ? '' : req.levelNo);
        req.streetName=(req.streetName == null ? '' : req.streetName);
        req.bldName=(req.bldName == null ? '' : req.bldName);
        req.unitNo=(req.unitNo == null ? '' : req.unitNo);
        req.country=(req.country == null ? '' : req.country);
        req.recipientInd=(req.recipientInd == null ? '' : req.recipientInd);
        req.billingInd=(req.billingInd == null ? '' : req.billingInd);
        req.subGroup=(req.subGroup == null ? '' : req.subGroup);
    }
    //4/15/2015 :Krithika Dharmarajan UD-0923 UD-0924 UD-0925 UD-0942
    
    @HttpPost
    global static SearchSubscriberServiceResponse searchSubscriber(SearchSubscriberServiceRequest req) {
        List<Account> accounts = new List<Account>();
        List<SubscriberDetails> details = new List<SubscriberDetails>();
        SearchSubscriberServiceResponse resp = null;
        ErrorResponseWrapper eRW = null;
        validateNullreqparams(req);//4/15/2015 :Krithika Dharmarajan UD-0923 UD-0924 UD-0925 UD-0942
        boolean isReqValid = validateMandatoryParameters(req);
        
        if(isReqValid == false){
            eRW = new ErrorResponseWrapper(OnlineExceptions.FAILURE,'EXES0001',OnlineExceptions.getErrorMessage('EXES0001'));
            return (new SearchSubscriberServiceResponse(req, details, eRW));
        }
        
        String queryString0 = '';
        String queryStringAcc = 'select Account_Auto_Number__c, Status__c, Sub_Group__c, recordType.name from account where ';//KRITHIKA DHARMARAJAN UD-0978 4/27/2015 START-END
        
        
        String email = req.email;
        String postalCode = req.postalCode;
        String blockNo = req.blockNo;
        String streetName = req.streetName;
        String levelNo = req.levelNo;
        String unitNo = req.unitNo;
        String bldName = req.bldName;
        String country = req.country;
        String passportNo = req.passportNo;
        String icNo = req.icNo;
        String contactNo = req.contactNo;
        String ldapId = req.ldapId;
        String eshopRefNo = req.eshopRefNo;
        String status = req.status;//KRITHIKA DHARMARAJAN UD-0978 4/27/2015 START-END
        String subGroup = req.subGroup;
        String subscriberType = req.subscriberType;
        
        queryString0 += ( req.eshopRefNo != ''     ? ' Eshop_Ref_No__c = :eshopRefNo and ' : '');
        queryString0 += ( req.status != ''         ? ' Status__c = :status and ' : '');//KRITHIKA DHARMARAJAN UD-0978 4/27/2015 START-END
        queryString0 += ( req.subGroup != ''       ? ' Sub_Group__c = :subGroup and ' : '');
        queryString0 += ( req.email != ''          ? ' Email__c = :email and ' : '');
        queryString0 += ( req.contactNo != ''      ? '(Phone = :contactNo or Mobile__c = :contactNo  or Handphone_Number__c =:contactNo or Office_Number__c =:contactNo) and ': ''); //Added previously as required by SPH Requirement
        queryString0 += ( req.passportNo != ''     ? ' Passport__c = :passportNo and ': '');
        queryString0 += ( req.icNo != ''           ? ' NRIC__c = :icNo and ': '');
        queryString0 += ( req.subscriberType != '' ? ' recordType.name = :subscriberType and ': '');
      

        if(queryString0 != ''){
            if(queryString0.substring(queryString0.length()-5, queryString0.length()) == ' and '){
                queryString0 = queryString0.substring(0,queryString0.length()-5);
                System.debug(queryString0);
            }
        }
        
        String queryString1 = '';
        String queryStringCont = 'select accountid from Contact where';
        
      
        queryString1 += ( req.billingInd == 'Y'  ? ' Billing_Indicator__c = true and ': '');
        queryString1 += ( req.recipientInd == 'Y'? ' Recipient_Indicator__c = true and ': '');
        queryString1 += ( req.postalCode != ''   ? ' Address__r.Postal_Code__r.name = :postalCode and ': ''); 
        queryString1 += ( req.blockNo != ''      ? ' Address__r.Block_House_Number__c = :blockNo and ': '');
        queryString1 += ( req.levelNo != ''      ? ' Address__r.Level_Number__c = :levelNo and ': ''); 
        queryString1 += ( req.streetName != ''     ? ' Address__r.Street_Name__c = :streetName and ': ''); 
        queryString1 += ( req.unitNo != ''       ? ' Address__r.Unit_Number__c = :unitNo and ': ''); 
        queryString1 += ( req.bldName != ''      ? ' Address__r.Building_Name__c = :bldName and ': '');
        queryString1 += ( req.country != ''      ? ' Address__r.Country__r.Code__c = :country and ': '');
       
        List<Asia1_Subscription__c> a1List = new List<Asia1_Subscription__c>();//1/19/2015  Krithika D :   D-1569 List to hold contact details
        List<Contact> cList = new List<Contact>();
        String temp = '(';
        /* 1/19/2015  Krithika D : Start  D-1569 Cahnging the SOQL for ldapID */
        if(req.ldapId != ''){
           a1List = [select Subscription__r.Contact__c from Asia1_Subscription__c  where Asia1__r.User_ID_LDAP_ID__c = :req.ldapId and Subscription__r.Contact__c!='' and Subscription__r.Contact__c != null];
       
           Integer i = a1List.size();
         if(a1List.size() == 0)
         {
          queryString1 += '';
          System.debug('List of ldap id is null');
          }
           if(i!=0){
            for(Asia1_Subscription__c t : a1List){
                if( i > 1 ){
                   temp += '\''+t.Subscription__r.Contact__c+'\',';
                   i--;
               }else if( i == 1 ){
                   temp += '\''+t.Subscription__r.Contact__c+'\'';
              }
              
           }
           temp += ')';//26/1/2014 Krithika D-1569 Retest
            /* 1/19/2015  Krithika D : End  D-1569 Changing the SOQL for ldapID */
           queryString1 += ' id in '+temp+' and ';
            }
        }
        
        if(queryString1 != ''){
            if(queryString1.substring(queryString1.length()-5, queryString1.length()) == ' and '){
                queryString1 = queryString1.substring(0,queryString1.length()-5);
                System.debug(queryString1);
            }
        }
        System.debug(queryString1);
        
        if(queryString0 != '' && queryString1 == ''){
            queryStringAcc += queryString0;
        }else if(queryString0 == '' && queryString1 != ''){
            queryStringAcc += ' id in ( ' + queryStringCont + queryString1 + ')';
        }else if(queryString0 != '' && queryString1 != ''){
            queryStringAcc += queryString0 + ' and id in ( ' + queryStringCont + queryString1 + ')';
        }else if(queryString0 == '' && queryString1 == ''){
            eRW = new ErrorResponseWrapper(OnlineExceptions.SUCCESS,'EXES0007',OnlineExceptions.getErrorMessage('EXES0007'));//Exception number changed as per requirement
            return (new SearchSubscriberServiceResponse(req, details, eRW));
        }
        
    //KRITHIKA DHARMARAJAN REMOVED ACTIVE STATUS VARIABLE AND OTHER LINES UD-0978 4/27/2015
        accounts = Database.query(queryStringAcc);
        for(Account accTemp : accounts){ 
    //KRITHIKA DHARMARAJAN REMOVED ACTIVE STATUS VARIABLE AND OTHER LINES UD-0978 4/27/2015       
            details.add(new SubscriberDetails(accTemp.Account_Auto_Number__c,accTemp.status__c,accTemp.recordType.name ,accTemp.Sub_Group__c));//KRITHIKA DHARMARAJAN UD-0978
        }
        
        Integer noOfAccounts =  details.size();

        if(noOfAccounts == 0){
            //28/01/2015 :Joban D-1525 Changed the error code to EXES0003 - Start
            eRW = new ErrorResponseWrapper(OnlineExceptions.SUCCESS,'EXES0003',OnlineExceptions.getErrorMessage('EXES0003'));
            //28/01/2015 :Joban D-1525 Changed the error code to EXES0003 - End
        }else if(noOfAccounts <= 10){
            eRW = new ErrorResponseWrapper(OnlineExceptions.SUCCESS,OnlineExceptions.SUCCESS,OnlineExceptions.SUCCESS);
        }else if(noOfAccounts > 10){
            eRW = new ErrorResponseWrapper(OnlineExceptions.FAILURE,'EXES0006',OnlineExceptions.getErrorMessage('EXES0006') + ' ' + noOfAccounts);
        }
        
        return (new SearchSubscriberServiceResponse(req, details, eRW));
    }
    
}