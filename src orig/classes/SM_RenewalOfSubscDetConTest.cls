@isTest(SeeAllData = true)
private class SM_RenewalOfSubscDetConTest {
    static testMethod void test(){
        Test.setMock(WebServiceMock.class, new zLoginMock());

        //Create Account a
        Account a = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            a.NRIC__c = 'T1234567R';
        insert a;
        
        //Create an Address record
        List<Address__c> addressList = TestDataFactory.createAddress(1);
          
        //create contact c
        Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = a.Id;
            con.Address__c = addressList[0].Id;
            con.Recipient_Indicator__c = true;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Phone = '123';
            con.HomePhone__c = '123';
            con.Mobile_Number__c = '123456789';
        insert con;
        
        //Create Billing Account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
            billAcc.Zuora__Account__c = a.Id;
            billAcc.Billing_Type__c = 'Full Prepaid';
            insert billAcc;
        
        //Create new Order order
        Order__c order = TestDataFactory.createOrder(1)[0];
            //order.Name = 'TestName';
            order.Account__c = a.id;
            order.Recipient_Contact__c = con.Id;
            order.Subscriber_Charge__c = 10.00;
            order.Delivery_Charge__c = 10.00;
            order.Billing_Account__c = billAcc.Id;
            order.Billing_Type__c = 'Full Prepaid';
            //order.Monthly_Delivery_Charge_for_Full_Payment__c = 12.00;
            //order.Credit_Balance__c = 1.00;
            //order.Informed_Customer__c = true;
            //order.Recipient_Contact__c = con.id;
            order.Order_Type__c = 'Change of Subscription Package';
            order.Status__c = 'Draft';
        insert order;

        //create package
        Package__c pack = TestDataFactory.createPackage(1)[0];
            pack.Package_Type__c = 'Base';             
            pack.Name = 'TestPackageName';
            pack.Subscription_Type__c = 'Termed';
            pack.Channel_Direct__c = true;
            pack.Channel_E_shop_overseas__c = true;
            pack.Channel_E_shop_private__c = true;
            pack.Channel_E_shop_public__c = true;
            //pack.Subscription_Period__c = '35';
            //pack.Package_Code__c = 'SamplePackageCode';
            pack.Effective_Start_Date__c = date.Today();
            pack.Effective_End_Date__c = date.Today() + 30;
        insert pack;
        
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
        insert prdRatePlan;
        
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            pItem.Package__c = pack.id;
            pItem.Product_Rate_Plan__c = prdRatePlan.id;
            pItem.Name = 'Test Pack Item';
        insert pItem; 
        
        Package_Access_Flag__c paf = testDataFactory.createPackageAccessFlag(1)[0];
            paf.Package__c = pack.Id;
        insert paf;            
        
        //Create order line item
        Order_Line_Item__c oli = TestDataFactory.createOrderLineItem(1)[0];
            //oli.Case__c = ca.id;
            //oli.Term_Length__c = 10;
            oli.Earliest_Start_Date__c = date.Today();
            oli.Start_Date__c = date.Today().addDays(2);
            oli.Main_Package_Period__c = 35;
            oli.Qty__c = 1;
            oli.Main_Package_ID__c = pack.id;
            oli.Delivered_By__c = 'Vendor'; 
            oli.Main_Package_Billing_Type__c = 'Full Prepaid';
            oli.Main_Package_Type__c = 'Base';
            oli.Main_Package_Frequency__c = 'Default';
            oli.Order__c = order.id;
        insert oli;                        
        
        //Create subscrption subs
        List<Zuora__Subscription__c> Subs = TestDataFactory.createSubscription(1);
            Subs[0].Zuora__Zuora_Id__c = '01254896';
            Subs[0].Zuora__Account__c = a.id;
            Subs[0].Order_Line_Item_Number__c = oli.Id;
            Subs[0].Order_Number__c = order.Id;
            Subs[0].Subscriber_Contact__c = con.Id;
            Subs[0].Recipient_Contact__c = con.Id;
            Subs[0].Main_Package_1__c = pack.id;
            Subs[0].Main_Package__c = pack.id;
            Subs[0].Suppress_Vendor_Start_Notice__c = 'false';
            Subs[0].Supressed_Acknowledgement_Letter__c = 'false';
            Subs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            Subs[0].Urgent__c = 'false';
            Subs[0].Vendor_Conversion__c = 'false';
            Subs[0].Charity__c = 'false';
            Subs[0].Subscription_Type__c = 'Publication';
            Subs[0].Zuora__Status__c= 'Active';
            Subs[0].Zuora__CustomerAccount__c = billAcc.id;
            Subs[0].Number_of_Copies1__c = '10';
            Subs[0].Zuora__SubscriptionEndDate__c = date.today().addDays(-1);
            Subs[0].Subscription_End_Date__c = 'date.today().addDays(-1)';
            Subs[0].Request_Expiration__c = true;
        try{
            Test.startTest(); 
                insert Subs; 
                        
                order.Base_Subscription__c = Subs[0].id;       
                update order;
                
                Asia1__c asia = TestDataFactory.createAsiaOne(1)[0];
                    asia.Contact__c = order.Recipient_Contact__c;
                    asia.Status__c = 'Pending Creation';
                    asia.Order_Number__c = [SELECT Name From Order__c WHERE Id =: Order.Id].Name;
                    asia.Display_Name__c = 'Asia-1';
                    asia.User_ID_LDAP_ID__c = 'test1@sample.com';
                    asia.Password__c = 'password';
                insert asia;

                Asia1_Subscription__c as1 = TestDataFactory.createAsiaOneSubscription(1)[0];
                    as1.Order_Line_Item__c = oli.id;
                    as1.Asia1__c = asia.id;
                insert as1;
                
                //System.assertNotEquals(null, order.Subscription__c);
                //Set current page parameters           
                //PageReference pageref = new Pagereference('/apex/SM_RenewalOfSubscriptionEntry?id=' + order.Id + '&accountId=' + order.Account__c);
                PageReference pageref = Page.SM_RenewalOfSubscriptionDetail;//
                Test.setCurrentPage(pageref);//
                ApexPages.currentPage().getParameters().put('Id', order.Id);//
                ApexPages.currentPage().getParameters().put('accountId', a.Id);// 
                   
                SM_RenewalOfSubscriptionDetailController controller = new SM_RenewalOfSubscriptionDetailController();
                controller.dtlDate = Date.today();//
                controller.thisOrder = order;
                controller.subscriptionList = Subs;
                controller.isDigital = false;
                controller.isFromPromotion = false;
                controller.retrieveOrder();
                controller.edit();
                controller.void(); 
                controller.submit();        
            Test.stopTest();
        }catch(Exception e){ 
            System.debug('\n'+e.getMessage()+'\n');
        }
    } 
}