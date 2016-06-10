/**
* Class Name: <MigrationOLITriggerHandler>
* @authors: <Christopher Camilon>
* Date: <6/25/2015>
* Requirement/Project Name: <SPH>
* @description <Validate>
*/

global class MigrationOLITriggerHandler {

    public void doBeforeInsert(List<Order_Line_Item__c> lstNewOLI)
    {
        
        List<Order_Line_Item__c> updatenewOLIList = new List<Order_Line_Item__c>();    
        for(Order_Line_Item__c newOLI : lstNewOLI)
        {            
            if(newOLI.Order_Line_Item_Legacy_Id__c != null || newOLI.Order_Line_Item_Legacy_Id__c != '')
            {
            
                updatenewOLIList.add(newOLI);
            
            }            
        }
        updNewOLIs(updatenewOLIList);
        
        //START D-4474 03102016 Jessica Palapal - To include Billing type upon creation
        if(!updatenewOLIList.isEmpty())
            updOLI(updatenewOLIList);
       //END D-4474 03102016 Jessica Palapal - To include Billing type upon creation   
    }
    
    public void doBeforeUpdate(List<Order_Line_Item__c> lstNewOLIs, Map<Id, Order_Line_Item__c> mapNewOLIs, List<Order_Line_Item__c> lstOldOLIs, Map<Id, Order_Line_Item__c> mapOldOLIs)
    {
        List<Order_Line_Item__c> OLIupdList = new List<Order_Line_Item__c>();
        for(Order_Line_Item__c oli : lstNewOLIs)
        {
            if(mapOldOLIs.get(oli.Id) != null )
            {
                if(oli.Order_Line_Item_Legacy_Id__c != null)
                {
                    OLIupdList.add(oli);
                }
            }
        }
        if(!OLIupdList.isEmpty())
            updOLI(OLIupdList);
       
    }
    
    private void updNewOLIs(List<Order_Line_Item__c> newOLIlst)
    {
        
        for(Order_Line_Item__c oliNew : newOLIlst)
        {
            oliNew.Asia_1_creation_mode__c = 'Individual';
            oliNew.Ph_d__c = True;
            oliNew.Ph_e__c = True;
        }
               
    }
    
    private void updOLI(List<Order_Line_Item__c> updOLIlst)
    {
        Set<Id> packageIds = new Set<Id>();
        for (Order_Line_Item__c updOLI : updOLIlst)
        {
            if(updOLI.Main_Package_ID__c != null)
            {
                packageIds.add(updOLI.Main_Package_ID__c);
            }
            
        }
        
        //START D-3273 07232015 Christopher Camilon - To include Billing Type from Package
        //Map<Id, Package__c> packageMap = new Map<Id, Package__c>([Select Id, (Select Id, Name, Is_Digital__c, Product_Family__r.Name, Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, Product_Rate_Plan__r.SubscriptionFrequency__c, Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c FROM Package_Items__r WHERE RecordType.DeveloperName like '%Product%' Limit 1), Subscription_Period__c, Package_Price__c, Platform__c, Subscription_Type__c, Package_Type__c From Package__c where Id IN: packageIds]);
        Map<Id, Package__c> packageMap = new Map<Id, Package__c>([Select Id, Billing_Type__c, (Select Id, Name, Is_Digital__c, Product_Family__r.Name, Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, Product_Rate_Plan__r.SubscriptionFrequency__c, Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c FROM Package_Items__r WHERE RecordType.DeveloperName like '%Product%' Limit 1), Subscription_Period__c, Package_Price__c, Platform__c, Subscription_Type__c, Package_Type__c From Package__c where Id IN: packageIds]);
        //END D-3273 07232015 Christopher Camilon - To include Billing Type from Package 
        
        //Map<String, Package_Item__C> packageItemMap = new Map<String, Package_Item__C>();
        //List<Package_Item__C> packageItemList = new List<Package_Item__C>([FROM Package_Item__c where  Package__c in : packageIds and RecordType.Name like : '%Product&']);
        //for(Package_Item__C packageItem : packageItemList)
        //{
            
            //packageItemMap.put(packageItem.Package__c, packageItem);    
            
        //}
        
      
        for (Order_Line_Item__c updOLI : updOLIlst)
        {
                           
           if(updOLI.Main_Package_ID__c != null && packageMap.containsKey(updOLI.Main_Package_ID__c)){
                          
                Package__c mainpackage = packageMap.get(updOLI.Main_Package_ID__c);
                
                //START D-3253 07152015 Christopher Camilon - To update check if fields are populated in Package
                //START D-3248 07152015 Christopher Camilon - To update check the fields before updating OLI field
                /*
                if(mainpackage.Subscription_Period__c != null || String.valueof(mainpackage.Subscription_Period__c) != ''){
                    updOLI.Main_Package_Period__c = Integer.valueof(mainpackage.Subscription_Period__c);
                }
                if(mainpackage.Package_Price__c != null || String.valueof(mainpackage.Package_Price__c) != ''){
                    updOLI.Main_Package_Subscription_Rate__c = mainpackage.Package_Price__c;
                }
                if(mainpackage.Subscription_Type__c != null || String.valueof(mainpackage.Subscription_Type__c) != ''){
                    updOLI.Main_Package_Sub_Type__c = mainpackage.Subscription_Type__c;
                }
                if(mainpackage.Package_Type__c != null || String.valueof(mainpackage.Package_Type__c) != ''){
                    updOLI.Main_Package_Type__c = mainpackage.Package_Type__c;
                }
                */
                //END D-3248 07152015 Christopher Camilon - To update check the fields before updating OLI field
               
                //START D-3264 07202015 Christopher Camilon - To check if Subscription Period package is 'N/A'
                /*
                if(mainpackage.Subscription_Period__c != null && String.valueof(mainpackage.Subscription_Period__c) != ''){
                    updOLI.Main_Package_Period__c = Integer.valueof(mainpackage.Subscription_Period__c);
                }
                */
                
                //START D-3266 07212015 Christopher Camilon - To check if Package's fields are null
                
                /*
                if(mainpackage.Subscription_Period__c != null && String.valueof(mainpackage.Subscription_Period__c) != '' && mainpackage.Subscription_Period__c != 'N/A' ){
                    updOLI.Main_Package_Period__c = Integer.valueof(mainpackage.Subscription_Period__c);
                }
                */
                //END D-3266 07212015 Christopher Camilon - To check if Package's fields are null
                
                //END D-3264 07202015 Christopher Camilon - To check if Subscription Period package is 'N/A'
                
                //START D-3266 07212015 Christopher Camilon - To check if Package's fields are null
                /*
                if(mainpackage.Billing_Type__c != null && String.valueof(mainpackage.Billing_Type__c) != ''){
                    String billType = mainpackage.Billing_Type__c;
                    updOLI.Main_Package_Billing_Type__c = billType;   
                }
                
                if(mainpackage.Package_Price__c != null && String.valueof(mainpackage.Package_Price__c) != ''){
                    updOLI.Main_Package_Subscription_Rate__c = mainpackage.Package_Price__c;
                }
                if(mainpackage.Subscription_Type__c != null && String.valueof(mainpackage.Subscription_Type__c) != ''){
                    updOLI.Main_Package_Sub_Type__c = mainpackage.Subscription_Type__c;
                }
                if(mainpackage.Package_Type__c != null && String.valueof(mainpackage.Package_Type__c) != ''){
                    updOLI.Main_Package_Type__c = mainpackage.Package_Type__c;
                }
                //END D-3253 07152015 Christopher Camilon - To update check if fields are populated in Package
                */
                
                
                if(mainpackage.Subscription_Period__c != null && mainpackage.Subscription_Period__c != 'N/A' ){
                    updOLI.Main_Package_Period__c = Integer.valueof(mainpackage.Subscription_Period__c);
                }
                
                
                if(mainpackage.Billing_Type__c != null){
                    String billType = mainpackage.Billing_Type__c;
                    updOLI.Main_Package_Billing_Type__c = billType;   
                }
                
                if(mainpackage.Package_Price__c != null){
                    updOLI.Main_Package_Subscription_Rate__c = mainpackage.Package_Price__c;
                }
                if(mainpackage.Subscription_Type__c != null){
                    updOLI.Main_Package_Sub_Type__c = mainpackage.Subscription_Type__c;
                }
                
                if(mainpackage.Package_Type__c != null){
                    updOLI.Main_Package_Type__c = mainpackage.Package_Type__c;
                }
                //END D-3266 07212015 Christopher Camilon - To check if Package's fields are null
                
                
                updOLI.Main_Package_Product_Family__c = 'Default';
                
                List<Package_Item__c> PackageItemList = mainpackage.Package_Items__r;
                //START D-3325 08052015 Christopher Camilon - To check if there is a related package item
                if(!PackageItemList.isEmpty()){
                    if(PackageItemList[0].Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c == 'All-In-One')
                    {
                        updOLI.Is_All_In_One__c = True;
                    }else{
                        updOLI.Is_All_In_One__c = False;
                    }
                
                    updOLI.Is_Digital__c = PackageItemList[0].Is_Digital__c;
                    updOLI.Main_Package_Product_Platform__c = PackageItemList[0].Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c;
                    updOLI.Main_Package_Product_Sub_Type__c = PackageItemList[0].Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c;
                             
                    String packagefrequency = ConstantsSLB.getProductFrequency(PackageItemList[0].Product_Rate_Plan__r.SubscriptionFrequency__c);
                    if(packagefrequency == 'Default'){
                        updOLI.Main_Package_Frequency__c = 'Default';
                    }
                    else if(packagefrequency == 'Mon - Fri'){
                        updOLI.Main_Package_Frequency__c = 'Mon - Fri';    
                    }else if(packagefrequency == 'Mon - Sat'){
                        updOLI.Main_Package_Frequency__c = 'Mon - Sat';
                    }else if(packagefrequency == 'Sat - Sun'){
                        updOLI.Main_Package_Frequency__c = 'Sat - Sun'; 
                    }else if(packagefrequency == 'Fri - Sun'){
                        updOLI.Main_Package_Frequency__c = 'Fri - Sun';
                    }
                    System.debug('@@@@@@@@@@@' + packagefrequency);
                }
                //END D-3325 08052015 Christopher Camilon - To check if there is a related package item
               
           }
            
      
                
                
                
          }
           
           
        }
            
}