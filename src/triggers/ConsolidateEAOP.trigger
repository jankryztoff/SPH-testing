/**
     * Class Name: ConsolidateEAOP
     * @author: Rica Kirsten Joy O. Mayo
     * Date: 10/16/2014
     * Requirement/Project Name: CRSM Project
     * @description Trigger that pushes all records in the Package Product Family to the Eligible Product Family (Add on Package) field.
     * 
     */
	//START D-0837 12/15/2014 Added by Manolo Vale�a - Added a before delete condition for this trigger.
trigger ConsolidateEAOP on Package_Product_Family__c (after insert, after update, before delete) {

    if((Trigger.isAfter && Trigger.isInsert) || (Trigger.isAfter && Trigger.isUpdate))
    {
        //Get Id of inserted or updated product families
        List<Package_Product_Family__c> packageProdFamilyList= trigger.new;
        PackageProductFamilyUpdate packProdFam = new PackageProductFamilyUpdate();
        packProdFam.updateEligibleProductFamily(packageProdFamilyList);
    }
    else if(Trigger.isBefore && Trigger.isDelete)
    {
        List<Package_Product_Family__c> packageProdFamilyList= trigger.old;
        PackageProductFamilyUpdate packProdFam = new PackageProductFamilyUpdate();
        packProdFam.updateDeletedEligibleProductFamily(packageProdFamilyList);
    }
    //END D-0837 12/15/2014 Added by Manolo Vale�a
}