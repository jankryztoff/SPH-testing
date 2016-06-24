public class AddressTriggerHandler implements TriggerHandlerInterface {
    /**
     * Class Name: <AddressTriggerHandler>
     * @authors: <JohnDacutan,JerellaMayelLedesma>
     * Date: <7/15/2014>
     * Requirement/Project Name: <SPH>
     * @description <Populates specified fields based from the Postal Code lookup field>
     */
    
    //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
    Map <String, Singpost_Address__c> matchPostal = new Map <String, Singpost_Address__c> ();
    Set<String> postalCodeName = new Set<String>();
    map<string, boolean> addressIdentifier_isValid = new map<string, boolean>();    // Start/End Singpost Database JohnD
    //START D-4441 SingPostCR FrancisBenzon 22Mar16 : vars
    Map<String, Boolean> identifier_inAddressDetail = new Map<String, Boolean>();
    Boolean isExistingRec = false;
    String levelNum = ' ';
    String unitNum = ' ';
    String postalCode = ' ';
    //END D-4441 SingPostCR FrancisBenzon 22Mar16 : vars   
    
    public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !AddressTriggerHandler.isBeforeInsertTriggerCalled;
        AddressTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !AddressTriggerHandler.isBeforeUpdateTriggerCalled;
        AddressTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !AddressTriggerHandler.isBeforeDeleteTriggerCalled;
        AddressTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !AddressTriggerHandler.isAfterInsertTriggerCalled;
        AddressTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !AddressTriggerHandler.isAfterUpdateTriggerCalled;
        AddressTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !AddressTriggerHandler.isAfterDeleteTriggerCalled;
        AddressTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    
    public void bulkBefore() {
        
                //START D-4441 SingPostCR FrancisBenzon 22Mar16
        List<Address_Details__c> adDetailsLst = new List<Address_Details__c>(); //START/END SingPostCR FrancisBenzon 22Mar16             
                //END D-4441 SingPostCR FrancisBenzon 22Mar16
        if(Trigger.isUpdate || Trigger.isInsert) {
            for(SObject singPostAddressLookup : Trigger.new) {
                Address__c postalCodeInput = (Address__c)singPostAddressLookup;
                postalCodeName.add(postalCodeInput.Postal_Code__c);
                //START D-4441 SingPostCR FrancisBenzon 22Mar16
                levelNum = postalCodeInput.Level_Number__c;
                unitNum = postalCodeInput.Unit_Number__c;
                postalCode = String.valueOf(postalCodeInput.Postal_Code__c).subString(0,15);
                
                identifier_inAddressDetail.put(postalCode+';'+levelNum+';'+unitNum, isExistingRec);
                system.debug(':::MAPBefore1' + identifier_inAddressDetail);
                //END D-4441 SingPostCR FrancisBenzon 22Mar16
            }
            
            //START D-4441 SingPostCR FrancisBenzon 22Mar16
            system.debug(':::KeySet ' + identifier_inAddressDetail.keySet());
            adDetailsLst = [Select Identifier__c From Address_Details__c Where Identifier__c IN :identifier_inAddressDetail.keySet()];
            system.debug(':::ListAddDet ' + adDetailsLst);
            for(Address_Details__c details : adDetailsLst) 
            {
                identifier_inAddressDetail.put(details.Identifier__c, true);
                system.debug(':::MAPBefore2' + identifier_inAddressDetail);
            }
            system.debug(':::MAPBefore3' + identifier_inAddressDetail);
            //END D-4441 SingPostCR FrancisBenzon 22Mar16
            //Start Code Review 02/18/2015 James
            if (postalCodeName.size() > 0){
                for (Singpost_Address__c singPost : [SELECT ID, Street_Name__c, Building_Name__c, Name, Address_Type__c, House_Block_Number__c from Singpost_Address__c WHERE ID in : postalCodeName]){
                    matchPostal.put(singPost.ID, singPost);
                }
            }
            //End Code Review 02/18/2015 James
        }
    }       
        
    public void bulkAfter() {
        
    }
    
    public void beforeInsert(SObject so) {
      updateAddress(so);
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
       updateAddress(so);
    }
    
    public void beforeDelete(SObject so) {
        
    }
    
    public void afterInsert(SObject so) {
        
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        
    }

    public void afterDelete(SObject so) {
        
    }

    public void andFinally() {
        
    }
    
    public void updateAddress(SObject so){
    Address__c address = (Address__c)so;
       if(address.recordTypeID == (Id) ConstantsSLB.getKeyId('Address_Local')) {
           if(address.Postal_Code__c==null){
                //address.addError('Postal Code cannot be empty.');
                ConstantsSLB.geterrorMessage('BlankPostalCode');
           }
           else{
                Singpost_Address__c singPost = matchPostal.get(address.Postal_Code__c);
                //Postal Address will be auto-populated based on entered and validated postal code
                //address.Building_Name__c = singPost.Building_Name__c; 
                //address.Street_Name__c = singPost.Street_Name__c; 
                address.Block_House_Number__c= singPost.House_Block_Number__c;
                address.Address_Type__c= singPost.Address_Type__c;
                //Address Unique Identifier field will have a value of the concatenation of Unit Number and Postal Code
                //address.Address_Unique_ID__c = address.Unit_Number__c+'|'+singPost.Name;
        
        //START: D-1035 12/3/2014 Added by C. Lin - Address Name and Address Unique ID Format
        //Start UD-0713 James 04/01/2015 - remove null word
        string LevelNum;
        string UnitNum;
        if(address.Level_Number__c != null){
            LevelNum = address.Level_Number__c;
        }else{
            LevelNum = '';
        }
        
        if (address.Unit_Number__c != null){
            UnitNum = address.Unit_Number__c;
        }else{
            UnitNum = '';
        }       
        address.Name = LevelNum + '-' + UnitNum + ';' + singPost.Name;
        address.Address_Unique_ID__c = LevelNum + '-' + UnitNum + ';' + singPost.Name;
        //End UD-0713 James 04/01/2015 
        //END: D-1035 12/3/2014 Added by C. Lin
           }
            //START D-4441 SingPostCR FrancisBenzon 22Mar16
            String identifier = String.valueOf(address.Postal_Code__c).subString(0,15) + ';' + address.Level_Number__c + ';' + address.Unit_Number__c;
            system.debug(':::identifier ' + identifier);
            if (!Test.isRunningTest()) {    
                if(identifier_inAddressDetail.containsKey(identifier))
                {
                    if(identifier_inAddressDetail.get(identifier) == false)
                    {
                        address.addError(System.Label.ERR_SingPost);                    
                    }
                }
                else {
                    address.addError(System.Label.ERR_SingPost);               
                }
            }             
            //END D-4441 SingPostCR FrancisBenzon 22Mar16
        }
    }     
}