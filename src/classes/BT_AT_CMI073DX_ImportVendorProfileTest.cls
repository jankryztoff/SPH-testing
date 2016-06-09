@isTest                   
public class BT_AT_CMI073DX_ImportVendorProfileTest{

static testMethod void testInsert(){
        
        List <Account> testAccount = TestDataFactory.createAccount(1, 'Vendor');
        List <Singpost_Address__c> postAdd = TestDataFactory.createSingpostAddress(1);
        List<BT_CO_CMISPOP_ImportVendorProfile__c> ivpList = new List<BT_CO_CMISPOP_ImportVendorProfile__c>();
        List<BT_CO_CMISPOP_ImportVendorProfile__c> ivpListUpdate = new List<BT_CO_CMISPOP_ImportVendorProfile__c>();
        List<BT_CO_CMISPOP_ImportVendorProfile__c> ivpListUpdatevalid = new List<BT_CO_CMISPOP_ImportVendorProfile__c>();
       List <Account> testAccountUpdate = new List <Account>();
        
        insert postAdd;
        insert testAccount;
        
        Integer i;
       
        Account acc = new Account();
         acc.Name = 'Test Account'+i;
         //acc.RecordTypeID = '012N00000008icL';
         acc.Vendor_Code__c = 'Code1';
         
         insert acc;
    
        
        for(i=0; i<3; i++){
            BT_CO_CMISPOP_ImportVendorProfile__c ivp = new BT_CO_CMISPOP_ImportVendorProfile__c();
            ivp.Name = 'CMI073DX';
            ivp.vendorCode__c = 'Code1';
            ivp.vendorGroup__c = 'G';
            ivp.vendorName__c = 'Test Vendor Name';
            ivp.vendorStatus__c = '1';
            ivp.vendorType__c = 'TY';
            ivp.zoneCode__c = '2';
            ivp.postalCode__c = postAdd[0].Name;
            ivp.blockHouseNumber__c = 'block1';
            ivp.buildingName__c = 'Building Name';
            ivp.email__c = 'sphc0035g@yahoo.com.sg';
            ivp.faxNumber__c = '654-3210';
            ivp.gstRegistrationNumber__c = 'Registration12345';
            ivp.handphoneNumber__c = '654-3210';
            ivp.level__c = 'LV1';
            ivp.nricPassport__c = 'G1234567M';
            ivp.pagerNumber__c = '6543-210-98';
            ivp.registeredName__c = 'Test REG Name';
            ivp.streetName__c = '888';
            ivp.telephoneOffice__c = '654-3210';
            ivp.telephoneResidence__c = '654-3210';
            ivp.unitNumber__c = '1234';
            ivpList.add(ivp);
        }

            insert ivpList;
       
       /* 
         
         for(Account test : [select Vendor_Type__c, Vendor_Group__c, Zone_Code__c, Vendor_Name__c, Vendor_Code__c from Account where Name =: testAccount[0].Name]){
             
                test.Vendor_Type__c  = 'TY';
                test.Vendor_Group__c  = 'G';
                test.Zone_Code__c  = '2';
                test.Vendor_Code__c = 'Code1';
                test.Unit_Number__c  = '1234';
                test.Level_Number__c  = 'LV1';
                test.House_Block_Number__c  = 'block1';
                test.Street_Name__c  = '888';
                test.Building_Name__c  = 'Building Name';
                test.PostalCode__c  = postAdd[0].Name;
                test.Telephone_Residence__c  = '654-3210';
                test.Telephone_Office__c  = '654-3210';
                test.Email__c  = 'sphc0035g@yahoo.com.sg';
                test.NRIC__c = 'G1234567M';
                test.GST_Registration_Number__c  = 'Registration12345';
             testAccountUpdate.add(test);
             
         }
        
            update testAccountUpdate;
       
        */
        for(BT_CO_CMISPOP_ImportVendorProfile__c ivp : [select id, vendorCode__c, vendorGroup__c, vendorName__c, vendorStatus__c, email__c, faxNumber__c, postalCode__c  from BT_CO_CMISPOP_ImportVendorProfile__c where Name = :'CMI073DX']){
  
            ivp.vendorCode__c = '';
            ivp.vendorGroup__c = '';
            ivp.vendorName__c = '';
            ivp.vendorStatus__c = 'Y';
            ivp.email__c = 'testemail##';
            ivp.nricPassport__c = 'Sd7A';
            ivp.faxNumber__c = '';
            ivp.postalCode__c = '';
            ivpListUpdate.add(ivp);
        }
        
        update ivpListUpdate;
        
        for(BT_CO_CMISPOP_ImportVendorProfile__c ivp : [select id, vendorCode__c, vendorGroup__c, vendorName__c, vendorStatus__c, email__c, faxNumber__c, postalCode__c  from BT_CO_CMISPOP_ImportVendorProfile__c where Name = :'CMI073DX']){
  
            ivp.vendorCode__c = 'Code2';
            ivp.vendorGroup__c = 'G';
            ivp.vendorName__c = 'Test Vendor Name';
            ivp.vendorStatus__c = '1';
            ivp.email__c = 'sphc0035g@yahoo.com.sg';
            ivp.nricPassport__c = 'G1234567M';
            ivp.faxNumber__c = '654-3210';
            ivp.postalCode__c = postAdd[0].Name;
            ivpListUpdatevalid.add(ivp);
        }
        
        update ivpListUpdatevalid;
       
        }

}