@IsTest (SeeAllData = true)
private with sharing class ChangeOfCreditCardControllerTest2 {
    static testmethod void testChangeOfCreditCardController() {
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        database.insert(acc);
        
        Contact con = TestDataFactory.createContactRecType(1, 'Customer Contact')[0];
        database.insert(con);
    
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Payment_Mode__c = GlobalVariableClass.CREDITCARD;
        billAcc.Billing_Contact__c = con.Id;
        database.insert(billAcc);
        
        Case caseRec = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
        caseRec.Billing_Account_Name__c = billAcc.Id;
        caseRec.AccountId = acc.Id;
        caseRec.Payment_Method_ID__c = 'CreditCard';
        database.insert(caseRec);
        
        Order__c order = TestDataFactory.createOrder(1)[0];
        order.Account__c = acc.Id;
        database.insert(order);
        
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        Order_Line_Item__c ordItem = TestDataFactory.createOrderLineItem(1)[0];
        ordItem.Order__c = order.Id;
        ordItem.Main_Package_ID__c = pack.Id;
        database.insert(ordItem);
        
        Integer counter=0;
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub : subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            if(counter==0){
                sub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY;    
            }
            else{
                sub.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION;
            }
            sub.Order_Line_Item_Number__c = ordItem.Id; 
            sub.Zuora__Status__c = GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE;
            counter++;
        }
        database.insert(subs);
    
        test.startTest();
            PageReference currPage = Page.CustomHpmPageCase;
            Test.setCurrentPage(currPage);
            ApexPages.StandardController stdControl = new ApexPages.StandardController(caseRec);
            
            ChangeOfCreditCardController control = new ChangeOfCreditCardController();
            ChangeOfCreditCardController.WrapSubscription  wrap = new ChangeOfCreditCardController.WrapSubscription(subs[0]);
            List<ChangeOfCreditCardController.WrapSubscription> wrapList = new List<ChangeOfCreditCardController.WrapSubscription>();
            wrapList.add(wrap);
            control.WrapSubList = wrapList;
            control.ProcessSelected();
            
            ApexPages.currentPage().getParameters().put('id', caseRec.Id);
            ChangeOfCreditCardController control2 = new ChangeOfCreditCardController();
            wrap.selected = true;
            control2.WrapSubList = wrapList;
            control2.ProcessSelected();
            control2.getSource();
            control2.thisCase.Payment_Method_ID__c = 'CreditCard';
            control2.saveRecord();
            
            control2.SelectedSubscriptions = subs;
            control2.UnSelectedSubscriptions = subs;
            control2.saveRecord();
            control2.cancel();
            control2.paymentMethodId = 'test';
        test.stopTest();   
    }
    
}