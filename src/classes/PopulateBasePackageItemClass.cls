/**
 * Class Name: <PopulateBasePackageItemClass>
 * @author: <Manolo>
 * Date: <09/11/2014>
 * Requirement/Project Name: <SPH>
 * @description<To populate Base Package Id for package line items>
 * History : 2/10/2015 Joban : Fixes for defect 2173. 
 */
public class PopulateBasePackageItemClass{

    //START D-2173 2/10/2015 Added By Joban Bir Singh : modified logic to add bulkification
    
    List<Id> listPackageId = new List<Id>();
    String basePackageId;
    set<Id> packageIds = new set<Id>();
    Map<Id, Package__c> packagesMap = new Map<Id, Package__c>();
    List<Package_Item__c> currentPackageItems = new List<Package_Item__c>();
    Map<Id,Id> mapPackageIdBaseProductId = new Map<Id,Id>();
    
    public void PopulateBasePackageItem(List<Package_Item__c> newPackageItems){   
        
        // For all the discount items store the package Id in a set
        for (Package_Item__c currentPackItem : newPackageItems){   
            If(currentPackItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Discount')){
                packageIds.add(currentPackItem.Package__c);
            }
        }
 
        if(!packageIds.isEmpty()){    
            // query base package items for tha packages above and map package id to base packageitem id
            for(Package_Item__c basePackageItem : [SELECT Id, Name, Package__c,RecordType.Name, RecordTypeId, Base_Package_Item__r.Id, Bundle_Item_No__c
                                                    FROM Package_Item__c 
                                                    WHERE Package__r.Id IN: packageIds AND RecordType.Name = 'Base Product']){
                mapPackageIdBaseProductId.put(basePackageItem.Package__c,basePackageItem.Id);
            }
 
            for(Package_Item__c packageItem : newPackageItems){
                If(packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Discount') 
                    && mapPackageIdBaseProductId.containsKey(packageItem.Package__c)){
                    packageItem.Base_Package_Item__c = mapPackageIdBaseProductId.get(packageItem.Package__c);
                }
            }
        }
        //END D-2173 2/10/2015 Added By Joban Bir Singh : modified logic to add bulkification
    }
}