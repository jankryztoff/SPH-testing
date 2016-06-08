public class ChangeInAddressController {
     
    public Contact changeInAddress {get; set;} 
    Id rectype;

    public ChangeInAddressController(ApexPages.StandardController controller) {
        this.changeInAddress = (Contact)controller.getRecord(); 
        rectype = (Id) ApexPages.currentPage().getParameters().get('RecordType');
        if(rectype != null) {
            changeInAddress.RecordTypeId = recType;
        }

    }
    
        
    public PageReference saveandnew(){
        PageReference pageRef = new pageReference('/apex/ContactEditPage_ForAllSubscription?caseId=' + changeInAddress.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }

}