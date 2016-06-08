@isTest(SeeAllData=true)
private class ZuoraCallOutTest2 {
    static testMethod void testZuoraCallOut01() {
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Zuora__ZInvoice__c inv = TestDataFactory.createInvoice(1)[0];
        database.insert(inv);
        
        Map<String,Object> mapObject = new Map<String,Object>();
        mapObject.put(inv.Id, inv);
    
        test.startTest();
            ZuoraCallOut zc = new ZuoraCallOut();
            try{
                zc.createZObject(mapObject, inv.id);
            }
            catch(Exception e){}
        test.stopTest();
    }
    
    static testMethod void testZuoraCallOut02() {
        test.startTest();
            ZuoraCallOut zc = new ZuoraCallOut();
            try{
                zc.createMultipleZObject(null, '');
            }
            catch(Exception e){}
        test.stopTest();
    }
    
    static testMethod void testZuoraCallOut03() {
        test.startTest();
            ZuoraCallOut zc = new ZuoraCallOut();
            try{
                zc.queryZObject('');
            }
            catch(Exception e){}
        test.stopTest();
    }
    
    static testMethod void testZuoraCallOut04() {
        Zuora__ZInvoice__c inv = TestDataFactory.createInvoice(1)[0];
        database.insert(inv);
        
        Map<String,Object> mapObject = new Map<String,Object>();
        mapObject.put(inv.Id, inv);
    
        test.startTest();
            ZuoraCallOut zc = new ZuoraCallOut();
            try{
                zc.updateZObject(mapObject, '', '');
            }
            catch(Exception e){}
        test.stopTest();
    }
    
    static testMethod void testZlogin01() {
        ZuoraCallOut testObj = new ZuoraCallOut();
        
        Map<String,Object> objectMap = new Map<String,Object>();
        objectMap.put('Name', '12345678');
        //objectMap.put('EffectiveStartDate','2010-12-31T00:00:00');
        String obj = 'Account';
        
        System.debug('>>>>>>>>>>');
        System.debug(testObj.createZObject(objectMap, obj));
        System.debug('<<<<<<<<<<');
        
        List<Map<String,Object>> listMap = new List<Map<String,Object>>();
        listMap.add(objectMap);
        
        System.debug(testObj.createMultipleZObject(listMap, obj));
        
        String SqueryStr = 'SELECT Name FROM Account';
        
        System.debug(testObj.queryZObject(SqueryStr));
        
        String objId = TestUtility.getFakeId(Account.SObjectType);
        
        System.debug(testObj.updateZObject(objectMap, obj, objId));
        
        System.debug(testObj.generateInvoice(objectMap));
        
        System.debug(testObj.loadZObjects(listMap, obj));
        
        System.debug(testObj.amendZObjects(listMap));
        
        System.debug(testObj.updateZObjects(listMap, obj));
        
        System.debug(testObj.generateInvoiceList(listMap));
        
        String inv = 'SELECT Name FROM Account';
        
        try{
          System.debug(testObj.zquerymore(inv));
        }catch(Exception e) {System.debug(e);}
        
        try{
          System.debug(testObj.zquerymoreInvoice(inv));
        }catch(Exception e) {System.debug(e);}
        
        try{
          System.debug(testObj.zquerymoreInvoices(inv));
        }catch(Exception e) {System.debug(e);}
        
        System.debug(testObj.amendMultipleZObjects(listMap));
        
        List<String> zuoraIdList = new List<String>();
        zuoraIdList.add(objId);
        
        System.debug(testObj.deleteZObjects(zuoraIdList, obj));
        
        
    }
}