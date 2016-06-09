/**
 * Class Name: <SubscriptionProductChargeTriggerHandler> 
 * @author: <Karl Wilson  Tan>
 * Date: <8/18/2014>
 * Requirement/Project Name: <SPH>
 * @description<Populate Product Code>
 */
 public class SubscriptionProductChargeTriggerHandler implements TriggerHandlerInterface{
 
 //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    Map<String, zqu__ZProduct__c> mapZprod = new Map<String, zqu__ZProduct__c>();
    Map<Id, Zuora__Subscription__c> mapZSub = new Map<Id, Zuora__Subscription__c>();
    //START: 02/13/2015 D-2210 S.Puli
    //START D-3063 K. Tan/ J.Ledesma 6/5/2015 Code Optimization 
    Map<Id, List<Zuora__SubscriptionProductCharge__c>> subMap = new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();////added
    Map<Id, List<zqu__ProductRatePlanCharge__c>> productRPMap = new Map<Id, List<zqu__ProductRatePlanCharge__c>>();////added
    List<zqu__ProductRatePlanCharge__c> prpcList = new List<zqu__ProductRatePlanCharge__c>();////added
    //END D-3063 K. Tan/ J.Ledesma 6/5/2015 Code Optimization
  //End: 02/13/2015 D-2210 S.Puli 
  
    //START D-2972 05/20/2015 Added by J. Sarion - ZProduct Id Set
    Set<Id> zProductIdSet = new Set<Id>();
    //END D-2972 05/20/2015 Added by J. Sarion - ZProduct Id Set
    
    //Start: UD-1173 James 05/18/2015
    List<zqu__ZProduct__c> ZProductList = new List<zqu__ZProduct__c>();
    List<Product_Publication__c> productPubList = new List<Product_Publication__c>();
    //End: UD-1173 James 05/18/2015
        
    //START D-3332 11/16/15 RReyes
    List<Asia1_Subscription__c> lstAsia1 = new List<Asia1_Subscription__c>(); 
    Map<Id, String> mapSubToProdCode = new Map<Id, String>();
    //END D-3332 11/16/15 RReyes
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !SubscriptionProductChargeTriggerHandler.isBeforeInsertTriggerCalled;
        SubscriptionProductChargeTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !SubscriptionProductChargeTriggerHandler.isBeforeUpdateTriggerCalled;
        SubscriptionProductChargeTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !SubscriptionProductChargeTriggerHandler.isBeforeDeleteTriggerCalled;
        SubscriptionProductChargeTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !SubscriptionProductChargeTriggerHandler.isAfterInsertTriggerCalled;
        SubscriptionProductChargeTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !SubscriptionProductChargeTriggerHandler.isAfterUpdateTriggerCalled;
        SubscriptionProductChargeTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !SubscriptionProductChargeTriggerHandler.isAfterDeleteTriggerCalled;
        SubscriptionProductChargeTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Map<Id, Zuora__Subscription__c> subscriptionMap = new Map<Id, Zuora__Subscription__c>(); // START-END : UD-1618 Jean Cari?o 06/18/2015
    
    public void bulkBefore() {
        Map<Id, List<Zuora__SubscriptionProductCharge__c>> spcMap= new Map<Id, List<Zuora__SubscriptionProductCharge__c>>();
        // START: UD-1618 Jean Cari?o 06/18/2015
        Set<Id> subIdSet = new Set<Id>();
        List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();
        // END: UD-1618 Jean Cari?o 06/18/2015
        Set<String> s = new Set<String>();
        //START: 02/13/2015 D-2210 S.Puli 
        Set<String> RPNSet = new Set<String>();////added
        List<zqu__ProductRatePlan__c> prpList = new List<zqu__ProductRatePlan__c>();////added
        Set<Id> PRPIdSet = new Set<Id>();////added
        //END: 02/13/2015 D-2210 S.Puli 
        //START D-3332 11/16/15 RReyes
         Map<Id, Id> mapOliToSub = new Map<Id, Id>();
         Set<Id> setPkgIds = new Set<Id>();
         Set<Id> setOliIds = new Set<Id>();
         Map<Id, Map<String, String>> mapPkgToProdPF = new Map<Id, Map<String, String>>();
         //lstAsia1 = new List<Asia1_Subscription__c>();
        //END D-3332 11/16/15 RReyes
        if(Trigger.isInsert || Trigger.isUpdate) {
            for(SObject newSpc : trigger.new){
                Zuora__SubscriptionProductCharge__c spc = (Zuora__SubscriptionProductCharge__c)newSpc;
                //Start : 23/06/2015 To populate data into Publication Charge : Arockia Presilda
                if(spcMap.containsKey(spc.Zuora__Subscription__c)) {            
                    spcMap.get(spc.Zuora__Subscription__c).add(spc);
                } else {
                    spcMap.put(spc.Zuora__Subscription__c, new List<Zuora__SubscriptionProductCharge__c>());
                    spcMap.get(spc.Zuora__Subscription__c).add(spc);
                }     
                system.debug('spcMapTrigger : ' + spcMap);
                //End : 23/06/2015 To populate data into Publication Charge : Arockia Presilda
                if(spc.Zuora__ProductSKU__c != null){
                    s.add(spc.Zuora__ProductSKU__c);                    
                    //START: 02/13/2015 D-2210 S.Puli 
                    //////////////////start
                    RPNSet.add(spc.Zuora__RatePlanName__c);////added
                    //START D-3063 K. Tan/ J.Ledesma 6/5/2015 Code Optimization
                    if(subMap.containsKey(spc.Zuora__Subscription__c))
                    {            
                        subMap.get(spc.Zuora__Subscription__c).add(spc);
                    } 
                    else 
                    {
                        subMap.put(spc.Zuora__Subscription__c, new List<Zuora__SubscriptionProductCharge__c>());
                        subMap.get(spc.Zuora__Subscription__c).add(spc);
                    }                
                    //END D-3063 K. Tan/ J.Ledesma 6/5/2015 Code Optimization
                    //END: 02/13/2015 D-2210 S.Puli 
                }
                
                subIdSet.add(spc.Zuora__Subscription__c);    // START-END: UD-1618 Jean Cari?o 06/18/2015
            }
            
            SubscriptionProductChargeHelper.calculatePubCharge(spcMap); //Arockia Presilda : 23/06/2015 To populate data into Publication Charg
            // START: UD-1618 Jean Cari?o 06/18/2015
            subscriptionList = [SELECT id, name, Term_Length__c, Billing_Type__c FROM Zuora__Subscription__c WHERE Id IN: subIdSet];
            for(Zuora__Subscription__c subscription : subscriptionList){
                            subscriptionMap.put(subscription.id, subscription);
            }
            // END: UD-1618 Jean Cari?o 06/18/2015
            //Start: UD-1173 James 05/18/2015
            
            
            //End: UD-1173 James 05/18/2015

        //START D-2327 25/02/15 Wenjun : cater Gift, Delivery and Postage as well
        //START D-3063 K. Tan/ J. Ledesma 6/5/2015 Code Optimization
            for(zqu__ZProduct__c zProd : [SELECT Id, Name, ProductCode__c, zqu__SKU__c 
                    FROM zqu__ZProduct__c  WHERE zqu__SKU__c IN :s]){
         //END D-2327 25/02/15 Wenjun
                //if(zProd.zqu__ProductRatePlan__r.size()>0){
                    mapZprod.put(zProd.zqu__SKU__c,zProd);
                //}
                
        //END D-3063 K. Tan/ J. Ledesma 6/5/2015 Code Optimization
            } 
            //START: 02/13/2015 D-2210 S.Puli 
            //////////////////start
            //START JSUAREZ 2/18/2015 code review: check RPNSet if null
            if(RPNSet.size()>0){
            //END JSUAREZ 2/18/2015 code review: check RPNSet if null
                prpList = [SELECT Id, zqu__ZProduct__r.zqu__SKU__c FROM zqu__ProductRatePlan__c WHERE Name IN : RPNSet AND zqu__ZProduct__r.zqu__SKU__c IN : 

s];
                for(zqu__ProductRatePlan__c prpL : prpList)
                {
                    PRPIdSet.add(prpL.Id);
                }
            }
            //START JSUAREZ 2/18/2015 code review: check PRPIdSet if null
            if(PRPIdSet.size()>0){
            //END JSUAREZ 2/18/2015 code review: check PRPIdSet if null
            prpcList = [SELECT Id, Name, PublicationCode__c, zqu__ProductRatePlan__c, zqu__ProductRatePlan__r.Name, 

zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__c IN : PRPIdSet];
            }
            for(zqu__ProductRatePlanCharge__c prpcL : prpcList)
            {
                if(productRPMap.containsKey(prpcL.zqu__ProductRatePlan__c))
                {
                    productRPMap.get(prpcL.zqu__ProductRatePlan__c).add(prpcL);
                }
                else
                {
                    productRPMap.put(prpcL.zqu__ProductRatePlan__c, new List<zqu__ProductRatePlanCharge__c>());
                    productRPMap.get(prpcL.zqu__ProductRatePlan__c).add(prpcL);
                }
            }
            ////////////////////end
      //END: 02/13/2015 D-2210 S.Puli 
        } 
        //START D-3332 11/16/15 RReyes
        if(Trigger.isInsert) {
            for(SObject newSpc : trigger.new){
                Zuora__SubscriptionProductCharge__c spcRec = (Zuora__SubscriptionProductCharge__c)newSpc;
                if(spcRec.Zuora__Subscription__c != null && (spcRec.Zuora__ProductSKU__c != '' && spcRec.Zuora__ProductSKU__c != null)){
                    if(!mapSubToProdCode.containsKey(spcRec.Zuora__Subscription__c)){
                        if(mapZprod.containsKey(spcRec.Zuora__ProductSKU__c)){
                            mapSubToProdCode.put(spcRec.Zuora__Subscription__c, mapZprod.get(spcRec.Zuora__ProductSKU__c).ProductCode__c);
                        }
                    }
                }
            }
            if(mapSubToProdCode.size() > 0){
                List<Zuora__Subscription__c> lstZSub = [SELECT Order_Line_Item_Number_1__c, Main_Package_1__c FROM Zuora__Subscription__c WHERE Id IN: mapSubToProdCode.keySet() 
                    AND Subscription_Type__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION]; 
                for(Zuora__Subscription__c sub: lstZSub){
                    if(sub.Main_Package_1__c != null){
                        setPkgIds.add(sub.Main_Package_1__c);
                    }
                }
                if(setPkgIds.size() > 0){
                    mapPkgToProdPF = new Map<Id, Map<String, String>>();
                    for(Package_Item__c pItemTemp : [SELECT Product_Rate_Plan__r.Product_Code__c, Product_Platform__c, Package__c FROM Package_Item__c WHERE Package__r.Package_Type__c = 'Bundle' AND Package__c IN: setPkgIds]){
                        if((pItemTemp.Product_Rate_Plan__r.Product_Code__c != null && pItemTemp.Product_Rate_Plan__r.Product_Code__c != '') && (pItemTemp.Product_Platform__c!= null && pItemTemp.Product_Platform__c!= '')){
                            if(mapPkgToProdPF.containsKey(pItemTemp.Package__c)){
                                mapPkgToProdPF.get(pItemTemp.Package__c).put(pItemTemp.Product_Rate_Plan__r.Product_Code__c, pItemTemp.Product_Platform__c);
                            }else{
                                mapPkgToProdPF.put(pItemTemp.Package__c, new Map<String, String>{ pItemTemp.Product_Rate_Plan__r.Product_Code__c => pItemTemp.Product_Platform__c});
                            }
                        }
                    }
                }
                for(Zuora__Subscription__c sub2: lstZSub){
                    if(mapPkgToProdPF.size() > 0){
                        if(sub2.Main_Package_1__c != null){
                            if(mapPkgToProdPF.containsKey(sub2.Main_Package_1__c)){
                                if(mapPkgToProdPF.get(sub2.Main_Package_1__c) != null){
                                    if(mapSubToProdCode.get(sub2.Id)!= null){
                                        if(mapPkgToProdPF.get(sub2.Main_Package_1__c).get(mapSubToProdCode.get(sub2.Id)) == 'All-In-One' 
                                        || mapPkgToProdPF.get(sub2.Main_Package_1__c).get(mapSubToProdCode.get(sub2.Id)) == 'Online' 
                                        || mapPkgToProdPF.get(sub2.Main_Package_1__c).get(mapSubToProdCode.get(sub2.Id)) == 'Smartphone'
                                        || mapPkgToProdPF.get(sub2.Main_Package_1__c).get(mapSubToProdCode.get(sub2.Id)) == 'Tablet'){
                                            mapOliToSub.put(sub2.Order_Line_Item_Number_1__c, sub2.Id);
                                        }
                                    }
                                }
                            
                            }
                        }
                    
                    }
                }
                if(mapOliToSub.size() > 0){
                    lstAsia1 = [SELECT Id, Subscription__c, Order_Line_Item__c FROM Asia1_Subscription__c WHERE Order_Line_Item__c IN :mapOliToSub.keySet()];
                    for(Asia1_Subscription__c asia1 : lstAsia1){
                        asia1.Subscription__c = mapOliToSub.get(asia1.Order_Line_Item__c);
                        //lstAsia1.add(asia1);
                    }
                }
            }
            
        }
        //END D-3332 11/16/15 RReyes    
    }

    public void bulkAfter() {
                                                                              
    }            
          
    public void beforeInsert(SObject so) {
        updateProdutCode(so);
    }
        
    public void beforeUpdate(SObject oldSo, SObject so) {
        updateProdutCode(so);
    }
    
    public void beforeDelete(SObject so) {
        //START Wenjun 10 July: the following codes break every Zuora Amendments Sync
        /*
        //Start UD-1544 Hot Fix 07-07-2015 Marvin/John
        Zuora__SubscriptionProductCharge__c spc = (Zuora__SubscriptionProductCharge__c)so;
        //SPCs with empty Subscription are marked for deletion: i.e. new versions inserted
        if(spc.Zuora__Subscription__c != NULL) 
            spc.addError('Disable Zuora Sync Deletion');
        //END UD-1544 Hot Fix 07-07-2015 Marvin/John
        */
        //END Wenjun 10 July
    }
    
    public void afterInsert(SObject so) {
    
     
    }    

    public void afterUpdate(SObject oldSo, SObject so) {    
    
    }

    public void afterDelete(SObject so) {

    }

    public void andFinally() {     
        try{
            update mapZSub.values();
            //START D-3332 11/15/16 RReyes
            if(lstAsia1.size() > 0){
                update lstAsia1;
            }
            //END D-3332 11/15/16 RReyes
        }
        catch (Exception e){
        
        } 
    }
    
    //START D-2799 23/04/15 Wenjun : Cater new added Dummy Rate Plan Charge
    public void updateProdutCode(SObject so) {
        Zuora__SubscriptionProductCharge__c spc = (Zuora__SubscriptionProductCharge__c)so;         
        if(mapZprod.containsKey(spc.Zuora__ProductSKU__c)){
            //START D-3063 K. Tan/ J.Ledesma 6/5/2015 Code Optimization
            if (mapZprod.containsKey(spc.Zuora__ProductSKU__c)) {
                spc.Product_Code__c = mapZprod.get(spc.Zuora__ProductSKU__c).ProductCode__c;
            }
            
            //START: 02/13/2015 D-2210 S.Puli 
            for(Zuora__SubscriptionProductCharge__c x : subMap.get(spc.Zuora__Subscription__c))
            {
                
                if(x.Zuora__RatePlanName__c == spc.Zuora__RatePlanName__c && x.Zuora__ProductSKU__c == spc.Zuora__ProductSKU__c && x.Name == spc.Name)
                
                {


                    for(zqu__ProductRatePlanCharge__c rec : prpcList)
                    {
                        if(x.Zuora__RatePlanName__c == rec.zqu__ProductRatePlan__r.Name && x.Zuora__ProductSKU__c == 

rec.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c && x.Name == rec.Name)
                        {
                        //END D-3063 K. Tan/ J.Ledesma 6/5/2015 Code Optimization
                                        //Start: UD-1173 James 05/18/2015
                                        if(rec.PublicationCode__c != null){
                                            spc.PublicationCode__c = rec.PublicationCode__c;
                                        }
                                        //End: UD-1173 James 05/18/2015
                        }
                    }
                }
            }
            //END: 02/13/2015 D-2210 S.Puli 
            
            //START D-3139 Bill Run Hotfix Wenjun 12/06/15 : Bypass Discount SPC
            //Bypass update if Delivery Charge is negative or 0 (Dummy Charge)
             if(GlobalVariableClass.DUMMY_CHARGE == spc.Name || GlobalVariableClass.SPC_MODEL_DISCOUNT == spc.Zuora__Model__c)
                return;
            
            Zuora__Subscription__c zSub = new Zuora__Subscription__c(id=spc.Zuora__Subscription__c);
            zSub.Product_Code__c = spc.Product_Code__c;
            
            //START D-2327 26/02/15 Wenjun : Set Gift Subscription Rate
            if(GlobalVariableClass.PRODUCT_CODE_PRMGFT == spc.Product_Code__c)
                zSub.Subscription_Charge__c = spc.Zuora__Price__c * spc.Zuora__Quantity__c;

                    // START: UD-1618 Jean Cari?o 06/18/2015
            if(GlobalVariableClass.PRODUCT_CODE_DELCHG == spc.Product_Code__c){
                    zSub.Subscription_Charge__c = Math.abs(spc.Zuora__Price__c);
                    // START: UD-1618 Jean Cari�o 06/18/2015
                    if(subscriptionMap.containsKey(spc.Zuora__Subscription__c) && subscriptionMap.get(spc.Zuora__Subscription__c) != null 
                       && subscriptionMap.get(spc.Zuora__Subscription__c).Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE 
                       && subscriptionMap.get(spc.Zuora__Subscription__c).Term_Length__c != null)
                    {
                        
                        zSub.Subscription_Charge__c = Math.abs(spc.Zuora__Price__c) * Integer.valueOf(subscriptionMap.get

(spc.Zuora__Subscription__c).Term_Length__c);
                    }
                    // END: UD-1618 Jean Cari�o 06/18/2015
            }
                    // END: UD-1618 Jean Cari?o 06/18/2015
            //END D-2327 26/02/15 Wenjun
            //END D-3139 [Bill Run Hotfix] Wenjun 12/06/15
        
            mapZSub.put(zSub.id, zSub); 
            
            // [JohnD 12/15] CCB-PC
            // encountered error during CCB-PC build test
            // catching error added
            // end CCB-PC
        }
        //END D-2799 23/04/15 Wenjun
    }   
      
 }