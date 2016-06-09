/**
 * Class Name: MigrationNewSubsTriggerHandlerTest
 * @author: April Veloso
 * Date: 8/26/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description: Test Class for MigrationNewSubscriptionTriggerHandler
 */

@isTest(seeAllData = True)
public with sharing class MigrationNewSubsTriggerHandlerTest{

    static testmethod void test(){
            
            //create values
           
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.RecordTypeId = ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division');
            insert acc;
                                  
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.Recipient_Indicator__c = true;
            insert con;
            
             
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].name = 'April Summer';
            //billAccountList [0].id = zInv.id;
            billAccountList[0].Zuora__Account__c = acc.id; 
            billAccountList[0].Billing_Contact__c = con.id;
            billAccountList[0].ARMS_Account_Number__c = '027101021';
            billAccountList[0].Other_PaymentMethod__c ='Invoice';
            billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
            billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
            billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
            billAccountList[0].Payment_Mode__c = 'CREDITCARD';
            insert billAccountList;
                
    
            Package__c pack = TestDataFactory.createPackage(1)[0];
            insert pack;
    
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Subscriber_Charge__c = 100.00;
            insert order;
            
            
            Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
            orderLineItem.Order__c = order.id;
            orderLineItem.Main_Package_ID__c = pack.id;
            insert orderLineItem;
            
            List<Promotion__c> promotionList = TestDataFactory.createPromotion(1);
            promotionList[0].Contract_Period__c = '1';
            promotionList[0].Effective_End_Date__c = System.today().addDays(30);
            insert promotionList;
            
            List<Subscription_Vendor__c> subVen = TestDataFactory.createSubscriptionVendor(1);
            insert SubVen;
            
            List<Zuora__Subscription__c> zSubList = TestDataFactory.createSubscription(2);
            Integer i = 0;
            for(Zuora__Subscription__c zSub: zSubList)
            {
                zSub.Name = 'NUM124';
                zSub.Subscription_Type__c = 'Full Prepaid';
                zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
                zSub.Subscription_Type_1__c = 'Publication';
                zSub.Subscription_Type__c = 'Publication';
                zSub.Zuora__Account__c = acc.id;
                zSub.Zuora__Status__c = 'Active';
                zSub.Order_Line_Item_Number__c = orderLineItem.id;
                zSub.Order_Line_Item_Number_1__c = orderLineItem.id;
                zSub.Recipient_Contact__c = con.id;
                zSub.Order_Number_1__c= order.id;
                zSub.Order_Number__c = order.id;
                zSub.Zuora__SubscriptionEndDate__c = System.Today() + 1;
                zSub.Zuora__AutoRenew__c = False;
                zSub.Supressed_Renewal_and_Reminder_Letter_1__c = False;
                zSub.Number_of_Copies__c=100;
                zSub.Number_of_Copies1__c =  '100';
                zSub.Qty__c = 20;
                zSub.Zuora__Version__c = 8 + i;
                zSub.Addon_Package_1__c = pack.id;
                zSub.Billing_Type__c = 'Full Prepaid';
                zSub.Delivered_By_1__c = 'Vendor';
                zSub.Delivered_By__c = 'Vendor';
                zSub.Main_Package_1__c = pack.id;
                zSub.Main_Package__c = pack.id;
                zSub.Promotion_1__c = promotionList[0].id;
                zSub.Promotion__c = promotionList[0].id;
                zSub.Subscriber_Contact__c = con.id;
                zSub.Vendor_1__c = acc.id;
                zSub.Vendor_Subscription_To_Convert_1__c = SubVen[0].id;
                zSub.Legacy_Subscription_ID__c = 'AD1234';     
                i++;
            }
            database.insert(zSubList);
        	//database.update(zSubList[0]);
            test.startTest();
                        
            MigrationNewSubscriptionTriggerHandler testInstance = new MigrationNewSubscriptionTriggerHandler();
            
            testInstance.runBeforeInsertTrigger();
            testInstance.runBeforeUpdateTrigger();
            testInstance.runBeforeDeleteTrigger();
            testInstance.runAfterInsertTrigger();
            testInstance.runAfterUpdateTrigger();
            testInstance.runAfterDeleteTrigger();
            /*
        	testInstance.bulkBefore();       
            testInstance.beforeInsert(zSubList[0]);
            testInstance.beforeUpdate(zSubList[0], zSubList[0]);
            testInstance.beforeDelete(zSubList[0]);
            testInstance.afterInsert(zSubList[0]);
            */
        
            testInstance.afterDelete(zSubList[0]);
            try{
                testInstance.bulkAfter();
            }catch(Exception e){}           
                    
            try{
                testInstance.afterUpdate(zSubList[0], zSubList[1]);
            }catch(Exception e){}
            try{
                testInstance.andFinally();
            }catch(Exception e){}
            

             
            test.stopTest();
    
    }
    
    
}