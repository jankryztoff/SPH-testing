@isTest (Seealldata = true)
public class Asia1CredsCreationForChangeofSubTest {

    static testmethod void isDigitalTrue(){
        Map<String, String> accountMap = new Map<String, String>();
        accountMap.put('username', 'SPH');
        accountMap.put('Password','Sign-Up');
        accountMap.put('Error', 'Error');
        accountMap.put('passwordChallenge','passwordChallenge');
        accountMap.put('firstName','firstName');
        accountMap.put('lastName','lastName');
        accountMap.put('displayName','displayName');
        accountMap.put('EMAIL','EMAIL');
        accountMap.put('phoneNumber','phoneNumber');
        
        
       // accountMap.put('Id', 'ID');
       // accountMap.put(GlobalVariableClass.USERNAME, 'UserName');
       // accountMap.put(GlobalVariableClass.DISPLAY_NAME, 'Display Name');
       // accountMap.put(GlobalVariableClass.PASSWORD, 'Password');
       // accountMap.put(GlobalVariableClass.EMAIL, 'test@test.com');
       // accountMap.put(GlobalVariableClass.SVC, 'SVC');
        
             
       
        
        
        Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber'));
            List<Package__c> pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15';             
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert new List<sObject>{postal,acc, pkg[0]};
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;

            List<Contact> con = TestDataFactory.createContact(1);
            con[0].Address__c = addressRec.Id;
            con[0].FirstName = 'test';
            con[0].LastName = 'testtest';
            //START: CCB002 Added by April Banaag - to apply changes to contact record type
            con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con[0].Recipient_Indicator__c = true;
            //END: CCB002 Added by April Banaag - to apply changes to contact record type
            con[0].Phone = '1234567';
            con[0].AccountId = acc.Id;
            insert con;            

            //create order
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Recipient_Contact__c = con[0].Id;
            System.debug('DEBUG con.Id' + con[0].Id);
            order.Informed_Customer__c = True;
            order.Subscriber_Charge__c = 15;
            insert order;   
        
            List<Package__c> pack = TestDataFactory.createPackage(1); //new Package__c();
            //pack = TestDataFactory.createPackage(1)[0];
            pack[0].Package_Type__c = 'Base';
            pack[0].Name = 'Test Package';
            pack[0].Package_Code__c = 'testcode';
            insert pack;        
           
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.today() +8;
            orderline.Main_Package_ID__c = pack[0].Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = FALSE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Start_Date__c = date.today()+7;
            insert orderline;
            
            
         Asia1__c asiaOneRecord = new Asia1__c(Display_Name__c='1Test_Asia.One1', Email__c='testasiaone@email.com', Status__c= 'Pending Creation', User_ID_LDAP_ID__c = '1Test1_Test.Test1', Password__c = 'testpassword',Contact__c = con[0].id);        
         insert asiaOneRecord;
        
        Service_Access_Flag__c saf = new Service_Access_Flag__c();
        saf.Name = 'test name';
        insert saf;
        
        Asia1_Subscription__c tmp = new Asia1_Subscription__c();
        tmp.Asia1__c = asiaOneRecord.id;
        tmp.Order_Line_Item__c = orderline.id;
        tmp.Service_Access_Flag__c = saf.id;
        insert tmp; 
        
        Test.startTest();
        Asia1CredsCreationForChangeofSub acccs = new Asia1CredsCreationForChangeofSub();
        acccs.enableServiceFlag(true, 'username','name');
        acccs.disableServiceFlag(true, 'sunny', 'sad');
        acccs.registerAsia1Accounts(order.Id);
        
         set<id> asia1IdSet = new set<id>();
         asia1IdSet.add(asiaOneRecord.id);
        
   
        
        Boolean result = acccs.createAccount(true, accountMap);
       // System.assert(result);
        Test.stopTest();
    }//end of unitTest1
    
}