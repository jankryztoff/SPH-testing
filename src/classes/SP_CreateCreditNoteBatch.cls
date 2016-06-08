/*
 * Class Name: SP_CreateCreditNoteBatch 
 * @author: Sherwin Puli
 * Date: 29-Feb-2016
 * Project/Requirement: UD-3253 CR for credit note
 * @description This class creates credit notes and credit note item, batch code: SP061.
 * Note: This should be run first before the Credit Note PDF Generation batch SP043.
 */ 
global class SP_CreateCreditNoteBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
   
    Boolean isAdhoc = false;
    Boolean isApexJobSuccessful = true;
    Set<Id> failedRecs = new Set<Id>();
    //Start UD-2549 16-Mar-2016 Added By S.Puli - enhancement for credit note batch SP061
    String cancelText = GlobalVariableClass.STATUS_CANCELLED;
    //End UD-2549 16-Mar-2016 Added By S.Puli - enhancement for credit note batch SP061
    
    global SP_CreateCreditNoteBatch(){
        
    }
    
    global SP_CreateCreditNoteBatch(Set<Id> invoiceIds){
        this.failedRecs = invoiceIds;
        this.isAdhoc = true;
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){

        String query = '';
        //Start UD-2549 16-Mar-2016 Added By S.Puli - enhancement for credit note batch SP061
		//Start D-4648 08-Apr-2016 Added By S.Puli
        if(isAdhoc){   
            query = 'SELECT Id,Zuora__TotalAmount__c,Zuora__TaxExemptAmount__c,Zuora__TaxAmount__c,Is_CN_Processed__c,Zuora__InvoiceDate__c,';
            query += ' Zuora__Zuora_Id__c,Zuora__BillingAccount__c,Zuora__BillingAccount__r.Billing_Type__c, Zuora__AdjustmentAmount__c,';
            query += ' Zuora__Status__c, Zuora__AmountWithoutTax__c, InvoicePaymentFailure__c';
            query += ' FROM Zuora__ZInvoice__c ';
            query += ' WHERE (Zuora__TotalAmount__c < 0 OR InvoicePaymentFailure__c = \'Y\') AND Id IN :failedRecs';
        }else{
            query = 'SELECT Id,Zuora__TotalAmount__c,Zuora__TaxExemptAmount__c,Zuora__TaxAmount__c,Is_CN_Processed__c,Zuora__InvoiceDate__c,';
            query += ' Zuora__Zuora_Id__c,Zuora__BillingAccount__c,Zuora__BillingAccount__r.Billing_Type__c, Zuora__AdjustmentAmount__c,';
            query += ' Zuora__Status__c, Zuora__AmountWithoutTax__c, InvoicePaymentFailure__c';
            query += ' FROM Zuora__ZInvoice__c ';
            query += ' WHERE (Zuora__TotalAmount__c < 0 OR InvoicePaymentFailure__c = \'Y\')';
            query += ' AND Is_CN_Processed__c = false'; 
        }
		//End D-4648 08-Apr-2016 Added By S.Puli
        //End UD-2549 16-Mar-2016 Added By S.Puli - enhancement for credit note batch SP061
        system.debug('query: '+ query);
        return Database.getQueryLocator(query);
        
    }

    global void execute(Database.BatchableContext BC, List<Zuora__ZInvoice__c> scope){

        Logger logger = new Logger(SP_CreateCreditNoteBatch.class.getName(), 'SP061', BC.getJobID());
        List<Invoice_Line_Item__c> invoiceLineItemList = new List<Invoice_Line_Item__c>();
        List<Invoice_Line_Item__c> invoiceLineItemForFullPreList = new List<Invoice_Line_Item__c>();
        Map<String, Zuora__ZInvoice__c> zuoraIdToInvoice_Map = new Map<String, Zuora__ZInvoice__c>();
        List<Zuora__ZInvoice__c> validInvoice_List = new List<Zuora__ZInvoice__c>();
        List<Credit_Note__c> creditNote_List = new List<Credit_Note__c>();
        Map<Id, Id> invoiceIdToCreditId_Map = new Map<Id, Id>();
        Map<String, List<Invoice_Line_Item__c>> invoiceToInvLines_Map = new Map<String, List<Invoice_Line_Item__c>>();
        Map<String, Credit_Note_Item__c> tempInvToCreLine_Map = new Map<String, Credit_Note_Item__c>();
        Map<Id, Id> invLineToSubsId_Map = new Map<Id, Id>();
        Set<String> invFullZuoraId_Set = new Set<String>();
        List<Zuora__ZInvoice__c> invoiceForFullPrep_List = new List<Zuora__ZInvoice__c>();
        Map<Id, String> subsIdToInvZuoraID_Map = new Map<Id, String>();
        Map<String, Zuora__ZInvoice__c> invoiceZuoraIdToRecord_Map = new Map<String, Zuora__ZInvoice__c>();
        Set<Id> reccBillAccIds = new Set<Id>();
        List<Zuora__ZInvoice__c> reccInvoices_List = new List<Zuora__ZInvoice__c>();
        Map<Id, List<Zuora__ZInvoice__c>> billAccToAllInvoice_Map = new Map<Id, List<Zuora__ZInvoice__c>>();
        List<Zuora__ZInvoice__c> invalidInvoice_List = new List<Zuora__ZInvoice__c>();
        Set<String> invalidInvoice_Set = new Set<String>();
        Map<String, Zuora__ZInvoice__c> invoiceWithLineItems = new Map<String, Zuora__ZInvoice__c>();
        //Start UD-2549 16-Mar-2016 Added By S.Puli - enhancement for credit note batch SP061
        List<Zuora__ZInvoice__c> fullAdjAndCancelInvoice_List = new List<Zuora__ZInvoice__c>();
        Other__c gstSetting = Other__c.getInstance('GST');
        Map<Id, Credit_Note__c> invoiceIdToCreditRecord_Map = new Map<Id, Credit_Note__c>();
        List<Credit_Note_Item__c> creditNoteItem_List = new List<Credit_Note_Item__c>();
        //End UD-2549 16-Mar-2016 Added By S.Puli - enhancement for credit note batch SP061
        
        try{
            
            for(Zuora__ZInvoice__c invRec : scope){
                //Start UD-2549 16-Mar-2016 Added By S.Puli - enhancement for credit note batch SP061
                if(invRec.Zuora__Zuora_Id__c <> null){
                    if(invRec.Zuora__TotalAmount__c < 0){
                        zuoraIdToInvoice_Map.put(invRec.Zuora__Zuora_Id__c, invRec);
                    }
                    if(invRec.InvoicePaymentFailure__c == 'Y'){//Start/End D-4648 08-Apr-2016 Added By S.Puli
                        fullAdjAndCancelInvoice_List.add(invRec);
                        invRec.Is_CN_Processed__c = true;
                        invoiceWithLineItems.put(invRec.Zuora__Zuora_Id__c, invRec);
                    }
                }
                //End UD-2549 16-Mar-2016 Added By S.Puli - enhancement for credit note batch SP061
            }
            //populate invoiceLineItemList
            invoiceLineItemList = [SELECT id, name, Invoice_ID__c, Charge_Amount__c, Tax_Amount__c, UOM__c, ID__c, Applied_To_Invoice_Item_ID__c,
                                    Charge_Name__c,Subscription__c, Tax_Exempt_Amount__c,Subscription__r.Zuora__CustomerAccount__c,
                                    Subscription__r.Billing_Type__c 
                                    FROM Invoice_Line_Item__c 
                                    WHERE Invoice_ID__c IN: zuoraIdToInvoice_Map.keySet()
                                    AND Applied_To_Invoice_Item_ID__c = null];
            
            //filter invoiceLineItemList
            //Start UD-2549 16-Mar-2016 Added By S.Puli - enhancement for credit note batch SP061
            if(!invoiceLineItemList.isEmpty()){
                for(Invoice_Line_Item__c iLi : invoiceLineItemList){
                    //populate invoiceToInvLines_Map
                    if(iLi.Invoice_ID__c <> null){
                        
                        if(!invoiceWithLineItems.containsKey(iLi.Invoice_ID__c)){
                            Zuora__ZInvoice__c inv = zuoraIdToInvoice_Map.get(iLi.Invoice_ID__c);
                            inv.Is_CN_Processed__c = true;
                            invoiceWithLineItems.put(iLi.Invoice_ID__c, inv);
                        }
                        
                        if(iLi.Charge_Amount__c < 0){
                            if(iLi.Charge_Name__c.length() > 14){
                                if(!iLi.Charge_Name__c.startsWithIgnoreCase(GlobalVariableClass.GOODWILL_CREDIT)){
                                    if(!invoiceToInvLines_Map.containsKey(iLi.Invoice_ID__c)){
                                        invoiceToInvLines_Map.put(iLi.Invoice_ID__c, new List<Invoice_Line_Item__c>{iLi});
                                    }else{
                                        invoiceToInvLines_Map.get(iLi.Invoice_ID__c).add(iLi);
                                    }
                                }
                                if(iLi.Subscription__r.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE){
                                    invLineToSubsId_Map.put(iLi.Id, iLi.Subscription__c);
                                }
                                if(iLi.Subscription__r.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_PRE || iLi.Subscription__r.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_POST){
                                    reccBillAccIds.add(iLi.Subscription__r.Zuora__CustomerAccount__c);
                                }
                            }else{
                                if(!invoiceToInvLines_Map.containsKey(iLi.Invoice_ID__c)){
                                    invoiceToInvLines_Map.put(iLi.Invoice_ID__c, new List<Invoice_Line_Item__c>{iLi});
                                }else{
                                    invoiceToInvLines_Map.get(iLi.Invoice_ID__c).add(iLi);
                                }
                                if(iLi.Subscription__r.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE){
                                    invLineToSubsId_Map.put(iLi.Id, iLi.Subscription__c);
                                }
                                if(iLi.Subscription__r.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_PRE || iLi.Subscription__r.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_POST){
                                    reccBillAccIds.add(iLi.Subscription__r.Zuora__CustomerAccount__c);
                                }
                            }
                        }
                        //filter invocie with positive charges
                        else if(iLi.Charge_Amount__c > 0){
                            invalidInvoice_Set.add(iLi.Invoice_ID__c);
                        }
                    }
                }
                
                //Populate validInvoice_List
                if(invoiceToInvLines_Map.size()>0){
                    for(String invZuoraId : invoiceToInvLines_Map.keySet()){
                        if(zuoraIdToInvoice_Map.containsKey(invZuoraId)){
                            if(!invalidInvoice_Set.contains(invZuoraId)){
                                validInvoice_List.add(zuoraIdToInvoice_Map.get(invZuoraId));
                            }
                        }
                    }
                }
                
                
                
                if(!validInvoice_List.isEmpty()){
                    for(Zuora__ZInvoice__c invoiceRec : validInvoice_List){
                        Credit_Note__c cn = new Credit_Note__c();
                        cn.Billing_Account__c = invoiceRec.Zuora__BillingAccount__c;
                        cn.Document_Date__c = invoiceRec.Zuora__InvoiceDate__c;
                        cn.Source_Invoice__c = invoiceRec.Id;
                        if(invoiceRec.Zuora__TaxAmount__c < 0){
                            cn.Tax_Rate__c = Decimal.ValueOf(gstSetting.Value__c);
                        }else{
                            cn.Tax_Rate__c = 0;
                        }
                        creditNote_List.add(cn);                    
                    }
                }
                
            }
            //End UD-2549 16-Mar-2016 Added By S.Puli - enhancement for credit note batch SP061
            
            //query invoice line item for full prepaid subscription
            invoiceLineItemForFullPreList = [SELECT id, name, Invoice_ID__c, Charge_Amount__c, Tax_Amount__c, UOM__c, ID__c, Applied_To_Invoice_Item_ID__c,
                                            Charge_Name__c,Subscription__c, Subscription__r.Billing_Type__c, Tax_Exempt_Amount__c    
                                            FROM Invoice_Line_Item__c 
                                            WHERE Subscription__c IN: invLineToSubsId_Map.values()
                                            AND Applied_To_Invoice_Item_ID__c = null
                                            AND Subscription__r.Billing_Type__c = :GlobalVariableClass.BILLING_TYPE_FULL_PRE
                                            AND Charge_Amount__c > 0];
                                            
            if(!invoiceLineItemForFullPreList.isEmpty()){
                for(Invoice_Line_Item__c invLineFull : invoiceLineItemForFullPreList){
                    invFullZuoraId_Set.add(invLineFull.Invoice_ID__c);
                    subsIdToInvZuoraID_Map.put(invLineFull.Subscription__c, invLineFull.Invoice_ID__c);
                }
                
                if(!invFullZuoraId_Set.isEmpty()){
                    invoiceForFullPrep_List = [SELECT Id,Zuora__TotalAmount__c,Zuora__TaxExemptAmount__c,Zuora__TaxAmount__c,Is_CN_Processed__c,
                                                Zuora__InvoiceDate__c,Zuora__Zuora_Id__c,Zuora__BillingAccount__c 
                                                FROM Zuora__ZInvoice__c 
                                                WHERE Zuora__Zuora_Id__c IN: invFullZuoraId_Set];
                    
                    if(!invoiceForFullPrep_List.isEmpty()){
                        for(Zuora__ZInvoice__c invFull : invoiceForFullPrep_List){
                            invoiceZuoraIdToRecord_Map.put(invFull.Zuora__Zuora_Id__c, invFull);
                        }
                    }
                }
            }
            
            //query reccuring invoices for reccuring subscription using reccBillAccIds
            if(!reccBillAccIds.isEmpty()){
                reccInvoices_List = [SELECT Id, Zuora__BillingAccount__c, Zuora__InvoiceDate__c,Zuora__TotalAmount__c,CreatedDate 
                                    FROM Zuora__ZInvoice__c
                                    WHERE Zuora__BillingAccount__c IN :reccBillAccIds 
                                    AND CreatedDate = LAST_90_DAYS ORDER BY CREATEDDATE DESC];
                if(!reccInvoices_List.isEmpty()){
                    for(Zuora__ZInvoice__c invRecc : reccInvoices_List){
                        if(!billAccToAllInvoice_Map.containsKey(invRecc.Zuora__BillingAccount__c)){
                            billAccToAllInvoice_Map.put(invRecc.Zuora__BillingAccount__c, new List<Zuora__ZInvoice__c>{invRecc});
                        }else{
                            billAccToAllInvoice_Map.get(invRecc.Zuora__BillingAccount__c).add(invRecc);
                        }
                    }   
                }
            }
            //Start UD-2549 16-Mar-2016 Added By S.Puli - enhancement for credit note batch SP061
            //create Credit Note for full invoice adjustment and cancelled invoices
            if(!fullAdjAndCancelInvoice_List.isEmpty()){
                for(Zuora__ZInvoice__c otherInv : fullAdjAndCancelInvoice_List){
                    Credit_Note__c cn = new Credit_Note__c();
                        cn.Billing_Account__c = otherInv.Zuora__BillingAccount__c;
                        cn.Document_Date__c = Date.today();
                        cn.Source_Invoice__c = null;
                        if(otherInv.Zuora__TaxAmount__c > 0){
                            cn.Tax_Rate__c = Decimal.ValueOf(gstSetting.Value__c);
                        }else{
                            cn.Tax_Rate__c = 0;
                        }
                        creditNote_List.add(cn);
                        invoiceIdToCreditRecord_Map.put(otherInv.Id, cn);
                }
            }
            
            //Insert Credit Note records
            if(!creditNote_List.isEmpty()){
                insert creditNote_List;
                
                for(Credit_Note__c cnRec : creditNote_List){
                    invoiceIdToCreditId_Map.put(cnRec.Source_Invoice__c, cnRec.Id);
                }               
            }
            
            //create Credit Note Item records
            if(!fullAdjAndCancelInvoice_List.isEmpty()){
                for(Zuora__ZInvoice__c otherInv : fullAdjAndCancelInvoice_List){
                    Credit_Note_Item__c cni = new Credit_Note_Item__c();
					//Start UD-2549 Added By S.Puli - Credit note batch enhancement
					if(invoiceIdToCreditRecord_Map.containsKey(otherInv.Id)){
						cni.Credit_Note__c = invoiceIdToCreditRecord_Map.get(otherInv.Id).Id;
					}else{
						logger.log(false, 'Full Adjusttment or Cancel Invoice not in Map', string.valueOf(otherInv.Id));
					}
					//End UD-2549 Added By S.Puli - Credit note batch enhancement
                    cni.Invoice__c = otherInv.Id;
                    cni.Amt_Before_Tax__c = MATH.ABS(otherInv.Zuora__AmountWithoutTax__c);
                    cni.Tax_Amt__c = MATH.ABS(otherInv.Zuora__TaxAmount__c);
                    cni.Tax_Exempt_Amt__c = MATH.ABS(otherInv.Zuora__TaxExemptAmount__c);
                    cni.Amt_After_Tax__c = MATH.ABS(otherInv.Zuora__TotalAmount__c);
                    
                    creditNoteItem_List.add(cni);
                }
            }
            
            if(!creditNoteItem_List.isEmpty()){
                insert creditNoteItem_List;
            }
            //End UD-2549 16-Mar-2016 Added By S.Puli - enhancement for credit note batch SP061
            
            if(!validInvoice_List.isEmpty()){
                for(Zuora__ZInvoice__c invRecord : validInvoice_List){
                    if(invRecord.Zuora__BillingAccount__r.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE){
                        if(invoiceToInvLines_Map.containsKey(invRecord.Zuora__Zuora_Id__c)){
                            for(Invoice_Line_Item__c invLi : invoiceToInvLines_Map.get(invRecord.Zuora__Zuora_Id__c)){
                                if(subsIdToInvZuoraID_Map.containsKey(invLi.Subscription__c)){
                                    String tempInvKey = '';
                                    tempInvKey = subsIdToInvZuoraID_Map.get(invLi.Subscription__c);
                                    if(!tempInvToCreLine_Map.containsKey(tempInvKey)){
                                        Credit_Note_Item__c cni = new Credit_Note_Item__c();
                                        //Start UD-2549 Added By S.Puli - Credit note batch enhancement
										if(invoiceIdToCreditId_Map.containsKey(invRecord.Id)){
											cni.Credit_Note__c = invoiceIdToCreditId_Map.get(invRecord.Id);
										}else{
											logger.log(false, 'Full prepaid Invoice Id not in Map', string.valueOf(invRecord.Id));
										}
										if(invoiceZuoraIdToRecord_Map.containsKey(subsIdToInvZuoraID_Map.get(invLi.Subscription__c))){
											cni.Invoice__c = invoiceZuoraIdToRecord_Map.get(subsIdToInvZuoraID_Map.get(invLi.Subscription__c)).Id;
										}else{
											logger.log(false, 'Full prepaid Invoice Zuora Id not in Map', subsIdToInvZuoraID_Map.get(invLi.Subscription__c));
										}
										//End UD-2549 Added By S.Puli - Credit note batch enhancement
                                        cni.Amt_Before_Tax__c = MATH.ABS(invLi.Charge_Amount__c);
                                        cni.Tax_Amt__c = MATH.ABS(invLi.Tax_Amount__c);
                                        cni.Tax_Exempt_Amt__c = MATH.ABS(invLi.Tax_Exempt_Amount__c);
                                        cni.Amt_After_Tax__c = cni.Amt_Before_Tax__c + cni.Tax_Amt__c;
                                        
                                        tempInvToCreLine_Map.put(tempInvKey, cni);
                                    }else{
                                        
                                        Credit_Note_Item__c cni = tempInvToCreLine_Map.get(tempInvKey);
                                        cni.Amt_Before_Tax__c += MATH.ABS(invLi.Charge_Amount__c);
                                        cni.Tax_Amt__c += MATH.ABS(invLi.Tax_Amount__c);
                                        cni.Tax_Exempt_Amt__c += MATH.ABS(invLi.Tax_Exempt_Amount__c);
                                        cni.Amt_After_Tax__c = cni.Amt_Before_Tax__c + cni.Tax_Amt__c;
                                        
                                        tempInvToCreLine_Map.put(tempInvKey, cni);
                                    }
                                }
                            }
                        }
                    }else{
                        if(invoiceToInvLines_Map.containsKey(invRecord.Zuora__Zuora_Id__c)){
                            for(Invoice_Line_Item__c invLi : invoiceToInvLines_Map.get(invRecord.Zuora__Zuora_Id__c)){
                                if(!tempInvToCreLine_Map.containsKey(invRecord.Zuora__Zuora_Id__c)){
                                    Credit_Note_Item__c cni = new Credit_Note_Item__c();
                                    //Start UD-2549 Added By S.Puli - Credit note batch enhancement
									if(invoiceIdToCreditId_Map.containsKey(invRecord.Id)){
										cni.Credit_Note__c = invoiceIdToCreditId_Map.get(invRecord.Id);
									}else{
										logger.log(false, 'Recurring Invoice Id not in Map', string.valueOf(invRecord.Id));
									}
									//End UD-2549 Added By S.Puli - Credit note batch enhancement
                                    cni.Amt_Before_Tax__c = MATH.ABS(invLi.Charge_Amount__c);
                                    cni.Tax_Amt__c = MATH.ABS(invLi.Tax_Amount__c);
                                    cni.Tax_Exempt_Amt__c = MATH.ABS(invLi.Tax_Exempt_Amount__c);
                                    cni.Amt_After_Tax__c = cni.Amt_Before_Tax__c + cni.Tax_Amt__c;
                                    //Populate Invoice field if Credit Amount is less than or equal to Last Invoice Total Amount
                                    cni.Invoice__c = null;
									//Start UD-2549 Added By S.Puli - Credit note batch enhancement
									if(billAccToAllInvoice_Map.containsKey(invRecord.Zuora__BillingAccount__c)){
										if(billAccToAllInvoice_Map.get(invRecord.Zuora__BillingAccount__c).size() > 1){
											if(cni.Amt_After_Tax__c <= billAccToAllInvoice_Map.get(invRecord.Zuora__BillingAccount__c)[1].Zuora__TotalAmount__c){
												cni.Invoice__c = billAccToAllInvoice_Map.get(invRecord.Zuora__BillingAccount__c)[1].Id;
											}
										}else{
											logger.log(false, 'Billing Account has 1 or 0 recurring invoice', string.valueOf(invRecord.Zuora__BillingAccount__c));
										}
									}else{
										logger.log(false, 'Billing Account Id not in Map', string.valueOf(invRecord.Zuora__BillingAccount__c));
									}
                                    //End UD-2549 Added By S.Puli - Credit note batch enhancement
                                    tempInvToCreLine_Map.put(invRecord.Zuora__Zuora_Id__c, cni);
                                }else{
                                    
                                    Credit_Note_Item__c cni = tempInvToCreLine_Map.get(invRecord.Zuora__Zuora_Id__c);
                                    cni.Amt_Before_Tax__c += MATH.ABS(invLi.Charge_Amount__c);
                                    cni.Tax_Amt__c += MATH.ABS(invLi.Tax_Amount__c);
                                    cni.Tax_Exempt_Amt__c += MATH.ABS(invLi.Tax_Exempt_Amount__c);
                                    cni.Amt_After_Tax__c = cni.Amt_Before_Tax__c + cni.Tax_Amt__c;
                                    
                                    //Populate Invoice field if Credit Amount is less than or equal to Last Invoice Total Amount
                                    cni.Invoice__c = null;
                                    //Start UD-2549 Added By S.Puli - Credit note batch enhancement
									if(billAccToAllInvoice_Map.containsKey(invRecord.Zuora__BillingAccount__c)){
										if(billAccToAllInvoice_Map.get(invRecord.Zuora__BillingAccount__c).size() > 1){
											if(cni.Amt_After_Tax__c <= billAccToAllInvoice_Map.get(invRecord.Zuora__BillingAccount__c)[1].Zuora__TotalAmount__c){
												cni.Invoice__c = billAccToAllInvoice_Map.get(invRecord.Zuora__BillingAccount__c)[1].Id;
											}
										}else{
											logger.log(false, 'Billing Account has 1 or 0 recurring invoice', string.valueOf(invRecord.Zuora__BillingAccount__c));
										}
									}else{
										logger.log(false, 'Billing Account Id not in Map', string.valueOf(invRecord.Zuora__BillingAccount__c));
									}
                                    //End UD-2549 Added By S.Puli - Credit note batch enhancement
                                    
                                    tempInvToCreLine_Map.put(invRecord.Zuora__Zuora_Id__c, cni);
                                }
                            }
                        }
                    }
                }               
            }
            
            if(!tempInvToCreLine_Map.isEmpty()){
                insert tempInvToCreLine_Map.values();
            }
            if(!invoiceWithLineItems.isEmpty()){
                update invoiceWithLineItems.values();
            }
        }catch(Exception e){
            logger.logBatchFailure(e, scope);
            
                    
            isApexJobSuccessful = false;

        }
        logger.save();
    }
    
    global void finish(Database.BatchableContext BC){

        List<Exception> exceptionList = new List<Exception>();
        
        try{
            if(!isApexJobSuccessful){
                BatchJobHelper.updateJobStatus(BC.getJobId(), false);
            }else{
                BatchJobHelper.updateJobStatus(BC.getJobId(), true);
            }
        }catch (Exception e){
            exceptionList.add(e);
        }
        
        ExceptionLogger.log(exceptionList); 
    }
}