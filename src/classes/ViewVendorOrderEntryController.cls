/**
 * Class Name: ViewVendorOrderEntryController
 * @author 
 * Date: 2014.07.31
 * Requirement: Start Subscription Order Entry
 * @description This class is use as an apex controller of ViewVendorOrderEntry VF page.
 *
 */


/*
* ------Revision------
* Version 1.0: Pilot Release
* By: <Glenn Garcia>
* Description:s
*/

public class ViewVendorOrderEntryController {

    
public Order__c order {get; set;}
public List<Order_Line_Item_Vendor__c> orders { get; set; }
public Publication__c pub {get; set; }
public Order_Line_Item_Vendor__c oli {get; set;}
public Integer counter {get; set;}
public String index {get; set;}
public List<OrWrapper> OrWrapperList {get;set;}
public Case objcase {get;set;}

    public ViewVendorOrderEntryController() {
        //string orderId = ApexPages.currentPage().getParameters().get('id');
        //system.assertequals(orderId, null);
        String orderId = ApexPages.currentPage().getParameters().get('id');               
        orders = new List<Order_Line_Item_Vendor__c>();
        Order_Line_Item_Vendor__c lineItem = new Order_Line_Item_Vendor__c();
        orders.add(lineItem);
        counter=0;
        
        //validation if the fields are not NULL
        OrWrapperList = new List<OrWrapper>();       
        if(orderId == NULL || orderId == '') {
        OrWrapper OrWrap = new OrWrapper(new Order_Line_Item_Vendor__c( Mon__c = 0, Tue__c = 0,Wed__c = 0,Thu__c = 0, 
                                         Fri__c = 0, Sat__c = 0, Sun__c = 0, PHe__c = 0, PHd__c = 0  
        ));
        counter++;
        OrWrap.counterWrap = counter; 
        OrWrapperList.add(OrWrap);
        order = new Order__c();       
        }

        else {           
             order = [SELECT Id, Account__c, Recipient_Contact__c, Reason__c,  Remarks__c, Vendor_Sms_Remarks__c, Informed_Customer__c  
                     FROM Order__c 
                     WHERE Id = :orderId];
                     
              LIST<Order_Line_Item_Vendor__c> vLineItems = [SELECT Id, Mon__c, Tue__c, Wed__c, Thu__c, Fri__c, Sat__c, Sun__c,
                     PHe__c, PHd__c, Start_Date__c, Notify_Vendor__c, Stop_Date__c, Publication__c
                     FROM Order_Line_Item_Vendor__c
                     WHERE Order__c = :orderId];                    
             for(Order_Line_Item_Vendor__c vli : vLineItems) {
                OrWrapper OrWrap = new OrWrapper(vli);
                counter++;
                OrWrap.counterWrap = counter; 
                OrWrapperList.add(OrWrap);
             }
    }
 }
     
     public class OrWrapper{
        public Order_Line_Item_Vendor__c oLine {get;set;}
        public Integer counterWrap {get;set;}
        
        public OrWrapper(Order_Line_Item_Vendor__c ol){
            this.oLine = ol;         
        }
    }

    public void initializeData() {
            oli = new Order_Line_Item_Vendor__c();
            }
            
    
    
    public void addOrder() {
        OrWrapper OrWrap = new OrWrapper(new Order_Line_Item_Vendor__c(
            Mon__c = 0,
            Tue__c = 0,
            Wed__c = 0,
            Thu__c = 0,
            Fri__c = 0,
            Sat__c = 0,
            Sun__c = 0,
            PHe__c = 0,
            PHd__c = 0            
        ));
        counter++;
        OrWrap.counterWrap = counter; 
        OrWrapperList.add(OrWrap);
   }

   
    public void removePub(){
        Integer param = Integer.valueOf(index);
        
        for(Integer i=0; i<OrWrapperList.size(); i++){
            if(OrWrapperList[i].counterWrap == param){
                OrWrapperList.remove(i);  
            }
        }
        
        counter--;      
    }
              
        
    public List<SelectOption> getItems() {
        
        List<SelectOption> options = new List<SelectOption>();
        list<Id> lPubID = new list<id>();
        list<string> lPubName = new list<string>();
        
        
        
        for (Publication__c pub : [select Id, Name, Product_Family__c from Publication__c]) 
        {     
             lPubID.add(pub.Id);
             lPubName.add(pub.Name);
             options.add(new SelectOption(pub.Id, pub.Name));
        }  
     
        return options;
        
        
    }

    public PageReference saveDraft() {                 
                order.Billing_Account__c = 'a0MN00000015tBeMAI';
                //order.Total_Full_Prepaid_Charge__c = 1;
                //order.Total_Monthly_Recurring_Charge__c = 1;
                order.Credit_Balance__c = 1;
                //order.Postage_Charge__c = 1;
                order.Delivery_Charge__c = 1;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 1;
                insert order;
                                
                // list that holds the Order_Line_Item_Vendor__c records
                // to be inserted
                List<Order_Line_Item_Vendor__c> OrList = new List<Order_Line_Item_Vendor__c>();
                for (OrWrapper ow : OrWrapperList)
                 {
                     Order_Line_Item_Vendor__c OrLi = ow.oLine;
                     OrLi.Order__c = order.Id;                 
                     OrList.add(OrLi);                
                 }
                insert OrList;               

                PageReference page = new Pagereference('/'+order.Id);
            page.setRedirect(true);
            return page;
                 }   
                 
        public pageReference cancelAction(){
    return returnToOrigination();
  }
        
        public PageReference cancel() {
        PageReference pageRef = new PageReference('/');
        pageRef.setRedirect(true);
        return pageRef;
    }        
        
        public PageReference submit() {  
                order.Billing_Account__c = 'a0MN00000015tBeMAI';
                //order.Total_Full_Prepaid_Charge__c = 1;
                //order.Total_Monthly_Recurring_Charge__c = 1;
                order.Credit_Balance__c = 1;
                //order.Postage_Charge__c = 1;
                order.Delivery_Charge__c = 1;
                order.Monthly_Delivery_Charge_for_Full_Payment__c = 1;
                upsert order;
                                
                // list that holds the Order_Line_Item_Vendor__c records
                // to be inserted
                List<Order_Line_Item_Vendor__c> OrList = new List<Order_Line_Item_Vendor__c>();
                for (OrWrapper ow : OrWrapperList)
                 {
                     Order_Line_Item_Vendor__c OrLi = ow.oLine;
                     OrLi.Order__c = order.Id;                 
                     OrList.add(OrLi);                
                 }
                upsert OrList;               
          
                // create related publications based on order line item vendor records
                List<Subscription_Vendor_Publication__c> svList = new List<Subscription_Vendor_Publication__c>();
                //List<Subscription_Vendor__c> sv2List = new List<Subscription_Vendor__c>();                
                       for (Order_Line_Item_Vendor__c oliv : [SELECT Mon__c, Tue__c, Wed__c, Thu__c, Fri__c, Sat__c, Sun__c, 
                                                                     PHd__c, PHe__c, Publication__c, Order__c, Subscription_Vendor__c,
                                                                     Start_Date__c, Stop_Date__c
                                                              FROM Order_Line_Item_Vendor__c where Order__c = :order.Id]) {
                // create vendor subscription
                Subscription_Vendor__c sv = new Subscription_Vendor__c();
                sv.Order_Number__c = order.Id;
                sv.Account__c = order.Account__c;
                sv.Reason__c = order.Reason__c;
                sv.Recipient__c = order.Recipient_Contact__c;
                sv.Subscription_Start_Date__c = oliv.Start_Date__c;
                sv.Subscription_Stop_Date__c = oliv.Stop_Date__c;
                insert sv;                                     

                         Subscription_Vendor_Publication__c svp = new Subscription_Vendor_Publication__c();
                         svp.Subscription_Vendor__c = sv.Id;
                         svp.Publication__c = oliv.Publication__c;
                         svp.Order__c = oliv.Order__c;
                         svp.Mon__c = oliv.Mon__c;
                         svp.Tue__c = oliv.Tue__c;
                         svp.Wed__c = oliv.Wed__c;
                         svp.Thu__c = oliv.Thu__c;
                         svp.Fri__c = oliv.Fri__c;
                         svp.Sat__c = oliv.Sat__c;
                         svp.Sun__c = oliv.Sun__c;
                         svp.PHd__c = oliv.PHd__c;
                         svp.PHe__c = oliv.PHe__c;
                         svList.add(svp);
                }
                
                insert svList;
                //insert sv2List;
                
                PageReference page = new Pagereference('/');
            page.setRedirect(true);
            return page;
                 }            
        

        public PageReference edit() {
        string pId = ApexPages.currentPage().getParameters().get('id');
        PageReference page = new PageReference ('/apex/CreateVendorOrderEntry?id='+pId);
        page.setRedirect(true);
         return page;

        return null;
    }
        private pageReference returnToOrigination(){
        PageReference page = new PageReference('/' + order.Id);
        page.setRedirect(true);
        return page;
  }

}