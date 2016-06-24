@isTest (seeAllData = false)
private class testpdfControllerTest{ 
     
        static testMethod void testpdfController2(){
            
            defaultCustomSetting();
            
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = '123';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            postal.Building_Name__c = 'test';
            postal.Street_Name__c = 'test';
            insert postal;
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
            acc.Name = 'Zuora Customer Account';
            acc.Phone = '123456';
            acc.AccountNumber = 'ACCNO001';
            acc.Staff_ID__c = 'SID001';
            insert acc;   
            
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].Zuora__Account__c = acc.id; 
            billAccountList[0].Zuora__AccountNumber__c = '001122';
            insert billAccountList; 
            
            Package__c pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Recurring Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;    
            
            
            
            Address__c address = TestDataFactory.createAddress(1)[0];
            address.Address_Type__c = 'A';
            address.Postal_Code__c = postal.Id;
            address.Block_House_Number__c ='TEST';
            address.Level_Number__c ='xx';
            address.Unit_Number__c = 'yy';
            insert address;
            
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = address.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Customer Contact'].id;
            con.Billing_Indicator__c = true;
            con.Recipient_Indicator__c = true;
            //insert con;
            
            List<Order__c> orderList = TestDataFactory.createOrder(1);
            orderList[0].Account__c = acc.id;
            orderList[0].Subscriber_Charge__c = 100; 
            orderList[0].Delivery_Charge__c = 20; 
            //orderList[0].Recipient_Contact__c = con.id;  
            orderList[0].Billing_Type__C = 'Full Prepaid';                     
            insert orderList;
            
            List<Order_Line_Item__c> orderLineItemList = TestDataFactory.createOrderLineItem(1);
            orderLineItemList[0].Order__c = orderList[0].id; 
            orderLineItemList[0].Main_Package_ID__c = pack.id;        
            orderLineItemList[0].Start_Date__c = system.today()+3; //jurna-10-26-15
            orderLineItemList[0].Publication_1__c = 'Beat Harry';
            //orderLineItemList[0].Publication_2__c = publi[0].id;
            insert orderLineItemList;
            
            List<Publication__c> publi = TestDataFactory.createPublication(1);
            publi[0].Name = orderLineItemList[0].Publication_1__c;    
            publi[0].Publication_Code__c = 'BHAO';
            publi[0].Published_Days__c = 'YYYYYYY';
            publi[0].Publication_Type__c = 'M';
            publi[0].Frequency_Code__c = 'D';
            publi[0].Publication_Next_Start_Date__c = date.Today() +14;
            database.insert(publi);
                     
            Zuora__Subscription__c zsub = TestDataFactory.createSubscription(1)[0];
            zsub.Name = 'Ron';
            zsub.Zuora__CustomerAccount__c = billAccountList[0].id;
            zsub.Main_Package_1__c = pack.id;
            zsub.Main_Package__c = pack.Id;
            zsub.Order_Line_Item_Number__c = orderLineItemList[0].id;
            zsub.Order_Line_Item_Number_1__c = orderLineItemList[0].id;     
            zsub.Zuora__Account__c = acc.id;
            zsub.Order_Number__c = orderList[0].id;  
            zsub.Order_Number_1__c = orderList[0].id;      
            //zsub.Recipient_Contact__c = con.Id;
            //zsub.Recipient_Contact_1__c = con.Id;
            //zsub.Subscriber_Contact__c = con.Id;
            //zsub.Subscriber_Contact_1__c = con.Id;
            zsub.Frequency_1__c = 'Mon - Fri';
            zsub.Frequency__c = 'Mon - Fri';
            zsub.Number_of_Copies__c = 2;
            zsub.Subscription_End_Date__c = string.valueOf(date.today());
            //zSub.Contact__c = con.id;
            insert zsub; 
            
            List<Zuora__SubscriptionProductCharge__c> subProdCharge = TestDataFactory.createSubProductCharge(1);    
            subProdCharge[0].Name = 'Credit Copy Sat';
            subProdCharge[0].PublicationCode__c = 'BHAO';
            subProdCharge[0].Zuora__Subscription__c = zsub.id;
            subProdCharge[0].Zuora__UOM__c = 'Credit Copy Weekday';
            subProdCharge[0].Zuora__Quantity__c = 5;
            subProdCharge[0].Zuora__ProductSKU__c = 'SKU-12345678';
            subProdCharge[0].Zuora__RatePlanName__c = 'PRODUCT RATE PLAN';
            insert subProdCharge;
            
            zqu__ZProduct__c zProd = TestDataFactory.createZProduct(1)[0];
            zProd.Name = 'THE STRAITS TIMES PRINT TEST';
            zProd.zqu__SKU__c = 'SKU-12345678';
            zProd.ProductCode__c = 'TEST';
            zProd.ProductType__c = 'Product';
            zProd.ProductPlatform__c = 'Print';
            zProd.ProductFamily__c = 'ST';
            zProd.ProductSubType__c = 'Newspaper';
            insert zProd;
            
            List<zqu__ProductRatePlan__c> prps = TestDataFactory.createProductRatePlan(2);
            for(zqu__ProductRatePlan__c prp: prps)
            { 
                prp.zqu__ZProduct__c = zProd.Id;
                prp.SubscriptionFrequency__c = '0';
            }
            prps[0].RatePlanCode__c = 'STEST13TS';
            prps[0].Name = 'PRODUCT RATE PLAN TEST';
            prps[0].RatePlanType__c = 'Bill Plan';
            
            prps[1].RatePlanCode__c = 'STEST15TS';
            prps[1].Name = 'PRODUCT RATE PLAN';
            prps[1].RatePlanType__c = 'Proration';
            prps[1].RatePlanSubType__c = 'Standard';
            insert prps; 
            
            Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
            packItem.Package__c = pack.Id;
            packItem.Product_Rate_Plan__c = prps[0].Id;
            /*
            packItem.RenewalPkgCodeMag1YrDisc__c = pack.Id;
            packItem.RenewalPkgCodeMag1YrBase__c = pack.Id;
            packItem.RenewalPkgCodeMag2YrBase__c = pack.Id;
            packItem.RenewalPkgCodeMag2YrDisc__c = pack.Id;*/
            insert packItem; 
            
            
            
            // Initialization of VisualForce Page
            PageReference pRef = Page.testpdf;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('id', zsub.Id);
            ApexPages.currentPage().getParameters().put('subscriptionId',zsub.Id);
            //ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Zuora__Subscription__c());
            
            Test.startTest();
            
            testpdfController cont = new testpdfController();
            cont.subId = zsub.id;
           
            
            //database.update(zsubList[0]);
            
            //testpdfController cont2 = new testpdfController();
            //cont2.subId = zsubList[0].id;
            cont.initialize();
            // BaseClass
            //testpdfController controller = new testpdfController();
            //PageReference nextPage = controller.redirect();
            //System.assert(nextPage.getUrl().contains('/' + acc.Id + '/e'));
            Test.stopTest();
          
        }
        
 
        
        
      static void defaultCustomSetting(){
         
        String invoiceId = '0x00x0x00x00x000000x0x000xx00x00';
        Key_Id__c keyId;
        Other__c otherC;
        
        String[] keyIdNameArray = new String[]{'Account_Direct Individual','Account_Vendor Subscriber','Address_Local','Contact_Customer Contact','Package Item_Base Product','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','UpdateARMSInfoResultId','NEXT_RECIPIENT_NUMBER','Account_Direct Corporate','Account_Direct SPH Inter-Division','Case_Change of Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Head of Customer Service Queue','Case Renewal of Subscription','Case_Change in Address','Complaint_Newspaper','Case_Complaint Magazine','SubTypeDel','SubTypePostage','SubTypePub','Address_Airline','Address_Internal','Address_Overseas'};
        String[] keyIdIdcArray = new String[]{'012N00000008ic1IAA','012N00000008ibwIAA','012N00000008idiIAA','012N00000008r43IAA','012N00000008jCOIAY','012N00000008jCdIAI','012N00000008jCTIAY','012N00000008jCsIAI','123vd','123457177','012N00000008ic6IAA','012N00000008icBIAQ','012N00000008lpwIAA','012N00000008jvYIAQ','012N00000008k09IAA','012N00000008k0EIAQ','00GN0000000mMcJ','00GN0000000lUNp','00GN0000000mUXw','012N00000008lqG','012N00000008lAoIAI','012N00000008kI8IAI','012N00000008kIDIAY','Delivery','Postage','Publication','012N00000008idx','012N00000008idnIAA','012N00000008idsIAA'};
        String[] keyIdTypeArray = new String[]{'Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Number','Record Type','Record Type','Record Type','Record Type','Record Type','Record Type','Id','Id','Id','Record Type','Record Type','Record Type','Record Type','Name','Name','Name','Record Type','Record Type','Record Type'};
        
        List<Key_Id__c> keyList = new List<Key_Id__c>();
        
        for(Integer i = 0 ; i < keyIdNameArray.size(); i++ )
        {
            keyId = new Key_Id__c();
            keyId.Name = keyIdNameArray[i];
            keyId.Id__c = keyIdIdcArray[i];
            keyId.Type__c = keyIdTypeArray[i];
            keyList.add(keyId);
        }
        insert keyList;
        
        String[] orderCNameArray = new String[]{'Order_Type COS_Package','Order_Type COS_Quantity','Order_Type Renewal','Order_Type Start','Order_Type Stop','Product_Category AIO','Product_Category Digital','Product_Category Magazine','Product_Category Print','DTL','ARMS_AccTyp','ARMS_SysId','ARMS_userID','ARMS_password'};
        String[] orderCValueArray = new String[]{'Change of Subscription Package','Change of Subscription Quantity','Renewal','Start','Stop','All in One (AIO)','Digital','Magazine','Print', '23:59','SS','SS','Username','Password'};
        
        List<Other__c> otherList = new List<Other__c>();
        for(Integer i = 0 ; i < orderCNameArray.size(); i++ )
        {
            otherC = new Other__c();
            otherC.Name = orderCNameArray[i];
            otherC.Value__c = orderCValueArray[i];
            otherList.add(otherC);
        }
        insert otherList;
        
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
        
        Delivery_Charge_Type__c delType = new Delivery_Charge_Type__c();
        delType.Name = 'A';
        delType.Default_Delivery_Charge_Type__c = 'C';
        insert delType;
        
        Delivery_Charge__c delCharge = new Delivery_Charge__c();
        delCharge.Name ='AC';
        delCharge.Vendor_Credit__c = 9.00;
        delCharge.Subscriber_Charge__c = 9.00;
        insert delCharge;
    }

}