@isTest (Seealldata = TRUE)
public class BT_ImportVendorSubscriptionTest{
    /*

    static testMethod void importVendorSubscriptionTest(){
        
         List<BT_CO_VSS_ImportVendorSubscription__c> ivsList = new List<BT_CO_VSS_ImportVendorSubscription__c>();
        List<BT_CO_VSS_ImportVendorSubscription__c> ivs1List = new List<BT_CO_VSS_ImportVendorSubscription__c>();
                                     
          Subscription_Vendor__c subv = new Subscription_Vendor__c();
          subv.Legacy_Create_By__c = 'Test';
          subv.Legacy_Create_Date__c = '20150606';
          subv.Legacy_Update_By__c = '20150706';
          subv.Legacy_Update_Date__c = '20150706';
          subv.Subscription_Stop_Date__c = Date.parse('02/02/2016');
          insert subv;
          
          Subscription_Vendor_Publication__c subvenpub = new Subscription_Vendor_Publication__c();
            subvenpub.Subscription_Vendor__c = subv.Id;
            insert subvenpub;
            
            BT_CO_LEG2SF_Log__c LEG2SF  = new BT_CO_LEG2SF_Log__c();
            LEG2SF.Invalid_Record_Count__c = 3.0;        
            LEG2SF.Total_Record_Count__c = 3.0;  
            LEG2SF.Valid_Record_Count__c = 3.0;
            LEG2SF.Interface_ID__c = 'DIR092DX';
            LEG2SF.Batch_Run_Date__c = date.today();
            LEG2SF.DML_Status__c = 'Failed';
            LEG2SF.Stack_Trace__c = 'Please see BT_CO_VSS_ImportVendorSubscription__c for validation details.';
            
            insert LEG2SF  ;
   
        BT_CO_VSS_ImportVendorSubscription__c ivs = new BT_CO_VSS_ImportVendorSubscription__c();
        ivs.subscriberName__c = 'TestA';
        ivs.subscriptionUpdateIndicator__c = 'A';
        ivs.hdsRecipientId__c = 'hds123';
        //ivs.crsmAccountId__c = acc.id;
        ivs.subscriberName__c = 'Test';
        ivs.subscriberFaxNumber__c = '634765';
        ivs.subscriberResidentTelephoneNumber__c = '123456';
        ivs.subscriberOfficeTelephoneNumber__c = '6324516';
        ivs.subscriberOfficeTelephoneExtension__c = '7263864';      
        ivs.recipientUpdateIndicator__c = 'A';
        ivs.hdsContactId__c = 'hds234';
        ivs.recipientName__c = 'Test';
        ivs.recipientResidenceTelephoneNumber__c = '2654245';
        ivs.recipientOfficeTelephoneNumber__c = '6376836';
        ivs.recipientOfficeTelephoneExtension__c = '6575';
        ivs.recipientFaxNumber__c = '546298';
        ivs.recipientHandphoneNumber__c = '8263877';
        ivs.recipientEmail__c = 'test@hotmail.com';
        ivs.recipientNric__c = '';
        ivs.recipientCompanyName__c = 'TestAcc';
        ivs.subscriberStreetCode__c = '218';
        ivs.subscriberBuildingCode__c = '453'; 
        ivs.subscriberHouseBlockNumber__c = '8'; 
        ivs.subscriberLevel__c = '6';
        ivs.subscriberUnit__c = '56';
        ivs.subscriberPostalCode__c = '63743';
        ivs.recipientStreetCode__c = '218';
        ivs.recipientBuildingCode__c = '453';
        ivs.recipientHouseBlockNumber__c = '8'; 
        ivs.recipientLevel__c = '6';
        ivs.recipientUnit__c = '56';
        ivs.recipientPostalCode__c = '40053';
        ivs.startDate__c = '20150304';
        ivs.stopDate__c = '20150708';
        ivs.vendorGroup__c = 'D';
        ivs.vendorNumber__c = '5';
        ivsList.add(ivs);
        insert ivsList;
        
         Publication__c p = new Publication__c();
        p.Name = 'PTest';
        p.Publication_Code__c = 'D462';
        p.Published_Days__c = 'YYYYYYY';
        p.Publication_Type__c = 'M';
    
    insert p;
        
        Contact con = new Contact();
            con.FirstName = 'testa';
            con.LastName = 'test';
            con.HDS_Contact_Id__c = 'hds462';
            con.Phone = '1234567';
            con.Mobile_Number__c = '09155568874'; 
            con.Mobile_Number_2__c = '09112234567';
            con.Recipient_Number__c = 299999993;
            con.Recipient_Number_Show__c = '299999993';
            insert con;
            
           Account acc = new Account();
            acc.Name = 'Test Account';
            //acc.RecordTypeID = '012N00000008ic6';
            acc.Vendor_Group__c = 'M';
            acc.Vendor_Code__c  = '6';
            acc.HDS_Recipient_Id__c = 'hds879';
            acc.Subscriber_Name__c = con.FirstName;
            //acc.HDS_Recipient_Id__c = 
        insert acc;
        
        Country__c testCountry = TestDataFactory.createCountry(1)[0];
            testCountry.Account__c = acc.Id;
            testCountry.Code__c = '6547954';
            testCountry.Country_Name__c = 'Singapore';
            insert testCountry;
            
        Singpost_Address__c singadd = new Singpost_Address__c();
            singadd.Name = '637343';
            singadd.Street_Name__c = 'Name';
            singadd.Number_of_Units__c = 3;
            singadd.Building_Name__c = 'abc';
            singadd.House_Block_Number__c = '3';
        
        insert singadd ;
        
        Address__c addressRecord = new Address__c();
            addressRecord.Block_House_Number__c = '3';
            addressRecord.Level_Number__c  = '30';
            addressRecord.Unit_Number__c = '30';
            addressRecord.Postal_Code__c = singadd.Id;
            addressRecord.Country__c = testCountry.Id;
        
        insert addressRecord ;
        
        BT_CO_VSS_ImportVendorSubscription__c ivs1 = new BT_CO_VSS_ImportVendorSubscription__c();
        ivs1.subscriberName__c = 'TestA';
        ivs1.subscriptionUpdateIndicator__c = 'A';
        ivs1.hdsRecipientId__c = 'hds879';
        ivs1.crsmAccountId__c = acc.id;
        ivs1.subscriberName__c = 'Test';
        ivs1.subscriberFaxNumber__c = '634765';
        ivs1.subscriberResidentTelephoneNumber__c = '123456';
        ivs1.subscriberOfficeTelephoneNumber__c = '6324516';
        ivs1.subscriberOfficeTelephoneExtension__c = '7263864';              
        ivs1.recipientUpdateIndicator__c = 'U';
        ivs1.hdsContactId__c = 'hds462';
        ivs1.recipientName__c = 'Test';
        ivs1.recipientResidenceTelephoneNumber__c = '26542545';
        ivs1.recipientOfficeTelephoneNumber__c = '637636';
        ivs1.recipientOfficeTelephoneExtension__c = '6575';
        ivs1.recipientFaxNumber__c = '5462948';
        ivs1.recipientHandphoneNumber__c = '823877';
        ivs1.recipientEmail__c = 'testuser@hotmail.com';
        ivs1.recipientNric__c = '';
        ivs1.recipientCompanyName__c = 'TestAcc';
        ivs1.subscriberStreetCode__c = '218';
        ivs1.subscriberBuildingCode__c = '453'; 
        ivs1.subscriberHouseBlockNumber__c = '8'; 
        ivs1.subscriberLevel__c = '6';
        ivs1.subscriberUnit__c = '56';
        ivs1.subscriberPostalCode__c = '637343';
        ivs1.recipientStreetCode__c = '218';
        ivs1.recipientBuildingCode__c = '453';
        ivs1.recipientHouseBlockNumber__c = '8'; 
        ivs1.recipientLevel__c = '6';
        ivs1.recipientUnit__c = '56';
        ivs1.recipientPostalCode__c = '40053';
        ivs1.startDate__c = '28750304';
        ivs1.stopDate__c = '20555708';
        ivs1.publicationCode__c = 'D462';
        ivs1.vendorGroup__c = 'M';
        ivs1.vendorNumber__c = '6';
        ivs1List.add(ivs1);
        insert ivs1List;
        
        List<BT_CO_VSS_ImportVendorSubscription__c> ivs2 = [select subscriptionUpdateIndicator__c from BT_CO_VSS_ImportVendorSubscription__c where id =: ivs.id];
        ivs2[0].subscriptionUpdateIndicator__c= 'D';
        update ivs2;
        
        List<BT_CO_VSS_ImportVendorSubscription__c> ivs5 = [select subscriptionUpdateIndicator__c from BT_CO_VSS_ImportVendorSubscription__c where id =: ivs.id];
        ivs5[0].subscriptionUpdateIndicator__c= 'V';
        try{
            update ivs5;
        }catch(exception e){}
        List<BT_CO_VSS_ImportVendorSubscription__c> ivs3 = [select subscriptionUpdateIndicator__c from BT_CO_VSS_ImportVendorSubscription__c where id =: ivs.id];
        ivs3[0].subscriptionUpdateIndicator__c= 'D';
        try{
            update ivs3;
        }catch(exception e){}
        List<BT_CO_VSS_ImportVendorSubscription__c> ivs4 = [select subscriptionUpdateIndicator__c from BT_CO_VSS_ImportVendorSubscription__c where id =: ivs.id];
        ivs4[0].subscriptionUpdateIndicator__c= 'U';
        try{
            update ivs4;
        }catch(exception e){}
        List<BT_CO_VSS_ImportVendorSubscription__c> ivs6 = [select subscriptionUpdateIndicator__c from BT_CO_VSS_ImportVendorSubscription__c where id =: ivs.id];
        ivs6[0].subscriptionUpdateIndicator__c= 'R';
        try{
            update ivs6;
        }catch(exception e){}

    }
    */
    
}