/**
 * Class Name: CancelSubscription 
 * @author: Kristine Campang
 * Date: 9/26/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Class for Cancellation of Subscription and Delivery Charge 
 *
 */
global class CancelSubscriptionForStopSub {    
    
    public class SubscriptionWrapper{
        public String subId;
        public String zuoraId;
        public String stopDate;
    }
    
    public static String amendApiCall(List<Zuora.zObject> amendmentList) {
        Zuora.zApi zuorApi = new Zuora.zApi();
        zuorApi.zlogin();

        // Amend Request
        Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();       
        //Zuora.zObject[] amendments = new List <Zuora.zObject>();
        
        Zuora.zObject[] amendments = new List< Zuora.zObject >();
        amendments = amendmentList;
                        
        amendRequest.amendments = amendments;
        
        // Amend Options
        Zuora.zApi.AmendOptions amendmentOption = new Zuora.zApi.AmendOptions();
        amendmentOption.GenerateInvoice = false;
        amendmentOption.ProcessPayments = false;
        amendRequest.amendOptions = amendmentOption;

        // Amend Preview
        Zuora.zApi.PreviewOptions previewOptions = new Zuora.zApi.PreviewOptions();
        previewOptions.EnablePreviewMode = false;
        amendRequest.previewOptions = previewOptions;
        
        Zuora.zApi.AmendResult result = zuorApi.zamend(new List < Zuora.zApi.AmendRequest >{
            amendRequest
        });     
        system.debug('<<<<<<<<<<<<<<<<<<<<<<<<<<<<< result ' + result);
        return String.valueOf(result.errors);
    }

    /**
    * Create basic infomation for amendment.
    */
    public static List<Zuora.zObject> createCancelAmendment(List<SubscriptionWrapper> subToZuora) {
        List<Zuora.zObject> amendmentList = new List<Zuora.zObject>();     
        String dateToday = formatDateToZuora(date.today());
        String zuoraDate;
        Zuora.zObject amendment;
        
        system.debug('<<<<<<<<<<<<<<<<<<<<<<<<<<<<< subToZuora ' + subToZuora);
        
        for(SubscriptionWrapper subWrap : subToZuora){
            zuoraDate = subWrap.stopDate;
            amendment = new Zuora.zObject(globalvariableclass.AMENDMENT);
            
            amendment.setValue(globalvariableclass.CONTRACT_EFFECTIVEDATE, /*'2014-09-20T20:44:54.718+05:30'*/ zuoraDate);
            amendment.setValue(globalvariableclass.DESCRIPTION, globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
            amendment.setValue(globalvariableclass.EFFECTIVE_DATE, /*'2015-04-01T20:44:54.718+05:30'*/ dateToday);
            amendment.setValue(globalvariableclass.NAME, globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
            amendment.setValue(globalvariableclass.STATUS, globalvariableclass.COMPLETED);
            amendment.setValue(globalvariableclass.SUBSCRIPTION_ID, subWrap.zuoraId);
            amendment.setValue(globalvariableclass.TYPE, globalvariableclass.CANCELATION);
            system.debug('<<<<<<<<<<<<<<<<<<<<<<<<<<<<< amendment ' + amendment);
            amendmentList.add(amendment);
        }
        
        return amendmentList;
    } 
    
    @future(callout=true)
    global  static void amendForSubCancelation(Map<Id, Date> subDateMap, String accountId){
        List<SubscriptionWrapper> subToZuora = checkDeliverySubscription(subDateMap, accountId);    
        List<Zuora.zObject> amendmentList = createCancelAmendment(subToZuora);
        amendApiCall(amendmentList);
    }
    
    public static List<SubscriptionWrapper> checkDeliverySubscription(Map<Id, Date> subDateMap, String accountId){              
        Map<id, Map<String, List<Zuora__Subscription__c>>> allSubscriptionMap = new Map<id, Map<String, List<Zuora__Subscription__c>>>();
        Map<id, Map<String, List<Zuora__Subscription__c>>> subscriptionToCancelMap = new Map<id, Map<String, List<Zuora__Subscription__c>>>();
        List<Zuora__Subscription__c> subTemp1 = new List<Zuora__Subscription__c>();
        List<Zuora__Subscription__c> subTemp2 = new List<Zuora__Subscription__c>();
        List<SubscriptionWrapper> subZuoraId = new List<SubscriptionWrapper>();
        Set<id> subIdSet = new Set<id>();
        subIdSet = subDateMap.keySet();
        SubscriptionWrapper subWrap;
        
        system.debug('++++++++++++++++++++++ subDateMap ' + subDateMap);
        
        List<Zuora__Subscription__c> subscription = [SELECT id, name, zuora__account__c, subscription_type_1__c,
                                                     Zuora__Zuora_Id__c, recipient_address_id__c
                                                     FROM zuora__subscription__c 
                                                     WHERE zuora__account__c =: accountId 
                                                        AND Zuora__Status__c =: GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE];
        
        List<Zuora__Subscription__c> subscriptionToCancel = [SELECT id, name, zuora__account__c, subscription_type_1__c,
                                                             Zuora__Zuora_Id__c, recipient_address_id__c
                                                             FROM zuora__subscription__c 
                                                             WHERE id IN : subIdSet];
                                                                    
        allSubscriptionMap = groupSubscriptions(subscription);
        subscriptionToCancelMap = groupSubscriptions(subscriptionToCancel);
        
        system.debug('>>>>>>>>>>>>>>>> allSubscriptionMap ' + allSubscriptionMap);
        system.debug('>>>>>>>>>>>>>>>> subscriptionToCancelMap ' + subscriptionToCancelMap);
        
        for(String recipientKey : subscriptionToCancelMap.get(accountId).keySet()){
            if(subscriptionToCancelMap.get(accountId).containsKey(recipientKey)){
                subTemp1 = subscriptionToCancelMap.get(accountId).get(recipientKey);
                subTemp2 = allSubscriptionMap.get(accountId).get(recipientKey);
                system.debug('>>>>>>>>>>>>>>>> subTemp1.size() ' + subTemp1.size());
                system.debug('>>>>>>>>>>>>>>>> subTemp2.size() - 1 ' + subTemp2.size());
                
                if(subTemp1.size() == (subTemp2.size() - 1)){
                    system.debug('>>>>>>>>>>>>>>>> TRUE ' + TRUE);
                    for(Zuora__Subscription__c sub :subTemp2){
                        subWrap = new SubscriptionWrapper();
                        subWrap.subId = sub.id;
                        subWrap.zuoraId = sub.Zuora__Zuora_Id__c;
                                                
                        if(sub.subscription_type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY){
                            subWrap.stopDate = formatDateToZuora(date.today());
                        } else {
                            system.debug(' >>>>>>>true>>>>>>>> subDateMap.get(sub.id) ' + subDateMap.get(sub.id));
                            subWrap.stopDate = formatDateToZuora(subDateMap.get(sub.id));
                            
                        }
                        
                        subZuoraId.add(subWrap);
                    }
                } else {
                    system.debug('>>>>>>>>>>>>>>>> FALSE ' + FALSE);
                    for(Zuora__Subscription__c sub :subTemp1){          
                        subWrap = new SubscriptionWrapper();
                        subWrap.subId = sub.id;
                        subWrap.zuoraId = sub.Zuora__Zuora_Id__c;                       
                        
                        if(sub.subscription_type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY){
                            subWrap.stopDate = formatDateToZuora(date.today());
                        } else {
                            system.debug(' >>>>>>>false>>>>>>>> subDateMap.get(sub.id) ' + subDateMap.get(sub.id));
                            subWrap.stopDate = formatDateToZuora(subDateMap.get(sub.id));
                        }
                        
                        subZuoraId.add(subWrap);
                    }
                }
            }
        }
        
        system.debug('>>>>>>>>>>>>>>>> subZuoraId ' + subZuoraId);
        return subZuoraId;
    }
    
    public static Map<id, Map<String, List<Zuora__Subscription__c>>> groupSubscriptions(List<Zuora__Subscription__c> subscription){
        Map<id, Map<String, List<Zuora__Subscription__c>>> accAddSubMap = new Map<id, Map<String, List<Zuora__Subscription__c>>>();for(Zuora__Subscription__c sub : subscription){
            if(accAddSubMap.containsKey(sub.zuora__account__c)){
                if(accAddSubMap.get(sub.zuora__account__c).containsKey(sub.recipient_address_id__c)){
                    accAddSubMap.get(sub.zuora__account__c).get(sub.recipient_address_id__c).add(sub);
                } else {
                    accAddSubMap.get(sub.zuora__account__c).put(sub.recipient_address_id__c, new List<Zuora__Subscription__c>{sub});
                }
            } else {
                accAddSubMap.put(sub.zuora__account__c, new Map<String, List<Zuora__Subscription__c>>());
                accAddSubMap.get(sub.zuora__account__c).put(sub.recipient_address_id__c, new List<Zuora__Subscription__c>{sub});
            }
        }
        
        return accAddSubMap;
    }             
    
    /*Convert Date to Format in Zoura
    */
    public static String formatDateToZuora(Date formatDate){
        system.debug('>>>>>>>>>formatDate' + formatDate);
        DateTime stp = (DateTime)formatDate;
        system.debug('>>>>>>>>>stp' + stp);
        String mydate = string.valueof(stp.format('YYYY-MM-d'));
        system.debug('>>>>>>>>>myDate' + myDate);
        String d = mydate+'T00:00:00';  
        return d;
    }
 
 }