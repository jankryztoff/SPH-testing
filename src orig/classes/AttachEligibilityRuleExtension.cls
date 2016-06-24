/**
 * Class Name: AttachEligibilityRuleExtension
 * @author John Dacutan
 * Date: 2014.07.17
 * Requirement: Attach Eligibility Rule on Promotion
 * @description This class is use as extension apex code of AttachEligibilityRule VF page.
 *
 */


/*
* ------Revision------
* Version 1.0: Pilot Release
* By: <Developer ? Name>
* Description:
*/

public with sharing class AttachEligibilityRuleExtension {
    
    /*
    * @variable promotionId : holds the id of the promotion being passed thru url
    * @variable pageRef : holds the pagereference object to be used when Cancel and Save (successful) buttons are
    *       click
    * @variable packageListSelected : holds the value of the hidden field on VF page for the Package being selected
    * @variable promotionName : holds the value of the promotion name that being passed thru url. this is use
    *       in apex:sectionHeader component on VF Page
    * @variable errorMsg : error message for Package List multi-select picklist if left blank
    */
    id promotionId;
    PageReference pageRef;
    public Promotion_Eligibility_Rule__c promotionEligibilityRule { get; set; } 
    public string packageListSelected { get; set; }
    public string promotionName { get; set; }
    public string errorMsg { get; set; }
    public Set<Product_Family__c> productfamilies {get;set;}
    public String prodfamId{get;set;}
    public static List<Promotion_Eligibility_Rule__c> pErList = new List<Promotion_Eligibility_Rule__c>(); //START/END UD-0756 MGaelo 4/27/2015
    /**
    * @description : Class constructor
    * @param : StandardController
    */
    public AttachEligibilityRuleExtension(ApexPages.StandardController stdController) {
        
        if (system.currentPageReference().getParameters().get('promotionId') != null) {            
            promotionId = system.currentPageReference().getParameters().get('promotionId');
        } else {                      
           
            Promotion_Eligibility_Rule__c per = (Promotion_Eligibility_Rule__c)stdController.getRecord();
            promotionId = per.Promotion__c;          
        }
        
        promotionName = system.currentPageReference().getParameters().get('promotionName');
        this.promotionEligibilityRule = new Promotion_Eligibility_Rule__c();
        productfamilies = new Set<Product_Family__c>();
        this.promotionEligibilityRule.Promotion__c = promotionId;
        this.pageRef = new PageReference('/' + promotionId);
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
    }
    
    
    /**
    * @description : Method that will retrieve all the package code from promotion package object.
    * @return : List of SelectOption to be used in custom multi-select picklist (Package List) in VF page
    */
    public list<SelectOption> getItems() {
        
        list<SelectOption> options = new list<SelectOption>();
        
        for (Promotion_Package__c pp : [select Package_Name__r.Package_Code__c from Promotion_Package__c where Promotion__c = :promotionId]) {
            if (pp.Package_Name__r.Package_Code__c != null) {
                options.add(new SelectOption(pp.Package_Name__r.Package_Code__c, pp.Package_Name__r.Package_Code__c));
            }
        }
        
        return options;
    }
    
    
    /**
    * @description : Method that will create a record on Promotion Eligibility Rule Object.
    * @return : If all validations and criterias are pass, it will redirect to Promotion Detail page
    *       where the VF page was invoke. Otherwise, will stay on the page and prompt the user the error(s)
    * @throw : Error message when validations/criterias are not met.
    */
    public PageReference save() {
        
        errorMsg = null;
        
        // validation where both Days and Date fields must not be null, 
        // otherwise this will throw an error to the user 
        /*if (promotionEligibilityRule.Days__c == null || promotionEligibilityRule.Date__c == null) {
            promotionEligibilityRule.Days__c.addError('You must enter Days or Date.');
            //promotionEligibilityRule.Date__c.addError('You must enter Days or Date.');
            return null;
        }*/
        
        if(promotionId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please go to Promotions tab and select a promotion. Please use Attach Eligibility Rule Button.'));
            return null;
        }
		//START UD-1340 26-May-2015 Added by Raviteja - Commented Duplicate Eligibility Rule validation
		/*
        //START UD-0756 MGaelo 4/27/2015 validate duplicate eligibility rule 		

        pErList = [SELECT Id, Name, Eligibility_Rule__r.Name FROM Promotion_Eligibility_Rule__c WHERE Eligibility_Rule__c = :this.promotionEligibilityRule.Eligibility_Rule__c AND Promotion__c =: promotionId limit 1];

        if(pErList.size() > 0){
               APexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate Eligibility Rule: ' + pErList[0].Eligibility_Rule__r.Name   +'. Check Promotion Eligibility Rule: ' + pErList[0].Name));
                return null;
            }

        //END UD-0756 MGaelo 4/27/2015 validate duplicate eligibility rule 
		  */
       //End UD-1340 26-May-2015 Added by Raviteja  
        // validation where only either Days or Date field must contain a value, 
        // otherwise this will throw an error to the user 
        if (promotionEligibilityRule.Days__c != null && promotionEligibilityRule.Date__c != null) {
            promotionEligibilityRule.Days__c.addError('You cannot enter both Date and Days.');
            promotionEligibilityRule.Date__c.addError('You cannot enter both Date and Days.');
            return null;
        }

        // validation where Promotion Eligibility Rule record must contain a value at least one Package, 
        // otherwise this will throw an error to the user. addError function is not use because field being
        // used is not bind to the custom field.
        if (packageListSelected == '' || packageListSelected == null) {
            errorMsg = 'Error: You must enter a value';
            return null;
        } else {
            // refine the value of the packageListSelected to match the multi-select piklist 
            // custom field value format
            promotionEligibilityRule.Package_List__c = packageListSelected.substring(1, packageListSelected.length()).replace(';', '; ');
        }
        
        // create a record if all validations are pass
        insert promotionEligibilityRule;
        
        pageRef = new PageReference('/' + promotionEligibilityRule.Id);
        return pageRef.setRedirect(true); 

        // redirect to Promotion Detail page where the VF page was invoke
        //return pageRef;
    }
    
    
    public PageReference cancel() {
        
        //START 1/9/2015 MGaelo D-1590 redirect to Promotion detail page after cancel
        PageReference pageRef = new PageReference('/' + system.currentPageReference().getParameters().get('promotionId'));
        //END 1/9/2015  MGaelo D-1590 redirect to Promotion detail page after cancel
        pageRef.setRedirect(true);
        
        return pageRef;
    }
    
    public void addProductFamily(){
    
        //rule.Prod_Family__c
        List<Product_Family__c> prodfam =new List<Product_Family__c>([Select Id, Name From Product_Family__c Where Id = :promotionEligibilityRule.Prod_Family__c]);
        for(Product_Family__c prod : prodfam){
            productfamilies.add(prod);    
        }
        promotionEligibilityRule.Prod_Family__c = null;
        
    }
    
    public void removeProductFamily(){
    
        //rule.Prod_Family__c
        for(Product_Family__c prod : productfamilies){
            if(prod.Id == prodfamId){
                productfamilies.remove(prod);    
            }
        }
    }
    

}