/**
* Class Name: StopSubOrderEntry_ViewVendorContTest
* @author: April Veloso
07/13/2015
* @Description: This is the test class for StopSubOrderEntry_ViewVendorController.
* 
*
*/
@isTest(SeeAllData=true)
public class StopSubOrderEntry_ViewVendorContTest{
      
      static testMethod void testStopSubOrderEntry(){  
            //insert values
            List<Account> accList = TestDataFactory.createAccount(1, 'Direct Corporate');         
            insert accList;
            String accountId = ApexPages.currentPage().getParameters().put('accountId', accList[0].id); 
       
                  
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = accList[0].Id;
            con.Recipient_Indicator__c = true;
            insert con;
         
            Order__c orderList = TestDataFactory.createOrder(1)[0];
            orderList.Account__c = accList[0].id;
            orderList.status__c = 'Active';
            orderList.case_record_type__c = 'Stop Subscription';
            orderList.category__c = 'Subscription Request';
            orderList.sub_category__c = 'Stop Subscription';
            orderList.Recipient_contact__c = con.id;
            orderList.Stop_Request_Date__c = Date.newInstance(2015, 08, 01);
            orderList.Suppress_Vendor_Notification__c = true;
            orderList.Terminating_Reason__c = 'Package - Upgrade';
            orderList.Status__c = 'Draft';
            insert orderList;           
            String orderId = ApexPages.currentPage().getParameters().put('orderId', orderList.id);   
            
            Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1) [0];
            insert subVen;
            
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Earliest_Start_Date__c = Date.today().addDays(1);
            insert pub;
            
            Subscription_Vendor_Publication__c vendorPublication = TestDataFactory.createVendorPublication(1)[0];
            vendorPublication.Mon__c = 10;
            vendorPublication.Tue__c = 20;
            vendorPublication.Wed__c = 30;
            vendorPublication.Thu__c = 40;
            vendorPublication.Fri__c = 50;
            vendorPublication.Sat__c = 60; 
            vendorPublication.Sun__c = 70; 
            vendorPublication.PHd__c = 80;
            vendorPublication.PHe__c = 90;
            vendorPublication.Publication__c = pub.id;
            vendorPublication.Subscription_Vendor__c = subVen.id;
            insert vendorPublication;
           
            List<Subscription_Vendor_Publication__c> vendorPublication2 = TestDataFactory.createVendorPublication(1);
            vendorPublication2[0].Mon__c = 10;
            vendorPublication2[0].Tue__c = 20;
            vendorPublication2[0].Wed__c = 30;
            vendorPublication2[0].Thu__c = 40;
            vendorPublication2[0].Fri__c = 50;
            vendorPublication2[0].Sat__c = 60; 
            vendorPublication2[0].Sun__c = 70; 
            vendorPublication2[0].PHd__c = 80;
            vendorPublication2[0].PHe__c = 90;
            vendorPublication2[0].Publication__c = pub.id;
            vendorPublication2[0].Subscription_Vendor__c = subVen.id;          
            insert vendorPublication2;
            
            Order_Line_Item_Vendor__c orderLine = TestDataFactory.createOrderLineItemVendor(1)[0]; 
            orderLine.Order__c = orderList.id;
            orderLine.Additional_Termination_Comment_del__c = 'Additional Termination Comment';
            orderLine.Subscription_Vendor_Publication__c = vendorPublication.id;
            orderLine.Start_Date__c = date.Today()+5;
            orderLine.Earliest_Stop_Date__c = Date.newInstance(2015, 08, 30);
            orderLine.Stop_Request_Date__c = Date.newInstance(2015, 10, 30);//date.Today() +1;
            insert orderLine;
            
            List<Order_Line_Item_Vendor__c> orderLine2 = TestDataFactory.createOrderLineItemVendor(1); 
            orderLine2[0].Order__c = orderList.id;
            orderLine2[0].Additional_Termination_Comment_del__c = 'Additional Termination Comment';
            orderLine2[0].Subscription_Vendor_Publication__c = vendorPublication.id;
            orderLine2[0].Start_Date__c = date.Today()+5;
            orderLine2[0].Stop_Request_Date__c = Date.newInstance(2015, 08, 01);//date.Today() +1;
            insert orderLine2;
  
            Order_Line_Item_Vendor__c testOrderLine  = [SELECT id FROM Order_Line_Item_Vendor__c WHERE ID =:orderLine.id];
            System.assertNotEquals(null, testOrderLine);
            
            Integer counter = 1 ;
            List<SelectOption> items = new List<SelectOption>();
            Date SubStartDate = date.Today() +1;
            
            Test.startTest();
            PageReference cancel;
            PageReference submit;
            PageReference edit;
            String index = 'index';
            
      
            StopSubOrderEntry_ViewVendorController testClass = new StopSubOrderEntry_ViewVendorController();
           
            testClass.oli = orderLine;
            testClass.pubObject = vendorPublication;
            testClass.SubVen = subVen;
            testClass.counter = counter;
            testClass.items = items;
            testClass.index = index;
            testClass.SubStartDate = SubStartDate;
            testClass.publicationRecordList  = vendorPublication2;
            testClass.orderLineItemList = orderLine2;
            testClass.finalPublicationList = vendorPublication2;
            
            testClass.getAccount();
            testClass.getOrder();
            testClass.createOrderLine(vendorPublication);
            testClass.cancel();
            testClass.submit();
            testClass.edit();
            testClass.voidStatus();            
            Test.stopTest();
            
  }
      static testMethod void testStopSubOrderEntry1(){  
            //insert values
            List<Account> accList = TestDataFactory.createAccount(1, 'Direct Corporate');         
            insert accList;
            String accountId = ApexPages.currentPage().getParameters().put('accountId', accList[0].id); 
       
                  
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = accList[0].Id;
            con.Recipient_Indicator__c = true;
            insert con;
         
            Order__c orderList = TestDataFactory.createOrder(1)[0];
            orderList.Account__c = accList[0].id;
            orderList.status__c = 'Active';
            orderList.case_record_type__c = 'Stop Subscription';
            orderList.category__c = 'Subscription Request';
            orderList.sub_category__c = 'Stop Subscription';
            orderList.Recipient_contact__c = con.id;
            orderList.Stop_Request_Date__c = Date.newInstance(2015, 08, 01);
            orderList.Suppress_Vendor_Notification__c = true;
            orderList.Terminating_Reason__c = 'Package - Upgrade';
            orderList.Status__c = 'Draft';
            insert orderList;           
            String orderId = ApexPages.currentPage().getParameters().put('orderId', orderList.id);   
            
            Subscription_Vendor__c subVen = TestDataFactory.createSubscriptionVendor(1) [0];
            insert subVen;
            
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Earliest_Start_Date__c = Date.today().addDays(1);
            insert pub;
            
            Subscription_Vendor_Publication__c vendorPublication = TestDataFactory.createVendorPublication(1)[0];
            vendorPublication.Mon__c = 10;
            vendorPublication.Tue__c = 20;
            vendorPublication.Wed__c = 30;
            vendorPublication.Thu__c = 40;
            vendorPublication.Fri__c = 50;
            vendorPublication.Sat__c = 60; 
            vendorPublication.Sun__c = 70; 
            vendorPublication.PHd__c = 80;
            vendorPublication.PHe__c = 90;
            vendorPublication.Publication__c = pub.id;
            vendorPublication.Subscription_Vendor__c = subVen.id;
            insert vendorPublication;
           
            List<Subscription_Vendor_Publication__c> vendorPublication2 = TestDataFactory.createVendorPublication(1);
            vendorPublication2[0].Mon__c = 10;
            vendorPublication2[0].Tue__c = 20;
            vendorPublication2[0].Wed__c = 30;
            vendorPublication2[0].Thu__c = 40;
            vendorPublication2[0].Fri__c = 50;
            vendorPublication2[0].Sat__c = 60; 
            vendorPublication2[0].Sun__c = 70; 
            vendorPublication2[0].PHd__c = 80;
            vendorPublication2[0].PHe__c = 90;
            vendorPublication2[0].Publication__c = pub.id;
            vendorPublication2[0].Subscription_Vendor__c = subVen.id;          
            insert vendorPublication2;
            
            Order_Line_Item_Vendor__c orderLine = TestDataFactory.createOrderLineItemVendor(1)[0]; 
            orderLine.Order__c = orderList.id;
            orderLine.Additional_Termination_Comment_del__c = 'Additional Termination Comment';
            orderLine.Subscription_Vendor_Publication__c = vendorPublication.id;
            orderLine.Start_Date__c = date.Today()+5;
            orderLine.Earliest_Stop_Date__c = Date.newInstance(2015, 08, 30);
            orderLine.Stop_Request_Date__c = Date.today().addDays(1);//date.Today() +1;
            insert orderLine;
            
            List<Order_Line_Item_Vendor__c> orderLine2 = TestDataFactory.createOrderLineItemVendor(1); 
            orderLine2[0].Order__c = orderList.id;
            orderLine2[0].Additional_Termination_Comment_del__c = 'Additional Termination Comment';
            orderLine2[0].Subscription_Vendor_Publication__c = vendorPublication.id;
            orderLine2[0].Start_Date__c = date.Today()+5;
            orderLine2[0].Stop_Request_Date__c = Date.today().addDays(1);//date.Today() +1;
            insert orderLine2;
  
            Order_Line_Item_Vendor__c testOrderLine  = [SELECT id FROM Order_Line_Item_Vendor__c WHERE ID =:orderLine.id];
            System.assertNotEquals(null, testOrderLine);
            
            Integer counter = 1 ;
            List<SelectOption> items = new List<SelectOption>();
            Date SubStartDate = date.Today() +1;
            
            Test.startTest();
            PageReference cancel;
            PageReference submit;
            PageReference edit;
            String index = 'index';
            
      
            StopSubOrderEntry_ViewVendorController testClass = new StopSubOrderEntry_ViewVendorController();
           
            testClass.oli = orderLine;
            testClass.pubObject = vendorPublication;
            testClass.SubVen = subVen;
            testClass.counter = counter;
            testClass.items = items;
            testClass.index = index;
            testClass.SubStartDate = SubStartDate;
            testClass.publicationRecordList  = vendorPublication2;
            testClass.orderLineItemList = orderLine2;
            testClass.finalPublicationList = vendorPublication2;
            
            testClass.getAccount();
            testClass.getOrder();
            testClass.createOrderLine(vendorPublication);
            testClass.cancel();
            testClass.submit();
            testClass.edit();
            testClass.voidStatus();            
            Test.stopTest();
            
  }  
}