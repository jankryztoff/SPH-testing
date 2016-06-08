public class ADM_PubCopiesController {
    
    Map<String, Set<Date>> mapPubCodeToNonPubDt = new Map<String, Set<Date>>();
    Map<String, String> mapPubCodeToUOM = new Map<String, String>();
    public Date startDate {get;set;}
    public Date endDate {get;set;}
    public String subName {get;set;}
    public Boolean isCredit {get;set;}
    public Decimal totalRefund {get;set;}
    public List<PubCopyObj> lstPubCopies {get;set;}
    public List<UsageObj> lstUsages {get;set;}
    public Set<String> setHeaders {get;set;}
    
    public ADM_PubCopiesController() {
        lstPubCopies = new List<PubCopyObj>();
        lstUsages = new List<UsageObj>();
        setHeaders = new Set<String>();
    }

    public PageReference calculateCopies()
    {
        lstPubCopies = new List<PubCopyObj>();
        setHeaders = new Set<String>();
        setHeaders.add('Publication Code');
        
        //Get subscription detail
        Zuora__Subscription__c sub = [SELECT Id, Name, qty__c, Product_Code__c, Vendor_1__c, Vendor_1__r.Vendor_Code__c, Vendor_1__r.Vendor_Group__c, 
            Recipient_Contact__r.Address__r.RecordType.DeveloperName, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c,Ph_d__c, Ph_e__c,
            Main_Package_1__r.Package_Type__c, Main_Package_1__r.Package_Price__c, Main_Package_1__r.Frequency_Identifier__c,Delivered_By_1__c, Frequency_1__c
            FROM Zuora__Subscription__c WHERE Name = :subName];
        
        //Get Public Holidays in this month
        Set<Date> setHolidays = getPublicHolidays(startDate,endDate);
        
        //Get Publication related data
        getPublicationData(sub, setHolidays);
        
        return null;
    }
    
    public PageReference calculateUsage()
    {
        lstUsages = new List<UsageObj>();
        totalRefund = 0.0;
        
        //Get subscription detail
        Zuora__Subscription__c sub = [SELECT Id, Name, qty__c, Product_Code__c, Vendor_1__c, Vendor_1__r.Vendor_Code__c, Vendor_1__r.Vendor_Group__c, 
            Recipient_Contact__r.Address__r.RecordType.DeveloperName, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c,Ph_d__c, Ph_e__c,
            Main_Package_1__r.Package_Type__c, Main_Package_1__r.Package_Price__c, Main_Package_1__r.Frequency_Identifier__c,Delivered_By_1__c, Frequency_1__c
            FROM Zuora__Subscription__c WHERE Name = :subName];
        
        //Get Public Holidays in this month
        Set<Date> setHolidays = getPublicHolidays(startDate,endDate);
        
        //Get Publication related data
        getUsagsQty(sub, setHolidays);
        
        return null;
    }
    
    //Get Public Holidays for the month
    public Set<Date> getPublicHolidays(Date startDT, Date endDT)
    {
        Set<Date> setDates = new Set<Date>();

        for (Public_Holiday__c tmp : [SELECT Holiday_Date__c FROM Public_Holiday__c 
                                      WHERE Holiday_Date__c >= :startDT AND Holiday_Date__c <= :endDT]) 
        { 
            setDates.add(tmp.Holiday_Date__c);
        }
        
        return setDates;
    }
    
    public void getPublicationData(Zuora__Subscription__c sub, Set<Date> setHolidays)
    {
        Map<Id, Set<Date>> mapPubIdToNonPubDates = new Map<Id, Set<Date>>();
        Map<Id, PubIssueHelper.PublicationPattern> mapPubIdToPubPattern = new Map<Id, PubIssueHelper.PublicationPattern>();
        Set<Id> setPublicationIds = new Set<Id>();
        Map<Id, Publication__c> mapPubIdToObj = new Map<Id, Publication__c>();
        String productCode = sub.Product_Code__c;
        Map<Integer, String> mapMthName = new Map<Integer, String>();
        
        mapMthName.put(1, 'Jan'); mapMthName.put(2, 'Feb'); mapMthName.put(3, 'Mar'); mapMthName.put(4, 'Apr'); mapMthName.put(5, 'May'); mapMthName.put(6, 'Jun');
        mapMthName.put(7, 'Jul'); mapMthName.put(8, 'Aug'); mapMthName.put(9, 'Sep'); mapMthName.put(10, 'Oct'); mapMthName.put(11, 'Nov'); mapMthName.put(12, 'Dec');
                
        //Retrieve Product Code to Publication Mapping
        for(Product_Publication__c prodPub : [SELECT ZProduct__r.ProductCode__c, Publication_Code__c, Publication_Code__r.Publication_Code__c 
                                        FROM Product_Publication__c WHERE ZProduct__r.ProductCode__c = :productCode])
        {
            Id pubId = prodPub.Publication_Code__c;
            setPublicationIds.add(pubId);
        }
        
        mapPubIdToObj = new Map<Id, Publication__c>([SELECT Id, Name, Publication_Code__c, Published_Days__c, Publication_Next_Start_Date__c, 
                                  Frequency_Code__c, Public_Holiday_Weekend_Pub_Indicator__c, Public_Holiday_Weekday_Pub_Indicator__c 
                                  FROM Publication__c WHERE ID in :setPublicationIds AND Publication_Next_Start_Date__c != null]);
        
        //Only retrieve Non Pub Dates in this particular month
        for(Non_Publication_Day__c pubDay : [SELECT Id, Publication__c, Publication_Code__c, Non_Publication_Date__c 
              FROM Non_Publication_Day__c WHERE Publication__c IN : setPublicationIds 
              AND Non_Publication_Date__c >= :startDate AND Non_Publication_Date__c <= :endDate])
        {
            if(!mapPubIdToNonPubDates.containsKey(pubDay.Publication__c))
                mapPubIdToNonPubDates.put(pubDay.Publication__c, new Set<Date> {pubDay.Non_Publication_Date__c});
            else
                mapPubIdToNonPubDates.get(pubDay.Publication__c).add(pubDay.Non_Publication_Date__c);
        }
        System.debug('=====> mapPubIdToNonPubDates: ' + mapPubIdToNonPubDates);
        
        //Generate Publication Pattern for Daily Publications
        for(Publication__c pubObj : mapPubIdToObj.values())
        {
            if(pubObj.Frequency_Code__c == 'D' || pubObj.Frequency_Code__c == 'W') //Daily Publication
                mapPubIdToPubPattern.put(pubObj.Id, PubIssueHelper.generatePubPattern(pubObj));
        }
        
        System.debug('=====> mapPubIdToPubPattern: ' + mapPubIdToPubPattern);
        
        /******************** Get Publish Dates for each Publication ***************************/
        for(Publication__c pubObj : mapPubIdToObj.values())
        {
             List<Date> lstDates = new List<Date>();
             Date nextIssueDate = pubObj.Publication_Next_Start_Date__c;
             List<PubMthCopy> lstMthCopies = new List<PubMthCopy>();
             Integer totalCount = 0;
            
            //Date Range: start_date = Month Start, end_date = Month End
            for(Date tmpDate = startDate; tmpDate <= endDate; tmpDate = tmpDate.addDays(1))
            {
                if(tmpDate != startDate && tmpDate.day() == 1)
                {
                    PubMthCopy tmpCopy = new PubMthCopy();
                    tmpCopy.mth = mapMthName.get(tmpDate.addMonths(-1).month()) + ' ' + tmpDate.addMonths(-1).year();
                    tmpCopy.intCopies = lstDates.size();
                    lstMthCopies.add(tmpCopy);
                    setHeaders.add(tmpCopy.mth);
                    totalCount  += tmpCopy.intCopies;
                    lstDates = new List<Date>();
                }
                
                if(pubObj.Frequency_Code__c == 'D') //Daily
                {
                    if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
                else if(pubObj.Frequency_Code__c == 'W') //Weekly
                {
                    if(Math.mod(tmpDate.daysBetween(nextIssueDate),7) == 0)
                    {
                        if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                            lstDates.add(tmpDate);  //Add to list if it is publish date
                        }
                    }
                }
                else if(pubObj.Frequency_Code__c == 'F') //Fortnightly
                {
                    if(Math.mod(tmpDate.daysBetween(nextIssueDate),14) == 0)
                    {
                        if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                            lstDates.add(tmpDate);  //Add to list if it is publish date
                        }
                    }
                }
                else if(pubObj.Frequency_Code__c == 'M') //Monthly
                {
                    if(tmpDate.day() == nextIssueDate.day())
                    {
                        if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                            lstDates.add(tmpDate);  //Add to list if it is publish date
                        }
                    }
                }
                else if(pubObj.Frequency_Code__c == 'B') //Bi-Monthly
                {
                    if(tmpDate.day() == nextIssueDate.day() && Math.mod(tmpDate.monthsBetween(nextIssueDate), 2) == 0)
                    {
                        if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                            lstDates.add(tmpDate);  //Add to list if it is publish date
                        }
                    }
                }
                else if(pubObj.Frequency_Code__c == 'Q') //Quarterly
                {
                    if(tmpDate.day() == nextIssueDate.day() && Math.mod(tmpDate.monthsBetween(nextIssueDate), 3) == 0)
                    {
                        if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                            lstDates.add(tmpDate);  //Add to list if it is publish date
                        }
                    }
                }
                else if(pubObj.Frequency_Code__c == 'H') //Half-Yearly
                {
                    if(tmpDate.day() == nextIssueDate.day() && Math.mod(tmpDate.monthsBetween(nextIssueDate), 6) == 0)
                    {
                        if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                            lstDates.add(tmpDate);  //Add to list if it is publish date
                        }
                    }
                }
                else if(pubObj.Frequency_Code__c == 'Y') //Yearly
                {
                    if(tmpDate.day() == nextIssueDate.day() && Math.mod(tmpDate.monthsBetween(nextIssueDate), 12) == 0)
                    {
                        if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                            lstDates.add(tmpDate);  //Add to list if it is publish date
                        }
                    }
                }               
            }
            
           PubMthCopy tmpCopy = new PubMthCopy();
           tmpCopy.mth = mapMthName.get(endDate.month()) + ' ' + endDate.year();
           tmpCopy.intCopies = lstDates.size();
           lstMthCopies.add(tmpCopy);
           setHeaders.add(tmpCopy.mth);
           totalCount  += tmpCopy.intCopies;
           
           PubMthCopy totalCopy = new PubMthCopy();
           totalCopy.mth = 'Total';
           totalCopy.intCopies = totalCount;
           setHeaders.add(totalCopy.mth);
           lstMthCopies.add(totalCopy);
                    
           PubCopyObj pubCopyRec= new PubCopyObj();
           pubCopyRec.pubCode = pubObj.Publication_Code__c;
           pubCopyRec.lstMthCopies = lstMthCopies;
           lstPubCopies.add(pubCopyRec);
        }
    }
    
    public void getUsagsQty(Zuora__Subscription__c sub, Set<Date> setHolidays)
    {
        Map<Id, Set<Date>> mapPubIdToNonPubDates = new Map<Id, Set<Date>>();
        Map<Id, PubIssueHelper.PublicationPattern> mapPubIdToPubPattern = new Map<Id, PubIssueHelper.PublicationPattern>();
        Set<Id> setPublicationIds = new Set<Id>();
        Map<Id, Publication__c> mapPubIdToObj = new Map<Id, Publication__c>();
        Map<String, Integer> mapPubCodeToWk = new Map<String, Integer>();
        Map<String, Integer> mapPubCodeToSat = new Map<String, Integer>();
        Map<String, Integer> mapPubCodeToSun = new Map<String, Integer>();
        Map<String, Decimal> mapUOMToPrice = new Map<String, Decimal>();
        Date fromDate = startDate;
        Date toDate = endDate;
        
        String productCode = sub.Product_Code__c;
        Boolean isMagazine = false;
        
        //Retrieve SPC Detail
        for(Zuora__SubscriptionProductCharge__c spcRec : [SELECT Zuora__UOM__c, Zuora__Price__c FROM Zuora__SubscriptionProductCharge__c 
                            WHERE Zuora__Subscription__c = : sub.ID])
        {
            mapUOMToPrice.put(spcRec.Zuora__UOM__c,spcRec.Zuora__Price__c);
        }
        
        //Retrieve Product Code to Publication Mapping
        for(Product_Publication__c prodPub : [SELECT ZProduct__r.ProductCode__c, Publication_Code__c, Publication_Code__r.Publication_Code__c 
                                        FROM Product_Publication__c WHERE ZProduct__r.ProductCode__c = :productCode])
        {
            Id pubId = prodPub.Publication_Code__c;
            setPublicationIds.add(pubId);
            String pubCode = prodPub.Publication_Code__r.Publication_Code__c;
            mapPubCodeToWk.put(pubCode, 0);
            mapPubCodeToSat.put(pubCode, 0);
            mapPubCodeToSun.put(pubCode, 0);
        }
        
        mapPubIdToObj = new Map<Id, Publication__c>([SELECT Id, Name, Publication_Code__c, Published_Days__c, Publication_Next_Start_Date__c, Platform_Type__c,
                                  Frequency_Code__c, Public_Holiday_Weekend_Pub_Indicator__c, Public_Holiday_Weekday_Pub_Indicator__c, Publication_Type__c, Publication_Platform_AIO__c
                                  FROM Publication__c WHERE ID in :setPublicationIds AND Publication_Next_Start_Date__c != null]);
        
        //Only retrieve Non Pub Dates in this particular month
        for(Non_Publication_Day__c pubDay : [SELECT Id, Publication__c, Publication_Code__c, Non_Publication_Date__c 
              FROM Non_Publication_Day__c WHERE Publication__c IN : setPublicationIds 
              AND Non_Publication_Date__c >= :startDate AND Non_Publication_Date__c <= :endDate])
        {
            if(!mapPubIdToNonPubDates.containsKey(pubDay.Publication__c))
                mapPubIdToNonPubDates.put(pubDay.Publication__c, new Set<Date> {pubDay.Non_Publication_Date__c});
            else
                mapPubIdToNonPubDates.get(pubDay.Publication__c).add(pubDay.Non_Publication_Date__c);
        }
        System.debug('=====> mapPubIdToNonPubDates: ' + mapPubIdToNonPubDates);
        
        //Generate Publication Pattern for Daily Publications
        for(Publication__c pubObj : mapPubIdToObj.values())
        {
            if(pubObj.Frequency_Code__c == 'D' || pubObj.Frequency_Code__c == 'W') //Daily Publication
                mapPubIdToPubPattern.put(pubObj.Id, PubIssueHelper.generatePubPattern(pubObj));
            
            if(pubObj.Publication_Type__c == 'M')
                isMagazine = true;
            
            if(pubObj.Platform_Type__c == 'Online' || pubObj.Platform_Type__c == 'Tablet' || pubObj.Platform_Type__c == 'Smartphone')
                mapPubCodeToUOM.put(pubObj.Publication_Code__c, pubObj.Platform_Type__c);
            else if(pubObj.Platform_Type__c == 'All in One (AIO)')
                mapPubCodeToUOM.put(pubObj.Publication_Code__c, 'AIO '+ pubObj.Publication_Platform_AIO__c);  
        }
        
        System.debug('=====> mapPubIdToPubPattern: ' + mapPubIdToPubPattern);
        if(isMagazine)
        {
             for(Publication__c pubObj : mapPubIdToObj.values())
             {
                Integer issueCount = calculateIssueDates(sub, pubObj, mapPubIdToPubPattern, mapPubIdToNonPubDates, setHolidays,startDate, endDate);
            
                UsageObj usageCopy = new UsageObj();
                usageCopy.uom = 'Credit Copy Issue ' + pubObj.Publication_Code__c;
                usageCopy.pubCode = pubObj.Publication_Code__c;
                usageCopy.intCopies = issueCount * Integer.valueOf(sub.qty__c); 
                usageCopy.price = (mapUOMToPrice.containsKey(usageCopy.uom)) ? mapUOMToPrice.get(usageCopy.uom) : null;
                lstUsages.add(usageCopy);
                if(usageCopy.price != null)
                    totalRefund += usageCopy.intCopies * usageCopy.price;
             }
        }
        else
        {
            Integer monthBtween = startDate.monthsBetween(endDate);
            if(endDate.toStartOfMonth().addMonths(1).addDays(-1) != endDate)
                monthBtween = monthBtween - 1;
            if(startDate.day() == 1)
                monthBtween = monthBtween + 1;
            
            if(monthBtween > 0 && isCredit)
            {
                for(Publication__c pubObj : mapPubIdToObj.values())
                {
                    UsageObj usageCopy = new UsageObj();
                    usageCopy.uom = 'Credit Copy Month ' + pubObj.Publication_Code__c;
                    usageCopy.pubCode = pubObj.Publication_Code__c;
                    usageCopy.intCopies = monthBtween * Integer.valueOf(sub.qty__c); 
                    usageCopy.price = (mapUOMToPrice.containsKey(usageCopy.uom)) ? mapUOMToPrice.get(usageCopy.uom) : null;
                    lstUsages.add(usageCopy);
                    if(usageCopy.price != null)
                        totalRefund += usageCopy.intCopies * usageCopy.price;
                }
            }
            
            if(startDate.day() == 1 && endDate.toStartOfMonth().addMonths(1).addDays(-1) == endDate)
                return;
            else if(startDate.day() == 1)
            {
                fromDate = endDate.toStartOfMonth();
                calculateCreditUOMs(sub, mapPubIdToObj, mapPubIdToPubPattern, mapPubIdToNonPubDates, setHolidays,mapPubCodeToWk,
                                    mapPubCodeToSat, mapPubCodeToSun, fromDate, toDate);
            }
            else if(endDate.toStartOfMonth().addMonths(1).addDays(-1) == endDate)
            {
                toDate = startDate.toStartOfMonth().addMonths(1).addDays(-1);
                calculateCreditUOMs(sub, mapPubIdToObj, mapPubIdToPubPattern, mapPubIdToNonPubDates, setHolidays,mapPubCodeToWk,
                                    mapPubCodeToSat, mapPubCodeToSun, fromDate, toDate);
            }
            else if(startDate.monthsBetween(endDate) == 0)
            {
                calculateCreditUOMs(sub, mapPubIdToObj, mapPubIdToPubPattern, mapPubIdToNonPubDates, setHolidays,mapPubCodeToWk,
                                    mapPubCodeToSat, mapPubCodeToSun, fromDate, toDate);
            }
            else
            {
                toDate = startDate.toStartOfMonth().addMonths(1).addDays(-1);
                calculateCreditUOMs(sub, mapPubIdToObj, mapPubIdToPubPattern, mapPubIdToNonPubDates, setHolidays,mapPubCodeToWk,
                                    mapPubCodeToSat, mapPubCodeToSun, fromDate, toDate);

                fromDate = endDate.toStartOfMonth();
                toDate = endDate;
                calculateCreditUOMs(sub, mapPubIdToObj, mapPubIdToPubPattern, mapPubIdToNonPubDates, setHolidays,mapPubCodeToWk,
                                    mapPubCodeToSat, mapPubCodeToSun, fromDate, toDate);               
            }
            
            for(String pubCode : mapPubCodeToWk.keySet())
            {
                if(mapPubCodeToWk.get(pubCode) >0)
                {
                    UsageObj usageCopy = new UsageObj();
                    String uomStr = '';
                    if(mapPubCodeToUOM.containsKey(pubCode))
                        uomStr = 'Copy ' + mapPubCodeToUOM.get(pubCode);
                    else
                        uomStr = 'Copy Weekday';
                    
                    if(isCredit)
                        uomStr = 'Credit ' + uomStr;
                    usageCopy.uom = uomStr;
                    usageCopy.pubCode = pubCode;
                    usageCopy.intCopies = mapPubCodeToWk.get(pubCode) * Integer.valueOf(sub.qty__c); 
                    usageCopy.price = (mapUOMToPrice.containsKey(usageCopy.uom)) ? mapUOMToPrice.get(usageCopy.uom) : null;
                    lstUsages.add(usageCopy);
                    if(usageCopy.price != null && isCredit)
                        totalRefund += usageCopy.intCopies * usageCopy.price;
                }
            }
            
            for(String pubCode : mapPubCodeToSat.keySet())
            {
                if(mapPubCodeToSat.get(pubCode) >0)
                {
                    UsageObj usageCopy = new UsageObj();
                    usageCopy.uom = isCredit ? 'Credit Copy Sat' : 'Copy Sat';
                    usageCopy.pubCode = pubCode;
                    usageCopy.intCopies = mapPubCodeToSat.get(pubCode) * Integer.valueOf(sub.qty__c); 
                    usageCopy.price = (mapUOMToPrice.containsKey(usageCopy.uom)) ? mapUOMToPrice.get(usageCopy.uom) : null;
                    lstUsages.add(usageCopy);
                    if(usageCopy.price != null && isCredit)
                        totalRefund += usageCopy.intCopies * usageCopy.price;
                }
            }
            
            for(String pubCode : mapPubCodeToSun.keySet())
            {
                if(mapPubCodeToSun.get(pubCode) >0)
                {
                    UsageObj usageCopy = new UsageObj();
                    usageCopy.uom = isCredit ? 'Credit Copy Sun' : 'Copy Sun';
                    usageCopy.pubCode = pubCode;
                    usageCopy.intCopies = mapPubCodeToSun.get(pubCode) * Integer.valueOf(sub.qty__c); 
                    usageCopy.price = (mapUOMToPrice.containsKey(usageCopy.uom)) ? mapUOMToPrice.get(usageCopy.uom) : null;
                    lstUsages.add(usageCopy);
                    if(usageCopy.price != null && isCredit)
                        totalRefund += usageCopy.intCopies * usageCopy.price;
                }
            }
        }
    }
    
   public  Integer calculateIssueDates(Zuora__Subscription__c sub, Publication__c pubObj, Map<Id, PubIssueHelper.PublicationPattern> mapPubIdToPubPattern, 
                                   Map<Id, Set<Date>> mapPubIdToNonPubDates, Set<Date> setHolidays, Date fromDate, Date toDate)
    {
        List<Date> lstDates = new List<Date>();
        Date nextIssueDate = pubObj.Publication_Next_Start_Date__c;
        
        //Date Range: start_date = Month Start, end_date = Month End
        for(Date tmpDate = fromDate; tmpDate <= toDate; tmpDate = tmpDate.addDays(1))
        {
            if(pubObj.Frequency_Code__c == 'D') //Daily
            {
                if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                    lstDates.add(tmpDate);  //Add to list if it is publish date
                }
            }
            else if(pubObj.Frequency_Code__c == 'W') //Weekly
            {
                if(Math.mod(tmpDate.daysBetween(nextIssueDate),7) == 0)
                {
                    if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'F') //Fortnightly
            {
                if(Math.mod(tmpDate.daysBetween(nextIssueDate),14) == 0)
                {
                    if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'M') //Monthly
            {
                if(tmpDate.day() == nextIssueDate.day())
                {
                    if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'B') //Bi-Monthly
            {
                if(tmpDate.day() == nextIssueDate.day() && Math.mod(tmpDate.monthsBetween(nextIssueDate), 2) == 0)
                {
                    if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'Q') //Quarterly
            {
                if(tmpDate.day() == nextIssueDate.day() && Math.mod(tmpDate.monthsBetween(nextIssueDate), 3) == 0)
                {
                    if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'H') //Half-Yearly
            {
                if(tmpDate.day() == nextIssueDate.day() && Math.mod(tmpDate.monthsBetween(nextIssueDate), 6) == 0)
                {
                    if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'Y') //Yearly
            {
                if(tmpDate.day() == nextIssueDate.day() && Math.mod(tmpDate.monthsBetween(nextIssueDate), 12) == 0)
                {
                    if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }               
        }
        return lstDates.size();
    }
    public void calculateCreditUOMs(Zuora__Subscription__c sub, Map<Id, Publication__c> mapPubIdToObj, Map<Id, PubIssueHelper.PublicationPattern> mapPubIdToPubPattern, 
                                   Map<Id, Set<Date>> mapPubIdToNonPubDates, Set<Date> setHolidays,Map<String, Integer> mapPubCodeToWk,
                                    Map<String, Integer> mapPubCodeToSat, Map<String, Integer> mapPubCodeToSun, Date fromDate, Date toDate)
    {
         /******************** Get Publish Dates for each Publication ***************************/
        for(Publication__c pubObj : mapPubIdToObj.values())
        {
            Date nextIssueDate = pubObj.Publication_Next_Start_Date__c;
            
            List<Date> lstDates = new List<Date>();
            
            //Date Range: start_date = Month Start, end_date = Month End
            for(Date tmpDate = fromDate; tmpDate <= toDate; tmpDate = tmpDate.addDays(1))
            {
                if(pubObj.Frequency_Code__c == 'D') //Daily
                {
                    if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                        updateResult(tmpDate, pubObj.Publication_Code__c, mapPubCodeToWk, mapPubCodeToSat, mapPubCodeToSun);
                    }
                }
                else if(pubObj.Frequency_Code__c == 'W') //Weekly
                {
                    if(Math.mod(tmpDate.daysBetween(nextIssueDate),7) == 0)
                    {
                        if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                             updateResult(tmpDate, pubObj.Publication_Code__c, mapPubCodeToWk, mapPubCodeToSat, mapPubCodeToSun);
                        }
                    }
                }
                else if(pubObj.Frequency_Code__c == 'F') //Fortnightly
                {
                    if(Math.mod(tmpDate.daysBetween(nextIssueDate),14) == 0)
                    {
                        if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                             updateResult(tmpDate, pubObj.Publication_Code__c, mapPubCodeToWk, mapPubCodeToSat, mapPubCodeToSun);
                        }
                    }
                }
                else if(pubObj.Frequency_Code__c == 'M') //Monthly
                {
                    if(tmpDate.day() == nextIssueDate.day())
                    {
                        if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                             updateResult(tmpDate, pubObj.Publication_Code__c, mapPubCodeToWk, mapPubCodeToSat, mapPubCodeToSun);
                        }
                    }
                }
                else if(pubObj.Frequency_Code__c == 'B') //Bi-Monthly
                {
                    if(tmpDate.day() == nextIssueDate.day() && Math.mod(tmpDate.monthsBetween(nextIssueDate), 2) == 0)
                    {
                        if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                             updateResult(tmpDate, pubObj.Publication_Code__c, mapPubCodeToWk, mapPubCodeToSat, mapPubCodeToSun);
                        }
                    }
                }
                else if(pubObj.Frequency_Code__c == 'Q') //Quarterly
                {
                    if(tmpDate.day() == nextIssueDate.day() && Math.mod(tmpDate.monthsBetween(nextIssueDate), 3) == 0)
                    {
                        if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                             updateResult(tmpDate, pubObj.Publication_Code__c, mapPubCodeToWk, mapPubCodeToSat, mapPubCodeToSun);
                        }
                    }
                }
                else if(pubObj.Frequency_Code__c == 'H') //Half-Yearly
                {
                    if(tmpDate.day() == nextIssueDate.day() && Math.mod(tmpDate.monthsBetween(nextIssueDate), 6) == 0)
                    {
                        if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                             updateResult(tmpDate, pubObj.Publication_Code__c, mapPubCodeToWk, mapPubCodeToSat, mapPubCodeToSun);
                        }
                    }
                }
                else if(pubObj.Frequency_Code__c == 'Y') //Yearly
                {
                    if(tmpDate.day() == nextIssueDate.day() && Math.mod(tmpDate.monthsBetween(nextIssueDate), 12) == 0)
                    {
                        if(isPublishDate(sub, pubObj, tmpDate, mapPubIdToNonPubDates, setHolidays, mapPubIdToPubPattern)){
                            updateResult(tmpDate, pubObj.Publication_Code__c, mapPubCodeToWk, mapPubCodeToSat, mapPubCodeToSun);
                        }
                    }
                }               
            }
        }
    }
    public Boolean isPublishDate(Zuora__Subscription__c sub, Publication__c publication, Date inputDate, Map<Id, Set<Date>> mapPubIdToNonPubDates, 
                    Set<Date> setHolidays, Map<Id, PubIssueHelper.PublicationPattern> mapPubIdToPubPattern)
    {
        //Verify Non-Publication Date
        if(mapPubIdToNonPubDates.containsKey(publication.Id) && mapPubIdToNonPubDates.get(publication.Id).contains(inputDate))
            return false;
        
        //Get User Subscription Frequency 
        PubIssueHelper.PublicationPattern userPattern = PubIssueHelper.generateSubPattern(publication, sub);
        
        //Verify Holiday
        if(setHolidays.contains(inputDate) && (!PubIssueHelper.isHolidayPublishDate(publication, inputDate) 
                                               || !PubIssueHelper.isHolidayPublishDate(userPattern, inputDate)))
            return false;
        
        //Verify Publish Days for Publications : cater for various frequency
        if(publication.Frequency_Code__c == 'D' || publication.Frequency_Code__c == 'W') //Daily or Weekly Publication
        {
            PubIssueHelper.PublicationPattern pattern = mapPubIdToPubPattern.get(publication.Id);
            if(!PubIssueHelper.isPublishDate(pattern, inputDate))
                return false;
            
            //Check User Subscription Frequency 
            if(!PubIssueHelper.isPublishDate(userPattern, inputDate))
                return false;
        }
        else 
            return true; //Frequency already catered in the for loop for Non-daily Publications
       
        return true;
    }
   
    public void updateResult(Date inputDate, String pubCode, Map<String, Integer> mapPubCodeToWk, 
                             Map<String, Integer> mapPubCodeToSat, Map<String, Integer> mapPubCodeToSun)
    {
        Integer curWkCount = mapPubCodeToWk.get(pubCode);
        Integer curSatCount = mapPubCodeToSat.get(pubCode);
        Integer curSunCount = mapPubCodeToSun.get(pubCode);
        
        if(mapPubCodeToUOM.containsKey(pubCode))
            mapPubCodeToWk.put(pubCode, curWkCount+1);
        else
        {
            String dayInWeek = DateUtility.dayInWeekEEE(inputDate);
            
            if(dayInWeek == 'Sat') 
                mapPubCodeToSat.put(pubCode, curSatCount+1);
            else if(dayInWeek == 'Sun')
                mapPubCodeToSun.put(pubCode, curSunCount+1);
            else
                mapPubCodeToWk.put(pubCode, curWkCount+1);
        }
    }
    
    public class PubCopyObj
    {
        public String pubCode {get;set;}
        public List<PubMthCopy> lstMthCopies {get;set;}
    }
    
    public class PubMthCopy
    {
        public String mth {get;set;}
        public Integer intCopies {get;set;}
    }
    
    public class UsageObj
    {
        public String uom {get;set;}
        public String pubCode {get;set;}
        public Integer intCopies {get;set;}
        public Decimal price {get;set;}
    }
}