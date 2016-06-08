/**
* Class Name: <invoiceProcessForFullPrepaid>
* @authors: <Jayson Sarion>
* Date: <11/29/2014>
* Requirement/Project Name: <SPH>
* @description: Charge Usage to the Billing Account.
        * Generate Invoice for Fully Prepaid Subscriptions.
        * Create Payment for the Invoice.
* History: 01/08/15 D-1592 Wenjun: Add support for Postage Charges and also fix Usage Bugs
* History: 4/10/15 D-2618 Billrun AddedBy FrancisBenzon : reconstructed class, made a queueable apex class for Invoice and Payment Creation.
*          Apex Class: InvoicePaymentQueueableClass
*Reason: Usage creation should be prior to Invoice creation, but upon encountering dml in usage creation, callout in Invoice cannot proceed.
*/

public class invoiceProcessForFullPrepaid {
    
    /*START: D-812 12/06/14 Added by J.Sarion – Charge Usage to the Billing Account.
    * Generate Invoice for Fully Prepaid Subscriptions.
    * Create Payment for the Invoice.
    */
    public static Set<Id> lsubIdSet = new Set<Id>();
    // Start D-2451 03/27/2015 VPernicia: Add a new variable to pull the value for cash payment
    public static Decimal OrderAmountPaid;       
    // End D-2451 03/27/2015 VPernicia: Add a new variable to pull the value for cash payment
	// Start UD-0721 04/09/2015 ronald Dagaraga: Add a new variable to pull the value for Check payment
    public static Decimal OrderCheckAmountPaid;       
    // End UD-0721 04/09/2015 ronald Dagaraga: Add a new variable to pull the value for Check payment
    public void callInvoice(Set<Id> subIdSet) {
        invoicePaymentProcess(subIdSet);
    }
        
    @future(callout=true)   
    public static void invoicePaymentProcess(Set<Id> subIdSet) {
        //START 02/18/2015 JTeves - Code Optimization - Removal of NULL value in Query Filter Sets
        if(subIdSet.contains(null)) {
            subIdSet.remove(null);
        }
            
        //END 02/18/2015 JTeves - Code Optimization
        Map<Id, Order__c> orderIdToOrderMap = new Map<Id, Order__c>();
        
        Set<Id> orderIdSet = new Set<Id>();
        Set<Id> oliIdSet = new Set<Id>();
        //Set<Id> lsubIdSet = new Set<Id>();
        List<zqu__Quote__c> quoteList = new List<zqu__Quote__c>();
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        Order_Line_Item__c oli = new Order_Line_Item__c();
        String zoql;
        //START 03/31/2015 D-2610 Kevin Evasco - REMOVED CODE
        //List<Map<String, Object>> usageMapList = new List<Map<String, Object>>();
        //END 03/31/2015 D-2610 Kevin Evasco - REMOVED CODE
    
        //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
        List<Usage__c> usageList = new List<Usage__c>();        
                
        //Start D-2451 03/27/2015 VPernicia: Add a new field "Order_Number_1__r.Amount_Paid__c" to pull the value for cash payment
		//Start UD-0721 04/09/2015 ronald Dagaraga: Add a new field "Order_Number_1__r.Check_Amount__c" to pull the value for cash payment
        //START 01/08/15 D-1592 Wenjun : Query Main Package ID, Subscription Type 
		// Start 30Apr15 UD-0715 JohnD - added fields Zuora__Account__c, Zuora__SubscriptionEndDate__c
        subList = [SELECT Id, Name, Order_Number_1__c, Order_Line_Item_Number_1__c, Zuora__SubscriptionStartDate__c, Main_Package_1__c, 
                   Subscription_Type_1__c, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, Term_Length__c, Zuora__CustomerAccount__r.Zuora__AccountNumber__c,
                   Order_Number_1__r.Amount_Paid__c, Order_Number_1__r.Check_Amount__c, Zuora__Account__c, Zuora__SubscriptionEndDate__c  
                   FROM Zuora__Subscription__c WHERE Id IN : subIdSet];
		// End 30Apr15 UD-0715 JohnD - added fields Zuora__Account__c, Zuora__SubscriptionEndDate__c
        //END 01/08/15 D-1592 Wenjun
        //End D-2451 03/27/2015 VPernicia: Add a new field "Order_Number_1__r.Amount_Paid__c" to pull the value for cash payment        
		//End UD-0721 04/09/2015 ronald Dagaraga: Add a new field "Order_Number_1__r.Check_Amount__c" to pull the value for cash payment
        //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
        for (Zuora__Subscription__c sub :subList) {
            if (sub.Order_Number_1__c != null) {               
                //START 02/18/2015 JTeves - Code Optimization - Removal of NULL value in Query Filter Sets
                if(sub.Order_Number_1__c != null) {
                    orderIdSet.add(sub.Order_Number_1__c);
                }
                //END 02/18/2015 JTeves - Code Optimization
                lsubIdSet.add(sub.Id);
            }
            if (sub.Order_Line_Item_Number_1__c != null) {
                oliIdSet.add(sub.Order_Line_Item_Number_1__c);
            }
            
            // Start D-2451 03/27/2015 VPernicia: Add a new condition to pull the value for cash payment
            if (sub.Order_Number_1__r.Amount_Paid__c != null) {
                OrderAmountPaid = sub.Order_Number_1__r.Amount_Paid__c;
            } else {
                OrderAmountPaid = 0;
            }
            // End D-2451 03/27/2015 VPernicia: Add a new condition to pull the value for cash payment
            
			// Start UD-0721 04/09/2015 ronald Dagaraga: Add a new variable to pull the value for Check payment
            if (sub.Order_Number_1__r.Check_Amount__c != null) {
                OrderCheckAmountPaid = sub.Order_Number_1__r.Check_Amount__c;
            } else {
                OrderCheckAmountPaid = 0;
            }
            // End UD-0721 04/09/2015 ronald Dagaraga: Add a new variable to pull the value for Check payment
			
            
        }
        system.debug(':::orderIdSet' + orderIdSet);
        if (!orderIdSet.isEmpty()) {
            //Start: D-3064 06/08/2015 James - added Recipient_Contact__r.Address__r.Address_Type__c field to query
            orderIdToOrderMap = new Map<Id, Order__c>([SELECT Id, Recipient_Type__c, Delivery_Charge_Type__c, Recipient_Contact__r.Address__r.Address_Type__c FROM Order__c WHERE Id IN :orderIdSet]);
            //End: D-3064 06/08/2015 James
        }
        system.debug(':::ORDERMAP' + ' ' + orderIdToOrderMap);
        if (!orderIdToOrderMap.isEMpty() || orderIdToOrderMap != null) {
            //not entering here
            usageList = createUsage(subList, orderIdToOrderMap);
            system.debug(':::Usage List' + ' ' + usageList.size());            
        }
        
        
        //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
        //UsageHelper.loadUniqueUsages(usageList,true);
        //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
        if(usageList != null && !usageList.isEmpty()) {
            UsageHelper.loadUniqueUsages(usageList,true);
			// Start UD-0721 Dags 04/16/2015 Moved out of if statement
            //Id jobID = System.enqueueJob(new InvoicePaymentQueueableClass(subIdSet));
            //system.debug(':::jobID' + ' ' + jobID);
			// End UD-0721 Dags 04/16/2015 Moved out of if statement
        }          
		 // Start UD-0721 Dags 04/16/2015 Moved statement 
         Id jobID = System.enqueueJob(new InvoicePaymentQueueableClass(subIdSet));
         system.debug(':::jobID' + ' ' + jobID);		
		 // End UD-0721 Dags 04/16/2015 Moved statement 
    }
    
    
    //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only
    //START 08/01/2014 D-1592 Wenjun - Rewrite the whole class
    //START D-2530 Wenjun 21/03/15 - only Delivery & Postage needs to pass usage
    public static List<Usage__c> createUsage(List<Zuora__Subscription__c> lstSub, Map<Id, Order__c> orderIdToOrderMap) {
        system.debug(':::USAGE METHOD');
        Map<Id, zqu__ProductRatePlanCharge__c> prpIdToPrpcMap = new Map<Id, zqu__ProductRatePlanCharge__c>();
        List<zqu__ProductRatePlan__c> lstDelRatePlans;
        List<Usage__c> usageList = new List<Usage__c>();
        Integer monthDays;
        Date startDate;
        string dFormat;
        
        // Start UD-0715 27Apr15 JohnD
        list<Zuora__Subscription__c> filteredSubscriptionList = FullPrepaidDeliveryChargeCalculator.calculate(lstSub);
        // End UD-0715 27Apr15 JohnD
        
        
        /*------------ Get Rateplan for Delivery Charge -------------------*/
        lstDelRatePlans = [Select zqu__ZProduct__r.ProductType__c, zqu__ZProduct__r.ProductSubType__c, zqu__ZProduct__c, Id, Name
                           From zqu__ProductRatePlan__c Where zqu__ZProduct__r.ProductType__c = 'Charge' AND zqu__Deleted__c = false 
                           and zqu__ZProduct__r.ProductSubType__c = 'Delivery' and zqu__ZProduct__r.Name = 'Delivery Charge'];
    
        for (zqu__ProductRatePlanCharge__c lprpc : [SELECT zqu__UOM__c, zqu__ProductRatePlan__c 
                                                    FROM zqu__ProductRatePlanCharge__c WHERE zqu__Type__c = 'Usage'
                                                   AND zqu__ProductRatePlan__c in : lstDelRatePlans AND sum__c > 0]) {
            prpIdToPrpcMap.put(lprpc.zqu__ProductRatePlan__c, lprpc);
        }
        
        for (Zuora__Subscription__c sub:filteredSubscriptionList) // Start/End UD-0715 27Apr15 JohnD replaced variable
        {
            if(sub.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE ||
              sub.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY)
            {
                System.debug('==========> Processing usage for Subscription: ' + sub.Name);
                ID ratePlanIDToUse = NULL;
                String strUOM = '';
                zqu__ProductRatePlanCharge__c prpc;
                
                
                
                
                if(sub.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE)
                    strUOM = ConstantsSLB.getUOM('PostageCharge');
                else if(sub.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY)
                {
                    if (orderIdToOrderMap.containsKey(sub.Order_Number_1__c)) {
                        Order__c order = orderIdToOrderMap.get(sub.Order_Number_1__c);
                        if (!lstDelRatePlans.isEmpty()) {
                            ratePlanIDToUse = getUOM(lstDelRatePlans, order);
                        }
                    }
                }
                
                if (ratePlanIDToUse != NULL && prpIdToPrpcMap.containsKey(ratePlanIDToUse))
                    prpc = prpIdToPrpcMap.get(ratePlanIDToUse);
                
                if(prpc!= NULL && prpc.zqu__UOM__c != NULL)
                    strUOM = prpc.zqu__UOM__c;
                    
                
                Date subStartDate = sub.Zuora__SubscriptionStartDate__c;
				//START 04/28/15 D-2832 and D-2830 Kevin Evasco - Usage Start Date should be the Subscrpition Start Date
				//startDate = subStartDate.addMonths(1).toStartofMonth().addDays(-1);
				startDate = subStartDate;
				//END 04/28/15 D-2832 and D-2830 Kevin Evasco - Usage Start Date should be the Subscrpition Start Date
                
                Usage__c usageRecord = new Usage__c();          
            
                usageRecord.UOM__c = strUOM;
                usageRecord.Account_Id__c = sub.Zuora__CustomerAccount__r.Zuora__AccountNumber__c;
                usageRecord.Subscription_Id__c = sub.Name;
                usageRecord.Start_Date__c = startDate;
                usageRecord.Quantity__c = sub.Term_Length__c;
                usageRecord.Status__c = UsageHelper.USAGE_STATUS;   
                
                if(sub.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE){
                    usageRecord.Usage_Type__c = UsageHelper.USAGE_TYPE_POSTAGE_CHARGE;
                } else if (sub.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY) {
                    usageRecord.Usage_Type__c = UsageHelper.USAGE_TYPE_DELIVERY_CHARGE;
                }
                
                usageList.add(usageRecord);
            }
        }
        
        return usageList;
    }
    //END D-2530 Wenjun 20/03/15
    //END 08/01/2015 Wenjun - Rewrite the whole class
    //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only

    public static Id getUOM (List<zqu__ProductRatePlan__c> lDeliveryRatePlan, Order__c order) {
        String sAirline;
        String sOverseas;
        String sLocal;
        String sInternal;

        
        sAirline = ConstantsSLB.getKeyId('AddAirline');
        sOverseas = ConstantsSLB.getKeyId('AddOverseas');
        sLocal = ConstantsSLB.getKeyId('AddLocal');
        sInternal = ConstantsSLB.getKeyId('AddInternal');

        ID RatePlanIDToUse;
        ID DeliveryRatePlanId_Internal;
        ID DeliveryRatePlanId_HDB;
        ID DeliveryRatePlanId_Apartment;
        ID DeliveryRatePlanId_Landed;
                
        if(lDeliveryRatePlan.size() > 0){
            for(zqu__ProductRatePlan__c drp: lDeliveryRatePlan){
                if (drp.name == 'Zero Charge Amount'){
                    DeliveryRatePlanId_Internal = drp.Id;
                }else if(drp.name == 'HDB DELIVERY CHARGE'){
                    DeliveryRatePlanId_HDB = drp.Id;
                }else if(drp.name == 'APT DELIVERY CHARGE'){ 
                    DeliveryRatePlanId_Apartment = drp.Id;
                }else if(drp.name == 'LANDED DELIVERY CHARGE'){
                    DeliveryRatePlanId_Landed = drp.Id;
                }
            }
        }
        
        if(order.Recipient_Type__c == sInternal){
            RatePlanIDToUse = DeliveryRatePlanId_Internal;
        }else if(order.Recipient_Type__c == sLocal || order.Recipient_Type__c == sAirline){
            if(order.Delivery_Charge_Type__c == 'H'){
                RatePlanIDToUse = DeliveryRatePlanId_HDB;
            }else if(order.Delivery_Charge_Type__c == 'C'){
                RatePlanIDToUse = DeliveryRatePlanId_Apartment;
            }else if(order.Delivery_Charge_Type__c == 'L'){
                RatePlanIDToUse = DeliveryRatePlanId_Landed;
            }
            //Start: D-3064 06/08/2015 James - For other delivery charge type, check Recipient Contact Address Type
            else{
                if(order.Recipient_Contact__r.Address__r.Address_Type__c == 'H'){
                    RatePlanIDToUse = DeliveryRatePlanId_HDB;
                }else if(order.Recipient_Contact__r.Address__r.Address_Type__c == 'S'){
                    RatePlanIDToUse = DeliveryRatePlanId_Landed;
                }else{
                    RatePlanIDToUse = DeliveryRatePlanId_Apartment;
                }
            }
            //End: D-3064 06/08/2015 James
        }
        
        return RatePlanIDToUse;
    }
    //END: D-812 12/06/14 Added by J.Sarion
}