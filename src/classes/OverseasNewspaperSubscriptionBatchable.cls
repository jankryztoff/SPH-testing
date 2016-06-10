public class OverseasNewspaperSubscriptionBatchable implements Database.Batchable<SObject> {

    /*
    4.  Criteria for identifying Overseas Newspaper Subscriptions
    a.  Subscription Delivered By = Mailing Agent
    b.  Delivery Address Type = Overseas
    c.  Subscription Product = Newspaper. In order to determine this, the query needs to follow the following path:
        i.  Subscription->Main Package->Package Item->Product Rate Plan->ZProduct
        ii. Field to be queried on ZProduct to determine whether it is Newspaper of Magazine � Product Sub Type
    */

    public database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator([select Id, Main_Package_1__c, Zuora__Account__r.AccountNumber, Zuora__Account__c, 
                Zuora__Account__r.Name, Recipient_Contact__c, Recipient_Contact__r.Name, Recipient_Contact__r.Phone, 
                Recipient_Contact__r.Address__c, Recipient_Contact__r.RecordType.Name, Recipient_Contact__r.Address__r.Address_1__c, 
                Recipient_Contact__r.Address__r.Address_2__c, Recipient_Contact__r.Address__r.Address_3__c, 
                Recipient_Contact__r.Address__r.Address_4__c, Recipient_Contact__r.Address__r.Country_Name__c, 
                Recipient_Contact__r.Salutation, Zuora__Account__r.RecordType.Name, Zuora__Account__r.Mailing_Agent_Code__c,  
                Recipient_Contact__r.Address__r.Block_House_Number__c, Recipient_Contact__r.Address__r.Level_Number__c, 
                Recipient_Contact__r.Address__r.Unit_Number__c, Recipient_Contact__r.Address__r.Building_Name__c 
                from Zuora__Subscription__c where Delivered_By__c = 'Mailing Agent' 
                and Recipient_Contact__r.RecordType.Name = 'Internal']);
    }
    
    
    public void execute(Database.BatchableContext bc, list<Zuora__Subscription__c> scope) {
        
        list<Packing_Label_Batch__c> packingLabelBatchList = new list<Packing_Label_Batch__c>();
        map<id, boolean> mainPackageId_isNewspaper = new map<id, boolean>();
        map<id, string> subscriptionId_publicationCode = new map<id, string>();
        map<id, string> subscriptionId_copyType = new map<id, string>();
        map<string, date> publicationCode_publicationIssueDate = new map<string, date>();
        
        
        for (Zuora__Subscription__c tmp : scope) {
            mainPackageId_isNewspaper.put(tmp.Main_Package_1__c, false);
        }
        
        //START 02/18/2015 - Added by Rom Edison Reyes - Checks if mainPackageId_isNewspaper is not empty
        if(mainPackageId_isNewspaper.size()>0){
            for (Package_Item__c tmp : [select Package__c from Package_Item__c 
                    where Package__c in :mainPackageId_isNewspaper.keySet() and Is_Newspaper__c = true]) {
                mainPackageId_isNewspaper.put(tmp.Package__c, true);
            }

            for (Zuora__SubscriptionProductCharge__c tmp : [select Zuora__Subscription__c, PublicationCode__c, Zuora__Price__c 
                    from Zuora__SubscriptionProductCharge__c where Zuora__Subscription__c in :mainPackageId_isNewspaper.keySet()]) {
                    
                    //START: 02/18/2015 - Added by Rom Edison Reyes - Checks if tmp.Zuora__Subscription__c is not null and tmp.PublicationCode__c is not null before adding to subscriptionId_publicationCode
                    if(tmp.Zuora__Subscription__c != null && tmp.PublicationCode__c != null){
                        subscriptionId_publicationCode.put(tmp.Zuora__Subscription__c, tmp.PublicationCode__c);
                    }//END: 02/18/2015 - Added by Rom Edison Reyes - Checks if tmp.Zuora__Subscription__c is not null and tmp.PublicationCode__c is not null before adding to subscriptionId_publicationCode
                    
                if (tmp.Zuora__Price__c > 0) {
                    subscriptionId_copyType.put(tmp.Zuora__Subscription__c, 'Subscription');
                } else {
                    subscriptionId_copyType.put(tmp.Zuora__Subscription__c, 'Freelist');
                }
            }
        }//END 02/18/2015 - Added by Rom Edison Reyes - Checks if mainPackageId_isNewspaper is not empty
        
        //START 02/18/2015 - Added by Rom Edison Reyes - Checks if subscriptionId_publicationCode is not empty
        if(subscriptionId_publicationCode.size()>0){
            // retrieve latest publication issue date
            for (SObject tmp : [select Publication_Code__c, Publication_Issue_Date__c 
                    from Publication_Daily_Issue_Data__c where Publication_Code__c in :subscriptionId_publicationCode.values() 
                    group by Publication_Code__c, Publication_Issue_Date__c order by Publication_Issue_Date__c desc]) {
            
                publicationCode_publicationIssueDate.put((string)tmp.get('Publication_Code__c'), (date)tmp.get('Publication_Issue_Date__c'));
            }
            // end retrieve latest publication issue date
        }//END 02/18/2015 - Added by Rom Edison Reyes - Checks if subscriptionId_publicationCode is not empty
        
        for (Zuora__Subscription__c tmp : scope) {
            
            if (mainPackageId_isNewspaper.get(tmp.Main_Package__c) == true) {
                
                Packing_Label_Batch__c packingLabelBatch = new Packing_Label_Batch__c();
                
                if (tmp.Zuora__Account__c != null) {
                    
                    packingLabelBatch.Subscriber_Account_Name__c = tmp.Zuora__Account__r.Name;
                    packingLabelBatch.Subscriber_Account_Number__c = tmp.Zuora__Account__r.AccountNumber;
                    packingLabelBatch.Mailing_Agent_Account_Number__c = tmp.Zuora__Account__r.Mailing_Agent_Code__c;
                }
                
                if (tmp.Recipient_Contact__c != null) {
                    
                    packingLabelBatch.Recipient_Name__c = tmp.Recipient_Contact__r.Name;
                    packingLabelBatch.Recipient_Number__c = tmp.Recipient_Contact__r.Phone;
                    packingLabelBatch.Salutation__c = tmp.Recipient_Contact__r.Salutation;
                    packingLabelBatch.Recipient_Type__c = tmp.Recipient_Contact__r.RecordType.Name;
                    
                    if (tmp.Recipient_Contact__r.Address__c != null) {
                        
                        packingLabelBatch.Address_1__c = tmp.Recipient_Contact__r.Address__r.Address_1__c;
                        packingLabelBatch.Address_2__c = tmp.Recipient_Contact__r.Address__r.Address_2__c;
                        packingLabelBatch.Address_3__c = tmp.Recipient_Contact__r.Address__r.Address_3__c;
                        packingLabelBatch.Address_4__c = tmp.Recipient_Contact__r.Address__r.Address_4__c;
                        packingLabelBatch.Unit__c = tmp.Recipient_Contact__r.Address__r.Unit_Number__c; 
                        packingLabelBatch.Block__c = tmp.Recipient_Contact__r.Address__r.Block_House_Number__c;
                        packingLabelBatch.Building_Name__c = tmp.Recipient_Contact__r.Address__r.Building_Name__c;
                        packingLabelBatch.Country__c = tmp.Recipient_Contact__r.Address__r.Country_Name__c;
                        packingLabelBatch.Level__c = tmp.Recipient_Contact__r.Address__r.Level_Number__c;
                    }
                }
                
                packingLabelBatch.Copy_Type__c = subscriptionId_copyType.get(tmp.Id);
                packingLabelBatch.Issue_Date__c = publicationCode_publicationIssueDate.get(subscriptionId_publicationCode.get(tmp.Id));
                packingLabelBatch.Publication_Code__c = subscriptionId_publicationCode.get(tmp.Id);
                packingLabelBatch.Number_of_Copies__c = tmp.Number_of_Copies__c;
                packingLabelBatch.Record_Type__c = 'Overseas';
                packingLabelBatch.Subscription_Type__c = 'Newspaper';
                            
                packingLabelBatchList.add(packingLabelBatch);
            }
        }
        
        insert packingLabelBatchList;
    }
    
    
    public void finish(Database.BatchableContext bc) {
        
    }
}