/**
 * Trigger Name: BT_AT_ARM063DX_2_CreateAccountBatchResonseFile
 * Author: Kevin Evasco
 * Date: 08/21/2014
 * Project/Requirement: SPH Integration - ARM063DX_2 Interface
 * Description: This trigger contains the business logic for ARM063DX_2 interface.
 * History: 2014/08/21 Kevin Evasco Created Skeletal Apex Trigger
 *          2014/09/29 Kevin Evasco Updated to implement business logic
 * History: 2015/02/16 Renino Niefes Code Review (Novasuite Audit Findings)
 * History: 2015/06/16 Renino Niefes Revised the code, removed unwanted comments
 * History: 2015/06/19 Renino Niefes if the status is rejected, update the status__c = 'rejected'
 */

trigger BT_AT_PPS057DX_RefundFileResponse on BT_CO_PPS_RefundFileResponse__c (before insert, before update){
    String interfaceId = 'PPS057DX';
    Map<Decimal,String> errorMessageMap = BT_CO_INT_Utilities.getErrorMessageMap(interfaceId);
    List<Zuora__Refund__c> refundsForUpdateList = new List<Zuora__Refund__c>();
    List<BT_CO_PPS_RefundFileResponse__c> recordsList = trigger.new;
    Set<String> accountNumberSet = new Set<String>();
    Set<ID> zRefundIDSet = new Set<ID>();
 
    Integer invalidRecordCount = 0;
    String zVALIDATION_CODE = '0';
    String dmlStatus = 'Success';
    String errorMessage = '';   
    String stackTrace = '';
    String zErrorMsg = '';     
    String vStatus = null;
    String vChqCutDate = null;
    String vApprovalDate = null;
    String vHandledByWho = null;
    String vClearenceDate = null;
    String vChqNumber = null;
    String vCustomerName2 = null;
    String vCustomerAccount = null;
    String vPayee2 = null;
    String vPaymentAmount2 = null;
    String vPaymentAmount = null;
    String vCustomerName = null;
    String vCustomerACNumber = null;
    
    System.debug('\n\n\n recordsList '+recordsList+'\n\n');

    for(BT_CO_PPS_RefundFileResponse__c so : recordsList) {
        vCustomerAccount = so.customerAccount__c;
        System.debug('\n\n\n vCustomerAccount '+vCustomerAccount+'\n\n');
        if (StringUtility.validate(vCustomerAccount).equalsIgnoreCase('0')){
            System.debug('\n\n\n StringUtility '+StringUtility.validate(vCustomerAccount).equalsIgnoreCase('0')+'\n\n');
            accountNumberSet.add(so.customerAccount__c);
            System.debug('\n\n\n customerAccount__c '+so.customerAccount__c+'\n\n');
        } 
    }

    System.debug('\n\n\n accountNumberSet '+accountNumberSet+'\n\n');
    Map<String, Account> accountsMap = new Map<String, Account>();
    List<Account> accountsList = [SELECT ID, AccountNumber FROM Account WHERE AccountNumber IN :accountNumberSet];
    System.debug('\n\n\n accountsList '+accountsList+'\n\n');

    for (Account acct : accountsList) {
        accountsMap.put(acct.AccountNumber,acct);
        System.debug('\n\n\n AccountNumber '+acct.AccountNumber+'\n\n');
    }   

    System.debug('\n\n\n accountsMap '+accountsMap+'\n\n');
    Map<String, Zuora__Refund__c> refundsMap = new Map<String, Zuora__Refund__c>();
    List<Zuora__Refund__c> refundslist = [SELECT ID, Cheque_Cut_Date__c, Approval_Date__c, Handled_by_Who__c, Clearance_Date__c,
                                                 Cheque_Number__c, Zuora__Account__r.Name, Zuora__Account__r.AccountNumber,
                                                 Payee__c, Payment_Amount__c, Zuora__Amount__c,Status__c
                                          FROM Zuora__Refund__c WHERE Zuora__Account__r.AccountNumber IN :accountNumberSet AND Status__c <> 'processed'];
    System.debug('\n\n\n refundslist '+refundslist+'\n\n');

    for(Zuora__Refund__c refund : refundslist) {
        String vAccountNumber = refund.Zuora__Account__r.AccountNumber;
        String vCustomerName0 = refund.Zuora__Account__r.Name;
        String vPayee = refund.Payee__c;
        Decimal dPaymentAmount = refund.Payment_Amount__c;
        Decimal dPaymentAmount2 = refund.Zuora__Amount__c;
        String vAmount = null;
        if (StringUtility.validate(dPaymentAmount).equalsIgnoreCase('0'))
            vAmount = dPaymentAmount.setScale(2).toPlainString();
        if (StringUtility.validate(dPaymentAmount2).equalsIgnoreCase('0')) 
            vAmount = dPaymentAmount2.setScale(2).toPlainString();
        String searchString = vAccountNumber+vCustomerName0+vAmount;  //removed vPayee for now until SFDC fixes the defect
        refundsMap.put(searchString,refund);
    }
                                          
    for(BT_CO_PPS_RefundFileResponse__c so : recordsList) {
        vStatus = so.chqStatus__c;
        vChqCutDate = so.chqCutDate__c;
        vApprovalDate = so.approvalDate__c;
        vHandledByWho = so.handledByWho__c;
        vClearenceDate = so.clearanceDate__c;
        vChqNumber = so.chqNumber__c;
        vCustomerName2 = so.customerName2__c;
        vCustomerAccount = so.customerAccount__c;
        vPayee2 = so.payee2__c;
        vPaymentAmount2 = so.paymentAmount2__c;
        vPaymentAmount = so.paymentAmount__c;
        String searchString = null;
        String searchString2 = null;
        Decimal vAmount = 0; //set vAmount default to 0 instead of null
        vCustomerName = so.customerName__c;
        vCustomerACNumber = so.customerACNumber__c;
        vAmount = Decimal.valueOf(vPaymentAmount).setScale(2);
        searchString = vCustomerAccount+vCustomerName2+vAmount; //removed vPayee2 for now until sfdc fixed the defect
        searchString2 = vCustomerACNumber+vCustomerName+vAmount;
        System.debug('PPS057DX: Z4 '+searchString);
        
        zVALIDATION_CODE = StringUtility.validate(vStatus);
        zVALIDATION_CODE += StringUtility.validate(vCustomerName2);
        zVALIDATION_CODE += StringUtility.validate(vCustomerAccount);
        zVALIDATION_CODE += StringUtility.validate(vPayee2);
        zVALIDATION_CODE += StringUtility.validate(vPaymentAmount2);
        zVALIDATION_CODE += StringUtility.validate(vChqCutDate);
        zVALIDATION_CODE += StringUtility.validate(vApprovalDate);
        zVALIDATION_CODE += StringUtility.validate(vHandledByWho);
        zVALIDATION_CODE += StringUtility.validate(vClearenceDate);
        zVALIDATION_CODE += StringUtility.validate(vChqNumber);
                
        if (StringUtility.validate(vStatus).equalsIgnoreCase('0')&&!vStatus.trim().equalsIgnoreCase('A')) {
            zVALIDATION_CODE += '1';
        } else {
            zVALIDATION_CODE += '0';
        }
        
        if (StringUtility.validate(vCustomerAccount).equalsIgnoreCase('0')&&!accountsMap.containsKey(vCustomerAccount.trim())) {
            zVALIDATION_CODE += '1';
        } else {
            zVALIDATION_CODE += '0';
        }

        if (StringUtility.validate(vPaymentAmount2).equalsIgnoreCase('0')&&StringUtility.validate(vCustomerAccount).equalsIgnoreCase('0')&&!refundsMap.containsKey(searchString.trim())) {
            zVALIDATION_CODE += '1';
        } else {
            zVALIDATION_CODE += '0';
        }

        if (StringUtility.validate(vChqCutDate).equalsIgnoreCase('0')&&!DateUtility.isDateDD_MM_YYYY(vChqCutDate,'\\.')) {
            zVALIDATION_CODE += '1';
        } else {
            zVALIDATION_CODE += '0';
        }

        if (StringUtility.validate(vApprovalDate).equalsIgnoreCase('0')&&!DateUtility.isDateDD_MM_YYYY(vApprovalDate,'\\.')) {
            zVALIDATION_CODE += '1';
        } else {
            zVALIDATION_CODE += '0';
        }       
        
        if (StringUtility.validate(vClearenceDate).equalsIgnoreCase('0')&&!DateUtility.isDateDD_MM_YYYY(vClearenceDate,'\\.')) {
            zVALIDATION_CODE += '1';
        } else {
            zVALIDATION_CODE += '0';
        }       
        
        if (BT_CO_INT_Utilities.checkValidation(zVALIDATION_CODE)) {
            so.Validation_Status__c = 'Passed';
            Zuora__Refund__c zRefund = refundsMap.get(searchString);
            zRefund.Cheque_Cut_Date__c = vChqCutDate;
            zRefund.Approval_Date__c = vApprovalDate;
            zRefund.Handled_by_Who__c = vHandledByWho;
            zRefund.Clearance_Date__c = vClearenceDate;
            zRefund.Cheque_Number__c = vChqNumber;          
            zRefund.PPS_Refund_Amount__c = vAmount;
            zRefund.Status__c = 'processed';
            
            if (!zRefundIDSet.contains(zRefund.ID)) {
                refundsForUpdateList.add(zRefund);
            }
            zRefundIDSet.add(zRefund.ID);
        } else {
            zErrorMsg = BT_CO_INT_Utilities.parseValidationCode(zVALIDATION_CODE, errorMessageMap);
            so.Validation_Status__c = 'Failed';
            so.Validation_Details__c = zVALIDATION_CODE + ':' + zErrorMsg;
            invalidRecordCount++;
            System.debug(interfaceId + ': Validation Error: ' + zErrorMsg);

            if (StringUtility.validate(vStatus).equalsIgnoreCase('0')&&vStatus.trim().equalsIgnoreCase('F')) {
                System.debug(interfaceId + ': rejected record searchstring2 ' + searchString2);
                if (refundsMap.containsKey(searchString2)) {
                    Zuora__Refund__c zRefund = refundsMap.get(searchString2);
                    zRefund.Status__c = 'rejected';
                    if (!zRefundIDSet.contains(zRefund.ID)) {
                        refundsForUpdateList.add(zRefund);
                    }
                    zRefundIDSet.add(zRefund.ID);
                    so.Validation_Status__c = 'Passed';
                    so.Validation_Details__c = '';
                    invalidRecordCount--;
                    System.debug(interfaceId + ': tagging status as rejected: ' + searchString2);
                }
            }
        }
    }
  
    //Process Valid Records        
    // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
    Savepoint savepointBeforeDML = Database.setSavepoint();
    try{
        update refundsForUpdateList;
    }catch(Exception e){    
        // Execute Database Rollback 
        Database.rollback(savepointBeforeDML);
        System.debug('BT_AT_PPS057DX_RefundFileResponse DML operation failed.');
        dmlStatus = 'Failed';
        errorMessage  = e.getMessage();
        stackTrace = e.getStackTraceString();
    }                    

    //LogManager
    BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
    leg2sfLog.Interface_ID__c = interfaceId;
    leg2sfLog.Batch_Run_Date__c = recordsList[0].Batch_Run_Date__c;
    leg2sfLog.Total_Record_Count__c = recordsList.size();
    leg2sfLog.Valid_Record_Count__c = recordsList.size() - invalidRecordCount;
    leg2sfLog.Invalid_Record_Count__c = invalidRecordCount;
    leg2sfLog.DML_Status__c = '';
    leg2sfLog.Error_Message__c = '';
    leg2sfLog.Stack_Trace__c = '';
    leg2sfLog.Batch_Job_Id__c = recordsList[0].Batch_Job_Id__c;

    insert leg2sfLog;
}