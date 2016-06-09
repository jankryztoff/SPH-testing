/**
 * Class Name: PopulateProductFamilyClass
 * @author: <Manolo Vanela>
 * Date: <11/26/2014>
 * Requirement/Project Name: <SPH>
 * @description<To populate Product Family for Package Items>
 * History : 2/9/2015 Joban : Fixes for defect 2151. Modified the complete class to enable bulkification.
 */

public class PopulateProductFamilyClass
{
    String rateName;
    String packageItemProductFamily;
    List<zqu__ProductRatePlan__c> productRPs = new list<zqu__ProductRatePlan__c>();
    List<Product_Family__c> pfRecordList = new List<Product_Family__c>();
    set<Id> setRatePlanId = new set<Id>();
    map<Id,String> mapRPIdProductFamily = new map<Id,String>();
    map<String,Id> mapProductFamilyProductId = new map<String,Id>();
    map<Id,Id> mapRPIdProductFamilyId = new map<Id,Id>();
    
    public void PopulateProductFamily(List<Package_Item__c> newPackageItems)
    {
        for(Package_Item__c packageItem : newPackageItems) 
        {
            if(packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')) 
            {
                // create a set of rate plan Ids for each package Item
                setRatePlanId.add(packageItem.Product_Rate_Plan__c);
            }
        }
        //Start D-2151 2/9/2015 Added By Joban Bir Singh 
        if(!setRatePlanId.isEmpty()){
            // query the Rate Plan object for the above Ids to get the Product Family for each Rate Plan
            for(zqu__ProductRatePlan__c productRP : [SELECT zqu__ZProduct__r.ProductSubType__c,zqu__ZProduct__r.ProductFamily__c 
                                                            FROM zqu__ProductRatePlan__c 
                                                            WHERE Id IN: setRatePlanId 
                                                            AND zqu__ZProduct__r.ProductSubType__c = 'Newspaper']){
                mapRPIdProductFamily.put(productRP.Id,productRP.zqu__ZProduct__r.ProductFamily__c);
                productRPs.add(productRP);
              
            }
        }

        if(!mapRPIdProductFamily.isEmpty()){
            // query Product Family to get the Id a product family provided the product family name
            for(Product_Family__c prodFam : [SELECT Id, Name, Product_Family__c FROM Product_Family__c WHERE Product_Family__c in: mapRPIdProductFamily.values()]){            
                mapProductFamilyProductId.put(prodFam.Product_Family__c,prodFam.Id);
            }
        }

        if(!productRPs.isEmpty()){
            // loop through the Product rate plans to map Rate plan and product family Id    
            for(zqu__ProductRatePlan__c PRP : productRPs){
                mapRPIdProductFamilyId.put(PRP.Id,mapProductFamilyProductId.get(PRP.zqu__ZProduct__r.ProductFamily__c));
            }
        }
        if(!mapRPIdProductFamilyId.isEmpty()){
            for(Package_Item__c packageItem : newPackageItems){
                if((packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product'))) 
                {
                   if(mapRPIdProductFamilyId.containsKey(packageItem .Product_Rate_Plan__c)){
                       packageItem.Product_Family__c = mapRPIdProductFamilyId.get(packageItem .Product_Rate_Plan__c);
                   }
                }
            }
        }
        //End D-2151 2/9/2015 Added By Joban Bir Singh 
    }
}