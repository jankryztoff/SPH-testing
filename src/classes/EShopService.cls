@RestResource(urlMapping='/EShopTempStopService/*')
global with sharing class EShopService{
    
    private static Date tempStop_Date;
    private static Date restart_Date;
    private static Case newCase = new Case();
    private static Order__c order = new Order__c();
    private static Temp_Stop__c tempStop = new Temp_Stop__c();
    private static EShopResponse response = new EShopResponse();
    
    global class EShopResponse{
        String svc_status;
        String error_code; 
        String error_message;
        String subscriberId;
        String requestTotalCredit;
        String requestTotalIssue;
        String restartDate;
        String tempStopDate;
        String currentTempStopCount;
    }
    
    global class EShopRequest{
        String subscriberId;
        String subscriptionId;
        String tempStopDate;
        String restartDate;
        String remarks;
        String source;
        String quantity;
    }

    @httpPOST
    global static EShopResponse processRequest(EShopRequest request){
        Integer flag = 0;
        response.svc_status = GlobalVariableClass.SVC_STATUS_SUCCESS;
        Temp_Stop__c tempStopRecord = new Temp_Stop__c();
        Zuora__Subscription__c subscription = new Zuora__Subscription__c();
        List<Subscription_Temp_Stop__c> existingTempStop = new List<Subscription_Temp_Stop__c>();
        Account account = new account();
        tempStop_Date = convertDate(request.tempStopDate);
        restart_Date = convertDate(request.restartDate);
        List<Subscription_Temp_Stop__c> subTemp = getTempStop(request);    
        Boolean result = validateOverlapping(subTemp, request);                
                
        try{                        
            account = getAccount(request.subscriberId);
        } catch (Exception e){
            flag = 1;
        }
        try{
            subscription = getSubscription(request);  
        } catch(Exception e){
            if(flag == 1){
                flag = 3;
            } else {
                flag = 2;
            }
        }
        if(request.subscriberId == '' || request.subscriptionId == '' || request.remarks == '' 
           || request.source == '' || request.quantity == ''){
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.ERROR_CODE_GENERAL;
            response.error_message = GlobalVariableClass.ERROR_MESSAGE_GENERAL;
        } else if(flag == 1){
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.ERROR_CODE_EITHER;
            response.error_message = GlobalVariableClass.ERROR_MESSAGE_SUBSCRIBER;
        } else if( flag == 2){
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.ERROR_CODE_EITHER;
            response.error_message = GlobalVariableClass.ERROR_MESSAGE_SUBSCRIPTION;
        } else if( flag == 3){
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.ERROR_CODE_BOTH;
            response.error_message = GlobalVariableClass.ERROR_MESSAGE_BOTH;            
        }else if(result){
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.ERROR_CODE_OVERLAPPING;
            response.error_message = GlobalVariableClass.ERROR_MESSAGE_OVERLAPPING;
        } else if(tempStop_Date == null || restart_Date == null){
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.ERROR_CODE_GENERAL;
            response.error_message = GlobalVariableClass.ERROR_MESSAGE_GENERAL;
        }
        
        if(response.svc_status == GlobalVariableClass.SVC_STATUS_SUCCESS){
            tempStopRecord = createTempStopRecord(request);
            response.requestTotalCredit = String.valueOf(tempStopRecord.Request_Total_Credit__c);
            response.requestTotalIssue = String.valueOf(tempStopRecord.Request_Total_Issue__c);
            response.currentTempStopCount = String.valueOf(subscription.Year_to_Date_Temp_Stop_Days__c);
        }
        
        return response;
    }
    
    private static Zuora__Subscription__c getSubscription(EShopRequest request){
        Account account = getAccount(request.subscriberId);
        Zuora__Subscription__c subscription = new Zuora__Subscription__c();
        
        subscription = [SELECT id, name, Vendor_Subscription_To_Convert_1__r.Temp_Stop_Count_Year_to_Date__c
                        FROM Zuora__Subscription__c 
                        WHERE id =: request.subscriptionId AND  Zuora__Account__c =: account.id];
        
        return subscription;
    }
    
    private static Account getAccount(String subscriberId){
        Account accountRecord = new Account();
        accountRecord = [SELECT id, name FROM Account WHERE account_auto_number__c =: subscriberId];
         
        return accountRecord;
    }
    
    private static void updateSubscription(EShopRequest request){
        Zuora__Subscription__c subscription = getSubscription(request);        
        
        subscription.order_number__c = order.id;
        update subscription;
    }
    
    private static void createSubscritpionTempStopRecord(EShopRequest request){
        Subscription_Temp_Stop__c subTempStop = new Subscription_Temp_Stop__c();
        Zuora__Subscription__c subscription = getSubscription(request);
        
        subTempStop.subscription__c = subscription.id;
        subTempStop.temp_stop__c = tempStop.id;
        
        insert subTempStop;
    }
    
    private static Temp_Stop__c createTempStopRecord(EShopRequest request){        
        tempStop.temp_stop_date__c = tempStop_Date;
        tempStop.restart_date__c = date.valueOf(restart_Date);
        tempStop.remarks__c = request.remarks;
        tempStop.temp_stop_qty__c = Integer.valueOf(request.quantity);
        
        insert tempStop;
        
        createOrderRecord(request);
        
        tempStop.case__c = newCase.id;
        tempStop.order__c = order.id;
        
        update tempStop;
        
        updateSubscription(request);
        createSubscritpionTempStopRecord(request);
        
        return tempStop;
    }        
    
    private static void createCaseRecord(EShopRequest request){        
        Publication__c publication = getPublication(request);
                
        newCase.category__c = GlobalVariableClass.TS_SUBSCRIPTION_REQUEST;
        newCase.subject__c = GlobalVariableClass.TS_SUBJECT;
        newCase.temp_stop__c = tempStop.id;        
        newCase.temp_stop_type__c = GlobalVariableClass.STATUS_NEW;
        newCase.temp_stop_date__c = tempStop_date;
        newCase.restart_date__c = restart_date;
        newCase.remarks__c = request.remarks;
        newCase.order__c = order.id;
        newCase.Origin = request.source;
        newCase.earliest_stop_date__c = publication.earliest_start_date__c;
        
        insert newCase;  
        
        order.Case_Owner__c = newCase.id;
        
        
        update order;              
    }
        
    private static void createOrderRecord(EShopRequest request){  
        Account account = getAccount(request.subscriberId);              
        order.account__c = account.id;
        order.order_type__c = GlobalVariableClass.TS_TEMP_STOP;
        order.temp_stop_type__c = GlobalVariableClass.STATUS_NEW;        
        order.status__c = GlobalVariableClass.STATUS_NEW;
        order.informed_customer__c = true;
        order.case_record_type__c = GlobalVariableClass.TS_SUBJECT;        
        order.credit_balance__c = 0;
        order.delivery_charge__c = 0;
        order.monthly_delivery_charge_for_full_payment__c = 0;
        order.subscriber_account__c = account.id;
        order.Base_Subscription__c = request.subscriptionId;
        
        insert order;
        
        createCaseRecord(request);
    }
    
    private static Publication__c getPublication(EShopRequest request){
        Set<String> ratePlanName = new Set<String>();
        Set<String> ratePlanId = new Set<String>();
        Set<String> publicationCodeSet = new Set<String>();        
        List<Zuora__SubscriptionProductCharge__c> subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();
        List<zqu__ProductRatePlan__c> ratePlanList = new List<zqu__ProductRatePlan__c>();
        List<zqu__ProductRatePlanCharge__c> prodRatePlanList = new List<zqu__ProductRatePlanCharge__c>();
        Publication__c publication = new Publication__c();
        
        subProdChargeList = [SELECT Zuora__RatePlanName__c, Zuora__Subscription__c
                             FROM Zuora__SubscriptionProductCharge__c
                             WHERE Zuora__Subscription__c =: request.subscriptionId];
        
        for(Zuora__SubscriptionProductCharge__c subProdCha : subProdChargeList){
            ratePlanName.add(subProdCha.Zuora__RatePlanName__c);
        }
        
        ratePlanList = [SELECT id, name, SubscriptionFrequency__c
                        FROM zqu__ProductRatePlan__c 
                        WHERE name IN :ratePlanName];
        
        for(zqu__ProductRatePlan__c ratePlanAccess : ratePlanList){
            ratePlanId.add(ratePlanAccess.id);
        }
        
        prodRatePlanList = [SELECT publicationcode__c, zqu__ProductRatePlan__c 
                            FROM zqu__ProductRatePlanCharge__c 
                            WHERE zqu__ProductRatePlan__c IN :ratePlanId];
        
        for(zqu__ProductRatePlanCharge__c pubCodeAccess : prodRatePlanList){
            publicationCodeSet.add(pubCodeAccess.publicationcode__c);
        }
        
        if(publicationCodeSet != null){
            try{
            publication = [SELECT earliest_start_date__c, publication_code__c FROM publication__c 
                           WHERE publication_code__c IN :publicationCodeSet];
            } catch(Exception e){
                system.debug('Error in querying of publications    ' + e.getmessage());
            }
        }
                       
        return publication;
    }
    
    private static List<Subscription_Temp_Stop__c> getTempStop(EShopRequest request){
        List<Subscription_Temp_Stop__c> tempStopRecordList = new List<Subscription_Temp_Stop__c>();
        
        tempStopRecordList = [SELECT id, name, subscription__c, temp_Stop__c, Temp_Stop__r.Temp_Stop_Date__c,
                              Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Cancelled__c
                              FROM Subscription_Temp_Stop__c 
                              WHERE subscription__c =: request.subscriptionId];
                              
        return tempStopRecordList;
    }
    
    private static Boolean validateOverlapping(List<Subscription_Temp_Stop__c> subTempRecord, EShopRequest request){
        Boolean returnValue = false;
        Date startPrev;
        Date endPrev;
        Date startInput = tempStop_Date;
        Date endInput = restart_Date;
        for(Subscription_Temp_Stop__c subTemp : subTempRecord){
            if(!(subTemp.temp_stop__r.cancelled__c)){
                if(subTemp.Subscription__c == request.subscriptionId){
                    startPrev = subTemp.Temp_Stop__r.Temp_Stop_Date__c;
                    endPrev = subTemp.Temp_Stop__r.Restart_Date__c;                    
                    if((startprev >= startinput && startprev <= endinput) ||
                       (endprev >= startinput && endprev <= endinput) ||
                       (startprev <= startinput && endprev >= endinput)){
                        returnValue = true;
                    }
                }
            }
        }        
        return returnValue;
    }
    
    private static Date convertDate(String myDate){
        Date d;
        try{
            String[] myDateOnly = myDate.split(' ');
            String[] strDate = myDateOnly[0].split('/');
            Integer myIntMonth = integer.valueOf(strDate[0]);       
            Integer myIntDay = integer.valueOf(strDate[1]);
            Integer myIntYear = integer.valueOf(strDate[2]);            
            d = Date.newInstance(myIntYear, myIntMonth, myIntDay);
        } catch(Exception e){
            d = null;
        }
        
        return d;
    }
}