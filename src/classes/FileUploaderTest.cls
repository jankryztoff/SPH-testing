@isTest (seeAllData=false)
public class FileUploaderTest {

    static testMethod void readFileTest() {  
    
        List<Account> accList = TestDataFactory.createAccount(2, 'Direct Corporate');         
        accList[0].name = '001N000000KoiRTIAZ';
        accList[0].name = '001N000000KoiRTIAZ';
        insert accList;
        
        String csvFile= 'Account Name,NRIC,Email,Phone,Mobile,Record Type,Date of Birth,Gender,Recipient Contact First Name,Recipient Contact Last Name,Home Number,Mobile Number 1,Email Address 1,Billing Contact First Name,Billing Contact Last Name,Home Number,Mobile Number 1,Email Address 1,Recipient Contact Postal Code,Recipient Contact House/Block Number,Recipient Contact Level Number,Recipient Contact Unit Number,Recipient Contact Singpost Address Type,Billing Contact Postal Code,Billing Contact House/Block Number,Billing Contact Level Number,Billing Contact Unit Number,Billing Contact Singpost Address Type,Subscription Start Date,Subscription End Date,Delivery Charge Type,Payment Mode,Credit Amount,Credit Balance,Check Amount,Check Dated,Check Issuing Bank,Check No.,Earliest Start Date,Start Date,Main Package Period,Qty,Term Length,Main Package ID,Main Package Billing Type,Main Package Type,Delivered By,Earliest Start Date,Start Date,Main Package Period,Qty,Term Length,Main Package ID,Main Package Billing Type,Main Package Type,Delivered By, Account id\n';
        csvFile += '001N000000KoiRTIAZ,45123,sph1@sph.com,456-89452,95468563138,Direct SPH Inter-Division,1992-03-12,Female,Alejandra,Merceds,404-5896,95468563138,sph1@sph.com,Alejandra2,Merceds2,404-5896,95468563138,sph11@sph.com,100,21,21,21,U,100,22,22,22,U,2015-03-01,2016-03-01,C,Cash,100,111,11,2015-03-01,11,11,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor, + accList[0].id \n';
        csvFile += '001N000000KoiRTIAZ,45123,sph2@sph.com,456-89123,85468563132,Direct Corporate,1992-04-12,Male,John,Villa,404-5896,95468563138,sph2@sph.com,John3,Villa3,404-5896,95468563138,sph12@sph.com,100,12,12,12,U,100,23,23,23,U,2015-03-01,2016-03-01,C,Cash,200,222,11,2015-03-01,12,12,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor,  +accList[0].id\n';
        csvFile += '001N000000KoiRTIAZ,45123,sph3@sph.com,456-89456,75468563133,Direct Corporate,1992-05-12,Female,Carla,Sy,404-5896,95468563138,sph3@sph.com,Carla4,Sy5,404-5896,95468563138,sph13@sph.com,100,13,13,13,U,100,24,24,24,U,2015-03-01,2016-03-01,C,Cash,300,333,11,2015-03-01,13,13,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor, +accList[1].id\n';
        
            
        
        Blob csvBlob = Blob.valueOf(csvFile);
        
             
        PageReference Readfile;
        PageReference upload;

        
        FileUploader fu = new FileUploader();
        fu.Message();
        fu.contentFile = csvBlob;  
        fu.upload();      
         
        
        List<Order__c> ordercList = fu.getuploadedOrder();
        //System.assert(ordercList != null);  
                
                   
    }
    
     static testMethod void messageTest() {
    
        FileUploader fu = new FileUploader ();    
        List<String> results = new List<String>{'Failed', 'Successful'};
    
        for (String r : results) {
            PageReference pRef = new Pagereference('/apex/FileUploaderAll?result=' + r);
            Test.setCurrentPage(pRef);
            fu.Message();
        }
        
        fu.cancel();        
    } 
    

    static testmethod void uploadTest() {
    
        List<Account> accList = TestDataFactory.createAccount(2, 'Direct Corporate');         
        accList[0].name = '001N000000KoiRTIAZ';
        accList[0].name = '001N000000KoiRTIAZ';
        insert accList;
        
        String csvFile= 'Account Name,NRIC,Email,Phone,Mobile,Record Type,Date of Birth,Gender,Recipient Contact First Name,Recipient Contact Last Name,Home Number,Mobile Number 1,Email Address 1,Billing Contact First Name,Billing Contact Last Name,Home Number,Mobile Number 1,Email Address 1,Recipient Contact Postal Code,Recipient Contact House/Block Number,Recipient Contact Level Number,Recipient Contact Unit Number,Recipient Contact Singpost Address Type,Billing Contact Postal Code,Billing Contact House/Block Number,Billing Contact Level Number,Billing Contact Unit Number,Billing Contact Singpost Address Type,Subscription Start Date,Subscription End Date,Delivery Charge Type,Payment Mode,Credit Amount,Credit Balance,Check Amount,Check Dated,Check Issuing Bank,Check No.,Earliest Start Date,Start Date,Main Package Period,Qty,Term Length,Main Package ID,Main Package Billing Type,Main Package Type,Delivered By,Earliest Start Date,Start Date,Main Package Period,Qty,Term Length,Main Package ID,Main Package Billing Type,Main Package Type,Delivered By, Account id\n';
        csvFile += '001N000000KoiRTIAZ,45123,sph1@sph.com,456-89452,95468563138,Direct SPH Inter-Division,1992-03-12,Female,Alejandra,Merceds,404-5896,95468563138,sph1@sph.com,Alejandra2,Merceds2,404-5896,95468563138,sph11@sph.com,100,21,21,21,U,100,22,22,22,U,2015-03-01,2016-03-01,C,Cash,100,111,11,2015-03-01,11,11,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor, + accList[0].id \n';
        csvFile += '001N000000KoiRTIAZ,45123,sph2@sph.com,456-89123,85468563132,Direct Corporate,1992-04-12,Male,John,Villa,404-5896,95468563138,sph2@sph.com,John3,Villa3,404-5896,95468563138,sph12@sph.com,100,12,12,12,U,100,23,23,23,U,2015-03-01,2016-03-01,C,Cash,200,222,11,2015-03-01,12,12,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor,  +accList[0].id\n';
        csvFile += '001N000000KoiRTIAZ,45123,sph3@sph.com,456-89456,75468563133,Direct Corporate,1992-05-12,Female,Carla,Sy,404-5896,95468563138,sph3@sph.com,Carla4,Sy5,404-5896,95468563138,sph13@sph.com,100,13,13,13,U,100,24,24,24,U,2015-03-01,2016-03-01,C,Cash,300,333,11,2015-03-01,13,13,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor, +accList[1].id\n';
        

      /*  String csvFile= 'Account Name,NRIC,Email,Phone,Mobile,Record Type,Date of Birth,Gender,Recipient Contact First Name,Recipient Contact Last Name,Home Number,Mobile Number 1,Email Address 1,Billing Contact First Name,Billing Contact Last Name,Home Number,Mobile Number 1,Email Address 1,Recipient Contact Postal Code,Recipient Contact House/Block Number,Recipient Contact Level Number,Recipient Contact Unit Number,Recipient Contact Singpost Address Type,Billing Contact Postal Code,Billing Contact House/Block Number,Billing Contact Level Number,Billing Contact Unit Number,Billing Contact Singpost Address Type,Subscription Start Date,Subscription End Date,Delivery Charge Type,Payment Mode,Credit Amount,Credit Balance,Check Amount,Check Dated,Check Issuing Bank,Check No.,Earliest Start Date,Start Date,Main Package Period,Qty,Term Length,Main Package ID,Main Package Billing Type,Main Package Type,Delivered By,Earliest Start Date,Start Date,Main Package Period,Qty,Term Length,Main Package ID,Main Package Billing Type,Main Package Type,Delivered By\n';
        csvFile += '001N000000KoiRTIAZ,45123,sph1@sph.com,456-89452,95468563138,Direct SPH Inter-Division,1992-03-12,Female,Alejandra,Merceds,404-5896,95468563138,sph1@sph.com,Alejandra2,Merceds2,404-5896,95468563138,sph11@sph.com,100,21,21,21,U,100,22,22,22,U,2015-03-01,2016-03-01,C,Cash,100,111,11,2015-03-01,11,11,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor\n';
        csvFile += '001N000000KoiRTIAZ,45123,sph2@sph.com,456-89123,85468563132,Direct Corporate,1992-04-12,Male,John,Villa,404-5896,95468563138,sph2@sph.com,John3,Villa3,404-5896,95468563138,sph12@sph.com,100,12,12,12,U,100,23,23,23,U,2015-03-01,2016-03-01,C,Cash,200,222,11,2015-03-01,12,12,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor\n';
        csvFile += '001N000000KoiRTIAZ,45123,sph3@sph.com,456-89456,75468563133,Direct Corporate,1992-05-12,Female,Carla,Sy,404-5896,95468563138,sph3@sph.com,Carla4,Sy5,404-5896,95468563138,sph13@sph.com,100,13,13,13,U,100,24,24,24,U,2015-03-01,2016-03-01,C,Cash,300,333,11,2015-03-01,13,13,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor\n';*/
       
        Blob csvBlob = Blob.valueOf(csvFile);
        
        FileUploader fu = new FileUploader (); 
        fu.contentFile = csvBlob; 
        fu.nameFile = csvBlob.toString(); 
        fu.upload();    
        
    }  
    
      static testmethod void unitTest1() {
    
       List<Account> accList = TestDataFactory.createAccount(1, 'Direct Corporate');       
        accList[0].name = '001N000000KoiRTIAZ';   
        insert accList;
        
        
         Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];      
                postal.House_Block_Number__c = '12';
                postal.Name = 'Test Postal';
                postal.Building_Name__c = 'Test Building';
                postal.Street_Name__c = 'Test Street';
                insert postal;
        
              
        Account accIdExp = [SELECT Id FROM Account WHERE Id=:accList[0].id];
        
               
        String csvFile= 'Account Name,NRIC,Email,Phone,Mobile,Record Type,Date of Birth,Gender,Recipient Contact First Name,Recipient Contact Last Name,Home Number,Mobile Number 1,Email Address 1,Billing Contact First Name,Billing Contact Last Name,Home Number,Mobile Number 1,Email Address 1,Recipient Contact Postal Code,Recipient Contact House/Block Number,Recipient Contact Level Number,Recipient Contact Unit Number,Recipient Contact Singpost Address Type,Billing Contact Postal Code,Billing Contact House/Block Number,Billing Contact Level Number,Billing Contact Unit Number,Billing Contact Singpost Address Type,Subscription Start Date,Subscription End Date,Delivery Charge Type,Payment Mode,Credit Amount,Credit Balance,Check Amount,Check Dated,Check Issuing Bank,Check No.,Earliest Start Date,Start Date,Main Package Period,Qty,Term Length,Main Package ID,Main Package Billing Type,Main Package Type,Delivered By,Earliest Start Date,Start Date,Main Package Period,Qty,Term Length,Main Package ID,Main Package Billing Type,Main Package Type,Delivered By, Account id\n';
        csvFile += accIdExp.Id +',45123,sph1@sph.com,456-89452,95468563138,Direct SPH Inter-Division,1992-03-12,Female,Alejandra,Merceds,2015-08-02,95468563138,sph1@sph.com,Alejandra2,Merceds2,2015-08-02,2015-09-02,sph11@sph.com,100,21,21,21,U,100,2015-09-10,22,22,3.70,' + postal.Id + ',2016-03-01,C,Cash,100,111,11,2015-03-01,11,11,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor,2015-03-01,2,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor, + accList[0].id \n';
       // csvFile += '001N000000KoiRTIAZ,45123,sph2@sph.com,456-89123,85468563132,Direct Corporate,1992-04-12,Male,John,Villa,404-5896,95468563138,sph2@sph.com,John3,Villa3,404-5896,95468563138,sph12@sph.com,100,12,12,12,U,100,23,23,23,U,2015-03-01,2016-03-01,C,Cash,200,222,11,2015-03-01,12,12,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor,  +accList[0].id\n';
       // csvFile += '001N000000KoiRTIAZ,45123,sph3@sph.com,456-89456,75468563133,Direct Corporate,1992-05-12,Female,Carla,Sy,404-5896,95468563138,sph3@sph.com,Carla4,Sy5,404-5896,95468563138,sph13@sph.com,100,13,13,13,U,100,24,24,24,U,2015-03-01,2016-03-01,C,Cash,300,333,11,2015-03-01,13,13,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor,2015-03-01,2015-03-01,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor, +accList[1].id\n';
        

       
        Blob csvBlob = Blob.valueOf(csvFile);
        
        FileUploader fu = new FileUploader (); 
        fu.contentFile = csvBlob; 
        fu.nameFile = csvBlob.toString(); 
        fu.ReadFile();
    }  
    
}