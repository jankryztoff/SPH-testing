/*
 * UD-3349 - UD-3359 - UD-3354 - 28-Dec-2015 Added by Raviteja - Restructured the class as part of the defect fix. 
 * UD-3349 - 06-Jan-2016 Added by Raviteja - Restructured the class as part of the defect fix. 
*/
global class BT_AB_MIRO055DX_VendorCreditingFileFinal implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful
{
    global final String interfaceId = 'MIRO055DX';
    global Datetime startDate;
    global Datetime endDate;
    global Date dToday;
    global Boolean isOverseasrun = True;
    
    global BT_AB_MIRO055DX_VendorCreditingFileFinal(Datetime starttime, Datetime endtime){        
        startDate = starttime;
        endDate = endtime;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //String query = 'Select postal_sector__c from Postal_Zone__c where postal_sector__c != Null Limit 1 ';
        String query = 'Select postal_sector__c from Postal_Zone__c where postal_sector__c != Null ';
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Postal_zone__c> postSector)
    {     
        
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        //Map<String, Integer> mspSubscribercount = New  Map<String, Integer>();
        Map<String, Set<String>> mspSubscriberlist = New  Map<String, Set<String>>();
        Map<String, Decimal> mspSubscriptioncopies = New  Map<String, Decimal>();
       
        Set<String> setPostalSector = New Set<String>();  
        for(Postal_zone__c pSector: postSector){
            setPostalSector.add(pSector.postal_sector__c);  
        }
        if(isOverseasrun){
            setPostalSector.add(''); // Added blank postSector for Overseas subscriptions
            //setPostalSector.add('XX');
        }
        Set<String> setPubs = new Set<String>();
        List<String> lstPublications = New List<String>();
        for(publication__c pub :[Select publication_code__c from publication__c where publication_code__c != Null AND Earliest_Start_Date__c >= LAST_N_MONTHS:5 ]){
            setPubs.add(pub.publication_code__c);
        }
        lstPublications.addAll(setPubs);
        
        Integer pubsize = lstPublications.size();
        
        system.debug('startDate : '+startDate);
        system.debug('endDate : '+endDate);
        system.debug('pubsize : '+pubsize);
        
        for(Integer i = 0; i < pubsize ; i = i+3){            
                Set<String> strPubCode = New Set<String>();
                strPubCode.add(lstPublications.get(i));
                if(i+1 <= pubsize-1)
                    strPubCode.add(lstPublications.get(i+1));
                if(i+2 <= pubsize-1)
                    strPubCode.add(lstPublications.get(i+2));
                    
                system.debug('strPubCode : '+strPubCode);
                system.debug('setPostalSector : '+setPostalSector);
                
                for(BT_CO_MIRO_SubscriptionIssueFile__c ar : [SELECT Publication_Code__c,Publication_Issue_Date__c,postal_sector__c,vendor_number__c,office_house_mail_indicator__c,house_type__c,
                    sub_channel_code__c,subscription_copies__c,subscriberId__c FROM BT_CO_MIRO_SubscriptionIssueFile__c                    
                    where Publication_Code__c in :strPubCode and Vendor_Number__c = 'MLAGN'  
                    and subscription_copies__c > 0 and postal_sector__c in :setPostalSector ]){
                
                    String mirokey = '';     
                    mirokey += (String)ar.Publication_Code__c + ',';
                    mirokey += (Date)ar.Publication_Issue_Date__c + ',';
                    mirokey += (String)ar.postal_sector__c + ',';  
                    mirokey  += '      ,';
                    mirokey += (String)ar.office_house_mail_indicator__c + ',';
                    
                    String aType = (String)ar.house_type__c;
                    if(aType == 'H' || aType == 'C' || aType == 'L' || aType == '' || aType == null || aType == 'I')
                        mirokey += aType + ',';
                    else
                        mirokey += 'C,';
                    
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
                
            }   
            //System.debug('ravi mspSubscriberlist ' + mspSubscriberlist);
            //System.debug('ravi mspSubscriptioncopies' + mspSubscriptioncopies);
            //System.debug('ravi mspSubscriptioncopies.keyset : '+mspSubscriptioncopies.keyset());
            
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
         
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
        }
        catch(Exception e)
        {    
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_MIRO055DX_VendorCreditingFile insert operation failed.');
        }
        
        isOverseasrun = False; 
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