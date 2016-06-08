/**
 * Class Name: SM_COSDetailControllerTest
 * @author: Kristine Joyce Balaoing
 * Date: 04/08/2016
 * Requirement/Project Name: Singapore Press Holdings
 * @description Test Class for SM_ChangeOfSubscriptionDetailController
 *
 */
 @isTest
public class SM_COSDetailControllerTest{
    
    //Test Data
    static Account acc;
    static List<Account> accList;
    static List<Order__c> orderRec;
    static List<Order_Line_Item__c> oliList;
    static List<Zuora__Subscription__c> zuoSubList;
    static Other__c otherC;
    static Zuora__CustomerAccount__c  billAcc;
    static Zuora__CustomerAccount__c billAcc2;
    static List<Package__c> packageList;
    static List<Account> accList2;
    static Promotion__c promoRec;
    static Promotion_Gift__c  promoGiftRec;
    static List<Order_Line_Item_Gift__c> oliGiftList;
    static Key_Id__c keyId;
    static Order__c orderRecord;
    static  Asia1_Subscription__c asia1Sub;
    static List<Asia1__c> asiaOneList;
    static Contact con;
    //static PageReference pageRef;
    
    static testMethod void orderPreparation(){
        
        //Account
        setAccount();
        
        //BA
        setBillingAccount();

        //Create Contact
        setContact();
        
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
        
        setPackage();
        //Vendor Account
        accList2 = TestDataFactory.createAccount(1, 'Mailing Agent');
        accList2[0].NRIC__c = 'T1234532';
        insert accList2;

        
        //Subs from Start
        zuoSubList = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c zSub : zuoSubList){
            zSub.Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
            zSub.Recipient_Contact__c= con.Id;
            zSub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
            //zuoSubList[0].Vendor__c = accList[0].Id;
            zSub.Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
            //zSub.Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
            zSub.Zuora__SubscriptionStartDate__c = date.today()-10;
            zSub.Zuora__SubscriptionEndDate__c = date.today()+10;
            zSub.Subscription_End_Date__c = string.valueof(date.today()+10);
            zSub.Main_Package__c = packageList[0].Id;
            zSub.Zuora__CustomerAccount__c = billAcc.id;
            zSub.Zuora__Account__c = accList[0].id;
            zSub.Subscriber_Contact__c= con.Id;
            zSub.Delivered_By__c = 'Mailing Agent';
            zSub.Delivered_By_1__c = 'Mailing Agent';
            zSub.Term_Length__c = 1;
            zSub.Term_Length1__c = '1';
            zSub.Vendor_1__c = accList2[0].Id;
            zSub.Product_Code__c = 'STSU';
            //zSub.Number_of_Copies__c = 1;
            zSub.Qty__c = 1;
            zSub.Qty1__c ='1';
        }
        insert zuoSubList;
        
        asiaOneList = TestDataFactory.createAsiaOne(1);
        insert asiaOneList;
        
        asia1Sub = new Asia1_Subscription__c();
        asia1Sub.Subscription__c = zuoSubList[0].Id;
        asia1Sub.Asia1__c =asiaOneList[0].Id;
        insert asia1Sub;
        //Order
        orderRec = TestDataFactory.createOrder(1);
        orderRec[0].Account__c = accList[0].Id;
        orderRec[0].Subscription__c = zuoSubList[0].Id;
        orderRec[0].Base_Subscription__c = zuoSubList[1].Id;
        orderRec[0].Order_Type1__c = 'Change of Subscription Package';
        orderRec[0].Status__c = 'Draft';
        orderRec[0].Billing_Type__c = 'Full Prepaid';
        insert orderRec;
        
        orderRecord = [SELECT Id, Account__c, Subscription__c, Base_Subscription__c, Order_Type1__c, Status__c, Billing_Type__c FROM Order__c WHERE Id = :orderRec[0].Id LIMIT 1];
        /*
        Zuora__Subscription__c zSubRecForUpdate = [SELECT Id, Billing_Type__c, Recipient_Contact__c, Subscription_Type__c, Zuora__Status__c,        Zuora__SubscriptionStartDate__c, Main_Package__c,Zuora__CustomerAccount__c, Zuora__Account__c, Subscriber_Contact__c, Delivered_By__c,  Delivered_By_1__c, Term_Length__c, Term_Length1__c, Vendor_1__c, Product_Code__c, Number_of_Copies__c FROM Zuora__Subscription__c WHERE Id =:zuoSubList[1].Id LIMIT 1];*/
        
        for(Zuora__Subscription__c sub : zuoSubList){
            sub.Order_Number__c = orderRec[0].Id;
            sub.Order_Number_1__c = orderRec[0].Id;
        }
        update zuoSubList;
        /*
        zuoSubList[1].Order_Number__c = orderRec[0].Id;
        zuoSubList[1].Order_Number_1__c = orderRec[0].Id;
        update zuoSubList[1];
        */
        
        
        //Order__c orderRecord = [SELECT Id, Account__c, Subscription__c, Base_Subscription__c, Order_Type1__c, Status__c FROM Order__c WHERE Id = :order]
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

        insert oliGiftList;
        
        //test.startTest();
        PageReference pageRef = Page.SM_ChangeOfSubscriptionDetail;
        system.test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(orderRec[0].Id));
        pageRef.getParameters().put('accountId',  accList[0].Id);
        SM_ChangeOfSubscriptionDetailController  controller = new SM_ChangeOfSubscriptionDetailController ();
        controller.retrieveOrder();
        controller.creditBalance(orderRecord.Id);
        controller.getUserIdDisableSvcInAsia1(zuoSubList[0].Id);
        controller.submit();
        controller.edit();
        controller.void();
        controller.doCancel();
        //controller.retrieveActiveSubscriptions();
        //controller.retrieveOrderLineItems();
        //controller.retrieveOrderLineItem();
    }
    
    static testMethod void errorInRetrieveOrder(){
        
        //Account
        accList = TestDataFactory.createAccount(1, 'Direct Individual');
        insert accList;
        
        //Order
        orderRec = TestDataFactory.createOrder(1);
        orderRec[0].Account__c = accList[0].Id;
        //orderRec[0].Base_Subscription__c = null;
        orderRec[0].Order_Type1__c = 'Change of Subscription Package';
        orderRec[0].Status__c = 'Draft';
        insert orderRec;
        
        try{
            PageReference pageRef = Page.SM_ChangeOfSubscriptionDetail;
            system.test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', orderRec[0].Id);
            pageRef.getParameters().put('accountId', accList[0].Id);
            SM_ChangeOfSubscriptionDetailController controller = new SM_ChangeOfSubscriptionDetailController();
            controller.retrieveOrder();
            controller.void();
            //controller.retrieveActiveSubscriptions();
            //test.stopTest();
        }catch(Exception e){
            System.debug('Error' + e);
        }
    }
    
    static testMethod void nullOrderPrep(){
        
        //Account
        accList = TestDataFactory.createAccount(1, 'Direct Individual');
        insert accList;
        
        
        try{
            PageReference pageRef = Page.SM_ChangeOfSubscriptionDetail;
            system.test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', null);
            pageRef.getParameters().put('accountId', accList[0].Id);
            SM_ChangeOfSubscriptionDetailController controller = new SM_ChangeOfSubscriptionDetailController();
            controller.retrieveOrder();
            controller.submit();
            controller.void();
            //controller.retrieveActiveSubscriptions();
            //test.stopTest();
        }catch(Exception e){
            System.debug('Error' + e);
        }
    }
    
    static testMethod void creditBalancePrep(){
        
        //Account
        setAccount();
        
        //BA
        billAcc2 = TestDataFactory.createBillingAccount(1)[0];
        billAcc2.Zuora__Account__c = accList[0].Id;
        billAcc2.Name = 'TEST';     
        billAcc2.Zuora__Credit_Balance__c = 20;
        billAcc2.Payment_Mode__c = 'Cash';
        billAcc2.Billing_Type__c = 'Full Prepaid';
        billAcc2.Zuora__DefaultPaymentMethod__c = 'Other';

        insert billAcc2;

        //Create Contact
        setContact();
        
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
        
        setPackage();
        //Vendor Account
        accList2 = TestDataFactory.createAccount(1, 'Mailing Agent');
        accList2[0].NRIC__c = 'T1234532';
        insert accList2;

        
        //Subs from Start
        zuoSubList = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c zSub : zuoSubList){
            zSub.Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
            zSub.Recipient_Contact__c= con.Id;
            zSub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
            //zuoSubList[0].Vendor__c = accList[0].Id;
            zSub.Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
            //zSub.Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
            zSub.Zuora__SubscriptionStartDate__c = date.today()-10;
            zSub.Zuora__SubscriptionEndDate__c = date.today()+10;
            zSub.Subscription_End_Date__c = string.valueof(date.today()+10);
            zSub.Main_Package__c = packageList[0].Id;
            zSub.Zuora__CustomerAccount__c = billAcc2.id;
            zSub.Zuora__Account__c = accList[0].id;
            zSub.Subscriber_Contact__c= con.Id;
            zSub.Delivered_By__c = 'Mailing Agent';
            zSub.Delivered_By_1__c = 'Mailing Agent';
            zSub.Term_Length__c = 1;
            zSub.Term_Length1__c = '1';
            zSub.Vendor_1__c = accList2[0].Id;
            zSub.Product_Code__c = 'STSU';
            //zSub.Number_of_Copies__c = 1;
            zSub.Qty__c = 1;
            zSub.Qty1__c ='1';
        }
        insert zuoSubList;
        
        asiaOneList = TestDataFactory.createAsiaOne(1);
        insert asiaOneList;
        
        asia1Sub = new Asia1_Subscription__c();
        asia1Sub.Subscription__c = zuoSubList[0].Id;
        asia1Sub.Asia1__c = asiaOneList[0].Id;
        insert asia1Sub;
        //Order
        orderRec = TestDataFactory.createOrder(1);
        orderRec[0].Account__c = accList[0].Id;
        orderRec[0].Subscription__c = zuoSubList[0].Id;
        orderRec[0].Base_Subscription__c = zuoSubList[1].Id;
        orderRec[0].Order_Type1__c = 'Change of Subscription Package';
        orderRec[0].Status__c = 'Draft';
        orderRec[0].Billing_Type__c = 'Full Prepaid';
        //orderRec[0].COS_Urgent_Request__c = true;
        insert orderRec;
        
        orderRecord = [SELECT Id, Account__c, Subscription__c, Base_Subscription__c, Order_Type1__c, Status__c, Billing_Type__c FROM Order__c WHERE Id = :orderRec[0].Id LIMIT 1];
        /*
        Zuora__Subscription__c zSubRecForUpdate = [SELECT Id, Billing_Type__c, Recipient_Contact__c, Subscription_Type__c, Zuora__Status__c,        Zuora__SubscriptionStartDate__c, Main_Package__c,Zuora__CustomerAccount__c, Zuora__Account__c, Subscriber_Contact__c, Delivered_By__c,  Delivered_By_1__c, Term_Length__c, Term_Length1__c, Vendor_1__c, Product_Code__c, Number_of_Copies__c FROM Zuora__Subscription__c WHERE Id =:zuoSubList[1].Id LIMIT 1];*/
        
        for(Zuora__Subscription__c sub : zuoSubList){
            sub.Order_Number__c = orderRec[0].Id;
            sub.Order_Number_1__c = orderRec[0].Id;
        }
        update zuoSubList;
        
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
            //orderline0.Urgent__c = true;
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

        insert oliGiftList;
        
        try{
            PageReference pageRef = Page.SM_ChangeOfSubscriptionDetail;
            system.test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', String.valueOf(orderRec[0].Id));
            pageRef.getParameters().put('accountId',  accList[0].Id);
            SM_ChangeOfSubscriptionDetailController  controller = new SM_ChangeOfSubscriptionDetailController ();
            controller.retrieveOrder();
            controller.creditBalance(orderRec[0].Id);
            controller.submit();
            controller.edit();
            controller.void();
            controller.doCancel();
        }catch(Exception e){
            System.debug('Error>>> ' + e);
        }
    }
    
    static testMethod void urgentDataPrep(){
        
        //Account
        setAccount();
        
        //BA
        billAcc2 = TestDataFactory.createBillingAccount(1)[0];
        billAcc2.Zuora__Account__c = accList[0].Id;
        billAcc2.Name = 'TEST';     
        billAcc2.Zuora__Credit_Balance__c = 20;
        billAcc2.Payment_Mode__c = 'Cash';
        billAcc2.Billing_Type__c = 'Full Prepaid';
        billAcc2.Zuora__DefaultPaymentMethod__c = 'Other';

        insert billAcc2;

        //Create Contact
        setContact();
        
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
        
        setPackage();
        //Vendor Account
        accList2 = TestDataFactory.createAccount(1, 'Mailing Agent');
        accList2[0].NRIC__c = 'T1234532';
        insert accList2;

        
        //Subs from Start
        zuoSubList = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c zSub : zuoSubList){
            zSub.Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
            zSub.Recipient_Contact__c= con.Id;
            zSub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
            //zuoSubList[0].Vendor__c = accList[0].Id;
            zSub.Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
            //zSub.Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
            zSub.Zuora__SubscriptionStartDate__c = date.today()-10;
            zSub.Zuora__SubscriptionEndDate__c = date.today()+10;
            zSub.Subscription_End_Date__c = string.valueof(date.today()+10);
            zSub.Main_Package__c = packageList[0].Id;
            zSub.Zuora__CustomerAccount__c = billAcc2.id;
            zSub.Zuora__Account__c = accList[0].id;
            zSub.Subscriber_Contact__c= con.Id;
            zSub.Delivered_By__c = 'Mailing Agent';
            zSub.Delivered_By_1__c = 'Mailing Agent';
            zSub.Term_Length__c = 1;
            zSub.Term_Length1__c = '1';
            zSub.Vendor_1__c = accList2[0].Id;
            zSub.Product_Code__c = 'STSU';
            //zSub.Number_of_Copies__c = 1;
            zSub.Qty__c = 1;
            zSub.Qty1__c ='1';
        }
        insert zuoSubList;

        //Order
        orderRec = TestDataFactory.createOrder(1);
        orderRec[0].Account__c = accList[0].Id;
        orderRec[0].Subscription__c = zuoSubList[0].Id;
        orderRec[0].Base_Subscription__c = zuoSubList[1].Id;
        orderRec[0].Order_Type1__c = 'Change of Subscription Package';
        orderRec[0].Status__c = 'Draft';
        orderRec[0].Billing_Type__c = 'Full Prepaid';
        orderRec[0].COS_Urgent_Request__c = true;
        insert orderRec;
        
        orderRecord = [SELECT Id, Account__c, Subscription__c, Base_Subscription__c, Order_Type1__c, Status__c, Billing_Type__c FROM Order__c WHERE Id = :orderRec[0].Id LIMIT 1];
        /*
        Zuora__Subscription__c zSubRecForUpdate = [SELECT Id, Billing_Type__c, Recipient_Contact__c, Subscription_Type__c, Zuora__Status__c,        Zuora__SubscriptionStartDate__c, Main_Package__c,Zuora__CustomerAccount__c, Zuora__Account__c, Subscriber_Contact__c, Delivered_By__c,  Delivered_By_1__c, Term_Length__c, Term_Length1__c, Vendor_1__c, Product_Code__c, Number_of_Copies__c FROM Zuora__Subscription__c WHERE Id =:zuoSubList[1].Id LIMIT 1];*/
        
        for(Zuora__Subscription__c sub : zuoSubList){
            sub.Order_Number__c = orderRec[0].Id;
            sub.Order_Number_1__c = orderRec[0].Id;
        }
        update zuoSubList;
        /*
        zuoSubList[1].Order_Number__c = orderRec[0].Id;
        zuoSubList[1].Order_Number_1__c = orderRec[0].Id;
        update zuoSubList[1];
        */
        
        
        //Order__c orderRecord = [SELECT Id, Account__c, Subscription__c, Base_Subscription__c, Order_Type1__c, Status__c FROM Order__c WHERE Id = :order]
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
            orderline0.Earliest_Start_Date__c = (date.today()).addMonths(2);
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
            //orderline0.Urgent__c = true;
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

        insert oliGiftList;
        
        try{
            PageReference pageRef = Page.SM_ChangeOfSubscriptionDetail;
            system.test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', String.valueOf(orderRec[0].Id));
            pageRef.getParameters().put('accountId',  accList[0].Id);
            SM_ChangeOfSubscriptionDetailController  controller = new SM_ChangeOfSubscriptionDetailController ();
            controller.retrieveOrder();
            controller.creditBalance(orderRec[0].Id);
        }catch(Exception e){
            System.debug('Error>>> ' + e);
        }
    }
    
    static testMethod void negativeTestMethod(){
        
        //Account
        accList = TestDataFactory.createAccount(1, 'Direct Individual');
        insert accList;
        
        
        try{
            PageReference pageRef = Page.SM_ChangeOfSubscriptionDetail;
            system.test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', null);
            pageRef.getParameters().put('accountId', accList[0].Id);
            SM_ChangeOfSubscriptionDetailController controller = new SM_ChangeOfSubscriptionDetailController();
            controller.retrieveOrder();
            //controller.submit();
            //controller.void();
            //controller.retrieveActiveSubscriptions();
            //controller.subscriptionDetails(null);
            controller.getUserIdDisableSvcInAsia1(null);
        }catch(Exception e){
            System.debug('Error' + e);
        }
    }
    
    static testMethod void waivedDataPrep(){
        //Account
        setAccount();
        
        //BA
        setBillingAccount();

        //Create Contact
        setContact();
        
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
        
        setPackage();
        //Vendor Account
        accList2 = TestDataFactory.createAccount(1, 'Mailing Agent');
        accList2[0].NRIC__c = 'T1234532';
        insert accList2;

        
        //Subs from Start
        zuoSubList = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c zSub : zuoSubList){
            zSub.Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
            zSub.Recipient_Contact__c= con.Id;
            zSub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION; 
            //zuoSubList[0].Vendor__c = accList[0].Id;
            zSub.Zuora__Status__c = GlobalVariableClass.ZUORA_STATUS_ACTIVE;
            //zSub.Billing_Type__c = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
            zSub.Zuora__SubscriptionStartDate__c = date.today()-10;
            zSub.Zuora__SubscriptionEndDate__c = date.today()+10;
            zSub.Subscription_End_Date__c = string.valueof(date.today()+10);
            zSub.Main_Package__c = packageList[0].Id;
            zSub.Zuora__CustomerAccount__c = billAcc.id;
            zSub.Zuora__Account__c = accList[0].id;
            zSub.Subscriber_Contact__c= con.Id;
            zSub.Delivered_By__c = 'Mailing Agent';
            zSub.Delivered_By_1__c = 'Mailing Agent';
            zSub.Term_Length__c = 1;
            zSub.Term_Length1__c = '1';
            zSub.Vendor_1__c = accList2[0].Id;
            zSub.Product_Code__c = 'STSU';
            //zSub.Number_of_Copies__c = 1;
            zSub.Qty__c = 1;
            zSub.Qty1__c ='1';
        }
        insert zuoSubList;
        
        asiaOneList = TestDataFactory.createAsiaOne(1);
        insert asiaOneList;
        
        asia1Sub = new Asia1_Subscription__c();
        asia1Sub.Subscription__c = zuoSubList[0].Id;
        asia1Sub.Asia1__c =asiaOneList[0].Id;
        insert asia1Sub;
        //Order
        orderRec = TestDataFactory.createOrder(1);
        orderRec[0].Account__c = accList[0].Id;
        orderRec[0].Subscription__c = zuoSubList[0].Id;
        orderRec[0].Base_Subscription__c = zuoSubList[1].Id;
        orderRec[0].Order_Type1__c = 'Change of Subscription Package';
        orderRec[0].Status__c = 'Draft';
        orderRec[0].Billing_Type__c = 'Full Prepaid';
        insert orderRec;
        
        orderRecord = [SELECT Id, Account__c, Subscription__c, Base_Subscription__c, Order_Type1__c, Status__c, Billing_Type__c FROM Order__c WHERE Id = :orderRec[0].Id LIMIT 1];

        
        for(Zuora__Subscription__c sub : zuoSubList){
            sub.Order_Number__c = orderRec[0].Id;
            sub.Order_Number_1__c = orderRec[0].Id;
        }
        update zuoSubList;

        
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
            orderline0.Fee_Waiver__c = true;
        }
    
        insert orderline;
        
        try{
            PageReference pageRef = Page.SM_ChangeOfSubscriptionDetail;
            system.test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', orderRec[0].Id);
            pageRef.getParameters().put('accountId', accList[0].Id);
            SM_ChangeOfSubscriptionDetailController controller = new SM_ChangeOfSubscriptionDetailController();
            controller.retrieveOrder();
            controller.submit();
        }catch(Exception e){
            System.debug('Error' + e);
        }
        
        
    }
    //Create Account 
    private static void setAccount(){
        accList = TestDataFactory.createAccount(1, 'Direct Individual');
        insert accList;
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
    
    //Create Contact
    private static void setContact(){
        //Create Contact
        con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        con.AccountId = accList[0].Id;
        con.Recipient_Indicator__c = true;
        insert con;
    }
    
    //Create Package 
    private static void setPackage(){
        //Main Package 
        packageList = TestDataFactory.createPackage(2);
        packageList[0].Package_Type__c = 'Base Product';                                  
        packageList[0].Billing_Type__c = 'Full Prepaid';
        insert packageList; 
    }
    
    
}