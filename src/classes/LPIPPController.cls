/**
* Class Name: LPIPPController 
* @author: Alyana Navarro
* Date: 
* Requirement/Project Name: CRSM Project
* @description: Controller for Gift Letter Template
*
* History: 02/10/15 D-2011 Updated to store Contract Period in a variable. Cannot use Subscription List as a merge field as it could potentially cause a VF Page error.
*/ 

public class LPIPPController {
       
      public Date datevalue {get; set;}
      public Order_Line_Item_Gift__c oligift {get; set;}
      public Contact recipientContact {get; set;}
      public Order_Line_Item__c orderLineItem {get; set;}
      public Order__c orderRec {get; set;}
      public Zuora__Subscription__c zuoSub {get; set;}
      public Zuora__Subscription__c zuoSubDel {get; set;}
      public Promotion_Gift__c promoGift {get; set;}      
      public List<Gift_Letter_Batch__c> giftLetBacth {get; set;}
      public Promotion__c promotion {get; set;}
      public String firstlast{get; set;}
      public String blockHouseNum {get; set;}
      public String levelNum {get; set;}
      public String unitNum {get; set;}
      public String buildingName {get;set;}
      public String stName {get; set;}
      public String countryName {get; set;}
      public String postalCode {get; set;}
      public Decimal contractPeriod {get; set;} //START/END 02/10/15 D-2011 Updated to store Contract Period in a variable. Cannot use Subscription List as a merge field as it could potentially cause a VF Page error.
      
      //START UD-2382 added by dags variable declaration for barcode
      public string barcode{get;set;}    
      //END UD-2382 added by dags variable declaration for barcode
      
      //START : D-1189 1/22/2015 Alyana Navarro
      public Zuora__Subscription__c delSubscription {get; set;}
      public List<Zuora__Subscription__c> subscriptionList {get; set;}
      public List<Zuora__Subscription__c> delSubscriptionList = new List<Zuora__Subscription__c>();
      public Gift_Letter_Batch__c giftLetterBatch {get; set;} 
      public string redemptionVenue {get;set;}
      // END : D-1189 1/22/2015
      
      // START : D-1141 2/6/2015 Alyana Navarro
      public Decimal subscriptionCharge {get; set;}
      public Decimal delPostCharge {get; set;}
      // END : D-1141 2/6/2015
      
      //START: D-2383 02/26/2015 Added by Manolo Valena - Variable for Product Code.
      public String ProductCode { get; set; }
      //END: D-2383 02/26/2015 Added by Manolo Valena
      
      //START UD-2449 09/01/15 RReyes
      public Decimal total {get; set;} 
      public Decimal totalSub = 0; 
      //END UD-2449 09/01/15 RReyes

      //START UD-2993 5/10/2015 Gdelrosario : added for "attention to" and normal recipient 
      public String contactName {get;set;}
      //END UD-2993 5/10/2015 Gdelrosario : added for "attention to" and normal recipient 

      //START UD-2995 10/5/2015 Gdelrosario : added variables for address
      public String address1 {get;set;}
      public String address2 {get;set;}
      public String address3 {get;set;}
      public String address4 {get;set;}
      public String address5 {get;set;}
      //END  UD-2995 10/5/2015 Gdelrosario : added variables for address
      //START D-3722 3/11/2015 Gdelrosario: change of call of address format
      public String finalAddress { get; set; }
      //END D-3722 3/11/2015 Gdelrosario: change of call of address format
      public void populateLPPTemplate(){                         
          
          try {
          subscriptionCharge = 0.00;
          delPostCharge = 0.00;
          datevalue = date.Today();
          giftLetBacth = new List<Gift_Letter_Batch__c>();
        // START : D-1189 1/22/2015 Alyana Navarro
          String giftLetterBatchId = ApexPages.currentPage().getParameters().get('giftLetterBatchId');
          String oliGiftId = ApexPages.currentPage().getParameters().get('id');
          
          if (oliGiftId != NULL ) { //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check
          //START:D-2217 2/13/15 Added by Manolo Valeña - Added Unique Number field to the query.
          oligift = [SELECT Id, Order_Line_Item__c,Order_Quantity__c, Gift_ID__c, Gift_Name__c, Gift_ID__r.Name, 
                        //START: D-2383 02/26/2015 Added by Manolo Valena - Added field to the query.
                        Promotion_Gift__c, Gift_ID__r.Gift_Code__c, 
                        Gift_Letter_Batch_Id__c, Unique_Number__c,
                        Order_Line_Item__r.Main_Package_ID__r.Package_Type__c,
                        //END: D-2383 02/26/2015 Added by Manolo Valena
                        //START UD-2993 5/10/2015 : added for query in attention to
                        Order_Line_Item__r.Order__r.Account__r.Attention_To_Care_Of__c,
                        //END UD-2993 5/10/2015 : added for query in attention to
                        //START UD-2995 10/5/2015 Gdelrosario : added query for address
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.recordType.developerName,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Block_House_Number__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Street_Name__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Level_Number__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Unit_Number__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Building_Name__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Country__r.Country_Name__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Address_1__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Address_2__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Address_3__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Address_4__c,
                        //START D-3722 3/11/2015 Gdelrosario: change of call of address format
                        //Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.City__r.Country__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Section_Code__r.Name,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Department__r.Name,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Company_Code__r.Name,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Location_Code__r.Name,
                        //END D-3722 3/11/2015 Gdelrosario:change of call of address format
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Section_Code__r.Section_Name__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Department__r.Department_Name__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Division_Code__r.Name,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Company_Code__r.Company_Name__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Location_Code__r.Location_Name__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.City__r.City_Name__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Airline_Number__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Flight_Number_1__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Flight_Number_2__c
                        //END  UD-2995 10/5/2015 Gdelrosario : added query for address
                   FROM Order_Line_Item_Gift__c
                   WHERE Id = :oliGiftId];
          //END:D-2217 2/13/15 Added by Manolo Valeña
          } //END: Code Review Implementation 2/17/2015 KLorica - Added NULL check
          //START UD-2995 10/5/2015 Gdelrosario : call for method to format address
          //START D-3722 3/11/2015 Gdelrosario: change of call of address format
          finalAddress = AddressHelper.formatGiftAddress(oligift); 
          //END D-3722 3/11/2015 Gdelrosario:change of call of address format
          //END  UD-2995 10/5/2015 Gdelrosario : call for method to format address
          if (oligift.Promotion_Gift__c != NULL) { //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check
          promoGift = [SELECT Id, Promotion__c, Gift_Type__c, Redemption_End_Date__c, Redemption_Letter_Details__c
                       FROM Promotion_Gift__c
                       WHERE Id = :oligift.Promotion_Gift__c];
          } //END: Code Review Implementation 2/17/2015 KLorica - Added NULL check
          if(giftLetterBatchId == null){
            giftLetterBatchId = oligift.Gift_Letter_Batch_Id__c;
          }
          
          giftLetterBatch = [SELECT Id, Redemption_Venue__c FROM Gift_Letter_Batch__c WHERE Id =: giftLetterBatchId ];
          if(giftLetterBatch != null){
              redemptionVenue = giftLetterBatch.Redemption_Venue__c;
          }
          // END : D-1189 1/22/2015
         if (oligift.Gift_ID__r.Gift_Code__c != NULL) { //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check
             try{
                  giftLetBacth = [SELECT Id, Redemption_Venue__c
                                  FROM Gift_Letter_Batch__c
                                  WHERE Gift_Code__c = :oligift.Gift_ID__r.Gift_Code__c];
             }
             catch (Exception e) {
                 System.debug('No gift letter batch has this gift code');
             }
         } //END: Code Review Implementation 2/17/2015 KLorica - Added NULL check
          
          
          if (promoGift.Promotion__c != NULL) { //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check           
          promotion = [SELECT Id, Name, Promotion_Code__c
                       FROM Promotion__c
                       WHERE Id = :promoGift.Promotion__c];
          
          } //END: Code Review Implementation 2/17/2015 KLorica - Added NULL check
          
          if (oligift.Order_Line_Item__c != NULL) { //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check
          //START: D-2385 03/05/2015 Added by Manolo Valena - Added Order__r.Recipient_Contact__r.Address__r.Name and Order__r.Account__c fields to the query.
          orderLineItem = [SELECT Id, Order__c, Main_Package_ID__r.Name, Subscription__c,
                           Order__r.Recipient_Contact__r.Address__r.Name,
                           Order__r.Account__c
                           FROM Order_Line_Item__c
                           WHERE Id = :oligift.Order_Line_Item__c];
          //END: D-2385 03/05/2015 Added by Manolo Valena
          } 
//END: Code Review Implementation 2/17/2015 KLorica - Added NULL check
          
          if (orderLineItem.Order__c != NULL) { //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check
          orderRec = [SELECT Id, Name, Recipient_Contact__r.Address__r.Concatenated_Address_Fields__c, Recipient_Contact__r.FirstName, Recipient_Contact__r.LastName, Recipient_Contact__r.Address__r.Address_1__c,
                      Recipient_Contact__r.Address__r.Block_House_Number__c,  Recipient_Contact__r.Address__r.Postal_Code__r.Building_Name__c, Recipient_Contact__r.Address__r.Postal_Code__r.Name,
                      //START UD-3183 10/30/2015 Gdelrosario : added query for billing contact name
                      Billing_Contact__r.FirstName,
                      Billing_Contact__r.LastName,
                      //END UD-3183 10/30/2015 Gdelrosario : added query for billing contact name
                      //START D-D-4358 25.1.2016 Gdelrosario : added query for billing type
                      Billing_Type__c,
                      //END D-D-4358 25.1.2016 Gdelrosario : added query for billing type
                      Recipient_Contact__r.Address__r.Level_Number__c, Recipient_Contact__r.Address__r.Unit_Number__c, Recipient_Contact__r.Address__r.Country__r.Country_Name__c,Recipient_Contact__r.Address__r.Postal_Code__r.Street_Name__c
                      FROM Order__c
                      WHERE Id =:orderLineItem.Order__c];
          } //END: Code Review Implementation 2/17/2015 KLorica - Added NULL check
        // START : D-1189 1/22/2015 Alyana Navarro
        // START : D-1141 2/6/2015 Alyana Navarro
        if (orderLineItem.id != NULL) { //START: Code Review Implementation 2/17/2015 KLorica - Added NULL check
                //START UD-2449 09/01/15 RReyes - removed Subscription_Type_1__c to reuse query.  just added condition on for loop. added computation of total amount
                subscriptionList = [SELECT id, name, Subscription_Charge__c, Delivery_Charge__c, New_Contract_Period_1__c, Zuora__CustomerAccount__c,
                                    Recipient_Contact__r.Address__r.Name, Subscription_Type_1__c
                                    FROM Zuora__Subscription__c 
                                    WHERE Order_Line_Item_Number_1__c =: orderLineItem.id]; //START/END D-2302 02/24/15 Kevin Evasco: Replaced Order_Line_Item_Number__c  with Order_Line_Item_Number_1__c

                for(Zuora__Subscription__c sub : subscriptionList){
                    if(sub.Subscription_Type_1__c == 'Publication'){
                        if(sub.Subscription_Charge__c != null){
                            subscriptionCharge += sub.Subscription_Charge__c;
                        } else {
                            subscriptionCharge += 0;
                        }
                        contractPeriod = sub.New_Contract_Period_1__c; //START/END 02/10/15 D-2011 Updated to store Contract Period in a variable. Cannot use Subscription List as a merge field as it could potentially cause a VF Page error.
                    }
                    
                    if(sub.Subscription_Charge__c != null){
                        totalSub += sub.Subscription_Charge__c;
                    }
                }
                //END UD-2449 09/01/15 RReyes - removed Subscription_Type_1__c to reuse query.  just added condition on for loop. added computation of total amount
            } //END: Code Review Implementation 2/17/2015 KLorica - Added NULL check
            total = totalSub.setScale(2); //START/END UD-2449 09/01/15 RReyes - sets total to 2 decimal places
          //START: D-2385 03/05/2015 Added by Manolo Valena - Updated where clause to look at the Unique_Delivery_Identifier__c field since the order line item field of delivery subscriptions is not being populated. Also added new where clause to only retrieve subscriptions under the account of the OLIG.
          //START: D-2385 03/04/2015 Added by Manolo Valena - Added the "Subscription_Charge__c" field to the query.
          //START UD-3599 7/1/2015 Gdelrosario : change the initial filter of manolo becuase the field is null in UAT2
          delSubscriptionList = [SELECT id, name, Zuora__CustomerAccount__c, Recipient_Contact__r.Address__r.Name, Subscription_Type_1__c,
                                 Delivery_Charge__c, Order_Line_Item_Number__c, Postage_Charge__c,
                                 Subscription_Charge__c
                                 FROM Zuora__Subscription__c 
                                 WHERE Order_Line_Item_Number_1__c =: orderLineItem.id AND (Subscription_Type_1__c = 'Delivery' //START/END D-2302 02/24/15 Kevin Evasco: Replaced Order_Line_Item_Number__c  with Order_Line_Item_Number_1__c
                                        OR Subscription_Type_1__c = 'Postage') 
                                 AND Zuora__Account__c =: orderLineItem.Order__r.Account__c LIMIT 1];
          //END UD-3599 7/1/2015 Gdelrosario : change the initial filter of manolo becuase the field is null in UAT2
          //END: D-2385 03/04/2015 Added by Manolo Valena
          //END: D-2385 03/05/2015 Added by Manolo Valena     
        if(delSubscriptionList.size() > 0){ 
        //START D-D-4358 25.1.2016 Gdelrosario : added condition for full prepaid 
           if(orderRec.Billing_Type__c == 'Full Prepaid'){
        //END D-D-4358 25.1.2016 Gdelrosario : added condition for full prepaid
              if(delSubscriptionList[0].Subscription_Type_1__c == 'Delivery'){
                //START: D-2385 03/04/2015 Added by Manolo Valena - Updated the condition to check the "Subscription_Charge__c" field instead of the "Delivery_Charge__c" field.
                if(delSubscriptionList[0].Subscription_Charge__c != null){
                    //START: D-2385 03/04/2015 Added by Manolo Valena - Updated the value being assigned to delPostCharge with the "Subscription_Charge__c" field instead of the "Delivery_Charge__c" field.
                    //START UD-3599 7/1/2015 Gdelrosario : divide the delfee with the contract period used
                      delPostCharge = (delSubscriptionList[0].Subscription_Charge__c/contractPeriod).setScale(2);
                    //END UD-3599 7/1/2015 Gdelrosario : divide the delfee with the contract period used
                    //END: D-2385 03/04/2015 Added by Manolo Valena
                }       
                //END: D-2385 03/04/2015 Added by Manolo Valena
            } else if(delSubscriptionList[0].Subscription_Type_1__c == 'Postage'){
                if(delSubscriptionList[0].Postage_Charge__c != null){
                    //START UD-3599 7/1/2015 Gdelrosario : divide the postagefee with the contract period used
                      delPostCharge = (delSubscriptionList[0].Postage_Charge__c/contractPeriod).setScale(2);
                    //END UD-3599 7/1/2015 Gdelrosario : divide the postagefee with the contract period used
                }           
           //START D-4358 25.1.2016 Gdelrosario : added condition for full prepaid              
              }
          
         
           }else{
              if(delSubscriptionList[0].Subscription_Type_1__c == 'Delivery'){                
                  if(delSubscriptionList[0].Subscription_Charge__c != null){
                      delPostCharge = (delSubscriptionList[0].Subscription_Charge__c);
                  }                        
              } else if(delSubscriptionList[0].Subscription_Type_1__c == 'Postage'){
                  if(delSubscriptionList[0].Postage_Charge__c != null){
                      delPostCharge = (delSubscriptionList[0].Postage_Charge__c);
                  }           
              }
           } 
          //END D-D-4358 25.1.2016 Gdelrosario : added condition for full prepaid 
        }
        
        // END : D-1141 2/6/2015
        // END : D-1189 1/22/2015
          //START UD-2993 5/10/2015 : added to billing account attention to field 
          contactName = oligift.Order_Line_Item__r.Order__r.Account__r.Attention_To_Care_Of__c; 
          //END UD-2993 5/10/2015 : added to billing account attention to field 
          //START UD-2787 18/9/2015 : Gdelrosario switch the firstname with the lastname
          //START UD-3183 10/30/2015 Gdelrosario : change query for billing contact name
          firstlast = (orderRec.Billing_Contact__r.FirstName + '          ' + orderRec.Billing_Contact__r.LastName).toUpperCase();
          //END UD-3183 10/30/2015 Gdelrosario : change query for billing contact name    
          //END UD-2787 18/9/2015 : Gdelrosario switch the firstname with the lastname
          /*//START UD-2995 5/10/2015 : Remove this block of codes
          if(orderRec.Recipient_Contact__r.Address__r.Block_House_Number__c != null){
              blockHouseNum = orderRec.Recipient_Contact__r.Address__r.Block_House_Number__c.toUpperCase();
          }
          if(orderRec.Recipient_Contact__r.Address__r.Level_Number__c != null){
              levelNum = orderRec.Recipient_Contact__r.Address__r.Level_Number__c.toUpperCase();
          }
          if(orderRec.Recipient_Contact__r.Address__r.Unit_Number__c != null){
              unitNum = orderRec.Recipient_Contact__r.Address__r.Unit_Number__c.toUpperCase();
          }
          if(orderRec.Recipient_Contact__r.Address__r.Postal_Code__r.Building_Name__c != null){
              buildingName = orderRec.Recipient_Contact__r.Address__r.Postal_Code__r.Building_Name__c.toUpperCase();
          }
          if(orderRec.Recipient_Contact__r.Address__r.Postal_Code__r.Street_Name__c != null){
              stName = orderRec.Recipient_Contact__r.Address__r.Postal_Code__r.Street_Name__c.toUpperCase();
          }
          if(orderRec.Recipient_Contact__r.Address__r.Country__r.Country_Name__c != null){
              countryName = orderRec.Recipient_Contact__r.Address__r.Country__r.Country_Name__c.toUpperCase();
          }
          if(orderRec.Recipient_Contact__r.Address__r.Postal_Code__r.Name != null){
              postalCode = orderRec.Recipient_Contact__r.Address__r.Postal_Code__r.Name.toUpperCase(); 
          }   
          *///End UD-2995 5/10/2015 : Remove this block of codes
            //START UD-2382 added by dags to show barcode
            For(Attachment e : [SELECT Id, Body FROM Attachment WHERE ParentId = :orderRec.Recipient_Contact__r.Address__r.Postal_Code__c]) {
                barcode = '/servlet/servlet.FileDownload?file=' + e.Id;
            }
            //END UD-2382 added by dags to show barcode       

          //START: D-2383 02/26/2015 Added by Manolo Valena - Added new logic for serial number shown on upper right corner of the letter.
          if(oligift.Order_Line_Item__r.Main_Package_ID__r.Package_Type__c != 'Bundle')
          {
              Package_Item__c PackItemRecord = new Package_Item__c();
              PackItemRecord = [SELECT Id, Name, Product_Rate_Plan__r.Product_Code__c 
                                FROM Package_Item__c 
                                WHERE Package__c =: oligift.Order_Line_Item__r.Main_Package_ID__c 
                                AND RecordType.Name = 'Base Product' 
                                LIMIT 1];
                                  
              if(PackItemRecord != null)
              {
                  ProductCode = PackItemRecord.Product_Rate_Plan__r.Product_Code__c + '-';
              }
          }
          else
          {
              List<Package_Item__c> PackItemRecord = new List<Package_Item__c>();
              PackItemRecord = [SELECT Id, Name, Product_Rate_Plan__r.Product_Code__c 
                                FROM Package_Item__c 
                                WHERE Package__c =: oligift.Order_Line_Item__r.Main_Package_ID__c 
                                AND RecordType.Name = 'Bundle Product' 
                                LIMIT 2];
                                  
              if(!PackItemRecord.isEmpty())
              {
                  ProductCode = '';
                  for(Package_Item__c packageItem : PackItemRecord)
                  {
                      ProductCode = ProductCode + packageItem.Product_Rate_Plan__r.Product_Code__c;
                  }
                  ProductCode = ProductCode + '-';
              }
          }
          //END: D-2383 02/26/2015 Added by Manolo Valena 
      }
         catch (Exception e) {
            // START : D-1189 1/22/2015 Alyana Navarro
            system.debug('Error: ' + e.getStackTraceString());
            // END : D-1189 1/22/2015
         }
          
    }
}