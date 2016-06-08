global  class SendQuotesToZuora {

    public void SendQuotesToZuora(){}
    
    public void RecievedData(list<Id> lQuoteId, Id AccountId, Id BillingAccountId, boolean bNewBilling){
        SendQuoteToZBilling(lQuoteId, AccountId, BillingAccountId, bNewBilling);
    }
    

    @future (callout=true)
    static void SendQuoteToZBilling(list<Id> lQuoteId, Id AccountId, Id BillingAccountId, boolean bNewBilling){
        
        list<zqu.zQuoteUtil.ZBillingQuoteCollection> quotes = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();
        
        zqu.zQuoteUtil.ZBillingQuoteCollection quote = new zqu.zQuoteUtil.ZBillingQuoteCollection();
        quote.sfdcAccountId  = AccountId;   
        
        if (bNewBilling){ 
            quote.zAccountId     = 'new';       
        }else{
            quote.zAccountId     = BillingAccountId;
        }
        
        list<zqu.zQuoteUtil.ZBillingQuoteRequest> lQReq = new list<zqu.zQuoteUtil.ZBillingQuoteRequest>();
        for(Id i: lQuoteId){
            zqu.zQuoteUtil.ZBillingQuoteRequest req = new zqu.zQuoteUtil.ZBillingQuoteRequest();
            req.sfdcQuoteId = i;
            lQReq.add(req);
        }
        
        quote.quoteRequests = lQReq;
        quotes.add(quote);
        
        List<zqu.zQuoteUtil.zBillingResult> results = zqu.zQuoteUtil.sendToZBilling(quotes);
        
        list<string> lResult = new list<string>();
        set<string> zAccountId = new set<string>();
        for (zqu.zQuoteUtil.zBillingResult result : results ) {
            //Returns are: Status:zAccountId:zSubscriptionId
            
            System.debug('RESULTS > '+ result);
            System.debug('SEND RESULT > '+ result.success + ':'+ result.zAccountId + ':'+result.zSubscriptionId);           
            lResult.add(result.success + ':'+ result.zAccountId + ':'+result.zSubscriptionId);
            zAccountId.add(result.zAccountId);
            
        }   
        
        RealTimeOnDemandSync(zAccountId);
        assessCaseOrderStatus(lQuoteId);
        
    }
    
    @future (callout=true)
    static void RealTimeOnDemandSync(set<String> lZuoraAccountId ) {
        Set<String> zuoraAccountIdSet = new Set<String>();
        zuoraAccountIdSet = lZuoraAccountId;
        
        try
        {
          Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
          syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
          syncManager.syncZuoraObjectIdSet = zuoraAccountIdSet;	
          List<Zuora.SyncResult> syncResult = syncManager.sendRequest();
        }
        catch( Zuora.OnDemandSyncManager.OnDemandSyncException e )
        {
          // Process On-demand Sync exception.
        }

    }
    
	public static void assessCaseOrderStatus(List<Id> quoteIds) {
    	Set<Id> orderIds = new Set<Id>();
    	Map<Id, Boolean> orderIdToIsASsignedMap = new Map<Id, Boolean>();
    	List<Case> cases;
    	List<Order__c> ordersToUpdate = new List<Order__c>();
    	
    	for(zqu__Quote__c quote : [SELECT Order_Number__c FROM zqu__Quote__c WHERE Id IN :quoteIds]) {
    		if(quote.Order_Number__c != null) {
    			orderIds.add((Id) quote.Order_Number__c);
    		}
    	}
    	
    	for(Order__c orderRec : [SELECT Id, (SELECT Vendor_Mailing_Agent__c FROM Order_Line_Items_Direct__r) FROM Order__c WHERE Id IN :orderIds]) {
    		Boolean isAssigned = true;
    		for(Order_Line_Item__c oli : orderRec.Order_Line_Items_Direct__r) {
    			if(oli.Vendor_Mailing_Agent__c == null) {
    				isAssigned = false;
    			}
    		}
    		orderIdToIsASsignedMap.put(orderRec.Id, isAssigned);
    	}
    	
    	cases = [SELECT Id, Status, Order__c FROM Case WHERE Order__c IN :orderIds];
    	for(Case cas : cases) {
    		if(orderIdToIsASsignedMap.containsKey(cas.Order__c)) {
    			if(orderIdToIsASsignedMap.get(cas.Order__c)) {
	    			cas.Status = 'Closed';
	    			cas.Sub_Status__C = 'Subscription Created';
	    			ordersToUpdate.add(new Order__c(Id=cas.Order__c, Status__c = 'Close'));
    			}
    			else {
    				cas.Status = 'Pending';
    				cas.Sub_Status__c = 'Waiting for Vendor Assignment';
    				ordersToUpdate.add(new Order__c(Id=cas.Order__c, Status__c = 'Pending Vendor Assignment'));
    			}
    		}
    		
    	}
    	update cases;
    	update ordersToUpdate;
    }
    
    /*
     * Method to Generate Invoice after the Usage records has been loaded for Delivery Subscriptions
     *
    static void generateInvoice(ZouraCallout zcallout, String zBillingACctId) {
    	List<Zuora.zObject> invoiceList = new List<Zuora.zObject>();
		Zuora.zObject invoice = new Zuora.zObject('Invoice');
		invoice.setValue('AccountId', zBillingACctId);
		invoice.setValue('InvoiceDate', String.valueOf(DateTime.now().addDays(-1)));
		invoice.setValue('TargetDate', String.valueOf(DateTime.now().addDays(1)));
		invoiceList.add(invoice);
		List<Zuora.zApi.SaveResult> generateResult = zcallout.zApiInstance.zgenerate(invoiceList);

    }*/
    
    static String sendPaymentToZuora(String BillingAccountId, Id quoteId) {
    	
    	zqu__Quote__c quote = [SELECT Order_Number__c FROM zqu__Quote__c WHERE Id = :quoteId];
    	Order__c order = [Select Id, Payment_Mode__c, Check_Amount__c, Check_Dated__c, Check_Issuing_Bank__c, Check_No__c FROM Order__c WHERE Id = : quote.Order_Number__c];
    	
    	ZuoraCallOut zCallout = new ZuoraCallOut();
		Map<String, String> paymentMap = new Map<String, String>();
		paymentMap.put('AccountId', BillingAccountId); //billing account Id
		//paymentMap.put('Amount', String.valueOf(amount));	
		//paymentMap.put('AppliedCreditBalanceAmount', '100');
		//paymentMap.put('AppliedInvoiceAmount', '0');
		paymentMap.put('EffectiveDate', String.valueOf(DateTime.now())); //The date when the payment takes effect.
		paymentMap.put('Type', 'External');
		paymentMap.put('Status', 'Processed');
		paymentMap.put('PaymentMethodId', ConstantsSLB.getKeyId('PaymentMethodId_Check'));
		if(order.Payment_Mode__c == 'Check') {
			paymentMap.put('Amount', String.valueOf(order.Check_Amount__c));
			paymentMap.put('AppliedCreditBalanceAmount', String.valueOf(order.Check_Amount__c));
			String comments = 'Check Dated: ' + (order.Check_Dated__c != null ? String.valueOf(order.Check_Dated__c) : '--') + '; ' +
								'Check Issuing Bank: ' + (order.Check_Issuing_Bank__c != null ? order.Check_Issuing_Bank__c : '--') + ': ' +
								'Check No.: ' + (order.Check_No__c != null ? order.Check_No__c : '--');
			paymentMap.put('Comment', comments);
		}
		else {
			paymentMap.put('Amount', String.valueOf(order.Amount_Paid__c));
			paymentMap.put('AppliedCreditBalanceAmount', String.valueOf(order.Amount_Paid__c));
		}
		zCallout.createZObject(paymentMap, 'Payment');
		return null;
    }
  
}