public class AssignVendorController {

    public List<Vendor_Allocation__c> vendAllocList     {get; set;}
    public List<Order_Line_Item__c> recPostalCodeList   {get; set;}
    public List<vaWrapper> vaWrapperList                {get; set;}
    public Integer counter                              {get; set;}
    public string selectedRadioButton                   {get; set;}
    String oliId;

    public AssignVendorController () {
        //START Code Review 2/17/2015 J.Sarion - Null in where clause causes Full Table scans
        vendAllocList = new List<Vendor_Allocation__c>();
        //END Code Review 2/17/2015 J.Sarion
        oliId = ApexPages.currentPage().getParameters().get('id');
        Set<String> recPostalCodeValues = new Set<String>();
        counter=0;
        vaWrapperList = new List<vaWrapper>();
        recPostalCodeList = [SELECT Id, Name,Recipient_Postal_Code__c, Vendor_Mailing_Agent__c
                                 FROM Order_Line_Item__c
                                 WHERE Id = :oliId];
            
        //START Code Review 2/17/2015 J.Sarion - Null in where clause causes Full Table scans
        for(Order_Line_Item__c oliRec: recPostalCodeList) {  
            if (oliRec.Recipient_Postal_Code__c != null) {
                recPostalCodeValues.add(oliRec.Recipient_Postal_Code__c);  
            }
        }
        System.debug('Postal Code' + recPostalCodeValues.size());
        
        if (!recPostalCodeValues.isEmpty()) {
            vendAllocList = [SELECT Id, Name, Vendor_Account__r.Name, Vendor_Account__r.RecordTypeId, 
                                                               Vendor_Account__r.Telephone_Office__c, Vendor_Account__r.Handphone_Number__c
                              FROM Vendor_Allocation__c
                              WHERE SingPost_Address__r.Name IN :recPostalCodeValues
                              AND Vendor_Account__r.RecordTypeId = :ConstantsSLB.getKeyId('Account_Vendor')];
        }
        //END Code Review 2/17/2015 J.Sarion
        
                for(Vendor_Allocation__c vAlloc : vendAllocList) {
                        vaWrapper vaWrap = new vaWrapper(vAlloc);
                        counter++;
                        vaWrap.counterWrap = counter; 
                        vaWrapperList.add(vaWrap);
                        
                        system.debug('WRAPPER VALUES: ' + vaWrapperList);
            }
            
    }

    public class vaWrapper {
    
        public Vendor_Allocation__c vendAlloc {get;set;}
        public Integer counterWrap {get;set;}
    
        public vaWrapper(Vendor_Allocation__c val){
            this.vendAlloc = val;         
        }
    }  
        
    public PageReference cancel() {
        return null;
    }

    public PageReference save () {
        
        ID OrderID;
        ID CaseID;
        boolean bUpdateSub;    
        list<Zuora__Subscription__c> lSub = new list<Zuora__Subscription__c>();
        
        Order_Line_Item__c oli = [SELECT Id, Vendor_Mailing_Agent__c, Order__c, Case__c FROM Order_Line_Item__c WHERE Id = :oliId];
        oli.Vendor_Mailing_Agent__c = selectedRadioButton;
        update oli;
        
        //START Code Review 2/17/2015 J.Sarion - Null in where clause causes Full Table scans
        if (oli.Order__c != null) {
            OrderID = oli.Order__c;
        }
        if (oli.Case__c != null) {
            CaseID = oli.Case__c;
        }
        //END Code Review 2/17/2015 J.Sarion
        
        bUpdateSub = false;
        
        // Update Subscription
        for (Zuora__Subscription__c sub :[SELECT Id, Vendor__c, Vendor_1__c FROM Zuora__Subscription__c WHERE Order_Line_Item_Number_1__c =:oliId]){ //START/END D-2302 02/24/15 Kevin Evasco: Replaced Order_Line_Item_Number__c  with Order_Line_Item_Number_1__c
            bUpdateSub = true;
            sub.Vendor_1__c = selectedRadioButton;
            sub.Vendor__c = selectedRadioButton;
            lSub.add(sub);
        }
        
        if(lSub.size()>0 && bUpdateSub){
            update lSub;
        }
        
        // Close Case and Order
        Boolean bClose;
        bClose = true;
        list<Order_Line_Item__c> lOLI = new list<Order_Line_Item__c>();
        
        //START Code Review 2/17/2015 J.Sarion - Null in where clause causes Full Table scans
        if (OrderID != null) {
            for(Order_Line_Item__c oliv: [SELECT Id, Vendor_Mailing_Agent__c FROM Order_Line_Item__c WHERE Order__c = :OrderID]){
                if (oliv.Vendor_Mailing_Agent__c == null){
                    bClose = false;
                }
            }
        }
        
        if(bClose){
            List<Case> cList = new List<Case>();
            List<Order__c> oList = new List<Order__c>();
            
            if (CaseID != null) {
                cList = [SELECT Id, Status, Sub_Status__c FROM Case WHERE Id = :CaseID];
            }
            
            List<Case> cToUpdate = new List<Case>();
            
            if(!cList.isEmpty()){
                for(Case cRec :  cList){
                    cRec.Status ='Closed';
                    cRec.Sub_Status__c = 'Subscription Created';
                    cToUpdate.add(cRec);
                }
                update cToUpdate;
            }
            
            if (OrderID != null) {
                oList = [Select Id, Status__c from Order__c where Id = :OrderID];
            }
            //END Code Review 2/17/2015 J.Sarion
            
            List<Order__c> oToUpdate = new List<Order__c>();
            
            if(!oList.isEmpty()){
                for(Order__c oRec :  oList){
                    oRec.Status__c = 'Close';
                    oToUpdate.add(oRec);
                }
                update oToUpdate;
            }
        }
        
        
        
        //return null
        PageReference ReturnPage = new PageReference('/' + oli.Id); 
        ReturnPage.setRedirect(true); 
        return ReturnPage; 
    }
}




// This code is working as expected. Code is not optimize.