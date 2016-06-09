global class  BT_AT_BatchCalloutHandler implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{

    String interfaceId = '';
     
    public BT_AT_BatchCalloutHandler(String interfaceId){
        this.interfaceId = interfaceId ;
    }
     
    global Database.QueryLocator start(Database.BatchableContext BC){    
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(interfaceId); 
        String query = 'select id from BT_CO_Batch_Run_Request__c where interface_id__c = :interfaceId  and end_time__c = null';
        return Database.getQueryLocator(query);
    }
    

    global void execute(Database.BatchableContext BC, List<sObject> scope){   
    }
    

    global void finish(Database.BatchableContext BC)
    {  
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId );
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');
        
        //System.debug('*********************** inside final'+ this.query);
        BatchServiceFacade a1F = new BatchServiceFacade();
        BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
        serviceRequestVO.setJobStatus(0);  
        serviceRequestVO.setJobID(interfaceid);
        serviceRequestVO.setJobDate(myDate);
        System.debug('################ before');
        a1F.delegateBatchCall(serviceRequestVO);
        System.debug('################ after'); 
    }

}