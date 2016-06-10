/**
     * Class Name: StopSubOrderEntryDirectViewController 
     * @author: Alyana Navarro
     * Date: 12/09/2014
     * Requirement/Project Name: <SPH>
     * History : 2/16/2015 - Joban - Code Review Activity : Modified code to prevent SOQL errors
     */
public class StopSubOrderEntryDirectViewController { 
    public Case caseRecord {get; set;}
    public List<Order_Line_Item__c> orderLineItemList {get; set;}
    public List<Asia1_Subscription__c> relatedAsiaList {get; set;}    
/*20141127 Playstation D0985
    public Account account {get; set;}  
*/
    public Account account1 {get; set;} //variables are not case-sensitive in Salesforce, Account is the same as account
/*20141127*/
    public Order__c order {get; set;}
    public Set<String> subscriptionId {get; set;}
    public Case caseCreated {get; set;}
    public List<Package_Access_Flag__c> pafList = new List<Package_Access_Flag__c>();
    public String parentId {get; set;}
    private Date esd;
    private Integer esdIndex;
    public class AsiaRelatedListWrapper{
        public String id {get; set;}
        public String userId {get; set;}
        public String serviceFlag {get; set;}
        public String status {get; set;}
        public Decimal quantity {get; set;}
        public String asiaSubscription {get; set;}
    }
    AsiaRelatedListWrapper asiaWrapper = new AsiaRelatedListWrapper();
    public List<AsiaRelatedListWrapper> asiaRelatedList {get; set;}
    public Map<ID,Date> mapOliIDToStopDate = new Map<ID,Date>(); //START END UD-1676 Wenjun 22/06/15
    
    /* Description: Method constructor for class
     * Parameter: 
     * Return: 
     */
    public StopSubOrderEntryDirectViewController() {        
        getOrder();
        getAccount();
        getOrderLineItem();
        getCase();       
        validateVoid(order);
        parentId =  ApexPages.currentPage().getParameters().get('def_parent_id');
    }
    
    /* Description: Method for getting account record
     * Parameter: 
     * Return: 
     */
    public void getAccount(){       
        String accountId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.PARAMETER_ACCOUNTID);
        if(accountId != null){
/*20141127 Playstation D0985
            account = [SELECT name, id FROM Account WHERE id = :accountId];
*/
            account1=[SELECT name,
                             id
                      FROM Account
                      WHERE id=:accountId]; //variables are not case-sensitive in Salesforce, Account is the same as account
/*20141127*/
        }
    }
    
    /* Description: Method for getting case record
     * Parameter: Id
     * Return: 
     */
    public void getCase(Id caseId){
        caseCreated = new Case();
        
        try{
        //Start 2/17/2015 - Joban - Code Review Activity : Added null check
            if(caseId!=null){
                caseCreated = [SELECT id, status, order_number__c, Sub_Status__c, Urgent_Request__c, Send_to_Retention__c, Requires_Urgent_Approval__c, Request_for_Waiving_of_Admin_Charge__c, Stop_Waive_Request__c FROM Case WHERE id =: caseId];
            }
        //End 2/17/2015 - Joban - Code Review Activity : Added null check
        } catch(Exception e){
            system.debug('No existing case.');
        }        
    }
    
    /* Description: Method constructor for class
     * Parameter: 
     * Return: 
     */
    public void getCase(){
        caseCreated = new Case();
        
        try{
        //Start 2/17/2015 - Joban - Code Review Activity : Added null check
            if(order.id != null){
                caseCreated = [SELECT id, status, order_number__c, Sub_Status__c, Urgent_Request__c, Send_to_Retention__c, Requires_Urgent_Approval__c, Request_for_Waiving_of_Admin_Charge__c, Stop_Waive_Request__c FROM Case WHERE order__c =: order.id];
            }
        //End 2/17/2015 - Joban - Code Review Activity : Added null check
        } catch(Exception e){
            system.debug('No existing case.');
        }        
    }
    
    /* Description: Method for getting order record
     * Parameter: 
     * Return: 
     */
    public void getOrder(){
        String orderId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.PARAMETER_ORDERID);    
        system.debug('>>>>>CHA getOrder orderId ' + orderId);
        if(orderId != null){    
        // START : D-1359 2/12/2015 Alyana Navarro
            order = [SELECT id, name, ownerId, status__c, case_record_type__c, category__c, sub_category__c, Eligible_for_Retention__c, Account__c, 
                    Send_to_Retention__c, Parent_Case__c , Urgent_Stop__c, isWaive__c
                    FROM Order__c 
                    WHERE id =: orderId];
        // END : D-1359 2/12/2015           
        }
        system.debug('>>>>>CHA getOrder order ' + order);
    }
    
    /* Description: Method for getting Order Line Item Records
     * Parameter: 
     * Return: 
     */
    public void getOrderLineItem(){
        Set<String> packIdSet = new Set<String>();
        Set<String> SVCSet = new Set<String>();
        subscriptionId = new Set<String>();
        //Start 2/17/2015 - Joban - Code Review Activity : Added null check
        system.debug('>>>>>CHA getOrderLineItem order.Id ' + order.Id);
        if(order.Id!=null){ 
        //START UD-1676 Wenjun 22/06/15 : Add subscription__r.Order_Line_Item_Number_1__c
            orderLineItemList = [SELECT id, name, subscription__c, earliest_stop_date__c, stop_request_date__c, terminating_reason__c,subscription__r.Order_Line_Item_Number_1__c,
                                 amount_to_refund__c, admin_charge__c, fee_waiver__c, fee_override__c, fee_override_amount__c, override_reason__c, 
                                 suppress_notification_stop__c, subscription__r.zuora__zuora_id__c, Main_Package_ID__c, Publication_1__c, Publication_2__c, Pending_Copies__c, Pending_Copies_2__c
                                 FROM Order_Line_Item__c WHERE order__c =: order.id]; 
        //END UD-1676 Wenjun 22/06/15
        //END UD-0364 4/8/2015 MGaelo added feeOverrideAmount                                               
        }
        //End 2/17/2015 - Joban - Code Review Activity : Added null check
        system.debug('>>>>>CHA getOrderLineItem orderLineItemList ' + orderLineItemList);
        for(Order_Line_Item__c oLineItem : orderLineItemList){
        
        //Start 2/17/2015 - Joban - Code Review Activity : Added null check
            if(oLineItem.subscription__r.id != null){ 
                subscriptionId.add(oLineItem.subscription__r.id);
                packIdSet.add(oLineItem.Main_Package_ID__c);
                //START UD-1676 Wenjun 22/06/15
                if(oLineItem.subscription__r.Order_Line_Item_Number_1__c != NULL)
                    mapOliIDToStopDate.put(oLineItem.subscription__r.Order_Line_Item_Number_1__c,oLineItem.stop_request_date__c); 
                //END UD-1676 Wenjun 22/06/15
            }
        //End 2/17/2015 - Joban - Code Review Activity : Added null check
        }                
        
        if(!(subscriptionId.isEmpty())){

            getRelatedAsiaSubscription();
        }   
    }
    
    /* Description: Method for getting Related Asia 1 Subscription
     * Parameter: 
     * Return: 
     */
    public void getRelatedAsiaSubscription(){
        Map<String, Package_Access_Flag__c> packageAccessFlagMap = new Map<String, Package_Access_Flag__c>();
        asiaRelatedList = new List<AsiaRelatedListWrapper>();
        //Start 2/17/2015 - Joban - Code Review Activity : Added null check
        if(subscriptionId!=null){ 
            //Start UD-1744 6/29/2015 - JLedesma - Asia 1 details on Save as Draft
            relatedAsiaList = [SELECT Service_Access_Flag__r.Name, id, Service_Access_Flag__c, Status__c, Subscription__c, Subscription__r.Main_Package_1__c, Asia1__r.User_ID_LDAP_ID__c, Concurrent__c 
                               FROM Asia1_Subscription__c 
                               WHERE Subscription__r.id IN :subscriptionId];
        }
        //END UD-1744 6/29/2015 - JLedesma - Asia 1 details on Save as Draft
        //End 2/17/2015 - Joban - Code Review Activity : Added null check
        Set<String> packageId = new Set<String>();
        for(Asia1_Subscription__c asia : relatedAsiaList){
            //Start 2/17/2015 - Joban - Code Review Activity : Added null check
            if(asia.Subscription__r.Main_Package_1__c!=null){
                packageId.add(asia.Subscription__r.Main_Package_1__c);
            }
        }
        if(!packageId.isEmpty()){
            pafList = [SELECT Id, Package_Service_Access_Flag__c, Package_Service_Access_Flag__r.Name, No_of_Concurrent_Users__c, package__c 
                       FROM Package_Access_Flag__c 
                       WHERE Package__c IN :packageId];
        }           
            //End 2/17/2015 - Joban - Code Review Activity : Added null check
        for(Package_Access_Flag__c psaf : pafList){
            //SVCSet.add(psaf.Package_Service_Access_Flag__r.Name);
            packageAccessFlagMap.put(psaf.package__c, psaf);
        }              
        
        for(Asia1_Subscription__c asiaSub : relatedAsiaList){
            //START UD-1744 6/29/2015 - JLedesma - Asia 1 details on Save as Draft
            asiaWrapper = new AsiaRelatedListWrapper();
            asiaWrapper.id = asiaSub.id;
            asiaWrapper.userId = asiaSub.Asia1__r.User_ID_LDAP_ID__c;
            asiaWrapper.status = asiaSub.status__c;
            asiaWrapper.asiaSubscription = asiaSub.subscription__r.id;
            asiaWrapper.serviceFlag =  asiaSub.Service_Access_Flag__r.Name;
            asiaWrapper.quantity = integer.valueOf(asiaSub.Concurrent__c);
            //END UD-1744 6/29/2015 - JLedesma - Asia 1 details on Save as Draft
                      
            asiaRelatedList.add(asiaWrapper);
        }                
        
    }
    
    /* Description: Method for redirecting to Edit mode
     * Parameter: 
     * Return: PageReference
     */
     public PageReference doEdit(){
        try {                       
            String retUrl=GlobalVariableClass.PAGEREFERENCE_TOEDIT+
                          GlobalVariableClass.PARAMETER_ORDERID+
                          '='+order.Id+
                          '&'+GlobalVariableClass.PARAMETER_ACCOUNTID+
                          '='+account1.id; //variables are not case-sensitive in Salesforce, Account is the same as account
/*20141127*/
            PageReference pgRef = new PageReference(retUrl);
            pgRef.setRedirect(true);
            
            return pgRef;
            
        } catch (exception e) {
            ApexPages.addMessages(e);
            return null;
        }
    }
    
    //declaration of variables
    
    public Case caseRec;
    public Static Boolean disable {get; set;}       
    
    /* Description: Method for validating if record can be void
     * Parameter: Order__c
     * Return: 
     */
    public void validateVoid(Order__c order){   
        if(order.Status__c == GlobalVariableClass.SUB_STATUS_PROVISIONING || order.Status__c == GlobalVariableClass.STATUS_CLOSE 
           || order.status__c == GlobalVariableClass.SUB_STATUS_PROVISIONED){ // START- END UD-3761 K. Tan 1/28/2015 Shall refer to STATUS_CLOSE instead 
            disable = false;
        }  
    }
    
    /* Description: Method for voiding of Order and/or Case
     * Parameter: 
     * Return: 
     */
    public PageReference voidStatus(){
        PageReference pgRef;

        order.Status__c = GlobalVariableClass.STATUS_VOID;
        if(caseRecord != null){
            caseRecord.Status = GlobalVariableClass.STATUS_VOID;
            update caseRecord;
        }
        if(order.Status__c == 'Void'){
            disable = true;
        }
        update order;
        
        try {                       
            /*20141127 Playstation D0985
            string retUrl = '/' + account.Id;
            */
            string retUrl='/'+account1.Id; //variables are not case-sensitive in Salesforce, Account is the same as account
            /*20141127*/
            pgRef = new PageReference(retUrl);
            pgRef.setRedirect(true);
            return pgRef;
        } 
        catch (exception e) {
            ApexPages.addMessages(e);
            return null;
        }          
    }
    
    /* Description: Method for cancelling transaction and redirecting to View Mode or account details
     * Parameter: 
     * Return: PageReference
     */
    public PageReference doCancel(){
        PageReference pgRef;
        try {                       
            string retUrl='/'+account1.id; //variables are not case-sensitive in Salesforce, Account is the same as account
/*20141127*/
            pgRef = new PageReference(retUrl);
            pgRef.setRedirect(true);
            return pgRef;
        } catch (exception e) {
            ApexPages.addMessages(e);
            return null;
        }        
    }    
    
    
    /* Description: Method for cancelling subscription to Zuora
     * Parameter: 
     * Return: 
     */
    public void cancelSubscription(){
        Map<id, Date> subDateMap = new Map<id, Date>();
        //checks if checkboxes from Order
       
        for(Order_Line_Item__c oLineItem : orderLineItemList){
            subDateMap.put(oLineItem.Subscription__c, oLineItem.Stop_Request_Date__c);
        }
        //START D-0941 12/3/2014 JB Domingo - Added code for Retention Offer process
 
        //START D-2003 2-18-15 AddedBy FrancisBenzon : affected by Cancellation in Change of Subscription. Added input paramater. 
        
        // SM_SubscriptionCancellationHelper.cancel(subDateMap, GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION );  Start/End UD-364 13Apr15 MGaelo deleted by JohnD 
        //END D-2003 2-18-15 AddedBy FrancisBenzon : affected by Cancellation in Change of Subscription. Added input paramater. 
        /*    if(Order.Urgent_Stop__c == TRUE || Order.Send_to_Retention__c == TRUE || Order.Request_for_Waiving_of_Admin_Charge__c == TRUE){
                //if(caseCreated.Sub_Status__c == GlobalVariableClass.SUB_STATUS_READY_FOR_SUBMISSION){              
                if(caseCreated.Sub_Status__c == 'Ready for Subscription'){
                    
                    //CancelSubscriptionForStopSub.amendForSubCancelation(subDateMap, account.id);
                    //cancelSub.checkDeliveryCharge(oLineItem.subscription__r.zuora__zuora_id__c, oLineItem.stop_request_date__c);
                }
            }
            if(Order.Urgent_Stop__c !=TRUE || Order.Send_to_Retention__c !=TRUE || Order.Request_for_Waiving_of_Admin_Charge__c!=TRUE){
                SM_SubscriptionCancellationHelper.cancel(subDateMap);
                

                //CancelSubscriptionForStopSub.amendForSubCancelation(subDateMap, account.id);
                
                //cancelSub.checkDeliveryCharge(oLineItem.subscription__r.zuora__zuora_id__c, oLineItem.stop_request_date__c);
            }*/ //END D-0941 12/3/2014 JB Domingo 
            if(caseCreated.Send_to_Retention__c ==false && caseCreated.Urgent_Request__c==false  && caseCreated.Requires_Urgent_Approval__c == false && caseCreated.Request_for_Waiving_of_Admin_Charge__c == false && caseCreated.Stop_Waive_Request__c==false){
                //START: D-1625,1406, 1356 1/22/2015 Added by Kristine Campang - commented out lines
                /*caseCreated.status = GlobalVariableClass.STATUS_PROVISIONED;            
                caseCreated.Sub_Status__c = GlobalVariableClass.SUB_STATUS_STOP_COMPLETED; 
                update caseCreated;*/
                //END: D-1625,1406, 1356
                order.status__c = GlobalVariableClass.STATUS_PROVISIONED;       
                update order;
            }
            if(caseCreated.Send_to_Retention__c ==true && caseCreated.Urgent_Request__c==false  && caseCreated.Requires_Urgent_Approval__c == false && caseCreated.Request_for_Waiving_of_Admin_Charge__c == false && caseCreated.Stop_Waive_Request__c==false){
                //START: D-1625,1406, 1356 1/23/2015 Added by Kristine Campang - commented out lines
                /*caseCreated.status = GlobalVariableClass.STATUS_PENDING;            
                caseCreated.Sub_Status__c = GlobalVariableClass.SUB_STATUS_FOR_RETENTION_OFFER; 
                update caseCreated;*/
                //END: D-1625,1406, 1356 1/23/2015 Added by Kristine Campang
                order.status__c = GlobalVariableClass.STATUS_PROVISIONED;       
                update order;
            }           
        }
                
    
    /* Description: Method for submitting the record for submission
     * Parameter: 
     * Return: PageReference
     */
    public PageReference submit() {        
        //save order line items       
        order.status__c = GlobalVariableClass.STATUS_PENDING;       
        update order;
        
        //Start UD-1642 Vpernicia 6/12/2015
        Decimal RefundAmount = 0;
        Decimal AdminChargeAmount = 0;
        //End UD-1642 Vpernicia 6/12/2015
        
        /**
          * Editted by : Alyana Navarro
          * D-0940
          * Validation when to create case and when to call out to zuora.
          **/
        Case existingCase;
        Case caseRecord = new Case();
        // START : D-1359 2/10/2015 Alyana Navarro
        Boolean isExisting;
        try{
            //Start 2/17/2015 - Joban - Code Review Activity : Added null check
            system.debug('>>>>>CHA order.id ' + order.id);
            if(order.id!=null){ 
                existingCase = [SELECT id, Sub_Status__c FROM Case WHERE Order_Number__c =: order.id];
            }
            //End 2/17/2015 - Joban - Code Review Activity : Added null check
            isExisting = true;
        } catch(Exception e){
            system.debug('>>>>>CHA e ' + e);
            isExisting = false;
        }
        system.debug('>>>>>CHA isExisting ' + isExisting);
        if(!isExisting){
        // END : D-1359 2/10/2015
            
            //call method to create case
            //populate parentId if applicable
            CreateCase cCase = new CreateCase(); 
            caseRecord = cCase.createCaseForStopSubscription(new List<Order__c>{order}, true)[0];

            if(order.Parent_Case__c != null){
                caseRecord.ParentId = order.Parent_Case__c;
            }
            //START END 12/11 D-0941 MGaelo deleted "if(order.Send_to_Retention__c != false)" to update the send to retention field
            //START: D-1625,1406, 1356 1/23/2015 Added by Kristine Campang - commented out lines    
                //caseRecord.Send_to_Retention__c = order.Send_to_Retention__c;
            //END: D-1625,1406, 1356 1/23/2015 Added by Kristine Campang
            system.debug('>>>>>CHA orderLineItemList.size() ' + orderLineItemList.size());
            if(orderLineItemList.size() > 0){

                //Start UD-1642 Vpernicia 6/12/2015
                setEarliestStopDateAndIndex(orderLineItemList);
                system.debug('>>>>>CHA orderLineItemList ' + orderLineItemList);
                for (Order_Line_Item__c Oli: orderLineItemList) {
                    system.debug('>>>>>CHA Oli ' + Oli);
                    RefundAmount += Oli.amount_to_refund__c;
                    // Start UD-1742 Dags 27/06/2015
                    //START:D-3683 10/2/15 Added by Manolo Valena - Updated from = to ==.
                    system.debug('>>>>>CHA Oli.fee_override__c ' + Oli.fee_override__c);
                    if(Oli.fee_override__c == true) {
                    //END:D-3683 10/2/15 Added by Manolo Valena
                        system.debug('>>>>>CHA Oli.fee_override_amount__c ' + Oli.fee_override_amount__c);
                        if (Oli.fee_override_amount__c != null){
                            AdminChargeAmount += Oli.fee_override_amount__c;
                        }else{
                            //START:D-3683 10/2/15 Added by Manolo Valena - Added condition to not process if admin charge is null.
                            if(Oli.admin_charge__c != null) {
                                AdminChargeAmount += Oli.admin_charge__c;
                            }
                            //END:D-3683 10/2/15 Added by Manolo Valena
                        }
                    }else{
                        system.debug('>>>>>CHA Oli.admin_charge__c ' + Oli.admin_charge__c);
                        //START:D-3683 10/2/15 Added by Manolo Valena - Added condition to not process if admin charge is null.
                        if(Oli.admin_charge__c != null) {
                            AdminChargeAmount += Oli.admin_charge__c;
                        }
                        //END:D-3683 10/2/15 Added by Manolo Valena
                    }
                 } 
                 // End UD-1742 Dags 27/06/2015   
                caseRecord.amount_to_refund__c = RefundAmount;
                caseRecord.admin_charges__c = AdminChargeAmount;
                //End UD-1642 Vpernicia 6/12/2015
            }                                               
            
            if(order.Send_to_Retention__c == false && order.Urgent_Stop__c == false && order.isWaive__c == false){
                getCase(caseRecord.id);
            }
            //START: D-1625,1406, 1356 1/23/2015 Added by Kristine Campang -commented out lines
            //START D-0509 related D-0941 12/4/2014 JB Domingo - changed the order fields in the IF condition
            //END D-0509 related D-0941 12/4/2014 JB Domingo
            //END: D-1625,1406, 1356 1/23/2015 Added by Kristine Campang
            if(!(subscriptionId.isEmpty())){
                List<Asia1_Subscription__c> Asia1 = [SELECT id, Service_Access_Flag__c, Status__c, Subscription__c, Subscription__r.Main_Package_1__c, Asia1__r.User_ID_LDAP_ID__c, Concurrent__c 
                                                        FROM Asia1_Subscription__c 
                                                        WHERE Subscription__r.id IN :subscriptionId];
                if(!(Asia1.isEmpty())){
                    caseRecord.Number_of_Asia1_Account__c = Asia1.size();
                }
            }
            
            upsert caseRecord;
        } else {
        // START : D-1359 2/12/2015 Alyana Navarro
            CreateCase cCase = new CreateCase(); 
            caseRecord = cCase.createCaseForStopSubscription(new List<Order__c>{order}, true)[0];           
            caseRecord = setCaseStatus(caseRecord, order);
            Database.update(caseRecord);            
            system.debug('>>>>>CHA caseRecord.Sub_Status__c ' + caseRecord.Sub_Status__c);
            if(caseRecord.Sub_Status__c == GlobalVariableClass.SUB_STATUS_READY_FOR_SUBMISSION){
                getCase(caseRecord.id);
            }
        // END : D-1359 2/12/2015   
        }
        // --End-- 
        
        //START UD-1676 Wenjun 22/06/15: Update Subscription End Date to PSTOP Request Date
       if(!mapOliIDToStopDate.isEmpty())
       {
           List<Zuora__Subscription__c> lstSubToUpd = new List<Zuora__Subscription__c>();
           for(Zuora__Subscription__c sub : [Select ID, Order_Line_Item_Number_1__c From Zuora__Subscription__c 
                                             where Order_Line_Item_Number_1__c in : mapOliIDToStopDate.keySet()])
           {
               if(mapOliIDToStopDate.containsKey(sub.Order_Line_Item_Number_1__c) 
                  && mapOliIDToStopDate.get(sub.Order_Line_Item_Number_1__c) != null)
               {
                   //START:UD-1559 7/1/15 Added by Manolo Valena - Updated subscription end date to stop request date minus 1.
                   sub.Zuora__SubscriptionEndDate__c = mapOliIDToStopDate.get(sub.Order_Line_Item_Number_1__c).addDays(-1);
                   //END:UD-1559 7/1/15 Added by Manolo Valena
                   lstSubToUpd.add(sub);
               }
           }
           UPDATE lstSubToUpd;
       } 
       //END UD-1676 Wenjun 22/06/15
        
        //Charles D-0635 - Add PageRef for exisitngCase
        // START : D-1359 2/10/2015 Alyana Navarro
        PageReference pRef;
        if(isExisting){     
            pRef = new PageReference('/' + existingCase.id);               
        }else{
            pRef = new PageReference('/' + caseRecord.id);            
        }
        
        return pRef;
        // END : D-1359 2/10/2015
    }
    
    // START : D-1359 2/10/2015 Alyana Navarro
    public Case setCaseStatus(Case caseRec, Order__c orderRec){     
        if(caseRec.Sub_Status__c == 'Urgent Stop Rejected'/*GlobalVariableClass.SUB_STATUS_URGENT_STOP_REJECTED*/){
            caseRec.Urgent_Request__c = orderRec.Urgent_Stop__c;
            caseRec.Stop_Waive_Request__c = orderRec.isWaive__c;            
            if(caseRec.Urgent_Request__c){
                caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_URGENT_STOP;
            } else if(caseRec.Stop_Waive_Request__c){
                caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_WAIVED;
            } else {
                caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_READY_FOR_SUBMISSION;
            }
        } else if(caseRec.Sub_Status__c == 'Waived Rejected'/*GlobalVariableClass.SUB_STATUS_WAIVED_REJECTED*/){            
            caseRec.Stop_Waive_Request__c = orderRec.isWaive__c;
            if(caseRec.Stop_Waive_Request__c){
                caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_WAIVED;
            } else {
                caseRec.Sub_Status__c = GlobalVariableClass.SUB_STATUS_READY_FOR_SUBMISSION;
            }
        }                       
        return caseRec;
    }
    // END : D-1359 2/10/2015
    /* Description: Method for obtaining the earliest stop date among all order line items related to case 
     * and its index in the list 
     * Parameter: 
     * Return: 
     */
    private void setEarliestStopDateAndIndex(List<Order_Line_Item__c> self)
    {
        if (self.size() == 0 || self.size()==null) {
            System.debug('List is empty.');
        }
        
        esd = self[0].earliest_stop_date__c;
        esdIndex = 0;

        for (integer i = 1; i < self.size(); ++i) {
            if (self[i].earliest_stop_date__c < esd) {
                esd = self[i].earliest_stop_date__c;
                esdIndex= i;
            }
        }
    }
    private void forWaiving(Case c){
        ////START: D-1625, D-1406, D-1356 Added by Kristine Campang -modified if condition added condition
        if(c.Request_for_Waiving_of_Admin_Charge__c || c.Stop_Waive_Request__c == true){
            c.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_WAIVED ;
            update c;
        }
        //END: D-1625, D-1406, D-1356 Added by Kristine Campang
    }
    
    private void forUrgent(Case c){
        if(c.Urgent_Request__c){
            c.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_URGENT_STOP ;
            update c;
        }
    }
}