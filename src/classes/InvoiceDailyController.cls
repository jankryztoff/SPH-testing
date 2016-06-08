/* Class Name: InvoiceDailyController 
* @author: Sherwin Puli
* Date: 30-Mar-2016
* Project/Requirement: SPH Invoice Template Controller for Daily Invoice
* 
*/

public class InvoiceDailyController {    
    
    public String address1 { get; set; }
    public String address2 { get; set; }
    public String address3 { get; set; }
    public String address4 { get; set; }
    public String address1b { get; set; }
    public String address1c { get; set; }
    public String address5 { get; set; }     
    public String finalOutputAddress { get; set; }   

    public List<SubscriptionDetails> subDetailsList { get; set; }
    public List<Invoice_Line_Item__c> invoiceLineItemList = new List<Invoice_Line_Item__c>();
    public List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();   
    
    public Map<Id,Decimal> subscription_invoiceAmount = new Map<Id,Decimal>();
    public Map<Id,Decimal> subscription_discountAmount = new Map<Id,Decimal>();
    public Map<Id,Decimal> delSubs_invoiceAmount = new Map<Id,Decimal>();
    public Map<Id,Decimal> postageSubs_invoiceAmount = new Map<Id,Decimal>();
    public Map<Id,Decimal> giftSubs_invoiceAmount = new Map<Id,Decimal>();

    public Zuora__CustomerAccount__c billingAccount { get; set; }    
    public Daily_Invoice__c dailyInvoice { get; set; }   
    
    public String barcodeAttId {get; set;}
    public boolean barChecker {get; set;}
    public Id singpostAddressId {get; set;}
    
    public Decimal previousBalance { get; set; }
    public Decimal totalOutstanding { get; set; }
    
    public Decimal subscriptionFee { get; set; } 
    public Decimal discountFee { get; set; } 
    public Decimal deliveryChargeFee { get; set; }
    public Decimal postageChargeFee { get; set; }   
    public Decimal adjustmentsFee { get; set; }
    public Decimal otherAdjustmentsFee { get; set; }
    public Decimal currentChargesBeforeGST { get; set; }
    public Decimal totalCurrentChargesPaymentTable { get; set; } 
    public Decimal totalCurrentChargesPaymentDetails { get; set; } 

    public Decimal giftChargeFee {get; set;} 
    
    public String taxRate { get; set; } 
    
    public Date dueDate { get; set; }
    
    public String billingAccountNumber { get; set; }
    public String attentionToCareOf { get; set; }
    public String paymentDescriptionFootnote { get; set; }
    public String billingType { get; set; }
    public String poNumber { get; set; }
    
    public Boolean isARMSAccount { get; set; }
    public Boolean isSPHIntercompanyBilling { get; set; }   
    public Boolean isRecipientOverseas { get; set; }  
    
    public Integer paymentType { get; set; }
    public Integer headnoteType { get; set; } 
    
    public String armsInvId { get; set; }
    
    public String footerInvoiceAmount {get; set;} 
    public String invoiceNumber {get; set;}
    public Integer checkDigit {get; set;}

    public String BillingAccountPONumber {get; set;}

    public Integer tableLineCounter {get; set;}
    public Integer totalPackageChar {get; set;}

    public class SubscriptionDetails {
        public String recipientName { get; set; }
        public Decimal recipientNumber { get; set; }
        public String subscriptionName { get; set; }
        public String packageName { get; set; }
        public Date subStartDate { get; set; }
        public Date subEndDate { get; set; }      
        public Integer quantity { get; set; }
        public Decimal amtWithoutTax { get; set; }
        public Decimal discountAmountWithoutTax { get; set; }
        public Decimal adminChargeFee { get; set; }
    }       
    public Decimal footerAmount { get; set; } 
    public InvoiceDailyController() {
        address3 = '';
        address1 = '';
        address2 = '';
        address4 = '';
        address1b = '';

    tableLineCounter = Integer.valueOf(Other__c.getInstance('Invoice Total Lines').value__c);
    totalPackageChar = Integer.valueOf(Other__c.getInstance('Invoice Total Package Char').value__c);

        address5 = '';

        initialize();
        generateInvoiceController();
    }
    
    public void generateInvoiceController() {
        try 
        {   
            giftChargeFee = 0.00;
            subDetailsList = new List<SubscriptionDetails>();
            Set<String> subscriptionIdSet = new Set<String>();
            Date earliestStart = null;
            Date latestEnd = null;
            
            List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>();
            Set<String> invoiceZuoraIds = new Set<String>();
            
            dailyInvoice = [SELECT Id, Name, To_ARMS_Time__c, ARMS_Invoice_ID__c, Balance__c, Billing_Account__c, Invoice_Date__c, 
                            Is_PDF_Generated__c, Payment_Amt__c, Prev_Bal__c, Tax_Amt__c, Tax_Exempt_Amt__c, Total_Amt__c,
                            Billing_Account__r.Zuora__Account__r.RecordTypeId, Billing_Account__r.Other_PaymentMethod__c,
                            Billing_Account__r.Zuora__Account__r.GST_Invoice__c,Billing_Account__r.GIRO_A_C__c, 
                            Billing_Account__r.Payment_Mode__c 
                            FROM Daily_Invoice__c 
                            WHERE id =: ApexPages.currentPage().getParameters().get('id')];
            
            invoiceList = [SELECT Name, Zuora__InvoiceDate__c, Zuora__AmountWithoutTax__c, Zuora__TaxAmount__c, Zuora__BillingAccount__c,
                        Zuora__DueDate__c, Zuora__Balance2__c, Zuora__Zuora_Id__c,Zuora__TotalAmount__c, ARMS_Invoice_ID__c, Previous_Balance__c, 
                        Zuora__BillingAccount__r.ARMS_Customer_Number__c, Zuora__TargetDate__c, Zuora__BillingAccount__r.Zuora__PurchaseOrderNumber__c, 
                        Zuora__BillingAccount__r.GIRO_A_C__c, Zuora__BillingAccount__r.Payment_Mode__c, Zuora__PaymentAmount__c,Daily_Invoice__c 
                        FROM Zuora__ZInvoice__c
                        WHERE Daily_Invoice__c = :dailyInvoice.Id];

            if(dailyInvoice <> null){
                if(dailyInvoice.ARMS_Invoice_ID__c <> null){
                    armsInvId = dailyInvoice.ARMS_Invoice_ID__c;
                } else {
                    armsInvId = dailyInvoice.Name;
                }
                
                dueDate = dailyInvoice.Invoice_Date__c; 
                
                if((dailyInvoice.Billing_Account__r.GIRO_A_C__c != null && dailyInvoice.Billing_Account__r.GIRO_A_C__c != '') || dailyInvoice.Billing_Account__r.Payment_Mode__c == GlobalVariableClass.CREDITCARD) {
                    dueDate = dueDate.addDays(2);
                }
            }
            
            if(dailyInvoice.Billing_Account__c <> null){
                billingAccount = [ SELECT name, Zuora__CustomerAccount__c.Id, Billing_Account_Name_2__c, ARMS_Account_Number__c,                
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
                                    FROM Zuora__CustomerAccount__c
                                    WHERE Id = :dailyInvoice.Billing_Account__c];            
        
                    getBarCode();

                    footerInvoiceAmount = '';
                    invoiceNumber = '';                 
                    Integer dateTotal = 0;
                    Integer accountTotal = 0;
                    Integer documentTotal = 0;
                    String tempAmount = String.valueOf(dailyInvoice.Total_Amt__c * 100);
                    tempAmount = tempAmount.substring(0, tempAmount.length() - 3);
                    String dateTodayString = String.valueOf(dailyInvoice.Invoice_Date__c).substring(0, 10);            
                    List<Integer> baseDigitsDate = new List<Integer>{5, 4, 3, 2, 0, 2, 7, 0, 5, 4};
                    List<Integer> baseDigitsAccount = new List<Integer>{5, 4, 3, 2, 7, 6, 5, 4, 3, 2};
                    for(Integer counter = 0; counter < 11 - tempAmount.length(); counter++){
                        footerInvoiceAmount += 0;
                    }
                    footerInvoiceAmount += tempAmount;
                    if(dailyInvoice.ARMS_Invoice_ID__c != null){
                        invoiceNumber = String.valueOf(dailyInvoice.ARMS_Invoice_ID__c).substring(2, dailyInvoice.ARMS_Invoice_ID__c.length());
                    } else {
                        invoiceNumber = dailyInvoice.name.substring(2, dailyInvoice.name.length());
                    }
                                                                
                    for(Integer counter = 0; counter < dateTodayString.length(); counter++){
                        if(dateTodayString.substring(counter, counter+1) != '-'){
                            dateTotal += Integer.valueOf(dateTodayString.substring(counter, counter+1)) * baseDigitsDate[counter];
                        }
                    }
                                        
                    if(billingAccount.ARMS_Account_Number__c != null){
                        billingAccountNumber = billingAccount.ARMS_Account_Number__c; 
                        String accountNumber = billingAccount.ARMS_Account_Number__c; 
                        for(Integer counter = 0; counter < accountNumber.length(); counter++){
                            accountTotal += Integer.valueOf(accountNumber.substring(counter, counter + 1)) * baseDigitsAccount[counter];
                        }
                    }

                    else {
                        billingAccountNumber = billingAccount.Zuora__AccountNumber__c;
                    }
                     
                    if(dailyInvoice.ARMS_Invoice_ID__c != null){
                        String docNumber = dailyInvoice.ARMS_Invoice_ID__c;
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
                        
                    //Populate Amounts
                    if(billingAccount.Other_PaymentMethod__c == 'Invoice'){
                    isARMSAccount = true;
                    }
                    
                    if(dailyInvoice.Prev_Bal__c != null) {
                        previousBalance = dailyInvoice.Prev_Bal__c;
                    } else { 
                        previousBalance = billingAccount.Zuora__Balance__c - dailyInvoice.Total_Amt__c + dailyInvoice.Payment_Amt__c; 
                    }
                    totalOutstanding = previousBalance + dailyInvoice.Total_Amt__c;     
                    
                    if(totalOutstanding < 0)
                        totalOutstanding = 0;

                    totalCurrentChargesPaymentDetails = dailyInvoice.Total_Amt__c; 
                         
                    
                    totalCurrentChargesPaymentTable= dailyInvoice.Total_Amt__c;                 
                    
                    footerAmount = totalOutstanding;
                    
                    if(billingAccount.Zuora__Account__r.RecordTypeId == ConstantsSLB.getKeyId('Account_Direct SPH Inter-Division')) {
                        isSPHIntercompanyBilling = true;                    
                    }
                    
                    if(billingAccount.Attention_To_Care_Of_Salutation__c != null) {
                        attentionToCareOf = billingAccount.Attention_To_Care_Of_Salutation__c + ' ' + billingAccount.Attention_To_Care1__c;
                    } else {                        
                        attentionToCareOf = billingAccount.Attention_To_Care1__c;
                    }  
                
            }
            
            if(!invoiceList.isEmpty()){
                for(Zuora__ZInvoice__c invoice : invoiceList){
                    if(invoice.Zuora__Zuora_Id__c != null) {
                        invoiceZuoraIds.ADD(invoice.Zuora__Zuora_Id__c);
                    }
                }
            }

            if(!invoiceZuoraIds.isEmpty()){
                invoiceLineItemList = [SELECT id, name, Invoice_ID__c, Subscription_ID__c, Subscription_Number__c, Charge_Amount__c, Tax_Exempt_Amount__c, Tax_Amount__c, 
                                        Subscription__c,Service_Start_Date__c, Service_End_Date__c, Applied_To_Invoice_Item_ID__c, UOM__c, ID__c,Product_Name__c,
                                        Subscription__r.Zuora__SubscriptionEndDate__c, Subscription__r.Order_Line_Item_Number_1__c, Subscription__r.Subscription_Type__c  
                                        FROM Invoice_Line_Item__c 
                                        WHERE Invoice_ID__c IN :invoiceZuoraIds];
            }

            Map <String, List<Invoice_Line_Item__c>> mapInvoiceLineItem = new Map <String, List<Invoice_Line_Item__c>>();
            Map <String, Map <String, Date>> mapSubtoDate = new Map <String, Map <String, Date>>();
            Map<String, String> invLineToUOM_Map = new Map<String, String>();
            Map<id, decimal> adminChargeSub = new Map<id, decimal>(); 
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

            for(Invoice_Line_Item__c invoiceLineItem : invoiceLineItemList) {
                if(invoiceLineItem.Subscription_Number__c != null) {
                    subscriptionIdSet.add(invoiceLineItem.Subscription_Number__c); 
                    
                    Decimal amountWithoutTax = 0;
                    Decimal adminCharge = 0; 
                    if (mapInvoiceLineItem.containsKey(invoiceLineItem.Subscription_Number__c)){
                        mapInvoiceLineItem.get(invoiceLineItem.Subscription_Number__c).add(invoiceLineItem);
                    }
                    
                    else{
                        mapInvoiceLineItem.put(invoiceLineItem.Subscription_Number__c, new List<Invoice_Line_Item__c>()); 
                        mapInvoiceLineItem.get(invoiceLineItem.Subscription_Number__c).add(invoiceLineItem);
                    }
                    
                    if(invoiceLineItem.Charge_Amount__c != NULL && invoiceLineItem.Tax_Amount__c != NULL)
                    {   
                        if(invoiceLineItem.Product_Name__c != 'Admin Charge'){
                            amountWithoutTax = invoiceLineItem.Charge_Amount__c+invoiceLineItem.Tax_Amount__c;
                        }
                        else{
                            adminCharge = invoiceLineItem.Charge_Amount__c+invoiceLineItem.Tax_Amount__c;
                            if(invoiceLineItem.Charge_Amount__c <> 0){  
                                if(!adminChargeSub.containsKey(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c)){   
                                    adminChargeSub.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, invoiceLineItem.Charge_Amount__c+invoiceLineItem.Tax_Amount__c); 
                                }else{
                                    Decimal tempAdminCharge = 0;
                                    tempAdminCharge = adminChargeSub.get(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c);
                                    adminChargeSub.put(invoiceLineItem.Subscription__r.Order_Line_Item_Number_1__c, invoiceLineItem.Charge_Amount__c + tempAdminCharge+invoiceLineItem.Tax_Amount__c);
                                }
                            }
                        }
                    }
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
                }
                
                //START UD-1539 06-12 Jason A.
                //Start D-4147 19-Dec-2015 Added by S.Puli - additional filter due to overseas scenario
                if(invoiceLineItem.Charge_Amount__c < 0 && invoiceLineItem.Tax_Amount__c != 0 && invoiceLineItem.Applied_To_Invoice_Item_ID__c == null) { 
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
                for(Invoice_Line_Item__c invoiceLine : mapInvoiceLineItem.get(subId)){
                    
                    if(invoiceLine.Charge_Amount__c > 0){
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
                //END D-3878 11/09/15 RReyes
                if(earliestStart <> null){
                    mapSubtoDate.put (subId, new Map<String, Date> {'startDate' => earliestStart});
                }
                if(latestEnd <> null){
                    mapSubtoDate.get (subId).put('endDate' , latestEnd);
                }
                //END UD-1784 07/02/2015 Added By S.Puli
            }

            Set<Id> oliBundleSet = new Set<Id>();
            Map<String, Zuora__Subscription__c> subEarliestMap = new Map<String, Zuora__Subscription__c>();
                //END UD-3306 11/25/2015 added by Jason A.
            if(!subscriptionIdSet.isEmpty()) {

                subscriptionList = [SELECT id, name, Main_Package_1__r.Name, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Qty__c,
                                    number_of_copies__c, Subscription_Type__c, PO_Number__c, Zuora__Zuora_Id__c, Billing_Type__c,
                                    Recipient_Contact__r.Name, Subscription_Charge__c, Recipient_Contact__r.Recipient_Number__c, Recipient_Contact__r.Address__r.RecordTypeId, //START/END D-3327 04 August 2015 Kevin Evasco - GST Rate will be based from custom settings only if tax amount is not 0.
                                    Order_Line_Item_Number_1__c, Order_Line_Item_Number_1__r.DTL_Date__c, Createddate
                                    FROM Zuora__Subscription__c
                                    WHERE Name IN: subscriptionIdSet ORDER BY Subscription_Type__c,Main_Package_1__r.Name DESC]; 
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

            if(billingAccount != null) {              
                finalOutputAddress = AddressHelper.formatAddress(billingAccount.Billing_Contact__r,false,false);
                system.debug('gddr >>: '+ finalOutputAddress);                              
            }
            for(Zuora__Subscription__c sub : subscriptionList) {    
                Decimal amountWithoutTax = 0;
                if(sub.Recipient_Contact__r.Address__r.RecordTypeId == ConstantsSLB.getkeyid('Address_Overseas')) {
                    isRecipientOverseas = true;
                }               
                if (subscription_invoiceAmount.get(sub.Order_Line_Item_Number_1__c) > 0) {
                    amountWithoutTax = subscription_invoiceAmount.get(sub.Order_Line_Item_Number_1__c);
                }

                if(!oliBundleSet.contains(sub.Order_Line_Item_Number_1__c)){
                    if(sub.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION) {

                            oliBundleSet.add(sub.Order_Line_Item_Number_1__c);
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
                            
                            subDetails.packageName = FinalPackageName;
                            
                            if(mapSubtoDate.containsKey(sub.Name)){
                                subDetails.subStartDate = mapSubtoDate.get(sub.Name).get('startDate');
                            }
                            if(mapSubtoDate.containsKey(sub.Name)){
                                subDetails.subEndDate = mapSubtoDate.get(sub.Name).get('endDate');
                            }
                            
                            subDetails.quantity = (Integer)sub.Qty__c;
                            //START: 11/09/2015 UD-2828 added by Jason A. 
                            subDetails.amtWithoutTax = 0;
                            subDetails.adminChargeFee = 0;
                            if(!adminChargeSub.containsKey(sub.Order_Line_Item_Number_1__c)){
                                subDetails.amtWithoutTax = amountWithoutTax;
                            }
                            else{
                                subDetails.adminChargeFee = adminChargeSub.get(sub.Order_Line_Item_Number_1__c);
                                subDetails.amtWithoutTax = amountWithoutTax; //START-END 11/30/2015 D-4005 added by Jason A.
                                subscriptionFee += subDetails.adminChargeFee;
                            }
                            //END: 11/09/2015 UD-2828 added by Jason A. 
                            //START 14 August 2015 UD-2259 Kevin Evasco - Seperate Line Item for Discount
                            if(subscription_discountAmount.containsKey(sub.Order_Line_Item_Number_1__c)){
                                Decimal discountAmount = subscription_discountAmount.get(sub.Order_Line_Item_Number_1__c);
                                if(discountAmount != null){
                                    subDetails.discountAmountWithoutTax = discountAmount; 
                                    discountFee += discountAmount;
                                }
                            }
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
        }
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

        
    }   
    //END : D-2037 03/09/2015 S.Puli
}