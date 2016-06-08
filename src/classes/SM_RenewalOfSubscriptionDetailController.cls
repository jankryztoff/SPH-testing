/**
     * Class Name: SM_RenewalOfSubscriptionDetailController
     * @author: john dacutan
     * Date: 09/29/2014
     * Requirement/Project Name: SPH Project
     * @description : this class is use as a controller for the renewal detailed page of SM_RenewalOfSubscriptionDetail visualforce page
     * 
     */
// Start UD-2039 22Jul15 JohnD - removed "with sharing" keyword
public class SM_RenewalOfSubscriptionDetailController extends SM_SubscriptionHelper {
// End UD-2039 22Jul15 JohnD - removed "with sharing" keyword    
    final id orderId = ApexPages.currentPage().getParameters().get('id');
    final id accountId = ApexPages.currentPage().getParameters().get('accountId');
    
    public list<Order_Line_Item__c> orderLineItemList { get; set; }
    public string selectedOrderLineItem { get; set; }
    public Order__c thisOrder { get; set; }
    public Order_Line_Item__c orderLineItem { get; set; }
    public list<Order_Line_Item_Gift__c> promotionGifts { get; set; }
    public list<Asia1Wrapper> asia1Subscriptions { get; set; }
    public date dtlDate { get; set; }
    public transient boolean isFromPromotion { get; set; }
    public transient boolean isDigital { get; set; }
    public list<Zuora__Subscription__c> subscriptionList { get; set; }
    // Start D-1345 01/19/2015 JohnD variable that holds the package name of the subscription to be renewed
    public string selectedSubsriptionPackageName { get; set; }
    // End D-1345 01/19/2015 JohnD
    // START D2642 5/18/2015 GDELROSARIO : added varibale for the id of seletedPackage
    public string selectedPackageId {get; set;}
    // END D2642 5/18/2015 GDELROSARIO
    
    //START D-3316 08/06/2015 Added by J.Sarion - 
    List<Asia1__c> updateAsia1List = new List<Asia1__c>();
    //END D-3316 08/06/2015 Added by J.Sarion - 

    public void retrieveOrder() {

        list<SObject> orderList = new list<SObject>();
        string queryStr = generateOrderSoqlStr();
        if((string)orderId ==  ' ' || (string)orderId == 'null' || (string)orderId == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage('No Order in Retention Record'));
            ApexPages.addMessage(myMsg);
            //ApexPages.addMessage(ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('No Order in Retention Record')));
        }
        else {          
            queryStr += ' where (Order_Type__c = \'Renewal\' and Account__c = \'' + accountId + '\' and Status__c =\'Draft\')';
            queryStr += ' or Id = \'' + orderId + '\' limit 1';
        }
       
       try {
           
           	orderList = database.query(queryStr);
           	// Start D-1345 01/19/2015 JohnD proceed only when orderlist has a value
           	if (orderList.size() > 0) {
           		
	           	thisOrder = (Order__c)orderList[0];
	           	dtlDate = getDtlDate();            
	           	retrieveActiveSubscriptions();
	           	retrieveOrderLineItems();
	            
	           	// Start D-1345 01/19/2015 JohnD retrieve the subscription package name
	           	if (thisOrder.Base_Subscription__c != null) {
		           	
		           // START D2642 5/18/2015 GDELROSARIO : added varibale for the id of seletedPackage
                    list<Zuora__Subscription__c> tempList = [select Main_Package_1__r.Name,Main_Package_1__c from Zuora__Subscription__c 
                            where Id = :thisOrder.Base_Subscription__c];
                            
                    if (tempList.size() > 0) {
                        selectedSubsriptionPackageName = tempList[0].Main_Package_1__r.Name;
                        selectedPackageId = tempList[0].Main_Package_1__c;
                    }
                    // END D2642 5/18/2015 GDELROSARIO
	           	}
	            // End D-1345 01/19/2015 John
           	}
           	// End D-1345 01/19/2015 JohnD
    
        } catch (exception e) {
            ApexPages.addMessages(e);           
        }
        
    }

    /**
    * @description : This method will retrieve all active subscriptions of the account
    *       and display in the existing subscriptin for renewal section of vf page
    */
	//START: D-4659 4-11-2016 Added by Kristine Balaoing - added @Tsvisible to private methods 
     @TestVisible private void retrieveActiveSubscriptions() {
        
        subscriptionList = [select Id, Name, Main_Package_1__c, Subscription_Type_1__c, Recipient_Contact__r.Address__r.Building_Name__c, 
                Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Recipient_Contact__c, 
                Recipient_Contact__r.Address__r.Address_1__c, Recipient_Contact__r.Address__r.Address_2__c, 
                Recipient_Contact__r.Address__r.Address_3__c, Recipient_Contact__r.Address__r.Address_4__c,
                Recipient_Contact__r.Address__r.C_O_Company__c,
                Recipient_Contact__r.Address__r.City__c, Recipient_Contact__r.HomePhone 
                from Zuora__Subscription__c where Id = :thisOrder.Base_Subscription__c];
        
    }



    /*
     * Description: This method will retrieve all the order line items related to the Order.
     *      The list will be displayed on the Line Items section of the VF page
    */
    @TestVisible private void retrieveOrderLineItems() {

        orderLineItemList = getOrderLineItems(thisOrder.Id);
        selectedOrderLineItem = orderLineItemList[0].Id;
        retrieveOrderLineItem();
    } 

	//END: D-4659 4-11-2016 Added by Kristine Balaoing
    /*
     * Description: This method will retrieve the information of the selected Order Line Item and 
     *      populate the data on the Subscription Details Section of the VF page.
     *      This will allow the user to update the Order Line Item. Invoke when user click on the
     *      specific Order Line Item from the Line Item section of the VF page
    */
    public void retrieveOrderLineItem() {
        
        orderLineItem = getOrderLineItem(selectedOrderLineItem);
                
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



    // START D2642 5/18/2015 GDELROSARIO : Method for Callout of ASIA1 during SUMBIT of renewal
        // Start UD-3452 19Jan16 JohnD - commented out. no longer in used
        /*
        public void asia1callout(){
           
         boolean isAsia1Validated = false;
         string serviceFlag = '';
         string myPhone = '';
         string asia1ErrorResponse = '';
         
            if (thisOrder.Recipient_Contact__r.Phone <> null && myPhone == '') {
                myPhone = thisOrder.Recipient_Contact__r.Phone;
            }
            if (thisOrder.Recipient_Contact__r.HomePhone__c <> null && myPhone == '') {
                myPhone = thisOrder.Recipient_Contact__r.HomePhone__c;
            }
            if (thisOrder.Recipient_Contact__r.HomePhone__c <> null && myPhone == '') {
                myPhone = thisOrder.Recipient_Contact__r.HomePhone__c;
            }
            if (thisOrder.Recipient_Contact__r.Mobile_Number__c <> null && myPhone == '') {
                myPhone = thisOrder.Recipient_Contact__r.Mobile_Number__c;
            }   
                    map<string, string> asia1newCreate = new map<string, string>();
                    map<string, Object> asia1Return = new map<string, Object>();
                    //list<string> packageIdpromotionId = selectedPackageId.split(':');
                    Package_Access_Flag__c paf = [select Package_Service_Access_Flag__c, Package_Service_Access_Flag__r.Name, 
                                                   No_of_Concurrent_Users__c from Package_Access_Flag__c where Package__c = :selectedPackageId];
                    
                    List<Asia1__c> asia1Account = [SELECT Account_Name__c,Display_Name__c,Email__c,Password__c,User_ID_LDAP_ID__c 
                                                            FROM Asia1__c 
                                                                WHERE Contact__c =: thisOrder.Recipient_Contact__c 
                                                                AND Status__c = 'Pending Creation'
                                                                AND Order_Number__c =: thisOrder.Name 
                                                                    LIMIT 10];
            
                    system.debug('-->> asia1Account LIST : '+ asia1Account);
                    for (Asia1__c asia1SingleAccount :asia1Account ){
                            //START D-3316 08/06/2015 Added by J.Sarion - set service to com. Service flags will be enabled when the Subscription is created.
                            asia1newCreate = new map<string, string>();
                            serviceFlag = paf.Package_Service_Access_Flag__r.Name;
                            asia1newCreate.put(GlobalVariableClass.SVC, 'com');
                            //END D-3316 08/06/2015 Added by J.Sarion - set service to com. Service flags will be enabled when the Subscription is created.
                            asia1newCreate.put(GlobalVariableClass.USERNAME, asia1SingleAccount.User_ID_LDAP_ID__c);
                            asia1newCreate.put(GlobalVariableClass.PASSWORD, asia1SingleAccount.Password__c);
                            asia1newCreate.put(GlobalVariableClass.PASS_CHALLENGE, 'what+is+my+favourite+drink');
                            asia1newCreate.put(GlobalVariableClass.PASS_RESPONSE, asia1SingleAccount.Password__c);
                            asia1newCreate.put(GlobalVariableClass.FNAME, thisOrder.Recipient_Contact__r.FirstName.replace(' ', '+'));
                            asia1newCreate.put(GlobalVariableClass.LNAME, thisOrder.Recipient_Contact__r.LastName.replace(' ', '+'));
                            asia1newCreate.put(GlobalVariableClass.PHONE, myPhone);
                            asia1newCreate.put(GlobalVariableClass.DISPLAY_NAME, asia1SingleAccount.Display_Name__c);
                            asia1newCreate.put(GlobalVariableClass.EMAIL, asia1SingleAccount.Email__c);
                            asia1newCreate.put(GlobalVariableClass.ENABLE, 'false');
                            asia1newCreate.put(GlobalVariableClass.IP, '');
                        
                        
                            asia1Return = AsiaOneServicesController.createAccount(asia1newCreate);
                    
                             if (asia1Return.get('Errors') <> null) {
                                asia1ErrorResponse = string.valueof(asia1Return.get('Errors'));
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, asia1ErrorResponse );
                                ApexPages.addmessage(myMsg);
                                system.debug('-->> Error : '+ myMsg);
                                //START D-3316 08/06/2015 Added by J.Sarion - Set status and log
                                asia1SingleAccount.Status__c = 'Error Creation';
                                asia1SingleAccount.Log__c = string.valueOf(asia1Return.get('Errors'));
                                //END D-3316 08/06/2015 Added by J.Sarion - Set status and log
                            }
                            if (asia1Return.get('Error') <> null) {
                                asia1ErrorResponse = string.valueof(asia1Return.get('Error'));
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, asia1ErrorResponse );
                                ApexPages.addmessage(myMsg);
                                system.debug('-->> Error : '+ myMsg);
                                //START D-3316 08/06/2015 Added by J.Sarion - Set status and log
                                asia1SingleAccount.Status__c = 'Error Creation';
                                asia1SingleAccount.Log__c = string.valueOf(asia1Return.get('Error'));
                                //END D-3316 08/06/2015 Added by J.Sarion - Set status and log
                            }
                    
                            if (asia1Return.get('Sign-Up') == 'Success') {
                                asia1SingleAccount.Status__c = 'Created';
                                //START D-3316 08/06/2015 Added by J.Sarion - Set status and log
                                asia1SingleAccount.ASIAONE_Legacy_Id__c = (string)asia1Return.get('System Id');
                                asia1SingleAccount.Enabled__c = true;
                                //END D-3316 08/06/2015 Added by J.Sarion - Set status and log
                                //update asia1SingleAccount;
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Success' );
                                ApexPages.addmessage(myMsg);
                                 system.debug('-->> Pass : '+ myMsg);
                            }
                            //START D-3316 08/06/2015 Added by J.Sarion - Add to list for update
                            updateAsia1List.add(asia1SingleAccount);
                            //END D-3316 08/06/2015 Added by J.Sarion - Add to list for update
                    }       
        }
        */
        // End UD-3452 19Jan16 JohnD - commented out. no longer in used
    // END D2642 5/18/2015 GDELROSARIO

    
    
    public PageReference submit() {
        
        PageReference pgRef;
        boolean isError = false;
		Order_Line_Item__c tmp;
        
        // Start UD-3452 19Jan16 JohnD - re-used the registerAsia1Accounts from sm_subscriptionhelper
        try {
            update registerAsia1Accounts(thisOrder.Id);
        } catch (exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage());
            ApexPages.addMessage(myMsg);
            isError = true;
            
        }
        // End UD-3452 19Jan16 JohnD - re-used the registerAsia1Accounts from sm_subscriptionhelper
        
        //START D-3316 08/06/2015 Added by J.Sarion - Create Asia1 account
        // Start UD-3452 19Jan16 JohnD - commented out
        //try{
        //    asia1callout();
        //    if(!updateAsia1List.isEmpty()){
        //        update updateAsia1List;
        //    }
        //}catch(exception e){
        //    e.getStackTraceString();
        //}
        // End UD-3452 19Jan16 JohnD - commented out
        //END D-3316 08/06/2015 Added by J.Sarion - Create Asia1 account

        try {
            
            tmp = [select id from Order_Line_Item__c where Order__c = :thisOrder.Id limit 1];

        
        } catch (exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ConstantsSLB.getErrorMessage('No Order Line Item'));
            ApexPages.addMessage(myMsg);
            isError = true;
        }
        
        if (isError == false) {
            
            thisOrder.Status__c = 'Pending';
            //START D-1407 Added by FrancisBenzon Autopopulation of DTL Date
            thisOrder.DTL_Date__c = dtlDate;
            //END D-1407 Added by FrancisBenzon Autopopulation of DTL Date
            update thisOrder;
            
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
            
            //Start UD-678 VPernicia/MGatchalian 4/06/2015
            Quote_Handler QH = new Quote_Handler();
            QH.Create_Quotes(thisOrder, 'Renewal Subscription', tmp.id);
            //End UD-678 VPernicia/MGatchalian 4/06/2015
            
            Subscription_Handler sh = new Subscription_Handler();
            sh.origin = 'Renewal of Subscription';
            sh.Subscription_Handler_Direct(thisOrder);
            Renewal_CancelSubscription.getSubscriptionParams(thisOrder.Base_Subscription__c);
                
            pgRef = new PageReference('/' + thisOrder.Account__c);
            pgRef.setRedirect(true);
            
        }
        
        return pgRef;
    }
    
    
    public PageReference void() {
        
        thisOrder.Status__c = 'Void';
        
        update thisOrder;
        
        PageReference pgRef = new PageReference('/' + thisOrder.Account__c);
        pgRef.setRedirect(true);
        
        return pgRef;
        
    }

    
    public PageReference edit() {
        
        string retUrl = '/apex/SM_RenewalOfSubscriptionEntry?subscriptionId=' + thisOrder.Base_Subscription__c + '&accountId=' + thisOrder.Account__c;
        PageReference pgRef = new PageReference(retUrl);
        pgRef.setRedirect(true);
        
        return pgRef;
        
    }    
}