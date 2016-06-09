/*
 * Class Name: BT_AB_ARM105DX_ExportDailyInvoice
 * @author: Kevin Evasco
 * Date: 21 March 2016
 * Project/Requirement: SPH Integration - ARM105DX Interface for UD-3207
 * @description This class populates BA_INT_DATA_POOL__c for ARM105DX
 */


global class BT_AB_ARM105DX_ExportDailyInvoice implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    global final String interfaceId = 'ARM105DX';
    
    global class ArmsInvoiceMaster{
        global String referenceNumber = '';
        global Date documentDate = null;
        global Date postingDate = null;
        global Date baselineDate = null;
        global Decimal totalAmount = 0.0;
        global String interfaceIdX = 'ARM105DX';
        global String jobId = '1';
        global String groupId = 'Master';
        global Date runForDate = Date.today();
        global DateTime insertTime = DateTime.now();
        
        global String getExportData(){
            return referenceNumber + ',' + documentDate + ',' + postingDate + ',' + baselineDate + ',' + totalAmount;
        }
    }
    
    global class ArmsInvoiceDetail{
        global String vAccountNumber = null;  //Account Number
        global String vSalesType = null; //Sales Type 
        global String vReasonCode = null;
        global String vPublicationCode = null;//Publication 
        global String vDepotGroup = null;//Depot Group
        global String vDepotGroupDescription = null;//Depot Group Description 
        global String vOutletCustomerName = null;//Outlet Customer Name
        global String vSynonym = null;//Synonym 
        global String vClientNo = null;//Client No 
        global String vNegativeDiscountIndicator = null;//Negative Discount Indicator
        global String vFillers1 = null;//Filler 
        global String vNoOfCopies = '1';//No Of Copies
        global String vIssueNo = null;//Issue No 
        global Date vIssueDate = null;//Issue Date
        global Date vStartDate = null;//Start Date
        global Date vStopDate = null;//Stop Date
        global Decimal vInsertionAmount = 0;//Insertion Amount
        global Decimal vPaginationAmount = 0;//Pagination Amount
        global Decimal vNRAAmount = 0;//NRA Amount 
        global Decimal vFreightCharge = 0;//Freight Charge
        global String vFreightType = null;//Freight Type
        global Decimal vGstRate = 0;//GST Rate
        global Decimal vGstAmount = 0;//GST Amount
        global Decimal vGrossAmount = 0;//Gross Amount
        global Decimal vGrossSales = 0;//Gross Sales
        global Decimal vNetAmountAfterGST = 0; //Net Amount After GST 
        global Decimal vAdjustmentToCommisionAmount = 0;//Adjustment to Commission Amount
        global Decimal vCommission = 0;//Commission 
        global Decimal vDiscount = 0;//Discount
        global Date vDueRate = null;//Due Date
        global String vRemark1 = null;//Remark1
        global String vApprovedBy = null;//Approved By
        global String vReferenceDocNo = null;//Reference Doc No (for CN)
        global String vSignIndicator = null;//Sign Indicator
        global String vGlAccount = null;//GL account 
        global Decimal vHandlingFee = 0;//Handling Fee
        global Decimal vDeliveryFee = 0;//Delivery Fee
        global Decimal vMiscAmount = 0;//Miscellaneous Amount
        global String vBundleCode = null;//Bundle Code
        global String interfaceIdX = 'ARM105DX';
        global String jobId = '1';
        global String groupId = 'Detail';
        global Date runForDate = Date.today();
        global DateTime insertTime = DateTime.now();
        
        global String getExportData(){
            String exportData = '';
            exportData += StringUtility.quoteReplaceStr(vAccountNumber) + ',';  //Account Number
            exportData += StringUtility.quoteReplaceStr(vSalesType) + ','; //Sales Type 
            exportData += StringUtility.quoteReplaceStr(vReasonCode) + ',';
            exportData += StringUtility.quoteReplaceStr(vPublicationCode) + ',';//Publication 
            exportData += StringUtility.quoteReplaceStr(vDepotGroup) + ',';//Depot Group
            exportData += StringUtility.quoteReplaceStr(vDepotGroupDescription) + ',';//Depot Group Description 
            exportData += StringUtility.quoteReplaceStr(vOutletCustomerName) + ',';//Outlet Customer Name
            exportData += StringUtility.quoteReplaceStr(vSynonym) + ',';//Synonym 
            exportData += StringUtility.quoteReplaceStr(vClientNo) + ',';//Client No 
            exportData += StringUtility.quoteReplaceStr(vNegativeDiscountIndicator) + ',';//Negative Discount Indicator
            exportData += StringUtility.quoteReplaceStr(vFillers1) + ',';//Filler 
            exportData += vNoOfCopies + ',';//No Of Copies
            exportData += vIssueNo + ',';//Issue No 
            exportData += vIssueDate + ',';//Issue Date
            exportData += vStartDate + ',';//Start Date
            exportData += vStopDate + ',';//Stop Date
            exportData += vInsertionAmount + ',';//Insertion Amount
            exportData += vPaginationAmount + ',';//Pagination Amount
            exportData += vNRAAmount + ',';//NRA Amount 
            exportData += vFreightCharge + ',';//Freight Charge
            exportData += vFreightType + ',';//Freight Type
            exportData += vGstRate + ',';//GST Rate
            exportData += vGstAmount + ',';//GST Amount
            exportData += vGrossAmount + ',';//Gross Amount
            exportData += vGrossSales + ',';//Gross Sales
            exportData += vNetAmountAfterGST + ','; //Net Amount After GST 
            exportData += vAdjustmentToCommisionAmount + ',';//Adjustment to Commission Amount
            exportData += vCommission + ',';//Commission 
            exportData += vDiscount + ',';//Discount
            exportData += vDueRate + ',';//Due Date
            exportData += StringUtility.quoteReplaceStr(vRemark1) + ',';//Remark1
            exportData += StringUtility.quoteReplaceStr(vApprovedBy) + ',';//Approved By
            exportData += StringUtility.quoteReplaceStr(vReferenceDocNo) + ',';//Reference Doc No (for CN)
            exportData += vSignIndicator + ',';//Sign Indicator
            exportData += StringUtility.quoteReplaceStr(vGlAccount) + ',';//GL account 
            exportData += vHandlingFee + ',';//Handling Fee
            exportData += vDeliveryFee + ',';//Delivery Fee
            exportData += vMiscAmount + ',';//Miscellaneous Amount
            exportData += StringUtility.quoteReplaceStr(vBundleCode) + ',';//Bundle Code
            return exportData;
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {        
        String query = '';
        system.debug('***** QUERY LOCATOR: '+[
            SELECT 
            To_ARMS_Time__c,
            ARMS_Invoice_ID__c,
            Id,
            Name,
            Billing_Account__r.Zuora__Account__r.AccountNumber,
            Billing_Account__r.ARMS_Account_Number__c,
            Billing_Account__r.Billing_Contact__r.Id,
            Invoice_Date__c, 
            Total_Amt__c

            FROM Daily_Invoice__c

            WHERE
            To_ARMS_Time__c = null AND 
            ARMS_Invoice_ID__c != null AND 
            Total_Amt__c > 0 AND
            (Billing_Account__r.Zuora__Account__r.RecordTypeId = :ConstantsSLB.getKeyId(GlobalVariableClass.ACCDIRCORP) AND
            Billing_Account__r.Billing_Type__c = :GlobalVariableClass.BILLING_TYPE_FULL_PRE)
        ]);
        return Database.getQueryLocator(
        [
            SELECT 
            To_ARMS_Time__c,
            ARMS_Invoice_ID__c,
            Id,
            Name,
            Billing_Account__r.Zuora__Account__r.AccountNumber,
            Billing_Account__r.ARMS_Account_Number__c,
            Billing_Account__r.Billing_Contact__r.Id,
            Invoice_Date__c, 
            Total_Amt__c,
			Prev_Bal__c
			
            FROM Daily_Invoice__c

            WHERE
            To_ARMS_Time__c = null AND 
            ARMS_Invoice_ID__c != null AND 
            Total_Amt__c > 0 AND
            (Billing_Account__r.Zuora__Account__r.RecordTypeId = :ConstantsSLB.getKeyId(GlobalVariableClass.ACCDIRCORP) AND
            Billing_Account__r.Billing_Type__c = :GlobalVariableClass.BILLING_TYPE_FULL_PRE)
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Daily_Invoice__c> scope)
    {       
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        Map<String,Zuora__ZInvoice__c> dailyInvoice_zInvoiceMap = new Map<String,Zuora__ZInvoice__c>();
        Map<String,Zuora__ZInvoice__c> zInvoiceMap = new Map<String,Zuora__ZInvoice__c>();
        Map<String,List<Invoice_Line_Item__c>> dailyInvoice_invoiceLineItems_map = new Map<String,List<Invoice_Line_Item__c>>();
       

        Set<Id> dailyInvoiceIdSet = new Set<Id>();
        Set<String> invoiceSet = new Set<String>();
        
        for(Daily_Invoice__c dailyInvoice : scope) {
            dailyInvoice.To_ARMS_Time__c = DateTime.now();
            dailyInvoiceIdSet.add(dailyInvoice.Id);
        }
        
        List<Zuora__ZInvoice__c> invoiceList = 
            [SELECT 
            Daily_Invoice__c,
            Id,
            Zuora__BillingAccount__r.Zuora__Balance__c,
            Zuora__DueDate__c,
            Zuora__External_Id__c,
            Zuora__GeneratedDate__c,
            Zuora__InvoiceDate__c, 
            Zuora__PaymentAmount__c,
            Zuora__TaxAmount__c,
            Zuora__TotalAmount__c,
            Zuora__BillingAccount__r.ARMS_Account_Number__c

            FROM Zuora__ZInvoice__c

            WHERE Daily_Invoice__c IN :dailyInvoiceIdSet];
            

        
        List<Other__c> gstSettingList = [SELECT Id, Value__c FROM Other__c WHERE Name = 'GST'];
        Decimal vGstRateX = 0;
        
        if(gstSettingList != null && gstSettingList.size() > 0) {
            Other__c gstSetting = gstSettingList.get(0);
            try{
                vGstRateX = (Decimal.valueOf(gstSetting.Value__c) / 100).setScale(2);                     
                vGstRateX = vGstRateX.setScale(4);                       
            } catch(Exception e) {}
        }
        
        //START 26 October 2015 UD-3056 Kevin Evasco - ARMS Interface Timestamp patch
        for (Zuora__ZInvoice__c record2 : invoiceList)
        {
            record2.ARMS_Interface_Timestamp__c = DateTime.now();
               
            if(record2.Daily_Invoice__c != null)
				dailyInvoice_zInvoiceMap.put(record2.Daily_Invoice__c,record2);
			zInvoiceMap.put(record2.Zuora__External_Id__c, record2);
			invoiceSet.add(record2.Zuora__External_Id__c);
  
        }
        //END 26 October 2015 UD-3056 Kevin Evasco - ARMS Interface Timestamp patch
        //system.debug('****invoiceSet: '+ invoiceSet);
        List<Invoice_Line_Item__c> invoiceItemsList = new List<Invoice_Line_Item__c>();
        if (invoiceSet != null && invoiceSet.size() > 0) {
            invoiceItemsList = [
                SELECT Accounting_Code__c, Applied_To_Invoice_Item_ID__c, Charge_Amount__c, Charge_Date__c, Charge_Description__c, Charge_ID__c, Charge_Name__c,
                    Charge_Number__c, Id, Id__c, Invoice_ID__c, Name, OwnerId, Processing_Type__c, Product_Description__c, Product_ID__c, Product_Name__c,
                    Quantity__c, Rate_Plan_Charge_ID__c, Revenue_Recognition_Code__c, Revenue_Recognition_Start_Date__c, Revenue_Recognition_Trigger_Condition__c,
                    Service_End_Date__c, Service_Start_Date__c, SKU__c, Subscription_ID__c, Subscription_Number__c, Tax_Amount__c, Tax_Code__c, Tax_Exempt_Amount__c,
                    Tax_Mode__c, Unit_Price__c, UOM__c
                FROM Invoice_Line_Item__c
                WHERE Invoice_ID__c in :invoiceSet
                AND Charge_Amount__c != 0
                ORDER BY Invoice_ID__c
            ];          
        }
        //system.debug('****invoiceItemsList: '+ invoiceItemsList);
        for(Invoice_Line_Item__c invoiceLineItem : invoiceItemsList) {
            Zuora__ZInvoice__c invoiceRecord = zInvoiceMap.get(invoiceLineItem.Invoice_ID__c);
            String dailyInvoiceId = '';
            if(invoiceRecord != null)
                dailyInvoiceId = invoiceRecord.Daily_Invoice__c;
                
            if(dailyInvoice_invoiceLineItems_map.get(dailyInvoiceId) == null)
                dailyInvoice_invoiceLineItems_map.put(dailyInvoiceId, new List<Invoice_Line_Item__c>());
            dailyInvoice_invoiceLineItems_map.get(dailyInvoiceId).add(invoiceLineItem);
            }
        
        Set<String> productIdSet = new Set<String>();
        if (invoiceItemsList != null && invoiceItemsList.size() >0) {
            for (Invoice_Line_Item__c item : invoiceItemsList) {
                if (item.Product_ID__c != null) {
                    productIdSet.add(item.Product_ID__c);           
                } 
            }           
        }
        
        List<zqu__ZProduct__c> productsList = new  List<zqu__ZProduct__c>();
        if (productIdSet != null && productIdSet.size() > 0) {
            productsList = [
                SELECT Id, Name, ProductCode__c, ProductSubType__c, ProductType__c, zqu__SKU__c, ProductFamily__c, zqu__ZuoraId__c FROM zqu__ZProduct__c
                WHERE zqu__ZuoraId__c IN :productIdSet
            ];          
        }

        Map<String,zqu__ZProduct__c> zProductMap = new Map<String,zqu__ZProduct__c>();
        for (zqu__ZProduct__c zProd : productsList) {
            if (zProd.zqu__ZuoraId__c != null) {
                zProductMap.put(zProd.zqu__ZuoraId__c,zProd);         
            }   
        }
        
        for(Daily_Invoice__c dailyInvoice : scope){
            Zuora__ZInvoice__c zi = dailyInvoice_zInvoiceMap.get(dailyInvoice.Id);
            if(zi != null){
                Decimal previousBalance = dailyInvoice.Prev_Bal__c; 
                Decimal remainingCreditBalance = previousBalance * -1;
                
                //20-April-2016 : Nitin Khanna : D-4682 : Begin
                if( previousBalance > zi.Zuora__TotalAmount__c)
                    continue;
                //20-April-2016 : Nitin Khanna : D-4682 : End
                
                //Insert Invoice Master Record
                ArmsInvoiceMaster aIM = new ArmsInvoiceMaster();
                aIM.referenceNumber = dailyInvoice.ARMS_Invoice_ID__c;
                aIM.documentDate = dailyInvoice.Invoice_Date__c;
                aIM.postingDate  = dailyInvoice.Invoice_Date__c;
                aIM.baselineDate = dailyInvoice.Invoice_Date__c;
                aIM.totalAmount  = previousBalance + dailyInvoice.Total_Amt__c;
                //END 15 April 2016 D-4682 Kevin Evasco - Apply credit balance to the Invoice Total Amount to get the total outstanding amount
                
                BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
                
                datapoolRecord.Name             = aIM.interfaceIdX;
                datapoolRecord.job_id__c        = aIM.jobId;
                datapoolRecord.group_id__c      = aIM.groupId;
                datapoolRecord.run_for_date__c  = aIM.runForDate;    
                datapoolRecord.insert_time__c   = aIM.insertTime; 
                datapoolRecord.export_data__c   = aIM.getExportData();
                
                datapoolList.add(datapoolRecord);
                
                List<ArmsInvoiceDetail> lstNP = new List<ArmsInvoiceDetail>();
                List<ArmsInvoiceDetail> lstMAG = new List<ArmsInvoiceDetail>();
                //20-April-2016 : Nitin Khanna : D-4682 : Begin
                List<ArmsInvoiceDetail> lstJP = new List<ArmsInvoiceDetail>();
                //20-April-2016 : Nitin Khanna : D-4682 : END
                
                Integer intTemp = 1;
                
                    List<Invoice_Line_Item__c> items = dailyInvoice_invoiceLineItems_map.get(dailyInvoice.Id);
					if(items!=null) {
						for (Invoice_Line_Item__c item : items){
							
							//Insert Invoice Detail Record
							ArmsInvoiceDetail aID = new ArmsInvoiceDetail();
							
							if (zi!=null){
								aID.vAccountNumber = dailyInvoice.Billing_Account__r.ARMS_Account_Number__c;
								aID.vSynonym = dailyInvoice.Billing_Account__r.Zuora__Account__r.AccountNumber;
								aID.vDueRate = zi.Zuora__DueDate__c;
								aID.vRemark1 = dailyInvoice.Billing_Account__r.Zuora__Account__r.AccountNumber;
								aID.vGlAccount = item.Accounting_Code__c;
								aID.vGstRate = vGstRateX;
								if(intTemp == 1){
									datapoolRecord.export_data__c  +=  ',' + zi.Zuora__BillingAccount__r.ARMS_Account_Number__c ;
									intTemp++;
								}
							}
							
							aID.vStartDate = item.Service_Start_Date__c;
							aID.vStopDate = item.Service_End_Date__c;
							aID.vGstAmount = item.Tax_Amount__c;
							aID.vGrossAmount = 0;
							aID.vNetAmountAfterGST = (item.Charge_Amount__c + item.Tax_Amount__c);
							aID.vDiscount = 0;
								
							if (zProductMap.containsKey(item.Product_ID__c)) {
								zqu__ZProduct__c product = zProductMap.get(item.Product_ID__c);
								if (product != null) {
									//20-April-2016 : Nitin Khanna : D-4682 : Begin
									if ( remainingCreditBalance != 0 ){
										aID.vSalesType = 'S';
										aID.vPublicationCode = 'JP';
										lstJP.add(aID);
									}//20-April-2016 : Nitin Khanna : D-4682 : END
									else if (product.ProductSubType__c=='Newspaper' || product.productcode__c == GlobalVariableClass.PRODUCT_CODE_DELCHG) { //START/END 09 November 2015 UD-3219 Kevin Evasco - Corrected Delivery Product Code 
										aID.vSalesType = 'S';
										aID.vPublicationCode = 'NP';
										lstNP.add(aID);
									} else {
										aID.vSalesType = 'N';
										aID.vPublicationCode = 'MAG';
										lstMAG.add(aID);
									}                           
								}
							}
						}
					}
                ArmsInvoiceDetail aIDTempNP = new ArmsInvoiceDetail();
                aIDTempNP = (lstNP.size() > 0 ? lstNP.get(0) : null);
                ArmsInvoiceDetail aIDTempMAG = new ArmsInvoiceDetail();
                aIDTempMAG = (lstMAG.size() > 0 ? lstMAG.get(0) : null);
                ArmsInvoiceDetail aIDTempJP = new ArmsInvoiceDetail();
                //20-April-2016 : Nitin Khanna : D-4682 : BEGIN
                aIDTempJP = (lstJP.size() > 0 ? lstJP.get(0) : null);
                //20-April-2016 : Nitin Khanna : D-4682 : END
                
                if(lstNP.size() > 0){
                    for(Integer i = 1; i<lstNP.size(); i++){
                        aIDTempNP.vGstAmount += lstNP.get(i).vGstAmount;
                        aIDTempNP.vNetAmountAfterGST += lstNP.get(i).vNetAmountAfterGST;
                    }
                }
                
                if(lstMAG.size() > 0){
                    for(Integer i = 1; i<lstMAG.size(); i++){
                        aIDTempMAG.vGstAmount += lstMAG.get(i).vGstAmount;
                        aIDTempMAG.vNetAmountAfterGST += lstMAG.get(i).vNetAmountAfterGST;
                    }
                }
                
                //20-April-2016 : Nitin Khanna : D-4682 : BEGIN
                if(lstJP.size() > 0){
                    for(Integer i = 1; i<lstJP.size(); i++){
                        aIDTempJP.vGstAmount += lstJP.get(i).vGstAmount;
                        aIDTempJP.vNetAmountAfterGST += lstJP.get(i).vNetAmountAfterGST;
                    }
                    aIDTempJP.vNetAmountAfterGST -= remainingCreditBalance;
                }
                //20-April-2016 : Nitin Khanna : D-4682 : END
                
                if(aIDTempNP != null && aIDTempMAG != null && aIDTempNP.vNetAmountAfterGST < aIDTempMAG.vNetAmountAfterGST && aIDTempNP.vNetAmountAfterGST < 0){
                    aIDTempMAG.vNetAmountAfterGST += aIDTempNP.vNetAmountAfterGST;
                    aIDTempMAG.vGstAmount += aIDTempNP.vGstAmount;
                    aIDTempNP = null;
                }else if(aIDTempNP != null && aIDTempMAG != null && aIDTempNP.vNetAmountAfterGST > aIDTempMAG.vNetAmountAfterGST && aIDTempMAG.vNetAmountAfterGST < 0){
                    aIDTempNP.vGstAmount += aIDTempMAG.vGstAmount;
                    aIDTempNP.vNetAmountAfterGST += aIDTempMAG.vNetAmountAfterGST;
                    aIDTempMAG = null;
                }
                
                //20-April-2016 : Nitin Khanna : D-4682 : BEGIN
                if(aIDTempJP != null){
                    BA_INT_DATA_POOL__c datapoolRecord2 = new BA_INT_DATA_POOL__c();
                    
                    datapoolRecord2.Name            = aIDTempJP.interfaceIdX;
                    datapoolRecord2.job_id__c       = aIDTempJP.jobId;
                    datapoolRecord2.group_id__c     = aIDTempJP.groupId;
                    datapoolRecord2.run_for_date__c = aIDTempJP.runForDate;    
                    datapoolRecord2.insert_time__c  = aIDTempJP.insertTime; 
                    datapoolRecord2.export_data__c  = aIDTempJP.getExportData();
                    
                    datapoolList.add(datapoolRecord2);
                }
                //20-April-2016 : Nitin Khanna : D-4682 : END
                
                if(aIDTempNP != null){
                    BA_INT_DATA_POOL__c datapoolRecord2 = new BA_INT_DATA_POOL__c();
                    
                    datapoolRecord2.Name            = aIDTempNP.interfaceIdX;
                    datapoolRecord2.job_id__c       = aIDTempNP.jobId;
                    datapoolRecord2.group_id__c     = aIDTempNP.groupId;
                    datapoolRecord2.run_for_date__c = aIDTempNP.runForDate;    
                    datapoolRecord2.insert_time__c  = aIDTempNP.insertTime; 
                    datapoolRecord2.export_data__c  = aIDTempNP.getExportData();
                    
                    datapoolList.add(datapoolRecord2);
                }
                if(aIDTempMAG != null){
                    BA_INT_DATA_POOL__c datapoolRecord2 = new BA_INT_DATA_POOL__c();
                    
                    datapoolRecord2.Name            = aIDTempMAG.interfaceIdX;
                    datapoolRecord2.job_id__c       = aIDTempMAG.jobId;
                    datapoolRecord2.group_id__c     = aIDTempMAG.groupId;
                    datapoolRecord2.run_for_date__c = aIDTempMAG.runForDate;    
                    datapoolRecord2.insert_time__c  = aIDTempMAG.insertTime; 
                    datapoolRecord2.export_data__c  = aIDTempMAG.getExportData();
                    
                    datapoolList.add(datapoolRecord2);
                }
            }
        }
        
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
            Database.update(scope, false); //START 26 October 2015 UD-3056 Kevin Evasco - ARMS Interface Timestamp patch
            Database.update(invoiceList, false);
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_ARM105DX_ExportDailyInvoice insert operation failed.');
        }
    }

    global void finish(Database.BatchableContext BC)
    {
        //Get the batch run date
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);            
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');
                
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