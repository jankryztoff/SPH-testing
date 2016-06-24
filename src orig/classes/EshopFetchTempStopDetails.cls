@RestResource(urlMapping='/TempStopFetchService/*')                        
global with sharing class EshopFetchTempStopDetails {
    
    global class EshopFetchTempStopDetailsRequest{
        String subscriberId;
         public String getSubscriberId(){
            return this.subscriberId;
        }
        
        public void setSubscriberId(String subscriberId){
            this.subscriberId = subscriberId;
        }

    }
    
    global class TempStopDetails{
        String subscriberId;
        String RecipientAccount; 
        String subscriptionId;
        String packageCode;
        String tempStopreasoncode; 
        Date tempStopDate; 
        Date restartDate; 
        String remarks; 
        DateTime createDate;
        Decimal quantity;
        String tempStopId;
        String tsStatus;
    }
    
    global class EshopFetchTempStopDetailsResponse {
        List<TempStopDetails> tSDetails = new List<TempStopDetails>(); //START-END D-4080 12-14-2015 added by Jason A. for code review
        ErrorResponseWrapper eRW;
        
        public EshopFetchTempStopDetailsResponse(List<TempStopDetails> tSDetails, ErrorResponseWrapper eRW){
            this.tSDetails = tSDetails;
            this.eRW = eRW;
        }
    }
    
    private static boolean validateMandatoryParameters(EshopFetchTempStopDetailsRequest req){
     //   if(req.subscriberId != null){
     //           return true;
     //   }
    //    return false;
            if(req.subscriberId == null){
            return false;
        }
        if(req.subscriberId == ''){
            return false;
        }
        System.debug('**************************************************false : '+req.subscriberId );
        return true;
    
    }

    @HttpPost
    global static EshopFetchTempStopDetailsResponse fetchTempStopDetails(EshopFetchTempStopDetailsRequest req) {
        List<TempStopDetails> tSDetailsList = new List<TempStopDetails>();
        ErrorResponseWrapper eRW = null;
        
        boolean isReqValid = validateMandatoryParameters(req);
        
        if(isReqValid == false){
            eRW = new ErrorResponseWrapper(OnlineExceptions.FAILURE,'EXES0001',OnlineExceptions.getErrorMessage('EXES0001'));
            return (new EshopFetchTempStopDetailsResponse(tSDetailsList, eRW));
        }
        
        String queryString0 = '';
        String active = 'Active';
        Boolean cancelled = true;
        String reqSubsId = req.subscriberId;
        queryString0 = 'select id from Zuora__Subscription__c where Zuora__Account__r.account_auto_number__c = :reqSubsId and Zuora__Status__c=:active';
        List<Zuora__Subscription__c> subsDetails = Database.query(queryString0);
        
        if(subsDetails.size() == 0){
            eRW = new ErrorResponseWrapper(OnlineExceptions.FAILURE,'EXES0003',OnlineExceptions.getErrorMessage('EXES0003'));
            return (new EshopFetchTempStopDetailsResponse(tSDetailsList, eRW));
        }
        
        queryString0 = 'select  Temp_Stop__r.Remarks__c, Temp_Stop__r.name, Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Temp_Stop_Date__c, ';
        queryString0 += ' Temp_Stop__r.Temp_Stop_Qty__c, Temp_Stop__r.Temp_Stop_Status__c, createddate, Subscription__c ';
        queryString0 += ' , Subscription__r.Name'; // Start/End - UD-1137 05-May-2015 Added by Raviteja
        queryString0 += ' , Subscription__r.Zuora__Zuora_Id__c'; // Start/End - UD-1137 06-May-2015 Added by Raviteja
        queryString0 += ' from Subscription_Temp_Stop__c ';
        queryString0 += ' where ';
        queryString0 += ' Subscription__c in :subsDetails';
        queryString0 += ' and Temp_Stop__r.Cancelled__c != :cancelled';
        queryString0 += ' and Temp_Stop__r.Temp_Stop_Status__c != \'Completed\'';
        
        List<Subscription_Temp_Stop__c> tSDetails = Database.query(queryString0);
        try{
            for(Subscription_Temp_Stop__c tsDet : tSDetails){
                System.debug(tsDet.Subscription__c);
                String tsDetSubId = tsDet.Subscription__c;
                queryString0 = 'select Zuora__Account__r.Account_Auto_Number__c,Recipient_Contact__c,Recipient_Contact__r.name,';
                queryString0 += 'Recipient_Contact__r.Recipient_Number__c , Main_Package_1__r.Package_Code__c, '; // Start/End - UD-1137 05-May-2015 Added by Raviteja
                queryString0 += ' Main_Package_1__c from Zuora__Subscription__c' ;
                queryString0 += ' where id = :tsDetSubId';
                
                List<Zuora__Subscription__c> sub = Database.query(queryString0);
                
                if(sub.size() > 0){
                    for(Zuora__Subscription__c temp : sub){
                        TempStopDetails det = new TempStopDetails();
                        
                        det.subscriberId = req.subscriberId;
                        //START UD-1137 05-May-2015 Added by Raviteja - Commented existing assignment
                        det.RecipientAccount = String.Valueof(temp.Recipient_Contact__r.Recipient_Number__c); 
                       //START UD-1137 06-May-2015 Added by Raviteja - Commented existing assignment
                       // det.subscriptionId = tsDet.Subscription__r.Name;
                        det.subscriptionId = tsDet.Subscription__r.Zuora__Zuora_Id__c;
                        //End UD-1137 06-May-2015 Added by Raviteja
                        det.packageCode = temp.Main_Package_1__r.Package_Code__c;
                       //End UD-1137 05-May-2015 Added by Raviteja  
                        //det.tempStopreasoncode; 
                        det.tempStopDate = tsDet.Temp_Stop__r.Temp_Stop_Date__c; 
                        det.restartDate = tsDet.Temp_Stop__r.Restart_Date__c; 
                        det.remarks = tsDet.Temp_Stop__r.Remarks__c; 
                        det.createDate = tsDet.createddate;
                        det.quantity = tsDet.Temp_Stop__r.Temp_Stop_Qty__c;
                        det.tempStopId = tsDet.Temp_Stop__r.name;
                        det.tsStatus = tsDet.Temp_Stop__r.Temp_Stop_Status__c;
                        System.debug('@@@@@@@@@@@@@@@@@@@@@@@ : '+det.tempStopId);
                        tSDetailsList.add(det);
                    }
                }
            }
        } catch(Exception e)
        {
            eRW = new ErrorResponseWrapper(OnlineExceptions.FAILURE,'EXES0018',OnlineExceptions.getErrorMessage('EXES0018'));
            return (new EshopFetchTempStopDetailsResponse(tSDetailsList, eRW));
        }
        
        Integer noOfDetails =  tSDetailsList.size();
        if(noOfDetails == 0){
            eRW = new ErrorResponseWrapper(OnlineExceptions.SUCCESS,'EXES0007',OnlineExceptions.getErrorMessage('EXES0007'));
        }else if(noOfDetails > 0){
            eRW = new ErrorResponseWrapper(OnlineExceptions.SUCCESS,OnlineExceptions.SUCCESS,OnlineExceptions.SUCCESS);
        }
        
       return (new EshopFetchTempStopDetailsResponse(tSDetailsList, eRW));
    }
    
}