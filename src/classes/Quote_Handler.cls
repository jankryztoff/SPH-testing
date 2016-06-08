/*
 * History: 12/14/14 Product Catalogue  Kevin Evasco - Updated to include proration charges
 * History: 01/06/15 Wenjun: Major Changes to Code Structures to fix Code Bugs and perform code optimization
 *  - Fix 1: Convert Map<Id, Order__c> mOrder to Order__c order as there is only ONE order passed in
 *  - Fix 2: Remove Set<ID> sAccountId and use ID accountId instead
 *  - Fix 3: Remove Map<Id, list<Order_Line_Item__c>> mOrderId_OrderLI as there is only ONE order
 *  - Fix 4: Remove Map<Id, list<zqu__ProductRatePlanChargeTier__c>> mProdRatePlanCharge_ProdRatePlanChargeTier as it is not in use
 *  - Fix 5: Wrong code logic to group a list of child records by certain common keys. The current code assumes 
 *           the list of records are ordered by the key in sequence. However, most of time the records are not grouped 
 *          in sequence which will result in wrong grouping being created
 *          ^ Line 198 - 228: Order Line Item Gifts by Line Item
 *          ^ Line 260 - 292: Package Item grouping by Package
 *          ^ Line 458 - 488: Product Rate Plan Charges by Product Rate Plan ID
 *          ^ Line 513 - 542: Rate Plan Charge Tiers by Rate Plan Charge
 *  - Fix 6: Remove unused variable Integer x - Original Line 563
 *  - Fix 7: Remove set<Id> sDeliveryRatePlanId - Original Line 369
 *  - Fix 8: Remove unused variable map<string, Id> mDelRP_RPID - Original Line 370
 *  - Fix 9: Use "RecordType.DeveloperName" instead of "RecordType.Name" - Original Line 260 and other referring places
 *  - Fix 10: Rate Plan Query only fetch active records by adding zqu__Deleted__c = false 
 *  - Fix 11: Other minor changes on Naming Convention / Code Formatting
 * History: 01/07/15 D-1592 Wenjun: Add support for Postage Charges
 * History: 01/22/15 D-1689 D-1670 D-1729 Wenjun
 *  - Fix 1: Proration Charges Wrong rate plan code
 *  - Fix 2: Quote Charge Group Not being created
 *  - Fix 3: Delivery Charge Rate Plan, Quote & Quote Charge
 *  - Fix 4: Quote Charges will be added to Quote when creating Charge Group. Rewrite the current Quote Charge handling codes
 *  - Fix 5: Add Quote Charges for Tiered Discount, Single Discount and Extension Discount
 *  - Fix 6: Overwrite Delivery Quote Charge to set User Input Amount
 *  - Fix 7: Overwrite Publication Quote Charge to set Quantity
 *  - Fix 8: Overwrite Discount Quote Charge to set Effective Start Date and Duration
 *  - Fix 9: Code Optimization - Removing unused codes
*/
public class Quote_Handler {
    
    // Start UD-0460 11-03-2015 MGaelo added by JohnD
    private static final string ORDER_STATUS_PENDING = 'Pending';
    private static final string DELIVERY_QUOTE_NAME = 'Delivery Charge';
    // End UD-0460 11-03-2015 MGaelo added by JohnD
    private static final string NON_CHARGEABLE = 'NonChargeable';   // Start/End UD-2210 22Aug15 JohnD
    
    public static String sAirline = ConstantsSLB.getKeyId('AddAirline');
    public static String sOverseas = ConstantsSLB.getKeyId('AddOverseas');
    public static String sLocal = ConstantsSLB.getKeyId('AddLocal');
    public static String sInternal = ConstantsSLB.getKeyId('AddInternal');
    public static String INVOICE_PROC_OPTION = ConstantsSLB.getKeyId('QuoteInvoiceProcessingSubscription');
    public static String TERM_EVER_GREEN = ConstantsSLB.getKeyId('SubTermTypeEvergreen');
    public static String CURRENCY_SGD = ConstantsSLB.getKeyId('CurrencySGD');
    public static String SUB_TYPE_PUB = ConstantsSLB.getKeyId('SubTypePub');
    public static String RT_ID_BASE_PROD = ConstantsSLB.getKeyId('Package Item_Base Product');
    public static String RT_ID_BUNDLE_PROD = ConstantsSLB.getKeyId('Package Item_Bundle Product');
    public static String RT_ID_BUNDLE_DISC = ConstantsSLB.getKeyId('Package Item_Bundle Discount');
    public static String RT_ID_DISC = ConstantsSLB.getKeyId('Package Item_Discount');
    public static String RT_ID_EXT_PROD = ConstantsSLB.getKeyId('Package Item_Extension Product');
    public static String RT_ID_EXT_DISC = ConstantsSLB.getKeyId('Package Item_Extension Discount');
    //START D-1837 Wenjun 09/02/15 : Subscription Type for Gift
    public static String SUB_TYPE_GIFT = ConstantsSLB.getKeyId('SubTypeGift');
    //END D-1837 Wenjun 09/02/15
    public static List<Id> lQuoteIds { get; set;} 
    
    //Start UD-678 VPernicia/MGatchalian 3/30/2015
    list<string> lstQuoteRatePlan = new list<string>();
    //End UD-678 VPernicia/MGatchalian 3/30/2015
    
    public static List<zqu__QuoteCharge__c> lQuoteCharges { get; set;}      // MBG 
    public static String paymentMode { get; set; }                          // Cash, Check, Credit Card, Other
    public static String paymentModeOther { get; set;}                      // Cash, Check, Credit Card, Other
    public static String sDeliveryChargeType {get; set;} 
    public static Boolean bCreateNewBillingAccount {get; set;} 
    public static Boolean bCreateDeliverySubscription {get; set;}
    public static Boolean bPayDeliveryChargeNow {get; set;}
    public static ID existingDeliverySubscriptionId {get; set;}
    public static ID sfBillingAccount {get; set;}
    public static String zBillingAccount {get; set;}
    public static Decimal subscriberCharge {get; set;}
    public static Decimal vendorCredit {get; set;}
    public static Boolean bCharity {get; set;}
    public static ID accountId {get; set;}
    public static Decimal deliveryFPSubscriptionUsage {get; set;}
    public static String ccPaymentMethodID {get; set;}  
    
    public static Set<Id> productIdSet = new Set<Id>();
    public static Set<Id> prorationIdSet = new Set<Id>();
    public static Set<Id> sProductRatePlanChargeId = new Set<Id>();
    public static String recipientAddId {get; set;}
    public static String recipientAddUniqueId {get; set;}
    public static String recipientAddressType {get; set;}
    public static Boolean bHasPostageCharge {get; set;}
    public static zqu__ProductRatePlan__c ratePlanPostage {get; set;}
    public static Boolean bHasVendorDelivery {get; set;}
    public static zqu__ProductRatePlan__c ratePlanDelivery {get; set;}
    
    //START UD-3178 11/18/2015 Added by J.Sarion - Set ZProduct's Product Code
    public static Set<String> productCodesWithNoDelSet = new Set<String>();
    public static List<Product_Code__c> mcs = Product_Code__c.getall().values();
    public static Set<String> prodCodeSet = new Set<String>();
    public static Map<Id, Id> packageIdToOliIdMap = new Map<Id, Id>();
    public static Map<Id, String> oliIdToProductCodeMap = new Map<Id, String>();
    //END UD-3178 11/18/2015 Added by J.Sarion - Set ZProduct's Product Code
    
    map<id, string> productId_packageItemFrequency = new map<id, string>(); // Start/End UD-2210 21Aug15
    //START UD-2175 30-July-2015 Added by S.Puli - add ExceptionLogger function
    list<exception> exceptionList = new list<exception>(); // declare this at the outermost within your class
    //END UD-2175 30-July-2015 Added by S.Puli
    
    public void Create_Quotes(Order__c orderObj,String origin, Id OliID)
    {
        //START UD-2175 30-July-2015 Added by S.Puli - add ExceptionLogger function
        try{
        //END UD-2175 30-July-2015 Added by S.Puli - add ExceptionLogger function
            List<ID> lPackageID = new list<ID>();
            List<Order_Line_Item__c> mOrderLineItemsholderList = new List<Order_Line_Item__c>();
            Map<Id, list<Package_Item__c>> mPackageToPackageItems = new Map<Id, list<Package_Item__c>>();
            Map<Id,Id> mapPackItemToProdId = new Map<Id,Id>();
            Id giftRatePlanId;
            Map<Id, List<Order_Line_Item_Gift__c>> mOrderLineItemToGifts = new Map<Id, List<Order_Line_Item_Gift__c>>();
            List<zqu__Quote__c> lstZQuotes = new List<zqu__Quote__c>();
            Map<Id, List<zqu.zChargeGroup>> mapQuoteIdToChargeGroups = new Map<Id, List<zqu.zChargeGroup>>();
            Map<Id, Set<Id>> mapProductIdToRatePlanIds = new Map<Id, Set<Id>>();
            Map<Id, Id> mapPackItemToQuoteId = new Map<Id, Id>();
            zqu__ProductRatePlan__c deliveryRatePlan_Internal;
            zqu__ProductRatePlan__c deliveryRatePlan_HDB;
            zqu__ProductRatePlan__c deliveryRatePlan_Apartment;
            zqu__ProductRatePlan__c deliveryRatePlan_Landed;
            String sPackageType;
            String defaultDeliveryChargeType; //For determine the Delivery Rate Plan
            Integer intTerm;
            lQuoteCharges = new List<zqu__QuoteCharge__c>();
            lQuoteIds = new List<Id>();
            Boolean isPrint = false; // For Delviery Charge Checking
            Map<String, DiscountChargeWrapper> mapDiscountCharges = new Map<String, DiscountChargeWrapper>();
            //START D-1970 Wenjun 28/01/15 : Postage Amount for each Quote
            Map<Id, Decimal> mapQuoteIdToPostageAmt = new Map<Id, Decimal>();
            //END D-1970 Wenjun 28/01/15
            //START D-1837 Wenjun 09/02/15 : Gift Charge Detail for each Quote
            Map<String, GiftChargeWrapper> mapQuoteIdToGiftCharges = new Map<String, GiftChargeWrapper>();
            //END D-1837 Wenjun 09/02/15
            //START D-2992 Wenjun 21/05/15 : Discount Percentage for Quote Charge
            Set<ID> setDiscRatePlanIDs = new Set<ID>();
            Map<ID, Decimal> mapRatePlanIDToDisc = new Map<Id, Decimal>();
            Map<Id, Decimal> mapQuoteIdToDisc = new Map<Id, Decimal>();
            //END D-2992 Wenjun 21/05/15
            //START UD-2228 8/14/2015 Added By C. Lin - Map Product Rate Plan to Subscription Frequency
            Map<Id, String> pRatePlanToSubFreqMap = new Map<Id, String>();
            //END UD-2228 8/14/2015 Added By C. Lin
            //Start D-1943 D-1945 AddedBy FrancisBenzon 1/26/2015 : To catch null pointer. If Both conditions for bHasVendorDelivery was not satisfied.
            bHasVendorDelivery = FALSE;   
            //End D-1943 D-1945 AddedBy FrancisBenzon 1/26/2015 : To catch null pointer. If Both conditions for bHasVendorDelivery was not satisfied.  
            //Start D-1847 01/28/15 Added by A Banaag - set to true
            bCreateDeliverySubscription = true;
            //End D-1847 01/28/15 Added by A Banaag - set to true
            // START: Code Review Implementation 2/17/2015 JAlejandro    
            Map<Id, Order_Line_Item__c> mOrderLineItems = new Map<Id, Order_Line_Item__c>();
            
            //START UD-3178 11/19/2015 Added by J.Sarion - Set Product Code as basis for creation of Del Sub
            for(Product_Code__c prodCode :mcs){
                prodCodeSet.add(prodCode.Product_Code__c);
            }
            //END UD-3178 11/19/2015 Added by J.Sarion - Set Product Code as basis for creation of Del Sub
            
            if (orderObj.Id != null)
            {        //Start D-2390 03/02/15 ABanaag - added Main_Package_ID__r.Billing_Type__c to query
                    // Start UD-1324 26May15 JohnD - added Total_Postage_Charge__c field
                    //START UD-2951 12/10/2015 Gdelrosario - added Order__r.Other_Payment_Mode__c, Order__r.Payment_Mode__c,
                    mOrderLineItems.putAll([Select Term_Length__c, Start_Date__c, Qty__c, 
                     Postage_Charge__c, Order__r.Id, Order__c, Name, Main_Package_Sub_Type__c, 
                     Main_Package_ID__r.Package_Sub_Type__c, Main_Package_ID__r.Package_Type__c, 
                     Main_Package_ID__r.Name, Main_Package_ID__c, Id, End_Date__c, Case__c, 
                     Auto_Renew__c, Addon_Package__r.Package_Sub_Type__c, Addon_Package__r.Name, 
                     Addon_Package__c, Addon_Package__r.Package_Type__c, Main_Package_Billing_Type__c,
                     Add_On_Package_Product_Sub_Type__c, Add_On_Package_Product_Platform__c,
                     Main_Package_ID__r.Subscription_Type__c,Main_Package_ID__r.Subscription_Period__c, 
                     Addon_Package__r.Subscription_Period__c,Charity__c, Promotion_ID__c, 
                     Main_Package_Product_Sub_Type__c, Main_Package_Product_Platform__c, 
                     Order__r.Other_Payment_Mode__c,
                     Order__r.Payment_Mode__c,
                     Contract_End_Date__c, New_Contract_Period__c, Promotion_Contract_Period__c,
                     Delivered_By__c, Main_Package_Frequency__c,Urgent__c, Generate_Invoice__c,
                     Suppress_Vendor_Start_notice__c, Supressed_Acknowledgement_Letter__c, Total_Postage_Charge__c, 
                     Suppress_Renewal_and_Reminder_Letter__c, Vendor_Mailing_Agent__c, Vendor_Conversion__c, Main_Package_ID__r.Billing_Type__c,
                     //START: UD-3307 11/25/15 Added by Manolo Valena
                     Vendor_Subscription_ID__c, PO_Number__c FROM Order_Line_Item__c WHERE Order__c =: orderObj.Id and id =:OliID]);
                     //END: UD-3307 11/25/15 Added by Manolo Valena
                  //END UD-2951 12/10/2015 Gdelrosario - added Order__r.Other_Payment_Mode__c, Order__r.Payment_Mode__c,
                     // End UD-1324 26May15 JohnD - added Total_Postage_Charge__c field
                     //End D-2390 03/02/15 ABanaag - added Main_Package_ID__r.Billing_Type__c to query

                    // END: Code Review Implementation 2/17/2015 JAlejandro
                    system.debug('==============> Order Line Items: ' + mOrderLineItems);
                    //Start/End D-1610 Addedby FrancisBenzon 1/26/2015 : Added Debt_Management_Treatment__c to order query
            
                    orderObj = [SELECT Id, Name, Account__c, Account__r.Id, Billing_Account__c, Recipient_Contact__c,
                                Billing_Account_External_ID__c, Payment_Mode__c, Other_Payment_Mode__c, Payment_Method_ID__c,
                                Billing_Contact__c, Billing_Contact__r.Id, Recipient_Contact__r.Address_Unique_Id__c,
                                Billing_Account_Creation_Mode__c , Recipient_Contact__r.Address__r.Address_Unique_ID__c,
                                FP_Del_Usage__c , Recipient_Type__c, Recipient_Address__c, Recipient_Add_Type__c,
                                Acquisition_Type__c, Cost_Centre__c,Delivery_Charge_Type__c, Subscriber_Charge__c, Vendor_Credit__c,
                                PO_Number__c, Delivery_Start_Date__c, Sponsor__c, Total_Monthly_Postage_Charge__c, Debt_Management_Treatment__c   
                                FROM Order__c WHERE Id =: orderObj.Id];
             }//Code Review Implementation 2/17/2015 JAlejandro                                                                            
            //Retrive infromation from Order Detail
            accountId = orderObj.Account__c;
            paymentMode = orderObj.Payment_Mode__c;
            paymentModeOther = orderObj.Other_Payment_Mode__c;
            sDeliveryChargeType = orderObj.Delivery_Charge_Type__c;
            deliveryFPSubscriptionUsage = orderObj.FP_Del_Usage__c;
            ccPaymentMethodID = orderObj.Payment_Method_ID__c;
            recipientAddId = orderObj.Recipient_Contact__r.Address_Unique_Id__c;
            recipientAddUniqueId = orderObj.Recipient_Contact__r.Address__r.Address_Unique_ID__c;

            //Check if there is Postage Charge Applied
            //START UD-2951 Gdelrosario 12/10/2015 : added the query to get postage for freelist
            bHasPostageCharge  = (orderObj.Total_Monthly_Postage_Charge__c > 0 || ( orderObj.Payment_Mode__c == 'Other' && orderObj.Other_Payment_Mode__c == 'Freelist' && mOrderLineItems.get(OliID).Delivered_By__c =='Mailing Agent')) ? true : false;
            //END UD-2951 Gdelrosario 12/10/2015 : added the query to get postage for freelist
            defaultDeliveryChargeType = ConstantsSLB.getDefaultDeliveryChargeType(orderObj.Recipient_Add_Type__c);
            
            System.debug('BILLING ACCOUNT CREATION MODE' + orderObj.Billing_Account_Creation_Mode__c);
            
            if(orderObj.Billing_Account_Creation_Mode__c == 'Create New Billing Account'){
                System.debug('CREATE NEW BILLING ACCOUNT');
                bCreateNewBillingAccount = true;
            }else{
                System.debug('DO NOT CREATE NEW BILLING ACCOUNT');
                bCreateNewBillingAccount = false;
                sfBillingAccount = orderObj.Billing_Account__c;
                zBillingAccount = orderObj.Billing_Account_External_ID__c;
            }

            /*---------------------------Get All Order Line Items GIFTS --------------------------------------*/
            //START D-1837 Wenjun 09/02/15 : 
           // START: Code Review Implementation 2/17/2015 JAlejandro
           if (!mOrderLineItems.keyset().isEmpty())
           { // END: Code Review Implementation 2/17/2015 JAlejandro
               for (Order_Line_Item_Gift__c gift : [SELECT Id, Type__c, Name, Price__c, Order_Line_Item__c, Order_Quantity__c, 
                                                     Promotion_Gift__r.Gift__r.One_Time_Charge__c   
                                                     FROM Order_Line_Item_Gift__c 
                                                     WHERE Order_Line_Item__c in :mOrderLineItems.keyset() AND Type__c = 'Premium'])             
                {
                    ID sID = gift.Order_Line_Item__c;
                    //END D-1837 Wenjun 09/02/15
                    if(mOrderLineItemToGifts.get(sID) == NULL)
                        mOrderLineItemToGifts.put(sID,new List<Order_Line_Item_Gift__c>());
                    mOrderLineItemToGifts.get(sID).add(gift);        
                } 
            }// Code Review Implementation 2/17/2015 JAlejandro
            for(Order_Line_Item__c oli: mOrderLineItems.values()){
                if(oli.Main_Package_ID__c != null)
                    lPackageID.add(oli.Main_Package_ID__c);
                if(oli.Addon_Package__c != null)
                    lPackageID.add(oli.Addon_Package__c);
                if(oli.Delivered_By__c == 'Vendor')
                    bHasVendorDelivery = true;                    
                
                //START UD-3178 11/1/8/2015 Added by J.Sarion - set package Id to Order Line Item Id
                if(oli.Main_Package_ID__c != null)
                    packageIdToOliIdMap.put(oli.Main_Package_ID__c, oli.Id);
                if(oli.Addon_Package__c != null)
                    packageIdToOliIdMap.put(oli.Addon_Package__c, oli.Id);
                //END UD-3178 11/1/8/2015 Added by J.Sarion - set package Id to Order Line Item Id
            }
            
            //START D-2530 19/03/15 Wenjun - Subscription still need to be created for Waived Case
            /*
            if(orderObj.Subscriber_Charge__c == 0) //Delivery Charge Waived
                bHasVendorDelivery = false;
            */
            //END D-2530 19/03/15 Wenjun
            
            /*----------------------- Get All Packages Items Details ---------------------------*/
            //Sort by Base_Package_Item__c to ensure Base Products processed earlier than Discounts
            // START: Code Review Implementation 2/17/2015 JAlejandro
            List<Package_Item__c> lstPItems = new List<Package_Item__c>();
            if (!lPackageID.isEmpty())
            { // END: Code Review Implementation 2/17/2015 JAlejandro
                //START UD-2228 8/14/2015 Added By C. Lin - Add Product_Rate_Plan__r.SubscriptionFrequency__c
                lstPItems = [SELECT Name, Id, Package__r.Id, RecordTypeID, RecordType.DeveloperName, Base_Package_Item__c,
                                            Product_Rate_Plan__c, Is_Newspaper__c, Is_Print__c, Product_Rate_Plan__r.zqu__ZProduct__c, 
                                            Product_Rate_Plan__r.zqu__ZProduct__r.ProductFamily__c, Product_Rate_Plan__r.Product_Code__c,
                                            Effective_Start_Month__c, Duration_in_months__c, Product_Rate_Plan__r.zqu__ZuoraId__c, 
                                            Product_Rate_Plan__r.SubscriptionFrequency__c 
                                            FROM Package_Item__c WHERE Package__c in: lPackageID
                                            Order By Bundle_Item_No__c ASC, Base_Package_Item__c ASC];
                //END UD-2228 8/14/2015 Added By C. Lin
            
                for(Package_Item__c pItem: lstPItems)
                {
                    productIdSet.add(pItem.Product_Rate_Plan__r.zqu__ZProduct__c);
                    mapPackItemToProdId.put(pItem.Id, pItem.Product_Rate_Plan__r.zqu__ZProduct__c);
                    
                    ID sId = pItem.Package__r.Id;
                    if(mPackageToPackageItems.get(sId) == NULL)
                        mPackageToPackageItems.put(sId,new List<Package_Item__c>());
                    mPackageToPackageItems.get(sId).add(pItem);
                    
                    if(pItem.Is_Print__c)
                        isPrint = true;
                    
            //START D-2992 Wenjun 21/05/15 : get Discount Rate Plan ID Set
            if(RT_ID_DISC == pItem.RecordTypeId || RT_ID_BUNDLE_DISC == pItem.RecordTypeId || RT_ID_EXT_DISC == pItem.RecordTypeId)
                setDiscRatePlanIDs.add(pItem.Product_Rate_Plan__c);
            //END D-2992 Wenjun 21/05/15
            
                    //START UD-2228 8/14/2015 Added By C. Lin - Map Product Rate Plan to Subscription Frequency
                    if(pItem.Product_Rate_Plan__c != null && pItem.Product_Rate_Plan__r.SubscriptionFrequency__c != null){
                        pRatePlanToSubFreqMap.put(pItem.Product_Rate_Plan__c, ConstantsSLB.getProductFrequency(pItem.Product_Rate_Plan__r.SubscriptionFrequency__c));
                        // Start UD-2210 21Aug15 JohnD - map product id to package item frequency
                        productId_packageItemFrequency.put(pItem.Product_Rate_Plan__r.zqu__ZProduct__c, pItem.Product_Rate_Plan__r.SubscriptionFrequency__c);
                        // End UD-2210 21Aug15 JohnD - map product id to package item frequency
                    }
                    //END UD-2228 8/14/2015 Added By C. Lin

                    //START UD-3178 11/18/2015 Added by J.Sarion - No Del Sub for selected Product Code
                    if(packageIdToOliIdMap.containsKey(pItem.Package__r.Id)) {
                        if(pItem.Product_Rate_Plan__r.Product_Code__c != null){
                            oliIdToProductCodeMap.put(packageIdToOliIdMap.get(pItem.Package__r.Id), pItem.Product_Rate_Plan__r.Product_Code__c);
                        }
                    }
                    //END UD-3178 11/18/2015 Added by J.Sarion - No Del Sub for selected Product Code
                }
            }// Code Review Implementation 2/17/2015 JAlejandro
            
            /*------------------------------- Get Rate Plans for Proration Charges----------------------------------*/
            if (!productIdSet.isEmpty())
            {
                for(zqu__ProductRatePlan__c ratePlan : [SELECT Id, zqu__ZProduct__c, RatePlanCode__c, SubscriptionFrequency__c, RatePlanSubType__c  
                        FROM zqu__ProductRatePlan__c WHERE zqu__ZProduct__r.Id IN :productIdSet AND RatePlanType__c = 'Proration' 
                        AND zqu__Deleted__c = false ORDER BY Id ASC]) {   // Start/End UD-2210 21Aug15 John - added SubscriptionFrequency__c and RatePlanSubType__c
                       
                    if (productId_packageItemFrequency.get(ratePlan.zqu__ZProduct__c) == ratePlan.SubscriptionFrequency__c 
                            || ratePlan.RatePlanSubType__c == NON_CHARGEABLE) { // Start/End UD-2210 21Aug15 John - added condition
                        
                        if(!mapProductIdToRatePlanIds.containsKey(ratePlan.zqu__ZProduct__c))
                        {
                            mapProductIdToRatePlanIds.put(ratePlan.zqu__ZProduct__c, new Set<Id>());
                        }
                        mapProductIdToRatePlanIds.get(ratePlan.zqu__ZProduct__c).add(ratePlan.Id);
                    }   // Start/End UD-2210 21Aug15 John - end condition
                }
            }
            
            /*------------------------------- Get Rate Plans for Gift Charges----------------------------------*/
                List<zqu__ProductRatePlan__c> lstGiftRatePlans = 
                    [Select zqu__ZProduct__r.ProductType__c, zqu__ZProduct__r.ProductSubType__c, zqu__ZProduct__c, Id 
                     From zqu__ProductRatePlan__c
                     Where zqu__ZProduct__r.ProductType__c = 'Gift' and zqu__ZProduct__r.ProductSubType__c = 'Premium' and zqu__Deleted__c = false];
            if(!lstGiftRatePlans.isEmpty()){
                giftRatePlanId = lstGiftRatePlans[0].Id;
            }
            
            /*------------------------------- Get Rate Plans for Delivery Charges----------------------------------*/
            if(bHasVendorDelivery)
            {
                List<zqu__ProductRatePlan__c> lstDeliveryRatePlans = 
                [Select zqu__ZProduct__r.ProductType__c, zqu__ZProduct__r.ProductSubType__c, zqu__ZProduct__c, Id, Name
                From zqu__ProductRatePlan__c
                //Start D-2227 02/17/15 Added by ABanaag - change filter from Name to Product Code; removed hardcoded values
                Where 
                zqu__ZProduct__r.ProductCode__c =: GlobalVariableClass.PRODUCT_CODE_DELCHG and zqu__Deleted__c = false];
                //End D-2227 02/17/15 Added by ABanaag - change filter from Name to Product Code; removed hardcoded values
                system.debug('GlobalVariableClass.PRODUCT_CODE_DELCHG '+GlobalVariableClass.PRODUCT_CODE_DELCHG );
                //START D-2545/D-2646 AddedBy FrancisBenzon : cater change of PRP Del Charge Names
                if(!lstDeliveryRatePlans.isEmpty()){
                    for(zqu__ProductRatePlan__c drp: lstDeliveryRatePlans){
                        system.debug('drp.Name ' + drp.Name);
                        if (drp.name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('Zero Charge Amount'))){
                            deliveryRatePlan_Internal = drp;
                        }else if(drp.name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('HDB DELIVERY CHARGE'))){
                            deliveryRatePlan_HDB = drp;
                        }else if(drp.name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('APT DELIVERY CHARGE'))){ 
                            deliveryRatePlan_Apartment = drp;
                        }else if(drp.name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('LANDED DELIVERY CHARGE'))){
                            deliveryRatePlan_Landed = drp;
                        }
                    }
                }
                //END D-2545/D-2646 AddedBy FrancisBenzon : cater change of PRP Del Charge Names
                //SET Delivery Rate Plan to Use
                if(orderObj.Recipient_Type__c == sInternal){
                    ratePlanDelivery = deliveryRatePlan_Internal;
                }else if(orderObj.Recipient_Type__c == sLocal || orderObj.Recipient_Type__c == sAirline){
                    if(defaultDeliveryChargeType == 'H')
                        ratePlanDelivery = deliveryRatePlan_HDB;
                    else if(defaultDeliveryChargeType== 'C')
                        ratePlanDelivery = deliveryRatePlan_Apartment;
                    else if(defaultDeliveryChargeType == 'L')
                        ratePlanDelivery = deliveryRatePlan_Landed;
                }
                
                if(ratePlanDelivery == NULL)
                    throw new CustomException(System.Label.ERR_NO_DELIVERY_RATE_PLAN);
            }
            
            /*------------------------------- Get Rate Plans for Postage Charge----------------------------------*/
            if(bHasPostageCharge)
            {
                //START D-3032 05/28/2015 Added by J. Sarion - Added Product_Code__c = 'POSCHG'
                // Start D-0060(UAT) 25-02-2015 JohnD add Limit keyword in the query
                ratePlanPostage = [SELECT Id,Name,zqu__ZProduct__c,zqu__ZProduct__r.ProductCode__c,
                                   zqu__ZProduct__r.ProductType__c,zqu__ZProduct__r.ProductSubType__c 
                                   FROM zqu__ProductRatePlan__c 
                                   WHERE RatePlanCode__c = 'CHGPOS' AND zqu__Deleted__c = false AND Product_Code__c = 'POSCHG' limit 1];
                // End D-0060(UAT) 25-02-2015 JohnD
                //END D-3032 05/28/2015 Added by J. Sarion - Added Product_Code__c = 'POSCHG'
            }
            
            //START D-2992 Wenjun 21/05/15 : Query Discount Percentage
            /*------------------------------- Get Discount Percentage ----------------------------------*/
            if(!setDiscRatePlanIDs.isEmpty())
            {
                for(zqu__ProductRatePlanCharge__c charge: [SELECT zqu__ProductRatePlan__c,sum__c FROM zqu__ProductRatePlanCharge__c 
                                                            WHERE zqu__Deleted__c = false 
                                                            and zqu__ProductRatePlan__c in :setDiscRatePlanIDs])
                {
                    mapRatePlanIDToDisc.put(charge.zqu__ProductRatePlan__c, charge.sum__c);
                }
            }
            //END D-2992 Wenjun 21/05/15
            
            /*----------------------START THE CREATION OF QUOTES ------------------*/
            System.debug('===========> Starting Creation of Quotes ...');
            for(Order_Line_Item__c oli: mOrderLineItems.values())
            {
                //Processing Main Package Quotes 
                if(oli.Main_Package_ID__c != null)
                {
                    //sPackageType values are: Base, Add On, Bundle, Discount
                    sPackageType = oli.Main_Package_ID__r.Package_Type__c; 
                    if (oli.Main_Package_ID__r.Subscription_Type__c == 'Termed') {
                        try {
                            //Start D-2390 03-02-15 ABanaag
                            if(oli.Main_Package_ID__r.Billing_Type__c != GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID
                            && oli.Term_Length__c!=null){
                                intTerm = integer.valueOf(oli.Term_Length__c);
                            }
                            else{
                                intTerm = Integer.valueof(oli.Main_Package_ID__r.Subscription_Period__c);
                            }
                            //End D-2390 03-02-15 ABanaag
                        } catch(exception e) {
                            intTerm = 0;
                            //START UD-2175 30-July-2015 Added by S.Puli - add ExceptionLogger function
                            exceptionList.add(e);
                            //END UD-2175 30-July-2015 Added by S.Puli - add ExceptionLogger function
                        }
                    }
                    
                    List<Package_Item__c> lstPackageItems = new List<Package_Item__c>();
                    
                    if (mPackageToPackageItems.get(oli.Main_Package_ID__c) != null) {
                        lstPackageItems = mPackageToPackageItems.get(oli.Main_Package_ID__c);
                    }
                    
                    //1st Loop to process all "Products"
                    for(Package_Item__c pckItm: lstPackageItems)
                    {
                        zqu__Quote__c quote = NULL;
                        
                        //Base Product & Bundle Product
                        //START UD-2228 8/14/2015 Added By C. Lin - get Frequency from Product Rate Plan
                        if(RT_ID_BASE_PROD == pckItm.RecordTypeId || RT_ID_BUNDLE_PROD == pckItm.RecordTypeId){
                            quote = createQuoteMain(oli, orderObj, intTerm, true, SUB_TYPE_PUB, true, false, false, origin);
                            quote.Frequency__c = pRatePlanToSubFreqMap.get(pckItm.Product_Rate_Plan__c);
                        }
                        else if(RT_ID_EXT_PROD == pckItm.RecordTypeId){ //Extension Product
                        //START D-1837 Wenjun 09/02/15 : Remove irrelevant logic for extension quote
                            quote = createQuoteExtension(oli, orderObj, pckItm.Duration_in_months__c, SUB_TYPE_PUB, origin);
                        //END D-1837 Wenjun 09/02/15
                            quote.Frequency__c = pRatePlanToSubFreqMap.get(pckItm.Product_Rate_Plan__c);
                        }
                        //END UD-2228 8/14/2015 Added By C. Lin
                        
                        if(quote != NULL)
                        {
                            INSERT quote;
                            system.debug('::::QUOTEID' + quote.Id);
                            system.debug('::::PRP' + pckItm.Product_Rate_Plan__c);
                            //Start D-2010 Addedby FrancisBenzon 2/2/15 : to catch error of managed class of zuora
                            try {
                                //Start UD-678 VPernicia/MGatchalian 3/30/2015: Comment out callout (chargeGroup) and mapQuoteIdToChargeGroups. Add lstQuoteRatePlan
                                //zqu.zChargeGroup chargeGroup = zqu.zQuoteUtil.getChargeGroup(quote.Id, pckItm.Product_Rate_Plan__c);
                                lstQuoteRatePlan.add(quote.Id + '|' + pckItm.Product_Rate_Plan__c);
                                
                                lstZQuotes.add(quote);
                                lQuoteIds.add(quote.Id);                            
                                mapPackItemToQuoteId.put(pckItm.Id, quote.Id);
                                //mapQuoteIdToChargeGroups.put(quote.Id, new List<zqu.zChargeGroup>());
                                //mapQuoteIdToChargeGroups.get(quote.Id).add(chargeGroup);
                                //End UD-678 VPernicia/MGatchalian 3/30/2015: Comment out callout (chargeGroup) and mapQuoteIdToChargeGroups. Add lstQuoteRatePlan
                            }
                            catch(exception e) {
                                system.debug('ERROR' + e.getMessage());
                                //START UD-2175 30-July-2015 Added by S.Puli - add ExceptionLogger function
                                exceptionList.add(e);
                                //END UD-2175 30-July-2015 Added by S.Puli - add ExceptionLogger function
                            }

                            //End D-2010 Addedby FrancisBenzon 2/2/15 : to catch error of managed class of zuora                      
                        }
                    } //End of For Loop
                    
                    //2nd Loop to process all "Discounts"
                    
                    for(Package_Item__c pckItm: lstPackageItems)
                    {

                        if(RT_ID_DISC == pckItm.RecordTypeId || RT_ID_BUNDLE_DISC == pckItm.RecordTypeId || RT_ID_EXT_DISC == pckItm.RecordTypeId)
                        {
                            //Get Discount Base Item
                            Id baseItemId = pckItm.Base_Package_Item__c;
                            if(baseItemId == NULL || !mapPackItemToQuoteId.containsKey(baseItemId))
                                throw new CustomException(System.Label.ERR_INVALID_PACKAGE + ' Item ID: ' + pckItm.Id);
                            
                            //Start UD-678 VPernicia/MGatchalian 3/30/2015: Comment out callout (chargeGroup) and mapQuoteIdToChargeGroups. Add lstQuoteRatePlan
                            //zqu.zChargeGroup chargeGroup = zqu.zQuoteUtil.getChargeGroup(mapPackItemToQuoteId.get(baseItemId), pckItm.Product_Rate_Plan__c);
                            //mapQuoteIdToChargeGroups.get(mapPackItemToQuoteId.get(baseItemId)).add(chargeGroup);
                            lstQuoteRatePlan.add(mapPackItemToQuoteId.get(baseItemId) + '|' + pckItm.Product_Rate_Plan__c);
                            //End UD-678 VPernicia/MGatchalian 3/30/2015: Comment out callout (chargeGroup) and mapQuoteIdToChargeGroups. Add lstQuoteRatePlan
                            
                            //Prepare data for later overwrite
                            String key = mapPackItemToQuoteId.get(baseItemId) +'-'+ pckItm.Product_Rate_Plan__c;
                            Integer startMonth = 1;
                            if(RT_ID_EXT_DISC != pckItm.RecordTypeId)
                                startMonth = Integer.valueOf(pckItm.Effective_Start_Month__c);
                            //START UD-0460 MGaelo Add logic for N/A duration and up to how many periods 
                            Integer duration;
                            Boolean isNone = false;
                            if(pckItm.Duration_in_months__c != 'N/A'){
                                duration = Integer.valueOf(pckItm.Duration_in_months__c); }
                            else{
                                duration = 0;
                                isNone = true;
                            }
                            
                            //START D-2992 Wenjun 21/05/15 : Discount Percentage for Quote Charge
                            if(startMonth == 1)
                            {
                                Decimal discountRate = mapRatePlanIDToDisc.get(pckItm.Product_Rate_Plan__c);
                                mapQuoteIdToDisc.put(mapPackItemToQuoteId.get(baseItemId), discountRate);
                            }
                            //END D-2992 Wenjun 21/05/15
                            
                            mapDiscountCharges.put(key, new DiscountChargeWrapper(startMonth, duration, oli.Start_Date__c, isNone));
                            //END UD-0460 MGaelo Add logic for N/A duration and up to how many periods
                        }
                    } //End of For Loop
                 } //End of if(oli.Main_Package_ID__c != null)

                // Process Add-on Package Quotes
                if(oli.Addon_Package__c != null) {
                    //sPackageType values are: Base, Add On, Bundle, Discount
                    sPackageType = oli.Addon_Package__r.Package_Type__c; 
                    
                    if (oli.Main_Package_ID__r.Subscription_Type__c == 'Termed' 
                        && oli.Promotion_ID__c != null && oli.Addon_Package__r.Subscription_Period__c != null) 
                    {
                        try {
                            intTerm = Integer.valueof(oli.Addon_Package__r.Subscription_Period__c);
                        } catch (exception e) {
                            intTerm = 0;
                            //START UD-2175 30-July-2015 Added by S.Puli - add ExceptionLogger function
                            exceptionList.add(e);
                            //END UD-2175 30-July-2015 Added by S.Puli - add ExceptionLogger function
                        }
                    }
                    
                    List<Package_Item__c> lstAddOnPackageItems = mPackageToPackageItems.get(oli.Addon_Package__c);
         
                    if (lstAddOnPackageItems != null) {                    
                        //1st Loop to process all "Products"
                        for(Package_Item__c pckItm: lstAddOnPackageItems)
                        {
                            if(RT_ID_BASE_PROD == pckItm.RecordTypeId)
                            {
                                zqu__Quote__c quote = createQuoteMain(oli, orderObj, 1, true, SUB_TYPE_PUB, false, true, false,origin);
                                //START UD-2228 8/14/2015 Added By C. Lin - get Frequency from Product Rate Plan
                                quote.Frequency__c = pRatePlanToSubFreqMap.get(pckItm.Product_Rate_Plan__c);
                                //END UD-2228 8/14/2015 Added By C. Lin
                                
                                INSERT quote;
                                //Start UD-678 VPernicia/MGatchalian 3/30/2015: Comment out callout (chargeGroup) and mapQuoteIdToChargeGroups. Add lstQuoteRatePlan
                                //zqu.zChargeGroup chargeGroup = zqu.zQuoteUtil.getChargeGroup(quote.Id, pckItm.Product_Rate_Plan__c);
                                lstQuoteRatePlan.add(quote.Id + '|' + pckItm.Product_Rate_Plan__c);
                                
                                lstZQuotes.add(quote);
                                lQuoteIds.add(quote.Id);
                                mapPackItemToQuoteId.put(pckItm.Id, quote.Id);
                                //mapQuoteIdToChargeGroups.put(quote.Id, new List<zqu.zChargeGroup>());
                                //mapQuoteIdToChargeGroups.get(quote.Id).add(chargeGroup);
                                //End UD-678 VPernicia/MGatchalian 3/30/2015: Comment out callout (chargeGroup) and mapQuoteIdToChargeGroups. Add lstQuoteRatePlan
                            }
                        } //End of For Loop
                        
                        //2nd Loop to process all "Discounts"
                        for(Package_Item__c pckItm: lstAddOnPackageItems)
                        {
                            if(RT_ID_DISC == pckItm.RecordTypeId)
                            {
                                //Get Discount Base Item
                                Id baseItemId = pckItm.Base_Package_Item__c;
                                if(baseItemId == NULL || !mapPackItemToQuoteId.containsKey(baseItemId))
                                    throw new CustomException(System.Label.ERR_INVALID_PACKAGE + ' Item ID: ' + pckItm.Id);
                                
                                //Start UD-678 VPernicia/MGatchalian 3/30/2015: Comment out callout (chargeGroup) and mapQuoteIdToChargeGroups. Add lstQuoteRatePlan
                                //zqu.zChargeGroup chargeGroup = zqu.zQuoteUtil.getChargeGroup(mapPackItemToQuoteId.get(baseItemId), pckItm.Product_Rate_Plan__c);
                                //mapQuoteIdToChargeGroups.get(mapPackItemToQuoteId.get(baseItemId)).add(chargeGroup); 
                                lstQuoteRatePlan.add(mapPackItemToQuoteId.get(baseItemId) + '|' + pckItm.Product_Rate_Plan__c);
                                //End UD-678 VPernicia/MGatchalian 3/30/2015: Comment out callout (chargeGroup) and mapQuoteIdToChargeGroups. Add lstQuoteRatePlan
                                
                                //Prepare data for later overwrite
                                String key = mapPackItemToQuoteId.get(baseItemId) + '-' +pckItm.Product_Rate_Plan__c;
                                Integer startMonth = Integer.valueOf(pckItm.Effective_Start_Month__c);
                                //START UD-0460 MGaelo Add logic for N/A duration and up to how many periods
                                Integer duration;
                                Boolean isNone = false;
                                if(pckItm.Duration_in_months__c != 'N/A'){
                                    duration = Integer.valueOf(pckItm.Duration_in_months__c); }
                                else{
                                    duration = 0;
                                    isNone = true;
                                }
                                
                                //START D-2992 Wenjun 21/05/15 : Discount Percentage for Quote Charge
                                if(startMonth == 1)
                                {
                                    Decimal discountRate = mapRatePlanIDToDisc.get(pckItm.Product_Rate_Plan__c);
                                    mapQuoteIdToDisc.put(mapPackItemToQuoteId.get(baseItemId), discountRate);
                                }
                                //END D-2992 Wenjun 21/05/15
                            
                                mapDiscountCharges.put(key, new DiscountChargeWrapper(startMonth, duration, oli.Start_Date__c, isNone));
                                //END UD-0460 MGaelo Add logic for N/A duration and up to how many periods
                            }
                        } //End of For Loop
                    }//End of if (lstAddOnPackageItems != null)
                } //End of if(oli.Addon_Package__c != null)

                // Process Gift Quotes
                if(!mOrderLineItemToGifts.isEmpty() && giftRatePlanId != NULL){
                    if (mOrderLineItemToGifts.containskey(oli.Id) && mOrderLineItemToGifts.get(oli.Id) != null){
                        for(Order_Line_Item_Gift__c itemGift: mOrderLineItemToGifts.get(oli.Id))
                        {
                            if(itemGift.type__c == 'Premium')
                            {
                                //START D-1837 Wenjun 09/02/15 : Create Gift Quote
                                zqu__Quote__c quote = createQuoteMain(oli, orderObj, 1, true, SUB_TYPE_GIFT, false, false, true, origin);
                                //START UD-2228 8/14/2015 Added By C. Lin - get Frequency from Product Rate Plan
                                quote.Frequency__c = null;
                                //END UD-2228 8/14/2015 Added By C. Lin
                                
                                INSERT quote;
                                //Start UD-678 VPernicia/MGatchalian 3/30/2015: Comment out callout (chargeGroup) and mapQuoteIdToChargeGroups. Add lstQuoteRatePlan
                                //zqu.zChargeGroup chargeGroup = zqu.zQuoteUtil.getChargeGroup(quote.Id, giftRatePlanId);
                                lstQuoteRatePlan.add(quote.id + '|' + giftRatePlanId);
                                
                                lstZQuotes.add(quote);
                                lQuoteIds.add(quote.Id);
                                //mapQuoteIdToChargeGroups.put(quote.Id, new List<zqu.zChargeGroup>());
                                //mapQuoteIdToChargeGroups.get(quote.Id).add(chargeGroup);
                                //End UD-678 VPernicia/MGatchalian 3/30/2015: Comment out callout (chargeGroup) and mapQuoteIdToChargeGroups. Add lstQuoteRatePlan
                                
                                //Prepare data for later overwrite
                                Decimal giftPrice = itemGift.Promotion_Gift__r.Gift__r.One_Time_Charge__c;
                                Integer iQuantity = Integer.valueOf(itemGift.Order_Quantity__c);
                                mapQuoteIdToGiftCharges.put(quote.Id, new GiftChargeWrapper(giftPrice, iQuantity));
                                //END D-1837 Wenjun 09/02/15
                            }
                        } //End of For Loop
                    }
                }//End of if(!mOrderLineItemToGifts.isEmpty())
                system.debug('ratePlanPostage>>'+ratePlanPostage);
                    /* START END UD-2951 1/10/2015 Gdelrosario : added parameter to get postage fix  */
                    //START D-3757 10/23/15 RReyes - added condition to cater postage creation for evergreen
                    if((oli.Delivered_By__c == 'Mailing Agent' && ratePlanPostage != NULL) && ((oli.Total_Postage_Charge__c > 0 && oli.Main_Package_ID__r.Subscription_Type__c == 'Termed') || (oli.Postage_Charge__c > 0 && oli.Main_Package_ID__r.Subscription_Type__c == 'Evergreen') || (oli.Order__r.Payment_Mode__c == 'Other' && oli.Order__r.Other_Payment_Mode__c == 'Freelist' && oli.Total_Postage_Charge__c == 0 )) ) // Start/End UD-1324 26May15 JohnD - added postage charge in the expression
                    //END D-3757 10/23/15 RReyes - added condition to cater postage creation for evergreen
                    /* END END UD-2951 1/10/2015 Gdelrosario : added parameter to get postage fix */
                    {
                    system.debug('oli.Delivered_By__c>>'+oli.Delivered_By__c+'   '+'ratePlanPostage>>'+ratePlanPostage);
                    zqu__Quote__c quote = createQuotePostage(orderObj, oli, ConstantsSLB.getkeyid('SubTypePostage'), origin);
                    
                    INSERT quote;
                    //Start UD-678 VPernicia/MGatchalian 3/30/2015: Comment out callout (chargeGroup) and mapQuoteIdToChargeGroups. Add lstQuoteRatePlan
                    //zqu.zChargeGroup chargeGroup = zqu.zQuoteUtil.getChargeGroup(quote.Id, ratePlanPostage.Id);
                    lstQuoteRatePlan.add(quote.id + '|' + ratePlanPostage.Id);
                    
                    lstZQuotes.add(quote);
                    lQuoteIds.add(quote.Id);
                    //mapQuoteIdToChargeGroups.put(quote.Id, new List<zqu.zChargeGroup>());
                    //mapQuoteIdToChargeGroups.get(quote.Id).add(chargeGroup);
                    //End UD-678 VPernicia/MGatchalian 3/30/2015: Comment out callout (chargeGroup) and mapQuoteIdToChargeGroups. Add lstQuoteRatePlan
                    
                    //START D-1970 Wenjun 28/01/15 : Postage Amount for each Quote
                    mapQuoteIdToPostageAmt.put(quote.Id, oli.Postage_Charge__c);
                    //END D-1970 Wenjun 28/01/15
                }
                
                //START D-2530 19/03/15 Wenjun : Create Delivery Sub for each Order Line Item
                if(oli.Delivered_By__c == 'Vendor' && ratePlanDelivery != NULL)
                {
                    //START UD-3221 11/18/2015 Added by J.Sarion - No Del Sub will be created for Product Codes in Custom Settings
                    String prodCode;
                    zqu__Quote__c quote = new zqu__Quote__c();
                    if(oliIdToProductCodeMap.containsKey(oli.Id)) {
                        prodCode = oliIdToProductCodeMap.get(oli.Id);
                    }
                    //START UD-3278 11/25/2015 Added F.Benzon - add quote if Package is eligible for Del Sub
                    if(prodCode == null || !prodCodeSet.contains(prodCode)) {
                        quote = createQuoteDelivery(orderObj, oli, ConstantsSLB.getkeyid('SubTypeDel'), origin);
                    
                        //END UD-3221 11/18/2015 Added by J.Sarion - No Del Sub will be created for Product Codes in Custom Settings
                        
                        INSERT quote;
                        
                        //Start UD-678 VPernicia/MGatchalian 3/30/2015: Comment out callout (chargeGroup) and mapQuoteIdToChargeGroups. Add lstQuoteRatePlan
                        //zqu.zChargeGroup chargeGroup = zqu.zQuoteUtil.getChargeGroup(quote.Id, ratePlanDelivery.Id);
                        lstQuoteRatePlan.add(quote.id + '|' + ratePlanDelivery.Id);
                        
                        lstZQuotes.add(quote);
                        lQuoteIds.add(quote.Id);
                        //mapQuoteIdToChargeGroups.put(quote.Id, new List<zqu.zChargeGroup>());
                        //mapQuoteIdToChargeGroups.get(quote.Id).add(chargeGroup);
                        //End UD-678 VPernicia/MGatchalian 3/30/2015: Comment out callout (chargeGroup) and mapQuoteIdToChargeGroups. Add lstQuoteRatePlan
                    }
                    //END UD-3278 11/25/2015 Added F.Benzon - add quote if Package is eligible for Del Sub
                }
                
                if(oli.Main_Package_Product_Platform__c == 'All-In-One')
                    bCharity = oli.Charity__c;
                else if(oli.Main_Package_Product_Platform__c == 'Print')
                    bCharity = false;        
                
                if(oli.Main_Package_Billing_Type__c == 'Full Prepaid')
                    bPayDeliveryChargeNow = true;
            }
            
            
            //set subscriberCharge & vendorCredit
            subscriberCharge = orderObj.Subscriber_Charge__c;
            vendorCredit = orderObj.Vendor_Credit__c;
            
            // Check if there is any existing Delivery Subscription
        
            
                

            //END D-2530 19/03/15 Wenjun
            /* ------------------------------- Process Prorations Rate Plans ---------------------------------*/
            for(Id itemID : mapPackItemToQuoteId.keySet())
            {
                ID quoteID = mapPackItemToQuoteId.get(itemID);
                ID prodID  = mapPackItemToProdId.get(itemID);
                
                if(mapProductIdToRatePlanIds.containsKey(prodID))
                {
                    for(ID ratePlanID : mapProductIdToRatePlanIds.get(prodID))
                    {
                        //Start UD-678 VPernicia/MGatchalian 3/30/2015: Comment out callout (chargeGroup) and mapQuoteIdToChargeGroups. Add lstQuoteRatePlan
                        lstQuoteRatePlan.add(quoteID + '|' + ratePlanID);
                        //End UD-678 VPernicia/MGatchalian 3/30/2015: Comment out callout (chargeGroup) and mapQuoteIdToChargeGroups. Add lstQuoteRatePlan
                    } 
                }       
            }

            /* ------------------------------- Add Charge Groups for each Quote-------------------------------*/
            //Zuora API does not support add Charge Groups for mutiple quote at the same time
            
            //Start UD-678 VPernicia/MGatchalian 3/30/2015: Comment out the whole try catch and call @future method
            AddChargeGroupCallout(lstQuoteRatePlan);
                    
            //End UD-678 VPernicia/MGatchalian 3/30/2015: Comment out the whole try catch and call @future 
            
            /* ------------------------------- Override Quote Charges -------------------------------*/
            //START D-1970 Wenjun 28/01/15 : Add zqu__UOM__c field
            
            List<zqu__QuoteCharge__c> lstDisCharges = new List<zqu__QuoteCharge__c>();
            if (!lQuoteIds.isEmpty())
            {
                //START D-2992 Wenjun 21/05/15 : Retrieve zqu__Model__c
                lstDisCharges = [SELECT Id, zqu__Quote__c, zqu__Quantity__c, zqu__Quote__r.Qty1__c,zqu__UOM__c, zqu__Model__c,  
                                zqu__EffectivePrice__c, zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c 
                                FROM zqu__QuoteCharge__c WHERE zqu__Quote__c in :lQuoteIds];
                //END D-2992 Wenjun 21/05/15
            }
            //END D-1970 Wenjun 28/01/15
            for(zqu__QuoteCharge__c quoteCharge : lstDisCharges)
            {
                //START D-1837 Wenjun 09/02/15 : Override Gift Charges
                if(giftRatePlanId != null && giftRatePlanId == quoteCharge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c) //Gift Charge Plan
                {   
                    GiftChargeWrapper giftCharge = mapQuoteIdToGiftCharges.get(quoteCharge.zqu__Quote__c);
                    if(giftCharge != NULL)
                    {
                        //START D-2877 05/08/2015 Added By S.Puli exclude dummy charges
                        if(quoteCharge.zqu__UOM__c <> GlobalVariableClass.DUMMY_CHARGE){    
                            quoteCharge.zqu__EffectivePrice__c = giftCharge.dPrice;
                            quoteCharge.zqu__Quantity__c = giftCharge.iQuantity;
                        }
                        //END D-2877 05/08/2015 Added By S.Puli exclude dummy charges
                    }
                    continue;
                } 
                //END D-1837 Wenjun 09/02/15
                
                //Set correct quantity value - Note: no quantity value for Usage Charges
                if(quoteCharge.zqu__Quantity__c != NULL && quoteCharge.zqu__Quantity__c > 0)
                    quoteCharge.zqu__Quantity__c = quoteCharge.zqu__Quote__r.Qty1__c;
                
                //Start D-1943 D-1945 Added by FrancisBenzon 1/27/2015 : catch null pointer 
                if(quoteCharge!=null && subscriberCharge!=null && ratePlanDelivery != null && ratePlanDelivery.Id == quoteCharge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c){    //Start/End D-2227 02/17/15 Added by AprilBanaag - added conditions to avoid null pointer           
                    //Overwrite with Latest Delivery Charge
                    
                    //START D-2877 05/08/2015 Added By S.Puli exclude dummy charges
                    if(quoteCharge.zqu__UOM__c <> GlobalVariableClass.DUMMY_CHARGE){
                        quoteCharge.zqu__EffectivePrice__c = (quoteCharge.zqu__EffectivePrice__c > 0) ? subscriberCharge : -subscriberCharge;
                    }
                    //END D-2877 05/08/2015 Added By S.Puli exclude dummy charges
                }           
                //End D-1943 D-1945 Added by FrancisBenzon 1/27/2015 : catch null pointer 
                //START D-1970 Wenjun 28/01/15 : Overwrite Postage Charge Value 
                else if(ratePlanPostage != null && ratePlanPostage.Id == quoteCharge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c) //Postage Charge Plan
                {
                    //START D-2877 05/08/2015 Added By S.Puli exclude dummy charges
                    if(quoteCharge.zqu__UOM__c <> GlobalVariableClass.DUMMY_CHARGE){
                        //Overwrite Postage Charge Value
                        Decimal postageAmt = mapQuoteIdToPostageAmt.get(quoteCharge.zqu__Quote__c);
                        quoteCharge.zqu__EffectivePrice__c = 
                            (ConstantsSLB.getUOM('PostageCharge') == quoteCharge.zqu__UOM__c) ?  postageAmt: -postageAmt;
                    }
                    //END D-2877 05/08/2015 Added By S.Puli exclude dummy charges
                }
                //END D-1970 Wenjun 28/01/15
                //START D-2992 Wenjun 21/05/15 : Overwrite Negative Credit with Discounted Values
                else if(mapQuoteIdToDisc.containsKey(quoteCharge.zqu__Quote__c) && quoteCharge.zqu__EffectivePrice__c < 0
                        && quoteCharge.zqu__Model__c == GlobalVariableClass.SPC_MODEL_UNIT)
                {
                    Decimal discRate = mapQuoteIdToDisc.get(quoteCharge.zqu__Quote__c);
                    //Start PD-0350 VPernicia: Exclude adjustment and Adjustment No Tax for the discount
                    if(discRate != NULL && (quoteCharge.zqu__UOM__c != GlobalVariableClass.AdjustmentUOM && quoteCharge.zqu__UOM__c != GlobalVariableClass.AdjustmentNoTaxUOM))
                    //End PD-0350 VPernicia: Exclude adjustment and Adjustment No Tax for the discount
                    {
                        Decimal newPrice = quoteCharge.zqu__EffectivePrice__c * (1 - discRate/100);
                        newPrice = newPrice.setScale(2, System.RoundingMode.HALF_UP);
                        quoteCharge.zqu__EffectivePrice__c = newPrice;
                    }
                }
                //END D-2992 Wenjun 21/05/15
                else
                {
                    String key = quoteCharge.zqu__Quote__c + '-'+ quoteCharge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c;
                    DiscountChargeWrapper discountCharge = mapDiscountCharges.get(key);

                    //Overwrite Discount Quotes
                    if(discountCharge != NULL)
                    {
                         Integer startMonth = discountCharge.effectStartMonth;
                         if(startMonth != 1) //For Tiered Discount
                         {
                             quoteCharge.zqu__TriggerEvent__c = 'SpecificDate';
                             Date startDate = discountCharge.startDate;
                             Integer intMthToAdd = (startDate.day() == 1) ? startMonth -1 : startMonth;
                             quoteCharge.zqu__TriggerDate__c = startDate.toStartOfMonth().addMonths(intMthToAdd);
                         }
                        
                        //Set Up To How Many Months 
                        //START UD-0460 MGaelo Add logic for N/A duration and up to how many periods
                        if(discountCharge.isNone){
                            quoteCharge.zqu__Upto_How_Many_Periods__c = null;
                        }else{
                        quoteCharge.zqu__Upto_How_Many_Periods__c = discountCharge.duration;
                        }
                        //END UD-0460 MGaelo Add logic for N/A duration and up to how many periods
                    }
                }
            }
            
            UPDATE lstDisCharges;
            System.debug('||-------------------------------------------------------------------------------------------||');
            System.debug('lstQuoteIDs' + lQuoteIds);
            System.debug('PaymentMode' + paymentMode);
            system.debug('sDeliveryChargeType' + paymentModeOther);
            system.debug('bCreateNewBillingAccount' + bCreateNewBillingAccount);
            system.debug('bCreateDeliverySubscription' + bCreateDeliverySubscription);
            system.debug('bPayDeliveryChargeNow' + bPayDeliveryChargeNow);
            system.debug('ExistingDeliverySubscriptionId' + existingDeliverySubscriptionId);
            system.debug('SFBillingAccount' + sfBillingAccount);
            system.debug('zBillingAccount' + zBillingAccount);
            system.debug('SubscriberCharge' + subscriberCharge);
            system.debug('AccountId' + accountId);
            system.debug('DeliveryFPSubscriptionUsage' + deliveryFPSubscriptionUsage);
            system.debug('||-------------------------------------------------------------------------------------------||'); 
        //START UD-2175 30-July-2015 Added by S.Puli - add ExceptionLogger function
        }
        catch (exception e) {
            exceptionList.add(e);
        }
        
        ExceptionLogger.log(exceptionList); // you must invoke this at the end of your execution script
        //END UD-2175 30-July-2015 Added by S.Puli - add ExceptionLogger function
    }
    
    //Start UD-678 VPernicia/MGatchalian 3/30/2015: To push quote to Zuora
    //@future (callout = true)
    public static void AddChargeGroupCallout(list<string> lstQuoteRateID) {
        
        map<id, list<id>> mapQuoteIdRateID = new map<id, list<id>>();
         
        for (integer x = 0; x < lstQuoteRateID.size(); x++) {
            List<string> arrayResult = lstQuoteRateID[x].split('\\|');
                
            if (!mapQuoteIdRateID.containskey(arrayResult[0])) {
                mapQuoteIdRateID.put(arrayResult[0], new list<id>());
                mapQuoteIdRateID.get(arrayResult[0]).add(arrayResult[1]);
            } else {
                mapQuoteIdRateID.get(arrayResult[0]).add(arrayResult[1]);
            }                
        } 
        
        for(Id quoteID : mapQuoteIdRateID.keySet())
        {
            List<zqu.zChargeGroup> lstChargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteID, mapQuoteIdRateID.get(quoteID));
            
            if(lstChargeGroups != NULL && !lstChargeGroups.isEmpty())
            {
                //Add up to 30 Charge Groups to a Quote
                if(lstChargeGroups.size() > 30)
                    throw new CustomException(System.Label.ERR_MAX_30_CHARGE_GROUP);
                else {
                    
                    zqu.zQuoteUtil.addChargeGroups(lstChargeGroups);
                }
             }
            
        }
    }
    //End UD-678 VPernicia/MGatchalian 3/30/2015: To push quote to Zuora
    
    public static zqu__Quote__c createQuoteMain(Order_Line_Item__c oli, Order__c orderObj, Integer intTerm, Boolean bBundledWith, 
                                         String sSubType, Boolean bMain, Boolean bAddOn, Boolean bGift, String origin){
        zqu__Quote__c q1 = new zqu__Quote__c ();
        q1.Name                                 = oli.Name;
        q1.zqu__SubscriptionType__c             = 'New Subscription';                    
        q1.zqu__ValidUntil__c                   = Date.Today().addMonths(1);
        //START D-1838 01/23/15 Added by April Banaag
        //START D-1967 01/28/15 Added by April Banaag - revert action; transfer D-1838 logic to SubscriptionTriggerHandler
        //START UD-2340 Wenjun 14 Oct: Set Contract Effective Date to one day before if start date is 1st day of the month for recurring prepaid
        //This is to make sure usage can be processed correctly
        if(oli.Main_Package_Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_PRE && oli.Start_Date__c.day() == 1)
            q1.zqu__StartDate__c                = oli.Start_Date__c.addDays(-1);
        else
            q1.zqu__StartDate__c                = oli.Start_Date__c;
        
        q1.zqu__TermStartDate__c                = oli.Start_Date__c;
        q1.zqu__Service_Activation_Date__c      = oli.Start_Date__c;
        //END UD-2340 Wenjun 14 Oct
        //END D-1967 01/28/15 Added by April Banaag - revert action; transfer D-1838 logic to SubscriptionTriggerHandler
        //END D-1838 01/23/15 Added by April Banaag
        q1.zqu__Subscription_Term_Type__c       = oli.Main_Package_ID__r.Subscription_Type__c;
        
        q1.Qty1__c                              = oli.Qty__c ;
        //START D-1837 Wenjun 09/02/15 : Term Length is 1 for Gift Subscription
        q1.Term_Length1__c                      = bGift? 1 : oli.Term_Length__c;
        //END D-1837 Wenjun 09/02/15
        q1.zqu__Currency__c                     = CURRENCY_SGD;
        q1.zqu__InvoiceProcessingOption__c      = INVOICE_PROC_OPTION;
        //Start D-1610 Added by FrancisBenzon 1/26/2015 : Value of Payment Term wrt Dbt Management Treatment
        if(orderObj.Debt_Management_Treatment__c == GlobalVariableClass.SUBL) {
            q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_SUBL;
        }
        else if(orderObj.Debt_Management_Treatment__c == GlobalVariableClass.SUBH) {
            q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_SUBH;
        }
        else if(orderObj.Debt_Management_Treatment__c == GlobalVariableClass.GOVT) {
            q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_GOVT;   
        }
        else {
            q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_NORM;
        }
        //End D-1610 Added by FrancisBenzon 1/26/2015 : Value of Payment Term wrt Dbt Management Treatment      
        q1.zqu__RenewalTerm__c                  = 0;
        q1.zqu__ProcessPayment__c               = false;
        q1.zqu__GenerateInvoice__c              = false;
        q1.Generate_Invoice1__c                 = false;
         
        if(oli.Main_Package_ID__r.Subscription_Type__c == ConstantsSLB.getkeyid('SubTermTypeTermed') ){
            if (bGift){
                q1.zqu__InitialTerm__c = 1;
            }else{
                //Start D-2390 03-02-15 ABanaag
                if (oli.Main_Package_ID__r.Subscription_Period__c != null) {
                    if(oli.Main_Package_ID__r.Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID 
                    || oli.Main_Package_ID__r.Billing_Type__c == GlobalVariableClass.RECURRING_POSTPAID){
                        q1.zqu__InitialTerm__c = intTerm;
                    }
                    else{
                        q1.zqu__InitialTerm__c = Integer.valueof(oli.Main_Package_ID__r.Subscription_Period__c);
                    }
                //End D-2390 03-02-15 ABanaag

                } else {
                    q1.zqu__InitialTerm__c = 0;
                }
            }
        }
        
        q1.Bundled_With__c                      = (bBundledWith) ? oli.id : NULL;    
        q1.Subscription_Type__c                 = sSubType;        
        q1.zqu__AutoRenew__c                    = oli.Auto_Renew__c;
        q1.Charity__c                           = oli.Charity__c;
        q1.Delivered_By__c                      = oli.Delivered_By__c;

        if(bCreateNewBillingAccount || origin == 'ESHOP Webservice')
             q1.zqu__BillToContact__c = orderObj.Billing_Contact__r.Id; 
        else
             q1.zqu__ZuoraAccountID__c = orderObj.Billing_Account_External_ID__c; 
        q1.Payment_Mode__c                      = orderObj.Payment_Mode__c; 
        q1.zqu__PaymentMethod__c                = orderObj.Payment_Mode__c;      
        q1.Other_PaymentMethod__c               = orderObj.Other_Payment_Mode__c;
        q1.zqu__Account__c                      = orderObj.Account__c;        
        q1.zqu__SoldToContact__c                = orderObj.Recipient_Contact__c;       
        q1.zqu__ElectronicPaymentMethodId__c    = orderObj.Payment_Method_ID__c;      
        q1.Cost_Center__c                       = orderObj.Cost_Centre__c;
        q1.Acquisition_Type__c                  = orderObj.Acquisition_Type__c;
        q1.Delivery_Charge_Type__c              = orderObj.Delivery_Charge_Type__c;
        q1.Subscriber_Charge__c                 = orderObj.Subscriber_Charge__c;
        //START UD-1271 5/21/15 AddedBy FrancisBenzon : vendor credit will only be calculated for subscription delivered by vendor
        if(oli.Delivered_By__c == GlobalVariableClass.VENDOR)
        {
            q1.Vendor_Credit__c                 = orderObj.Vendor_Credit__c;
        }       
        //END UD-1271 5/21/15 AddedBy FrancisBenzon : vendor credit will only be calculated for subscription delivered by vendor
        q1.Frequency__c                         = oli.Main_Package_Frequency__c;            
        q1.Sponsor__c                           = orderObj.Sponsor__c;
        //START: UD-3307 11/25/15 Added by Manolo Valena
        q1.PO_Number__c                         = oli.PO_Number__c;
        //END: UD-3307 11/25/15 Added by Manolo Valena
                                                  
        if (orderObj.Recipient_Contact__c != null) {
               q1.Recipient_Contact__c = String.valueOf(orderObj.Recipient_Contact__c);
        }
        
        //START D-1837 Wenjun 09/02/15 : Promo Pack Check logic does not apply to Add-On and Gift
        if(bMain){
            q1.Main_Package__c                      = oli.Main_Package_ID__c;
            q1.Package_Product_Sub_Type__c          = oli.Main_Package_Product_Sub_Type__c;
            
            if(oli.Vendor_Conversion__c){
                q1.Vendor_Conversion__c             = oli.Vendor_Conversion__c;
                q1.Vendor_Subscription_To_Convert__c= oli.Vendor_Subscription_ID__c; 
            }
            try{
                Promotion_Package__c proPack = [Select Package_Name__c From Promotion_Package__c
                                Where Package_Name__c =: oli.Main_Package_Id__c LIMIT 1];
        
                if(proPack != null)
                {
                    q1.Contract_End_Date__c = oli.Contract_End_Date__c; 
                    q1.New_Contract_Period__c = oli.New_Contract_Period__c;
                }
            }
            catch(Exception e)
            {
                q1.Contract_End_Date__c = null;
                q1.New_Contract_Period__c = null;
            }
            q1.Promotion_Contract_Period__c             = oli.Promotion_Contract_Period__c; 
        }else if(bAddOn){   
            q1.Main_Package__c                      = oli.Addon_Package__c;
            q1.Package_Product_Sub_Type__c          = oli.Add_On_Package_Product_Sub_Type__c;
        }else if(bGift){
            q1.Main_Package__c                      = null;
            q1.Package_Product_Sub_Type__c          = null;
        }
        //END D-1837 Wenjun 09/02/15
        
        q1.Order_Line_Item_Number__c                = oli.Id;
        q1.Order_Number__c                          = oli.Order__c;
        q1.Order_Line_Item_Number_1__c              = oli.Id;
        q1.Urgent__c                                = oli.Urgent__c;  
        q1.Suppress_Vendor_Start_Notice__c          = oli.Suppress_Vendor_Start_notice__c;
        q1.Supressed_Acknowledgement_Letter__c      = oli.Supressed_Acknowledgement_Letter__c;
        q1.Supressed_Renewal_and_Reminder_Letter__c = oli.Suppress_Renewal_and_Reminder_Letter__c;  
        q1.Vendor__c                                = oli.Vendor_Mailing_Agent__c;

        return q1;          
    }
    
    //START D-1837 Wenjun 09/02/15 : Remove irrelevant logic for extension quote
    public static zqu__Quote__c createQuoteExtension(Order_Line_Item__c oli, Order__c orderObj, String duration, String sSubType, String origin){
        zqu__Quote__c q1 = new zqu__Quote__c ();
        q1.Name                                 = oli.Name;
        q1.zqu__SubscriptionType__c             = 'New Subscription';                    
        q1.zqu__ValidUntil__c                   = Date.Today().addMonths(1);
        //START UD-2340 Wenjun 14 Oct: Set Contract Effective Date to one day before if start date is 1st day of the month for recurring prepaid
        //This is to make sure usage can be processed correctly
        q1.zqu__TermStartDate__c                = oli.End_Date__c.addDays(1); //Start after the Base Product
        q1.zqu__Service_Activation_Date__c      = oli.End_Date__c.addDays(1); //Start after the Base Product
        if(oli.Main_Package_Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_PRE && q1.zqu__TermStartDate__c.day() == 1)
            q1.zqu__StartDate__c                = oli.End_Date__c;
        else
            q1.zqu__StartDate__c                = oli.End_Date__c.addDays(1);
        //END UD-2340 Wenjun 14 Oct
        q1.zqu__Subscription_Term_Type__c       = oli.Main_Package_ID__r.Subscription_Type__c;
        q1.Qty1__c                              = oli.Qty__c ;
        q1.Term_Length1__c                      = Integer.valueOf(duration); //Duration
        q1.zqu__InitialTerm__c                  = Integer.valueOf(duration); //Duration
        q1.zqu__Currency__c                     = CURRENCY_SGD;
        q1.zqu__InvoiceProcessingOption__c      = INVOICE_PROC_OPTION;
        //Start D-1610 Added by FrancisBenzon 1/26/2015 : Value of Payment Term wrt Dbt Management Treatment
        if(orderObj.Debt_Management_Treatment__c == GlobalVariableClass.SUBL) {
            q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_SUBL;
        }
        else if(orderObj.Debt_Management_Treatment__c == GlobalVariableClass.SUBH) {
            q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_SUBH;
        }
        else if(orderObj.Debt_Management_Treatment__c == GlobalVariableClass.GOVT) {
            q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_GOVT;   
        }
        else {
            q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_NORM;
        }
        //End D-1610 Added by FrancisBenzon 1/26/2015 : Value of Payment Term wrt Dbt Management Treatment
        q1.zqu__RenewalTerm__c                  = 0;
        q1.zqu__ProcessPayment__c               = false;
        q1.zqu__GenerateInvoice__c              = false;
        q1.Generate_Invoice1__c                 = false;
        q1.Bundled_With__c                      = oli.id;    
        q1.Subscription_Type__c                 = sSubType;        
        q1.zqu__AutoRenew__c                    = false;
        q1.Charity__c                           = oli.Charity__c;
        q1.Delivered_By__c                      = oli.Delivered_By__c;
        q1.Vendor__c                            = oli.Vendor_Mailing_Agent__c;

        if(bCreateNewBillingAccount || origin == 'ESHOP Webservice')
             q1.zqu__BillToContact__c = orderObj.Billing_Contact__r.Id; 
        else
             q1.zqu__ZuoraAccountID__c = orderObj.Billing_Account_External_ID__c; 
        q1.Payment_Mode__c                      = orderObj.Payment_Mode__c; 
        q1.zqu__PaymentMethod__c                = orderObj.Payment_Mode__c;      
        q1.Other_PaymentMethod__c               = orderObj.Other_Payment_Mode__c;
        q1.zqu__Account__c                      = orderObj.Account__c;        
        q1.zqu__SoldToContact__c                = orderObj.Recipient_Contact__c;       
        q1.zqu__ElectronicPaymentMethodId__c    = orderObj.Payment_Method_ID__c;      
        q1.Cost_Center__c                       = orderObj.Cost_Centre__c;
        q1.Acquisition_Type__c                  = orderObj.Acquisition_Type__c;
        q1.Delivery_Charge_Type__c              = orderObj.Delivery_Charge_Type__c;
        q1.Subscriber_Charge__c                 = orderObj.Subscriber_Charge__c;
        //START UD-1271 5/21/15 AddedBy FrancisBenzon : vendor credit will only be calculated for subscription delivered by vendor
        if(oli.Delivered_By__c == GlobalVariableClass.VENDOR)
        {
            q1.Vendor_Credit__c                 = orderObj.Vendor_Credit__c;
        }       
        //END UD-1271 5/21/15 AddedBy FrancisBenzon : vendor credit will only be calculated for subscription delivered by vendor
        q1.Frequency__c                         = oli.Main_Package_Frequency__c;            
        q1.Sponsor__c                           = orderObj.Sponsor__c;
        //START: UD-3307 11/25/15 Added by Manolo Valena
        q1.PO_Number__c                         = oli.PO_Number__c;
        //END: UD-3307 11/25/15 Added by Manolo Valena
                                                  
        if (orderObj.Recipient_Contact__c != null) {
               q1.Recipient_Contact__c = String.valueOf(orderObj.Recipient_Contact__c);
        }  

        q1.Main_Package__c                      = oli.Main_Package_ID__c;
        q1.Package_Product_Sub_Type__c          = oli.Main_Package_Product_Sub_Type__c;
        q1.Order_Line_Item_Number__c                = oli.Id;
        q1.Order_Number__c                          = oli.Order__c;
        q1.Order_Line_Item_Number_1__c              = oli.Id;
        q1.Urgent__c                                = oli.Urgent__c;  
        q1.Suppress_Vendor_Start_Notice__c          = oli.Suppress_Vendor_Start_notice__c;
        q1.Supressed_Acknowledgement_Letter__c      = oli.Supressed_Acknowledgement_Letter__c;
        q1.Supressed_Renewal_and_Reminder_Letter__c = oli.Suppress_Renewal_and_Reminder_Letter__c;  

        return q1;          
    }
    //END D-1837 Wenjun 09/02/15
    
    //START D-2530 Wenjun 19/03/15 : Set new fields on Delviery Subscriptions 
    public static zqu__Quote__c createQuoteDelivery (Order__c orderObj, Order_Line_Item__c itemObj, String sSubType, String origin){
        zqu__Quote__c q1 = new zqu__Quote__c ();    
        q1.Name                                     = 'Delivery Charge';
        q1.zqu__SubscriptionType__c                 = 'New Subscription';                    
        q1.zqu__ValidUntil__c                       = Date.Today().addMonths(1);
        q1.Term_Length1__c                          = itemObj.Term_Length__c;
        q1.Qty1__c                                  = itemObj.Qty__c ;
        //START D-2031 Wenjun 12/02/15 : Term Setting same as related Publication Subscription
        q1.zqu__Subscription_Term_Type__c           = itemObj.Main_Package_ID__r.Subscription_Type__c;

        //Start D-2390 03/02/15 ABanaag 
        if (itemObj.Main_Package_ID__r.Subscription_Type__c == ConstantsSLB.getkeyid('SubTermTypeTermed')) {
            try {
                if(itemObj.Main_Package_ID__r.Billing_Type__c != GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID
                   && itemObj.Term_Length__c!=null){
                       q1.zqu__InitialTerm__c = itemObj.Term_Length__c;
                   }
                else{
                    q1.zqu__InitialTerm__c = Integer.valueof(itemObj.Main_Package_ID__r.Subscription_Period__c);
                }
            } catch(exception e) {
                q1.zqu__InitialTerm__c = 0;
            }
        }               
        //End D-2390 03/02/15 ABanaag  
        q1.zqu__RenewalTerm__c                      = 0;
        //END D-2031 Wenjun 12/02/15
        q1.zqu__Currency__c                         = CURRENCY_SGD;
        q1.zqu__InvoiceProcessingOption__c          = INVOICE_PROC_OPTION;
        //Start D-1610 Added by FrancisBenzon 1/26/2015 : Value of Payment Term wrt Dbt Management Treatment
        if(orderObj.Debt_Management_Treatment__c == GlobalVariableClass.SUBL) {
            q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_SUBL;
        }
        else if(orderObj.Debt_Management_Treatment__c == GlobalVariableClass.SUBH) {
            q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_SUBH;
        }
        else if(orderObj.Debt_Management_Treatment__c == GlobalVariableClass.GOVT) {
            q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_GOVT;   
        }
        else {
            q1.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_NORM;
        }
        //End D-1610 Added by FrancisBenzon 1/26/2015 : Value of Payment Term wrt Dbt Management Treatment
        //START D-1838 01/23/15 Added by April Banaag
        //START D-1967 01/28/15 Added by April Banaag - revert action; transfer D-1838 logic to SubscriptionTriggerHandler
        // Start UD-0715 28Apr15 JohnD - start date and activation date must follow from its associated order line item
        //START UD-2340 Wenjun 14 Oct: Set Contract Effective Date to one day before if start date is 1st day of the month for recurring prepaid
        //This is to make sure usage can be processed correctly
        if(itemObj.Main_Package_Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_PRE && itemObj.Start_Date__c.day() == 1)
            q1.zqu__StartDate__c                    = itemObj.Start_Date__c.addDays(-1);
        else
            q1.zqu__StartDate__c                    = itemObj.Start_Date__c;
        
        q1.zqu__TermStartDate__c                    = itemObj.Start_Date__c;
        q1.zqu__Service_Activation_Date__c          = itemObj.Start_Date__c;
        //END UD-2340 Wenjun 14 Oct
        // End UD-0715 28Apr15 JohnD - start date and activation date must follow from its associated order line item
        //End D-1967 01/28/15 Added by April Banaag - revert action; transfer D-1838 logic to SubscriptionTriggerHandler
        //END D-1838 01/23/15 Added by April Banaag
        q1.Acquisition_Type__c                      = orderObj.Acquisition_Type__c;      
        q1.zqu__Account__c                          = orderObj.Account__c;        
        q1.Payment_Mode__c                          = orderObj.Payment_Mode__c; 
        q1.zqu__PaymentMethod__c                    = orderObj.Payment_Mode__c; 
        q1.Other_PaymentMethod__c                   = orderObj.Other_Payment_Mode__c;
        q1.zqu__SoldToContact__c                    = orderObj.Recipient_Contact__c;       
        if(bCreateNewBillingAccount || origin == 'ESHOP Webservice'){
            q1.zqu__BillToContact__c                = orderObj.Billing_Contact__r.Id;   
        }else{
            q1.zqu__ZuoraAccountID__c               = orderObj.Billing_Account_External_ID__c;   
        }
        
        q1.zqu__ElectronicPaymentMethodId__c        = orderObj.Payment_Method_ID__c;  
        q1.Subscription_Type__c                     = sSubType;
        q1.Delivery_Charge_Type__c                  = orderObj.Delivery_Charge_Type__c;
        q1.zqu__ProcessPayment__c                   = false;
        q1.zqu__GenerateInvoice__c                  = false;
        q1.Generate_Invoice1__c                     = false;
        //START: D-2320 02/25/2015 Added by Kristine Campang - added one field for delivery identifier
        q1.Unique_Delivery_Identifier__c           = orderObj.Recipient_Contact__r.Address__r.Address_Unique_Id__c;
        //END: D-2320 02/25/2015 Added by Kristine Campang
        q1.Delivered_By__c                          = itemObj.Delivered_By__c;
        q1.Vendor__c                                = itemObj.Vendor_Mailing_Agent__c;
        q1.Recipient_Contact__c                     = orderObj.Recipient_Contact__c;            
        q1.Order_Number__c                          = orderObj.ID;
        q1.Order__c                                 = orderObj.ID; // Start/End UD-0275 11-03-2015 JohnD
        q1.Order_Line_Item_Number__c                = itemObj.Id;
        q1.Order_Line_Item_Number_1__c              = itemObj.Id;
        q1.Subscriber_Charge__c                     = orderObj.Subscriber_Charge__c;
        //START UD-1271 5/21/15 AddedBy FrancisBenzon : vendor credit will only be calculated for subscription delivered by vendor
        if(itemObj.Delivered_By__c == GlobalVariableClass.VENDOR)
        {
            q1.Vendor_Credit__c                 = orderObj.Vendor_Credit__c;
        }       
        //END UD-1271 5/21/15 AddedBy FrancisBenzon : vendor credit will only be calculated for subscription delivered by vendor
        try{
            Promotion_Package__c proPack = [Select Package_Name__c From Promotion_Package__c
                                            Where Package_Name__c =: itemObj.Main_Package_Id__c LIMIT 1];
            
            if(proPack != null)
            {
                q1.Contract_End_Date__c = itemObj.Contract_End_Date__c; 
                q1.New_Contract_Period__c = itemObj.New_Contract_Period__c;
            }
         }
        catch(Exception e)
        {
            q1.Contract_End_Date__c = null;
            q1.New_Contract_Period__c = null;
        }
        q1.Promotion_Contract_Period__c     = itemObj.Promotion_Contract_Period__c; 
        //START: UD-1319 05/21/2015 Added by Kristine Campang - populates Main Package field of Del Sub with Main Package ID of Order Line Item
        q1.Main_Package__c                      = itemObj.Main_Package_ID__c;
        //END: UD-1319 05/21/2015 Added by Kristine Campang
        return q1;
    }
    //END D-2530 Wenjun 19/03/15
    
    public static zqu__Quote__c createQuotePostage(Order__c orderObj, Order_Line_Item__c itemObj, String sSubType, String origin){
        zqu__Quote__c quote = new zqu__Quote__c ();
        //START D-4603 retrofited by Gio Hotfix by WenJun 29/03/2016
        //quote.Name                                     = 'Postage Charge - ' + itemObj.Main_Package_ID__r.Name;
        quote.Name                                     = 'Postage Charge';
        //END D-4603 retrofited by Gio Hotfix by WenJun 29/03/2016 
        quote.zqu__SubscriptionType__c                 = 'New Subscription';                    
        quote.zqu__ValidUntil__c                       = Date.Today().addMonths(1);
        quote.Qty1__c                                  = itemObj.Qty__c ;
        quote.Term_Length1__c                          = itemObj.Term_Length__c;
        //START D-2031 Wenjun 12/02/15 : Term Setting same as related Publication Subscription
        quote.zqu__Subscription_Term_Type__c           = itemObj.Main_Package_ID__r.Subscription_Type__c;
        //START D-2225 02/23/2015 C. Lin - Fix for Argument cannot be null in Integer.valueOf()
        try{
            //Start D-2390 03/02/15 ABanaag 
                if (itemObj.Main_Package_ID__r.Subscription_Type__c == 'Termed') {
                    try {
                        if(itemObj.Main_Package_ID__r.Billing_Type__c != GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID
                        && itemObj.Term_Length__c!=null){
                            quote.zqu__InitialTerm__c = itemObj.Term_Length__c;
                        }
                        else{
                            quote.zqu__InitialTerm__c = Integer.valueof(itemObj.Main_Package_ID__r.Subscription_Period__c);
                        }
                    } catch(exception e) {
                        quote.zqu__InitialTerm__c = 0;
                    }
                }               
             //End D-2390 03/02/15 ABanaag  
        }
        catch(Exception e){
            //"N/A"; set to null
            quote.zqu__InitialTerm__c = null;
        }
        //END D-2225 02/23/2015 C. Lin
        quote.zqu__RenewalTerm__c                      = 0;
        //END D-2031 Wenjun 12/02/15
        quote.zqu__Currency__c                         = CURRENCY_SGD;
        quote.zqu__InvoiceProcessingOption__c          = INVOICE_PROC_OPTION;
        //Start D-1610 Added by FrancisBenzon 1/26/2015 : Value of Payment Term wrt Dbt Management Treatment
        if(orderObj.Debt_Management_Treatment__c == GlobalVariableClass.SUBL) {
            quote.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_SUBL;
        }
        else if(orderObj.Debt_Management_Treatment__c == GlobalVariableClass.SUBH) {
            quote.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_SUBH;
        }
        else if(orderObj.Debt_Management_Treatment__c == GlobalVariableClass.GOVT) {
            quote.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_GOVT;   
        }
        else {
            quote.zqu__PaymentTerm__c              = GlobalVariableClass.PAYMENT_TERM_NORM;
        }
        //End D-1610 Added by FrancisBenzon 1/26/2015 : Value of Payment Term wrt Dbt Management Treatment
        //START D-1838 01/23/15 Added by April Banaag
        //START D-1967 01/28/15 Added by April Banaag - revert action; transfer D-1838 logic to SubscriptionTriggerHandler
        //START UD-2340 Wenjun 14 Oct: Set Contract Effective Date to one day before if start date is 1st day of the month for recurring prepaid
        //This is to make sure usage can be processed correctly
        if(itemObj.Main_Package_Billing_Type__c == GlobalVariableClass.BILLING_TYPE_MR_PRE && itemObj.Start_Date__c.day() == 1)
            quote.zqu__StartDate__c                    = itemObj.Start_Date__c.addDays(-1);
        else
            quote.zqu__StartDate__c                    = itemObj.Start_Date__c;
        
        quote.zqu__TermStartDate__c                    = itemObj.Start_Date__c;
        quote.zqu__Service_Activation_Date__c          = itemObj.Start_Date__c;
        //END UD-2340 Wenjun 14 Oct
        //END D-1967 01/28/15 Added by April Banaag - revert action; transfer D-1838 logic to SubscriptionTriggerHandler
        //END D-1838 01/23/15 Added by April Banaag
        quote.Acquisition_Type__c                      = orderObj.Acquisition_Type__c;      
        quote.zqu__Account__c                          = orderObj.Account__c;        
        quote.Payment_Mode__c                          = orderObj.Payment_Mode__c; 
        quote.zqu__PaymentMethod__c                    = orderObj.Payment_Mode__c; 
        quote.Other_PaymentMethod__c                   = orderObj.Other_Payment_Mode__c;
        quote.zqu__SoldToContact__c                    = orderObj.Recipient_Contact__c;
        if(bCreateNewBillingAccount || origin == 'ESHOP Webservice'){
            quote.zqu__BillToContact__c                = orderObj.Billing_Contact__r.Id;   
        }else{
            quote.zqu__ZuoraAccountID__c               = orderObj.Billing_Account_External_ID__c;   
        }
        
        quote.zqu__AutoRenew__c                        = itemObj.Auto_Renew__c;
        quote.Charity__c                               = itemObj.Charity__c;
        quote.Delivered_By__c                          = itemObj.Delivered_By__c;
        quote.Vendor__c                                = itemObj.Vendor_Mailing_Agent__c;
        quote.zqu__ElectronicPaymentMethodId__c        = orderObj.Payment_Method_ID__c;
        quote.Recipient_Contact__c                     = orderObj.Recipient_Contact__c;            
        quote.Subscription_Type__c                     = sSubType;
        quote.Order_Number__c                          = orderObj.ID;
        quote.Order_Line_Item_Number__c                = itemObj.Id;
        quote.Order_Line_Item_Number_1__c              = itemObj.Id;
        quote.zqu__ProcessPayment__c                   = false;
        quote.zqu__GenerateInvoice__c                  = false;
        quote.Generate_Invoice1__c                     = false; 
        
        //START: UD-1319 05/21/2015 Added by Kristine Campang - populates Main Package field of Del Sub with Main Package ID of Order Line Item
        quote.Main_Package__c                        = itemObj.Main_Package_ID__c;
        //END: UD-1319 05/21/2015 Added by Kristine Campang
        return quote;
    }
    
    
        

                
                
                
            
            
            
            
            
                
                
            
                
            
            
         
    
    public class DiscountChargeWrapper
    {
        public Integer effectStartMonth {get; set;}
        public Integer duration {get; set;}
        public Date startDate;
        public boolean isNone;//START/END UD-0460 MGaelo - Added isNone to determine if value of picklist is 'N/A'
        
        public DiscountChargeWrapper(Integer int1, Integer int2, Date dateObj, boolean isNone)//START/END UD-0460 MGaelo- added isNone parameter
        {
            this.effectStartMonth = int1; this.duration = int2; this.startDate = dateObj; this.isNone = isNone;//START/END UD-0460 MGaelo - added isNone
        }
    }
    
    //START D-1837 Wenjun 09/02/15 : Store Order Line Gift infor for Quotes
    public class GiftChargeWrapper
    {
        public Decimal dPrice {get; set;}
        public Integer iQuantity {get; set;}
        
        public GiftChargeWrapper(Decimal decimal1, Integer int2)
        {
            this.dPrice = decimal1; this.iQuantity = int2; 
        }
    }
    //END D-1837 Wenjun 09/02/15
}