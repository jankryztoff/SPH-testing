/**
 * Class Name: CreditCardFailure_InboundEmailHandler  
 * @author: Jeff Teves
 * Date: 10/21/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description: Class for handling Credit Card Payment Failures in Zuora Class will Parse the Email Received from Zuora and perform the following functions:
 *                  1. Create External Payment Record
 *                  2. Transfer Subscriptions to New/Existing Billing Accoutn with Payment Type: Invoice
 *                  3. Cancel Subscriptions and Generate Invoice to be sent to ARMS
 * @trigger: Email Message will be recieved from Zuora during third failed Credit Card Payment Attempt. EmailMessage body format will be fixed containing field details from Zuora.
 */
 
Global class CreditCardFailure_InboundEmailHandler implements Messaging.inboundEmailHandler{
    
    List<Exception> exceptionList = new List<Exception>();
    final String CREDIT_CARD = 'Credit Card';
    final String PAYPAL = 'PayPal'; //START-END UD-2806 Added by K.Tan/J.Sarion - implement retry failure for Paypal
    final String INVOICE = 'Invoice';
    String ARMSAccountNumber;
    String ARMSCustomerNumber;
    List<Log__c> logList = new List<Log__c>();
    Log__c newLog = new Log__c();

    Global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,  Messaging.InboundEnvelope env ) {
        
        Zuora__CustomerAccount__c billingAcct = new Zuora__CustomerAccount__c();
        Zuora__CustomerAccount__c invoiceBA;
        
        //declare inboundemailresult to be returned by the class
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        //Variables parsed from email
        String accountName;
        String accountNumber;
        String billToContactWorkEmail;
        String billToContactFirstName;
        String billToContactLastName;
        String paymentMethodCardHolderName;
        String paymentMethodCreditCardType;
        String paymentErrorMessage;
        String paymentMethodExpirationDate;
        String paymentAmount;
        String paymentDate;
        String paymentMethodPaymentMethodType;
        String paymentMethodPaypalEmail;
        String paymentMethodPaypalBaid;
        String newZuoraBillingAccountID;

        //Parse Email Body and store to temp variables
        //ASSUMPTION: PlainTextBody is parsed from the Email, not the HtmlEmailBody
        if(email.plainTextBody != null) {
            //START UD-1544 10/06/2015 Added by K.Tan/J.Sarion
            String plainTextBody = email.plainTextBody.replace('&lt;', '<');
            plainTextBody = plainTextBody.replace('&gt;', '>');
            //END UD-1544 10/06/2015 Added by K.Tan/J.Sarion
            
            DOM.Document doc = new DOM.Document();
            try {
                System.debug('plainTextBody: ' + plainTextBody);
                System.debug('Email: ' + email);
                Integer startIndex = plainTextBody.indexOf('<CreditCardDetails>');
                system.debug('>>>>>> 20');
                Integer endIndex = plainTextBody.indexOf('</CreditCardDetails>') + 20;
                system.debug('>>>>>> 21');
                system.debug('>>>>>> startIndex ' + startIndex);
                system.debug('>>>>>> endIndex' + endIndex);
                plainTextBody = plainTextBody.substring(startIndex, endIndex);
                system.debug('>>>>>> 22');
                doc.load(plainTextBody); 
                system.debug('>>>>>> 23');   
                DOM.XMLNode root = doc.getRootElement();
                
                system.debug('>>>>>> 1');
                accountName = root.getChildElement('AccountName', null).getText();
                system.debug('>>>>>> 2');
                accountNumber = root.getChildElement('AccountNumber', null).getText();
                system.debug('>>>>>> 3');
                billToContactWorkEmail = root.getChildElement('BillToContactWorkEmail', null).getText();
                system.debug('>>>>>> 4');
                billToContactFirstName = root.getChildElement('BillToContactFirstName', null).getText();
                system.debug('>>>>>> 5');
                billToContactLastName = root.getChildElement('BillToContactLastName', null).getText();
                system.debug('>>>>>> 6');
                paymentMethodCardHolderName = root.getChildElement('PaymentMethodCardHolderName', null).getText();
                system.debug('>>>>>> 7');
                paymentMethodCreditCardType = root.getChildElement('PaymentMethodCreditCardType', null).getText();
                system.debug('>>>>>> 8');
                paymentErrorMessage = root.getChildElement('PaymentErrorMessage', null).getText();
				//START D-4684 4/19/2016 Added by J.Sarion - Trim error message to 255 characters only
				if(paymentErrorMessage != null) {
					if(paymentErrorMessage.length() > 255) {
						paymentErrorMessage = paymentErrorMessage.substring(0, 255);
					}
				}
				//END D-4684 4/19/2016 Added by J.Sarion - Trim error message to 255 characters only
                system.debug('>>>>>> 9');
                paymentMethodExpirationDate = root.getChildElement('PaymentMethodExpirationDate', null).getText();
                paymentAmount = root.getChildElement('PaymentAmount', null).getText();
                //START UD-1544 10/06/2015 Added by K.Tan/J.Sarion
                paymentAmount = paymentAmount.remove('$');
                paymentAmount = paymentAmount.remove(',');
                //END UD-1544 10/06/2015 Added by K.Tan/J.Sarion
                paymentDate = root.getChildElement('PaymentDate', null).getText();
                system.debug('>>>>>> 12');
                paymentMethodPaymentMethodType = root.getChildElement('PaymentMethodPaymentMethodType', null).getText();
                system.debug('>>>>>> 13');
                paymentMethodPaypalEmail = root.getChildElement('PaymentMethodPaypalEmail', null).getText();
                system.debug('>>>>>> 14');
                paymentMethodPaypalBaid = root.getChildElement('PaymentMethodPaypalBaid', null).getText();
                
                system.debug('>>>>>> accountName ' + accountName);
                system.debug('>>>>>> accountNumber ' + accountNumber );
                system.debug('>>>>>> billToContactWorkEmail ' + billToContactWorkEmail);
                system.debug('>>>>>> ');
                system.debug('>>>>>> ');
                system.debug('>>>>>> ');
                system.debug('>>>>>> ');
                                

            } 
            catch (Exception e) {  // invalid XML
                system.debug('>>>>>> FAILED PARSING');
                exceptionList.add(e);
            }
        
        }
        
        if(accountNumber != null) {
            //billingAcct = [SELECT Id, Zuora__Account__c, Billing_Contact__r.FirstName, Billing_Contact__r.LastName 
            //                FROM Zuora__CustomerAccount__c WHERE Zuora__AccountNumber__c = :accountNumber];
            billingAcct = [SELECT Billing_Contact__r.FirstName, Billing_Contact__r.LastName, Id,
                                                            Zuora__PaymentMethod_Type__c,
                                                            Zuora__External_Id__c, Name, Payment_Mode__c,
                                                            Zuora__Currency__c, Zuora__BillCycleDay__c, Zuora__PaymentTerm__c, 
                                                            Zuora__SoldToId__c, Zuora__BillToId__c, Zuora__Account__c, Zuora__Batch__c,
                                                            Billing_Type__c, Billing_Contact__c, Zuora__Account__r.name, Zuora__Account__r.AccountNumber,
                                                                (SELECT Id, Zuora__CustomerAccount__r.Zuora__PaymentMethod_Type__c, Name, Zuora__CustomerAccount__c, 
                                                                Zuora__CustomerAccount__r.Payment_Mode__c, Subscription_Type_1__c, Zuora__Zuora_Id__c, Order_Line_Item_Number_1__c
                                                                FROM Zuora__Subscriptions__r)
                                                            FROM Zuora__CustomerAccount__c WHERE Zuora__AccountNumber__c = :accountNumber]; //START-END UD-2806 Added by K.Tan/J.Sarion - implement retry failure for Paypal
         }
        
        
        if(billingAcct.Zuora__Account__c != null) {
            List<Zuora__CustomerAccount__c> billingAccounts = [Select Id, Zuora__Zuora_Id__c FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c = :billingAcct.Zuora__Account__c AND Other_PaymentMethod__c = :INVOICE];
            if(!billingAccounts.isEmpty()) {
                invoiceBA = billingAccounts[0];
            }
        }
            
        // START : D-3554, D-3556, and D-3593 9/25/2015 Alyana Navarro
        //No invoice billing Account scenario. THis process will create new invoice billing account
        //if(invoiceBA == null) { //create a billing acct with payment type Invoice
            // Start create New Billing Account
            
            //START D-3236 10-07-2015 Marvin Gatchalian - will use existing logic for creation of ARMS
            /*
            if (!CreateARMSCustomer(billingAcct)) {
                ARMSAccountNumber = null;
                // As discussed once ARMS creation is fail, the whole process will stop and must create entry to Log object
                newLog = new Log__c();
                newLog.Detail__c = 'ARMS Creation';
                newLog.Message__c = 'Customer not created.';
                newLog.Record_ID__c = billingAcct.Id;
                logList.add(newLog);
                result.success = false;
            }
            */
            //END D-3236 10-07-2015 Marvin Gatchalian  - will use existing logic for creation of ARMS
            
            //else {
			//START UD-2549 3/23/2016 Added by J.Sarion - uncommented if condition
            if(billingAcct.Billing_Type__c != GlobalVariableClass.BILLING_TYPE_FULL_PRE){ //START-END UD-1544 10/06/2015 Added by K.Tan/J.Sarion
                External_Payment__c extPayment = instantiateExternalPayment(accountName, accountNumber, billToContactWorkEmail, billToContactFirstName, billToContactLastName,
                                                                        paymentMethodCardHolderName, paymentMethodCreditCardType, paymentErrorMessage, 
                                                                        paymentMethodExpirationDate, paymentAmount, paymentDate, paymentMethodPaymentMethodType, 
                                                                        paymentMethodPaypalEmail, paymentMethodPaypalBaid, billingAcct);
                try {
                    insert extPayment;
                }
                catch(DmlException e) {
                    exceptionList.add(e);
                }
                
                if(!exceptionList.isEmpty()) {
                    ExceptionLogger.log(exceptionList);
                }
                
                result.success = true;
            } //START-END UD-1544 10/06/2015 Added by K.Tan/J.Sarion
			//END UD-2549 3/23/2016 Added by J.Sarion - uncommented if condition
            //}
        //}
        // END : D-3554, D-3556, and D-3593 9/25/2015 Alyana Navarro
        // Return the result for the Apex Email Service
        return result;
    }
    
    
    // Start�D-3920 10/11/2015 D-3920�by Ana Fe Dumangas to comment out unused method
    //Create ARMS
 /*   private boolean CreateARMSCustomer (Zuora__CustomerAccount__c billingAcct) {
        boolean isARMSSucess;
        
        wwwSphComArWsWsdlCam.CreateCustomerAccountRequestType armsCusRec = new wwwSphComArWsWsdlCam.CreateCustomerAccountRequestType();
        armsCusRec.CusAccCre = new wwwSphComArWsSchemaCamCreatecusto.CusAccCre_element();
        armsCusRec.CusAccCre.SysId = ConstantsSLB.getOther('ARMS_SysId');
        armsCusRec.CusAccCre.CusM1 = billingAcct.Zuora__Account__r.name;                   //change to account name
        armsCusRec.CusAccCre.CusSts = ConstantsSLB.getOther('ARMS_CusSts');
        armsCusRec.CusAccCre.Syno = billingAcct.Zuora__Account__r.AccountNumber;           //change to acccount number
        armsCusRec.CusAccCre.UniqId = billingAcct.Zuora__Account__r.AccountNumber;         //change to acccount number
        armsCusRec.CusAccCre.BizP = 'NORM';
        armsCusRec.CusAccCre.AccTyp = ConstantsSLB.getOther('ARMS_AccTyp');
        armsCusRec.CusAccCre.CrLmtInt = ConstantsSLB.getOther('ARMS_CrLmtInt');
        armsCusRec.CusAccCre.CrLmtExt = ConstantsSLB.getOther('ARMS_CrLmtExt');
        armsCusRec.CusAccCre.DbtStrt = 'NORM';
        armsCusRec.CusAccCre.CreId = '005N00000014RHl';
        armsCusRec.CusAccCre.CoyCd = ConstantsSLB.getOther('ARMS_CoyCd');
        armsCusRec.user_x = new wwwSphComArWsSchemaCommonUser.UserType();
        armsCusRec.user_x.userID = ConstantsSLB.getOther('ARMS_userID');
        armsCusRec.user_x.password = ConstantsSLB.getOther('ARMS_password');
        system.debug(armsCusRec);
        
        wwwSphComArWsWsdlCam.CAMSOAP CusCreateCAM = new wwwSphComArWsWsdlCam.CAMSOAP();
        wwwSphComArWsWsdlCam.CreateCustomerAccountResponseType CusCreatedRec = CusCreateCAM.CreateCustomerAccount(armsCusRec);
        system.debug(CusCreatedRec);
        
        if (CusCreatedRec.CusAccCreResp != null) {
            system.debug(CusCreatedRec.CusAccCreResp.AccN);
            system.debug(CusCreatedRec.CusAccCreResp.CusN);
            ARMSAccountNumber = CusCreatedRec.CusAccCreResp.AccN;
            ARMSCustomerNumber = CusCreatedRec.CusAccCreResp.CusN;
            isARMSSucess = true;    
        }
        else {
            isARMSSucess = false;
        }
        
        return isARMSSucess;
       
    } */
    // End 10/11/2015 D-3920�by Ana Fe Dumangas�to comment out unused method
    
    
    //utility method to construct external payment record
    private External_Payment__c instantiateExternalPayment(String accountName, String accountNumber, String billToContactWorkEmail, String billToContactFirstName,
                                                            String billToContactLastName, String paymentMethodCardHolderName, String paymentMethodCreditCardType, 
                                                            String paymentErrorMessage, String paymentMethodExpirationDate, String paymentAmount, String paymentDate, 
                                                            String paymentMethodPaymentMethodType, String paymentMethodPaypalEmail, String paymentMethodPaypalBaid,
                                                            Zuora__CustomerAccount__c billingAcct) {
        
        External_Payment__c extPayment = new External_Payment__c();
        extPayment.Account_Name__c = billingAcct.Zuora__Account__c;
        if(accountNumber != null) {
            try {
                //START D-3465 K. Tan Change from decimal to String 9/7/2015
                extPayment.Account_Number__c = String.valueOf(accountNumber);
                //START D-3465 K. Tan Change from decimal to String 9/7/2015
            }
            catch(Exception e) {
                exceptionList.add(e);
            }
        }
        extPayment.Billing_Account__c = billingAcct.Id;
        if(billToContactWorkEmail != null) {
            extPayment.Billing_Contact_email__c = billToContactWorkEmail;
        }
        extPayment.Billing_Contact_First_Name__c = billingAcct.Billing_Contact__r.FirstName;
        extPayment.Billing_Contact_Last_Name__c = billingAcct.Billing_Contact__r.LastName;
        //extPayment.Sold_To_Contact_Name__c = ??; //Lookup(Contact)
        
        if(paymentMethodCardHolderName != null) {
            extPayment.Card_Holder_Name__c = paymentMethodCardHolderName;
        }
        
        if(paymentMethodCreditCardType != null) {
            extPayment.Card_Type__c = paymentMethodCreditCardType;
        }

        if(paymentErrorMessage != null) {
            extPayment.Error_Message__c = paymentErrorMessage;
        }
        //START D-3465 K. Tan include Credit Card Expiration 9/7/2015
        //START UD-1544 10/14/2015 Added by K.Tan/J.Sarion
        if(paymentMethodExpirationDate != null){
            try {
                list<string> strDate = paymentMethodExpirationDate.split('/');
                Date datex;
                if (strDate.size() == 2) {
                    integer month = integer.valueOf(strDate[0]);
                    integer day = 1;
                    integer year = integer.valueOf(strDate[1]);
                    datex = date.newInstance(year, month, day);
                }
                extPayment.Expiration_Date__c = datex;
            }
            catch (Exception e) {
                exceptionList.add(e);
            }
        
        }
        //END UD-1544 10/14/2015 Added by K.Tan/J.Sarion
        //END D-3465 K. Tan include Credit Card Expiration 9/7/2015
        if(paymentAmount != null) {
            try {
                Decimal amt = Decimal.valueOf(paymentAmount);
                extPayment.Payment_amount__c = amt;
                extPayment.Transaction_Amount__c = amt;
            }
            catch(Exception e) {
                exceptionList.add(e);
            }
        }
        
        //START UD-2806 10/12/2015 Added by K.Tan/J.Sarion - implement retry failure for paypal
        if(billingAcct.Zuora__PaymentMethod_Type__c == 'PayPal'){
            extPayment.Payment_Method__c = PAYPAL;
            extPayment.Payment_Type__c = PAYPAL;
			extPayment.Transaction_Type__c = 'C'; //START-END UD-2806 11/09/2015 Added by J.Sarion - Set transaction type for PayPal: C
        }
        else{
            extPayment.Payment_Method__c = CREDIT_CARD;
            extPayment.Payment_Type__c = CREDIT_CARD;
			extPayment.Transaction_Type__c = 'F'; //START-END UD-2806 11/09/2015 Added by J.Sarion - Set transaction type only for Credit Card: F
        }
        
       
        if(paymentMethodPaypalEmail != null){
          try{
                extPayment.PayPal_Email__c = paymentMethodPaypalEmail;
            }
            catch(Exception e) {
                exceptionList.add(e);
            }  
        }
        if(paymentMethodPaypalBaid != null){
          try{
                extPayment.PayPal_BAID__c = paymentMethodPaypalBaid;
            }
            catch(Exception e) {
                exceptionList.add(e);
            }  
        }
        //END UD-2806 10/12/2015 Added by K.Tan/J.Sarion - implement retry failure for paypal
        //START UD-1544 10/14/2015 Added by K.Tan/J.Sarion
        if(paymentDate != null) {
            try {
                list<string> strDate = paymentDate.split('/');
                Date datex;
                if (strDate.size() == 3) {
                    integer month = integer.valueOf(strDate[0]);
                    integer day = integer.valueOf(strDate[1]);
                    integer year = integer.valueOf(strDate[2]);
                    datex = date.newInstance(year, month, day);
                }
                //Date dt = Date.parse(paymentDate);
                extPayment.Payment_Date__c = datex;
                extPayment.Transaction_Date__c = datex;
            }
            catch (Exception e) {
                exceptionList.add(e);
            }
        }
        //END UD-1544 10/14/2015 Added by K.Tan/J.Sarion
        //START D-3236 12-07-2015 Marvin/JOHN
        //.ARMS_Account_Number__c = ARMSAccountNumber;
        //extPayment.ARMS_Customer_Number__c = ARMSCustomerNumber;
        //extPayment.ARMS_Debt_Management__c = 'SUBH';
        //extPayment.ARMS_Business_Profile__c = 'NORM';
        //extPayment.Bank_Name__c = ARMSAccountNumber + ',' + ARMSCustomerNumber + ',NORM,SUBH';
        //extPayment.Transaction_Type__c = 'F'; //START-END UD-2806 11/09/2015 Added J.Sarion - Commented out. Set transaction type only for Credit Card
        //extPayment.Billing_Type__c = billingAcct.Billing_Type__c;
        extPayment.Sold_To_Contact_Name__c = billingAcct.Billing_Contact__c;
        return extPayment;
        //END  D-3236 12-07-2015 Marvin/JOHN
        
    }
}