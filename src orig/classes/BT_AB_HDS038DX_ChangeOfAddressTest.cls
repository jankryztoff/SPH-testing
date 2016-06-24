@isTest 
private class BT_AB_HDS038DX_ChangeOfAddressTest{
    static testMethod void testBT_AB_HDS038DX_ChangeOfAddress(){
        //custom settings setup 
  
        BT_CO_Batch_Run_Request__c btCobatchRunReq = new BT_CO_Batch_Run_Request__c();
        btCobatchRunReq.Interface_ID__c = 'HDS038DX';
        // btCobatchRunReq.Batch_Run_Date__c = Date.today()+1;

        insert btCobatchRunReq;

        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);

        BT_CS_Interface_Parameters__c btIntParam = new BT_CS_Interface_Parameters__c();
        btIntParam.Name = 'Default Timestamp';
        btIntParam.Value__c = 'T16:00:00.000Z';
        btIntParam.Description__c = 'Default timestamp value of T11:00:00.000Z';
        insert btIntParam;
        
        List<Other__c> otherList = new List<Other__c>{
            new Other__c(Name='DTL', Value__c='23:59')
        };
        database.insert(otherList);
        
        BatchInterface_Settings__c bs = new BatchInterface_Settings__c();
        bs.Name = 'Endpoint Delegator';
        bs.Value__c = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
        database.insert(bs);
        
        //create account
        //Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
        database.insert(acc);
        
        //create address
        Address__c ad = TestDataFactory.createAddress(1)[0];
        database.insert(ad);
        
        //create contact
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = ad.id;
        database.insert(con);
        
        Billing_Batch__c billingBatch = new Billing_Batch__c();
        billingBatch.Next_Batch_Number__c = 14;
        billingBatch.Batch__c = '13,14,15';
        billingBatch.Name = 'Full Prepaid';
        insert billingBatch;


        //create billing account
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        billAcc.Billing_Type__c = 'Full Prepaid';
        database.insert(billAcc);
         
        //create zProduct
        zqu__ZProduct__c zp = TestDataFactory.createZProduct(1)[0];
        zp.ProductType__c = 'Product';
        zp.ProductCode__c = 'BT';
        zp.ProductFamily__c = 'BT';
        database.insert(zp);
         
        //create package
        Package__c pack = TestDataFactory.createPackage(1)[0];
        database.insert(pack);
        
        //create subscription        
        List<Zuora__Subscription__c> subs = TestDataFactory.createSubscription(2);
        for(Zuora__Subscription__c sub: subs){
            sub.Zuora__CustomerAccount__c = billAcc.Id;
            sub.Zuora__Account__c = acc.id;
            sub.Main_Package__c = pack.Id;        
            sub.Main_Package_1__c = pack.Id;
            sub.Recipient_Contact__c = con.id;
            sub.Frequency_1__c = 'Mon-Fri';
            sub.Zuora__Status__c = 'Active';
            sub.Zuora__SubscriptionStartDate__c = date.today();
            sub.Subscription_Type_1__c = 'Publication';
            sub.Subscription_Type__c = 'Publication';
            sub.Term_Length__c = 1;
            sub.Term_Length1__c = '1';
            sub.Product_Code__c = 'BT';
            sub.Delivered_By_1__c = 'Vendor';
        }
        database.insert(subs);
              
        //create case
        Id casRecordTypeId1 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Change of Address/Vendor').getRecordTypeId();
        Id casRecordTypeId2 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Change of Subscription').getRecordTypeId();
        Id casRecordTypeId3 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Renewal of Subscription').getRecordTypeId();

        Set<Id> caseSet = new Set<Id>();
        List<Case> cas = new List<Case>();//TestDataFactory.createCase(1, 'Change of Address/Vendor')[0];
        for(integer i = 0; i < 3; i++){
            
            Case casrec = new Case();
            casrec.Account__c = acc.id;
            casrec.Change_of_Address_Type__c = 'Change of Vendor';
            casrec.Contact_To_Update__c = con.id; //added
            casrec.Subscription_Name__c = subs[0].id;
            casrec.Vendor__c = acc.id; //added
            casrec.Status = 'Closed';
            casrec.Effective_Date__c = Date.today()+1;
            casrec.Sub_Status__c = 'Approved';

            if(i==1){
                casrec.RecordTypeId = casRecordTypeId2;
            }else if(i == 2){
                casrec.RecordTypeId = casRecordTypeId3;
            }else{
                casrec.RecordTypeId = casRecordTypeId1;
            }

            cas.add(casrec);
        } 
        

        // cas[1].Account__c = acc.id;
        // cas[1].RecordTypeId = casRecordTypeId2;
        // cas[1].Change_of_Address_Type__c = '';
        // cas[1].Contact_To_Update__c = con.id; //added
        // cas[1].Subscription_Name__c = subs[0].id;
        // cas[1].Vendor__c = acc.id; //added
        // cas[1].Status = 'Closed';
        // cas[1].Effective_Date__c = Date.today()+1;
        // cas[1].Sub_Status__c = 'Approved';

        // cas[2].Account__c = acc.id;
        // cas[2].RecordTypeId = casRecordTypeId3;
        // cas[2].Change_of_Address_Type__c = '';
        // cas[2].Contact_To_Update__c = con.id; //added
        // cas[2].Subscription_Name__c = subs[0].id;
        // cas[2].Vendor__c = acc.id; //added
        // cas[2].Status = 'Closed';
        // cas[2].Effective_Date__c = Date.today()+1;
        // cas[2].Sub_Status__c = 'Approved';

        database.insert(cas);
        caseSet.add(cas[0].Id);
        caseSet.add(cas[1].Id);
        caseSet.add(cas[2].Id);

        List<Case> checkSubDate = [Select RecordType.DeveloperName, Subscription_Start_Date__c from Case where Id IN: caseSet];
        
        //create address assignment
        Address_Assignment__c aa = new Address_Assignment__c();
        aa.Case__c = cas[0].Id;
        aa.Address__c = ad.Id;
        aa.Vendor__c = acc.Id;
        aa.Contact__c = con.Id;
        aa.Effective_Date__c = date.today()+2;
        database.insert(aa);
        
          //create case subscription
        List<Case_Subscription__c> caseSubs = new List<Case_Subscription__c>();//TestDataFactory.createCaseSubscription(3);
        
        for(Integer cntr = 0; cntr < 3; cntr++){
            Case_Subscription__c cs = new Case_Subscription__c();
            cs.Case__c = cas[cntr].Id;
            
            cs.Account__c = acc.id;
            cs.Subscription__c = subs[0].Id;
            cs.isComplaint__c = true;

            if(cntr < 2){
                cs.Address__c = ad.id;
            }else{
                cs.Address__c = null;
            }
            caseSubs.add(cs);
        }
        database.insert(caseSubs);
        
        //create publication
        List<Publication__c> pub = TestDataFactory.createPublication(1);
        //Publication__c pub = TestDataFactory.createPublication(1)[0];
        for(Publication__c pubs : pub) {
        pubs.Name = 'TestPub';
        pubs.Publication_Code__c = 'BH';
        pubs.Product_Family__c = 'BT';
        pubs.Published_Days__c = 'YYYYYNN';
        pubs.Platform_Type__c = 'Print';
        pubs.Publication_Type__c = 'N';
        }
        database.insert(pub);
        
        
        List <Product_Publication__c> proPub =TestDataFactory.createProductPublication(1);
        for(Product_Publication__c pp: proPub) {
        pp.ZProduct__c = zp.Id; //zproduct   
        pp.Publication_Code__c = pub[0].id;    
        }
          insert proPub;
        
        //create product rate plan
        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(1)[0];
        prp.zqu__ZProduct__c = zp.Id;
        prp.RatePlanType__c = 'Bill Plan';
        database.insert(prp);
        
        //create product rate plan charge
        zqu__ProductRatePlanCharge__c prpc =  TestDataFactory.createProductRatePlanCharge(1)[0];
        prpc.zqu__ProductRatePlan__c = prp.Id;
        prpc.PublicationCode__c = 'BH';
        database.insert(prpc);
        
        //create package item
        Package_Item__c pItem = TestDataFactory.createPackageItem(1,'Base Product')[0];
        pItem.Package__c = pack.id;
        pItem.Product_Rate_Plan__c = prp.Id;
        database.insert(pItem);
        
        List<Case_Subscription__c> scope = [SELECT Case__r.Id,
                                                    Case__r.Restart_Date__c,
                                                    Case__r.Effective_Date__c,
                                                    Case__r.Change_of_Address_Type__c,   
                                                    Case__r.LastModifiedDate,
                                                    Case__r.POP_Start_Date__c,
                                                    Case__r.Earliest_Stop_Date__c,
                                                    Case__r.Stop_Request_Date__c,
                                                    Case__r.Stop_Date__c,
                                                    Case__r.Temp_Stop_Date__c,
                                                    Case__r.RecordType.DeveloperName,  
                                                    Case__r.Status,      
                                                    Case__r.Order__c,
                                                    Case__r.Order__r.ID,
                                                    Case__r.Order__r.Subscription__r.ID,
                                                    Case__r.CreatedDate,  
                                                    Case__r.Vendor__r.Vendor_Group__c,   
                                                    Case__r.Vendor__r.Vendor_Code__c,    
                                                    Case__r.Subscription_Name__r.Recipient_Contact__r.Address__r.Block_House_Number__c, 
                                                    Case__r.Subscription_Name__r.Recipient_Contact__r.Address__r.Level_Number__c, 
                                                    Case__r.Subscription_Name__r.Recipient_Contact__r.Address__r.Unit_Number__c, 
                                                    Case__r.Subscription_Name__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name, 
                                                    Case__r.Subscription_Name__r.Recipient_Contact__r.Address__r.Street_Name__c, 
                                                    Case__r.Subscription_Name__r.Recipient_Contact__r.Address__r.Building_Name__c, 
                                                    Case__r.Subscription_Name__r.Recipient_Contact__r.Contact_Legacy_Id__c, 
                                                    Case__r.Subscription_Name__r.Recipient_Contact__r.Id, 
                                                    Case__r.Subscription_Name__r.Recipient_Contact__r.Name, 
                                                    Case__r.Subscription_Name__r.Recipient_Contact__r.Recipient_Number__c, 
                                                    Case__r.Subscription_Name__r.Recipient_Contact__r.Salutation,      
                                                    Case__r.Subscription_Name__r.Recipient_Contact__r.Company_Name__c,
                                                    Case__r.Subscription_Name__r.Id, 
                                                    Case__r.Subscription_Name__r.Name, 
                                                    Case__r.Subscription_Name__r.Qty__c, 
                                                    Case__r.Subscription_Name__r.Pub_Tag__c,               
                                                    Case__r.Subscription_Name__r.Frequency__c, 
                                                    Case__r.Subscription_Name__r.Product_Code__c, 
                                                    Case__r.Subscription_Name__r.Zuora__SubscriptionStartDate__c, 
                                                    Case__r.Subscription_Name__r.Zuora__SubscriptionEndDate__c, 
                                                    Case__r.Subscription_Name__r.Effective_Start_Date__c,      
                                                    Case__r.Subscription_Name__r.Effective_End_Date__c,                
                                                    Case__r.Subscription_Name__r.Vendor_1__r.Id, 
                                                    Case__r.Subscription_Name__r.Vendor_1__r.Vendor_Group__c, 
                                                    Case__r.Subscription_Name__r.Vendor_1__r.Vendor_Code__c, 
                                                    Case__r.Subscription_Name__r.Main_Package_1__c, 
                                                    Case__r.Subscription_Name__r.LastModifiedDate, 
                                                    Case__r.Subscription_Name__r.Zuora__Status__c,  
                                                    Address__r.Id, 
                                                    Address__r.Block_House_Number__c, 
                                                    Address__r.Level_Number__c, 
                                                    Address__r.Unit_Number__c, 
                                                    Address__r.Postal_Code__r.Name, 
                                                    Address__r.Street_Name__c, 
                                                    Address__r.Building_Name__c, 
                                                    Subscription__r.Vendor_1__r.Id,
                                                    Subscription__r.Vendor_1__r.Vendor_Group__c,
                                                    Subscription__r.Vendor_1__r.Vendor_Code__c,
                                                    Subscription__r.Recipient_Contact__r.Address__r.Block_House_Number__c,
                                                    Subscription__r.Recipient_Contact__r.Address__r.Level_Number__c,
                                                    Subscription__r.Recipient_Contact__r.Address__r.Unit_Number__c,
                                                    Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name,
                                                    Subscription__r.Recipient_Contact__r.Address__r.Street_Name__c,
                                                    Subscription__r.Recipient_Contact__r.Address__r.Building_Name__c, 
                                                    Subscription__r.Recipient_Contact__r.Contact_Legacy_Id__c,
                                                    Subscription__r.Recipient_Contact__r.Id,
                                                    Subscription__r.Recipient_Contact__r.Name,
                                                    Subscription__r.Recipient_Contact__r.Recipient_Number__c,
                                                    Subscription__r.Recipient_Contact__r.Company_Name__c,
                                                    Subscription__r.Id,Subscription__r.Name,
                                                    Subscription__r.Qty__c,
                                                    Subscription__r.Pub_Tag__c,
                                                    Subscription__r.Frequency__c,
                                                    Subscription__r.Product_Code__c,
                                                    Subscription__r.Zuora__SubscriptionStartDate__c,
                                                    Subscription__r.Zuora__SubscriptionEndDate__c,
                                                    Subscription__r.LastModifiedDate,
                                                    Subscription__r.Zuora__Status__c,
                                                    Subscription__r.Main_Package_1__c,
                                                    Account__r.Attention_To_Care_Of__c, 
                                                    Account__r.Account_Legacy_Id__c,
                                                    Account__r.Account_Auto_Number__c,
                                                    Account__r.CreatedDate,
                                                    Account__r.Id,
                                                    Account__r.Name,
                                                    LastModifiedDate From Case_Subscription__c];

        List<Product_Publication__c> listPP = [SELECT ZProduct__r.productcode__c, publication_code__r.name FROM Product_Publication__c];
        //test
        test.startTest();
            System.assertEquals(Date.Today(), checkSubDate[0].Subscription_Start_Date__c);
            System.assertEquals(Date.Today(), checkSubDate[1].Subscription_Start_Date__c);
            System.assertEquals(Date.Today(), checkSubDate[2].Subscription_Start_Date__c);
            BT_AB_HDS038DX_ChangeOfAddress batch = new BT_AB_HDS038DX_ChangeOfAddress();
            Id batchID = database.executeBatch(batch, 200);
            Database.BatchableContext BC;
            batch.execute(BC,scope);
            system.assert(batchID <> null);
        test.stopTest();
        }
}