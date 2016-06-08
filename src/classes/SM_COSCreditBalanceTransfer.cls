/**
* Class Name: <SM_COSCreditBalanceTransfer>
* @authors: <JTeves/FritzBenzon>
* Date: <18-June-2015>
* Requirement/Project Name: <SPH>
* @description: this queuable class is for refund, payment, and credit Balance adjustment   
* process for Change of Subscription
* Balance of old billing account will be credited to the balance 
* of new billing account
* UD-3676 01/21/2016 RReyes - bulkify processBalanceTransfer() method
*/

public class SM_COSCreditBalanceTransfer {
    //private String oldBillAcctId;
    //private String newBillAcctId;
    //public Decimal oldAcctCreditBal = 0;
    private Id orderId;
    public static Logger logger = new Logger(SM_COSCreditBalanceTransfer.class.getName());  //START UD-3676 RReyes - added logger
    @future(callout=true)
    //START UD-3676 01/21/16 - bulkify method
    //public static void processBalanceTransfer(Id OrderId, String oldBillAcctId) {
    public static void processBalanceTransfer(Map<Id,String> mapOrderIdToOldBAId) {  
    //END UD-3676 01/21/16 - bulkify method
        String newBillAcctId = ' ';
        Decimal oldAcctCreditBal = 0;
        //START UD-3676 01/21/16 RReyes
        Map<String, Decimal> mapOldBAIdToOldBACB = new Map<String, Decimal>();
        Map<Id, String> mapOrderIdToNewBAId = new Map<Id, String>();
        Map<String, Zuora__CustomerAccount__c> mapOldBAIDToBARec = new Map<String, Zuora__CustomerAccount__c>();
        //END UD-3676 01/21/16 RReyes
        Zuora.zApi zApiInstance = new Zuora.zApi(); 
        try { 
            //START D-3268 Modified By C.I.Salas - Test Coverage
            if (!Test.isRunningTest()) {
                zApiInstance.zlogin();
            }
            //END D-3268 Modified By C.I.Salas - Test Coverage
        } 
        catch(Zuora.zRemoteException ex) { 
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex); 
        } 
        catch(Zuora.zAPIException ex) { 
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex); 
        } 
        catch(Zuora.zForceException ex) { 
            system.debug(GlobalVariableClass.ZUORA_ERROR+ex); 
        }
        //START UD-3676 01/21/16 - bulkify query
        String queryStr = '';
        for(String oldBAId : mapOrderIdToOldBAId.values())
            queryStr += ' OR ID=\'' + oldBAId + '\'';
        queryStr = queryStr.substring(4);
        //END UD-3676 01/21/16 - bulkify query
        //ZOQL: query credit balance from the Billing Account of the old subscription
        Zuora.zApi.QueryRequest qr = new Zuora.zApi.QueryRequest();
        qr.zoql = 'SELECT Id, Name, CreditBalance FROM Account Where ' + queryStr; //START/END UD-3676 01/21/16 - bulkify query
        //Set query options
        Zuora.zApi.QueryOptions qo = new Zuora.zApi.QueryOptions();
        qo.batchSize = 20;
        qo.caseSensitive = false;
        qr.queryOptions = qo;
        
        Zuora.zApi.QueryResult queryResult = zApiInstance.zquery(qr);
        List<Zuora.zObject> zObjList = new List<Zuora.zObject>();
        if (queryResult.size > 0) {
            zObjList.addAll(queryResult.records);
        }
        
        //START UD-3676 01/21/16 - bulkify
        if(zObjList.size() > 0) 
        {       
            //oldAcctCreditBal = Decimal.valueOf(String.valueOf(zObjList[0].getValue('CreditBalance')));
            for(Zuora.zObject zObjs : zObjList){
                String oldBAId = (String)zObjs.getValue('Id');
                Decimal creditBalance = (Decimal) zObjs.getValue('CreditBalance');
                if(oldBAId != null && creditBalance != null){
                    if(!mapOldBAIdToOldBACB.containsKey(oldBAId)){
                        mapOldBAIdToOldBACB.put(oldBAId, creditBalance);
                    }
                }
            }       
        }
        //END UD-3676 01/21/16 - bulkify
        
        //query all quotes where Order Id = orderId : 
        //START UD-3676 RReyes 01/21/16 - bulkify - put to map
        /*zqu__Quote__c quote = [Select zqu__ZuoraAccountID__c From zqu__Quote__c Where Order_Line_Item_Number_1__r.Order__c = :orderId AND Subscription_Type__c = 'Publication'];
        newBillAcctId = quote.zqu__ZuoraAccountID__c;
        system.debug(':::NEWBILLINGACCT' + ' ' + newBillAcctId);
        */
        if(mapOrderIdToOldBAId.size() > 0){
            for(zqu__Quote__c quoteRec : [SELECT zqu__ZuoraAccountID__c, Order_Line_Item_Number_1__r.Order__c FROM zqu__Quote__c WHERE Order_Line_Item_Number_1__r.Order__c IN:mapOrderIdToOldBAId.keySet() 
                                            AND Subscription_Type__c = 'Publication']){
                if(quoteRec.Order_Line_Item_Number_1__r.Order__c != null && quoteRec.zqu__ZuoraAccountID__c != null){
                    if(!mapOrderIdToNewBAId.containsKey(quoteRec.Order_Line_Item_Number_1__r.Order__c)){
                        mapOrderIdToNewBAId.put(quoteRec.Order_Line_Item_Number_1__r.Order__c, quoteRec.zqu__ZuoraAccountID__c);
                    }
                }                               
            }
            
            for(Zuora__CustomerAccount__c billAcc:[SELECT Payment_Mode__c, Zuora__Default_Payment_Method__r.Zuora__External_Id__c, Zuora__Zuora_Id__c FROM Zuora__CustomerAccount__c 
                                                    WHERE Zuora__Zuora_Id__c IN: mapOrderIdToOldBAId.values()]){
                if(billAcc.Zuora__Zuora_Id__c != null){
                    if(!mapOldBAIDToBARec.containsKey(billAcc.Zuora__Zuora_Id__c)){
                        mapOldBAIDToBARec.put(billAcc.Zuora__Zuora_Id__c, billAcc);
                    }
                }                           
            }
        }
        
        //END UD-3676 RReyes  01/21/16 - bulkify - put to map
        //TO DO: Create Refund for the billing account of old sub using Invoice Amount
        Map<String,Object> refundMap = new Map<String, Object>();
        List<Map<String, Object>> listMap = new List<Map<String, Object>>();
        String paymentMode = ' ';
        Map<String, Object> paymentMap = new Map<String, Object>();
        List<Map<String, Object>> paymentMapList = new List<Map<String, Object>>();
        Date dateToday = date.today();
        Set<String> BillingAccountId = new Set<String>();
        //START UD-3676 RReyes  01/21/16  - bulkify , removed condition on refund, added logger.save, changed system.debug to logger
        ZuoraCallOut zCallOut = new ZuoraCallOut();
        //BillingAccountId.add(newBillAcctId);
        //BillingAccountId.add(oldBillAcctId);
        for(String oldBAId: mapOrderIdToOldBAId.values()){
            if(!BillingAccountId.isEmpty()){
                if(!BillingAccountId.contains(oldBAId)){
                    BillingAccountId.add(oldBAId);
                }else{
                    BillingAccountId.add(oldBAId);
                }
            }
        }
        for(String newBAId: mapOrderIdToNewBAId.values()){
            if(!BillingAccountId.isEmpty()){
                if(!BillingAccountId.contains(newBAId)){
                    BillingAccountId.add(newBAId);
                }else{
                    BillingAccountId.add(newBAId);
                }
            }
        }
        
        system.debug(':::BILLACCTS');
        //START UD-2249 9/26/15 AddedBy FrancisBenzon : do not create refund and payment for use existing BA
        //if(oldAcctCreditBal > 0 && oldBillAcctId != newBillAcctId) {
        
        //END UD-2249 9/26/15 AddedBy FrancisBenzon : do not create refund and payment for use existing BA
         if(mapOrderIdToOldBAId.size() > 0){   
            for(String orderId : mapOrderIdToOldBAId.keySet()){
                
                String oldBAId = mapOrderIdToOldBAId.get(orderId);
                String newBAId = mapOrderIdToNewBAId.get(orderId);
                Decimal oldBACreditBal = mapOldBAIdToOldBACB.get(oldBAId);
                Zuora__CustomerAccount__c BillingAccount_OldSub = mapOldBAIDToBARec.get(oldBAId);
                
                if(oldBACreditBal > 0 && oldBAId != newBAId){
                    if(BillingAccount_OldSub.Payment_Mode__c != null){
                        paymentMode = BillingAccount_OldSub.Payment_Mode__c;
                    }
                    else{
                        paymentMode = GlobalVariableClass.CASH;
                    }
                    // START UD-2498 10/23/2015 K. Tan
                    refundMap.put('AccountId', oldBAId);                    
                    refundMap.put('Amount', oldBACreditBal);                                   
                    refundMap.put('SourceType', 'CreditBalance');
                    refundMap.put('Type', 'External' );             
                    refundMap.put('MethodType', paymentMode);                   
                    listMap.add(refundMap); // START-END-3829 10/28/2015 K. Tan
                    // END-2498 10/23/2015 K. Tan
      
                    //TO DO : create Payment to new Billing Account using credit Balance of old to new subscription
                    paymentMap.put('AccountId', newBAId);   
                    paymentMap.put('EffectiveDate', Zuora.Zutil.getZuoraDate(dateToday)); //today
                    paymentMap.put('PaymentMethodId', ConstantsSLB.getKeyId('PaymentMethodId_Cash'));
                    paymentMap.put('Amount', oldBACreditBal);
                    paymentMap.put('AppliedCreditBalanceAmount', oldBACreditBal);
                    paymentMap.put('Type', 'External');
                    paymentMap.put('Status', 'Processed');
                    
                    paymentMapList.add(paymentMap);
                }
            }          
        }
        
        if (!listMap.isEmpty()){
            List<Map<String,String>> resultMapRefund = zCallOut.loadZObjects(listMap, 'Refund');
            for(Map<String,String> resultMap : resultMapRefund)
            {
                //UD-3676 - changed system.debug to logger
                if(resultMap.get('Status') != 'Success') 
                {
                    logger.log(false, '[SM_COSCreditBalanceTransfer] Refund Error: ' + resultMap.get('Message') + ' - (Refund) listMap: ' + listMap);
                }
            }       
        }
             
            system.debug(':::PAYMENTMAPLIST' + ' ' + paymentMapList);
        if (!paymentMapList.isEmpty()) 
        {
            List<Map<String,String>> resultMapPayment = zCallOut.loadZObjects(paymentMapList, 'Payment');
            
            for(Map<String,String> resultMap : resultMapPayment)
            {
                //UD-3676 - changed system.debug to logger
                if(resultMap.get('Status') != 'Success') 
                {
                    logger.log(false, '[SM_COSCreditBalanceTransfer] Payment Error: ' + resultMap.get('Message') + ' - paymentMapList: ' + paymentMapList);
                }
            }       
        } 
        logger.save();//UD-3676 RReyes 01/25/16 RReyes - added logger.save()
    //END UD-3676 RReyes  01/21/16  - bulkify , removed condition on refund, added logger.save, changed system.debug to logger
        //Perform Zuora Sync
        Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
        syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
        syncManager.syncZuoraObjectIdSet  = BillingAccountId;
        syncManager.emailNotificationEnabled = false;
        List<Zuora.SyncResult> syncResult = syncManager.sendRequest();
        System.debug('>>>>> Sync Result:' + syncResult);        
    }
}