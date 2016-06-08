/**
 * Class Name: SP_CreditBalanceAdjustmentLessThanZero
 * @author: Jason Abolac / Jayson Sarion
 * Date: 03/20/2015
 * Requirement/Project Name: CRSM Project
 * @description: MD - 17 batch class that will retrieve those invoices where the balance is < 0. 
 * @history: D-3791 LISEN 21-Oct-2015 - Refine query to only select Invoice where Invoice Date < TODAY
 */
global class SP_CreditBalanceAdjustmentLessThanZero implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
	//START D-3670 LISEN 12/Oct/2015 - Enable on demand all for batch recovery
	private Set<String> accountNumbers = null;
    
    //START D-3670 10/14/2015 Added By C. Lin - Add Variable
    Integer type;
    final Static Integer SELECTIVE_INVOICE = 1;
    final Static Integer SELECTIVE_ACCOUNTS = 2;
    Boolean isApexJobSuccessful = true;
    //END D-3670 10/14/2015 Added By C. Lin
    
	global SP_CreditBalanceAdjustmentLessThanZero(){
	
	}
	
    //START D-3670 10/14/2015 Added By C. Lin - Add type for Selective Id or Billing Account Number
    global SP_CreditBalanceAdjustmentLessThanZero(Set<String> accountNumbers, Integer type){
        this.accountNumbers = accountNumbers;
        this.type = type;
    }
    //END D-3670 10/14/2015 Added By C. Lin
	//END D-3670 LISEN 12/Oct/2015 - Enable on demand all for batch recovery
	
    global Database.queryLocator start(Database.BatchableContext bc) {
		//START D-3670 LISEN 12/Oct/2015 - Enable on demand all for batch recovery
        //START D-3670 10/14/2015 Added By C. Lin - Change to Billing Account Number and into string query
        String query;
        
        //START D-3791 LISEN 21-Oct-2015 - Refine query to only select Invoice where Invoice Date < TODAY
		if(accountNumbers != null && !accountNumbers.isEmpty()){
            if(type == SELECTIVE_INVOICE){
                query = 'SELECT Id, Name, Zuora__Balance2__c FROM Zuora__ZInvoice__c WHERE Zuora__Balance2__c < 0 AND Id IN :accountNumbers AND Zuora__InvoiceDate__c <= TODAY';
            }else if(type == SELECTIVE_ACCOUNTS){
                query = 'SELECT Id, Name, Zuora__Balance2__c FROM Zuora__ZInvoice__c WHERE Zuora__Balance2__c < 0 AND Zuora__BillingAccount__r.Zuora__AccountNumber__c IN :accountNumbers AND Zuora__InvoiceDate__c <= TODAY';
            }
		}else{
            query = 'SELECT Id, Name, Zuora__Balance2__c FROM Zuora__ZInvoice__c WHERE Zuora__Balance2__c < 0 AND CreatedDate = THIS_MONTH AND Zuora__InvoiceDate__c <= TODAY';
		}
        //END D-3791 LISEN 21-Oct-2015 - Refine query to only select Invoice where Invoice Date < TODAY
        
        return Database.getQueryLocator(query);
        //END D-3670 10/14/2015 Added By C. Lin
		//END D-3670 LISEN 12/Oct/2015 - Enable on demand all for batch recovery
    }
    
    
    global void execute(Database.BatchableContext bc, list<Zuora__ZInvoice__c> invList) {
		//START D-3670 LISEN 12/Oct/2015 - Enable on demand all for batch recovery
        //START D-3670 10/14/2015 Added By C. Lin - Remove save setSavepoint and rollback
        //Savepoint sp = Database.setSavepoint();
        Logger logger = new Logger(SP_CreditBalanceAdjustmentLessThanZero.class.getName(),'SP046');
        //END D-3670 10/14/2015 Added By C. Lin
        try{
			List<Map<String, Object>> creditBalAdjMapList = new List<Map<String, Object>>();
            //START D-3670 10/14/2015 Added By C. Lin - Comment Out
            //Logger logger = new Logger(SP_CreditBalanceAdjustmentLessThanZero.class.getName(),'SP046'); //START END D-1011 MD-28 Dags 18/06/15
            //END D-3670 10/14/2015 Added By C. Lin
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
                                    //START D-4080 Gdelrosario : added instantiation for code review
                                    list<map<string, string>> resultmap = new list<Map<String,String>>();  
                                    //END D-4080 Gdelrosario : added instantiation for code review
									system.debug('creditBalAdjMapList' + creditBalAdjMapList);      
									ZuoraCallOut zuorCall = new ZuoraCallOut();
									resultmap = zuorCall.loadZObjects(creditBalAdjMapList, 'CreditBalanceAdjustment');
									system.debug('resultmap' + resultmap);
									//START D-1011 MD-28 Dags 18/06/15 - Using Logger
									for(Map<String,String> result :resultMap){
										 if(result.get('Status') == 'Processed') {                      
											 system.debug('~~~~~~ : SUCCESS'); 
										 }
										 else { 
											
											//system.debug('~~~~~~ : Failed PAYMENT');                       
											//system.debug('Message : ' + result.get('Message')); 
											logger.log(false,result.get('Message'));
											
										  } 
									}
									Logger.save() ;
									//END D-1011 MD-28 Dags 18/06/15  
		}catch(Exception e){
            //START D-3670 10/14/2015 Added By C. Lin - Add logger
            //Database.rollback(sp);
            //Id JOB_ID = BC.getJobId();       
            //BatchJobHelper.handleException(invList,e,SP_CreditBalanceAdjustmentLessThanZero.class.getName(),'SP046',JOB_ID,JOB_ID,True);
            logger.logBatchFailure(e, invList);
            logger.save();
            
            isApexJobSuccessful = false;
            //END D-3670 10/14/2015 Added By C. Lin
        }
		//END D-3670 LISEN 12/Oct/2015 - Enable on demand all for batch recovery
    }   

    global void finish(Database.BatchableContext bc) {
        //START D-3670 10/14/2015 Added By C. Lin - Enable on demand batch call for recovery
        if(!isApexJobSuccessful){
            BatchJobHelper.updateJobStatus(BC.getJobId(), false);
        }else{
            BatchJobHelper.updateJobStatus(BC.getJobId(), true);
        }
        //END D-3670 10/14/2015 Added By C. Lin
    }   
}