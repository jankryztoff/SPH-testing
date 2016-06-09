/**
* Class Name: <calculateCharges>
* @authors: <JerellaLedesma>
* Date: <8//2014>
* Requirement/Project Name: <SPH>
* @description <Calculates delivery charge and payment charge for order line items>
*/

public class CalculateCharges{
    
    Address__c address = new Address__c();
    Contact con = new Contact();
    List<Order__c> orderRecord = new List<Order__c>();  
    List<Zuora__Subscription__c> subs = new List<Zuora__Subscription__c>();
    List<zqu__ProductRatePlanCharge__c> ProductRatePlanCharges = new List<zqu__ProductRatePlanCharge__c>(); 
    List<Package_Item__c> packageListItems = new List<Package_Item__c>();
    List<Id> orderLines = new List<Id>();
    List<Order_Line_Item__c> orderlineItems = new List<Order_Line_Item__c>();
    List<Order_Line_Item__c> fullPrepaidItems = new List<Order_Line_Item__c>();
    List<Order_Line_Item__c> RecurringPrepaidItems = new List<Order_Line_Item__c>();
    Set<Id> packageIds = new Set<Id>();
    Set<Id> prodRatePlanIds = new Set<Id>();
    Map<Id, List<Package_Item__c>> packageIdToPackageItemsMap = new Map<Id, List<Package_Item__c>>(); 
    Map<Id, List<zqu__ProductRatePlanCharge__c>> prodRatePlanIdToRatePlanChargesMap = new Map<Id, List<zqu__ProductRatePlanCharge__c>>(); 

    
    public Map<String, object> returnValues(Id orderId, String chargetype, Id recipeint, Id recipientAddress){
        Map<String, object> valuesMap = new Map<String, object>();
        
        //returns sum of Full and Recurring values and months   
        String fullAndRecurring = getfullAndRecurr(orderId, recipientAddress);
        //returns concatenated values of delivery and vendor charge
        String delVen = getDeliveryAndVendorCharge(chargetype, recipeint);
        String output = fullAndRecurring + ',' + delVen;
        
        String[] arrayOfReturned = output.split(',');
        valuesMap.put('FullPrepaid', arrayOfReturned[0]);
        valuesMap.put('RecurringPrepaid', arrayOfReturned[1]);
        valuesMap.put('Months', arrayOfReturned[2]);
        valuesMap.put('DeliveryCharge', arrayOfReturned[3]);
        valuesMap.put('VendorCredit', arrayOfReturned[4]);
        
        return valuesMap;       
    }
    
    public String getfullAndRecurr(Id orderId, Id recipientAddress){
        orderLineItems = [Select Order__r.Account__c, Start_Date__c, End_Date__c, Main_Package_ID__c, Order_Line_Item__c.Main_Package_Billing_Type__c from Order_Line_Item__c WHERE Order__c = :orderId ORDER BY End_Date__c DESC NULLS LAST];
        Integer months = getMonths(orderLineItems[0].Order__r.Account__c, recipientAddress, orderLineItems[0].Start_Date__c, orderLineItems[0].End_Date__c);
        Double recurringPrice = 0;
        Double fullPrice = 0;
        String fullAndRecurrConcat;
        
        for(Order_Line_Item__c oLine : orderLineItems){
            //adds Package Id of an orderline to a set
            packageIds.add(oLine.Main_Package_ID__c);
            
            if(oLine.Main_Package_Billing_Type__c == 'Full Prepaid'){
                fullPrepaidItems.add(oLine);
            }
            
            else if(oLine.Main_Package_Billing_Type__c == 'Recurring Prepaid'){
                RecurringPrepaidItems.add(oLine);
            }
        }
        
        //adds the package items for the package ID
        for(Package_Item__c p : [SELECT Id, Name, Package_Item__c.Product_Rate_Plan__r.Id, Product_Rate_Plan__c, Package__c FROM Package_Item__c WHERE Package__c IN :packageIds]){
            
            if(packageIdToPackageItemsMap.containsKey(p.Package__c)) {
                packageIdToPackageItemsMap.get(p.Package__c).add(p);
            }                                       
            else {
                packageIdToPackageItemsMap.put(p.Package__c, new List<Package_Item__c>{p});        
            }
        } 
        
        //gets sum of all ptoduct rate plan charge for each package item for full charge
        for (Order_Line_Item__c OLI : fullPrepaidItems){                
            fullPrice += getTotalPriceOfPackage(OLI.Main_Package_ID__c);
        }
        
        //gets sum of all ptoduct rate plan charge for each package item for recurring charge
        for (Order_Line_Item__c OLI : RecurringPrepaidItems){
            
            recurringPrice += getTotalPriceOfPackage(OLI.Main_Package_ID__c);                
        }
        
        return fullAndRecurrConcat = fullPrice+ ',' + recurringPrice + ',' + months; 
    }
    
    //maps the packagelist items for each package Id
    public double getTotalPriceOfPackage(Id packageId){
        Double totalPrice = 0;
        
        //gets the package items for each package ID that was fetched and stores it in a list.
        if(packageIdToPackageItemsMap.containsKey(packageId)){
            packageListItems = packageIdToPackageItemsMap.get(packageId);
        }
        else{
            packageListItems = new List<Package_Item__c>();
        }
        
        //returns the sum of the total price for the charges for the package Id fetched.
        if(packageListItems.size() > 0){
            for(Package_Item__c pckgItem : packageListItems)    {
                prodRatePlanIds.add(pckgItem.Product_Rate_Plan__c);
            }
            
        }
        
        //adds the package items for the package ID
        for(zqu__ProductRatePlanCharge__c prodRatePlan : [SELECT Name, sum__c, zqu__ProductRatePlanCharge__c.zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__c  IN :prodRatePlanIds]){
            
            if(prodRatePlanIdToRatePlanChargesMap.containsKey(prodRatePlan.zqu__ProductRatePlan__c)) {
                prodRatePlanIdToRatePlanChargesMap.get(prodRatePlan.zqu__ProductRatePlan__c).add(prodRatePlan);
            }                                       
            else {
                prodRatePlanIdToRatePlanChargesMap.put(prodRatePlan.zqu__ProductRatePlan__c, new List<zqu__ProductRatePlanCharge__c>{prodRatePlan});        
            }
        }
        if(packageListItems.size() > 0){
            for(Package_Item__c pckItem : packageListItems)   {
                Double priceReturned = totalPrice(pckItem.Product_Rate_Plan__c);
                totalPrice += priceReturned;
            }
        }
        
        else{
            totalPrice = 0;
        }
        
        
        return totalPrice;
        
    }
    
    //get total price of each package list item 
    public Double totalPrice(Id prodRatePlanId){        
        Double totalPriceOfProductRPCharges=0;
        
        if(prodRatePlanIdToRatePlanChargesMap.containsKey(prodRatePlanId)){
            ProductRatePlanCharges = prodRatePlanIdToRatePlanChargesMap.get(prodRatePlanId);
        }
        else{
            ProductRatePlanCharges = new List<zqu__ProductRatePlanCharge__c>();
        }
        
        for(zqu__ProductRatePlanCharge__c prodRatePlanCharRecs : ProductRatePlanCharges){
            
            totalPriceOfProductRPCharges += (prodRatePlanCharRecs.sum__c != null ? prodRatePlanCharRecs.sum__c : 0);    
        }
        return totalPriceOfProductRPCharges;           
        
    } 
    
    
    public static Integer getMonths(Id accountId, Id recipientAddressId, Date orderLineStartDate, Date orderLineEndDate){
        //gets the record with the latest end date for existing Full Prepaid subscriptions of the Recipient Contact
        Date endDate;
        Integer months = 0;
        
        try {
        	
         	Zuora__Subscription__c sub = [SELECT Id, Name, Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c 
        			WHERE Recipient_Contact__r.Address__c =:recipientAddressId AND Billing_Type__c = 'Full Prepaid' 
        			and Zuora__Account__c = :accountId ORDER BY Zuora__SubscriptionEndDate__c DESC NULLS LAST limit 1];     
        
        	endDate = sub.Zuora__SubscriptionEndDate__c;
        	months = endDate.monthsBetween(orderLineEndDate);
        
        } catch (exception e) {
        	
        	endDate = orderLineEndDate;
        	months = orderLineStartDate.monthsBetween(orderLineEndDate);
        	
        }

        return months;
    }
    

	public decimal getSubscriberCharge(string addressTypeDeliveryChargeType) {
		return ConstantsSLB.getSubscriberCharge(addressTypeDeliveryChargeType);
	}    
    
    public decimal getVendorCredit(string addressTypeDeliveryChargeType) {
    	return ConstantsSLB.getVendorCredit(addressTypeDeliveryChargeType);
    }
    
    
  
    //gets the concatenated values of delivery charge, vendor credit and months difference
    public String getDeliveryAndVendorCharge(String chtype, Id recipeint){
        
        //con = [SELECT Id, Name, Contact.Address__r.Id  FROM Contact WHERE Id = :recipeint]; 
        //address = [SELECT Id, Name, Address_Type__c FROM Address__c WHERE Id = :con.Address__r.Id];
        con = [SELECT Id, Name, Contact.Address__r.Address_Type__c  FROM Contact WHERE Id = :recipeint];
        String addressType = con.Address__r.Address_Type__c;
        String delAndvendor = CalculateDeliveryCharge(chtype, addressType);
        
        return delAndvendor;
    }


    public String CalculateDeliveryCharge(String deliveryChargeType, String addressType) {            
        
        String delAndVendorCharge;
        Double deliverycharge;             
        Double vendorCredit;
        
        if(deliveryChargeType == 'H'){
            deliverycharge = (Double) ConstantsSLB.getChargeAmount('DeliveryCharge_H');
            vendorCredit = (Double) ConstantsSLB.getChargeAmount('VendorCredit_H');   
        }     
        else if(deliveryChargeType == 'C'){
            deliverycharge = (Double) ConstantsSLB.getChargeAmount('DeliveryCharge_C');
            vendorCredit = (Double) ConstantsSLB.getChargeAmount('VendorCredit_C');   
        }    
        else if(deliveryChargeType == 'L'){
            deliverycharge = (Double) ConstantsSLB.getChargeAmount('DeliveryCharge_L');
            vendorCredit = (Double) ConstantsSLB.getChargeAmount('VendorCredit_L');   
        }    
        else if(deliveryChargeType == 'S'){
            deliverycharge = (Double) ConstantsSLB.getChargeAmount('DeliveryCharge_S');
            vendorCredit = (Double) ConstantsSLB.getChargeAmount('VendorCredit_S');   
        }
        else if(deliveryChargeType == 'Z'){
            deliverycharge = (Double) ConstantsSLB.getChargeAmount('DeliveryCharge_Z');
            vendorCredit = (Double) ConstantsSLB.getChargeAmount('VendorCredit_Z');   
        } 
        else if(deliveryChargeType == 'N'){
            deliverycharge = (Double) ConstantsSLB.getChargeAmount('DeliveryCharge_N');
            vendorCredit = vendorCreditAddType(addressType);
        }                   
        else if(deliveryChargeType == '9'){
            deliverycharge = (Double) ConstantsSLB.getChargeAmount('DeliveryCharge_9');
            vendorCredit = vendorCreditAddType(addressType);
        }
        
        String concatenated = deliverycharge + ',' + vendorCredit;
        return concatenated ;
    }
    
    public Double vendorCreditAddType(String AddressType){
        
        Double vendorCredit;
        
        //Determines what value must be returned for the specified Address Type of the recipient
        if(AddressType == 'P'){
            vendorCredit = (Double) ConstantsSLB.getChargeAmount('AddressType_P');               
        }
        else if(AddressType == 'B'){
            vendorCredit = (Double) ConstantsSLB.getChargeAmount('AddressType_B');               
        }
        else if(AddressType == 'W'){
            vendorCredit = (Double) ConstantsSLB.getChargeAmount('AddressType_W');
        }
        else if(AddressType == 'H'){
            vendorCredit = (Double) ConstantsSLB.getChargeAmount('AddressType_H');
        }
        else if(AddressType == 'K'){
            vendorCredit = (Double) ConstantsSLB.getChargeAmount('AddressType_K');
        }
        else if(AddressType == 'A'){
            vendorCredit = (Double) ConstantsSLB.getChargeAmount('AddressType_A');
        }
        else if(AddressType == 'C'){
            vendorCredit = (Double) ConstantsSLB.getChargeAmount('AddressType_C');
        }
        else if(AddressType == 'S'){
            vendorCredit = (Double) ConstantsSLB.getChargeAmount('AddressType_S');
        }
        else if(AddressType == 'G'){
            vendorCredit = (Double) ConstantsSLB.getChargeAmount('AddressType_G');
        }
        else if(AddressType == 'U'){
            vendorCredit = (Double) ConstantsSLB.getChargeAmount('AddressType_U');
        }
        
        //returns the value of Vendor Credit
        return vendorCredit;
    }
}