/**
 * Class Name:  CustomZuoraSyncQueueable
 * @author: Zhu, Wenjun
 * Date: 28 April 2015
 * Requirement/Project Name: CRSM Project
 * @description: This is part of custom sync solution for solving the Zuora Sync Amendment Issue (Delete & Insert).
 * 				 This class will copy the subscription detail from new version to the existing subscription
 */

public class CustomZuoraSyncQueueable implements Queueable {
    Public List<Zuora__Subscription__c> lstNewVersions;
    
    public void execute(QueueableContext context) {
        if(lstNewVersions == NULL || lstNewVersions.isEmpty())
        	return;
        
        Set<String> setExistingSubNames = new Set<String>();
        Map<String, Zuora__Subscription__c> mapNewVersions = new Map<String, Zuora__Subscription__c>();
        List<Zuora__Subscription__c> lstSubsToUpd = new List<Zuora__Subscription__c>();
        
        for(Zuora__Subscription__c sub : lstNewVersions)
        {
            setExistingSubNames.add(sub.Name);
            mapNewVersions.put(sub.Name, sub);
        }
        
        //Fetch existing subscriptions  
        for(Zuora__Subscription__c oldSub : [SELECT Id, Name FROM Zuora__Subscription__c WHERE Name in : setExistingSubNames])
        {
            if(mapNewVersions.containsKey(oldSub.Name))
            {
                syncSubNewVersion(oldSub, mapNewVersions.get(oldSub.Name));
                lstSubsToUpd.add(oldSub);
            }
        }
        
        //UPDATE Existing Subscriptions
        if(!lstSubsToUpd.isEmpty())
        	UPDATE lstSubsToUpd;
    }
    
    //Copy values from the new version to existing record
    private void syncSubNewVersion(Zuora__Subscription__c oldSub, Zuora__Subscription__c newSub)
    {
        if(newSub.Contract_End_Date__c != NULL)
            oldSub.Contract_End_Date__c = newSub.Contract_End_Date__c;
        if(newSub.Recipient_Contact_1__c != NULL)
        	oldSub.Recipient_Contact_1__c = newSub.Recipient_Contact_1__c;
        if(newSub.Recipient_Contact__c != NULL)
        	oldSub.Recipient_Contact__c = newSub.Recipient_Contact__c;
        if(newSub.Other_PaymentMethod__c != NULL)
            oldSub.Other_PaymentMethod__c = newSub.Other_PaymentMethod__c;
        if(newSub.Payment_Method__c != NULL)
            oldSub.Payment_Method__c = newSub.Payment_Method__c;
        if(newSub.Payment_Mode__c != NULL)
            oldSub.Payment_Mode__c = newSub.Payment_Mode__c;
        if(newSub.Promotion_Contract_Period__c != NULL)
            oldSub.Promotion_Contract_Period__c = newSub.Promotion_Contract_Period__c;
        if(newSub.Payment_Type__c != NULL)
            oldSub.Payment_Type__c = newSub.Payment_Type__c;
        if(newSub.Subscriber_Contact__c != NULL)
            oldSub.Subscriber_Contact__c = newSub.Subscriber_Contact__c;
        if(newSub.Subscriber_Contact_1__c != NULL)
            oldSub.Subscriber_Contact_1__c = newSub.Subscriber_Contact_1__c;
        if(newSub.Term_Length1__c != NULL)
            oldSub.Term_Length1__c = newSub.Term_Length1__c;
        if(newSub.Vendor_Credit__c != NULL)
            oldSub.Vendor_Credit__c = newSub.Vendor_Credit__c;
        //if(newSub.Zuora__Account__c != NULL)
            //oldSub.Zuora__Account__c = newSub.Zuora__Account__c;
        if(newSub.Zuora__CustomerAccount__c != NULL)
            oldSub.Zuora__CustomerAccount__c = newSub.Zuora__CustomerAccount__c;
        if(newSub.Zuora__AutoRenew__c != NULL)
            oldSub.Zuora__AutoRenew__c = newSub.Zuora__AutoRenew__c;
        if(newSub.Zuora__ContractAcceptanceDate__c != NULL)
            oldSub.Zuora__ContractAcceptanceDate__c = newSub.Zuora__ContractAcceptanceDate__c;
        if(newSub.Zuora__ContractEffectiveDate__c != NULL)
            oldSub.Zuora__ContractEffectiveDate__c = newSub.Zuora__ContractEffectiveDate__c;
        if(newSub.Zuora__External_Id__c != NULL)
            oldSub.Zuora__External_Id__c = newSub.Zuora__External_Id__c;
        if(newSub.Zuora__InitialTerm__c != NULL)
            oldSub.Zuora__InitialTerm__c = newSub.Zuora__InitialTerm__c;
        if(newSub.Zuora__InvoiceOwner__c != NULL)
            oldSub.Zuora__InvoiceOwner__c = newSub.Zuora__InvoiceOwner__c;
        if(newSub.Zuora__NextChargeDate__c != NULL)
            oldSub.Zuora__NextChargeDate__c = newSub.Zuora__NextChargeDate__c;
        if(newSub.Zuora__NextRenewalDate__c != NULL)
            oldSub.Zuora__NextRenewalDate__c = newSub.Zuora__NextRenewalDate__c;
        if(newSub.Zuora__OriginalCreatedDate__c != NULL)
            oldSub.Zuora__OriginalCreatedDate__c = newSub.Zuora__OriginalCreatedDate__c;
        if(newSub.Zuora__RenewalTerm__c != NULL)
            oldSub.Zuora__RenewalTerm__c = newSub.Zuora__RenewalTerm__c;
        if(newSub.Zuora__ServiceActivationDate__c != NULL)
           	oldSub.Zuora__ServiceActivationDate__c = newSub.Zuora__ServiceActivationDate__c;
        if(newSub.Zuora__Status__c != NULL)
            oldSub.Zuora__Status__c = newSub.Zuora__Status__c;
        if(newSub.Zuora__SubscriptionStartDate__c != NULL)
            oldSub.Zuora__SubscriptionStartDate__c = newSub.Zuora__SubscriptionStartDate__c;
        if(newSub.Zuora__SubscriptionEndDate__c != NULL)
            oldSub.Zuora__SubscriptionEndDate__c = newSub.Zuora__SubscriptionEndDate__c;
        if(newSub.Zuora__MRR__c != NULL)
            oldSub.Zuora__MRR__c = newSub.Zuora__MRR__c;
        if(newSub.Zuora__TCV__c != NULL)
            oldSub.Zuora__TCV__c = newSub.Zuora__TCV__c;
        if(newSub.Zuora__TermStartDate__c != NULL)
            oldSub.Zuora__TermStartDate__c = newSub.Zuora__TermStartDate__c;
        if(newSub.Zuora__TermEndDate__c != NULL)
            oldSub.Zuora__TermEndDate__c = newSub.Zuora__TermEndDate__c;
        if(newSub.Zuora__TermSettingType__c != NULL)
            oldSub.Zuora__TermSettingType__c = newSub.Zuora__TermSettingType__c;
        if(newSub.Zuora__Version__c != NULL)
            oldSub.Zuora__Version__c = newSub.Zuora__Version__c;
        if(newSub.Zuora__Notes__c != NULL)
            oldSub.Zuora__Notes__c = newSub.Zuora__Notes__c;
        if(newSub.Zuora__Zuora_Id__c != NULL)
            oldSub.Zuora__Zuora_Id__c = newSub.Zuora__Zuora_Id__c;  
	//START D-2972 05/25/2015 Added by J.Sarion- Added mapping for Delivery Charge Type and Vendor
        if(newSub.Delivery_Charge_Type__c != NULL)
            oldSub.Delivery_Charge_Type__c = newSub.Delivery_Charge_Type__c;
        if(newSub.Vendor__c != NULL)
            oldSub.Vendor__c = newSub.Vendor__c;  
	//END D-2972 05/25/2015 Added by J.Sarion- Added mapping for Delivery Charge Type and Vendor
    }
}