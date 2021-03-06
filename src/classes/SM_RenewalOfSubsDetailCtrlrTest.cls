/**
 * Class Name: SM_RenewalOfSubsDetailCtrlrTest
 * @author: Kristine Joyce Balaoing
 * Date: 05/05/2016
 * Requirement/Project Name: Singapore Press Holdings
 * @description Test Class for SM_RenewalOfSubscriptionDetailController
 *
 */
 @isTest
public class SM_RenewalOfSubsDetailCtrlrTest {
    
    //Test Data
    static Account acc;
    static List<Account> accList;
    static List<Order__c> orderRec;
    static List<Order_Line_Item__c> oliList;
    static List<Zuora__Subscription__c> zuoSubList;
    static Other__c otherC;
    static Zuora__CustomerAccount__c  billAcc;
    static List<Package__c> packageList;
    static List<Account> accList2;
    static Promotion__c promoRec;
    static Promotion_Gift__c  promoGiftRec;
    static List<Order_Line_Item_Gift__c> oliGiftList;
    static Key_Id__c keyId;
    //static PageReference pageRef;
    
    
    
    static testMethod void orderPreparation(){
        
        //Account
        accList = TestDataFactory.createAccount(1, 'Direct Individual');
        insert accList;
        
        //BA
        setBillingAccount();

        //Create Contact
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        //con.Address__c = addressRec.Id;
        con.AccountId = accList[0].Id;
        //con.RecordTypeName = 'Customer Contact';
        con.Recipient_Indicator__c = true;
        insert con;
        
        //Custom Setting 
        otherC = new Other__c();
        otherC.Name = 'DTL';
        otherC.Value__c = '23:59';
        insert otherC;
        
        //Key Id
        //Get record type of renewal
        List<RecordType> rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Renewal of Subscription' LIMIT 1];
        keyId = new Key_Id__c();
        keyId.Id__c = rt[0].Id;
        keyId.Name = 'Renewal of Subscription';
        keyId.Type__c = 'RecordType';
        //insert keyId;
        
        //Main Package 
        packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[0].Billing_Type__c = 'Full Prepaid';
        insert packageList; 
        //Vendor Account
        accList2 = TestDataFactory.createAccount(1, 'Mailing Agent');
        accList2[0].NRIC__c = 'T1234532';
        insert accList2;

        
        //Subs from Start
        zuoSubList = TestDataFactory.createSubscription(1);
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
        zuoSubList[0].Recipient_Contact__c= con.Id;
        zuoSubList[0].Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
        //zuoSubList[0].Vendor__c = accList[0].Id;
        zuoSubList[0].Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
        zuoSubList[0].Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
        zuoSubList[0].Zuora__SubscriptionStartDate__c = date.today()-10;
        zuoSubList[0].Zuora__SubscriptionEndDate__c = date.today()+10;
        zuoSubList[0].Subscription_End_Date__c = string.valueof(date.today()+10);
        zuoSubList[0].Main_Package__c = packageList[0].Id;
        zuoSubList[0].Zuora__CustomerAccount__c = billAcc.id;
        zuoSubList[0].Zuora__Account__c = accList[0].id;
        zuoSubList[0].Subscriber_Contact__c= con.Id;
        zuoSubList[0].Delivered_By__c = 'Mailing Agent';
        zuoSubList[0].Delivered_By_1__c = 'Mailing Agent';
        zuoSubList[0].Term_Length__c = 1;
        zuoSubList[0].Term_Length1__c = '1';
        zuoSubList[0].Vendor_1__c = accList2[0].Id;
        zuoSubList[0].Product_Code__c = 'STSU';
        insert zuoSubList;
        

        //Order
        orderRec = TestDataFactory.createOrder(1);
        orderRec[0].Account__c = accList[0].Id;
        orderRec[0].Base_Subscription__c = zuoSubList[0].Id;
        orderRec[0].Order_Type1__c = 'Renewal';
        orderRec[0].Status__c = 'Draft';
        insert orderRec;
        //System.assertEquals( zuoSubList[0].Zuora__SubscriptionStartDate__c, zuoSubList[0].Zuora__SubscriptionEndDate__c);
        //System.debug('SUB REC >>>> ' + subRecs1[0].Zuora__SubscriptionEndDate__c);
        //System.debug('ORDER REC >>>>>' + orderRec1);
        //System.assertEquals(null, orderRec1.Base_Subscription__c);
        
        //Create Order Line Item
        List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(1);
        for(Order_Line_Item__c orderline0 : orderline){
            orderline0.Order__c = orderRec[0].Id;
            orderline0.End_Date__c = Date.newInstance(2017, 04, 27);
            orderline0.Main_Package_ID__c = packageList[0].Id;
            orderline0.Term_Length__c = 0;
            orderline0.Main_Package_Period__c = 0;  
            orderline0.Asia1_Creation_Mode__c = 'Individual';
            //orderline0.Start_Date__c = Date.newInstance(2016, 04, 27);
            orderline0.Start_Date__c = ((date.today()-10).addMonths(1));
            orderline0.Term_is_discussed__c = false;
            orderline0.Is_Digital__c = TRUE;
            //orderline0.Promotion_ID__c = promoTmp.id;
            orderline0.Penalty_Charge__c = 100;
            orderline0.New_Contract_Period__c = 1;
            orderline0.Main_Package_Subscription_Rate__c = 100;
            orderline0.Qty__c = 1;
            //orderline0.Main_Package_ID__c
            orderline0.Main_Package_Billing_Type__c = 'Full Prepaid';
            orderline0.Main_Package_Frequency__c = 'Default';
            orderline0.Main_Package_Sub_Type__c = 'Single';
            orderline0.Main_Package_Type__c = 'Base';
            orderline0.Is_Digital__c = true;
            orderline0.Subscribed_as__c = 'New Buy';
        }
    
        insert orderline;
        
        //Create Promo
        promoRec = TestDataFactory.createPromotion(1)[0]; 
        promoRec.Name = 'Promotions';
        promoRec.Contract_Period__c ='12';
        promoRec.Penalty_Charge__c = '100'; 
        promoRec.Maximum_No_of_gifts_allowed__c = '5';
        
        insert promoRec;
        
        //Create Promotion Gift
        promoGiftRec = TestDataFactory.createPromotionGift(1)[0];
        promoGiftRec.Promotion__c = promoRec.Id;
         
        insert promoGiftRec;
        
        //Create Order Line Item Gift
        oliGiftList = TestDataFactory.createItemGift(5);
        for(Order_Line_Item_Gift__c olig : oliGiftList) {
            olig.Order_Line_Item__c = orderline[0].id;
            olig.Promotion_Gift__c = promoGiftRec.id;
        }
        //???
        insert oliGiftList;
        
        
        //test.startTest();
        PageReference pageRef = Page.SM_RenewalOfSubscriptionDetail;
        system.test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(orderRec[0].Id));
        pageRef.getParameters().put('accountId',  accList[0].Id);
        SM_RenewalOfSubscriptionDetailController controller = new SM_RenewalOfSubscriptionDetailController();
        controller.retrieveOrder();
        controller.retrieveActiveSubscriptions();
        controller.retrieveOrderLineItems();
        controller.retrieveOrderLineItem();
        
        Order__c orderRecord = [SELECT Id, Name FROM Order__c WHERE Id = :orderRec[0].Id LIMIT 1];
        orderRecord.Status__c = 'Void';
        update orderRecord;
        
        controller.void();
        controller.edit();
        try{
            controller.submit();
        }catch(Exception e){
            System.debug('Error ' + e);
        }
        //test.stopTest();
    }
    
    static testMethod void nullOrderPrep(){
        
        //test.startTest();
        try{
            PageReference pageRef = Page.SM_RenewalOfSubscriptionDetail;
            system.test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', null);
            //pageRef.getParameters().put('accountId', null);
            SM_RenewalOfSubscriptionDetailController controller = new SM_RenewalOfSubscriptionDetailController();
            controller.retrieveOrder();
            //controller.retrieveActiveSubscriptions();
            //test.stopTest();
        }catch(Exception e){
            System.debug('Error' + e);
        }
    }
    
     //Create Billing Account
    private static void setBillingAccount() {
        billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = accList[0].Id;
        billAcc.Name = 'TEST';     
        billAcc.Zuora__Credit_Balance__c = 0;
        billAcc.Payment_Mode__c = 'Cash';
        billAcc.Billing_Type__c = 'Full Prepaid';
        billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
  
        insert billAcc;
    }
}