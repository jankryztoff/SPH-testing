public class AccountEditOverrideController {
    /** 
     * Class Name: AccountEditOverrideController
     * @author: Marjorie Gaelo
     * Date: 
     * Requirement/Project Name: CRSM Project
     * @description Controller for AccountEditOverride VF page
     * 
     */
    Account thisAccount;
    //PageReference pageRef = ApexPages.getUrl();
    String baseUrl;
    
    public AccountEditOverrideController(ApexPages.StandardController controller) {
        Id recordId = controller.getId();
        baseUrl = System.Url.getSalesforceBaseUrl().toExternalForm();
        //START: Code Review Implementation 2/12/2015 KLorica
        if (recordId != NULL) {
        //END: Code Review Implementation 2/12/2015 KLorica
            try {
                thisAccount = [Select Id, RecordTypeId, RecordType.Name FROM Account WHERE Id = :recordId];
            }
            catch(QueryException e) {
                thisAccount = new Account();
                Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            }
        //START: Code Review Implementation 2/12/2015 KLorica for testing only jcalma
        }
        //END: Code Review Implementation 2/12/2015 KLorica
    }
    
    public PageReference redirect() {
        //START: Code Review Implementation 2/12/2015 KLorica
        PageReference pgRef;
        //END: Code Review Implementation 2/12/2015 KLorica
        
        if(thisAccount.Id != null) {
            if(thisAccount.RecordType.Name == 'Vendor' || thisAccount.RecordType.Name == 'Mailing Agent') {
                
                return new PageReference ('/' + thisAccount.Id + '/e?nooverride=1&retURL=' + '/' + thisAccount.Id);
            }
            else {
                System.Debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + thisAccount.Id);
                //System.Debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@' + pageRef);
                //return new PageReference ('https://c.cs6.visual.force.com/apex/AccountEditPage?id=' + thisAccount.Id + '&retURL=' + '/' + thisAccount.Id);
                //START D-3562 09/15/2015 Added by J.Sarion - page redirect to AccountEditPage
                pgRef = new PageReference ('/apex/AccountEditPage?id=' + thisAccount.Id + '&retURL=' + '/' + thisAccount.Id); //original
                pgRef.setRedirect(true);
                return pgRef;
                //return new PageReference(baseUrl + '/apex/AccountEditPage?id=' + thisAccount.Id + '&retURL=' + '/' + thisAccount.Id);
                //END D-3562 09/15/2015 Added by J.Sarion - page redirect to AccountEditPage
            }
        }
        else {
            //return null;
            return pgRef;
        } 
    }
}