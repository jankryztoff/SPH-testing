public class COS_SaveSubmit{
    
    Order__c orderObj = new Order__c();
    Order_Line_Item__c orderLineItemObj = new Order_Line_Item__c();
    
    public void saveAsDraft(Order__c thisOrder, Order_Line_Item__c orderLineItem,Zuora__Subscription__c subscription){       
        
        if(thisOrder.Effective_Date__c < Date.today()){
            if(thisOrder.Effective_Date__c >= orderLineItem.Earliest_Start_Date__c){
                orderObj.COS_Urgent_Request__c = false;
                orderLineItemObj.COS_Urgent_Request__c = false;             
            }
            else if(thisOrder.Effective_Date__c < orderLineItem.Earliest_Start_Date__c){
                orderObj.COS_Urgent_Request__c = true;
                orderLineItemObj.COS_Urgent_Request__c = true;      
            }
        }	
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Effective Date should be a future date.'));
        }
        
        orderObj.Account__c = thisOrder.Account__c;
        orderObj.Creation_Mode__c = thisOrder.Creation_Mode__c;
        orderObj.Subject__c = thisOrder.Subject__c;
        orderObj.Order_Type__c = thisOrder.Order_Type__c;
        orderObj.Reason_for_Waiver__c = thisOrder.Reason_for_Waiver__c;
        orderObj.Order_Action__c = thisOrder.Order_Action__c;
        orderObj.Status__c = thisOrder.Status__c;   
        orderObj.Delivery_Charge__c = thisOrder.Delivery_Charge__c;
        orderObj.Credit_Balance__c = thisOrder.Credit_Balance__c;
        orderObj.Monthly_Delivery_Charge_for_Full_Payment__c = thisOrder.Monthly_Delivery_Charge_for_Full_Payment__c;

        orderLineItemObj.Earliest_Start_Date__c = orderLineItem.Earliest_Start_Date__c;
        orderLineItemObj.Start_Date__c = thisOrder.Effective_Date__c;
        orderLineItemObj.Order__c = subscription.Order_Number_1__c;     
        orderLineItemObj.Qty__c = thisOrder.New_Quantity__c;
        orderLineItemObj.Term_Length__c = subscription.Term_Length__c;
        orderLineItemObj.Main_Package_ID__c = subscription.Main_Package_1__c;

        try{
            upsert orderObj;
            upsert orderLineItemObj;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }       
    }
    
    public void Submit(Order__c thisOrder, Zuora__Subscription__c oldDelSub){
    List<Order_Line_Item__c> oli = new List<Order_Line_Item__c>();
    //START: D-802 12/09/14 Added by S.Puli - add condition for multiple vendor
    oli = [Select Effective_Date__c, Qty__c, Vendor_Mailing_Agent__c From Order_Line_Item__c 
           Where Order__c =: thisOrder.Id Limit 1];
	//END: D-802 12/09/14 Added by S.Puli - add condition for multiple vendor
    system.debug('::::OLI' + oli);
        try{
            if(thisOrder != null){
                Case caseObj = new Case(); 
                caseObj.AccountId = thisOrder.Account__c;            
                caseObj.ContactId = thisOrder.Recipient_Contact__c;
                caseObj.Category__c = 'Subscription Request';
                caseObj.Sub_Category__c = 'Change of Subscription Packages';
                caseObj.Subject__c = thisOrder.Subject__c;
                caseObj.Origin = thisOrder.Creation_Mode__c;
                caseObj.New_Order_Details__c = thisOrder.Id;
                caseObj.Action_Type__c = 'Amend';
                caseObj.RecordTypeId = (Id)ConstantsSLB.getKeyId('Case_Change of Subscription');
    
                if(thisOrder.COS_Urgent_Request__c == true){
                        caseObj.Status = 'Pending';
                        caseObj.Sub_Status__c  = 'Waiting for Urgent Approval';
                }
                else if(thisOrder.COS_Urgent_Request__c == false){      
                        //START: D-802 12/09/14 Added by S.Puli - add condition for multiple vendor
						Contact conRec;
						if(caseObj.ContactId<>null){
							conRec = [Select Id, Name, Address__r.Postal_Code__c From Contact Where Id = :caseObj.ContactId];
						}
						List<Vendor_Allocation__c> vaList = [Select ID, Name, SingPost_Address__c From Vendor_Allocation__c Where SingPost_Address__c = :conRec.Address__r.Postal_Code__c];
						
						if(oli[0].Vendor_Mailing_Agent__c == null && vaList.size()>1){
							caseObj.Status = 'Pending';
							caseObj.Sub_Status__c  = 'Waiting for Vendor Assignment';
						}else if(oli[0].Vendor_Mailing_Agent__c == null && vaList.size()<1){
							caseObj.Status = 'Pending';
							caseObj.Sub_Status__c  = 'Waiting for Vendor Assignment';
						} else {
							caseObj.Status = 'Closed';
							caseObj.Sub_Status__c  = 'Change of Subscription Completed';
						}
						//END: D-802 12/09/14 Added by S.Puli
                        if(oldDelSub != null){
                            amendCallOut(oldDelSub.Id , oli[0].Effective_Date__c, oli[0].Qty__c);
                        }
                }
    
                insert caseObj;
            }
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
     @future (callout=true) 
     public static void amendCallOut(Id subscriptionId, Date effectiveDate, Decimal qty){

    
        List<Zuora.zObject> ratePlanChargeDataList = new List<Zuora.zObject>();
        List<Zuora__SubscriptionProductCharge__c> subProdChargeListFinal = new List<Zuora__SubscriptionProductCharge__c>();
        Map<String,zqu__ProductRatePlan__c> sku_ProdRatePlanMap = new Map<String,zqu__ProductRatePlan__c>();
        Map<String,zqu__ProductRatePlanCharge__c> name_ProdRatePlanChargeMap= new Map<String,zqu__ProductRatePlanCharge__c>();		
        Set<String> productSKUSet = new Set<String>();
        Set<String> name_SpcRpc_Set = new Set<String>();
        Set<String> sku_SpcRpc_Set = new Set<String>();
		Set<String> prodRatePlanNameSet = new Set<String>();
		Set<Id> ratePlanIds = new Set<Id>();
        
        Zuora__Subscription__c zSub = [SELECT Zuora__Zuora_Id__c, Zuora__ContractEffectiveDate__c FROM Zuora__Subscription__c WHERE Id =: subscriptionId]; 

        List<Zuora__SubscriptionProductCharge__c> subProdChargeList = [SELECT Id, Name, Zuora__Zuora_Id__c, Zuora__RatePlanName__c,
																		Zuora__RatePlanId__c, Zuora__ProductSKU__c 
																		FROM Zuora__SubscriptionProductCharge__c 
																		WHERE Zuora__Subscription__c =: zSub.Id];
        if(subProdChargeList != null){
            for(Zuora__SubscriptionProductCharge__c subProdCharge:subProdChargeList){
                productSKUSet.add(subProdCharge.Zuora__ProductSKU__c);
                name_SpcRpc_Set.add(subProdCharge.Name);
                sku_SpcRpc_Set.add(subProdCharge.Zuora__ProductSKU__c);
				prodRatePlanNameSet.add(subProdCharge.Zuora__RatePlanName__c);
            }
        }
		
		if(prodRatePlanNameSet != null) {
			List<zqu__ProductRatePlan__c> ratePlans = [SELECT Id, Name FROM zqu__ProductRatePlan__c 
														WHERE Name IN :prodRatePlanNameSet];
			if(ratePlans != null) {
				for(zqu__ProductRatePlan__c rPlans : ratePlans) {					
					ratePlanIds.add(rPlans.Id);
				}
			}			
		}
		
        system.debug('name_SpcRpc_Set'+name_SpcRpc_Set);
        List<zqu__ProductRatePlanCharge__c> prodRatePlanChargeList = [SELECT Name, zqu__ZuoraId__c, zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c 
																		FROM zqu__ProductRatePlanCharge__c 
																		WHERE Name IN:name_SpcRpc_Set 
																		AND zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c IN:sku_SpcRpc_Set
																		AND zqu__ProductRatePlan__c IN :ratePlanIds];																	
        if(prodRatePlanChargeList != null){
            for(zqu__ProductRatePlanCharge__c zProdRatePlanCharge:prodRatePlanChargeList){
                name_ProdRatePlanChargeMap.put(zProdRatePlanCharge.Name,zProdRatePlanCharge);
            }
        }
        system.debug('name_ProdRatePlanChargeMap'+name_ProdRatePlanChargeMap);
        
        for(zqu__ProductRatePlan__c zProdRatePlan : [SELECT Id, zqu__ZProduct__r.zqu__SKU__c, RatePlanType__c, zqu__ZProduct__r.ProductType__c 
														FROM zqu__ProductRatePlan__c WHERE zqu__ZProduct__r.zqu__SKU__c IN:productSKUSet])
		{
            if(zProdRatePlan!=null){
                sku_ProdRatePlanMap.put(zProdRatePlan.zqu__ZProduct__r.zqu__SKU__c, zProdRatePlan);
            }
        }
        system.debug('::::SUBPRODCHARGE' + subProdChargeList);
        if(subProdChargeList != null){      
            for(Zuora__SubscriptionProductCharge__c subProdChargeObj:subProdChargeList){
                zqu__ProductRatePlan__c zProdRatePlan = sku_ProdRatePlanMap.get(subProdChargeObj.Zuora__ProductSKU__c);
                if(zProdRatePlan.RatePlanType__c == 'Bill Plan' && zProdRatePlan.zqu__ZProduct__r.ProductType__c == 'Product'){
                    subProdChargeListFinal.add(subProdChargeObj);
                    system.debug('::::::BILLPLAN RCHARGE' + subProdChargeListFinal);
                }   
            }   
        }
                                
        Zuora.zApi zuorApi = new Zuora.zApi();
		//START D-3268 Modified By C.I.Salas - Test Coverage
		if (!Test.isRunningTest()) {
			zuorApi.zlogin();
		}
		//END D-3268 Modified By C.I.Salas - Test Coverage
                                                                                               
        Zuora.zObject amend = new Zuora.zObject('Amendment');
        amend.setValue('Description', 'Change of Subscription');
        amend.setValue('ContractEffectiveDate', Zuora.Zutil.getZuoraDate(effectiveDate));
        amend.setValue('Name', 'Change of Subscription' + Date.today());
        amend.setValue('SubscriptionId', zSub.Zuora__Zuora_Id__c);        
        amend.setValue('Type', 'UpdateProduct');
        amend.setValue('ServiceActivationDate', Zuora.Zutil.getZuoraDate(effectiveDate));
        
		//remove this after--------------------------------------------------------
		system.debug('>>>>EFFECTIVEDATE' + effectiveDate);
		//subProdChargeList[0].Zuora__RatePlanId__c;
		system.debug('>>>>RatePlanId' + subProdChargeList[0].Zuora__RatePlanId__c);
		//--------------------------------------------------------------------------
		
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        
            Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
            ratePlan.setValue('AmendmentSubscriptionRatePlanId', subProdChargeList[0].Zuora__RatePlanId__c); //question on this
            ratePlan.setValue('SubscriptionId', zSub.Zuora__Zuora_Id__c); //comment
         	//--------remove
         	system.debug('>>>>RatePlanId' + zSub.Zuora__Zuora_Id__c);
        for(Zuora__SubscriptionProductCharge__c zSubProductCharge:subProdChargeListFinal){
            Zuora.zObject ratePlanChargeObj = new Zuora.zObject('RatePlanCharge');
            if(zSubProductCharge != null){
                zqu__ProductRatePlanCharge__c zProdRatePlanCh = name_ProdRatePlanChargeMap.get(zSubProductCharge.Name);
                ratePlanChargeObj.setValue('ProductRatePlanChargeId', zProdRatePlanCh.zqu__ZuoraId__c); 
				//remove
				system.debug('>>>>RatePlanChargeId' + zProdRatePlanCh.zqu__ZuoraId__c);
            }
            ratePlanChargeObj.setValue('Id', zSubProductCharge.Zuora__Zuora_Id__c); //id
            ratePlanChargeObj.setValue('RatePlanId', zSubProductCharge.Zuora__RatePlanId__c); //comment       
            ratePlanChargeObj.setValue('Quantity', qty);    
          
            Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
            ratePlanChargeData.setValue('RatePlanCharge',ratePlanChargeObj);         
            ratePlanChargeDataList.add(ratePlanChargeData);     

			//REMOVE-------------
			system.debug('>>>>SPCID' + zSubProductCharge.Zuora__Zuora_Id__c);
        }
     	system.debug(':::::::RATEPLAN' + ratePlan);
        system.debug(':::::::RLIST' + ratePlanChargeDataList);
        ratePlanData.setValue('RatePlan', ratePlan);
        ratePlanData.setValue('RatePlanChargeData', ratePlanChargeDataList);
        
        amend.setValue('RatePlanData', ratePlanData);	
        
        // Amend Request
        Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
        Zuora.zObject[] amendments = new List < Zuora.zObject > {amend};
        amendRequest.amendments = amendments;
                    
        // Amend Options
        Zuora.zApi.AmendOptions amendmentOption = new Zuora.zApi.AmendOptions();
        amendmentOption.GenerateInvoice = false;
        amendmentOption.ProcessPayments = false;
        amendRequest.AmendOptions = amendmentOption;
                        
        // Amend Preview
        Zuora.zApi.PreviewOptions previewOptions = new Zuora.zApi.PreviewOptions();
        previewOptions.EnablePreviewMode = false;
        amendRequest.previewOptions = previewOptions;

        Zuora.zApi.AmendResult amendResult = zuorApi.zamend(new List<Zuora.zApi.AmendRequest>{amendRequest});
        system.debug('>>>>>RESULT' + String.valueOf(amendResult.errors));
		//START: D-1185 12/17/14 Added by S.Puli
        if(amendResult.success == true){
			COS_SubsQty.updateZuoraSubFields(zSub.Zuora__Zuora_Id__c, string.valueOf(qty));
		}
		//END: D-1185 12/17/14 Added by S.Puli

    }

    /*
    public void amendCallOut(Id accId, Zuora__Subscription__c oldDelSub, Date effectiveDate, Decimal qty){
        COS_CreateAmendmentQuote createAmendQuote = new COS_CreateAmendmentQuote();
        zqu__Quote__c zQuoteObj = createAmendQuote.zQuote(accId, oldDelSub, effectiveDate);
        insert zQuoteObj;
        List<zqu__QuoteCharge__c> zquoteChargeList = createAmendQuote.(zQuoteObj, qty);
        insert zquoteChargeList;
        COS_CreateAmendmentQuote.SendToZBilling(zQuoteObj.Id, zQuoteObj.zqu__ZuoraAccountID__c);
    }  
    
    */ 
    /*
    public static String formatDateToZuora(Date formatDate){

        DateTime stp = (DateTime)formatDate;
        String mydate = string.valueof(stp.format('YYYY-MM-d'));
        String d = mydate+'T00:00:00';
        return d;
    }
    
    public static String zuoraQuery(String chargeNumber, Zuora.zApi zuorApi){
        //Zuora.zApi zuorApi = new Zuora.zApi();
        //zuorApi.zlogin();  
        
        String aname;
        try {
        String zoql = 'SELECT Id, ChargeNumber from RatePlanCharge Where ChargeNumber =\'+chargeNumber+\'';
        List<Zuora.zObject> zobjs = zuorApi.zquery(zoql);

        for (Zuora.zObject o : zobjs) {
            aname = (String)o.getValue('Id');
            //more code here...
        }
        } catch (Zuora.zRemoteException ex) {
        if ('INVALID_FIELD' == ex.code) {
            // An invalid field was specified
            //more code here...
            } else {
            //more code here...
        }
        } catch (Zuora.zAPIException ex) {
        ex.getMessage();
        //more code here...
        } catch (Zuora.zForceException ex) {
        //more code here...
        }
        
        return aname;    
    }
    */
}