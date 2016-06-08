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
        if(Trigger.isUpdate || Trigger.isInsert) {
            for(SObject singPostAddressLookup : Trigger.new) {
                Address__c postalCodeInput = (Address__c)singPostAddressLookup;
                postalCodeName.add(postalCodeInput.Postal_Code__c);            
            }
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
        }
    }
    
    
    
}