public class BaseExtensionProductFamilyClass
{
    String packageId;
    String productFamily;
    List<Package_Item__c> currentPackageItems;
    Id[] packageIds;
    Id[] productFamilyIds;
    Id[] PRPIds;
    Map<Id, Package__c> packagesMap;
    Map<Id, zqu__ProductRatePlan__c> PRPMap;
    
    public void BaseExtensionProductFamily(List<Package_Item__c> newPackageItems)
    {
        packageIds = new Id[]{};
        productFamilyIds = new Id[]{};
        PRPIds = new Id[]{};
        
        for (Package_Item__c currentPackItem : newPackageItems)
        {
            packageIds.add(currentPackItem.Package__c);
            productFamilyIds.add(currentPackItem.Product_Family__c);
            PRPIds.add(currentPackItem.Product_Rate_Plan__c);  
        }
        //START: Code Review 02/18/2015 Added by Kristine Campang
        if(packageIds.size()>0){
            packagesMap = new Map<Id, Package__c>([Select Id, Name, Package_Type__c, Package_Sub_Type__c from Package__c where Id in :packageIds]);
        }
        if(PRPIds.size()>0){
            PRPMap = new Map<Id, zqu__ProductRatePlan__c>([SELECT zqu__ZProduct__r.ProductFamily__c FROM zqu__ProductRatePlan__c WHERE Id in :PRPIds]);
        }
        
        
        for(Package_Item__c packageItems : newPackageItems)
        {
            if (packagesMap.containsKey(packageItems.Package__c))
            {
                if(packagesMap.get(packageItems.Package__c).Package_Type__c == GlobalVariableClass.PACKAGETYPE_DISCOUNT && packagesMap.get(packageItems.Package__c).Package_Sub_Type__c == 'Extension' && packageItems.RecordTypeId == constantsSLB.getKeyID('Package Item_Extension Product'))
                {
                    packageId = packagesMap.get(packageItems.Package__c).Id;
                }
            }
        }
        
        if(packageId != null)
        {
            currentPackageItems = [SELECT Name, RecordType.Name, RecordTypeId, Product_Family__r.Id, Product_Rate_Plan__r.zqu__ZProduct__r.ProductFamily__c
                                                    FROM Package_Item__c 
                                                    WHERE Package__r.Id =: packageId AND RecordType.Name = 'Base Product' 
                                                    LIMIT 1];
                                                    
            if(currentPackageItems.size()>0)
            {
                productFamily = currentPackageItems[0].Product_Rate_Plan__r.zqu__ZProduct__r.ProductFamily__c;
                //System.Debug('@@@@@@@@@@@@@@@@' + productFamily);
                for(Package_Item__c packageItems : newPackageItems)
                {
                    //System.Debug('@@@@@@@@@@@@@@@@' + PRPMap.get(packageItems.Product_Rate_Plan__c).zqu__ZProduct__r.ProductFamily__c);
                    if (packagesMap.containsKey(packageItems.Package__c) && PRPMap.containsKey(packageItems.Product_Rate_Plan__c))
                    {
                        //START D-1389 1/14/2015 Added by Manolo Vale�a - Added an if statement to check if PRPMap contains packageItems.Product_Rate_Plan__c. This should fix the Null Pointer Exception error.
                        if(PRPMap.containsKey(packageItems.Product_Rate_Plan__c))
                        {
                            if(!(productFamily.Equals(PRPMap.get(packageItems.Product_Rate_Plan__c).zqu__ZProduct__r.ProductFamily__c)) && packagesMap.get(packageItems.Package__c).Package_Type__c == GlobalVariableClass.PACKAGETYPE_DISCOUNT && packagesMap.get(packageItems.Package__c).Package_Sub_Type__c == 'Extension' && packageItems.RecordTypeId == constantsSLB.getKeyID('Package Item_Extension Product'))
                            {
                                //packageItems.addError('This Extension Product must have the same Product Family as the Base Product of this package. Please change the \'Product Rate Plan\' to match with Product Family of Base Product');
                                packageItems.addError('Both Base Product and Extension Product must belong to the same product family');
                            }
                        }
                        //START D-1389 1/14/2015 Added by Manolo Vale�a
                    }
                }
            }
            //END: Code Review 02/18/2015 Added by Kristine Campang
        }
    }
}