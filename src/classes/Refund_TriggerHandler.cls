/**
* Class Name: Refund_TriggerHandler 
* @author: Accenture PDC - Sherwin Puli
* Date: 15.July.2015
* Requirement/Project Name: SF SPH
* @description: Class that manages Refund DMLs. UD-1419
* 
* @History: UD-1419 7/17/2015 Alyana Navarro
* @History: UD-3253 04-Mar-2016 S.Puli - Remove Credit Note Code due to CR and create Credit Adjustment Records instead.
*/

public class Refund_TriggerHandler{
    
    Logger logger = new Logger(Refund_TriggerHandler.class.getName());
    public Other__c creditNoteNumber = new Other__c();
    public Other__c minCreditNoteNumber = new Other__c();
    public Other__c maxCreditNoteNumber = new Other__c();
    Integer latestCreditNote = 0;
    
    public void doBeforeInsert(List<Zuora__Refund__c> newRefundList) {
        
        for(Integer counter = 0; counter < newRefundList.size(); counter++){
            newRefundList[counter].Case__c = newRefundList[counter].Case_1__c;
        }   
    }
    
    public void doAfterInsert(List<Zuora__Refund__c> newRefundList, Map<Id, Zuora__Refund__c> newRefundMap){  
        generateCreditAdjustments(newRefundMap);
    }
       
    public void doBeforeUpdate(List<Zuora__Refund__c> newRefundList, Map<Id, Zuora__Refund__c> newRefundMap, 
                               List<Zuora__Refund__c> oldRefundList, Map<Id, Zuora__Refund__c> oldRefundMap)
    {}
           
    public void doAfterUpdate(List<Zuora__Refund__c> newRefundList, Map<Id, Zuora__Refund__c> newRefundMap, 
                              List<Zuora__Refund__c> oldRefundList, Map<Id, Zuora__Refund__c> oldRefundMap)
    {}
    
    public void doBeforeDelete(List<Zuora__Refund__c> oldRefundList, Map<Id, Zuora__Refund__c> oldRefundMap)
    {}

    public void doAfterDelete(List<Zuora__Refund__c> oldRefundList, Map<Id, Zuora__Refund__c> oldRefundMap)
    {}
    
    public void generateCreditAdjustments(Map<Id, Zuora__Refund__c> newRefundMap){
        try {
            List<Zuora__Refund__c> initRefund_List = new List<Zuora__Refund__c>();
            List<Credit_Adjustment__c> creditAdj_List = new List<Credit_Adjustment__c>();
            
            creditNoteNumber = Other__c.getInstance('CN_NUMBER_NEXT');
            minCreditNoteNumber = Other__c.getInstance('CN_NUMBER_MIN');
            maxCreditNoteNumber = Other__c.getInstance('CN_NUMBER_MAX');
            latestCreditNote = Integer.valueOf(creditNoteNumber.Value__c);
            
            if(!newRefundMap.isEmpty()){
                initRefund_List = [SELECT Id, Zuora__BillingAccount__c, Zuora__BillingAccount__r.Other_PaymentMethod__c, Case__c,Case__r.CaseNumber, 
                                    Case__r.Payment_Mode__c,Case__r.RecordTypeID, Zuora__Amount__c,Zuora__RefundDate__c,
                                    Zuora__BillingAccount__r.ARMS_Account_Number__c 
                                    FROM Zuora__Refund__c 
                                    WHERE Id IN :newRefundMap.keySet()  
                                    AND Zuora__BillingAccount__r.Other_PaymentMethod__c = :GlobalVariableClass.INVOICE 
                                    AND Case__r.Payment_Mode__c = :GlobalVariableClass.INVOICE 
                                    AND Case__r.RecordTypeID = :ConstantsSLB.getKeyId(GlobalVariableClass.CASEREFUND) 
                                    ];
                                    
                for(Zuora__Refund__c ref : initRefund_List){
                    Credit_Adjustment__c ca = new Credit_Adjustment__c();
                    ca.Billing_Account__c = ref.Zuora__BillingAccount__c;
                    ca.Case__c = ref.Case__c;
                    ca.Credit_Amount__c = ref.Zuora__Amount__c;
                    ca.Document_Date__c = date.valueOf(ref.Zuora__RefundDate__c);
                    ca.Name =  '00' + String.valueOf(latestCreditNote);
                    latestCreditNote++;
                    if(latestCreditNote > Integer.valueOf(maxCreditNoteNumber.Value__c)){
                        latestCreditNote = Integer.valueOf(minCreditNoteNumber.Value__c);
                    }
                    
                    creditAdj_List.add(ca);
                }
            }
            if(!creditAdj_List.isEmpty()){
                insert creditAdj_List;
                creditNoteNumber.Value__c = String.valueOf(latestCreditNote);
                update creditNoteNumber;
            }
        } catch (exception e) {
            logger.log(e);
        }
        logger.save();
    }
    
}