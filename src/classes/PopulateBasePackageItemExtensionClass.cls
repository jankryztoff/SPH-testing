public class PopulateBasePackageItemExtensionClass
{
    String packageId;
    String basePackageId;
    Id[] packageIds;
    Map<Id, Package__c> packagesMap;
    List<Package_Item__c> currentPackageItems;

    public void PopulateBasePackageItemExtension(List<Package_Item__c> newPackageItems)
    {
        packageIds = new Id[]{};
        for (Package_Item__c currentPackItem : newPackageItems)
        {
            packageIds.add(currentPackItem.Package__c);
        }
		// START: Code Review Implementation 2/12/2015 JAlejandro
        if (!packageIds.isEmpty())
		{// END: Code Review Implementation 2/12/2015 JAlejandro
			packagesMap = new Map<Id, Package__c>([Select Id from Package__c where Id in :packageIds]);
        
			for(Package_Item__c packageItem : newPackageItems)
			{
				If(packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Extension Discount'))
				{
					if (packagesMap.containsKey(packageItem.Package__c))
					{
						packageId = packagesMap.get(packageItem.Package__c).Id;
					}
				}
			}
        }
        if(packageId != null)
        {
            currentPackageItems = [SELECT Id, Name, RecordType.Name, RecordTypeId, Base_Package_Item__r.Id, Bundle_Item_No__c
                                    FROM Package_Item__c 
                                    WHERE Package__r.Id =: packageId AND RecordType.Name = 'Extension Product' 
                                    LIMIT 1];
            
            if(!currentPackageItems.isEmpty())
            {
                basePackageId = currentPackageItems[0].Id;
            }
            
            for(Package_Item__c packageItem : newPackageItems)
            {
                If(packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Extension Discount'))
                {
                    packageItem.Base_Package_Item__c = basePackageId;
                }
            }
        }
    }
}