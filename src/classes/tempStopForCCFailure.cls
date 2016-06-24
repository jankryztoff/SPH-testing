public class tempStopForCCFailure {
    List<Order__c> orderList = new List<Order__c>();
    List<Case> caseList = new List<Case>();
    List<Temp_Stop__c> updateTempStopList = new List<Temp_Stop__c>();

    Set<String> tempStopStatus = new Set<String>{globalvariableclass.TS_STATUS_ONGOING, globalvariableclass.TS_STATUS_NOTSTARTED};
    Set<Id> subIdForTempStopSet = new Set<Id>();
    
    Integer indexNumber = 0;
    
    Logger logger = new Logger(tempStopForCCFailure.class.getName());

    public tempStopForCCFailure(Set<Id> subIdForTempStopSet) {
        this.subIdForTempStopSet = subIdForTempStopSet;
    }
    
    public void dataprep() {
        List<Subscription_Temp_Stop__c> subTempStopList = new List<Subscription_Temp_Stop__c>();
        
        system.debug('>>>>>subIdForTempStopSet ' + subIdForTempStopSet);
        subTempStopList = [SELECT Subscription__r.Status_Formula__c, Subscription__r.Order_Line_Item_Number__c, Subscription__r.Order_Line_Item_Number_1__r.Ph_d__c, 
                                    Subscription__r.Order_Line_Item_Number_1__r.Ph_e__c, Temp_Stop__r.Case__r.Current_Date_for_Year_To_Date__c, Temp_Stop__r.Case__r.Next_Year_for_Year_To_Date__c, Subscription__r.Next_Year_Temp_Stop_Days__c, Subscription__r.Order_Line_Item_Number_1__r.Main_Package_Frequency__c, Subscription__r.Year_to_Date_Temp_Stop_Days__c, Subscription__r.Ph_d__c, Subscription__r.Ph_e__c, Subscription__r.Zuora__SubscriptionStartDate__c , Subscription__r.Zuora__SubscriptionEndDate__c, Subscription__r.Recipient_Address_ID__c, Subscription__r.Main_Package_1__r.Id, Subscription__r.Main_Package_1__r.Name, Temp_Stop__r.Id, Subscription__r.Recipient_Contact__r.Id, Subscription__r.Zuora__CustomerAccount__r.Id, Id, Name, Subscription__r.Delivery_Charge__c, Subscription__r.Name, Subscription__r.Id, Temp_Stop__r.Qty__c, Subscription__r.Zuora__Status__c, Temp_Stop__r.Case__r.Total_Issue__c, Subscription__r.Frequency_1__c, Subscription__r.Zuora__CustomerAccount__r.Name, Subscription__r.Recipient_Contact__r.Name, Temp_Stop__c, Temp_Stop__r.Temp_Stop_Date__c, Subscription__r.Number_of_Copies__c, Temp_Stop__r.Temp_Stop_Status__c, Temp_Stop__r.POP_Start_Date__c, Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Request_Total_Issue__c, Temp_Stop__r.Case__r.Year_To_Date_Count__c, Subscription__r.Product_Code__c, Subscription__c, Temp_Stop__r.Case__c, Subscription__r.Main_Package_1__r.Package_Type__c, Subscription_Temp_Stop_Legacy_Id__c, Subscription__r.Zuora__Account__c, Subscription__r.Zuora__Zuora_Id__c 
                              FROM Subscription_Temp_Stop__c 
                              WHERE Subscription__c IN : subIdForTempStopSet AND Temp_Stop__r.Temp_Stop_Status__c IN :tempStopStatus];
        system.debug('>>>>>subTempStopList ' + subTempStopList.size());
        for(Subscription_Temp_Stop__c sts :subTempStopList) {
            if(sts.Temp_Stop__r.Temp_Stop_Status__c == globalvariableclass.TS_STATUS_NOTSTARTED) {
                cancelTempStop(sts);
            }
            else if(sts.Temp_Stop__r.Temp_Stop_Status__c == globalvariableclass.TS_STATUS_ONGOING) {
                
            }
        }
        
        if(!orderList.isEmpty()) {
            try{
                database.insert(orderList, false);
            }
            catch(Exception e) {
                logger.log(false, 'Order creation failed: ' + e);
                system.debug('>>>>>Exception ' + e);
            }
        }
        
        for(Case c :caseList) {
            c.Order__c = orderList[indexNumber].Id;
            indexNumber++;
        }
        
        if(!caseList.isEmpty()) {
            try{
                database.insert(caseList, false);
            }
            catch(Exception e) {
                logger.log(false, 'Case creation failed: ' + e);
                system.debug('>>>>>Exception ' + e);
            }
        }
        system.debug('>>>>>updateTempStopList ' + updateTempStopList.size());
        if(!updateTempStopList.isEmpty()) {
            try{
                database.update(updateTempStopList, false);
            }
            catch(Exception e) {
                logger.log(false, 'Temp Stop cancellation failed: ' + e);
                system.debug('>>>>>Exception ' + e);
            }
        }
        
        logger.save();
    }
    
    public void cancelTempStop(Subscription_Temp_Stop__c sts) {
        Order__c order = new Order__c();
        order.Subscription__c = sts.Subscription__c;
        order.Account__c = sts.Subscription__r.Zuora__Account__c;
        order.Order_Type__c = globalvariableclass.TS_TEMP_STOP;
        order.Temp_Stop_Type__c = globalvariableclass.TS_CANCEL;
        order.Status__c = globalvariableclass.TS_NEW;
        order.Informed_Customer__c = true;
        order.Case_Record_Type__c = ConstantsSLB.getKeyId('Temp Stop Subscription');
        order.Credit_Balance__c = 0; 
        order.Delivery_Charge__c = 0; 
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
        //order.Request_Source__c = requestSource;  
        order.Subscriber_Account__c = sts.Subscription__r.Zuora__Account__c;
        orderList.add(order);
        
        Case thisCase = new Case(); 
        //thisCase.Create_Follow_Up_Task__c = followUpTask;
        //thisCase.Origin = requestSource;
        thisCase.Temp_Stop_Type__c = globalvariableclass.TS_CANCEL;
        thisCase.RecordTypeID = ConstantsSLB.getKeyId('Temp Stop Subscription');
        thisCase.Category__c = globalvariableclass.TS_SUBSCRIPTION_REQUEST;
        thisCase.Subject = globalvariableclass.TS_SUBJECT;
        thisCase.Temp_Stop_Date__c = sts.Temp_Stop__r.Temp_Stop_Date__c;
        thisCase.Temp_Stop__c = sts.Temp_Stop__c;
        thisCase.Qty__c = sts.Temp_Stop__r.Qty__c;
        thisCase.Restart_Date__c = sts.Temp_Stop__r.Restart_Date__c;
        //thisCase.Remarks__c = Can.remarks;
        thisCase.Temp_Stop_Sub__c = sts.Subscription__c;  
        thisCase.AccountId = sts.Subscription__r.Zuora__Account__c;   
        //if(parentCaseId != null){
            //thisCase.ParentId = parentCaseId;
        //}
        if (thisCase.Temp_Stop_Date__c == Date.Today() + 1){
            thisCase.Requires_Urgent_Approval__c = true;
            thisCase.Status = globalvariableclass.TS_PENDING;
            thisCase.Sub_Status__c = globalvariableclass.TS_URGENT_APPROVAL_STATUS;
        }else{
            thisCase.Requires_Urgent_Approval__c = false;
            thisCase.Status = globalvariableclass.TS_CLOSED;
            thisCase.Sub_Status__c = globalvariableclass.TS_APPROVED;
        }
        caseList.add(thisCase);

        Temp_Stop__c tempStop = new Temp_Stop__c ();
        tempStop.Id = sts.Temp_Stop__c;
        tempStop.Cancelled__c = True;
        
        if (thisCase.Status == globalvariableclass.TS_CLOSED){
            updateTempStopList.add(tempStop);
        }
    }
}