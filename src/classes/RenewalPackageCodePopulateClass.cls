public class RenewalPackageCodePopulateClass
{
    String rateName;
    String renewalPackageCodeNewspaper;
    String renewalPackageCodeMagazine1YrBase;
    String renewalPackageCodeMagazine1YrDiscount;
    String renewalPackageCodeMagazine2YrBase;
    String renewalPackageCodeMagazine2YrDiscount;
    String zProductType;
    List<zqu__ProductRatePlan__c> productRPs;
    
    public void RenewalPackageCodePopulate(List<Package_Item__c> newPackageItems)
    {/* START D-4415 Gdelrosario
        // START: Code Review Implementation 2/12/2015 JAlejandro
        if (rateName != null)
        { // END: Code Review Implementation 2/12/2015 JAlejandro
            for(Package_Item__c packageItem : newPackageItems) 
            {
                if(packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')) 
                {
                    rateName = packageItem.Product_Rate_Plan__c;
                }
            }
            // START : UD-3048 11/11/2015 Alyana Navarro 
            productRPs = [SELECT Name, zqu__ZProduct__r.RenewalPkgCodeNewspaper__c, zqu__ZProduct__r.RenewalPkgCodeNewspaper__r.Package_Code__c, zqu__ZProduct__r.RenewalPkgCodeMag1YrBase__c, zqu__ZProduct__r.RenewalPkgCodeMag1YrBase__r.Package_Code__c, zqu__ZProduct__r.RenewalPkgCodeMag1YrDisc__c,zqu__ZProduct__r.RenewalPkgCodeMag1YrDisc__r.Package_Code__c, zqu__ZProduct__r.RenewalPkgCodeMag2YrBase__c, zqu__ZProduct__r.RenewalPkgCodeMag2YrBase__r.Package_Code__c, zqu__ZProduct__r.RenewalPkgCodeMag2YrDisc__c, zqu__ZProduct__r.RenewalPkgCodeMag2YrDisc__r.Package_Code__c, zqu__ZProduct__r.ProductSubType__c FROM zqu__ProductRatePlan__c WHERE Id =: rateName];
            
            for(zqu__ProductRatePlan__c productRP : productRPs) 
            {
                renewalPackageCodeNewspaper = productRP.zqu__ZProduct__r.RenewalPkgCodeNewspaper__r.Package_Code__c;
                renewalPackageCodeMagazine1YrBase = productRP.zqu__ZProduct__r.RenewalPkgCodeMag1YrBase__r.Package_Code__c;
                renewalPackageCodeMagazine1YrDiscount = productRP.zqu__ZProduct__r.RenewalPkgCodeMag1YrDisc__r.Package_Code__c;
                renewalPackageCodeMagazine2YrBase = productRP.zqu__ZProduct__r.RenewalPkgCodeMag2YrBase__r.Package_Code__c;
                renewalPackageCodeMagazine2YrDiscount = productRP.zqu__ZProduct__r.RenewalPkgCodeMag2YrDisc__r.Package_Code__c;
                zProductType = productRP.zqu__ZProduct__r.ProductSubType__c;
            }
            
            for(Package_Item__c packageItem : newPackageItems) 
            {
                if((packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Bundle Product')) && zProductType == 'Newspaper' && packageItem.RenewalPkgCodeNewspaper__c == Null) 
                    {
                        packageItem.RenewalPkgCodeNewspaper__c = renewalPackageCodeNewspaper;
                    }
                else if((packageItem.RecordTypeId == constantsSLB.getKeyID('Package Item_Base Product') || packageItem.RecordTypeId == 
                constantsSLB.getKeyID('Package Item_Bundle Product')) && zProductType == 'Magazine' && 
                packageItem.RenewalPkgCodeMag1YrBase__c == Null && packageItem.RenewalPkgCodeMag1YrDisc__c == Null && packageItem.RenewalPkgCodeMag2YrBase__c == Null && 
                packageItem.RenewalPkgCodeMag2YrDisc__c == Null) 
                    {
                        packageItem.RenewalPkgCodeMag1YrBase__c = renewalPackageCodeMagazine1YrBase;
                        packageItem.RenewalPkgCodeMag1YrDisc__c = renewalPackageCodeMagazine1YrDiscount;
                        packageItem.RenewalPkgCodeMag2YrBase__c = renewalPackageCodeMagazine2YrBase;
                        packageItem.RenewalPkgCodeMag2YrDisc__c = renewalPackageCodeMagazine2YrDiscount;    
                    }
            }
            // END : UD-3048 11/11/2015 Alyana Navarro 
        }// Code Review Implementation 2/12/2015 JAlejandro
  END D-4415 Gdelrosario */ }
}