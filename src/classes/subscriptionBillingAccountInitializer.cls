/**
 * Class Name: subscriptionBillingAccountInitializer 
 * @author: Michiko Santoyo
 * Date: 11-22-2014 
 * Requirement/Project Name: CRSM Project - D-0721
 * @description Class that will populate Billing Contact on Billing Account.
 * History : 2/17/2015 - KLorica Code Review Implementation : Modified code to prevent SOQL errors
 * History : 2/25/2015 D-2333 Kevin Evasco:  Enable Auto Population for Billing Account's Billing Contact field.
 */

public class subscriptionBillingAccountInitializer {    

    Set<Id> billingAccountIDSet = new Set<Id>();
    Set<Id> billingContactIDSet = new Set<Id>();
    Map<Id,Id> billingAccountbillingContactmap = new Map<Id,Id>();
    Map<Id,Zuora__CustomerAccount__c> billingAccountMap = new Map<Id,Zuora__CustomerAccount__c>();
    Map<Id,Contact> billingContactMap = new Map<Id,Contact>();
    public list<exception> exceptionBAList = new list<exception>(); //Start-End PD-0360 5-31-2016 added by Jason A.
    
    public void retrieveBillingContact(List<Zuora__Subscription__c> subscriptionList, Map<id, Order_Line_Item__c> orderLineItemId_orderLineItem) //START/END 2/25/2015 D-2333 Kevin Evasco:  Enable Auto Population for Billing Account's Billing Contact field.
    {
        
        for(Zuora__Subscription__c subRecord: subscriptionList)
        {
            //START 2/25/2015 D-2333 Kevin Evasco:  Enable Auto Population for Billing Account's Billing Contact field.
            if(subRecord.Order_Line_Item_Number__c != '' && subRecord.Order_Line_Item_Number__c != null)
            {                   
                billingAccountIDSet.add(subRecord.Zuora__CustomerAccount__c);
                billingContactIDSet.add(subRecord.Contact__c);
                try
                {
                        billingAccountbillingContactmap.put(subRecord.Zuora__CustomerAccount__c, orderLineItemId_orderLineItem.get((Id)subRecord.Order_Line_Item_Number__c).Order__r.Billing_Contact__c); 
                }
                catch(Exception e)
                {
                    exceptionBAList.add(e); //Start-End PD-0360 5-31-2016 added by Jason A.
                }
            }
            //END 2/25/2015 D-2333 Kevin Evasco:  Enable Auto Population for Billing Account's Billing Contact field.
        }
        //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check    
        if (billingAccountIDSet.size() > 0) {
            billingAccountMap = new Map<Id,Zuora__CustomerAccount__c>([SELECT Id, Zuora__Account__c, Billing_Contact__c FROM Zuora__CustomerAccount__c WHERE Id IN :billingAccountIDSet]);      
        } //END: Code Review Implementation 2/17/2015 KLorica - Added NULL check    
        
        //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check    
        if (billingContactIDSet.size() > 0) {
            billingContactMap = new Map<Id,Contact>([SELECT Id, Name FROM Contact WHERE Id IN :billingContactIDSet]);
        }//END: Code Review Implementation 2/17/2015 KLorica - Added NULL check 
        for(Zuora__CustomerAccount__c billingAccRecord : billingAccountMap.values())
        {
            Id billContactId = billingAccountbillingContactmap.get(billingAccRecord.Id);
            Contact billContactRecord = billingContactMap.get(billContactId);
            
            billingAccRecord.Billing_Contact__c = billContactId;
        }
        
        if(billingAccountMap.values().size() > 0)
        {
            try
            {
            update billingAccountMap.values();
            } catch(Exception e){
                system.debug('>>>CHA eee ' + e);
                exceptionBAList.add(e); //Start-End PD-0360 5-31-2016 Added by Jason A.
            }

        }
        
        exceptionlogger.log(exceptionBAList); //Start-End PD-0360 5-31-2016 Added by Jason A.
    }
}