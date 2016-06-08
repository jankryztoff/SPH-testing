/**
@Author Alfred Abrina
@name DigitalComplaintControllerTest
@CreateDate 02/15/2015
@Description Test class for CsvFileUploadController
@Version <1.0>
@reference CsvFileUploadController
*/  
@isTest (Seealldata = TRUE)
private class CsvFileUploadControllerTest{
/**
* Feed the csv format text to the controller 
* @name test1
* @param none
* @return none
*/  
    static testmethod void test1(){
        Id profileID = (Id) ConstantsSLB.getKeyId('Profile_Standard User');
        User testUserCFUCT = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );   
        //The test will run as the user created.
        System.runAs(testUserCFUCT) {
             Document doc = new Document();
             doc.name = '0016235';
                    String file = '001N000000KoiRTIAZ,45123,sph1@sph.com,456-89452,95468563138,Direct SPH Inter-Division,15/02/1990,Female,Alejandra,Merceds,404-5896,95468563138,sph1@sph.com,Alejandra2,Merceds2,404-5896,95468563138,sph11@sph.com,100,21,21,21,U,100,22,22,22,U,03/02/2015,03/01/2015,C,Cash,100,111,11,03/02/2015,11,11,03/01/2015,03/02/2012,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor,03/01/2015,03/01/2015,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor\n';
                    file += '001N000000KoiRTIAZ,45123,sph2@sph.com,456-89123,85468563132,Direct Corporate,15/02/1990,Male,John,Villa,404-5896,95468563138,sph2@sph.com,John3,Villa3,404-5896,95468563138,sph12@sph.com,100,12,12,12,U,100,23,23,23,U,03/01/2012,03/01/2016,C,Cash,200,222,11,03/01/2015,12,12,03/01/2015,03/01/2015,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor,03/01/2015,03/01/2015,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor\n';
                    file += '001N000000KoiRTIAZ,45123,sph3@sph.com,456-89456,75468563133,Direct Corporate,15/02/1990,Female,Carla,Sy,404-5896,95468563138,sph3@sph.com,Carla4,Sy5,404-5896,95468563138,sph13@sph.com,100,13,13,13,U,100,24,24,24,U,03/01/2015,03/01/2015,C,Cash,300,333,11,03/01/2015,13,13,03/01/2015,03/01/2015,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor,03/01/2015,03/01/2015,11,1,11,PKG Bundle - Full Prepaid - Magazine,Full Prepaid,Base,Vendor\n';
             doc.body = (true) ? Blob.valueOf(file) : null;
             doc.AuthorId = UserInfo.getUserId(); 
             doc.FolderId = UserInfo.getUserId(); 
             insert doc;
             
             System.assertEquals ('0016235', doc.name);
             Document test_doc = [Select Id from Document where Name =: doc.name];
               
             CsvFileUploadController cfuc = new CsvFileUploadController();
             PageReference pRef = new Pagereference('/apex/CsvFileUploadPage?Id=' + test_doc.Id);
             Test.setCurrentPage(pRef);
             
             ApexPages.currentPage().getParameters().put('id', test_doc.Id);
             cfuc.upload();
             cfuc.parseCsv();   
             cfuc.cancel(); 
        }
    }
/**
* Feed empty data to the controller 
* @name testEmptyFile
* @param none
* @return none
*/      
    static testmethod void testEmptyFile(){
        Id profileID = (Id) ConstantsSLB.getKeyId('Profile_Standard User');
        System.debug('>>>>>>>>>>>>>>' + profileID);
        User testUserCFUCT = new User(
            Alias = 'stndrd',
            Email='standarduser@test.com', 
            EmailEncodingKey='UTF-8',
            LastName='Test',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = (Id) ConstantsSLB.getKeyId('Profile_Standard User'), 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard@test.com'
        );   
        //The test will run as the user created.
        System.runAs(testUserCFUCT) {
         Document doc = new Document();
             doc.name = 'jasas87232';
                    String file = ' ';
             doc.body = (true) ? Blob.valueOf(file) : null;
             doc.AuthorId = UserInfo.getUserId(); 
             doc.FolderId = UserInfo.getUserId();
             insert doc;
             
             System.assertEquals ('jasas87232', doc.name);             
             Document test_doc = [Select Id from Document where Name =: doc.name];
               
             CsvFileUploadController cfuc = new CsvFileUploadController();
             PageReference pRef = new Pagereference('/apex/CsvFileUploadPage?Id=' + test_doc.Id);
             Test.setCurrentPage(pRef);
             
             ApexPages.currentPage().getParameters().put('id', test_doc.Id);
             cfuc.upload();
             cfuc.parseCsv();   
             cfuc.cancel(); 
    }
    
   } 
}