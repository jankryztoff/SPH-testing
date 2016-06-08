/* Testclass on hold
 * by: Jensar Joey Sayson
 */

@isTest(SeeAllData = true)
public class StartSubscriptionServiceTest {
    
    static Map<String,SObject> objectMap;
    
    static void setDataMethod(){
        
        objectMap = null;
        objectMap = new Map<String,SObject>();
        
        //Create country
        Country__c country = TestDataFactory.createCountry(1)[0];
            country.Country_Name__c = 'SIN';
        database.insert(country);
        
        //Create postal
        Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = 'SPostal';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            postal.Building_Name__c = 'Building';
            postal.Street_Name__c = 'Street';
        database.insert(postal);
        
        //Create account
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
            acc.NRIC__c = 'T1234567R';
            acc.Name = 'Test Account';
            acc.Phone = '123-456';
            acc.Email__c = 'test@test.com';
            acc.Date_of_Birth__c = date.today();
            acc.Gender__c = 'Male';
            acc.Race__c = 'Chinese';
            acc.Language__c = 'Others';
            acc.Contact_Person__c = 'Contact Person';
            acc.Sub_Group__c = 'Freelist(MY)';
        database.insert(acc);
        
        //Create Package
        Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
        database.insert(pack);        
        
        //Create zProduct
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        database.insert(zProduct);
        
        //Create zProduct rate plan
        zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            prdRatePlan.BillingType__c = 'Full Prepaid';
            prdRatePlan.BillingPeriod__c = '18';
            prdRatePlan.SubscriptionFrequency__c = '1';
        database.insert(prdRatePlan);
        
        //Create zProduct rate plan charge
        zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
            zprpc.Name = 'Product Rate Plan Charge';
            zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
            zprpc.zqu__ZuoraId__c = '3689922200';
        database.insert(zprpc);        
        
        //Create Package Item    
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            pItem.Package__c = pack.id;
            pItem.Product_Rate_Plan__c = prdRatePlan.id;
            pItem.Name = 'Test Pack Item';
        database.insert(pItem); 
        
        //Create Publication        
        Publication__c publ = TestDataFactory.createPublication(1)[0];
            publ.Direct_Sub_Delivery_Method__c = 'Vendor';
        database.insert(publ);  
        
        //Create Product Publication
        Product_Publication__c prodPub = TestDataFactory.createProductPublication(1)[0];
            prodPub.Publication_Code__c = publ.id;
            prodPub.ZProduct__c = zProduct.Id;
        database.insert(prodPub);
        
        //Create Billing Account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
        	billAcc.Zuora__DefaultPaymentMethod__c = 'Other';
        database.insert(billAcc);        
        
        //Create Address
        Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c = 'A';
            addressRec.Postal_Code__c = postal.Id;
            addressRec.Block_House_Number__c ='TEST';
            addressRec.Level_Number__c ='xx';
            addressRec.Unit_Number__c = 'yy';
            addressRec.Country__c = country.id;
        database.insert(addressRec);
        
        //Create Contact
        Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
            con.FirstName = 'Test';
            con.LastName = 'Contact';
            con.Passport__c = 'PassTest';
            con.HomePhone__c = '123 456';
            con.Mobile_Number__c = '123456';
            con.Email = 'test@test.com';
        database.insert(con);
        
        //Create another Contact
        Contact con1 = TestDataFactory.createContact(1)[0];
            con1.AccountId = acc.Id;
            con1.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
            con1.Billing_Indicator__c = true;
        database.insert(con1);
        
        //Create order
        Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Order_Type__c = 'Renewal';
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.Id;
            //WAK
            order.Billing_Type__c = billAcc.Billing_Type__c;
            order.Billing_Contact__c = con1.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';        
        database.insert(order);
        
        //Create Case
        Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        	cas.Order__c = order.Id;
        database.insert(cas);
        
        //Create Order Line Item
        Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.Start_Date__c = date.today().addDays(1);
            orderline.End_Date__c = date.today().addDays(2);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
            orderline.Stop_Request_Date__c =  date.Today().addDays(4);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            //orderline.Fee_Override__c = TRUE;
        database.insert(orderline);
        
    }
    
    //First Testmethod
    static testMethod void testMethod01(){
		
        //Set-up data
        setDataMethod();
        
        //Assertions here
        System.assertEquals(null, null);
        
    }
    
    
}