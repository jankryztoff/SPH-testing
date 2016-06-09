public class PopulateProductCodeOnCase{

    public static void PopulateProductCode(){

        Set<String> s = new Set<String>();
        for(Zuora__SubscriptionProductCharge__c spc : [SELECT Id, Zuora__ProductSKU__c, Product_Code__c FROM Zuora__SubscriptionProductCharge__c  WHERE Zuora__Subscription__c = 'a0XN0000000atgt']){
            if(spc.Zuora__ProductSKU__c != null){
            s.add(spc.Zuora__ProductSKU__c);                    
            }                
        }
        
        Map<String, zqu__ZProduct__c> mapZprod = new Map<String, zqu__ZProduct__c>();
        for(zqu__ZProduct__c zProd : [SELECT Id, Name, ProductCode__c, zqu__SKU__c FROM zqu__ZProduct__c  WHERE zqu__SKU__c IN :s AND zqu__SKU__c != null]){
            mapZprod.put(zProd.zqu__SKU__c,zProd);
        }               

        List<Zuora__SubscriptionProductCharge__c> subPrCh = new List<Zuora__SubscriptionProductCharge__c>();
        for(Zuora__SubscriptionProductCharge__c spc : [SELECT Id, Zuora__ProductSKU__c, Product_Code__c FROM Zuora__SubscriptionProductCharge__c  WHERE Zuora__Subscription__c = 'a0XN0000000atgt']){
            spc.Product_Code__c = mapZprod.get(spc.Zuora__ProductSKU__c).ProductCode__c;
            subPrCh.add(spc);
        }                  
       update subPrCh; 
    }

}