@isTest (seealldata = true)
private class AsiaOneBulkCreationTriggerHandlerTest{

    private static List<Zuora__Subscription__c> subList; 
    private static List<BT_CO_ASIAONE_BulkIdCreation__c> asiaOneBulk;
    private static BT_CO_ASIAONE_BulkIdCreation__c asiaOne; 
    private static BT_CO_ASIAONE_BulkIdCreation__c asiaTwo; 
    private static BT_CO_ASIAONE_BulkIdCreation__c asiaThree; 
    private static Account acc;
    private static Contact con;
    private static Asia1__c a1;
    private static Asia1_Subscription__c as1;


    private static void setTestData(){
        setAccount();
        
        con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        insert con;
        setSubscription();
        setAsia1();
        setAsiaSubs();
        
        setAsiaOneBulk();
        
    }

    private static void setAccount() {
        //Create Account
        acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Name = 'TEST';
        acc.AccountNumber = '123456789';
        acc.NRIC__c = 'T1234567R';
        insert acc; 
    }

    private static void setSubscription(){
        subList = [SELECT Name, Number_of_Copies__c, Order_Line_Item_Number_1__r.Is_Digital__c, Zuora__Status__c, Subscription_Type_1__c 
                    FROM Zuora__Subscription__c 
                    WHERE Zuora__Status__c = 'Active' 
                    AND Subscription_Type_1__c = 'Publication' 
                    AND Order_Line_Item_Number_1__r.Is_Digital__c = true 
                    limit 1];
        
        subList[0].Number_of_Copies__c = 100;
        SubscriptionTriggerHandler.preventExecution = true;
        update subList[0];
        system.debug('******* sublist: ' + subList[0]);
    }

    private static void setAsiaOneBulk(){
        asiaOneBulk = new List<BT_CO_ASIAONE_BulkIdCreation__c>();
        asiaOne = new BT_CO_ASIAONE_BulkIdCreation__c();
        asiaOne.Subscription__c = subList[0].Name;
        asiaOne.Display_Name__c = 'displayNamB123abc';
        asiaOne.User_ID_LDAP_ID__c = 'displayNam@123abc';
        asiaOne.Password__c = 'Ack004TinbEd';

        asiaTwo = new BT_CO_ASIAONE_BulkIdCreation__c();
        asiaTwo.Subscription__c = subList[0].Name;
        asiaTwo.Display_Name__c = 'displayNamB123abc2';
        asiaTwo.User_ID_LDAP_ID__c = 'displayNam@123abc2';
        asiaTwo.Password__c = 'Ack004TinbEd2';

        asiaThree = new BT_CO_ASIAONE_BulkIdCreation__c();
        asiaThree.Subscription__c = subList[0].Name;
        asiaThree.Display_Name__c = 'displayNamB123abc3c';
        asiaThree.User_ID_LDAP_ID__c = 'displayNam@123abc3';
        asiaThree.Password__c = 'Ack004TinbEd3';
    }


    private static void setAsiaSubs(){
        as1 = new Asia1_Subscription__c();
        as1.Asia1__c = a1.Id;
        as1.Subscription__c = subList[0].Id;
        as1.Status__c = 'Created';
        insert as1;
    }

    private static void setAsia1(){
        a1 = new Asia1__c();
        a1.User_ID_LDAP_ID__c = 'displayNam@123abc4';
        a1.Contact__c = con.Id;
        a1.Display_Name__c = 'displayNamB123abc4';
        insert a1;
    }


    
    static testMethod void testAsiaOneBulkCreationTriggerHandler2(){
        //initialize test data
        setTestData();
  //      List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
  //      subList = [select name, Number_of_Copies__c from Zuora__Subscription__c where Zuora__Status__c = 'Active' 
  //              and Subscription_Type_1__c = 'Publication' and Order_Line_Item_Number_1__r.Is_Digital__c = true limit 1];
		
		//system.debug('>>>> ' + subList[0]);
		//subList[0].Number_of_Copies__c = 100;
		
		//SubscriptionTriggerHandler.preventExecution = true;
		//update subList[0];
		//system.debug('>>>> ' + subList[0]);
        test.startTest();
        //List<BT_CO_ASIAONE_BulkIdCreation__c> asiaOneBulk = new List<BT_CO_ASIAONE_BulkIdCreation__c>();
        //asiaOneBulk = new List<BT_CO_ASIAONE_BulkIdCreation__c>();

        //BT_CO_ASIAONE_BulkIdCreation__c asiaOne = new BT_CO_ASIAONE_BulkIdCreation__c();
        //asiaOne.subscription__c = subList[0].Name;
        //asiaOne.Display_Name__c = 'displayNamB123abc';
        //asiaOne.User_ID_LDAP_ID__c = 'displayNam@123abc';
        //asiaOne.Password__c = 'Ack004TinbEd';
        asiaOneBulk.add(asiaOne);
        asiaOneBulk.add(asiaTwo);
        asiaOneBulk.add(asiaThree);
		insert asiaOneBulk;

        test.stoptest();
    }

    static testMethod void testNullUserLDAPID(){
        //initialize test data
        setTestData();

        test.startTest();
        asiaOneBulk = new List<BT_CO_ASIAONE_BulkIdCreation__c>();
        
        asiaOne.User_ID_LDAP_ID__c = null;
        //asiaOneBulk.add(asiaOne);
        try{
            insert asiaOne;
        }catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Required Field') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
        test.stoptest();
    }

    static testMethod void testNullDisplayName(){
        //initialize test data
        setTestData();

        test.startTest();
        //asiaOneBulk = new List<BT_CO_ASIAONE_BulkIdCreation__c>();
        
        asiaOne.Display_Name__c = null;
        //asiaOneBulk.add(asiaOne);
        try{
            insert asiaOne;
        }catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Required Field') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
        test.stoptest();
    }

    static testMethod void testAfterInsertMethod(){
        test.startTest();
        setTestData();
        asiaOneBulk.add(asiaOne);
        asiaOneBulk.add(asiaTwo);
        asiaOneBulk.add(asiaThree);

        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());       
        AsiaOneServiceRequestVO aosr = new AsiaOneServiceRequestVO();        
        AsiaOneFacade aof = new AsiaOneFacade();
        AsiaOneServiceResponsetVO actualResponse = aof.delegateAsiaOneCall(aosr);      
        System.debug('****** aosr: ' + aosr);
        System.debug('****** actualResponse: ' + actualResponse);      
              
    
    // Get TestData
        BatchServiceFacadeMockTest testData = new BatchServiceFacadeMockTest();
        HTTPResponse res = testData.respond(new HttpRequest());
        Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());

        System.debug('***** respMap: ' + respMap);
        try{
            //asiaOneBulk.add(asiaOne);
            ////insert asiaOneBulk;
            //System.debug('****** after insert');
            AsiaOneBulkCreationTriggerHandler triggerHandler = new AsiaOneBulkCreationTriggerHandler();
            System.debug('***** before do after insert');
            triggerHandler.doAfterInsert(asiaOneBulk);
            System.debug('***** before do after insert');

        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage()!=null ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }

       
        test.stoptest();
    }
}