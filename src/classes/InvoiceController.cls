/* Class Name: InvoiceController 
* @author: Kevin H. Evasco
* Date: 03/09/2015
* Project/Requirement: SPH Invoice Draft Template Controller
* 
* History: 03/09/2015 MD-23/D-1985 Kevin Evasco Reconstructed class for the new invoice template provided by the client
* History: 03/09/2015 MD-23/D-1985 Kevin Evasco Reconstructed class for the new invoice template provided by the client
* History: 07/16/2015 Invoice CRs and SIRs Kevin Evasco - Fixed the following defects: UD-1695, UD-1760, UD-1762, UD-1785, UD-1773, UD-1766, UD-1765, UD-1798, D-3208, D-3207, D-3206. In addition, there were some code clean up done.
*/

public class InvoiceController {    
    
	Logger logger = new Logger('InvoiceController');//Start/End PD-0349 29-May-2016 Added By S.Puli
	
    public String address1 { get; set; }
    public String address2 { get; set; }
    public String address3 { get; set; }
    public String address4 { get; set; }
    //Start: UD-1089 04/29/2015 James - update address format
    public String address1b { get; set; }
    public String address1c { get; set; }
    //End: UD-1089 04/29/2015 James 
    //START UD-2293 12/8/2015 Gdelrosario : added to cater for country in template
    public String address5 { get; set; }     
    //END UD-2293 12/8/2015 Gdelrosario : added to cater for country in template    

    //START D-3722 15/10/2015 Gdelrosario : added for the final output of address
    public String finalOutputAddress { get; set; }   
    //END D-3722 15/10/2015 Gdelrosario : added for the final output of address
    public List<SubscriptionDetails> subDetailsList { get; set; }
    public List<Invoice_Line_Item__c> invoiceLineItemList = new List<Invoice_Line_Item__c>();
    public List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();   
    
    //START D-3929 18-Nov-2015 Added by S.Puli
    public Map<Id,Decimal> subscription_invoiceAmount = new Map<Id,Decimal>();
    public Map<Id,Decimal> subscription_discountAmount = new Map<Id,Decimal>(); //START/END 14 August 2015 UD-2259 Kevin Evasco - Seperate Line Item for Discount
    public Map<Id,Decimal> delSubs_invoiceAmount = new Map<Id,Decimal>();
    public Map<Id,Decimal> postageSubs_invoiceAmount = new Map<Id,Decimal>();
    public Map<Id,Decimal> giftSubs_invoiceAmount = new Map<Id,Decimal>();
    //END D-3929 18-Nov-2015 Added by S.Puli

    public Zuora__CustomerAccount__c billingAccount { get; set; }    
    public Zuora__ZInvoice__c invoice { get; set; }   
    
    public String barcodeAttId {get; set;}
    public boolean barChecker {get; set;} //START/END MGaelo UD-1248 7/13/2015
    public Id singpostAddressId {get; set;}
    
    public Decimal previousBalance { get; set; }
    public Decimal totalOutstanding { get; set; }
    
    public Decimal subscriptionFee { get; set; } 
    public Decimal discountFee { get; set; } //START/END 14 August 2015 UD-2259 Kevin Evasco - Seperate Line Item for Discount
    public Decimal deliveryChargeFee { get; set; }
    public Decimal postageChargeFee { get; set; }   
    public Decimal adjustmentsFee { get; set; }
    public Decimal otherAdjustmentsFee { get; set; }
    public Decimal currentChargesBeforeGST { get; set; }
    //START UD-1781 UD-1819 UD-1763 Kevin Evasco 20 July 2015 - Payment Details Formula
    public Decimal totalCurrentChargesPaymentTable { get; set; } 
    public Decimal totalCurrentChargesPaymentDetails { get; set; } 
    //END UD-1781 UD-1819 UD-1763 Kevin Evasco 20 July 2015 - Payment Details Formula
    public Decimal giftChargeFee {get; set;} // START-END : D-2837 4/30/2015 Alyana Navarro
    
    public String taxRate { get; set; } //START/END 04/17/2015 D-2771 Kevin Evasco - Invoice PDF Generation Optimization
    
    public Date dueDate { get; set; }
    
    public String billingAccountNumber { get; set; } //START/END UD-1766 14 July 2015 Kevin Evasco - Billing Account Number
    public String attentionToCareOf { get; set; }
    public String paymentDescriptionFootnote { get; set; }
    public String billingType { get; set; }
    public String poNumber { get; set; }
    
    public Boolean isARMSAccount { get; set; }
    public Boolean isSPHIntercompanyBilling { get; set; }   
    public Boolean isRecipientOverseas { get; set; }  //START/END D-3327 04 August 2015 Kevin Evasco - GST Rate will be based from custom settings only if tax amount is not 0.
    
    public Integer paymentType { get; set; }
    public Integer headnoteType { get; set; } //START/END 15 July 2015 Kevin Evasco - UD-1695, UD-1760, UD-1762, UD-1785, UD-1773, UD-1766, UD-1765, UD-1798, D-3208, D-3207, D-3206 - Needed for absolute position head note.
    
    //START: D-2802 24/04/15 Added by S.Puli - adding ARMS Invoice ID
    public String armsInvId { get; set; }
    //END: D-2802 24/04/15 Added by S.Puli - adding ARMS Invoice ID
    
    // START: D-2901 15/05/15 Added by S.Puli
    public boolean onlyFive { get; set; }
    //END: D-2901 15/05/15 Added by S.Puli
    //START UD-3758 02-23-2016 added by Jason A.
    public Map<Id,Order_Line_Item__c> orderIdMap = new Map<Id,Order_Line_Item__c>();
    public Map<Id, decimal> addOnAmountMap = new Map<Id, decimal>();
    //END UD-3758 02-23-2016 added by Jason A.
    // START : UD-1257 5/1/2015 Alyana Navarro
    public String footerInvoiceAmount {get; set;} 
    public String invoiceNumber {get; set;}
    public Integer checkDigit {get; set;}
    // END : UD-1257 5/1/2015 Alyana Navarro
    
    // START D-3205 7/5/15 VPernicia
    public String BillingAccountPONumber {get; set;}
    // END D-3205 7/5/15 VPernicia
    //START : UD-3207 9/11/2015 Gdelrosario
    public Integer tableLineCounter {get; set;}
    public Integer totalPackageChar {get; set;}
    //END : UD-3207 9/11/2015 Gdelrosario
    public class SubscriptionDetails {
        public String recipientName { get; set; }
        //START: UD-1771 7/4/15 VPernicia
        public Decimal recipientNumber { get; set; }
        //END: UD-1771 7/4/15 VPernicia
        public String subscriptionName { get; set; }
        public String packageName { get; set; }
        public Date subStartDate { get; set; }
        public Date subEndDate { get; set; }      
        public Integer quantity { get; set; }
        public Decimal amtWithoutTax { get; set; }
        public Decimal discountAmountWithoutTax { get; set; } //START/END 14 August 2015 UD-2259 Kevin Evasco - Seperate Line Item for Discount
        public Decimal adminChargeFee { get; set; } //START-END: 11/09/2015 UD-2828 added by Jason A. 
    }       
    //Start UD-3893 31-Mar-2016 Added By S.Puli
    public Decimal footerAmount { get; set; } 
    //End UD-3893 31-Mar-2016 Added By S.Puli
    public InvoiceController() {
    //Start UD-1682 added by Jason A.
        address3 = '';
        address1 = '';
        address2 = '';
        address4 = '';
        address1b = '';
    //End UD-1682 added by Jason A.
    // START : UD-3207 9/11/2015 Gdelrosario
    tableLineCounter = Integer.valueOf(Other__c.getInstance('Invoice Total Lines').value__c);
    totalPackageChar = Integer.valueOf(Other__c.getInstance('Invoice Total Package Char').value__c);
    // END : UD-3207 9/11/2015 Gdelrosario
    //START UD-2293 12/8/2015 Gdelrosario : added to cater for country in template
        address5 = '';
    //END UD-2293 12/8/2015 Gdelrosario : added to cater for country in template
        initialize();
        generateInvoiceController();
    }
    
    public void generateInvoiceController() {
        try 
        {   
            giftChargeFee = 0.00; // START-END : D-2837 4/30/2015 Alyana Navarro
            subDetailsList = new List<SubscriptionDetails>();
            Set<String> subscriptionIdSet = new Set<String>();
            //START UD-1458 6/9/2015 Added by MGaelo
            Date earliestStart = null;
            Date latestEnd = null;
            //END UD-1458 6/9/2015 Added by MGaelo
            //START D-2790 22-Apr-2015 Added by Raviteja - added Zuora__TotalAmount__c field in SOQL // End
            //START: D-2802 24/04/15 Added by S.Puli - adding ARMS Invoice ID
            // START : D-2828 5/7/2015 Alyana Navarro - Added Zuora__TargetDate__c in query.
            // Start D-2934 14May15 K. Tan - added Zuora__DueDate__c field
        // START : UD-1257 5/1/2015 Alyana Navarro
        // START : D-3205 7/4/2015 VPernicia    
            invoice = [ SELECT Name, Zuora__InvoiceDate__c, Zuora__AmountWithoutTax__c, Zuora__TaxAmount__c, Zuora__BillingAccount__c,
                        Zuora__DueDate__c, Zuora__Balance2__c, Zuora__Zuora_Id__c,Zuora__TotalAmount__c, ARMS_Invoice_ID__c, Previous_Balance__c, //START/END 21 September 2015 UD-2504 and UD-2826 Kevin Evasco - use the previous balance field from Invoice Record.
                        Zuora__BillingAccount__r.ARMS_Customer_Number__c, Zuora__TargetDate__c, Zuora__BillingAccount__r.Zuora__PurchaseOrderNumber__c, Zuora__BillingAccount__r.GIRO_A_C__c, Zuora__BillingAccount__r.Payment_Mode__c, Zuora__PaymentAmount__c //START/END UD-1695 14 July 2015 Kevin Evasco - GIRO //START/END UD-1781 UD-1819 UD-1763 Kevin Evasco 20 July 2015 - Payment Details Formula
                        FROM Zuora__ZInvoice__c
                        WHERE id =: ApexPages.currentPage().getParameters().get('id')];
        // END : D-3205 7/4/2015 VPernicia
        // END : UD-1257 5/1/2015 Alyana Navarro
            // End D-2934 14May15 K.Tan - added Zuora__DueDate__c field
            // END : D-2828 5/7/2015 Alyana Navarro
            if(invoice <> null){
                
                if(invoice.ARMS_Invoice_ID__c <> null){
                    armsInvId = invoice.ARMS_Invoice_ID__c;
                } else {
                    armsInvId = invoice.Name;
                }
                
                // START : D-3205 7/4/2015 VPernicia
                //START UD-3306 11/25/2015 added by Jason A.
                //BillingAccountPONumber = invoice.Zuora__BillingAccount__r.Zuora__PurchaseOrderNumber__c;
                //END UD-3306 11/25/2015 added by Jason A.
                // END : D-3205 7/4/2015 VPernicia
                dueDate = invoice.Zuora__DueDate__c; // Start/End D-2934 14May15 K. Tan - set the due date
                
                //START UD-1695 14 July 2015 Kevin Evasco - GIRO
                if((invoice.Zuora__BillingAccount__r.GIRO_A_C__c != null && invoice.Zuora__BillingAccount__r.GIRO_A_C__c != '') || invoice.Zuora__BillingAccount__r.Payment_Mode__c == GlobalVariableClass.CREDITCARD) {
                    dueDate = dueDate.addDays(2);
                }
                //END UD-1695 14 July 2015 Kevin Evasco - GIRO
            }
                        
            //END: D-2802 24/04/15 Added by S.Puli - adding ARMS Invoice ID
            if(invoice != null){
                //getTaxRate(); //START/END D-3327 04 August 2015 Kevin Evasco - GST Rate will be based from custom settings only if tax amount is not 0.
                //START D-2790 22-Apr-2015 Added by Raviteja  - updated the totalCurrentCharges calculation
                //START UD-1781 UD-1819 UD-1763 Kevin Evasco 20 July 2015 - Payment Details Formula
                  //totalCurrentCharges = invoice.Zuora__TotalAmount__c;
                  //totalOutstanding += totalCurrentCharges; //START/END 15 July 2015 Kevin Evasco - UD-1695, UD-1760, UD-1762, UD-1785, UD-1773, UD-1766, UD-1765, UD-1798, D-3208, D-3207, D-3206 - Corrected total oustanding formula                 
                //START D-2790 22-Apr-2015 Added by Raviteja  - updated the totalCurrentCharges calculation
                //END UD-1781 UD-1819 UD-1763 Kevin Evasco 20 July 2015 - Payment Details Formula
                 //End D-2790 22-Apr-2015 Added by Raviteja
                // START : UD-1257 6/1/2015 Alyana Navarro  
                if(invoice.Zuora__BillingAccount__c != null) {
                // START : UD-1656 6/18/2015 Alyana Navarro
            // START : UD-1480 6/11/2015 Alyana Navarro 
                    //START D-3722 Gdelrosario 23/10/2015: added to query
                    //START: D-3934 11/12/2015 Added by Jason A.
            billingAccount = [ SELECT 
                                       //START/END UD-1105 05-05-2015 Marvin G added ARMS_Account_Number__c field
                                                        // START: UD-1781 Jul-06-2015 Added by S.Puli
                                        //START/END D-2853 05-06-2015 Marvin G added Address record type
                                        //Start/End Dags UD-1598 06/27/2015 add Attention_To_Care1__c
                                        //START/END UD-1773 14 July 2015 Kevin Evasco - GIRO
                                        
                                        name, Zuora__CustomerAccount__c.Id, Billing_Account_Name_2__c, ARMS_Account_Number__c,                
                                        Zuora__Account__r.Name, Zuora__Account__r.AccountNumber, Zuora__Account__r.RecordTypeId, Payment_Mode__c,
                                        Attention_To_Care_Of_Name__c, Attention_To_Care_Of_Salutation__c, Bank__c,
                                        Billing_Contact__r.Id,
                                        Billing_Contact__r.Address__r.recordType.developerName,
                                        Billing_Contact__r.Address__r.Address_1__c, 
                                        Billing_Contact__r.Address__r.Address_2__c, 
                                        Billing_Contact__r.Address__r.Address_3__c, 
                                        Billing_Contact__r.Address__r.Address_4__c,
                                        Billing_Contact__r.Address__r.RecordType.Id, 
                                        Billing_Contact__r.Address__r.Block_House_Number__c,
                                        Billing_Contact__r.Address__r.Postal_Code__r.Street_Name__c, 
                                        Billing_Contact__r.Address__r.Level_Number__c,
                                        Billing_Contact__r.Address__r.Unit_Number__c, 
                                        Billing_Contact__r.Address__r.Postal_Code__r.Name, 
                                        Billing_Contact__r.Address__r.Postal_Code__c, 
                                        Billing_Contact__r.LastName,
                                        Billing_Contact__r.Firstname,
                                        Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c,
                                        Billing_Contact__r.Address__r.Country__r.Country_Name__c, 
                                        Billing_Contact__r.Address__r.Country__c,
                                        ARMS_Total_Outstanding_Amount__c, 
                                        Other_PaymentMethod__c, 
                                        Zuora__AccountNumber__c, 
                                        Zuora__PurchaseOrderNumber__c, 
                                        Billing_Account_Auto_Number__c, 
                                        Zuora__Balance__c, GIRO_Bank_Code__c,
                                        Billing_Contact__r.Name,
                                        Billing_Contact__r.HomePhone__c, 
                                        Billing_Contact__r.Address__r.RecordType.name,
                                        Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c, 
                                        Billing_Contact__r.Address__r.Department__r.Department_Name__c, 
                                        Billing_Contact__r.Address__r.Division_Code__r.Department_Name__c, 
                                        Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c, 
                                        Billing_Contact__r.Address__r.Location_Code__r.Location_Name__c, 
                                        Billing_Contact__r.Address__r.City__r.City_Name__c, 
                                        Billing_Contact__r.Address__r.Airline_Number__c, 
                                        Billing_Contact__r.Address__r.Flight_Number_1__c, 
                                        Billing_Contact__r.Address__r.Flight_Number_2__c,
                                        Attention_To_Care1__c,
                                        Zuora__Account__c, 
                                        Zuora__Credit_Balance__c, 
                                        Billing_Type__c, GIRO_A_C__c, AGD_Unit__c,
                                        Billing_Contact__r.Address__r.Street_Name__c,
                                        Billing_Contact__r.Address__r.Building_Name__c,
                                        Billing_Contact__r.Address__r.Country__r.Code__c,
                                        Billing_Contact__r.Address__r.Country__r.Name,
                                        Billing_Contact__r.Address__r.Division_Code__r.Name,
                                        Billing_Contact__r.Address__r.Section_Code__r.Name,
                                        Billing_Contact__r.Address__r.Department__r.Name,
                                        Billing_Contact__r.Address__r.Company_Code__r.Name,
                                        Billing_Contact__r.Address__r.Location_Code__r.Name,
                                        Billing_Contact__r.Address__r.City__c,
                                        Billing_Contact__r.Address__r.City__r.Name,
                                        Billing_Contact__r.Address__r.Packing_Code__c,
                                        Billing_Contact__r.Address__r.City__r.Country__r.Country_Name__c,
                                        Billing_Contact__r.Company_Name__c
                    //END: D-3934 11/12/2015 Added by Jason A.
                    // END: UD-1781 Jul-06-2015 Added by S.Puli
                                    FROM Zuora__CustomerAccount__c
                                    WHERE Id = :invoice.Zuora__BillingAccount__c];
                                    //WHERE Id = 'a0MN0000003ozAqMAI'];
            // END : UD-1480 6/11/2015 Alyana Navarro
                // END : UD-1656 6/18/2015 Alyana Navarro   
                //END D-3722 Gdelrosario 23/10/2015: added to query
                    getBarCode();
                    
                    
                    footerInvoiceAmount = '';
                    invoiceNumber = '';                 
                    Integer dateTotal = 0;
                    Integer accountTotal = 0;
                    Integer documentTotal = 0;
                    //START PD-0212 5-23-2016 Changes by Jason A
                    //Start PD-0349 29-May-2016 Added by S.Puli - Previous balance is null for some scenarios and needs to be computed i.e. Recurring
                    decimal tempvalue = 0;
					if(invoice.Previous_Balance__c <> null){	
						tempvalue = decimal.valueof(invoice.Previous_Balance__c) + invoice.Zuora__TotalAmount__c;
                    }else{
						tempvalue = billingAccount.Zuora__Balance__c + invoice.Zuora__PaymentAmount__c;
					}
					//End PD-0349 29-May-2016 Added by S.Puli
                    String tempAmount = String.valueOf(tempvalue * 100);
                    //END PD-0212 5-23-2016 Changes by Jason A
                    tempAmount = tempAmount.substring(0, tempAmount.length() - 3);
                    String dateTodayString = String.valueOf(invoice.Zuora__InvoiceDate__c).substring(0, 10);            
                    List<Integer> baseDigitsDate = new List<Integer>{5, 4, 3, 2, 0, 2, 7, 0, 5, 4};
                    List<Integer> baseDigitsAccount = new List<Integer>{5, 4, 3, 2, 7, 6, 5, 4, 3, 2};
                    for(Integer counter = 0; counter < 11 - tempAmount.length(); counter++){
                        footerInvoiceAmount += 0;
                    }
                    footerInvoiceAmount += tempAmount;
                    if(invoice.ARMS_Invoice_ID__c != null){
                        invoiceNumber = String.valueOf(invoice.ARMS_Invoice_ID__c).substring(2, invoice.ARMS_Invoice_ID__c.length());
                    } else {
                        invoiceNumber = invoice.name.substring(3, invoice.name.length());
                    }
                                                                
                    for(Integer counter = 0; counter < dateTodayString.length(); counter++){
                        if(dateTodayString.substring(counter, counter+1) != '-'){
                            dateTotal += Integer.valueOf(dateTodayString.substring(counter, counter+1)) * baseDigitsDate[counter];
                        }
                    }
                                        
                    if(billingAccount.ARMS_Account_Number__c != null){
                        billingAccountNumber = billingAccount.ARMS_Account_Number__c; //START/END UD-1766 14 July 2015 Kevin Evasco - Billing Account Number
                        String accountNumber = billingAccount.ARMS_Account_Number__c; // To be replaced by account number
                        for(Integer counter = 0; counter < accountNumber.length(); counter++){
                            accountTotal += Integer.valueOf(accountNumber.substring(counter, counter + 1)) * baseDigitsAccount[counter];
                        }
                    }
                    //START UD-1766 14 July 2015 Kevin Evasco - Billing Account Number
                    else {
                        billingAccountNumber = billingAccount.Zuora__AccountNumber__c;
                    }
                    //END UD-1766 14 July 2015 Kevin Evasco - Billing Account Number
                     
                    if(invoice.ARMS_Invoice_ID__c != null){
                        String docNumber = invoice.ARMS_Invoice_ID__c; // To be replaced.
                        docNumber = docNumber.substring(2, docNumber.length());
                        for(Integer counter = 0; counter < docNumber.length(); counter++){
                            documentTotal += Integer.valueOf(docNumber.substring(counter, counter + 1)) * baseDigitsAccount[counter + 2];
                        }                        
                    }
                                         
                    checkDigit = Math.mod((dateTotal + accountTotal + documentTotal + 18), 11); // Invoice is always I. I = 18. Refer in Check Digit Logic File.
                    if(checkDigit == 0 || checkDigit == 1){
                        checkDigit = 0;
                    } else {
                        checkDigit = 11 - checkDigit;
                    }
                    // END : UD-1257 6/1/2015 Alyana Navarro
                    
                    /* START D-3327 04 August 2015 Kevin Evasco - GST Rate will be based from custom settings only if tax amount is not 0.
                    //START UD-2853 05-06-2015 Marvin G
                    if (billingAccount.Billing_Contact__r.Address__r.RecordType.name == 'Overseas') {
                        taxRate = '0';
                    }
                    //END UD-2853 05-06-2015 Marvin G 
                    END D-3327 04 August 2015 Kevin Evasco - GST Rate will be based from custom settings only if tax amount is not 0. */
                    
                    //START D-3288 Kevin Evasco 27 July 2015 - Total Current Charges Fix
                    //START UD-1781 UD-1819 UD-1763 Kevin Evasco 20 July 2015 - Payment Details Formula
                    //START 02 August 2015 D-3331 Kevin Evasco - Hotfix: Payment Details Formula
                    //Start UD-3890 11-Apr-2016 Added By S.Puli
                    /***
                    if(billingAccount.Other_PaymentMethod__c == 'Invoice'){
                        isARMSAccount = true;
                        if(billingAccount.ARMS_Total_Outstanding_Amount__c != null){    
                            //START 15 July 2015 Kevin Evasco - UD-1695, UD-1760, UD-1762, UD-1785, UD-1773, UD-1766, UD-1765, UD-1798, D-3208, D-3207, D-3206 - Corrected Previous Balance and Total Outstanding Amount.
                            previousBalance = billingAccount.ARMS_Total_Outstanding_Amount__c;
                            //END 15 July 2015 Kevin Evasco - UD-1695, UD-1760, UD-1762, UD-1785, UD-1773, UD-1766, UD-1765, UD-1798, D-3208, D-3207, D-3206 - Corrected Previous Balance and Total Outstanding Amount.
                        }
                        //START 31 August 2015 UD-1819 Kevin Evasco - New Total Concurrent Charges Payment Details Formula for ARMS
                        //totalOutstanding = invoice.Zuora__TotalAmount__c;
                        //START UD-2987 10/02/2015 added by Jason A. for Total Current Charge Due = Total Outstanding Amount = �Amount� (on the bottom of PDF � highlighted) = invoice.Zuora__PaymentAmount__c.
                        totalCurrentChargesPaymentDetails = invoice.Zuora__PaymentAmount__c;  
                        totalOutstanding = totalCurrentChargesPaymentDetails;
                        //END UD-2987 10/02/2015 added by Jason A. for Total Current Charge Due = Total Outstanding Amount = �Amount� (on the bottom of PDF � highlighted) = invoice.Zuora__PaymentAmount__c.
                        totalOutstanding = totalCurrentChargesPaymentDetails;
                        //END 31 August 2015 UD-1819 Kevin Evasco - New Total Concurrent Charges Payment Details Formula for ARMS  
                        
                        //Start UD-3893 31-Mar-2016 Added By S.Puli
                        footerAmount = totalCurrentChargesPaymentDetails;
                        //End UD-3893 31-Mar-2016 Added By S.Puli
                    }
                    else {
                    ***/
                     if(billingAccount.Other_PaymentMethod__c == 'Invoice'){
                         isARMSAccount = true;
                     }
                    
                    
                        //START 2 October 2015 UD-2504 Kevin Evasco - Previous Balance = BA Balance - Invoice Total Amount + Invoice Payment.
                        //START 21 September 2015 UD-2504 and UD-2826 Kevin Evasco - use the previous balance field from Invoice Record.
                        if(invoice.Previous_Balance__c != null) {
                            previousBalance = Decimal.valueOf(invoice.Previous_Balance__c);
                        } else {            
                            previousBalance = billingAccount.Zuora__Balance__c - invoice.Zuora__TotalAmount__c + invoice.Zuora__PaymentAmount__c; 
                        }
                        totalOutstanding = previousBalance + invoice.Zuora__TotalAmount__c;     
                        
                        if(totalOutstanding < 0)
                            totalOutstanding = 0;
                        
                        //Start UD-3893 31-Mar-2016 Added By S.Puli
                        footerAmount = totalOutstanding;
                        //End UD-3893 31-Mar-2016 Added By S.Puli
                        //END 21 September 2015 UD-2504 and UD-2826 Kevin Evasco - use the previous balance field from Invoice Record.                      
                        //END 2 October 2015 UD-2504 Kevin Evasco - Previous Balance = BA Balance - Invoice Total Amount + Invoice Payment.
                        totalCurrentChargesPaymentDetails = invoice.Zuora__TotalAmount__c; 
                    //}
                    //End UD-3890 11-Apr-2016 Added By S.Puli
                    totalCurrentChargesPaymentTable= invoice.Zuora__TotalAmount__c;                 
                    //totalCurrentChargesPaymentDetails = invoice.Zuora__TotalAmount__c; //START/END 31 August 2015 UD-1819 Kevin Evasco - New Total Concurrent Charges Payment Details Formula for ARMS                            
                    //END 02 August 2015 D-3331 Kevin Evasco - Kevin Evasco - Hotfix: Payment Details Formula
                    //END UD-1781 UD-1819 UD-1763 Kevin Evasco 20 July 2015 - Payment Details Formula
                    //END D-3288 Kevin Evasco 27 July 2015 - Total Current Charges Fix
                    
                    if(billingAccount.Zuora__Account__r.RecordTypeId == ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division')) {
                        isSPHIntercompanyBilling = true;                    
                    }
                    
                    //Start Dags UD-1598 06/27/2015 add Attention_To_Care1__c
                      if(billingAccount.Attention_To_Care_Of_Salutation__c != null) {
                        attentionToCareOf = billingAccount.Attention_To_Care_Of_Salutation__c + ' ' + billingAccount.Attention_To_Care1__c;
                    } else {                        
                        attentionToCareOf = billingAccount.Attention_To_Care1__c;
                    }
                    //End Dags UD-1598 06/27/2015 add Attention_To_Care1__c   
                }
                //START UD-1458 6/9/2015 Added by MGaelo: ServiceStart/End Date
                if(invoice.Zuora__Zuora_Id__c != null) {
                    //START UD-2819 19-Sept-2015 Added By S.Puli - add UOM__c, ID__c
            //START: 11/09/2015 UD-2828 added by Jason A. 
                    //START D-3878 11/09/15 RReyes - added sub end date in query
                    //START D-3929 18-Nov-2015 Added by S.Puli
    //START UD-3758 02-23-2016 added by Jason A.
                    invoiceLineItemList = [SELECT id, name, Invoice_ID__c, Subscription_ID__c, Subscription_Number__c, Charge_Amount__c, Tax_Exempt_Amount__c, Tax_Amount__c, Subscription__c,
                                            Service_Start_Date__c, Service_End_Date__c, Applied_To_Invoice_Item_ID__c, UOM__c, ID__c,Product_Name__c,  //START/END 14 August 2015 UD-2259 Kevin Evasco - Seperate Line Item for Discount
                                            Subscription__r.Zuora__SubscriptionEndDate__c, Subscription__r.Order_Line_Item_Number_1__c, Subscription__r.Main_Package_1__r.Package_Type__c, Subscription__r.Subscription_Type__c  
                                            FROM Invoice_Line_Item__c 
                                            WHERE Invoice_ID__c =: invoice.Zuora__Zuora_Id__c];
    //END UD-3758 02-23-2016 added by Jason A.
                    //END D-3929 18-Nov-2015 Added by S.Puli
                    //END D-3878 11/09/15 RReyes - added sub end date in query
                    //END UD-2819 19-Sept-2015 Added By S.Puli
                    //END: 11/09/2015 UD-2828 added by Jason A. 
                }
            }
            
            Map <String, List<Invoice_Line_Item__c>> mapInvoiceLineItem = new Map <String, List<Invoice_Line_Item__c>>();
            Map <String, Map <String, Date>> mapSubtoDate = new Map <String, Map <String, Date>>();
            //END UD-1458 6/9/2015 Added by MGaelo created Map for SubId and InvoiceLineitemsList
            //START UD-2819 19-Sept-2015 Added By S.Puli
            Map<String, String> invLineToUOM_Map = new Map<String, String>();
            //END UD-2819 19-Sept-2015 Added By S.Puli
            Map<id, decimal> adminChargeSub = new Map<id, decimal>(); //START-END: 11/09/2015 UD-2828 added by Jason A. 
            //START UD-2819 19-Sept-2015 Added By S.Puli - loop for invoice line item map to UOM
            for(Invoice_Line_Item__c invoiceLineItem : invoiceLineItemList){
                if(invoiceLineItem.UOM__c <> null ){
                    if(invoiceLineItem.UOM__c.length() > 8){
                        String uomString = '';
                        uomString = invoiceLineItem.UOM__c.substring(0,9).toUpperCase();
                        if(uomString == GlobalVariableClass.NO_CREDIT){
                            invLineToUOM_Map.put(invoiceLineItem.ID__c, invoiceLineItem.UOM__c);
                        }
                    }
                }
            }
            //END UD-2819 19-Sept-2015 Added By S.Puli
            for(Invoice_Line_Item__c invoiceLineItem : invoiceLineItemList) {
                //START D-3114 HOTFIX Kevin 06/15/2015: Changed Subscription Identifier from Subscription External Id to Subscription Name
                if(invoiceLineItem.Subscription_Number__c != null) {
                    subscriptionIdSet.add(invoiceLineItem.Subscription_Number__c); 
                    
                    Decimal amountWithoutTax = 0;
                    Decimal adminCharge = 0; //START-END: 11/09/2015 UD-2828 added by Jason A. 
                    // START UD-1458 6/9/2015 MGaelo Set Start Date as EarliestServiceStartDate & End Date as LatestServiceEndDate
                    if (mapInvoiceLineItem.containsKey(invoiceLineItem.Subscription_Number__c)){
                        mapInvoiceLineItem.get(invoiceLineItem.Subscription_Number__c).add(invoiceLineItem);
                    }
                    
                    else{
                        mapInvoiceLineItem.put(invoiceLineItem.Subscription_Number__c, new List<Invoice_Line_Item__c>()); mapInvoiceLineItem.get(invoiceLineItem.Subscription_Number__c).add(invoiceLineItem);
                    }
                    // END UD-1458 6/9/2015 MGaelo Set Start Date as EarliestServiceStartDate & End Date as LatestServiceEndDate
                    
                    if(invoiceLineItem.Charge_Amount__c != NULL && invoiceLineItem.Tax_Amount__c != NULL)
                    {
    //START UD-3758 02-23-2016 added by Jason A.
                        if(invoiceLineItem.Subscription__r.Main_Package_1__r.Package_Type__c == GlobalVariableClass.PACKAGETYPE_ADDON){
                            if(addOnAmountMap.containskey(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c)){
                                Decimal temp = addOnAmountMap.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c);
                                temp += invoiceLineItem.Tax_Amount__c + invoiceLineItem.Charge_Amount__c;
                                addOnAmountMap.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, temp);
                            } else {
                                addOnAmountMap.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, (invoiceLineItem.Tax_Amount__c + invoiceLineItem.Charge_Amount__c));
                            }
                        } 
    //END UD-3758 02-23-2016 added by Jason A.
                        
                        //START: 11/09/2015 UD-2828 added by Jason A. 
                        if(invoiceLineItem.Product_Name__c != 'Admin Charge'){
                            //Start D-4068 09-Dec-2015 Added by S.Puli/J.Abolac - include tax invoiceLineItem.Tax_Amount__c
                            amountWithoutTax = invoiceLineItem.Charge_Amount__c+invoiceLineItem.Tax_Amount__c;
                            //End D-4068 09-Dec-2015 Added by S.Puli/J.Abolac - include tax invoiceLineItem.Tax_Amount__c
                        }
                        else{
                            //Start D-4068 09-Dec-2015 Added by S.Puli/J.Abolac - include tax invoiceLineItem.Tax_Amount__c
                            adminCharge = invoiceLineItem.Charge_Amount__c+invoiceLineItem.Tax_Amount__c;
                            //START D-3929 18-Nov-2015 Added by S.Puli
                            //Start D-4279 11-Jan-2016 Added by S.Puli - do not add if admin charge is 0
                            if(invoiceLineItem.Charge_Amount__c <> 0){  
                                if(!adminChargeSub.containsKey(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c)){   
                                    adminChargeSub.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, invoiceLineItem.Charge_Amount__c+invoiceLineItem.Tax_Amount__c); 
                                }else{
                                    Decimal tempAdminCharge = 0;
                                    tempAdminCharge = adminChargeSub.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c);
                                    adminChargeSub.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, invoiceLineItem.Charge_Amount__c + tempAdminCharge+invoiceLineItem.Tax_Amount__c);
                                }
                            }
                            //End D-4279 11-Jan-2016 Added by S.Puli
                            //End D-4068 09-Dec-2015 Added by S.Puli/J.Abolac - include tax invoiceLineItem.Tax_Amount__c
                            //END D-3929 18-Nov-2015 Added by S.Puli
                        }
                        //END: 11/09/2015 UD-2828 added by Jason A. 
                        //START D-2790 22-Apr-2015 Added by Raviteja  - updated the amountWithoutTax calculation
                        
                        //End D-2790 22-Apr-2015 Added by Raviteja
                    }
                    //Start UD-1497 06/09 Jason A.
                    //Start UD-1539 07/07/15 VPernicia Uncomment if condition for amountWithoutTax
                    //START UD-2819 19-Sept-2015 Added By S.Puli
                    //START D-3929 18-Nov-2015 Added by S.Puli
                    if(!invLineToUOM_Map.containsKey(invoiceLineItem.ID__c)){
                        if(invoiceLineItem.Applied_To_Invoice_Item_ID__c <> null){
                            if(!invLineToUOM_Map.containsKey(invoiceLineItem.Applied_To_Invoice_Item_ID__c)){
                                if(amountWithoutTax >= 0)
                                {
                                    if(invoiceLineItem.Subscription__r.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION){
                                        if(subscription_invoiceAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) == null)
                                        {
                                            subscription_invoiceAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, amountWithoutTax);
                                        }
                                        else
                                        {
                                            Decimal newAmount = subscription_invoiceAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) + amountWithoutTax;                      
                                            subscription_invoiceAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, newAmount);
                                        }
                                    }else if(invoiceLineItem.Subscription__r.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY){
                                        if(delSubs_invoiceAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) == null)
                                        {
                                            delSubs_invoiceAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, amountWithoutTax);
                                        }
                                        else
                                        {
                                            Decimal newAmount = delSubs_invoiceAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) + amountWithoutTax;                      
                                            delSubs_invoiceAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, newAmount);
                                        }
                                    }else if(invoiceLineItem.Subscription__r.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE){
                                        if(postageSubs_invoiceAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) == null)
                                        {
                                            postageSubs_invoiceAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, amountWithoutTax);
                                        }
                                        else
                                        {
                                            Decimal newAmount = postageSubs_invoiceAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) + amountWithoutTax;                      
                                            postageSubs_invoiceAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, newAmount);
                                        }
                                    }else if(invoiceLineItem.Subscription__r.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_GIFT){
                                        if(giftSubs_invoiceAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) == null)
                                        {
                                            giftSubs_invoiceAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, amountWithoutTax);
                                        }
                                        else
                                        {
                                            Decimal newAmount = giftSubs_invoiceAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) + amountWithoutTax;                      
                                            giftSubs_invoiceAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, newAmount);
                                        }
                                    }
                                }
                                //START 14 August 2015 UD-2259 Kevin Evasco - Seperate Line Item for Discount
                                else if(amountWithoutTax < 0 && invoiceLineItem.Applied_To_Invoice_Item_ID__c != null) {
                                    if(subscription_discountAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) == null)
                                    {
                                        subscription_discountAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, amountWithoutTax);
                                    }
                                    else
                                    {
                                        Decimal newAmount = subscription_discountAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) + amountWithoutTax;                      
                                        subscription_discountAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, newAmount);
                                    }
                                }
                            }
                        }
                        else{
                            if(amountWithoutTax >= 0)
                            {
                                if(invoiceLineItem.Subscription__r.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION){
                                    if(subscription_invoiceAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) == null)
                                    {
                                        subscription_invoiceAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, amountWithoutTax);
                                    }
                                    else
                                    {
                                        Decimal newAmount = subscription_invoiceAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) + amountWithoutTax;                      
                                        subscription_invoiceAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, newAmount);
                                    }
                                }else if(invoiceLineItem.Subscription__r.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY){
                                    if(delSubs_invoiceAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) == null)
                                    {
                                        delSubs_invoiceAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, amountWithoutTax);
                                    }
                                    else
                                    {
                                        Decimal newAmount = delSubs_invoiceAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) + amountWithoutTax;                      
                                        delSubs_invoiceAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, newAmount);
                                    }
                                }else if(invoiceLineItem.Subscription__r.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE){
                                    if(postageSubs_invoiceAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) == null)
                                    {
                                        postageSubs_invoiceAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, amountWithoutTax);
                                    }
                                    else
                                    {
                                        Decimal newAmount = postageSubs_invoiceAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) + amountWithoutTax;                      
                                        postageSubs_invoiceAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, newAmount);
                                    }
                                }else if(invoiceLineItem.Subscription__r.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_GIFT){
                                    if(giftSubs_invoiceAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) == null)
                                    {
                                        giftSubs_invoiceAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, amountWithoutTax);
                                    }
                                    else
                                    {
                                        Decimal newAmount = giftSubs_invoiceAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) + amountWithoutTax;                      
                                        giftSubs_invoiceAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, newAmount);
                                    }
                                }
                            }
                            //START 14 August 2015 UD-2259 Kevin Evasco - Seperate Line Item for Discount
                            else if(amountWithoutTax < 0 && invoiceLineItem.Applied_To_Invoice_Item_ID__c != null) {
                                if(subscription_discountAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) == null)
                                {
                                    subscription_discountAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, amountWithoutTax);
                                }
                                else
                                {
                                    Decimal newAmount = subscription_discountAmount.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c) + amountWithoutTax;                      
                                    subscription_discountAmount.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, newAmount);
                                }
                            }
                        }
            }
            //END D-3929 18-Nov-2015 Added by S.Puli
                    //END UD-2819 19-Sept-2015 Added By S.Puli
                    //END 14 August 2015 UD-2259 Kevin Evasco - Seperate Line Item for Discount
                    
                    
                    //End UD-1539 07/07/15 VPernicia Uncomment if condition for amountWithoutTax
                    //End UD-1497 06/09 Jason A.
                    //END D-3114 HOTFIX Kevin 06/15/2015: Changed Subscription Identifier from Subscription External Id to Subscription Name
                }
                
                //START UD-1539 06-12 Jason A.
                //Start D-4147 19-Dec-2015 Added by S.Puli - additional filter due to overseas scenario
                if(invoiceLineItem.Charge_Amount__c < 0 && invoiceLineItem.Tax_Amount__c != 0 && invoiceLineItem.Applied_To_Invoice_Item_ID__c == null) { //START/END 14 August 2015 UD-2259 Kevin Evasco - Seperate Line Item for Discount
                    //Start D-4068 09-Dec-2015 Added by S.Puli/J.Abolac
                    adjustmentsFee += invoiceLineItem.Charge_Amount__c+invoiceLineItem.Tax_Amount__c;
                    //End D-4068 09-Dec-2015 Added by S.Puli/J.Abolac           
                } else if(invoiceLineItem.Charge_Amount__c < 0 && invoiceLineItem.Tax_Amount__c == 0 && invoiceLineItem.Applied_To_Invoice_Item_ID__c == null) {
                    otherAdjustmentsFee += invoiceLineItem.Charge_Amount__c;
                }
                //End D-4147 19-Dec-2015 Added by S.Puli
                                //END UD-1539 06-12 Jason A.
            }                                           
            // START UD-1458 6/9/2015 MGaelo Set Start Date as EarliestServiceStartDate & End Date as LatestServiceEndDate
            for(String subId : mapInvoiceLineItem.keySet())
            {            
                Date serviceStart;
                Date serviceEnd;
                Date subEndDate;//START/END D-3878 11/09/15 RReyes
                //START UD-1784 07/02/2015 Added By S.Puli
                earliestStart = null;
                latestEnd = null;
                //START D-3878 11/09/15 RReyes - considers only charges > 0 and compared end date with sub end date
                //START PD-0349 28-May-2016 Added By S.Puli
                for(Invoice_Line_Item__c invoiceLine : mapInvoiceLineItem.get(subId)){
                    
                    if(invoiceLine.Charge_Amount__c > 0){
                        if(invoiceLine.UOM__c <> null ){
                            if(invoiceLine.UOM__c.length() > 8){
                                String uomString = '';
                                uomString = invoiceLine.UOM__c.substring(0,9).toUpperCase();
                                if(uomString <> GlobalVariableClass.NO_CREDIT){
                                    serviceStart = invoiceLine.Service_Start_Date__c;
                                    serviceEnd= invoiceLine.Service_End_Date__c;
                                    subEndDate = invoiceLine.Subscription__r.Zuora__SubscriptionEndDate__c;
                                    
                                    if(earliestStart == null){
                                    earliestStart = serviceStart;
                                    
                                    }else if(serviceStart < earliestStart){
                                    earliestStart = serviceStart;
                                    }
                                    
                                    if(latestEnd == null){
                                    latestEnd = serviceEnd;
                                    }else if(serviceEnd > latestEnd){
                                    latestEnd = serviceEnd;
                                    }
                                    
                                    if(latestEnd != null && subEndDate != null){
                                        if(subEndDate < latestEnd){
                                            latestEnd = subEndDate;
                                        }
                                    }
                                }
                            }else{
                                serviceStart = invoiceLine.Service_Start_Date__c;
                                serviceEnd= invoiceLine.Service_End_Date__c;
                                subEndDate = invoiceLine.Subscription__r.Zuora__SubscriptionEndDate__c;
                                
                                if(earliestStart == null){
                                earliestStart = serviceStart;
                                
                                }else if(serviceStart < earliestStart){
                                earliestStart = serviceStart;
                                }
                                
                                if(latestEnd == null){
                                latestEnd = serviceEnd;
                                }else if(serviceEnd > latestEnd){
                                latestEnd = serviceEnd;
                                }
                                
                                if(latestEnd != null && subEndDate != null){
                                    if(subEndDate < latestEnd){
                                        latestEnd = subEndDate;
                                    }
                                }
                            
                            }
                        }
                            
                    }
                }
                //END PD-0349 28-May-2016 Added By S.Puli
                //END D-3878 11/09/15 RReyes
                if(earliestStart <> null){
                    mapSubtoDate.put (subId, new Map<String, Date> {'startDate' => earliestStart});
                }
                if(latestEnd <> null){
                    mapSubtoDate.get (subId).put('endDate' , latestEnd);
                }
                //END UD-1784 07/02/2015 Added By S.Puli
            }
            // End UD-1458 6/9/2015 MGaelo Set Start Date as EarliestServiceStartDate & End Date as LatestServiceEndDate
            //START D-3929 18-Nov-2015 Added by S.Puli
            Set<Id> oliBundleSet = new Set<Id>();
            //END D-3929 18-Nov-2015 Added by S.Puli
                //START UD-3306 11/25/2015 added by Jason A.
            Map<String, Zuora__Subscription__c> subEarliestMap = new Map<String, Zuora__Subscription__c>();
                //END UD-3306 11/25/2015 added by Jason A.
            if(!subscriptionIdSet.isEmpty()) {
            // START : D-2837 4/30/2015 Alyana Navarro
            // START : UD-1771 7/4/15 VPernicia
            // START : UD-2302 8/12/15 Jason A.
            //START D-3929 18-Nov-2015 Added by S.Puli
                //START UD-3306 11/25/2015 added by Jason A.
    //START UD-3758 02-23-2016 added by Jason A.
                subscriptionList = [SELECT id, name, Main_Package_1__r.Name, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Qty__c,
                                    number_of_copies__c, Subscription_Type__c, PO_Number__c, Zuora__Zuora_Id__c, Billing_Type__c,
                                    Recipient_Contact__r.Name, Subscription_Charge__c, Recipient_Contact__r.Recipient_Number__c, Recipient_Contact__r.Address__r.RecordTypeId, //START/END D-3327 04 August 2015 Kevin Evasco - GST Rate will be based from custom settings only if tax amount is not 0.
                                    Order_Line_Item_Number_1__c, Order_Line_Item_Number_1__r.DTL_Date__c, Createddate, Main_Package_1__r.Package_Type__c
                                    FROM Zuora__Subscription__c
                                    WHERE Name IN: subscriptionIdSet ORDER BY Subscription_Type__c,Main_Package_1__r.Name DESC]; //START/END D-3114 HOTFIX Kevin 06/15/2015: Changed Subscription Identifier from Subscription External Id to Subscription Name 
                //END UD-3306 11/25/2015 added by Jason A.
    //END UD-3758 02-23-2016 added by Jason A.
            //END D-3929 18-Nov-2015 Added by S.Puli
            // END: UD-2302 8/12/15 Jason A.
            // END : UD-1771 7/4/15 VPernicia 
            // END : D-2837 4/30/2015 Alyana Navarro
            }
                //START UD-3306 11/25/2015 added by Jason A.
            DateTime earliestDate = null;
            for(Zuora__Subscription__c sub : subscriptionList){
                if(earliestDate == null){
                    earliestDate = sub.Createddate;
                    subEarliestMap.put('earliestSub',sub);
                }else if(earliestDate >= sub.Createddate){
                    earliestDate = sub.Createddate;
                    subEarliestMap.put('earliestSub',sub);
                }
            }
            BillingAccountPONumber = subEarliestMap.get('earliestSub').PO_Number__c;
                //END UD-3306 11/25/2015 added by Jason A.
            
            //Start D-3112 Hotfix 06/15 added by Jason A./ Von P.          
            if(billingAccount != null) {  
                //START D-3722 Gdelrosario 23/10/2015: change parameter of address             
                finalOutputAddress = AddressHelper.formatAddress(billingAccount.Billing_Contact__r,false,false);
                system.debug('gddr >>: '+ finalOutputAddress);  
                //START D-3722 Gdelrosario 23/10/2015: change parameter of address                              
            }
            //End D-3112 Hotfix 06/15 added by Jason A./ Von P.
            for(Zuora__Subscription__c sub : subscriptionList) {    
                // Start UD-1539 07/04/15 VPernicia
                Decimal amountWithoutTax = 0;
                 //START D-3327 04 August 2015 Kevin Evasco - GST Rate will be based from custom settings only if tax amount is not 0.
                if(sub.Recipient_Contact__r.Address__r.RecordTypeId == ConstantsSLB.getkeyid('Address_Overseas')) {
                    isRecipientOverseas = true;
                }               
                 //END D-3327 04 August 2015 Kevin Evasco - GST Rate will be based from custom settings only if tax amount is not 0.
                //START D-3929 18-Nov-2015 Added by S.Puli
                if (subscription_invoiceAmount.get(sub.Order_Line_Item_Number_1__c) > 0) {
                    amountWithoutTax = subscription_invoiceAmount.get(sub.Order_Line_Item_Number_1__c);//START-END D-3114 HOTFIX Kevin 06/15/2015: Changed Subscription Identifier from Subscription External Id to Subscription Name
                }
                //END D-3929 18-Nov-2015 Added by S.Puli
                // End UD-1539 07/04/15 VPernicia
                //START D-3929 18-Nov-2015 Added by S.Puli
    //START UD-3758 02-23-2016 added by Jason A.
                if(!oliBundleSet.contains(sub.Order_Line_Item_Number_1__c) || sub.Main_Package_1__r.Package_Type__c == GlobalVariableClass.PACKAGETYPE_ADDON){
                    if(sub.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION) {
                        if(sub.Main_Package_1__r.Package_Type__c != GlobalVariableClass.PACKAGETYPE_ADDON){
                            oliBundleSet.add(sub.Order_Line_Item_Number_1__c);
                        }
    //END UD-3758 02-23-2016 added by Jason A.
                            SubscriptionDetails subDetails = new SubscriptionDetails();
                            subDetails.recipientName = sub.Recipient_Contact__r.Name;
                            //START UD-1771 7/4/15 VPernicia
                            subDetails.recipientNumber = sub.Recipient_Contact__r.Recipient_Number__c;
                            //END UD-1771 7/4/15 VPernicia
                            subDetails.subscriptionName = sub.Name;
                    // START UD-3207 Gdelrosario & Von Pernicia 9/11/2015
                            integer intPackageChar = totalPackageChar;
                            integer intPackageChar2 = 0;
                            integer lenPackage = string.valueof(sub.Main_Package_1__r.Name).length();
                            string[] splitPackageName = string.valueof(sub.Main_Package_1__r.Name).split(' ');
                            
                            for (string vals: splitPackageName) {
                                
                                intPackageChar = intPackageChar - vals.length() - 1;
                                intPackageChar2 = intPackageChar2 + vals.length() + 1;
                                
                                if (vals.length() > intPackageChar) {
                                    break;
                                }    
                            }
                            
                            string FinalPackageName = '';
                            
                            if (lenPackage <= totalPackageChar) {
                                FinalPackageName = sub.Main_Package_1__r.Name;
                            } else {
                                FinalPackageName = string.valueof(sub.Main_Package_1__r.Name).substring(0, intPackageChar2 - 1);
                            }
                            
                            if (lenPackage >= totalPackageChar) {
                                FinalPackageName += '<br/>' + string.valueof(sub.Main_Package_1__r.Name).substring(intPackageChar2 - 1, lenPackage);
                            }
                            
                            subDetails.packageName = FinalPackageName;//sub.Main_Package_1__r.Name;                                        
                    // END UD-3207 Gdelrosario & Von Pernicia 9/11/2015
                            //START UD-1784 07/02/2015 Added By S.Puli
                            //subDetails.subStartDate = sub.Zuora__SubscriptionStartDate__c;
                            //subDetails.subEndDate = sub.Zuora__SubscriptionEndDate__c; //START: UD-1138 05/05/2015 Added logic for Recurring Prepaid
                            // START: D-2869 5/8/2015 K. Tan
                            //START: D-2934 5/14/2015 K. Tan - Service Period for Recurring Postpaid
                            
                            if(mapSubtoDate.containsKey(sub.Name)){
                                subDetails.subStartDate = mapSubtoDate.get(sub.Name).get('startDate');
                            }
                            if(mapSubtoDate.containsKey(sub.Name)){
                                subDetails.subEndDate = mapSubtoDate.get(sub.Name).get('endDate');
                            }
                            /*
                                if(sub.Billing_Type__c.contains('Recurring')){
                                    if(sub.Billing_Type__c.contains('Prepaid')){
                                    //START UD-1458 MGaelo 6/10/2016 Added logic for Recurring Prepaid
                                        Date customSettingsUsageDate = Date_Configuration__c.getInstance('Usage Reference Date').date__c.toStartOfMonth();
                                        
                                        if(subDetails.subStartDate >= customSettingsUsageDate){
                                            subDetails.subStartDate = earliestStart;
                                            subDetails.subEndDate = latestEnd;                                  
                                        } else if(subDetails.subStartDate.month() == invoice.Zuora__InvoiceDate__c.month() && subDetails.subStartDate.year() == invoice.Zuora__InvoiceDate__c.year()){
                                        //START UD-1458 MGaelo 6/10/2016 Added logic for Recurring Prepaid
                                            if(subDetails.subStartDate == subDetails.subStartDate.toStartOfMonth()){
                                                subDetails.subEndDate = date.newInstance(subDetails.subStartDate.year(), subDetails.subStartDate.month(), 
                                                Date.daysInMonth(subDetails.subStartDate.year(), subDetails.subStartDate.month()));
                                            } else {
                                                subDetails.subEndDate = date.newInstance(subDetails.subStartDate.year(), subDetails.subStartDate.month() + 1, 
                                                Date.daysInMonth(subDetails.subStartDate.year(), subDetails.subStartDate.month() + 1));
                                            }
                                        } else {                                
                                            if(subDetails.subStartDate == subDetails.subStartDate.toStartOfMonth()){
                                                subDetails.subStartDate = date.newInstance(invoice.Zuora__TargetDate__c.year(), invoice.Zuora__TargetDate__c.month(), 1);
                                                subDetails.subEndDate = date.newInstance(invoice.Zuora__TargetDate__c.year(), invoice.Zuora__TargetDate__c.month(), 
                                                Date.daysInMonth(invoice.Zuora__TargetDate__c.year(), invoice.Zuora__TargetDate__c.month()));
                                            } else {
                                                subDetails.subStartDate = date.newInstance(invoice.Zuora__InvoiceDate__c.year(), invoice.Zuora__InvoiceDate__c.month() + 1, 1);
                                                subDetails.subEndDate = date.newInstance(invoice.Zuora__InvoiceDate__c.year(), invoice.Zuora__InvoiceDate__c.month() + 1, 
                                                Date.daysInMonth(invoice.Zuora__InvoiceDate__c.year(), invoice.Zuora__InvoiceDate__c.month() + 1));
                                            }
                                        }
                                    } else{
                                            if(subDetails.subStartDate.month() == invoice.Zuora__InvoiceDate__c.month() && subDetails.subStartDate.year() == invoice.Zuora__InvoiceDate__c.year()){
                                                subDetails.subEndDate = date.newInstance(subDetails.subStartDate.year(), subDetails.subStartDate.month(), 
                                                Date.daysInMonth(subDetails.subStartDate.year(), subDetails.subStartDate.month()));
                                            } else {
                                                subDetails.subStartDate = date.newInstance(invoice.Zuora__InvoiceDate__c.year(), invoice.Zuora__InvoiceDate__c.month(), 1);
                                                subDetails.subEndDate = date.newInstance(invoice.Zuora__InvoiceDate__c.year(), invoice.Zuora__InvoiceDate__c.month(), 
                                                Date.daysInMonth(invoice.Zuora__InvoiceDate__c.year(), invoice.Zuora__InvoiceDate__c.month()));
                                            }
                                            if(subDetails.subStartDate == subDetails.subStartDate.toStartOfMonth()){
                                                subDetails.subStartDate = date.newInstance(invoice.Zuora__InvoiceDate__c.year(), invoice.Zuora__InvoiceDate__c.month(), 1);
                                                subDetails.subEndDate = date.newInstance(invoice.Zuora__InvoiceDate__c.year(), invoice.Zuora__InvoiceDate__c.month(), 
                                                Date.daysInMonth(invoice.Zuora__InvoiceDate__c.year(), invoice.Zuora__InvoiceDate__c.month()));
                                            } else {
                                                if(subDetails.subStartDate.month() == invoice.Zuora__InvoiceDate__c.month()){
                                                    subDetails.subStartDate = date.newInstance(invoice.Zuora__InvoiceDate__c.year(), invoice.Zuora__InvoiceDate__c.month(), sub.Zuora__SubscriptionStartDate__c.day());                                                 
                                                }
                                                else{
                                                    subDetails.subStartDate = date.newInstance(invoice.Zuora__InvoiceDate__c.year(), invoice.Zuora__InvoiceDate__c.month(), 1);                                                                                     
                                                }                                       
                                                subDetails.subEndDate = date.newInstance(invoice.Zuora__InvoiceDate__c.year(), invoice.Zuora__InvoiceDate__c.month(), 
                                                Date.daysInMonth(invoice.Zuora__InvoiceDate__c.year(), invoice.Zuora__InvoiceDate__c.month()));
                                            }
                                    }
                                }//END: UD-1138 05/05/2015
                                */
                                
                                //END: D-2934 5/14/2015 K. Tan - Service Period for Recurring Postpaid

                                    // END: D-2869 5/8/2015 K. Tan
                                    /*if(subDetails.subStartDate == subDetails.subStartDate.toStartofMonth()){
                                        integer numberOfDays = Date.daysInMonth(subDetails.subStartDate.year(), subDetails.subStartDate.month());
                                        subDetails.subEndDate = Date.newInstance(subDetails.subStartDate.year(),subDetails.subStartDate.month(), numberOfDays);
                                        }
                                            else{
                                                Date nextMonth = subDetails.subStartDate.addMonths(1);
                                                Integer numOfDaysNextMonth = Date.daysInMonth(nextMonth.year(), nextMonth.month());
                                                subDetails.subEndDate = Date.newInstance(nextMonth.year(), nextMonth.month(), numOfDaysNextMonth);
                                                }
                                }*/ // START-END: D-2869 5/8/2015 K. Tan
                            subDetails.quantity = (Integer)sub.Qty__c;
                            //START: 11/09/2015 UD-2828 added by Jason A. 
                            subDetails.amtWithoutTax = 0;
                            subDetails.adminChargeFee = 0;
    //START UD-3758 02-23-2016 added by Jason A.
                            if(!adminChargeSub.containsKey(sub.Order_Line_Item_Number_1__c)){
                                //subDetails.amtWithoutTax = amountWithoutTax;
                                if(sub.Main_Package_1__r.Package_Type__c != GlobalVariableClass.PACKAGETYPE_ADDON ){
                                    if(addOnAmountMap.containskey(sub.Order_Line_Item_Number_1__c)){
                                        amountWithoutTax = amountWithoutTax - addOnAmountMap.get(sub.Order_Line_Item_Number_1__c);
                                        subDetails.amtWithoutTax = amountWithoutTax;
                                    } else {
                                        subDetails.amtWithoutTax = amountWithoutTax;
                                    }
                                } else {
                                    subDetails.amtWithoutTax = addOnAmountMap.get(sub.Order_Line_Item_Number_1__c);
                                    amountWithoutTax = subDetails.amtWithoutTax;
                                }
                            }
                             
                            else{
                                if(sub.Main_Package_1__r.Package_Type__c != GlobalVariableClass.PACKAGETYPE_ADDON ){
                                    subDetails.adminChargeFee = adminChargeSub.get(sub.Order_Line_Item_Number_1__c);
                                }
                                subDetails.amtWithoutTax = amountWithoutTax; //START-END 11/30/2015 D-4005 added by Jason A.
                                subscriptionFee += subDetails.adminChargeFee;
                            }
                            //END: 11/09/2015 UD-2828 added by Jason A. 
                            //START 14 August 2015 UD-2259 Kevin Evasco - Seperate Line Item for Discount
                            if(subscription_discountAmount.containsKey(sub.Order_Line_Item_Number_1__c)){
                                if(sub.Main_Package_1__r.Package_Type__c != GlobalVariableClass.PACKAGETYPE_ADDON ){
                                    Decimal discountAmount = subscription_discountAmount.get(sub.Order_Line_Item_Number_1__c);
                                    if(discountAmount != null){
                                        subDetails.discountAmountWithoutTax = discountAmount; 
                                        discountFee += discountAmount;
                                    }
                                }
                            }
    //END UD-3758 02-23-2016 added by Jason A.
                            //END 14 August 2015 UD-2259 Kevin Evasco - Seperate Line Item for Discount
                            //START: 11/09/2015 UD-2828 added by Jason A. 
                            if(subDetails.amtWithoutTax <> 0){
                                subDetailsList.add(subDetails);     
                            }
                            else{
                                if(adminChargeSub.containsKey(sub.Order_Line_Item_Number_1__c)){
                                    subDetailsList.add(subDetails);
                                }
                            }
                            //END: 11/09/2015 UD-2828 added by Jason A. 
                            //END UD-1784 07/02/2015 Added By S.Puli
                            subscriptionFee += amountWithoutTax;
                        // START : D-2828 5/7/2015 Alyana Navarro - Uncomment
                        
                    } else if(sub.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY) {
                    // END : D-2828 5/7/2015 Alyana Navarro
                        if(delSubs_invoiceAmount.containsKey(sub.Order_Line_Item_Number_1__c)){
                            deliveryChargeFee += delSubs_invoiceAmount.get(sub.Order_Line_Item_Number_1__c);
                        }
                    } else if(sub.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE) {
                        if(postageSubs_invoiceAmount.containsKey(sub.Order_Line_Item_Number_1__c)){
                            postageChargeFee += postageSubs_invoiceAmount.get(sub.Order_Line_Item_Number_1__c);   
                        }
                    } 
                    // START : D-2837 4/30/2015 Alyana Navarro
                    else if(sub.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_GIFT){
                        if(giftSubs_invoiceAmount.containsKey(sub.Order_Line_Item_Number_1__c)){
                            giftChargeFee += giftSubs_invoiceAmount.get(sub.Order_Line_Item_Number_1__c);
                        }
                    }
                }
                //END D-3929 18-Nov-2015 Added by S.Puli
                // END : D-2837 4/30/2015 Alyana Navarro                
                if(sub.PO_Number__c != null) {
                    poNumber = sub.PO_Number__c;
                }
                
                if(sub.Billing_Type__c != null) {
                    billingType = sub.Billing_Type__c;
                }
                // START: D-2901 15/05/15 Added by S.Puli
                onlyFive = false;
                if(subDetailsList.size() == 5){
                    onlyFive = true;
                }
                //END: D-2901 15/05/15 Added by S.Puli
                
            }   
            
            currentChargesBeforeGST += subscriptionFee;
            currentChargesBeforeGST += discountFee; //START/END 14 August 2015 UD-2259 Kevin Evasco - Seperate Line Item for Discount
            currentChargesBeforeGST += deliveryChargeFee;
            currentChargesBeforeGST += postageChargeFee;
            currentChargesBeforeGST += adjustmentsFee;
            //currentChargesBeforeGST += otherAdjustmentsFee;
            
            getTaxRate(); //START/END D-3327 04 August 2015 Kevin Evasco - GST Rate will be based from custom settings only if tax amount is not 
            getPaymentDescription();
            
        }       
        catch(Exception e) {
            system.debug('Error message : ' + e);
			logger.log(e);//Start/End PD-0349 29-May-2016 Added By S.Puli
        }
		logger.save();//Start/End PD-0349 29-May-2016 Added By S.Puli
    }
    
    public void initialize() {  
        previousBalance = 0;    
        totalOutstanding = 0;
        subscriptionFee = 0;
        discountFee = 0; //START/END 14 August 2015 UD-2259 Kevin Evasco - Seperate Line Item for Discount
        deliveryChargeFee = 0;
        postageChargeFee = 0;
        adjustmentsFee = 0.00;
        otherAdjustmentsFee = 0;
        currentChargesBeforeGST = 0;
        //START UD-1781 UD-1819 UD-1763 Kevin Evasco 20 July 2015 - Payment Details Formula
        totalCurrentChargesPaymentDetails = 0;
        totalCurrentChargesPaymentTable = 0;
        //END UD-1781 UD-1819 UD-1763 Kevin Evasco 20 July 2015 - Payment Details Formula
        
        isARMSAccount = false;  
        isSPHIntercompanyBilling = false;
        isRecipientOverseas = false; //START/END D-3327 04 August 2015 Kevin Evasco - GST Rate will be based from custom settings only if tax amount is not 0.
        
        // dueDate = Date.Today().addDays(30); // Start/End D-2934 14May15 K.Tan - commented out. due date must come from the invoce
        
        paymentType = 0;
    }
    
    //START 15 July 2015 Kevin Evasco - UD-1695, UD-1760, UD-1762, UD-1785, UD-1773, UD-1766, UD-1765, UD-1798, D-3208, D-3207, D-3206 - Used Billing Account to determine billing type.
    public void getPaymentDescription() {
    //START UD-3212 11/11/2015 added by Jason A.  
        if(billingAccount.Billing_Type__c.contains(GlobalVariableClass.BILLING_TYPE_RECURRING) && isARMSAccount) {
            if(billingAccount.AGD_Unit__c != null){
                paymentType = 4;
                paymentDescriptionFootnote = 'E-Invoice, ' + billingAccount.AGD_Unit__c;
            }else{
                paymentType = 1;
                paymentDescriptionFootnote = 'Recurring (Inv)';
            }
        } else if (billingAccount.Billing_Type__c.contains(GlobalVariableClass.BILLING_TYPE_RECURRING) && billingAccount.Payment_Mode__c == GlobalVariableClass.CREDITCARD) {      
            paymentType = 2;   
            paymentDescriptionFootnote = 'Recurring (CC)';
        } else if (billingAccount.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE) { 
            if (billingAccount.AGD_Unit__c != null && isARMSAccount) {
                paymentType = 4;
                paymentDescriptionFootnote = 'E-Invoice, ' + billingAccount.AGD_Unit__c;
            } else {
                paymentType = 3;
                paymentDescriptionFootnote = 'Full Payment';
            }
        }
        //END UD-3212 11/11/2015 added by Jason A. 

        if((billingAccount.GIRO_A_C__c != null && billingAccount.GIRO_A_C__c != '') || (billingAccount.Billing_Type__c.contains(GlobalVariableClass.BILLING_TYPE_RECURRING) && billingAccount.Payment_Mode__c == GlobalVariableClass.CREDITCARD)) {
            headnoteType = 1; 
        } else {
            headnoteType = 0;
        }        
    }
    //END 15 July 2015 Kevin Evasco - UD-1695, UD-1760, UD-1762, UD-1785, UD-1773, UD-1766, UD-1765, UD-1798, D-3208, D-3207, D-3206 - Used Billing Account to determine billing type.
    
    public boolean IsRecurring(String billingTypeParam)
    {
        if(billingTypeParam == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID || billingTypeParam == GlobalVariableClass.RECURRING_POSTPAID)   {
            return true;
        }
        else {
            return false;
        }
    }
    //START UD-1248 MGaelo 7/13/2015 added barcode condition
    public void getBarCode(){    
    barChecker = false;
        List<Attachment> attList = [SELECT Id FROM Attachment WHERE ParentId = :billingAccount.Billing_Contact__r.Address__r.Postal_Code__c];
        if(attList.size()>0){
            barcodeAttId = attList[0].Id;
            if(barcodeAttId<>null){
                barChecker = true;
            }
        }
        //END UD-1248 MGaelo 7/13/2015    
    }
    
    public void getTaxRate(){       
        //START 04/17/2015 D-2771 Kevin Evasco - Invoice PDF Generation Optimization
        /* REMOVED FOR D-2771
        try {
            Zuora.zApi zuorApi = new Zuora.zApi();
            //START D-3268 Modified By C.I.Salas - Test Coverage
            if (!Test.isRunningTest()) {
                zuorApi.zlogin();
            }
            //END D-3268 Modified By C.I.Salas - Test Coverage
            String zoql = 'SELECT TaxRate FROM TaxationItem Where InvoiceId =\'' + invoice.Zuora__Zuora_Id__c + '\'';
            List<Zuora.zObject> zobjs = zuorApi.zquery(zoql);
             
            for (Zuora.zObject o : zobjs) {
                taxRate = Integer.valueOf((Decimal)o.getValue('TaxRate')*100);
                break;
            }
        } catch (Exception e) {
        }       
        REMOVED FOR D-2771 */
        //START D-3327 04 August 2015 Kevin Evasco - GST Rate will be based from custom settings only if tax amount is not 0.
        if(isRecipientOverseas == false) {
            try {
                Other__c gstSetting = Other__c.getInstance('GST');
                if(gstSetting.Value__c != null) {
                    taxRate = gstSetting.Value__c;
                } else {
                    taxRate = '7';
                }
            } catch (Exception e) {
                taxRate = '7';
            }
        } else {
            taxRate = '0';
        }
        //END D-3327 04 August 2015 Kevin Evasco - GST Rate will be based from custom settings only if tax amount is not 0.
        //END 04/17/2015 D-2771 Kevin Evasco - Invoice PDF Generation Optimization
        
    }   
    //END : D-2037 03/09/2015 S.Puli
}