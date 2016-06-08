/**
     * Class Name: PackageProductFamilyUpdate
     * @author: Kristine Campang
     * Date: 10/24/2014
     * Requirement/Project Name: CRSM Project
     * @description Class that collects ProductFamily Code  from Package Product Family to the Eligible Product Family (Add on Package) field.
     * 
     */
public class PackageProductFamilyUpdate{
    
    list<Package__c> lpack;
    Set<id> prodFamId_list;
    Set<id> lpackageId;
    Map<Id, String> mpckfam;
    Map<Id, Package__c> mapPckIdToPckRec;
    Map<Id, List<Package_Product_Family__c>> mapPckToPckProdFamily;
    List<Package__c> pckList;
    Set<String> prodCodeSet;
    Set<Id> packageIdSet;
    String prodfam;
    
    public void updateEligibleProductFamily(List<Package_Product_Family__c> pckProdList){
        
        lpack = new list<Package__c>();
        lpackageId = new Set<id>();
        mpckfam = new Map<Id, String>();
        mapPckIdToPckRec = new Map<Id, Package__c>();
        mapPckToPckProdFamily = new Map<Id, List<Package_Product_Family__c>>();
        pckList = new List<Package__c>();
        prodCodeSet = new Set<String>();
        packageIdSet = new Set<Id>();
        prodFamId_list = new Set<id>();
        
        for(Package_Product_Family__c pckProdFamRec: pckProdList){
            
            if(pckProdFamRec.Product_Family__c != null){
                prodFamId_list.add(pckProdFamRec.Product_Family__c);
            }
            if(pckProdFamRec.Package_Name__c != null){
                packageIdSet.add(pckProdFamRec.Package_Name__c);
            }
        }
        // START: Code Review Implementation 2/17/2015 JAlejandro
        if (!packageIdSet.isEmpty())
		{
			pckList = [SELECT Id,Eligible_Product_Family_for_Add_On_Pack__c 
										FROM Package__c
										WHERE Id IN :packageIdSet];
			for(Package__c pck : pckList){
				mapPckIdToPckRec.put(pck.Id, pck);
			}
		}

        if(prodFamId_list.size() > 0 && !mapPckIdToPckRec.isEmpty()){// END: Code Review Implementation 2/13/2015 JAlejandro

            //Query Package family values
            for (Package_Product_Family__c lpackfam : [SELECT id, Product_Family_Text__c, Package_Name__c
                                                   FROM Package_Product_Family__c 
                                                   WHERE Package_Name__c IN : packageIdSet]) { 
                if(mapPckToPckProdFamily.containsKey(lpackfam.Package_Name__c)){
                     mapPckToPckProdFamily.get(lpackfam.Package_Name__c).add(lpackfam);
                }
                else{
                    mapPckToPckProdFamily.put(lpackfam.Package_Name__c, new List<Package_Product_Family__c>{lpackfam});
                }
                System.debug('MAP:' + mapPckToPckProdFamily);
            }
                
            for(Id pckRecId : mapPckToPckProdFamily.Keyset()){
                if(mapPckIdToPckRec.containsKey(pckRecId)){
                    Package__c pckRec = mapPckIdToPckRec.get(pckRecId);
                    List<Package_Product_Family__c> pckProdFamList = new List<Package_Product_Family__c>();
                    pckProdFamList = mapPckToPckProdFamily.get(pckRec.Id);
                    for(Package_Product_Family__c packProdFam : pckProdFamList){
                        prodCodeSet.add(packProdFam.Product_Family_Text__c);
                        prodfam='';
                        Integer counter = 0;
                        for (String prodCode : prodCodeSet){
                            prodfam = prodfam + prodCode;
                            if(counter<prodCodeSet.size()-1)
                            {
                                prodfam = prodfam +',' /*+ prodCode*/;
                                counter++;
                            }
                        }
                        /* Removed method 
                        //Consolidate Product Family values                                    
                        if(String.IsBlank(prodfam)) { 
                            prodfam = lpackfam.Product_Family_Text__c; 
                        }
                        else {
                            prodfam = prodfam + ', ' + lpackfam.Product_Family_Text__c;
                        }
                        */          
                                
                        //
                        mpckfam.put(packProdFam.Package_Name__c,prodfam);
                        lpackageId.add(packProdFam.Package_Name__c); 
                    }
                }
            
            }                                           
        }
        
        if(mpckfam.size() > 0){
            //Populate parent Package Eligible Product Famliy field
            for(Package__c finalpack : [SELECT id, Eligible_Product_Family_for_Add_On_Pack__c
                                        FROM Package__c
                                        WHERE Id IN: lpackageId]) {
                if(mpckfam.containsKey(finalpack.Id)){
                    finalpack.Eligible_Product_Family_for_Add_On_Pack__c = mpckfam.get(finalpack.Id);
                    lpack.add(finalpack);
                }
            }
            
            if(lpack.size() > 0){
            
                Update lpack;
            }
        }
    
    }
	//START D-0837 12/15/2014 Added by Manolo Vale�a - added new method to update "Eligible Product Family(for Add-On Pack)" field of package when a package product family record is deleted.
    Id prodFamId;
    Id packId;
    Id prodFamCode;
    String newCodes;
    
    public void updateDeletedEligibleProductFamily(List<Package_Product_Family__c> toDeletePckProdList)
    {
        for(Package_Product_Family__c del : toDeletePckProdList)
        {
            packId = del.Package_Name__c;
            prodFamId = del.Product_Family__c;
            prodFamCode = del.Product_Family__c;
        }
        // START: Code Review Implementation 2/17/2015 JAlejandro
		if ( packId != null && prodFamCode != null)
		{
			List<Package_Product_Family__c> ppfRecords = [SELECT Product_Family__r.Product_Family__c 
														  FROM Package_Product_Family__c 
														  WHERE Package_Name__c =: packId
														  AND Product_Family__c != : prodFamCode]; 
			for(Package_Product_Family__c p : ppfRecords)
			{
				if(newCodes == Null)
				{
					newCodes = p.Product_Family__r.Product_Family__c;
				}
				else
				{
					newCodes = newCodes + ',' + p.Product_Family__r.Product_Family__c;
				}
			}
			
			List<Package__c> packUpdates = [SELECT id, Eligible_Product_Family_for_Add_On_Pack__c
											FROM Package__c
											WHERE Id =: packId];
			
			for(Package__c packUpdate : packUpdates) 
			{
				packUpdate.Eligible_Product_Family_for_Add_On_Pack__c = newCodes;
			}
			
			update packUpdates;
		}// END: Code Review Implementation 2/17/2015 JAlejandro
    }
    //END D-0837 12/15/2014 Added by Manolo Vale�a
}