@isTest (SeeAllData = False)
private class SM_StartSubscriptionEntry_Test2 {

    static void setCustomSettings() {
    
        //Cir_Planner_Schedule__c
        List<Cir_Planner_Schedule__c> cpsList = new List<Cir_Planner_Schedule__c>{
            new Cir_Planner_Schedule__c(Name='CIR Plan Schedule', Mon_Fri_End_Time__c=Date.today(),
                Mon_Fri_Start_Time__c=Date.today(),Sat_PH_End_Time__c=Date.today(),Sat_PH_Start_Time__c=Date.today(),
                Sun_End_Time__c=Date.today(),Sun_Start_Time__c=Date.today())
        };
        Database.insert(cpsList);
        
        //
        RecordType Case_ChangeinAddress = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Change of Address/Vendor' LIMIT 1];
        RecordType Case_TempStop        = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Temp Stop Subscription' LIMIT 1];
        RecordType Contact_VendorStaff     = [SELECT id, Name FROM RecordType WHERE SobjectType='Contact' AND Name='Vendor Staff' LIMIT 1];
        RecordType Contact_CustomerContact = [SELECT id, Name FROM RecordType WHERE SobjectType='Contact' AND Name='Customer Contact' LIMIT 1];
        RecordType Case_Stop = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Stop Subscription' LIMIT 1];
        
        //Key_Id__c
        //.getInstance('Vendor Rep Role')
        //ConstantsSLB.getKeyId('Contact_Customer Contact');
        /*
        final string AIRLINE = ConstantsSLB.getKeyId('AddAirline');
        final string OVERSEAS = ConstantsSLB.getKeyId('AddOverseas');
        final string LOCAL = ConstantsSLB.getKeyId('AddLocal');
        final string INTERNAL = ConstantsSLB.getKeyId('AddInternal');
        */
        /*
        List<Key_Id__c> kisList = new List<Key_Id__c>{
            new Key_Id__c(Name='Vendor Rep Role',       Id__c='123456789', Type__c='Number'),
            new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER', Id__c='123456789', Type__c='Number'),
            
            new Key_Id__c(Name='Case_Change in Address', Id__c=Case_ChangeinAddress.id, Type__c='RecordType'),
            new Key_Id__c(Name='Case_Temp Stop',         Id__c=Case_TempStop.id,        Type__c='RecordType'),
            
            new Key_Id__c(Name='Contact_Vendor Staff',     Id__c=Contact_VendorStaff.id,     Type__c='RecordType'),
            new Key_Id__c(Name='Contact_Customer Contact', Id__c=Contact_CustomerContact.id, Type__c='RecordType'),
            
            new Key_Id__c(Name='Case_Stop', Id__c=Case_Stop.id ,Type__c='RecordType'),
            
            new Key_Id__c(Name='AddInternal', Id__c='Internal', Type__c='Name'),
            new Key_Id__c(Name='AddLocal',    Id__c='Local',     Type__c='Name')
        };
        Database.insert(kisList);
        */
        //Batch_Configuration_Settings__c.getInstance('SP_VendorNotificationsBatch');
        List<Batch_Configuration_Settings__c> bcsList = new List<Batch_Configuration_Settings__c>{
            new Batch_Configuration_Settings__c(Name='SP_VendorNotificationsBatch', Batch_Size__c=10, 
                Max_Retries__c=10, Notification_Recipients__c='', Number_Of_Days_To_Retrieve__c=30)
        };
        Database.insert(bcsList);
        
        //Other__c
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59'),
            
            new Other__c(Name='Zero Charge Amount',     Value__c='Zero'),
            new Other__c(Name='HDB DELIVERY CHARGE',    Value__c='HDB'),
            new Other__c(Name='APT DELIVERY CHARGE',    Value__c='APT'),
            new Other__c(Name='LANDED DELIVERY CHARGE', Value__c='LANDED')
        };        
        Database.insert(otherList);
        
        //Delivery_Charge_Type__c
        List<Delivery_Charge_Type__c> delCharTypeList = new List<Delivery_Charge_Type__c>{
            new Delivery_Charge_Type__c(Name='H', Default_Delivery_Charge_Type__c='H'),
            new Delivery_Charge_Type__c(Name='L', Default_Delivery_Charge_Type__c='L'),
            new Delivery_Charge_Type__c(Name='C', Default_Delivery_Charge_Type__c='C')
        };
        Database.insert(delCharTypeList);
    }


    static testMethod void testAddOrderLineItem01() {
        
        System.RunAs(TestDataFactory.prepareTestUsers('Standard User')) {
        try {
            setCustomSettings();
            
            Key_Id__c keyId = new Key_Id__c();
            keyId.Name = 'Contact_Customer Contact';
            keyId.Id__c = '01290000001AgHXAA0';
            insert keyId;
            
            //Create Account
            Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.Name = 'TEST';
            acc.AccountNumber = '123456789';
            acc.NRIC__c = 'T1234567R';
            insert acc; 
               
            //Create Singpost Address
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            insert postal;
            
            //Create Address
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            //Create Contact
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;  
            insert con;            
            
            //Create Billing Account
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Name = 'TEST';     
            billAcc.Zuora__Credit_Balance__c = 0;
            billAcc.Payment_Mode__c = 'Cash';
            billAcc.Billing_Type__c = 'Full Prepaid';
            insert billAcc;
            
            //Create Asia One
           
            List <Asia1__c> asiaList = TestDataFactory.createAsiaOne(1);
            for(Asia1__c asia : asiaList){
                asia.Id_Already_Active__c = false;
                asia.Is_Link_Expired_Used__c = true;
                asia.Status__c = 'Enabled';
                asia.Enabled__c = false;
                asia.Contact__c = con.Id;
                asia.Display_Name__c = 'acn@sphcom.sg';
                asia.User_ID_LDAP_ID__c = 'userId27';
                asia.Base_Date_Expiration__c = date.today()-5;
                asia.Password__c = 'sph123409';
                asia.ASIAONE_Legacy_Id__c = '146';
                asia.Email__c = 'acn@sphcom.sg';
            }
            insert asiaList;            
                          
            //Create Package
             List<Package__c> packageList = TestDataFactory.createPackage(1);
            for (Package__c obj : packageList) {
                obj.Package_Price__c = 3;
                obj.Billing_Type__c = 'Recurring Prepaid';
                obj.Package_Type__c = 'Add on';
                obj.Eligible_Product_Family_for_Add_On_Pack__c = 'Default';
            }
            insert packageList;
            
            //Create zProduct
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            zProduct.ProductSubType__c  = 'Magazine';
            zProduct.ProductPlatform__c = 'Online';
            insert zProduct;
            
            Set<String> promoId = new Set<String>();
            promoId.add(zProduct.id);
            
            //Create Product Rate Plan
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            insert prdRatePlan;
            
            //Create Product Rate Plan Charge
            zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(1)[0];
            prpc.zqu__ProductRatePlan__c = prdRatePlan.Id;
            
            insert prpc;
            
            //Create Package Item
            Package_Item__c pItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            pItem.Package__c               = packageList[0].Id;
            pItem.Product_Rate_Plan__c     = prdRatePlan.Id;
            pItem.Duration_in_months__c    = '1';
            pItem.Effective_Start_Month__c = '1';
            
                insert pItem;
            
            
            
              //Create Publication
            Publication__c pub = TestDataFactory.createPublication(1)[0];
            pub.Name = 'pubdata';
            pub.Publication_Code__c = 'pubf';
            pub.Published_Days__c = 'NNNYYYN';
            pub.Publication_Type__c = 'A';
            pub.Earliest_Start_Date__c = date.Today().addDays(3);
            pub.Direct_Sub_Delivery_Method__c = 'Vendor or Mailing Agent';
            insert pub;
    
            
            //Create Product Publication
            
            List<Product_Publication__c> prodList = TestDataFactory.createProductPublication(1);
            prodList[0].Publication_Code__c = pub.id;
            prodList[0].ZProduct__c = zProduct.id;
         
            insert prodList;
            
            system.assertNotEquals(0, prodList.size());
            
            //insert Promo
            Promotion__c promoTmp = TestDataFactory.createPromotion(1)[0]; 
            promoTmp.Name = 'Promotions';
            promoTmp.Contract_Period__c ='12';
            promoTmp.Penalty_Charge__c = '100'; 
            insert promoTmp;
           
            
            //Create Order
            Order__c orderRec_0 = TestDataFactory.createOrder(1)[0];
            orderRec_0.Account__c = acc.Id;
            orderRec_0.Informed_Customer__c = TRUE;
            orderRec_0.Sub_Category__c ='Stop Subscription';
            orderRec_0.Recipient_Contact__c = con.Id;
            orderRec_0.Order_Type__c = 'Start';
            orderRec_0.Status__c = 'New';
            orderRec_0.Credit_Balance__c = 0;
            orderRec_0.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';
            orderRec_0.Delivery_Charge__c = 0;
            orderRec_0.Billing_Contact__c = null; 
            orderRec_0.Delivery_Charge_Type__c = 'S' ;
            orderRec_0.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            orderRec_0.Check_Amount__c = 100;
            orderRec_0.Check_Issuing_Bank__c = 'BLANK';
            orderRec_0.Check_No__c = 'SPACE';
            orderRec_0.Payment_Mode__c = 'Other';
            orderRec_0.Check_Dated__c =  date.today();
            orderRec_0.Remarks_Check__c =  'TESTTESTTEST';
            orderRec_0.Zone_Charge__c = 0;
            orderRec_0.Subscriber_Charge__c = 0;
            orderRec_0.Vendor_Credit__c = 0;   
            orderRec_0.Billing_Account__c = billAcc.id;
            orderRec_0.Other_Payment_Mode__c = 'Invoice';
            orderRec_0.Billing_Type__c = 'Full Prepaid';
            insert orderRec_0;
            
                    
            //Create Order Line Item
            List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(3);
            orderline[0].Order__c = orderRec_0.Id;
            orderline[0].End_Date__c = date.today();
            orderline[0].Main_Package_ID__c = packageList[0].Id;
            orderline[0].Addon_Package__c = packageList[0].id;
            orderline[0].Term_Length__c = null;
            orderline[0].Main_Package_Period__c = 0;  
            orderline[0].Asia1_Creation_Mode__c = 'Individual';
            //orderline[0].Start_Date__c = date.today();
            //orderline[0].Vendor_Mailing_Agent__c = acc.Id;
            orderline[0].Parent_Account__c = acc.Id;
            orderline[0].Term_is_discussed__c = false;
            orderline[0].Is_Digital__c = TRUE;
            orderline[0].Promotion_ID__c = promoTmp.id;
            orderline[0].Penalty_Charge__c = 100;
            orderline[0].New_Contract_Period__c = 1;
            orderline[0].Main_Package_Subscription_Rate__c = 100;
            orderline[0].Qty__c = 1;
            orderline[0].Main_Package_Product_Family__c = 'Default';
            orderline[0].Main_Package_Billing_Type__c = 'Recurring Prepaid';
            orderline[0].Main_Package_Frequency__c = 'Default';
            orderline[0].Main_Package_Sub_Type__c = 'Termed';
            orderline[0].Main_Package_Type__c = 'Base';
            orderline[0].Subscribed_as__c = 'New Buy';
    //TODO        orderline[0].Delivered_By__c = 'Overseas'; //jowie
            //Create Order Line Item    
            orderline[1].Order__c = orderRec_0.Id;
            orderline[1].End_Date__c = date.today();
            orderline[1].Addon_Package__c = packageList[0].id;
            orderline[1].Main_Package_ID__c = packageList[0].Id;
            orderline[1].Term_Length__c = 0;
            orderline[1].Main_Package_Period__c = 0;  
            orderline[1].Asia1_Creation_Mode__c = 'Individual';
            //orderline[1].Start_Date__c = date.today();
            orderline[1].Term_is_discussed__c = false;
            orderline[1].Is_Digital__c = TRUE;
            orderline[1].Promotion_ID__c = promoTmp.id;
            orderline[1].Penalty_Charge__c = 9999999999999999.99;
            orderline[1].New_Contract_Period__c = 999;
            orderline[1].Main_Package_Subscription_Rate__c = 100;
            orderline[1].Qty__c = 1;
            orderline[1].Main_Package_Product_Family__c = 'Default';
            orderline[1].Main_Package_Billing_Type__c = 'Recurring Prepaid';
            orderline[1].Main_Package_Frequency__c = 'Default';
            orderline[1].Main_Package_Sub_Type__c = 'Single';
            orderline[1].Main_Package_Type__c = 'Base';
            orderline[1].Subscribed_as__c = 'New Buy';
            orderline[1].Contract_End_Date__c = date.valueOf('1970-01-01');        
            
            //Create Order Line Item    
            orderline[2].Order__c = orderRec_0.Id;
            orderline[2].End_Date__c = date.today();
            orderline[2].Addon_Package__c = packageList[0].id;
            orderline[2].Main_Package_ID__c = packageList[0].Id;
            orderline[2].Term_Length__c = 0;
            orderline[2].Main_Package_Period__c = 0;  
            orderline[2].Asia1_Creation_Mode__c = 'Individual';
            //orderline[2].Start_Date__c = null;
            orderline[2].Term_is_discussed__c = true;
            orderline[2].Is_Digital__c = TRUE;
            orderline[2].Promotion_ID__c = promoTmp.id;
            orderline[2].Penalty_Charge__c = 9999999999999999.99;
            orderline[2].New_Contract_Period__c = 0;
            orderline[2].Main_Package_Subscription_Rate__c = 100;
            orderline[2].Qty__c = 1;
            orderline[2].Main_Package_Product_Family__c = 'Default';
            orderline[2].Main_Package_Billing_Type__c = 'Recurring Prepaid';
            orderline[2].Main_Package_Frequency__c = 'Default';
            orderline[2].Main_Package_Sub_Type__c = 'Single';
            orderline[2].Main_Package_Type__c = 'Base';
            orderline[2].Subscribed_as__c = 'New Buy';
            orderline[2].Contract_End_Date__c = date.valueOf('1970-01-01'); 
            
                insert orderline;
            
            
            
           /* Asia1_Subscription__c asub = new Asia1_Subscription__c();
            asub.Asia1__c = asiaList[0].id;
            asub.Order_Line_Item__c = orderline[0].id;
            asub.Status__c = 'Enabled';
            insert asub; */        
            
            //create Quote
            List<zqu__Quote__c> zqQ = TestDataFactory.createQuote(1);
            zqQ[0].Vendor_Credit__c = 0;
            zqQ[0].zqu__Account__c = acc.id;
            zqQ[0].Payment_Mode__c = 'Test';
            zqQ[0].Delivery_Charge_Type__c = 'S';
            zqQ[0].Subscriber_Charge__c = 0;
            zqQ[0].Other_PaymentMethod__c = 'Recurring Prepaid';
            zqQ[0].zqu__BillToContact__c = con.id;
            zqQ[0].Main_Package__c = packageList[0].id;
            zqQ[0].Order__c = orderRec_0.id;
            insert zqQ;
                    
            //Create Promotion Gift
            Promotion_Gift__c promoGift = TestDataFactory.createPromotionGift(1)[0];
            insert promoGift;
            
            //Create Order Line Item Gift
            List<Order_Line_Item_Gift__c> orderLineItemGifts = TestDataFactory.createItemGift(5);
            for(Order_Line_Item_Gift__c olig : orderLineItemGifts) {
                olig.Order_Line_Item__c = orderline[0].id;
                olig.Promotion_Gift__c = promoGift.id;
            }
            
            insert orderLineItemGifts;
        
                
            
            //NEW ORDER
           /* PageReference pageRef = Page.SM_StartSubscriptionEntry;
            SM_StartSubscriptionEntryController ssec = new SM_StartSubscriptionEntryController(); */
            
            Test.startTest();
            PageReference pageRef = Page.SM_StartSubscriptionEntry;
            pageRef.getParameters().put('id', orderline[0].Id);         //orderId
            pageRef.getParameters().put('accountId', acc.Id);           //accountId
            //pageRef.getParameters().put('def_parent_id', acc.Id);         //parentCaseId || parentId 
            //pageRef.getParameters().put('contactId', acc.Id);         //thiscontactId
            Test.setCurrentPage(pageRef);
            
            SM_StartSubscriptionEntryController testObj = new SM_StartSubscriptionEntryController();
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', acc.Id);
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Account());
            
            //Order_Line_Item__c 
            testObj.addAsia1ExistingAccount();
            testObj.asia1SubscriptionsTotal = 0;
            testObj.orderLineItem = orderline[0];
            testObj.selectedPackageId = packageList[0].id + ':' + promoTmp.id;
            testObj.addOrderLineItem();
            Test.stopTest(); 
            }
            catch (exception e){
                system.debug('poc >>>' +  e);
            }
        }
    }
}