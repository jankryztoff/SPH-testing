/** Start D-02262 VPernicia 4/30/15
* Class Name: PubCommissionRatesTriggerHandler
* @author: Rom Edison Reyes
* Date: 04/28/2015
* Requirement/Project Name: Singapore Press Holdings
* @description TriggerHandler for Publication Commission Rates
*/

public class PubCommissionRatesTriggerHandler {


    public void doAfterUpdate(List<Publication_Commission_Rates__c> lstNewPubComRates, Map<Id, Publication_Commission_Rates__c> mapNewPubComRates,
                               List<Publication_Commission_Rates__c> lstOldPubComRates, Map<Id, Publication_Commission_Rates__c> mapOldPubComRates)
    { 
        List<Publication__c> pubList = new List<Publication__c>() ;
        Map<Id, Publication__c> mapIdtoPub = new Map<Id, Publication__c>();
        Set<Id> pubIdSet = new Set<Id>();
        String dayOfWeek = DateTime.now().format('E'); 
        
        for(Publication_Commission_Rates__c pcr: lstNewPubComRates){
            if(pcr.Publication__c != null){
                pubIdSet.add(pcr.Publication__c);
            }
        }
        if(pubIdSet.size() > 0){        
            for(Publication__c pub:[SELECT Id, Insert_Rate__c,
            Commission_Rate_Special_Mon__c, Commission_Rate_Mon__c, Cover_Price_Mon__c,
            Commission_Rate_Special_Tue__c, Commission_Rate_Tue__c, Cover_Price_Tue__c,
            Commission_Rate_Special_Wed__c, Commission_Rate_Wed__c, Cover_Price_Wed__c,
            Commission_Rate_Special_Thu__c, Commission_Rate_Thu__c, Cover_Price_Thu__c,
            Commission_Rate_Special_Fri__c, Commission_Rate_Fri__c, Cover_Price_Fri__c,
            Commission_Rate_Special_Sat__c, Commission_Rate_Sat__c, Cover_Price_Sat__c,
            Commission_Rate_Special_Sun__c, Commission_Rate_Sun__c, Cover_Price_Sun__c,
            Commission_Rate_Special_PHE__c, Commission_Rate_PHE__c, Cover_Price_PHE__c,
            Commission_Rate_Special_PHW__c, Commission_Rate_PHW__c, Cover_Price_PHW__c
            
            from Publication__c where Id in: pubIdSet]){
                mapIdtoPub.put(pub.Id, pub);
            }
        }
        
        for(Publication_Commission_Rates__c pcr: lstNewPubComRates){
            if(mapIdtoPub.keySet().contains(pcr.Publication__c)){
                Publication__c pub = mapIdtoPub.get(pcr.Publication__c);
                
                pub.Insert_Rate__c = pcr.Insertion_Rate__c;
                
                pub.Commission_Rate_Special_Mon__c = pcr.Commission_Rate_Special_Mon__c;
                pub.Commission_Rate_Mon__c = pcr.Commission_Rate_Mon__c;
                pub.Cover_Price_Mon__c = pcr.Cover_Price_Mon__c;
                
                pub.Commission_Rate_Special_Tue__c = pcr.Commission_Rate_Special_Tue__c;
                pub.Commission_Rate_Tue__c = pcr.Commission_Rate_Tue__c;
                pub.Cover_Price_Tue__c = pcr.Cover_Price_Tue__c;
                
                pub.Commission_Rate_Special_Wed__c = pcr.Commission_Rate_Special_Wed__c;
                pub.Commission_Rate_Wed__c = pcr.Commission_Rate_Wed__c;
                pub.Cover_Price_Wed__c = pcr.Cover_Price_Wed__c;
                
                pub.Commission_Rate_Special_Thu__c = pcr.Commission_Rate_Special_Thur__c;
                pub.Commission_Rate_Thu__c = pcr.Commission_Rate_Thur__c;
                pub.Cover_Price_Thu__c = pcr.Cover_Price_Thur__c;
                
                pub.Commission_Rate_Special_Fri__c = pcr.Commission_Rate_Special_Fri__c;
                pub.Commission_Rate_Fri__c = pcr.Commission_Rate_Fri__c;
                pub.Cover_Price_Fri__c = pcr.Cover_Price_Fri__c;
                
                pub.Commission_Rate_Special_Sat__c = pcr.Commission_Rate_Special_Sat__c;
                pub.Commission_Rate_Sat__c = pcr.Commission_Rate_Sat__c;
                pub.Cover_Price_Sat__c = pcr.Cover_Price_Sat__c;
                
                pub.Commission_Rate_Special_Sun__c = pcr.Commission_Rate_Special_Sun__c;
                pub.Commission_Rate_Sun__c = pcr.Commission_Rate_Sun__c;
                pub.Cover_Price_Sun__c = pcr.Cover_Price_Sun__c;
                
                pub.Commission_Rate_Special_PHE__c = pcr.Commission_Rate_Special_PHE__c;
                pub.Commission_Rate_PHE__c = pcr.Commission_Rate_PHE__c;
                pub.Cover_Price_PHE__c = pcr.Cover_Price_PHE__c;
                
                /*pub.Commission_Rate_Special_PHW__c = pcr.Commission_Rate_Special_PHD__c;
                pub.Commission_Rate_PHW__c = pcr.Commission_Rate_PHD__c;
                pub.Cover_Price_PHW__c = pcr.Cover_Price_PHD__c;*/
                
                pubList.add(pub);
            }
            
        }

        if(pubList.size() > 0){
            try{
                update pubList;
            }catch(exception e){
                System.debug('>>> Update Failed: ' + e.getMessage());
            }
        }
            
        
    }

}
//End D-02262 VPernicia 4/30/15