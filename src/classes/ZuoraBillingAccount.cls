/**
 * Class Name: CreateBillingAccountInZuora
 * @author: Marvin Gatchalian
 * Date: 07/01/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description: Use this class to create Billing Account, Billing Contact, Account Activation and Ammendment in Zuora
 *                  1. Creattion Billing Account
 *                  2. Creation of Billing Contact
 *                  3. Account Activation
 *                  4. Ammendment
 * 
/* Class Name : ZuoraBillingAccount
* History : include all changes
* Update on : 7/10/15
* Description : UD-1805 Bypass CreditCard. transfer invoice ownership for stop 
* and start charging
*/

 

public class ZuoraBillingAccount {


    Map<String,String> billingAccResultMap = new Map<String,String>();
    Map<String,Object> billingAccMap = new Map<String,Object>();
    
    Map<String,String> billingContactResultMap = new Map<String,String>();
    Map<String,Object> billingContactMap = new Map<String,Object>();
    ZuoraCallOut zCallout = new ZuoraCallOut();
    
    List<Zuora__Subscription__c> SelectedSubscriptions = new List<Zuora__Subscription__c>();
    final String PMTHD_INV_ID = ConstantsSLB.getKeyId('ZuoraPaymentMethod_Other');
    
    
    public Contact contactBilling;

    String BillingContId;
    String BillingAcctId;
        
    Public string CreateBAInZuoraInvoice (Zuora__CustomerAccount__c billingAcct, String ARMSAccountNumber){         // Returns new zuora billing account id
        boolean isBaCreationSucess;
        
                //START UD-3833 2/28/2016 Added by J.Sarion - Check ARMS Invoice details
                List<Zuora__CustomerAccount__c> billAcc = new List<Zuora__CustomerAccount__c>();
                
                if(billingAcct.Zuora__Account__c != null) {
                billAcc = [SELECT Id, Zuora__PaymentTerm__c 
                           FROM Zuora__CustomerAccount__c 
                           WHERE Zuora__Account__c = :billingAcct.Zuora__Account__c AND Other_PaymentMethod__c = 'Invoice' AND Payment_Mode__c = 'Other' LIMIT 1];  
                }
                //END UD-3833 2/28/2016 Added by J.Sarion - Check ARMS Invoice details
        
                billingAccMap.put('BillCycleDay',billingAcct.Zuora__BillCycleDay__c);
                billingAccMap.put('Currency',billingAcct.Zuora__Currency__c );
                billingAccMap.put('Name', billingAcct.Name );
                //START UD-3833 2/28/2016 Added by J.Sarion - Update Payment Term
                if(!billAcc.isEmpty()) {
                    billingAccMap.put('PaymentTerm', billAcc[0].Zuora__PaymentTerm__c );                                
                }
                else {
                    billingAccMap.put('PaymentTerm', 'Net 15');
                }
                //END UD-3833 2/28/2016 Added by J.Sarion - Update Payment Term                              
                billingAccMap.put('Status','Draft');
                //START D-3955 12/8/2015 Added by K. Tan
                billingAccMap.put('Batch', ConstantsSLB.getKeyId('Batch Number'));
                //END D-3955 12/8/2015 Added by K. Tan
                billingAccMap.put('CrmId', billingAcct.Zuora__Account__c );
                billingAccMap.put('DefaultPaymentMethodId', PMTHD_INV_ID);
                billingAccMap.put('Billing_Type__c', billingAcct.Billing_Type__c);
                billingAccMap.put('Other_PaymentMethod__c', 'Invoice');
                //START D-3971 11/23/2015 Added by K. Tan
                billingAccMap.put('Link_Prev_Billing_Contact__c', billingAcct.Billing_Contact__c);
                //END D-3971 11/23/2015 Added by K. Tan                

                //START UD-3171 10/30/2015 Added by K. Tan
               /* billingAccMap.put('ARMS_Debt_Management__c', 'SUBH');
                billingAccMap.put('ARMS_Business_Profile__c', 'NORM');

                if (ARMSAccountNumber != null) {
                    billingAccMap.put('ARMS_Account_Number__c', ARMSAccountNumber);
                }*/
                //END UD-3171 10/30/2015 Added by K. Tan

                billingAccResultMap = zCallout.createZObject (billingAccMap, 'Account');    
                
                
                if (billingAccResultMap.get('Status') == 'Success') {
                    BillingAcctId = (String) billingAccResultMap.get('Id');
                    
                    if (BillingAcctId != null && billingAcct.Billing_Contact__c != null) {
                        isBaCreationSucess  = createContactBilling (BillingAcctId , billingAcct.Billing_Contact__c);
                    }
                    else {
                        system.debug('=====>>>> Account ID is Null or BillingContactID is Null ');
                        system.debug('=====>>>>fail Create Billing acct');
                        isBaCreationSucess = false;
                    }
                    
                    if (BillingAcctId != null) {
                        isBaCreationSucess = activateAccount (billingAcct);
                    }
                     else {
                        system.debug('=====>>>> Account ID is Null, Account Activation not possible ');
                        system.debug('=====>>>>fail Account Activation');
                        isBaCreationSucess = false;
                    }
                           
                }
                else {
                    system.debug('>>>>>>>>>>> Call Out Response Status ' + ' ' + billingAccResultMap.get('Status'));
                    system.debug('=====>>>> fail Create Billing acct');
                    isBaCreationSucess = false;
                }
        if (isBaCreationSucess) {
            return BillingAcctId;
        }
        else {
            return null;
        }             
       
    }
    
    
    public boolean createContactBilling(String billingAccountID, id billingContact){
        boolean isSucess;
        //Start UD-3833 07-Apr-2016 Added By S.Puli - update field mapping
        contactBilling = [SELECT Id, Name, AccountId, MailingCountry, FirstName, 
                                LastName, Email, Mailing_Address__c, City_Code__c, Address__r.Postal_Code__r.Name, 
                                Address__r.City__r.City_Name__c, MailingCity, MailingPostalCode  
                                FROM Contact WHERE Id =:billingContact];


        billingContactMap.put('AccountId', billingAccountID);
        billingContactMap.put('Country',contactBilling.MailingCountry );
        billingContactMap.put('FirstName',contactBilling.FirstName );
        billingContactMap.put('LastName',contactBilling.LastName);                              
        billingContactMap.put('WorkEmail',contactBilling.Email);
        billingContactMap.put('City', contactBilling.MailingCity );
        //billingContactMap.put('Address1', contactBilling.Mailing_Address__c);
        billingContactMap.put('PostalCode', contactBilling.MailingPostalCode);
        //End UD-3833 07-Apr-2016 Added By S.Puli 
                
        billingContactResultMap = zCallout.createZObject (billingContactMap, 'Contact');
        
            try {
                
                if (billingContactResultMap.get('Status') == 'Success') {
                     system.debug('===>>>>success create billing Contact');  
                     BillingContId = (String) billingContactResultMap.get('Id');
                     isSucess = true;
                   
               }
                else {
                    system.debug('>>> Creation of Billing Contact failed status is ' + ' ' + billingContactResultMap.get('Status'));
                    system.debug('=====>>>>fail Create Billing Contact');
                    isSucess = false;
                }
            }
            catch(Exception e){
                system.debug('===CreateContactBilling Error==>>>>' +e);
                isSucess = false;
            }   
        return isSucess;
    }
    
    
    public boolean activateAccount(Zuora__CustomerAccount__c billingAcct){
        
        String StatusBillingAcct;
        boolean isSucess;
        
       
        
        Map<String,String> NewBillingAccResultMap = new Map<String,String>();
        Map<String,Object> newbillingAccMap = new Map<String,Object>();
        
        newbillingAccMap.put('Id', BillingAcctId);
        system.debug('====BillingAcctId==>>' +BillingAcctId);
        newbillingAccMap.put('Status', 'Active');
        newbillingAccMap.put('BillToId', BillingContId);
        newbillingAccMap.put('SoldToId', BillingContId);
        newbillingAccMap.put('CrmId', billingAcct.Zuora__Account__c);
        //START D-3955 12/8/2015 Added by K. Tan
        newbillingAccMap.put('Batch', ConstantsSLB.getKeyId('Batch Number'));
        //END D-3955 12/8/2015 Added by K. Tan
        
        
        NewBillingAccResultMap = zCallout.updateZObject(newbillingAccMap, 'Account', BillingAcctId);
        
        
        if (NewBillingAccResultMap.get('Status') == 'Success') {
            system.debug('===>>>> Account Activated');    
            StatusBillingAcct = NewBillingAccResultMap.get('Status');
            system.debug('====status====>>>' + StatusBillingAcct);
            isSucess = true;
        }
        else {
            system.debug('>>>>>>>>>>>>>>>>> Activation Failed' + ' ' + NewBillingAccResultMap.get('Status'));
            system.debug('>>>>>>>>>>>>>>>>> Error Message ' + ' ' + NewBillingAccResultMap.get('Message'));
            isSucess = false;
        }
        return isSucess;
        
    }
    
    //START AddedBy Francis Benzon : added input param of old BA
    public void createAmendments(List <Zuora__Subscription__c> associatedSubscription, String BillingAcctId, String oldBillingAcctId)  {
    //END AddedBy Francis Benzon : added input param of old BA
    system.debug(':::SUBS  ' + associatedSubscription);
    system.debug(':::NEWBA ' + BillingAcctId);
    system.debug(':::OLDBA ' + oldBillingAcctId);
            // Create Amendment
            List<Map<String,Object>> AmendmentList = new List<Map<String,Object>>();                            
            Map<String,Object> AmendmentMap;
            String startDate;
            startDate = zuora.zUtil.getZuoraDate(date.today());

        
            system.debug('=====Before Loop SelectedSubscription====>>');
            for(Zuora__Subscription__c sub: associatedSubscription)
            {                       
                system.debug('=====Inside Loop SelectedSubscription====>>');
                AmendmentMap = new Map<String, Object>();
                AmendmentMap.put('Code', null);
                AmendmentMap.put(globalvariableclass.CONTRACT_EFFECTIVEDATE, startDate);
                AmendmentMap.put(globalvariableclass.DESCRIPTION, 'Subscription Owner Transfer');
                AmendmentMap.put(globalvariableclass.EFFECTIVE_DATE, startDate);
                AmendmentMap.put(globalvariableclass.NAME, 'Subscription Owner Transfer');
                AmendmentMap.put(globalvariableclass.STATUS, globalvariableclass.COMPLETED);
                AmendmentMap.put(globalvariableclass.SUBSCRIPTION_ID, sub.Zuora__Zuora_Id__c);
                AmendmentMap.put(globalvariableclass.TYPE, 'OwnerTransfer');
                //START AddedBy FrancisBenzon : maintained customer account as old BA to reference back old ba during retransfer of subs
                //START D-3955 12/8/2015 Added by K. Tan
                AmendmentMap.put('DestinationAccountId', BillingAcctId);
                //END D-3955 12/8/2015 Added by K. Tan
                //END AddedBy FrancisBenzon : maintained customer account as old BA to reference back old ba during retransfer of subs
                AmendmentMap.put('DestinationInvoiceOwnerId', BillingAcctId);
                system.debug('=====Amendment====>>' + AmendmentList);
                AmendmentList.add(AmendmentMap);
                system.debug('=====Amendment List====>>' + AmendmentList);
                
            }
            
            List<Map<String,String>> AmendmentResultMap = zCallout.amendZObjects(AmendmentList);

            try {                           
                //system.assertequals(AmendmentResultMap , null);
                for(Map<String, String> rMap: AmendmentResultMap) {
                    if (rMap.get('Status') == 'Success') {
                        system.debug('===>>>>success amend');
                    }
                    else {
                        system.debug('>>>>>>>>>>>>>>>>>rMap1' + ' ' + rMap.get('Status'));
                        system.debug('>>>>>>>>>>>>>>>>>rMap2' + ' ' + rMap.get('Code'));
                        system.debug('>>>>>>>>>>>>>>>>>rMap2' + ' ' + rMap.get('Message'));
                        system.debug('===>>>>fail amend');                                      
                    }
                }
            

            }
            catch(Exception e){
                system.debug('===Amendment Error==>>>>' +e);
            }  

    }
    
    
   

}