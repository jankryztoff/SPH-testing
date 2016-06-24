/**
 * @Class Name: BT_TH_STP050DX_StopPressSubsTest
 * @author: April Veloso
 * @Date: 4/8/2016
 * @Requirement/Project Name: Singapore Press Holdings
 * @ test class for BT_TH_STP050DX_StopPressSubscription
 * @History:
 * Erika Hidalgo 05/11/2016 
 */


@isTest (SeeAllData = True)
public class BT_TH_STP050DX_StopPressSubsTest{

    static testMethod void validInsertStopPress(){
                   
                  Package__c packageRecord = new Package__c(Name='Test Package1', Package_Type__c='Base',
                                                      Subscription_Type__c='Termed', Package_Code__c='PackageCode1',
                                                      Product_Family_Current_Package__c = '1', Effective_Start_Date__c=date.today(), 
                                                      Effective_End_Date__c=date.today()+100, Subscription_Period__c='123', Package_Price__c = 10.50, Billing_Type__c = 'Full Prepaid');    
                   insert packageRecord;
                   
                   
                   zqu__ZProduct__c product = TestDataFactory.createZProduct(1)[0];
                   insert product;
                                          
                   zqu__ProductRatePlan__c productRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                   productRatePlan.zqu__ZProduct__c = product.id;
                   insert productRatePlan;
                   
                   zqu__ProductRatePlanCharge__c productRatePlanChargeRecord = new zqu__ProductRatePlanCharge__c(Name='Test Product Rate Plan Charge1', zqu__ZuoraId__c='ZID1', zqu__ProductRatePlan__c = productRatePlan.Id);
                   insert productRatePlanChargeRecord;
                   
                  Product_Publication__c productPublicationRecord = new Product_Publication__c();
                  productPublicationRecord.ZProduct__c = product.Id;
                   insert  productPublicationRecord;
                    
                  Package_Item__c packageItemRecord = new Package_Item__c(Name='Test Package Item1', RecordTypeId = ConstantsSLB.getKeyID('Package Item_Base Product'), 
                                                                         Package__c =  packageRecord.id, Product_Rate_Plan__c = productRatePlan.id );
                  insert packageItemRecord;
                  
                  Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    postal.Name = '1245';
                    postal.Building_Name__c = 'Ebloc2';
                    insert postal;
                    
               
                    
                   BT_CO_STPPRS_StopPressSubscription__c so = new BT_CO_STPPRS_StopPressSubscription__c();
                   so.Validation_Status__c = 'Passed';
                   so.subscription_package_code__c = packageRecord.Package_Code__c;
                   so.subscriber_house_level_number__c = '123';
                   so.recipient_house_level_number__c = '132';
                   so.subscriber_house_unit_number__c =  '12';
                   so.recipient_house_unit_number__c = '124';
                   so.subscriber_type__c  = 'IP';
                   so.online_order_num__c = 'Testing111111-1';
                   so.subscriber_hphnn__c = '02345678';
                   so.subscriber_home_tel_number__c = '08333797';
                   so.subscriber_office_tel_number__c = '27487';
                   so.subscriber_office_ext_number__c = '24334';
                   so.subscriber_fax_number__c = '12345';
                   so.subscriber_date_of_birth__c =  '1.1.1997';
                   so.subscriber_email_id__c =  'test@test.com';
                   so.subscriber_name__c = 'TestSO';
                   so.subscriber_house_block_number__c = '434' ;
                   so.subscriber_postal_code__c = postal.Name;
                   so.subscriber_country_code__c = GlobalVariableClass.SINGAPORE_CODE;
                   so.subscriber_overseas_add1__c = '32434';
                   so.subscriber_overseas_add2__c = '34343';
                   so.subscriber_overseas_add3__c = '4545';
                   so.subscriber_overseas_add4__c = '324324';
                   so.referred_start_date__c = '2.2.2050';
                   so.sub_period__c = '1';

                   test.startTest();
                     try{
                         insert so;
                         
                     }catch(Exception ex){
                          System.debug('Exception - ' + ex.getMessage());
                     }
                   test.stopTest(); 
    }
    
    static testMethod void validUpdateStopPress(){
                   
                  Package__c packageRecord = new Package__c(Name='Test Package1', Package_Type__c='Base',
                                                      Subscription_Type__c='Termed', Package_Code__c='PackageCode1',
                                                      Product_Family_Current_Package__c = '1', Effective_Start_Date__c=date.today(), 
                                                      Effective_End_Date__c=date.today()+100, Subscription_Period__c='123', Package_Price__c = 10.50, Billing_Type__c = 'Full Prepaid');    
                   insert packageRecord;
                   
                   
                   zqu__ZProduct__c product = TestDataFactory.createZProduct(1)[0];
                   insert product;
                                          
                   zqu__ProductRatePlan__c productRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                   productRatePlan.zqu__ZProduct__c = product.id;
                   insert productRatePlan;
                   
                   zqu__ProductRatePlanCharge__c productRatePlanChargeRecord = new zqu__ProductRatePlanCharge__c(Name='Test Product Rate Plan Charge1', zqu__ZuoraId__c='ZID1', zqu__ProductRatePlan__c = productRatePlan.Id);
                   insert productRatePlanChargeRecord;
                   
                  Product_Publication__c productPublicationRecord = new Product_Publication__c();
                  productPublicationRecord.ZProduct__c = product.Id;
                   insert  productPublicationRecord;
                    
                  Package_Item__c packageItemRecord = new Package_Item__c(Name='Test Package Item1', RecordTypeId = ConstantsSLB.getKeyID('Package Item_Base Product'), 
                                                                         Package__c =  packageRecord.id, Product_Rate_Plan__c = productRatePlan.id );
                  insert packageItemRecord;
                  
                  Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    postal.Name = '1245';
                    postal.Building_Name__c = 'Ebloc2';
                    insert postal;
                    
               
                    
                   BT_CO_STPPRS_StopPressSubscription__c so = new BT_CO_STPPRS_StopPressSubscription__c();
                   so.Validation_Status__c = 'Passed';
                   so.subscription_package_code__c = packageRecord.Package_Code__c;
                   so.subscriber_house_level_number__c = '123';
                   so.recipient_house_level_number__c = '132';
                   so.subscriber_house_unit_number__c =  '12';
                   so.recipient_house_unit_number__c = '124';
                   so.subscriber_type__c  = 'IP';
                   so.online_order_num__c = 'Testing111111-1';
                   so.subscriber_hphnn__c = '02345678';
                   so.subscriber_home_tel_number__c = '08333797';
                   so.subscriber_office_tel_number__c = '27487';
                   so.subscriber_office_ext_number__c = '24334';
                   so.subscriber_fax_number__c = '12345';
                   so.subscriber_date_of_birth__c =  '1.1.1997';
                   so.subscriber_email_id__c =  'test@test.com';
                   so.subscriber_name__c = 'Test SO SO';
                   so.subscriber_house_block_number__c = '434' ;
                   so.subscriber_postal_code__c = postal.Name;
                   so.subscriber_country_code__c = 'AB';
                   so.subscriber_overseas_add1__c = '32434';
                   so.subscriber_overseas_add2__c = '34343';
                   so.subscriber_overseas_add3__c = '4545';
                   so.subscriber_overseas_add4__c = '324324';
                   so.referred_start_date__c = '2.2.2050';
                   so.sub_period__c = '1';

                   insert so;

                   test.startTest();
                     try{
                         
                        update so; 
                     }catch(Exception ex){
                          System.debug('Exception - ' + ex.getMessage());
                     }
                   test.stopTest(); 
    }
    
    static testMethod void validUpdateStopPressWithOrderLineItem(){
                   
                  Package__c packageRecord = new Package__c(Name='Test Package1', Package_Type__c='Base',
                                                      Subscription_Type__c='Termed', Package_Code__c='PackageCode1',
                                                      Product_Family_Current_Package__c = '1', Effective_Start_Date__c=date.today(), 
                                                      Effective_End_Date__c=date.today()+100, Subscription_Period__c='123', Package_Price__c = 10.50, Billing_Type__c = 'Full Prepaid');    
                   insert packageRecord;
                   
                   
                   zqu__ZProduct__c product = TestDataFactory.createZProduct(1)[0];
                   insert product;
                                          
                   zqu__ProductRatePlan__c productRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                   productRatePlan.zqu__ZProduct__c = product.id;
                   insert productRatePlan;
                   
                   zqu__ProductRatePlanCharge__c productRatePlanChargeRecord = new zqu__ProductRatePlanCharge__c(Name='Test Product Rate Plan Charge1', zqu__ZuoraId__c='ZID1', zqu__ProductRatePlan__c = productRatePlan.Id);
                   insert productRatePlanChargeRecord;
                   
                  Product_Publication__c productPublicationRecord = new Product_Publication__c();
                  productPublicationRecord.ZProduct__c = product.Id;
                   insert  productPublicationRecord;
                    
                  Package_Item__c packageItemRecord = new Package_Item__c(Name='Test Package Item1', RecordTypeId = ConstantsSLB.getKeyID('Package Item_Base Product'), 
                                                                         Package__c =  packageRecord.id, Product_Rate_Plan__c = productRatePlan.id );
                  insert packageItemRecord;
                  
                  Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    postal.Name = '1245';
                    postal.Building_Name__c = 'Ebloc2';
                    insert postal;
                    
                  Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                  acc.RecordTypeId = [SELECT Id from Recordtype WHERE sObjectType = 'Account' and Name = 'Direct Corporate'].id;
                  insert acc;
                    
                  Order__c orderRecord = new Order__c(Account__c =  acc.Id, Delivery_Charge__c=100.00, Credit_Balance__c=20000.00, Monthly_Delivery_Charge_for_Full_Payment__c=100.00);
                  insert orderRecord;
                  
                  Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
                  orderLineItem.Order__c = orderRecord.id;
                  orderLineItem.Main_Package_ID__c =  packageRecord.id;
                  orderLineItem.Online_Order_Number__c = 'Testing111111-1';
                  
                  insert orderLineItem;
                  
               
                    
                   BT_CO_STPPRS_StopPressSubscription__c so = new BT_CO_STPPRS_StopPressSubscription__c();
                   so.Validation_Status__c = 'Passed';
                   so.subscription_package_code__c = packageRecord.Package_Code__c;
                   so.subscriber_house_level_number__c = '123';
                   so.recipient_house_level_number__c = '132';
                   so.subscriber_house_unit_number__c =  '12';
                   so.recipient_house_unit_number__c = '124';
                   so.subscriber_type__c  = 'IP';
                   so.online_order_num__c = orderLineItem.Online_Order_Number__c;
                   so.subscriber_hphnn__c = '02345678';
                   so.subscriber_home_tel_number__c = '08333797';
                   so.subscriber_office_tel_number__c = '27487';
                   so.subscriber_office_ext_number__c = '24334';
                   so.subscriber_fax_number__c = '12345';
                   so.subscriber_date_of_birth__c =  '1.1.1997';
                   so.subscriber_email_id__c =  'test@test.com';
                   so.subscriber_name__c = 'Test SO SO';
                   so.subscriber_house_block_number__c = '434' ;
                   so.subscriber_postal_code__c = postal.Name;
                   so.subscriber_country_code__c = 'AB';
                   so.subscriber_overseas_add1__c = '32434';
                   so.subscriber_overseas_add2__c = '34343';
                   so.subscriber_overseas_add3__c = '4545';
                   so.subscriber_overseas_add4__c = '324324';
                   so.referred_start_date__c = '2.2.2050';
                   so.sub_period__c = '1';

                   insert so;

                   test.startTest();
                     try{
                         
                        update so; 
                     }catch(Exception ex){
                          System.debug('Exception - ' + ex.getMessage());
                     }
                   test.stopTest(); 
    }
    
    
    static testMethod void insertStopPressWithoutPackageItem(){
                   
                  Package__c packageRecord = new Package__c(Name='Test Package1', Package_Type__c='Base',
                                                      Subscription_Type__c='Termed', Package_Code__c='PackageCode1',
                                                      Product_Family_Current_Package__c = '1', Effective_Start_Date__c=date.today(), 
                                                      Effective_End_Date__c=date.today()+100, Subscription_Period__c='123', Package_Price__c = 10.50, Billing_Type__c = 'Full Prepaid');    
                   insert packageRecord;
                   
                   
                   zqu__ZProduct__c product = TestDataFactory.createZProduct(1)[0];
                   insert product;
                                          
                   zqu__ProductRatePlan__c productRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                   productRatePlan.zqu__ZProduct__c = product.id;
                   insert productRatePlan;
                   
                   zqu__ProductRatePlanCharge__c productRatePlanChargeRecord = new zqu__ProductRatePlanCharge__c(Name='Test Product Rate Plan Charge1', zqu__ZuoraId__c='ZID1', zqu__ProductRatePlan__c = productRatePlan.Id);
                   insert productRatePlanChargeRecord;
                   
                  Product_Publication__c productPublicationRecord = new Product_Publication__c();
                  productPublicationRecord.ZProduct__c = product.Id;
                   insert  productPublicationRecord;
                    
                
                  Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    postal.Name = '1245';
                    postal.Building_Name__c = 'Ebloc2';
                    insert postal;

                   BT_CO_STPPRS_StopPressSubscription__c so = new BT_CO_STPPRS_StopPressSubscription__c();
                   so.Validation_Status__c = 'Passed';
                   so.subscription_package_code__c = packageRecord.Package_Code__c;
                   so.subscriber_house_level_number__c = '123';
                   so.recipient_house_level_number__c = '132';
                   so.subscriber_house_unit_number__c =  '12';
                   so.recipient_house_unit_number__c = '124';
                   so.subscriber_type__c  = 'IP';
                   so.online_order_num__c = 'Testing111111-1';
                   so.subscriber_hphnn__c = '02345678';
                   so.subscriber_home_tel_number__c = '08333797';
                   so.subscriber_office_tel_number__c = '27487';
                   so.subscriber_office_ext_number__c = '24334';
                   so.subscriber_fax_number__c = '12345';
                   so.subscriber_date_of_birth__c =  '1.1.1997';
                   so.subscriber_email_id__c =  'test@test.com';
                   so.subscriber_name__c = 'TestSO';
                   so.subscriber_house_block_number__c = '434' ;
                   so.subscriber_postal_code__c = postal.Name;
                   so.subscriber_country_code__c = GlobalVariableClass.SINGAPORE_CODE;
                   so.subscriber_overseas_add1__c = '32434';
                   so.subscriber_overseas_add2__c = '34343';
                   so.subscriber_overseas_add3__c = '4545';
                   so.subscriber_overseas_add4__c = '324324';
                   so.referred_start_date__c = '2.2.2050';
                   so.sub_period__c = '1';

                   test.startTest();
                     try{
                         insert so;
                         
                     }catch(Exception ex){
                          System.debug('Exception - ' + ex.getMessage());
                     }
                   test.stopTest(); 
    }
    
    static testMethod void invalidStopPressSubscription(){
                   
                   List<BT_CO_STPPRS_StopPressSubscription__c> recordsList = new List<BT_CO_STPPRS_StopPressSubscription__c>();
                   BT_CO_STPPRS_StopPressSubscription__c so1 = new BT_CO_STPPRS_StopPressSubscription__c(Validation_Status__c = 'Passed', subscription_package_code__c = 'PC01', online_order_num__c = '102102' );
                   BT_CO_STPPRS_StopPressSubscription__c so2 = new BT_CO_STPPRS_StopPressSubscription__c(Validation_Status__c = 'Passed', subscription_package_code__c = 'PC02', online_order_num__c = '102103' );
                  
                   recordsList.add(so1);
                   recordsList.add(so2);
                   
                   
                   test.startTest();
                        try{
                          insert recordsList;
                        }catch(exception ex){
                             System.debug('Exception - ' + ex.getMessage());
                        }  
                      
                   test.stopTest(); 
    }
    
    static testMethod void stopPressWithoutOnlineOrderNum(){
                  Package__c packageRecord = new Package__c(Name='Test Package1', Package_Type__c='Base',
                                                      Subscription_Type__c='Termed', Package_Code__c='PackageCode1',
                                                      Product_Family_Current_Package__c = '1', Effective_Start_Date__c=date.today(), 
                                                      Effective_End_Date__c=date.today()+100, Subscription_Period__c='123', Package_Price__c = 10.50, Billing_Type__c = 'Full Prepaid');    
                   insert packageRecord;
                   
                   
                   zqu__ZProduct__c product = TestDataFactory.createZProduct(1)[0];
                   insert product;
                                          
                   zqu__ProductRatePlan__c productRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                   productRatePlan.zqu__ZProduct__c = product.id;
                   insert productRatePlan;
                   
                   zqu__ProductRatePlanCharge__c productRatePlanChargeRecord = new zqu__ProductRatePlanCharge__c(Name='Test Product Rate Plan Charge1', zqu__ZuoraId__c='ZID1', zqu__ProductRatePlan__c = productRatePlan.Id);
                   insert productRatePlanChargeRecord;
                   
                  Product_Publication__c productPublicationRecord = new Product_Publication__c();
                  productPublicationRecord.ZProduct__c = product.Id;
                   insert  productPublicationRecord;
                    
                  Package_Item__c packageItemRecord = new Package_Item__c(Name='Test Package Item1', RecordTypeId = ConstantsSLB.getKeyID('Package Item_Base Product'), 
                                                                         Package__c =  packageRecord.id, Product_Rate_Plan__c = productRatePlan.id );
                  insert packageItemRecord;
                   BT_CO_STPPRS_StopPressSubscription__c so1 = new BT_CO_STPPRS_StopPressSubscription__c(Validation_Status__c = 'Passed', subscription_package_code__c = 'PC01');
                   
                   
                   test.startTest();
                        try{
                          insert so1;
                        }catch(exception ex){
                             System.debug('Exception - ' + ex.getMessage());
                        }  
                      
                   test.stopTest(); 
    }
    
    
      static testMethod void invalidContactRecordAndPhoneNumbers(){
     
                  Package__c packageRecord = new Package__c(Name='Test Package1', Package_Type__c='Base',
                                                      Subscription_Type__c='Termed', Package_Code__c='PackageCode1',
                                                      Product_Family_Current_Package__c = '1', Effective_Start_Date__c=date.today(), 
                                                      Effective_End_Date__c=date.today()+100, Subscription_Period__c='N/A', Package_Price__c = 10.50, Billing_Type__c = 'Full Prepaid');    
                   insert packageRecord;
                   
                   
                   zqu__ZProduct__c product = TestDataFactory.createZProduct(1)[0];
                   insert product;
                                          
                   zqu__ProductRatePlan__c productRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                   productRatePlan.zqu__ZProduct__c = product.id;
                   insert productRatePlan;
                   
                   zqu__ProductRatePlanCharge__c productRatePlanChargeRecord = new zqu__ProductRatePlanCharge__c(Name='Test Product Rate Plan Charge1', zqu__ZuoraId__c='ZID1', zqu__ProductRatePlan__c = productRatePlan.Id);
                   insert productRatePlanChargeRecord;
                   
                  Product_Publication__c productPublicationRecord = new Product_Publication__c();
                  productPublicationRecord.ZProduct__c = product.Id;
                   insert  productPublicationRecord;
                    
                  Package_Item__c packageItemRecord = new Package_Item__c(Name='Test Package Item1', RecordTypeId = ConstantsSLB.getKeyID('Package Item_Base Product'), 
                                                                         Package__c =  packageRecord.id, Product_Rate_Plan__c = productRatePlan.id );
                  insert packageItemRecord;
                  
                  Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    postal.Name = '1245';
                    postal.Building_Name__c = 'Ebloc2';
                    insert postal;
                    
               
                   BT_CO_STPPRS_StopPressSubscription__c so = new BT_CO_STPPRS_StopPressSubscription__c();
                   so.Validation_Status__c = 'Passed';
                   so.subscription_package_code__c = packageRecord.Package_Code__c;
                   so.subscriber_house_level_number__c = '1';
                   so.recipient_house_level_number__c = '3';
                   so.subscriber_house_unit_number__c =  '1';
                   so.recipient_house_unit_number__c = '2';
                   so.subscriber_type__c  = 'IS';
                   so.online_order_num__c = 'Testing111111-1';
                   so.subscriber_date_of_birth__c =  '1.1.1997';
                   so.subscriber_name__c = 'Test SO SO';
                   so.subscriber_house_block_number__c = '434' ;
                   so.subscriber_postal_code__c = '122';
                   so.subscriber_country_code__c = '243432';
                   so.subscriber_overseas_add1__c = '32434';
                   so.subscriber_overseas_add2__c = '34343';
                   so.subscriber_overseas_add3__c = '4545';
                   so.subscriber_overseas_add4__c = '324324';
                   so.referred_start_date__c = '2.2.2050';
                   so.sub_period__c = '1';
                   so.subscriber_office_ext_number__c = '12345';

                   test.startTest();
                     try{
                         insert so;
                         
                     }catch(Exception ex){
                          System.debug('Exception - invalidContactRecordAndPhoneNumbers' + ex.getMessage());
                     }
                   test.stopTest(); 

    }
    
    static testMethod void soDifferentSubscriberType(){
     
                  Package__c packageRecord = new Package__c(Name='Test Package1', Package_Type__c='Base',
                                                      Subscription_Type__c='Termed', Package_Code__c='PackageCode1',
                                                      Product_Family_Current_Package__c = '1', Effective_Start_Date__c=date.today(), 
                                                      Effective_End_Date__c=date.today()+100, Subscription_Period__c='N/A', Package_Price__c = 10.50, Billing_Type__c = 'Full Prepaid');    
                   insert packageRecord;
                   
                   
                   zqu__ZProduct__c product = TestDataFactory.createZProduct(1)[0];
                   insert product;
                                          
                   zqu__ProductRatePlan__c productRatePlan = TestDataFactory.createProductRatePlan(1)[0];
                   productRatePlan.zqu__ZProduct__c = product.id;
                   insert productRatePlan;
                   
                   zqu__ProductRatePlanCharge__c productRatePlanChargeRecord = new zqu__ProductRatePlanCharge__c(Name='Test Product Rate Plan Charge1', zqu__ZuoraId__c='ZID1', zqu__ProductRatePlan__c = productRatePlan.Id);
                   insert productRatePlanChargeRecord;
                   
                  Product_Publication__c productPublicationRecord = new Product_Publication__c();
                  productPublicationRecord.ZProduct__c = product.Id;
                   insert  productPublicationRecord;
                    
                  Package_Item__c packageItemRecord = new Package_Item__c(Name='Test Package Item1', RecordTypeId = ConstantsSLB.getKeyID('Package Item_Base Product'), 
                                                                         Package__c =  packageRecord.id, Product_Rate_Plan__c = productRatePlan.id );
                  insert packageItemRecord;
                  
                  Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    postal.Name = '1245';
                    postal.Building_Name__c = 'Ebloc2';
                    insert postal;
                    
               
                    
                   BT_CO_STPPRS_StopPressSubscription__c so = new BT_CO_STPPRS_StopPressSubscription__c();
                   so.Validation_Status__c = 'Passed';
                   so.subscription_package_code__c = packageRecord.Package_Code__c;
                   so.subscriber_house_level_number__c = '1';
                   so.recipient_house_level_number__c = '34';
                   so.subscriber_house_unit_number__c =  '1';
                   so.recipient_house_unit_number__c = '24';
                   so.subscriber_type__c  = 'TE';
                   so.online_order_num__c = 'Testing111111-1';
                   so.subscriber_date_of_birth__c =  '1.1.1997';
                   so.subscriber_name__c = 'TestSO';
                   so.subscriber_house_block_number__c = '434' ;
                   so.subscriber_postal_code__c = postal.Name;
                   so.subscriber_country_code__c = '243432';
                   so.subscriber_overseas_add1__c = '32434';
                   so.subscriber_overseas_add2__c = '34343';
                   so.subscriber_overseas_add3__c = '4545';
                   so.subscriber_overseas_add4__c = '324324';
                   so.referred_start_date__c = '2.2.2050';
                   so.sub_period__c = '1';

                   test.startTest();
                     try{
                         insert so;
                         
                     }catch(Exception ex){
                          System.debug('Exception - ' + ex.getMessage());
                     }
                   test.stopTest(); 

    }
    
      static testMethod void createCaseTest(){
                   
                   BT_CO_STPPRS_StopPressSubscription__c so = new BT_CO_STPPRS_StopPressSubscription__c();
                   so.Validation_Status__c = 'Passed';
                   so.subscription_package_code__c = 'PC01';
                   so.online_order_num__c = '102102';
                   database.insert(so);
                   
                   Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
                    acc.RecordTypeId = [SELECT Id from Recordtype WHERE sObjectType = 'Account' and Name = 'Direct Corporate'].id;
                    insert acc;
                    
                    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                    postal.Name = 'Name';
                    postal.Building_Name__c = 'Ebloc2';
                    insert postal;
                    
                    Country__c country = TestDataFactory.createCountry(1)[0]; 
                    country.Country_Name__c = 'SINGAPORE'; 
                    insert country;
                    
                    Address__c address = TestDataFactory.createAddress(1)[0];
                    //address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
                    address.Block_House_Number__c =  'TEST';
                    address.Postal_Code__c = postal.id;
                    address.Level_Number__c = '17';
                    address.Unit_Number__c = 'Unit 5';
                    address.Country__c = country.id;
                    
                    //address.RecordType.Id = getRecordType('Address_Internal', 'Address__c').id;
                    
                    insert address;
                    
                    Contact con = TestDataFactory.createContact(1)[0];
                    con.AccountId = acc.Id;
                    con.Address__c = address.id;
                    con.Recipient_Indicator__c = true;
                   // con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                    insert con;
                    
                     
                    List<Zuora__CustomerAccount__c> billAccountList = TestDataFactory.createBillingAccount(1);
                    billAccountList[0].name = 'April Summer';
                    //billAccountList [0].id = zInv.id;
                    billAccountList[0].Zuora__Account__c = acc.id; 
                    billAccountList[0].Billing_Contact__c = con.id;
                    billAccountList[0].ARMS_Account_Number__c = '027101021';
                    billAccountList[0].Other_PaymentMethod__c ='Invoice';
                    billAccountList[0].ARMS_Total_Outstanding_Amount__c = 100.00;
                    billAccountList[0].Attention_To_Care_Of_Salutation__c = 'MR';
                    billAccountList[0].Billing_Type__c = 'Recurring Prepaid';
                    billAccountList[0].Payment_Mode__c = 'CREDITCARD';
                    insert billAccountList;
                    
                    Package__c pack = new Package__c(Name='Test Package1', Package_Type__c='Base',
                                                      Subscription_Type__c='Termed', Package_Code__c='PackageCode1',
                                                      Product_Family_Current_Package__c = '1', Effective_Start_Date__c=date.today(), 
                                                      Effective_End_Date__c=date.today()+100, Subscription_Period__c='N/A', Package_Price__c = 10.50, Billing_Type__c = 'Full Prepaid');  
                    insert pack;
                   
                    Zuora__Subscription__c zSub = TestDataFactory.createSubscription(1)[0];
                    zSub.Name = 'NUM124';
                    zSub.Billing_Type__c = 'Full Prepaid';
                    zSub.Zuora__CustomerAccount__c = billAccountList[0].id;
                    zSub.Subscription_Type_1__c = 'Publication';
                    zSub.Subscription_Type__c = 'Publication';
                    zSub.Zuora__Account__c = acc.id;
                    
                    zSub.Recipient_Contact__c = con.id;
                    
                    zSub.Zuora__SubscriptionStartDate__c = date.Today() + 1;
                    zSub.Zuora__SubscriptionEndDate__c = date.Today() + 5;
                    
                    zSub.Term_Length__c = 1;
                    zSub.Term_Length1__c = '1';
                    zSub.Main_Package_1__c = pack.id;
                    zSub.Main_Package__c = pack.id;
                    insert zSub; 
                  
                                      
                    Order__c order = TestDataFactory.createOrder(1)[0];
                    order.Account__c = acc.Id;
                    order.Informed_Customer__c = TRUE;
                    order.Recipient_Contact__c = con.Id;
                    order.Subscriber_Charge__c = 100.00;
                    order.Base_Subscription__c = zSub.id;
                    order.Status__c = 'Void';
                    order.Billing_Account__c = billAccountList[0].id;
                    order.Billing_Type__c = 'Recurring Prepaid';
                    //order.Order_Type__c = ConstantsSLB.getOTher('Change of Subscription');
                  //  order.Order_Type__c = 'Renewal'; //= ConstantsSLB.getOther('Order_Type Renewal');
                   // order.Urgent_Stop__c = false;
                   // order.isWaive__c = true;
                    insert order;
                    
                    Order_Line_Item__c orderLineItem = TestDataFactory.createOrderLineItem(1)[0];
                    orderLineItem.Order__c = order.id;
                    orderLineItem.Start_Date__c = zSub.Zuora__SubscriptionEndDate__c.addDays(1);
                    orderLineItem.Main_Package_ID__c = pack.id;
                    orderLineItem.Subscription__c = zSub.id;
                    orderLineItem.Online_Order_Number__c = order.id;
                    database.insert(orderLineItem);
                    
                   List<BT_CO_STPPRS_StopPressSubscription__c> recordsList = new List<BT_CO_STPPRS_StopPressSubscription__c>();
                   recordsList.add(so);
                   //database.insert(recordsList);

                   List<Package__c> packList = [SELECT Id, Billing_Type__c, Package_Sub_Type__c, Package_Type__c, Subscription_Period__c, Subscription_Type__c, Product_Family_Current_Package__c, Package_Price__c, Package_Code__c FROM Package__c WHERE Package_Code__c = :so.subscription_package_code__c];        
                  // System.assertEquals(packList.size(), -1);
                
                   test.startTest();
                     try{
                         
                        BT_TH_STP050DX_StopPressSubscription.createCase(order);
                        BT_TH_STP050DX_StopPressSubscription.getOrderBillingAccount(order);
                        BT_TH_STP050DX_StopPressSubscription.cloneOrder(order, billAccountList[0].id);
           
                     }catch(Exception ex){
                          System.debug('Exception - ' + ex.getMessage());
                     }
                   test.stopTest(); 
    }
    
  
}