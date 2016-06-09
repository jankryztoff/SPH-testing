/*
* Class Name: GiftLetterNTUC
* @author: R.Mayo Date: 11/14/2014
* Requirement/Project Name: SPH
* @description: GiftLetterNTUC controller
*/

public class GiftLetterNTUC{ 

    //START: D-0908 12/02/2014 / R.Mayo
    //add fields
    //START UD-2382 added by dags variable declaration for barcode
    public string barcode{get;set;}    
    //END UD-2382 added by dags variable declaration for barcode
    public final Date DateToday{ get; set; }
    //START: D-1189 01/15/2014 Added by P.Villarica - Add getter and setter variable for Order Line Item
    public final Order_Line_Item_Gift__c OrderLineItemGift{ get; set; }
    //END: D-1189 01/15/2014 Added by P.Villarica
    
    // START : D-1141 2/6/2015 Alyana Navarro
    public Zuora__Subscription__c subscription {get; set;}
    // END : D-1141 2/6/2015
    
    //START: D-2383 02/26/2015 Added by Manolo Valena - Variable for Product Code.
    public String ProductCode { get; set; }
    //END: D-2383 02/26/2015 Added by Manolo Valena
    
    //START: D-2385 02/26/2015 Added by Manolo Valena - Variable for Product Name and Penalty Charge/Penalty Charge Override.
    public String ProductName { get; set; }
    public String PenaltyCharge { get; set; }
    //START: D-2385 02/26/2015 Added by Manolo Valena
    //START UD-2214 24/8/2015 GdelRosario : Added get seters for recpient number and account number
    public String sub_accn {get;set;}
    public String rcpn_accn {get;set;}
    //END UD-2214 24/8/2015 GdelRosario
    //START UD-2993 5/10/2015 Gdelrosario : added for "attention to" and normal recipient 
    public transient String contactName {get;set;}
    public transient String billingContactName {get;set;}
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

    public GiftLetterNTUC() {
        try
        {
            DateToday = Date.Today();            
            
            //START:D-2217 2/13/15 Added by Manolo Valeña - Added Unique Number field to the query. 
            //START: D-2156 02/11/2015 Added by Manolo Valena - Added additional field "Order_Line_Item__r.Promotion_ID__r.Contract_Period__c" in the query.    
            //START: D-1189 01/15/2014 Added by P.Villarica - Query the fields that will be displayed in the PDF       
            OrderLineItemGift = [SELECT Order_Line_Item__c, Order_Line_Item__r.Order__c, Order_Line_Item__r.Order__r.Account__c, 
                                Order_Line_Item__r.Order__r.Recipient_Contact__c, Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__c, 
                                Order_Line_Item__r.Subscription__c, Order_Line_Item__r.Subscription__r.Main_Package_1__c,
                                Order_Line_Item__r.Subscription__r.Main_Package_1__r.Name,
                                Order_Line_Item__r.Subscription__r.Main_Package_1__r.Package_Code__c,
                                Order_Line_Item__r.Subscription__r.Zuora__SubscriptionStartDate__c,
                                Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Postal_Code__c,
                                Order_Line_Item__r.Order__r.Account__r.AccountNumber, 
                                Order_Line_Item__r.Order__r.Account__r.Recipient_Number__c, //START -END UD-2214 Gdelrosario : added for the recipt number
                                Order_Line_Item__r.Order__r.Account__r.Name,
                                //START UD-2993 5/10/2015 : added for query in attention to
                                Order_Line_Item__r.Order__r.Account__r.Attention_To_Care_Of__c,
                                Order_Line_Item__r.Order__r.Billing_Contact__r.Name,
                                        //END UD-2993 5/10/2015 : added for query in attention to
                                        //START D-3722 3/11/2015 Gdelrosario: change of call of address format
                                        //Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.City__r.Country__c,
                                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Section_Code__r.Name,
                                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Department__r.Name,
                                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Company_Code__r.Name,
                                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Location_Code__r.Name,
                                        //END D-3722 3/11/2015 Gdelrosario:change of call of address format
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
                                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Section_Code__r.Section_Name__c,
                                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Department__r.Department_Name__c,
                                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Division_Code__r.Name,
                                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Company_Code__r.Company_Name__c,
                                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Location_Code__r.Location_Name__c,
                                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.City__r.City_Name__c,
                                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Airline_Number__c,
                                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Flight_Number_1__c,
                                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Flight_Number_2__c,
                                        //END  UD-2995 10/5/2015 Gdelrosario : added query for address
                                        Order_Line_Item__r.Main_Package_ID__c, // START-END : D-1141 2/6/2015 Alyana Navarro
                                        Order_Line_Item__r.Promotion_ID__r.Contract_Period__c,
                                        //START: D-2383 02/26/2015 Added by Manolo Valena - Added field to the query.
                                        Unique_Number__c,
                                        Order_Line_Item__r.Main_Package_ID__r.Package_Type__c,
                                //END: D-2383 02/26/2015 Added by Manolo Valena
                                //START: D-2385 02/26/2015 Added by Manolo Valena - Added field to the query.
                                Order_Line_Item__r.Term_Length__c,
                                Order_Line_Item__r.Promotion_ID__r.Penalty_Charge__c,
                                Order_Line_Item__r.Promotion_ID__r.Penalty_Charge_Override__c
                                //END: D-2385 02/26/2015 Added by Manolo Valena
                                FROM Order_Line_Item_Gift__c 
                                WHERE ID =: ApexPages.currentPage().getParameters().get('id')];                             
            //END: D-1189 01/15/2014 Added by P.Villarica
            //END: D-2156 02/11/2015 Added by Manolo Valena 
            //END:D-2217 2/13/15 Added by Manolo Valeña - Added Unique Number field to the query. 

            //START UD-2995 10/5/2015 Gdelrosario : to call the method to format address
            //START D-3722 3/11/2015 Gdelrosario: change of call of address format
            finalAddress = AddressHelper.formatGiftAddress(OrderLineItemGift); 
            //END D-3722 3/11/2015 Gdelrosario:change of call of address format                   
            //END  UD-2995 10/5/2015 Gdelrosario : to call the method to format address
            //START UD-2382 added by dags to show barcode
            For(Attachment e : [SELECT Id, Body FROM Attachment WHERE ParentId = :OrderLineItemGift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Postal_Code__c]) {
                barcode = '/servlet/servlet.FileDownload?file=' + e.Id;
            }
            //END UD-2382 added by dags to show barcode    
            //START: D-2156 02/11/2015 Added by Manolo Valena - Updated "orderLineItemGift" to "OrderLineItemGift" 
            // START : D-1141 2/6/2015 Alyana Navarro
            //START Code Review 2/18/2015 Added By C. Lin - Null in where clause causes full table scans - 100K Record Issue Limit
            if(OrderLineItemGift != null){
                if(OrderLineItemGift.Order_Line_Item__c != null && OrderLineItemGift.Order_Line_Item__r.Main_Package_ID__c != null){
                    //START UD-2214 24/8/2015 GdelRosario : added specific fields in the query
                    // START : UD-2214 10/12/2015 Alyana Navarro
                    subscription = [SELECT id, name, Main_Package_1__r.name, Zuora__SubscriptionStartDate__c, Main_Package_1__r.Package_Code__c,Zuora__CustomerAccount__c, Recipient_Contact__r.Recipient_Number__c, 
                                        Zuora__CustomerAccount__r.Billing_Contact__r.Recipient_Number__c,Zuora__CustomerAccount__r.Billing_Contact__r.Billing_Indicator__c
                                        FROM Zuora__Subscription__c 
                                        WHERE Order_Line_Item_Number_1__c =: OrderLineItemGift.Order_Line_Item__c //START/END D-2302 02/24/15 Kevin Evasco: Replaced Order_Line_Item_Number__c  with Order_Line_Item_Number_1__c
                                        AND Main_Package_1__c =: OrderLineItemGift.Order_Line_Item__r.Main_Package_ID__c 
                                        LIMIT 1];
                    // END : UD-2214 10/12/2015 Alyana Navarro
                    //END UD-2214 24/8/2015 GdelRosario : query
                }
            }

            //START UD-2993 5/10/2015 : added to billing account attention to field 
                contactName = OrderLineItemGift.Order_Line_Item__r.Order__r.Account__r.Attention_To_Care_Of__c; 
                billingContactName = OrderLineItemGift.Order_Line_Item__r.Order__r.Billing_Contact__r.Name;
            //END UD-2993 5/10/2015 : added to billing account attention to field 
            //START UD-2214 Gdelrosario 24/8/2015
                //START UD-2214 Gdelrosario 19/10/2015 : change the sub_accn from recipient number to account number
                //sub_accn =  OrderLineItemGift.Order_Line_Item__r.Order__r.Account__r.Recipient_Number__c;
                sub_accn =  OrderLineItemGift.Order_Line_Item__r.Order__r.Account__r.AccountNumber;
                //END UD-2214 Gdelrosario 19/10/2015 : change the sub_accn from recipient number to account number
            // START : UD-2214 10/12/2015 Alyana Navarro
            rcpn_accn = '';
            if(subscription.Recipient_Contact__r.Recipient_Number__c != null){
                rcpn_accn = String.valueOf(subscription.Recipient_Contact__r.Recipient_Number__c);
            }
            // END : UD-2214 10/12/2015 Alyana Navarro
            //END UD-2214 Gdelrosario 24/8/2015
            //END Code Review 2/18/2015 Added By C. Lin
            // END : D-1141 2/6/2015
            //END: D-2156 02/11/2015 Added by Manolo Valena
            //START: D-2383 02/26/2015 Added by Manolo Valena - Added new logic for serial number shown on upper right corner of the letter.
            //START D-3932 20-Nov-2015 Added By S.Puli
            if(OrderLineItemGift.Order_Line_Item__r.Main_Package_ID__r.Package_Type__c != 'Bundle')
            {
                Package_Item__c PackItemRecord = new Package_Item__c();
                PackItemRecord = [SELECT Id, Name, Product_Rate_Plan__r.Product_Code__c,
                                  //START: D-2385 02/26/2015 Added by Manolo Valena - Added field to the query.
                                  Product_Rate_Plan__r.zqu__ZProduct__r.Name, Package__r.Name
                                  //END: D-2385 02/26/2015 Added by Manolo Valena 
                                  FROM Package_Item__c 
                                  WHERE Package__c =: OrderLineItemGift.Order_Line_Item__r.Main_Package_ID__c 
                                  AND RecordType.Name = 'Base Product' 
                                  LIMIT 1];
                                  
                if(PackItemRecord != null)
                {
                    ProductCode = PackItemRecord.Product_Rate_Plan__r.Product_Code__c + '-';
                    //START: D-2385 02/26/2015 Added by Manolo Valena - Assigns value to ProductName variable.
                    ProductName = PackItemRecord.Package__r.Name;
                    //END: D-2385 02/26/2015 Added by Manolo Valena - Added field to the query.
                }
            }
            else
            {
                List<Package_Item__c> PackItemRecord = new List<Package_Item__c>();
                PackItemRecord = [SELECT Id, Name, Product_Rate_Plan__r.Product_Code__c,
                                  //START: D-2385 02/26/2015 Added by Manolo Valena - Added field to the query.
                                  Product_Rate_Plan__r.zqu__ZProduct__r.Name,Package__r.Name 
                                  //END: D-2385 02/26/2015 Added by Manolo Valena  
                                  FROM Package_Item__c 
                                  WHERE Package__c =: OrderLineItemGift.Order_Line_Item__r.Main_Package_ID__c 
                                  AND RecordType.Name = 'Bundle Product' 
                                  LIMIT 2];
                                  
                if(!PackItemRecord.isEmpty())
                {
                    ProductCode = '';
                    //START: D-2385 02/26/2015 Added by Manolo Valena
                    ProductName = '';
                    //END: D-2385 02/26/2015 Added by Manolo Valena
                    for(Package_Item__c packageItem : PackItemRecord)
                    {
                        ProductCode = ProductCode + packageItem.Product_Rate_Plan__r.Product_Code__c;
                    }
                    ProductCode = ProductCode + '-';
                    
                    //START: D-2385 02/26/2015 Added by Manolo Valena - Formats ProductName string value.
                    if(PackItemRecord.size() == 2)
                    {
                        ProductName = PackItemRecord[0].Package__r.Name;
                    }
                    else if(PackItemRecord.size() == 1)
                    {
                        ProductName = PackItemRecord[0].Package__r.Name;
                    }
                    //END: D-2385 02/26/2015 Added by Manolo Valena
                }
            }
            //END D-3932 20-Nov-2015 Added By S.Puli
            //END: D-2383 02/26/2015 Added by Manolo Valena
            //START: D-2385 02/26/2015 Added by Manolo Valena - Assigns value for the PenaltyCharge variable.
            if(OrderLineItemGift.Order_Line_Item__r.Promotion_ID__r.Penalty_Charge_Override__c != null)
            {
                PenaltyCharge = String.valueOf(OrderLineItemGift.Order_Line_Item__r.Promotion_ID__r.Penalty_Charge_Override__c);
            }
            else
            {
                PenaltyCharge = String.valueOf(OrderLineItemGift.Order_Line_Item__r.Promotion_ID__r.Penalty_Charge__c);
            }
            //END: D-2385 02/26/2015 Added by Manolo Valena
           
            
        }
        catch(Exception e)
        {   
            // START : D-1141 2/6/2015 Alyana Navarro
            system.debug('Error : ' + e);
            // END : D-1141 2/6/2015
        }
    }

}