public class ZuoraAmendmentHelper {

	/*
	*	@description: this method will delete the amendment made to zuora
	*	@param : set of order id
	*/
	public static void deleteAmendment(set<id> orderIdSet) {
		
    	integer amendmentCounter = 0;
    	list<string> zuoraAmendmentIdList = new list<string>();
    	
    	for (Zoura_Amendment__c za : [select Amendment_Id__c from Zoura_Amendment__c where Order__c in :orderIdSet]) {
    		
    		if (za.Amendment_Id__c != null) {
    			zuoraAmendmentIdList.add(za.Amendment_Id__c);
    		}
    	}
    	
    	if (zuoraAmendmentIdList.size() > 0) {
			
			Zuora.zapi zApiInstance = new Zuora.zapi();
			//START D-3268 Modified By C.I.Salas - Test Coverage
			if (!Test.isRunningTest()) {
				zApiInstance.zlogin();
			}
			//END D-3268 Modified By C.I.Salas - Test Coverage
    		
    		list<Zuora.zApi.DeleteResult> deleteResults = zApiInstance.zdelete('Amendment',zuoraAmendmentIdList);
    	}
	}
	
	
	/*
	*	@description: this method will delete the amendment made to zuora
	*	@param : list of zuora amendment ids
	*/
	public static void deleteAmendment(list<string> zuoraAmendmentIdList) {
		
    	if (zuoraAmendmentIdList != null && zuoraAmendmentIdList.size() > 0) {
			
			Zuora.zapi zApiInstance = new Zuora.zapi();
			//START D-3268 Modified By C.I.Salas - Test Coverage
			if (!Test.isRunningTest()) {
				zApiInstance.zlogin();
			}
			//END D-3268 Modified By C.I.Salas - Test Coverage
    		
    		list<Zuora.zApi.DeleteResult> deleteResults = zApiInstance.zdelete('Amendment',zuoraAmendmentIdList);
    	}
	}
	
	
}