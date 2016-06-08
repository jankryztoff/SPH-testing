/**
   @Author Joy Suarez
   @name AdminCharge_Amendment_Test
   @CreateDate 02/03/2015
   @Description test class for AdminCharge_Amendment
   @Version <1.0>
   @reference <Referenced program names>
  */
  /**
    *  To test AdminCharge_Amendment
    *  @name testAdminAmendment
    *  @param none
    *  @return none
    *  @throws na
    */ 
  
@isTest(seeAllData=True)
private class AdminCharge_Amendment_Test {
/*    
    static testMethod void testAdminAmendment()
    {         
           
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            insert acc;
    
            Package__c pack = new Package__c();
            pack = TestDataFactory.createPackage(1)[0];
            insert pack;
    
            Contact con = TestDataFactory.createContact(1)[0];
            con.AccountId = acc.Id;
            con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact'); 
            con.Recipient_Indicator__c = true; 
            insert con;
            
            Test.startTest();    
        try {
            //Test.setMock(WebServiceMock.class, new zLoginMock());
    
            List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
            billAccountList[0].Zuora__Account__c = acc.id; 
            insert billAccountList;
            
            Order__c orderRec = TestDataFactory.createOrder(1)[0];
            orderRec.Account__c = acc.Id;
            orderRec.Informed_Customer__c = TRUE;
            orderRec.Recipient_Contact__c = con.Id;
            orderRec.Subscriber_Charge__c = 100;
            insert orderRec;
                                    
            Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
            orderline.Order__c = orderRec.Id;
            orderline.End_Date__c = date.today();
            orderline.Start_Date__c = date.newInstance(2015, 5, 14);
            orderline.Main_Package_ID__c = pack.Id;
            insert orderline;
            
            zqu__ProductRatePlanCharge__c newRatePlan = TestDataFactory.createProductRatePlanCharge(1)[0];
            newRatePlan.Name = 'Admin Charge';
            newRatePlan.zqu__Deleted__c = false;
            newRatePlan.zqu__ZuoraId__c = 'Zuora1';
            insert newRatePlan;
            system.assertNotEquals(null, newRatePlan );
            
            zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
            insert zProduct;
                
            zqu__ProductRatePlan__c prdRatePlan = TestDataFactory.createProductRatePlan(1)[0];
            prdRatePlan.zqu__ZProduct__c = zProduct.Id;
            insert prdRatePlan;
            
            List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(1);
            subRecs[0].Zuora__Account__c = acc.Id;
            subRecs[0].Zuora__CustomerAccount__c = billAccountList[0].id;
            subRecs[0].Zuora__SubscriptionEndDate__c = date.today() +5;
            subRecs[0].Subscription_End_Date__c = String.valueOf(date.today()+5);
            subRecs[0].Subscriber_Contact__c = con.Id;
            subRecs[0].Recipient_Contact__c = con.Id;
            subRecs[0].Main_Package_1__c = pack.id;
            subRecs[0].Zuora__Status__c = 'Active';
            subRecs[0].Order_Number__c = orderRec.Id;
            subRecs[0].Suppress_Vendor_Start_Notice__c = 'false';
            subRecs[0].Supressed_Acknowledgement_Letter__c = 'false';
            subRecs[0].Supressed_Renewal_and_Reminder_Letter__c = 'false';
            subRecs[0].Urgent__c = 'false';
            subRecs[0].Vendor_Conversion__c = 'false';
            subRecs[0].Charity__c = 'false';
            subRecs[0].Order_Line_Item_Number__c = orderline.Id;
            subRecs[0].Contract_End_Date_1__c = date.newInstance(2014, 12, 12);
            subRecs[0].Number_of_Copies__c= 100;
            subRecs[0].Number_of_Copies1__c =  '100';
            subRecs[0].Qty__c = 20;
            Database.insert(subRecs);
     
            decimal AdminCharge = 17.00;
            Date ContractEffectiveDate = Date.newInstance(2014, 12, 12);
            Date CustomerAcceptanceDate = Date.newInstance(2014, 12, 12);
            Date EffectiveDate = Date.newInstance(2014, 12, 12);
            Date ServiceActivationDate = Date.newInstance(2014, 12, 12);
               
            AdminCharge_Amendment adminChargeAmend = new AdminCharge_Amendment();    
            adminChargeAmend.amendForNewProduct(subRecs[0].id, AdminCharge, ContractEffectiveDate, CustomerAcceptanceDate, EffectiveDate, ServiceActivationDate);
            
            Test.StopTest(); 
       }catch(Zuora.zRemoteException e){
            system.debug(e);
       } 
   } 
*/
    static testMethod void testAmendForNewProductFutureCallout01() {
               
       try {
            //Test.setMock(WebServiceMock.class, new zLoginMock());      
            //TestData
                String subscriptionId = '123';
                decimal AdminCharge = 10;
                Date ContractEffectiveDate = Date.today();
                Date CustomerAcceptanceDate = Date.today();
                Date EffectiveDate = Date.today();
                Date ServiceActivationDate = Date.today();
            
            
                Test.startTest();        
                AdminCharge_Amendment amendForNew = new AdminCharge_Amendment();
                //AdminCharge_Amendment.amendForNewProductFutureCallout(subscriptionId, AdminCharge,
                                            //ContractEffectiveDate, CustomerAcceptanceDate, 
                                            //EffectiveDate, ServiceActivationDate);   
               amendForNew.amendForNewProduct(subscriptionId, AdminCharge,
                                            ContractEffectiveDate, CustomerAcceptanceDate, 
                                            EffectiveDate, ServiceActivationDate);
                Test.stopTest();                            
                
                                            
               
                                            
                //}catch(Zuora.zRemoteException e) {System.debug(e);}
         }   
         catch(Exception e){}
                
       }
       
       static testMethod void testnewAmmendment() {
               
       try {
            //Test.setMock(WebServiceMock.class, new zLoginMock());      
            //TestData
                String subscriptionId = '123';
                decimal AdminCharge = 10;
                Date ContractEffectiveDate = Date.today();
                Date CustomerAcceptanceDate = Date.today();
                Date EffectiveDate = Date.today();
                Date ServiceActivationDate = Date.today();
                Map<String, Decimal> newMap1 = new Map<String, Decimal>();
                newMap1.put(subscriptionId,AdminCharge);
                Map<String, Date> newMap2 = new Map<String, Date>();
                newMap2.put(subscriptionId,CustomerAcceptanceDate);
                Test.startTest();        
                AdminCharge_Amendment amendForNew = new AdminCharge_Amendment();
                amendForNew.bulkAdminChargeAmendment(newMap1,newMap2);
                
                Test.stopTest();                            
                
                                            
               
                                            
                //}catch(Zuora.zRemoteException e) {System.debug(e);}
         }   
         catch(Exception e){}
                
       }
   
}