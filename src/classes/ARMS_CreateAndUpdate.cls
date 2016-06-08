/**
* Class Name: ARMS_CreateAndUpdate 
* @author: Accenture PDC - Sherwin Puli
* Date: 06.Nov.2014
* Requirement/Project Name: SF SPH
* @description: Class that manages INVOICE Billing Account inserted.
*/

/**
* History: D-3046: Class is updated from UAT as a result of UAT hotfix
* @author: Accenture PDC - Sherwin Puli
* Date: 29.May.2015
*/

/**
* History: UD-1810: Class is updated replacing hard coded letters to global variables
* @author: Accenture PDC - Sherwin Puli
* Date: 9.July.2015
*/


public class ARMS_CreateAndUpdate {
    
    public class PaymentInfoWrapper {
        
        public string paymentMode;
        public string otherPaymentMethod;
        public string armsBusinessProfile;
        public string armsDebtManagement;
        public string armsId;
    }
    
    public void createAccount(set<id> orderIdSet, map<id, Zuora__CustomerAccount__c> billingAccountId_billingAccount, 
            map<id, PaymentInfoWrapper> billingAccountId_paymentInfoWrapper, 
            map<id, Order__c> billingAccountId_Order) {
        
        Map<Id, Id> AccIdMap = new Map<Id, Id>();
        Map<Id, Id> billAccIdMap = new Map<Id, Id>();
        Map<Id, Id> orderAccIdMap = new Map<Id, Id>();
        
        Map<Id, String> CUSorderIdBizProfMap = new Map<Id, String>();
        Map<Id, String> CUSorderIdDebtMgTrMap = new Map<Id, String>();
        
        Map<Id, String> ACCorderIdCusNumMap = new Map<Id, String>();
        Map<Id, String> ACCorderIdBizProfMap = new Map<Id, String>();
        Map<Id, String> ACCorderIdDebtMgTrMap = new Map<Id, String>();
        set<id> billingAccountIdWithExistingCustomerAndAccountIdSet = new set<id>();
        
        List<BT_CO_ARMS_CreateAccountBatchFile__c> accToCreateBatchList = new List<BT_CO_ARMS_CreateAccountBatchFile__c>();
        List<BT_CO_ARMS_CreateCustAccountFile__c> cusToCreateBatchList = new List<BT_CO_ARMS_CreateCustAccountFile__c>();
        List<BT_CO_ARMS_CreateCustAccountFile__c> cusToInsertBatchList = new List<BT_CO_ARMS_CreateCustAccountFile__c>();
        
        Set<Id> batchCustSet = new Set<Id>();
        Set<Id> batchAccSet = new Set<Id>();
        
        for (Zuora__CustomerAccount__c tmp : billingAccountId_billingAccount.values()) {
            AccIdMap.put(tmp.Zuora__Account__c, tmp.Id);
            billAccIdMap.put(tmp.Id, tmp.Zuora__Account__c);
        }

        for (Order__c ord : [Select Id, Name, Account__c, Customer_No__c, Create_ARMS_Customer_Account__c, 
                Business_Profile__c, Debt_Management_Treatment__c, Create_ARMS_Account_Only__c, 
                Other_Payment_Mode__c, Billing_Contact__c  From Order__c Where Id in :orderIdSet]) {
            
            system.debug('>>>>>>>>>order<<< ' + ord);
            if (ord.Create_ARMS_Customer_Account__c == true && ord.Create_ARMS_Account_Only__c == false) {
                
                CUSorderIdBizProfMap.put(AccIdMap.get(ord.Account__c),ord.Business_Profile__c);
                CUSorderIdDebtMgTrMap.put(AccIdMap.get(ord.Account__c),ord.Debt_Management_Treatment__c);
                
            } else if (ord.Create_ARMS_Account_Only__c == true) {
                
                if (ord.Customer_No__c <> null && ord.Customer_No__c <> '') {
                    
                    ACCorderIdCusNumMap.put(AccIdMap.get(ord.Account__c),ord.Customer_No__c);
                    ACCorderIdBizProfMap.put(AccIdMap.get(ord.Account__c),ord.Business_Profile__c);
                    ACCorderIdDebtMgTrMap.put(AccIdMap.get(ord.Account__c),ord.Debt_Management_Treatment__c);
                }
            
            //} else if (ord.Create_ARMS_Account_Only__c == false &&  ord.Create_ARMS_Customer_Account__c == false 
            //      && ord.Customer_No__c <> null && ord.) {
            
                //billingAccountIdWithExistingCustomerAndAccountIdSet.add();        
            }
        }
        
        //START: D-995 12/05/14 Added by S.Puli -- updated code to include Account Number from Account
        //list of ARMS customer to create in ARMS
        //START: UD-0964/095 04/22/2015 Added by S.PULI
        //START: UD-1527 11/06/2015 Added by S.Puli
        //START: UD-1528 07/07/2015 Added by S.Puli
        //START UD-2653 10-Sept-2015 Added By S.Puli
        List<Zuora__CustomerAccount__c> customerToCreateList = [Select GST_Out_of_Scope__c,Billing_Contact__r.Address__r.Building_Name__c,Billing_Contact__r.Mobile_Number__c,Billing_Contact__r.Mobile_Number_2__c,Billing_Contact__r.Address__r.Country__r.code__c,
            Billing_Contact__r.Address__r.Postal_Code__r.Service_Number__c,Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c,
            Billing_Contact__r.Address__r.Department__r.Department_Name__c,Billing_Contact__r.Address__r.Division_Code__r.Department_Name__c,
            Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c, Billing_Contact__r.Address__r.City__r.City_Name__c,
            Billing_Contact__r.Address__r.Airline_Number__c,Billing_Contact__r.Address__r.Flight_Number_1__c,Billing_Contact__r.Address__r.Flight_Number_2__c,
            Billing_Contact__r.Office_Number__c,Zuora__Account__r.Designation__c,Billing_Contact__r.Address__r.recordType.developerName,
            Zuora__Account__r.Attention_To_Care_Of__c,Zuora__Account__r.Attention_Care_Off_ind__c,Billing_Contact__r.Address__r.Address_1__c,
            Billing_Contact__r.Address__r.Address_2__c,Billing_Contact__r.Address__r.Address_3__c,Billing_Contact__r.Address__r.Address_4__c,
            Billing_Contact__r.Address__r.Building_Name_2__c,Billing_Contact__r.Address__r.Street_Name__c,Billing_Contact__r.Address__r.Unit_Number__c,
            Billing_Contact__r.Address__r.Level_Number__c,Billing_Contact__r.Address__r.Block_House_Number__c,Billing_Contact__r.Address__r.Country__c,
            Billing_Contact__r.Address__r.Postal_Code__r.name,SOA_Grouping__c,Billing_Contact__r.NRIC__c,CreatedBy.name,Id,Name, Status__c, 
            Zuora__Account__c, Zuora__Account__r.Name, Zuora__Account__r.AccountNumber, Zuora__AccountNumber__c, ARMS_Business_Profile__c,
            ARMS_Debt_Management__c, Zuora__BillToAddress1__c, Zuora__BillToAddress2__c, Zuora__BillToPostalCode__c, Zuora__BillToCity__c, 
            Zuora__BillToCountry__c, Zuora__BillToName__c,Billing_Contact__r.Email,Billing_Contact__r.Office_Extension__c,Billing_Contact__r.HomePhone__c,
            //START UD-1527 6/23/15 Added by Manolo Valena - Added passport field.
            Billing_Contact__r.Passport__c,
            //END UD-1527 6/23/15 Added by Manolo Valena
            Billing_Contact__r.Handphone_Number__c,Billing_Contact__r.Fax__c, Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c, Zuora__Account__r.Attention_To_Care_Of_Indicator__c, Zuora__Account__r.Staff_ID__c,CreatedBy.Alias From Zuora__CustomerAccount__c Where Id In :CUSorderIdBizProfMap.keyset()];
        //END UD-2653 10-Sept-2015 Added By S.Puli
        //END: UD-1528 07/07/2015 Added by S.Puli
        //END: UD-1527 11/06/2015 Added by S.Puli
        //END: UD-0964/095 04/22/2015 Added by S.PULI
        
        //START: UD-0963 04/24/2015 Added by S.PULI
        Set<String> cusName_SET = new Set<String>();
        
        //START: UD-1557 11/06/2015 Added by S.Puli
        Set<Id> cusIds_SET = new Set<Id>();
        if(customerToCreateList.size()>0){
            for(Zuora__CustomerAccount__c ba : customerToCreateList){
                cusName_SET.add(ba.Name);
                cusIds_SET.add(ba.Id);
            }
        }
        
        
        List<Zuora__Subscription__c> newCusSubsList = new List<Zuora__Subscription__c>();
        Map<Id, String> billCusAccToOrderAlias_MAP = new Map<Id, String>();
        //START UD-2653 10-Sept-2015 Added By S.Puli
        Map<Id, String> billAccToCreatorAlias_MAP = new Map<Id, String>();
        //END UD-2653 10-Sept-2015 Added By S.Puli
            
        if(cusIds_SET.size()>0){
            newCusSubsList = [Select Id, Name, Zuora__CustomerAccount__c, Order_Number_1__r.Billing_Account_Creation_Mode__c, Order_Number_1__r.CreatedBy.Alias from Zuora__Subscription__c Where Zuora__CustomerAccount__c IN :cusIds_SET AND Order_Number_1__r.Billing_Account_Creation_Mode__c = :GlobalVariableClass.CREATE_NEW_BILLACC Limit 1];
            if(newCusSubsList.size()>0){
                for(Zuora__Subscription__c zSub : newCusSubsList){
                    if(!billCusAccToOrderAlias_MAP.containsKey(zSub.Zuora__CustomerAccount__c)){
                        billCusAccToOrderAlias_MAP.put(zSub.Zuora__CustomerAccount__c, zSub.Order_Number_1__r.CreatedBy.Alias);
                    }
                }
            }
        }
        
        
        //END: UD-1557 11/06/2015 Added by S.Puli
        
        
        List<BT_CO_ARMS_CreateCustAccountFile__c> createCusFile_LIST = [Select Id, Customer_Name1__c, Reference_Key__c, CreatedDate From BT_CO_ARMS_CreateCustAccountFile__c Where CreatedDate = Today AND Customer_Name1__c In :cusName_SET];
        
        Map<Id, List<BT_CO_ARMS_CreateCustAccountFile__c>> createMasterToDetail_MAP = new Map<Id, List<BT_CO_ARMS_CreateCustAccountFile__c>>();
        
        List<BT_CO_ARMS_CreateCustAccountFile__c> createFileToDelete = new List<BT_CO_ARMS_CreateCustAccountFile__c>();
        
        if(customerToCreateList.size()>0 && createCusFile_LIST.size()>0){
            for(Zuora__CustomerAccount__c billRec : customerToCreateList){
                //START UD-2653 10-Sept-2015 Added By S.Puli
                if(!billAccToCreatorAlias_MAP.containsKey(billRec.Id)){
                    billAccToCreatorAlias_MAP.put(billRec.Id, billRec.CreatedBy.Alias);
                }
                //END UD-2653 10-Sept-2015 Added By S.Puli
                for(BT_CO_ARMS_CreateCustAccountFile__c bFile : createCusFile_LIST){
                    if(billRec.Name == bFile.Customer_Name1__c){
                        if(createMasterToDetail_MAP.containskey(billRec.Id)){
                            createMasterToDetail_MAP.get(billRec.Id).add(bFile);
                        }else{
                            createMasterToDetail_MAP.put(billRec.Id, new List<BT_CO_ARMS_CreateCustAccountFile__c>{bFile});
                        }
                    }
                }
            }
        }
        
        //END: UD-0963 04/24/2015 Added by S.PULI
        
        Set<Id> baCusIdSet = new Set<Id>();
        system.debug('customerToCreateList-->>>>>>>>>>>>>>'+ customerToCreateList);
        if(customerToCreateList<>null && customerToCreateList.size()>0){
        
            for(Zuora__CustomerAccount__c customerRec : customerToCreateList){
                //START: UD-1557 11/06/2015 Added by S.Puli
                //START UD-2653 10-Sept-2015 Added By S.Puli
                if(!billCusAccToOrderAlias_MAP.containsKey(customerRec.Id)){
                    billCusAccToOrderAlias_MAP.put(customerRec.Id, billAccToCreatorAlias_MAP.get(customerRec.Id));
                }
                //END UD-2653 10-Sept-2015 Added By S.Puli
                if(billCusAccToOrderAlias_MAP.containsKey(customerRec.Id)){
                //END: UD-1557 11/06/2015 Added by S.Puli
                    //START: UD-0963 04/24/2015 Added by S.PULI
                    if(createMasterToDetail_MAP.containskey(customerRec.Id)){
                        if(createMasterToDetail_MAP.get(customerRec.Id).size()>0){
                            for(BT_CO_ARMS_CreateCustAccountFile__c batchFileRecord : createMasterToDetail_MAP.get(customerRec.Id)){
                                createFileToDelete.add(batchFileRecord);
                            }                   
                        }
                    }
                    //END: UD-0963 04/24/2015 Added by S.PULI
                    
                    string referenceKey = customerRec.Zuora__Account__r.AccountNumber;
                    string uniqueKey = customerRec.Zuora__Account__r.AccountNumber;
                    PaymentInfoWrapper paymentInfo = billingAccountId_paymentInfoWrapper.get(customerRec.Id);
                    
                    if (customerRec.Zuora__Account__r.AccountNumber != null) {
                        
                        if (customerRec.Zuora__Account__r.AccountNumber.length() > 10) {
                            
                            referenceKey =  customerRec.Zuora__Account__r.AccountNumber.substring(0, 10);
                        }

                        if (customerRec.Zuora__Account__r.AccountNumber.length() > 26) {
                            
                            uniqueKey =     customerRec.Zuora__Account__r.AccountNumber.substring(0, 26);
                        }
                    }
                    //END: D-995 12/05/14 Added by S.Puli
                    
                    BT_CO_ARMS_CreateCustAccountFile__c cusRec1 = new BT_CO_ARMS_CreateCustAccountFile__c(
                        Customer_Name1__c = customerRec.Name,
                        Customer_Status__c = ConstantsSLB.getOther('ARMS_CusSts'),
                        Company_Code__c = ConstantsSLB.getOther('ARMS_CoyCd'),
                        Reference_Key__c = referenceKey,
                        Unique_Key__c = uniqueKey,
                        Account_Type__c = ConstantsSLB.getOther('ARMS_AccTyp'),
                        Credit_Limit_External__c = ConstantsSLB.getOther('ARMS_CrLmtExt'),
                        Credit_Limit_Internal__c = ConstantsSLB.getOther('ARMS_CrLmtInt'),
                        //START: UD-1557 11/06/2015 Added by S.Puli
                        //Start UD-3411 Added By S.Puli - Ensure value for Create_Id__c
                        //Create_Id__c = billCusAccToOrderAlias_MAP.get(customerRec.Id),
                        //End UD-3411 Added By S.Puli - Ensure value for Create_Id__c
                        //END: UD-1557 11/06/2015 Added by S.Puli
                        Sub_Contact_Name__c = customerRec.Zuora__BillToName__c,
                        //START UD-2418 02-Sept-2015 Added By S.Puli
                        Sub_Contact_Designation__c = customerRec.Zuora__Account__r.Designation__c,
                        Sub_Contact_Ext__c = customerRec.Billing_Contact__r.Office_Extension__c,
                        //END UD-2418 02-Sept-2015 Added By S.Puli
                        //Sub_Contact_Type__c,
                        Debt_Mgt_Treatment__c = paymentInfo.armsDebtManagement,
                        Business_Profile__c = paymentInfo.armsBusinessProfile, 
                        Record_Type__c = 'Master',
                        Status__c = 'New',
                        SPH_Staff_Indicator__c=GlobalVariableClass.STRING_N,
                    //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
                        Credit_Term_Reference__c = ConstantsSLB.getOther('ARMS_CrTrmRef'),
                        Approved_Debt_Exposure_Amount__c = ConstantsSLB.getOther('ARMS_DbtExp'),
                        SOA_Group__c = customerRec.SOA_Grouping__c,
                        GST_OutOfScope_Indicator__c = (customerRec.GST_Out_of_Scope__c ? GlobalVariableClass.STRING_Y : GlobalVariableClass.STRING_N)
                        //SOA_Supression_Indicator__c
                    );
                    
                    //Start UD-3411 Added By S.Puli - Ensure value for Create_Id__c
                    if(billCusAccToOrderAlias_MAP.get(customerRec.Id)<>null){
                        cusRec1.Create_Id__c = billCusAccToOrderAlias_MAP.get(customerRec.Id);
                    }else{
                        if(customerRec.CreatedBy.Alias <> null){
                            cusRec1.Create_Id__c = customerRec.CreatedBy.Alias;
                        }                        
                    }
                    //End UD-3411 Added By S.Puli - Ensure value for Create_Id__c
                    if(customerRec.Billing_Contact__r.Address__r.recordType.developerName == 'Local'){
                        cusRec1.Postal_Code__c = customerRec.Billing_Contact__r.Address__r.Postal_Code__r.name;
                        cusRec1.City_Zip__c = '';
                        cusRec1.Country__c = customerRec.Billing_Contact__r.Address__r.Country__r.code__c;
                        cusRec1.Block_House_Number__c = customerRec.Billing_Contact__r.Address__r.Block_House_Number__c;
                        cusRec1.Floor_Number__c = customerRec.Billing_Contact__r.Address__r.Level_Number__c;
                        cusRec1.Unit_No__c = customerRec.Billing_Contact__r.Address__r.Unit_Number__c;
                        cusRec1.Street__c = customerRec.Billing_Contact__r.Address__r.Street_Name__c;
                        cusRec1.Building_Secondary__c = customerRec.Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c;
                        cusRec1.PO_Box_No__c = customerRec.Billing_Contact__r.Address__r.Postal_Code__r.Service_Number__c;
                    }
                    
                    if(customerRec.Billing_Contact__r.Address__r.recordType.developerName == 'Overseas'){
                        cusRec1.Address1__c = customerRec.Billing_Contact__r.Address__r.Address_1__c;
                        cusRec1.Address2__c = customerRec.Billing_Contact__r.Address__r.Address_2__c;
                        cusRec1.Address3__c = customerRec.Billing_Contact__r.Address__r.Address_3__c;
                        cusRec1.Address4__c = customerRec.Billing_Contact__r.Address__r.Address_4__c;
                        cusRec1.Country__c = customerRec.Billing_Contact__r.Address__r.Country__r.code__c;
                    }
                    
                    if(customerRec.Billing_Contact__r.Address__r.recordType.developerName == 'Internal'){
                        cusRec1.Address1__c = customerRec.Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c;
                        cusRec1.Address2__c = customerRec.Billing_Contact__r.Address__r.Department__r.Department_Name__c;
                        cusRec1.Address3__c = customerRec.Billing_Contact__r.Address__r.Division_Code__r.Department_Name__c;
                        cusRec1.Address4__c = customerRec.Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c;
                        cusRec1.Country__c = customerRec.Billing_Contact__r.Address__r.Country__r.code__c;
                    }
                    
                    if(customerRec.Billing_Contact__r.Address__r.recordType.developerName == 'Airline'){
                        if (customerRec.Billing_Contact__r.Address__r.City__r != null && customerRec.Billing_Contact__r.Address__r.City__r.City_Name__c != null)  // Start/End UD-3357 12/07/15 RReyes
                          cusRec1.Address1__c = (customerRec.Billing_Contact__r.Address__r.City__r.City_Name__c.length() > 40 ? customerRec.Billing_Contact__r.Address__r.City__r.City_Name__c.subString(0,40) : customerRec.Billing_Contact__r.Address__r.City__r.City_Name__c ) ;
                        cusRec1.Address2__c = customerRec.Billing_Contact__r.Address__r.Airline_Number__c;
                        cusRec1.Address3__c = customerRec.Billing_Contact__r.Address__r.Flight_Number_1__c;
                        cusRec1.Address4__c = customerRec.Billing_Contact__r.Address__r.Flight_Number_2__c;
                        cusRec1.Country__c = customerRec.Billing_Contact__r.Address__r.Country__r.code__c;
                    }
                    
                    cusRec1.Co_Attention_To_Indicator__c = customerRec.Zuora__Account__r.Attention_To_Care_Of_Indicator__c;
                    cusRec1.co_Attention_To_Party__c = customerRec.Zuora__Account__r.Attention_To_Care_Of__c;
                    
                    /*if(customerRec.Zuora__BillToAddress1__c<>null){
                        if(customerRec.Zuora__BillToAddress1__c.length() > 40){
                            cusRec1.Address1__c = customerRec.Zuora__BillToAddress1__c.substring(0, 40);
                        } else {
                            cusRec1.Address1__c = customerRec.Zuora__BillToAddress1__c;
                        }
                    }
                    if(customerRec.Zuora__BillToAddress2__c<>null){
                        if(customerRec.Zuora__BillToAddress2__c.length() > 40){
                            cusRec1.Address2__c = customerRec.Zuora__BillToAddress2__c.substring(0, 40);
                        } else {
                            cusRec1.Address2__c = customerRec.Zuora__BillToAddress2__c;
                        }
                    }*/
                    
                    if(cusRec1.Business_Profile__c == 'GOVT' && cusRec1.Debt_Mgt_Treatment__c == 'GOVT'){
                        cusRec1.Credit_Term__c = '30';
                    }
                    if(cusRec1.Business_Profile__c == 'NORM' && cusRec1.Debt_Mgt_Treatment__c == 'SUBH'){
                        cusRec1.Credit_Term__c = '15';
                    }
                    if(cusRec1.Business_Profile__c == 'NORM' && cusRec1.Debt_Mgt_Treatment__c == 'SUBL'){
                        cusRec1.Credit_Term__c = '10';
                    }
                    if(cusRec1.Business_Profile__c == 'NORM' && cusRec1.Debt_Mgt_Treatment__c == 'NORM'){
                        cusRec1.Credit_Term__c = '0';
                    }
                    if(customerRec.Billing_Contact__r.NRIC__c != null){
                        cusRec1.ID_Type__c = 'NRIC';
                        cusRec1.ID_No__c = customerRec.Billing_Contact__r.NRIC__c;
                    }
                    //START UD-1527 6/23/15 Added by Manolo Valena - Added else condition for passport field value.
                    else {
                        if(customerRec.Billing_Contact__r.Passport__c != null) {
                            cusRec1.ID_Type__c = GlobalVariableClass.PASS;
                            cusRec1.ID_No__c = customerRec.Billing_Contact__r.Passport__c;
                        }
                    }
                    //END UD-1527 6/23/15 Added by Manolo Valena
                    
                    //START: UD-1528 07/07/2015 Added by S.Puli
                    if(customerRec.Zuora__Account__r.Staff_ID__c <> null){
                        cusRec1.SPH_Staff_Indicator__c = GlobalVariableClass.STRING_Y;
                    }
                    //END: UD-1528 07/07/2015 Added by S.Puli
                    //END: D-995 12/05/14 Added by S.Puli
                    
                    BT_CO_ARMS_CreateCustAccountFile__c cusRec2 = new BT_CO_ARMS_CreateCustAccountFile__c(
                        Customer_Name1__c = customerRec.Name,
                        Customer_Status__c = ConstantsSLB.getOther('ARMS_CusSts'),
                        Reference_Key__c = referenceKey,
                        Unique_Key__c = uniqueKey,
                        //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
                        Business_Profile__c = paymentInfo.armsBusinessProfile, 
                        //END: D-995 12/05/14 Added by S.Puli
                        Account_Type__c = ConstantsSLB.getOther('ARMS_AccTyp'),
                        Credit_Limit_External__c = ConstantsSLB.getOther('ARMS_CrLmtExt'),
                        Credit_Limit_Internal__c = ConstantsSLB.getOther('ARMS_CrLmtInt'),
                        //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
                        Debt_Mgt_Treatment__c = paymentInfo.armsDebtManagement,
                        //END: D-995 12/05/14 Added by S.Puli
                        //START: UD-1557 11/06/2015 Added by S.Puli
                        //Start UD-3411 Added By S.Puli - Ensure value for Create_Id__c
                        Create_Id__c = cusRec1.Create_Id__c,
                        //End UD-3411 Added By S.Puli - Ensure value for Create_Id__c
                        //END: UD-1557 11/06/2015 Added by S.Puli
                        //START UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        //Sub_Contact_Name__c = customerRec.Zuora__BillToName__c,
                        //END UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        //Sub_Contact_Designation__c,
                        Sub_Contact_Type__c=GlobalVariableClass.STRING_O,
                        //Sub_ContactNo_Email__c,
                        //Sub_Contact_Ext__c,
                        Record_Type__c = 'Detail',
                        //START: UD-0964/095 04/22/2015 Added by S.PULI
                        //START UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        Status__c = 'New'
                        //Sub_Contact_Designation__c = customerRec.Zuora__Account__r.Designation__c,
                        //START: UD-1527 11/06/2015 Added by S.Puli - Remove
                        // REMOVE Sub_ContactNo_Email__c = customerRec.Billing_Contact__r.Office_Number__c,
                        //END: UD-1527 11/06/2015 Added by S.Puli
                        //Sub_Contact_Ext__c = customerRec.Billing_Contact__r.Office_Extension__c //START/END UD-0118 5/20/15 MGaelo Change OfficeExtension into phone
                        //END UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        //END: UD-0964/095 04/22/2015 Added by S.PULI

                    );
                    //START: UD-1527 11/06/2015 Added by S.Puli - Add
                    if(customerRec.Billing_Contact__r.Office_Number__c <>  null){
                        cusRec2.Sub_ContactNo_Email__c = customerRec.Billing_Contact__r.Office_Number__c;
                    }else {
                        cusRec2.Sub_Contact_Type__c = null;
                        cusRec2.Sub_ContactNo_Email__c = '0';
                    }
                    //END: UD-1527 11/06/2015 Added by S.Puli
                    BT_CO_ARMS_CreateCustAccountFile__c cusRec3 = null;
                    BT_CO_ARMS_CreateCustAccountFile__c cusRec4 = null;
                    BT_CO_ARMS_CreateCustAccountFile__c cusRec5 = null;
                    BT_CO_ARMS_CreateCustAccountFile__c cusRec6 = null;

                    if(customerRec.Billing_Contact__r.HomePhone__c != null){
                        cusRec3 = cusRec2.clone();
                        cusRec3.Sub_Contact_Type__c = GlobalVariableClass.STRING_H;
                        cusRec3.Sub_ContactNo_Email__c = customerRec.Billing_Contact__r.HomePhone__c;
                        cusRec3.Sub_Contact_Ext__c = '';
                    }
                    
                    if(customerRec.Billing_Contact__r.Mobile_Number__c != null || customerRec.Billing_Contact__r.Mobile_Number_2__c != null){
                        cusRec4 = cusRec2.clone();
                        cusRec4.Sub_Contact_Type__c=GlobalVariableClass.STRING_M;
                        cusRec4.Sub_ContactNo_Email__c = (customerRec.Billing_Contact__r.Mobile_Number__c != null ? customerRec.Billing_Contact__r.Mobile_Number__c : customerRec.Billing_Contact__r.Mobile_Number_2__c);
                        cusRec4.Sub_Contact_Ext__c = '';
                    }
                    //START: UD-1527 11/06/2015 Added by S.Puli
                    if(customerRec.Billing_Contact__r.Fax__c != null){
                    //END: UD-1527 11/06/2015 Added by S.Puli
                        cusRec5 = cusRec2.clone();
                        cusRec5.Sub_Contact_Type__c = GlobalVariableClass.STRING_F;
                        //START: UD-1527 11/06/2015 Added by S.Puli
                        cusRec5.Sub_ContactNo_Email__c = customerRec.Billing_Contact__r.Fax__c;
                        //END: UD-1527 11/06/2015 Added by S.Puli
                        cusRec5.Sub_Contact_Ext__c = '';
                    }
                    
                    if(customerRec.Billing_Contact__r.Email != null){
                        cusRec6 = cusRec2.clone();
                        cusRec6.Sub_Contact_Type__c=GlobalVariableClass.STRING_E;
                        cusRec6.Sub_ContactNo_Email__c = customerRec.Billing_Contact__r.Email;
                        cusRec6.Sub_Contact_Ext__c = '';
                    }
                    //START D-3775 10/29/15 RReyes
                    String tempContCreate = '';
                    if(cusRec1 != null){
                        if(cusRec1.Sub_ContactNo_Email__c != null){
                            tempContCreate = cusRec1.Sub_ContactNo_Email__c;
                            if(tempContCreate.length() > 40){
                                cusRec1.Sub_ContactNo_Email__c = tempContCreate.subString(0, 40);
                            }
                        }
                    }
                    if(cusRec2 != null){
                        if(cusRec2.Sub_ContactNo_Email__c != null){
                            tempContCreate = cusRec2.Sub_ContactNo_Email__c;
                            if(tempContCreate.length() > 40){
                                cusRec2.Sub_ContactNo_Email__c = tempContCreate.subString(0, 40);
                            }
                        }
                    }
                    if(cusRec3 != null){
                        if(cusRec3.Sub_ContactNo_Email__c != null){
                            tempContCreate = cusRec3.Sub_ContactNo_Email__c;
                            if(tempContCreate.length() > 40){
                                cusRec3.Sub_ContactNo_Email__c = tempContCreate.subString(0, 40);
                            }
                        }
                    }
                    if(cusRec4 != null){
                        if(cusRec4.Sub_ContactNo_Email__c != null){
                            tempContCreate = cusRec4.Sub_ContactNo_Email__c;
                            if(tempContCreate.length() > 40){
                                cusRec4.Sub_ContactNo_Email__c = tempContCreate.subString(0, 40);
                            }
                        }
                    }
                    if(cusRec5 != null){
                        if(cusRec5.Sub_ContactNo_Email__c != null){
                            tempContCreate = cusRec5.Sub_ContactNo_Email__c;
                            if(tempContCreate.length() > 40){
                                cusRec5.Sub_ContactNo_Email__c = tempContCreate.subString(0, 40);
                            }
                        }
                    }
                    if(cusRec6 != null){
                        if(cusRec6.Sub_ContactNo_Email__c != null){
                            tempContCreate = cusRec6.Sub_ContactNo_Email__c;
                            if(tempContCreate.length() > 40){
                                cusRec6.Sub_ContactNo_Email__c = tempContCreate.subString(0, 40);
                            }
                        }
                    }
                    //END D-3775 10/29/15 RReyes
                    
                    cusToCreateBatchList.add(cusRec1);
                    cusToInsertBatchList.add(cusRec1);
                    //START UD-2418 02-Sept-2015 Added By S.Puli 
                    if(cusRec2.Sub_Contact_Type__c <> null){
                        cusToInsertBatchList.add(cusRec2);
                    }
                    //END UD-2418 02-Sept-2015 Added By S.Puli 
                    if(cusRec3 != null) cusToInsertBatchList.add(cusRec3);
                    if(cusRec4 != null) cusToInsertBatchList.add(cusRec4);
                    if(cusRec5 != null) cusToInsertBatchList.add(cusRec5);
                    if(cusRec6 != null) cusToInsertBatchList.add(cusRec6);
                    baCusIdSet.add(customerRec.Id);
                //START: UD-1557 11/06/2015 Added by S.Puli 
                }
                //END: UD-1557 11/06/2015 Added by S.Puli
            }
                
            //START: UD-0963 04/24/2015 Added by S.PULI
            if(createFileToDelete.size()>0){
                Database.delete(createFileToDelete, false);
            }
            //END: UD-0963 04/24/2015 Added by S.PULI
            
            if(cusToCreateBatchList<>null && cusToCreateBatchList.size()>0){
            
                insert cusToInsertBatchList;
            
                for(BT_CO_ARMS_CreateCustAccountFile__c accBatch : cusToCreateBatchList){
                    batchCustSet.add(accBatch.Id);
                }
            }
           
            createCustomerWebservice(batchCustSet, baCusIdSet);
    
        }
        
        //list of ARMS account to create in ARMS
        //START D-2760 14-Apr-2015 Raviteja - Commented - added new fields
        //START: UD-1557 11/06/2015 Added by S.Puli
        List<Zuora__CustomerAccount__c> billAccToCreateList = [Select Id, Name, Status__c, Zuora__Account__c, Zuora__Account__r.Name, Zuora__AccountNumber__c, ARMS_Business_Profile__c, ARMS_Debt_Management__c, CreatedById,ARMS_Account_Number__c,ARMS_Customer_Number__c,ARMS_ID__c,Billing_Type__c,Payment_Mode__c,Other_PaymentMethod__c,SOA_Grouping__c From Zuora__CustomerAccount__c Where Id In :ACCorderIdCusNumMap.keyset()];
        
        Set<Id> billIds_SET = new Set<Id>();
        List<Zuora__Subscription__c> newSubsList = new List<Zuora__Subscription__c>();
        Map<Id, String> billAccToOrderAlias_MAP = new Map<Id, String>();
        
        if(billAccToCreateList.size()>0){
            for(Zuora__CustomerAccount__c zRec : billAccToCreateList){
                billIds_SET.add(zRec.Id);
            }
            
            if(billIds_SET.size()>0){
                newSubsList = [Select Id, Name, Zuora__CustomerAccount__c, Order_Number_1__r.Billing_Account_Creation_Mode__c, Order_Number_1__r.CreatedBy.Alias from Zuora__Subscription__c Where Zuora__CustomerAccount__c IN :billIds_SET AND Order_Number_1__r.Billing_Account_Creation_Mode__c = :GlobalVariableClass.CREATE_NEW_BILLACC Limit 1];
                if(newSubsList.size()>0){
                    for(Zuora__Subscription__c zSub : newSubsList){
                        if(!billAccToOrderAlias_MAP.containsKey(zSub.Zuora__CustomerAccount__c)){
                            billAccToOrderAlias_MAP.put(zSub.Zuora__CustomerAccount__c, zSub.Order_Number_1__r.CreatedBy.Alias);
                        }
                    }
                }
            }
        
        }
        //END: UD-1557 11/06/2015 Added by S.Puli
        //END D-2760 14-Apr-2015 Raviteja 
        
        System.debug('SZ1 -------> ' + billAccToCreateList.size());
        System.debug('SZ2 -------> ' + billAccToCreateList);
        Set<Id> baAccIdSet = new Set<Id>();
        
        //START: UD-0963 04/24/2015 Added by S.PULI
        Set<String> cusCusNum_SET = new Set<String>();
        
        if(billAccToCreateList.size()>0){
            for(Zuora__CustomerAccount__c ba : billAccToCreateList){
                if(ACCorderIdCusNumMap.containskey(ba.Id)){
                    cusCusNum_SET.add(ACCorderIdCusNumMap.get(ba.Id));
                }
            }
        }
        
        System.debug('SZ3 -------> ' + cusCusNum_SET.size());
        System.debug('SZ4 -------> ' + cusCusNum_SET);
        
        List<BT_CO_ARMS_CreateAccountBatchFile__c> createAccFile_LIST = [Select Id, CCRID__c, CreatedDate From BT_CO_ARMS_CreateAccountBatchFile__c Where CreatedDate = Today AND CCRID__c In :cusCusNum_SET];
        
        Map<Id, List<BT_CO_ARMS_CreateAccountBatchFile__c>> createAccMasterToDetail_MAP = new Map<Id, List<BT_CO_ARMS_CreateAccountBatchFile__c>>();
        
        List<BT_CO_ARMS_CreateAccountBatchFile__c> createAccFileToDelete = new List<BT_CO_ARMS_CreateAccountBatchFile__c>();
        
        if(billAccToCreateList.size()>0 && createAccFile_LIST.size()>0){
            for(Zuora__CustomerAccount__c billRec : billAccToCreateList){
                for(BT_CO_ARMS_CreateAccountBatchFile__c bFile : createAccFile_LIST){
                    if(ACCorderIdCusNumMap.containskey(billRec.Id)){
                    
                        if(ACCorderIdCusNumMap.get(billRec.Id) == bFile.CCRID__c){
                            if(createAccMasterToDetail_MAP.containskey(billRec.Id)){
                                createAccMasterToDetail_MAP.get(billRec.Id).add(bFile);
                            }else{
                                createAccMasterToDetail_MAP.put(billRec.Id, new List<BT_CO_ARMS_CreateAccountBatchFile__c>{bFile});
                            }
                        }
                    }
                }
            }
        }
        System.debug('SZ5 -------> ' + createAccFile_LIST.size() + ' ---> ' + createAccFile_LIST);
        System.debug('SZ6 -------> ' + createAccMasterToDetail_MAP.size() + ' ---> ' + createAccMasterToDetail_MAP);
        
        
        //END: UD-0963 04/24/2015 Added by S.PULI
        
        if(billAccToCreateList<>null && billAccToCreateList.size()>0){  
        
            for(Zuora__CustomerAccount__c billAccRec : billAccToCreateList){
                //START: UD-1557 11/06/2015 Added by S.Puli
                if(billAccToOrderAlias_MAP.containsKey(billAccRec.Id)){
                //END: UD-1557 11/06/2015 Added by S.Puli
                    //START: UD-0963 04/24/2015 Added by S.PULI
                    if(createAccMasterToDetail_MAP.containskey(billAccRec.Id)){
                        if(createAccMasterToDetail_MAP.get(billAccRec.Id).size()>0){
                            for(BT_CO_ARMS_CreateAccountBatchFile__c bAcc : createAccMasterToDetail_MAP.get(billAccRec.Id)){
                                createAccFileToDelete.add(bAcc);
                            }
                        }
                    }
                    //END: UD-0963 04/24/2015 Added by S.PULI
                    
                    System.debug('SZ7 -------> ' + createAccFileToDelete.size() + ' ---> ' + createAccFileToDelete);
                    
                    //PaymentInfoWrapper paymentInfo = billingAccountId_paymentInfoWrapper.get(billAccRec.Id);
                    Order__c tmpOrder = billingAccountId_order.get(billAccRec.Id);
                    
                    System.debug('SZ8 -------> is Order null ' + (tmpOrder == null));
                    
                    BT_CO_ARMS_CreateAccountBatchFile__c accRec = new BT_CO_ARMS_CreateAccountBatchFile__c(
                        
                        Company_Code__c = ConstantsSLB.getOther('ARMS_CoyCd'),
                        CCRID__c = ACCorderIdCusNumMap.get(billAccRec.Id),
                        Account_Type__c = ConstantsSLB.getOther('ARMS_AccTyp'),
                        Debt_Management_Treatment__c = ACCorderIdDebtMgTrMap.get(billAccRec.Id),
                        //START: UD-1557 11/06/2015 Added by S.Puli
                        //Start UD-3411 Added By S.Puli - Ensure value for Create_Id__c
                        //Creator_ID__c = billAccToOrderAlias_MAP.get(billAccRec.Id),
                        //End UD-3411 Added By S.Puli - Ensure value for Create_Id__c
                        //END: UD-1557 11/06/2015 Added by S.Puli
                        //Credit_Term__c = tmpOrder.ARMS_Credit_Term__c,
                        Credit_Term_Refererence__c = 'I',
                        Credit_Limit_Internal__c = tmpOrder.Credit_Limit_Internal_Limit__c,
                        Credit_Limit_External__c = tmpOrder.Credit_Limit_External_Limit__c,
                        Approved_Debt_Exposure_Amount__c = tmpOrder.Approved_Debt_Exposure_Amount__c,
                        Cust_Giro_Acct_Number__c = tmpOrder.Cust_Giro_Acct_Number__c,
                        Cust_Giro_Bank_Number__c = tmpOrder.Cust_Giro_Bank_Number__c,
                        Business_Sector__c = tmpOrder.Business_Sector__c,
                        SOA_Suppression_Indicator__c = tmpOrder.SOA_Suppression_Indicator__c,
                        Transient_Indicator__c = tmpOrder.Transient_Indicator__c
                        
                    );
                        //Start UD-3411 Added By S.Puli - Ensure value for Create_Id__c
                        if(billAccToOrderAlias_MAP.get(billAccRec.Id) <> null){
                            accRec.Creator_ID__c = billAccToOrderAlias_MAP.get(billAccRec.Id);
                        }else if(billAccRec.CreatedBy.Alias <> null){
                            accRec.Creator_ID__c = billAccRec.CreatedBy.Alias;
                        }
                        //End UD-3411 Added By S.Puli - Ensure value for Create_Id__c
                        //START: UD-1528 11/06/2015 Added by S.Puli
                        //START: UD-1557 11/06/2015 Added by S.Puli
                        if(accRec.Credit_Limit_Internal__c == null){
                            accRec.Credit_Limit_Internal__c = ConstantsSLB.getOther('ARMS_CrLmtInt');
                        }
                        if(accRec.Credit_Limit_External__c == null){
                            accRec.Credit_Limit_External__c = ConstantsSLB.getOther('ARMS_CrLmtExt');
                        }
                        if(accRec.Approved_Debt_Exposure_Amount__c == null){
                            accRec.Approved_Debt_Exposure_Amount__c = ConstantsSLB.getOther('ARMS_DbtExp');
                        }   
                        //END: UD-1557 11/06/2015 Added by S.Puli
                        //END: UD-1528 11/06/2015 Added by S.Puli

                    //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
                        if(accRec.Debt_Management_Treatment__c=='NORM'){
                            accRec.Credit_Term__c = '0';
                        }
                        if(accRec.Debt_Management_Treatment__c=='SUBH'){
                            accRec.Credit_Term__c = '15';
                        }
                        if(accRec.Debt_Management_Treatment__c=='SUBL'){
                            accRec.Credit_Term__c = '10';
                        }
                        if(accRec.Debt_Management_Treatment__c=='GOVT'){
                            accRec.Credit_Term__c = '30';
                        }
                    //END: D-995 12/05/14 Added by S.Puli      
                    //START: UD-1557 11/06/2015 Added by S.Puli
                    accRec.SOA_Group__c = billAccRec.SOA_Grouping__c;
                    //END: UD-1557 11/06/2015 Added by S.Puli
                    billAccRec.ARMS_Customer_Number__c = ACCorderIdCusNumMap.get(billAccRec.Id);
                    
                    //START D-2760 15-Apr-2015 Added by Raviteja - Values copy over from Prepaid/Full Prepaid/PostPaid billing account of the same ARMS Customer Number
                    billAccRec.ARMS_ID__c = ACCorderIdCusNumMap.get(billAccRec.Id); 
                    
                    List<Zuora__CustomerAccount__c> existingbillingAccount = [Select Id,Name,Billing_Type__c, ARMS_Customer_Number__c,ARMS_Business_Profile__c,ARMS_Account_Number__c from Zuora__CustomerAccount__c where ARMS_Customer_Number__c =:ACCorderIdCusNumMap.get(billAccRec.Id) AND (Billing_Type__c = 'Prepaid' OR Billing_Type__c = 'Postpaid') limit 1];
                    
                    if(existingbillingAccount != Null  && existingbillingAccount.size()>0){
                        if(billAccRec.ARMS_Business_Profile__c == Null && existingbillingAccount[0].ARMS_Business_Profile__c != Null)
                            billAccRec.ARMS_Business_Profile__c = existingbillingAccount[0].ARMS_Business_Profile__c;
                        if(billAccRec.ARMS_Account_Number__c == Null && existingbillingAccount[0].ARMS_Account_Number__c != Null)    
                            billAccRec.ARMS_Account_Number__c = existingbillingAccount[0].ARMS_Account_Number__c;
                    }
                    
                    //End D-2760 15-Apr-2015 Added by Raviteja
                    
                    accToCreateBatchList.add(accRec);
                    baAccIdSet.add(billAccRec.Id);
                    
                    System.debug('SZ9 -------> '+ accToCreateBatchList.size() +' ----> '+accToCreateBatchList);
                    System.debug('SZ10 -------> '+ baAccIdSet.size() + ' ---> ' +baAccIdSet);
                //START: UD-1557 11/06/2015 Added by S.Puli
                }
                //END: UD-1557 11/06/2015 Added by S.Puli
            } 
            
            
            if(billAccToCreateList<>null && billAccToCreateList.size()>0){
                System.debug('SZ11 -------> Updating billing account ----> ' + billAccToCreateList.size());
                update billAccToCreateList;
            }
                    
            //START: UD-0963 04/24/2015 Added by S.PULI
            if(createAccFileToDelete.size()>0){
                System.debug('SZ12 -------> Deleting ---->' + createAccFileToDelete.size());
                Database.delete(createAccFileToDelete, false);
            }
            //END: UD-0963 04/24/2015 Added by S.PULI
            if(accToCreateBatchList<>null && accToCreateBatchList.size()>0){
                System.debug('SZ13 -------> Inserting --->' + accToCreateBatchList.size());
                insert accToCreateBatchList;
            
                for(BT_CO_ARMS_CreateAccountBatchFile__c accBatch : accToCreateBatchList){
                    batchAccSet.add(accBatch.Id);
                }
            }
            System.debug('SZ14 -------> Calling out --->' + batchAccSet.size());
            createAccountWebservice(batchAccSet, baAccIdSet);
        }

    }
    
    //START uat hot fix 05/27/2015
    public void updateAccount(List<Zuora__CustomerAccount__c> updInitialBillAccList){
    //END uat hot fix 05/27/2015    
        Set<Id> AccToUpdSet = new Set<Id>();
        
        List<BT_CO_ARMS_UpdateAccountBatchFile__c> bAccList = new List<BT_CO_ARMS_UpdateAccountBatchFile__c>();
        
        List<Zuora__CustomerAccount__c> zCusTOUpdList = new List<Zuora__CustomerAccount__c>();
        
        //START uat hot fix 05/27/2015
        //START: UD-1527 11/06/2015 Added by S.Puli
        List<Zuora__CustomerAccount__c> updBillAccList = new List<Zuora__CustomerAccount__c>();
        Set<Id> updAccIds_SET = new Set<Id>();
        if(updInitialBillAccList.size()>0){
            for(Zuora__CustomerAccount__c z : updInitialBillAccList){   
                updAccIds_SET.add(z.Id);
            }
            updBillAccList = [Select ARMS_ID__c,Other_PaymentMethod__c,ARMS_Customer_Number__c,Billing_Contact__r.Address__r.Country__r.code__c,
            Billing_Contact__r.Address__r.Postal_Code__r.Service_Number__c,Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c,
            Billing_Contact__r.Address__r.Department__r.Department_Name__c,Billing_Contact__r.Address__r.Division_Code__r.Department_Name__c,
            Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c, Billing_Contact__r.Address__r.City__r.City_Name__c,
            Billing_Contact__r.Address__r.Airline_Number__c,Billing_Contact__r.Address__r.Flight_Number_1__c,Billing_Contact__r.Address__r.Flight_Number_2__c,
            Billing_Contact__r.Office_Number__c,Zuora__Account__r.Designation__c,Billing_Contact__r.Address__r.recordType.developerName,
            Zuora__Account__r.Attention_To_Care_Of__c,Zuora__Account__r.Attention_Care_Off_ind__c,Billing_Contact__r.Address__r.Address_1__c,
            Billing_Contact__r.Address__r.Address_2__c,Billing_Contact__r.Address__r.Address_3__c,Billing_Contact__r.Address__r.Address_4__c,
            Billing_Contact__r.Address__r.Building_Name_2__c,Billing_Contact__r.Address__r.Street_Name__c,Billing_Contact__r.Address__r.Unit_Number__c,
            Billing_Contact__r.Address__r.Level_Number__c,Billing_Contact__r.Address__r.Block_House_Number__c,Billing_Contact__r.Address__r.Country__c,
            Billing_Contact__r.Address__r.Postal_Code__r.name,SOA_Grouping__c,Billing_Contact__r.NRIC__c,CreatedBy.name,Id,Name, Status__c, 
            Zuora__Account__c, Zuora__Account__r.Name, Zuora__Account__r.AccountNumber, Zuora__AccountNumber__c, ARMS_Business_Profile__c,
            ARMS_Debt_Management__c, Zuora__BillToAddress1__c, Zuora__BillToAddress2__c, Zuora__BillToPostalCode__c, Zuora__BillToCity__c, 
            Zuora__BillToCountry__c, Zuora__BillToName__c,Billing_Contact__r.Email,Billing_Contact__r.Office_Extension__c,Billing_Contact__r.HomePhone__c,
            //START UD-1527 6/23/15 Added by Manolo Valena - Added passport field.
            Billing_Contact__r.Passport__c,
            //END UD-1527 6/23/15 Added by Manolo Valena
            Billing_Contact__r.Handphone_Number__c,Billing_Contact__r.Fax__c, LastModifiedBy.Name, ARMS_Account_Number__c, ARMS_Account_Type__c, Credit_Term__c, Credit_Reference__c, Credit_Limit_Internal__c, Credit_Limit_External__c, Approved_Debt_Exposure_Amount__c, Business_Sector__c From Zuora__CustomerAccount__c Where Id In :updAccIds_SET];
        }
        //END: UD-1527 11/06/2015 Added by S.Puli
        //END uat hot fix 05/27/2015
        
        //START: UD-0964/095 04/22/2015 Added by S.PULI
        Set<String> updAccCusNum_SET = new Set<String>();
        Set<String> updAccNum_SET = new Set<String>();
        if(updBillAccList.size()>0){
            for(Zuora__CustomerAccount__c z : updBillAccList){
                updAccCusNum_SET.add(z.ARMS_Customer_Number__c);
                updAccNum_SET.add(z.ARMS_Account_Number__c);
            }
        }
        
        List<BT_CO_ARMS_UpdateAccountBatchFile__c> oldAccToUpdRec_LIST = [Select Id, Name, Account_Number__c, CCRID__c,CreatedDate From BT_CO_ARMS_UpdateAccountBatchFile__c Where CCRID__c IN :updAccCusNum_SET AND Account_Number__c IN :updAccNum_SET AND CreatedDate = Today];
        
        Map<Id, List<BT_CO_ARMS_UpdateAccountBatchFile__c>> updAccBatchFile_MAP = new Map<Id, List<BT_CO_ARMS_UpdateAccountBatchFile__c>>();
        
        List<BT_CO_ARMS_UpdateAccountBatchFile__c> updAccToDelete_LIST = new List<BT_CO_ARMS_UpdateAccountBatchFile__c>();
        
        if(oldAccToUpdRec_LIST.size()>0 && updBillAccList.size()>0){
            for(Zuora__CustomerAccount__c zCus : updBillAccList){
                for(BT_CO_ARMS_UpdateAccountBatchFile__c bAcc : oldAccToUpdRec_LIST){
                    if(zCus.ARMS_Customer_Number__c == bAcc.CCRID__c && zCus.ARMS_Account_Number__c == bAcc.Account_Number__c){
                        if(updAccBatchFile_MAP.containskey(zCus.Id)){
                            updAccBatchFile_MAP.get(zCus.Id).add(bAcc);
                        } else{
                            updAccBatchFile_MAP.put(zCus.Id, new List<BT_CO_ARMS_UpdateAccountBatchFile__c>{bAcc});
                        }
                    }
                }
            }
        }
        
        //END: UD-0964/095 04/22/2015 Added by S.PULI
        
        if(updBillAccList.size()>0 && updBillAccList<>null){
            for(Zuora__CustomerAccount__c ba : updBillAccList){
                if(ba.Other_PaymentMethod__c == 'Invoice'){
                
                    //START: UD-0964/095 04/22/2015 Added by S.PULI
                    if(updAccBatchFile_MAP.containskey(ba.Id)){
                        if(updAccBatchFile_MAP.get(ba.Id).size()>0){
                            for(BT_CO_ARMS_UpdateAccountBatchFile__c brec : updAccBatchFile_MAP.get(ba.Id)){
                                updAccToDelete_LIST.add(brec);
                            }
                        }
                    }
                    //END: UD-0964/095 04/22/2015 Added by S.PULI
                    
                    BT_CO_ARMS_UpdateAccountBatchFile__c accToUpdRec = new BT_CO_ARMS_UpdateAccountBatchFile__c();
                        accToUpdRec.CCRID__c = ba.ARMS_ID__c;
                        accToUpdRec.Account_Number__c = ba.ARMS_Account_Number__c;
                        accToUpdRec.Account_Type__c = 'SS';
                        accToUpdRec.Credit_Term__c = String.ValueOf(ba.Credit_Term__c);
                        accToUpdRec.Credit_Term_Reference__c =  ConstantsSLB.getOther('ARMS_CrTrmRef');
                        //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
                        if(ba.Credit_Limit_Internal__c!= null && String.ValueOf(ba.Credit_Limit_Internal__c).substringBefore('.').length()<11){
                            Integer iCLI = 11-String.ValueOf(ba.Credit_Limit_Internal__c).substringBefore('.').length();
                            String credInt = '00000000000';
                            String aInt = credInt.substring(0,iCLI);
                            String bInt = aInt+String.ValueOf(ba.Credit_Limit_Internal__c).substringBefore('.');
                            
                            accToUpdRec.Credit_Limit_Internal__c = bInt;
                        } else if(ba.Credit_Limit_Internal__c!= null){
                            accToUpdRec.Credit_Limit_Internal__c = String.ValueOf(ba.Credit_Limit_Internal__c).substringBefore('.');
                        } else { 
                            accToUpdRec.Credit_Limit_Internal__c = '00000000000';
                        }
                        
                        if(ba.Credit_Limit_External__c != null && String.ValueOf(ba.Credit_Limit_External__c).substringBefore('.').length()<11){
                            Integer iCLE = 11-String.ValueOf(ba.Credit_Limit_External__c).substringBefore('.').length();
                            String credExt = '00000000000';
                            String aExt = credExt.substring(0,iCLE);
                            String bExt = aExt+String.ValueOf(ba.Credit_Limit_External__c).substringBefore('.');
                            
                            accToUpdRec.Credit_Limit_External__c = bExt;
                        } else if(ba.Credit_Limit_External__c != null){
                            accToUpdRec.Credit_Limit_External__c = String.ValueOf(ba.Credit_Limit_External__c).substringBefore('.');
                        } else {
                            accToUpdRec.Credit_Limit_External__c = '00000000000';
                        }
                        
                        if(ba.Approved_Debt_Exposure_Amount__c != null && String.ValueOf(ba.Approved_Debt_Exposure_Amount__c).substringBefore('.').length()<11){
                            Integer iDebtExp = 11-String.ValueOf(ba.Approved_Debt_Exposure_Amount__c).substringBefore('.').length();
                            String credExt = '00000000000';
                            String aDeb = credExt.substring(0,iDebtExp);
                            String bDeb = aDeb+String.ValueOf(ba.Approved_Debt_Exposure_Amount__c).substringBefore('.');
                        
                            accToUpdRec.Approved_Debt_Exposure_Amount__c = bDeb;
                        } else if(ba.Approved_Debt_Exposure_Amount__c != null){
                            accToUpdRec.Approved_Debt_Exposure_Amount__c = String.ValueOf(ba.Approved_Debt_Exposure_Amount__c).substringBefore('.');
                        } else {
                            accToUpdRec.Approved_Debt_Exposure_Amount__c = '00000000000';
                        }
                        
                        //END: D-995 12/05/14 Added by S.Puli 
                        accToUpdRec.Debt__c = ba.ARMS_Debt_Management__c;
                        if(ba.lastmodifiedby.name.length() > 15){
                            accToUpdRec.Update_ID__c = ba.lastmodifiedby.name.substring(0, 15);
                        } else{
                            accToUpdRec.Update_ID__c = ba.lastmodifiedby.name;
                        }     
                            String datedata = String.valueOf(date.today());
                            String datestring = datedata.replace('-','');
                        accToUpdRec.Update_Date__c = datestring;
                            String timedata = String.valueOf(Datetime.now());
                            String timesubstring = timedata.substringAfter(' ');
                            String timestring = timesubstring.replace(':','');
                        accToUpdRec.Update_Time__c = timestring;
                        accToUpdRec.Business_Sector__c = ba.Business_Sector__c;
                        accToUpdRec.SoaGroup__c = ba.SOA_Grouping__c;
                        accToUpdRec.Company_Code__c = ConstantsSLB.getOther('ARMS_CoyCd');
                        //accToUpdRec.SOA_Suppression_Indicator__c
                        //accToUpdRec.Transient_Indicator__c
                        
                    bAccList.add(accToUpdRec);
                    zCusTOUpdList.add(ba);
                }
            }
            //START: UD-0964/095 04/22/2015 Added by S.PULI
            if(updAccToDelete_LIST.size()>0){
                Database.delete(updAccToDelete_LIST, false);
            }
            //END: UD-0964/095 04/22/2015 Added by S.PULI
            if(bAccList<>null && bAccList.size()>0){
            
            insert bAccList;
            
                for(BT_CO_ARMS_UpdateAccountBatchFile__c a : bAccList){
                    AccToUpdSet.add(a.Id);
                }
            }
            
           updateAccountWebservice(AccToUpdSet); 
        }
    
    }
    //START: D-1013 12/06/14 Added by S.Puli - add method to Update Customer online to ARMS
    public void updateCustomer(List<Zuora__CustomerAccount__c> edtCustomerList){
        
        Set<Id> CusToUpdSet = new Set<Id>();
        
        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> bCusList = new List<BT_CO_ARMS_UpdateCustomerBatchFile__c>();
        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> bCusInsertList = new List<BT_CO_ARMS_UpdateCustomerBatchFile__c>();
        
        Set<Id> queryBillAccSet = new Set<Id>();
        if(edtCustomerList<>null && edtCustomerList.size()>0){
            for(Zuora__CustomerAccount__c zc : edtCustomerList){
                queryBillAccSet.add(zc.Id);
            }
        }
        
        //List<Zuora__CustomerAccount__c> zCusToUpdList = new List<Zuora__CustomerAccount__c>();
        //START: UD-0964/095 04/22/2015 Added by S.PULI
        //List<Zuora__CustomerAccount__c> customerToCreateList = [Select lastmodifiedby.name,Id,Name, Status__c, Zuora__Account__c, Zuora__Account__r.Name, Zuora__Account__r.AccountNumber, Zuora__AccountNumber__c, ARMS_Business_Profile__c, ARMS_Debt_Management__c, CreatedById, Zuora__BillToAddress1__c, Zuora__BillToAddress2__c, Zuora__BillToPostalCode__c, Zuora__BillToCity__c, Zuora__BillToCountry__c, Zuora__BillToName__c, Other_PaymentMethod__c, ARMS_ID__c, ARMS_Customer_Number__c, Billing_Contact__r.Email,Billing_Contact__r.Office_Extension__c  From Zuora__CustomerAccount__c Where Id In :queryBillAccSet];
        //START: UD-1527 11/06/2015 Added by S.Puli
        //START: UD-1528 07/07/2015 Added by S.Puli
        List<Zuora__CustomerAccount__c> customerToCreateList = [Select lastmodifiedby.name, ARMS_ID__c,Other_PaymentMethod__c,ARMS_Customer_Number__c,Billing_Contact__r.Address__r.Country__r.code__c,
            Billing_Contact__r.Address__r.Postal_Code__r.Service_Number__c,Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c,
            Billing_Contact__r.Address__r.Department__r.Department_Name__c,Billing_Contact__r.Address__r.Division_Code__r.Department_Name__c,
            Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c, Billing_Contact__r.Address__r.City__r.City_Name__c,
            Billing_Contact__r.Address__r.Airline_Number__c,Billing_Contact__r.Address__r.Flight_Number_1__c,Billing_Contact__r.Address__r.Flight_Number_2__c,
            Billing_Contact__r.Office_Number__c,Zuora__Account__r.Designation__c,Billing_Contact__r.Address__r.recordType.developerName,
            Zuora__Account__r.Attention_To_Care_Of__c,Zuora__Account__r.Attention_Care_Off_ind__c,Billing_Contact__r.Address__r.Address_1__c,
            Billing_Contact__r.Address__r.Address_2__c,Billing_Contact__r.Address__r.Address_3__c,Billing_Contact__r.Address__r.Address_4__c,
            Billing_Contact__r.Address__r.Building_Name_2__c,Billing_Contact__r.Address__r.Street_Name__c,Billing_Contact__r.Address__r.Unit_Number__c,
            Billing_Contact__r.Address__r.Level_Number__c,Billing_Contact__r.Address__r.Block_House_Number__c,Billing_Contact__r.Address__r.Country__c,
            Billing_Contact__r.Address__r.Postal_Code__r.name,SOA_Grouping__c,Billing_Contact__r.NRIC__c,CreatedBy.name,Id,Name, Status__c, 
            Zuora__Account__c, Zuora__Account__r.Name, Zuora__Account__r.AccountNumber, Zuora__AccountNumber__c, ARMS_Business_Profile__c,
            ARMS_Debt_Management__c, Zuora__BillToAddress1__c, Zuora__BillToAddress2__c, Zuora__BillToPostalCode__c, Zuora__BillToCity__c, 
            Zuora__BillToCountry__c, Zuora__BillToName__c,Billing_Contact__r.Email,Billing_Contact__r.Office_Extension__c,Billing_Contact__r.HomePhone__c,
            //START UD-1527 6/23/15 Added by Manolo Valena - Added passport field.
            Billing_Contact__r.Passport__c,
            //END UD-1527 6/23/15 Added by Manolo Valena
            Billing_Contact__r.Handphone_Number__c,Billing_Contact__r.Fax__c,Attention_To_Care_Of_Indicator1__c,Attention_To_Care1__c, Billing_Contact__r.Mobile_Number__c, Billing_Contact__r.Mobile_Number_2__c, Billing_Contact__r.Name, Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c, Zuora__Account__r.Attention_To_Care_Of_Indicator__c, Zuora__Account__r.GST_Out_of_Scope__c, Zuora__Account__r.Staff_ID__c From Zuora__CustomerAccount__c Where Id In :queryBillAccSet];
        //END: UD-1528 07/07/2015 Added by S.Puli
        //END: UD-1527 11/06/2015 Added by S.Puli
        //END: UD-0964/095 04/22/2015 Added by S.PULI
        
        //START: UD-0964/095 04/22/2015 Added by S.PULI
        Set<String> updCusName_SET = new Set<String>();
        Set<String> updUniqKey_SET = new Set<String>();
        Set<String> updCusNum_SET = new Set<String>();
        Map<Id, List<BT_CO_ARMS_UpdateCustomerBatchFile__c>> updCusMasterToDetail_MAP = new Map<Id, List<BT_CO_ARMS_UpdateCustomerBatchFile__c>>();
        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> updCusToDelete_LIST = new List<BT_CO_ARMS_UpdateCustomerBatchFile__c>();
        
        
        if(customerToCreateList.size()>0){
            for(Zuora__CustomerAccount__c zc : customerToCreateList){
                updCusName_SET.add(zc.Name);
                updUniqKey_SET.add(zc.Zuora__Account__r.AccountNumber);
                updCusNum_SET.add(zc.ARMS_Customer_Number__c);
            }
        }
        
        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> oldUpdateCusRecord_LIST = [Select Id, CreatedDate,Customer_Name1__c, CCRID__c,Business_Profile__c, UniqueKey__c from BT_CO_ARMS_UpdateCustomerBatchFile__c Where CreatedDate = Today AND Customer_Name1__c IN :updCusName_SET AND UniqueKey__c IN :updUniqKey_SET AND CCRID__c IN :updCusNum_SET];
        
        if(oldUpdateCusRecord_LIST.size()>0 && customerToCreateList.size()>0){
            for(Zuora__CustomerAccount__c zc : customerToCreateList){
                for(BT_CO_ARMS_UpdateCustomerBatchFile__c oldRec : oldUpdateCusRecord_LIST){
                    if(zc.Zuora__Account__r.Name == oldrec.Customer_Name1__c && zc.Zuora__Account__r.AccountNumber == oldrec.UniqueKey__c && zc.ARMS_Customer_Number__c == oldrec.CCRID__c){
                        if(updCusMasterToDetail_MAP.containskey(zc.Id)){
                            updCusMasterToDetail_MAP.get(zc.Id).add(oldRec);
                        } else{
                            updCusMasterToDetail_MAP.put(zc.Id, new List<BT_CO_ARMS_UpdateCustomerBatchFile__c>{oldRec});
                        }
                    }
                }
            }
        }
        
        //END: UD-0964/095 04/22/2015 Added by S.PULI
        //START D-3300 03-Aug-2015 Added by S.Puli
        Map<Id, BT_CO_ARMS_UpdateCustomerBatchFile__c> dupChecker_MAP = new Map<Id, BT_CO_ARMS_UpdateCustomerBatchFile__c>();
        //END D-3300 03-Aug-2015 Added by S.Puli
        if(edtCustomerList.size()>0 && edtCustomerList<>null){
            for(Zuora__CustomerAccount__c ba : customerToCreateList){
                if(ba.Other_PaymentMethod__c == 'Invoice'){
                    //START: UD-0964/095 04/22/2015 Added by S.PULI
                    if(updCusMasterToDetail_MAP.containskey(ba.Id)){
                        if(updCusMasterToDetail_MAP.get(ba.Id).size()>0){
                            for(BT_CO_ARMS_UpdateCustomerBatchFile__c bRec : updCusMasterToDetail_MAP.get(ba.Id)){
                                //START D-3300 03-Aug-2015 Added by S.Puli
                                if(!dupChecker_MAP.containsKey(bRec.Id)){
                                    dupChecker_MAP.put(bRec.Id, bRec);
                                    updCusToDelete_LIST.add(bRec);
                                }
                                //END D-3300 03-Aug-2015 Added by S.Puli
                            }
                        }
                    }
                    //END: UD-0964/095 04/22/2015 Added by S.PULI
                    string referenceKey = ba.Zuora__Account__r.AccountNumber;
                    string uniqueKey = ba.Zuora__Account__r.AccountNumber;
                    
                    if (ba.Zuora__Account__r.AccountNumber != null) {
                        
                        if (ba.Zuora__Account__r.AccountNumber.length() > 10) {
                            
                            referenceKey =  ba.Zuora__Account__r.AccountNumber.substring(0, 10);
                        }

                        if (ba.Zuora__Account__r.AccountNumber.length() > 26) {
                            
                            uniqueKey =     ba.Zuora__Account__r.AccountNumber.substring(0, 26);
                        }
                    }
                    
                    BT_CO_ARMS_UpdateCustomerBatchFile__c updateCusRecord = new BT_CO_ARMS_UpdateCustomerBatchFile__c();
                        updateCusRecord.CCRID__c = ba.ARMS_ID__c;
                        updateCusRecord.Customer_Name1__c = ba.Name;
                        updateCusRecord.UniqueKey__c = uniqueKey;
                        if(ba.lastmodifiedby.name.length() > 15){
                            updateCusRecord.Update_ID__c = ba.lastmodifiedby.name.substring(0, 15);
                        } else{
                            updateCusRecord.Update_ID__c = ba.lastmodifiedby.name;
                        }
                            String datedata = String.valueOf(date.today());
                            String datestring = datedata.replace('-','');
                        updateCusRecord.UpdateDate__c = datestring;
                            String timedata = String.valueOf(Datetime.now());
                            String timesubstring = timedata.substringAfter(' ');
                            String timestring = timesubstring.replace(':','');
                        updateCusRecord.UpdateTime__c = timestring;
                        //updateCusRecord.Postal_Code__c = ba.Zuora__BillToPostalCode__c;
                        //updateCusRecord.City_Zip__c = ba.Zuora__BillToCity__c;
                        //START UD-3171 10/30/2015 Added by K. Tan - Error on Ending position out of bounds: 39     
                        if (ba.Billing_Contact__r.Name.length() > 40){
                            updateCusRecord.Contact_Name__c = ba.Billing_Contact__r.Name.subString(0, 39); //START-END D-3607 Added by J.Sarion - Trim value to 40 chars only       
                        }
                        else{
                            updateCusRecord.Contact_Name__c = ba.Billing_Contact__r.Name;   
                        }
                        //END UD-3171 10/30/2015 Added by K. Tan - Error on Ending position out of bounds: 39  
                        //START UD-2418 02-Sept-2015 Added By S.Puli 
                        updateCusRecord.Contact_Designation__c = ba.Zuora__Account__r.Designation__c;
                        updateCusRecord.Contact_Extension__c = ba.Billing_Contact__r.Office_Extension__c;
                        //END UD-2418 02-Sept-2015 Added By S.Puli                  
                        updateCusRecord.RecordType__c = 'Master';
                        updateCusRecord.Status__c = 'New';
                        //START: UD-0802 04/08/2015 Added by S.PULI
                        updateCusRecord.Business_Profile__c = ba.ARMS_Business_Profile__c;
                        updateCusRecord.ReferenceKey__c = referenceKey;
                        updateCusRecord.SPH_Staff_Indicator__c=GlobalVariableClass.STRING_N;
                        //END: UD-0802 04/08/2015 Added by S.PULI
                        
                        //START: UD-1528 07/07/2015 Added by S.Puli
                        if(ba.Zuora__Account__r.Staff_ID__c <> null){
                            updateCusRecord.SPH_Staff_Indicator__c = GlobalVariableClass.STRING_Y;
                        }
                        //END: UD-1528 07/07/2015 Added by S.Puli
                        if(ba.Billing_Contact__r.NRIC__c != null){
                            updateCusRecord.ID_Type__c = 'NRIC';
                            updateCusRecord.ID_Number__c = ba.Billing_Contact__r.NRIC__c;
                        }
                        //START UD-1527 6/23/15 Added by Manolo Valena - Added else condition for passport field value.
                        else {
                            if(ba.Billing_Contact__r.Passport__c != null) {
                                updateCusRecord.ID_Type__c = GlobalVariableClass.PASS;
                                updateCusRecord.ID_Number__c = ba.Billing_Contact__r.Passport__c;
                            }
                        }
                        //END UD-1527 6/23/15 Added by Manolo Valena
                        
                        //START hotfix 05/28/2015
                        updateCusRecord.Customer_Status__c = GlobalVariableClass.STRING_A;
                        updateCusRecord.CareOf_AttentionTo_Indicator__c = ba.Zuora__Account__r.Attention_To_Care_Of_Indicator__c;
                        updateCusRecord.CareOf_ATtentionTo_Party__c = ba.Attention_To_Care1__c;
                        //END hotfix 05/28/2015
                        //START D-3046 06/03/2015
                        updateCusRecord.GST_OutOfScope_Indicator__c ='';
                        if(ba.Zuora__Account__r.GST_Out_of_Scope__c){
                            updateCusRecord.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_Y;
                        } else{
                            updateCusRecord.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_N;
                        }
                        //END D-3046 06/03/2015

                        if(ba.Billing_Contact__r.Address__r.recordType.developerName == 'Local'){
                            updateCusRecord.Postal_Code__c = ba.Billing_Contact__r.Address__r.Postal_Code__r.name;
                            updateCusRecord.City_Zip__c = '';
                            updateCusRecord.Country__c = ba.Billing_Contact__r.Address__r.Country__r.code__c;
                            updateCusRecord.Block_House_No__c = ba.Billing_Contact__r.Address__r.Block_House_Number__c;
                            updateCusRecord.Floor_No__c = ba.Billing_Contact__r.Address__r.Level_Number__c;
                            updateCusRecord.Unit_No__c = ba.Billing_Contact__r.Address__r.Unit_Number__c;
                            updateCusRecord.Street__c = ba.Billing_Contact__r.Address__r.Street_Name__c;
                            updateCusRecord.Building_Secondary__c = ba.Billing_Contact__r.Address__r.Postal_Code__r.Building_Name__c;
                            updateCusRecord.PO_Box_No__c = ba.Billing_Contact__r.Address__r.Postal_Code__r.Service_Number__c;
                        }
                        
                        if(ba.Billing_Contact__r.Address__r.recordType.developerName == 'Overseas'){
                            updateCusRecord.Address1__c = ba.Billing_Contact__r.Address__r.Address_1__c;
                            updateCusRecord.Address2__c = ba.Billing_Contact__r.Address__r.Address_2__c;
                            updateCusRecord.Address3__c = ba.Billing_Contact__r.Address__r.Address_3__c;
                            updateCusRecord.Address4__c = ba.Billing_Contact__r.Address__r.Address_4__c;
                            updateCusRecord.Country__c = ba.Billing_Contact__r.Address__r.Country__r.code__c;
                        }
                        
                        if(ba.Billing_Contact__r.Address__r.recordType.developerName == 'Internal'){
                            updateCusRecord.Address1__c = ba.Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c;
                            updateCusRecord.Address2__c = ba.Billing_Contact__r.Address__r.Department__r.Department_Name__c;
                            updateCusRecord.Address3__c = ba.Billing_Contact__r.Address__r.Division_Code__r.Department_Name__c;
                            updateCusRecord.Address4__c = ba.Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c;
                            updateCusRecord.Country__c = ba.Billing_Contact__r.Address__r.Country__r.code__c;
                        }
                        
                        if(ba.Billing_Contact__r.Address__r.recordType.developerName == 'Airline'){
                            updateCusRecord.Address1__c = (ba.Billing_Contact__r.Address__r.City__r.City_Name__c.length() > 40 ? ba.Billing_Contact__r.Address__r.City__r.City_Name__c.subString(0,40) : ba.Billing_Contact__r.Address__r.City__r.City_Name__c ) ;
                            updateCusRecord.Address2__c = ba.Billing_Contact__r.Address__r.Airline_Number__c;
                            updateCusRecord.Address3__c = ba.Billing_Contact__r.Address__r.Flight_Number_1__c;
                            updateCusRecord.Address4__c = ba.Billing_Contact__r.Address__r.Flight_Number_2__c;
                            updateCusRecord.Country__c = ba.Billing_Contact__r.Address__r.Country__r.code__c;
                        }
                        
                        /*if(ba.Zuora__BillToAddress1__c<>null){
                            if(ba.Zuora__BillToAddress1__c.length() > 40){
                                updateCusRecord.Address1__c = ba.Zuora__BillToAddress1__c.substring(0, 40);
                            } else {
                                updateCusRecord.Address1__c = ba.Zuora__BillToAddress1__c;
                            }
                        }
                        if(ba.Zuora__BillToAddress2__c<>null){
                            if(ba.Zuora__BillToAddress2__c.length() > 40){
                                updateCusRecord.Address2__c = ba.Zuora__BillToAddress2__c.substring(0, 40);
                            } else {
                                updateCusRecord.Address2__c = ba.Zuora__BillToAddress2__c;
                            }
                        }*/
                        
                        BT_CO_ARMS_UpdateCustomerBatchFile__c updateCusRecord2 = new BT_CO_ARMS_UpdateCustomerBatchFile__c();
                        updateCusRecord2.CCRID__c = ba.ARMS_ID__c;
                        updateCusRecord2.Customer_Name1__c = ba.Name;
                        updateCusRecord2.UniqueKey__c = uniqueKey;
                        if(ba.lastmodifiedby.name.length() > 15){
                            updateCusRecord2.Update_ID__c = ba.lastmodifiedby.name.substring(0, 15);
                        } else{
                            updateCusRecord2.Update_ID__c = ba.lastmodifiedby.name;
                        }
                            String datedata2 = String.valueOf(date.today());
                            String datestring2 = datedata2.replace('-','');
                        updateCusRecord2.UpdateDate__c = datestring2;
                            String timedata2 = String.valueOf(Datetime.now());
                            String timesubstring2 = timedata2.substringAfter(' ');
                            String timestring2 = timesubstring2.replace(':','');
                        updateCusRecord2.UpdateTime__c = timestring2;
                        //updateCusRecord2.Postal_Code__c = ba.Zuora__BillToPostalCode__c;
                        //updateCusRecord2.City_Zip__c = ba.Zuora__BillToCity__c;
                        //START UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        //updateCusRecord2.Contact_Name__c = ba.Billing_Contact__r.Name;
                        //END UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        updateCusRecord2.RecordType__c = 'Detail';
                        updateCusRecord2.Status__c = 'New';
                        //START: UD-0802 04/08/2015 Added by S.PULI
                        updateCusRecord2.Business_Profile__c = ba.ARMS_Business_Profile__c;
                        //END: UD-0802 04/08/2015 Added by S.PULI
                        //START: UD-0964/095 04/22/2015 Added by S.PULI
                        updateCusRecord2.ContactNo_Email__c = ba.Billing_Contact__r.Office_Number__c;
                        updateCusRecord2.Contact_Type__c = GlobalVariableClass.STRING_O;
                        //START UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        //updateCusRecord2.Contact_Designation__c = ba.Zuora__Account__r.Designation__c;
                        //updateCusRecord2.Contact_Extension__c = ba.Billing_Contact__r.Office_Extension__c; //START/END UD-0118 5/20/15 MGaelo change OfficeExtension into phone
                        //END UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                        //START: UD-1528 11/06/2015 Added by S.Puli
                        if(updateCusRecord2.ContactNo_Email__c == null){
                            updateCusRecord2.Contact_Type__c = null;
                        }
                        //END: UD-1528 11/06/2015 Added by S.Puli
                        
                        //END: UD-0964/095 04/22/2015 Added by S.PULI
                        /*if(ba.Zuora__BillToAddress1__c<>null){
                            if(ba.Zuora__BillToAddress1__c.length() > 40){
                                updateCusRecord2.Address1__c = ba.Zuora__BillToAddress1__c.substring(0, 40);
                            } else {
                                updateCusRecord2.Address1__c = ba.Zuora__BillToAddress1__c;
                            }
                        }
                        if(ba.Zuora__BillToAddress2__c<>null){
                            if(ba.Zuora__BillToAddress2__c.length() > 40){
                                updateCusRecord2.Address2__c = ba.Zuora__BillToAddress2__c.substring(0, 40);
                            } else {
                                updateCusRecord2.Address2__c = ba.Zuora__BillToAddress2__c;
                            }
                        }*/
                        //START hotfix 05/28/2015
                        updateCusRecord2.Customer_Status__c = GlobalVariableClass.STRING_A;
                        if(ba.Billing_Contact__r.NRIC__c != null){
                            updateCusRecord2.ID_Type__c = 'NRIC';
                            updateCusRecord2.ID_Number__c = ba.Billing_Contact__r.NRIC__c;
                        }
                        //START UD-1527 6/23/15 Added by Manolo Valena - Added else condition for passport field value.
                        else {
                            if(ba.Billing_Contact__r.Passport__c != null) {
                                updateCusRecord2.ID_Type__c = GlobalVariableClass.PASS;
                                updateCusRecord2.ID_Number__c = ba.Billing_Contact__r.Passport__c;
                            }
                        }
                        //END UD-1527 6/23/15 Added by Manolo Valena
                        updateCusRecord2.CareOf_AttentionTo_Indicator__c = ba.Zuora__Account__r.Attention_To_Care_Of_Indicator__c;
                        updateCusRecord2.CareOf_ATtentionTo_Party__c = ba.Attention_To_Care1__c;
                        //END hotfix 05/28/2015
                        //START D-3046 06/03/2015
                        updateCusRecord2.GST_OutOfScope_Indicator__c ='';
                        if(ba.Zuora__Account__r.GST_Out_of_Scope__c){
                            updateCusRecord2.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_Y;
                        } else{
                            updateCusRecord2.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_N;
                        }
                        //END D-3046 06/03/2015
                        
                        BT_CO_ARMS_UpdateCustomerBatchFile__c cusRec3 = null;
                        BT_CO_ARMS_UpdateCustomerBatchFile__c cusRec4 = null;
                        BT_CO_ARMS_UpdateCustomerBatchFile__c cusRec5 = null;
                        BT_CO_ARMS_UpdateCustomerBatchFile__c cusRec6 = null;

                        if(ba.Billing_Contact__r.HomePhone__c != null){
                            cusRec3 = updateCusRecord2.clone();
                            cusRec3.Contact_Type__c = GlobalVariableClass.STRING_H;
                            cusRec3.ContactNo_Email__c = ba.Billing_Contact__r.HomePhone__c;
                            //START hotfix 05/28/2015
                            cusRec3.Customer_Status__c = GlobalVariableClass.STRING_A;
                            if(ba.Billing_Contact__r.NRIC__c != null){
                                cusRec3.ID_Type__c = 'NRIC';
                                cusRec3.ID_Number__c = ba.Billing_Contact__r.NRIC__c;
                            }
                            //START UD-1527 6/23/15 Added by Manolo Valena - Added else condition for passport field value.
                            else {
                                if(ba.Billing_Contact__r.Passport__c != null) {
                                    cusRec3.ID_Type__c = GlobalVariableClass.PASS;
                                    cusRec3.ID_Number__c = ba.Billing_Contact__r.Passport__c;
                                }
                            }
                            //END UD-1527 6/23/15 Added by Manolo Valena
                            cusRec3.CareOf_AttentionTo_Indicator__c = ba.Zuora__Account__r.Attention_To_Care_Of_Indicator__c;
                            cusRec3.CareOf_ATtentionTo_Party__c = ba.Attention_To_Care1__c;
                            //END hotfix 05/28/2015
                            //START D-3046 06/03/2015
                            cusRec3.GST_OutOfScope_Indicator__c ='';
                            if(ba.Zuora__Account__r.GST_Out_of_Scope__c){
                                cusRec3.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_Y;
                            } else{
                                cusRec3.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_N;
                            }
                            //END D-3046 06/03/2015
                        }
                        
                        if(ba.Billing_Contact__r.Mobile_Number__c != null || ba.Billing_Contact__r.Mobile_Number_2__c != null){
                            cusRec4 = updateCusRecord2.clone();
                            cusRec4.Contact_Type__c=GlobalVariableClass.STRING_M;
                            if(ba.Billing_Contact__r.Mobile_Number__c <> null){
                                cusRec4.ContactNo_Email__c = ba.Billing_Contact__r.Mobile_Number__c;
                            } else if(ba.Billing_Contact__r.Mobile_Number_2__c <> null){
                                cusRec4.ContactNo_Email__c = ba.Billing_Contact__r.Mobile_Number_2__c;
                            }
                            //START hotfix 05/28/2015
                            cusRec4.Customer_Status__c = GlobalVariableClass.STRING_A;
                            if(ba.Billing_Contact__r.NRIC__c != null){
                                cusRec4.ID_Type__c = 'NRIC';
                                cusRec4.ID_Number__c = ba.Billing_Contact__r.NRIC__c;
                            }
                            //START UD-1527 6/23/15 Added by Manolo Valena - Added else condition for passport field value.
                            else {
                                if(ba.Billing_Contact__r.Passport__c != null) {
                                    cusRec4.ID_Type__c = GlobalVariableClass.PASS;
                                    cusRec4.ID_Number__c = ba.Billing_Contact__r.Passport__c;
                                }
                            }
                            //END UD-1527 6/23/15 Added by Manolo Valena
                            cusRec4.CareOf_AttentionTo_Indicator__c = ba.Zuora__Account__r.Attention_To_Care_Of_Indicator__c;
                            cusRec4.CareOf_ATtentionTo_Party__c = ba.Attention_To_Care1__c;
                            //END hotfix 05/28/2015
                            //START D-3046 06/03/2015
                            cusRec4.GST_OutOfScope_Indicator__c ='';
                            if(ba.Zuora__Account__r.GST_Out_of_Scope__c){
                                cusRec4.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_Y;
                            } else{
                                cusRec4.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_N;
                            }
                            //END D-3046 06/03/2015
                        }
                        //START: UD-1527 11/06/2015 Added by S.Puli
                        if(ba.Billing_Contact__r.Fax__c != null){
                        //END: UD-1527 11/06/2015 Added by S.Puli
                            cusRec5 = updateCusRecord2.clone();
                            cusRec5.Contact_Type__c = GlobalVariableClass.STRING_F;
                            //START: UD-1527 11/06/2015 Added by S.Puli
                            cusRec5.ContactNo_Email__c = ba.Billing_Contact__r.Fax__c;
                            //END: UD-1527 11/06/2015 Added by S.Puli
                            //START hotfix 05/28/2015
                            cusRec5.Customer_Status__c = GlobalVariableClass.STRING_A;
                            if(ba.Billing_Contact__r.NRIC__c != null){
                                cusRec5.ID_Type__c = 'NRIC';
                                cusRec5.ID_Number__c = ba.Billing_Contact__r.NRIC__c;
                            }
                            //START UD-1527 6/23/15 Added by Manolo Valena - Added else condition for passport field value.
                            else {
                                if(ba.Billing_Contact__r.Passport__c != null) {
                                    cusRec5.ID_Type__c = GlobalVariableClass.PASS;
                                    cusRec5.ID_Number__c = ba.Billing_Contact__r.Passport__c;
                                }
                            }
                            //END UD-1527 6/23/15 Added by Manolo Valena
                            cusRec5.CareOf_AttentionTo_Indicator__c = ba.Zuora__Account__r.Attention_To_Care_Of_Indicator__c;
                            cusRec5.CareOf_ATtentionTo_Party__c = ba.Attention_To_Care1__c;
                            //END hotfix 05/28/2015
                            //START D-3046 06/03/2015
                            cusRec5.GST_OutOfScope_Indicator__c ='';
                            if(ba.Zuora__Account__r.GST_Out_of_Scope__c){
                                cusRec5.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_Y;
                            } else{
                                cusRec5.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_N;
                            }
                            //END D-3046 06/03/2015
                        }
                        
                        if(ba.Billing_Contact__r.Email != null){
                            cusRec6 = updateCusRecord2.clone();
                            cusRec6.Contact_Type__c=GlobalVariableClass.STRING_E;
                            cusRec6.ContactNo_Email__c = ba.Billing_Contact__r.Email;
                            //START hotfix 05/28/2015
                            cusRec6.Customer_Status__c = GlobalVariableClass.STRING_A;
                            if(ba.Billing_Contact__r.NRIC__c != null){
                                cusRec6.ID_Type__c = 'NRIC';
                                cusRec6.ID_Number__c = ba.Billing_Contact__r.NRIC__c;
                            }
                            //START UD-1527 6/23/15 Added by Manolo Valena - Added else condition for passport field value.
                            else {
                                if(ba.Billing_Contact__r.Passport__c != null) {
                                    cusRec6.ID_Type__c = GlobalVariableClass.PASS;
                                    cusRec6.ID_Number__c = ba.Billing_Contact__r.Passport__c;
                                }
                            }
                            //END UD-1527 6/23/15 Added by Manolo Valena
                            cusRec6.CareOf_AttentionTo_Indicator__c = ba.Zuora__Account__r.Attention_To_Care_Of_Indicator__c;
                            cusRec6.CareOf_ATtentionTo_Party__c = ba.Attention_To_Care1__c;
                            //END hotfix 05/28/2015
                            //START D-3046 06/03/2015
                            cusRec6.GST_OutOfScope_Indicator__c ='';
                            if(ba.Zuora__Account__r.GST_Out_of_Scope__c){
                                cusRec6.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_Y;
                            } else{
                                cusRec6.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_N;
                            }
                            //END D-3046 06/03/2015
                        }
                    //START D-3775 10/29/15 RReyes - cut ContactNo_Email__c to 40 characters
                    String tempCont = '';
                    if(updateCusRecord != null){
                        if(updateCusRecord.ContactNo_Email__c != null){
                            tempCont = updateCusRecord.ContactNo_Email__c;
                            if(tempCont.length() > 40){
                                updateCusRecord.ContactNo_Email__c = tempCont.subString(0, 40);
                            }
                        }
                    }
                    if(updateCusRecord2 != null){
                        if(updateCusRecord2.ContactNo_Email__c != null){
                            tempCont = updateCusRecord2.ContactNo_Email__c;
                            if(tempCont.length() > 40){
                                updateCusRecord2.ContactNo_Email__c = tempCont.subString(0, 40);
                            }
                        }
                    }
                    if(cusRec3 != null){
                        if(cusRec3.ContactNo_Email__c != null){
                            tempCont = cusRec3.ContactNo_Email__c;
                            if(tempCont.length() > 40){
                                cusRec3.ContactNo_Email__c = tempCont.subString(0, 40);
                            }
                        }
                    }
                    if(cusRec4 != null){
                        if(cusRec4.ContactNo_Email__c != null){
                            tempCont = cusRec4.ContactNo_Email__c;
                            if(tempCont.length() > 40){
                                cusRec4.ContactNo_Email__c = tempCont.subString(0, 40);
                            }
                        }
                    }
                    if(cusRec5 != null){
                        if(cusRec5.ContactNo_Email__c != null){
                            tempCont = cusRec5.ContactNo_Email__c;
                            if(tempCont.length() > 40){
                                cusRec5.ContactNo_Email__c = tempCont.subString(0, 40);
                            }
                        }
                    }
                    if(cusRec6 != null){
                        if(cusRec6.ContactNo_Email__c != null){
                            tempCont = cusRec6.ContactNo_Email__c;
                            if(tempCont.length() > 40){
                                cusRec6.ContactNo_Email__c = tempCont.subString(0, 40);
                            }
                        }
                    }
                    //END D-3775 10/29/15 RReyes - cut ContactNo_Email__c to 40 characters 
                                       
                    bCusList.add(updateCusRecord);
                    bCusInsertList.add(updateCusRecord);
                    //START UD-2418 02-Sept-2015 Added By S.Puli
                    if(updateCusRecord2.Contact_Type__c <> null){
                        bCusInsertList.add(updateCusRecord2);
                    }
                    //END UD-2418 02-Sept-2015 Added By S.Puli
                    if(cusRec3 != null) bCusInsertList.add(cusRec3);
                    if(cusRec4 != null) bCusInsertList.add(cusRec4);
                    if(cusRec5 != null) bCusInsertList.add(cusRec5);
                    if(cusRec6 != null) bCusInsertList.add(cusRec6);
                    //zCusTOUpdList.add(ba);
                }
            }
            //START: UD-0964/095 04/22/2015 Added by S.PULI
            if(updCusToDelete_LIST.size()>0){
                Database.delete(updCusToDelete_LIST, false);
            }
            //END: UD-0964/095 04/22/2015 Added by S.PULI
            if(bCusInsertList<>null && bCusInsertList.size()>0 && bCusList<>null && bCusList.size()>0){
            
            insert bCusInsertList;
            
                for(BT_CO_ARMS_UpdateCustomerBatchFile__c a : bCusList){
                    CusToUpdSet.add(a.Id);
                }
            }
            
            updateCustomerWebservice(CusToUpdSet); 
        }
    
    }
    //END: D-1013 12/06/14 Added by S.Puli
    
    @future(callout = true)
    public static void createCustomerWebservice(Set<Id> cusBatchId, Set<Id> baIdSet){
        
        //Start D-4011 03-Dec-2015 Added by S.Puli - exception logger
        list<exception> exceptionList = new list<exception>();
        boolean isRecordLock = true;
        //End D-4011 03-Dec-2015 Added by S.Puli
        //Start D-4078 15-Dec-2015 Added by S.Puli
        List<Log__c> logList = new List<Log__c>();
        //End D-4078 15-Dec-2015 Added by S.Puli
        //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
        //START: UD-1527 11/06/2015 Added by S.Puli
        List<BT_CO_ARMS_CreateCustAccountFile__c> customerRecList = [Select Id,Customer_Name1__c,Customer_Status__c,
                Reference_Key__c,Unique_Key__c,Business_Profile__c,Account_Type__c,Credit_Limit_External__c,
                Credit_Limit_Internal__c,Debt_Mgt_Treatment__c,Create_Id__c, Postal_Code__c, City_Zip__c, 
                Country__c, Address1__c, Address2__c, Sub_Contact_Name__c, Credit_Term__c, Credit_Term_Reference__c, Approved_Debt_Exposure_Amount__c, Address3__c, Address4__c, Block_House_Number__c,Building_Secondary__c,Co_Attention_To_Indicator__c, co_Attention_To_Party__c,Company_Code__c,Floor_Number__c,GST_OutOfScope_Indicator__c,ID_No__c,ID_Type__c,PO_Box_No__c, Street__c,Unit_No__c,SOA_Group__c,SPH_Staff_Indicator__c,Record_Type__c From BT_CO_ARMS_CreateCustAccountFile__c Where Id In :cusBatchId];
        //END: UD-1527 11/06/2015 Added by S.Puli
        //END: D-995 12/05/14 Added by S.Puli
        
        //START: UD-0964/0965 04/22/2015 Added by S.PULI
        Map<Id, List<BT_CO_ARMS_CreateCustAccountFile__c>> masterToDetail_MAP = new Map<Id, List<BT_CO_ARMS_CreateCustAccountFile__c>>();
        Set<String> cusName_SET = new Set<String>();
        
        if(customerRecList.size()>0){
            for(BT_CO_ARMS_CreateCustAccountFile__c bCus : customerRecList){
                cusName_SET.add(bCus.Customer_Name1__c);
            }
        //START: UD-1527 11/06/2015 Added by S.Puli
            for(BT_CO_ARMS_CreateCustAccountFile__c bSearch : [Select Id, Reference_Key__c, Customer_Name1__c,Sub_Contact_Name__c,Sub_Contact_Designation__c,Sub_Contact_Ext__c,Sub_ContactNo_Email__c,Sub_Contact_Type__c,Record_Type__c From BT_CO_ARMS_CreateCustAccountFile__c Where Customer_Name1__c IN :cusName_SET AND Record_Type__c = 'Detail']){
       //END: UD-1527 11/06/2015 Added by S.Puli
                for(BT_CO_ARMS_CreateCustAccountFile__c b : customerRecList){
                    if(bSearch.Customer_Name1__c == b.Customer_Name1__c && bSearch.Reference_Key__c == b.Reference_Key__c){
                        if(masterToDetail_MAP.containsKey(b.Id)){
                            masterToDetail_MAP.get(b.Id).add(bSearch);
                        }else{
                            //START: UD-1527 11/06/2015 Added by S.Puli
                            masterToDetail_MAP.put(b.Id, new List<BT_CO_ARMS_CreateCustAccountFile__c>{b, bSearch});
                            //END: UD-1527 11/06/2015 Added by S.Puli
                        }
                    }
                }
            }
        }
        //END: UD-0964/0965 04/22/2015 Added by S.PULI
        
        List<BT_CO_ARMS_CreateCustAccountFile__c> bCusToDeleteList = new List<BT_CO_ARMS_CreateCustAccountFile__c>();
        //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
        //START: D-1013 12/06/14 Added by S.Puli - add ARMS_Customer_Number__c to Update Customer online to ARMS
        List<Zuora__CustomerAccount__c> billAccList = [Select Id, Name, ARMS_ID__c, Zuora__Zuora_Id__c, 
                ARMS_Account_Number__c, Zuora__AccountNumber__c, Zuora__Account__r.AccountNumber, ARMS_Debt_Management__c, ARMS_Business_Profile__c, ARMS_Customer_Number__c From Zuora__CustomerAccount__c Where Id IN :baIdSet];
        //END: D-1013 12/06/14 Added by S.Puli
        //END: D-995 12/05/14 Added by S.Puli 
        List<Zuora__CustomerAccount__c> billAccTOUpdList = new List<Zuora__CustomerAccount__c>();
        
        Map<String, Zuora__CustomerAccount__c> bcCusNumMap = new Map<String, Zuora__CustomerAccount__c>();
        
        List<Zuora.zObject> zObjectList = new List<Zuora.zObject>();
        Zuora.zApi zApiInstance = new Zuora.zApi();
        //START D-3268 Modified By C.I.Salas - Test Coverage
        if (!Test.isRunningTest()) {
            zApiInstance.zlogin();
        }
        //END D-3268 Modified By C.I.Salas - Test Coverage

        if(billAccList<>null && billAccList.size()>0){
            for(Zuora__CustomerAccount__c ba : billAccList){
            //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
                //START: UD-0964/0965 04/22/2015 Added by S.PULI
                bcCusNumMap.put(ba.Zuora__Account__r.AccountNumber, ba);
                //END: UD-0964/0965 04/22/2015 Added by S.PULI
            //END: D-995 12/05/14 Added by S.Puli
            }
        }
        
        if(customerRecList<>null && customerRecList.size()>0){
            for(BT_CO_ARMS_CreateCustAccountFile__c bCreateCus : customerRecList){
                wwwSphComArWsWsdlCam.CreateCustomerAccountRequestType armsCusRec = new wwwSphComArWsWsdlCam.CreateCustomerAccountRequestType();

                armsCusRec.CusAccCre = new wwwSphComArWsSchemaCamCreatecusto.CusAccCre_element();

                    armsCusRec.CusAccCre.SysId = ConstantsSLB.getOther('ARMS_SysId');
                    armsCusRec.CusAccCre.CusM1 = bCreateCus.Customer_Name1__c;
                    armsCusRec.CusAccCre.CusSts = bCreateCus.Customer_Status__c;
                    armsCusRec.CusAccCre.Syno = bCreateCus.Reference_Key__c;
                    armsCusRec.CusAccCre.UniqId = bCreateCus.Unique_Key__c;
                    armsCusRec.CusAccCre.BizP = bCreateCus.Business_Profile__c;
                    armsCusRec.CusAccCre.AccTyp = bCreateCus.Account_Type__c;
                    armsCusRec.CusAccCre.CrLmtInt = bCreateCus.Credit_Limit_Internal__c;
                    armsCusRec.CusAccCre.CrLmtExt = bCreateCus.Credit_Limit_External__c;
                    armsCusRec.CusAccCre.DbtStrt = bCreateCus.Debt_Mgt_Treatment__c;
                    armsCusRec.CusAccCre.CreId = bCreateCus.Create_Id__c;
                    armsCusRec.CusAccCre.CoyCd =  ConstantsSLB.getOther('ARMS_CoyCd');
                    armsCusRec.CusAccCre.PstC = bCreateCus.Postal_Code__c;
                    armsCusRec.CusAccCre.CityM = bCreateCus.City_Zip__c;
                    //armsCusRec.CusAccCre.Cntry = bCreateCus.Country__c;
                    armsCusRec.CusAccCre.CusA1 = bCreateCus.Address1__c;
                    armsCusRec.CusAccCre.CusA2 = bCreateCus.Address2__c;
                    //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
                    armsCusRec.CusAccCre.CrTrm = bCreateCus.Credit_Term__c;
                    armsCusRec.CusAccCre.CrTrmRef = bCreateCus.Credit_Term_Reference__c;
                    armsCusRec.CusAccCre.DbtExp = bCreateCus.Approved_Debt_Exposure_Amount__c;
                    //END: D-995 12/05/14 Added by S.Puli
                    
                    //START: UD-1527 11/06/2015 Added by S.Puli
                    armsCusRec.CusAccCre.CusA3 = bCreateCus.Address3__c;
                    armsCusRec.CusAccCre.CusA4 = bCreateCus.Address4__c;
                    armsCusRec.CusAccCre.DbtExp = bCreateCus.Approved_Debt_Exposure_Amount__c;
                    armsCusRec.CusAccCre.BlkN = bCreateCus.Block_House_Number__c;
                    armsCusRec.CusAccCre.BldgSec = bCreateCus.Building_Secondary__c;
                    armsCusRec.CusAccCre.AttnI = bCreateCus.Co_Attention_To_Indicator__c;
                    armsCusRec.CusAccCre.Attn = bCreateCus.co_Attention_To_Party__c;
                    armsCusRec.CusAccCre.Cntry = bCreateCus.Country__c;
                    armsCusRec.CusAccCre.FlrN = bCreateCus.Floor_Number__c;
                    armsCusRec.CusAccCre.GstOOSI = bCreateCus.GST_OutOfScope_Indicator__c;
                    armsCusRec.CusAccCre.IdN = bCreateCus.ID_No__c;
                    armsCusRec.CusAccCre.IdTyp = bCreateCus.ID_Type__c;
                    armsCusRec.CusAccCre.PoBoxN = bCreateCus.PO_Box_No__c;
                    armsCusRec.CusAccCre.SOAGrp = bCreateCus.SOA_Group__c;
                    armsCusRec.CusAccCre.StfI = bCreateCus.SPH_Staff_Indicator__c;
                    armsCusRec.CusAccCre.Str = bCreateCus.Street__c;
                    armsCusRec.CusAccCre.UntN = bCreateCus.Unit_No__c;
                    //Unit_No__c
                    
                    List<wwwSphComArWsSchemaCamCreatecusto.ContType> contArray = new List<wwwSphComArWsSchemaCamCreatecusto.ContType>();
                    //START UD-2595 05-Sept-2015 Added by S.Puli - Re-link function to include new values from user input
                    if(masterToDetail_MAP.containsKey(bCreateCus.Id)){
                        for(BT_CO_ARMS_CreateCustAccountFile__c bCusFile : masterToDetail_MAP.get(bCreateCus.Id)){
                            if(bCusFile.Record_Type__c == 'Detail'){
                                //START: UD-1528 11/06/2015 Added by S.Puli
                                if(bCusFile.Sub_Contact_Type__c <> null){
                                    wwwSphComArWsSchemaCamCreatecusto.ContType armsContact = new wwwSphComArWsSchemaCamCreatecusto.ContType();
                                    
                                    armsContact.CtPeM1 = bCusFile.Sub_Contact_Name__c;
                                    armsContact.Dsgtn = bCusFile.Sub_Contact_Designation__c;
                                    armsContact.CtExt = bCusFile.Sub_Contact_Ext__c;
                                    armsContact.CtNoEm = bCusFile.Sub_ContactNo_Email__c;
                                    armsContact.CtTyp = bCusFile.Sub_Contact_Type__c;

                                    contArray.add(armsContact);
                                }
                                //END: UD-1528 11/06/2015 Added by S.Puli
                            }
                        }
                    }
                    //END UD-2595 05-Sept-2015 Added by S.Puli - Re-link function to include new values from user input
                    wwwSphComArWsSchemaCamCreatecusto.L_ContType lContType = new wwwSphComArWsSchemaCamCreatecusto.L_ContType();
                    lContType.Cont = contArray;
                    
                    armsCusRec.CusAccCre.L_Cont = lContType;
                    //END: UD-1527 11/06/2015 Added by S.Puli
                    armsCusRec.user_x = new wwwSphComArWsSchemaCommonUser.UserType();
                    armsCusRec.user_x.userID = ConstantsSLB.getOther('ARMS_userID');
                    armsCusRec.user_x.password = ConstantsSLB.getOther('ARMS_password');
               
                //START UD-0274 03-18-2015 Marvin Gatchalian
                try {
                    wwwSphComArWsWsdlCam.CAMSOAP CusCreateCAM = new wwwSphComArWsWsdlCam.CAMSOAP();
                    wwwSphComArWsWsdlCam.CreateCustomerAccountResponseType CusCreatedRec = CusCreateCAM.CreateCustomerAccount(armsCusRec);
                    //START: UD-1527 11/06/2015 Added by S.Puli
                    system.debug('>>CusCreatedRec'+CusCreatedRec);
                    //END: UD-1527 11/06/2015 Added by S.Puli
                    //Start D-4078 15-Dec-2015 Added by S.Puli - log the response file from ARMS to Log__c object
                    if(boolean.valueOf(ConstantsSLB.getOther('ARMS Log Key'))){
                        Log__c logRec = new Log__c();
                        logRec.Message__c = String.valueOf(CusCreatedRec);
                        logRec.Job_ID__c = ConstantsSLB.getOther('ARMS Log');
                        logList.add(logRec);
                    }
                    //End D-4078 15-Dec-2015 Added by S.Puli
                
                    wwwSphComArWsSchemaCommonMessages.MessagesType mymessages;
                    if (CusCreatedRec.messages <> null ) {
                        mymessages = CusCreatedRec.messages;    
                    }
                    else {
                        mymessages = null;
                    }
                    
                    wwwSphComArWsSchemaCommonMessages.MessageType mymessage;
                    
                    if (mymessages.messages.size() > 0 ) {
                        mymessage = mymessages.messages[0];
                    }
                    else {
                        mymessage = null;
                    }
                    
                    
                
                
                //END UD-0274 03-18-2015 Marvin Gatchalian
                
                if(CusCreatedRec<>null){
                    if(CusCreatedRec.CusAccCreResp<>null){
                        if(CusCreatedRec.CusAccCreResp.RtnSts == '0' ){
                            bCusToDeleteList.add(bCreateCus);
                            
                            //put code that will update sfdc billing account ARMS ID and ARMS Acc Num from arms response CusN AccN
                            if(bcCusNumMap<>null && bcCusNumMap.size()>0){
                                
                                id billingAccountId = bcCusNumMap.get(bCreateCus.Unique_Key__c).Id;
                                
                                bcCusNumMap.get(bCreateCus.Unique_Key__c).ARMS_ID__c = CusCreatedRec.CusAccCreResp.CusN;
                                bcCusNumMap.get(bCreateCus.Unique_Key__c).ARMS_Account_Number__c = CusCreatedRec.CusAccCreResp.AccN;
                                bcCusNumMap.get(bCreateCus.Unique_Key__c).ARMS_Business_Profile__c = bCreateCus.Business_Profile__c;
                                bcCusNumMap.get(bCreateCus.Unique_Key__c).ARMS_Debt_Management__c = bCreateCus.Debt_Mgt_Treatment__c;
                                bcCusNumMap.get(bCreateCus.Unique_Key__c).Other_PaymentMethod__c = 'Invoice';
                                bcCusNumMap.get(bCreateCus.Unique_Key__c).Payment_Mode__c = 'Other';
                                bcCusNumMap.get(bCreateCus.Unique_Key__c).ARMS_Account_Type__c = ConstantsSLB.getOther('ARMS_AccTyp');
                                //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
                                bcCusNumMap.get(bCreateCus.Unique_Key__c).Credit_Limit_Internal__c = Decimal.valueOf(ConstantsSLB.getOther('ARMS_CrLmtInt'));
                                bcCusNumMap.get(bCreateCus.Unique_Key__c).Credit_Limit_External__c = Decimal.valueOf(ConstantsSLB.getOther('ARMS_CrLmtExt'));
                                //bcCusNumMap.get(bCreateCus.Unique_Key__c).Credit_Term__c = CusCreatedRec.CusAccCreResp.CrTrm;
                                bcCusNumMap.get(bCreateCus.Unique_Key__c).Credit_Reference__c = ConstantsSLB.getOther('ARMS_CrTrmRef');
                                bcCusNumMap.get(bCreateCus.Unique_Key__c).Approved_Debt_Exposure_Amount__c = Decimal.valueOf(ConstantsSLB.getOther('ARMS_DbtExp'));
                                //END: D-995 12/05/14 Added by S.Puli
                                //START: D-1013 12/06/14 Added by S.Puli - add ARMS_Customer_Number__c to Update Customer online to ARMS
                                bcCusNumMap.get(bCreateCus.Unique_Key__c).ARMS_Customer_Number__c = CusCreatedRec.CusAccCreResp.CusN;
                                //END: D-1013 12/06/14 Added by S.Puli
                                    
                                    //START UD-0274 03-18-2015 Marvin Gatchalian
                                    bcCusNumMap.get(bCreateCus.Unique_Key__c).ARMS_Return_Status__c = CusCreatedRec.CusAccCreResp.RtnSts;
                                    bcCusNumMap.get(bCreateCus.Unique_Key__c).Arms_Return_Message__c = CusCreatedRec.CusAccCreResp.RtnMsg;
                                    //END UD-0274 03-18-2015 Marvin Gatchalian
                                    
                                billAccTOUpdList.add(bcCusNumMap.get(bCreateCus.Unique_Key__c));

                                // prepare data for zuora update
                                //START UD-2653 10-Sept-2015 Added By S.Puli - Remove zuora callout for ARMS fields
                                /*
                                Zuora.zObject zObject = new Zuora.zObject('Account');
                                zObject.setValue('Id', bcCusNumMap.get(bCreateCus.Unique_Key__c).Zuora__Zuora_Id__c);
                                zObject.setValue('Other_PaymentMethod__c', 'Invoice');
                                zObject.setValue('ARMS_Account_Number__c', CusCreatedRec.CusAccCreResp.AccN);
                                //START: UD-1516 K. Tan 7/6/2015 Update Bus Prof and Debt Management Field in Zuora
                                zObject.setValue('ARMS_Business_Profile__c', bCreateCus.Business_Profile__c);
                                zObject.setValue('ARMS_Debt_Management__c', bCreateCus.Debt_Mgt_Treatment__c);
                                //END: UD-1516 K. Tan 7/6/2015 Update Bus Prof and Debt Management Field in Zuora
                                zObjectList.add(zObject);
                                */
                                //END UD-2653 10-Sept-2015 Added By S.Puli
                                // end prepare data for zuora update
                                }
                            } 
                        }
                        //START UD-0274 03-18-2015 Marvin Gatchalian
                        else if(CusCreatedRec.CusAccCreResp == null){
                            if (mymessage <> null) {
                                bcCusNumMap.get(bCreateCus.Unique_Key__c).Arms_Return_Message__c = mymessage.message;
                                //REMOVE UD-0964,0965 billAccTOUpdList.add(bcCusNumMap.get(bCreateCus.Unique_Key__c));
                                //START: UD-0802 04/08/2015 Added by S.PULI
                                if(mymessage.message.contains('Customer Exists')){
                                    bCusToDeleteList.add(bCreateCus);
                                
                                    //put code that will update sfdc billing account ARMS ID and ARMS Acc Num from arms response CusN AccN
                                    if(bcCusNumMap<>null && bcCusNumMap.size()>0){
                                        
                                        id billingAccountId = bcCusNumMap.get(bCreateCus.Unique_Key__c).Id;
                                        
                                        bcCusNumMap.get(bCreateCus.Unique_Key__c).ARMS_ID__c = CusCreatedRec.CusAccCreResp.CusN;
                                        bcCusNumMap.get(bCreateCus.Unique_Key__c).ARMS_Account_Number__c = CusCreatedRec.CusAccCreResp.AccN;
                                        bcCusNumMap.get(bCreateCus.Unique_Key__c).ARMS_Business_Profile__c = bCreateCus.Business_Profile__c;
                                        bcCusNumMap.get(bCreateCus.Unique_Key__c).ARMS_Debt_Management__c = bCreateCus.Debt_Mgt_Treatment__c;
                                        bcCusNumMap.get(bCreateCus.Unique_Key__c).Other_PaymentMethod__c = 'Invoice';
                                        bcCusNumMap.get(bCreateCus.Unique_Key__c).Payment_Mode__c = 'Other';
                                        bcCusNumMap.get(bCreateCus.Unique_Key__c).ARMS_Account_Type__c = ConstantsSLB.getOther('ARMS_AccTyp');
                                        bcCusNumMap.get(bCreateCus.Unique_Key__c).Credit_Limit_Internal__c = Decimal.valueOf(ConstantsSLB.getOther('ARMS_CrLmtInt'));
                                        bcCusNumMap.get(bCreateCus.Unique_Key__c).Credit_Limit_External__c = Decimal.valueOf(ConstantsSLB.getOther('ARMS_CrLmtExt'));
                                        //bcCusNumMap.get(bCreateCus.Unique_Key__c).Credit_Term__c = CusCreatedRec.CusAccCreResp.CrTrm;
                                        bcCusNumMap.get(bCreateCus.Unique_Key__c).Credit_Reference__c = ConstantsSLB.getOther('ARMS_CrTrmRef');
                                        bcCusNumMap.get(bCreateCus.Unique_Key__c).Approved_Debt_Exposure_Amount__c = Decimal.valueOf(ConstantsSLB.getOther('ARMS_DbtExp'));
                                        bcCusNumMap.get(bCreateCus.Unique_Key__c).ARMS_Customer_Number__c = CusCreatedRec.CusAccCreResp.CusN;                                       
                                        bcCusNumMap.get(bCreateCus.Unique_Key__c).ARMS_Return_Status__c = CusCreatedRec.CusAccCreResp.RtnSts;
                                        bcCusNumMap.get(bCreateCus.Unique_Key__c).Arms_Return_Message__c = CusCreatedRec.CusAccCreResp.RtnMsg;
                                        
                                        billAccTOUpdList.add(bcCusNumMap.get(bCreateCus.Unique_Key__c));
        
                                        // prepare data for zuora update
                                        //START UD-2653 10-Sept-2015 Added By S.Puli - remove zuora callout
                                        /*
                                        Zuora.zObject zObject = new Zuora.zObject('Account');
                                        zObject.setValue('Id', bcCusNumMap.get(bCreateCus.Unique_Key__c).Zuora__Zuora_Id__c);
                                        zObject.setValue('Other_PaymentMethod__c', 'Invoice');
                                        zObject.setValue('ARMS_Account_Number__c', CusCreatedRec.CusAccCreResp.AccN);
                                        //START: UD-1516 K. Tan 7/6/2015 Update Bus Prof and Debt Management Field in Zuora
                                        zObject.setValue('ARMS_Business_Profile__c', bCreateCus.Business_Profile__c);
                                        zObject.setValue('ARMS_Debt_Management__c', bCreateCus.Debt_Mgt_Treatment__c);
                                        //END: UD-1516 K. Tan 7/6/2015 Update Bus Prof and Debt Management Field in Zuora
                                        zObjectList.add(zObject);
                                        */
                                        //END UD-2653 10-Sept-2015 Added By S.Puli
                                        // end prepare data for zuora update
        
                                    }
                                
                                }
                                //END: UD-0802 04/08/2015 Added by S.PULI
                            }
                            else if (mymessage == null) {
                                bcCusNumMap.get(bCreateCus.Unique_Key__c).Arms_Return_Message__c = 'CusCreatedRec.CusAccCreResp is null and message is null';
                                billAccTOUpdList.add(bcCusNumMap.get(bCreateCus.Unique_Key__c));
                            }
                         
                        }
                        //END UD-0274 03-18-2015 Marvin Gatchalian     
                        
                    }
                    //START UD-0274 03-18-2015 Marvin Gatchalian
                    else if (CusCreatedRec == null) {
                            bcCusNumMap.get(bCreateCus.Unique_Key__c).Arms_Return_Message__c = ConstantsSLB.getErrorMessage('Invalid Response');
                            billAccTOUpdList.add(bcCusNumMap.get(bCreateCus.Unique_Key__c));
                    }
                    
                }
                catch (Exception ex) {
                    bcCusNumMap.get(bCreateCus.Unique_Key__c).Arms_Return_Message__c = 'Invalid or missing parameter ' + string.valueOf(armsCusRec);
                    //Start D-4078 14-Dec-2015 Added by S.Puli
                    exceptionList.add(ex);
                    //End D-4078 14-Dec-2015 Added by S.Puli
                    //REMOVE UD-0964, 0965 billAccTOUpdList.add(bcCusNumMap.get(bCreateCus.Unique_Key__c));
                }
                //END UD-0274 03-18-2015 Marvin Gatchalian
            }
            
            if(billAccTOUpdList<>null && billAccTOUpdList.size()>0){
                //START UD-0274 03-18-2015 Marvin Gatchalian
                if (zObjectList <> null && zObjectList.size() > 0) {
                    List<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(zObjectList);
                    system.debug('>>>zuoraarmsupdate ' + results);
                }
                //END UD-0274 03-18-2015 Marvin Gatchalian
                //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
                ARMS_TriggerHandler.isSkipUpdate = true;
                //END: D-995 12/05/14 Added by S.Puli
                //Start D-4011 03-Dec-2015 Added by S.Puli - logic to retry record update when record is locked
                while(isRecordLock){
                    try{
                        update billAccTOUpdList;
                        isRecordLock = false;
                    } catch (dmlexception e) {
                        isRecordLock = e.getMessage().contains('UNABLE_TO_LOCK_ROW');
                        exceptionList.add(e);
                    }
                }
                if(!exceptionList.isEmpty()) {
                    ExceptionLogger.log(exceptionList);
                }               
                //End D-4011 03-Dec-2015 Added by S.Puli - logic to retry record update when record is locked
                //Start D-4078 15-Dec-2015 Added by S.Puli
                if(logList.size()>0){   
                    List<Database.Saveresult> dList = Database.insert(logList, false);
                }
                //End D-4078 15-Dec-2015 Added by S.Puli
            }
            if(bCusToDeleteList<>null && bCusToDeleteList.size()>0){
                //START: UD-0964/0965 04/22/2015 Added by S.PULI
                List<BT_CO_ARMS_CreateCustAccountFile__c> bCusToDeleteTotalList = new List<BT_CO_ARMS_CreateCustAccountFile__c>();
                system.debug('>>masterToDetail_MAP>>'+ masterToDetail_MAP);
                for(BT_CO_ARMS_CreateCustAccountFile__c b : bCusToDeleteList){
                    if(masterToDetail_MAP.containskey(b.Id)){
                        if(masterToDetail_MAP.get(b.Id).size()>0){
                            for(BT_CO_ARMS_CreateCustAccountFile__c bT : masterToDetail_MAP.get(b.Id)){
                                bCusToDeleteTotalList.add(bT);
                            }                           
                        }
                    }
                }
                if(bCusToDeleteTotalList.size()>0){
                    List<Database.DeleteResult> d = Database.delete(bCusToDeleteTotalList, false);
                }
                system.debug('bCusToDeleteListafterdelete>>'+bCusToDeleteList);
                //END: UD-0964/0965 04/22/2015 Added by S.PULI
            }
        }
    }
    
    @future(callout = true)
    public static void createAccountWebservice(Set<Id> accBatchId, Set<Id> billAccIdSet){
    
        //Start D-4011 03-Dec-2015 Added by S.Puli - exception logger
        list<exception> exceptionList = new list<exception>();
        boolean isRecordLock = true;
        //End D-4011 03-Dec-2015 Added by S.Puli
        //Start D-4078 15-Dec-2015 Added by S.Puli
        List<Log__c> logList = new List<Log__c>();
        //End D-4078 15-Dec-2015 Added by S.Puli
        //START: UD-1557 11/06/2015 Added by S.Puli
        List<BT_CO_ARMS_CreateAccountBatchFile__c> accountRecList = [Select createdBy.name,Id, Account_Type__c, Company_Code__c, CCRID__c,  
                Creator_ID__c, Credit_Term__c, Credit_Term_Refererence__c, Credit_Limit_Internal__c, Credit_Limit_External__c, 
                Approved_Debt_Exposure_Amount__c, Debt_Management_Treatment__c, Cust_Giro_Acct_Number__c, Cust_Giro_Bank_Number__c, 
                Business_Sector__c, SOA_Suppression_Indicator__c, Transient_Indicator__c, ARMS_ID__c,SOA_Group__c    
                From BT_CO_ARMS_CreateAccountBatchFile__c Where Id In :accBatchId];
        //END: UD-1557 11/06/2015 Added by S.Puli
        List<BT_CO_ARMS_CreateAccountBatchFile__c> bAccToDeleteList = new List<BT_CO_ARMS_CreateAccountBatchFile__c>();
        
        //START: D-1675, D-1676 01/20/2014 Added by S.Puli
        List<Zuora__CustomerAccount__c> billAccList = [Select Id, Name, ARMS_ID__c, Zuora__Zuora_Id__c, ARMS_Account_Number__c, Zuora__AccountNumber__c, ARMS_Debt_Management__c, ARMS_Business_Profile__c, ARMS_Customer_Number__c From Zuora__CustomerAccount__c Where Id IN :billAccIdSet];
        //END: D-1679, D-1676 01/20/2014 Added by S.Puli
        
        List<Zuora__CustomerAccount__c> billAccTOUpdList = new List<Zuora__CustomerAccount__c>();
        
        Map<String, Zuora__CustomerAccount__c> bcAccNumMap = new Map<String, Zuora__CustomerAccount__c>();
        //START: UD-1516 K. Tan 7/6/2015 Update Bus Prof and Debt Management Field in Zuora
        Map<String, String> custNotoBusProfmap = new Map<String, String>();
        //END: UD-1516 K. Tan 7/6/2015 Update Bus Prof and Debt Management Field in Zuora
        List<Zuora.zObject> zObjectList = new List<Zuora.zObject>();
        Zuora.zApi zApiInstance = new Zuora.zApi();
        //START D-3268 Modified By C.I.Salas - Test Coverage
        if (!Test.isRunningTest()) {
            zApiInstance.zlogin();
        }
        //END D-3268 Modified By C.I.Salas - Test Coverage

        if(billAccList<>null && billAccList.size()>0){
            for(Zuora__CustomerAccount__c ba : billAccList){
                //START: D-1675, D-1676 01/20/2014 Added by S.Puli
                bcAccNumMap.put(ba.ARMS_Customer_Number__c, ba);
                //START: UD-1516 K. Tan 7/6/2015 Update Bus Prof and Debt Management Field in Zuora
                custNotoBusProfmap.put(ba.ARMS_Customer_Number__c, ba.ARMS_Business_Profile__c);
                //END: UD-1516 K. Tan 7/6/2015 Update Bus Prof and Debt Management Field in Zuora
                //END: D-1679, D-1676 01/20/2014 Added by S.Puli
            }
        }
        
                
        if(accountRecList<>null && accountRecList.size()>0){
            for(BT_CO_ARMS_CreateAccountBatchFile__c bAcc : accountRecList){
                wwwSphComArWsWsdlCam.CreateAccountRequestType armsAccRec = new wwwSphComArWsWsdlCam.CreateAccountRequestType ();

                armsAccRec.AccCre = new wwwSphComArWsSchemaCamCreateaccou.AccCre_element();

                    armsAccRec.AccCre.SysId = ConstantsSLB.getOther('ARMS_SysId');
                    armsAccRec.AccCre.CoyCd = bAcc.Company_Code__c;
                    armsAccRec.AccCre.CusN = bAcc.CCRID__c;
                    armsAccRec.AccCre.AccTyp = bAcc.Account_Type__c;
                    armsAccRec.AccCre.CrLmtInt = bAcc.Credit_Limit_Internal__c;
                    armsAccRec.AccCre.CrLmtExt = bAcc.Credit_Limit_External__c;
                    armsAccRec.AccCre.CreId = bAcc.Creator_ID__c;
                    armsAccRec.AccCre.DbtStrt = bAcc.Debt_Management_Treatment__c;
                    armsAccRec.AccCre.CrTrmRef = bAcc.Credit_Term_Refererence__c;
                    armsAccRec.AccCre.CrTrm = bAcc.Credit_Term__c;
                    armsAccRec.AccCre.DbtExp = bAcc.Approved_Debt_Exposure_Amount__c;
                    
                    if (armsAccRec.AccCre.CrLmtInt == null) {
                        armsAccRec.AccCre.CrLmtInt = ConstantsSLB.getOther('ARMS_CrLmtInt');
                    }
                    
                    if (armsAccRec.AccCre.CrLmtExt == null) {
                        armsAccRec.AccCre.CrLmtExt = ConstantsSLB.getOther('ARMS_CrLmtExt');
                    }

                    if (armsAccRec.AccCre.DbtStrt == null) {                    
                        armsAccRec.AccCre.DbtStrt = ConstantsSLB.getOther('ARMS_DbtStrt');
                    }
                    
                    if (armsAccRec.AccCre.CrTrmRef == null) {
                        armsAccRec.AccCre.CrTrmRef = ConstantsSLB.getOther('ARMS_CrTrmRef');
                    }
                    
                    if (armsAccRec.AccCre.CrTrm == null) {
                        armsAccRec.AccCre.CrTrm = ConstantsSLB.getOther('ARMS_CrTrm');
                    }
                    
                    if (armsAccRec.AccCre.DbtExp == null) {
                        armsAccRec.AccCre.DbtExp = ConstantsSLB.getOther('ARMS_DbtExp');
                    }
                    //START: UD-1557 11/06/2015 Added by S.Puli
                    armsAccRec.AccCre.SOAGrp = bAcc.SOA_Group__c;
                    armsAccRec.AccCre.SOASup = bAcc.SOA_Suppression_Indicator__c;
                    armsAccRec.AccCre.TrnI = bAcc.Transient_Indicator__c;
                    //END: UD-1557 11/06/2015 Added by S.Puli
                    armsAccRec.user_x = new wwwSphComArWsSchemaCommonUser.UserType();
                    armsAccRec.user_x.userID = ConstantsSLB.getOther('ARMS_userID');
                    armsAccRec.user_x.password = ConstantsSLB.getOther('ARMS_password');

                system.debug(armsAccRec);

                wwwSphComArWsWsdlCam.CAMSOAP AccCreateCAM = new wwwSphComArWsWsdlCam.CAMSOAP();
                wwwSphComArWsWsdlCam.CreateAccountResponseType AccCreatedRec = AccCreateCAM.CreateAccount(armsAccRec);
                system.debug(AccCreatedRec);
                
                //Start D-4078 15-Dec-2015 Added by S.Puli - log the response file from ARMS to Log__c object
                if(boolean.valueOf(ConstantsSLB.getOther('ARMS Log Key'))){
                    Log__c logRec = new Log__c();
                    logRec.Message__c = String.valueOf(AccCreatedRec);
                    logRec.Job_ID__c = ConstantsSLB.getOther('ARMS Log');
                    logList.add(logRec);
                }
                //End D-4078 15-Dec-2015 Added by S.Puli
                
                if(AccCreatedRec<>null){
                    if(AccCreatedRec.AccCreResp<>null){
                        if(AccCreatedRec.AccCreResp.RtnSts == '0'){
                            bAccToDeleteList.add(bAcc);
                            
                            //put code to update billing Account ARMS Acc Num from response AccN
                            if(bcAccNumMap<>null && bcAccNumMap.size()>0){

                                id billingAccountId = bcAccNumMap.get(bAcc.CCRID__c).Id;
                                
                                bcAccNumMap.get(bAcc.CCRID__c).Other_PaymentMethod__c = 'Invoice';
                               //REMOVE UD-0964/0965 bcAccNumMap.get(bAcc.CCRID__c).Payment_Mode__c = 'Invoice';
                                bcAccNumMap.get(bAcc.CCRID__c).ARMS_Account_Type__c = ConstantsSLB.getOther('ARMS_AccTyp');
                                bcAccNumMap.get(bAcc.CCRID__c).ARMS_Account_Number__c = AccCreatedRec.AccCreResp.AccN;
                                //START: D-1675, D-1676 01/20/2014 Added by S.Puli
                                //START: UD-1557 11/06/2015 Added by S.Puli
                                bcAccNumMap.get(bAcc.CCRID__c).Creator_ID__c = bAcc.Creator_ID__c;
                                //END: UD-1557 11/06/2015 Added by S.Puli
                                //END: D-1675, D-1676 01/20/2014 Added by S.Puli
                                //bcAccNumMap.get(bAcc.CCRID__c).ARMS_Business_Profile__c = bAcc.Business_Profile__c;
                                bcAccNumMap.get(bAcc.CCRID__c).ARMS_Debt_Management__c = bAcc.Debt_Management_Treatment__c;
                                //START: D-1675, D-1676 01/20/2014 Added by S.Puli
                                bcAccNumMap.get(bAcc.CCRID__c).ARMS_ID__c = bAcc.CCRID__c;
                                //END: D-1675, D-1676 01/20/2014 Added by S.Puli
                                bcAccNumMap.get(bAcc.CCRID__c).GIRO_A_C__c = bAcc.Cust_Giro_Acct_Number__c;
                                bcAccNumMap.get(bAcc.CCRID__c).GIRO_Bank_Code__c = bAcc.Cust_Giro_Bank_Number__c;
                                
                                if ( bAcc.Credit_Limit_External__c != null) {
                                    bcAccNumMap.get(bAcc.CCRID__c).Credit_Limit_External__c = decimal.valueOf(bAcc.Credit_Limit_External__c);
                                }
                                
                                if (bAcc.Credit_Limit_Internal__c != null) {
                                    bcAccNumMap.get(bAcc.CCRID__c).Credit_Limit_Internal__c = decimal.valueOf(bAcc.Credit_Limit_Internal__c);
                                }
                                
                                bcAccNumMap.get(bAcc.CCRID__c).Credit_Reference__c = bAcc.Credit_Term_Refererence__c;
                                
                                //START: D-1675, D-1676 01/20/2014 Added by S.Puli
                                billAccTOUpdList.add(bcAccNumMap.get(bAcc.CCRID__c));
                                //END: D-1675, D-1676 01/20/2014 Added by S.Puli

                                // prepare data for zuora update
                                //START UD-2653 10-Sept-2015 Added By S.Puli - Remove Zuora callout for ARMS fields
                                /*
                                Zuora.zObject zObject = new Zuora.zObject('Account');
                                zObject.setValue('Id', bcAccNumMap.get(bAcc.CCRID__c).Zuora__Zuora_Id__c);
                                zObject.setValue('Other_PaymentMethod__c', 'Invoice');
                                zObject.setValue('ARMS_Account_Number__c', AccCreatedRec.AccCreResp.AccN);
                                //START: UD-0964/095 04/22/2015 Added by S.PULI
                                zObject.setValue('DefaultPaymentMethodId', ConstantsSLB.getKeyId('ZuoraPaymentMethod_Other'));
                                //END: UD-0964/095 04/22/2015 Added by S.PULI
                                //START: UD-1516 K. Tan 7/6/2015 Update Bus Prof and Debt Management Field in Zuora
                                zObject.setValue('ARMS_Business_Profile__c', custNotoBusProfmap.get(bAcc.CCRID__c));                                
                                zObject.setValue('ARMS_Debt_Management__c', bAcc.Debt_Management_Treatment__c); 
                                //START: UD-1516 K. Tan 7/6/2015 Update Bus Prof and Debt Management Field in Zuora
                                zObjectList.add(zObject);
                                */
                                //END UD-2653 10-Sept-2015 Added By S.Puli
    
                            // end prepare data for zuora update

                            }
                            
                        } else if(AccCreatedRec.AccCreResp.RtnSts == '2'){
                            
                            bAccToDeleteList.add(bAcc);
                        }
                    }
                }
            }
            if(billAccTOUpdList<>null && billAccTOUpdList.size()>0){
                
                // zuora callout to update arms info
                
                List<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(zObjectList);
                
                system.debug('<>><><>>>>><<< ' + results);
                
                /*
                for (Zuora.zApi.SaveResult result : results) {
                    
                    if (result.Success) {
                        zuoraIdSet.add(result.Id);
                    }
                }
                */
                // end zuora callout to update arms info
                ARMS_TriggerHandler.isSkipUpdate = true;
                //Start D-4011 03-Dec-2015 Added by S.Puli - logic to retry record update when record is locked
                while(isRecordLock){
                    try{
                        update billAccTOUpdList;
                        isRecordLock = false;
                    } catch (dmlexception e) {
                        isRecordLock = e.getMessage().contains('UNABLE_TO_LOCK_ROW');
                        exceptionList.add(e);
                    }
                }
                if(!exceptionList.isEmpty()) {
                    ExceptionLogger.log(exceptionList);
                }               
                //End D-4011 03-Dec-2015 Added by S.Puli - logic to retry record update when record is locked
                //Start D-4078 15-Dec-2015 Added by S.Puli
                if(logList.size()>0){   
                    Database.insert(logList, false);
                }
                //End D-4078 15-Dec-2015 Added by S.Puli
            }
            if(bAccToDeleteList<>null && bAccToDeleteList.size()>0){
                delete bAccToDeleteList;
            }
        }         
    }
    
    
    @future(callout = true)
    public static void updateAccountWebservice(Set<Id> accBatchId){
    
        //Start D-4078 15-Dec-2015 Added by S.Puli
        List<Log__c> logList = new List<Log__c>();
        //End D-4078 15-Dec-2015 Added by S.Puli
        List<BT_CO_ARMS_UpdateAccountBatchFile__c> accBatchList = [Select Id, Name, Account_Number__c, Account_Type__c, 
                Approved_Debt_Exposure_Amount__c, Business_Sector__c, CCRID__c, Company_Code__c, Credit_Limit_External__c, 
                Credit_Limit_Internal__c, Credit_Term__c, Credit_Term_Reference__c, Debt__c, SoaGroup__c, 
                SOA_Suppression_Indicator__c, Status__c, Transient_Indicator__c, Update_Date__c, Update_ID__c, Update_Time__c 
                From BT_CO_ARMS_UpdateAccountBatchFile__c Where Id IN :accBatchId];
        
        List<BT_CO_ARMS_UpdateAccountBatchFile__c> accBatchToDeleteList = new List<BT_CO_ARMS_UpdateAccountBatchFile__c>();
        
        //START UD-1735 7/8/2015 Added By C. Lin - Update ARMS Details in Zuora
        Set<String> updCusNum_SET = new Set<String>();
    
        if(accBatchList.size()>0){
            for(BT_CO_ARMS_UpdateAccountBatchFile__c ac : accBatchList){
                updCusNum_SET.add(ac.CCRID__c);
            }
        }
        
        //START UD-3815 1/25/2016 Added by J.Sarion - Commented out unused codes
        /*
        Map<String, Zuora__CustomerAccount__c> billAccIdToRecord_MAP = new Map<String, Zuora__CustomerAccount__c>();
        //START D-3300 03-Aug-2015 Added by S.Puli-clear fields in Zuora
        List<Zuora__CustomerAccount__c> billAccToUpdateInZuora_LIST = [Select Id,ARMS_Customer_Number__c,ARMS_Business_Profile__c,ARMS_Debt_Management__c,Zuora__Zuora_Id__c,ARMS_Account_Number__c From Zuora__CustomerAccount__c Where ARMS_Customer_Number__c IN :updCusNum_SET];
        //END D-3300 03-Aug-2015 Added by S.Puli-clear fields in Zuora
        
        if(billAccToUpdateInZuora_LIST.size()>0){
            for(Zuora__CustomerAccount__c zBillAcc : billAccToUpdateInZuora_LIST){
                if(zBillAcc.ARMS_Customer_Number__c <> null){
                    billAccIdToRecord_MAP.put(zBillAcc.ARMS_Customer_Number__c, zBillAcc);
                }
            }
        }
        */
        //END UD-3815 1/25/2016 Added by J.Sarion - Commented out unused codes
        
        List<Zuora.zObject> zObjectList = new List<Zuora.zObject>();
        Zuora.zApi zApiInstance = new Zuora.zApi();
        //START D-3268 Modified By C.I.Salas - Test Coverage
        if (!Test.isRunningTest()) {
            zApiInstance.zlogin();
        }
        //END D-3268 Modified By C.I.Salas - Test Coverage
        //END UD-1735 7/8/2015 Added By C. Lin
        if(accBatchList<>null && accBatchList.size()>0){
            for(BT_CO_ARMS_UpdateAccountBatchFile__c bAccUpd : accBatchList){
                
                wwwSphComArWsWsdlCam.UpdateAccountRequestType updAccRec = new wwwSphComArWsWsdlCam.UpdateAccountRequestType();                              
                updAccRec.AccUpd = new wwwSphComArWsSchemaCamUpdateaccou.AccUpd_element();
                    updAccRec.AccUpd.SysId = ConstantsSLB.getOther('ARMS_SysId');
                    updAccRec.AccUpd.CusN = bAccUpd.CCRID__c;
                    updAccRec.AccUpd.AccN = bAccUpd.Account_Number__c;
                    updAccRec.AccUpd.AccTyp = bAccUpd.Account_Type__c;
                    if(bAccUpd.Credit_Term__c<>null && bAccUpd.Credit_Term__c<>'null'){
                        updAccRec.AccUpd.CrTrm = bAccUpd.Credit_Term__c;
                    }
                    if(bAccUpd.Credit_Term_Reference__c<>null && bAccUpd.Credit_Term_Reference__c<>'null'){
                        updAccRec.AccUpd.CrTrmRef = bAccUpd.Credit_Term_Reference__c;
                    }
                    if(bAccUpd.Credit_Limit_Internal__c<>null && bAccUpd.Credit_Limit_Internal__c<>'null'){
                        updAccRec.AccUpd.CrLmtInt = bAccUpd.Credit_Limit_Internal__c;
                    }
                    if(bAccUpd.Credit_Limit_External__c<>null && bAccUpd.Credit_Limit_External__c <> 'null'){
                        updAccRec.AccUpd.CrLmtExt = bAccUpd.Credit_Limit_External__c;
                    }
                    if(bAccUpd.Approved_Debt_Exposure_Amount__c<>null && bAccUpd.Approved_Debt_Exposure_Amount__c <>'null'){
                        updAccRec.AccUpd.DbtExp = bAccUpd.Approved_Debt_Exposure_Amount__c;
                    }
                    if(bAccUpd.Debt__c<>null && bAccUpd.Debt__c<>'null'){
                        updAccRec.AccUpd.DbtStrt = bAccUpd.Debt__c;
                    }
                    //START: D-995 12/05/14 Added by S.Puli - add components to successfully execute webservice call
                    updAccRec.AccUpd.UpdId = bAccUpd.Update_ID__c;
                    //END: D-995 12/05/14 Added by S.Puli
                        String datedata = String.valueOf(date.today());
                        String datestring = datedata.replace('-','');
                    updAccRec.AccUpd.UpdDte = datestring;
                        String timedata = String.valueOf(Datetime.now());
                        String timesubstring = timedata.substringAfter(' ');
                        String timestring = timesubstring.replace(':','');
                    updAccRec.AccUpd.UpdTme = timestring;
                    if(bAccUpd.Business_Sector__c<>null && bAccUpd.Business_Sector__c<>'null'){
                        updAccRec.AccUpd.BizSctr = bAccUpd.Business_Sector__c;
                    }
                    if(bAccUpd.SoaGroup__c<>null && bAccUpd.SoaGroup__c<>'null'){
                        updAccRec.AccUpd.SOAGrp = bAccUpd.SoaGroup__c;
                    }
                    updAccRec.AccUpd.CoyCd = bAccUpd.Company_Code__c;
                    if(bAccUpd.SOA_Suppression_Indicator__c<>null && bAccUpd.SOA_Suppression_Indicator__c<>'null'){
                        updAccRec.AccUpd.SOASup = bAccUpd.SOA_Suppression_Indicator__c;
                    }
                    if(bAccUpd.Transient_Indicator__c<>null && bAccUpd.Transient_Indicator__c <>'null'){
                        updAccRec.AccUpd.TrnI = bAccUpd.Transient_Indicator__c;
                    }
                    
                updAccRec.user_x = new wwwSphComArWsSchemaCommonUser.UserType();
                updAccRec.user_x.userID = ConstantsSLB.getOther('ARMS_userID');
                updAccRec.user_x.password = ConstantsSLB.getOther('ARMS_password');

                system.debug(updAccRec);

                wwwSphComArWsWsdlCam.CAMSOAP AccUpdCAM = new wwwSphComArWsWsdlCam.CAMSOAP();
                wwwSphComArWsWsdlCam.UpdateAccountResponseType updAccRespRec = AccUpdCAM.UpdateAccount(updAccRec);
                system.debug(updAccRespRec);
                
                //Start D-4078 15-Dec-2015 Added by S.Puli - log the response file from ARMS to Log__c object
                if(boolean.valueOf(ConstantsSLB.getOther('ARMS Log Key'))){
                    Log__c logRec = new Log__c();
                    logRec.Message__c = String.valueOf(updAccRespRec);
                    logRec.Job_ID__c = ConstantsSLB.getOther('ARMS Log');
                    logList.add(logRec);
                }
                //End D-4078 15-Dec-2015 Added by S.Puli
                
                if(updAccRespRec<>null){
                    if(updAccRespRec.messages<>null){
                        if(updAccRespRec.messages.overallStatus == 'Successful'){
                            accBatchToDeleteList.add(bAccUpd);
                        }
                    }
                }
                //START UD-2375 08/28/2015 Added by J.Sarion - Commented out
                /*
                //START UD-1735 7/8/2015 Added By C. Lin - Update ARMS Details in Zuora
                // prepare data for zuora update
                if(billAccIdToRecord_MAP.containsKey(bAccUpd.CCRID__c)){
                    Zuora.zObject zObject = new Zuora.zObject('Account');
                    zObject.setValue('Id', billAccIdToRecord_MAP.get(bAccUpd.CCRID__c).Zuora__Zuora_Id__c);
                    zObject.setValue('ARMS_Business_Profile__c', billAccIdToRecord_MAP.get(bAccUpd.CCRID__c).ARMS_Business_Profile__c);
                    zObject.setValue('ARMS_Debt_Management__c', billAccIdToRecord_MAP.get(bAccUpd.CCRID__c).ARMS_Debt_Management__c);
                    //START D-3300 03-Aug-2015 Added by S.Puli-clear fields in Zuora
                    zObject.setValue('ARMS_Account_Number__c', billAccIdToRecord_MAP.get(bAccUpd.CCRID__c).ARMS_Account_Number__c);
                    //END D-3300 03-Aug-2015 Added by S.Puli-clear fields in Zuora
                    zObjectList.add(zObject);
                }
                // end prepare data for zuora update
                //END UD-1735 7/8/2015 Added By C. Lin
                */
                //END UD-2375 08/28/2015 Added by J.Sarion - Commented out
            }
            //START UD-2375 08/28/2015 Added by J.Sarion - Commented out
            /*
            //START UD-1735 7/8/2015 Added By C. Lin - Update ARMS Details in Zuora
            if (zObjectList <> null && zObjectList.size() > 0) {
                List<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(zObjectList);
            }
            //END UD-1735 7/8/2015 Added By C. Lin
            */
            //END UD-2375 08/28/2015 Added by J.Sarion - Commented out
            
            if(accBatchToDeleteList<>null && accBatchToDeleteList.size()>0){
                delete accBatchToDeleteList;
            }
            //Start D-4078 15-Dec-2015 Added by S.Puli
            if(logList.size()>0){   
                Database.insert(logList, false);
            }
            //End D-4078 15-Dec-2015 Added by S.Puli
        }
    }
    //START: D-1013 12/06/14 Added by S.Puli - add updateCustomerWebservice to Update Customer online to ARMS
    @future(callout = true)
    public static void updateCustomerWebservice(Set<Id> CusToUpdSet){
    //Start D-4078 15-Dec-2015 Added by S.Puli
    List<Log__c> logList = new List<Log__c>();
    //End D-4078 15-Dec-2015 Added by S.Puli
    
    //START: UD-0964/0965 04/22/2015 Added by S.PULI
    //START: UD-1528 11/06/2015 Added by S.Puli
    //START: UD-1810 08/07/2015 Added by S.Puli
    List<BT_CO_ARMS_UpdateCustomerBatchFile__c> updCusBatchRec = [Select Id, Name, UniqueKey__c, CCRID__c, Address1__c, Address2__c, Customer_Name1__c, Update_ID__c, Contact_Name__c, City_Zip__c, Postal_Code__c, Business_Profile__c, RecordType__c, Address3__c, Address4__c, Block_House_No__c, Building_Secondary__c,CareOf_AttentionTo_Indicator__c,CareOf_ATtentionTo_Party__c,Country__c,Customer_Status__c,Floor_No__c,GST_OutOfScope_Indicator__c,ID_Number__c,ID_Type__c,PO_Box_No__c,SPH_Staff_Indicator__c,Street__c,Unit_No__c,Unlink_Customer__c from BT_CO_ARMS_UpdateCustomerBatchFile__c Where  Id =: CusToUpdSet];
    //END: UD-1810 08/07/2015 Added by S.Puli
    //END: UD-1528 11/06/2015 Added by S.Puli
    //END: UD-0964/0965 04/22/2015 Added by S.PULI
    List<BT_CO_ARMS_UpdateCustomerBatchFile__c> deleteCusList = new List<BT_CO_ARMS_UpdateCustomerBatchFile__c>();
    
    //START: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
    List<BT_CO_ARMS_UpdateCustomerBatchFile__c> updCusToDelete_LIST = new List<BT_CO_ARMS_UpdateCustomerBatchFile__c>();
    
    Set<String> updCusName_SET = new Set<String>();
    Set<String> updUniqKey_SET = new Set<String>();
    Set<String> updCusNum_SET = new Set<String>();
    
        if(updCusBatchRec.size()>0){
            for(BT_CO_ARMS_UpdateCustomerBatchFile__c zc : updCusBatchRec){
                updCusName_SET.add(zc.Customer_Name1__c);
                updUniqKey_SET.add(zc.UniqueKey__c);
                updCusNum_SET.add(zc.CCRID__c);
            }
        }
    //START: UD-1528 11/06/2015 Added by S.Puli
    List<BT_CO_ARMS_UpdateCustomerBatchFile__c> oldUpdateCusRecord_LIST = [Select Id, CreatedDate,Customer_Name1__c, CCRID__c,Business_Profile__c, UniqueKey__c,Contact_Designation__c, Contact_Extension__c, Contact_Name__c, ContactNo_Email__c, Contact_Type__c, RecordType__c from BT_CO_ARMS_UpdateCustomerBatchFile__c Where CreatedDate = Today AND Customer_Name1__c IN :updCusName_SET AND UniqueKey__c IN :updUniqKey_SET AND CCRID__c IN :updCusNum_SET];
    //END: UD-1528 11/06/2015 Added by S.Puli
    Map<Id, List<BT_CO_ARMS_UpdateCustomerBatchFile__c>> updCusMasterToDetail_MAP = new Map<Id, List<BT_CO_ARMS_UpdateCustomerBatchFile__c>>();
        
        if(oldUpdateCusRecord_LIST.size()>0 && updCusBatchRec.size()>0){
            for(BT_CO_ARMS_UpdateCustomerBatchFile__c zc : updCusBatchRec){
                for(BT_CO_ARMS_UpdateCustomerBatchFile__c oldRec : oldUpdateCusRecord_LIST){
                    if(zc.Customer_Name1__c == oldrec.Customer_Name1__c && zc.UniqueKey__c == oldrec.UniqueKey__c && zc.CCRID__c == oldrec.CCRID__c){
                        if(updCusMasterToDetail_MAP.containskey(zc.Id)){
                            updCusMasterToDetail_MAP.get(zc.Id).add(oldRec);
                        } else{
                            updCusMasterToDetail_MAP.put(zc.Id, new List<BT_CO_ARMS_UpdateCustomerBatchFile__c>{oldRec});
                        }
                    }
                }
            }
        }
    //END: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
        //START UD-1735 7/8/2015 Added By C. Lin - Update ARMS Details in Zuora
        //START UD-3815 1/25/2016 Added by J.Sarion - Commented out unused codes
        /*
        Map<String, Zuora__CustomerAccount__c> billAccIdToRecord_MAP = new Map<String, Zuora__CustomerAccount__c>();
        List<Zuora__CustomerAccount__c> billAccToUpdateInZuora_LIST = [Select Id,ARMS_Customer_Number__c,ARMS_Business_Profile__c,ARMS_Debt_Management__c,Zuora__Zuora_Id__c From Zuora__CustomerAccount__c Where ARMS_Customer_Number__c IN :updCusNum_SET];
        
        if(billAccToUpdateInZuora_LIST.size()>0){
            for(Zuora__CustomerAccount__c zBillAcc : billAccToUpdateInZuora_LIST){
                if(zBillAcc.ARMS_Customer_Number__c <> null){
                    billAccIdToRecord_MAP.put(zBillAcc.ARMS_Customer_Number__c, zBillAcc);
                }
            }
        }
        */
        //END UD-3815 1/25/2016 Added by J.Sarion - Commented out unused codes
        
        List<Zuora.zObject> zObjectList = new List<Zuora.zObject>();
        Zuora.zApi zApiInstance = new Zuora.zApi();
        //START D-3268 Modified By C.I.Salas - Test Coverage
        if (!Test.isRunningTest()) {
            zApiInstance.zlogin();
        }
        //END D-3268 Modified By C.I.Salas - Test Coverage
        //END UD-1735 7/8/2015 Added By C. Lin
        if(updCusBatchRec<>null && updCusBatchRec.size()>0){
        
            for(BT_CO_ARMS_UpdateCustomerBatchFile__c bc : updCusBatchRec){
            
            wwwSphComArWsWsdlCam.UpdateCustomerRequestType updCusRec = new wwwSphComArWsWsdlCam.UpdateCustomerRequestType();
            updCusRec.CusUpd = new wwwSphComArWsSchemaCamUpdatecusto.CusUpd_element();
            system.debug(updCusRec);
            
            updCusRec.CusUpd.SysId = ConstantsSLB.getOther('ARMS_SysId');
            updCusRec.CusUpd.CusN = bc.CCRID__c;
            updCusRec.CusUpd.CusM1 = bc.Customer_Name1__c;
            updCusRec.CusUpd.UniqId = bc.UniqueKey__c;
            updCusRec.CusUpd.Syno = bc.UniqueKey__c;
            updCusRec.CusUpd.CusA1 = bc.Address1__c;
            updCusRec.CusUpd.CusA2 = bc.Address2__c;
            updCusRec.CusUpd.UpdId = bc.Update_ID__c;
                String datedata = String.valueOf(date.today());
                String datestring = datedata.replace('-','');
            updCusRec.CusUpd.UpdDte = datestring;
                String timedata = String.valueOf(Datetime.now());
                String timesubstring = timedata.substringAfter(' ');
                String timestring = timesubstring.replace(':','');
            updCusRec.CusUpd.UpdTme = timestring;
            updCusRec.CusUpd.CityM = bc.City_Zip__c;
            updCusRec.CusUpd.PstC = bc.Postal_Code__c;
            //START: UD-0802 04/08/2015 Added by S.PULI
            updCusRec.CusUpd.BizP = bc.Business_Profile__c;
            //START: UD-1810 08/07/2015 Added by S.Puli
            if(bc.Unlink_Customer__c == GlobalVariableClass.STRING_Y){
                updCusRec.CusUpd.Unlnk = bc.Unlink_Customer__c;
            }else{
                updCusRec.CusUpd.Unlnk = GlobalVariableClass.STRING_N;
            }
            //END: UD-1810 08/07/2015 Added by S.Puli
            //END: UD-0802 04/08/2015 Added by S.PULI
            
            //START: UD-1528 11/06/2015 Added by S.Puli
            updCusRec.CusUpd.CusA3 = bc.Address3__c;
            updCusRec.CusUpd.CusA4 = bc.Address4__c;
            updCusRec.CusUpd.BlkN = bc.Block_House_No__c;
            updCusRec.CusUpd.BldgSec = bc.Building_Secondary__c;
            updCusRec.CusUpd.AttnI = bc.CareOf_AttentionTo_Indicator__c;
            updCusRec.CusUpd.Attn = bc.CareOf_ATtentionTo_Party__c;
            updCusRec.CusUpd.Cntry = bc.Country__c;
            updCusRec.CusUpd.CusSts = bc.Customer_Status__c;
            updCusRec.CusUpd.FlrN = bc.Floor_No__c;
            updCusRec.CusUpd.GstOOSI = bc.GST_OutOfScope_Indicator__c;
            updCusRec.CusUpd.IdN = bc.ID_Number__c;
            updCusRec.CusUpd.IdTyp = bc.ID_Type__c;
            updCusRec.CusUpd.PoBoxN = bc.PO_Box_No__c;
            updCusRec.CusUpd.StfI = bc.SPH_Staff_Indicator__c;
            updCusRec.CusUpd.Str = bc.Street__c;
            updCusRec.CusUpd.UntN = bc.Unit_No__c;
            //Unlink_Customer__c
            
            //START: UD-1528 11/06/2015 Added by S.Puli
            List<wwwSphComArWsSchemaCamUpdatecusto.ContType> contAccArray = new List<wwwSphComArWsSchemaCamUpdatecusto.ContType>();
            //START UD-2595 05-Sept-2015 Added by S.Puli - Re-link function to include new values from user input
            if(updCusMasterToDetail_MAP.containsKey(bc.Id)){
                for(BT_CO_ARMS_UpdateCustomerBatchFile__c zUpdFile : updCusMasterToDetail_MAP.get(bc.Id)){
                    
                    
                    if(zUpdFile.Contact_Type__c <> null ){  
                    
                        wwwSphComArWsSchemaCamUpdatecusto.ContType armsAccContact = new wwwSphComArWsSchemaCamUpdatecusto.ContType();
                        
                        armsAccContact.CtPeM1 = zUpdFile.Contact_Name__c;
                        armsAccContact.Dsgtn = zUpdFile.Contact_Designation__c;
                        armsAccContact.CtTyp = zUpdFile.Contact_Type__c;
                        armsAccContact.CtNoEm = zUpdFile.ContactNo_Email__c;
                        armsAccContact.CtExt = zUpdFile.Contact_Extension__c;
                        
                        contAccArray.add(armsAccContact);
                    }
                    
                }
            }
            //END UD-2595 05-Sept-2015 Added by S.Puli - Re-link function to include new values from user input
            wwwSphComArWsSchemaCamUpdatecusto.L_ContType lAccContType = new wwwSphComArWsSchemaCamUpdatecusto.L_ContType();
            lAccContType.Cont = contAccArray;
            //END: UD-1528 11/06/2015 Added by S.Puli
            updCusRec.CusUpd.L_Cont = lAccContType;
            system.debug(updCusRec);
            
            //END: UD-1528 11/06/2015 Added by S.Puli
            updCusRec.user_x = new wwwSphComArWsSchemaCommonUser.UserType();
            updCusRec.user_x.userID = ConstantsSLB.getOther('ARMS_userID');
            updCusRec.user_x.password = ConstantsSLB.getOther('ARMS_password');

            wwwSphComArWsWsdlCam.CAMSOAP CusUpdCAM = new wwwSphComArWsWsdlCam.CAMSOAP();
            wwwSphComArWsWsdlCam.UpdateCustomerResponseType updCusRespRec = CusUpdCAM.UpdateCustomer(updCusRec);
            system.debug(updCusRespRec);
            
            //Start D-4078 15-Dec-2015 Added by S.Puli - log the response file from ARMS to Log__c object
            if(boolean.valueOf(ConstantsSLB.getOther('ARMS Log Key'))){
                Log__c logRec = new Log__c();
                logRec.Message__c = String.valueOf(updCusRespRec);
                logRec.Job_ID__c = ConstantsSLB.getOther('ARMS Log');
                logList.add(logRec);
            }
            //End D-4078 15-Dec-2015 Added by S.Puli
            
                if(updCusRespRec<>null){
                    if(updCusRespRec.messages<>null){
                        if(updCusRespRec.messages.overallStatus=='Successful'){
                              
                            deleteCusList.add(bc);
                            
                        }
                    } 
                }   
                
                //START UD-2375 09/01/2015 Added by J.Sarion - Commented Out
                /*
                //START UD-1735 7/8/2015 Added By C. Lin - Update ARMS Details in Zuora
                // prepare data for zuora update
                if(billAccIdToRecord_MAP.containsKey(bc.CCRID__c)){
                    Zuora.zObject zObject = new Zuora.zObject('Account');
                    zObject.setValue('Id', billAccIdToRecord_MAP.get(bc.CCRID__c).Zuora__Zuora_Id__c);
                    //START: UD-1516 K. Tan 7/6/2015 Update Bus Prof and Debt Management Field in Zuora
                    zObject.setValue('ARMS_Business_Profile__c', bc.Business_Profile__c);
                    zObject.setValue('ARMS_Debt_Management__c', billAccIdToRecord_MAP.get(bc.CCRID__c).ARMS_Debt_Management__c);
                    //END: UD-1516 K. Tan 7/6/2015 Update Bus Prof and Debt Management Field in Zuora
                    //START: UD-1810 08/07/2015 Added by S.Puli
                    if(bc.Unlink_Customer__c == GlobalVariableClass.STRING_Y){
                        zObject.setValue('ARMS_Account_Number__c', '');
                    }
                    //END: UD-1810 08/07/2015 Added by S.Puli
                    zObjectList.add(zObject);
                }
                // end prepare data for zuora update
                //END UD-1735 7/8/2015 Added By C. Lin
                */
                //END UD-2375 09/01/2015 Added by J.Sarion - Commented Out
                
            }
            
            //START UD-2375 09/01/2015 Added by J.Sarion - Commented Out
            /*
            //START UD-1735 7/8/2015 Added By C. Lin - Update ARMS Details in Zuora
            if (zObjectList <> null && zObjectList.size() > 0) {
                List<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(zObjectList);
            }
            //END UD-1735 7/8/2015 Added By C. Lin
            */
            //END UD-2375 09/01/2015 Added by J.Sarion - Commented Out

            //START: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
            if(deleteCusList<>null && deleteCusList.size()>0){
                for(BT_CO_ARMS_UpdateCustomerBatchFile__c dRec : deleteCusList){
                    //START UD-2595 05-Sept-2015 Added by S.Puli - Re-link function to include new values from user input
                    if(updCusMasterToDetail_MAP.containsKey(dRec.Id)){
                        updCusToDelete_LIST.addAll(updCusMasterToDetail_MAP.get(dRec.Id));
                    }
                    //END UD-2595 05-Sept-2015 Added by S.Puli - Re-link function to include new values from user input//START/END D-4078 REMOVE backslash
                }
                Database.delete(updCusToDelete_LIST, false);
                system.debug('deleteCusList>>'+deleteCusList);
            }
            //END: D-3046 ARMS Update Customer 27/05/2015 Added by S.Puli
            //Start D-4078 15-Dec-2015 Added by S.Puli
            if(logList.size()>0){   
                Database.insert(logList, false);
            }
            //End D-4078 15-Dec-2015 Added by S.Puli
        }   
    }
    //END: D-1013 12/06/14 Added by S.Puli
}