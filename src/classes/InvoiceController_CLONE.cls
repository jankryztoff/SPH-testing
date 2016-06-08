/*
* Class Name: InvoiceController
* @author: Kevin H. Evasco
* Date: 03/09/2015
* Project/Requirement: SPH Invoice Draft Template Controller
* 
 * History: 03/09/2015 MD-23/D-1985 Kevin Evasco Reconstructed class for the new invoice template provided by the client
*/

public class InvoiceController_CLONE {    
    
    public String address1 { get; set; }
    public String address2 { get; set; }
    public String address3 { get; set; }
    public String address4 { get; set; }
    //Start: UD-1089 04/29/2015 James - update address format
    public String address1b { get; set; }
    public String address1c { get; set; }
    //End: UD-1089 04/29/2015 James     
    
    public List<SubscriptionDetails> subDetailsList { get; set; }
    public List<Invoice_Line_Item__c> invoiceLineItemList = new List<Invoice_Line_Item__c>();
    public List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();   
    
    public Map<String,Decimal> subscription_invoiceAmount = new Map<String,Decimal>();

    public Zuora__CustomerAccount__c billingAccount { get; set; }    
    public Zuora__ZInvoice__c invoice { get; set; }   
    
    public String barcodeAttId {get; set;}
    public Id singpostAddressId {get; set;}
    
    public Decimal previousBalance { get; set; }
    public Decimal totalOutstanding { get; set; }
    
    public Decimal subscriptionFee { get; set; }
    public Decimal deliveryChargeFee { get; set; }
    public Decimal postageChargeFee { get; set; }   
    public Decimal adjustmentsFee { get; set; }
    public Decimal otherAdjustmentsFee { get; set; }
    public Decimal currentChargesBeforeGST { get; set; }
    public Decimal totalCurrentCharges { get; set; } 
    public Decimal giftChargeFee {get; set;} // START-END : D-2837 4/30/2015 Alyana Navarro
    
    public String taxRate { get; set; } //START/END 04/17/2015 D-2771 Kevin Evasco - Invoice PDF Generation Optimization
    
    public Date dueDate { get; set; }
    
    public String attentionToCareOf { get; set; }
    public String paymentDescription { get; set; }
    public String paymentDescriptionFootnote { get; set; }
    public String billingType { get; set; }
    public String poNumber { get; set; }
    
    public Boolean isARMSAccount { get; set; }
    public Boolean isSPHIntercompanyBilling { get; set; }   
    
    public Integer paymentType { get; set; }
    
    //START: D-2802 24/04/15 Added by S.Puli - adding ARMS Invoice ID
    public String armsInvId { get; set; }
    //END: D-2802 24/04/15 Added by S.Puli - adding ARMS Invoice ID
    
    // START: D-2901 15/05/15 Added by S.Puli
    public boolean onlyFive { get; set; }
    //END: D-2901 15/05/15 Added by S.Puli
    
    // START : UD-1257 5/1/2015 Alyana Navarro
    public String footerInvoiceAmount {get; set;} 
    public String invoiceNumber {get; set;}
    public Integer checkDigit {get; set;}
    // END : UD-1257 5/1/2015 Alyana Navarro
    
    // START D-3205 7/5/15 VPernicia
    public String BillingAccountPONumber {get; set;}
    // END D-3205 7/5/15 VPernicia
    
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
    }       
    
    public InvoiceController_CLONE() {
    //Start UD-1682 added by Jason A.
        address3 = '';
        address1 = '';
        address2 = '';
        address4 = '';
        address1b = '';
    //End UD-1682 added by Jason A.
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
                        Zuora__DueDate__c, Zuora__Balance2__c, Zuora__Zuora_Id__c,Zuora__TotalAmount__c, ARMS_Invoice_ID__c,
                        Zuora__BillingAccount__r.ARMS_Customer_Number__c, Zuora__TargetDate__c, Zuora__BillingAccount__r.Zuora__PurchaseOrderNumber__c
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
                BillingAccountPONumber = invoice.Zuora__BillingAccount__r.Zuora__PurchaseOrderNumber__c;
                // END : D-3205 7/4/2015 VPernicia
                
                dueDate = invoice.Zuora__DueDate__c; // Start/End D-2934 14May15 K. Tan - set the due date
            }
                        
            //END: D-2802 24/04/15 Added by S.Puli - adding ARMS Invoice ID
            if(invoice != null){
                getTaxRate();
                //START D-2790 22-Apr-2015 Added by Raviteja  - updated the totalCurrentCharges calculation
                  totalCurrentCharges = invoice.Zuora__TotalAmount__c;
                 //End D-2790 22-Apr-2015 Added by Raviteja
                // START : UD-1257 6/1/2015 Alyana Navarro  
                if(invoice.Zuora__BillingAccount__c != null) {
                // START : UD-1656 6/18/2015 Alyana Navarro
            // START : UD-1480 6/11/2015 Alyana Navarro
                    billingAccount = [ SELECT name, Zuora__CustomerAccount__c.Id, Billing_Account_Name_2__c, ARMS_Account_Number__c,                //START/END UD-1105 05-05-2015 Marvin G added ARMS_Account_Number__c field
                    // START: UD-1781 Jul-06-2015 Added by S.Puli
                                        Zuora__Account__r.Name, Zuora__Account__r.AccountNumber, Zuora__Account__r.RecordTypeId, Payment_Mode__c,
                                        Attention_To_Care_Of_Name__c, Attention_To_Care_Of_Salutation__c, Bank__c,
                                        Billing_Contact__r.Address__r.Address_1__c, Billing_Contact__r.Address__r.Address_2__c, 
                                        Billing_Contact__r.Address__r.Address_3__c, Billing_Contact__r.Address__r.Address_4__c,
                                        Billing_Contact__r.Address__r.RecordType.Id, Billing_Contact__r.Address__r.Block_House_Number__c,
                                        Billing_Contact__r.Address__r.Postal_Code__r.Street_Name__c, Billing_Contact__r.Address__r.Level_Number__c,
                                        Billing_Contact__r.Address__r.Unit_Number__c, Billing_Contact__r.Address__r.Postal_Code__r.Name, 
                                        Billing_Contact__r.Address__r.Postal_Code__c, Billing_Contact__r.LastName, Billing_Contact__r.Firstname,
                                        Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c,
                                        Billing_Contact__r.Address__r.Country__r.Country_Name__c, Billing_Contact__r.Address__r.Country__c,
                                        ARMS_Total_Outstanding_Amount__c, Other_PaymentMethod__c, Zuora__AccountNumber__c, 
                                        Zuora__PurchaseOrderNumber__c, Billing_Account_Auto_Number__c, Zuora__Balance__c, Billing_Contact__r.Name,
                                        GIRO_Bank_Code__c, Billing_Contact__r.HomePhone__c, 
                                        Billing_Contact__r.Address__r.RecordType.name,//START/END D-2853 05-06-2015 Marvin G added Address record type
                                        Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c, 
                                        Billing_Contact__r.Address__r.Department__r.Department_Name__c, 
                                        Billing_Contact__r.Address__r.Division_Code__r.Department_Name__c, 
                                        Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c, 
                                        Billing_Contact__r.Address__r.Location_Code__r.Location_Name__c, 
                                        Billing_Contact__r.Address__r.City__r.City_Name__c, 
                                        Billing_Contact__r.Address__r.Airline_Number__c, Billing_Contact__r.Address__r.Flight_Number_1__c, 
                                        Billing_Contact__r.Address__r.Flight_Number_2__c,Attention_To_Care1__c //Start/End Dags UD-1598 06/27/2015 add Attention_To_Care1__c
                                        ,Zuora__Account__c
                    // END: UD-1781 Jul-06-2015 Added by S.Puli
                                    FROM Zuora__CustomerAccount__c
                                    WHERE Id = :invoice.Zuora__BillingAccount__c];
                                    //WHERE Id = 'a0MN0000003ozAqMAI'];
            // END : UD-1480 6/11/2015 Alyana Navarro
                // END : UD-1656 6/18/2015 Alyana Navarro   
                    getBarCode();
                    
                    
                    footerInvoiceAmount = '';
                    invoiceNumber = '';                 
                    Integer dateTotal = 0;
                    Integer accountTotal = 0;
                    Integer documentTotal = 0;
                    String tempAmount = String.valueOf(invoice.Zuora__TotalAmount__c * 100);
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
                        String accountNumber = billingAccount.ARMS_Account_Number__c; // To be replaced by account number
                        for(Integer counter = 0; counter < accountNumber.length(); counter++){
                            accountTotal += Integer.valueOf(accountNumber.substring(counter, counter + 1)) * baseDigitsAccount[counter];
                        }
                    }
                     
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
                    
                    //START UD-2853 05-06-2015 Marvin G
                    if (billingAccount.Billing_Contact__r.Address__r.RecordType.name == 'Overseas') {
                        taxRate = '0';
                    }
                    //END UD-2853 05-06-2015 Marvin G 
                    
                    if(billingAccount.Other_PaymentMethod__c == 'Invoice'){
                        isARMSAccount = true;
                    }
                    
                    if(billingAccount.ARMS_Total_Outstanding_Amount__c != null) {
                        totalOutstanding = billingAccount.ARMS_Total_Outstanding_Amount__c;
                    }
                    
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
                    invoiceLineItemList = [SELECT id, name, Invoice_ID__c, Subscription_ID__c, Subscription_Number__c, Charge_Amount__c, Tax_Exempt_Amount__c, Tax_Amount__c, Subscription__c,
                                            Service_Start_Date__c, Service_End_Date__c
                                            FROM Invoice_Line_Item__c 
                                            WHERE Invoice_ID__c =: invoice.Zuora__Zuora_Id__c];
                }
            }
            
            Map <String, List<Invoice_Line_Item__c>> mapInvoiceLineItem = new Map <String, List<Invoice_Line_Item__c>>();
            Map <String, Map <String, Date>> mapSubtoDate = new Map <String, Map <String, Date>>();
            //END UD-1458 6/9/2015 Added by MGaelo created Map for SubId and InvoiceLineitemsList
            for(Invoice_Line_Item__c invoiceLineItem : invoiceLineItemList) {
                //START D-3114 HOTFIX Kevin 06/15/2015: Changed Subscription Identifier from Subscription External Id to Subscription Name
                if(invoiceLineItem.Subscription_Number__c != null) {
                    subscriptionIdSet.add(invoiceLineItem.Subscription_Number__c); 
                    
                    Decimal amountWithoutTax = 0;
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
                        //START D-2790 22-Apr-2015 Added by Raviteja  - updated the amountWithoutTax calculation
                        amountWithoutTax = invoiceLineItem.Charge_Amount__c;
                        //End D-2790 22-Apr-2015 Added by Raviteja
                    }
                    //Start UD-1497 06/09 Jason A.
                    //Start UD-1539 07/07/15 VPernicia Uncomment if condition for amountWithoutTax
                    if(amountWithoutTax >= 0)
                    {
                        if(subscription_invoiceAmount.get(invoiceLineItem.Subscription_Number__c) == null)
                        {
                            subscription_invoiceAmount.put(invoiceLineItem.Subscription_Number__c, amountWithoutTax);
                        }
                        else
                        {
                            Decimal newAmount = subscription_invoiceAmount.get(invoiceLineItem.Subscription_Number__c) + amountWithoutTax;                      
                            subscription_invoiceAmount.put(invoiceLineItem.Subscription_Number__c, newAmount);
                        }
                    }
                    //End UD-1539 07/07/15 VPernicia Uncomment if condition for amountWithoutTax
                    //End UD-1497 06/09 Jason A.
                    //END D-3114 HOTFIX Kevin 06/15/2015: Changed Subscription Identifier from Subscription External Id to Subscription Name
                }
                
                //START UD-1539 06-12 Jason A.
                if(invoiceLineItem.Charge_Amount__c < 0 && invoiceLineItem.Tax_Amount__c != 0) {
                    adjustmentsFee += invoiceLineItem.Charge_Amount__c;
                                
                } else if(invoiceLineItem.Charge_Amount__c < 0 && invoiceLineItem.Tax_Amount__c == 0) {
                    otherAdjustmentsFee += invoiceLineItem.Charge_Amount__c;
                }
                //END UD-1539 06-12 Jason A.
            }                                           
            // START UD-1458 6/9/2015 MGaelo Set Start Date as EarliestServiceStartDate & End Date as LatestServiceEndDate
            for(String subId : mapInvoiceLineItem.keySet())
            {            
            Date serviceStart;
            Date serviceEnd;
            //START UD-1784 07/02/2015 Added By S.Puli
            earliestStart = null;
            latestEnd = null;
            
                    for(Invoice_Line_Item__c invoiceLine : mapInvoiceLineItem.get(subId)){
                        
                        if(invoiceLine.Charge_Amount__c <> 0){
                        serviceStart = invoiceLine.Service_Start_Date__c;
                        serviceEnd= invoiceLine.Service_End_Date__c;
        
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
                        }
                        
                    }
                if(earliestStart <> null){
                    mapSubtoDate.put (subId, new Map<String, Date> {'startDate' => earliestStart});
                }
                if(latestEnd <> null){
                    mapSubtoDate.get (subId).put('endDate' , latestEnd);
                }
                //END UD-1784 07/02/2015 Added By S.Puli
            }
            // End UD-1458 6/9/2015 MGaelo Set Start Date as EarliestServiceStartDate & End Date as LatestServiceEndDate
            
            if(!subscriptionIdSet.isEmpty()) {
            // START : D-2837 4/30/2015 Alyana Navarro
            // START : UD-1771 7/4/15 VPernicia
                subscriptionList = [SELECT id, name, Main_Package_1__r.Name, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Qty__c,
                                    number_of_copies__c, Subscription_Type__c, PO_Number__c, Zuora__Zuora_Id__c, Billing_Type__c,
                                    Recipient_Contact__r.Name, Subscription_Charge__c, Recipient_Contact__r.Recipient_Number__c
                                    FROM Zuora__Subscription__c
                                    WHERE Name IN: subscriptionIdSet ORDER BY Subscription_Type__c DESC]; //START/END D-3114 HOTFIX Kevin 06/15/2015: Changed Subscription Identifier from Subscription External Id to Subscription Name 
            // END : UD-1771 7/4/15 VPernicia
            // END : D-2837 4/30/2015 Alyana Navarro
            }
        //Start D-3112 Hotfix 06/15 added by Jason A./ Von P.          
            if(billingAccount != null) {
                if(billingAccount.Billing_Contact__r.Address__r.RecordType.Id == ConstantsSLB.getKeyId('Address_Local')) {
                    if(billingAccount.Billing_Contact__r.Address__r.Block_House_Number__c != null){
                        address1 = billingAccount.Billing_Contact__r.Address__r.Block_House_Number__c + ' ';
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c != null){
                        address1 += billingAccount.Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c + ' ';
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Postal_Code__r.Street_Name__c != null){
                        address1 += billingAccount.Billing_Contact__r.Address__r.Postal_Code__r.Street_Name__c;
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Level_Number__c != null){
                        address2 = '#' + billingAccount.Billing_Contact__r.Address__r.Level_Number__c;
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Unit_Number__c != null){
                        address2 += ' - ' + billingAccount.Billing_Contact__r.Address__r.Unit_Number__c;
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Country__r.Country_Name__c != null){
                        address3 = billingAccount.Billing_Contact__r.Address__r.Country__r.Country_Name__c + ' ';
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Postal_Code__r.Name != null){
                        address3 += billingAccount.Billing_Contact__r.Address__r.Postal_Code__r.Name;
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Block_House_Number__c != null){
                        address1b = billingAccount.Billing_Contact__r.Address__r.Block_House_Number__c + ' ';
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Postal_Code__r.Street_Name__c != null){
                        address1b += billingAccount.Billing_Contact__r.Address__r.Postal_Code__r.Street_Name__c;
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c != null){
                        address1c = billingAccount.Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c;
                    }
                } else if(billingAccount.Billing_Contact__r.Address__r.RecordType.Id == ConstantsSLB.getKeyId('Address_Overseas')) {
                    if(billingAccount.Billing_Contact__r.Address__r.Address_1__c != null){
                        address1b = billingAccount.Billing_Contact__r.Address__r.Address_1__c;
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Address_2__c != null){
                        address2 = billingAccount.Billing_Contact__r.Address__r.Address_2__c;
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Address_3__c != null){
                        address3 = billingAccount.Billing_Contact__r.Address__r.Address_3__c;
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Address_4__c != null){
                        address4 = billingAccount.Billing_Contact__r.Address__r.Address_4__c;
                    }
                // START : UD-1656 6/18/2015 Alyana Navarro
                }
                else if(billingAccount.Billing_Contact__r.Address__r.RecordType.Id == ConstantsSLB.getKeyId('Address_Internal')){
                    if(billingAccount.Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c != null){
                        address1b = billingAccount.Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c;
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Department__r.Department_Name__c != null){
                        address2 = billingAccount.Billing_Contact__r.Address__r.Department__r.Department_Name__c;
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Division_Code__r.Department_Name__c != null){
                        address1c = billingAccount.Billing_Contact__r.Address__r.Division_Code__r.Department_Name__c;
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c != null){
                        address3 = billingAccount.Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c;
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Location_Code__r.Location_Name__c != null){
                        address4 = billingAccount.Billing_Contact__r.Address__r.Location_Code__r.Location_Name__c;
                    }
                } else if(billingAccount.Billing_Contact__r.Address__r.RecordType.Id == ConstantsSLB.getKeyId('Address_Airline')){
                    if(billingAccount.Billing_Contact__r.Address__r.City__r.City_Name__c != null){
                        address1b = billingAccount.Billing_Contact__r.Address__r.City__r.City_Name__c;
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Airline_Number__c != null){
                        address2 = billingAccount.Billing_Contact__r.Address__r.Airline_Number__c;
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Flight_Number_1__c != null){
                        address1c = billingAccount.Billing_Contact__r.Address__r.Flight_Number_1__c;
                    }
                    if(billingAccount.Billing_Contact__r.Address__r.Flight_Number_2__c != null){
                        address3 = billingAccount.Billing_Contact__r.Address__r.Flight_Number_2__c;
                    }
                }
                // END : UD-1656 6/18/2015 Alyana Navarro
            }
            //End D-3112 Hotfix 06/15 added by Jason A./ Von P.
            for(Zuora__Subscription__c sub : subscriptionList) {    
                
                // Start UD-1539 07/04/15 VPernicia
                Decimal amountWithoutTax = 0;
                
                if (subscription_invoiceAmount.get(sub.Name) > 0) {
                    amountWithoutTax = subscription_invoiceAmount.get(sub.Name);//START-END D-3114 HOTFIX Kevin 06/15/2015: Changed Subscription Identifier from Subscription External Id to Subscription Name
                }
                // End UD-1539 07/04/15 VPernicia

                if(sub.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION) {  
                    SubscriptionDetails subDetails = new SubscriptionDetails();
                    subDetails.recipientName = sub.Recipient_Contact__r.Name;
                    //START UD-1771 7/4/15 VPernicia
                    subDetails.recipientNumber = sub.Recipient_Contact__r.Recipient_Number__c;
                    //END UD-1771 7/4/15 VPernicia
                    subDetails.subscriptionName = sub.Name;
                    subDetails.packageName = sub.Main_Package_1__r.Name;
                    //START UD-1784 07/02/2015 Added By S.Puli
                    //subDetails.subStartDate = sub.Zuora__SubscriptionStartDate__c;
                    //subDetails.subEndDate = sub.Zuora__SubscriptionEndDate__c; //START: UD-1138 05/05/2015 Added logic for Recurring Prepaid
                    // START: D-2869 5/8/2015 K. Tan
                    //START: D-2934 5/14/2015 K. Tan - Service Period for Recurring Postpaid
                    
                    //system.assertEquals(mapSubtoDate,null);
                    //system.assertEquals(sub.Name, 'a');
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
                    subDetails.amtWithoutTax = amountWithoutTax;
                    if(subDetails.amtWithoutTax <> 0){
                        subDetailsList.add(subDetails);     
                    }
                    //END UD-1784 07/02/2015 Added By S.Puli
                    subscriptionFee += amountWithoutTax;
                // START : D-2828 5/7/2015 Alyana Navarro - Uncomment
                } else if(sub.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY) {
                // END : D-2828 5/7/2015 Alyana Navarro
                    deliveryChargeFee += amountWithoutTax;
                } else if(sub.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE) {
                    postageChargeFee += amountWithoutTax;               
                } 
                // START : D-2837 4/30/2015 Alyana Navarro
                else if(sub.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_GIFT){
                    if(amountWithoutTax != null){
                        giftChargeFee += amountWithoutTax;
                    }
                }
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
            currentChargesBeforeGST += deliveryChargeFee;
            currentChargesBeforeGST += postageChargeFee;
            currentChargesBeforeGST += adjustmentsFee;
            currentChargesBeforeGST += otherAdjustmentsFee;
            
            // START: UD-1781 Jul-06-2015 Added by S.Puli
            List<Zuora__ZInvoice__c> previousInvoice = new List<Zuora__ZInvoice__c>();
            // END: UD-1781 Jul-06-2015 Added by S.Puli
            
            if(isARMSAccount && billingAccount.ARMS_Total_Outstanding_Amount__c != null) {
                previousBalance = billingAccount.ARMS_Total_Outstanding_Amount__c;
            // START: UD-1781 Jul-06-2015 Added by S.Puli
            }else {
                previousInvoice = [ SELECT Name, Zuora__InvoiceDate__c, Zuora__AmountWithoutTax__c, Zuora__TaxAmount__c, Zuora__BillingAccount__c,
                        Zuora__DueDate__c, Zuora__Balance2__c, Zuora__Zuora_Id__c,Zuora__TotalAmount__c, ARMS_Invoice_ID__c,
                        Zuora__BillingAccount__r.ARMS_Customer_Number__c, Zuora__TargetDate__c, Zuora__BillingAccount__r.Zuora__PurchaseOrderNumber__c,Zuora__Account__c
                        FROM Zuora__ZInvoice__c
                        WHERE Zuora__BillingAccount__c = :billingAccount.Id];
                
                system.debug('previousInvoice>>'+previousInvoice);
                
                if(previousInvoice.size()>0){
                    for(Zuora__ZInvoice__c invRec : previousInvoice){
                        
                        if(invRec.Zuora__InvoiceDate__c.month() == invoice.Zuora__InvoiceDate__c.month()-1){
                            if(invRec.Zuora__Balance2__c <> 0){
                            previousBalance = invRec.Zuora__Balance2__c;
                            }
                        }
                    }
                }
                
                
            }
            // END: UD-1781 Jul-06-2015 Added by S.Puli
            paymentDescription = getPaymentDescription();
            
        }       
        catch(Exception e) {
            system.debug('Error message : ' + e);
        }
    }
    
    public void initialize() {  
        previousBalance = 0;    
        totalOutstanding = 0;
        subscriptionFee = 0;
        deliveryChargeFee = 0;
        postageChargeFee = 0;
        adjustmentsFee = 0.00;
        otherAdjustmentsFee = 0;
        currentChargesBeforeGST = 0;
        totalCurrentCharges = 0;
        
        isARMSAccount = false;  
        isSPHIntercompanyBilling = false;
        
        // dueDate = Date.Today().addDays(30); // Start/End D-2934 14May15 K.Tan - commented out. due date must come from the invoce
        
        paymentType = 0;
    }
    
    public String getPaymentDescription() {
        String paymentDescription;
        
        if(IsRecurring(billingType) && isARMSAccount) {
            paymentType = 1;
            paymentDescription = 'Total outstanding amount will be deducted from your bank account with ' + billingAccount.Bank__c + ' on ' + dueDate + '.';
            paymentDescriptionFootnote = 'Recurring (Inv)';
        } else if (IsRecurring(billingType) && billingAccount.Payment_Mode__c == GlobalVariableClass.CREDITCARD) {      
            paymentType = 2;
            paymentDescription = 'Total outstanding amount will be deducted from your credit card account on ' + dueDate + '.';     
            paymentDescriptionFootnote = 'Recurring (CC)';
        } else if (billingType == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID) { 
            paymentType = 3;
            paymentDescriptionFootnote = 'Full Payment';
        } /*else if (<E-Invoice>) {         
            paymentType = Payment.E_INVOICE;
            paymentDescription = 'Please make payment for total outstanding amount by ' + dueDate + '.';
            paymentDescriptionFootnote = 'E-Invoice';
        }*/
        
        return paymentDescription;
    }
    
    public boolean IsRecurring(String billingTypeParam)
    {
        if(billingTypeParam == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_RECURRING_PREPAID || billingTypeParam == GlobalVariableClass.RECURRING_POSTPAID)   {
            return true;
        }
        else {
            return false;
        }
    }
    
    public void getBarCode(){    
        List<Attachment> attList = [SELECT Id FROM Attachment WHERE ParentId = :billingAccount.Billing_Contact__r.Address__r.Postal_Code__c];
        if(attList.size()>0){
            barcodeAttId = attList[0].Id;
        } else{
            barcodeAttId = null;
        }        
    }
    
    public void getTaxRate(){       
        //START 04/17/2015 D-2771 Kevin Evasco - Invoice PDF Generation Optimization
        /* REMOVED FOR D-2771
        try {
            Zuora.zApi zuorApi = new Zuora.zApi();
            zuorApi.zlogin();
            String zoql = 'SELECT TaxRate FROM TaxationItem Where InvoiceId =\'' + invoice.Zuora__Zuora_Id__c + '\'';
            List<Zuora.zObject> zobjs = zuorApi.zquery(zoql);
             
            for (Zuora.zObject o : zobjs) {
                taxRate = Integer.valueOf((Decimal)o.getValue('TaxRate')*100);
                break;
            }
        } catch (Exception e) {
        }       
        REMOVED FOR D-2771 */
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
        //END 04/17/2015 D-2771 Kevin Evasco - Invoice PDF Generation Optimization
        
    }   
    //END : D-2037 03/09/2015 S.Puli
}