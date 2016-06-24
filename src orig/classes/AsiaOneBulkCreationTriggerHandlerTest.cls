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
    private static Asia1__c a2;
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
        subList = [SELECT Name, Number_of_Copies__c, Order_Line_Item_Number_1__r.Is_Digital__c, 
                            Zuora__Status__c, Subscription_Type_1__c, Zuora__Account__c
                    FROM Zuora__Subscription__c 
                    WHERE Zuora__Status__c = 'Active' 
                    AND Subscription_Type_1__c = 'Publication' 
                    AND Order_Line_Item_Number_1__r.Is_Digital__c = true 
                    limit 2];
        
        subList[0].Number_of_Copies__c = 100;
        subList[1].Number_of_Copies__c = 100;

        SubscriptionTriggerHandler.preventExecution = true;
        update subList[0];
        update subList[1];
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
        asiaThree.Subscription__c = subList[1].Name;
        asiaThree.Display_Name__c = 'displayNamB123abc3';
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
        a1.User_ID_LDAP_ID__c = 'displayNam@123abc2';
        a1.Contact__c = con.Id;
        a1.Display_Name__c = 'displayNamB123abc4';
        insert a1;

        a2 = new Asia1__c();
        a2.User_ID_LDAP_ID__c = 'displayNam@123abc5';
        a2.Contact__c = con.Id;
        a2.Display_Name__c = 'displayNam@123abc5';
        insert a2;

    }
    
    static testMethod void testAsiaOneBulkCreationTriggerHandler2(){

  //      List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
  //      subList = [select name, Number_of_Copies__c from Zuora__Subscription__c where Zuora__Status__c = 'Active' 
  //              and Subscription_Type_1__c = 'Publication' and Order_Line_Item_Number_1__r.Is_Digital__c = true limit 1];
    
    //system.debug('>>>> ' + subList[0]);
    //subList[0].Number_of_Copies__c = 100;
    
    //SubscriptionTriggerHandler.preventExecution = true;
    //update subList[0];
    //system.debug('>>>> ' + subList[0]);
        Test.startTest();
        //initialize test data
        setTestData();
        //List<BT_CO_ASIAONE_BulkIdCreation__c> asiaOneBulk = new List<BT_CO_ASIAONE_BulkIdCreation__c>();
        //asiaOneBulk = new List<BT_CO_ASIAONE_BulkIdCreation__c>();

        //BT_CO_ASIAONE_BulkIdCreation__c asiaOne = new BT_CO_ASIAONE_BulkIdCreation__c();
        //asiaOne.subscription__c = subList[0].Name;
        //asiaOne.Display_Name__c = 'displayNamB123abc';
        //asiaOne.User_ID_LDAP_ID__c = 'displayNam@123abc';
        //asiaOne.Password__c = 'Ack004TinbEd';
        asiaOneBulk.add(asiaOne);
    insert asiaOneBulk;
        Test.stoptest();
        List<BT_CO_ASIAONE_BulkIdCreation__c> asiaInserted = [Select Id from BT_CO_ASIAONE_BulkIdCreation__c where Id = :asiaOne.Id];
        System.assertEquals(1, asiaInserted.size());
    }

    static testMethod void testNullUserLDAPID(){
        Test.startTest();       

        //initialize test data
        setTestData();

        asiaOneBulk = new List<BT_CO_ASIAONE_BulkIdCreation__c>();
        asiaOne.User_ID_LDAP_ID__c = null;
        //asiaOneBulk.add(asiaOne);
        try{
            insert asiaOne;
        }catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Required Field') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
        Test.stoptest();
    }

    static testMethod void testNullDisplayName(){
        Test.startTest();
        
        //initialize test data
        setTestData();
        
        asiaOne.Display_Name__c = null;
        try{
            insert asiaOne;
        }catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Required Field') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
        Test.stoptest();
    }

    static testMethod void testWithDuplicateLdapUser(){
        Test.startTest();
        //initialize test data
        setTestData();

        //setting the duplicate record
        BT_CO_ASIAONE_BulkIdCreation__c asiaDuplicate = new BT_CO_ASIAONE_BulkIdCreation__c();
        asiaDuplicate.Subscription__c = subList[0].Name;
        asiaDuplicate.Display_Name__c = 'displayNamB123abc';
        asiaDuplicate.User_ID_LDAP_ID__c = 'displayNam@123abc6';
        asiaDuplicate.Password__c = 'Ack004TinbEd';

        insert asiaDuplicate;

        try{
            asiaOneBulk.add(asiaOne);
            asiaOneBulk.add(asiaTwo);
            asiaOneBulk.add(asiaThree);
            insert asiaOneBulk;

        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage()!=null ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }

        Test.stoptest();
    }

    static testMethod void testWithDuplicateDisplayName(){
        Test.startTest();
        //initialize test data
        setTestData();

        //setting the duplicate record
        BT_CO_ASIAONE_BulkIdCreation__c asiaDuplicate = new BT_CO_ASIAONE_BulkIdCreation__c();
        asiaDuplicate.Subscription__c = subList[0].Name;
        asiaDuplicate.Display_Name__c = 'displayNamB123abc2';
        asiaDuplicate.User_ID_LDAP_ID__c = 'displayNam@123abc7';
        asiaDuplicate.Password__c = 'Ack004TinbEd2';
        insert asiaDuplicate;
 
        //asiaTwo.Display_Name__c = 'displayNamB123abc2';
        try{
            asiaOneBulk.add(asiaOne);
            asiaOneBulk.add(asiaTwo);
            asiaOneBulk.add(asiaThree);
            insert asiaOneBulk;

        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage()!=null ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }

        Test.stoptest();
    }

    static testMethod void testAfterInsertMethod(){

        List<Zuora__Subscription__c> zsubList = [SELECT Name, Number_of_Copies__c, Order_Line_Item_Number_1__r.Is_Digital__c, 
                            Zuora__Status__c, Subscription_Type_1__c, Zuora__Account__c
                    FROM Zuora__Subscription__c 
                    WHERE Zuora__Status__c = 'Active' 
                    AND Subscription_Type_1__c = 'Publication' 
                    AND Order_Line_Item_Number_1__r.Is_Digital__c = true 
                    AND Number_of_Copies__c > 10
                    limit 1];

        BT_CO_ASIAONE_BulkIdCreation__c asiaBulkOne = new BT_CO_ASIAONE_BulkIdCreation__c();
        asiaBulkOne.Subscription__c = zsubList[0].Name;
        asiaBulkOne.Display_Name__c = 'displayNamB123abc2';
        asiaBulkOne.User_ID_LDAP_ID__c = 'displayNam@123abc3';
        asiaBulkOne.Password__c = 'Ack004TinbEd2';

        BT_CO_ASIAONE_BulkIdCreation__c asiaBulkTwo = new BT_CO_ASIAONE_BulkIdCreation__c();
        asiaBulkTwo.Subscription__c = zsubList[0].Name;
        asiaBulkTwo.Display_Name__c = 'displayNamB123abc2';
        asiaBulkTwo.User_ID_LDAP_ID__c = 'displayNam@123abc2';
        asiaBulkTwo.Password__c = 'Ack004TinbEd2';

        BT_CO_ASIAONE_BulkIdCreation__c asiaBulkThree = new BT_CO_ASIAONE_BulkIdCreation__c();
        asiaBulkThree.Subscription__c = zsubList[0].Name;
        asiaBulkThree.Display_Name__c = 'displayNamB123abc2';
        asiaBulkThree.User_ID_LDAP_ID__c = 'displayNam@123abc3';
        asiaBulkThree.Password__c = 'Ack004TinbEd2';
        insert asiaBulkThree;
        
        List<BT_CO_ASIAONE_BulkIdCreation__c> asiaList = new List<BT_CO_ASIAONE_BulkIdCreation__c>();
        asiaList.add(asiaBulkOne);
        asiaList.add(asiaBulkTwo);

        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());       

        Test.startTest();
            
        AsiaOneBulkCreationTriggerHandler triggerHandler = new AsiaOneBulkCreationTriggerHandler();
        triggerHandler.doAfterInsert(asiaList);

        test.stoptest();
    }

    static testMethod void testApiSignUp(){

        List<Asia1_Subscription__c> asia1SubscriptionList = [select Id,Asia1__r.Id from Asia1_Subscription__c where Asia1__c != null Limit 1];
        List<Asia1_Subscription__c> asia1SubscriptionList1 = [select Id,Asia1__r.Id from Asia1_Subscription__c where Asia1__c != null and Subscription__r.Recipient_Contact__r.HomePhone__c != null Limit 1];
        List<Asia1_Subscription__c> asia1SubscriptionList2 = [select Id,Asia1__r.Id from Asia1_Subscription__c where Asia1__c != null AND Subscription__r.Recipient_Contact__r.Office_Number__c != null Limit 1];

        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest());       

        Test.startTest();
        
        if(!asia1SubscriptionList.isEmpty()){
            AsiaOneBulkCreationTriggerHandler.apiSignUp(asia1SubscriptionList[0].Asia1__r.Id);
        }
        if(!asia1SubscriptionList1.isEmpty()){
            AsiaOneBulkCreationTriggerHandler.apiSignUp(asia1SubscriptionList1[0].Asia1__r.Id);
        }
        if(!asia1SubscriptionList2.isEmpty()){
            AsiaOneBulkCreationTriggerHandler.apiSignUp(asia1SubscriptionList2[0].Asia1__r.Id);
        }
    

        Test.stopTest();
    }

}