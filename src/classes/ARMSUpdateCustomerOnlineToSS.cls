/*
 * Class Name: ARMSUpdateCustomerOnlineToSS
 * @Author: Krithika Dharmarajan
 * @Date: 04/11/2014
 * @Description: This class is for updating billing account details sent from ARMS
 * History: 06/02/2015 :Krithika D D-1651 changed List initialization
 */    
 global class ARMSUpdateCustomerOnlineToSS
{
    public static String accNo;
    public static String billingAccNo;
    public static List<Zuora__CustomerAccount__c> bAcc = new List<Zuora__CustomerAccount__c>();
    public static Zuora__CustomerAccount__c baccTemp;
    public static String AttentionToCareOfSalutation = 'MR';
    public static Date TomoDate = system.today().addDays(1) ;
    public static DateTime Dt = TomoDate;
    public static String effectiveDate = Dt.format('MM/dd/yyyy');
   // public static String effectiveDate = myDateformat;
    
     global class ErrorResponseWrapper {
         webService String svc_status;
         webService String error_code;
         webService String error_message;
        
          public ErrorResponseWrapper (String svc_status, String error_code, String error_message){
            this.svc_status = svc_status;
            this.error_code = error_code;
            this.error_message = error_message;
                 }
    }
    
     global class ARMSUpdateCustomerOnlineRequest{   
     
       webService String systemID { get; set; }
       webService String customerNumber;
       webService String referenceKey;
       webService String uniqueKey;
       webService String customerName1;
       webService String customerName2;
       webService Date   customerCreateDate;
       webService String status;
       webService String blacklistIndicator;
       webService String blacklistColourCode;
       webService String blacklistReason;
       webService String idType;   
       webService String idNo;
       webService String passportCountryCode;
       webService Integer creditRiskRating;
       webService Integer creditLimitInternal;
       webService Integer creditLimitExternal;
       webService String block;
       webService String floorNo;
       webService String unitNo;
       webService String street;
       webService String building;
       webService String address1;
       webService String address2;
       webService String address3;
       webService String address4;
       webService String postalCode;
       webService String city;
       webService String country;
       webService String  poBoxNo;
       webService String careofAttentiontoParty;
       webService String careofAttentiontoIndicator;
       webService String businessProfile;
       webService String sphStaffIndicator;
       webService String updateID;
       webService Date updateDate;
       webService DateTime updateTime;
       webService String gstOutOfScopeIndicator;
        
    }
    
    global class ARMSUpdateCustomerOnlineResponse{
         webService ErrorResponseWrapper eRW;
         webService ARMSUpdateCustomerOnlineRequest req;

         public ARMSUpdateCustomerOnlineResponse(ARMSUpdateCustomerOnlineRequest req,ErrorResponseWrapper eRW)
         {
         this.eRW = eRW;
         this.req = req;
         }
    }
    
    private static boolean validateMandatoryParameters(ARMSUpdateCustomerOnlineRequest req){
        if((req.systemID == null) ||(req.customerNumber == null ) || (req.ReferenceKey == null) || (req.UniqueKey == null) || (req.CustomerName1== null)){
            return false;
        }
        if((req.systemID == '') ||(req.customerNumber == '' ) || (req.ReferenceKey == '') || (req.UniqueKey == '') || (req.CustomerName1 == '')){
            return false;
        }
        return true;
    }     
             
    webService static ARMSUpdateCustomerOnlineResponse updateDetails(ARMSUpdateCustomerOnlineRequest req){
            
            System.debug('I have entered soap webservice');
            ErrorResponseWrapper eRW = null;       
            String succString = '';     
            
            boolean isReqValid = validateMandatoryParameters(req);
            System.debug('validate mandatory result is'+isReqValid);
            
            if(isReqValid == false){
            System.debug('validate mandatory failed');
            eRW = new ErrorResponseWrapper(OnlineExceptions.FAILURE,'EXARMS0001',OnlineExceptions.getErrorMessage('EXARMS0001'));
            return (new ARMSUpdateCustomerOnlineResponse(req,eRW));
             }
             
             
             //All the static fields are checked
            if(req.systemID != 'SS')
            {
            System.debug('static field validation failed');
            eRW = new ErrorResponseWrapper(OnlineExceptions.FAILURE,'EXARMS0002',OnlineExceptions.getErrorMessage('EXARMS0002'));
            return (new ARMSUpdateCustomerOnlineResponse(req,eRW));
            }
            System.debug('all static fields are valid');
             
             //Billing Account details are checked
             try{  
                           
                succString = fetchBillingAccountDetails(req);
                //succString += updateBillingContactaddressDetails(req);//START-END 4/13/2015 KRITHIKA D D-2730
                System.debug('the message from billing function'+succString);
                }
            catch(System.QueryException qe){
                    eRW = new ErrorResponseWrapper(OnlineExceptions.FAILURE,'EXARMS0003',OnlineExceptions.getErrorMessage('EXARMS0003'));
                    return (new ARMSUpdateCustomerOnlineResponse(req,eRW));
                }
                
             if(succString.containsIgnoreCase('FAILURE')){
             eRW = new ErrorResponseWrapper(OnlineExceptions.FAILURE,'EXEARMS0003',succString);
             }
             else{
             eRW = new ErrorResponseWrapper(OnlineExceptions.SUCCESS,OnlineExceptions.SUCCESS,succString);
             }
        return (new ARMSUpdateCustomerOnlineResponse(req,eRW));
    }  
        
            
    public static String fetchBillingAccountDetails(ARMSUpdateCustomerOnlineToSS.ARMSUpdateCustomerOnlineRequest  req){               
                
                String updatestatus = '';
                String customerno = req.customerNumber;
                String refkey = req.referenceKey;
		//D-3552  START  KRITHIKA DHARMARAJAN 5/11/2015
                String queryString0 = 'select Zuora__Zuora_Id__c,Zuora__Account__r.Account_Auto_Number__c,ARMS_Customer_Number__c,Zuora__AccountNumber__c,ARMS_Account_Number__c,Zuora__BillToId__c,Billing_Contact__r.Address__r.Address_1__c,Billing_Contact__r.Address__r.Address_2__c,';
                queryString0 += 'Billing_Contact__r.Address__r.Address_3__c,Billing_Contact__r.Address__r.Address_4__c,Billing_Contact__r.Address__r.Block_House_Number__c,';
                queryString0 += 'Billing_Contact__r.Address__r.Building_Name__c,Billing_Contact__r.Address__r.City__c,Billing_Contact__r.Address__r.Country_Name__c,Billing_Contact__r.Address__r.Level_Number__c,';
                queryString0 +=  'Billing_Contact__r.Address__r.Postal_Code__r.Name,Credit_Limit_Internal__c,Credit_Limit_External__c,Billing_Account_Name_2__c,Billing_Contact__r.Address__r.Street_Name__c,';
                queryString0 +=  'ARMS_Business_Profile__c,Billing_Contact__r.Address__r.Unit_Number__c,Attention_To_Care_Of_Indicator__c,Attention_To_Care_Of_Name__c,Attention_To_Care_Of_Salutation__c,Billing_Contact__r.Address__r.Country__r.Code__c,Billing_Contact__r.NRIC__c,'; //KRITHIKA DHARMARAJAN UD-1635 Removed ARMS_DEBT_MANAGEMENT Name,Credit_Term__c,Billing_Contact__c, FIELD
                queryString0 +=  'Billing_Contact__r.Passport__c,ARMS_ID__c,Status__c,Update_Date__c,Update_ID__c,Update_Time__c from Zuora__CustomerAccount__c where ARMS_Customer_Number__c =:customerno and Zuora__Account__r.Account_Auto_Number__c  =:refkey';
       //D-3552   END  KRITHIKA DHARMARAJAN 5/11/2015
                bAcc = Database.query(queryString0);
               //4/13/2015 START ARMS Duplicate ID build D-2730 
                for(Zuora__CustomerAccount__c baccListValue : bAcc)
                {
                baccTemp = baccListValue;
               //4/13/2015 END  ARMS Duplicate ID build D-2730
                //4/13/2015 START ARMS Duplicate ID build D-2730
              //if(bAcc.size() > 1)
              //   {
              //  System.debug('list contains more than one record return false and exit the function');
              //  updatestatus = 'Failure';
              //  return updatestatus;
              //  }
                
              //  System.debug('list contains only one record and processing it');
              //  baccTemp = bAcc.get(0);
              //  System.debug('Done with query will crosscheck address and other paraameters');
               //4/13/2015 END  ARMS Duplicate ID build D-2730 
                accNo = baccTemp.Zuora__Account__r.Account_Auto_Number__c;
                System.debug('&&&&&&& Accnt Number is' +accNo);
                billingAccNo = baccTemp.Zuora__AccountNumber__c; //4/13/2015 END  ARMS Duplicate ID build D-2730
                String ConactId = baccTemp.Billing_Contact__c;
                System.debug('$$$$$$$$$$$$'+ConactId);
                
                
         
                String name = req.customerName1+' '+req.customername2;
               // UpdateBillingContactName.updateZuoraBillingContact(req.customerName1.substring(0,req.customerName1.indexOf(' ')),req.customername1.substring(req.customername1.indexOf(' ')+1),baccTemp.Zuora__BillToId__c);    //KRITHIKA DHARMARAJAN START-END 7/23/2015 HOTFIX UD-1635
                UpdateBillingAccountName.updateZuoraBillingAccount(name,baccTemp.Zuora__Zuora_Id__c);
                
                baccTemp.Credit_Limit_Internal__c = (req.creditLimitInternal != null ? req.creditLimitInternal : baccTemp.Credit_Limit_Internal__c);
                baccTemp.Credit_Limit_External__c = (req.creditLimitExternal != null ? req.creditLimitExternal : baccTemp.Credit_Limit_External__c);
               //  baccTemp.Name = (req.customerName1 != null ? req.customerName1 : baccTemp.Name);
               // baccTemp.Billing_Account_Name_2__c = (req.CustomerName2 != null ? req.CustomerName2 : baccTemp.Billing_Account_Name_2__c);
                baccTemp.ARMS_Business_Profile__c = (req.businessProfile!= null ? req.businessProfile : baccTemp.ARMS_Business_Profile__c);
              //  baccTemp.Attention_To_Care_Of_Indicator__c = (req.careofAttentiontoIndicator!= null ? req.careofAttentiontoIndicator : baccTemp.Attention_To_Care_Of_Indicator__c); 
            //    baccTemp.Attention_To_Care_Of_Name__c = (req.careofAttentiontoParty!= null ? req.careofAttentiontoParty : baccTemp.Attention_To_Care_Of_Name__c); 
             //   baccTemp.Attention_To_Care_Of_Salutation__c =(AttentionToCareOfSalutation!= null ? AttentionToCareOfSalutation: baccTemp.Attention_To_Care_Of_Salutation__c); 
                baccTemp.Status__c = (req.status!= null ? req.status : baccTemp.Status__c);
                baccTemp.Update_Date__c = (req.updateDate!= null ? req.updateDate: baccTemp.Update_Date__c);
                baccTemp.Update_ID__c = (req.updateID!= null ? req.updateID: baccTemp.Update_ID__c);
                baccTemp.Update_Time__c = (req.updateTime!= null ? req.updateTime: baccTemp.Update_Time__c);
                
                
                String queryString2 = 'select NRIC__c,Passport__c from Contact where id =:ConactId';
                List<Contact> conttempList = new List<Contact>();
                Contact conttemp;
                
                conttempList = Database.query(queryString2);
                if(conttempList.size() > 1 || conttempList.size() == 0)
                {
                System.debug('list contains more than one record return false and exit the function');
                updatestatus = 'Failure';
                return updatestatus;
                }
                
                System.debug('list contains only one record and processing it');
                conttemp = conttempList.get(0);
                
                     if(req.idType != null ) //KRITHIKA DHARMARAJAN START-END 7/23/2015 HOTFIX UD-1635
                     {  //KRITHIKA DHARMARAJAN START-END 7/23/2015 HOTFIX UD-1635
                     if(req.idType.containsIgnoreCase('PASS'))
                     {
                      System.debug('idType is passport');
                      conttemp.Passport__c = req.idNo;
                    }
                     if(req.idType.containsIgnoreCase('NRIC'))
                    {
                     System.debug('idType is NRIC');
                     conttemp.NRIC__c = req.idNo;
                     }    
                  update conttemp;
                  }  //KRITHIKA DHARMARAJAN START-END 7/23/2015 HOTFIX UD-1635
                  ARMS_TriggerHandler.isSkipUpdate = true; //KRITHIKA 2730 4/29/2015
                  update baccTemp;
                  //4/13/2015 START ARMS Duplicate ID build D-2730 
                  //KRITHIKA DHARMARAJAN START-END 7/23/2015 HOTFIX UD-1635
                 if(checkCOA(req)) {  //KRITHIKA DHARMARAJAN START-END 7/23/2015 HOTFIX UD-1635
                 updatestatus = updateBillingContactaddressDetails(req);
                 }
                 else
                 {
                 updatestatus = ' Address Change not Requested ';
                 } //KRITHIKA DHARMARAJAN START-END 7/23/2015 HOTFIX UD-1635
                  }
                  //4/13/2015 END  ARMS Duplicate ID build D-2730
                  updatestatus += ' UpdATE Parameter SUCCESS '; //KRITHIKA DHARMARAJAN D-2730 5/4/2015
                  System.debug('&&&&&&&&&&&&&&&&&&&&'+updatestatus);
                  return updatestatus;
 }
                  
    public static String updateBillingContactaddressDetails(ARMSUpdateCustomerOnlineRequest req) {
            
            String updatestatus = '';  
            system.debug('outside if');      //D-3552  START-END  KRITHIKA DHARMARAJAN 5/11/2015
            if(baccTemp.Billing_Contact__r.Address__r.Address_1__c != req.address1 || baccTemp.Billing_Contact__r.Address__r.Address_2__c != req.address2 || baccTemp.Billing_Contact__r.Address__r.Address_3__c != req.address3 ||
                baccTemp.Billing_Contact__r.Address__r.Address_4__c != req.address4 || baccTemp.Billing_Contact__r.Address__r.Block_House_Number__c != req.block || 
                baccTemp.Billing_Contact__r.Address__r.Building_Name__c != req.building || baccTemp.Billing_Contact__r.Address__r.City__c != req.city  || 
                baccTemp.Billing_Contact__r.Address__r.Country__r.Code__c != req.country || baccTemp.Billing_Contact__r.Address__r.Level_Number__c != req.floorNo ||
                baccTemp.Billing_Contact__r.Address__r.Postal_Code__r.Name != req.postalCode || baccTemp.Billing_Contact__r.Address__r.Street_Name__c != req.street || baccTemp.Billing_Contact__r.Address__r.Unit_Number__c !=  req.unitNo)//D-3552  START-END  KRITHIKA DHARMARAJAN 5/11/2015
                {
                    system.debug('inside if'); //D-3552   START-END KRITHIKA DHARMARAJAN 5/11/2015
                    System.debug('address details not matching have to be updated');
                    ChangeAddressService.ChangeAddressServiceRequest coareq = new ChangeAddressService.ChangeAddressServiceRequest();
                    ChangeAddressService.ChangeAddressServiceResponse coaresp = new ChangeAddressService.ChangeAddressServiceResponse();   
                    coareq.setAddress1(req.address1);
                    coareq.setAddress2(req.address2);
                    coareq.setAddress3(req.address3);
                    coareq.setAddress4(req.address4);
                    System.debug('@@@@@@@@@@@@'+billingAccNo);
                    coareq.setBillingAccountNumber(billingAccNo);
                    coareq.setBillingIndicator('Y');
                    coareq.setBlockNumber(req.block );
                    coareq.setBuildingName(req.building);
		    //D-3552 START   KRITHIKA DHARMARAJAN 5/11/2015
                    if(req.Country == 'SG')
                    {
                    coareq.setCountry('Singapore');
                    }
		    //D-3552  END  KRITHIKA DHARMARAJAN 5/11/2015
                    coareq.setCustomerAccountNumber(accNo);
                    coareq.setDeliveryIndicator('N');
                    coareq.setEffectiveDate(effectiveDate);
                    coareq.setLevelNumber(req.floorNo);
                    coareq.setPostalCode(req.postalCode);
                    coareq.setStreetName(req.street);
                    coareq.setUnitNumber(req.unitNo);
                    List<String> subs = new List<String>(); // START-END D-1651 Changed the list from null to new empty list
                    coareq.setSubscriptions(subs);
                    coaresp = ChangeAddressService.processRequest(coareq);
                    System.debug(' svc status of change of address  ' +coaresp.getSvc_status());
                    System.debug('  error of change of address  ' +coaresp.getError_code());
                    System.debug('   orderID change of address  ' +coaresp.getOrderid());
                    System.debug('   debug of change of address  ' +coaresp.getDebug());
                    updatestatus = ' COA :'+coaresp.getSvc_status() +coaresp.getError_message();
                    System.debug('  final update status  ' +updatestatus);
                }
            return updatestatus;
            }
     //UD-1635 KRITHIKA 7//28/2015 START
    private static  boolean checkCOA(ARMSUpdateCustomerOnlineRequest req)
    {
      if(  req.block != null &&
                 req.country != null && req.floorNo != null &&
                req.postalCode != null &&  req.street != null && req.unitNo != null)
                {
              //  if(req.address1 != null && req.address2 != null && req.address3 != null &&
              //   req.address4 != null )
                return true;
                }
                return false;
    }
//UD-1635 KRITHIKA 7//28/2015 END                    
}