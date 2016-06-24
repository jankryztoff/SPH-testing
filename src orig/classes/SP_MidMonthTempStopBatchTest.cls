/**
 * Class Name: <SP_MidMonthTempStopBatchTest>
 * @author: <JhustinPinoy>
 * Date: <9/27/2014>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for SP_MidMonthTempStopBatch>
 */

@isTest
public class SP_MidMonthTempStopBatchTest {
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther();
    }  
    
    static testMethod void testBatch(){
        
        //Create a new user with Standard User Profile
        User testUser = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_System Administrator'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );
        
        System.runAs(testUser) {
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert new List<sObject> {postal, acc, pack};
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            // START : CCB 002 12/2/2014 Edited By Alyana P. Navarro
            //con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Recipient Contact');
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            // END : CCB 002 12/2/2014
            insert con;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            insert orderRec;
            
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = orderRec.Id;
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(4);
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                subRec.Name = 'test';
                subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRec.Subscriber_Contact__c = con.Id;
                subRec.Recipient_Contact__c = con.Id;
                subRec.Main_Package_1__c = pack.id;
                subRec.Zuora__Status__c = 'Active';
                subRec.Order_Number__c = orderRec.Id;
                subRec.Suppress_Vendor_Start_Notice__c = 'false';
                subRec.Supressed_Acknowledgement_Letter__c = 'false';
                subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec.Urgent__c = 'false';
                subRec.Vendor_Conversion__c = 'false';
                subRec.Charity__c = 'false';
                //jess added this
                subRec.Zuora__SubscriptionStartDate__c = Date.Today();
                

            }
            subRecs[0].Billing_Type__c = 'Full Prepaid';
            subRecs[1].Billing_Type__c = 'Recurring Prepaid';
            subRecs[2].Billing_Type__c = 'Full Prepaid';
            subRecs[3].Billing_Type__c = 'Recurring Prepaid';
            
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.newInstance(2014, 12, 2);
            orderline.Main_Package_ID__c = pack.Id;
            //insert new List<sObject>{cas, subrecs[0], subrecs[1], subrecs[2], subrecs[3], orderline};
                
            //----Jess Added this
            //
            //adding Billing Contact Records
            Zuora__CustomerAccount__c billingAccountList = TestDataFactory.createBillingAccount(1)[0];
            billingAccountList.Zuora__Account__c = acc.id;
            billingAccountList.Zuora__AccountNumber__c = 'BA-00000141';
            insert billingAccountList;
                
            Zuora__Subscription__c subRecord = TestDataFactory.createSubscription(1)[0];
            subRecord.Zuora__Account__c = acc.Id;
            subRecord.Zuora__CustomerAccount__c = billingAccountList.Id;
            subRecord.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
            subRecord.Subscriber_Contact__c = con.Id;
            subRecord.Recipient_Contact__c = con.Id;
            subRecord.Main_Package_1__c = pack.id;
            subRecord.Zuora__Status__c = 'Active';
            subRecord.Order_Number__c = orderRec.Id;
            subRecord.Suppress_Vendor_Start_Notice__c = 'false';
            subRecord.Supressed_Acknowledgement_Letter__c = 'false';
            subRecord.Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecord.Urgent__c = 'false';
            subRecord.Vendor_Conversion__c = 'false';
            subRecord.Charity__c = 'false';
            subRecord.Billing_Type__c = 'Full Prepaid';
            insert subRecord;

            
            
            
            List<Zuora__SubscriptionProductCharge__c> zspc = new List <Zuora__SubscriptionProductCharge__c>{
            new Zuora__SubscriptionProductCharge__c( 
            Zuora__Subscription__c = subRecs[0].id,
            Zuora__Type__c = 'One-Time',
            Zuora__UOM__c ='Credit Copy Mon',
            Zuora__RatePlanName__c = 'Test Product Rate Plan',
            Zuora__Quantity__c = 2,
            Zuora__ProductSKU__c = 'SKU-00000083',
            Zuora__ChargeNumber__c = 'C-00000434')
            };
            
            insert zspc; 
 
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.Name = 'test';
            zProduct.zqu__SKU__c = 'SKU-00000100';
            insert zProduct;
                
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.Name = 'testing';
            prdRatePlan.SubscriptionFrequency__c = '2';
            insert prdRatePlan;
            
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id; 
            prpc.Name = 'try';
            prpc.PublicationCode__c = 'ST'; 
            insert prpc;
            
            
            List <Publication__c> newPubs = TestDataFactory.createPublication(4);
            for (Publication__c newPub : newPubs) {
            
            newPub.Earliest_Start_Date__c = Date.Today();
            newPub.Publication_Code__c = 'PUB1';
            newPub.Published_Days__c = '2';
            newPub.Publication_Type__c = 'N';
            //Sunday_Publication__c = newPub.Id
            
            }
            
            newPubs[0].Sunday_Publication__c = newPubs[0].Id;
            //insert new List<sObject>{newPubs[0]};
            
            //newPub.Sunday_Publication__c = newPub[0].Id;
            //update newPub;
            
            List<Publication_Price__c> PubPrice = new List <Publication_Price__c>{
            new Publication_Price__c(
            Cover_Price__c = 12,
            Day_of_Week__c = 'Tuesday',
            Publication_Code__c = 'code'  
            )};
            //insert PubPrice;
            
            List<Non_Publication_Day__c> nonPub = new List <Non_Publication_Day__c>{
            new Non_Publication_Day__c (
            //Publication__c = newPubs[0].Id,
            Publication_Code__c = 'test',
            Non_Publication_Date__c = Date.Today()
            )};
            //insert nonPub;
            
            /*Temp_Stop__c tempStop = new Temp_Stop__c();
            tempStop.Temp_Stop_Date__c = ;
            tempStop.Temp_Stop_Qty__c=;
            tempStop.Restart_Date__c = THIS_MONTH*/
                

            //----------
            List<Temp_Stop__c> tempStops = new List<Temp_Stop__c>{
                new Temp_Stop__c(
                    Case__c = cas.Id,
                    Temp_Stop_Qty__c = 5,
                    Temp_Stop_Date__c = System.today(),
                    Restart_Date__c = System.today()
                )
            };
            //insert tempStops;
            
            /*
            List<Subscription_Temp_Stop__c> subTempStops = new List<Subscription_Temp_Stop__c>{
                new Subscription_Temp_Stop__c(
                    Subscription__c = subRecs[0].Id,
                    Temp_Stop__c = tempStops[0].Id
                )
            };
            
            insert subTempStops;
            */
            
            List<Usage__c> usageList = new List<Usage__c>();
            Set<Id> subIds = new Set<Id>(); 
            //Set<String> ratePlanCharges = new Set<String>();

            Map<Id, zqu__ProductRatePlanCharge__c> mapSubProdChargeIdToProdRatePlanCharge = new Map<Id, zqu__ProductRatePlanCharge__c>();
            //mapSubProdChargeIdToProdRatePlanCharge.put(zspc.Id, prpc);
            
            Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapSubsIdToSubProdCharges = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();
            Set<String> ratePlanCharges = new Set<String>();
            SP_ProrationUtility.populateSubscriptionToSpC(mapSubsIdToSubProdCharges, subRecs, ratePlanCharges, zspc); 

            Map<String, Publication__c> mapPubCodeToPublication = new Map<String, Publication__c>();          
            Map<String, Set<Date>> mapPubCodeToNonPubDates = new Map<String, Set<Date>>();   
            SP_ProrationUtility.populatePubCodeToPublication(mapPubCodeToPublication, newPubs);
            
            SP_ProrationUtility.populatePubCodeToNonPubDates(mapPubCodeToNonPubDates, nonPub);                    
                
            system.debug('>>>>>>>>>>>>>>>>>>>mapSubsIdToSubProdCharges ' + mapSubsIdToSubProdCharges);
            
            Test.startTest();
            
            SP_MidMonthTempStopBatch batch = new SP_MidMonthTempStopBatch();
            ID batchprocessid = Database.executeBatch(batch, 200);
            
            Test.stopTest();
        }
    }
    }