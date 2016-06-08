/**
    HISTORY 
    D-1189 1/22/2015 Alyana Navarro - Reconstructed the entire class 
    D-2013 3/20/2015 Alyana Navarro - Reconstructed the entire class
    **/
    public class PackingLabelsController_POC { 

        //START : D-3014 05/25/2015 S.Puli
        public Packing_Label_Batch__c PackagingLabel { get; set; }
       // public Publication__c Pub { get; set; }
        public Date DateToday{ get; set; }
        //public  Account { get; set; }
        public Zuora__Subscription__c Sub {get; set;}
        //public  Id RecipientAddressId  {get; set;}
        public Packing_Grp__c PackingGrp {get; set;}
        public string CountryCode { get; set; }
        public string CityCode { get; set; }
        public String Destination {get; set;}
        public String PackingCode {get; set;}
        public Country__C Country {get; set;}
        public City__c City {get; set;}
        public String pubCode {get; set;}
        public List<Zuora__SubscriptionProductCharge__c> spcList {get; set;}
        //Start  D-3017 Added by S.Puli
        public Map<string,Integer> pubCodesQtyMap {get; set;} 
        //End  D-3017 Added by S.Puli   
        public set<string> pubCodes {get; set;}
        //Start  D-3017 Added by S.Puli
        public list<Integer> quantity {get; set;}
        public Map<String, Integer> pubToPubCount_MAP {get; set;}
        //End  D-3017 Added by S.Puli
        public List<string> deliveryDates {get; set;}
        public string packingCodeCity{get; set;}    
        public string flightHeader{get; set;}    
        public string f1 {get; set;}    
        public string f2 {get; set;}    
        public string packingGrpDescription {get; set;}
        public String packingLabelId;
        
        public string addtype {get; set;}
        List<Zuora__Subscription__c> subscription_LIST {get; set;}
        public String overseasPubCode {get; set;}
        public String dateString {get; set;}
        public String recipientNumber {get; set;}
        public String numCopy {get; set;}
        //END : D-3014 05/25/2015 S.Puli
        
        //START : D-3015 05/25/2015 S.Puli
        public string magPubCode {get; set;}
        //END : D-3015 05/25/2015 S.Puli
        // START : UD-1839 7/14/2015 Alyana Navarro
        public String address1 {get; set;}
        public String address2 {get; set;}
        public String address3 {get; set;}
        public String address4 {get; set;}
        public String address5 {get; set;}
        // END : UD-1839 7/14/2015 Alyana Navarro
        //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
        public DateTime refDate {get; set;}
        //Start UD-2782 and UD-2783 VPernicia 09/18/15
        public Map<string,Integer> pubCodesSubQtyMap {get; set;} 
        public string subContactID {get; set;}  
        //End UD-2782 and UD-2783 VPernicia 09/18/15
        //START D-3529 Gdelrosario : added variable for VF page
        public String finalAddress {get;set;}
        //END D-3529 Gdelrosario : added variable for VF page
    //END: D-3672 11/13/2015 Added by Kristine Balaoing
        //START : D-3014 05/25/2015 S.Puli
        public void initializeOSW(){
            
            addtype = '';
            addtype = 'overseas';
            
            try{
                packingLabelsOverseasWrapController();
            } catch(Exception e){
            
            }
        }
        // START : UD-2962 10/29/2015 Alyana Navarro
        public Boolean isAirlineWrapper = false;
        public void initializeAirline(){
            isAirlineWrapper = true;
            addtype = '';
            addtype = 'airline';
            PackingLabelsControllerClass();
            getGeneralDetails();
            airlineReportHardCopy();
        }

        // END : UD-2962 10/29/2015 Alyana Navarro
        //END : D-3014 05/25/2015 S.Puli
        //START : D-3015 05/25/2015 S.Puli
        public void initializeMagazineWrap(){
        
            addtype = '';
            addtype = 'internal';
            try{
                packingLabelsMagazineWrapController();
            } catch(Exception e){
            
            }
        
        }
        //END : D-3015 05/25/2015 S.Puli
        //START : D-3014 05/25/2015 S.Puli
        public PackingLabelsController_POC () {
        
        }
        
        public void PackingLabelsControllerClass(){
        //END : D-3014 05/25/2015 S.Puli
            //START : D-3014 05/25/2015 S.Puli
        try{
            subscription_LIST = querySub(addtype,'both');
            //END : D-3014 05/25/2015 S.Puli
            DateToday = Date.Today();
            packingLabelId = ApexPages.currentPage().getParameters().get('id');
            //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
        //refDate = DateTime.valueOf(ApexPages.currentPage().getParameters().get('issueDate')); 
        refDate = system.today();
            //END: D-3672 11/13/2015 Added by Kristine Balaoing
        //Account acc = [Select Name, id from Account];

            //START : D-3014 05/25/2015 S.Puli
            PackagingLabel = [SELECT Delivery_Date__c, Subscription__c, Flight_Number_1__c, Flight_Number_2__c, Flight_Number_3__c, Account_Name__r.Name, Account_Name__r.AccountNumber, Address_1__c, Address_2__c, Address_3__c, Address_4__c, Building_Name__c, Copy_Type__c, Country__c, Issue_Date__c, Level__c, Mailing_Agent_Account_Number__c, Number_of_Copies__c, Publication_Code__c, Recipient_Name__c, Recipient_Number__c, Salutation__c, Subscriber_Account_Name__c, Subscriber_Account_Number__c, Subscription_Product_Charge__c, Subscription_Type__c, Unit__c, Record_Type__c, Recipient_Type__c
                       FROM Packing_Label_Batch__c 
                       WHERE Id = :packingLabelId];
            //END : D-3014 05/25/2015 S.Puli
                  
            /*** -- START: Destination -- ***/
            //START : D-3014 05/25/2015 S.Puli
            if(PackagingLabel.Subscription__c!=null && PackagingLabel.Recipient_Type__c == 'Airline') {
                //START : D-3017 06/04/2015 S.Puli
                Sub = [SELECT Recipient_Contact__r.Address__r.Flight_Number_1__c, Recipient_Contact__r.Address__r.Flight_Number_2__c, Recipient_Contact__r.Address__r.City__r.Name, Recipient_Contact__r.Address__r.City__c, Recipient_Contact__r.Address__r.Packing_Code__c, Recipient_Contact__r.Address__r.Country__r.Name,Frequency_1__c,Recipient_Contact__c, Recipient_Contact__r.Address__r.Country__r.Code__c
                FROM Zuora__Subscription__c 
                WHERE ID =: PackagingLabel.Subscription__c AND
                Recipient_Contact__r.Address__r.RecordTypeId =: ConstantsSLB.getKeyId('Address_Airline') 
                ];
                //END : D-3017 06/04/2015 S.Puli
            //END : D-3014 05/25/2015 S.Puli
                if (sub != null) { //Start/End D-3908 VPernicia 11/18/15: Remove the packing code condition
                
                    //Start UD-2782 and UD-2783 VPernicia 09/18/15
                    subContactID = Sub.Recipient_Contact__c;
                    //End UD-2782 and UD-2783 VPernicia 09/18/15
                    
                    //Start D-3908 VPernicia 11/18/15: Added the packing code condition
                    if (sub.Recipient_Contact__r.Address__r.Packing_Code__c != null) { 
                        PackingGrp = [SELECT Id, Packing_Group_Description__c, Packing_Code__c FROM Packing_Grp__c WHERE ID =: sub.Recipient_Contact__r.Address__r.Packing_Code__c ];
                        if (PackingGrp != null) {
                            PackingCode = PackingGrp.Packing_Code__c;
                            
                            //packing group description
                            if(PackingGrp.Packing_Group_Description__c != null){
                                packingGrpDescription = PackingGrp.Packing_Group_Description__c;
                            }
                            else{
                                System.debug('packing group description field is null');
                                //START : D-3017 06/04/2015 S.Puli
                                packingGrpDescription = '';
                                //END : D-3017 06/04/2015 S.Puli
                            }
                        }
                    } else {
                        System.debug('packing code field is null');
                        //START : D-3017 06/04/2015 S.Puli
                        packingCode = '';
                        //END : D-3017 06/04/2015 S.Puli
                    }
                    //End D-3908 VPernicia 11/18/15: Added the packing code condition
                    
                    //country
                    //START : D-3017 06/04/2015 S.Puli
                    Country = [SELECT Name, Code__c FROM Country__c WHERE Code__c =: sub.Recipient_Contact__r.Address__r.Country__r.Code__c Limit 1];
                    //END : D-3017 06/04/2015 S.Puli
                    if(Country!=null){
                            CountryCode = country.Code__c;
                    }
                    else{
                        System.debug('Country code field is null');
                        //START : D-3017 06/04/2015 S.Puli
                        countryCode = '';
                        //END : D-3017 06/04/2015 S.Puli
                    }
                    
                    //city
                    if(sub.Recipient_Contact__r.Address__r.City__c!=null){
                        City = [SELECT Id, Name from City__c where Name =: sub.Recipient_Contact__r.Address__r.City__r.Name];
                        cityCode=city.Name;
                    }
                    else{
                        System.debug('City field is null');
                        //START : D-3017 06/04/2015 S.Puli
                        cityCode='';
                        //END : D-3017 06/04/2015 S.Puli
                    }
                    
                    //flight1
                    if(sub.Recipient_Contact__r.Address__r.Flight_Number_1__c!=null){
                        f1=sub.Recipient_Contact__r.Address__r.Flight_Number_1__c;
                    }
                    else{
                        System.debug('Flight 1 is null');
                        //START : D-3017 06/04/2015 S.Puli
                        f1='';
                        //END : D-3017 06/04/2015 S.Puli
                    }
                    
                    //flight2
                    if(sub.Recipient_Contact__r.Address__r.Flight_Number_2__c!=null){
                        f2=sub.Recipient_Contact__r.Address__r.Flight_Number_2__c;
                    }
                    else{
                        System.debug('Flight 1 is null');
                        //START : D-3017 06/04/2015 S.Puli
                        f2='';
                        //END : D-3017 06/04/2015 S.Puli
                    }
                    
                    
                }
                else
                {
                    System.debug('recipient address has no packing code (packing grp object)');
                }
            }
            else{
                System.debug('Packaging Label Batch has no subscription');
            }
            
            if(packingCode != null && Country != null){
                destination = packingCode+'-'+countryCode;
            }
            
            if(packingCode != null && CityCode != null){
                packingCodeCity= packingCode+'-'+cityCode;
            } 
            
            if(f1!= null && f2!= null){
                flightHeader= f1+'-'+f2;
            }
            /*** -- END: Destination-- ***/
            
           //pubCode = sub.SPC__r.Product_Rate_Plan__r.PRPC__r.Publication_Code__c;
           
           /*** Start: pubcodes **/
           //START : D-3014 05/25/2015 S.Puli
           //Start D-3017 Added by S.Puli
            if(sub <> null){
            //Start UD-2133 VPernicia 09/02/15: Add Zuora__Subscription__r.Number_of_Copies__c 
                spcList= [SELECT Zuora__RatePlanName__c, Zuora__Quantity__c, PublicationCode__c, Zuora__Subscription__r.Number_of_Copies__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c =: sub.id];   
            }
            //End UD-2133 VPernicia 09/02/15: Add Zuora__Subscription__r.Number_of_Copies__c
            //END D-3017 Added by S.Puli
            //END : D-3014 05/25/2015 S.Puli
           
           string productRatePlan;
           List<zqu__ProductRatePlanCharge__c > ratePlanCharges = new List<zqu__ProductRatePlanCharge__c >();
           Map<string,double> ratePlanNameQuantityMap = new Map<string,double>();
           //Start D-3017 Added by S.Puli
           pubCodesQtyMap = new Map<string,Integer>();
           //End  D-3017 Added by S.Puli
           system.debug('before loop');
            //START : D-3014 05/25/2015 S.Puli
            if(spcList.size()>0){
               for (Zuora__SubscriptionProductCharge__c spc : spcList) {
                   system.debug(spc.Zuora__RatePlanName__c+','+spc.Zuora__Quantity__c);
                   //Start D-3017 Added by S.Puli
                   //Start UD-2133 VPernicia 09/02/15: Change condition to filter Zuora__Subscription__r.Number_of_Copies__c
                   if(spc.Zuora__Subscription__r.Number_of_Copies__c <> 0 && spc.Zuora__Subscription__r.Number_of_Copies__c <> null && spc.PublicationCode__c <> null){
                   //ratePlanNameQuantityMap.put(spc.Zuora__RatePlanName__c,spc.Zuora__Quantity__c);
                        pubCodesQtyMap.put(spc.PublicationCode__c,Integer.valueOf(spc.Zuora__Subscription__r.Number_of_Copies__c));
                    }
                   //End UD-2133 VPernicia 09/02/15: Change condition to filter Zuora__Subscription__r.Number_of_Copies__c
                   //END D-3017 Added by S.Puli
                }
            }
            
            //END : D-3014 05/25/2015 S.Puli
           //system.debug('after loop ratePlanNameQuantity size: ' + string.valueof(ratePlanNameQuantityMap.size()));
            //Start D-3017 Added by S.Puli
           /**for (string rtn : ratePlanNameQuantityMap.keyset()) {
               ratePlanCharges = [SELECT zqu__ProductRatePlan__r.Name, PublicationCode__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__r.Name IN : ratePlanNameQuantityMap.keyset()];
               
               for (zqu__ProductRatePlanCharge__c rpc : ratePlanCharges ) {
                   //Start  D-3017 Added by S.Puli
                    if(rpc.PublicationCode__c <> null){
                        Integer qty = Integer.valueOf(ratePlanNameQuantityMap.get(rtn));
                        //qty.substringafter('.');
                        if(qty <> 0 && qty <> null){
                            pubCodesQtyMap.put(rpc.PublicationCode__c,qty);
                        }
                    } 
                    //end  D-3017 Added by S.Puli
               }
           }**/
            //END D-3017 Added by S.Puli
            system.debug(pubCodesQtyMap.keyset());
            //START : D-3017 06/04/2015 S.Puli
            if(Sub<>null){
                pubcodes = new Set<String>();
                quantity = new list<Integer>();
                List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();
                subscriptionList.add(Sub);
                Map<id, Set<String>> subIdPubCodeSetMap = new Map<id, Set<String>>();
                subIdPubCodeSetMap.put(Sub.Id, pubCodesQtyMap.keyset());
                Map<Id, Map<String, Integer>> pubToCount_MAP = new Map<Id, Map<String, Integer>>();             
            pubToCount_MAP = getPublication(subscriptionList, subIdPubCodeSetMap);          
                pubToPubCount_MAP = new Map<String, Integer>();
                    for(String pub : pubCodesQtyMap.keyset()){
                        //Start UD-2137 VPernicia 08/24/15
                        if (pubToCount_MAP.get(Sub.Recipient_Contact__c).get(pub) > 0) {
                            pubcodes.add(pub);
                            quantity.add(pubToCount_MAP.get(Sub.Recipient_Contact__c).get(pub));
                            pubToPubCount_MAP = pubToCount_MAP.get(Sub.Recipient_Contact__c);
                        }
                        //End UD-2137 VPernicia 08/24/15
                    }
                system.debug(pubcodes + '>>>'+quantity);
            }
            //END : D-3017 06/04/2015 S.Puli
           /*** End: pubcodes **/ 
           
           /**Start: dates**/
           deliveryDates = new List<String>();
       //START: D-3672 11/13/2015 Added by Kristine Balaoing - removed for batch recovery     
       DateTime dT = refDate;
       //END: D-3672 11/13/2015 Added by Kristine Balaoing
           //Start  D-3017 Added by S.Puli
           String dDate = '';
           String date_DAY='';
           String date_MONTH='';
           String date_YEAR='';
           if(string.valueOf(dT.day()).length()==1){
                date_DAY = '0'+string.valueOf(dT.day())+'.';
           } else{
                date_DAY = string.valueOf(dT.day())+'.';
           }
           if(string.valueOf(dT.month()).length()==1){
                date_MONTH = '0'+string.valueOf(dT.month())+'.';
           } else{
                date_MONTH =string.valueOf(dT.month())+'.';
           }
                date_YEAR = string.valueOf(dT.year());
            dDate= date_DAY + date_MONTH + date_YEAR;

           for(String p: pubcodes ){
               deliveryDates.add(dDate);
           }
           //End  D-3017 Added by S.Puli
           /**End: dates**/

           }
           catch(Exception e)
           {
           system.debug(e.getmessage());
           //destination = sub.Recipient_Contact__r.Address__r.Country__r.Name;
           }
            
        } 
        
        public List<Zuora__Subscription__c> querySub(string addressRecType, string publicationType){
            //START : D-3014 05/25/2015 S.Puli
            string adRecTypeId = '';
            //END : D-3014 05/25/2015 S.Puli
            if(addressRecType=='local'){
                adRecTypeId= constantsslb.getkeyid('Address_Local');
            }
            else if(addressRecType=='internal'){
                adRecTypeId= constantsslb.getkeyid('Address_Internal');
            }
            else if(addressRecType=='airline'){
                adRecTypeId= constantsslb.getkeyid('Address_Airline');
            }
            else if(addressRecType=='overseas'){
                adRecTypeId= constantsslb.getkeyid('Address_Overseas');
            }
            
            string qry = 'SELECT Recipient_Contact__r.Address__r.Flight_Number_1__c, '
                    +   'Recipient_Contact__r.Address__r.Flight_Number_2__c, '
                    +   'Recipient_Contact__r.Address__r.City__r.Name, '
                    +   'Recipient_Contact__r.Address__r.City__c, '
                    +   'Recipient_Contact__r.Address__r.Packing_Code__c, '
                    +   'Recipient_Contact__r.Address__r.Country__r.Name '
                    +   'FROM Zuora__Subscription__c WHERE '
                    +   'Recipient_Contact__r.Address__r.RecordTypeId = \'' + adRecTypeId +'\'' ;

            List<Zuora__Subscription__c> results = database.query(qry);
            system.debug('results:' + results);
            return results;
        }
            
        // START : D-2013 3/19/2015 Alyana Navarro      
        public Packing_Label_Batch__c packingLabelBatch = new Packing_Label_Batch__c();
        public Account subscriberAccount = new Account();
        public Set<String> pubCodeSet {get; set;}
        public Set<String> pubCodeSet2 {get; set;} // Start/End UD-2137 VPernicia 08/24/15
        public Map<Id, String> recIdRecName {get; set;}
        public Map<String, Integer> pubTotalMap {get; set;}
        public Map<String, List<Id>> destinationRecipientIdMap {get; set;}
        public Map<Id, Map<String, Integer>> recIdPubCodeQuanMapMap {get; set;}
        public Map<String, Map<String, Integer>> destinationPubCodeTotalQuanMap {get; set;}
        
        public String subAccountName {get; set;}
        
        public void getGeneralDetails(){
            packingLabelBatch = [SELECT id, name, Subscriber_Account_Number__c FROM Packing_Label_Batch__c WHERE id =: packingLabelId];
            subscriberAccount = [SELECT id, name FROM Account WHERE AccountNumber =: packingLabelBatch.Subscriber_Account_Number__c];
            
            subAccountName = subscriberAccount.name.toUpperCase();
        }
        
        public List<String> sortedDestination {get; set;} // START-END : UD-2962 10/30/2015 Alyana Navarro
        
        public void airlineReportHardCopy(){
            try {
                subAccountName = ''; // START-END : UD-2962 10/29/2015 Alyana Navarro
                //START : D-3014 05/25/2015 S.Puli
                //initializeAirline(); // START-END : UD-2962 10/29/2015 Alyana Navarro
                //END : D-3014 05/25/2015 S.Puli
                //getGeneralDetails(); // START-END : UD-2962 10/29/2015 Alyana Navarro
                recIdRecName = new Map<Id, String>();
                destinationRecipientIdMap = new Map<String, List<Id>>();        
                String addRecordTypeId = ConstantsSLB.getKeyId('Address_Airline');
                Set<Id> airlineSubIdSet = new Set<Id>();
                Set<Id> recipientContactSet = new Set<Id>();
                List<Zuora__Subscription__c> airlineSubList = new List<Zuora__Subscription__c>();
                List<Zuora__SubscriptionProductCharge__c> subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();
                List<Contact> recipientContactList = new List<Contact>();
                Map<Id, Set<String>> airlineSubIdPubCodeSetMap = new Map<Id, Set<String>>();
                Map<Id, Zuora__Subscription__c> subscriptionMap = new Map<Id, Zuora__Subscription__c>();
                Map<String, List<String>> recipientNamePubCodeListMap = new Map<String, List<String>>();
                Map<String, Map<String, Integer>> recipientNamePubCodeQuanMapMap = new Map<String, Map<String, Integer>>();

                //Start UD-2782 and UD-2783 VPernicia 08/18/15
                pubCodesSubQtyMap = new Map<string,Integer>();
                //Start UD-2782 and UD-2783 VPernicia 08/18/15
                //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
                //START UD-2137 05-Oct-2015 Added By S.Puli - filter active subscriptions only
                
        //refDate = DateTime.valueOf(ApexPages.currentPage().getParameters().get('issueDate')); 
        refDate = system.today();
                Date refIssueDate = Date.newInstance(refDate.year(), refDate.month(), refDate.day());
                
        // START : UD-2962 10/29/2015 Alyana Navarro
                Set<Id> subscriptionIdSet = new Set<Id>();
                
                if(!isAirlineWrapper){
                    Account mailingAgentAccount = [SELECT id, name, AccountNumber FROM Account WHERE id =: ApexPages.currentPage().getParameters().get('id')];
                    
                    for(Packing_Label_Batch__c packingLabel : [SELECT id, name, subscription__c FROM Packing_Label_Batch__c WHERE Mailing_Agent_Account_Number__c =: mailingAgentAccount.AccountNumber AND subscription__r.Zuora__Account__r.RecordType.Name = 'Direct Corporate' AND subscription__r.Zuora__Account__r.Airline_Indicator__c = true AND subscription__r.Recipient_Contact__r.Address__r.RecordType.Name = 'Airline' AND Issue_Date__c =:refIssueDate]){                  
                        if(packingLabel.subscription__c != null){
                            subscriptionIdSet.add(packingLabel.subscription__c);
                        }
                    }
                    
                    airlineSubList = [SELECT id, name, Recipient_Contact__r.Name, Recipient_Contact__c, Frequency_1__c,Zuora__SubscriptionStartDate__c,
                                      Zuora__SubscriptionEndDate__c
                                      FROM Zuora__Subscription__c 
                                      WHERE subscription_type__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
                                            AND Recipient_Contact__r.Address__r.RecordTypeId =: addRecordTypeId 
                                            AND Zuora__SubscriptionStartDate__c <= :refIssueDate AND (Zuora__SubscriptionEndDate__c >= :refIssueDate or Zuora__SubscriptionEndDate__c = null)
                                            AND Order_Line_Item_Number_1__r.Main_Package_Product_Sub_Type__c =: GlobalVariableClass.ZPRODUCTSUBTYPE_NEWSPAPER
                                            AND Id IN: subscriptionIdSet];
                } else {
                    airlineSubList = [SELECT id, name, Recipient_Contact__r.Name, Recipient_Contact__c, Frequency_1__c,Zuora__SubscriptionStartDate__c,
                                      Zuora__SubscriptionEndDate__c
                                      FROM Zuora__Subscription__c 
                                      WHERE subscription_type__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
                                            AND Recipient_Contact__r.Address__r.RecordTypeId =: addRecordTypeId 
                                            AND Zuora__SubscriptionStartDate__c <= :refIssueDate AND (Zuora__SubscriptionEndDate__c >= :refIssueDate or Zuora__SubscriptionEndDate__c = null)                                     
                                            AND Zuora__Account__r.AccountNumber =: packingLabelBatch.Subscriber_Account_Number__c]; 
                }
                                        //AND Zuora__Account__r.AccountNumber =: packingLabelBatch.Subscriber_Account_Number__c];
                // END : UD-2962 10/29/2015 Alyana Navarro
                //END UD-2137 05-Oct-2015 Added By S.Puli                       
                //END: D-3672 11/13/2015 Added by Kristine Balaoing
                for(Zuora__Subscription__c sub : airlineSubList){
                    airlineSubIdSet.add(sub.id);
                    subscriptionMap.put(sub.id, sub);
                    recipientContactSet.add(sub.Recipient_Contact__c); 
                }
                
                // START : D-2591 3/25/2015 Alyana Navarro - Change query of Country Code.
                //Start UD-2133 VPernicia: Add Address__r.City__r.Name
                recipientContactList = [SELECT id, name, Address__r.Packing_Code__r.Packing_Code__c, Address__r.City__r.Country__r.Code__c, Address__r.City__r.Name 
                                        FROM Contact 
                                        WHERE Id IN: recipientContactSet];                                                                  
                //End UD-2133 VPernicia: Add Address__r.City__r.Name
                
                // START : UD-2962 10/30/2015 Alyana Navarro
                sortedDestination = new List<String>();
                Set<String> destinationSet = new Set<String>();
                // END : UD-2962 10/30/2015 Alyana Navarro
                
                for(Contact con : recipientContactList){
                    recIdRecName.put(con.id, con.Name);
                    // START : D-3016 5/29/2015 SPuli - Hotfix
                    String destination = '-';
                    if(con.Address__r.Packing_Code__r.Packing_Code__c != null){
                        destination = con.Address__r.Packing_Code__r.Packing_Code__c + '-';                 
                    } else {
                        destination = '';
                    }
                    
                    if(con.Address__r.City__r.Name != null){ //Start/End UD-2133 VPernicia: Change to Address__r.City__r.Name
                        destination += con.Address__r.City__r.Name; //Start/End UD-2133 VPernicia: Change to Address__r.City__r.Name
                    } else if(con.Address__r.Packing_Code__r.Packing_Code__c != null){
                        destination = packingCode.substring(0, packingCode.length());
                    }                               
                    // END : D-3016 5/29/2015 SPuli - Hotfix
                    
                    destinationSet.add(destination); // START-END : UD-2962 10/30/2015 Alyana Navarro
                    
                    if(destinationRecipientIdMap.containsKey(destination)){
                        destinationRecipientIdMap.get(destination).add(con.id);
                    } else {
                        destinationRecipientIdMap.put(destination, new List<Id>{con.id});
                    }
                }
                // START : UD-2962 10/30/2015 Alyana Navarro
                sortedDestination.addAll(destinationSet);
                sortedDestination.sort();
                // END : UD-2962 10/30/2015 Alyana Navarro
                
                // END : D-2591 3/25/2015 Alyana Navarro             
                // START : D-3016 5/29/2015 SPuli - Hotfix
                Set<String> UOMs = new Set <String>();
                UOMs.add(GlobalVariableClass.DUMMY_CHARGE);
                
                //Start UD-2782 and UD-2783 VPernicia 08/18/15: Add Number_of_Copies__c
                subProdChargeList = [SELECT id, name, PublicationCode__c, Zuora__Subscription__c,Zuora__UOM__c, Zuora__Subscription__r.Number_of_Copies__c
                                     FROM Zuora__SubscriptionProductCharge__c 
                                     WHERE Zuora__Subscription__c IN: airlineSubIdSet AND Zuora__UOM__c NOT IN :UOMs AND (Zuora__UOM__c <> null OR Zuora__UOM__c <> '')];            //End UD-2782 and UD-2783 VPernicia 08/18/15: Add Number_of_Copies__c
                // END : D-3016 5/29/2015 SPuli - Hotfix
                for(Zuora__SubscriptionProductCharge__c subProdCharge : subProdChargeList){ //Vonski
                    if(subProdCharge.PublicationCode__c != null){
                        if(airlineSubIdPubCodeSetMap.containsKey(subProdCharge.Zuora__Subscription__c)){
                            airlineSubIdPubCodeSetMap.get(subProdCharge.Zuora__Subscription__c).add(subProdCharge.PublicationCode__c);
                        } else {
                            airlineSubIdPubCodeSetMap.put(subProdCharge.Zuora__Subscription__c, new Set<String>{subProdCharge.PublicationCode__c});
                        }
                    }
                    
                    //Start UD-2782 and UD-2783 VPernicia 08/18/15: To pull subscription quantity
                    pubCodesSubQtyMap.put(subProdCharge.Zuora__Subscription__c + subProdCharge.PublicationCode__c, Integer.valueOf(subProdCharge.Zuora__Subscription__r.Number_of_Copies__c));
                    //End UD-2782 and UD-2783 VPernicia 08/18/15: To pull subscription quantity
                }                   
                //Start D-3908 VPernicia 11/18/15: Check if subContactID is null to prevent Map key null not found in map
                //if (subContactID != null) {
                    recIdPubCodeQuanMapMap = getPublication(airlineSubList, airlineSubIdPubCodeSetMap);
                //}
                //End D-3908 VPernicia 11/18/15: Check if subContactID is null to prevent Map key null not found in map
                getTotalPublications();
            } catch(Exception e){
                system.debug('Error in generating Report Hard Copy PDF');
            }
        }
        
        public void getTotalPublications(){
            destinationPubCodeTotalQuanMap = new Map<String, Map<String, Integer>>();
            pubTotalMap = new Map<String, Integer>();
            
            for(String pubCode : pubCodeSet){
                Integer total = 0;
                for(String destination : destinationRecipientIdMap.keySet()){
                    Integer subTotalPub = 0;
                    for(Id recId : destinationRecipientIdMap.get(destination)){
                        // START : D-3016 5/29/2015 SPuli - Hotfix
                        if(recIdPubCodeQuanMapMap.containsKey(recId) && recIdPubCodeQuanMapMap.get(recId)<> null){
                            if(recIdPubCodeQuanMapMap.get(recId).containsKey(pubCode)){                                       
                                subTotalPub += recIdPubCodeQuanMapMap.get(recId).get(pubCode);
                                total += recIdPubCodeQuanMapMap.get(recId).get(pubCode);                        
                                if(destinationPubCodeTotalQuanMap.containsKey(destination)){
                                    //REMOVE if(destinationPubCodeTotalQuanMap.get(destination).containsKey(pubCode)){
                                        destinationPubCodeTotalQuanMap.get(destination).put(pubCode, subTotalPub);
                                    //REMOVE } else {
                                    //REMOVE    destinationPubCodeTotalQuanMap.get(destination).put(pubCode, subTotalPub); // START-END : D-2591 3/25/2015 Alyana Navarro - Change value of Map from subTotalPub to 0.
                                    //REMOVE }
                                } else {
                                    destinationPubCodeTotalQuanMap.put(destination, new Map<String, Integer>{pubCode => subTotalPub});
                                }
                                
                                pubTotalMap.put(pubCode, total);
                            }
                        } else{
                            destinationRecipientIdMap.remove(destination);
                        }
                        // END : D-3016 5/29/2015 SPuli - Hotfix
                    }               
                }                       
            }                               
        }
        
        public Map<Id, Map<String, Integer>> getPublication(List<Zuora__Subscription__c> subscriptionList, Map<id, Set<String>> subIdPubCodeSetMap){
            Boolean isPublished = false;
            pubCodeSet = new Set<String>();
            pubCodeSet2 = new Set<String>(); // Start/End UD-2137 VPernicia 08/24/15
            Set<String> newPubCodeSet = new Set<String>();        
            List<Publication__c> publicationList = new List<Publication__c>();
            List<String> publishedDays;
            List<String> subFrequency;
            Map<String, List<String>> pubCodePubDaysListMap = new Map<String, List<String>>();
            Map<Id, Map<String, Integer>> recipientIdPubCodeQuanMapMap = new Map<Id, Map<String, Integer>>();
            Map<Id, List<String>> subIdSubFreqListMap = new Map<Id, List<String>>();
            Map<String, Integer> dayOfWeekMap = new Map<String, Integer>{'Mon'=>0,'Tue'=>1,'Wed'=>2,'Thu'=>3,'Fri'=>4,'Sat'=>5,'Sun'=>6};
            //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
        String dayOfWeek = (refDate).format('EEE');
            //END: D-3672 11/13/2015 Added by Kristine Balaoing
        
            for(Id subId : subIdPubCodeSetMap.keySet()){
                pubCodeSet.addAll(subIdPubCodeSetMap.get(subId));
            }
            
            //Start UD-2782 and UD-2783 VPernicia 09/16/15: Added new filter Platform_Type__c =: GlobalVariableClass.PLATFORM_PRINT
            publicationList = [SELECT id, name, Published_Days__c, Publication_Code__c FROM Publication__c WHERE Publication_Code__c IN: pubCodeSet and Platform_Type__c =: GlobalVariableClass.PLATFORM_PRINT];
            //End UD-2782 and UD-2783 VPernicia 09/16/15: Added new filter Platform_Type__c =: GlobalVariableClass.PLATFORM_PRINT
            
            for(Publication__c pub : publicationList){
                publishedDays = new List<String>();
                publishedDays = pub.Published_Days__c.split(''); 
                publishedDays.remove(0);
                pubCodePubDaysListMap.put(pub.Publication_Code__c, publishedDays);
            }
            
            for(Zuora__Subscription__c sub : subscriptionList){
                if(sub.Frequency_1__c == GlobalVariableClass.FREQUENCY_MONFRI){
                    subFrequency = new List<String>{'Y','Y','Y','Y','Y','N','N'};
                } else if(sub.Frequency_1__c == GlobalVariableClass.FREQUENCY_FRISUN){
                    subFrequency = new List<String>{'N','N','N','N','Y','Y','Y'};
                } else if(sub.Frequency_1__c == GlobalVariableClass.FREQUENCY_SATSUN){
                    subFrequency = new List<String>{'N','N','N','N','N','Y','Y'};
                } else if(sub.Frequency_1__c == 'Mon-Sat'){
                    subFrequency = new List<String>{'Y','Y','Y','Y','Y','Y','N'};
                } else if(sub.Frequency_1__c == GlobalVariableClass.FREQUENCY_DEFAULT){
                    subFrequency = null;
                }
                
                subIdSubFreqListMap.put(sub.id, subFrequency);
            }
            
            Integer counter = 0;
            Integer innerCounter = 0;
            for(Zuora__Subscription__c sub : subscriptionList){
                counter++;
                if(subIdPubCodeSetMap.containsKey(sub.id)){
                    for(String pubCode : subIdPubCodeSetMap.get(sub.id)){
                        innerCounter++;
                        if(pubCodePubDaysListMap.containsKey(pubCode)){
                            if(subIdSubFreqListMap.containsKey(sub.id)){
                                List<String> pubDays = pubCodePubDaysListMap.get(pubCode);
                                List<String> subFreq = new List<String>();
                                
                                if(subIdSubFreqListMap.get(sub.id) != null){
                                    subFreq = subIdSubFreqListMap.get(sub.id);  
                                } else {
                                    subFreq = pubDays;
                                }
                                
                                if(pubDays[dayOfWeekMap.get(dayOfWeek)] == 'Y' && subFreq[dayOfWeekMap.get(dayOfWeek)] == 'Y'){                             
                                    if(recipientIdPubCodeQuanMapMap.containsKey(sub.Recipient_Contact__c)){
                                        if(recipientIdPubCodeQuanMapMap.get(sub.Recipient_Contact__c).containsKey(pubCode)){
                                            Integer total = recipientIdPubCodeQuanMapMap.get(sub.Recipient_Contact__c).get(pubCode) + Integer.valueof(pubCodesSubQtyMap.get(sub.id + pubCode));
                                            recipientIdPubCodeQuanMapMap.get(sub.Recipient_Contact__c).put(pubCode, total);
                                        } else {
                                            recipientIdPubCodeQuanMapMap.get(sub.Recipient_Contact__c).put(pubCode, pubCodesSubQtyMap.get(sub.id + pubCode));
                                        }
                                        
                                    } else {
                                        recipientIdPubCodeQuanMapMap.put(sub.Recipient_Contact__c, new Map<String, Integer>{pubCode => pubCodesSubQtyMap.get(sub.id + pubCode)});
                                        
                                    }
                                    pubCodeSet2.add(pubCode); // Start/End UD-2137 VPernicia 08/24/15
                                } else {
                                    if(recipientIdPubCodeQuanMapMap.containsKey(sub.Recipient_Contact__c)){                                 
                                        recipientIdPubCodeQuanMapMap.get(sub.Recipient_Contact__c).put(pubCode, 0);                                 
                                    } else {
                                        recipientIdPubCodeQuanMapMap.put(sub.Recipient_Contact__c, new Map<String, Integer>{pubCode => 0});
                                    }
                                }
                            }
                        }
                    }
                }
            }           
            
            for(String pub : pubCodeSet){
                for(Id key : recipientIdPubCodeQuanMapMap.keySet()){                
                    if(!recipientIdPubCodeQuanMapMap.get(key).containsKey(pub)){
                        recipientIdPubCodeQuanMapMap.get(key).put(pub, 0);
                    }               
                }
            }
            return recipientIdPubCodeQuanMapMap;
        }       
        //START : D-3014 05/25/2015 S.Puli
        /**
        Added By: Sherwin Puli
        Description: Method that will fetch data for visualforce page:OverseasWrapper
        **/
        public void packingLabelsOverseasWrapController(){
            //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
         packingLabelId = ApexPages.currentPage().getParameters().get('id');
         //refDate = DateTime.valueOf(ApexPages.currentPage().getParameters().get('issueDate')); 
         refDate = system.today();
         //END: D-3672 11/13/2015 Added by Kristine Balaoing
        overseasPubCode = '';
            recipientNumber = '';
            numCopy = '';
            
            String dMonth = '';
            String dDateToday = '';
            String dYear = '';
            
            //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
            if(String.valueof(refDate.MONTH()).length()<2){
                dMonth = '0'+refDate.MONTH()+'.';
            } else{
                dMonth = refDate.MONTH()+'.';
            }
            if(String.valueOf(refDate.DAY()).length()<2){
                dDateToday = '0'+refDate.DAY()+'.';
            } else{
                dDateToday = refDate.DAY()+'.';
            }
            dYear = String.valueOf(refDate.YEAR());
            dateString = dDateToday+dMonth+dYear;
        //END: D-3672 11/13/2015 Added by Kristine Balaoing
        //START : D-3015 05/25/2015 S.Puli         
            PackagingLabel = [SELECT Delivery_Date__c, Subscription__c, Flight_Number_1__c, Flight_Number_2__c, Flight_Number_3__c, Account_Name__r.Name, Account_Name__r.AccountNumber, Address_1__c, Address_2__c, Address_3__c, Address_4__c, Building_Name__c, Copy_Type__c, Country__c, Issue_Date__c, Level__c, Mailing_Agent_Account_Number__c, Number_of_Copies__c, Publication_Code__c, Recipient_Name__c, Recipient_Number__c, Salutation__c, Subscriber_Account_Name__c, Subscriber_Account_Number__c, Subscription_Product_Charge__c, Subscription_Type__c, Unit__c, Record_Type__c, Recipient_Type__c, Subscription__r.Recipient_Contact__r.Recipient_Number__c, Subscription__r.Recipient_Contact__r.Zone__c, Subscription__r.Vendor_1__r.Name
                       FROM Packing_Label_Batch__c 
                       WHERE Id = :packingLabelId];
            //START D-3529 Gdelrosario 14/10/2015: added to get the subscription to get value from reciepeint
                       //START D-3722 Gdelrosario 23/10/2015: added to query
             Sub = [SELECT Id, Name, Recipient_Contact__c, Recipient_Contact__r.ID, 
                             Recipient_Contact__r.Address__r.recordType.developerName,
                             Recipient_Contact__r.Address__r.Block_House_Number__c,
                             Recipient_Contact__r.Address__r.Street_Name__c,
                             Recipient_Contact__r.Address__r.Level_Number__c,
                             Recipient_Contact__r.Address__r.Unit_Number__c,
                             Recipient_Contact__r.Address__r.Building_Name__c,
                             Recipient_Contact__r.Address__r.Country__r.Country_Name__c,
                             Recipient_Contact__r.Address__r.Country__r.Code__c,
                             Recipient_Contact__r.Address__r.Country__r.Name,
                             Recipient_Contact__r.Address__r.Postal_Code__r.Name,
                             Recipient_Contact__r.Address__r.Address_1__c,
                             Recipient_Contact__r.Address__r.Address_2__c,
                             Recipient_Contact__r.Address__r.Address_3__c,
                             Recipient_Contact__r.Address__r.Address_4__c,
                             Recipient_Contact__r.Address__r.Section_Code__r.Section_Name__c,
                             Recipient_Contact__r.Address__r.Department__r.Department_Name__c,
                             Recipient_Contact__r.Address__r.Division_Code__r.Name,
                             Recipient_Contact__r.Address__r.Company_Code__r.Company_Name__c,
                             Recipient_Contact__r.Address__r.Location_Code__r.Location_Name__c,
                             Recipient_Contact__r.Address__r.Section_Code__r.Name,
                             Recipient_Contact__r.Address__r.Department__r.Name,
                             Recipient_Contact__r.Address__r.Company_Code__r.Name,
                             Recipient_Contact__r.Address__r.Location_Code__r.Name,
                             Recipient_Contact__r.Address__r.City__c,
                             Recipient_Contact__r.Address__r.City__r.Name,
                             Recipient_Contact__r.Address__r.City__r.City_Name__c,
                             Recipient_Contact__r.Address__r.Airline_Number__c,
                             Recipient_Contact__r.Address__r.Flight_Number_1__c,
                             Recipient_Contact__r.Address__r.Flight_Number_2__c,
                             Recipient_Contact__r.Address__r.Packing_Code__c,
                             Frequency_1__c
                    FROM Zuora__Subscription__c 
                    WHERE ID =: PackagingLabel.Subscription__c];

            finalAddress = AddressHelper.formatAddress(Sub.Recipient_Contact__r, false, true);
            //END D-3722 Gdelrosario 23/10/2015: added to query
            //END D-3529 Gdelrosario 14/10/2015 : added to get the subscription to get value from reciepeint
            if(PackagingLabel.Subscription__r.Recipient_Contact__r.Recipient_Number__c<>null){
                recipientNumber = String.valueOf(PackagingLabel.Subscription__r.Recipient_Contact__r.Recipient_Number__c);
        //END : D-3015 05/25/2015 S.Puli
            }
            
            numCopy += '/ '+PackagingLabel.Number_of_Copies__c+ ' ';
            numCopy += PackagingLabel.Subscription__r.Vendor_1__r.Name+' ';
            //if(){ 
                numCopy += 'A';
            //} else if(){
            //  numCopy += 'S';
            //}
            numCopy += '/ '+PackagingLabel.Subscription__r.Recipient_Contact__r.Zone__c;
            
            List<Zuora__SubscriptionProductCharge__c> overseasSpcList = new List<Zuora__SubscriptionProductCharge__c>();
            if(PackagingLabel.Subscription__c <> null){
                overseasSpcList = [Select Id, Name, PublicationCode__c, Zuora__Subscription__c From Zuora__SubscriptionProductCharge__c Where Zuora__Subscription__c = :PackagingLabel.Subscription__c];
            }
                
            if(overseasSpcList.size()>0){
                for(Zuora__SubscriptionProductCharge__c zSpc : overseasSpcList){
                    
                    if(zSpc.PublicationCode__c == 'BH'){
                        overseasPubCode = zSpc.PublicationCode__c;
                    }
                    if(zSpc.PublicationCode__c == 'WB'){
                        overseasPubCode = zSpc.PublicationCode__c;
                    }
                    if(zSpc.PublicationCode__c == 'ZB'){
                        overseasPubCode = zSpc.PublicationCode__c;
                    }
                    if(zSpc.PublicationCode__c == 'TM'){
                        overseasPubCode = zSpc.PublicationCode__c;
                    }
                    if(zSpc.PublicationCode__c == 'BT'){
                        overseasPubCode = zSpc.PublicationCode__c;
                    }
                    if(zSpc.PublicationCode__c == 'ST'){
                        overseasPubCode = zSpc.PublicationCode__c;
                    }
                    if(zSpc.PublicationCode__c == 'NP'){
                        overseasPubCode = zSpc.PublicationCode__c;
                    }
                    if(zSpc.PublicationCode__c == 'MY'){
                        overseasPubCode = zSpc.PublicationCode__c;
                    }
                    if(zSpc.PublicationCode__c == 'SM'){
                        overseasPubCode = zSpc.PublicationCode__c;
                    }   
                
                }       
            }
        
        
        }
        //END : D-3014 05/25/2015 S.Puli
        
        //START : D-3015 05/25/2015 S.Puli
        /**
        Added By: Sherwin Puli
        Description: Method that will fetch data for visualforce page:MagazineInternalWrapper
        **/
        public void packingLabelsMagazineWrapController(){
            
            // START : UD-1839 7/14/2015 Alyana Navarro
            Zuora__Subscription__c subscription = new Zuora__Subscription__c();
            // END : UD-1839 7/14/2015 Alyana Navarro
            //subscription_LIST = querySub(addtype,'both');
            //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
            packingLabelId = ApexPages.currentPage().getParameters().get('id');
            //refDate = DateTime.valueOf(ApexPages.currentPage().getParameters().get('issueDate'));
            refDate = system.today();
            magPubCode = '';
            
            String dMonth = '';
            String dDateToday = '';
            String dYear = '';
          
            
            if(String.valueof(refDate.MONTH()).length()<2){
                dMonth = '0'+refDate.MONTH()+'.';
            } else{
                dMonth = refDate.MONTH()+'.';
            }
            if(String.valueOf(refDate.DAY()).length()<2){
                dDateToday = '0'+refDate.DAY()+'.';
            } else{
                dDateToday = refDate.DAY()+'.';
            }
            dYear = String.valueOf(refDate.YEAR());
            dateString = dDateToday+dMonth+dYear;
        //END: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
            // START : UD-1839 7/14/2015 Alyana Navarro/S.Puli
            //START D-3529 Gdelrosario 14/10/2015: added to get the subscription to get value from reciepeint/ added query
            //START D-3722 Gdelrosario 23/10/2015: added to query
            // START : UD-2914 10/26/2015 Added by Jason A
            //START UD-3201 16-Nov-2015 Added By S.Puli
            PackagingLabel = [SELECT Delivery_Date__c, Subscription__c, Flight_Number_1__c, Flight_Number_2__c, Flight_Number_3__c, Account_Name__r.Name, Account_Name__r.AccountNumber, Address_1__c, Address_2__c, Address_3__c, Address_4__c,Address_5__c, Building_Name__c, Copy_Type__c, Country__c, Issue_Date__c, Level__c, Mailing_Agent_Account_Number__c, Number_of_Copies__c, Publication_Code__c, Recipient_Name__c, Recipient_Number__c, Salutation__c, Subscriber_Account_Name__c, Subscriber_Account_Number__c, Subscription_Product_Charge__c, Subscription_Type__c, Unit__c, Record_Type__c, Recipient_Type__c, Subscription__r.Recipient_Contact__r.Recipient_Number__c, Subscription__r.Recipient_Contact__r.Zone__c, Subscription__r.Main_Package_1__c, Subscription__r.Recipient_Contact__r.Address__r.Block_House_Number__c, Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Street_Name__c, Subscription__r.Recipient_Contact__r.Address__r.Level_Number__c, Subscription__r.Recipient_Contact__r.Address__r.Unit_Number__c, Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Building_Name__c, Subscription__r.Recipient_Contact__r.Address__r.Country__r.Country_Name__c, Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name, Subscription__r.Recipient_Contact__r.Address__r.RecordType.Id, 
                                     Subscription__r.Recipient_Contact__r.ID,
                                     Subscription__r.Recipient_Contact__r.Address__r.recordType.developerName,
                                     //Subscription__r.Recipient_Contact__r.Address__r.Block_House_Number__c,
                                     Subscription__r.Recipient_Contact__r.Address__r.Street_Name__c,
                                     //Subscription__r.Recipient_Contact__r.Address__r.Level_Number__c,
                                     //Subscription__r.Recipient_Contact__r.Address__r.Unit_Number__c,
                                     Subscription__r.Recipient_Contact__r.Address__r.Building_Name__c,
                                     //Subscription__r.Recipient_Contact__r.Address__r.Country__r.Country_Name__c,
                                     Subscription__r.Recipient_Contact__r.Address__r.Country__r.Code__c,
                                     Subscription__r.Recipient_Contact__r.Address__r.Country__r.Name,
                                     //Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name,
                                     Subscription__r.Recipient_Contact__r.Address__r.Address_1__c,
                                     Subscription__r.Recipient_Contact__r.Address__r.Address_2__c,
                                     Subscription__r.Recipient_Contact__r.Address__r.Address_3__c,
                                     Subscription__r.Recipient_Contact__r.Address__r.Address_4__c,
                                     Subscription__r.Recipient_Contact__r.Address__r.Section_Code__r.Section_Name__c,
                                     Subscription__r.Recipient_Contact__r.Address__r.Department__r.Department_Name__c,
                                     Subscription__r.Recipient_Contact__r.Address__r.Division_Code__r.Name,
                                     Subscription__r.Recipient_Contact__r.Address__r.Company_Code__r.Company_Name__c,
                                     Subscription__r.Recipient_Contact__r.Address__r.Location_Code__r.Location_Name__c,
                                     Subscription__r.Recipient_Contact__r.Address__r.Section_Code__r.Name,
                                     Subscription__r.Recipient_Contact__r.Address__r.Department__r.Name,
                                     Subscription__r.Recipient_Contact__r.Address__r.Company_Code__r.Name,
                                     Subscription__r.Recipient_Contact__r.Address__r.Location_Code__r.Name,
                                     Subscription__r.Recipient_Contact__r.Address__r.City__c,
                                     Subscription__r.Recipient_Contact__r.Address__r.City__r.Name,
                                     Subscription__r.Recipient_Contact__r.Address__r.City__r.City_Name__c,
                                     Subscription__r.Recipient_Contact__r.Address__r.Airline_Number__c,
                                     Subscription__r.Recipient_Contact__r.Address__r.Flight_Number_1__c,
                                     Subscription__r.Recipient_Contact__r.Address__r.Flight_Number_2__c,
                                     Subscription__r.Recipient_Contact__r.Address__r.Packing_Code__c,
                                     Subscription__r.Recipient_Contact__r.name,
                                    Subscription__r.Recipient_Contact__r.Company_Name__c
                       FROM Packing_Label_Batch__c 
                       WHERE Id = :packingLabelId];
            //END UD-3201 16-Nov-2015 Added By S.Puli
            // END : UD-2914 10/26/2015 Added by Jason A           
            // END : UD-1839 7/14/2015 Alyana Navarro/S.Puli

            finalAddress = AddressHelper.formatAddress(PackagingLabel.Subscription__r.Recipient_Contact__r,false,true);
            //END D-3722 Gdelrosario 23/10/2015: added to query
            //END D-3529 Gdelrosario 14/10/2015: added to get the subscription to get value from reciepeint/ added query
            List<Package_Item__c> pckItem = [Select Id, Name, Package__c from Package_Item__c Where Package__c = :PackagingLabel.Subscription__r.Main_Package_1__c];
            
            if(PackagingLabel.Subscription__r.Recipient_Contact__r.Recipient_Number__c<>null){
                recipientNumber = String.valueOf(PackagingLabel.Subscription__r.Recipient_Contact__r.Recipient_Number__c);
            }
            
            
            List<Zuora__SubscriptionProductCharge__c> magazineSpcList = new List<Zuora__SubscriptionProductCharge__c>();
            if(PackagingLabel.Subscription__c <> null){
            // START : UD-1839 7/14/2015 Alyana Navarro/S.Puli
                magazineSpcList = [Select Id, Name, PublicationCode__c, Zuora__Subscription__c,  
                                   Zuora__Subscription__r.Main_Package_1__r.Name, Zuora__RatePlanName__c 
                                   From Zuora__SubscriptionProductCharge__c 
                                   Where Zuora__Subscription__c = :PackagingLabel.Subscription__c];
            }
            // END : UD-1839 7/14/2015 Alyana Navarro/S.Puli
                
            if(magazineSpcList.size()>0 && pckItem.size()>0){
                for(Zuora__SubscriptionProductCharge__c zSpc : magazineSpcList){
                    for(Package_Item__c pck : pckItem){ 
                        if(zSpc.Zuora__RatePlanName__c == pck.Name){
                            magPubCode = zSpc.PublicationCode__c;
                        }
                    }
                }       
            }

            /*
            START D-3529 Gdelrosario 14/10/2015 : removed not used codes
            // START : UD-1839 7/14/2015 Alyana Navarro/S.Puli
            if(PackagingLabel.Subscription__r.Recipient_Contact__r.Address__r.RecordType.Id == ConstantsSLB.getKeyId('Address_Local')){
                if(PackagingLabel.Subscription__r.Recipient_Contact__r.Address__r.Block_House_Number__c != null){
                    address1 = PackagingLabel.Subscription__r.Recipient_Contact__r.Address__r.Block_House_Number__c + ' ';
                }
                
                if(PackagingLabel.Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Street_Name__c != null){
                    address1 += PackagingLabel.Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Street_Name__c;
                }
                
                if(PackagingLabel.Subscription__r.Recipient_Contact__r.Address__r.Block_House_Number__c != null){
                    address2 = '#' + PackagingLabel.Subscription__r.Recipient_Contact__r.Address__r.Level_Number__c;
                }
                
                if(PackagingLabel.Subscription__r.Recipient_Contact__r.Address__r.Unit_Number__c != null){
                    address2 += '-' + PackagingLabel.Subscription__r.Recipient_Contact__r.Address__r.Unit_Number__c;
                }
                
                if(PackagingLabel.Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Building_Name__c != null){             
                    address3 = PackagingLabel.Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Building_Name__c;
                }
                
                if(PackagingLabel.Subscription__r.Recipient_Contact__r.Address__r.Country__r.Country_Name__c != null){
                    address4 = PackagingLabel.Subscription__r.Recipient_Contact__r.Address__r.Country__r.Country_Name__c + ' ';
                }
                
                if(PackagingLabel.Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name != null){
                    address4 += PackagingLabel.Subscription__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name;
                }
            } else if(PackagingLabel.Subscription__r.Recipient_Contact__r.Address__r.RecordType.Id == ConstantsSLB.getKeyId('Address_Internal')){
                if(PackagingLabel.Address_1__c != null){
                    address1 = PackagingLabel.Address_1__c;
                }
                
                if(PackagingLabel.Address_2__c != null){
                    address2 = PackagingLabel.Address_2__c;
                }

                if(PackagingLabel.Address_3__c != null){
                    address3 = PackagingLabel.Address_3__c;
                }
                
                if(PackagingLabel.Address_4__c != null){
                    address4 = PackagingLabel.Address_4__c;
                }
                
                if(PackagingLabel.Address_5__c != null){
                    address5 = PackagingLabel.Address_5__c;
                }           
            }
            // END : UD-1839 7/14/2015 Alyana Navarro/S.Puli
            END D-3529 Gdelrosario 14/10/2015 : removed not used codes
            */
        }
        //END : D-3015 05/25/2015 S.Puli
    //START : UD-2953 10/26/2015 Additional Method is being added by Jason A./Puli S
        public void overseasReportHardCopy(Set<String> subIdSet){
            try {
                recIdRecName = new Map<Id, String>();
                destinationRecipientIdMap = new Map<String, List<Id>>();        
                String addRecordTypeId = ConstantsSLB.getKeyId('Address_Overseas');
                Set<Id> airlineSubIdSet = new Set<Id>();
                Set<Id> recipientContactSet = new Set<Id>();
                List<Zuora__Subscription__c> airlineSubList = new List<Zuora__Subscription__c>();
                List<Zuora__SubscriptionProductCharge__c> subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();
                List<Contact> recipientContactList = new List<Contact>();
                Map<Id, Set<String>> airlineSubIdPubCodeSetMap = new Map<Id, Set<String>>();
                Map<Id, Zuora__Subscription__c> subscriptionMap = new Map<Id, Zuora__Subscription__c>();
                Map<String, List<String>> recipientNamePubCodeListMap = new Map<String, List<String>>();
                Map<String, Map<String, Integer>> recipientNamePubCodeQuanMapMap = new Map<String, Map<String, Integer>>();   

                pubCodesSubQtyMap = new Map<string,Integer>();

                //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
                //refDate = DateTime.valueOf(ApexPages.currentPage().getParameters().get('issueDate'));   //---------------->i changed this
                refDate = system.today();
                Date refIssueDate = Date.newInstance(refDate.year(), refDate.month(), refDate.day());
                
            airlineSubList = [SELECT id, name, Recipient_Contact__r.Name, Recipient_Contact__c, Frequency_1__c,Zuora__SubscriptionStartDate__c,Zuora__SubscriptionEndDate__c
                                  FROM Zuora__Subscription__c 
                                  WHERE subscription_type__c =: GlobalVariableClass.SUBSCRIPTION_TYPE_PUBLICATION 
                                        AND Recipient_Contact__r.Address__r.RecordTypeId =: addRecordTypeId 
                                        AND Zuora__SubscriptionStartDate__c <= :refIssueDate AND (Zuora__SubscriptionEndDate__c >= :refIssueDate or Zuora__SubscriptionEndDate__c = null)
                                        AND Id In :subIdSet];

                for(Zuora__Subscription__c sub : airlineSubList){
                    airlineSubIdSet.add(sub.id);
                    subscriptionMap.put(sub.id, sub);
                    recipientContactSet.add(sub.Recipient_Contact__c);
                }   
                

                recipientContactList = [SELECT id, name, Address__r.Packing_Code__r.Packing_Code__c, Address__r.City__r.Country__r.Code__c, Address__r.City__r.Name 
                                        FROM Contact 
                                        WHERE Id IN: recipientContactSet];            
                
                Set<String> UOMs = new Set <String>();
                UOMs.add(GlobalVariableClass.DUMMY_CHARGE);
                

                subProdChargeList = [SELECT id, name, PublicationCode__c, Zuora__Subscription__c,Zuora__UOM__c, Zuora__Subscription__r.Number_of_Copies__c
                                     FROM Zuora__SubscriptionProductCharge__c 
                                     WHERE Zuora__Subscription__c IN: airlineSubIdSet AND Zuora__UOM__c NOT IN :UOMs AND (Zuora__UOM__c <> null OR Zuora__UOM__c <> '')];            //End UD-2782 and UD-2783 VPernicia 08/18/15: Add Number_of_Copies__c

                for(Zuora__SubscriptionProductCharge__c subProdCharge : subProdChargeList){ 
                    if(subProdCharge.PublicationCode__c != null){
                        if(airlineSubIdPubCodeSetMap.containsKey(subProdCharge.Zuora__Subscription__c)){
                            airlineSubIdPubCodeSetMap.get(subProdCharge.Zuora__Subscription__c).add(subProdCharge.PublicationCode__c);
                        } else {
                            airlineSubIdPubCodeSetMap.put(subProdCharge.Zuora__Subscription__c, new Set<String>{subProdCharge.PublicationCode__c});
                        }
                    }
                    

                    pubCodesSubQtyMap.put(subProdCharge.Zuora__Subscription__c + subProdCharge.PublicationCode__c, Integer.valueOf(subProdCharge.Zuora__Subscription__r.Number_of_Copies__c));
                    
                }
                
                recIdPubCodeQuanMapMap = getPublication(airlineSubList, airlineSubIdPubCodeSetMap);
                getTotalPublications();
            } catch(Exception e){
            system.debug('Error in generating Report Hard Copy PDF');
            }
        }
    //END : UD-2953 10/26/2015 Additional Method is being added by Jason A./Puli S
        //END: D-3672 11/13/2015 Added by Kristine Balaoing
    }