public class BundlePackageOneBundleDiscountClass
{
    String packageId;
    String basePackItemId;
    String basePackageItem;
    List<Package_Item__c> currentPackageItems;
    Package_Item__c currentPackageItems1;
    Id[] packageIds;
    Id[] basePackageItemIds;
    Map<Id, Package__c> packagesMap;
    Map<Id, Package_Item__c> basePackageItemsMap;
    
    public void BundlePackageOneBundleDiscount(List<Package_Item__c> newPackageItems)
    {
        currentPackageItems = new List<Package_Item__c>();
        packageIds = new Id[]{};
        basePackageItemIds = new Id[]{};
        for (Package_Item__c currentPackItem : newPackageItems)
        {
            packageIds.add(currentPackItem.Package__c);
            basePackageItemIds.add(currentPackItem.Base_Package_Item__c);  
        }
        //START: Tine Code Review
        if(packageIds != null){
			packagesMap = new Map<Id, Package__c>([Select Id, Name, Package_Type__c, Package_Sub_Type__c from Package__c where Id in :packageIds]);
		}
		if(basePackageItemIds !=null){
			basePackageItemsMap = new Map<Id, Package_Item__c>([Select Id, Name, Bundle_Item_No__c from Package_Item__c where Id in :basePackageItemIds]);
		}
        //END: Tine Review
        for(Package_Item__c packageItems : newPackageItems)
        {
            if (packagesMap.containsKey(packageItems.Package__c) && basePackageItemsMap.containsKey(packageItems.Base_Package_Item__c))
            {
                if(packagesMap.get(packageItems.Package__c).Package_Type__c == GlobalVariableClass.PACKAGETYPE_BUNDLE && packageItems.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Discount'))
                {
                    packageId = packagesMap.get(packageItems.Package__c).Id;
                    basePackItemId = basePackageItemsMap.get(packageItems.Base_Package_Item__c).Id;
                }
            }
        }
        //START: Tine Code Review - null not yet fixed
        if(packageId != null && basePackItemId != null)
        {
            currentPackageItems = [SELECT Id, Name, RecordType.Name, RecordTypeId, Base_Package_Item__r.Id, Bundle_Item_No__c
                                    FROM Package_Item__c 
                                    WHERE Package__r.Id =: packageId AND RecordType.Name = 'Bundle Discount' AND Base_Package_Item__r.Id =: basePackItemId AND Base_Package_Item__r.Id != Null  
                                    LIMIT 1];
                                                        
            if(!currentPackageItems.isEmpty())
            {
                basePackageItem = currentPackageItems[0].Base_Package_Item__r.Id;
                
                for(Package_Item__c packageItems : newPackageItems)
                {
                    if (packagesMap.containsKey(packageItems.Package__c) && basePackageItemsMap.containsKey(packageItems.Base_Package_Item__c))
                    {
                        if((basePackageItem == basePackageItemsMap.get(packageItems.Base_Package_Item__c).Id) && packagesMap.get(packageItems.Package__c).Package_Type__c == GlobalVariableClass.PACKAGETYPE_BUNDLE && packageItems.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Discount'))
                        {
                            packageItems.addError('There is already a Bundle Discount Package Item connected to the selected Bundle Product. Please select a different Bundle Product');
                        }
                    }
                }
            }
            
            currentPackageItems1 = new Package_Item__c();
            
            try
            {
                currentPackageItems1 = [SELECT Id
                                    FROM Package_Item__c 
                                    WHERE Package__r.Id =: packageId AND RecordType.Name = 'Bundle Product'
                                    LIMIT 1];
            }
            catch(exception e)
            {
                currentPackageItems1 = Null;
            }
            
            if(currentPackageItems1 == Null)
            {
                for(Package_Item__c packageItems : newPackageItems)
                {
                    if(packagesMap.get(packageItems.Package__c).Package_Type__c == GlobalVariableClass.PACKAGETYPE_BUNDLE && packageItems.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Discount'))
                    //if((basePackageItem == basePackageItemsMap.get(packageItems.Base_Package_Item__c).Id) && packagesMap.get(packageItems.Package__c).Package_Type__c == 'Bundle' && packageItems.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Discount'))
                    {
                        packageItems.addError('A Bundle Product Package Item must first be created before adding a Bundle Discount Package item');
                    }
                }
            }
        }
    }
}