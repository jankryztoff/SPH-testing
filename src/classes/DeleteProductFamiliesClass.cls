public class DeleteProductFamiliesClass
{
    String perId;
    List<Promo_Eligibility_Rule_Product_Family__c> perpfStoDelete;
    
    public void DeleteProductFamilies(List<Promotion_Eligibility_Rule__c> oldPromotionEligibilityRules)
    {
        perpfStoDelete = new List<Promo_Eligibility_Rule_Product_Family__c>();
        for (Promotion_Eligibility_Rule__c per : oldPromotionEligibilityRules)
        {
            perId = per.Id;
        }
        
        perpfStoDelete = [SELECT Name, Promotion_Eligibility_Rule__c FROM Promo_Eligibility_Rule_Product_Family__c WHERE Promotion_Eligibility_Rule__c =: perId];
        if(!perpfStoDelete.isEmpty())
        {
            delete perpfStoDelete;
        }
    }
}