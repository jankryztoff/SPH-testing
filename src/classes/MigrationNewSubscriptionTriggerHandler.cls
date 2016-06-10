/**
* Class Name: <MigrationNewSubscriptionTriggerHandler>
* @authors: <ChristopherCamilon>
* Date: <8/17/2015>
* Requirement/Project Name: <SPH>
* @description <Validate>
*/
public class MigrationNewSubscriptionTriggerHandler implements TriggerHandlerInterface {
    
    public static Boolean preventExecution = FALSE;
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    List<Zuora__Subscription__c> lstNewSubVersions = new List<Zuora__Subscription__c>(); 
    List<Zuora__Subscription__c> lstNewSubsToDel = new List<Zuora__Subscription__c>(); 
    Set<Id> setBAIdsToSync = new Set<Id>();
    
    Static Set<Id> OrderIds = new Set<Id>();
    Static Map<Id, Order__c> OrderMap = new Map<Id, Order__c>();
    Static List<Order__c> OrderList = new List<Order__c>();
    Static Map<Id, List<Zuora__Subscription__c>> OrderSubPubMap = new Map<Id, List<Zuora__Subscription__c>>();
    Static Map<Id, List<Zuora__Subscription__c>> OrderSubDelMap = new Map<Id, List<Zuora__Subscription__c>>();
    Static Map<Id, List<Zuora__Subscription__c>> OrderAllSubDelMap = new Map<Id, List<Zuora__Subscription__c>>();
    //START D-3466 09012015 To avoid too many SOQL errors
    Static List<Order__c> updOrderList = new List<Order__c>();
    //END D-3466 09012015 To avoid too many SOQL errors
    //START D-3557 09102015 To avoid null pointer exception
    Static Set<Id> idOrders = new Set<Id>();
    Static Set<Id> OrderIdset = new Set<Id>();
    Static Map<Id, String> oldOrderIdsMap = new Map<Id, String>();
    //END D-3557 09102015 To avoid null pointer exception
    //START D-3790 10202015 To fix promo and delivery charge
    Static Set<Id> PromotionIds = new Set<Id>();
    Static Map<Id, Promotion__c> PromotionMap = new Map<Id, Promotion__c>();
    //END D-3790 10202015 To fix promo and delivery charge
    
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !MigrationNewSubscriptionTriggerHandler.isBeforeInsertTriggerCalled;
        MigrationNewSubscriptionTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !MigrationNewSubscriptionTriggerHandler.isBeforeUpdateTriggerCalled;
        MigrationNewSubscriptionTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !MigrationNewSubscriptionTriggerHandler.isBeforeDeleteTriggerCalled;
        MigrationNewSubscriptionTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !MigrationNewSubscriptionTriggerHandler.isAfterInsertTriggerCalled;
        MigrationNewSubscriptionTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !MigrationNewSubscriptionTriggerHandler.isAfterUpdateTriggerCalled;
        MigrationNewSubscriptionTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !MigrationNewSubscriptionTriggerHandler.isAfterDeleteTriggerCalled;
        MigrationNewSubscriptionTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;
    }
    
    public void bulkBefore() {
    
        //START D-3790 10202015 To fix promo and delivery charge
        if (Trigger.isUpdate) {
        
            for (Zuora__Subscription__c sub : (list<Zuora__Subscription__c>)trigger.new) {
                
                PromotionIds.add(sub.Promotion_1__c);        
                
            }    
            List<Promotion__c> PromotionList = new List<Promotion__c>();
            PromotionList = [Select Id, Effective_End_Date__c From Promotion__c Where Id in : PromotionIds];
            for(Promotion__c promo : PromotionList){
                
                PromotionMap.put(promo.id, promo);
            
            }
        } 
        //END D-3790 10202015 To fix promo and delivery charge
                                             
        
    }
    
    public void bulkAfter() {
        
        if (Trigger.isUpdate) {
            //START D-3790 10202015 To fix promo and delivery charge
            //START D-3557 09102015 To avoid null pointer exception
           // for (Zuora__Subscription__c oldsub : (list<Zuora__Subscription__c>)trigger.old) {
            //    if (oldsub.Legacy_Subscription_ID__c != null && oldsub.Legacy_Subscription_ID__c != '' && oldsub.Order_Number_1__c != null && oldsub.Subscription_Type_1__c == 'Delivery'){

               //     OrderIds.add((id)oldsub.Order_Number_1__c);
                                             
                                     
              // }
           // }
            
            for (Zuora__Subscription__c sub : (list<Zuora__Subscription__c>)trigger.new) {
                if (sub.Legacy_Subscription_ID__c != null && sub.Legacy_Subscription_ID__c != '' && sub.Order_Number_1__c != null){                    
                    OrderIds.add((id)sub.Order_Number_1__c); 
                }
            }
            //START D-3685 10022015 To change delivery charge value
            OrderList = [SELECT Id, Name, Initial_Term__c, Full_Prepaid_Delivery_Charge__c, Delivery_Charge__c, Total_Full_Prepaid__c, Subscriber_Charge__c From Order__c where ID in : OrderIds];
            for(Order__c ord : OrderList){
            
                OrderMap.put(ord.id, ord);
            
            }
            //END D-3790 10202015 To fix promo and delivery charge
            
            
            /*
            List<Zuora__Subscription__c> OrderSubPubList = new List<Zuora__Subscription__c>();
            List<Zuora__Subscription__c> OrderSubDelList = new List<Zuora__Subscription__c>();
            List<Zuora__Subscription__c> OrderAllSubDelList = new List<Zuora__Subscription__c>();
            OrderList = [SELECT Id, Name, Initial_Term__c, Full_Prepaid_Delivery_Charge__c, Delivery_Charge__c, Total_Full_Prepaid__c, Subscriber_Charge__c From Order__c where ID in : OrderIds];
            for(Order__c ord : OrderList){
                /*
                List<Zuora__Subscription__c> OrderSubPubList = new List<Zuora__Subscription__c>();
                List<Zuora__Subscription__c> OrderSubDelList = new List<Zuora__Subscription__c>();
                List<Zuora__Subscription__c> OrderAllSubDelList = new List<Zuora__Subscription__c>();
                */
                /*
                OrderMap.put(ord.id, ord);
                /*
                
                OrderSubPubList = [SELECT Id, Name, Subscription_Charge__c FROM Zuora__Subscription__c Where Order_Number_1__c = : ord.id AND Subscription_Type_1__c =: 'Publication' AND Billing_Type__c =: 'Full Prepaid'];                 
                OrderSubDelList = [SELECT Id, Name, Subscription_Charge__c, Term_Length__c, Delivery_Charge__c FROM Zuora__Subscription__c Where Order_Number_1__c = : ord.id AND Subscription_Type_1__c =: 'Delivery' AND Billing_Type__c =: 'Full Prepaid'];
                OrderAllSubDelList = [SELECT Id, Name, Subscription_Charge__c, Delivery_Charge__c FROM Zuora__Subscription__c Where Order_Number_1__c = : ord.id AND Subscription_Type_1__c =: 'Delivery'];            
                
                OrderSubPubMap.put(ord.id, OrderSubPubList);
                OrderSubDelMap.put(ord.id, OrderSubDelList);
                OrderAllSubDelMap.put(ord.id, OrderAllSubDelList);
                
                
                idOrders.add(ord.id);
            }
            
            OrderSubPubList = [SELECT Id, Name, Subscription_Charge__c, Order_Number_1__c FROM Zuora__Subscription__c Where Order_Number_1__c IN : idOrders AND Subscription_Type_1__c =: 'Publication' AND Billing_Type__c =: 'Full Prepaid'];
            OrderSubDelList = [SELECT Id, Name, Subscription_Charge__c, Term_Length__c, Delivery_Charge__c,Order_Number_1__c FROM Zuora__Subscription__c Where Order_Number_1__c IN : idOrders AND Subscription_Type_1__c =: 'Delivery' AND Billing_Type__c =: 'Full Prepaid'];
            OrderAllSubDelList = [SELECT Id, Name, Subscription_Charge__c, Delivery_Charge__c,Order_Number_1__c FROM Zuora__Subscription__c Where Order_Number_1__c IN : idOrders AND Subscription_Type_1__c =: 'Delivery'];
            
            for(Zuora__Subscription__c sub : OrderSubPubList){
                if(OrderSubPubMap.containsKey(sub.Order_Number_1__c)){
                    OrderSubPubMap.get(sub.Order_Number_1__c).add(sub);
                }else{
                    OrderSubPubMap.put(sub.Order_Number_1__c, new List<Zuora__Subscription__c> {sub});
                }
    
            }
            
            for(Zuora__Subscription__c sub : OrderSubDelList){
                if(OrderSubPubMap.containsKey(sub.Order_Number_1__c)){
                    OrderSubPubMap.get(sub.Order_Number_1__c).add(sub);
                }else{
                    OrderSubPubMap.put(sub.Order_Number_1__c, new List<Zuora__Subscription__c> {sub});
                }
    
            }
            
            for(Zuora__Subscription__c sub : OrderAllSubDelList){
                if(OrderSubPubMap.containsKey(sub.Order_Number_1__c)){
                    OrderSubPubMap.get(sub.Order_Number_1__c).add(sub);
                }else{
                    OrderSubPubMap.put(sub.Order_Number_1__c, new List<Zuora__Subscription__c> {sub});
                }
    
            }
            //END D-3557 09102015 To avoid null pointer exception
            */
            //END D-3685 10022015 To change delivery charge value
        }            
        
    }
    
    public void beforeInsert(SObject so) {
        
        Zuora__Subscription__c sub = (Zuora__Subscription__c)so;
        if(sub.Zuora__Version__c != 1)
            sub.Zuora__Account__c = Null;
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){            
        //START D-3557 09102015 To avoid null pointer exception
        Zuora__Subscription__c sub = (Zuora__Subscription__c)so;
        
        if (sub.Legacy_Subscription_ID__c != null && sub.Legacy_Subscription_ID__c != ''){
            
            sub.Ph_d__c = TRUE;
            sub.Ph_e__c = TRUE;
            //START D-3721 10122015 Fix Subscription End Date 
            if(sub.Term_Length__c > 0 && sub.Zuora__Status__c != GlobalVariableClass.STATUS_CANCELLED){
                sub.Zuora__SubscriptionEndDate__c = sub.Zuora__SubscriptionStartDate__c.addMonths(Integer.valueOf(sub.Term_Length__c)).addDays(-1);   
            }else if(sub.Zuora__Status__c != GlobalVariableClass.STATUS_CANCELLED && sub.Term_Length__c == null ){
                sub.Zuora__SubscriptionEndDate__c = null;              
            }else if(sub.Zuora__Status__c == GlobalVariableClass.STATUS_CANCELLED && sub.Subscription_End_Date__c == null) {
                sub.Zuora__SubscriptionEndDate__c = sub.Zuora__SubscriptionEndDate__c.addDays(-1);
                sub.Subscription_End_Date__c = String.Valueof(sub.Zuora__SubscriptionEndDate__c);
            }else if(sub.Zuora__Status__c == GlobalVariableClass.STATUS_CANCELLED && sub.Subscription_End_Date__c != null) {
                //START D-3734 10142015 Fix Subscription End Date 
                //  Date SubEndDate =  date.newinstance(Integer.valueof(sub.Subscription_End_Date__c.substring(0,3)), Integer.valueof(sub.Subscription_End_Date__c.substring(5,6)), //Integer.valueof(sub.Subscription_End_Date__c.substring(8,9)));   
                Date SubEndDate = Date.valueof(sub.Subscription_End_Date__c);
                sub.Zuora__SubscriptionEndDate__c =  SubEndDate;                   
                //END D-3734 10142015 Fix Subscription End Date 
            }
            //END D-3721 10122015 Fix Subscription End Date 
            
            if(sub.Addon_Package_1__c != null){
                sub.Addon_Package__c = String.valueOf(sub.Addon_Package_1__c);
            }
            
            if(sub.Billing_Type__c == null){
                sub.Billing_Type_isNull__c = 'TRUE';               
            }else{
                sub.Billing_Type_isNull__c = 'FALSE';
            }
            
            if(sub.Delivered_By_1__c != null){
                sub.Delivered_By__c = String.valueOf(sub.Delivered_By_1__c);
            }
            
            if(sub.Main_Package_1__c != null){
                sub.Main_Package_isNull__c = 'FALSE';
                sub.Main_Package__c = String.valueOf(sub.Main_Package_1__c);
            }else{
                sub.Main_Package_isNull__c = 'TRUE';
                sub.Main_Package__c = '';
            }
            
            if(sub.Order_Line_Item_Number_1__c != null){
                sub.Order_Line_Item_Number__c = String.valueOf(sub.Order_Line_Item_Number_1__c);    
            }
            
            if(sub.Order_Number_1__c != null){
                sub.Order_Number__c = String.valueOf(sub.Order_Number_1__c);    
            }
            
            if(sub.Promotion_1__c != null){
         
                sub.Promotion__c = String.valueOf(sub.Promotion_1__c);    
            }
            //START D-3685 10022015 To change delivery charge value
            //START D-3790 10202015 To fix promo and delivery charge
            if(sub.Promotion_1__c != null && (sub.Contract_End_Date__c == null || sub.Contract_End_Date__c == '')){
                
                Promotion__c promo = PromotionMap.get(sub.Promotion_1__c);
                System.Debug('@@@@' + String.valueof(promo.Effective_End_Date__c));
                sub.Contract_End_Date__c = String.valueof(promo.Effective_End_Date__c); 
                sub.Contract_End_Date_1__c = promo.Effective_End_Date__c; 
                  
            }
            //END D-3790 10202015 To fix promo and delivery charge
            //END D-3685 10022015 To change delivery charge value
            if(sub.Number_of_Copies1__c != null && String.valueOF(sub.Number_of_Copies1__c) != ''){
                sub.Qty__c = Integer.valueof(sub.Number_of_Copies1__c);
                sub.Number_of_Copies__c = Integer.valueof(sub.Number_of_Copies1__c);
                sub.Qty1__c = sub.Number_of_Copies1__c;
            }
            
            if(sub.Subscription_Type__c != null && String.valueOF(sub.Subscription_Type__c) != ''){            
                sub.Subscription_Type_1__c = String.valueof(sub.Subscription_Type__c);            
            }
            
            if(sub.Recipient_Contact__c != null){
                sub.Recipient_Contact_1__c = String.valueOf(sub.Recipient_Contact__c);    
                sub.Recipient_Contact_isNull__c = 'FALSE';
            }else{
                sub.Recipient_Contact_1__c = '';    
                sub.Recipient_Contact_isNull__c = 'TRUE';
            }
            
            if(sub.Subscriber_Contact__c != null){
                sub.Subscriber_Contact_1__c = String.valueOf(sub.Subscriber_Contact__c);    
            }
            
            if(sub.Vendor_1__c != null){
                sub.Vendor__c = String.valueOf(sub.Vendor_1__c);    
            }
            
            if(sub.Vendor_Subscription_To_Convert_1__c != null){
                sub.Vendor_Subscription_To_Convert__c = String.valueOf(sub.Vendor_Subscription_To_Convert_1__c);    
            }
            
        }
        //END D-3557 09102015 To avoid null pointer exception
    }
    public void beforeDelete(SObject so) {
        
        Zuora__Subscription__c sub = (Zuora__Subscription__c)so;
        if(sub.Zuora__Account__c != NULL) 
            sub.addError('Disable Zuora Sync Deletion!');
        
    }
    public void afterInsert(SObject so) {        
        
        Zuora__Subscription__c subscription = (Zuora__Subscription__c)so; 
        if(subscription.Zuora__Account__c == NULL && subscription.Zuora__Version__c != 1)
        {
            lstNewSubVersions.add(subscription);
            Zuora__Subscription__c subToDel = new Zuora__Subscription__c(Id = subscription.Id);
            lstNewSubsToDel.add(subToDel);
        }
        
    }
    public void afterUpdate(SObject oldSo, SObject so) {
        
        Zuora__Subscription__c oldSub = (Zuora__Subscription__c)oldSo;
        Zuora__Subscription__c newSub = (Zuora__Subscription__c)so;
        if(oldSub.Zuora__Version__c != newSub.Zuora__Version__c)
            setBAIdsToSync.add(newSub.Zuora__CustomerAccount__c);
        
        Zuora__Subscription__c sub = (Zuora__Subscription__c)so;
        //START D-3557 09102015 To avoid null pointer exception
        
        //START D-3685 10022015 To change delivery charge value
        //START D-3790 10202015 To fix promo and delivery charge
        //if(sub.Order_Number_1__c != null && sub.Subscription_Type_1__c == 'Delivery'){
       
        
        if(orderMap.Containskey(sub.Order_Number_1__c)){
            Order__c ord = OrderMap.get(sub.Order_Number_1__c);
            ord.Initial_Term__c = String.valueof(integer.valueof(sub.Term_Length__c));
            //START D-3820 10262015 To change subscriber charge value on Order
            if (sub.Subscription_Type_1__c == 'Delivery'){   
            //END D-3820 10262015 To change subscriber charge value on Order           
                if(sub.Subscription_Charge__c == null){
                    ord.Subscriber_Charge__c = 0;
                }else{
                    ord.Subscriber_Charge__c = sub.Subscription_Charge__c;
                }                                               
            }
                
            if(!OrderIdset.contains(ord.id)){
                updOrderList.add(ord);
                OrderIdset.add(ord.id);
            }
                          
         }
           
         //}
         //END D-3790 10202015 To fix promo and delivery charge
         //END D-3685 10022015 To change delivery charge value
         //START D-3685 10022015 To change delivery charge value
            /*
            if(orderMap.Containskey(sub.Order_Number_1__c)){
                Order__c ord = OrderMap.get(sub.Order_Number_1__c);    
                
                List<Zuora__Subscription__c> SubPubList = new List<Zuora__Subscription__c>();
                List<Zuora__Subscription__c> SubDelList = new List<Zuora__Subscription__c>();
                List<Zuora__Subscription__c> AllSubDelList = new List<Zuora__Subscription__c>();
                
                Decimal ordSubCharge = 0;
                Decimal fullPrepaidDelCharge = 0;
                Decimal ordTotalFullPrepaid = 0;
                AllSubDelList = OrderAllSubDelMap.get(ord.id);
                SubDelList = OrderSubDelMap.get(ord.id);
                SubPubList = OrderSubPubMap.get(ord.id);
                 //START D-3557 09102015 To avoid null pointer exception
                if(AllSubDelList != null && !AllSubDelList.isEmpty()){
                    for(Zuora__Subscription__c oneSubDel : AllSubDelList){
                        Decimal subdelcharge;
                        if (oneSubDel.Delivery_Charge__c == null){
                            subdelcharge = 0;
                        }else{
                            subdelcharge = oneSubDel.Delivery_Charge__c;
                        }
                        ordSubCharge = ordsubcharge + subdelcharge;      
                    
                    }
               
                    ord.Subscriber_Charge__c = ordSubCharge;
                }
                if(SubDelList != null && !SubDelList.isEmpty()){
                    for(Zuora__Subscription__c subDel : SubDelList){                   
                        Decimal total;
                        if (subDel.Delivery_Charge__c == null){
                            total = 0;
                        }else{
                            total = subDel.Term_Length__c * subDel.Delivery_Charge__c;
                        }
                        fullPrepaidDelCharge = fullPrepaidDelCharge + total;    
                    }
                
                    ord.Full_Prepaid_Delivery_Charge__c = fullPrepaidDelCharge;
                }
                if(SubPubList != null && !SubPubList.isEmpty()){
                    for(Zuora__Subscription__c subPub : SubPubList){
                        Decimal subPubCharge;
                        subPubCharge = subPub.Subscription_Charge__c;   
                        ordTotalFullPrepaid = ordTotalFullPrepaid + subPubCharge; 
                    }
                    ordTotalFullPrepaid = ordTotalFullPrepaid + fullPrepaidDelCharge;
                    ord.Total_Full_Prepaid__c = ordTotalFullPrepaid;
                }
                 
                //START D-3466 09012015 To avoid too many SOQL errors
                /*
                update ord;
                */
                /*
                //END D-3466 09012015 To avoid too many SOQL errors
                if(!OrderIdset.contains(ord.id)){
                    updOrderList.add(ord);
                    OrderIdset.add(ord.id);
                }
                
                //END D-3557 09102015 To avoid null pointer exception
            }
            
        }
        */
        //END D-3557 09102015 To avoid null pointer exception
        //END D-3685 10022015 To change delivery charge value
    }
    
    public void afterDelete(SObject so) {
        
    }
    
    public void andFinally() {
        
        
        if(!lstNewSubVersions.isEmpty())
        {
            CustomZuoraSyncQueueable asynJob = new CustomZuoraSyncQueueable();
            asynJob.lstNewVersions = lstNewSubVersions;
            System.enqueueJob(asynJob);
        }
        
        if(!lstNewSubsToDel.isEmpty())
        {
            //DELETE All New Versions
            DELETE lstNewSubsToDel;
            //Database.emptyRecycleBin(lstNewSubsToDel);                
        }
        
        if(!setBAIdsToSync.isEmpty())
        {
            //Perform Zuora Sync
            Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
            syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
            syncManager.syncObjectIdSet  = setBAIdsToSync;
            //Disable Email Notification for On-demand Sync
            syncManager.emailNotificationEnabled = false;
            
            List<Zuora.SyncResult> syncResult = syncManager.sendRequest();
            System.debug('>>>>> Sync Result:' + syncResult);
        } 
        //START D-3557 09102015 To avoid null pointer exception
        //START D-3466 09012015 To avoid too many SOQL errors
        if(!updOrderList.isEmpty())
            update updOrderList;
        //END D-3466 09012015 To avoid too many SOQL errors
        //END D-3557 09102015 To avoid null pointer exception
    }
    
}