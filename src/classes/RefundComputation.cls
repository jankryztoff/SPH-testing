/**
 * Class Name: RefundComputation 
 * @author: Kristine Campang
 * Date: 9/26/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Class for Refund Computation
 *
 * History: 1.0    16/12/2014 Kristine Campang : Changed mapping of Product Rate Plan and computation of refund
 * History: D-1757 14/01/2015 Wenjun : Postage Charge
 */
public class RefundComputation{

    public static Zuora__Subscription__c zuoSubscrpt;
    public static Set<Id> subsIdSet;
    public static String contractDate;
    public static List<Zuora__SubscriptionProductCharge__c> zuoSubProdCharg;
    public static List<zqu__ProductRatePlan__c> zquProdRatePlan;

    public static Map<Id, String> mapZuoProdCharge_ProdCode;
    public static Map<Id, List<Zuora__SubscriptionProductCharge__c>> mapZuoSubs_ZuoSubProdCharge;
    public static Map<Id, Set<String>> mapProdRatePlanChargeId_toPublicationCode;
    public static Map<Id, Set<String>>  mapSubsId_toRatePlan;
    public static Set<String> setRatePlan;
    public static Set<String> publiCode;

    //variables for Product Rate Plan
    public static Set<Id> ratePlanIds;
    public static List<zqu__ProductRatePlan__c> productRatePlanList;
    public static Map<String, zqu__ProductRatePlan__c> mapProdRatePlanName_toProductRatePlanRec;

    //variables for Product Rate Plan and Charges
    public static List<zqu__ProductRatePlanCharge__c> prodRatePlanChargesList;
    public static Map<String, List<zqu__ProductRatePlanCharge__c>> mapProdRatePlan_toProdRatePlanCharge;

    //variables for Publication
    public static List<Publication__c> pubList;
    public static Map<String, Publication__c> mapPublicCode_toPublicRec;
    public static Map<Id, List<Publication__c>> mapSubsId_toPublicRec;
    public static Map<Id, List<Publication__c>> mapSubsId_toPubList;
    public static Set<String> pubCodeSetperPRC;

    //variables for Temp Stop
    public static Temp_Stop__c TempStopRec;
    public static List<Subscription_Temp_Stop__c> SubTempStopList;
    public static Set<Id> TempStopSet;

    //Computation Variables
    public static Decimal paymentPerMonth;
    public static Date startDate;
    public static Date endDate;
    public static Decimal remMonthsRefund; 
    public static Integer remDays;
    public static Integer monthDiff;
    public static Integer stopDiff;
    public static Date lastDay;
    public static Date startMo;
    public static Decimal proratedAmt;
    public static List<Publication_Price__c> coverPriceList;
    public static String dayOfWeek;
    public static Boolean isRefundable;
    public static Boolean Refundable;
    public static Integer numberOfDays;
    public static Date lastDayOfMonth;
    public static Decimal prorationAmountForRemainingDaysBef;
    public static Decimal prorationAmountForRemainingDaysAft;
    public static Map<String, Decimal> dayToCoverPriceMap;
    public static Map<String, Map<String, Decimal>> pubToMapDayCoverPriceMap;
    public static Date startOfTheMonth;
    public static Decimal totalProration;
    public static List<Non_Publication_Day__c> nonPubDates;
    public static Set<Date> nonPubDatesWithinSet;
    public static String subfreq;
    public static Decimal covPrice;
    public static Decimal pendingcopies{get;set;}
    public static Decimal numofcopies;
    Public static Map<Id, Decimal> pendingcopiesmap;
    Public static Map<Publication__c, Decimal> givencopiesmap;
    //detailsofRefund
    //START: New PC Implementation 12/15/2014 Added by Kristine Campang - added variables for new PC Implementation
    public static Map<String, Map<String, Decimal>> mapPRC_UOM_Price;
    public static Map<String, List<zqu__ProductRatePlanCharge__c>> mapPubCodeToRatePlanCharge; 
    public static Decimal copyPrice;
    public static Decimal copyMonth;
    public static Decimal fProratedAmt;
    //END: New PC Implementation 12/15/2014 Added by Kristine Campang
    public static List<Zuora__SubscriptionProductCharge__c> zuoSPCForQuantity;
    public static decimal finalMonth;
    //START: D-1664 1/29/2015 Added by Kristine Campang - added variables
    public static Set<String> setRP;
    //END: D-1664 1/29/2015 Added by Kristine Campang 
    //START: D-2007 02/12/2015 Added by Kristine Campang - variables for delivery
    public static Zuora__Subscription__c zuoSubDel;
    public static List<Zuora__SubscriptionProductCharge__c> zuoProdChargeDel;
    public static Decimal delRef;
    public static Decimal monthDiffDel;
    //END: D-2007 02/12/2015 Added by Kristine Campang
    //START: D- 0077 03/03/2015 Added by Kristine Campang - added variables for new Issue Calculation Utility
    public static Integer pendingCopiesPerPub;
    public static Decimal weekdayIssue;
    public static Decimal SaturdayIssue ;
    public static Decimal SundayIssue;
    public static Decimal copyPriceWeekday;
    public static Decimal copyPriceSaturday;
    public static Decimal copyPriceSunday;
    public static Set<Date> zSPCDiscountSet;
    public static List<Zuora__SubscriptionProductCharge__c> zuoSubProdChargListDisc;
    public static Set<Zuora__SubscriptionProductCharge__c> zSPCDiscount;
    public static List<Date> zSPCDiscountList;
    public static Map<Id, Decimal> mapSPCDiscToPrice;
    public static Map<Date, Id> mapDateToSPC;
    public static Map<Id, List<Date>> finalDiscountMap;
    public static Map<Id, List<Date>> totalDiscountDateMap;
    public static Decimal totalDiscountAmount;
    public static Decimal weekDayDiscount;
    public static Decimal saturdayDiscount;
    public static Decimal sundayDiscount;
    public static Decimal totalDiscount;
    public static Decimal totalDiscountPerPub;
    public static Map<Id, Zuora__SubscriptionProductCharge__c> mapSPCIdToSPCRec;
    //END: D- 0077 03/03/2015 Added by Kristine Campang
    //START: D-2119 and D-2120 03/11/2015 Added by Kristine Campang - added variables for online, magazine, and all in one
    public static Decimal OddFreqIssue;
    public static Decimal copyPriceMagazine;
    public static Decimal copyPriceOnline;
    public static Boolean isMagazine;
        //START: D- 2553 03/24/2015 Added by Kristine Campang - added new variable for magazine discount
        public static Boolean isDigital;
        //END: D-2119 and D-2120 03/11/2015 Added by Kristine Campang
        //START: D- 2551 03/19/2015 Added by Kristine Campang - added variables for postage
        public static Decimal monthDiffPostage;
        //START: D- 2553 03/24/2015 Added by Kristine Campang - added new variable for magazine discount
        public static Decimal magazineDiscount;
        public static Decimal onlineDiscount;
        public static Decimal weekdayIssueDisc;
        public static Decimal SaturdayIssueDisc;
        public static Decimal SundayIssueDisc;
        public static Decimal OddFreqIssueDisc;
        public static Package__c mainPackage;
        public static Boolean isAIO;
        //START UD-2054 7/22/2015 Added By C. Lin - Change to List
        public static List<Package_Item__c> pckItems = new List<Package_Item__c>();
        //public static zqu__ZProduct__c zProduct;
        //END UD-2054 7/22/2015 Added By C. Lin
        public static List<Publication__c> AIOPubList;
        public static List<Publication__c> AIOMagazinePub;
        public static Boolean isAIOMag;
        public static Decimal totalProrationAIOMag;
        //END: D- 2553 03/24/2015 Added by Kristine Campang
        //START: D- 2553 04/9/2015 Added by Kristine Campang - added variables for AIO
        public static Decimal copyPriceAIOOnline;
        public static Decimal copyPriceAIOSmartphone;
        public static Decimal copyPriceAIOTablet;
        public static Decimal AIOTabletDiscount;
        public static Decimal AIOOnlineDiscount;
        public static Decimal AIOSmartphoneDiscount;
        public static Decimal monthDiscount;
        public static Decimal numMonth;
        //END: D- 2553 04/9/2015 Added by Kristine Campang
        
        //START D-3134 VPernicia 6/22/15
        public static String ProductSKU;
        //END D-3134 VPernicia 6/22/15
        
        //START D-3842 10/30/2015 Added by J.Sarion - Only one sub will have the delivery fee for the refund
        public static Set<Id> oliIdForBundleSetRC = new Set<Id>();
        public static String orderType = '';
        //END D-3842 10/30/2015 Added by J.Sarion - Only one sub will have the delivery fee for the refund
        
        
        //Start UD-2685 VPernicia 09/09/15
        public static map<string, decimal> mapSPCPrice;
        //End UD-2685 VPernicia 09/09/15
    /*
     * Description : This method is use to compute the amount of refund based on the stop request date
     * Parameters: Id subscriptionId, Date stopReqDate
     * Return : totalProration (Total Proration)
    */
    
    //START D-2553 and D-2560 VPernicia 4/19/15
    public Static Decimal computeRefund (Id subscriptionId, Date stopReqDate){
        
        System.debug('COMPUTE REFUND ENTERED');

        //Computation Variables Instantiation
        nonPubDates = new List<Non_Publication_Day__c>();
        prorationAmountForRemainingDaysBef = 0.00;
        prorationAmountForRemainingDaysAft = 0.00;
        totalProration = 0.00;
        monthDiff = 0;
        remMonthsRefund = 0.00;
        paymentPerMonth = 0.00;
        proratedAmt = 0.00;
        numofcopies = 0.00;
        copyMonth = 0;
        finalMonth = 0;
        pendingCopies = 0;
        pendingcopiesmap = new Map<Id, Decimal>();
        givencopiesmap = new Map<Publication__c, Decimal>();
        //START D-1757 15/01/15 Wenjun : Postage Charge Refund Amount
        Decimal amtPostageRefund = 0.00;
        //END D-1757 15/01/15 Wenjun
        //START: D- 2007 02/12/2015 Added by Kristine Campang - added variable for delivery
        delRef  = 0.00;
        monthDiffDel = 0.00;
        //END: D-2007 02/12/2015 Added by Kristine Campang
        //START: D-0077 03/02/2015 Added by Kristine Campang - added variables instantiation
        pendingCopiesPerPub = 0;
        weekdayIssue = 0.00;
        SaturdayIssue = 0.00;
        SundayIssue = 0.00;
        totalDiscount = 0.00;
        totalDiscountPerPub = 0.00;
        numberOfDays = 0;
        //END: D-0077 03/02/2015 Added by Kristine Campang
        //START: D- 2119 03/11/2015 Added by Kristine Campang - added variable instantiation
        OddFreqIssue = 0.00;
        //END: D- 2119 03/11/2015 Added by Kristine Campang
        //START: D-2120 03/17/2015 Added by Kristine Campang - added variable instance
        isMagazine = false;
        //END: D-2120 03/17/2015 Added by Kristine Campang
            //START: D-2553 03/31/2015 Added by Kristine Campang - added variable instance
            isDigital = false;
            weekdayIssueDisc = 0.00;
            SaturdayIssueDisc = 0.00;
            SundayIssueDisc = 0.00;  
            OddFreqIssueDisc = 0.00;
            numMonth = 0.00;         //STAR-END : D-2553 04/06/2015 Added by Kristine Campang - added logic for online and AIO
            //END: D-2553 03/31/2015 Added by Kristine Campang
            
        //instantiates variables
        zuoSubProdCharg = new List<Zuora__SubscriptionProductCharge__c>();
        zquProdRatePlan = new List<zqu__ProductRatePlan__c>();
        mapZuoProdCharge_ProdCode = new Map<Id, String>();
        mapZuoSubs_ZuoSubProdCharge = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();
        mapProdRatePlanChargeId_toPublicationCode = new Map<Id, Set<String>>();
        mapSubsId_toRatePlan = new Map<Id, Set<String>>();
        dayToCoverPriceMap = new Map<String, Decimal>() ;
        pubToMapDayCoverPriceMap = new Map<String, Map<String, Decimal>>();
        setRatePlan = new Set<String>();
        publiCode = new Set<String>();
        subsIdSet = new Set<Id>();
        //instantiates Product Rate Plan Variables
        ratePlanIds = new Set<Id>();
        productRatePlanList = new List<zqu__ProductRatePlan__c>();
        mapProdRatePlanName_toProductRatePlanRec = new Map<String, zqu__ProductRatePlan__c>();

        //instantiates Product Rate Plan Charges Variables
        prodRatePlanChargesList = new List<zqu__ProductRatePlanCharge__c>();
        mapProdRatePlan_toProdRatePlanCharge = new Map<String, List<zqu__ProductRatePlanCharge__c>>();
        pubCodeSetperPRC = new Set<String>();

        //instantiates Publication variables
        pubList = new List<Publication__c>();
        mapPublicCode_toPublicRec = new Map<String, Publication__c>();
        mapSubsId_toPublicRec = new Map<Id, List<Publication__c>>();
        mapSubsId_toPubList = new Map<Id, List<Publication__c>>();
            //START: D- 2560 04/06/2015 Added by Kristine Campang - added logic for AIO
            AIOPubList = new List<Publication__c>();
            AIOMagazinePub = new List<Publication__c>();
            //END: D- 2560 04/06/2015 Added by Kristine Campang
        //START: Kristine Campang
        mapPRC_UOM_Price = new Map<String, Map<String, Decimal>>();
        mapPubCodeToRatePlanCharge = new Map<String, List<zqu__ProductRatePlanCharge__c>>();
        //START: D-1107 12/18/2014 Added by Kristine Campang - added variables
        zuoSPCForQuantity = new List<Zuora__SubscriptionProductCharge__c>();
        //END: D-1107 12/18/2014 Added by Kristine Campang
        //START: D-1664 1/29/2015 Added by Kristine Campang - instantiated added variable
        setRP = new Set<String>();
        //END: D-1664 1/29/2015 Added by Kristine Campang
        //START: D-2007 02/12/2015 Added by Kristine Campang - added instances of variable for Delivery Refund
        zuoProdChargeDel = new List<Zuora__SubscriptionProductCharge__c>();
        //END: D-2007 02/12/2015 Added by Kristine Campang
        //START: D-0077 03/05/2015 Added by Kristine Campang - added variables for discount
        zuoSubProdChargListDisc = new List<Zuora__SubscriptionProductCharge__c>();
        mapSPCIdToSPCRec = new Map<Id, Zuora__SubscriptionProductCharge__c>();
        zSPCDiscountSet = new Set<Date>();
        zSPCDiscount = new Set<Zuora__SubscriptionProductCharge__c>();
        zSPCDiscountList = new List<Date>();
        mapSPCDiscToPrice = new Map<Id, Decimal>();
        mapDateToSPC = new Map<Date, Id>();
        finalDiscountMap = new Map<Id, List<Date>>();
        totalDiscountDateMap = new Map<Id, List<Date>>();
        totalDiscountAmount = 0.00;
        weekDayDiscount = 0.00;
        sundayDiscount = 0.00;
        sundayDiscount = 0.00;
        //END: D-0077 03/05/2015 Added by Kristine Campang
        //START: D-2551 03/19/2015 Added by Kristine Campang - added variables for postage
        monthDiffPostage = 0.00;
        //END: D-2551 03/19/2015 Added by Kristine Campang
            //START: D- 2560 04/06/2015 Added by Kristine Campang - added variables for AIO     
            isAIO = false;
            isAIOMag = false;
            totalProrationAIOMag = 0.00;
            //END: D- 2560 04/06/2015 Added by Kristine Campan
        
        //Start UD-2685 VPernicia 09/09/15
        mapSPCPrice = new map<string, decimal>();
        //End UD-2685 VPernicia 09/09/15
        //Zuora Subscription Stop
        //START D-1757 15/01/15 Wenjun : Retrieve Delivered By and Postage Charge
        //START: D-2007 02/12/2015 Added by Kristine Campang - retrieve billing account and recipient contact
        //START UD-0356 3/19/2015 Added By C. Lin - Added Order_Line_Item_Number_1__c
            //START: D - 2560 04/06/2015 Added by Kristine Campang - added field for query
        //START: UD-912 04/24/2015 Added by Kristine Campang - added TERM field for query
    //START UD-2657/D-3414/D-3711 Wenjun 19 Oct 15: Retrieve Main Pack Price
        zuoSubscrpt = [SELECT Id, Billing_Type__c, Contract_End_Date_1__c, Credit_Balance__c, Frequency_1__c, Number_of_Copies__c, Product_Code__c, 
                Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Term_Length__c, Zuora__TermStartDate__c, Zuora__TermEndDate__c,
                        Delivered_By_1__c, Postage_Charge__c, Zuora__CustomerAccount__c, Recipient_Contact__r.Address__r.Name, Order_Line_Item_Number_1__c,  
            Order_Line_Item_Number_1__r.Main_Package_Frequency__c, Order_Line_Item_Number_1__r.Ph_d__c, Order_Line_Item_Number_1__r.Ph_e__c,
            Promotion__c, Promotion_Contract_Period_1__c, Main_Package_1__c, Zuora__TermSettingType__c, Main_Package_1__r.Package_Price__c 
                        FROM Zuora__Subscription__c WHERE Id = :subscriptionId];
    //END UD-2657/D-3414/D-3711 Wenjun 19 Oct 15
        //END: UD-912 04/24/2015 Added by Kristine Campang
            //END: D - 2560 04/06/2015 Added by Kristine Campang
        //END UD-0356 3/19/2015 Added By C. Lin
        //END D-1757 15/01/15 Wenjun
        
        //START:D-3102 6/17/15 Added by Manolo Valena - Update stopReqDate variable value to the start date of the subscription selected to show full refund.
        if(zuoSubscrpt.Zuora__SubscriptionEndDate__c > stopReqDate && 
           stopReqDate < zuoSubscrpt.Zuora__SubscriptionStartDate__c && 
           zuoSubscrpt.Zuora__TermSettingType__c == GlobalVariableClass.SUBSCRIPTION_TYPE_TERMED && 
           zuoSubscrpt.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID) {
            stopReqDate = zuoSubscrpt.Zuora__SubscriptionStartDate__c;
        }
        //END:D-3102 6/17/15 Added by Manolo Valena
        
        System.debug('sub' + zuoSubscrpt);
            //START: D- 2560 04/06/2015 Added by Kristine Campang - added logic for AIO
            mainPackage = [SELECT Id
                            FROM Package__c
                            WHERE Id =:zuoSubscrpt.Main_Package_1__c];
                            
            //START: UD-0959 MMallorca 04/23/2015 update query, added filter
            //START UD-2054 7/22/2015 Added By C. Lin - Add Product_Platform__c, Get Bundle Product Package Items
            //Start UD-3432 12/22/15 VPernicia
            map<string, decimal> packagePrice = new map<string, decimal>();
            //End UD-3432 12/22/15 VPernicia
            try{
            pckItems = [SELECT Id, Package__c, Product_Rate_Plan__r.zqu__ZProduct__c, RecordTypeId, Product_Platform__c, Price__c, Product_Family2__c //Start/End UD-3432 12/22/15 VPernicia: added Price__c, Product_Family2__c
                        FROM Package_Item__c
                        WHERE Package__c = :mainPackage.Id AND (RecordTypeId = :ConstantsSLB.getKeyId('Package Item_Base Product') OR RecordTypeId = :ConstantsSLB.getKeyId('Package Item_Bundle Product'))];
            }
            catch(exception ex){
                system.debug('Error ' + ex);
            }
            //END UD-2054 7/22/2015 Added By C. Lin
            //END : UD-0959 MMallorca
            
            //START UD-2054 7/22/2015 Added By C. Lin - Add Product_Platform__c, Get Bundle Product Package Items
            /*zProduct = [SELECT Id, ProductPlatform__c 
                        FROM zqu__ZProduct__c
                        WHERE Id =:pckItems.Product_Rate_Plan__r.zqu__ZProduct__c];*/
            
            for(Package_Item__c pItem : pckItems){
                
                //Start UD-3432 12/22/15 VPernicia
                packagePrice.put(pItem.Product_Family2__c, pItem.Price__c);
                //End UD-3432 12/22/15 VPernicia
                
                if(pItem.Product_Platform__c != null){
                    if(pItem.Product_Platform__c == 'All-In-One'){
                        isAIO = true;
                        if(userinfo.getLastName() == 'accenture devKC'){
                        }
                    }
                }
            }
            //END UD-2054 7/22/2015 Added By C. Lin
            //END: D- 2560 04/06/2015 Added by Kristine Campang
        try{
            //START UD-0356 3/19/2015 Added By C. Lin - Changed WHERE to Order_Line_Item_Number_1__c
            //START UD-1749 1-Jul-2015 Added by JTeves - add filter condition: filter out records with NULL OLI number
            zuoSubDel = [SELECT Id, Name, Subscription_Type_1__c, Zuora__CustomerAccount__c, Recipient_Contact__r.Address__r.Name
                         FROM Zuora__Subscription__c
                         WHERE Order_Line_Item_Number_1__c = :zuoSubscrpt.Order_Line_Item_Number_1__c AND Subscription_Type_1__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY AND Order_Line_Item_Number_1__c != NULL];     
            //END UD-1749 1-Jul-2015 Added by JTeves                         
            //END UD-0356 3/19/2015 Added By C. Lin
            zuoProdChargeDel = [SELECT Id, Zuora__Price__c, Zuora__UOM__c, Zuora__Subscription__c
                                FROM Zuora__SubscriptionProductCharge__c
                                WHERE Zuora__Subscription__c = :zuoSubDel.Id AND Zuora__UOM__c LIKE 'CREDIT%'];
        }
        catch(Exception e){
            System.debug('No Delivery subcription');
        }
        System.debug('ZUOPRODCHARGEDEL' + zuoPRodChargeDel);
        //END: D-2007 02/12/2015 Added by Kristine Campang
        //list of Subscription Product and Charges under Subscription                           
          //START D-3134 VPernicia 6/22/15
          //Start UD-2685 VPernicia 09/09/15: Added Zuora__UOM__c
          zuoSubProdCharg = [SELECT Id, Zuora__RatePlanName__c, Zuora__ProductName__c, Zuora__Quantity__c, Product_Code__c, Zuora__ProductSKU__c, Zuora__Price__c, Zuora__BillingPeriod__c, Zuora__Subscription__c, Zuora__Model__c, PublicationCode__c, Zuora__UOM__c
                              FROM Zuora__SubscriptionProductCharge__c
                              WHERE Zuora__Subscription__c =:subscriptionId];
          //End UD-2685 VPernicia 09/09/15: Added Zuora__UOM__c
          //END D-3134 VPernicia 6/22/15
        //START: D-0077 03/06/2015 Added by Kristine Campang - added query for spc discounts
            //START: D-2553 and D-2560 VPernicia 4/16/15 - Additional criteria Zuora__EffectiveStartDate__c and limit 1
              //Start D-3134 06/19/2015 James/Von
              zuoSubProdChargListDisc = [SELECT Id, Zuora__RatePlanName__c, Zuora__ProductName__c, Zuora__Quantity__c, Product_Code__c, Zuora__ProductSKU__c, Zuora__Price__c, Zuora__BillingPeriod__c, Zuora__Subscription__c, Zuora__Model__c, Zuora__EffectiveStartDate__c, PublicationCode__c
                                  FROM Zuora__SubscriptionProductCharge__c
                                  WHERE Zuora__Subscription__c =:subscriptionId  AND Zuora__Model__c =: GlobalVariableClass.SPC_MODEL_DISCOUNT AND Zuora__ProductName__c LIKE '%discount%' 
                                  AND Zuora__EffectiveStartDate__c <=: zuoSubscrpt.Zuora__SubscriptionEndDate__c 
                                  ORDER BY Zuora__EffectiveStartDate__c ASC
                                  limit 1];
              //End D-3134 06/19/2015 James/Von
            //END: D-2553 and D-2560 VPernicia 4/16/15
        //END: D-0077 03/06/2015 Added by Kristine Campang
        //START: D-1107 12/18/2014 Added by Kristine Campang - created a different list of SPC to allow Quantity to have a value
        zuoSPCForQuantity = [SELECT Zuora__Quantity__c, Product_Code__c, Zuora__ProductSKU__c, Zuora__Subscription__c, Zuora__RatePlanName__c
                            FROM Zuora__SubscriptionProductCharge__c
                            WHERE Zuora__Subscription__c =:subscriptionId];

        mapZuoSubs_ZuoSubProdCharge.put(subscriptionId, zuoSubProdCharg);//map of Zuora Subscription Id to List of Subscription Product and Charges

        System.debug('MAP Subscription to Subscription Product and Charges:' + zuoSubProdCharg);    

        //assumption: There is only one Rate Plan under that Subcription
        for(Zuora__SubscriptionProductCharge__c zSPC : zuoSubProdCharg){
            setRatePlan.add(zSPC.Zuora__RatePlanName__c);
            System.debug('SET RATE PLAN' + setRatePlan);
            if(zuoSPCForQuantity.size()>0){
                if(zSPC.Zuora__Quantity__c != null){ //D-0881 Catch error for null Quantity in Susbcription Product and Charge record
                    numofcopies = zSPC.Zuora__Quantity__c;
                }
            }
            //START D-3134 VPernicia 6/22/15
            if (zSPC.Zuora__Model__c != GlobalVariableClass.SPC_MODEL_DISCOUNT && ProductSKU != '') {
                
                ProductSKU = zSPC.Zuora__ProductSKU__c;
            }
            //END D-3134 VPernicia 6/22/15
            
            //Start UD-2685 VPernicia 09/09/15
            if (zSPC.Zuora__UOM__c == 'Credit Copy AIO Smartphone') {
                mapSPCPrice.put('Credit Copy AIO Smartphon', zSPC.Zuora__Price__c);  
            } else {
                mapSPCPrice.put(zSPC.Zuora__UOM__c, zSPC.Zuora__Price__c);  
            }          
            //End UD-2685 VPernicia 09/09/15
          }
              
        //START: D-0077 03/05/2015 Added by Kristine Campang - added logic for discount SPCs
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
        //END: D-0077 03/05/2015 Added by Kristine Campang      
        //END: D-1107 12/18/2014 Added by Kristine Campang
        //List all Product Rate Plan under Subscription Product and Charges

        if(setRatePlan.size()>0){
            //Start/End D-2553 22Mar15 JohnD added filter criteria not to include the deleted productrateplan
              //START D-3134 VPernicia 6/22/15
              productRatePlanList = [SELECT Id, Name, BillingType__c, Product_Code__c, RatePlanCode__c, RatePlanType__c, SubscriptionFrequency__c
                                      FROM zqu__ProductRatePlan__c
                                      WHERE Name IN :setRatePlan AND zqu__ZProduct__r.zqu__SKU__c = :ProductSKU and RatePlanType__c = 'Proration' 
                                      AND RatePlanSubType__c = 'Standard' AND zqu__Deleted__c = false];
              //END D-3134 VPernicia 6/22/15
        }
        //START: D-1664 1/29/2015 Added by Kristine Campang - added set for real rate plan Name
        if(productRatePlanList.size()>0){
            System.debug('PROD RATE PLAN NOT NULL ENTERE');
            setRP.add(productRatePlanList[0].Name);
        }
        System.debug('SETRP' + setRP);
        //END: D- 1664 1/29/2015 Added by Kristine Campang 

        for(zqu__ProductRatePlan__c prodRatePlanRec : productRatePlanList){
                ratePlanIds.add(prodRatePlanRec.Id);
                mapProdRatePlanName_toProductRatePlanRec.put(prodRatePlanRec.Name, prodRatePlanRec);
        }   
        System.debug('PROD RATE PLAN LIST:' + productRatePlanList);
        System.debug('RATE Plan IDs:' + ratePlanIds);
        System.debug('MAP of Product Rate Plan Name to Product Rate Plan Record:' + mapProdRatePlanName_toProductRatePlanRec);
        //List all Product Rate Plan Charges under Product Rate Plan
        if(setRatePlan.size()>0){
            //Start/End D-2553 22Mar15 JohnD added filter criteria not to include the deleted ProductRatePlanCharge
              //START D-3134 VPernicia 6/22/15
              prodRatePlanChargesList = [SELECT Id, zqu__Type__c, zqu__RecurringPeriod__c, zqu__ProductRatePlan__c, zqu__ProductRatePlan__r.Name,  Product_Code__c, PublicationCode__c, zqu__UOM__c, Sum__c
                                          FROM zqu__ProductRatePlanCharge__c
                                          WHERE zqu__ProductRatePlan__r.Name IN : setRatePlan AND zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c = :ProductSKU and zqu__ProductRatePlan__r.RatePlanType__c = 'Proration' AND zqu__ProductRatePlan__r.RatePlanSubType__c = 'Standard' 
                                          AND zqu__Deleted__c = false];
              //END D-3134 VPernicia 6/22/15
        }                          
        System.debug('LIST Product Rate Plan Charges:' + prodRatePlanChargesList);
        
        for(zqu__ProductRatePlanCharge__c prodRatePlanChargeRec : prodRatePlanChargesList){
                publiCode.add(prodRatePlanChargeRec.PublicationCode__c);
                mapProdRatePlan_toProdRatePlanCharge.put(prodRatePlanChargeRec.zqu__ProductRatePlan__r.Name, prodRatePlanChargesList);
                
                if(mapPubCodeToRatePlanCharge.containsKey(prodRatePlanChargeRec.PublicationCode__c)){
                    mapPubCodeToRatePlanCharge.get(prodRatePlanChargeRec.PublicationCode__c).add(prodRatePlanChargeRec);
                }
                else{
                    mapPubCodeToRatePlanCharge.put(prodRatePlanChargeRec.PublicationCode__c, new List<zqu__ProductRatePlanCharge__c>{prodRatePlanChargeRec});
                }      
        }
        
        System.debug('SET of Publication Code:' +  publiCode);
        System.debug('MAP of Product Rate Plan to Product Rate Plan Charges List:' +  mapProdRatePlan_toProdRatePlanCharge);
        System.debug('MAP of Product Rate Plan Charges Id to Publication Codes:' +  mapProdRatePlanChargeId_toPublicationCode);
        
        //List all Publications under the Product Rate Plan Charges
        if(publiCode.size()>0){
                //START D-1757 15/01/15 Wenjun : Retrieve Publication_Type__c, Frequency_Code__c, Publication_Next_Start_Date__c 
    //START: D- 2119 03/13/2015 Added by Kristine Campang - added fields for query
                //START:UD-0784 5/13/15 Added by Manolo Valena - Added Publication_Platform_AIO__c field in query.
                //START: UD-1761 7/7/2015 JLedesma Changed criteria for Publication's Platform Type and Publication Platform
                pubList = [SELECT Id, Name, Publication_Code__c, Publish_Pattern__c, Published_Days__c,
                            Publication_Type__c, Frequency_Code__c, Publication_Next_Start_Date__c, Platform_Type__c,
                            Publication_Platform_AIO__c
                           FROM Publication__c WHERE Publication_Code__c IN :publiCode];
                //END: UD-1761 7/7/2015 JLedesma Changed criteria for Publication's Platform Type and Publication Platform
                //END:UD-0784 5/13/15 Added by Manolo Valena
                //END D-1757 15/01/15 Wenjun
                mapSubsId_toPubList.put(subscriptionId, pubList);           
                //gets all Non Pub Dates Related to the Subscription
                nonPubDates = [SELECT Id, Non_Publication_Date__c, Publication__c, Publication_Code__c, 
                            Publication__r.Published_Days__c
                            FROM Non_Publication_Day__c
                            WHERE Publication_Code__c IN :publiCode];

        }
            //START: D-2553 04/06/2015 Added by Kristine Campang - added logic for online and AIO
            for(Publication__c publicRec : pubList){
                    mapPublicCode_toPublicRec.put(publicRec.Publication_Code__c, publicRec);
                    if(mapSubsId_toPublicRec.containsKey(subscriptionId)){
                        mapSubsId_toPublicRec.get(subscriptionId).add(publicRec);
                        
                    }
                    else{
                        mapSubsId_toPublicRec.put(subscriptionId, new List<Publication__c> {publicRec});
                    }
                    //START: UD-1761 7/7/2015 JLedesma Changed criteria for Publication's Platform Type and Publication Platform
                    //START: UD-1761 7/13/2015 JLedesma Changed criteria for Publication's Platform Type and Publication Platform
                    if(publicRec.Publication_Type__c =='M'){
                        isMagazine = true;
                    }
                    if(publicRec.Platform_Type__c == GlobalVariableClass.ONLINE || publicRec.Platform_Type__c == GlobalVariableClass.TABLET || publicRec.Platform_Type__c == GlobalVariableClass.SMARTPHONE){
                        isDigital = true;
                    }
                    if(isAIO){
                        if(publicRec.Publication_Type__c == 'M'){
                            isAIOMag = true;
                            AIOMagazinePub.add(publicRec);
                        }
                        else{
                            AIOPubList.add(publicRec);
                        }
                    }
                    //END: UD-1761 7/7/2015 JLedesma Changed criteria for Publication's Platform Type and Publication Platform
                    //START: UD-1761 7/13/2015 JLedesma Changed criteria for Publication's Platform Type and Publication Platform
            }
            System.debug('pubList' + pubList);
        //END: D- 2119 03/13/2015 Added by Kristine Campang - added fields for query

            System.debug('MAP of Publication Code to Publication Record:' + mapPublicCode_toPublicRec);
            System.debug('MAP of Subscription Id to Publication Record:' + mapSubsId_toPublicRec);
            
            //START: New PC Implementation 12/15/2014 Added by Kristine Campang - Lines transferred to Submit Button
            endDate = zuoSubscrpt.Zuora__SubscriptionEndDate__c;
            givencopiesmap = copiesGivenSub(pubList, startDate, endDate, nonPubDates);
            //END: New PC Implementation 12/15/2014 Added by Kristine Campang
            System.debug('PUBLIST' + pubList);
            System.debug('NONPUB DATES' + nonPubDates);
            System.debug('BILLING TYPE' + zuoSubscrpt.Billing_Type__c);
            System.debug('FIRST CONDITION' + (pubList.size()>0 || nonPubDates.size()>0));
            System.debug('SECOND CONDITION' + String.valueof(zuoSubscrpt.Billing_Type__c !=null));
            //Compute for Fully Prepaid
            //START: D-0077 03/09/2015 Added by Kristine Campang - changed method of proration
            if((pubList.size()>0 || nonPubDates.size()>0) && zuoSubscrpt.Billing_Type__c !=null){
                System.debug('COMPUTATION ENTERED');
                if(zuoSubscrpt.Billing_Type__c == 'Full Prepaid'){     
                    System.debug('FULL PREPAID COMPUTATION ENTERED');
                    if(mapZuoSubs_ZuoSubProdCharge.containsKey(zuoSubscrpt.Id)){
                        
                //START UD-2657/D-3414/D-3711 Wenjun 19 Oct 15: Bypass calculation if stop before start
                if(stopReqDate > zuoSubscrpt.Zuora__SubscriptionStartDate__c)
                    getPendingCopiesMap(pubList, stopReqDate, endDate, nonPubDates, stopReqDate);
                //END UD-2657/D-3414/D-3711 Wenjun 19 Oct 15
                        //D-0881 Move out of Subscription Product and Charge for loop
                        startOfTheMonth = endDate.toStartOfMonth();
                        lastDay = getLastDayOfTheMonth(stopReqDate);
                        
                        //START: D-1589 1/27/2015 Added by Kristine Campang -added condition
                        //START: D-1664 1/27/2014 Added by Kristine Campang - modified if condition - switched methods
                        if((stopReqDate.month() == endDate.month()) && (stopReqDate.year() == endDate.year())){
                            System.debug('STOPREQ CONDITION ENTERED'); 
                            if(stopReqDate == stopReqDate.toStartOfMonth() && endDate == getLastDayOfTheMonth(stopReqDate)){
                                System.debug('STOP AND END MONTH AND YEAR THE SAME ENTERED');
                                monthdiff = 1;
                                prorationAmountForRemainingDaysAft = 0.00;
                                prorationAmountForRemainingDaysBef = 0.00;
                            }
                            //START: D- 2553 03/24/2015 Added by Kristine Campang
                            else{
                                
                                if (zuoSubscrpt.Zuora__SubscriptionEndDate__c >= stopReqDate) {
                                    if(isAIO){
                                        prorationAmountForRemainingDaysAft = getProration(AIOPubList, stopReqDate, endDate, stopReqDate);
                                    }
                                    else{
                                        prorationAmountForRemainingDaysAft = getProration(pubList, stopReqDate, endDate, stopReqDate);
                                    }
                                }
                            //END: D- 2553 03/24/2015 Added by Kristine Campang
                                System.debug('SAME SAME MONTH YEAR END AND STOP' + prorationAmountForRemainingDaysAft);
                            }
                        }
                        else if(stopReqDate > zuoSubscrpt.Zuora__SubscriptionStartDate__c) { //START END UD-2657/D-3414/D-3711 Wenjun 19 Oct 15: Bypass calculation if stop before start
                            System.debug('else major entered');
                            if(endDate ==getLastDayOfTheMonth(endDate)){
                                System.debug('endate entered');
                                if(stopReqDate == stopReqDate.toStartOfMonth()){
                                    System.debug('stop date start of month');
                                    monthDiff = stopReqDate.monthsBetween(endDate) + 1; // no minus 1 for the remaining days not a full month but plus one for stop req as start of moth
                                    prorationAmountForRemainingDaysAft =0.00;
                                    prorationAmountForRemainingDaysBef = 0.00;
                                }
                                else {
                                    System.debug('else not start of month entered');
                                    monthDiff = stopReqDate.monthsBetween(endDate); // no minus 1 for the remaining days not a full month
                                    prorationAmountForRemainingDaysAft =0.00;
                                    //START: D-2553 04/06/2015 Added by Kristine Campang - added logic for online and AIO
                                    if (zuoSubscrpt.Zuora__SubscriptionEndDate__c >= stopReqDate) {
                                        if(isAIO){
                                            prorationAmountForRemainingDaysBef = getProration(AIOPubList, stopReqDate, lastDay, stopReqDate);
                                        }
    
                                        else{
                                            prorationAmountForRemainingDaysBef = getProration(pubList, stopReqDate, lastDay, stopReqDate);
                                        }
                                    }
                                    //END: D-2553 04/06/2015 Added by Kristine Campang - added logic for online and AIO
                                    System.debug('BEFORE:' + prorationAmountForRemainingDaysBef);
                                }

                            }
                            else if(endDate !=getLastDayOfTheMonth(endDate)){
                                System.debug('End date not last day entered');
                                //START: D-1664 1/27/2015 Added by Kristine Campang - included if condition for stop date month equal with end date month
                                if(stopReqDate.month() != endDate.month() && stopReqDate != stopReqDate.toStartOfMonth()){
                                    System.debug('Stop Req not equal to end month entered');
                                    monthDiff = stopReqDate.monthsBetween(endDate)-1; // minus 1 for the remaining days not a full month
                                    
                                    ////START-END: DELETED LINES by Kristine Campang D-2553
                                    //START: D- 2553 03/24/2015 Added by Kristine Campang
                                    if (zuoSubscrpt.Zuora__SubscriptionEndDate__c >= stopReqDate) {
                                        if(isAIO){
                                            prorationAmountForRemainingDaysBef = getProration(AIOPubList, stopReqDate, lastDay, stopReqDate);
                                        } else{
                                            prorationAmountForRemainingDaysBef = getProration(pubList, stopReqDate, lastDay, stopReqDate);
                                        }
                                    }
                                    //End: D- 2553 03/24/2015 Added by Kristine Campang
                                    System.debug('PRORATION' + prorationAmountForRemainingDaysBef + 'stop date' + stopReqDate + 'end Date' + lastDay);
                                }
                                if(stopReqDate.month() != endDate.month() && stopReqDate == stopReqDate.toStartOfMonth()){
                                    System.debug('Stop Req not equal to end month entered and stop equal to first day of month');
                                    monthDiff = stopReqDate.monthsBetween(endDate); //minus 1 for the remaining days not a full month plus 1 for start of moth meaning plus 0
                                }
                                if(stopReqDate.month() == endDate.month()){
                                    //START UD-0356 3/23/2015 Added By C. Lin - Added year in the if conditions 'stopReqDate.year() != endDate.year()'
                                    if(stopReqDate.year() != endDate.year() && stopReqDate != stopReqDate.toStartOfMonth()){
                                        System.debug('if entered year is not equal and stop req date is not start of the month');
                                        monthDiff = stopReqDate.monthsBetween(endDate)-1; // minus 1 for the remaining days not a full month
                                        
                                        //START-END: DELETED LINES by Kristine Campang D-2553
                                        //START: D- 2553 03/24/2015 Added by Kristine Campang
                                        if (zuoSubscrpt.Zuora__SubscriptionEndDate__c >= stopReqDate) {
                                            if(isAIO){
                                                prorationAmountForRemainingDaysBef = getProration(AIOPubList, stopReqDate, lastDay, stopReqDate);
                                            } else{
                                                prorationAmountForRemainingDaysBef = getProration(pubList, stopReqDate, lastDay, stopReqDate);
                                            }
                                        }
                                        //END: D- 2553 03/24/2015 Added by Kristine Campang
                                    }else if(stopReqDate.year() != endDate.year() && stopReqDate == stopReqDate.toStartOfMonth()){
                                        System.debug('if entered year is not equal and stop req date is start of the month');
                                        monthDiff = stopReqDate.monthsBetween(endDate); //minus 1 for the remaining days not a full month plus 1 for start of moth meaning plus 0
                                    }
                                    else{
                                        System.debug('else entered year is equal');
                                        monthDiff = 0;
                                    }
                                    //END UD-0356 3/23/2015 Added By C. Lin
                                }
                                //END: D-1664 1/27/2015 Added by Kristine Campang
                                System.debug('MONTH DIFF NOT END OF MONTH:' + monthDiff);

                                //START: D-2120 03/17/2015 Added by Kristine Campang - tranferred logic to other part of code
                                //START: D- 2119 03/13/2015 Added by Kristine Campang - added filter for magazine                       
                                //START-END: DELETED LINES by Kristine Campang D-2553
            
                                //START: D- 2553 03/24/2015 Added by Kristine Campang
                                if (zuoSubscrpt.Zuora__SubscriptionEndDate__c >= stopReqDate) {
                                    if(isAIO){
                                        prorationAmountForRemainingDaysAft = getProration(AIOPubList, startOfTheMonth, endDate,stopReqDate);
                                    }
                                    else{
                                        prorationAmountForRemainingDaysAft = getProration(pubList, startOfTheMonth, endDate,stopReqDate);
                                    }
                                }
                                //END: D- 2553 03/24/2015 Added by Kristine Campang
                                System.debug('PRORATION AFTER' + prorationAmountForRemainingDaysAft + 'stop date' + startOfTheMonth + 'end Date' + endDate);
                                //END: D- 2119 03/13/2015 Added by Kristine Campang
                                //END: D-2120 03/17/2015 Added by Kristine Campang
                            }
                            //D-0881 end
                        }
                        //START:D-2007 02/12/2015 Added by Kristine Campang - logic for delivery
                        if(zuoProdChargeDel.size()>0){
                            System.debug('charge not null' + zuoProdChargeDel);
                            if(stopReqDate == stopReqDate.toStartOfMonth()){
                                monthDiffDel = stopReqDate.monthsBetween(endDate) + 1;
                            }
                            else{
                                monthDiffDel = stopReqDate.monthsBetween(endDate);
                                
                            }
                            //START D-3842 10/30/2015 Added by J.Sarion - Only one sub will have the delivery fee for the refund
                            if(orderType == 'Stop'){
                                if(!oliIdForBundleSetRC.contains(zuoSubscrpt.Order_Line_Item_Number_1__c)){
                                    delRef = monthDiffDel * zuoProdChargeDel[0].Zuora__Price__c;
                                }
                            }
                            else{
                                delRef = monthDiffDel * zuoProdChargeDel[0].Zuora__Price__c;
                            }
                            //END D-3842 10/30/2015 Added by J.Sarion - Only one sub will have the delivery fee for the refund
                        }
                        System.debug('DEL CHARGE REFUND:' + delRef);
                        //END:D-2007 02/12/2015 Added by Kristine Campang
                        System.debug('AFTER:' + prorationAmountForRemainingDaysAft);
                        //START-END: DELETED LINES by Kristine Campang D-2553
                        if(isAIO){
                            AIOPubList = retrieveValidPublications(AIOPubList, stopReqDate);
                            finalMonth = computeMonthlyPayment(AIOPubList,monthDiff);
                        }
                        //START: D- 2553 03/24/2015 Added by Kristine Campang
                        else{
                            pubList = retrieveValidPublications(pubList, stopReqDate);
                            finalMonth = computeMonthlyPayment(pubList,monthDiff);
                        }

                        System.debug('MONTHLY:' + finalMonth);
                        //START 15/01/15 Wenjun : Fix Bug - getProrationforPrepaid is long excecution process
                        //if(getProrationforPrepaid(pubList, stopReqDate, lastDay, nonPubDates, stopReqDate)!=null){
                        //START: D- 0077 03/09/2015 Added by Kristine Campang - added logic for discount
                        //totalDiscountDateMap = getDiscountRange(stopReqDate, endDate); //Deleted D-2553 by VPerniciana
                        System.debug('DISCOUNT DATES:' + totalDiscountDateMap);
                        //START-END: DELETED LINES by Kristine Campang D-2553
                        
                        //START:UD-2491 9/28/15 Added by Manolo Valena - Commented out/removed discount value since SPCs are already discounted when the package is of discount type.
                        /*if(isAIO){
                            totalDiscountAmount = computeDiscount(AIOPubList, stopReqDate, endDate);
                        }
                        else{
                            totalDiscountAmount = computeDiscount(pubList, stopReqDate, endDate);
                        }*/
                        //END:UD-2491 9/28/15 Added by Manolo Valena
                        
                        //END: D- 2553 03/24/2015 Added by Kristine Campang
                        //END: D- 0077 03/09/2015 Added by Kristine Campang
                        System.debug('TOTAL DISCOUNT AMOUNT' + totalDiscountAmount);
                        System.debug('BEFORE' + prorationAmountForRemainingDaysBef);
                        System.debug('>>>>>CHA AFTER' + prorationAmountForRemainingDaysAft);
                        System.debug('>>>>>CHA AIOMAG' + totalProrationAIOMag);
                        //START-END: DELETED LINES by Kristine Campang D-2553
                        
                        //START UD-2657/D-3414/D-3711 Wenjun 19 Oct 15: hanlde if stop before start
                        if(stopReqDate <= zuoSubscrpt.Zuora__SubscriptionStartDate__c)
                        {
                            //Start UD-3432 12/22/15 VPernicia
                            for (Zuora__SubscriptionProductCharge__c getPackagePrice: zuoSubProdCharg) {
                                if (packagePrice.containskey(getPackagePrice.PublicationCode__c)) {    

                                    //START D-4340 20Jan16 AddeBy FrancisBenzon : throw error if price isNull
                                    if(packagePrice.get(getPackagePrice.PublicationCode__c) == null)
                                    {
                                        throw new CustomException(System.Label.ERR_COSPackageItemPriceNull);
                                    }
                                    else {
                                        totalProration = packagePrice.get(getPackagePrice.PublicationCode__c) * zuoSubscrpt.Number_of_Copies__c;
                                    }
                                    //END D-4340 20Jan16 AddeBy FrancisBenzon : throw error if price isNull
                                                                                             
                                }
                                
                                if (totalProration > 0) { break; }
                            }
                            //  totalProration = zuoSubscrpt.Main_Package_1__r.Package_Price__c * zuoSubscrpt.Number_of_Copies__c;
                            //End UD-3432 12/22/15 VPernicia
                        }
                        else
                        {
                            totalProration = (zuoSubscrpt.Number_of_Copies__c * finalMonth) + (prorationAmountForRemainingDaysBef == null ? 0.00 : prorationAmountForRemainingDaysBef) + (prorationAmountForRemainingDaysAft == null ? 0.00 : prorationAmountForRemainingDaysAft) + (totalProrationAIOMag == null ? 0.00 : totalProrationAIOMag);
                            //START: D-2120 03/17/2015 Added by Kristine Campang - added logic for magazine
        
                            //START: D- 2553 03/24/2015 Added by Kristine Campang
                            if (zuoSubscrpt.Zuora__SubscriptionEndDate__c >= stopReqDate) {
                                if(isMagazine == true && isAIO == false){
                                    totalProration = getProration(pubList, stopReqDate, endDate,stopReqDate);
                                }
                                //START: D- 2553 03/24/2015 Added by Kristine Campang
                                if(isAIOMag){
                                    totalProrationAIOMag = getProration(AIOMagazinePub, stopReqDate, endDate,stopReqDate);
                                }
                            }
                        }
                        //END: D- 2553 03/24/2015 Added by Kristine Campang
                        //END: D-2120 03/17/2015 Added by Kristine Campang - added logic for magazine
                        //END UD-2657/D-3414/D-3711 Wenjun 19 Oct 15
                        
                        //END: D-1664 1/27/2014 Added by Kristine Campang
                        //END: D-1589 1/27/2015 Added by Kristine Campang
                        //}    
                        //END 15/01/15 Wenjun
                        //START : New PC Implementation 12/15/2014 Added by Kristine Campang - removed previous computation of Monthly price
                        //END : New PC Implementation 12/15/2014 Added by Kristine Campang
                        //START: D-1589 1/27/2015 Added by Kristine Campang -transferred lines to above code
                        //END: D-1589 1/27/2015 Added by Kristine Campang
                        //START D-1757 15/01/15 Wenjun : Calculate Postage Charge Refund
                        if(zuoSubscrpt.Delivered_By_1__c == 'Mailing Agent')
                        {
                            //START: D-2551 03/19/2015 Added by Kristine Campang - modified logic for postage
                            /*Integer remainingMths = stopReqDate.monthsBetween(endDate);
                            List<String> lstRatePlanNames = new List<String>();
                            lstRatePlanNames.addall(setRatePlan);
                            System.debug('INITIAL REMAINING MONTHS' + remainingMths);
                            //Check if this month copy is Not issued, add 1 month refund
                            if(!SP_ProrationUtility.isIssuedInPeriod(zuoSubscrpt.ID, pubList, stopReqDate.toStartOfMonth(), stopReqDate,
                                                                   nonPubDates, mapProdRatePlanName_toProductRatePlanRec.get(lstRatePlanNames[0])))
                                { remainingMths += 1;}
                            System.debug('FINAL REMAINING MONTHS' + remainingMths);
                            */if(stopReqDate == stopReqDate.toStartOfMonth()){
                                    monthDiffPostage = stopReqDate.monthsBetween(endDate) + 1;
                                }
                                else{
                                    monthDiffPostage = stopReqDate.monthsBetween(endDate);
                                    
                                }
                            System.debug('MONTHDIFF FINAL' + monthDiffPostage);
                            //START D-3047/UD-1347 29-05-2015 Marvin G -Hot fix
                            if (zuoSubscrpt.Postage_Charge__c == null) {
                                amtPostageRefund = monthDiffPostage * 0;
                            }
                            else {
                                amtPostageRefund = monthDiffPostage * zuoSubscrpt.Postage_Charge__c;
                            }
                            //END D-3047/UD-1347 29-05-2015 Marvin G -Hot fix
                            amtPostageRefund.setScale(2);
                        }
                        //END: D-2551 03/19/2015 Added by Kristine Campang
                        //END D-1757 15/01/15 Wenjun
                        System.debug('TOTAL PRORATION' + totalProration);
                        totalProration = totalProration.setScale(2);
                    }
                }
                if(zuoSubscrpt.Billing_Type__c =='Recurring Prepaid' && stopReqDate > zuoSubscrpt.Zuora__SubscriptionStartDate__c){  //START END UD-2657/D-3414/D-3711 Wenjun 19 Oct - Stop before Start
                    System.debug('RECURRING COMPUTATION ENTERED');
                    //START: D-1664 1/30/2015 Added by Kristine Campang - changed end date to last day of the month
                    //START: D-0077 03/08/2015 Added by Kristine Campang - added logic for end date not end of the month
            //START: D- 2119 03/13/2015 Added by Kristine Campang - added logic for blank endDate values
                    //Start: D-0077 VPernicia 5/4/2015: Additional condition for getLastDayOfTheMonth
                    if(endDate != null){
                         if(endDate.month() != stopReqDate.month() || (endDate.month() == stopReqDate.month() && endDate.year() != stopReqDate.year()) /*&& endDate.year() != stopReqDate.year()*/){ //START-END: D-2553 VPernicia
                            endDate = getLastDayOfTheMonth(stopReqDate);
                        }
                        else{
                            endDate = zuoSubscrpt.Zuora__SubscriptionEndDate__c;
                        }
                    }
                    else{
                        endDate = getLastDayOfTheMonth(stopReqDate);
                    }
                    //End: D-0077 VPernicia 5/4/2015: Additional condition for getLastDayOfTheMonth
                    //START: D-2553 and D-2560 VPernicia 4/16/15 - Add query to get discount fro recuring
                      //Start D-3134 06/19/2015 James/Von
                      zuoSubProdChargListDisc = [SELECT Id, Zuora__RatePlanName__c, Zuora__ProductName__c, Zuora__Quantity__c, Product_Code__c, Zuora__ProductSKU__c, Zuora__Price__c, Zuora__BillingPeriod__c, Zuora__Subscription__c, Zuora__Model__c, Zuora__EffectiveStartDate__c, PublicationCode__c
                                  FROM Zuora__SubscriptionProductCharge__c
                                  WHERE Zuora__Subscription__c =:subscriptionId  AND Zuora__Model__c =: GlobalVariableClass.SPC_MODEL_DISCOUNT AND Zuora__ProductName__c LIKE '%discount%' 
                                  AND Zuora__EffectiveStartDate__c <=: endDate and Zuora__EffectiveStartDate__c >=: endDate.ToStartOfMonth()
                                  ORDER BY Zuora__EffectiveStartDate__c ASC
                                  limit 1];
                      //End D-3134 06/19/2015 James/Von
                                
                     for(Zuora__SubscriptionProductCharge__c zSPC : zuoSubProdChargListDisc){
                        mapSPCIdToSPCRec.put(zSPC.Id, zSPC);
                        zSPCDiscount.add(zSPC);
                        if(!zSPCDiscountSet.contains(zSPC.Zuora__EffectiveStartDate__c)){
                            zSPCDiscountSet.add(zSPC.Zuora__EffectiveStartDate__c);
                            zSPCDiscountList.add(zSPC.Zuora__EffectiveStartDate__c);
                        }
                    }
                    //END: D-2553 and D-2560 VPernicia 4/16/15 - Add query to get discount fro recuring
                    //END: D-0077 03/08/2015 Added by Kristine Campang
            //END: D- 2119 03/13/2015 Added by Kristine Campang - added logic for blank endDate values

                    //END: D-1664 1/30/2015 Added by Kristine Campang
                 
                    //START: D-2007 02/12/2015 Added by Kristine Campang - added condition for delivery
                    if(stopReqDate == stopReqDate.toStartOfMonth()){
                        if(zuoProdChargeDel.size()>0){
                            //START D-3842 10/30/2015 Added by J.Sarion - Only one sub will have the delivery fee for the refund
                            if(orderType == 'Stop'){
                                if(!oliIdForBundleSetRC.contains(zuoSubscrpt.Order_Line_Item_Number_1__c)){
                                    delRef = zuoProdChargeDel[0].Zuora__Price__c;
                                }
                            }
                            else{
                                delRef = zuoProdChargeDel[0].Zuora__Price__c;
                            }
                            //END D-3842 10/30/2015 Added by J.Sarion - Only one sub will have the delivery fee for the refund
                        }
                    }
                    System.debug('DEL REF RECURRING:' + delRef);
                    //START: D - 0077 03/09/2015 Added by Kristine Campang - added logic for discount
                    //totalDiscountDateMap = getDiscountRange(stopReqDate, endDate); //START - END D-2533 03-24-2015 added by kristine Campang
                    //END: D - 0077 03/09/2015 Added by Kristine Campang
                    
                    //START: D- 2553 03/24/2015 Added by Kristine Campang
                    //START:UD-2491 9/28/15 Added by Manolo Valena - Commented out/removed discount value since SPCs are already discounted when the package is of discount type.
                    //totalDiscountAmount = computeDiscount(pubList, stopReqDate, endDate);
                    //END:UD-2491 9/28/15 Added by Manolo Valena

//START: UD-760 04/29/2015 Added by Kristine Campang - transferred line here                    
                    getPendingCopiesMap(pubList, stopReqDate, endDate, nonPubDates, stopReqDate);
                    system.debug('pendingcopiesmap Recurring ' + pendingcopiesmap); 
//END: UD-760 04/29/2015 Added by Kristine Campang                  
                    
                    //START: UD-912 04/24/2015 Added by Kristine Campang - added condition for evergreen
                    //START: UD-760 04/29/2015 Added by Kristine Campang - modified publist for monthly in recurring scenarios
                    if (zuoSubscrpt.Zuora__SubscriptionEndDate__c >= stopReqDate || zuoSubscrpt.Zuora__TermSettingType__c == 'Evergreen') {
                        System.debug('weeee');
                        if(isAIO){
                            if(stopReqDate == stopReqDate.toStartOfMonth() && endDate == getLastDayOfTheMonth(stopReqDate)){
                                AIOPubList = retrieveValidPublications(AIOPubList, stopReqDate);
                                totalProration = computeMonthlyPayment(AIOPubList,1);
                            }
                            else{
                                totalProration = getProration(AIOPubList, stopReqDate, endDate, stopReqDate);
                            }
                        }
                        else{
                            if(stopReqDate == stopReqDate.toStartOfMonth() && endDate == getLastDayOfTheMonth(stopReqDate)){
                                System.debug('pubpub' + pubList);
                                System.debug('stop' + stopReqDate);
                                pubList = retrieveValidPublications(pubList, stopReqDate);
                                totalProration = computeMonthlyPayment(pubList,1);
                                System.debug('total whole month recurring' + totalProration);
                            }   
                            else{
                                totalProration = getProration(pubList, stopReqDate, endDate, stopReqDate);
                            }
                        }
                        //END: UD-760 04/29/2015 Added by Kristine Campang
                        System.debug('DISCOUNT RANGES:' + totalDiscountDateMap);    
                        //START: D-1589 1/27/2015 Added by Kristine Campang - modified whole code for recurring and removed some lines
//START/END: 04/29/2015 Removed line by Kristine Campang                        
                        //END: D-1589 1/27/2015 Added by Kristine Campang
                    }
            
                    //END: D-2007 02/12/2015 Added by Kristine Campang
                    //START D-1757 15/01/15 Wenjun : Calculate Postage Charge Refund
                    if(zuoSubscrpt.Delivered_By_1__c == 'Mailing Agent')
                    {
                        Integer refundMths = 0;
                        List<String> lstRatePlanNames = new List<String>();
                        lstRatePlanNames.addall(setRatePlan);
                        
                        //START:D-3060 6/4/15 Added by Manolo Valena - Fix made by Marvin Gatchalian for UD-1443
                        zqu__ProductRatePlan__c prpTOPass = new zqu__ProductRatePlan__c();
                        if (mapProdRatePlanName_toProductRatePlanRec.containskey(lstRatePlanNames[0])) {
                            prpTOPass  = mapProdRatePlanName_toProductRatePlanRec.get(lstRatePlanNames[0]);
                        }
                        else {
                            prpTOPass  = [SELECT Id, Name, BillingType__c, Product_Code__c, RatePlanCode__c, RatePlanType__c, SubscriptionFrequency__c
                                            FROM zqu__ProductRatePlan__c
                                                WHERE Name IN :setRatePlan and SubscriptionFrequency__c <> null limit 1];
                            
                        }
                        
                        if(!SP_ProrationUtility.isIssuedInPeriod(zuoSubscrpt.ID, pubList, stopReqDate.toStartOfMonth(), stopReqDate,
                                                                nonPubDates, prpTOPass))
                        { 
                            refundMths += 1;
                        }
                       
                        if (zuoSubscrpt.Postage_Charge__c != null) {
                            amtPostageRefund = refundMths * zuoSubscrpt.Postage_Charge__c;
                        }
                        else {
                            amtPostageRefund = refundMths * 0;
                        }
                        //END:D-3060 6/4/15 Added by Manolo Valena
                        amtPostageRefund.setScale(2);
                    }
                    //END D-1757 15/01/15 Wenjun
                    totalProration = totalProration.setScale(2);
                    System.debug('TOTAL PRORATION RECURRING:' + totalProration);
                }
            }
            //END: D-0077 03/09/2015 Added by Kristine Campang
            //START D-1757 15/01/15 Wenjun : Include Postage Charge Refund Amount
            System.debug('POSTAGE' + amtPostageRefund);
            //START: D-0077 03/09/2015 Added by Kristine Campang - substracted discount
            system.debug('Pro' + totalProration + 'Post' + amtPostageRefund + 'delRef' + delRef + 'Dis' + totalDiscountAmount);
            if(isDigital == TRUE){
                delRef = 0;
            }
            //START: D-0077 4/29/2015 Added by Kristine Campang - added code validation for subscription that has not started yet
            //START: UD-795 04/30/2015 Added by Kristine Campang - modified filter logic 
            if ((zuoSubscrpt.Zuora__SubscriptionEndDate__c >= stopReqDate && stopReqDate >= zuoSubscrpt.Zuora__SubscriptionStartDate__c) || (zuoSubscrpt.Zuora__TermSettingType__c == 'Evergreen' && stopReqDate >= zuoSubscrpt.Zuora__SubscriptionStartDate__c))  {
                //START:UD-2491 9/28/15 Added by Manolo Valena - Commented out/removed discount value since SPCs are already discounted when the package is of discount type.
                return (Math.abs(totalProration) + amtPostageRefund + Math.abs(delRef) /*- Math.abs(totalDiscountAmount)*/).setScale(2);
                //END:UD-2491 9/28/15 Added by Manolo Valena
            } else {
                return 0;
            }
            //END: UD-795 04/30/2015 Added by Kristine Campang 
            //END: D-0077 4/29/2015 Added by Kristine Campang
            //END: UD-912 04/24/2015 Added by Kristine Campang 
            //END: D-0077 03/09/2015 Added by Kristine Campang
            //END D-1757 15/01/15 Wenjun
            //END: D-2553 04/06/2015 Added by Kristine Campang

    }/*end computeRefund*/
    //END D-2553 and D-2560 VPernicia 4/19/15
    
    
    /*
     * Description: Method to get the Last Day of the MONTH
     * Parameters: Date dateField
     * Return: lastDayOfMonth (last Day of the month)
    */
    public Static Date getLastDayOfTheMonth(Date dateField){   
        numberOfDays = Date.daysInMonth(dateField.year(), dateField.month());
        lastDayOfMonth = Date.newInstance(dateField.year(), dateField.month(), numberOfDays);
        
        return lastDayOfMonth;
    }
    /*
     * Description: Method to get the First Day of the MONTH
     * Parameters: Date dateField 
     * Return: lastDayOfMonth (last Day of the month)
    */
    // Start: D-0462 / 1/8/2015 / K. Tan  / First Day of Month
    public Static Date getfirstDayOfTheMonth(){
         Date datefield = date.today();   
         return Date.newInstance(datefield.year(), dateField.month(), 1);
        
        } 
    // End: D-0462 / 1/8/2015 / K. Tan  / First Day of Month
    
    /*
     * Description: Method that converts Subscription Frequency to a String Similar to Publish Pattern
     * Parameters: Publication__c publicationRecForConvert and zqu__ProductRatePlan__c prodRatePlanForConvert
     * Return: Subscription Frequecny converted into String (subfreq)
    */
    //START 15/01/15 Wenjun : Optimize the code
    public Static String convertSubFreq(Publication__c pubObj, zqu__ProductRatePlan__c prodRatePlan){
        String returnVal = '';
        
        if(prodRatePlan != NULl && pubObj != NULL)
        {
            if(prodRatePlan.SubscriptionFrequency__c == '0')
                returnVal = pubObj.Published_Days__c;
            else if(prodRatePlan.SubscriptionFrequency__c == '1')
                returnVal = 'YYYYYNN';
            else if(prodRatePlan.SubscriptionFrequency__c == '2')
                returnVal = 'NNNNNYY';
            else if(prodRatePlan.SubscriptionFrequency__c == '3')
                returnVal = 'YYYYYYN';
            //START: 01/15/2015 D-1807 J.Teves Set the value of subscription frequency to "0" if NULL
            else returnVal = pubObj.Published_Days__c;
            //END: 01/15/2015 D-1807 J.Teves
        }

        return returnVal;
    }
    
     /*
     * Description: Method for getting the if that day is Eligible for Refund
     * Parameters: Publication__c publicationRec, zqu__ProductRatePlan__c prodRatePlanRec, and  String paramDOW
     * Return: Boolean isRefundable
    */
    public Static Boolean checkifRefundable(Publication__c publicationRec, zqu__ProductRatePlan__c prodRatePlanRec, String paramDOW ){
        isRefundable = false;
        //convert subFREq to equivalent YYYYYNN
        subfreq = convertSubFreq(publicationRec, prodRatePlanRec);
        if(publicationRec != null && subfreq != null && paramDOW != null){ //New Defect 11 Charles Lin Catch null publicationRec or subfreq or paramDOW
        if((publicationRec.Published_Days__c.substring(0,1)== 'Y' && subfreq.substring(0,1)=='Y' && paramDOW == 'MON')
            ||
            (publicationRec.Published_Days__c.substring(1,2)== 'Y' && subfreq.substring(1,2)== 'Y' && paramDOW =='TUE')
            ||
            (publicationRec.Published_Days__c.substring(2,3)== 'Y' && subfreq.substring(2,3)== 'Y' && paramDOW =='WED') 
            ||
            (publicationRec.Published_Days__c.substring(3,4)== 'Y' && subfreq.substring(3,4)== 'Y' && paramDOW =='THU')
            ||
            (publicationRec.Published_Days__c.substring(4,5)== 'Y' && subfreq.substring(4,5)== 'Y' && paramDOW =='FRI')
            ||
            (publicationRec.Published_Days__c.substring(5,6)== 'Y' && subfreq.substring(5,6)== 'Y' && paramDOW =='SAT')
            ||
            (publicationRec.Published_Days__c.substring(6,7)== 'Y' && subfreq.substring(6,7)== 'Y' && paramDOW =='SUN')
            ){
               isRefundable = true;
            }
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Publication or Subscription Frequency');
            ApexPages.addMessage(myMsg);   
        }//End New Defect 11 
            
        return isRefundable;
    }
    
    //END 15/01/15 Wenjun
    /*
     * Description: Method to check for any existing Temp Stop
     * Parameters: Date stpDate
     * Return: Boolean tmpIsWithin 
    */
    public Static Boolean checkTempStop(Date stpDate){
        Boolean tmpIsWithin;
        SubTempStopList = new List<Subscription_Temp_Stop__c>();
        TempStopSet = new Set<Id>();

        SubTempStopList = [SELECT Id, Name, Subscription__c, Temp_Stop__c, Temp_Stop__r.Id
                            FROM Subscription_Temp_Stop__c
                            WHERE Subscription__r.Id =:zuoSubscrpt.Id];
        for(Subscription_Temp_Stop__c subTempRec : SubTempStopList){
            if (subTempRec.Temp_Stop__c!= null){
                TempStopSet.add(subTempRec.Temp_Stop__c);
            }
        }
        
        if(TempStopSet!=null && TempStopSet.size() > 0 ) {      //FYI added AND condition TempStopSet.size() > 0 to trap null
            try{
                TempStopRec = [SELECT Id, Name, Restart_Date__c, Temp_Stop_Date__c, Temp_Stop_Qty__c, Temp_Stop_Status__c
                            FROM Temp_Stop__c
                            WHERE Id IN :TempStopSet AND Cancelled__c !=TRUE AND (Temp_Stop_Date__c <= :stpDate) AND (Restart_Date__c > = :stpDate )];
           }
           catch(exception e){
           }
        }
            if(TempStopRec!=null){
                tmpIsWithin = true;
            }
            
            else{
                tmpisWithin = false;
            
            }
        return tmpIsWithin;

    }
    //START: D-0077 03/09/2015 Added by Kristine Campang - changed proration logic
        //START: D- 2553 04/9/2015 Added by Kristine Campang - modified for all in one and online
    public Static Decimal getProration(List<Publication__c> publications, Date compStartDate, Date compEndDate, Date stp){
        
        
        Set<String> pubCodeSet = new Set<String>();
        Set<Id> pubIdSet = new Set<Id>();
        List<String> ratePlan = new List<String>();
        Map<String, Map<String, Publication_Price__c>> pubCodeToCoverPriceMap = new Map<String, Map<String, Publication_Price__c>>();
        //START: D- 1664 1/30/2015 Added by Kristine Campang- changed variable to be converted to list
        ratePlan.addall(setRP);
        //END: D- 1664 1/30/2015 Added by Kristine Campang
        //Set<Date> withinDates = checkIfWithin(nonPubDateList,compStartDate, compEndDate);
        //START: D-2119 03/11/2015 Added by Kristine Campang - Added logic for magazine, online and AIO
        String numDayOfWeek;
        copyPrice = 0.00;
        boolean tmpS = checkTempStop(stp);
        //for passing of values to getCoverPrice
        for(Publication__c publi : publications){
            pubCodeSet.add(publi.publication_Code__c);
            pubIdSet.add(publi.id);     
        }

        if(TempStopRec != null){
            if(tmpS){
                compStartDate = TempStopRec.Temp_Stop_Date__c;
            }
        }

        for(Publication__c pub : publications){
            
            
            if(mapProdRatePlanName_toProductRatePlanRec.containsKey(ratePlan[0])){
                List<zqu__ProductRatePlanCharge__c> prodRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
                prodRatePlanChargeList = mapPubCodeToRatePlanCharge.get(pub.Publication_Code__c);
                //START: D-2553 4/17/2015 Added by V.Pernicia - Added logic for magazine, online and AIO
                if(pub.Platform_Type__c == 'Online' || pub.Platform_Type__c == 'Smartphone' || pub.Platform_Type__c == 'Tablet') {
                //END: D-2553 4/17/2015 Added by V.Pernicia - Added logic for magazine, online and AIO
                        mapPRC_UOM_Price = getCopyPrice(prodRatePlanChargeList, pub.Publication_Code__c, pub.Platform_Type__c, null); 
                    }
                    else if(pub.Platform_Type__c == 'All in One (AIO)'){
                        System.debug('aio entered');
                        System.debug('ONLINE PUB NAME' + pub.Name);
                        System.debug('BOOL' + string.valueOf((pub.Name).contains('ONLINE')));
                        //START:UD-0784 5/13/15 Added by Manolo Valena - Changed condition to compare the value of the new picklist.
                        if(pub.Publication_Platform_AIO__c == GlobalVariableClass.ONLINE){
                            System.debug('online entered');
                            mapPRC_UOM_Price = getCopyPrice(prodRatePlanChargeList, pub.Publication_Code__c, pub.Platform_Type__c, 'Online'); 
                            System.debug('online' + mapPRC_UOM_Price);
                        }
                        else if(pub.Publication_Platform_AIO__c == GlobalVariableClass.SMARTPHONE){
                            System.debug('smartphone entered');
                            mapPRC_UOM_Price = getCopyPrice(prodRatePlanChargeList, pub.Publication_Code__c, pub.Platform_Type__c, 'Smartphon'); 
                            System.debug('smartphone' + mapPRC_UOM_Price);
                        }
                        else if(pub.Publication_Platform_AIO__c == GlobalVariableClass.TABLET){
                            System.debug('tablet entered');
                            mapPRC_UOM_Price = getCopyPrice(prodRatePlanChargeList, pub.Publication_Code__c, pub.Platform_Type__c, 'Tablet'); 
                            System.debug('tablet' + mapPRC_UOM_Price);
                        }
                        //END:UD-0784 5/13/15 Added by Manolo Valena
                        //START: D-2553 and D-2560 VPernicia 4/16/15
                        else {
                            mapPRC_UOM_Price = getCopyPrice(prodRatePlanChargeList, pub.Publication_Code__c, pub.Platform_Type__c, null); 
                        }
                        //END: D-2553 and D-2560 VPernicia 4/16/15
                    }
                    else{
                        mapPRC_UOM_Price = getCopyPrice(prodRatePlanChargeList, pub.Publication_Code__c, null, null);
                }
                //START: UD-1761 7/7/2015 JLedesma Changed criteria for Publication's Platform Type and Publication Platform
                //START: UD-1761 7/13/2015 JLedesma Changed criteria for Publication's Platform Type and Publication Platform
                if(pub.Publication_Type__c =='M'){
                //END: UD-1761 7/7/2015 JLedesma Changed criteria for Publication's Platform Type and Publication Platform
                //START: UD-1761 7/13/2015 JLedesma Changed criteria for Publication's Platform Type and Publication Platform
                    compStartDate = stp;
                    compEndDate = zuoSubscrpt.Zuora__SubscriptionEndDate__c;
                }

                UsageHelper.initialize();
                PublicationIssueWrapper pubWrapper = UsageHelper.IssueCalculation(pub.Publication_Code__c, compStartDate, compEndDate, zuoSubscrpt, Integer.valueOf(zuoSubscrpt.Number_of_Copies__c));
                weekdayIssue = Decimal.valueOf(pubWrapper.weekday_no_of_copies);
                SaturdayIssue = Decimal.valueOf(pubWrapper.sat_no_of_copies);
                SundayIssue = Decimal.valueOf(pubWrapper.sun_no_of_copies);
                OddFreqIssue = Decimal.valueOf(pubWrapper.odd_freq_copies);
                System.debug('PUB WRAPPER' + pubWrapper);
                System.debug('WAAAAAAAAAAA:' + weekdayIssue +':' + SaturdayIssue + ':' + SundayIssue + ':' + compStartDate + ':' + compEndDate);
                System.debug('MAP PRICE OUTSIDE FOR' + mapPRC_UOM_Price);

                copyPriceWeekday = 0.00;
                copyPriceSaturday = 0.00;
                copyPriceSunday = 0.00;
                copyPriceMagazine = 0.00;
                copyPriceOnline = 0.00;
                    copyPriceAIOTablet = 0.00;
                    copyPriceAIOSmartphone = 0.00;
                    copyPriceAIOOnline = 0.00;
                        //END: D-2553 and D-2560 VPernicia 4/16/15

                for(zqu__ProductRatePlanCharge__c prodRatePlanChrg : prodRatePlanChargeList){
                        System.debug('WEEKDAY' + weekdayIssue);
                        System.debug('MAP PRICE' + mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Weekday'));
                        if(prodRatePlanChrg.zqu__UOM__c == 'Credit Copy Weekday'){
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('Weekday')){
                                copyPriceWeekday = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Weekday') !=null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Weekday') : 0) * weekdayIssue;
                            }
                             System.debug('weekday' + copyPriceWeekday);
               
                        }
                        else if(prodRatePlanChrg.zqu__UOM__c == 'Credit Copy Sat'){
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('Sat')){
                                copyPriceSaturday = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Sat') !=null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Sat') : 0) * SaturdayIssue;
                            }
                             System.debug('Saturday' + copyPriceSaturday);
               
                        }
                        else if(prodRatePlanChrg.zqu__UOM__c == 'Credit Copy Sun'){
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('Sun')){
                                copyPriceSunday = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Sun') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Sun') : 0) * SundayIssue;
                            }
                             System.debug('Sunday' + copyPriceSunday);
                        }
                        else if(prodRatePlanChrg.zqu__UOM__c == 'Credit Copy Issue ' + pub.Publication_Code__c){
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('Magazine')){
                                copyPriceMagazine = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Magazine') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Magazine') : 0) * OddFreqIssue;
                            }
                        }
    //START: D-2120 and D-2119 03/17/2015 Added by Kristine Campang - added logic for online and magazine
                        else if(prodRatePlanChrg.zqu__UOM__c == 'Credit Copy Online'){
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('Online')){
                                copyPriceOnline = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Online') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Online') : 0) * OddFreqIssue;
                            }
                        }
                        else if(prodRatePlanChrg.zqu__UOM__c == 'Credit Copy Smartphone'){
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('Smartphone')){
                                copyPriceOnline = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Smartphone') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Smartphone') : 0) * OddFreqIssue;
                            }
                        }
                        else if(prodRatePlanChrg.zqu__UOM__c == 'Credit Copy Tablet'){
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('Tablet')){
                                copyPriceOnline = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Tablet') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Tablet') : 0) * OddFreqIssue;
                            }
                        }
                        else if(prodRatePlanChrg.zqu__UOM__c == 'Credit Copy AIO Tablet'){
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('AIO Tablet')){
                                    copyPriceAIOTablet = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('AIO Tablet') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('AIO Tablet') : 0) * OddFreqIssue;
                            }
                        }
                        else if(prodRatePlanChrg.zqu__UOM__c == 'Credit Copy AIO Online'){
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('AIO Online')){
                                    copyPriceAIOOnline = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('AIO Online') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('AIO Online') : 0) * OddFreqIssue;
                            }
                        }
                        else if(prodRatePlanChrg.zqu__UOM__c == 'Credit Copy AIO Smartphon'){ //START/END: D-2553 4/17/2015 Added by V.Pernicia - Added logic for magazine, online and AIO
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('AIO Smartphon')){ //START/END: D-2553 4/17/2015 Added by V.Pernicia - Added logic for magazine, online and AIO
                                    copyPriceAIOSmartphone = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('AIO Smartphon') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('AIO Smartphon') : 0) * OddFreqIssue;
                                }
                            }
                            else if(prodRatePlanChrg.zqu__UOM__c == 'Credit Copy AIO Smartphone'){
                                if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('AIO Smartphone')){
                                    copyPriceAIOSmartphone = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('AIO Smartphone') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('AIO Smartphone') : 0) * OddFreqIssue;
                                }
                            }
    //END: D-2120 and D-2119 03/17/2015 Added by Kristine Campang - added logic for online and magazine
                        
                }
                //START: D-2553 4/17/2015 Added by V.Pernicia - Added logic for magazine, online and AIO
                copyPrice += Math.abs(copyPriceWeekday + copyPriceSaturday + copyPriceSunday + copyPriceMagazine + copyPriceOnline + copyPriceAIOTablet + copyPriceAIOOnline + copyPriceAIOSmartphone);
                System.debug('COPY PRICE:' + copyPrice + ':weekday' + copyPriceWeekday + ':sat' + copyPriceSaturday + ':sun' + copyPriceSunday + 'aioonline' + copyPriceAIOOnline + 'aiotablet' + copyPriceAIOTablet + 'aiosmartphone' + copyPriceAIOSmartphone);
                //proratedAmt += copyPrice;
                //END: D-2553 4/17/2015 Added by V.Pernicia - Added logic for magazine, online and AIO
                system.debug('>>>>>>>>>>>> ' + copyPriceWeekday + ' : ' + copyPriceSaturday + ' : ' + copyPriceSunday + ' : '+ proratedAmt );
            }
        }
        return copyPrice;
        //END: D-2119 03/11/2015 Added by Kristine Campang
            //END: D- 2553 04/9/2015 Added by Kristine Campang - added variables for AIO
    }
    
    
        /*  
     * Description: Method for Getting Pending Copies
     * Parameters : List<Publication__c> publications, Date compStartDate, Date compEndDate, List<Non_Publication_Day__c> nonPubDateList, Date stp
     *Return : pendingcopiesmap
    */
        //START: D- 2553, D-2560 04/9/2015 Added by Kristine Campang - chnaged quantity to number of copies
    public Static void getPendingCopiesMap(List<Publication__c> publications, Date compStartDate, Date compEndDate, List<Non_Publication_Day__c> nonPubDateList, Date stp){
   
        System.debug('get pending copies map entered');
        List<String> ratePlan = new List<String>();
        //START: D- 1664 1/30/2015 Added by Kristine Campang- changed variable to be converted to list
        ratePlan.addall(setRP);
        System.debug('SET RATE PLAN' + ratePlan);
        //END: D- 1664 1/30/2015 Added by Kristine Campang
        //Set<Date> withinDates = checkIfWithin(nonPubDateList,compStartDate, compEndDate);
        //System.debug('within dates' + withinDates);
        String numDayOfWeek;

        boolean tmpS = checkTempStop(stp);
        system.debug('Publications : ' + publications);
        
        if(TempStopRec != null){
            if(tmpS){
                compStartDate = TempStopRec.Temp_Stop_Date__c;
            }
        }
            //get Cover Price for all Publications
            //pubCodeToCoverPriceMap = getCoverPrice(pubCodeSet, pubIdSet);
            
        //START: UD-2984 10/7/15 Added by Manolo Valena
        UsageHelper.initialize();
        //END: UD-2984 10/7/15 Added by Manolo Valena
            
        //START: UD-795 04/30/2015 Added by Kristine Campang - modified filter logic    
        for(Publication__c pub : publications){
            if(mapProdRatePlanName_toProductRatePlanRec.containsKey(ratePlan[0])){
                System.debug('if pending entered');
                
                if(compStartDate >= zuoSubscrpt.Zuora__SubscriptionStartDate__c){
                    //START: UD-2984 10/7/15 Added by Manolo Valena
                    //UsageHelper.initialize();
                    //END: UD-2984 10/7/15 Added by Manolo Valena
                    PublicationIssueWrapper pubWrapperPending = UsageHelper.IssueCalculation(pub.Publication_Code__c , compStartDate, compEndDate, zuoSubscrpt, Integer.valueOf(numofcopies));
        //START: D- 2119 03/13/2015 Added by Kristine Campang - added fields accumulated amount
                    pendingCopiesPerPub = pubWrapperPending.weekday_no_of_copies + pubWrapperPending.sat_no_of_copies + pubWrapperPending.sun_no_of_copies + pubWrapperPending.odd_freq_copies;
        //END: D- 2119 03/13/2015 Added by Kristine Campang - added fields accumulated amount
                    pendingcopiesmap.put(pub.Id, pendingCopiesPerPub);
                    System.debug('PUB WRAPPPER PENDING' + pubWrapperPending);
                }
                else{
                    pendingcopiesmap.put(pub.Id, 0);
                }
            }
        }
        //END: UD-795 04/30/2015 Added by Kristine Campang
         System.debug('PENDING COPIES MAP:' + pendingcopiesmap);
    }
    //END: D-0077 03/09/2015 Added by Kristine Campang
        //END: D- 2553, D-2560 04/9/2015 Added by Kristine Campang - added variables for AIO        

    
    public static Map<Publication__c, Decimal> copiesGivenSub(List<Publication__c> publications, Date compStartDate, Date compEndDate, List<Non_Publication_Day__c> nonPubDateList){
        Map<Publication__c, Decimal> copiesgiven = new Map<Publication__c, Decimal>();
        List<String> ratePlan = new List<String>();
        ratePlan.addall(setRatePlan);
        Set<Date> withinDates = checkIfWithin(nonPubDateList,compStartDate, compEndDate);
        for(compStartDate = compStartDate; compStartDate <= compEndDate; compStartDate = compStartDate.addDays(1)) { 
                try{
                if(withinDates.size()>0){
                    if(withinDates.contains(compStartDate)){
                        continue;
                    }
                }}
                catch(Exception e){
                    System.debug('WithinDates is null');
                }
                    dayOfWeek = ((DateTime)compStartDate).format('EEE');   
                        
                        for(Publication__c pub : publications){
                            if(mapProdRatePlanName_toProductRatePlanRec.containsKey(ratePlan[0])){
                                try{Boolean deliverable = checkifRefundable(pub, mapProdRatePlanName_toProductRatePlanRec.get(ratePlan[0]), dayOfWeek);
                                
                                    if(deliverable){
                                        if(copiesgiven.containsKey(pub)){
                                            Decimal given = copiesgiven.get(pub);
                                            given = given + numofcopies;
                                            copiesgiven.put(pub,given);
                                              
                                        }else{
                                            copiesgiven.put(pub,numofcopies);
                                        }                                    
                                                                                                 
                                    }
                                }
                                catch(Exception e){
                                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error' + e);
                                }
                            }
                        }
            }
        
        return copiesgiven;
    }

    /*
     * Description: Method for checking if Non Publication Days are Within the Effective Period
     * Parameters: List<Non_Publication_Day__c> nonPubDatesList, Date strDate, Date lastDate
     * Return: nonPubDatesWithinSet ( all non Publication Days that are Within the Subscription's start date and end date
    */
    public Static Set<Date>  checkIfWithin(List<Non_Publication_Day__c> nonPubDatesList, Date strDate, Date lastDate){
            nonPubDatesWithinSet = new Set<Date>();
            for(Non_Publication_Day__c nonPubDateRec : nonPubDatesList){
                if(strDate<=nonPubDateRec.Non_Publication_Date__c && nonPubDateRec.Non_Publication_Date__c<=lastDate){
                    
                    nonPubDatesWithinSet.add(nonPubDateRec.Non_Publication_Date__c);            
                }
            }
            return nonPubDatesWithinSet;
    }

    public Static Decimal getpending(Publication__c publication){
        system.debug('getpending publication ' + publication);
        system.debug('pendingcopiesmap.containsKey(publication.Id) ' + pendingcopiesmap.containsKey(publication.Id));
        system.debug('pendingcopiesmap ' + pendingcopiesmap);
        if (pendingcopiesmap.containsKey(publication.Id)){
            pendingcopies = pendingcopiesmap.get(publication.Id);
            system.debug('pendingcopies ' + pendingcopies);
        }else{
            pendingcopies = 0;
        }
        
        pendingcopies = pendingcopies.setScale(2);
        
        return pendingcopies;
    }
        //START: D- 2553/ D-2560 04/9/2015 Added by Kristine Campang - modified logic for all in one and discount
        public Static Map<String, Map<String, Decimal>> getCopyPrice (List<zqu__ProductRatePlanCharge__c> prodRatePlanChargeList, String publicationCode, String platform, String pubName){
    
        Map<String, Map<String, Decimal>> mapProdRatePlanCh_mapUOM_Price = new Map<String, Map<String, Decimal>>();
        String monthUOM = 'Credit Copy Month ' + publicationCode;
            //START: D-2119 03/11/2015 Added by Kristine Campang - added logic for magazine, online, and AIO
            String magazineUOM = 'Credit Copy Issue ' + publicationCode;
            String onlineUOM = 'Credit Copy ' + platform;
            String AIOUOM = 'Credit Copy AIO ' + pubName;
           
            for(zqu__ProductRatePlanCharge__c prodRatePlanChrgRec : prodRatePlanChargeList){
                mapProdRatePlanCh_mapUOM_Price.put(prodRatePlanChrgRec.Id, new Map<String, Decimal>());
                //Start UD-2685 VPernicia 09/09/15: Pull the Price from mapSPCPrice
                if(prodRatePlanChrgRec.zqu__UOM__c == 'Credit Copy Weekday'){
                    mapProdRatePlanCh_mapUOM_Price.get(prodRatePlanChrgRec.Id).put('Weekday', mapSPCPrice.get('Credit Copy Weekday'));
                }
                if(prodRatePlanChrgRec.zqu__UOM__c == 'Credit Copy Sat'){
                    mapProdRatePlanCh_mapUOM_Price.get(prodRatePlanChrgRec.Id).put('Sat' , mapSPCPrice.get('Credit Copy Sat'));
                }
                if(prodRatePlanChrgRec.zqu__UOM__c == 'Credit Copy Sun'){
                    mapProdRatePlanCh_mapUOM_Price.get(prodRatePlanChrgRec.Id).put('Sun' , mapSPCPrice.get('Credit Copy Sun'));
                }
                if(prodRatePlanChrgRec.zqu__UOM__c == monthUOM){
                    mapProdRatePlanCh_mapUOM_Price.get(prodRatePlanChrgRec.Id).put('Month' , mapSPCPrice.get(monthUOM));
                }
                //START: D- 2119 03/11/2015 Added by Kristine Campang - added UOM for magazine and online
                if(prodRatePlanChrgRec.zqu__UOM__c == magazineUOM){
                    mapProdRatePlanCh_mapUOM_Price.get(prodRatePlanChrgRec.Id).put('Magazine' , mapSPCPrice.get(magazineUOM));
                }
                if(prodRatePlanChrgRec.zqu__UOM__c == onlineUOM){
                    mapProdRatePlanCh_mapUOM_Price.get(prodRatePlanChrgRec.Id).put(platform, mapSPCPrice.get(onlineUOM));
                }
                if(prodRatePlanChrgRec.zqu__UOM__c == AIOUOM){
                    mapProdRatePlanCh_mapUOM_Price.get(prodRatePlanChrgRec.Id).put('AIO ' + pubName , mapSPCPrice.get(AIOUOM));
                }
                //END: D- 2119 03/11/2015 Added by Kristine Campang
                //END: D-2119 03/11/2015 Added by Kristine Campang
                //End UD-2685 VPernicia 09/09/15: Pull the Price from mapSPCPrice
            }
            
            return mapProdRatePlanCh_mapUOM_Price;
        }
    
    public Static Decimal computeMonthlyPayment(List<Publication__c> publicList, Integer monthDifference){
    
        Decimal monthly = 0;
        Decimal paymentMonth = 0;
        System.debug('MONTH DIFF' + monthDifference);
        for(Publication__c publicRec : publicList){
            List<zqu__ProductRatePlanCharge__c> productRatePlanChargesList = new List<zqu__ProductRatePlanCharge__c>();
            productRatePlanChargesList = mapPubCodeToRatePlanCharge.get(publicRec.Publication_Code__c);
                mapPRC_UOM_Price = getCopyPrice(productRatePlanChargesList, publicRec.Publication_Code__c, null, null); 
            System.debug('PRODUCT RATE PLAN CHARGE LIST:' + productRatePlanChargesList);
            System.debug('MAP PRC UOM:' + mapPRC_UOM_Price);
        //END: D- 2553 04/9/2015 Added by Kristine Campang
            
            for(zqu__ProductRatePlanCharge__c zquPRC : productRatePlanChargesList){
                if(mapPRC_UOM_Price.get(zquPRC.Id).containsKey('Month')){
                    copyMonth = (mapPRC_UOM_Price.get(zquPRC.Id).get('Month') != null ? mapPRC_UOM_Price.get(zquPRC.Id).get('Month') : 0);
                    System.debug('COPY MONTH' + copyMonth);
                }
                //START: D-1589 1/27/2015 Added by Kristine Campang - added condition to avoid 0 monthly
                if(monthDifference !=0){
                    monthly = (copyMonth * monthDifference);
                    
                }
                else{
                    monthly = 0;
                }
                //END: D-1589 1/27/2015 Added by Kristine Campang
                System.debug('MONTHLY METHOD' + monthly);
            }
            paymentMonth += monthly;
        }
        //START: D-2119 03/11/2015 Added by Kristine Campang - made the return value positive

        return Math.abs(paymentMonth);
        //END: D-2119 03/11/2015 Added by Kristine Campang - made the return value positive
    }
    //START: D-0077 03/09/2015 Added by Kristine Campang - added logic for discount
        //START: D- 2553 04/9/2015 Added by Kristine Campang - modifed method name and logic for discount
        /*public static Map<Id, List<Date>> getDiscountRange(Date strDate, Date enDate){
            
            System.debug('DISCOUNT LIST' + zSPCDiscountList);
            Integer counter;
            for(counter = 0; counter < zSPCDiscountList.size(); counter++){
                System.debug('loop entered');
                if(zSPCDiscountList[counter] >= strDate && zSPCDiscountList[counter] <= enDate){
                    System.debug('str prior entered');
                    System.debug('first if date  ' + zSPCDiscountList[counter] + strDate + enDate);
                    System.debug('first' + String.valueof(zSPCDiscountList[counter] >= strDate));
                    System.debug('second' + String.valueof(zSPCDiscountList[counter] <= enDate));
                    System.debug('first if entered');
                    if(counter != zSPCDiscountList.size()-1){
                        System.debug('hindi dulong counter');
                        if(zSPCDiscountList[counter+1] > enDate){
                            System.debug('next discount is later than the end date');
                            finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{zSPCDiscountList[counter], enDate});
                        }
                        else{
                            System.debug('else next discount is later');
                            finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{zSPCDiscountList[counter], zSPCDiscountList[counter + 1] - 1});
                        }
                    } 
                    else {
                        System.debug('last discount on the list');
                        if (zSPCDiscountList.size() > 1) {
                            if(zSPCDiscountList[counter-1] > strDate){
                                System.debug('stop date is before prior discount');
                                finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{zSPCDiscountList[counter], enDate});
                            }
                            else {
                                System.debug('else');
                                finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{zSPCDiscountList[counter], enDate});
                            }
                        } else {
                            finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{zSPCDiscountList[counter], enDate});
                        }
                    }
                }
                else if(zSPCDiscountList[counter] < strDate && zSPCDiscountList[counter] <= enDate){
                    System.debug('else if entered');
                    if(counter == 0){
                        System.debug('first discount');
                        if(zSPCDiscountList.size() > 1){
                            System.debug('more than one discount');
                            if(zSPCDiscountList[counter+1] < strDate){
                                System.debug('yow');
                                if(counter != zSPCDiscountList.size()-1){
                                    System.debug('should continue');
                                    continue;
                                }
                            }
                            else{
                                System.debug('str prior entered');
                                if(zSPCDiscountList[counter+1] > enDate){
                                    System.debug('if if if ');
                                    finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{strDate, enDate});
                                }
                                else{
                                    System.debug('tine');
                                    finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{strDate, zSPCDiscountList[counter + 1] - 1});
                                }
                            }
                        } 
                        else {
                            System.debug('debug debug');
                            finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{strDate, endDate});
                        }
                    }
                    else{
                        System.debug('entered else');
                        if(counter != zSPCDiscountList.size()-1){
                            System.debug('campang');
                            if(zSPCDiscountList[counter+1] < strDate){
                                System.debug('should continue');
                                continue;
                            }
                            else{
                                System.debug('another debug');
                                finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{strDate, zSPCDiscountList[counter+1]-1});
                            }
                        }
                        else{
                            System.debug('debugging');
                            finalDiscountMap.put(mapDateToSPC.get(zSPCDiscountList[counter]), new List<Date>{strDate, enDate});
                        }
                    }               
                }
            }
        //END: D- 2553 04/9/2015 Added by Kristine Campang
        
        /*public static Map<Id, List<Date>> getDiscountRange(Date strDate, Date enDate) {


            return finalDiscountMap;
        }*/        
        
        //START: D- 2553/D-2560 04/9/2015 Added by Kristine Campang - added new method for all in one
        /*public static void GetWeekDays(Publication__c pubRec, date DDate1, date DDate2, Boolean IsStopDate) {
        
            Date DateFrom;
            Date DateTo;
            boolean isWeekDay=true;
                
            Date myDate1 = date.newinstance(DDate1.year(), DDate1.month(), DDate1.day());
            Date EndOfMonth1= getLastDayOfTheMonth(DDate1);
            Date StartOfMonth1 = date.newinstance(DDate1.year(), DDate1.month(), 1);
        
            Date myDate2 = date.newinstance(DDate2.year(), DDate2.month(), DDate2.day());
            Date EndOfMonth2= getLastDayOfTheMonth(DDate2);
            Date StartOfMonth2 = date.newinstance(DDate2.year(), DDate2.month(), 1);
        
            if (DDate1.month() == DDate2.month()) {
            
                if (myDate1 == StartOfMonth1 && myDate2 == EndOfMonth2) {
                    numMonth = 1;
                    isWeekDay = false;system.debug('>>>> 1 only');
                }               
                DateFrom = DDate1;
                DateTo = DDate2;
                
            } else {
            
                if (DDate2 == EndOfMonth2) {
                    
                    if (DDate1 == StartOfMonth1) {
                        DateFrom = DDate1;
                        DateTo = EndOfMonth1;
                        isWeekDay= false;
                        numMonth = DDate1.monthsBetween(DDate2) + 1;
                        system.debug('Date1 >>>>' + numMonth + StartOfMonth1 + EndOfMonth1 + DDate1 + DateTo + DDate2);
                        
                    } else {
                        DateFrom = DDate1;
                        DateTo = EndOfMonth1;
                        numMonth = DDate1.monthsBetween(DDate2);
                        system.debug('Date2 >>>>' + numMonth + StartOfMonth1 + EndOfMonth1 + DDate1 + DateTo + DDate2);
                    }
                    
                    
                    system.debug('numMonth1 >>>>' + numMonth + DDate1 + DateTo );
                } else {
                    
                    if (IsStopDate) {
                    
                        DateFrom = DDate1;
                        DateTo = EndOfMonth1;
                        
                        if (DDate1 == StartOfMonth1) { 
                            numMonth = DDate1.monthsBetween(DDate2);
                        } else {
                            numMonth = DDate1.monthsBetween(DDate2) - 1;
                        }     
                        
                        system.debug('numMonth2 Von1>>>> Date From' + DateFrom + ' To: ' + DateTo);
                    } else {
                        
                        DateFrom = StartOfMonth2;
                        DateTo = DDate2;
                        
                        if (DDate1 == StartOfMonth1) { 
                            numMonth = DDate1.monthsBetween(DDate2);
                        } else {
                            numMonth = DDate1.monthsBetween(DDate2) - 1;
                        } 
                        
                        system.debug('numMonth2 Von2>>>>  Date From' + DateFrom + ' To: ' + DateTo);
                    }
                    
                    system.debug('numMonth2 >>>>' + numMonth );
                }        
            }
                 
            
            Date myDate3 = date.newinstance(DateFrom.year(), DateFrom.month(), DateFrom.day());
            Date EndOfMonth3= getLastDayOfTheMonth(DateFrom);
            Date StartOfMonth3 = date.newinstance(DateFrom.year(), DateFrom.month(), 1);
            
            /*
            if (DateFrom == DateFrom.ToStartOfMonth() && DateTo == EndOfMonth3 && isMagazine == false) {
                isWeekDay= false;
                system.debug('isWeekDay entry1' + isWeekDay);
            } 
            
            if (IsStopDate == false) {
                if (DDate1.month() == DDate2.month() && DDate1.year() == DDate2.year()){
                    isWeekDay= false;
                    system.debug('isWeekDay entry2' + isWeekDay);
                }
            }
            System.debug('Date Range before -Von:' + DateFrom + ' to ' + DateTo + isWeekDay);
            if(isMagazine) {
                DateFrom = DDate1;
                DateTo = DDate2;
            }
        
            if (isWeekDay== true) {
                UsageHelper.initialize();
                PublicationIssueWrapper pubWrapperDiscount = UsageHelper.IssueCalculation(pubRec.Publication_Code__c, DateFrom, DateTo, zuoSubscrpt, Integer.valueOf(zuoSubscrpt.Number_of_Copies__c));
                System.debug('Date Range -Von:' + DateFrom + ' to ' + DateTo + 'pubRec >>>' + pubRec.Publication_Code__c + '>>>' + Integer.valueOf(zuoSubscrpt.Number_of_Copies__c));
                weekdayIssueDisc = weekdayIssueDisc + Decimal.valueOf(pubWrapperDiscount.weekday_no_of_copies);
                SaturdayIssueDisc = SaturdayIssueDisc + Decimal.valueOf(pubWrapperDiscount.sat_no_of_copies);
                SundayIssueDisc = SundayIssueDisc + Decimal.valueOf(pubWrapperDiscount.sun_no_of_copies);
                if(isMagazine){
                    if (IsStopDate == true) {
                        OddFreqIssueDisc = Decimal.valueOf(pubWrapperDiscount.odd_freq_copies);
                        system.debug('von1 >>>>' + OddFreqIssueDisc );
                    }
                }
                else{
                    if (IsStopDate == true) {
                    OddFreqIssueDisc = OddFreqIssueDisc + Decimal.valueOf(pubWrapperDiscount.odd_freq_copies);
                    }
                    //OddFreqIssueDisc = Decimal.valueOf(pubWrapperDiscount.odd_freq_copies);
                    system.debug('von2 >>>>' + OddFreqIssueDisc );
                }
                    System.debug('WEEKDAY ISSUE -Von:' + weekdayIssueDisc);
                    System.debug('SATURDAY ISSUE -Von:' + SaturdayIssueDisc);
                    System.debug('SUNDAY ISSUE -Von:' + SundayIssueDisc);
                    System.debug('OddFreqIssueDisc -Von:' + OddFreqIssueDisc);
           } 
        }*/
        //END: D- 2553 04/9/2015 Added by Kristine Campang
        
        //START: D-2553 and D-2560 VPernicia 4/16/15
        public static void GetIssueCalculation(Publication__c pubRec, date StopSubDate, date EndSubDate, date EffectivityDate) {
         
            Date DateFrom;
            Date DateTo;
            boolean isWeekDay=true;
            
            Date EndOfMonthStopDate = getLastDayOfTheMonth(StopSubDate);
            Date StartOfMonthStopDate = date.newinstance(StopSubDate.year(), StopSubDate.month(), 1);
        
            Date EndOfMonthEndSubDate = getLastDayOfTheMonth(EndSubDate);
            Date StartOfMonthEndSubDate = date.newinstance(EndSubDate.year(), EndSubDate.month(), 1);
          
            Date StartDateDiff;
            Date EndDateDiff;
            
            
            Integer isEntry = 0;
          
            For (integer x=0; x<=1; x++) {
                
                isWeekDay = false;
                If (x==0) {
                    
                    if (StopSubDate >= EffectivityDate) {
                    
                        If (StopSubDate != StartOfMonthStopDate ) {
                            DateFrom = StopSubDate;
                            DateTo = EndOfMonthStopDate;
                            isWeekDay = true;
                            
                            StartDateDiff = EndOfMonthStopDate+1;
                            
                            system.debug('isWeekdayStopsub');
                        } else {
                        
                            StartDateDiff = StopSubDate;
                        }
                    }
                    
                    if (StopSubDate.month() == EndSubDate.month() && StopSubDate.year() == EndSubDate.year()) {
                    
                        If (StopSubDate != StartOfMonthStopDate ) {
                            
                            DateFrom = StopSubDate;
                            DateTo = EndSubDate;
                            isWeekDay = true;
                            isEntry = 1;
                            system.debug('isWeekdayStopsub1');
                        }
                    }
                
                } else {
                    If (EndSubDate > EffectivityDate && isEntry == 0) {
                        If (EndSubDate != EndOfMonthEndSubDate ) {
                            DateFrom = StartOfMonthEndSubDate;
                            DateTo = EndSubDate;
                            isWeekDay = true;
                            EndDateDiff = StartOfMonthEndSubDate-1;
                            
                            system.debug('isWeekdayEndsub');
                        } else {
                        
                            EndDateDiff = EndSubDate;
                        }
                        
                        if (StopSubDate.month() == EndSubDate.month() && StopSubDate.year() == EndSubDate.year()) {
                        
                            if (EndSubDate != EndOfMonthEndSubDate && isEntry == 0) {
                        
                                DateFrom = StopSubDate;
                                DateTo = EndSubDate;
                                isWeekDay = true;
                            }
                        }
                    }
                }
               
                if (isMagazine) {
                
                    if (EffectivityDate > StopSubDate) {
                    
                        DateFrom = EffectivityDate;
                        DateTo = EndSubDate;
                    } else {
                    
                        DateFrom = StopSubDate;
                        DateTo = EndSubDate;
                    }
                    
                    isWeekDay = true;
                }
           
                If (isWeekDay == true) {
                   
                    UsageHelper.initialize();
                    PublicationIssueWrapper pubWrapperDiscount = UsageHelper.IssueCalculation(pubRec.Publication_Code__c, DateFrom, DateTo, zuoSubscrpt, Integer.valueOf(zuoSubscrpt.Number_of_Copies__c));
                    System.debug('Date Range -Von:' + DateFrom + ' to ' + DateTo + 'pubRec >>>' + pubRec.Publication_Code__c + '>>>' + Integer.valueOf(zuoSubscrpt.Number_of_Copies__c));
                    weekdayIssueDisc = weekdayIssueDisc + Decimal.valueOf(pubWrapperDiscount.weekday_no_of_copies);
                    SaturdayIssueDisc = SaturdayIssueDisc + Decimal.valueOf(pubWrapperDiscount.sat_no_of_copies);
                    SundayIssueDisc = SundayIssueDisc + Decimal.valueOf(pubWrapperDiscount.sun_no_of_copies);
                    
                    if (isMagazine) {
                        OddFreqIssueDisc = Decimal.valueOf(pubWrapperDiscount.odd_freq_copies);
                    } else {
                        OddFreqIssueDisc = OddFreqIssueDisc + Decimal.valueOf(pubWrapperDiscount.odd_freq_copies);
                    }
                }
            }
            
            try {
                
                if (StopSubDate >= EffectivityDate) {
                
                    numMonth = (StartDateDiff).monthsBetween(EndDateDiff) + 1;
                    system.debug('StartDateDiff ' + StartDateDiff );
                    system.debug('EndDateDiff ' + EndDateDiff );
                } else {
                    numMonth = (EffectivityDate).monthsBetween(EndDateDiff) + 1;
                    system.debug('StartDateDiff e' + EffectivityDate);
                    system.debug('EndDateDiff e' + (EndDateDiff));
                }
                
                if(zuoSubscrpt.Billing_Type__c =='Recurring Prepaid') {
                    
                    if (StopSubDate.month() == EndSubDate.month() && StopSubDate.year() == EndSubDate.year()) {
                        if (StopSubDate == StartOfMonthStopDate && EndSubDate == EndOfMonthEndSubDate) {
                            numMonth = 1;
                        } else {
                            numMonth = 0;
                        }
                       
                    }
                }
                
                system.debug('StartDateDiff>>>');
            } catch (exception e) {
                
                numMonth = 0;//(EffectivityDate).monthsBetween(StartOfMonthEndSubDate-1) + 1;
                system.debug('EffectivityDate>>>');
            }
            
            System.debug('numMonth -Von' + numMonth );
            
            System.debug('WEEKDAY ISSUE -Von:' + weekdayIssueDisc);
            System.debug('SATURDAY ISSUE -Von:' + SaturdayIssueDisc);
            System.debug('SUNDAY ISSUE -Von:' + SundayIssueDisc);
            System.debug('OddFreqIssueDisc -Von:' + OddFreqIssueDisc);
            
        }
        //END: D-2553 and D-2560 VPernicia 4/16/15
        
        //START: D- 2553 04/9/2015 Added by Kristine Campang - modified code for all in one and discount
        public static Decimal computeDiscount(List<Publication__c> publicationList, Date strDate, Date enDate){    
            
            integer Counter= 0;
            boolean isWeekdays= false;
            Date DateFrom;
            Date DateTo;
            
            System.debug('Pumasok:' + totalDiscountDateMap);
            for(Zuora__SubscriptionProductCharge__c spcDiscountId : zuoSubProdChargListDisc){
                Counter++;
                
                weekdayIssueDisc = 0;
                SaturdayIssueDisc = 0;
                SundayIssueDisc = 0;
                OddFreqIssueDisc = 0;
                numMonth = 0;
                
                List<Date> discountRange = totalDiscountDateMap.get(spcDiscountId.id);
                
                System.debug('DISCOUNT RANGE:' + discountRange);
            //START: D-2119 03/11/2015 Added by Kristine Campang - edited variable instance             
                totalDiscountPerPub = 0.00;
                
                for(Publication__c pubRec : publicationList){
                        
                        isWeekdays = false;
                        OddFreqIssueDisc = 0.00;
                        weekDayDiscount = 0.00;
                        saturdayDiscount = 0.00;
                        sundayDiscount = 0.00;
                        magazineDiscount = 0.00;
                        onlineDiscount = 0.00;
                        AIOTabletDiscount = 0.00;
                        AIOSmartphoneDiscount = 0.00;
                        AIOOnlineDiscount = 0.00;
                        monthDiscount = 0.00;
                        copyMonth = 0.00;
                        
                        List<zqu__ProductRatePlanCharge__c> prodRatePlanChargeDiscountList = new List<zqu__ProductRatePlanCharge__c>();
                        prodRatePlanChargeDiscountList = mapPubCodeToRatePlanCharge.get(pubRec.Publication_Code__c);
                        
                        if(pubRec.Platform_Type__c == 'Online' || pubRec.Platform_Type__c == 'Smartphone' || pubRec.Platform_Type__c == 'Tablet'){
                            mapPRC_UOM_Price = getCopyPrice(prodRatePlanChargeDiscountList, pubRec.Publication_Code__c, pubRec.Platform_Type__c, null); 
                        }
                        else if(pubRec.Platform_Type__c == 'All in One (AIO)'){
                            System.debug('aio entered');
                            System.debug('ONLINE PUB NAME' + pubRec.Name);
                            System.debug('BOOL' + string.valueOf((pubRec.Name).contains('ONLINE')));
                            //START:UD-0784 5/13/15 Added by Manolo Valena - Changed condition to compare the value of the new picklist.
                            if(pubRec.Publication_Platform_AIO__c == GlobalVariableClass.ONLINE){
                                System.debug('online entered');
                                mapPRC_UOM_Price = getCopyPrice(prodRatePlanChargeDiscountList, pubRec.Publication_Code__c, pubRec.Platform_Type__c, 'Online');
                                System.debug('online' + mapPRC_UOM_Price);
                            }
                            else if(pubRec.Publication_Platform_AIO__c == GlobalVariableClass.SMARTPHONE){
                                System.debug('smartphone entered');
                                mapPRC_UOM_Price = getCopyPrice(prodRatePlanChargeDiscountList, pubRec.Publication_Code__c, pubRec.Platform_Type__c, 'Smartphon');
                                System.debug('smartphone' + mapPRC_UOM_Price);
                            }
                            else if(pubRec.Publication_Platform_AIO__c == GlobalVariableClass.TABLET){
                                System.debug('tablet entered');
                                mapPRC_UOM_Price = getCopyPrice(prodRatePlanChargeDiscountList, pubRec.Publication_Code__c, pubRec.Platform_Type__c, 'Tablet');
                                System.debug('tablet' + mapPRC_UOM_Price);
                            }
                            //END:UD-0784 5/13/15 Added by Manolo Valena
                        }
                        else{
                            mapPRC_UOM_Price = getCopyPrice(prodRatePlanChargeDiscountList, pubRec.Publication_Code__c, null, null); 
                        }
                        
                        GetIssueCalculation(pubRec, strDate, enDate, spcDiscountId.Zuora__EffectiveStartDate__c);
                        
                        mapSPCDiscToPrice = new Map<Id, Decimal>();         
                        for(Zuora__SubscriptionProductCharge__c spcDisc : zSPCDiscount){        
                            mapSPCDiscToPrice.put(spcDisc.Id, spcDisc.Zuora__Price__c);         
                        } 
                        
                        system.debug('prodRatePlanChargeDiscountList' + prodRatePlanChargeDiscountList.size());
                        for(zqu__ProductRatePlanCharge__c prodRatePlanChrg : prodRatePlanChargeDiscountList){
                            System.debug('WEEKDAY' + weekdayIssue);
                            System.debug('MAP PRICE' + mapPRC_UOM_Price);
                            System.debug('<<<<<<<<<' + mapPRC_UOM_Price.get(prodRatePlanChrg.Id));                  
                            System.debug('MAP PRICE' + mapPRC_UOM_Price);
                            System.debug('zSPCDiscount' + (mapSPCDiscToPrice.get(spcDiscountId.id)/100));
                            System.debug('weekdayIssueDisc --Von' + weekdayIssueDisc);
                            System.debug('SaturdayIssueDisc --Von' + SaturdayIssueDisc);
                            System.debug('SundayIssueDisc --Von' + SundayIssueDisc);
                            System.debug('OddFreqIssueDisc --Von' + OddFreqIssueDisc);
                            //START 12-Sept -2015 UD-2685 S.Puli - to avoid null pointer
                            if(mapPRC_UOM_Price.containsKey(prodRatePlanChrg.Id)){
                            //END 12-Sept -2015 UD-2685 S.Puli - to avoid null pointer
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('Weekday')){
                                copyPriceWeekday = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Weekday') !=null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Weekday') : 0);
                                weekDayDiscount = (Math.abs(copyPriceWeekday) * (mapSPCDiscToPrice.get(spcDiscountId.id)/100)) * weekdayIssueDisc;
                                System.debug('WEEKDAY ISSUE' + weekdayIssue);
                                System.debug('DISCOUNT VALUE WEEKDAY' + mapSPCDiscToPrice.get(spcDiscountId.id)/100);
                                System.debug('WEEKDAY PRICE:' + copyPriceWeekday);
                                System.debug('WEEKDAY DISCOUNT:' + weekDayDiscount);
                            }
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('Sat')){
                                copyPriceSaturday = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Sat') !=null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Sat') : 0);
                                saturdayDiscount = (Math.abs(copyPriceSaturday) * (mapSPCDiscToPrice.get(spcDiscountId.id)/100)) * SaturdayIssueDisc;
                                System.debug('SAT ISSUE' + SaturdayIssue);
                                System.debug('SATURDAY PRICE:' + copyPriceSaturday);
                                System.debug('SATURDAY DISCOUNT:' + saturdayDiscount);
                            }
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('Sun')){
                                copyPriceSunday = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Sun') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Sun') : 0);
                                sundayDiscount = (Math.abs(copyPriceSunday) * (mapSPCDiscToPrice.get(spcDiscountId.id)/100)) * SundayIssueDisc;
                                System.debug('SUN ISSUE' + SundayIssue);
                                System.debug('SUNDAY PRICE:' + copyPriceSunday);
                                System.debug('SUNDAY DISCOUNT:' + sundayDiscount);
                            }
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('Magazine')){
                                copyPriceMagazine = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Magazine') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Magazine') : 0);
                                System.debug('copy Magazine' + copyPriceMagazine);
                                System.debug('tine' + String.valueOf((Math.abs(copyPriceMagazine) * (mapSPCDiscToPrice.get(spcDiscountId.id)/100))));
                                System.debug('count' + OddFreqIssueDisc);
                                magazineDiscount = (Math.abs(copyPriceMagazine) * (mapSPCDiscToPrice.get(spcDiscountId.id)/100)) * OddFreqIssueDisc;
                                System.debug('MAGAZINE DISCOUNT' + magazineDiscount);
                            }
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('Online')){
                                copyPriceOnline = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Online') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Online') : 0);
                                onlineDiscount = (Math.abs(copyPriceOnline) * (mapSPCDiscToPrice.get(spcDiscountId.id)/100)) * OddFreqIssueDisc;
                                System.debug('oddFreqDisc' + OddFreqIssueDisc);
                                System.debug('copyPriceOnline' + copyPriceOnline);
                                System.debug('ONLINE DISCOUNT' + onlineDiscount + ' Percentage: ' + mapSPCDiscToPrice.get(spcDiscountId.id));
                            }
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('Smartphone')){
                                copyPriceOnline = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Smartphone') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Smartphone') : 0);
                                onlineDiscount = (Math.abs(copyPriceOnline) * (mapSPCDiscToPrice.get(spcDiscountId.id)/100)) * OddFreqIssueDisc;
                                System.debug('ONLINE DISCOUNT SMARTPHONE' + onlineDiscount);
                            }
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('Tablet')){
                                copyPriceOnline = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Tablet') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Tablet') : 0);
                                onlineDiscount = (Math.abs(copyPriceOnline) * (mapSPCDiscToPrice.get(spcDiscountId.id)/100)) * OddFreqIssueDisc;
                                System.debug('ONLINE DISCOUNT TABLET' + onlineDiscount);
                            }
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('AIO Tablet')){
                                copyPriceOnline = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('AIO Tablet') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('AIO Tablet') : 0);
                                AIOTabletDiscount = (Math.abs(copyPriceOnline) * (mapSPCDiscToPrice.get(spcDiscountId.id)/100)) * OddFreqIssueDisc;
                                System.debug('AIO DISCOUNT TABLET' + AIOTabletDiscount + '>>' + OddFreqIssueDisc);
                            }
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('AIO Online')){
                                copyPriceOnline = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('AIO Online') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('AIO Online') : 0);
                                AIOOnlineDiscount = (Math.abs(copyPriceOnline) * (mapSPCDiscToPrice.get(spcDiscountId.id)/100)) * OddFreqIssueDisc;
                                System.debug('AIO DISCOUNT ONLINE' + AIOOnlineDiscount);
                            }
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('AIO Smartphon')){
                                copyPriceOnline = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('AIO Smartphon') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('AIO Smartphon') : 0);
                                AIOSmartphoneDiscount = (Math.abs(copyPriceOnline) * (mapSPCDiscToPrice.get(spcDiscountId.id)/100)) * OddFreqIssueDisc;
                                System.debug('AIO DISCOUNT SMARTPHONE' + AIOSmartphoneDiscount);
                            }
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('AIO Smartphone')){
                                copyPriceOnline = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('AIO Smartphone') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('AIO Smartphone') : 0);
                                AIOSmartphoneDiscount = (Math.abs(copyPriceOnline) * (mapSPCDiscToPrice.get(spcDiscountId.id)/100)) * OddFreqIssueDisc;
                                System.debug('AIO DISCOUNT SMARTPHONE' + AIOSmartphoneDiscount);
                            }
                            if(mapPRC_UOM_Price.get(prodRatePlanChrg.Id).containsKey('Month')){
                                System.debug('MONTH DISCOUNT Before' + monthDiscount + ' Copy Month:' + Math.abs(copyMonth) + ' SPC Discount:' + mapSPCDiscToPrice.get(spcDiscountId.id) + ' numMonth: ' + numMonth);
                                copyMonth = (mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Month') != null ? mapPRC_UOM_Price.get(prodRatePlanChrg.Id).get('Month') : 0);
                                monthDiscount = (Math.abs(copyMonth) * (mapSPCDiscToPrice.get(spcDiscountId.id)/100)) * numMonth;
                                System.debug('MONTH DISCOUNT' + monthDiscount + ' Copy Month:' + Math.abs(copyMonth) + ' SPC Discount:' + mapSPCDiscToPrice.get(spcDiscountId.id));
                                System.debug('monthDiscount' + monthDiscount);
                            }
                            }//START/END UD-2685 12-Sept -2015 S.Puli - to avoid null pointer
                         
                        }
                        totalDiscountPerPub += weekDayDiscount + saturdayDiscount + sundayDiscount + magazineDiscount + onlineDiscount + AIOTabletDiscount + AIOOnlineDiscount + AIOSmartphoneDiscount + monthDiscount;
                        System.debug('TOTAL DISCOUNT PER PUB' + totalDiscountPerPub + ':weekday' + weekDayDiscount + ':sat' + saturdayDiscount + ':sun' + sundayDiscount + 'online' + onlineDiscount + 'aio smartphone' + AIOSmartphoneDiscount + 'aio tablet' + AIOTabletDiscount + 'aio online' + AIOOnlineDiscount + 'monthly' + monthDiscount);
                        System.debug('mapPRC_UOM_Price:' + mapPRC_UOM_Price);
                    }
                    totalDiscount += totalDiscountPerPub;
                    System.debug('TOTAL DISCOUNT:' + totalDiscount + ':total Discount PER PUB:' + totalDiscountPerPub);
            //END: D-2119 03/11/2015 Added by Kristine Campang
            }
            return totalDiscount;
        }
        //END: D-0077 03/09/2015 Added by Kristine Campang
        //END: D- 2553 04/9/2015 Added by Kristine Campang - added variables for AIO
        
        //START: UD-760 04/27/2015 Added by Kristine Campang - added method for retrieval of publication valid for monthly Refund
        public static List<Publication__c> retrieveValidPublications(List<Publication__c> publicationList, Date stpDate){
            
            List<Publication__c> pubListMonthly = new List<Publication__c>();
            for(Publication__c publicationRec : publicationList){
                UsageHelper.initialize();
                PublicationIssueWrapper pubWrapperMonthly = UsageHelper.IssueCalculation(publicationRec.Publication_Code__c, stpDate, endDate, zuoSubscrpt, Integer.valueOf(zuoSubscrpt.Number_of_Copies__c));
                if(pubWrapperMonthly.weekday_no_of_copies > 0 || pubWrapperMonthly.sat_no_of_copies > 0 || pubWrapperMonthly.sun_no_of_copies > 0 || pubWrapperMonthly.odd_freq_copies > 0){
                    pubListMonthly.add(publicationRec);
                }
            }
            
            return pubListMonthly;
        }

    }