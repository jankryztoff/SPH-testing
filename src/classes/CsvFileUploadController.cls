/*
 * History: D-1864 21/01/2015 Wenjun
 */
public class CsvFileUploadController{

	
	
  public Document document{
    get{
      if(document == null)
        document = new Document();
      return document;
    }
    set;
  }
 
  public pageReference upload(){

    PageReference PageRef;  
    document.AuthorId = UserInfo.getUserId();
    document.FolderId = UserInfo.getUserId(); // put it in running user's folder
 
    try{
      insert document;
    }catch(DMLException e){
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));
      return null;
    }
 
    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'File uploaded successfully'));

    PageRef = new PageReference('/apex/CsvFileUploadPage?Id='+document.Id); 
    return PageRef; 
  }
  
  public pageReference parseCsv(){
  	
  	

    String docIdStr = System.currentPagereference().getParameters().get('Id');
    List<Account> accountList = new List<Account>();
    List<Contact> contactList = new List<Contact>();
    List<Contact> billingContactList = new List<Contact>(); 
    List<Order__c> orderList = new List<Order__c>();
    List<Address__c> addressList = new List<Address__c>();
    List<Address__c> billingAddressList = new List<Address__c>();
    //START D-1864 21/01/15 Wenjun: Remove unused code
    //List<Order_Line_Item__c> orderLineItemList;
    //END D-1864 21/01/15 Wenjun
    List<Order_Line_Item__c> orderLineItemsList = new List<Order_Line_Item__c>();
    Map<Integer,Account> contact_account_Map = new Map<Integer,Account>(); 
    Map<Integer,Address__c> contact_address_Map = new Map<Integer,Address__c>();
    Map<Integer,Address__c> billingContact_address_Map = new Map<Integer,Address__c>();
    Map<Integer,Order__c> oli_order_Map = new Map<Integer,Order__c>();
    Map<String,Id> postal_singpostId_Map = new Map<String,Id>();  
    Map<Address__c,String> address_postal_Map = new Map<Address__c,String>(); 
	//START D-1864 21/01/15 Wenjun: Fix existing bug - cannot use Map<Order_Line_Item__c, String>
    Map<Integer,String> oli_MainPackageID_Map = new Map<Integer,String>();
	//END D-1864 21/01/15 Wenjun
    Map<String,Id> packageName_packageId_map = new Map<String,Id>();  
    
    Map<Integer,Account> order_account_Map = new Map<Integer,Account>();    
    Map<Integer,Address__c> order_address_Map = new Map<Integer,Address__c>(); 
    Map<Integer,Contact> order_contact_Map = new Map<Integer,Contact>();
    Map<Integer,Contact> order_billingcontact_Map = new Map<Integer,Contact>(); 
    
    //START: D-1140 12/12/14 Added by J.Sarion � Order Upload added variable
    Map<Order__c, Boolean> orderToIfSameContactMap = new Map<Order__c, Boolean>();
    Map<Contact, Account> contactToAccountMap = new Map<Contact, Account>();
    Map<Contact, Address__c> billContactToAddressMap = new Map<Contact, Address__c>();
    //END: D-1140 12/12/14 Added by J.Sarion
    
    //START D-1864 21/01/15 Wenjun: New Variable for storing Order ID to Recipient Contact
    Map<Id,Id> mapOrderIdToContactId = new Map<Id,Id>();
    //END D-1864 21/01/15 Wenjun
	// Start UD-2865 24Sep15 - JohnD
  	integer orderLimit;
  	try {
  		orderLimit = integer.valueOf(ConstantsSLB.getOther('Maximum Order for File Upload'));
  	} catch (exception e) {
  		orderLimit = 50;
  	}
	// End UD-2865 24Sep15 - JohnD
    Order_Line_Item__c oli;
    Savepoint sp;
    
    Set<Id> orderIdSet = new Set<Id>();
    Set<String> quoteNameSet = new Set<String>();

        try{

            sp = Database.setSavepoint();
        
            if(docIdStr != null){     
                
                Document document = [SELECT Id, Body, Name FROM Document WHERE ID =: docIdStr];	// Start/End UD-2865 24Sep15 JohnD - added Name
                
                if(document != null){
                    
                    List<List<string>> ls = CSVReader.Parse(document.body.toString());
                    ls.remove(0);
                    Integer counter_OLI = 0;
                    Integer counter_Order = 0;
                     
                    if(ls.size() <= orderLimit){	// Start/End UD-2865 24Sep15 JohnD
                    	
                        Country__c countrySIN = getCountryObjForSIN();  // Start/End UD-2865 21Sep15 JohnD
                        
                        for(List<String> listStr:ls){
                            //START: D-1140 12/12/14 Added by J.Sarion � Check if contact is for Billing and Recipient
                            Boolean sameContact = false;
                            Address__c billingAddressObject;
                            Contact billingContactObject;
                            //END: D-1140 12/12/14 Added by J.Sarion
                            
                            String accountStr = 'Account_'+listStr[5];
                            Account accountObject = new Account();
                            accountObject.Name = listStr[0];
                            accountObject.NRIC__c = listStr[1];
                            accountObject.Email__c = listStr[2];
                            accountObject.Phone = listStr[3];
                            accountObject.Mobile__c = listStr[4];
                            if(listStr[5] != null){
                                accountObject.RecordTypeId = ConstantsSLB.getKeyId(accountStr);
                            }
                            if(listStr[6] != null){
                                accountObject.Date_of_Birth__c = setStringToDateFormat(listStr[6]);
                            }
                            accountObject.Gender__c = listStr[7];   
                            accountList.add(accountObject);
                            
                            //START: D-1140 12/12/14 Added by J.Sarion � Check if contact is for Billing and Recipient
                            // Start UD-2865 24Sep15 JohnD - added listStr[13] == '' ||
                            if (listStr[13] == '' || (listStr[8] == listStr[13] && listStr[9] == listStr[14] && listStr[10] == listStr[15] 
                            		&& listStr[11] == listStr[16] && listStr[12] == listStr[17] && listStr[19] == listStr[24] 
                            		&& listStr[20] == listStr[25] && listStr[21] == listStr[26] && listStr[22] == listStr[27] 
                            		&& listStr[18] == listStr[23])) {
                            			
                                sameContact = true;
                            }
                            system.debug('>>>>>sameContact ' + sameContact);
                            // End UD-2865 24Sep15 JohnD - added listStr[13] == '' ||
                            //END: D-1140 12/12/14 Added by J.Sarion

                            Contact contactObject = new Contact();
                            contactObject.FirstName = listStr[8];
                            contactObject.LastName = listStr[9];
                            contactObject.HomePhone__c = listStr[10];
                            contactObject.Mobile_Number__c = listStr[11];
                            contactObject.Email__c = listStr[12];
                            contactObject.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                            contactObject.Recipient_Indicator__c = true;
                            //START: D-1140 12/12/14 Added by J.Sarion � Set Billing Indicator to True
                            if (sameContact) {
                                contactObject.Billing_Indicator__c = true;
                            }
                            //END: D-1140 12/12/14 Added by J.Sarion
                            contactList.add(contactObject);
                            
                            //START: D-1140 12/12/14 Added by J.Sarion � Create Billing Contact for the account
                            if (!sameContact) {
                                billingContactObject = new Contact();
                                billingContactObject.FirstName = listStr[13];
                                billingContactObject.LastName = listStr[14];
                                billingContactObject.HomePhone__c = listStr[15];
                                billingContactObject.Mobile_Number__c = listStr[16];
                                billingContactObject.Email__c = listStr[17];
                                billingContactObject.RecordTypeId = ConstantsSLB.getKeyId('Contact_Customer Contact');
                                billingContactObject.Billing_Indicator__c = true;   
                                contactToAccountMap.put(billingContactObject, accountObject);
                                billingContactList.add(billingContactObject);
                            }
                            //END: D-1140 12/12/14 Added by J.Sarion
                            
                            //START D-1864 21/01/15 Wenjun : Get Country Record for Singapore
                            // Country__c countrySIN = getCountryObjForSIN();   // Start/End UD-2865 21Sep15 JohnD - moved to outside this loop
                            //END D-1864 21/01/15 Wenjun
							
                            Address__c addressObject = new Address__c();
                            
                            addressObject.Block_House_Number__c = listStr[19];    
                            addressObject.Level_Number__c = listStr[20];
                            addressObject.Unit_Number__c = listStr[21];
                            addressObject.Address_Type__c = listStr[22];
                            //START D-1864 21/01/15 Wenjun : Set Country as Singapore
                            addressObject.Country__c = countrySIN.Id;
                            //END D-1864 21/01/15 Wenjun
                            //START D-2555 01/06/2015 Added By C. Lin - populate address_postal_Map after addressObject is assigned
                            address_postal_Map.put(addressObject,listStr[18]);
                            //END D-2555 01/06/2015 Added By C. Lin
                            addressList.add(addressObject);

                            //START: D-1140 12/12/14 Added by J.Sarion � Create Address for the Billing Contact
                            if (!sameContact) {
                                billingAddressObject = new Address__c();
                                
                                billingAddressObject.Block_House_Number__c = listStr[24];    
                                billingAddressObject.Level_Number__c = listStr[25];
                                billingAddressObject.Unit_Number__c = listStr[26];
                                billingAddressObject.Address_Type__c = listStr[27];
                                //START D-1864 21/01/15 Wenjun : Set Country as Singapore
                            	billingAddressObject.Country__c = countrySIN.Id;
                            	//END D-1864 21/01/15 Wenjun
                                billContactToAddressMap.put(billingContactObject, billingAddressObject);
                                system.debug('>>>>>billContactToAddressMap ' + billContactToAddressMap);
                                //START D-2555 01/06/2015 Added By C. Lin - populate address_postal_Map after addressObject is assigned
                                address_postal_Map.put(billingAddressObject,listStr[23]);
                                //END D-2555 01/06/2015 Added By C. Lin
                                addressList.add(billingAddressObject);
                            }
                            //END: D-1140 12/12/14 Added by J.Sarion
                            
                            Order__c orderObject = new Order__c(); 
                            if(listStr[28] != null && listStr[28] != ''){            
                                orderObject.Subscription_Start_Date__c = setStringToDateFormat(listStr[28]);
                            }
                            if(listStr[29] != null && listStr[29] != ''){            
                                orderObject.Subscription_End_Date__c = setStringToDateFormat(listStr[29]);
                            }
                            orderObject.Delivery_Charge_Type__c = listStr[30];
                            orderObject.Payment_Mode__c = listStr[31];
                            if(listStr[32] != null && listStr[32] != ''){            
                                orderObject.Vendor_Credit__c = Decimal.valueOf(listStr[32]);
                            }
                            if(listStr[33] != null && listStr[33] != ''){            
                                orderObject.Credit_Balance__c = Decimal.valueOf(listStr[33]);
                            }
                            if(listStr[34] != null && listStr[34] != ''){            
                                orderObject.Check_Amount__c = Decimal.ValueOf(listStr[34]);
                            }
                            if(listStr[35] != null && listStr[35] != ''){            
                                orderObject.Check_Dated__c = setStringToDateFormat(listStr[35]);
                            }
                            if(listStr[36] != null && listStr[36] != ''){            
                                orderObject.Check_Issuing_Bank__c = listStr[36];
                            }
                            orderObject.Check_No__c = listStr[37]; 
                            orderObject.Acquisition_Type__c = 'ROAD SHOW';
                            orderObject.Creation_Mode__c = 'Others';
                            orderObject.Subject__c = document.Name + ' - R' + string.valueOf(counter_Order + 1);	// Start/End UD-2865 24Sep15 JohnD - do not remove this
                            //START: D-1140 12/12/14 Added by J.Sarion � Mapping if Order have the same contact for Billing and Recipient
                            orderToIfSameContactMap.put(orderObject, sameContact);
                            //END: D-1140 12/12/14 Added by J.Sarion
                            orderList.add(orderObject);
                            
                                             
                            for(Integer i=38;i<listStr.size();i+=9){
                                //START D-1864 21/01/15 Wenjun: Remove unused code
                                //orderLineItemList = new List<Order_Line_Item__c>();
                                //END D-1864 21/01/15 Wenjun
                                
                                oli = new Order_Line_Item__c();
                                if(listStr[i] != null){
                                    oli.Earliest_Start_Date__c = setStringToDateFormat(listStr[i]);
                                }
                                if(listStr[i+1] != null){
                                    oli.Start_Date__c = setStringToDateFormat(listStr[i+1]);
                                }
                                if(listStr[i+2] != null){
                                    oli.Main_Package_Period__c = integer.valueOf(listStr[i+2]);
                                }
                                if(listStr[i+3] != null){
                                    oli.Qty__c = integer.valueOf(listStr[i+3]);
                                }
                                if(listStr[i+4] != null){
                                    oli.Term_Length__c = integer.valueOf(listStr[i+4]);
                                }
                                //START D-1864 21/01/15 Wenjun: Fix existing bug
                                oli_MainPackageID_Map.put(counter_OLI,listStr[i+5]);
                                //END D-1864 21/01/15 Wenjun
                                oli.Main_Package_Billing_Type__c = listStr[i+6];
                                oli.Main_Package_Type__c = listStr[i+7];
                                oli.Delivered_By__c = listStr[i+8];
                                
                                //START D-1864 21/01/15 Wenjun: Remove unused code
                                //orderLineItemList.add(oli);
                                //END D-1864 21/01/15 Wenjun
                                orderLineItemsList.add(oli); 
                                oli_order_Map.put(counter_OLI,orderObject);         
                                counter_OLI++;
                            }

                            contact_account_Map.put(counter_Order,accountObject);
                            contact_address_Map.put(counter_Order,addressObject);
                            order_account_Map.put(counter_Order,accountObject);
                            order_address_Map.put(counter_Order,addressObject);
                            order_contact_Map.put(counter_Order,contactObject);
                            //START: D-1140 12/12/14 Added by J.Sarion � Check if same Contact for Billing and Recipient
                            if (!sameContact) {
                                billingContact_address_Map.put(counter_Order,billingAddressObject);
                                order_billingcontact_Map.put(counter_Order,billingContactObject);
                            }
                            //END: D-1140 12/12/14 Added by J.Sarion
                            counter_Order++;

                        }
                                                                                                   
                        if(address_postal_Map != null){
                            for(Singpost_Address__c singpost:[SELECT Id, Name FROM Singpost_Address__c WHERE Name IN: address_postal_Map.values()]){
                                postal_singpostId_Map.put(singpost.Name,singpost.Id);
                            }
                        }
                        
                        for(Address__c addressObj:addressList){
                            if(addressObj != null){
                                String postalStr = address_postal_Map.get(addressObj); 
                                if(postalStr != null){
                                    addressObj.Postal_Code__c = postal_singpostId_Map.get(postalStr);               
                                }
                            }
                        }

                        insert addressList;
                                
                        insert accountList;
                        
                        counter_Order = 0;
                        for(Contact contactObj:contactList){
                            if(contactObj != null){
                                if(order_account_Map != null){
                                    Account accObj = order_account_Map.get(counter_Order);
                                    if(accObj != null){
                                        contactObj.AccountId = accObj.Id; 
                                    }   
                                }
                                                                     
                                if(contact_address_Map != null){
                                    contactObj.Address__c  = contact_address_Map.get(counter_Order).Id;
                                }
                            }
                            counter_Order++;
                        }
                        
                        insert contactList;
                        
                        counter_Order = 0;
                        
                        //START: D-1140 12/12/14 Added by J.Sarion � Tie Contact to Account and check if billingContactList is not empty
                        for(Contact billConObj:billingContactList){
                            Address__c address = billContactToAddressMap.get(billConObj);
                            if(billConObj != null){
                                if (contactToAccountMap.containsKey(billConObj)) {
                                    Account accObj = contactToAccountMap.get(billConObj);
                                    if(accObj != null){
                                        billConObj.AccountId = accObj.Id;
                                        billContactToAddressMap.put(billConObj, address);
                                    }
                                }
                                                                     
                                if(billContactToAddressMap != null){
                                    if (billContactToAddressMap.containsKey(billConObj)) {
                                        billConObj.Address__c  = billContactToAddressMap.get(billConObj).Id;
                                    }
                                }
                            }
                            
                            counter_Order++;
                        }
                        if (!billingContactList.isEmpty()) {
                            insert billingContactList;             
                        }
                        //END: D-1140 12/12/14 Added by J.Sarion
                        
                        counter_Order = 0;
                        for(Order__c orderObj:orderList){
                            Decimal zoneCharge;               
                            Address__c addObj = new Address__c();
                            Boolean ifSameContact = false; // Start/End UD-2865 19Sep15 JohnD - set to false
                            
                            if (orderToIfSameContactMap.containsKey(orderObj)) {
                                ifSameContact = orderToIfSameContactMap.get(orderObj);
                            }
                            if(orderObj != null){
                                if(order_account_Map.get(counter_Order) != null){ 
                                    orderObj.Account__c = order_account_Map.get(counter_Order).Id; 
                                }

                                if(order_contact_Map != null){
                                    Contact conObj = order_contact_Map.get(counter_Order);
                                    if(conObj != null){                           
                                        orderObj.Recipient_Contact__c = conObj.Id;
                                        //START: D-1140 12/12/14 Added by J.Sarion � If same contact, Billing Contact is the same with Recipient
                                        if (ifSameContact) {
                                            orderObj.Billing_Contact__c = conObj.Id;
                                            system.debug('>>>>>orderObj.Billing_Contact__c ' + conObj);
                                            system.debug('>>>>>orderObj.Recipient_Contact__c ' + conObj);
                                        }
                                        //END: D-1140 12/12/14 Added by J.Sarion
                                    }
                                }  
                                
                                //START: D-1140 12/12/14 Added by J.Sarion � Check if same contact for Billing and Recipient
                                if (!ifSameContact) {
                                    if (order_billingcontact_Map != null) {
                                        Contact bconObj = order_billingcontact_Map.get(counter_Order);
                                        if(bconObj != null){                           
                                            orderObj.Billing_Contact__c = bconObj.Id;
                                            system.debug('>>>>>orderObj.Billing_Contact__c ' + bconObj);
                                        }
                                    }
                                }
                                //END: D-1140 12/12/14 Added by J.Sarion
                                        
                                if(order_address_Map.get(counter_Order) != null){                           
                                    addObj = order_address_Map.get(counter_Order);
                                }                       
                                system.debug('>>>>>>>>>>>>>>Address_Type__c' + addObj.Address_Type__c);
                                if(addObj.Address_Type__c != null){
                                    String deliveryChargeTypeStr;
                                    if (ConstantsSLB.getDefaultDeliveryChargeType(addObj.Address_Type__c) != null) {
                                        deliveryChargeTypeStr = ConstantsSLB.getDefaultDeliveryChargeType(addObj.Address_Type__c);
                                    }
                                    else {
                                        orderObj.Delivery_Charge__c = 0;
                                        orderObj.Monthly_Delivery_Charge_for_Full_Payment__c = 0;
                                    }
                                    system.debug('>>>>>>>>>>>>>>deliveryChargeTypeStr' + deliveryChargeTypeStr);
                                    if(deliveryChargeTypeStr != null){
                                        orderObj.Delivery_Charge__c = (ConstantsSLB.getSubscriberCharge(addObj.Address_Type__c+deliveryChargeTypeStr) != null ? ConstantsSLB.getSubscriberCharge(addObj.Address_Type__c+deliveryChargeTypeStr) : 0);
                                        orderObj.Monthly_Delivery_Charge_for_Full_Payment__c = (ConstantsSLB.getSubscriberCharge(addObj.Address_Type__c+deliveryChargeTypeStr) != null ? ConstantsSLB.getSubscriberCharge(addObj.Address_Type__c+deliveryChargeTypeStr) : 0);
                                    }
                                }
                                else{
                                    system.debug('>>>>>>>>>>>>>>Adress Type Null');
                                   orderObj.Delivery_Charge__c = 0.00;
                                   orderObj.Monthly_Delivery_Charge_for_Full_Payment__c = 0.00;
                                }  

                                if(addObj.Zonal_Code__c != null){
                                    orderObj.Zone_Charge__c = ConstantsSLB.getPostageCharge(addObj.Zonal_Code__c);
                                }
                            }
                            counter_Order++;
                        }  
                                       
                        insert orderList;
                        system.debug('>>>>>>>>>>>>>>>>oli_mainpackageid_Map: ' + oli_MainPackageID_Map);
                        
                        //START D-1864 21/01/15 Wenjun: Populate the Contact Map
                        for(Order__c orderObj : orderList)
                            mapOrderIdToContactId.put(orderObj.ID, orderObj.Recipient_Contact__c);
                        //END D-1864 21/01/15 Wenjun
    
                        if(oli_MainPackageID_Map != null){              
                            for(Package__c packageObj:[SELECT Id, Name FROM Package__c WHERE Name IN: oli_MainPackageID_Map.values()]){
                                packageName_packageId_map.put(packageObj.Name,packageObj.Id);     
                            }
                        }
                        system.debug('>>>>>>>>>>>>>>>>packageName_packageId_map: ' + packageName_packageId_map);

                        counter_OLI = 0;
                        for(Order_Line_Item__c oliObject:orderLineItemsList){
                            if(oliObject != null){
							    //START D-1864 21/01/15 Wenjun: Fix existing bug - cannot use Map<Order_Line_Item__c, String>
                                if(oli_MainPackageID_Map != null){
                                    String mainPackageIdStr = oli_MainPackageID_Map.get(counter_OLI);
                                    if(mainPackageIdStr != null){
                                        if(packageName_packageId_map != null){
                                            oliObject.Main_Package_ID__c = packageName_packageId_map.get(mainPackageIdStr);
                                        }
                                    }
                                }
								//END D-1864 21/01/15 Wenjun
                                if(oli_order_Map != null){
                                    oliObject.Order__c = oli_order_Map.get(counter_OLI).Id;                   
                                }
                            }
                            counter_OLI++;
                        }

                        insert orderLineItemsList;
                        
                        //START D-1864 21/01/15 Wenjun: Update the Postage Charge
                        Map<Id, Decimal> mapItemIdToPostageCharge = PostageChargeHelper.getPostageChargesForLineItems(mapOrderIdToContactId,orderLineItemsList);   
                        for(Order_Line_Item__c itemObj : orderLineItemsList)    
                        {
                            itemObj.Postage_Charge__c = mapItemIdToPostageCharge.get(itemObj.Id);
                        }
                        UPDATE orderLineItemsList;
                        //END D-1864 21/01/15 Wenjun
                        //START D-2555 01/06/2015 Added By C. Lin - Add Vendor_Assignment. Query orderLineItemsList including Recipient_Postal_Code__c
                        Vendor_Assignment va = new Vendor_Assignment ();
                        //START D-3382 CCB-135 04/Aug/15 Wenjun: Add Query Fields
                        //START D-3423 Wenjun 19 Aug 15: Query Field Main_Package_Product_Platform__c
						// Start UD-2865 19Sep15 JohnD - added Case__c, Case__r.Subscription_Name__c, Case__r.Subscription_Name__r.Delivered_By_1__c, Case__r.Subscription_Name__r.Vendor_1__c
                        orderLineItemsList = [SELECT Id, Name, Main_Package_Period__c, Delivered_By__c, Main_Package_ID__c, Term_Length__c, Main_Package_Type__c, 
                                Postage_Charge__c, Qty__c, Start_Date__c, Order__c, Main_Package_Billing_Type__c, Earliest_Start_Date__c, Recipient_Postal_Code__c, 
                                Order__r.Recipient_Contact__r.Address__r.Recordtype.DeveloperName, Main_Package_Product_Platform__c, 
								Case__c, Case__r.Subscription_Name__c, Case__r.Subscription_Name__r.Delivered_By_1__c, Case__r.Subscription_Name__r.Vendor_1__c 
                                FROM Order_Line_Item__c WHERE ID IN :orderLineItemsList];
                        // End UD-2865 19Sep15 JohnD - added Case__c, Case__r.Subscription_Name__c, Case__r.Subscription_Name__r.Delivered_By_1__c, Case__r.Subscription_Name__r.Vendor_1__c
                        //END D-3423 Wenjun 19 Aug 15
                        //END D-3382 CCB-135 04/Aug/15 Wenjun
                        va.Assign_Vendor_To_Order_Line_Items(orderLineItemsList);
                        //END D-2555 01/06/2015 Added By C. Lin
                        
                        //START: D-1140 12/12/14 Added by J.Sarion – Moved code before the Apex Pagess Messages
                        //[D-0548] Creation of Quotes
                        // Start UD-2865 21Sep15 JohnD - revised logic
                        if (orderList != null && !orderList.isEmpty()) {
							
							integer chunkSize = 5;
							integer totalChunks = integer.valueOf(math.ceil(orderList.size() / chunkSize));
							
							if (math.mod(orderList.size(), chunkSize) != 0) {
								totalChunks++;
							}
							
							string fileIdentifier = 'OrderUpload|' + string.valueOf(datetime.now());
                            
                            Other__c other = new Other__c();
                            other.Name = fileIdentifier;
                            other.Value__c = '0';
                            insert other;
                            
                            for (Order__c order :orderList) { 
                                
								orderIdSet.add(order.Id);
								if (orderIdSet.size() == chunkSize) {
									System.enqueueJob(new QueueableBulkQuoteHandler(orderIdSet, null, fileIdentifier, totalChunks));
									orderIdSet = new set<id>();
								}
                            }
							
							if (!orderIdSet.isEmpty()) {
								System.enqueueJob(new QueueableBulkQuoteHandler(orderIdSet, null, fileIdentifier, totalChunks));
							}
							
							/* commented out
                            Renewal_Quote_Handler_Bulk_Poc createQuote = new Renewal_Quote_Handler_Bulk_Poc();
                            quoteNameSet = createQuote.bulkQuoteCreation(orderIdSet, null);
                            system.debug('>>>>>>>>>>>>>>>>>>quoteNameSet' + quoteNameSet);
                            SendQuotesToZuoraMultipleAccount batch = new SendQuotesToZuoraMultipleAccount(orderIdSet, quoteNameSet, null);
                            database.executeBatch(batch);
							*/
                        }
                        // End UD-2865 21Sep15 JohnD - revised logic
                        //END: D-1140 12/12/14 Added by J.Sarion
                        
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Your Orders have been successfully created. Below is the summary of the upload process:'+'<br/>'+'<br/>'+
                        'Total Orders created = '+orderList.size()+'<br/>'+'<br/>'+
                        'CRSM will now create the Quotes for these Order for creating Subscriptions in Zuora.'+'<br/>'+
                        'You will receive an email once the Quote creation job is completed'));
                        //Database.rollback(sp);
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Maximum number of subscriptions: ' + orderLimit));                
                    }
                }
                else{
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Document not found'));             
                }
            }
            else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Document not found'));
            }
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Your Orders creation could not be completed due to the following errors:'+'<br/>'+'<br/>'+
            'Orders created - 0 '+'<br/>'+
            'Failure Reason - '+e.getMessage())); 
            ExceptionLogger.log(new list<exception> { e });		// Start/End UD-2865 24Sep15 JohnD
            Database.rollback(sp);    
        }
        return null;
    } 
   
    private Date setStringToDateFormat(String myDate) {
        String[] strDate = myDate.split('/');
        Integer myIntDate = integer.valueOf(strDate[1]);
        Integer myIntMonth = integer.valueOf(strDate[0]);
        Integer myIntYear = integer.valueOf(strDate[2]);
        Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
        return d;
    }
    
    public pageReference cancel()
    {
        document.body = null;
        document = new document();
        PageReference PageRef = new PageReference('/apex/CsvFileUploadPage'); 
        system.debug('DEBUG:'+ PageRef);
        PageRef.setRedirect(true);
        return PageRef;    
    } 
    
    //START D-1864 21/01/15 Wenjun : Method to retrieve Singapore Country
    private Country__c getCountryObjForSIN()
    {
        List<Country__c> countryList = [SELECT Id, Name, Country_Name__c, Code__c, Zone__c 
                                        FROM Country__c WHERE Country_Name__c = 'Singapore' limit 1];
        
        if(countryList.isEmpty())
            throw new CustomException(System.Label.ERR_NO_COUNTRY);
        else 
            return countryList[0];
    }
    //END D-1864 21/01/15 Wenjun
}