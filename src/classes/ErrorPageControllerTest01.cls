/**
* Class Name: ErrorPageController
* @author: Joyrem Zarmaine D. Ayuman
* Date: <7/13/2015>
* Requirement/Project Name: <SPH Project>
* @description<Test Class for ErrorPageController>
*/
  
@isTest (SeeAlldata = true)

public class ErrorPageControllerTest01{
    
    
        static testMethod void testErrorPageController() { // <-- This is the Original Test Method Signature
       
            //User cso = TestDataFactory.prepareTestUsers();
        
           // System.runAs(cso) 
           /* Account acc = new Account(
                Name = 'Test Account',
                RecordTypeId = ConstantsSLB.getKeyId('Account_Vendor'),
                Email__c = 'sample@email.com',
                Mobile__c = '1234567'
            );
            insert acc;*/
             try {
                Test.setMock(WebServiceMock.class, new zLoginMock());
                
            Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            //Singpost_Address__c postal = TestDataFactory.createSingpostAddress(1)[0];
            postal.Name = 'SPostal';
            postal.House_Block_Number__c = 'TEST';
            postal.Address_Type__c = 'A';
            insert postal;
            
            Address__c addressRec = TestDataFactory.createAddress(1)[0];
            addressRec.Address_Type__c='P';
            addressRec.Postal_Code__c = postal.Id;
            insert addressRec;
            
            
            Account acc = TestDataFactory.createAccount(1, 'Vendor Subscriber')[0];
            acc.NRIC__c = 'T1234567R';
            insert acc;
            
        
            Contact con = TestDataFactory.createContact(1)[0];
            con.Address__c = addressRec.Id;
            con.AccountId = acc.Id;
            
             Case cas = TestDataFactory.createCase(1, 'Complaint - Magazine')[0];
             //cas.Order__c = order.Id;
             insert cas;
       
            
            Test.startTest();
            
            // Initialization of VisualForce Page
            PageReference pRef = Page.ErrorPage;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('id', cas.Id);
            ApexPages.currentPage().getParameters().put('msg', 'Error');
            //ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Case());
            
            // BaseClass
            ErrorPageController controller = new ErrorPageController();
            //controller.back();
            PageReference backPage = controller.back();
            System.assert(backPage.getUrl().contains('/' + cas.Id ));
            Test.stopTest();
      }
          catch(Zuora.zRemoteException e) {
          }  
                  
    
  }  
   }