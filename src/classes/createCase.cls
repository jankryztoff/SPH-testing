public class createCase {
    
    public List<Case> createCase2(List<Order__c> orderList, boolean bDirect ) {
        List<Case> caseList = new List<Case>();
        Set<Id> sUrgentOrder = new Set<Id>();
        Set<Id> unAssignedOrders = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        Map<Id, Id> orderIdToCaseIdMap = new Map<Id, Id>();
        
        for(Order__c order : orderList) {
            orderIds.add(order.Id);
        }
        
        for(Case cas : [SELECT Id, Order__c FROM Case WHERE RecordTypeId = :ConstantsSLB.getKeyId(GlobalVariableClass.RECTYPE_START_SUBSCRIPTION) AND Status = :GlobalVariableClass.STATUS_PENDING AND Category__c = :GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST AND Sub_Category__c = :GlobalVariableClass.SUBCATEGORY_START_SUBCRIPTION AND Subject = :GlobalVariableClass.SUBJECT_START_SUBSCRIPTION]) {
            orderIdToCaseIdMap.put(cas.Order__c, cas.Id);
        }

        if(bDirect) {
            for(Order_Line_Item__c OLI :[SELECT Order__c, Order__r.Parent_Case__c, Urgent__c FROM Order_Line_Item__c WHERE Order__c in: orderList ]) {
                if (OLI.Urgent__c == True) {
                    sUrgentOrder.add(OLI.Order__c);
                } 
                //START: D-1089 12/19/14 Added by April Banaag - to apply "Waiting for vendor assignment" scenario to direct start sub
                //END: D-1089 12/19/14 Added by April Banaag - to apply "Waiting for vendor assignment" scenario to direct start sub
            }
        }
        else {
            for(Order_Line_Item_Vendor__c OLI :[select Order__c, Vendor__c, Urgent__c FROM Order_Line_Item_Vendor__c WHERE Order__c in: orderList ]) {
                if (OLI.Urgent__c == True) {
                    sUrgentOrder.add(OLI.Order__c);
                }
                //START D-2046 05/Feb/15 Wenjun: Comment out the code as need to create Subscription 1st. 
                //There are logic in CaseTriggerHandler to set "Pending Vendor Assignment"
                /* added logic for checking if order line items have vendors assigned */
                /*
                if(OLI.Vendor__c == NULL) {
                    unAssignedOrders.add(OLI.Order__c);
                } 
                */              
                //END D-2046 05/Feb/15 Wenjun               
                /*--------------------------------------------------------------------*/
            }
        }
        
        for(Order__c orderRecord : orderList) {   
            //forced Variables
            Case caseRec = new Case();
            if(orderIdToCaseIdMap.containsKey(orderRecord.Id)) {
                caseRec = new Case(Id=orderIdToCaseIdMap.get(orderRecord.Id));
            }
            caseRec.Subject = GlobalVariableClass.SUBJECT_START_SUBSCRIPTION;      
            caseRec.RecordTypeID = ConstantsSLB.getKeyId(GlobalVariableClass.RECTYPE_START_SUBSCRIPTION);
            caseRec.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
            caseRec.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_START_SUBCRIPTION;
            caseRec.Status = GlobalVariableClass.STATUS_PENDING;
            
            if(sUrgentOrder.contains(orderRecord.Id)){
                caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_URGENT_START;
                //START D-2212 03-06-2015 Marvin Gatchalian
                caseRec.Urgent_Request__c = true;
                //END D-2212 03-06-2015 Marvin Gatchalian
            }
            /* added logic for setting status based on vendor assignment */
            else {
                //START: D-1089 12/19/14 Added by April Banaag - add logic for analyzing if case is waiting for vendor assignment
                //orderrecord.Recipient_Contact__c 
                LIST<Contact> conList = [SELECT id, Address__c FROM Contact where Id =: orderRecord.Recipient_Contact__c ];
                //Start: D-1409 01/09/15 Added by ABanaag - add error messages for scenarios 
                if(conList.size()>0){
                    ID addressID = conList[0].Address__c;
                
                    LIST<Address__c> adList = [SELECT id, RecordTypeId from Address__c WHERE id =: addressID ];
                    if(adList.size()>0){
                        ID recTypeId = adlist[0].RecordTypeId;
                    
                        // Start D-2005 02/05/2015 JohnD added expression in condition
                        if(unAssignedOrders.contains(orderRecord.Id) && recTypeId == ConstantsSLB.getKeyID('Address_Local') 
                                && orderRecord.No_Vendor_Needed__c == false){
                            
                            caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
                        // End D-2005 02/05/2015 JohnD
                        }
                        else {
                            //START UD-1451 06/12/15 RReyes - added condition if not direct account
							if(!bDirect){
								caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_SUBS_CREATED;	
							}
							else{
								caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
							}
							//END UD-1451 06/12/15 RReyes - added condition if not direct account
                        }
                    }
                    else{
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Contact has no address.');
                        ApexPages.addMessage(myMsg);
                    }
                }
                else{
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Order has no recipient contact.');
                    ApexPages.addMessage(myMsg);
                }
                //END: D-1409 01/09/15 Added by ABanaag - add error messages for scenarios 
                //END: D-1089 12/19/14 Added by April Banaag - add logic for analyzing if case is waiting for vendor assignment
            }
            /*--------------------------------------------------------------------*/
            
            //values taken from the order object
            caseRec.Order__c = orderRecord.Id;
            caseRec.AccountId = orderRecord.Account__c;
            caseRec.Description = orderRecord.Remarks__c;
            caseRec.Origin = orderRecord.Acquisition_Type__c;
            caseRec.Recipient__c = orderRecord.Recipient_Contact__c;
            //Start: D-1456 01/07/15 Added by ABanaag
            LIST<Contact> conList = [SELECT id, Address__c FROM Contact WHERE id =: orderRecord.Recipient_Contact__c ];
            if (conList.size()>0){
                Id recAddId = conlist[0].address__c;
                caseRec.Recipient_Address__c = recAddId;
            }
            //End: D-1456 01/07/15 Added by ABanaag
            
            
            if (orderRecord.Parent_Case__c != 'null') {
                caseRec.ParentId = orderRecord.Parent_Case__c;
            }
            
            try {
                 if(orderRecord.Parent_Case__c != null || orderRecord.Parent_Case__c != 'null') {
                    caseRec.ParentId = orderRecord.Parent_Case__c;                    
                 }                     
            }
            catch(Exception e) {
                system.debug(orderRecord.Parent_Case__c);               
            }
                                           
            if(bDirect){
                caseRec.Subscriber__c = orderRecord.Billing_Contact__c;                
            }
        
            caseList.add(caseRec);
        }
        
        upsert caseList;
        
        Map<id,id> mapCase_Order = new Map<Id,Id>();
        Map<id,id> mapCase_Order_Opp = new Map<Id,Id>();
        set<id> orderIdSet = new set<Id>();
        for(Case c: caseList){
            mapCase_Order.PUT(c.Order__c, c.Id);
        }
               
        UpdateOrderLineItems(mapCase_Order, bDirect);
        
        return  caseList;
    }
    
        
        /* @Description: Method for Creation of Case in Stop Subscription Scenario
        *  @Parameters: List<Order__c> orderList, Boolean Direct 
        *  @Return : List<Case> caseList
        */
    public List<Case> createCaseForStopSubscription(List<Order__c> orderList, boolean bDirect) {
        // START : D-1359 2/11/2015 Alyana Navarro
        Boolean isExisting = false;
        Set<String> accountSet = new Set<String>();
        List<Case> existingCaseList = new List<Case>();
        // END : D-1359 2/11/2015       
        List<Case> caseList = new List<Case>();
        Set<Id> sUrgentOrder = new Set<Id>();
        Set<Id> sWaiveOrder = new Set<Id>();
        Set<Id> unAssignedOrders = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        Map<Id, Case> orderIdToCaseIdMap = new Map<Id, Case>(); // START-END : D-1359 2/11/2015 Alyana Navarro
        Map<id,id> mapCase_Order = new Map<Id,Id>();
        Map<id,id> mapCase_Order_Opp = new Map<Id,Id>();
        set<id> orderIdSet = new set<Id>();
        
		//START:D-3308 8/6/2015 Added by Manolo Valena - new maps.
        Map<Id, Date> orderToEarliestDate = new Map<Id, Date>();
        Map<Id, Date> orderToStopDate = new Map<Id, Date>();
        //END:D-3308 8/6/2015 Added by Manolo Valena
		
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION).getRecordTypeId(); 
        
        for(Order__c order : orderList) {
            orderIds.add(order.Id);
            accountSet.add(order.account__c); // START-END : D-1359 2/12/2015 Alyana Navarro
            //START: D- 1323 2/5/2015 Added by Kristine Campang - added condition for vendor account
            if(bDirect != true){
                System.debug('vendor order entered');
                if(order.Urgent_Stop__c == true){
                    System.debug('urgent order entered');
                    sUrgentOrder.add(order.Id);
                }
            }
            //END: D- 1323 2/5/2015 Added by Kristine Campang
        }
        
    // START : D-1359 2/11/2015 Alyana Navarro
        existingCaseList = [SELECT Id, Order__c, Sub_Status__c, Status, Subject, RecordTypeID, Category__c, Sub_Category__c, Subscriber__c,
                            Description, Origin, Recipient_Address__c, Eligible_for_Retention_Offer__c, Send_To_Retention__c, Order_Number__c,
                            AccountId, Recipient__c, Urgent_Request__c, Waived_Request__c, ParentId, Stop_Waive_Request__c
                            FROM Case 
                            WHERE RecordTypeId = :rtId AND Status = :GlobalVariableClass.STATUS_PENDING 
                                AND Category__c = :GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST 
                                AND Sub_Category__c = :GlobalVariableClass.SUBCATEGORY_STOP_SUBCRIPTION AND AccountId IN : accountSet];
        
        for(Case cas : existingCaseList){
            orderIdToCaseIdMap.put(cas.Order__c, cas);
            //START:UD-1152 5/8/2015 Added by Manolo Valena - removed assignment of true value to boolean variable. User must still be able to create new stop case while there is another existing pending stop case.
            //isExisting = true;
            //END:UD-1152 5/8/2015 Added by Manolo Valena
        }
    // END : D-1359 2/11/2015
        
        

        for(Order_Line_Item__c OLI :[SELECT Order__c, Urgent_Stop__c, Fee_Waiver__c FROM Order_Line_Item__c WHERE Order__c in: orderList ]) {
            if (OLI.Urgent_Stop__c == True) {
                sUrgentOrder.add(OLI.Order__c);
            }
            
            //this should be removed for Stop - Vendor Subscription
            if (OLI.Fee_Waiver__c == True) {
                sWaiveOrder.add(OLI.Order__c);
            }
        }
		//START:UD-1341 5/21/2015 Added by Manolo Valena - get Urgent Orders for OLIV.
        //START:D-3308 8/6/2015 Added by Manolo Valena - Added Earliest_Stop_Date__c and Stop_Request_Date__c in the query.
        for(Order_Line_Item_Vendor__c OLI :[select Order__c, Vendor__c, Urgent__c, Earliest_Stop_Date__c, Stop_Request_Date__c FROM Order_Line_Item_Vendor__c WHERE Order__c in: orderList ]) {
        //END:D-3308 8/6/2015 Added by Manolo Valena
            if (OLI.Urgent__c == True) {
                sUrgentOrder.add(OLI.Order__c);
            }
			
			//START:D-3308 8/6/2015 Added by Manolo Valena - Put earliest date in map.
            if(orderToEarliestDate.containsKey(OLI.Order__c)) {
                if(OLI.Earliest_Stop_Date__c < orderToEarliestDate.get(OLI.Order__c)) {
                    orderToEarliestDate.put(OLI.Order__c, OLI.Earliest_Stop_Date__c);
                    orderToStopDate.put(OLI.Order__c, OLI.Stop_Request_Date__c);
                }
            }
            else {
                orderToEarliestDate.put(OLI.Order__c, OLI.Earliest_Stop_Date__c);
                orderToStopDate.put(OLI.Order__c, OLI.Stop_Request_Date__c);
            }
            //END:D-3308 8/6/2015 Added by Manolo Valena
        }
        //END:UD-1341 5/21/2015 Added by Manolo Valena

        for(Order__c orderRecord : orderList) {   
            //forced Variables
            Case caseRec = new Case();
            if(orderIdToCaseIdMap.containsKey(orderRecord.Id)) {
                // START : D-1359 2/11/2015 Alyana Navarro
                caseRec = orderIdToCaseIdMap.get(orderRecord.Id);                
                isExisting = true;
                // END : D-1359 2/11/2015
            }
            caseRec.Subject = GlobalVariableClass.SUBJECT_STOP_SUBSCRIPTION;      
            caseRec.RecordTypeID = rtId;
            caseRec.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
            caseRec.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_STOP_SUBCRIPTION;
            //START: D-1287 1/6/2015 Added by Kristine Campang- changed case status and substatus   
            //START: D-1336 1/8/2015 Added by Kristine Campang - added conditions for vendor
            //direct
            if(bDirect){
                caseRec.Subscriber__c = orderRecord.Billing_Contact__c;  
                caseRec.Description = orderRecord.Remarks__c; 
                caseRec.Origin = orderRecord.Acquisition_Type__c;
                caseRec.Recipient_Address__c = orderRecord.Recipient_Contact__r.Address__c;
                // START : D-1359 2/10/2015 Alyana Navarro - Remodified if condition.
                //START: D- 1625 1/23/2015 Added by Kristine Campang - modified if condition
                
                if(!isExisting){
                    if(orderRecord.Eligible_for_Retention__c){
                        caseRec.Eligible_for_Retention_Offer__c = true;
                        if(orderRecord.Send_to_Retention__c){
                            caseRec.Status = GlobalVariableClass.STATUS_PENDING;
                            caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_FOR_RETENTION_OFFER;
                            caseRec.Send_To_Retention__c = true;
                            //caseRec.Owner = 'Retention Que'; //change to Queue   // --For deletion
                        }
                    }               
                //END: D-1625 1/23/2015 Added by Kristine Campang                               
                    if(!orderRecord.Send_To_Retention__c){
                        if(sUrgentOrder.contains(orderRecord.Id) || orderRecord.Stop_Request_Date__c < orderRecord.Earliest_Stop_Date__c){
                                caseRec.Status = GlobalVariableClass.STATUS_PENDING;
                                caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_URGENT_STOP;
                        }
                        //this should be removed for Stop - Vendor subscription
                        else if(sWaiveOrder.contains(orderRecord.Id)){
                            caseRec.Status = GlobalVariableClass.STATUS_PENDING;
                            caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_WAIVED;
                        }
                        else {
                        	// Start D-2660 01Apr15 JohnD changed the Status and Sub Status value
                            caseRec.Status = GlobalVariableClass.STATUS_PENDING;
                            caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_READY_FOR_SUBMISSION;
                            // End D-2660 01Apr15 JohnD changed the Status and Sub Status value
                        }
                    }
                
                }
        // END : D-1359 2/10/2015
            }
            //vendor
            else{
                //START:D-3308 8/6/2015 Added by Manolo Valena - Updated if condition.
				//START: D-4087 12/15/15 Added by Manolo Valena - Urgent Stop should be less than or equal to.
                if(sUrgentOrder.contains(orderRecord.Id) && orderToStopDate.get(orderRecord.Id) <= orderToEarliestDate.get(orderRecord.Id)){
                //END: D-4087 12/15/15 Added by Manolo Valena
				//END:D-3308 8/6/2015 Added by Manolo Valena
                        caseRec.Status = GlobalVariableClass.STATUS_PENDING;
                        caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_URGENT_STOP;
                }
                else {
                    caseRec.Status = GlobalVariableClass.STATUS_CLOSED;
                    caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_STOP_COMPLETED;
                }
            }

            //END: D-1287 1/6/2015 Added by Kristine Campang- changed case status and substatus 
            //values taken from the order object
            caseRec.Order__c = orderRecord.Id;
            caseRec.Order_Number__c = orderRecord.Id;
            caseRec.AccountId = orderRecord.Account__c;
            caseRec.Recipient__c = orderRecord.Recipient_Contact__c;
            caseRec.Urgent_Request__c = false;
            caseRec.Waived_Request__c = false;
            if (orderRecord.Parent_Case__c != 'null') {
                caseRec.ParentId = orderRecord.Parent_Case__c;
            }

            //for checkboxes in Case
            if(sUrgentOrder.contains(orderRecord.Id)){
                caseRec.Urgent_Request__c = true;
            }
            if(sWaiveOrder.contains(orderRecord.Id)){
                caseRec.Stop_Waive_Request__c = true;
            }
            //END: D-1336 1/8/2015 Added by Kristine Campang
            caseList.add(caseRec);
        }
        if(caseList.size()>0){
            upsert caseList;
        }   
        
        //START: D-1623 01/14/2014 Added by S.Puli
        //START: D-1323 2/5/2015 Added by Kristine Campang - limit operation to direct accounts
        List<Order_Line_Item__c> oliLIST = [Select Id, Name, Subscription__c, Order__c From Order_Line_Item__c Where Order__c IN :orderIds];
        Map<Id, Id> caseSubMap = new Map<Id, Id>();
        List<Case_Subscription__c> caseSubList = new List<Case_Subscription__c>();
        
        if(oliLIST<>null && oliLIST.size()>0){
            for(Order_Line_Item__c oli : oliLIST){
                caseSubMap.put(oli.Id, oli.Subscription__c);
            }
        }
        //END: D-1323 2/5/2015 Added by Kristine Campang
        //END: D-1623 01/14/2014 Added by S.Puli
        
        for(Case c: caseList){
            mapCase_Order.PUT(c.Order__c, c.Id);
            //START: D-1623 01/14/2014 Added by S.Puli
            //START: D-1323 2/5/2015 Added by Kristine Campang - limit operation to direct accounts
                if(bDirect){
            Case_Subscription__c csRec = new Case_Subscription__c();
            csRec.Case__c = c.Id;
            for(Order_Line_Item__c oliRec : [Select Id, Name, Order__c From Order_Line_Item__c Where Order__c = :c.Order__c]){
                csRec.Subscription__c = caseSubMap.get(oliRec.Id);
                csRec.Account__c = c.AccountId;
            }
            caseSubList.add(csRec);
                }
            //END: D-1323 2/5/2015 Added by Kristine Campang 
            //END: D-1623 01/14/2014 Added by S.Puli
        }
        
        //START: D-1623 01/14/2014 Added by S.Puli
        //START: D-1323 2/5/2015 Added by Kristine Campang - checks whether caseSubList is not null
        if(caseSubList.size()>0){
        //START UD-1677 6/18/15 Added by Manolo Valena - Commented out. Please do not delete.
		//insert caseSubList;
        //END UD-1677 6/18/15 Added by Manolo Valena
		}
        //END: D-1323 2/5/2015 Added by Kristine Campang 
        //END: D-1623 01/14/2014 Added by S.Puli
        
        //this methods ties the Order Line Items to the created Case
        UpdateOrderLineItems(mapCase_Order,bDirect);
        return  caseList;
    }


    /*
    *   @description : this method will create a case for renewal of subscription scenario
    *   @author : JohnD
    *   @lastupdate : 9/26/214
    */
    public List<Case> createCaseRenewal(List<Order__c> orderList, boolean bDirect ) {
        List<Case> caseList = new List<Case>();
        Set<Id> sUrgentOrder = new Set<Id>();
        Set<Id> unAssignedOrders = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        Map<Id, Id> orderIdToCaseIdMap = new Map<Id, Id>();
        
        for(Order__c order : orderList) {
            orderIds.add(order.Id);
        }
        
        for(Case cas : [SELECT Id, Order__c, Subscriber__c, Subscription_Name__c FROM Case WHERE RecordTypeId = :ConstantsSLB.getKeyId('Renewal of Subscription') AND Status = 'New' AND Category__c = 'Subscription Request' AND Sub_Category__c = 'Renewal of Subscription' AND Subject = 'Renewal of Subscription']) {
            orderIdToCaseIdMap.put(cas.Order__c, cas.Id);
        }

        
        
        if(bDirect) {
            for(Order_Line_Item__c OLI :[SELECT Order__c, Urgent__c FROM Order_Line_Item__c WHERE Order__c in: orderList ]) {
                if (OLI.Urgent__c == True) {
                    sUrgentOrder.add(OLI.Order__c);
                }                                   
            }
        }
        else {
            for(Order_Line_Item_Vendor__c OLI :[select Order__c, Vendor__c, Urgent__c FROM Order_Line_Item_Vendor__c WHERE Order__c in: orderList ]) {
                if (OLI.Urgent__c == True) {
                    sUrgentOrder.add(OLI.Order__c);
                }
                /* added logic for checking if order line items have vendors assigned */
                if(OLI.Vendor__c == NULL) {
                    unAssignedOrders.add(OLI.Order__c);
                }                             
                /*--------------------------------------------------------------------*/
            }
        }
        
        for(Order__c orderRecord : orderList) {   
            //forced Variables
            Case caseRec = new Case();
            if(orderIdToCaseIdMap.containsKey(orderRecord.Id)) {
                caseRec = new Case(Id=orderIdToCaseIdMap.get(orderRecord.Id));
            }
            caseRec.Subject = 'Renewal of Subscription';      
            caseRec.RecordTypeID = ConstantsSLB.getKeyId('Renewal of Subscription');
            caseRec.Category__c = 'Subscription Request';
            caseRec.Sub_Category__c = 'Renewal of Subscription';
            caseRec.Status = 'Pending';
            
            if(sUrgentOrder.contains(orderRecord.Id)){
                caseRec.Sub_Status__c = 'Waiting for Urgent Start Approval';
                //START D-2212 03-06-2015 Marvin Gatchalian
                caseRec.Requires_Urgent_Approval__c = true;
                //END D-2212 03-06-2015 Marvin Gatchalian
            }
            /* added logic for setting status based on vendor assignment */
            else {
                caseRec.Sub_Status__c = 'Provisioning';
            }
            /*--------------------------------------------------------------------*/
            
            //values taken from the order object
            caseRec.Order__c = orderRecord.Id;
            caseRec.Order_Number__c = orderRecord.Id;
            caseRec.AccountId = orderRecord.Account__c;
            caseRec.Description = orderRecord.Remarks__c;
            caseRec.Origin = orderRecord.Acquisition_Type__c;
            caseRec.Recipient__c = orderRecord.Recipient_Contact__c;
            //caseRec.Subscriber__c = orderRecord.Recipient_Contact__c;
            caseRec.Subscription_Name__c = orderRecord.Base_Subscription__c;     
            caseRec.Recipient_Address__c = orderRecord.Recipient_Contact__r.Address__c;
            
            
            if(bDirect && orderRecord.Billing_Contact__c != null){
                caseRec.Subscriber__c = orderRecord.Billing_Contact__c;                
            }
            else {
                caseRec.Subscriber__c = orderRecord.Recipient_Contact__c;
            }
        
            caseList.add(caseRec);
        }

        if(caseList.size() > 0) {
            upsert caseList;
        }

        Map<id,id> mapCase_Order = new Map<Id,Id>();
        Map<id,id> mapCase_Order_Opp = new Map<Id,Id>();
        set<id> orderIdSet = new set<Id>();
        for(Case c: caseList){
            mapCase_Order.PUT(c.Order__c, c.Id);
        }
               
        UpdateOrderLineItems(mapCase_Order, bDirect);
        
        return  caseList;
    }

    public void UpdateOrderLineItems(Map<id,id> mapCase_Order, boolean bDirect){
        
        
        if(bDirect){
            List<Order_Line_Item__c> orderLineItemToBeUpdatedList= new List<Order_Line_Item__c>();
            
            for(Order_Line_Item__c OLI :[SELECT Id, Order__c, Case__c, Urgent__c 
                                               FROM Order_Line_Item__c
                                               WHERE Order__c in:mapCase_Order.keyset() ]){                                                
               
                OLI.case__c =  mapCase_Order.get(OLI.Order__c);
                orderLineItemToBeUpdatedList.add(OLI);                                   
            }
            
            update orderLineItemToBeUpdatedList;   
            
        }else{
            List<Order_Line_Item_Vendor__c> orderLineItemVendorToBeUpdatedList= new List<Order_Line_Item_Vendor__c>();
            for(Order_Line_Item_Vendor__c OLIV :[SELECT Id, Order__c, Case__c, Urgent__c 
                                               FROM Order_Line_Item_Vendor__c
                                               WHERE Order__c in:mapCase_Order.keyset() ]){
                OLIV.Case__c = mapCase_Order.get(OLIV.Order__c);
                orderLineItemVendorToBeUpdatedList.add(OLIV);                                   
            }
            update orderLineItemVendorToBeUpdatedList; 
        }
    } 
     
    public List<Case> createCaseForChangeOfSubscription(List<Order__c> orderList, boolean bDirect) {
        List<Case> caseList = new List<Case>();
        Set<Id> sUrgentOrder = new Set<Id>();
        Set<Id> sWaiveOrder = new Set<Id>();
        Set<Id> unAssignedOrders = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        Map<Id, Id> orderIdToCaseIdMap = new Map<Id, Id>();
        //START D-1942 Francis Benzon 1/28/2015 : Variable
        String addressLocal = GlobalVariableClass.CS_ADDRESSLOCAL;
        //END D-1942 Francis Benzon 1/28/2015 Variable
        //START D-2027 Wenjun 05/02/15 : List to Store Order Line Items
        List<Order_Line_Item__c> lstOrderLineItems = new List<Order_Line_Item__c>();
        //END D-2027 Wenjun 05/02/15
    
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION).getRecordTypeId(); 
        
        //START: D-802 12/10/14 Added by S.Puli - add condition for multiple vendor
            Contact conRec;
            if(orderList[0].Recipient_Contact__r.Id<>null){
                //START D-1942 Francis Benzon 1/28/2015 : updated query for additional needed fields
                conRec = [Select Id, Name, Address__r.Postal_Code__c, Address__c, Address__r.RecordTypeId
                            From Contact 
                            Where Id = :orderList[0].Recipient_Contact__r.Id];
                //END D-1942 Francis Benzon 1/28/2015 : updated query for additional needed fields
            }
            List<Vendor_Allocation__c> vaList = [Select ID, Name, SingPost_Address__c From Vendor_Allocation__c Where SingPost_Address__c = :conRec.Address__r.Postal_Code__c];
        //END: D-802 12/10/14 Added by S.Puli
        
        for(Order__c order : orderList) {
            orderIds.add(order.Id);
        }
        
        for(Case cas : [SELECT Id, Order__c FROM Case WHERE RecordTypeId = :rtId AND Status = :GlobalVariableClass.STATUS_PENDING 
                AND Category__c = :GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST 
                AND Sub_Category__c = :GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION]) {
                    
            orderIdToCaseIdMap.put(cas.Order__c, cas.Id);
        }

        //START D-2027 Wenjun 05/02/15 : Store Order Line Items for Update
        lstOrderLineItems = [SELECT Order__c, Urgent__c, Fee_Waiver__c FROM Order_Line_Item__c WHERE Order__c in: orderList];
        for(Order_Line_Item__c OLI :lstOrderLineItems) {
        //END D-2027 Wenjun 05/02/15
            if (OLI.Urgent__c == True) {
                sUrgentOrder.add(OLI.Order__c);
            }
            
            //this should be removed for Stop - Vendor Subscription
            if (OLI.Fee_Waiver__c == True) {
                sWaiveOrder.add(OLI.Order__c);
            }
        }

        for(Order__c orderRecord : orderList) {   
            //forced Variables
            Case caseRec = new Case();
            if(orderIdToCaseIdMap.containsKey(orderRecord.Id)) {
                caseRec = new Case(Id=orderIdToCaseIdMap.get(orderRecord.Id));
            }
            caseRec.Subject = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
            caseRec.Reason_Code__c = orderRecord.Reason_Code__c;
            caseRec.RecordTypeID = rtId;
            caseRec.Remarks__c = orderRecord.Remarks__c;
            caseRec.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
            caseRec.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_CHANGE_OF_SUBCRIPTION;
            caseRec.Status = GlobalVariableClass.STATUS_PENDING;
            caseRec.Creation_Mode__c = orderRecord.Creation_Mode__c;
            caseRec.Action_Type__c = orderRecord.Order_Action__c;
                //START 01/23/15 D-1802 Jerella - Request_for_Waiving_of_Admin_Charge and Admin_Charge fields populated on caseRec
                caseRec.Admin_Charges__c = orderRecord.Admin_Charge__c;
                caseRec.Request_for_Waiving_of_Admin_Charge__c = orderRecord.Request_for_Waiving_of_Admin_Charge__c;
                //END 01/23/15 D-1802 Jerella - Request_for_Waiving_of_Admin_Charge and Admin_Charge fields populated on caseRec
            caseRec.Effective_Date__c = orderRecord.Effective_Date__c;

            if (sWaiveOrder.contains(orderRecord.Id)) {
                //START UD-0778 4/29/2015 Added by Manolo Valena - Removed string and get string value from globalvariableclass
                caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_WAIVED;
				//END UD-0778 4/29/2015 Added by Manolo Valena
            } else if (sUrgentOrder.contains(orderRecord.Id)) {
                caseRec.Sub_Status__c = 'Waiting for Urgent Approval';
            // Start D-2005 02/08/2015 JohnD added condition for non vendor order
            } else if (orderRecord.No_Vendor_Needed__c == true) {
                caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
            // End D-2005 02/08/2015 JohnD
            } else {
                //START: D-802 12/10/14 Added by S.Puli - add condition for multiple vendor
                if(vaList.size() <> 1){
                    for(Order_Line_Item__c OLI : [Select Effective_Date__c, Qty__c, Vendor_Mailing_Agent__c, Order__c From Order_Line_Item__c Where Order__c =: orderRecord.Id Limit 1]){
                        OLI.Vendor_Mailing_Agent__c = null;
                        //START D-1942 Francis Benzon 1/28/2015 : updated if statement to include variables in GlobalVariableClass
                        //START/END D-2332 3/11/15 AddedBy FrancisBenzon : added additional criteria in If Statement for vendor assignment
                        /*START D-2332 3/11/15 Added By FrancisBenzon : Added criteria so that it will no longer be waiting for vendor assignment, logic is already in CaseTriggerHandler. */
                        if(unAssignedOrders.contains(orderRecord.Id) && OLI.Vendor_Mailing_Agent__c == null && conRec.Address__c != null && conRec.Address__r.RecordTypeId == ConstantsSLB.getKeyID(addressLocal) && orderRecord.No_Vendor_Needed__c == false)
                        {                       
                            caseRec.Sub_Status__c  = 'Waiting for Vendor Assignment';
                        }                       
                         else {                 
                            caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
                        }
                        /*END D-2332 3/11/15 Added By FrancisBenzon : Added criteria so that it will no longer be waiting for vendor assignment, logic is already in CaseTriggerHandler.*/
                        //END D-1942 Francis Benzon 1/28/2015 updated if statement to include variables in GlobalVariableClass
                    }
                }               
                else {  
                //END: D-1409 01/09/15 Added by ABanaag - add error messages for scenarios 
                    caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_PROVISIONING;
                }
                //END: D-802 12/10/14 Added by S.Puli
            }

            //values taken from the order object
            caseRec.Order__c = orderRecord.Id;
            caseRec.AccountId = orderRecord.Account__c;
            caseRec.Subscription_Name__c = orderRecord.Subscription__c;
            caseRec.Description = orderRecord.Remarks__c;
            caseRec.Origin = orderRecord.Acquisition_Type__c;
            caseRec.Recipient__c = orderRecord.Recipient_Contact__c;
            caseRec.Recipient_Address__c = orderRecord.Recipient_Contact__r.Address__c;
            caseRec.Urgent_Request__c = false;
            caseRec.Waived_Request__c = false;
      
            if(sUrgentOrder.contains(orderRecord.Id)){
                caseRec.Urgent_Request__c = true;
            }
            if(sWaiveOrder.contains(orderRecord.Id)){
                 caseRec.Waived_Request__c = true;
            }
            
            if(bDirect){
                caseRec.Subscriber__c = orderRecord.Billing_Contact__c;                
            }
        
            caseList.add(caseRec);
        }
        
        try {
            upsert caseList;
        }
        catch (Exception e) {
            ApexPages.addMessages(e);   
        }
        
        //START D-2027 Wenjun 05/02/15 : Update Order Line Items / Remove unused codes
        Map<Id,Id> mapOrderIdToCaseId = new Map<Id,Id>();
        //Map<id,id> mapCase_Order_Opp = new Map<Id,Id>();
        //set<id> orderIdSet = new set<Id>();
        for(Case c: caseList){
            mapOrderIdToCaseId.put(c.Order__c, c.Id);
        }
        
        for(Order_Line_Item__c oli :lstOrderLineItems) 
        {
            oli.Case__c = mapOrderIdToCaseId.get(oli.Order__c);
        }
        
        UPDATE lstOrderLineItems;
        //END D-2027 Wenjun 05/02/15
        
        return  caseList;
    }
}