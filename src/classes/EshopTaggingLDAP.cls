@RestResource(urlMapping='/EShopTaggingLDAP/*')
global with sharing class EshopTaggingLDAP{
    
    private static Response resp = new Response();
    global class Request{
        String subscriberId;
        String asiaOneLdapId;
    }

    global class Response{
        String subscriberId;
        String asiaOneLdapId;
        String svc_status;
        String error_code;
        String error_message;
    }

    @httpPOST
    global static Response processRequest(Request reqObj){
        
        
        List<Zuora__Subscription__c> zuoraSubList = new List<Zuora__Subscription__c>();
        Map<id, zqu__ProductRatePlan__c> subIdToProdRatePlan = new Map<id, zqu__ProductRatePlan__c>();
        List<Asia1_Subscription__c> asiaOneSubscriptionList = new List<Asia1_Subscription__c>();
        Asia1__c asiaOne;
        Set<Id> subIdSet = new Set<Id>();
        Set<Id> setPrintSubs = new Set<Id>();
        
        // START 04/15/15 UD-0926 UD-0927  Joban Bir Singh - Added Mandatory Field Validation
        Boolean isValid = true;
    
        isValid = checkMandatoryFields(reqObj);
        system.debug('valid --------'+isValid);
        if(!isValid) {
            resp.error_code = GlobalVariableClass.ERROR_CODE_MANDATORY;
            resp.error_message = GlobalVariableClass.NSS_ERROR_MESSAGE_MANDATORY;
            resp.svc_status = 'Failure';    
        } else {
            //START Code Review 2/17/2015 Added By C. Lin - Null in where clause causes full table scans - 100K Record Issue Limit
            if(reqObj != null){
                if(reqObj.subscriberId != null){
                    zuoraSubList =[SELECT Id, name, Zuora__Account__r.Account_Auto_Number__c 
                                   FROM Zuora__Subscription__c 
                                   WHERE Zuora__Account__r.Account_Auto_Number__c = :reqObj.subscriberId AND  Zuora__Status__c = 'Active'];
                }
                
                
            }
            //END Code Review 2/17/2015 Added By C. Lin
            
            resp.subscriberId = reqObj.subscriberId;
            resp.asiaOneLdapId = reqObj.asiaOneLdapId;
            if(zuoraSubList== null || zuoraSubList.size()==0){
                resp.error_code = 'EXES0017';
                resp.error_message = OnlineExceptions.getErrorMessage('EXES0017');
                resp.svc_status = 'Failure';    
            }
            if(zuoraSubList.size()>0){
                for(Zuora__Subscription__c sub : zuoraSubList){
                    //START Code Review 2/17/2015 Added By C. Lin - Null in where clause causes full table scans - 100K Record Issue Limit
                    if(sub.Id != null){
                        subIdSet.add(sub.Id);
                        }
                    //END Code Review 2/17/2015 Added By C. Lin
                }
            }
            
            //get Product Rate Plan for each subscription
            subIdToProdRatePlan = getProductRatePlan(subIdSet);      
        }
        
        // END 04/15/15 UD-0926 UD-0927 Joban Bir Singh - Added Mandatory Field Validation
        if(zuoraSubList.size()>0){
        List<Asia1_Subscription__c> lstexistingAsia1 = New List<Asia1_Subscription__c>();
        lstexistingAsia1 = [Select Id, Subscription__c, Asia1__c 
                                        from Asia1_Subscription__c 
                                        where Asia1__r.User_ID_LDAP_ID__c =: reqObj.asiaOneLdapId AND
                                              Subscription__r.Zuora__Account__r.AccountNumber =: reqObj.subscriberId];
            for(Zuora__Subscription__c zSub : zuoraSubList){
                 if(subIdToProdRatePlan.containsKey(zSub.Id)){                 
                    if(subIdToProdRatePlan.get(zSub.Id).zqu__ZProduct__r.ProductPlatform__c != 'Print'){
                        resp.error_code = 'EXES0016 ';
                        resp.error_message = OnlineExceptions.getErrorMessage('EXES0016');
                        resp.svc_status = 'Failure';
                    }
                    if(subIdToProdRatePlan.get(zSub.Id).zqu__ZProduct__r.ProductPlatform__c == 'Print'){
                        //call create Asia 1
                        //call create Asia1Sub
                        resp.svc_status = 'Success';
                        setPrintSubs.add(zSub.Id);
                        asiaOne = createAsia1(reqObj.asiaOneLdapId);
                        //asiaOneSubscriptionList = createAsia1Sub(setPrintSubs, null); don't call my name don't call my name 
                    }
                    
                 }
            }
        }
        //START UD-1212 11-May-2015 Added by Raviteja - Direct Individual Subscriber cannot have morethan one LDAP Id
        List<Asia1_Subscription__c> lstexistingdirindividualAsia1 = New List<Asia1_Subscription__c>();
        lstexistingdirindividualAsia1 = [Select Id, Subscription__c, Asia1__c 
                                        from Asia1_Subscription__c 
                                        where Asia1__r.User_ID_LDAP_ID__c =: reqObj.asiaOneLdapId AND
                                              Subscription__r.Zuora__Account__r.AccountNumber =: reqObj.subscriberId AND Subscription__r.Zuora__Account__r.RecordType.Name = 'Direct Individual'];
          
        //if(asiaOne!=null){ // UD-1212 11-May-2015 Added by Raviteja - commented existing condition
        if(asiaOne!=null && lstexistingdirindividualAsia1.size() == 0){
        //End UD-1212 11-May-2015 Added by Raviteja 
            insert asiaOne;
            asiaOneSubscriptionList = createAsia1Sub(setPrintSubs, asiaOne.Id);
        }
        //START UD-1212 11-May-2015 Added by Raviteja - Direct Individual Subscriber cannot have morethan one LDAP Id
        else if(lstexistingdirindividualAsia1.size() > 1){           
                resp.error_message = 'Direct Individual Subscriber cannot have morethan one LDAP Id';
                resp.svc_status = 'Failure';
        }
        //End UD-1212 11-May-2015 Added by Raviteja 
        if(asiaOneSubscriptionList.size()>0 || asiaOneSubscriptionList!=null){
            insert asiaOneSubscriptionList;
        }
        
        return resp;
    }
    
    
    
    private static  Map<id, zqu__ProductRatePlan__c> getProductRatePlan(Set<id> subIdSet){
        Set<String> prodSKU = new Set<String>();
        List<Zuora__SubscriptionProductCharge__c> subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();
        Map<id, Set<String>> prodSKUSetMap = new Map<id, Set<String>>();        
        List<zqu__ProductRatePlan__c> prodRatePlanList = new List<zqu__ProductRatePlan__c>();
        Map<String, zqu__ProductRatePlan__c> prodRatePlanMap = new Map<String, zqu__ProductRatePlan__c>();
        Map<id, zqu__ProductRatePlan__c> subProdRatePlanMap = new Map<id, zqu__ProductRatePlan__c>();
        
        //START Code Review 2/17/2015 Added By C. Lin - Null in where clause causes full table scans - 100K Record Issue Limit
        subIdSet.remove(null);
        if(!subIdSet.isEmpty()){
            subProdChargeList = [SELECT id, name, Zuora__Subscription__c, Zuora__RatePlanName__c, Zuora__ProductSKU__c
                                 FROM Zuora__SubscriptionProductCharge__c 
                                 WHERE Zuora__Subscription__c IN : subIdSet];
        }
        //END Code Review 2/17/2015 Added By C. Lin
        
        for(Zuora__SubscriptionProductCharge__c subProdCharge : subProdChargeList){
            //START Code Review 2/17/2015 Added By C. Lin - Null in where clause causes full table scans - 100K Record Issue Limit
            if(subProdCharge.Zuora__ProductSKU__c != null){
                prodSKU.add(subProdCharge.Zuora__ProductSKU__c);
            }
            //END Code Review 2/17/2015 Added By C. Lin
            
            if(prodSKUSetMap.containsKey(subProdCharge.Zuora__Subscription__c)){
                prodSKUSetMap.get(subProdCharge.Zuora__Subscription__c).add(subProdCharge.Zuora__ProductSKU__c);
            } else{
                prodSKUSetMap.put(subProdCharge.Zuora__Subscription__c, new Set<String>{subProdCharge.Zuora__ProductSKU__c});
            }
        }
        
        //START Code Review 2/17/2015 Added By C. Lin - Null in where clause causes full table scans - 100K Record Issue Limit
        prodSKU.remove(null);
        if(!prodSKU.isEmpty()){
            prodRatePlanList = [SELECT id, name, zqu__ZProduct__c, RatePlanType__c, zqu__ZProduct__r.ProductFamily__c,
                                SubscriptionFrequency__c, zqu__ZProduct__r.zqu__SKU__c, zqu__ZProduct__r.ProductPlatform__c
                                FROM zqu__ProductRatePlan__c 
                                WHERE zqu__ZProduct__r.zqu__SKU__c IN : prodSKU AND RatePlanType__c = 'Bill Plan'];
        }
        //END Code Review 2/17/2015 Added By C. Lin
        
        for(zqu__ProductRatePlan__c prodRatePlan : prodRatePlanList){
            prodRatePlanMap.put(prodRatePlan.zqu__ZProduct__r.zqu__SKU__c, prodRatePlan);
        }           
        
        for(Id subId : subIdSet){
            if(prodSKUSetMap.containsKey(subId)){
                for(String sku : prodSKUSetMap.get(subId)){
                    if(prodRatePlanMap.containsKey(sku)){
                        subProdRatePlanMap.put(subId, prodRatePlanMap.get(sku));
                    }
                }               
            }
        }
        
        return subProdRatePlanMap;
    }
    
    private static Asia1__c createAsia1(String ldapId){
        Map<String,Object> userDetailsMap = new Map<String,Object>();
        userDetailsMap = AsiaOneServicesController.viewUserDetails(ldapId);
        //System.assertEquals(null, userDetailsMap);
        Asia1__c asia1 = new Asia1__c();
        //System.assertEquals(null, !userDetailsMap.isEmpty());
        //System.assertEquals(null, userDetailsMap.get('DisplayName'));      
        if(!userDetailsMap.isEmpty()){       
            asia1.User_ID_LDAP_ID__c = ldapId;
            asia1.Display_Name__c = (String)userDetailsMap.get('Display Name');
            asia1.Email__c = (String)userDetailsMap.get('E-Mail');
            asia1.Password__c ='dummyPassword';
        }             
        
        return asia1;
    }
    
    private static List<Asia1_Subscription__c> createAsia1Sub(Set<Id> zSubsId, Id asiaOneId){
        List<Asia1_Subscription__c> asia1SubList = new List<Asia1_Subscription__c>();
        
        
        for(Id subscriptId : zSubsId){
            Asia1_Subscription__c asia1Sub = new Asia1_Subscription__c();
            asia1Sub.Subscription__c = subscriptId;
            asia1Sub.Asia1__c = asiaOneId;
            asia1SubList.add(asia1Sub);
        }
        
        return asia1SubList;
    }
    
    // START 04/15/15 UD-0927 & UD-0926 Joban Bir Singh - Added Mandatory Field Validation
    public static Boolean checkMandatoryFields(Request reqObj)
    {
        Boolean isValid = true;
        //START UD-1205 09-May-2015 Added by Raviteja - added String.isBlank() in both conditions
        if(reqObj.subscriberId == null || reqObj.subscriberId == '' || String.isBlank(reqObj.subscriberId)){
            isValid = false;
        }
        if(reqObj.asiaOneLdapId == null || reqObj.asiaOneLdapId == '' || String.isBlank(reqObj.asiaOneLdapId)){
            isValid = false;
        }
        //End UD-1205 09-May-2015 Added by Raviteja
        return isValid;
    }
    // END 04/15/15 UD-0927 & UD-0926 Joban Bir Singh - Added Mandatory Field Validation
    
}