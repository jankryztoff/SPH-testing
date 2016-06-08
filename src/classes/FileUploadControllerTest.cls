@isTest
public class FileUploadControllerTest{

    public static testMethod void uploadFile(){
        PageReference pageRef = new PageReference('/apex/FileUpload/');
        Test.setCurrentPage(pageRef);
        FileUploadController fuc = new FileUploadController();

        
        String c = 'Test Document';
        Blob b= blob.valueOf(c);
        fuc.document.body = b;
        fuc.document.name='Test.txt';
        fuc.document.description='Test Description';
        
        fuc.Upload();
        ApexPages.Message msg = ApexPages.getMessages().get(0);
        System.assertEquals(ApexPages.Severity.INFO, msg.getSeverity());
    }
    
    public static testMethod void uploadEmptyFile(){
        PageReference pageRef = new PageReference('/apex/FileUpload/');
        Test.setCurrentPage(pageRef);
        FileUploadController fuc = new FileUploadController();

        
       
        fuc.Upload();
        ApexPages.Message msg = ApexPages.getMessages().get(0);
        System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
    }

    
}