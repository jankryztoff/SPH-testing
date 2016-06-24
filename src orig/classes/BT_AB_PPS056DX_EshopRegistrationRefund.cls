/*
 * Class Name: BT_AB_PPS056DX_EshopRegistrationRefund 
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - PPS056DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for PPS056DX batch job. Used together with BT_AS_PPS056DX_EshopRegistrationRefund Schedulable
 * 
 * History: 08/26/2014 Kevin Evasco Created Skeletal Apex Batchable
 * History: 09/30/2014 Renino Niefes Added code implementation
 * History: 11/03/2014 Renino Niefes changed criteria in soql (new refunds only)
 */


global class BT_AB_PPS056DX_EshopRegistrationRefund implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    // SOQL Query in getting the interface primary object
    // TO-DO: Update query based on requirements
    //global final String query = 'SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = \'PPS056DX Sample Source\'';    
    global final String interfaceId = 'PPS056DX';       
  
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = :interfaceId];
        delete resultList; 
        //START HotFix 27-July-2015 Added by Nitin - Updated Query
    
        String query = 'SELECT ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.name, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Country_Name__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.RecordType.developername, ';
            //local addresses
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Unit_Number__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Level_Number__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Street_Name__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Building_Name__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Block_House_Number__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Postal_Code_Text__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Postal_Code__r.Service_Number__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Postal_Code__r.name, ';
            //overseas
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Address_1__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Address_2__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Address_3__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Address_4__c, ';
            //internal
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Department__r.Department_Name__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Division_Code__r.Department_Name__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.City__r.City_Name__c, ';
            //airlines
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Airline_Number__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Flight_Number_1__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Flight_Number_2__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Country__r.code__c, ';
            
            query += '    Payee__c, ';
            query += '    Mail_Address_Line_1__c, ';
            query += '    Mail_Address_Line_2__c, ';
            query += '    Mail_Address_Line_3__c, ';
            query += '    Mail_Address_Line_4__c, ';
            query += '    Telephone__c, ';
            query += '    Bank_Code__c, ';
            query += '    Bank_Account_Number__c, ';
            query += '    Payment_Amount__c, ';
            query += '    Clearing_Country_Code__c, ';
            query += '    Payment_Type__c, ';
            query += '    Customer_A_C_Type__c, ';
            query += '    Status__c, ';
            query += '    Zuora__Amount__c, ';
            query += '    Zuora__BillingAccount__r.Id, ';
            query += '    Zuora__Account__r.Account_Auto_Number__c, ';
            query += '    Zuora__Account__r.Name, ';
            
            //contact details
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Mobile_Number__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.Mobile_Number_2__c, ';
            query += '    Zuora__BillingAccount__r.Billing_Contact__r.HomePhone__c ';  
            query += ' FROM ';
            query += '    Zuora__Refund__c';
            query += ' WHERE ';
            query += '    (Status__c = \'new\' OR Status__c = null)';  //replace this with 'new' later on
            query += '    AND Zuora__RefundMethodType__c = \'Check\'';
            //query += '    AND createdDate = TODAY';   
        //End HotFix 27-July-2015 Added by Nitin - Updated Query
        return Database.getQueryLocator(query);
    }
    
    /* @description Executes the business logic and populates BA_INT_DATA_POOL__c with new records based on the interface requirements.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {       
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        List<Zuora__Refund__c> refundList = new List<Zuora__Refund__c>();
        for(sObject record : scope)
        {  
            Zuora__Refund__c refundRecord = (Zuora__Refund__c)record;
            
            String exportData = '';    
            //START HotFix 27-July-2015 Added by Nitin - Updated exportData
            exportData += refundRecord.Zuora__Account__r.name + ',';
            
            if(refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.recordType.developerName == 'Local'){
                String poBox = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Postal_Code__r.Service_Number__c;
                String unitNo = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Unit_Number__c;
                String levelNo = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Level_Number__c;
                String houseNo = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Block_House_Number__c;
                String buildingName = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Building_Name__c;
                String street = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Street_Name__c;
                String country = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Country_Name__c;
                String pCode = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Postal_Code__r.name;
                 //KRITHIKA D UD-1829 START Address_line_1 has to be mandatory D-3567 
                List<String> AdressLine = new List<String>();  
                String Address_line_1 = (poBox == null ? '' : poBox) + (houseNo == null ? '' : houseNo) + ' ' + (street == null ? '' : street)  ;
                String Address_line_2 = (levelNo == null ? '' : levelNo) + ' ' + (unitNo == null ? '' : unitNo);
                String Address_line_3 = (buildingName == null ? '' : buildingName) ;
                String Address_line_4 = (country == null ? '' : country)  + ' ' + (pCode == null ? '' : pCode) ;
                
                if(!String.isBlank(Address_line_1)){
                    AdressLine.add((Address_line_1.contains(',') ? Address_line_1.replace(',','') : Address_line_1));     
                }
                if(!String.isBlank(Address_line_2)){
                    AdressLine.add((Address_line_2.contains(',') ? Address_line_2.replace(',','') : Address_line_2));     
                }
                if(!String.isBlank(Address_line_3)){
                    AdressLine.add((Address_line_3.contains(',') ? Address_line_3.replace(',','') : Address_line_3));     
                }
                if(!String.isBlank(Address_line_4)){
                    AdressLine.add((Address_line_4.contains(',') ? Address_line_4.replace(',','') : Address_line_4));     
                }
                if(String.isBlank(Address_line_1) && String.isBlank(Address_line_2) && String.isBlank(Address_line_3) && String.isBlank(Address_line_4)){
                    system.debug('Address is blank');
                    refundRecord.Status__c = 'failed';
                    continue;
                }
                system.debug('AddressLinesize=========>'+AdressLine.size());
                if(AdressLine.size() != 4){
                    if(AdressLine.size() == 0){
                        system.debug('AddressLinesizezero=========>'+AdressLine.size());
                        refundRecord.Status__c = 'failed';
                        continue;
                    }
                    if(AdressLine.size() == 1){
                        system.debug('AddressLinesizeone=========>'+AdressLine.size());
                        AdressLine.add('');
                        AdressLine.add('');
                        AdressLine.add('');
                    }
                    if(AdressLine.size() == 2){
                        system.debug('AddressLinesizetwo=========>'+AdressLine.size());
                        AdressLine.add('');
                        AdressLine.add('');
                    }
                    if(AdressLine.size() == 3){
                        system.debug('AddressLinesizethree=========>'+AdressLine.size());
                        AdressLine.add('');
                    }
                }
                system.debug('AddressLinesize=========>'+AdressLine.size());
                for(String tempAdd :AdressLine) {
                    exportData += tempAdd + ',';
                    system.debug('adding comma u stupid ');
                     system.debug('expotdatainsideloop================>'+exportData ); 
                }   
                system.debug('expotdata================>'+exportData ); 
                    //KRITHIKA D UD-1829  Address_line_1 has to be mandatory D-3567  
            }
            
            if(refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.recordType.developerName == 'Overseas'){
                String addr1 = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Address_1__c;
                String addr2 = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Address_2__c;
                String addr3 = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Address_3__c;
                String addr4 = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Address_4__c;        
            
                exportData += (addr1 == null? '' :addr1)  + ',';
                exportData += (addr2 == null? '' :addr2)  + ',';
                exportData += (addr3 == null? '' :addr3)  + ',';
                exportData += (addr4 == null? '' :addr4)  + ',';
            }
            
            if(refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.recordType.developerName == 'Internal'){
                String sectionNo = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c;
                String deptNo = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Department__r.Department_Name__c;
                String div = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Division_Code__r.Department_Name__c;
                String cCode = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c;
                String countryCode = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Country__r.code__c;
            
                exportData += (sectionNo == null ? '' : sectionNo)  + ',';
                exportData += (deptNo == null ? '' : deptNo)  + ',';
                exportData += (div == null ? '' : div)  + ',';
                exportData += (cCode == null ? '' : cCode) + ' ' + (countryCode == null ? '' : countryCode)  + ',';
            }
            
            if(refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.recordType.developerName == 'Airline'){
                String fltNo1 = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Flight_Number_1__c;
                String fltNo2 = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Flight_Number_2__c;
                String airNo = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.Airline_Number__c;
                String city = refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.City__r.City_Name__c ;
                
                exportData +=  (fltNo1 == null ? '' : fltNo1) + ',';
                exportData += (fltNo2 == null ? '' : fltNo2)  + ',';
                exportData += (airNo == null ? '' : airNo)  + ',';
                exportData += (city == null ? '' : city)  + ',';
            }
            //KRITHIKA DHARMARAJAN UD-1829 START 26/08/2015 D-3567
            if(refundRecord.Zuora__BillingAccount__r.Billing_Contact__r.Address__r.recordType.developerName == null){ 
              // exportData += ',' + ',' + ',' + ',' ;
              refundRecord.Status__c = 'failed';
              continue;
            }
            //KRITHIKA DHARMARAJAN UD-1829 END 26/08/2015 D-3567
            exportData += refundRecord.Zuora__Account__r.name + ',';
            exportData += refundRecord.Mail_Address_Line_1__c + ',';
            exportData += refundRecord.Mail_Address_Line_2__c + ',';
            exportData += refundRecord.Mail_Address_Line_3__c + ',';
            exportData += refundRecord.Mail_Address_Line_4__c + ',';
            exportData += getTelephoneNumber(refundRecord) + ',';
            exportData += refundRecord.Bank_Code__c + ',';
            exportData += refundRecord.Bank_Account_Number__c + ',';
            exportData += getPaymentAmount(refundRecord) + ',';
            exportData += refundRecord.Clearing_Country_Code__c + ',';
            exportData += refundRecord.Payment_Type__c + ',';
            exportData += refundRecord.Zuora__Account__r.Account_Auto_Number__c;    
            //End HotFix 27-July-2015 Added by Nitin - Updated exportData
            
            refundRecord.Status__c = 'issued';
            refundList.add(refundRecord);
            
           // Prepare Data Pool information here
            BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
            datapoolRecord.Name = interfaceId;
            datapoolRecord.job_id__c = '1';
            datapoolRecord.group_id__c = 'Detail';
            datapoolRecord.run_for_date__c = Date.today();      
            datapoolRecord.insert_time__c = DateTime.now(); 
            datapoolRecord.export_data__c = exportData;
            
            datapoolList.add(datapoolRecord);
        }
  
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
            update refundList;
        }
        catch(Exception e)
        {       
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_PPS056DX_EshopRegistrationRefund insert operation failed.');
        }
    }
    
    //Start HotFix 27-July-2015 Added by Nitin - Implemented getTelephoneNumber and getPaymentAmount methods    
    private String getTelephoneNumber(Zuora__Refund__c zrRecord) {
        String zResult = '';
        String zMobile = (String) zrRecord.Zuora__BillingAccount__r.Billing_Contact__r.Mobile_Number__c;
        String zHandphoneNumber = (String) zrRecord.Zuora__BillingAccount__r.Billing_Contact__r.Mobile_Number_2__c;
        String zHomeNumber = (String) zrRecord.Zuora__BillingAccount__r.Billing_Contact__r.HomePhone__c;
        
        
        if (zMobile != null && zMobile.length() > 0) {
            zResult = zMobile;
        } else if (zHandphoneNumber != null && zHandphoneNumber.length() > 0) {
            zResult = zHandphoneNumber;
        } else if (zHomeNumber != null && zHomeNumber.length() > 0) {
            zResult = zHomeNumber;
        }         
        return zResult;
    }
    
    private String getPaymentAmount(Zuora__Refund__c zrRecord) { 
        String zResult = '';
        Decimal pAmount = (Decimal) zrRecord.Payment_Amount__c;
        Decimal zAmount = (Decimal) zrRecord.Zuora__Amount__c;
        
        if (pAmount != null && pAmount >= 0) {
            zResult = String.valueOf(pAmount);
        } else if (zAmount != null && zAmount >= 0) {
            zResult = String.valueOf(zAmount);
        }
        
        return zResult; 
    }
    //End HotFix 27-July-2015 Added by Nitin - Implemented getTelephoneNumber and getPaymentAmount methods
    
    /*
     * @description A method which executes the final actions of the class.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
    global void finish(Database.BatchableContext BC)
    {
          //Get the batch run date
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);            
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');
                
        //System.debug('*********************** inside final'+ this.query);
        BatchServiceFacade a1F = new BatchServiceFacade();
        BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
        serviceRequestVO.setJobStatus(0);
        serviceRequestVO.setJobID(interfaceId);
        serviceRequestVO.setJobDate(myDate);
        System.debug('################ before');
        a1F.delegateBatchCall(serviceRequestVO);
        System.debug('################ after');        

        //Update Batch Run Request's End Time
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(interfaceId);
    }
}