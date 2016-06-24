/**
 * Class Name: <PackageItemTriggerHandler>
 * @author: <KristineCampang>
 * Date: <10/16/2014>
 * Requirement/Project Name: <SPH>
 * @description<To populate Package Price base on created Package Items>
 * History: 17/02/2015 Wenjun: Code Review Fix - Restructure the class
 */

public class PackageItemTriggerHandler{
    
    //Before Insert logic - Call separate method for detail processing - Leave Blank for not in use
    public void doBeforeInsert(List<Package_Item__c> lstNewPkgItems)
    {
        processPkgItems(lstNewPkgItems);
        checkBillingType(lstNewPkgItems);
    }
    
    //After Insert logic - Call separate method for detail processing - Leave Blank for not in use
    public void doAfterInsert(List<Package_Item__c> lstNewPkgItems, Map<Id, Package_Item__c> mapNewPkgItems)
    {
        postPriceComputation(lstNewPkgItems);
    }
    
    //Before Update logic - Call separate method for detail processing - Leave Blank for not in use
    public void doBeforeUpdate(List<Package_Item__c> lstNewPkgItems, Map<Id, Package_Item__c> mapNewPkgItems,
                               List<Package_Item__c> lstOldPkgItems, Map<Id, Package_Item__c> mapOldPkgItems)
    {
        processPkgItems(lstNewPkgItems);
        //Note: Wenjun - the following codes actually prevents updating Billing Type for Bundle Package Item
        //checkBillingType(lstNewPkgItems);
    }

    //After Update logic - Call separate method for detail processing - Leave Blank for not in use
    public void doAfterUpdate(List<Package_Item__c> lstNewPkgItems, Map<Id, Package_Item__c> mapNewPkgItems,
                               List<Package_Item__c> lstOldPkgItems, Map<Id, Package_Item__c> mapOldPkgItems)
    {
		//START D-2327 27/02/15 Wenjun : Post Update only if Base Package Item, Product Family or Rate Plan is updated
		List<Package_Item__c> lstItemsToProcess = new List<Package_Item__c>();
		for(Package_Item__c item : lstNewPkgItems)
		{
			if(item.Base_Package_Item__c != mapOldPkgItems.get(item.Id).Base_Package_Item__c
			|| item.Product_Family__c != mapOldPkgItems.get(item.Id).Product_Family__c
			|| item.Product_Rate_Plan__c != mapOldPkgItems.get(item.Id).Product_Rate_Plan__c)
				lstItemsToProcess.add(item);
		}
		
		if(!lstItemsToProcess.isEmpty())
			postPriceComputation(lstItemsToProcess);
		//END D-2327 27/02/15 Wenjun
    }
    
    //Before Delete logic - Call separate method for detail processing - Leave Blank for not in use
    public void doBeforeDelete(List<Package_Item__c> lstOldPkgItems, Map<Id, Package_Item__c> mapOldPkgItems)
    {
        //START D-0828 1/7/2015 Added By C. Lin - Recalculates the package price during deletion of a package item
        PackagePriceComputation pckComputation = new PackagePriceComputation();
        pckComputation.deletePackageItems(lstOldPkgItems);
        //END D-0828 1/7/2015 Added By C. Lin
    }
    
    //After Delete logic - Call separate method for detail processing - Leave Blank for not in use
    public void doAfterDelete(List<Package_Item__c> lstOldPkgItems, Map<Id, Package_Item__c> mapOldPkgItems)
    {}
        
    private void processPkgItems(List<Package_Item__c> packItemList) {
        //START D-0840 12/11/2014 Added by Manolo Vale�a - added trigger.isUpdate to condition and also called method of PopulateProductFamilyClass 
        DiscountEffectiveStartMonthClass des = new DiscountEffectiveStartMonthClass();
        des.DiscountEffectiveStartMonth(packItemList);
        
        BaseExtensionProductFamilyClass bep = new BaseExtensionProductFamilyClass();
        bep.BaseExtensionProductFamily(packItemList);
        
        BundlePackageOneBundleDiscountClass bpb = new BundlePackageOneBundleDiscountClass();
        bpb.BundlePackageOneBundleDiscount(packItemList);
        
        PopulateBasePackageItemExtensionClass pbp = new PopulateBasePackageItemExtensionClass();
        pbp.PopulateBasePackageItemExtension(packItemList);
        
        PopulateBasePackageItemClass pbpi = new PopulateBasePackageItemClass();
        pbpi.PopulateBasePackageItem(packItemList);
        
        RenewalPackageCodePopulateClass rpc = new RenewalPackageCodePopulateClass();
        rpc.RenewalPackageCodePopulate(packItemList);
        
        PopulateProductFamilyClass populateProductFam = new PopulateProductFamilyClass();
        populateProductFam.PopulateProductFamily(packItemList);
        
        //START D-1383 1/14/2015 Added by Manolo Vale�a - Added trigger to allow show error message if Extension Discount package item does not have the same duration as that of the Extension Product package item.
        ExtensionProductDiscountDurationClass epdd = new ExtensionProductDiscountDurationClass();
        epdd.ExtensionProductDiscountDuration(packItemList);
        //END D-1383 1/14/2015 Added by Manolo Vale�a
        //END D-0840 12/11/2014 Added by Manolo Vale�a
    }
        
    private void postPriceComputation(List<Package_Item__c> packItemList) {
        PackagePriceComputation pckComputation = new PackagePriceComputation();
        pckComputation.processPackageItems(packItemList);
    }
    
    //Note: Wenjun - the following codes does not verify the records in the same trigger batch
    //START D-0679 12/2/2014 Added by JB Domingo
    private void checkBillingType(List<Package_Item__c> packItemList){
        String bundleProductStr = ConstantsSLB.getKeyId('Package Item_Bundle Product');
        
        Map<Id, Id> mapPkgItemIdToPkgId = new Map<Id, Id>();
        Map<Id, Package_Item__c> mapPkgIdToPkgItem = new Map<Id, Package_Item__c>(); //Just compare with any of the Item inside the Package
        for(Package_Item__c newItem : packItemList)
        {
            if(String.valueOf(newItem.RecordTypeId) == bundleProductStr)
                mapPkgItemIdToPkgId.put(newItem.Id, newItem.Package__c);
        }
        
        List<Package_Item__c> existingItemList = [SELECT Id, Billing_Type__c, Package__c FROM Package_Item__c 
                        WHERE Package__c in : mapPkgItemIdToPkgId.values() AND RecordTypeId =: bundleProductStr];
                        
        for(Package_Item__c currentItem: existingItemList)
        {
            mapPkgIdToPkgItem.put(currentItem.Package__c, currentItem);
        }
                        
        for(Package_Item__c newItem : packItemList)
        {   
            if(mapPkgItemIdToPkgId.containsKey(newItem.Id))
            {
                Id pkgId = mapPkgItemIdToPkgId.get(newItem.Id);
                if(mapPkgIdToPkgItem.containsKey(pkgId))
                {
                    Package_Item__c existingItem =  mapPkgIdToPkgItem.get(pkgId);
                    if(newItem.Billing_Type__c != existingItem.Billing_Type__c){
                        newItem.addError('The Billing type of the Product Rate Plan should be '+ existingItem.Billing_Type__c+'.');
                    }
                }
            }
        }
    }
    //END D-0679 12/2/2014 Added by JB Domingo  	
}