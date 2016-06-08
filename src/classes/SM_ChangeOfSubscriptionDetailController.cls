public class SM_ChangeOfSubscriptionDetailController extends SM_SubscriptionHelper {
     
    final id orderId = ApexPages.currentPage().getParameters().get('id');
    final id accountId = ApexPages.currentPage().getParameters().get('accountId');
    //START D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
    final String FULL_PRE = GlobalVariableClass.BILLING_TYPE_FULL_PRE;
    final String MR_PRE = GlobalVariableClass.BILLING_TYPE_MR_PRE;
    final String MR_POS = GlobalVariableClass.BILLING_TYPE_MR_POST;
    //END D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
    
    public list<Order_Line_Item__c> orderLineItemList { get; set; }
    public string selectedOrderLineItem { get; set; }
    public Order__c thisOrder { get; set; }
    public Order_Line_Item__c orderLineItem { get; set; }
    public Order_Line_Item__c oli { get; set; }
    public list<Order_Line_Item_Gift__c> promotionGifts { get; set; }
    public list<Asia1Wrapper> asia1Subscriptions { get; set; }
    public date dtlDate { get; set; }
    public transient boolean isFromPromotion { get; set; }
    public transient boolean isDigital { get; set; }
    public Zuora__Subscription__c sub { get; set;}
    public SubscriptionWrapper selectedSubscription { get; set; }
    public list<SubscriptionWrapper> relatedSubscriptionList { get; set; }
    public string selectedPackageId { get; set; }
    public Zuora__Subscription__c zs;
    //added 10242014
    public Map<Id, Date> mapId_StartDate = new Map<Id, Date>();
    //START UD-2193 07/31/2015 Added by J.Sarion - List of Asia1
    List<Asia1__c> asia1List = new List<Asia1__c>();
    //END UD-2193 07/31/2015 Added by J.Sarion - List of Asia1
    
    public void retrieveOrder() {

        list<SObject> orderList = new list<SObject>();
        
        string queryStr = generateOrderSoqlStr();
        queryStr += ' where (Order_Type__c = \'Change of Subscription Package\' and Account__c = \'' + accountId + '\' and Status__c =\'Draft\')';
        queryStr += ' or Id = \'' + orderId + '\' limit 1';
        
       try {
            
            orderList = database.query(queryStr);
            thisOrder = (Order__c)orderList[0];
            //START UD-1831 7/14/15 AddedBy FrancisBenzon : to populate DTL Date
            dtlDate = SM_SubscriptionHelper.getDtlDate();
            //END UD-1831 7/14/15 AddedBy FrancisBenzon : to populate DTL Date
            retrieveOrderLineItems();
            if (orderLineItemList.size() > 0) {
                oli = orderLineItemList[0];
                retrieveOrderLineItem();
            }
            retrieveRelatedSubscriptions();
            sub = subscriptionDetails(thisOrder.Subscription__c);
    
        } catch (exception e) {
            ApexPages.addMessages(e);           
       }
    }

    
    public class SubscriptionWrapper {
        public string publicationName { get; set; }
        public string publicationPrintPattern { get; set; }
        public date subscriptionStartDate { get; set; }
        public date subscriptionEndDate { get; set; }
        public integer quantity { get; set; }
        public id mainPackage { get; set; }
        public id SubscriptionId {get; set;}
        //START UD-0622 RReyes 05/06/15 - Added variable for main package name
        public string packageName { get; set; }
        //END UD-0622 RReyes 05/06/15 - Added variable for main package name
    }
    
    /*
     * Description: This method will retrieve all the order line items related to the Order.
     *      The list will be displayed on the Line Items section of the VF page
    */
    private void retrieveOrderLineItems() {
        orderLineItemList = getOrderLineItems(thisOrder.Id);
    } 


    /*
     * Description: This method will retrieve the information of the selected Order Line Item and 
     *      populate the data on the Subscription Details Section of the VF page.
     *      This will allow the user to update the Order Line Item. Invoke when user click on the
     *      specific Order Line Item from the Line Item section of the VF page
    */
    public void retrieveOrderLineItem() {
        
        orderLineItem = getOrderLineItem(oli.Id);
                
        // populate getter-setter variables
        promotionGifts = orderLineItem.Order_Line_Item_Gifts__r;
        
        if (promotionGifts.size() > 0) {
            isFromPromotion = true;
        }
         
        if (orderLineItem.Is_Digital__c == true) {
            
            isDigital = true;
            asia1Subscriptions = getAsia1s(orderLineItem.Asia1_Subscriptions__r);
        }
    }
    
    /*
     * Description: This method will retrieve all details related to the Subscription.
     *      The list will be displayed on the Subscription Details of the VF page
    */
    private Zuora__Subscription__c subscriptionDetails(Id subId) {
        sub  = new Zuora__Subscription__c ();
        if(subId!=NULL || subId!=''){
            try {
                sub = [SELECT Recipient_Contact__c, Payment_Mode_1__c FROM Zuora__Subscription__c WHERE Id = :subId];
            } catch (exception e) {
                sub = null;
            }
        }
        else{
            sub=NULL;
        }
        System.debug(sub);
        return sub;
    } 
    
    /* 
     * By: <FrancisMartinBenzon>
     * @Descrption: Method gets selected UserIds and Service Flags to be disabled in Asia1.
     * @Parameters: String subscriptionId
     * @Return: Boolean Status of the Response of Callout.
    */
    
    public void getUserIdDisableSvcInAsia1(Id subscriptionId) {
        
        String UserNameId;
        String ServiceFlag;
        Boolean digital;
        Asia1_Subscription__c getSvcFlagsAsia1Sub = new Asia1_Subscription__c();
        Asia1__c getLdapIdAsia1 = new Asia1__c();
        Asia1CredsCreationForChangeofSub asia1creds = new Asia1CredsCreationForChangeofSub();
        
        if(subscriptionId != null) {
            getSvcFlagsAsia1Sub = [SELECT Id, Subscription__c, Service_Access_Flag__c, Asia1__c FROM Asia1_Subscription__c 
                                                        WHERE Subscription__c = :subscriptionId];
        }
    
        try {
            getLdapIdAsia1 = [SELECT Id, User_ID_LDAP_ID__c, Display_Name__c FROM Asia1__c WHERE Id = :getSvcFlagsAsia1Sub.Asia1__c];
        }
        catch(exception e) {
            System.debug('ERROR: hey' + e); 
        }
    
        UserNameId = getLdapIdAsia1.User_ID_LDAP_ID__c;
        ServiceFlag = getSvcFlagsAsia1Sub.Service_Access_Flag__c;
        digital = TRUE;
        
        asia1creds.disableServiceFlag(digital, UserNameId, ServiceFlag);
    }
    
    /**
  * @description : This method will retrieve all active subscriptions of the account
  *     and display in the existing subscriptin for renewal section of vf page
  */
    public void retrieveRelatedSubscriptions() {     
        
        map<id, string> packageId_publicationName = new map<id, string>();
        map<id, string> packageId_publicationPattern = new map<id, string>();
        map<id, id> productId_packageId = new map<id, id>();
        set<id> productIds = new set<id>();
        set<id> packageIds = new set<id>();
        list<SubscriptionWrapper> tmpSwList = new list<SubscriptionWrapper>();
        relatedSubscriptionList = new list<SubscriptionWrapper>();
        //START UD-0622 RReyes - for new logic in getting publication
        List<Product_Publication__c> prodPubList= new List<Product_Publication__c>();
        //END UD-0622 RReyes - for new logic in getting publication
        // retrieve recipient contact detai of the selected subscription
        try {
            //START UD-0622 05/06/15 RReyes - Added Main_Package_1__r.Name in the query
            zs = [select Id, Recipient_Contact__c, Cost_Center__c, Number_of_Copies__c,
                    Main_Package_1__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, 
                    Order_Number_1__c, Delivery_Charge_Type_1__c, Zuora__CustomerAccount__r.Name, 
                    Zuora__CustomerAccount__r.Payment_Mode__c, Main_Package_1__r.Name  
                    from Zuora__Subscription__c where Id = :thisOrder.Subscription__c];
            //END UD-0622 05/06/15 RReyes - Added Main_Package_1__r.Name in the query
            selectedPackageId = zs.Main_Package_1__c;         
            
            thisOrder.Recipient_Contact__c = zs.Recipient_Contact__c;
            thisOrder.Cost_Centre__c = zs.Cost_Center__c;
            //START UD-0633 CommentedOutBy FrancisBenzon : logic retrieves old sub details.
            //START UD-0689 04-21-2015 MarvinG Delivery_Charge_Type__c should be coming from Order object
            //thisOrder.Delivery_Charge_Type__c = zs.Delivery_Charge_Type_1__c;
            //END UD-0689 04-21-2015 MarvinG Delivery_Charge_Type__c should be coming from Order object
            //END UD-0633 CommentedOutBy FrancisBenzon : logic retrieves old sub details.
            selectedSubscription = new SubscriptionWrapper();
            selectedSubscription.subscriptionStartDate = zs.Zuora__SubscriptionStartDate__c;
            selectedSubscription.subscriptionEndDate = zs.Zuora__SubscriptionEndDate__c;
            selectedSubscription.mainPackage = zs.Main_Package_1__c;
            //START UD-0622 05/06/15 RReyes - Sets the Main Package Name
            selectedSubscription.packageName = zs.Main_Package_1__r.Name;
            //END UD-0622 05/06/15 RReyes - Sets the Main Package Name
            if (zs.Number_of_Copies__c != null) {
                selectedSubscription.quantity = integer.valueOf(zs.Number_of_Copies__c);
            }
            
            packageIds.add(zs.Main_Package_1__c);
            
            // retrieve related subscriptions
            if (zs.Order_Number_1__c != null) {
                 //START UD-0622 05/06/15 RReyes - Added Main_Package_1__r.Name in query
                for (Zuora__Subscription__c tmp : [select Main_Package_1__c, Number_of_Copies__c, Zuora__SubscriptionStartDate__c, 
                        Zuora__SubscriptionEndDate__c, Main_Package_1__r.Name from Zuora__Subscription__c 
                        where Order_Number_1__c = :zs.Order_Number_1__c and Id != :zs.Id]) {
                 //END UD-0622 05/06/15 RReyes - Added Main_Package_1__r.Name in query    
                    SubscriptionWrapper tmpSw = new SubscriptionWrapper();
                    tmpSw.subscriptionStartDate = tmp.Zuora__SubscriptionStartDate__c;
                    tmpSw.subscriptionEndDate = tmp.Zuora__SubscriptionEndDate__c;
                    tmpSw.mainPackage = tmp.Main_Package_1__c;
                    //START UD-0622 05/06/15 RReyes - Adds value for main package name
                    tmpSw.packageName = tmp.Main_Package_1__r.Name;
                    //END UD-0622 05/06/15 RReyes - Adds value for main package name
                    if (tmp.Number_of_Copies__c != null) {
                        tmpSw.quantity = integer.valueOf(tmp.Number_of_Copies__c);
                    }
                    
                    tmpSwList.add(tmpSw);
                    //START UD-0622 04/17/15 RReyes - Checks if product Id is already in the list
                    if(!packageIds.contains(tmp.Main_Package_1__c)){
                        packageIds.add(tmp.Main_Package_1__c);
                    }//END UD-0622 04/17/15 RReyes - Checks if product Id is already in the list
                    
                }
            }
            // end retrieve related subscriptions
            
            // retrieve publication detail
            for (Package__c pkg : [select Id, (select Id, Product_Rate_Plan__r.zqu__ZProduct__c from Package_Items__r) 
                    from Package__c where Id = :packageIds]) {
                
                for (Package_Item__c tmp : pkg.Package_Items__r) {
                    //START UD-0622 04/17/15 RReyes
                        if(!productId_packageId.keySet().contains(tmp.Product_Rate_Plan__r.zqu__ZProduct__c)){
                            productId_packageId.put(tmp.Product_Rate_Plan__r.zqu__ZProduct__c, pkg.Id);
                        }//END UD-0622 04/17/15 RReyes
                }
            }
            
            //START UD-0622 RReyes - Changed logic in case of multiple product publications
            if(productId_packageId.keySet().size() > 0){
                for(Id zProdId: productId_packageId.keySet()){
                    prodPubList.clear();    
                    prodPubList = [select Publication_Code__c, Publication_Code__r.Name, Publication_Code__r.Publish_Pattern__c, 
                                    Publication_Code__r.Sunday_Publication__c, Publication_Code__r.Platform_Type__c, ZProduct__c 
                                    from Product_Publication__c where ZProduct__c =: zProdId];
                System.debug('>>>prodPubList.size: ' + prodPubList.size());
                System.debug('>>>prodPubList: ' + prodPubList);
                if(prodPubList.size() == 1){
                    System.debug('>>ProdPubList' + prodPubList[0]);
                    if(prodPubList[0].ZProduct__c != null){
                        id tmpPkgId = productId_packageId.get(prodPubList[0].ZProduct__c);
                         if (tmpPkgId != null) {
                            packageId_publicationName.put(tmpPkgId, prodPubList[0].Publication_Code__r.Name);
                            packageId_publicationPattern.put(tmpPkgId, prodPubList[0].Publication_Code__r.Publish_Pattern__c);
                         }
                    }
                }
                else if(prodPubList.size() > 1){
                    for(Product_Publication__c tmp : prodPubList){
                        if(tmp.ZProduct__c != null && tmp.Publication_Code__r.Platform_Type__c == 'Print' && tmp.Publication_Code__r.Sunday_Publication__c != null){
                            id tmpPkgId = productId_packageId.get(tmp.ZProduct__c);
                            if (tmpPkgId != null) {
                                packageId_publicationName.put(tmpPkgId, tmp.Publication_Code__r.Name);
                                packageId_publicationPattern.put(tmpPkgId, tmp.Publication_Code__r.Publish_Pattern__c);
                            }
                        }
                    }
                }   
                }
                }
             
                
                    
                    
                        
                
            //END UD-0622 RReyes - Changed logic in case of multiple product publications
            
            // end retrieve publication detail
            
            if (selectedSubscription.mainPackage != null) {
                selectedSubscription.publicationName = packageId_publicationName.get(selectedSubscription.mainPackage);
                //START: UD-0622 04/17/15 RReyes - Changed reference from Name to Pattern
                selectedSubscription.publicationPrintPattern = packageId_publicationPattern.get(selectedSubscription.mainPackage);
                //END: UD-0622 04/17/15 RReyes - Changed reference from Name to Pattern
            }
            
            if (relatedSubscriptionList != null) {
                relatedSubscriptionList.clear();
            }
            for (SubscriptionWrapper tmp : tmpSwList) {
                tmp.publicationName = packageId_publicationName.get(tmp.mainPackage);
                //START: UD-0622 04/17/15 RReyes - Changed reference from Name to Pattern
                tmp.publicationPrintPattern = packageId_publicationPattern.get(tmp.mainPackage);
                //END: UD-0622 04/17/15 RReyes - Changed reference from Name to Pattern
                relatedSubscriptionList.add(tmp);
            }
            
            
        } catch (exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Invalid Subscription Id = ' +thisOrder.Subscription__c + tmpSwList);
            ApexPages.addMessage(myMsg);
            
       }
        // end retrieve recipient contact details of the selected subscription
    
    }
    //START : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons 
    public PageReference submit() {
        
        PageReference pgRef;
        
        if (orderLineItem != null) {
            
            //START D-2588 [MD- 12] KEstoya - Processing of CreditBalance 3/17/15
            // creditBalance(thisOrder.Id);	// Start/End UD-2501 27Aug15 JohnD - commented out 
            //END D-2588 [MD- 12] KEstoya - Processing of CreditBalance 3/17/15
            
            thisOrder.Status__c = 'Provisioning';
            mapId_StartDate.put(thisOrder.Subscription__c, orderLineItem.Start_Date__c);
                
            //START UD-2193 07/31/2015 Added by J.Sarion - Commented out disabling of Asia1 and Create Asia1 accounts
            try {
                //getUserIdDisableSvcInAsia1(thisOrder.Subscription__c);
                //Asia1CredsCreationForChangeofSub createAsia1 = new Asia1CredsCreationForChangeofSub();    // Start/End UD-3452 19Jan16 JohnD - commented out
                asia1List = registerAsia1Accounts(thisOrder.Id);    // Start/End UD-3452 19Jan16 JohnD - call the method in the sm_subscriptionhelper instead
            }  
            catch(Exception e) {
                system.debug(thisOrder.Subscription__c);
                
            }
            //END UD-2193 07/31/2015 Added by J.Sarion - Commented out disabling of Asia1 and Create Asia1 accounts
            
            /* Start D-2593 26Mar15 JohnD moved this to SM_SubscriptionCancellationHelper class
            
            Subscription_Handler sh = new Subscription_Handler();
            sh.origin = 'Change of Subscription';              
            sh.Subscription_Handler_Direct(thisOrder);
            
            End D-2593 26Mar15 JohnD moved this to SM_SubscriptionCancellationHelper class */
            
            //START UD-1595 JTeves/FBenzon 19-June-2015 Move the Case Creation to COS Controller, and Subscription Creation to Queueable class
            //START D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
            List<Order_Line_Item__c> orderLineItems = [SELECT Order__c, Order__r.Subscription__c, Order__r.Subscription__r.Billing_Type__c, Order__r.Subscription__r.Order_Line_Item_Number__c, Main_Package_Billing_Type__c, Urgent__c, Fee_Waiver__c, Start_Date__c  FROM Order_Line_Item__c WHERE Order__c = :thisOrder.Id];
            List<Zuora__Subscription__c> zSubs;
            Boolean isUrgentRequest = FALSE;
            Boolean needWaiverApproval = FALSE;
            Boolean isUrgentInvoicing = FALSE;
            for(Order_Line_Item__c oli : orderLineItems) {
                if (oli.Urgent__c == True) {
                    isUrgentRequest = TRUE;
                }
                if (oli.Fee_Waiver__c == True) {
                    needWaiverApproval = TRUE;
                }
                if((oli.Order__r.Subscription__r.Billing_Type__c == FULL_PRE && oli.Main_Package_Billing_Type__c == FULL_PRE) || (oli.Order__r.Subscription__r.Billing_Type__c == FULL_PRE && oli.Main_Package_Billing_Type__c == MR_PRE) || (oli.Order__r.Subscription__r.Billing_Type__c == MR_PRE && oli.Main_Package_Billing_Type__c == FULL_PRE && oli.Start_Date__c.toStartOfMonth() == Date.today().toStartOfMonth())) {
                    isUrgentInvoicing = TRUE;
                }
            }
            
            //START D-3423 Wenjun 27 Aug 15 : Vendor / Mailing Agent Assignment
            //START D-3481 UAT Hotifx 02 Sep 15: Urgent COS
            //Calling Subscription Handler - Create COS Case and Vendor Assignment
            Subscription_Handler sh = new Subscription_Handler();
                    
            //Only cancel Subscription right away if Order is not urgent/no waiver approval required
            if(!isUrgentRequest && !needWaiverApproval) {
                if(isUrgentInvoicing) {
                    // cancel subscription 
                    SM_SubscriptionCancellationHelper.associatedOrder = thisOrder; // Start/End D-2593 26Mar15 JohnD
                    SM_SubscriptionCancellationHelper.cancelSubscriptions(mapId_StartDate, GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION);
                    
                    sh.origin = GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION; //Bypass Quotes Submission
                }
                else if(orderLineItems[0].Order__r.Subscription__c != null && orderLineItems[0].Order__r.Subscription__r.Order_Line_Item_Number__c != null ) {
                    
                    zSubs = [Select Id, Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c 
                            WHERE Order_Line_Item_Number__c = :orderLineItems[0].Order__r.Subscription__r.Order_Line_Item_Number__c];
                    
                    for(Zuora__Subscription__c zSub : zSubs) {
                        zSub.ZUora__SubscriptionEndDate__c = orderLineItems[0].Start_Date__c.addDays(-1);
                    }
                    
                    sh.origin = GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION +' - Future'; //Quotes will be submitted
                }
            }
            else //Need Approval
            {
                    sh.origin = GlobalVariableClass.RECTYPE_CHANGE_OF_SUBSCRIPTION; //Bypass Quotes Submission
            }
            //END D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
            
            // sh.Subscription_Handler_Direct(thisOrder);	// Start/End D-3925 12Nov15 JohnD - commented out
            //END D-3481 UAT Hotifx 02 Sep 15: Urgent COS
            //END D-3423 Wenjun 27 Aug 15
            
            if ((isUrgentRequest || needWaiverApproval) || !isUrgentInvoicing || (isUrgentInvoicing && SM_SubscriptionCancellationHelper.isSuccess)) {
                
                try {
                    thisOrder.DTL_Date__c = SM_SubscriptionHelper.getDtlDate();
                    update thisOrder;
                    
					sh.Subscription_Handler_Direct(thisOrder);	// Start/End D-3925 12Nov15 JohnD
					
                    //START D-3166 24-26-2015 Marvin Gatchalian
                    List<Order_Line_Item__c> orderLIst = [SELECT id, DTL_Date__c from Order_Line_Item__c where Order__c = :thisOrder.Id];
                    if(!orderLIst.isEmpty())
                    {
                        for(Order_Line_Item__c orderLI : orderLIst )
                        {
                            orderLi.DTL_Date__c = dtlDate;
                        }
                        update orderLIst;
                    }
                    //END D-3166 24-26-2015 Marvin Gatchalian
                    
                    //START D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
                    //START D-3225 Hotfix addedBy JSar/Fritz - attempt to dereference null to zSubs
                    if(zSubs != null && !zSubs.isEmpty()) {
                        update zSubs;
                    }
                    //END D-3225 Hotfix addedBy JSar/Fritz - attempt to dereference null to zSubs
                    //END D-3226 JTeves 4-July-2015 - PSTOP/COS Process Updates
                    
                    pgRef = new PageReference('/' + thisOrder.Account__c);
                    pgRef.setRedirect(true);
          
                } catch (exception e) {
                    ApexPages.addMessages(e);
                }
                
            } else {
                ApexPages.Message error = new ApexPages.Message(ApexPages.Severity.ERROR, SM_SubscriptionCancellationHelper.errorMessage);
                ApexPages.addMessage(error);
                return null; //START/END UD-3371 AddedBy FrancisBenzon : return error of cancellation
                return null; //fritz
            }
            // End D-2593 26Mar15 JohnD added logic
            //END UD-1595 JTeves/FBenzon 19-June-2015 Move the Case Creation to COS Controller, and Subscription Creation to Queueable class  
                
        }
        //START: D-1409 01/08/15 Added by A Banaag - display error when Submit is clicked without order line item
        else {
            ApexPages.Message error = new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot submit Change of Subscription: Order line item not found');
            ApexPages.addMessage(error);
            return null; //START/END UD-3371 AddedBy FrancisBenzon : return error if no oli
        }
        //END: D-1409 01/08/15 Added by A Banaag - display error when Submit is clicked without order line item
            //START UD-1831 7/14/15 AddedBy FrancisBenzon : to populate DTL Date
        //START UD-2193 07/31/2015 Added by J.Sarion - Update Asia1 records
        if(!asia1List.isEmpty()){
            update asia1List;
        }
        //END UD-2193 07/31/2015 Added by J.Sarion - Update Asia1 records
        
        pgRef = new PageReference('/' + thisOrder.Account__c);
        pgRef.setRedirect(true);
            //END UD-1831 7/14/15 AddedBy FrancisBenzon : to populate DTL Date
        return pgRef;
    }
    //END : D-1853 1/21/2015 JLedesma - Change of Subscription removal of radio buttons 
    
    public PageReference void() {
        
        PageReference pgRef;
        id caseId = getCase(thisOrder.Id);
        
        if (caseId != null) {
            
            try {
                
                Case c = [select Id, Status from Case where Id = :caseId];
                c.Status = 'Void';
                
                try {
                    
                    update c;
                    thisOrder.Status__c = 'Cancelled';
                    
                    try {
                        
                        update thisOrder;
                        pgRef = new PageReference('/' + thisOrder.Account__c);
                        pgRef.setRedirect(true);
                        
                    } catch (exception eo) {
                        ApexPages.addMessages(eo);
                    }
                    
                } catch (exception ec) {
                    ApexPages.addMessages(ec);
                }
            } catch (exception e) {
                ApexPages.addMessages(e);
            }
        }
        //START: D-0477 12/10/2014 Added By C. Lin - Added else condition to redirect to account when no case is attached to the order for change of subscription yet.
        else{
            thisOrder.Status__c = 'Cancelled';
            try{
                update thisOrder;
                pgRef = new PageReference('/' + thisOrder.Account__c);
                pgRef.setRedirect(true);
            } catch (exception e) {
                ApexPages.addMessages(e);
            }
        }
        //END: D-0477 12/10/2014 Added By C. Lin
        return pgRef;
    }
    
    
    private id getCase(Id orderId){
        
        try {
            id caseId = [select Case__c from Order_Line_Item__c where Order__c = :orderId limit 1].Case__c;
            return caseId;
            
        } catch (exception e) {
            return null;
        }
    }


    public PageReference edit() {
        //START/END D-2332 3/13/15 AddedBy FrancisBenzon : show inputted fields if user want to edit COS 
        string retUrl = '/apex/SM_ChangeOfSubscriptionEntry?id=' + thisOrder.Id + '&accountId=' + thisOrder.Account__c + '&subscriptionId=' + thisOrder.Subscription__c;
        PageReference pgRef = new PageReference(retUrl);
        pgRef.setRedirect(true);
        
        return pgRef;
        
    }
    
    //START D-2663 AddedBy FrancisBenzon : enable cancel action when Error encountered upon submit
    public PageReference doCancel() {
                        
        if(thisOrder.Id<>null){
       
            delete [select id from Order_Line_Item__c where Order__c = :thisOrder.Id];
            delete [select id from Order__c where Id = :thisOrder.Id];
        }
               
        string retURl = '/' + thisOrder.Account__c;
        PageReference pgRef = new PageReference(retUrl);
        pgRef.setRedirect(true);
        
        return pgRef;
        
    }
    //END D-2663 AddedBy FrancisBenzon : enable cancel action when Error encountered upon submit
    
    
    //START D-2588 [MD- 12] KEstoya - Processing of CreditBalance 3/17/15
    
    public void creditBalance(id orderId){
    
        
                
        Zuora__Refund__c zr = new Zuora__Refund__c();
        Zuora__Payment__c zp = new Zuora__Payment__c();
        ZuoraCallOut creditBalanceCallOut = new ZuoraCallOut();       
        Set<Id> billAcctIds = new Set<Id>();
        List<Zuora__CustomerAccount__c> cAccounts = new List<Zuora__CustomerAccount__c>();
        
        String startDate;
        startDate = zuora.zUtil.getZuoraDate(date.today()); 

        
        List<Zuora__CustomerAccount__c> billingAccts = [SELECT Zuora__AccountNumber__c, Zuora__External_Id__c, Zuora__Credit_Balance__c, Payment_Mode__c, Zuora__Default_Payment_Method__r.Zuora__External_Id__c FROM Zuora__CustomerAccount__c 
                                                        WHERE Zuora__Account__c =: thisOrder.Account__c]; // START/END UD-2498 10/23/2015 K. Tan
                                                        
        
        
        for(Zuora__CustomerAccount__c billAcc: billingAccts){
            billAcctIds.add(billAcc.Id);
            if(billAcc.Zuora__Credit_Balance__c > 0){
                cAccounts.add(billAcc);
            }
        }
                                
        Order__c order  = [SELECT Id, Billing_Account__c, Billing_Type__c, Billing_Account__r.Zuora__Zuora_Id__c FROM Order__c WHERE Id =: orderId];
        
        //Map<String, Object> refundRecs = new Map<String, Object>();
        Map<String, Object> paymentRecs = new Map<String, Object>();
        List<Map<String, Object>> listMap = new List<Map<String, Object>>();
        Decimal totalRefund = 0;
        
        
        if (thisOrder.Billing_Type__c != null){
            
            if ((thisOrder.Billing_Type__c.equalsIgnorecase('Full Prepaid')) &&
                (thisOrder.Billing_Account_Creation_Mode__c != 'Create New Billing Account')){
                
                
            for (Zuora__CustomerAccount__c billAcct:cAccounts){
                    if(billAcct.Id != order.Billing_Account__c){
                        
                        Map<String,Object> refundMap = new Map<String, Object>();
                        refundMap.put('AccountId', billAcct.Zuora__External_Id__c);                 
                        refundMap.put('Amount', billAcct.Zuora__Credit_Balance__c); 
                        refundMap.put('SourceType', 'CreditBalance'); 
                        // START UD-2498 10/23/2015 K. Tan
                        if(billAcct.Payment_Mode__c == 'CreditCard' || billAcct.Payment_Mode__c == 'Paypal') {
                        
                            refundMap.put('Type', 'Electronic');
                            refundMap.put('PaymentMethodId', billAcct.Zuora__Default_Payment_Method__r.Zuora__External_Id__c);
                        }
                        else{
                            refundMap.put('Type', 'External');
                            refundMap.put('MethodType', 'Other' );  
                        }
                        //END UD-2498 10/23/2015 K. Tan
                        listMap.add(refundMap);
                        totalRefund += billAcct.Zuora__Credit_Balance__c;
                    } 

                }
                List<Map<String,String>> resultMap = creditBalanceCallOut.loadZObjects(listMap, 'Refund');

                    //Map<String,String> resultMap = RefundCallOut.createMultipleZObject(listMap, 'Refund');
                    for(Map<String, String> rMap: resultMap) {
                        if (rMap.get('Status') == 'Success') {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, ConstantsSLB.geterrorMessage('SuccessfullyCreatedRefund'))); 
                        }
                        else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('FailedCreateRefundForBA')));
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Message: ' + rMap.get('Message')));

                        }

                        }
                        
                  
                
                    
                String cashId;
                String checkId;
                
                cashId = ConstantsSLB.getKeyId('PaymentMethodId_Cash');
                checkId = ConstantsSLB.getKeyId('PaymentMethodId_Check');
                
                     
                Map<String,Object> p = new Map<String, Object>();  

                if(totalRefund != 0){
                    p.put('AccountId', order.Billing_Account__r.Zuora__Zuora_Id__c);
                    p.put('Amount', totalRefund);
                    p.put('AppliedCreditBalanceAmount', totalRefund);
                    p.put('Type', 'External');
                    p.put('Status', 'Processed');  
                    p.put('EffectiveDate', startDate);                
                    p.put('PaymentMethodId', cashId);
                }
                
                try{
                Map<String,String> resultMap2 = creditBalanceCallOut.createZObject(p, 'Payment');
                

                    if (resultMap2!=null){
                    
                        
                        
                            if(resultMap2.get('Status') == 'Success'){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, ConstantsSLB.geterrorMessage('Credit Balance Payment Success')));
                            }
                            else{
                                
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.geterrorMessage('Failed Credit Balance Payment')));
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Message: ' + resultMap2.get('Message')));
                                
                            }
                            
                    }
                }
                catch(exception z){
                    system.debug(z);
                }
                                      
        }
    
    }   
       
    }
    //END D-2588 [MD- 12] KEstoya - Processing of CreditBalance 3/17/15
}