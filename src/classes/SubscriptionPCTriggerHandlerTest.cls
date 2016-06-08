/**
 * Class Name: <SubscriptionPCTriggHandlerTest>
 * @author: <KarlTan>
 * Date: <8/30/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for SubscriptionProductChargeTriggerHandler>
 */

@isTest (seeAllData= True)
public class SubscriptionPCTriggerHandlerTest {


    ///static Account acc;    
    static testMethod void testPopulateProductCode(){
        
        //Create a new user with Standard User Profile

        User u = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
            );
        
      //  System.assertEquals('', String.valueOf(u));

        //The test will run as the user created.
        System.runAs(u) {
            //
            
            List<zqu__ZProduct__c> zProd = TestDataFactory.createZProduct(1);
            zProd[0].zqu__SKU__c = 'SKU-0000075';
            zProd[0].ProductCode__c = 'STUT';
            insert zProd;
            
            List<zqu__ProductRatePlan__c> zProdRP = TestDataFactory.createProductRatePlan(1);
            zProdRP[0].zqu__ZProduct__c = zProd[0].id;
            insert zProdRP;
            
            Account acc = new Account(Name = 'Test Account', RecordTypeId = ConstantsSLB.getKeyId('Account_Direct Corporate'));
            acc.Email__c = 'test@test.com';
            insert acc;
            
            List<Contact> con = TestDataFactory.createContact(1);
            // START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
            //con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
            con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con[0].Recipient_Indicator__c = true;
            // END : CCB 002 12/2/2014
            con[0].Phone = '1234567';
            con[0].AccountId = acc.Id;
            insert con;
            
            List<Package__c> pkg = TestDataFactory.createPackage(1);
            pkg[0].Subscription_Period__c = '15'; 
            insert pkg;
            
            //create order
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Recipient_Contact__c = con[0].Id;
            order.Informed_Customer__c = True;
            insert order;
            
            //create case
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = order.Id;
            insert cas;         


            List<Zuora__Subscription__c> zSubs =  TestDataFactory.createSubscription(1);
            zSubs[0].Order_Number__c = order.Id;
            zSubs[0].Subscriber_Contact__c = con[0].id;
            zSubs[0].Main_Package_1__c = pkg[0].id;
            zSubs[0].Zuora__Account__c = acc.id;
            zSubs[0].Suppress_Vendor_Start_Notice__c = 'false';
            zSubs[0].Supressed_Acknowledgement_Letter__c = 'false';
            zSubs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            zSubs[0].Urgent__c = 'false';
            zSubs[0].Vendor_Conversion__c = 'false';
            zSubs[0].Charity__c = 'false';
            try{
            insert zSubs;            
            }catch(Exception e){}          
       
            List<Zuora__SubscriptionProductCharge__c> zSubProdCharge = TestDataFactory.createSubProductCharge(1);
            zSubProdCharge[0].Zuora__ProductSKU__c = 'SKU-0000075';
            zSubProdCharge[0].Zuora__Subscription__c = zSubs[0].id;
            insert zSubProdCharge;
            
            zSubProdCharge[0].Product_Code__c = 'STUT';           
            update zSubProdCharge;
            
        }           
    }
    
}