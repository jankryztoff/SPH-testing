public class LP_May14GiftLetterController
{        
    public string billingContactName { get; set; }
    public string contactName { get; set; }
    public string contactMailingAddress { get; set; }
    public double paymentAmount { get; set; }
    public date expirationDate { get; set; }
    
    //START:D-2217 2/13/15 Added by Manolo Valeña 
    public Order_Line_Item_Gift__c OrderLineItemGiftVar { get; set; }
    //END:D-2217 2/13/15 Added by Manolo Valeña
    
    // START : D-1189 1/6/2015 Alyana Navarro 
    public String letterDetails {get; set;}
    public string oligId;
    // END : D-1189 1/6/2015
    
    // START : D-1141 2/5/2015 Alyana Navarro
    public String giftLetterBatchId;
    public Gift_Letter_Batch__c giftLetterBatch {get; set;}
    public String mailingCountry {get; set;}
    // END : D-1141 2/5/2015
    
    public string mailingBlk { get; set; }
    public string mailingStreet { get; set; }
    public string mailingLevel { get; set; }
    public string mailingUnit { get; set; }
    public string mailingBuilding { get; set; }
    public string mailingPostalCode { get; set; }
    
    //START UD-2458 added by Dags Variable declaration
    public string redemptionVenue {get;set;}

    //END UD-2458 added by Dags Variable declaration
    public string pubCode { get; set; }
    public string giftName { get; set; }
    public string giftDescription { get; set; }
    public string subAccountNum { get; set; }
    public string recAccountNum { get; set; }
    public string barcode{get;set;} //Start /End UD-2382 Added by Dags due to barcode 
    
    //START: D-2383 02/26/2015 Added by Manolo Valena - Variable for Product Code.
    public String ProductCode { get; set; }
    //END: D-2383 02/26/2015 Added by Manolo Valena
    
    //START: D-2385 02/26/2015 Added by Manolo Valena - Variable for Product Name.
    public String ProductName { get; set; }
    //START: D-2385 02/26/2015 Added by Manolo Valena
    
    //START 04/27/15 UD-0960 and UD-0829 Kevin Evasco - Removed overlapping gift letter batch validation
    public String redemptionStartDate { get; set; }
    public String redemptionEndDate { get; set; }
    //END 04/27/15 UD-0960 and UD-0829 Kevin Evasco - Removed overlapping gift letter batch validation

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

    
    public LP_May14GiftLetterController()
    {   
        //START 04/27/15 UD-0960 and UD-0829 Kevin Evasco - Removed overlapping gift letter batch validation
        try
        {
            oligId = ApexPages.currentPage().getParameters().get('id');
            // START : D-1141 2/6/2015 Alyana Navarro
            giftLetterBatchId = ApexPages.currentPage().getParameters().get('giftLetterBatchId');
            // END : D-1141 2/6/2015
        }catch(Exception e)
        {
            system.debug('Error: ' + e.getStackTraceString());
        }
        //END 04/27/15 UD-0960 and UD-0829 Kevin Evasco - Removed overlapping gift letter batch validation
    }

    public Date Today 
    { 
        get 
        { 
            return Date.Today(); 
        }
    }
    
    public void initialize()
    {        
        //try
        //{
         setFields();
        //}
        //catch(Exception e)
        //{
            // START : D-1189 1/6/2015 Alyana Navarro            
        //    system.debug('Error: ' + e.getStackTraceString());
            // END : D-1189 1/6/2015
        //}
    }
    
    public void setFields()
    {   
        // START : D-1141 2/6/2015 Alyana Navarro
        pubCode = '';
        // END : D-1141 2/6/2015
        Order_Line_Item__c oli;
        Order__c relatedOrder;      
        
        // START : D-1189 1/6/2015 Alyana Navarro
        Publication__c publication = new Publication__c();
        Order_Line_Item_Gift__c orderLineItemGift;
        Promotion_Gift__c promotionGift = new Promotion_Gift__c();
        // START : D-1141 2/4/2015 Alyana Navarro - Change from Zuora__Subscription__c to List<Zuora__Subscription__c>
        List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();
        Integer counter = 0;
        // END : D-1141 2/4/2015
                
        //START:D-2217 2/13/15 Added by Manolo Valeña - Added Unique Number field to the query. Also assigns value to OrderLineItemGiftVar.
        //Start : Code Review Implementation 02/18/2015 S.Puli
        if(oligId<>null){
        //End : Code Review Implementation 02/18/2015 S.Puli
        //START: D-2383 02/26/2015 Added by Manolo Valena - Added field to the query.
        orderLineItemGift = [SELECT id, name, order_line_item__c, gift_id__c, promotion_gift__c, Gift_Letter_Batch_Id__c, Unique_Number__c, Order_Line_Item__r.Main_Package_ID__r.Package_Type__c,
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
                                Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.City__r.Country__c,
                                //Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.City__r.Country__r.Country_Name__c,
                                Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Airline_Number__c,
                                Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Flight_Number_1__c,
                                Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Flight_Number_2__c
                                //END  UD-2995 10/5/2015 Gdelrosario : added query for address

                             FROM Order_Line_Item_Gift__c 
                             WHERE id =: oligId];
        //END: D-2383 02/26/2015 Added by Manolo Valena
        }//Start/End : Code Review Implementation 02/18/2015 S.Puli                  
        OrderLineItemGiftVar = orderLineItemGift;                   
        //END:D-2217 2/13/15 Added by Manolo Valeña
        

        //START UD-2995 10/5/2015 : method to format the address in the template
            Order_Line_Item__c orderLineItem;
            orderLineItem= [SELECT id, name, 
                                    Order__r.Recipient_Contact__r.Address__r.City__r.Country__r.Country_Name__c
                             FROM Order_Line_Item__c
                             WHERE id =: orderLineItemGift.order_line_item__c LIMIT 1];
        If(!Test.IsRunningTest()){
        //START D-3722 3/11/2015 Gdelrosario: change of call of address format
          finalAddress = AddressHelper.formatGiftAddress(orderLineItemGift); 
        //END D-3722 3/11/2015 Gdelrosario:change of call of address format
        }

        // START : D-1141 2/6/2015 Alyana Navarro
        if(giftLetterBatchId == null){
            giftLetterBatchId = orderLineItemGift.Gift_Letter_Batch_Id__c;
        }
        //START UD-2458 added by dags get redemption venue
        if(giftLetterBatchId<>null){
        giftLetterBatch = [SELECT Id, Redemption_Venue__c FROM Gift_Letter_Batch__c WHERE Id =: giftLetterBatchId ];
        }
            if(giftLetterBatch != null){
                redemptionVenue = giftLetterBatch.Redemption_Venue__c;
            }
        //END UD-2458 added by dags get redemption venue
        //Start : Code Review Implementation 02/18/2015 S.Puli
        if(giftLetterBatchId<>null){
        //End : Code Review Implementation 02/18/2015 S.Puli        
        giftLetterBatch = [SELECT id, name, Redemption_Start_Date__c, Redemption_End_Date__c 
                           FROM Gift_Letter_Batch__c 
                           WHERE id =: giftLetterBatchId];
            //START 04/27/15 UD-0960 and UD-0829 Kevin Evasco - Removed overlapping gift letter batch validation
            
            redemptionStartDate = formatDate(giftLetterBatch.Redemption_Start_Date__c);
            redemptionEndDate = formatDate(giftLetterBatch.Redemption_End_Date__c);
            
            //END 04/27/15 UD-0960 and UD-0829 Kevin Evasco - Removed overlapping gift letter batch validation
        }//Start/End : Code Review Implementation 02/18/2015 S.Puli
        // END : D-1141 2/6/2015
        
        //Start : Code Review Implementation 02/18/2015 S.Puli
        if(orderLineItemGift<>null){
            if(orderLineItemGift.order_line_item__c<>null){
        //End : Code Review Implementation 02/18/2015 S.Puli 
                oli = [SELECT Order__c, Subscription__c, Publication_1__c, Publication_2__c, Main_Package_ID__c
               FROM Order_Line_Item__c 
               WHERE Id =: orderLineItemGift.order_line_item__c];
            }//Start/End : Code Review Implementation 02/18/2015 S.Puli
        }//Start/End : Code Review Implementation 02/18/2015 S.Puli
        
        //Start : Code Review Implementation 02/18/2015 S.Puli
        if(oli<>null){
            if(oli.Order__c<>null){
        //End : Code Review Implementation 02/18/2015 S.Puli
        // START : UD-3196 11/3/2015 Alyana Navarro
        relatedOrder = [SELECT Id, Name, Billing_Contact__r.Name, Recipient_Contact__r.Address__r.Concatenated_Address_Fields__c,
                        Recipient_Contact__r.Name, Recipient_Contact__r.FirstName, Recipient_Contact__r.LastName, 
                        Recipient_Contact__r.Address__r.Block_House_Number__c, 
                        Recipient_Contact__r.Address__r.Postal_Code__r.Building_Name__c,
                        Recipient_Contact__r.Address__r.Postal_Code__r.Name, 
                        Recipient_Contact__r.Address__r.Level_Number__c, 
                        Recipient_Contact__r.Address__r.Unit_Number__c, 
                        Recipient_Contact__r.Address__r.Country__r.Country_Name__c, 
                        Recipient_Contact__r.Address__r.Postal_Code__r.Street_Name__c,
                        Recipient_Contact__r.Address__r.Postal_Code__c, //start/End UD-2382 added by dags for barcode
                        Account__r.Recipient_Number__c, //START /END UD-2214 Gdelrosario 24/8/2015 added for the account recieptnumber
                        Account__r.Attention_To_Care_Of__c, //START END UD-2457 Gdelrosario 28/9/2015 added for the query to get the attention to field
                        Account__r.Account_Auto_Number__c, Recipient_Contact__r.AccountId, Account__r.AccountNumber, 
                        Recipient_Contact__r.Recipient_Number__c
                        FROM Order__c
                        WHERE Id =: oli.Order__c];
            // END : UD-3196 11/3/2015 Alyana Navarro
            }//Start/End : Code Review Implementation 02/18/2015 S.Puli
        }//Start/End : Code Review Implementation 02/18/2015 S.Puli
                        
        //Start : Code Review Implementation 02/18/2015 S.Puli
        Account recipientAccount;
        if(relatedOrder<>null){
            if(relatedOrder.Recipient_Contact__c<>null){
                if(relatedOrder.Recipient_Contact__r.AccountId<>null){
        //End : Code Review Implementation 02/18/2015 S.Puli 
        recipientAccount = [SELECT id, Account_Auto_Number__c 
                                    FROM Account 
                                    WHERE id =: relatedOrder.Recipient_Contact__r.AccountId];
                }//Start/End : Code Review Implementation 02/18/2015 S.Puli
            }//Start/End : Code Review Implementation 02/18/2015 S.Puli
        }//Start/End : Code Review Implementation 02/18/2015 S.Puli
                                    
        //Start : Code Review Implementation 02/18/2015 S.Puli
        if(orderLineItemGift.promotion_gift__c<>null){
        //End : Code Review Implementation 02/18/2015 S.Puli
        promotionGift = [SELECT id, name, redemption_letter_details__c, gift__c, gift__r.gift_description__c, gift__r.name
                             FROM Promotion_Gift__c 
                             WHERE id =: orderLineItemGift.promotion_gift__c];
        }//Start/End : Code Review Implementation 02/18/2015 S.Puli
        //START : D-1141 2/6/2015 Alyana Navarro
        //Start : Code Review Implementation 02/18/2015 S.Puli
        if(oli.Main_Package_ID__c<>null){
        //End : Code Review Implementation 02/18/2015 S.Puli
        //START UD-2214 GdelRosario : added fields for query
        subscriptionList = [SELECT id, name, Product_Code__c,Zuora__CustomerAccount__c,Zuora__CustomerAccount__r.Billing_Contact__r.Recipient_Number_Show__c,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Billing_Indicator__c
                                FROM Zuora__Subscription__c 
                                    WHERE Order_Line_Item_Number_1__c =: oli.id 
                                    AND Subscription_Type__c = 'Publication' 
                                    AND Main_Package_1__c =: oli.Main_Package_ID__c];
        }//Start/End : Code Review Implementation 02/18/2015 S.Puli
        //END UD-2214 GdelRosario : added fields for query
        for(Zuora__Subscription__c sub : subscriptionList){
            counter++;
            pubCode += sub.Product_Code__c;
            if(counter != subscriptionList.size()){
                pubCode += ' and ';
            }
        }
        // END : D-1141 2/6/2015
        
        contactName = relatedOrder.Account__r.Attention_To_Care_Of__c;    //START - END GDELROSARIO UD-2457 28/9/2015 change to billing account attention to field 
        billingContactName = relatedOrder.Billing_Contact__r.Name;
        //START UD-2214 GdelRosario 24/8/2015 : dynamic query
        // START : UD-3196 11/3/2015 Alyana Navarro
        subAccountNum = relatedOrder.Account__r.AccountNumber; // relatedOrder.Account__r.Recipient_Number__c;
        recAccountNum = String.valueOf(relatedOrder.Recipient_Contact__r.Recipient_Number__c);
        /*if(subscriptionList[0].Zuora__CustomerAccount__r.Billing_Contact__r.Billing_Indicator__c == true){
            recAccountNum = subscriptionList[0].Zuora__CustomerAccount__r.Billing_Contact__r.Recipient_Number_Show__c;
        }else {
            recAccountNum = recipientAccount.Account_Auto_Number__c;
        } */ 
        // END : UD-3196 11/3/2015 Alyana Navarro
        //END UD-2214 GdelRosario 24/8/2015: dynamic query
        giftDescription = promotionGift.gift__r.gift_description__c;
        giftName = promotionGift.gift__r.name;
        letterDetails = promotionGift.redemption_letter_details__c;             
        // END : D-1189 1/12/2015
        //START UD-2382 added by dags to show barcode
        For(Attachment e : [SELECT Id, Body FROM Attachment WHERE ParentId = : relatedOrder.Recipient_Contact__r.Address__r.Postal_Code__c]) {
                barcode = '/servlet/servlet.FileDownload?file=' + e.Id;
            }
        //END UD-2382 added by dags to show barcode    
        
        //START: D-2383 02/26/2015 Added by Manolo Valena - Added new logic for serial number shown on upper right corner of the letter.
        //START D-3932 20-Nov-2015 Added By S.Puli
        if(orderLineItemGift.Order_Line_Item__r.Main_Package_ID__r.Package_Type__c != 'Bundle')
        {
            Package_Item__c PackItemRecord = new Package_Item__c();
            PackItemRecord = [SELECT Id, Name, Product_Rate_Plan__r.Product_Code__c, 
                              //START: D-2385 02/26/2015 Added by Manolo Valena - Added field to the query.
                              Product_Rate_Plan__r.zqu__ZProduct__r.Name,Package__r.Name 
                              //END: D-2385 02/26/2015 Added by Manolo Valena
                              FROM Package_Item__c 
                              WHERE Package__c =: orderLineItemGift.Order_Line_Item__r.Main_Package_ID__c 
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
                              WHERE Package__c =: orderLineItemGift.Order_Line_Item__r.Main_Package_ID__c 
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
    }
    
    //START 04/27/15 UD-0960 and UD-0829 Kevin Evasco - Removed overlapping gift letter batch validation
    //START:D-2232 2/16/15 Added by Manolo Valeña - Input by Jeffrey Teves.
    /* REMOVED FOR UD-0960 and UD-0829
    public String getRedemptionStartDate() {

        return formatDate(giftLetterBatch.Redemption_Start_Date__c);
    }
    
    public String getRedemptionEndDate() {
        return formatDate(giftLetterBatch.Redemption_End_Date__c);
    }
    REMOVED FOR UD-0960 and UD-0829 */
    //END 04/27/15 UD-0960 and UD-0829 Kevin Evasco - Removed overlapping gift letter batch validation
    
    private String formatDate(Date dt) {
        String str = '';
        Time t = Time.newInstance(0,0,0,0);
        DateTime dTime = Datetime.newInstance(dt, t);
        Integer day = dt.day();
        String suffix = '';
        if(Math.mod(day, 10) == 1 && day != 11) {
            suffix = 'st';
        }
        else if(Math.mod(day, 10) == 2 && day != 12) {
            suffix = 'nd';
        }
        else if(Math.mod(day, 10) == 3 && day != 13) {
            suffix = 'rd';
        }
        else {
            suffix = 'th';
        }
        
        str += String.valueOf(dt.day()) + suffix + ' ';
        //START UD-3328 Gdelrosario : change the value of the year to get the Date instance not the dateTime instance
        str += dtime.format('MMMM') +' '+ String.valueOf(dt.year());
        //str += dtime.format('MMMM YYYY');
        //END UD-3328 Gdelrosario : change the value of the year to get the Date instance not the dateTime instance
        
        return str;
    }
    //END:D-2232 2/16/15 Added by Manolo Valeña.

    
}