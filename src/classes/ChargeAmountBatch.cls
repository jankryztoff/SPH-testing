global class ChargeAmountBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //String query = 'SELECT Id,Name,Order_Line_Item_Number_1__r.DTL_Date__c,Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c FROM Zuora__Subscription__c';
        String query = 'SELECT Id,Name,Zuora__Subscription__r.Order_Line_Item_Number_1__r.DTL_Date__c,Zuora__Subscription__r.Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c FROM Zuora__SubscriptionProductCharge__c';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Zuora__SubscriptionProductCharge__c> scope)
    {
        //List<Reporting_Subscription__c> RptSubLst = new List<Reporting_Subscription__c>();
        //List<Zuora__SubscriptionProductCharge__c> SPCLst = [SELECT Id,Name,PublicationCode__c, Zuora__ExtendedAmount__c, Zuora__ProductName__c, Zuora__Price__c,Zuora__Quantity__c,Zuora__Subscription__c  FROM Zuora__SubscriptionProductCharge__c where Zuora__Subscription__c  IN: scope];
         for(Zuora__SubscriptionProductCharge__c a : scope)
         {
             a.Charge_Amount__c=a.Zuora__ExtendedAmount__c;
            /*for(Zuora__SubscriptionProductCharge__c SPC : [SELECT Id,Name,PublicationCode__c, Zuora__ExtendedAmount__c, Zuora__ProductName__c, Zuora__Price__c,Zuora__Quantity__c,Zuora__Subscription__c  FROM Zuora__SubscriptionProductCharge__c where Zuora__Subscription__c  IN: scope ])
            {
             if(a.Id == SPC.Zuora__Subscription__c)
             {
             Reporting_Subscription__c RptSub = new Reporting_Subscription__c();
             RptSub.Subscription_Number__c= a.Name;
             RptSub.DTL_Date__c= a.Order_Line_Item_Number_1__r.DTL_Date__c;
             RptSub.Publication_Type__c= a.Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c;
             RptSub.Extended_Amount__c= SPC.Zuora__ExtendedAmount__c;
             RptSub.Price__c= SPC.Zuora__Price__c;
             RptSub.Product_Name__c= SPC.Zuora__ProductName__c;
             RptSub.Publication_Code__c= SPC.PublicationCode__c;
             RptSub.Quantity__c= SPC.Zuora__Quantity__c;
             RptSub.SPC_id__c= SPC.Id;
             RptSub.SPC_name__c= SPC.Name;
             RptSub.Subscription_Number__c= SPC.Zuora__Subscription__c;
             if(SPC.Zuora__ProductName__c == 'Discount' && SPC.Zuora__ExtendedAmount__c != null)    
             {
                 RptSub.Charge__c = (SPC.Zuora__ExtendedAmount__c /SPC.Zuora__Price__c);
             }   
             RptSubLst.add(RptSub); 
             }
            }*/
         }  
         
         //insert RptSubLst;
         update scope;
    }   
  
    global void finish(Database.BatchableContext BC)
    {
    }


}