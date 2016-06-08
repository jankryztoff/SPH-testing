/**
* Class Name: EditErrorPageController
* @author: Joyrem Zarmaine D. Ayuman
* Date: <7/13/2015>
* Requirement/Project Name: <SPH Project>
* @description<Test Class for EditErrorPageController>
*/
  
@isTest (SeeAlldata = true)

public class EditErrorPageControllerTest{
    
    
        static testMethod void testEditErrorPageController() { 
        
        
         Test.startTest();
         PageReference pRef = Page.ErrorPage;
            Test.setCurrentPage(pRef);
            //ApexPages.currentPage().getParameters().put('id', cas.Id);
            //ApexPages.currentPage().getParameters().put('msg', 'Error');
            ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(new Account());
            
            // BaseClass
            EditErrorPageController controller = new EditErrorPageController(stdCtrlr);
            //controller.back();
            //PageReference backPage = controller.back();
            //System.assert(backPage.getUrl().contains('/' + cas.Id ));
            Test.stopTest();
            
            }
            
      }