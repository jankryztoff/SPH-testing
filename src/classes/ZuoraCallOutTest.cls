/**
 * Class Name: ZuoraCallOutTest
 * @author: Alfred Abrina
 * Date: 02/17/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description Test class for ZuoraCallOut
 *
 */
@isTest(SeeAllData=true)
private class ZuoraCallOutTest {

    /* static testMethod void testZuoraCallOut01() {
    
        Test.setMock(WebServiceMock.class, new zLoginMock());
    
        Zuora.zApi zApiInstance = new Zuora.zApi();
        zApiInstance.zlogin();
    
        //ZuoraCallOut testObj = new ZuoraCallOut();
    } */
    
    
    static testMethod void createZObject(){
     
     //create account object
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         acc.NRIC__c = 'T1234567R';
         acc.Name = 'testacc';
         //insert acc;
         //Test.setMock(WebServiceMock.class, new zLoginMock());
         //Test.startTest();   
         try{
         
         ZuoraCallOut zc = new  ZuoraCallOut();
         Zuora.zObject zObj = new Zuora.zObject('Account');
         Map <String, Account> test = new Map <String, Account>();
         test.put ('Name', acc);
         zc.createZObject(test, 'Account');
    
     }
     catch(Zuora.zRemoteException e){}
     //Test.stopTest();
 }
 
 static testMethod void createMultipleZObject(){
     
     //create account object
         Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
         acc.NRIC__c = 'T1234567R';
         acc.Name = 'testacc';
         //insert acc;
         //Test.setMock(WebServiceMock.class, new zLoginMock());
         //Test.startTest();   
         try{
         
         ZuoraCallOut zc = new  ZuoraCallOut();
         Zuora.zObject zObj = new Zuora.zObject('Account');
         Map <String, Account> test = new Map <String, Account>();
         test.put ('Name', acc);
         
         List<Map<String,Object>> testList = new List<Map<String,Object>>();
         testList.add(test );
         
         zc.createMultipleZObject(testList, 'Account');
    
     }
     catch(Zuora.zRemoteException e){}
     //Test.stopTest();
 }
 
 static testMethod void queryZObject(){
     
     String mySOQL = 'select AccountNumber, Id FROM Account WHERE Id =\'2c92c094533aff39015342347ff86f36\'';
     try{
         ZuoraCallOut zc = new  ZuoraCallOut();
         zc.queryZObject(mySOQL );
     }
     catch(Zuora.zRemoteException e){}
     //Test.stopTest();
 }
 
 static testMethod void updateZObject(){
     
     Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
     acc.NRIC__c = 'T1234567R';
     acc.Name = 'testacc';
     //insert acc;
     //Test.setMock(WebServiceMock.class, new zLoginMock());
     //Test.startTest();   
     try{
     
         ZuoraCallOut zc = new  ZuoraCallOut();
         Zuora.zObject zObj = new Zuora.zObject('Account');
         Map <String, Account> test = new Map <String, Account>();
         test.put ('Name', acc);
         zc.updateZObject(test, 'Account', '000000000000000001');
     }
     catch(Zuora.zRemoteException e){}
     //Test.stopTest();
 }
 
 static testMethod void generateInvoice(){
     
     Test.startTest();
     try {
         ZuoraCallOut zc = new  ZuoraCallOut();
         Zuora.zObject zObj = new Zuora.zObject('Invoice');
         
         Map <String, Object> test = new Map <String, Object>();
         test.put ('AccountId', '2c92c0f9535f95e101536ec9eb2745d5');
         zc.generateInvoice(test);
     }
     catch(Zuora.zRemoteException e){}
     Test.stopTest();
 }
 
 static testMethod void generateInvoiceList(){
     
     Test.startTest();
     try {
         ZuoraCallOut zc = new  ZuoraCallOut();
         Zuora.zObject zObj = new Zuora.zObject('Invoice');
         
         Map <String, Object> test = new Map <String, Object>();
         List<Map <String, Object>> testList = new List<Map <String, Object>>();
         test.put ('AccountId', '2c92c0f9535f95e101536ec9eb2745d5');
         testList.add(test);
         zc.generateInvoiceList(testList);
     }
     catch(Zuora.zRemoteException e){}
     Test.stopTest();
 }
 
 
 
 static testMethod void loadZObjects(){
     Test.startTest();

     Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
     acc.NRIC__c = 'T1234567R';
     acc.Name = 'testacc';

     try{
         
         ZuoraCallOut zc = new  ZuoraCallOut();
         Zuora.zObject zObj = new Zuora.zObject('Account');
         Map <String, Account> test = new Map <String, Account>();
         test.put ('Name', acc);
         
         List<Map<String,Object>> testList = new List<Map<String,Object>>();
         testList.add(test );
         
         zc.loadZObjects(testList, 'Account');
    
     }
     catch(Zuora.zRemoteException e){}
     Test.stopTest();
 }
 
 static testMethod void amendZObjects(){
     Test.startTest();

     Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
     acc.NRIC__c = 'T1234567R';
     acc.Name = 'testacc';

     try{
         
         ZuoraCallOut zc = new  ZuoraCallOut();
         Zuora.zObject zObj = new Zuora.zObject('Account');
         Map <String, Account> test = new Map <String, Account>();
         test.put ('Name', acc);
         
         List<Map<String,Object>> testList = new List<Map<String,Object>>();
         testList.add(test );
         
         zc.amendZObjects(testList);
    
     }
     catch(Zuora.zRemoteException e){}
     Test.stopTest();
 }
 
 static testMethod void updateZObjects(){
     Test.startTest();

     Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
     acc.NRIC__c = 'T1234567R';
     acc.Name = 'testacc';

     try{
         
         ZuoraCallOut zc = new  ZuoraCallOut();
         Zuora.zObject zObj = new Zuora.zObject('Account');
         Map <String, Account> test = new Map <String, Account>();
         test.put ('Name', acc);
         
         List<Map<String,Object>> testList = new List<Map<String,Object>>();
         testList.add(test );
         
         zc.updateZObjects(testList, 'Account');
    
     }
     catch(Zuora.zRemoteException e){}
     Test.stopTest();
 }
 
 static testMethod void zquerymore(){
     Test.startTest();
     ZuoraCallOut zc = new  ZuoraCallOut();
     zc.zquerymore('2c92c094533aff39015342347ff86f36');
     Test.stopTest();
 }
 
 static testMethod void zquerymoreInvoice(){
     Test.startTest();
     ZuoraCallOut zc = new  ZuoraCallOut();
     zc.zquerymoreInvoice('2c92c094533aff39015342347ff86f36');
     Test.stopTest();
 }
 
 static testMethod void zquerymoreInvoices(){
     Test.startTest();
     ZuoraCallOut zc = new  ZuoraCallOut();
     zc.zquerymoreInvoices('2c92c094533aff39015342347ff86f36');
     Test.stopTest();
 }
 
 static testMethod void createMultipleZObjectForRefund(){
     Test.startTest();

     Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
     acc.NRIC__c = 'T1234567R';
     acc.Name = 'testacc';

     try{
         
         ZuoraCallOut zc = new  ZuoraCallOut();
         Zuora.zObject zObj = new Zuora.zObject('Account');
         Map <String, Account> test = new Map <String, Account>();
         test.put ('Name', acc);
         
         List<Map<String,Object>> testList = new List<Map<String,Object>>();
         testList.add(test );
         
         zc.createMultipleZObjectForRefund(testList, 'Account');
    
     }
     catch(Zuora.zRemoteException e){}
     Test.stopTest();
 }
 
 static testMethod void bulkQueryInvoices(){
     Test.startTest();
     ZuoraCallOut zc = new  ZuoraCallOut();
     Set<String> setInvId = new Set<String>();
     setInvId.add('2c92c094533aff39015342347ff86f36');
     setInvId.add('2c92c094533aff39015342347ff86f37');
     zc.bulkQueryInvoices(setInvId);
     Test.stopTest();
 }
 
 static testMethod void bulkQueryPayMet(){
     Test.startTest();
     ZuoraCallOut zc = new  ZuoraCallOut();
     Set<String> setInvId = new Set<String>();
     setInvId.add('2c92c094533aff39015342347ff86f36');
     setInvId.add('2c92c094533aff39015342347ff86f37');
     zc.bulkQueryPayMet(setInvId);
     Test.stopTest();
 }
 
 static testMethod void bulkQueryForInvoiceItemv1(){
     Test.startTest();
     ZuoraCallOut zc = new  ZuoraCallOut();
     Set<String> setInvId = new Set<String>();
     setInvId.add('2c92c094533aff39015342347ff86f36');
     setInvId.add('2c92c094533aff39015342347ff86f37');
     zc.bulkQueryForInvoiceItem(setInvId, 'invoice');
     Test.stopTest();
 }
 
 static testMethod void bulkQueryForInvoiceItemv2(){
     Test.startTest();
     ZuoraCallOut zc = new  ZuoraCallOut();
     Set<String> setInvId = new Set<String>();
     setInvId.add('2c92c094533aff39015342347ff86f36');
     setInvId.add('2c92c094533aff39015342347ff86f37');
     zc.bulkQueryForInvoiceItem(setInvId, 'subscription');
     Test.stopTest();
 }
 
 static testMethod void bulkQueryForAccount(){
     Test.startTest();
     ZuoraCallOut zc = new  ZuoraCallOut();
     Set<String> setInvId = new Set<String>();
     setInvId.add('2c92c094533aff39015342347ff86f36');
     setInvId.add('2c92c094533aff39015342347ff86f37');
     zc.bulkQueryForAccount(setInvId);
     Test.stopTest();
 }
 
 static testMethod void bulkCreateZObjects(){
     Test.startTest();

     Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
     acc.NRIC__c = 'T1234567R';
     acc.Name = 'testacc';

     try{
         
         ZuoraCallOut zc = new  ZuoraCallOut();
         Zuora.zObject zObj = new Zuora.zObject('Account');
         Map <String, Account> test = new Map <String, Account>();
         test.put ('Name', acc);
         
         List<Map<String,Object>> testList = new List<Map<String,Object>>();
         testList.add(test );
         
         zc.bulkCreateZObjects(testList, 'Account');
    
     }
     catch(Zuora.zRemoteException e){}
     Test.stopTest();
 }
 
 static testMethod void loginToZuora(){
   try{
   Test.setMock(WebServiceMock.class, new zLoginMock());
   login();
   }
    catch(Zuora.zRemoteException e){}
 }    
 
 static void login(){
    ZuoraCallOut zc = new  ZuoraCallOut();
     try{
         Test.setMock(WebServiceMock.class, new zLoginMock());
         zc.zApiInstance.zlogin();
     }catch (Zuora.zRemoteException ex){
        if ('Login Failed. ' == ex.code){
            try{
                zc.zApiInstance.setEndpoint('https://apisandbox-zforsf.zuora.com/apps/services/a/58.0');
                zc.zApiInstance.zlogin();
            }catch (Zuora.zRemoteException e){
                System.debug ('Zuora Exception: ' +e.code);
            }
        }
     }
 }
    
    //START PD-0506 6/11/2016 Added by J.Sarion
    static testMethod void deleteZObjects(){
         Test.startTest();
         try{
             
            ZuoraCallOut zc = new  ZuoraCallOut();
            Set<String> zuoraIdSet = new Set<String>();
            zuoraIdSet.add(ResponseUtility.generateExternalId());

            zc.deleteZObjects(zuoraIdSet, 'Subscription');

         }
         catch(Zuora.zRemoteException e){}
         Test.stopTest();
    }
    //END PD-0506 6/11/2016 Added by J.Sarion
 
}