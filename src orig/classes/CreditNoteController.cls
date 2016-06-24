/**
HISTORY  
D-1189 1/22/2015 Alyana Navarro - Reconstructed the entire class
D-2982, UD-1419, UD-1421, and UD-1422 6/10/2015 Alyana Navarro - Reconstructed the entire class
UD-1419 7/20/2015 Alyana Navarro
UD-3253 Change of object, CR for Credit Note 07-Feb-2016 by S.Puli
**/

public class CreditNoteController{   
    
    Logger logger = new Logger('CreditNoteController');
    
    public String accountName {get; set;}
    public String accountNumber {get; set;}
    public String invoiceNumber {get; set;}
    public String creditNoteNumber {get; set;}    
    public Date issueDate {get; set;}
    public String address1 {get; set;}
    public String address2 {get; set;}
    public String address3 {get; set;}
    public String address4 {get; set;}
    public String address5 {get; set;}
    public String finalAddress {get; set;}
    public List<CreditNoteWrapper> creditNoteWrapperList {get; set;}
    public string billingAccountNumber {get; set;}
    public string billContactname {get; set;}
    public Decimal totalAmount {get; set;}
    public Decimal totalBeforeGST {get; set;}
    public Decimal totalAfterGST {get; set;}
    public String textAmount {get; set;}
    public String barcodeAttId {get; set;}
    //START D-3936 11/13/2015 added by Jason A.
    public String AttnTo {get; set; }
    //END D-3936 11/13/2015 added by Jason A.
    //START D-3722 15/10/2015 Gdelrosario: added for variable change in page
    public String finalAddressOutput {get; set;}
    //END D-3722 15/10/2015 Gdelrosario: added for variable change in page
    public boolean isInScope {get; set;}
    
    public class CreditNoteWrapper{
        //public Id invoiceId;                
        public String paymentAccountNumber {get; set;}
        public String invoiceName {get; set;}
        public Date invoiceDate {get; set;}
        //public String publication {get; set;}
        public Decimal credAmountAfterGST {get; set;}
        public Decimal credGSTAmount {get; set;}
        public Decimal credAmountBefGST {get; set;}
        public Decimal credGSTPercentage {get; set;}
    }
    
    public void generateCreditNoteController(){
        
        try{
            CreditNoteWrapper creditNoteWrapper;
            creditNoteWrapperList = new List<CreditNoteWrapper>();
            String sign = 'Negative ';
            Decimal totalToParse = 0;
            Id creditNoteId = ApexPages.currentPage().getParameters().get('id'); // START-END : UD-1419 7/20/2015 Alyana Navarro
            Contact billingContact = new Contact();
            List<Credit_Note__c> creditNoteList = new List<Credit_Note__c>();
            List<Attachment> attachementList = new List<Attachment>();
            List<Credit_Note_Item__c> creditNoteItemList = new List<Credit_Note_Item__c>();

            // START : UD-1419 7/20/2015 Alyana Navarro - Remove commented out code
            // START : UD-2514 8/31/2015 Alyana Navarro
            //START UD-3055 08-Oct-2015 Added by S.Puli - change to ARMS Account Number
            //START D-3936 11/13/2015 added by Jason A.
            
            //creditNoteList = [SELECT id, name, Invoice_ID__r.Zuora__Account__r.AccountNumber, Invoice_ID__r.Zuora__Account__r.Name, 
            //                  Issue_Date__c, Publication__c, Net_Amount_After_GST__c, GST_Amount__c, GST_Rate__c, 
            //                  Invoice_ID__c, Credit_Note_Number__c, Billing_Account__c, Billing_Account__r.Billing_Contact__c, 
            //                  Billing_Account__r.Zuora__Account__r.Name, Account_Number__c, Billing_Account__r.Zuora__AccountNumber__c, 
            //                  Billing_Account__r.Billing_Contact__r.LastName, Billing_Account__r.Billing_Contact__r.Firstname,
            //                  Billing_Account__r.ARMS_Account_Number__c, Billing_Account__r.Billing_Contact__r.Company_Name__c
            //                  FROM Credit_Note__c 
            //                  WHERE Id =: creditNoteId];
            //END D-3936 11/13/2015 added by Jason A.
            //END UD-3055 08-Oct-2015 Added by S.Puli - change to ARMS Account Number
            // END : UD-2514 8/31/2015 Alyana Navarro
            // END : UD-1419 7/20/2015 Alyana Navarro - Remove commented out code
            // START : UD-2891 9/21/2015 Alyana Navarro
            //START : UD-3722 added query 
            
            //Query Credit Note
            creditNoteList = [SELECT id, name, Source_Invoice__r.Zuora__Account__r.AccountNumber, Source_Invoice__r.Zuora__Account__r.Name, 
                              Document_Date__c, Credit_Note_Number__c, Billing_Account__c, Billing_Account__r.Billing_Contact__c, 
                              Billing_Account__r.Zuora__Account__r.Name, Account_Number__c, Billing_Account__r.Zuora__AccountNumber__c, 
                              Billing_Account__r.Billing_Contact__r.LastName, Billing_Account__r.Billing_Contact__r.Firstname,
                              ARMS_Number__c, Billing_Account__r.Billing_Contact__r.Company_Name__c,Tax_Rate__c,
                              Total_Amt_After_Tax__c,Total_Amt_Before_Tax__c,Total_Tax_Amt__c,
                              Total_Tax_Exempt_Amt__c,Source_Invoice__r.Name,Billing_Account__r.Zuora__Account__r.GST_Out_of_Scope__c 
                              FROM Credit_Note__c 
                              WHERE Id =: creditNoteId];
            
            
            //Query Credit Note Item
            //Start UD-2549 18-Mar-2016 Added By S.Puli - requirement for credit note CR
            creditNoteItemList = [SELECT Id,Amt_After_Tax__c,Name,Amt_Before_Tax__c,Credit_Note__c,Invoice__c,Invoice_Date__c,Tax_Amt__c,Tax_Exempt_Amt__c,
                                    Tax_Rate__c,Invoice__r.Name, Invoice__r.ARMS_Invoice_ID__c 
                                    FROM Credit_Note_Item__c 
                                    WHERE Credit_Note__c = :creditNoteId];
            //End UD-2549 18-Mar-2016 Added By S.Puli - requirement for credit note CR
            
            billingContact = [SELECT id, Address__r.Postal_Code__c, RecordTypeId, MailingCountry, Address__r.Building_Name__c,
                  Address__r.Postal_Code__r.Street_Name__c, Address__r.Level_Number__c, Address__r.Street_Name__c,
                  Address__r.Unit_Number__c, Address__r.Country__r.Country_Name__c, Address__r.Postal_Code__r.Name, 
                  Address__r.Block_House_Number__c, Address__r.Postal_Code__r.Building_Name__c, Address__r.Address_1__c, 
                  Address__r.Address_2__c, Address__r.Address_3__c, Address__r.Address_4__c, Address__r.Airline_Number__c, 
                  Address__r.City__c, Address__r.Flight_Number_1__c, Address__r.Flight_Number_2__c, Address__r.Location_Code__r.Location_Name__c, 
                  Address__r.Company_Code__r.Company_Name__c, Address__r.Division_Code__r.Name, Address__r.Department__r.Department_Name__c, 
                  Address__r.Section_Code__r.Section_Name__c,Address__r.RecordTypeId, Address__r.City__r.City_Name__c,
                  //START MMallorca D-3722 04/11/2015 Added address fields for Internal Address Type
                  Address__r.City__r.Country__r.Country_Name__c, 
                  Address__r.City__r.Name,
                  Address__r.Section_Code__r.Name,
                  Address__r.Department__r.Name,
                  Address__r.Company_Code__r.Name,
                  Address__r.Location_Code__r.Name
                  //END MMallorca D-3722 04/11/2015 Added address fields for Internal Address Type    
                  FROM Contact 
                  WHERE id =: creditNoteList[0].Billing_Account__r.Billing_Contact__c];
             //END : UD-3722 added query 
            // END : UD-2891 9/21/2015 Alyana Navarro
            
            attachementList = [SELECT Id 
                               FROM Attachment 
                               WHERE ParentId =: billingContact.Address__r.Postal_Code__c];

            //START D-3722 15/10/2015 Gdelrosario: call for the method to format the address
            //populateAddress(billingContact);
            //START: D-3668 10/22/2015 Added by Kristine Balaoing - commented due to pending fix by Gio
            //START: D-3668 11/5/2015 Added by Kristine Balaoing - removed line because component used not yet in SIT
            finalAddressOutput=AddressHelper.formatAddress(billingContact,false,false);
            //END: D-3668 11/5/2015 Added by Kristine Balaoing
            //END: D-3668 10/22/2015 Added by Kristine Balaoing
            //END D-3722 15/10/2015 Gdelrosario: call for the method to format the address
            
            accountName = creditNoteList[0].Billing_Account__r.Zuora__Account__r.Name;
            accountNumber = creditNoteList[0].Account_Number__c;
        //START UD-3055 08-Oct-2015 Added by S.Puli - change to ARMS Account Number
            if(creditNoteList[0].ARMS_Number__c <> null){
                billingAccountNumber = creditNoteList[0].ARMS_Number__c;
            }else{
                billingAccountNumber = creditNoteList[0].Billing_Account__r.Zuora__AccountNumber__c;
            }
        //END UD-3055 08-Oct-2015 Added by S.Puli 
            //invoiceNumber = invoice.ARMS_Invoice_ID__c;            
            billContactname = creditNoteList[0].Billing_Account__r.Billing_Contact__r.Firstname + ' ' + creditNoteList[0].Billing_Account__r.Billing_Contact__r.LastName; // START-END : UD-2514 8/31/2015 Alyana Navarro
            //START UD-1828 16-July-2015 Added by S.Puli- Change Credit_Note_Number__c from Number to Text
            creditNoteNumber = String.valueOf(creditNoteList[0].Credit_Note_Number__c); // START-END : UD-1422 7/1/2015 Alyana Navarro 
            //END UD-1828 16-July-2015 Added by S.Puli- Change Credit_Note_Number__c from Number to Text
            //START D-3936 11/13/2015 added by Jason A.
            AttnTo = String.valueOf(creditNoteList[0].Billing_Account__r.Billing_Contact__r.Company_Name__c);
            //END D-3936 11/13/2015 added by Jason A.
            totalAmount = 0;
            totalBeforeGST = 0;
            totalAfterGST = 0;
            isInScope = creditNoteList[0].Billing_Account__r.Zuora__Account__r.GST_Out_of_Scope__c;
            
            if(attachementList.size() > 0){
                barcodeAttId = attachementList[0].id;
            } else {
                barcodeAttId = null;
            }
            
            //CR Changes needed below
            if(creditNoteList[0].Document_Date__c != null){
                issueDate = creditNoteList[0].Document_Date__c;
            }
            // START : UD-1419 7/20/2015 Alyana Navarro
            
            for(Credit_Note_Item__c cni : creditNoteItemList){
                
                creditNoteWrapper = new CreditNoteWrapper();
                //creditNoteWrapper.invoiceId = null; 
                //Start UD-2549 18-Mar-2016 Added By S.Puli - requirement for credit note CR
                if(cni.Invoice__r.ARMS_Invoice_ID__c <> null){
                    creditNoteWrapper.invoiceName = cni.Invoice__r.ARMS_Invoice_ID__c;
                }else{
                    creditNoteWrapper.invoiceName = cni.Invoice__r.Name;
                }
                //End UD-2549 18-Mar-2016 Added By S.Puli
                creditNoteWrapper.invoiceDate = cni.Invoice_Date__c;
                //creditNoteWrapper.publication = creditNote.Publication__c;
                creditNoteWrapper.credGSTAmount = cni.Tax_Amt__c;//Decimal.valueOf(cni.Tax_Amt__c);
                creditNoteWrapper.credGSTPercentage = cni.Tax_Rate__c;//Decimal.valueOf(cni.Tax_Rate__c);
                creditNoteWrapper.credAmountAfterGST = cni.Amt_After_Tax__c;//Decimal.valueOf(cni.Amt_After_Tax__c);
                creditNoteWrapper.credAmountBefGST = cni.Amt_Before_Tax__c;//Decimal.valueOf(cni.Amt_Before_Tax__c);
                
                creditNoteWrapperList.add(creditNoteWrapper);
            }
            // END : UD-1419 7/20/2015 Alyana Navarro - Move up
            for(CreditNoteWrapper creditNoteWrap : creditNoteWrapperList){
                totalAmount += creditNoteWrap.credGSTAmount;
                totalBeforeGST += creditNoteWrap.credAmountBefGST;
                totalAfterGST += creditNoteWrap.credAmountAfterGST;
            }
            
            totalToParse = totalAfterGST * -1;
            if(totalAfterGST > 0){
                sign = '';
                totalToParse = totalAfterGST;
            }
            
            textAmount = 'Dollars ' + sign + NumberToWord.english_number(totalToParse) + ' Only';
        } catch(Exception e){
          system.debug('Error Message : ' + e.getMessage());
          logger.log(e);
        }
        
        logger.save();
    }
}