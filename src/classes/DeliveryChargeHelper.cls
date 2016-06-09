/*
 * Class Name: DeliveryChargeHelper
 * @Author: Wenjun Zhu
 * @Date: 16/March/2015
 * @Description: This class is for Delivery Charges related code logic
 * 
 * @History - [MD-18] 23/03/15 Wenjun : Add more utility methods
 * @History - [D-2777] 20/04/15 Wenjun : Remove unused method public static void updateDelChargeRate(Id delSubId, Decimal newChargeRate)
 *
 */
public class DeliveryChargeHelper {
    
    public final static String FULL_PRE = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID;
    public final static String MR_PRE = GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID;
    public final static String MR_POST = GlobalVariableClass.RECURRING_POSTPAID;
    public final static String SUBTYPE_DEL = GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY; //START END D-2777 Wenjun 16/04/15
    //START UD-2303 08/14/2015 Added by J.Sarion - Added static variable for COA Batch
    public static boolean isCalledFromCOABatch = false;
    //END UD-2303 08/14/2015 Added by J.Sarion - Added static variable for COA Batch
    
    //Check if the 1st Sub is higher in Hierarchy than 2nd Sub
    //START D-2777 15-Apr-2015 Wenjun: remove = when comparing start date
    public static Boolean isHigherInHierarchy(Zuora__Subscription__c sub1, Zuora__Subscription__c sub2)
    { 
        //Get data fields used to compare Sub Hierarchy
        String billingTypeSub1 = sub1.Billing_Type__c;
        String billingTypeSub2 = sub2.Billing_Type__c;
        Date startDateSub1 = sub1.Zuora__SubscriptionStartDate__c;
        Date startDateSub2 = sub2.Zuora__SubscriptionStartDate__c;
        Boolean isOnContractSub1 = isSubOnContract(sub1);
        Boolean isOnContractSub2 = isSubOnContract(sub2);
        
        if(billingTypeSub1 == FULL_PRE)
        {
            if(billingTypeSub2 != FULL_PRE)
                return true;
            else 
                return (startDateSub1 < startDateSub2);    
        }
        else
        {
            if(billingTypeSub2 == FULL_PRE)
                return false;
            else if(isOnContractSub1 && isOnContractSub2)
                return (startDateSub1 < startDateSub2);
            else if(isOnContractSub1 && !isOnContractSub2)
                return true;
            else if(!isOnContractSub1 && isOnContractSub2)
                return false;
            else 
                return (startDateSub1 < startDateSub2);
        }   
    }
    //END D-2777 15-Apr-2015 Wenjun: remove = when comparing start date
    
    public static Boolean isSubOnContract(Zuora__Subscription__c sub)
    {
        Date monthEnd = Date.today().toStartOfMonth().addMonths(1).addDays(-1);
        Date nextMonthEnd = Date.today().toStartOfMonth().addMonths(2).addDays(-1);
        
        if(sub.Billing_Type__c == MR_PRE)
            return (sub.Contract_End_Date_1__c != NULL && sub.Contract_End_Date_1__c >= nextMonthEnd);
        else if (sub.Billing_Type__c == MR_POST)
            return (sub.Contract_End_Date_1__c != NULL && sub.Contract_End_Date_1__c >= monthEnd);
        else
            return false;
    }

    //Create Amendment Objects for Changing of Delivery Charge Rate
    public static List<Zuora.zApi.AmendRequest> createCODCAmendmentReqs(List<Zuora__Subscription__c> lstSubs, Id ratePlanID){
            
        List<Zuora.zApi.AmendRequest> lstAmendReqs = new List<Zuora.zApi.AmendRequest>();
        Map<String,zqu__ProductRatePlanCharge__c> mapNameProdRatePlanCharge = new Map<String,zqu__ProductRatePlanCharge__c>();      
        Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapSubIDToSPCLst = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();
        Map<Id, String> mapSubToRatePlanId = new Map<Id, String>();
        
        //START UD-3083 10/22/2015 Added By C. Lin - Consider Invoice Date
        Set<String> invoiceIdSet = new Set<String>();
        Map<String, Date> invoiceIdToInvoiceDateMap = new Map<String, Date>();
        Map<Id, Set<String>> subIdToInvoiceIdSetMap = new Map<Id, Set<String>>();
        //END UD-3083 10/22/2015 Added By C. Lin
        
        if(!lstSubs.isEmpty() && ratePlanID != null)
        {
            for(Zuora__SubscriptionProductCharge__c spcObj: [SELECT Id, Name, Zuora__Zuora_Id__c, Zuora__RatePlanName__c, 
                                 Zuora__RatePlanId__c, Zuora__ProductSKU__c, Zuora__Subscription__c 
                                 FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c in : lstSubs])
             {
                 mapSubToRatePlanId.put(spcObj.Zuora__Subscription__c, spcObj.Zuora__RatePlanId__c);
                 if(mapSubIDToSPCLst.containsKey(spcObj.Zuora__Subscription__c))
                     mapSubIDToSPCLst.get(spcObj.Zuora__Subscription__c).add(spcObj);
                 else
                     mapSubIDToSPCLst.put(spcObj.Zuora__Subscription__c, new List<Zuora__SubscriptionProductCharge__c> {spcObj});
             }
            
            //Get Delivery Rate Plan Charges
            for(zqu__ProductRatePlanCharge__c prpc : [Select Id, Name, zqu__ZuoraId__c,zqu__UOM__c, zqu__Type__c, sum__c
                 From zqu__ProductRatePlanCharge__c Where zqu__ProductRatePlan__c = :ratePlanID AND zqu__Deleted__c = false])
            {
                mapNameProdRatePlanCharge.put(prpc.Name,prpc);
            }
            
            //START UD-3083 10/22/2015 Added By C. Lin - Consider Invoice Date
            for(Invoice_Line_Item__c invLI : [SELECT Id, Name, Invoice_ID__c, Subscription__c FROM Invoice_Line_Item__c WHERE Subscription__c in : lstSubs])
            {
                invoiceIdSet.add(invLI.Invoice_ID__c);
                if(subIdToInvoiceIdSetMap.containsKey(invLI.Subscription__c)){
                    subIdToInvoiceIdSetMap.get(invLI.Subscription__c).add(invLI.Invoice_ID__c);
                }else{
                    subIdToInvoiceIdSetMap.put(invLI.Subscription__c, new Set<String> {invLI.Invoice_ID__c});
                }
            }
            
            for(Zuora__ZInvoice__c inv : [SELECT Id, Name, Zuora__InvoiceDate__c, Zuora__TargetDate__c, Zuora__Zuora_Id__c FROM Zuora__ZInvoice__c WHERE Zuora__Zuora_Id__c in : invoiceIdSet])
            {
                invoiceIdToInvoiceDateMap.put(inv.Zuora__Zuora_Id__c, inv.Zuora__InvoiceDate__c);
            }
            //END UD-3083 10/22/2015 Added By C. Lin
            
            //START D-4382 Wenjun 15/02/16 : for Daily Run: always effective immediately
            Date effectiveDate = Date.today();

            for(Zuora__Subscription__c zSub : lstSubs)      
            {       
                if(mapSubIDToSPCLst.containsKey(zSub.Id) && mapSubToRatePlanId.containsKey(zSub.Id))
                {  
                    if (zSub.Zuora__SubscriptionStartDate__c > effectiveDate)
                        effectiveDate = zSub.Zuora__SubscriptionStartDate__c;
            //END D-4382 Wenjun 15/02/16 
            
                    //START UD-3083 10/22/2015 Added By C. Lin - Consider Invoice Date
                    if(subIdToInvoiceIdSetMap.containsKey(zSub.Id)){
                        for(String invId : subIdToInvoiceIdSetMap.get(zSub.Id)){
                            if(invoiceIdToInvoiceDateMap.containsKey(invId)){
                                if(invoiceIdToInvoiceDateMap.get(invId) > effectiveDate){
                                    effectiveDate = invoiceIdToInvoiceDateMap.get(invId).addDays(1);
                                }
                            }
                        }
                    }
                    //END UD-3083 10/22/2015 Added By C. Lin
                        
                    Zuora.zObject amendObj = new Zuora.zObject('Amendment');
                    List<Zuora.zObject> ratePlanChargeDataList = new List<Zuora.zObject>();
                    
                    amendObj.setValue('Description', 'Change of Delivery Rate Plan Charge');
                    amendObj.setValue('ContractEffectiveDate', Zuora.Zutil.getZuoraDate(effectiveDate));
                    amendObj.setValue('Name', 'Change of Delivery Rate Plan Charge');
                    amendObj.setValue('SubscriptionId', zSub.Zuora__Zuora_Id__c);        
                    amendObj.setValue('Type', 'UpdateProduct');
                    amendObj.setValue('ServiceActivationDate', Zuora.Zutil.getZuoraDate(effectiveDate));
                    
                    //Prepare Rate Plan Data
                    Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
                    Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
                    ratePlan.setValue('AmendmentSubscriptionRatePlanId', mapSubToRatePlanId.get(zSub.Id));
                    ratePlan.setValue('SubscriptionId', zSub.Zuora__Zuora_Id__c); 

                    for(Zuora__SubscriptionProductCharge__c zSubProductCharge:mapSubIDToSPCLst.get(zSub.Id))
                    {
                        Zuora.zObject ratePlanChargeObj = new Zuora.zObject('RatePlanCharge');
                        zqu__ProductRatePlanCharge__c zProdRatePlanCh = mapNameProdRatePlanCharge.get(zSubProductCharge.Name);
                        
                        if(zProdRatePlanCh == null) continue; //START END D-2699 27/03/15 Wenjun                
                                                    
                        ratePlanChargeObj.setValue('ProductRatePlanChargeId', zProdRatePlanCh.zqu__ZuoraId__c); 
                        ratePlanChargeObj.setValue('Id', zSubProductCharge.Zuora__Zuora_Id__c); 
                        ratePlanChargeObj.setValue('RatePlanId', zSubProductCharge.Zuora__RatePlanId__c);           
                        ratePlanChargeObj.setValue('Price', zProdRatePlanCh.sum__c); 
                            
                        Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
                        ratePlanChargeData.setValue('RatePlanCharge',ratePlanChargeObj);         
                        ratePlanChargeDataList.add(ratePlanChargeData);     
                    }

                    ratePlanData.setValue('RatePlan', ratePlan);
                    ratePlanData.setValue('RatePlanChargeData', ratePlanChargeDataList);
                    
                    amendObj.setValue('RatePlanData', ratePlanData);    
                    
                    // Amend Request
                    Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
                    Zuora.zObject[] amendments = new List < Zuora.zObject > {amendObj};
                    amendRequest.amendments = amendments;
                    
                    // Amend Options
                    amendRequest.AmendOptions = createAmendOption();
                                    
                    // Amend Preview
                    amendRequest.previewOptions = createPreviewOption();
        
                    lstAmendReqs.add(amendRequest);
                } // End of If
            } //End of For
        } //End of If
        return lstAmendReqs;
    }
    
    public static List<Zuora.zApi.AmendRequest> createCODCAmendmentReqs(List<Zuora__Subscription__c> lstSubs, String oldRatePlanName,  String newRatePlanId)
    {
        List<Zuora.zApi.AmendRequest> lstAmendReqs = new List<Zuora.zApi.AmendRequest>();     
        Map<Id, String> mapSubToRatePlanId = new Map<Id, String>();
        
        //START UD-3083 10/22/2015 Added By C. Lin - Consider Invoice Date
        Set<String> invoiceIdSet = new Set<String>();
        Map<String, Date> invoiceIdToInvoiceDateMap = new Map<String, Date>();
        Map<Id, Set<String>> subIdToInvoiceIdSetMap = new Map<Id, Set<String>>();
        //END UD-3083 10/22/2015 Added By C. Lin
        
        if(!lstSubs.isEmpty() && oldRatePlanName != null && newRatePlanId != null)
        {
            for(Zuora__SubscriptionProductCharge__c spcObj: [SELECT Id, Name, Zuora__Zuora_Id__c, Zuora__RatePlanName__c, 
                                 Zuora__RatePlanId__c, Zuora__ProductSKU__c, Zuora__Subscription__c 
                                 FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c in : lstSubs
                                 AND Zuora__RatePlanName__c = :oldRatePlanName])
             {
                 mapSubToRatePlanId.put(spcObj.Zuora__Subscription__c, spcObj.Zuora__RatePlanId__c); //SPC Rate Plan ID
             }
            
            //START UD-3083 10/22/2015 Added By C. Lin - Consider Invoice Date
            for(Invoice_Line_Item__c invLI : [SELECT Id, Name, Invoice_ID__c, Subscription__c FROM Invoice_Line_Item__c WHERE Subscription__c in : lstSubs])
            {
                invoiceIdSet.add(invLI.Invoice_ID__c);
                if(subIdToInvoiceIdSetMap.containsKey(invLI.Subscription__c)){
                    subIdToInvoiceIdSetMap.get(invLI.Subscription__c).add(invLI.Invoice_ID__c);
                }else{
                    subIdToInvoiceIdSetMap.put(invLI.Subscription__c, new Set<String> {invLI.Invoice_ID__c});
                }
            }
            
            for(Zuora__ZInvoice__c inv : [SELECT Id, Name, Zuora__InvoiceDate__c, Zuora__TargetDate__c, Zuora__Zuora_Id__c FROM Zuora__ZInvoice__c WHERE Zuora__Zuora_Id__c in : invoiceIdSet])
            {
                invoiceIdToInvoiceDateMap.put(inv.Zuora__Zuora_Id__c, inv.Zuora__InvoiceDate__c);
            }
            //END UD-3083 10/22/2015 Added By C. Lin
            
            Date effectiveDate = Date.today().toStartOfMonth().addMonths(1);
            
            //START UD-2303 08/14/2015 Added by J.Sarion - set Contract Effective Date
            if(isCalledFromCOABatch){
                effectiveDate = Date.today();
            }
            //END UD-2303 08/14/2015 Added by J.Sarion - set Contract Effective Date

            for(Zuora__Subscription__c zSub : lstSubs)      
            {       
                if(mapSubToRatePlanId.containsKey(zSub.Id))
                {  
                    if (zSub.Zuora__SubscriptionStartDate__c > effectiveDate)
                        effectiveDate = zSub.Zuora__SubscriptionStartDate__c;
                    
                    //START UD-3083 10/22/2015 Added By C. Lin - Consider Invoice Date
                    if(subIdToInvoiceIdSetMap.containsKey(zSub.Id)){
                        for(String invId : subIdToInvoiceIdSetMap.get(zSub.Id)){
                            if(invoiceIdToInvoiceDateMap.containsKey(invId)){
                                if(invoiceIdToInvoiceDateMap.get(invId) > effectiveDate){
                                    effectiveDate = invoiceIdToInvoiceDateMap.get(invId).addDays(1);
                                }
                            }
                        }
                    }
                    //END UD-3083 10/22/2015 Added By C. Lin
                    
                    /******************** Remove Existing Rate Plan ************************/   
                    Zuora.zObject amendObj = new Zuora.zObject('Amendment');
                    
                    amendObj.setValue('Description', 'Remove Delivery Rate Plan');
                    amendObj.setValue('ContractEffectiveDate', Zuora.Zutil.getZuoraDate(effectiveDate));
                    amendObj.setValue('Name', 'Remove Delivery Rate Plan');
                    amendObj.setValue('SubscriptionId', zSub.Zuora__Zuora_Id__c);        
                    amendObj.setValue('Type', 'RemoveProduct');
                    amendObj.setValue('ServiceActivationDate', Zuora.Zutil.getZuoraDate(effectiveDate));
                    
                    //Prepare Rate Plan Data
                    Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
                    Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
                    ratePlan.setValue('SubscriptionId', zSub.Zuora__Zuora_Id__c); 
                    ratePlan.setValue('AmendmentSubscriptionRatePlanId', mapSubToRatePlanId.get(zSub.Id));
                    ratePlanData.setValue('RatePlan', ratePlan);                    
                    amendObj.setValue('RatePlanData', ratePlanData);    
                    
                    /******************** Add New Rate Plan ************************/   
                    Zuora.zObject amendNewObj = new Zuora.zObject('Amendment');
                    
                    amendNewObj.setValue('Description', 'New Delivery Rate Plan');
                    amendNewObj.setValue('ContractEffectiveDate', Zuora.Zutil.getZuoraDate(effectiveDate));
                    amendNewObj.setValue('Name', 'New Delivery Rate Plan');
                    amendNewObj.setValue('SubscriptionId', zSub.Zuora__Zuora_Id__c);        
                    amendNewObj.setValue('Type', 'NewProduct');
                    amendNewObj.setValue('ServiceActivationDate', Zuora.Zutil.getZuoraDate(effectiveDate));
                    
                    //Prepare Rate Plan Data
                    Zuora.zObject ratePlanData2 = new Zuora.zObject('RatePlanData');
                    Zuora.zObject ratePlan2 = new Zuora.zObject('RatePlan');
                    ratePlan2.setValue('SubscriptionId', zSub.Zuora__Zuora_Id__c); 
                    ratePlan2.setValue('ProductRatePlanId', newRatePlanId);
                    ratePlanData2.setValue('RatePlan', ratePlan2);                    
                    amendNewObj.setValue('RatePlanData', ratePlanData2);  
                    
                    // Amend Request
                    Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
                    Zuora.zObject[] amendments = new List < Zuora.zObject > {amendObj, amendNewObj};
                    amendRequest.amendments = amendments;
                    
                    // Amend Options
                    amendRequest.AmendOptions = createAmendOption();
                                    
                    // Amend Preview
                    amendRequest.previewOptions = createPreviewOption();
        
                    lstAmendReqs.add(amendRequest);
                } // End of If
            } //End of For
        } //End of If
        return lstAmendReqs;
    }
    
    //START Wenjun D-4806 20 April 16 - Add Job Run Date parameter
    public static List<Zuora.zApi.AmendRequest> createCoverPriceAmendmentReqs(List<Zuora__Subscription__c> lstSubs, Date executionDay)
    {
        List<Zuora.zApi.AmendRequest> lstAmendReqs = new List<Zuora.zApi.AmendRequest>();
        Map<String,zqu__ProductRatePlanCharge__c> mapNameProdRatePlanCharge = new Map<String,zqu__ProductRatePlanCharge__c>();      
        Map<String, List<Zuora__SubscriptionProductCharge__c>> mapZRatePlanIdToSPCLst = new Map<String, List<Zuora__SubscriptionProductCharge__c>>();
        Map<Id, Set<String>> mapSubToRatePlanIdList = new Map<Id, Set<String>>();
        Set<String> setProductSKU = new Set<String>();
        Set<String> setChargeName = new Set<String>();
        Set<String> setRatePlanName = new Set<String>();
        //START D-2992 Wenjun 22/05/15 : Query Subscription Base Discount
        Map<Id, SPCDiscWrapper> mapSubToDisc = new Map<Id, SPCDiscWrapper>();
        
        if(!lstSubs.isEmpty())
        {
            for(Zuora__SubscriptionProductCharge__c spcObj: [SELECT Id, Name, Zuora__Zuora_Id__c, Zuora__RatePlanName__c,  
                           Zuora__RatePlanId__c, Zuora__ProductSKU__c, Zuora__Subscription__c, Zuora__Model__c, Zuora__Quantity__c, 
                           Zuora__EffectiveStartDate__c, Zuora__Price__c, Product_Code__c //START END D-4382 Wenjun 15/02/16 : Fetch Product Code
                           FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c in : lstSubs])
             {
                if(spcObj.Zuora__Model__c != GlobalVariableClass.SPC_MODEL_DISCOUNT) //Ignore Discount
                {
                    setProductSKU.add(spcObj.Zuora__ProductSKU__c);
                    setChargeName.add(spcObj.Name);
                    setRatePlanName.add(spcObj.Zuora__RatePlanName__c);
                    
                    if(mapSubToRatePlanIdList.containsKey(spcObj.Zuora__Subscription__c))
                        mapSubToRatePlanIdList.get(spcObj.Zuora__Subscription__c).add(spcObj.Zuora__RatePlanId__c);
                    else
                        mapSubToRatePlanIdList.put(spcObj.Zuora__Subscription__c, new Set<String> {spcObj.Zuora__RatePlanId__c});
                    
                    if(mapZRatePlanIdToSPCLst.containsKey(spcObj.Zuora__RatePlanId__c))
                         mapZRatePlanIdToSPCLst.get(spcObj.Zuora__RatePlanId__c).add(spcObj);
                    else
                         mapZRatePlanIdToSPCLst.put(spcObj.Zuora__RatePlanId__c, new List<Zuora__SubscriptionProductCharge__c> {spcObj});
                }
                //START D-4382 Wenjun 15/02/16 : Ignore 100% Non-chargeable proration charges
                else if(spcObj.Product_Code__c == 'DISC') //Discount SPC - Ignore 100% Non-chargeable proration charges
                {
                    if(!mapSubToDisc.containsKey(spcObj.Zuora__Subscription__c) || 
                        spcObj.Zuora__EffectiveStartDate__c < mapSubToDisc.get(spcObj.Zuora__Subscription__c).effectiveDT)
                        mapSubToDisc.put(spcObj.Zuora__Subscription__c,new SPCDiscWrapper(spcObj.Zuora__EffectiveStartDate__c,spcObj.Zuora__Price__c));
                }
                //END D-4382 Wenjun 15/02/16
             }
            //END D-2992 Wenjun 22/05/15
            
            //Get Rate Plan Charges
            for(zqu__ProductRatePlanCharge__c prpc : [Select Id, Name, zqu__ZuoraId__c,zqu__UOM__c, zqu__Type__c, 
                        sum__c, zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c
                 From zqu__ProductRatePlanCharge__c Where Name in :setChargeName AND zqu__Deleted__c = false
                 AND zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c IN:setProductSKU 
                 AND zqu__ProductRatePlan__r.Name in : setRatePlanName 
                 AND (zqu__ProductRatePlan__r.RatePlanType__c = :GlobalVariableClass.RATEPLANTYPE_BILL 
                      or zqu__ProductRatePlan__r.RatePlanType__c = :GlobalVariableClass.RATEPLANNAME_PRORATION)])
            {
                String key = prpc.Name + prpc.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c;
                mapNameProdRatePlanCharge.put(key,prpc);
            }
            
            //START D-4382 Wenjun 15/02/16 : Set effective date as Execution Date + 1
            Date effectiveDate = executionDay.addDays(1);

            for(Zuora__Subscription__c zSub : lstSubs)      
            {       
                System.debug('===> ' + zSub.Id);
                if(mapSubToRatePlanIdList.containsKey(zSub.Id))
                {  
                    // Amend Request
                    Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
                    Zuora.zObject[] amendments = new List < Zuora.zObject > {};
                    
                   if (zSub.Zuora__SubscriptionStartDate__c > effectiveDate)
                        effectiveDate = zSub.Zuora__SubscriptionStartDate__c;
             //END D-4382 Wenjun 15/02/16 
             
                    System.debug('===> ' + mapSubToRatePlanIdList.get(zSub.Id).size());
                    
                    //Create Amendment Object for each Rate Plan                    
                    for(String spcRatePlanID : mapSubToRatePlanIdList.get(zSub.Id))
                    {
                        Zuora.zObject amendObj = new Zuora.zObject('Amendment');
                        List<Zuora.zObject> ratePlanChargeDataList = new List<Zuora.zObject>();
                        
                        amendObj.setValue('Description', 'Change of Cover Price');
                        amendObj.setValue('ContractEffectiveDate', Zuora.Zutil.getZuoraDate(effectiveDate));
                        amendObj.setValue('Name', 'Change of Cover Price');
                        amendObj.setValue('SubscriptionId', zSub.Zuora__Zuora_Id__c);        
                        amendObj.setValue('Type', 'UpdateProduct');
                        amendObj.setValue('ServiceActivationDate', Zuora.Zutil.getZuoraDate(effectiveDate));
                        
                        //Prepare Rate Plan Data
                        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
                        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
                        ratePlan.setValue('AmendmentSubscriptionRatePlanId', spcRatePlanID);
                        ratePlan.setValue('SubscriptionId', zSub.Zuora__Zuora_Id__c); 

                        for(Zuora__SubscriptionProductCharge__c zSubProductCharge:mapZRatePlanIdToSPCLst.get(spcRatePlanID))
                        {
                            Zuora.zObject ratePlanChargeObj = new Zuora.zObject('RatePlanCharge');
                            String key = zSubProductCharge.Name + zSubProductCharge.Zuora__ProductSKU__c;
                            zqu__ProductRatePlanCharge__c zProdRatePlanCh = mapNameProdRatePlanCharge.get(key);
                            
                            if(zProdRatePlanCh == null) continue; //START END D-2699 27/03/15 Wenjun
                            //START D-2992 Wenjun 22/05/15 : Overwrite negative list price with discounted value
                            Decimal listPrice = zProdRatePlanCh.sum__c;
                            if(mapSubToDisc.containsKey(zSub.Id) && listPrice < 0 
                                && zSubProductCharge.Zuora__Model__c == GlobalVariableClass.SPC_MODEL_UNIT)
                            {
                                Decimal discRate = mapSubToDisc.get(zSub.Id).discRate;
                                if(discRate != NULL)
                                {
                                    listPrice = listPrice * (1 - discRate/100);
                                    listPrice = listPrice.setScale(2, System.RoundingMode.HALF_UP);
                                }
                            }
                            
                            ratePlanChargeObj.setValue('ProductRatePlanChargeId', zProdRatePlanCh.zqu__ZuoraId__c); 
                            ratePlanChargeObj.setValue('Id', zSubProductCharge.Zuora__Zuora_Id__c); 
                            ratePlanChargeObj.setValue('RatePlanId', zSubProductCharge.Zuora__RatePlanId__c);           
                            ratePlanChargeObj.setValue('Price', listPrice); 
                            //END D-2992 Wenjun 22/05/15
                            ratePlanChargeObj.setValue('Quantity', zSubProductCharge.Zuora__Quantity__c);
                                
                            Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
                            ratePlanChargeData.setValue('RatePlanCharge',ratePlanChargeObj);         
                            ratePlanChargeDataList.add(ratePlanChargeData);     
                        }

                        ratePlanData.setValue('RatePlan', ratePlan);
                        ratePlanData.setValue('RatePlanChargeData', ratePlanChargeDataList);
                        
                        amendObj.setValue('RatePlanData', ratePlanData); 
                        amendments.add(amendObj);                   
                    }

                    amendRequest.amendments = amendments;
                    // Amend Options
                    amendRequest.AmendOptions = createAmendOption();          
                    // Amend Preview
                    amendRequest.previewOptions = createPreviewOption();
        
                    lstAmendReqs.add(amendRequest);
                } // End of If
            } //End of For
        } //End of If
        return lstAmendReqs;
    }
    //END Wenjun D-4806 20 April 16 - Add Job Run Date parameter
    
    public static Zuora.zApi.AmendOptions createAmendOption()
    {
        Zuora.zApi.AmendOptions amendmentOption = new Zuora.zApi.AmendOptions();
        amendmentOption.GenerateInvoice = false;
        amendmentOption.ProcessPayments = false;
        
        return amendmentOption;
    }
    
    public static Zuora.zApi.PreviewOptions createPreviewOption()
    {
        Zuora.zApi.PreviewOptions previewOptions = new Zuora.zApi.PreviewOptions();
        previewOptions.EnablePreviewMode = false;
        
        return previewOptions;
    }
    //START D-2777 Wenjun 16/04/15 : Set Delivery Subscription Active Flag
    public static void updateDelSubsActiveFlag(Set<Id> setRecipientIds)
    {
        Set<Zuora__Subscription__c> setToUpd = new Set<Zuora__Subscription__c>();
        Map<ID, Zuora__Subscription__c> mapRecipientToDelSub = new Map<ID, Zuora__Subscription__c>();
        //Map<String, Zuora__Subscription__c> mapFullPreDelSub = new Map<String, Zuora__Subscription__c>(); //START END D-2921 Wenjun 12/05/15
        Set<Zuora__Subscription__c> setInActiveDelSubs = new Set<Zuora__Subscription__c>();
        Date today = Date.today();
        Date yesterday = Date.today().addDays(-1);
        
        //Fetch affected subscriptions to Update, including end date = yesterday
        for(Zuora__Subscription__c sub: [SELECT Id, Name, Subscription_Type_1__c, Is_Active__c, Billing_Type__c, 
                        Recipient_Contact__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Contract_End_Date_1__c
                        FROM Zuora__Subscription__c WHERE Recipient_Contact__c IN :setRecipientIds 
                        AND (Zuora__SubscriptionEndDate__c >= :yesterday OR Zuora__SubscriptionEndDate__c = null)
                        AND Subscription_Type_1__c = :SUBTYPE_DEL AND (
                          Billing_Type__c = :FULL_PRE OR
                          (Billing_Type__c != :FULL_PRE AND Zuora__SubscriptionStartDate__c <= :today)
                          ) Order by Name])
        {
            Boolean isActive = false;
            
            if(sub.Zuora__SubscriptionEndDate__c == yesterday)
                setInActiveDelSubs.add(sub);
            else //END Date >= Today
            {
                if(sub.Billing_Type__c == FULL_PRE)
                {
                    //START D-2921 Wenjun 12/05/15: all non-expired Full Prepaid are active
                    if(sub.Is_Active__c != true) 
                    {
                        sub.Is_Active__c = true;
                        setToUpd.add(sub);
                    }
                    //END D-2921 Wenjun 12/05/15
                }
                
                if(sub.Zuora__SubscriptionStartDate__c <= today)
                {
                    if(mapRecipientToDelSub.containsKey(sub.Recipient_Contact__c))
                    {
                        Zuora__Subscription__c prevDelSub = mapRecipientToDelSub.get(sub.Recipient_Contact__c);
                        if(DeliveryChargeHelper.isHigherInHierarchy(sub,prevDelSub))
                        {
                            mapRecipientToDelSub.put(sub.Recipient_Contact__c, sub);
                            //Set pre sub to Inactive - if not Full Prepaid
                            if(prevDelSub.Billing_Type__c != FULL_PRE)
                                setInActiveDelSubs.add(prevDelSub); 
                        }
                        else
                        {
                            if(sub.Billing_Type__c != FULL_PRE)
                                setInActiveDelSubs.add(sub); //Set this sub to Inactive
                        }
                    }
                    else mapRecipientToDelSub.put(sub.Recipient_Contact__c, sub);
                }
            }
        }
        
        
        //Process the "Active" del sub as of Today
        for(Zuora__Subscription__c delSub : mapRecipientToDelSub.values())
        {
            if(delSub.Is_Active__c != true) 
            {
                delSub.Is_Active__c = true;
                setToUpd.add(delSub);
            }
        }
        
        //Process Inactive subs
        for(Zuora__Subscription__c delSub : setInActiveDelSubs)
        {
            if(delSub.Is_Active__c != false) 
            {
                delSub.Is_Active__c = false;
                setToUpd.add(delSub);
            }
        }
        
        //UPDATE Subs
        //START D-3028 Wenjun 18/06/15 : allow partial success
        Database.update(new List<Zuora__Subscription__c>(setToUpd), false);
        //END D-3028 Wenjun 18/06/15
    }
    
    public static void updateAllSubsActiveFlag(Set<Id> setRecipientIds, Date runDt)
    {
        Set<Zuora__Subscription__c> setToUpd = new Set<Zuora__Subscription__c>();
        Map<ID, Zuora__Subscription__c> mapRecipientToDelSub = new Map<ID, Zuora__Subscription__c>();
        //Map<String, Zuora__Subscription__c> mapFullPreDelSub = new Map<String, Zuora__Subscription__c>(); //START END D-2921 Wenjun 12/05/15
        Set<Zuora__Subscription__c> setInActiveDelSubs = new Set<Zuora__Subscription__c>();
        Date dtExpire = runDt.addDays(-1);
        
        for(Zuora__Subscription__c sub: [SELECT Id, Name, Subscription_Type_1__c, Is_Active__c, Billing_Type__c, 
                        Recipient_Contact__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Contract_End_Date_1__c
                        FROM Zuora__Subscription__c WHERE Recipient_Contact__c IN :setRecipientIds 
                        AND (Zuora__SubscriptionEndDate__c >= :dtExpire OR Zuora__SubscriptionEndDate__c = null)
                        AND ((Subscription_Type_1__c != :SUBTYPE_DEL) OR
                          (Subscription_Type_1__c = :SUBTYPE_DEL AND Billing_Type__c = :FULL_PRE) OR
                          (Subscription_Type_1__c = :SUBTYPE_DEL AND Billing_Type__c != :FULL_PRE AND Zuora__SubscriptionStartDate__c <= :runDt)
                          ) ORDER By Name])
        {
            Boolean isActive = false;
            
            if(sub.Zuora__SubscriptionEndDate__c == dtExpire)
                setInActiveDelSubs.add(sub);
            else
            {
                /************* Process Non-Delivery Subs *****************/
                if(sub.Subscription_Type_1__c != SUBTYPE_DEL)
                {
                    if(sub.Is_Active__c != true) 
                    {
                        sub.Is_Active__c = true;
                        setToUpd.add(sub);
                    }
                }
                /************* Process Delivery Subs *****************/
                else
                {
                    if(sub.Billing_Type__c == FULL_PRE)
                    {
                        //START D-2921 Wenjun 12/05/15: all non-expired Full Prepaid are active
                        if(sub.Is_Active__c != true) 
                        {
                            sub.Is_Active__c = true;
                            setToUpd.add(sub);
                        }
                        //END D-2921 Wenjun 12/05/15
                    }
                
                    if(sub.Zuora__SubscriptionStartDate__c <= runDt)
                    {
                       if(mapRecipientToDelSub.containsKey(sub.Recipient_Contact__c))
                        {
                            Zuora__Subscription__c prevDelSub = mapRecipientToDelSub.get(sub.Recipient_Contact__c);
                            if(DeliveryChargeHelper.isHigherInHierarchy(sub,prevDelSub))
                            {
                                mapRecipientToDelSub.put(sub.Recipient_Contact__c, sub);
                                //Set pre sub to Inactive - if not Full Prepaid
                                if(prevDelSub.Billing_Type__c != FULL_PRE)
                                    setInActiveDelSubs.add(prevDelSub); 
                            }
                            else
                            {
                                if(sub.Billing_Type__c != FULL_PRE)
                                    setInActiveDelSubs.add(sub); //Set this sub to Inactive
                            }
                        }
                        else mapRecipientToDelSub.put(sub.Recipient_Contact__c, sub);
                    }
                }
            }
        }
        
        //Process Full Prepaid Del Subs
        
        //Process the "Active" del sub as of Running Date
        for(Zuora__Subscription__c delSub : mapRecipientToDelSub.values())
        {
            if(delSub.Is_Active__c != true) 
            {
                delSub.Is_Active__c = true;
                setToUpd.add(delSub);
            }
        }
        
        //Process Inactive subs
        for(Zuora__Subscription__c delSub : setInActiveDelSubs)
        {
            if(delSub.Is_Active__c != false) 
            {
                delSub.Is_Active__c = false;
                setToUpd.add(delSub);
            }
        }
        
        //UPDATE Subs
        //START D-3028 Wenjun 18/06/15 : allow partial success
        Database.update(new List<Zuora__Subscription__c>(setToUpd), false);
        //END D-3028 Wenjun 18/06/15
    }
     //END D-2777 Wenjun 16/04/15
    
    //START D-2992 Wenjun 22/05/15 :Discount Wrapper Class
    Class SPCDiscWrapper
    {
        Date effectiveDT {get;set;}
        Decimal discRate {get;set;}
        
        SPCDiscWrapper(Date inputDT, Decimal inputRate)
        {
            effectiveDT = inputDT;
            discRate = inputRate;
        }
    }
    //END D-2992 Wenjun 22/05/15
}