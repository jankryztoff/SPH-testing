/**
 * Class Name: ProductRatePlanTriggerHandler 
 * @author: Joban Bir Singh
 * Date: 7/1/2015
 * Requirement/Project Name: <SPH>
 * @description 
 * This method creates Product Publication object record when a product rate plan charge record is inserted
 * @History: 01/27/2015 Joban: modified code in the afterInsert method and commented the code in the bulkafter method.
 */
public class ProductRatePlanChargeTriggerHandler implements TriggerHandlerInterface{
    
     // set to store product Rate plan ids
     public  set<Id> setProdRatePlanId = new set<Id>();
     // map of product rate plan Id and Publiation code
     public  map<string,string> mapPRPCIdPublicationCode = new map<string,String>();  
     // map of publication Id and Publication record Id
     public  map<String,Id> mapPublicationCodePubId = new map<String,Id>(); 
     // list of Product Publication records to be inserted
     public  list<Product_Publication__c> listProductPublicationRecords = new List<Product_Publication__c>();
     // map of Rate PLan Id and Product Id 
     public  map<String,String> mapRatePlanIdProductId = new map<String,String>(); 
     public list<zqu__ProductRatePlanCharge__c> triggerNewList = new List<zqu__ProductRatePlanCharge__c>();
     public  final string BILLPLAN = 'Bill Plan';
     public  final string PRODUCT = 'Product';
     //START D-2637 Wenjun 27/03/15
     public List<zqu__ProductRatePlanCharge__c> lstChangedCharges = new List<zqu__ProductRatePlanCharge__c>(); 
     //END D-2637 Wenjun 27/03/15
    //START D-3597 05/10/2015 AddedBy FrancisBenzon : list of deleted PRPCs
    public List<sObject> listPRPCToDel = new List<zqu__ProductRatePlanCharge__c>();
    static list<exception> exceptionList = new list<exception>();
    Set<String> productCodePubCodeSet = new Set<String>();
    Set<String> pubCodeSet = new Set<String>();
    Set<String> productCodeSet = new Set<String>();
    Set<String> chargesPubCodesSet = new Set<String>();
    Set<Id> deletedChargeRPSet = new Set<Id>();
    Set<String> pubCodesForRPDeletion = new Set<String>();  //START/END UD-2656 10/27/15 AddedBy FrancisBenzon : adtl var
    List<Product_Publication__c> productPubListDelete = new List<Product_Publication__c>();
    List<zqu__ProductRatePlan__c> prpList = new List<zqu__ProductRatePlan__c>();
    Boolean forDeletion = false;
    //END D-3597 05/10/2015 AddedBy FrancisBenzon : list of deleted PRPCs
    
     //recursion flags
    public static Boolean isBeforeUpdateTriggerCalled = FALSE;
    public static Boolean isBeforeDeleteTriggerCalled = FALSE;
    public static Boolean isBeforeInsertTriggerCalled = FALSE;
    public static Boolean isAfterUpdateTriggerCalled = FALSE;
    public static Boolean isAfterDeleteTriggerCalled = FALSE;
    public static Boolean isAfterInsertTriggerCalled = FALSE;
    
     public Boolean runBeforeInsertTrigger() {
        Boolean returnVar = !ProductRatePlanChargeTriggerHandler.isBeforeInsertTriggerCalled;
        ProductRatePlanChargeTriggerHandler.isBeforeInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeUpdateTrigger() {
        Boolean returnVar = !ProductRatePlanChargeTriggerHandler.isBeforeUpdateTriggerCalled;
        ProductRatePlanChargeTriggerHandler.isBeforeUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runBeforeDeleteTrigger() {
        Boolean returnVar = !ProductRatePlanChargeTriggerHandler.isBeforeDeleteTriggerCalled;
        ProductRatePlanChargeTriggerHandler.isBeforeDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterInsertTrigger() {
        Boolean returnVar = !ProductRatePlanChargeTriggerHandler.isAfterInsertTriggerCalled;
        ProductRatePlanChargeTriggerHandler.isAfterInsertTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterUpdateTrigger() {
        Boolean returnVar = !ProductRatePlanChargeTriggerHandler.isAfterUpdateTriggerCalled;
        ProductRatePlanChargeTriggerHandler.isAfterUpdateTriggerCalled = TRUE;
        return returnVar;        
    }
    
    public Boolean runAfterDeleteTrigger() {
        Boolean returnVar = !ProductRatePlanChargeTriggerHandler.isAfterDeleteTriggerCalled;
        ProductRatePlanChargeTriggerHandler.isAfterDeleteTriggerCalled = TRUE;
        return returnVar;        
    }
        
    public void bulkBefore() {
     
    }
        
    public void bulkAfter() {
 
    }
    
    public void beforeInsert(SObject so) {
       
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
        
    }
    
    public void beforeDelete(SObject so) {
    }    
        
    
    public void afterInsert(SObject so) {
        zqu__ProductRatePlanCharge__c rec = (zqu__ProductRatePlanCharge__c)so;
        // [Joban 27/1] D-1956 Start
        //START Code Review 2/17/2015 Added By C. Lin - Excluding null values in a list.
        //START D-3597 05/10/2015 AddedBy FrancisBenzon : do not insert deleted PRPCs, no creation of prod pub for deleted PRPCs
        
        if(rec != null) {
            if(rec.zqu__Deleted__c == false)
            {
                triggerNewList.add(rec);
                if(rec.zqu__ProductRatePlan__c != null && rec.PublicationCode__c != null){
                    setProdRatePlanId.add(rec.zqu__ProductRatePlan__c); 
                    mapPRPCIdPublicationCode.put(rec.PublicationCode__c,rec.Id);            
                }           
            }
            else {
                sObject delObject = new zqu__ProductRatePlanCharge__c(Id=rec.Id);
                listPRPCToDel.add(delObject);
            }
        }
        
        //END D-3597 05/10/2015 AddedBy FrancisBenzon : do not insert deleted PRPCs, no creation of prod pub for deleted PRPCs
        //END Code Review 2/17/2015 Added By C. Lin
        // [Joban 27/1] D-1956 End
        //START D-3597 05/10/2015 AddedBy FrancisBenzon : optimized code using above
        //START Code Review 2/17/2015 Added By C. Lin - Excluding null values in a list.
        /*if(rec != null){
            //add condition here deleted
            if(rec.zqu__ProductRatePlan__c != null && rec.PublicationCode__c != null){
                setProdRatePlanId.add(rec.zqu__ProductRatePlan__c); 
                mapPRPCIdPublicationCode.put(rec.PublicationCode__c,rec.Id);            
            }  
        }*/
        //END Code Review 2/17/2015 Added By C. Lin
        //END D-3597 05/10/2015 AddedBy FrancisBenzon : optimized code using above
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        //START D-2637 Wenjun 27/03/15
        zqu__ProductRatePlanCharge__c newRec = (zqu__ProductRatePlanCharge__c)so;
        zqu__ProductRatePlanCharge__c oldRec = (zqu__ProductRatePlanCharge__c)oldSo;
        if(newRec.sum__c != oldRec.sum__c)
            lstChangedCharges.add(newRec);
        //END D-2637 Wenjun 27/03/15
        
        //START D-3597 05/10/2015 AddedBy FrancisBenzon : list of deleted PRPCs
        if(oldRec.zqu__Deleted__c == false && newRec.zqu__Deleted__c == true)
        {
            sObject delObject = new zqu__ProductRatePlanCharge__c(Id=newRec.Id);
            listPRPCToDel.add(delObject);
        }               
        //END D-3597 05/10/2015 AddedBy FrancisBenzon : list of deleted PRPCs
    }

    public void afterDelete(SObject so) {
        //START: D-2843 04/30/2015 Added by Jean Cariño - get Id of record deleted
        zqu__ProductRatePlanCharge__c newRec = (zqu__ProductRatePlanCharge__c)so;
        lstChangedCharges.add(newRec);
        //END: D-2843 04/30/2015 Added by Jean Cariño
        //START D-3597 05/10/2015 AddedBy FrancisBenzon : list of deleted PRPCs
        if(newRec.Product_Code__c != null && newRec.PublicationCode__c != null)
        {
            String productPubCodes = newRec.Product_Code__c + ':' + newRec.PublicationCode__c;
            productCodePubCodeSet.add(productPubCodes);
        }
        //START UD-2656 removedBy FrancisBenzon : logic no longer needed
        /*
        if(newRec.zqu__ProductRatePlan__c != null)
        {
            deletedChargeRPSet.add(newRec.zqu__ProductRatePlan__c); 
        } */ 
        //END UD-2656 removedBy FrancisBenzon : logic no longer needed
        //END D-3597 05/10/2015 AddedBy FrancisBenzon : list of deleted PRPCs
    }

    public void andFinally() {
        //START D-2637 Wenjun 27/03/15
        if(Trigger.isInsert)
        {
        //END D-2637 Wenjun 27/03/15
            // Query the Rate Plan object to retrieve the Product Ids
             if(!setProdRatePlanId.isEmpty()){
                 for(zqu__ProductRatePlan__c prodPlan : [Select Id,zqu__ZProduct__c,RatePlanType__c,zqu__ZProduct__r.ProductType__c,zqu__ZProduct__r.zqu__Deleted__c
                                                          from zqu__ProductRatePlan__c where Id in :setProdRatePlanId])
                {
                    //START D-2876 Wenjun 08/05/15 - Fix Null Exception
                    if(BILLPLAN.equalsIgnoreCase(prodPlan.RatePlanType__c) && 
                       PRODUCT.equalsIgnoreCase(prodPlan.zqu__ZProduct__r.ProductType__c) && 
                       prodPlan.zqu__ZProduct__r.zqu__Deleted__c == false){
                          mapRatePlanIdProductId.put(prodPlan.Id,prodPlan.zqu__ZProduct__c);                    
                    }
                    //END D-2876 Wenjun 08/05/15                                                       
                 }                                                  
             }
             // query the Product Publication object to get the publication Id
             if(!mapPRPCIdPublicationCode.isEmpty()){
                for(Publication__c publicationRec : [Select Id,Publication_Code__c from Publication__c where 
                                                     Publication_Code__c in :mapPRPCIdPublicationCode.keyset()]){
                  mapPublicationCodePubId.put(publicationRec.Publication_Code__c,publicationRec.Id);                                                
                }       
             }
           
           if(!mapRatePlanIdProductId.isEmpty() && !mapPublicationCodePubId.isEmpty()){  
               // For Each record being inserted create a junction object Record
               for(zqu__ProductRatePlanCharge__c newRec : triggerNewList){
                 Product_Publication__c proPublication = new Product_Publication__c();
                 if(mapRatePlanIdProductId.containsKey(newRec.zqu__ProductRatePlan__c)){            
                     proPublication.ZProduct__c = mapRatePlanIdProductId.get(newRec.zqu__ProductRatePlan__c);      
                 } 
                 if(mapPublicationCodePubId.containsKey(newRec.PublicationCode__c)){
                     proPublication.Publication_Code__c = mapPublicationCodePubId.get(newRec.PublicationCode__c); 
                 }                
                 listProductPublicationRecords.add(proPublication);   
               } 
           }
           if(!listProductPublicationRecords.isEmpty()){
              Database.SaveResult[] srList = database.insert(listProductPublicationRecords,false);   
               // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted PRoduct Rate Plan Charge.  ID: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }              
           }
        //START D-2637 Wenjun 27/03/15
            
            //START D-3597 05/10/2015 AddedBy FrancisBenzon : delete PRPCs
            if(listPRPCToDel.size() > 0)
            {
                try 
                {
                    delete listPRPCToDel;
                }
                catch(exception e) {
                    exceptionList.add(e);
                }
            }
            //END D-3597 05/10/2015 AddedBy FrancisBenzon : delete PRPCs
        }
        //START: D-2843 04/30/2015 Added by Jean Cariño - Added isDelete
        else if (Trigger.isUpdate || Trigger.isDelete)
        //END: D-2843 04/30/2015 Added by Jean Cariño
        {
            if(!lstChangedCharges.isEmpty())
            {
                Set<Id> setProductRatePlanIds = new Set<Id>();
                
                for(zqu__ProductRatePlanCharge__c charge : lstChangedCharges)
                    setProductRatePlanIds.add(charge.zqu__ProductRatePlan__c);
                
                
                //Retrieve all affected Package Items
                List<Package_Item__c> lstRelatedPackItems = [SELECT Package__c, Product_Family__c
                            FROM Package_Item__c WHERE Product_Rate_Plan__c in :setProductRatePlanIds];
                
                PackagePriceComputation pckComputation = new PackagePriceComputation();
                pckComputation.processPackageItems(lstRelatedPackItems);
            }
            
            //START D-3597 05/10/2015 AddedBy FrancisBenzon : delete PRPCs
            if(listPRPCToDel.size() > 0)
            {
                try 
                {
                    delete listPRPCToDel;
                }
                catch(exception e) {
                    exceptionList.add(e);
                }
            }
            
            if(productCodePubCodeSet.size() > 0)
            {
                for(String prodPub : productCodePubCodeSet)
                {
                    productCodeSet.add(prodPub.subStringBefore(':'));
                    pubCodeSet.add(prodPub.subStringAfter(':'));
                }
                //START UD-2656 AddedBy FrancisBenzon 10/27/15 : all rate plans on the product
                prpList = [Select zqu__ZProduct__r.ProductCode__c, zqu__ZProduct__c,
                           (Select Name, Product_Code__c, PublicationCode__c From zqu__R00N40000001mFVKEA2__r) 
                           From zqu__ProductRatePlan__c Where zqu__ZProduct__r.ProductCode__c IN :productCodeSet];
                
                if(prpList.size() > 0)
                {
                    for(zqu__ProductRatePlan__c prp : prpList)
                    {                       
                        for(zqu__ProductRatePlanCharge__c charge : prp.zqu__R00N40000001mFVKEA2__r)
                        {                             
                            chargesPubCodesSet.add(charge.PublicationCode__c);                          
                        }                       
                    }
                    for(String delPubCode : pubCodeSet)
                    {
                        if(!chargesPubCodesSet.contains(delPubCode))
                        {
                            pubCodesForRPDeletion.add(delPubCode);
                        }
                    }
                    //END UD-2656 AddedBy FrancisBenzon 10/27/15 : all rate plans on the product
                }               
                
                if(productCodeSet.size() > 0 && pubCodesForRPDeletion.size() > 0)
                {
                    //START UD-2656 AddedBy FrancisBenzon 10/27/15  : get product pubs that do not use the deleted pubCode
                    productPubListDelete = [Select Id, Name From Product_Publication__c Where Product_Code_Mapping__c IN :productCodeSet 
                                            AND Publication_Code_Mapping__c IN :pubCodesForRPDeletion];
                    //END UD-2656 AddedBy FrancisBenzon 10/27/15  : get product pubs that do not use the deleted pubCode                       
                    if(productPubListDelete.size() > 0)
                    {
                        try
                        {
                            delete productPubListDelete;
                        }
                        catch(exception e) {
                            exceptionList.add(e);
                        }
                    }                                       
                }
            }                               
            //END D-3597 05/10/2015 AddedBy FrancisBenzon : delete PRPCs
        }
        //END D-2637 Wenjun 27/03/15
        
        //START D-3597 05/10/2015 AddedBy FrancisBenzon : log errors
        if(exceptionList.size() > 0)
        {
            ExceptionLogger.log(exceptionList);
        }
        //END D-3597 05/10/2015 AddedBy FrancisBenzon : log errors
    }
}