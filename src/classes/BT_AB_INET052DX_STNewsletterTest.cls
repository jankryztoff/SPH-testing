@isTest
public class BT_AB_INET052DX_STNewsletterTest{

    static testMethod void testBT_AB_INET052DX_STNewsletter() {
    
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
        
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.Name = 'TestName';
        database.insert(acc);
        
        Address__c address = TestDataFactory.createAddress(1)[0];
        database.insert(address);
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.AccountId = acc.id;
        con.HomePhone__c = '321324321434';
        con.Billing_Indicator__c = True;
        con.Email = 'TestName@testing.com';
        con.Email__c = 'TestName@testing.com';
        con.Email_Secondary__c = 'TestName@testing.com';
        //contact1.Recipient_Indicator__c = true;
        con.Address__c = address.Id;
        database.insert(con);  
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        pack.Product_Family_Current_Package__c = 'ST';
        database.insert(pack);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__Account__c = acc.id;
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Main_Package__c = pack.Id;
        sub.Contact__c = con.id;
        sub.Recipient_Contact__c = con.id; 
        sub.Product_Code__c = '01';
        sub.Term_Length__c = 1;
        sub.Term_Length1__c = '1'; 
        sub.Main_Package_1__c = pack.Id;
        sub.Zuora__SubscriptionStartDate__c = date.today();
        sub.Zuora__SubscriptionEndDate__c = date.today().addDays(1);
        database.insert(sub);
        
       // List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        //subList.add(sub);
        
        List<Order__c> orders = TestDataFactory.createOrder(1);
        for(Order__c ord : orders){
        ord.Account__c = acc.id;
        ord.Order_Type__c = 'Renewal'; 
        ord.Base_Subscription__c = sub.id;
        ord.Billing_Contact__c = con.id;
        ord.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        }      
        database.insert(orders);
        
        List<Order_Line_Item__c> olis = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c oli : olis ){
        oli.Order__c = orders[0].id; 
        oli.Main_Package_ID__c = pack.id; 
        oli.Subscription__c = sub.id;  
        oli.Start_Date__c = Date.Today().addDays(2);          
        }
        database.insert(olis);

         BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
         datapoolRecord.Name = 'INET052DX';
         datapoolRecord.job_id__c = '1';
         datapoolRecord.group_id__c = 'Detail';
         datapoolRecord.run_for_date__c = Date.today();      
         datapoolRecord.insert_time__c = DateTime.now(); 
         datapoolRecord.export_data__c = '';
         insert datapoolRecord;
            
            List<Zuora__Subscription__c> scope =[SELECT Zuora__Account__c,
            Zuora__CustomerAccount__c,
            Main_Package__c,
            Contact__c,
            Recipient_Contact__c,
            Product_Code__c,
            Term_Length__c,
            Term_Length1__c, 
            Main_Package_1__c,
            Zuora__SubscriptionStartDate__c,
            Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c where ID =:sub.id and Contact__c!= null ];
        
         test.startTest();
         
            BT_AB_INET052DX_STNewsletter batch = new BT_AB_INET052DX_STNewsletter();
            database.executeBatch(batch, 200);
            
        test.stopTest(); 
        
    
    }
   
}