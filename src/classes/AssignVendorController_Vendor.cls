public class AssignVendorController_Vendor {

    public List<Vendor_Allocation__c> vendAllocList             {get; set;}
    public List<Order_Line_Item_Vendor__c> recPostalCodeList    {get; set;}
    public List<vaWrapper> vaWrapperList                {get; set;}
    public Integer counter                              {get; set;}
    public string selectedRadioButton                   {get; set;}
    String oliId;
    public Order_Line_Item_Vendor__c ParentRecord = new Order_Line_Item_Vendor__c();

    public AssignVendorController_Vendor () {
        
        oliId = ApexPages.currentPage().getParameters().get('id');
	
		ParentRecord = [SELECT Id, Vendor__c, Subscription_Vendor__r.Id, Case__c, Order__c FROM Order_Line_Item_Vendor__c WHERE Id = :oliId];
		
		Set<String> recPostalCodeValues = new Set<String>();
		counter=0;
		vaWrapperList = new List<vaWrapper>();

		recPostalCodeList = [SELECT Id, Name,Recipient_Postal_Code__c, Vendor__c
							FROM Order_Line_Item_Vendor__c
							WHERE Id = :oliId];		
		for(Order_Line_Item_Vendor__c oliRec: recPostalCodeList) {           
			recPostalCodeValues.add(oliRec.Recipient_Postal_Code__c);    
		}
		System.debug('Postal Code' + recPostalCodeValues.size());
		//START JSUAREZ 2/18/2015 code review: check recPostalCodeValues if null
		if(recPostalCodeValues.size()>0){
		//END JSUAREZ 2/18/2015 code review: check recPostalCodeValues if null
			vendAllocList = [SELECT Id, Name, Vendor_Account__r.Name, Vendor_Account__r.RecordTypeId, 
     						Vendor_Account__r.Telephone_Office__c, Vendor_Account__r.Handphone_Number__c
					 		FROM Vendor_Allocation__c
							WHERE SingPost_Address__r.Name IN :recPostalCodeValues 
							AND Vendor_Account__r.RecordTypeId = :ConstantsSLB.getKeyId('Account_Vendor')];
		}
		//START JSUAREZ 2/18/2015 code review: check vendAllocList if null
		if(vendAllocList.size()>0){
		//END JSUAREZ 2/18/2015 code review: check vendAllocList if null
			for(Vendor_Allocation__c vAlloc : vendAllocList) {
				   vaWrapper vaWrap = new vaWrapper(vAlloc);
				   counter++;
				   vaWrap.counterWrap = counter; 
				   vaWrapperList.add(vaWrap);
							
				   system.debug('WRAPPER VALUES: ' + vaWrapperList);
			
			}	
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
    
    public PageReference selectedVendorAllocation(){
            
            selectedRadioButton = ApexPages.currentPage().getParameters().get('conid');
        
        return null;
    }

    public PageReference save () {
        

        ID OrderID;
        ID CaseID;
        
        //================================================
        // Fix D-0971
        // Populate vendor__c with the selected vendor by User
        //================================================
        
        //Update Order Line Items
		
		List<Order_Line_Item_Vendor__c> oli = new List<Order_Line_Item_Vendor__c>([SELECT Id, Vendor__c, Subscription_Vendor__r.Id, Case__c, Order__c FROM Order_Line_Item_Vendor__c WHERE Id = :oliId]);
		
		if(!oli.isEmpty()){
		oli[0].Vendor__c = selectedRadioButton;
			try{
			update oli;
			}catch(exception e){
				System.debug(e.getMessage());
			}
		}
		
        OrderID = ParentRecord.Order__c;
        CaseID = ParentRecord.Case__c;
        
        //================================================
        // Fix D-0971
        // Store Subscription_Vendor__c in a list to prevent error when 
        // Subscription_Vendor__c field is not populated in Order Line Item Vendor
        //================================================
        // Update Subscription
		
		List<Subscription_Vendor__c> subV =  new List<Subscription_Vendor__c> ([SELECT Id, Vendor__c FROM 
																					Subscription_Vendor__c WHERE Id =:ParentRecord.Subscription_Vendor__r.Id]);
		if(!subV.isEmpty()){
			subV[0].Vendor__c = selectedRadioButton;
			try{
			  update subV;
			} catch(exception e){
			   System.debug(e.getMessage());
			}
		}
        
        // Close Case and Order
        Boolean bClose;
        bClose = true;
		list<Order_Line_Item_Vendor__c> lOLI = new list<Order_Line_Item_Vendor__c>();
		for(Order_Line_Item_Vendor__c oliv: [SELECT Id, Vendor__c FROM Order_Line_Item_Vendor__c WHERE Order__c = :OrderID]){
			if (oliv.Vendor__c == null){
				bClose = false;
			}
		}
		
        if(bClose){
            Case c = [SELECT Id, Status, Sub_Status__c FROM Case WHERE Id = :CaseID];
            if(c != null){
                c.Status ='Closed';
                c.Sub_Status__c = 'Subscription Created';
                Update c;
            }
            
            Order__c  o = [Select Id, Status__c from Order__c where Id = :OrderID];
            if(o != null){
                o.Status__c = 'Close';
                Update o;
            }
        }
             
                       
        //return null
        PageReference ReturnPage = new PageReference('/' + ParentRecord.Id);
        ReturnPage.setRedirect(true); 
        return ReturnPage; 
    }
}