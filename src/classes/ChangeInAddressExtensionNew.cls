/* History: [JES 1/9/2014 Implement new process for COA]
*/
public class ChangeInAddressExtensionNew{

    public Case changeInAddress {get; set;} 
    Contact getContact = new Contact();
    Case tmpList = new Case(); 
    String rectype; 
    String acctId;
    String casId;
    String conId;    
    String pageRef;
    String parentId;           
    Boolean conPageRedirect = FALSE;
    public String ownerName{get;set;}
    //START D-1850 1/22/2015  Added By MGaelo - added validation rule: new address cannot be equal to old address 
    Boolean compareAddresscheck = FALSE;
    //END D-1850 1/22/2015  Added By MGaelo - added validation rule: new address cannot be equal to old address 
    //START: D-1124 1/14/2015 Added By J. Sarion - Implement new process for COA
    public SubscriptionWrapper subscriptionWrapper {get; set;}    
    public List<SubscriptionWrapper> subWrapperList {get; set;}
    List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
    //START D-1811 1/19/2015 Added By C. Lin - Fixed rendering of Subscription Information table according to its Change of address type. Added Vendor Subscriptions for Vendor and Vendor Subscriber Accounts
    List<Subscription_Vendor__c> subVendorList = new List<Subscription_Vendor__c>();
    //END D-1811 1/19/2015 Added By C. Lin
    List<Address_Assignment__c> addressAssignmentList = new List<Address_Assignment__c>();
    List<Vendor_Allocation__c> vendorAllocationList = new List<Vendor_Allocation__c>();
    List<Package__c> packageList = new List<Package__c>();
    List<zqu__ProductRatePlanCharge__c> prpcList = new List<zqu__ProductRatePlanCharge__c>();
    List<Publication__c> pubList = new List<Publication__c>();
    public Boolean showSubTable {get; set;}
    Set<Id> packageIdSet = new Set<Id>();
    Set<Id> prpIdSet = new Set<Id>();
    Set<String> pubCodeSet = new Set<String>();
    Date earliestStartDate;
    //START: D-1955 2/11/2015 Added By J. Sarion - Case Subscription creation
    Account acc;
    //END: D-1955 2/11/2015 Added By J. Sarion
    //END: D-1124 1/14/2015 Added By J. Sarion
    
    //START D-2905 05/12/2015 Added by J. Sarion - Added new variables
    Map<Id, Contact> conIdToContactMap = new Map<Id, Contact>();
    Map<Id, Set<Id>> postalCodeToVendorMap = new Map<Id, Set<Id>>();
    Map<Id, Id> subIdToVendorMap = new Map<Id, Id>();
    Map<Id, SubscriptionWrapper> subIdToSubscriptionWrapperMap = new Map<Id, SubscriptionWrapper>();
    Id myId {get; set;}
    String existingSubVendor;
    Boolean noVendorAllocated = false;
    Boolean invalidVendor = false;
    //END D-2905 05/12/2015 Added by J. Sarion - Added new variables
    
    //START D-2979 5/20/2015 Added By C. Lin - set for magazine subscriptions
    Set<Id> magazineSubSet = new Set<Id>();
    //END D-2979 5/20/2015 Added By C. Lin
    //START UD-1566 6/17/2015 Added By C. Lin - for Account record type
    Public Boolean showPackage {get; set;}
    //START UD-1566 6/17/2015 Added By C. Lin
    
    //START UD-2978 9/30/2015 Added By C. Lin - COA Bundle Subscriptions Together
    public Id selectedSubId {get; set;}
    //END UD-2978 9/30/2015 Added By C. Lin
    
    //START UD-3555 11Jan2016 Added By C. Lin - Validation for Bundle Subs should be COA together
    Map<Id, List<Zuora__Subscription__c>> oliIdToSubListMap = new Map<Id, List<Zuora__Subscription__c>>();
    Map<Id, Zuora__Subscription__c> subIdToSubscriptionMap = new Map<Id, Zuora__Subscription__c>();
    //END UD-3555 11Jan2016 Added By C. Lin
    
    public ChangeInAddressExtensionNew(ApexPages.StandardController controller) {
  
        ownerName=UserInfo.getname();
        acctId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.PARAMETER_ACCOUNTID);    
        casId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.PARAMETER_ID);
        conId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.PARAMETER_CONTACTID);  
        //rectype = ApexPages.currentPage().getParameters().get(GlobalVariableClass.PARAMETER_RECORDTYPE);       
        rectype = ConstantsSLB.getkeyid('Case_Change in Address');      
        parentId= ApexPages.currentPage().getParameters().get(GlobalVariableClass.DEFPARID);
        
        changeInAddress = (Case) controller.getRecord();
        
        changeInAddress.RecordTypeId = (rectype != '' && rectype != GlobalVariableClass.NULLVALUE ? rectype : NULL);
        changeInAddress.AccountId = (acctId != '' && acctId != GlobalVariableClass.NULLVALUE ? acctId : NULL);
        changeInAddress.ContactId = (conId != '' && conId != GlobalVariableClass.NULLVALUE ? conId : NULL);
        changeInAddress.ParentId = (parentId !=''  && parentId != GlobalVariableClass.NULLVALUE ? parentId : NULL);
        //START: D-1955 2/11/2015 Added By J. Sarion - COA Approval Process
        changeInAddress.Status = GlobalVariableClass.STATUS_PENDING;
        //END: D-1955 2/11/2015 Added By J. Sarion
        //START D-2368 2/25/2015 Added By C. Lin - Default Priority to Medium
        changeInAddress.Priority = 'Medium';
        //start UD-1046 5/7/2015 ABOdias for creation mode "Phone" will be the default
        changeInAddress.Creation_Mode_picklist__c = 'Phone' ;
        //end UD-1046 5/7/2015 ABOdias for creation mode "Phone" will be the default
        //END D-2368 2/25/2015 Added By C. Lin
        
        //START UD-3293 25Nov2015 Added By C. Lin
        if(parentId != null && parentId != ''){
            Case pCase = [SELECT Id, Subject, Description FROM Case WHERE Id = :parentId LIMIT 1];
            
            changeInAddress.Subject = pCase.Subject;
            changeInAddress.Description = pCase.Description;
        }
        //END UD-3293 25Nov2015 Added By C. Lin
        
        //START: D-1124 1/14/2015 Added By J. Sarion - Implement new process for COA
        showSubTable = false;
        //END: D-1124 1/14/2015 Added By J. Sarion
        
        //START D-2905 05/12/2015 Added by J. Sarion - Map Postal Code to Vendor
        getVendorPerPostal();
        //END D-2905 05/12/2015 Added by J. Sarion - Map Postal Code to Vendor
        //START D-2979 5/20/2015 Added By C. Lin - get magazine subscriptions
        getMagazineSubs();
        //END D-2979 5/20/2015 Added By C. Lin
        //START UD-1566 6/17/2015 Added By C. Lin - for Account record type
        showPackage();
        //END UD-1566 6/17/2015 Added By C. Lin
        
        //START UD-3555 11Jan2016 Added By C. Lin - Validation for Bundle Subs should be COA together
        List<Zuora__Subscription__c> allSubList = [SELECT Id, Name, Order_Line_Item_Number_1__c, Main_Package_1__c FROM Zuora__Subscription__c WHERE Zuora__Account__c = :acctId AND Subscription_Type_1__c = 'Publication'];
        
        if(!allSubList.isEmpty()){
            for(Zuora__Subscription__c sub : allSubList){
                if(oliIdToSubListMap.containsKey(sub.Order_Line_Item_Number_1__c)){
                    oliIdToSubListMap.get(sub.Order_Line_Item_Number_1__c).add(sub);
                }else{
                    oliIdToSubListMap.put(sub.Order_Line_Item_Number_1__c, new List<Zuora__Subscription__c>{sub});
                }
                
                if(sub.Id != null){
                    subIdToSubscriptionMap.put(sub.Id, sub);
                }
            }
        }
        //END UD-3555 11Jan2016 Added By C. Lin
    }
    
    //START UD-1566 6/17/2015 Added By C. Lin - for Account record type
    public void showPackage(){
        Account accRec = [SELECT Id, Name, RecordType.Name FROM Account WHERE Id = :changeInAddress.AccountId];
        if(accRec.RecordType.Name != 'Vendor Subscriber'){
            showPackage = true;
        }else{
            showPackage = false;
        }
    }
    //END UD-1566 6/17/2015 Added By C. Lin
    //START: D-1124 1/14/2015 Added By J. Sarion - Implement new process for COA
    public pageReference save() {
        //START D-2219 2/13/2015 Added By J.Sarion - Check if there's an existing case
        PageReference pageRef;
        List<Case> cas = new List<Case>();
        //START UD-0819 4/14/2015 Added By C. Lin - Fix for allowing user to change of vendor for another subscription
        Set<Id> caseIdSet = new Set<Id>();
        List<Case_Subscription__c> caseSubList = new List<Case_Subscription__c>();
        Set<Id> subscriptionIdSet = new Set<Id>();
        //END UD-0819 4/14/2015 Added By C. Lin
        //START D-2223 2/16/2015 Added By C. Lin - Fix for unable to sunmit for approval of case for urgent COA approval
        //END D-2223 2/16/2015 Added By C. Lin
        //START D-3942 13Nov2015 Added By C. Lin - Validation for creating COA Case with same Contact To Update and Effective Date
        List<Case> sameContactCase = new List<Case>();
        //END D-3942 13Nov2015 Added By C. Lin
        //START UD-3356 04Dec2015 Added By C. Lin - Consider same susbcription only for this validation
        Set<Id> cIdSet = new Set<Id>();
        List<Case_Subscription__c> cSubList = new List<Case_Subscription__c>();
        Set<Id> subIdSet = new Set<Id>();
        //END UD-3356 04Dec2015 Added By C. Lin
		Map<Id, Boolean> subIdToSelectedSubMap = new Map<Id, Boolean>(); //START END UD-3799 22Jan2016 Added By C. Lin - Map subId to if selected or not
        
        //START UD-2500 08/26/2015 Added by J.Sarion - Check fields if not populated
        if(changeInAddress.ContactId == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, GlobalVariableClass.CONTACTNULL));
            return null;
        }
        if(changeInAddress.Category__c == null || changeInAddress.Sub_Category__c == null || changeInAddress.Change_of_Address_Type__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ConstantsSLB.getErrorMessage(GlobalVariableClass.FIELDSNULL)));
            return null;
        }
        //END UD-2500 08/26/2015 Added by J.Sarion - Check fields if not populated
        
        //START D-3861 11/4/2015 Added By C. Lin - Check for Cases which are still in Waiting for Vendor Assignment Sub Status
        List<Case> caseWFVAList = new List<Case>();
        
        if(changeInAddress.AccountId != null){
            //START PD-0218 6/3/2016 Added By C. Aragon - Check if status is void
            caseWFVAList = [SELECT Id, Status FROM Case WHERE AccountId = :changeInAddress.AccountId AND Sub_Status__c = :GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN];
        	//END PD-0218 6/3/2016 Added By C. Aragon
        }
        
        if(!caseWFVAList.isEmpty() || caseWFVAList.size() > 1){
            //START PD-0218 6/3/2016 Added By C. Aragon - Check if status is void
            for(Case c: caseWFVAList){
                if (c.Status != GlobalVariableClass.STATUS_VOID){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ConstantsSLB.getErrorMessage(GlobalVariableClass.CASEWFVA)));
                    return null;
                } 
            }
            //END PD-0218 6/3/2016 Added By C. Aragon
        }
        //END D-3861 11/4/2015 Added By C. Lin
        
        //START D-2905 05/12/2015 Added by J. Sarion - Check Vendor if applicable to Postal Code        
        //START D-2979 5/20/2015 Added By C. Lin - Change String to GlobalVariableClass
        if (changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.CHANGEVENDOR) {
        //END D-2979 5/20/2015 Added By C. Lin
            checkVendor();

            if (noVendorAllocated) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Postal Code of Contact To Update does not have any Vendor yet.'));
                return null;
            }
            if (invalidVendor) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Vendor selected is not allocated to the postal code of the selected contact, please perform vendor allocation.'));
                return null;
            }
            
            existingSubVendor = null;
            for (SubscriptionWrapper subWrapper :subWrapperList) {
                if (subWrapper.selectSub == true) {
                    if (subIdToVendorMap.containsKey(subWrapper.subId)) {
                        if (subIdToVendorMap.get(subWrapper.subId) == changeInAddress.Vendor__c) {
                            if (existingSubVendor == null) {
                                existingSubVendor = subWrapper.subName;
                            }
                            else {
                                existingSubVendor += subWrapper.subName + ', ';
                            }
                            subIdToSubscriptionWrapperMap.get(subWrapper.subId).selectSub = false;
                        }
                    }
                }
            }
            
            if (existingSubVendor != null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Selected vendor is already the existing vendor of the ff subscriptions: ' + existingSubVendor));
                return null;
            }
        }
        //END D-2905 05/12/2015 Added by J. Sarion - Check Vendor if applicable to Postal Code      
        
        //START UD-0521 3/23/2015 Added By C. Lin - Added filter by account to query for cas
        if (changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.CHANGEVENDOR && changeInAddress.Vendor__c != null && changeInAddress.Effective_Date__c != null) {
            //START UD-0819 4/14/2015 Added By C. Lin - Fix for allowing user to change of vendor for another subscription
            //START UD-3555 11Jan2016 Added By C. Lin - Exclude Void cases from the validation rule of same contact to update
            cas = [SELECT Id FROM Case WHERE Vendor__c =:changeInAddress.Vendor__c AND Effective_Date__c =:changeInAddress.Effective_Date__c AND AccountId = :changeInAddress.AccountId AND Status != 'Void'];
            //END UD-3555 11Jan2016 Added By C. Lin
            //END UD-0819 4/14/2015 Added By C. Lin
        }
        else {
            //START UD-3555 11Jan2016 Added By C. Lin - Exclude Void cases from the validation rule of same contact to update
            //START UD-0819 4/14/2015 Added By C. Lin - Fix for allowing user to change of vendor for another subscription
            cas = [SELECT Id FROM Case WHERE Contact_To_Update__c =:changeInAddress.Contact_To_Update__c AND New_Address__c =: changeInAddress.New_Address__c AND Effective_Date__c =:changeInAddress.Effective_Date__c AND AccountId = :changeInAddress.AccountId AND Status != 'Void'];
            //END UD-0819 4/14/2015 Added By C. Lin
            //START D-3942 13Nov2015 Added By C. Lin - Validation for creating COA Case with same Contact To Update and Effective Date
            sameContactCase = [SELECT Id FROM Case WHERE Contact_To_Update__c =:changeInAddress.Contact_To_Update__c AND Effective_Date__c =:changeInAddress.Effective_Date__c AND AccountId = :changeInAddress.AccountId AND Status != 'Void'];
            //END D-3942 13Nov2015 Added By C. Lin
            //END UD-3555 11Jan2016 Added By C. Lin
        }
        //END UD-0521 3/23/2015 Added By C. Lin
        
        //START UD-0819 4/14/2015 Added By C. Lin - Fix for allowing user to change of vendor for another subscription
        if(!cas.isEmpty()){
            for(Case c : cas){
                caseIdSet.add(c.Id);
            }
        }
        
        if(!caseIdSet.isEmpty()){
            caseSubList = [SELECT Id, Name, Case__c, Subscription__c FROM Case_Subscription__c WHERE Case__c IN :caseIdSet];
        }
        
        if(!caseSubList.isEmpty()){
            for(Case_Subscription__c cs : caseSubList){
                subscriptionIdSet.add(cs.Subscription__c);
            }
        }
        //END UD-0819 4/14/2015 Added By C. Lin
        
        //START UD-3356 04Dec2015 Added By C. Lin - Consider same susbcription only for this validation
        if(!sameContactCase.isEmpty()){
            for(Case c : sameContactCase){
                cIdSet.add(c.Id);
            }
        }
        
        if(!cIdSet.isEmpty()){
            cSubList = [SELECT Id, Name, Case__c, Subscription__c FROM Case_Subscription__c WHERE Case__c IN :cIdSet];
        }
        
        if(!cSubList.isEmpty()){
            for(Case_Subscription__c cs : cSubList){
                subIdSet.add(cs.Subscription__c);
            }
        }
        //END UD-3356 04Dec2015 Added By C. Lin
        
            
            if(changeInAddress.Effective_Date__c == NULL ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Effective Date must not be null'));
                return null;
            }
            //START UD-2282 8/7/2015 Added By C. Lin - Fix order of error messages
            //START D-1849 2/2/2015 Added By C. Lin - Change condition and remove change of address type: local to overseas, overseas to overseas, and overseas to local
            if(changeInAddress.Contact_To_Update__c == null && (changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLINGADD || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.CHANGEVENDOR)){
            //END D-1849 2/2/2015 Added By C. Lin
                //START D-0974 1/20/2015 Added By C. Lin - Changed error messages to follow standards and validations for new COA.
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage(GlobalVariableClass.BLANKCONTACTTOUPDATE)));
                //END D-0974 1/20/2015 Added By C. Lin
                return null;
            }
            //START D-0974 1/21/2015 Added By J. Sarion - Changed error messages to follow standards and validations for new COA.
            //START D-1849 2/2/2015 Added By C. Lin - Change condition and remove change of address type: local to overseas, overseas to overseas, and overseas to local
            else if(changeInAddress.New_Address__c == null && (changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLINGADD || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC)) {
            //END D-1849 2/2/2015 Added By C. Lin
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage(GlobalVariableClass.BLANKNEWADDRESS)));
                return null;
            }
            //START D-1850 1/22/2015  Added By MGaelo - added validation rule: new address cannot be equal to old address 
            else if(changeInAddress.New_Address__c != null && (changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLINGADD || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC) && compareAddresscheck){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage(GlobalVariableClass.NEWADDNEOLDADD)));
                return null;
            }
            //END D-1850 1/22/2015 Added By MGaelo - added validation rule: new address cannot be equal to old address
            //START D-0974 1/20/2015 Added By C. Lin - Changed error messages to follow standards and validations for new COA.
            else if(changeInAddress.Vendor__c == null && (changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.CHANGEVENDOR)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage(GlobalVariableClass.BLANKVENDOR)));
                return null;
            }
            //END D-0974 1/20/2015 Added By C. Lin
            //START D-0116 3/3/2015 Added By C. Lin - Added Error Message for Subscription is required for certain types of change of address.
            else if(subWrapperList.isEmpty() && (changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.CHANGEVENDOR)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage(GlobalVariableClass.COATYPENOSUBS)));
                return null;
            }
            //END D-0116 3/3/2015 Added By C. Lin
            //END UD-2282 8/7/2015 Added By C. Lin
            //START: D-1955 2/11/2015 Added By J. Sarion - Case Subscription creation
            else if(!subWrapperList.isEmpty() && (changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.CHANGEVENDOR)) {
            //END: D-1955 2/11/2015 Added By J. Sarion
                //START UD-2282 8/7/2015 Added By C. Lin - Fix order of error messages
                populatePOPStartDate();
                changeInAddress.POP_Start_Date__c = (earliestStartDate != null ? earliestStartDate : null);
                //END UD-2282 8/7/2015 Added By C. Lin
                //START D-0116 3/3/2015 Added By C. Lin - Fix Attempt to dereference null
                Boolean withSubChecked = false;
                //END D-0116 3/3/2015 Added By C. Lin
                //START UD-0819 4/14/2015 Added By C. Lin - Fix for allowing user to change of vendor for another subscription
                Boolean caseSubExist = false;
                //END UD-0819 4/14/2015 Added By C. Lin
                //START UD-3356 04Dec2015 Added By C. Lin - Consider same susbcription only for this validation
                Boolean cSubExist = false;
                //END UD-3356 04Dec2015 Added By C. Lin
                //START UD-3555 11Jan2016 Added By C. Lin - Validation for Bundle Subs should be COA together
                Boolean bundleSubsSelected = true;
                //END UD-3555 11Jan2016 Added By C. Lin
                
                for (SubscriptionWrapper sub :subWrapperList) {
                    if (sub.selectSub == true) {
                        withSubChecked = true;
                        break;
                    }
                }
                //START UD-0819 4/14/2015 Added By C. Lin - Fix for allowing user to change of vendor for another subscription
                for (SubscriptionWrapper sub :subWrapperList) {
                    if(sub.selectSub == true){
                        if(subscriptionIdSet.contains(sub.subId)){
                            caseSubExist = true;
                            break;
                        }
                    }
                }
                //END UD-0819 4/14/2015 Added By C. Lin
                
                //START UD-3356 04Dec2015 Added By C. Lin - Consider same susbcription only for this validation
                for(SubscriptionWrapper sub :subWrapperList){
                    if(sub.selectSub == true){
                        if(subIdSet.contains(sub.subId)){
                            cSubExist = true;
                            break;
                        }
                    }
                }
                //END UD-3356 04Dec2015 Added By C. Lin
				//START UD-3799 22Jan2016 Added By C. Lin - Map subId to if selected or not
                for(SubscriptionWrapper sub :subWrapperList){
                    if(sub.subId != null){
                        subIdToSelectedSubMap.put(sub.subId, sub.selectSub);
                    }
                }
                //END UD-3799 22Jan2016 Added By C. Lin
				
				//START UD-3555 11Jan2016 Added By C. Lin - Validation for Bundle Subs should be COA together
				for(SubscriptionWrapper subWrap :subWrapperList){
					if(subIdToSubscriptionMap.containsKey(subWrap.subId)){
						if(oliIdToSubListMap.containsKey(subIdToSubscriptionMap.get(subWrap.subId).Order_Line_Item_Number_1__c)){
							if(oliIdToSubListMap.get(subIdToSubscriptionMap.get(subWrap.subId).Order_Line_Item_Number_1__c).size() > 1 && subWrap.selectSub == true){ //START END UD-3799 22Jan2016 Added By C. Lin - Add && subWrap.selectSub == true
								for(Zuora__Subscription__c sub : oliIdToSubListMap.get(subIdToSubscriptionMap.get(subWrap.subId).Order_Line_Item_Number_1__c)){
									//START UD-3799 22Jan2016 Added By C. Lin - Check if sub is selected in wrapper or not
                                    //if(subWrap.selectSub == false && sub.Id == subWrap.subId){
                                    if(subIdToSelectedSubMap.get(sub.Id) == false){
                                        bundleSubsSelected = false;
                                        break;
                                    }
                                    //END UD-3799 22Jan2016 Added By C. Lin
                                }
                            }
                        }
                    }
                }
                //END UD-3555 11Jan2016 Added By C. Lin
                
                //START D-2905 5/12/2015 Added By C. Lin - CCB for COA
                Set<Id> vendorSet = new Set<Id>();
                if(changeInAddress.New_Address__c != null){
                    vendorSet = getVendor(changeInAddress.New_Address__c);
                }
                system.debug('>>>>>vendorSet ' + vendorSet);
                if(changeInAddress.Effective_Date__c >= changeInAddress.POP_Start_Date__c){
                    if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC){
                        if(vendorSet.size() > 1 || vendorSet.size() == 0){
                            //START D-3301 7/31/2015 Added By C. Lin - Set Status to Pending
                            changeInAddress.Status = GlobalVariableClass.STATUS_PENDING;
                            //END D-3301 7/31/2015 Added By C. Lin
                            changeInAddress.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
                        }else if(vendorSet.size() == 1){
                            changeInAddress.Status = GlobalVariableClass.STATUS_CLOSED;
                            //START UD-3356 04Dec2015 Added By C. Lin - Fix Sub Status when case is closed
                            changeInAddress.Sub_Status__c = null;
                            //END UD-3356 04Dec2015 Added By C. Lin
                        }
                    }
                    else {
                        changeInAddress.Status = GlobalVariableClass.STATUS_CLOSED;
                        //START UD-3356 04Dec2015 Added By C. Lin - Fix Sub Status when case is closed
                        changeInAddress.Sub_Status__c = null;
                        //END UD-3356 04Dec2015 Added By C. Lin
                    }
                }
                //START D-2905 5/15/2015 Added By C. Lin - CCB for COA
                else {
                    //START UD-3356 04Dec2015 Added By C. Lin - Fix Sub Status when case is closed
                    if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.CHANGEVENDOR){
                        changeInAddress.Status = GlobalVariableClass.STATUS_CLOSED;
                        changeInAddress.Sub_Status__c = null;
                    }
                    //END UD-3356 04Dec2015 Added By C. Lin
                }
                //END D-2905 5/15/2015 Added By C. Lin - CCB for COA
                //END D-2905 5/12/2015 Added By C. Lin
                
                if (!withSubChecked) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage(GlobalVariableClass.SELECTSUBSCRIPTIONS)));
                    return null;
                }
                else {
                    //START UD-0521 3/25/2015 Added By C. Lin - Fix same case already exist error
                    //START UD-0819 4/14/2015 Added By C. Lin - Fix for allowing user to change of vendor for another subscription
                    if (caseSubExist == false) {
                    //END UD-0819 4/14/2015 Added By C. Lin
                        //START D-3942 13Nov2015 Added By C. Lin - Validation for creating COA Case with same Contact To Update and Effective Date
                        //START UD-3356 04Dec2015 Added By C. Lin - Consider same susbcription only for this validation
                        if(cSubExist == false){
                            //START UD-3555 11Jan2016 Added By C. Lin - Validation for Bundle Subs should be COA together
                            if(bundleSubsSelected){
                                String error = checkContactEligibility();
                                if(error != null){
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                                    return null;
                                }else{
                                    try {
                                        upsert changeInAddress;
                                  
                                        //START D-1955 2/11/2015 Added By J.Sarion - Check Effective Date if earlier than POP Start Date
                                        //START UD-0816 4/23/2015 Added By C. Lin - For Urgent Approval of COA
                                        if (changeInAddress.Effective_Date__c >= changeInAddress.POP_Start_Date__c) {
                                        //END UD-0816 4/23/2015 Added By C. Lin
                                            createAssignment();
                                            //Start: D-2075 02/25/2014 Added by S.Puli
                                            if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.CHANGEVENDOR || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC){
                                                createCaseSubscription();
                                            }
                                            //End: D-2075 02/25/2014 Added by S.Puli
                                        }
                                        //START UD-0816 4/23/2015 Added By C. Lin - For Urgent Approval of COA
                                        else if (changeInAddress.Effective_Date__c < changeInAddress.POP_Start_Date__c) {
                                            if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.CHANGEVENDOR){
                                                createCaseSubscription();
                                                createAssignment();
                                            }else if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC){
                                                createCaseSubscription();
                                                //START D-3301 7/31/2015 Added By C. Lin - Set Status to Pending
                                                changeInAddress.Status = GlobalVariableClass.STATUS_PENDING;
                                                //END D-3301 7/31/2015 Added By C. Lin
                                            }
                                        }
                                        //END UD-0816 4/23/2015 Added By C. Lin
                                        //END D-1955 2/11/2015 Added By J.Sarion
                                  
                                        //START D-3301 7/31/2015 Added By C. Lin - Upsert again
                                        upsert changeInAddress;
                                        //END D-3301 7/31/2015 Added By C. Lin
                                        insert addressAssignmentList;
                                        pageRef = new pageReference('/' + changeInAddress.Id);

                                    } catch (exception e) {
                                        ApexPages.addMessages(e);
                                        return null;
                                    }
                                }
                            }else{
								//START UD-3799 22Jan2016 Added By C. Lin - Updated Error Message
                                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Subscriptions in a Bundle Package should be selected'));
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A subscription from a bundle package is selected and its related bundle subscription/s are not selected. Please select all subscriptions in that bundle package to proceed.'));
                                //END UD-3799 22Jan2016 Added By C. Lin
                                selectBundleSub(); //START END UD-3555 11Jan2016 Added By C. Lin - To auto select the Bundle Sub of the sub selected by the user
                                return null;
                            }
                            //END UD-3555 11Jan2016 Added By C. Lin
                        }else{
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage(GlobalVariableClass.SAMECONTACTCASE)));
                            return null;
                        }
                        //END UD-3356 04Dec2015 Added By C. Lin
                        //END D-3942 13Nov2015 Added By C. Lin
                    } else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage(GlobalVariableClass.SAMECASE)));
                        return null;
                    }
                    //END UD-0521 3/25/2015 Added By C. Lin
                }
            }
            //END D-0974 1/21/2015 Added By J. Sarion
            else{
                //START UD-0521 3/25/2015 Added By C. Lin - Fix same case already exist error
                if (cas.isEmpty()) {
                    //START UD-2016 8/10/2015 Added By C. Lin - Populate POP Start Date
                    populatePOPStartDate();
                    changeInAddress.POP_Start_Date__c = (earliestStartDate != null ? earliestStartDate : null);
                    //END UD-2016 8/10/2015 Added By C. Lin
                    //START D-2905 5/12/2015 Added By C. Lin - CCB for COA
                    Set<Id> vendorSet = new Set<Id>();
                    if(changeInAddress.New_Address__c != null){
                        vendorSet = getVendor(changeInAddress.New_Address__c);
                    }
                    if(changeInAddress.Effective_Date__c >= changeInAddress.POP_Start_Date__c){
                        if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD){
                            if(vendorSet.size() > 1 || vendorSet.size() == 0){
                                //START D-3301 7/31/2015 Added By C. Lin - Set Status to Pending
                                changeInAddress.Status = GlobalVariableClass.STATUS_PENDING;
                                //END D-3301 7/31/2015 Added By C. Lin
                                changeInAddress.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
                            }else if(vendorSet.size() == 1){
                                changeInAddress.Status = GlobalVariableClass.STATUS_CLOSED;
                                //START UD-3356 04Dec2015 Added By C. Lin - Fix Sub Status when case is closed
                                changeInAddress.Sub_Status__c = null;
                                //END UD-3356 04Dec2015 Added By C. Lin
                            }
                        }
                        //START D-2956 5/27/2015 Added By C. Lin - Close COA Billing Address after save
                        else if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLINGADD){
                            changeInAddress.Status = GlobalVariableClass.STATUS_CLOSED;
                            //START UD-3356 04Dec2015 Added By C. Lin - Fix Sub Status when case is closed
                            changeInAddress.Sub_Status__c = null;
                            //END UD-3356 04Dec2015 Added By C. Lin
                        }
                        //END D-2956 5/27/2015 Added By C. Lin
                    }
                    //START D-2956 5/27/2015 Added By C. Lin - Close COA Billing Address after save
                    else{
                        if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLINGADD){
                            changeInAddress.Status = GlobalVariableClass.STATUS_CLOSED;
                            //START UD-3356 04Dec2015 Added By C. Lin - Fix Sub Status when case is closed
                            changeInAddress.Sub_Status__c = null;
                            //END UD-3356 04Dec2015 Added By C. Lin
                        }
                    }
                    //END D-2956 5/27/2015 Added By C. Lin
                    //END D-2905 5/12/2015 Added By C. Lin
                    
                    //START: D-1338 12/22/2014 Added By C. Lin - Fixed error handling to display error message to the page.
                    String error = checkContactEligibility();
                    if(error != null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                        return null;
                    }else{
                        try {
                            upsert changeInAddress;
                        
                            //START D-1955 2/11/2015 Added By J.Sarion - Check Effective Date if earlier than POP Start Date
                            //START UD-0816 4/23/2015 Added By C. Lin - For Urgent Approval of COA
                            if (changeInAddress.Effective_Date__c >= changeInAddress.POP_Start_Date__c) {
                                createAssignment();
    //START D-2913 05/18/2015 Jason A./Sherwin P.
                                //START D-3026 5/29/2015 Added By C. Lin - Add Create Case Sub for Change of Billing Address
                                if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLINGADD){
                                    createCaseSubscription();
                                }
                                //END D-3026 5/29/2015 Added By C. Lin
    //END D-2913 05/18/2015 Jason A./Sherwin P.
                            }
                            //END UD-0816 4/23/2015 Added By C. Lin
                            //START UD-0816 4/23/2015 Added By C. Lin - For Urgent Approval of COA
                            //Start: D-2075 02/25/2014 Added by S.Puli
                            else if (changeInAddress.Effective_Date__c < changeInAddress.POP_Start_Date__c) {
                            //End: D-2075 02/25/2014 Added by S.Puli
                                //START D-2905 5/12/2015 Added By C. Lin
                                if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD){
                                    createCaseSubscription();
                                    //START D-3301 7/31/2015 Added By C. Lin - Set Status to Pending
                                    changeInAddress.Status = GlobalVariableClass.STATUS_PENDING;
                                    //END D-3301 7/31/2015 Added By C. Lin
                                }else if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLINGADD){
                                    createAssignment();
                                    //START D-3026 5/29/2015 Added By C. Lin - Add Create Case Sub for Change of Billing Address
                                    createCaseSubscription();
                                    //END D-3026 5/29/2015 Added By C. Lin
                                }
                                //END D-2905 5/12/2015 Added By C. Lin
                            }
                            //END UD-0816 4/23/2015 Added By C. Lin
                            //END D-1955 2/11/2015 Added By J.Sarion
                        
                            //START D-3301 7/31/2015 Added By C. Lin - Upsert again
                            upsert changeInAddress;
                            //END D-3301 7/31/2015 Added By C. Lin
                            insert vendorAllocationList;
                            insert addressAssignmentList;
                            pageRef = new pageReference('/' + changeInAddress.Id);

                        } catch (exception e) {
                            ApexPages.addMessages(e);
                            return null;
                        }
                    }
                    //END: D-1338 12/22/2014 Added By C. Lin
                } else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage(GlobalVariableClass.SAMECASE)));
                    return null;
                }
                //END UD-0521 3/25/2015 Added By C. Lin
            }
        //END: D-2219 2/13/2015 Added By J. Sarion
        pageRef.setRedirect(true);
        
        return pageRef;
    }
    //END: D-1124 1/14/2015 Added By J. Sarion
    
    //START 12/3/2014 CCB.002 Created By: Francis Benzon
    //START: D-1338 12/22/2014 Added By C. Lin - Fixed error handling to display error message to the page.
    //START D-0974 1/20/2015 Added By C. Lin - Changed error messages to follow standards and validations for new COA.
    public String checkContactEligibility() {
        String errorMsg;
        //String caseRecType = changeInAddress.RecordTypeId;      
        String changeOfAddressType = changeInAddress.Change_of_Address_Type__c;
        Set<String> deliveryAddTypeSet = new Set<String> {
            GlobalVariableClass.DELIVERYADDLOC,
            GlobalVariableClass.DELIVERYADDLOCOVSEA,
            GlobalVariableClass.DELIVERYADDOVSEA,
            GlobalVariableClass.DELIVERYADDOVSEALOC
        };
        if(changeInAddress.Contact_To_Update__c != null) {
            getContact = [SELECT Id, Recipient_Indicator__c, Billing_Indicator__c FROM Contact WHERE Id = :changeInAddress.Contact_To_Update__c];
        }
        
        //validation for change of billing address
        //START D-3681 10/30/2015 Added By C. Lin - Added validation criteria
        if(changeOfAddressType == GlobalVariableClass.BILLINGADD && (getContact.Billing_Indicator__c == false)){ //START/END UD-3270 30Nov2015 Added By C. Lin - At least Billing Indicator checked
        //END D-3681 10/30/2015 Added By C. Lin
            errorMsg = ConstantsSLB.getErrorMessage(GlobalVariableClass.BILLINDICATORREQUIRED);
        }
        //validation rule for change of delivery address
        //START D-1849 2/2/2015 Added By C. Lin - Change condition and remove change of address type: local to overseas, overseas to overseas, and overseas to local
        //START D-3681 10/30/2015 Added By C. Lin - Added validation criteria
        else if(changeOfAddressType == GlobalVariableClass.DELIVERYADDLOC && (getContact.Recipient_Indicator__c == false)) { //START/END UD-3270 30Nov2015 Added By C. Lin - At least Recipient Indicator checked
        //END D-3681 10/30/2015 Added By C. Lin
        //END D-1849 2/2/2015 Added By C. Lin
            errorMsg = ConstantsSLB.getErrorMessage(GlobalVariableClass.RECIPINDICATORREQUIRED);
        }
        //validation rule for change of delivery and billing address
        else if((getContact.Recipient_Indicator__c == false || getContact.Billing_Indicator__c == false) && changeOfAddressType == GlobalVariableClass.BILLDELIVERYADD) {
            errorMsg = ConstantsSLB.getErrorMessage(GlobalVariableClass.BILLRECIPINDICATORREQUIRED);
        }
        
        return errorMsg;
    }
    //END D-0974 1/20/2015 Added By C. Lin
    //END: D-1338 12/22/2014 Added By C. Lin
    //END 12/3/2014 CCB.002 Created By: Francis Benzon
    
    //START: D-1124 1/14/2015 Added By J. Sarion - Implement new process for COA
    // ------------  Subscription Wrapper  ------------ //
    public class SubscriptionWrapper{ 
        public Boolean selectSub {get; set;}      
        public String subName {get; set;}
        //START UD-1566 6/17/2015 Added By C. Lin - Add Main package to table
        public String mainPack {get; set;}
        //END UD-1566 6/17/2015 Added By C. Lin
        public Id subId {get; set;}
        public String contactName {get; set;}
        public String vendorName {get; set;}
        public String status {get; set;}
        //START UD-0819 4/14/2015 Added By C. Lin - Fix for allowing user to change of vendor for another subscription
        public Id recipientPostal {get; set;}
        //END UD-0819 4/14/2015 Added By C. Lin
        //START UD-2206 9/17/15 AddedBy FrancisBenzon : address Id var
        public Id recipientAddress {get; set;}
        //END UD-2206 9/17/15 AddedBy FrancisBenzon : address Id var
        //START D-3709 10/12/2015 Added By C. Lin - Save Old Vendor Credit of Sub in Case Subscription
        public Decimal vendorCredit {get; set;}
        //END D-3709 10/12/2015 Added By C. Lin
    }
    
    public void getSubscriptions() {
        subWrapperList = new List<SubscriptionWrapper>();
        //START D-1811 1/23/2015 Added By C. Lin - Fixed rendering of Subscription Information table according to its Change of address type. Added Vendor Subscriptions for Vendor and Vendor Subscriber Accounts
        //START: D-1955 2/11/2015 Added By J. Sarion - Case Subscription creation
        acc = [SELECT Id, RecordType.Name FROM Account WHERE Id =:acctId];
        //END: D-1955 2/11/2015 Added By J. Sarion
        //START UD-0818 4/17/2015 Added By C. Lin - Fix for displaying Print and All In One Subscriptions only.
        Set<Id> subVenIdSet = new Set<Id>();
        List<Subscription_Vendor_Publication__c> subVenPublication = new List<Subscription_Vendor_Publication__c>();
        Set<Id> svIdSet = new Set<Id>();
        List<Subscription_Vendor__c> sVendorList = new List<Subscription_Vendor__c>();
        Set<Id> packIdSet = new Set<Id>();
        List<Package_Item__c> packageItemList = new List<Package_Item__c>();
        Map<Id, List<Package_Item__c>> packToPackItemMap = new Map<Id, List<Package_Item__c>>();
        Set<Id> sIdSet = new Set<Id>();
        List<Zuora__Subscription__c>  sList = new List<Zuora__Subscription__c>();
        //END UD-0818 4/17/2015 Added By C. Lin
        
        if (acc.RecordType.Name == 'Vendor Subscriber') {
            //START D-0116 3/2/2015 Added By C. Lin - Display subscriptions(vendor) with effective date is within the subscription period
            if(changeInAddress.Effective_Date__c != null){
                //START D-2905 05/12/2015 Added by: J.Sarion - Subscription list for Change of Vendor depends on Contact to Update
                //START D-2979 5/20/2015 Added By C. Lin - Change String to GlobalVariableClass
                if (changeInAddress.Change_of_Address_Type__c != GlobalVariableClass.CHANGEVENDOR) {
                //END D-2979 5/20/2015 Added By C. Lin
                    //START UD-2398 08/20/2015 Added by J.Sarion - Get subscription vendor with null subscription stop date
                    //START UD-0819 4/14/2015 Added By C. Lin - Fix for allowing user to change of vendor for another subscription
                    //START UD-2070 11Nov2015 Added By C. Lin - change filter to Contact instead of Account
                    if(changeInAddress.ContactId != null){
                        subVendorList = [SELECT Id, Name, Recipient__r.Name, Recipient__r.Address__r.Postal_Code__c, Vendor__r.Name, Status__c, Vendor__c FROM Subscription_Vendor__c WHERE Recipient__c =:changeInAddress.ContactId AND Status__c = 'Active' AND (Subscription_Stop_Date__c > :changeInAddress.Effective_Date__c OR Subscription_Stop_Date__c = null)];
                    }
                    //END UD-2070 11Nov2015 Added By C. Lin
                    //END UD-0819 4/14/2015 Added By C. Lin
                }
                else {
                    //START UD-2070 11Nov2015 Added By C. Lin - change filter to Contact instead of Account
                    if(changeInAddress.ContactId != null){
                        subVendorList = [SELECT Id, Name, Recipient__r.Name, Recipient__r.Address__r.Postal_Code__c, Vendor__r.Name, Status__c, Vendor__c FROM Subscription_Vendor__c WHERE Recipient__c =:changeInAddress.ContactId AND Status__c = 'Active' AND (Subscription_Stop_Date__c > :changeInAddress.Effective_Date__c OR Subscription_Stop_Date__c = null)];
                    }
                    //END UD-2070 11Nov2015 Added By C. Lin
                    //END UD-2398 08/20/2015 Added by J.Sarion - Get subscription vendor with null subscription stop date
                }
            }
            //START D-2979 5/20/2015 Added By C. Lin - Remove code
    //START D-2913 05/18/2015 Jason A./Sherwin P.
            /*if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD){
                subVendorList = [SELECT Id, Name, Recipient__r.Name, Recipient__r.Address__r.Postal_Code__c, Vendor__r.Name, Status__c, Vendor__c FROM Subscription_Vendor__c WHERE Account__c =:acctId AND Status__c = 'Active' AND Subscription_Stop_Date__c > :changeInAddress.Effective_Date__c];
            }*/
    //END D-2913 05/18/2015 Jason A./Sherwin P.
            //END D-2979 5/20/2015 Added By C. Lin
            //END D-0116 3/2/2015 Added By C. Lin
            
            //START UD-0818 4/17/2015 Added By C. Lin - Fix for displaying Print and All In One Subscriptions only.
            if(!subVendorList.isEmpty()){
                for(Subscription_Vendor__c subVen : subVendorList){
                    subVenIdSet.add(subVen.Id);
                    subIdToVendorMap.put(subVen.Id, subVen.Vendor__c);
                }
            }
            //END D-2905 05/12/2015 Added by: J.Sarion - Subscription list for Change of Vendor depends on Contact to Update
            if(!subVenIdSet.isEmpty()){
                //START D-2979 5/20/2015 Added By C. Lin - Add Publication__r.Product_Category__c in query
                subVenPublication = [SELECT Id, Name, Subscription_Vendor__c, Publication__c, Publication__r.Platform_Type__c, Publication__r.Product_Category__c FROM Subscription_Vendor_Publication__c WHERE Subscription_Vendor__c IN :subVenIdSet];
                //END D-2979 5/20/2015 Added By C. Lin
            }
            
            //START D-2979 5/20/2015 Added By C. Lin - Exclude Magazine Subscriptions
            if(!subVenPublication.isEmpty()){
                for(Subscription_Vendor_Publication__c svp : subVenPublication){
                    if(svp.Publication__r.Platform_Type__c == 'Print' || svp.Publication__r.Platform_Type__c == 'All in One (AIO)'){
                        if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.CHANGEVENDOR){
                            if(svp.Publication__r.Product_Category__c != 'Magazine'){
                                svIdSet.add(svp.Subscription_Vendor__c);
                            }
                        }else{
                            svIdSet.add(svp.Subscription_Vendor__c);
                        }
                    }
                }
            }
            //END D-2979 5/20/2015 Added By C. Lin
            
            if(!svIdSet.isEmpty()){
                //START UD-2206 9/24/2015 Added By C. Lin - Added Recipient__r.Address__c in query
                sVendorList = [SELECT Id, Name, Recipient__r.Name, Recipient__r.Address__r.Postal_Code__c, Vendor__r.Name, Status__c, Recipient__r.Address__c FROM Subscription_Vendor__c WHERE Id IN :svIdSet];
                //END UD-2206 9/24/2015 Added By C. Lin
            }
            
            for (Subscription_Vendor__c sub :sVendorList) {
            //END UD-0818 4/17/2015 Added By C. Lin
                subscriptionWrapper = new SubscriptionWrapper();
                
                subscriptionWrapper.selectSub = false;
                subscriptionWrapper.subName = sub.Name;
                subscriptionWrapper.subId = sub.Id;
                subscriptionWrapper.contactName = (sub.Recipient__r.Name != null ? sub.Recipient__r.Name : null);
                subscriptionWrapper.vendorName = (sub.Vendor__r.Name != null ? sub.Vendor__r.Name : null);
                subscriptionWrapper.status = (sub.Status__c != null ? sub.Status__c : null);
                //START UD-0819 4/14/2015 Added By C. Lin - Fix for allowing user to change of vendor for another subscription
                subscriptionWrapper.recipientPostal = (sub.Recipient__r.Address__r.Postal_Code__c != null ? sub.Recipient__r.Address__r.Postal_Code__c : null);
                //END UD-0819 4/14/2015 Added By C. Lin
                //START UD-2206 9/24/2015 Added By C. Lin - populate address using recipient contact address
                subscriptionWrapper.recipientAddress = (sub.Recipient__r.Address__c != null ? sub.Recipient__r.Address__c : null);
                //END UD-2206 9/24/2015 Added By C. Lin
                
                subWrapperList.add(subscriptionWrapper);
                
                //START D-2905 05/12/2015 Added by: J.Sarion - Subscription list for Change of Vendor depends on Contact to Update
                subIdToSubscriptionWrapperMap.put(sub.Id, subscriptionWrapper);
                //END D-2905 05/12/2015 Added by: J.Sarion - Subscription list for Change of Vendor depends on Contact to Update
            }
        }
        else if(acc.RecordType.Name != 'Vendor') {
            //START D-2378 2/25/2015 Added By C. Lin - Display only subscriptions of type publication
            //START D-0116 3/2/2015 Added By C. Lin - Display subscriptions(vendor) with effective date is within the subscription period AND Term Setting is EVERGREEN
            if(changeInAddress.Effective_Date__c != null){
                //START D-2905 05/12/2015 Added by: J.Sarion - Subscription list for Change of Vendor depends on Contact to Update
                //START D-2979 5/20/2015 Added By C. Lin - Change String to GlobalVariableClass
                if (changeInAddress.Change_of_Address_Type__c != GlobalVariableClass.CHANGEVENDOR) {
                //END D-2979 5/20/2015 Added By C. Lin
                    //START UD-0819 4/14/2015 Added By C. Lin - Fix for allowing user to change of vendor for another subscription
                    //START UD-2070 11Nov2015 Added By C. Lin - change filter to Contact instead of Account
                    if(changeInAddress.ContactId != null){
                        //START UD-3356 04Dec2015 Added By C. Lin - Fix hotfix code for UD-3270
                        //START UD-3270 30Nov2015 Added By C. Lin - get subList depending on the Change of Address Type selected
                        if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLINGADD){
                            subList = [SELECT Id, Name, Recipient_Contact__r.Name, Recipient_Contact__r.Address__r.Postal_Code__c, Vendor_1__r.Name, Zuora__Status__c, Main_Package_1__c, Vendor_1__c FROM Zuora__Subscription__c WHERE Contact__c =:changeInAddress.ContactId and Zuora__Status__c = 'Active' AND Subscription_Type_1__c = 'Publication' AND (Zuora__SubscriptionEndDate__c > :changeInAddress.Effective_Date__c OR Zuora__TermSettingType__c = 'EVERGREEN')];
                        }else if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD){
                            subList = [SELECT Id, Name, Recipient_Contact__r.Name, Recipient_Contact__r.Address__r.Postal_Code__c, Vendor_1__r.Name, Zuora__Status__c, Main_Package_1__c, Vendor_1__c FROM Zuora__Subscription__c WHERE (Recipient_Contact__c =:changeInAddress.ContactId OR Contact__c =:changeInAddress.ContactId) and Zuora__Status__c = 'Active' AND Subscription_Type_1__c = 'Publication' AND (Zuora__SubscriptionEndDate__c > :changeInAddress.Effective_Date__c OR Zuora__TermSettingType__c = 'EVERGREEN')];
                        }else if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC){
                            subList = [SELECT Id, Name, Recipient_Contact__r.Name, Recipient_Contact__r.Address__r.Postal_Code__c, Vendor_1__r.Name, Zuora__Status__c, Main_Package_1__c, Vendor_1__c FROM Zuora__Subscription__c WHERE Recipient_Contact__c =:changeInAddress.ContactId and Zuora__Status__c = 'Active' AND Subscription_Type_1__c = 'Publication' AND (Zuora__SubscriptionEndDate__c > :changeInAddress.Effective_Date__c OR Zuora__TermSettingType__c = 'EVERGREEN')];
                        }
                        //END UD-3270 30Nov2015 Added By C. Lin
                        //END UD-3356 04Dec2015 Added By C. Lin
                    }
                    //END UD-2070 11Nov2015 Added By C. Lin
                    //END UD-0819 4/14/2015 Added By C. Lin
                }
                else {
                    //START UD-2070 11Nov2015 Added By C. Lin - change filter to Contact instead of Account
                    if(changeInAddress.ContactId != null){
                        //START UD-3356 04Dec2015 Added By C. Lin - Fix hotfix code for UD-3270
                        subList = [SELECT Id, Name, Recipient_Contact__r.Name, Recipient_Contact__r.Address__r.Postal_Code__c, Vendor_1__r.Name, Zuora__Status__c, Main_Package_1__c, Vendor_1__c FROM Zuora__Subscription__c WHERE Recipient_Contact__c =:changeInAddress.ContactId and Zuora__Status__c = 'Active' AND Subscription_Type_1__c = 'Publication' AND (Zuora__SubscriptionEndDate__c > :changeInAddress.Effective_Date__c OR Zuora__TermSettingType__c = 'EVERGREEN')];
                        //END UD-3356 04Dec2015 Added By C. Lin
                    }
                    //END UD-2070 11Nov2015 Added By C. Lin
                }
            }
            //START D-2979 5/20/2015 Added By C. Lin - Remove code
    //START D-2913 05/18/2015 Jason A./Sherwin P.
            /*if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD){
                subList = [SELECT Id, Name, Recipient_Contact__r.Name, Recipient_Contact__r.Address__r.Postal_Code__c, Vendor_1__r.Name, Zuora__Status__c, Main_Package_1__c, Vendor_1__c FROM Zuora__Subscription__c WHERE Zuora__Account__c =:acctId and Zuora__Status__c = 'Active' AND Subscription_Type_1__c = 'Publication' AND (Zuora__SubscriptionEndDate__c > :changeInAddress.Effective_Date__c OR Zuora__TermSettingType__c = 'EVERGREEN')];
            }*/
    //END D-2913 05/18/2015 Jason A./Sherwin P.
            //END D-2979 5/20/2015 Added By C. Lin
            //END D-0116 3/2/2015 Added By C. Lin
            //END D-2378 2/25/2015 Added By C. Lin
            
            //START UD-0818 4/17/2015 Added By C. Lin - Fix for displaying Print and All In One Subscriptions only.
            if(!subList.isEmpty()){
                for(Zuora__Subscription__c s : subList){
                    packIdSet.add(s.Main_Package_1__c);
                    subIdToVendorMap.put(s.Id, s.Vendor_1__c);
                }
            }
            //END D-2905 05/12/2015 Added by: J.Sarion - Subscription list for Change of Vendor depends on Contact to Update
            Id baseProduct = ConstantsSLB.getKeyId('Package Item_Base Product');
            //START: D-2808 JLedesma 4/28/2015 Cannot perform Change of Address on Bundle Package
            Id bundleProduct = ConstantsSLB.getKeyId('Package Item_Bundle Product');
            
            
            if(!packIdSet.isEmpty()){
                //START D-2979 5/20/2015 Added By C. Lin - Add Is_Magazine__c in query
                packageItemList = [SELECT Id, Package__c, Product_Platform__c, Is_Magazine__c FROM Package_Item__c WHERE Package__c IN :packIdSet AND (RecordTypeId = :baseProduct OR RecordTypeId = :bundleProduct)];
                //END D-2979 5/20/2015 Added By C. Lin
            }
            
            if(!packageItemList.isEmpty()){
                for(Package_Item__c pItem : packageItemList){
                    if(packToPackItemMap.containsKey(pItem.Package__c)){
                        packToPackItemMap.get(pItem.Package__c).add(pItem);
                    }else{
                        packToPackItemMap.put(pItem.Package__c, new List<Package_Item__c> {pItem});
                    }
                }
            }
           
            //START D-2979 5/20/2015 Added By C. Lin - Exclude Magazine Subscriptions
            if(!subList.isEmpty()){
                for(Zuora__Subscription__c sub : subList){
                    if(packToPackItemMap.containsKey(sub.Main_Package_1__c)){
                        for(Package_Item__c packItem : packToPackItemMap.get(sub.Main_Package_1__c)){
                            if(packItem.Product_Platform__c == 'Print' || packItem.Product_Platform__c == 'All-In-One'){
                                if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.CHANGEVENDOR){
                                    if(packItem.Is_Magazine__c == false){
                                        sIdSet.add(sub.Id);
                                    }
                                }else{
                                    sIdSet.add(sub.Id);
                                }
                            }
                        }
                    }
                }
            }
            //END D-2979 5/20/2015 Added By C. Lin
             //END: D-2808 JLedesma 4/28/2015 Cannot perform Change of Address on Bundle Package
            if(!sIdSet.isEmpty()){
                //START UD-2206 9/17/15 AddedBy FrancisBenzon : added recipient contact address in query
                //START UD-1566 6/17/2015 Added By C. Lin - Add Main_Package_1__r.Name
                //START D-3709 10/12/2015 Added By C. Lin - Save Old Vendor Credit of Sub in Case Subscription
                sList = [SELECT Id, Name, Recipient_Contact__r.Name, Recipient_Contact__r.Address__r.Postal_Code__c, Vendor_1__r.Name, Zuora__Status__c, Main_Package_1__c, Main_Package_1__r.Name, Recipient_Contact__r.Address__c, Vendor_Credit_1__c FROM Zuora__Subscription__c WHERE Id IN :sIdSet];
                //END D-3709 10/12/2015 Added By C. Lin
                //END UD-1566 6/17/2015 Added By C. Lin
                //END UD-2206 9/17/15 AddedBy FrancisBenzon : added recipient contact address in query
            }
            
            for (Zuora__Subscription__c sub :sList) {
            //END UD-0818 4/17/2015 Added By C. Lin
                subscriptionWrapper = new SubscriptionWrapper();
                
                subscriptionWrapper.selectSub = false;
                subscriptionWrapper.subName = sub.Name;
                //START UD-1566 6/17/2015 Added By C. Lin - Add main package to the table
                subscriptionWrapper.mainPack = sub.Main_Package_1__r.Name;
                //END UD-1566 6/17/2015 Added By C. Lin
                subscriptionWrapper.subId = sub.Id;
                subscriptionWrapper.contactName = (sub.Recipient_Contact__r.Name != null ? sub.Recipient_Contact__r.Name : null);
                subscriptionWrapper.vendorName = (sub.Vendor_1__r.Name != null ? sub.Vendor_1__r.Name : null);
                subscriptionWrapper.status = (sub.Zuora__Status__c != null ? sub.Zuora__Status__c : null);
                //START UD-0819 4/14/2015 Added By C. Lin - Fix for allowing user to change of vendor for another subscription
                subscriptionWrapper.recipientPostal = (sub.Recipient_Contact__r.Address__r.Postal_Code__c != null ? sub.Recipient_Contact__r.Address__r.Postal_Code__c : null);
                //END UD-0819 4/14/2015 Added By C. Lin
                //START UD-2206 9/17/15 AddedBy francisBenzon : populate address using recipient contact address
                subscriptionWrapper.recipientAddress = (sub.Recipient_Contact__r.Address__c != null ? sub.Recipient_Contact__r.Address__c : null);
                //END UD-2206 9/17/15 AddedBy francisBenzon : populate address using recipient contact address
                //START D-3709 10/12/2015 Added By C. Lin - Save Old Vendor Credit of Sub in Case Subscription
                subscriptionWrapper.vendorCredit = (sub.Vendor_Credit_1__c != null ? sub.Vendor_Credit_1__c : null);
                //END D-3709 10/12/2015 Added By C. Lin
                
                subWrapperList.add(subscriptionWrapper);
                
                //START D-2905 05/12/2015 Added by: J.Sarion - Subscription list for Change of Vendor depends on Contact to Update
                subIdToSubscriptionWrapperMap.put(sub.Id, subscriptionWrapper);
                //END D-2905 05/12/2015 Added by: J.Sarion - Subscription list for Change of Vendor depends on Contact to Update
            }
        }
        //END D-1811 1/23/2015 Added By C. Lin
        
        //START D-2905 05/12/2015 Added by J. Sarion - Check Vendor if applicable to Postal Code
        checkVendor();
        //END D-2905 05/12/2015 Added by J. Sarion - Check Vendor if applicable to Postal Code
    }
    
    public void checkAllSubs() {
        for (SubscriptionWrapper sub :subWrapperList) {
            sub.selectSub = true;
        }
    }
    
    //START UD-2978 9/30/2015 Added By C. Lin - COA Bundle Subscriptions Together
    public void selectBundleSub() {
        Set<Id> bundleSubSet = getBundleSubSet(selectedSubId);
        Map<Id, Boolean> selectedSubToCheckValue = new Map<Id, Boolean>();
        
        for (SubscriptionWrapper sub :subWrapperList) {
            if(sub.selectSub == true && selectedSubId == sub.subId){
                selectedSubToCheckValue.put(selectedSubId, true);
            }else if(sub.selectSub == false && selectedSubId == sub.subId){
                selectedSubToCheckValue.put(selectedSubId, false);
            }
        }
        
        for (SubscriptionWrapper sub :subWrapperList) {
            if(bundleSubSet.contains(sub.subId)){
                sub.selectSub = selectedSubToCheckValue.get(selectedSubId);
            }
        }
    }
    
    public Set<Id> getBundleSubSet(Id selectedSubId){
        Set<Id> bundleSubSet = new Set<Id>();
        
        List<Zuora__Subscription__c> selectedSubList = [SELECT Id, Name, Order_Line_Item_Number_1__c, Main_Package_1__c FROM Zuora__Subscription__c WHERE Id = :selectedSubId];
        
        //START UD-3555 11Jan2016 Added By C. Lin - Validation for Bundle Subs should be COA together
        /*if(!selectedSubList.isEmpty()){
            for(Zuora__Subscription__c sub : selectedSubList){
                if(sub.Order_Line_Item_Number_1__c != null){
                    bundleOliId = sub.Order_Line_Item_Number_1__c;
                }
                
                if(sub.Main_Package_1__c != null){
                    bundlePackageId = sub.Main_Package_1__c;
                }
            }
        }
        
        if(bundleOliId != null && bundlePackageId != null){
            bundleSubList = [SELECT Id, Name FROM Zuora__Subscription__c WHERE Order_Line_Item_Number_1__c = :bundleOliId AND Main_Package_1__c = :bundlePackageId AND Subscription_Type_1__c = 'Publication'];
        }
        
        if(!bundleSubList.isEmpty()){
            for(Zuora__Subscription__c sub : bundleSubList){
                bundleSubSet.add(sub.Id);
            }
        }*/
        
        for(Zuora__Subscription__c subscrip : selectedSubList){
            if(oliIdToSubListMap.containsKey(subscrip.Order_Line_Item_Number_1__c)){
                for(Zuora__Subscription__c sub : oliIdToSubListMap.get(subscrip.Order_Line_Item_Number_1__c)){
                    bundleSubSet.add(sub.Id);
                }
            }
        }
        //END UD-3555 11Jan2016 Added By C. Lin
        
        return bundleSubSet;
    }
    //END UD-2978 9/30/2015 Added By C. Lin
    
    public Boolean checkAddressType() {
        if (changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.CHANGEVENDOR) {
            showSubTable = true;
            return showSubTable;
        } else{
            showSubTable = false;
            return showSubTable;
        }
        
    }
    //START D-1850 1/22/2015 Added By MGaelo - added validation rule: new address cannot be equal to old address 
    public void compareAddress() {
    
        compareAddresscheck = FALSE;
        if(changeInAddress.Contact_To_Update__c != null) {
            getContact = [SELECT Id, Address__c, Recipient_Indicator__c, Billing_Indicator__c FROM Contact WHERE Id = :changeInAddress.Contact_To_Update__c];
        }
        
        if(changeInAddress.New_Address__c == getContact.Address__c && (changeInAddress.Change_of_Address_Type__c != GlobalVariableClass.CHANGEVENDOR)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ConstantsSLB.getErrorMessage(GlobalVariableClass.NEWADDNEOLDADD)));
            compareAddresscheck = TRUE;
        }
        
        //START D-3409 8/15/2015 Added By C. Lin - Invoke method on change for POP Start Date
        getSubscriptions();
        //END D-3409 8/15/2015 Added By C. Lin

    }
    //END D-1850 1/22/2015 Added By MGaelo - added validation rule: new address cannot be equal to old address   
    public void createAssignment() {
        //START D-1849 2/2/2015 Added By C. Lin - Change condition and remove change of address type: local to overseas, overseas to overseas, and overseas to local
        //START D-2258 3/9/2015 Added By C. Lin - CAT 1 - COA Change in Billing Address not reflected in SFDC/Zuora Billing Account
        if (changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLINGADD || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD) {
        //END D-2258 3/9/2015 Added By C. Lin
        //END D-1849 2/2/2015 Added By C. Lin
            Address_Assignment__c addressAssignment = new Address_Assignment__c();
            addressAssignment.Case__c = changeInAddress.Id;
            addressAssignment.Address__c = changeInAddress.New_Address__c;
            addressAssignment.Contact__c = changeInAddress.Contact_To_Update__c;
            addressAssignment.Effective_Date__c = changeInAddress.Effective_Date__c;
            
            //START D-2905 5/12/2015 Added By C. Lin - CCB for COA
            Set<Id> vendorSet = new Set<Id>();
            if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD){
                if(changeInAddress.New_Address__c != null){
                    vendorSet = getVendor(changeInAddress.New_Address__c);
                }
                
                if(vendorSet.size() == 1){
                    for(Id ven : vendorSet){
                        addressAssignment.Vendor__c = ven;
                    }
                }
            }
            //END D-2905 5/12/2015 Added By C. Lin
            
            addressAssignmentList.add(addressAssignment);
        }
        //START D-2258 3/9/2015 Added By C. Lin - CAT 1 - COA Change in Billing Address not reflected in SFDC/Zuora Billing Account
        else if (changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC) {
        //END D-2258 3/9/2015 Added By C. Lin
            //START D-2219 2/13/2015 Added By J.Sarion - Create Address Assignment for every subscription
            for (SubscriptionWrapper sub :subWrapperList) {
                if (sub.selectSub) {
                    Address_Assignment__c addressAssignment = new Address_Assignment__c();
                    addressAssignment.Case__c = changeInAddress.Id;
                    addressAssignment.Address__c = changeInAddress.New_Address__c;
                    addressAssignment.Contact__c = changeInAddress.Contact_To_Update__c;
                    addressAssignment.Effective_Date__c = changeInAddress.Effective_Date__c;
                    //START D-2001 2/2/2015 Added By C. Lin - Added Subscription_Vendor__c field if Account is Vendor Subscriber and Subscriptions are Vendor Subscriptions
                    //END D-2001 2/2/2015 Added By C. Lin
                    
                    if (!subList.isEmpty()) {
                        addressAssignment.Subscription__c = sub.subId;
                    }
                    if (!subVendorList.isEmpty()) {
                        addressAssignment.Subscription_Vendor__c = sub.subId;
                    }
                    
                    //START D-2905 5/12/2015 Added By C. Lin - CCB for COA
                    Set<Id> vendorSet = new Set<Id>();
                    if(changeInAddress.New_Address__c != null){
                        vendorSet = getVendor(changeInAddress.New_Address__c);
                    }
                    
                    //START D-2979 5/20/2015 Added By C. Lin - assign vendor for non magazine subscriptions only
                    if(!magazineSubSet.contains(sub.subId)){
                        if(vendorSet.size() == 1){
                            for(Id ven : vendorSet){
                                addressAssignment.Vendor__c = ven;
                            }
                        }
                    }
                    //END D-2979 5/20/2015 Added By C. Lin
                    //END D-2905 5/12/2015 Added By C. Lin
                    
                    addressAssignmentList.add(addressAssignment);
                }
            }
            //END: D-2219 2/13/2015 Added By J.Sarion                               
        }
    }
    
    public void populatePOPStartDate() {
        //START D-2219 2/13/2015 Added By J.Sarion - Populate POP Start Date
        Set<Id> subVendorIdSet = new Set<Id>();
        List<Subscription_Vendor__c> selectedSubVendorList = new List<Subscription_Vendor__c>();
        //START D-2223 2/16/2015 Added By C. Lin
        Set<Id> subsIdSet = new Set<Id>();
        List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();
        //START UD-0816 4/23/2015 Added By C. Lin - For Urgent Approval of COA
        if(!subWrapperList.isEmpty() && (changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.DELIVERYADDLOC || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.CHANGEVENDOR)){
        //END UD-0816 4/23/2015 Added By C. Lin
            for (SubscriptionWrapper sub :subWrapperList) {
                system.debug('>>>>>POP START DATE sub.subId ' + sub.subId);
                if (sub.selectSub) {
                    if (acc.RecordType.Name == 'Vendor Subscriber') {
                        system.debug('>>>>>sub.subId vendor subs ' + sub.subId);
                        subVendorIdSet.add(sub.subId);
                    }
                    else if (acc.RecordType.Name != 'Vendor') {
                        system.debug('>>>>>sub.subId direct ' + sub.subId);
                        subsIdSet.add(sub.subId);
                    }
                }
            }
            
            if (!subsIdSet.isEmpty()) {
                subscriptionList = [SELECT Main_Package_1__c FROM Zuora__Subscription__c WHERE Id IN :subsIdSet];
            }
            
            for (Zuora__Subscription__c sub :subscriptionList) {
                if (sub.Main_Package_1__c != null) {
                    packageIdSet.add(sub.Main_Package_1__c);
                }
            }
        }else{
            for (Zuora__Subscription__c sub :subList) {
                if (sub.Main_Package_1__c != null) {
                    packageIdSet.add(sub.Main_Package_1__c);
                }
            }
            
            for (Subscription_Vendor__c subVendor :subVendorList) {
                subVendorIdSet.add(subVendor.Id);
            }
        }
        //END D-2223
    
        if (!subVendorIdSet.isEmpty()) {
            selectedSubVendorList = [SELECT Id, (SELECT Id, Publication__r.Publication_Code__c FROM Subscription_Vendor_Publications__r) FROM Subscription_Vendor__c WHERE Id IN :subVendorIdSet];
        }
        
        for (Subscription_Vendor__c subVendor :selectedSubVendorList) {
            for (Subscription_Vendor_Publication__c subVendorPub :subVendor.Subscription_Vendor_Publications__r) {
                pubCodeSet.add(subVendorPub.Publication__r.Publication_Code__c);
            }
        }
        //END: D-2219 2/13/2015 Added By J.Sarion
        if (!packageIdSet.isEmpty()) {
            packageList = [SELECT Id, (SELECT Id, Product_Rate_Plan__c FROM Package_Items__r) FROM Package__c WHERE Id IN :packageIdSet];
        }
        
        for (Package__c pack :packageList) {
            for (Package_Item__c packageItem :pack.Package_Items__r) {
                prpIdSet.add(packageItem.Product_Rate_Plan__c);
            }
        }
        
        if (!prpIdSet.isEmpty()) {
            prpcList = [SELECT Id, PublicationCode__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__c IN:prpIdSet];
        }
        
        for (zqu__ProductRatePlanCharge__c prpc :prpcList) {
            pubCodeSet.add(prpc.PublicationCode__c);
        }
        
        if (!pubCodeSet.isEmpty()) {
            pubList = [SELECT Id, Earliest_Start_Date__c FROM Publication__c WHERE Publication_Code__c IN :pubCodeSet];
        }
        
        for (Publication__c pub :pubList) {
            if (pub.Earliest_Start_Date__c != null) {
                if (earliestStartDate == null) {
                    earliestStartDate = pub.Earliest_Start_Date__c;
                }
                //START D-2219 2/13/2015 Added By J.Sarion - Populate POP Start Date
                else if (pub.Earliest_Start_Date__c < earliestStartDate) {
                    earliestStartDate = pub.Earliest_Start_Date__c;
                }
                //END: D-2219 2/13/2015 Added By J.Sarion
            }
        }
    }
    //END: D-1124 1/14/2015 Added By J. Sarion
    
    //START D-0974 1/21/2015 Added By J. Sarion - Implement new process for COA
    public pageReference cancel() {
        PageReference pageRef;
        
        //START D-2956 5/18/2015 Added By C. Lin - Prevent error for cancel
        if(conId != null){
            pageRef = new pageReference('/' + conId);
        }else{
            pageRef = new pageReference('/' + acctId);
        }
        //END D-2956 5/18/2015 Added By C. Lin
        pageRef.setRedirect(true);
        return pageRef;
    }
    //END: D-0974 1/21/2015 Added By J. Sarion
    
    /* @description Create Case Subscriptions
     * @param BC
     * @param scope
     * @return void
     */
    //START D-1955 2/11/2015 Added By J.Sarion - Create Case Subscription / Case Subscription Vendor
    public void createCaseSubscription() {
        Case_Subscription__c caseSub;
        Case_Vendor_Subscription__c caseSubVendor;
        List<Case_Subscription__c> caseSubList = new List<Case_Subscription__c>();
        List<Case_Vendor_Subscription__c> caseSubVendorList = new List<Case_Vendor_Subscription__c>();

        for (SubscriptionWrapper sub :subWrapperList) {
            system.debug('>>>>>sub.subId ' + sub.subId);
            if (sub.selectSub) {
                if (acc.RecordType.Name == 'Vendor Subscriber') {
                    system.debug('>>>>>sub.subId ' + sub.subId);
                    caseSubVendor = new Case_Vendor_Subscription__c();
                    caseSubVendor.Subscription_Vendor__c = sub.subId;
                    caseSubVendor.Case__c = changeInAddress.Id;
                    caseSubVendor.Account__c = acctId;
                    //START UD-2206 9/24/15 Added By C. Lin - put address Id
                    caseSubVendor.Address__c = sub.recipientAddress;
                    //END UD-2206 9/24/15 Added By C. Lin
                    caseSubVendorList.add(caseSubVendor);
                }
                else if (acc.RecordType.Name != 'Vendor') {
                    system.debug('>>>>>sub.subId ' + sub.subId);
                    try {
                        caseSub = new Case_Subscription__c();
                        caseSub.Subscription__c = sub.subId;
                        caseSub.Case__c = changeInAddress.Id;
                        caseSub.Account__c = acctId;
                        //START UD-2206 9/17/15 AddedBy FrancisBenzon : put address Id
                        caseSub.Address__c = sub.recipientAddress;
                        //END UD-2206 9/17/15 AddedBy FrancisBenzon : put address Id
                        //START D-3709 10/12/2015 Added By C. Lin - Save Old Vendor Credit of Sub in Case Subscription
                        caseSub.Old_Vendor_Credit__c = sub.vendorCredit;
                        //END D-3709 10/12/2015 Added By C. Lin
                       //START: D-4285 1-14-2016 Added by Kristine Balaoing
                       caseSub.Old_Recipient_Contact__c = changeInAddress.Contact_To_Update__c;
                        caseSubList.add(caseSub);
                    }
                    catch (Exception e) {
                        system.debug('>>>>>error ' + e);
                    }
                }
            }
    //START D-2913 05/18/2015 Jason A./Sherwin P.
            //START D-3026 5/29/2015 Added By C. Lin - Add Create Case Sub for Change of Billing Address
            else if(changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLDELIVERYADD || changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.BILLINGADD){
            //START D-3026 5/29/2015 Added By C. Lin
                if (acc.RecordType.Name == 'Vendor Subscriber') {
                    system.debug('>>>>>sub.subId ' + sub.subId);
                    caseSubVendor = new Case_Vendor_Subscription__c();
                    caseSubVendor.Subscription_Vendor__c = sub.subId;
                    caseSubVendor.Case__c = changeInAddress.Id;
                    caseSubVendor.Account__c = acctId;
                    //START UD-2206 9/24/15 Added By C. Lin - put address Id
                    caseSubVendor.Address__c = sub.recipientAddress;
                    //END UD-2206 9/24/15 Added By C. Lin
                    caseSubVendorList.add(caseSubVendor);
                }
                else if (acc.RecordType.Name != 'Vendor') {
                    system.debug('>>>>>sub.subId ' + sub.subId);
                    try {
                        caseSub = new Case_Subscription__c();
                        caseSub.Subscription__c = sub.subId;
                        caseSub.Case__c = changeInAddress.Id;
                        caseSub.Account__c = acctId;
                        //START UD-2206 9/17/15 AddedBy FrancisBenzon : put address Id
                        caseSub.Address__c = sub.recipientAddress;
                        //END UD-2206 9/17/15 AddedBy FrancisBenzon : put address Id
                        //START D-3709 10/12/2015 Added By C. Lin - Save Old Vendor Credit of Sub in Case Subscription
                        caseSub.Old_Vendor_Credit__c = sub.vendorCredit;
                        //END D-3709 10/12/2015 Added By C. Lin
                       caseSub.Old_Recipient_Contact__c = changeInAddress.Contact_To_Update__c;
               //END: D-4285 1-14-2016 Added by Kristine Balaoing
                        caseSubList.add(caseSub);
                    }
                    catch (Exception e) {
                        system.debug('>>>>>error ' + e);
                    }
                }
                
                
            }
    //END D-2913 05/18/2015 Jason A./Sherwin P.
        }
        if (!caseSubList.isEmpty()) {
            try {
                insert caseSubList;
            }
            catch (DMLException e) {
                system.debug('>>>>>Error ' + e);
            }
        }
        if (!caseSubVendorList.isEmpty()) {
            try {
                insert caseSubVendorList;
            }
            catch (DMLException e) {
                system.debug('>>>>>Error ' + e);
            }
        }
    }
    //END: D-1955 2/11/2015 Added By J.Sarion
    
    //START D-2905 05/12/2015 Added by J. Sarion - Check Vendor if applicable to Postal Code
    public void checkVendor() {
        noVendorAllocated = false;
        invalidVendor = false;
        
        //START D-2979 5/20/2015 Added By C. Lin - Change String to GlobalVariableClass
        if (changeInAddress.Contact_To_Update__c != null && changeInAddress.Change_of_Address_Type__c == GlobalVariableClass.CHANGEVENDOR) {
        //END D-2979 5/20/2015 Added By C. Lin
            if (conIdToContactMap.containsKey(changeInAddress.Contact_To_Update__c)) {
                Contact con = conIdToContactMap.get(changeInAddress.Contact_To_Update__c);
                if (postalCodeToVendorMap.containsKey(con.Address__r.Postal_Code__c)) {
                    if(changeInAddress.Vendor__c != null){
                        if (!(postalCodeToVendorMap.get(con.Address__r.Postal_Code__c).contains(changeInAddress.Vendor__c))) {
                            invalidVendor = true;
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Selected Vendor not applicable for Postal Code: ' + con.Address__r.Postal_Code__r.Name));
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Vendor selected is not allocated to the postal code of the selected contact, please perform vendor allocation.'));
                            
                        }
                    }
                }
                else {
                    noVendorAllocated = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Postal Code of Contact To Update does not have any Vendor yet.'));
                }
            }
        }
        else {
            changeInAddress.Vendor__c = null;
        }
    }
    
    public void getVendorPerPostal() {
        Set<Id> postalCodeIdSet = new Set<Id>();
        
        for (Contact con : [SELECT Id, Address__r.Postal_Code__c, Address__r.Postal_Code__r.Name FROM Contact WHERE Recipient_Indicator__c = true AND AccountId =:acctId]) {
            postalCodeIdSet.add(con.Address__r.Postal_Code__c);
            conIdToContactMap.put(con.Id, con);
        }
        
        for (Vendor_Allocation__c venAlloc : [SELECT Id, SingPost_Address__c, Vendor_Account__c FROM Vendor_Allocation__c WHERE SingPost_Address__c IN :postalCodeIdSet AND Status__c = 'active']) {
            if (postalCodeToVendorMap.containsKey(venAlloc.SingPost_Address__c))
                postalCodeToVendorMap.get(venAlloc.SingPost_Address__c).add(venAlloc.Vendor_Account__c);
            else
                postalCodeToVendorMap.put(venAlloc.SingPost_Address__c, new Set<ID> {venAlloc.Vendor_Account__c});
        }
    }
    //For Subscription Validation onclick
    public void checkExistingVendor() {
        if (subIdToSubscriptionWrapperMap.containsKey(myId)) {
            if (subIdToVendorMap.containsKey(myId)) {
                if (subIdToVendorMap.get(myId) == changeInAddress.Vendor__c) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Selected vendor is already the existing vendor of the subscription.'));
                    subIdToSubscriptionWrapperMap.get(myId).selectSub = false;
                }
            }
        }
    }
    //END D-2905 05/12/2015 Added by J. Sarion - Check Vendor if applicable to Postal Code
    
    //START D-2905 5/12/2015 Added By C. Lin - CCB for COA
    public Set<Id> getVendor(Id addressId) {
        Set<Id> vendorIdSet = new Set<Id>();
        Address__c address = [SELECT Id, Postal_Code__c FROM Address__c WHERE Id = :addressId];
        if (address.Postal_Code__c != null) {
            for (Vendor_Allocation__c venAlloc : [SELECT Id, SingPost_Address__c, Vendor_Account__c FROM Vendor_Allocation__c WHERE SingPost_Address__c = :address.Postal_Code__c AND Status__c = 'active'])
            {
                if (venAlloc.Vendor_Account__c != null){
                    vendorIdSet.add(venAlloc.Vendor_Account__c);
                }
            }
        }
        return vendorIdSet;
    }
    //END D-2905 5/12/2015 Added By C. Lin
    //START D-2979 5/20/2015 Added By C. Lin - Identify Magazine Subscriptions
    public void getMagazineSubs(){
        List<Zuora__Subscription__c> subscripList = new List<Zuora__Subscription__c>();
        Set<Id> setPackId = new Set<Id>();
        List<Package_Item__c> packItemList = new List<Package_Item__c>();
        Set<Id> setPackageId = new Set<Id>();
        List<Subscription_Vendor__c> subscripVenList = new List<Subscription_Vendor__c>();
        Set<Id> subscripVenIdSet = new Set<Id>();
        List<Subscription_Vendor_Publication__c> subVenPubList = new List<Subscription_Vendor_Publication__c>();
        
        subscripList = [SELECT Id, Name, Main_Package_1__c FROM Zuora__Subscription__c WHERE Zuora__Account__c =:acctId AND Zuora__Status__c = 'Active' AND Subscription_Type_1__c = 'Publication' AND ((Zuora__SubscriptionEndDate__c > TODAY AND Zuora__TermSettingType__c = 'TERMED') OR (Zuora__SubscriptionEndDate__c = NULL AND Zuora__TermSettingType__c = 'EVERGREEN'))];
        
        for(Zuora__Subscription__c sub : subscripList){
            if(sub.Main_Package_1__c != null){
                setPackId.add(sub.Main_Package_1__c);
            }
        }
        
        packItemList = [SELECT Id, Name, Package__c FROM Package_Item__c WHERE Package__c IN : setPackId AND Is_Magazine__c = true];
        
        for(Package_Item__c packItem : packItemList){
            if(packItem.Package__c != null){
                setPackageId.add(packItem.Package__c);
            }
        }
        
        for(Zuora__Subscription__c s : subscripList){
            if(setPackageId.contains(s.Main_Package_1__c)){
                magazineSubSet.add(s.Id);
            }
        }
        
        subscripVenList = [SELECT ID, Name FROM Subscription_Vendor__c WHERE Account__c =:acctId AND Status__c = 'Active'];
        
        for(Subscription_Vendor__c subVen : subscripVenList){
            subscripVenIdSet.add(subVen.Id);
        }
        
        subVenPubList = [SELECT Id, Name, Subscription_Vendor__c, Publication__c, Publication__r.Product_Category__c FROM Subscription_Vendor_Publication__c WHERE Subscription_Vendor__c IN :subscripVenIdSet];
        
        for(Subscription_Vendor_Publication__c svp : subVenPubList){
            if(svp.Publication__r.Product_Category__c == 'Magazine'){
                magazineSubSet.add(svp.Subscription_Vendor__c);
            }
        }
    }
    //END D-2979 5/20/2015 Added By C. Lin
}