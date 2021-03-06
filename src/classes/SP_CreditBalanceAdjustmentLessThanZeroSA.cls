/**
 * Class Name: SP_CreditBalanceAdjustmentLessThanZero
 * @author: Jason Abolac / Jayson Sarion
 * Date: 03/20/2015
 * Requirement/Project Name: CRSM Project
 * @description: MD - 17 batch class that will retrieve those invoices where the balance is < 0. 
 *
 */
global class SP_CreditBalanceAdjustmentLessThanZeroSA implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    Boolean selectAccountsFlag = false; 
    Set<String> accountNumberSet;
    
    global SP_CreditBalanceAdjustmentLessThanZeroSA(Set<String> accountNumberSet){
        this.selectAccountsFlag = true;
        this.accountNumberSet = accountNumberSet;
    }       
    
    global Database.queryLocator start(Database.BatchableContext bc) {
    
        if(selectAccountsFlag) {
           return Database.getQueryLocator([SELECT Id, Name, Zuora__Balance2__c FROM Zuora__ZInvoice__c WHERE Zuora__Balance2__c < 0 AND CreatedDate = THIS_MONTH AND Zuora__Account__r.AccountNumber IN :accountNumberSet]);
        } else {        
           return Database.getQueryLocator([SELECT Id, Name, Zuora__Balance2__c FROM Zuora__ZInvoice__c WHERE Zuora__Balance2__c < 0 AND CreatedDate = THIS_MONTH]);
        }
     }
    
    
    global void execute(Database.BatchableContext bc, list<Zuora__ZInvoice__c> invList) {
        List<Map<String, Object>> creditBalAdjMapList = new List<Map<String, Object>>();
        Logger logger = new Logger(SP_CreditBalanceAdjustmentLessThanZero.class.getName(),'SP046'); //START END D-1011 MD-28 Dags 18/06/15
                                Map<String, Object> creditBalAdjMap;
                                
                                
                                for (Zuora__ZInvoice__c inv :invList) {
                                                creditBalAdjMap = new Map<String, Object>();
                                                
                                                //creditBalAdjMap.put('AdjustmentDate', zuora.zUtil.getZuoraDate(date.today()) );
                                                //creditBalAdjMap.put('Number',  );
                                                creditBalAdjMap.put('Type', 'Increase' );
                                                creditBalAdjMap.put('Amount', Math.abs(inv.Zuora__Balance2__c));
                                                creditBalAdjMap.put('SourceTransactionNumber', inv.Name );
                                                creditBalAdjMapList.add(creditBalAdjMap);
                                }
                                list<map<string, string>> resultmap;  
                                system.debug('creditBalAdjMapList' + creditBalAdjMapList);      
                                ZuoraCallOut zuorCall = new ZuoraCallOut();
                                resultmap = zuorCall.loadZObjects(creditBalAdjMapList, 'CreditBalanceAdjustment');
                                system.debug('resultmap' + resultmap);
                                //START D-1011 MD-28 Dags 18/06/15 - Using Logger
                                for(Map<String,String> result :resultMap){
                                     if(result.get('Status') == 'Processed') {                      
                                     }
                                     else { 
                                        
                                        logger.log(false,result.get('Message'));
                                        
                                      } 
                                }
                                Logger.save() ;
                                //END D-1011 MD-28 Dags 18/06/15                            
    }   

    global void finish(Database.BatchableContext bc) {
        BatchJobHelper.updateJobStatus(BC.getJobId());
    }   
}