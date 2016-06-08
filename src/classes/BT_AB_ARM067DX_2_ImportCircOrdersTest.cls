/**
 * Class Name: BT_AB_ARM067DX_2_ImportCircOrdersTest     
 * @author: Accenture IDC - Nilesh    
 * Date: 18 Feb 2015    
 * Requirement/Project Name: SPH Project    
 * @description Test Class for BT_AB_ARM067DX_2_ImportCirculationOrders    
 */
@isTest
public class BT_AB_ARM067DX_2_ImportCircOrdersTest {
    
    
    static testMethod void executeBatch(){
        
        String externalId = 'XXXXXXXX';
        String zuoraId = '3689922200';
        String productCode = 'XXXX';
        
        defaultCustomSetting();
        
        //ARMS_Interface_Timestamp__c != null AND ARMS_invoice_id__c != null AND Zuora__TotalAmount__c > 0
        
        Other__c otherC = new Other__c();
            otherC.Name = 'GST';
            otherC.Value__c = '7';
        insert otherC;

        Other__c otherC2 = new Other__c();
            otherC2.Name = 'LOG_DEBUG_ON';
            otherC2.Value__c = '7';
        insert otherC2;

        Zuora__ZInvoice__c testInvoice = TestDataFactory.createInvoice(1)[0];
            testInvoice.Zuora__InvoiceDate__c = date.Today();
            testInvoice.Zuora__External_Id__c = externalId;
            testInvoice.ARMS_Interface_Timestamp__c = date.today();
            testInvoice.ARMS_invoice_id__c = '027000001';
            testInvoice.Zuora__TotalAmount__c = 10.00;
            testInvoice.Previous_Balance__c = '1';
            testInvoice.ARMS_Interface_Timestamp__c = date.today().addDays(1);
        insert testInvoice;
         
        Invoice_Line_Item__c testInvoiceLineItem = new Invoice_Line_Item__c();
            testInvoiceLineItem.Invoice_ID__c = externalId;
            testInvoiceLineItem.Quantity__c = 100;
            testInvoiceLineItem.Tax_Amount__c = 1000.0;
            testInvoiceLineItem.Unit_Price__c = 1000.0;
            testInvoiceLineItem.Charge_Amount__c = 1000.0;
            testInvoiceLineItem.Product_ID__c = zuoraId;
        insert testInvoiceLineItem;
        
        zqu__ZProduct__c testProduct =  TestDataFactory.createZProduct(1)[0];
            testProduct.zqu__ZuoraId__c = zuoraId;
            testProduct.ProductCode__c = productCode;
            testProduct.ProductType__c = 'Product';
            testProduct.ProductSubType__c ='Newspaper';
        insert testProduct;
        
        zqu__ProductRatePlan__c testProductRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            testProductRatePlan.zqu__ZProduct__c = testProduct.Id;
            testProductRatePlan.RatePlanType__c= 'Bill Plan';
            testProductRatePlan.zqu__EffectiveStartDate__c= date.today();
            testProductRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            testProductRatePlan.zqu__Deleted__c = false;
        insert testProductRatePlan;
        
        zqu__ProductRatePlanCharge__c testProductRatePlanCharge =  TestDataFactory.createProductRatePlanCharge(1)[0];
            testProductRatePlanCharge.Name = 'Product Rate Plan Charge';
            testProductRatePlanCharge.zqu__ProductRatePlan__c = testProductRatePlan.id;
            testProductRatePlanCharge.zqu__ZuoraId__c = zuoraId;
        insert testProductRatePlanCharge;
        
        List<Zuora__ZInvoice__c> scope = [SELECT Zuora__InvoiceDate__c, Zuora__External_Id__c,
            ARMS_Interface_Timestamp__c, ARMS_invoice_id__c,Zuora__TotalAmount__c, Previous_Balance__c FROM Zuora__ZInvoice__c LIMIT 1];
        system.debug('***scope = ' + scope);
        try{
            Test.StartTest();
                BT_AB_ARM067DX_2_ImportCirculationOrders batch = new BT_AB_ARM067DX_2_ImportCirculationOrders();
                Database.executeBatch(batch, 200);
                Database.BatchableContext BC;
                batch.execute(BC,scope);
            Test.StopTest(); 
        }catch(exception e){}
    }
    
    static void defaultCustomSetting()
    {
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type'};
        
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

    static testMethod void executeBatch2(){
        
        String externalId = 'XXXXXXXX';
        String zuoraId = '3689922200';
        String productCode = 'DELCHG';
        
        defaultCustomSetting();
        
        //ARMS_Interface_Timestamp__c != null AND ARMS_invoice_id__c != null AND Zuora__TotalAmount__c > 0
        
        Other__c otherC = new Other__c();
            otherC.Name = 'GST';
            otherC.Value__c = '7';
        insert otherC;

        Other__c otherC2 = new Other__c();
            otherC2.Name = 'LOG_DEBUG_ON';
            otherC2.Value__c = '7';
        insert otherC2;

        Zuora__ZInvoice__c testInvoice = TestDataFactory.createInvoice(1)[0];
            testInvoice.Zuora__InvoiceDate__c = date.Today();
            testInvoice.Zuora__External_Id__c = externalId;
            testInvoice.ARMS_Interface_Timestamp__c = date.today();
            testInvoice.ARMS_invoice_id__c = '027000001';
            testInvoice.Zuora__TotalAmount__c = 10.00;
            testInvoice.Previous_Balance__c = '0';
            testInvoice.ARMS_Interface_Timestamp__c = date.today().addDays(1);
        insert testInvoice;
         
        Invoice_Line_Item__c testInvoiceLineItem = new Invoice_Line_Item__c();
            testInvoiceLineItem.Invoice_ID__c = externalId;
            testInvoiceLineItem.Quantity__c = 100;
            testInvoiceLineItem.Tax_Amount__c = 1000.0;
            testInvoiceLineItem.Unit_Price__c = 1000.0;
            testInvoiceLineItem.Charge_Amount__c = 1000.0;
            testInvoiceLineItem.Product_ID__c = zuoraId;
        insert testInvoiceLineItem;
        
        zqu__ZProduct__c testProduct =  TestDataFactory.createZProduct(1)[0];
            testProduct.zqu__ZuoraId__c = zuoraId;
            testProduct.ProductCode__c = productCode;
            testProduct.ProductType__c = 'Product';
            testProduct.ProductSubType__c ='Newspaper';
        insert testProduct;
        
        zqu__ProductRatePlan__c testProductRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            testProductRatePlan.zqu__ZProduct__c = testProduct.Id;
            testProductRatePlan.RatePlanType__c= 'Bill Plan';
            testProductRatePlan.zqu__EffectiveStartDate__c= date.today();
            testProductRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            testProductRatePlan.zqu__Deleted__c = false;
        insert testProductRatePlan;
        
        zqu__ProductRatePlanCharge__c testProductRatePlanCharge =  TestDataFactory.createProductRatePlanCharge(1)[0];
            testProductRatePlanCharge.Name = 'Product Rate Plan Charge';
            testProductRatePlanCharge.zqu__ProductRatePlan__c = testProductRatePlan.id;
            testProductRatePlanCharge.zqu__ZuoraId__c = zuoraId;
        insert testProductRatePlanCharge;
        
        List<Zuora__ZInvoice__c> scope = [SELECT Zuora__InvoiceDate__c, Zuora__External_Id__c,
            ARMS_Interface_Timestamp__c, ARMS_invoice_id__c,Zuora__TotalAmount__c, Previous_Balance__c FROM Zuora__ZInvoice__c LIMIT 1];
        system.debug('***scope = ' + scope);
        try{
            Test.StartTest();
                BT_AB_ARM067DX_2_ImportCirculationOrders batch = new BT_AB_ARM067DX_2_ImportCirculationOrders();
                Database.executeBatch(batch, 200);
                Database.BatchableContext BC;
                batch.execute(BC,scope);
            Test.StopTest(); 
        }catch(exception e){}
    }

    static testMethod void executeBatch3(){
        
        String externalId = 'XXXXXXXX';
        String zuoraId = '3689922200';
        String productCode = 'DELCHG';
        
        defaultCustomSetting();
        
        //ARMS_Interface_Timestamp__c != null AND ARMS_invoice_id__c != null AND Zuora__TotalAmount__c > 0
        
        Other__c otherC = new Other__c();
            otherC.Name = 'GST';
            otherC.Value__c = '7';
        insert otherC;

        Other__c otherC2 = new Other__c();
            otherC2.Name = 'LOG_DEBUG_ON';
            otherC2.Value__c = '7';
        insert otherC2;

        Zuora__ZInvoice__c testInvoice = TestDataFactory.createInvoice(1)[0];
            testInvoice.Zuora__InvoiceDate__c = date.Today();
            testInvoice.Zuora__External_Id__c = externalId;
            testInvoice.ARMS_Interface_Timestamp__c = date.today();
            testInvoice.ARMS_invoice_id__c = '027000001';
            testInvoice.Zuora__TotalAmount__c = 10.00;
            testInvoice.Previous_Balance__c = '11';
            testInvoice.ARMS_Interface_Timestamp__c = date.today().addDays(1);
        insert testInvoice;
         
        Invoice_Line_Item__c testInvoiceLineItem = new Invoice_Line_Item__c();
            testInvoiceLineItem.Invoice_ID__c = externalId;
            testInvoiceLineItem.Quantity__c = 100;
            testInvoiceLineItem.Tax_Amount__c = 1000.0;
            testInvoiceLineItem.Unit_Price__c = 1000.0;
            testInvoiceLineItem.Charge_Amount__c = 1000.0;
            testInvoiceLineItem.Product_ID__c = zuoraId;
        insert testInvoiceLineItem;
        
        zqu__ZProduct__c testProduct =  TestDataFactory.createZProduct(1)[0];
            testProduct.zqu__ZuoraId__c = zuoraId;
            testProduct.ProductCode__c = productCode;
            testProduct.ProductType__c = 'Product';
            testProduct.ProductSubType__c ='Newspaper';
        insert testProduct;
        
        zqu__ProductRatePlan__c testProductRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            testProductRatePlan.zqu__ZProduct__c = testProduct.Id;
            testProductRatePlan.RatePlanType__c= 'Bill Plan';
            testProductRatePlan.zqu__EffectiveStartDate__c= date.today();
            testProductRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            testProductRatePlan.zqu__Deleted__c = false;
        insert testProductRatePlan;
        
        zqu__ProductRatePlanCharge__c testProductRatePlanCharge =  TestDataFactory.createProductRatePlanCharge(1)[0];
            testProductRatePlanCharge.Name = 'Product Rate Plan Charge';
            testProductRatePlanCharge.zqu__ProductRatePlan__c = testProductRatePlan.id;
            testProductRatePlanCharge.zqu__ZuoraId__c = zuoraId;
        insert testProductRatePlanCharge;
        
        List<Zuora__ZInvoice__c> scope = [SELECT Zuora__InvoiceDate__c, Zuora__External_Id__c,
            ARMS_Interface_Timestamp__c, ARMS_invoice_id__c,Zuora__TotalAmount__c, Previous_Balance__c FROM Zuora__ZInvoice__c LIMIT 1];
        system.debug('***scope = ' + scope);
        try{
            Test.StartTest();
                BT_AB_ARM067DX_2_ImportCirculationOrders batch = new BT_AB_ARM067DX_2_ImportCirculationOrders();
                Database.executeBatch(batch, 200);
                Database.BatchableContext BC;
                batch.execute(BC,scope);
            Test.StopTest(); 
        }catch(exception e){}
    }

    static testMethod void executeBatch4(){
        
        String externalId = 'XXXXXXXX';
        String zuoraId = '3689922200';
        String productCode = 'XXXX';
        
        defaultCustomSetting();
        
        //ARMS_Interface_Timestamp__c != null AND ARMS_invoice_id__c != null AND Zuora__TotalAmount__c > 0
        
        Other__c otherC = new Other__c();
            otherC.Name = 'GST';
            otherC.Value__c = '7';
        insert otherC;

        Other__c otherC2 = new Other__c();
            otherC2.Name = 'LOG_DEBUG_ON';
            otherC2.Value__c = '7';
        insert otherC2;

        Zuora__ZInvoice__c testInvoice = TestDataFactory.createInvoice(1)[0];
            testInvoice.Zuora__InvoiceDate__c = date.Today();
            testInvoice.Zuora__External_Id__c = externalId;
            testInvoice.ARMS_Interface_Timestamp__c = date.today();
            testInvoice.ARMS_invoice_id__c = '027000001';
            testInvoice.Zuora__TotalAmount__c = 10.00;
            testInvoice.Previous_Balance__c = '0';
            testInvoice.ARMS_Interface_Timestamp__c = date.today().addDays(1);
        insert testInvoice;
         
        Invoice_Line_Item__c testInvoiceLineItem = new Invoice_Line_Item__c();
            testInvoiceLineItem.Invoice_ID__c = externalId;
            testInvoiceLineItem.Quantity__c = 100;
            testInvoiceLineItem.Tax_Amount__c = 1000.0;
            testInvoiceLineItem.Unit_Price__c = 1000.0;
            testInvoiceLineItem.Charge_Amount__c = 1000.0;
            testInvoiceLineItem.Product_ID__c = zuoraId;
        insert testInvoiceLineItem;
        
        zqu__ZProduct__c testProduct =  TestDataFactory.createZProduct(1)[0];
            testProduct.zqu__ZuoraId__c = zuoraId;
            testProduct.ProductCode__c = productCode;
            testProduct.ProductType__c = 'Product';
            testProduct.ProductSubType__c ='News';
        insert testProduct;
        
        zqu__ProductRatePlan__c testProductRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            testProductRatePlan.zqu__ZProduct__c = testProduct.Id;
            testProductRatePlan.RatePlanType__c= 'Bill Plan';
            testProductRatePlan.zqu__EffectiveStartDate__c= date.today();
            testProductRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            testProductRatePlan.zqu__Deleted__c = false;
        insert testProductRatePlan;
        
        zqu__ProductRatePlanCharge__c testProductRatePlanCharge =  TestDataFactory.createProductRatePlanCharge(1)[0];
            testProductRatePlanCharge.Name = 'Product Rate Plan Charge';
            testProductRatePlanCharge.zqu__ProductRatePlan__c = testProductRatePlan.id;
            testProductRatePlanCharge.zqu__ZuoraId__c = zuoraId;
        insert testProductRatePlanCharge;
        
        List<Zuora__ZInvoice__c> scope = [SELECT Zuora__InvoiceDate__c, Zuora__External_Id__c,
            ARMS_Interface_Timestamp__c, ARMS_invoice_id__c,Zuora__TotalAmount__c, Previous_Balance__c FROM Zuora__ZInvoice__c LIMIT 1];
        system.debug('***scope = ' + scope);
        try{
            Test.StartTest();
                BT_AB_ARM067DX_2_ImportCirculationOrders batch = new BT_AB_ARM067DX_2_ImportCirculationOrders();
                Database.executeBatch(batch, 200);
                Database.BatchableContext BC;
                batch.execute(BC,scope);
            Test.StopTest(); 
        }catch(exception e){}
    }

}