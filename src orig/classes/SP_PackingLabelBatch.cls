/**
 * Class Name: SP_PackingLabelBatch
 * @author: Raviteja Kumar 
 * Date: 
 * Requirement/Project Name: CRSM Project - NCR015-5
 * @description Batch Apex Class to Create Daily Vendor POP Batch Records which will be fetched by Integration to be sent to the POP System.
 * assumptions: This batch Class runs on a daily basis and aggregates publication data for the next day. Publication Copies is computed per vendor if:
 *              1. The next day is a Publish Day AND
 *              2. The next day is not a public holiday AND
 *              3. The subscription is not under a Temp Stop for the next day.
 *              4. Totals does not include copies for Vendor Subscriptions
 * D-4605 and D-4613 Restrtutre the code by updating the logic with Mailing_Agent_Code__c Instead of Vendor_Code__c
 */ 
global class SP_PackingLabelBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful {    

    global final Id JOB_ID;
    global Boolean overrideFlg = false;
    global Boolean isSuccess = True; //START/END D-4583 24-Mar-2016 Added by Raviteja - variable for job status 
    global Date ovdFromDate = Date.today();   
    global Map<Id,Set<Date>> mapPubIssueDate = New Map<Id,Set<Date>>();            
    global Set<id> subscriptionIDs = new Set<Id>(); // START-END I-0269 - Raviteja - 23May2016 - implemeting the logic for Subscriptions adhoc run
    
    global SP_PackingLabelBatch(){}
    
    global SP_PackingLabelBatch(Date fromDate){       
        overrideFlg = true;
        ovdFromDate = fromDate;
    }
  
    global SP_PackingLabelBatch(Id jobID, Date fromDate){        
        JOB_ID = jobID;
        overrideFlg = true;
        ovdFromDate = fromDate;    
    }
   
    global SP_PackingLabelBatch(Id jobID){
      JOB_ID = jobID;
      overrideFlg = true;
    }
   
    // START I-0269 - Raviteja - 23May2016 - implemeting the logic for Subscriptions adhoc run
    global SP_PackingLabelBatch(Set<id> subIDs, Date fromDate){        
        subscriptionIDs.addAll(subIDs);
        overrideFlg = true;
        ovdFromDate = fromDate;    
    }
    // END I-0269 - Raviteja - 23May2016 
    
    global Database.QueryLocator start(Database.BatchableContext BC) {             
        
        String query = 'SELECT Id, Name, qty__c, Product_Code__c, Vendor_1__c, Vendor_1__r.Vendor_Code__c, Vendor_1__r.Vendor_Group__c, ';
        query       += ' Recipient_Contact__r.Address__r.RecordType.DeveloperName, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, ';
        query       += ' Main_Package_1__r.Package_Type__c, Main_Package_1__r.Package_Price__c, Main_Package_1__r.Frequency_Identifier__c, ';
        query       += ' Recipient_Contact__r.Address__r.Postal_Code__r.Address_Type__c, Zuora__CustomerAccount__r.Attention_To_Care_Of_Indicator__c, ';
        query       += ' Recipient_Contact__r.Address__r.Packing_Code__c, Recipient_Contact__r.Address__r.Packing_Code__r.Name, Recipient_Contact__r.Address__r.City__r.Name, ';
        query       += ' Recipient_Contact__r.Address__r.Flight_Number_1__c, Recipient_Contact__r.Address__r.Flight_Number_2__c, ';
        query       += ' Recipient_Contact__r.Address__r.Packing_Group_Description__c, ';        
        query       += ' Recipient_Contact__r.Address__r.Postal_Code__r.Name, Vendor_1__r.Mailing_Agent_Code__c, ';   
        query       += ' Recipient_Contact__r.Address__r.Block_House_Number__c, ';
        query       += ' Recipient_Contact__r.Address__r.Street_Name__c, ';
        query       += ' Recipient_Contact__r.Address__r.Level_Number__c, ';
        query       += ' Recipient_Contact__r.Address__r.Unit_Number__c, ';
        query       += ' Recipient_Contact__r.Address__r.Building_Name__c, ';
        query       += ' Recipient_Contact__r.Address__r.Country_Name__c, ';
        query       += ' Recipient_Contact__r.Address__r.Address_1__c, ';
        query       += ' Recipient_Contact__r.Address__r.Address_2__c, ';
        query       += ' Recipient_Contact__r.Address__r.Address_3__c, ';
        query       += ' Recipient_Contact__r.Address__r.Address_4__c, ';
        query       += ' Recipient_Contact__r.Address__r.Section_Code__r.Name, ';
        query       += ' Recipient_Contact__r.Address__r.Department__r.Name, ';
        query       += ' Recipient_Contact__r.Address__r.Division_Code__r.Name, ';
        query       += ' Recipient_Contact__r.Address__r.Company_Code__r.Name, ';
        query       += ' Recipient_Contact__r.Address__r.Location_Code__r.Name, ';
        query       += ' Recipient_Contact__r.Address__r.Airline_Number__c, ';          
        query       += ' Recipient_Contact__r.Address__r.Postal_Sector__c,  ';      
        query       += ' Recipient_Contact__r.Address__r.Packing_Code__r.Airline__c, ';     
        query       += ' Recipient_Contact__r.Address__r.Packing_Code__r.Sequence_Number__c, ';  
        //Start/End 30Mar2016 - Raviteja - Added Packing_Code__r.Packing_Code__c , City__r.Airline__c,City_Name__c in SOQL 
        query       += ' Recipient_Contact__r.Address__r.Packing_Code__r.Packing_Code__c, ';  
        query       += ' Recipient_Contact__r.Address__r.City__r.Airline__c, ';
        query       += ' Recipient_Contact__r.Address__r.City__r.City_Name__c, ';
        query       += ' Recipient_Contact__r.Address__r.City__r.City_code__c, ';       
        query       += ' Recipient_Contact__r.Address__r.City__r.Remarks__c, ';             
        query       += ' Zuora__Account__r.Account_Auto_Number__c,  ';                      
        query       += ' Recipient_Contact__r.Recipient_Number_Show__c, ';                  
        query       += ' Recipient_Contact__r.FirstName,    ';                  
        query       += ' Recipient_Contact__r.LastName, ';      
        //START D-4583 24-Mar-2016 Kevin Evasco - Added Company Name        
        query       += ' Recipient_Contact__r.Company_Name__c,  ';
        //END D-4583 24-Mar-2016 Kevin Evasco - Added Company Name      
        query       += ' Delivered_By_1__c, Sponsor_1__c, Other_PaymentMethod_1__c, Ph_d__c, Ph_e__c, Frequency_1__c,Zuora__Account__C ';       
        query       += ' FROM Zuora__Subscription__c WHERE Subscription_Type__c  = \'Publication\' and Delivered_By_1__c IN (\'Mailing Agent\') ';        
        query       += ' AND (Zuora__SubscriptionEndDate__c > :ovdFromDate OR Zuora__SubscriptionEndDate__c = NULL) ';                       
        query       += ' AND Vendor_1__c != NULL';     
        
        // START I-0269 - Raviteja - 23May2016 - implemeting the logic for Subscriptions adhoc run
        if(!subscriptionIDs.isEmpty()){
            query       += ' AND Id IN :subscriptionIDs ';
        }               
        // END I-0269 - Raviteja - 23May2016 - implemeting the logic for Subscriptions adhoc run
        
        //query       += ' Limit 1 ';           
        
        System.debug('query : '+query);
        
        return Database.getQueryLocator(query);
    }
        
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> lstSubs) {
        /************************** Variable Definitions ***********************************************/
        Map<Id, Zuora__Subscription__c> mapSubIdToObj = new Map<Id, Zuora__Subscription__c>();
        Set<String> setProductCodes = new Set<String>();
        Map<String, Set<Id>> mapProdCodeToPubIds = new Map<String, Set<Id>>();
        Map<Id, Set<Id>> mapSubIdToPubIds = new Map<Id, Set<Id>>();
        Set<Id> setPublicationIds = new Set<Id>();
        Map<Id, Publication__c> mapPubIdToObj = new Map<Id, Publication__c>();
        Map<Id, Set<Date>> mapPubDailyIssueDate = new Map<Id, Set<Date>>();
        Map<Id, List<Date>> mapPubIdToPOPDates = new Map<Id, List<Date>>();
        Map<Id, Set<Date>> mapPubIdToNonPubDates = new Map<Id, Set<Date>>();
        Map<String, Set<Date>> mapPubCodeToPreRunDates = new Map<String, Set<Date>>();
        Map<Id, PubIssueHelper.PublicationPattern> mapPubIdToPubPattern = new Map<Id, PubIssueHelper.PublicationPattern>();
        Set<Date> setHolidays = new Set<Date>();
        Map<Id, List<Subscription_Temp_Stop__c>> mapSubIdToTStops = new Map<Id, List<Subscription_Temp_Stop__c>>();
        List<CMIS_POP_Packing_label_Batch__c> lstPLBData = new List<CMIS_POP_Packing_label_Batch__c>();        
        Map<Id,COAWrapper> mapSubToCOA = new  Map<Id,COAWrapper>();
        Date maxDateToCheck = ovdFromDate.addDays(90); //START END D-3631 29/09/15 Wenjun Hotfix to support full back dated run
        /************************** Get Publications based on Subscriptions ****************************/    
   
    try{             
        for(Zuora__Subscription__c zSub : lstSubs) {
            mapSubIdToObj.put(zSub.Id, zSub);
            if(zSub.Product_Code__c != null)
                setProductCodes.add(zSub.Product_Code__c);
        }        
        
        for(Product_Publication__c prodPub : [SELECT ZProduct__r.ProductCode__c, Publication_Code__c, Publication_Code__r.Publication_Code__c                
                FROM Product_Publication__c WHERE ZProduct__r.ProductCode__c in :setProductCodes AND Publication_Code__r.Platform_Type__c = 'Print'])
        {                      
            String productCode = prodPub.ZProduct__r.ProductCode__c;
            Id pubId = prodPub.Publication_Code__c;
            setPublicationIds.add(pubId);
            if(!mapProdCodeToPubIds.containsKey(productCode))
                mapProdCodeToPubIds.put(productCode, new Set<Id> {pubId});
            else
                mapProdCodeToPubIds.get(productCode).add(pubId);
        }
      
        
        mapPubIdToObj = new Map<Id, Publication__c>([SELECT Id, Name, Publication_Code__c, Published_Days__c, Publication_Next_Start_Date__c, Platform_Type__c,  
                                                                    Frequency_Code__c, Public_Holiday_Weekend_Pub_Indicator__c, Public_Holiday_Weekday_Pub_Indicator__c 
                                                    FROM Publication__c WHERE ID in :setPublicationIds AND Platform_Type__c = 'Print' AND Publication_Next_Start_Date__c != null]);
                                                    
        for(Publication_Daily_Issue_Data__c pdiData : [Select Id,Publication__c,Publication_Issue_Date__c from Publication_Daily_Issue_Data__c 
                                                                                        where Consolidation_Date__c = :ovdFromDate  AND Publication__c in :mapPubIdToObj.keySet()])
        {           
            //mapPubDailyIssueDate.put(pdiData.Publication__c,pdiData.Publication_Issue_Date__c);   
            if(!mapPubDailyIssueDate.containsKey(pdiData.Publication__c))
                mapPubDailyIssueDate.put(pdiData.Publication__c, new Set<Date> {pdiData.Publication_Issue_Date__c});
            else
                mapPubDailyIssueDate.get(pdiData.Publication__c).add(pdiData.Publication_Issue_Date__c);                                              
        }
        
        //Generate Sub ID to Publication Codes mapping
        for(Zuora__Subscription__c zSub : lstSubs) {
            if(mapProdCodeToPubIds.containsKey(zSub.Product_Code__c))
                mapSubIdToPubIds.put(zSub.Id, mapProdCodeToPubIds.get(zSub.Product_Code__c));
        }
        
        /*************************** Generate Date Range for each Publication ************************/
        //Only retrieve Non Pub Dates in the next 90 days
       
        for(Non_Publication_Day__c pubDay : [SELECT Id, Publication__c, Publication_Code__c, Non_Publication_Date__c 
              FROM Non_Publication_Day__c WHERE Publication__c IN : setPublicationIds 
              AND Non_Publication_Date__c > :ovdFromDate AND Non_Publication_Date__c <= :maxDateToCheck])   
        {
            if(!mapPubIdToNonPubDates.containsKey(pubDay.Publication__c))
                mapPubIdToNonPubDates.put(pubDay.Publication__c, new Set<Date> {pubDay.Non_Publication_Date__c});
            else
                mapPubIdToNonPubDates.get(pubDay.Publication__c).add(pubDay.Non_Publication_Date__c);
        } 
        
        //Only retrieve Public Holidays in the next 90 days
        //START D-3631 29/09/15 Wenjun Hotfix to support full back dated run - use maxDateToCheck instead of NEXT_90_DAYS
        for (Public_Holiday__c tmp : [SELECT Holiday_Date__c FROM Public_Holiday__c 
                                      WHERE Holiday_Date__c > :ovdFromDate AND Holiday_Date__c <= :maxDateToCheck]) 
        //END D-3631 29/09/15 Wenjun Hotfix to support full back dated run
        { 
            setHolidays.add(tmp.Holiday_Date__c);
        }        
        
        for (CMIS_POP_Packing_label_Batch__c plb :[SELECT Publication_Code__c, Publication_Issue_Date__c FROM CMIS_POP_Packing_label_Batch__c
                                 WHERE CreatedDate < TODAY 
                                 AND Publication_Issue_Date__c = :ovdFromDate])
        //END D-3631 29/09/15 Wenjun Hotfix to support full back dated run
        {   
            String pubCode = plb.Publication_Code__c;
            Date issueDate = plb.Publication_Issue_Date__c;
            if(!mapPubCodeToPreRunDates.containsKey(pubCode))
                mapPubCodeToPreRunDates.put(pubCode, new Set<Date> {issueDate});
            else
                mapPubCodeToPreRunDates.get(pubCode).add(issueDate);
        }      
        
        //Generate Publication Pattern for Daily Publications
        for(Publication__c pubObj : mapPubIdToObj.values())
        {
            if(pubObj.Frequency_Code__c == 'D') //Daily Publication
                mapPubIdToPubPattern.put(pubObj.Id, PubIssueHelper.generatePubPattern(pubObj));
        }       
        
        Date todayDT = Date.today();    
      
        if(overrideFlg){
            todayDT = ovdFromDate;
            System.debug('=====> Overriding From Date');
        }
       
        //Fetch all the COA Cases
        Set<Id> setCaseIDs = new Set<Id>();
        Map<Id, Address_Assignment__c> mapCaseToAddrAssign = new Map<Id, Address_Assignment__c>();
        List<Case_Subscription__c> lstCaseSubs = [SELECT ID, Name, Case__c, Subscription__c, Case__r.Effective_Date__c, CreatedDate
                       FROM Case_Subscription__c WHERE Subscription__c in :lstSubs AND Case__r.Status = :GlobalVariableClass.STATUS_CLOSED 
                       AND Case__r.Effective_Date__c > :todayDT 
                       AND (Case__r.Change_of_Address_Type__c = :GlobalVariableClass.BILLDELIVERYADD 
                            OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.DELIVERYADDLOC)];
        
        for(Case_Subscription__c caseSub : lstCaseSubs)
            setCaseIDs.add(caseSub.Case__c);
        
        //Fetch Address Assignment to get Vendor      
        for(Address_Assignment__c addrAssign :
            [
            SELECT ID, Case__c, Vendor__r.Vendor_Code__c, Vendor__r.Vendor_Group__c , Vendor__r.Mailing_Agent_Code__c , 
            Address__r.Packing_Code__c, Address__r.Packing_Code__r.Name, Address__r.Packing_Group_Description__c,     
            Address__r.RecordType.Name,
            Address__r.Block_House_Number__c,
            Address__r.Street_Name__c,
            Address__r.Level_Number__c,
            Address__r.Unit_Number__c,
            Address__r.Building_Name__c,
            Address__r.Country_Name__c,
            Address__r.Postal_Code__r.Name,
            Address__r.Postal_Code__r.Address_Type__c ,
            Address__r.Address_1__c,
            Address__r.Address_2__c,
            Address__r.Address_3__c,
            Address__r.Address_4__c,
            Address__r.Section_Code__r.Name,
            Address__r.Department__r.Name,
            Address__r.Division_Code__r.Name,
            Address__r.Company_Code__r.Name,
            Address__r.Location_Code__r.Name,
            Address__r.City__r.Name,
            Address__r.Airline_Number__c,
            Address__r.Flight_Number_1__c,
            Address__r.Flight_Number_2__c,      
            Address__r.Packing_Code__r.Airline__c,      
            Address__r.Packing_Code__r.Sequence_Number__c,              
            Address__r.Packing_Code__r.Packing_Code__c,   //Start/End 30Mar2016 - Raviteja - Added Packing_Code__r.Packing_Code__c in SOQL  
            Address__r.City__r.Airline__c,  //Start/End 30Mar2016 - Raviteja - Added City__r.Airline__c in SOQL 
            Address__r.City__r.City_Name__c,   //Start/End 30Mar2016 - Raviteja - Added City__r.City_Name__c in SOQL 
            Address__r.RecordType.DeveloperName, //Start/End D-4673 13Apr2016 - Raviteja - Added RecordType.DeveloperName in SOQL 
            Address__r.City__r.City_code__c,        
            Address__r.City__r.Remarks__c,      
            Address__r.Postal_Sector__c 
            From Address_Assignment__c WHERE Case__c in :setCaseIDs AND Vendor__c != NULL
            ])
         {
              mapCaseToAddrAssign.put(addrAssign.Case__c, addrAssign);  
         }
         
        for(Case_Subscription__c caseSub : lstCaseSubs)
        {
            if(mapCaseToAddrAssign.containsKey(caseSub.Case__c))
            {
                Address_Assignment__c addrAssign = mapCaseToAddrAssign.get(caseSub.Case__c);
                COAWrapper newCOA = new COAWrapper(caseSub.Case__r.Effective_Date__c, caseSub.CreatedDate, 
                                                   addrAssign.Vendor__r.Vendor_Group__c, addrAssign.Vendor__r.Mailing_Agent_Code__c);                
                newCOA.addressAssignmentRecord = addrAssign;
                if(mapSubToCOA.containsKey(caseSub.Subscription__c))
                {
                    COAWrapper preCOA = mapSubToCOA.get(caseSub.Subscription__c);
                    if(newCOA.createDT > preCOA.createDT)
                        mapSubToCOA.put(caseSub.Subscription__c, newCOA);
                }
                else
                    mapSubToCOA.put(caseSub.Subscription__c, newCOA);
            }
        }
        
        //Fetch COV Cases
        for(Case_Subscription__c caseSub : [SELECT ID, Name, Case__c, Subscription__c, Case__r.Effective_Date__c, CreatedDate,
                                            Case__r.Vendor__r.Vendor_Code__c, Case__r.Vendor__r.Vendor_Group__c , Case__r.Vendor__r.Mailing_Agent_Code__c 
                       FROM Case_Subscription__c WHERE Subscription__c in :lstSubs AND Case__r.Status = :GlobalVariableClass.STATUS_CLOSED 
                       AND Case__r.Effective_Date__c > :todayDT 
                       AND Case__r.Change_of_Address_Type__c = :GlobalVariableClass.CHANGEVENDOR])
        {
            COAWrapper newCOA = new COAWrapper(caseSub.Case__r.Effective_Date__c, caseSub.CreatedDate, 
                      caseSub.Case__r.Vendor__r.Vendor_Group__c, caseSub.Case__r.Vendor__r.Mailing_Agent_Code__c);
            if(mapSubToCOA.containsKey(caseSub.Subscription__c))
            {
                COAWrapper preCOA = mapSubToCOA.get(caseSub.Subscription__c);
                if(newCOA.createDT > preCOA.createDT)
                    mapSubToCOA.put(caseSub.Subscription__c, newCOA);
            }
            else
                mapSubToCOA.put(caseSub.Subscription__c, newCOA);
        }        
        
        //Finally generate the Publication to POP Consolidation Dates mapping
        //for(Publication__c pubObj : mapPubIdToObj.values())
        for(Publication__c pubObj : [SELECT Id, Name, Publication_Code__c, Published_Days__c, Publication_Next_Start_Date__c, Platform_Type__c,  
                                                                    Frequency_Code__c, Public_Holiday_Weekend_Pub_Indicator__c, Public_Holiday_Weekday_Pub_Indicator__c 
                                                    FROM Publication__c WHERE ID in :mapPubDailyIssueDate.keyset()])
        {
            //Date nextIssueDate = pubObj.Publication_Next_Start_Date__c;
            Set<Date> lstPBIDate = mapPubDailyIssueDate.get(pubObj.Id);
            System.debug('pubObj.Id :'+pubObj.Id);
            
            List<Date> lstDates = new List<Date>();
            //Date Range: start_date = Today + 1, end_date = next_issue_date - 1
            if(pubObj.Frequency_Code__c == 'D') //Daily
            {
                for(Date tmpDate : lstPBIDate)
                {
                    if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, mapPubCodeToPreRunDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'W') //Weekly
            {
                for(Date tmpDate : lstPBIDate)
                {
                    if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, mapPubCodeToPreRunDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'F') //Fortnightly
            {
                for(Date tmpDate : lstPBIDate)
                {
                    if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, mapPubCodeToPreRunDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'M') //Monthly
            {
                for(Date tmpDate : lstPBIDate)
                {
                    if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, mapPubCodeToPreRunDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'B') //Bi-Monthly
            {
                for(Date tmpDate : lstPBIDate)
                {
                    if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, mapPubCodeToPreRunDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'Q') //Quarterly
            {
                for(Date tmpDate : lstPBIDate)
                {
                    if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, mapPubCodeToPreRunDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'H') //Half-Yearly
            {
                for(Date tmpDate : lstPBIDate)
                {
                    if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, mapPubCodeToPreRunDates, setHolidays, mapPubIdToPubPattern)){
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                    }
                }
            }
            else if(pubObj.Frequency_Code__c == 'Y') //Yearly
            {
                for(Date tmpDate : lstPBIDate)
                {
                    if(isPOPDate(pubObj, tmpDate, mapPubIdToNonPubDates, mapPubCodeToPreRunDates, setHolidays, mapPubIdToPubPattern))
                        lstDates.add(tmpDate);  //Add to list if it is publish date
                }
            }   
            System.debug(' pubObj.Id : '+pubObj.Id);
            System.debug(' lstDates : '+lstDates);
            
            if(!lstDates.isEmpty())
                mapPubIdToPOPDates.put(pubObj.Id, lstDates);                            
          
        }
        
        /*************************** Retrieve Temp Stops ************************/        
        for( Subscription_Temp_Stop__c tempStopObj : [SELECT Subscription__c, Temp_Stop__r.Temp_Stop_Date__c, Temp_Stop__r.Qty__c,
                                                      Temp_Stop__r.Restart_Date__c, Temp_Stop__r.Temp_Stop_Qty__c 
                                                      FROM Subscription_Temp_Stop__c 
                                                      WHERE Subscription__c IN :lstSubs AND Temp_Stop__r.Cancelled__c = false                                                       
                                                      AND Temp_Stop__r.Restart_Date__c >:todayDT])  
          {
            if(!mapSubIdToTStops.containsKey(tempStopObj.Subscription__c))
                mapSubIdToTStops.put(tempStopObj.Subscription__c, new List<Subscription_Temp_Stop__c> {tempStopObj});
            else
                mapSubIdToTStops.get(tempStopObj.Subscription__c).add(tempStopObj);
        }        
       
        /*************************** Processing for each Subscription ************************/
        for(Zuora__Subscription__c sub : lstSubs) 
        {
            Set<Id> setPubIds = mapSubIdToPubIds.get(sub.Id);
            if(setPubIds != null && !setPubIds.isEmpty())
            {
                Boolean hasTempStop = mapSubIdToTStops.containsKey(sub.Id);
                System.debug(setPubIds + ':' + setPubIds.size());
                //Retrieve the eligible dates for each pub
                for(Id pubId : setPubIds)
                {
                    List<Date> lstPOPDates = new List<Date>();
                    
                    System.debug('pubId : '+pubId);                    
                    System.debug('mapPubIdToPOPDates pubId : '+mapPubIdToPOPDates.get(pubId));                    
                    
                    if(mapPubIdToPOPDates.get(pubId) != Null){
                        lstPOPDates = mapPubIdToPOPDates.get(pubId);
                        //lstPOPDates.remove(null);
                    }
                    
                    System.debug('lstPOPDates isEmpty : '+lstPOPDates.isEmpty());
                    System.debug('lstPOPDates size : '+lstPOPDates.size());
                    
                    if(lstPOPDates != null && !lstPOPDates.isEmpty())
                    //if(lstPOPDates.size() > 0)
                    {
                        //Get User Subscription Frequency 
                        PubIssueHelper.PublicationPattern userPattern = PubIssueHelper.generateSubPattern(mapPubIdToObj.get(pubId), sub);
                        
                        System.debug('userPattern :'+userPattern);
                        System.debug('lstPOPDates : '+lstPOPDates);
                        for(Date popDate : lstPOPDates)
                        {
                            //Verify Subscription Start Date / End Date                                   
                            if(popDate < sub.Zuora__SubscriptionStartDate__c || (sub.Zuora__SubscriptionEndDate__c != null && popDate > sub.Zuora__SubscriptionEndDate__c))
                                continue;
                           
                            //Verify Holiday
                            if(setHolidays.contains(popDate) && !PubIssueHelper.isHolidayPublishDate(userPattern, popDate))
                                continue;
                            
                            //Check User Subscription Frequency 
                            if(!PubIssueHelper.isPublishDate(userPattern, popDate))
                                continue;                            
                            
                            Integer tempStopQty = 0;
                            
                            if(hasTempStop && mapPubIdToObj.get(pubId) != Null && mapPubIdToObj.get(pubId).Platform_Type__c == 'Print') //Having Temp Stops
                                tempStopQty = getTempStopQty(popDate, mapSubIdToTStops.get(sub.Id));
                           
                            //Creating Packing Label Batch Record                                                      
                            lstPLBData.add(createPLBRecord(sub, mapPubIdToObj.get(pubId), popDate, tempStopQty, mapSubToCOA.get(sub.Id))); 
                            System.debug('lstPLBData :'+lstPLBData);                                       
                        }
                    }
                }
            }
        }
        
        /*************************** Insert Data into DB ************************/
        if(!lstPLBData.isEmpty()) 
        {
            List<Database.SaveResult > saveResults = Database.insert(lstPLBData, false); 
            for(Database.SaveResult result : saveResults) {
                 // START I-0269 - PD-0104 - Raviteja - 09May2016 - Log the failed reasons
                if(!result.isSuccess()){
                        System.debug(Logginglevel.WARN, 'Insert Packing Label Batch Failed: ' + result);                        
                        List<Database.Error> err = result.getErrors();
                        Logger logger = new Logger('SP_PackingLabelBatch','SP060',BC.getJobId());                
                        logger.log(False,err[0].getMessage(),result.getId()); 
                        logger.save();
                    }
                 // END I-0269 - PD-0104 - Raviteja - 09May2016 - Log the failed reasons      
            } 
        }                       
      } 
      catch (Exception e) {                              
            BatchJobHelper.handleException(lstSubs,e,SP_PackingLabelBatch.class.getName(),'SP060',BC.getJobId(),BC.getJobId(),True);
            isSuccess = False; //START/END D-4583 24-Mar-2016 Added by Raviteja - Assigned job status failed if any error found
        }   
    }        
               
    global void finish(Database.BatchableContext BC) {                 
             System.debug('Job Completed');
             //START D-4583 24-Mar-2016 Added by Raviteja - Using BatchJobHelper.updateJobStatus to update the Status.        
         BatchJobHelper.updateJobStatus(BC.getJobId(),isSuccess);
         //End D-4583 24-Mar-2016 Added by Raviteja 
    }
    
    private Boolean isPOPDate(Publication__c publication, Date inputDate, Map<Id, Set<Date>> mapPubIdToNonPubDates, 
            Map<String, Set<Date>> mapPubCodeToPreRunDates, Set<Date> setHolidays, Map<Id, PubIssueHelper.PublicationPattern> mapPubIdToPubPattern)
    {
        //Verify Non-Publication Date
        System.debug('Checking for Non-Pub Days');
        if(mapPubIdToNonPubDates.containsKey(publication.Id) && mapPubIdToNonPubDates.get(publication.Id).contains(inputDate))
            return false;
        
        //Verify Previous Run Date
        System.debug('Checking for previous runs');
        if(mapPubCodeToPreRunDates.containsKey(publication.Publication_Code__c) 
            && mapPubCodeToPreRunDates.get(publication.Publication_Code__c).contains(inputDate))
            return false;
            
        //Verify Holiday
        System.debug('Checking for Holidays');
        if(setHolidays.contains(inputDate) && !PubIssueHelper.isHolidayPublishDate(publication, inputDate))
            return false;
        
        //Verify Publish Days for Publications : cater for various frequency
        System.debug('Checking for Frequency');
        if(publication.Frequency_Code__c == 'D') //Daily Publication
        {
            PubIssueHelper.PublicationPattern pattern = mapPubIdToPubPattern.get(publication.Id);
            System.debug('is publish date :' + PubIssueHelper.isPublishDate(pattern, inputDate)); 
            return PubIssueHelper.isPublishDate(pattern, inputDate);
        }
        else 
            return true; //Frequency already catered in the for loop for Non-daily Publications
        
        System.debug('ALL PASS!!!');
        return true;
    }    
  
    public Integer getTempStopQty(Date inputDate, List<Subscription_Temp_Stop__c> lstTempStops)
    {
        for(Subscription_Temp_Stop__c tempStop : lstTempStops)
        {
            //Temp Stop Date Range: Temp_Stop_Date__c to Restart_Date__c minus 1 day
            if(tempStop.Temp_Stop__r.Temp_Stop_Date__c <= inputDate && tempStop.Temp_Stop__r.Restart_Date__c > inputDate)
                return tempStop.Temp_Stop__r.Qty__c == null ? 0 : Integer.valueOf(tempStop.Temp_Stop__r.Qty__c);
        }
        
        return 0;
    }
    
    private CMIS_POP_Packing_label_Batch__c createPLBRecord(Zuora__Subscription__c sub, Publication__c pub, Date popDate, Integer tempStopQty, COAWrapper coaRec)   
    {      
        Boolean isLocal = (sub.Recipient_Contact__r.Address__r.RecordType.DeveloperName == 'Local'
                             || sub.Recipient_Contact__r.Address__r.RecordType.DeveloperName == 'Airline'
                             || sub.Recipient_Contact__r.Address__r.RecordType.DeveloperName == 'Internal');             
        
        Boolean isOverseas = (sub.Recipient_Contact__r.Address__r.RecordType.DeveloperName == 'Overseas');       
        Boolean isFreeList = sub.Other_PaymentMethod_1__c == 'FreeList'? True : False;       
        
        CMIS_POP_Packing_label_Batch__c plbRec = new CMIS_POP_Packing_label_Batch__c();              
        
        System.debug('in createPLBRecord sub : '+sub);
        System.debug('in createPLBRecord sub.Delivered_By_1__c : '+sub.Delivered_By_1__c);
        System.debug('in createPLBRecord pub : '+pub);
        System.debug('in createPLBRecord popDate : '+popDate);
        System.debug('in createPLBRecord tempStopQty : '+tempStopQty);
        System.debug('in createPLBRecord coaRec : '+coaRec);
        
        if(sub.Delivered_By_1__c == 'Mailing Agent')
        {
            //Check COA / COV
            if(coaRec != null && coaRec.effectiveDT != null && coaRec.effectiveDT <= popDate)
            {
                plbRec.Mailing_Agent__c = coaRec.vendorCode;
                // START I-0269 - Raviteja - 23May2016 - Assigning Vendor Group as 'V'
                //plbRec.Vendor_Group__c = coaRec.vendorGroup;   
                 plbRec.Vendor_Group__c = (coaRec.vendorGroup == null) ? 'V' : coaRec.vendorGroup; 
                // END I-0269 - Raviteja - 23May2016 - Assigning Vendor Group as 'V'
                
                plbRec.Postal_Zone__c = coaRec.addressAssignmentRecord.Address__r.Postal_Sector__c;
                
                plbRec.Airline_City_Code__c = coaRec.addressAssignmentRecord.Address__r.City__r.Name;
                 //Start/End 30Mar2016 - Raviteja - Update airline packing group from Packing_Code__r.Packing_Code__c
                //plbRec.Airline_Packing_Group__c = coaRec.addressAssignmentRecord.Address__r.Packing_Code__r.Name;            
                plbRec.Airline_Packing_Group__c = coaRec.addressAssignmentRecord.Address__r.Packing_Code__r.Packing_Code__c;            
                //End 30Mar2016 - Raviteja
                plbRec.Packing_Group_Description__c = coaRec.addressAssignmentRecord.Address__r.Packing_Group_Description__c;
                
                plbRec.Address_Record_Type__c = coaRec.addressAssignmentRecord.Address__r.RecordType.DeveloperName;
                plbRec.Block_House_Number__c = coaRec.addressAssignmentRecord.Address__r.Block_House_Number__c;
                plbRec.Street_Name__c = coaRec.addressAssignmentRecord.Address__r.Street_Name__c;
                plbRec.Level_Number__c = coaRec.addressAssignmentRecord.Address__r.Level_Number__c;
                plbRec.Unit_Number__c = coaRec.addressAssignmentRecord.Address__r.Unit_Number__c;
                plbRec.Building_Name__c = coaRec.addressAssignmentRecord.Address__r.Building_Name__c;
                plbRec.Country_Name__c = coaRec.addressAssignmentRecord.Address__r.Country_Name__c;
                plbRec.Postal_Code__c = coaRec.addressAssignmentRecord.Address__r.Postal_Code__r.Name;
                plbRec.Address_1__c = coaRec.addressAssignmentRecord.Address__r.Address_1__c;
                plbRec.Address_2__c = coaRec.addressAssignmentRecord.Address__r.Address_2__c;
                plbRec.Address_3__c = coaRec.addressAssignmentRecord.Address__r.Address_3__c;
                plbRec.Address_4__c = coaRec.addressAssignmentRecord.Address__r.Address_4__c;
                plbRec.Section_Code__c = coaRec.addressAssignmentRecord.Address__r.Section_Code__r.Name;
                plbRec.Department__c = coaRec.addressAssignmentRecord.Address__r.Department__r.Name;
                plbRec.Division_Code__c = coaRec.addressAssignmentRecord.Address__r.Division_Code__r.Name;
                plbRec.Company_Code__c = coaRec.addressAssignmentRecord.Address__r.Company_Code__r.Name;
                plbRec.Location_Code__c = coaRec.addressAssignmentRecord.Address__r.Location_Code__r.Name;
                plbRec.Country_Name__c = coaRec.addressAssignmentRecord.Address__r.Country_Name__c;
                plbRec.Airline_Number__c = coaRec.addressAssignmentRecord.Address__r.Airline_Number__c;
                plbRec.Flight_Number__c = coaRec.addressAssignmentRecord.Address__r.Flight_Number_1__c;
                plbRec.Flight_Number_2__c = coaRec.addressAssignmentRecord.Address__r.Flight_Number_2__c;
                //Start 30Mar2016 - Raviteja - Updated the Airline_Name__c assignment
                //plbRec.Airline_Name__c = coaRec.addressAssignmentRecord.Address__r.Packing_Code__r.Airline__c;
                plbRec.Airline_Name__c = coaRec.addressAssignmentRecord.Address__r.City__r.Airline__c;
                //End 30Mar2016 - Raviteja 
                //Start/End 30Mar2016 - Raviteja - Sequence Number to 0 in case that the Sequence Number from Recipieng Address is null
                if(coaRec.addressAssignmentRecord.Address__r.Packing_Code__r.Sequence_Number__c != null){
                    plbRec.Sequence_Number__c = String.valueOf(coaRec.addressAssignmentRecord.Address__r.Packing_Code__r.Sequence_Number__c);
                  }   
                else{
                    plbRec.Sequence_Number__c = '0';
                }
                //Start 30Mar2016 - Raviteja - Updated the assignment for City_Code__c 
                //plbRec.City_Code__c = coaRec.addressAssignmentRecord.Address__r.City__r.City_code__c;
                plbRec.City_Code__c = coaRec.addressAssignmentRecord.Address__r.City__r.City_Name__c;
                //End 30Mar2016 - Raviteja - 
                plbRec.Remarks__c = coaRec.addressAssignmentRecord.Address__r.City__r.Remarks__c;

            }
            else
            {
                plbRec.Mailing_Agent__c = sub.Vendor_1__r.Mailing_Agent_Code__c;  
                plbRec.Vendor_Group__c = (sub.Vendor_1__r.Vendor_Group__c == null) ? 'V' : sub.Vendor_1__r.Vendor_Group__c; 
                
                plbRec.Postal_Zone__c = sub.Recipient_Contact__r.Address__r.Postal_Sector__c;
                
                plbRec.Airline_City_Code__c = sub.Recipient_Contact__r.Address__r.City__r.Name;
                 //Start 30Mar2016 - Raviteja - Updated the Airline_Packing_Group__c with Packing_Code__r.Packing_Code__c
                //plbRec.Airline_Packing_Group__c = sub.Recipient_Contact__r.Address__r.Packing_Code__r.Name;             
                plbRec.Airline_Packing_Group__c = sub.Recipient_Contact__r.Address__r.Packing_Code__r.Packing_Code__c;             
                //End 30Mar2016 - Raviteja - 
                plbRec.Packing_Group_Description__c = sub.Recipient_Contact__r.Address__r.Packing_Group_Description__c;
                
                plbRec.Address_Record_Type__c = sub.Recipient_Contact__r.Address__r.RecordType.DeveloperName;
                plbRec.Block_House_Number__c = sub.Recipient_Contact__r.Address__r.Block_House_Number__c;
                plbRec.Street_Name__c = sub.Recipient_Contact__r.Address__r.Street_Name__c;
                plbRec.Level_Number__c = sub.Recipient_Contact__r.Address__r.Level_Number__c;
                plbRec.Unit_Number__c = sub.Recipient_Contact__r.Address__r.Unit_Number__c;
                plbRec.Building_Name__c = sub.Recipient_Contact__r.Address__r.Building_Name__c;
                plbRec.Country_Name__c = sub.Recipient_Contact__r.Address__r.Country_Name__c;
                plbRec.Postal_Code__c = sub.Recipient_Contact__r.Address__r.Postal_Code__r.Name;
                plbRec.Address_1__c = sub.Recipient_Contact__r.Address__r.Address_1__c;
                plbRec.Address_2__c = sub.Recipient_Contact__r.Address__r.Address_2__c;
                plbRec.Address_3__c = sub.Recipient_Contact__r.Address__r.Address_3__c;
                plbRec.Address_4__c = sub.Recipient_Contact__r.Address__r.Address_4__c;
                plbRec.Section_Code__c = sub.Recipient_Contact__r.Address__r.Section_Code__r.Name;
                plbRec.Department__c = sub.Recipient_Contact__r.Address__r.Department__r.Name;
                plbRec.Division_Code__c = sub.Recipient_Contact__r.Address__r.Division_Code__r.Name;
                plbRec.Company_Code__c = sub.Recipient_Contact__r.Address__r.Company_Code__r.Name;
                plbRec.Location_Code__c = sub.Recipient_Contact__r.Address__r.Location_Code__r.Name;
                plbRec.Country_Name__c = sub.Recipient_Contact__r.Address__r.Country_Name__c;
                plbRec.Airline_Number__c = sub.Recipient_Contact__r.Address__r.Airline_Number__c;
                plbRec.Flight_Number__c = sub.Recipient_Contact__r.Address__r.Flight_Number_1__c;
                plbRec.Flight_Number_2__c = sub.Recipient_Contact__r.Address__r.Flight_Number_2__c;
                //Start 30Mar2016 - Raviteja - Updated the Airline_Name__c assignment
                //plbRec.Airline_Name__c = sub.Recipient_Contact__r.Address__r.Packing_Code__r.Airline__c;
                plbRec.Airline_Name__c = sub.Recipient_Contact__r.Address__r.City__r.Airline__c;
                //End 30Mar2016 - Raviteja
                //Start/End 30Mar2016 - Raviteja - Sequence Number to 0 in case that the Sequence Number from Recipieng Address is null
                if(sub.Recipient_Contact__r.Address__r.Packing_Code__r.Sequence_Number__c != null){
                    plbRec.Sequence_Number__c = String.valueOf(sub.Recipient_Contact__r.Address__r.Packing_Code__r.Sequence_Number__c);
                }    
                else{
                    plbRec.Sequence_Number__c = '0';
                }                
                    
                //Start 30Mar2016 - Raviteja - Updated the assignment for City_Code__c 
                //plbRec.City_Code__c = sub.Recipient_Contact__r.Address__r.City__r.City_code__c;
                plbRec.City_Code__c = sub.Recipient_Contact__r.Address__r.City__r.City_Name__c;
                //End 30Mar2016 - Raviteja
                plbRec.Remarks__c = sub.Recipient_Contact__r.Address__r.City__r.Remarks__c;
            }           
        }       
        
        System.debug('in createPLBRecord plbRec.Mailing_Agent__c : '+plbRec.Mailing_Agent__c);
        
        if(plbRec.Mailing_Agent__c == Null){
            plbRec.Mailing_Agent__c = 'MLAGN';
        }
                 
        plbRec.Attention_To_Care_Of_Indicator__c = sub.Zuora__CustomerAccount__r.Attention_To_Care_Of_Indicator__c;
        
        //START D-4583 24-Mar-2016 Kevin Evasco - Added Attn To Name
        plbRec.Attn_To_Name__c = sub.Recipient_Contact__r.Company_Name__c;
        //END D-4583 24-Mar-2016 Kevin Evasco - Added Attn To Name
        plbRec.Publication_Code__c = pub.Publication_Code__c;       
        plbRec.Publication_Issue_Date__c = popDate;
        plbRec.Subscription_Name__c = sub.Name;
        plbRec.Subscription__c = sub.Id; 
        plbRec.External_Id__c = sub.Vendor_1__r.Mailing_Agent_Code__c + pub.Publication_Code__c + sub.Name;
        plbRec.Batch_Run_Date__c = ovdFromDate; //START/END D-4626 04-Apr-2016 Raviteja Kumar - Added Batch_Run_Date__c  
        
        Integer qtyToPrint = (sub.qty__c == null) ? 0 : Integer.valueOf(sub.qty__c);
        qtyToPrint = qtyToPrint - tempStopQty; //Minus Temp Stop Quantity
        
        plbRec.Total_Direct_Subscriptions__c = qtyToPrint;
        plbRec.Total_Sponsored_Copies__c = sub.Sponsor_1__c ? qtyToPrint : 0;
        
        plbRec.Subscriber_Account_Number__c = sub.Zuora__Account__r.Account_Auto_Number__c;
        plbRec.Recipient_Number__c = sub.Recipient_Contact__r.Recipient_Number_Show__c;
        plbRec.First_Name__c = sub.Recipient_Contact__r.FirstName;
        plbRec.Last_Name__c = sub.Recipient_Contact__r.LastName;
        
        if(isFreeList)
            plbRec.Freelist_Indicator__c = 'Y';
        else
            plbRec.Freelist_Indicator__c = 'N';
        
        if(isLocal) {           
            plbRec.Total_Local_Subscription_Copies__c = isFreeList ? 0 : qtyToPrint;                     
            plbRec.Total_Local_Freelist_Copies__c = isFreeList ? qtyToPrint : 0;
            plbRec.Total_Overseas_Subscription_Copies__c = 0;
            plbRec.Total_Overseas_Freelist_Copies__c = 0;
        }
        else if(isOverseas) {
            plbRec.Total_Local_Subscription_Copies__c = 0;
            plbRec.Total_Local_Freelist_Copies__c = 0;            
            plbRec.Total_Overseas_Subscription_Copies__c = isFreeList ? 0 : qtyToPrint;                
            plbRec.Total_Overseas_Freelist_Copies__c = isFreeList ? qtyToPrint : 0;
        }
        else{
            plbRec.Total_Local_Subscription_Copies__c = 0;
            plbRec.Total_Local_Freelist_Copies__c = 0;
            plbRec.Total_Overseas_Subscription_Copies__c = 0;
            plbRec.Total_Overseas_Freelist_Copies__c = 0;
        }
        
        System.debug('plbRec :'+plbRec);
        return plbRec;
    }     
    
    Class COAWrapper
    {
        Date effectiveDT;
        Datetime createDT;
        String vendorGroup;
        String vendorCode;
        Address_Assignment__c addressAssignmentRecord;
        
        COAWrapper(Date startDate, Datetime createdDate, String strGroup, String strCode)
        {
            effectiveDT = startDate;
            createDT = createdDate;
            vendorGroup = strGroup;
            vendorCode = strCode;
        }
    }
}