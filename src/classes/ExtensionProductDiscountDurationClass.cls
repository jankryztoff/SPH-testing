/**
 * Class Name: ExtensionProductDiscountDurationClass
 * @author: Manolo Valeña
 * Date: 1/14/2015
 * Requirement/Project Name: SPH
 * @description: D-1383 - Extension Discount package item must have the same duration as that of the Extension Product package item.
 */

public class ExtensionProductDiscountDurationClass
{
    String packageId;
    String duration;
    List<Package_Item__c> currentPackageItems;
    Id[] packageIds;
    Id[] productFamilyIds;
    Map<Id, Package__c> packagesMap;
    
    public void ExtensionProductDiscountDuration(List<Package_Item__c> newPackageItems)
    {
        packageIds = new Id[]{};
        productFamilyIds = new Id[]{};
        
        for (Package_Item__c currentPackItem : newPackageItems)
        {
			//START 02/18/2015 - Added by Rom Edison Reyes - Checks if currentPackItem.Package__c is not null before adding to packageIds
			if(currentPackItem.Package__c != null){
				packageIds.add(currentPackItem.Package__c);
			}//END 02/18/2015 - Added by Rom Edison Reyes - Checks if currentPackItem.Package__c is not null before adding to packageIds
            productFamilyIds.add(currentPackItem.Product_Family__c); 
        }
        //START 02/18/2015 - Added by Rom Edison Reyes - Checks if packageIds has values
		if(packageIds.size()>0){
			packagesMap = new Map<Id, Package__c>([Select Id, Name, Package_Type__c, Package_Sub_Type__c from Package__c where Id in :packageIds]);
        
			for(Package_Item__c packageItems : newPackageItems)
			{
				if (packagesMap.containsKey(packageItems.Package__c))
				{
					if(packagesMap.get(packageItems.Package__c).Package_Type__c == 'Discount' && packagesMap.get(packageItems.Package__c).Package_Sub_Type__c == 'Extension' && packageItems.RecordTypeId == constantsSLB.getKeyID('Package Item_Extension Discount'))
					{
						packageId = packagesMap.get(packageItems.Package__c).Id;
					}
				}
			}
        }//END 02/18/2015 - Added by Rom Edison Reyes - Checks if packageIds has values
        
        if(packageId != null)
        {
            currentPackageItems = [SELECT Name, RecordType.Name, RecordTypeId, Product_Family__r.Id, 
                                          Product_Rate_Plan__r.zqu__ZProduct__r.ProductFamily__c, Duration_in_months__c
                                   FROM Package_Item__c 
                                   WHERE Package__r.Id =: packageId AND RecordType.Name = 'Extension Product' 
                                   LIMIT 1];
                                                    
            if(!currentPackageItems.isEmpty())
            {
                duration = currentPackageItems[0].Duration_in_months__c;
                for(Package_Item__c packageItems : newPackageItems)
                {
                    if (packagesMap.containsKey(packageItems.Package__c))
                    {
                        if(!(duration == packageItems.Duration_in_months__c) && packagesMap.get(packageItems.Package__c).Package_Type__c == 'Discount' && packagesMap.get(packageItems.Package__c).Package_Sub_Type__c == 'Extension' && packageItems.RecordTypeId == constantsSLB.getKeyID('Package Item_Extension Discount'))
                        {
                            packageItems.addError('Extension Discount duration must be the same as the Extension Product duration');
                        }
                    }
                }
            }
        }
    }
}