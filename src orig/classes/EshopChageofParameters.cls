/* 
 * Class Name: EshopChageofParameters
 * @Author: Krithika Dharmarajan
 * @Date: 17/09/2014
 * @Description: This class is for Change of Subscription details
 * History: 4/15/2015 :Krithika Dharmarajan UD-0948
 */

@RestResource(urlMapping='/EshopChangeofParametersService/*')  
global with sharing class EshopChageofParameters{
public static String accname;


global class ChangeofParametersRequest{

    String nric;
    String passport;
    String homePhone;
    String mobilePhone;
    String officePhone;
    String email;
    String secondarymail;
    String name;
    String salutation;
    String contactID;
    String billingIndicator;
    String recipientIndicator;

}

global class ChangeofParametersResponse{

    ChangeofParametersRequest req;
    ErrorResponseWrapper eRW;

    public ChangeofParametersResponse(ChangeofParametersRequest req,ErrorResponseWrapper eRW){
            this.req= req;
            this.eRW = eRW;

}
}

private static boolean validateMandatoryParameters(ChangeofParametersRequest req){
  
   if(req.nric == null || req.passport == null || req.homePhone == null || req.mobilePhone == null || req.officePhone == null || 
   req.email == null || req.secondarymail == null || req.name == null || req.salutation == null || req.contactID == null ||
   req.billingIndicator == null || req.recipientIndicator == null ){
            return false;
        }
   if(req.nric == '' || req.passport == '' || req.homePhone == '' || req.mobilePhone == '' || req.officePhone == '' || 
   req.email == '' || req.secondarymail == '' || req.name == '' || req.salutation == '' || req.contactID == '' ||
   req.billingIndicator == '' || req.recipientIndicator == ''){
            return false;
        }
    return true;
  }
  
 
@HttpPost
global static ChangeofParametersResponse UpdateCustomerDetails(ChangeofParametersRequest req){

    ErrorResponseWrapper eRW = null;
    String succString = OnlineExceptions.SUCCESS;
    boolean updatestatus;
    boolean updateaccstatus;

    boolean isReqValid = validateMandatoryParameters(req);

    if(isReqValid == false){
            eRW = new ErrorResponseWrapper(OnlineExceptions.FAILURE,'EXES0001',OnlineExceptions.getErrorMessage('EXES0001'));
            return (new ChangeofParametersResponse(req, eRW));
        }
    System.debug('Mandatory fields are present');
    try{  
                if(req.billingIndicator == 'Y' && req.recipientIndicator == 'N')
                {
                   
                   System.debug('the contact to be updated is billing contact');
                   updatestatus = UpdateBillingContact(req);
                   updateaccstatus = UpdateAccount(req);
                }
                else if(req.billingIndicator == 'N' && req.recipientIndicator == 'Y' )
                {
                   
                   System.debug('the contact to be updated is recipient contact');
                   updatestatus = UpdateRecepientContact(req);
                }
                else
                {
                    updatestatus = false;
                }
                
                if(updatestatus == false){
                    eRW = new ErrorResponseWrapper(OnlineExceptions.FAILURE,'EXES0003',OnlineExceptions.getErrorMessage('EXES0003'));
                    return (new ChangeofParametersResponse(req, eRW));   
                        }
         
               if(updateaccstatus == false){
                   eRW = new ErrorResponseWrapper(OnlineExceptions.FAILURE,'EXES0001',OnlineExceptions.getErrorMessage('EXES0001'));
                    return (new ChangeofParametersResponse(req, eRW));   
                         }    
        }
            
    catch(System.QueryException qe){
                eRW = new ErrorResponseWrapper(OnlineExceptions.FAILURE,'EXES0007',OnlineExceptions.getErrorMessage('EXES0007'));
                return (new ChangeofParametersResponse(req, eRW));
        }
 
       eRW = new ErrorResponseWrapper(OnlineExceptions.SUCCESS,OnlineExceptions.SUCCESS,succString);
        return (new ChangeofParametersResponse(req, eRW)); 
}

  public static boolean UpdateAccount(ChangeofParametersRequest req)  {
                List<Account> tempAccntlist = new List<Account>();
                Account tempAccnt;
                boolean updateaccstatus;
                String accountName = accname;
                String queryString2 = 'select Name,NRIC__c,Passport__c,Telephone_Residence__c,Handphone_Number__c,Office_Number__c,Email__c,Email_Secondary__c,Mobile__c from Account where Account_Auto_Number__c =:accountName'; // START-END 4/15/2015 :Raviteja UD-0948 - Added Phone,Mobile__c in SOQL (:Krithika Dharmarajan)
                //D-3912 25/11/2015 START-END  REMOVING PHONE FROM THE SOQL KRITHIKA DHARMARAJAN
                tempAccntlist = Database.query(queryString2);  
                        
               if(tempAccntlist.size() >1 || tempAccntlist.size() == 0 )
                            {
                                return false;
                            }
                            tempAccnt = tempAccntlist.get(0);
                           
                            tempAccnt.NRIC__c = req.nric;
                            tempAccnt.Passport__c = req.passport;
                      //      tempAccnt.Telephone_Residence__c = req.homePhone;// START-END 4/15/2015 :Krithika Dharmarajan UD-0948
                            // tempAccnt.Phone = req.homePhone;// START-END 4/15/2015 :Krithika Dharmarajan UD-0948
                            //D-3912 25/11/2015 START-END REMOVING PHONE FROM THE SOQL KRITHIKA DHARMARAJAN
                      //      tempAccnt.Handphone_Number__c = req.mobilePhone;// START-END 4/15/2015 :Krithika Dharmarajan UD-0948
                            tempAccnt.Mobile__c =req.mobilePhone;// START-END 4/15/2015 :Krithika Dharmarajan UD-0948
                            tempAccnt.Office_Number__c = req.officePhone;
                            tempAccnt.Email__c = req.email;
                            tempAccnt.Email_Secondary__c = req.secondarymail;
                            tempAccnt.Name = req.name;
                       //   tempAccnt.Salutation = salutation;
                            
                            update tempAccnt;
                            return true;
                }

 public static boolean UpdateBillingContact(ChangeofParametersRequest req)  {
 
                        List<Contact> cont = new List<Contact> ();
                        Contact contemp ; 
                        String contactID =  req.contactID;
                        boolean Zcallout;
                        
                        String queryString0 = 'select FirstName,LastName,Account.Account_Auto_Number__c,Billing_Indicator__c,NRIC__c,Passport__c,HomePhone__c,Mobile_Number__c,Office_Number__c,Email__c,Email_Secondary__c,Name,Salutation from Contact where id=:contactID and Billing_Indicator__c = true';
                        cont = Database.query(queryString0);  
                        
                            if(cont.size() > 1 || cont.size() == 0)
                            {
                                return false;
                            }
                            contemp = cont.get(0);
                            
                            accname =  contemp.Account.Account_Auto_Number__c;
                            contemp.NRIC__c = req.nric;
                            contemp.Passport__c = req.passport;
                            contemp.HomePhone__c = req.homePhone;
                            contemp.Mobile_Number__c = req.mobilePhone;
                            contemp.Office_Number__c = req.officePhone;
                            contemp.Email__c = req.email;
                            contemp.Email_Secondary__c = req.secondarymail;
                            contemp.Salutation = req.salutation;
                    //      contemp.Name = name;
                           if(req.name.contains(' '))
                                  {
                            contemp.FirstName = req.name.substring(0,req.name.indexOf(' '));
                            contemp.LastName = req.name.substring(req.name.indexOf(' ')+1);
                                  }
                            update contemp;
                            Zcallout = UpdatetoZuora(req);
                            System.debug('status'+Zcallout);
                            if(Zcallout == false){
                            System.debug('Zuora update failed');
                            return false;
                            }
                            return true;
}
        
 public static boolean UpdateRecepientContact(ChangeofParametersRequest req)  {
 
                            List<Contact> cont = new List<Contact> ();
                            String contactID =  req.contactID;
                            Contact contemp ;
                            boolean Zcallout;                           
                           
                            String queryString1 = 'select FirstName,LastName,NRIC__c,Passport__c,HomePhone__c,Mobile_Number__c,Office_Number__c,Email__c,Email_Secondary__c,Name,Salutation from Contact where id=:contactID and Recipient_Indicator__c = true';
                            cont = Database.query(queryString1);  
                            if(cont.size() > 1 || cont.size() == 0 )
                                {
                                    return false;
                                }
                            contemp = cont.get(0);
                            contemp.NRIC__c = req.nric;
                            contemp.Passport__c = req.passport;
                            contemp.HomePhone__c = req.homePhone;
                            contemp.Mobile_Number__c = req.mobilePhone;
                            contemp.Office_Number__c = req.officePhone;
                            contemp.Email__c = req.email;
                            contemp.Email_Secondary__c = req.secondarymail;
                    //      contemp.Name = name;
                               if(req.name.contains(' '))
                                  {
                            contemp.FirstName = req.name.substring(0,req.name.indexOf(' '));
                            contemp.LastName = req.name.substring(req.name.indexOf(' ')+1);
                                  }
                                 
                            contemp.Salutation = req.salutation;
                       
                            update contemp;
                            return true;
}
public static boolean UpdatetoZuora(ChangeofParametersRequest req)
{                              System.debug('I have entered zuora update class');
                               List<Zuora__CustomerAccount__c> zcustacclist = new List<Zuora__CustomerAccount__c> ();
                             //  Zuora__CustomerAccount__c zcustacctemp; START END 4/15/2015 :Krithika Dharmarajan UD-0948
                               String contactID =  req.contactID;  
                               String FirstName = req.name.substring(0,req.name.indexOf(' '));
                               String LastName = req.name.substring(req.name.indexOf(' ')+1);
                                System.debug('#########');
                               String queryString3 = 'select Zuora__BillToId__c,Zuora__SoldToId__c from Zuora__CustomerAccount__c where Billing_Contact__c =:contactID';
                               zcustacclist = Database.query(queryString3);
                              // if(zcustacclist.size() > 1 || zcustacclist.size() == 0 ) START END 4/15/2015 :Krithika Dharmarajan UD-0948
                                if(zcustacclist.size() == 0 )//START END 4/15/2015 :Krithika Dharmarajan UD-0948
                                {
                                    return false;
                                }
                               // START  4/15/2015 :Krithika Dharmarajan UD-0948
                                for(Zuora__CustomerAccount__c zcustacctemp:zcustacclist)
                                {
                              // zcustacctemp = zcustacclist.get(0);START END 4/15/2015 :Krithika Dharmarajan UD-0948
                               //Z callout to update billing contact START END 4/15/2015 :Krithika Dharmarajan UD-0948
                               System.debug('Z callout to update billing contact'); //START END 4/15/2015 :Krithika Dharmarajan UD-0948
                               UpdateBillingContactName.updateZuoraBillingContact(FirstName,LastName,zcustacctemp.Zuora__BillToId__c);//START END 4/15/2015 :Krithika Dharmarajan UD-0948
                                }
                                // END 4/15/2015 :Krithika Dharmarajan UD-0948
                               //Z callout to update billing contact START END 4/15/2015 :Krithika Dharmarajan UD-0948
                              // System.debug('Z callout to update billing contact'); START END 4/15/2015 :Krithika Dharmarajan UD-0948
                             //  UpdateBillingContactName.updateZuoraBillingContact(FirstName,LastName,zcustacctemp.Zuora__BillToId__c);START END 4/15/2015 :Krithika Dharmarajan UD-0948
                               return true;
                           
                         
}                        
                        
    }
     /* Sample Request Parameter:
     /services/apexrest/EshopChangeofParametersService/v29.0
 { 

"req":
 {
      "nric":"G1314241L",
     "passport": "K324556",
     "homePhone":"88999888",
     "mobilePhone":"54545466",
     "officePhone":"34343435",
     "email":"hhh@gmail.com",
     "secondarymail":"ggg@gmail.com",
     "name":"krithika dharmarajan",
     "salutation":"Ms",
     "contactID":"003N000000I7eUs",
     "billingIndicator":"Y",
     "recipientIndicator":"N"


 }
}
     */