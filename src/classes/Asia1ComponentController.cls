public virtual with sharing class Asia1ComponentController {

    public string accountId;
    public Asia1__c asia1SingleAccount { get; set; } 
    public list<Asia1Wrapper> asia1Subscriptions { get; set; }
    public Asia1_Subscription__c asia1SingleSubscription { get; set; }
    public transient string selectedAsia1Creation { get; set; }
    public transient string asia1SelectedExistingId { get; set; }
    public transient string asia1IdToBeRemoved { get; set; }
    public transient string selectedPackageId { get; set; }
    public transient boolean isCreateNew { get; set; }
    public string ldapValidityImg { get; set; }
    public string displayNameValidityImg { get; set; }
    
 
    public Asia1ComponentController() {
        isCreateNew = true;
        this.asia1Subscriptions = new list<Asia1Wrapper>();
        asia1SingleAccount = new Asia1__c();
        ldapValidityImg = '/s.gif';
        displayNameValidityImg = '/s.gif';
    }
   
    public class Asia1Wrapper  {
        public string userId { get; set; }
        public string asia1Id { get; set; }
        public list<Asia1SubscriptionWrapper> asia1Subscriptions { get; set; } 
    }
    
    
    public class Asia1SubscriptionWrapper {
        public string serviceFlagId { get; set; }
        public string serviceFlagName { get; set; }
        public string status { get; set; }
        public integer concurrent { get; set; }
    }
    
    
    public void addAsia1Account() {
        system.assert(false);
//        asia1Accounts.add(asia1SingleAccount);
        asia1SingleAccount = new Asia1__c();
    }
    
    
    public void addAsia1ExistingAccount() {
        //asia1SelectedExistingId = 'a0AN0000002ZQYm';
        Asia1__c tmpAsia1 = [select Id, User_ID_LDAP_ID__c from Asia1__c where Id = :asia1SelectedExistingId];

        Asia1Wrapper newAsia1Subscription = new Asia1Wrapper();
        newAsia1Subscription.userId = tmpAsia1.User_ID_LDAP_ID__c;
        newAsia1Subscription.asia1Id = tmpAsia1.Id;
        
        list<Asia1SubscriptionWrapper> tmpAsia1Subscriptions = new list<Asia1SubscriptionWrapper>();
        
        for (Package_Access_Flag__c paf : retrieveServiceFlags(selectedPackageId)) {
            
            Asia1SubscriptionWrapper tmpAsia1Sub = new Asia1SubscriptionWrapper();
            
            tmpAsia1Sub.status = 'Enabled';
            tmpAsia1Sub.serviceFlagId = paf.Package_Service_Access_Flag__c;
            tmpAsia1Sub.serviceFlagName = paf.Package_Service_Access_Flag__r.Name;
            
            if (paf.No_of_Concurrent_Users__c != null) {
                tmpAsia1Sub.concurrent = integer.valueOf(paf.No_of_Concurrent_Users__c);
            }
            
            tmpAsia1Subscriptions.add(tmpAsia1Sub);
        }
        
        newAsia1Subscription.asia1Subscriptions = tmpAsia1Subscriptions;
        
        asia1Subscriptions.add(newAsia1Subscription);
        
    }
    

    public void validateNewAsia1Account() {
        
        
        // check require fields
        if (asia1SingleAccount.User_ID_LDAP_ID__c != null && asia1SingleAccount.Display_Name__c != null) {
            
            // call to asia1 stub only
            if (asia1SingleAccount.User_ID_LDAP_ID__c == 'ldaptest') {
                ldapValidityImg = '/resource/check';
            } else {
                ldapValidityImg = '/resource/wrong';
            }
            
            if (asia1SingleAccount.Display_Name__c == 'dislaynametest') {
                displayNameValidityImg = '/resource/check';
            } else {
                displayNameValidityImg = '/resource/wrong';
            }
            // end call to asia1 stub only
            
            // call to asia1 actual
            
            // end call to asia1 actual
            
            
        } else {
            
            ldapValidityImg = '/s.gif';
            displayNameValidityImg = '/s.gif';
            
            if (asia1SingleAccount.User_ID_LDAP_ID__c == null) {
                asia1SingleAccount.User_ID_LDAP_ID__c.addError('Required Field.');
            }
            
            if (asia1SingleAccount.Display_Name__c == null) {
                asia1SingleAccount.Display_Name__c.addError('Requireed Field.');
            }
            
        }
        
        
        
        /*
        if (asia1SingleAccount.Password__c == null) {
            asia1SingleAccount.Password__c.addError('Required Field.');
        }
        
        if (asia1SingleAccount.Email__c == null) {
            asia1SingleAccount.Email__c.addError('Required Field.');
        }
        */
        // end check require fields
    }
    
    
    public void removeAsia1Subscription() {
        
        integer i = 0;
        
        for (i = 0; i < asia1Subscriptions.size(); i++) {   
            if (asia1Subscriptions.get(i).asia1Id == asia1IdToBeRemoved) {
                asia1Subscriptions.remove(i);
            }
        }
    }
    
    
    public list<Package_Access_Flag__c> retrieveServiceFlags(id pkgId) {
        
        return [select Package_Service_Access_Flag__c, Package_Service_Access_Flag__r.Name, 
                No_of_Concurrent_Users__c from Package_Access_Flag__c where Package__c = :pkgId];
        
    }
    
    
    public list<SelectOption> getAsia1ExistingAccounts() {
        
        
        
        set<id> tmpAsia1Ids = new set<id>();
        for (Asia1Wrapper tmpw : asia1Subscriptions) {
            tmpAsia1Ids.add(tmpw.asia1Id);
        }
        
        list<SelectOption> options = new list<SelectOption>();
        
        
        for (Asia1__c asia1 : [select Id, User_ID_LDAP_ID__c from Asia1__c where Contact__r.Account.Id = :accountId  and Id not in :tmpAsia1Ids]) {
            options.add(new SelectOption(asia1.Id, asia1.User_ID_LDAP_ID__c));
        }
        
        return options;
    }
}