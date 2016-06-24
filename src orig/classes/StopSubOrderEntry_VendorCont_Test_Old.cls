@isTest(SeeAllData=true)
Public class StopSubOrderEntry_VendorCont_Test_Old{
    
    Public Static testMethod void StopSubOrderEntry_VendorController_Test() {

        List<Account> acct = TestDataFactory.createAccount(1, 'Vendor');
        acct[0].Name = 'Account1';
        insert acct;
        
        List<Contact> con = TestDataFactory.createContact(1);
        //Contact con = new Contact(
            con[0].AccountId = acct[0].id;
            //LastName = 'LastName1');
        insert con;
        
        List<Order__c> ord = TestDataFactory.createOrder(1);
        ord[0].Account__c = acct[0].id;
            //Credit_Balance__c = 300.00,
            //Delivery_Charge__c = 100.00,
            //Informed_Customer__c = true,
            //Recipient_Contact__c = con.id);
        Insert ord;    
        
        
        
        //List<Contact> con = TestDataFactory.createContact(1);
        //Insert con;
        try{
        Test.StartTest(); 
             PageReference pageVendorView = new PageReference('/apex/StopSubOrderEntry_Vendor_View?accountId='+ord[0].Account__c+'&orderId=' + ord[0].Id + '&recordtypeId=' + ord[0].recordtype);
                Test.setCurrentPage(pageVendorView);
                    
        StopSuborderEntry_VendorController stopSuborder = new StopSuborderEntry_VendorController();
        //stopSubOrder.getAccount();
        //stopSubOrder.getContact();
        //stopSubOrder.getOrder();
                
        Test.StopTest();
        }catch(exception e){}
    }
}