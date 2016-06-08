@isTest(seeAllData = true)	// enable seealldata for it zuora objects
private class ResponseUtilityTest {

    static testMethod void myUnitTest() {
        
        ResponseUtility resUtil = new ResponseUtility();
        string query = 'SELECT AccountId, Balance, Id, Amount FROM Invoice';
        ResponseUtility.zuoraAccountId = ResponseUtility.generateExternalId();
        system.assertEquals(ResponseUtility.zuoraAccountId.length(), 18);
		
		for (Zuora.zApi.SaveResult result : resUtil.getZuoraPositiveResults()) {
			system.assert(result.Success);
		}
				
		ResponseUtility.usedNegativeResponse = true;
		for (Zuora.zApi.SaveResult result : resUtil.getZuoraPositiveResults()) {
			system.assert(!result.Success);
		}

 		Zuora.zApi.AmendResult result = resUtil.getZuoraPositiveAmendResults();
		system.assert(result.Success);
 
 		for (Zuora.zObject zObject : resUtil.getMockZObjectResponse(query)) {
 			system.assertEquals(decimal.valueOf(string.valueOf(zObject.getValue('Balance'))), 10);
 		}
 
        Zuora.zApi.QueryResult qryRes1 = resUtil.getMockQueryResultPositive(query, true);
        system.assert(qryRes1.done);
        
        Zuora.zApi.QueryResult qryRes2 = resUtil.getMockQueryMoreResultPositive(query, true);
        system.assert(qryRes2.done);
        
        resUtil.getMockLoginResult(); 
        
        
    }
}