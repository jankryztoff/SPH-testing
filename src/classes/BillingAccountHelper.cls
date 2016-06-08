//START UD-0810 04-14-2015 Marvin Gatchalian - modified majority of codes... 

public class BillingAccountHelper { 
    
    /*
    *   @description : This method will update the billing account in both zuora and sfdc after
    *           the creation of subscription in sfdc
    *   @param : set of order id
    */
    public static void updateBillingAccountPaymenInfo(set<id> orderIdSet) {
        //START UD-1214 GdelRosario/Ledesma : added map for varibale use
        map<id, order__c> billingIdToAccountOnly = new map<Id, order__c>();
        map<id, Zuora__CustomerAccount__c> IdToBillingAccount = new map<id, Zuora__CustomerAccount__c>();
        //END UD-1214 GdelRosario/Ledesma : added map for varibale use
        
        map<id, id> orderId_billingAccountId = new map<id, id>();
        map<id, ARMS_CreateAndUpdate.PaymentInfoWrapper> billingAccountId_paymentInfoWrapper = new map<id, ARMS_CreateAndUpdate.PaymentInfoWrapper>();
        map<id, string> billingAccountId_otherPaymentMethod = new map<id, string>();
        map<id, id> billingAccountId_orderId = new map<id, id>();
        
        list<Zuora__CustomerAccount__c> billingAccountList = new list<Zuora__CustomerAccount__c>();
        map<id, Zuora__CustomerAccount__c> billingAccountId_billingAccount = new map<id, Zuora__CustomerAccount__c>();
        map<id, Order__c> billingAccountId_Order = new map<id, Order__c>();
        map<id, Order__c> billingAccountIdWithExisting_Order = new map<id, Order__c>();
        set<id> orderIdforArmsSet = new set<id>();
        set<id> billingAccountIdWithAccountSet = new set<id>();
        Set<Id> billingAccountIDSet = new Set<Id>(); //start-end D-2839 jason abolac

        //for updateBillingAccountToZuoraAndSfdc() parameters initiation:
        map<id, string> billId_ARMSAccountNumber = new map<id, string>(); 
        map<id, string> billId_ARMSCustomerNumber = new map<id, string>();
        map<id, string> billId_CreatorID = new map<id, string>(); 
        map<id, string> billId_ARMSDebtManagement = new map<id, string>();
        map<id, string> billId_ARMSBusinessProfile = new map<id, string>();
        map<id, string> billId_ARMSID = new map<id, string>();
        map<id, string> billId_CustGiroAcctNumber = new map<id, string>();
        map<id, string> billId_CustGiroBankNumber = new map<id, string>();
        map<id, string> billId_CreditLimitExternal = new map<id, string>();
        map<id, string> billId_CreditLimitInternal = new map<id, string>();
        map<id, string> billId_CreditTermRefererence = new map<id, string>();
        map<id, string> billId_CustomerNumber = new map<id, string>();
        boolean isInvoice;
        isInvoice = false;
        
        //START: D-4232 1-6-2015 Added by Kristine Balaoing - added logging mechanism
        List<exception> exceptionList = new List<exception>();
        //END: D-4232 1-6-2015 Added by Kristine Balaoing
        //retrieve billing account zuora id
        //START 02/19/2015 JTeves Code Optimization: Remove NULL values on Query filter set
        //START: D-4232 1-6-2016 Added by Kristine Balaoing - added for logging mechanism
        try{
            orderIdSet.remove(null);
            if(orderIdSet != NULL){
                for (Zuora__Subscription__c tmp : [select Order_Number_1__c, Zuora__CustomerAccount__c 
                        from Zuora__Subscription__c where Order_Number_1__c in :orderIdSet]) {
                    if(tmp.Order_Number_1__c!=NULL && tmp.Zuora__CustomerAccount__c!=NULL){
                        orderId_billingAccountId.put(tmp.Order_Number_1__c, tmp.Zuora__CustomerAccount__c);
                    }
                }
                // end retrieve billing account zuora id

                //START UD-1645 6/22/2015 GdelRosario : added this for calling the method to update cheque details
                updateBillingAccountForRenewCheque(orderIdSet);
                //END UD-1645 6/22/2015 GdelRosario 
                
                // retrieve related orders
                
                for (Order__c tmp : [select Id, Customer_No__c, Payment_Mode__c, Other_Payment_Mode__c, 
                        ARMS_Account_Number__c, Business_Profile__c, Debt_Management_Treatment__c,
                        ARMS_Credit_Term__c, Credit_Term_Reference__c, Credit_Limit_Internal_Limit__c, 
                        Credit_Limit_External_Limit__c, Approved_Debt_Exposure_Amount__c,  
                        Cust_Giro_Acct_Number__c, Cust_Giro_Bank_Number__c, Business_Sector__c, Company_Code__c, 
                        SOA_Suppression_Indicator__c, Transient_Indicator__c, Create_ARMS_Customer_Account__c, 
                        Create_ARMS_Account_Only__c, CreatedById   
                        from Order__c where Billing_Account_Creation_Mode__c = 'Create New Billing Account' 
                        and Id in :orderIdSet]) {
                        
                        id billingAccountId = orderId_billingAccountId.get(tmp.Id);
                    // for arms
                    if (tmp.Payment_Mode__c == 'Other' && tmp.Other_Payment_Mode__c == 'Invoice') {
                        
                        orderIdforArmsSet.add(tmp.Id);
                        //START UD-1214 Gdelrosario/Ledesma : added method for ARMS account only mapping billingId and order
                        //START D-3108 13/06/2015 S.Puli
                        /*if(tmp.Create_ARMS_Account_Only__c == true){
                            if(tmp != null){
                              billingIdToAccountOnly.put(billingAccountId, tmp);
                            }

                        }*/
                        //END D-3108 13/06/2015 S.Puli
                        //END UD-1214 Gdelrosario/Ledesma : added method for ARMS account only mapping billingId and order
                        
                        if (tmp.Create_ARMS_Customer_Account__c == true || tmp.Create_ARMS_Account_Only__c == true) {
                            ARMS_CreateAndUpdate.PaymentInfoWrapper paymentInfo = new ARMS_CreateAndUpdate.PaymentInfoWrapper();
                            
                            paymentInfo.armsId = tmp.Customer_No__c;
                            paymentInfo.armsBusinessProfile = tmp.Business_Profile__c;
                            paymentInfo.armsDebtManagement = tmp.Debt_Management_Treatment__c;
                            billingAccountId_paymentInfoWrapper.put(billingAccountId, paymentInfo);
                            
                            billingAccountId_Order.put(billingAccountId, tmp);
                            
                            //START D-2839 05-06-2015 Jason Abolac
                            //START D-3108 13/06/2015 S.Puli
                            billingIdToAccountOnly.put(billingAccountId, tmp);
                            //END D-3108 13/06/2015 S.Puli
                            billingAccountIDSet.add(billingAccountId);
                            //END D-2839 05-06-2015 Jason Abolac
                            
                            isInvoice = true;
                        } else {
                            billingAccountIdWithAccountSet.add(billingAccountId);
                            billId_ARMSAccountNumber.put(billingAccountId, tmp.ARMS_Account_Number__c); 
                            billId_ARMSCustomerNumber.put(billingAccountId, tmp.Customer_No__c);
                            billId_CreatorID.put(billingAccountId, ((string)tmp.CreatedById).substring(0, 15)); 
                            billId_ARMSDebtManagement.put(billingAccountId,  tmp.Debt_Management_Treatment__c);
                            billId_ARMSBusinessProfile.put(billingAccountId, tmp.Business_Profile__c);
                            billId_CustGiroAcctNumber.put(billingAccountId, tmp.Cust_Giro_Acct_Number__c);
                            billId_CustGiroBankNumber.put(billingAccountId, tmp.Cust_Giro_Bank_Number__c);
                            billId_CreditLimitExternal.put(billingAccountId, tmp.Credit_Limit_External_Limit__c);
                            billId_CreditLimitInternal.put(billingAccountId, tmp.Credit_Limit_Internal_Limit__c);
                            billId_CreditTermRefererence.put(billingAccountId, tmp.Credit_Term_Reference__c);
                            billId_CustomerNumber.put(billingAccountId, tmp.Customer_No__c);
                            //billId_ARMSID.put(billingAccountId, );
                            billingAccountId_orderId.put(billingAccountId, tmp.Id);
                            isInvoice = true;
                        }
                    
                    } else {
                        billingAccountId_orderId.put(billingAccountId, tmp.Id);
                        isInvoice = false;
                        //billingAccountId_otherPaymentMethod.put(billingAccountId, tmp.Other_Payment_Mode__c);
                    }
                }
               
             }    
            //END 02/19/2015 JTeves
                
                for (Zuora__CustomerAccount__c tmp : [select Id, Zuora__Zuora_Id__c, Other_PaymentMethod__c, ARMS_Account_Number__c, 
                        ARMS_Account_Type__c, ARMS_Business_Profile__c, ARMS_Debt_Management__c, ARMS_ID__c, Name,
                        Zuora__Account__c, Zuora__AccountNumber__c, Zuora__BillToAddress1__c, Zuora__BillToAddress2__c, 
                        Zuora__BillToPostalCode__c, Zuora__BillToCity__c, Zuora__BillToName__c, CreatedById 
                        from Zuora__CustomerAccount__c where Id in :billingAccountId_paymentInfoWrapper.keySet()]) {
                    
                    billingAccountList.add(tmp);
                    billingAccountId_billingAccount.put(tmp.Id, tmp);
                    //START UD-1214 Ledesma/Gdelrosario : pair up the the order id with its order details 
                    for(Id billAccId : billingIdToAccountOnly.keySet()){
                        if(billAccId == tmp.Id){
                            IdToBillingAccount.put(tmp.Id, tmp);
                        }
                    }
                    //END UD-1214
                }
                //START UD-1214 Ledesma/Gdelrosario : pair up the the order id with its order details 
                if(IdToBillingAccount.size() > 0){
                    updateBillingAccountAccountOnly(billingIdToAccountOnly, IdToBillingAccount);
                }       
                //END UD-1214
                 
              
                
                if (billingAccountList.size() > 0) {
                    //START D-2839 05-06-2015 Jason Abolac
                    updateSphPaymentMethod(billingAccountIdSet);
                    //END D-2599 05-06-2015 Jason Abolac
                     
                    // create arms account and update zuora and sfdc
                    ARMS_CreateAndUpdate armsInstance = new ARMS_CreateAndUpdate();
                    armsInstance.createAccount(orderIdforArmsSet, billingAccountId_billingAccount, billingAccountId_paymentInfoWrapper, billingAccountId_Order);
                    
         
                    //START UD-0810 
                    List<Zuora.zObject> zObjectListSubs = new List<Zuora.zObject>();
                    List <Zuora__Subscription__c> SubsToUpdate = new List <Zuora__Subscription__c>();
                           
                    map<id, List<Zuora__Subscription__c>> billIDtoSubsZuoraID = new map<id, List<Zuora__Subscription__c>>();     // Billing Account to Subscription Zuora ID
                    for ( Zuora__Subscription__c eachSubscription :[select Id, Zuora__Zuora_Id__c, Zuora__CustomerAccount__c, Billing_Type__c , Zuora__Version__c
                                                                    from Zuora__Subscription__c where 
                                                                    Order_Number_1__c in :billingAccountId_order.values()]) {
                        if (billIDtoSubsZuoraID.containskey(eachSubscription.Zuora__CustomerAccount__c)) {
                            billIDtoSubsZuoraID.get(eachSubscription.Zuora__CustomerAccount__c).add(eachSubscription);
                        }
                        else {
                            list<Zuora__Subscription__c> myTempSubs = new List<Zuora__Subscription__c>();
                            myTempSubs.add(eachSubscription);
                            billIDtoSubsZuoraID.put(eachSubscription.Zuora__CustomerAccount__c, myTempSubs);
                        }
                     }
                     
                     
                     set<id> subFullPrepaidSet  = new set<id>();
                    
                            
                     for (Zuora__CustomerAccount__c tmp :  [select Id, Zuora__Zuora_Id__c, Other_PaymentMethod__c, Zuora__DefaultPaymentMethod__c, 
                        Zuora__Account__c, Bank__c from Zuora__CustomerAccount__c where Id in :billingAccountId_order.keySet()]) {
                     
                         List <Zuora__Subscription__c> SubsZuoraIds = new List <Zuora__Subscription__c>();
                         
                         
                         
                         if (billIDtoSubsZuoraID.containskey(tmp.id)) {
                              SubsZuoraIds = billIDtoSubsZuoraID.get(tmp.id);
                         }
                         
                         
                         
                         
                         for (Zuora__Subscription__c currentSubscription :SubsZuoraIds ) { 
                            
                            //Zuora.zObject zObjectSubs = new Zuora.zObject('Subscription');
                            //zObjectSubs.setValue('Id', currentSubscription.Zuora__Zuora_Id__c);
                            //zObjectSubs.setValue('Other_PaymentMethod__c', 'Invoice');
                            //zObjectListSubs.add(zObjectSubs);
                            currentSubscription.Other_PaymentMethod_1__c = 'Invoice';
                            
                            
                            
                            currentSubscription.Other_PaymentMethod__c = 'Invoice';
                            
                            SubsToUpdate.add(currentSubscription);
                            
                            
                             
                            if (currentSubscription.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID
                                                            && currentSubscription.Zuora__Version__c == 1) {
                                subFullPrepaidSet.add(currentSubscription.Id);
                            }
                         }  
                     }
                    /* START D-3052 (Bill Run Hotfix) 05/31/15 John Dacutan/Kevin Evasco - No need to call invoiceProcessForFullPrepaid as this is already being invoked in the SubscriptionTriggerHandler.
                    if (!subFullPrepaidSet.isEmpty() ) {
                        invoiceProcessForFullPrepaid inv = new invoiceProcessForFullPrepaid();
                        inv.callInvoice(subFullPrepaidSet);
                    }
                    END D-3052 Bill Run Hotfix 05/31/15 John Dacutan/Kevin Evasco - No need to call invoiceProcessForFullPrepaid as this is already being invoked in the SubscriptionTriggerHandler. */
                    //START UD-0810 04-23-2015 Marvin G              
                    //if (SubsToUpdate.size() > 0) {
                        //update SubsToUpdate;
                    //}
                    //END UD-0810 04-23-2015 Marvin G
                     
                     
                     //END D-2599 04-15-2015 Marvin Gatchalian
                }
                // end retrieve related orders
                
                
                if (billingAccountId_orderId.size() > 0 && !isInvoice) {
                    updateBillingAccountToZuora(billingAccountId_orderId);
                }
                
                if (billingAccountIdWithAccountSet.size() > 0) {
                    
                    updateBillingAccountToZuoraAndSfdc(
                            billingAccountIdWithAccountSet,
                            billId_ARMSAccountNumber, 
                            billId_ARMSCustomerNumber, 
                            billId_CreatorID, 
                            billId_ARMSDebtManagement,
                            billId_ARMSBusinessProfile,
                            billId_ARMSID,
                            billId_CustGiroAcctNumber,
                            billId_CustGiroBankNumber,
                            billId_CreditLimitExternal,
                            billId_CreditLimitInternal,
                            billId_CreditTermRefererence,
                            billingAccountId_orderId);    
                }
        }catch(Exception e){
                exceptionList.add(e);
        }
        
        if(exceptionList.size()>1){
            ExceptionLogger.log(exceptionList);
        }
        //END: D-4232 1-6-2016 Added by Kristine Balaoing
            
    }

    
    @future(callout=true)
    public static void updateBillingAccountToZuora(map<id, id> billingAccountId_orderId) {
        
        system.debug('>>>updateBillingAccountToZuora ');
        //START: D-4232 1-6-2016 Added by Kristine Balaoing - added logging mechanism
        
        List<exception> exceptionList = new List<exception>();
        try{
            List<Zuora.zObject> zObjectList = new List<Zuora.zObject>();
            //START UD-0810 04-13-2014 Marvin Gatchalian
            List<Zuora.zObject> zObjectListSubs = new List<Zuora.zObject>();
            //END UD-0810 04-13-2014 Marvin Gatchalian
            
            Zuora.zApi zApiInstance = new Zuora.zApi();
            //START D-3268 Modified By C.I.Salas - Test Coverage
            if (!Test.isRunningTest()) {
                zApiInstance.zlogin();
            }
            //END D-3268 Modified By C.I.Salas - Test Coverage
            
            //START D-2938 05-14-2015 Marvin Gatchalian added GL Code field
            //START D-3048  06-05-2015 K.Tan -Populate GL Code and Cost Centre
            map<id, Order__c> orderId_Order = new map<id, Order__c>([select Id, Other_Payment_Mode__c, Check_Amount__c, 
                    Check_Dated__c, Check_No__c, Check_Issuing_Bank__c, Payment_Mode__c, GL_Code__c, Cost_Centre__c 
                    from Order__c where Id in :billingAccountId_orderId.values()]);
            //END D-3048  06-05-2015 K.Tan -Populate GL Code and Cost Centre
            //END D-2938 05-14-2015 Marvin Gatchalian added GL Code field
            
            //START UD-0810 04-13-2015 Marvin Gatchalian
            set <string> accountIDset = new set <string>();
            map<id, Zuora__PaymentMethod__c> billIDtoPaymentMethod = new map<id, Zuora__PaymentMethod__c>();
            for ( Zuora__PaymentMethod__c eachPaymentMethod :[select Id, name, Zuora__BillingAccount__c 
                                                                from Zuora__PaymentMethod__c where 
                                                                Zuora__BillingAccount__c in :billingAccountId_orderId.keyset()]) {
                billIDtoPaymentMethod.put(eachPaymentMethod.Zuora__BillingAccount__c, eachPaymentMethod);
            
            }
            
            map<id, List<Zuora__Subscription__c>> billIDtoSubsZuoraID = new map<id, List<Zuora__Subscription__c>>();     // Billing Account to Subscription Zuora ID
            for ( Zuora__Subscription__c eachSubscription :[select Id, Zuora__Zuora_Id__c, Zuora__CustomerAccount__c 
                                                                from Zuora__Subscription__c where 
                                                                Order_Number_1__c in :billingAccountId_orderId.values()]) {
                if (billIDtoSubsZuoraID.containskey(eachSubscription.Zuora__CustomerAccount__c)) {
                    billIDtoSubsZuoraID.get(eachSubscription.Zuora__CustomerAccount__c).add(eachSubscription);
                }
                else {
                    list<Zuora__Subscription__c> myTempSubs = new List<Zuora__Subscription__c>();
                    myTempSubs.add(eachSubscription);
                    billIDtoSubsZuoraID.put(eachSubscription.Zuora__CustomerAccount__c, myTempSubs);
                }
            
            }
                                                                  
            //END UD-0810 04-13-2015 Marvin Gatchalian
            
            list<Zuora__CustomerAccount__c> billingAccountList = new list<Zuora__CustomerAccount__c>();
            List <Zuora__Subscription__c> SubsToUpdate = new List <Zuora__Subscription__c>();
            
            //START D-2938  05-14-2015 Marvin Gatchalian added GL Code field
            //START D-3048  06-05-2015 K.Tan -Populate GL Code and Cost Centre

            for (Zuora__CustomerAccount__c tmp :  [select Id, Zuora__Zuora_Id__c, Other_PaymentMethod__c, Zuora__DefaultPaymentMethod__c, 
                    Zuora__Account__c, Bank__c, GL_Code__c, Cost_Centre__c from Zuora__CustomerAccount__c where Id in :billingAccountId_orderId.keySet()]) {
            //END D-3048  06-05-2015 K.Tan -Populate GL Code and Cost Centre

            //END D-2938 05-14-2015 Marvin Gatchalian added GL Code field
                
                Order__c tmpOrder = orderId_Order.get(billingAccountId_orderId.get(tmp.Id));
                tmp.Other_PaymentMethod__c = tmpOrder.Other_Payment_Mode__c;
                tmp.Payment_Mode__c = tmp.Zuora__DefaultPaymentMethod__c;
                
                
                if (tmp.Zuora__DefaultPaymentMethod__c != null) {
                    
                    if (tmp.Zuora__DefaultPaymentMethod__c.toLowerCase() == 'cheque' || 
                            tmp.Zuora__DefaultPaymentMethod__c.toLowerCase() == 'check') {
                                
                        tmp.Payment_Mode__c = 'Check';
                        tmp.Cheque_Date__c = tmpOrder.Check_Dated__c;
                        tmp.Bank__c = tmpOrder.Check_Issuing_Bank__c;
                        
                        try {
                            tmp.Cheque_No__c = decimal.valueOf(tmpOrder.Check_No__c);
                        } catch (exception e) {
                            tmp.Cheque_No__c = null;
                        }
                    }
                    
                    if (tmp.Zuora__DefaultPaymentMethod__c.toLowerCase() == 'creditcard'){
                        tmp.Other_PaymentMethod__c = '';
                        tmp.Payment_Mode__c = 'CreditCard';
                        tmp.Zuora__AutoPay__c = true; // Start/End D-2756 22Apr15 JohnD
                        
                        system.debug('Payment Method >>>>>> ' + billIDtoPaymentMethod.containskey(tmp.id));
                        //START UD-0810 04-13-2014 Marvin Gatchalian
                        if (billIDtoPaymentMethod.containskey(tmp.id)) {
                            Zuora__PaymentMethod__c currentPaymentMethod = billIDtoPaymentMethod.get(tmp.id);
                            //START UD-1397 19-06-2015 Marvin Gatchalian
                            //START D-3279 RReyes - 07/27/15
                            if (currentPaymentMethod.id != null){
                                if(String.valueOf(currentPaymentMethod.id) != '')
                                    tmp.Zuora__Default_Payment_Method__c = currentPaymentMethod.id;
                            }
                            /* CommentedOut by RReyes to use logic above
                            if (currentPaymentMethod.id != null || currentPaymentMethod.id != '') {
                                tmp.Zuora__Default_Payment_Method__c = currentPaymentMethod.id;
                            }
                            CommentedOut by RReyes to use logic above */
                            //END D-3279 RReyes - 07/27/15
                            //END UD-1397 19-06-2015 Marvin Gatchalian
                        }
                        //END UD-0810 04-13-2014 Marvin Gatchalian
                        system.debug('>>>updateBillingAccountToZuora >> Default Payment Method' + tmp.Zuora__DefaultPaymentMethod__c);
                    }
                    
                   //START UD-0810 04-13-2014 Marvin Gatchalian
                    if (tmp.Zuora__DefaultPaymentMethod__c.toLowerCase() == 'cash'){   
                        tmp.Other_PaymentMethod__c = '';
                        tmp.Payment_Mode__c = 'Cash';
                    }
                   //END UD-0810 04-13-2014 Marvin Gatchalian
                   
                }
                
                // prepare data for zuora update

                if (tmpOrder.Payment_Mode__c == 'Other') {
                    system.debug('>>>updateBillingAccountToZuora >> Other >>' + tmpOrder.Payment_Mode__c);
                    Zuora.zObject zObject = new Zuora.zObject('Account');
                    zObject.setValue('Id', tmp.Zuora__Zuora_Id__c);
                    zObject.setValue('Other_PaymentMethod__c', tmpOrder.Other_Payment_Mode__c);
                     //START D-3048  06-05-2015 K.Tan -Populate GL Code and Cost Centre
                    zObject.setValue('GL_Code__c', tmpOrder.GL_Code__c);
                    zObject.setValue('Cost_Centre__c', tmpOrder.Cost_Centre__c);
                     //END D-3048  06-05-2015 K.Tan -Populate GL Code and Cost Centre               
                    zObjectList.add(zObject);
                    
                    
                    //START D-2938  05-14-2015 Marvin Gatchalian
                    if (tmpOrder.Other_Payment_Mode__c == 'Internal Charge') {
                        tmp.GL_Code__c = tmpOrder.GL_Code__c;
                    //START D-3048  06-05-2015 K.Tan -Populate GL Code and Cost Centre
                        tmp.Cost_Centre__c = tmpOrder.Cost_Centre__c;
                    //END D-3048  06-05-2015 K.Tan -Populate GL Code and Cost Centre
                          
                    }
                    //END D-2938  05-14-2015 Marvin Gatchalian
                    
                    
                    //START UD-0810 04-13-201 4 Marvin Gatchalian
                    List <Zuora__Subscription__c> SubsZuoraIds = new List <Zuora__Subscription__c>();
                    
                    SubsZuoraIds = billIDtoSubsZuoraID.get(tmp.id);
                    
                    for (Zuora__Subscription__c currentSubscription :SubsZuoraIds ) { 
                        Zuora.zObject zObjectSubs= new Zuora.zObject('Subscription');
                        zObjectSubs.setValue('Id', currentSubscription.Zuora__Zuora_Id__c);
                        zObjectSubs.setValue('Other_PaymentMethod__c', tmpOrder.Other_Payment_Mode__c);
                        zObjectListSubs.add(zObjectSubs);
                        currentSubscription.Other_PaymentMethod_1__c = tmpOrder.Other_Payment_Mode__c;
                        currentSubscription.Other_PaymentMethod__c = tmpOrder.Other_Payment_Mode__c;
                        SubsToUpdate.add(currentSubscription);
                    }
                    
                }
                // end prepare data for zuora update
                accountIDset.add(tmp.Zuora__Zuora_Id__c);
                //END UD-0810 04-13-2014 Marvin Gatchalian
                billingAccountList.add(tmp);
           }
           
            if (billingAccountList.size() > 0) {
                
                if (zObjectList.size() > 0) {
                    List<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(zObjectList);

                }
                
                //START UD-0810 04-13-2014 Marvin Gatchalian
                if (zObjectListSubs.size() > 0) {
                    List<Zuora.zApi.SaveResult> resultsSubs = zApiInstance.zupdate(zObjectListSubs);

                }
                //END UD-0810 04-13-2014 Marvin Gatchalian

                //Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
                //syncManager.syncZuoraObjectIdSet = accountIDset;
                //syncManager.sendRequest();
                
                update billingAccountList;
                //START UD-0810 04-23-2015 MarvinG
                //update SubsToUpdate;
                //END UD-0810 04-23-2015 MarvinG
            }
        }catch(Exception e){
            exceptionList.add(e);
        }
        
        if(exceptionList.size()>0){
            ExceptionLogger.log(exceptionList);
        }
        //END: D-4232 1-6-2016 Added by Kristine Balaoing
    }

        
    
    //START UD-0810 04-13-2014 Marvin Gatchalian
    @future(callout=true)
    public static void updateBillingAccountToZuoraAndSfdc(
            set<id> billingAccountId,
            map<id, string> billId_ARMSAccountNumber, 
            map<id, string> billId_ARMSCustomerNumber, 
            map<id, string> billId_CreatorID, 
            map<id, string> billId_ARMSDebtManagement,
            map<id, string> billId_ARMSBusinessProfile,
            map<id, string> billId_ARMSID,
            map<id, string> billId_CustGiroAcctNumber,
            map<id, string> billId_CustGiroBankNumber,
            map<id, string> billId_CreditLimitExternal,
            map<id, string> billId_CreditLimitInternal,
            map<id, string> billId_CreditTermRefererence,
            map<id, id> billingAccountId_orderId) {
                

        List<Zuora.zObject> zObjectList = new List<Zuora.zObject>();
        List<Zuora.zObject> zObjectListSubs = new List<Zuora.zObject>();
        //START: D-4232 1-6-2016 Added by Kristine Balaoing - added logging mechanism
        List<exception> exceptionList = new List<exception>();
        
        try{
            Zuora.zApi zApiInstance = new Zuora.zApi();
            //START D-3268 Modified By C.I.Salas - Test Coverage
            if (!Test.isRunningTest()) {
                zApiInstance.zlogin();
            }
            //END D-3268 Modified By C.I.Salas - Test Coverage

            list<Zuora__CustomerAccount__c> billingAccountList = new list<Zuora__CustomerAccount__c>();
            list<Zuora__Subscription__c> SubsToUpdate = new list<Zuora__Subscription__c>();
            
            map<id, Order__c> orderId_Order = new map<id, Order__c>(); //Account to Order
            
            for (Order__c eachOrder :[select Id, Account__c, Other_Payment_Mode__c, Check_Amount__c, 
                    Check_Dated__c, Check_No__c, Check_Issuing_Bank__c, Payment_Mode__c  
                    from Order__c where Id in :billingAccountId_orderId.values()]) {
                    
                    orderId_Order.put(eachOrder.Account__c, eachOrder );
            }
           
            set <string> accountIDset = new set <string>();
           
            
            map<id, List<Zuora__Subscription__c>> billIDtoSubsZuoraID = new map<id, List<Zuora__Subscription__c>>();     // Billing Account to Subscription Zuora ID
            for ( Zuora__Subscription__c eachSubscription :[select Id, Zuora__Zuora_Id__c, Zuora__CustomerAccount__c 
                                                                from Zuora__Subscription__c where 
                                                                Order_Number_1__c in :billingAccountId_orderId.values()]) {
                if (billIDtoSubsZuoraID.containskey(eachSubscription.Zuora__CustomerAccount__c)) {
                    billIDtoSubsZuoraID.get(eachSubscription.Zuora__CustomerAccount__c).add(eachSubscription);
                }
                else {
                    list<Zuora__Subscription__c> myTempSubs = new List<Zuora__Subscription__c>();
                    myTempSubs.add(eachSubscription);
                    billIDtoSubsZuoraID.put(eachSubscription.Zuora__CustomerAccount__c, myTempSubs);
                }
            
            }
            
         
                  
            for (Zuora__CustomerAccount__c tmp :  [select Id, Zuora__Zuora_Id__c, Other_PaymentMethod__c, 
                    ARMS_Account_Number__c, Creator_ID__c, ARMS_Debt_Management__c, ARMS_Business_Profile__c, 
                    ARMS_Account_Type__c, GIRO_A_C__c, GIRO_Bank_Code__c, Credit_Limit_External__c, 
                    Credit_Limit_Internal__c, Credit_Term__c, Payment_Mode__c, Zuora__DefaultPaymentMethod__c 
                    from Zuora__CustomerAccount__c where Id in :billingAccountId]) {
                //START D-2760 17-Apr-2015 Added by Raviteja  - unCommented for as part of the duplicate ARMS ID changes   - values are not populating into the ARMS ID
                //tmp.Other_PaymentMethod__c = 'Invoice';
                  tmp.Other_PaymentMethod__c = 'Invoice';
                 //End D-2760 17-Apr-2015 Added by Raviteja
                
                
                tmp.ARMS_Account_Type__c = 'SS';
                tmp.ARMS_Account_Number__c = billId_ARMSAccountNumber.get(tmp.Id);
                tmp.ARMS_Customer_Number__c = billId_ARMSCustomerNumber.get(tmp.Id);
                tmp.Creator_ID__c = billId_CreatorID.get(tmp.Id);
                tmp.ARMS_Debt_Management__c = billId_ARMSDebtManagement.get(tmp.Id);
                tmp.ARMS_Business_Profile__c = billId_ARMSBusinessProfile.get(tmp.Id);
                //START D-2760 17-Apr-2015 Added by Raviteja  - Commented for as part of the duplicate ARMS ID changes   - values are not populating into the ARMS ID
                //tmp.ARMS_ID__c = billId_ARMSID.get(tmp.Id);
                tmp.ARMS_ID__c = billId_ARMSCustomerNumber.get(tmp.Id);
                //End D-2760 17-Apr-2015 Added by Raviteja
                tmp.GIRO_A_C__c = billId_CustGiroAcctNumber.get(tmp.Id);
                tmp.GIRO_Bank_Code__c= billId_CustGiroBankNumber.get(tmp.Id);
                tmp.Payment_Mode__c = tmp.Zuora__DefaultPaymentMethod__c;
                
                if (billId_CreditLimitExternal.get(tmp.Id) != null) {
                    tmp.Credit_Limit_External__c = decimal.valueOf(billId_CreditLimitExternal.get(tmp.Id));
                 }
                
                    
                    // prepare data for zuora update
                        Zuora.zObject zObject = new Zuora.zObject('Account');
                        zObject.setValue('Id', tmp.Zuora__Zuora_Id__c);

                        zObject.setValue('Other_PaymentMethod__c', 'Invoice');
                        //START UD-2653 17-Sept-2015 Added By S.Puli
                        //zObject.setValue('ARMS_Account_Number__c', billId_ARMSAccountNumber.get(tmp.Id));
                        //END UD-2653 17-Sept-2015 Added By S.Puli
                        
                        if (billId_ARMSAccountNumber.get(tmp.Id) != null) { 
                            zObjectList.add(zObject);
                        }
                        // end prepare data for zuora update
                    
                    
                        List <Zuora__Subscription__c> SubsZuoraIds = new List <Zuora__Subscription__c>();
                        if (billIDtoSubsZuoraID.containskey(tmp.id)) {
                            SubsZuoraIds = billIDtoSubsZuoraID.get(tmp.id);
                        }
                        
                        //if (orderId_Order.containskey(tmp.Zuora__Account__c)) {
                        //    Order__c curOrder = orderId_Order.get(tmp.Zuora__Account__c);
                            
                                
                            //if (SubsZuoraIds.size() > 0 ) {
                                for (Zuora__Subscription__c currentSubscription :SubsZuoraIds ) { 
                                    Zuora.zObject zObjectSubs = new Zuora.zObject('Subscription');
                                    zObjectSubs.setValue('Id', currentSubscription.Zuora__Zuora_Id__c);
                                    zObjectSubs.setValue('Other_PaymentMethod__c', 'Invoice');
                                    zObjectListSubs.add(zObjectSubs);
                                    currentSubscription.Other_PaymentMethod_1__c = 'Invoice';
                                    currentSubscription.Other_PaymentMethod__c = 'Invoice';
                                    SubsToUpdate.add(currentSubscription);
                                }
                            //}
                            
                        //}
                    
                
                
                accountIDset.add(tmp.Zuora__Zuora_Id__c); 
                billingAccountList.add(tmp);
            }
           

            if (billingAccountList.size() > 0) {
                if (zObjectList.size() > 0) {
                    List<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(zObjectList);
                    system.debug('>>>zuoraarmsupdate ' + results);
                }
                
                if (zObjectListSubs.size() > 0) {
                    List<Zuora.zApi.SaveResult> resultsSubs = zApiInstance.zupdate(zObjectListSubs);
                }
                
                //START UD-0810 04-23-2015 MarvinG
                //update SubsToUpdate;
                //END UD-0810 04-23-2015 MarvinG
                 
                 //START D-2760 17-Apr-2015 Added by Raviteja  - unCommented for as part of the duplicate ARMS ID changes                    
                //update billingAccountList;
                //set the isSkipUpdate to true
                        ARMS_TriggerHandler.isSkipUpdate = true;                    
                       update billingAccountList; 
                //End D-2760 17-Apr-2015 Added by Raviteja
                
            }
        }catch(Exception e){
            exceptionList.add(e);
        }
        if(exceptionList.size()>0){
            ExceptionLogger.log(exceptionList);
        }
        //END: D-4232 1-6-2016 Added by Kristine Balaoing
    }
    // end ARMS functionality
    //END UD-0810 04-13-2014 Marvin Gatchalian
    
    // Start D-2756 22Apr15 JohnD - added method to update the default payment method   
    /* 
     * @description : this method will update the default payment method in zuora. invoke from 
     *     PaymentMethodTriggerHandler apex class
     * @param : set of billing account ids
     * @return : none
    */
    @future (callout=true)
    public static void updateDefaultPaymentMethod(set<id> billingAccountIdSet) {
        
        //START: D-4232 1-6-2016 Added by Kristine Balaoing - added logging mechanism
        List<exception> exceptionList = new List<exception>();
        // Start D-4592 07Apr16 JohnD
        final string CARD_TYPE_AMEX = 'AmericanExpress';
        final string PAYMENT_GATEWAY = 'CyberSource AMEX';
        final string CREDIT_CARD = 'creditcard';
        // End D-4592 07Apr16 JohnD
        
        try{
            billingAccountIdSet.remove(null);
            
            list<Zuora__CustomerAccount__c> billingAccountList = [select Id, Zuora__Default_Payment_Method__c, 
                    Zuora__DefaultPaymentMethod__c, Zuora__Zuora_Id__c, Zuora__CreditCardType__c from Zuora__CustomerAccount__c where Id in :billingAccountIdSet];	// Start/End D-4592 07Apr16 JohnD - added field
            
            set<id> paymentIdSet = new set<id>();
            map<id, string> paymentId_paymentExternalId = new map<id, string>();
            list<Zuora.zObject> zObjectList = new list<Zuora.zObject>();
            
            Zuora.zApi zApiInstance = new Zuora.zApi();
            //START D-3268 Modified By C.I.Salas - Test Coverage
            if (!Test.isRunningTest()) {
                zApiInstance.zlogin();
            }
            //END D-3268 Modified By C.I.Salas - Test Coverage
            
            for (Zuora__CustomerAccount__c ba : billingAccountList) {
                if (ba.Zuora__DefaultPaymentMethod__c != null && ba.Zuora__Default_Payment_Method__c != null) {
                            
                    paymentIdSet.add(ba.Zuora__Default_Payment_Method__c);
                }
            }
            
            paymentIdSet.remove(null);
            
            if (!paymentIdSet.isEmpty()) {

                for (Zuora__PaymentMethod__c p : [select Id, Zuora__External_Id__c from Zuora__PaymentMethod__c where Id in :paymentIdSet]) {
                    if (p.Zuora__External_Id__c != null) {
                        paymentId_paymentExternalId.put(p.Id, p.Zuora__External_Id__c);
                    }
                }
                
                for (Zuora__CustomerAccount__c ba : billingAccountList) {
                    if (ba.Zuora__DefaultPaymentMethod__c != null && ba.Zuora__Default_Payment_Method__c != null) {
                                
                        if (paymentId_paymentExternalId != null && paymentId_paymentExternalId.containsKey(ba.Zuora__Default_Payment_Method__c)) {
                            
                            Zuora.zObject zObject = new Zuora.zObject('Account');
                            zObject.setValue('Id', ba.Zuora__Zuora_Id__c);
                            zObject.setValue('DefaultPaymentMethodId', paymentId_paymentExternalId.get(ba.Zuora__Default_Payment_Method__c));
                            
                            // Start D-4592 07Apr16 JohnD - added PaymentGateway
                            if (ba.Zuora__DefaultPaymentMethod__c.toLowerCase() == CREDIT_CARD || ba.Zuora__DefaultPaymentMethod__c == 'PayPal') { //START/END 05/04/2015 CR-005 Kevin Evasco - PayPal CR
                                zObject.setValue('AutoPay', true);
								
								if (ba.Zuora__DefaultPaymentMethod__c.toLowerCase() == CREDIT_CARD && ba.Zuora__CreditCardType__c == CARD_TYPE_AMEX) {
									zObject.setValue('PaymentGateway', PAYMENT_GATEWAY);
								}								
								
                            }
                            // End D-4592 07Apr16 JohnD - added PaymentGateway
                            
                            zObjectList.add(zObject);
                        }
                    }
                }
                
                if (zObjectList != null && !zObjectList.isEmpty()) {
                    list<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(zObjectList);
                }
            }
        }catch(Exception e){
            exceptionList.add(e);
        }
        
        if(exceptionList.size()>0){
            ExceptionLogger.log(exceptionList);
        }
        //END: D-4232 1-6-2016 Added by Kristine Balaoing
    }
    // End D-2756 22Apr15 JohnD - added method to update the default payment method
     //START UD-1214 Ledesma/Gdelrosario : added method to updaye BillingAccount Only
    public static void updateBillingAccountAccountOnly(map<Id, order__c> billAccOnly, map<id, Zuora__CustomerAccount__c> idToBillAcc){
    
        list<Zuora__CustomerAccount__c> updateBillingAccountList = new list<Zuora__CustomerAccount__c>();
        //START: D-4232 1-6-2015 Added by Kristine Balaoing - added logging mechanism
        List<exception> exceptionList = new List<exception>();
        
        try{
            for(Id billacc : idToBillAcc.keySet()){
                Order__c tmp = billAccOnly.get(billacc);
                Zuora__CustomerAccount__c billingAccount = idToBillAcc.get(billacc);
                
                if(billingAccount != null){
                  billingAccount.ARMS_Business_Profile__c = tmp.Business_Profile__c;
                    //START D-3108 13/06/2015 S.Puli
                    billingAccount.ARMS_Debt_Management__c = tmp.Debt_Management_Treatment__c;
                    //END D-3108 13/06/2015 S.Puli
                }

                
                
                if(billingAccount != null){
                    updateBillingAccountList.add(billingAccount);
                }
                
            }
            
            if(updateBillingAccountList.size() > 0){
                //START D-3108 13/06/2015 S.Puli
                ARMS_TriggerHandler.isSkipUpdate = true;
                //END D-3108 13/06/2015 S.Puli
                update updateBillingAccountList;
            }
        }catch(Exception e){
            exceptionList.add(e);
        }
        
        if(exceptionList.size()>0){
            ExceptionLogger.log(exceptionList);
        }
        //END: D-4232 1-6-2016 Added by Kristine Balaoing
    }
    //END UD-1214
    
    
    //START D-2839 05-06-2015 Jason Abolac
    @future (callout=true)
    public static void updateSphPaymentMethod(set<id> billingAccountIdSet) {
    
        //Start D-4011 03-Dec-2015 Added by S.Puli - exception logger
        boolean isRecordLock = true;
        list<exception> exceptionList = new list<exception>();
        //End D-4011 03-Dec-2015 Added by S.Puli
        //START: D-4232 1-6-2016 Added by Kristine Balaoing - added logging mechanism
        try{
            billingAccountIdSet.remove(null);
        
            list<Zuora__CustomerAccount__c> billingAccountsetList = [select Id, Zuora__Default_Payment_Method__c, 
                Zuora__DefaultPaymentMethod__c, Zuora__Zuora_Id__c, Other_PaymentMethod__c from Zuora__CustomerAccount__c where Id in :billingAccountIdSet];
            system.debug('billingAccountsetList' + billingAccountsetList);
            set<id> paymentIdSet = new set<id>();
            map<id, string> paymentId_paymentExternalId = new map<id, string>();
            list<Zuora.zObject> zObjectList = new list<Zuora.zObject>();
            
            Zuora.zApi zApiInstance = new Zuora.zApi();
            //START D-3268 Modified By C.I.Salas - Test Coverage
            if (!Test.isRunningTest()) {
                zApiInstance.zlogin();
            }
            //END D-3268 Modified By C.I.Salas - Test Coverage
            
            if (!billingAccountsetList.isEmpty()) {

                system.debug('zObjectList' + zObjectList);
                for (Zuora__CustomerAccount__c ba : billingAccountsetList) {              
                            Zuora.zObject zObject = new Zuora.zObject('Account');
                            zObject.setValue('Id', ba.Zuora__Zuora_Id__c);
                            zObject.setValue('Other_PaymentMethod__c', 'Invoice');
                            zObjectList.add(zObject);
                            system.debug('zObjectList' + zObjectList);
                            
                            //START UD-0810v3 05-07-2015 Marvin G
                            ba.Other_PaymentMethod__c = 'Invoice';
                            ba.Payment_Mode__c = 'Other';
                            //END UD-0810v3 05-07-2015 Marvin G

                }
                
                if (zObjectList != null && !zObjectList.isEmpty()) {
                    list<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(zObjectList);
                    system.debug('results' + results);
                    
                }
                
                //START UD-0810v3 05-07-2015 Marvin G
                //START D-3108 13/06/2015 S.Puli
                ARMS_TriggerHandler.isSkipUpdate = true;
                //END D-3108 13/06/2015 S.Puli
            
            
                
            //Start D-4011 03-Dec-2015 Added by S.Puli - logic to retry record update when record is locked
                while(isRecordLock){
                    try{
                        update billingAccountsetList;
                        isRecordLock = false;
                    } catch (dmlexception e) {
                        isRecordLock = e.getMessage().contains('UNABLE_TO_LOCK_ROW');
                        exceptionList.add(e);
                    }
                }              
                //End D-4011 03-Dec-2015 Added by S.Puli - logic to retry record update when record is locked
                //END UD-0810v3 05-07-2015 Marvin G
                
            }
        }catch(Exception e){
            exceptionList.add(e);
        }
        if(exceptionList.size()>0) {
            ExceptionLogger.log(exceptionList);
        } 
        //END: D-4232 1-6-2016 Added by Kristine Balaoing
    }
    //END D-2839 05-06-2015 Jason Abolac

    //START UD-1645 6/22/2015 GdelRosario : added this method for update of Billing Account when Renewal of exisintg BA (cheque)
    public static void updateBillingAccountForRenewCheque(set<id> orderId){
        map<id, id> orderId_billingAccountId2 = new map<id, id>();
        List <Zuora__CustomerAccount__c> billAcctToUpdate = new List<Zuora__CustomerAccount__c>(); 
        //START: D-4232 1-6-2015 Added by Kristine Balaoing - added logging mechanism
        List<Exception> exceptionList = new List<Exception>();
    
        try{
            for (Zuora__Subscription__c tmp : [select Order_Number_1__c, Zuora__CustomerAccount__c 
                    from Zuora__Subscription__c where Order_Number_1__c in :orderId]) {
                if(tmp.Order_Number_1__c!=NULL && tmp.Zuora__CustomerAccount__c!=NULL){
                    orderId_billingAccountId2.put(tmp.Order_Number_1__c, tmp.Zuora__CustomerAccount__c);
                }
            }
            system.debug('>>>>>orderId' + orderId);
            for (Order__c tmp : [select Id, Customer_No__c, Payment_Mode__c, Other_Payment_Mode__c, CreatedById, Check_Issuing_Bank__c,
                    Check_No__c,Check_Dated__c,Check_Amount__c   
                    from Order__c 
                    where Billing_Account_Creation_Mode__c = 'Use existing Billing Account'
                    and Payment_Mode__c = 'Check' 
                    and Id in :orderId ]){

               id billingAccountId = orderId_billingAccountId2.get(tmp.Id);
                        
                 for(Zuora__CustomerAccount__c billAcct : [select Id, Zuora__Default_Payment_Method__c, Zuora__DefaultPaymentMethod__c, Zuora__Zuora_Id__c, Other_PaymentMethod__c
                        from Zuora__CustomerAccount__c 
                        where Id = :billingAccountId]){
                        
                        billAcct.Cheque_Date__c=tmp.Check_Dated__c;
                        // Start UD-2865 26Nov15 JohnD - trap null pointer
                        if (tmp.Check_No__c != null) {
                            billAcct.Cheque_No__c = decimal.valueOf(tmp.Check_No__c);
                        } else {
                            billAcct.Cheque_No__c = null;
                        }
                        // End UD-2865 26Nov15 JohnD - trap null pointer
                       billAcct.Bank__c=tmp.Check_Issuing_Bank__c;
                        billAcctToUpdate.add(billAcct);
                            
                        system.debug('----->>' + billAcctToUpdate.size());
                        
                }
            }

            if(billAcctToUpdate.size()>0){
                update billAcctToUpdate;    
            }
        }catch(Exception e){
            exceptionList.add(e);
        }
            
        if(exceptionList.size()>0){
            ExceptionLogger.log(exceptionList);
        }
        //END: D-4232 1-6-2016 Added by Kristine Balaoing
            
    }
    //END UD-1645 6/22/2015 GdelRosario : added this method for update of Billing Account when Renewal of exisintg BA (cheque)
}

//END UD-0810 04-14-2015 Marvin Gatchalian - modified majority of codes...