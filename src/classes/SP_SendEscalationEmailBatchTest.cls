@isTest
public class SP_SendEscalationEmailBatchTest {

     static testmethod void test() {
     
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        Other__c  othrD = new Other__c();
        othrD.Name = 'Complaint counter days';
        othrD.Value__c = '1';
        insert othrD;
        
        Other__c  othrW = new Other__c();
        othrW.Name = 'Complaint counter weeks';
        othrW.Value__c = '1';
        insert othrW;
     
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c(); 
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'Complaint_Newspaper';
        key.Id__c = '01290000001AgHN';
        key.Type__c = 'RecordType';
        database.insert(key);
         
        Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
        database.insert(acc);
        
        Address__c ad = TestDataFactory.createAddress(1)[0];
        database.insert(ad);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.Address__c = ad.Id;
        database.insert(con);
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        database.insert(billAcc);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
        sub.Zuora__CustomerAccount__c = billAcc.Id;
        sub.Zuora__Account__c = acc.Id;
        sub.Subscriber_Contact__c = con.Id;
        sub.Recipient_Contact__c = con.Id;
        sub.Subscription_Type_1__c = 'Publication';
        sub.Subscription_Type__c = 'Publication';
        sub.Main_Package__c = pack.Id;
        database.insert(sub);
    
        Case cas = TestDataFactory.createCase(1, 'Complaint - Newspaper')[0];
        cas.AccountId = acc.Id;
        //cas.Vendor_Chargeable_Paper__c = true;
        cas.IsEscalated = true;
        cas.Status = 'Pending';
        database.insert(cas);
        
        SP_SendEscalationEmailBatch batch = new SP_SendEscalationEmailBatch();
        ID batchprocessid = Database.executeBatch(batch,200);
         
     }
}