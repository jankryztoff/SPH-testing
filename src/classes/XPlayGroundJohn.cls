public class XPlayGroundJohn {


	private void x() {
		
		ZuoraCallout zCallOut = new ZuoraCallout();
		set<string> invoiceZuoraIdSet = new set<string>();
		set<id> eNetsAccountIdSet = new set<id>();
		set<id> subscriptionIdSet = new set<id>();
		set<id> billingAccountIdSet = new set<id>();
		set<string> billingAccountZuoraIdSet = new set<string>();
		list<Zuora.zObject> zInvoiceObjectList = new list<Zuora.zObject>();
		list<map<string, object>> lstPaymentMap = new list<map<string, object>>();
		map<id, string> eNetsAccountId_paymentNumber = new map<id, string>();
		map<string, decimal> invoiceZuoraId_cashAmount = new map<string, decimal>();
		map<string, decimal> invoiceZuoraId_checkAmount = new map<string, decimal>();
		map<string, string> billingAccountZuoraId_defaultPaymentMethodId = new map<string, string>();
		map<string, Zuora__CustomerAccount__c> billingAccountZuoraId_billingAccount = new map<string, Zuora__CustomerAccount__c>();

		for (Zuora__ZInvoice__c invoice : [select Zuora__Zuora_Id__c, Zuora__Account__c, Zuora__BillingAccount__c, 
				Zuora__BillingAccount__r.Other_PaymentMethod__c from Zuora__ZInvoice__c	where Zuora__Balance2__c > 0 
				and Zuora__BillingAccount__r.Billing_Type__c = 'Full Prepaid' limit 200]) {	// zuora only accepts upto 200 parameters in where clause
			
			if (invoice.Zuora__BillingAccount__r.Other_PaymentMethod__c != null && 
					invoice.Zuora__BillingAccount__r.Other_PaymentMethod__c == 'eNets') {
				
				eNetsAccountIdSet.add(invoice.Zuora__Account__c);		
			}
			
			billingAccountIdSet.add(invoice.Zuora__BillingAccount__c);
			invoiceZuoraIdSet.add(invoice.Zuora__Zuora_Id__c);
		}


		for (BT_CO_STPPRS_StopPressSubscription__c stopPressSub : [select Payment_Number__c, Order__r.Account__c 
				from BT_CO_STPPRS_StopPressSubscription__c where Order__r.Account__c in :eNetsAccountIdSet]) {
			
			eNetsAccountId_paymentNumber.put(stopPressSub.Order__r.Account__c, stopPressSub.Payment_Number__c);
		}

		for (Invoice_Line_Item__c ili : [select Subscription__r.Order_Number_1__c, Subscription__c, 
				Subscription__r.Order_Number_1__r.Amount_Paid__c, Subscription__r.Order_Number_1__r.Check_Amount__c,  
				Subscription__r.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, 
				Subscription__r.Zuora__CustomerAccount__r.Zuora__DefaultPaymentMethod__c, Invoice_ID__c 
				from Invoice_Line_Item__c where Invoice_Id__c in :invoiceZuoraIdSet]) {
			
			if (ili.Subscription__r.Zuora__CustomerAccount__r.Zuora__DefaultPaymentMethod__c == GlobalVariableClass.CASH) {
				invoiceZuoraId_cashAmount.put(ili.Invoice_ID__c, ili.Subscription__r.Order_Number_1__r.Amount_Paid__c);
			} else if (ili.Subscription__r.Zuora__CustomerAccount__r.Zuora__DefaultPaymentMethod__c == GlobalVariableClass.CHEQUE) {
				invoiceZuoraId_checkAmount.put(ili.Invoice_ID__c, ili.Subscription__r.Order_Number_1__r.Check_Amount__c);
			}
			
			subscriptionIdSet.add(ili.Subscription__c);
		}

		for (Zuora__CustomerAccount__c billingAccount : [select Id, Zuora__External_Id__c, Zuora__DefaultPaymentMethod__c, 
				Zuora__Default_Payment_Method__r.Zuora__External_Id__c, Zuora__Account__c, Other_PaymentMethod__c,
				(select id, Order_Number_1__r.Payment_Method_ID__c, Order_Number_1__r.Billing_Account_Creation_Mode__c 
				from Zuora__Subscriptions__r where Id in :subscriptionIdSet)
				from Zuora__CustomerAccount__c where Id in :billingAccountIdSet]) {

			for (Zuora__Subscription__c sub : billingAccount.Zuora__Subscriptions__r) {
				
				if (sub.Order_Number_1__r.Billing_Account_Creation_Mode__c == 'Create New Billing Account') {
					billingAccountZuoraId_defaultPaymentMethodId.put(billingAccount.Zuora__External_Id__c, sub.Order_Number_1__r.Payment_Method_ID__c);
				} 
			}
			
			if (billingAccountZuoraId_defaultPaymentMethodId.get(billingAccount.Zuora__External_Id__c) == null) {
				billingAccountZuoraId_defaultPaymentMethodId.put(billingAccount.Zuora__External_Id__c, billingAccount.Zuora__Default_Payment_Method__r.Zuora__External_Id__c);
			}
			
			billingAccountZuoraId_billingAccount.put(billingAccount.Zuora__External_Id__c, billingAccount);
		}


		for (Zuora.zObject zInvoice : zCallOut.bulkQueryInvoices(invoiceZuoraIdSet)) {

			map<String, Object> paymentMap = new Map<String, Object>();
			
			Zuora__CustomerAccount__c billingAccount = billingAccountZuoraId_billingAccount.get((string)zInvoice.getValue('AccountId'));
			decimal balance = (decimal)zInvoice.getValue('Balance');
				
			if(billingAccount.Zuora__DefaultPaymentMethod__c == GlobalVariableClass.CASH) {
				paymentMap.put('PaymentMethodId', ConstantsSLB.getKeyId('PaymentMethodId_Cash'));
				paymentMap.put('Amount', invoiceZuoraId_cashAmount.get((string)zInvoice.getValue('Id')));
				paymentMap.put('AppliedCreditBalanceAmount', invoiceZuoraId_cashAmount.get((string)zInvoice.getValue('Id')) - balance);
				paymentMap.put('Type', 'External');
			} 
			else if (billingAccount.Zuora__DefaultPaymentMethod__c == GlobalVariableClass.CHEQUE) {
				paymentMap.put('PaymentMethodId', ConstantsSLB.getKeyId('PaymentMethodId_Check'));
				paymentMap.put('Amount', invoiceZuoraId_checkAmount.get((string)zInvoice.getValue('Id')));
				paymentMap.put('AppliedCreditBalanceAmount', invoiceZuoraId_checkAmount.get((string)zInvoice.getValue('Id')) - balance);
				paymentMap.put('Type', 'External'); 
			}
			else if (billingAccount.Zuora__DefaultPaymentMethod__c == GlobalVariableClass.OTHER) {
				paymentMap.put('PaymentMethodId', ConstantsSLB.getKeyId('ZuoraPaymentMethod_Other'));
				paymentMap.put('Amount', balance);                 
				paymentMap.put('Type', 'External');

				if(billingAccount.Other_PaymentMethod__c == 'eNets'){
					if(billingAccount.Zuora__Account__c != null && eNetsAccountId_paymentNumber.containsKey(billingAccount.Zuora__Account__c))
						paymentMap.put('Comment', 'eNets Payment Number: ' + eNetsAccountId_paymentNumber.get(billingAccount.Zuora__Account__c));
				}
			}
			else {
				paymentMap.put('PaymentMethodId', billingAccountZuoraId_defaultPaymentMethodId.get(billingAccount.Zuora__External_Id__c));
				paymentMap.put('Amount', balance);
				paymentMap.put('Type', 'Electronic');
			}

			paymentMap.put('AccountId', (string)zInvoice.getValue('AccountId'));
			paymentMap.put('EffectiveDate', Zuora.Zutil.getZuoraDate(Date.today()));    
			paymentMap.put('InvoiceId', zInvoice.getValue('Id'));
			paymentMap.put('AppliedInvoiceAmount', balance);
			paymentMap.put('Status', 'Processed');   
			
			lstPaymentMap.add(paymentMap);			
		}

		if (!lstPaymentMap.isEmpty()) {
			
			Logger logger = new Logger('PD-0266 Patch via Execute Anonymous');
			
			try {

				for (map<string, string> resultMap : zCallOut.loadZObjects(lstPaymentMap, 'Payment')) {           
					if (resultMap.get('Status') != 'Success') {
						logger.log(false, '[processPayment] Payment Creation Error: ' + resultMap.get('Message') + ' - PaymentMap: ' + lstPaymentMap); //START/END D-4235 01/07/15 RReyes - added paymentMap on logs
					}
				}
			}
			catch (Exception e)
			{
				logger.log(e);
			}
			
			logger.save();
		}

	}

}