/*
 * Revision: Version 1.0 
 * @author: Del Rosario, George
 * Date: 16/11/2015
 * Requirement/Project Name: Singapore Press Holdings
 * Description: New VF page for Gift Letter Batches for improved UI [UD-0461]
 * 
 */


public class GiftLetterBatchesExtenController {
    private id recordID {get;set;}
    public  Gift_Letter_Batch__c g {set; get;}
    public List<String> promoGiftError = new List<String>();
    
    public GiftLetterBatchesExtenController(ApexPages.StandardController stdController) {
        if( (Id)stdController.getRecord().Id == null){
            this.g =(Gift_Letter_Batch__c)stdController.getRecord();
        }else{
            g = [Select id, Name, Promotion__c,Gift__c,Start_Date__c,End_Date__c,Redemption_Start_Date__c,Redemption_End_Date__c,
                    Letter_Template__c,Customer_Account_Number__c,Promo_Chinese_Name__c,Redemption_Venue__c
                        FROM Gift_Letter_Batch__c WHERE id =: (Id)stdController.getRecord().Id];
        }
    }
    
    public LIST<SelectOption> getGiftOptions(){
        List<selectOption> options = new List<selectOption>(); 
        options.add(new selectOption('', '- NONE -')); 
        if(g.Promotion__c != null){
            for(Promotion_Gift__c gift : [Select id, Name, Gift__c,Gift__r.ID,Gift__r.Name,Promotion__c,Promotion__r.Name FROM Promotion_Gift__c WHERE Promotion__c =: g.Promotion__c ]){   
                if( gift.Id != null && gift.Promotion__c != null ){
                    options.add(new selectOption(gift.Gift__r.ID, gift.Gift__r.Name));
                }else {
                    promoGiftError.add(gift.Name);
                } 
            }
            
            if(promoGiftError.size() > 0){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid Input.');
                ApexPages.addMessage(myMsg);
            }
            
        }
        return options;
    }
    
    
    public System.PageReference saveNew() {
        try{
            insert g; 
            PageReference giftPage = ApexPages.currentPage();
            giftPage.setRedirect(true);
            return giftPage;
        }catch(Exception e){
			system.debug('InsertFailed: ' + e.getMessage());
			return null;
        }
    }
    
    public System.PageReference save() {
          try{
                upsert g; 
                PageReference giftPage = new ApexPages.StandardController(g).view();
                giftPage.setRedirect(true);
                return giftPage;  
          }catch(Exception e){
				system.debug('InsertFailed: ' + e.getMessage());
                return null;
          }
      
    }
    

    


    
    
}