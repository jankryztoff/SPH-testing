public class UpdateSubscriptionClass
{
    String newProductPlatform;
    Id newPackageId;
    String oldProductPlatform;
    Id oldPackageId;
    Id accountIdS;
    String recordType = '';
    Id orderId;
    Boolean vendorConversion;
    Map<Id, Order__c> ordersMap;
    List<Zuora__Subscription__c> accountSubscriptions;
    Id[] orderIds;
    Integer countActive;
    Integer countInactive;
    String classification;
    String subClassification;
    String reasonCode;
    
    public void UpdateSubscription(List<Zuora__Subscription__c> newSubscriptions)
    {
        accountSubscriptions = new List<Zuora__Subscription__c>();
        orderIds = new Id[]{};
        for(Zuora__Subscription__c currentZSubscriptions : newSubscriptions)
        {
            if(currentZSubscriptions.Order_Number__c != Null)
            {
                orderIds.add(Id.ValueOf(currentZSubscriptions.Order_Number__c)); 
            }     
        }
        
        if(!orderIds.isEmpty())
        {
            ordersMap = new Map<Id, Order__c>([SELECT Id, Order_Type__c FROM Order__c WHERE Id in :orderIds]);
        }
        
        for (Zuora__Subscription__c zSubscription : newSubscriptions)
        {
            accountIdS = zSubscription.Zuora__Account__c;
            newPackageId = zSubscription.Main_Package__c;
            orderId = zSubscription.Order_Number__c; 
            //vendorConversion = Boolean.ValueOf(zSubscription.Vendor_Conversion__c); 
            if(zSubscription.Vendor_Conversion__c != Null)
            {
                vendorConversion = Boolean.ValueOf(zSubscription.Vendor_Conversion__c);
            }
            else
            {
                vendorConversion = False;
            }
            
            if (ordersMap.containsKey(zSubscription.Order_Number__c))
            {
                recordType = ordersMap.get(zSubscription.Order_Number__c).Order_Type__c;
            }
        }
        
        accountSubscriptions = [SELECT Name, Zuora__Status__c, Order_Number_1__r.Case_Record_Type__c, 
                                       Zuora__Account__c, Zuora__Account__r.Name
                                FROM Zuora__Subscription__c 
                                WHERE Zuora__Account__c =: accountIdS];
                                
        countActive = 0;
        countInactive = 0;
        
        for(Zuora__Subscription__c accountSubscription : accountSubscriptions)
        {
            if(accountSubscription.Zuora__Status__c == 'Active')
            {
                countActive += 1;
            }
            else if(accountSubscription.Zuora__Status__c == 'Inactive')
            {
                countInactive += 1;
            }
        }
        
        if(recordType == null)
        {
            recordType = '';
        }
        
        if(recordType.contains('Start')) //Start Subscription
        {
            /**************************************************************************************
            * Needed values for Start Subscription - Upgrade and Downgrade
            ***************************************************************************************/
            List<Package_Item__c> packageItems = [SELECT Product_Platform__c FROM Package_Item__c 
                                                      WHERE Package__r.Id =: newPackageId LIMIT 1];
                                                      
            if(!packageItems.isEmpty())
            {                                          
                newProductPlatform = packageItems[0].Product_Platform__c; //new productPlatform of selected Package Item
            }
            
            /**************************************************************************************
            * New and Neutral/Flat for Start Subscription
            ***************************************************************************************/
            if(vendorConversion == False)
            {
                if(accountSubscriptions.isEmpty())
                {
                    classification = 'New';
                    subClassification = 'Neutral/Flat';
                    reasonCode = 'Correction';
                }
                else if(!accountSubscriptions.isEmpty() && countActive > 0)
                {
                    classification = 'New';
                    subClassification = 'Neutral/Flat';
                    reasonCode = 'Customer Request';
                }
                else if(!accountSubscriptions.isEmpty() && countActive == 0 && countInactive > 0)
                {
                    classification = 'New';
                    subClassification = 'Neutral/Flat';
                }
            }
            /**************************************************************************************
            * Upgrade and Downgrade, and Vendor Conversion for Start Subscription
            ***************************************************************************************/
            else if(vendorConversion == True)
            {
                if(newProductPlatform == 'Print')
                {
                    classification = 'Vendor Conversion';
                    subClassification = 'Neutral/Flat';
                }
                else if(newProductPlatform == 'All In One')
                {
                    classification = 'Vendor Conversion';
                    subClassification = 'Upgrade';
                }
                else if(newProductPlatform == 'Digital')
                {
                    classification = 'Vendor Conversion';
                    subClassification = 'Downgrade';
                }
            }
        }
        else if(recordType.contains('Renewal')) //Renewal of Subscription
        {
            classification = 'Renewed';
            subClassification = 'Neutral/Flat';
            reasonCode = 'Customer Request';
        }
        
        else if(recordType.contains('Change')) //Change of Subscription
        {
            /**************************************************************************************
            * Needed values for Change of Subscription
            ***************************************************************************************/
            List<Package_Item__c> packageItems = [SELECT Product_Platform__c FROM Package_Item__c 
                                                      WHERE Package__r.Id =: newPackageId LIMIT 1];
                                                      
            if(!packageItems.isEmpty())
            {                                          
                newProductPlatform = packageItems[0].Product_Platform__c; //new productPlatform of selected Package Item
            }
            
            Id oldSubscriptionId;
            List<Case> cases = [SELECT AccountId, Account.Name, RecordType.Name, Order__c, Order__r.Subscription__c 
                                FROM Case 
                                WHERE AccountId =: accountIdS 
                                AND RecordType.Name = 'Change of Subscription' 
                                AND Order__r.Subscription__c != Null
                                ORDER BY CreatedDate DESC
                                LIMIT 1];
                                
            if(!cases.isEmpty())
            {                   
                oldSubscriptionId = cases[0].Order__r.Subscription__c;
            }
            
            List <Zuora__Subscription__c> prevSubscription = [SELECT Id, Name, Main_Package_1__c, Order_Number_1__c 
                                                              FROM Zuora__Subscription__c 
                                                              WHERE Id =: oldSubscriptionId 
                                                              LIMIT 1];
            if(!prevSubscription.isEmpty())                                                  
            {                                                  
                oldPackageId = prevSubscription[0].Main_Package_1__c;
            }
            
            List<Package_Item__c> oldPackageItems = [SELECT Product_Platform__c FROM Package_Item__c 
                                                     WHERE Package__r.Id =: oldPackageId LIMIT 1];
                                                     
            if(!oldPackageItems.isEmpty())
            {                                         
                oldProductPlatform = oldPackageItems[0].Product_Platform__c;
            }
            
            /**************************************************************************************
            * Needed values for Change of Subscription - Qty Increase and Qty Decrease
            ***************************************************************************************/
            Id oldOrderId;
            Double quantity;
            Double qtyNew;
            
            if(!prevSubscription.isEmpty()){
                oldOrderId = prevSubscription[0].Order_Number_1__c;
            }
            List<Order_Line_Item__c> oldOrderLineItem = [SELECT Qty__c
                                                         FROM Order_Line_Item__c
                                                         WHERE Order__r.Id =: oldOrderId LIMIT 1];
             
            if(!oldOrderLineItem.isEmpty())
            {                                             
                quantity = oldOrderLineItem[0].Qty__c;                                        
            }
            
            List<Order_Line_Item__c> orderLineItem = [SELECT Order__c, Qty__c
                                                      FROM Order_Line_Item__c
                                                      WHERE Order__r.Id =: orderId LIMIT 1];
                                                      
                                                      
            if(!orderLineItem.isEmpty())
            {                                          
                qtyNew = orderLineItem[0].Qty__c; 
            }
            
            /**************************************************************************************
            * Upgrade and Downgrade for Change of Subscription
            ***************************************************************************************/
            if(oldPackageId != newPackageId)
            {
                if((oldProductPlatform == 'Print' || oldProductPlatform == 'Digital') && newProductPlatform == 'All In One')
                {
                    classification = 'Change';
                    subClassification = 'Upgrade';
                }
                else if(oldProductPlatform == 'Digital' && newProductPlatform == 'Print')
                {
                    classification = 'Change';
                    subClassification = 'Upgrade';
                }
                else if(oldProductPlatform == 'All In One' && (newProductPlatform == 'Print' || newProductPlatform == 'Digital'))
                {
                    classification = 'Change';
                    subClassification = 'Downgrade';
                }
                else if(oldProductPlatform == 'Print' && newProductPlatform == 'Digital')
                {
                    classification = 'Change';
                    subClassification = 'Downgrade';
                }
            }
            
            /**************************************************************************************
            * Qty Increase and Qty Decrease for Change of Subscription
            ***************************************************************************************/                                                      
            else if(oldPackageId == newPackageId)
            {
                if(qtyNew > quantity)
                {
                    classification = 'Change';
                    subClassification = 'Qty Increase';
                }
                else if(qtyNew < quantity)
                {
                    classification = 'Change';
                    subClassification = 'Qty Decrease'; 
                }
            }
        }
        
        for (Zuora__Subscription__c zSubscription : newSubscriptions)
        {
            zSubscription.Classification__c = classification;
            zSubscription.Sub_Classification__c = subClassification;
            zSubscription.Reason_Code__c = reasonCode;
        }
    }
}