/**
 * Class Name: AdjustmentUsageLoader 
 * @author: Kevin Evasco
 * Date: Augsut 5, 2015
 * Requirement/Project Name: CRSM Project
 * @description Class which loads Adjustment Usages to Zuora
 * History: 06 August 08 UD-2122 - Created new apex class
 */
public class AdjustmentUsageLoader{
    
    public static Id CASE_ADJUSTMENT = (Id) ConstantsSLB.getKeyID('Case_Adjustments');
    
    public static String UOM_ADJUSTMENT = 'Adjustment';
    public static String UOM_ADJUSTMENT_NO_TAX = 'Adjustment No Tax';
    public static String USAGE_TYPE_ADJUSTMENT = 'Adjustment';
    
    @future(callout=true)
    public static void loadAdjustmentUsages(Set<Id> caseIdSet){ 
        
        Set<Id> invoiceIdSet = new Set<Id>();
        Set<Id> billingAccountIdSet = new Set<Id>();
        Set<Id> subscriptionIdSet = new Set<Id>();
        Set<String> invoicesWithZeroTaxIdSet = new Set<String>();
        Set<String> taxableInvoicesZIDSet = new Set<String>();
        
        List<Usage__c> usageList = new List<Usage__c>();
        List<Case> caseList = new List<Case>(); 
        List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>(); // START-END 12/10/2015 D-4076 added by jason A. for Code review 
        List<Invoice_Line_Item__c> invoiceLineItemList;
        List<Zuora__Subscription__c> subscriptionList;
        
        Map<Id, Boolean> invoiceId_taxableFlag_map = new Map<Id, Boolean>();
        Map<Id, Case> accountId_caseRecord_map = new Map<Id, Case>();
        
        caseList = [SELECT Id, Invoice__c, Invoice__r.Zuora__Zuora_Id__c, Invoice__r.Zuora__BillingAccount__c, ClosedDate, Adjustment_Amount__c, Invoice__r.Zuora__TaxAmount__c, Subscription_Name__c FROM Case WHERE Id IN: caseIdSet AND RecordTypeId = :CASE_ADJUSTMENT AND Adjustment_Amount__c > 0];
                    
                  
        for (Case caseElement : caseList) {
            if(caseElement.Invoice__c != null) {
                invoiceIdSet.add(caseElement.Invoice__c);
                accountId_caseRecord_map.put(caseElement.Invoice__r.Zuora__BillingAccount__c, caseElement);
                
                if(caseElement.Invoice__r.Zuora__TaxAmount__c != 0)
                    taxableInvoicesZIDSet.add(caseElement.Invoice__r.Zuora__Zuora_Id__c);
                else                    
                    invoicesWithZeroTaxIdSet.add(caseElement.Invoice__r.Zuora__Zuora_Id__c);
            }
            
            if(caseElement.Subscription_Name__c != null){
                subscriptionIdSet.add(caseElement.Subscription_Name__c);
            }
            
            billingAccountIdSet.add(caseElement.Invoice__r.Zuora__BillingAccount__c); // CHANGE TO BILLING ACCOUNT
        }
        
        // per invoice, get invoice line items WHERE Tax Amount != 0, if there is mark the invoice as taxable
        invoiceLineItemList = [SELECT Id, Invoice_ID__c FROM Invoice_Line_Item__c WHERE Invoice_ID__c IN :invoicesWithZeroTaxIdSet AND Tax_Amount__c != 0];
        
        for(Invoice_Line_Item__c invoiceLineItemElement : invoiceLineItemList) {
            taxableInvoicesZIDSet.add(invoiceLineItemElement.Invoice_ID__c);
        }       
        
        subscriptionList = [SELECT Id, Name, Zuora__CustomerAccount__c, Zuora__CustomerAccount__r.Zuora__AccountNumber__c,
                                        (SELECT Id, Name, Zuora__UOM__c , Zuora__Price__c, Zuora__ChargeNumber__c, PublicationCode__c
                                        FROM Zuora__Subscription_Product_Charges__r
                                        WHERE Zuora__Subscription__c IN :subscriptionIdSet AND (Name = :UOM_ADJUSTMENT OR Name = :UOM_ADJUSTMENT_NO_TAX))
                                    FROM Zuora__Subscription__c WHERE Id IN :subscriptionIdSet];
        
        for (Zuora__Subscription__c subscriptionElement : subscriptionList)
        {
            Case caseRecord = accountId_caseRecord_map.get(subscriptionElement.Zuora__CustomerAccount__c);
            Boolean isInvoiceTaxable = false;
            
            if(taxableInvoicesZIDSet.contains(caseRecord.Invoice__r.Zuora__Zuora_Id__c)) {
                isInvoiceTaxable = true;
            }           
            
            for (Zuora__SubscriptionProductCharge__c spcElement : subscriptionElement.Zuora__Subscription_Product_Charges__r){
                Boolean proceed = false;
                
                if(isInvoiceTaxable == true && spcElement.Name == UOM_ADJUSTMENT)
                    proceed = true;
                else if(isInvoiceTaxable == false && spcElement.Name == UOM_ADJUSTMENT_NO_TAX)
                    proceed = true;
                
                if(proceed == true){
                    Integer quantity = Integer.valueOf(Math.ceil(Math.abs(caseRecord.Adjustment_Amount__c / spcElement.Zuora__Price__c)));
                
                    if(quantity > 0) {
                        Usage__c usageRecord = new Usage__c();  
                        usageRecord.UOM__c = spcElement.Zuora__UOM__c;
                        usageRecord.Account_Id__c = subscriptionElement.Zuora__CustomerAccount__r.Zuora__AccountNumber__c;
                        usageRecord.Subscription_Id__c = subscriptionElement.Name;
                        usageRecord.Quantity__c = quantity;
                        usageRecord.Status__c = UsageHelper.USAGE_STATUS;   
                        usageRecord.Rate_Plan_Charge_Id__c = spcElement.Zuora__ChargeNumber__c;    
                        usageRecord.Publication_Code__c = spcElement.PublicationCode__c;
                        usageRecord.Usage_Type__c = USAGE_TYPE_ADJUSTMENT;      
                        usageRecord.StopType__c = USAGE_TYPE_ADJUSTMENT;                                            
                        
                        if(caseRecord.ClosedDate != NULL) {
                            DateTime closedDateTime = caseRecord.ClosedDate;
                            usageRecord.Start_Date__c = Date.newinstance(closedDateTime.year(), closedDateTime.month(), closedDateTime.day());
                        } else {
                            usageRecord.Start_Date__c = Date.today();
                        }
                        
                        usageList.add(usageRecord);
                    }
                }               
            }
        }
        
        UsageHelper.loadUniqueUsages(usageList,false);
    }
}