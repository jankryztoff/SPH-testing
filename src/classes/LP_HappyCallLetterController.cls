/**
* Class Name: LP_HappyCallLetterController 
* @author: Jean Cariño
* Date: 17/03/2015
* Requirement/Project Name: SPH
* @description Controller for HappyCallLetter VF page
*/ 
public class LP_HappyCallLetterController {

    public string contractPeriod{get;set;}
    public string oligid;
    public Order_Line_Item_Gift__c oligRec{get;set;}
    public string giftCode{get;set;}
    public string sub_accn{get;set;}
    public string rcpn_accn{get;set;}
    public string salutation{get;set;}
    public string fName{get;set;}
    public string lName{get;set;}
    public string giftDes{get;set;}
    public integer giftDesnum{get;set;}
    public string postalCode{get;set;}
    public List<String> delAddr{get;set;}
    public string rVenue{get;set;}
    public string barcode{get;set;}
    public string rDetails{get;set;}
    public date rEndDate{get;set;}
    public date rStartDate{get;set;}
    public string cntry{get;set;}
    public string giftLetterBatchId;
    public String ProductCode{ get; set; }
    public String ProductName { get; set; }
    public Gift_Letter_Batch__c giftLetterBatch {get;set;}
    
    //START UD-0406 4/8/2015 Added by Manolo Valena - Added new variables.
    public String blockHouseNum {get; set;}
    public String levelNum {get; set;}
    public String unitNum {get; set;}
    public String buildingName {get;set;}
    public String stName {get; set;}
    //END UD-0406 4/8/2015 Added by Manolo Valena

    //START UD-2995 10/5/2015 Gdelrosario : added variables for address
    public String address1 {get;set;}
    public String address2 {get;set;}
    public String address3 {get;set;}
    public String address4 {get;set;}
    public String address5 {get;set;}
    //END  UD-2995 10/5/2015 Gdelrosario : added variables for address

    //START UD-2993 5/10/2015 Gdelrosario : added for "attention to" and normal recipient 
    public String contactName {get;set;}
    public String billingContactName {get;set;}
    //END UD-2993 5/10/2015 Gdelrosario : added for "attention to" and normal recipient
        
    // START : UD-2089 8/4/2015 Alyana Navarro
    public List<String> redemptionVenueSplitList = new List<String>(); //START-END D-4076 12-10-2015 added by Jason A. for code review
    public Boolean isBreak {get; set;} // START-END : UD-2089 8/19/2015 Alyana Navarro
    // END : UD-2089 8/4/2015 Alyana Navarro

    //START D-3722 3/11/2015 Gdelrosario: change of call of address format
    public String finalAddress { get; set; }
    //END D-3722 3/11/2015 Gdelrosario: change of call of address format

        public LP_HappyCallLetterController(){
            try{
                setFields();
            } catch(Exception e){
                system.debug('Error in generating letter!');
            }
        }
        
        public void setFields(){
            isBreak = false; // START-END : UD-2089 8/4/2015 Alyana Navarro // START-END : UD-2089 8/19/2015 Alyana Navarro
            oligid = ApexPages.currentPage().getParameters().get('id');
            
            giftLetterBatchId = ApexPages.currentPage().getParameters().get('giftLetterBatchId');                
             //START UD-2100 05-Aug-2015 Added By S.Puli - add map of oliGift To Zuora__Subscription__r.New_Contract_Period_1__c
             //START UD-2995 10/5/2015 Gdelrosario : added query for address
            oligRec = [SELECT id, Gift_Letter_Batch_Id__c, Promotion_Gift__r.Promotion__r.Contract_Period__c, Promotion_Gift__r.Gift__r.Gift_Code__c,
                        Order_Line_Item__r.Order__r.Account__r.AccountNumber, Order_Line_Item__r.Order__r.Recipient_Contact__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Salutation, Order_Line_Item__r.Order__r.Recipient_Contact__r.FirstName,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.LastName, Promotion_Gift__r.Gift__r.Name,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Contact_Address_Detail__c, Promotion_Gift__r.Redemption_Letter_Details__c,
                        Promotion_Gift__r.Redemption_End_Date__c, Order_Line_Item__r.Order__r.Recipient_Contact__r.Account.AccountNumber,
                        Order_Line_Item__r.Main_Package_ID__r.Name, Unique_Number__c, Order_Line_Item__r.Main_Package_ID__c,
                        Order_Line_Item__r.Main_Package_ID__r.Package_Type__c, 
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
                        //START UD-3183 10/30/2015 Gdelrosario : added query for billing contact name
                        Order_Line_Item__r.Order__r.Billing_Contact__r.FirstName,
                        Order_Line_Item__r.Order__r.Billing_Contact__r.LastName,
                        //END UD-3183 10/30/2015 Gdelrosario : added query for billing contact name
                        //END  UD-2995 10/5/2015 Gdelrosario : added query for address
                    /*
                        //START UD-0406 4/8/2015 Added by Manolo Valena - Query additional fields.
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Block_House_Number__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Level_Number__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Unit_Number__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Postal_Code__r.Building_Name__c,
                        Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Postal_Code__r.Street_Name__c,
                    */    
                        //START UD-2214 Gdelrosario : added for receipt number 
                        Order_Line_Item__c,
                        //END UD-2100 05-Aug-2015 Added By S.Puli - add map of oliGift To Zuora__Subscription__r.New_Contract_Period_1__c
                        //END UD-0406 4/8/2015 Added by Manolo Valena
                        //START UD-2214 Gdelrosario : added for receipt number 
                        Order_Line_Item__r.Order__r.Account__r.Recipient_Number__c
                        //END UD-2214 Gdelrosario : added for receipt number 
                                            FROM Order_Line_Item_Gift__c
                                            WHERE id =: oligid];
            //START UD-2100 05-Aug-2015 Added By S.Puli - add map of oliGift To Zuora__Subscription__r.New_Contract_Period_1__c
            List<Zuora__Subscription__c> sub_List = new List<Zuora__Subscription__c>();
            if(oligRec <> null){
                //start UD-2214 Gdelrosario : added Zuora__CustomerAccount__c in the query 
                // START : UD-2214 10/12/2015 Alyana Navarro
                sub_List = [SELECT Id, Name, Order_Line_Item_Number_1__c,New_Contract_Period_1__c ,Zuora__CustomerAccount__c,
                            Zuora__CustomerAccount__r.Billing_Contact__r.Recipient_Number_Show__c,Zuora__CustomerAccount__r.Billing_Contact__r.Billing_Indicator__c, Recipient_Contact__r.Recipient_Number__c
                                FROM Zuora__Subscription__c 
                                Where Order_Line_Item_Number_1__c = :oligRec.Order_Line_Item__c 
                                AND Subscription_Type_1__c = : GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
                                Limit 1];
                // END : UD-2214 10/12/2015 Alyana Navarro
                //END UD-2214 Gdelrosario 24/8/2015
                if(sub_List.size()>0){
                    if(sub_List[0].New_Contract_Period_1__c <> null && sub_List[0].New_Contract_Period_1__c <> 0){
                        Decimal dec = 0;
                        dec = sub_List[0].New_Contract_Period_1__c;
                        contractPeriod = String.valueOf(dec.divide(12, 2, System.RoundingMode.UP));//START/END UD-2100 08/12/15 RReyes - round up contract period
                    } else{
                        contractPeriod = '0';
                    }
                }
            }
            //END UD-2100 05-Aug-2015 Added By S.Puli - add map of oliGift To Zuora__Subscription__r.New_Contract_Period_1__c
                                                                                                                                                                                
        if(giftLetterBatchId == null){
            giftLetterBatchId = oligRec.Gift_Letter_Batch_Id__c;
        }
        if(giftLetterBatchId != null){
            giftLetterBatch = [SELECT id, name, Redemption_Start_Date__c, Redemption_End_Date__c, Redemption_Venue__c
                                       FROM Gift_Letter_Batch__c 
                                       WHERE id =: giftLetterBatchId];
        }                
        
            //START UD-2100 05-Aug-2015 Added By S.Puli - add map of oliGift To Zuora__Subscription__r.New_Contract_Period_1__c
            //contractPeriod = String.valueOf(Integer.valueOf(oligRec.Promotion_Gift__r.Promotion__r.Contract_Period__c) / 12); 
            //END UD-2100 05-Aug-2015 Added By S.Puli - add map of oliGift To Zuora__Subscription__r.New_Contract_Period_1__c
        giftCode = oligRec.Unique_Number__c;//Promotion_Gift__r.Gift__r.Gift_Code__c;
        //START UD-2214 Gdelrosario 24/8/2015
            //START UD-2214 Gdelrosario 19/10/2015 : change the sub_accn from recipient number to account number
            //sub_accn = oligRec.Order_Line_Item__r.Order__r.Account__r.Recipient_Number__c;  
            sub_accn = oligRec.Order_Line_Item__r.Order__r.Account__r.AccountNumber;  
            //END UD-2214 Gdelrosario 19/10/2015 : change the sub_accn from recipient number to account number     
        // START : UD-2214 10/12/2015 Alyana Navarro
        rcpn_accn = '';
        if(sub_List[0].Recipient_Contact__r.Recipient_Number__c != null){
            rcpn_accn = String.valueOf(sub_List[0].Recipient_Contact__r.Recipient_Number__c);
        }
        // END : UD-2214 10/12/2015 Alyana Navarro
        //END UD-2214 Gdelrosario 24/8/2015
        salutation = oligRec.Order_Line_Item__r.Order__r.Recipient_Contact__r.Salutation;
        //START UD-3183 10/30/2015 Gdelrosario : change the field for billing contact name
        fName = oligRec.Order_Line_Item__r.Order__r.Billing_Contact__r.FirstName;
        lName = oligRec.Order_Line_Item__r.Order__r.Billing_Contact__r.LastName;
        //END UD-3183 10/30/2015 Gdelrosario : change the field for billing contact name     
        lName = lName.replace(' ','&nbsp;'); // START-END : D-3506 9/9/2015 GDelRosario : added this for replace of space with nbsp
        giftDes = oligRec.Promotion_Gift__r.Gift__r.Name;
        postalCode = oligRec.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name;
        delAddr = oligRec.Order_Line_Item__r.Order__r.Recipient_Contact__r.Contact_Address_Detail__c.split('<br>');
        rVenue= giftLetterBatch.Redemption_Venue__c;/*.replace('<br>','<br/>');*/
        rEndDate = giftLetterBatch.Redemption_End_Date__c;
        rStartDate = giftLetterBatch.Redemption_Start_Date__c;
        cntry = oligRec.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Country__r.Country_Name__c;
        //START UD-2993 5/10/2015 : added to billing account attention to field 
        contactName = oligRec.Order_Line_Item__r.Order__r.Account__r.Attention_To_Care_Of__c; 
        //END UD-2993 5/10/2015 : added to billing account attention to field 


        // START : UD-2089 8/4/2015 Alyana Navarro
        if(giftLetterBatch.Redemption_Venue__c != null){ 
        // START : UD-2089 8/19/2015 Alyana Navarro
            String tempGiftLetter = giftLetterBatch.Redemption_Venue__c.replace(' style=""', '');
            redemptionVenueSplitList = tempGiftLetter.split('<br>');
            

            if(redemptionVenueSplitList.size() <= 16){
                isBreak = true;
            }                                
               
            if(rVenue.substring(0, 2) == '<p' && rVenue.substring(rVenue.length() - 4, rVenue.length()) == '</p>'){
                rVenue = rVenue.replace('<p', '<div');
                rVenue = rVenue.replace('</p>', '</div>');
                
            }
    // END : UD-2089 8/19/2015 Alyana Navarro
        }
            // END : UD-2089 8/4/2015 Alyana Navarro
     
            for(Attachment e : [SELECT Id, Body FROM Attachment WHERE ParentId = : oligRec.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Postal_Code__c]) {
                barcode = '/servlet/servlet.FileDownload?file=' + e.Id;
            }
            getUniqueName();
            //START UD-2995 10/5/2015 : called out for the method
            //START D-3722 3/11/2015 Gdelrosario: change of call of address format
            finalAddress = AddressHelper.formatGiftAddress(oligRec); 
            //END D-3722 3/11/2015 Gdelrosario:change of call of address format
            //END UD-2995 10/5/2015 : called out for the method

        }
        
        private void getUniqueName() {
            //START D-3932 20-Nov-2015 Added By S.Puli
            if(oligRec.Order_Line_Item__r.Main_Package_ID__r.Package_Type__c != 'Bundle')
            {
                Package_Item__c PackItemRecord = new Package_Item__c();
                PackItemRecord = [SELECT Id, Name, Product_Rate_Plan__r.Product_Code__c,
                                  Product_Rate_Plan__r.zqu__ZProduct__r.Name, Package__r.Name
                                  FROM Package_Item__c 
                                  WHERE Package__c =: oligRec.Order_Line_Item__r.Main_Package_ID__c 
                                  AND RecordType.Name = 'Base Product' 
                                  LIMIT 1];
                                  
                if(PackItemRecord != null)
                {
                    ProductCode = PackItemRecord.Product_Rate_Plan__r.Product_Code__c + '-';
                    ProductName = PackItemRecord.Package__r.Name;
                }
            }
            else
            {
                List<Package_Item__c> PackItemRecord = new List<Package_Item__c>();
                PackItemRecord = [SELECT Id, Name, Product_Rate_Plan__r.Product_Code__c,
                                  Product_Rate_Plan__r.zqu__ZProduct__r.Name, Package__r.Name
                                  FROM Package_Item__c 
                                  WHERE Package__c =: oligRec.Order_Line_Item__r.Main_Package_ID__c 
                                  AND RecordType.Name = 'Bundle Product' 
                                  LIMIT 2];
                                  
                if(!PackItemRecord.isEmpty())
                {
                    ProductCode = '';
                    ProductName = '';
                    for(Package_Item__c packageItem : PackItemRecord)
                    {
                        ProductCode = ProductCode + packageItem.Product_Rate_Plan__r.Product_Code__c;
                    }
                    ProductCode = ProductCode + '-';
                    
                    if(PackItemRecord.size() == 2)
                    {
                        ProductName = PackItemRecord[0].Package__r.Name;
                    }
                    else if(PackItemRecord.size() == 1)
                    {
                        ProductName = PackItemRecord[0].Package__r.Name;
                    }
                }
            }
            giftCode = ProductCode + giftCode;
            //END D-3932 20-Nov-2015 Added By S.Puli
        }
    }