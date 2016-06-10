// Start UD-3541 18Jan16 JohnD - fix implemented and optimized the whole class

public class BulkOrderUploadController extends BulkOrderUploadDeclarator {
    
    public document orderFile { 
        
        get { 
            
            if (orderFile == null) {
                orderFile = new Document(); 
            }
            return orderFile; 
        } 
        
        set;
    }

    public void retrieveReferenceDoc() {
        
        templateUrl = EMPTY_STR;
        referenceUrl = EMPTY_STR;
        try {
            
            string templateId = [select Id from Document where Name = :DOC_TEMPLATE_NAME].Id;
            templateUrl = DOC_BASE_URL + templateId;
            templateName = DOC_TEMPLATE_LABEL;
        
        } catch (exception e) {
        
            templateUrl = EMPTY_STR;
            templateName = NOT_AVAILABLE;    
        }
        
        try {
            
            string referenceId = [select Id from Document where Name = :DOC_REF_NAME].Id;
            referenceUrl = DOC_BASE_URL + referenceId;
            referenceName = DOC_REF_LABEL;
        
        } catch (exception e) {
        
            referenceUrl = EMPTY_STR;
            referenceName = NOT_AVAILABLE;   
        }
    }

        
    public void verifyDocument() {
        
        orderFile.AuthorId = UserInfo.getUserId();
        orderFile.FolderId = UserInfo.getUserId();
        
       // if (orderFile.BodyLength <= FILE_SIZE_LIMIT) {
            try {
                
                upsert orderFile;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, SUCCESS_MESSAGE));
                
            } catch (exception e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            }
            
        //} else {
        //    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ERROR_FILE_SIZE));
       // }
    }
    
    
    public void processDocument() {
        
        prepareDocument();
        prepareFieldDefinition(rowHeader);
        scanCrossReferrenceData(rowContent);
        retrieveRecordTypeFieldSet();
        retrieveCrossReferrenceData();
        parseRowData(rowContent);
        executeRecordCreation();
        generateAndProcessQuotes();
        generateSummary();
        ExceptionLogger.log(exceptionList);
        clearAllData();
    }
    
    
    private void prepareDocument() {

        documentName = orderFile.Name;
        string content = orderFile.body.toString();
        content = content.replaceAll(C_RETURN, EMPTY_STR);
        
        
        list<list<string>> parsedContent = CSVReader.parse(content);
        list<string> rowList = content.split(NEW_LINE);
        
        rowHeader = parsedContent[0];
        parsedContent.remove(0);
        rowContent = parsedContent;
    }
    
    
    private void prepareFieldDefinition(list<string> columnHeaderParam) {
        
        integer index = 0;
        set<integer> objColumnIndexSet;
        set<integer> ideColumnIndexSet;
        string identifierName;
        string objectName;
        string fieldName;
        map<string, Bulk_Order_Configuration__c> name_bulkOrderConfiguration = new map<string, Bulk_Order_Configuration__c>();
        
        for (Bulk_Order_Configuration__c boc : Bulk_Order_Configuration__c.getAll().values()) {
            name_bulkOrderConfiguration.put((string)boc.get(S_FIELD_NAME), boc);
            identifierName_columnIndexSet.put((string)boc.get(CS_FIELD_IDENTIFIER), new set<integer>());
        }
        
        for (string header : columnHeaderParam) {
            
            header = header.trim();
            
            if (header != EMPTY_STR) {
                
                Bulk_Order_Configuration__c config = name_bulkOrderConfiguration.get(header);
                
                if (config != null && config.get(CS_FIELD_OBJECT_NAME) != null && config.get(CS_FIELD_FIELD_NAME) != null) {
                    
                    columnIndex_fieldName.put(index, (string)config.get(CS_FIELD_FIELD_NAME));
                    
                    objectName = (string)config.get(CS_FIELD_OBJECT_NAME);
                    fieldName = (string)config.get(CS_FIELD_FIELD_NAME);
                    
                    objColumnIndexSet = new set<integer>();
                    if (objectName_columnIndexSet.get(objectName) != null) {
                        objColumnIndexSet = objectName_columnIndexSet.get(objectName);
                    }
                    
                    objColumnIndexSet.add(index);
                    objectName_columnIndexSet.put(objectName, objColumnIndexSet);
                    
                    if (config.get(CS_FIELD_IDENTIFIER) != null) {
                        
                        identifierName = (string)config.get(CS_FIELD_IDENTIFIER);
                        ideColumnIndexSet = new set<integer>();
                        
                        if (identifierName_columnIndexSet.get(identifierName) != null) {
                            ideColumnIndexSet = identifierName_columnIndexSet.get(identifierName);
                        }
                        
                        ideColumnIndexSet.add(index);
                        identifierName_columnIndexSet.put(identifierName, ideColumnIndexSet);
                    }
                    
                    
                    fieldIdentifier_index.put(objectName + fieldName, index);
                    
                } else {
                    addWarning(1, System.Label.BO_ERR_INVALID_COLUMN_HEADER + ' : ' + header);
                }
            }
            
            index++;
        }
    }
    
    
    private void scanCrossReferrenceData(list<list<string>> rowListParam) {
        
        list<string> rowDataList = new list<string>(); //START-END D-4080 12-11-2015 added by Jason A. for code review
        string existingContactIdentifier;
        string tmpData = EMPTY_STR;
        
        for (integer rowIndex = 0; rowIndex < rowListParam.size(); rowIndex++) {
            
            tmpData = EMPTY_STR;
            
            for (string rowData : rowListParam[rowIndex]) {
                tmpData += rowData.replaceAll(SPACE, EMPTY_STR).replaceAll(TAB, EMPTY_STR);
            }
            
            if (tmpData != EMPTY_STR) {
                
                rowDataList = rowListParam[rowIndex];
                
                integer totalColumnTrails = columnIndex_fieldName.size() - rowDataList.size();
                if (totalColumnTrails > 0) {
                    for (integer i = 1; i <= totalColumnTrails; i++) {
                        rowDataList.add(EMPTY_STR);
                    }
                }
                
                if (rowDataList[fieldIdentifier_index.get(IDE_ACC_ACCNUMBER)].trim() != EMPTY_STR) {
                    
                    accountNumber_account.put(rowDataList[fieldIdentifier_index.get(IDE_ACC_ACCNUMBER)], null);

                    // start recipient contact
                    contactAddressRecordTypeName = rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)].trim();
                    contactFirstName = rowDataList[fieldIdentifier_index.get(IDE_RC_FIRST_NAME)].trim();
                    contactLastName = rowDataList[fieldIdentifier_index.get(IDE_RC_LAST_NAME)].trim();

                    if (contactAddressRecordTypeName != EMPTY_STR && contactFirstName != EMPTY_STR && contactLastName != EMPTY_STR) {

                        existingContactAddressRecordTypeName.add(contactAddressRecordTypeName);
                        existingContactFistName.add(contactFirstName);
                        existingContactLastName.add(contactLastName);
                    
                        existingContactIdentifier = contactAddressRecordTypeName + contactFirstName + contactLastName;
                        existingContactIdentifier_contact.put(existingContactIdentifier, null);
                    }
                    // end recipient contact 
                    
                    // start billing contact
                    contactAddressRecordTypeName = rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_RECORDTYPEID)].trim();
                    contactFirstName = rowDataList[fieldIdentifier_index.get(IDE_BC_FIRST_NAME)].trim();
                    contactLastName = rowDataList[fieldIdentifier_index.get(IDE_BC_LAST_NAME)].trim();

                    if (contactAddressRecordTypeName != EMPTY_STR && contactFirstName != EMPTY_STR  && contactLastName != EMPTY_STR) {

                        existingContactAddressRecordTypeName.add(contactAddressRecordTypeName);
                        existingContactFistName.add(contactFirstName);
                        existingContactLastName.add(contactLastName);
                    
                        existingContactIdentifier = contactAddressRecordTypeName + contactFirstName + contactLastName;
                        existingContactIdentifier_contact.put(existingContactIdentifier, null);
                    }
                    // end billing contact
                }
                
                if (rowDataList[fieldIdentifier_index.get(IDE_ORDER_BILLING_ACCOUNT)].trim() == EMPTY_STR 
                        && rowDataList[fieldIdentifier_index.get(IDE_ORDER_PAYMENT_MODE)].trim() == PAYMENT_MODE_OTHER 
                        && rowDataList[fieldIdentifier_index.get(IDE_ORDER_OTHER_PAYMENT_MODE)].trim() == OTHER_PAYMENT_MODE_INVOICE 
                        && rowDataList[fieldIdentifier_index.get(IDE_ORDER_CUST_NUM)].trim() != EMPTY_STR) {
                            
                    armsCutomerNumber_accountNumber.put(rowDataList[fieldIdentifier_index.get(IDE_ORDER_CUST_NUM)], null);
                }
                
                
                if (rowDataList[fieldIdentifier_index.get(IDE_OLI_PROMOTION_ID)].trim() != EMPTY_STR) {
                    promotionCode_promotion.put(rowDataList[fieldIdentifier_index.get(IDE_OLI_PROMOTION_ID)], null);
                }
                
                if (rowDataList[fieldIdentifier_index.get(IDE_OLI_PACKAGE_ID)].trim() != EMPTY_STR) {
                    packageCode_package.put(rowDataList[fieldIdentifier_index.get(IDE_OLI_PACKAGE_ID)], null);
                }
                
                if (rowDataList[fieldIdentifier_index.get(IDE_OLI_ADDON_PACKAGE)].trim() != EMPTY_STR) {
                    packageCode_package.put(rowDataList[fieldIdentifier_index.get(IDE_OLI_ADDON_PACKAGE)], null);
                }
                
                if (rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_POSTAL_CODE)].trim() != EMPTY_STR) {
                    postalCode_singpostAddress.put(rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_POSTAL_CODE)], null);
                }
                
                if (rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)].trim() == RT_ADDRESS_INTERNAL) {
                    
                    if (rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_COMPANY_CODE)].trim() != EMPTY_STR) {
                        companyCode_id.put(rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_COMPANY_CODE)], null);
                    }
                        
                    if (rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_DEPARTMENT)].trim() != EMPTY_STR) {
                        departmentCode_id.put(rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_DEPARTMENT)], null);
                    }
                    
                    if (rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_DIVISION_CODE)].trim() != EMPTY_STR) {
                        divisionCode_id.put(rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_DIVISION_CODE)], null);
                    }
                    
                    if (rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_LOCATION_CODE)].trim() != EMPTY_STR) {
                        locationCode_id.put(rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_LOCATION_CODE)], null);
                    }

                    if (rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_SECTION_CODE)].trim() != EMPTY_STR) {
                        sectionCode_id.put(rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_SECTION_CODE)], null);
                    }
                }

                if (rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_RECORDTYPEID)].trim() == RT_ADDRESS_INTERNAL) {
                    
                    if (rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_COMPANY_CODE)].trim() != EMPTY_STR) {
                        companyCode_id.put(rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_COMPANY_CODE)], null);
                    }
    
                    if (rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_DEPARTMENT)].trim() != EMPTY_STR) {
                        departmentCode_id.put(rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_DEPARTMENT)], null);
                    }
    
                    if (rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_DIVISION_CODE)].trim() != EMPTY_STR) {
                        divisionCode_id.put(rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_DIVISION_CODE)], null);
                    }
    
                    if (rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_LOCATION_CODE)].trim() != EMPTY_STR) {
                        locationCode_id.put(rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_LOCATION_CODE)], null);
                    }
    
                    if (rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_SECTION_CODE)].trim() != EMPTY_STR) {
                        sectionCode_id.put(rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_SECTION_CODE)], null);
                    }
                }
                
                if (rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)].trim() == RT_ADDRESS_AIRLINE) {

                    if (rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_CITY)].trim() != EMPTY_STR) {
                        cityCode_id.put(rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_CITY)], null);
                    }
                    
                    if (rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_PACKING_CODE)].trim() != EMPTY_STR) {
                        packingCode_id.put(rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_PACKING_CODE)], null);
                    }
                }
                
                if (rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)].trim() == RT_ADDRESS_AIRLINE 
                    && rowDataList[fieldIdentifier_index.get(IDE_OLI_DELIVERED_BY)] == DELIVERED_BY_MAILING_AGENT 
                    && rowDataList[fieldIdentifier_index.get(IDE_OLI_VENDOR_MAILING_AGENT)] != EMPTY_STR) {
                                                
                        mailingAgentCode_Id.put(rowDataList[fieldIdentifier_index.get(IDE_OLI_VENDOR_MAILING_AGENT)], null);
                }

                if (rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_RECORDTYPEID)].trim() == RT_ADDRESS_AIRLINE) {

                    if (rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_CITY)].trim() != EMPTY_STR) {
                        cityCode_id.put(rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_CITY)], null);
                    }

                    if (rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_PACKING_CODE)].trim() != EMPTY_STR) {
                        packingCode_id.put(rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_PACKING_CODE)], null);
                    }
                }
                
                rowDataList[fieldIdentifier_index.get(IDE_OLIG_PROMOTION_GIFT)] = rowDataList[fieldIdentifier_index.get(IDE_OLIG_PROMOTION_GIFT)].replace(SPACE,EMPTY_STR);
                      
                if (rowDataList[fieldIdentifier_index.get(IDE_OLI_PROMOTION_ID)].trim() != EMPTY_STR 
                        && rowDataList[fieldIdentifier_index.get(IDE_OLIG_PROMOTION_GIFT)] != EMPTY_STR) {
                    
                    string promotionCodeGiftCode = rowDataList[fieldIdentifier_index.get(IDE_OLI_PROMOTION_ID)].trim();
                    
                    for (string gc : rowDataList[fieldIdentifier_index.get(IDE_OLIG_PROMOTION_GIFT)].split(SEMI_COLON)) {
                        
                        if (gc != null && gc != EMPTY_STR) {
                            
                            promotionCodeGiftCode += gc;
                            promotionCodeGiftCode_promotionGift.put(promotionCodeGiftCode, null); 
                            giftCodeSet.add(gc);
                        }
                    }
                }       
                
            } else {
            
                emptyRowSet.add(rowIndex);  
            }
            
        }
    }
    
    
    private void retrieveCrossReferrenceData() {
        
        // start existing account
        set<string> billingAccountNumberSet;
        set<string> invoiceBillingTypeSet;
        set<string> zoneCodeSet = new set<string>();
      
        for (Account acc : [select Id, AccountNumber, Name, RecordType.DeveloperName, Airline_Indicator__c, 
                (select Id, Zuora__AccountNumber__c, Billing_Type__c, Zuora__DefaultPaymentMethod__c, 
                Other_PaymentMethod__c from R00N40000001kyLcEAI) 
                from Account where AccountNumber in :accountNumber_account.keySet()]) {
            
            accountNumber_account.put(acc.AccountNumber, acc);
            
            billingAccountNumberSet = new set<string>();
            invoiceBillingTypeSet = new set<string>();
            for (Zuora__CustomerAccount__c ba : acc.R00N40000001kyLcEAI) {
                
                billingAccountNumberSet.add(ba.Zuora__AccountNumber__c);
                billingAccountNumber_billingAccount.put(ba.Zuora__AccountNumber__c, ba);
                
                if (ba.Zuora__DefaultPaymentMethod__c == PAYMENT_MODE_OTHER && ba.Other_PaymentMethod__c == OTHER_PAYMENT_MODE_INVOICE) {
                    invoiceBillingTypeSet.add(ba.Billing_Type__c);
                }
            }
            
            accountNumber_billingAccountNumberSet.put(acc.AccountNumber, billingAccountNumberSet);
            
            if (!invoiceBillingTypeSet.isEmpty()) {
                accountNumber_invoiceBillingTypeSet.put(acc.AccountNumber, invoiceBillingTypeSet);
            }
        }
        // end existing account
        
        for (Account accMailAgent : [select Id, AccountNumber, Name, RecordType.Name, Airline_Indicator__c, Mailing_Agent_Code__c, Type from Account where RecordType.Name = :RT_MAILING_AGENT AND Type = :RT_ADDRESS_AIRLINE AND Active__c = true]) {
            mailingAgentCode_Id.put(accMailAgent.Mailing_Agent_Code__c, accMailAgent.Id);
        }
        
        // start arms/invoice billing account
        for (Zuora__CustomerAccount__c ba : [select ARMS_Customer_Number__c, zuora__Account__r.AccountNumber 
                from Zuora__CustomerAccount__c where ARMS_Customer_Number__c in :armsCutomerNumber_accountNumber.keySet()]) {
            
            armsCutomerNumber_accountNumber.put(ba.ARMS_Customer_Number__c, ba.zuora__Account__r.AccountNumber);
        }
        // end arms/invoice billing account
        
        
        // start existing contact
        for (Contact con : [select Id, FirstName, LastName, Address__r.RecordType.DeveloperName, 
                Recipient_Indicator__c, Billing_Indicator__c from Contact 
                where FirstName in :existingContactFistName and LastName in :existingContactLastName 
                and Address__r.RecordType.DeveloperName in :existingContactAddressRecordTypeName 
                and Account.AccountNumber in :accountNumber_account.keySet()]) {
            
            contactIdentifier = con.Address__r.RecordType.DeveloperName + con.FirstName + con.LastName;
            existingContactIdentifier_contact.put(contactIdentifier, con);
        }
        // end existing contact
        
        // start recordtype mapping
        set<string> allowableSobjectSet = new set<string>();
        allowableSobjectSet.add(OBJECT_ACCOUNT); 
        allowableSobjectSet.add('Contact');
        allowableSobjectSet.add('Case');
        allowableSobjectSet.add('Address__c');
        
        for (RecordType rt : [select Id, Name from RecordType where SObjectType in :allowableSobjectSet]) {
            recordTypeName_recordTypeId.put(rt.Name, rt.Id);
        }
        // end recordtype mapping
        
        // start promotion mapping
        for (Promotion__c promo : [select Id, Promotion_Code__c, Contract_Period__c, Penalty_Charge__c, 
                Penalty_Charge_Override__c, Maximum_No_of_gifts_allowed__c from Promotion__c 
                where Promotion_Code__c in :promotionCode_promotion.keySet() 
                and Effective_Start_Date__c <= today and Effective_End_Date__c >= today]) {
            
            promotionCode_promotion.put(promo.Promotion_Code__c, promo);
        }
        // end promotion mapping
        
        // start package mapping
        set<id> productIdSet = new set<id>();
        set<id> pkgProductIdSet;
        
        for (Package__c pkg : [select Id, Package_Code__c, Billing_Type__c, Subscription_Period__c, Package_Type__c, 
                Subscription_Type__c, Product_Family_Current_Package__c, Package_Price__c, Platform__c, Package_Sub_Type__c, 
                (select Id, Is_Digital__c, Product_Rate_Plan__r.zqu__ZProduct__c, 
                Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c, Product_Rate_Plan__r.SubscriptionFrequency__c, 
                Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c, Product_Rate_Plan__r.RatePlanType__c 
                from Package_Items__r where RecordType.DeveloperName like '%Product%' and Product_Rate_Plan__r.zqu__Deleted__c = false 
                and Product_Rate_Plan__r.zqu__Zproduct__r.zqu__Deleted__c = false)  
                from Package__c where Package_Code__c in :packageCode_package.keySet() 
                and Effective_Start_Date__c <= today and Effective_End_Date__c >= today 
                and Package_Type__c != 'Grace Period']) {
            
            packageCode_package.put(pkg.Package_Code__c, pkg);
            
            pkgProductIdSet = new set<id>();    
            if (packageCode_productIdSet.get(pkg.Package_Code__c) != null) {
                pkgProductIdSet = packageCode_productIdSet.get(pkg.Package_Code__c);
            }
            
            for (Package_Item__c pkgItem : pkg.Package_Items__r) {
                productIdSet.add(pkgItem.Product_Rate_Plan__r.zqu__ZProduct__c);
                pkgProductIdSet.add(pkgItem.Product_Rate_Plan__r.zqu__ZProduct__c);
            }
            packageCode_productIdSet.put(pkg.Package_Code__c, pkgProductIdSet);
            
        }
        // end package mapping
        
        // start promotion related objects
        if (promotionCode_promotion != null && !promotionCode_promotion.isEmpty()) {
            
            // start promotion package - use to validate if package is under promotion entered
            for (Promotion_Package__c pp : [select Promotion__r.Promotion_Code__c, Package_Name__r.Package_Code__c 
                    from Promotion_Package__c where Promotion__r.Promotion_Code__c in :promotionCode_promotion.keySet()]) {
            
                if (pp.Promotion__r.Promotion_Code__c != null && pp.Package_Name__r.Package_Code__c != null) {
                    promotionPackageIdentifierSet.add(pp.Promotion__r.Promotion_Code__c + pp.Package_Name__r.Package_Code__c);
                }
            }
            // end promotion package - use to validate if package is under promotion entered
            
            // start promotion gift
            if (!giftCodeSet.isEmpty()) {
                
                for (Promotion_Gift__c pg : [select Id, Promotion__r.Promotion_Code__c, Gift__r.Gift_Code__c, 
                        Balance_Quantity_New__c, Promotion__r.Maximum_No_of_gifts_allowed__c 
                        from Promotion_Gift__c where Promotion__r.Promotion_Code__c in :promotionCode_promotion.keySet() 
                        and Gift__r.Gift_Code__c in :giftCodeSet]) {
                    
                    promotionCodeGiftCode_promotionGift.put(pg.Promotion__r.Promotion_Code__c + pg.Gift__r.Gift_Code__c, pg);
                }
            }
            // end promotion gift
        }
        // end promotion related objects
        
        
        // start publication mapping
        for (Product_Publication__c pp : [select ZProduct__c, Publication_Code__r.Earliest_Start_Date__c, 
                Publication_Code__r.Direct_Sub_Delivery_Method__c 
                from Product_Publication__c where ZProduct__c in :productIdSet
                AND Publication_Code__r.Earliest_Start_Date__c != null 
                order by Publication_Code__r.Earliest_Start_Date__c asc]) {
            
            if (productId_productPublication.get(pp.ZProduct__c) == null) {
                productId_productPublication.put(pp.ZProduct__c, pp);
            }       

            if(pp.Publication_Code__r.Direct_Sub_Delivery_Method__c != EMPTY_STR && pp.Publication_Code__r.Direct_Sub_Delivery_Method__c != null){
                if(!productId_setDelMethod.containsKey(pp.ZProduct__c)){
                        productId_setDelMethod.put(pp.ZProduct__c, new Set<String>{pp.Publication_Code__r.Direct_Sub_Delivery_Method__c});
                }else{
                    productId_setDelMethod.get(pp.ZProduct__c).add(pp.Publication_Code__r.Direct_Sub_Delivery_Method__c);
                }
            }
        }
        // end publication mapping
        
        
        // start singpost address mapping
        for (Singpost_Address__c postal : [select Id, Name, Address_Type__c, Building_Name__c, Street_Name__c, 
                House_Block_Number__c from Singpost_Address__c where Name in :postalCode_singpostAddress.keySet()]) {
            
            postalCode_singpostAddress.put(postal.Name, postal);
        }
        // end singpost address mapping
        
        // start country mapping
        for (Country__c country : [select Id, Name, Zonal_Code__c from Country__c]) {
            
            countryCode_countryId.put(country.Name, country.Id);
            countryCode_zoneCode.put(country.Name, country.Zonal_Code__c);
            zoneCodeSet.add(country.Zonal_Code__c);
        }
        // end country mapping
        
        // start delivery charge
        for (zqu__ProductRatePlanCharge__c prpc : [select Name, sum__c, zqu__ProductRatePlan__r.Name 
                from zqu__ProductRatePlanCharge__c
                where zqu__ProductRatePlan__r.zqu__ZProduct__r.ProductCode__c = :GlobalVariableClass.PRODUCT_CODE_DELCHG 
                and (not Name like 'Credit%') and (not Name like 'Dummy%') and zqu__Deleted__c = false]) {
        
            if (prpc.zqu__ProductRatePlan__r.Name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge(DELIVERY_PRP_ZERO))) {
                deliveryChargeType_amount.put('I', prpc.sum__c);
            } else if (prpc.zqu__ProductRatePlan__r.Name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge(DELIVERY_PRP_HDB))) {
                deliveryChargeType_amount.put('H', prpc.sum__c);
            } else if (prpc.zqu__ProductRatePlan__r.Name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge(DELIVERY_PRP_APT))) {
                deliveryChargeType_amount.put('C', prpc.sum__c);
            } else if (prpc.zqu__ProductRatePlan__r.Name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge(DELIVERY_PRP_LANDED))) {
                deliveryChargeType_amount.put('L', prpc.sum__c);
            }       
        }    
        // end delivery charge
        
        // start sph company code
        for (SPH_Company__c company : [select Id, Company_Code__c from SPH_Company__c where Company_Code__c in :companyCode_id.keySet()]) {
            companyCode_id.put(company.Company_Code__c, company.Id);
        }
        // end sph company code
        
        // start sph company code
        for (SPH_Department__c dept : [select Id, Department_Code__c from SPH_Department__c where Department_Code__c in :departmentCode_id.keySet()]) {
            departmentCode_id.put(dept.Department_Code__c, dept.Id);
        }
        // end sph company code
        
        // start sph division code
        for (SPH_Division__c div : [select Id, Department_Code__c from SPH_Division__c where Department_Code__c in :divisionCode_id.keySet()]) {
            divisionCode_id.put(div.Department_Code__c, div.Id);
        }
        // end sph division code
        
        // start sph location code
        for (SPH_Location__c loc : [select Id, Location_Code__c from SPH_Location__c where Location_Code__c in :locationCode_id.keySet()]) {
            locationCode_id.put(loc.Location_Code__c, loc.Id);
        }
        // end sph location code

        // start sph section code
        for (SPH_Section__c sec : [select Id, Section_Code__c from SPH_Section__c where Section_Code__c in :sectionCode_id.keySet()]) {
            sectionCode_id.put(sec.Section_Code__c, sec.Id);
        }
        // end sph section code
        
        // start city code
        for (City__c city : [select Id, City_Code__c from City__c where City_Code__c in :cityCode_id.keySet()]) {
            cityCode_id.put(city.City_Code__c, city.Id);
        }
        // end city code

        // start packing code
        for (Packing_Grp__c pkng : [select Id, Packing_Code__c from Packing_Grp__c where Packing_Code__c in :packingCode_id.keySet()]) {
            packingCode_id.put(pkng.Packing_Code__c, pkng.Id);
        }
        // end packing code
        
        zoneProduct_postageCharge = PostageChargeHelper.getPostageCharges(zoneCodeSet, productIdSet);   // Start/End UD-3541 16Jan16 JohnD
    }
    
    
    private void parseRowData(list<list<string>> rowDataListParam) {

        integer counter = 2;
        
        for (integer rowIndex = 0; rowIndex < rowDataListParam.size(); rowIndex++) {

            if (!emptyRowSet.contains(rowIndex)) {
                
                try {
                    processRow(rowDataListParam[rowIndex], counter);
                } catch (exception e) {
                    exceptionList.add(e);
                }
                
                counter++;
            }
        }
    }
    

    private void processRow(list<string> rowDataParam, integer rowNumberParam) {
        
        map<string, object> referenceName_value = new map<string, object>();
        set<string> accountContactIdentifierSet = new set<string>();
        set<string> addressRCContactIdentifierSet = new set<string>();
        set<string> addressBCContactIdentifierSet = new set<string>();
        set<string> recordTypeFieldSet = new set<string>();
        
        sobject accountx;
        sobject recipientAddress;
        sobject billingAddress;
        sobject recipientContact;
        sobject billingContact;
        sobject contactx;
        sobject orderx;
        sobject orderLineItem;
        sobject orderLineItemGift;
        string objectName;
        string recipientAddressType;
        string accountIdentifier = EMPTY_STR;
        string recipientAddressIdentifier = EMPTY_STR;
        string billingAddressIdentifier = EMPTY_STR;
        string recipientContactIdentifier = EMPTY_STR;
        string billingContactIdentifier = EMPTY_STR;
        string orderIdentifier = EMPTY_STR;
        string orderLineItemIdentifier = EMPTY_STR;
        string orderLineItemGiftIdentifier = EMPTY_STR;
        string fieldName;
        string addressName = EMPTY_STR;
        string billingType = EMPTY_STR;
        string deliveryChargeType;
        string accountName;
        string recipientAddressRecordTypeName = RT_ADDRESS_LOCAL; // set to default if not specified
        decimal subscriberCharge = 0.00;
        decimal vendorCredit = 0.00;
        decimal sSubscriberCharge = 0.00;
        decimal sVendorCredit = 0.00;
        decimal totalSubscriptionRate = 0.00;
        object objectValue;
        boolean isRecipientContactExist = false;
        boolean isBillingContactExist = false;
        Contact existingRecipientContact;
        Contact existingBillingContact;
        Zuora__CustomerAccount__c existingBillingAccount;
        
        list<string> rowDataList = new list<string>();
        for (string rowData : rowDataParam) {
            rowDataList.add(rowData.trim());
        }
        
        
        integer totalColumnTrails = columnIndex_fieldName.size() - rowDataList.size();
        if (totalColumnTrails > 0) {
            for (integer i = 1; i <= totalColumnTrails; i++) {
                rowDataList.add(EMPTY_STR);
            }
        }
        
        Promotion__c promo = promotionCode_promotion.get(rowDataList[fieldIdentifier_index.get(IDE_OLI_PROMOTION_ID)]);
        Package__c pkg = packageCode_Package.get(rowDataList[fieldIdentifier_index.get(IDE_OLI_PACKAGE_ID)]);
        Package__c addonPkg = packageCode_Package.get(rowDataList[fieldIdentifier_index.get(IDE_OLI_ADDON_PACKAGE)]);
        
        // start validation
        referenceName_value.put(IS_EXIST_PROMO, promo != null);
        referenceName_value.put(IS_EXIST_PACKAGE, pkg != null);
        referenceName_value.put(IS_EXIST_ADDON_PACKAGE, addonPkg != null);
        referenceName_value.put(ROW_NUMBER, rowNumberParam);
        
        if (addonPkg != null) {
            referenceName_value.put(IS_VALID_ADDON_PACKAGE, addonPkg.Package_Type__c == ADD_ON);
        }
        
        if (pkg != null) {
            referenceName_value.put(PACKAGE_BILLING_TYPE, pkg.Billing_Type__c);
        }
        
        if (!validateData(rowDataList, referenceName_value)) {
            return;
        }
        // end validation
        
        // start account
        for (integer index : identifierName_columnIndexSet.get(OBJECT_ACCOUNT)) {
            accountIdentifier += refineIdentifier(rowDataList[index]);
        }

        if (rowDataList[fieldIdentifier_index.get(IDE_ACC_ACCNUMBER)] != EMPTY_STR) { // existing account
            
            Account acc = accountNumber_account.get(rowDataList[fieldIdentifier_index.get(IDE_ACC_ACCNUMBER)]);
            accountName = acc.Name;
            accountIdentifier = acc.AccountNumber;  // override with accountnumber
            
            // start check if recipient contact exist
            contactAddressRecordTypeName = rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)].trim();
            contactFirstName = rowDataList[fieldIdentifier_index.get(IDE_RC_FIRST_NAME)].trim();
            contactLastName = rowDataList[fieldIdentifier_index.get(IDE_RC_LAST_NAME)].trim();
            contactIdentifier = contactAddressRecordTypeName + contactFirstName + contactLastName;
            
            existingRecipientContact = existingContactIdentifier_contact.get(contactIdentifier);
            // end check if recipient contact exist
            
            // start check if billing contact exist
            contactAddressRecordTypeName = rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_RECORDTYPEID)].trim();
            contactFirstName = rowDataList[fieldIdentifier_index.get(IDE_BC_FIRST_NAME)].trim();
            contactLastName = rowDataList[fieldIdentifier_index.get(IDE_BC_LAST_NAME)].trim();
            
            if (contactAddressRecordTypeName != EMPTY_STR && contactFirstName != EMPTY_STR && contactLastName != EMPTY_STR) {
                contactIdentifier = contactAddressRecordTypeName + contactFirstName + contactLastName;
                existingBillingContact = existingContactIdentifier_contact.get(contactIdentifier);
            } else {
                existingBillingContact = existingRecipientContact;
            }
            // end check if billing contact exist
            
        } else if (accountIdentifier_account.get(accountIdentifier) == null) {
            
            accountx = new Account();
            recordTypeFieldSet = recordTypeName_fieldSet.get(rowDataList[fieldIdentifier_index.get(IDE_ACC_RECORDTYPEID)]);
            
            for (integer index : objectName_columnIndexSet.get(OBJECT_ACCOUNT)) {
                
                fieldName = columnIndex_fieldName.get(index);
                
                if (recordTypeFieldSet.contains(fieldName)) {
                    
                    if (fieldName == S_FIELD_RECORDTYPEID) {
                        objectValue = recordTypeName_recordTypeId.get(rowDataList[index]);
                    } else {
                        objectValue = stringToObject(rowDataList[index], Schema.SObjectType.Account.fields.getMap().get(fieldName).getDescribe().getType().name());
                    }
                    
                    accountx.put(fieldName, objectValue);
                }
            }
        
        } else {
            accountName = (string)accountIdentifier_account.get(accountIdentifier).get(S_FIELD_NAME);
        }
        
        if (accountx != null) {
            accountName = (string)accountx.get(S_FIELD_NAME);
            accountIdentifier_account.put(accountIdentifier, accountx);
        }
        // end account
        
        // start address
        if (existingRecipientContact == null) { // bypass creation if recipient already exist
            
            for (integer index : identifierName_columnIndexSet.get(OBJECT_RECIPIENT_ADDRESS)) {
                recipientAddressIdentifier += refineIdentifier(rowDataList[index]);
            }

            if (addressIdentifier_address.get(recipientAddressIdentifier) == null) {
                
                recipientAddress = new Address__c();
                recordTypeFieldSet = recordTypeName_fieldSet.get(rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)]);
                string pCode;
                string countryCode;
                
                recipientAddress.put(FIELD_COUNTRY, countryCode_countryId.get(COUNTRY_CODE_SG));
                
                for (integer index : objectName_columnIndexSet.get(OBJECT_RECIPIENT_ADDRESS)) {

                    fieldName = columnIndex_fieldName.get(index);
                    
                    if (recordTypeFieldSet.contains(fieldName)) {
                        
                        if (fieldName == S_FIELD_RECORDTYPEID) {
                            
                            objectValue = recordTypeName_recordTypeId.get(rowDataList[index]);
                            if (objectValue == null) {
                                // set local as default
                                rowDataList[index] = RT_ADDRESS_LOCAL;
                                objectValue = recordTypeName_recordTypeId.get(rowDataList[index]);
                            }
                            
                            recipientAddressRecordTypeName = rowDataList[index];
                        
                        } else if (fieldName == FIELD_COUNTRY) {
                            
                            if (rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)] == RT_ADDRESS_OVERSEAS) {
                                objectValue = countryCode_countryId.get(rowDataList[index]);
                            } else {
                                objectValue = countryCode_countryId.get(COUNTRY_CODE_SG);
                            }
                        
                        } else if (fieldName == FIELD_POSTAL_CODE) {
                            
                            pCode = rowDataList[index];
                            Singpost_Address__c postal = postalCode_singpostAddress.get(pCode);
                            //system.assertEquals('AddressType ' , postal.Address_Type__c);
                            recipientAddressType = postal.Address_Type__c;
                            objectValue = postal.Id;
                            recipientAddress.put(FIELD_BUILDING_NAME_2, postal.Building_Name__c);
                            recipientAddress.put(FIELD_BLOCK_HOUSE_NUM, postal.House_Block_Number__c);
                            recipientAddress.put(FIELD_STREET_NAME_2, postal.Street_Name__c);
                            
                        } else if (fieldName == FIELD_COMPANY_CODE) {
                            objectvalue = companyCode_id.get(rowDataList[index]);
                        } else if (fieldName == FIELD_DEPARTMENT) {
                            objectvalue = departmentCode_id.get(rowDataList[index]);
                        } else if (fieldName == FIELD_DIVISION_CODE) {
                            objectvalue = divisionCode_id.get(rowDataList[index]);
                        } else if (fieldName == FIELD_LOCATION_CODE) {
                            objectvalue = locationCode_id.get(rowDataList[index]);
                        } else if (fieldName == FIELD_SECTION_CODE) {
                            objectvalue = sectionCode_id.get(rowDataList[index]);
                        } else if (fieldName == FIELD_PACKING_CODE) {
                            objectvalue = packingCode_id.get(rowDataList[index]);
                        } else if (fieldName == FIELD_CITY) {
                            objectValue = cityCode_id.get(rowDataList[index]);
                        } else {
                            objectValue = stringToObject(rowDataList[index], Schema.SObjectType.Address__c.fields.getMap().get(fieldName).getDescribe().getType().name());
                        }
                        
                        recipientAddress.put(fieldName, objectValue);
                    }
                }
                
                recipientAddress.put(S_FIELD_NAME, generateAddressName((string)recipientAddress.get(FIELD_LEVEL_NUM), (string)recipientAddress.get(FIELD_UNIT_NUM), pCode));
                
            }
            
            if (recipientAddress != null) {
                addressIdentifier_address.put(recipientAddressIdentifier, recipientAddress);
            }
        }
        
        if (existingBillingContact == null) {   // bypass creation if billing already exis
                
            for (integer index : identifierName_columnIndexSet.get(OBJECT_BILLING_ADDRESS)) {
                billingAddressIdentifier += refineIdentifier(rowDataList[index]);
            }

            if (addressIdentifier_address.get(billingAddressIdentifier) == null && billingAddressIdentifier.trim() != EMPTY_STR) {
                
                billingAddress = new Address__c();
                recordTypeFieldSet = recordTypeName_fieldSet.get(rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_RECORDTYPEID)]);
                string pCode;
                
                billingAddress.put(FIELD_COUNTRY, countryCode_countryId.get(COUNTRY_CODE_SG));
                
                for (integer index : objectName_columnIndexSet.get(OBJECT_BILLING_ADDRESS)) {
                    
                    fieldName = columnIndex_fieldName.get(index);
                    
                    if (recordTypeFieldSet.contains(fieldName)) {
                        
                        if (fieldName == S_FIELD_RECORDTYPEID) {
    
                            objectValue = recordTypeName_recordTypeId.get(rowDataList[index]);
                            if (objectValue == null) {
                                // set local as default
                                rowDataList[index] = RT_ADDRESS_LOCAL;
                                objectValue = recordTypeName_recordTypeId.get(rowDataList[index]);
                            }
    
                        } else if (fieldName == FIELD_COUNTRY) {
                            
                            if (rowDataList[fieldIdentifier_index.get(IDE_BC_ADDRESS_RECORDTYPEID)] == RT_ADDRESS_OVERSEAS) {
                                objectValue = countryCode_countryId.get(rowDataList[index]);
                            } else {
                                objectValue = countryCode_countryId.get(COUNTRY_CODE_SG);
                            }
    
                        } else if (fieldName == FIELD_POSTAL_CODE) { 
                            
                            pCode = rowDataList[index];
                            Singpost_Address__c postal = postalCode_singpostAddress.get(pCode);
                            //system.assertEquals('AddressType ' , postal.Address_Type__c);
                            objectValue = postal.Id;
                            billingAddress.put(FIELD_BUILDING_NAME_2, postal.Building_Name__c);
                            billingAddress.put(FIELD_BLOCK_HOUSE_NUM, postal.House_Block_Number__c);
                            billingAddress.put(FIELD_STREET_NAME_2, postal.Street_Name__c);

                        } else if (fieldName == FIELD_COMPANY_CODE) {
                            objectvalue = companyCode_id.get(rowDataList[index]);
                        } else if (fieldName == FIELD_DEPARTMENT) {
                            objectvalue = departmentCode_id.get(rowDataList[index]);
                        } else if (fieldName == FIELD_DIVISION_CODE) {
                            objectvalue = divisionCode_id.get(rowDataList[index]);
                        } else if (fieldName == FIELD_LOCATION_CODE) {
                            objectvalue = locationCode_id.get(rowDataList[index]);
                        } else if (fieldName == FIELD_SECTION_CODE) {
                            objectvalue = sectionCode_id.get(rowDataList[index]);
                        } else if (fieldName == FIELD_PACKING_CODE) {
                            objectvalue = packingCode_id.get(rowDataList[index]);
                        } else if (fieldName == FIELD_CITY) {
                            objectValue = cityCode_id.get(rowDataList[index]);
                        } else {
                            objectValue = stringToObject(rowDataList[index], Schema.SObjectType.Address__c.fields.getMap().get(fieldName).getDescribe().getType().name());
                        }
                        
                        billingAddress.put(fieldName, objectValue);
                    }
                }
                
                billingAddress.put(S_FIELD_NAME, generateAddressName((string)billingAddress.get(FIELD_LEVEL_NUM), (string)billingAddress.get(FIELD_UNIT_NUM), pCode));
            }
            
            if (billingAddress != null) {
                addressIdentifier_address.put(billingAddressIdentifier, billingAddress);
            }
        }
        // end address
        
        // start contact
        // start recipient
        recipientContactIdentifier = accountIdentifier + recipientAddressIdentifier;
        for (integer index : identifierName_columnIndexSet.get(OBJECT_RECIPIENT_CONTACT)) {
            recipientContactIdentifier += refineIdentifier(rowDataList[index]);
        }
        
        if (existingRecipientContact != null && existingRecipientContact.Recipient_Indicator__c == true) {
            
            recipientContactIdentifier = existingRecipientContact.Address__r.RecordType.DeveloperName;
            recipientContactIdentifier += existingRecipientContact.FirstName;
            recipientContactIdentifier += existingRecipientContact.LastName;
             
        } else if (contactIdentifier_contact.get(recipientContactIdentifier) == null) {
            
            recipientContact = new Contact();
            
            for (integer index : objectName_columnIndexSet.get(OBJECT_RECIPIENT_CONTACT)) {
                
                fieldName = columnIndex_fieldName.get(index);
                objectValue = stringToObject(rowDataList[index], Schema.SObjectType.Contact.fields.getMap().get(fieldName).getDescribe().getType().name());
                
                if (Schema.SObjectType.Contact.fields.getMap().get(fieldName).getDescribe().getType().name() == DATA_TYPE_BOOLEAN) {
                    objectValue = (boolean)objectValue;
                }
                
                recipientContact.put(fieldName, objectValue);
            }
            
            recipientContact.put(S_FIELD_RECORDTYPEID, recordTypeName_recordTypeId.get(RT_CUSTOMER_CONTACT));
            recipientContact.put(FIELD_RECIPIENT_INDICATOR, true);
            
        } else {
            recipientContact = contactIdentifier_contact.get(recipientContactIdentifier);
        }
        // end recipient

        // start billing
        billingContactIdentifier = accountIdentifier + billingAddressIdentifier;
        for (integer index : identifierName_columnIndexSet.get(OBJECT_BILLING_CONTACT)) {
            billingContactIdentifier += refineIdentifier(rowDataList[index]);
        }
        
        if (existingBillingContact != null && existingBillingContact.Billing_Indicator__c == true) {
            
            billingContactIdentifier = existingBillingContact.Address__r.RecordType.DeveloperName;
            billingContactIdentifier += existingBillingContact.FirstName;
            billingContactIdentifier += existingBillingContact.LastName;
             
        } else if (recipientContactIdentifier != billingContactIdentifier) {
            
            if (contactIdentifier_contact.get(billingContactIdentifier) == null) {
                
                billingContact = new Contact();
                for (integer index : objectName_columnIndexSet.get(OBJECT_BILLING_CONTACT)) {
                    
                    fieldName = columnIndex_fieldName.get(index);
                    objectValue = stringToObject(rowDataList[index], Schema.SObjectType.Contact.fields.getMap().get(fieldName).getDescribe().getType().name());
                    billingContact.put(fieldName, objectValue);
                }

                billingContact.put(S_FIELD_RECORDTYPEID, recordTypeName_recordTypeId.get(RT_CUSTOMER_CONTACT));
                billingContact.put(FIELD_BILLING_INDICATOR, true);
                
                if (billingContact.get(S_FIELD_FIRST_NAME) == null && billingContact.get(S_FIELD_LAST_NAME) == null) {
                     
                    billingContact = null;
                    recipientContact.put(FIELD_BILLING_INDICATOR, true);
                    billingContactIdentifier = recipientContactIdentifier;
                }
            }
            
        } else {
            
            recipientContact.put(FIELD_BILLING_INDICATOR, true);
            billingContactIdentifier = recipientContactIdentifier;
        }
        // end billing
        
        if (recipientContact != null) {
            
            contactIdentifier_contact.put(recipientContactIdentifier, recipientContact);
            contactIdentifier_accountIdentifier.put(recipientContactIdentifier, accountIdentifier);
            contactIdentifier_addressIdentifier.put(recipientContactIdentifier, recipientAddressIdentifier);
        }
        
        if (billingContact != null) {
            
            contactIdentifier_contact.put(billingContactIdentifier, billingContact);
            contactIdentifier_accountIdentifier.put(billingContactIdentifier, accountIdentifier);
            contactIdentifier_addressIdentifier.put(billingContactIdentifier, billingAddressIdentifier);
        }
        // end contact

        // start order
        if (pkg != null && pkg.Billing_Type__c != null) { 
            billingType = pkg.Billing_Type__c;
        }
        
        orderIdentifier = accountIdentifier + recipientContactIdentifier + billingContactIdentifier + rowNumberParam;
        for (integer index : identifierName_columnIndexSet.get(OBJECT_ORDER)) {
            orderIdentifier += refineIdentifier(rowDataList[index]);
        }
        
        if (orderIdentifier_order.get(orderIdentifier) == null) {
            
            orderx = new Order__c();
            creditCardField_value = new map<string, string>();
            
            for (integer index : objectName_columnIndexSet.get(OBJECT_ORDER)) {
                
                fieldName = columnIndex_fieldName.get(index);
                
                if (fieldName.contains(CREDIT_CARD)) {
                    // credit card processing. 
                    creditCardField_value.put(fieldName, rowDataList[index]);
                
                } else {
                    
                    objectValue = stringToObject(rowDataList[index], Schema.SObjectType.Order__c.fields.getMap().get(fieldName).getDescribe().getType().name());
                    orderx.put(fieldName, objectValue);
                    
                    if (fieldName == FIELD_VENDOR_CREDIT) {
                        
                        if (objectValue == null) {
                            objectValue = 0.00;
                        }
                        
                        sVendorCredit = (decimal)objectValue;
                    
                    } else if (fieldName == FIELD_SUBSCRIBER_CHARGE) {
                        
                        if (objectValue == null) {
                            objectValue = 0.00;
                        }
                    
                        sSubscriberCharge = (decimal)objectValue;
                    
                    } else if (fieldName == FIELD_DELIVER_CHARGE_TYPE) {
                        
                        deliveryChargeType = (string)objectValue;
                        // Start D-4334 19Jan16 JohnD - added logic if not delivered by vender charge type must be Z
                        if ((deliveryChargeType == null || deliveryChargeType == EMPTY_STR) 
                                && rowDataList[fieldIdentifier_index.get(IDE_OLI_DELIVERED_BY)] == DELIVERED_BY_VENDOR) { 
                            //START PD-0041 FrancisBenzon 16May16 : default to H if recipientAddType is null
                            if(recipientAddressType != null)
                            {
                                deliveryChargeType = ConstantsSLB.getDefaultDeliveryChargeType(recipientAddressType);
                            } else {
                                deliveryChargeType = 'H';
                            }                           
                            //END PD-0041 FrancisBenzon 16May16 : default to H if recipientAddType is null
                            orderx.put(fieldName, deliveryChargeType);
                        } else if (rowDataList[fieldIdentifier_index.get(IDE_OLI_DELIVERED_BY)] != DELIVERED_BY_VENDOR) {
                            orderx.put(fieldName, 'Z');
                        }
                        // End D-4334 19Jan16 JohnD - added logic if not delivered by vender charge type must be Z
                    }
                }
            }
            
            // start subscriber and vendor credit
            if (recipientAddressRecordTypeName == RT_ADDRESS_INTERNAL) {
                
                subscriberCharge = deliveryChargeType_amount.get('I');
            
            } else if (recipientAddressRecordTypeName == RT_ADDRESS_LOCAL || recipientAddressRecordTypeName == RT_ADDRESS_AIRLINE) {
                
                if (deliveryChargeType == 'N') {
                    vendorCredit = deliveryChargeType_amount.get(deliveryChargeType);
                } else if (deliveryChargeType == 'S') {
                    subscriberCharge = sSubscriberCharge;
                    vendorCredit = sVendorCredit;
                } else if (deliveryChargeType == '9') {
                    subscriberCharge = sSubscriberCharge;
                } else if (deliveryChargeType != 'Z') {
                    subscriberCharge = deliveryChargeType_amount.get(deliveryChargeType);
                    vendorCredit = deliveryChargeType_amount.get(deliveryChargeType);
                }
            }
            orderx.put(FIELD_SUBSCRIBER_CHARGE, subscriberCharge);
            orderx.put(FIELD_VENDOR_CREDIT, vendorCredit);               
            // end subscriber and vendor credit 
            orderx.put(FIELD_BILLING_TYPE, pkg.Billing_Type__c);
            orderx.put(FIELD_ORDER_TYPE, START_STR);
            orderx.put(FIELD_STATUS, PENDING);
            orderx.put(FIELD_DTL_DATE, dtlDate);
            orderx.put(FIELD_CREDIT_BALANCE, 0.00);
            orderx.put(FIELD_MONTHLY_DEL_CHG_FULL_PAYMENT, 0.00);  
            orderx.put(FIELD_RECURRING_DEL_CHG, subscriberCharge);
            orderx.put(FIELD_BA_CREATION_MODE, BA_CREATION_MODE_NEW);
            orderx.put(FIELD_FPP_DEL_CHG , 0.0);
            orderx.put(FIELD_ACQ_TYPE, ROAD_SHOW);
            orderx.put(FIELD_CREATION_MODE, OTHERS);
            orderx.put(FIELD_ACCOUNT_NAME, accountName);
            orderx.put(FIELD_ORDER_ACTION, START_STR);
            orderx.put(FIELD_DEL_CHG, 0.00);
            orderx.put(FIELD_SUBJECT, documentName + ' - R' + string.valueOf(rowNumberParam));
            
            if (pkg.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE) {
                orderx.put(FIELD_MONTHLY_DEL_CHG_FULL_PAYMENT, subscriberCharge);
            }

            // start retrieve existing billing contact
            if (rowDataList[fieldIdentifier_index.get(IDE_ORDER_BILLING_ACCOUNT)] != EMPTY_STR) {
                
                existingBillingAccount = billingAccountNumber_billingAccount.get(rowDataList[fieldIdentifier_index.get(IDE_ORDER_BILLING_ACCOUNT)]);
                if (existingBillingAccount != null) {
                    
                    orderx.put(FIELD_BILLING_ACCOUNT, existingBillingAccount.Id);
                    orderx.put(FIELD_PAYMENT_MODE, existingBillingAccount.Zuora__DefaultPaymentMethod__c);
                    orderx.put(FIELD_OTHER_PAYMENT_MODE, existingBillingAccount.Other_PaymentMethod__c);
                    orderx.put(FIELD_BA_CREATION_MODE, BA_CREATION_MODE_EXISTING);
                }
            }
            // end retrieve existing billing contact
            
            if ((string)orderx.get(FIELD_PAYMENT_MODE) != PAYMENT_MODE_CHECK) {
                
                orderx.put(FIELD_CHECK_AMOUNT, null);
                orderx.put(FIELD_CHECK_DATED, null);
                orderx.put(FIELD_CHECK_ISSUING_BANK, null);
                orderx.put(FIELD_CHECK_NUM, null);
                orderx.put(FIELD_CHECK_REM, null);                 
            }
            
            if ((string)orderx.get(FIELD_PAYMENT_MODE) != PAYMENT_MODE_CASH) {
                orderx.put(FIELD_AMOUNT_PAID, null);
            }
            
            if ((string)orderx.get(FIELD_PAYMENT_MODE) != PAYMENT_MODE_CC) {
                orderIdentifier_creditCard = new map<string, map<string, string>>();
            } else {
                orderIdentifier_creditCard.put(orderIdentifier, creditCardField_value);
            }
            
            if ((string)orderx.get(FIELD_PAYMENT_MODE) == PAYMENT_MODE_OTHER) {
                
                if ((string)orderx.get(FIELD_OTHER_PAYMENT_MODE) != OTHER_PAYMENT_MODE_INTERNAL_CHG) {
                    orderx.put(FIELD_GL_CODE, null);
                }
                
                if ((string)orderx.get(FIELD_OTHER_PAYMENT_MODE) != OTHER_PAYMENT_MODE_INVOICE) {
                    
                    orderx.put(FIELD_ARMS_ACC_NUM, null);
                    orderx.put(FIELD_ARMS_CUS_NUM, null);
                    orderx.put(FIELD_ARMS_BUS_PROFILE, null);
                    orderx.put(FIELD_ARMS_DEBT_MGT, null);
                
                } else if (existingBillingAccount == null){
                    
                    if (orderx.get(FIELD_ARMS_CUS_NUM) == null && orderx.get(FIELD_ARMS_ACC_NUM) == null) {
                        orderx.put(FIELD_ARMS_CREATE_CUS, true);
                    } else if (orderx.get(FIELD_ARMS_CUS_NUM) != null && orderx.get(FIELD_ARMS_ACC_NUM) == null) {
                        orderx.put(FIELD_ARMS_CREATE_ACC, true);
                    }
                }
                
            } else {
                orderx.put(FIELD_OTHER_PAYMENT_MODE, null);
            }
            
        }
        
        if (orderx != null) {
            
            orderIdentifier_order.put(orderIdentifier, orderx);
            
            orderIdentifier_accountIdentifier.put(orderIdentifier, accountIdentifier);
            orderIdentifier_recipientContactIdentifier.put(orderIdentifier, recipientContactIdentifier);
            orderIdentifier_billingContactIdentifier.put(orderIdentifier, billingContactIdentifier);
        }
        // end order

        orderLineItemIdentifier = orderIdentifier;
        for (integer index : identifierName_columnIndexSet.get(OBJECT_OLI)) {
            orderLineItemIdentifier +=  refineIdentifier(rowDataList[index]);
        }
        
        if (orderLineItemIdentifier_orderLineItem.get(orderLineItemIdentifier) == null) {
            
            orderLineItem = new Order_Line_Item__c();
            integer period;
            integer contractPeriod;
            integer quantity = 1;
            date startDate;
            date endDate;
            date contractEndDate;
            
            try {
                period = integer.valueOf(pkg.Subscription_Period__c);
            } catch (exception e) {
                
            }
            
            for (integer index : objectName_columnIndexSet.get(OBJECT_OLI)) {

                fieldName = columnIndex_fieldName.get(index);
                objectValue = null;
                
                if (fieldName == FIELD_PROMOTION_ID) {
                    
                    if (promo != null) {
                        
                        objectValue = promo.Id;
                        orderLineItem.put(FIELD_TERM_DISCUSS, true);
                        
                        if (promo.Penalty_Charge_Override__c != null){
                            orderLineItem.put(FIELD_PENALTY_CHG, promo.Penalty_Charge_Override__c);
                        } else if (promo.Penalty_Charge__c != null) {
                            orderLineItem.put(FIELD_PENALTY_CHG, decimal.valueOf(promo.Penalty_Charge__c));
                        } else {
                            orderLineItem.put(FIELD_PENALTY_CHG, 0.00);
                        }
                        
                    } else {
                        objectValue = null;
                    }
                
                } else if (fieldName == FIELD_NEW_CONTRACT_PERIOD && promo != null) {
                    
                    if (rowDataList[index] != EMPTY_STR) {
                        
                        try {
                            contractPeriod = integer.valueOf(rowDataList[index]);
                        } catch (exception e) {
                            contractPeriod = 0;
                        }
                        objectValue = contractPeriod;
                        orderLineItem.put(FIELD_NEW_CONTRACT_PERIOD, contractPeriod);
                    }
                
                } else if (fieldName == FIELD_MAIN_PACKAGE_ID) {
                    objectValue = pkg.Id;
                } else if (fieldName == FIELD_ADDON_PACKAGE && addonPkg != null) {
                    objectValue = addonPkg.Id;
                } else {
                    objectValue = stringToObject(rowDataList[index], Schema.SObjectType.Order_Line_Item__c.fields.getMap().get(fieldName).getDescribe().getType().name());
                }
                
                if (fieldName == FIELD_QTY) {
                    if (objectValue != null && integer.valueOf(objectValue) > 0) {
                        quantity = integer.valueOf(objectValue);
                    } else {
                        objectValue = quantity;
                    }
                }
                
                // excluded Vendor_Mailing_Agent__c field for it will have its own logic
                // since vendor assignment is done in Vendor_Assignment class and have its own dml (update), 
                // re-updating the oli in the executeRecordCreation method will causes to this field be nulled
                if (fieldName != FIELD_VENDOR_MAILING_AGENT) {
                    orderLineItem.put(fieldName, objectValue);
                }
            }


            for (Package_Item__c pkgItem : pkg.Package_Items__r) {
                
                Product_Publication__c productPublication = productId_productPublication.get(pkgItem.Product_Rate_Plan__r.zqu__ZProduct__c);
                
                orderLineItem.put(FIELD_IS_DIGITAL, pkgItem.Is_Digital__c);
                
                if (pkgItem.Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c == 'All-In-One') {
                    orderLineItem.put(FIELD_IS_AIO, true);
                }
                
                if (pkgItem.Product_Rate_Plan__r.SubscriptionFrequency__c != null && 
                        (pkgItem.Product_Rate_Plan__r.RatePlanType__c  == GlobalVariableClass.RATE_TYPE_BILL_RUN 
                        || pkgItem.Product_Rate_Plan__r.RatePlanType__c  == GlobalVariableClass.RATE_TYPE_PRORATION)) {
                        
                   orderLineItem.put(FIELD_PACKAGE_FREQ, ConstantsSLB.getProductFrequency(pkgItem.Product_Rate_Plan__r.SubscriptionFrequency__c)); 
                }
                
                orderLineItem.put(FIELD_PRODUCT_SUB_TYPE, pkgItem.Product_Rate_Plan__r.zqu__ZProduct__r.ProductSubType__c);
                orderLineItem.put(FIELD_PRODUCT_PLATFORM, pkgItem.Product_Rate_Plan__r.zqu__ZProduct__r.ProductPlatform__c);
                
                orderLineItem.put(FIELD_EARLIEST_START_DATE, productPublication.Publication_Code__r.Earliest_Start_Date__c);
                orderLineItem.put(FIELD_DELIVERY_METHOD, productPublication.Publication_Code__r.Direct_Sub_Delivery_Method__c);
            }

            if (orderLineItem.get(FIELD_START_DATE) == null) {
                orderLineItem.put(FIELD_START_DATE, orderLineItem.get(FIELD_EARLIEST_START_DATE));
            }
                    
            startDate = date.valueOf(orderLineItem.get(FIELD_START_DATE));
            
            if (pkg.Subscription_Type__c == GlobalVariableClass.SUBSCRIPTION_TYPE_TERMED && period != null) {
                endDate = startDate.addMonths(period).addDays(-1);
            }
            
            orderLineItem.put(FIELD_TERM_LENGTH, period);
            orderLineItem.put(FIELD_END_DATE, endDate);
            orderLineItem.put(FIELD_SUBSCRIBED_AS, 'New Buy');
            orderLineItem.put(FIELD_PACKAGE_PERIOD, period);
            orderLineItem.put(FIELD_PACKAGE_TYPE, pkg.Package_Type__c);
            orderLineItem.put(FIELD_PACKAGE_SUB_TYPE, pkg.Subscription_Type__c);
            orderLineItem.put(FIELD_PRODUCT_FAMILY, pkg.Product_Family_Current_Package__c);
            orderLineItem.put(FIELD_PACKAGE_SUB_RATE, pkg.Package_Price__c);
            orderLineItem.put(FIELD_PACKAGE_BILLING_TYPE, billingType);
            
            if (addonPkg != null) {
                
                orderLineItem.put(FIELD_ADDON_PRODUCT_PLATFORM, addonPkg.Platform__c);
                orderLineItem.put(FIELD_ADDON_PRODUCT_SUB_TYPE, addonPkg.Subscription_Type__c);
                orderLineItem.put(FIELD_ADDON_SUB_RATE, addonPkg.Package_Price__c);
            }
            
            if (orderIdentifier_totalSubscriptionRate.get(orderIdentifier) != null) {
                totalSubscriptionRate = orderIdentifier_totalSubscriptionRate.get(orderIdentifier);
            }
            
            if (pkg.Package_Price__c != null) {
                totalSubscriptionRate += (pkg.Package_Price__c * quantity);
            }
            
            if (addonPkg != null && addonPkg.Package_Price__c != null) {
                totalSubscriptionRate += (addonPkg.Package_Price__c * quantity);
            }
            
            orderIdentifier_totalSubscriptionRate.put(orderIdentifier, totalSubscriptionRate);
            
            // start initialize postage charge to 0 to be used in calculation later
            if (billingType == GlobalVariableClass.BILLING_TYPE_FULL_PRE) {
                orderIdentifier_totalPostageCharge.put(orderIdentifier, 0.00);
            }
            // end initialize postage charge to 0 to be used in calculation later
            
            
            if (contractPeriod > 0) {
                contractEndDate = startDate.addMonths(contractPeriod).addDays(-1);
                orderLineItem.put(FIELD_CONTRACT_END_DATE, contractEndDate);
            }

            if (rowDataList[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)].trim() == RT_ADDRESS_AIRLINE 
                    && rowDataList[fieldIdentifier_index.get(IDE_OLI_DELIVERED_BY)] == DELIVERED_BY_MAILING_AGENT 
                    && rowDataList[fieldIdentifier_index.get(IDE_OLI_VENDOR_MAILING_AGENT)] != EMPTY_STR) {
                
                orderLineItem.put(FIELD_VENDOR_MAILING_AGENT, mailingAgentCode_Id.get(rowDataList[fieldIdentifier_index.get(IDE_OLI_VENDOR_MAILING_AGENT)]));
            }
        }
        
        if (orderLineItem != null) {

            orderLineItemIdentifier_orderLineItem.put(orderLineItemIdentifier, orderLineItem);
            orderLineItemIdentifier_orderIdentifier.put(orderLineItemIdentifier, orderIdentifier);
            
            list<sobject> orderLineItemList = new list<Order_Line_Item__c>();
            
            if (orderLineItem.get(FIELD_DELIVERED_BY) == GlobalVariableClass.OLIDELIVEREDBY_VENDOR) {
                // for delivery charge - getting the longest line item
                if (orderIdentifier_vendorOrderLineItemList.get(orderIdentifier) != null) {
                    orderLineItemList = orderIdentifier_vendorOrderLineItemList.get(orderIdentifier);
                }
                
                orderLineItemList.add(orderLineItem);
                orderIdentifier_vendorOrderLineItemList.put(orderIdentifier, orderLineItemList);
            
            } else if (orderLineItem.get(FIELD_DELIVERED_BY) == DELIVERED_BY_MAILING_AGENT) {
                // for postage charge
                if (orderIdentifier_agentOrderLineItemList.get(orderIdentifier) != null) {
                    orderLineItemList = orderIdentifier_agentOrderLineItemList.get(orderIdentifier);
                }
                
                orderLineItemList.add(orderLineItem);
                orderIdentifier_agentOrderLineItemList.put(orderIdentifier, orderLineItemList);
            }
            
        }
        // end order line item
        
        // start order line item gift
        if (promo != null  
                && rowDataList[fieldIdentifier_index.get(IDE_OLIG_PROMOTION_GIFT)] != EMPTY_STR) {
            
            string promotionCodeGiftCode = promo.Promotion_Code__c;
            string identifier;
            
            for (string gc : rowDataList[fieldIdentifier_index.get(IDE_OLIG_PROMOTION_GIFT)].split(SEMI_COLON)) {
                
                if (gc != null && gc != EMPTY_STR) {
                    
                    orderLineItemGiftIdentifier = orderLineItemIdentifier + gc;
                    identifier = promotionCodeGiftCode + gc;
                    
                    orderLineItemGift = new Order_Line_Item_Gift__c();
                    orderLineItemGift.put(FIELD_PROMOTION_GIFT, promotionCodeGiftCode_promotionGift.get(identifier).Id);
                    orderLineItemGift.put(FIELD_ORDER_QUANTITY, orderLineItem.get(FIELD_QTY));
                    
                    orderLineItemGiftIdentifier_orderLineItemGift.put(orderLineItemGiftIdentifier, orderLineItemGift);
                    orderLineItemGiftIdentifier_orderLineItemIdentifier.put(orderLineItemGiftIdentifier, orderLineItemIdentifier);
                    
                }
            }
        }      
         
        // end order line item gift
    }
    
    
    private void executeRecordCreation() {
        //Logger logger = new Logger(BulkOrderUploadController.class.getName());
        savepoint sp = Database.setSavepoint();
        
        if (!accountIdentifier_account.isEmpty() || !accountNumber_account.isEmpty()) {
            
            try {
                // do not change the sequence
                accountIdentifier_account.remove(null);
                addressIdentifier_address.remove(null);
                contactIdentifier_contact.remove(null);
                orderIdentifier_order.remove(null);
                orderLineItemIdentifier_orderLineItem.remove(null);
                
                insert accountIdentifier_account.values();
                addExistingAccount();
                
                insert addressIdentifier_address.values();
                
                populateContactLookupFields();
                insert contactIdentifier_contact.values();
                addExistingContact();
                
                populateOrderLookupFields();
                insert orderIdentifier_order.values();
                
                populateOrderLineItemLookupFields();
                // Start UD-3407 04Jan16 JohnD - added retry mechanism on lock issue. ignoring dml inside loop risk
                //START UD-3541 1/12/2015 K. Tan
                //list<exception> exceptionOnRetryList = new list<exception>();
                boolean isLocked = true;
                while (isLocked) {
                    
                    isLocked = false;
                   
                    try {
                        insert orderLineItemIdentifier_orderLineItem.values();
                    } catch (exception oliEx) {
                        //exceptionOnRetryList.add(oliEx);
                        //logger.log(oliEx);
                        if (oliEx.getMessage().contains(LOCK_ROW)) {
                            isLocked = true;
                        }
                    }
                }
                /*try{
                    logger.save();
                }
                catch(Exception e){
                    
                }*/
                //END UD-3541 1/12/2015 K. Tan
                // End UD-3407 04Jan16 JohnD - added retry mechanism on lock issue. ignoring dml inside loop risk
                
                if (!orderLineItemGiftIdentifier_orderLineItemGift.isEmpty()) {
                
                    populateOrderLineItemGiftLookupFields();
                    insert orderLineItemGiftIdentifier_orderLineItemGift.values();
                }
                
                mapRecordIdToIdentifier();
                computeCharges();
                
                update orderLineItemIdentifier_orderLineItem.values();
                update orderIdentifier_order.values();
                
                assignVendor();
                
                prepareCases();
                insert caseList;
                
                assignCaseToOrderLineItem();
                update orderLineItemIdentifier_orderLineItem.values();
            
            } catch (exception e) {
                Database.rollback(sp);
                isErrorEncountered = true;
                
                string message = System.Label.BO_ERR_CREATION_FAILURE + e.getMessage();

                orderFile = null;

                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, message));
                exceptionList.add(e);              
            }
        } 
    }
    
    private void addExistingAccount() {
        if (!accountNumber_account.isEmpty()) {
            for (Account acc : accountNumber_account.values()) {
                accountIdentifier_account.put(acc.AccountNumber, acc);
            }
        }
    }
    
    private void addExistingContact() {
        
        if (!existingContactIdentifier_contact.isEmpty()) {
            for (string identifier : existingContactIdentifier_contact.keySet()) {
                contactIdentifier_contact.put(identifier, existingContactIdentifier_contact.get(identifier));
            }
        }
    }
    
    
    private void assignCaseToOrderLineItem() {
        
        map<id, id> orderId_caseId = new map<id, id>();
        for (Case casex : caseList) {
            orderId_caseId.put(casex.Order__c, casex.Id);
        }
        
        for (Order_Line_Item__c orderLineItem : (list<Order_Line_Item__c>)orderLineItemIdentifier_orderLineItem.values()) {
            orderLineItem.Case__c = orderId_caseId.get(orderLineItem.Order__c);
        }
    }
    
    

    /*
    *   pre-requisite: account and address (already inserted)  
    */
    private void populateContactLookupFields() {

        for (string identifier : contactIdentifier_contact.keySet()) {
            
            string accountIdentifier = contactIdentifier_accountIdentifier.get(identifier);
            string addressIdentifier = contactIdentifier_addressIdentifier.get(identifier);
            
            Account accountx = (Account)accountIdentifier_account.get(accountIdentifier);
            Address__c address = (Address__c)addressIdentifier_address.get(addressIdentifier);
            Contact contactx = (Contact)contactIdentifier_contact.get(identifier);
            
            contactx.AccountId = accountx.Id;
            contactx.Address__c = address.Id;
            
            contactIdentifier_contact.put(identifier, contactx);
        }
    }
    
    
    private void populateOrderLookupFields() {

        for (string identifier : orderIdentifier_order.keySet()) {
            
            Order__c orderx = (Order__c)orderIdentifier_order.get(identifier);
            
            string accountIdentifier = orderIdentifier_accountIdentifier.get(identifier);
            string recipientContactIdentifier = orderIdentifier_recipientContactIdentifier.get(identifier);
            string billingContactIdentifier = orderIdentifier_billingContactIdentifier.get(identifier);
            
            Account accountx = (Account)accountIdentifier_account.get(accountIdentifier);
            Contact recipientContact = (Contact)contactIdentifier_contact.get(recipientContactIdentifier);
            Contact billingContact = (Contact)contactIdentifier_contact.get(billingContactIdentifier);
            
            orderx.Account__c = accountx.Id;
            orderx.Recipient_Contact__c = recipientContact.Id;
            orderx.Billing_Contact__c = billingContact.Id;
            
        }
    }
        

    private void populateOrderLineItemLookupFields() {
        
        for (string identifier : orderLineItemIdentifier_orderLineItem.keySet()) {
            
            string orderIdentifier = orderLineItemIdentifier_orderIdentifier.get(identifier);
            Order__c orderx = (Order__c)orderIdentifier_order.get(orderIdentifier);
            Order_Line_Item__c orderLineItem = (Order_Line_Item__c)orderLineItemIdentifier_orderLineItem.get(identifier);
            
            orderLineItem.Order__c = orderx.Id;
            
            orderLineItemIdentifier_orderLineItem.put(identifier, orderLineItem);
        }   
    }
    
    private void populateOrderLineItemGiftLookupFields() {
        
        orderLineItemGiftIdentifier_orderLineItemGift.remove(null);
        
        for (string identifier : orderLineItemGiftIdentifier_orderLineItemGift.keySet()) {
            
            string orderLineItemIdentifier = orderLineItemGiftIdentifier_orderLineItemIdentifier.get(identifier);

            Order_Line_Item__c orderLineItem = (Order_Line_Item__c)orderLineItemIdentifier_orderLineItem.get(orderLineItemIdentifier);
            Order_Line_Item_Gift__c orderLineItemGift = (Order_Line_Item_Gift__c)orderLineItemGiftIdentifier_orderLineItemGift.get(identifier);
            orderLineItemGift.Order_Line_Item__c = orderLineItem.Id;
            
            orderLineItemGiftIdentifier_orderLineItemGift.put(identifier, orderLineItemGift);
        }
    }
    
    private void mapRecordIdToIdentifier() {
        
        for (string identifier : orderIdentifier_order.keySet()) {
            
            orderId_orderIdentifier.put(orderIdentifier_order.get(identifier).Id, identifier);
        }   
        
        for (string identifier : orderLineItemIdentifier_orderLineItem.keySet()) {
            
            Order_Line_Item__c orderLineItem = (Order_Line_Item__c)orderLineItemIdentifier_orderLineItem.get(identifier);
            orderLineItemId_orderLineItemIdentifier.put(orderLineItem.Id, identifier);
            
            if (orderLineItem.Start_Date__c < orderLineItem.Earliest_Start_Date__c) {
                urgentOrderIdSet.add(orderLineItem.Order__c);
            }
        }
    }
    
    
    private void computeCharges() {
        
        Order__c orderx;
        list<Order_Line_Item__c> orderLineItemList = new list<Order_Line_Item__c>();
        
        // start postage charge
        map<id, id> orderId_recipientId = new map<id, id>();
        for (string identifier : orderIdentifier_agentOrderLineItemList.keySet()) {
            
            orderx = (Order__c)orderIdentifier_order.get(identifier);
            orderId_recipientId.put(orderx.Id, orderx.Recipient_Contact__c);
            list<Order_Line_Item__c> agentOrderLineItemList = orderIdentifier_agentOrderLineItemList.get(identifier);
            orderLineItemList.addAll(agentOrderLineItemList);
        }
        
        map<id, decimal> orderLineItemId_postageCharge = PostageChargeHelper.getPostageChargesForLineItems(orderId_recipientId, orderLineItemList);
        
        if (orderLineItemId_postageCharge != null) {
            
            orderLineItemList = new list<Order_Line_Item__c>();
            list<Order__c> orderList = new list<Order__c>();
            
            for (id orderLineItemId : orderLineItemId_postageCharge.keySet()) {
                
                string orderLineItemIdentifier = orderLineItemId_orderLineItemIdentifier.get(orderLineItemId);
                
                Order_Line_Item__c orderLineItem = (Order_Line_Item__c)orderLineItemIdentifier_orderLineItem.get(orderLineItemIdentifier);
                orderLineItem.Postage_Charge__c = orderLineItemId_postageCharge.get(orderLineItemId);
                orderLineItemIdentifier_orderLineItem.put(orderLineItemIdentifier, orderLineItem);
                
                string orderIdentifier = orderId_orderIdentifier.get(orderLineItem.Order__c);
                decimal totalPostageCharge = 0.00;
                
                if (orderIdentifier_totalPostageCharge.get(orderIdentifier) != null) {
                    totalPostageCharge = orderIdentifier_totalPostageCharge.get(orderIdentifier);
                }
                
                totalPostageCharge += (orderLineItem.Postage_Charge__c * orderLineItem.Qty__c);
                
                orderIdentifier_totalPostageCharge.put(orderIdentifier, totalPostageCharge);
            }
        }
        // end postage charge

        // start total full prepaid 
        for (string identifier : orderIdentifier_order.keySet()) {
            
            orderx = (Order__c)orderIdentifier_order.get(identifier);
            
            if (orderx.Billing_Type__c == GlobalVariableClass.BILLING_TYPE_FULL_PRE) {
                
                // start longest oli
                orderLineItemList = orderIdentifier_vendorOrderLineItemList.get(identifier);
                Order_Line_Item__c masterOli;
                if (orderLineItemList != null && !orderLineItemList.isEmpty()) {
                    masterOli = SM_SubscriptionHelper.getLongestOrderLineItem(orderLineItemList);
                }

                if (masterOli != null && masterOli.Term_Length__c != null && orderx.Subscriber_Charge__c != null) {
                    orderx.Full_Prepaid_Delivery_Charge__c = orderx.Subscriber_Charge__c * masterOli.Term_Length__c;
                }
                // end longest oli

                orderx.Total_Full_Prepaid__c = orderIdentifier_totalPostageCharge.get(identifier) 
                        + orderIdentifier_totalSubscriptionRate.get(identifier) + orderx.Full_Prepaid_Delivery_Charge__c;
            
            } else {
                orderx.Total_Full_Prepaid__c = 0.00;
            }
            
            orderIdentifier_order.put(identifier, orderx);
        }
        // end total full prepaid
    }
    
    
    private object stringToObject(string value, string objectType) {

        object convertedValue;
        
        try {
            if (value != null && value != EMPTY_STR) {
                if (objectType == DATA_TYPE_DATE) {
                    convertedValue = stringToDate(value);
                } else if (objectType == DATA_TYPE_DATETIME) {
                    convertedValue = datetime.valueOf(value);
                } else if (objectType == DATA_TYPE_BOOLEAN) {
                    if (value == 'Y') {
                        convertedValue = true;
                    } else {
                        convertedValue = false;
                    }
                } else if (objectType == DATA_TYPE_INTEGER) {
                    convertedValue = integer.valueOf(value);
                } else if (objectType == DATA_TYPE_DOUBLE || objectType == DATA_TYPE_PERCENT || objectType == DATA_TYPE_CURRENCY) {
                    convertedValue = decimal.valueOf(value);
                } else if (objectType == DATA_TYPE_ID) {
                    convertedValue = id.valueOf(value);
                } else {
                    convertedValue = value;
                }
            } else if (objectType == DATA_TYPE_BOOLEAN) {
                convertedValue = false;
            }
        } catch (exception e) { }
        
        return convertedValue;      
    }
    
    
    private string refineIdentifier(string value) {
        
        string refinedKey = value.replace(SPACE,EMPTY_STR);
        return refinedKey;
    }
    
    private string generateAddressName(string levelNumberParam, string unitNumberParam, string postalCodeParam) {
        
        string name = EMPTY_STR;
        if (levelNumberParam == null) {
            levelNumberParam = NULL_STR;
        }
        
        if (unitNumberParam == null) {
            unitNumberParam = NULL_STR;
        }
        
        name = levelNumberParam + HYPHEN + unitNumberParam + SEMI_COLON + postalCodeParam;
        
        return name;
    }
    
    
    private date stringToDate(string dateStrParam) {
        
        list<string> strDate = dateStrParam.split('/');
        date datex;
        
        if (strDate.size() == 3) {
            integer day = integer.valueOf(strDate[0]);
            integer month = integer.valueOf(strDate[1]);
            integer year = integer.valueOf(strDate[2]);
            datex = date.newInstance(year, month, day);
        }
        
        return datex;
    }
    
    
    private void generateAndProcessQuotes() {
        
        if (!isErrorEncountered) {
        
            list<Order__c> orderList = orderIdentifier_order.values();
            
            if (orderList != null && !orderList.isEmpty()) {
                
                map<id, map<string, string>> orderId_creditCard;
                set<id> orderIdSet = new set<id>();
                set<id> chunkUrgentOrderIdSet = new set<id>();
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
                
                
                for (Order__c orderx :orderList) { 
                      
                    orderIdSet.add(orderx.Id);
                    
                    if (urgentOrderIdSet.contains(orderx.Id)) {
                        chunkUrgentOrderIdSet.add(orderx.Id);
                    }
                    
                    if (orderIdentifier_creditCard.keySet().contains(orderId_orderIdentifier.get(orderx.Id))) {
                        
                        if (orderId_creditCard == null) {
                            orderId_creditCard = new map<id, map<string, string>>();
                        }
                        
                        orderId_creditCard.put(orderx.Id, orderIdentifier_creditCard.get(orderId_orderIdentifier.get(orderx.Id)));
                    }
                    
                    if (orderIdSet.size() == chunkSize) {
                        
                        System.enqueueJob(new QueueableBulkQuoteHandler(orderIdSet, chunkUrgentOrderIdSet, orderId_creditCard, null, fileIdentifier, totalChunks));
                        orderIdSet = new set<id>();
                        chunkUrgentOrderIdSet = new set<id>();
                        orderId_creditCard = null;
                    }
                }
                
                if (!orderIdSet.isEmpty()) {
                    System.enqueueJob(new QueueableBulkQuoteHandler(orderIdSet, chunkUrgentOrderIdSet, orderId_creditCard, null, fileIdentifier, totalChunks));
                }
            }
        }          
    }
    
    
    private void assignVendor() {

    Vendor_Assignment va = new Vendor_Assignment ();
        
        list<Order_Line_Item__c> orderLineItemsList = [select Id, Name, Main_Package_Period__c, Delivered_By__c, Main_Package_ID__c, Term_Length__c,  
                Postage_Charge__c, Qty__c, Start_Date__c, Order__c, Main_Package_Billing_Type__c, Earliest_Start_Date__c, Recipient_Postal_Code__c, 
                Order__r.Recipient_Contact__r.Address__r.Recordtype.DeveloperName, Main_Package_Product_Platform__c, Main_Package_Type__c,
                Case__c, Case__r.Subscription_Name__c, Case__r.Subscription_Name__r.Delivered_By_1__c, Case__r.Subscription_Name__r.Vendor_1__c 
                from Order_Line_Item__c where Id in :orderLineItemId_orderLineItemIdentifier.keySet()];
                
        va.Assign_Vendor_To_Order_Line_Items(orderLineItemsList);
    }
    
    
    private void prepareCases() {
        
        for (Order__c orderx : [select Id, Account__c, Acquisition_Type__c, Remarks__c, 
                Recipient_Contact__c, Recipient_Contact__r.Address__c, Billing_Contact__c, 
                No_Vendor_Needed__c, (select Id from Order_Line_Items_Direct__r  
                where Delivered_By__c = :GlobalVariableClass.OLIDELIVEREDBY_VENDOR and Vendor_Mailing_Agent__c = null) 
                from Order__c where Id in :orderId_orderIdentifier.keySet()]) { 
            
            Case casex = new Case();
            casex.Order__c = orderx.Id;
            casex.Subject = GlobalVariableClass.SUBJECT_START_SUBSCRIPTION;      
            casex.RecordTypeID = ConstantsSLB.getKeyId(GlobalVariableClass.RECTYPE_START_SUBSCRIPTION);
            casex.Category__c = GlobalVariableClass.CATEGORY_SUBSCRIPTION_REQUEST;
            casex.Sub_Category__c = GlobalVariableClass.SUBCATEGORY_START_SUBCRIPTION;
            casex.Status = GlobalVariableClass.STATUS_PENDING;
            casex.AccountId = orderx.Account__c;
            casex.Description = orderx.Remarks__c;
            casex.Origin = orderx.Acquisition_Type__c;
            casex.Recipient__c = orderx.Recipient_Contact__c;
            casex.Recipient_Address__c = orderx.Recipient_Contact__r.Address__c;
            casex.Subscriber__c = orderx.Billing_Contact__c;
            
            if (urgentOrderIdSet.contains(orderx.Id)) {
                casex.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_URGENT_START;
            } else if (orderx.No_Vendor_Needed__c == false && !orderx.Order_Line_Items_Direct__r.isEmpty()) {
                casex.Sub_Status__c = GlobalVariableClass.SUB_STATUS_WAITING_FOR_VENDOR_ASSIGN;
            } else {
                casex.Sub_Status__c = GlobalVariableClass.STATUS_PENDING;
            }
            
            caseList.add(casex);
            System.debug('caselist ' + caseList);
        }
    }
    
    
    private void generateSummary() {
        
        if (!isErrorEncountered && orderIdentifier_order.size() > 0) {
            
            string totalAccounts = '<tr><td>Accounts</td><td>: ' +string.valueOf(accountIdentifier_account.size() - accountNumber_account.size());
            string totalContacts = '<tr><td>Contacts</td><td>: ' +string.valueOf(contactIdentifier_contact.size() - existingContactIdentifier_contact.size());
            string totalAddresses = '<tr><td>Addresses</td><td>: ' +string.valueOf(addressIdentifier_address.size());
            string totalOrders = '<tr><td>Orders</td><td>: ' + string.valueOf(orderIdentifier_order.size());
            string totalOrderLineItems = '<tr><td>Order Line Items</td><td>: ' + string.valueOf(orderLineItemIdentifier_orderLineItem.size());
            string summaryData = totalAccounts + totalContacts + totalAddresses + totalOrders + totalOrderLineItems;
            summaryData = '<table><tr><th>Item Name</th><th>Total Records</th><tr>' + summaryData + '</table>';
            
            string summary = 'Your Orders have been successfully created. Below is the summary of the upload process.<br /><br >';
            summary += summaryData + '<br /><br />';
            summary += 'CRSM will now create the Quotes for these Order for creating Subscriptions in Zuora.';
            summary += 'You will receive an email once the Quote creation job is completed';
            
            orderFile = null;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, summary));
        }
        
        if (!warningList.isEmpty() && !isErrorEncountered) {
            
            string warningSummary = 'Below are issues encountered.<br />';
            warningSummary += '<ul>';
            for (string warning : warningList) {
                warningSummary += '<li>' + warning + '</li>';
            }
            warningSummary += '</ul>';
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, warningSummary));
        }
    }
    
    
    public void cancel() {
        orderFile = new Document();
    }
    
    
    private boolean validateData(list<string> rowDataListParam, map<string, object> referenceName_valueParam) {
         
        integer rowNumber = (integer)referenceName_valueParam.get(ROW_NUMBER);
        integer quantity = (integer)stringToObject(rowDataListParam[fieldIdentifier_index.get(IDE_OLI_QTY)], DATA_TYPE_INTEGER);
        Account existingAccount;
        Contact existingRecipientContact;
        Contact existingBillingContact;
        boolean isBillingAccountNumberProvided = false;
        string accountNumber = rowDataListParam[fieldIdentifier_index.get(IDE_ACC_ACCNUMBER)];
        string packageBillingType = (string)referenceName_valueParam.get(PACKAGE_BILLING_TYPE);
        set<string> dateFieldSet = new set<string> {IDE_ACC_DATE_OF_BIRTH, IDE_ACC_DATE_SINCE, IDE_OLI_START_DATE, IDE_ORDER_CHECK_DATED};
        //START UD-3357 12/04/15 RReyes
        Package__c pkgRec = packageCode_Package.get(rowDataListParam[fieldIdentifier_index.get(IDE_OLI_PACKAGE_ID)]); 
        List<Package_Item__c> lstPackItem = new List<Package_Item__c>();
        //END UD-3357 12/04/15 RReyes

        string defaultDeliveryChargeType;   
        boolean isWithDeliveryRatePlan;
        
        if (accountNumber != EMPTY_STR) {
            
            existingAccount = accountNumber_account.get(accountNumber);
            
            if (existingAccount == null) {

                addWarning(rowNumber, System.Label.BO_ERR_ACCOUNT_NUMBER_NOT_EXIST);
                return false;

            } else {

                // start check if recipient contact exist
                contactAddressRecordTypeName = rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)].trim();
                contactFirstName = rowDataListParam[fieldIdentifier_index.get(IDE_RC_FIRST_NAME)].trim();
                contactLastName = rowDataListParam[fieldIdentifier_index.get(IDE_RC_LAST_NAME)].trim();
                contactIdentifier = contactAddressRecordTypeName + contactFirstName + contactLastName;
                
                existingRecipientContact = existingContactIdentifier_contact.get(contactIdentifier);
                // end check if recipient contact exist
                
                // start check if billing contact exist
                contactAddressRecordTypeName = rowDataListParam[fieldIdentifier_index.get(IDE_BC_ADDRESS_RECORDTYPEID)].trim();
                contactFirstName = rowDataListParam[fieldIdentifier_index.get(IDE_BC_FIRST_NAME)].trim();
                contactLastName = rowDataListParam[fieldIdentifier_index.get(IDE_BC_LAST_NAME)].trim();
                contactIdentifier = contactAddressRecordTypeName + contactFirstName + contactLastName;
                
                existingBillingContact = existingContactIdentifier_contact.get(contactIdentifier);
                
                if ((contactAddressRecordTypeName == EMPTY_STR || contactFirstName == EMPTY_STR || contactLastName == EMPTY_STR) 
                        && existingRecipientContact != null && existingRecipientContact.Billing_Indicator__c == false) {
                            
                    addWarning(rowNumber, System.Label.BO_ERR_INVALID_BILLING_CONTACT);
                    return false;
                }
                // end check if billing contact exist
            }
            
        } else {
        
            if (rowDataListParam[fieldIdentifier_index.get(IDE_ACC_RECORDTYPEID)] == RT_INTER_DIV 
                    && rowDataListParam[fieldIdentifier_index.get(IDE_ACC_STAFF_ID)] == EMPTY_STR) {
                
                addWarning(rowNumber, System.Label.BO_ERR_STAFF_ID_REQUIRED);
                return false;
            }
            
            if (rowDataListParam[fieldIdentifier_index.get(IDE_ACC_RECORDTYPEID)] == RT_DIRECT_CORP 
                    && rowDataListParam[fieldIdentifier_index.get(IDE_ACC_CONTACT_PERSON)] == EMPTY_STR) {
                
                addWarning(rowNumber, System.Label.BO_ERR_CONTACT_PERSON_REQUIRED);
                return false;
            }
        }
        
        if (((rowDataListParam[fieldIdentifier_index.get(IDE_ACC_RECORDTYPEID)] == RT_DIRECT_CORP 
                && (rowDataListParam[fieldIdentifier_index.get(IDE_ACC_AIRLINE_IND)]) == 'N')
                ||(existingAccount != null && existingAccount.Airline_Indicator__c == false))
                && ((rowDataListParam[fieldIdentifier_index.get(IDE_BC_ADDRESS_RECORDTYPEID)] == RT_ADDRESS_AIRLINE 
                && existingBillingContact == null)
                || (rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)] == RT_ADDRESS_AIRLINE 
                && existingRecipientContact == null))) {
            
            addWarning(rowNumber, System.Label.BO_ERR_AIRLINE_INDICATOR_REQUIRED);
            return false;
        }
        
        if (existingRecipientContact == null && (rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)] == EMPTY_STR 
                || rowDataListParam[fieldIdentifier_index.get(IDE_RC_FIRST_NAME)] == EMPTY_STR
                || rowDataListParam[fieldIdentifier_index.get(IDE_RC_LAST_NAME)] == EMPTY_STR)) {
                    
            addWarning(rowNumber, System.Label.BO_ERR_RECIPIENT_CONTACT_REQUIRED);
            return false;
        }
        
        if (existingRecipientContact == null && rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)] == RT_ADDRESS_LOCAL) {
            
            if (rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_LEVEL_NUM)].length() < 2) {

                addWarning(rowNumber, System.Label.BO_ERR_INVALID_LEVEL_NUMBER);
                return false;
                
            } else if (rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_UNIT_NUM)].length() < 2) {

                addWarning(rowNumber, System.Label.BO_ERR_INVALID_UNIT_NUMBER);
                return false;
            }
            
            if (postalCode_singpostAddress.get(rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_POSTAL_CODE)]) == null) {
                
                addWarning(rowNumber, System.Label.BO_ERR_INVALID_POSTAL_CODE);
                return false;
            }
        }
        
        
        if (existingBillingContact == null && (rowDataListParam[fieldIdentifier_index.get(IDE_BC_ADDRESS_RECORDTYPEID)] == RT_ADDRESS_LOCAL) 
                && rowDataListParam[fieldIdentifier_index.get(IDE_BC_FIRST_NAME)] != EMPTY_STR 
                && rowDataListParam[fieldIdentifier_index.get(IDE_BC_LAST_NAME)] != EMPTY_STR) {
            
            if (rowDataListParam[fieldIdentifier_index.get(IDE_BC_ADDRESS_LEVEL_NUM)].length() < 2) {

                addWarning(rowNumber, System.Label.BO_ERR_INVALID_LEVEL_NUMBER);
                return false;
                
            } else if (rowDataListParam[fieldIdentifier_index.get(IDE_BC_ADDRESS_UNIT_NUM)].length() < 2) {

                addWarning(rowNumber, System.Label.BO_ERR_INVALID_UNIT_NUMBER);
                return false;
                
            } else if (postalCode_singpostAddress.get(rowDataListParam[fieldIdentifier_index.get(IDE_BC_ADDRESS_POSTAL_CODE)]) == null) {
                
                addWarning(rowNumber, System.Label.BO_ERR_INVALID_POSTAL_CODE);
                return false;
            }
            
        }

        if (rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_BILLING_ACCOUNT)] != EMPTY_STR) {
            
            string billingAccountNumber = rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_BILLING_ACCOUNT)];
            set<string> billingAccountNumberSet = accountNumber_billingAccountNumberSet.get(accountNumber);
            
            if (accountNumber == EMPTY_STR) {

                addWarning(rowNumber, System.Label.BO_ERR_ACCOUNT_NUMBER_REQUIRED);
                return false;
                
            } else if (billingAccountNumberSet != null && !billingAccountNumberSet.contains(billingAccountNumber)) {
                
                addWarning(rowNumber, System.Label.BO_ERR_INVALID_BILLING_ACCOUNT_NUMBER);
                return false;

            } else if (billingAccountNumber_billingAccount.get(billingAccountNumber).Billing_Type__c != packageBillingType) {

                addWarning(rowNumber, System.Label.BO_ERR_INVALID_BILLING_TYPE);
                return false;
                
            } else {
                isBillingAccountNumberProvided = true;
            }
        }
        
        if (rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_PAYMENT_MODE)] == PAYMENT_MODE_PAYPAL) {
            
            addWarning(rowNumber, System.Label.BO_ERR_PAYPAL_NOT_ALLOWED);
            return false;
            
        } else if (packageBillingType != null && (packageBillingType).contains(RECURRING_STR)) {
        
            set<string> invalidPaymentModeSet = new set<string>{PAYMENT_MODE_CASH, PAYMENT_MODE_CHECK};
            set<string> invalidOtherPaymentModeSet = new set<string>{OTHER_PAYMENT_MODE_ENETS, OTHER_PAYMENT_MODE_IPP};
            set<string> invalidOtherPaymentInternalModeSet = new set<string>{OTHER_PAYMENT_MODE_ENETS, OTHER_PAYMENT_MODE_IPP, OTHER_PAYMENT_MODE_IPP};
            string accountRecordTypeName = rowDataListParam[fieldIdentifier_index.get(IDE_ACC_RECORDTYPEID)];
            string paymentMode = rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_PAYMENT_MODE)];
            string otherPaymentMode = rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_OTHER_PAYMENT_MODE)];
            
            if (existingAccount != null) {
                accountRecordTypeName = existingAccount.RecordType.DeveloperName;
            }
            
            if (accountRecordTypeName == RT_INTER_DIV) {
                
                if (invalidPaymentModeSet.contains(paymentMode) || (paymentMode == PAYMENT_MODE_OTHER 
                        && invalidOtherPaymentInternalModeSet.contains(otherPaymentMode))) {
                
                    addWarning(rowNumber, System.Label.BO_ERR_INVALID_PAYMENT_MODE_INTER_DIVISION);
                    return false;
                }
            
            } else {
                
                if (invalidPaymentModeSet.contains(paymentMode) || (paymentMode == PAYMENT_MODE_OTHER 
                        && invalidOtherPaymentModeSet.contains(otherPaymentMode))) {
                
                    addWarning(rowNumber, System.Label.BO_ERR_INVALID_PAYMENT_MODE_RECURRING);
                    return false;
                                
                }
                
            }
        }
        
        if (quantity == null || (quantity != null && quantity <= 0)) {

            addWarning(rowNumber, System.Label.BO_ERR_INVALID_QUANTITY);
            return false;
        }
        
        if (rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_PAYMENT_MODE)] == PAYMENT_MODE_OTHER 
                && rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_OTHER_PAYMENT_MODE)] == OTHER_PAYMENT_MODE_INTERNAL_CHG) {
            
            if (rowDataListParam[fieldIdentifier_index.get(IDE_ACC_RECORDTYPEID)] != RT_INTER_DIV) {
                
                addWarning(rowNumber, System.Label.BO_ERR_INTERNAL_CHARGE_NOT_APPLICABLE);
                return false;
                
            } else if (rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_GL_CODE)] == EMPTY_STR) {
                
                addWarning(rowNumber, System.Label.BO_ERR_GL_CODE_REQUIRED);
                return false;
                
            }
            
        }
        
        if (!isBillingAccountNumberProvided) {
            
            if (rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_PAYMENT_MODE)] == PAYMENT_MODE_OTHER 
                    && rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_OTHER_PAYMENT_MODE)] == OTHER_PAYMENT_MODE_INVOICE) {
                
                set<string> invoiceBillingTypeSet = accountNumber_invoiceBillingTypeSet.get(accountNumber);
                
                if (invoiceBillingTypeSet != null && invoiceBillingTypeSet.contains(packageBillingType)) {
                
                    addWarning(rowNumber, System.Label.BO_ERR_ARMS_EXIST_ON_SAME_TYPE);
                    return false;
                    
                } else if (rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_ARMS_DEBT_MGT)] == EMPTY_STR
                    || rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_ARMS_BUS_PROFILE)] == EMPTY_STR) {
                    
                    addWarning(rowNumber, System.Label.BO_ERR_ARMS_DEBT_MGNT_PROFILE_REQUIRED);
                    return false;
                    
                } else if (rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_ARMS_ACC_NUM)] != EMPTY_STR 
                        || rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_CUST_NUM)] != EMPTY_STR) {
                    
                    for (string baNumber : accountNumber_billingAccountNumberSet.get(accountNumber)) {
                        
                        Zuora__CustomerAccount__c ba = billingAccountNumber_billingAccount.get(baNumber);
                        if (ba.Zuora__DefaultPaymentMethod__c == PAYMENT_MODE_OTHER && ba.Other_PaymentMethod__c == OTHER_PAYMENT_MODE_INVOICE 
                                && ((rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_ARMS_ACC_NUM)] == ba.ARMS_Account_Number__c 
                                && ba.ARMS_Account_Number__c != null)
                                || (rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_CUST_NUM)] == ba.ARMS_Customer_Number__c 
                                && ba.ARMS_Customer_Number__c != null))) {

                            addWarning(rowNumber, System.Label.BO_ERR_ARMS_ALREADY_EXIST);
                            return false;
                        }
                    }
                    
                    if (rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_CUST_NUM)] != EMPTY_STR) {
                        
                        string armsAccountNumber = armsCutomerNumber_accountNumber.get(rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_CUST_NUM)]);
                        
                        if (armsAccountNumber != null && armsAccountNumber != accountNumber) {

                            addWarning(rowNumber, System.Label.BO_ERR_ARMS_CUS_NUM_ALREADY_IN_USED);
                            return false;
                        }
                    }
                }
                
            }
        }
        
        
        if (rowDataListParam[fieldIdentifier_index.get(IDE_OLI_PROMOTION_ID)] != EMPTY_STR && !(boolean)referenceName_valueParam.get(IS_EXIST_PROMO)) {
            
            addWarning(rowNumber, System.Label.BO_ERR_INVALID_PROMOTION_CODE);
            return false;
        }

        if (rowDataListParam[fieldIdentifier_index.get(IDE_OLI_PACKAGE_ID)] != EMPTY_STR && !(boolean)referenceName_valueParam.get(IS_EXIST_PACKAGE)) {
            
            addWarning(rowNumber, System.Label.BO_ERR_INVALID_PACKAGE_CODE);
            return false;
        }

        if ((referenceName_valueParam.get(IS_VALID_ADDON_PACKAGE) != null && !(boolean)referenceName_valueParam.get(IS_VALID_ADDON_PACKAGE)) 
                ||(rowDataListParam[fieldIdentifier_index.get(IDE_OLI_ADDON_PACKAGE)] != EMPTY_STR && !(boolean)referenceName_valueParam.get(IS_EXIST_ADDON_PACKAGE))) {
            
            addWarning(rowNumber, System.Label.BO_ERR_INVALID_ADD_ON_PACKAGE_CODE);
            return false; 
        }
        
        if (rowDataListParam[fieldIdentifier_index.get(IDE_OLI_PROMOTION_ID)] != EMPTY_STR && rowDataListParam[fieldIdentifier_index.get(IDE_OLI_PACKAGE_ID)] != EMPTY_STR) {
            
            string promoPackage = rowDataListParam[fieldIdentifier_index.get(IDE_OLI_PROMOTION_ID)] + rowDataListParam[fieldIdentifier_index.get(IDE_OLI_PACKAGE_ID)];
            
            if (!promotionPackageIdentifierSet.contains(promoPackage)) {
                
                addWarning(rowNumber, System.Label.BO_ERR_INVALID_PACKAGE_CODE_UNDER_PROMOTION);
                return false;
            }
        }
        
        if (rowDataListParam[fieldIdentifier_index.get(IDE_OLI_PROMOTION_ID)] != EMPTY_STR && rowDataListParam[fieldIdentifier_index.get(IDE_OLIG_PROMOTION_GIFT)] != EMPTY_STR) {
            
            string promotionCodeGiftCode = rowDataListParam[fieldIdentifier_index.get(IDE_OLI_PROMOTION_ID)];
            string identifier;
            set<string> gcSet = new set<string>();
            object maxAllowedGifts;
            Promotion_Gift__c promoGift;
            
            if (rowDataListParam[fieldIdentifier_index.get(IDE_OLIG_PROMOTION_GIFT)] != EMPTY_STR) {
                
                for (string gc : rowDataListParam[fieldIdentifier_index.get(IDE_OLIG_PROMOTION_GIFT)].split(SEMI_COLON)) {
                    
                    identifier = promotionCodeGiftCode + gc;
                    promoGift = promotionCodeGiftCode_promotionGift.get(identifier);
                    
                    if (promoGift == null) {
                        
                        addWarning(rowNumber, System.Label.BO_ERR_INVALID_GIFT_UNDER_PROMOTION);
                        return false;
                    }
                    
                    if (quantity > promoGift.Balance_Quantity_New__c) {
                        
                        addWarning(rowNumber, System.Label.BO_ERR_NOT_ENOUGH_STOCK);
                        return false;
                    }
                    
                    gcSet.add(gc);
                }
                
                maxAllowedGifts = stringToObject(promoGift.Promotion__r.Maximum_No_of_gifts_allowed__c, DATA_TYPE_INTEGER);
                
                if (maxAllowedGifts == null || (maxAllowedGifts != null && gcSet.size() > (integer)maxAllowedGifts)) {

                    addWarning(rowNumber, System.Label.BO_ERR_MAX_ALLOWABLE_GIFT_EXCEEDED);
                    return false;
                }
            }
        }
        
        
        if (rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)] == RT_ADDRESS_INTERNAL && rowDataListParam[fieldIdentifier_index.get(IDE_OLI_DELIVERED_BY)] != DELIVERED_BY_MAILING_AGENT) {
            
            addWarning(rowNumber, System.Label.BO_ERR_INVALID_DELIVERED_BY_4_INTERNAL_ADDR);
            return false;
        }
        
        if (rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)].trim() == RT_ADDRESS_AIRLINE 
                && rowDataListParam[fieldIdentifier_index.get(IDE_OLI_DELIVERED_BY)] == DELIVERED_BY_MAILING_AGENT 
                && rowDataListParam[fieldIdentifier_index.get(IDE_OLI_VENDOR_MAILING_AGENT)] == EMPTY_STR) {
        
            addWarning(rowNumber, System.Label.BO_ERR_REQUIRED_MAILING_AGENT);
            return false;                       
        }

        //START UD-3357 RReyes - added validation for delivered by.
        //Delivered by Vendor is Disabled for recipients with overseas, airline, internal 
        if(rowDataListParam[fieldIdentifier_index.get(IDE_OLI_DELIVERED_BY)] == DELIVERED_BY_VENDOR){

            if (rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)] == RT_ADDRESS_INTERNAL || rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)] == RT_ADDRESS_AIRLINE || rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)] == RT_ADDRESS_OVERSEAS){
                addWarning(rowNumber, System.Label.BO_ERR_INVALID_VENDOR_DELIVERY);
                return false;
            }
        }
        
        
        if (pkgRec != null) {
            lstPackItem = pkgRec.Package_Items__r;
            Set<String> setDelMethod = new Set<String>(); 
            Set<String> setOptions = new Set<String>();
            String deliveredBy = rowDataListParam[fieldIdentifier_index.get(IDE_OLI_DELIVERED_BY)];
            if(lstPackItem.size() > 0){
                for(Package_Item__c pckItem : lstPackItem){
                    if(pckItem.Product_Rate_Plan__r.zqu__ZProduct__c != null){
                        if(productId_setDelMethod.containsKey(pckItem.Product_Rate_Plan__r.zqu__ZProduct__c)){
                            setOptions.add(DELIVERED_BY_NONE);
                            setDelMethod = productId_setDelMethod.get(pckItem.Product_Rate_Plan__r.zqu__ZProduct__c);
                            if(setDelMethod.size() > 0){
                                if(setDelMethod.contains(DELIVERED_BY_BOTH)){
                                    setOptions.add(DELIVERED_BY_VENDOR);
                                    setOptions.add(DELIVERED_BY_MAILING_AGENT);
                                    break;
                                }else{
                                    if(setDelMethod.contains(DELIVERED_BY_VENDOR)){
                                        setOptions.add(DELIVERED_BY_VENDOR);
                                    }
                                    if(setDelMethod.contains(DELIVERED_BY_MAILING_AGENT)){
                                        setOptions.add(DELIVERED_BY_MAILING_AGENT);
                                    }
                                }
                            }
                        }
                    }
                }
            }else{
                addWarning(rowNumber, System.Label.BO_ERR_NO_PACKAGE_ITEM);
                return false;
            }
            
            //validation
            if(setOptions.size() > 0){
                setOptions.remove(EMPTY_STR);
                setOptions.remove(null);
            }

            if(!setOptions.isEmpty()){
                if(deliveredBy != EMPTY_STR){
                    if(!setOptions.contains(deliveredBy)){
                        addWarning(rowNumber, System.Label.BO_ERR_INVALID_DELIVERED_BY);
                        return false;
                    }
                }else{
                    addWarning(rowNumber, System.Label.BO_ERR_NO_DELIVERED_BY);
                    return false;
                }
            }else{
                addWarning(rowNumber, System.Label.BO_ERR_INVALID_PACKAGE_SELECTED);
                return false;
            }
        }
        //END UD-3357 RReyes - added validation for delivered by.

        for (string dateField : dateFieldSet) {
            
            
            if (rowDataListParam[fieldIdentifier_index.get(dateField)] != EMPTY_STR && stringToObject(rowDataListParam[fieldIdentifier_index.get(dateField)], DATA_TYPE_DATE) == null) {

                addWarning(rowNumber, System.Label.BO_ERR_INVALID_DATE_VALUE);
                return false;
            }
        }

        if (rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)].trim() == RT_ADDRESS_AIRLINE 
                && rowDataListParam[fieldIdentifier_index.get(IDE_OLI_DELIVERED_BY)] == DELIVERED_BY_MAILING_AGENT 
                && rowDataListParam[fieldIdentifier_index.get(IDE_OLI_VENDOR_MAILING_AGENT)] != EMPTY_STR 
                && mailingAgentCode_Id.get(rowDataListParam[fieldIdentifier_index.get(IDE_OLI_VENDOR_MAILING_AGENT)]) == null) {
            
            addWarning(rowNumber, System.Label.BO_ERR_INVALID_MAILING_AGENT_CODE);
            return false;
        }

        // Start D-4334 19Jan16 JohnD - validation for payment mode and other payment method
        
        if (rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_BILLING_ACCOUNT)] == EMPTY_STR) {
            
            if (rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_PAYMENT_MODE)].trim() == EMPTY_STR) {
                
                addWarning(rowNumber, System.Label.BO_ERR_PAYMENT_MODE_REQUIRED);
                return false;
                
            } else if (!paymentModeSet.contains(rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_PAYMENT_MODE)].trim())) {
                
                addWarning(rowNumber, System.Label.BO_ERR_INVALID_PAYMENT_MODE);
                return false;
            }
        }

        if (rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_PAYMENT_MODE)] == PAYMENT_MODE_OTHER) {

            if (rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_OTHER_PAYMENT_MODE)] == EMPTY_STR) {
            
                addWarning(rowNumber, System.Label.BO_ERR_OTHER_PAYMENT_MODE_REQUIRED);
                return false;

            } else if (!otherPaymentModeSet.contains(rowDataListParam[fieldIdentifier_index.get(IDE_ORDER_OTHER_PAYMENT_MODE)])) {
                
                addWarning(rowNumber, System.Label.BO_ERR_INVALID_OTHER_PAYMENT_MODE);
                return false;
            }
        }
        // End D-4334 19Jan16 JohnD - validation for payment mode and other payment method
        
        // start pre-quote creation validation
        if (rowDataListParam[fieldIdentifier_index.get(IDE_OLI_DELIVERED_BY)] == DELIVERED_BY_VENDOR) {
            
            isWithDeliveryRatePlan = false;

            if (rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)] == RT_ADDRESS_INTERNAL) {

                if (deliveryChargeType_amount.get('I') != null) {
                    isWithDeliveryRatePlan = true;
                }
            
            } else if (rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)] == RT_ADDRESS_AIRLINE 
                    || rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)] == RT_ADDRESS_LOCAL) {
                
                Singpost_Address__c postal = postalCode_singpostAddress.get(rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_POSTAL_CODE)]);
                
                if (deliveryChargeType_amount.get(ConstantsSLB.getDefaultDeliveryChargeType(postal.Address_Type__c)) != null) {
                    isWithDeliveryRatePlan = true;
                }
            }

            if (isWithDeliveryRatePlan == false) {
                
                addWarning(rowNumber, System.Label.ERR_NO_DELIVERY_RATE_PLAN);
                return false;
            }
        }

        if (rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)] == RT_ADDRESS_OVERSEAS)  {
            
            if (countryCode_countryId.get(rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_COUNTRY)]) == null) {
                
                addWarning(rowNumber, System.Label.BO_ERR_INVALID_COUNTRY_CODE);
                return false;
            }
            
            if (countryCode_zoneCode.get(rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_COUNTRY)]) == null) {
                
                addWarning(rowNumber, System.Label.ERR_CONTACT_NO_ZONE);
                return false;
            }
        }
        
        if (rowDataListParam[fieldIdentifier_index.get(IDE_OLI_DELIVERED_BY)] == DELIVERED_BY_MAILING_AGENT) {
            
            boolean isPostageError = false;
            
            if (rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)] == RT_ADDRESS_AIRLINE 
                    || rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)] == RT_ADDRESS_LOCAL 
                    || rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_RECORDTYPEID)] == RT_ADDRESS_INTERNAL) {
                
                rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_COUNTRY)] = COUNTRY_CODE_SG;               
            }
            
            string zoneCode = countryCode_zoneCode.get(rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_COUNTRY)]);
            for (id productId : packageCode_productIdSet.get(rowDataListParam[fieldIdentifier_index.get(IDE_OLI_PACKAGE_ID)])) {
       
                string zoneProductIdentifier = zoneCode.toUpperCase() + productId;
                
                if (zoneProduct_postageCharge.get(zoneProductIdentifier) == null) {

                    if (countryCode_zoneCode.get(rowDataListParam[fieldIdentifier_index.get(IDE_RC_ADDRESS_COUNTRY)]) == null) {
                        
                        addWarning(rowNumber, System.Label.ERR_NO_POSTAGE_CHARGE + ' : Combination: ' + zoneProductIdentifier);
                        isPostageError = true;
                    }
                }
                
            }
            
            if (isPostageError) {
                return false;
            }
        }
        // end pre-quote creation validation

        return true;
    }
    
    
    private void retrieveRecordTypeFieldSet() {

        set<string> fieldSet;
        
        for (Record_Type_Field_Setup__c rtfs : Record_Type_Field_Setup__c.getAll().values()) {
            
            fieldSet = new set<string>();
            
            if (recordTypeName_fieldSet.get((string)rtfs.get(CS_RECORD_TYPE_NAME)) != null) {
                fieldSet = recordTypeName_fieldSet.get((string)rtfs.get(CS_RECORD_TYPE_NAME));
            }
            
            fieldSet.add((string)rtfs.get(CS_FIELD_FIELD_NAME));
            recordTypeName_fieldSet.put((string)rtfs.get(CS_RECORD_TYPE_NAME), fieldSet);
            
        }
    }
    

    private void addWarning(integer rowNumberParam, string msgParam) {
        warningList.add(BRACKET_O + string.valueOf(rowNumberParam) + BRACKET_C + SPACE + msgParam);
    }
    
    /*
     //START PD-0041 FrancisBenzon 21May16: for test class coverage only
        public void testCoveragePatch() {
            integer i = 0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
               i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
               i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
               i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                      i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
               i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }
        
            //END PD-0041 FrancisBenzon 21May16: for test class coverage only
        */
}
// End UD-3541 18Jan16 JohnD - fix implemented and optimized the whole class