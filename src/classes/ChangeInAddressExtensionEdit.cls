/* History: [C. Lin 1/15/2014 Implement new process for COA]
*/
public class ChangeInAddressExtensionEdit{
	public Case changeInAddress {get; set;}
	//Contact getContact = new Contact();
	Id rectype;
	String pageRef;

	//START: D-0974 1/15/2015 Added By C. Lin - Implement new process for COA
    public SubscriptionWrapper subscriptionWrapper {get; set;}
    public List<SubscriptionWrapper> subWrapperList {get; set;}
    List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
    List<Address_Assignment__c> addressAssignmentList = new List<Address_Assignment__c>();
    List<Vendor_Allocation__c> vendorAllocationList = new List<Vendor_Allocation__c>();
    public Boolean showSubTable {get; set;}
    Set<Id> subsId = new Set<Id>();
    //END: D-0974 1/15/2015 Added By C. Lin
	//START D-2954 5/19/2015 Added By C. Lin - CCB COA
    Set<Id> vendorIdSet = new Set<Id>();
    public Date popStartDate {get; set;}
    //END D-2954 5/19/2015 Added By C. Lin
	
	public ChangeInAddressExtensionEdit(ApexPages.StandardController controller) {
		//rectype = (Id) ApexPages.currentPage().getParameters().get('RecordType');
		rectype = (Id) ApexPages.currentPage().getParameters().get(GlobalVariableClass.PARAMETER_RECORDTYPE);
		this.changeInAddress = (Case) controller.getRecord();
		if(rectype != null) {
			changeInAddress.RecordTypeId = recType;
		}
        //START D-0974 1/15/2015 Added By C. Lin - Implement new process for COA
        //getSubscriptions();
        //END D-0974 1/15/2015 Added By C. Lin
		
		//START D-2954 5/19/2015 Added By C. Lin - CCB COA
        Case caseList = [SELECT Id, POP_Start_Date__c FROM Case WHERE Id = : changeInAddress.Id LIMIT 1];
        popStartDate = caseList.POP_Start_Date__c;
        
        if(changeInAddress.New_Address__c != null){
            Address__c address = [SELECT Id, Postal_Code__c FROM Address__c WHERE Id = :changeInAddress.New_Address__c];
            
            if (address.Postal_Code__c != null) {
                for (Vendor_Allocation__c venAlloc : [SELECT Id, SingPost_Address__c, Vendor_Account__c FROM Vendor_Allocation__c WHERE SingPost_Address__c = :address.Postal_Code__c AND Status__c = 'active'])
                {
                    if (venAlloc.Vendor_Account__c != null){
                        vendorIdSet.add(venAlloc.Vendor_Account__c);
                    }
                }
            }
        }
        //END D-2954 5/19/2015 Added By C. Lin
	}

	public PageReference save(){
        //START: D-0974 1/15/2015 Added By C. Lin - Implement new process for COA
        PageReference pageRef;
            /*upsert changeInAddress;
            
            if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC  && changeInAddress.Selected_Subscriptions_Only__c == true)
            {
                string cCaseId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.PARAMETER_ID); 
                pageRef = new pageReference(GlobalVariableClass.PAGEREFERENCE_CASEASSIGN + GlobalVariableClass.PARAMETER_ID + '=' + cCaseId);
            }
            else
            {
                pageRef = new pageReference(GlobalVariableClass.PAGEREFERENCE_CHANGEADDRESS + GlobalVariableClass.PARAMETER_CASEID + '=' + changeInAddress.Id + '&' + GlobalVariableClass.PARAMETER_ID + '=' + changeInAddress.ContactId);
            }*/
        //START D-0974 1/21/2015 Added By J. Sarion - Changed error messages to follow standards and validations for new COA.
        if(changeInAddress.Effective_Date__c == NULL ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Effective Date must not be null'));
            return null;
        }
		//START D-2954 5/18/2015 Added By C. Lin - CCB COA
        else if(changeInAddress.Contact_To_Update__c == null && changeInAddress.Change_of_Address_Type__c != GlobalVariableClass.DELIVERYADDOVSEA){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage(GlobalVariableClass.BLANKCONTACTTOUPDATE)));
            return null;
        }
		//END D-2954 5/18/2015 Added By C. Lin
        else if(changeInAddress.Vendor__c == null && (changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.CHANGEVENDOR)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage(GlobalVariableClass.BLANKVENDOR)));
            return null;
        }       
        else if(changeInAddress.New_Address__c == null && (changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLINGADD || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOCOVSEA || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDOVSEALOC)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage(GlobalVariableClass.BLANKNEWADDRESS)));
            return null;
        }
        else {
            try {
				//START D-2954 5/19/2015 Added By C. Lin - CCB COA
				if(changeInAddress.Effective_Date__c >= popStartDate){
                    if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC){
                        if(vendorIdSet.size() > 1 || vendorIdSet.size() == 0){
                            changeInAddress.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
                        }else if(vendorIdSet.size() == 1){
                            changeInAddress.Status = GlobalVariableClass.STATUS_CLOSED;
                        }
                    }else{
                        changeInAddress.Status = GlobalVariableClass.STATUS_CLOSED;
                    }
                }
                //END D-2954 5/19/2015 Added By C. Lin
                upsert changeInAddress;
                updateAssignment();
                pageRef = new pageReference('/' + changeInAddress.Id);

            } catch (exception e) {
                ApexPages.addMessages(e);
                return null;
            }
        }
        //END D-0974 1/21/2015 Added By J. Sarion
        
        pageRef.setRedirect(true);
        return pageRef;
        //END: D-0974 1/15/2015 Added By C. Lin
    }
    
    //START: D-0974 1/15/2015 Added By C. Lin - Implement new process for COA
    // ------------  Subscription Wrapper  ------------ //
    public class SubscriptionWrapper{
        public Boolean selectSub {get; set;}
        public String subName {get; set;}
        public Id subId {get; set;}
        public String contactName {get; set;}
        public String vendorName {get; set;}
        public String status {get; set;}
    }
    
    public void updateAssignment() {    
		//START D-2954 5/18/2015 Added By C. Lin - CCB COA
        if (changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLINGADD || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOCOVSEA || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDOVSEALOC) {
		//END D-2954 5/18/2015 Added By C. Lin;
            List<Address_Assignment__c> addAssignmentList = new List<Address_Assignment__c>();
            addAssignmentList = [SELECT Id, Name, Case__c, Address__c, Contact__c, Effective_Date__c FROM Address_Assignment__c WHERE Case__c = :changeInAddress.Id];
            
            for(Address_Assignment__c addAssign : addAssignmentList){
                addAssign.Address__c = changeInAddress.New_Address__c;
                addAssign.Contact__c = changeInAddress.Contact_To_Update__c;
                addAssign.Effective_Date__c = changeInAddress.Effective_Date__c;
				
				//START D-2954 5/19/2015 Added By C. Lin - CCB COA
				if(vendorIdSet.size() == 1){
                    for(Id ven : vendorIdSet){
                        addAssign.Vendor__c = ven;
                    }
                }
                //END D-2954 5/19/2015 Added By C. Lin
            }
            update addAssignmentList;
        }
		//START D-0974 1/21/2015 Added By J. Sarion - Changed error messages to follow standards and validations for new COA.
		//START D-2954 5/18/2015 Added By C. Lin - CCB COA
        else if (changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC) {
		//END D-2954 5/18/2015 Added By C. Lin
            List<Address_Assignment__c> addAssignmentSubList = new List<Address_Assignment__c>();
            addAssignmentSubList = [SELECT Id, Name, Case__c, Address__c, Contact__c, Effective_Date__c FROM Address_Assignment__c WHERE Case__c = :changeInAddress.Id AND Subscription__c != NULL];
            
            for(Address_Assignment__c addAssignSub : addAssignmentSubList){
                addAssignSub.Address__c = changeInAddress.New_Address__c;
                addAssignSub.Contact__c = changeInAddress.Contact_To_Update__c;
                addAssignSub.Effective_Date__c = changeInAddress.Effective_Date__c;
				
				//START D-2954 5/19/2015 Added By C. Lin - CCB COA
				if(vendorIdSet.size() == 1){
                    for(Id ven : vendorIdSet){
                        addAssignSub.Vendor__c = ven;
                    }
                }
                //END D-2954 5/19/2015 Added By C. Lin
            }
            update addAssignmentSubList;
        }
		//END D-0974 1/21/2015 Added By J. Sarion
    }
	//END D-0974 1/15/2015 Added By C. Lin
}