public class PDFGenerationOverseasNewspaper{
    
        public Set<String> pubCodeSet {get; set;}
        public Set<Id> packLabelIdSet {get; set;}
        public Packing_Label_Batch__c PackagingLabel { get; set; }
        public List<Packing_Label_Batch__c> packLableList{get; set;}
        public Map<String, List<Packing_Label_Batch__c>>  mapSubscriberAccountNameToListofPackLabelList{get; set;}
        public Map<String, String> mapPubToProductFamily {get; set;} 
        // START : D-1189 1/22/2015 April Banaag
        public string mailingAgentAccountName {get; set;}
        public string fax {get; set;}
        // END : D-1189 1/22/2015

        public Integer BHSub {get; set;}
        public Integer WBsub {get; set;}
        public Integer ZBsub {get; set;}
        public Integer TMsub {get; set;}
        public Integer BTsub {get; set;}
        public Integer STsub {get; set;}
        public Integer NPsub {get; set;}
        public Integer MYsub {get; set;}
        public Integer SMsub {get; set;}
        
        //variables for freelist
        public Integer BHfree {get; set;}
        public Integer WBfree {get; set;}
        public Integer ZBfree {get; set;}
        public Integer TMfree {get; set;}
        public Integer BTfree {get; set;}
        public Integer STfree {get; set;}
        public Integer NPfree {get; set;}
        public Integer MYfree {get; set;}
        public Integer SMfree {get; set;}
        
        //variables for grand total
        public Integer grandTotalST {get; set;}
        public Integer grandTotalBT {get; set;}
        public Integer grandTotalBH {get; set;}
        public Integer grandTotalNP {get; set;}
        public Integer grandTotalZB {get; set;}
        public Integer grandTotalTM {get; set;}
        public Integer grandTotalWB {get; set;}
        public Integer grandTotalSM {get; set;}
        public Integer grandTotalMY {get; set;}
        
        // START : D-2013 3/5/2015 Alyana Navarro
        public String accountNumber {get; set;}
        // END : D-2013 3/5/2015 Alyana Navarro
    //START: D-3672 11/12/2015 Added by Kristine Balaoing - added for batch recovery
        public Date referenceDate {get; set;}
    //END: D-3672 11/12/2015 Added by Kristine Balaoing
        //START : D-3014 05/25/2015 S.Puli
        public String faxString {get; set;}
        //END : D-3014 05/25/2015 S.Puli
        public void generatePDF(){
            // START : D-2013 3/4/2015 Alyana Navarro
            Set<String> subIdSet = new Set<String>();
            List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
            List<Zuora__SubscriptionProductCharge__c> subProdChargeList = new List<Zuora__SubscriptionProductCharge__c>();
            Map<String, Set<String>> subIdSubProdChargeListMap = new Map<String, Set<String>>();
            // END : D-2013 3/4/2015 Alyana Navarro
            try
            {
                //variables instantiation
                BHSub = 0;
                WBsub = 0;
                ZBsub = 0;
                TMsub = 0;
                BTsub = 0;
                STsub = 0;
                NPsub = 0;
                MYsub = 0;
                SMsub = 0;
                
                //variables for freelist
                BHfree = 0;
                WBfree = 0;
                ZBfree = 0;
                TMfree = 0;
                BTfree = 0;
                STfree = 0;
                NPfree = 0;
                MYfree = 0;
                SMfree = 0;
                //variables for total 
                grandTotalST  = 0;
                grandTotalBT  = 0;
                grandTotalBH  = 0;
                grandTotalNP  = 0;
                grandTotalZB  = 0;
                grandTotalTM  = 0;
                grandTotalWB  = 0;
                grandTotalSM  = 0;
                grandTotalMY  = 0;
                pubCodeSet = new  Set<String>();
                packLabelIdSet = new Set<Id>();           
                packLableList = new List<Packing_Label_Batch__c>();
                mapSubscriberAccountNameToListofPackLabelList = new Map<String, List<Packing_Label_Batch__c>>();
                mapPubToProductFamily = new Map<String, String>();
                //DateToday = Date.Today();
                //START: D-2013 3/19/15 VPernicia: Add additional fields conditions - Grace Period, Payment method and Subscription Rate
                
                accountNumber = ApexPages.currentPage().getParameters().get('id');
                //START: D-3672 11/12/2015 Added by Kristine Balaoing - added for batch recovery
                referenceDate = Date.valueOf(ApexPages.currentPage().getParameters().get('issueDate'));
        
                // START : D-1189 1/22/2015 April Banaag
               
                //START : D-3014 05/25/2015 S.Puli
                packLableList = [SELECT Subscription__r.Order_Line_Item_Number_1__r.Vendor_Mailing_Agent__c, Account_Name__r.Name, Address_1__c, 
                                 Address_2__c, Address_3__c, Address_4__c,Building_Name__c, Copy_Type__c,Country__c, Issue_Date__c, Level__c, 
                                 Mailing_Agent_Account_Number__c, Number_of_Copies__c, Publication_Code__c, Recipient_Name__c, Recipient_Number__c, 
                                 Salutation__c, Subscriber_Account_Name__c, Subscriber_Account_Number__c, Subscription_Product_Charge__c, 
                                 Subscription_Type__c, Unit__c, Subscription__c, Record_Type__c, Product_Family__c,
                                 Subscription__r.Grace_Period_Subscription__c, Subscription__r.Other_PaymentMethod_1__c,
                                 Subscription__r.Order_Line_Item_Number_1__r.Total_Subscription_Rate__c, Subscription__r.Vendor_1__r.Fax
                                 FROM Packing_Label_Batch__c 
                                 WHERE Mailing_Agent_Account_Number__c = :accountNumber AND 
                                 Subscription_Type__c = 'Newspaper' AND Record_Type__c = 'Overseas'
                                 AND Issue_Date__c =:referenceDate];
                //END: D-3672 11/12/2015 Added by Kristine Balaoing - added for batch recovery
        //END : D-3014 05/25/2015 S.Puli
                //END: D-2013 3/19/15 VPernicia: Add additional fields - Grace Period, Payment method and Subscription Rate
                // START : D-2013 3/5/2015 Alyana Navarro
                for(Packing_Label_Batch__c  packLabel : packLableList){
                    subIdSet.add(packLabel.subscription__c);
                }
                //START : D-3017 06/04/2015 S.Puli
                subProdChargeList = [SELECT Id, name, PublicationCode__c, Zuora__Subscription__c, Zuora__Subscription__r.Recipient_Contact__c
                                     FROM Zuora__SubscriptionProductCharge__c 
                                     WHERE Zuora__Subscription__c IN: subIdSet];
                List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>();
                Map<id, Set<String>> subIdPubCodeSetMap = new Map<id, Set<String>>();
                
                if(subProdChargeList.size()>0){
                    for(Zuora__SubscriptionProductCharge__c zSPC : subProdChargeList){
                        if(subIdPubCodeSetMap.containskey(zSPC.Zuora__Subscription__c)){
                            subIdPubCodeSetMap.get(zSPC.Zuora__Subscription__c).add(zSPC.PublicationCode__c);
                        } else{
                            subIdPubCodeSetMap.put(zSPC.Zuora__Subscription__c, new Set<String>{zSPC.PublicationCode__c});
                        }
                    }
                }
                if(subIdSet.size()>0){
                    subscriptionList = [SELECT Id,Recipient_Contact__r.Address__r.Country__r.Name,Frequency_1__c,Recipient_Contact__c 
                    FROM Zuora__Subscription__c 
                    WHERE ID IN :subIdSet
                    ];

                }
                Map<Id, Map<String, Integer>> recIdToPubToCount_MAP = new Map<Id, Map<String, Integer>>();
                if(subscriptionList.size()>0){
                    
                //START : UD-2953 10/26/2015 Additional Method is being added by Jason A./Puli S   
                    PackingLabelsController plc = new PackingLabelsController ();
                    plc.overseasReportHardCopy(subIdSet);
                    recIdToPubToCount_MAP = plc.getPublication(subscriptionList, subIdPubCodeSetMap);
                //END : UD-2953 10/26/2015 Additional Method is being added by Jason A./Puli S
                }
                //END : D-3017 06/04/2015 S.Puli
                for(Zuora__SubscriptionProductCharge__c subProdCha : subProdChargeList){
                    //Start  D-3017 Added by S.Puli
                    if(recIdToPubToCount_MAP.containskey(subProdCha.Zuora__Subscription__r.Recipient_Contact__c)){
                        if(subProdCha.PublicationCode__c <> null){
                            //START D-3908 16Nov15 AddedBy FritzB/VonP : added checking for null values.
                            if(recIdToPubToCount_MAP.get(subProdCha.Zuora__Subscription__r.Recipient_Contact__c).containsKey(subProdCha.PublicationCode__c))
                            {
                                if(recIdToPubToCount_MAP.get(subProdCha.Zuora__Subscription__r.Recipient_Contact__c).get(subProdCha.PublicationCode__c)>0)
                                {
                                    if(subIdSubProdChargeListMap.containsKey(subProdCha.Zuora__Subscription__c)){
                                        subIdSubProdChargeListMap.get(subProdCha.Zuora__Subscription__c).add(subProdCha.PublicationCode__c);
                                    } else {
                                        subIdSubProdChargeListMap.put(subProdCha.Zuora__Subscription__c, new Set<String>{subProdCha.PublicationCode__c});
                                    }
                                }
                            }
                            //END D-3908 16Nov15 AddedBy FritzB/VonP : added checking for null values.
                        }
                    }
                    //End  D-3017 Added by S.Puli
                }
                // END : D-2013 3/5/2015 Alyana Navarro
                
                //START: D-2013 3/19/15 VPernicia: Removed if condition and use query string value to pull account data
                //START D-3013 05/22/2015 Added By S.Puli
                //START D-3014 05/26/2015 Added By S.Puli
                Account mailingAgentAccount = [SELECT Id, Name, Fax 
                                               FROM Account 
                                               WHERE AccountNumber =: accountNumber Limit 1];
                //END D-3014 05/26/2015 Added By S.Puli
                //END D-3013 05/22/2015 Added By S.Puli
                mailingAgentAccountName = mailingAgentAccount.Name;
                //START D-3014 05/26/2015 Added By S.Puli
                faxString = '';
                if(mailingAgentAccount.Fax <> null){
                    faxString = '( Fax: '+String.valueOf(mailingAgentAccount.Fax)+')';
                }
                //END D-3014 05/26/2015 Added By S.Puli
                //END: D-2013 3/19/15 VPernicia: Removed if condition and use query string value to pull account data
                for(Packing_Label_Batch__c packLabel : packLableList){
                    //START SPH Code Review - 13-Feb-2015 Added by Raviteja - included if condition in order to avoid null pointer exception in SOQL     
                    if(packLabel.Publication_Code__c != null){
                    pubCodeSet.add(packLabel.Publication_Code__c);
                    }
                    //End SPH Code Review - 13-Feb-2015 Added by Raviteja 
                    packLabelIdSet.add(packLabel.Id);
                }
                
                
                List<Publication__c> pubList = [SELECT Id, Publication_Code__c, Product_Family__c
                                                FROM Publication__c
                                                WHERE Publication_Code__c IN : pubCodeSet];
                for(Publication__c pub : pubList){
                    mapPubToProductFamily.put(pub.Publication_Code__c , pub.Product_Family__c);
                }
                // START : D-2013 3/5/2015 Alyana Navarro
                for(Packing_Label_Batch__c packLabelBatch : packLableList){
                    if(subIdSubProdChargeListMap.containsKey(packLabelBatch.Subscription__c)){
                        for(String pubCode : subIdSubProdChargeListMap.get(packLabelBatch.Subscription__c)){
                        
                            //START: D-2013 3/19/15 VPernicia: Add additional conditions - Grace Period, Payment method and Subscription Rate
                            if(packLabelBatch.Copy_Type__c == 'FreeList' 
                                //START D-3013 05/22/2015 Added By S.Puli
                                //REMOVE || packLabelBatch.Subscription__r.Grace_Period_Subscription__c != null
                                //REMOVE || packLabelBatch.Subscription__r.Other_PaymentMethod_1__c == 'Free List'
                                //REMOVE || packLabelBatch.Subscription__r.Order_Line_Item_Number_1__r.Total_Subscription_Rate__c == 0 
                                ){
                                //END D-3013 05/22/2015 Added By S.Puli
                                if(pubCode == 'BH'){
                                    //START D-3013 05/22/2015 Added By S.Puli
                                    BHfree += integer.valueOf(packLabelBatch.Number_of_Copies__c);
                                    //END D-3013 05/22/2015 Added By S.Puli
                                }
                                if(pubCode == 'WB'){
                                    //START D-3013 05/22/2015 Added By S.Puli
                                    WBfree += integer.valueOf(packLabelBatch.Number_of_Copies__c);
                                    //END D-3013 05/22/2015 Added By S.Puli
                                }
                                if(pubCode == 'ZB'){
                                    //START D-3013 05/22/2015 Added By S.Puli
                                    ZBfree += integer.valueOf(packLabelBatch.Number_of_Copies__c);
                                    //END D-3013 05/22/2015 Added By S.Puli
                                }
                                if(pubCode == 'TM'){
                                    //START D-3013 05/22/2015 Added By S.Puli
                                    TMfree += integer.valueOf(packLabelBatch.Number_of_Copies__c);
                                    //END D-3013 05/22/2015 Added By S.Puli
                                }
                                if(pubCode == 'BT'){
                                    //START D-3013 05/22/2015 Added By S.Puli
                                    BTfree += integer.valueOf(packLabelBatch.Number_of_Copies__c);
                                    //END D-3013 05/22/2015 Added By S.Puli
                                }
                                if(pubCode == 'ST'){
                                    //START D-3013 05/22/2015 Added By S.Puli
                                    STfree += integer.valueOf(packLabelBatch.Number_of_Copies__c);
                                    //END D-3013 05/22/2015 Added By S.Puli
                                }
                                if(pubCode == 'NP'){
                                    //START D-3013 05/22/2015 Added By S.Puli
                                    NPfree += integer.valueOf(packLabelBatch.Number_of_Copies__c);
                                    //END D-3013 05/22/2015 Added By S.Puli
                                }
                                if(pubCode == 'MY'){
                                    //START D-3013 05/22/2015 Added By S.Puli
                                    MYfree += integer.valueOf(packLabelBatch.Number_of_Copies__c);
                                    //END D-3013 05/22/2015 Added By S.Puli
                                }
                                if(pubCode == 'SM'){
                                    //START D-3013 05/22/2015 Added By S.Puli
                                    SMfree += integer.valueOf(packLabelBatch.Number_of_Copies__c);
                                    //END D-3013 05/22/2015 Added By S.Puli
                                }   
                            }
                            
                            else if(packLabelBatch.Copy_Type__c == 'Subscription'){
                                if(pubCode == 'BH'){
                                    //START D-3013 05/22/2015 Added By S.Puli
                                    BHSub += integer.valueOf(packLabelBatch.Number_of_Copies__c);
                                    //END D-3013 05/22/2015 Added By S.Puli
                                }
                                if(pubCode == 'WB'){
                                    //START D-3013 05/22/2015 Added By S.Puli
                                    WBsub += integer.valueOf(packLabelBatch.Number_of_Copies__c);
                                    //END D-3013 05/22/2015 Added By S.Puli
                                }
                                if(pubCode == 'ZB'){
                                    //START D-3013 05/22/2015 Added By S.Puli
                                    ZBsub += integer.valueOf(packLabelBatch.Number_of_Copies__c);
                                    //END D-3013 05/22/2015 Added By S.Puli
                                }
                                if(pubCode == 'TM'){
                                    //START D-3013 05/22/2015 Added By S.Puli
                                    TMsub += integer.valueOf(packLabelBatch.Number_of_Copies__c);
                                    //END D-3013 05/22/2015 Added By S.Puli
                                }
                                if(pubCode == 'BT'){
                                    //START D-3013 05/22/2015 Added By S.Puli
                                    BTsub += integer.valueOf(packLabelBatch.Number_of_Copies__c);
                                    //END D-3013 05/22/2015 Added By S.Puli
                                }
                                if(pubCode == 'ST'){
                                    //START D-3013 05/22/2015 Added By S.Puli
                                    STsub += integer.valueOf(packLabelBatch.Number_of_Copies__c);
                                    //END D-3013 05/22/2015 Added By S.Puli
                                }
                                if(pubCode == 'NP'){
                                    //START D-3013 05/22/2015 Added By S.Puli
                                    NPsub += integer.valueOf(packLabelBatch.Number_of_Copies__c);
                                    //END D-3013 05/22/2015 Added By S.Puli
                                }
                                if(pubCode == 'MY'){
                                    //START D-3013 05/22/2015 Added By S.Puli
                                    MYsub += integer.valueOf(packLabelBatch.Number_of_Copies__c);
                                    //END D-3013 05/22/2015 Added By S.Puli
                                }
                                if(pubCode == 'SM'){
                                    //START D-3013 05/22/2015 Added By S.Puli
                                    SMsub += integer.valueOf(packLabelBatch.Number_of_Copies__c);
                                    //END D-3013 05/22/2015 Added By S.Puli
                                }
                            }
                            //END: D-2013 3/19/15 VPernicia: Add additional conditions - Grace Period, Payment method and Subscription Rate
                        }
                    }
                }
                // END : D-2013 3/5/2015 Alyana Navarro
                grandTotalST = STsub + STfree;
                grandTotalBT = BTsub + BTfree;
                grandTotalBH = BHsub + BHfree;
                grandTotalNP = NPsub + NPfree;
                grandTotalZB = ZBsub + ZBfree;
                grandTotalTM = TMsub + TMfree;
                grandTotalWB = WBsub + WBfree;
                grandTotalSM = SMsub + SMfree;
                grandTotalMY = MYsub + MYfree;
            }
            catch(Exception e)
            {

            }
            
            // END : D-1189 1/22/2015
        }
}