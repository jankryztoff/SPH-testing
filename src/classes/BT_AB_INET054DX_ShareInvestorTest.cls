/**
 * Class Name: BT_AB_INET054DX_ShareInvestorTest     
 * @author: Accenture IDC - Nilesh    
 * Date: 17 Feb 2015    
 * Requirement/Project Name: SPH Project    
 * @description Test Class for BT_AB_INET054DX_ShareInvestorChargeOut    
 */
@isTest (SeeAllData = true)
public class BT_AB_INET054DX_ShareInvestorTest {

   /* static {
        
        BT_CO_Batch_Run_Request__c batchRunRequest = new BT_CO_Batch_Run_Request__c();
        batchRunRequest.Interface_ID__c = 'INET054DX';
        batchRunRequest.Batch_Run_Date__c = System.Today()+1;
        
        insert batchRunRequest;
    } */
    
    static testmethod void executeBatch(){
       
     Integer count = 0;
        //Account__c
        List<Account> accounts = TestDataFactory.createAccount(1, 'Direct Corporate');
        accounts[0].AccountNumber = 'TestAcctNum';
        insert accounts;
        
        //SingPost Address  
        List<Singpost_Address__c> postalAddresses = TestDataFactory.createSingpostAddress(1);
        for(Singpost_Address__c postalAdd: postalAddresses){
            postalAdd.Building_Name__c = 'eBloc Tower 2';
            postalAdd.Street_Name__c = 'W. Geonzon St.';
            postalAdd.Name = 'TestName';
        }
        insert postalAddresses;   
        
         //Address
        List<Address__c> addresses = TestDataFactory.createAddress(1);
        for(Address__c address: addresses){
        address.Postal_Code__c = postalAddresses[0].id;
        }
        insert addresses;  
        
          //Contact
        List<Contact> contacts = TestDataFactory.createContact(1);
        count = 0;
        for(Contact contact: contacts){
         contact.Address__c = addresses[count].id;
         contact.AccountId = accounts[count].id;
         contact.Recipient_Indicator__c = true;
        }
        insert contacts;  
        
         //Billing Account
       Zuora__CustomerAccount__c ba = TestDataFactory.createBillingAccount(1)[0];
       ba.Name = 'TestName';
       ba.Zuora__Account__c = accounts[0].Id;
       ba.Zuora__AccountNumber__c = 'TestAcctNum';
       ba.Billing_Contact__c = contacts[0].id;
       ba.Billing_Type__c = 'Full Prepaid'; 
       ba.Zuora__Status__c = 'Active';
       insert ba;
       
       //Zuora Subscription
       List<Zuora__Subscription__c> subRecs1 = TestDataFactory.createSubscription(4);
        for (Zuora__Subscription__c subRec : subRecs1) {
            subRec.Zuora__CustomerAccount__c = ba.id;
            subRec.Product_Code__c = 'Test Code';
            subRec.Zuora__Account__c = accounts[0].Id;
            }
           
            insert subRecs1; 
       
      //Invoice__c
       List<Zuora__ZInvoice__c> invList = TestDataFactory.createInvoice(1);
       invList[0].Name = 'TestName';
       invList[0].Zuora__ZuoraId__c = ba.id;
       invList[0].Zuora__BillingAccount__c = ba.id;
       invList[0].Zuora__InvoiceDate__c = Date.today();
       invList[0].Zuora__Zuora_Id__c = 'Test';
       invList[0].Zuora__Account__c = accounts[0].id;
       insert invList;
       
       zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
       zProd.zqu__ZuoraId__c = 'Test';
       zProd.ProductCode__c = 'Test Code';
       insert zProd;
       
       zqu__ProductRatePlan__c zProdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
       zProdRatePlan.zqu__ZProduct__c = zProd.id;
       insert zProdRatePlan;
       
       zqu__ProductRatePlanCharge__c zProdRate = TestDataFactory.createProductRatePlanCharge(1)[0];
       zProdRate.PublicationCode__c = 'SIOP';
       zProdRate.zqu__ProductRatePlan__c = zProdRatePlan.id;
       insert zProdRate;
       
       List<Invoice_Line_Item__c> invoList = new List<Invoice_Line_Item__c>();
       Invoice_Line_Item__c inv = new Invoice_Line_Item__c();
       inv.Invoice_ID__c = 'Test';
       inv.Quantity__c = 50;
       inv.Tax_Amount__c = 30.00;
       inv.Unit_Price__c = 20.00;
       inv.Charge_Amount__c = 15.00;
       inv.Product_ID__c = 'Test';
       inv.Subscription__c = subRecs1[0].id;
       
       invoList.add(inv);
       insert invoList;       
    
        Test.StartTest();
        try{
        BT_AB_INET054DX_ShareInvestorChargeOut batch = new BT_AB_INET054DX_ShareInvestorChargeOut();
        //Database.executeBatch(batch, 1000000);
        }catch(exception e){}
        Test.StopTest(); 
    
    
    
   /* Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
    insert dtl;
 
        String zuoraId = '3689922200';
        String productCode = 'XXXX';
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';

        defaultCustomSetting();
        
        Map<String, SObject> sObjectList = TestDataFactory.createSubscriptionPackage();
        
        Account testAccount = (Account) sObjectList.get('Account');
       
        zqu__ZProduct__c testProduct =  (zqu__ZProduct__c) sObjectList.get('zqu__ZProduct__c');
            testProduct.zqu__ZuoraId__c = zuoraId;
            testProduct.ProductCode__c = productCode;
        update testProduct;
        
        Zuora__CustomerAccount__c testCustomerAccount = (Zuora__CustomerAccount__c) sObjectList.get('Zuora__CustomerAccount__c');
            testCustomerAccount.Zuora__Status__c = 'Active';
            testCustomerAccount.Zuora__DefaultPaymentMethod__c = 'Other';
        update testCustomerAccount;
        
        Zuora__Subscription__c testSubscription = (Zuora__Subscription__c) sObjectList.get('Zuora__Subscription__c');
            testSubscription.Product_Code__c = productCode;
            testSubscription.Zuora__CustomerAccount__c = testCustomerAccount.id;
        insert testSubscription;

        zqu__ProductRatePlanCharge__c testProductRatePlanCharge =  (zqu__ProductRatePlanCharge__c) sObjectList.get('zqu__ProductRatePlanCharge__c');
            testProductRatePlanCharge.zqu__ZuoraId__c = zuoraId;
            testProductRatePlanCharge.PublicationCode__c = 'SIOP';
        update testProductRatePlanCharge;
        
        Zuora__ZInvoice__c testInvoice = TestDataFactory.createInvoice(1)[0];
            testInvoice.Zuora__Zuora_Id__c = invoiceId;
            testInvoice.Zuora__Account__c = testAccount.id;
            testInvoice.Zuora__BillingAccount__c = testCustomerAccount.id;
        insert testInvoice; 

        Invoice_Line_Item__c testInvoiceLineItem = new Invoice_Line_Item__c();
            testInvoiceLineItem.Invoice_ID__c = invoiceId;
            testInvoiceLineItem.Quantity__c = 100;
            testInvoiceLineItem.Tax_Amount__c = 1000.0;
            testInvoiceLineItem.Unit_Price__c = 1000.0;
            testInvoiceLineItem.Charge_Amount__c = 1000.0;
            testInvoiceLineItem.Product_ID__c = zuoraId;
        insert testInvoiceLineItem;
                
        Test.StartTest();
            BT_AB_INET054DX_ShareInvestorChargeOut batch = new BT_AB_INET054DX_ShareInvestorChargeOut();
            Database.executeBatch(batch, 200);
        Test.StopTest(); 
    }
    
    static void defaultCustomSetting()
    {
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name'};
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
                keyId = new Key_Id__c();
                keyId.Name = keyIdNameArray[i];
                keyId.Id__c = keyIdIdcArray[i];
                keyId.Type__c = keyIdTypeArray[i];
            insert keyId;
        }
        
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print'};
        
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
                otherC = new Other__c();
                otherC.Name = orderCNameArray[i];
                otherC.Value__c = orderCValueArray[i];
            insert otherC;
        }
        
        Cir_Planner_Schedule__c cirPlannerSchedule = new Cir_Planner_Schedule__c();
            cirPlannerSchedule.Sat_PH_Start_Time__c = System.Now();
            cirPlannerSchedule.Sat_PH_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Mon_Fri_Start_Time__c = System.Now();
            cirPlannerSchedule.Mon_Fri_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Sun_Start_Time__c = System.Now();
            cirPlannerSchedule.Sun_End_Time__c = System.Now()+1;
            cirPlannerSchedule.Name = 'CIR Plan Schedule';
        insert cirPlannerSchedule;
        
        BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
            batchInterfaceSetting.Name = 'Endpoint Delegator';
            batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        insert batchInterfaceSetting; 
        */
    } 
}