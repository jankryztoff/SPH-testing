public class AddressValidator {
	
	// Start D-4801 23Jun16 JohnD - local address pre-validation
	public static map<string, boolean> validate(list<Address__c> addressListParam) {
		
		map<string, boolean> identifier_isExist = new map<string, boolean>();
		string identifier;
		
		for (Address__c address : addressListParam) {
			
			identifier = generateIdentifier(address);
			identifier_isExist.put(identifier, false);
		}
		
		for (Address_Details__c addressDetail : [select Identifier__c from Address_Details__c 
				where Identifier__c in :identifier_isExist.keySet()]) {
			
			identifier_isExist.put(addressDetail.Identifier__c, true);
		}
		
		return identifier_isExist;
	}
	
	
	public static boolean validate(Address__c addressParam) {
		
		boolean isExist = false;
		string identifier = generateIdentifier(addressParam);
		
		for (Address_Details__c addressDetails : [select Id from Address_Details__c 
				where Identifier__c = :identifier]) {
					
			isExist = true;
			break;
		}
		
		return isExist;
	}
	
	
	public static map<string, boolean> validate(set<string> identifierSetParam) {
		
		map<string, boolean> identifier_isExist = new map<string, boolean>();
		
		for (string identifier : identifierSetParam) {
			identifier_isExist.put(identifier, false);
		}
		
		for (Address_Details__c addressDetail : [select Identifier__c from Address_Details__c 
				where Identifier__c in :identifierSetParam]) {
			
			identifier_isExist.put(addressDetail.Identifier__c, true);
		}
		
		return identifier_isExist;
	}
	
	
	public static string generateIdentifier(Address__c addressParam) {
		return generateIdentifier(addressParam.Postal_Code__c, addressParam.Level_Number__c, addressParam.Unit_Number__c);	
	}
	
	public static string generateIdentifier(string singPostIdParam, string levelNumberParam, string unitNumberParam) {

		final string DELIMITER = ';';
		string identifier;
		string postalCode = '';
		string levelNumber = '';
		string unitNumber = '';
			
		if (singPostIdParam != null) {
			postalCode = string.valueOf(singPostIdParam).subString(0,15);
		}
		
		if (levelNumberParam != null) {
			levelNumber = levelNumberParam;
		}
		
		if (unitNumberParam != null) {
			unitNumber = unitNumberParam;
		}
		
		identifier = postalCode + DELIMITER + levelNumber + DELIMITER + unitNumber;
		
		return identifier;	
	}
	// End D-4801 23Jun16 JohnD - local address pre-validation
}