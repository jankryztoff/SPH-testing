/**
* Class Name: ARMS_UnlinkArmsAccController 
* @author: Accenture PDC - Sherwin Puli
* Date: 29.Oct.2014
* Requirement/Project Name: SF SPH
* @description:
*/

/**
* History: UD-1810: Class is updated replacing hard coded letters to global variables
* @author: Accenture PDC - Sherwin Puli
* Date: 9.July.2015
*/
global class ARMS_UnlinkArmsAccController{ 
   
    webservice static String updateBillAccount(Id billAccId) {
        String msg;
        String pnameAdm = ConstantsSLB.getOther('ARMS CSO Admin');
        String pnameLead = ConstantsSLB.getOther('ARMS CSO Team Leader');
        //START UD-0762: AddedBy RodelioSantos to include SPH System Admin 2 as user of Unlink ARMS Account button
    String pnameSphSysAd = ConstantsSLB.getOther ('ARMS System Administrator');//START/END UD-1567: MGaelo Change restriction from SPH System Admin 2 to System Administrator
        //END UD-0762: AddedBy RodelioSantos to include SPH System Admin 2 as user of Unlink ARMS Account button
        Profile prAdm = [Select Id, Name from Profile Where Profile.Name =: pnameAdm];
        Profile prLead = [Select Id, Name from Profile Where Profile.Name =: pnameLead];
        //START UD-0762: AddedBy RodelioSantos to include SPH System Admin 2 as user of Unlink ARMS Account button
        Profile prSphSysAd = [Select Id, Name from Profile Where Profile.Name =: pnameSphSysAd];
        //END UD-0762: AddedBy RodelioSantos to include SPH System Admin 2 as user of Unlink ARMS Account button
        //START Code Review 2/17/2015 J.Sarion - Null in where clause causes Full Table scans
        Zuora__CustomerAccount__c billAccRec = new Zuora__CustomerAccount__c();
        
        //START UD-0762: UpdatedBy RodelioSantos to include SPH System Admin 2 in the condition
        if(UserInfo.getProfileId() == prAdm.Id || UserInfo.getProfileId() == prLead.Id || UserInfo.getProfileId() == prSphSysAd.Id){
        //END UD-0762: UpdatedBy RodelioSantos to include SPH System Admin 2 in the condition
        msg = ConstantsSLB.getErrorMessage('ARMS Unlink Confirm');
        
            if (billAccId != null) {
            //START: UD-0802 04/08/2015 Added by S.PULI
                //START UD-0762 AddedBy RodelioSantos - added ARMS_Customer_Number__c to the query
                //START: UD-0964/095 04/22/2015 Added by S.PULI
                //START: UD-1567 06/16/2015 Added by MGaelo Acct and CustNum is not null
                try{
                    //Start UD-1663 James 06/22/2015 - added Zuora__External_Id__c field
                    billAccRec = [Select Id, Name, ARMS_Account_Number__c, ARMS_ID__c, ARMS_Customer_Number__c, Zuora__Account__r.AccountNumber, Other_PaymentMethod__c, Zuora__Account__r.Name,ARMS_Account_Required__c, Zuora__External_Id__c From Zuora__CustomerAccount__c Where Id = :billAccId AND ARMS_Account_Number__c != null AND ARMS_Customer_Number__c!= null AND Other_PaymentMethod__c = :GlobalVariableClass.INVOICE];
                    //End UD-1663 James 06/22/2015
                }catch(Exception e){
                    //START: UD-1528 11/06/2015 Added by S.Puli
                    msg = ConstantsSLB.getErrorMessage('ARMS Unlink Error');
                    //END: UD-1528 11/06/2015 Added by S.Puli
                    return msg;
                }
    
                //END: UD-1567 06/16/2015 Added by MGaelo Acct and CustNum is not null
                //END UD-0762 AddedBy RodelioSantos - added ARMS_Customer_Number__c to the query
                
                //START: UD-1567 06/16/2015 Added by MGaelo if billAccRec is not null
                if (billAccRec != null){
                    
                        //Start UD-1663 James 06/22/2015 - clear AMS Account Number in Zuora
                        //START UD-2653 10-Sept-2015 Added By S.Puli - remove zuora callout
                        /*
                        List<Zuora.zObject> zObjectList = new List<Zuora.zObject>();
                        Zuora.zApi zApiInstance = new Zuora.zApi();
                        try{
                            //START D-3268 7/21/2015 Modified By C.I.Salas - Test Coverage
                            if (!Test.isRunningTest()) {
                                zApiInstance.zlogin();
                            }
                            //END D-3268 7/21/2015 Modified By C.I.Salas - Test Coverage
                            Zuora.zObject zObject = new Zuora.zObject('Account');
                            zObject.setValue('Id', billAccRec.Zuora__External_Id__c);
                            zObject.setValue('ARMS_Account_Number__c', '');
                            zObjectList.add(zObject);
                                
                            if (zObjectList <> null && zObjectList.size() > 0) {
                                List<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(zObjectList);
                                system.debug('>>>zuoraarmsupdate ' + results);
                            }
                        }catch(Exception e){
                            system.debug('Error: ' + e);
                        }
                        */
                        //END UD-2653 10-Sept-2015 Added By S.Puli
                        //End UD-1663 James 06/22/2015
                            
                    //START: UD-0964/095 04/22/2015 Added by S.PULI
                    if(billAccRec.ARMS_Customer_Number__c<>null && billAccRec.ARMS_Customer_Number__c<>'' && billAccRec.ARMS_Account_Number__c<>null && billAccRec.ARMS_Account_Number__c<>''){
                    //END: UD-0964/095 04/22/2015 Added by S.PULI
                    //START: UD-1528 11/06/2015 Added by S.Puli
                    Set<Id> CusToUpdSet = new Set<Id>();
        
                        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> bCusList = new List<BT_CO_ARMS_UpdateCustomerBatchFile__c>();
                        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> bCusInsertList = new List<BT_CO_ARMS_UpdateCustomerBatchFile__c>();
                        
                        Set<Id> queryBillAccSet = new Set<Id>();
                        queryBillAccSet.add(billAccRec.Id);

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
                        
                        if(customerToCreateList.size()>0 && customerToCreateList<>null){
                            for(Zuora__CustomerAccount__c ba : customerToCreateList){
                                if(ba.Other_PaymentMethod__c == 'Invoice'){
                                    if(updCusMasterToDetail_MAP.containskey(ba.Id)){
                                        if(updCusMasterToDetail_MAP.get(ba.Id).size()>0){
                                            for(BT_CO_ARMS_UpdateCustomerBatchFile__c bRec : updCusMasterToDetail_MAP.get(ba.Id)){
                                                updCusToDelete_LIST.add(bRec);
                                            }
                                        }
                                    }

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
                                        //START: UD-1810 08/07/2015 Added by S.Puli
                                        updateCusRecord.Unlink_Customer__c = ConstantsSLB.getOther('ARMS_Unlnk');
                                        //END: UD-1810 08/07/2015 Added by S.Puli
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

                                        updateCusRecord.Contact_Name__c = ba.Billing_Contact__r.Name;
                                        //START UD-2418 02-Sept-2015 Added By S.Puli
                                        updateCusRecord.Contact_Designation__c = ba.Zuora__Account__r.Designation__c;
                                        updateCusRecord.Contact_Extension__c = ba.Billing_Contact__r.Office_Extension__c;
                                        //END UD-2418 02-Sept-2015 Added By S.Puli
                                        updateCusRecord.RecordType__c = GlobalVariableClass.STRING_MASTER;
                                        updateCusRecord.Status__c = 'New';

                                        updateCusRecord.Business_Profile__c = ba.ARMS_Business_Profile__c;
                                        updateCusRecord.ReferenceKey__c = referenceKey;
                                        updateCusRecord.SPH_Staff_Indicator__c=GlobalVariableClass.STRING_N;

                                        //START: UD-1528 07/07/2015 Added by S.Puli
                                        if(ba.Zuora__Account__r.Staff_ID__c <> null){
                                            updateCusRecord.SPH_Staff_Indicator__c = GlobalVariableClass.STRING_Y;
                                        }
                                        //END: UD-1528 07/07/2015 Added by S.Puli
                                        
                                        if(ba.Billing_Contact__r.NRIC__c != null){
                                            updateCusRecord.ID_Type__c = GlobalVariableClass.STRING_NRIC;
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
        
                                        updateCusRecord.Customer_Status__c = GlobalVariableClass.STRING_A;
                                        updateCusRecord.CareOf_AttentionTo_Indicator__c = ba.Zuora__Account__r.Attention_To_Care_Of_Indicator__c;
                                        updateCusRecord.CareOf_ATtentionTo_Party__c = ba.Attention_To_Care1__c;

                                        updateCusRecord.GST_OutOfScope_Indicator__c ='';
                                        if(ba.Zuora__Account__r.GST_Out_of_Scope__c){
                                            updateCusRecord.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_Y;
                                        } else{
                                            updateCusRecord.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_N;
                                        }


                                        if(ba.Billing_Contact__r.Address__r.recordType.developerName == GlobalVariableClass.STRING_LOCAL){
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
                                        
                                        if(ba.Billing_Contact__r.Address__r.recordType.developerName == GlobalVariableClass.STRING_OVERSEAS){
                                            updateCusRecord.Address1__c = ba.Billing_Contact__r.Address__r.Address_1__c;
                                            updateCusRecord.Address2__c = ba.Billing_Contact__r.Address__r.Address_2__c;
                                            updateCusRecord.Address3__c = ba.Billing_Contact__r.Address__r.Address_3__c;
                                            updateCusRecord.Address4__c = ba.Billing_Contact__r.Address__r.Address_4__c;
                                            updateCusRecord.Country__c = ba.Billing_Contact__r.Address__r.Country__r.code__c;
                                        }
                                        
                                        if(ba.Billing_Contact__r.Address__r.recordType.developerName == GlobalVariableClass.STRING_INTERNAL){
                                            updateCusRecord.Address1__c = ba.Billing_Contact__r.Address__r.Section_Code__r.Section_Name__c;
                                            updateCusRecord.Address2__c = ba.Billing_Contact__r.Address__r.Department__r.Department_Name__c;
                                            updateCusRecord.Address3__c = ba.Billing_Contact__r.Address__r.Division_Code__r.Department_Name__c;
                                            updateCusRecord.Address4__c = ba.Billing_Contact__r.Address__r.Company_Code__r.Company_Name__c;
                                            updateCusRecord.Country__c = ba.Billing_Contact__r.Address__r.Country__r.code__c;
                                        }
                                        
                                        if(ba.Billing_Contact__r.Address__r.recordType.developerName == GlobalVariableClass.STRING_AIRLINE){
                                            updateCusRecord.Address1__c = (ba.Billing_Contact__r.Address__r.City__r.City_Name__c.length() > 40 ? ba.Billing_Contact__r.Address__r.City__r.City_Name__c.subString(0,40) : ba.Billing_Contact__r.Address__r.City__r.City_Name__c ) ;
                                            updateCusRecord.Address2__c = ba.Billing_Contact__r.Address__r.Airline_Number__c;
                                            updateCusRecord.Address3__c = ba.Billing_Contact__r.Address__r.Flight_Number_1__c;
                                            updateCusRecord.Address4__c = ba.Billing_Contact__r.Address__r.Flight_Number_2__c;
                                            updateCusRecord.Country__c = ba.Billing_Contact__r.Address__r.Country__r.code__c;
                                        }
                                        
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
                                        //START UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                                        //updateCusRecord2.Contact_Name__c = ba.Billing_Contact__r.Name;
                                        //END UD-2418 02-Sept-2015 Added By S.Puli
                                        updateCusRecord2.RecordType__c = GlobalVariableClass.STRING_DETAIL;
                                        updateCusRecord2.Status__c = 'New';
                                        updateCusRecord2.Business_Profile__c = ba.ARMS_Business_Profile__c;

                                        updateCusRecord2.ContactNo_Email__c = ba.Billing_Contact__r.Office_Number__c;
                                        updateCusRecord2.Contact_Type__c = GlobalVariableClass.STRING_O;
                                        //START UD-2418 02-Sept-2015 Added By S.Puli - Remove null "Detail" file, remove contact Designation, name, ext
                                        //updateCusRecord2.Contact_Designation__c = ba.Zuora__Account__r.Designation__c;
                                        //updateCusRecord2.Contact_Extension__c = ba.Billing_Contact__r.Office_Extension__c; 
                                        //END UD-2418 02-Sept-2015 Added By S.Puli
                                        updateCusRecord2.Customer_Status__c = GlobalVariableClass.STRING_A;
                                        if(ba.Billing_Contact__r.NRIC__c != null){
                                            updateCusRecord2.ID_Type__c = GlobalVariableClass.STRING_NRIC;
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

                                        updateCusRecord2.GST_OutOfScope_Indicator__c ='';
                                        if(ba.Zuora__Account__r.GST_Out_of_Scope__c){
                                            updateCusRecord2.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_Y;
                                        } else{
                                            updateCusRecord2.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_N;
                                        }
                                        
                                        //START: UD-1528 11/06/2015 Added by S.Puli
                                        if(updateCusRecord2.ContactNo_Email__c == null){
                                            updateCusRecord2.Contact_Type__c = null;
                                        }
                                        //END: UD-1528 11/06/2015 Added by S.Puli
                                        
                                        BT_CO_ARMS_UpdateCustomerBatchFile__c cusRec3 = null;
                                        BT_CO_ARMS_UpdateCustomerBatchFile__c cusRec4 = null;
                                        BT_CO_ARMS_UpdateCustomerBatchFile__c cusRec5 = null;
                                        BT_CO_ARMS_UpdateCustomerBatchFile__c cusRec6 = null;

                                        if(ba.Billing_Contact__r.HomePhone__c != null){
                                            cusRec3 = updateCusRecord2.clone();
                                            cusRec3.Contact_Type__c = GlobalVariableClass.STRING_H;
                                            cusRec3.ContactNo_Email__c = ba.Billing_Contact__r.HomePhone__c;

                                            cusRec3.Customer_Status__c = GlobalVariableClass.STRING_A;
                                            if(ba.Billing_Contact__r.NRIC__c != null){
                                                cusRec3.ID_Type__c = GlobalVariableClass.STRING_NRIC;
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

                                            cusRec3.GST_OutOfScope_Indicator__c ='';
                                            if(ba.Zuora__Account__r.GST_Out_of_Scope__c){
                                                cusRec3.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_Y;
                                            } else{
                                                cusRec3.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_N;
                                            }

                                        }
                                        
                                        if(ba.Billing_Contact__r.Mobile_Number__c != null || ba.Billing_Contact__r.Mobile_Number_2__c != null){
                                            cusRec4 = updateCusRecord2.clone();
                                            cusRec4.Contact_Type__c=GlobalVariableClass.STRING_M;
                                            if(ba.Billing_Contact__r.Mobile_Number__c <> null){
                                                cusRec4.ContactNo_Email__c = ba.Billing_Contact__r.Mobile_Number__c;
                                            } else if(ba.Billing_Contact__r.Mobile_Number_2__c <> null){
                                                cusRec4.ContactNo_Email__c = ba.Billing_Contact__r.Mobile_Number_2__c;
                                            }

                                            cusRec4.Customer_Status__c = GlobalVariableClass.STRING_A;
                                            if(ba.Billing_Contact__r.NRIC__c != null){
                                                cusRec4.ID_Type__c = GlobalVariableClass.STRING_NRIC;
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

                                            cusRec4.GST_OutOfScope_Indicator__c ='';
                                            if(ba.Zuora__Account__r.GST_Out_of_Scope__c){
                                                cusRec4.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_Y;
                                            } else{
                                                cusRec4.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_N;
                                            }

                                        }

                                        if(ba.Billing_Contact__r.Fax__c != null){

                                            cusRec5 = updateCusRecord2.clone();
                                            cusRec5.Contact_Type__c = GlobalVariableClass.STRING_F;

                                            cusRec5.ContactNo_Email__c = ba.Billing_Contact__r.Fax__c;

                                            cusRec5.Customer_Status__c = GlobalVariableClass.STRING_A;
                                            if(ba.Billing_Contact__r.NRIC__c != null){
                                                cusRec5.ID_Type__c = GlobalVariableClass.STRING_NRIC;
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

                                            cusRec5.GST_OutOfScope_Indicator__c ='';
                                            if(ba.Zuora__Account__r.GST_Out_of_Scope__c){
                                                cusRec5.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_Y;
                                            } else{
                                                cusRec5.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_N;
                                            }

                                        }
                                        
                                        if(ba.Billing_Contact__r.Email != null){
                                            cusRec6 = updateCusRecord2.clone();
                                            cusRec6.Contact_Type__c=GlobalVariableClass.STRING_E;
                                            cusRec6.ContactNo_Email__c = ba.Billing_Contact__r.Email;

                                            cusRec6.Customer_Status__c = GlobalVariableClass.STRING_A;
                                            if(ba.Billing_Contact__r.NRIC__c != null){
                                                cusRec6.ID_Type__c = GlobalVariableClass.STRING_NRIC;
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

                                            cusRec6.GST_OutOfScope_Indicator__c ='';
                                            if(ba.Zuora__Account__r.GST_Out_of_Scope__c){
                                                cusRec6.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_Y;
                                            } else{
                                                cusRec6.GST_OutOfScope_Indicator__c =GlobalVariableClass.STRING_N;
                                            }

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

                                }
                            }

                            if(updCusToDelete_LIST.size()>0){
                                Database.delete(updCusToDelete_LIST, false);
                            }

                            if(bCusInsertList<>null && bCusInsertList.size()>0 && bCusList<>null && bCusList.size()>0){
                            
                            insert bCusInsertList;
                            
                                for(BT_CO_ARMS_UpdateCustomerBatchFile__c a : bCusList){
                                    CusToUpdSet.add(a.Id);
                                }
                            }
                            ARMS_CreateAndUpdate.updateCustomerWebservice(CusToUpdSet); 
                        }
                        billAccRec.ARMS_Account_Required__c = false;
                        //END: UD-1528 11/06/2015 Added by S.Puli
                        billAccRec.ARMS_ID__c = null;
                        billAccRec.ARMS_Account_Number__c = null;
                        //START UD0762 AddedBy RodelioSantos - updating ARMS_Customer_Number__c to null
                        billAccRec.ARMS_Customer_Number__c = null;
                        //END UD-0762 AddedBy RodelioSantos - updating ARMS_Customer_Number__c to null
                        update billAccRec;
                            //START: UD-0964/095 04/22/2015 Added by S.PULI
                    }
                        //END: UD-0964/095 04/22/2015 Added by S.PULI
                } //END UD-1567 06/16/2015 Added by MGaelo if billAccRec is not null
            }
            //END Code Review 2/17/2015 J.Sarion
        } else {
            msg = ConstantsSLB.getErrorMessage('ARMS Profile Error');
        }
        return msg;
   }
   
    //START: UD-1528 11/06/2015 Added by S.Puli - REMOVE and transfer callout to ARMS_CreateAndUpdate class
    /**@future(callout = true)
    public static void updateCustomerWebservice(Id billAccToUpdate, Id CusRecId){
    //START Code Review 2/17/2015 J.Sarion - Null in where clause causes Full Table scans
    Zuora__CustomerAccount__c batchBillAccRec = new Zuora__CustomerAccount__c();
    BT_CO_ARMS_UpdateCustomerBatchFile__c updCusBatchRec = new BT_CO_ARMS_UpdateCustomerBatchFile__c();
    
        if (billAccToUpdate != null) {
        batchBillAccRec = [Select Id, Name, ARMS_Account_Number__c, ARMS_ID__c, LastModifiedById From Zuora__CustomerAccount__c Where Id = :billAccToUpdate];
        }
        
        if (CusRecId != null) {
        updCusBatchRec = [Select Id, Name, UniqueKey__c, CCRID__c from BT_CO_ARMS_UpdateCustomerBatchFile__c Where  Id =: CusRecId];
        }
        
        if(batchBillAccRec<>null && updCusBatchRec<>null){
        
        wwwSphComArWsWsdlCam.UpdateCustomerRequestType updCusRec = new wwwSphComArWsWsdlCam.UpdateCustomerRequestType();
        updCusRec.CusUpd = new wwwSphComArWsSchemaCamUpdatecusto.CusUpd_element();
        system.debug(updCusRec);
        
        updCusRec.CusUpd.SysId = ConstantsSLB.getOther('ARMS_SysId');
        updCusRec.CusUpd.Unlnk = ConstantsSLB.getOther('ARMS_Unlnk');
        updCusRec.CusUpd.CusN = updCusBatchRec.CCRID__c;
        updCusRec.CusUpd.CusM1 = batchBillAccRec.Name;
        updCusRec.CusUpd.UniqId = updCusBatchRec.UniqueKey__c;
        updCusRec.CusUpd.CusA1 = 'Test UpdateAddress';
        updCusRec.CusUpd.UpdId = String.valueOf(batchBillAccRec.LastModifiedById).substring(0,15);
            String datedata = String.valueOf(date.today());
            String datestring = datedata.replace('-','');
        updCusRec.CusUpd.UpdDte = datestring;
            String timedata = String.valueOf(Datetime.now());
            String timesubstring = timedata.substringAfter(' ');
            String timestring = timesubstring.replace(':','');
        updCusRec.CusUpd.UpdTme = timestring;
        
        updCusRec.user_x = new wwwSphComArWsSchemaCommonUser.UserType();
        updCusRec.user_x.userID = ConstantsSLB.getOther('ARMS_userID');
        updCusRec.user_x.password = ConstantsSLB.getOther('ARMS_password');
    
        wwwSphComArWsWsdlCam.CAMSOAP CusUpdCAM = new wwwSphComArWsWsdlCam.CAMSOAP();
        wwwSphComArWsWsdlCam.UpdateCustomerResponseType updCusRespRec = CusUpdCAM.UpdateCustomer(updCusRec);
        system.debug(updCusRespRec);
        
            if(updCusRespRec<>null){
                if(updCusRespRec.messages<>null){
                    if(updCusRespRec.messages.overallStatus=='Successful'){
                        if (updCusRec.CusUpd.UniqId != null && CusRecId != null) {
                    //START: UD-0964/095 04/22/2015 Added by S.PULI
                        List<BT_CO_ARMS_UpdateCustomerBatchFile__c> newUpdateCusRecord_LIST = [Select Id, CreatedDate,Customer_Name1__c, CCRID__c,Business_Profile__c, UniqueKey__c from BT_CO_ARMS_UpdateCustomerBatchFile__c Where CreatedDate = Today AND Customer_Name1__c = :batchBillAccRec.Name AND UniqueKey__c = :updCusBatchRec.UniqueKey__c AND CCRID__c = :updCusBatchRec.CCRID__c];
                                    
                                        if(newUpdateCusRecord_LIST<>null &&newUpdateCusRecord_LIST.size()>0){
                                            Database.delete(newUpdateCusRecord_LIST,false);
                                    
                                        }
                    //END: UD-0964/095 04/22/2015 Added by S.PULI
                        }
                    }
                } 
            }   
        }   
    }
    //END Code Review 2/17/2015 J.Sarion
    **/
    //END: UD-1528 11/06/2015 Added by S.Puli
}