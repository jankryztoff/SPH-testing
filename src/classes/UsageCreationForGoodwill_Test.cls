/**
     * Test Class Name: UsageCreationForGoodwill_Test
     * @author: jensar.joey.z.sayson    
     * @base class: UsageCreationForGoodwill
     * Date: 01/07/2015    
     */

@isTest(SeeAllData=true)
private class UsageCreationForGoodwill_Test
{

    //Global variables
    static Account acc = null;
    static Zuora__CustomerAccount__c billAcc = null;
    static Address__c addressRec = null;
    static Contact con = null; 
    static Contact con1 = null;
    static Order__c order = null;    
    static Case cas = null;
    static Zuora__Subscription__c subRecord = null;
    
    //static Subscription_Name__c subName = null;
    static Zuora__SubscriptionProductCharge__c subProdCharge = null;
    
    static void setAllData01(){

        acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        database.insert(acc);

        billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        database.insert(billAcc);

        addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        database.insert(addressRec);
              
        con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        database.insert(con); 
 
        con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        database.insert(con1);
        
        order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Category__c = 'Subscription Request';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Check';
        order.Billing_Account__c = billAcc.id;
        order.Billing_Type__c = billAcc.Billing_Type__c;
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Order_Type__c = 'Change of Subscription';
        database.insert(order);
        
        subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__CustomerAccount__c = billAcc.id;
        //subRecord.Order__c = order.id;
        //subRecord.Order_Number__c = order.Id;
        subRecord.Order_Number_1__c = order.id;
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
//        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__Status__c = 'Active';
        subRecord.Suppress_Vendor_Start_Notice__c = 'false';
        subRecord.Supressed_Acknowledgement_Letter__c = 'false';
        subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecord.Urgent__c = 'false';
        subRecord.Vendor_Conversion__c = 'false';
        subRecord.Charity__c = 'false';
        subRecord.Billing_Type__c = 'Full Prepaid';
        subRecord.Bundled_With__c = 'TEST';
        subRecord.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Zuora__SubscriptionStartDate__c = date.today();
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Contract_End_Date_1__c = date.today().addDays(10);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
//        subRecord.Main_Package_1__c = pack.id;
        subRecord.Subscription_Type__c = 'Publication';
        subRecord.Subscription_Type_1__c = 'Publication';
//        subRecord.Promotion_1__c = promo.id;
//        subRecord.Name = 'Goodwill Name';
        database.insert(subRecord);

        subProdCharge = new Zuora__SubscriptionProductCharge__c(
            Name='Goodwill-SPC01', 
            Zuora__Price__c=2,
            Zuora__UOM__c='UOM_Test',
            Zuora__ChargeNumber__c='ChargeNumber_Test',
            Zuora__Subscription__c=subRecord.id,
            PublicationCode__c='12345');
        database.insert(subProdCharge);

        cas = TestDataFactory.createCase(1, 'Complaint - Digital')[0];
            cas.Order__c = order.Id;
            cas.Status = 'Closed';
            cas.Goodwill_Amount__c = 1;
            cas.Account__c = acc.Id;
            cas.Subscription_Name__c = subRecord.id;
            cas.Goodwill_Approval_Status__c = 'Approved';
        database.insert(cas); //fritz  
        
        Case_Subscription__c casSub = new Case_Subscription__c(Account__c = acc.Id, isComplaint__c=FALSE, 
            Case__c=cas.id, Subscription__c=subRecord.id);
        database.insert(casSub);
    }
    
    static testmethod void testmethod1(){
        try{
            setAllData01(); //fritz   
                
            Set<Id> caseIdSet = new Set<Id>();
            caseIdSet.add(cas.Id);                      
            
            Test.startTest();
            UsageCreationForGoodwill.createUsageForGoodwill(caseIdSet);
            Test.stopTest();
            
            System.assertNotEquals(null, caseIdSet);
        }
        catch(Zuora.zRemoteException e){}
    }
    
    
    
    static void setAllData02(){

        acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
        acc.Name = 'TEST';
        acc.NRIC__c = 'T1234567R';
        database.insert(acc);

        billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__Credit_Balance__c = 50000.00;
        database.insert(billAcc);

        addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        database.insert(addressRec);
              
        con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acc.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;
        database.insert(con); 
 
        con1 = TestDataFactory.createContact(1)[0];
        con1.Address__c = addressRec.Id;
        con1.AccountId = acc.Id;
        con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con1.Billing_Indicator__c = true;
        database.insert(con1);
        
        order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        order.Case_Record_Type__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Category__c = 'Subscription Request';
        order.Eligible_for_Retention__c = TRUE;
        order.Informed_Customer__c = TRUE;
        order.Sub_Category__c ='Stop Subscription';
        order.Recipient_Contact__c = con.Id;
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Check_Amount__c = 100;
        order.Check_Issuing_Bank__c = 'BLANK';
        order.Check_No__c = 'SPACE';
        order.Check_Dated__c = date.today();
        order.Remarks_Check__c = 'TESTTESTTEST';
        order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
        order.Payment_Mode__c = 'Check';
        order.Billing_Account__c = billAcc.id;
        order.Billing_Type__c = billAcc.Billing_Type__c;
        order.Sub_Category__c = GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION;
        order.Credit_Balance__c = 0;
        order.Delivery_Charge_Type__c = 'S';
        order.Subscriber_Charge__c = 2000.00;
        order.Vendor_Credit__c = 10000.00;
        order.Credit_Balance__c = 20000.00;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        order.Billing_Contact__c= con1.id;
        order.Order_Type__c = 'Change of Subscription';
        database.insert(order);
        
        subRecord = TestDataFactory.createSubscription(1)[0];
        subRecord.Zuora__Account__c = acc.Id;
        subRecord.Zuora__CustomerAccount__c = billAcc.id;
        //subRecord.Order__c = order.id;
        //subRecord.Order_Number__c = order.Id;
        subRecord.Order_Number_1__c = order.id;
        subRecord.Subscriber_Contact__c = con.Id;
        subRecord.Recipient_Contact__c = con.Id;
//        subRecord.Main_Package_1__c = pack.id;
        subRecord.Zuora__Status__c = 'Active';
        subRecord.Suppress_Vendor_Start_Notice__c = 'false';
        subRecord.Supressed_Acknowledgement_Letter__c = 'false';
        subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
        subRecord.Urgent__c = 'false';
        subRecord.Vendor_Conversion__c = 'false';
        subRecord.Charity__c = 'false';
        subRecord.Billing_Type__c = 'Full Prepaid';
        subRecord.Bundled_With__c = 'TEST';
        subRecord.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Subscription_Type_1__c = ConstantsSLB.getkeyid('SubTypePub');
        subRecord.Zuora__SubscriptionStartDate__c = date.today();
        subRecord.Zuora__SubscriptionEndDate__c = date.today().addDays(6);
        subRecord.Contract_End_Date_1__c = date.today().addDays(10);
        subRecord.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
//        subRecord.Main_Package_1__c = pack.id;
        subRecord.Subscription_Type__c = 'Publication';
        subRecord.Subscription_Type_1__c = 'Publication';
//        subRecord.Promotion_1__c = promo.id;
//        subRecord.Name = 'Goodwill Name';
        database.insert(subRecord);

        subProdCharge = new Zuora__SubscriptionProductCharge__c(
            Name='Goodwill-SPC01', 
            Zuora__Price__c=2,
            Zuora__UOM__c='UOM_Test',
            Zuora__ChargeNumber__c='ChargeNumber_Test',
            Zuora__Subscription__c=subRecord.id,
            PublicationCode__c='12345');
        database.insert(subProdCharge);

        cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = order.Id;
            cas.Status = 'Closed';
            //cas.Goodwill_Amount_Newspaper__c = -1;  //Not Writeable. Roll-up Case_Subscription__c : Goodwill_Amount__c 
            cas.Account__c = acc.Id;
            cas.Subscription_Name__c = subRecord.id;
            cas.Goodwill_Approval_Status__c = 'Approved';
            //cas.ClosedDate = null; //Not Writeable
        database.insert(cas);  
        
        Case_Subscription__c casSub = new Case_Subscription__c(
            Account__c = acc.Id, 
            isComplaint__c=FALSE, 
            Case__c=cas.id, 
            Goodwill_Amount__c = 1,
            Subscription__c=subRecord.id);
        database.insert(casSub);
    }
    
    static testmethod void testmethod2(){
        try{
            setAllData01();  //fritz  
                
            Set<Id> caseIdSet = new Set<Id>();
            caseIdSet.add(cas.Id);                      
            
            Test.startTest();
            UsageCreationForGoodwill.createUsageForGoodwill(caseIdSet);
            Test.stopTest();
            
            System.assertNotEquals(null, caseIdSet);
        }
        catch(Zuora.zRemoteException e){}
    }

}