/*
 * Class Name: BT_AB_DATAPOOL_DeleteRecords
 * @author: Renino Niefes
 * Date: 2015/03/04
 * Project/Requirement: SPH Integration - For all outbound interfaces that requires data pool
 * @description 
 * 
 * History: 2015/03/04 Renino Niefes Created Skeletal Apex Batchable.  Transferred all the switch if statments from BatchRunRequest Trigger to this class
 *          2015/03/11 Michael Francisco - Added entry for SMS104DX interface
 */

global class BT_AB_DATAPOOL_DeleteRecords implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    global String interfaceId = '';
    
    global void setInterfaceId(String interfaceId) {
        this.interfaceId = interfaceId;
    }
    
    global String getInterfaceId() {
        return this.interfaceId;
    }
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = :interfaceID'; 
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<BA_INT_DATA_POOL__c> scope)
    { 
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            delete scope;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_DATAPOOL_DeleteRecords delete operation failed.');
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {   
        if(interfaceId == 'AGD042DX')
        {
            BT_AB_AGD042DX_AGDEInvoince batchJob = new BT_AB_AGD042DX_AGDEInvoince();
            Database.executeBatch(batchJob);
        }
        else if(interfaceId == 'ARM063DX')
        {
            BT_AB_ARM063DX_CreateAccountBatch batchJob = new BT_AB_ARM063DX_CreateAccountBatch();
            Database.executeBatch(batchJob);
        }              
        else if(interfaceId == 'ARM064DX')
        {
            BT_AB_ARM064DX_CreateCustomerAccount batchJob = new BT_AB_ARM064DX_CreateCustomerAccount();
            Database.executeBatch(batchJob);
        }        
        else if(interfaceId == 'ARM065DX')
        {
            BT_AB_ARM065DX_UpdateCustomerBatch batchJob = new BT_AB_ARM065DX_UpdateCustomerBatch();
            Database.executeBatch(batchJob);
        }        
        else if(interfaceId == 'ARM066DX')
        {
            BT_AB_ARM066DX_UpdateAccountBatch batchJob = new BT_AB_ARM066DX_UpdateAccountBatch();
            Database.executeBatch(batchJob);
        }        
        //START 11 March 2016 UD-3247 Kevin Evasco - Credit Note and Credit Adjustment Interfaces
        else if(interfaceId == 'ARM067DX')
        {
            BT_AB_ARM067DX_ImportCirculationOrders batchJob = new BT_AB_ARM067DX_ImportCirculationOrders();
            Database.executeBatch(batchJob);
        } 
        else if(interfaceId == 'ARM068DX')
        {
            BT_AB_ARM068DX_ExportCreditAdjustment batchJob = new BT_AB_ARM068DX_ExportCreditAdjustment();
            Database.executeBatch(batchJob);
        }       
        //END 11 March 2016 UD-3247 Kevin Evasco - Credit Note and Credit Adjustment Interfaces
        else if(interfaceId == 'CMI087DX')
        {
            BT_AB_CMI087DX_ExportVendorToPostal batchJob = new BT_AB_CMI087DX_ExportVendorToPostal();
            Database.executeBatch(batchJob);
        }        
        else if(interfaceId == 'CMI101DX')
        {
            BT_AB_CMI101DX_DirectSubNewspaper batchJob = new BT_AB_CMI101DX_DirectSubNewspaper();
            Database.executeBatch(batchJob);
        }        
        //START 1 December 2015 UD-4003 - Chained Data Purge Batches for DIR094DX
        else if(interfaceId == 'DIR094DX')
        {
            IntegrationDataPurgeBatch detailDataPurge = new IntegrationDataPurgeBatch(IntegrationDataPurgeBatch.DIR094DX_DETAIL_DATAPURGE, IntegrationDataPurgeBatch.DIR094DX_DETAIL_DATAPURGE_SQL);
            Database.executeBatch(detailDataPurge, 10000);
        }    
        //END 1 December 2015 UD-4003 - Chained Data Purge Batches for DIR094DX     
        else if(interfaceId == 'HDS036DX')
        {
            BT_AB_HDS036DX_DailyTempStopFile batchJob = new BT_AB_HDS036DX_DailyTempStopFile();
            Database.executeBatch(batchJob);
        }        
        else if(interfaceId == 'HDS037DX')
        {
            BT_AB_HDS037DX_DailyVendorSubscription batchJob = new BT_AB_HDS037DX_DailyVendorSubscription();
            Database.executeBatch(batchJob);
        }        
        else if(interfaceId == 'HDS038DX')
        {
            BT_AB_HDS038DX_DailyStartStopActionFile batchJob = new BT_AB_HDS038DX_DailyStartStopActionFile();
            Database.executeBatch(batchJob);
        }        
        else if(interfaceId == 'HDS039DX')
        {
            BT_AB_HDS039DX_SubscriptionIssuesFile batchJob = new BT_AB_HDS039DX_SubscriptionIssuesFile();
            Database.executeBatch(batchJob);
        }        
        else if(interfaceId == 'HDS039DX_CR')
        {
            BT_AB_HDS039DX_CR_SubscriptionIssuesFile batchJob = new BT_AB_HDS039DX_CR_SubscriptionIssuesFile();
            Database.executeBatch(batchJob);
        }        
        else if(interfaceId == 'HDS039DX_DB')
        {
            BT_AB_HDS039DX_DR_SubscriptionIssuesFile batchJob = new BT_AB_HDS039DX_DR_SubscriptionIssuesFile();
            Database.executeBatch(batchJob);
        }        

        else if(interfaceId == 'INET052DX')
        {
            BT_AB_INET052DX_STNewsletter batchJob = new BT_AB_INET052DX_STNewsletter();
            Database.executeBatch(batchJob);
        }        
        else if(interfaceId == 'INET054DX')
        {
            //BT_AB_INET054DX_ShareInvestorChargeOut batchJob = new BT_AB_INET054DX_ShareInvestorChargeOut();
            BT_AB_INET054DX_BR_SIOP_ChargeOut batchJob = new BT_AB_INET054DX_BR_SIOP_ChargeOut();
            Database.executeBatch(batchJob);
        }        
        else if(interfaceId == 'MIRO055DX')
        {
            BT_AB_MIRO055DX_VendorCreditingFile batchJob = new BT_AB_MIRO055DX_VendorCreditingFile();
            Database.executeBatch(batchJob,4);
        }        
        else if(interfaceId == 'PPS056DX')
        {
            BT_AB_PPS056DX_EshopRegistrationRefund batchJob = new BT_AB_PPS056DX_EshopRegistrationRefund();
            Database.executeBatch(batchJob);
        }        
        else if(interfaceId == 'REW031DX')
        {
            BT_AB_REW031DX_DirectSubscriberRewards batchJob = new BT_AB_REW031DX_DirectSubscriberRewards();
            Database.executeBatch(batchJob);
        }        
        else if(interfaceId == 'REW040DX')
        {
            BT_AB_REW040DX_SubscriberRewardsIntFile batchJob = new BT_AB_REW040DX_SubscriberRewardsIntFile();
            Database.executeBatch(batchJob);
        }    
                    
        else if(interfaceId == 'SAP072DX')
        {
            BT_AB_SAP072DX_AdjustmentInterfaceToSAP batchJob = new BT_AB_SAP072DX_AdjustmentInterfaceToSAP();
            Database.executeBatch(batchJob);
        }        
        else if(interfaceId == 'VBS103DX')
        {
            BT_AB_VBS103DX_VendorCreditingDebiting batchJob = new BT_AB_VBS103DX_VendorCreditingDebiting();
            Database.executeBatch(batchJob);
        }        
        else if(interfaceId == 'VSS088DX')
        {
            BT_AB_VSS088DX_ExportVendorToPostal batchJob = new BT_AB_VSS088DX_ExportVendorToPostal();
            Database.executeBatch(batchJob);
        }        
        else if(interfaceId == 'VSS089DX')
        {
            BT_AB_VSS089DX_ExportZoneToPostal batchJob = new BT_AB_VSS089DX_ExportZoneToPostal();
            Database.executeBatch(batchJob);
        }        
        else if(interfaceId == 'VSS090DX')
        {
            BT_AB_VSS090DX_ExportVendorSubscription batchJob = new BT_AB_VSS090DX_ExportVendorSubscription();
            Database.executeBatch(batchJob);
        }        
        else if(interfaceId == 'VSS093DX')
        {
            BT_AB_VSS093DX_ExportCustomerStartStop batchJob = new BT_AB_VSS093DX_ExportCustomerStartStop();
            Database.executeBatch(batchJob);
        }
        else if(interfaceid == 'ESH1001DX')
        {
            BT_AB_ESH1001DX_ESHOPPublication esh1001dx = new BT_AB_ESH1001DX_ESHOPPublication('ESH1001DX');
            Database.executeBatch(esh1001dx );
        }
        else if(interfaceid == 'ESH1002DX')
        {
            BT_AB_ESH1002DX_ESHOPProduct esh1002dx = new BT_AB_ESH1002DX_ESHOPProduct('ESH1002DX');
            Database.executeBatch(esh1002dx );
        }
        else if(interfaceid == 'ESH1003DX')
        {
            BT_AB_ESH1003DX_ESHOPPackage esh1003dx = new BT_AB_ESH1003DX_ESHOPPackage('ESH1003DX');
            Database.executeBatch(esh1003dx );
        }
        else if(interfaceid == 'ESH1004DX')
        {
            BT_AB_ESH1004DX_ESHOPPromotion esh1004dx = new BT_AB_ESH1004DX_ESHOPPromotion('ESH1004DX');
            Database.executeBatch(esh1004dx );
        }
        else if(interfaceid == 'ESH1005DX')
        {
            BT_AB_ESH1005DX_ESHOPGift esh1005dx = new BT_AB_ESH1005DX_ESHOPGift('ESH1005DX');
            Database.executeBatch(esh1005dx );
        }
        else if(interfaceid == 'ARM067DX_2')
        {            
            BT_AB_ARM067DX_2_ImportCirculationOrders arm06dx2 = new BT_AB_ARM067DX_2_ImportCirculationOrders();
            Database.executeBatch(arm06dx2);
        } //START MD-54 2015-03-13 Michael Francisco - Added entry for SMS104DX interface 
        else if(interfaceid == 'SMS104DX')
        {            
            BT_AB_SMS104DX_SMSBulkOutboundFile sms104dx = new BT_AB_SMS104DX_SMSBulkOutboundFile();
            Database.executeBatch(sms104dx);
        } //END MD-54 2015-03-13 Michael Francisco
        //START 25 February 2016 NCR015-5 Kevin Evasco - Packing Label CR 
        else if(interfaceid == 'CMI102DX')
        {            
            BT_AB_CMI102DX_ExportPackingLabel cmi102dx = new BT_AB_CMI102DX_ExportPackingLabel();
            Database.executeBatch(cmi102dx);
        }
        //END 25 February 2016 NCR015-5 Kevin Evasco - Packing Label CR 
        //START 25 February 2016 NCR016 Kevin Evasco - Packing Label CR 
        else if(interfaceid == 'DIR105DX')
        {            
            BT_AB_DIR105DX_BuildingCodeValidation dir105dx = new BT_AB_DIR105DX_BuildingCodeValidation();
            Database.executeBatch(dir105dx);
        }
        //END 25 February 2016 NCR016 Kevin Evasco - Packing Label CR 
        //START 28 March 2016 UD-3207 Kevin Evasco - Added ARM105DX
        else if(interfaceid == 'ARM105DX')
        {            
            BT_AB_ARM105DX_ExportInvoice arm105dx = new BT_AB_ARM105DX_ExportInvoice();
            Database.executeBatch(arm105dx);
        }
        else if(interfaceid == 'AGD106DX')
        {            
            BT_AB_AGD106DX_ExportInvoice arm105dx = new BT_AB_AGD106DX_ExportInvoice();
            Database.executeBatch(arm105dx);
        }
        //END 28 March 2016 UD-3207 Kevin Evasco - Added ARM105DX
    }
}