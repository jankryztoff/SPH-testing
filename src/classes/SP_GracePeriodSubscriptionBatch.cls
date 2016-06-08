/**
* Class Name: SP_GracePeriodSubscriptionBatch
* @author: Alyana Navarro & Jayson Sarion
* Date: 
* Requirement/Project Name: CRSM Project
* @description: Batch Apex Class to Create Grace Period Subscriptions
*
* History: 12/15/14 Product Catalogue  Kevin Evasco - Updated to include proration charges
* History: D-1826 20/01/15 Wenjun : Add support for Postage Charges and fix bugs
* History: D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
*/ 

global class SP_GracePeriodSubscriptionBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
   
  //START D-0810 Created by Francis Benzon 12/8/2014 *Custom Setting for Configurable End Date
  Integer configurableNumberOfDays = Integer.valueOf(ConstantsSLB.getKeyId('GracePeriodDaysBeforeEndDate'));
  Date endDate = date.today().addDays(configurableNumberOfDays); 
  //END D-0810 Created by Francis Benzon 12/8/2014 *Custom Setting for Configurable End Date
  Renewal_Quote_Handler_Bulk quoteHandler = new Renewal_Quote_Handler_Bulk();
  Global Set<String> returnSet = new Set<String>();
  Global String origin = 'Grace';
  Global Set<string> quoteAccountZuoraIdSet = new Set<string>();
  Global Set<id> orderIdSet = new Set<id>();
  Set<Id> orderListIdSet = new Set<Id>();
  
  
  Map<Id,Zuora__Subscription__c> subscriptionMap = new Map<Id,Zuora__Subscription__c>(); //START/END D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
  
  /*
   * Description: Main query
   * Parameter: 
   * Return:
   */
  global Database.QueryLocator start(Database.BatchableContext BC) {
    //START D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
        //START D-2497 &&   Added by J. Sarion 04/27/2015 - Added additional fields 
		return Database.getQueryLocator([SELECT id, name, main_package_1__c, subscription_type_1__c,
                         zuora__subscriptionStartDate__c, Zuora__Account__c, Order_Line_Item_Number_1__c,
                         zuora__subscriptionEndDate__c, Recipient_Contact__c, Order_Number_1__c, Order_Number_1__r.Billing_Type__c,
                         Grace_Period_Subscription__c, Zuora__CustomerAccount__r.Billing_Type__c, 
                         Recipient_Contact__r.Address__r.RecordTypeId, Order_Number_1__r.Delivery_Charge_Type__c,
                         Sponsor_1__c, Term_Length__c, Order_Number_1__r.Account__r.Id, Zuora__CustomerAccount__r.Zuora__Account__r.Id
                         FROM Zuora__Subscription__c 
                         WHERE zuora__status__c = 'Active' AND  Zuora__SubscriptionEndDate__c =: endDate
                         AND Zuora__AutoRenew__c = FALSE AND Subscription_Type_1__c = 'Publication' AND Grace_Period_Subscription__c = null]);
        //END D-2497 &&   Added by J. Sarion 04/27/2015 - Added additional fields 
    //END D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
                     
  }
  
  /*
   * Description: Main method
   * Parameter: 
   * Return:
   */
  global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> subscriptionList){
    //START D-1960 04/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class.
    try
    {
    //END D-1960 04/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class.
      //Renewal_Quote_Handler_Bulk quoteHandler = new Renewal_Quote_Handler_Bulk();
    
      Set<id> subIdSet = new Set<id>();
      Set<id> orderLineItemIdSet = new Set<id>();
      Set<id> packageIdSet = new Set<id>();
      Map<id, zqu__ProductRatePlan__c> subProdRatePlanMap = new Map<id, zqu__ProductRatePlan__c>();
      Map<id, Product_Family__c> subProdFamilyMap = new Map<id, Product_Family__c>();
      Map<id, Grace_Period__c> subGracePeriodMap = new Map<id, Grace_Period__c>();
      Map<id, Package__c> packageMap = new Map<id, Package__c>();
      List<Zuora__Subscription__c> newSubscriptionList = new List<Zuora__Subscription__c>();
      List<Order_Line_Item__c> orderLineItemList = new List<Order_Line_Item__c>();
     List<Order__c> orderList = new List<Order__c>();
      List<Package__c> packageList = new List<Package__c>();
      //START D-0810 By: Francis Benzon 
      Integer gracePeriodDays; 
      Map<Id, Zuora__Subscription__c> oliIdToSubMap = new Map<Id, Zuora__Subscription__c>();      
      //END D-0810 By: Francis Benzon 
      
      // START 12/15/14 Product Catalogue  Kevin Evasco - Updated to include proration charges
      quoteHandler.source = 'Grace Period Batch';
      // END 12/15/14 Product Catalogue  Kevin Evasco - Updated to include proration charges      
      
      system.debug('subscription List  :  '  + subscriptionList);
          //START D-2497 &&   Added by J. Sarion 04/27/2015 - Billing Account and Order must have the same Billing Type
          for(Zuora__Subscription__c sub : subscriptionList){
            if (sub.Order_Number_1__r.Billing_Type__c.contains(sub.Zuora__CustomerAccount__r.Billing_Type__c) && sub.Zuora__CustomerAccount__r.Billing_Type__c != null && sub.Order_Number_1__r.Account__r.Id == sub.Zuora__CustomerAccount__r.Zuora__Account__r.Id) {
                newSubscriptionList.add(sub);
                subIdSet.add(sub.id);
                subscriptionMap.put(sub.Id,sub);
            }
          }
          //END D-2497 &&   Added by J. Sarion 04/27/2015 - Billing Account and Order must have the same Billing Type
      subProdRatePlanMap = getProductRatePlan(subIdSet);
      subProdFamilyMap = getProductFamily(subProdRatePlanMap);
      subGracePeriodMap = getGracePeriod(subProdFamilyMap);
      
      //START D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
          //START D-2497 &&   Added by J. Sarion 04/27/2015 - Billing Account and Order must have the same Billing Type
		  for(Zuora__Subscription__c sub : newSubscriptionList){
		  //END D-2497 &&   Added by J. Sarion 04/27/2015 - Billing Account and Order must have the same Billing Type
        Boolean subjectForGracePeriod = false;
        Grace_Period__c subGracePeriod = subGracePeriodMap.get(sub.Id);
        
        if(subGracePeriod != null){
          if(subGracePeriod.Grace_Days__c > 0){
            if(sub.Term_Length__c >= subGracePeriod.Minimum_Subscription_Period_months__c){  
              if(subGracePeriod.Local_Subscription_Indicator__c && sub.Recipient_Contact__r.Address__r.RecordTypeId == ConstantsSLB.getkeyid('Address_Local')){              
                subjectForGracePeriod = true;
                System.debug('Grace Period: Local Subscription');
              }
              else if(subGracePeriod.Overseas_Subscription_Indicator__c && sub.Recipient_Contact__r.Address__r.RecordTypeId == ConstantsSLB.getkeyid('Address_Overseas')){          
                subjectForGracePeriod = true;
                System.debug('Grace Period: OVerseas Subscription');
              }
              else if(subGracePeriod.Airline_Subscription_Indicator__c && sub.Recipient_Contact__r.Address__r.RecordTypeId == ConstantsSLB.getkeyid('Address_Airline')){          
                subjectForGracePeriod = true;
                System.debug('Grace Period: Airline Subscription');
              }
              else if(subGracePeriod.Sponsored_Subscription_Indicator__c && sub.Sponsor_1__c){          
                subjectForGracePeriod = true;
                System.debug('Grace Period: Sponsored Subscription');
              }
              else if(subGracePeriod.Special_Delivery_Fee_Indicator__c && sub.Order_Number_1__r.Delivery_Charge_Type__c == 'S'){  
                subjectForGracePeriod = true;
                System.debug('Grace Period: Sponsored Subscription');
              }
              else if(subGracePeriod.Allow_frequency_other_than_Default__c){
                subjectForGracePeriod = true;
                System.debug('Grace Period: Allow frequency other than default');
              }
              else if(subProdRatePlanMap.containsKey(sub.id)){ 
                if(subProdRatePlanMap.get(sub.id).SubscriptionFrequency__c == '0'){
                  subjectForGracePeriod = true;
                  System.debug('Grace Period: Subscription Frequency is 0');
                }        
                else{              
                  System.debug('Grace Period: Subscription Frequency is not 0');
                }

              }
              
              if(subjectForGracePeriod)
              {
                orderIdSet.add(sub.Order_Number_1__c);
                orderLineItemIdSet.add(sub.Order_Line_Item_Number_1__c);
                // START Code Review 2/18/2015 Jean Cari�o
                if(sub.main_package_1__c != null){
                    packageIdSet.add(sub.main_package_1__c);
                }
                // END Code Review 2/18/2015 Jean Cari�o
                //START: D-0810 Added by FrancisBenzon Map needed
                oliIdToSubMap.put(sub.Order_Line_Item_Number_1__c, sub); 
                system.debug('>>>>OLISUBMAP' + oliIdToSubMap);
                //END: D-0810 Added by FrancisBenzon Map needed
              }
            }
          }
        }
        else{
          System.debug('No Grace Period record for this product family. ');
        }
      }
      //END D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
      
      //START D-0821 1/8/2015 Added By C. Lin - Remove Renewal_Package_Code__c from the query. Not in use and should be deleted in the Package Object.
      
      // START Code Review 2/18/2015 Jean Cari�o
      if(packageIdSet.size() > 0){
            packageList = [SELECT id, name, Package_Code__c FROM Package__c WHERE id IN : packageIdSet];
      }
      // END Code Review 2/18/2015 Jean Cari�o
      
      //END D-0821 1/8/2015 Added By C. Lin
      for(Package__c pack : packageList){
        packageMap.put(pack.id, pack);
      }
      
      orderList = createOrder(orderIdSet);

      for(Order__c orderId : orderList){
	//START D-2497 &&   Added by J. Sarion 04/27/2015 - Billing Account and Order must have the same Billing Type
			if (orderId.Id != null) 
				orderListIdSet.add(orderId.Id);
          } 
          system.debug('>>>>>orderListIdSet ' + orderListIdSet);
		  if (!orderListIdSet.isEmpty()) {
			orderList = [SELECT Id, Name, Subscription__c, Recipient_Contact__c FROM Order__c WHERE Id IN :orderListIdSet];
		  }
      //END D-2497 &&   Added by J. Sarion 04/27/2015 - Billing Account and Order must have the same Billing Type
      orderLineItemList = getOrderLineItem(orderLineItemIdSet, packageMap, orderList, oliIdToSubMap, subGracePeriodMap);//START/END D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
      
      quoteAccountZuoraIdSet = quoteHandler.bulkQuoteCreation(orderListIdSet, origin);
      system.debug('EXECUTE' + orderIdSet);
      system.debug('EXECUTE' + quoteAccountZuoraIdSet);
      system.debug('EXECUTE' + origin);
      
    //START D-1960 04/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class.
    }
    catch(Exception e)
    {
      ExceptionLogger.log(new List<Exception>{e});
    }       
    //END D-1960 04/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class.
  }
  
  global void finish(Database.BatchableContext BC) {
    //START D-1960 04/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class.
    if(quoteAccountZuoraIdSet.size() > 0)
    {
    //END D-1960 04/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class.
      system.debug('FINISH' + orderIdSet);
      system.debug('FINISH' + returnSet);
      system.debug('FINISH' + origin);
      //Map<id, Grace_Period__c> subGracePeriodMap = new Map<id, Grace_Period__c>();
      SendQuotesToZuoraMultipleAccount sendQuotes = new SendQuotesToZuoraMultipleAccount(orderListIdSet, quoteAccountZuoraIdSet, origin);
      Database.executeBatch(sendQuotes);          
    //START D-1960 04/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class.
    }       
    //END D-1960 04/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class.
    
    String shortID = String.valueOf(BC.getJobId()).subString(0,15);
    List<BATCH_JOB_SCHEDULER__c> batchJobSchedulerList = [SELECT Id, Status__c, Batch_Code__c, Batch_Run_Date__c, SFDC_Job_id__c FROM BATCH_JOB_SCHEDULER__c WHERE SFDC_Job_id__c = :shortID OR SFDC_Job_id__c = :BC.getJobId()];       
    
    if(batchJobSchedulerList.size() > 0)
    {
      BATCH_JOB_SCHEDULER__c batchJobScheduler = batchJobSchedulerList.get(0);
      batchJobScheduler.Status__c = 'SUCCESS';
      batchJobScheduler.End_Time__c = DateTime.now();
      
      BatchServiceFacade a1F = new BatchServiceFacade();
      BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
      serviceRequestVO.setJobStatus(0);
      serviceRequestVO.setJobID(batchJobScheduler.Batch_Code__c);
      serviceRequestVO.setJobDate(batchJobScheduler.Batch_Run_Date__c);
      a1F.delegateBatchCall(serviceRequestVO);
      
      update batchJobScheduler; //START/END D-1960 04/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class.           
    }
  }
  
  public Map<id, zqu__ProductRatePlan__c> getProductRatePlan(Set<id> subIdSet){
    Set<String> prodSKU = new Set<String>();
    List<Zuora__SubscriptionProductCharge__c> subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();
    Map<id, Set<String>> prodSKUSetMap = new Map<id, Set<String>>();        
    List<zqu__ProductRatePlan__c> prodRatePlanList = new List<zqu__ProductRatePlan__c>();
    Map<String, zqu__ProductRatePlan__c> prodRatePlanMap = new Map<String, zqu__ProductRatePlan__c>();
    Map<id, zqu__ProductRatePlan__c> subProdRatePlanMap = new Map<id, zqu__ProductRatePlan__c>();
    
                //START Code Review Jean Cari�o 2/18/2015 : check subIdSet if null
                if(subIdSet.size() > 0){
    subProdChargeList = [SELECT id, name, Zuora__Subscription__c, Zuora__RatePlanName__c, Zuora__ProductSKU__c
               FROM Zuora__SubscriptionProductCharge__c 
               WHERE Zuora__Subscription__c IN : subIdSet];
    }
                //END Code Review Jean Cari�o 2/18/2015 : check subIdSet if null
    for(Zuora__SubscriptionProductCharge__c subProdCharge : subProdChargeList){
      //START Code Review Jean Cari�o 2/18/2015 : check Zuora__ProductSKU__c if null
      if(subProdCharge.Zuora__ProductSKU__c != null){
        prodSKU.add(subProdCharge.Zuora__ProductSKU__c);
      }
      //END Code Review Jean Cari�o 2/18/2015 : check Zuora__ProductSKU__c if null
      
      if(prodSKUSetMap.containsKey(subProdCharge.Zuora__Subscription__c)){
        prodSKUSetMap.get(subProdCharge.Zuora__Subscription__c).add(subProdCharge.Zuora__ProductSKU__c);
      } else{
        prodSKUSetMap.put(subProdCharge.Zuora__Subscription__c, new Set<String>{subProdCharge.Zuora__ProductSKU__c});
      }
    }
    //START Code Review Jean Cari�o 2/18/2015 : check prodSKU if null
    if(prodSKU.size() > 0){
        prodRatePlanList = [SELECT id, name, zqu__ZProduct__c, RatePlanType__c, zqu__ZProduct__r.ProductFamily__c,
              SubscriptionFrequency__c, zqu__ZProduct__r.zqu__SKU__c
              FROM zqu__ProductRatePlan__c 
              WHERE zqu__ZProduct__r.zqu__SKU__c IN : prodSKU AND RatePlanType__c = 'Bill Plan'];
    }
    //END Code Review Jean Cari�o 2/18/2015 : check prodSKU if null
    
    for(zqu__ProductRatePlan__c prodRatePlan : prodRatePlanList){
      prodRatePlanMap.put(prodRatePlan.zqu__ZProduct__r.zqu__SKU__c, prodRatePlan);
    }           
    
    for(Id subId : subIdSet){
      if(prodSKUSetMap.containsKey(subId)){
        for(String sku : prodSKUSetMap.get(subId)){
          if(prodRatePlanMap.containsKey(sku)){
            subProdRatePlanMap.put(subId, prodRatePlanMap.get(sku));
          }
        }               
      }
    }
    
    return subProdRatePlanMap;
  }
  
  public Map<id, Product_Family__c> getProductFamily(Map<id, zqu__ProductRatePlan__c> subProdRatePlanMap){
    List<Product_Family__c> prodFamilyList = new List<Product_Family__c>();
    Set<String> prodFamilySet = new Set<String>();
    Map<String, Product_Family__c> prodFamilyMap = new Map<String, Product_Family__c>();
    Map<id, Product_Family__c> subProdFamilyMap = new Map<id, Product_Family__c>(); 
    
    for(Id subId : subProdRatePlanMap.keySet()){
      //START Code Review Jean Cari�o 2/18/2015 : check ProductFamily__c if null
      if(subProdRatePlanMap.get(subId).zqu__ZProduct__r.ProductFamily__c != null){
        prodFamilySet.add(subProdRatePlanMap.get(subId).zqu__ZProduct__r.ProductFamily__c);
      }
      //END Code Review Jean Cari�o 2/18/2015 : check ProductFamily__c if null
    }
    
                //START Code Review Jean Cari�o 2/18/2015 : check prodFamilySet if null
                if(prodFamilySet.size() > 0){
    prodFamilyList = [SELECT id, name, Product_Family__c FROM Product_Family__c WHERE Product_Family__c IN : prodFamilySet]; //START/END D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
    }
                //END Code Review Jean Cari�o 2/18/2015 : check prodFamilySet if null
    for(Product_Family__c prodFamily : prodFamilyList){
      prodFamilyMap.put(prodFamily.Product_Family__c, prodFamily);
    }
    
    for(Id subId : subProdRatePlanMap.keySet()){
      if(prodFamilyMap.containsKey(subProdRatePlanMap.get(subId).zqu__ZProduct__r.ProductFamily__c)){
        subProdFamilyMap.put(subId, prodFamilyMap.get(subProdRatePlanMap.get(subId).zqu__ZProduct__r.ProductFamily__c));
      }
    }
    
    return subProdFamilyMap;
  }
  
  public Map<id, Grace_Period__c> getGracePeriod(Map<id, Product_Family__c> subProdFamilyMap){
    Set<id> prodFamilySet = new Set<id>();
    List<Grace_Period__c> gracePeriodList = new List<Grace_Period__c>();
    Map<id, Grace_Period__c> gracePeriodMap = new Map<id, Grace_Period__c>();
    Map<id, Grace_Period__c> subGracePeriodMap = new Map<id, Grace_Period__c>();
    
    for(Id subId : subProdFamilyMap.keySet()){    
        prodFamilySet.add(subProdFamilyMap.get(subId).id);    
    }
    
    //START D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
    
    //START Code Review Jean Cari�o 2/18/2015 : check prodFamilySet if null
    if(prodFamilySet.size() > 0){
        gracePeriodList = [SELECT id, name, Product_Family__c, Allow_frequency_other_than_Default__c, Minimum_Subscription_Period_months__c,
              Local_Subscription_Indicator__c, Overseas_Subscription_Indicator__c, Airline_Subscription_Indicator__c, Sponsored_Subscription_Indicator__c, Special_Delivery_Fee_Indicator__c, Grace_Days__c
               FROM Grace_Period__c 
               WHERE Product_Family__c IN : prodFamilySet AND Active__c = TRUE];
    }
    //END Code Review Jean Cari�o 2/18/2015 : check prodFamilySet if null
    
    //END D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
    
    for(Grace_Period__c gracePeriod : gracePeriodList){
      gracePeriodMap.put(gracePeriod.Product_Family__c, gracePeriod);
    }
    
    for(Id subId : subProdFamilyMap.keySet()){
      if(gracePeriodMap.containsKey(subProdFamilyMap.get(subId).id)){
        subGracePeriodMap.put(subId, gracePeriodMap.get(subProdFamilyMap.get(subId).id));
      }
    }
    
    return subGracePeriodMap;
  }
  
  public List<Order__c> createOrder(Set<Id> orderIdSet){
    Order__c orderRec;
    List<Order__c> orderList = new List<Order__c>();
    List<Order__c> newOrderList = new List<Order__c>();     
    /*Start D-0810 By: Francis Benzon 
    *Description: query subscriptions using order Ids and put to map then populate sub field in order record
    *Date: 12/10/2014       
    */
    List<Zuora__Subscription__c> subsWrtToOrderIds = new List<Zuora__Subscription__c>();
    List<Order__c> updateOrderList = new List<Order__c>();
    Map<Id, Id> orderToSubscriptionMap = new Map<Id, Id>();
                
                
    try {
        //START Code Review Jean Cari�o 2/18/2015 : check orderIdSet if null 
      if(orderIdSet.size() > 0){
			//START D-2497 &&   Added by J. Sarion 04/27/2015 - Billing Account and Order must have the same Billing Type
            subsWrtToOrderIds = [SELECT Id, Name, Order_Number_1__c, Zuora__CustomerAccount__c FROM Zuora__Subscription__c WHERE Order_Number_1__c IN :orderIdSet AND Subscription_Type_1__c = 'Publication']; //START/END D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
			//END D-2497 &&   Added by J. Sarion 04/27/2015 - Billing Account and Order must have the same Billing Type
      }
        //END Code Review Jean Cari�o 2/18/2015 : check orderIdSet if null 
    }
    catch(exception e) {
      system.debug(e.getMessage());
    }
    if(subsWrtToOrderIds != null) {
      for(Zuora__Subscription__c subIteration : subsWrtToOrderIds) {
        orderToSubscriptionMap.put(subIteration.Order_Number_1__c, subIteration.Id);
        subscriptionMap.put(subIteration.Order_Number_1__c, subIteration); //START/END D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
      }
    }
    
    //START Code Review Jean Cari�o 2/18/2015 : check orderIdSet if null 
      if(orderIdSet.size() > 0){
        orderList = [SELECT id, name FROM Order__c WHERE id IN : orderIdSet];
      }
    //END Code Review Jean Cari�o 2/18/2015 : check orderIdSet if null 
    
    for(Order__c ords : orderList) {
      ords.Subscription__c = orderToSubscriptionMap.get(ords.Id);
      //START D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
      ords.Billing_Account__c = subscriptionMap.get(ords.Id).Zuora__CustomerAccount__c;
      ords.Billing_Account_Creation_Mode__c = 'Use existing Billing Account';  
      //END D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
      updateOrderList.add(ords);
    }   
    
    // START 12/15/14 Product Catalogue Kevin Evasco - Cannot perform insert for existing records. Changed DML from insert to update
    update updateOrderList;     
    // END 12/15/14 Product Catalogue Kevin Evasco - Cannot perform insert for existing records. Changed DML from insert to update
    //End D-0810 By: Francis Benzon
        
    for(sObject sObj : SObjectAllFieldCloner.cloneObjects(updateOrderList, updateOrderList.getsObjectType())){
      newOrderList.add((Order__c) sObj);
    }
    
    /*for(Zuora__Subscription__c sub : subList){
      orderRec = new Order__c();
      orderRec.Account__c = sub.Zuora__Account__c;
      orderRec.Subscription_Start_Date__c = date.today() + 2;
      orderRec.Payment_Mode__c = sub.Payment_Mode__c;
      orderRec.Billing_Contact__c = sub.Contact__c;
      orderRec.Recipient_Contact__c = sub.Recipient_Contact__c;
      orderRec.Payment_Method_ID__c = sub.Zuora__CustomerAccount__r.Zuora__DefaultPaymentMethod__c;
      orderRec.Subscriber_Charge__c = sub.Subscription_Charge__c;
      orderRec.Delivery_Charge_Type__c = sub.Delivery_Charge_Type_1__c;
      orderRec.Subscription__c = sub.id;
      
      orderList.add(orderRec);
    }*/
    
    if(!newOrderList.isEmpty()) {
      List<Database.Saveresult> saveResults = Database.insert(newOrderList, false); 
      for(Database.Saveresult sr : saveResults) {
        if(!sr.isSuccess()) {
          //error handling tbd
        }
      } 
    }
    
    return newOrderList;
  }
  
  public List<Order_Line_Item__c> getOrderLineItem(Set<id> orderLineItemIdSet, Map<id, Package__c> packageMap, List<Order__c> orderList, Map<Id, Zuora__Subscription__c> oliSubMap, Map<id, Grace_Period__c> subGracePeriodMap){ //START/END D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
    //SObjectAllFieldCloner sObjectCloner = new SObjectAllFieldCloner();
    Order__c orderRec = new Order__c();     
    Map<id, Order__c> subOrderMap = new Map<id, Order__c>();        
    List<Order_Line_Item__c> orderLineItemList = new List<Order_Line_Item__c>();
    List<Order_Line_Item__c> newOrderLineItemList = new List<Order_Line_Item__c>();  
    //START 20/01/15 Wenjun : Remove this list - cause double insertion
    //List<Order_Line_Item__c> oliToUpdateList = new List<Order_Line_Item__c> (); //START/END D-0810 By: FrancisBenzon
    //END 20/01/15 Wenjun   
    
    //START Code Review Jean Cari�o 2/18/2015 : check orderLineItemIdSet if null 
    if(orderLineItemIdSet.size() > 0){
        orderLineItemList = [SELECT id, name, Main_Package_ID__c FROM Order_Line_Item__c WHERE id IN : orderLineItemIdSet];
    }
    //END Code Review Jean Cari�o 2/18/2015 : check orderLineItemIdSet if null     
    
    for(sObject sObj : SObjectAllFieldCloner.cloneObjects(orderLineItemList, orderLineItemList.getsObjectType())){
      newOrderLineItemList.add((Order_Line_Item__c) sObj);
    }       
    
    //newOrderLineItemList = (Order_Line_Item__c) sObjectCloner.cloneObjects(orderLineItemList.orderLineItemList[0].getsObjectType());          
    
    for(Order__c order : orderList){
      subOrderMap.put(order.Subscription__c, order);
    }
    
    for(Order_Line_Item__c orderLineItem : newOrderLineItemList){ 
      if(subOrderMap.containsKey(id.valueOf(orderLineItem.Subscription_Id__c))){ 
        orderRec = subOrderMap.get(id.valueOf(orderLineItem.Subscription_Id__c));
	//START D-2497 &&   Added by J. Sarion 04/27/2015 - Billing Account and Order must have the same Billing Type
	if (orderRec.id != null)
        orderLineItem.order__c = orderRec.id;
	//END D-2497 &&   Added by J. Sarion 04/27/2015 - Billing Account and Order must have the same Billing Type

        //Start D-0810 By: Francis Benzon
        try {
          orderLineItem.Start_Date__c = orderLineItem.End_Date__c.addDays(1);
          //START D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.
          orderLineItem.End_Date__c = orderLineItem.Start_Date__c.addDays(Integer.valueOf(subGracePeriodMap.get(orderLineItem.Subscription_Id__c).Grace_Days__c)); orderLineItem.Term_Length__c = Integer.valueOf(subGracePeriodMap.get(orderLineItem.Subscription_Id__c).Grace_Days__c)/31+1; orderLineItem.Grace_Days__c = Integer.valueOf(subGracePeriodMap.get(orderLineItem.Subscription_Id__c).Grace_Days__c); 
          //END D-1960 and D-1686 12/02/15 Kevin Evasco : Added error handling and utilized the ExceptionLogger class. Implemented usage of Grace Period configuration.

        }
        catch(exception e) {
          system.debug(e.getMessage());        
        }
        //START 20/01/15 Wenjun : Remove this list - cause double insertion
        //oliToUpdateList.add(orderLineItem);
        //END 20/01/15 Wenjun 
        //End D-0810 By: Francis Benzon
      }           
    }
    //START D-0810 By: FrancisBenzon
    //START 20/01/15 Wenjun : Change from oliToUpdateList to newOrderLineItemList
    INSERT newOrderLineItemList;
    //END 20/01/15 Wenjun 
    //END D-0810 By: FrancisBenzon
    
    //START 20/01/15 Wenjun : Use DML instead of Database.insert as currently not designed to handle partial success
    /*
    if(!newOrderLineItemList.isEmpty()) {
      List<Database.Saveresult> saveResults = Database.insert(newOrderLineItemList, false); 
      for(Database.Saveresult sr : saveResults) {
        if(!sr.isSuccess()) {
          //error handling tbd
        }
      } 
    }
    */
    //END 20/01/15 Wenjun
    
    //START D-1826 20/01/15 Wenjun: Updating with Latest Postage Charges
    // Map Storing Order to Recipient Contact ID mapping
    Map<Id,Id> mapOrderIdToContactId = new Map<Id, Id>();
    for(Order__c newOrder : orderList)
      mapOrderIdToContactId.put(newOrder.Id, newOrder.Recipient_Contact__c);
    
    Map<Id, Decimal> mapItemIdToPostageCharge = PostageChargeHelper.getPostageChargesForLineItems(mapOrderIdToContactId,newOrderLineItemList);   
    for(Order_Line_Item__c itemObj : newOrderLineItemList)    
    {
      itemObj.Postage_Charge__c = mapItemIdToPostageCharge.get(itemObj.Id);
    }
    UPDATE newOrderLineItemList;
    //END D-1826 20/01/15 Wenjun
    
    return newOrderLineItemList;
  }   
}