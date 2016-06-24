public class ContactNewOverrideController {
    /**
     * Class Name: ContactNewOverrideController
     * @author: Marjorie Gaelo
     * Date: 
     * Requirement/Project Name: CRSM Project
     * @description Controller for ContactNewOverride VF page
     * 
     */
//START: CCB002 Added by April Banaag - to apply changes to contact record type
    Id selectedRTypeId;
    //Id billingContact;
    //Id recipientContact;
    Id accountId;
    Id customerContact;
//END: CCB002 Added by April Banaag - to apply changes to contact record type
    public ContactNewOverrideController(ApexPages.StandardController controller) {
        accountId = ApexPages.currentPage().getParameters().get('accid');
        selectedRTypeId = ApexPages.currentPage().getParameters().get('RecordType');
//START: CCB002 Added by April Banaag - to apply changes to contact record type
        //recipientContact = ConstantsSLB.getKeyId('Contact_Recipient Contact');
        //billingContact = ConstantsSLB.getKeyId('Contact_Billing Contact');
        customerContact = ConstantsSLB.getKeyId('Contact_Customer Contact');
//END: CCB002 Added by April Banaag - to apply changes to contact record type
        
    }
    
    public PageReference redirect() {
    //START: CCB002 Added by April Banaag - to apply changes to contact record type
        /*if(selectedRTypeId == billingContact || selectedRTypeId == recipientContact) {
            return new PageReference('/apex/CreateModifyContactAddress?accountId=' + accountId +'&RecordType=' + selectedRTypeId);
        }*/
        if(selectedRTypeId == customerContact) {
    //END: CCB002 Added by April Banaag - to apply changes to contact record type    
            return new PageReference('/apex/CreateModifyContactAddress?accountId=' + accountId +'&RecordType=' + selectedRTypeId);
        }
        else {
            return new pageReference('/003/e?nooverride=1&RecordType=' + selectedRTypeId + '&retURL=/003/o');
        }
    }
    

}