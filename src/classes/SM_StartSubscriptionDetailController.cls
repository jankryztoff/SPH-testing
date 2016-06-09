public class SM_StartSubscriptionDetailController extends SM_SubscriptionHelper { 
     
    final id orderId = ApexPages.currentPage().getParameters().get('id');
    final id accountId = ApexPages.currentPage().getParameters().get('accountId');
    //Start PPancho No data saved if we click EDIT on the Case after Order submission 
    final String orderStatus = ApexPages.currentPage().getParameters().get('status');
    //End PPancho
    
    public list<Order_Line_Item__c> orderLineItemList { get; set; }
    public string selectedOrderLineItem { get; set; }
    public Order__c thisOrder { get; set; }
    public Order_Line_Item__c orderLineItem { get; set; }
    public list<Order_Line_Item_Gift__c> promotionGifts { get; set; }
    public list<Asia1Wrapper> asia1Subscriptions { get; set; }
    public date dtlDate { get; set; }
    public transient boolean isFromPromotion { get; set; }
    public transient boolean isDigital { get; set; }
    public transient boolean isOrderLineItemsExist { get; set; }
    public string parentId {get; set;}
    public transient boolean isNewspaper {get; set;}
    public transient boolean isMagazine {get; set;}
    public List<Package_Item__c> packageItemList {get; set;}
	
	//START:D-3461 10/27/2015 Added by Manolo Valena
    public String VendorMailingAgent { get; set; }
    public Boolean isMailingAgentAirline { get; set; }
    //END:D-3461 10/27/2015 Added by Manolo Valena
	
    //Start PPancho No data saved if we click EDIT on the Case after Order submission
    public boolean getIsButtonRendered() {
        boolean bool = false;
        System.debug('DEB>>>>>>>>>>>>>>>>>>>>STATUS: ' + orderStatus);
        if(null != orderStatus) {
            
            if('New' == orderStatus || 'Draft' == orderStatus) {
                bool = false;
            }
            else {
                bool = true;
            }
        }
        System.debug('DEB>>>>>>>>>>>>>>>>>>>>isrendered: ' + bool);
        return bool;
    }
    //End PPAncho
    
    public void retrieveOrder() {
        list<SObject> orderList = new list<SObject>();
        
        string queryStr = generateOrderSoqlStr();
        //Start PPancho No data saved if we click EDIT on the Case after Order submission
        if(null != orderId){
            queryStr += ' where Id = \'' + orderId + '\' limit 1';
        }
        else {
            queryStr += ' where (Order_Type__c = \'Start\' and Account__c = \'' + accountId + '\' and Status__c =\'Draft\')';
            queryStr += ' or Id = \'' + orderId + '\' limit 1';
        }
        //End PPancho
        
       try {
            
            orderList = database.query(queryStr);
            thisOrder = (Order__c)orderList[0];
            dtlDate = SM_SubscriptionHelper.getDtlDate();
            retrieveOrderLineItems();
    
        } catch (exception e) {
            ApexPages.addMessages(e);           
        }
        
    }


    /*
     * Description: This method will retrieve all the order line items related to the Order.
     *      The list will be displayed on the Line Items section of the VF page
    */
    private void retrieveOrderLineItems() {
        orderLineItemList = getOrderLineItems(thisOrder.Id);
        Set<ID> packageId = new Set<Id>();
        if (orderLineItemList.size() > 0) {
            for(Order_Line_Item__c oli: orderLineItemList){
                packageId.add(oli.Main_Package_ID__c);
            }
            packageItemList = [Select Is_Newspaper__c, Is_Magazine__c From Package_Item__c Where Package__c IN: packageId];
            for(Package_Item__c packageItem: packageItemList){
                If(packageItem.Is_Newspaper__c == true){
                    isNewspaper = true;
                }                       
                Else if(packageItem.Is_Magazine__c == true){
                    isMagazine = true;
                }
            }
            isOrderLineItemsExist = true;
        } else {
            isOrderLineItemsExist = false;
        }
		
		//START:D-3461 10/27/2015 Added by Manolo Valena
        if(orderLineItemList[0].Vendor_Mailing_Agent__c != NULL &&
           orderLineItemList[0].Delivered_By__c == GlobalVariableClass.OLIDELIVEREDBY_MAILING_AGENT &&
           orderLineItemList[0].Order__r.Recipient_Contact__r.Address__r.RecordType.Name == GlobalVariableClass.STRING_AIRLINE) {
            isMailingAgentAirline = true;
            VendorMailingAgent = orderLineItemList[0].Vendor_Mailing_Agent__r.Name;
        }
        else {
            isMailingAgentAirline = false;
        }
        //END:D-3461 10/27/2015 Added by Manolo Valena
    } 


    /*
     * Description: This method will retrieve the information of the selected Order Line Item and 
     *      populate the data on the Subscription Details Section of the VF page.
     *      This will allow the user to update the Order Line Item. Invoke when user click on the
     *      specific Order Line Item from the Line Item section of the VF page
    */
    public void retrieveOrderLineItem() {
        
        orderLineItem = getOrderLineItem(selectedOrderLineItem);
                
        // populate getter-setter variables
        promotionGifts = orderLineItem.Order_Line_Item_Gifts__r;
        
        if (promotionGifts.size() > 0) {
            isFromPromotion = true;
        }
         
        if (orderLineItem.Is_Digital__c == true) {
            
            isDigital = true;
            asia1Subscriptions = getAsia1s(orderLineItem.Asia1_Subscriptions__r);
        }
    }
    
    //start GSantos - added for D-0585
    public void updateOrderLineItemGifts(List<Order_Line_Item__c> orderItemList){
        List<Order_Line_Item_Gift__c> OrderLineItemGifts= [SELECT Id, Hidden_Status__c FROM Order_Line_Item_Gift__c WHERE Order_Line_Item__c =:orderItemList];
        if(!OrderLineItemGifts.isEmpty())
        {
            for(Order_Line_Item_Gift__c OrderLineItemGift : OrderLineItemGifts)
            {
                OrderLineItemGift.Hidden_Status__c = 'Provisioning';
            }
            update OrderLineItemGifts;
        }
    }
    //end GSantos
    
    public PageReference submit() {
        
        retrieveOrder(); // Start/End UD-2523 29Aug15 JohnD
        
        parentId = ApexPages.currentPage().getParameters().get('def_parent_id');
        
        PageReference pgRef;
        boolean isError = false;
        
        try {
            
            Order_Line_Item__c tmp = [select id from Order_Line_Item__c where Order__c = :thisOrder.Id LIMIT 1];
            
        } catch (exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('No Order Line Item'));
            ApexPages.addMessage(myMsg);
            isError = true;
        }
        
        if (isError == false) {         
            //START: D-0964 / 12-16-2014 added by MBG/S.Puli: Moving this call out before any DML operation
            // Start UD-1431 07Jul15 JohnD -  check olis if none is delivered by vendor
            boolean isVendorExists = false;
        
            for (Order_Line_Item__c oli : getOrderLineItems(thisOrder.Id)) {
                if (oli.Delivered_By__c == GlobalVariableClass.VENDOR) {
                    isVendorExists = true;
                    break;
                }
            }
        
            if (!isVendorExists) {
                thisOrder.Delivery_Charge_Type__c = 'Z';    // Start/End UD-2211 20Aug15 JohnD - changed N to Z
                thisOrder.Subscriber_Charge__c = 0.00;
                thisOrder.Vendor_Credit__c = 0.00;
            }
            // End UD-1431 07Jul15 JohnD -  check olis if none is delivered by vendor
            //START D-1011 MD 28 09/07/2015 Dags Update the positioning 
            // creditBalance(thisOrder.Id); // Start/End UD-2501 27Aug15 JohnD - commented out
            //START: D-0964 / 12-16-2014 added by MBG: Moving this call out before any DML operation
                update registerAsia1Accounts(thisOrder.Id); // Start/End UD-3452 19Jan16 JohnD - added "update"
                //START D-2588 [MD- 12] KEstoya - Processing of CreditBalance 3/17/15
                //END D-2588 [MD- 12] KEstoya - Processing of CreditBalance 3/17/15             
            //END: D-0964 / 12-16-2014 added by MBG: Moving this call out before any DML operation
            //END D-1011 MD 28 09/07/2015 Dags Update the positioning  
              
            try {
                if(parentId != null || parentId != 'null') {
                    thisOrder.Parent_Case__c = parentId;
                }                   
            }
            catch(Exception e) {
                system.debug(parentId);
            }
            
            thisOrder.DTL_Date__c = dtlDate;
            thisOrder.Status__c = 'Provisioning';
            update thisOrder;
            
            // Start UD-2211 20Aug15 JohnD - update related quotes
            // if (thisOrder.Delivery_Charge_Type__c == 'Z') { // Start/End UD-2523 29Aug15 JohnD - moved this inside the loop

            list<zqu__Quote__c> quoteList4Update = new list<zqu__Quote__c>();
            for (zqu__Quote__c q : [select id, Delivery_Charge_Type__c, Subscriber_Charge__c, Vendor_Credit__c, zqu__ZuoraAccountID__c from zqu__Quote__c 
                    where Order_Line_Item_Number_1__r.Order__c = :thisOrder.Id]) {  // Start/End UD-2523 29Aug15 JohnD - added zqu__ZuoraAccountID__c
                
                // Start UD-2523 29Aug15 JohnD - modified logic
                if (thisOrder.Delivery_Charge_Type__c == 'Z' || thisOrder.Billing_Account__r.Zuora__External_Id__c != q.zqu__ZuoraAccountID__c) {
                    
                    if (thisOrder.Delivery_Charge_Type__c == 'Z') {
                        q.Delivery_Charge_Type__c = thisOrder.Delivery_Charge_Type__c;
                        q.Subscriber_Charge__c = thisOrder.Subscriber_Charge__c;
                        q.Vendor_Credit__c = thisOrder.Vendor_Credit__c;
                    }
                    
                    if (thisOrder.Billing_Account__r.Zuora__External_Id__c != q.zqu__ZuoraAccountID__c) {
                        q.zqu__ZuoraAccountID__c = thisOrder.Billing_Account__r.Zuora__External_Id__c;
                    }
                    
                    quoteList4Update.add(q);
                }  
                // End UD-2523 29Aug15 JohnD - modified logic
            }
            
            if (!quoteList4Update.isEmpty()) {
                update quoteList4Update;
            }
            // }    // Start/End UD-2523 29Aug15 JohnD - moved this inside the loop
            // End UD-2211 20Aug15 JohnD - updated related quotes
            
            List<Order_Line_Item__c> orderLIs = [SELECT id, DTL_Date__c from Order_Line_Item__c where Order__c = :thisOrder.Id];/////
            if(!orderLIs.isEmpty())
            {
                for(Order_Line_Item__c orderLI : orderLIs)
                {
                    orderLi.DTL_Date__c = dtlDate;
                }
                //start GSantos - added for D-0585
                updateOrderLineItemGifts(orderLIs);
                //end GSantos
            }
            
            
            //D-896 Added try catch

            
            try {
                update orderLIs;/////
            }
            
            catch (exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));      
            }
            
            // Start UD-0759 Ronald Dagaraga for submission of urgent approval process 16Apr15
            list<Case> caseList = [select Id from Case where Order__c = :thisOrder.Id];
            
            if (caseList != null && !caseList.isEmpty()) {
                list<ProcessInstance> processInstanceList = [select Status from ProcessInstance where TargetObjectId = :caseList.get(0).Id order by createdDate desc limit 1];
                if (processInstanceList != null && !processInstanceList.isEmpty() && processInstanceList[0].Status == 'Rejected') {
                    boolean isUrgent;
                    for (Order_Line_Item__c oli : [select Urgent__c from Order_Line_Item__c where Order__c = :thisOrder.Id]) {
                        if (oli.Urgent__c == true) {
                            isUrgent = true;
                            break;
                        }
                    }
                    
                    if (isUrgent == true) {
                        ApprovalProcessSubmitter.submit(caseList[0].Id);
                    }
                }
            }
            // End UD-0759 Ronald Dagaraga for submission of urgent approval process 16Apr15
            
            Subscription_Handler sh = new Subscription_Handler();
            sh.origin = 'Start Subscription';//START/END UD-1349 05/25/15 RReyes - sets value of origin to avoid attempt to dereference
            sh.Subscription_Handler_Direct(thisOrder);
            
            
            
            pgRef = new PageReference('/' + thisOrder.Account__c);
            pgRef.setRedirect(true);
            
        }
        
        return pgRef;
    }
    
    
    public PageReference voidButton() {
        
        thisOrder.Status__c = 'Void';
        
        update thisOrder;
        
        PageReference pgRef = new PageReference('/' + thisOrder.Account__c);
        pgRef.setRedirect(true);
        
        return pgRef;
        
    }

    
    public PageReference edit() {
        
        string retUrl = '/apex/SM_StartSubscriptionEntry?id=' + thisOrder.Id + '&accountId=' + thisOrder.Account__c;
        PageReference pgRef = new PageReference(retUrl);
        pgRef.setRedirect(true);
        
        return pgRef;
        
    }    
    
            
        
        
    public void creditBalance(id orderId){
    
        //START D-2588 [MD- 12] KEstoya - Processing of CreditBalance 3/17/15
                
        Zuora__Refund__c zr = new Zuora__Refund__c();
        Zuora__Payment__c zp = new Zuora__Payment__c();
        ZuoraCallOut creditBalanceCallOut = new ZuoraCallOut();       
        Set<Id> billAcctIds = new Set<Id>();
        List<Zuora__CustomerAccount__c> cAccounts = new List<Zuora__CustomerAccount__c>();
        
        String startDate;
        startDate = zuora.zUtil.getZuoraDate(date.today()); 

        
        List<Zuora__CustomerAccount__c> billingAccts = [SELECT Zuora__AccountNumber__c, Zuora__External_Id__c, Zuora__Credit_Balance__c, Payment_Mode__c, Zuora__Default_Payment_Method__r.Zuora__External_Id__c FROM Zuora__CustomerAccount__c 
                                                        WHERE Zuora__Account__c =: thisOrder.Account__c]; // START/END UD-2498 10/23/2015 K. Tan
        
        for(Zuora__CustomerAccount__c billAcc: billingAccts){
            billAcctIds.add(billAcc.Id);
            if(billAcc.Zuora__Credit_Balance__c > 0){
                cAccounts.add(billAcc);
            }
        }
                                
        Order__c order  = [SELECT Id, Billing_Account__c, Billing_Type__c, Billing_Account__r.Zuora__Zuora_Id__c FROM Order__c WHERE Id =: orderId];
        
        
        Map<String, Object> paymentRecs = new Map<String, Object>();
        List<Map<String, Object>> listMap = new List<Map<String, Object>>();
        Decimal totalRefund = 0;
        
        if (thisOrder.Billing_Type__c != null){
            if ((thisOrder.Billing_Type__c.equalsIgnorecase('Full Prepaid')) &&
                (thisOrder.Billing_Account_Creation_Mode__c != 'Create New Billing Account')){
                
                system.debug('===>>thisOrder.Billing_Account_Creation_Mode__c' + thisOrder.Billing_Account_Creation_Mode__c);
                
            for (Zuora__CustomerAccount__c billAcct:cAccounts){
                    if(billAcct.Id != order.Billing_Account__c){
                        
                        Map<String,Object> refundMap = new Map<String, Object>();
                        refundMap.put('AccountId', billAcct.Zuora__External_Id__c);                 
                        refundMap.put('Amount', billAcct.Zuora__Credit_Balance__c); 
                        refundMap.put('SourceType', 'CreditBalance'); 
                        // START UD-2498 10/23/2015 K. Tan
                        if(billAcct.Payment_Mode__c == 'CreditCard' || billAcct.Payment_Mode__c == 'Paypal') {
                        
                            refundMap.put('Type', 'Electronic');
                            refundMap.put('PaymentMethodId', billAcct.Zuora__Default_Payment_Method__r.Zuora__External_Id__c);
                        }
                        else{
                            refundMap.put('Type', 'External');
                            refundMap.put('MethodType', 'Other' );  
                        }
                        //END UD-2498 10/23/2015 K. Tan                     
                        listMap.add(refundMap);
                        totalRefund += billAcct.Zuora__Credit_Balance__c;
                    } 

                }
                List<Map<String,String>> resultMap = creditBalanceCallOut.loadZObjects(listMap, 'Refund');

                    //Map<String,String> resultMap = RefundCallOut.createMultipleZObject(listMap, 'Refund');
                    for(Map<String, String> rMap: resultMap) {
                        if (rMap.get('Status') == 'Success') {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, ConstantsSLB.geterrorMessage('SuccessfullyCreatedRefund'))); 
                        }
                        else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('FailedCreateRefundForBA')));
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Message: ' + rMap.get('Message')));

                        }

                        }
                        
                  
                
                    
                String cashId;
                String checkId;
                
                cashId = ConstantsSLB.getKeyId('PaymentMethodId_Cash');
                checkId = ConstantsSLB.getKeyId('PaymentMethodId_Check');
                
                     
                Map<String,Object> p = new Map<String, Object>();  

                if(totalRefund != 0){
                    p.put('AccountId', order.Billing_Account__r.Zuora__Zuora_Id__c);
                    p.put('Amount', totalRefund);
                    p.put('AppliedCreditBalanceAmount', totalRefund);
                    p.put('Type', 'External');
                    p.put('Status', 'Processed');  
                    p.put('EffectiveDate', startDate);                
                    p.put('PaymentMethodId', cashId);
                }
                
                try{
                Map<String,String> resultMap2 = creditBalanceCallOut.createZObject(p, 'Payment');
                

                    if (resultMap2!=null){
                    
                        
                        
                            if(resultMap2.get('Status') == 'Success'){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, ConstantsSLB.geterrorMessage('Credit Balance Payment Success')));
                            }
                            else{
                                
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('Failed Credit Balance Payment')));
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Message: ' + resultMap2.get('Message')));
                                
                            }
                            
                    }
                }
                catch(exception z){
                    system.debug(z);
                }
                                      
        }
    
    }   
       
        //END D-2588 [MD- 12] KEstoya - Processing of CreditBalance 3/17/15

}
}