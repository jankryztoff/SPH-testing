@isTest(SeeAllData = false)
private class BT_AB_HDS038DX_TempStopTest {
    
    //Description of method: 
    static  testmethod void test01(){
                /*Key_Id__c key = new Key_Id__c();
                key.Name = 'NEXT_RECIPIENT_NUMBER';
                key.Id__c = '30012551';
                database.insert(key);*/               
                
                Other__c other = new Other__c();
                other.Name = 'DTL';
                other.Value__c = '23:59';
                database.insert(other); 
                
                
                Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
                cir.Name = 'CIR Plan Schedule';
                cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
                cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
                cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
                cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
                cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
                cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
                database.insert(cir);
                
                BatchInterface_Settings__c batchInterfaceSetting = new BatchInterface_Settings__c();
                batchInterfaceSetting.Name = 'Endpoint Delegator';
                batchInterfaceSetting.value__C = 'http://devcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
                insert batchInterfaceSetting;
                
                BT_CO_Batch_Run_Request__c batchRun = new BT_CO_Batch_Run_Request__c();
                batchRun.Interface_ID__c = 'HDS038DX';
                batchRun.Batch_Run_Date__c = date.today();
                batchRun.End_Time__c = null;
                database.insert(batchRun);
                
                
                Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
                database.insert(acc);
                List<Singpost_Address__c> postal = TestDataFactory.createSingpostAddress(2);
                postal[0].Building_Name__c = 'Ebloc2';
                postal[1].Building_Name__c = 'Ebloc2';
                insert postal;
                
                List<Country__c> country = TestDataFactory.createCountry(2); 
                country[0].Country_Name__c = 'SINGAPORE'; 
                country[1].Country_Name__c = 'SINGAPORE'; 
                insert country;
                
                List<Address__c> address = TestDataFactory.createAddress(2);
                //address.RecordTypeId = ConstantsSLB.getKeyId('Address_Local');
                address[0].Block_House_Number__c =  'TEST';
                address[0].Postal_Code__c = postal[0].id;
                address[0].Level_Number__c = '17';
                address[0].Unit_Number__c = 'Unit 5';
                address[0].Country__c = country[0].id;
                
                //address.RecordType.Id = getRecordType('Address_Internal', 'Address__c').id;
                address[1].Block_House_Number__c =  'TEST';
                address[1].Postal_Code__c = postal[1].id;
                address[1].Level_Number__c = '17';
                address[1].Unit_Number__c = 'Unit 5';
                address[1].Country__c = country[1].id;
                insert address;
                
                List<Contact> con = TestDataFactory.createContact(2);
                con[0].AccountId = acc.Id;
                con[0].Address__c = address[0].id;
                con[0].Recipient_Indicator__c = true;
                
                con[1].AccountId = acc.Id;
                con[1].Address__c = address[1].id;
                con[1].Recipient_Indicator__c = true;
                // con.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                insert con;
                
                Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                billAcc.Zuora__Account__c = acc.Id;
                database.insert(billAcc);
                
                Package__c pack = TestDataFactory.createPackage(1)[0];
                pack.Package_Type__c = 'Base';
                database.insert(pack);
                
                Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                sub.Zuora__CustomerAccount__c = billAcc.Id;
                sub.Product_Code__c = 'XY23';
                sub.Main_Package_1__c = pack.id;
                sub.Main_Package__c = pack.id;
                database.insert(sub);
                
                Product_Family__c prodFam = TestdataFactory.createProductFamily(1)[0];
                prodFam.Product_Family__c = 'BH';
                database.insert(prodFam);
                
                Publication__c pub = TestDataFactory.createPublication(1)[0];
                pub.Name = 'Test';
                pub.Publication_Code__c ='XY23';
                pub.Platform_Type__c = 'Print';
                pub.Publication_Type__c = 'N';
                pub.Product_Family__c = 'BH';
                pub.Product_Family_Lookup__c = prodFam.id;
                database.insert(pub);
                
                List<zqu__ZProduct__c> zProduct = TestDataFactory.createZProduct(2);
                zProduct[0].ProductCode__c = 'XY23';
                zProduct[0].ProductType__c = 'Product';
                zProduct[0].ProductFamily__c = 'BH';
                
                zProduct[1].ProductCode__c = 'XY23';
                zProduct[1].ProductType__c = 'Product';
                zProduct[1].ProductFamily__c = 'BH';
                database.insert(zProduct);
                
                List<Product_Publication__c> prodPub = TestDataFactory.createProductPublication(2);
                prodPub[0].ZProduct__c = zProduct[0].id;
                prodPub[0].publication_code__c = pub.id;
                
                prodPub[1].ZProduct__c = zProduct[1].id;
                prodPub[1].publication_code__c = pub.id;
                database.insert(prodPub);
                
                zqu__ProductRatePlan__c prdrateplan = TestDataFactory.createProductRatePlan(1)[0];
                prdrateplan.RatePlanType__c = 'Bill Plan';
                prdrateplan.zqu__ZProduct__c = zProduct[0].id;
                database.insert(prdrateplan);
                
                zqu__ProductRatePlanCharge__c prodRatePlanCharge = TestDataFactory.createProductRatePlanCharge(1)[0];
                prodRatePlanCharge.PublicationCode__c = 'XY23';
                prodRatePlanCharge.zqu__ProductRatePlan__c= prdrateplan.id;
                database.insert(prodRatePlanCharge);
                
                Package_Item__c packItem = TestDataFactory.createPackageItem(1, 'Base Product')[0];
                packItem.Package__c = pack.id;
                packItem.Product_Rate_Plan__c = prdrateplan.id;
                database.insert(packItem);
                
                Temp_Stop__c tempStop = TestDataFactory.createTempStop(1)[0];
                tempStop.Cancelled__c = False;
                database.insert(tempStop);
                
                Recordtype recType = [SELECT ID, DeveloperName FROM RecordType where SObjectType = 'Case' and DeveloperName = 'Temp_Stop_Subscription' LIMIT 1];
                List<Case> cas = TestDataFactory.createCase(2, 'Complaint - Newspaper');
                cas[0].RecordtypeId = rectype.ID;
                cas[0].Effective_Date__c = date.today()+1;
                cas[0].Status = 'Closed';
                cas[0].Temp_Stop__c = tempStop.id;
                cas[0].Sub_Status__c = 'Assess for Goodwill';
                cas[0].Temp_Stop_Type__c = 'New';
                cas[0].Temp_Stop_Date__c = date.today().addDays(1);
                cas[0].Restart_Date__c = date.today().addDays(2);
                
                Recordtype recType1 = [SELECT ID, DeveloperName FROM RecordType where SObjectType = 'Case' and DeveloperName = 'Change_of_Address' LIMIT 1];    
                cas[1].RecordtypeId = rectype1.ID;
                cas[1].Effective_Date__c = date.today()+1;
                cas[1].Status = 'Closed';
                cas[1].Temp_Stop__c = tempStop.id;
                cas[1].Sub_Status__c = 'Assess for Goodwill';
                cas[1].Temp_Stop_Type__c = 'New';
                cas[1].Temp_Stop_Date__c = date.today().addDays(1);
                cas[1].Restart_Date__c = date.today().addDays(2);
                database.insert(cas);
                
                List<Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(2);
                caseSub[0].Case__c = cas[0].Id;
                caseSub[0].Subscription__c = sub.Id;
                
                caseSub[1].Case__c = cas[1].Id;
                caseSub[1].Subscription__c = sub.Id;
                database.insert(caseSub);
                
                
                Address_Assignment__c addAssignment = new Address_Assignment__c();
                addAssignment.Case__c = cas[0].id;
                addAssignment.Address__c = address[0].id;
                addAssignment.Contact__c = con[0].id; 
                addAssignment.Effective_Date__c = date.today();
                database.insert(addAssignment);
                
                Address_Assignment__c addAssignment1 = new Address_Assignment__c();
                addAssignment1.Case__c = cas[1].id;
                addAssignment1.Address__c = address[1].id;
                addAssignment1.Contact__c = con[1].id; 
                addAssignment1.Effective_Date__c = date.today();
                database.insert(addAssignment1);
                
                Test.StartTest();
                
                BT_AB_HDS038DX_TempStop batch = new BT_AB_HDS038DX_TempStop();
                Database.executeBatch(batch, 200);
                
                
                Test.StopTest(); 
   }
}