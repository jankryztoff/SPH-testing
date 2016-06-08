public class CaseEditOverrideController {
    /**
     * Class Name: CaseEditOverrideController
     * @author: Karl Tan
     * Date: 
     * Requirement/Project Name: CRSM Project
     * @description Controller for CaseEditOverride VF page
     * 
     */

    Case thisCase;
    String passedRecordType;
    Id compMagId;
    Id compNewsId;
    Id changePaymentId;
    Id changeCreditCard;
    Id bypassCreditCard;
    Id adjustmentsRType;
    Id changeAddressId;
    Id startSubId;
    Id stopSubId;
    Id changeParticularsId;
    Id resetPassId;
    Id retentionId;
    Id tempStopId;
    Id refundId;
    Id digitalId;
    Id enquiryId;
    Id accountId;    
    String account_Vendor;
    String account_VendorSubscriber;
    //String accountId;
    //vars
    //Account acct;
    //START UD-3293 25Nov2015 Added By C. Lin - Changing Record Type from Enquiry leads to New Pages
    String parentId;
    Id recordTypeId;
    Id changeOfSubId;
    Id renewalRecType;
    Id account_DirectCorporate;
    Id account_DirectIndividual;
    Id account_DirectSphInterDivision;
    Id vendorStopRequestId;
    //END UD-3293 25Nov2015 Added By C. Lin
    
    public CaseEditOverrideController (ApexPages.StandardController controller) {
        //accountId = ApexPages.currentPage().getParameters().get(GlobalVariableClass.DEFACCID);
        Id recordId = controller.getId();
        passedRecordType = ApexPages.currentPage().getParameters().get('RecordType');
        compMagId = ConstantsSLB.getKeyId('Case_Complaint Magazine');
        compNewsId = ConstantsSLB.getKeyId('Complaint_Newspaper');
        changePaymentId = ConstantsSLB.getKeyId('Case_Change of Payment Type');
        changeCreditCard = ConstantsSLB.getKeyId('Case_Change of Credit Card');
        bypassCreditCard = ConstantsSLB.getKeyId('Case_Bypass Credit Card');
        adjustmentsRType = ConstantsSLB.getKeyId('Case_Adjustments');
        changeAddressId = ConstantsSLB.getKeyId('Case_Change in Address');
        startSubId = ConstantsSLB.getKeyId('Start Subscription');
        stopSubId = ConstantsSLB.getKeyId('Case_Stop');
        changeParticularsId = ConstantsSLB.getKeyId('Case_Particulars');
        resetPassId = ConstantsSLB.getKeyId('Case_Reset Password');
        retentionId = ConstantsSLB.getKeyId('Case_Retention');
        tempStopId = ConstantsSLB.getKeyId('Case_Temp Stop');
        refundId = ConstantsSLB.getKeyId('Case_Refund');
        digitalId = ConstantsSLB.getKeyId('Case_Digital'); 
        enquiryId  = ConstantsSLB.getKeyId('Case_Enquiry');
        account_Vendor = GlobalVariableClass.VENDOR;
        account_VendorSubscriber = GlobalVariableClass.VENDORSUB;
        
        //START UD-3293 25Nov2015 Added By C. Lin - Changing Record Type from Enquiry leads to New Pages
        renewalRecType = ConstantsSLB.getKeyId(GlobalVariableClass.CASERENEWAL);
        changeOfSubId = ConstantsSLB.getKeyId(GlobalVariableClass.CASECHANGESUB);
        account_DirectCorporate = ConstantsSLB.getKeyId(GlobalVariableClass.ACCDIRCORP);
        account_DirectIndividual = ConstantsSLB.getKeyId(GlobalVariableClass.ACCDIRINDIVIDUAL);
        account_DirectSphInterDivision = ConstantsSLB.getKeyId(GlobalVariableClass.ACCDIRSPH);
        vendorStopRequestId  = ConstantsSLB.getKeyId('Case_Vendor Stop Request');
        //END UD-3293 25Nov2015 Added By C. Lin
        
        try {
			//START:Code Review Implementation 2/18/15 Added by Manolo Valeña - Checks if recordId is not equal to null.
			if(recordId != null){
				//START UD-1152 5/8/2015 Added by Manolo Valena - Added Sub Status field to the query.
                //START UD-3293 25Nov2015 Added By C. Lin - Add Account.RecordTypeId
                thisCase = [Select Account_Record_Type__c, Id, RecordTypeId, RecordType.Name, AccountId, Order__c, Order__r.Status__c, Sub_Status__c, Account.RecordTypeId FROM Case WHERE Id = :recordId];
                //END UD-3293 25Nov2015 Added By C. Lin
				//END UD-1152 5/8/2015 Added by Manolo Valena
			}
			//END:Code Review Implementation 2/18/15 Added by Manolo Valeña
		}
        catch(QueryException e) {
            thisCase = new Case();
            Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }
    
    public PageReference redirect() {
        PageReference pgRef;
        System.debug(passedRecordType);
        
        //set recordtype value, if RecordTYpe Parameter is passed, get it from URL, else, get it from Case record
        //Id recordTypeId; //START/END UD-3293 25Nov2015 Added By C. Lin - Remove
		//START:Code Review Implementation 2/18/15 Added by Manolo Valeña - Checks if thisCase is not equal to null.
        
        //START UD-3293 25Nov2015 Added By C. Lin - Changing Record Type from Enquiry leads to New Pages
        Boolean changeFromEnquiry = false;
        //END UD-3293 25Nov2015 Added By C. Lin
        
		if(thisCase != null){
            //START D-3293 23Nov2015 Added By C. Lin - Add validation if Account is null. Changing Record Type from Enquiry leads to New Pages
            
            if(passedRecordType != NULL && passedRecordType != '' && thisCase.RecordTypeId != null){
                recordTypeId = (Id) passedRecordType;
                
                if(thisCase.RecordTypeId == passedRecordType){
                    changeFromEnquiry = false;
                }else if(thisCase.RecordTypeId == enquiryId && passedRecordType != enquiryId){
                    changeFromEnquiry = true;
                    parentId = ApexPages.currentPage().getParameters().get('Id');
                }
            }else if(thisCase.RecordTypeId != null){
                changeFromEnquiry = false;
                recordTypeId = thisCase.RecordTypeId;
            }
            
            if(changeFromEnquiry == false){
                //Normal editing of Case
			if(recordTypeId == enquiryId) {
				return new PageReference('/' + thisCase.Id + '/e?nooverride=1&RecordType=' + recordTypeId + '&retURL=' + '/' + thisCase.Id);
			}
			else if(recordTypeId == resetPassId) {
				return new PageReference('/' + thisCase.Id + '/e?nooverride=1&RecordType=' + recordTypeId + '&retURL=' + '/' + thisCase.Id);
			}
			else if(recordTypeId == digitalId) {
				return new PageReference('/' + thisCase.Id + '/e?nooverride=1&RecordType=' + recordTypeId + '&retURL=' + '/' + thisCase.Id);
			}
			else if(recordTypeId == tempStopId) {
				//START UD-0300 4/29/2015 Added By C. Lin - Disable editing of Temp Stop Case manually
                return new PageReference('/apex/ErrorPage?id=' + thisCase.Id + '&RecordType=' + recordTypeId +  '&retURL=' + '/' + thisCase.Id + '&msg=' + 'TempStopEditErrorMessage');
                //END UD-0300 4/29/2015 Added By C. Lin
			}
			else if(recordTypeId == compNewsId) {
				return new PageReference('/apex/ComplaintNewspaperPage?id=' + thisCase.Id + '&RecordType=' + recordTypeId +  '&retURL=' + '/' + thisCase.Id);
			}
			else if(recordTypeId == stopSubId) {
				//START UD-1152 5/8/2015 Added by Manolo Valena - Added condition to redirect to Order Entry Page when rejected Stop Case is edited.
                if(thisCase.Sub_Status__c != GlobalVariableClass.SUB_STATUS_URGENT_STOP_REJECTED && 
                   thisCase.Sub_Status__c != GlobalVariableClass.SUB_STATUS_WAIVED_REJECTED) {
                    return new PageReference('/apex/StopSubEditPage_Case?id=' + thisCase.Id + '&RecordType=' + recordTypeId + '&retURL=' + '/' + thisCase.Id);            
                }
                else {
                    return new PageReference('/apex/StopSub_Order_Entry_Direct_Edit?accountId=' + thisCase.AccountId + '&RecordType=' + recordTypeId + '&orderId=' + thisCase.Order__c);
                }
                //END UD-1152 5/8/2015 Added by Manolo Valena
			}
			else if(recordTypeId == changeCreditCard) {
				return new PageReference('/apex/CustomHpmPageCase?id=' + thisCase.Id + '&RecordType=' + recordTypeId + '&retURL=' + '/' + thisCase.Id);
			}
			else if(recordTypeId == changePaymentId) {
				return new PageReference('/' + thisCase.Id + '/e?nooverride=1&RecordType=' + recordTypeId + '&retURL=' + '/' + thisCase.Id);
			}            
			else if(recordTypeId == adjustmentsRType) {
				return new PageReference('/apex/AdjustmentsCaseEditPage?id=' + thisCase.Id + '&RecordType=' + recordTypeId + '&retURL=' + '/' + thisCase.Id);
			}
			else if(recordTypeId == changeAddressId) {
				return new PageReference('/apex/ChangeInAddressCaseEditPage?id=' + thisCase.Id + '&RecordType=' + recordTypeId + '&retURL=' + '/' + thisCase.Id);
			}          
			else if(recordTypeId == compMagId){
				return new PageReference('/apex/ComplaintMagazineEditPage?id=' + thisCase.Id + '&RecordType=' + recordTypeId + '&retURL=' + '/' + thisCase.Id);            
			}
			else if(recordTypeId == retentionId){
				return new PageReference('/' + thisCase.Id + '/e?nooverride=1&RecordType=' + recordTypeId + '&retURL=' + '/' + thisCase.Id);            
			}        
			else if(recordTypeId == changeParticularsId){
				return new PageReference('/' + thisCase.Id + '/e?nooverride=1&RecordType=' + recordTypeId + '&retURL=' + '/' + thisCase.Id);            
			}
			/*e commenting out - duplicate
			else if(recordTypeId == tempStopId){
				return new PageReference('/' + thisCase.Id + '/e?nooverride=1&RecordType=' + recordTypeId + '&retURL=' + '/' + thisCase.Id);           
			}                 
			else if(recordTypeId == digitalId){
				return new PageReference('/' + thisCase.Id + '/e?nooverride=1&RecordType=' + recordTypeId + '&retURL=' + '/' + thisCase.Id);           
			}
			*/ 
			else if(recordTypeId == refundId){
				return new PageReference('/' + thisCase.Id + '/e?nooverride=1&RecordType=' + recordTypeId + '&retURL=' + '/' + thisCase.Id);         
			} 
			
			else if(recordTypeId == startSubId ){ 
				
				if(thisCase.Account_Record_Type__c == account_Vendor || thisCase.Account_Record_Type__c == account_VendorSubscriber){            
					return new PageReference('/' + thisCase.Id + '/e?nooverride=1&RecordType=' + recordTypeId + '&retURL=' + '/' + thisCase.Id);    
				}
				else{
					//Start PPancho No data saved if we click EDIT on the Case after Order submission
					//START: D-1246 12/17/2014 Added by Kristine Campang - added additional if condition to handle page landing
					if(thisCase.Order__c != null && 'New' != thisCase.Order__r.Status__c && 'Draft' != thisCase.Order__r.Status__c){
						return new PageReference('/apex/SM_StartSubscriptionDetail?id=' + thisCase.Order__c + '&RecordType=' + recordTypeId + '&retURL=' + '/' + thisCase.Id + '&accountId=' + thisCase.AccountId + '&status=' + thisCase.Order__r.Status__c);
					}
					else if(thisCase.Order__c == null){
						return new PageReference('/apex/SM_StartSubscriptionEntry?' + 'RecordType=' + recordTypeId + '&accountId=' + thisCase.AccountId);
					}
					else{
						return new PageReference('/apex/SM_StartSubscriptionEntry?id=' + thisCase.Order__c + '&RecordType=' + recordTypeId + '&retURL=' + '/' + thisCase.Id + '&accountId=' + thisCase.AccountId); 
					}
					
					//END: D-1246 12/17/2014 Added by Kristine Campang
					//End PPancho
				}             
			}
										 
			else {
				return new PageReference('/' + thisCase.Id + '/e?nooverride=1&RecordType=' + recordTypeId + '&retURL=' + '/' + thisCase.Id);
			}
            }else{
                if(thisCase.AccountId != null){
                    //changeFromEnquiry
                    if(recordTypeId == digitalId) {
                        return new PageReference('/500/e?nooverride=1&RecordType=' + recordTypeId + relatedCaseIds() + '&retURL=/' + thisCase.Id);
                    }
                    else if(recordTypeId == compMagId){
                        return new PageReference('/apex/ComplaintMagazineEditPage?RecordType=' + recordTypeId + relatedCaseIds() + '&retURL=' + '/' + thisCase.Id);
                    }
                    else if(recordTypeId == compNewsId) {
                        return new PageReference('/apex/ComplaintNewspaperPage?RecordType=' + recordTypeId + relatedCaseIds() + '&retURL=' + '/' + thisCase.Id);
                    }
                    else if(recordTypeId == changeAddressId){
                        return new PageReference('/apex/ChangeInAddressCaseNewPage?RecordType=' + recordTypeId + relatedCaseIds() + '&retURL=' + '/' + thisCase.Id);
                    }
                    else if(recordTypeId == changePaymentId){
                        return new PageReference('/apex/ChangeOfPaymentType?RecordType=' + recordTypeId + relatedCaseIds() + '&retURL=' + '/' + thisCase.Id);
                    }
                    else if(recordTypeId == renewalRecType){
                        return new PageReference('/apex/SM_RenewalOfSubscriptionEntry?RecordType=' + recordTypeId  + relatedCaseIds() + '&retURL=' + '/' + thisCase.Id);
                    }
                    else if(recordTypeId == changeOfSubId){
                        return new PageReference('/apex/SM_ChangeOfSubscriptionEntry?RecordType=' + recordTypeId  + relatedCaseIds() + '&retURL=' + '/' + thisCase.Id);
                    }
                    else if(recordTypeId == startSubId ){
                        if(thisCase.Account_Record_Type__c == account_Vendor || thisCase.Account_Record_Type__c == account_VendorSubscriber){
                            return new PageReference( '/apex/CreateVendorOrderEntry?RecordType=' + recordTypeId + relatedCaseIds() + '&retURL=' + '/' + thisCase.Id);    
                        }
                        else{
                            return new PageReference('/apex/SM_StartSubscriptionEntry?RecordType=' + recordTypeId + relatedCaseIds() + '&retURL=' + '/' + thisCase.Id);
                        }
                    }
                    else if(recordTypeId == stopSubId) {
                        if(thisCase.Account_Record_Type__c == account_Vendor || thisCase.Account_Record_Type__c == account_VendorSubscriber){
                            return new PageReference('/apex/StopSubOrderEntry_Vendor_Edit?RecordType=' + recordTypeId + relatedCaseIds() + '&retURL=' + '/' + thisCase.Id);
                        }else{
                            return new PageReference('/apex/StopSub_Order_Entry_Direct_Edit?RecordType=' + recordTypeId + relatedCaseIds() + '&retURL=' + '/' + thisCase.Id);
                        }
                    }
                    else if(recordTypeId == tempStopId) {
                        if (thisCase.Account.RecordTypeId == account_DirectIndividual || thisCase.Account.RecordTypeId == account_DirectCorporate || thisCase.Account.RecordTypeId == account_DirectSphInterDivision) {
                            return new PageReference('/apex/TempStopDirect?RecordType=' + recordTypeId + relatedCaseIds() + '&retURL=' + '/' + thisCase.Id);
                        }
                        
                        else if (thisCase.Account_Record_Type__c == account_VendorSubscriber || thisCase.Account_Record_Type__c == account_Vendor){
                            return new PageReference('/apex/VendorTempStopSubs?RecordType=' + recordTypeId + relatedCaseIds() + '&retURL=' + '/' + thisCase.Id);
                        }
                    }
                    else if(recordTypeId == adjustmentsRType) {
                        return new PageReference('/apex/AdjustmentsCaseEditPage?RecordType=' + recordTypeId + relatedCaseIds() + '&retURL=' + '/' + thisCase.Id);
                    }
                    else if(recordTypeId == bypassCreditCard) {
                        return new PageReference('/500/e?nooverride=1&RecordType=' + recordTypeId + relatedCaseIds() + '&retURL=/' + thisCase.Id);
                    }
                    else if(recordTypeId == changeCreditCard) {
                        return new PageReference('/500/e?nooverride=1&RecordType=' + recordTypeId + relatedCaseIds() + '&retURL=/' + thisCase.Id);
                    }
                    else if(recordTypeId == changeParticularsId){
                        return new PageReference('/500/e?nooverride=1&RecordType=' + recordTypeId + relatedCaseIds() + '&retURL=/' + thisCase.Id);
                    }
                    else if(recordTypeId == refundId){
                        return new PageReference('/500/e?nooverride=1&RecordType=' + recordTypeId + relatedCaseIds() + '&retURL=/' + thisCase.Id);
                    }
                    else if(recordTypeId == vendorStopRequestId){
                        return new PageReference('/500/e?nooverride=1&RecordType=' + recordTypeId + relatedCaseIds() + '&retURL=/' + thisCase.Id);
                    }
                }else{
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Account is needed before changing the Record Type. Please populate the Account before changing the Record Type.'));
                }
            }
            //END D-3293 23Nov2015 Added By C. Lin
		}
		return null;
		//END:Code Review Implementation 2/18/15 Added by Manolo Valeña
    }
    
    //START UD-3293 25Nov2015 Added By C. Lin - Changing Record Type from Enquiry leads to New Pages
    public string relatedCaseIds() 
    {
        String pRef;
        String accId;
        String conId;
        Case cas;
        
        if(parentId != null && parentId != '') 
        {
            cas = [SELECT accountId, contactId FROM Case Where Id =: parentId limit 1];
            accId = cas.accountId;
            conId = cas.contactId;        
        } 
        if(recordTypeId == digitalId || recordTypeId == bypassCreditCard || recordTypeId == changeCreditCard || recordTypeId == changeParticularsId || recordTypeId == refundId || recordTypeId == vendorStopRequestId)
        {
            pRef = (accId != null && accId != '' && accId != 'null' ? '&def_account_id=' + accId : '') + 
                (conId != null && conId != 'null' && conId != '' ? '&def_contact_id=' + conId : '') + 
                (parentId != null && parentId != 'null' && parentId != '' ? '&def_parent_id=' + parentId : ''); 
        }
        else 
        {
            pRef = (accId != null && accId != '' && accId != 'null' ? '&accountId=' + accId : '') + 
                (conId != null && conId != 'null' && conId != '' ? '&contactId=' + conId : '') + 
                (parentId != null && parentId != 'null' && parentId != '' ? '&def_parent_id=' + parentId : ''); 
        }
        
        return pRef;
    }
    //END UD-3293 25Nov2015 Added By C. Lin
}