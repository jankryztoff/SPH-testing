/**
 * History D-2327 27/02/15 Wenjun : Add changes to calculate Package Item Price. Only valid for "Product" Record Type Items. 
       Need Package Item Price for generating Subscription Rate of Bundle Product / Extension Product.
**/

//Issue Note Wenjun: Most of the logic in method processPackageItems and deletePackageItems are duplicated
public class PackagePriceComputation{
    //variable declaration
    List<Package_Item__c> packageItemList;
    Set<Id> packageIdSet;
    List<zqu__ProductRatePlan__c> prodRatePlanList;
    Set<Id> setRatePlan;
    List<zqu__ProductRatePlanCharge__c> prodRatePlanChargeList;
    Decimal sumRCharges;
    Decimal Price;
    String DiscType;
    List<Package__c> packageList;
    Decimal discount;
    String DiscountType;
    List<Package_Item__c> bundleBaseProdList;
    
    //declaration of map variables 
    Map<Id, String> mapPackageToProductFamily;
    Map<Id, Product_Family__c> productFamilyMap;
    Map<Id, List<Package_Item__c>> mapPackageToPackageItem;
    Map<Id, List<zqu__ProductRatePlanCharge__c>> mapRatePlanToRatePlanChargeList;
    Map<Id, zqu__ProductRatePlan__c> mapRateIdToRatePlanRec;
    Map<String, List<Package_Item__c>> mapBundleNumberToPck;
    Map<Id, Decimal> mapPackageToPackagePrice;
    Map<Id, Decimal> mapBasePackToSumRCharges;
    //START: UD-2979 12/7/15 Added by Manolo Valena
    Map<Id, List<Decimal>> mapDiscSinglePckToSumCharge;
    //END: UD-2979 12/7/15 Added by Manolo Valena
    Map<Id, String> mapDiscTypeToPck;
    Map<Id, Decimal> mapDiscSinglePckToDiscount;
    //START: UD-2979 12/7/15 Added by Manolo Valena
    Map<Id, List<Decimal>> mapDiscTieredPckToSumCharges;
    //END: UD-2979 12/7/15 Added by Manolo Valena
    Map<Id, Decimal> mapDiscTieredPckToDiscount;
    //START: UD-2979 12/7/15 Added by Manolo Valena
    Map<Id, List<Decimal>> mapDiscExtnPckToSumCharges;
    //END: UD-2979 12/7/15 Added by Manolo Valena
    Map<Id, Decimal> mapDiscExtnPckToDiscount;
    //START: UD-2979 12/7/15 Added by Manolo Valena
    Map<Id, List<Decimal>> mapAddOnPckToSumCharges;
    //END: UD-2979 12/7/15 Added by Manolo Valena
    Map<Id, Decimal> mapAddOnPckToDiscount;
    Map<String, Decimal> mapBundNumToSumCharge;
    Map<Id, String> mapDiscBundToDiscountType;
    Map<String, Decimal> mapBundNumToDiscount = new Map<String, Decimal>(); //START-END D-4080 12-10-2015 added by Jason A. for code review
    Map<Id, Package__c> mapPackIdToPackRec;
    //START: UD-2979 12/7/15 Added by Manolo Valena
    Map<Id, List<Decimal>> mapBundBaseToSumRCharges;
    //END: UD-2979 12/7/15 Added by Manolo Valena
    Map<Id, Decimal> mapBundDiscToDiscount;
    Map<Id, Id> mapBaseProdToDiscountBund;
    Map<Id, String> mapPackageToBillType;
    Map<Id, String> mapPackageToSubFreq;
    //START D-2327 27/02/15 Wenjun
    Map<Id, Decimal> mapPackItemProdToPrice; 
    Map<Id, Id> mapPackIdToBaseProdId; //Map of Package to Base Product Package Item
    //START: UD-2979 12/7/15 Added by Manolo Valena
    Map<Id, List<Decimal>> mapExtProdToSumRCharges;
    //END: UD-2979 12/7/15 Added by Manolo Valena
    Map<Id, String> mapExtDisToDiscountType;
    Map<Id, Decimal> mapExtDiscToDiscount;
    Map<Id, Package_Item__c> mapPackItems;
    //END D-2327 27/02/15 Wenjun
  
    Set<Id> productFamilyIdSet;

    //START D-0828 1/7/2015 Added By C. Lin - package items id
    Set<Id> setPackItemId;
    //END D-0828 1/7/2015 Added By C. Lin
    public void processPackageItems(List<Package_Item__c> packItemList){
        
        //instantiates variables
        productFamilyMap = new Map<Id, Product_Family__c>();
        mapPackageToProductFamily = new Map<Id,String>();
        packageItemList = new List<Package_Item__c> ();
        packageIdSet = new Set<Id>();
        prodRatePlanList = new List<zqu__ProductRatePlan__c>();
        setRatePlan = new Set<Id>();
        prodRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
        packageList = new List<Package__c>();
        bundleBaseProdList = new List<Package_Item__c>();       
        
        //instantiation of map variables
        mapPackageToPackageItem = new Map<Id, List<Package_Item__c>>();
        mapRatePlanToRatePlanChargeList = new Map<Id, List<zqu__ProductRatePlanCharge__c>>();
        mapRateIdToRatePlanRec = new Map<Id, zqu__ProductRatePlan__c>();
        mapBundleNumberToPck = new Map<String, List<Package_Item__c>>();
        mapPackageToPackagePrice = new Map<Id, Decimal>();
        mapBasePackToSumRCharges = new Map<Id, Decimal>();
        //START: UD-2979 12/7/15 Added by Manolo Valena
        mapDiscSinglePckToSumCharge = new Map<Id, List<Decimal>>();
        //END: UD-2979 12/7/15 Added by Manolo Valena
        mapDiscTypeToPck = new Map<Id, String>();
        mapDiscSinglePckToDiscount = new Map<Id, Decimal>();
        //START: UD-2979 12/7/15 Added by Manolo Valena
        mapDiscTieredPckToSumCharges = new Map<Id, List<Decimal>>();
        //END: UD-2979 12/7/15 Added by Manolo Valena
        mapDiscTieredPckToDiscount = new Map<Id, Decimal>();
        //START: UD-2979 12/7/15 Added by Manolo Valena
        mapDiscExtnPckToSumCharges = new Map<Id, List<Decimal>>();
        //END: UD-2979 12/7/15 Added by Manolo Valena
        mapDiscExtnPckToDiscount = new Map<Id, Decimal>();
        //START: UD-2979 12/7/15 Added by Manolo Valena
        mapAddOnPckToSumCharges = new Map<Id, List<Decimal>>();
        //END: UD-2979 12/7/15 Added by Manolo Valena
        mapAddOnPckToDiscount = new Map<Id, Decimal>();
        mapBundNumToSumCharge = new Map<String, Decimal>();
        mapPackIdToPackRec = new Map<Id, Package__c>();
        //START: UD-2979 12/7/15 Added by Manolo Valena
        mapBundBaseToSumRCharges = new Map<Id, List<Decimal>>();
        //END: UD-2979 12/7/15 Added by Manolo Valena
        mapBundDiscToDiscount = new Map<Id, Decimal>();
        mapBaseProdToDiscountBund = new Map<Id, Id>();
        mapDiscBundToDiscountType = new Map<Id, String>();
        mapPackageToBillType = new Map<Id, String>();
        mapPackageToSubFreq = new Map<Id, String>();
    //START D-2327 27/02/15 Wenjun
    mapPackItemProdToPrice  = new Map<Id, Decimal>();
    mapPackIdToBaseProdId = new Map<Id, Id>();
        //START: UD-2979 12/7/15 Added by Manolo Valena
        mapExtProdToSumRCharges = new Map<Id, List<Decimal>>();
        //END: UD-2979 12/7/15 Added by Manolo Valena
    mapExtDiscToDiscount = new Map<Id, Decimal>();
    mapExtDisToDiscountType = new Map<Id, String>();
    mapPackItems = new Map<Id, Package_Item__c>();
        //Price = 0; //Initialise for each Package to avoid Null Error
    //END D-2327 27/02/15 Wenjun
        
        productFamilyIdSet = new Set<Id>();
        
        //D-0840 - 11-22-2014
        for(Package_Item__c pckItemRec : packItemList){
            packageIdSet.add(pckItemRec.Package__c);
            productFamilyIdSet.add(pckItemRec.Product_Family__c);
        }
        
/*20141126 Playstation D0833 D0840
        productFamilyMap = new Map<Id, Product_Family__c>([SELECT Id, Product_Family_Name__c FROM Product_Family__c WHERE Id IN :productFamilyIdSet]);
*/
    //START:D-1957 1/29/15 Added by Manolo Vale�a - Added the "Product_Family__c" field to the query.
        // START: Code Review Implementation 2/17/2015 JAlejandro
    if (!productFamilyIdSet.isEmpty())
    {
      productFamilyMap = new Map<Id, Product_Family__c>([SELECT Id,
                                                                  Name,
                                  Product_Family__c
                                                           FROM Product_Family__c
                                                           WHERE Id IN :productFamilyIdSet]);
    }// END: Code Review Implementation 2/17/2015 JAlejandro
    //END:D-1957 1/29/15 Added by Manolo Vale�a                           
/*20141126*/
        
        
        for(Package_Item__c pckItemRec : packItemList){
        //D-0972
        
            if(productFamilyMap.containsKey(pckItemRec.Product_Family__c)) {
                Product_Family__c productFamilyRecord = productFamilyMap.get(pckItemRec.Product_Family__c);
            
/*20141126 Playstation D0833 D0840
                mapPackageToProductFamily.put(pckItemRec.Package__c, productFamilyRecord.Product_Family_Name__c);
*/
        //START:D-1957 1/29/15 Added by Manolo Vale�a - Map is now being inputted with the product family code of the Product Family record and not the name.
                mapPackageToProductFamily.put(pckItemRec.Package__c, productFamilyRecord.Product_Family__c);
        //END:D-1957 1/29/15 Added by Manolo Vale�a
/*20141126*/
            }
        }              
        
        /*catch(exception e) {
            mapPackageToProductFamily = new Map<Id,String>();       
        }*/
        
        //query all Package Items under all those Parent records meaning to say all those including the existing ones not just the newly inserted ones
        if(packageIdSet.size()>0){
            packageList = [SELECT Id, Name, Package_Sub_Type__c, Package_Type__c, Package_Price__c
                                            FROM Package__c
                                            WHERE Id IN :packageIdSet];
        }
        
        if(packageList.size()>0){
            for(Package__c packRec : packageList){
                mapPackIdToPackRec.put(packRec.Id, packRec);
                
            }
        }
        //START:D-1957 1/29/15 Added by Manolo Vale�a - Added the "Product_Family2__c" field to the query.
        // START: Code Review Implementation 2/17/2015 JAlejandro
    if (!packageIdSet.isEmpty())
    {
      packageItemList = [SELECT Id, Bundle_Item_No__c, Duration_in_months__c, Effective_Start_Month__c, Price__c,  //START END D-2327 27/02/15 Wenjun : Retrieve Price__c
                 Product_Rate_Plan__c, Product_Rate_Plan__r.BillingType__c, Product_Rate_Plan__r.SubscriptionFrequency__c,
                 Package__c, Package__r.Package_Type__c, Package__r.Package_Sub_Type__c, RecordTypeId,Base_Package_Item__c, Product_Family2__c
                 FROM Package_Item__c
                 WHERE Package__c IN : packageIdSet];
    }        
    // END: Code Review Implementation 2/17/2015 JAlejandro
      //END:D-1957 1/29/15 Added by Manolo Vale�a
        if(packageItemList.size()>0){
            for(Package_Item__c packItemRecAll : packageItemList){
    //maps package to Package Items
    if(mapPackageToPackageItem.containsKey(packItemRecAll.Package__c)){
      mapPackageToPackageItem.get(packItemRecAll.Package__c).add(packItemRecAll);
    }
    else{
      mapPackageToPackageItem.put(packItemRecAll.Package__c, new List<Package_Item__c>{packItemRecAll}); //remember this }is a list ilabas mo na lang kaya yang if sa for?
    }
    //Puts Rate Plans in a set
    if(packItemRecAll.Product_Rate_Plan__c!=null){
      setRatePlan.add(packItemRecAll.Product_Rate_Plan__c);
    }
    mapPackItems.put(packItemRecAll.Id, packItemRecAll); //START END D-2327 27/02/15 Wenjun
            }
        }
        //Queries all Rate Plan Charges related to the Package
        if(setRatePlan.size()>0)
    {
            prodRatePlanList = [SELECT Id, Name, RatePlanSubType__c, RatePlanType__c, BillingType__c, SubscriptionFrequency__c
                                FROM zqu__ProductRatePlan__c
                                WHERE Id IN :setRatePlan];
            for(zqu__ProductRatePlan__c RatePlanRec : prodRatePlanList){
                mapRateIdToRatePlanRec.put(RatePlanRec.Id, RatePlanRec);
            }
      // START: D-1920 1/30/2015 Added by Raviteja kumar - added zqu__ProductRatePlan__r.BillingType__c field in SOQL to get the value in getRatePlanChargesSum() - End 
            prodRatePlanChargeList = [SELECT Id, Name, sum__c, zqu__ProductRatePlan__c,zqu__ProductRatePlan__r.BillingType__c
                                     FROM zqu__ProductRatePlanCharge__c
                                     //START:UD-3290 11/20/15 Added by Manolo Valena
                                     WHERE zqu__ProductRatePlan__c IN :setRatePlan 
                                     AND zqu__Deleted__c = false];
                                     //END:UD-3290 11/20/15 Added by Manolo Valena
        }
        //Maps Product Rate Plan to Product Rate Plan Charges
        if(prodRatePlanChargeList.size()>0){
            for(zqu__ProductRatePlanCharge__c prodRatePlanChargeRec : prodRatePlanChargeList){
                if(mapRatePlanToRatePlanChargeList.containsKey(prodRatePlanChargeRec.zqu__ProductRatePlan__c)){
                        mapRatePlanToRatePlanChargeList.get(prodRatePlanChargeRec.zqu__ProductRatePlan__c).add(prodRatePlanChargeRec);
                        
                    }
                    else{
                        mapRatePlanToRatePlanChargeList.put(prodRatePlanChargeRec.zqu__ProductRatePlan__c, new List<zqu__ProductRatePlanCharge__c> {prodRatePlanChargeRec});
                    }
            }
        }
        //iterates list of Packages and populates maps for computation of PackagePrice
        for(Id PckId : mapPackageToPackageItem.Keyset()){
            Boolean bdiscount;
            Package__c pck = mapPackIdToPackRec.get(PckId);
            List<Package_Item__c> pckItemList = mapPackageToPackageItem.get(pck.Id);
        
            for(Package_Item__c pckitem : pckItemList){
                //start Base Package
                if(pck.Package_Type__c == 'Base'){
                    if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Base Product')){
                        if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
                        {
                            sumRCharges = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                            mapBasePackToSumRCharges.put(pck.Id, sumRCharges);
                        }
                        if (pckitem.Product_Rate_Plan__c <> null) {
                            mapPackageToBillType.put(pck.Id, pckitem.Product_Rate_Plan__r.BillingType__c);
                            mapPackageToSubFreq.put(pck.Id, pckitem.Product_Rate_Plan__r.SubscriptionFrequency__c);
                        }
      mapPackIdToBaseProdId.put(pck.Id, pckitem.Id); //START END D-2327 27/02/15 Wenjun
                    }
                }
                //end Base Package
                //start Discount    
                else if(pck.Package_Type__c == 'Discount'){
                    //start single
                    if(pck.Package_Sub_Type__c == 'Single'){
                        if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Base Product')){
                            if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
                            {
                                //START: UD-2979 12/7/15 Added by Manolo Valena
                                //sumRCharges = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                                //mapDiscSinglePckToSumCharge.put(pck.Id, sumRCharges);
                                //END: UD-2979 12/7/15 Added by Manolo Valena
                                
                                //START: UD-2979 12/7/15 Added by Manolo Valena
                                if(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)[0].zqu__ProductRatePlan__r.BillingType__c != GlobalVariableClass.RECURRING_POSTPAID) {
                                    for(zqu__ProductRatePlanCharge__c prpcRec : mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)) {
                                        if(mapDiscSinglePckToSumCharge.containsKey(pck.Id)) {   
                                            mapDiscSinglePckToSumCharge.get(pck.Id).add(prpcRec.sum__c);
                                        }
                                        else {
                                            mapDiscSinglePckToSumCharge.put(pck.Id, new List<Decimal>{prpcRec.sum__c});
                                        }
                                    }
                                }
                                else {
                                    mapDiscSinglePckToSumCharge.put(pck.Id, new List<Decimal>{null});
                                }
                                //END: UD-2979 12/7/15 Added by Manolo Valena
                            }
                            if (pckitem.Product_Rate_Plan__c <> null) {
                                mapPackageToBillType.put(pck.Id, pckitem.Product_Rate_Plan__r.BillingType__c);
                                mapPackageToSubFreq.put(pck.Id, pckitem.Product_Rate_Plan__r.SubscriptionFrequency__c);
                            }
          mapPackIdToBaseProdId.put(pck.Id, pckitem.Id); //START END D-2327 27/02/15 Wenjun
                        }
                                
                        if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Discount')){
                            DiscountType = mapRateIdToRatePlanRec.get(pckitem.Product_Rate_Plan__c).RatePlanSubType__c;
                            if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
                            {
                                discount = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                                mapDiscSinglePckToDiscount.put(pck.Id,discount);
                            }
                            mapDiscTypeToPck.put(pck.Id, DiscountType);
                        }
                    }
                    //end single
                    //start Tiered
                    else if(pck.Package_Sub_Type__c == 'Tiered'){
            if(pckitem.RecordTypeId== ConstantsSLB.getKeyId('Package Item_Base Product')){
                if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
                {
                  //START: UD-2979 12/7/15 Added by Manolo Valena
                  //sumRCharges = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                  //mapDiscTieredPckToSumCharges.put(pck.Id, sumRCharges);
                  //END: UD-2979 12/7/15 Added by Manolo Valena
                  
                                    //START: UD-2979 12/7/15 Added by Manolo Valena
                                    if(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)[0].zqu__ProductRatePlan__r.BillingType__c != GlobalVariableClass.RECURRING_POSTPAID) {
                                        for(zqu__ProductRatePlanCharge__c prpcRec : mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)) {
                                            if(mapDiscTieredPckToSumCharges.containsKey(pck.Id)) {  
                                                mapDiscTieredPckToSumCharges.get(pck.Id).add(prpcRec.sum__c);
                                            }
                                            else {
                                                mapDiscTieredPckToSumCharges.put(pck.Id, new List<Decimal>{prpcRec.sum__c});
                                            }
                                        }
                                    }
                                    else {
                                        mapDiscTieredPckToSumCharges.put(pck.Id, new List<Decimal>{null});
                                    }
                                    //END: UD-2979 12/7/15 Added by Manolo Valena
                }
                if (pckitem.Product_Rate_Plan__c <> null) {
                  mapPackageToBillType.put(pck.Id, pckitem.Product_Rate_Plan__r.BillingType__c);
                  mapPackageToSubFreq.put(pck.Id, pckitem.Product_Rate_Plan__r.SubscriptionFrequency__c);
                }
                mapPackIdToBaseProdId.put(pck.Id, pckitem.Id); //START END D-2327 27/02/15 Wenjun
            }
              
            if(pckitem.RecordTypeId== ConstantsSLB.getKeyId('Package Item_Discount')){
              if(pckitem.Effective_Start_Month__c =='1'){
                DiscountType = mapRateIdToRatePlanRec.get(pckitem.Product_Rate_Plan__c).RatePlanSubType__c;
                if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c)) {
                  discount = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                  mapDiscTieredPckToDiscount.put(pck.Id, discount);
                }
                mapDiscTypeToPck.put(pck.Id, DiscountType);
              }
            }
                    }
                    //end Tiered
                    //start Extension
                    else if (pck.Package_Sub_Type__c == 'Extension'){
            if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Base Product')){
              if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
              {
                //START: UD-2979 12/7/15 Added by Manolo Valena
                //sumRCharges = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                //mapDiscExtnPckToSumCharges.put(pck.Id, sumRCharges);
                //END: UD-2979 12/7/15 Added by Manolo Valena
                
                                //START: UD-2979 12/7/15 Added by Manolo Valena
                                if(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)[0].zqu__ProductRatePlan__r.BillingType__c != GlobalVariableClass.RECURRING_POSTPAID) {
                                    for(zqu__ProductRatePlanCharge__c prpcRec : mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)) {
                                        if(mapDiscExtnPckToSumCharges.containsKey(pck.Id)) {    
                                            mapDiscExtnPckToSumCharges.get(pck.Id).add(prpcRec.sum__c);
                                        }
                                        else {
                                            mapDiscExtnPckToSumCharges.put(pck.Id, new List<Decimal>{prpcRec.sum__c});
                                        }
                                    }
                                }
                                else {
                                    mapDiscExtnPckToSumCharges.put(pck.Id, new List<Decimal>{null});
                                }
                                //END: UD-2979 12/7/15 Added by Manolo Valena
              }
              if (pckitem.Product_Rate_Plan__c <> null) {
                mapPackageToBillType.put(pck.Id, pckitem.Product_Rate_Plan__r.BillingType__c);
                mapPackageToSubFreq.put(pck.Id, pckitem.Product_Rate_Plan__r.SubscriptionFrequency__c);
              }
            }
            
            if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Discount')){
              DiscountType = mapRateIdToRatePlanRec.get(pckitem.Product_Rate_Plan__c).RatePlanSubType__c;
              if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
              {
                discount = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                mapDiscExtnPckToDiscount.put(pck.Id, discount);
              }
              mapDiscTypeToPck.put(pck.Id, DiscountType);
            }
            
            //START D-2327 27/02/15 Wenjun : Added logic for Extension Product as the discount may not be 100%
            if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Extension Product')){
              if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
              {
                //START: UD-2979 12/7/15 Added by Manolo Valena
                //sumRCharges = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                //mapExtProdToSumRCharges.put(pckitem.Id, sumRCharges);
                //END: UD-2979 12/7/15 Added by Manolo Valena
                
                                //START: UD-2979 12/7/15 Added by Manolo Valena
                                if(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)[0].zqu__ProductRatePlan__r.BillingType__c != GlobalVariableClass.RECURRING_POSTPAID) {
                                    for(zqu__ProductRatePlanCharge__c prpcRec : mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)) {
                                        if(mapExtProdToSumRCharges.containsKey(pckitem.Id)) {   
                                            mapExtProdToSumRCharges.get(pckitem.Id).add(prpcRec.sum__c);
                                        }
                                        else {
                                            mapExtProdToSumRCharges.put(pckitem.Id, new List<Decimal>{prpcRec.sum__c});
                                        }
                                    }
                                }
                                else {
                                    mapExtProdToSumRCharges.put(pckitem.Id, new List<Decimal>{null});
                                }
                                //END: UD-2979 12/7/15 Added by Manolo Valena
              }
            }
            
            if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Extension Discount')){
              if (mapRateIdToRatePlanRec.containsKey(pckitem.Product_Rate_Plan__c))
              {
                discountType = mapRateIdToRatePlanRec.get(pckitem.Product_Rate_Plan__c).RatePlanSubType__c;
                mapExtDisToDiscountType.put(pckitem.Id, discountType);
              }
              if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
              {
                discount = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                mapExtDiscToDiscount.put(pckitem.Id, discount);
              }
            }
            //END D-2327 27/02/15 Wenjun
                    }
                    //end Extension
                }
                //end discount
                //start Add On
                else if(pck.Package_Type__c == 'Add On'){
                    if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Base Product')){
                        if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
                        {
                            //START: UD-2979 12/7/15 Added by Manolo Valena
                            //sumRCharges = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                            //mapAddOnPckToSumCharges.put(pck.Id, sumRCharges);
                            //END: UD-2979 12/7/15 Added by Manolo Valena
                            
                            //START: UD-2979 12/7/15 Added by Manolo Valena
                            if(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)[0].zqu__ProductRatePlan__r.BillingType__c != GlobalVariableClass.RECURRING_POSTPAID) {
                                for(zqu__ProductRatePlanCharge__c prpcRec : mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)) {
                                    if(mapAddOnPckToSumCharges.containsKey(pck.Id)) {   
                                        mapAddOnPckToSumCharges.get(pck.Id).add(prpcRec.sum__c);
                                    }
                                    else {
                                        mapAddOnPckToSumCharges.put(pck.Id, new List<Decimal>{prpcRec.sum__c});
                                    }
                                }
                            }
                            else {
                                mapAddOnPckToSumCharges.put(pck.Id, new List<Decimal>{null});
                            }
                            //END: UD-2979 12/7/15 Added by Manolo Valena
                        }
                        if (pckitem.Product_Rate_Plan__c <> null) {
                            mapPackageToBillType.put(pck.Id, pckitem.Product_Rate_Plan__r.BillingType__c);
                            mapPackageToSubFreq.put(pck.Id, pckitem.Product_Rate_Plan__r.SubscriptionFrequency__c);
                        }
      mapPackIdToBaseProdId.put(pck.Id, pckitem.Id); //START END D-2327 27/02/15 Wenjun
                    }
                    
                    if(pckitem.RecordTypeId== ConstantsSLB.getKeyId('Package Item_Discount')){
                        discountType = mapRateIdToRatePlanRec.get(pckitem.Product_Rate_Plan__c).RatePlanSubType__c;
                        if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
                        {
                            discount = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                            mapAddOnPckToDiscount.put(pck.Id, discount);
                        }
                        mapDiscTypeToPck.put(pck.Id, discountType);
                    }
                }
                //end Add On
                //start bundle
                else if(pck.Package_Type__c == 'Bundle'){
                    if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Bundle Product')){
                        if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
                        {
                            //START: UD-2979 12/7/15 Added by Manolo Valena
                            //sumRCharges = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                            //mapBundBaseToSumRCharges.put(pckitem.Id, sumRCharges);
                            //END: UD-2979 12/7/15 Added by Manolo Valena
                            
                            //START: UD-2979 12/7/15 Added by Manolo Valena
                            if(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)[0].zqu__ProductRatePlan__r.BillingType__c != GlobalVariableClass.RECURRING_POSTPAID) {
                                for(zqu__ProductRatePlanCharge__c prpcRec : mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)) {
                                    if(mapBundBaseToSumRCharges.containsKey(pckitem.Id)) {  
                                        mapBundBaseToSumRCharges.get(pckitem.Id).add(prpcRec.sum__c);
                                    }
                                    else {
                                        mapBundBaseToSumRCharges.put(pckitem.Id, new List<Decimal>{prpcRec.sum__c});
                                    }
                                }
                            }
                            else {
                                mapBundBaseToSumRCharges.put(pckitem.Id, new List<Decimal>{null});
                            }
                            //END: UD-2979 12/7/15 Added by Manolo Valena
                        }
                        bundleBaseProdList.add(pckitem);
                        if (pckitem.Product_Rate_Plan__c <> null) {
                            mapPackageToBillType.put(pck.Id, pckitem.Product_Rate_Plan__r.BillingType__c);
                            mapPackageToSubFreq.put(pck.Id, pckitem.Product_Rate_Plan__r.SubscriptionFrequency__c);
                        }
                    }
                    
                    if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Bundle Discount')){
                        if (mapRateIdToRatePlanRec.containsKey(pckitem.Product_Rate_Plan__c))
                        {
                            discountType = mapRateIdToRatePlanRec.get(pckitem.Product_Rate_Plan__c).RatePlanSubType__c;
                            System.debug(discountType);
                            //create Map of BundNum to Discount Type
                            mapDiscBundToDiscountType.put(pckitem.Id, discountType);
                        }
                        if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
                        {
                            discount = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                            //maps discBund to its discount 
                            mapBundDiscToDiscount.put(pckitem.Id, discount);
                        }
                        
                        //create Map of bund Num and discount
                        mapBaseProdToDiscountBund.put(pckitem.Base_Package_Item__c, pckitem.Id);
                        
                    }
                }
                //end bundle
            } 
        }

        //gets PackagePrice for each packageRec
        for(Id packageRecId : mapPackageToPackageItem.Keyset()){
            Package__c packageRec = mapPackIdToPackRec.get(packageRecId);
      Price = 0.0; //START D-2327 27/02/15 Wenjun : Fix existing NULL Bug
      
            if(packageRec.Package_Type__c == 'Base'){
                Price = mapBasePackToSumRCharges.get(packageRec.Id);
            }
            else if(packageRec.Package_Type__c == 'Discount'){
                if(packageRec.Package_Sub_Type__c == 'Single'){
                    DiscType = mapDiscTypeToPck.get(packageRec.Id);
                    Price = computePackagePrice(DiscType, mapDiscSinglePckToSumCharge.get(packageRec.Id), mapDiscSinglePckToDiscount.get(packageRec.Id));
                }
                else if(packageRec.Package_Sub_Type__c == 'Tiered'){
                    DiscType = mapDiscTypeToPck.get(packageRec.Id);
                    Price = computePackagePrice(DiscType, mapDiscTieredPckToSumCharges.get(packageRec.Id), mapDiscTieredPckToDiscount.get(packageRec.Id));
                }
                else if(packageRec.Package_Sub_Type__c == 'Extension'){
                    DiscType = mapDiscTypeToPck.get(packageRec.Id);
                    Price = computePackagePrice(DiscType, mapDiscExtnPckToSumCharges.get(packageRec.Id), mapDiscExtnPckToDiscount.get(packageRec.Id));
          
          //START D-2327 27/02/15 Wenjun : Calculation for Extension Product Price 
          //START: UD-2979 12/7/15 Added by Manolo Valena
          String extDiscType; List<Decimal> extSumCharges; Decimal extDiscValue; Id baseItemId; Id extItemtId;
          //END: UD-2979 12/7/15 Added by Manolo Valena
          
          for(Package_Item__c pckitem : mapPackageToPackageItem.get(packageRecId))
          {
            if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Base Product'))
              baseItemId = pckitem.Id;
            else if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Extension Product'))
            {
              extItemtId = pckitem.Id;
              if(mapExtProdToSumRCharges.containsKey(pckitem.Id))
                extSumCharges = mapExtProdToSumRCharges.get(pckitem.Id);
            }
            else if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Extension Discount'))
            {
              if(mapExtDisToDiscountType.containsKey(pckitem.Id))
                extDiscType = mapExtDisToDiscountType.get(pckitem.Id);
              if(mapExtDiscToDiscount.containsKey(pckitem.Id))
                extDiscValue = mapExtDiscToDiscount.get(pckitem.Id);
            }
          }
          
          Decimal extensionPrice = computePackagePrice(extDiscType, extSumCharges, extDiscValue);
          if(baseItemId != null && Price != null)
            mapPackItemProdToPrice.put(baseItemId, Price);
          if(extItemtId != null && extensionPrice != null)
            mapPackItemProdToPrice.put(extItemtId, extensionPrice);
          //END D-2327 27/02/15 Wenjun
                }
            }
            else if(packageRec.Package_Type__c == 'Add On'){
                DiscType = mapDiscTypeToPck.get(packageRec.Id);
        //START D-0828 1/27/2015 Added By C. Lin - Changed || to &&. Wrong if statment condition. Always true for the if statement due to ||.
                if(DiscType!='Fixed' && DiscType!='Percentage'){
        //END D-0828 1/27/2015 Added By C. Lin
                    //START: UD-2979 12/7/15 Added by Manolo Valena
                    //Price = mapAddOnPckToSumCharges.get(packageRec.Id);
                    if(mapAddOnPckToSumCharges.get(packageRec.Id)[0] != null) { 
                        for(Decimal pd : mapAddOnPckToSumCharges.get(packageRec.Id)) {
                            Price = Price + pd;
                        }
                    }
                    else {
                        Price = null;
                    }
                    //END: UD-2979 12/7/15 Added by Manolo Valena
                }
                else if(DiscType =='Fixed' || DiscType == 'Percentage'){
                    Price = computePackagePrice(DiscType, mapAddOnPckToSumCharges.get(packageRec.Id), mapAddOnPckToDiscount.get(packageRec.Id));
                } 
            }
            else if(packageRec.Package_Type__c == 'Bundle'){
                Decimal bundPrice = 0;
                for(Package_Item__c pckBund: bundleBaseProdList){
                    //START: UD-2979 12/7/15 Added by Manolo Valena
                    Decimal bundP = 0;
                    //END: UD-2979 12/7/15 Added by Manolo Valena
                    if(mapBaseProdToDiscountBund.containsKey(pckBund.Id)){
                        Id corrDisc = mapBaseProdToDiscountBund.get(pckBund.Id);
                        String BundDiscType = mapDiscBundToDiscountType.get(corrDisc);
                        bundPrice = computePackagePrice(BundDiscType, mapBundBaseToSumRCharges.get(pckBund.Id), mapBundDiscToDiscount.get(corrDisc));
                        System.debug(bundPrice);
                    }
                    else if(!mapBaseProdToDiscountBund.containsKey(pckBund.Id)){
                        //START: UD-2979 12/7/15 Added by Manolo Valena
                        //bundPrice = mapBundBaseToSumRCharges.get(pckBund.Id);
                        if(mapBundBaseToSumRCharges.get(pckBund.Id)[0] != null) {   
                            for(Decimal ds : mapBundBaseToSumRCharges.get(pckBund.Id)) {
                                bundP = bundP + ds;
                            }
                            bundPrice = bundP;
                        }
                        else {
                            bundPrice = null;
                        }
                        //END: UD-2979 12/7/15 Added by Manolo Valena
                    }

          //START: D-0543 12/2/2014 Added by Kristine Campang - to avoid Argument cannot be null error
          if(bundPrice != null){
            Price += bundPrice;
          }
          else{
            bundPrice = 0;
            Price += bundPrice;
          }
          //END D-0543 12/2/2014 Added by Kristine Campang
          mapPackItemProdToPrice.put(pckBund.Id, bundPrice); //START END D-2327 27/02/15 Wenjun
                }

            }
            mapPackageToPackagePrice.put(packageRec.Id, Price);
            System.debug(mapPackageToPackagePrice);
      
      //START D-2327 27/02/15 Wenjun : Base Package Item Price
      if(mapPackIdToBaseProdId.containsKey(packageRec.Id))
      {
        mapPackItemProdToPrice.put(mapPackIdToBaseProdId.get(packageRec.Id), Price);
      }
      //END D-2327 27/02/15 Wenjun
        }
        
        List<Package__c> packageListToBeUpdated = new List<Package__c>();
    //START:D-1957 1/29/15 Added by Manolo Vale�a - Added new variables.
        String container;
        String packType;
        //END:D-1957 1/29/15 Added by Manolo Vale�a
        for(Id pckId : packageIdSet){
                Package__c packRec = mapPackIdToPackRec.get(pckId);
        //START:D-1957 1/29/15 Added by Manolo Vale�a - Added code that updates the "Product Family (Current Package)" field of a Package record.
                for(Package_Item__c packI : mapPackageToPackageItem.get(pckId))
                {
                    packType = packI.Package__r.Package_Type__c;
                    if(packI.Product_Family2__c != null)
                    {
                        if(container == null)
                        {
                            container = packI.Product_Family2__c;
                        }
                        else
                        {
                            container = container + GlobalVariableClass.COMMA + packI.Product_Family2__c;
                        }
                    }
                }
                if(packType.Equals(GlobalVariableClass.PACKAGETYPE_BUNDLE))
                {
                    packRec.Product_Family_Current_Package__c = container;
                }
                else
                {
          //START:D-2077 2/4/15 Added by Manolo Valeña - Added an if-else statement to filter package items with null product family.
          if(mapPackageToProductFamily.get(pckId) != null)
                    {
            packRec.Product_Family_Current_Package__c = mapPackageToProductFamily.get(pckId);
          }
          //END:D-2077 2/4/15 Added by Manolo Valeña
        }
                //END:D-1957 1/29/15 Added by Manolo Vale�a
                packRec.Package_Price__c = mapPackageToPackagePrice.get(packRec.Id);
                if(mapPackageToBillType.get(pckId) != null)
                {
                packRec.Billing_Type__c = mapPackageToBillType.get(pckId);
                }
                packRec.Frequency_Identifier__c = mapPackageToSubFreq.get(pckId);                
                packageListToBeUpdated.add(packRec);
        }
        update packageListToBeUpdated;
    
    //START D-2327 27/02/15 Wenjun : Update affected Package Items
    List<Package_Item__c> lstPackItemsToUpd = new List<Package_Item__c>();
    if(!mapPackItemProdToPrice.isEmpty())
    {
      for(Id itemID : mapPackItemProdToPrice.keySet())
      {
        if(mapPackItems.containsKey(itemID))
        {
          //Update only if Price is changed
          if(mapPackItemProdToPrice.get(itemID) != mapPackItems.get(itemID).Price__c)
          {
            Package_Item__c item = new Package_Item__c(Id =itemID);
            item.Price__c = mapPackItemProdToPrice.get(itemID);
            lstPackItemsToUpd.add(item);
          }
        }
      } //End of For loop
    }

        if(!lstPackItemsToUpd.isEmpty())
      UPDATE lstPackItemsToUpd;
    }   

  //START D-0828 1/7/2015 Added By C. Lin - Recalculates the package price during deletion of a package item
  public void deletePackageItems(List<Package_Item__c> packItemList){
        
        //instantiates variables
        productFamilyMap = new Map<Id, Product_Family__c>();
        mapPackageToProductFamily = new Map<Id,String>();
        packageItemList = new List<Package_Item__c> ();
        packageIdSet = new Set<Id>();
        prodRatePlanList = new List<zqu__ProductRatePlan__c>();
        setRatePlan = new Set<Id>();
        prodRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c>();
        packageList = new List<Package__c>();
        bundleBaseProdList = new List<Package_Item__c>();       
        setPackItemId = new Set<Id>();
    
        //instantiation of map variables
        mapPackageToPackageItem = new Map<Id, List<Package_Item__c>>();
        mapRatePlanToRatePlanChargeList = new Map<Id, List<zqu__ProductRatePlanCharge__c>>();
        mapRateIdToRatePlanRec = new Map<Id, zqu__ProductRatePlan__c>();
        mapBundleNumberToPck = new Map<String, List<Package_Item__c>>();
        mapPackageToPackagePrice = new Map<Id, Decimal>();
        mapBasePackToSumRCharges = new Map<Id, Decimal>();
        //START: UD-2979 12/7/15 Added by Manolo Valena
        mapDiscSinglePckToSumCharge = new Map<Id, List<Decimal>>();
        //END: UD-2979 12/7/15 Added by Manolo Valena
        mapDiscTypeToPck = new Map<Id, String>();
        mapDiscSinglePckToDiscount = new Map<Id, Decimal>();
        //START: UD-2979 12/7/15 Added by Manolo Valena
        mapDiscTieredPckToSumCharges = new Map<Id, List<Decimal>>();
        //END: UD-2979 12/7/15 Added by Manolo Valena
        mapDiscTieredPckToDiscount = new Map<Id, Decimal>();
        //START: UD-2979 12/7/15 Added by Manolo Valena
        mapDiscExtnPckToSumCharges = new Map<Id, List<Decimal>>();
        //END: UD-2979 12/7/15 Added by Manolo Valena
        mapDiscExtnPckToDiscount = new Map<Id, Decimal>();
        //START: UD-2979 12/7/15 Added by Manolo Valena
        mapAddOnPckToSumCharges = new Map<Id, List<Decimal>>();
        //END: UD-2979 12/7/15 Added by Manolo Valena
        mapAddOnPckToDiscount = new Map<Id, Decimal>();
        mapBundNumToSumCharge = new Map<String, Decimal>();
        mapPackIdToPackRec = new Map<Id, Package__c>();
        //START: UD-2979 12/7/15 Added by Manolo Valena
        mapBundBaseToSumRCharges = new Map<Id, List<Decimal>>();
        //END: UD-2979 12/7/15 Added by Manolo Valena
        mapBundDiscToDiscount = new Map<Id, Decimal>();
        mapBaseProdToDiscountBund = new Map<Id, Id>();
        mapDiscBundToDiscountType = new Map<Id, String>();
        mapPackageToBillType = new Map<Id, String>();
        mapPackageToSubFreq = new Map<Id, String>();
        //START D-2327 27/02/15 Wenjun
    mapPackItemProdToPrice  = new Map<Id, Decimal>();
    mapPackIdToBaseProdId = new Map<Id, Id>();
    //START: UD-2979 12/7/15 Added by Manolo Valena
    mapExtProdToSumRCharges = new Map<Id, List<Decimal>>();
    //END: UD-2979 12/7/15 Added by Manolo Valena
    mapExtDiscToDiscount = new Map<Id, Decimal>();
    mapExtDisToDiscountType = new Map<Id, String>();
    mapPackItems = new Map<Id, Package_Item__c>();
        //Price = 0; //Initialise for each Package to avoid Null Error
    //END D-2327 27/02/15 Wenjun
        
        productFamilyIdSet = new Set<Id>();
        
        //D-0840 - 11-22-2014
        for(Package_Item__c pckItemRec : packItemList){
            packageIdSet.add(pckItemRec.Package__c);
            productFamilyIdSet.add(pckItemRec.Product_Family__c);
      setPackItemId.add(pckItemRec.Id);
        }
        //START:D-1957 1/29/15 Added by Manolo Vale�a - Added the "Product_Family__c" field to the query.
        // START: Code Review Implementation 2/17/2015 JAlejandro
    if (!productFamilyIdSet.isEmpty())
    {
      productFamilyMap = new Map<Id, Product_Family__c>([SELECT Id,
                                    Name,
                                    Product_Family__c
                                 FROM Product_Family__c
                                 WHERE Id IN :productFamilyIdSet]);
        // END: Code Review Implementation 2/12/2015 JAlejandro
    //END:D-1957 1/29/15 Added by Manolo Vale�a
        }
        for(Package_Item__c pckItemRec : packItemList){
        //D-0972
        
            if(productFamilyMap.containsKey(pckItemRec.Product_Family__c)) {
                Product_Family__c productFamilyRecord = productFamilyMap.get(pckItemRec.Product_Family__c);
        //START:D-1957 1/29/15 Added by Manolo Vale�a - Value being put in map is now the code of the product family and not it's name.
                mapPackageToProductFamily.put(pckItemRec.Package__c, productFamilyRecord.Product_Family__c);
        //END:D-1957 1/29/15 Added by Manolo Vale�a
            }
        }   
        
        //query all Package Items under all those Parent records meaning to say all those including the existing ones not just the newly inserted ones
        if(packageIdSet.size()>0){
            packageList = [SELECT Id, Name, Package_Sub_Type__c, Package_Type__c, Package_Price__c
                                            FROM Package__c
                                            WHERE Id IN :packageIdSet];
        }
        
        if(packageList.size()>0){
            for(Package__c packRec : packageList){
                mapPackIdToPackRec.put(packRec.Id, packRec);
                
            }
    }
        //START:D-1957 1/29/15 Added by Manolo Vale�a - Added the "Product_Family2__c" field to the query.
        // START: Code Review Implementation 2/17/2015 JAlejandro
    if (!packageIdSet.isEmpty())
    {
    packageItemList = [SELECT Id, Bundle_Item_No__c, Duration_in_months__c, Effective_Start_Month__c, Price__c, //START END D-2327 27/02/15 Wenjun : Retrieve Price__c
                           Product_Rate_Plan__c, Product_Rate_Plan__r.BillingType__c, Product_Rate_Plan__r.SubscriptionFrequency__c,
                           Package__c, Package__r.Package_Type__c, Package__r.Package_Sub_Type__c, RecordTypeId,Base_Package_Item__c, Product_Family2__c
                           FROM Package_Item__c
                           WHERE Package__c IN : packageIdSet AND Id NOT IN : setPackItemId];
    }// END: Code Review Implementation 2/17/2015 JAlejandro
      //END:D-1957 1/29/15 Added by Manolo Vale�a
        if(packageItemList.size()>0){
            
            for(Package_Item__c packItemRecAll : packageItemList){
        //maps package to Package Items
        if(mapPackageToPackageItem.containsKey(packItemRecAll.Package__c)){
          mapPackageToPackageItem.get(packItemRecAll.Package__c).add(packItemRecAll);
        }
        else{
          mapPackageToPackageItem.put(packItemRecAll.Package__c, new List<Package_Item__c>{packItemRecAll}); //remember this }is a list ilabas mo na lang kaya yang if sa for?
        }
        //Puts Rate Plans in a set
        if(packItemRecAll.Product_Rate_Plan__c!=null){
          setRatePlan.add(packItemRecAll.Product_Rate_Plan__c);
        }
        mapPackItems.put(packItemRecAll.Id, packItemRecAll); //START END D-2327 27/02/15 Wenjun
            }
        }
        //Queries all Rate Plan Charges related to the Package
        if(setRatePlan.size()>0){
            prodRatePlanList = [SELECT Id, Name, RatePlanSubType__c, RatePlanType__c, BillingType__c, SubscriptionFrequency__c
                                FROM zqu__ProductRatePlan__c
                                WHERE Id IN :setRatePlan];
            for(zqu__ProductRatePlan__c RatePlanRec : prodRatePlanList){
                mapRateIdToRatePlanRec.put(RatePlanRec.Id, RatePlanRec);
            }
            // START: D-1920 1/30/2015 Added by Raviteja kumar - added zqu__ProductRatePlan__r.BillingType__c field in SOQL to get the value in getRatePlanChargesSum() - End 
         prodRatePlanChargeList = [SELECT Id, Name, sum__c, zqu__ProductRatePlan__c,zqu__ProductRatePlan__r.BillingType__c
                                     FROM zqu__ProductRatePlanCharge__c
                                     //START:UD-3290 11/20/15 Added by Manolo Valena
                                     WHERE zqu__ProductRatePlan__c IN :setRatePlan 
                                     AND zqu__Deleted__c = false];
                                     //END:UD-3290 11/20/15 Added by Manolo Valena
        }
        //Maps Product Rate Plan to Product Rate Plan Charges
        if(prodRatePlanChargeList.size()>0){
            for(zqu__ProductRatePlanCharge__c prodRatePlanChargeRec : prodRatePlanChargeList){
                if(mapRatePlanToRatePlanChargeList.containsKey(prodRatePlanChargeRec.zqu__ProductRatePlan__c)){
                        mapRatePlanToRatePlanChargeList.get(prodRatePlanChargeRec.zqu__ProductRatePlan__c).add(prodRatePlanChargeRec);
                        
                    }
                    else{
                        mapRatePlanToRatePlanChargeList.put(prodRatePlanChargeRec.zqu__ProductRatePlan__c, new List<zqu__ProductRatePlanCharge__c> {prodRatePlanChargeRec});
                    }
            }
        }
        //iterates list of Packages and populates maps for computation of PackagePrice
        for(Id PckId : mapPackageToPackageItem.Keyset()){
            Boolean bdiscount;
            Package__c pck = mapPackIdToPackRec.get(PckId);
            List<Package_Item__c> pckItemList = mapPackageToPackageItem.get(pck.Id);
        
            for(Package_Item__c pckitem : pckItemList){
                //start Base Package
                if(pck.Package_Type__c == 'Base'){
                    if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Base Product')){
                        if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
                        {
                            sumRCharges = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                            mapBasePackToSumRCharges.put(pck.Id, sumRCharges);
                        }
                        if (pckitem.Product_Rate_Plan__c <> null) {
                            mapPackageToBillType.put(pck.Id, pckitem.Product_Rate_Plan__r.BillingType__c);
                            mapPackageToSubFreq.put(pck.Id, pckitem.Product_Rate_Plan__r.SubscriptionFrequency__c);
                        }
            mapPackIdToBaseProdId.put(pck.Id, pckitem.Id); //START END D-2327 27/02/15 Wenjun
                    }
                }
                //end Base Package
                //start Discount    
                else if(pck.Package_Type__c == 'Discount'){
                    //start single
                    if(pck.Package_Sub_Type__c == 'Single'){
                        if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Base Product')){
                            if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
                            {
                                //START: UD-2979 12/7/15 Added by Manolo Valena
                                //sumRCharges = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                                //mapDiscSinglePckToSumCharge.put(pck.Id, sumRCharges);
                                //END: UD-2979 12/7/15 Added by Manolo Valena
                                
                                //START: UD-2979 12/7/15 Added by Manolo Valena
                                if(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)[0].zqu__ProductRatePlan__r.BillingType__c != GlobalVariableClass.RECURRING_POSTPAID) {
                                    for(zqu__ProductRatePlanCharge__c prpcRec : mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)) {
                                        if(mapDiscSinglePckToSumCharge.containsKey(pck.Id)) {   
                                            mapDiscSinglePckToSumCharge.get(pck.Id).add(prpcRec.sum__c);
                                        }
                                        else {
                                            mapDiscSinglePckToSumCharge.put(pck.Id, new List<Decimal>{prpcRec.sum__c});
                                        }
                                    }
                                }
                                else {
                                    mapDiscSinglePckToSumCharge.put(pck.Id, new List<Decimal>{null});
                                }
                                //END: UD-2979 12/7/15 Added by Manolo Valena
                            }
                            if (pckitem.Product_Rate_Plan__c <> null) {
                                mapPackageToBillType.put(pck.Id, pckitem.Product_Rate_Plan__r.BillingType__c);
                                mapPackageToSubFreq.put(pck.Id, pckitem.Product_Rate_Plan__r.SubscriptionFrequency__c);
                            }
              mapPackIdToBaseProdId.put(pck.Id, pckitem.Id); //START END D-2327 27/02/15 Wenjun
                        }
                                
                        if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Discount')){
                            DiscountType = mapRateIdToRatePlanRec.get(pckitem.Product_Rate_Plan__c).RatePlanSubType__c;
                            if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
                            {
                                discount = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                                mapDiscSinglePckToDiscount.put(pck.Id,discount);
                            }
                            mapDiscTypeToPck.put(pck.Id, DiscountType);
                        }
                    }
                    //end single
                    //start Tiered
                    else if(pck.Package_Sub_Type__c == 'Tiered'){
                            if(pckitem.RecordTypeId== ConstantsSLB.getKeyId('Package Item_Base Product')){
                if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
                {
                  //START: UD-2979 12/7/15 Added by Manolo Valena   
                  //sumRCharges = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                  //mapDiscTieredPckToSumCharges.put(pck.Id, sumRCharges);
                  //END: UD-2979 12/7/15 Added by Manolo Valena
                  
                                    //START: UD-2979 12/7/15 Added by Manolo Valena
                                    if(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)[0].zqu__ProductRatePlan__r.BillingType__c != GlobalVariableClass.RECURRING_POSTPAID) {
                                        for(zqu__ProductRatePlanCharge__c prpcRec : mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)) {
                                            if(mapDiscTieredPckToSumCharges.containsKey(pck.Id)) {  
                                                mapDiscTieredPckToSumCharges.get(pck.Id).add(prpcRec.sum__c);
                                            }
                                            else {
                                                mapDiscTieredPckToSumCharges.put(pck.Id, new List<Decimal>{prpcRec.sum__c});
                                            }
                                        }
                                    }
                                    else {
                                        mapDiscTieredPckToSumCharges.put(pck.Id, new List<Decimal>{null});
                                    }
                                    //END: UD-2979 12/7/15 Added by Manolo Valena
                }
                if (pckitem.Product_Rate_Plan__c <> null) {
                  mapPackageToBillType.put(pck.Id, pckitem.Product_Rate_Plan__r.BillingType__c);
                  mapPackageToSubFreq.put(pck.Id, pckitem.Product_Rate_Plan__r.SubscriptionFrequency__c);
                }
                mapPackIdToBaseProdId.put(pck.Id, pckitem.Id); //START END D-2327 27/02/15 Wenjun
                            }
                                
                            if(pckitem.RecordTypeId== ConstantsSLB.getKeyId('Package Item_Discount')){
                                if(pckitem.Effective_Start_Month__c =='1'){
                                    DiscountType = mapRateIdToRatePlanRec.get(pckitem.Product_Rate_Plan__c).RatePlanSubType__c;
                                    if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c)) {
                                        discount = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                                        mapDiscTieredPckToDiscount.put(pck.Id, discount);
                                    }
                                    mapDiscTypeToPck.put(pck.Id, DiscountType);
                                }
                            }
                    }
                    //end Tiered
                    //start Extension
                    else if (pck.Package_Sub_Type__c == 'Extension'){
            if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Base Product')){
                if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
                {
                  //START: UD-2979 12/7/15 Added by Manolo Valena
                  //sumRCharges = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                  //mapDiscExtnPckToSumCharges.put(pck.Id, sumRCharges);
                  //END: UD-2979 12/7/15 Added by Manolo Valena
                  
                                    //START: UD-2979 12/7/15 Added by Manolo Valena
                                    if(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)[0].zqu__ProductRatePlan__r.BillingType__c != GlobalVariableClass.RECURRING_POSTPAID) {
                                        for(zqu__ProductRatePlanCharge__c prpcRec : mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)) {
                                            if(mapDiscExtnPckToSumCharges.containsKey(pck.Id)) {    
                                                mapDiscExtnPckToSumCharges.get(pck.Id).add(prpcRec.sum__c);
                                            }
                                            else {
                                                mapDiscExtnPckToSumCharges.put(pck.Id, new List<Decimal>{prpcRec.sum__c});
                                            }
                                        }
                                    }
                                    else {
                                        mapDiscExtnPckToSumCharges.put(pck.Id, new List<Decimal>{null});
                                    }
                                    //END: UD-2979 12/7/15 Added by Manolo Valena
                }
                if (pckitem.Product_Rate_Plan__c <> null) {
                  mapPackageToBillType.put(pck.Id, pckitem.Product_Rate_Plan__r.BillingType__c);
                  mapPackageToSubFreq.put(pck.Id, pckitem.Product_Rate_Plan__r.SubscriptionFrequency__c);
                }
            }
            
            if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Discount')){
                DiscountType = mapRateIdToRatePlanRec.get(pckitem.Product_Rate_Plan__c).RatePlanSubType__c;
                if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
                {
                  discount = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                  mapDiscExtnPckToDiscount.put(pck.Id, discount);
                }
                mapDiscTypeToPck.put(pck.Id, DiscountType);
            }
              
            //START D-2327 27/02/15 Wenjun : Added logic for Extension Product as the discount may not be 100%
            if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Extension Product')){
              if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
              {
                //START: UD-2979 12/7/15 Added by Manolo Valena
                //sumRCharges = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                //mapExtProdToSumRCharges.put(pckitem.Id, sumRCharges);
                //END: UD-2979 12/7/15 Added by Manolo Valena
                
                                //START: UD-2979 12/7/15 Added by Manolo Valena
                                if(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)[0].zqu__ProductRatePlan__r.BillingType__c != GlobalVariableClass.RECURRING_POSTPAID) {
                                    for(zqu__ProductRatePlanCharge__c prpcRec : mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)) {
                                        if(mapExtProdToSumRCharges.containsKey(pckitem.Id)) {   
                                            mapExtProdToSumRCharges.get(pckitem.Id).add(prpcRec.sum__c);
                                        }
                                        else {
                                            mapExtProdToSumRCharges.put(pckitem.Id, new List<Decimal>{prpcRec.sum__c});
                                        }
                                    }
                                }
                                else {
                                    mapExtProdToSumRCharges.put(pckitem.Id, new List<Decimal>{null});
                                }
                                //END: UD-2979 12/7/15 Added by Manolo Valena
              }
            }
            
            if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Extension Discount')){
              if (mapRateIdToRatePlanRec.containsKey(pckitem.Product_Rate_Plan__c))
              {
                discountType = mapRateIdToRatePlanRec.get(pckitem.Product_Rate_Plan__c).RatePlanSubType__c;
                mapExtDisToDiscountType.put(pckitem.Id, discountType);
              }
              if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
              {
                discount = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                mapExtDiscToDiscount.put(pckitem.Id, discount);
              }
            }
            //END D-2327 27/02/15 Wenjun
                    }
                    //end Extension
                }
                //end discount
                //start Add On
                else if(pck.Package_Type__c == 'Add On'){
                    if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Base Product')){
                        if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
                        {
                            //START: UD-2979 12/7/15 Added by Manolo Valena
                            //sumRCharges = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                            //mapAddOnPckToSumCharges.put(pck.Id, sumRCharges);
                            //END: UD-2979 12/7/15 Added by Manolo Valena
                            
                            //START: UD-2979 12/7/15 Added by Manolo Valena
                            if(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)[0].zqu__ProductRatePlan__r.BillingType__c != GlobalVariableClass.RECURRING_POSTPAID) {
                                for(zqu__ProductRatePlanCharge__c prpcRec : mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)) {
                                    if(mapAddOnPckToSumCharges.containsKey(pck.Id)) {   
                                        mapAddOnPckToSumCharges.get(pck.Id).add(prpcRec.sum__c);
                                    }
                                    else {
                                        mapAddOnPckToSumCharges.put(pck.Id, new List<Decimal>{prpcRec.sum__c});
                                    }
                                }
                            }
                            else {
                                mapAddOnPckToSumCharges.put(pck.Id, new List<Decimal>{null});
                            }
                            //END: UD-2979 12/7/15 Added by Manolo Valena
                        }
                        if (pckitem.Product_Rate_Plan__c <> null) {
                            mapPackageToBillType.put(pck.Id, pckitem.Product_Rate_Plan__r.BillingType__c);
                            mapPackageToSubFreq.put(pck.Id, pckitem.Product_Rate_Plan__r.SubscriptionFrequency__c);
                        }
            mapPackIdToBaseProdId.put(pck.Id, pckitem.Id); //START END D-2327 27/02/15 Wenjun
                    }
                    
                    if(pckitem.RecordTypeId== ConstantsSLB.getKeyId('Package Item_Discount')){
                        discountType = mapRateIdToRatePlanRec.get(pckitem.Product_Rate_Plan__c).RatePlanSubType__c;
                        if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
                        {
                            discount = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                            mapAddOnPckToDiscount.put(pck.Id, discount);
                        }
                        mapDiscTypeToPck.put(pck.Id, discountType);
                    }
                }
                //end Add On
                //start bundle
                else if(pck.Package_Type__c == 'Bundle'){
                    if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Bundle Product')){
                        if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
                        {
                            //START: UD-2979 12/7/15 Added by Manolo Valena
                            //sumRCharges = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                            //mapBundBaseToSumRCharges.put(pckitem.Id, sumRCharges);
                            //END: UD-2979 12/7/15 Added by Manolo Valena
                            
                            //START: UD-2979 12/7/15 Added by Manolo Valena
                            if(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)[0].zqu__ProductRatePlan__r.BillingType__c != GlobalVariableClass.RECURRING_POSTPAID) {
                                for(zqu__ProductRatePlanCharge__c prpcRec : mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c)) {
                                    if(mapBundBaseToSumRCharges.containsKey(pckitem.Id)) {  
                                        mapBundBaseToSumRCharges.get(pckitem.Id).add(prpcRec.sum__c);
                                    }
                                    else {
                                        mapBundBaseToSumRCharges.put(pckitem.Id, new List<Decimal>{prpcRec.sum__c});
                                    }
                                }
                            }
                            else {
                                mapBundBaseToSumRCharges.put(pckitem.Id, new List<Decimal>{null});
                            }
                            //END: UD-2979 12/7/15 Added by Manolo Valena
                        }
                        bundleBaseProdList.add(pckitem);
                        if (pckitem.Product_Rate_Plan__c <> null) {
                            mapPackageToBillType.put(pck.Id, pckitem.Product_Rate_Plan__r.BillingType__c);
                            mapPackageToSubFreq.put(pck.Id, pckitem.Product_Rate_Plan__r.SubscriptionFrequency__c);
                        }
                    }
                    
                    if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Bundle Discount')){
                        if (mapRateIdToRatePlanRec.containsKey(pckitem.Product_Rate_Plan__c))
                        {
                            discountType = mapRateIdToRatePlanRec.get(pckitem.Product_Rate_Plan__c).RatePlanSubType__c;
                            System.debug(discountType);
                            //create Map of BundNum to Discount Type
                            mapDiscBundToDiscountType.put(pckitem.Id, discountType);
                        }
                        if (mapRatePlanToRatePlanChargeList.containsKey(pckitem.Product_Rate_Plan__c))
                        {
                            discount = getRatePlanChargesSum(mapRatePlanToRatePlanChargeList.get(pckitem.Product_Rate_Plan__c));
                            //maps discBund to its discount 
                            mapBundDiscToDiscount.put(pckitem.Id, discount);
                        }
                        
                        //create Map of bund Num and discount
                        mapBaseProdToDiscountBund.put(pckitem.Base_Package_Item__c, pckitem.Id);
                    }
                }
                //end bundle
            }
        }

        //gets PackagePrice for each packageRec
        for(Id packageRecId : mapPackageToPackageItem.Keyset()){
            Package__c packageRec = mapPackIdToPackRec.get(packageRecId);
      Price = 0.0; //START D-2327 27/02/15 Wenjun : Fix existing NULL Bug
      
            if(packageRec.Package_Type__c == 'Base'){
                Price = mapBasePackToSumRCharges.get(packageRec.Id);
            }
            else if(packageRec.Package_Type__c == 'Discount'){
                if(packageRec.Package_Sub_Type__c == 'Single'){
                    DiscType = mapDiscTypeToPck.get(packageRec.Id);
                    Price = computePackagePrice(DiscType, mapDiscSinglePckToSumCharge.get(packageRec.Id), mapDiscSinglePckToDiscount.get(packageRec.Id));
                }
                else if(packageRec.Package_Sub_Type__c == 'Tiered'){
                    DiscType = mapDiscTypeToPck.get(packageRec.Id);
                    Price = computePackagePrice(DiscType, mapDiscTieredPckToSumCharges.get(packageRec.Id), mapDiscTieredPckToDiscount.get(packageRec.Id));
                }
                else if(packageRec.Package_Sub_Type__c == 'Extension'){
                    DiscType = mapDiscTypeToPck.get(packageRec.Id);
                    Price = computePackagePrice(DiscType, mapDiscExtnPckToSumCharges.get(packageRec.Id), mapDiscExtnPckToDiscount.get(packageRec.Id));
          
          //START D-2327 27/02/15 Wenjun : Calculation for Extension Product Price 
          //START: UD-2979 12/7/15 Added by Manolo Valena
          String extDiscType; List<Decimal> extSumCharges; Decimal extDiscValue; Id baseItemId; Id extItemtId;
          //END: UD-2979 12/7/15 Added by Manolo Valena
          
          for(Package_Item__c pckitem : mapPackageToPackageItem.get(packageRecId))
          {
            if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Base Product'))
              baseItemId = pckitem.Id;
            else if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Extension Product'))
            {
              extItemtId = pckitem.Id;
              if(mapExtProdToSumRCharges.containsKey(pckitem.Id))
                extSumCharges = mapExtProdToSumRCharges.get(pckitem.Id);
            }
            else if(pckitem.RecordTypeId == ConstantsSLB.getKeyId('Package Item_Extension Discount'))
            {
              if(mapExtDisToDiscountType.containsKey(pckitem.Id))
                extDiscType = mapExtDisToDiscountType.get(pckitem.Id);
              if(mapExtDiscToDiscount.containsKey(pckitem.Id))
                extDiscValue = mapExtDiscToDiscount.get(pckitem.Id);
            }
          }
          
          Decimal extensionPrice = computePackagePrice(extDiscType, extSumCharges, extDiscValue);
          if(baseItemId != null && Price != null)
            mapPackItemProdToPrice.put(baseItemId, Price);
          if(extItemtId != null && extensionPrice != null)
            mapPackItemProdToPrice.put(extItemtId, extensionPrice);
          //END D-2327 27/02/15 Wenjun
                }
            }
            else if(packageRec.Package_Type__c == 'Add On'){
                DiscType = mapDiscTypeToPck.get(packageRec.Id);
                if(DiscType!='Fixed' && DiscType!='Percentage'){
                    //START: UD-2979 12/7/15 Added by Manolo Valena
                    //Price = mapAddOnPckToSumCharges.get(packageRec.Id);
                    if(mapAddOnPckToSumCharges.get(packageRec.Id)[0] != null) { 
                        for(Decimal pd : mapAddOnPckToSumCharges.get(packageRec.Id)) {
                            Price = Price + pd;
                        }
                    }
                    else {
                        Price = null;
                    }
                    //END: UD-2979 12/7/15 Added by Manolo Valena
                }
                else if(DiscType =='Fixed' || DiscType == 'Percentage'){
                    Price = computePackagePrice(DiscType, mapAddOnPckToSumCharges.get(packageRec.Id), mapAddOnPckToDiscount.get(packageRec.Id));
                }
            }
            else if(packageRec.Package_Type__c == 'Bundle'){
                Decimal bundPrice = 0;
                for(Package_Item__c pckBund: bundleBaseProdList){
                    //START: UD-2979 12/7/15 Added by Manolo Valena
                    Decimal bundP = 0;
                    //END: UD-2979 12/7/15 Added by Manolo Valena
                    if(mapBaseProdToDiscountBund.containsKey(pckBund.Id)){
                        Id corrDisc = mapBaseProdToDiscountBund.get(pckBund.Id);
                        String BundDiscType = mapDiscBundToDiscountType.get(corrDisc);
                        bundPrice = computePackagePrice(BundDiscType, mapBundBaseToSumRCharges.get(pckBund.Id), mapBundDiscToDiscount.get(corrDisc));
                        System.debug(bundPrice);
                    }
                    else if(!mapBaseProdToDiscountBund.containsKey(pckBund.Id)){
                        //START: UD-2979 12/7/15 Added by Manolo Valena
                        //bundPrice = mapBundBaseToSumRCharges.get(pckBund.Id);
                        if(mapBundBaseToSumRCharges.get(pckBund.Id)[0] != null) {   
                            for(Decimal ds : mapBundBaseToSumRCharges.get(pckBund.Id)) {
                                bundP = bundP + ds;
                            }
                            bundPrice = bundP;
                        }
                        else {
                            bundPrice = null;
                        }
                        //END: UD-2979 12/7/15 Added by Manolo Valena
                    }

                  //START: D-0543 12/2/2014 Added by Kristine Campang - to avoid Argument cannot be null error
          if(bundPrice != null){
            Price += bundPrice;
          }
          else{
            bundPrice = 0;
            Price += bundPrice;
          }
          //END D-0543 12/2/2014 Added by Kristine Campang
          mapPackItemProdToPrice.put(pckBund.Id, bundPrice); //START END D-2327 27/02/15 Wenjun
                }

            }
            mapPackageToPackagePrice.put(packageRec.Id, Price);
            System.debug(mapPackageToPackagePrice);
      
            //START D-2327 27/02/15 Wenjun : Base Package Item Price
      if(mapPackIdToBaseProdId.containsKey(packageRec.Id))
      {
        mapPackItemProdToPrice.put(mapPackIdToBaseProdId.get(packageRec.Id), Price);
      }
      //END D-2327 27/02/15 Wenjun
        }
        
        List<Package__c> packageListToBeUpdated = new List<Package__c>();
    //START:D-1957 1/29/15 Added by Manolo Vale�a - Added new variables.
        String container;
        String packType;
        //END:D-1957 1/29/15 Added by Manolo Vale�a
        for(Id pckId : packageIdSet){
                Package__c packRec = mapPackIdToPackRec.get(pckId);
        //START:D-1957 1/29/15 Added by Manolo Vale�a - Added code that updates the list of product families shown in the "Product Family (Current Package)" field of the Package record.
                if(mapPackageToPackageItem.containsKey(pckId))
                {
                    for(Package_Item__c packI : mapPackageToPackageItem.get(pckId))
                    {
                        packType = packI.Package__r.Package_Type__c;
                        if(packI.Product_Family2__c != null)
                        {
                            if(container == null)
                            {
                                container = packI.Product_Family2__c;
                            }
                            else
                            {
                                container = container + GlobalVariableClass.COMMA + packI.Product_Family2__c;
                            }
                        }
                    }
                }
                else
                {
                    container = GlobalVariableClass.EMPTYSTR;
                    packType = GlobalVariableClass.PACKAGETYPE_BUNDLE;
                }
                if(packType.Equals(GlobalVariableClass.PACKAGETYPE_BUNDLE))
                {
                    packRec.Product_Family_Current_Package__c = container;
                }
                else
                {
          //START:D-2077 2/4/15 Added by Manolo Valeña - Added an if-else statement to filter package items with null product family.
          if(mapPackageToProductFamily.get(pckId) != null)
                    {
            packRec.Product_Family_Current_Package__c = mapPackageToProductFamily.get(pckId);
          }
          //END:D-2077 2/4/15 Added by Manolo Valeña
                }
                //END:D-1957 1/29/15 Added by Manolo Vale�a
                packRec.Package_Price__c = mapPackageToPackagePrice.get(packRec.Id);
                if(mapPackageToBillType.get(pckId) != null)
                {
                packRec.Billing_Type__c = mapPackageToBillType.get(pckId);
                }
                packRec.Frequency_Identifier__c = mapPackageToSubFreq.get(pckId);                
                packageListToBeUpdated.add(packRec);
        }
        update packageListToBeUpdated;
        
    //START D-2327 27/02/15 Wenjun : Update affected Package Items
    List<Package_Item__c> lstPackItemsToUpd = new List<Package_Item__c>();
    if(!mapPackItemProdToPrice.isEmpty())
    {
      for(Id itemID : mapPackItemProdToPrice.keySet())
      {
        if(mapPackItems.containsKey(itemID))
        {
          //Update only if Price is changed
          if(mapPackItemProdToPrice.get(itemID) != mapPackItems.get(itemID).Price__c)
          {
            Package_Item__c item = new Package_Item__c(Id =itemID);
            item.Price__c = mapPackItemProdToPrice.get(itemID);
            lstPackItemsToUpd.add(item);
          }
        }
      } //End of For loop
    }

        if(!lstPackItemsToUpd.isEmpty())
      UPDATE lstPackItemsToUpd;
    //END D-2327 27/02/15 Wenjun 
    }
  //END D-0828 1/7/2015 Added By C. Lin
  
    public Decimal getRatePlanChargesSum(List<zqu__ProductRatePlanCharge__c> prodRatePlanCharList){     
        Decimal baseProdChargesSum = 0;
        if(prodRatePlanCharList.size()>0){
       //START D-1920 1/30/2015 Added by Raviteja Kumar
      /* //START D-1718 1/20/2015 Added by Manolo Valeña
            zqu__ProductRatePlanCharge__c prpCharge = [SELECT zqu__ProductRatePlan__r.BillingType__c 
                                                       FROM zqu__ProductRatePlanCharge__c 
                                                       WHERE Id =: prodRatePlanCharList[0].Id
                                                       LIMIT 1];
            //END D-1718 1/20/2015 Added by Manolo Valeña  */
      
      
       // implemented the same logic for zqu__ProductRatePlanCharge__c  to get the 'zqu__ProductRatePlan__r.BillingType__c' value with out using SOQL 
            String prpChargezquProductRatePlanBillingType = '';
            prpChargezquProductRatePlanBillingType = prodRatePlanCharList[0].zqu__ProductRatePlan__r.BillingType__c;
            //END D-1920 1/30/2015 Added by Raviteja Kumar
      
            for(zqu__ProductRatePlanCharge__c prodRatePlanChargeRec : prodRatePlanCharList){
                //START D-1718 1/20/2015 Added by Manolo Vale�a - Added an if-else statement to check if the billing type of the product rate plan is postpaid. If it is, the value for the baseProdChargesSum variable is Null.
        //START D-1920 1/30/2015 Added by Raviteja Kumar - updated if condition by using string variable, functionality remain same.  - End
        //if(prpCharge.zqu__ProductRatePlan__r.BillingType__c != GlobalVariableClass.RECURRING_POSTPAID)          
        if(prpChargezquProductRatePlanBillingType  != GlobalVariableClass.RECURRING_POSTPAID)
                {
          if(prodRatePlanChargeRec.sum__c!=null){
            baseProdChargesSum += prodRatePlanChargeRec.sum__c;
          }
          else{
            baseProdChargesSum = 0;
          }
        }
        else 
                {
                    baseProdChargesSum = Null;
                }
                //END D-1718 1/20/2015 Added by Manolo Vale�a
            }
        }
        System.debug(baseProdChargesSum);
        return baseProdChargesSum;
            
    }

    //Issue Note Wenjun: the following Discount calculation is not optimized and cannot handle negative Discount
    //START: UD-2979 12/7/15 Added by Manolo Valena - Updated whole method.
    public Decimal computePackagePrice(String discType, List<Decimal> sumCharges, Decimal disc){
        Decimal fPriceT = 0;
        
        if(sumCharges != null) {
            for(Decimal sumCharge : sumCharges) {
                Decimal fPrice = 0; 
                Decimal discDecimal = 0;
                String convDiscount;
            
                //START D-1718 1/20/2015 Added by Manolo Vale�a - Added an if-else statement to check if sumCharges is not equal to null. If it is equal to null, the fPrice variable is given a value of null.
                if(sumCharge != Null) 
                {   
                    if(discType == 'Percentage'){
                        String discStr = String.valueof(disc);
                        Integer discInte = discStr.IndexOf('.');
                        String noDotDisc = discStr.remove('.'); 
                        
                        //START D-2409 4/16/2015 Added by Manolo Valena - Added if-else statement to allow negative Discount.
                        if(disc >= 0) {
                            if(discInte == 2){
                            convDiscount = '0.' + noDotDisc;
                            discDecimal = decimal.valueOf(convDiscount);
                            }
                            else if(discInte == 1){
                                convDiscount = '0.0' + noDotDisc;
                                discDecimal = decimal.valueOf(convDiscount);
                            }
                            else if(discInte == 3){
                                discDecimal = 1;
                            }
                        }
                        else {
                            if(discInte == 3){
                            convDiscount = '-0.' + noDotDisc.remove('-');
                            discDecimal = decimal.valueOf(convDiscount);
                            }
                            else if(discInte == 2){
                                convDiscount = '-0.0' + noDotDisc.remove('-');
                                discDecimal = decimal.valueOf(convDiscount);
                            }
                            else if(discInte == 4){
                                discDecimal = -1;
                            }
                        }
                        if(disc > 100 || disc < -100) {
                            fPrice = sumCharge;
                        }
                        else {
                            fPrice = (sumCharge - (sumCharge * discDecimal).setScale(2, RoundingMode.HALF_UP));
                        }
                        //END D-2409 4/16/2015 Added by Manolo Valena
                    }
                    else if(discType == 'Fixed'){
                        fPrice = sumCharge - disc;
                    }
                    else if(discType == null){
                        fPrice = sumCharge;
                    }
                }
                else 
                {
                    fPrice = Null;
                }
                //END D-1718 1/20/2015 Added by Manolo Vale�a
                
                if(fPrice != null) {
                    fPriceT = fPriceT + fPrice;
                }
                else {
                    fPriceT = null;
                }
            }
        }
        else {
            fPriceT = null;
        }
        return fPriceT;
    }
    //END: UD-2979 12/7/15 Added by Manolo Valena
    
}