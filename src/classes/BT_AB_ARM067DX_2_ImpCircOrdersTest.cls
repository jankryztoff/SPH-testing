/**
* Class Name: BT_AB_ARM067DX_2_ImpCircOrdersTest
* @author: Recuerdo Bregente
* @date: 07/09/2015
* @requirement/Project Name: SPH Project
* @description Batch Apex Class to test BT_AB_ARM067DX_2_ImportCirculationOrders. 
* to the Subscriber via Email.
*/
@isTest(seeAllData=True)
private class BT_AB_ARM067DX_2_ImpCircOrdersTest {

    static final String invoiceProductId = 'PRO0000001';
    static final String appliedInvoiceId = 'APPINV0001';
    
    
    static List<Zuora__ZInvoice__c> zuoraInvoice;
    static Invoice_Line_Item__c testInvoiceLineItem;
    static Invoice_Line_Item__c newTestInvoiceLineItem;
    static zqu__ZProduct__c testProduct;

    
    /**
    * @name : prepareZuoraInvoiceRecord
    * @author : Recuerdo Bregente
    * @description : Prepares the Zuora Invoice Record.
    * @date: 07/09/2015
    */ 
    static void prepareZuoraInvoiceRecord(Integer recordCount, String mockId, Decimal chargeAmount, String productType) {
        zuoraInvoice = TestDataFactory.createInvoice(recordCount);
        Date invoiceDate = Date.today();
        System.assertNotEquals(null, invoiceDate);
            
            for(Zuora__ZInvoice__c zuoraInvoiceRec : zuoraInvoice){
                zuoraInvoiceRec.Zuora__InvoiceDate__c = invoiceDate;
                zuoraInvoiceRec.ARMS_invoice_id__c = '027000001';
                zuoraInvoiceRec.Zuora__External_Id__c = 'EXT111111';
                zuoraInvoiceRec.Zuora__TaxAmount__c = 100;
                zuoraInvoiceRec.Zuora__AmountWithoutTax__c = 100;
                zuoraInvoiceRec.ARMS_Interface_Timestamp__c = date.today();
            }
             
            insert zuoraInvoice;
            
        testInvoiceLineItem = new Invoice_Line_Item__c();
        testInvoiceLineItem.Invoice_ID__c = 'EXT111111';
        testInvoiceLineItem.Quantity__c = 100;
        testInvoiceLineItem.Tax_Amount__c = 1000.0;
        testInvoiceLineItem.Unit_Price__c = 1000.0;
        testInvoiceLineItem.Charge_Amount__c = chargeAmount;
        testInvoiceLineItem.Product_ID__c = invoiceProductId;
        if(null != mockId){
            testInvoiceLineItem.Applied_To_Invoice_Item_ID__c = mockId;
            testInvoiceLineItem.ID__c = mockId;
        }
        
        insert testInvoiceLineItem;
        
        newTestInvoiceLineItem = new Invoice_Line_Item__c();
        newTestInvoiceLineItem.Invoice_ID__c = 'EXT111111';
        newTestInvoiceLineItem.Quantity__c = 100;
        newTestInvoiceLineItem.Tax_Amount__c = 1000.0;
        newTestInvoiceLineItem.Unit_Price__c = 1000.0;
        newTestInvoiceLineItem.Charge_Amount__c = 1000;
        testInvoiceLineItem.Product_ID__c = invoiceProductId;
        if(null != mockId){
            testInvoiceLineItem.Applied_To_Invoice_Item_ID__c = mockId;
            testInvoiceLineItem.ID__c = mockId;
        }
        
        insert newTestInvoiceLineItem;
        
        testProduct =  TestDataFactory.createZProduct(1)[0];
            testProduct.zqu__ZuoraId__c = invoiceProductId;
            testProduct.ProductCode__c = productType;
            testProduct.ProductType__c = 'Product';
        insert testProduct;
    }
    
    /**
    * @name: testBatchIfProductTypeIsDELC
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BT_AB_ARM067DX_2_ImportCirculationOrders execution
    *                with Product type is DELC.
    * @date: 07/09/2015
    */
    static testMethod void testBatchIfProductTypeIsDELC(){
        boolean errorExist = false;
        ID batchprocessid;
        try{
            Test.StartTest();
            prepareZuoraInvoiceRecord(1, null, 1000, 'DELC');
        
            BT_AB_ARM067DX_2_ImportCirculationOrders batch = new BT_AB_ARM067DX_2_ImportCirculationOrders();
            batchprocessid = Database.executeBatch(batch, 200);

            Test.StopTest();  
        } catch (Zuora.zRemoteException e) {
            errorExist = true;
        }
        
        System.assertEquals(false, errorExist);
    }
    
    /**
    * @name: testBatchIfProductTypeIsNotDELCAndNotNewsPaper
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BT_AB_ARM067DX_2_ImportCirculationOrders execution
    *                with Product type is not DELC and not Newspaper.
    * @date: 07/09/2015
    */
    static testMethod void testBatchIfProductTypeIsNotDELCAndNotNewsPaper(){
        boolean errorExist = false;
        ID batchprocessid;
        try{
            Test.StartTest();
            prepareZuoraInvoiceRecord(1, null, 1000, 'Prod');
        
            BT_AB_ARM067DX_2_ImportCirculationOrders batch = new BT_AB_ARM067DX_2_ImportCirculationOrders();
            batchprocessid = Database.executeBatch(batch, 200);

            Test.StopTest();  
        } catch (Zuora.zRemoteException e) {
            errorExist = true;
        }
        
        System.assertEquals(false, errorExist);
    }
    
    /**
    * @name: testBatchIfChargeAmountLessThanZero
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BT_AB_ARM067DX_2_ImportCirculationOrders execution
    *                with Applied_To_Invoice_Item_ID__c is not null And amount is less than zero.
    * @date: 07/09/2015
    */
    static testMethod void testBatchIfChargeAmountLessThanZero(){
        boolean errorExist = false;
        ID batchprocessid;
        try{
            Test.StartTest();
            prepareZuoraInvoiceRecord(1, appliedInvoiceId, -1, 'DELC');
        
            BT_AB_ARM067DX_2_ImportCirculationOrders batch = new BT_AB_ARM067DX_2_ImportCirculationOrders();
            batchprocessid = Database.executeBatch(batch, 200);

            Test.StopTest();  
        } catch (Zuora.zRemoteException e) {
            errorExist = true;
        }
        
        System.assertEquals(false, errorExist);
    }
    
    /**
    * @name: testBatchIfChargeAmountLessThanZero
    * @author : Recuerdo Bregente
    * @description : Handles the testing for BT_AB_ARM067DX_2_ImportCirculationOrders execution
    *                with Applied_To_Invoice_Item_ID__c is null And amount is less than zero.
    * @date: 07/09/2015
    */
    static testMethod void testBatchIfAppliedInvoiceNullAndChargeAmountLessThanZero(){
        boolean errorExist = false;
        ID batchprocessid;
        try{
            Test.StartTest();
            prepareZuoraInvoiceRecord(1, null, -1, 'DELC');
        
            BT_AB_ARM067DX_2_ImportCirculationOrders batch = new BT_AB_ARM067DX_2_ImportCirculationOrders();
            batchprocessid = Database.executeBatch(batch, 200);

            Test.StopTest();  
        } catch (Zuora.zRemoteException e) {
            errorExist = true;
        }
        
        System.assertEquals(false, errorExist);
    }
    
 }