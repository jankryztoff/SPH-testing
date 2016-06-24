/*April Veloso
* 04/11/2016
* Base Class Name:SP_VendorNotificationsBatch
* Test Class Name:SP_VendorNotificationsBatchTest
*/

@isTest
public class SP_VendorNotificationsBatchTest{
    @testSetup 
    static void setupData() {
        insert CustomSettingsDataFactory.createKey_Id();
        insert CustomSettingsDataFactory.createOther(); 
        insert CustomSettingsDataFactory.createPlannerSched();
        insert CustomSettingsDataFactory.createBatchConfig(); 
        insert CustomSettingsDataFactory.createIntegration_Settings();
        insert CustomSettingsDataFactory.createCharge();
        insert CustomSettingsDataFactory.createChargeType();
        insert CustomSettingsDataFactory.createZuora_HPM_Settings();
        insert CustomSettingsDataFactory.createError_Messages();
        insert CustomSettingsDataFactory.createARMSInterface();
        insert CustomSettingsDataFactory.createUom();
        insert CustomSettingsDataFactory.createUnit_of_Measure();
        
        
    }  
        static testmethod void test_SP_VendorNotificationsBatch(){
                 Project__c pro = TestDataFactory.createProject(1)[0];
                 pro.Project_Description__c = 'This is a new confidential project.';
                 database.insert(pro);
                            
                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
                 acc.Active__c = true;
                 database.insert(acc);
                 
                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                 postal.Building_Name__c = 'Ebloc2';
                 database.insert(postal);
                 
                 Address__c ad = TestDataFactory.createAddress(1)[0];
                 ad.Postal_Code__c = postal.id;
                 database.insert(ad);
                 
                 
                 Recordtype rectypeCon = [SELECT Id, Name from Recordtype where sObjecttype = 'Contact' and Name = 'Vendor Staff' LIMIT 1];
                 List<Contact> con = TestDataFactory.createContact(3);
                 con[0].Recordtypeid = rectypeCon.id;
                 con[0].Account = acc;
                 con[0].AccountId = acc.id;
                 con[0].Recipient_Indicator__c = true; 
                 con[0].Address__c = ad.id;
                 con[0].Active__c = true;
                 con[0].Vendor_Communication_Preference__c  = 'SMS';
                 
                 con[1].Recordtypeid = rectypeCon.id;
                 con[1].Account = acc;
                 con[1].AccountId = acc.id;
                 con[1].Recipient_Indicator__c = true; 
                 con[1].Address__c = ad.id;
                 con[1].Active__c = true;
                 con[1].Vendor_Communication_Preference__c  = 'Email';
                 
                 con[2].Recordtypeid = rectypeCon.id;
                 con[2].Account = acc;
                 con[2].AccountId = acc.id;
                 con[2].Recipient_Indicator__c = true; 
                 con[2].Address__c = ad.id;
                 con[2].Active__c = true;
                 con[2].Vendor_Communication_Preference__c  = 'Email';
                 database.insert(con);  
              /*   
                 Contact con2 = TestDataFactory.createContactRecType(1, 'Vendor Staff')[0];
                 con2.AccountId = acc.Id;
                 con2.Active__c = true;
                 database.insert(con2);
               */  
                 Temp_Stop__c temp = TestDataFactory.createTempStop(1)[0];
                 temp.Restart_Date__c = date.today()+1;
                 database.insert(temp);
                 
                 Package__c pack = TestDataFactory.createPackage(1)[0];
                 database.insert(pack);   
                        
                 Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                 billAcc.Zuora__Account__c = acc.Id;
                 ARMS_TriggerHandler.isSkipUpdate = true;
                 database.insert(billAcc);
        
                        
               /**  Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                 sub.Zuora__CustomerAccount__c = billAcc.Id;
                 database.insert(sub); **/
                 
                List<Order__c> orderRec = TestDataFactory.createOrder(3);
                 orderRec[0].Account__c = acc.Id;
                 orderRec[0].Informed_Customer__c = TRUE;
                 orderRec[0].Recipient_Contact__c = con[0].Id;
                 orderRec[0].Subscriber_Charge__c = 100.00;
                 
                 orderRec[1].Account__c = acc.Id;
                 orderRec[1].Informed_Customer__c = TRUE;
                 orderRec[1].Recipient_Contact__c = con[1].Id;
                 orderRec[1].Subscriber_Charge__c = 100.00;
                 
                 orderRec[2].Account__c = acc.Id;
                 orderRec[2].Informed_Customer__c = TRUE;
                 orderRec[2].Recipient_Contact__c = con[2].Id;
                 orderRec[2].Subscriber_Charge__c = 100.00;
                 insert orderRec;   
                    
                          
                 List<Zuora__Subscription__c> sub = TestDataFactory.createSubscription(3);
                 sub[0].Zuora__CustomerAccount__c = billAcc.Id;
                 sub[0].Order_Number__c  = orderRec[0].Id;
                 sub[0].Order_Number_1__c = orderRec[0].Id;
                
                 sub[1].Zuora__CustomerAccount__c = billAcc.Id;
                 sub[1].Order_Number__c = orderRec[1].Id;
                 sub[1].Order_Number_1__c = orderRec[1].Id;
                 sub[1].Zuora__Account__c = acc.id;
                 sub[1].Delivered_By_1__c = 'Vendor';
                 sub[1].Zuora__Status__c = 'Active';
                 sub[1].Subscription_Type_1__c = 'Publication';
                 
                 sub[2].Zuora__CustomerAccount__c = billAcc.Id;
                 sub[2].Order_Number__c = orderRec[2].Id;
                 sub[2].Order_Number_1__c = orderRec[2].Id;
                 sub[2].Zuora__Account__c = acc.id;
                 sub[2].Delivered_By_1__c = 'Vendor';
                 sub[2].Zuora__Status__c = 'Active';
                 sub[2].Subscription_Type_1__c = 'Publication';
                 database.insert(sub);
                 
                 List<Order_Line_Item__c> orderline = TestDataFactory.createOrderLineItem(3);
                 orderline[0].Order__c = orderRec[0].Id;
                 orderline[0].Subscription__c = sub[0].id;
                 orderline[0].Main_Package_ID__c = pack.Id;
                
                 orderline[1].Order__c = orderRec[1].Id;
                 orderline[1].Subscription__c = sub[1].id;
                 orderline[1].Main_Package_ID__c = pack.Id;
                 
                 orderline[2].Order__c = orderRec[2].Id;
                 orderline[2].Subscription__c = sub[2].id;
                 orderline[2].Main_Package_ID__c = pack.Id;
                 insert orderline;
                               
        
                 List<Case> cas = TestDataFactory.createCase(3, 'Change of Address/Vendor');
                 cas[0].Temp_Stop__c = temp.Id;
                 cas[0].Temp_Stop__r = temp;
                 cas[0].Effective_Date__c = date.today()+1;
                 cas[0].Change_of_Address_Type__c = 'Change of Vendor';
                 cas[0].Vendor__c  = acc.Id;
                 cas[0].Contact_To_Update__c = con[0].Id;
                 cas[0].RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND Name = 'Temp Stop Subscription'].Id;
                 cas[0].COA__c = true;
                 cas[0].Account = acc;
                 cas[0].Accountid = acc.id;
                 cas[0].Temp_Stop_Sub__c = sub[0].id;
                 cas[0].Temp_Stop_Date__c = date.today();
                 cas[0].Restart_Date__c = date.today()+1;
                 cas[0].Sub_Status__c = 'Urgent CoA Approved';
               
                        
                 cas[1].Temp_Stop__c = temp.Id;
                 cas[1].Temp_Stop__r = temp;
                 cas[1].Effective_Date__c = date.today()+1;
                 cas[1].Change_of_Address_Type__c = 'Change of Vendor';
                 cas[1].Vendor__c  = acc.Id;
                 cas[1].Contact_To_Update__c = con[1].Id;
                 cas[1].Account = acc;
                 cas[1].Accountid = acc.id;            
                 cas[1].Temp_Stop_Sub__c = sub[1].id;      
                 cas[1].Sub_Status__c = 'Urgent CoA Approved';
                
                 cas[2].Temp_Stop__c = temp.Id;
                 cas[2].Temp_Stop__r = temp;
                 cas[2].Effective_Date__c = date.today()+1;
                 cas[2].Change_of_Address_Type__c = 'Change of Vendor';
                 cas[2].Vendor__c  = acc.Id;
                 cas[2].Contact_To_Update__c = con[1].Id;
                 cas[2].RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND Name = 'Change of Subscription'].Id;
                 cas[2].Account = acc;
                 cas[2].Accountid = acc.id;            
                 cas[2].Temp_Stop_Sub__c = sub[1].id;      
                 cas[2].Sub_Status__c = 'Urgent CoA Approved';
                 cas[2].Subscription_Name__c = sub[2].Id;
                
                 
                 database.insert(cas);
                 
                 
                 Address_Assignment__c aa = new Address_Assignment__c();
                 aa.Case__c = cas[0].Id;
                 aa.Vendor__c = acc.Id;
                 aa.Address__c = ad.Id;
                 aa.Contact__c = con[0].Id;
                 aa.Effective_Date__c = date.today()+1;
                 database.insert(aa); 
                 
                 Address_Assignment__c aa1 = new Address_Assignment__c();
                 aa1.Case__c = cas[1].Id;
                 aa1.Vendor__c = acc.Id;
                 aa1.Address__c = ad.Id;
                 aa1.Contact__c = con[1].Id;
                 aa1.Subscription__c = sub[0].id;
                 aa1.Effective_Date__c = date.today()+1;
                 database.insert(aa1);
                 
                 List<Address_Assignment__c> adassignList = new List<Address_Assignment__c>();
                 adassignList.add(aa);
                 adassignList.add(aa1);
                 
                        
                 List<Case_Subscription__c> caseSub = TestDataFactory.createCaseSubscription(3);
                 caseSub[0].Case__c = cas[0].Id;
                 caseSub[0].Subscription__c = sub[0].Id;
                 
                 caseSub[1].Case__c = cas[1].Id;
                 caseSub[1].Subscription__c = sub[0].Id;    
                 
                 caseSub[2].Case__c = cas[2].Id;
                 caseSub[2].Subscription__c = sub[0].Id;    
                 database.insert(caseSub);
                                 
                 Publication__c pub = TestDataFactory.createPublication(1)[0];
                 database.insert(pub);
                        
                 Publication__c pubSun = TestDataFactory.createPublication(1)[0];
                 pubSun.Sunday_Publication__c = pub.Id;
                 database.insert(pubSun);
                 
                Parcel__c par = TestDataFactory.createParcel(1)[0];
                par.Project_Name__c = pro.Id;
                par.Allocation_Type__c = 'SDA';
                par.Description__c = 'Description';
                insert par;
                 
                List<Vendor_Allocation__c> venAlloc = TestDataFactory.createVendorAlloc(4);
                venAlloc[0].SingPost_Address__c = postal.Id;
                venAlloc[0].Vendor_Account__c = acc.Id;
                venAlloc[0].Parcel_Name__c = par.Id;
                venAlloc[0].Allocated__c = TRUE;
                
                venAlloc[1].SingPost_Address__c = postal.Id;
                venAlloc[1].Vendor_Account__c = acc.Id;
                venAlloc[1].Parcel_Name__c = par.Id;
                venAlloc[1].Allocated__c = TRUE;
                
                venAlloc[2].SingPost_Address__c = postal.Id;
                venAlloc[2].Vendor_Account__c = acc.Id;
                venAlloc[2].Parcel_Name__c = par.Id;
                venAlloc[2].Allocated__c = TRUE;
                
                venAlloc[3].SingPost_Address__c = postal.Id;
                venAlloc[3].Vendor_Account__c = acc.Id;
                venAlloc[3].Parcel_Name__c = par.Id;
                venAlloc[3].Allocated__c = TRUE;
                venAlloc[3].SingPost_Address__c = postal.Id;
                venAlloc[3].Vendor_Account__c = acc.Id;
                venAlloc[3].Parcel_Name__c = par.Id;
                venAlloc[3].Allocated__c = TRUE;
                insert venAlloc;
                Database.BatchableContext BC;
                
                Postal_Zone__c postalSector = new Postal_Zone__c();
                postalSector.Name = 'test';
                database.insert(postalSector);
                
                User  u = TestDataFactory.prepareTestusers();
                
                Post_Sector_Ops_Rep_Mapping__c postSectorOps = TestdataFactory.createPostSector(1)[0];
                postSectorOps.Zone__c = postalSector.id;
                postSectorOps.Vendor_Ops__c = u.id; 
                database.insert(postSectorOps);
                 
                        
                test.starttest();
                        SP_VendorNotificationsBatch batch = new SP_VendorNotificationsBatch();
                        ID batchprocessid = Database.executeBatch(batch, 200); 
                        batch.execute(BC, caseSub);
                        batch.coverageMethod();
                        batch.coverageMethodSecond();
                test.stoptest();
                }
                
            //START KPunzalan
            static testmethod void test_constructMail(){
                
            //SP_VendorNotificationsBatch.constructMail();
          
            String transactionNameParam = GlobalVariableClass.TS_URGENTRESTART; 
            // List<String> toAddressesParam, 
            // Case caseObjectParam, //
            // Zuora__Subscription__c subscriptionParam, //
            // Map<Id, String> conId_AliasMapParam, 
            // String issueDateParam, 
            // String subParam, 
            // Address__c addressObjParam, 
            // Singpost_Address__c singpostAddressObjParam, 
            // String classificationParam, 
            // Map<Id, List<String>> coaStartToEmails_MapParam, 
            // Map<Id, String> aliasCOAMapParam, 
            // Map<Id, id> conId_NameMapParam, 
            // String sessionId,  
            // Map<Id, List<String>> tempCaseToVendorEmail_MAPParam, 
            // Map<Id, List<String>> tempToNewMobile_MapParam, 
            // Map<Id, List<String>> coaStartToNewMobile_MAPParam, 
            // Map<Id, Set<Id>> coaStartToTaskCon_MAPParam, 
            // Map<Id,Id> coaToUserTask_MAPParam, 
            // Map<Id, Id> tempCaseToUserId_MapParam, 
            // Map<Id, String> tempCaseToUserAlias_MapParam, 
            // Map <Id, Set<Id>>tempCaseToContacts_MapParam, 
            // Map<Id, String> coaToUserAlias_MAPParam, 
            // boolean isSendEmailParam
              
              //(transactionName, toAddresses, caseObject, subscription, conId_AliasMap, issueDate, sub, addressObj, singpostAddressObj, classification, coaStartToEmails_Map, aliasCOAMap, conId_NameMap, sessionId, tempWithCoaToVendorEmail_MAP, tempToNewMobile_Map, coaStartToNewMobile_MAP, coaStartToTaskCon_MAP, coaToUserTask_MAP, tempCaseToUserId_Map, tempCaseToUserAlias_Map, tempCaseToContacts_Map, coaToUserAlias_MAP, isSendEmail);
                
            }
            
            static testmethod void test_checkForNonProvision(){
                 Project__c pro = TestDataFactory.createProject(1)[0];
                 pro.Project_Description__c = 'This is a new confidential project.';
                 database.insert(pro);
                            
                 Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
                 acc.Active__c = true;
                 database.insert(acc);
                 
                 Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
                 postal.Building_Name__c = 'Ebloc2';
                 database.insert(postal);
                 
                 Address__c ad = TestDataFactory.createAddress(1)[0];
                 ad.Postal_Code__c = postal.id;
                 database.insert(ad);
                 
                 
                 Recordtype rectypeCon = [SELECT Id, Name from Recordtype where sObjecttype = 'Contact' and Name = 'Vendor Staff' LIMIT 1];
                 List<Contact> con = TestDataFactory.createContact(2);
                 con[0].Recordtypeid = rectypeCon.id;
                 con[0].Account = acc;
                 con[0].AccountId = acc.id;
                 con[0].Recipient_Indicator__c = true; 
                 con[0].Address__c = ad.id;
                 con[0].Active__c = true;
                 con[0].Vendor_Communication_Preference__c  = 'SMS';
                 
                 con[1].Recordtypeid = rectypeCon.id;
                 con[1].Account = acc;
                 con[1].AccountId = acc.id;
                 con[1].Recipient_Indicator__c = true; 
                 con[1].Address__c = ad.id;
                 con[1].Active__c = true;
                 con[1].Vendor_Communication_Preference__c  = 'Email';
                 database.insert(con);  
              /*   
                 Contact con2 = TestDataFactory.createContactRecType(1, 'Vendor Staff')[0];
                 con2.AccountId = acc.Id;
                 con2.Active__c = true;
                 database.insert(con2);
               */  
                 Temp_Stop__c temp = TestDataFactory.createTempStop(1)[0];
                 temp.Restart_Date__c = date.today()+1;
                 database.insert(temp);
                 
                 Package__c pack = TestDataFactory.createPackage(1)[0];
                 database.insert(pack);   
                        
                 Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
                 billAcc.Zuora__Account__c = acc.Id;
                 ARMS_TriggerHandler.isSkipUpdate = true;
                 database.insert(billAcc);
        
                        
               /**  Zuora__Subscription__c sub = TestDataFactory.createSubscription(1)[0];
                 sub.Zuora__CustomerAccount__c = billAcc.Id;
                 database.insert(sub); **/
                 
                List<Order__c> orderRec = TestDataFactory.createOrder(2);
                 orderRec[0].Account__c = acc.Id;
                 orderRec[0].Informed_Customer__c = TRUE;
                 orderRec[0].Recipient_Contact__c = con[0].Id;
                 orderRec[0].Subscriber_Charge__c = 100.00;
                 
                 orderRec[1].Account__c = acc.Id;
                 orderRec[1].Informed_Customer__c = TRUE;
                 orderRec[1].Recipient_Contact__c = con[1].Id;
                 orderRec[1].Subscriber_Charge__c = 100.00;
                 insert orderRec;   
                    
                
                 List<Zuora__Subscription__c> sub = TestDataFactory.createSubscription(2);
                 sub[0].Zuora__CustomerAccount__c = billAcc.Id;
                 sub[0].Order_Number__c  = orderRec[0].Id;
                 sub[0].Order_Number_1__c = orderRec[0].Id;
                
                 sub[1].Zuora__CustomerAccount__c = billAcc.Id;
                 sub[1].Order_Number__c = orderRec[1].Id;
                 sub[1].Order_Number_1__c = orderRec[1].Id;
                 sub[1].Zuora__Account__c = acc.id;
                 sub[1].Delivered_By_1__c = 'Vendor';
                 sub[1].Frequency_1__c = 'Default';
                 database.insert(sub);
                 
                 sub[1].Zuora__CustomerAccount__c = billAcc.Id;
                 sub[1].Order_Number__c = orderRec[1].Id;
                 sub[1].Order_Number_1__c = orderRec[1].Id;
                 sub[1].Zuora__Account__c = acc.id;
                 sub[1].Delivered_By_1__c = 'Vendor';
                 sub[1].Frequency_1__c = 'Mon - Fri';
                 database.update(sub[1]);
                 
                // SP_VendorNotificationsBatch.checkForNonProvision()
            }
            
            static testmethod void test_convertDateToString(){
                SP_VendorNotificationsBatch.convertDateToString(Date.today());
               
            }
            //END KPunzalan
}