/**
 * Class Name: AcknowledgmentLetterEmail
 * @author: Jean Cariño
 * Date: 04/29/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description trigger handler for LetterPrintRequestTrigger
 */

public class LetterPrintRequestTriggerHandler {

    public void doBeforeInsert(List<Letter_Print_Request__c> lstNewLPR,
    Map<Id, Letter_Print_Request__c> mapLPR,
    List<Letter_Print_Request__c> lstOldLPR,
    Map<Id, Letter_Print_Request__c> mapOldLPR){
    
    List<Account> acctList = new List<Account>() ;
    Map<Id, String> mapIdtoAcct = new Map<Id, String>();
    Set<Id> acctIdSet = new Set<Id>();

    for(Letter_Print_Request__c lpr: lstNewLPR){
        //START: D-2873 Added By S.Puli - filter for acknowledement letter only
        if(lpr.Record_Id__c != null && lpr.Letter_Type__c == GlobalVariableClass.LETTER_TYPE_ACK){
		//END: D-2873 Added By S.Puli 
            acctIdSet.add(lpr.Record_Id__c);
            }
        }
        
        if(acctIdSet.size() > 0){ 
			//START UD-2286 11-Aug-2015 Added By S.Puli
            for(Zuora__CustomerAccount__c acct:[SELECT Id, Zuora__Account__r.Acknowledgement_Letter__c
                              FROM Zuora__CustomerAccount__c
                              WHERE Id in: acctIdSet]){
            mapIdtoacct.put(acct.Id, acct.Zuora__Account__r.Acknowledgement_Letter__c);
            }
			
        for(Letter_Print_Request__c lpr: lstNewLPR){
            if (mapIdtoacct.containsKey(lpr.Record_Id__c)){
			//END UD-2286 11-Aug-2015 Added By S.Puli
            lpr.Acknowledgment_Type__c = mapIdtoacct.get(lpr.Record_Id__c);        
                }
            }
        }
    }
}