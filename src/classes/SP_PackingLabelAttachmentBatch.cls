/*
 * Class Name: SP_PackingLabelAttachmentBatch
 * @author: Alyana P. Navarro
 * Date: 10/11/2014
 * 
 * History: 10/11/2014 Alyana P. Navarro Created Apex Batch
 * History: 10/11/2014 Kevin H. Evasco Updated class
 * History: 12/05/2014 D-0797, D-0849 Kevin Evasco Added new constructor to enable storage of Session ID.
 * History: 10/16/2015 Added by Kristine Balaoing - modified logic to handle error
 */

global class SP_PackingLabelAttachmentBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {    
    
    String letterType;
    Integer batchCount;
    String sessionId;
    //START 04-Nov-2015 D-3672 Added by Kristine Balaoing - Recovery plan
    DateTime referenceDate;
    Date refIssueDate;
    boolean isRecovery = false;
    //START: D-3976 11/24/2015 Added by Kristine Balaoing - added for batch recovery
    Set<Id> failedRecs = new Set<Id>();
    //END 04-Nov-2015 D-3672 Added by Kristine Balaoing - Recovery plan

    //START: D-3664 10/16/2015 Added by Kristine Balaoing - modified logic to handle error
    Boolean isApexJobSuccessful = true; 
    //END: 10/16/2015 Added by Kristine Balaoing - modified logic to handle error
    
    public Set<Id> airlineMailingAgentSet = new Set<Id>(); // START-END : UD-2962 10/29/2015 Alyana Navarro
    public Set<String> overseasMailingAgentIdSet = new Set<String>(); // START-END : D-3896 11/6/2015 Alyana Navarro
    // START: D-3664  12/05/2014 D-0797, D-0849 Kevin Evasco Added new constructor to enable storage of Session ID.
    global SP_PackingLabelAttachmentBatch(String letterType, Integer batchCount, String sessionId)
    {
        this.letterType = letterType;
        this.batchCount = batchCount;
        this.sessionId = sessionId;
    }
    // END: 12/05/2014 D-0797, D-0849 Kevin Evasco Added new constructor to enable storage of Session ID.
    
    //START 04-Nov-2015 D-3672 Added by Kristine Balaoing - Recovery plan
    global SP_PackingLabelAttachmentBatch(String refDate, String letterType, Integer batchCount, String sessionId, Set<Id> pckLabelIds)
    {
        this.letterType = letterType;
        this.batchCount = batchCount;
        this.sessionId = sessionId;
        referenceDate = DateTime.valueOf(refDate);    //ginawa ko tong time tama ba? No pala. Dapat time na siya pag ininput
        isRecovery = true;
        this.failedRecs = pckLabelIds;
        
    }
    
    //END 04-Nov-2015 D-3672 Added by Kristine Balaoing - Recovery plan
    //END: D-3976 11/24/2015 Added by Kristine Balaoing

    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext bc)
    {       
        // START : D-2013 3/20/2015 Alyana Navarro
    
        //START UD-1551 24-Aug-2015 Added By S.Puli - Change logic of packing label record creation
        //START UD-2904 27-Oct-2015 Added by S.Puli - Update logic to reference Issue date field
        //START 04-Nov-2015 D-3672 Added by Kristine Balaoing - Recovery plan
        //Remove Date referenceDate;
        if(!isRecovery){
            refIssueDate = Date.today();            
    //START: D-3664 11/18/2015 Added by Kristine Balaoing - added for batch recovery
        }else{
            refIssueDate = Date.newInstance(referenceDate.year(), referenceDate.month(), referenceDate.day());
            try{
                Letter_Print_Batch__c letterPrintBatch = [SELECT id, name, Initialization_Status__c 
                                                          FROM Letter_Print_Batch__c 
                                                          WHERE Initialization_Status__c = 'Active' 
                                                            AND Letter_Type__c =: SP_GenerateLetterPrintBatch.packingLabelLetter];
                if(letterPrintBatch != null){
                    letterPrintBatch.Initialization_Status__c = 'Incomplete';
                    update letterPrintBatch;
                }
            } catch(Exception e){
                system.debug('No existing active Letter Print Batch');
            }
        }
    //END: D-3664 11/18/2015 Added by Kristine Balaoing
        //END 04-Nov-2015 D-3672 Added by Kristine Balaoing - Recovery plan
        // Start D-3908 VPernicia 11/17/15: Additional criteria to check if Mailing agent is not null to avoid Map key null not found in map
        //START: D-3976 11/24/2015 Added by Kristine Balaoing - added for batch recovery
        if(isRecovery == true && letterType=='Packing_Label_Letter'){
            return Database.getQueryLocator([SELECT id, name, Subscription__c, Mailing_Agent_Account_Number__c,CreatedDate, Issue_Date__c FROM Packing_Label_Batch__c Where Issue_Date__c = :refIssueDate and Mailing_Agent_Account_Number__c <> null AND Id IN:failedRecs]);
        }else{
            return Database.getQueryLocator([SELECT id, name, Subscription__c, Mailing_Agent_Account_Number__c,CreatedDate, Issue_Date__c FROM Packing_Label_Batch__c Where Issue_Date__c = :refIssueDate and Mailing_Agent_Account_Number__c <> null]);
        }
        //END: D-3976 11/24/2015 Added by Kristine Balaoing
        // End D-3908 VPernicia 11/17/15: Additional criteria to check if Mailing agent is not null to avoid Map key null not found in map
        //END UD-2904 27-Oct-2015 
    //END UD-1551 24-Aug-2015 Added By S.Puli - Change logic of packing label record creation
    // END : D-2013 3/20/2015 Alyana Navarro
    }
    
    /* @description
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
        // START : D-2013 3/20/2015 Alyana Navarro
    global void execute(Database.BatchableContext BC, List<Packing_Label_Batch__c> scope)
    // END : D-2013 3/20/2015 Alyana Navarro
    {     
        //START: D-3664 10/16/2015 Added by Kristine Balaoing - modified logic to handle error
        Logger logger = new Logger(SP_PackingLabelAttachmentBatch.class.getName(), 'SP021', BC.getJobID());         
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            // START : 1/5/2015 D-1179 Alyana Navarro - Instantiate variable
            List<Letter_Print_Request__c> letterPrintRequests = new List<Letter_Print_Request__c>();
            // END : 1/5/2015 D-1179
            
            Set<Id> allPackagesIdSet = new Set<Id>();
            Set<Id> productRatePlanIdSet = new Set<Id>();
            Set<Id> productIdSet = new Set<Id>();
            Set<Id> subscriptionIdSet = new Set<Id>();
            
            List<Package_Item__c> packageItemList = new List<Package_Item__c>();
            List<zqu__ProductRatePlan__c> productRatePlanList = new List<zqu__ProductRatePlan__c>();
            List<Product_Publication__c> productPublicationList = new List<Product_Publication__c>();
            List<zqu__ZProduct__c> productList = new List<zqu__ZProduct__c>();
            List<Packing_Label_Batch__c> packingLabelList = new List<Packing_Label_Batch__c>();
            
            Map<Id,List<Package_Item__c>> package_packageItemMap = new Map<Id,List<Package_Item__c>>();
            Map<Id,zqu__ZProduct__c> productMap = new Map<Id,zqu__ZProduct__c>();
            Map<Id,List<Product_Publication__c>> product_productPublicationMap = new Map<Id,List<Product_Publication__c>>();
            Map<Id,List<Product_Publication__c>> package_productPublicationMap = new Map<Id,List<Product_Publication__c>>();
            Map<Id,Account> subscriptionId_account_map = new Map<Id,Account>();
            // START : D-2013 3/20/2015 Alyana Navarro
            Map<Id, Packing_Label_Batch__c> subscriptionID_packingLabelID_map = new Map<Id, Packing_Label_Batch__c>();        
            
            for(Packing_Label_Batch__c batchObject : scope)
            {
                subscriptionIdSet.add(batchObject.Subscription__c);
                subscriptionID_packingLabelID_map.put(batchObject.Subscription__c, batchObject);
            }
        //START: D-3672 11/13/2015 Added by Kristine Balaoing - put comment to include changes in comment in below code
            //START UD-2904 27-Oct-2015 Added by S.Puli - Update logic to get product type from order line item and avoid errors
            // START : UD-2962 10/29/2015 Alyana Navarro
            List <Zuora__Subscription__c> subList = [SELECT id, name, Delivered_By_1__c, Zuora__Account__r.Id, Zuora__Account__r.AccountNumber, 
                                           Zuora__Account__r.RecordType.Name, Recipient_Contact__r.Address__r.RecordType.Name, 
                                           Account_Record_Type__c, Zuora__Account__r.Airline_Indicator__c, Vendor_1__c,
                                           Order_Line_Item_Number_1__r.Main_Package_ID__r.Id, Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c 
                                           FROM Zuora__Subscription__c 
                                           WHERE id IN: subscriptionIdSet];
            // END : UD-2962 10/29/2015 Alyana Navarro
            //END UD-2904 27-Oct-2015 Added by S.Puli - Update logic to get product type from order line item and avoid errors
            //END: D-3672 11/13/2015 Added by Kristine Balaoing
        /*for(Zuora__Subscription__c batchObject : scope)
            {
                subscriptionIdSet.add(batchObject.Id);
            }*/
            
            System.debug('scope: ' + scope);
            for(Zuora__Subscription__c batchObject : subList)
        // END : D-2013 3/20/2015 Alyana Navarro
            {
                allPackagesIdSet.add(batchObject.Order_Line_Item_Number_1__r.Main_Package_ID__r.Id);
            }
            //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check    
            if (allPackagesIdSet.size() > 0) {
                packageItemList = [SELECT Id, Package__r.Id, Product_Rate_Plan__r.Id, Product_Rate_Plan__r.zqu__ZProduct__r.Id FROM Package_Item__c WHERE Package__c IN :allPackagesIdSet];
                
                for(Package_Item__c packageItem : packageItemList)
                {
                    List<Package_Item__c> packageItemTempList = package_packageItemMap.get(packageItem.Package__r.Id);
                    if(packageItemTempList == null)
                    {
                        packageItemTempList = new List<Package_Item__c>();
                    }
                    packageItemTempList.add(packageItem);
                    
                    package_packageItemMap.put(packageItem.Package__r.Id, packageItemTempList);            
                    productRatePlanIdSet.add(packageItem.Product_Rate_Plan__r.Id);
                }
            } //END: Code Review Implementation 2/17/2015 KLorica - Added NULL check        
            
            //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check    
            if (productRatePlanIdSet.size() > 0) {
                productRatePlanList = [SELECT Id, zqu__ZProduct__r.Id FROM zqu__ProductRatePlan__c WHERE Id IN :productRatePlanIdSet];
            
                 for(zqu__ProductRatePlan__c productRatePlan : productRatePlanList)
                {
                    productIdSet.add(productRatePlan.zqu__ZProduct__r.Id);
                }
            } //END: Code Review Implementation 2/17/2015 KLorica - Added NULL check                
            
            //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check    
            if (productIdSet.size() > 0) {
                productList = [SELECT Id FROM zqu__ZProduct__c WHERE Id IN :productIdSet];
                    
                for(zqu__ZProduct__c productRecord : productList)
                {        
                    productMap.put(productRecord.Id,productRecord);     
                }
            } //END: Code Review Implementation 2/17/2015 KLorica - Added NULL check  
            
            //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check    
            if (productIdSet.size() > 0) {
                productPublicationList = [SELECT Id, ZProduct__r.Id, Publication_Code__r.Publication_Type__c FROM Product_Publication__c WHERE ZProduct__c IN :productIdSet];
                
                System.debug('productPublicationList value: ' + productPublicationList);    
                for(Product_Publication__c productPublicationRecord : productPublicationList)
                {   
                    List<Product_Publication__c> productPublicationTempList = product_productPublicationMap.get(productPublicationRecord.ZProduct__r.Id);
                    if(productPublicationTempList == null)
                    {
                        productPublicationTempList = new List<Product_Publication__c>();
                    }
                    productPublicationTempList.add(productPublicationRecord);
                    product_productPublicationMap.put(productPublicationRecord.ZProduct__r.Id,productPublicationTempList);
                }
            } //END: Code Review Implementation 2/17/2015 KLorica - Added NULL check  
        
            System.debug('package_packageItemMap value: ' + package_packageItemMap);    
            for(Id keyId : package_packageItemMap.keySet())
            {            
                List<Package_Item__c> packageTempList = package_packageItemMap.get(keyId);
                
                for(Package_Item__c packageItemRecord : packageTempList)
                {              
                    List<Product_Publication__c> productPublicationTempList = product_productPublicationMap.get(packageItemRecord.Product_Rate_Plan__r.zqu__ZProduct__r.Id);  
                                 
                    package_productPublicationMap.put(keyId,productPublicationTempList); 
                }          
            }           
            for(Zuora__Subscription__c batchObject : subList) // START-END : D-2013 3/20/2015 Alyana Navarro
            {           
                System.debug('Record ID: ' + batchObject.Id);
                System.debug('Delivered By: ' + batchObject.Delivered_By_1__c);
                System.debug('Recipient Contact Address Record Type Name: '+ batchObject.Recipient_Contact__r.Address__r.RecordType.Name);
                package_productPublicationMap.get(batchObject.Order_Line_Item_Number_1__r.Main_Package_ID__r.Id);
                System.debug('Account Record Type Name ' + batchObject.Zuora__Account__r.RecordType.Name);
                System.debug('Airline Indicator: ' + batchObject.Zuora__Account__r.Airline_Indicator__c);
                // START : 1/5/2015 D-1179 Alyana Navarro - Added If condition.
                if(subscriptionID_packingLabelID_map.containsKey(batchObject.Id)){
                // END : 1/5/2015 D-1179
                    //START UD-2904 27-Oct-2015 Added by S.Puli - Update logic to get product type from order line item and avoid errors
                    if(batchObject.Delivered_By_1__c == 'Mailing Agent' && batchObject.Recipient_Contact__r.Address__r.RecordType.Name == 'Overseas')
                    {               
                        //REMOVE if(package_productPublicationMap.get(batchObject.Order_Line_Item_Number_1__r.Main_Package_ID__r.Id) != null)
                        //REMOVE{                   if(package_productPublicationMap.get(batchObject.Order_Line_Item_Number_1__r.Main_Package_ID__r.Id)[0].Publication_Code__r.Publication_Type__c == 'N')
                            if(batchObject.Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c == GlobalVariableClass.ZPRODUCTSUBTYPE_NEWSPAPER){
                                Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
                                letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.packingLabelLetter;
                                letterPrintRequest.Letter_Sub_Type__c = SP_GenerateLetterPrintBatch.overseasNewspaperReportHardCopy;
                                letterPrintRequest.Record_ID__c = subscriptionID_packingLabelID_map.get(batchObject.Id).Mailing_Agent_Account_Number__c; // START-END : D-2013 3/20/2015 Alyana Navarro
                                letterPrintRequest.Status__c = SP_GenerateLetterPrintBatch.newValue;
                                // START : D-3896 11/6/2015 Alyana Navarro
                
                
                //START 04-Nov-2015 D-3672 Added by Kristine Balaoing - Recovery plan
                                //START: D- 3664 11/17/2015 Added by Kristine Balaoing - hotfix added else for normal run
                                if(isRecovery){
                                    letterPrintRequest.Generation_From__c = referenceDate;
                                }else{
                                    letterPrintRequest.Generation_From__c = System.now();
                                }
                                //END: D- 3664 11/17/2015 Added by Kristine Balaoing
                                //END 04-Nov-2015 D-3672 Added by Kristine Balaoing - Recovery plan
                                // START : D-3016 5/29/2015 SPuli - Hotfix
                //START 04-Nov-2015 D-3672 Added by Kristine Balaoing - Recovery plan
        //START: D-3664 11/18/2015 Added by Kristine Balaoing - added comment to include change missing in SIT
                                if(letterPrintRequest.Record_ID__c != null && !overseasMailingAgentIdSet.contains(letterPrintRequest.Record_ID__c)){
                                    letterPrintRequests.add(letterPrintRequest);
                                    overseasMailingAgentIdSet.add(letterPrintRequest.Record_ID__c);
                                }
                                // END : D-3016 5/29/2015 SPuli - Hotfix
                                // END : D-3896 11/6/2015 Alyana Navarro
                //END: D-3664 11/18/2015 Added by Kristine Balaoing
                        
                                letterPrintRequest = new Letter_Print_Request__c();
                                letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.packingLabelLetter;
                                letterPrintRequest.Letter_Sub_Type__c = SP_GenerateLetterPrintBatch.overseasNewspaperWrapper;
                                letterPrintRequest.Record_ID__c = subscriptionID_packingLabelID_map.get(batchObject.Id).id; // START-END : D-2013 3/20/2015 Alyana Navarro
                                letterPrintRequest.Status__c = SP_GenerateLetterPrintBatch.newValue;
                                //START: D- 3664 11/17/2015 Added by Kristine Balaoing - hotfix added else for normal run
                                if(isRecovery){
                                    letterPrintRequest.Generation_From__c = referenceDate;
                                }else{
                                    letterPrintRequest.Generation_From__c = System.now();
                                }
                                //END: D- 3664 11/17/2015 Added by Kristine Balaoing
                                //END 04-Nov-2015 D-3672 Added by Kristine Balaoing - Recovery plan
                                // START : D-3016 5/29/2015 SPuli - Hotfix
                                if(letterPrintRequest.Record_ID__c != null){
                                    letterPrintRequests.add(letterPrintRequest);
                                }
                                // END : D-3016 5/29/2015 SPuli - Hotfix
                            }
                        //REMOVE}
                    }
                    
                    if(batchObject.Delivered_By_1__c == 'Mailing Agent' && batchObject.Zuora__Account__r.RecordType.Name == 'Direct SPH Inter-Division')
                    {               
                        //REMOVE if(package_productPublicationMap.get(batchObject.Order_Line_Item_Number_1__r.Main_Package_ID__r.Id) != null)
                        //REMOVE{
                            //REMOVE if(package_productPublicationMap.get(batchObject.Order_Line_Item_Number_1__r.Main_Package_ID__r.Id)[0].Publication_Code__r.Publication_Type__c == 'M')
                            if(batchObject.Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c == GlobalVariableClass.ZPRODUCTSUBTYPE_MAGAZINE){
                                Letter_Print_Request__c letterPrintRequest = new Letter_Print_Request__c();
                                letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.packingLabelLetter;
                                letterPrintRequest.Letter_Sub_Type__c = SP_GenerateLetterPrintBatch.magazineInternalWrapper;
                                letterPrintRequest.Record_ID__c = subscriptionID_packingLabelID_map.get(batchObject.Id).id; // START-END : D-2013 3/20/2015 Alyana Navarro
                                letterPrintRequest.Status__c = SP_GenerateLetterPrintBatch.newValue;
                                //START 04-Nov-2015 D-3672 Added by Kristine Balaoing - Recovery plan
                                //START: D- 3664 11/17/2015 Added by Kristine Balaoing - hotfix added else for normal run
                                if(isRecovery){
                                    letterPrintRequest.Generation_From__c = referenceDate;
                                }else{
                                    letterPrintRequest.Generation_From__c = System.now();
                                }
                                //END: D- 3664 11/17/2015 Added by Kristine Balaoing
                                //END 04-Nov-2015 D-3672 Added by Kristine Balaoing - Recovery plan
                                // START : D-3016 5/29/2015 SPuli - Hotfix
                                if(letterPrintRequest.Record_ID__c != null){
                                    letterPrintRequests.add(letterPrintRequest);
                                }
                                // END : D-3016 5/29/2015 SPuli - Hotfix
                            }
                        //REMOVE }
                    }
                    
                    if(batchObject.Zuora__Account__r.RecordType.Name == 'Direct Corporate' && batchObject.Zuora__Account__r.Airline_Indicator__c && batchObject.Recipient_Contact__r.Address__r.RecordType.Name == 'Airline')
                    {   
                        Letter_Print_Request__c letterPrintRequest;
                        if(batchObject.Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c == GlobalVariableClass.ZPRODUCTSUBTYPE_NEWSPAPER){
                        //REMOVE if(package_productPublicationMap.get(batchObject.Order_Line_Item_Number_1__r.Main_Package_ID__r.Id) != null)
                        //REMOVE{
                            //REMOVE if(package_productPublicationMap.get(batchObject.Order_Line_Item_Number_1__r.Main_Package_ID__r.Id)[0].Publication_Code__r.Publication_Type__c == 'N') // START-END : D-2591 3/25/2015 Alyana Navarro - Change publication type from M to N
                            //REMOVE {                       
                                letterPrintRequest = new Letter_Print_Request__c();
                                letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.packingLabelLetter;
                                letterPrintRequest.Letter_Sub_Type__c = SP_GenerateLetterPrintBatch.airlineSubscriptionWrapper;
                                letterPrintRequest.Record_ID__c = subscriptionID_packingLabelID_map.get(batchObject.Id).id; // START-END : D-2013 3/20/2015 Alyana Navarro
                                letterPrintRequest.Status__c = SP_GenerateLetterPrintBatch.newValue;
                                //START 04-Nov-2015 D-3672 Added by Kristine Balaoing - Recovery plan
                                //START: D- 3664 11/17/2015 Added by Kristine Balaoing - hotfix added else for normal run
                                if(isRecovery){
                                    letterPrintRequest.Generation_From__c = referenceDate;
                                }else{
                                    letterPrintRequest.Generation_From__c = System.now();
                                }
                                //END: D- 3664 11/17/2015 Added by Kristine Balaoing
                                //END 04-Nov-2015 D-3672 Added by Kristine Balaoing - Recovery plan
                                // START : D-3016 5/29/2015 SPuli - Hotfix
                                if(letterPrintRequest.Record_ID__c != null){
                                    letterPrintRequests.add(letterPrintRequest);
                                }
                                // END : D-3016 5/29/2015 SPuli - Hotfix
                            //REMOVE }
                        //REMOVE }
                        
                            letterPrintRequest = new Letter_Print_Request__c();
                            letterPrintRequest.Letter_Type__c = SP_GenerateLetterPrintBatch.packingLabelLetter;
                            letterPrintRequest.Letter_Sub_Type__c = SP_GenerateLetterPrintBatch.airlineSubscriptionReportHardCopy;
                            // START : UD-2962 10/29/2015 Alyana Navarro
                            letterPrintRequest.Record_ID__c = batchObject.Vendor_1__c; //subscriptionID_packingLabelID_map.get(batchObject.Id).id; // START-END : D-2013 3/20/2015 Alyana Navarro                           
                            letterPrintRequest.Status__c = SP_GenerateLetterPrintBatch.newValue;
                            //START 04-Nov-2015 D-3672 Added by Kristine Balaoing - Recovery plan
                            //START: D- 3664 11/17/2015 Added by Kristine Balaoing - hotfix added else for normal run
                            if(isRecovery){
                                letterPrintRequest.Generation_From__c = referenceDate;
                            }else{
                                letterPrintRequest.Generation_From__c = System.now();
                            }
                                //END: D- 3664 11/17/2015 Added by Kristine Balaoing
                            //END 04-Nov-2015 D-3672 Added by Kristine Balaoing - Recovery plan
                            // START : D-3016 5/29/2015 SPuli - Hotfix
                            if(letterPrintRequest.Record_ID__c != null && !airlineMailingAgentSet.contains(letterPrintRequest.Record_ID__c)){
                                letterPrintRequests.add(letterPrintRequest);
                                airlineMailingAgentSet.add(letterPrintRequest.Record_ID__c);
                            }                           
                            // END : UD-2962 10/29/2015 Alyana Navarro
                        // END : D-3016 5/29/2015 SPuli - Hotfix
                        }
                    }
                    //END UD-2904 27-Oct-2015 Added by S.Puli - Update logic to get product type from order line item and avoid errors
                }
            }

            if(letterPrintRequests.size() > 0)
            {
                insert letterPrintRequests;         
            }
        }catch(Exception e){
            Database.rollback(sp);
            logger.logBatchFailure(e, scope);
            logger.save();
            
            isApexJobSuccessful = false;
        }
        //END: D-3664 10/16/2015 Added by Kristine Balaoing - modified logic to handle error
    }
    
    /*
     * @description A method which executes the final actions of the class.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
    global void finish(Database.BatchableContext BC){
        
        //START: D-3664 10/16/2015 Added by Kristine Balaoing - modified logic to handle error
        //START: D- 4267 1-13-2016 Added by Kristine Balaoing - added logging mechanism
        Logger loggerFinish; 
            
        if(!Test.isRunningTest()){
        loggerFinish = new Logger('SP_PackingLabelAttachmentBatch', 'SP021');
        }
        
        try{
            if(!isApexJobSuccessful){
                BatchJobHelper.updateJobStatus(BC.getJobId(), false); //START-END KRITHIKA DHARMARAJAN 4/17/2015 D-2770
            }else{
                BatchJobHelper.updateJobStatus(BC.getJobId(), true);
            }
            // START: 12/05/2014 D-0797, D-0849 Kevin Evasco Added the Session ID Parameter
            //START 04-Nov-2015 D-3672 Added by Kristine Balaoing - Recovery plan
            if(!isRecovery){
                //Start D-4742 Raviteja 26Apr2016 - Capturing batch job schdduler record id            
                SP_BatchJobSchedulerService.setParentBatchJobSchedulerId(BC.getJobId());  
                //End D-4742 Raviteja 26Apr2016 - Capturing batch job schdduler record id
                SP_BatchJobSchedulerService.processRequest('SP029','Start', null, sessionId); 
            }else{
                SP_GenerateLetterPrintBatch generateBatch = new SP_GenerateLetterPrintBatch(null, SP_GenerateLetterPrintBatch.packingLabelLetter, 1, sessionId); 
                Database.executeBatch(generateBatch);
            }
        }catch(Exception e){
            loggerFinish.log(e);
            loggerFinish.save();
        }
        //END: D-4267 1-13-2016  Added by Kristine Balaoing
    //END 04-Nov-2015 D-3672 Added by Kristine Balaoing - Recovery plan
        // END: 12/05/2014 D-0797, D-0849 Kevin Evasco Added the Session ID Parameter     
        
            
                
    }   
        //END: D-3664 10/16/2015 Added by Kristine Balaoing
    
}