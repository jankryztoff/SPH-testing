/**
* Class Name: SP_PackingLabelBatchRecordCreation
* @author: Alyana P. Navarro
* Date: 4/15/2015
* Requirement/Project Name: SPH Project
* @description Batch Apex Class to create records in Packing Label Batch Object
*/
//START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
global class SP_PackingLabelBatchRecordCreation implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    Set<String> selectiveIds = null;
    Boolean isAdhoc = false;
    Boolean isApexJobSuccessful = true;
    Date adhocBatchRunDate = null;
    Map<String, Date> backupPubNextStartDate = null;

    global SP_PackingLabelBatchRecordCreation(){

    }

    global SP_PackingLabelBatchRecordCreation(Set<String> selectiveIds, Date adhocBatchRunDate, String backupPubNextStartDate){
        this.selectiveIds = selectiveIds;
        this.adhocBatchRunDate = adhocBatchRunDate;

        if(backupPubNextStartDate != null){
            this.backupPubNextStartDate = (Map<String, Date>)JSON.deserialize(backupPubNextStartDate, Map<String, Date>.class);    
        }
        
        isAdhoc = true;
    }
    //END: D-3672 11/13/2015 Added by Kristine Balaoing
    
   /* @description Called at the beginning of the apex job to collect the objects    
    * to be passed to the execute method    
    * @param bc - predefined parameter     
    * @return list of objects from Subscription Object    
    */                               
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        //START D-3013 05/22/2015 Added By S.Puli
        //START : D-3014 05/25/2015 S.Puli
        //START : D-3015 05/25/2015 S.Puli
        //START UD-1551 24-Aug-2015 Added By S.Puli - Change logic of packing label record creation
        
        Set<string> SubFrequency = new Set<string>();
        DateTime myDateTime = (DateTime) system.today();
        Date dToday = date.today();
        //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
        if(isAdhoc){
            myDateTime = adhocBatchRunDate;
            dToday = adhocBatchRunDate;
        }
        //END: D-3672 11/13/2015 Added by Kristine Balaoing
        string dayOfWeek = myDateTime.Format('E');
        
        SubFrequency.add('Default');
        if (dayOfWeek == 'Mon' || dayOfWeek == 'Tue' || dayOfWeek == 'Wed' || dayOfWeek == 'Thu' || dayOfWeek == 'Fri') {
            SubFrequency.add('Mon - Fri'); SubFrequency.add('Mon - Sat');
        }
        if (dayOfWeek == 'Sat' || dayOfWeek == 'Sun') {
            SubFrequency.add('Sat - Sun');
            SubFrequency.add('Fri - Sun');
        }
        
        if (dayOfWeek == 'Sat') {
            SubFrequency.add('Mon - Sat');
        }
        
        if (dayOfWeek == 'Fri') {
            SubFrequency.add('Fri - Sun');         
        }
        //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
        String query = 
        'SELECT id, Zuora__Account__c, Zuora__Account__r.Name, Zuora__Account__r.AccountNumber, Vendor_1__r.AccountNumber, ' +
        'Recipient_Contact__r.Address__r.Unit_Number__c, Recipient_Contact__r.Name, Recipient_Contact__r.Address__r.RecordType.Name, ' +
        'Recipient_Contact__r.Address__r.Address_1__c, Recipient_Contact__r.Address__r.Address_2__c, ' +
        'Recipient_Contact__r.Address__r.Address_3__c, Recipient_Contact__r.Address__r.Address_4__c, ' +
        'Recipient_Contact__r.Address__r.Block_House_Number__c, Recipient_Contact__r.Address__r.Building_Name__c, ' +
        'Recipient_Contact__r.Salutation, Grace_Period_Subscription__c, Other_PaymentMethod_1__c, ' +
        'Recipient_Contact__r.Address__r.Country_Name__c, Recipient_Contact__r.Address__r.Flight_Number_1__c, Recipient_Contact__r.Address__r.Flight_Number_2__c, Recipient_Contact__r.Address__r.Postal_Code__r.Name, Recipient_Contact__r.Address__r.Street_Name__c, '+
        'Recipient_Contact__r.Address__r.Level_Number__c, Number_of_Copies__c, Recipient_Contact__r.Recipient_Number__c, ' +
        'Order_Number_1__r.Total_Subscription_Rate__c, Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c, isFreeList__c, ' +
        'Main_Package_1__r.Package_Price__c, Recipient_Contact__r.Address__r.Department__r.Name, Recipient_Contact__r.Address__r.Division_Code__r.Name, Recipient_Contact__r.Address__r.Company_Name__c, Recipient_Contact__r.Address__r.Section_Code__r.Name, Main_Package_1__r.Package_Type__c, Recipient_Contact__r.Address__r.Location_Code__r.Name, ' +
        'Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c,Frequency_1__c ' +
        
                 //Start VPernicia D-3722 11/11/2015: Added fields
        ',Order_Line_Item_Number_1__r.Ph_e__c ' +
        ',Order_Line_Item_Number_1__r.Ph_d__c ' +
                 //End VPernicia D-3722 11/11/2015: Added fields
        
        'FROM Zuora__Subscription__c ' +
                 //WHERE CreatedDate = TODAY AND Subscription_Type_1__c = 'Publication' AND Zuora__Status__c = 'Active']);
                 // Start UD-2133 VPernicia 09/03/15: additional criteria 'or Zuora__SubscriptionEndDate__c = null' for evergreen
                 'WHERE Frequency_1__c in: SubFrequency AND Subscription_Type_1__c = \'Publication\' AND Zuora__SubscriptionStartDate__c <= :dToday AND (Zuora__SubscriptionEndDate__c >= :dToday or Zuora__SubscriptionEndDate__c = null)';
                 // End UD-2133 VPernicia 09/03/15: additional criteria 'or Zuora__SubscriptionEndDate__c = null' for evergreen
        if(selectiveIds != null){
            query += 'AND ID = :selectiveIds ';
        }

        return Database.getQueryLocator(query);
        //END: D-3672 11/13/2015 Added by Kristine Balaoing        
        //END UD-1551 24-Aug-2015 Added By S.Puli - Change logic of packing label record creation
        //END : D-3015 05/25/2015 S.Puli
        //END : D-3014 05/25/2015 S.Puli
        //END D-3013 05/22/2015 Added By S.Puli
    }
                                 
   /* @description Executes the business logic and creates record in Packing Label Batch Object
    * @param bc - predefined parameter  
    * @param subscriptionList - a list of sObjects from the initial database query     
    * @return void
    */ 
    global void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> subscriptionList) {

        Packing_Label_Batch__c packingLabelBatch = new Packing_Label_Batch__c();
        Set<Id> subIdSet = new Set<Id>();
        Set<String> pubCodeSet = new Set<String>();
        List<Packing_Label_Batch__c> packingLabelBatchList = new List<Packing_Label_Batch__c>();
        List<Packing_Label_Batch__c> existingPackingLabelBatchList = new List<Packing_Label_Batch__c>();
        List<Zuora__SubscriptionProductCharge__c> subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();
        List<Publication__c> publicationList = new List<Publication__c>();
        Map<Id, Publication__c> subIdPublicationMap = new Map<Id, Publication__c>();
        Map<Id, Set<String>> subIdPubCodeSetMap = new Map<Id, Set<String>>();       
        Map<String, Publication__c> publicationMap = new Map<String, Publication__c>();
        Map<Id, Packing_Label_Batch__c> packingLabelBatchMap = new Map<Id, Packing_Label_Batch__c>();
        //START UD-1551 24-Aug-2015 Added By S.Puli - Change logic of packing label record creation
        Map<Id, Zuora__Subscription__c> subIdToSubscription_MAP = new Map<Id, Zuora__Subscription__c>();
        List<Zuora__Subscription__c> finalSubscriptionList = new List<Zuora__Subscription__c>();
        //END UD-1551 24-Aug-2015 Added By S.Puli - Change logic of packing label record creation
    //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
        Date adhocToday = Date.today();
        if(isAdhoc){
            adhocToday = adhocBatchRunDate;
        }

        Logger logger = new Logger(SP_PackingLabelBatchRecordCreation.class.getName(), 'SP052', BC.getJobID());

        try{
            for(Zuora__Subscription__c sub : subscriptionList){         
                subIdSet.add(sub.id);
            //START UD-1551 24-Aug-2015 Added By S.Puli - Change logic of packing label record creation
                subIdToSubscription_MAP.put(sub.Id, sub);
            }
           
            //existingPackingLabelBatchList = [SELECT id, name, Subscription__c FROM Packing_Label_Batch__c WHERE Subscription__c IN: subIdSet];
            
            //for(Packing_Label_Batch__c packLabelBatch : existingPackingLabelBatchList){
                //packingLabelBatchMap.put(packLabelBatch.Subscription__c, packLabelBatch);
            //}
            
            
            subProdChargeList = [SELECT id, name, Product_Code__c, Zuora__Subscription__c,PublicationCode__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c IN: subIdSet];
                    
            for(Zuora__SubscriptionProductCharge__c subProdCharge : subProdChargeList){
                if(subProdCharge.PublicationCode__c != null){
                //START UD-1551 24-Aug-2015 Added By S.Puli - Change logic of packing label record creation
                    pubCodeSet.add(subProdCharge.PublicationCode__c);
                
                    if(subIdPubCodeSetMap.containsKey(subProdCharge.Zuora__Subscription__c)){
                        subIdPubCodeSetMap.get(subProdCharge.Zuora__Subscription__c).add(subProdCharge.PublicationCode__c);
                    } else {                
                        subIdPubCodeSetMap.put(subProdCharge.Zuora__Subscription__c, new Set<String>{subProdCharge.PublicationCode__c});
                    }
                }
                //END UD-1551 24-Aug-2015 Added By S.Puli - Change logic of packing label record creation
            }
            
            publicationList = [SELECT id, name, Earliest_Start_Date__c, Publication_Code__c,Publication_Next_Start_Date__c,Frequency_Code__c,Public_Holiday_Weekday_Pub_Indicator__c,Public_Holiday_Weekend_Pub_Indicator__c,Published_Days__c FROM Publication__c WHERE Publication_Code__c IN: pubCodeSet];
            system.debug('publicationList: '+publicationList);
            //END UD-1551 24-Aug-2015 Added By S.Puli - Change logic of packing label record creation
            for(Publication__c pub : publicationList){
                publicationMap.put(pub.Publication_Code__c, pub);
                try{
                    if(!isAdhoc){
                        backupPubNextStartDate.put(pub.Publication_Code__c, pub.Publication_Next_Start_Date__c);    
                    }
                } catch(Exception e){                   
                    system.debug('Error : ' + e.getMessage());
                }
            }
            
            for(Id subId : subIdPubCodeSetMap.keySet()){            
                Date earliestStartDate;
                String tempPubCode;
                for(String pubCode : subIdPubCodeSetMap.get(subId)){
                    if(publicationMap.containsKey(pubCode)){
                        if(earliestStartDate == null){
                            if(publicationMap.get(pubCode).Earliest_Start_Date__c != null){
                                earliestStartDate = publicationMap.get(pubCode).Earliest_Start_Date__c;
                                tempPubCode = pubCode;
                            }
                        } else {
                            if(publicationMap.get(pubCode).Earliest_Start_Date__c != null){
                                if(publicationMap.get(pubCode).Earliest_Start_Date__c < earliestStartDate){
                                    earliestStartDate = publicationMap.get(pubCode).Earliest_Start_Date__c;
                                    tempPubCode = pubCode;
                                }
                            }
                        }
                    }
                }
                if(publicationMap.containsKey(tempPubCode)){
                    subIdPublicationMap.put(subId, publicationMap.get(tempPubCode));
                }
            }
            
            //START UD-1551 24-Aug-2015 Added By S.Puli - Change logic of packing label record creation
            Map<string, date> pubToNonPubDate_MAP = new Map<string, date>();
            List<Non_Publication_Day__c> nonPubDays_LIST = [Select id,Non_Publication_Date__c,Publication_Code__c from Non_Publication_Day__c where Publication_Code__c IN :publicationMap.keySet() AND Non_Publication_Date__c = :adhocToday];
            if(nonPubDays_LIST.size()>0){
                for(Non_Publication_Day__c nonPub : nonPubDays_LIST){
                    if(nonPub.Non_Publication_Date__c <> null){
                        pubToNonPubDate_MAP.put(nonPub.Publication_Code__c, nonPub.Non_Publication_Date__c);
                    }
                }
            }
            system.debug('pubToNonPubDate_MAP: '+pubToNonPubDate_MAP);
            //START D-3703 05-Oct-2015 Added by S.Puli - move initialize outside the loop
            UsageHelper.initialize();
            //END D-3703 05-Oct-2015 Added by S.Puli 
            for(Zuora__Subscription__c sub : subscriptionList){
                
                if(subIdPublicationMap.containsKey(sub.Id) && subIdPubCodeSetMap.containsKey(sub.Id)){  
                    for(String pubCode : subIdPubCodeSetMap.get(sub.Id)){
                        if(sub.Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c == 'Newspaper'){
                            Date currDate = date.today();
                            
                            if(isAdhoc){
                                currDate = adhocToday;
                            }
        //END: D-3672 11/13/2015 Added by Kristine Balaoing
                            Decimal noOfCopies = sub.Number_of_Copies__c;
                            Decimal weekdayIssue;
                            Decimal SaturdayIssue;
                            Decimal SundayIssue;
                            Decimal oddFreq;

                            //START D-3703 05-Oct-2015 Added by S.Puli - move initialize outside the loop
                            //UsageHelper.initialize();
                            //END D-3703 05-Oct-2015 Added by S.Puli 
                            PublicationIssueWrapper pubWrapper = UsageHelper.IssueCalculation(pubCode, currDate, currDate, subIdToSubscription_MAP.get(sub.Id), Integer.valueOf(noOfCopies));
                            
                            //Start VPernicia D-3722 11/11/15: Added condition to check if pubWrapper is not null
                            if (pubWrapper != null) {
                                system.debug('pubWrapper: '+pubWrapper);
                                weekdayIssue = Decimal.valueOf(pubWrapper.weekday_no_of_copies);
                                SaturdayIssue = Decimal.valueOf(pubWrapper.sat_no_of_copies);
                                SundayIssue = Decimal.valueOf(pubWrapper.sun_no_of_copies);
                                oddFreq = Decimal.valueOf(pubWrapper.odd_freq_copies);
                                //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
                                if(weekdayIssue > 0 || SaturdayIssue > 0 || SundayIssue > 0 ){
                                    finalSubscriptionList.add(sub);
                                }
                                //END: D-3672 11/13/2015 Added by Kristine Balaoing
                            }
                            //End VPernicia D-3722 11/11/15: Added condition to check if pubWrapper is not null
                                
                            
                        } else if(sub.Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c == 'Magazine'){
                            if(publicationMap.containsKey(pubCode)){
                                if(!pubToNonPubDate_MAP.containsKey(pubCode)){
                                    Publication__c pubRec = publicationMap.get(pubCode);
                                    if(pubRec.Publication_Next_Start_Date__c <> null){
                                        //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
                                        Date nextDate = null;
                                        Date currDate = date.today();
                                        DateTime dateTimeNow = (DateTime) system.today();

                                        if(isAdhoc){
                                            nextDate = backupPubNextStartDate.get(pubCode);
                                            currDate = adhocBatchRunDate;
                                            dateTimeNow = adhocBatchRunDate;
                                        }

                                        if(pubRec.Publication_Next_Start_Date__c <> null || (isAdhoc && nextDate != null)){
                                            string dayToday = dateTimeNow.Format('E');

                                            if(!isAdhoc){
                                                nextDate = pubRec.Publication_Next_Start_Date__c;    
                                            }
                                            
                                            PubIssueHelper.PublicationPattern pubPattern = PubIssueHelper.generatePubPattern(pubRec);
                                            if((dayToday == 'Mon' && pubPattern.isMon)||(dayToday == 'Tue' && pubPattern.isTue)||(dayToday == 'Wed' && pubPattern.isWed)||(dayToday == 'Thu' && pubPattern.isThu)||(dayToday == 'Fri' && pubPattern.isFri)||(dayToday == 'Sat' && pubPattern.isSat)||(dayToday == 'Sun' && pubPattern.isSun)){
                                                        
                                                if(pubRec.Frequency_Code__c == 'W'){
                                                    if(Math.mod(currDate.daysBetween(nextDate),7) == 0){
                                                        finalSubscriptionList.add(sub);
                                                    }
                                                } else if(pubRec.Frequency_Code__c == 'F'){
                                                    if(Math.mod(currDate.daysBetween(nextDate),14) == 0){
                                                        finalSubscriptionList.add(sub);
                                                    }
                                                } else if(pubRec.Frequency_Code__c == 'M'){
                                                    if(currDate.day() == nextDate.day()){
                                                        finalSubscriptionList.add(sub);
                                                    }
                                                } else if(pubRec.Frequency_Code__c == 'B'){
                                                    if(currDate.day() == nextDate.day() && Math.mod(currDate.monthsBetween(nextDate), 2) == 0){
                                                        finalSubscriptionList.add(sub);
                                                    }
                                                } else if(pubRec.Frequency_Code__c == 'Q'){
                                                    if(currDate.day() == nextDate.day() && Math.mod(currDate.monthsBetween(nextDate), 3) == 0){
                                                        finalSubscriptionList.add(sub);
                                                    }
                                                } else if(pubRec.Frequency_Code__c == 'H'){
                                                    if(currDate.day() == nextDate.day() && Math.mod(currDate.monthsBetween(nextDate), 6) == 0){
                                                        finalSubscriptionList.add(sub);
                                                    }
                                                } else if(pubRec.Frequency_Code__c == 'Y'){
                                                    if(currDate.day() == nextDate.day() && Math.mod(currDate.monthsBetween(nextDate), 12) == 0){
                                                        finalSubscriptionList.add(sub);
                                                    }
                                                }
                                            }                                       
                                        }
                                    }
                                }
                            }   //END: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
                        }
                    }
                }           
                
            }
            system.debug('finalSubscriptionList: '+finalSubscriptionList);
            for(Zuora__Subscription__c sub : finalSubscriptionList){
            //END UD-1551 24-Aug-2015 Added By S.Puli - Change logic of packing label record creation
                if(!packingLabelBatchMap.containsKey(sub.id)){                                      
                    packingLabelBatch = new Packing_Label_Batch__c();
                    packingLabelBatch.Account_Name__c = sub.Zuora__Account__c;
                    //START : D-3015 05/25/2015 S.Puli
                    if(sub.Recipient_Contact__r.Address__r.RecordType.Name == GlobalVariableClass.INTERNAL){
                        packingLabelBatch.Address_1__c = sub.Recipient_Contact__r.Address__r.Section_Code__r.Name;
                        packingLabelBatch.Address_2__c = sub.Recipient_Contact__r.Address__r.Department__r.Name;//Division_Code__r
                        packingLabelBatch.Address_3__c = sub.Recipient_Contact__r.Address__r.Division_Code__r.Name;//Company_Name__c
                        packingLabelBatch.Address_4__c = sub.Recipient_Contact__r.Address__r.Company_Name__c;//Section_Code__r
                        packingLabelBatch.Address_5__c = sub.Recipient_Contact__r.Address__r.Location_Code__r.Name;
                    } else {
                        packingLabelBatch.Address_1__c = sub.Recipient_Contact__r.Address__r.Address_1__c;
                        packingLabelBatch.Address_2__c = sub.Recipient_Contact__r.Address__r.Address_2__c;
                        packingLabelBatch.Address_3__c = sub.Recipient_Contact__r.Address__r.Address_3__c;
                        packingLabelBatch.Address_4__c = sub.Recipient_Contact__r.Address__r.Address_4__c;  
                    }
                    //END : D-3015 05/25/2015 S.Puli
                    packingLabelBatch.Block__c = sub.Recipient_Contact__r.Address__r.Block_House_Number__c; 
                    packingLabelBatch.Building_Name__c = sub.Recipient_Contact__r.Address__r.Building_Name__c;
                                                                        
                    //START D-3013 05/22/2015 Added By S.Puli
                    //START : D-3014 05/25/2015 S.Puli
                    //START : D-3015 05/25/2015 S.Puli
                    if(sub.Other_PaymentMethod_1__c == GlobalVariableClass.FREE_LIST || sub.Main_Package_1__r.Package_Price__c == 0 ||sub.Main_Package_1__r.Package_Type__c == GlobalVariableClass.PACKAGETYPE_GRACE){
                    //END : D-3014 05/25/2015 S.Puli
                    //END D-3013 05/22/2015 Added By S.Puli
                        packingLabelBatch.Copy_Type__c = GlobalVariableClass.FREELIST;
                    } else {
                        packingLabelBatch.Copy_Type__c = GlobalVariableClass.ZUORA_SUBSCRIPTION_OBJ;
                    }
                    //END : D-3015 05/25/2015 S.Puli
                    if(sub.Recipient_Contact__r.Address__r.Country_Name__c != null){
                        if(sub.Recipient_Contact__r.Address__r.Country_Name__c.length() > 20){
                            packingLabelBatch.Country__c = sub.Recipient_Contact__r.Address__r.Country_Name__c.substring(0,19);
                        } else {
                            packingLabelBatch.Country__c = sub.Recipient_Contact__r.Address__r.Country_Name__c;
                        }
                    }
                    
                    if(subIdPublicationMap.containsKey(sub.id)){
                        if(subIdPublicationMap.get(sub.id).Earliest_Start_Date__c != null){
                            packingLabelBatch.Delivery_Date__c = subIdPublicationMap.get(sub.id).Earliest_Start_Date__c;
                            //Start UD-1980 and UD-1988 VPernicia: Change from Earliest_Start_Date__c to date today
                            packingLabelBatch.Issue_Date__c = date.today();//subIdPublicationMap.get(sub.id).Earliest_Start_Date__c;
                            //End UD-1980 and UD-1988 VPernicia: Change from Earliest_Start_Date__c to date today
                        }
                        if(subIdPublicationMap.get(sub.Id).Publication_Code__c != null){
                            packingLabelBatch.Publication_Code__c = subIdPublicationMap.get(sub.Id).Publication_Code__c;
                        }
                    }
                    
                    packingLabelBatch.POSTCODE__c = sub.Recipient_Contact__r.Address__r.Postal_Code__r.Name;
                    packingLabelBatch.ST_NAME__c = sub.Recipient_Contact__r.Address__r.Street_Name__c;
                    packingLabelBatch.Flight_Number_1__c = sub.Recipient_Contact__r.Address__r.Flight_Number_1__c;
                    packingLabelBatch.Flight_Number_2__c = sub.Recipient_Contact__r.Address__r.Flight_Number_2__c;   
                    packingLabelBatch.Level__c = sub.Recipient_Contact__r.Address__r.Level_Number__c;
                    packingLabelBatch.Mailing_Agent_Account_Number__c = sub.Vendor_1__r.AccountNumber;
                    packingLabelBatch.Number_of_Copies__c = sub.Number_of_Copies__c;                                                                
                    packingLabelBatch.Recipient_Name__c = sub.Recipient_Contact__r.Name;                    
                    packingLabelBatch.Recipient_Type__c = sub.Recipient_Contact__r.Address__r.RecordType.Name;
                    packingLabelBatch.Record_Type__c = sub.Recipient_Contact__r.Address__r.RecordType.Name;
                    packingLabelBatch.Recipient_Number__c = String.valueOf(sub.Recipient_Contact__r.Recipient_Number__c);
                    
                    if(sub.Recipient_Contact__r.Salutation != null){
                        if(sub.Recipient_Contact__r.Salutation.length() > 10){
                            packingLabelBatch.Salutation__c = sub.Recipient_Contact__r.Salutation.substring(0,9);
                        } else {
                            packingLabelBatch.Salutation__c = sub.Recipient_Contact__r.Salutation;
                        }
                    }
                    
                    //START UD-2914 10/27/2015 Added by Jason A. 
                    packingLabelBatch.Subscriber_Account_Name__c = string.valueof(sub.Zuora__Account__r.Name).left(50);
                    //END UD-2914 10/27/2015 Added by Jason A.
                    packingLabelBatch.Subscriber_Account_Number__c = sub.Zuora__Account__r.AccountNumber;
                    packingLabelBatch.Subscription__c = sub.id;                                     
                    packingLabelBatch.Unit__c = sub.Recipient_Contact__r.Address__r.Unit_Number__c;
                    //START D-3013 05/22/2015 Added By S.Puli
                    packingLabelBatch.Subscription_Type__c = sub.Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c;
                    //END D-3013 05/22/2015 Added By S.Puli
                                                    
                    packingLabelBatchList.add(packingLabelBatch);
                }
            }
        } catch(Exception e){
          system.debug('Error found!!!' + e);
        }
        //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery    
        try{
            insert packingLabelBatchList;
        } catch(Exception e){
            logger.logBatchFailure(e, subscriptionList, JSON.serialize(backupPubNextStartDate));
            isApexJobSuccessful = false;
        } finally{
            logger.save();
        }
    //END: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
    }
    
    //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
    global void finish(Database.BatchableContext BC) {
        
        //START: D-4267 1-13-2016 Added by Kristine Balaoing - added logging mechanism
        Logger loggerFinish; 
            
        if(!Test.isRunningTest()){
        loggerFinish = new Logger('SP_PackingLabelBatchRecordCreation', 'SP052');
        }
        
        try{
            if(!isApexJobSuccessful){
                BatchJobHelper.updateJobStatus(BC.getJobId(), false); 
            }else{
                BatchJobHelper.updateJobStatus(BC.getJobId(), true);
            }
        }catch(Exception e){
            loggerFinish.log(e);
            loggerFinish.save();
        }
        //END: D- 4267 1-13-2016 Added by Kristine Balaoing
    }
    //END: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
}