global with sharing class BT_INT_UTILITY {

	global static String createSimpleQuery(String interfaceName, String whereClause){
		String queryString0 = 'select field_name__c, from_object__c from bt_int_param_config__c where interface_name__c = :interfaceName order by field_sequence__C';
		List<bt_int_param_config__c> fieldList = Database.query(queryString0);
		
		String batchQueryString = 'Select ';
		String fromObject = '';
		
		for(bt_int_param_config__c temp : fieldList){
			if(fromObject != ''){
				batchQueryString += ' ,' + temp.field_name__c;
			}else{
				batchQueryString += temp.field_name__c;
			}
			fromObject = temp.from_object__c;
		}
		
		batchQueryString += ' from ' + fromObject;
		
		if(whereClause != ''){
			batchQueryString += ' where '+ whereClause;
		}
		
		System.debug('##############' + batchQueryString);
		return batchQueryString;
	}
	
	global static List<String> getQueryFields(String interfaceName){
		String queryString0 = 'select postOpFieldName__c from bt_int_param_config__c where interface_name__c = :interfaceName order by field_sequence__C';
		List<bt_int_param_config__c> fieldList = Database.query(queryString0);
		List<String> returnList = new List<String>();
		
		for(bt_int_param_config__c temp : fieldList){
			returnList.add(temp.postOpFieldName__c);
		}
		
		System.debug('fieldList size : ' + returnList.size());
		System.debug(returnList);
		
		return returnList;
	}
}