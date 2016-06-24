/*
 * Class Name: ZInvoiceHelper
 * @author: Kevin Evasco
 * Date: 05 October 2015
 * Project/Requirement: SPH - Billing
 * @description This class contains the utility methods for ZInvoice
 * @History: 05 October 2015 UD-2504 Kevin Evasco - Created for UD-2504. Fix would store the Previous Balance in Zuora Invoice record.
 */
  
 global class ZInvoiceHelper{   
    
    global class ZInvoiceWrapper {
        public String invoiceId;
        public String previousBalance;
    }   
    
    public static void adjustInvoicePreviousBalance(List<ZInvoiceWrapper> invoiceWrapperListParam, Logger loggerParam) {        
        
        ZuoraCallOut zCallOut = new ZuoraCallOut();
        List<Map<String, Object>> invoiceZList = new List<Map<String, Object>>();
        
        for(ZInvoiceWrapper invoiceWrapperElem : invoiceWrapperListParam) {         
            Map<String, Object> invoiceMap = new Map<String, Object>();         
            invoiceMap.put('Id', invoiceWrapperElem.invoiceId);
            invoiceMap.put('Previous_Balance__c', invoiceWrapperElem.previousBalance);
            invoiceZList.add(invoiceMap);
        }

        try {   
            List<Map<String,String>> resultMap = zCallout.updateZObjects(invoiceZList, 'Invoice');
             for(Map<String,String> result :resultMap){
                if(result.get('Status') == 'Success') {                      
                    system.debug('Successful adjustInvoicePreviousBalance'); 
                }
                else {
                    loggerParam.log(false,result.get('Message'));                                                     
                } 
             }
        } catch (exception ze) {
              loggerParam.log(ze);
        }
    }   
}