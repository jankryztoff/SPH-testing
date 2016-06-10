/**
 * History: D-1839 Wenjun 04/02/15: Remove irrelevant logic - Aadjustment Case Category cannot be "Collection/Payment"
 */
public with sharing class AdjustmentExtensionEdit {

    public Case adjustment {get; set;}
    public Account account {get; set;}
    public String ownerName{get;set;} 
    Id rectype;
    Id accountId;
    Id billingaccountId;
    Boolean saveAndNew = false;
    PageReference pageRef;
    //START: D-1016 12/4/2014 Added By C. Lin - For Contact Name field's filter criteria. Select Contacts under current Account
    Id existingCaseId;
    //END: D-1016 12/4/2014 Added By C. Lin
    Id parentCaseId; //START/END UD-3293 RReyes - 11/25/15
    
    public AdjustmentExtensionEdit(ApexPages.StandardController controller) {
        //For Case StandardController - ownerName
        ownerName=UserInfo.getname();
        this.adjustment = (Case) controller.getRecord();
        rectype = (Id) ApexPages.currentPage().getParameters().get('RecordType');
        accountId = (Id) ApexPages.currentPage().getParameters().get('accountId');
        billingaccountId = (Id) ApexPages.currentPage().getParameters().get('billingaccountId');
        
        //START: D-1016 12/4/2014 Added By C. Lin - For Contact Name field's filter criteria. Select Contacts under current Account
        existingCaseId = (Id) ApexPages.currentPage().getParameters().get('id');
        if(existingCaseId == null){
            adjustment.Account__c = accountId;
            adjustment.AccountId = accountId;
        }
        //END: D-1016 12/4/2014 Added By C. Lin
        //START UD-3293 11/25/15 RReyes
        parentCaseId = (Id) ApexPages.currentPage().getParameters().get('def_parent_id');
        if(parentCaseId != null){
            adjustment.ParentId = parentCaseId;
            
            Case pCase = [SELECT Id, Subject, Description FROM Case WHERE Id = :parentCaseId LIMIT 1];
                
            adjustment.Subject = pCase.Subject;
            adjustment.Description = pCase.Description;
        }
        //END UD-3293 11/25/15 RReyes
        if(billingaccountId != null){
            Zuora__CustomerAccount__c zca = [Select id, Zuora__Account__c, Name From Zuora__CustomerAccount__c where id =: billingaccountId LIMIT 1];
            adjustment.Billing_Account_Name__c = zca.id;            
            adjustment.Account__c = zca.Zuora__Account__c;
            //START: D-1016 12/4/2014 Added By C. Lin - For Contact Name field's filter criteria. Select Contacts under current Account
            adjustment.AccountId = zca.Zuora__Account__c;
            //END: D-1016 12/4/2014 Added By C. Lin
        }
        
        if(rectype != null) {
            adjustment.RecordTypeId = recType;
        }
    }
    
    public PageReference submitAndNew(){
        saveAndNew = true;
        return processAdjustment();
    }
    //START UD- 1851 8/31/2015 to route cancelled cases to account page
    public PageReference cancel(){
        
      pageRef = new PageReference('/' + adjustment.AccountId);
      pageRef.setRedirect(true);
      return  pageRef;
    }
    //END UD- 1851 8/31/2015 to route cancelled cases to account page
    
    public PageReference submitAdjustment(){
        return processAdjustment();
    }
    
    public PageReference processAdjustment() 
    {
    	// Start PD-0353 31May16 JohnD
        boolean isSubscriptionRelatedToInvoice = false;
        boolean isInvoiceLineItemAvailable = false;
    	// End PD-0353 31May16 JohnD

        //Validation : Adjustment Amount must be PositivesubmitAdjustment
		
        if(adjustment.Adjustment_Amount__c <= 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.ERR_ADJ_AMT_POSITIVE));
            return null;            
        }
        
        //START UD-1825 07/15/2015 Added by J.Sarion - Check Balance if negative or zero balance
        Zuora__ZInvoice__c zInvoice = new Zuora__ZInvoice__c();
        
        if(adjustment.Invoice__c != null){
		
			//START 06 August 2015 UD-2122 Kevin Evasco - Reject adjustment case if Adjustment Amount is greater than the Invoice Amount.
            zInvoice = [SELECT Id, Zuora__Zuora_Id__c, Zuora__InvoiceDate__c, Zuora__TotalAmount__c 
            		FROM Zuora__ZInvoice__c WHERE Id = :adjustment.Invoice__c];	// Start/End PD-0353 31May16 JohnD - added Zuora__Zuora_Id__c
			
			// Start PD-0353 31May16 JohnD - validate subscription against invoice
			for (Invoice_Line_Item__c ili : [select Subscription__c from Invoice_Line_Item__c where Invoice_ID__c = :zInvoice.Zuora__Zuora_Id__c]) {
				
				isInvoiceLineItemAvailable = true;
				if (ili.Subscription__c == adjustment.Subscription_Name__c) {
					isSubscriptionRelatedToInvoice = true;
					break;
				}
			}
			
			if (!isInvoiceLineItemAvailable) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.REQUIRED_ILI));
                return null;
			}
			
			if (!isSubscriptionRelatedToInvoice) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.ERR_INVOICE_SUB_NOT_MATCHED));
                return null;
			}
			// End PD-0353 31May16 JohnD - validate subscription against invoice
            /* 
            if(zInvoice.Zuora__Balance2__c <= 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Selected Invoice has zero or negative balance.'));
                return null;
            }
            */
            if(adjustment.Adjustment_Amount__c > zInvoice.Zuora__TotalAmount__c ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.INVALID_ADJ_AMT));	// Start/End PD-0353 31May16 JohnD - replaced hard coded string
                return null;
            }            
			//END 06 August 2015 UD-2122 Kevin Evasco - Reject adjustment case if Adjustment Amount is greater than the Invoice Amount.
			
            if(Date.Today() < zInvoice.Zuora__InvoiceDate__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.INVALID_ADJ_DATE));	// Start/End PD-0353 31May16 JohnD - replaced hard coded string
                return null;
            }
        }
        //END UD-1825 07/15/2015 Added by J.Sarion - Check Balance if negative or zero balance
        
        //START UD-1825 07/14/2015 Added by J.Sarion - Removed Zuora Callout for adjustment. Case must be approved first.
        /*
        try
        {
            sendAdjustmentToZuora(); 
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error trying to process adjustment: ' +  e.getMessage() + ' Please create an Ad Hoc Payment instead.'));
            return null;
        }
        */
        //Set to "Success"
        //adjustment.Adjustment_Status__c = 'Success';
        adjustment.Status = GlobalVariableClass.STATUS_PENDING;
        //END UD-1825 07/14/2015 Added by J.Sarion - Removed Zuora Callout for adjustment. Case must be approved first.
            
        //Save Case Record
        if(adjustment.Id == null) {
            INSERT adjustment;
        }
        else {
            UPDATE adjustment;
        }
        
        if (saveAndNew == true) {
            pageRef = new pageReference('apex/AdjustmentsCaseEditPage?accountId=' + accountId + '&RecordType=' + rectype);
            pageRef.setRedirect(true);
        }
        else {
            pageRef = new PageReference('/' + adjustment.Id);
            pageRef.setRedirect(true);           
        }

        return pageRef;  
    }
    
    //START UD-1825 07/14/2015 Added by J.Sarion - Removed Zuora Callout for adjustment. Case must be approved first.
    /*
    public void sendAdjustmentToZuora() {
        Map<String,String> resultMap = new Map<String,String>();
        Map<String,Object> adjustmentMap = new Map<String,Object>();
        ZuoraCallOut zCallOut = new ZuoraCallOut();
        
        //Retrieve Invoice Detail
        // START: Code Review Implementation 2/13/2015 JAlejandro
        if (adjustment.Invoice__c != null)
        {// END: Code Review Implementation 2/13/2015 JAlejandro
            Zuora__ZInvoice__c zInvoice =[Select Id, Name, Zuora__External_Id__c, Zuora__Zuora_Id__c,  Zuora__ZuoraId__c  
                                          FROM Zuora__ZInvoice__c Where Id = : adjustment.Invoice__c];
            
            adjustmentMap.put('Amount', adjustment.Adjustment_Amount__c);
            adjustmentMap.put('Type','Credit');
            adjustmentMap.put('InvoiceId', zInvoice.Zuora__External_Id__c);
            adjustmentMap.put('InvoiceNumber', zInvoice.Name);
        }// Code Review Implementation 2/13/2015 JAlejandro
        if (!System.Test.isRunningTest())
        {
            resultMap = zCallOut.createZObject(adjustmentMap,'InvoiceAdjustment');
        }
        else
        {
            resultMap = new Map<String, String>{'Status' => 'Error'};
        }
        
        if(resultMap.get('Status') != 'Success')
        //START : 2/10/2015 / D-2165 / K. Tan / Modified below error to capture
           throw new CustomException(resultMap.get('Message'));
        //END : 2/10/2015 / D-2165 / K. Tan / Modified below error to capture
    }
    */
    //END UD-1825 07/14/2015 Added by J.Sarion - Removed Zuora Callout for adjustment. Case must be approved first.
}