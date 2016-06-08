global class VendorStopSubscriptionButton{
    
    webservice static String stopVendorSub(String subStopCaseId){
        String result;
        Case caseRec = new Case();
        Set<id> subVendorSet = new Set<id>();       
        List<Order_Line_Item_Vendor__c> oLIVendor = new List<Order_Line_Item_Vendor__c>();
        List<Subscription_Vendor__c> subVenList = new List<Subscription_Vendor__c>();
        List<Subscription_Vendor__c> newSubVenList = new List<Subscription_Vendor__c>();
        
        try{        
            caseRec = [SELECT id, Status, Sub_Status__c, account.recordType.name FROM Case WHERE id =: subStopCaseId];          
            if(String.valueOf(caseRec.account.recordType.name) == GlobalVariableClass.VENDORSUB){
                caseRec.Status = GlobalVariableClass.STATUS_CLOSED;
                caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_STOP_COMPLETED;
                
                oLIVendor = [SELECT id, name, Subscription_Vendor__c FROM Order_Line_Item_Vendor__c WHERE Case__c =: subStopCaseId];
                
                for(Order_Line_Item_Vendor__c oliv : oLIVendor){
                    subVendorSet.add(oliv.Subscription_Vendor__c);
                }
                
                subVenList = [SELECT id, name, status__c FROM Subscription_Vendor__c WHERE id IN: subVendorSet];
                
                for(Subscription_Vendor__c subVen : subVenList){
                    subVen.status__c = GlobalVariableClass.STATUS_CANCELLED;
                    newSubVenList.add(subVen);
                }
                
                update newSubVenList;
                update caseRec;
                result = 'Success';
            } else {
                result = 'Account should be Vendor Stop Subscription.';  // Start/End UD-3816 VPernicia 1/29/16
            }
        } catch(Exception e){
            result = 'Error in cancelling subscription.';
            system.debug('ERROR : ' + e.getStackTraceString());
        }
        
        return result;
    }
}