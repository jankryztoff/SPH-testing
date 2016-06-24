public class PaperFeeCalculator {

    public static boolean isWithValidSpcs;
    
    public static decimal compute(list<Case_Subscription__c> caseSubscriptionListParam) {
        
        decimal totalPaperFee = 0.0;
        decimal paperFee;
        map<id, map<string, decimal>> subscriptionId_uom_price = new map<id, map<string, decimal>>();
        map<id, map<string, string>> subscriptionId_pubCode_uom = new map<id, map<string, string>>();
        map<string, decimal> uom_price = new map<string, decimal>();
        map<string, string> pubCode_uom = new map<string, string>();
        map<string, id> pubCode_publicationId = new map<string, id>();
        map<id, boolean> caseId_isReplacedByCourier = new map<id, boolean>();   // Start/End UD-3208 09Nov15 JohnD
        map<id, boolean> caseId_isReplacedByVendor = new map<id, boolean>();  // Start/End UD-3208 12Nov15 FrancisBenzon
        //START UD-3103 10/15/2015 Added by Manolo Valena
        map<id, List<Case_Subscription__c>> subscriptionId_caseSubscription = new map<id, List<Case_Subscription__c>>();
        //END UD-3103 10/15/2015 Added by Manolo Valena
        
        map<id, boolean> subscriptionId_isWithVAlidSpcs = new map<id, boolean>();
        
        //START UD-3103 10/15/2015 Added by Manolo Valena - To be removed.
        //Case_Subscription__c caseSubscription = new Case_Subscription__c(); 
        //END UD-3103 10/15/2015 Added by Manolo Valena
        
        list<Case_Vendor_Fee__c> caseVendorFeeList = new list<Case_Vendor_Fee__c>();
        Case_Vendor_Fee__c caseVendorFee;
        set<id> subscriptionIdSet = new set<id>();
        set<string> publicationCodeSet = new set<string>();
        set<string> uomCopySet = new set<string>();
        integer creditCopies = 0;
        integer numberOfCopies = 0;
        integer replacementCopies = 0; // Start/End UD-3208 12Nov15 FrancisBenzon : variable
        
        uomCopySet.add(GlobalVariableClass.UOM_COPYWEEKDAY);
        uomCopySet.add(GlobalVariableClass.UOM_COPYSAT);
        uomCopySet.add(GlobalVariableClass.UOM_COPYSUN);
        
        for (Case_Subscription__c cs : caseSubscriptionListParam) {
            subscriptionIdSet.add(cs.Subscription__c);
            
            //START UD-3103 10/15/2015 Added by Manolo Valena
            if(subscriptionId_caseSubscription.containsKey(cs.Subscription__c)) {
                subscriptionId_caseSubscription.get(cs.Subscription__c).add(cs);
            }
            else {
                subscriptionId_caseSubscription.put(cs.Subscription__c, new List<Case_Subscription__c> {cs});
            }
            //END UD-3103 10/15/2015 Added by Manolo Valena
            
            subscriptionId_isWithValidSpcs.put(cs.Subscription__c, false);
            
            caseId_isReplacedByCourier.put(cs.Case__c, false);  // Start/End UD-3208 09Nov15 JohnD - initialized variable
            caseId_isReplacedByVendor.put(cs.Case__c, false);  // Start/End UD-3208 12Nov15 FrancisBenzon - initialized variable
        }
        
        // Start UD-3208 09Nov15 JohnD - assigned value
        //START UD-3208 12Nov15 FrancisBenzon - added replacedByVendor, added value
        for (Case tmp : [select Id, Replaced_by_Courier__c, Replaced_by_Vendor__c from Case where Id in :caseId_isReplacedByCourier.keySet()]) {
            caseId_isReplacedByCourier.put(tmp.Id, tmp.Replaced_by_Courier__c);
            caseId_isReplacedByVendor.put(tmp.Id, tmp.Replaced_by_Vendor__c);
        }
        //END UD-3208 12Nov15 FrancisBenzon - added replacedByVendor, added value
        // End UD-3208 09Nov15 JohnD - assigned value
        
        for (Zuora__SubscriptionProductCharge__c spc : [select Zuora__Subscription__c, Zuora__Price__c, Zuora__UOM__c, 
                PublicationCode__c from Zuora__SubscriptionProductCharge__c where Zuora__Subscription__c in :subscriptionIdSet 
                and Zuora__UOM__c in :uomCopySet]) {
            
            if (spc.PublicationCode__c != null && spc.Zuora__UOM__c != null && spc.Zuora__Price__c !=  null) {

                uom_price = new map<string, decimal>();
                pubCode_uom = new map<string, string>();
                
                if (subscriptionId_uom_price.get(spc.Zuora__Subscription__c) != null) {
                    uom_price = subscriptionId_uom_price.get(spc.Zuora__Subscription__c);
                }
                
                uom_price.put(spc.Zuora__UOM__c, spc.Zuora__Price__c);
                subscriptionId_uom_price.put(spc.Zuora__Subscription__c, uom_price);
                
                if (subscriptionId_pubCode_uom.get(spc.Zuora__Subscription__c) != null) {
                    pubCode_uom = subscriptionId_pubCode_uom.get(spc.Zuora__Subscription__c);
                }
                
                pubCode_uom.put(spc.PublicationCode__c, spc.Zuora__UOM__c);
                subscriptionId_pubCode_uom.put(spc.Zuora__Subscription__c, pubCode_uom);
                publicationCodeSet.add(spc.PublicationCode__c);
                
                subscriptionId_isWithValidSpcs.put(spc.Zuora__Subscription__c, true);
            }
        }

        for (Publication__c pub : [select Id, Publication_Code__c from Publication__c 
                where Publication_Code__c in :publicationCodeSet]) {
            
            pubCode_publicationId.put(pub.Publication_Code__c, pub.Id);
        }
        
        for (Zuora__Subscription__c sub : [select Id, Frequency_1__c, Order_Line_Item_Number_1__r.Ph_e__c, 
                Order_Line_Item_Number_1__r.Ph_d__c from Zuora__Subscription__c where Id in :subscriptionIdSet]) {
                
            //START UD-3103 10/15/2015 Added by Manolo Valena
            if(subscriptionId_caseSubscription.containsKey(sub.Id)) {   
                for(Case_Subscription__c caseSubscription : subscriptionId_caseSubscription.get(sub.Id)) {
                    //START UD-3061 10/9/2015 Added by Manolo Valena - Updated if-else condition.
                    if(caseSubscription.Complaint_Copies__c != null && caseSubscription.Complaint_Copies__c > 0) {
                        numberOfCopies = (integer)caseSubscription.Complaint_Copies__c;
                    } 
                    else {
                        numberOfCopies = 0;
                    }
                    //END UD-3061 10/9/2015 Added by Manolo Valena
                    
                    uom_price = subscriptionId_uom_price.get(sub.Id);
                    
                    if (subscriptionId_pubCode_uom.get(sub.Id) != null) {
                        
                        pubCode_uom = subscriptionId_pubCode_uom.get(sub.Id);
                        
                        for (string pubCode : pubCode_uom.keySet()) {
                            
                            PublicationIssueWrapper publicationIssue = UsageHelper.IssueCalculation(pubCode, caseSubscription.Complaint_From__c, caseSubscription.Complaint_To__c, sub, numberOfCopies);
                            
                            //START UD-3061 10/9/2015 Added by Manolo Valena
                            PublicationIssueWrapper publicationIssueReplacement;
                            if(caseSubscription.Replace_From__c != null && caseSubscription.Replace_To__c != null && (caseSubscription.Replacement_Copies__c != null && caseSubscription.Replacement_Copies__c != 0)) { 
                                publicationIssueReplacement = UsageHelper.IssueCalculation(pubCode, caseSubscription.Replace_From__c, caseSubscription.Replace_To__c, sub, (integer)caseSubscription.Replacement_Copies__c);
                            }
                            //END UD-3061 10/9/2015 Added by Manolo Valena
                            
                            paperFee = 0.0;
                            //START UD-3215 11/10/15 AddedBy FrancisBenzon : charge everything if replaced by courier - [paperFee]
                            if (publicationIssue.weekday_no_of_copies > 0) {
                                //START UD-3061 10/9/2015 Added by Manolo Valena
                                if(caseSubscription.Replace_From__c != null && caseSubscription.Replace_To__c != null && (caseSubscription.Replacement_Copies__c != null && caseSubscription.Replacement_Copies__c != 0) && caseId_isReplacedByCourier.get(caseSubscription.Case__c) == false) {
                                    totalPaperFee += (publicationIssue.weekday_no_of_copies - publicationIssueReplacement.weekday_no_of_copies) * uom_price.get(GlobalVariableClass.UOM_COPYWEEKDAY);
                                    paperFee += (publicationIssue.weekday_no_of_copies - publicationIssueReplacement.weekday_no_of_copies) * uom_price.get(GlobalVariableClass.UOM_COPYWEEKDAY);
                                }
                                else {
                                    totalPaperFee += publicationIssue.weekday_no_of_copies * uom_price.get(GlobalVariableClass.UOM_COPYWEEKDAY);
                                    paperFee += publicationIssue.weekday_no_of_copies * uom_price.get(GlobalVariableClass.UOM_COPYWEEKDAY);
                                }
                                //END UD-3061 10/9/2015 Added by Manolo Valena
                            }
                            
                            if (publicationIssue.sat_no_of_copies > 0) {
                                //START UD-3061 10/9/2015 Added by Manolo Valena
                                if(caseSubscription.Replace_From__c != null && caseSubscription.Replace_To__c != null && (caseSubscription.Replacement_Copies__c != null && caseSubscription.Replacement_Copies__c != 0) && caseId_isReplacedByCourier.get(caseSubscription.Case__c) == false) {
                                    totalPaperFee += (publicationIssue.sat_no_of_copies - publicationIssueReplacement.sat_no_of_copies) * uom_price.get(GlobalVariableClass.UOM_COPYSAT);
                                    paperFee += (publicationIssue.sat_no_of_copies - publicationIssueReplacement.sat_no_of_copies) * uom_price.get(GlobalVariableClass.UOM_COPYSAT);
                                }
                                else {
                                    totalPaperFee += publicationIssue.sat_no_of_copies * uom_price.get(GlobalVariableClass.UOM_COPYSAT);
                                    paperFee += publicationIssue.sat_no_of_copies * uom_price.get(GlobalVariableClass.UOM_COPYSAT);
                                }
                                //END UD-3061 10/9/2015 Added by Manolo Valena
                            }
                            
                            if (publicationIssue.sun_no_of_copies > 0) {
                                //START UD-3061 10/9/2015 Added by Manolo Valena
                                if(caseSubscription.Replace_From__c != null && caseSubscription.Replace_To__c != null && (caseSubscription.Replacement_Copies__c != null && caseSubscription.Replacement_Copies__c != 0) && caseId_isReplacedByCourier.get(caseSubscription.Case__c) == false) {
                                    totalPaperFee += (publicationIssue.sun_no_of_copies - publicationIssueReplacement.sun_no_of_copies) * uom_price.get(GlobalVariableClass.UOM_COPYSUN);
                                    paperFee += (publicationIssue.sun_no_of_copies - publicationIssueReplacement.sun_no_of_copies) * uom_price.get(GlobalVariableClass.UOM_COPYSUN);
                                }
                                else {  
                                    totalPaperFee += publicationIssue.sun_no_of_copies * uom_price.get(GlobalVariableClass.UOM_COPYSUN);
                                    paperFee += publicationIssue.sun_no_of_copies * uom_price.get(GlobalVariableClass.UOM_COPYSUN);
                                }
                                //END UD-3061 10/9/2015 Added by Manolo Valena
                            }
                            //END UD-3215 11/10/15 AddedBy FrancisBenzon : charge everything if replaced by courier - [paperFee]

                            if (paperFee > 0) {
                                
                                caseVendorFee = new Case_Vendor_Fee__c();
                                caseVendorFee.Case__c = caseSubscription.Case__c;
                                //START UD-3208 11/6/15 AddedBy FrancisBenzon : vendor fee copies = complaint copies * complaint dates
                                //START UD-3208 11/12/15 AddedBy FrancisBenzon : added/deducted replacement copies
                                caseVendorFee.Copies__c = publicationIssue.weekday_no_of_copies + publicationIssue.sat_no_of_copies + publicationIssue.sun_no_of_copies;
                                //START UD-3254 13Nov15 FrancisBEnzon : Catch null pointer 
                                if(publicationIssueReplacement != null)
                                {
                                    replacementCopies = publicationIssueReplacement.weekday_no_of_copies + publicationIssueReplacement.sat_no_of_copies +publicationIssueReplacement.sun_no_of_copies;
                                }
                                //END UD-3254 13Nov15 FrancisBEnzon : Catch null pointer
                                if(caseId_isReplacedByVendor.get(caseSubscription.Case__c))
                                {
                                    if (caseSubscription.Replacement_Copies__c == null)
                                        caseSubscription.Replacement_Copies__c = 0;
                                    caseVendorFee.Copies__c =  caseVendorFee.Copies__c - replacementCopies;
                                    system.debug(':::RepByVendor  ' + caseVendorFee.Copies__c);
                                }
                                //END UD-3208 11/12/15 AddedBy FrancisBenzon : added/deducted replacement copies
                                //END UD-3208 11/6/15 AddedBy FrancisBenzon : vendor fee copies = complaint copies * complaint dates
                                caseVendorFee.Subscription__c = sub.Id;
                                caseVendorFee.Publication__c = pubCode_publicationId.get(pubCode);
                                caseVendorFee.Paper_Fee__c = paperFee;
                                caseVendorFeeList.add(caseVendorFee);
                            }
                        }
                    }
                }
            }
            //END UD-3103 10/15/2015 Added by Manolo Valena
        }       
        
        if (!caseVendorFeeList.isEmpty()) {
            try {
                insert caseVendorFeeList;
            } catch (exception e) {
                ExceptionLogger.log(new list<exception> { e });
            }
        }
        
        isWithValidSpcs = true;
        
        for (boolean isValidSpc : subscriptionId_isWithValidSpcs.values()) {
            if (isValidSpc == false) {
                isWithValidSpcs = false;
                return null;
            }
        }
        
        return totalPaperFee;
    }

}