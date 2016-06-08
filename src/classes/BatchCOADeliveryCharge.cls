/**
 * Class Name:  BatchCOADeliveryCharge
 * @author: Zhu, Wenjun
 * Date: 25 March 2015
 * Requirement/Project Name: CRSM Project
 * @description: Batch to change delivery charge during COA
 */
 
global class BatchCOADeliveryCharge implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {    
    //START D-3243 07/16/2015 Added by J.Sarion - Get Job ID
    //START UD-2162 08/17/2015 Added by J.Sarion - Update map to Id to Set of String
    global Map<ID, Set<String>> mapNewContactToSub = new Map<ID, Set<String>>();
    //END UD-2162 08/17/2015 Added by J.Sarion - Update map to Id to Set of String
    global Set<Id> setBillingAccountId = new Set<Id>();
    global Map<String, Id> mapDelZuoraIdToOldAddressId = new Map<String, Id>();
    //END D-3243 07/16/2015 Added by J.Sarion - Get Job ID
    
    //START D-3243 07/16/2015 Added by J.Sarion - Get Job ID
    global final Id JOB_ID;
    //END D-3243 07/16/2015 Added by J.Sarion - Get Job ID
    
    //START UD-2162 08/17/2015 Added by J.Sarion - Update map to Id to Set of String
    global BatchCOADeliveryCharge(Map<ID, Set<String>> mapNewContactToSub, Map<String, Id> mapDelZuoraIdToOldAddressId){
    //END UD-2162 08/17/2015 Added by J.Sarion - Update map to Id to Set of String
      this.mapNewContactToSub = mapNewContactToSub;
      this.mapDelZuoraIdToOldAddressId = mapDelZuoraIdToOldAddressId;
    }
    
    //START D-3243 07/16/2015 Added by J.Sarion - Get Job ID
    //START UD-2162 08/17/2015 Added by J.Sarion - Update map to Id to Set of String
    global BatchCOADeliveryCharge(Map<ID, Set<String>> mapNewContactToSub, Map<String, Id> mapDelZuoraIdToOldAddressId, Id jobID){
    //END UD-2162 08/17/2015 Added by J.Sarion - Update map to Id to Set of String
        JOB_ID = jobID;
        this.mapNewContactToSub = mapNewContactToSub;
        this.mapDelZuoraIdToOldAddressId = mapDelZuoraIdToOldAddressId;
    }
    //END D-3243 07/16/2015 Added by J.Sarion - Get Job ID
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Set<Id> setContactIds = mapNewContactToSub.keyset();
        System.debug('=============>' + setContactIds);
        String query = 'SELECT Id, FirstName, LastName, Salutation, NRIC__c, Passport__c, Billing_Account_Name_2__c, ';
        query += ' Company_Name__c, City_Code__c, Remarks__c, Business_Address_Indicator__c, Billing_Indicator__c, ';
        query += ' Recipient_Indicator__c, HomePhone__c, Mobile_Number__c, Mobile_Number_2__c, Office_Number__c, ';
        query += ' Office_Extension__c, Fax__c, Email__c, Email_Secondary__c, Address__c, RecordTypeId, AccountId, ';
        query += ' Address__r.Postal_Code__r.Building_Name__c, Address__r.Postal_Code__r.House_Block_Number__c, ';
        query += ' Address__r.Postal_Code__r.Street_Name__c, Address__r.Building_Name__c, Address__r.Address_Type__c, ';
        query += ' Address__r.Street_Name__c, Address__r.Block_House_Number__c, Address__r.City__r.Name, Address__r.Country_Name__c, ';
        query += ' Address__r.Postal_Code__r.Name FROM Contact WHERE Id IN :setContactIds'; 
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> lstContacts){
        //START UD-2162 08/18/2015 Added by J.Sarion - Change from List to Set
        Set<Id> conAddressIDs = new Set<Id>();
        //END UD-2162 08/18/2015 Added by J.Sarion - Change from List to Set
        Map<Id,Id> mapNewConToAddressId = New Map<Id,Id>();
        Map<String, Zuora__Subscription__c> mapZuoraIdToDelSub = New Map<String, Zuora__Subscription__c>();
        Map<Id,String> conAddressTypeMap = New Map<Id,String>();
        Map<Id,String> oldConAddressTypeMap = New Map<Id,String>();
        List<Id> oldDeliverySubConAddressIDs = New List<Id>();
        Set<String> setDelSubZuoraIds = new Set<String>();
        
        //Break Delivery Sub List into 3 Categories which addresstype not contains H,C,L
        List<Zuora__Subscription__c> lstHSubs = new List<Zuora__Subscription__c> ();
        List<Zuora__Subscription__c> lstCSubs = new List<Zuora__Subscription__c> ();
        List<Zuora__Subscription__c> lstLSubs = new List<Zuora__Subscription__c> ();
        //Break Delivery Sub List into 6 Categories which addresstype contains H,C,L
        List<Zuora__Subscription__c> lstHCdelSubs = new List<Zuora__Subscription__c> ();
        List<Zuora__Subscription__c> lstHLdelSubs = new List<Zuora__Subscription__c> ();
        List<Zuora__Subscription__c> lstCHdelSubs = new List<Zuora__Subscription__c> ();
        List<Zuora__Subscription__c> lstCLdelSubs = new List<Zuora__Subscription__c> ();
        List<Zuora__Subscription__c> lstLCdelSubs = new List<Zuora__Subscription__c> ();
        List<Zuora__Subscription__c> lstLHdelSubs = new List<Zuora__Subscription__c> ();
        
        //Fetching the New Contact Address Type from Address        
        for(Contact newContact : lstContacts){         
            conAddressIDs.add(newContact.Address__c);
            mapNewConToAddressId.put(newContact.Id,newContact.Address__c);  
            //START UD-2162 08/17/2015 Added by J.Sarion - Update map to Id to Set of String
            setDelSubZuoraIds.addAll(mapNewContactToSub.get(newContact.Id));
            
            for(String delSubZuoraID :mapNewContactToSub.get(newContact.Id)) {              
                if(delSubZuoraID != null && mapDelZuoraIdToOldAddressId.containsKey(delSubZuoraID))
                {
                    conAddressIDs.add(mapDelZuoraIdToOldAddressId.get(delSubZuoraID));
                }
            }
            //END UD-2162 08/17/2015 Added by J.Sarion - Update map to Id to Set of String
        }
        
        //START UD-2890 9/25/2015 Added By C. Lin - Auto Sync All Billing Account from list
        List<Zuora__Subscription__c> lstDelSubForBillAcc = [SELECT Id, Zuora__CustomerAccount__c FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c IN :setDelSubZuoraIds 
                                    AND Zuora__Status__c = 'Active' AND Subscription_Type_1__c = 'Delivery'];
        
        for(Zuora__Subscription__c subBA : lstDelSubForBillAcc)
        {
            setBillingAccountId.add(subBA.Zuora__CustomerAccount__c);
        }
        //END UD-2890 9/25/2015 Added By C. Lin
        
        List<Zuora__Subscription__c> lstDelSubs = [SELECT Id, Zuora__Account__c, Recipient_Contact__c, Recipient_Contact__r.Address__c, Zuora__Zuora_Id__c, Delivery_Charge_Type_1__c,
                                    Zuora__CustomerAccount__c, Zuora__SubscriptionStartDate__c, Contract_End_Date_1__c,Zuora__SubscriptionEndDate__c, Order_Line_Item_Number_1__c  
                                    FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c IN :setDelSubZuoraIds 
                                    AND Zuora__Status__c = 'Active' AND Subscription_Type_1__c = 'Delivery' 
                                    AND (Billing_Type__c= 'Recurring Prepaid' OR Billing_Type__c= 'Recurring Postpaid')];
        
        for(Zuora__Subscription__c sub : lstDelSubs)
        {
            mapZuoraIdToDelSub.put(sub.Zuora__Zuora_Id__c, sub);
        }
        
        //Preparing Map for new delivery Contact Id and delivery Contact address type
        Map<Id, Address__c> mapAddress = new Map<Id, Address__c>
                ([select Id,Name, Postal_Code__c, Address_Type__c from Address__c where Id in:conAddressIDs]);
    
        for(Contact newContact : lstContacts){         
            String newAddrType;
            String oldAddrType;
            String oldDelChargeType;
            Zuora__Subscription__c deliverSub;
            
            if(newContact.Address__c != null && mapAddress.containsKey(newContact.Address__c) 
                && mapAddress.get(newContact.Address__c).Address_Type__c != null)
                newAddrType = ConstantsSLB.getDefaultDeliveryChargeType(mapAddress.get(newContact.Address__c).Address_Type__c);
            
            //START UD-2162 08/17/2015 Added by J.Sarion - Update map to Id to List of String
            for(String delSubZuoraID: mapNewContactToSub.get(newContact.Id)) {
                if(delSubZuoraID != null && mapZuoraIdToDelSub.containsKey(delSubZuoraID))
                {
                    deliverSub = mapZuoraIdToDelSub.get(delSubZuoraID);
                    Id oldAddressId = mapDelZuoraIdToOldAddressId.get(delSubZuoraID);
                    oldDelChargeType = deliverSub.Delivery_Charge_Type_1__c;
                    
                    if(oldAddressId != null && mapAddress.containsKey(oldAddressId) && mapAddress.get(oldAddressId).Address_Type__c != null)
                        oldAddrType = ConstantsSLB.getDefaultDeliveryChargeType(mapAddress.get(oldAddressId).Address_Type__c);
                }
                
                
                if(oldAddrType == null || oldDelChargeType == null || newAddrType == null)
                    continue;
                    
                if((oldDelChargeType !='H' && oldDelChargeType != 'C' && oldDelChargeType != 'L') && (oldAddrType == newAddrType)){   
                    if(oldAddrType == 'H') lstHSubs.add(deliverSub);
                    if(oldAddrType == 'C') lstCSubs.add(deliverSub);
                    if(oldAddrType == 'L') lstLSubs.add(deliverSub); 
                    
                    if(deliverSub.Zuora__CustomerAccount__c != null)
                        setBillingAccountId.add(deliverSub.Zuora__CustomerAccount__c); 
                } 
                else if(oldAddrType != newAddrType)
                {                        
                    if(oldAddrType == 'H') 
                    {
                        if(newAddrType == 'C')
                            lstHCdelSubs.add(deliverSub);
                        if(newAddrType == 'L')
                            lstHLdelSubs.add(deliverSub);    
                    }                             
                    else if (oldAddrType == 'C') 
                    {
                        if(newAddrType == 'H')
                            lstCHdelSubs.add(deliverSub);
                        if(newAddrType == 'L')
                            lstCLdelSubs.add(deliverSub);    
                    }
                    else if(oldAddrType == 'L')
                    {
                        if(newAddrType == 'H')
                            lstLHdelSubs.add(deliverSub);
                        if(newAddrType == 'C')
                            lstLCdelSubs.add(deliverSub);    
                    }
                    
                    if(deliverSub.Zuora__CustomerAccount__c != null)
                        setBillingAccountId.add(deliverSub.Zuora__CustomerAccount__c); 
                }
            }
            //END UD-2162 08/17/2015 Added by J.Sarion - Update map to Id to List of String
        } 
        
        zqu__ProductRatePlan__c deliveryRatePlan_HDB;
        zqu__ProductRatePlan__c deliveryRatePlan_Apartment;
        zqu__ProductRatePlan__c deliveryRatePlan_Landed; 
        List <Zuora.zApi.AmendRequest> lstAmendReqs = new List <Zuora.zApi.AmendRequest>(); 
        
         /*------------------------------- Get Rate Plans for Delivery Charges----------------------------------*/
        for(zqu__ProductRatePlan__c drp: [Select Id, Name, zqu__ZuoraId__c From zqu__ProductRatePlan__c
                                        Where zqu__ZProduct__r.ProductCode__c =: GlobalVariableClass.PRODUCT_CODE_DELCHG and zqu__Deleted__c = false])
        {
            if(drp.name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('HDB DELIVERY CHARGE')))
                deliveryRatePlan_HDB = drp;
            else if(drp.name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('APT DELIVERY CHARGE')))
                deliveryRatePlan_Apartment = drp;
            else if(drp.name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('LANDED DELIVERY CHARGE')))
                deliveryRatePlan_Landed = drp;
        }
        
        
        //START UD-2303 08/14/2015 Added by J.Sarion - set isCalledFromCOABatch to true
        DeliveryChargeHelper.isCalledFromCOABatch = true;
        //END UD-2303 08/14/2015 Added by J.Sarion - set isCalledFromCOABatch to true
        
        if(!lstHSubs.isEmpty())
            lstAmendReqs.addAll(DeliveryChargeHelper.createCODCAmendmentReqs(lstHSubs,deliveryRatePlan_HDB.Id));    
        if(!lstCSubs.isEmpty())
            lstAmendReqs.addAll(DeliveryChargeHelper.createCODCAmendmentReqs(lstCSubs,deliveryRatePlan_Apartment.Id));        
         if(!lstLSubs.isEmpty())
            lstAmendReqs.addAll(DeliveryChargeHelper.createCODCAmendmentReqs(lstLSubs,deliveryRatePlan_Landed.Id));   
        
        
        if(!lstHCdelSubs.isEmpty())
            lstAmendReqs.addAll(DeliveryChargeHelper.createCODCAmendmentReqs(lstHCdelSubs,deliveryRatePlan_HDB.Name,deliveryRatePlan_Apartment.zqu__ZuoraId__c));        
        if(!lstHLdelSubs.isEmpty())
            lstAmendReqs.addAll(DeliveryChargeHelper.createCODCAmendmentReqs(lstHLdelSubs,deliveryRatePlan_HDB.Name,deliveryRatePlan_Landed.zqu__ZuoraId__c));        
        if(!lstCHdelSubs.isEmpty())
            lstAmendReqs.addAll(DeliveryChargeHelper.createCODCAmendmentReqs(lstCHdelSubs,deliveryRatePlan_Apartment.Name,deliveryRatePlan_HDB.zqu__ZuoraId__c));
        if(!lstCLdelSubs.isEmpty())
            lstAmendReqs.addAll(DeliveryChargeHelper.createCODCAmendmentReqs(lstCLdelSubs,deliveryRatePlan_Apartment.Name,deliveryRatePlan_Landed.zqu__ZuoraId__c)); 
        if(!lstLHdelSubs.isEmpty())
            lstAmendReqs.addAll(DeliveryChargeHelper.createCODCAmendmentReqs(lstLHdelSubs,deliveryRatePlan_Landed.Name,deliveryRatePlan_HDB.zqu__ZuoraId__c));              
        if(!lstLCdelSubs.isEmpty())
            lstAmendReqs.addAll(DeliveryChargeHelper.createCODCAmendmentReqs(lstLCdelSubs,deliveryRatePlan_Landed.Name,deliveryRatePlan_Apartment.zqu__ZuoraId__c));        
           
		//START D-3791 LISEN 21-Oct-2015 - Fix Log BatchCode
        Logger logger = new Logger(BatchCOADeliveryCharge.class.getName(),'SP050'); //START END D-1011 MD-28 Dags 18/06/15        
		//END D-3791 LISEN 21-Oct-2015 - Fix Log BatchCode
        if(!lstAmendReqs.isEmpty()){    
            Zuora.zApi zuorApi = new Zuora.zApi();
            //START D-3268 Modified By C.I.Salas - Test Coverage
            if (!Test.isRunningTest()) {
                zuorApi.zlogin();
            }
            //END D-3268 Modified By C.I.Salas - Test Coverage      
                  
            //Send Amendment Request one by one            
            for(Zuora.zApi.AmendRequest amendRequest :lstAmendReqs)
            {
                Zuora.zApi.AmendResult amendResult = zuorApi.zamend(new List<Zuora.zApi.AmendRequest>{amendRequest});
                //START D-3791 LISEN 21-Oct-2015 - Added filter to prevent log when Zuora sync is successful
				//START D-3854 11/2/2015 Added By C. Lin - Add brackets to place logger.log inside the if statement
                if(!amendResult.success && amendResult.errors != null){
                    System.debug(Logginglevel.ERROR, System.Label.ERR_CODC_AMEND + ' : ' + amendResult);
					logger.log(false,'' + amendResult); //START END D-1011 MD-28 Dags 18/06/15
				}
				//END D-3854 11/2/2015 Added By C. Lin
                //END D-3791 LISEN 21-Oct-2015 - Added filter to prevent log when Zuora sync is successful
            }
			Logger.save(); //START END D-1011 MD-28 Dags 18/06/15
        }
    }
    
    global void finish(Database.BatchableContext BC) {  
        //Perform Zuora Sync
        //START D-3651 10/02/2015 Added by J.Sarion - set emailNotificationEnabled to false
        Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
        syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
        syncManager.syncObjectIdSet  = setBillingAccountId;
        syncManager.emailNotificationEnabled = false;
        List<Zuora.SyncResult> syncResult = syncManager.sendRequest();
        //END D-3651 10/02/2015 Added by J.Sarion - set emailNotificationEnabled to false
        
        //START D-3243 07/16/2015 Added by J.Sarion - Update Job Status
        BatchJobHelper.updateJobStatus(JOB_ID);
        //END D-3243 07/16/2015 Added by J.Sarion - Update Job Status
    }
}