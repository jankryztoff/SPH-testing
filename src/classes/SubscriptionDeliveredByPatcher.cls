global class SubscriptionDeliveredByPatcher implements Database.Batchable<sObject>
{    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {       
        return Database.getQueryLocator([SELECT Id, Main_Package_1__r.Id, Delivered_By__c, Delivered_By_1__c, Recipient_Contact__r.Address__r.RecordTypeId FROM Zuora__Subscription__c]);
    }
    
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> scope)
    {        
        Set<Id> packageIdSet = new Set<Id>();
        Map<Id,List<Package_Item__c>> package_packageItem_map = new Map<Id,List<Package_Item__c>>();
        for(Zuora__Subscription__c subElement : scope) {
            packageIdSet.add(subElement.Main_Package_1__r.Id);
        }
        
        List<Package_Item__c> packageItemList = [SELECT Id, Package__c, Is_Newspaper__c, Is_Print__c, Is_All_In_One__c, Is_Magazine__c FROM Package_Item__c WHERE Package__c IN :packageIdSet];
        
        for(Package_Item__c packageItemElement : packageItemList) { 
            if(package_packageItem_map.get(packageItemElement.Package__c) == null)
                package_packageItem_map.put(packageItemElement.Package__c, new List<Package_Item__c>());
            package_packageItem_map.get(packageItemElement.Package__c).add(packageItemElement);
        }
        
        for(Zuora__Subscription__c subElement : scope) {
            List<Package_Item__c> sub_package_packageItem_map = package_packageItem_map.get(subElement.Main_Package_1__r.Id);
            if(sub_package_packageItem_map != null) {
                for(Package_Item__c packageItemElement : sub_package_packageItem_map ){     
                    if(subElement.Recipient_Contact__r.Address__r.RecordTypeId != ConstantsSLB.getkeyid('Address_Local')){
                      subElement.Delivered_By__c = 'Mailing Agent';
                      subElement.Delivered_By_1__c = 'Mailing Agent';
                      break;
                    } else if(subElement.Recipient_Contact__r.Address__r.RecordTypeId == ConstantsSLB.getkeyid('Address_Local')) { 
                        if(packageItemElement.Is_Newspaper__c == true && (packageItemElement.Is_Print__c == True || packageItemElement.Is_All_In_One__c == True)) {
                            subElement.Delivered_By__c = 'Vendor';
                            subElement.Delivered_By_1__c = 'Vendor';
                            break;
                        } else if(packageItemElement.Is_Magazine__c == true) {
                            subElement.Delivered_By__c = 'Mailing Agent';
                            subElement.Delivered_By_1__c = 'Mailing Agent';
                            break;
                        }
                    }
                }
            }           
            
            if(subElement.Delivered_By__c == null)
                subElement.Delivered_By__c = 'None';
            if(subElement.Delivered_By_1__c == null)
                subElement.Delivered_By_1__c = 'None';
        }
        
        Database.update(scope,false);
    }
    
    global void finish(Database.BatchableContext BC)
    {                 
        
    }
}