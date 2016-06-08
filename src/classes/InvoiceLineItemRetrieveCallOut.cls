/*
 * Class Name: InvoiceLineItemRetrieveCallOut
 * @author: Kevin H. Evasco
 * Date: 03/09/2015
 * Project/Requirement: SPH Invoice Draft Template Controller
 * 
 * History: 03/09/2015 MD-23/D-1985 Kevin Evasco Reconstructed class for the new invoice template provided by the client
 */
 
public class InvoiceLineItemRetrieveCallOut
{
	public static String zoqlBaseQuery = 
		'SELECT AccountingCode, AppliedToInvoiceItemId, ChargeAmount, ChargeDate,'+
		'ChargeDescription, ChargeName, ChargeNumber, CreatedById,'+
		'CreatedDate, Id, InvoiceId, ProcessingType, ProductDescription, ProductId,'+
		'ProductName, Quantity, RatePlanChargeId, RevRecCode, RevRecStartDate,'+
		'RevRecTriggerCondition, ServiceEndDate, ServiceStartDate, SKU, SubscriptionId,'+
		'SubscriptionNumber, TaxAmount, TaxCode, TaxExemptAmount, TaxMode, UnitPrice,'+
		'UOM, UpdatedById, UpdatedDate FROM InvoiceItem';

    public static void retrieveInvoiceLineItemByDateRange(DateTime fromDateTime, DateTime toDateTime){
        try{
            List<Invoice_Line_Item__c> invoiceLineItemList = new List<Invoice_Line_Item__c>();
  
            String fromDate = Zuora.ZUtil.getZuoraDate(fromDateTime);
            String toDate = Zuora.ZUtil.getZuoraDate(toDateTime);
			
			String finalQuery = zoqlBaseQuery;
			finalQuery += constructFilterByDateRange(fromDate, toDate);			  
    
            invoiceLineItemList.addAll(getInvoiceLineItems(finalQuery));            
            Database.upsert(invoiceLineItemList);
        }
        catch(Exception e){
            system.debug(e);
        } 
    }
	
	public static void retrieveInvoiceLineItemByInvoiceId(String invoiceId){
        try{
            List<Invoice_Line_Item__c> invoiceLineItemList = new List<Invoice_Line_Item__c>();    
			
			String finalQuery = zoqlBaseQuery;
			finalQuery += constructFilterByInvoiceId(invoiceId);	
    
            invoiceLineItemList.addAll(getInvoiceLineItems(finalQuery));            
            Database.upsert(invoiceLineItemList);
        }
        catch(Exception e){
            system.debug(e);
        } 
    }
	
	public static String constructFilterByDateRange(String fromDate, String toDate)
	{
		return ' WHERE CreatedDate >= ' + fromDate + ' AND CreatedDate <= ' + toDate;
	}	
	
	public static String constructFilterByInvoiceId(String invoiceId)
	{
		return ' WHERE InvoiceId =\''+ invoiceId +'\'';
	}
	
	public static List<Invoice_Line_Item__c> getInvoiceLineItems(String zoql)
	{				
		List<Zuora.zObject> zObjList = new List<Zuora.zObject>();
		List<Invoice_Line_Item__c> invoiceLineItemList = new List<Invoice_Line_Item__c>();
		
		Zuora.zApi api = new Zuora.zApi();
		api.zlogin();		
	
		//Set query options
		Zuora.zApi.QueryOptions qo = new Zuora.zApi.QueryOptions();
		qo.batchSize = 500;
		qo.caseSensitive = false;
		
		//Set ZOQL for query request
		Zuora.zApi.QueryRequest qr = new Zuora.zApi.QueryRequest();
		qr.queryOptions = qo;    
		qr.zoql = zoql;	
		
		// Call zquery() to get initial results
		Zuora.zApi.QueryResult queryResult = api.zquery(qr);
		if(queryResult.size > 0){
			zObjList.addAll(queryResult.records);
		}
		// If the result set is not complete, call zqueryMore() to get more records
		Zuora.zApi.QueryResult queryMoreResult;
   
		while(!queryResult.done){
			Zuora.zApi.QueryMoreRequest qmr = new Zuora.zApi.QueryMoreRequest();
			Zuora.zApi.QueryOptions qo1 = new Zuora.zApi.QueryOptions();
			qo1.batchSize = 500;
			qo1.caseSensitive = false;
			qmr.queryOptions = qo1;         
			qmr.queryLocator = queryResult.queryLocator;
			queryMoreResult = api.zqueryMore(qmr);
			
			if(queryMoreResult.size > 0){
				zObjList.addAll(queryMoreResult.records);
			}   
		}
		
		for(Zuora.zObject zObj:zObjList){
			Invoice_Line_Item__c invoiceLineItemObj = new Invoice_Line_Item__c();
			if(zObj.getValue('AccountingCode') != null){
				invoiceLineItemObj.Accounting_Code__c = (string)zObj.getValue('AccountingCode');
			}
			if(zObj.getValue('AppliedToInvoiceItemId') != null){            
				invoiceLineItemObj.Applied_To_Invoice_Item_ID__c = (string)zObj.getValue('AppliedToInvoiceItemId');
			}
			if(zObj.getValue('ChargeAmount') != null){          
				invoiceLineItemObj.Charge_Amount__c = (decimal)zObj.getValue('ChargeAmount');
			}
			if(zObj.getValue('ChargeDate') != null){            
				invoiceLineItemObj.Charge_Date__c = (datetime)zObj.getValue('ChargeDate');
			}
			if(zObj.getValue('ChargeDescription') != null){
				invoiceLineItemObj.Charge_Description__c =(string)zObj.getValue('ChargeDescription');
			}
			if(zObj.getValue('RatePlanChargeId') != null){          
				invoiceLineItemObj.Charge_ID__c = (string)zObj.getValue('RatePlanChargeId');
			}
			if(zObj.getValue('ChargeName') != null){            
				invoiceLineItemObj.Charge_Name__c = (string)zObj.getValue('ChargeName');
			}
			if(zObj.getValue('ChargeNumber') != null){          
				invoiceLineItemObj.Charge_Number__c = (string)zObj.getValue('ChargeNumber');
			}
			if(zObj.getValue('CreatedById') != null){           
				invoiceLineItemObj.Created_By_ID__c = (string)zObj.getValue('CreatedById');
			}
			if(zObj.getValue('CreatedDate') != null){           
				invoiceLineItemObj.Created_Date__c = (datetime)zObj.getValue('CreatedDate');
			}
			if(zObj.getValue('Id') != null){            
				invoiceLineItemObj.ID__c = (string)zObj.getValue('Id');
			}
			if(zObj.getValue('InvoiceId') != null){         
				invoiceLineItemObj.Invoice_ID__c = (string)zObj.getValue('InvoiceId');
			}
			if(zObj.getValue('ProcessingType') != null){            
				invoiceLineItemObj.Processing_Type__c = (decimal)zObj.getValue('ProcessingType');
			}
			if(zObj.getValue('ProductDescription') != null){            
				invoiceLineItemObj.Product_Description__c = (string)zObj.getValue('ProductDescription');
			}
			if(zObj.getValue('ProductId') != null){         
				invoiceLineItemObj.Product_ID__c =(string)zObj.getValue('ProductId');
			}
			if(zObj.getValue('ProductName') != null){           
				invoiceLineItemObj.Product_Name__c = (string)zObj.getValue('ProductName');
			}
			if(zObj.getValue('Quantity') != null){          
				invoiceLineItemObj.Quantity__c = (decimal)zObj.getValue('Quantity');
			}
			if(zObj.getValue('RatePlanChargeId') != null){          
				invoiceLineItemObj.Rate_Plan_Charge_ID__c = (string)zObj.getValue('RatePlanChargeId');
			}
			if(zObj.getValue('RevRecCode') != null){            
				invoiceLineItemObj.Revenue_Recognition_Code__c = (string)zObj.getValue('RevRecCode');
			}
			if(zObj.getValue('RevRecStartDate') != null){           
				invoiceLineItemObj.Revenue_Recognition_Start_Date__c = (datetime)zObj.getValue('RevRecStartDate');
			}
			if(zObj.getValue('RevRecTriggerCondition') != null){            
				invoiceLineItemObj.Revenue_Recognition_Trigger_Condition__c = (string)zObj.getValue('RevRecTriggerCondition');
			}
			if(zObj.getValue('ServiceEndDate') != null){            
				invoiceLineItemObj.Service_End_Date__c = (datetime)zObj.getValue('ServiceEndDate');
			}
			if(zObj.getValue('ServiceStartDate') != null){          
				invoiceLineItemObj.Service_Start_Date__c = (datetime)zObj.getValue('ServiceStartDate');
			}
			if(zObj.getValue('SKU') != null){           
				invoiceLineItemObj.SKU__c = (string)zObj.getValue('SKU');
			}
			if(zObj.getValue('SubscriptionId') != null){            
				invoiceLineItemObj.Subscription_ID__c = (string)zObj.getValue('SubscriptionId');
			}
			if(zObj.getValue('SubscriptionNumber') != null){            
				invoiceLineItemObj.Subscription_Number__c = (string)zObj.getValue('SubscriptionNumber');
			}
			if(zObj.getValue('TaxAmount') != null){         
				invoiceLineItemObj.Tax_Amount__c = (decimal)zObj.getValue('TaxAmount');
			}
			if(zObj.getValue('TaxCode') != null){           
				invoiceLineItemObj.Tax_Code__c = (string)zObj.getValue('TaxCode');
			}
			if(zObj.getValue('TaxExemptAmount') != null){           
				invoiceLineItemObj.Tax_Exempt_Amount__c = (decimal)zObj.getValue('TaxExemptAmount');
			}
			if(zObj.getValue('TaxMode') != null){           
				invoiceLineItemObj.Tax_Mode__c = (string)zObj.getValue('TaxMode');
			}
			if(zObj.getValue('UnitPrice') != null){         
				invoiceLineItemObj.Unit_Price__c = (decimal)zObj.getValue('UnitPrice');
			}
			if(zObj.getValue('UOM') != null){           
				invoiceLineItemObj.UOM__c = (string)zObj.getValue('UOM');
			}
			if(zObj.getValue('UpdatedById') != null){           
				invoiceLineItemObj.Updated_By_ID__c = (string)zObj.getValue('UpdatedById');
			}
			if(zObj.getValue('UpdatedDate') != null){           
				invoiceLineItemObj.Updated_Date__c = (datetime)zObj.getValue('UpdatedDate');
			}
			invoiceLineItemList.add(invoiceLineItemObj);
		}
		
		return invoiceLineItemList;
	}
}