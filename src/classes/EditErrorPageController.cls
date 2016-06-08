/**
* Class Name: EditErrorPageController
* @author: Jerella Ledesma
* Date: 5/6/2015
* Requirement/Project Name: <SPH>
* @description Controller for ErrorPage (Temp Stop Edit)
*/
public with sharing class EditErrorPageController {
    
    public EditErrorPageController(ApexPages.StandardController controller) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Message: ' + ConstantsSLB.getErrorMessage('Temp Stop Edit Error')));
    }
    
    

}