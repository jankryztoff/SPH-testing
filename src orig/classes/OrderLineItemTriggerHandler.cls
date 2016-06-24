/*Developer: Francis Benzon 11/19/2014
* Description: Updates vendor field in subscription if CSO manually assigns vendor. 
* Updates Status of Order and Case Close
* History: 21/Jan/2015 Joban D-1828
* History: 21/Feb/2015 Wenjun - Code review Fix
* History: 05/Feb/2015 JohnD UD-0190
*/

public class OrderLineItemTriggerHandler
{
    // variables initialization that will be used in classification process
    private static Map<id, Order_Line_Item__c> orderLineItemId_basedOrderLineItem = new Map<id, Order_Line_Item__c>();
    private static Map<id, string> orderId_orderType = new Map<id, string>();
    private static Map<id, integer> orderId_accountSubscriptions = new Map<id, integer>();
    private static Map<id, string> orderId_subscriptionIndicator = new Map<id, string>();
    private static Map<id, string> packageId_productPlatform = new Map<id, string>();
    private static Map<id, id> orderId_basedOrderLineItemId = new Map<id, id>();
    private static final string NO_SUBSCRIPTION = 'No Subscription';
    private static final string WITH_ACTIVE_SUBSCRIPTION = 'With Active Subscription';
    private static final string DIGITAL = ConstantsSLB.getOther('Product_Category Digital');
    private static final string PRINT = ConstantsSLB.getOther('Product_Category Print');
    private static final string AIO = ConstantsSLB.getOther('Product_Category AIO');
    // added functionality for vendor conversion scenario
    Map<id, string> vendorSubId_HighestPubProdType = new Map<id, string>();
    //START  4/22/2015 UD-0675 MGaelo Remove Validation on Charity checkbox
    //List<Unique_Address__c> recipientAddress = Unique_Address__c.getall().values(); 
    /*Map<String, String> recAddressMap = new Map<String, String>(); 
    Set<Id> packageIds = new Set<Id>();
    Map<Id, Id> packageIdsAIO = new Map<Id, Id>(); 
    List<Package_Item__c> packageItemList = new List<Package_Item__c>();*/
    //END 4/22/2015 UD-0675 MGaelo Remove Validation on Charity checkbox
    
    //Before Insert logic - Call separate method for detail processing - Leave Blank for not in use
    public void doBeforeInsert(List<Order_Line_Item__c> lstNewItems)
    {
        processDataForClassification(lstNewItems); 
        runDateValidation(lstNewItems); 
        //START 4/22/2015 UD-0675 MGaelo Remove Validation on Charity checkbox
        //charityAddress(lstNewItems);
        //END 4/22/2015 UD-0675 MGaelo Remove Validation on Charity checkbox
        // [JohnD 12/10] D-0636
        // This will invoke the classify() method within this class where the classification of order line item takes place
        for(Order_Line_Item__c orderLineItem : lstNewItems){
        
            classify(orderLineItem);
        }
            // End D-0636  

    }
    
    //After Insert logic - Call separate method for detail processing - Leave Blank for not in use
    public void doAfterInsert(List<Order_Line_Item__c> lstNewItems, Map<Id, Order_Line_Item__c> mapNewItems)
    {}
    
    //Before Update logic - Call separate method for detail processing - Leave Blank for not in use
    public void doBeforeUpdate(List<Order_Line_Item__c> lstNewItems, Map<Id, Order_Line_Item__c> mapNewItems,
                               List<Order_Line_Item__c> lstOldItems, Map<Id, Order_Line_Item__c> mapOldItems)
    {
        processDataForClassification(lstNewItems);
        //START 4/22/2015 UD-0675 MGaelo Remove Validation on Charity checkbox
        //charityAddress(lstNewItems);
        //END 4/22/2015 UD-0675 MGaelo Remove Validation on Charity checkbox
        //Check if Start Date is updated
        List<Order_Line_Item__c> lstUpdatedItems = new List<Order_Line_Item__c>();
        for(Order_Line_Item__c newOli : lstNewItems){
            if(newOli.Start_Date__c != mapOldItems.get(newOli.Id).Start_Date__c)
                lstUpdatedItems.add(newOli);
        }
        
        if(!lstUpdatedItems.isEmpty())
            runDateValidation(lstUpdatedItems);
        
        for(Order_Line_Item__c newOli : lstNewItems){
            // [JohnD 12/10] D-0636
            // This will invoke the classify() method within this class where the classification of order line item takes place
            classify(newOli);
            // End D-0636
        }           
    }

    //After Update logic - Call separate method for detail processing - Leave Blank for not in use
    public void doAfterUpdate(List<Order_Line_Item__c> lstNewItems, Map<Id, Order_Line_Item__c> mapNewItems,
                               List<Order_Line_Item__c> lstOldItems, Map<Id, Order_Line_Item__c> mapOldItems)
    {
        //Check if Vendor is updated
        List<Order_Line_Item__c> lstUpdatedItems = new List<Order_Line_Item__c>();
        for(Order_Line_Item__c newOli : lstNewItems){
            if(newOli.Vendor_Mailing_Agent__c != mapOldItems.get(newOli.Id).Vendor_Mailing_Agent__c)
                lstUpdatedItems.add(newOli);
        }
        
        if(!lstUpdatedItems.isEmpty())
            assignVendor(lstUpdatedItems);
    }
    
    //Before Delete logic - Call separate method for detail processing - Leave Blank for not in use
    public void doBeforeDelete(List<Order_Line_Item__c> lstOldItems, Map<Id, Order_Line_Item__c> mapOldItems)
    {}
    
    //After Delete logic - Call separate method for detail processing - Leave Blank for not in use
    public void doAfterDelete(List<Order_Line_Item__c> lstOldItems, Map<Id, Order_Line_Item__c> mapOldItems)
    {} 
    
    //Updates Vendor in Subscription and Status in Case after update in Vendor in Order Line Item
    private void assignVendor(List<Order_Line_Item__c> lstNewItems) 
    {
        Set<Id> setOrderId = new Set<Id>();
        Set<Id> setCaseId = new Set<Id>();
        //Start D-0846 04/17/15 ABanaag - Changed from Map<id,Zuora__Subscription__c> to Map<Id, List<Zuora__Subscription__c>>
        Map<Id, List<Zuora__Subscription__c>> mapOliIdToSub = new Map<Id, List<Zuora__Subscription__c>>(); //Start-End UD-0846 04/17/15 ABanaag
        //End D-0846 04/17/15 ABanaag - Changed from Map<id,Zuora__Subscription__c> to Map<Id, List<Zuora__Subscription__c>>
        Map<Id, Order_Line_Item__c> mapOliIdToObj = new Map<Id, Order_Line_Item__c>();
        //START Code Review 2/18/2015 J.Sarion - Null in where clause causes Full Table scans
        Map<Id, Order__c> mapOrders = new Map<Id, Order__c>();
        Map<Id, Case> mapCases = new Map<Id, Case>();
        //END Code Review 2/17/2015 J.Sarion
        List<Case> lstCaseToUpdate = new List<Case>();
        List<Order__c> lstOrderToUpdate = new List<Order__c>();
        
        // Start UD-0228 05-03-2015 JohnD variable declaration
        map<id, Order__c> orderId_Order = new map<id, Order__c>();
        map<id, Case> caseId_case = new map<id, Case>();
        // End UD-0228 05-03-2015 JohnD
        List<Zuora__Subscription__c> lstSubToUpdate = new List<Zuora__Subscription__c>();
        
        for(Order_Line_Item__c oli : lstNewItems)
        {
            mapOliIdToObj.put(oli.Id, oli);
            
            if(oli.Order__c != null) 
                setOrderId.add(oli.Order__c);
       //START 3/17/15 MD-7 (D-2536) MGaelo    
            if(oli.Case__c != null) 
            {               
                setCaseId.add(oli.Case__c);             
            }                       
        }
        //END 3/17/15 MD-7 (D-2536) MGaelo 
        // Start UD-0228 05-03-2015 JohnD add null checking
        //START Code Review 2/17/2015 J.Sarion - Null in where clause causes Full Table scans
        
        if (setCaseId != null && !setCaseId.isEmpty()) {
            //Start D-0846 04/14/2015 ABanaaag, added ownerID to query
            mapCases = new Map<Id, Case> ([SELECT Status, Sub_Status__c, ownerId, CreatedById FROM Case WHERE Id in :setCaseId]);
            //End D-0846 04/14/2015 ABanaaag, added ownerID to query         
        }
        
        if (setOrderId != null && !setOrderId.isEmpty()) {
            mapOrders = new Map<Id, Order__c> ([SELECT Status__c FROM Order__c WHERE Id in :setOrderId]);
            for(Zuora__Subscription__c sub: [SELECT Id, Vendor_1__c, Vendor__c, Order_Line_Item_Number_1__c FROM Zuora__Subscription__c 
                                             WHERE Order_Number_1__c in :setOrderId AND Zuora__Status__c = 'Active'])
            {                             
                //Start D-0846 04/17/15 ABanaag - cater for multiple subscriptions per order line item
                /**
                if(sub.Order_Line_Item_Number_1__c != null)
                    mapOliIdToSub.put(sub.Order_Line_Item_Number_1__c, sub);
                **/
                if(mapOliIdToSub.containsKey(sub.Order_Line_Item_Number_1__c)){
                    mapOliIdToSub.get(sub.Order_Line_Item_Number_1__c).add(sub);
                } else {
                    mapOliIdToSub.put(sub.Order_Line_Item_Number_1__c, new List<Zuora__Subscription__c>{sub});
                }
                //End D-0846 04/17/15 ABanaag - cater for multiple subscriptions per order line item
            }                                       
        }
        //END Code Review 2/17/2015 J.Sarion
                
        if (mapOliIdToSub != null) {
            for(Id oliId : mapOliIdToSub.KeySet())
            {
                if (mapOliIdToObj.get(oliId) != null && mapOliIdToSub.get(oliId).size() > 0) { //Start/End UD-0846 04/17/15 ABanaag
                    
                    Order_Line_Item__c oli = mapOliIdToObj.get(oliId);
                    
                    //Update Related Subscription
            //Start UD-0846 04/17/15 ABanaag
                    List<Zuora__Subscription__c> relatedSubs = mapOliIdToSub.get(oliId);
                    for(Zuora__Subscription__c relatedSub : relatedSubs){
                        system.debug('relatedSubId'+relatedSub.id);
                        //system.assert(false);
                        relatedSub.Vendor_1__c = oli.Vendor_Mailing_Agent__c;
                        relatedSub.Vendor__c = oli.Vendor_Mailing_Agent__c;
                        lstSubToUpdate.add(relatedSub);
                    }
            //End UD-0846 04/17/15 ABanaag
                    // Start UD-0228 05-03-2015 JohnD replaced list into map to avoid duplicate ids when update
                    //Update Related Case
                    Case relatedCase = mapCases.get(oli.Case__c);
                    //Start UD-0916 04/14/15 ABanaag - added SubStatus!=Waiting for Urgent Start; removed hardcoded values  
                    //Start D-0846 04/14/2015 ABanaaag, changed UD-0916 from SubStatus!=Waiting for Urgent Start to relatedCase.OwnerId !=ConstantsSLB.getKeyId('CSO TL Queue')
                    if(relatedCase != null && relatedCase.OwnerId !=ConstantsSLB.getKeyId('CSO TL Queue')) {
                    //End D-0846 04/14/2015 ABanaaag, changed UD-0916 from SubStatus!=Waiting for Urgent Start to relatedCase.OwnerId !=ConstantsSLB.getKeyId('CSO TL Queue')
                    //End UD-0916 04/14/15 ABanaag - added SubStatus!=Waiting for Urgent Start; removed hardcoded values
                        relatedCase.Status = 'Closed';                       
                        relatedCase.Sub_Status__c = 'Subscription Created';                         
                        relatedCase.OwnerId = relatedCase.CreatedById; //Start/End D-0846 04/14/2015 ABanaaag return case to CSO
                        caseId_case.put(relatedCase.Id, relatedCase);
                    }
                    
                    //Update Related Order
                    Order__c relatedOrder = mapOrders.get(oli.Order__c);
                    if(relatedOrder != null) {
                        relatedOrder.Status__c = GlobalVariableClass.STATUS_CLOSE; // START- END UD-3761 K. Tan 1/28/2015 Shall refer to STATUS_CLOSE instead 
                        orderId_order.put(relatedOrder.Id, relatedOrder); 
                    }
                    //End UD-0228 05-03-2015 JohnD
                }
            }
        }     
        // End UD-0228 05-03-2015 JohnD
        
        //Perform DML Operations
        if(!lstSubToUpdate.isEmpty()) UPDATE lstSubToUpdate;     
        
        // Start UD-0190 05-03-2015 JohnD changed how to update related objects
        if (!caseId_case.isEmpty()) {
            update caseId_case.values();
        }
        
        if (!orderId_order.isEmpty()) {
            update orderId_order.values();
        }
        // End UD-0190 05-03-2015 JohnD
    }
    
    //[JohnD 12/09] D-0636
    /*
    *   @description: This method will populate the Sub-classification and Reason Code fields of the
    *       Order Line Item record that being created/updated. This will be invoke from beforeInsert() 
    *       or beforeUpdate() method within this class 
    *   @param: Order Line Item record
    *   @return: N/A
    */
    private void classify(Order_Line_Item__c orderLineItem) {
        String orderType = orderId_orderType.get(orderLineItem.Order__c);
        orderLineItem.Publication_Product_Category__c = packageId_productPlatform.get(orderLineItem.Main_Package_ID__c);
        orderLineItem.Based_Order_Line_Item__c = orderId_basedOrderLineItemId.get(orderLineItem.Order__c);
        
        // start subscription
        if (orderType == ConstantsSLB.getOther('Order_Type Start')) {
            // [JohnD 12/11] D-0636
            // added for vendor conversion scenario
            if (orderLineItem.Vendor_Conversion__c == true && orderLineItem.Vendor_Subscription_ID__c != null) {
                orderLineItem.Sub_classification__c = subClassifyProductCategory
                (vendorSubId_HighestPubProdType.get(orderLineItem.Vendor_Subscription_ID__c), orderLineItem.Publication_Product_Category__c);
                orderLineItem.Reason_Code__c = null;
            } else {
                orderLineItem.Sub_classification__c = ConstantsSLB.getOther('Order_Line_Item Neutral');
                if (orderId_subscriptionIndicator.get(orderLineItem.Order__c) == WITH_ACTIVE_SUBSCRIPTION) { // with active subscription
                    orderLineItem.Reason_Code__c = ConstantsSLB.getOther('Reason_Code Customer Request');
                } else if (orderId_subscriptionIndicator.get(orderLineItem.Order__c) == NO_SUBSCRIPTION) {   // without subscription
                    orderLineItem.Reason_Code__c = ConstantsSLB.getOther('Reason_Code Correction');
                }
            }
            // end added for vendor conversion scenario
        // change of subscription quantity
        // Start PD-0136 02Jun16 JohnD - added logic for sub classification
        } else if (orderType == ConstantsSLB.getOther('Order_Type COS_Quantity') 
            || orderType == ConstantsSLB.getOther('Order_Type COS_Package') 
            || ordertype == ConstantsSLB.getOther('Order_Type COS_Others')) {
            	
            if (orderLineItem.Based_Order_Line_Item__c != null) {
                Order_Line_Item__c basedOrderLineItem =  orderLineItemId_basedOrderLineItem.get(orderLineItem.Based_Order_Line_Item__c);
                
                if (orderType == ConstantsSLB.getOther('Order_Type COS_Quantity')) {
                    if (orderLineItem.Qty__c > basedOrderLineItem.Qty__c) {
                        orderLineItem.Sub_classification__c = ConstantsSLB.getOther('Order_Line_Item Qty Increase');
                    } else if (orderLineItem.Qty__c < basedOrderLineItem.Qty__c) {
                        orderLineItem.Sub_classification__c = ConstantsSLB.getOther('Order_Line_Item Qty Decrease');
                    }
                    
                } else if (orderType == ConstantsSLB.getOther('Order_Type COS_Package')) {
                    orderLineItem.Sub_classification__c = subClassifyProductCategory
                    (basedOrderLineItem.Publication_Product_Category__c, orderLineItem.Publication_Product_Category__c);
                
                } else {
                	orderLineItem.Sub_Classification__c = orderLineItem.Subscribed_As__c;
                }
            }
            // [JohnD 12/11] D-0636
            // added for vendor conversion scenario
            orderlineItem.Reason_Code__c = null;
            // end added for vendor conversion scenario
        } else if (orderType == ConstantsSLB.getOther('Order_Type Renewal')) {
        // End PD-0136 02Jun16 JohnD - added logic for sub classification
            orderLineItem.Sub_classification__c = ConstantsSLB.getOther('Order_Line_Item Neutral');
            
            if (orderLineItem.Auto_Renew__c == true) {
                orderLineItem.Reason_Code__c = ConstantsSLB.getOther('Reason_Code Auto Renew');
            } else {
                orderLineItem.Reason_Code__c = ConstantsSLB.getOther('Reason_Code Customer Request');
            }
        } else if (orderType == ConstantsSLB.getOther('Order_Type Stop')) {
            orderLineItem.Sub_classification__c = 'N/A';
        }
    }
    
    /*
    *   @description: This method will identify whether the transaction is downgrade or upgrade.
    *       This will be called from classify() method within this class.
    *   @param: fromPc = product platform of the based subscription/orderlineitem;
    *           toPc = product platform of the subscription/orderlineitem to be created
    *   @return: Downgrade or Upgrade or Neutral/Flat
    */
    // [JohnD 12/11] D-0636
    // updated to address vendor conversion scenario
    private String subClassifyProductCategory(String fromPc, String toPc) {
        String returnValue; 
        integer currentProductCategory = 0;
        integer basedProductCategory = 0;
        
        if (toPc == ConstantsSLB.getOther('Product_Category AIO')) {
            currentProductCategory = 3;
        } else if (toPc == ConstantsSLB.getOther('Product_Category Print')) {
            currentProductCategory = 2;
        } else if (toPc == ConstantsSLB.getOther('Product_Category Magazine')) {
            currentProductCategory = 2;
        } else if (toPc ==  ConstantsSLB.getOther('Product_Category Digital')) {
            currentProductCategory = 1;
        }
        
        if (fromPc == ConstantsSLB.getOther('Product_Category AIO')) {
            basedProductCategory = 3;
        } else if (fromPc == ConstantsSLB.getOther('Product_Category Print')) {
            basedProductCategory = 2;
        } else if (fromPc == ConstantsSLB.getOther('Product_Category Magazine')) {
            basedProductCategory = 2;
        } else if (fromPc == ConstantsSLB.getOther('Product_Category Digital')) {
            basedProductCategory = 1;
        }
        
        if (currentProductCategory > basedProductCategory) {
            returnValue = ConstantsSLB.getOther('Order_Line_Item Upgrade');
        } else if (currentProductCategory < basedProductCategory) {
            returnValue = ConstantsSLB.getOther('Order_Line_Item Downgrade');
        } else if (currentProductCategory == 0 || basedProductCategory == 0) {
            returnValue = ConstantsSLB.getOther('Order_Line_Item Invalid');
        } else if (currentProductCategory == basedProductCategory) {
            returnValue = ConstantsSLB.getOther('Order_Line_Item Neutral');
        }
        
        return returnValue;
    }
    // end updated to vendor conversion scenario
    
    /*
    *   @description: This method will prepare all the data needed to classify the order line items.
    *       This is a bulkify approach to avoid the query within a loop. 
    *   @param: list of order line items being process by the trigger
    *   @return: N/A. All processed values within this method are being stored in the static variables
    */
    private void processDataForClassification(list<Order_Line_Item__c> lstNewItems) {
        
        Set<id> orderIdSet = new Set<id>();
        //START Code Review 2/17/2015 J.Sarion - Null in where clause causes Full Table scans
        list<Order__c> orderList = new list<Order__c>();
        //END Code Review 2/17/2015 J.Sarion
        Map<id, id> orderId_accountId = new Map<id, id>();
        Map<id, id> orderId_parentAccountId = new Map<id, id>();
        Map<id, string> accountId_subscriptionIndicator = new Map<id, string>();
        Map<id, string> parentAccountId_subscriptionIndicator = new Map<id, string>();
        
        // [JohnD 12/11] D-0636 added for vendor conversion scenario
        Map<string, integer> productCategory_level = new Map<string, integer>();
        productCategory_level.put(ConstantsSLB.getOther('Product_Category Digital'), 0);    // [JohnD 12/12] updated due to null pointer
        productCategory_level.put(ConstantsSLB.getOther('Product_Category Print'), 1);      // [JohnD 12/12] updated due to null pointer
        productCategory_level.put(ConstantsSLB.getOther('Product_Category Magazine'), 1);   // [JohnD 12/12] updated due to null pointer
        productCategory_level.put(ConstantsSLB.getOther('Product_Category AIO'), 2);
        // end added
             
        for (Order_Line_Item__c tmpOli : lstNewItems) {
            // get associated based order line item
            if (tmpOli.Based_Order_Line_Item__c != null) {
                orderLineItemId_basedOrderLineItem.put(tmpOli.Based_Order_Line_Item__c, null);
            }
            
            // initialize packageId_productPlatform
            if (tmpOli.Main_Package_ID__c != null) {
                packageId_productPlatform.put(tmpOli.Main_Package_ID__c, null);
            }
            
            //START Code Review 2/17/2015 J.Sarion - Null in where clause causes Full Table scans
            if (tmpOli.Order__c != null) {
                orderIdSet.add(tmpOli.Order__c);
            }
            //END Code Review 2/17/2015 J.Sarion
            
            // [JohnD 12/11] D-0636
            // added for vendor conversion scenario
            if (tmpOli.Vendor_Conversion__c == true && tmpOli.Vendor_Subscription_ID__c != null) {
                vendorSubId_HighestPubProdType.put(tmpOli.Vendor_Subscription_ID__c, null);
            }
            // end added for vendor conversion scenario
        }

        //Retrieving susbscriptions
        //START Code Review 2/17/2015 J.Sarion - Null in where clause causes Full Table scans
        if (!orderIdSet.isEmpty()) {
            orderList = [SELECT Id, Account__c, Parent_Account_Id__c, Order_Type__c, 
                                    Subscription__r.Order_Line_Item_Number_1__c  FROM Order__c where Id in :orderIdSet];
        }
        //END Code Review 2/17/2015 J.Sarion
        
        for (Order__c tmp : orderList) {
            orderId_accountId.put(tmp.Id, tmp.Account__c);
            //START D-1828 21/01/15 Joban : Checking for null values from getting added to the map
            if(tmp.Parent_Account_Id__c != null){
                orderId_parentAccountId.put(tmp.Id, tmp.Parent_Account_Id__c);
            }
            //END D-1828 21/01/15 Joban
            orderId_orderType.put(tmp.Id, tmp.Order_Type__c);
            
            if (tmp.Subscription__r.Order_Line_Item_Number_1__c != null) {
                orderId_basedOrderLineItemId.put(tmp.Id, tmp.Subscription__r.Order_Line_Item_Number_1__c);
            }
            
            // [JohnD 12/10] D-0636
            // missed this statement to initialize the variable
            accountId_subscriptionIndicator.put(tmp.Account__c, NO_SUBSCRIPTION);
            // end D-0636
            
        }

        //START Code Review 2/17/2015 J.Sarion - Null in where clause causes Full Table scans
        if (orderId_basedOrderLineItemId.values().size() > 0) {
            orderLineItemId_basedOrderLineItem = new Map<id, Order_Line_Item__c>([SELECT Id, Qty__c, 
                    Publication_Product_Category__c FROM Order_Line_Item__c WHERE Id in :orderId_basedOrderLineItemId.values()]);
        }
        if (orderId_parentAccountId.values().size() > 0) {
            for (Subscription_Vendor__c tmp : [SELECT Account__c, Status__c FROM Subscription_Vendor__c 
                                               WHERE Account__c in :orderId_parentAccountId.values()]) 
            {   
                parentAccountId_subscriptionIndicator.put(tmp.Account__c, null);
                if (tmp.Status__c == 'Active') {
                    parentAccountId_subscriptionIndicator.put(tmp.Account__c, WITH_ACTIVE_SUBSCRIPTION);
                }
            }
        }

        if (orderId_accountId.values().size() > 0) {
            for (Zuora__Subscription__c tmp : [SELECT Zuora__Account__c, Zuora__Status__c, Zuora__Account__r.ParentId 
                    FROM Zuora__Subscription__c WHERE Zuora__Account__c in :orderId_accountId.values()]) 
            {
                accountId_subscriptionIndicator.put(tmp.Zuora__Account__c, null);
                if (tmp.Zuora__Status__c == 'Active' || parentAccountId_subscriptionIndicator.get(tmp.Zuora__Account__r.ParentId) == 'Active') {
                    accountId_subscriptionIndicator.put(tmp.Zuora__Account__c, WITH_ACTIVE_SUBSCRIPTION);
                }
            }
        }
        //END Code Review 2/17/2015 J.Sarion
        
        // populate the orderId_subscriptionIndicator
        for (Order__c tmp : orderList) {
            if (accountId_subscriptionIndicator.get(tmp.Account__c) == WITH_ACTIVE_SUBSCRIPTION 
                    || accountId_subscriptionIndicator.get(tmp.Parent_Account_Id__c) == WITH_ACTIVE_SUBSCRIPTION) {
                        
                orderId_subscriptionIndicator.put(tmp.Id, WITH_ACTIVE_SUBSCRIPTION);
                    
            } else if (accountId_subscriptionIndicator.get(tmp.Account__c) == NO_SUBSCRIPTION 
                    || accountId_subscriptionIndicator.get(tmp.Parent_Account_Id__c) == NO_SUBSCRIPTION) {
                
                orderId_subscriptionIndicator.put(tmp.Id, NO_SUBSCRIPTION);
            }
        }
        // end populate the orderId_subscriptionIndicator
        
        // populate publication product type
        //START Code Review 2/17/2015 J.Sarion - Null in where clause causes Full Table scans
        if (packageId_productPlatform.keySet().size() > 0) {
            for (Package__c tmp : [SELECT id, (SELECT Is_Digital_2__c, Is_Print__c, Is_All_In_One__c 
                    FROM Package_Items__r WHERE RecordType.DeveloperName like '%Product%' Limit 1) FROM Package__c 
                    WHERE Id in :packageId_productPlatform.keySet()]) 
            {
                packageId_productPlatform.put(tmp.Id, null);
                if (tmp.Package_Items__r.size() > 0) {
                    List<Package_Item__c> tmpPackageItemList = tmp.Package_Items__r;
                    if (tmpPackageItemList[0].Is_Digital_2__c == true) {
                        packageId_productPlatform.put(tmp.Id, DIGITAL);
                    } else if (tmpPackageItemList[0].Is_Print__c == true) {
                        packageId_productPlatform.put(tmp.Id, PRINT);
                    } else if (tmpPackageItemList[0].Is_All_In_One__c == true) {
                        packageId_productPlatform.put(tmp.Id, AIO);
                    }       
                }
            }
        }
        // end populate publication product type
        
        // [JohnD 12/11] D-0636
        // added for vendor conversion scenario
        if (vendorSubId_HighestPubProdType.keySet().size() > 0) {
            for (Subscription_Vendor_Publication__c tmp : [SELECT Subscription_Vendor__c, 
                    Publication__r.Product_Category__c FROM Subscription_Vendor_Publication__c 
                    WHERE Subscription_Vendor__c in :vendorSubId_HighestPubProdType.keySet()]) 
            {
                if (vendorSubId_HighestPubProdType.get(tmp.Subscription_Vendor__c) != null) 
                {
                    String currentCategory = vendorSubId_HighestPubProdType.get(tmp.Subscription_Vendor__c);
                    if (productCategory_level.get(tmp.Publication__r.Product_Category__c) > productCategory_level.get(currentCategory)) {
                        vendorSubId_HighestPubProdType.put(tmp.Subscription_Vendor__c, tmp.Publication__r.Product_Category__c);
                    }
                } else {
                    vendorSubId_HighestPubProdType.put(tmp.Subscription_Vendor__c, tmp.Publication__r.Product_Category__c);
                }
            }
        }
        //END Code Review 2/17/2015 J.Sarion
        // end added for vendor conversion scenario
        
    }
    
    // end D-0636
    
    //START D-1754 01/21/15 Added by April Banaag
    /*
    *   @description: This method validates the value and display an error 
    *       when values do not match each other (to be done in OrderLineItemTriggerHandler).
    *   @Parameters: List<SObject>
    *   @return: N/A
    */
    public void runDateValidation(List<Order_Line_Item__c> lstItems){
        Map<Id, Id> mapItemIdToOrderId = new Map<Id, Id>();
        //START Code Review 2/17/2015 J.Sarion - Null in where clause causes Full Table scans
        Map<Id, Order__c> mapRelatedOrders = new Map<Id, Order__c>();
        for(Order_Line_Item__c item : lstItems)
            mapItemIdToOrderId.put(item.Id, item.order__c);

        System.debug('>>>>>mapItemIdToOrderId ' + mapItemIdToOrderId);
        if (mapItemIdToOrderId.values().size() > 0) {
            mapRelatedOrders = new Map<Id, Order__c> ([SELECT id, Base_Subscription__r.Zuora__SubscriptionEndDate__c, 
                                                Order_Type__c FROM Order__c WHERE Id in : mapItemIdToOrderId.values()]); 
        }
        //END Code Review 2/17/2015 J.Sarion
        System.debug('>>>>>mapRelatedOrders ' + mapRelatedOrders);
        for(Order_Line_Item__c newOli : lstItems){
            Order__c relatedOrder = mapRelatedOrders.get(newOli.Order__c);
            //System.debug('>>>>>relatedOrder.Order_Type__c ' + relatedOrder.Order_Type__c);
            System.debug('test class ----------------------------------> ' + relatedOrder + ' - ' + mapRelatedOrders);
            if(relatedOrder != null && relatedOrder.Order_Type__c == ConstantsSLB.getOther('Order_Type Renewal'))
            {
              
                //Start UD-0441 James 03/25/2015 - start date of renewal is equal to end date of previous subscription + 1
                if(newOli.Start_Date__c != relatedOrder.Base_Subscription__r.Zuora__SubscriptionEndDate__c.addDays(1)){
                    newOli.addError('Renewal Start Date must be day after the End Date of subscription to be renewed.');
                }
                //End UD-0441 James 03/25/2015         
            }
        }
   }
   //END D-1754 01/21/15 Added by April Banaag
   
    //START 4/22/2015 UD-0675 MGaelo Remove Validation on Charity checkbox
    /*public void charityAddress(List<Order_Line_Item__c> lstItems){
        
        Unique_Address__c recipientAddress = Unique_Address__c.getInstance('SPH Media Centre store address');
        set<Id> orderIds = new set<Id>();
        Map<id, Order__c> mapOrder = new Map<id, Order__c>();
        for(Order_Line_Item__c orderLineItem : lstItems){
            packageIds.add(orderLineItem.Main_Package_ID__c);
            orderIds.add(orderLineItem.Order__c);
        }
        
        packageItemList = [SELECT Package__c FROM Package_Item__c WHERE Package__c IN : packageIds AND Is_All_In_One__c = TRUE];
        mapOrder = new Map<id, Order__c> ([Select ID, Recipient_Contact__c, Recipient_Address_Name__c,
                        Recipient_Contact__r.Address__r.Name
                        From Order__c Where Id IN :orderIds]);
      

        for(Package_Item__c pItems : packageItemList){
            packageIdsAIO.put(pItems.Package__c, pItems.Id);
        }

        for(Order_Line_Item__c orderLineItem : lstItems){
        
            if(orderLineItem.Charity__c == TRUE && packageIdsAIO.containskey(orderLineItem.Main_Package_ID__c)){


                if(mapOrder.containsKey(orderlineItem.Order__c) && mapOrder.get(orderlineItem.Order__c).Recipient_Address_Name__c != NULL) {
                    if(recipientAddress.Charity_Address__c != mapOrder.get(orderlineItem.Order__c).Recipient_Address_Name__c)
                    { 
                        orderLineItem.addError('Recipient Address must be at SPH Store.'); 
                    }
                }
            }
            else if(orderLineItem.Charity__c == true && !packageIdsAIO.containskey(orderLineItem.Main_Package_ID__c))
            {
                orderLineItem.addError('Charity should be unchecked for packages that are not All-in-One.'); 
            }                       
        }   
    }*/
    //END 4/22/2015 UD-0675 MGaelo Remove Validation on Charity checkbox
   
}