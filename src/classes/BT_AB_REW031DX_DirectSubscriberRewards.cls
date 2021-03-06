/*
 * Class Name: BT_AB_REW031DX_DirectSubscriberRewards
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - REW031DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for REW031DX batch job. Used together with BT_AS_REW031DX_DirectSubscriberRewards Schedulable
 * 
 * History: 08/26/2014 Kevin Evasco Created Skeletal Apex Batchable
 * History: 09/25/2014 Renino Niefes added code implementations
 */


global class BT_AB_REW031DX_DirectSubscriberRewards implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    // SOQL Query in getting the interface primary object
    // TO-DO: Update query based on requirements
    global final String query = 'SELECT zqu__SKU__c FROM zqu__ZProduct__c WHERE ProductSubType__c = \'Newspaper\'';    
    global final String interfaceId = 'REW031DX';
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = :interfaceId];
        delete resultList;                  
    
        return Database.getQueryLocator(query);
    }
    
    /* @description Executes the business logic and populates BA_INT_DATA_POOL__c with new records based on the interface requirements.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {       
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        String recordTypeID = ConstantsSLB.getKeyId('Account_Direct Individual');
        String prevCutOffDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getStartTime(interfaceId);
        
        Set<String> skuSet = new Set<String>();     
        for(sObject record : scope) {
            zqu__ZProduct__c zProduct = (zqu__ZProduct__c) record;
            skuSet.add(zProduct.zqu__SKU__c);
        }     
     
        List<Zuora__SubscriptionProductCharge__c> subProductCharges = [SELECT 
                Zuora__Subscription__r.Subscriber_Contact__r.Name,
                Zuora__Subscription__r.Subscriber_Contact__r.NRIC__c,
                Zuora__Subscription__r.Zuora__Account__r.Date_Of_Birth__c,
                Zuora__Subscription__r.Subscriber_Contact__r.Phone,
                Zuora__Subscription__r.Subscriber_Contact__r.Email__c,
                Zuora__Subscription__r.Zuora__SubscriptionEndDate__c,
                Zuora__Subscription__r.Zuora__Account__r.AccountNumber,
                Zuora__Subscription__r.Subscriber_Contact__r.Address__r.Postal_Code__r.Name,
                Zuora__Subscription__r.Subscriber_Contact__r.Address__r.Block_House_Number__c,
                Zuora__Subscription__r.Subscriber_Contact__r.Address__r.Level_Number__c,
                Zuora__Subscription__r.Zuora__Account__r.Id
            FROM Zuora__SubscriptionProductCharge__c 
            WHERE Zuora__ProductSKU__c in :skuSet
            AND Zuora__Subscription__r.Zuora__Account__r.RecordTypeId = :recordTypeID           
            ];
            //AND LastModifiedDate = :prevCutOffDate  remove for now
            
        for(sObject record : subProductCharges) 
        {
            Zuora__SubscriptionProductCharge__c subProdCharge = (Zuora__SubscriptionProductCharge__c) record;
            String exportData = ''; 
            
            exportData += subProdCharge.Zuora__Subscription__r.Subscriber_Contact__r.Name + ','; //Customer Name 
            exportData += subProdCharge.Zuora__Subscription__r.Subscriber_Contact__r.NRIC__c + ','; //NRIC Passport 
            exportData += subProdCharge.Zuora__Subscription__r.Zuora__Account__r.Date_Of_Birth__c + ','; //Birth Date 
            exportData += subProdCharge.Zuora__Subscription__r.Subscriber_Contact__r.Phone + ','; //Telephone Number 
            exportData += subProdCharge.Zuora__Subscription__r.Subscriber_Contact__r.Email__c + ','; //Email ID 
            exportData += subProdCharge.Zuora__Subscription__r.Zuora__SubscriptionEndDate__c + ','; //Expiry Date 
            exportData += subProdCharge.Zuora__Subscription__r.Zuora__Account__r.AccountNumber + ','; //Subscriber ID 
            exportData += subProdCharge.Zuora__Subscription__r.Subscriber_Contact__r.Address__r.Postal_Code__r.Name + ','; //Postal Code 
            exportData += subProdCharge.Zuora__Subscription__r.Subscriber_Contact__r.Address__r.Block_House_Number__c + ','; //House Block Number 
            exportData += subProdCharge.Zuora__Subscription__r.Subscriber_Contact__r.Address__r.Level_Number__c + ','; //Level Number 
            exportData += ','; //Unit Number TBD
            exportData += ','; //Online User ID TBD
            exportData += 'N,'; //Privacy Indicator Hard Coded
            exportData += subProdCharge.Zuora__Subscription__r.Zuora__Account__r.Id; //CRSM Account ID

            
            // Prepare Data Pool information here
            BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
            datapoolRecord.Name = interfaceId;
            datapoolRecord.job_id__c = '1';
            datapoolRecord.group_id__c = 'Detail';
            datapoolRecord.run_for_date__c = Date.today();      
            datapoolRecord.insert_time__c = DateTime.now(); 
            datapoolRecord.export_data__c = exportData;
            
            datapoolList.add(datapoolRecord);
        }

     
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_' + interfaceId + '_DirectSubscriberRewards insert operation failed.');
        }
    }
    
    /*
     * @description A method which executes the final actions of the class.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
    global void finish(Database.BatchableContext BC)
    {
          //Get the batch run date
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);            
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');
                
        //System.debug('*********************** inside final'+ this.query);
        BatchServiceFacade a1F = new BatchServiceFacade();
        BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
        serviceRequestVO.setJobStatus(0);
        serviceRequestVO.setJobID(interfaceId);
        serviceRequestVO.setJobDate(myDate);
        System.debug('################ before');
        a1F.delegateBatchCall(serviceRequestVO);
        System.debug('################ after');        

        //Update Batch Run Request's End Time
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(interfaceId);
    }
}