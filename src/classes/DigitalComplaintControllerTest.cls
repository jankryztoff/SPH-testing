/**
@Author Alfred Abrina
@name DigitalComplaintControllerTest
@CreateDate 02/15/2015
@Modified by Ana Fe Dumangas
@Modified by 6/23/15
@Description Test class for DigitalComplaintController
@Version <1.0>
@reference DigitalComplaintController
*/  
@isTest(SeeAllData = TRUE)
private class DigitalComplaintControllerTest {
  
/**
* Test method for data creation 
* @name testDigitalComplaint
*/       
  static testMethod void testDigitalComplaint()
    {  
      Account acc = new Account(Name = 'Test Account', Email__c = 'test@sample.com', Mobile__c = '123456789',
      RecordtypeId = ConstantsSLB.getKeyId('Account_Direct Individual'), 
      Generate_Account_Number__c = TRUE); 
      insert acc;     
      
      Contact con = TestDataFactory.createContact(1)[0];     
      con.AccountId = acc.Id;
      con.RecordTypeId =  ConstantsSLB.getKeyId('Contact_Customer Contact');
      con.Recipient_Indicator__c = true;  
      insert con;      
       
      Asia1__c asia = new Asia1__c();
      asia.ASIAONE_Legacy_Id__c = 'tsh44sa5';
      asia.Legacy_Created_Date__c = '12320514';
      asia.Legacy_Created_By__c = 'lando';
      asia.Legacy_Updated_Date__c = '114409';
      asia.Legacy_Updated_By__c = 'dola4nd';
      asia.Display_Name__c = 'mytest';
      asia.User_ID_LDAP_ID__c = 'alfred2015';
      asia.Password__c = 'newPass';     
      asia.Email__c = 'test@force.com';   
      insert asia;
      
      Asia1_Subscription__c asiasub = new Asia1_Subscription__c();
      asiasub.Asia1__c = asia.id;
      asiasub.Status__c = 'Active';
      insert asiasub;  
                 
      Case cas = TestDataFactory.createCase(1, 'Enquiry')[0];
      cas.AccountId = acc.Id;
      cas.ContactId = con.Id; 
      insert cas;        
    
      String username = 'alfred2015';
      String password = 'newPass';
      String displayName = 'mytest'; 
                  
      DigitalComplaintController dg = new DigitalComplaintController();
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
      dg.responseMap = new Map<String, String>();       
      boolean resetPassword = dg.resetPassword(cas, username, asiasub.Id, password, 'SVC', displayName);  
     
      dg.validateNewUsername(username, displayName);
      dg.enableServiceFlag (cas, username, 'SVC');              
 
      dg.disableServiceFlag(cas, username, password, displayName, 'SVC');  
      Map<String, String> mapCont = new Map<String, String>();
      mapCont.put ('Id', asia.Id);
      mapCont.put(GlobalVariableClass.USERNAME, username); 
      mapCont.put(GlobalVariableClass.DISPLAY_NAME, displayName); 
      mapCont.put(GlobalVariableClass.PASSWORD, password);
      mapCont.put(GlobalVariableClass.EMAIL, 'test@force.com');                     
      mapCont.put(GlobalVariableClass.SVC, 'svc');   
      dg.createAccount(cas, mapCont);   
  
        
      dg.createDigitalComplaintItems(cas, username, password, 'SVC', displayName, 'Active');
      dg.getErrors();
 
      Test.stopTest();        
    }
        
    static testMethod void testValidateUsernameFailed()
    {  
      Account acc = new Account(Name = 'Test Account', Email__c = 'test@sample.com', Mobile__c = '123456789',
      RecordtypeId = ConstantsSLB.getKeyId('Account_Direct Individual'), 
      Generate_Account_Number__c = TRUE); 
      insert acc;     
      
      Contact con = TestDataFactory.createContact(1)[0];     
      con.AccountId = acc.Id;
      con.RecordTypeId =  ConstantsSLB.getKeyId('Contact_Customer Contact');
      con.Recipient_Indicator__c = true;  
      insert con;      
       
      Asia1__c asia = new Asia1__c();
      asia.ASIAONE_Legacy_Id__c = 'tsh44sa5';
      asia.Legacy_Created_Date__c = '12320514';
      asia.Legacy_Created_By__c = 'lando';
      asia.Legacy_Updated_Date__c = '114409';
      asia.Legacy_Updated_By__c = 'dola4nd';
      asia.Display_Name__c = 'mytest';
      asia.User_ID_LDAP_ID__c = 'alfred2015';
      asia.Password__c = 'newPass';     
      asia.Email__c = 'test@force.com';   
      insert asia;
      
      Asia1_Subscription__c asiasub = new Asia1_Subscription__c();
      asiasub.Asia1__c = asia.id;
      asiasub.Status__c = 'Active';
      insert asiasub;  
                 
      Case cas = TestDataFactory.createCase(1, 'Enquiry')[0];
      cas.AccountId = acc.Id;
      cas.ContactId = con.Id;      
    //  cas.Sub_Category__c = 'User Id Not Created/Activated';
      insert cas;
              
      String username = 'alfred2015';
      String password = 'newPa';
      String displayName = 'mest'; 
                  
      DigitalComplaintController dg = new DigitalComplaintController();
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockFail2Test());
           
      Map<String, Boolean > validateNewUser = dg.validateNewUsername(username, displayName);
      System.assertEquals(validateNewUser.get('userNameValidationResult'), false); 
      Test.stopTest();        
      } 
/**
* Test method for data creation 
* @name testEnableServiceFlagFailed
*/       
    static testMethod void testEnableServiceFlagFailed()
    {  
      Account acc = new Account(Name = 'Test Account', Email__c = 'test@sample.com', Mobile__c = '123456789',
      RecordtypeId = ConstantsSLB.getKeyId('Account_Direct Individual'), 
      Generate_Account_Number__c = TRUE); 
      insert acc;     
      
      Contact con = TestDataFactory.createContact(1)[0];     
      con.AccountId = acc.Id;
      con.RecordTypeId =  ConstantsSLB.getKeyId('Contact_Customer Contact');
      con.Recipient_Indicator__c = true;  
      insert con;      
       
      Asia1__c asia = new Asia1__c();
      asia.ASIAONE_Legacy_Id__c = 'tsh44sa5';
      asia.Legacy_Created_Date__c = '12320514';
      asia.Legacy_Created_By__c = 'lando';
      asia.Legacy_Updated_Date__c = '114409';
      asia.Legacy_Updated_By__c = 'dola4nd';
      asia.Display_Name__c = 'mytest';
      asia.User_ID_LDAP_ID__c = 'alfred2015';
      asia.Password__c = 'newPass';     
      asia.Email__c = 'test@force.com';   
      insert asia;
      
      Asia1_Subscription__c asiasub = new Asia1_Subscription__c();
      asiasub.Asia1__c = asia.id;
      asiasub.Status__c = 'Active';
      insert asiasub;  
                 
      Case cas = TestDataFactory.createCase(1, 'Enquiry')[0];
      cas.AccountId = acc.Id;
      cas.ContactId = con.Id;      
      cas.Sub_Category__c = 'User Id Not Created/Activated';
      insert cas;
              
      String username = 'alfred2145';
      String password = 'newPa';
      String displayName = 'mest'; 
                  
      DigitalComplaintController dg = new DigitalComplaintController();
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockFail2Test());
     
      boolean isSuccess = dg.enableServiceFlag (cas, 'errorUser', 'SVC');              
      System.assertEquals(isSuccess, false);        
      
      Test.stopTest();        
      }  
/**
* Test method for data creation 
* @name testDisableServiceFlagFailed
*/         
    static testMethod void testDisableServiceFlagFailed()
    {  
      Account acc = new Account(Name = 'Test Account', Email__c = 'test@sample.com', Mobile__c = '123456789',
      RecordtypeId = ConstantsSLB.getKeyId('Account_Direct Individual'), 
      Generate_Account_Number__c = TRUE); 
      insert acc;     
      
      Contact con = TestDataFactory.createContact(1)[0];     
      con.AccountId = acc.Id;
      con.RecordTypeId =  ConstantsSLB.getKeyId('Contact_Customer Contact');
      con.Recipient_Indicator__c = true;  
      insert con;      
       
      Asia1__c asia = new Asia1__c();
      asia.ASIAONE_Legacy_Id__c = 'tsh44sa5';
      asia.Legacy_Created_Date__c = '12320514';
      asia.Legacy_Created_By__c = 'lando';
      asia.Legacy_Updated_Date__c = '114409';
      asia.Legacy_Updated_By__c = 'dola4nd';
      asia.Display_Name__c = 'mytest';
      asia.User_ID_LDAP_ID__c = 'alfred2015';
      asia.Password__c = 'newPass';     
      asia.Email__c = 'test@force.com';   
      insert asia;
      
      Asia1_Subscription__c asiasub = new Asia1_Subscription__c();
      asiasub.Asia1__c = asia.id;
      asiasub.Status__c = 'Active';
      insert asiasub;  
                 
      Case cas = TestDataFactory.createCase(1, 'Enquiry')[0];
      cas.AccountId = acc.Id;
      cas.ContactId = con.Id; 
      cas.Sub_Category__c = 'Change/Reset Password';     
      insert cas;        
    
      String username = 'alfred2015';
      String password = 'newPass';
      String displayName = 'mytest'; 
                  
      DigitalComplaintController dg = new DigitalComplaintController();
      Test.startTest();
     
      boolean isDisabled = dg.disableServiceFlag(cas, 'errorUser', password, displayName, 'SVC');  
      System.assertEquals (isDisabled, true);
      dg.getErrors();     
     
      Test.stopTest();        
    }
/**
* Test method for data creation 
* @name testDisableServiceFlagSuccess
*/    
    static testMethod void testDisableServiceFlagSuccess()
    {  
      Account acc = new Account(Name = 'Test Account', Email__c = 'test@sample.com', Mobile__c = '123456789',
      RecordtypeId = ConstantsSLB.getKeyId('Account_Direct Individual'), 
      Generate_Account_Number__c = TRUE); 
      insert acc;     
      
      Contact con = TestDataFactory.createContact(1)[0];     
      con.AccountId = acc.Id;
      con.RecordTypeId =  ConstantsSLB.getKeyId('Contact_Customer Contact');
      con.Recipient_Indicator__c = true;  
      insert con;      
       
      Asia1__c asia = new Asia1__c();
      asia.ASIAONE_Legacy_Id__c = 'tsh44sa5';
      asia.Legacy_Created_Date__c = '12320514';
      asia.Legacy_Created_By__c = 'lando';
      asia.Legacy_Updated_Date__c = '114409';
      asia.Legacy_Updated_By__c = 'dola4nd';
      asia.Display_Name__c = 'mytest';
      asia.User_ID_LDAP_ID__c = 'alfred2015';
      asia.Password__c = 'newPass';     
      asia.Email__c = 'test@force.com';   
      insert asia;
      
      Asia1_Subscription__c asiasub = new Asia1_Subscription__c();
      asiasub.Asia1__c = asia.id;
      asiasub.Status__c = 'Active';
      insert asiasub;  
                 
      Case cas = TestDataFactory.createCase(1, 'Enquiry')[0];
      cas.AccountId = acc.Id;
      cas.ContactId = con.Id; 
      cas.Sub_Category__c = 'Change/Reset Password';     
      insert cas;        
    
      String username = 'alfred2015';
      String password = 'newPass';
      String displayName = 'mytest'; 
                  
      DigitalComplaintController dg = new DigitalComplaintController();
      Test.startTest();
     
      boolean isDisabled = dg.disableServiceFlag(cas, username, password, displayName, 'SVC');  
      System.assertEquals (isDisabled, true);
      dg.getErrors();     
     
      Test.stopTest();        
    }
/**
* Test method for data error 
* @name testGetError
*/            
     static testMethod void testGetError()
     {
         DigitalComplaintController dg = new DigitalComplaintController();     
         System.assertEquals(dg.getErrors(), NULL);
     }
     static testMethod void testChangeResetPassword()
    {  
      Account acc = new Account(Name = 'Test Account', Email__c = 'test@sample.com', Mobile__c = '123456789',
      RecordtypeId = ConstantsSLB.getKeyId('Account_Direct Individual'), 
      Generate_Account_Number__c = TRUE); 
      insert acc;     
      
      Contact con = TestDataFactory.createContact(1)[0];     
      con.AccountId = acc.Id;
      con.RecordTypeId =  ConstantsSLB.getKeyId('Contact_Customer Contact');
      con.Recipient_Indicator__c = true;  
      insert con;      
       
      Asia1__c asia = new Asia1__c();
      asia.ASIAONE_Legacy_Id__c = 'tsh44sa5';
      asia.Legacy_Created_Date__c = '12320514';
      asia.Legacy_Created_By__c = 'lando';
      asia.Legacy_Updated_Date__c = '114409';
      asia.Legacy_Updated_By__c = 'dola4nd';
      asia.Display_Name__c = 'mytest';
      asia.User_ID_LDAP_ID__c = 'alfred2015';
      asia.Password__c = 'newPass';     
      asia.Email__c = 'test@force.com';   
      insert asia;
      
      Asia1_Subscription__c asiasub = new Asia1_Subscription__c();
      asiasub.Asia1__c = asia.id;
      asiasub.Status__c = 'Active';
      insert asiasub;  
                 
      Case cas = TestDataFactory.createCase(1, 'Enquiry')[0];
      cas.AccountId = acc.Id;
      cas.ContactId = con.Id; 
     cas.Sub_Category__c = 'Change/Reset Password';     
      insert cas;        
    
      String username = 'alfred2015';
      String password = 'newPass';
      String displayName = 'mytest'; 
                  
      DigitalComplaintController dg = new DigitalComplaintController();
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
      dg.responseMap = new Map<String, String>();       
      boolean resetPassword = dg.resetPassword(cas, username, 'testId', password, 'SVC', displayName);  
      System.Assert(resetPassword, true);

      dg.validateNewUsername(username, displayName);
      dg.enableServiceFlag (cas, username, 'SVC');              
 
      dg.disableServiceFlag(cas, username, password, displayName, 'SVC');  
      Map<String, String> mapCont = new Map<String, String>();
      mapCont.put ('Id', asia.Id);
      mapCont.put(GlobalVariableClass.USERNAME, username); 
      mapCont.put(GlobalVariableClass.DISPLAY_NAME, displayName); 
      mapCont.put(GlobalVariableClass.PASSWORD, password);
      mapCont.put(GlobalVariableClass.EMAIL, 'test@force.com');                     
      mapCont.put(GlobalVariableClass.SVC, 'svc');   
      dg.createAccount(cas, mapCont);   
  
        
      dg.createDigitalComplaintItems(cas, username, password, 'SVC', displayName, 'Active');
      dg.getErrors();
 
      Test.stopTest();        
    }
/**
* Test method for account creation 
* @name testGetError
*/       
    static testMethod void testCreateAccount()
    {  
      Account acc = new Account(Name = 'Test Account', Email__c = 'test@sample.com', Mobile__c = '123456789',
      RecordtypeId = ConstantsSLB.getKeyId('Account_Direct Individual'), 
      Generate_Account_Number__c = TRUE); 
      insert acc;     
      
      Contact con = TestDataFactory.createContact(1)[0];     
      con.AccountId = acc.Id;
      con.RecordTypeId =  ConstantsSLB.getKeyId('Contact_Customer Contact');
      con.Recipient_Indicator__c = true;  
      insert con;      
       
      Asia1__c asia = new Asia1__c();
      asia.ASIAONE_Legacy_Id__c = 'tsh44sa5';
      asia.Legacy_Created_Date__c = '12320514';
      asia.Legacy_Created_By__c = 'lando';
      asia.Legacy_Updated_Date__c = '114409';
      asia.Legacy_Updated_By__c = 'dola4nd';
      asia.Display_Name__c = 'mytest';
      asia.User_ID_LDAP_ID__c = 'alfred2015';
      asia.Password__c = 'newPass';     
      asia.Email__c = 'test@force.com';   
      insert asia;
      
      Asia1_Subscription__c asiasub = new Asia1_Subscription__c();
      asiasub.Asia1__c = asia.id;
      asiasub.Status__c = 'Active';
      insert asiasub;  
                 
      Case cas = TestDataFactory.createCase(1, 'Enquiry')[0];
      cas.AccountId = acc.Id;
      cas.ContactId = con.Id;      
    //  cas.Sub_Category__c = 'User Id Not Created/Activated';
      insert cas;
              
      String username = 'alfred20156';
      String password = 'newPa';
      String displayName = 'mest'; 
                          
      DigitalComplaintController dg = new DigitalComplaintController();
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
      dg.responseMap = new Map<String, String>();       
     
      Map<String, String> mapCont = new Map<String, String>();
      mapCont.put ('Id', asia.Id);
      mapCont.put(GlobalVariableClass.USERNAME, username); 
      mapCont.put(GlobalVariableClass.DISPLAY_NAME, displayName); 
      mapCont.put(GlobalVariableClass.PASSWORD, password);
      mapCont.put(GlobalVariableClass.EMAIL, 'test@force.com');                     
      mapCont.put(GlobalVariableClass.SVC, 'svc');   
      boolean isCreated = dg.createAccount(cas, mapCont);   
      System.assertEquals (isCreated, false);

      Test.stopTest();        
      } 
/**
* Test method for data creation 
* @name testDigitalComplaint3
*/           
   static testMethod void testDigitalComplaint3()
    {  
      Account acc = new Account(Name = 'Test Account', Email__c = 'test@sample.com', Mobile__c = '123456789',
      RecordtypeId = ConstantsSLB.getKeyId('Account_Direct Individual'), 
      Generate_Account_Number__c = TRUE); 
      insert acc;     
      
      Contact con = TestDataFactory.createContact(1)[0];     
      con.AccountId = acc.Id;
      con.RecordTypeId =  ConstantsSLB.getKeyId('Contact_Customer Contact');
      con.Recipient_Indicator__c = true;  
      insert con;      
       
      Asia1__c asia = new Asia1__c();
      asia.ASIAONE_Legacy_Id__c = 'tsh44sa5';
      asia.Legacy_Created_Date__c = '12320514';
      asia.Legacy_Created_By__c = 'lando';
      asia.Legacy_Updated_Date__c = '114409';
      asia.Legacy_Updated_By__c = 'dola4nd';
      asia.Display_Name__c = 'mytest';
      asia.User_ID_LDAP_ID__c = 'alfred2015';
      asia.Password__c = 'newPass';     
      asia.Email__c = 'test@force.com';   
      insert asia;
      
      Asia1_Subscription__c asiasub = new Asia1_Subscription__c();
      asiasub.Asia1__c = asia.id;
      asiasub.Status__c = 'Active';
      insert asiasub;  
                 
      Case cas = TestDataFactory.createCase(1, 'Enquiry')[0];
      cas.AccountId = acc.Id;
      cas.ContactId = con.Id; 
      cas.Sub_Category__c = 'Deactivate User Id';     
      insert cas;        
    
      String username = 'alfred2015';
      String password = 'newPass';
      String displayName = 'mytest'; 
                  
      DigitalComplaintController dg = new DigitalComplaintController();
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());
      dg.responseMap = new Map<String, String>();       
      boolean resetPassword = dg.resetPassword(cas, username, 'testId', password, 'SVC', displayName);  
      System.Assert(resetPassword, true);

      dg.validateNewUsername(username, displayName);
      dg.enableServiceFlag (cas, username, 'SVC');              
 
      dg.disableServiceFlag(cas, username, password, displayName, 'SVC');  
      Map<String, String> mapCont = new Map<String, String>();
      mapCont.put ('Id', asia.Id);
      mapCont.put(GlobalVariableClass.USERNAME, username); 
      mapCont.put(GlobalVariableClass.DISPLAY_NAME, displayName); 
      mapCont.put(GlobalVariableClass.PASSWORD, password);
      mapCont.put(GlobalVariableClass.EMAIL, 'test@force.com');                     
      mapCont.put(GlobalVariableClass.SVC, 'svc');   
      dg.createAccount(cas, mapCont);   
  
        
      dg.createDigitalComplaintItems(cas, username, password, 'SVC', displayName, 'Active');
      dg.getErrors();
 
      Test.stopTest();        
    }
/**
* Test method for data creation error
* @name testDigitalComplaintFail3
*/     
    static testMethod void testDigitalComplaintFail3()
    {  
      Account acc = new Account(Name = 'Test Account', Email__c = 'test@sample.com', Mobile__c = '123456789',
      RecordtypeId = ConstantsSLB.getKeyId('Account_Direct Individual'), 
      Generate_Account_Number__c = TRUE); 
      insert acc;     
      
      Contact con = TestDataFactory.createContact(1)[0];     
      con.AccountId = acc.Id;
      con.RecordTypeId =  ConstantsSLB.getKeyId('Contact_Customer Contact');
      con.Recipient_Indicator__c = true;  
      insert con;      
       
      Asia1__c asia = new Asia1__c();
      asia.ASIAONE_Legacy_Id__c = 'tsh44sa5';
      asia.Legacy_Created_Date__c = '12320514';
      asia.Legacy_Created_By__c = 'lando';
      asia.Legacy_Updated_Date__c = '114409';
      asia.Legacy_Updated_By__c = 'dola4nd';
      asia.Display_Name__c = 'mytest';
      asia.User_ID_LDAP_ID__c = 'alfred2015';
      asia.Password__c = 'newPass';     
      asia.Email__c = 'test@force.com';   
      insert asia;
      
      Asia1_Subscription__c asiasub = new Asia1_Subscription__c();
      asiasub.Asia1__c = asia.id;
      asiasub.Status__c = 'Active';
      insert asiasub;  
                 
      Case cas = TestDataFactory.createCase(1, 'Enquiry')[0];
      cas.AccountId = acc.Id;
      cas.ContactId = con.Id;      
      cas.Sub_Category__c = 'Deactivate User Id';      
      insert cas;
              
      String username = 'alfred';
      String password = 'newPa';
      String displayName = 'mest'; 
                  
      DigitalComplaintController dg = new DigitalComplaintController();
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockFail2Test());
      Map<String,Object> responseMapTest = new Map<String,Object>();
      
      dg.responseMap = new Map<String, String>();      
      dg.resetPassword(cas, 'hello', 'testId123113', 'fail2', 'SVC', displayName);  
      boolean resetPassword = dg.resetPassword(cas, username, 'testId', password, 'SVC', displayName);  
          
      dg.validateNewUsername('erroruser', 'ErrorDisplay');
      
      dg.responseMap.put('Activate', 'Success');           
      dg.enableServiceFlag (cas, username, 'SVC');              
      dg.disableServiceFlag(cas, username, password, displayName, 'SVC');  
      Map<String, String> mapCont = new Map<String, String>();
      mapCont.put ('Id', asia.Id);
      mapCont.put(GlobalVariableClass.USERNAME, username); 
      mapCont.put(GlobalVariableClass.DISPLAY_NAME, displayName); 
      mapCont.put(GlobalVariableClass.PASSWORD, password);
      mapCont.put(GlobalVariableClass.EMAIL, 'test@force.com');                
      mapCont.put(GlobalVariableClass.SVC, 'svc');  
  
      dg.createAccount(cas, mapCont);   
      
      dg.createDigitalComplaintItems(cas, username, password, 'SVC', displayName, 'Active');     
      Test.stopTest();        
      }  

    }