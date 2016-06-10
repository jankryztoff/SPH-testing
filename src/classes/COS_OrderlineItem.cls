/**
 * Class Name: COS_OrderlineItem
 * @author: Jerella Mayel Ledesma
 * Date: 10/10/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Sets Orderline Item Details from Subscription
 */

public class COS_OrderlineItem {

	public static id billingAccountId;
	public static id billingContactId;
	
    public static Order_Line_Item__c setOrderLineItemFields(Id subId){
    	
    	Order_Line_Item__c oli = new Order_Line_Item__c();
    	
		{
    	try 
		{   // START: Code Review Implementation 2/12/2015 JAlejandro
			if (subId != null)
			{ // END: Code Review Implementation 2/12/2015 JAlejandro
					List<Zuora__Subscription__c> sublist = [SELECT Order_Line_Item_Number__c, Order_Number_1__c, Promotion_1__c, 
												  Promotion_Contract_Period_1__c, New_Contract_Period_1__c,
												  Penalty_Charge_1__c, Main_Package_1__c, Main_Package_1__r.Package_Type__c, 
												  Main_Package_1__r.Subscription_Period__c, Main_Package_1__r.Package_Sub_Type__c,
												  Main_Package_1__r.Billing_Type__c, Frequency_1__c, Zuora__SubscriptionStartDate__c, 
												  Term_Length__c, Zuora__SubscriptionEndDate__c, Urgent_1__c, Number_of_Copies__c,
												  Charity_1__c, Delivered_By_1__c, PO_Number__c, Suppress_Grace_Allocation__c, 
												  Supressed_Acknowledgement_Letter_1__c, Zuora__AutoRenew__c, Generate_Invoice__c,
												  Asia1_Creation_Mode_1__c, Term_is_discussed__c, Zuora__CustomerAccount__c, 
												  Zuora__CustomerAccount__r.Billing_Contact__c FROM Zuora__Subscription__c 
												  WHERE Id = :subId];
					
					// START: Code Review Implementation 2/12/2015 JAlejandro
					if (sublist.size() > 0)
					{// END: Code Review Implementation 2/12/2015 JAlejandro
						Zuora__Subscription__c sub = sublist.get(0); 
						oli = new Order_Line_Item__c();
						oli.Order_Line_Item_ID__c = sub.Order_Number_1__c;
						oli.Order__c = sub.Order_Number_1__c;
						oli.Promotion_ID__c = sub.Promotion_1__c;
						oli.Promotion_Contract_Period__c = sub.Promotion_Contract_Period_1__c;
						oli.New_Contract_Period__c = sub.New_Contract_Period_1__c;
						oli.Penalty_Charge__c = sub.Penalty_Charge_1__c;
						oli.Main_Package_ID__c = sub.Main_Package_1__c;
						oli.Main_Package_Type__c = sub.Main_Package_1__r.Package_Type__c;
						oli.Main_Package_Product_Sub_Type__c = sub.Main_Package_1__r.Package_Sub_Type__c;
						oli.Main_Package_Billing_Type__c = sub.Main_Package_1__r.Billing_Type__c;
						oli.Main_Package_Frequency__c = sub.Frequency_1__c;
						oli.Main_Package_Sub_Type__c = sub.Main_Package_1__r.Package_Sub_Type__c;
						oli.Start_Date__c = sub.Zuora__SubscriptionStartDate__c;
						oli.Term_Length__c = sub.Term_Length__c;
						oli.End_Date__c = sub.Zuora__SubscriptionEndDate__c;
						oli.Qty__c = sub.Number_of_Copies__c;
						oli.Charity__c = sub.Charity_1__c;
						oli.Delivered_By__c = sub.Delivered_By_1__c;
						oli.PO_Number__c = sub.PO_Number__c;
						oli.Supressed_Grace_Allocation__c = sub.Suppress_Grace_Allocation__c;
						oli.Supressed_Acknowledgement_Letter__c = sub.Supressed_Acknowledgement_Letter_1__c;
						oli.Auto_Renew__c = sub.Zuora__AutoRenew__c;
						oli.Generate_Invoice__c = sub.Generate_Invoice__c;
						oli.Asia_1_creation_mode__c = sub.Asia1_Creation_Mode_1__c;
						oli.Term_is_discussed__c = sub.Term_is_discussed__c;
						if (sub.Main_Package_1__r.Subscription_Period__c != null) {
							oli.Main_Package_Period__c = Decimal.valueOf(sub.Main_Package_1__r.Subscription_Period__c);
						}
						
						billingAccountId = sub.Zuora__CustomerAccount__c;
						billingContactId = sub.Zuora__CustomerAccount__r.Billing_Contact__c;
					}// Code Review Implementation 2/12/2015 JAlejandro
			} 
		}// Code Review Implementation 2/12/2015 JAlejandro 
		catch(exception e) 
			{
					ApexPages.addMessages(e);
			}
        return oli;
    }
   } 
}