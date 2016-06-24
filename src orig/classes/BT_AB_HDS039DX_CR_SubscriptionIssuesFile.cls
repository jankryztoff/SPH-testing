/*
 * Class Name: BT_AB_HDS039DX_CR_SubscriptionIssuesFile
 * @author: Kevin H. Evasco
 * Date: 08/26/2014
 * Project/Requirement: SPH Integration - HDS039DX Interface
 * @description This class populates BA_INT_DATA_POOL__c for HDS039DX batch job. Used together with BT_AS_HDS039DX_SubscriptionIssuesFile Schedulable
 * 
 * History: 08/26/2014 Kevin Evasco Created Skeletal Apex Batchable
 * History: 11/09/2014 Renino Niefes code implementation / SPlitted the batch into two parts, one for debits and another one for credits
 * History: 16/12/2014 Wenjun D-1167
 * History: 03/19/2015 Renino Niefes - D-2562 Get the data from BT_CO_VSS_CreditDebit__c object.  Monthly_Vendor_Data__c is now obsolete
 * History: 03/26/2015 Renino Niefes - D-2615 Missing values for the following: Start Date, Stop Date, DOW Pattern, DOW Pattern PHe
 * History: 03/27/2015 Renino Niefes - D-2615 Changed the mapping field for Subscription Contact int Subscription__r.Recipient_Contact__r
 * History: 2015/06/26 Renino Niefes - hotfix added nullity check and toPlainString for Note Number
 * History: D-4421-UD-3393 and UD-3702 Raviteja 11-Feb-2016 - Restructure the class 
 */


global class BT_AB_HDS039DX_CR_SubscriptionIssuesFile implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    // SOQL Query in getting the interface primary object
    // TO-DO: Update query based on requirements
    //global final String query = 'SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = \'HDS039DX Sample Source\'';    
    global final String interfaceId = 'HDS039DX_CR';
    
    String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);            
    DateTime cutOffEnd = DateUtility.convertDateFromYYYY_MM_DD_ToMonthEnd(batchRunDate);
    DateTime cutOffStart = DateUtility.convertDateFromYYYY_MM_DD_ToMonthStart(batchRunDate);
    
    /* @description 
     * 
     * @param BatchableContext which is a predefined parameter
     * @return Database.QueryLocator
     */ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //List<BA_INT_DATA_POOL__c> resultList = [SELECT Id FROM BA_INT_DATA_POOL__c WHERE Name = :interfaceId];
        //delete resultList;  
        
        //[START 03/27/2015 Renino Niefes - D-2615] Changed the mapping for Contact
        //[START 2015-03-19 D-2562 Renz] MOdify the query to use the new object rather than monthly vendor data
        //START HotFix 30-July-2015 Added by Raviteja - removing the Logic for Inactive vendors
        /*List<Account> lstVendors = [SELECT Id,Name,Vendor_Code__c FROM Account WHERE RecordType.DeveloperName = 'Vendor' AND Vendor_code__c != Null AND Active__c = TRUE];
        List<String> strLstVendor = new List<String>();
        
        System.debug(' SZ0 --------> ' + lstVendors.size());
        
        for(Account acc : lstVendors)
            strLstVendor.add(acc.Vendor_Code__c);
            
        System.debug(' SZ1 --------> ' + strLstVendor.size());
        */   
        //End HotFix 30-July-2015 Added by Raviteja 
        
        String query = '';
        query += ' SELECT Subscription__r.Account_Record_Type__c,';
        query += '  Vendor_Number__c,';
        query += '  Publication_Code__c,';
        query += '  Subscription__r.ID, ';
        query += '  Subscription__r.Recipient_Contact__r.Address__r.Block_House_Number__c,';
        query += '  Subscription__r.Recipient_Contact__r.Address__r.Level_Number__c,';
        query += '  Subscription__r.Recipient_Contact__r.Address__r.Unit_Number__c,';
        query += '  Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name,';
        query += '  Subscription__r.Recipient_Contact__r.Address__r.Street_Name__c,';
        query += '  Subscription__r.Recipient_Contact__r.Address__r.Building_Name__c,';
        query += '  Subscription__r.Recipient_Contact__r.Address__r.Address_Unique_ID__c,';
        query += '  Subscription__r.Zuora__SubscriptionStartDate__c,';
        query += '  Subscription__r.Zuora__SubscriptionEndDate__c,';
        
        query += '  Subscription__r.Recipient_Contact__r.Account.Account_Legacy_Id__c,';
        query += '  Subscription__r.Recipient_Contact__r.Contact_Legacy_Id__c,';    
        query += '  Subscription__r.Pub_Tag__c, ';
        query += '  Subscription__r.Gift_ID__c, ';        
        
        query += '  Recipient_Contact__r.Address__r.Block_House_Number__c,';
        query += '  Recipient_Contact__r.Address__r.Level_Number__c,';
        query += '  Recipient_Contact__r.Address__r.Unit_Number__c,';
        query += '  Recipient_Contact__r.Address__r.Postal_Code__r.Name,';
        query += '  Recipient_Contact__r.Address__r.Street_Name__c,';
        query += '  Recipient_Contact__r.Address__r.Building_Name__c,';
        query += '  Recipient_Contact__r.Address__r.Address_Unique_ID__c,';
        query += '  Recipient_Contact__r.Account.Account_Legacy_Id__c,';
        query += '  Recipient_Contact__r.Contact_Legacy_Id__c,';    
        query += '  Recipient_Contact__r.Recipient_Number__c,';
        
        query += '  Copies__c,';
        query += '  Delivery__c,';  
        query += '  Commission__c,';
        query += '  Manual_Amt__c,';
        query += '  Insertion__c,';
        query += '  Total_Amount__c,';
        query += '  Address__C,';//START/End D-3621 - Hotfix Raviteja - 29Sep2015 - Adding set Address in SOQL
        query += '  Subscription__r.Product_Code__c,';
        query += '  Subscription__r.Effective_Start_Date__c,';
        query += '  Subscription__r.Effective_End_Date__c,';        
        
        //START HotFix 30-July-2015 Added by Raviteja - applying New Logic for Sponsored Indicator from Sponsor_1__c check box
        //query += '  Subscription__r.Sponsored_Indicator__c,';    
        query += '  Subscription__r.Sponsor_1__c,';
        //End HotFix 30-July-2015 Added by Raviteja
        
        query += '  Credit_Debit__c,';
        query += '  Name,';
        query += '  Note_Number__c,';
        query += '  Pagination__c,';
        query += '  Posting_Date__c,';
        query += '  Recipient_Contact__c,';
        
        //START HotFix 23-July-2015 Added by Raviteja - applying New Logic for From and To date
        query += '  From__c,';
        query += '  To__c,';        
        //End HotFix 23-July-2015 Added by Raviteja
        
        //START D-1167 16/12/14 Added by Wenjun : Account Number, Contact Number and Subscription Number
        query += '  Subscription__r.Zuora__Account__r.Account_Auto_Number__c,';
        query += '  Subscription__r.Recipient_Contact__r.Recipient_Number__c,';
        query += '  Subscription__r.Order_Number_1__r.DOW_Pattern__c,';
        query += '  Subscription__r.Name,';
        //END D-1167

        //START 03/26/2015 Renino Niefes - D-2615
        query += '  Subscription__r.Zuora__TermStartDate__c,';
        query += '  Subscription__r.Zuora__TermEndDate__c,';        
        query += '  Subscription__r.Frequency__c,';
        //END 03/26/2015 Renino Niefes - D-2615
        
        //START HotFix 10-July-2015 Added by Raviteja - applying New Logic for Publicationdayspattern
        query += '  Subscription__r.Main_Package_1__r.Frequency_Identifier__c,';        
        //End HotFix 10-July-2015 Added by Raviteja
        
        query += '  Vendor_Group__c';
        query += ' FROM BT_CO_VSS_CreditDebit__c';
        query += ' WHERE Posting_Date__c >=  ' + cutOffStart.format('yyyy-MM-dd');
        query += '  AND Posting_Date__c <=  ' + cutOffEnd.format('yyyy-MM-dd');
        query += '  AND Credit_Debit__c = \'C\'';
        query += '  AND Total_Amount__c > 0';   
        //START / End HotFix 30-July-2015 Added by Raviteja - removing the Logic for Inactive vendors       
        //query += '  AND Vendor_Number__c in :strLstVendor';
        
        //[END 2015-03-19 D-2562 Renz]
        //[END 03/27/2015 Renino Niefes - D-2615]
        
        System.debug(' SZ3 --------> ' + query);
        
        return Database.getQueryLocator(query);
    }
    
    /* @description Executes the business logic and populates BA_INT_DATA_POOL__c with new records based on the interface requirements.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @param scope a list of sObjects from the initial database query
     * @return void
     */ 
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {       
        List<BA_INT_DATA_POOL__c> datapoolList = new List<BA_INT_DATA_POOL__c>();
        
        //[START 03/27/2015 Renino Niefes - D-2615] Use Subscription__r.Recipient_Contact__r instead of Contact__r
        //START D-2615 2015-03-26 Renz Create a set of Product Codes
        //START HotFix 27-July-2015 Added by Raviteja - applying New Logic for Publicationdays pattern. Commented old Product_Publication__c logic apply New logic on Publication__c
        //Set<String> productCodeSet = new Set<String>();
         Set<String> publicationCodeSet = new Set<String>();
        //End HotFix 27-July-2015 Added by Raviteja
        Set<Id> addressIdSet = new Set<Id>(); //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - Adding set Address to store VSS address records        
        for(sObject record : scope)
        {
            BT_CO_VSS_CreditDebit__c so = (BT_CO_VSS_CreditDebit__c)record;
            //START HotFix 27-July-2015 Added by Raviteja - applying New Logic for Publicationdays pattern. Commented old Product_Publication__c logic apply New logic on Publication__c
            //if (so.Subscription__r.Product_Code__c!=null) productCodeSet.add(so.Subscription__r.Product_Code__c);
            if (so.Publication_Code__c != Null) publicationCodeSet.add(so.Publication_Code__c);
            //End HotFix 27-July-2015 Added by Raviteja
            if (so.Address__c != Null) addressIdSet.add(so.Address__c); //START/End D-3621 - Hotfix Raviteja - 29Sep2015 - Adding set Address to store VSS address records
        }
        
        //START HotFix 27-July-2015 Added by Raviteja - applying New Logic for Publicationdays pattern. Commented old Product_Publication__c logic apply New logic on Publication__c
        /*
        //Get all Product Code and create a map of Product Code and Family
        List<Product_Publication__c> productPublicationList = [
            SELECT Id,
                ZProduct__r.ProductCode__c,
                Publication_Code__r.Publication_Code__c,
                Publication_Code__r.Published_Days__c,
                Publication_Code__r.Public_Holiday_Weekday_Pub_Indicator__c,
                Publication_Code__r.Public_Holiday_Weekend_Pub_Indicator__c
            FROM Product_Publication__c WHERE ZProduct__r.ProductCode__c IN :productCodeSet AND Publication_Code__r.ID != null
        ];

        // Create Map of Publication Code using Product Code as KEY
        Map<String, Product_Publication__c> productPublicationMap = new Map<String,Product_Publication__c>();
        Pattern pPublishedDays = Pattern.compile('((?=.*[YN]).{3,9})');
        Pattern pPublicationCode = Pattern.compile('((?=.*\\d)|(?=.*[a-zA-Z]).{2,6})');
        boolean failed = false;
        for (Product_Publication__c rec : productPublicationList) {
            String zPublishedDays = rec.Publication_Code__r.Published_Days__c;
            String zPublicationCode = rec.Publication_Code__r.Publication_Code__c;
            if (zPublishedDays != null && zPublicationCode != null) {
                Matcher mPublishedDays = pPublishedDays.matcher(zPublishedDays);
                Matcher mPublicationCode = pPublicationCode.matcher(zPublicationCode);
                if (mPublishedDays.matches() && mPublicationCode.matches()) {
                    if (!productPublicationMap.containsKey(rec.ZProduct__r.ProductCode__c)) 
                        productPublicationMap.put(rec.ZProduct__r.ProductCode__c, rec);
                } else {
                    failed = true;
                }
            } else {
                failed = true;
            }   
            if (failed) {
                System.debug('FAILED PP-REC-ID:'+rec.Id+' PUB-CODE:'+zPublicationCode+' PUB-DAYS:'+zPublishedDays);
                failed = false;
            }
        }
        //END D-2615 2015-03-26 Renz Create a set of subscription IDs
        */
        
        //START D-3621 - Hotfix Raviteja - 29Sep2015 - Adding mapVssAddress to store VSS address records;
        Map<Id, Address__c> mapVssAddress = new Map<Id, Address__c>([Select Id, Block_House_Number__c, Level_Number__c, Unit_Number__c, Postal_Code__c, Postal_Code__r.Name, 
                                                                        Street_Name__c, Building_Name__c, Address_Unique_ID__c from Address__c where Id in :addressIdSet ]);
        //End D-3621 - Hotfix Raviteja - 29Sep2015 - Adding mapVssAddress to store VSS address records;
        //Get all Publication Code and create a map of publication pattern
        List<Publication__c> PublicationList = [
            SELECT Id, Publication_Code__c, Published_Days__c, Public_Holiday_Weekday_Pub_Indicator__c, Public_Holiday_Weekend_Pub_Indicator__c
            FROM Publication__c WHERE Publication_Code__c IN :publicationCodeSet 
        ];
        
        // Create Map of Publication Code using Product Code as KEY
        Map<String, Publication__c> PublicationMap = new Map<String,Publication__c>();
        for(Publication__c pub: PublicationList){
            PublicationMap.put(pub.Publication_Code__c, pub);
        }       
        //End HotFix 27-July-2015 Added by Raviteja  
        
        //[START 2015-03-19 D-2562 Renz] MOdify the query to use the new object rather than monthly vendor data
        for(sObject record : scope)
        {                      
            
            BT_CO_VSS_CreditDebit__c so = (BT_CO_VSS_CreditDebit__c)record;
                         
            String exportData = '';     
            exportData += so.Vendor_Group__c + ',';//Cus Grp 
            
            exportData += so.Vendor_Number__c + ',';//Vendor Number 
            exportData += so.Subscription__r.Recipient_Contact__r.Account.Account_Legacy_Id__c + ',';//Subscriber Account 
            exportData += so.Subscription__r.Recipient_Contact__r.Contact_Legacy_Id__c + ',';//Recipient Account 
            exportData += so.Publication_Code__c + ',';//Publication Code 
            //START D-3621 - Hotfix Raviteja - 29Sep2015 - Publication Tag assignment moving up.
            if (so.Subscription__r.ID!=null) { 
                 exportData += StringUtility.quoteReplaceStr(so.Subscription__r.Pub_Tag__c) + ',';//Publication Tag
                 }
                 else {
                exportData += 'null,';//Publication Tag 
                }
            //End D-3621 - Hotfix Raviteja - 29Sep2015
            //START D-3621 - Hotfix Raviteja - 29Sep2015 - Adding vss Address in export data
            if(!mapVssAddress.isEmpty() && mapVssAddress.containsKey(so.Address__c)){
                Address__c vssAddress = mapVssAddress.get(so.Address__c);
                
                exportData += StringUtility.quoteReplaceStr(vssAddress.Block_House_Number__c) + ',';//Block Number 
                exportData += StringUtility.quoteReplaceStr(vssAddress.Level_Number__c) + ',';//Level Number 
                exportData += StringUtility.quoteReplaceStr(vssAddress.Unit_Number__c) + ',';//Unit Number 
                exportData += StringUtility.quoteReplaceStr(vssAddress.Postal_Code__r.Name) + ',';//Postal Code 
                exportData += StringUtility.quoteReplaceStr(vssAddress.Street_Name__c) + ',';//Street Name 
                exportData += StringUtility.quoteReplaceStr(vssAddress.Building_Name__c) + ',';//Building Name 
                exportData += StringUtility.quoteReplaceStr(vssAddress.Address_Unique_ID__c) + ',';//Address Line  
            }
            //Nitin Khanna : 10-07-2015 : hotfix : rectifying the period from to end date : start
            //if (so.Subscription__r.ID!=null) {
            else if (so.Subscription__r.ID!=null) {            
                //exportData += StringUtility.quoteReplaceStr(so.Subscription__r.Pub_Tag__c) + ',';//Publication Tag  // Commented by Raviteja D-3621 - Hotfix Raviteja - 29Sep2015
                //End D-3621 - Hotfix Raviteja - 29Sep2015 - Adding vss Address in export data
                exportData += StringUtility.quoteReplaceStr(so.Subscription__r.Recipient_Contact__r.Address__r.Block_House_Number__c) + ',';//Block Number 
                exportData += StringUtility.quoteReplaceStr(so.Subscription__r.Recipient_Contact__r.Address__r.Level_Number__c) + ',';//Level Number 
                exportData += StringUtility.quoteReplaceStr(so.Subscription__r.Recipient_Contact__r.Address__r.Unit_Number__c) + ',';//Unit Number 
                exportData += StringUtility.quoteReplaceStr(so.Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name) + ',';//Postal Code 
                exportData += StringUtility.quoteReplaceStr(so.Subscription__r.Recipient_Contact__r.Address__r.Street_Name__c) + ',';//Street Name 
                exportData += StringUtility.quoteReplaceStr(so.Subscription__r.Recipient_Contact__r.Address__r.Building_Name__c) + ',';//Building Name 
                exportData += StringUtility.quoteReplaceStr(so.Subscription__r.Recipient_Contact__r.Address__r.Address_Unique_ID__c) + ',';//Address Line                 
                
            } else {
                //exportData += 'null,';//Publication Tag // Start/End Commented by Raviteja D-3621 - Hotfix Raviteja - 29Sep2015
                exportData += StringUtility.quoteReplaceStr(so.Recipient_Contact__r.Address__r.Block_House_Number__c) + ',';//Block Number 
                exportData += StringUtility.quoteReplaceStr(so.Recipient_Contact__r.Address__r.Level_Number__c) + ',';//Level Number 
                exportData += StringUtility.quoteReplaceStr(so.Recipient_Contact__r.Address__r.Unit_Number__c) + ',';//Unit Number 
                exportData += StringUtility.quoteReplaceStr(so.Recipient_Contact__r.Address__r.Postal_Code__r.Name) + ',';//Postal Code 
                exportData += StringUtility.quoteReplaceStr(so.Recipient_Contact__r.Address__r.Street_Name__c) + ',';//Street Name 
                exportData += StringUtility.quoteReplaceStr(so.Recipient_Contact__r.Address__r.Building_Name__c) + ',';//Building Name 
                exportData += StringUtility.quoteReplaceStr(so.Recipient_Contact__r.Address__r.Address_Unique_ID__c) + ',';//Address Line 
            }
            //START HotFix 23-July-2015 Added by Raviteja - applying New Logic for From and To date - Commented existing logic
            /*exportData += cutOffStart.format('yyyy-MM-dd') + ',';//From Date 
              exportData += cutOffEnd.addDays(-1).format('yyyy-MM-dd') + ',';//To Date 
            */               
            if(so.From__c != Null){
                Date fromdate = so.From__c;
                exportData += datetime.newInstance(fromdate.year(), fromdate.month(),fromdate.day()).format('yyyy-MM-dd') + ',';//From Date
            }else if(so.Subscription__r.Zuora__SubscriptionStartDate__c >= cutOffStart.date() && so.Subscription__r.Zuora__SubscriptionStartDate__c <= cutOffEnd.addDays(-1).date()){
                //exportData += so.Subscription__r.Zuora__SubscriptionStartDate__c + ',';//From Date         
                  Date subStartdate = so.Subscription__r.Zuora__SubscriptionStartDate__c;   
                  exportData += datetime.newInstance(subStartdate.year(), subStartdate.month(),subStartdate.day()).format('yyyy-MM-dd') + ',';//From Date   
            }else{
                exportData += cutOffStart.format('yyyy-MM-dd') + ',';//From Date
            }
            if(so.To__c != Null){
                Date todate = so.To__c;
                exportData += datetime.newInstance(todate.year(), todate.month(),todate.day()).format('yyyy-MM-dd') + ',';//To Date
            }else if(so.Subscription__r.Zuora__SubscriptionEndDate__c != null){
                    if(so.Subscription__r.Zuora__SubscriptionEndDate__c >= cutOffStart.date() && so.Subscription__r.Zuora__SubscriptionEndDate__c <= cutOffEnd.addDays(-1).date()){
                        //exportData += so.Subscription__r.Zuora__SubscriptionEndDate__c + ',';//To Date
                         Date subEnddate = so.Subscription__r.Zuora__SubscriptionEndDate__c;
                         exportData += datetime.newInstance(subEnddate.year(), subEnddate.month(),subEnddate.day()).format('yyyy-MM-dd') + ',';//To Date
                    }else{
                        exportData += cutOffEnd.addDays(-1).format('yyyy-MM-dd') + ',';//To Date
                    }
            
            }else{
                exportData += cutOffEnd.addDays(-1).format('yyyy-MM-dd') + ',';//To Date 
            }
            //End HotFix 23-July-2015 Added by Raviteja
            //Nitin Khanna : 10-07-2015 : hotfix : rectifying the period from to end date : End             
            
              exportData += so.Copies__c + ',';//Copies             
            
            //Handling Charge = Miscellaneous           
            exportData += (so.Commission__c + so.Pagination__c) + ',';//Handling Charge 
            
            //Insertion Fee = Insertion
            exportData += so.Insertion__c + ',';//Insertion Fee 
            
            //Delivery Fee = Delivery Rate
            exportData += so.Delivery__c + ',';//Delivery Fee 
            
            exportData += so.Total_Amount__c + ',';//Total Amount 
            
            Decimal dNoteNumber = so.Note_Number__c;
            if (dNoteNumber!=null) {
                exportData += dNoteNumber.toPlainString() + ',';//C/N number 
            } else {
                exportData += 'null,';//C/N number 
            }
            
            exportData += so.Subscription__r.Product_Code__c + ',';//Product Code 
            //START D-2615 2015-03-26 Renz - Fill in the missing values
            //Nitin Khanna : 10-07-2015 : hotfix : rectifying the period from to end date : start
            exportData += so.Subscription__r.Zuora__SubscriptionStartDate__c + ',';//Start Date 
            if(so.Subscription__r.Zuora__SubscriptionEndDate__c != null){
                exportData += so.Subscription__r.Zuora__SubscriptionEndDate__c + ',';//Stop Date
            }else if(so.Subscription__r.ID != null){
                exportData += '2099-12-31,';
            }else {
                exportData += 'null,';
            }
            //Nitin Khanna : 10-07-2015 : hotfix : rectifying the period from to end date : end
            if (so.Subscription__r.ID!=null) {
                //START HotFix 27-July-2015 Added by Raviteja - Getting the Pattern from Publication. Commented the Product_Publication__c logic
                //if (productPublicationMap.containsKey(so.Subscription__r.Product_Code__c)) {
                  if (PublicationMap.keyset().size() > 0) {
                    //Product_Publication__c rec = productPublicationMap.get(so.Subscription__r.Product_Code__c);
                    Publication__c pub = PublicationMap.get(so.Publication_Code__c);
                    String zSubscriptionFrequency = so.Subscription__r.Frequency__c;
                    //START HotFix 10-July-2015 Added by Raviteja - commented exisitng functionality applying New Logic for Publicationdays pattern
                    //String zPublishedDays = getPublishedDays(zSubscriptionFrequency, rec.Publication_Code__r.Published_Days__c);
                    // String zPublishedDays = getPublishedDaypattern(so.Subscription__r.Main_Package_1__r.Frequency_Identifier__c, rec.Publication_Code__r.Published_Days__c);
                     String zPublishedDays = getPublishedDaypattern(so.Subscription__r.Main_Package_1__r.Frequency_Identifier__c, pub.Published_Days__c);
                    //End HotFix 10-July-2015 Added by Raviteja
                    String zPHdIndicator = 'N';
                    //boolean zPublicHolidayWeekdayInd = rec.Publication_Code__r.Public_Holiday_Weekday_Pub_Indicator__c;
                    boolean zPublicHolidayWeekdayInd = pub.Public_Holiday_Weekday_Pub_Indicator__c;
                //End HotFix 27-July-2015 Added by Raviteja     
                    if (zPublicHolidayWeekdayInd) {
                        zPHdIndicator = 'Y';
                    }
                    exportData += StringUtility.quoteReplaceStr(zPublishedDays + zPHdIndicator) + ',';//Day of week pattern 
                } else {
                    exportData += 'null,';//Day of week pattern 
                }
            } else {
                exportData += 'null,';//Day of week pattern 
            }
            //END D-2615 2015-03-26 Renz - Fill in the missing values
            
            //START D-2615 2015-03-26 Use StringUtility to enclose the values with quotes
            //START UD-3066 - Hotfix Raviteja - 12Oct2015 - Updating Free gift as blank value
            //exportData += StringUtility.quoteReplaceStr(so.Subscription__r.Gift_ID__c) + ',';//Free Gift
            exportData += 'null,';//Free Gift
            //End UD-3066 - Hotfix Raviteja - 12Oct2015
            //START HotFix 30-July-2015 Added by Raviteja - applying New Logic for Sponsored Indicator from Sponsor_1__c check box
            /*if (so.Subscription__r.Sponsored_Indicator__c!=null&&so.Subscription__r.Sponsored_Indicator__c.trim().equalsIgnoreCase('')) {
                exportData += StringUtility.quoteReplaceStr(so.Subscription__r.Sponsored_Indicator__c) + ',';//Sponsored Indicator 
            } else {
                exportData += 'N,';
            }
            //END D-2615 2015-03-26 Use StringUtility to enclose the values with quotes        
            */
            if (so.Subscription__r.Sponsor_1__c == True) {
                exportData += 'Y,';//Sponsored Indicator 
            } else {
                exportData += 'N,';
            }
            //END HotFix 30-July-2015 Added by Raviteja
            //CR/DR indicator 
            exportData += so.Credit_Debit__c + ',';//CR/DR indicator 
            
            exportData += so.Posting_Date__c + ',';//Transaction Date 
            
            //START UD-3393 11-Feb-2016 Added by Raviteja - Applying the logic for Contact Number
            /*
            if (so.Subscription__r.ID!=null) {
            //START D-1167 16/12/14 Added by Wenjun : Account Number, Contact Number, Subscription Number and Account Sub Group
            // D-1167: according to FDS, it should not be the 18-character Row ID but a system generated sequence number
            //exportData += so.Subscription__r.Zuora__Account__r.ID + ',';//CRSM Account ID
            //exportData += so.Subscription__r.Recipient_Contact__r.ID + ',';//CRSM Contact ID
            //exportData += so.Subscription__r.ID + ',';//CRSM Direct Subscription ID
            
                exportData += so.Subscription__r.Zuora__Account__r.Account_Auto_Number__c + ',';//CRSM Account Number
                if (so.Subscription__r.Recipient_Contact__r.Recipient_Number__c!=null) {
                    exportData += so.Subscription__r.Recipient_Contact__r.Recipient_Number__c.toPlainString() + ','; //CRSM Contact Number
                } else {
                    exportData += 'null,'; //CRSM Contact Number
                }
                exportData += so.Subscription__r.Name + ',';//CRSM Direct Subscription Number - Generated from Zuora
            //END D-1167
            } else {
                exportData += 'null,';//CRSM Account Number
                if (so.Recipient_Contact__r.Recipient_Number__c!=null) {
                    exportData += so.Recipient_Contact__r.Recipient_Number__c.toPlainString() + ','; //CRSM Contact Number
                } else {
                    exportData += 'null,'; //CRSM Contact Number
                }               
                exportData += 'null,';//CRSM Direct Subscription Number - Generated from Zuora          
            }
            */
            if(so.Recipient_Contact__c!=null) {
                if(so.Subscription__r.ID!=null){
                    exportData += so.Subscription__r.Zuora__Account__r.Account_Auto_Number__c + ',';//CRSM Account Number
                    if(so.Recipient_Contact__r.Recipient_Number__c!=null){
                        exportData += so.Recipient_Contact__r.Recipient_Number__c.toPlainString() + ','; //CRSM Contact Number
                     } else {
                        exportData += 'null,'; //CRSM Contact Number
                     }   
                    exportData += so.Subscription__r.Name + ',';//CRSM Direct Subscription Number - Generated from Zuora
                }
                else{
                    exportData += 'null,';//CRSM Account Number
                    if(so.Recipient_Contact__r.Recipient_Number__c!=null){
                        exportData += so.Recipient_Contact__r.Recipient_Number__c.toPlainString() + ','; //CRSM Contact Number
                    } else {
                        exportData += 'null,'; //CRSM Contact Number
                    } 
                    exportData += 'null,';//CRSM Direct Subscription Number - Generated from Zuora
                }
            }
            else if(so.Subscription__r.ID!=null){
                exportData += so.Subscription__r.Zuora__Account__r.Account_Auto_Number__c + ',';//CRSM Account Number
                if (so.Subscription__r.Recipient_Contact__r.Recipient_Number__c!=null) {
                    exportData += so.Subscription__r.Recipient_Contact__r.Recipient_Number__c.toPlainString() + ','; //CRSM Contact Number
                } else {
                    exportData += 'null,'; //CRSM Contact Number
                }
                exportData += so.Subscription__r.Name + ',';//CRSM Direct Subscription Number - Generated from Zuora
            }
            else{
                exportData += 'null,';//CRSM Account Number
                exportData += 'null,'; //CRSM Contact Number
                exportData += 'null,';//CRSM Direct Subscription Number - Generated from Zuora
            }
            //END UD-3393 11-Feb-2016 Added by Raviteja
            
            //START D-2615 2015-03-26 Renz - Fill in the missing values
            if (so.Subscription__r.ID!=null) {    
                //START HotFix 27-July-2015 Added by Raviteja - Getting the Pattern from Publication. Commented the Product_Publication__c logic
                //if (productPublicationMap.containsKey(so.Subscription__r.Product_Code__c)) {
                 if (PublicationMap.keyset().size() > 0) {
                   // Product_Publication__c rec = productPublicationMap.get(so.Subscription__r.Product_Code__c);                  
                    Publication__c pub = PublicationMap.get(so.Publication_Code__c);
                    String zSubscriptionFrequency = so.Subscription__r.Frequency__c;
                    String zPHeIndicator = 'N';
                    boolean zPublicHolidayWeekendInd = false;
                    //zPublicHolidayWeekendInd = rec.Publication_Code__r.Public_Holiday_Weekend_Pub_Indicator__c;
                    zPublicHolidayWeekendInd = pub.Public_Holiday_Weekend_Pub_Indicator__c;
                 //End HotFix 27-July-2015 Added by Raviteja    
                    if (zPublicHolidayWeekendInd) {
                        zPHeIndicator = 'Y';
                    }
                    exportData += zPHeIndicator + ',';//Day of week pattern (PHe)               
                } else {
                    exportData += 'null,';//Day of week pattern (PHe)
                }               
            } else {
                exportData += 'null,';//Day of week pattern (PHe)
            }
             //END D-2615 2015-03-26 Renz - Fill in the missing values   
        
            // Prepare Data Pool information here
            BA_INT_DATA_POOL__c datapoolRecord = new BA_INT_DATA_POOL__c();
            datapoolRecord.Name = interfaceId;          
            datapoolRecord.job_id__c = '1';
            datapoolRecord.group_id__c = 'Detail';
            datapoolRecord.run_for_date__c = Date.today();      
            datapoolRecord.insert_time__c = DateTime.now(); 
            datapoolRecord.export_data__c = exportData;
            
            datapoolList.add(datapoolRecord);
        }
        //[END 2015-03-19 D-2562 Renz]
        //[END 03/27/2015 Renino Niefes - D-2615] Use Subscription__r.Recipient_Contact__r instead of Contact__r
        
        // Set the database savepoint. In case DML Operation fails, use this savepoint for rollback.  
        Savepoint savepointBeforeDML = Database.setSavepoint();
        try
        {
            insert datapoolList;
        }
        catch(Exception e)
        {    
            // Execute Database Rollback 
            Database.rollback(savepointBeforeDML);
            System.debug('BT_AB_HDS039DX_SubscriptionIssuesFile insert operation failed.');
        }
    }
    
    /*
     * @description A method which executes the final actions of the class.
     * 
     * @param BC a BatchableContext which is a predefined parameter
     * @return void
     */ 
    global void finish(Database.BatchableContext BC)
    {
       //Get the batch run date
        String batchRunDate = BT_AU_BATCHRUNREQUEST_UpdateInfo.getBatchRunDate(interfaceId);            
        Date myDate = DateUtility.convertDate(batchRunDate,'-','YMD');
                
        //System.debug('*********************** inside final'+ this.query);
        BatchServiceFacade a1F = new BatchServiceFacade();
        BatchServiceRequestVO serviceRequestVO = new BatchServiceRequestVO();
        serviceRequestVO.setJobStatus(0);
        serviceRequestVO.setJobID(interfaceId);
        serviceRequestVO.setJobDate(myDate);
        System.debug('################ before');
        a1F.delegateBatchCall(serviceRequestVO);
        System.debug('################ after');        

        //Update Batch Run Request's End Time
        BT_AU_BATCHRUNREQUEST_UpdateInfo.updateEndTime(interfaceId);
        
    }
    
    //[START 2015-03-27 D-2615 Renz] Created new method to handle PublishedDays String 
    private String getPublishedDays(String zSubscriptionFrequency, String zPublishedDays) {
        String result_data = '';
        if (zSubscriptionFrequency !=null && !zSubscriptionFrequency.equalsIgnoreCase('default')) {
            if (zSubscriptionFrequency.equalsIgnoreCase('Mon - Fri')) {
                result_data = 'YYYYYNN';
            } else if (zSubscriptionFrequency.equalsIgnoreCase('Mon - Sat')) {
                result_data = 'YYYYYYN';
            } else if (zSubscriptionFrequency.equalsIgnoreCase('Sat - Sun')) {  
                result_data = 'NNNNNYY';
            }           
        } else {
            if (zPublishedDays != null) {
                result_data = zPublishedDays;
            }
        }
        return result_data;
    }   
    //[END 2015-03-27 D-2615 Renz]
    
    //START HotFix 10-July-2015 Added by Raviteja - applying New Logic for Publicationdays pattern    
    private String getPublishedDaypattern(String freqIdentifier, String zPublishedDays) {
        String result_data = '';
        
    if(freqIdentifier == '0')
            result_data = zPublishedDays;
        else if(freqIdentifier == '1') //Mon - Fri
            result_data = 'YYYYYNN';
        else if(freqIdentifier== '2') //Weekend only
            result_data = 'NNNNNYY';
        else if(freqIdentifier == '3') //Mon - Sat
            result_data = 'YYYYYYN';

        return result_data;
    }    
    //End HotFix 10-July-2015 Added by Raviteja  
}