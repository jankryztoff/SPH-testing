/**
 * Class Name: SP_EscalatedComplaintsEmailNotification 
 * @author: Jb Domingo
 * Date: 9/29/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Batch Class that send email notifications to Case Team
 *
 */
public class SP_EscalatedComplaintsEmailNotification {  
    /* @description This method checks escalated cases and send email to the case team 
     * 
     * @param cList - list of case objects
     * @return void
     */  
    public void emailVendorEscalatedComplaints(List<Case> cList){
    
        Set<Id> contactIdSet = new Set<Id>();       
        Set<string> ratePlanChargeIdSet = new Set<string>();
        Set<string> pubCodeIdSet = new Set<string>();
        Set<Id> subscriptionIdSet = new Set<Id>();
        Set<Id> addressIdSet = new Set<Id>();
        Set<Id> singpostAddressIdSet = new Set<Id>();
        Set<String> toAddressesSet = new Set<String>();     
        Set<Id> caseTeamUserIdSet = new Set<Id>();
        Set<Id> caseIdSet = new Set<Id>();
        
        List<Case_Subscription__c> caseSubscriptionList = new List<Case_Subscription__c>();
        List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();      
        List<Zuora__SubscriptionProductCharge__c> subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();
        List<zqu__ProductRatePlanCharge__c> prodRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
        List<Publication__c> publicationList = new List<Publication__c>();
        List<Contact> contactList = new List<Contact>();
        List<Address__c> addressList = new List<Address__c>();
        List<Singpost_Address__c> singpostAddressList = new List<Singpost_Address__c>();
        List<Case_Subscription__c> caseSubscriptionsList = new List<Case_Subscription__c>();
        List<String> toAddresses = new List<String>();      
        List<CaseTeamMember> caseTeamMemberList = new List<CaseTeamMember>();
        List<User> caseTeamUserList = new List<User>();  
        List<Case> caseObjList = new List<Case>();
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<CaseTeamMember> caseTeamMembersList = new List<CaseTeamMember>();
        
        Map<Id,List<Case_Subscription__c>> case_caseSubscriptionMap = new Map<Id,List<Case_Subscription__c>>();       
        Map<Id,Zuora__Subscription__c> subscriptionMap = new Map<Id,Zuora__Subscription__c>();
        Map<Id, Zuora__SubscriptionProductCharge__c> subProdChargeMap = new Map<Id, Zuora__SubscriptionProductCharge__c>();
        Map<String, zqu__ProductRatePlanCharge__c> productRatePlanChargeMap = new Map<String, zqu__ProductRatePlanCharge__c>();
        Map<String , Publication__c> publicationMap = new Map<String, Publication__c>();            
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        Map<Id,Address__c> addressMap = new Map<Id,Address__c>();
        Map<Id,Singpost_Address__c> singpostAddressMap = new Map<Id,Singpost_Address__c>();
        Map<Id,List<CaseTeamMember>> case_CaseTeamListMap = new Map<Id,List<CaseTeamMember>>();
        Map<Id,User> userMap = new Map<Id,User>();
        
        Address__c addressObj = new Address__c();  
        Contact con = new Contact();  
        Publication__c publicationObj = new Publication__c();      
        Singpost_Address__c singpostAddressObj = new Singpost_Address__c();
        String transactionName;         
        String sub; 
        Zuora__SubscriptionProductCharge__c subProdChargeObj = new Zuora__SubscriptionProductCharge__c();        
        Zuora__Subscription__c subscription = new Zuora__Subscription__c();    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        //Get all escalated cases
        for(Case c:cList){
            if(c.IsEscalated == true){          
                caseObjList.add(c);
                caseIdSet.add(c.Id);
            }
        }
        //Get all case team members
                                
                                // START Code Review Jean Cari�o 02/18/2015 : Check caseIdSet if null.
                                if(caseIdSet.size() > 0){
                                                CaseTeamMemberList = [SELECT Id, MemberId, ParentId FROM CaseTeamMember WHERE ParentId IN: caseIdSet];
                                }
                                // END Code Review Jean Cari�o 02/18/2015 : Check caseIdSet if null.
                                
        if(caseTeamMemberList != null){
            for(CaseTeamMember caseTeam:caseTeamMemberList){
                                                                // START Code Review Jean Cari�o 02/18/2015 : Check caseTeam.MemberId if null.
                                                                if(caseTeam.MemberId != null){
                                                                                caseTeamUserIdSet.add(caseTeam.MemberId);
                                                                }
                                                                // END Code Review Jean Cari�o 02/18/2015 : Check caseTeam.MemberId if null.
                List<CaseTeamMember> caseTeamMemberTempList = case_CaseTeamListMap.get(caseTeam.ParentId);
                if(caseTeamMemberTempList == null)
                {
                    caseTeamMemberTempList = new List<CaseTeamMember>();
                }
                caseTeamMemberTempList.add(caseTeam);
                case_CaseTeamListMap.put(caseTeam.ParentId,caseTeamMemberTempList);
            }
        }
        //Get all case team members
                                // START Code Review Jean Cari�o 02/18/2015 : Check caseTeamUserIdSet if null.
                                if(caseTeamUserIdSet.size() > 0){
                                                caseTeamUserList = [SELECT Id, Email FROM User WHERE Id IN: caseTeamUserIdSet];
                                }
                                // END Code Review Jean Cari�o 02/18/2015 : Check caseTeamUserIdSet if null.
        if(caseTeamUserList != null){
            for(User u:caseTeamUserList){
                userMap.put(u.Id,u);
            }
        }
                                
        //Get all case subscriptions related to the case
                                // START Code Review Jean Cari�o 02/18/2015 : Check caseIdSet if null.
                                if(caseIdSet.size() > 0){
                                                caseSubscriptionList = [SELECT Id, Case__c, Subscription__c FROM Case_Subscription__c WHERE Case__c IN:caseIdSet];
                                }
                                // END Code Review Jean Cari�o 02/18/2015 : Check caseIdSet if null.
                                
        if(caseSubscriptionList != NULL){
            for(Case_Subscription__c caseSubObj : caseSubscriptionList){
                                                
                                                                if(caseSubObj.Subscription__c != null){
                                                                                subscriptionIdSet.add(caseSubObj.Subscription__c);
                                                                }
                List<Case_Subscription__c> caseSubscriptionTempList = case_caseSubscriptionMap.get(caseSubObj.Case__c);
                if(caseSubscriptionTempList == null){
                    caseSubscriptionTempList = new List<Case_Subscription__c>();
                }
                caseSubscriptionTempList.add(caseSubObj);
                case_caseSubscriptionMap.put(caseSubObj.Case__c,caseSubscriptionTempList);
            }
        }
        //Get the subscriptions        
        subscriptionList = [SELECT Id, Name, Subscriber_Contact__c, Recipient_Contact__c, Recipient_Contact__r.FirstName, Recipient_Contact__r.LastName, Vendor_1__r.Id, Frequency_1__c, Number_of_Copies__c, Vendor_1__r.Email__c, Effective_End_Date__c, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Vendor_Subscription_To_Convert_1__c  FROM Zuora__Subscription__c WHERE Id IN:subscriptionIdSet];
        if(subscriptionList != NULL){
            for(Zuora__Subscription__c zSub:subscriptionList){
                subscriptionMap.put(zSub.Id,zSub);
                contactIdSet.add(zSub.Recipient_Contact__c);
            }
        }
        //Get subscription product and charges for every subscription
        subProdChargeList = [SELECT Zuora__Subscription__c, Zuora__RatePlanName__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c IN: subscriptionIdSet];
        if(subProdChargeList != NULL){       
            for(Zuora__SubscriptionProductCharge__c subProdCharge: subProdChargeList){
                subProdChargeMap.put(subProdCharge.Zuora__Subscription__c, subProdCharge);
                ratePlanChargeIdSet.add(subProdCharge.Zuora__RatePlanName__c);
            }
        }
        //Get product rate plan and charges
        prodRatePlanChargeList = [SELECT Id, Name, zqu__ProductRatePlan__c, PublicationCode__c FROM zqu__ProductRatePlanCharge__c WHERE Name IN: ratePlanChargeIdSet]; 
        if(prodRatePlanChargeList != NULL){
            for(zqu__ProductRatePlanCharge__c prodRatePlanCharge:prodRatePlanChargeList){
                productRatePlanChargeMap.put(prodRatePlanCharge.Name, prodRatePlanCharge);
                pubCodeIdSet.add(prodRatePlanCharge.PublicationCode__c);
            }
        }
        //Get publications
        publicationList = [SELECT Name, Publication_Code__c FROM Publication__c WHERE Publication_Code__c IN: pubCodeIdSet];  
        if(publicationList != NULL){
            for(Publication__c publication : publicationList){
                publicationMap.put(publication.Publication_Code__c, publication);
            }
        }
        //Get contacts
        contactList = [SELECT Id, FirstName, LastName, Address__r.Id, Salutation FROM Contact WHERE Id IN: contactIdSet];
        if(contactList != NULL){
            for(Contact c : contactList){
                contactMap.put(c.Id, c);
                addressIdSet.add(c.Address__r.Id);
            }
        }
        //Get addresses of contacts
        addressList = [SELECT Id, Block_House_Number__c, Level_Number__c, Unit_Number__c, Postal_Code__r.Id, Street_Name__c, Building_Name__c FROM Address__c WHERE Id IN: addressIdSet];    
                
        if(addressList != NULL){       
            for(Address__c address : addressList){
                addressMap.put(address.Id, address);
                singpostAddressIdSet.add(address.Postal_Code__r.Id);
            }
        }
        //Get postal code of addresses
        singpostAddressList = [SELECT Id, Name FROM Singpost_Address__c WHERE Id IN: singpostAddressIdSet];
        if(singpostAddressList != NULL){
            for(Singpost_Address__c singpostAddress : singpostAddressList){
                singpostAddressMap.put(singpostAddress.Id, singpostAddress);
            }
        }  
        //This will get all the related objects needed for every case in the caseObjList
        for(Case caseObject:caseObjList){
            
            if(case_CaseTeamListMap != null){
                caseTeamMembersList = case_CaseTeamListMap.get(caseObject.Id);
            }
            
            if(caseTeamMembersList != null && userMap != null){
                for(CaseTeamMember casTeamMem:caseTeamMembersList){
                    User userObj = userMap.get(casTeamMem.MemberId);
                    toAddresses.add(userObj.Email);
                }           
            }
            
            if(case_caseSubscriptionMap != NULL){
                caseSubscriptionsList = case_caseSubscriptionMap.get(caseObject.Id);
            }
            
            if(caseSubscriptionsList != NULL){
                for(Case_Subscription__c caseSubObject: caseSubscriptionsList){
                    if(subscriptionMap != NULL && caseSubObject != NULL){
                        subscription = subscriptionMap.get(caseSubObject.Subscription__c);
                    }

                    if(contactMap != NULL){  
                        if(subscription != NULL){            
                            con = contactMap.get(subscription.Recipient_Contact__c);
                        }
                    }

                    if(subProdChargeMap != NULL){
                        if(subscription != NULL){
                            subProdChargeObj = subProdChargeMap.get(subscription.Id);
                        }
                    }
                    
                    if(productRatePlanChargeMap != NULL){
                        if(subProdChargeObj != NULL){
                            zqu__ProductRatePlanCharge__c productRatePlan = productRatePlanChargeMap.get(subProdChargeObj.Zuora__RatePlanName__c);
                            if(productRatePlan != NULL){
                                publicationObj = publicationMap.get(productRatePlan.PublicationCode__c);                            
                            }
                        }
                    }

                    if(publicationObj != NULL){
                        sub += string.valueOf(publicationObj.Publication_Code__c);
                    }
                    
                    if(subscription != NULL){
                        sub += '('+string.valueOf(subscription.Frequency_1__c)+' '+string.valueOf(subscription.Number_of_Copies__c)+')';        
                    }               
                } 
                
                if(addressMap != NULL){
                    if(con != NULL){
                        addressObj = addressMap.get(con.Address__r.Id);
                    }
                }
                
                if(singpostAddressMap != NULL){       
                    if(addressObj != NULL){
                       singpostAddressObj = singpostAddressMap.get(addressObj.Postal_Code__r.Id);
                    }
                }  
            }  
            //After getting all the objects needed, this will create the mail and will add to the maillist
            mail = new Messaging.SingleEmailMessage();    
            mail.setToAddresses(toAddresses);
            mail.setSubject('Case:'+caseObject.Id);       
            mail.setHtmlBody((subscription.Recipient_Contact__r.FirstName != null ? subscription.Recipient_Contact__r.FirstName : '')+
                            (subscription.Recipient_Contact__r.LastName != null ? subscription.Recipient_Contact__r.LastName : '')+Date.today()+
                            (transactionName != null ? transactionName : '')+'</br>'+
                            (sub != null ? sub : '')+'</br>'+
                            (addressObj.Block_House_Number__c != null ? addressObj.Block_House_Number__c : '')+ 
                            (addressObj.Street_Name__c != null ? addressObj.Street_Name__c : '')+
                            (addressObj.Building_Name__c != null ? addressObj.Building_Name__c : '')+
                            (addressObj.Level_Number__c != null ? addressObj.Level_Number__c : '')+
                            (addressObj.Unit_Number__c != null ? addressObj.Unit_Number__c : '')+
                            (singpostAddressObj.Name != null ? singpostAddressObj.Name : '')+'Classification'+
                            (caseObject.CSO_Remarks__c != null ? caseObject.CSO_Remarks__c : '')); 
                                                               
            mailList.add(mail);        
        }
        //Sends the mails to the Case Team
        try{
            Messaging.sendEmail(mailList);
        }
        catch(Exception e){
            //error handling tbd
        }
    }
}