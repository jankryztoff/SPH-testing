public class AssignSubscriptionExtension{

    public Case selectedSubscription {get; set;} 
    Id rectype;            
    string cCaseId = ApexPages.currentPage().getParameters().get('id');    
    //public List<Case> zCase {get;set;}
    
    public AssignSubscriptionExtension(ApexPages.StandardController controller) {
        this.selectedSubscription = (Case) controller.getRecord(); 
        rectype = (Id) ApexPages.currentPage().getParameters().get('RecordType');
    
        if(rectype != null) {
            selectedSubscription.RecordTypeId = recType;
        }   
    }
     
    
    public List<SubscriptionObj> SubscriptionList;
        
    public List<SubscriptionObj> getSubscriptionList() {   
     
          if(SubscriptionList == null) 
          {
             
            SubscriptionList = new List<SubscriptionObj>();
            
            //Collect all Subscription related in Account
            for(Zuora__Subscription__c zSubs: [select Id, Name, Subscriber_Contact__c, Recipient_Contact__c, Recipient_Contact__r.Address__c, vendor_1__c, Zuora__Status__c from Zuora__Subscription__c 
                where Zuora__Account__c =: selectedSubscription.AccountId]) {
                
                SubscriptionList.add(new SubscriptionObj(zSubs)); 
            }
          }
        return SubscriptionList;
    }

    public class SubscriptionObj{
        public Zuora__Subscription__c zSubs{get; set;}
        public Boolean selected{get; set;}
        public String errMsg{get;set;}
        public Boolean hasError {get;set;}

        public SubscriptionObj(Zuora__Subscription__c a) {
            zSubs = a;
            selected = false;
            hasError =false;
        }
    }
 
    public PageReference submit(){
      
        //Set<String> selectedSubscriptionID = new Set<String>();
        List<Zuora__Subscription__c> selectedSubscriptionList = new List<Zuora__Subscription__c>();     
        Boolean hasError = False;
        for(SubscriptionObj z: getSubscriptionList()){
        if(z.selected == true && selectedSubscription.Recipient_Address__c == z.zSubs.Recipient_Contact__r.Address__c){
           z.errMsg = ConstantsSLB.getErrorMessage('Duplicate Address Error');
           z.hasError =TRUE;
           hasError =TRUE;
        
       
        }
        else{
           z.errMsg = '';
           z.hasError =FALSE;

        }

        if(z.selected == true) {
            //selectedSubscriptionID.add(z.zSubs.Name);
            selectedSubscriptionList.add(z.zSubs);
          
        }
            
        } 
        
        if(hasError) 
            {
                return NULL;
            }
        //selectedSubscriptionList = [Select Id, Recipient_Contact__c From Zuora__Subscription__c Where Id =:  selectedSubscriptionID ]; 
        for(Zuora__Subscription__c z : selectedSubscriptionList) {
            selectedSubscription.Subscription_Name__c = z.Id;                 
            z.Recipient_Contact__c = selectedSubscription.Recipient__c;
            z.Vendor__c = selectedSubscription.Replaced_By__c;
            z.Vendor_1__c = selectedSubscription.Replaced_By__c;
            //System.debug('@@@@@ ' + selectedSubscription.Id + '/' + selectedSubscription.Recipient__c + '/' + z.Recipient_Contact__c);
            System.debug('@@@@@ ' + selectedSubscription.Id + '/' + selectedSubscription.Recipient__c + '/' + z.Recipient_Contact__c + '/' + z.Vendor__c + '/' + z.Vendor_1__c);
                   
        }
        
        
        try
        {
            if(selectedSubscriptionList != NULL)
            {
                update selectedSubscription;
                update selectedSubscriptionList;              
                
                             
               
            }
         
            
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('Generic Error') + e.getStackTraceString()));
        }
       
        PageReference pageRef = new pageReference('/'+cCaseId);
        pageRef.setRedirect(true);
        return pageRef;
        
        return null;
    }
    
    public PageReference cancel(){
        PageReference pageRef = new pageReference('/'+cCaseId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public void retrieveAddress() {
        if(selectedSubscription.Recipient__c != null) {
            try {
                selectedSubscription.Recipient_Address__c = [SELECT Address__c FROM Contact WHERE Id = :selectedSubscription.Recipient__c].Address__c;
            }
            catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('Generic Error') + e.getStackTraceString()));
            }
        }
    }
}