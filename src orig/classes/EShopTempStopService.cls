/**
* Class Name: EShopTempStopService 
* @author: Jb Domingo
* Date: 11/7/2014
* Requirement/Project Name: Singapore Press Holdings
* @description ESHOP Temp Stop Web Service
* History: D-2012 JLedesma 3/27/2015 Updated class to utilize IssuCalculation method from UsageHelper
* Raviteja : D-2683 Restructure the class
*/
@RestResource(urlMapping='/EShopTempStopService1/*')
global with sharing class EShopTempStopService{
    
    private static Date tempStop_Date;
    private static Date restart_Date;
    private static Case newCase = new Case();
    private static Order__c order = new Order__c();
    private static Temp_Stop__c tempStop = new Temp_Stop__c();
    private static EShopResponse response = new EShopResponse();
    //START: D-2012 3/27/2015 JLedesma Issue Calculation
    private static Map<String, String> pubCodeToPublishedDays = new Map<String, String>();
    private static Set<ID> subsID = new Set<ID>();
    private static Map<Id, Zuora__Subscription__c> mapIdToSubRec = new Map<Id, Zuora__Subscription__c>(); 
    private static  List<Zuora__Subscription__c> subList =  new List<Zuora__Subscription__c>();
    private static  List<Zuora__Subscription__c> subscriptionToBeUpdated = new List<Zuora__Subscription__c>();
    private static Map<Id, Zuora__Subscription__c> mapSubIdToSubRecord = new Map<Id, Zuora__Subscription__c>(); 
    private static Map<Id, List<Zuora__SubscriptionProductCharge__c>> subToDiscountSPCList = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();
    private static Map<Id,Map<String, Double>> sProdChargeUOMToPrice = new Map<Id,Map<String, Double>>(); // SubscriptionId to Subscription Product & Charge UOM with Price
    private static Map<Id, Id> subIdToPackageIds = new Map<Id, Id>();
    //initialize
    private static List<zqu__ProductRatePlanCharge__c> ratePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
    private static List<Zuora__SubscriptionProductCharge__c> subProdChList = new List<Zuora__SubscriptionProductCharge__c>();//Note this is used in another line
    private static Map<Id, List<String>> subToCoverPrice = new Map<Id, List<String>>();
    private static Map<Id, Set<Id>> subIdToRatePlan = new Map<Id, Set<Id>>();
    private static Set<Id> packageIds = new Set<Id>();
    private static List<Publication__c> pubList;
    private static Set<String> pubcodes = new Set<String>();
    private static Map<Id, List<Package_Item__c>> subIdToPackageItems = new Map<Id, List<Package_Item__c>>();
    //Computation
    private static Map<String, Decimal> mapRefundTotalCredit = new Map<String, Decimal>();
    private static Set<Zuora__SubscriptionProductCharge__c> zSPCDiscount = new Set<Zuora__SubscriptionProductCharge__c>();
    private static List<Zuora__SubscriptionProductCharge__c> zuoSubProdChargListDisc = new List<Zuora__SubscriptionProductCharge__c>();
    private static Map<Id, List<Date>> totalDiscountDateMap = new Map<Id, List<Date>>();
    private static List<Date> zSPCDiscountList = new List<Date>();
    private static Decimal totalDiscountAmount = 0;
    private static Map<String, Decimal> totalIssueAndTotalAmountGetter = new Map<String, Decimal>();
    private static Decimal totalNotDiscountedAmount = 0;
    private static Map<String, Decimal> refundEligibleAndTotalCredit = new Map<String, Decimal>();
    private static Map<Id, Zuora__SubscriptionProductCharge__c> mapSPCIdToSPCRec = new Map<Id, Zuora__SubscriptionProductCharge__c>();
    private static Set<Date> zSPCDiscountSet = new Set<Date>();
    private static Map<Id, Decimal> mapSPCDiscToPrice = new Map<Id, Decimal>();
    private static Map<Date, Id> mapDateToSPC = new Map<Date, Id>();
    private static Map<Id, List<Publication__c>> packageToPubrec = new Map<Id, List<Publication__c>>();
    //get discount
    private static Map<Id, List<Date>> finalDiscountMap = new Map<Id, List<Date>>();
    //comput discount
    private static Decimal totalDiscount = 0;
    private static Decimal totalDiscountPerPub = 0;
    private static  Decimal totalNotDiscounted = 0;
    private static Decimal totalNotDiscountedPerPub = 0;
    private static  Decimal weekdayIssue = 0;
    private static Decimal SaturdayIssue = 0;
    private static   Decimal SundayIssue = 0;
    private static Decimal weekDayDiscount = 0;
    private static Decimal saturdayDiscount = 0;
    private static   Decimal sundayDiscount = 0;
    private static Decimal copyPriceWeekday = 0;
    private static   Decimal copyPriceSaturday = 0;
    private static   Decimal copyPriceSunday = 0;
    private static Decimal weekDayNotDiscounted = 0;
    private static   Decimal saturdayNotDiscounted = 0;
    private static  Decimal sundayNotDiscounted = 0;
    //computnotdiscount
    private static Integer accumulatedNextYear = 0;
    private static Integer accumulatedCurrentYear = 0;
    private static Integer currentYear = 0;
    private static   Integer nextYear = 0;
    private static Map<String, Decimal> totalIssueAndTotalAmount = new Map<String, Decimal>();
    
    //END: D-2012 3/27/2015 JLedesma Issue Calculation
    
    global class EShopResponse{
        String svc_status;
        String error_code; 
        String error_message;
        String subscriberId;
        String subscriptionId;
        String tempStopId;                    
        String debug; //START/END UD-1830 07 July 2015 Kevin Evasco - Hotfix for debugging.     
    }
    
    global class EShopRequest{
        String actionIndicator;
        String subscriberId; 
        String subscriptionId;
        String tempStopId;
        String tempStopDate;
        String restartDate;
        String remarks;
        String source;
        String tempReasonCode;
    }
    
    @httpPOST
    global static EShopResponse processRequest(EShopRequest req){
        Integer flag = 0;
        response.svc_status = GlobalVariableClass.SVC_STATUS_SUCCESS;
        Temp_Stop__c tempStopRecord = new Temp_Stop__c();
        Zuora__Subscription__c subscription = new Zuora__Subscription__c();
        List<Subscription_Temp_Stop__c> existingTempStop = new List<Subscription_Temp_Stop__c>();
        Account account = new account();
        tempStop_Date = convertDate(req.tempStopDate);
        restart_Date = convertDate(req.restartDate);       
        //START UD-1129 07-May-2015 Added by Raviteja - Assigning  req.subscriptionid from zuoraid to subsxription.Name
        List<Zuora__Subscription__c> subscriptionName =  New List<Zuora__Subscription__c>(); 
        subscriptionName = [SELECT Id,Name,Zuora__Zuora_Id__c From Zuora__Subscription__c where Zuora__Zuora_Id__c =: req.subscriptionId LIMIT 1 ];
        List<Temp_Stop_Setting__c> tempstopsettings = [SELECT Name, TempStop_Min_Gap_Days__c, TemStop_Max_Issues__c, TemStop_Min_Issues__c from Temp_Stop_Setting__c LIMIT 1];
        
        if(subscriptionName.size()>0 && subscriptionName[0].Name != Null){
            req.subscriptionid = subscriptionName[0].Name;
        }
        //End UD-1129 07-May-2015 Added by Raviteja   
        try{       
            if(req.subscriberId != '' && req.subscriberId != null){
                account = getAccount(req.subscriberId);
            }
        }catch (Exception e){
            flag = 1;
        }
        //START HotFix 05-Sep-2015 Added by Raviteja - Implemented logic for  Direct_Corporate accounts
        if(account.RecordType.developerName == 'Direct_Corporate')
        {
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
            response.error_message =GlobalVariableClass.ERROR_MESSAGE_INVALID_INPUT+': Temp Stop is not allowed for Corporate Subscribers';   
        }
        //End HotFix 05-Sep-2015 Added by Raviteja   
        try{
            subscription = getSubscription(req);  
            //START KRITHIKA D D-2365
            if(subscription.Qty__c > 1)
            {
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                response.error_code = GlobalVariableClass.ERROR_CODE_MORETHANONE_SUBSCRIPTIONQTY;
                response.error_message =GlobalVariableClass.ERROR_MESSAGE_INVALID_INPUT+': Eshop Subscription with quantity greater than one not supported';   
            }
            //END KRITHIKA D D-2365
        }catch(Exception e){
            if(flag == 1){
                flag = 3;
            } else {
                flag = 2;
            }
        }
        System.debug('req.tempStopId :'+req.tempStopId);
        System.debug('req.actionIndicator  :'+req.actionIndicator);
        if(req.actionIndicator == '' || req.actionIndicator == NULL){
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.ERROR_CODE_MANDATORY;
            response.error_message = GlobalVariableClass.ERROR_MESSAGE_MANDATORY;
        }
        else if(req.actionIndicator == 'ADD' && (req.subscriberId == '' || req.subscriberId == NULL || req.subscriptionId == '' || req.subscriptionId == NULL || 
                                                 req.tempStopDate == '' || req.tempStopDate == NULL || req.restartDate == '' || req.restartDate == NULL || req.source == '' || req.source == NULL || req.tempReasonCode == '')){          
                                                     response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                                                     response.error_code = GlobalVariableClass.ERROR_CODE_MANDATORY;
                                                     response.error_message = GlobalVariableClass.ERROR_MESSAGE_MANDATORY;             
                                                 }
        else if(req.actionIndicator == 'UPDATE' && (req.subscriberId == '' || req.subscriberId == NULL  || req.subscriptionId == '' || req.subscriptionId == NULL || 
                                                    req.tempStopId == '' || req.tempStopId == NULL || req.tempStopDate == '' || req.tempStopDate == NULL || req.restartDate == '' || req.restartDate == NULL || 
                                                    req.source == '' || req.source == NULL || req.tempReasonCode == '' )){
                                                        response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                                                        response.error_code = GlobalVariableClass.ERROR_CODE_MANDATORY;
                                                        response.error_message = GlobalVariableClass.ERROR_MESSAGE_MANDATORY;         
                                                    }
        else if(req.actionIndicator == 'CANCEL' && (req.subscriberId == '' || req.subscriberId == NULL || req.subscriptionId == '' || req.subscriptionId == NULL || 
                                                    req.tempStopId == '' || req.tempStopId == NULL || req.source == '' || req.source == NULL || req.tempReasonCode == '')){
                                                        response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                                                        response.error_code = GlobalVariableClass.ERROR_CODE_MANDATORY;
                                                        response.error_message = GlobalVariableClass.ERROR_MESSAGE_MANDATORY;       
                                                    }
        else if(convertDate(req.tempStopDate) < Date.today() || convertDate(req.restartDate) < Date.today()){
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
            response.error_message = GlobalVariableClass.ERROR_MESSAGE_INVALID_INPUT+' : Temp Stop Date and Restart Date should be a future date';                  
        }
        else if(convertDate(req.tempStopDate) > subscription.Zuora__SubscriptionEndDate__c || convertDate(req.restartDate)  > subscription.Zuora__SubscriptionEndDate__c){
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
            response.error_message = GlobalVariableClass.ERROR_MESSAGE_INVALID_INPUT+' : Temp Stop Date and Restart Date should be earlier than Subcsription End Date';                    
        }   
        else if(convertDate(req.tempStopDate) >= convertDate(req.restartDate)){
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
            response.error_message = GlobalVariableClass.ERROR_MESSAGE_INVALID_INPUT+' : Temp Stop Date should be earlier than Restart Date';              
        }
        else if(!tempstopsettings.isempty() && (tempStop_Date.daysbetween(restart_Date) < tempstopsettings[0].TempStop_Min_Gap_Days__c)){
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
            response.error_message = GlobalVariableClass.ERROR_MESSAGE_INVALID_INPUT+' : ' +  (ConstantsSLB.getErrorMessage('TempStopDateRestartDatePart1') 
                                                                                               + ' ' + tempstopsettings[0].TempStop_Min_Gap_Days__c + ' ' 
                                                                                               + ConstantsSLB.getErrorMessage('TempStopDateRestartDatePart2'));
            
        }
        else if(flag == 1){
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.ERROR_CODE_EITHER;
            response.error_message = GlobalVariableClass.ERROR_MESSAGE_SUBSCRIBER;
        }
        else if(flag == 2){
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.ERROR_CODE_EITHER;
            response.error_message = GlobalVariableClass.ERROR_MESSAGE_SUBSCRIPTION;
        }
        else if(flag == 3){
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.ERROR_CODE_BOTH;
            response.error_message = GlobalVariableClass.ERROR_MESSAGE_BOTH;            
        } 
        // START : D-0926 12/6/2014 Added by Alyana Navarro - Validation for temp stop period more than 3 months.
        else if(!isPeriodValid(req)){
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            response.error_code = GlobalVariableClass.ERROR_CODE_GENERAL;
            response.error_message = GlobalVariableClass.ERROR_MESSAGE_PERIOD;
        }
        // END : D-0926 12/6/2014
        
        if(response.svc_status == GlobalVariableClass.SVC_STATUS_SUCCESS){
            
            Savepoint sp;
            Publication__c publicationObject;
            
            try{
                sp = Database.setSavepoint();
                publicationObject = getPublication(req);
                List<Subscription_Temp_Stop__c> subTemp = new List<Subscription_Temp_Stop__c>();
                List<Subscription_Temp_Stop__c> subTempUpdate = new List<Subscription_Temp_Stop__c>(); 
                
                if(req.actionIndicator == 'ADD'){
                    subTemp = getTempStop(req); 
                    if(convertDate(req.tempStopDate) < publicationObject.earliest_start_date__c){
                        response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                        response.error_code = GlobalVariableClass.ERROR_CODE_TSTOP;
                        response.error_message = GlobalVariableClass.ERROR_MESSAGE_TSTOP;                   
                    }
                    else if(validateOverlapping(subTemp, req)){
                        response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                        response.error_code = GlobalVariableClass.ERROR_CODE_OVERLAPPING;
                        response.error_message = GlobalVariableClass.ERROR_MESSAGE_OVERLAPPING;
                    }
                    else if(checkProductPlatform(req)){
                        response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                        response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
                        response.error_message = GlobalVariableClass.ERROR_MESSAGE_INVALID_INPUT+' : Temp Stop is not allowed for Online Subscriptions';                    
                    }
                    else{
                        tempStopRecord = createTempStopRecord(req);
                    }
                }
                else if(req.actionIndicator == 'UPDATE'){
                    subTempUpdate = getTempStopUpdate(req); 
                    if(convertDate(req.tempStopDate) < publicationObject.earliest_start_date__c){
                        response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                        response.error_code = GlobalVariableClass.ERROR_CODE_TSTOP;
                        response.error_message = GlobalVariableClass.ERROR_MESSAGE_TSTOP;                   
                    }
                    else if(validateOverlapping(subTempUpdate, req)){
                        response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                        response.error_code = GlobalVariableClass.ERROR_CODE_OVERLAPPING;
                        response.error_message = GlobalVariableClass.ERROR_MESSAGE_OVERLAPPING;
                    }
                    else if(checkProductPlatform(req)){
                        response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                        response.error_code = GlobalVariableClass.ERROR_CODE_INVALID_INPUT;
                        response.error_message = GlobalVariableClass.ERROR_MESSAGE_INVALID_INPUT+' : Temp Stop is not allowed for Online Subscriptions';                    
                    }
                    else{
                        tempStopRecord = updateTempStopRecord(req);
                    }                   
                }
                else if(req.actionIndicator == 'CANCEL'){
                    cancelTempStop(req);
                }
                if(tempStopRecord.Id != null){
                    Temp_Stop__c tempStopObj = [SELECT Id, Name FROM Temp_Stop__c WHERE Id =: tempStopRecord.Id];
                    if(tempStopObj.Name != null){
                        response.tempStopId = tempStopObj.Name;
                    }
                }
                response.subscriptionId = subscription.Name;
                response.subscriberId = account.account_auto_number__c;
            }
            catch(DMLException dmle){
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                response.error_code = GlobalVariableClass.ERROR_CODE_GENERAL;
                response.error_message = GlobalVariableClass.ERROR_MESSAGE_GENERAL;
                //START UD-1830 07 July 2015 Kevin Evasco - Hotfix for debugging.
                response.debug += 'Type: ' + dmle.getTypeName() + ' ';
                response.debug += 'Message: ' + dmle.getMessage() + ' ';
                response.debug += 'Stack Trace: ' + dmle.getStackTraceString();
                //END UD-1830 07 July 2015 Kevin Evasco - Hotfix for debugging.
                Database.rollback(sp);              
            }
            catch(Exception e){
                response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
                response.error_code = GlobalVariableClass.ERROR_CODE_GENERAL;
                response.error_message = GlobalVariableClass.ERROR_MESSAGE_GENERAL;
                //START UD-1830 07 July 2015 Kevin Evasco - Hotfix for debuggin.
                response.debug += 'Type: ' + e.getTypeName() + ' ';
                response.debug += 'Message: ' + e.getMessage() + ' ';
                response.debug += 'Stack Trace: ' + e.getStackTraceString();
                //END UD-1830 07 July 2015 Kevin Evasco - Hotfix for debugging.
                Database.rollback(sp);
            }
        } 
        return response;
    }
    
    private static List<Subscription_Temp_Stop__c> getTempStop(EShopRequest req){
        List<Subscription_Temp_Stop__c> tempStopRecordList = new List<Subscription_Temp_Stop__c>();
        
        //START 03 May 2016 D-4797 Kevin Evasco - Added Temp_Stop__r.IsDeleted
        tempStopRecordList = [SELECT id, Name, subscription__c, temp_Stop__c, Temp_Stop__r.Temp_Stop_Date__c,
                              Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Cancelled__c, subscription__r.Name, Temp_Stop__r.IsDeleted
                              FROM Subscription_Temp_Stop__c 
                              WHERE subscription__r.Name =: req.subscriptionId];
        //END 03 May 2016 D-4797 Kevin Evasco - Added Temp_Stop__r.IsDeleted
        
        return tempStopRecordList;
    }
    
    private static List<Subscription_Temp_Stop__c> getTempStopUpdate(EShopRequest req){
        List<Subscription_Temp_Stop__c> tempStopUpdateList = new List<Subscription_Temp_Stop__c>();
        
        //START 03 May 2016 D-4797 Kevin Evasco - Added Temp_Stop__r.IsDeleted
        tempStopUpdateList = [SELECT id, name, subscription__c, Temp_Stop__c, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Name, 
                              Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Cancelled__c, subscription__r.Name,
                              Temp_Stop__r.IsDeleted
                              FROM Subscription_Temp_Stop__c 
                              WHERE subscription__r.Name =: req.subscriptionId AND Temp_Stop__r.Name !=: req.tempStopId];       
        //END 03 May 2016 D-4797 Kevin Evasco - Added Temp_Stop__r.IsDeleted
        
        return tempStopUpdateList;
    }   
    
    private static Boolean validateOverlapping(List<Subscription_Temp_Stop__c> subTempRecord, EShopRequest req){
        Boolean returnValue = false;
        Date startPrev;
        Date endPrev;
        Date startInput = tempStop_Date;
        Date endInput = restart_Date;
        //START 03 May 2016 Kevin Evasco - Only consider overlapping temp stop if it is not deleted
        for(Subscription_Temp_Stop__c subTemp : subTempRecord){
            if(!subTemp.temp_stop__r.cancelled__c && !subTemp.temp_stop__r.IsDeleted){
                if(subTemp.subscription__r.Name == req.subscriptionId){
                    startPrev = subTemp.Temp_Stop__r.Temp_Stop_Date__c;
                    endPrev = subTemp.Temp_Stop__r.Restart_Date__c;                    
                    if((startprev >= startinput && startprev <= endinput) ||                
                       (endprev >= startinput && endprev <= endinput) ||                            
                       (startprev <= startinput && endprev >= endinput) ||
                       (startprev >= startinput && endprev <= endinput)){            
                           returnValue = true;
                       }
                }
            }
        }
        //END 03 May 2016 Kevin Evasco - Only consider overlapping temp stop if it is not deleted        
        return returnValue;
    }
    
    private static Account getAccount(String subscriberId){
        Account accountRecord = new Account();
        //START HotFix 05-Sep-2015 Added by Raviteja - Added RecordType.developerName in SOQL 
        //accountRecord = [SELECT id, name, account_auto_number__c FROM Account WHERE account_auto_number__c =: subscriberId];
        accountRecord = [SELECT id, name, account_auto_number__c,RecordType.developerName FROM Account WHERE account_auto_number__c =: subscriberId];
        //End HotFix 05-Sep-2015 Added by Raviteja         
        return accountRecord;
    }   
    //START: D-2012 3/27/2015 JLedesma Issue Calculation   
    private static Zuora__Subscription__c getSubscription(EShopRequest req){
        Account account = getAccount(req.subscriberId);
        Zuora__Subscription__c subscription = new Zuora__Subscription__c();
        
        //START: D-1357 01/23/2015 Added by S.Puli include contact details in SOQL
        //START: D-1360 01/27/2015 Added by S.Puli
        //START: D-2365 25/02/2015 Added Qty__c by Krithika D
        //START UD-1129 07-May-2015 Added by Raviteja - Added Order_Line_Item_Number_1__r.Ph_d__c in SOQL// END
        //START PD-0114 10-May-2016 Added by Raviteja - Added Order_Line_Item_Number_1__r.Ph_e__c in SOQL // END
        subscription = [SELECT id,Qty__c,name, Vendor_Subscription_To_Convert_1__r.Temp_Stop_Count_Year_to_Date__c, Year_to_Date_Temp_Stop_Days__c, Zuora__SubscriptionStartDate__c, 
                        Zuora__SubscriptionEndDate__c, Recipient_Contact__c, Recipient_Contact__r.Name, Zuora__Status__c,Next_Year_Temp_Stop_Days__c,
                        Order_Line_Item_Number_1__r.Main_Package_Frequency__c, Order_Line_Item_Number_1__r.Ph_d__c, Order_Line_Item_Number_1__r.Ph_e__c ,  Ph_d__c, Ph_e__c,Recipient_Address_ID__c,
                        Main_Package_1__r.Name,Previous_Year_Temp_Stop_Days__c,Subscription_Type_1__c,Zuora__CustomerAccount__r.Name, 
                        Main_Package_1__r.Id,Zuora__CustomerAccount__r.Id,Delivery_Charge__c,Frequency_1__c,Recipient_Contact__r.Id,Number_of_Copies__c 
                        FROM Zuora__Subscription__c WHERE Name =: req.subscriptionId AND Zuora__Account__c =: account.id];
        
        //END: D-2365 25/02/2015 Added Qty__c by Krithika D
        //END: D-1360 01/27/2015 Added by S.Puli
        //END: D-1357 01/23/2015 Added by S.Puli
        
        return subscription;
    }
    
    private static Temp_Stop__c createTempStopRecord(EShopRequest req){    
        Decimal currentCount = 0;
        Decimal nextCount = 0;
        tempStop.temp_stop_date__c = tempStop_Date;
        tempStop.restart_date__c = date.valueOf(restart_Date);
        tempStop.remarks__c = req.remarks;
        
        //KRITHIKA D D-2012 START
        Zuora__Subscription__c sub = getSubscription(req);
        if(sub.id!=NULL && req.tempStopDate!= NULL && req.restartDate!=NULL){
            mapRefundTotalCredit = computation(sub, sub.id, tempStop_Date,  restart_Date, 1);
            tempStop.Qty__c = mapRefundTotalCredit.get('qty');
            tempStop.Request_Total_Credit__c = mapRefundTotalCredit.get('credit');
            tempStop.Request_Total_Issue__c = Integer.valueOf(mapRefundTotalCredit.get('issue'));
            tempStop.Year_To_Date_Count__c = mapRefundTotalCredit.get('current');
            nextCount = mapRefundTotalCredit.get('next');
        }
        else{
            tempStop.Year_To_Date_Count__c = 0;
            tempStop.Qty__c = 0;
            tempStop.Request_Total_Credit__c = 0;
            tempStop.Request_Total_Issue__c = 0;
        }
        //KRITHIKA D D-2012 END
        insert tempStop;
        
        createOrderRecord(req);
        createCaseRecord(req, tempStop.Request_Total_Credit__c, tempStop.Request_Total_Issue__c,mapRefundTotalCredit.get('current'), mapRefundTotalCredit.get('next'), sub,GlobalVariableClass.TS_CREATE);
        tempStop.case__c = newCase.id;
        tempStop.order__c = order.id;
        
        update tempStop;
        sub.Year_to_Date_Temp_Stop_Days__c = tempStop.Year_To_Date_Count__c;
        sub.Next_Year_Temp_Stop_Days__c = nextCount;
        //START: UD-1830 7/13/2015 Avoid looping of Trigger
        //update sub;
        //END: UD-1830 7/13/2015 Avoid looping of Trigger
        createSubscritpionTempStopRecord(req);
        
        return tempStop;
    } 
    
    private static void createOrderRecord(EShopRequest req){
        Account account = getAccount(req.subscriberId); 
        Zuora__Subscription__c orderSubscription = getSubscription(req);
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
        order.Acquisition_Type__c = 'ESHOP / ECOMZ (ONLINE)';
        if(orderSubscription != null){
            order.Base_Subscription__c = orderSubscription.Id;
        }
        
        insert order;
    }
    
    private static void createSubscritpionTempStopRecord(EShopRequest req){
        Subscription_Temp_Stop__c subTempStop = new Subscription_Temp_Stop__c();
        Zuora__Subscription__c subscription = getSubscription(req);
        //START: D-1360 01/27/2015 Added by S.Puli
        if(subscription.Zuora__Status__c <> GlobalVariableClass.STATUS_CANCELLED){
            //END: D-1360 01/27/2015 Added by S.Puli
            subTempStop.subscription__c = subscription.id;
            subTempStop.temp_stop__c = tempStop.id;
            
            insert subTempStop;
            //START: D-1360 01/27/2015 Added by S.Puli
        } else{
            response.svc_status = GlobalVariableClass.SVC_STATUS_FAILURE;
            //START: D-1933,1938 01/28/2015 Added by S.Puli update fields
            response.error_code = GlobalVariableClass.ERROR_CODE_TS_SUBS_CANCELLED;
            response.error_message = OnlineExceptions.getErrorMessage(GlobalVariableClass.ERROR_CODE_TS_SUBS_CANCELLED);
            //END: D-1933,1938 01/28/2015 Added by S.Puli update fields
        }
        //END: D-1360 01/27/2015 Added by S.Puli
    }
    
    private static void createCaseRecord(EShopRequest req, Decimal credits, Decimal issues, Decimal current, Decimal next, Zuora__Subscription__c subscriptionObj,String tempstoptype){   
        Account accountObj = getAccount(req.subscriberId);
        //START: D-1120 Jerella Ledesma 12/18/2014 Populated 'Account' field
        newCase.AccountId = accountObj.Id;
        //END: D-1120 Jerella Ledesma 12/18/2014
        //KRITHIKA D D-2198 02/03/2015
        newCase.RecordTypeId = ConstantsSLB.getKeyId('Case_Temp Stop');        
        newCase.category__c = GlobalVariableClass.TS_SUBSCRIPTION_REQUEST;
        newCase.subject = GlobalVariableClass.TS_SUBJECT;//KRITHIKA D D-2198 25/02/2015
        newCase.Status = GlobalVariableClass.TS_CLOSED;//KRITHIKA D D-2198 25/02/2015
        newCase.Sub_Status__c = GlobalVariableClass.TS_APPROVED;//KRITHIKA D D-2198 25/02/2015
        newCase.Temp_Stop_Sub__c = subscriptionObj.Id;//KRITHIKA D D-2198 02/03/2015
        newCase.temp_stop__c = tempStop.id;        
        newCase.temp_stop_type__c = tempstoptype;
        newCase.temp_stop_date__c = tempStop_date;
        newCase.restart_date__c = restart_date;
        newCase.remarks__c = req.remarks;
        newCase.order__c = order.id;
        newCase.Origin = req.source;
        //START: PD-0434 06/01/2016 CCamilon CaseSubRecord
        newCase.POP_Start_Date__c = (Date)earliestStart(subscriptionObj);
        //END: PD-0434 06/01/2016 CCamilon CaseSubRecord
        newCase.Total_Issue__c = issues;
        newCase.Request_Total_Credit__c = credits; 
        newCase.Current_Date_for_Year_To_Date__c = current;
        newCase.Next_Year_for_Year_To_Date__c = next;
        newCase.Year_To_Date_Count__c = current + next;
        newCase.Temp_Stop_Sub__c = subscriptionObj.Id;
        newCase.Qty__c = 1; //START/END UD-1830 07 July 2015 Kevin Evasco - Case Quantity should be 1    
        insert newCase;  
        order.Case_Owner__c = newCase.id;
        order.status__c = 'Close';
        update order;

        createCaseSubRecord(newCase, subscriptionObj, accountObj);
       
        
    }
    //END: D-2012 3/27/2015 JLedesma Issue Calculation
    private static Boolean checkProductPlatform(EShopRequest req){
        List<Zuora__SubscriptionProductCharge__c> subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();
        zqu__ZProduct__c productObj = new zqu__ZProduct__c();
        Boolean isDigital = false;
        
        if(req.subscriptionId != '' && req.subscriptionId != null){
            subProdChargeList = [SELECT Zuora__RatePlanName__c, Zuora__Subscription__c, Zuora__Subscription__r.Name, Zuora__ProductSKU__c
                                 FROM Zuora__SubscriptionProductCharge__c
                                 WHERE Zuora__Subscription__r.Name =: req.subscriptionId LIMIT 1];
            if(subProdChargeList.size() > 0){
                productObj = [SELECT ProductPlatform__c FROM zqu__ZProduct__c WHERE zqu__SKU__c =: subProdChargeList[0].Zuora__ProductSKU__c];
                if(productObj.ProductPlatform__c == 'Online' || productObj.ProductPlatform__c == 'Smartphone' || productObj.ProductPlatform__c == 'Tablet'){
                    isDigital = true;
                }
            }
        }
        return isDigital;
    }
    
    private static Publication__c getPublication(EShopRequest req){
        Set<String> ratePlanNameSet = new Set<String>();
        Set<String> ratePlanIdSet = new Set<String>();
        Set<String> publicationCodeSet = new Set<String>();        
        List<Zuora__SubscriptionProductCharge__c> subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();
        List<zqu__ProductRatePlan__c> ratePlanList = new List<zqu__ProductRatePlan__c>();
        List<zqu__ProductRatePlanCharge__c> prodRatePlanList = new List<zqu__ProductRatePlanCharge__c>();
        List<Publication__c> publicationList = new List<Publication__c>();
        Publication__c publicationEarliestStartDate = new Publication__c();
        
        if(req.subscriptionId != '' && req.subscriptionId != null){
            subProdChargeList = [SELECT Zuora__RatePlanName__c, Zuora__Subscription__c, Zuora__Subscription__r.Name
                                 FROM Zuora__SubscriptionProductCharge__c
                                 WHERE Zuora__Subscription__r.Name =: req.subscriptionId];
            if(subProdChargeList != null){
                for(Zuora__SubscriptionProductCharge__c subProdCharge : subProdChargeList){
                    ratePlanNameSet.add(subProdCharge.Zuora__RatePlanName__c);
                }
            }
            if(ratePlanNameSet != null){
                ratePlanList = [SELECT Id, Name, SubscriptionFrequency__c
                                FROM zqu__ProductRatePlan__c 
                                WHERE name IN :ratePlanNameSet];
            }
            if(ratePlanList != null){
                for(zqu__ProductRatePlan__c ratePlanAccess : ratePlanList){
                    ratePlanIdSet.add(ratePlanAccess.id);
                }
            }
            if(ratePlanIdSet != null){
                prodRatePlanList = [SELECT publicationcode__c, zqu__ProductRatePlan__c 
                                    FROM zqu__ProductRatePlanCharge__c 
                                    WHERE zqu__ProductRatePlan__c IN :ratePlanIdSet];
            }
            if(prodRatePlanList != null){
                for(zqu__ProductRatePlanCharge__c pubCodeAccess : prodRatePlanList){
                    publicationCodeSet.add(pubCodeAccess.publicationcode__c);
                }
            }
            if(publicationCodeSet != null){
                publicationList = [SELECT earliest_start_date__c, publication_code__c FROM Publication__c 
                                   WHERE publication_code__c IN :publicationCodeSet 
                                   ORDER BY earliest_start_date__c ASC];
            }
            
        }
        if(publicationList != null){
            return publicationList[0];  
        }
        else{
            return publicationEarliestStartDate;
        }
    }
    //START: D-2012 3/27/2015 JLedesma Issue Calculation
    private static Temp_Stop__c updateTempStopRecord(EShopRequest req){
        Order__c oldOrder;
        Case oldCase;
        Order__c newOrder = new Order__c();
        Case caseUpdate = new Case();
        Decimal current = 0;
        Decimal nextCount = 0;
        //START: D-1933,1938 01/28/2015 Added by S.Puli update fields
        Temp_Stop__c tempStopRecordUpdate = [SELECT Case__r.Next_Year_for_Year_To_Date__c, Case__r.Current_Date_for_Year_To_Date__c, Id, Name, temp_stop_date__c, 
                                             restart_date__c, remarks__c, Case__c, Order__c, Qty__c,Request_Total_Issue__c 
                                             FROM Temp_Stop__c 
                                             WHERE Name =: req.tempStopId];
        //END: D-1933,1938 01/28/2015 Added by S.Puli update fields
        tempStop = new Temp_Stop__c();
        tempStop.temp_stop_date__c = tempStop_Date;
        tempStop.restart_date__c = date.valueOf(restart_Date);
        tempStop.remarks__c = req.remarks;
        tempStopRecordUpdate.Cancelled__c = TRUE;
        update tempStopRecordUpdate;
        
        Zuora__Subscription__c sub = getSubscription(req);
        if(sub.id!=NULL && req.tempStopDate!= NULL && req.restartDate!=NULL){
            mapRefundTotalCredit = computation(sub, sub.id, tempStop_Date,  restart_Date, 1);
            System.debug('\\\\\\\\\\\\' + mapRefundTotalCredit);
            tempStop.Qty__c = mapRefundTotalCredit.get('qty');
            tempStop.Request_Total_Credit__c = mapRefundTotalCredit.get('credit');
            tempStop.Request_Total_Issue__c = Integer.valueOf(mapRefundTotalCredit.get('issue'));
            current = mapRefundTotalCredit.get('current');
            tempStop.Year_To_Date_Count__c = current;
            nextCount = mapRefundTotalCredit.get('next');
        }
        else{
            tempStop.Year_To_Date_Count__c = current;
            tempStop.Qty__c = 0;
            tempStop.Request_Total_Credit__c = 0;
            tempStop.Request_Total_Issue__c = 0;
        }
        //KRITHIKA D D-2012 END
        System.debug('tempStop' + tempStop);
        insert tempStop;
        
        createOrderRecord(req);
        createCaseRecord(req, tempStop.Request_Total_Credit__c, tempStop.Request_Total_Issue__c,(mapRefundTotalCredit.get('current')), mapRefundTotalCredit.get('next'), sub,GlobalVariableClass.TS_UPDATE);
        tempStop.case__c = newCase.id;
        tempStop.order__c = order.id;
        
        update tempStop;
        sub.Year_to_Date_Temp_Stop_Days__c = (sub.Year_to_Date_Temp_Stop_Days__c- tempStopRecordUpdate.Case__r.Current_Date_for_Year_To_Date__c) + current;
        sub.Next_Year_Temp_Stop_Days__c = (sub.Next_Year_Temp_Stop_Days__c - tempStopRecordUpdate.Case__r.Next_Year_for_Year_To_Date__c) + nextCount;
        //START: UD-1830 7/13/2015 Avoid looping of Trigger
        //update sub;
        //END: UD-1830 7/13/2015 Avoid looping of Trigger
        createSubscritpionTempStopRecord(req);
        
        return tempStop; //START/END 04 January 2016 UD-3489 Kevin Evasco - Return the new temp stop instead of the updated temp stop.
    }
    //END: D-2012 3/27/2015 JLedesma Issue Calculation
    
    private static void cancelTempStop(EShopRequest req){
        Case caseRecordToClose;
        Order__c orderRecordToClose;
        
        if(req.tempStopId != '' && req.tempStopId != null){
            Temp_Stop__c tempStopRecordCancel = [SELECT Id, Name, Cancelled__c, Case__c, Order__c FROM Temp_Stop__c WHERE Name =: req.tempStopId];
            tempStopRecordCancel.Cancelled__c = true;
            update tempStopRecordCancel;
            
            if(tempStopRecordCancel.Case__c != null){
                caseRecordToClose = [SELECT Id, Status FROM Case WHERE Id =: tempStopRecordCancel.Case__c];
                //START: D-1357 01/23/2015 Added by S.Puli update case fields
                //START: D-1933,1938 01/28/2015 Added by S.Puli remove hardcode
                caseRecordToClose.Status = GlobalVariableClass.STATUS_CLOSED;
                caseRecordToClose.Origin = GlobalVariableClass.CASE_ORIGIN_ESHOP;
                //END: D-1933,1938 01/28/2015 Added by S.Puli
                caseRecordToClose.ContactId = getSubscription(req).Recipient_Contact__r.Id;
                //END: D-1357 01/23/2015 Added by S.Puli
                update caseRecordToClose;
            }
            
            if(tempStopRecordCancel.Order__c != null){
                orderRecordToClose = [SELECT Id, Status__c FROM Order__c WHERE Id =: tempStopRecordCancel.Order__c];
                //START: D-1933,1938 01/28/2015 Added by S.Puli update fields remove hardcode
                orderRecordToClose.Status__c = GlobalVariableClass.STATUS_CANCELLED;
                //START: D-1357 01/23/2015 Added by S.Puli update order fields
                orderRecordToClose.Order_Status__c = GlobalVariableClass.STATUS_CANCELLED;
                orderRecordToClose.Acquisition_Type__c = GlobalVariableClass.ACQTYPE_ESHOP_ECOMZ_ONLINE;
                //END: D-1933,1938 01/28/2015 Added by S.Puli
                //END: D-1357 01/23/2015 Added by S.Puli
                update orderRecordToClose;
            }
        }
    }
    
    
    private static Date convertDate(String myDate){
        Date d;
        try{
            String[] myDateOnly = myDate.split(' ');
            String[] strDate = myDateOnly[0].split('/');
            //START: D-1357 01/23/2015 Added by S.Puli correct date format
            Integer myIntDay = integer.valueOf(strDate[0]);       
            Integer myIntMonth = integer.valueOf(strDate[1]);
            //END: D-1357 01/23/2015 Added by S.Puli
            Integer myIntYear = integer.valueOf(strDate[2]);            
            d = Date.newInstance(myIntYear, myIntMonth, myIntDay);
        } catch(Exception e){
            d = null;
        }
        
        return d;
    }
    // START : D-0926 12/6/2014 Added by Alyana Navarro - Validation for temp stop period more than 3 months.
    private static Boolean isPeriodValid(EshopRequest req){
        Date tempStopLoc = convertDate(req.tempStopDate);
        Date restartLoc = convertDate(req.restartDate);       
        Integer monthsBet = tempStopLoc.monthsBetween(restartLoc) - 1;
        Boolean flag = true;
        
        if(monthsBet == 2){
            if(tempStopLoc.day() < restartLoc.day()){
                flag = false;
            }
        } else if(monthsBet > 2){
            flag = false;
        }
        return flag;
    }
    // END : D-0926 12/6/2014
    //START: D-2012 3/27/2015 JLedesma Issue Calculation
    private static Map<String, Decimal> computation(Zuora__Subscription__c zsub, Id subId, Date TempStopdate, Date RestartDate, Integer qty){
        
        subProdChList = [SELECT Zuora__EffectiveStartDate__c, Zuora__Model__c, Zuora__ProductName__c, Zuora__Subscription__r.Ph_d__c, Zuora__Subscription__r.Ph_e__c, 
                         Name, Zuora__Quantity__c, Zuora__UOM__c, Zuora__Price__c, Zuora__Subscription__c, Zuora__ProductSKU__c, PublicationCode__c, Zuora__RatePlanName__c 
                         FROM Zuora__SubscriptionProductCharge__c 
                         where Zuora__Subscription__c = : subId];
        
        List<Package_Item__c> packItemsInitial = [SELECT Package__c, Product_Rate_Plan__c, Id, Is_Print__c, Is_All_In_One__c, Is_Newspaper__c, 
                                                  RecordType.developerName 
                                                  FROM Package_Item__c 
                                                  WHERE Package__c =:  zsub.Main_Package_1__c AND Is_Newspaper__c = TRUE 
                                                  AND (Is_Print__c=TRUE OR Is_All_In_One__c=TRUE)];
        
        List<Package_Item__c> pckItems = new List<Package_Item__c>();
        Set<String> pubcodeList = new Set<String>();
        Set<String> prpIds = new Set<String>();
        
        for(Package_Item__c p : packItemsInitial){
            if(p.RecordType.developerName.contains('Base_Product') || p.RecordType.developerName.contains('Bundle_Product')){
                pckItems.add(p);
                prpIds.add(p.Product_Rate_Plan__c);
            }
        }
        
        ratePlanChargeList = [SELECT Id, Name, PublicationCode__c, zqu__ProductRatePlan__c, zqu__ProductRatePlan__r.Name 
                              from zqu__ProductRatePlanCharge__c 
                              WHERE zqu__ProductRatePlan__c IN :prpIds];
        
        for(zqu__ProductRatePlanCharge__c prpc : ratePlanChargeList){
            pubcodeList.add(prpc.PublicationCode__c);
        }
        
        pubList = [SELECT Id, Name, Platform_Type__c, Publication_Code__c, Published_Days__c, Earliest_Start_Date__c from Publication__c WHERE Publication_Code__c IN : pubcodeList];             
        
        
        for(Zuora__SubscriptionProductCharge__c z : subProdChList){
            if(z.Zuora__Model__c == ConstantsSLB.getUOM('Discount-Percentage') && z.Zuora__ProductName__c.toLowerCase() == 'discount' && z.Zuora__Subscription__c == subId){
                zuoSubProdChargListDisc.add(z);
            }
            if(z.Zuora__UOM__c == 'Copy Weekday'){
                copyPriceWeekday = z.Zuora__Price__c;
            }
            if(z.Zuora__UOM__c == 'Copy Sat'){
                copyPriceSaturday = z.Zuora__Price__c;
            }
            if(z.Zuora__UOM__c == 'Copy Sun'){
                copyPriceSunday = z.Zuora__Price__c;
            }
        }
        
        
        for(Zuora__SubscriptionProductCharge__c zSPC : zuoSubProdChargListDisc){
            mapSPCIdToSPCRec.put(zSPC.Id, zSPC);
            zSPCDiscount.add(zSPC);
            if(!zSPCDiscountSet.contains(zSPC.Zuora__EffectiveStartDate__c)){
                zSPCDiscountSet.add(zSPC.Zuora__EffectiveStartDate__c);
                zSPCDiscountList.add(zSPC.Zuora__EffectiveStartDate__c);
            }
        }
        for(Zuora__SubscriptionProductCharge__c spcDisc : zSPCDiscount){
            mapSPCDiscToPrice.put(spcDisc.Id, spcDisc.Zuora__Price__c);
            mapDateToSPC.put(spcDisc.Zuora__EffectiveStartDate__c, spcDisc.Id);
        }
        
        
        totalIssueAndTotalAmountGetter = computeNotDiscounted(pubList, subId, qty, TempStopdate, RestartDate, zsub, copyPriceWeekday, copyPriceSaturday, copyPriceSunday);
        totalNotDiscountedAmount = totalIssueAndTotalAmountGetter.get('amount');
        Decimal totalIssue = totalIssueAndTotalAmountGetter.get('issues');            
        totalDiscountAmount = computeDiscount(pubList, subId, qty);            
        Decimal total = totalNotDiscountedAmount - totalDiscountAmount;
        refundEligibleAndTotalCredit.put('tempStopDays', totalIssue/qty);
        refundEligibleAndTotalCredit.put('refund', totalIssue*qty);            
        if(totalIssue < 8){
            total = 0;
        }
        
        refundEligibleAndTotalCredit.put('credit', total);  
        refundEligibleAndTotalCredit.put('issue', totalIssue);                 
        refundEligibleAndTotalCredit.put('current', Integer.valueOf(totalIssueAndTotalAmountGetter.get('current')));
        refundEligibleAndTotalCredit.put('next', Integer.valueOf(totalIssueAndTotalAmountGetter.get('next')));
        refundEligibleAndTotalCredit.put('qty', qty);
        return refundEligibleAndTotalCredit;
        
    }
    
    private static Map<Id, List<Date>> getDiscount(Date strDate, Date enDate, List<Date> zSPCDiscountListtemp){
        Integer counter;
        finalDiscountMap = new Map<Id, List<Date>>();
        for(counter = 0; counter < zSPCDiscountListtemp.size(); counter++){
            if(zSPCDiscountListtemp[counter] >= strDate && zSPCDiscountListtemp[counter] <= enDate-1){
                if(counter != zSPCDiscountListtemp.size()-1){
                    finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountListtemp[counter]), new List<Date>{zSPCDiscountListtemp[counter], zSPCDiscountListtemp[counter + 1] - 1});
                } 
                else {
                    finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountListtemp[counter]), new List<Date>{zSPCDiscountListtemp[counter], enDate-1});
                }
            }
            else if(zSPCDiscountListtemp[counter] < strDate && zSPCDiscountListtemp[counter] <= enDate-1){
                if(counter == 0){
                    if(zSPCDiscountListtemp.size() > counter+1){
                        finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountListtemp[counter]), new List<Date>{strDate , zSPCDiscountListtemp[counter + 1] - 1});
                    }
                    else{
                        finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountListtemp[counter]), new List<Date>{strDate , enDate-1});
                    }
                }
                else{
                    finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountListtemp[counter]), new List<Date>{zSPCDiscountListtemp[counter], enDate-1});
                }
            }
            
        }
        
        return finalDiscountMap;
    }  
    
    private static Decimal computeDiscount(List<Publication__c> publicationList, Id subId, Integer qty){    
        Zuora__Subscription__c zuoSubscrpt = new Zuora__Subscription__c();
        zuoSubscrpt = mapIdToSubRec.get(subId);
        totalDiscount = 0;
        totalDiscountPerPub = 0.00;
        for(Id spcDiscountId : totalDiscountDateMap.keySet()){
            List<Date> discountRange = totalDiscountDateMap.get(spcDiscountId);
            for(Publication__c pubRec : publicationList){
                
                PublicationIssueWrapper pubWrapperDiscount = UsageHelper.IssueCalculation(pubRec.Publication_Code__c, discountRange[0], discountRange[1], zuoSubscrpt, qty);
                weekdayIssue = Decimal.valueOf(pubWrapperDiscount.weekday_no_of_copies);
                SaturdayIssue = Decimal.valueOf(pubWrapperDiscount.sat_no_of_copies);
                SundayIssue = Decimal.valueOf(pubWrapperDiscount.sun_no_of_copies);
                
                weekDayDiscount = 0.00;
                saturdayDiscount = 0.00;
                sundayDiscount = 0.00;
                List<String> coverPrices = new List<String>();
                coverPrices = subToCoverPrice.get(subId);
                
                for(String s : coverPrices){
                    if(s.contains('wkd')){
                        copyPriceWeekday = Decimal.valueOf(s.subString(3));
                        weekDayDiscount = (Math.abs(copyPriceWeekday) * (mapSPCDiscToPrice.get(spcDiscountId)/100)) * weekdayIssue;
                    }
                    else if(s.contains('sat')){
                        copyPriceSaturday = Decimal.valueOf(s.subString(3));
                        saturdayDiscount = (Math.abs(copyPriceSaturday) * (mapSPCDiscToPrice.get(spcDiscountId)/100)) * SaturdayIssue;
                    }
                    else if(s.contains('sun')){
                        copyPriceSunday = Decimal.valueOf(s.subString(3));
                        sundayDiscount = (Math.abs(copyPriceSunday) * (mapSPCDiscToPrice.get(spcDiscountId)/100)) * SundayIssue;
                    }
                }
                totalDiscountPerPub += weekDayDiscount + saturdayDiscount + sundayDiscount;
            }
            totalDiscount += totalDiscountPerPub;
            
        }
        return totalDiscount;
    }
    
    private static Map<String, Decimal> computeNotDiscounted(List<Publication__c> publicationList, Id subId, Integer qty, Date start, Date endDate, 
                                                             Zuora__Subscription__c zuoSubscrpt, Decimal PriceWeekday, Decimal PriceSaturday, Decimal PriceSunday){ 
                                                                 totalNotDiscountedPerPub = 0.00;
                                                                 totalNotDiscounted = 0.00;
                                                                 Decimal allIssues = 0.00;
                                                                 Decimal totalIssue = 0.00;
                                                                 AccumulatedNextYear = 0;
                                                                 AccumulatedCurrentYear = 0;
                                                                 Decimal totalweekdayIssue = 0;
                                                                 Decimal totalSaturdayIssue = 0;
                                                                 Decimal totalSundayIssue = 0;
                                                                 for(Date tempDate = start; tempDate<endDate; tempDate=tempDate.addDays(1)){
                                                                     for(Publication__c pubRec : publicationList){
                                                                         currentYear = 0;
                                                                         nextYear = 0;
                                                                         UsageHelper.initialize();
                                                                         //PublicationIssueWrapper pubWrapperDiscount = UsageHelper.IssueCalculation(pubRec.Publication_Code__c, start, endDate-1, zuoSubscrpt, qty);
                                                                         PublicationIssueWrapper pubWrapperDiscount = UsageHelper.IssueCalculation(pubRec.Publication_Code__c, tempDate, tempDate, zuoSubscrpt, qty);
                                                                         weekdayIssue = Decimal.valueOf(pubWrapperDiscount.weekday_no_of_copies);
                                                                         SaturdayIssue = Decimal.valueOf(pubWrapperDiscount.sat_no_of_copies);
                                                                         SundayIssue = Decimal.valueOf(pubWrapperDiscount.sun_no_of_copies);
                                                                         currentYear = pubWrapperDiscount.current_year_days;  
                                                                         nextYear = pubWrapperDiscount.next_year_days;   
                                                                         allIssues += weekdayIssue + SaturdayIssue + SundayIssue;
                                                                         
                                                                         AccumulatedCurrentYear += currentYear;
                                                                         AccumulatedNextYear += nextYear;
                                                                         if(tempDate.year() == date.today().year() && zuoSubscrpt.Year_to_Date_Temp_Stop_Days__c+AccumulatedCurrentYear <= 30){
                                                                             totalweekdayIssue += weekdayIssue;
                                                                             totalSaturdayIssue += SaturdayIssue;
                                                                             totalSundayIssue += SundayIssue;
                                                                         }
                                                                         else if(tempDate.year() != date.today().year() && zuoSubscrpt.Next_Year_Temp_Stop_Days__c+AccumulatedNextYear <= 30){
                                                                             totalweekdayIssue += weekdayIssue;
                                                                             totalSaturdayIssue += SaturdayIssue;
                                                                             totalSundayIssue += SundayIssue;
                                                                         }            
                                                                     }   
                                                                 }
                                                                 //totalIssue = allIssues;
                                                                 totalIssue = totalweekdayIssue + totalSaturdayIssue + totalSundayIssue ;
                                                                 
                                                                 weekDayNotDiscounted = (Math.abs(PriceWeekday) * totalweekdayIssue);
                                                                 saturdayNotDiscounted = (Math.abs(PriceSaturday) * totalSaturdayIssue);
                                                                 sundayNotDiscounted = (Math.abs(PriceSunday) * totalSundayIssue);
                                                                 totalNotDiscountedPerPub += weekDayNotDiscounted + saturdayNotDiscounted+ sundayNotDiscounted;
                                                                 totalNotDiscounted += totalNotDiscountedPerPub;
                                                                 
                                                                 
                                                                 totalIssueAndTotalAmount.put('issues', totalIssue);
                                                                 totalIssueAndTotalAmount.put('amount', totalNotDiscounted);
                                                                 totalIssueAndTotalAmount.put('current', AccumulatedCurrentYear);
                                                                 totalIssueAndTotalAmount.put('next', AccumulatedNextYear);
                                                                 return totalIssueAndTotalAmount;
                                                             }
    //END: D-2012 3/27/2015 JLedesma Issue Calculation
    //START: PD-0308 5/31/2016 CCamilon CaseSubRecord
    private static void createCaseSubRecord(Case caseObj,  Zuora__Subscription__c subscriptionObj, Account accountObj){
        
        Case_Subscription__c newCaseSub = new Case_Subscription__c();
        newCaseSub.Account__c = accountObj.id;
        newCaseSub.Case__c = caseObj.id;
        newCaseSub.Subscription__c = subscriptionObj.id;
        insert newCaseSub;
        
    }
    //END PD-0308 5/31/2016 CCamilon CaseSubRecord
    //START: PD-0434 06/01/2016 CCamilon CaseSubRecord
       private static Date earliestStart(Zuora__Subscription__c sub){
        String copySun = ConstantsSLB.getUOM('Copy Sun');
        String copyWeek = ConstantsSLB.getUOM('Copy Weekday');
        String copySat = ConstantsSLB.getUOM('Copy Sat');
        String discPer = ConstantsSLB.getUOM('Discount-Percentage');
        Set<String> UOMSet = new Set<String>{copySun, copyWeek, copySat, discPer};
        Map<Id, List<String>> nsubToCoverPrice = new Map<Id, List<String>>();
        Map<Id, String> subIdToProductCodeMap = new Map<Id, String>();
        
        List<Zuora__SubscriptionProductCharge__c> nsubProdChList = [SELECT Zuora__EffectiveStartDate__c, Zuora__Model__c, Zuora__ProductName__c, Zuora__Subscription__r.Ph_d__c, Zuora__Subscription__r.Ph_e__c, Name, Zuora__Quantity__c, Zuora__UOM__c, Zuora__Price__c, Zuora__Subscription__c, Zuora__ProductSKU__c, PublicationCode__c, Zuora__RatePlanName__c, Zuora__Subscription__r.Product_Code__c FROM Zuora__SubscriptionProductCharge__c where Zuora__Subscription__c = : sub.id AND Zuora__UOM__c IN : UOMSet];
        system.debug('nsubProdChList' + nsubProdChList);
        for(Zuora__SubscriptionProductCharge__c s: nsubProdChList){
                
                if(nsubToCoverPrice.containsKey(s.Zuora__Subscription__c)){            
                    if(s.Zuora__UOM__c == 'Copy Weekday'){
                        nsubToCoverPrice.get(s.Zuora__Subscription__c).add('wkd' + s.Zuora__Price__c);
                    }   
                    if(s.Zuora__UOM__c == 'Copy Sat'){
                        nsubToCoverPrice.get(s.Zuora__Subscription__c).add('sat' + s.Zuora__Price__c);
                    }
                    if(s.Zuora__UOM__c == 'Copy Sun'){
                        nsubToCoverPrice.get(s.Zuora__Subscription__c).add('sun' + s.Zuora__Price__c);
                    }
                } else {
                    nsubToCoverPrice.put(s.Zuora__Subscription__c, new List<String>());
                    if(s.Zuora__UOM__c == 'Copy Weekday'){
                        nsubToCoverPrice.get(s.Zuora__Subscription__c).add('wkd' + s.Zuora__Price__c);
                    }   
                    if(s.Zuora__UOM__c == 'Copy Sat'){
                        nsubToCoverPrice.get(s.Zuora__Subscription__c).add('sat' + s.Zuora__Price__c);
                    }
                    if(s.Zuora__UOM__c == 'Copy Sun'){
                        nsubToCoverPrice.get(s.Zuora__Subscription__c).add('sun' + s.Zuora__Price__c);
                    }
                }
                
                if(s.Zuora__Subscription__r.Product_Code__c != null){
                    subIdToProductCodeMap.put(s.Zuora__Subscription__c, s.Zuora__Subscription__r.Product_Code__c);
                }       
        }
            
        List<Package_Item__c> pckItems = [SELECT Package__c, Product_Rate_Plan__c, Id, Is_Print__c, Is_All_In_One__c, Is_Newspaper__c, Product_Rate_Plan__r.Product_Code__c FROM Package_Item__c WHERE Package__c = : sub.Main_Package_1__c];
        Map<Id, List<Package_Item__c>> packIdToPackItemListMap = new Map<Id, List<Package_Item__c>>();
        Map<Id, List<Package_Item__c>> nsubIdToPackageItems = new Map<Id, List<Package_Item__c>>();
        
        for(Package_Item__c packageItem :pckItems){
            if(packageItem.Package__c != null){
                 
                    if(packIdToPackItemListMap.containsKey(packageItem.Package__c)){
                        packIdToPackItemListMap.get(packageItem.Package__c).add(packageItem);
                    }else{
                        packIdToPackItemListMap.put(packageItem.Package__c, new List<Package_Item__c>{packageItem});
                    }

            }
        }
        system.debug('packIdToPackItemListMap' + packIdToPackItemListMap);
        system.debug('pckItems' + pckItems);
        if(packIdToPackItemListMap.containsKey(sub.Main_Package_1__c)){
                    for(Package_Item__c pacItem : packIdToPackItemListMap.get(sub.Main_Package_1__c)){
                        if(nsubIdToPackageItems.containsKey(sub.id)){
                            nsubIdToPackageItems.get(sub.id).add(pacItem);
                        }else{
                            nsubIdToPackageItems.put(sub.id, new List<Package_Item__c>{pacItem});
                        }
                    }
        }
        system.debug('nsubIdToPackageItems' + nsubIdToPackageItems);
        List<Id> sublistId = new List<Id> ();
        List<Package_Item__c> packageItems = new List<Package_Item__c>();
        Set<Id> prp = new Set<Id>();
        for(Id subIdFromPackageMap : nsubIdToPackageItems.keySet()){
                LIST<String> subProd = nsubToCoverPrice.get(subIdFromPackageMap);
                if(subProd!=NULL && !subProd.isEmpty()){
                    sublistId.add(subIdFromPackageMap);
                    if(nsubIdToPackageItems.containsKey(subIdFromPackageMap)){
                        packageItems = nsubIdToPackageItems.get(subIdFromPackageMap);
                    }
                    system.debug('packageItems' + packageItems);
                    if(packageItems!=NULL){
                        for(Package_Item__c p : packageItems){
                            prp.add(p.Product_Rate_Plan__c);
                        }
                    }
                }
        }
           system.debug('prp' + prp);
        List<zqu__ProductRatePlanCharge__c> nratePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
        nratePlanChargeList = [SELECT Id, Name, PublicationCode__c, zqu__ProductRatePlan__c, zqu__ProductRatePlan__r.Name from zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__c IN :prp];
        Map<Id, Set<String>> PRPToPubCode = new Map<Id, Set<String>>();
        for(zqu__ProductRatePlanCharge__c prpc : nratePlanChargeList){
                pubcodes.add(prpc.PublicationCode__c);
                if(PRPToPubCode.containsKey(prpc.zqu__ProductRatePlan__c)){            
                        PRPToPubCode.get(prpc.zqu__ProductRatePlan__c).add(prpc.PublicationCode__c);
                } 
                else{
                    PRPToPubCode.put(prpc.zqu__ProductRatePlan__c, new Set<String>());
                    PRPToPubCode.get(prpc.zqu__ProductRatePlan__c).add(prpc.PublicationCode__c);
                }
        }
        system.debug('PRPToPubCode' + PRPToPubCode);
        List<Publication__c> npublist = new List<Publication__c>();
        npubList = [SELECT Id, Name, Platform_Type__c, Publication_Code__c, Published_Days__c, Earliest_Start_Date__c from Publication__c WHERE Publication_Code__c IN : pubcodes]; 
        Set<String> publCodeFromRatePlan = new Set<String>();
                    for(Package_Item__c p : pckItems){
                if(PRPToPubCode.containsKey(p.Product_Rate_Plan__c)){
                    publCodeFromRatePlan = PRPToPubCode.get(p.Product_Rate_Plan__c);
                    for(String pubCode : publCodeFromRatePlan){
                        for(Publication__c pubrec : npubList){
                            if(pubrec.Platform_Type__c == 'Print' && pubCode == pubrec.Publication_Code__c){
                                if(packageToPubrec.containsKey(p.Package__c)){            
                                        packageToPubrec.get(p.Package__c).add(pubrec);
                                } 
                                else {
                                    packageToPubrec.put(p.Package__c, new List<Publication__c>());
                                    packageToPubrec.get(p.Package__c).add(pubrec);
                                }
                            }
                         }
                     }
                  }
                  }  
                  system.debug('npubList' +   npubList);
                  system.debug('packageToPubrec'+packageToPubrec);
        Date earliestDate = null;
        List<Publication__c> publications = new List<Publication__c>();
        List<Date> pubDates = new List<Date>();
        if(packageToPubrec.containsKey(sub.Main_Package_1__c)){
            publications = packageToPubrec.get(sub.Main_Package_1__c);
            for(Publication__c pub : publications){
                pubDates.add(pub.Earliest_Start_Date__c);     
            }
            if(pubDates.size()>0){    
                pubDates.sort();
                earliestDate = pubDates[0];
            }
            else{
                earliestDate = NULL;
            }
        }
        
        system.debug('earliestDate'+ earliestDate);
        return earliestDate;
        
    }
    //END: PD-0434 06/01/2016 CCamilon CaseSubRecord
    
}