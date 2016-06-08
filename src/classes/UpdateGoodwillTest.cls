/**
     * Test Class Name: UpdateGoodwillTest
     * @author: John Patrick L. Ocariz
     * @base class: UpdateGoodwill
     * Date: 02/06/2015    
     */

@isTest(SeeAllData=true)
private class UpdateGoodwillTest { 
    
    /*
    *  @name <testupdateBillingAccountPaymentInfo_01>
    *  @description - test method to call updateZuoraGoodWillCall() and getResponse()
    *  @param <void>>
    *  @return <none> -  
    *  @throws exception-<none>
    */
    // static testmethod void testupdateZuoraGoodWillCall(){              
    //     //create zuora account
        
    //     Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
    //     acc.NRIC__c = 'T1234567R';
    //     insert acc;
        
    //     Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
    //     billAcc.Zuora__Account__c = acc.Id;
    //     insert billAcc;
        
    //     //create zpi instances
    //     Zuora.zApi zApiInstance = new Zuora.zApi();
    //     //List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();
    //     Zuora.zObject rec = new Zuora.zObject('Account');        
    //     Zuora.zApi.SaveResult result = new Zuora.zApi.SaveResult();
                
    //     //create test data
    //     string testgoodwillvalue = 'goodwill';
    //     string testbillingAccountId = String.valueOf(billAcc.Id);
    //     string testresponse = 'response';
    //     string testreturnUrl = 'url';  
        
    //     //create zuora for assert
    //     //Zuora.zApi zApiInstance = new Zuora.zApi();        
    //     //Zuora.zObject rec = new Zuora.zObject('Account');
        
    //     // List<Zuora.zObject> objs = new List<Zuora.zObject> {rec};        
    //     //<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(objs); 
       
    //     //start test
    //     try{
    //       test.setMock(WebServiceMock.class, new zApiTest());
    //       test.setMock(WebServiceMock.class, new zLoginMock());
    //             test.startTest();
                
    //             //System.assertEquals(false, result.Success = false);
               
    //             UpdateGoodwill upg = new UpdateGoodwill();
    //             System.assertNotEquals(null, upg);
               
    //             UpdateGoodwill.updateZuoraGoodWillCall(testgoodwillValue, testbillingAccountId);
    //             upg.getResponse();
                
    //             test.stopTest();
    //     }
    //     catch(Exception e){} 
        
    // }
    
    // static testmethod void testupdateZuoraGoodWillCall2(){              
    //     //create zuora account
    //     Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
    //     //acc.NRIC__c = 'T1234567R';
    //     insert acc;
        
    //     Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
    //     billAcc.Zuora__Account__c = acc.Id;
    //     insert billAcc;
        
    //     //create zpi instances
    //     //Zuora.zApi zApiInstance = new Zuora.zApi();
    //     //List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();
    //     //Zuora.zObject rec = new Zuora.zObject('Account');        
    //     //Zuora.zApi.SaveResult result = new Zuora.zApi.SaveResult();
        
    //     //insert results;
                
    //     //create test data
    //     string testgoodwillvalue;
    //     string testbillingAccountId;
    //     string testresponse;
    //     string testreturnUrl;  
        
    //     //create zuora for assert
    //     //Zuora.zApi zApiInstance = new Zuora.zApi();        
    //     //Zuora.zObject rec = new Zuora.zObject('Account');
        
    //     // List<Zuora.zObject> objs = new List<Zuora.zObject> {rec};        
    //     //<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(objs); 
       
    //     //start test
    //     try{
    //       test.setMock(WebServiceMock.class, new zApiTest());
    //       test.setMock(WebServiceMock.class, new zLoginMock());
    //             test.startTest();
                
    //             //System.assertEquals(false, result.Success = false);
               
    //             UpdateGoodwill upg = new UpdateGoodwill();
    //             System.assertNotEquals(null, upg);
    //             //result.Success = false;
    //             UpdateGoodwill.updateZuoraGoodWillCall(null, null);
    //             upg.getResponse();
                
    //             test.stopTest();
    //     }
    //     catch(Exception e){} 
        
    // }

    /*********************************************************
     * @author              : Kingsley Tumaneng
     * @date                : MAY 23, 2016
     * @description         : test method for UpdateGoodwill 
     *                        that is Error
     * 
    *********************************************************/
    static testmethod void testNotSuccess(){              
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            insert acc;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            insert billAcc;
         
        //create test data
        string testgoodwillvalue            = 'goodwill';
        string testbillingAccountId         = String.valueOf(billAcc.Id);
        string testresponse                 = 'response';
        string testreturnUrl                = 'url';  
        
        test.startTest();
        
            UpdateGoodwill upg = new UpdateGoodwill();
            System.assertNotEquals(null, upg);
            
            upg.getResponse();
            UpdateGoodwill.updateZuoraGoodWillCall(testgoodwillValue, testbillingAccountId);
            UpdateGoodwill.isTrue = false;
            
        test.stopTest();
    }
    
    /*********************************************************
     * @author              : Kingsley Tumaneng
     * @date                : MAY 23, 2016
     * @description         : test method for UpdateGoodwill 
     *                        that is Success
     * 
    *********************************************************/
    static testmethod void testSuccess(){              
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            insert acc;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            insert billAcc;
        
        //create test data
        string testgoodwillvalue            = 'goodwill';
        string testbillingAccountId         = String.valueOf(billAcc.Id);
        string testresponse                 = 'response';
        string testreturnUrl                = 'url';  
        
        test.startTest();
        
            UpdateGoodwill upg = new UpdateGoodwill();
            System.assertNotEquals(null, upg);
            
            UpdateGoodwill.updateZuoraGoodWillCall(testgoodwillValue, testbillingAccountId);
            
        test.stopTest();
    }
}