/*
 * Class Name: PostageChargeHelper
 * @Author: Wenjun Zhu
 * @Date: 07/Jan/2015
 * @Description: This class is for Postage Charges related code logic
 * 
 * History: D-1826 19/01/2015 Wenjun: Add Utility Methods to support build records from batch jobs
 */
public class PostageChargeHelper {
    
    public static Decimal getPostageChargeForLineItem(ID contactID, Order_Line_Item__c itemObj)
    { 
        // START: Code Review Implementation 2/17/2015 JAlejandro
        Contact recipentContact = new Contact();
        if (contactID != null)
        {
            recipentContact = [select Id, Address__c, Address__r.Address_Type__c, Zone__c from Contact where Id = :contactID];
        }
        // END: Code Review Implementation 2/17/2015 JAlejandro
        if(recipentContact == NULL)
            throw new CustomException(System.Label.ERR_INVALID_CONTACT);
        
        if(recipentContact.Zone__c == NULL)
            throw new CustomException(System.Label.ERR_CONTACT_NO_ZONE);
        
        List<ID> lstPackageID = new List<ID>();
        if(itemObj.Main_Package_ID__c != NULL)
            lstPackageID.add(itemObj.Main_Package_ID__c);
        if(itemObj.Addon_Package__c != NULL)
            lstPackageID.add(itemObj.Addon_Package__c);
        
        List<ID> lstZProductIDs = getZProductIDsByPackageIDs(lstPackageID);
        return calculatePostageCharge(recipentContact.Zone__c, lstZProductIDs);
    }
    
    public static List<ID> getZProductIDsByPackageIDs(List<ID> lstPackageID)
    {
        List<ID> lstZProductIDs = new List<ID>();
        // START: Code Review Implementation 2/17/2015 JAlejandro
        if (!lstPackageID.isEmpty())
        { // END: Code Review Implementation 2/17/2015 JAlejandro
            for(Package_Item__c pItem: [SELECT Name, Id,  Package__r.Id, RecordType.DeveloperName,
                                               Product_Rate_Plan__r.zqu__ZProduct__r.Id
                                               FROM Package_Item__c WHERE Package__c in: lstPackageID])
            {
                if(pItem.RecordType.DeveloperName.contains('Product'))
                   lstZProductIDs.add(pItem.Product_Rate_Plan__r.zqu__ZProduct__r.Id); 
            }
        } // Code Review Implementation 2/17/2015 JAlejandro
        return lstZProductIDs;
    }
    
    public static Decimal calculatePostageCharge(String strZone, List<ID> lstZProductIDs)
    {
        Decimal amtPostage = 0.0;   
        //Used to get the latest charge by Effective Date
        Map<ID, Decimal> mByProduct = new Map<ID, Decimal>();
        
        //filters null values of strZone, and null and empty values of lstZProductIDs.
        // START: Code Review Implementation 2/17/2015 JAlejandro
        if (!lstZProductIDs.isEmpty() && strZone != null) 
        { // END: Code Review Implementation 2/17/2015 JAlejandro
            for(Zone_Product__c zoneProduct :  [SELECT Product__c, Postage_Charge__c, Effective_Start_Date__c FROM Zone_Product__c  
                 WHERE Zone__r.Name =:strZone AND Product__c in :lstZProductIDs AND Effective_Start_Date__c <= TODAY
                 ORDER BY Product__c, Effective_Start_Date__c DESC])
            {
                ID productID = zoneProduct.Product__c;
                if(!mByProduct.containsKey(productID))
                    mByProduct.put(productID,zoneProduct.Postage_Charge__c);
            }
                      
        //Sum the Postage Charges of all products
            for(ID productID : lstZProductIDs)
            {
                if(mByProduct.containsKey(productID))
                    amtPostage += mByProduct.get(productID);
                //START D-1970 28/01/15 Wenjun : throw Error Message if no posatge charge configured
                else 
                    throw new CustomException(System.Label.ERR_NO_POSTAGE_CHARGE + ' : Combination: ' + strZone + productID);
                //END D-1970 28/01/15 Wenjun
            }
        } // Code Review Implementation 2/17/2015 JAlejandro
        return amtPostage;
    }
    
    //START D-1826 19/01/2015 Wenjun : Utility Methods to support Batch Processing of Bulk Records
    public static Map<Id, Decimal> getPostageChargesForLineItems(Map<Id,Id> mapOrderIdToContactId, List<Order_Line_Item__c> lstItems)
    { 
        Map<Id, Decimal> mapItemIdToPostageCharge = new Map<Id, Decimal>();
         // START: Code Review Implementation 2/17/2015 JAlejandro
        Map<Id, Contact> mapContacts = new Map<ID, Contact>();
        //Retrieve Contacts Map for getting Zone Info
        if (!mapOrderIdToContactId.values().isEmpty())
        { 
            mapContacts.putAll([SELECT Id, Address__c, Address__r.Address_Type__c, Zone__c 
                                        FROM Contact WHERE Id in :mapOrderIdToContactId.values()]);
        }
        
        else 
        {
            mapContacts = new Map<ID, Contact>();
        }// END: Code Review Implementation 2/17/2015 JAlejandro
        //Create Order ID to Zone Map and Zone Set
        Map<Id, String> mapOrderIdToZone = new Map<Id, String>();
        Set<String> setZones = new Set<String>();
        
        for(Id idOrder : mapOrderIdToContactId.keySet())
        {
            Id idContact = mapOrderIdToContactId.get(idOrder);
            if(mapContacts.containsKey(idContact) && mapContacts.get(idContact).Zone__c != NULL)
            {
                mapOrderIdToZone.put(idOrder, mapContacts.get(idContact).Zone__c);
                setZones.add(mapContacts.get(idContact).Zone__c);
            }
            else
                throw new CustomException(System.Label.ERR_CONTACT_NO_ZONE + ' : Order ID: ' + idOrder);
        }

        //Get all the packages
        List<ID> lstPackageID = new List<ID>();
        for(Order_Line_Item__c itemObj : lstItems)
        {
            if(itemObj.Main_Package_ID__c != NULL)
                lstPackageID.add(itemObj.Main_Package_ID__c);
            if(itemObj.Addon_Package__c != NULL)
                lstPackageID.add(itemObj.Addon_Package__c);
        }
        
        //Get Package ID to ZProduct ID Mapping
        Map<Id,List<Id>> mapPkgIdToProdIds = getPackageToProductsMap(lstPackageID);
        
        //Generate the product ID set
        Set<Id> setProdIDs = new Set<Id>();
        for(Id idPackage : mapPkgIdToProdIds.keySet())
        {
            for(Id idProd : mapPkgIdToProdIds.get(idPackage))
                setProdIDs.add(idProd);
        }
        
        //Get the Postage for each Zone and Product combination
        Map<String, Decimal> mapPostageCharges = getPostageCharges(setZones, setProdIDs);
        
        //Sum Postage by Order Line Item
        for(Order_Line_Item__c itemObj : lstItems)
        {
            Decimal itemPostageChargeAmt = 0.0;
            ID parentOrderId = itemObj.Order__c;
            String strZone = mapOrderIdToZone.get(parentOrderId);
            
            //All the products related to this Order Line Item
            Set<ID> setPackProdIDs = new Set<ID>();
            if(itemObj.Main_Package_ID__c != NULL)
                setPackProdIDs.addAll(mapPkgIdToProdIds.get(itemObj.Main_Package_ID__c));
            if(itemObj.Addon_Package__c != NULL)
                setPackProdIDs.addAll(mapPkgIdToProdIds.get(itemObj.Addon_Package__c));
            
            for(Id tmpProdID : setPackProdIDs)
            {
                String strKey = strZone.toUpperCase() + tmpProdID;
                if(mapPostageCharges.containsKey(strKey))
                    itemPostageChargeAmt += mapPostageCharges.get(strKey);
                else
                    throw new CustomException(System.Label.ERR_NO_POSTAGE_CHARGE + ' : Combination: ' + strKey);
            }
            
            mapItemIdToPostageCharge.put(itemObj.Id, itemPostageChargeAmt);
        } // End of For
        
        return mapItemIdToPostageCharge;
    }
    
    public static Map<Id,List<Id>> getPackageToProductsMap(List<ID> lstPackageID)
    {
        Map<Id,List<Id>> mapPkgIdToProdId = new Map<Id,List<Id>>();

        // START: Code Review Implementation 2/17/2015 JAlejandro
        if (!lstPackageID.isEmpty())
        { // END: Code Review Implementation 2/17/2015 JAlejandro
            for(Package_Item__c pItem: [SELECT Name, Id,  Package__r.Id, RecordType.DeveloperName,
                                               Product_Rate_Plan__r.zqu__ZProduct__r.Id
                                               FROM Package_Item__c WHERE Package__c in: lstPackageID])
            {
                if(pItem.RecordType.DeveloperName.contains('Product'))
                {
                    if(!mapPkgIdToProdId.containsKey(pItem.Package__c))
                        mapPkgIdToProdId.put(pItem.Package__c, new List<Id> ());
                        
                     mapPkgIdToProdId.get(pItem.Package__c).add(pItem.Product_Rate_Plan__r.zqu__ZProduct__r.Id);
                }
            }
        }// Code Review Implementation 2/17/2015 JAlejandro
        return mapPkgIdToProdId;
    }
    
    public static Map<String, Decimal> getPostageCharges(Set<String> setZones, Set<Id> setProdIDs)
    {
        Map<String, Decimal> mapPostageCharges = new Map<String, Decimal>();
        
        //Get the latest charge by Effective Date
        // START: Code Review Implementation 2/17/2015 JAlejandro
        if (!setZones.isEmpty() && !setProdIDs.isEmpty())
        { // END: Code Review Implementation 2/17/2015 JAlejandro
            for(Zone_Product__c zoneProduct :  [SELECT Zone__r.Name, Product__c, Postage_Charge__c, Effective_Start_Date__c FROM Zone_Product__c  
                 WHERE Zone__r.Name in :setZones AND Product__c in :setProdIDs AND Effective_Start_Date__c <= TODAY
                 ORDER BY Zone__r.Name, Product__c, Effective_Start_Date__c DESC])
            {
                String strKey = zoneProduct.Zone__r.Name.toUpperCase() + zoneProduct.Product__c;
                if(!mapPostageCharges.containsKey(strKey))
                    mapPostageCharges.put(strKey,zoneProduct.Postage_Charge__c);
            }
        } // Code Review Implementation 2/17/2015 JAlejandro
        return mapPostageCharges;
    }
    //END D-1826 19/01/2015 Wenjun
    // START : UD-3510 1/8/2016 Alyana Navarro
    /** 
     ** @Description: Created for Renewal Letter.          
     **/
    public static Map<Id, Decimal> getPostageChargeForLineItemRenewalLetter(Map<Id, Order_Line_Item__c> orderLineItemMap, Map<Id, Id> orderLIRecipientContactIdMap){ 
        Order_Line_Item__c orderLineItemRec = new Order_Line_Item__c();     
        Map<Id, String> oLIRecipientContactZoneMap = new Map<Id, String>();
        Map<Id, Set<Id>> orderLineItemProductIdSetMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> orderLineItemPackageIdSetMap = new Map<Id, Set<Id>>();
        Map<Id, Contact> recipentContactMap = new Map<Id, Contact>([SELECT Id, Address__c, Address__r.Address_Type__c, Zone__c 
                                                                    FROM Contact 
                                                                    WHERE Id IN: orderLIRecipientContactIdMap.values()]);
        
        if(recipentContactMap.size() > 0){
            for(Id orderLineItemId : orderLIRecipientContactIdMap.keySet()){
                orderLineItemRec = orderLineItemMap.get(orderLineItemId);               
                
                if(recipentContactMap.containsKey(orderLIRecipientContactIdMap.get(orderLineItemId))){
                    oLIRecipientContactZoneMap.put(orderLineItemId, recipentContactMap.get(orderLIRecipientContactIdMap.get(orderLineItemId)).Zone__c);
                }                               
                
                if(orderLineItemRec.Main_Package_ID__c != null){
                    orderLineItemPackageIdSetMap.put(orderLineItemRec.id, new Set<Id>{orderLineItemRec.Main_Package_ID__c});
                }
                if(orderLineItemRec.Addon_Package__c != null){
                    if(orderLineItemPackageIdSetMap.containsKey(orderLineItemRec.id)){
                        orderLineItemPackageIdSetMap.get(orderLineItemRec.id).add(orderLineItemRec.Addon_Package__c);
                    } else {
                        orderLineItemPackageIdSetMap.put(orderLineItemRec.id, new Set<Id>{orderLineItemRec.Main_Package_ID__c});
                    }
                }
            }
        }
        
        orderLineItemProductIdSetMap = getZProductIDsByPackageIDsForRenewalLetter(orderLineItemPackageIdSetMap);
        return calculatePostageChargeRenewalLetter(oLIRecipientContactZoneMap, orderLineItemProductIdSetMap);
    }
    
    /** 
     ** @Description: Created for Renewal Letter. 
     **/
    public static Map<Id, Set<Id>> getZProductIDsByPackageIDsForRenewalLetter(Map<Id, Set<Id>>  orderLineItemPackageIdSetMap) {
        Set<Id> packageIdSet = new Set<Id>();
        Map<Id, Set<Id>> orderLineItemProductIdMap = new Map<Id, Set<Id>>();
        Map<Id, List<Package_Item__c>> packagePackageItemMap = new Map<Id, List<Package_Item__c>>();
        
        for(Id packageId : orderLineItemPackageIdSetMap.keySet()){
            packageIdSet.addAll(orderLineItemPackageIdSetMap.get(packageId));
        }
        
        List<Package_Item__c> packageItemList = [SELECT Name, Id,  Package__r.Id, RecordType.DeveloperName, Product_Rate_Plan__r.zqu__ZProduct__r.Id
                                                 FROM Package_Item__c 
                                                 WHERE Package__c IN: packageIdSet];
                                                 
        for(Package_Item__c packageItem : packageItemList){
            if(packagePackageItemMap.containsKey(packageItem.Package__c)){
                packagePackageItemMap.get(packageItem.Package__c).add(packageItem);
            } else {
                packagePackageItemMap.put(packageItem.Package__c, new List<Package_Item__c>{packageItem});
            }
        }
        
        for(Id orderLineItemId : orderLineItemPackageIdSetMap.keySet()){
            for(Id packageId : orderLineItemPackageIdSetMap.get(orderLineItemId)){
                if(packagePackageItemMap.containsKey(packageId)){
                    for(Package_Item__c packageItem : packagePackageItemMap.get(packageId)){
                        if(packageItem.RecordType.DeveloperName.contains('Product')){
                            if(orderLineItemProductIdMap.containsKey(orderLineItemId)){
                                orderLineItemProductIdMap.get(orderLineItemId).add(packageItem.Product_Rate_Plan__r.zqu__ZProduct__r.Id); 
                            } else {
                                orderLineItemProductIdMap.put(orderLineItemId, new Set<Id>{packageItem.Product_Rate_Plan__r.zqu__ZProduct__r.Id});
                            }
                        }
                    }
                }
            }
        }
        
        return orderLineItemProductIdMap;
    }
    
    /** 
     ** @Description: Created for Renewal Letter. 
     **/
    public static Map<Id, Decimal> calculatePostageChargeRenewalLetter(Map<Id, String> oLIRecipientContactZoneMap, Map<Id, Set<Id>> orderLineItemProductIdSetMap) { 
        Decimal amtPostage = 0.0;
        Set<Id> productIdSet = new Set<Id>();
        List<Zone_Product__c> zoneProductList = new List<Zone_Product__c>();    
        Map<Id, Decimal> orderLineItemPostageMap = new Map<Id, Decimal>();
        Map<Id, Map<String, Zone_Product__c>> productIdZoneProductMap = new Map<Id, Map<String, Zone_Product__c>>();
        
        for(Id orderLineItemId : orderLineItemProductIdSetMap.keySet()){
            productIdSet.addAll(orderLineItemProductIdSetMap.get(orderLineItemId));
        }
        
        zoneProductList = [SELECT Product__c, Postage_Charge__c, Effective_Start_Date__c, Zone__r.Name, Zone__c
                           FROM Zone_Product__c
                           WHERE Zone__r.Name =: oLIRecipientContactZoneMap.values()
                                AND Product__c IN: productIdSet
                                AND Effective_Start_Date__c <= TODAY
                           ORDER BY Product__c, Effective_Start_Date__c DESC];
                           
        for(Zone_Product__c zoneProduct : zoneProductList){
            if(productIdZoneProductMap.containsKey(zoneProduct.Product__c)){
                if(!productIdZoneProductMap.get(zoneProduct.Product__c).containsKey(zoneProduct.Zone__r.Name)){
                    productIdZoneProductMap.get(zoneProduct.Product__c).put(zoneProduct.Zone__r.Name, zoneProduct);
                }
            } else {
                productIdZoneProductMap.put(zoneProduct.Product__c, new Map<String, Zone_Product__c>{zoneProduct.Zone__r.Name => zoneProduct});
            }
        }

        for(Id orderLineItemId : orderLineItemProductIdSetMap.keySet()){
            amtPostage = 0.0;
            for(Id productId : orderLineItemProductIdSetMap.get(orderLineItemId)){
                if(productIdZoneProductMap.containsKey(productId) && oLIRecipientContactZoneMap.containsKey(orderLineItemId)){
                    if(productIdZoneProductMap.get(productId).containsKey(oLIRecipientContactZoneMap.get(orderLineItemId))){
                        amtPostage += productIdZoneProductMap.get(productId).get(oLIRecipientContactZoneMap.get(orderLineItemId)).Postage_Charge__c;
                    }
                }
            }
            
            orderLineItemPostageMap.put(orderLineItemId, amtPostage);
        }

        return orderLineItemPostageMap;
    }
    // END : UD-3510 1/8/2016 Alyana Navarro
}