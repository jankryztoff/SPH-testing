/**
   @Author Val Lu
   @name SP_AddressAssignmentCallOutTest
   @CreateDate 02/26/2015
   @Description To test SP_AddressAssignmentCallOut class
   @Version <1.0>
  */
@isTest (Seealldata = TRUE)
private class SP_AddressAssignmentCallOutTest {
    /**
    *  To test SP_AddressAssignmentCallOut class
    *  @name testSP_AddressAssignmentCallOut
    *  @param none
    *  @return none
    *  @throws na
    */
    static testMethod void testSP_AddressAssignmentCallOut(){
        
        List<Account> CallOutAccount =  TestDataFactory.createAccount(2,'Direct Corporate');
        database.insert(CallOutAccount);
        
        List<Map<String, Object>> subMapList = new List<Map<String, Object>>();
        Map<String,String> subMap;
        
        for (integer i=0; i<10;i++)
        {
            subMap = new Map<String,String>();
            subMap.put('Status', 'Success');
            subMapList.add(subMap);            
        }  
        
        
        //SP_AddressAssignmentCallOut batch = new SP_AddressAssignmentCallOut(subMapList);
        //Database.executeBatch(batch, GlobalVariableClass.MAX_NO_OF_RECORD_50);
        
        Test.startTest();
        try{
        Test.setMock(WebServiceMock.class, new zLoginMock());
        
        SP_AddressAssignmentCallOut batch = new SP_AddressAssignmentCallOut(subMapList);
        //ID batchprocessid = Database.executeBatch(batch, 200);
       
        //system.assertNotEquals(null, batchprocessid);
        Database.BatchableContext BC;
        batch.start(BC);
        batch.execute(BC, CallOutAccount); 
        try
        {
            batch.finish(BC); 
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
        
        
        Test.stopTest();
        }
        catch(Zuora.zRemoteException e){
            String error = e.getMessage();
        }
       } 
    }