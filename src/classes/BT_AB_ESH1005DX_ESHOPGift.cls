/*
 * Class Name: BT_AB_ESH1005DX_ESHOPPublication
 * @author: Nitin Khanna
 * Date: 20/09/2014
 * Project/Requirement: SPH Integration - ESH1005DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for ESH1005DX batch job. 
 * 
 */
//START D-1882 05-Feb-2015 Added by Raviteja- Implemented the 'Database.Stateful' in order to access the 'datapoolListsize' variable in Finish()  
global class BT_AB_ESH1005DX_ESHOPGift implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {

     String query = '';    
     String interfaceName = '';
     List<String> fieldList = new List<String>();
	 //START D-1882 05-Feb-2015 Added by Raviteja- Created new Integer to store the datapoolList size
     global Integer datapoolListsize = 0;  
     //End D-1882 05-Feb-2015 Added by Raviteja
     
     public BT_AB_ESH1005DX_ESHOPGift(String interfaceName){
        this.interfaceName = interfaceName;
        this.query = BT_INT_UTILITY.createSimpleQuery(interfaceName,'');
        System.debug('*********************** inside ctor'+ this.query);
     }
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = 'ESH1005DX'];
        delete resultList;  
		
		//START D-1882 05-Feb-2015 Added by Raviteja -INSERTING Header record into BA_INT_DATA_POOL__c 
        BA_INT_DATA_POOL__c datapoolHRecord = new BA_INT_DATA_POOL__c();
        datapoolHRecord.name = interfaceName;
        datapoolHRecord.job_id__c = interfaceName;
        datapoolHRecord.group_id__c = 'Master';
        datapoolHRecord.run_for_date__c = Date.today();      
        datapoolHRecord.insert_time__c = DateTime.now(); 
        datapoolHRecord.export_data__c = 'H,'+DateTime.now();        
        insert datapoolHRecord;    
        //End D-1882 05-Feb-2015 Added by Raviteja
		
        System.debug('*********************** inside start'+ this.query);
        return Database.getQueryLocator(this.query);
    }
    
    /* @description Executes the business logic and populates BA_INT_DATA_POOL__c with new records based on the interface requirements.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<sObject> scope){   
        System.debug('*********************** inside execute'+ this.query);    
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        //START D-1882 05-Feb-2015 Added by Raviteja -commented and move the code to start method
        /*
        BA_INT_DATA_POOL__c datapoolHRecord = new BA_INT_DATA_POOL__c();
        datapoolHRecord.name = interfaceName;
        datapoolHRecord.job_id__c = interfaceName;
        datapoolHRecord.group_id__c = 'Master';
        datapoolHRecord.run_for_date__c = Date.today();      
        datapoolHRecord.insert_time__c = DateTime.now(); 
        datapoolHRecord.export_data__c = 'H,'+DateTime.now();
        datapoolList.add(datapoolHRecord);        
        */
        //End D-1882 05-Feb-2015 Added by Raviteja
        for(sObject record : scope){          
            System.debug(record);  
            
            Promotion_gift__c prodPubRec = (Promotion_gift__c)record;

            String exportData = '';
            exportData += prodPubRec.gift__r.Gift_Code__c + ',';
            exportData += prodPubRec.gift__r.Gift_description__c + ',';
            exportData += prodPubRec.createddate + ',';
            exportData += prodPubRec.createdby.name + ',';
            exportData += prodPubRec.lastmodifieddate + ',';
            exportData += prodPubRec.lastmodifiedby.name + ',';
            exportData += prodPubRec.Balance_Quantity__c + ',';
            exportData += prodPubRec.Promotion__r.Promotion_Code__c + ',';
            //START D-1882 05-Feb-2015 Added by Raviteja - Added Promotion__r.Contract_Period__c field in export data
            exportData += prodPubRec.Promotion__r.Contract_Period__c + ','; 
            //End D-1882 05-Feb-2015 Added by Raviteja
            
            BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
            datapoolRecord.name = interfaceName;
            datapoolRecord.job_id__c = interfaceName;
            datapoolRecord.group_id__c = 'Master';
            datapoolRecord.run_for_date__c = Date.today();      
            datapoolRecord.insert_time__c = DateTime.now(); 
            datapoolRecord.export_data__c = exportData;
            
            datapoolList.add(datapoolRecord);
            System.debug('%%%%%%%%%%%%%%%%%%%%%'+datapoolRecord);
        }
		//START D-1882 05-Feb-2015 Added by Raviteja - commented the code and moved to Finish method
        /*
        BA_INT_DATA_POOL__c datapoolTRecord = new BA_INT_DATA_POOL__c();
        datapoolTRecord.name = interfaceName;
        datapoolTRecord.job_id__c = interfaceName;
        datapoolTRecord.group_id__c = 'Master';
        datapoolTRecord.run_for_date__c = Date.today();      
        datapoolTRecord.insert_time__c = DateTime.now(); 
        datapoolTRecord.export_data__c = 'T,'+(datapoolList.size()-1);
        datapoolList.add(datapoolTRecord);
		*/
        //End D-1882 05-Feb-2015 Added by Raviteja
        
		//START D-1882 05-Feb-2015 Added by Raviteja - Calculating the datapoolList size 
         datapoolListsize = datapoolList.size()+datapoolListsize;
        //End D-1882 05-Feb-2015 Added by Raviteja
		
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try{
            insert datapoolList;
        }
        catch(Exception e){    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_ESH1005DX_ESHOPPublication insert operation failed.');
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
		//START D-1882 05-Feb-2015 Added by Raviteja -INSERTING Tali(last) record into BA_INT_DATA_POOL__c 
        BA_INT_DATA_POOL__c datapoolTRecord = new BA_INT_DATA_POOL__c();
        datapoolTRecord.name = interfaceName;
        datapoolTRecord.job_id__c = interfaceName;
        datapoolTRecord.group_id__c = 'Master';
        datapoolTRecord.run_for_date__c = Date.today();      
        datapoolTRecord.insert_time__c = DateTime.now(); 
        datapoolTRecord.export_data__c = 'T,'+(datapoolListsize);        
        insert datapoolTRecord;
        //End D-1882 05-Feb-2015 Added by Raviteja
        
		//start Nitin/D-2087/6Feb2015 callout moved to a chained batch class
        BT_AT_BatchCalloutHandler calloutHandler = new BT_AT_BatchCalloutHandler(interfaceName);
        Database.executeBatch(calloutHandler);
		//end Nitin/D-2087/6Feb2015
        

    }
}