@RestResource(urlMapping='/FetchGiftDetailsService/*')                        
global with sharing class EshopFetchGiftDetailsService {
    
    global class FetchGiftDetailsServiceRequest {
        String promotionId = null;
        String contractDuraction = null;
        List<String> giftId = null;
        public String getpromotionId(){     
            return this.promotionId;      
        }            
             public void setpromotionId(String promotionId){    
             this.promotionId = promotionId;       
        }
        public String getcontractDuraction(){     
            return this.contractDuraction;      
        }            
             public void setcontractDuraction(String contractDuraction){    
             this.contractDuraction = contractDuraction;       
        }
        public List<String> getgiftId(){     
            return this.giftId;      
        }            
             public void setgiftId(List<String> giftId){    
             this.giftId = giftId;       
        }


    }
    
    global class GiftDetails {
        String promotionId;
        String contractDuraction;
        String giftId;
        String description;
        Decimal status;
        
        public GiftDetails(String promotionId, String contractDuraction, String giftId, String description, Decimal status){
            this.promotionId = promotionId;
            this.contractDuraction = contractDuraction;
            this.giftId = giftId;
            this.description = description;
            this.status = status;
        }
    }
    
    global class FetchGiftDetailsServiceResponse {
        List<GiftDetails> details = new List<GiftDetails>(); //START-END D-4080 12-14-2015 added by Jason A. for code review
        ErrorResponseWrapper eRW;
        
        public FetchGiftDetailsServiceResponse(List<GiftDetails> details, ErrorResponseWrapper eRW){
            this.details = details;
            this.eRW = eRW;
        }
    }
    
    private static boolean validateMandatoryParameters(FetchGiftDetailsServiceRequest req){
        if(req != null){
  // 4/16/2015 KRITHIKA DHARMARAJAN UD-0933 START
            if(req.giftId.isEmpty() || req.promotionId == '' || req.contractDuraction == '')
            {
             return false;
            }
      // 4/16/2015 KRITHIKA DHARMARAJAN UD-0933 END       
            for(String giftTemp : req.giftId){
                if(req.promotionId == null || giftTemp == null || req.contractDuraction == null){
                    return false;
                }
            }
        }else{
            return false;
        }
        return true;
    }

    @HttpPost
    global static FetchGiftDetailsServiceResponse fetchGiftDetails(FetchGiftDetailsServiceRequest req) {
        boolean isReqValid = validateMandatoryParameters(req);
        ErrorResponseWrapper eRW  = null;
        List<Promotion_Gift__c> pGCL = new List<Promotion_Gift__c>();
        List<GiftDetails> gD = new List<GiftDetails>();
        List<String> giftId = req.giftId;
        String promotionId = req.promotionId;
        String contractDuraction = req.contractDuraction;
        
        if(isReqValid == false){
            eRW = new ErrorResponseWrapper(OnlineExceptions.FAILURE,'EXES0001',OnlineExceptions.getErrorMessage('EXES0001'));
            return (new FetchGiftDetailsServiceResponse(null, eRW));
        }
        
        String queryString0 = 'select Balance_Quantity__c,Gift__r.Gift_description__c,Gift__r.Gift_Code__c,promotion__r.Promotion_Code__c, '; 
            queryString0 += 'promotion__r.Contract_Period__c from Promotion_Gift__c ';
            queryString0 += 'where Gift__r.Gift_Code__c in :giftId and ';
            queryString0 += 'promotion__r.Promotion_Code__c = :promotionId and promotion__r.Contract_Period__c = :contractDuraction';
        
        pGCL = Database.query(queryString0);
        
        for(Promotion_Gift__c temp : pGCL){
            gD.add(new GiftDetails(promotionId, contractDuraction, temp.Gift__r.Gift_Code__c, temp.Gift__r.Gift_description__c, temp.Balance_Quantity__c));
        }
        
        if( gD.size() == 0 ){
            //Start [K.Ibalio 1/19/2015 D-1509] Changing expected error message for EXES0008
            eRW = new ErrorResponseWrapper(OnlineExceptions.FAILURE,'EXES0008',OnlineExceptions.getErrorMessage('EXES0008'));
      //End [K.Ibalio 1/19/2015 D-1509] Changing expected error message for EXES0008
        }else{
            eRW = new ErrorResponseWrapper(OnlineExceptions.SUCCESS,OnlineExceptions.SUCCESS,OnlineExceptions.SUCCESS);
        }
        
        return (new FetchGiftDetailsServiceResponse(gD, eRW));
    }
    
}