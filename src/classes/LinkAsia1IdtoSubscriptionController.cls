/**
 * Class Name: LinkAsia1IdtoSubscriptionController
 * @author: Christopher Camilon   
 * Date: 06/23/2016
 * Requirement/Project Name: SPH Project
 * @description : this class is use as a controller for linking of Asia1 Ids to Subscriptions
 */
 public class LinkAsia1IdtoSubscriptionController extends SM_SubscriptionHelper {
    public class subwrapper{
        public Zuora__Subscription__c sub {get; set;}
        public Boolean selected {get; set;}
        public subwrapper(Zuora__Subscription__c zsub){
            sub  = zsub;
            selected = false;
        }
    }
   
    public String items { get; set; }

  

    @testVisible private boolean isAsia1Validated = false;
    List<Asia1__c> asia1IdList = new List<Asia1__c>();
    final static string ERR_CREATION = 'Error Creation';
    public Id  contactId  { get; set; }
    public string existing { get; set; }
    public string createnew { get; set; }
    public boolean asia1layoutshow{ get; set; }
    public transient string asia1SelectedExistingId { get; set; }
    public Asia1__c asia1SingleAccount { get; set; }
    public string displayNameValidityImg { get; set; }  
    public string ldapValidityImg { get; set; } 
    public string userselected { get; set; } 
    
    public LinkAsia1IdtoSubscriptionController (){
    
        asia1SingleAccount = new Asia1__c();
        ldapValidityImg = '/s.gif';
        displayNameValidityImg = '/s.gif';
        contactId = ApexPages.currentPage().getParameters().get('contactId');
        asia1IdList = [Select Id, Name, User_ID_LDAP_ID__c, Password__c, Status__c, Contact__c From Asia1__c Where Contact__c =: contactId AND Status__c !=: ERR_CREATION];
        if(asia1IdList.size() > 0){
            createnew = '';
            existing = 'checked';
            asia1layoutshow = true;
        }else{
            existing = '';
            createnew = 'checked';
            asia1layoutshow = false;
            
        }

    }
    public list<SelectOption> getAsia1ExistingAccounts() {
        
        /*set<id> tmpAsia1Ids = new set<id>();
        for (Asia1Wrapper tmpw : asia1Subscriptions) {
            tmpAsia1Ids.add(tmpw.asia1Id);
        }*/
        
        list<SelectOption> options = new list<SelectOption>();
        
        //START UD-3454 01/06/15 RReyes - added condition if Asia1 is not Disabled
        String disabled = GlobalVariableClass.ASIA1_SUBSCRIPTION_STATUS_DISABLED;
        for (Asia1__c asia1 : [select Id, User_ID_LDAP_ID__c from Asia1__c where Contact__c = :contactId  and status__c!=:ERR_CREATION]) {
            options.add(new SelectOption(asia1.Id, asia1.User_ID_LDAP_ID__c));
        }
        //END UD-3454 01/06/15 RReyes - added condition if Asia1 is not Disabled
        return options;
    }
    
    public void addAsia1NewAccount(){
        
            isAsia1Validated = false;
         
            validateNewAsia1Account();
            system.debug('>>>>>isAsia1Validated ' + isAsia1Validated);
            system.debug('>>>>>asia1SingleAccount.Password__c ' + asia1SingleAccount.Password__c);
            if (isAsia1Validated == true && asia1SingleAccount.Password__c != null && asia1SingleAccount.Password__c != '') {
                
                asia1SingleAccount.id = null;
                asia1SingleAccount.Status__c = 'Created';
                asia1SingleAccount.Contact__c = contactId;
        
                //asia1SingleAccount.Order_Number__c = thisOrder.name;
                /*
                try {
                
                    insert asia1SingleAccount;
                    
                    for (Asia1Wrapper asia1wrapper : createAsia1SubscriptionFromAccessFlag(asia1SingleAccount.User_ID_LDAP_ID__c, asia1SingleAccount.Id, packageIdpromotionId[0])){
                        asia1Subscriptions.add(asia1wrapper);
                    }
                    asia1SubscriptionsTotal = asia1Subscriptions.size();
                   
                    asia1SingleAccount = new Asia1__c();
                   
            
                    ldapValidityImg = '/s.gif';
                    displayNameValidityImg = '/s.gif';
                } catch (exception e) {
                    if(userInfo.getLastName() == 'Balaoing'){
                        System.assertEquals(null, e);
                    }
                    ApexPages.addMessages(e);
                }*/
            }
            else if(asia1SingleAccount.Password__c == null || asia1SingleAccount.Password__c == '') {
                ApexPages.addMessage(new APexPages.Message(ApexPages.severity.ERROR, 'Password is required'));
                //ApexPages.addMessages('Password is required');

            }
    }
    public void addAsia1ExistingAccount(){
        
    }
 
    public List<String> getSubList() {
        List<String> SubList = new List<String>();
        subList.add('a');
        
        return SubList;
    }
     public void setSubList(List<String> aww) {
        List<String> SubList = new List<String>();
        subList.add('a');
        
       
    }



    public PageReference cancel() {
        return null;
    }


    public PageReference confirm() {
        return null;
    }


    public void validateNewAsia1Account() {
         if (asia1SingleAccount.User_ID_LDAP_ID__c != null && asia1SingleAccount.Display_Name__c != null) {
            
            map<string, object> validationResult = validateAsia1Account(asia1SingleAccount.User_ID_LDAP_ID__c, 
                    asia1SingleAccount.Display_Name__c);
            
            ldapValidityImg = (string)validationResult.get('ldap');
            displayNameValidityImg = (string)validationResult.get('username');
            
            isAsia1Validated = (boolean)validationResult.get('success');
        } else {
            
            ldapValidityImg = '/s.gif';
            displayNameValidityImg = '/s.gif';
            
            if (asia1SingleAccount.User_ID_LDAP_ID__c == null) {
                asia1SingleAccount.User_ID_LDAP_ID__c.addError(ConstantsSLB.getErrorMessage('Required Field'));
            }
            
            if (asia1SingleAccount.Display_Name__c == null) {
                asia1SingleAccount.Display_Name__c.addError(ConstantsSLB.getErrorMessage('Required Field'));
            }
        }
    }
    
    List<subwrapper> subList = new List<subwrapper>();
    List<Zuora__Subscription__c> selectedSubs = new List<Zuora__Subscription__c>();
        
    public List<subwrapper> getSubs {
        get{
        List<Zuora__Subscription__c> subResultList = new List <Zuora__Subscription__c>();
        List<Package_Item__c> pckItemList = new List<Package_Item__c>();
        Set<Id> pckageIdSet = new Set<Id>();
        Set<Id> printCheckIdSet = new Set<Id>();
        subResultList = [select Id, Name, Billing_Type__c, Main_Package_1__c ,Main_Package_1__r.Name, Product_Code__c, Number_of_Copies__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Status_Formula__c from Zuora__Subscription__c Where Recipient_Contact__c =: contactId AND Status_Formula__c =: GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE AND Subscription_Type_1__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION ];
        for(Zuora__Subscription__c subResult : subResultList){
            pckageIdSet.add(subResult.Main_Package_1__c);
        }
        
        pckItemList = [Select Id, Product_Platform__c, Package__c From Package_Item__c Where Package__c in: pckageIdSet];
        for(Package_Item__c pckItem : pckItemList){
            if(pckItem.Product_Platform__c != GlobalVariableClass.PLATFORM_PRINT){ 
                printCheckIdSet.add(pckItem.Package__c);
            }
        }
    
        for(Zuora__Subscription__c s : [select Id, Name, Billing_Type__c, Main_Package_1__c, Main_Package_1__r.Name, Product_Code__c, Number_of_Copies__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Status_Formula__c from Zuora__Subscription__c Where Recipient_Contact__c =: contactId AND Status_Formula__c =: GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE AND Subscription_Type_1__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION AND Main_Package_1__c IN: printCheckIdSet])
            subList.add(new subwrapper(s));
            return subList;
        }
    }
    
    public PageReference getSelected()
    {
        selectedSubs.clear();
        for(subwrapper sbwrapper : subList)
        if(sbwrapper.selected == true)
        selectedSubs.add(sbwrapper.sub);
        return null;
    }
    
    public List<Zuora__Subscription__c> GetSelectedSubs()
    {
        if(selectedSubs.size()>0)
        return selectedSubs;
        else
        return null;
    }    
 }