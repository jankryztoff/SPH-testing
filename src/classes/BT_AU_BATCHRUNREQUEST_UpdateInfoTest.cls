/**
@Author Val Lu
@name BT_AU_BATCHRUNREQUEST_UpdateInfoTest
@CreateDate 02/26/2015
@Description To test BT_AU_BATCHRUNREQUEST_UpdateInfo class

@Modified by Hazel Jurna M. Limot


@Version <1.0>
*/
@isTest (seeAllData= True)
private class BT_AU_BATCHRUNREQUEST_UpdateInfoTest
{


    private static User testUser;

    /**
    *  This creates testdata
    *  @name testData
    *  @param none
    *  @return none
    *  @throws na
    */    
    private static void testData()
    {
        //Create a new user with Standard User Profile
        testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );  
    }
    
    /**
    *  To test UpdateEndTime method
    *  @name testUpdateEndTime
    *  @param none
    *  @return none
    *  @throws na
    */    
    static testmethod void testUpdateEndTime1()
    {       
        testData();
        
        Test.startTest();
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('NotExistInterface');
        }  
        
        BT_CO_Batch_Run_Request__c batchRunRequest1 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest1.Interface_ID__c = 'TestInterface1';
        batchRunRequest1.Start_Time__c = DateTime.now();
        batchRunRequest1.End_Time__c = null;
        batchRunRequest1.Batch_Run_Date__c = date.today();
        insert batchRunRequest1;
        
        system.assertNotEquals(null, batchRunRequest1.Id);
        Test.stopTest();
    }     
    
    static testmethod void testUpdateEndTime2()
    {
        testData();
        
        Test.startTest();
        
        BT_CO_Batch_Run_Request__c batchRunRequest2 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest2.Interface_ID__c = 'TestInterface1';
        batchRunRequest2.Start_Time__c = DateTime.now();
        batchRunRequest2.End_Time__c = null;
        batchRunRequest2.Batch_Run_Date__c = date.today();
        insert batchRunRequest2;
        
        system.assertNotEquals(null, batchRunRequest2.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('TestInterface1');
        }
        Test.stopTest();        
    }    
    
    static testmethod void testUpdateEndTime3()
    {    
        testData();
        
        Test.startTest();
        BT_CO_Batch_Run_Request__c batchRunRequest3 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest3.Interface_ID__c = 'TestInterface3';
        batchRunRequest3.Start_Time__c = null;
        batchRunRequest3.End_Time__c = null;
        batchRunRequest3.Batch_Run_Date__c = null;
        insert batchRunRequest3;
        
        system.assertNotEquals(null, batchRunRequest3.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('TestInterface3');
        }  
        Test.stopTest();
    }
    
    /**
    *  To test GetStartTime method
    *  @name testGetStartTime
    *  @param none
    *  @return none
    *  @throws na
    */  
    static testmethod void testGetStartTime1()
    {
        testData();
        
        Test.startTest();
        
        BT_CO_Batch_Run_Request__c batchRunRequest1 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest1.Interface_ID__c = 'TestInterface1';
        batchRunRequest1.Start_Time__c = DateTime.now();
        batchRunRequest1.End_Time__c = null;
        batchRunRequest1.Batch_Run_Date__c = date.today();
        insert batchRunRequest1;
        
        system.assertNotEquals(null, batchRunRequest1.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.getStartTime('TestInterface1');
        }
        Test.stopTest();
    }    
    
    static testmethod void testGetStartTime2()
    {
        testData();
        
        Test.startTest();
        
        BT_CO_Batch_Run_Request__c batchRunRequest2 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest2.Interface_ID__c = 'TestInterface2';
        batchRunRequest2.Start_Time__c = DateTime.now();
        batchRunRequest2.End_Time__c = DateTime.now();
        batchRunRequest2.Batch_Run_Date__c = date.today();
        insert batchRunRequest2;
        
        system.assertNotEquals(null, batchRunRequest2.Id);
        
        System.runAs(testUser) 
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.getStartTime('TestInterface2');
        }
        Test.stopTest();
    }
    
    static testmethod void testGetStartTime3()
    {
        testData();
        
        Test.startTest();
        
        BT_CO_Batch_Run_Request__c batchRunRequest2 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest2.Interface_ID__c = 'TestInterface2';
        batchRunRequest2.Start_Time__c = null;
        batchRunRequest2.End_Time__c = DateTime.now();
        batchRunRequest2.Batch_Run_Date__c = date.today();
        insert batchRunRequest2;
        
        system.assertEquals(null, batchRunRequest2.Start_Time__c);
        
        System.runAs(testUser) 
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.getStartTime('TestInterface2');
        }
        Test.stopTest();
    }
    
    /**
    *  To test GetBatchRunDate method
    *  @name testGetBatchRunDate
    *  @param none
    *  @return none
    *  @throws na
    */  
    static testmethod void testGetBatchRunDate()
    {
        testData();
        
        BT_CO_Batch_Run_Request__c batchRunRequest1 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest1.Interface_ID__c = 'TestInterface2';
        batchRunRequest1.Start_Time__c = DateTime.now();
        batchRunRequest1.End_Time__c = null;
        batchRunRequest1.Batch_Run_Date__c = null;
        insert batchRunRequest1;
        
        system.assertNotEquals(null, batchRunRequest1.Id);
        
        string interfaceId = 'TestInterface2';
        
        System.runAs(testUser)
        {
            Test.startTest();
            BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);
            Test.stopTest();
        }           
        
    }
    
    /**
    *  To test BT_AU_BATCHRUNREQUEST_UpdateInfoTest method
    *  @name testMethod1
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testmethod void testMethod1()/*To test with specific Interface_ID__C values*/
    {       
        testData();
        
        Test.startTest();
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('NotExistInterface');
        }  
        Test.stopTest();
    }
    
    static testmethod void testMethodForbatchRunRequest1()
    {
        testData();
        
        Test.startTest();
        
        BT_CO_Batch_Run_Request__c batchRunRequest1 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest1.Interface_ID__c = 'AGD042DX';
        batchRunRequest1.Start_Time__c = DateTime.now();
        batchRunRequest1.End_Time__c = null;
        batchRunRequest1.Batch_Run_Date__c = date.today();
        insert batchRunRequest1;
        
        system.assertNotEquals(null, batchRunRequest1.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('AGD042DX');
        }
        Test.stopTest();        
    }    
    
    static testmethod void testMethodForbatchRunRequest2()
    {
        testData();
        
        Test.startTest();
        
        BT_CO_Batch_Run_Request__c batchRunRequest2 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest2.Interface_ID__c = 'ARM063DX';
        batchRunRequest2.Start_Time__c = DateTime.now();
        batchRunRequest2.End_Time__c = null;
        batchRunRequest2.Batch_Run_Date__c = date.today();
        insert batchRunRequest2;
        
        system.assertNotEquals(null, batchRunRequest2.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('ARM063DX');
        }
        Test.stopTest();  
    }   
    /*
    static testmethod void testMethodForbatchRunRequest3()
    {
        testData();
        
        Test.startTest(); 
        
        BT_CO_Batch_Run_Request__c batchRunRequest3 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest3.Interface_ID__c = 'ARM064DX';
        batchRunRequest3.Start_Time__c = null;
        batchRunRequest3.End_Time__c = null;
        batchRunRequest3.Batch_Run_Date__c = null;
        insert batchRunRequest3;
        
        system.assertNotEquals(null, batchRunRequest3.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('ARM064DX');
        }
        Test.stopTest();
   }    
    */
  /* static testmethod void testMethodForbatchRunRequest4()
    {
        testData();
        
        Test.startTest();  
        
        BT_CO_Batch_Run_Request__c batchRunRequest4 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest4.Interface_ID__c = 'ARM065DX';
        batchRunRequest4.Start_Time__c = null;
        batchRunRequest4.End_Time__c = null;
        batchRunRequest4.Batch_Run_Date__c = null;
        insert batchRunRequest4;
        
        system.assertNotEquals(null, batchRunRequest4.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('ARM065DX');
        }
        Test.stopTest();
    }   */
    
    static testmethod void testMethodForbatchRunRequest5()
    {
        testData();
        
        Test.startTest(); 
         
        BT_CO_Batch_Run_Request__c batchRunRequest5 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest5.Interface_ID__c = 'ARM066DX';
        batchRunRequest5.Start_Time__c = null;
        batchRunRequest5.End_Time__c = null;
        batchRunRequest5.Batch_Run_Date__c = null;
        insert batchRunRequest5;
        
        system.assertNotEquals(null, batchRunRequest5.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('ARM066DX');
        }
        Test.stopTest();
    }   
    
    /**
    *  To test BT_AU_BATCHRUNREQUEST_UpdateInfoTest method
    *  @name testMethod2
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testmethod void testMethod2()/*To test with specific Interface_ID__C 6 to 10 values*/
    {       
        testData();
        
        Test.startTest();
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('NotExistInterface');
        }
        Test.stopTest();  
    }   
    
    static testmethod void testMethodForbatchRunRequest6() 
     {
        testData();
        
        Test.startTest();
        
        BT_CO_Batch_Run_Request__c batchRunRequest6 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest6.Interface_ID__c = 'ARM067DX';
        batchRunRequest6.Start_Time__c = null;
        batchRunRequest6.End_Time__c = null;
        batchRunRequest6.Batch_Run_Date__c = null;
        insert batchRunRequest6;
        
        system.assertNotEquals(null, batchRunRequest6.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('ARM067DX');
        }
        Test.stopTest();
     }   
    /*
     static testmethod void testMethodForbatchRunRequest7() 
     {
        testData();
        
        Test.startTest();
        
        BT_CO_Batch_Run_Request__c batchRunRequest7 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest7.Interface_ID__c = 'CMI087DX';
        batchRunRequest7.Start_Time__c = null;
        batchRunRequest7.End_Time__c = null;
        batchRunRequest7.Batch_Run_Date__c = null;
        insert batchRunRequest7;
        
        system.assertNotEquals(null, batchRunRequest7.Id);
         
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('CMI087DX');
        }
        Test.stopTest();
     }   
    */
     static testmethod void testMethodForbatchRunRequest8() 
     {
        testData();
        
        Test.startTest();
        
        BT_CO_Batch_Run_Request__c batchRunRequest8 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest8.Interface_ID__c = 'CMI101DX';
        batchRunRequest8.Start_Time__c = null;
        batchRunRequest8.End_Time__c = null;
        batchRunRequest8.Batch_Run_Date__c = null;
        insert batchRunRequest8;
        
        system.assertNotEquals(null, batchRunRequest8.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('CMI101DX');
        }
        Test.stopTest();
     }  
     
     static testmethod void testMethodForbatchRunRequest9() 
     {
        testData();
        
        Test.startTest();
      
        BT_CO_Batch_Run_Request__c batchRunRequest9 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest9.Interface_ID__c = 'DIR094DX';
        batchRunRequest9.Start_Time__c = null;
        batchRunRequest9.End_Time__c = null;
        batchRunRequest9.Batch_Run_Date__c = null;
        insert batchRunRequest9;
        
        system.assertNotEquals(null, batchRunRequest9.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('DIR094DX');
        }
        Test.stopTest();
     }  
     
     static testmethod void testMethodForbatchRunRequest10() 
     {
        testData();
        
        Test.startTest();
        
        BT_CO_Batch_Run_Request__c batchRunRequest10 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest10.Interface_ID__c = 'HDS036DX';
        batchRunRequest10.Start_Time__c = null;
        batchRunRequest10.End_Time__c = null;
        batchRunRequest10.Batch_Run_Date__c = null;
        insert batchRunRequest10;
        
        system.assertNotEquals(null, batchRunRequest10.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('HDS036DX');
        }
        Test.stopTest();
    }   
    
    /**
    *  To test BT_AU_BATCHRUNREQUEST_UpdateInfoTest method
    *  @name testMethod3
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testmethod void testMethod3()/*To test with specific Interface_ID__C 11 to 15 values*/
    {       
        testData();
        
        Test.startTest();
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('NotExistInterface');
        }
        Test.stopTest();
    }   
    /*
     static testmethod void testMethodForbatchRunRequest11() 
     {
        testData();
        
        Test.startTest();
        
        BT_CO_Batch_Run_Request__c batchRunRequest11 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest11.Interface_ID__c = 'HDS037DX';
        batchRunRequest11.Start_Time__c = null;
        batchRunRequest11.End_Time__c = null;
        batchRunRequest11.Batch_Run_Date__c = null;
        insert batchRunRequest11;
        
        system.assertNotEquals(null, batchRunRequest11.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('HDS037DX');
        }
        Test.stopTest();
      } 
    */  
    /*
     static testmethod void testMethodForbatchRunRequest12() 
     {
         try{
        testData();
        
        Test.startTest(); 
        
        BT_CO_Batch_Run_Request__c batchRunRequest12 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest12.Interface_ID__c = 'HDS038DX';
        batchRunRequest12.Start_Time__c = null;
        batchRunRequest12.End_Time__c = null;
        batchRunRequest12.Batch_Run_Date__c = null;
        insert batchRunRequest12;
        
        system.assertNotEquals(null, batchRunRequest12.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('HDS038DX');
        }
        Test.stopTest();
         }catch(exception e){}
     }  
    */
     static testmethod void testMethodForbatchRunRequest13() 
     {
        testData();
        
        Test.startTest(); 
        
        BT_CO_Batch_Run_Request__c batchRunRequest13 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest13.Interface_ID__c = 'HDS039DX';
        batchRunRequest13.Start_Time__c = null;
        batchRunRequest13.End_Time__c = null;
        batchRunRequest13.Batch_Run_Date__c = null;
        insert batchRunRequest13;
        
        system.assertNotEquals(null, batchRunRequest13.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('HDS039DX');
        }
        Test.stopTest();
      }
      
     /*static testmethod void testMethodForbatchRunRequest14() 
     {
        testData();
        
        Test.startTest();
        
        BT_CO_Batch_Run_Request__c batchRunRequest14 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest14.Interface_ID__c = 'HDS039DX_CR';
        batchRunRequest14.Start_Time__c = null;
        batchRunRequest14.End_Time__c = null;
        batchRunRequest14.Batch_Run_Date__c = null;
        insert batchRunRequest14;
        
        system.assertNotEquals(null, batchRunRequest14.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('HDS039DX_CR');
        }
        Test.stopTest();
     }  */
     
     static testmethod void testMethodForbatchRunRequest15() 
     {
        testData();
        
        Test.startTest();
         
        BT_CO_Batch_Run_Request__c batchRunRequest15 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest15.Interface_ID__c = 'HDS039DX_DB';
        batchRunRequest15.Start_Time__c = null;
        batchRunRequest15.End_Time__c = null;
        batchRunRequest15.Batch_Run_Date__c = null;
        insert batchRunRequest15;
        
        system.assertNotEquals(null, batchRunRequest15.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('HDS039DX_DB');
        }
        Test.stopTest();
    }   
    
    /**
    *  To test BT_AU_BATCHRUNREQUEST_UpdateInfoTest method
    *  @name testMethod4
    *  @param none
    *  @return none
    *  @throws na
    */ 
    static testmethod void testMethod4()/*To test with specific Interface_ID__C 21 to 25 values*/
    {       
        testData();
        
        Test.startTest();
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('NotExistInterface');
        }
        Test.stopTest();           
    }   
    
   /* static testmethod void testMethodForbatchRunRequest21() 
     {
        testData();
        
        Test.startTest();
        
        BT_CO_Batch_Run_Request__c batchRunRequest21 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest21.Interface_ID__c = 'REW040DX';
        batchRunRequest21.Start_Time__c = null;
        batchRunRequest21.End_Time__c = null;
        batchRunRequest21.Batch_Run_Date__c = null;
        insert batchRunRequest21;
        
        system.assertNotEquals(null, batchRunRequest21.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('REW040DX');
        }
        Test.stopTest();
     }  */
     
     static testmethod void testMethodForbatchRunRequest22() 
     {
        testData();
        
        Test.startTest(); 
        
        BT_CO_Batch_Run_Request__c batchRunRequest22 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest22.Interface_ID__c = 'REW041DX';
        batchRunRequest22.Start_Time__c = null;
        batchRunRequest22.End_Time__c = null;
        batchRunRequest22.Batch_Run_Date__c = null;
        insert batchRunRequest22;
        
        system.assertNotEquals(null, batchRunRequest22.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('REW041DX');
        }
        Test.stopTest();
     }  
     
     static testmethod void testMethodForbatchRunRequest23() 
     {
        testData();
        
        Test.startTest();
         
        BT_CO_Batch_Run_Request__c batchRunRequest23 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest23.Interface_ID__c = 'SAP072DX';
        batchRunRequest23.Start_Time__c = null;
        batchRunRequest23.End_Time__c = null;
        batchRunRequest23.Batch_Run_Date__c = null;
        insert batchRunRequest23;
        
        system.assertNotEquals(null, batchRunRequest23.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('SAP072DX');
        }
        Test.stopTest();
     }  
     
     static testmethod void testMethodForbatchRunRequest24() 
     {
        testData();
        
        Test.startTest(); 
        BT_CO_Batch_Run_Request__c batchRunRequest24 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest24.Interface_ID__c = 'VBS103DX';
        batchRunRequest24.Start_Time__c = null;
        batchRunRequest24.End_Time__c = null;
        batchRunRequest24.Batch_Run_Date__c = null;
        insert batchRunRequest24;
        
        system.assertNotEquals(null, batchRunRequest24.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('VBS103DX');
        }
        Test.stopTest();
     }  
     /*
     static testmethod void testMethodForbatchRunRequest25() 
     {
        testData();
        
        Test.startTest();
        BT_CO_Batch_Run_Request__c batchRunRequest25 =  new BT_CO_Batch_Run_Request__c();
        batchRunRequest25.Interface_ID__c = 'VSS088DX';
        batchRunRequest25.Start_Time__c = null;
        batchRunRequest25.End_Time__c = null;
        batchRunRequest25.Batch_Run_Date__c = null;
        insert batchRunRequest25;
        
        system.assertNotEquals(null, batchRunRequest25.Id);
        
        System.runAs(testUser)
        {
            BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime('VSS088DX');
        }
        
        Test.stopTest();
    }   
    */
}