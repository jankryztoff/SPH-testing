/**
* Class Name: <OrderLineItemVendorTriggerHandler>
* @author: <Rom Edison Reyes>
* Date: <3/27/2015>
* Requirement/Project Name: <SPH>
* @description <UD-0647: To restrict order line item (Vendor) fields from being updated based on Publication published days>
* History: 05/Aug/15 D-3382 CCB-135 Wenjun - Move Mailing Agent Assignment Logic to Vendor_Assignment Class
*/
public class OrderLineItemVendorTriggerHandler {
    
    static boolean isTriggerUpdateExecuted = false;	// Start/End UD-1188 12May15 JohnD
    
    List<String> lstPubDays = new List<String>();
    List<Id> listOfPubId = new List<Id>();
    List<Publication__c> lstPubs = new List<Publication__c>(); 
    Map<Id, Publication__c> publications = new Map<Id, Publication__c>();
    String errorMsg = '';
    //START UD-1303 05/21/15 RReyes - adds new list to contain related OLIs to be updated
	Id toBeUpdated = null;
	//END UD-1303 05/21/15 RReyes - adds new list to contain related OLIs to be updated
    
    //BeforeUpdate logic 
    public void doBeforeUpdate(List<Order_Line_Item_Vendor__c> lstNewOliVendor, Map<Id, Order_Line_Item_Vendor__c> mapNewOliVendor,
                               List<Order_Line_Item_Vendor__c> lstOldOliVendor, Map<Id, Order_Line_Item_Vendor__c> mapOldOliVendor)
    {    
        for(Order_Line_Item_Vendor__c newOli : lstNewOliVendor)
        {
            if(newOli.Publication__c != null)
            {
                listOfPubId.add(newOli.Publication__c); 
            }
			//START UD-1303 05/21/15 RReyes - gets the current id of the subscription to be updated
			if(toBeUpdated == null){
				toBeUpdated = newOli.Id;
			}
			//END UD-1303 05/21/15 RReyes - gets the current id of the subscription to be updated
        }
        
        if(listOfPubId.size() > 0)
        {
            lstPubs = [Select Id, Published_Days__c from Publication__c where Id in:listOfPubId];
            
            if(lstPubs.size() > 0)
            {
                for(Publication__c pubs: lstPubs)
                {
                    publications.put(pubs.id, pubs);
                }
                
                if(publications.size() > 0)
                {
                    for(Order_Line_Item_Vendor__c newOliVendor : lstNewOliVendor)
                    {
                        if(newOliVendor.Publication__c != null)
                        {
                            if(publications.containsKey(newOliVendor.Publication__c))
                            {  
                                String pubDay = publications.get(newOliVendor.Publication__c).Published_Days__c;
                                if(pubDay !='' || pubday!= null)
                                {
                                    lstPubDays = splitPublication(pubDay);
                                    errorMsg = checkError(newOliVendor, mapOldOliVendor.get(newOliVendor.Id), lstPubDays);
                                }
                                if(errorMsg != ' ' && errorMsg!= null){
                                    newOliVendor.addError(errorMsg);
                                }
                                else
                                {
                                    System.debug('>>No Error!' + errorMsg);
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Start UD-1188 12May15 JohnD - call updateFields function
        updateFields(lstNewOliVendor);	

    	if (isTriggerUpdateExecuted == false) {
    		updateVendorAssignment(lstNewOliVendor, mapOldOliVendor);
    	}
		// End UD-1188 12May15 JohnD - call updateFields function    	
    }
    
    public List<String> splitPublication(String pubDays)
    {
        List<String> splitPubDays = new List<String>();
        splitPubDays = pubDays.split('');
        splitPubDays.remove(0);
        return splitPubDays;
    }
    
    public string checkError(Order_Line_Item_Vendor__c newOli, Order_Line_Item_Vendor__c oldOli, List<String> lstPubDays)
    {
        String error = ' ';
        Integer errorCount = 0;
        List<String> lstEditable = new List<String>();
        
        if(lstPubDays[0] == 'N'){
            if(newOli.Mon__c != oldOli.Mon__c){
                errorCount++;
            }
        }else{
            lstEditable.add('Mon');
        }
        
        if(lstPubDays[1] == 'N'){
            if(newOli.Tue__c != oldOli.Tue__c){
                errorCount++;
            }
        }else{
            lstEditable.add('Tue');
        }
        
        if(lstPubDays[2] == 'N'){
            if(newOli.Wed__c != oldOli.Wed__c){
                errorCount++;
            }
        }else{
            lstEditable.add('Wed');
        }
        
        if(lstPubDays[3] == 'N'){
            if(newOli.Thu__c != oldOli.Thu__c){
                errorCount++;
            }
        }else{
            lstEditable.add('Thu');
        }
        
        if(lstPubDays[4] == 'N'){
            if(newOli.Fri__c != oldOli.Fri__c){
                errorCount++;
            }
        }else{
            lstEditable.add('Fri');
        }
        
        if(lstPubDays[5] == 'N'){
            if(newOli.Sat__c != oldOli.Sat__c){
                errorCount++;
            }
        }else{
            lstEditable.add('Sat');
        }
        
        if(lstPubDays[6] == 'N'){
            if(newOli.Sun__c != oldOli.Sun__c){
                errorCount++;
            }
        }else{
            lstEditable.add('Sun');
        }
        
        if(errorCount > 0 && lstEditable.size() > 0)
        {
            error += 'You can only edit values for the following fields: ';
            for(Integer x = 0; x < lstEditable.size(); x++)
            {
                if(!(x == lstEditable.size() - 1))
                {
                    error += lstEditable[x] + ', ';
                }
                else
                {
                    error += lstEditable[x];
                }
            }
        }
        return error;
    }
    
    //Logic for AfterUpdate - Leave blank for not in use
    public void doAfterUpdate(List<Order_Line_Item_Vendor__c> lstNewOliVendor, Map<Id, Order_Line_Item_Vendor__c> mapNewOliVendor,
                              List<Order_Line_Item_Vendor__c> lstOldOliVendor, Map<Id, Order_Line_Item_Vendor__c> mapOldOliVendor)
    {}
    
    
    //Logic for BeforeInsert - Leave blank if not in use
    public void doBeforeInsert(List<Order_Line_Item_Vendor__c> lstNewOliVendor)
    {
    	updateFields(lstNewOliVendor);	// Start/End UD-1188 11May15 JohnD - call updateFields function
    }
    
    //Logic for AfterInsert - Leave blank if not in use
    public void doAfterInsert(List<Order_Line_Item_Vendor__c> lstNewOliVendor, Map<Id, Order_Line_Item_Vendor__c> mapNewOliVendor)
    {}
    
    //Logic for BeforeDelete - Leave blank if not in use
    public void doBeforeDelete(List<Order_Line_Item_Vendor__c> lstOldOliVendor, Map<Id, Order_Line_Item_Vendor__c> mapOldOliVendor)
    {}    
    
    //Logic for BeforeDelete - Leave blank if not in use
    public void doAfterDelete(List<Order_Line_Item_Vendor__c> lstOldOliVendor, Map<Id, Order_Line_Item_Vendor__c> mapOldOliVendor)
    {}

    // Start UD-1188 11May15 JohnD - added logic to set fields values
    private void updateFields(list<Order_Line_Item_Vendor__c> orderLineItemVendorList) {
    	 
    	set<id> sundayPublicationIdSet = new set<id>();
    	set<id> publicationIdSet = new set<id>();

    	for (Order_Line_Item_Vendor__c oliv : orderLineItemVendorList) {
    		
    		if (oliv.Publication__c != null) {
    			publicationIdSet.add(oliv.Publication__c);
    		}
    		
    	}
    	
    	for (Publication__c pub : [select Id from Publication__c where Id in :publicationIdSet and Published_Days__c = 'NNNNNNY']) {
    		sundayPublicationIdSet.add(pub.Id);
    	}
    	
    	for (Order_Line_Item_Vendor__c oliv : orderLineItemVendorList) {
    		
    		if (sundayPublicationIdSet != null && !sundayPublicationIdSet.isEmpty() && sundayPublicationIdSet.contains(oliv.Publication__c)) {
    			oliv.Mon__c = 0;
    			oliv.Tue__c = 0;
    			oliv.Wed__c = 0;
    			oliv.Thu__c = 0;
    			oliv.Fri__c = 0;
    			oliv.Sat__c = 0;
    			oliv.PHd__c = 0;
    			oliv.PHe__c = 0;
    		}
    	}
    }
    // End UD-1188 11May15 JohnD - added logic to set fields values
    
    // Start UD-1188 12May15 JohnD - added logic to update the vendor
    private void updateVendorAssignment(list<Order_Line_Item_Vendor__c> orderLineItemVendorListParam, 
    		map<id, Order_Line_Item_Vendor__c> orderLineItemVendorId_orderLineItemVendorParam) {
    	
    	map<id, id> orderId_vendorId = new map<id, id>();
    	list<Subscription_Vendor__c> subscriptionVendorList = new list<Subscription_Vendor__c>();
    	list<Order__c> orderList = new list<Order__c>();
    	list<Order_Line_Item_Vendor__c> orderLineItemVendorList = new list<Order_Line_Item_Vendor__c>();
    	list<Case> caseList = new list<Case>();
    	list<Exception> exceptionList = new list<Exception>();
    	set<id> orderLineItemVendorIdSet = orderLineItemVendorId_orderLineItemVendorParam.keySet();
    	
    	Order_Line_Item_Vendor__c oldOrderLineItemVendor;

    	for (Order_Line_Item_Vendor__c oliv : orderLineItemVendorListParam) {
    		
    		oldOrderLineItemVendor = orderLineItemVendorId_orderLineItemVendorParam.get(oliv.Id);
    		
    		if (oliv.Vendor__c != oldOrderLineItemVendor.Vendor__c) {
    			orderId_vendorId.put(oliv.Order__c, oliv.Vendor__c);
    		}
    	}
    	
    	if (orderId_vendorId != null && !orderId_vendorId.isEmpty()) {
    		
    		for (Subscription_Vendor__c sv : [select Id, Vendor__c, Order_Number__c from Subscription_Vendor__c 
    				where Order_Number__c in :orderId_vendorId.keySet()]) {
    					
    			sv.Vendor__c = orderId_vendorId.get(sv.Order_Number__c);
    			subscriptionVendorList.add(sv);
    		}
    		
    		for (Order__c o : [select Id, Status__c from Order__c where Id in :orderId_vendorId.keySet()]) {
    			
    			if (orderId_vendorId.get(o.Id) == null) {
    				o.Status__c = GlobalVariableClass.STATUS_PENDING_VENDOR_ASSIGN;
    			} else {
    				o.Status__c = GlobalVariableClass.STATUS_CLOSE;
    			}
    			
    			orderList.add(o);
    		}
    		
    		for (Order_Line_Item_Vendor__c oliv : [select Id, Vendor__c, Order__c from Order_Line_Item_Vendor__c 
    				where Order__c in :orderId_vendorId.keySet()]) {
    			
    			if (!orderLineItemVendorIdSet.contains(oliv.Id)) {
    				oliv.Vendor__c = orderId_vendorId.get(oliv.Order__c);
    			}
    			//START UD-1303 05/21/15 RReyes - prevents adding the current OLI to be updated
    			
				if(oliv.Id != toBeUpdated){
                 orderLineItemVendorList.add(oliv);}
				//END UD-1303 05/21/15 RReyes - prevents adding the current OLI to be updated
    		}
    		
    		for (Case c : [select Id, Status, Sub_Status__c, Order__c from Case where Order__c in :orderId_vendorId.keySet()]) {
    			
    			if (orderId_vendorId.get(c.Order__c) == null) {
    				c.Status = GlobalVariableClass.STATUS_PENDING;
    				c.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
    			} else {
    				c.Status = GlobalVariableClass.STATUS_CLOSED;
    				c.Sub_Status__c = GlobalVariableClass.SUB_STATUS_SUBS_CREATED;
    			}
    			
    			caseList.add(c);
    		}
    		
    		if (!subscriptionVendorList.isEmpty()) {
    			
    			try {
    				update subscriptionVendorList;
    			} catch (exception e) {
    				exceptionList.add(e);
    			}
    		}
    		
    		if (!orderList.isEmpty()) {
    			try {
    				update orderList;
    			} catch (exception e) {
    				exceptionList.add(e);
    			}
    		}

    		if (!orderLineItemVendorList.isEmpty()) {
    			try {
    				update orderLineItemVendorList;
    			} catch (exception e) {
    				exceptionList.add(e);
    			}
    		}

    		if (!caseList.isEmpty()) {
    			try {
    				update caseList;
    			} catch (exception e) {
    				exceptionList.add(e);
    			}
    		}
    		
    		if (!exceptionList.isEmpty()) {
    			ExceptionLogger.log(exceptionList);
    		}
    	}
    	
    	isTriggerUpdateExecuted = true;
    }
    // End UD-1188 12May15 JohnD - added logic to update the vendor
}