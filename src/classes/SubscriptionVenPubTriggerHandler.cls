/**
 * Class Name: SubscriptionVenPubTriggerHandler
 * @author: Sherwin Puli
 * Date: 17-February-2016
 * Requirement/Project Name: <SPH>
 * @description: triggerhandler for object Subscription_Vendor_Publication__c
 */

public class SubscriptionVenPubTriggerHandler{  
    
    Map<Id, Set<Id>> subToPubIds_Map = new Map<Id, Set<Id>>();
    Map<Id, String> subToPubCodes_Map = new Map<Id, String>();
    List<Subscription_Vendor__c> subscriptionVendorToSave = new List<Subscription_Vendor__c>();
    Set<Id> initialPubs = new set<Id>();
    
    public void doBeforeInsert(List<Subscription_Vendor_Publication__c> lstNewSubVenPubs)
    {
        for(Subscription_Vendor_Publication__c svp : lstNewSubVenPubs){
            if(svp.Publication__c <> null){
                if(!subToPubIds_Map.containsKey(svp.Subscription_Vendor__c)){
                    subToPubIds_Map.put(svp.Subscription_Vendor__c, new Set<Id>{svp.Publication__c});
                }else{
                    subToPubIds_Map.get(svp.Subscription_Vendor__c).add(svp.Publication__c);
                }
                initialPubs.add(svp.Publication__c);
            }
        }
        if(subToPubIds_Map.size()>0){
            getSubscriptionVendor(subToPubIds_Map);
        }
        andFinally();
    }  
    
    public void doBeforeUpdate(List<Subscription_Vendor_Publication__c> lstNewSubVenPubs, Map<Id, Subscription_Vendor_Publication__c> mapNewSubVenPubs,
                               List<Subscription_Vendor_Publication__c> lstOldSubVenPubs, Map<Id, Subscription_Vendor_Publication__c> mapOldSubVenPubs)
    {
        for(Subscription_Vendor_Publication__c svp : lstNewSubVenPubs){
            if(svp.Publication__c <> null){
                if(!subToPubIds_Map.containsKey(svp.Subscription_Vendor__c)){
                    subToPubIds_Map.put(svp.Subscription_Vendor__c, new Set<Id>{svp.Publication__c});
                }else{
                    subToPubIds_Map.get(svp.Subscription_Vendor__c).add(svp.Publication__c);
                }
                initialPubs.add(svp.Publication__c);
            }
        }
        if(subToPubIds_Map.size()>0){
            getSubscriptionVendor(subToPubIds_Map);
        }
        andFinally();
    }   
    
    private void andFinally() {
        
        boolean isError = false;
        Logger logger = new Logger(SubscriptionVenPubTriggerHandler.class.getName(), 'None', null);
        
        if(subscriptionVendorToSave.size()>0){
            Database.SaveResult[] subsSaveResult = Database.update(subscriptionVendorToSave, false);
            for(Database.SaveResult subs : subsSaveResult){
                String subsFailure = '';
                if (!subs.isSuccess()) {
                    for(Database.Error subsError : subs.getErrors()){
                        subsFailure += subsError.getStatusCode()+'* ' + subsError.getMessage() + '\n';
                    }
                    
                    logger.log(true, subsFailure);
                    isError = true;
                }
            }
            if(isError){
                logger.save();          
            }
        }
    }
    
    private void getSubscriptionVendor(Map<Id, Set<Id>> subToPubIds_Map){   
        List<Subscription_Vendor__c> subscriptionVendorToUpdate = new List<Subscription_Vendor__c>();
        List<Publication__c> pub_List = new List<Publication__c>();
        Map<Id, String> subIdToCode = new Map<Id, String>();
        Map<Id, String> pubIdToCode = new Map<Id, String>();
        if(subToPubIds_Map.size()>0){
            pub_List = [SELECT Id,Publication_Code__c FROM Publication__c WHERE Id IN :initialPubs];
            subscriptionVendorToUpdate = [SELECT Id,Publication_Code__c FROM Subscription_Vendor__c WHERE Id IN :subToPubIds_Map.keyset()];
            
            if(pub_List.size()>0){
                for(Publication__c pub : pub_List){
                    if(pub.Publication_Code__c <> null){
                        pubIdToCode.put(pub.Id, pub.Publication_Code__c);
                    }
                }
            }
            for(Id subId : subToPubIds_Map.keySet()){
                for(Subscription_Vendor__c subVP : subscriptionVendorToUpdate){
                    if(subVP.Publication_Code__c <> null){  
                        subIdToCode.put(subVP.Id, subVP.Publication_Code__c);
                    }
                }
                for(Id pubId : subToPubIds_Map.get(subId)){
                    if(pubIdToCode.containsKey(pubId)){
                        if(!subToPubCodes_Map.containsKey(subId)){
                            if(subIdToCode.containsKey(subId)){
                                subToPubCodes_Map.put(subId, subIdToCode.get(subId)+', '+pubIdToCode.get(pubId));
                            }else{
                                subToPubCodes_Map.put(subId, pubIdToCode.get(pubId));
                            }
                        }else{
                            String tempPubCode = '';
                            tempPubCode = subToPubCodes_Map.get(subId);
                            subToPubCodes_Map.put(subId, tempPubCode+', '+pubIdToCode.get(pubId));
                            
                        }
                    }
                }
            }
            if(subscriptionVendorToUpdate.size() > 0){
                for(Subscription_Vendor__c subsVen : subscriptionVendorToUpdate){
                    if(subToPubCodes_Map.containsKey(subsVen.Id)){
                        subsVen.Publication_Code__c = subToPubCodes_Map.get(subsVen.Id);
                        subscriptionVendorToSave.add(subsVen);
                    }
                }
            }
        }
    }
       
}