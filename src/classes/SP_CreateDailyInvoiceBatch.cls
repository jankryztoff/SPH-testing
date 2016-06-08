/**
     * Class Name: SP_CreateDailyInvoiceBatch
     * @author: Kristine Balaoing
     * Date: 3-23-2016
     * Requirement/Project Name: CRSM Project
     * @description Batch Apex Class to Create Asia 1 Accounts
     * 
     */
     global class SP_CreateDailyInvoiceBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
        
        Boolean isApexJobSuccessful = true;
        Set<String> selectiveRecs = new Set<String>();
        Map<Id, List<Zuora__ZInvoice__c>> mapBAToInv = new Map<Id, List<Zuora__ZInvoice__c>>();
        Map<Id, Map<String, Decimal>> mapBAToAmtValuesMap = new Map<Id, Map<String, Decimal>>();
        Map<Id, Daily_Invoice__c> mapBAToDailyInv = new Map<Id, Daily_Invoice__c>();
        Map<Id, Zuora__ZInvoice__c> mapBAToFirstInv = new Map<Id, Zuora__ZInvoice__c>();
        Date refDate;
         //constructor for running date: today
         global SP_CreateDailyInvoiceBatch(){
            refDate = Date.today();
         }
         
         global SP_CreateDailyInvoiceBatch(Date inputDate){
            refDate = inputDate;
         }
         
         global SP_CreateDailyInvoiceBatch(Date inputDate, Set<String> targetedBAs){
            refDate = inputDate;
            selectiveRecs = targetedBAs;
         }
         
         global Database.QueryLocator start(Database.BatchableContext bc){
            
            String query;
            if(selectiveRecs.isEmpty()){
                query = 'SELECT Id, Name, Billing_Type__c, Zuora__Account__c, Zuora__Account__r.RecordTypeId, Zuora__LastInvoiceDate__c ';
                query += 'FROM Zuora__CustomerAccount__c WHERE Billing_Type__c = \'Full Prepaid\' ';
                query += 'AND Zuora__LastInvoiceDate__c = :refDate  AND Zuora__Account__r.RecordType.Name = \'Direct Corporate\' ';
            }else{
                query = 'SELECT Id, Name, Billing_Type__c, Zuora__Account__c, Zuora__Account__r.RecordTypeId, Zuora__LastInvoiceDate__c ';
                query += 'FROM Zuora__CustomerAccount__c WHERE Billing_Type__c = \'Full Prepaid\' ';
                query += 'AND Zuora__LastInvoiceDate__c = :refDate  AND Zuora__Account__r.RecordType.Name = \'Direct Corporate\' ';
                query +='AND Name IN : selectiveRecs ' ;
            }
            
            return Database.getQueryLocator(query);
         }
         
         global void execute(Database.BatchableContext BC, List<Zuora__CustomerAccount__c> billAcctsList ){
         
            Logger logger = new Logger(SP_CreateDailyInvoiceBatch.class.getName(), 'SP0064', BC.getJobId());
            Savepoint sp = Database.setSavepoint(); //no callout as of now double check if to include callouts in this
            
            try{
                List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>();
                List<Zuora__ZInvoice__c> zInvListToFilter = new List<Zuora__ZInvoice__c>();
                List<Zuora__ZInvoice__c> negInvoiceList = new List<Zuora__ZInvoice__c>();
                List<Zuora__ZInvoice__c> zInvoiceFinalList = new List<Zuora__ZInvoice__c>();
                List<Zuora__ZInvoice__c> ascInvList = new List<Zuora__ZInvoice__c>();
                List<Daily_Invoice__c> dailyInvListToBeUpdated = new List<Daily_Invoice__c>();
                List<Daily_Invoice__c> createdDailyInvoices = new List<Daily_Invoice__c>();
                List<Daily_Invoice__c> dailyInvList = new List<Daily_Invoice__c>();
                List<Invoice_Line_Item__c> invLineItemList = new List<Invoice_Line_Item__c>();
                Map<Id, Zuora__ZInvoice__c> mapInvoiceIdToInvoiceRec = new Map<Id, Zuora__ZInvoice__c>(); 
                Set<Id> invoiceIdSet = new Set<Id>();
                Set<Id> negativeInvoiceSet = new Set<Id>();
                Set<Zuora__CustomerAccount__c> dailyInvListToBeCreated = new Set<Zuora__CustomerAccount__c>();
                Zuora__ZInvoice__c invoiceRec;
                
                
                
                
                invoiceList = [SELECT Id, Zuora__BillingAccount__c, Zuora__InvoiceDate__c, Zuora__TotalAmount__c, Zuora__Balance2__c, Zuora__TaxExemptAmount__c, Zuora__PaymentAmount__c, Zuora__ZInvoice__c.Zuora__TaxAmount__c, Previous_Balance__c, CreatedDate FROM Zuora__ZInvoice__c 
                                WHERE Zuora__BillingAccount__c IN : billAcctsList AND Zuora__InvoiceDate__c = :refDate];  
                                
                dailyInvList = [SELECT Id, Invoice_Date__c, Total_Amt__c, Billing_Account__c FROM Daily_Invoice__c 
                                            WHERE Billing_Account__c IN :billAcctsList AND Invoice_Date__c = :refDate];
                
                for(Zuora__ZInvoice__c zInv : invoiceList){
                    if(mapBAToInv.containsKey(zInv.Zuora__BillingAccount__c)){
                        mapBAToInv.get(zInv.Zuora__BillingAccount__c).add(zInv);
                    }else{
                        mapBAToInv.put(zInv.Zuora__BillingAccount__c, new List<Zuora__ZInvoice__c>{zInv});
                    }
                    //for invoices with negative amount
                    if(zInv.Zuora__TotalAmount__c <0){
                        zInvListToFilter.add(zInv);
                    }
                }
                
                for(String baId : mapBAToInv.KeySet()){
                    //invPerBAList = mapBAToInv.get(baId);
                    for(Zuora__ZInvoice__c zInvoice : mapBAToInv.get(baId)){
                        if(mapBAToFirstInv.containsKey(baId)){
                            if(mapBAToFirstInv.get(baId).CreatedDate > zInvoice.CreatedDate){
                                mapBAToFirstInv.put(baId, zInvoice);
                            }
                        }else{
                            mapBAToFirstInv.put(baId, zInvoice);
                        }
                    }
                    
                }
                for(Zuora__ZInvoice__c zInvToFilter : zInvListToFilter){
                    invoiceIdSet.add(zInvToFilter.Id);
                    mapInvoiceIdToInvoiceRec.put(zInvToFilter.Id, zInvToFilter);
                }
                
                invLineItemList = [SELECT Id, Invoice_ID__c, Applied_To_Invoice_Item_ID__c, Charge_Amount__c FROM Invoice_Line_Item__c WHERE Invoice_ID__c IN :invoiceIdSet AND Applied_To_Invoice_Item_ID__c = null];
                
                for(Daily_Invoice__c dInv : dailyInvList){
                    mapBAToDailyInv.put(dInv.Billing_Account__c, dInv);
                }
                
                createdDailyInvoices = processDInvoice(billAcctsList);
                /*
                for(Zuora__CustomerAccount__c billAcc : billAcctsList){
                    if(mapBAToDailyInv.containsKey(billAcc.Id)){
                        dailyInvListToBeUpdated.add(mapBAToDailyInv.get(billAcc.Id));
                    }else{
                        dailyInvListToBeCreated.add(billAcc);
                    }
                }
                //create new daily invoice records
                if(dailyInvListToBeCreated.size()>0){
                    createdDailyInvoices = createDailyInvoice(dailyInvListToBeCreated);
                }
                
                if(dailyInvListToBeUpdated.size()>0){
                    updateDailyInvoice(dailyInvListToBeUpdated);
                }*/
                
                
                for(Daily_Invoice__c dailyInvoice : createdDailyInvoices){
                    mapBAToDailyInv.put(dailyInvoice.Billing_Account__c, dailyInvoice);
                }
                //Zuora invoice list to filter
                for(Invoice_Line_Item__c ili : invLineItemList){
                    if(ili.Charge_Amount__c > 0){
                        if(mapInvoiceIdToInvoiceRec.containsKey(ili.Invoice_ID__c)){
                            if(mapInvoiceIdToInvoiceRec.get(ili.Invoice_ID__c).Zuora__TotalAmount__c < 0){
                                negativeInvoiceSet.add(ili.Invoice_ID__c);
                            }
                        }
                    }
                }
                
                for(Id negInvId : negativeInvoiceSet){
                    if(mapInvoiceIdToInvoiceRec.containsKey(negInvId)){
                        invoiceRec = mapInvoiceIdToInvoiceRec.get(negInvId);
                        
                        invoiceRec.Is_CN_Processed__c = true;
                        
                        negInvoiceList.add(invoiceRec);
                    }
                }
                
                update negInvoiceList;
                
                for(Zuora__ZInvoice__c zInvoiceFinal : invoiceList){
                    if(mapBAToDailyInv.containsKey(zInvoiceFinal.Zuora__BillingAccount__c)){
                        zInvoiceFinal.Daily_Invoice__c = mapBAToDailyInv.get(zInvoiceFinal.Zuora__BillingAccount__c).Id;
                    }
                    
                    zInvoiceFinalList.add(zInvoiceFinal);
                }
                
                update zInvoiceFinalList;
            }catch(Exception e){
                Database.rollback(sp); //again as long as there's no callout
                logger.logBatchFailure(e, billAcctsList);
                logger.save();
                
                isApexJobSuccessful = false;
            }
            
        }
            
        global void finish(Database.BatchableContext BC){
            
            if(!isApexJobSuccessful){
                BatchJobHelper.updateJobStatus(BC.getJobId(), false);
            }else{
                BatchJobHelper.updateJobStatus(BC.getJobId(), true);
            }
        }
        
        public List<Daily_Invoice__c> processDInvoice(List<Zuora__CustomerAccount__c> billAccsSet){
            
            List<Daily_Invoice__c> dailyInvForInsertList = new List<Daily_Invoice__c>();
            List<Daily_Invoice__c> dailyInvForUpdateList = new List<Daily_Invoice__c>();
            Map<String, Decimal> mapAmountToValues;
            Boolean forInsert;
            
            for(Zuora__CustomerAccount__c zCustAcc : billAccsSet){
                Daily_Invoice__c dInvRec; 
                if(mapBAToDailyInv.containsKey(zCustAcc.Id)){
                    dInvRec = mapBAToDailyInv.get(zCustAcc.Id);
                    forInsert = false;
                }else{
                    dInvRec = new Daily_Invoice__c();
                    forInsert = true;
                }
                
                mapAmountToValues = new Map<String, Decimal>();
                
                if(mapBAToInv.containsKey(zCustAcc.Id)){
                    mapAmountToValues = computeTotalAmount(mapBAToInv.get(zCustAcc.Id));
                    mapBAToAmtValuesMap.put(zCustAcc.Id, mapAmountToValues);
                }
                
                if(forInsert){
                    dInvRec.Billing_Account__c = zCustAcc.Id;
                }
                dInvRec.Total_Amt__c = mapAmountToValues.get('Total Amount');
                dInvRec.Balance__c = mapAmountToValues.get('Total Balance');
                dInvRec.Tax_Amt__c = mapAmountToValues.get('Total Tax Amount');
                dInvRec.Tax_Exempt_Amt__c = mapAmountToValues.get('Total Tax Exempt Amount');
                dInvRec.Payment_Amt__c = mapAmountToValues.get('Total Payment');
                dInvRec.Invoice_Date__c = refDate;
                dInvRec.Prev_Bal__c = Decimal.valueOf(mapBAToFirstInv.get(zCustAcc.Id).Previous_Balance__c);
                System.debug('@!@' + forInsert);
                if(forInsert){
                    dailyInvForInsertList.add(dInvRec);
                    
                }else{
                    dailyInvForUpdateList.add(dInvRec);
                }
            }
            
            if(dailyInvForInsertList.size()>0){
                insert dailyInvForInsertList;
            }
            if(dailyInvForUpdateList.size()>0){
                update dailyInvForUpdateList;
            }

            
            return dailyInvForInsertList;
            
        }

        
        public Map<String, Decimal> computeTotalAmount(List<Zuora__ZInvoice__c> invoiceList){
            
            Map<String, Decimal> mapAmtToValues = new Map<String, Decimal>();
            Decimal totalAmount = 0;
            Decimal totalBalance = 0;
            Decimal totalTaxAmt = 0;
            Decimal totalTaxExemptAmt = 0;
            Decimal totalPaymentAmt = 0;
            for(Zuora__ZInvoice__c zInv : invoiceList){
                totalAmount = totalAmount + zInv.Zuora__TotalAmount__c;
                totalBalance = totalBalance + zInv.Zuora__Balance2__c;
                totalTaxAmt = totalTaxAmt + zInv.Zuora__TaxAmount__c;
                totalTaxExemptAmt = totalTaxExemptAmt + zInv.Zuora__TaxExemptAmount__c;
                totalPaymentAmt = totalPaymentAmt + zInv.Zuora__PaymentAmount__c;
            }
            
            mapAmtToValues.put('Total Amount' , totalAmount);
            mapAmtToValues.put('Total Balance' , totalBalance);
            mapAmtToValues.put('Total Tax Amount' , totalTaxAmt);
            mapAmtToValues.put('Total Tax Exempt Amount' , totalTaxExemptAmt);
            mapAmtToValues.put('Total Payment' , totalPaymentAmt);
            
            return mapAmtToValues;
        }
     
     }