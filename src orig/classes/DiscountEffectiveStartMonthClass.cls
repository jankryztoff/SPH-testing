public class DiscountEffectiveStartMonthClass
{
    String packageId;
    String startMonth;
    String duration;
    List<Package_Item__c> currentPackageItems;
    Id[] packageIds;
    Map<Id, Package__c> packagesMap;
    //START:D-2949 5/21/15 Added by Manolo Valena - Added new Set variable.
    Set<Id> packageItemsIdSet = new Set<Id>();
    //END:D-2949 5/21/15 Added by Manolo Valena
    
    public void DiscountEffectiveStartMonth(List<Package_Item__c> newPackageItems)
    {
        packageIds = new Id[]{};
        for (Package_Item__c currentPackItem : newPackageItems)
        {
            //START 02/18/2015 - Added by Rom Edison Reyes - Checks if currentPackItem.Package__c is not null before adding to packageIds
            if(currentPackItem.Package__c != null){
                packageIds.add(currentPackItem.Package__c);  
            }//END 02/18/2015 - Added by Rom Edison Reyes - Checks if currentPackItem.Package__c is not null before adding to packageIds            
        }
        system.debug('>>>CHA limits.getQueries()' + limits.getQueries());
        //START 02/18/2015 - Added by Rom Edison Reyes - Checks if packageIds has values
        if(packageIds.size()>0){
            packagesMap = new Map<Id, Package__c>([Select Id, Name, Package_Type__c, Package_Sub_Type__c from Package__c where Id in :packageIds]); 
        }//END 02/18/2015 - Added by Rom Edison Reyes - Checks if packageIds has values
        
        for(Package_Item__c packageItems : newPackageItems)
        {
            if (packagesMap.containsKey(packageItems.Package__c))
            {
                if(packagesMap.get(packageItems.Package__c).Package_Type__c == 'Discount' && packagesMap.get(packageItems.Package__c).Package_Sub_Type__c == 'Tiered' && packageItems.RecordTypeId == constantsSLB.getKeyID('Package Item_Discount'))
                {
                    packageId = packagesMap.get(packageItems.Package__c).Id;
                    //START:D-2949 5/21/15 Added by Manolo Valena - Populate set variable with package item Ids.
                    packageItemsIdSet.add(packageItems.Id);
                    //END:D-2949 5/21/15 Added by Manolo Valena
                }
            }
        }
        
        if(packageId != null)
        {
            currentPackageItems = [SELECT Name, RecordType.Name, RecordTypeId, Effective_Start_Month__c, Duration_in_months__c 
                                                    FROM Package_Item__c 
                                                    WHERE Package__r.Id =: packageId AND RecordType.Name = 'Discount'
                                                    //START:D-2949 5/21/15 Added by Manolo Valena - Additional condition to only get the old package items. 
                                                    AND Id NOT IN : packageItemsIdSet 
                                                    //END:D-2949 5/21/15 Added by Manolo Valena
                                                    ORDER BY CreatedDate DESC LIMIT 1];
        
            if(!currentPackageItems.isEmpty())
            {
                startMonth = currentPackageItems[0].Effective_Start_Month__c;
                if(currentPackageItems[0].Duration_in_months__c == Null)
                {
                    duration = '0';
                }
                else
                {
                    duration = currentPackageItems[0].Duration_in_months__c;
                }
                
                for(Package_Item__c packageItems : newPackageItems)
                {
                    if (packagesMap.containsKey(packageItems.Package__c))
                    {
                        if((integer.valueOf(packageItems.Effective_Start_Month__c) != integer.valueOf(startMonth) + integer.valueOf(duration)) && packagesMap.get(packageItems.Package__c).Package_Type__c == 'Discount' && packagesMap.get(packageItems.Package__c).Package_Sub_Type__c == 'Tiered' && packageItems.RecordTypeId == constantsSLB.getKeyID('Package Item_Discount'))
                        {
                            packageItems.addError('Please select the Effective Start Month value of \'' + (integer.valueOf(startMonth) + integer.valueOf(duration)) + '\'');
                        }
                    }
                }
            }
        }
    }
}