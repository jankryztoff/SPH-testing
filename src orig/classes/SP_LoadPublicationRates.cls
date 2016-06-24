/*
* Class Name: SP_LoadPublicationRates
* @Author: Jayson Sarion
* Date: 02 July 2015
* Requirement/Project Name: CRSM Project
* @Description Batch Apex Class to update Publication's Commission Rates and Cover Prices based on the Publication Commission Rate 
*
*/
global class SP_LoadPublicationRates implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    Date referenceDate;
	
	//START D-3676 14-Oct-2015 LISEN - update logic for batch recovery
	Set<String> selectiveIds = null;
	Boolean isApexJobSuccessful = true;
    
    //Default Constructor
    global SP_LoadPublicationRates() {
        referenceDate = date.Today();
    }
    
    //Constructor with input of specific date to process
    global SP_LoadPublicationRates(Date inputDate) {
        referenceDate = inputDate;
    }
	
	//Constructor with input of specific Publication Commission Rate
	global SP_LoadPublicationRates(Set<String> selectiveIds){
		this.selectiveIds = selectiveIds;
	}
	//END D-3676 14-Oct-2015 LISEN - update logic for batch recovery
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Query all records with Effective Date equal to referenceDate
		//START D-3676 14-Oct-2015 LISEN - update logic for batch recovery
        String query = 'SELECT Id, Commission_Rate_Special_Fri__c, Commission_Rate_Special_Mon__c, Commission_Rate_Special_PHD__c, Commission_Rate_Special_PHE__c, Commission_Rate_Special_Sat__c,                  Commission_Rate_Special_Sun__c, Commission_Rate_Special_Thur__c, Commission_Rate_Special_Tue__c, Commission_Rate_Special_Wed__c, Commission_Rate_Fri__c, Commission_Rate_Mon__c, Commission_Rate_PHD__c, Commission_Rate_PHE__c, Commission_Rate_Sat__c, Commission_Rate_Sun__c, Commission_Rate_Thur__c, Commission_Rate_Tue__c, Commission_Rate_Wed__c, Cover_Price_Fri__c, Cover_Price_Mon__c, Cover_Price_PHD__c, Cover_Price_PHE__c, Cover_Price_Sat__c, Cover_Price_Sun__c, Cover_Price_Thur__c, Cover_Price_Tue__c, Cover_Price_Wed__c, Insertion_Rate__c, Effective_Start_Date__c, Publication__c, CreatedDate ';
        query       += 'FROM Publication_Commission_Rates__c WHERE ID != null ';
		if(selectiveIds != null){
			query       += ' AND ID = :selectiveIds';
		}else{
			query       += ' AND Effective_Start_Date__c = :referenceDate';
		}
		//END D-3676 14-Oct-2015 LISEN - update logic for batch recovery
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Publication_Commission_Rates__c> scope) {
		//START D-3676 14-Oct-2015 LISEN - update logic for batch recovery
		Logger logger = new Logger(SP_LoadPublicationRates.class.getName(), 'SP058', BC.getJobID());
		try{
			Map<Id, Publication_Commission_Rates__c> pubIdToPubRateMap = new Map<Id, Publication_Commission_Rates__c>();
			List<Publication__c> pubList = new List<Publication__c>();
			Publication_Commission_Rates__c pubRate = new Publication_Commission_Rates__c();
			List<exception> lstExceptions = new List<exception>();
					
			//Map Publication Id to Publication Commission Rate
			//Latest record will be mapped in case of multiple records per Publication
			for(Publication_Commission_Rates__c pubCommRate :scope) {
				if(pubCommRate.Publication__c != null) {
					if(pubIdToPubRateMap.containsKey(pubCommRate.Publication__c)) {
						if(pubIdToPubRateMap.get(pubCommRate.Publication__c).CreatedDate < pubCommRate.CreatedDate)
							pubIdToPubRateMap.put(pubCommRate.Publication__c, pubCommRate);
					}
					else {
						pubIdToPubRateMap.put(pubCommRate.Publication__c, pubCommRate);
					}
				}
			}

			//List of Publications to be updated
			if(!pubIdToPubRateMap.isEmpty()) {
				pubList = [SELECT Id, Insert_Rate__c, Commission_Rate_Special_Mon__c, Commission_Rate_Mon__c, Cover_Price_Mon__c, Commission_Rate_Special_Tue__c, Commission_Rate_Tue__c, Cover_Price_Tue__c, Commission_Rate_Special_Wed__c, Commission_Rate_Wed__c, Cover_Price_Wed__c, Commission_Rate_Special_Thu__c, Commission_Rate_Thu__c, Cover_Price_Thu__c, Commission_Rate_Special_Fri__c, Commission_Rate_Fri__c, Cover_Price_Fri__c, Commission_Rate_Special_Sat__c, Commission_Rate_Sat__c, Cover_Price_Sat__c, Commission_Rate_Special_Sun__c, Commission_Rate_Sun__c, Cover_Price_Sun__c, Commission_Rate_Special_PHE__c, Commission_Rate_PHE__c, Cover_Price_PHE__c, Commission_Rate_Special_PHD__c, Commission_Rate_PHD__c, Cover_Price_PHD__c FROM Publication__c WHERE Id IN :pubIdToPubRateMap.keySet()];
			}

			//Update Publication record with the rates and prices effective today or the reference date
			for(Publication__c pub :pubList) {
				if(pubIdToPubRateMap.containsKey(pub.Id)) {
					pubRate = pubIdToPubRateMap.get(pub.Id);
					
					pub.Insert_Rate__c = pubRate.Insertion_Rate__c != null ? pubRate.Insertion_Rate__c : pub.Insert_Rate__c;
					
					pub.Commission_Rate_Special_Mon__c = pubRate.Commission_Rate_Special_Mon__c != null ? pubRate.Commission_Rate_Special_Mon__c : pub.Commission_Rate_Special_Mon__c;
					pub.Commission_Rate_Mon__c = pubRate.Commission_Rate_Mon__c != null ? pubRate.Commission_Rate_Mon__c : pub.Commission_Rate_Mon__c;
					pub.Cover_Price_Mon__c = pubRate.Cover_Price_Mon__c != null ? pubRate.Cover_Price_Mon__c : pub.Cover_Price_Mon__c;
					
					pub.Commission_Rate_Special_Tue__c = pubRate.Commission_Rate_Special_Tue__c != null ? pubRate.Commission_Rate_Special_Tue__c : pub.Commission_Rate_Special_Tue__c;
					pub.Commission_Rate_Tue__c = pubRate.Commission_Rate_Tue__c != null ? pubRate.Commission_Rate_Tue__c : pub.Commission_Rate_Tue__c;
					pub.Cover_Price_Tue__c = pubRate.Cover_Price_Tue__c != null ? pubRate.Cover_Price_Tue__c : pub.Cover_Price_Tue__c;
					
					pub.Commission_Rate_Special_Wed__c = pubRate.Commission_Rate_Special_Wed__c != null ? pubRate.Commission_Rate_Special_Wed__c : pub.Commission_Rate_Special_Wed__c;
					pub.Commission_Rate_Wed__c = pubRate.Commission_Rate_Wed__c != null ? pubRate.Commission_Rate_Wed__c : pub.Commission_Rate_Wed__c;
					pub.Cover_Price_Wed__c = pubRate.Cover_Price_Wed__c != null ? pubRate.Cover_Price_Wed__c : pub.Cover_Price_Wed__c;
					
					pub.Commission_Rate_Special_Thu__c = pubRate.Commission_Rate_Special_Thur__c != null ? pubRate.Commission_Rate_Special_Thur__c : pub.Commission_Rate_Special_Thu__c;
					pub.Commission_Rate_Thu__c = pubRate.Commission_Rate_Thur__c != null ? pubRate.Commission_Rate_Thur__c : pub.Commission_Rate_Thu__c;
					pub.Cover_Price_Thu__c = pubRate.Cover_Price_Thur__c != null ? pubRate.Cover_Price_Thur__c : pub.Cover_Price_Thu__c;
					
					pub.Commission_Rate_Special_Fri__c = pubRate.Commission_Rate_Special_Fri__c != null ? pubRate.Commission_Rate_Special_Fri__c : pub.Commission_Rate_Special_Fri__c;
					pub.Commission_Rate_Fri__c = pubRate.Commission_Rate_Fri__c != null ? pubRate.Commission_Rate_Fri__c : pub.Commission_Rate_Fri__c;
					pub.Cover_Price_Fri__c = pubRate.Cover_Price_Fri__c != null ? pubRate.Cover_Price_Fri__c : pub.Cover_Price_Fri__c;
					
					pub.Commission_Rate_Special_Sat__c = pubRate.Commission_Rate_Special_Sat__c != null ? pubRate.Commission_Rate_Special_Sat__c : pub.Commission_Rate_Special_Sat__c;
					pub.Commission_Rate_Sat__c = pubRate.Commission_Rate_Sat__c != null ? pubRate.Commission_Rate_Sat__c : pub.Commission_Rate_Sat__c;
					pub.Cover_Price_Sat__c = pubRate.Cover_Price_Sat__c != null ? pubRate.Cover_Price_Sat__c : pub.Cover_Price_Sat__c;
					
					pub.Commission_Rate_Special_Sun__c = pubRate.Commission_Rate_Special_Sun__c != null ? pubRate.Commission_Rate_Special_Sun__c : pub.Commission_Rate_Special_Sun__c;
					pub.Commission_Rate_Sun__c = pubRate.Commission_Rate_Sun__c != null ? pubRate.Commission_Rate_Sun__c : pub.Commission_Rate_Sun__c;
					pub.Cover_Price_Sun__c = pubRate.Cover_Price_Sun__c != null ? pubRate.Cover_Price_Sun__c : pub.Cover_Price_Sun__c;
					
					pub.Commission_Rate_Special_PHE__c = pubRate.Commission_Rate_Special_PHE__c != null ? pubRate.Commission_Rate_Special_PHE__c : pub.Commission_Rate_Special_PHE__c;
					pub.Commission_Rate_PHE__c = pubRate.Commission_Rate_PHE__c != null ? pubRate.Commission_Rate_PHE__c : pub.Commission_Rate_PHE__c;
					pub.Cover_Price_PHE__c = pubRate.Cover_Price_PHE__c != null ? pubRate.Cover_Price_PHE__c : pub.Cover_Price_PHE__c;
					
					pub.Commission_Rate_Special_PHD__c = pubRate.Commission_Rate_Special_PHD__c != null ? pubRate.Commission_Rate_Special_PHD__c : pub.Commission_Rate_Special_PHD__c;
					pub.Commission_Rate_PHD__c = pubRate.Commission_Rate_PHD__c != null ? pubRate.Commission_Rate_PHD__c : pub.Commission_Rate_PHD__c;
					pub.Cover_Price_PHD__c = pubRate.Cover_Price_PHD__c != null ? pubRate.Cover_Price_PHD__c : pub.Cover_Price_PHD__c;
				}
			}
			
			if(!pubList.isEmpty()) {
				update pubList;
			}
		}catch(Exception e){
            logger.logBatchFailure(e, scope);
			
			isApexJobSuccessful = false;
		}finally{
			logger.save();
		}
		//END D-3676 14-Oct-2015 LISEN - update logic for batch recovery
    }
    
    global void finish(Database.BatchableContext BC) {
        //Update Job Status
		//START D-3676 14-Oct-2015 LISEN - update logic for batch recovery
		if(!isApexJobSuccessful){
        	BatchJobHelper.updateJobStatus(BC.getJobId(), false); 
        }else{
            BatchJobHelper.updateJobStatus(BC.getJobId(), true);
        }
		//END D-3676 14-Oct-2015 LISEN - update logic for batch recovery
    }
}