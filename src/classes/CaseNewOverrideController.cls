public class CaseNewOverrideController {
    /**
     * Class Name: CaseNewOverrideController 
     * @author: Karl Tan
     * Date: 
     * Requirement/Project Name: CRSM Project
     * @description Controller for CaseNewOverride VF page
     * 
     */
    //Start MMallorca UD-1167 05/09/2015
        public Contact objcontact {get; set;}
    //End MMallorca UD-1167 05/09/2015
    String selectedRTypeId;
    Id compMagId;
    String accountId;
    Id compNewsId;
    String contactId;
    String parentId;
    String subscriptionId;
    String billingaccountId;
    String subId;
    String billAccId;
    String retUrl;
    String billAccCaseFieldId;
    Id changePaymentId;
    Id changeCreditCard;
    Id bypassCreditCard;
    Id adjustmentsRType;
    Id changeAddressId;
    Id startSubId;
    Id stopSubId;
    Id changeParticularsId;
    Id resetPassId;
    Id retentionId;
    Id tempStopId;
    Id refundId;
    Id digitalId;
    Id enquiryId;
    Id changeOfSubId;
    Id account_DirectCorporate;
    Id account_DirectIndividual;
    Id account_DirectSphInterDivision;
    Id account_Vendor;
    Id account_MailingAgent;
    Id account_VendorSubscriber;
    Id renewalRecType;
    //START: D-0801 12/6/2014 Added By C. Lin - Change to String to be used for billing account to be auto populated
    String accountIdfromBilling;
    //END: D-0801 12/6/2014 Added By C. Lin
 
    Account acct;
    List<Order__c> orderRecs;
    Order__c orderRec = new Order__c();
    List<Order__c> renewalOrderRec;
    Zuora__CustomerAccount__c billrec = new Zuora__CustomerAccount__c ();
    Zuora__Subscription__c subrec = new Zuora__Subscription__c ();
    

    public CaseNewOverrideController (ApexPages.StandardController controller) {
        accountId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.DEFACCID);
        contactId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.DEFCONID);
        parentId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.DEFPARID);
        subscriptionId= ApexPages.currentPage().getParameters().get(GlobalVariableClass.SUBSCRIPTIONID);
        billingaccountId= ApexPages.currentPage().getParameters().get(GlobalVariableClass.BILLINGACCOUNT_ID);
        selectedRTypeId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.PARAMETER_RECORDTYPE);
        compMagId = ConstantsSLB.getKeyId(GlobalVariableClass.CASECOMPMAG );
        compNewsId = ConstantsSLB.getKeyId(GlobalVariableClass.COMPNEWS);
        changePaymentId = ConstantsSLB.getKeyId(GlobalVariableClass.CASEPAYMENTTYPPE);
        changeCreditCard = ConstantsSLB.getKeyId(GlobalVariableClass.CASECHANGECC);
        bypassCreditCard = ConstantsSLB.getKeyId(GlobalVariableClass.CASEBYPASSCC);
        adjustmentsRType = ConstantsSLB.getKeyId(GlobalVariableClass.CASEADJUSTMENTS);
        changeAddressId = ConstantsSLB.getKeyId(GlobalVariableClass.CASECHANGEADD);
        startSubId = ConstantsSLB.getKeyId(GlobalVariableClass.CASESTARTSUB);
        stopSubId = ConstantsSLB.getKeyId(GlobalVariableClass.CASESTOP);
        changeParticularsId = ConstantsSLB.getKeyId(GlobalVariableClass.CASEPARTICULARS);
        resetPassId = ConstantsSLB.getKeyId(GlobalVariableClass.CASERESETPASS);
        retentionId = ConstantsSLB.getKeyId(GlobalVariableClass.CASERETENTION);
        tempStopId = ConstantsSLB.getKeyId(GlobalVariableClass.CASETEMPSTOP);
        refundId = ConstantsSLB.getKeyId(GlobalVariableClass.CASEREFUND);
        digitalId = ConstantsSLB.getKeyId(GlobalVariableClass.CASEDIGITAL); 
        enquiryId  = ConstantsSLB.getKeyId(GlobalVariableClass.CASEENQUIRY);
        changeOfSubId = ConstantsSLB.getKeyId(GlobalVariableClass.CASECHANGESUB);
        account_DirectCorporate = ConstantsSLB.getKeyId(GlobalVariableClass.ACCDIRCORP);
        account_DirectIndividual = ConstantsSLB.getKeyId(GlobalVariableClass.ACCDIRINDIVIDUAL);
        account_DirectSphInterDivision = ConstantsSLB.getKeyId(GlobalVariableClass.ACCDIRSPH);
        account_MailingAgent = ConstantsSLB.getKeyId(GlobalVariableClass.ACCOUNT_MAILING_AGENT);
        account_Vendor = ConstantsSLB.getKeyId(GlobalVariableClass.ACCVENDOR);
        account_VendorSubscriber = ConstantsSLB.getKeyId(GlobalVariableClass.ACCVENDORSUB);  
        renewalRecType = ConstantsSLB.getKeyId(GlobalVariableClass.CASERENEWAL); 
        changeOfSubId = ConstantsSLB.getKeyId(GlobalVariableClass.CASECHANGESUB);      
        billAccCaseFieldId = ConstantsSLB.getKeyId(GlobalVariableClass.BILLINGACCOUNTCASE);
        
        try{
            retUrl = ApexPages.currentPage().getParameters().get(GlobalVariableClass.SUBRETURL);
            if(retUrl!=NULL){
                billrec = [SELECT Id, Name, Zuora__Account__c FROM Zuora__CustomerAccount__c WHERE Id = :retUrl.substring(1)];
                accountIdfromBilling = billrec.Zuora__Account__c;
            }
        }
        catch(Exception e){
            System.debug(e);
        }
        if(accountId != null && accountId != '') {
            try {
                acct = [Select RecordTypeId, RecordType.Name FROM Account WHERE Id = :accountId];
                orderRecs = [SELECT Id FROM Order__c WHERE Account__c = :acct.Id AND (Status__c = 'Draft' OR Status__c = 'New') LIMIT 1];
            }
            catch(Exception e) {
                acct = new Account();
                orderRecs = new List<Order__c>();
            }
        }
        

        if(subscriptionId != null && subscriptionId != '') {
            try {
                renewalOrderRec = [SELECT Id, Base_Subscription__c, Order_Type__c, Status__c FROM Order__c WHERE Order_Type__c = 'Renewal' AND Base_Subscription__c = :subscriptionId 
                                    AND (Status__c = 'Draft' OR Status__c = 'New')];
                Order__c orderRec = renewalOrderRec[1];
            }
            catch(Exception e) {
                renewalOrderRec = new List<Order__c>();
            }

        }  
        try{
            subId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.SUBRETURL);
            subRec = [SELECT Id FROM Zuora__Subscription__c WHERE Id = :subId.substring(1)];
            if(subRec != NULL){
                subscriptionId = subId.substring(1);
            }

        }
        catch(Exception e) {
            subRec = new Zuora__Subscription__c();
        }  

    }

    public PageReference redirect() {
        String pRef;
        if(selectedRTypeId == compMagId) {  
            //START UD-0707 AddedBy FrancisBenzon : Cater complaint magazine creation from a parent case
            if(accountId != null || contactId != null) 
            {
                pRef = '/apex/ComplaintMagazineEditPage?RecordType=' + selectedRTypeId + getIds();
            }
            else {
                pRef = '/apex/ComplaintMagazineEditPage?RecordType=' + selectedRTypeId + relatedCaseIds();
            }
            //END UD-0707 AddedBy FrancisBenzon : Cater complaint magazine creation from a parent case
        } 
        else if (selectedRTypeId  == renewalRecType ) {
            if(renewalOrderRec != null) {
               
               pRef = '/apex/SM_RenewalOfSubscriptionEntry?RecordType=' + selectedRTypeId  + getIds() +
                        (subscriptionId != null && subscriptionId != 'null' && subscriptionId != '' ? '&subscriptionId=' + subscriptionId : '');
            }
            else {
                pRef = '/apex/SM_RenewalOfSubscriptionEntry?RecordType=' + selectedRTypeId  + getIds() + 
                        (subscriptionId != null && subscriptionId != 'null' && subscriptionId != '' ? '&subscriptionId=' + subscriptionId : '');
            }
            return new PageReference(pRef);         
        }
               
        else if (selectedRTypeId == compNewsId ) {
            //START UD-0707 AddedBy FrancisBenzon : auto populate acct and contact when user complaint case in related Case
            if(accountId != null || contactId != null) 
            {
                 pRef = '/apex/ComplaintNewspaperPage?RecordType=' + selectedRTypeId + getIds(); 
            }
            else 
            {                   
                pRef = '/apex/ComplaintNewspaperPage?RecordType=' + selectedRTypeId + relatedCaseIds();              
            } 
            //END UD-0707 AddedBy FrancisBenzon : auto populate acct and contact when user complaint case in related Case
        }   
        
        /*else if (selectedRTypeId == changeCreditCard ) {
            pRef = '/apex/CustomHpmPageCase?RecordType=' + selectedRTypeId + getIds();     
        }*/ 
        
        else if (selectedRTypeId == changePaymentId ) {
            billAccId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.SUBRETURL);
            try {
                if(billAccId.substring(1).length() == 15){
                    billrec = [Select Id From Zuora__CustomerAccount__c Where Id = :billAccId.substring(1)];
                    billingaccountId = billAccId.substring(1);
                }
            }
            catch(Exception e) {
                billrec = new Zuora__CustomerAccount__c();
            }
        
            pRef = '/apex/ChangeOfPaymentType?RecordType=' + selectedRTypeId + getIds() +
                        (billingaccountId != null && billingaccountId != 'null' && billingaccountId != '' ? '&billingaccountId=' + billingaccountId : ''); 
        } 
        
        else if (selectedRTypeId == changeOfSubId) {
            pRef = '/apex/SM_ChangeOfSubscriptionEntry?RecordType=' + selectedRTypeId  + getIds() +
                        (subscriptionId != null && subscriptionId != 'null' && subscriptionId != '' ? '&subscriptionId=' + subscriptionId : '');
        }
        
        else if (selectedRTypeId == adjustmentsRType ) {
            subId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.SUBRETURL);
            try {
                if(subId.substring(1).length() == 15){
                    billrec = [Select Id From Zuora__CustomerAccount__c Where Id = :subId.substring(1)];
                    billingaccountId = subId.substring(1);
                }
            }
            catch(Exception e) {
                billrec = new Zuora__CustomerAccount__c();
            }
            
            pRef = '/apex/AdjustmentsCaseEditPage?RecordType=' + selectedRTypeId + getIds() +
                        (billingaccountId != null && billingaccountId != 'null' && billingaccountId != '' ? '&billingaccountId=' + billingaccountId : '');          
        }
        else if (selectedRTypeId == changeAddressId ) {
            //START UD-0707 AddedBy FrancisBenzon : cater COA creation from Parent Case
            if(accountId != null || contactId != null) 
            {
                pRef = '/apex/ChangeInAddressCaseNewPage?RecordType=' + selectedRTypeId + getcaseIds();   
            }
            else
            {
                pRef = '/apex/ChangeInAddressCaseNewPage?RecordType=' + selectedRTypeId + + relatedCaseIds();
            }
            //END UD-0707 AddedBy FrancisBenzon : cater COA creation from Parent Case
        }
        
        else if(selectedRTypeId == startSubId) {
            if (accountId != null) {
                //Start: D-1092 12/17/2014 Updated by James Azaña
                if (acct.RecordTypeId == account_DirectCorporate || acct.RecordTypeId == account_DirectIndividual || acct.RecordTypeId == account_VendorSubscriber || acct.RecordTypeId == account_DirectSphInterDivision) {
                //End: D-1092
                    if(acct.RecordTypeId == account_VendorSubscriber) {
                        pRef = '/apex/CreateVendorOrderEntry?RecordType=' + selectedRTypeId + getIds();
                        /*if(orderRecs.size() == 1) {
                            orderRec = orderRecs[0];
                        }
                        if(orderRec.Id != null) {
                            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, '' + ConstantsSLB.getErrorMessage('Account RecodType not valid'));
                            ApexPages.addMessage(msg);
                            return null;
                            //pRef = '/apex/ViewVendorOrderEntry?RecordType=' + selectedRTypeId + getIds();
                        }
                        else {
                            pRef = '/apex/CreateVendorOrderEntry?RecordType=' + selectedRTypeId + getIds();
                        }*/
                    }
                    else {
                        if(orderRec.Id != null) {
                            pRef = '/apex/SM_StartSubscriptionDetail?RecordType=' + selectedRTypeId + '&id=' + orderRec.Id + getIds();  
                        }
                        else {
                            pRef = '/apex/SM_StartSubscriptionEntry?RecordType=' + selectedRTypeId + getIds();
                        } 
                    }
                } else {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, '' + ConstantsSLB.getErrorMessage('Account RecodType not valid'));
                    ApexPages.addMessage(msg);
                    return null;
                }
            } else if(parentId != null) {
                pRef = '/apex/SM_StartSubscriptionEntry?RecordType=' + selectedRTypeId + getnextcaseIds();
            } else {
                pRef = '/apex/SM_StartSubscriptionEntry?RecordType=' + selectedRTypeId;
            }
            return new PageReference(pRef);
        }
        
        else if(selectedRTypeId == stopSubId) {
        
            if (accountId != null) {
                if(acct.RecordTypeId == account_VendorSubscriber || acct.RecordTypeId == account_Vendor) {
                    if(orderRecs.size() == 1) {
                        orderRec = orderRecs[0];
                    }
                    //Start MMallorca UD-1167 05/09/2015
                    try{
                        objcontact = [SELECT id, name FROM Contact WHERE Account.Id =: accountId AND Recipient_Indicator__c = true LIMIT 1];
                    //End MMallorca UD-1167 05/09/2015
                        // START : D-1353 12/23/2014 Alyana Navarro
                        if(isNew()){
                            pRef = '/apex/StopSubOrderEntry_Vendor_Edit?RecordType=' + selectedRTypeId + getIds();
                        } else {
                            pRef = '/apex/StopSubOrderEntry_Vendor_View?accountId=' + oldOrderRec.Account__c + '&orderId=' + oldOrderRec.Id + '&recordtypeId=' + selectedRTypeId;
                        }
                        // END : D-1353 12/23/2014
                    //Start MMallorca UD-1167 05/09/2015
                    }
                    catch(exception e){
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, '' + ConstantsSLB.getErrorMessage('Vendor Stop Subscription Error'));
                        ApexPages.addMessage(msg);
                        return null;
                    }
                    //End MMallorca UD-1167 05/09/2015
                }
                else {
                           
                        pRef = '/apex/StopSub_Order_Entry_Direct_Edit?RecordType=' + selectedRTypeId + getIds() +
                                (parentId != null && parentId != 'null' && parentId != '' ? '&parentId=' + parentId : '');
                    }
                }  else {
                    pRef = '/apex/StopSub_Order_Entry_Direct_Edit?RecordType=' + selectedRTypeId + getnextcaseIds();
                }
                return new PageReference(pRef);
        }
 
        else if (selectedRTypeId == tempStopId) {
            if (acct.RecordTypeId == account_DirectIndividual || acct.RecordTypeId == account_DirectCorporate || acct.RecordTypeId == account_DirectSphInterDivision) {
                pRef = '/apex/TempStopDirect?RecordType=' + selectedRTypeId + getIds();
            }
            
            else if (acct.RecordTypeId == account_VendorSubscriber || acct.RecordTypeId == account_Vendor){
                pRef = '/apex/VendorTempStopSubs?RecordType=' + selectedRTypeId + getIds();     
            }
        }
        //Start: UD-1131 05/06/2015 James - cancel button to previous page
        else if (selectedRTypeId  == digitalId) {
            String acctId = ApexPages.currentPage().getParameters().get('def_account_id');
            String conId = ApexPages.currentPage().getParameters().get('def_contact_id');
            if(acctId != null){
                if(conId != null){
                    pRef =  '/500/e?def_account_id=' + acctId + '&def_contact_id=' + conId + '&nooverride=1&RecordType=' + digitalId + '&retURL=/' + conId;
                }else{
                    pRef = '/500/e?def_account_id=' + acctId + '&nooverride=1&RecordType=' + digitalId + '&retURL=/' + acctId;
                }
            }
            else
            {
                //START UD-0707 5/7/15 AddedBy FrancisBenzon : to cater complaint digital from a parent case
                pRef = '/500/e?nooverride=1&RecordType=' + selectedRTypeId + '&retURL=/500/o' + getDefIds() + relatedCaseIds();
                //END UD-0707 5/7/15 AddedBy FrancisBenzon : to cater complaint digital from a parent case
            }           
        }
        //End: UD-1131 05/07/2015 James              
        else {          
            pRef = '/500/e?nooverride=1&RecordType=' + selectedRTypeId + '&retURL=/500/o' + getDefIds();
            
        }
        return new PageReference(pRef);
    }
    
    public string getDefIds() {
    String pRef;
    String billAccName;
    //START: D-0801 12/6/2014 Added By C. Lin - variable for concatenating parameters for Billing Account when user is from billing account record
    String pRefBillAcc;
    //END: D-0801 12/6/2014 Added By C. Lin
    
        if(selectedRTypeId == changeCreditCard || selectedRTypeId == bypassCreditCard){
            //START: D-0801 12/6/2014 Added By C. Lin - Removed if statement for bypassCreditCard. Changed concatenation of pRef by using another variable. For URL No longer exist errors.
            if(accountIdfromBilling != null &&  accountIdfromBilling != 'null'){                
                accountid = accountIdfromBilling;
            }
            if (billrec.Name != null) {
                billAccName = billrec.Name.replaceAll( '\\s+', '+');
                pRefBillAcc = (billrec.Name != null && billrec.Name != 'null' && billrec.Name != '' ? '&' + billAccCaseFieldId + '=' + billAccName : '') + (billrec.Id != null ? '&' + billAccCaseFieldId + '_lkid=' + billrec.Id : '');
            }
            //END: D-0801 12/6/2014 Added By C. Lin
        }
        pRef = (accountId != null && accountId != 'null' && accountId != '' ? '&def_account_id=' + accountId : '') +
        (contactId != null && contactId != 'null' && contactId != '' ? '&def_contact_id=' + contactId : '') + 
        (pRefBillAcc != null && pRefBillAcc != 'null' && pRefBillAcc != '' ? pRefBillAcc : '');
    return pRef;
    }
    
    public string getIds() {
    String pRef;
    
        pRef = (accountId != null && accountId != 'null' && accountId != '' ? '&accountId=' + accountId : '') +
        (contactId != null && contactId != 'null' && contactId != '' ? '&contactId=' + contactId : '');
   
    return pRef;
   
    }
    
    public string getcaseIds() {
    String pRef;
    
       pRef = (accountId != null && accountId != 'null' && accountId != '' ? '&accountId=' + accountId : '') +
        (contactId != null && contactId != 'null' && contactId != '' ? '&contactId=' + contactId : '') +
        (parentId != null && parentId != 'null' && parentId != '' ? '&def_parent_id=' + parentId : '');
        
    return pRef;    
    }
        //START UD-0707 AddedBy FrancisBenzon : to cater case creation from Parent Case
    
    public string getnextcaseIds() {
        String pRef;
        Case cas = [SELECT accountId, contactId FROM Case Where Id =: parentId limit 1];
        ID accId = cas.accountId;
        Id conId = cas.contactId;
        
        if (parentId != null) {
           pRef = '&def_parent_id=' + parentId;
        }

        if (accId != null) {
           pRef += '&accountId=' + accId;
        }
        if(conId != null)
        {
            pRef += '&contactId=' + conId;
        }
        //END UD-0707 AddedBy FrancisBenzon : to cater case creation from Parent Case
       //pRef = (parentId != null && parentId != 'null' && parentId != '' ? '&def_parent_id=' + parentId : '') + 
       //(accId != null && accId != 'null' && accId != '' ? '&accountId=' + accId : 'k');
        
    return pRef;    
    }
    //START UD-0707 AddedBy FrancisBenzon : auto populate acct and contact when user complaint case in related Case
    public string relatedCaseIds() 
    {
        
    String pRef;
    String accId;
    String conId;
    Case cas;
    
    if(parentId != null && parentId != '') 
    {
        cas = [SELECT accountId, contactId FROM Case Where Id =: parentId limit 1];
        accId = cas.accountId;
        conId = cas.contactId;        
    } 
    if(selectedRTypeId  == digitalId)
    {
        pRef = (accId != null && accId != '' && accId != 'null' ? '&def_account_id=' + accId : '') + 
            (conId != null && conId != 'null' && conId != '' ? '&def_contact_id=' + conId : '') + 
            (parentId != null && parentId != 'null' && parentId != '' ? '&def_parent_id=' + parentId : ''); 
    }
    else 
    {
         pRef = (accId != null && accId != '' && accId != 'null' ? '&accountId=' + accId : '') + 
            (conId != null && conId != 'null' && conId != '' ? '&contactId=' + conId : '') + 
            (parentId != null && parentId != 'null' && parentId != '' ? '&def_parent_id=' + parentId : ''); 
    }
       
        
    return pRef;    
    }
    //END UD-0707 AddedBy FrancisBenzon : auto populate acct and contact when user complaint case in related Case
    
    // START : D-1353 12/23/2014 Alyana Navarro - Check if there is existing order for stop subscription (Vendor Accounts)
    Order__c oldOrderRec;
    public Boolean isNew(){
        Boolean flag;
        
        try{
            oldOrderRec = [SELECT id, name, account__c
                           FROM Order__c 
                           WHERE Account__c =: accountId AND Status__c = 'Draft'
                                AND Case_Record_Type__c = 'Stop Subscription' LIMIT 1];
            flag = false;
        } catch(Exception e){
            flag = true;
        }                   
        
        
        
        return flag;
    }
    // END : D-1353 12/23/2014
}