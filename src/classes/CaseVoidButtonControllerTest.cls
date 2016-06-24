/**
* Class Name: CaseVoidButtonControllerTest
* @author: Sherwin Puli
* Date: 
* Modified: 
* Modified Date: 
* @Description:
* History: 
*
*/
@isTest(Seealldata = True)
public class CaseVoidButtonControllerTest
{
    public static testMethod void testVoidCase(){
        
        List<User> userList = new List<User>();
        List<Case> caseList = new List<Case>();
        
        String recType = ConstantsSLB.getOther('ARMS CSO Admin');
            User testUser1 = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = [Select Id From Profile Where Name = :recType Limit 1].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard1@test.com'
            );
        userList.add(testUser1);
        
            User testUser2 = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = [Select Id From Profile Where Name = :recType Limit 1].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard2@test.com'
            );
        userList.add(testUser2);
        
        insert userList;        
            
            //ACC
            Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            insert acc;
            
            //CASE
            Case complainCase = new Case();
            complainCase = TestDataFactory.createCase(1, GlobalVariableClass.RECTYPE_COMPLAINT_NEWSPAPER)[0];
            complainCase.OwnerId = testUser1.Id;
            caseList.add(complainCase);
            
            Case coaCasePast = new Case();
            coaCasePast = TestDataFactory.createCase(1, GlobalVariableClass.RECTYPE_COA)[0];
            coaCasePast.OwnerId = testUser1.Id;
            coaCasePast.Effective_Date__c = Date.TODAY().addDays(1);
            caseList.add(coaCasePast);
            
            Case coaCaseFuture = new Case();
            coaCaseFuture = TestDataFactory.createCase(1, GlobalVariableClass.RECTYPE_COA)[0];
            coaCaseFuture.OwnerId = testUser1.Id;
            coaCaseFuture.Effective_Date__c = Date.TODAY().addDays(3);
            caseList.add(coaCaseFuture);
            
            insert caseList;
            
            Test.startTest();
            
            //CASES ADDITIONAL          
            Case coaCaseInvalid = new Case();
            coaCaseInvalid = TestDataFactory.createCase(1, GlobalVariableClass.RECTYPE_COA)[0];
            coaCaseInvalid.OwnerId = testUser1.Id;
            coaCaseInvalid.Effective_Date__c = null;
            insert coaCaseInvalid;
            /*
            Case cosCaseValid = new Case();
            cosCaseValid = TestDataFactory.createCase(1, GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION)[0];
            cosCaseValid.OwnerId = testUser1.Id;
            cosCaseValid.Effective_Date__c = null;
            insert cosCaseValid;
            
            Case stopCaseValid = new Case();
            stopCaseValid = TestDataFactory.createCase(1, GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION)[0];
            stopCaseValid.OwnerId = testUser1.Id;
            //stopCaseValid.Effective_Date__c = null;
            insert stopCaseValid;
            
            //BILLING ACC
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
            insert billAcc;
            
            //ADDRESS
            Address__c ad = TestDataFactory.createAddress(1)[0];
            database.insert(ad);
            
            //CONTACT
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.AccountId = acc.Id;
            con.NRIC__c = 'T2123451S';
            con.Address__c = ad.Id;
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
            database.insert(con);
            
            
            
            //PUBLICATION
            Publication__c publication = TestDataFactory.createPublication(1)[0];
            publication.Publication_Code__c = 'XX';
            publication.Earliest_Start_Date__c = date.today()+1;
            database.insert(publication);
            
            //PRODUCT
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;

            //PRODUCT RATEPLAN
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;
            
            //PRPC
            zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
            zprpc.Name = 'Product Rate Plan Charge';
            zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
            zprpc.zqu__ZuoraId__c = '3689922200';
            zprpc.PublicationCode__c = 'XX';
            insert zprpc;
            
            //PACKAGE
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            //PACKAGE ITEM
            Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            pItem.Package__c = pack.id;
            pItem.Product_Rate_Plan__c = prdRatePlan.id;
            pItem.Name = 'Test Pack Item';
            insert pItem; 
            
            //ORDER
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.id;
            order.Billing_Contact__c = con.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';
            order.Billing_Type__c = 'Full Prepaid';
            insert order;
            
            //OLI for Stop
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.newInstance(2017, 12, 2);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(3);
            orderline.Stop_Request_Date__c =  date.Today().addDays(5);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Case__c = stopCaseValid.Id;
            orderline.Start_Date__c = Date.Today().addDays(2);
            insert orderline;
            
            //OLI for COS
            Order_Line_Item__c orderlineCOS = TestDataFactory.createOrderLineItem(1)[0];
            orderlineCOS.Order__c = order.Id;
            orderlineCOS.End_Date__c = date.newInstance(2017, 12, 2);
            orderlineCOS.Main_Package_ID__c = pack.Id;
            orderlineCOS.Term_Length__c = 0;
            orderlineCOS.Main_Package_Period__c = 0;
            orderlineCOS.Earliest_Start_Date__c = date.today();
            orderlineCOS.Earliest_Stop_Date__c = Date.Today().addDays(3);
            orderlineCOS.Stop_Request_Date__c =  date.Today().addDays(5);
            orderlineCOS.Terminating_Reason__c = 'Others';
            orderlineCOS.Amount_To_Refund__c = 0;
            orderlineCOS.Admin_Charge__c = 0;
            orderlineCOS.Fee_Waiver__c = TRUE;
            orderlineCOS.Fee_Override__c = TRUE;
            orderlineCOS.Override_Reason__c = 'TEST';
            orderlineCOS.Suppress_Notification_Stop__c = TRUE;
            orderlineCOS.Main_Package_Type__c = 'Base';
            orderlineCOS.Case__c = cosCaseValid.Id;
            orderlineCOS.Start_Date__c = Date.Today().addDays(2);
            insert orderlineCOS;
            */
            //EXECUTION
            CaseVoidButtonController.voidCase(complainCase.Id, testUser2.Id);
            CaseVoidButtonController.voidCase(complainCase.Id, testUser1.Id);
            CaseVoidButtonController.voidCase(coaCasePast.Id, testUser2.Id);
            CaseVoidButtonController.voidCase(coaCasePast.Id, testUser1.Id);
            CaseVoidButtonController.voidCase(coaCaseFuture.Id, testUser1.Id);
            CaseVoidButtonController.voidCase(coaCaseInvalid.Id, testUser1.Id);
            //CaseVoidButtonController.voidCase(cosCaseValid.Id, testUser1.Id);
            //CaseVoidButtonController.voidCase(stopCaseValid.Id, testUser1.Id);
            Test.stopTest();
    }
    
    public static testMethod void testVoidCase2(){
        
        List<User> userList = new List<User>();
        List<Case> caseList = new List<Case>();
        
        String recType = ConstantsSLB.getOther('ARMS CSO Admin');
            User testUser1 = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = [Select Id From Profile Where Name = :recType Limit 1].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard1@test.com'
            );
        userList.add(testUser1);
        
            User testUser2 = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = [Select Id From Profile Where Name = :recType Limit 1].Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard2@test.com'
            );
        userList.add(testUser2);
       
        insert userList;        
            
            //ACC
            Account acc = TestDataFactory.createAccount(1, 'Direct Individual')[0];
            insert acc;
            
            
            
            //CASES
            Case cosCaseValid = new Case();
            cosCaseValid = TestDataFactory.createCase(1, GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION)[0];
            cosCaseValid.OwnerId = testUser1.Id;
            cosCaseValid.Effective_Date__c = null;
            insert cosCaseValid;
            
            Case stopCaseValid = new Case();
            stopCaseValid = TestDataFactory.createCase(1, GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION)[0];
            stopCaseValid.OwnerId = testUser1.Id;
            //stopCaseValid.Effective_Date__c = null;
            insert stopCaseValid;
            //BILLING ACC
            Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
            billAcc.Zuora__Account__c = acc.Id;
            billAcc.Billing_Type__c = 'Full Prepaid'; // added by jjzs
            insert billAcc;
            
            //ADDRESS
            Address__c ad = TestDataFactory.createAddress(1)[0];
            database.insert(ad);
            
            //CONTACT
            Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
            con.AccountId = acc.Id;
            con.NRIC__c = 'T2123451S';
            con.Address__c = ad.Id;
            con.Recipient_Indicator__c = true;
            con.Billing_Indicator__c = true;
            database.insert(con);
            
            
            
            //PUBLICATION
            Publication__c publication = TestDataFactory.createPublication(1)[0];
            publication.Publication_Code__c = 'XX';
            publication.Earliest_Start_Date__c = date.today()+1;
            database.insert(publication);
            
            //PRODUCT
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;

            //PRODUCT RATEPLAN
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            prdRatePlan.RatePlanType__c= 'Bill Plan';
            prdRatePlan.zqu__EffectiveStartDate__c= date.today();
            prdRatePlan.zqu__EffectiveEndDate__c= date.today().addDays(30);
            prdRatePlan.zqu__Deleted__c = false;
            insert prdRatePlan;
            
            //PRPC
            zqu__ProductRatePlanCharge__c zprpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
            zprpc.Name = 'Product Rate Plan Charge';
            zprpc.zqu__ProductRatePlan__c = prdRatePlan.id;
            zprpc.zqu__ZuoraId__c = '3689922200';
            zprpc.PublicationCode__c = 'XX';
            insert zprpc;
            
            //PACKAGE
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            pack.Name = 'Pack name';
            pack.Billing_Type__c = 'Full Prepaid';
            pack.Package_Type__c = 'Base';
            pack.Subscription_Period__c = '18';
            pack.Package_Code__c = 'afds132';
            insert pack;
            
            //PACKAGE ITEM
            Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
            pItem.Package__c = pack.id;
            pItem.Product_Rate_Plan__c = prdRatePlan.id;
            pItem.Name = 'Test Pack Item';
            insert pItem; 
            
            //ORDER
            Order__c order = TestDataFactory.createOrder(1)[0];
            order.Account__c = acc.Id;
            order.Informed_Customer__c = TRUE;
            order.Recipient_Contact__c = con.Id;
            order.Status__c = 'Draft';
            order.Eligible_for_Retention__c = TRUE;
            order.Billing_Account_Creation_Mode__c = 'Create New Billing Account';
            order.Payment_Mode__c = 'Credit Card';
            order.Billing_Account__c = billAcc.id;
            order.Billing_Contact__c = con.id;
            order.Case_Record_Type__c = 'Complaint - Magazine';
            order.Category__c = 'Subscription Request';
            order.Sub_Category__c ='Stop Subscription';
            order.Credit_Balance__c = 0;
            order.Delivery_Charge__c = 0;
            order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
            order.Order_Type__c = 'Change of Subscription Package';
            order.PO_Number__c = 'PO00000';
            order.Billing_Type__c = 'Full Prepaid';
            insert order;
            
            //OLI for Stop
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = order.Id;
            orderline.End_Date__c = date.newInstance(2017, 12, 2);
            orderline.Main_Package_ID__c = pack.Id;
            orderline.Term_Length__c = 0;
            orderline.Main_Package_Period__c = 0;
            orderline.Earliest_Start_Date__c = date.today();
            orderline.Earliest_Stop_Date__c = Date.Today().addDays(3);
            orderline.Stop_Request_Date__c =  date.Today().addDays(5);
            orderline.Terminating_Reason__c = 'Others';
            orderline.Amount_To_Refund__c = 0;
            orderline.Admin_Charge__c = 0;
            orderline.Fee_Waiver__c = TRUE;
            orderline.Fee_Override__c = TRUE;
            orderline.Override_Reason__c = 'TEST';
            orderline.Suppress_Notification_Stop__c = TRUE;
            orderline.Main_Package_Type__c = 'Base';
            orderline.Case__c = stopCaseValid.Id;
            orderline.Start_Date__c = Date.Today().addDays(2);
            insert orderline;
            
            //OLI for COS
            Order_Line_Item__c orderlineCOS = TestDataFactory.createOrderLineItem(1)[0];
            orderlineCOS.Order__c = order.Id;
            orderlineCOS.End_Date__c = date.newInstance(2017, 12, 2);
            orderlineCOS.Main_Package_ID__c = pack.Id;
            orderlineCOS.Term_Length__c = 0;
            orderlineCOS.Main_Package_Period__c = 0;
            orderlineCOS.Earliest_Start_Date__c = date.today();
            orderlineCOS.Earliest_Stop_Date__c = Date.Today().addDays(3);
            orderlineCOS.Stop_Request_Date__c =  date.Today().addDays(5);
            orderlineCOS.Terminating_Reason__c = 'Others';
            orderlineCOS.Amount_To_Refund__c = 0;
            orderlineCOS.Admin_Charge__c = 0;
            orderlineCOS.Fee_Waiver__c = TRUE;
            orderlineCOS.Fee_Override__c = TRUE;
            orderlineCOS.Override_Reason__c = 'TEST';
            orderlineCOS.Suppress_Notification_Stop__c = TRUE;
            orderlineCOS.Main_Package_Type__c = 'Base';
            orderlineCOS.Case__c = cosCaseValid.Id;
            orderlineCOS.Start_Date__c = Date.Today().addDays(2);
            insert orderlineCOS;
            
             Test.startTest();
            //EXECUTION
            //CaseVoidButtonController.voidCase(complainCase.Id, testUser2.Id);
            //CaseVoidButtonController.voidCase(complainCase.Id, testUser1.Id);
            //CaseVoidButtonController.voidCase(coaCasePast.Id, testUser2.Id);
            //CaseVoidButtonController.voidCase(coaCasePast.Id, testUser1.Id);
            //CaseVoidButtonController.voidCase(coaCaseFuture.Id, testUser1.Id);
            //CaseVoidButtonController.voidCase(coaCaseInvalid.Id, testUser1.Id);
            CaseVoidButtonController.voidCase(cosCaseValid.Id, testUser1.Id);
            CaseVoidButtonController.voidCase(stopCaseValid.Id, testUser1.Id);
            Test.stopTest();
    }
    

}