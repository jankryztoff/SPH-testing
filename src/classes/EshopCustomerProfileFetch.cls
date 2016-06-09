/*
 * Class Name: EshopCustomerProfileFetch
 * @Author: Nitin B Khanna
 * @Date: 17/09/2014
 * @Description: This class is for Eshop Service:Fetch customer profile/address/contact/debt management details
 * History: 19/01/2015 :Krithika D D-1573 added new string to store the status,
 * History: 27/01/2015 : Krithika D D-1573 Retest failed corrections
 * History: 02/05/2015 :Joban: D - 2033 modified the error code. 
 * History: 02/24/2015 : Krithika.D modified and updated D-2193 KRITHIKA D 2/17/2015
 */    
@RestResource(urlMapping='/CustomerProfileFetchService/*')                        
global with sharing class EshopCustomerProfileFetch {
    
    global class EshopCustomerProfileFetchRequest{
        String subscriberId;
        
        public String getSubscriberId(){
            return this.subscriberId;
        }
        
        public void setSubscriberId(String subscriberId){
            this.subscriberId = subscriberId;
        }
    }
    
    global class AccountDetails{
        String account_type;
        //String salutation;
        String full_name;
        String ic_no;
        String passport_no;
        String email;
        String home_contact_number;
        String mobile_contact_number;
        String others_contact_number;
        String designation;
        Date dob;
        String eshop_ref_no;
        String staff_id; //START/END: D-1091 Modified by FrancisBenzon corrected assignment String to String
        String status;//START/END : 19/01/2015 Krithika.D D-1573 As required by  FDS 
        String source='';//START/END : 19/01/2015 Krithika.D D-1573 As required by  FDS
        String black_listed='';//START/END : 19/01/2015 Krithika.D D-1573 As required by  FDS
        String staff_perm_partimer='PARTIMER';//START/END: 27/01/2015  Krithika.D D-1573 Retest Failed 
        
        public AccountDetails(String subsId){
            fetchAccountDetails(subsId);
        }
        
        public void fetchAccountDetails(String subsId){
            boolean statusbool;//START/END: 27/01/2015 Krithika.D D-1573 Retest Failed  
            String queryString0 = 'select recordType.name, Name, NRIC__c, Passport__c, Email__c, Telephone_Residence__c, Mobile__c, Street_Name__c, Building_Name__c, ';
            queryString0 += 'Phone, Designation__c, Date_of_Birth__c, active__c, Eshop_Ref_No__c, singpost_address__r.Address_Type__c, ';
            queryString0 += 'Staff_ID__c,Sub_Group__c ';//27/01/2014 Retest Krithika.D D-1573 As required by  FDS added sub_group
			queryString0 += ' , Office_Number__c '; // Start/End - UD-0948 04-May-2015 Added by Raviteja
            queryString0 += 'from Account where Account_Auto_Number__c = :subsId';

            Account accTemp = Database.query(queryString0);   
             
            account_type = accTemp.recordType.name;
            full_name = accTemp.Name;
            ic_no = accTemp.NRIC__c; 
            passport_no = accTemp.Passport__c; 
            email = accTemp.Email__c;             
			//START UD-0948 21-Apr-2015 Added by Raviteja - Commented existing assignment
            home_contact_number = accTemp.Phone; 
            //End UD-0948 21-Apr-2015 Added by Raviteja
            mobile_contact_number = accTemp.Mobile__c;
			//START UD-0948 04-May-2015 Added by Raviteja - Commented existing assignment
            //others_contact_number = accTemp.Phone;
			others_contact_number = accTemp.Office_Number__c;
            //End UD-0948 04-May-2015 Added by Raviteja
            designation = accTemp.Designation__c;
            dob = accTemp.Date_of_Birth__c; 
            statusbool = accTemp.active__c; //START/END: 27/01/2015 Krithika.D D-1573 Retest Failed  
            /*Krithika 20/01/2015 Krithika D Start: D--1573 As required by FDS*/
            if(accTemp.Active__c == true){
            status='ACTIVE';
            }
            else{
            status='INACTIVE';
            }    
            /* 20/01/2015 Krithika D Start: D--1573 As required by FDS*/   
            eshop_ref_no = accTemp.Eshop_Ref_No__c; 
      
            STAFF_ID = accTemp.Staff_ID__c; 
            /*20/01/2015 Krithika D Start: D--1573 As required by FDS*/
            List<ESHOPSettings__c> templist;
            templist=[select source__c from ESHOPSettings__c];
            for(ESHOPSettings__c tempsettings : templist)
            {
            source = tempsettings.source__c;
            }
            /*20/01/2015 Krithika D Start: D--1573 As required by FDS*/   
            /*27/1/2015 Krithika D Start Retest Fail STAFF_PERM_PARTIMER */
            if(account_type.equals('Direct SPH Inter-Division'))
            {
                if(accTemp.Sub_Group__c.equals('SPH BOD') || accTemp.Sub_Group__c.equals('SPH Senior Staff') || accTemp.Sub_Group__c.equals('SPH Retiree') || accTemp.Sub_Group__c.equals('SPH Staff'))
                    {
                    staff_perm_partimer = 'STAFF';
                    }
            }
            /*27/1/2015 Krithika D End Retest Fail STAFF_PERM_PARTIMER */
        }
    }
    
    global class ContactDetails{
        String contact_name;
        String contactId; //salesforce id
        String address_id;
        String addr_type;
        String postal_code;
        String blk_no;
        String level_no;
        String street_name;
        String bld_name;
        String unit_no;
        String location_code;
        String unformatted_addr;// field missing in object addr1+2+3+4
        String country;
        boolean billingIndicator;
        boolean recipientIndicator;
        String ldapId;//20/01/2015 Krithika.D D-1573 As required by  FDS
        String address_group;//27/01/2015 Krithika.D D-1573 As required by FDS
        String salutation; // Start/End - UD-0948 04-May-2015 Added by Raviteja
        // D-3912 25/11/2015   START FETCHING PHONE DETAILS FOR BILLING ACCOUNT KRITHIKA DHARMARAJAN
        String home_contact_number;
        String mobile_contact_number;
        String office_contact_number;
        // D-3912 25/11/2015   END FETCHING PHONE DETAILS FOR BILLING ACCOUNT KRITHIKA DHARMARAJAN
    }
    
    public static List<ContactDetails> fetchContactDetails(String subsId, Boolean reciepientIndicator){
            List<ContactDetails> cDetails = new  List<ContactDetails>();
            
            String queryString0 = '';
            
            queryString0 = 'select name, Address__c,Billing_Indicator__c,Recipient_Indicator__c ';
            queryString0 += ' , salutation '; // Start/End - UD-0948 04-May-2015 Added by Raviteja
           // D-3912 25/11/2015 START-END MOVING FROM CONTACT INSIDE IF ELSE CONDITION KRITHIKA DHARMARAJAN
                
            if(reciepientIndicator == true){
                queryString0 += ' ,Office_Number__c,Mobile_Number__c,HomePhone__c from contact '; // D-3912 25/11/2015 START-END MOVING FROM CONTACT INSIDE IF ELSE CONDITION KRITHIKA DHARMARAJAN // D-4168 22/12/2015 START-END ADDED CONTACT FIELDS KRITHIKA DHARMARAJAN HOTFIX
                queryString0 += ' where account.Account_Auto_Number__c = :subsId and recipient_indicator__c = true';
            }else if(reciepientIndicator == false){
                queryString0 += ' ,Office_Number__c,Mobile_Number__c,HomePhone__c from contact ';// D-3912 25/11/2015 START-END MOVING FROM CONTACT INSIDE IF ELSE CONDITION KRITHIKA DHARMARAJAN
                queryString0 += ' where account.Account_Auto_Number__c = :subsId and billing_indicator__c = true';
            }
            
            System.debug('##############################################################');
            System.debug('recIndicator : ' + reciepientIndicator);
            
            List<Contact> contacts = Database.query(queryString0);
            System.debug('contact list size : '+contacts.size());
            List<Asia1_Subscription__c> asiaOneSubsList;//20/1/2015 Krithika.D D-1573 Ldap Id is required
            //START Hot Fixing 10-Jun-2015 Added by Raviteja - Implemented the workaround for Too many SOQL queries: 101 issue
            Set<Id> Contactidset =  new Set<Id>();
             for(Contact temp : contacts){
             Contactidset.add(temp.id);
             }
            asiaOneSubsList = [select Subscription__r.Contact__c,Asia1__r.User_ID_LDAP_ID__c from Asia1_Subscription__c where Subscription__r.Contact__c IN :Contactidset ];
            Map<Id, String> asiaOneMap = new Map<Id, String>();
            for(Asia1_Subscription__c temp:asiaOneSubsList)
            {
            asiaOneMap.put(temp.Subscription__r.Contact__c,temp.Asia1__r.User_ID_LDAP_ID__c);
            }
             //End Hot Fixing 10-Jun-2015 Added by Raviteja
            for(Contact temp : contacts){                
                ContactDetails cD = new ContactDetails();
                cD.contact_name = temp.name;
                cD.salutation = temp.salutation; // Start/End - UD-0948 04-May-2015 Added by Raviteja
                String addId = temp.Address__c;
                cD.address_id = temp.Address__c;
                cD.contactId = temp.id;
                cD.billingIndicator = temp.Billing_Indicator__c;
                /*20/1/2015 Krithika.D Start : D-1573 Ldap Id is required*/
                cD.recipientIndicator = temp.Recipient_Indicator__c;
                //D-3912 START  25/11/2015 FETCHING PHONE DETAILS  krithika D
		// D-4168 22/12/2015 START ADDED CONTACT FIELDS KRITHIKA DHARMARAJAN HOTFIX
                if((cD.billingIndicator == true)){
                //22/12/2015 KRITHIKA DHARMARAJAN HOTFIX
                //D-4125 17/12/2015 HOTFIX CHANGES TO INCLUDE VALIDATION OF CONTACT
                // D-4168 22/12/2015 END ADDED CONTACT FIELDS KRITHIKA DHARMARAJAN HOTFIX
                    cD.office_contact_number = temp.Office_Number__c;
                    cD.mobile_contact_number = temp.Mobile_Number__c;
                    cD.home_contact_number= temp.HomePhone__c;
                }
                 //D-3912 END  25/11/2015 FETCHING PHONE DETAILS  krithika D
                //START Hot Fixing 10-Jun-2015 Added by Raviteja - Implemented the workaround for Too many SOQL queries: 101 issue
               /*asiaOneSubsList = [ select Asia1__r.User_ID_LDAP_ID__c from Asia1_Subscription__c where Subscription__r.Contact__c =:temp.id];//20/01/2015 D-1573 Krithika.D D-1573 As required by  FDS
                    for(Asia1_Subscription__c tempasiaOneSubsList : asiaOneSubsList )
                    {
                    cD.ldapId = tempasiaOneSubsList.Asia1__r.User_ID_LDAP_ID__c;                  
                }*/
				cD.ldapId = asiaOneMap.get(temp.id);
				//End Hot Fixing 10-Jun-2015 Added by Raviteja
                 /*20/1/2015 Krithika.D End : D-1573 Ldap Id is required*/
                queryString0 = 'select recordType.name,Postal_Code__r.Address_Type__c,Address_Unique_Id__c,Postal_Code__r.name, Block_House_Number__c, Level_Number__c, Street_Name__c, ';
                queryString0 += ' Address_1__c, Address_2__c, Address_3__c, Address_4__c, ';
                queryString0 += 'Unit_Number__c, Location_Code__r.location_code__c, Full_Address__c,Country_Name__c, Building_Name__c from address__c where id = :addId';
                   //27/1/2015 Krithika.D D-1573 added recordType.name for Address group is requirement
                Address__c addr = Database.query(queryString0);
                System.debug('afetr address fetch');
                if(addr != null){
                    cD.addr_type = addr.Postal_Code__r.Address_Type__c;
                    cD.address_id = addr.Address_Unique_Id__c;
                    cD.postal_code = addr.Postal_Code__r.name;
                    cD.blk_no = addr.Block_House_Number__c;
                    cD.level_no = addr.Level_Number__c;
                    cD.street_name = addr.Street_Name__c;
                    cD.bld_name = addr.Building_Name__c;
                    cD.unit_no = addr.Unit_Number__c;
                    cD.location_code = addr.Location_Code__r.location_code__c;
                    cD.unformatted_addr = addr.Full_Address__c;
                    cD.country = addr.Country_Name__c;
                    cD.address_group = addr.recordType.name; //27/1/2015 Krithika.D D-1573 added recordType.name for Address group is requirement
                    String unfAdd = '';
                    unfAdd += (addr.Address_1__c != null ? addr.Address_1__c + ' ' : '');
                    unfAdd += (addr.Address_2__c != null ? addr.Address_2__c + ' ' : '');
                    unfAdd += (addr.Address_3__c != null ? addr.Address_3__c + ' ' : '');
                    unfAdd += (addr.Address_4__c != null ? addr.Address_4__c + ' ' : '');
                    cD.unformatted_addr = unfAdd;
                    System.debug('address pouplated');
                }
                cDetails.add(cD);
            }
            return cDetails;
    }
        
    global class BillingAccountDetails{
        String billing_acc_no;
        Decimal acc_level_outstanding;
        String billing_contact;
        String payment_method;
        String payment_type;//same as payment method
        String payment_mode;
        String cc_number;
        String cc_card_type;
        String cc_expiry_date;
        String debt_management_status;
		String billing_account_type; // Start/End - D-3159 24-June-2015 Added by Raviteja - Adding billing_account_type in Response
        ContactDetails cDetails;
    }   
    
    public static List<BillingAccountDetails> fetchBillingAccountDetails(String subsId){
            List<BillingAccountDetails> bDetails = new  List<BillingAccountDetails>();
            List<ContactDetails> contacts = fetchContactDetails(subsId, false);
            String active = 'Active';
			 //START Hot Fixing 10-Jun-2015 Added by Raviteja - Implemented the workaround for Too many SOQL queries: 101 issue
            List<String> lst_conId = New List<String>();
            for(ContactDetails con : contacts){
                if(con.contactId != Null){
                    lst_conId.add(con.contactId);
                }
            }            
            String queryString1 = ' select Zuora__AccountNumber__c, ARMS_Total_Outstanding_Amount__c, Billing_Contact__c, Zuora__PaymentMethod_Type__c,Zuora__DefaultPaymentMethod__c, ';
                queryString1 += ' Payment_Mode__c, Zuora__CreditCardType__c,Zuora__CreditCard_Number__c,Zuora__CreditCard_Expiration__c,ARMS_Debt_Management__c,Other_PaymentMethod__c ';
                queryString1 += ' , Billing_Type__c ';  // Start/End - D-3159 24-June-2015 Added by Raviteja - Adding Billing_Type__c in SOQL
                queryString1 += ' from Zuora__CustomerAccount__c ';
                queryString1 += ' where Billing_Contact__c IN :lst_conId and Zuora__Status__c=:Active';            
           List<Zuora__CustomerAccount__c> lst_CustomerAccount = Database.query(queryString1);  
           Map<String, List<Zuora__CustomerAccount__c>> map_concusAcc = New Map<String, List<Zuora__CustomerAccount__c>>();
            for(Zuora__CustomerAccount__c objCA: lst_CustomerAccount){                
                if(map_concusAcc.get(objCA.Billing_Contact__c) == NULL)
                    map_concusAcc.put(objCA.Billing_Contact__c,new List<Zuora__CustomerAccount__c>());
                map_concusAcc.get(objCA.Billing_Contact__c).add(objCA);                      
            }            
            //End Hot Fixing 10-Jun-2015 Added by Raviteja
            for(ContactDetails temp : contacts){
                String cId = temp.contactId;
                /*19/01/2015 Krithika.D D-1573 Start :Changed Staus__c to Zuora_c */
                //START D-2354 KRITHIKA D 2/26/2015
                 //START Hot Fixing 10-Jun-2015 Added by Raviteja - Commented the Database.query(queryString0) to avoid Too many SOQL queries: 101 and implemented the workaround
                /*
                String queryString0 = ' select Zuora__AccountNumber__c, ARMS_Total_Outstanding_Amount__c, Billing_Contact__c, Zuora__PaymentMethod_Type__c,Zuora__DefaultPaymentMethod__c, ';
                queryString0 += ' Payment_Mode__c, Zuora__CreditCardType__c,Zuora__CreditCard_Number__c,Zuora__CreditCard_Expiration__c,ARMS_Debt_Management__c,Other_PaymentMethod__c ';
                queryString0 += ' from Zuora__CustomerAccount__c ';
                queryString0 += ' where Billing_Contact__c = :cId and Zuora__Status__c=:Active'; 
                //START D-2354 KRITHIKA D 2/26/2015 */
                /*19/01/2015 Krithika.D D-1573 Ends :Changed Staus__c to Zuora_c */
                //List<Zuora__CustomerAccount__c> bC = Database.query(queryString0);            
                
                List<Zuora__CustomerAccount__c> bC = New List<Zuora__CustomerAccount__c>();                
                bc =  map_concusAcc.get(cId);                             
                //End Hot Fixing 10-Jun-2015 Added by Raviteja
				
				 // Start/End - Hot Fixing 10-Jun-2015 Added by Raviteja - Added If condition to avoid the Null Ponter Exception. 
				if(bc != Null){       
                for(Zuora__CustomerAccount__c ZCAc : bC){
                    BillingAccountDetails bAD = new BillingAccountDetails();
                
                    bAD.billing_acc_no = ZCAc.Zuora__AccountNumber__c;
                    bAD.acc_level_outstanding = ZCAc.ARMS_Total_Outstanding_Amount__c;
					bAD.billing_account_type = ZCAc.Billing_Type__c; // Start/End - D-3159 24-June-2015 Added by Raviteja - Assiging value into billing_account_type in Response
                    bAD.billing_contact = ZCAc.Billing_Contact__c;
                    //START D-2193 KRITHIKA D 2/17/2015
                    bAD.payment_mode = ZCAc.Zuora__DefaultPaymentMethod__c;
                    bAD.payment_method = ZCAc.Zuora__DefaultPaymentMethod__c;
                    bAD.payment_type = ZCAc.Zuora__DefaultPaymentMethod__c;//same as payment method
                    if(ZCAc.Zuora__DefaultPaymentMethod__c ==  GlobalVariableClass.PAYMENT_MODE_OTHER)
                    {
                    bAD.payment_method = ZCAc.Other_PaymentMethod__c;
                    bAD.payment_type = ZCAc.Other_PaymentMethod__c;//same as payment method
                    }
                    //END D-2193 KRITHIKA D 2/17/2015
                    bAD.cc_number = ZCAc.Zuora__CreditCard_Number__c;
                    bAD.cc_card_type = ZCAc.Zuora__CreditCardType__c;
                    bAD.cc_expiry_date = ZCAc.Zuora__CreditCard_Expiration__c;
                    bAD.debt_management_status = ZCAc.ARMS_Debt_Management__c;
                    bAD.cDetails = temp;
                    
                    bDetails.add(bAD);
                }
               } 
            }
            return bDetails;
    }
    
    global class EshopCustomerProfileFetchResponse {
      /*19/01/2015 Krithika.D D-1573 Account Number to be included in Request*/
        EshopCustomerProfileFetchRequest req;
        AccountDetails accDetails;
        List<BillingAccountDetails> billAccDetails = new List<BillingAccountDetails>(); //START-END D-4080 12-14-2015 added by Jason A. for code review
        List<ContactDetails> contactDetails = new List<ContactDetails>(); //START-END D-4080 12-14-2015 added by Jason A. for code review
        ErrorResponseWrapper eRW;    
        public EshopCustomerProfileFetchResponse(EshopCustomerProfileFetchRequest req,AccountDetails accDetails, List<BillingAccountDetails> billAccDetails, 
                                                            List<ContactDetails> contactDetails, ErrorResponseWrapper eRW){
            this.req=req;
            this.accDetails = accDetails;
            this.billAccDetails = billAccDetails;
            this.contactDetails = contactDetails;
            this.eRW = eRW;
      /*19/01/2015 Krithika.D D-1573 Account Number to be included in Request*/
        }
    }
    
    private static boolean validateMandatoryParameters(EshopCustomerProfileFetchRequest req){
        if(req.subscriberId == null){
            return false;
        }
        if(req.subscriberId == ''){
            return false;
        }
        return true;
    }

    @HttpPost
    global static EshopCustomerProfileFetchResponse FetchCustomerDetails(EshopCustomerProfileFetchRequest req) {
        ErrorResponseWrapper eRW = null;
        AccountDetails aDetails = null;
        String succString = OnlineExceptions.SUCCESS;
        
        List<ContactDetails> cDetails = new List<ContactDetails>();
        List<BillingAccountDetails> bDetails = new List<BillingAccountDetails>();
        
        boolean isReqValid = validateMandatoryParameters(req);
        
        if(isReqValid == false){
            eRW = new ErrorResponseWrapper(OnlineExceptions.FAILURE,'EXES0001',OnlineExceptions.getErrorMessage('EXES0001'));
            return (new EshopCustomerProfileFetchResponse(req,aDetails,bDetails,cDetails, eRW));
        }
        
        try{
            aDetails = new AccountDetails(req.subscriberId);
        }catch(System.QueryException qe){
            eRW = new ErrorResponseWrapper(OnlineExceptions.FAILURE,'EXES0003',OnlineExceptions.getErrorMessage('EXES0003'));  //  02/05/2015 Joban: D - 2033 modified the error code. 
            return (new EshopCustomerProfileFetchResponse(req,null,null,null, eRW));
        }
        
        try{
            cDetails = fetchContactDetails(req.subscriberId, true);
        }catch(System.QueryException qe){
            succString += ' ;Contact details do not exist';
        }
        
        try{
            bDetails = fetchBillingAccountDetails(req.subscriberId);
        }catch(System.QueryException qe){
            succString += ' ;billing contact details do not exist';
        }
        
        eRW = new ErrorResponseWrapper(OnlineExceptions.SUCCESS,OnlineExceptions.SUCCESS,succString);
        return (new EshopCustomerProfileFetchResponse(req,aDetails,bDetails,cDetails, eRW));
    }
    
}