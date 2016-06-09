/*April Veloso
* 04/13/2016
* Base Class Name:
* Test Class Name: 
*/

@isTest (seeAllData = true)
public class SP_VendorSubscriptionNotificationsTest2{ 
 
        
        static testmethod void test_SP_VondorSubscriptionNotificationsSelective() {
                
                //Singpost Address
                Singpost_Address__c singAdd = TestDataFactory.createSingpostAddress(1)[0];
                singAdd.Name = '013';
                insert singAdd;
                
                
                //Account
                Account acc = TestDataFactory.createAccount(1, 'Vendor')[0];
                acc.Singpost_Address__c = singAdd.id;
                acc.Active__c = true;
                acc.Vendor_Communication_Preference__c = 'Both';
                acc.Handphone_Number__c = '923429';
                acc.Email__c =  'test@test.com';
                acc.Vendor_Code__c = 'Code1';
                acc.Vendor_Group__c = '1';
                database.insert(acc);
                
                
                //Address__c
                Address__c addressRec = TestDataFactory.createAddress(1)[0];
                addressRec.Address_Type__c='P';
                addressRec.Postal_Code__c = singAdd.Id;
                RecordType addressRT = [SELECT id, name, sobjecttype FROM recordtype WHERE sobjecttype='address__c' AND Name='Overseas'];
                addressRec.RecordTypeId = addressRT.id;
                insert addressRec;
                
                
                /*2: Vendor Staff*/     
                //Contact
                List<Contact> conList = TestDataFactory.createContactRecType(1, 'Vendor Staff');
                conList[0].AccountId = acc.Id;
                conList[0].Address__c = addressRec.Id;
                conList[0].Recipient_Indicator__c = true;
                conList[0].LastName = 'Last Name';
                conList[0].FirstName = 'First Name';
                conList[0].Phone = '1234567';
                conList[0].Billing_Indicator__c = TRUE; 
                conList[0].Mobile_Number__c = '09155568874'; 
                conList[0].Mobile_Number_2__c = '09112234567';
                conList[0].Active__c = true;
                conList[0].Email = 'test@sample.com';
                conList[0].Vendor_Communication_Preference__c = 'Both';
                conList[0].HomePhone__c = '09155568874';
                conList[0].Email = 'test@test.com';
                insert conList;
    
                                          
                            
                //Order__c
                Order__c orderRec = TestDataFactory.createOrder(1)[0];
                orderRec.Account__c = acc.Id;
                orderRec.Informed_Customer__c = TRUE;
                orderRec.Recipient_Contact__c = conList[0].Id;
                orderRec.Billing_Contact__c = conList[0].Id;
                orderRec.Subscriber_Charge__c = 15;
                insert orderRec;
                
                
                
                
                
                
                //Temp Stop
                List<Temp_Stop__c> tempStop = TestDataFactory.createTempStop(4);
                tempStop[0].Temp_Stop_Date__c = Date.today();
                tempStop[0].Restart_Date__c = Date.today() + 1;
                tempStop[0].Remarks__c = 'Sample Remarks';
                tempStop[0].Cancelled__c = false;
                
                tempStop[1].Temp_Stop_Date__c = Date.today();
                tempStop[1].Restart_Date__c = Date.today() + 1;
                tempStop[1].Remarks__c = 'Sample Remarks';
                tempStop[1].Cancelled__c = false;
                
                tempStop[2].Temp_Stop_Date__c = Date.today()+1;
                tempStop[2].Restart_Date__c = Date.today() + 2;
                tempStop[2].Remarks__c = 'Sample Remarks';
                tempStop[2].Cancelled__c = false;
                
                tempStop[3].Temp_Stop_Date__c = Date.today();
                tempStop[3].Restart_Date__c = Date.today() + 1;
                tempStop[3].Remarks__c = 'Sample Remarks';
                tempStop[3].Cancelled__c = false;
                insert tempStop;
                
                
                //Case
                List<Case> cs = TestDataFactory.createCase(4, 'Change of Address/Vendor');
                cs[0].AccountId = acc.id;
                cs[0].Effective_Date__c = Date.today()+1;
                cs[0].COA__c = true;
                cs[0].Temp_Stop__c = tempStop[0].id;
                cs[0].Status = 'Closed';
                cs[0].Order__c = orderRec.id;
                cs[0].Vendor__c = acc.id;
                cs[0].Change_of_Address_Type__c = 'Change of Vendor';
                cs[0].Contact_To_Update__c = conList[0].id;
                cs[0].New_Address__c = addressRec.id;
                cs[0].Temp_Stop_Date__c = Date.today();
                cs[0].restart_date__c = date.today()+1;
                cs[0].Vendor_Chargeable_Courier__c = true;
                cs[0].Vendor_Chargeable_Paper__c = false;
                cs[0].Vendor_Email__c = 'test@test.com';
                cs[0].Vendor_No__c = '1234567';
                cs[0].Vendor_Subscription_Created__c = true;
                
                cs[1].AccountId = acc.id;
                cs[1].Effective_Date__c = Date.today()+1;
                cs[1].COA__c = true;
                cs[1].Temp_Stop__c = tempStop[1].id;
                cs[1].Status = 'Closed';
                cs[1].Order__c = orderRec.id;
                //cs[1].Vendor__c = acc.id;
                cs[1].Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
                //cs[1].Change_of_Address_Type__c = 'Change of Vendor';
                cs[1].Contact_To_Update__c = conList[0].id;
                cs[1].New_Address__c = addressRec.id;
                cs[1].Temp_Stop_Date__c = Date.today();
                cs[1].restart_date__c = date.today()+2;
                cs[1].Vendor_Chargeable_Courier__c = true;
                cs[1].Vendor_Chargeable_Paper__c = false;
                cs[1].Vendor_Email__c = 'test@test.com';
                cs[1].Vendor_No__c = '1234567';
                cs[1].Vendor_Subscription_Created__c = true;
                                
                //Case cs2 = TestDataFactory.createCase(1, 'Temp Stop Subscription')[0];
                cs[2].RecordtypeId = ConstantsSLB.getKeyId('Case_Stop');
                cs[2].AccountId = acc.id;
                cs[2].Effective_Date__c = Date.today()+1;
                cs[2].COA__c = true;
                cs[2].Temp_Stop__c = tempStop[2].id;
                cs[2].Status = 'Closed';
                cs[2].Order__c = orderRec.id;
                cs[2].Vendor__c = acc.id;
                cs[2].Change_of_Address_Type__c = 'Change of Vendor';
                cs[2].Contact_To_Update__c = conList[0].id;
                cs[2].New_Address__c = addressRec.id;
                //cs[1].Temp_Stop_Date__c = Date.today();
                cs[2].Temp_Stop_Date__c = Date.today().addDays(1);
                cs[2].restart_date__c = date.today()+2;
                cs[2].Vendor_Chargeable_Courier__c = true;
                cs[2].Vendor_Chargeable_Paper__c = false;
                cs[2].Vendor_Email__c = 'test@test.com';
                cs[2].Vendor_No__c = '1234567';
                cs[2].Vendor_Subscription_Created__c = true;
                
                cs[3].RecordtypeId = ConstantsSLB.getKeyId('Case_Temp Stop');
                cs[3].AccountId = acc.id;
                cs[3].Effective_Date__c = Date.today()+1;
                cs[3].COA__c = true;
                cs[3].Temp_Stop__c = tempStop[3].id;
                cs[3].Status = 'Closed';
                cs[3].Order__c = orderRec.id;
                cs[3].Change_of_Address_Type__c = GlobalVariableClass.BILLDELIVERYADD;
                //cs[3].Change_of_Address_Type__c = 'Change of Vendor';
                cs[3].Contact_To_Update__c = conList[0].id;
                cs[3].New_Address__c = addressRec.id;
                //cs[1].Temp_Stop_Date__c = Date.today();
                cs[3].Temp_Stop_Date__c = Date.today();
                cs[3].Restart_date__c = date.today()+1;
                //cs[3].Vendor__c = acc.id;
                cs[3].Vendor_Chargeable_Courier__c = true;
                cs[3].Vendor_Chargeable_Paper__c = false;
                cs[3].Vendor_Email__c = 'test@test.com';
                cs[3].Vendor_No__c = '1234567';
                cs[3].Vendor_Subscription_Created__c = true;
                
                insert cs;

               
                
                List<Subscription_Vendor__c> subVen = TestDataFactory.createSubscriptionVendor(4);
                subVen[0].Account__c = acc.id;
                subVen[0].Vendor__c = acc.id;
                subVen[0].Recipient__c = conList[0].id;
                subVen[0].Subscription_Stop_Date__c = date.today() +1;
                
                subVen[1].Account__c = acc.id;
                subVen[1].Vendor__c = acc.id;
                subVen[1].Recipient__c = conList[0].id;
                subVen[1].Subscription_Stop_Date__c = date.today() +1;
                                
                subVen[2].Account__c = acc.id;
                subVen[2].Vendor__c = acc.id;
                subVen[2].Recipient__c = conList[0].id;
                subVen[2].Subscription_Stop_Date__c = date.today() +1;
                
                subVen[3].Account__c = acc.id;
                subVen[3].Vendor__c = acc.id;
                subVen[3].Recipient__c = conList[0].id;
                subVen[3].Subscription_Stop_Date__c = date.today() +1;
                insert subVen;
                
                          
                List<Case_Vendor_Subscription__c> csVenSub = TestDataFactory.createCaseVendorSub(4);
                csVenSub[0].Case__c = cs[0].id;
                csVenSub[0].Subscription_Vendor__c = subVen[0].id;
                csVenSub[0].Account__c = acc.id;
                csVenSub[0].Address__c = addressRec.id;
                
                csVenSub[1].Case__c = cs[1].id;
                csVenSub[1].Subscription_Vendor__c = subVen[1].id;
                csVenSub[1].Account__c = acc.id;
                csVenSub[1].Address__c = addressRec.id;
                
                csVenSub[2].Case__c = cs[2].id;
                csVenSub[2].Subscription_Vendor__c = subVen[2].id;
                csVenSub[2].Account__c = acc.id;
                csVenSub[2].Address__c = addressRec.id;
                
                csVenSub[3].Case__c = cs[3].id;
                csVenSub[3].Subscription_Vendor__c = subVen[3].id;
                csVenSub[3].Account__c = acc.id;
                csVenSub[3].Address__c = addressRec.id;
                
                insert csVenSub;
                
                
                List<Order_Line_Item_Vendor__c> orderlineVendor = TestdataFactory.createOrderLineItemVendor(4);
                orderlineVendor[0].Start_Date__c = date.today().addDays(1);
                orderlineVendor[0].Order__c = orderRec.id;
                orderlineVendor[0].Case__c = cs[0].id;
                orderlineVendor[0].Subscription_Vendor__c = subVen[0].id;
                
                orderlineVendor[1].Start_Date__c = date.today().addDays(1);
                orderlineVendor[1].Order__c = orderRec.id;
                orderlineVendor[1].Case__c = cs[1].id;
                orderlineVendor[1].Subscription_Vendor__c = subVen[1].id;
                
                orderlineVendor[2].Start_Date__c = date.today().addDays(1);
                orderlineVendor[2].Order__c = orderRec.id;
                orderlineVendor[2].Case__c = cs[2].id ;    
                orderlineVendor[2].Subscription_Vendor__c = subVen[2].id;  
                
                orderlineVendor[3].Start_Date__c = date.today().addDays(1);
                orderlineVendor[3].Order__c = orderRec.id;
                orderlineVendor[3].Case__c = cs[3].id ;    
                orderlineVendor[3].Subscription_Vendor__c = subVen[3].id;
                database.insert(orderlineVendor);
                
                
                //Sunday_Publication__r
                List<Publication__c> sundayPublicationList = TestDataFactory.createPublication(1);
                sundayPublicationList[0].Publication_Code__c = 'SPB1';
                Database.insert(sundayPublicationList);
                
                /*Subscription_Vendor_Publication__c subVenPub = TestDataFactory.createVendorPublication(1)[0];
                subVenPub.Subscription_Vendor__c = subVen.id;
                subVenPub.Publication__c = sundayPublicationList[0].id;
                insert subVenPub; */
                
                //Publication__c
                List<Publication__c> publicationList = TestDataFactory.createPublication(1);
                for (Publication__c publication : publicationList) {
                publication.Publication_Code__c = 'PUB1';
                publication.Sunday_Publication__c = sundayPublicationList[0].id;
                }
                Database.insert(publicationList);
                
                
                Address_Assignment__c addAss1 = new Address_Assignment__c();
                addAss1.Case__c = cs[0].id;
                addAss1.Address__c = addressRec.id;
                addAss1.Contact__c = conList[0].id;
                addAss1.Effective_Date__c = Date.today().addDays(2);
                addAss1.Vendor__c = acc.id;
                insert addAss1;
                
                Address_Assignment__c addAss2 = new Address_Assignment__c();
                addAss2.Case__c = cs[1].id;
                addAss2.Address__c = addressRec.id;
                addAss2.Contact__c = conList[0].id;
                addAss2.Effective_Date__c = Date.today().addDays(2);
                addAss2.Vendor__c = acc.id;
                insert addAss2;
                
                Address_Assignment__c addAss3 = new Address_Assignment__c();
                addAss3.Case__c = cs[2].id;
                addAss3.Address__c = addressRec.id;
                addAss3.Contact__c = conList[0].id;
                addAss3.Effective_Date__c = Date.today().addDays(2);
                addAss3.Vendor__c = acc.id;
                insert addAss3;
                
                Address_Assignment__c addAss4 = new Address_Assignment__c();
                addAss4.Case__c = cs[3].id;
                addAss4.Address__c = addressRec.id;
                addAss4.Contact__c = conList[0].id;
                addAss4.Effective_Date__c = Date.today().addDays(2);
                addAss4.Vendor__c = acc.id;
                insert addAss4;
                
                
                Postal_Zone__c postalZone = new Postal_Zone__c();
                postalZone.Name = '013';
                database.insert(postalZone);
                
                
                Post_Sector_Ops_Rep_Mapping__c postSector  = new Post_Sector_Ops_Rep_Mapping__c();
                postSector.Zone__C = postalZone.id;
                postSector.Vendor_Ops__c =  [SELECT Id, IsActive from User where IsActive = true and Id!= null LIMIT 1].id;
                //postSector.Vendor_Ops__c = u.id;
                database.insert(postSector);
                
                
                List<Subscription_Vendor_Publication__c> subVenPub = TestDataFactory.createVendorPublication(4);
                subVenPub[0].Subscription_Vendor__c = subVen[0].id;
                subVenPub[0].Publication__c = publicationList[0] .id;
                subVenPub[0].Mon__c = 1;
                subVenPub[0].Tue__c = 2;
                subVenPub[0].Wed__c = 3;
                subVenPub[0].Thu__c = 4;
                subVenPub[0].Fri__c = 5;
                subVenPub[0].Sat__c = 6;
                subVenPub[0].Sun__c = 7;
                
                subVenPub[1].Subscription_Vendor__c = subVen[1].id;
                subVenPub[1].Publication__c = publicationList[0] .id;
                subVenPub[1].Mon__c = 1;
                subVenPub[1].Tue__c = 2;
                subVenPub[1].Wed__c = 3;
                subVenPub[1].Thu__c = 4;
                subVenPub[1].Fri__c = 5;
                subVenPub[1].Sat__c = 6;
                subVenPub[1].Sun__c = 7;
                
                
                subVenPub[2].Subscription_Vendor__c = subVen[2].id;
                subVenPub[2].Publication__c = publicationList[0] .id;
                subVenPub[2].Mon__c = 1;
                subVenPub[2].Tue__c = 2;
                subVenPub[2].Wed__c = 3;
                subVenPub[2].Thu__c = 4;
                subVenPub[2].Fri__c = 5;
                subVenPub[2].Sat__c = 6;
                subVenPub[2].Sun__c = 7;
                
                subVenPub[3].Subscription_Vendor__c = subVen[3].id;
                subVenPub[3].Publication__c = publicationList[0].id;
                subVenPub[3].Mon__c = 1;
                subVenPub[3].Tue__c = 2;
                subVenPub[3].Wed__c = 3;
                subVenPub[3].Thu__c = 4;
                subVenPub[3].Fri__c = 5;
                subVenPub[3].Sat__c = 6;
                subVenPub[3].Sun__c = 7;
                insert subVenPub;
                
                
                Test.startTest();
                    SP_VendorSubscriptionNotificationsBatch batch = new SP_VendorSubscriptionNotificationsBatch();
                    SP_VendorSubscriptionNotificationsBatch batch2 = new SP_VendorSubscriptionNotificationsBatch(new set<id>{cs[0].Id, cs[1].Id, cs[2].Id, cs[3].id});
                    ID batchprocessid2 = Database.executeBatch(batch2, 200);
                Test.stopTest();
                     
    }
    
    
}