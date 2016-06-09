public with sharing class ComplaintMagazineController {

    public String getCase() {
        return null;
    }


    public ComplaintMagazineController() {

    }


    public Case cas {get;set;}
    public Case_Subscription__c CaseSub {get;set;}
    


    public void CustomController(){
        cas = new Case();
        CaseSub = new Case_Subscription__c();
    }   
       
    public void save(){
        
            insert cas;

  }
  


     public void cancel(){
        
        return;
  }    




        
    public ComplaintMagazineController(ApexPages.StandardController controller) {


    }/*End Constructor*/




}/*End Class*/