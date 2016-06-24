/**********************************************************************/
/* Class Name:  PromotionTriggerHandler_Test
/* @author: Marie Kristine Munda 
/* Description: A test class for PromotionTriggerHandler Class
/* Date Last Modified: 02/06/2014
/**********************************************************************/

@isTest (Seealldata = TRUE)

private class PromotionTriggerHandler_Test{
        
    private static List<Promotion__c> prmList = new List<Promotion__c>();     
    private static List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
    private static List<Package__c> pkgList = new List<Package__c>();
    private static Order__c orderRecord;
    
    
    /************************************/
    /*This method is to test Create Test Data
    /*Oject Account, Order, SingPost are Package, Case, PRomotion, Contact created.
    /************************************/
    static  testmethod void  testPromotionTriggerHandlerData(){
   
   /****************************** Test Data Creation ****************************/
   /*   Insert code statements that inserts Data                                 */
   /*   needed by Base Class.                                                    */
   /*****************************************************************************/
   // Account
   Account acct = new Account(
            Name = 'Test Account'
        );
   insert acct;
        
    //Create Singapore postal 
    Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
        
    //Create Adress   
    Address__c addressRec = TestDataFactory.createAddress(1)[0];
        addressRec.Address_Type__c='P';
        addressRec.Postal_Code__c = postal.Id;
    insert addressRec;
        
   // Contact
   Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = addressRec.Id;
        con.AccountId = acct.Id;
        con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
        con.Recipient_Indicator__c = true;          
    insert con;
        
    //Create Package    
    List<Package__c> packageList = TestDataFactory.createPackage(1);
         for(Package__c item : packageList){
             item.name = 'sample package';
             item.Package_Type__c = 'Discount';
             item.Package_Sub_Type__c = 'Tiered';
             item.Package_code__c = 'T0013ABS';
             item.Effective_Start_Date__c = date.today();
             item.Effective_End_Date__c = date.today().addDays(1);    
         }        
         insert packageList ;
        
          for(Integer i = 0; i < 200; i++){
            pkgList.add(
                new Package__c(
                    Name = 'Test Pkg' + i,
                    Package_Code__c = '000123' + i,
                    Effective_Start_Date__c = Date.today(),
                    Effective_End_Date__c = Date.today().addDays(5)
                    )
                );
            }
        insert pkgList;
        
        Set<Id> packageIds= new Set<Id>();
            for(Package__c pkg: pkgList){
                packageIds.add(pkg.id);
            }
   
        //List Promotion
          List<Promotion__c> promoList = TestDataFactory.createPromotion(1);
            for(Promotion__c item:promoList){
            item.Promotion_Code__c = 'Promo Code';
            item.Name = 'Test Promo';
            item.Effective_Start_Date__c = Date.today();
            item.Effective_End_Date__c = Date.today().addDays(5);
            item.Contract__c='No';
           
            }
         insert promoList;
         System.assertEquals('Promo Code', promoList[0].Promotion_Code__c);
        
        //New promo
            for(Integer i =0; i<200; i++){
            prmList.add(
                new Promotion__c(
                    Promotion_Code__c = 'PromoCode',
                    Name = 'Test Promotion2',
                    Effective_Start_Date__c = Date.today(),
                    Effective_End_Date__c = Date.today().addDays(5),
                    Contract__c ='No'
                    )
                );
            }
             insert prmList;
            System.assertEquals('Test Promotion2', prmList[0].Name );
        
        Set<Id> promoIds = new Set<Id>();
            for(Promotion__c prm : prmList){
                promoIds.add(prm.id);
            }
        //Create Order
          orderRecord = new Order__c(
                Account__c = acct.Id,
                Informed_Customer__c = true,
                Recipient_Contact__c = con.Id,
                Credit_Balance__c = 150.0, 
                Delivery_Charge__c = 50.0, 
                Monthly_Delivery_Charge_for_Full_Payment__c = 10.0
            );
        insert orderRecord;
        system.assertNotEquals(null, orderRecord);          
        
        
        for(Integer i = 0; i < 100; i++){
            oliList.add(
                new Order_Line_Item__c(
                    Promotion_ID__c = prmList[i].Id,
                    Order__c = orderRecord.Id,
                    Delivered_By__c = 'Mailing Agent',
                    Main_Package_Billing_Type__c = 'Recurring Prepaid',
                    Main_Package_Frequency__c = 'TestPackFreq',
                    Main_Package_Sub_Type__c = 'TestSubType',
                    Main_Package_Type__c = 'TestPackType',
                    End_Date__c = Date.today().addDays(30),
                    Main_Package_ID__c = pkgList[i].Id    
                )
            );
        }
        try{
        insert oliList;
        
        }catch (Exception e) {
        System.debug(e.getMessage());
       }//end of catch
        
   
   }//End of testPromotionTriggerHandler Method 
   
   
    /************************************/
    /*This method is to execute testPromotionTriggerHandlerData method
    /************************************/  
   static testMethod void promoTriggerHandlerTest(){
   
        testPromotionTriggerHandlerData();
        Test.startTest();
        
            Promotion__c prom = prmList[0];
            prom.Id = null;
            prom.Promotion_Code__c =  'PromoCode';            
            insert prom;
            System.assertEquals(prom.Promotion_Code__c , 'PromoCode');     
            
            update prom;
            delete oliList;
            delete prmList;
        Test.stopTest();
        
    }//End of promoTriggerHandlerTest
   
}//End of PromotionTriggerHandler_Test