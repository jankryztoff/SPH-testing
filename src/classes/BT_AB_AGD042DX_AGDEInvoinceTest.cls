/**
  * Class Name: BT_AB_AGD042DX_AGDEInvoinceTest
  * @author: Accenture IDC - Nilesh
  * Date: 11 Feb 2015
  * Requirement/Project Name: SPH Project
  * @description Test Class for BT_AB_AGD042DX_AGDEInvoince
  * 
  */
@isTest (SeeAllData = False)
public class BT_AB_AGD042DX_AGDEInvoinceTest {

        static void defaultCustomSetting()
        {
                    String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
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
        }
        
        static testmethod void executeBatch(){
        
                    defaultCustomSetting();
                    
                    Account testAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                    testAccount.NRIC__c = 'T1234567R';
                    testAccount.Attention_To_Care_Of_Indicator__c = 'A';
                    insert testAccount;
                    
                    Zuora__CustomerAccount__c testCustomerAccount = TestDataFactory.createBillingAccount(1)[0];
                    testCustomerAccount.AGD_Unit__c = '1';
                    testCustomerAccount.Attention_To_Care_Of_Indicator__c = 'A';
                    testCustomerAccount.Attention_To_Care_Of_Name__c = '1';
                    testCustomerAccount.Attention_To_Care_Of_Salutation__c = 'MR';
                    testCustomerAccount.Zuora__Account__c = testAccount.Id;
                    insert testCustomerAccount;
                    
                    Zuora__ZInvoice__c testInvoice = TestDataFactory.createInvoice(1)[0];
                    testInvoice.Zuora__InvoiceDate__c = date.today();
                    testInvoice.Zuora__BillingAccount__c = testCustomerAccount.id;
                    testInvoice.Zuora__TaxAmount__c = 100;
                    testInvoice.Zuora__TotalAmount__c = 10;
                    testInvoice.Zuora__External_Id__c='1';
                    insert testInvoice;
                    
                    Invoice_Line_Item__c testInvoiceLineItem = new Invoice_Line_Item__c();
                    testInvoiceLineItem.Invoice_ID__c = '1';
                    testInvoiceLineItem.Unit_Price__c = 2;
                    testInvoiceLineItem.Quantity__c = 5;
                    testInvoiceLineItem.Tax_Amount__c = 100.0;
                    testInvoiceLineItem.Charge_Amount__c = 200.0;
                    testInvoiceLineItem.Charge_Description__c = 'EMPTY';
                    testInvoiceLineItem.Product_Name__c = 'Delivery Charge';
                    insert testInvoiceLineItem;
                    
                    Test.StartTest();
                    BT_AB_AGD042DX_AGDEInvoince batch = new BT_AB_AGD042DX_AGDEInvoince();
                    Database.executeBatch(batch, 200);        
                    Test.StopTest();
                    
        }//end of executeBatch
        
        static testmethod void executeBatch2(){
        
                    defaultCustomSetting();
                    
                    Account testAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                    testAccount.NRIC__c = 'T1234567R';
                    testAccount.Attention_To_Care_Of_Indicator__c = 'A';
                    insert testAccount;
                    
                    Zuora__CustomerAccount__c testCustomerAccount = TestDataFactory.createBillingAccount(1)[0];
                    testCustomerAccount.AGD_Unit__c = '1';
                    testCustomerAccount.Attention_To_Care_Of_Indicator__c = 'A';
                    testCustomerAccount.Attention_To_Care_Of_Name__c = '1';
                    testCustomerAccount.Attention_To_Care_Of_Salutation__c = 'MR';
                    testCustomerAccount.Zuora__Account__c = testAccount.Id;
                    insert testCustomerAccount;
                    
                    Zuora__ZInvoice__c testInvoice = TestDataFactory.createInvoice(1)[0];
                    testInvoice.Zuora__InvoiceDate__c = date.today();
                    testInvoice.Zuora__BillingAccount__c = testCustomerAccount.id;
                    testInvoice.Zuora__TaxAmount__c = 100;
                    testInvoice.Zuora__TotalAmount__c = 10;
                    testInvoice.Zuora__External_Id__c='1';
                    insert testInvoice;
                    
                    Invoice_Line_Item__c testInvoiceLineItem = new Invoice_Line_Item__c();
                    testInvoiceLineItem.Invoice_ID__c = '1';
                    testInvoiceLineItem.Unit_Price__c = 2;
                    testInvoiceLineItem.Quantity__c = 5;
                    testInvoiceLineItem.Tax_Amount__c = 100.0;
                    testInvoiceLineItem.Charge_Amount__c = 200.0;
                    testInvoiceLineItem.Charge_Description__c = 'EMPTY';
                    testInvoiceLineItem.Product_Name__c =  'Postage Charge';
                    insert testInvoiceLineItem;
                    
                    Test.StartTest();
                    BT_AB_AGD042DX_AGDEInvoince batch = new BT_AB_AGD042DX_AGDEInvoince();
                    Database.executeBatch(batch, 200);        
                    Test.StopTest();
                    
        }//end of executeBatch2
        static testmethod void executeBatch3(){
        
                    defaultCustomSetting();
                    
                    Other__c other = new Other__c();
                    other.Name = 'DTL';
                    other.Value__c = '23:59';
                    database.insert(other);
                    
                    Account testAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                    testAccount.NRIC__c = 'T1234567R';
                    testAccount.Attention_To_Care_Of_Indicator__c = 'A';
                    insert testAccount;
                    
                    Zuora__CustomerAccount__c testCustomerAccount = TestDataFactory.createBillingAccount(1)[0];
                    testCustomerAccount.AGD_Unit__c = '1';
                    testCustomerAccount.Attention_To_Care_Of_Indicator__c = 'A';
                    testCustomerAccount.Attention_To_Care_Of_Name__c = '1';
                    testCustomerAccount.Attention_To_Care_Of_Salutation__c = 'MR';
                    testCustomerAccount.Zuora__Account__c = testAccount.Id;
                    insert testCustomerAccount;
                    
                    Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                    zSub.Zuora__Account__c = testAccount.id;
                    zSub.Zuora__CustomerAccount__c = testCustomerAccount.id;
                    zSub.Zuora__SubscriptionStartDate__c = null;
                    zSub.Zuora__SubscriptionEndDate__c = date.Today() + 5;
                    database.insert(zSub);
                    
                    Zuora__ZInvoice__c testInvoice = TestDataFactory.createInvoice(1)[0];
                    testInvoice.Zuora__InvoiceDate__c = date.today();
                    testInvoice.Zuora__BillingAccount__c = testCustomerAccount.id;
                    testInvoice.Zuora__TaxAmount__c = 100;
                    testInvoice.Zuora__TotalAmount__c = 10;
                    testInvoice.Zuora__External_Id__c='1';
                    insert testInvoice;
                    
                    Invoice_Line_Item__c testInvoiceLineItem = new Invoice_Line_Item__c();
                    testInvoiceLineItem.Invoice_ID__c = '1';
                    testInvoiceLineItem.Unit_Price__c = 2;
                    testInvoiceLineItem.Quantity__c = 5;
                    testInvoiceLineItem.Tax_Amount__c = 100.0;
                    testInvoiceLineItem.Charge_Amount__c = 200.0;
                    testInvoiceLineItem.Charge_Description__c = 'EMPTY';
                    testInvoiceLineItem.Product_Name__c =  'Neither';
                    testInvoiceLineItem.Subscription__c = zSub.id;
                    insert testInvoiceLineItem;
                    
                    Test.StartTest();
                    BT_AB_AGD042DX_AGDEInvoince batch = new BT_AB_AGD042DX_AGDEInvoince();
                    Database.executeBatch(batch, 200);        
                    Test.StopTest();
                    
        }
        static testmethod void executeBatch4(){
        
                    defaultCustomSetting();
                    
                    Other__c other = new Other__c();
                    other.Name = 'DTL';
                    other.Value__c = '23:59';
                    database.insert(other);
                    
                    Account testAccount = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                    testAccount.NRIC__c = 'T1234567R';
                    testAccount.Attention_To_Care_Of_Indicator__c = 'A';
                    insert testAccount;
                    
                    Zuora__CustomerAccount__c testCustomerAccount = TestDataFactory.createBillingAccount(1)[0];
                    testCustomerAccount.AGD_Unit__c = '1';
                    testCustomerAccount.Attention_To_Care_Of_Indicator__c = 'A';
                    testCustomerAccount.Attention_To_Care_Of_Name__c = '1';
                    testCustomerAccount.Attention_To_Care_Of_Salutation__c = 'MR';
                    testCustomerAccount.Zuora__Account__c = testAccount.Id;
                    insert testCustomerAccount;
                    
                    Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                    zSub.Zuora__Account__c = testAccount.id;
                    zSub.Zuora__CustomerAccount__c = testCustomerAccount.id;
                    zSub.Zuora__SubscriptionStartDate__c = date.Today() + 1;
                    zSub.Zuora__SubscriptionEndDate__c = date.Today() + 5;
                    database.insert(zSub);
                    
                    Zuora__ZInvoice__c testInvoice = TestDataFactory.createInvoice(1)[0];
                    testInvoice.Zuora__InvoiceDate__c = date.today();
                    testInvoice.Zuora__BillingAccount__c = testCustomerAccount.id;
                    testInvoice.Zuora__TaxAmount__c = 100;
                    testInvoice.Zuora__TotalAmount__c = 10;
                    testInvoice.Zuora__External_Id__c='1';
            		//START EGC 4/9/2016 added				
            		testInvoice.ARMS_Interface_Timestamp__c = null; 
            		testInvoice.ARMS_invoice_id__c = '02111111';
            		testInvoice.Zuora__TotalAmount__c = 100;
            		testInvoice.Zuora__InvoiceDate__c = System.today().addDays(30);
            		//END EGC 4/9/2016	        
            		insert testInvoice;
                    
                    Invoice_Line_Item__c testInvoiceLineItem = new Invoice_Line_Item__c();
                    testInvoiceLineItem.Invoice_ID__c = '1';
                    testInvoiceLineItem.Unit_Price__c = 2;
                    testInvoiceLineItem.Quantity__c = 5;
                    testInvoiceLineItem.Tax_Amount__c = 100.0;
                    testInvoiceLineItem.Charge_Amount__c = 200.0;
                    testInvoiceLineItem.Charge_Description__c = 'EMPTY';
                    testInvoiceLineItem.Product_Name__c =  'Neither';
                    testInvoiceLineItem.Subscription__c = zSub.id;
                    insert testInvoiceLineItem;
                    
                    Test.StartTest();
                    BT_AB_AGD042DX_AGDEInvoince batch = new BT_AB_AGD042DX_AGDEInvoince();
                        Database.executeBatch(batch, 200);        
                    Test.StopTest();
                    
        }
        
}