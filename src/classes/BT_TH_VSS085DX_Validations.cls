/**
 * Trigger Name: BT_TH_VSS085DX_Validations
 * Author: Renino Niefes
 * Date: 2015/05/22
 * Project/Requirement: SPH Integration - VSS085DX Interface
 * Description: This trigger contains the business logic for VSS085DX interface.
 * History: 2015/05/22 Renino Niefes broken down the original code into multiple Trigger Handlers
 * History: 2015/09/24 Renino Niefes D-3606 RETROFIT ONLY. NO CODE CHANGE BELOW  
 */
 
 
 public class BT_TH_VSS085DX_Validations
{   
    String interfaceId = 'VSS085DX';
    integer invalidRecordCount = 0;
    String errorMessage = '';   
    String stackTrace = '';
    String dmlStatus = 'Success';
    
    Set<String> postalCodeSet = new Set<String>();
    Set<String> publicationCodeSet = new Set<String>();
    Set<String> vendorCodeSet = new Set<String>();
    Set<String> hdsSubsIDSet = new Set<String>();

    String vHdsRecipientId = null;
    String vSubscriberPostalCode = null;
    String vHdsContactId = null;
    String vRecipientPostalCode = null;
    String vHdsSubscriptionId = null;
    String vVendorGroup = null;
    String vVendorNumber = null;            
    String vPublicationCode = null;
    String vStartDate = null;
    String vStopDate = null;
    String vSubscriptionCopies = null;
    String vSubscriberEmail = null;
    String vRecipientEmail = null;
    
    Map<String, Singpost_Address__c> singpostMap = null;
    Map<String, Publication__c> publicationMap = null;
    Map<String, Account> vendorMap = null;
    
    public List<BT_CO_VSS_ImportVendorSubscription__c> validateRecords(List<BT_CO_VSS_ImportVendorSubscription__c> recordsList, BT_TH_VSS085DX_ManageMaps mapManager) {
        List<BT_CO_VSS_ImportVendorSubscription__c> validRecords = new List<BT_CO_VSS_ImportVendorSubscription__c>();
        Map<Decimal,String> errorMessageMap = BT_CO_INT_Utilities.getErrorMessageMap(interfaceId);
        
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            vSubscriberPostalCode = so.SubscriberPostalCode__c;
            vRecipientPostalCode = so.RecipientPostalCode__c;
            vVendorNumber = so.VendorNumber__c;         
            vPublicationCode = so.PublicationCode__c;
            
            if (StringUtility.validate(vSubscriberPostalCode).equalsIgnoreCase('0')) postalCodeSet.add(vSubscriberPostalCode);
            if (StringUtility.validate(vSubscriberPostalCode).equalsIgnoreCase('0')) postalCodeSet.add(vRecipientPostalCode);
            if (StringUtility.validate(vSubscriberPostalCode).equalsIgnoreCase('0')) publicationCodeSet.add(vPublicationCode);
            if (StringUtility.validate(vSubscriberPostalCode).equalsIgnoreCase('0')) vendorCodeSet.add(vVendorNumber);          
        }

        singpostMap = mapManager.getSingpostMap(postalCodeSet);
        publicationMap = mapManager.getPublicationMap();
        vendorMap = mapManager.getVendorMap(vendorCodeSet);
        
        Boolean isValid = true;
        String zErrorMsg = '';
        String zVALIDATION_CODE = '0';
        
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            vHdsRecipientId = so.HdsRecipientId__c;
            vSubscriberPostalCode = so.SubscriberPostalCode__c;
            vHdsContactId = so.HdsContactId__c;
            vRecipientPostalCode = so.RecipientPostalCode__c;
            vHdsSubscriptionId = so.HdsSubscriptionId__c;
            vVendorGroup = so.VendorGroup__c;
            vVendorNumber = so.VendorNumber__c;         
            vPublicationCode = so.PublicationCode__c;
            vStartDate = so.StartDate__c;
            vStopDate = so.StopDate__c;
            vSubscriptionCopies = so.SubscriptionCopies__c;
            vSubscriberEmail = so.SubscriberEmail__c;
            vRecipientEmail = so.RecipientEmail__c;
            zErrorMsg = '';
            zVALIDATION_CODE = '0';
            isValid = true;
            
            zVALIDATION_CODE = StringUtility.validate(vHdsRecipientId);
            zVALIDATION_CODE += StringUtility.validate(vSubscriberPostalCode); 
            zVALIDATION_CODE += StringUtility.validate(vHdsContactId); 
            zVALIDATION_CODE += StringUtility.validate(vRecipientPostalCode); 
            zVALIDATION_CODE += StringUtility.validate(vHdsSubscriptionId); 
            zVALIDATION_CODE += StringUtility.validate(vVendorGroup); 
            zVALIDATION_CODE += StringUtility.validate(vVendorNumber); 
            zVALIDATION_CODE += StringUtility.validate(vPublicationCode); 
            zVALIDATION_CODE += StringUtility.validate(vSubscriptionCopies); 
                            
            if(vStartDate!=null&&vStartDate.trim()!= ''&&DateUtility.isDateDD_MM_YYYY(vStartDate,'\\.') == false) {             
                zVALIDATION_CODE += '1';
            } else {
                zVALIDATION_CODE += '0';
                //Date dStartDate = DateUtility.convertDate(vStartDate, '.', 'DMY');
                //if (dStartDate<Date.Today()) {
                //  zVALIDATION_CODE += '1';
                //} else {
                //  zVALIDATION_CODE += '0';
                //}
            }

            if(vStopDate!=null&&vStopDate.trim()!= ''&&DateUtility.isDateDD_MM_YYYY(vStopDate,'\\.') == false) {                
                zVALIDATION_CODE += '1';
            } else {
                zVALIDATION_CODE += '0';
                //Date dStopDate = DateUtility.convertDate(vStopDate, '.', 'DMY');
                //if (dStopDate<Date.Today()) {
                //  zVALIDATION_CODE += '1';
                //} else {
                //  zVALIDATION_CODE += '0';
                //}             
            }
            
            if (vPublicationCode!=null&&vPublicationCode.trim()!=''&&publicationMap.containsKey(vPublicationCode)==false) {
                zVALIDATION_CODE += '1';
            } else {
                zVALIDATION_CODE += '0';
            }

            if (vSubscriberPostalCode!=null&&vSubscriberPostalCode.trim()!=''&&singpostMap.containsKey(vSubscriberPostalCode)==false) {
                zVALIDATION_CODE += '1';
            } else {
                zVALIDATION_CODE += '0';
            }

            if (vRecipientPostalCode!=null&&vRecipientPostalCode.trim()!=''&&singpostMap.containsKey(vRecipientPostalCode)==false) {
                zVALIDATION_CODE += '1';
            } else {
                zVALIDATION_CODE += '0';
            }

            if (vVendorNumber!=null&&vVendorNumber.trim()!=''&&vendorMap.containsKey(vVendorNumber)==false) {
                zVALIDATION_CODE += '1';
            } else {
                zVALIDATION_CODE += '0';
            }
            
            
            if (BT_CO_INT_Utilities.checkValidation(zVALIDATION_CODE)) {
                so.Validation_Status__c = 'Passed';
                validRecords.add(so);               
            } else {
                zErrorMsg = BT_CO_INT_Utilities.parseValidationCode(zVALIDATION_CODE, errorMessageMap);
                isValid = false;
                so.Validation_Status__c = 'Failed';
                so.Validation_Details__c = zVALIDATION_CODE + ':' + zErrorMsg;
                invalidRecordCount++;
                System.debug('VSS085DX: Validation Error: ' + zErrorMsg);               
            }
            
            
        }

        //LogManager
        BT_CO_LEG2SF_Log__c leg2sfLog = new BT_CO_LEG2SF_Log__c();
        leg2sfLog.Interface_ID__c = 'VSS085DX';
        leg2sfLog.Batch_Run_Date__c = recordsList[0].Batch_Run_Date__c;
        leg2sfLog.Total_Record_Count__c = recordsList.size();
        leg2sfLog.Valid_Record_Count__c = recordsList.size() - invalidRecordCount;
        leg2sfLog.Invalid_Record_Count__c = invalidRecordCount;
        leg2sfLog.DML_Status__c = '';
        leg2sfLog.Error_Message__c = '';
        leg2sfLog.Stack_Trace__c = '';
        leg2sfLog.Batch_Job_Id__c = recordsList[0].Batch_Job_Id__c;
   
        insert leg2sfLog;
        
        return validRecords;
    }
    
    
}