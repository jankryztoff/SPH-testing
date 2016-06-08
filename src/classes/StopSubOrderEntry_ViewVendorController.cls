/**
 * Class Name: StopSubOrderEntry_VendorController
 * @author 
 * Date: 2014.09.09
 * Requirement: Stop Subscription Order Entry
 * @description This class is use as an apex controller of StopSubOrderEntry_Vendor_View VF page.
 *
 */


/*
 * ------Revision------
 * Version 1.0: Pilot Release
 * By: <Kim Saclag>
 * Description:
 */

public class StopSubOrderEntry_ViewVendorController{
    
    public Order__c order {get; set;}
    public Subscription_Vendor__c SubVen {get; set;}
    public Order_Line_Item_Vendor__c oli {get; set;}
    public Integer counter {get; set;}
    public String index {get; set;}
    public Case objcase {get;set;}
    public List<SelectOption> items {get; set;}
    public Date SubStartDate {get;set;}
    public Subscription_Vendor_Publication__c pubObject {get; set;}
    public List<Subscription_Vendor_Publication__c> publicationRecordList {get; set;}
    public List<Order_Line_Item_Vendor__c> orderLineItemList {get; set;}
    public List<Subscription_Vendor_Publication__c> finalPublicationList {get; set;}
    Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Stop Subscription').getRecordTypeId();
    public Account account {get; set;} 
    //Id accountId;
    Id recordType;

    public StopSubOrderEntry_ViewVendorController() {
        getOrder();
        getAccount();      
    }
    
    public void getAccount(){
        String accountId = ApexPages.currentPage().getParameters().get('accountId');      
        account = [SELECT name, id FROM Account WHERE id = :accountId];
        
    }
    
    public void getOrder(){
        String orderId = ApexPages.currentPage().getParameters().get('orderId');    
        if(orderId != null){    
            order = [SELECT id, name, ownerId, status__c, case_record_type__c, category__c, sub_category__c, Account__c, Recipient_contact__c 
                     FROM Order__c 
                     WHERE id =: orderId];
                     
            order.status__c = 'Draft';         
        }
    }                       

    public Order_Line_Item_Vendor__c createOrderLine(Subscription_Vendor_Publication__c publication){
 
        Order_Line_Item_Vendor__c oLIRecord = new Order_Line_Item_Vendor__c();
        oLIRecord.Publication__c = oLIRecord.Publication__c;
        oLIRecord.Mon__c = publication.Mon__c;
        oLIRecord.Tue__c = publication.Tue__c;
        oLIRecord.Wed__c = publication.Wed__c;
        oLIRecord.Thu__c = publication.Thu__c;
        oLIRecord.Fri__c = publication.Fri__c;
        oLIRecord.Sat__c = publication.Sat__c; 
        oLIRecord.Sun__c = publication.Sun__c; 
        oLIRecord.PHd__c = publication.PHd__c;
        oLIRecord.PHe__c = publication.PHe__c; 
        oLIRecord.Earliest_Stop_Date__c = publication.Publication__r.Earliest_Start_Date__c;
        oLIRecord.Stop_Request_Date__c = order.Stop_Request_Date__c;
        oLIRecord.Subscription_Vendor__c = publication.Subscription_Vendor__c; 
        oLIRecord.Suppress_Vendor_Notification__c = order.Suppress_Vendor_Notification__c;
        oLIRecord.Additional_Termination_Comment_del__c = oli.Additional_Termination_Comment_del__c;
        oLIRecord.Terminating_Reason__c = order.Terminating_Reason__c;
        oLIRecord.order__c = order.id;
        oLIRecord.Start_Date__c = System.Today();

        return oLIRecord;
    }
    
                 
    public PageReference cancel(){
        PageReference pgRef;
        try {                       
            string retUrl = '/' + account.id;
            pgRef = new PageReference(retUrl);
            pgRef.setRedirect(true);
            return pgRef;
        } catch (exception e) {
            ApexPages.addMessages(e);
            return null;
        }        
    }  
     
    public PageReference submit() {  
        //save order line items
        //saveDraft();
        
        try {
            
            //call method to create case
            CreateCase cCase = new CreateCase(); 
            order.Order_Status__c = 'Pending';
            objCase = cCase.createCaseforStopSubscription(new List<Order__c>{order}, false)[0];

        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()  + '; stacktrace: ' + e.getStackTraceString()));
            return null;
        }
        if (oli.Stop_Request_Date__c <= pubObject.Publication__r.Earliest_Start_Date__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Stop Request Date must be after Earliest Stop Date.'));
            return null;
        }
        PageReference pRef = new PageReference('/' + objCase.Id);
        return pRef;
    }

    public PageReference edit(){
        try {                       
            String retUrl = '/apex/StopSubOrderEntry_Vendor_Edit?orderId=' + order.Id + '&accountId=' + account.id;
            
            PageReference pgRef = new PageReference(retUrl);
            pgRef.setRedirect(true);
            
            return pgRef;
            
        } catch (exception e) {
            ApexPages.addMessages(e);
            return null;
        }
    }
    
    public void voidStatus(){
        order.Status__c = 'Void';
        //caseRec.Status ='Void';
        update order;
        //update caseRec;
    }


}