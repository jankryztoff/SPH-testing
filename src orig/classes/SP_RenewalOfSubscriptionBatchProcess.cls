/**
 * Class Name: SP_RenewalOfSubscriptionBatchProcess
 * @author: AlyanaNavarro
 * Date: 
 * Requirement/Project Name: Singapore Press Holdings
 * @description 
 * 
 * History: 19/01/15 Wenjun : Rewrite this class
 *  - Fix 1: Main Query - Only retrive those with Main Package - i.e. ignore Add-on, Gift, Postage Charge etc
 *  - Fix 2: Renewal Package Code
 *  - D-1826: Add support for Postage Charges
 * History: 19/02/15 Karl Tan : Update Class to cater Subscription End Dates
 */
 
 global class SP_RenewalOfSubscriptionBatchProcess implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    Set<Id> setNewOrderIDs = new Set<Id>();
    Set<String> setQuoteNames = new Set<String>();
    //START: D-2179 2/18/2015 Added By K.Tan - Transfer TempStop and COA to Renewal Subscription
    Map<Id, String> oliIDtoZuoraIDmap = new Map<Id, String>();
    //END: D-2179 2/18/2015 Added By K.Tan
    //START D-3068 6/10/2015 Added By C. Lin - Map for Order to Billing Account
    Map<Id, Id> orderIdToBillAccIdMap = new Map<Id, Id>();
    //END D-3068 6/10/2015 Added By C. Lin
    
    global final static String ORIGIN = 'Renewal';
    
    //START D-3659 10/5/15 AddedBy FrancisBenzon: recovery plan auto renew batch
    String newVar = GlobalVariableClass.STATUS_NEW;
    String activeVar = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
    Integer daysBeforeEndDate = Integer.valueOf(ConstantsSLB.getKeyId('DaysBeforeSubEndDate_RenewalOfSub'));
    Date endDate;
    
    //START D-3755 14-Oct-2015 LISEN - update logic for batch recovery
    Set<String> selectiveIds = null;
    Boolean isApexJobSuccessful = true;
    //END D-3755 14-Oct-2015 LISEN - update logic for batch recovery
    
    global SP_RenewalOfSubscriptionBatchProcess() 
    {
        endDate = Date.today().addDays(daysBeforeEndDate);
    }
    
    global SP_RenewalOfSubscriptionBatchProcess(Date inputDate) 
    {
        endDate = inputDate;
    }
    //END D-3659 10/5/15 AddedBy FrancisBenzon: recovery plan auto renew batch
    
    //START D-3755 14-Oct-2015 LISEN - update logic for batch recovery
    global SP_RenewalOfSubscriptionBatchProcess(Set<String> selectiveIds){
        this.selectiveIds = selectiveIds;
    }
    //END D-3755 14-Oct-2015 LISEN - update logic for batch recovery
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //START D-3659 10/5/15 AddedBy FrancisBenzon: recovery plan auto renew batch
        /*Integer daysBeforeEndDate = Integer.valueOf(ConstantsSLB.getKeyId('DaysBeforeSubEndDate_RenewalOfSub'));
        Date endDate = Date.today().addDays(daysBeforeEndDate);
        String newVar = 'New';
        String activeVar = 'Active';*/
        //END D-3659 10/5/15 AddedBy FrancisBenzon: recovery plan auto renew batch
        
        //START: D-2179 2/18/2015 Added By K.Tan - Transfer TempStop and COA to Renewal Subscription
        //START: JLedesma - Code Review 'NULL in WHERE clause' 2/19/2015 
        //START D-3068 6/10/2015 Added By C. Lin - Add Zuora__CustomerAccount__c
        //START D-3755 14-Oct-2015 LISEN - update logic for batch recovery
        String query = '';
        if(selectiveIds != null){
            query = 'SELECT Id, name, Main_Package_isNull__c, main_package_1__c, subscription_type_1__c, zuora__subscriptionStartDate__c, ' +
                            'zuora__subscriptionEndDate__c, Zuora__Zuora_Id__c, Recipient_Contact__c, Order_Number_1__c, Order_Line_Item_Number_1__c, ' +
                            'Year_to_Date_Temp_Stop_Days__c, Previous_Year_Temp_Stop_Days__c, Zuora__Account__c, Zuora__AutoRenew__c, Zuora__CustomerAccount__c ' +
                            'FROM Zuora__Subscription__c '+ 'WHERE Zuora__Status__c = :activeVar ' + 'AND  Zuora__AutoRenew__c = true ' +
                            'AND id =: selectiveIds ' + 'AND Main_Package_isNull__c = \'FALSE\' ';
        }else{
            query = 'SELECT Id, name, Main_Package_isNull__c, main_package_1__c, subscription_type_1__c, zuora__subscriptionStartDate__c, ' +
                            'zuora__subscriptionEndDate__c, Zuora__Zuora_Id__c, Recipient_Contact__c, Order_Number_1__c, Order_Line_Item_Number_1__c, ' +
                            'Year_to_Date_Temp_Stop_Days__c, Previous_Year_Temp_Stop_Days__c, Zuora__Account__c, Zuora__AutoRenew__c, Zuora__CustomerAccount__c ' +
                            'FROM Zuora__Subscription__c '+ 'WHERE Zuora__Status__c = :activeVar ' + 'AND  Zuora__AutoRenew__c = true ' +
                            'AND Zuora__SubscriptionEndDate__c =: endDate ' + 'AND Main_Package_isNull__c = \'FALSE\' ';
        }
        //END D-3755 14-Oct-2015 LISEN - update logic for batch recovery
        //END D-3068 6/10/2015 Added By C. Lin
        return Database.getQueryLocator(query);
        //END: JLedesma - Code Review 'NULL in WHERE clause' 2/19/2015 
        //END: D-2179 2/18/2015 Added By K.Tan
    }
    
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> lstSubs) { 
        //START D-3755 14-Oct-2015 LISEN - update logic for batch recovery
        Logger logger = new Logger(SP_RenewalOfSubscriptionBatchProcess.class.getName(), 'SP013', BC.getJobID());
        try{
            Set<Id> setPackageIDs = new Set<Id>();
            Set<Id> setOldOrderIDs = new Set<Id>();
            Set<Id> setOldLineItemIDs = new Set<Id>();
            Map<Id, Id> mapOldSubIdToNewOrderId = new Map<Id, Id>();
            // Map storing existing Order ID to new cloned Order ID
            Map<Id,sObject> mapOldOrderIdToNewOrder = new Map<Id,sObject>();
            //START: D-2179 2/18/2015 Added By K.Tan - Transfer TempStop and COA to Renewal Subscription
            Map<Id,sObject> mapOldOLIIdToNewOLI = new Map<Id,sObject>();
            // Map Storing Order to Recipient Contact ID mapping
            Map<Id,Id> mapOrderIdToContactId = new Map<Id, Id>();
            List<Order_Line_Item__c> newOrderLineItemList = new List<Order_Line_Item__c>();     
            List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();
            //END: D-2179 2/18/2015 Added By K.Tan
            
            for(Zuora__Subscription__c sub : lstSubs){
                
                setOldOrderIDs.add(sub.Order_Number_1__c); // order Ids in sub list
                setOldLineItemIDs.add(sub.Order_Line_Item_Number_1__c);//order line item Ids in sub list
                setPackageIDs.add(sub.main_package_1__c);  //package Ids of main packages in sub list
                //START: D-2179 2/18/2015 Added By K.Tan - Transfer TempStop and COA to Renewal Subscription
                oliIDtoZuoraIDmap.put(sub.Order_Line_Item_Number_1__c, sub.Zuora__Zuora_Id__c);
                //END: D-2179 2/18/2015 Added By K.Tan
                //START D-3068 6/10/2015 Added By C. Lin - Populate Billing Account field for Order
                orderIdToBillAccIdMap.put(sub.Order_Number_1__c, sub.Zuora__CustomerAccount__c);
                //END D-3068 6/10/2015 Added By C. Lin
            }
            
            /***************************** Create New Orders **************************/
            //Clone existing Order List
            system.debug('******setOldOrderIDs: '+setOldOrderIDs);
            mapOldOrderIdToNewOrder = cloneExistingOrders(setOldOrderIDs);              
            
            for(sObject sObj : mapOldOrderIdToNewOrder.values())
            {
                Order__c newOrder = (Order__c)sObj;
                setNewOrderIDs.add(newOrder.Id);
                mapOrderIdToContactId.put(newOrder.Id, newOrder.Recipient_Contact__c);
            }

            /***************************** Create New Order Line Items **************************/
            //START: D-2179 2/18/2015 Added By K.Tan - Transfer TempStop and COA to Renewal Subscription
            mapOldOLIIdToNewOLI = cloneExistingItems(setOldLineItemIDs, setPackageIDs, mapOldOrderIdToNewOrder, mapOrderIdToContactId);             
            
            /*for(Order_Line_Item__c oli : [SELECT id, name, order__c FROM Order_Line_Item__c WHERE id IN: mapOldOLIIdToNewOLI.keyset()]){
                oliIdOrderIdMap.put(oli.id, mapOldOrderIdToNewOrder.get(oli));
            }
            
            for(Id oliId : mapOldOLIIdToNewOLI.keySet()){
                if(oliIdOrderIdMap.containsKey(oliId)){
                    mapOldOLIIdToNewOLI.get(oliId);
                }           
                newOrderLineItemList.add(oliId);
            }*/
            //END: D-2179 2/18/2015 Added By K.Tan
            
            /***************************** Create Quotes **************************/
            Renewal_Quote_Handler_Bulk rQuoteHandler = new Renewal_Quote_Handler_Bulk();
            setQuoteNames = rQuoteHandler.bulkQuoteCreation(setNewOrderIDs,ORIGIN);
        }catch(Exception e){
            logger.logBatchFailure(e, lstSubs);
            
            isApexJobSuccessful = false;
        }finally{
            logger.save();
        }
        //END D-3755 14-Oct-2015 LISEN - update logic for batch recovery
    }
    
    global void finish(Database.BatchableContext BC)
    {   
        //START D-3810 23-Oct-2015 LISEN - Fix callout issue
        /***************************** Update Batch Job Scheduler **************************/   
        //BatchJobHelper.updateJobStatus(BC.getJobId());//START -END D-2770 4/17/2015 KRITHIKA DHARMARAJAN //START-END D-3080 KRITHIKA HOTFIX
        
        //START D-3755 14-Oct-2015 LISEN - update logic for batch recovery
        if(!isApexJobSuccessful){
            BatchJobHelper.updateJobStatus(BC.getJobId(), false); 
        }else{
            BatchJobHelper.updateJobStatus(BC.getJobId(), true);
        }
        //END D-3755 14-Oct-2015 LISEN - update logic for batch recovery

        /***************************** Send Quotes to Zuora **************************/
        if(!setNewOrderIDs.isEmpty())
        {
            SendQuotesToZuoraMultipleAccount sendQuotes = new SendQuotesToZuoraMultipleAccount(setNewOrderIDs, setQuoteNames, ORIGIN);
            Database.executeBatch(sendQuotes); 
        }
        //END D-3810 23-Oct-2015 LISEN - Fix callout issue
    }
    
    //Clone the existing Orders
    public Map<Id,sObject> cloneExistingOrders(Set<Id> setOldOrderIDs){
        List<Order__c> newOrderList = new List<Order__c>();
        Map<Id,sObject> mapIdToObj = new Map<Id,sObject>();
        
        //Convert ID Set to ID List
        List<Id> lstOldOrderIDs = new List<Id>();
        lstOldOrderIDs.addAll(setOldOrderIDs);
        
        mapIdToObj = SObjectAllFieldCloner.cloneObjects(lstOldOrderIDs, Order__c.sObjectType);
        
        //START D-3068 6/10/2015 Added By C. Lin - Populate Billing Account field for Order
        for(Id ordId : mapIdToObj.keySet()){
            Order__c orderObj = (Order__c) mapIdToObj.get(ordId);
            if(orderObj.Billing_Account__c == null){
                orderObj.Billing_Account__c = orderIdToBillAccIdMap.get(ordId);
            }
            newOrderList.add(orderObj);
        }
        
        insert newOrderList;
        //END D-3068 6/10/2015 Added By C. Lin
        
        return mapIdToObj;
    }
    
    //START: D-2179 2/18/2015 Added By K.Tan - Transfer TempStop and COA to Renewal Subscription
    public Map<Id, sObject> cloneExistingItems(Set<id> setOldLineItemIDs, Set<Id> setOldPackageIDs, 
                                   Map<Id,sObject> mapOldOrderIdToNewOrder, Map<Id,Id> mapOrderIdToContactId){
        Package__c packageRec = new Package__c();
        Order__c orderRec = new Order__c();     
        Map<id, Order__c> subOrderMap = new Map<id, Order__c>();        
        List<Order_Line_Item__c> orderLineItemList = new List<Order_Line_Item__c>();
        List<Order_Line_Item__c> lstNewLineItems = new List<Order_Line_Item__c>();  
                                       
        //Convert ID Set to ID List
        List<Id> lstOldLineItemIDs = new List<Id>();
        lstOldLineItemIDs.addAll(setOldLineItemIDs);                                                 
        
        //Get Renewal Package IDs
        Map<Id, Id> mapOldPackIdToNewPackId = generateRenewalPackageMap(setOldPackageIDs);
        // Clone Order Line Items and override with new values
        Map<Id,sObject> mapIdTosObject = SObjectAllFieldCloner.cloneObjects(lstOldLineItemIDs, Order_Line_Item__c.sObjectType);

        for(Id oliID : mapIdTosObject.keySet()){
            Order_Line_Item__c itemObj= (Order_Line_Item__c) mapIdTosObject.get(oliID);
            itemObj.Auto_Renew__c = true;
            itemObj.Order__c = mapOldOrderIdToNewOrder.get(itemObj.Order__c).Id;
            itemObj.Start_Date__c = itemObj.End_Date__c.addDays(1);
            itemObj.End_Date__c = itemObj.Start_Date__c.addMonths(Integer.valueOf(itemObj.Term_Length__c));

            // START: D-2286 / K. Tan / Modified to cater if it does not contain package code
            if(mapOldPackIdToNewPackId.containsKey(itemObj.Main_Package_ID__c)) {
                itemObj.Main_Package_ID__c = mapOldPackIdToNewPackId.get(itemObj.Main_Package_ID__c);
            }

            itemObj.Old_Subscription__c = oliIDtoZuoraIDmap.get(oliID);
            if(itemObj.Addon_Package__c != NULL) {
                if(mapOldPackIdToNewPackId.containsKey(itemObj.Addon_Package__c)){
                    itemObj.Addon_Package__c = mapOldPackIdToNewPackId.get(itemObj.Addon_Package__c);
                }   
            }
            // END: D-2286 / K. Tan / Modified to cater if it does not contain package code
            lstNewLineItems.add(itemObj);
        }

        INSERT lstNewLineItems;
                   
        system.debug('****lstNewLineItems: '+lstNewLineItems);                      
        //Updating with Latest Postage Charges
        Map<Id, Decimal> mapItemIdToPostageCharge = PostageChargeHelper.getPostageChargesForLineItems(mapOrderIdToContactId,lstNewLineItems);   
        for(Order_Line_Item__c itemObj : lstNewLineItems)    
        {
            itemObj.Postage_Charge__c = mapItemIdToPostageCharge.get(itemObj.Id);
        }
        UPDATE lstNewLineItems;
        
        return mapIdTosObject;
        //END: D-2179 2/18/2015 Added By K.Tan
    } 
   
    //Code Fix by 19/01/15 Wenjun: Renew Package Code Logic: 
    //1. Determine if the Package if a discounted Package by checking Discount_Count__c and Bundle_Discount_Count__c
    //2. All Renewal Package Code shall be retrieved from the Base Product or Bundle Product
    //3. Create the map from Old Package to Renewal Package 
    public Map<Id, Id> generateRenewalPackageMap (Set<Id> setPackageIDs)
    {
        Map<Id, String> mapPackIdToRenewalCode = new Map<Id, String>();
        Map<String, Id> mapPackCodeToPackId =  new Map<String, Id> ();
        Map<Id, Id> returnIDMap = new Map<Id, Id>();
        String baseProdRTId = constantsSLB.getKeyID('Package Item_Base Product');
        String bundleProdRTId = constantsSLB.getKeyID('Package Item_Bundle Product');
        // START : UD-3048 11/10/2015 Alyana Navarro
        //START D-4413 7.3.2016 gdelrosario
        for(Package_Item__c packageItem : [SELECT Id, Name, Package__c, Package__r.Subscription_Period__c, Package__r.Discount_Count__c,
                            Package__r.Bundle_Discount_Count__c, Product_Rate_Plan__r.zqu__ZProduct__c, 
                            Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c,Package__r.RenewalPkgCodeNewspaper__r.Package_Code__c,Package__r.RenewalPkgCodeMag1YrDisc__r.Package_Code__c,
                            Package__r.RenewalPkgCodeMag2YrDisc__r.Package_Code__c,Package__r.RenewalPkgCodeMag1YrBase__r.Package_Code__c,Package__r.RenewalPkgCodeMag2YrBase__r.Package_Code__c           
                            FROM Package_Item__c 
                            WHERE Package__c IN :setPackageIDs AND (RecordTypeId = :baseProdRTId OR RecordTypeId = :bundleProdRTId)])
        {
            //For Newspaper
            if(packageItem.Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c == 'Newspaper')
                mapPackIdToRenewalCode.put(packageItem.Package__c, packageItem.Package__r.RenewalPkgCodeNewspaper__r.Package_Code__c);                                  
            else if(packageItem.Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c == 'Magazine')
            {
               //Check If it is Discount
                if(packageItem.Package__r.Discount_Count__c > 0 || packageItem.Package__r.Bundle_Discount_Count__c > 0)
                {
                    if(packageItem.Package__r.Subscription_Period__c == '12')
                        mapPackIdToRenewalCode.put(packageItem.Package__c, packageItem.Package__r.RenewalPkgCodeMag1YrDisc__r.Package_Code__c);
                    else if(packageItem.Package__r.Subscription_Period__c == '24')
                        mapPackIdToRenewalCode.put(packageItem.Package__c, packageItem.Package__r.RenewalPkgCodeMag2YrDisc__r.Package_Code__c);
                } else //Not Discounte Package
                {
                    if(packageItem.Package__r.Subscription_Period__c == '12')
                        mapPackIdToRenewalCode.put(packageItem.Package__c, packageItem.Package__r.RenewalPkgCodeMag1YrBase__r.Package_Code__c);
                    else if(packageItem.Package__r.Subscription_Period__c == '24')
                        mapPackIdToRenewalCode.put(packageItem.Package__c, packageItem.Package__r.RenewalPkgCodeMag2YrBase__r.Package_Code__c);
                }
            }
        }
        //END D-4413 7.3.2016 gdelrosario
        // END : UD-3048 11/10/2015 Alyana Navarro
        //Retrieve details for all the Renewal Packages
        for(Package__c packObj : [SELECT Id, Package_Code__c FROM Package__c WHERE Package_Code__c in :mapPackIdToRenewalCode.values()])
            mapPackCodeToPackId.put(packObj.Package_Code__c, packObj.Id);
 
        for(Id oldPackID : mapPackIdToRenewalCode.keySet())
        {
            if(mapPackCodeToPackId.containsKey(mapPackIdToRenewalCode.get(oldPackID)))
                returnIDMap.put(oldPackID, mapPackCodeToPackId.get(mapPackIdToRenewalCode.get(oldPackID)));
        }
        
        return returnIDMap;
    }
 }