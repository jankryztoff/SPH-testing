/**
 * Class Name: CancelSubscription 
 * @author: Kristine Campang
 * Date: 9/26/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Class for Cancellation of Subscription and Delivery Charge 
 *
 */
global class CancelSubscription {
   
    public static String amendApiCall(Zuora.zObject amendment) {
        Zuora.zApi zuorApi = new Zuora.zApi();
        //START D-3268 Modified By C.I.Salas - Test Coverage
        if (!Test.isRunningTest()) {
            zuorApi.zlogin();
        }
        //END D-3268 Modified By C.I.Salas - Test Coverage

        // Amend Request
        Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
        Zuora.zObject[] amendments = new List < Zuora.zObject > {
        amendment
        };
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

        Zuora.zApi.AmendResult result = zuorApi.zamend(new List < Zuora.zApi.AmendRequest > {
        amendRequest
        });
        
        return String.valueOf(result.errors);
    }

    /**
    * Create basic infomation for amendment.
    */
    public static Zuora.zObject createCancelAmendment(String zuoraId, Date stopDate) {

        String zuoraDate =  formatDateToZuora(stopDate);    

        Zuora.zObject amendment = new Zuora.zObject(globalvariableclass.AMENDMENT);
        amendment.setValue(globalvariableclass.CONTRACT_EFFECTIVEDATE, /*'2014-09-20T20:44:54.718+05:30'*/ Zuora.zUtil.getZuoraDate(stopDate));
        amendment.setValue(globalvariableclass.DESCRIPTION, globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
        amendment.setValue(globalvariableclass.EFFECTIVE_DATE, /*'2015-04-01T20:44:54.718+05:30'*/ Zuora.zUtil.getZuoraDate(stopDate));
        amendment.setValue(globalvariableclass.NAME, globalvariableclass.CANCEL_A_SUBSCRIPTION_AMENDMENT);
        amendment.setValue(globalvariableclass.STATUS, globalvariableclass.COMPLETED);
        amendment.setValue(globalvariableclass.SUBSCRIPTION_ID, zuoraId);
        amendment.setValue(globalvariableclass.TYPE, globalvariableclass.CANCELATION);

        return amendment;
    } 
    @future(callout=true)
    global  static void amendForSubCancelation(String zuoraSubscriptionId, Date stopDate) {
        Zuora.zObject amendment = createCancelAmendment(zuoraSubscriptionId, stopDate);
        amendApiCall(amendment);
    }  

    /* Method for Delivery Charge Logic

    */
    public void checkDeliveryCharge(Id subsId, Date stpReqDate){

    //declaration of variables
     Zuora__Subscription__c selectedSubs;
     List<Zuora__Subscription__c> PubSubRelatedSubsList;
     Zuora__Subscription__c delChargeSubToCancel;
    
        //instantiates variables
        PubSubRelatedSubsList = new List<Zuora__Subscription__c>();

        //Search for all Publication Subscriptions
        selectedSubs = [SELECT Id, Name, Zuora__Account__c, Recipient_Contact__c, Recipient_Contact__r.Address__c,
                        Subscription_Type_1__c
                        FROM Zuora__Subscription__c
                        WHERE Id = :subsId];                
        //query all subscriptions with same account and address     
        PubSubRelatedSubsList =[SELECT Id, Name, Zuora__Account__c, Recipient_Contact__c, Subscription_Type_1__c
                                FROM Zuora__Subscription__c
                                WHERE Zuora__Account__c =:selectedSubs.Zuora__Account__c
                                AND  Subscription_Type_1__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
                                AND  Recipient_Contact__r.Address__r.Id =:selectedSubs.Recipient_Contact__r.Address__c 
                                AND Zuora__Status__c = :GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE];
        delChargeSubToCancel = [SELECT Id, Name, Zuora__Account__c, Recipient_Contact__c, Subscription_Type_1__c, Zuora__Zuora_Id__c
                                FROM Zuora__Subscription__c
                                WHERE Zuora__Account__c =:selectedSubs.Zuora__Account__c
                                    AND  Subscription_Type_1__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY
                                    AND  Recipient_Contact__r.Address__r.Id =:selectedSubs.Recipient_Contact__r.Address__c
                                    AND Zuora__Status__c = :GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE];                         
        if(PubSubRelatedSubsList.size()==0){
                createCancelAmendment(delChargeSubToCancel.Zuora__Zuora_Id__c, stpReqDate);
        }           
    }
    
    /*Convert Date to Format in Zoura
    */
    public static String formatDateToZuora(Date formatDate){

        DateTime stp = (DateTime)formatDate;
        String mydate = string.valueof(stp.format('YYYY-MM-d'));
        String d = mydate+'T00:00:00';
        return d;
    }
 
 }