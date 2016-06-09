/** 
 * Class Name: CreateVendorOrderEntryController
 * @author 
 * Date: 2014.07.31
 * Requirement: Start Subscription Order Entry
 * @description This class is use as an apex controller of CreateVendorOrderEntry VF page.
 *
 */

/*
 * ------Revision------
 * Version 1.0: Pilot Release
 * By: <Glenn Garcia>
 * Description:
 * History: [Jayson S|D-0861] Set default quantity of publication to 1
 * History: [Wenjun D-1280 18/12/14]
 */

public class CreateVendorOrderEntryController {
  //Start MMallorca D-3137 06/26/2015
  Set<Id> sundayPubs;
  //End MMallorca D-3137 06/26/2015
  
    final static string DELIVERY_CHARGE_KEY = 'SubscriberCharge';   // D-2040 02/05/2015 JohnD
    
    public Order__c order {get; set;}
    //public List<Order_Line_Item_Vendor__c> orders { get; set; }
    public Publication__c pub {get; set; }
    public Order_Line_Item_Vendor__c oli {get; set;}
    public Integer counter {get; set;}
    public String index {get; set;}
    public List<OrWrapper> orWrapperList {get;set;}
    public Case objcase {get;set;}
    Id accountId;
    Set<id> specialPublicationIds;
    String orderId;
    //Start D-1749 01/26/15 Added by A BANAAG declare maps
    Map <id,double> mapPubIdToPhe= new Map <id,double>();
    Map <id,double> mapPubIdToPhw= new Map <id,double>();
    //End D-1749 01/26/15 Added by A BANAAG declare maps
    date dtlDate;  // Start/End UD-1451 16Jun15 RReyes
    /*
     * publication__c reference data
     * Map<Product Family, Map<Day of week, Publication Id>>
     */
    /*
     * publication__c reference data
     * Map<Publication Id, Product Family>
     * Will only contain mapping for publications under special product families
     */
    Map<Id, String> publicationIdToProductFamilyMap;
    /*
     * publication__c reference data
     * Map<Publication Id, publish pattern>
     */
    //START D-1280 18/12/14 Wenjun : Redefine Publication Pattern Map
    Map<Id, PublicationPattern> publicationIdToPatternMap;
    //END D-1280 18/12/14
    /*
     * publication__c reference data
     * Map<Product Family, Id of primary publication>
     */
        //Start D-1755 02/11/2015 added by ABanaag  
        Map<String, Id> productFamilyToPrimaryPublicationMap = new Map<String, Id>(); //START-END D-4076 12-10-2015 added by Jason A. for code review
        //End D-1755 02/11/2015 added by ABanaag  
        Map<Integer, Map<String, Order_Line_Item_Vendor__c>> counterToLineItemsMap;
        Id parentCaseId; //START/END UD-3293 11/25/15 RReyes
        //Wrapper class for Order Line Item Vendor Records
        public class OrWrapper {
            public Id oldPublicationId {get; set;}
            public Order_Line_Item_Vendor__c oLine {get;set;}
            public Integer counterWrap {get;set;}
            public String styleClass {get; set;}
            public String pubStyleClass {get; set;}
            //START D-1280 18/12/14 Wenjun : Store the pattern to disable user input
            public PublicationPattern pattern {get; set;}
            //END D-1280 18/12/14
            public OrWrapper(Order_Line_Item_Vendor__c ol){
                this.oLine = ol;
                this.styleClass = 'day';     
            }
        }

    public CreateVendorOrderEntryController() {
        Set<Integer> counterNumbersWithCreatedWrappers = new Set<Integer>(); 
        //orderId = ApexPages.currentPage().getParameters().get('id');
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        counter=0;
        orWrapperList = new List<orWrapper>();
            //START UD-3293 11/25/15 RReyes
            parentCaseId = ApexPages.currentPage().getParameters().get('def_parent_id');
            if (parentCaseId != null) {
                string tmp = parentCaseId;
                tmp.toLowerCase();
                if (tmp == 'null') {
                    parentCaseId = null;
                }
            }   
            //END UD-3293 11/25/15 RReyes
        counterToLineItemsMap = new Map<Integer, Map<String, Order_Line_Item_Vendor__c>>();
        publicationIdToProductFamilyMap = new Map<Id, String>();
        //START D-1280 18/12/14 Wenjun : Redefine Publication Pattern Map
        publicationIdToPatternMap = new Map<Id, PublicationPattern>();
        //END D-1280 18/12/14 Wenjun
        //Start D-1755 02/11/2015 added by ABanaag
        specialPublicationIds = new Set<Id>(); 
        //End D-1755 02/11/2015 added by ABanaag
    
    //Start MMallorca D-3137 06/26/2015
    sundayPubs = new Set<Id>();
    //End MMallorca D-3137 06/26/2015
    
        getItems();
        
        //query order and order line items
        if(accountId != null) {//edit mode
            try {
            //Start: D-1456 added by A. Banaag - add DTL date to query
                // Start D-2040 02/05/2015 JohnD added Delivery_Charge__c field in the query          
                order = [SELECT Id, DTL_Date__c, Account__c, Recipient_Contact__c, Reason__c,  Remarks__c, Vendor_Sms_Remarks__c, Informed_Customer__c,   
                     Delivery_Charge__c FROM Order__c WHERE Account__c = :accountId AND Status__c = 'Draft' LIMIT 1];
                // End D-2040 02/05/2015 JohnD added Delivery_Charge__c field in the query
        // Start D-1755 02/11/2015 AprilB added publication__r.product_family_lookup__r.name field                
                LIST<Order_Line_Item_Vendor__c> vLineItems = [SELECT Id, Publication__r.Product_Family_Lookup__r.Name, DTL_Date__c, Mon__c, Tue__c, Recipient_Postal_Code__c, Wed__c, Thu__c, Fri__c, Sat__c, Sun__c,
                     PHe__c, PHd__c, Start_Date__c, Notify_Vendor__c, Wrapper_Number__c, Stop_Date__c, Publication__c, Publication__r.Publish_Pattern__c, Publication__r.Sunday_Publication__c, Publication__r.Product_Family__c 
                     FROM Order_Line_Item_Vendor__c
                     WHERE Order__c = :order.Id ORDER BY Wrapper_Number__c];
        // End D-1755 02/11/2015 AprilB
           //End: D-1456 added by A. Banaag - add DTL date to query                               
                for(Order_Line_Item_Vendor__c oli : vLineItems) {
                    counter = (Integer) oli.Wrapper_Number__c;
                    //Start D-1755 02/11/2015 added by ABanaag
                    if(oli.Publication__r.Sunday_Publication__c==null) {//check if line item is in special product family
                    //End D-1755 02/11/2015 added by ABanaag
                        OrWrapper OrWrap = new OrWrapper(oli);
                        OrWrap.counterWrap = counter;
                        orWrapperList.add(OrWrap);
                        counterNumbersWithCreatedWrappers.add(counter);
                        counterToLineItemsMap.put(counter, new Map<String, Order_Line_Item_Vendor__c>{'Weekdays' => oli});
                        //START D-1280 19/12/14 Wenjun : Initialise pattern for existing Items
                        OrWrap.pattern = publicationIdToPatternMap.get(oli.Publication__c);
                        //END D-1280 19/12/14
                    }
                    else { //special publication, populate mapping for counter number and set of order line item vendor records 
                        if(counterToLineItemsMap.containsKey(counter)) {
                            counterToLineItemsMap.get(counter).put(oli.Publication__r.Sunday_Publication__c != null ? 'Weekdays' : 'Weekends', oli);
                        }
                        else {
                            counterToLineItemsMap.put(counter, new Map<String, Order_Line_Item_Vendor__c>{oli.Publication__r.Sunday_Publication__c != null ? 'Weekdays' : 'Weekends' => oli});
                        }
                    }
                }
                for(Integer key : counterToLineItemsMap.keySet()) {
                    counter = key;
                    if(!counterNumbersWithCreatedWrappers.contains(key)) { //create wrapper objects for counters with no items only
                        OrWrapper orWrap = new OrWrapper(    
                            new Order_Line_Item_Vendor__c(
                                //START D-1280 19/12/14 Wenjun : Set Qty to 0 for Empty Line
                                Mon__c = 0,Tue__c = 0,Wed__c = 0,Thu__c = 0, Fri__c = 0,Sat__c = 0,Sun__c = 0,PHe__c = 0,PHd__c = 0
                                //END D-1280 19/12/14 Wenjun
                            )
                        );
                        orWrap.counterWrap = counter;
                        orWrap.oLine.Wrapper_Number__c = counter;
                        for(Order_Line_Item_Vendor__c oliv : counterToLineItemsMap.get(key).values()) {
                            if(publicationIdToProductFamilyMap.containsKey(oliv.Publication__c)) { //create wrapper objects for publications under special product families only.
                                    //wrapper object for non-special publication is already created above
                                //relate the line item to publication for weekday (regular issue)
                                //if(publicationIdToProductFamilyMap.containsKey(oliv.Publication__c)) {
                                    //Start D-1755 02/11/2015 Added by ABanaag
                                    if(specialPublicationIds.contains(oliv.Publication__c)) {
                                        orWrap.oLine.Publication__c = (oliv.Publication__c); 
                                    //end D-1755 02/11/2015 Added by ABanaag    
                                    }
                                //}
                                //orWrap.oLine.Publication = ?????;
                                //get primary publication from map
                                    orWrap.oLine.Mon__c += (oliv.Mon__c != NULL ? oliv.Mon__c : 0);
                                    orWrap.oLine.Tue__c += (oliv.Tue__c != NULL ? oliv.Tue__c : 0);
                                    orWrap.oLine.Wed__c += (oliv.Wed__c != NULL ? oliv.Wed__c : 0);
                                    orWrap.oLine.Thu__c += (oliv.Thu__c != NULL ? oliv.Thu__c : 0);
                                    orWrap.oLine.Fri__c += (oliv.Fri__c != NULL ? oliv.Fri__c : 0);
                                    orWrap.oLine.Sat__c += (oliv.Sat__c != NULL ? oliv.Sat__c : 0);
                                    orWrap.oLine.Sun__c += (oliv.Sun__c != NULL ? oliv.Sun__c : 0);
                                    orWrap.oLine.Phd__c = (oliv.Phd__c != NULL ? oliv.Phd__c : 0);
                                    orWrap.oLine.Phe__c = (oliv.Phe__c != NULL ? oliv.Phe__c : 0);
                                orWrap.oLine.Start_Date__c = oliv.Start_Date__c;
                                orWrap.oLine.Stop_Date__c = oliv.Stop_Date__c;
                                
                                //START D-1280 19/12/14 Wenjun : Initialise pattern for existing Items
                                orWrap.pattern = publicationIdToPatternMap.get(orWrap.oLine.Publication__c);
                                //END D-1280 19/12/14
                            }
                        }
                        orWrapperList.add(orWrap);
                    }
                }
                     
            }
            catch(QueryException e) {
                //in case of failure to restrieve order and related order line item vendor records, instantiate new records
                order = new Order__c(Account__c=accountId);
                OrWrapper OrWrap = new OrWrapper(
                    new Order_Line_Item_Vendor__c(
                        //START D-1280 19/12/14 Wenjun : Set Qty to 0 for Empty Line
                        Mon__c = 0,Tue__c = 0,Wed__c = 0,Thu__c = 0, Fri__c = 0,Sat__c = 0,Sun__c = 0,PHe__c = 0,PHd__c = 0
                        // Start UD-263 Ronald Dagaraga Set value to true
                        , Notify_Vendor__c = true
                        // End UD-263 Ronald Dagaraga Set value to true
                        //END D-1280 19/12/14 Wenjun 
                    )
                );
                counter++;
                OrWrap.counterWrap = counter;
                orWrap.oLine.Wrapper_Number__c = counter;
                orWrapperList.add(OrWrap);
            }
            catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            }
            try {
                objCase = [SELECT Id FROM Case WHERE Order__c = :order.Id AND Order__c != null LIMIT 1];
            }
            catch(Exception e) {
                objCase = new Case();
            }
            
        }
        else {
            //no passed Id, instantiate Order and line item wrapper records
            OrWrapper OrWrap = new OrWrapper(
                new Order_Line_Item_Vendor__c(
                    //START D-1280 19/12/14 Wenjun : Set Qty to 0 for Empty Line
                    Mon__c = 0,Tue__c = 0,Wed__c = 0,Thu__c = 0, Fri__c = 0,Sat__c = 0,Sun__c = 0,PHe__c = 0,PHd__c = 0
                    //END D-1280 19/12/14 Wenjun 
                )
            );
            counter++;
            OrWrap.counterWrap = counter; 
            OrWrap.oLine.Wrapper_Number__c = counter;
            orWrapperList.add(OrWrap);
            order = new Order__c();
        }
        
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'map: ' + String.valueOf(publicationIdToProductFamilyMap)));
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'counter: ' + String.valueOf(counterToLineItemsMap)));
        //populate maps

        // Start D-2040 02/05/2015 JohnD populate delivery charge
        if (order.Recipient_Contact__c == null) {
            list<Contact> contactList = [select Id from Contact where AccountId = :order.Account__c 
                    and Recipient_Indicator__c = true order by CreatedDate desc limit 1];
            
            if (contactList.size() > 0) {
                order.Recipient_Contact__c = contactList[0].Id;
            }
        } 
        //Start UD-0223 03/05/15 ABanaag - there should be no delivery charges for vendor subscriptions
        order.delivery_charge__c = 0;
        //Start UD-0223 03/05/15 ABanaag - there should be no delivery charges for vendor subscriptions
        // End D-2040 02/05/2015 JohnD

    }

    private void getItems() {
        //START D-1280 18/12/14 Wenjun : Rewrite the whole Class... Too many unused codes...
        /* Rewrite the Class
        items = new List<SelectOption>();
        items.add(new SelectOption('', ' --Select a Publication-- '));
        Set<SelectOption> optionSet = new Set<SelectOption>();
        List<Publication__c> publications = [SELECT Id, Name,Product_Family__c,Publish_Pattern__c, Sunday_Publication__c FROM Publication__c];
        for(Publication__c pub : publications) {
            if(!specialPublications.contains(pub.Product_Family__c)) {//check if publication is in special product family
                optionSet.add(new SelectOption(pub.Id, pub.Name));
            }
            else {//product is in special families
                if(productFamilyToPublicationsMap.containsKey(pub.Product_Family__c)) {
                    productFamilyToPublicationsMap.get(pub.Product_Family__c).put(pub.Sunday_Publication__c != null ? 'Weekdays' : 'Weekends', pub.Id);
                }
                else {
                    productFamilyToPublicationsMap.put(pub.Product_Family__c, New Map<String, Id>{pub.Sunday_Publication__c != null ? 'Weekdays' : 'Weekends' => pub.Id});
                }
                if(pub.Sunday_Publication__c != null) {
                    optionSet.add(new SelectOption(pub.Id, Pub.Name));
                    productFamilyToPrimaryPublicationMap.put(pub.Product_Family__c, pub.Id);
                }
                else {
                    productFamilyToSecondaryPublicationMap.put(pub.Product_Family__c, pub.Id);
                }
                publicationIdToProductFamilyMap.put(pub.Id, pub.Product_Family__c);
                publicationIdToPublishPatternMap.put(pub.Id, pub.Sunday_Publication__c != null ? 'Weekdays' : 'Weekends');
            }
            
        }
        items.addAll(optionSet);
        */
        //Retrieve all the Newspaer Publications to Cache
        // Start D-1755 02/11/2015 AprilB added publication__r.product_family_lookup__r.name field    
        List<Publication__c> publications = [SELECT Id,Name,Product_Family_Lookup__r.Name,Product_Family__c,Published_Days__c,Sunday_Publication__c,
                                             Public_Holiday_Weekday_Pub_Indicator__c,Public_Holiday_Weekend_Pub_Indicator__c 
                                             FROM Publication__c WHERE Publication_Type__c = 'N'];
        for(Publication__c pub : publications) {
        // End D-1755 02/11/2015 AprilB
            //check if publication is in special product family
                //Start/End D-1755 02/11/2015 added by ABanaag 
                if(pub.Sunday_Publication__c != null) { 
                    specialPublicationIds.add(pub.Id); 
          //Start MMallorca D-3137 06/26/2015
          sundayPubs.add(pub.Sunday_Publication__c);
          //End MMallorca D-3137 06/26/2015
                //End D-1755 02/11/2015 added by ABanaag
                }
                publicationIdToProductFamilyMap.put(pub.Id, pub.Product_Family__c);
            
            //Generate Publication Pattern Map
            publicationIdToPatternMap.put(pub.Id,generatePattern(pub));
        }        
        //END D-1280 18/12/14 Wenjun
    }

    
    public PageReference addOrder() {
        //START UD-0136 3/3/15 Addedby FrancisBenzon: variable string to avoid hardcoding
        String StopDateValidation = GlobalVariableClass.VENDORSUB_STOPDATE_INVALID;
        String StartDateValidation = GlobalVariableClass.VENDORSUB_STARTDATE_NULL;  
        //END UD-0136 3/3/15 Addedby FrancisBenzon: variable string to avoid hardcoding
        
        for(OrWrapper ow : orWrapperList ) {
            //START UD-0136 3/3/15 Addedby FrancisBenzon: Removed Stop Date as a required field, Added validation for stop date to be greater than start date.
            if(ow.oLine.Start_Date__c==NULL) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage(StartDateValidation)));
                return null;
            }
            if(ow.oLine.Start_Date__c > ow.oLine.Stop_Date__c) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage(StopDateValidation)));
                return null;
            }
            //END UD-0136 3/3/15 Addedby FrancisBenzon: Removed Stop Date as a required field, Added validation for stop date to be greater than start date.
            //START UD-0259 3/23/15 Addedby RodelioSantos: Added validation stop date should not be null/ Start date should be greater than today.
            if(ow.oLine.Start_Date__c <= date.today())
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Start Date should be greater than date today.'));
                return null;
            }
            //START UD-0915 4/14/2015 Added by Manolo Valena - Removed as it is not mandatory for Vendor Subscription Account to input Stop Date value.
            /*if(ow.oLine.Stop_Date__c ==NULL)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Stop Date should not be null'));
                return null;
            }*/
            //END UD-0915 4/14/2015 Added by Manolo Valena
            //END UD-0259 3/23/15 Addedby RodelioSantos: Added validation stop date should not be null/ Start date should be greater than today.
            if(ow.counterWrap > counter) {
                counter = ow.counterWrap;
            }
        }

        OrWrapper OrWrap = new OrWrapper(
            new Order_Line_Item_Vendor__c(
                //START D-1280 19/12/14 Wenjun : Set Qty to 0 for Empty Line
                Mon__c = 0,Tue__c = 0,Wed__c = 0,Thu__c = 0, Fri__c = 0,Sat__c = 0,Sun__c = 0,PHe__c = 0,PHd__c = 0
                // Start UD-263 Ronald Dagaraga Set value to true
                , Notify_Vendor__c = true
                // End UD-263 Ronald Dagaraga Set value to true
                //END D-1280 19/12/14 Wenjun           
            )
        );
        counter++;
        OrWrap.counterWrap = counter;
        orWrap.oLine.Wrapper_Number__c = counter;
        orWrapperList.add(OrWrap);
        return null;
    }

    public void removePub(){
        Integer param = Integer.valueOf(index);
        
        for(Integer i=0; i<orWrapperList.size(); i++){
            if(orWrapperList[i].counterWrap == param){
                orWrapperList.remove(i); 
            }
        }
        //delete records that were previously inserted but were removed through the "remove" button
        if(counterToLineItemsMap.containsKey(param)) {
            List<Order_Line_Item_Vendor__c> itemsToDelete = new List<Order_Line_Item_Vendor__c>();
            itemsToDelete.addAll(counterToLineItemsMap.remove(param).values());
            try {
                delete itemsToDelete;
            }
            catch(DmlException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error while trying to remove line items. Error Message: ' + e.getMessage()));
            }
        }
    }
              
    public PageReference saveDraft() {                
        //START UD-0136 3/3/15 Addedby FrancisBenzon: variable string to avoid hardcoding
        String StopDateValidation = GlobalVariableClass.VENDORSUB_STOPDATE_INVALID;
        String StartDateValidation = GlobalVariableClass.VENDORSUB_STARTDATE_NULL;
        //END UD-0136 3/3/15 Addedby FrancisBenzon: variable string to avoid hardcoding
        System.debug('Savedraft method entered!'); 
        order.Credit_Balance__c = 0;
        order.Monthly_Delivery_Charge_for_Full_Payment__c = 1;
        order.Status__c = 'Draft';
        order.DTL_Date__c = dtlDate; // Start/End UD-1451 16Jun15 RReyes
            //START UD-3293 11/25/15 RReyes
            if(parentCaseId != null){
                order.Parent_Case__c = String.ValueOf(parentCaseId);
            }
            //END UD-3293 11/25/15 RReyes
        try {
                upsert order;
        }
        catch(DMLException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getDmlMessage(0)));
                return null;
        }

        // list that holds the Order_Line_Item_Vendor__c records
        // to be inserted
        Map<Integer, Map<String, Order_Line_Item_Vendor__c>> newCounterToLineItemsMap = new Map<Integer, Map<String, Order_Line_Item_Vendor__c>>();
        Map<Integer, Map<String, Order_Line_Item_Vendor__c>> oldCounterToLineItemsMap = counterToLineItemsMap.clone();
        List<Order_Line_Item_Vendor__c> orInsertList = new List<Order_Line_Item_Vendor__c>();
        List<Order_Line_Item_Vendor__c> orDeleteList = new List<Order_Line_Item_Vendor__c>();
        Boolean hasError = false;
                
        for (OrWrapper ow : orWrapperList) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, '========================== ' + ow.counterWrap));
            //VALIDATION: Populate number of copies for at least one day from Monday-Sunday
            if((ow.oLine.Mon__c == null || ow.oLine.Mon__c <= 0) &&
                (ow.oLine.Tue__c == null || ow.oLine.Tue__c <= 0) &&
                (ow.oLine.Wed__c == null || ow.oLine.Wed__c <= 0) &&
                (ow.oLine.Thu__c == null || ow.oLine.Thu__c <= 0) &&
                (ow.oLine.Fri__c == null || ow.oLine.Fri__c <= 0) &&
                (ow.oLine.Sat__c == null || ow.oLine.Sat__c <= 0) &&
                (ow.oLine.Sun__c == null || ow.oLine.Sun__c <= 0)) {
                hasError = true;
                ow.styleClass = 'error';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please enter a valid number of publications!'));
                return null;
            }
            //START UD-0136 3/3/15 Addedby FrancisBenzon: Removed Stop Date as a required field, Added validation for stop date to be greater than start date.
            else if(ow.oLine.Start_Date__c==NULL){
                        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage(StartDateValidation)));
            return null;
            }
            if(ow.oLine.Start_Date__c > ow.oLine.Stop_Date__c) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ConstantsSLB.getErrorMessage(StopDateValidation)));
                return null;
            }
            //END UD-0136 3/3/15 Addedby FrancisBenzon: Removed Stop Date as a required field, Added validation for stop date to be greater than start date.
            //START UD-0259 3/23/15 Addedby RodelioSantos: Added validation stop date should not be null/ Start date should be greater than today.
            if(ow.oLine.Start_Date__c <= date.today())
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Start Date should be greater than date today.'));
                return null;
            }
            //START UD-0915 4/14/2015 Added by Manolo Valena - Removed as it is not mandatory for Vendor Subscription Account to input Stop Date value.
            /*if(ow.oLine.Stop_Date__c ==NULL)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Stop Date should not be null'));
                return null;
            }*/
            //END UD-0915 4/14/2015 Added by Manolo Valena
            //END UD-0259 3/23/15 Addedby RodelioSantos: Added validation stop date should not be null/ Start date should be greater than today.
            else {
                ow.styleClass = 'day';
            }
            //VALIDATION: Publication must NOT be null
            if(ow.oLine.Publication__c == null) {
                ow.pubStyleClass = 'selectError';
                hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select a Publication!'));
                return null;
            }
            else {
                ow.pubStyleClass = '';
                //ow.oldPublicationId = ow.oLine.Publication__c;
            }

            /*
             * check if line item is linked to a special publication
             */
            system.debug('saveDraft publicationIdToProductFamilyMap=>' +publicationIdToProductFamilyMap);
            Boolean isSpecialPublication = FALSE;
            //Start D-1755 02/11/2015 Added by ABanaag 
            if(specialPublicationIds.contains(ow.oLine.Publication__c)) { 
            //End D-1755 02/11/2015 Added by ABanaag 
                isSpecialPublication = TRUE;
            }
            else {
                isSpecialPublication = FALSE;
            }
             
            /*
             * process line items
             */
            Map<String, Order_Line_Item_Vendor__c> orderLineItems = new Map<String, Order_Line_Item_Vendor__c>();
            Map<String, Order_Line_Item_Vendor__c> newOrderLineItems = new Map<String, Order_Line_Item_Vendor__c>();
            if(counterToLineItemsMap.containsKey(ow.counterWrap)) {
                orderLineItems = counterToLineItemsMap.get(ow.counterWrap).clone();//clone the collection so we can replace it later
            }
            
            //non-special publications
            if(!isSpecialPublication) {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'NON - Special Publication ' + ow.counterWrap));
                //existing Order Line Item record
                if(orderLineItems.containsKey('Weekdays')) {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'existing item ' + ow.counterWrap));
                    Order_Line_Item_Vendor__c orli = orderLineItems.remove('Weekdays').clone(true, false, false, false);
                    orLi.Wrapper_Number__c = ow.oLine.Wrapper_Number__c;
                    orLi.Mon__c = ow.oLine.Mon__c;
                    orLi.Tue__c = ow.oLine.Tue__c;
                    orLi.Wed__c = ow.oLine.Wed__c;
                    orLi.Thu__c = ow.oLine.Thu__c;
                    orLi.Fri__c = ow.oLine.Fri__c;
                    orLi.Sat__c = ow.oLine.Sat__c;
                    orLi.Sun__c = ow.oLine.Sun__c;
                    orLi.Phe__c = ow.oLine.Phe__c;
                    orLi.Phd__c = ow.oLine.Phd__c;
                    orLi.Start_Date__c = ow.oLine.Start_Date__c;
                    orLi.Stop_Date__c = ow.oLine.Stop_Date__c;
                    orLi.Order__c = order.Id; 
                    orLi.Publication__c = ow.oLine.Publication__c;
                    orInsertList.add(orLi);
                    //add to new map to replace old records
                    newOrderLineItems.put('Weekdays', orLi);
                }
                //new order line item record
                else {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'new item ' + ow.counterWrap));
                    Order_Line_Item_Vendor__c orLi = ow.oLine.clone(true, false, false, false);  
                    orLi.Order__c = order.Id;                 
                    orInsertList.add(orLi);
                    //add to new map to replace old records
                    newOrderLineItems.put('Weekdays', orLi);
                }               
            }
            //special publications
            else {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Special Publication ' + ow.counterWrap));
                //if monday-saturday issues has values
                if((ow.oLine.Mon__c != null && ow.oLine.Mon__c > 0) ||
                    (ow.oLine.Tue__c != null && ow.oLine.Tue__c > 0) ||
                    (ow.oLine.Wed__c != null && ow.oLine.Wed__c > 0) ||
                    (ow.oLine.Thu__c != null && ow.oLine.Thu__c > 0) ||
                    (ow.oLine.Fri__c != null && ow.oLine.Fri__c > 0) ||
                    (ow.oLine.Sat__c != null && ow.oLine.Sat__c > 0)) {
                    //existing record for regular issue
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'has entry for mon-sat ' + ow.counterWrap));
                    if(orderLineItems.containsKey('Weekdays')) {
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'existing item special weekday ' + ow.counterWrap));
                        Order_Line_Item_Vendor__c orli = orderLineItems.remove('Weekdays').clone(true, false, false, false);
                        orLi.Wrapper_Number__c = ow.oLine.Wrapper_Number__c;
                        orLi.Mon__c = ow.oLine.Mon__c;
                        orLi.Tue__c = ow.oLine.Tue__c;
                        orLi.Wed__c = ow.oLine.Wed__c;
                        orLi.Thu__c = ow.oLine.Thu__c;
                        orLi.Fri__c = ow.oLine.Fri__c;
                        orLi.Sat__c = ow.oLine.Sat__c;
                        orLi.Sun__c = 0; //zero-out value for sunday publication
                        orLi.Phe__c = ow.oLine.Phe__c;
                        orLi.Phd__c = ow.oLine.Phd__c;
                        //Start UD-3402 06-Jan-2016 Added by S.Puli - if start date input is sunday, move oli start date to next day for weekday pub
                        Date startForWD = ow.oLine.Start_Date__c;
                        Datetime startForWDT = datetime.newinstance(startForWD.year(), startForWD.month(), startForWD.day());
                        Datetime startFinalWDT;
                        if(startForWDT.format('E') == GlobalVariableClass.SUNDAY_UOM_STRING){
                            startFinalWDT = startForWDT.addDays(1);
                            orLi.Start_Date__c = date.newinstance(startFinalWDT.year(), startFinalWDT.month(), startFinalWDT.day());
                        }else{
                            orLi.Start_Date__c = ow.oLine.Start_Date__c;
                        }
                        //End UD-3402 06-Jan-2016 Added by S.Puli
                        orLi.Stop_Date__c = ow.oLine.Stop_Date__c;
                        orLi.Order__c = order.Id; 
                        orLi.Publication__c = ow.oLine.Publication__c;
                        orInsertList.add(orLi);
                        //add to new map to replace old records
                        newOrderLineItems.put('Weekdays', orLi);
                    }
                    //new record for regular issue
                    else {
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'new item special weekday' + ow.counterWrap));
                        Order_Line_Item_Vendor__c orLi = ow.oLine.clone(true, false, false, false);  
                        orLi.Order__c = order.Id;
                        orLi.Sun__c = 0; //zero-out value for sunday publication   
                        //Start UD-3402 06-Jan-2016 Added by S.Puli - if start date input is sunday, move oli start date to next day for weekday pub
                        Date startForWD = ow.oLine.Start_Date__c;
                        Datetime startForWDT = datetime.newinstance(startForWD.year(), startForWD.month(), startForWD.day());
                        Datetime startFinalWDT;
                        if(startForWDT.format('E') == GlobalVariableClass.SUNDAY_UOM_STRING){
                            startFinalWDT = startForWDT.addDays(1);
                            orLi.Start_Date__c = date.newinstance(startFinalWDT.year(), startFinalWDT.month(), startFinalWDT.day());
                        }else{
                            orLi.Start_Date__c = ow.oLine.Start_Date__c;
                        }
                        //End UD-3402 06-Jan-2016 Added by S.Puli
                        orInsertList.add(orLi);
                        //add to new map to replace old records
                        newOrderLineItems.put('Weekdays', orLi);
                    }
                }
                //if sunday issue has a value
                if(ow.oLine.Sun__c != null && ow.oLine.Sun__c > 0) {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'has entry for sun ' + ow.counterWrap));
                    //existing record for sunday issue
                    if(orderLineItems.containsKey('Weekends')) {
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'existing item sunday special ' + ow.counterWrap));
                        Order_Line_Item_Vendor__c orli = orderLineItems.remove('Weekends').clone(true, false, false, false);
                        orLi.Wrapper_Number__c = ow.oLine.Wrapper_Number__c;
                        orLi.Mon__c = 0; //zero-out value for weekday publication
                        orLi.Tue__c = 0; //zero-out value for weekday publication
                        orLi.Wed__c = 0; //zero-out value for weekday publication
                        orLi.Thu__c = 0; //zero-out value for weekday publication
                        orLi.Fri__c = 0; //zero-out value for weekday publication
                        orLi.Sat__c = 0; //zero-out value for weekday publication
                        orLi.Sun__c = ow.oLine.Sun__c; 
                        orLi.Phe__c = ow.oLine.Phe__c;
                        orLi.Phd__c = ow.oLine.Phd__c;
                        //Start UD-3402 06-Jan-2016 Added by S.Puli - if the start date for a sunday pub is not a sunday, move it to the next closest sunday
                        Date startD = ow.oLine.Start_Date__c;
                        Datetime startDT = datetime.newinstance(startD.year(), startD.month(), startD.day());
                        Datetime startFinalDT;
                        if(startDT.format('E') == GlobalVariableClass.SUNDAY_UOM_STRING){   
                            orLi.Start_Date__c = ow.oLine.Start_Date__c;
                        }else{
                            for(integer i=0;i<7;i++){
                                startFinalDT = startDT.addDays(i);
                                if(startFinalDT.format('E') == GlobalVariableClass.SUNDAY_UOM_STRING){
                                    break;
                                }
                            }
                            orLi.Start_Date__c = date.newinstance(startFinalDT.year(), startFinalDT.month(), startFinalDT.day());
                        }
                        //End UD-3402 06-Jan-2016 Added by S.Puli
                        orLi.Stop_Date__c = ow.oLine.Stop_Date__c;
                        orLi.Order__c = order.Id; 
                        //orLi.Publication__c = ow.oLine.Publication__c;
                        if(publicationIdToProductFamilyMap.containsKey(ow.oLine.Publication__c)) { //populate publication with sunday issue
                                //Start D-1755 01/28/15 Added by A BANAAG - use sunday publication
                                orLi.Publication__c = getSundayPublication(ow.oLine.Publication__c);
                                //End D-1755 01/28/15 Added by A BANAAG - use sunday publication
                        }
                        
                        //Start D-1755 01/28/15 Added by A BANAAG - add condition for error handling; OLI is not created if publication field is null
                        if(orLi.Publication__c!=null){
                            orInsertList.add(orLi);
                            //add to new map to replace old records
                            newOrderLineItems.put(GlobalVariableClass.CREATEVENDORSTART_WEEKEND, orLi);
                        }
                        //End D-1755 01/28/15 Added by A BANAAG - add condition for error handling; OLI is not created if publication field is null
                    }
                    //new record for sunday issue
                    else {
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'new record sunday special ' + ow.counterWrap));
                        Order_Line_Item_Vendor__c orLi = ow.oLine.clone(true, false, false, false);  
                        orLi.Order__c = order.Id;
                        orLi.Mon__c = 0; //zero-out value for weekday publication
                        orLi.Tue__c = 0; //zero-out value for weekday publication
                        orLi.Wed__c = 0; //zero-out value for weekday publication
                        orLi.Thu__c = 0; //zero-out value for weekday publication
                        orLi.Fri__c = 0; //zero-out value for weekday publication
                        orLi.Sat__c = 0; //zero-out value for weekday publication
                        if(publicationIdToProductFamilyMap.containsKey(ow.oLine.Publication__c)) { //populate publication with sunday issue
                                //Start D-1755 02/11/2015 added by ABanaag
                                orLi.Publication__c = getSundayPublication(ow.oLine.Publication__c); 
                                //End D-1755 02/11/2015 added by ABanaag
                        }
                        //Start UD-3402 06-Jan-2016 Added by S.Puli - if the start date for a sunday pub is not a sunday, move it to the next closest sunday
                        Date startD = ow.oLine.Start_Date__c;
                        Datetime startDT = datetime.newinstance(startD.year(), startD.month(), startD.day());
                        Datetime startFinalDT;
                        if(startDT.format('E') == GlobalVariableClass.SUNDAY_UOM_STRING){   
                        //retain
                        }else{
                            for(integer i=0;i<7;i++){
                                startFinalDT = startDT.addDays(i);
                                if(startFinalDT.format('E') == GlobalVariableClass.SUNDAY_UOM_STRING){
                                    break;
                                }
                            }
                            //System.assertEquals(startFinalDT.format('E'), 'a');
                            orLi.Start_Date__c = date.newinstance(startFinalDT.year(), startFinalDT.month(), startFinalDT.day());
                        }
                        //End UD-3402 06-Jan-2016 Added by S.Puli
                        orInsertList.add(orLi);
                        //add to new map to replace old records
                        newOrderLineItems.put('Weekends', orLi);
                    }
                }
            }
            
            //delete extra/unused line items    
            if(orderLineItems.values().size() > 0) {
                orDeleteList.addAll(orderLineItems.values());
            }
            
            //replace counterToLineItemsMap values
            newCounterToLineItemsMap.put(ow.counterWrap, newOrderLineItems);
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'newCounter ' + ow.counterWrap + ' ' + newCounterToLineItemsMap));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'oldCpunter ' + ow.counterWrap + ' ' + oldCounterToLineItemsMap));
            
        }
        
        if(!hasError) {
            try {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, String.valueOf(orInsertList)));
                upsert orInsertList;
                counterToLineItemsMap.putAll(newCounterToLineItemsMap);
                delete orDeleteList;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Saved successfully.'));
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'successful insert'));
            }
            catch(DmlException e) {
                counterToLineItemsMap.putAll(oldCounterToLineItemsMap);
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'failed insert'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getDmlMessage(0)));
            }
        }
        
        //replace counter to line items mapping
        orInsertList = new List<Order_Line_Item_Vendor__c>();
        orDeleteList = new List<Order_Line_Item_Vendor__c>(); 
        
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'counter: ' + String.valueOf(counterToLineItemsMap)));
        PageReference pRef = new PageReference('/apex/ViewVendorOrderEntry?accountId=' + order.Account__c);
        return pRef;
    }
    
                 
    public PageReference cancel() {
        if(objCase.Id != null) {
            List<sObject> updateList = new List<sObject>();
            objCase.Status = 'Void';
            updateList.add(objCase);
            order.Status__c = 'Void';
            updateList.add(order);
            update updateList;
        }
        else if(order.Id != null) {
            delete order;
        }
        
        PageReference pageRef;
        if(accountId != null) {
            pageRef = new PageReference('/' + accountId);
        }
        else {
            pageRef = new PageReference('/001/o');
        }
        return pageRef;
    }
     
    public void refreshStyleClass() {
        Integer param = Integer.valueOf(index);
        
        for(Integer i=0; i<orWrapperList.size(); i++){
            if(orWrapperList[i].counterWrap == param){
                if((orWrapperList[i].oLine.Mon__c == null || orWrapperList[i].oLine.Mon__c <= 0) &&
                    (orWrapperList[i].oLine.Tue__c == null || orWrapperList[i].oLine.Tue__c <= 0) &&
                    (orWrapperList[i].oLine.Wed__c == null || orWrapperList[i].oLine.Wed__c <= 0) &&
                    (orWrapperList[i].oLine.Thu__c == null || orWrapperList[i].oLine.Thu__c <= 0) &&
                    (orWrapperList[i].oLine.Fri__c == null || orWrapperList[i].oLine.Fri__c <= 0) &&
                    (orWrapperList[i].oLine.Sat__c == null || orWrapperList[i].oLine.Sat__c <= 0) &&
                    (orWrapperList[i].oLine.Sun__c == null || orWrapperList[i].oLine.Sun__c <= 0)) {
                    orWrapperList[i].styleClass = 'error';
                }
                else {
                    orWrapperList[i].styleClass = 'day';
                }
            }
        }
    }       
     
    public PageReference submit() {  
        //save order line items
        dtlDate = SM_SubscriptionHelper.getDtlDate(); // Start/End UD-1451 16Jun15 RReyes
        saveDraft();
        
        try {
                //Check urgent line items
                Identify_Urgent_OrderLineItem  identify = new Identify_Urgent_OrderLineItem();
                Boolean isUrgent = identify.Identify_Urgent_OrderLineItem(new List<Order__c>{order}, false);
                //Assign items to vendor
    //START D-3382 CCB-135 04/Aug/15 Wenjun: Add Query Fields
                List<Order_Line_Item_Vendor__c> oLineItems = [SELECT Id, Recipient_Postal_Code__c, Start_Date__c, Wrapper_Number__c, Stop_Date__c,
                      Publication__c, Order__r.Recipient_Contact__r.Address__r.Recordtype.DeveloperName 
                      FROM Order_Line_Item_Vendor__c WHERE Order__c = :order.Id];
    //END D-3382 CCB-135 04/Aug/15 Wenjun
                Vendor_Assignment vAssign = new Vendor_Assignment();
                vAssign.Assign_Vendor_To_Order_Line_Items(oLineItems);
                
                //call method to create case
                CreateCase cCase = new CreateCase(); 
                objCase = cCase.createCase2(new List<Order__c>{order}, false)[0];
//START: D-1456 Added by ABanaag - populate values of DTL Date fields in order and OLIV                
                // Start UD-1451 16Jun15 - commented out by RReyes
                /*
                order.DTL_Date__c = SM_SubscriptionHelper.getDtlDate();
                update order;
                System.debug('April debug | Order ID : ' + order.Id + '; Order DTL DATE' + string.valueOf(order.DTL_Date__c));
                */
                // End UD-1451 16Jun15 - commented out by RReyes
                
                List<Order_Line_Item_Vendor__c > orderLIs = [SELECT id, DTL_Date__c from Order_Line_Item_Vendor__c where Order__c = :order.Id];
                    if(!orderLIs.isEmpty())
                    {
                        for(Order_Line_Item_Vendor__c orderLI : orderLIs)
                        {
                            // orderLi.DTL_Date__c = SM_SubscriptionHelper.getDtlDate(); // Start/End UD-1451 16Jun15 - commented out by RReyes
                            orderLi.DTL_Date__c = dtlDate; //Start/End UD-1451 16Jun15 RReyes
                            update OrderLi;
                            System.debug('April debug | OLIV ID: ' + orderLi.Id + '; DTL DATE' + string.valueOf(orderLi.DTL_Date__c ));
                        }
                        //updateOrderLineItemGifts(orderLIs);
                    }
//END: D-1456 Added by ABanaag - populate values of DTL Date fields in Order and OLIV                   
        }
        catch(Exception e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + e.getStackTraceString()));
                return null;
        }
        PageReference pRef = new PageReference('/' + objCase.Id);
        return pRef;    
    }
        

    public PageReference edit() {
        PageReference pRef = Page.CreateVendorOrderEntry;
        pRef.getParameters().put('accId', order.Account__c);
        pRef.getParameters().put('id', order.Id);
        return pRef;
    }
    
    //START D-1280 18/12/14 Wenjun
    //Action Support Method - when selecting a Publication
    public PageReference changePublication() {
        Integer param = Integer.valueOf(index);
        //Start D-1749 01/26/15 Added by A BANAAG : map PHE and PHW values to Publication
        mapPubIdToPhe = new Map<id,double> ();
        mapPubIdToPhw = new Map<id,double> ();
        set<id> pubIdSet = new set<id>();
        
        //populate pubIdSet
        if(orWrapperList.size()>0){
            for (orWrapper o:orWrapperList){
                if(o.oLine.Publication__c!=null){
          //Start MMallorca D-3137 Exclude sunday publications 06/26/2015
          for(Id sundayId : sundayPubs){
            if(sundayId == o.oLine.Publication__c){
              o.oLine.Publication__c = null;
              ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, '' + ConstantsSLB.getErrorMessage('PublicationNotMain'));
              ApexPages.addMessage(msg);
              return null;
            }
          }
                    pubIdSet.add(o.oLine.Publication__c);
          //End MMallorca D-3137 06/26/2015
        }   
            }
        }
        //populate mapPubIdToPhe & mapPubIdToPhw
        if(pubIdSet.size()>0){
            for (Publication__c pub : [SELECT Id, Cover_Price_PHE__c, Cover_Price_PHW__c from Publication__c WHERE ID IN:pubIdSet]){
                mapPubIdToPhe.put(pub.Id,pub.Cover_Price_PHE__c);
                mapPubIdToPhw.put(pub.Id,pub.Cover_Price_PHW__c);
            }
        }
        //End D-1749 01/26/15 Added by A BANAAG : map PHE and PHW values to Publication
        
        for(Integer i=0; i<orWrapperList.size(); i++)
        {
            if(orWrapperList[i].counterWrap == param){
                OrWrapper OrWrap = orWrapperList[i];
                ID pubID = orWrapperList[i].oLine.Publication__c;
                if(pubID != NULL)
                {
                    String productFamily = publicationIdToProductFamilyMap.get(pubID);
                    //Start D-1755 02/11/2015 Added by ABanaag 
                    if(getSundayPublication(pubID) != NULL) //Having differnt Sunday Publication 
                    //End D-1755 02/11/2015 Added by ABanaag 
                    {  
                       PublicationPattern primaryPattern = publicationIdToPatternMap.get(pubID);
                       //Start D-1755 Added by A Banaag - use sunday publication
                       PublicationPattern secondPattern = publicationIdToPatternMap.get(getSundayPublication(pubID));
                       //End D-1755 Added by A Banaag - use sunday publication
                        if(primaryPattern != NULL && secondPattern != NULL)
                        {
                             OrWrap.oLine.Mon__c = (primaryPattern.isMon || secondPattern.isMon) ? 1 : 0;
                             OrWrap.oLine.Tue__c = (primaryPattern.isTue || secondPattern.isTue) ? 1 : 0;
                             OrWrap.oLine.Wed__c = (primaryPattern.isWed || secondPattern.isWed) ? 1 : 0;
                             OrWrap.oLine.Thu__c = (primaryPattern.isThu || secondPattern.isThu) ? 1 : 0;
                             OrWrap.oLine.Fri__c = (primaryPattern.isFri || secondPattern.isFri) ? 1 : 0;
                             OrWrap.oLine.Sat__c = (primaryPattern.isSat || secondPattern.isSat) ? 1 : 0;
                             OrWrap.oLine.Sun__c = (primaryPattern.isSun || secondPattern.isSun) ? 1 : 0;
                             //START UD-0134 3/3/15 AddedBy FrancisBenzon
                             //Start D-1749 Added by A BANAAG : get values from Publication object                       
                             OrWrap.oLine.Phe__c = 0;  // Start/End UD-1188 12May15 JohnD - set Phe to zero         
                             OrWrap.oLine.Phd__c = ((primaryPattern.isPHd || secondPattern.isPHd) && (mapPubIdToPhw.containsKey(pubId))) ? 1 : 0;
                             //End D-1749 Added by A BANAAG : get values from Publication object
                             //END UD-0134 3/3/15 AddedBy FrancisBenzon
                             //Set Pattern for disbale user input
                             OrWrap.pattern = mergePattern(primaryPattern,secondPattern);
                        }
                    }
                    else
                    {
                        PublicationPattern pattern = publicationIdToPatternMap.get(pubID);
                        OrWrap.pattern = pattern;
                        if(pattern != NULL)
                        {
                             OrWrap.oLine.Mon__c = pattern.isMon ? 1 : 0;
                             OrWrap.oLine.Tue__c = pattern.isTue ? 1 : 0;
                             OrWrap.oLine.Wed__c = pattern.isWed ? 1 : 0;
                             OrWrap.oLine.Thu__c = pattern.isThu ? 1 : 0;
                             OrWrap.oLine.Fri__c = pattern.isFri ? 1 : 0;
                             OrWrap.oLine.Sat__c = pattern.isSat ? 1 : 0;
                             OrWrap.oLine.Sun__c = pattern.isSun ? 1 : 0;
                             //START UD-0134 3/3/15 AddedBy FrancisBenzon 
                             //Start D-1749 Added by A BANAAG : get values from Publication object
                             OrWrap.oLine.Phd__c = (pattern.isPHd && mapPubIdToPhe.containsKey(pubId)) ? 1 : 0;
                             OrWrap.oLine.Phe__c = (pattern.isPHe && mapPubIdToPhw.containsKey(pubId)) ? 1 : 0;
                             //End D-1749 Added by A BANAAG : get values from Publication object
                             //END UD-0134 3/3/15 AddedBy FrancisBenzon
                        }
                    }
                } //END OF IF if(pubID != NULL)
            }//End of IF
        }
        return null;
    }
    
    private PublicationPattern generatePattern(Publication__c publication)
    {
        String publishDays = publication.Published_Days__c;
        
        PublicationPattern pattern = new PublicationPattern();
        pattern.isPHd = publication.Public_Holiday_Weekday_Pub_Indicator__c;
        pattern.isPHe = publication.Public_Holiday_Weekend_Pub_Indicator__c;
        try
        {
            pattern.isMon = publishDays.mid(0,1) == 'Y'? true : false;
            pattern.isTue = publishDays.mid(1,1) == 'Y'? true : false;
            pattern.isWed = publishDays.mid(2,1) == 'Y'? true : false;
            pattern.isThu = publishDays.mid(3,1) == 'Y'? true : false;
            pattern.isFri = publishDays.mid(4,1) == 'Y'? true : false;
            pattern.isSat = publishDays.mid(5,1) == 'Y'? true : false;
            pattern.isSun = publishDays.mid(6,1) == 'Y'? true : false;
            //START: UD-1358 05/28/2015 Jean Cariño Added Logic for PHd and PHe
            // Start UD-1188 12May15 JohnD - replaced logic for Sunday pub
            if (pattern.isSat || (pattern.isSun && pattern.isSat)) {
            pattern.isPHe = true;
            } else {
            pattern.isPHe = false;
            }
            if (pattern.isMon || pattern.isTue || pattern.isWed || pattern.isThu || pattern.isFri) {
                pattern.isPHd = true;
                } else {
            pattern.isPHd = false;
            }            
            // End UD-1188 12May15 JohnD - replaced logic for Sunday pub
            //END: UD-1358 05/28/2015 Jean Cariño Added Logic for PHd and PHe
        }
        Catch (Exception e)
        {
            System.debug(System.LoggingLevel.ERROR,e.getMessage());
            throw new CustomException(System.Label.ERR_PUB_CONFIG);
        }
        return pattern;
    }
    
    private PublicationPattern mergePattern(PublicationPattern primaryPattern,PublicationPattern secondPattern)
    {
        PublicationPattern pattern = new PublicationPattern();
        pattern.isMon = primaryPattern.isMon || secondPattern.isMon? true : false;
        pattern.isTue = primaryPattern.isTue || secondPattern.isTue? true : false;
        pattern.isWed = primaryPattern.isWed || secondPattern.isWed? true : false;
        pattern.isThu = primaryPattern.isThu || secondPattern.isThu? true : false;
        pattern.isFri = primaryPattern.isFri || secondPattern.isFri? true : false;
        pattern.isSat = primaryPattern.isSat || secondPattern.isSat? true : false;
        pattern.isSun = primaryPattern.isSun || secondPattern.isSun? true : false; 
        pattern.isPHd = primaryPattern.isPHd || secondPattern.isPHd? true : false;
        pattern.isPHe = primaryPattern.isPHe || secondPattern.isPHe? true : false; 
        return pattern;
    }
    
    //Wrapper Class for Publication Pattern
    public Class PublicationPattern
    {
        public Boolean isMon {get; set;}
        public Boolean isTue {get; set;}
        public Boolean isWed {get; set;}
        public Boolean isThu {get; set;}
        public Boolean isFri {get; set;}
        public Boolean isSat {get; set;}
        public Boolean isSun {get; set;}
        public Boolean isPHd {get; set;}
        public Boolean isPHe {get; set;}
    }
    //END D-1280
    
    //Start D-1755 01/28/15 Added by A BANAAG 
    /**
    * Method Name : getSundayPublication
    * @author April Banaag
    * @param Publication ID
    * @description returns the value of Sunday Publication field of the record passed in param
    **/
    private ID getSundayPublication(ID specialPublicationId){
       
        Publication__c specialPublication = [SELECT Sunday_Publication__c, id from Publication__c WHERE id =: specialPublicationId];
        id matchingPubId;
        if(specialPublication.Sunday_Publication__c!=null){
            matchingPubId = specialPublication.Sunday_Publication__c;
        }
        return matchingPubId;
    }
    //End D-1755 01/28/15 Added by A BANAAG 
    
    
    // Start D-2040 02/05/2015 JohnD
    /*
    * @description : this method will retrieve the pre-configured delivery charge from custom settings
    */
    public void populateDeliveryCharge() {
        
        if (order.Recipient_Contact__c != null) {   
            try {
                
                string addressType = [select Address__r.Address_Type__c from Contact where Id = :order.Recipient_Contact__c].Address__r.Address_Type__c;
                order.Delivery_Charge_Type__c = ConstantsSLB.getDefaultDeliveryChargeType(addressType);         
                
                map<string, decimal> charges = SM_SubscriptionHelper.getCharges(order.Recipient_Contact__c, order.Delivery_Charge_Type__c, null, null);
                
                order.Delivery_Charge__c = charges.get(DELIVERY_CHARGE_KEY);
            } catch (exception e) {
                ExceptionLogger.log(new list<exception> { e });
            }
        }
    }
    // End D-2040 02/05/2015 JohnD
}