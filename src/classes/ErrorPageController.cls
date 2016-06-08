/**
* Class Name: ErrorPageController
* @author: Charles Lin
* Date: 04/29/2015
* Requirement/Project Name: <SPH>
* @description Controller for ErrorPage
*/

public class ErrorPageController {
    String errorMsg = ApexPages.currentPage().getParameters().get('msg');
    Id caseId = ApexPages.currentPage().getParameters().get('id');
    
    public ErrorPageController() {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Message: ' + ConstantsSLB.getErrorMessage(errorMsg)));
    }
    
    public PageReference back(){
        PageReference pageRef = new PageReference('/' + caseId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}