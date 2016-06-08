/**
 * Class Name: StopSubOrderEntry_VendorController
 * @author 
 * Date: 2014.09.09
 * Requirement: Stop Subscription Order Entry
 * @description This class is use as an apex controller of StopSubOrderEntry_Vendor VF page.
 *
 */


/*
 * ------Revision------
 * Version 1.0: Pilot Release
 * By: <Kim Saclag>
 * Description:
 */

public class StopSubOrderEntry_VendorController{
    
    public Case objcase {get;set;}
    public Case recordType {get; set;}
    public Account account {get; set;}
    public Contact objcontact {get; set;}
    public Order__c order {get; set;}
    public Publication__c pub {get; set; }
    public Order_Line_Item_Vendor__c oli{get; set;}
    public Integer counter {get; set;}
    public String index {get; set;}
    public List<SelectOption> items {get; set;}
    public id accountId;
    public id contactId;
    Public String orderId;
    public Subscription_Vendor_Publication__c pubObject {get; set;}
    public Non_Publication_Day__c nonPubObject {get; set;}
    public List<Subscription_Vendor_Publication__c> publicationRecordList {get; set;}    
    public List<Non_Publication_Day__c> nonPublicationRecordList {get; set;}
    public String WarningIcon {get; set;}
    public String RecordTypeId;
    public Set<String> subscriptionVId {get; set;}
    Boolean isNew = True;
    public Order_Line_Item_Vendor__c olivf {get; set;}
    //Start D-3041 06/01/2015 Added by Jason A. 
    Public Set <id> pubId {get; set;}
    //End D-3041 06/01/2015 Added by Jason A.   
    public List<Order_Line_Item_Vendor__c> orderLineItemList {
        get { 
            return [SELECT id, name, publication__c, Publication__r.name, mon__c, tue__c, wed__c, thu__c, fri__c, sat__c, sun__c, phd__c, phe__c, subscription_vendor__c, subscription_vendor__r.id, earliest_Start_Date__c, earliest_stop_date__c, stop_request_date__c, terminating_reason__c, Additional_Termination_Comment_del__c, notify_vendor__c, suppress_vendor_notification__c, Send_to_Retention__c
                    FROM Order_Line_Item_Vendor__c WHERE order__c =: order.id]; 
        }
        set;
        }
    //START D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
    List<Case_Vendor_Subscription__c> caseSubList = new List<Case_Vendor_Subscription__c>();
    Map<Id, Case_Vendor_Subscription__c> subIdToCOACaseSubMap = new Map<Id, Case_Vendor_Subscription__c>();
    Boolean notValid = false;
    //END D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
    /*
     * Order_Line_Item_Vendor__c reference data
     * Map<wrapper counter, Map<publish pattern, order line items vendor records under wrapper number>>
     */
    //START D-4080 Gdelrosario 11/12/2015 : added instantiation for code review
    Map<Integer, Map<String, Order_Line_Item_Vendor__c>> counterToLineItemsMap= new Map<Integer,Map<String,Order_Line_Item_Vendor__c>>();
    //END D-4080 Gdelrosario 11/12/2015 : added instantiation for code review
    
    //Wrapper class for Order Line Item Vendor Records
    public class OrWrapper {
        public String publicationId {get; set;}
        public String oliId {get; set;}
        public String publicationName {get; set;}
        public Decimal mon {get; set;}
        public Decimal tue {get; set;}
        public Decimal wed {get; set;}
        public Decimal thu {get; set;}
        public Decimal fri {get; set;}
        public Decimal sat {get; set;}
        public Decimal sun {get; set;}
        public Decimal phd {get; set;}
        public Decimal phe {get; set;}
        public Boolean isNotified {get; set;} 
        public Date earliestStopDate {get; set;}               
        public Date stopReqDate {get; set;}
        public String status {get; set;}
        public Id subVendor {get ; set;}
    }
    
    public list<OrWrapper> finalPublicationList {get; set;}

    public Set<Id> publicationIds = new Set<Id>();
    Id parentCaseId; //START/END UD-3293 RReyes 11/25/15
     /*
     * Description : This method is use to check if the order has an existing Account.
     * Parameters: None
     * Return : None
     */

    public StopSuborderEntry_VendorController() {

        finalPublicationList = new List<OrWrapper>();

        getAccount();
        olivf = new order_line_item_vendor__c();
        oli = new order_line_item_vendor__c();        
        pubObject = new Subscription_Vendor_Publication__c(Publication__r = new Publication__c());
        pubObject.Account__c = account.id;
        nonPubObject = new Non_Publication_Day__c(Publication__r = new Publication__c());        
        orderId = ApexPages.currentPage().getParameters().get('orderId');                        
        WarningIcon ='/s.gif';
        //START UD-3293 RReyes 11/25/15
        parentCaseId = ApexPages.currentPage().getParameters().get('def_parent_id');
        if (parentCaseId != null) {
                string tmp = parentCaseId;
                tmp.toLowerCase();
                if (tmp == 'null') {
                    parentCaseId = null;
                }
        }  
        //END UD-3293 RReyes 11/25/15
        //query order and order line items  
        if (accountId != null) {//edit mode      
            
            list<Order__c>  lOrder = new list<Order__c>();
            
            lOrder = [SELECT id, name, Case_Owner__c, ownerId, owner.name, status__c, case_record_type__c, category__c, sub_category__c, Account__c, Recipient_contact__r.Accountid, 
                     Stop_request_date__c, terminating_reason__c, suppress_vendor_notification__c
                     FROM Order__c                      
                     //WHERE account__c =: accountId   AND case_record_type__c =: 'Stop Subscription' AND status__c =: 'Draft' LIMIT 1]; 
                     WHERE account__c =: accountId   AND case_record_type__c =: GlobalVariableClass.RECTYPE_STOP_SUBSCRIPTION AND status__c =: GlobalVariableClass.STATUS_DRAFT LIMIT 1];         
            if(lOrder.size() >0 ){
                order = new Order__c();      
                order = lOrder[0];         
                orderId = order.id;                               
            } else {
                order = new Order__c();
            }
            
            order.ownerId = UserInfo.getUserId();
            order.account__c = accountid;
            order.recipient_contact__c = objcontact.id;
            order.status__c = GlobalVariableClass.STATUS_NEW;
            order.category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
            order.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_STOP_SUBCRIPTION;
            order.credit_balance__c = 0;
            order.delivery_charge__c = 0;
            order.monthly_delivery_charge_for_full_payment__c = 0; 
            recordTypeId = ApexPages.currentPage().getParameters().get('recordtype');
            if(recordTypeId != null) {
                recordType = [SELECT recordtype.name, recordtype.id FROM Case WHERE recordtype.id =: recordTypeId LIMIT 1];  
                order.case_record_type__c = recordType.recordType.name;
            }
            //START D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
            caseSubList = [SELECT Id, Case__r.Effective_Date__c, Subscription_Vendor__c, Case__r.CaseNumber, Case__r.RecordType.Name, Subscription_Vendor__r.Name FROM Case_Vendor_Subscription__c WHERE Case__r.Status =: GlobalVariableClass.STATUS_CLOSED AND Case__r.RecordType.Name = 'Change of Address/Vendor' AND Account__c = :accountId Order by Case__r.Effective_Date__c ASC];

            for (Case_Vendor_Subscription__c caseSub :caseSubList) {
                subIdToCOACaseSubMap.put(caseSub.Subscription_Vendor__c, caseSub);
            }
            //END D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
        }

        getOrder();

    }

    /*
     * Description : This method is use to check if the order has an existing Account.
     * Parameters: None
     * Return : None
     */

    public void getAccount() {
    
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        //Start : Code Review Implementation 02/18/2015 S.Puli
        if(accountId<>null){
        //end : Code Review Implementation 02/18/2015 S.Puli
            account = [SELECT id, name FROM Account WHERE id =: accountId];
        }//Start/End : Code Review Implementation 02/18/2015 S.Puli

        getContact();
    }
    
    /*
     * Description : This method is use to check if the order has an existing Contact.
     * Parameters: None
     * Return : None
     */
    
    public void getContact() {
            // START : D-1106 12/19/2014 Alyana Navarro
            //Start : Code Review Implementation 02/18/2015 S.Puli
            if(accountId<>null){
            //end : Code Review Implementation 02/18/2015 S.Puli
            //Start MMallorca UD-1167 05/09/2015
                try{
                    objcontact = [SELECT id, name FROM Contact WHERE Account.Id =: accountId AND Recipient_Indicator__c = true LIMIT 1];
                }
                catch(exception e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 'No Contact. Please Create First.')); 

                }
            //End MMallorca UD-1167 05/09/2015
            }//Start/End : Code Review Implementation 02/18/2015 S.Puli
    }           // END : D-1106 12/19/2014


    /*
     * Description : This method is use to insert the Publication values in a wrapper.
     * Parameters: None
     * Return : None
     */

    public void getPubSelections(){
        for(Order_Line_Item_Vendor__c oliv : orderLineItemList){
            publicationIds.add(oliv.Publication__c);
            OrWrapper orWrap = new OrWrapper();
            orWrap.publicationId = oliv.Publication__c;
            orWrap.publicationName = oliv.Publication__r.name;
            orWrap.oliId = oliv.Id;
            orWrap.mon = oliv.mon__c;
            orWrap.tue = oliv.tue__c; 
            orWrap.wed = oliv.wed__c;
            orWrap.thu = oliv.thu__c;
            orWrap.fri = oliv.fri__c;
            orWrap.sat = oliv.sat__c;
            orWrap.sun = oliv.sun__c;
            orWrap.phd = oliv.phd__c;
            orWrap.phe = oliv.phe__c;
            orWrap.isNotified = !(oliv.Suppress_Vendor_Notification__c);
            orWrap.earliestStopDate = oliv.Earliest_Start_Date__c;
            orWrap.stopReqDate = oliv.Stop_Request_Date__c;
            finalPublicationList.add(orWrap);
        }
    }
    
    /*
     * Description : This method is use to get the field of the Order object.
     * Parameters: None
     * Return : None
     */
    
    public void getOrder() {
        String orderId = ApexPages.currentPage().getParameters().get('orderId');
       
        if(orderId != null && orderId != 'null'){
            
            try {
                order = [SELECT id, name, Case_Owner__c, ownerId, owner.name, status__c, case_record_type__c, category__c, sub_category__c, Account__c, Recipient_contact__r.Accountid, 
                         Stop_request_date__c, terminating_reason__c, suppress_vendor_notification__c
                         FROM order__c
                         WHERE id =: orderId];
            } catch (exception e) {
                 order = new order__c();
            }
        }
    }
    
    /*
     * Description : This method is use to add the selected Subscription Vendor on a list.
     * Parameters: None
     * Return : None
     */

    public void addLineItem() {
        //START D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
        checkExistingCOA();
        if (!notValid) {
        if(isNew) {
            finalPublicationList = new List<OrWrapper>();
            isNew = False;
        //Start D-3041 06/01/2015 Added by Jason A. 

                pubId = new set <id>();
            }
            publicationIds.clear();
        //End D-3041 06/01/2015 Added by Jason A.   
        //Start : Code Review Implementation 02/18/2015 S.Puli
        if(pubObject.Subscription_Vendor__c<>null){
        //End : Code Review Implementation 02/18/2015 S.Puli
        publicationRecordList = [SELECT id, Name, Mon__c, Tue__c, Wed__c, Thu__c, Fri__c, Sat__c, Sun__c, PHd__c, PHe__c, 
                                 Publication__r.Earliest_Start_Date__c, Publication__c, Publication__r.name, Subscription_Vendor__c
                                 FROM Subscription_Vendor_Publication__c
                                 WHERE Subscription_Vendor__c =: pubObject.Subscription_Vendor__c];
        }//Start/End : Code Review Implementation 02/18/2015 S.Puli
                                                      
        for(Subscription_Vendor_Publication__c pub : publicationRecordList) {
            if(checkDuplicatePublication(pub.id)) {
                if(!publicationIds.contains(pub.Id)) {
                    publicationIds.add(pub.Id);
                    OrWrapper orWrap = new OrWrapper();
                    OrWrap.subVendor = pub.Subscription_Vendor__c;
                    orWrap.publicationId = pub.Publication__c;
                    orWrap.publicationName = pub.Publication__r.name;
                    orWrap.oliId = pub.Id;
                    orWrap.mon = pub.mon__c;
                    orWrap.tue = pub.tue__c; 
                    orWrap.wed = pub.wed__c;
                    orWrap.thu = pub.thu__c;
                    orWrap.fri = pub.fri__c;
                    orWrap.sat = pub.sat__c;
                    orWrap.sun = pub.sun__c;
                    orWrap.phd = pub.phd__c;
                    orWrap.phe = pub.phe__c;
                    orWrap.subVendor = pub.Subscription_Vendor__c;
                    orWrap.isNotified = !(oli.Suppress_Vendor_Notification__c);
                    orWrap.earliestStopDate = pub.Publication__r.Earliest_Start_Date__c;
                    orWrap.stopReqDate = olivf.Stop_Request_Date__c;                 
                //Start D-3041 06/01/2015 Added by Jason A. 
                        if(!pubId.contains(pub.Id)){
                            finalPublicationList.add(orWrap);
                        }                   
                        pubId.add(pub.Id);
            }
        }
            }
                //End D-3041 06/01/2015 Added by Jason A.   
        
        if (olivf.Stop_Request_Date__c <= pubObject.Publication__r.Earliest_Start_Date__C) {
            WarningIcon = '/resource/Warning_Icon'; 
        } else {
            WarningIcon = null;
        }
                
				
        }
        //END D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
    }
    //Start D-3041 06/01/2015 Added by Jason A.
    public void earliestStopDate() {
            if(pubObject.Subscription_Vendor__c<>null){
            publicationRecordList = [SELECT id, Name, Mon__c, Tue__c, Wed__c, Thu__c, Fri__c, Sat__c, Sun__c, PHd__c, PHe__c, 
                                     Publication__r.Earliest_Start_Date__c, Publication__c, Publication__r.name, Subscription_Vendor__c
                                     FROM Subscription_Vendor_Publication__c
                                     WHERE Subscription_Vendor__c =: pubObject.Subscription_Vendor__c];
            }
            List<OrWrapper> earliestStopDatePublist = new List<OrWrapper>();
            for(Subscription_Vendor_Publication__c pub : publicationRecordList) {
                if(checkDuplicatePublication(pub.id)) {
                    if(!publicationIds.contains(pub.Id)) {
                        publicationIds.add(pub.Id);
                        OrWrapper orWrap = new OrWrapper();
                        orWrap.earliestStopDate = pub.Publication__r.Earliest_Start_Date__c;                
                        earliestStopDatePublist.add(orWrap);
                    }
                }
            }
            
            if (olivf.Stop_Request_Date__c <= pubObject.Publication__r.Earliest_Start_Date__C) {
                WarningIcon = '/resource/Warning_Icon'; 
            } else {
                WarningIcon = null;
            }
                            
            try {
                pubObject.Publication__r.Earliest_Start_Date__c = getEarliestStopDate(earliestStopDatePublist);
            }
            catch(Exception e) {
            }
    }
    //End D-3041 06/01/2015 Added by Jason A.
    
    public Boolean checkDuplicatePublication(String id) {
        if(!finalPublicationList.isEmpty()) {
            for(OrWrapper pub : finalPublicationList) {
                if(pub.publicationId == id) {
                    return false;
                }
            }
        }
        return true;
    }
    
    public Boolean checkDuplicateOrderLineItem(String id) {
        if(!orderLineItemList.isEmpty()) {
            for(Order_Line_Item_Vendor__c olivList : orderLineItemList) {
                if(olivList.Publication__r.Id == id) {
                    return false;
                }
            }
        }
        return true;
    }
    
    public Date getEarliestStopDate(List<OrWrapper> publication) {
        Date earliestStopDate = publication[0].earliestStopDate;

        for(Integer counter = 0; counter < publication.size(); counter++) {
            if(earliestStopDate > publication[counter].earliestStopDate) {
                earliestStopDate = publication[counter].earliestStopDate;
            }
        }
        return earliestStopDate;
    }       
   
    public void removePub() {
        for(Integer i=0; i < finalPublicationList.size(); i++) {
            if(finalPublicationList[i].publicationId == index) {
                publicationIds.remove(finalPublicationList[i].oliId);
                finalPublicationList.remove(i);
            }
            if(orderLineItemList.size() > 0){
                if(orderLineItemList[i].Publication__r.Id == index){
                    orderLineItemList.remove(i);
                    delete orderLineItemList[i];
                }
            }
        }
        if(finalPublicationList.size() > 0) {
            pubObject.Publication__r.Earliest_Start_Date__c = getEarliestStopDate(finalPublicationList);
        } else {
            pubObject.Publication__r.Earliest_Start_Date__c = null;
        }
    }
    
    /*
     * Description : This method is use to create Order Line Item and Order.
     * Parameters: None
     * Return : None
     */

    public PageReference saveDraft() {
    
        List<Order_Line_Item_Vendor__c> orInsertList = new List<Order_Line_Item_Vendor__c>();
        List<Order_Line_Item_Vendor__c> orDeleteList = new List<Order_Line_Item_Vendor__c>();
        Boolean hasError = false;             
        Set<Id> orWrpIds = new Set<Id>();
        
        //START D-2980 05/22/2015 Added by J.Sarion/VPernicia - Check if there's an existing COA for the selected subscription
        checkExistingCOA();
        if (notValid) {
            
            return null;        
        }
        //END D-2980 05/22/2015 Added by J.Sarion/VPernicia - Check if there's an existing COA for the selected subscription
        
        for(OrWrapper orW : finalPublicationList ) {
            orWrpIds.add(orW.publicationId);            
        }

        Map<Id, List<Non_Publication_Day__c>> nonPubMap = new Map<Id, List<Non_Publication_Day__c>>();
        //Start : Code Review Implementation 02/18/2015 S.Puli
        if(orWrpIds<>null&&orWrpIds.size()>0){
        //End : Code Review Implementation 02/18/2015 S.Puli
            for(Non_Publication_Day__c npd :  [SELECT name, Non_Publication_Date__c, Publication__c, Publication__r.Name
                             FROM Non_Publication_Day__c
                             WHERE Publication__c IN :orWrpIds]) {
                if(npd.Publication__c != null) {
                    if(!nonPubMap.containsKey(npd.Publication__c)) {
                        nonPubMap.put(npd.Publication__c, new List<Non_Publication_Day__c>());
                    }
                    nonPubMap.get(npd.Publication__c).add(npd);
                }
            }
        }//Start/End : Code Review Implementation 02/18/2015 S.Puli
        for(OrWrapper orW : finalPublicationList) {
            if(nonPubMap.containsKey(orW.publicationId)) {
                for(Non_Publication_Day__c npd : nonPubMap.get(orW.publicationId)) {
                    if(orW.stopReqDate == npd.Non_Publication_Date__c) {
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, '' + ConstantsSLB.getErrorMessage('InvalidStopRequestDateNonPub'));
                        ApexPages.addMessage(msg);
                        return null;
                    }
                    if(olivf.stop_request_date__c == npd.Non_Publication_Date__c) {
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, '' + ConstantsSLB.getErrorMessage('InvalidStopRequestDateNonPub'));
                        ApexPages.addMessage(msg);
                        return null;
                    }
                }
            }
        }

        if (olivf.Stop_Request_Date__c <= System.Today()) {
        
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, '' + ConstantsSLB.getErrorMessage('InvalidStopRequestDate'));
            ApexPages.addMessage(msg);
            return null;
        } 

        /*if (olivf.Stop_Request_Date__c == nonPubObject.Non_Publication_Date__c) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, '' + ConstantsSLB.getErrorMessage('InvalidStopRequestDateNonPub'));
            ApexPages.addMessage(msg);
            return null;  
        }*/

        order.Credit_Balance__c = 0;
        order.Delivery_Charge__c = 0;
        // START : D-1106 12/19/2014 Alyana Navarro
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        // END : D-1106 12/19/2014
        order.Status__c = GlobalVariableClass.STATUS_DRAFT;
        order.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_STOP_SUBCRIPTION;

        if (olivf.Stop_Request_Date__c <= pubObject.Publication__r.Earliest_Start_Date__C) {
            WarningIcon = '/resource/Warning_Icon';
        } 
        else {
            WarningIcon = null;
        }
        //try{
            upsert order;

            list<order_line_item_vendor__c> oliv = new list<order_line_item_vendor__c>();
        
            //Start : Code Review Implementation 02/18/2015 S.Puli
            if(pubObject.Subscription_Vendor__c<>null){
            //End : Code Review Implementation 02/18/2015 S.Puli
                publicationRecordList = [SELECT id, Name, Mon__c, Tue__c, Wed__c, Thu__c, Fri__c, Sat__c, Sun__c, PHd__c, PHe__c, 
                                 Publication__r.Earliest_Start_Date__c, Publication__c, Publication__r.name, Subscription_Vendor__c
                                 FROM Subscription_Vendor_Publication__c
                                 WHERE Subscription_Vendor__c =: pubObject.Subscription_Vendor__c];
            }//Start/End : Code Review Implementation 02/18/2015 S.Puli
            for(OrWrapper ow : finalPublicationList){
                if(checkDuplicateOrderLineItem(ow.publicationId)) {
                        Order_Line_Item_Vendor__c oli = new Order_Line_Item_Vendor__c();
                        oli.Publication__c = ow.publicationId;
                        oli.mon__c = ow.mon;
                        oli.tue__c = ow.tue;
                        oli.wed__c = ow.wed;
                        oli.thu__c = ow.thu;
                        oli.fri__c = ow.fri;
                        oli.sat__c = ow.sat;
                        oli.sun__c = ow.sun;
                        oli.phd__c = ow.phd;
                        oli.phe__c = ow.phe;
                        //START D-3340 8/11/2015 Added By C. Lin - Change olivf.stop_request_date__c to ow.stopReqDate
                        oli.stop_request_date__c = ow.stopReqDate;
                        //END D-3340 8/11/2015 Added By C. Lin
                        oli.earliest_stop_date__c = ow.earliestStopDate; 
                        //START:UD-1341 5/21/2015 Added by Manolo Valena - Update urgent field of oliv record.
                        if(oli.stop_request_date__c <= oli.earliest_stop_date__c) {
                            oli.Urgent__c = true;
                        }
                        else {
                            oli.Urgent__c = false;
                        }
                        //END:UD-1341 5/21/2015 Added by Manolo Valena
                        oli.notify_vendor__c = ow.isNotified;
                        oli.suppress_vendor_notification__c = !ow.isNotified;
                        oli.Order__c = order.Id;
                        oli.Subscription_Vendor__c = ow.subVendor;
                        oli.Additional_Termination_Comment_del__c = olivf.Additional_Termination_Comment_del__c;
                        oli.Terminating_Reason__c = olivf.Terminating_Reason__c;
                        oli.Send_to_Retention__c = olivf.Send_to_Retention__c;
                        oliv.add (oli);
                }
            }
            
            insert oliv;
        
        //Start : Code Review Implementation 02/18/2015 S.Puli
        if(oliv<>null){
            //End : Code Review Implementation 02/18/2015 S.Puli
            orderLineItemList = [SELECT id, name, publication__c, Publication__r.name, mon__c, tue__c, wed__c, thu__c, fri__c, sat__c, sun__c, phd__c, phe__c, subscription_vendor__c, subscription_vendor__r.id, earliest_stop_date__c, stop_request_date__c, terminating_reason__c, notify_vendor__c, suppress_vendor_notification__c, Send_to_Retention__c
                         FROM Order_Line_Item_Vendor__c WHERE Id IN :oliv]; 

        }//Start/End : Code Review Implementation 02/18/2015 S.Puli
        //}
        /*catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));

        } */   

        //replace counter to line items mapping
        orInsertList = new List<Order_Line_Item_Vendor__c>();
        orDeleteList = new List<Order_Line_Item_Vendor__c>(); 
        
        PageReference pRef = new PageReference('/apex/StopSubOrderEntry_Vendor_View?accountId=' + order.Account__c + '&orderId=' + order.Id + '&recordtypeId=' + recordtype);
        //PageReference pRef = new PageReference(GlobalVariableClass.PAGEREFERENCE_TOVIEWVENDOR + GlobalVariableClass.PARAMETER_ACCOUNTID + '=' + order.Account__c + '&' + GlobalVariableClass.PARAMETER_ORDERID + '=' + order.Id + '&' + GlobalVariableClass.PARAMETER_RECORDTYPEID + '=' + recordtype);
        pRef.setRedirect(true);
        return pRef;
        
       
    }
    
    /*
     * Description : This method is use to cancel the drafted Order.
     * Parameters: None
     * Return : None
     */
    
    public PageReference cancel() {

        /*string retUrl = '/' + accountId;

        if (order.Status__c == 'New') {
            delete order;
            retUrl = '/001/o';
        } else if (order.Status__c == 'Draft') {
            retUrl = '/apex/StopSubOrderEntry_Vendor_View?accountId=' +accountId+ '&orderId=' + order.Id;
        }

        PageReference pageRef = new PageReference(retUrl);
        pageRef.setRedirect(true);
        return pageRef;*/
        

        PageReference pageRef;
        
        if (Order.Name == null) {
            //delete order;
            pageRef = new PageReference('/' + accountId);
        } else if (Order.Name != null) {
            pageRef = new PageReference('/apex/StopSubOrderEntry_Vendor_View?accountId=' +accountId+ '&orderId=' + order.Id);
            //pageRef = new PageReference(GlobalVariableClass.PAGEREFERENCE_TOVIEWVENDOR + GlobalVariableClass.PARAMETER_ACCOUNTID + '=' +accountId+ '&' + GlobalVariableClass.PARAMETER_ORDERID + '=' + order.Id);
        }
        
        return pageRef;
    }

    /*
     * Description : This method is use to create Order, Order Line Item and Case.
     * Parameters: None
     * Return : None
     */

    public PageReference submit() {
        Set<Id> subId = new Set<Id>();

        for(Order_Line_Item_Vendor__c oLineVendwrap : orderLineItemList ) {
            subId.add(oLineVendwrap.subscription_vendor__c);
        }

        //Start : Code Review Implementation 02/18/2015 S.Puli
        List<Subscription_Vendor__c> subVendList;
        if(subId<>null){
        //end : Code Review Implementation 02/18/2015 S.Puli
        subVendList = [SELECT id, name, status__c FROM Subscription_Vendor__c WHERE id IN : subId and Status__c != 'Cancelled'];
        }//Start/End : Code Review Implementation 02/18/2015 S.Puli
        //save order line items

        //call method to create case
       
        CreateCase cCase = new CreateCase();
        order.Status__c = GlobalVariableClass.STATUS_PENDING;        
        
        objCase = cCase.createCaseForStopSubscription(new List<Order__c>{order}, false)[0];
        for(Order_Line_Item_Vendor__c o : orderLineItemList){
            if((objCase.Earliest_Stop_Date__c == null || objCase.Earliest_Stop_Date__c > o.earliest_stop_date__c) && o.earliest_stop_date__c != null){
                objCase.Earliest_Stop_Date__c = o.earliest_stop_date__c;
                objCase.Stop_Request_Date__c = o.stop_request_date__c;
                objCase.Additional_Termination_Comments__c = o.Additional_Termination_Comment_del__c;
                objCase.Termination_Reason__c = o.Terminating_Reason__c;
            }
            objCase.Send_to_Retention__c = o.Send_to_Retention__c;
        }                               
        
        // START : D-1322 12/22/2014 Alyana Navarro - Check if order is urgent and change Case sub status if order is urgent.
        //START: D-4087 12/15/15 Added by Manolo Valena - Urgent Stop should be greater than or equal to.
        if(objCase.Earliest_Stop_Date__c >= objCase.Stop_Request_Date__c){
        //END: D-4087 12/15/15 Added by Manolo Valena
            order.Urgent_Stop__c = true;            
        }                
        
        // START : D-2192 2/11/2015 Alyana Navarro  
        objCase.Urgent_Request__c = order.Urgent_Stop__c;       
        if(objCase.Urgent_Request__c){
            objCase.Status = 'Pending';
            objCase.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_URGENT_STOP;            
        } else {
            for(Subscription_Vendor__c sub : subVendList) {
                //sub.status__c = 'Cancelled';
                sub.status__c = GlobalVariableClass.STATUS_CANCELLED;
            }                        
            //START D-2940 5/15/15 Added by Manolo Valena - Added new condition to update order status to closed if case status is closed and sub status is stop subscription completed.
            if(objCase.Status == GlobalVariableClass.STATUS_CLOSED && objCase.Sub_Status__c == GlobalVariableClass.SUB_STATUS_STOP_COMPLETED) {
                order.Status__c = GlobalVariableClass.STATUS_CLOSE; // START- END UD-3761 K. Tan 1/28/2015 Shall refer to STATUS_CLOSE instead 
            }
            //END D-2940 5/15/15 Added by Manolo Valena
        }
        //START UD-3293 11/25/15 RReyes
        if(parentCaseId != null){
            objCase.ParentId = parentCaseId;
        }
        //END UD-3293 11/25/15 RReyes
        
        update subVendList;
                
        // END : D-2192 2/11/2015
        // END : D-1322 12/22/2014
        
        upsert objCase;
        update order;
        
        PageReference pRef = new PageReference('/' + objCase.Id);
        return pRef;  
    }

    /*
     * Description : This method is use to edit the Order created.
     * Parameters: None
     * Return : None
     */

    public PageReference edit() {
        PageReference pRef = Page.StopSubOrderEntry_Vendor_Edit;
        pRef.getParameters().put('accId', order.Account__c);
        pRef.getParameters().put('id', order.Id);
        return pRef;
    }

    /*
     * Description : This method is use to update the order status to void.
     * Parameters: None
     * Return : None
     */
    // Start UD-2205 VPernicia 08/04/15
    public PageReference voidStatus() {
         
        PageReference pageRef;
    
        //order.Status__c = 'Void';
        if (order != null){
            order.Status__c = GlobalVariableClass.STATUS_VOID;
            update order;
            
            pageRef = new PageReference('/' + accountId);
            
            return pageRef;
        } else {
            return null;
        }
    }
    // End UD-2205 VPernicia 08/04/15
    
    //START D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
    public void checkExistingCOA () {
        Case_Vendor_Subscription__c latestCaseSub;
        notValid = false;
        if (pubObject.Subscription_Vendor__c != null && olivf.Stop_Request_Date__c != null) {
            if (subIdToCOACaseSubMap.containsKey(pubObject.Subscription_Vendor__c)) {
                latestCaseSub = subIdToCOACaseSubMap.get(pubObject.Subscription_Vendor__c);
                if (latestCaseSub.Case__r.Effective_Date__c >= olivf.Stop_Request_Date__c) {
                    String errorMessage = 'There is an existing case ' + latestCaseSub.Case__r.CaseNumber + ' of type ' + latestCaseSub.Case__r.RecordType.Name + ' where Effective Date is ' +latestCaseSub.Case__r.Effective_Date__c + '. Please set Stop request after the said date.';

                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
                    ApexPages.addMessage(myMsg);
                    
                    notValid = true;
                }
            }
        }
    }
    //END D-2980 05/22/2015 Added by J.Sarion - Check if there's an existing COA for the selected subscription
}