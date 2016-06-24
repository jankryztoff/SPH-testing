/*
 * Class Name: BT_AB_MIRO055DX_VendorCreditingFile
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - MIRO055DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for MIRO055DX batch job. Used together with BT_AS_MIRO055DX_VendorCreditingFile Schedulable
 * 
 * History: 2014/08/26 Kevin Evasco Created Skeletal Apex Batchable
 * History: 2014/10/08 Renino Niefes added code implementation
 * History: 2014/11/07 Renino Niefes added code implementation
 * History: 2015/03/10 D-2310 Renino Niefes removed the criteria in fetching data from MIRO staging object.  Added V in front of the Vendor code
 * UD-3349 - UD-3359 - UD-3354 - 28-Dec-2015 Added by Raviteja - Restructured the class as part of the defect fix. 
 * UD-3349 - 06-Jan-2016 Added by Raviteja - Restructured the class as part of the defect fix. 
 */

global class BT_AB_MIRO055DX_VendorCreditingFile implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    // SOQL Query in getting the interface primary object
    // TO-DO: Update query based on requirements
    global final String interfaceId = 'MIRO055DX';
    //START HotFix 18-Aug-2015 Added by Raviteja - Creating Parametrised constructor 
    global Datetime startDate;
    global Datetime endDate;
    global Date dToday;
    global Boolean isManualRun = False;
    //End HotFix 18-Aug-2015 Added by Raviteja
    //String batchRunDate = null;
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
     //START HotFix 18-Aug-2015 Added by Raviteja - Creating Parametrised constructor 
    
    global BT_AB_MIRO055DX_VendorCreditingFile(){
        /*dToday = Date.Today();
        startDate = datetime.newInstanceGMT(dToday.year(), dToday.month(),dToday.day(),0,0,0);
        endDate = startDate.addDays(1);
    }
    
    global BT_AB_MIRO055DX_VendorCreditingFile(String interfaceId){*/
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId); 
        startDate = Datetime.valueOfGmt(batchRunDate+' 00:00:00');
        endDate = startDate.addDays(1);
        isManualRun = True;
    }
    
    //End HotFix 18-Aug-2015 Added by Raviteja  
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = :interfaceId];
        delete resultList;  
       
        String query = 'SELECT ID, Vendor_Code__c, mailing_agent_code__c, recordType.DeveloperName FROM Account WHERE Active__c = true ';
        query += 'AND RecordType.DeveloperName in  (\'Vendor\',\'Mailing_Agent\') AND Vendor_group__c !=null ';
        //query += 'AND RecordType.DeveloperName in  (\'Vendor\',\'Mailing_Agent\') AND Vendor_group__c !=null limit 1 ';
        System.debug(query);
       
        return Database.getQueryLocator(query);
    }
    
    /* @description Executes the business logic and populates BA_INT_DATA_POOL__c with new records based on the interface requirements.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<Account> lstVendors)//Nitin Khanna : 06-04-2015 : UD-0804 
    {       
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        Map<String, Set<String>> mspSubscriberlist = New  Map<String, Set<String>>();
        Map<String, Decimal> mspSubscriptioncopies = New  Map<String, Decimal>();
        
        String query = '';
        
        //Nitin Khanna : 06-04-2015 : UD-0804 : fetching the vendor numbers from account object : Start
        Set<String> setVendorNumbers = new Set<String>();
        for(Account vendor : lstVendors)
        {
            if(vendor.recordType.DeveloperName == 'Vendor' && vendor.Vendor_code__c != null){
                setVendorNumbers.add(vendor.Vendor_code__c);
            }
            if(vendor.recordType.DeveloperName == 'Mailing_Agent' && vendor.mailing_agent_code__c != null){
                setVendorNumbers.add('MLAGN');
            }
        }

        System.debug('################################# ' + setVendorNumbers.size());
        //Nitin Khanna : 06-04-2015 : UD-0804 : fetching the vendor numbers from account object : End
        
        //Nitin Khanna : 31-3-2015 : UD-341 : Adding aggregate query in the for loop : Start
        
          //START/End UD-3300 and D-3989 24-Nov-2015 Added by Raviteja  - Added ONLIN filter in SOQL - Remove the logic of ONLIN      
        for(BT_CO_MIRO_SubscriptionIssueFile__c ar : [SELECT Publication_Code__c,Publication_Issue_Date__c,postal_sector__c,vendor_number__c,office_house_mail_indicator__c,house_type__c,
                    sub_channel_code__c,subscription_copies__c,subscriberId__c FROM BT_CO_MIRO_SubscriptionIssueFile__c                    
                    where Vendor_Number__c in :setVendorNumbers and Vendor_Number__c != 'MLAGN' and subscription_copies__c > 0 ]){
                
                    String mirokey = '';     
                    mirokey += (String)ar.Publication_Code__c + ',';
                    mirokey += (Date)ar.Publication_Issue_Date__c + ',';
                    mirokey += (String)ar.postal_sector__c + ',';                      
                    mirokey += 'V' + (String)ar.vendor_number__c + ',';
                    mirokey += (String)ar.office_house_mail_indicator__c + ',';
                    
                    String aType = (String)ar.house_type__c;
                    if(aType == 'H' || aType == 'C' || aType == 'L' || aType == '' || aType == null || aType == 'I')
                        mirokey += aType + ',';
                    else
                        mirokey += 'C,';
                    
                    //String scCode = (String)ar.get('sub_channel_code__c');
                    String scCode = (String)ar.sub_channel_code__c;
                    if(scCode!=null && scCode!= '')
                        mirokey += scCode + ',';
                    else
                        mirokey += 'LDS,';                           
                           
                            
                    if(mspSubscriptioncopies.get(mirokey) != null){
                            Decimal copies = (Decimal)mspSubscriptioncopies.get(mirokey) + ar.subscription_copies__c;
                            mspSubscriptioncopies.put( mirokey, copies);
                        }
                        else{
                            mspSubscriptioncopies.put(mirokey, ar.subscription_copies__c);
                        }
                    
                    
                    String subscriberid = (String) ar.subscriberId__c;
                    if(!mspSubscriberlist.containsKey(mirokey))
                        mspSubscriberlist.put(mirokey, new Set<String> {subscriberid});
                    else
                        mspSubscriberlist.get(mirokey).add(subscriberid);
                    
                }
                
            for(String key: mspSubscriptioncopies.keyset()){
            
                String exportData = key;
                Decimal subcopies = (Decimal)mspSubscriptioncopies.get(key);
                Set<String> susbcriberlist = mspSubscriberlist.get(key);
                Decimal Subscribercount = (Decimal)susbcriberlist.size();
                exportData += subcopies + ',';
                exportData += Subscribercount + ',';
                
                BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
                datapoolRecord.Name = interfaceId;
                datapoolRecord.job_id__c = '1';
                datapoolRecord.group_id__c = 'Detail';
                datapoolRecord.run_for_date__c = Date.today();      
                datapoolRecord.insert_time__c = DateTime.now(); 
                datapoolRecord.export_data__c = exportData;
                
                datapoolList.add(datapoolRecord);

            }
        //Nitin Khanna : 31-3-2015 : UD-341/D-2622 : Adding aggregate query in the for loop : Start
        
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
            System.debug('BT_AB_MIRO055DX_VendorCreditingFile insert operation failed.');
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
        BT_AB_MIRO055DX_VendorCreditingFileFinal miroFinal = new BT_AB_MIRO055DX_VendorCreditingFileFinal(startDate, endDate);
        Database.executeBatch(miroFinal,1);
    }
}