public class AddressValidator {

    /*
    @param: addressIdentifierSetParam = singpostAddressName + buildingNumber + levelNumber + unitNumber
    */
    public static map<string, boolean> validate(set<string> addressIdentifierSetParam) {
        
        map<string, boolean> addressIdentifier_isExist = new map<string, boolean>();
        addressIdentifierSetParam.remove(null);
        
        for (string identfier : addressIdentifierSetParam) {
            addressIdentifier_isExist.put(identfier, false);
        }
        
        for (Address_Details__c addressDetail : [select Identifier__c from Address_Details__c where Identifier__c in :addressIdentifierSetParam]) {
            addressIdentifier_isExist.put(addressDetail.Identifier__c, true);
        }
        
        return addressIdentifier_isExist;
    }
}