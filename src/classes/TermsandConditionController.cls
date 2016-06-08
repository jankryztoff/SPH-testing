public  class TermsandConditionController {

    public Promotion__c promo {get; set;}
    

    public TermsandConditionController() {
        string promoId = ApexPages.currentPage().getParameters().get('id');
        //String promoId='a0CN0000001QxcS';  
        
        this.promo = [SELECT Id, Name, Terms_Conditions_Summary__c, Terms_Conditions_Detail__c
                 FROM Promotion__c
                 WHERE Id = :promoId];
    
    
    
    }
    

}