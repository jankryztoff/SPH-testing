/*
 * Class Name: BulkAsiaOneSignUpLevel2QueueableTest
 * @author: Christian Coquilla
 * Date: 4/9/2016
 * Project/Requirement:  <SPH>
 * @description Test Class for BulkAsiaOneSignUpLevel2Queueable
 */

@isTest(seeAllData = true)
public class BulkAsiaOneSignUpLevel2QueueableTest{

    //initializing queueable class
    static testMethod void test01(){
        
          Asia1__c asia = TestDataFactory.createAsiaOne(1)[0];
        asia.ASIAONE_Legacy_Id__c = 'tsh4sa5';
        asia.Legacy_Created_Date__c = '1232014';
        asia.Legacy_Created_By__c = 'lando';
        asia.Legacy_Updated_Date__c = '11409';
        asia.Legacy_Updated_By__c = 'doland';
        asia.Display_Name__c = 'asiasd';
        asia.User_ID_LDAP_ID__c = 'ldap@sing.com';
        asia.Password__c = 'ddfdf5654';
        insert asia;
        
        Asia1_Subscription__c asiasub = TestDataFactory.createAsiaOneSubscription(1)[0];
        asiasub.Asia1__c = asia.id;
        asiasub.Status__c = 'Disabled';
        insert asiasub;   
    
       /*  Asia1__c asia = TestDataFactory.createAsiaOne(1)[0];
         //Asia1__c asia = new Asia1__c();
         asia.User_ID_LDAP_ID__c = 'ldap@test.com';
         insert asia;
         
         set<id> asia1IdSetParam = new set<id>();
         //Asia1__c asia1Record = new Asia1__c();
        asia1IdSetParam.add(asia.Id);
        
        Asia1_Subscription__c asiaSubs = TestDataFactory.createAsiaOneSubscription(1)[0];
        asiaSubs.Asia1__c = asia.Id;
        //asiaSubs.Subscription__c = subRecs.Id;
        insert asiaSubs; */
        
        set<id> asia1IdSetParam = new set<id>();
        asia1IdSetParam.add(asia.Id);
        asia1IdSetParam.add(asiasub.id);
        try{
        Test.startTest();
        
        
          
          System.assertNotEquals(null, asia1IdSetParam);
          System.assertNotEquals(null, asiaSub.id);
         
          string asia1APIFunction = 'Sign-Up';  
          string asia1APIFunction2 = null;
          Map<string, string> reqValueObject = new Map<string, string>();      
          //reqValueObject.put(asia1APIFunction,asia1APIFunction2);
          AsiaOneServiceResponsetVO call = new AsiaOneServiceResponsetVO(reqValueObject, asia1APIFunction2);
        
        Map<string, object> getReqObj = call.getReqValueObject();
            
            System.enqueueJob(new BulkAsiaOneSignUpLevel2Queueable(asia1IdSetParam));
           
        Test.stopTest();
        }catch(exception e){}
    }
    
    static testMethod void NewTest(){
    
     
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        insert acc;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.Id;
        con.Mobile_Number__c = '0930304145';
        insert con;
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
    
        Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
        subRecs.Zuora__CustomerAccount__c = billAcc.Id;
        subRecs.Recipient_Contact__c = con.Id;
        insert subRecs;
        
         List<Asia1__c> asiaList = TestDataFactory.createAsiaOne(1);
         insert asiaList;
         
         Asia1__c asia1 = new Asia1__c();
         asia1.User_ID_LDAP_ID__c = 'ldap@test.com';
         insert asia1;
         
         asiaList.add(asia1);
                  
         
        set<id> NewAsia1Set = new set<id>();
        
        NewAsia1Set.add(asiaList[0].Id);

         
        //List<Asia1_Subscription__c> asiaSubsList = TestDataFactory.createAsiaOneSubscription(1);
        List<Asia1_Subscription__c> asiaSubsList = new List<Asia1_Subscription__c>();
        Asia1_Subscription__c asiaSubs = new Asia1_Subscription__c();
        asiaSubs.Asia1__c = asia1.id;
        asiaSubs.Subscription__c = subRecs.id;
        insert asiaSubs;
        asiaSubsList.add(asiaSubs);
       

     Test.startTest();

       
        
        BulkAsiaOneSignUpLevel2Queueable BulkAsia2 = new BulkAsiaOneSignUpLevel2Queueable(NewAsia1Set);
        QueueableContext QC;
        BulkAsia2.execute(QC);
        
     Test.stopTest();
    }
}