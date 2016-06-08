public class EmailToCaseHelper {

    public static void populateFields(list<Case> newCaseList) {
        
        map<string, Contact> emailAddress_contact = new map<string, Contact>();
        set<string> emailAddressSet = new set<string>();
        Contact kontak;
        
        for (Case c : newCaseList) {
            
            if (c.RecordTypeId == ConstantsSLB.getKeyId('Case_Enquiry') && c.SuppliedEmail != null) {
                emailAddressSet.add(c.SuppliedEmail);
            }
        }
        
        emailAddressSet.remove(null);
        
        for (Contact con : [select Id, AccountId, Email, Email_Secondary__c from Contact 
                where Email in :emailAddressSet or Email_Secondary__c in :emailAddressSet]) {
            
            if (con.Email != null) {
                emailAddress_contact.put(con.Email, con);
            } else if (con.Email_Secondary__c != null) {
                emailAddress_contact.put(con.Email_Secondary__c, con);
            }
        }
        
        for (Case c : newCaseList) {
            
            if (c.RecordTypeId == ConstantsSLB.getKeyId('Case_Enquiry') && c.SuppliedEmail != null) {
                
                kontak = emailAddress_contact.get(c.SuppliedEmail);
                
                if (kontak != null) {
                    c.ContactId = kontak.Id;
                    c.AccountId = kontak.AccountId;
                }
            }
        }
    }
}