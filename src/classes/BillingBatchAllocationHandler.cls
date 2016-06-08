/*
 * Class Name: BillingBatchAllocationHandler
 * @author: Wenjun Zhu
 * Date: 11/12/2014
 * @description: This class is for allocating Batch1 to 20 to Billing Accounts
 * 
 * History: D-4463 20Mar16 JohnD - totally revised
 */
public class BillingBatchAllocationHandler {
    
    // Start D-4463 20Mar16 JohnD - new logic
	public static void allocateBatchNumber(set<id> billingAccountIdSetParam) {
		
		list<Zuora__CustomerAccount__c> billingAccountList = [select Id, Zuora__Batch__c, Billing_Type__c, 
				Zuora__Zuora_Id__c from Zuora__CustomerAccount__c where Id in :billingAccountIdSetParam];

		Logger logger = new Logger(BillingBatchAllocationHandler.class.getName());
		map<string, list<string>> billingType_batchNumberSequenceList = new map<string, list<string>>();
		map<string, string> billingAccountZuoraId_batchNumber = new map<string, string>();
		map<string, integer> billingType_nextBatchNumberIndex = new map<string, integer>();
		list<string> batchNumberSequenceList = new list<string>();

    	list<map<string, string>> responseResults = new list<map<string, string>>();
    	list<map<string, object>> zuoraObjectList = new list<map<string, object>>();
		set<string> billingAccountZuoraIdSet = new set<string>();
		set<string> billingTypeSet = new set<string>();
		billingTypeSet.add(GlobalVariableClass.BILLING_TYPE_FULL_PRE);
		billingTypeSet.add(GlobalVariableClass.BILLING_TYPE_MR_PRE);
		billingTypeSet.add(GlobalVariableClass.BILLING_TYPE_MR_POST);
		
		integer currentBatchNumberIndex;
		string batchNumber;
		integer nextBatchNumberIndex;
		string errorMsg = '';
		
    	// retrieve batch number assignment from custom settings
		list<Billing_Batch__c> billingBatchList = [select Id, Name, Batch__c, Next_Batch_Number__c from Billing_Batch__c 
				where Name in :billingTypeSet];
		
		if (billingBatchList.isEmpty()) {
			throw new CustomException('Billing Batch Number is not configured.');
		}
		
		for (Billing_Batch__c bb : billingBatchList) {
			
			if (bb.Batch__c != null) {
				
				currentBatchNumberIndex = 0;
				batchNumberSequenceList = bb.Batch__c.split(',');
				billingType_batchNumberSequenceList.put(bb.Name, batchNumberSequenceList);
				
				if (bb.Next_Batch_Number__c != null) {
				
					for (integer i = 0; i < batchNumberSequenceList.size(); i++) {
						
						if (batchNumberSequenceList[i] == string.valueOf(integer.valueOf(bb.Next_Batch_Number__c))) {
							currentBatchNumberIndex = i;
							break;
						}
					}
				}
				
				billingType_nextBatchNumberIndex.put(bb.Name, currentBatchNumberIndex);
				
			} else {
				errorMsg += 'No batch number configured for ' + bb.Name;
			}
		}
		
		for (Zuora__CustomerAccount__c ba : billingAccountList) {
			
			batchNumberSequenceList = billingType_batchNumberSequenceList.get(ba.Billing_Type__c);
			currentBatchNumberIndex = billingType_nextBatchNumberIndex.get(ba.Billing_Type__c);

			batchNumber = 'Batch' + batchNumberSequenceList[currentBatchNumberIndex];
			nextBatchNumberIndex = currentBatchNumberIndex + 1;
			
			if (nextBatchNumberIndex == batchNumberSequenceList.size()) {
				nextBatchNumberIndex = 0;
			}
			
			billingType_nextBatchNumberIndex.put(ba.Billing_Type__c, nextBatchNumberIndex);
			
            map<string, object> requestField_value = new map<string, object>();
            requestField_value.put('Id', ba.Zuora__Zuora_Id__c);
			requestField_value.put('Batch', batchNumber);
			//requestField_value.put('Batch', 'Batch19');	// reset all for testing purposes
			
			zuoraObjectList.add(requestField_value);
		}

        // start send request callout to zuora for update
        if (!zuoraObjectList.isEmpty()) {
	        ZuoraCallOut zCall = new ZuoraCallOut();
	        if (!Test.isRunningTest()) {
	            responseResults = zCall.updateZObjects(zuoraObjectList, 'Account');
	        } else {
	            responseResults.add(new map<string, string>{'Status' => 'Error'});
	        }
        }

        // start parse result
        for (map<string, string> responseField_value : responseResults) {
        	
        	if (responseField_value.get('Status') != GlobalVariableClass.ZUORA_SUCCESS) {
        		errorMsg += responseField_value.get('Message') + ' || ';
        	}
        }
        // end parse result

		// start update billing batch next batch number
		for (Billing_Batch__c bb : billingBatchList) {
			
			batchNumberSequenceList = billingType_batchNumberSequenceList.get(bb.Name);
			bb.Next_Batch_Number__c = integer.valueOf(batchNumberSequenceList[billingType_nextBatchNumberIndex.get(bb.Name)]);
		}
		
		try {
			update billingBatchList;
		} catch (exception e) {
			errorMsg += e.getMessage();
		}
		// end update billing batch next batch number
		
		if (errorMsg != '' && !Test.isRunningTest()) {
			logger.log(false, errorMsg);
			logger.save();
		}
	}
    // End D-4463 20Mar16 JohnD - new logic
    
    // Start D-4463 20Mar16 JohnD - commented out 
    /*
    //Wenjun - 11/12/2014 - For Billing Batch Number Allocation
    //Fetch the underlying subscriptions to determine the Billing Type i.e. prepaid or postpaid
    //Assumption: Subscriptions under the same Billing Account have the same Billing Type
    public static String getBillingType(String billingAccountID)
    {
        String returnVal = NULL;
        //START: JLedesma - Code Review 'NULL in WHERE clause' 2/19/2015 
        //START: D-2307 - K. Tan / Revert back the original Aggregate result query 
        AggregateResult[] groupedResults = [SELECT Billing_Type__c,COUNT(Id) FROM Zuora__Subscription__c 
         WHERE Zuora__CustomerAccount__c = : billingAccountID and Billing_Type__c != NULL/*and Billing_Type_isNull__c = 'FALSE' * /
         Group by Billing_Type__c ORDER BY COUNT(Id) DESC LIMIT 1];
        //END: D-2307 - K. Tan / Revert back the original Aggregate result query          
        //END: JLedesma - Code Review 'NULL in WHERE clause' 2/19/2015 
        if(groupedResults != NULL && groupedResults.size() >0)
            returnVal = (String) groupedResults[0].get('Billing_Type__c');
        
        return returnVal;
    }
    
    //Fetch the underlying subscriptions to determine the Billing Type i.e. prepaid or postpaid
    //Assumption: Subscriptions under the same Billing Account have the same Billing Type
    public static Map<ID,String> getBillingTypes(List<Zuora__CustomerAccount__c> lstAccounts)
    {
        //START D-1610 2/23/15 AddedBy FrancisBenzon : change Where clause of Zuora__CustomerAccount__c From List to Set of Ids
        Set<Id> billAcctIds = new Set<Id>();
        for(Zuora__CustomerAccount__c accts : lstAccounts) {
            billAcctIds.add(accts.Id);
        }
        Map<ID,String> mapResult = new Map<ID,String>();
        //START: JLedesma - Code Review 'NULL in WHERE clause' 2/19/2015 
        List<Zuora__Subscription__c> lstSub = [SELECT Billing_Type_isNull__c, Zuora__CustomerAccount__c,Billing_Type__c
                                               FROM Zuora__Subscription__c 
                                                WHERE Zuora__CustomerAccount__c in :billAcctIds and Billing_Type_isNull__c = 'FALSE']; 
        //END: JLedesma - Code Review 'NULL in WHERE clause' 2/19/2015 
        //END D-1610 2/23/15 AddedBy FrancisBenzon : change Where clause of Zuora__CustomerAccount__c From List to Set of Ids
        for(Zuora__Subscription__c sub : lstSub)
        {
            mapResult.put(sub.Zuora__CustomerAccount__c,sub.Billing_Type__c);
        }
        
        return mapResult;
    }
    
    //Create the Batch Number Allocation Key e.g. Payment Mode + " " + Billing Type
    public static String generateBatchKey(String paymentMode, String billingType)
    {
        String batchKey = '';
        
        //Separate the Payment Mode into different groups
        //Cash,Cheque,Invoice,CreditCard,eNets,PayPal,External Parties,Internal Charge
        if(paymentMode == NULL)
          throw new CustomException(System.Label.ERR_NULL_PAYMENT_MODE);
        if(paymentMode == 'CreditCard' || paymentMode == 'Credit Card')
            batchKey += 'Credit Card';
        else if (paymentMode != 'Invoice' && paymentMode != 'PayPal')
            batchKey += 'Others';
        else
            batchKey += paymentMode;
        
        //Process Billing Type
        if(billingType == NULL)
          throw new CustomException(System.Label.ERR_NULL_BILLING_TYPE);
        if(billingType.contains('Prepaid'))
            batchKey += ' Prepaid';
        else if(billingType.contains('Postpaid'))
            batchKey += ' Postpaid';
        
        return batchKey;
    }
    
    //This method is used for Change Payment Type - Processing Single Billing Account only
    public static String allocateBatchNumber(String paymentMode, String billingType)
    {
        String returnVal = NULL;
        String batchKey = BillingBatchAllocationHandler.generateBatchKey(paymentMode,billingType);
        
        //Get Custom Setting
        String strNumList = ConstantsSLB.getBillingBatch(batchKey);
        if(strNumList == NULL)
            throw new CustomException(System.Label.ERR_BILLING_BATCH + 'Batch Key is: ' + batchKey);
        
        //Process the setting the generate Eligible Batch Number List
        List<String> numberArray = strNumList.split(',');
        List<String> lstBatchNumber = new List<String>();
        if(numberArray != NULL && numberArray.size() >0)
        {
            for(String strNumber : numberArray)
            {
                if(strNumber != NULL && strNumber.trim() != '')
                    lstBatchNumber.add('Batch'+strNumber);
            }
        }
        else
            throw new CustomException(System.Label.ERR_BILLING_BATCH + 'Batch Key is: ' + batchKey);
        
        if(lstBatchNumber.isEmpty())
            throw new CustomException(System.Label.ERR_BILLING_BATCH + 'Batch Key is: ' + batchKey);
        
        System.debug('===========> Eligible Batch Numbers: '+ lstBatchNumber);
        
        //If there are multiple eligible Batch Numbers, query existing load to determine which Batch to allocate
        if(lstBatchNumber.size() > 1)
        {
            //START: D-2340 3/14/2015  VPernicia - fix for SOQL too many rows 
            Billing_Batch__c CSNextBillingBatchNumber = Billing_Batch__c.getValues(batchKey);
            Integer CurrentBatchNumber = (Integer) CSNextBillingBatchNumber.Next_Batch_Number__c;
            
            returnVal = 'Batch'+CurrentBatchNumber;
            
            /*
            AggregateResult[] groupedResults = [SELECT Zuora__Batch__c, COUNT(ID) FROM Zuora__CustomerAccount__c 
             WHERE Zuora__Batch__c in :lstBatchNumber GROUP BY Zuora__Batch__c ORDER BY COUNT(ID)];
            
            System.debug('===========> AggregateResult is: '+ groupedResults);
            
            if(groupedResults != NULL && groupedResults.size() > 0)
            {
                //Scenario 1: All Batches have been assigned so going to assign the Batch with lowest load 
                if(groupedResults.size() == lstBatchNumber.size())
                {
                    returnVal = (String) groupedResults[0].get('Zuora__Batch__c');
                }
                else //Scenario 2: still got Batch not used before
                {
                    Set<String> setUsedBatch = new Set<String>();
                    for(AggregateResult result : groupedResults)
                        setUsedBatch.add((String)result.get('Zuora__Batch__c'));
                    
                    //Assign any of the unused number
                    for(String strNumber: lstBatchNumber)
                    {
                        if(!setUsedBatch.contains(strNumber))
                        {
                            returnVal = strNumber;
                            BREAK;
                        }
                    }
                } // End of Else
            } // End of If
            else //Assign the 1st Batch Number as no number is being used now
                returnVal = lstBatchNumber[0];
            * /
            //END: D-2340 3/14/2015  VPernicia - fix for SOQL too many rows
        }
        else //There are only ONE appropriate number to assign
            returnVal = lstBatchNumber[0];
        
        System.debug('===========> Batch Number to Assign: '+ returnVal); 
        
        return returnVal;
    }
    
    public static List<Map<String,String>> setBatchNoForAccounts(List<Zuora__CustomerAccount__c> lstAccounts)
    {
        List<Map<String,Object>> lstAccountsToUpd = new List<Map<String,Object>>();
        Map<ID,String> mapBatchKey = new Map<ID,String>();
        Set<String> setKeys = new Set<String>();
        //Zuora Callout Result Map
        List<Map<String,String>> lstResultMap = new List<Map<String,String>>();
        
        //Get Billing Types
        Map<ID,String> mapBillingTypes = BillingBatchAllocationHandler.getBillingTypes(lstAccounts);

        //Update the Billing Batch Key for each Billing Account
        for(Zuora__CustomerAccount__c account: lstAccounts)
        {
           //START D-1610 2/23/15 AddedBy FrancisBenzon : checking to avoid null. Cater Bad data to be able to proceed in process. 
           if(mapBillingTypes.get(account.ID) != null) {
                String paymentMode = BillingBatchAllocationHandler.getPaymentMode(account);
                String batchKey = BillingBatchAllocationHandler.generateBatchKey(paymentMode,mapBillingTypes.get(account.ID));
                mapBatchKey.put(account.ID,batchKey);
                setKeys.add(batchKey);
           }
           //END D-1610 2/23/15 AddedBy FrancisBenzon : checking to avoid null. Cater Bad data to be able to proceed in process. 
        }
        
        //Get assigned Batch Number for each Batch Key
        Map<String,String> mapKeyToBatchNumber = BillingBatchAllocationHandler.allocateBatchNumber(setKeys);
        
        //Construct the List Messge for Zuora Callout
        for(Zuora__CustomerAccount__c account: lstAccounts)
        {
            Map<String,Object> pMethod = new Map<String,Object>();
            pMethod.put('Id', account.Zuora__Zuora_Id__c); //Zuora ID
            pMethod.put('Batch', mapKeyToBatchNumber.get(mapBatchKey.get(account.ID)));
                    
            lstAccountsToUpd.add(pMethod);
        }
        
        //Fire Zuora Callout to update Batch Number
        ZuoraCallOut zCall = new ZuoraCallOut();
        if (!Test.isRunningTest()) {
            lstResultMap = zCall.updateZObjects(lstAccountsToUpd,'Account');
        }
        else {
            lstResultMap.add(new Map<String, String>{'Status' => 'Error'});
        }
        
        System.debug('=========> Update Billing Batch Result: ' + lstResultMap);
        
        return lstResultMap;
    }
    
    //Check the Default Payment Method and Other Payment Method to get the Payment Mode
    public static String getPaymentMode(Zuora__CustomerAccount__c account)
    {
        String paymentMode = account.Zuora__DefaultPaymentMethod__c;
        if(paymentMode == 'Other')
           paymentMode = account.Other_PaymentMethod__c;
        
        return paymentMode;
    }
    
    //Used by Billing Batch Number Allocation Batch Job
    //Note: The following logic assigns the same batch number (with lowest load) for the records with same Type.
    //This can achieve "load balancing" at a period of time (e.g. after few batch runs)
    //To achive exact loading balancing for each run, the code will be more complex
    public static Map<String,String> allocateBatchNumber(Set<String> setBatchKeys)
    { 
        Map<String,String> mapKeyToBatchNumber = new Map<String,String> ();
        //This map stores the mapping from Batch Number to Batch Key: e.g. Batch1 - Credit Card Prepaid
        Map<String,String> mapBatchToKey = new Map<String,String>();
        //This Map stores the current Load of Each Batch Number: e.g. Batch1 - 10; Batch2:20 etc
        Map<String, Integer> mapBatchLoad = new Map<String, Integer>();
        
        //Query Custom Settings
        List<Billing_Batch__c> batchSettings = [SELECT Name,Batch__c FROM Billing_Batch__c WHERE Name in :setBatchKeys];
   
        for(Billing_Batch__c setting : batchSettings)
        {
            String strNumList = setting.Batch__c;
            //Process the setting the generate Eligible Batch Number List
            List<String> numberArray = strNumList.split(',');
            if(numberArray != NULL && numberArray.size() >0)
            {
                for(String strNumber : numberArray)
                {
                    if(strNumber != NULL && strNumber.trim() != '')
                    {
                        mapBatchToKey.put('Batch'+strNumber, setting.Name);
                        //Initialise the load to 0
                        mapBatchLoad.put('Batch'+strNumber, 0);
                    }
                }
            }
            else
                throw new CustomException(System.Label.ERR_BILLING_BATCH + 'Batch Key is: ' + setting.Name); 
        } //End of For Loop
        
        if(mapBatchToKey.isEmpty())
            throw new CustomException(System.Label.ERR_BILLING_BATCH);
        
        System.debug('===========> Batch Number to Key Mapping: '+ mapBatchToKey);
        
        //Query the  Database for current load
        AggregateResult[] groupedResults = [SELECT Zuora__Batch__c, COUNT(ID) FROM Zuora__CustomerAccount__c 
             WHERE Zuora__Batch__c in :mapBatchToKey.keySet() GROUP BY Zuora__Batch__c];
        
        if(groupedResults != NULL && !groupedResults.isEmpty())
        {
            for(AggregateResult result : groupedResults)
            {
                String batchNumber = (String) result.get('Zuora__Batch__c');
                Integer intLoad = (Integer) result.get('expr0');
                mapBatchLoad.put(batchNumber, intLoad);
            }
        }
        
        //Generate the final mapping list by locating the lowest load
        for(String batchNumber : mapBatchToKey.keySet())
        {
            String batchKey = mapBatchToKey.get(batchNumber);
            if(!mapKeyToBatchNumber.containsKey(batchKey))
                mapKeyToBatchNumber.put(batchKey,batchNumber);
            else if(mapBatchLoad.containsKey(batchNumber) 
                    && mapBatchLoad.get(batchNumber) < mapBatchLoad.get(mapKeyToBatchNumber.get(batchKey)))
                //This Batch Number has lower load
                mapKeyToBatchNumber.put(batchKey,batchNumber);        
        }
        
        System.debug('===========> Batch Number to Assign: '+ mapKeyToBatchNumber); 
        
        return mapKeyToBatchNumber;
    }
    */
    // End D-4463 20Mar16 JohnD - commented out
}