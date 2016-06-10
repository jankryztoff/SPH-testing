/**
 * Class Name: DeliveryChargeHandlerCOA
 * @author: Kristine Campang
 * Date: 9/26/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Class for Creation/Cancellation of Delivery Charge for Change of Delivery Address
 *
 */



public class SP_DeliveryChargeHandlerCOA{

    //VARIABLES
    public List<Zuora__Subscription__c> PubSubRelatedSubsList;
    public List<Zuora__Subscription__c> newDelChargeList;
    public Zuora__Subscription__c selectedSubs;
    public Zuora__Subscription__c delChargeSubToCancel;
    public String DeliveryRatePlanId_Internal;
    public String DeliveryRatePlanId_HDB;
    public String DeliveryRatePlanId_Apartment;
    public String DeliveryRatePlanId_Landed;
    public List<zqu__ProductRatePlan__c> DeliveryRatePlanList;
  public Map<String, zqu__ProductRatePlan__c> delProductRatePlanMap = new Map<String, zqu__ProductRatePlan__c>();
  String delChg_hdb = ConstantsSLB.getKeyId('DELCHG_HDB');
  String delChg_land = ConstantsSLB.getKeyId('DELCHG_LAND');
  String delChg_apt = ConstantsSLB.getKeyId('DELCHG_APT');
  String delChg_zero = ConstantsSLB.getKeyId('DELCHG_ZERO');
                
    public void checkDeliveryCharge(Id subsId, Id accId, Id newAddId, Address__c addRec, Decimal Charge){

        //instantiates variables
        PubSubRelatedSubsList = new List<Zuora__Subscription__c>();
        newDelChargeList = new List<Zuora__Subscription__c> ();

        //Search for all Publication Subscriptions
        //START Code Review Jean Cari?o : check subsId if null
        if(subsId != null){
        selectedSubs = [SELECT Id, Name, Zuora__Account__c,Zuora__Account__r.Id, Recipient_Contact__c, Subscription_Type_1__c, Zuora__CustomerAccount__c, 
                        Recipient_Contact__r.Address__r.id, Zuora__CustomerAccount__r.Zuora__SoldToId__c, Zuora__CustomerAccount__r.Zuora__BillToId__c, 
                        Order_Number_1__r.Billing_Contact__c, Order_Number_1__r.Recipient_Contact__c 
                        FROM Zuora__Subscription__c
                        WHERE Id = :subsId];
        }
        //End Code Review Jean Cari?o : check subsId if null
        //query all subscriptions with same account and address
        //START Code Review Jean Cari?o : check WHERE identifier if null
        if(selectedSubs.Zuora__Account__r.Id != null && selectedSubs.Recipient_Contact__r.Address__r.Id != null){
            PubSubRelatedSubsList =[SELECT Id, Name, Zuora__Account__c, Zuora__Account__r.Id, Recipient_Contact__c, Subscription_Type_1__c, Zuora__CustomerAccount__c, 
                                Recipient_Contact__r.Address__c, Zuora__CustomerAccount__r.Zuora__SoldToId__c, Zuora__CustomerAccount__r.Zuora__BillToId__c,
                                Order_Number_1__r.Billing_Contact__c, Order_Number_1__r.Recipient_Contact__c
                                FROM Zuora__Subscription__c
                                WHERE Zuora__Account__c =:selectedSubs.Zuora__Account__r.Id 
                                AND  Subscription_Type_1__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION
                                AND  Recipient_Contact__r.Address__r.Id =:selectedSubs.Recipient_Contact__r.Address__r.Id
                                AND  Zuora__Status__c = :GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE];
        
            //Query all Delivery Subcriptions Related to Publication Subscriptions
            delChargeSubToCancel = [SELECT Id, Name, Zuora__Account__c, Zuora__Account__r.Id, Zuora__CustomerAccount__r.Zuora__External_Id__c, Zuora__CustomerAccount__c, Recipient_Contact__c, Subscription_Type_1__c, 
                                Zuora__Zuora_Id__c, Recipient_Contact__r.Address__c, Zuora__CustomerAccount__r.Zuora__SoldToId__c, Zuora__CustomerAccount__r.Zuora__BillToId__c,
                                Order_Number_1__r.Billing_Contact__c, Order_Number_1__r.Recipient_Contact__c
                                FROM Zuora__Subscription__c
                                WHERE Zuora__Account__c =:selectedSubs.Zuora__Account__r.Id 
                                AND  Subscription_Type_1__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY 
                                AND  Recipient_Contact__r.Address__r.Id =:selectedSubs.Recipient_Contact__r.Address__r.Id
                                AND Zuora__Status__c = :GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE
                                LIMIT 1];
        }   
        //END Code Review Jean Cari?o : check WHERE identifier if null
        if(PubSubRelatedSubsList.size()==0){
                System.debug('ZUOOOOOOOOOOORAAA ID:' + delChargeSubToCancel.Zuora__Zuora_Id__c);
                CancelSubscription.createCancelAmendment(delChargeSubToCancel.Zuora__Zuora_Id__c, Date.today()); //to fix stopDate
        }
        
        
        if(!checkIfNewDelSubExist(newAddId)){
                //insert creation of Quotes here
                createDeliveryCharge();
                zqu__Quote__c buildQuotesDel = zBuildQoutesPackageDELIVERY(accId, delChargeSubToCancel);
                insert buildQuotesDel;
                List<zqu__QuoteCharge__c> zquoteChargeList  = zPopulateQuoteChargeDELIVERY(buildQuotesDel,Charge, addRec);
                insert zquoteChargeList;
                SendToZBilling(buildQuotesDel.Id, buildQuotesDel.zqu__ZuoraAccountID__c);

        }
    
    }
    /*Method to check if there is an Existing Delivery Charge Related to the New Address and Same Account
    *
    */
    public Boolean checkIfNewDelSubExist(Id newAddId){
        //START Code Review Jean Cari?o : check WHERE identifier if null
        if(newAddId != null && selectedSubs.Zuora__Account__r.Id != null){
            newDelChargeList = [SELECT Id, Name, Zuora__Account__c, Zuora__Account__r.Id, Recipient_Contact__c, Subscription_Type_1__c, Zuora__Zuora_Id__c,
                            Zuora__CustomerAccount__c, 
                            Recipient_Contact__r.Address__c, Zuora__CustomerAccount__r.Zuora__SoldToId__c, Zuora__CustomerAccount__r.Zuora__BillToId__c, Order_Number__c
                            FROM Zuora__Subscription__c
                            WHERE Zuora__Account__c =:selectedSubs.Zuora__Account__r.Id 
                            AND  Subscription_Type_1__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY 
                            AND  Recipient_Contact__r.Address__r.Id =:newAddId
                            AND Zuora__Status__c = :GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE];     
        }
        //END Code Review Jean Cari?o : check WHERE identifier if null
        if(newDelChargeList.size()>0){
            return true;
        }
        else{
            return false;
        }
                
    }
    
    //fetch product and rate plans for delivery charges
    public void createDeliveryCharge(){


        DeliveryRatePlanList = new list<zqu__ProductRatePlan__c>();
        set<Id>sDeliveryRatePlanId = new set<Id>();
        map<string, Id> deliveryRatePlan_RatePlanIDMap = new map<String,Id>();
        map<Id,string> mProductRatePlanID_mProductRatePlanNameDELIVERY = new map<Id,string>();
        
        //gets List of Product Rate Plan
        DeliveryRatePlanList = [Select zqu__ZProduct__r.ProductType__c, zqu__ZProduct__r.ProductSubType__c, zqu__ZProduct__c, Id, Name, zqu__ZProduct__r.Name,
                                (SELECT Id, Name, sum__c, zqu__UOM__c, zqu__RecurringPeriod__c, zqu__Discount_Level__c, zqu__Model__c, zqu__Type__c, zqu__Upto_How_Many_Periods__c, zqu__ZuoraId__c, zqu__ProductRatePlan__c, zqu__ProductRatePlan__r.Name FROM R00N40000001mFVKEA2__r)
                                From zqu__ProductRatePlan__c
                                Where zqu__ZProduct__r.ProductType__c = 'Charge'
                                and zqu__ZProduct__r.ProductSubType__c = 'Delivery'];
        
        System.debug('DELIVERY RATE PLAN LIST:' + DeliveryRatePlanList);
        //mapping for Rate Plan Charges
        if(DeliveryRatePlanList.size() > 0){
            for(zqu__ProductRatePlan__c drp: DeliveryRatePlanList){
                if (drp.name == delChg_zero){
                    DeliveryRatePlanId_Internal = drp.Name;
          delProductRatePlanMap.put(delChg_zero, drp);
                }else if(drp.name == delChg_hdb){
                    DeliveryRatePlanId_HDB = drp.Name;
          delProductRatePlanMap.put(delChg_hdb, drp);
                }else if(drp.name == delChg_apt){
                    DeliveryRatePlanId_Apartment = drp.Name;
          delProductRatePlanMap.put(delChg_apt, drp);
                }else if(drp.name == delChg_land){
                    DeliveryRatePlanId_Landed = drp.Name;
          delProductRatePlanMap.put(delChg_land, drp);
                }
                
                sDeliveryRatePlanId.add(drp.id);
                deliveryRatePlan_RatePlanIDMap.put(drp.Name, drp.Id);
                //sProdRatePlan.add(drp.Id);
            }
        }
        //Get Rate Plan from here ok? Depending on the delivery type
        
            
        
    }
  
  //populate delivery charge quote
    public zqu__Quote__c zBuildQoutesPackageDELIVERY (Id accId, Zuora__Subscription__c oldDelSub){
        
            zqu__Quote__c quoteDel = new zqu__Quote__c ();
            
            //q1.Name = 'Delivery Subscription';
            quoteDel.zqu__Account__c = accId;        
      quoteDel.zqu__InitialTerm__c = 1;
      quoteDel.zqu__RenewalTerm__c = 1;
            quoteDel.zqu__SubscriptionType__c = 'New Subscription';                    
            quoteDel.zqu__ValidUntil__c = date.today().addMonths(1);  
            quoteDel.zqu__StartDate__c = Date.Today();
            quoteDel.zqu__SoldToContact__c = oldDelSub.Order_Number_1__r.Recipient_Contact__c;
            quoteDel.zqu__BillToContact__c = oldDelSub.Order_Number_1__r.Billing_Contact__c;
            quoteDel.zqu__ZuoraAccountID__c = oldDelSub.Zuora__CustomerAccount__r.Zuora__External_Id__c;
            quoteDel.Subscription_Type__c = ConstantsSLB.getkeyid('SubTypeDel');
     
            return quoteDel;
        }
    
  //populate delivery quote charge
    public list<zqu__QuoteCharge__c> zPopulateQuoteChargeDELIVERY(zqu__Quote__c zQuote, Decimal ChargeAmount, Address__c newAdd){
                                                        
            list<zqu__QuoteCharge__c> quoteChargeList = new list<zqu__QuoteCharge__c>();
      zqu__ProductRatePlan__c prodRatePlan = new zqu__ProductRatePlan__c();
      zqu__QuoteCharge__c zQuoteCharge = new zqu__QuoteCharge__c();
      zqu__ProductRatePlanCharge__c prodRatePlanCharge = new zqu__ProductRatePlanCharge__c();
      
      if(ChargeAmount!=null && delProductRatePlanMap.containsKey(delChg_zero)){
        prodRatePlan = delProductRatePlanMap.get(delChg_zero);
        zQuoteCharge.zqu__EffectivePrice__c = ChargeAmount;
        zQuoteCharge.zqu__ProductRatePlanName__c = DeliveryRatePlanId_Internal;
      }
      else if((newAdd.Address_Type__c=='A' || newAdd.Address_Type__c== 'B' ||newAdd.Address_Type__c== 'C' ||newAdd.Address_Type__c=='G' || newAdd.Address_Type__c=='K' || newAdd.Address_Type__c=='P' || newAdd.Address_Type__c=='S') && delProductRatePlanMap.containsKey('Delivery Charge Condo/Office')) {
        prodRatePlan = delProductRatePlanMap.get(delChg_apt);
        zQuoteCharge.zqu__ProductRatePlanName__c = DeliveryRatePlanId_Apartment;
      }
      else if(newAdd.Address_Type__c=='H' && delProductRatePlanMap.containsKey(delChg_hdb)){
        prodRatePlan = delProductRatePlanMap.get(delChg_hdb);
        zQuoteCharge.zqu__ProductRatePlanName__c = DeliveryRatePlanId_HDB;
      }
      else if(newAdd.Address_Type__c=='S' && delProductRatePlanMap.containsKey(delChg_land)){
        prodRatePlan = delProductRatePlanMap.get(delChg_land);
        zQuoteCharge.zqu__ProductRatePlanName__c = DeliveryRatePlanId_Landed;
      }
      //assumption: Rate Plan Charge Name is the same as the name of the Rate Plan.
      for(zqu__ProductRatePlanCharge__c prc : prodRatePlan.R00N40000001mFVKEA2__r) {
        if(prc.Name == prodRatePlan.Name) {
          prodRatePlanCharge = prc;
        }
      }
      
      zQuoteCharge.Name = prodRatePlanCharge.Name;
      zQuoteCharge.zqu__Quote__c = zQuote.Id;
      zQuoteCharge.zqu__ProductRatePlanCharge__c =  prodRatePlanCharge.id;
      zQuoteCharge.zqu__Quantity__c = 1;
      zQuoteCharge.zqu__UOM__c = prodRatePlanCharge.zqu__UOM__c;
      zQuoteCharge.zqu__Period__c = prodRatePlanCharge.zqu__RecurringPeriod__c;
      zQuoteCharge.zqu__Model__c = prodRatePlanCharge.zqu__Model__c;
      zQuoteCharge.zqu__TimeProductAdded__c = String.ValueOf(Datetime.now());
      zQuoteCharge.zqu__ChargeType__c = prodRatePlanCharge.zqu__Type__c;
      zQuoteCharge.zqu__PeriodNumeric__c = prodRatePlanCharge.zqu__Upto_How_Many_Periods__c;
      zQuoteCharge.zqu__RatePlanCharge_ZuoraID__c = prodRatePlanCharge.zqu__ZuoraId__c;
      zQuoteCharge.RecordTypeId = ConstantsSLB.getkeyid('Default Quote Charge'); 
      zQuoteCharge.zqu__ProductName__c = prodRatePlan.zqu__ZProduct__r.Name;
      zQuoteCharge.zqu__Discount_Level__c = prodRatePlanCharge.zqu__Discount_Level__c;
      zQuoteCharge.zqu__Upto_How_Many_Periods__c = prodRatePlanCharge.zqu__Upto_How_Many_Periods__c;

      quoteChargeList.add(zQuoteCharge);
      
      return quoteChargeList; 
    }
  
    @future (callout=true)
    public static void SendToZBilling(Id quoteId, String zAccId){
        System.debug('quoteId: ' + quoteId + '-- zAccId: ' + zAccId);
        List<zqu.zQuoteUtil.ZBillingQuoteCollection> quotes = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();

        zqu.zQuoteUtil.ZBillingQuoteCollection quote = new zqu.zQuoteUtil.ZBillingQuoteCollection();
        //quote.sfdcAccountId = '001N000000JxMyZ'; // SFDC CRM Account ID
        quote.zAccountId = zAccId; // Zuora Billing Account ID
        quote.quoteRequests = new List<zqu.zQuoteUtil.ZBillingQuoteRequest>();

        zqu.zQuoteUtil.ZBillingQuoteRequest req = new zqu.zQuoteUtil.ZBillingQuoteRequest();
        req.sfdcQuoteId = quoteId; // SFDC Quote ID
        system.debug('>>>>>>>>>>>>>>>>>>>Debug:' + quoteId);
        quote.quoteRequests.add(req);
        quotes.add(quote);

        String zId = '';
        List<zqu.zQuoteUtil.zBillingResult> results = zqu.zQuoteUtil.sendToZBilling(quotes);
        for ( zqu.zQuoteUtil.zBillingResult result : results ) {
            System.debug( 'Result: QuoteId = ' + result.sfdcQuoteId + ', Success = ' + result.success + ', message = ' + result.message );
            zId = result.zSubscriptionId;
        }
    }
}