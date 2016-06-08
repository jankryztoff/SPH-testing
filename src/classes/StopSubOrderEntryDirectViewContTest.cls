/**
 * Class Name: <StopSubOrderEntryDirectViewController>
 * @author: <Jessica Palapal>
 * Date: <10/22/2014>
 * Requirement/Project Name: <SPH>
 * @description: Test Class for StopSubOrderEntryDirectViewController
 */
 
@isTest (Seealldata = TRUE)
public class StopSubOrderEntryDirectViewContTest{
    static testMethod void test(){
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
            
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            insert acc;

            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Package_Type__c = 'Base';
            insert pack;
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
            
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            insert prdRatePlan;
            
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.ARMS_Account_Type__c = 'Savings';
            billAcc.Zuora__PaymentMethodType__c = 'Check';
            billAcc.ARMS_Business_Profile__c = 'ARMS Business Profile';
            billAcc.ARMS_Debt_Management__c = 'picklist data type??';
            billAcc.Billing_Type__c = 'Prepaid';
            billAcc.ARMS_ID__c = '00002';
            billAcc.Zuora__AccountNumber__c = '12345667';
            billAcc.Zuora__BillToAddress1__c = 'Address1';
            billAcc.Zuora__BillToAddress2__c = 'Address2';
            billAcc.Zuora__BillToPostalCode__c = '1900';
            billAcc.Zuora__BillToCity__c = 'New York';
            billAcc.Zuora__BillToName__c = 'John Smith';
            insert billAcc;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            RecordType rt =[SELECT Name, ID FROM RecordType where id =: '012N00000008id4IAA'];
            //system.assertEquals(rt,null);
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            insert con;
            
            Contact con1 = TestDataFactory.createContact(1)[0];
            con1.Address__c = addressRec.Id;
            con1.AccountId = acc.Id;
            con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con1.Billing_Indicator__c = true;
            insert con1;
            
            Order__c order = TestDataFactory.createOrder(1)[0]; 
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            //order.Order_Type__c = 'Renewal';
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';      
            order.Billing_Account__c = billAcc.id;
            order.Billing_Type__c = 'Full Prepaid';
            order.Billing_Contact__c = con1.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';
            insert order;
            
                        
            Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
            cas.Order__c = order.Id;
            insert cas;
        
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.newInstance(2014, 12, 2);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            //orderline.Subscription__c = subRecs[0].id;
            orderline.Start_Date__c = date.Today().addDays(1);
            orderline.Earliest_Start_Date__c = date.today().addDays(1);
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.newInstance(2050, 12, 2);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            //orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            insert orderline;
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(1);
                subRecs[0].Zuora__Account__c = acc.Id;
                subRecs[0].Zuora__Zuora_Id__c = '1123';
                subRecs[0].Order_Line_Item_Number_1__c = orderline.Id;
                //subRecs[0].Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRecs[0].Subscriber_Contact__c = con.Id;
                subRecs[0].Zuora__CustomerAccount__c = billAcc.Id;
                subRecs[0].Recipient_Contact__c = con.Id;
                subRecs[0].Main_Package_1__c = pack.id;
                subRecs[0].Zuora__Status__c = 'Active';
                subRecs[0].Order_Number__c = order.Id;
                subRecs[0].Suppress_Vendor_Start_Notice__c = 'false';
                subRecs[0].Supressed_Acknowledgement_Letter__c = 'false';
                subRecs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs[0].Urgent__c = 'false';
                subRecs[0].Vendor_Conversion__c = 'false';
                subRecs[0].Charity__c = 'false';
                subRecs[0].Billing_Type__c = 'Full Prepaid';
                /*
                subRecs[1].Zuora__Account__c = acc.Id;
                subRecs[1].Zuora__Zuora_Id__c = '1123';
                subRecs[1].Zuora__CustomerAccount__c = billAcc.Id;
                subRecs[1].Order_Line_Item_Number_1__c = orderline.id;
                //subRecs[1].Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRecs[1].Subscriber_Contact__c = con.Id;
                subRecs[1].Recipient_Contact__c = con.Id;
                subRecs[1].Main_Package_1__c = pack.id;
                subRecs[1].Zuora__Status__c = 'Active';
                subRecs[1].Order_Number__c = order.Id;
                subRecs[1].Suppress_Vendor_Start_Notice__c = 'false';
                subRecs[1].Supressed_Acknowledgement_Letter__c = 'false';
                subRecs[1].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs[1].Urgent__c = 'false';
                subRecs[1].Vendor_Conversion__c = 'false';
                subRecs[1].Charity__c = 'false';
                subRecs[1].Billing_Type__c = 'Recurring Prepaid';
                
                subRecs[2].Zuora__Account__c = acc.Id;
                subRecs[2].Zuora__Zuora_Id__c = '1123';
                subRecs[2].Order_Line_Item_Number_1__c = orderline.id;
                subRecs[2].Zuora__CustomerAccount__c = billAcc.Id;
                //subRecs[2].Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRecs[2].Subscriber_Contact__c = con.Id;
                subRecs[2].Recipient_Contact__c = con.Id;
                subRecs[2].Main_Package_1__c = pack.id;
                subRecs[2].Zuora__Status__c = 'Active';
                subRecs[2].Order_Number__c = order.Id;
                subRecs[2].Suppress_Vendor_Start_Notice__c = 'false';
                subRecs[2].Supressed_Acknowledgement_Letter__c = 'false';
                subRecs[2].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs[2].Urgent__c = 'false';
                subRecs[2].Vendor_Conversion__c = 'false';
                subRecs[2].Charity__c = 'false';
                subRecs[2].Billing_Type__c = 'Full Prepaid';
                
                subRecs[3].Zuora__Account__c = acc.Id;
                subRecs[3].Zuora__Zuora_Id__c = '1123';
                subRecs[3].Order_Line_Item_Number_1__c = orderline.id;
                subRecs[3].Zuora__CustomerAccount__c = billAcc.Id;
                //subRecs[3].Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRecs[3].Subscriber_Contact__c = con.Id;
                subRecs[3].Recipient_Contact__c = con.Id;
                subRecs[3].Main_Package_1__c = pack.id;
                subRecs[3].Zuora__Status__c = 'Active';
                subRecs[3].Order_Number__c = order.Id;
                subRecs[3].Suppress_Vendor_Start_Notice__c = 'false';
                subRecs[3].Supressed_Acknowledgement_Letter__c = 'false';
                subRecs[3].Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRecs[3].Urgent__c = 'false';
                subRecs[3].Vendor_Conversion__c = 'false';
                subRecs[3].Charity__c = 'false';
                subRecs[3].Billing_Type__c = 'Recurring Prepaid';                
            insert subRecs;
            
            for (Zuora__Subscription__c subRec : subRecs) {
                subRec.Zuora__Account__c = acc.Id;
                subRec.Zuora__Zuora_Id__c = '1123';
                //subRec.Zuora__SubscriptionEndDate__c = date.newInstance(2014, 12, 2);
                subRec.Subscriber_Contact__c = con.Id;
                subRec.Recipient_Contact__c = con.Id;
                subRec.Main_Package_1__c = pack.id;
                subRec.Zuora__Status__c = 'Active';
                subRec.Order_Number__c = order.Id;
                subRec.Suppress_Vendor_Start_Notice__c = 'false';
                subRec.Supressed_Acknowledgement_Letter__c = 'false';
                subRec.Supressed_Renewal_and_Reminder_Letter__c = 'false';
                subRec.Urgent__c = 'false';
                subRec.Vendor_Conversion__c = 'false';
                subRec.Charity__c = 'false';
            }
            //subRecs[0].Billing_Type__c = 'Full Prepaid';
            //subRecs[1].Billing_Type__c = 'Recurring Prepaid';
            //subRecs[2].Billing_Type__c = 'Full Prepaid';
            //subRecs[3].Billing_Type__c = 'Recurring Prepaid';
            */   
            //insert new List<sObject>{cas, subrecs[0], subrecs[1], subrecs[2], subrecs[3]};
            
            List <Publication__c> pubList = new List <Publication__c>();
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = 'Test';
            pub.Publication_Code__c = 'PUB1';
            pub.Published_Days__c = 'YYYYNNY';
            pub.Publication_Type__c = 'M';
            pub.Publish_Pattern__c = 'Weekdays';
            //pubList.add(pub);
            insert pub;
            
            Publication__c npub = TestDataFactory.createPublication(1)[0];                                                     
            npub.Publication_Code__c = 'PUB1';
            npub.Published_Days__c = 'YYYYNNY';
            npub.Publication_Type__c = 'M';
            npub.Publish_Pattern__c = 'Weekdays';
            pubList.add(npub);
            //insert pubList;   
            insert npub;         
            
            List <Non_Publication_Day__c> nonPubList = new List <Non_Publication_Day__c>();
            Non_Publication_Day__c nonpub = new Non_Publication_Day__c();                                                     
            nonpub.Non_Publication_Date__c = date.today();
            nonpub.Publication_Code__c = 'PUB1';
            nonpub.Publication__c = npub.Id;
            nonPubList.add(nonpub);
            insert nonPubList;        
            
            Service_Access_Flag__c SAF = TestDataFactory.createServiceAccessFlag(1)[0];
            SAF.Flag_Code__c = 'TEST';
            SAF.Flag_Description__c = 'TESTx';
            insert SAF;
            
            Package_Access_Flag__c PAF = TestDataFactory.createPackageAccessFlag(1)[0];
            PAF.Package__c = pack.Id;
            PAF.No_of_Concurrent_Users__c = 2;
            PAF.Package_Service_Access_Flag__c = SAF.Id;
            //insert PAF;
            
            //create Asia1__c
            Asia1__c tmpAsia1 = TestDataFactory.createAsiaOne(1)[0];
            tmpAsia1.User_ID_LDAP_ID__c = 'xxxxx@xxxx.xxxx';
            tmpAsia1.Display_Name__c = 'Test';
            tmpAsia1.Email__c = 'test@email.com' ;
            tmpAsia1.Password__c = 'aBcD3Fg';
            tmpAsia1.Contact__c = con.Id;
            insert tmpAsia1;
            
            //insert new List<sObject>{nonPubList, tmpAsia1};
            
            /*List<Asia1_Subscription__c> asiaSubList = TestDataFactory.createAsiaOneSubscription(1);
            
            asiaSubList[0].Asia1__c = tmpAsia1.Id;
            asiaSubList[0].Subscription__c = SubRecs[0].Id;
            asiaSubList[0].Status__c = 'Enabled';
            asiaSubList[0].Order_Line_Item__c = orderline.Id;
            asiaSubList[0].Service_Access_Flag__c = SAF.Id;*/
            //insert asiaSubList;      
           
                
            Test.startTest();
            PageReference pRef = Page.StopSub_Order_Entry_Direct_View;
            //Test.setCurrentPageReference(pRef);
            Test.setCurrentPage(pRef);
                
            ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ORDERID, order.Id);
            ApexPages.currentPage().getParameters().put(GlobalVariableClass.PARAMETER_ACCOUNTID, acc.Id);
            //ApexPages.currentPage().getParameters().put('Id', orderline.Id);  
            ApexPages.currentPage().getParameters().put('def_parent_id', orderline.Id);
             
              /*ApexPages.StandardController stdController = new ApexPages.Standardcontroller(new case());*/
            StopSubOrderEntryDirectViewController STOPSUB = new StopSubOrderEntryDirectViewController();
            //STOPSUB.getAccount();
            //STOPSUB.cancelSubscription();
            //STOPSUB.getCase();
            //STOPSUB.getOrder();
            
            //STOPSUB.getOrderLineItem();
            
            /*StopSubOrderEntryDirectViewController getCase;
            StopSubOrderEntryDirectViewController getOrderLineItem;
            //StopSubOrderEntryDirectViewController getRelatedAsiaSubscription;
            StopSubOrderEntryDirectViewController voidStatus;
            StopSubOrderEntryDirectViewController CancelSubscription;
            StopSubOrderEntryDirectViewController validateVoid;*/
                
    
           Test.stopTest();
        
    }
}