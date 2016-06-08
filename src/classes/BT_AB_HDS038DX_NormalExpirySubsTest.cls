@isTest (seeAllData=false)

public class BT_AB_HDS038DX_NormalExpirySubsTest{

        static testMethod void NormalExpiryTest() { 

                    Other__c dtl = new Other__c(Name='DTL', Value__c='14:00');
                    insert dtl;
                    
                    /*Key_Id__c key = new Key_Id__c();
                    key.Name = 'NEXT_RECIPIENT_NUMBER';
                    key.Id__c = '123457397';
                    key.Type__c = 'Number';
                    insert key;*/
                    
                    Cir_Planner_Schedule__c cirPlanSched = new Cir_Planner_Schedule__c();
                    cirPlanSched.Name = 'CIR Plan Schedule';
                    cirPlanSched.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0); 
                    cirPlanSched.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0); 
                    cirPlanSched.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0); 
                    cirPlanSched.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                    cirPlanSched.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                    cirPlanSched.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0); 
                    insert cirPlanSched;
                    
                    //April BT_CO_Batch_Run_Request__c
                    BT_CO_Batch_Run_Request__c newRequest = new BT_CO_Batch_Run_Request__c();
                    newRequest.Interface_ID__c = 'HDS038DX';
                    newRequest.End_Time__c = null;
                    newRequest.Batch_Run_Date__c = date.today()+3;
                    database.insert(newRequest);
                    
                    Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                    acc.Name ='testaccount';
                    acc.Company_Name__c = 'testcompany';
                    acc.Sub_Group__c = 'Others';
                    acc.Vendor_Group__c = 'T';
                    acc.Vendor_Code__c = 'testt';
                    insert acc; //, RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor Subscriber'));
                                            
                    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    postal.Name = 'testname';
                    postal.Street_Name__c = 'teststreetname';
                    postal.Building_Name__c = 'testbuilding';
                    insert postal;
                    //insert new List<sObject>{postal,acc, pkg[0]};
                    
                    Address__c addressRec = TestDataFactory.createAddress(1)[0];
                    addressRec.Address_Type__c='P';
                    addressRec.Postal_Code__c = postal.Id;
                    addressRec.Block_House_Number__c = '123';
                    addressRec.Level_Number__c = '123';
                    addressRec.Unit_Number__c ='1234';
                    addressRec.Postal_Code__c = postal.id;
                    insert addressRec;
                    
                    List<Contact> con = TestDataFactory.createContact(1);
                    //con[0].Name = 'testname';
                    con[0].Address__c = addressRec.Id;
                    con[0].FirstName = 'test';
                    con[0].LastName = 'testtest';
                    con[0].Recipient_Indicator__c = true;
                    con[0].Phone = '1234567';
                    con[0].AccountId = acc.Id;
                    con[0].Recipient_Number__c = 12345;
                    con[0].Salutation = 'Mr.';
                    // con[0].RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                    insert con;            
                    
                    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                    billAcc.Zuora__Account__c = acc.Id;
                    insert billAcc;
                    
                    // Package__c packageList = TestDataFactory.createPackage(1)[0];
                    //insert packageList;
                    
                    //create order
                    
                    List<Package__c> pack = TestDataFactory.createPackage(2); //new Package__c();
                    //pack = TestDataFactory.createPackage(1)[0];
                    pack[0].Package_Type__c = 'Base';
                    pack[0].Name = 'Test Package';
                    pack[0].Package_Code__c = 'testcode';
                    
                    //april
                    pack[1].Package_Type__c = 'Base';
                    pack[1].Name = 'Test';
                    pack[1].Package_Code__c = 'testcode1';
                    insert pack;      
                    
                    Promotion__c prom = new Promotion__c();
                    prom.Effective_End_Date__c = date.today()+5;
                    prom.Effective_Start_Date__c = date.today();
                    prom.Promotion_Code__c = 'Promo Code';
                    insert prom;
                    
                    Zuora__Subscription__c subRecs = TestDataFactory.createSubscription(1)[0];
                    subRecs.Name = 'BA-S01710546'; //April
                    subRecs.Zuora__Account__c = acc.Id;
                    subRecs.Zuora__CustomerAccount__c = billAcc.Id;
                    subRecs.Main_Package__c = pack[0].Id;
                    subRecs.Main_Package_1__c = pack[0].Id; //April
                    subRecs.Zuora__SubscriptionEndDate__c = date.today()+3;
                    subRecs.Zuora__SubscriptionStartDate__c = date.today()+2;
                    subRecs.Billing_Type__c = 'Full Prepaid';
                    subRecs.Qty1__c = '3.3';
                    subRecs.Qty__c = 3;
                    subRecs.Number_of_Copies__c = 3;
                    subRecs.Delivered_By__c = 'Mailing Agent';
                    subRecs.Term_Length__c = 1;//joy
                    subRecs.Term_Length1__c = '1';//joy
                    subRecs.Subscription_Type__c = 'PUBLICATION';//April 'Pub';
                    subRecs.Zuora__Status__c = 'CANCELLED';
                    subRecs.Recipient_Contact__c = con[0].Id;
                    subRecs.Pub_Tag__c = 'testtag';
                    subRecs.Frequency__c = 'Mon-Fri';
                    subRecs.Product_Code__c = '12PH'; //April'testcode';
                    subRecs.Vendor_1__c = acc.Id;
                    subRecs.Promotion_1__c = prom.Id;
                    //subRecs.Product_Code__c = 'ASC';
                    //subRecs.Effective_Start_Date__c = date.today()+3;
                    //subRecs.Effective_End_Date__c = date.today()+2;
                    //subRecs.Zuora__TermSettingType__c = GlobalVariableClass.SUBSCRIPTION_TYPE_TERMED;
                    //subRecs.Order_Line_Item_Number__c = orderline.Id;
                    // subRecs.Subscription_Type__c = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY; 
                    insert subRecs;
                                        
                    
                    Order__c order = TestDataFactory.createOrder(1)[0];
                    order.Account__c = acc.Id;
                    order.Recipient_Contact__c = con[0].Id;
                    System.debug('DEBUG con.Id' + con[0].Id);
                    order.Informed_Customer__c = True;
                    order.Subscriber_Charge__c = 15;
                    order.Order_Type__c = 'Renewal';
                    order.Base_Subscription__c = subRecs.id;
                    insert order;   
                    
                    Order_Line_Item__c orderline = TestDataFactory.createOrderLineItem(1)[0];
                    orderline.Order__c = order.Id;
                    orderline.End_Date__c = date.today() +8;
                    orderline.Main_Package_ID__c = pack[0].Id;
                    orderline.Term_Length__c = 0;
                    orderline.Main_Package_Period__c = 0;
                    orderline.Earliest_Start_Date__c = date.today();
                    orderline.Earliest_Stop_Date__c = Date.Today().addDays(2);
                    orderline.Stop_Request_Date__c =  date.Today().addDays(4);
                    orderline.Terminating_Reason__c = 'Others';
                    orderline.Amount_To_Refund__c = 0;
                    orderline.Admin_Charge__c = 0;
                    orderline.Fee_Waiver__c = FALSE;
                    orderline.Fee_Override__c = TRUE;
                    orderline.Override_Reason__c = 'TEST';
                    orderline.Suppress_Notification_Stop__c = TRUE;
                    orderline.Main_Package_Type__c = 'Base';
                    orderline.Start_Date__c = date.today()+7;
                    insert orderline;
                    
                    //April start
                    List<Publication__c> pub = TestDataFactory.createPublication(2);
                    pub[0].Name = '12PH';
                    pub[0].Publication_Code__c ='Z234';
                    pub[0].Platform_Type__c ='Print';
                    pub[0].Publication_Type__c ='N';
                    pub[0].Public_Holiday_Weekday_Pub_Indicator__c = true;
                    pub[0].Public_Holiday_Weekend_Pub_Indicator__c = false;
                    
                    pub[1].Name = '12PH';
                    pub[1].Publication_Code__c ='Z234';
                    pub[1].Platform_Type__c ='Print';
                    pub[1].Publication_Type__c ='N';
                    pub[1].Public_Holiday_Weekday_Pub_Indicator__c = false;
                    pub[1].Public_Holiday_Weekend_Pub_Indicator__c = true;
                    database.insert(pub);
                    
                    List<zqu__ZProduct__c> zProduct = TestDataFactory.createZProduct(2);
                    zProduct[0].Productcode__c = '12PH';
                    
                    zProduct[1].Productcode__c = '12PH';
                    database.insert(zProduct);
                    
                    List<zqu__ProductRatePlan__c> prdRatePlan = TestDataFactory.createProductRatePlan(2);
                    prdRatePlan[0].zqu__ZProduct__c = zProduct[0].Id;
                    prdRatePlan[0].RatePlanType__c= 'Bill Plan';
                    prdRatePlan[0].zqu__EffectiveStartDate__c= date.today();
                    prdRatePlan[0].zqu__EffectiveEndDate__c= date.today().addDays(30);
                    prdRatePlan[0].zqu__Deleted__c = false;
                    
                    
                    prdRatePlan[1].zqu__ZProduct__c = zProduct[1].Id;
                    prdRatePlan[1].RatePlanType__c= 'Bill Plan';
                    prdRatePlan[1].zqu__EffectiveStartDate__c= date.today();
                    prdRatePlan[1].zqu__EffectiveEndDate__c= date.today().addDays(30);
                    prdRatePlan[1].zqu__Deleted__c = false;
                    
                    database.insert(prdRatePlan);
                    
                    List<Package_Item__c> packItem = TestDataFactory.createPackageItem(2, 'Base Product');
                    packItem[0].Package__c = pack[0].id;
                    packItem[0].Product_Rate_Plan__c = prdRatePlan[0].id;
                    
                    packItem[1].Package__c = pack[1].id;
                    packItem[1].Product_Rate_Plan__c = prdRatePlan[1].id;
                    database.insert(packItem);
                    
                    List<zqu__ProductRatePlanCharge__c> zprpc =  TestDataFactory.createProductRatePlanCharge(2);
                    zprpc[0].Name = 'Product Rate Plan Charge';
                    zprpc[0].zqu__ProductRatePlan__c = prdRatePlan[0].id;
                    zprpc[0].zqu__ZuoraId__c = '3689922200';
                    zprpc[0].PublicationCode__c = 'Z234';
                    
                    zprpc[1].Name = 'Product Rate Plan Charge';
                    zprpc[1].zqu__ProductRatePlan__c = prdRatePlan[1].id;
                    zprpc[1].zqu__ZuoraId__c = '3689922201';
                    zprpc[1].PublicationCode__c = 'Z235';
                    database.insert(zprpc);
                                        
                    
                    List<Product_Publication__c> prodPub = TestDataFactory.createProductPublication(2);
                    prodPub[0].ZProduct__c = zProduct[0].id;
                    prodPub[0].Publication_Code__c = pub[0].id;
                                       
                    prodPub[1].ZProduct__c = zProduct[1].id;
                    prodPub[1].Publication_Code__c = pub[1].id;
                    database.insert(prodPub);
                    //end
                    
                    BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
                    batchInterfaceSetting.Name = 'Endpoint Delegator';
                    batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
                    insert batchInterfaceSetting;
                    
                    
                    BA_INT_DATA_POOL__c bidp = new BA_INT_DATA_POOL__c();
                    bidp.name = 'dfdf';
                    bidp.job_id__c = 'sdfsdf';
                    bidp.group_id__c = 'sdfse';
                    bidp.run_for_date__c = system.today();
                    bidp.insert_time__c = system.now();
                    insert bidp;
                    
                    
                    BT_AB_HDS038DX_NormalExpirySubscriptions batch = new BT_AB_HDS038DX_NormalExpirySubscriptions();
                    ID batchprocessid = Database.executeBatch(batch,200);
                    System.assertNotEquals(null, batchprocessid);
                    
                    BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate('2');

        }

}