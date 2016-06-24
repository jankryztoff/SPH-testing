/**
* Class Name: <ComplaintNewspaperCounterUpdate>
* Date: <04-February-2016>
* Requirement/Project Name: <SPH>
* @description: 
*/
public class ComplaintNewspaperCounterUpdate{
    Map<String, Map<String, Integer>> mapAddressToCounter = new Map<String, Map<String, Integer>>();
    Map<String, Integer> mapContactToCounter = new Map<String, Integer>();
    Id complaintId = ConstantsSLB.getKeyId('Complaint_Newspaper');
    Integer ctrDays = Integer.valueOf(ConstantsSLB.getOther('Complaint counter days'));
    Integer ctrWeeks = Integer.valueOf(ConstantsSLB.getOther('Complaint counter weeks'));
    Set<String> caseIds = new Set<String>();
    List<Case_Subscription__c> lstCaseSub = new List<Case_Subscription__c>();
    List<Case_Vendor_Subscription__c> lstCaseVendorSub = new List<Case_Vendor_Subscription__c>();
    List<Contact> contactsToUpdate = new List<Contact>();
    List<Address__c> addressesToUpdate = new List<Address__c>();
    Contact con;
    Address__c add;
    Date baseDate = Date.Today() - ctrWeeks;

    public void doUpdate(){
        if(complaintId != null && baseDate != null){
            lstCaseSub = [SELECT Case__r.CreatedDate, Goodwill_Amount__c, Case__r.Status, Case__r.Goodwill_Approval_Status__c, Subscription__r.Recipient_Contact__c,Subscription__r.Recipient_Contact__r.Address__c 
                            FROM Case_Subscription__c WHERE Case__r.RecordTypeId =:complaintId AND Subscription__r.Recipient_Contact__c != null AND Case__r.CreatedDate >=:baseDate AND Case__r.CreatedBy.Name = 'Migration'];
            
            lstCaseVendorSub = [SELECT Case__r.CreatedDate, Goodwill_Amount__c, Case__r.Status, Case__r.Goodwill_Approval_Status__c, Subscription_Vendor__r.Recipient__r.Address__c, Subscription_Vendor__r.Recipient__c
                        FROM Case_Vendor_Subscription__c
                        WHERE Case__r.RecordTypeId =:complaintId AND Subscription_Vendor__r.Recipient__c != null AND Case__r.CreatedDate >=:baseDate AND Case__r.CreatedBy.Name = 'Migration'];
       }
        System.debug('>>rr: lstCaseSub--' + lstCaseSub);
        if(!lstCaseSub.isEmpty()){
            for(Case_Subscription__c caseSub: lstCaseSub){
                String contactId, addressId;
                
                contactId = caseSub.Subscription__r.Recipient_Contact__c;
                if(caseSub.Subscription__r.Recipient_Contact__r.Address__c != null){
                    addressId =  caseSub.Subscription__r.Recipient_Contact__r.Address__c;
                }
                
                if(!mapContactToCounter.containsKey(contactId)){
                    mapContactToCounter.put(contactId, 0);
                }
                
                if(addressId !=null){
                    if(!mapAddressToCounter.containsKey(addressId)){
                        mapAddressToCounter.put(addressId, new Map<String, Integer>());
                        mapAddressToCounter.get(addressId).put('30Days', 0);
                        mapAddressToCounter.get(addressId).put('16Weeks', 0);
                    }
                }
                
                if(caseSub.Case__r.CreatedDate.date() >= (Date.Today() - 112)){
                    if(caseSub.Case__r.CreatedDate.date() >= (Date.Today() - 30)){
                        if (caseSub.Goodwill_Amount__c > 0 && caseSub.case__r.Status =='Closed' && caseSub.case__r.Goodwill_Approval_Status__c=='Approved'){
                                mapContactToCounter.put(contactId, mapContactToCounter.get(contactId) + 1);
                        }
                        if(addressId != null){
                                mapAddressToCounter.get(addressId).put('30Days', mapAddressToCounter.get(addressId).get('30Days') + 1);
                        } 
                    }
                    if(addressId != null){
                            mapAddressToCounter.get(addressId).put('16Weeks', mapAddressToCounter.get(addressId).get('16Weeks') + 1);
                    } 
                }
            }
        }


        System.debug('>>rr: lstCaseVendorSub--' + lstCaseVendorSub);
        if(!lstCaseVendorSub.isEmpty()){
            for(Case_Vendor_Subscription__c caseVendorSub: lstCaseVendorSub){
                String vContactId, vAddressId;
                
                vContactId = caseVendorSub.Subscription_Vendor__r.Recipient__c;
                if(caseVendorSub.Subscription_Vendor__r.Recipient__r.Address__c != null){
                    vAddressId =  caseVendorSub.Subscription_Vendor__r.Recipient__r.Address__c;
                }
                
                if(!mapContactToCounter.containsKey(vContactId)){
                    mapContactToCounter.put(vContactId, 0);
                }
                
                if(vAddressId !=null){
                    if(!mapAddressToCounter.containsKey(vAddressId)){
                        mapAddressToCounter.put(vAddressId, new Map<String, Integer>());
                        mapAddressToCounter.get(vAddressId).put('30Days', 0);
                        mapAddressToCounter.get(vAddressId).put('16Weeks', 0);
                    }
                }
                
                if(caseVendorSub.Case__r.CreatedDate.date() >= (Date.Today() - 112)){
                    if(caseVendorSub.Case__r.CreatedDate.date() >= (Date.Today() - 30)){
                        if (caseVendorSub.Goodwill_Amount__c > 0 && caseVendorSub.case__r.Status =='Closed' && caseVendorSub.case__r.Goodwill_Approval_Status__c=='Approved'){
                                mapContactToCounter.put(vContactId, mapContactToCounter.get(vContactId) + 1);
                        }
                        if(vAddressId != null){
                                mapAddressToCounter.get(vAddressId).put('30Days', mapAddressToCounter.get(vAddressId).get('30Days') + 1);
                        } 
                    }
                    if(vAddressId != null){
                            mapAddressToCounter.get(vAddressId).put('16Weeks', mapAddressToCounter.get(vAddressId).get('16Weeks') + 1);
                    } 
                }
            }
        }
        
        System.debug('>>rr: mapContactToCounter--' + mapContactToCounter);
        if(mapContactToCounter.size() > 0){
            for(String contId: mapContactToCounter.keySet()){
                if(mapContactToCounter.get(contId) > 0){
                    con = new Contact();
                    con.Id = contId;
                    con.Number_of_goodwill__c = mapContactToCounter.get(contId);
                    contactsToUpdate.add(con);
                }
            }
        }
        System.debug('>>rr: mapAddressToCounter--' + mapAddressToCounter);
        if(mapAddressToCounter.size() > 0){
            for(String addId: mapAddressToCounter.keySet()){
                if(mapAddressToCounter.get(addId).get('30Days') > 0 || mapAddressToCounter.get(addId).get('16Weeks') > 0  ){
                    add = new Address__c();
                    add.Id = addId;
                    add.Non_Delivery_Complaint_Cases_30_days__c = mapAddressToCounter.get(addId).get('30Days');
                    add.Non_Delivery_Complaint_Cases_16_wks__c = mapAddressToCounter.get(addId).get('16Weeks');
                    addressesToUpdate.add(add);
                }
            }
        }

        try{
            System.debug('>>rr: contactsToUpdate--' + contactsToUpdate);
            if(contactsToUpdate.size() > 0){
                update contactsToUpdate;
            }
            System.debug('>>rr: addressesToUpdate--' + addressesToUpdate);
            if(addressesToUpdate.size() > 0){
                update addressesToUpdate;
            }
        }catch(Exception e){
            System.debug('Update Error: ' + e);
        }
    }
}