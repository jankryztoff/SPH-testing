public with sharing class ApprovalProcessSubmitter {

	public static void submit(id recordId) {
		
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setComments('Submitting request for approval.');
        request.setObjectId(recordId);
        
        try {
        	Approval.ProcessResult result = Approval.process(request);
        } catch (exception e) {
        	ExceptionLogger.log(new list<exception> { e });
        }      
	}
}