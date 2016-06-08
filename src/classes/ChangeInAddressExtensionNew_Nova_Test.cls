/**
 * Name : ChangeInAddressExtensionNew_Nova_Test
 * Author : NovaCop Unit Test Generator
 * Description : Test class used for testing the ChangeInAddressExtensionNew
 * Date : 1/27/15 10:48 AM 
 * Modified by : Hazel Jurna M. Limot
 * Modified date : 06/19/15 02:29 PM
 * Version : <intial Draft> 
 */
@isTest
private class ChangeInAddressExtensionNew_Nova_Test { 
    /*
     *@name testSave() 
     *@return void 
     *@description This method for save () In CLASS ChangeInAddressExtensionNew.cls
     */
     static testMethod void  testSave() { 
        ChangeInAddressExtensionNew changeInAddressExtensionNewTest  =  new ChangeInAddressExtensionNew(new ApexPages.StandardController (new Case()));
        Test.startTest();
        Test.setCurrentPage(Page.ChangeInAddressCaseNewPage);
        PageReference pagereferenceTest = changeInAddressExtensionNewTest.save();
         System.assert(true);
        Test.stopTest();
    }
    /*
     *@name testCheckContactEligibility() 
     *@return void 
     *@description This method for checkContactEligibility () In CLASS ChangeInAddressExtensionNew.cls
     */
     static testMethod void  testCheckContactEligibility() { 
        ChangeInAddressExtensionNew changeInAddressExtensionNewTest  =  new ChangeInAddressExtensionNew(new ApexPages.StandardController (new Case()));
        Test.startTest();
        Test.setCurrentPage(Page.ChangeInAddressCaseNewPage);
        String stringTest = changeInAddressExtensionNewTest.checkContactEligibility();
         System.assert(true);
        Test.stopTest();
    }
    /*
     *@name testGetSubscriptions() 
     *@return void 
     *@description This method for getSubscriptions () In CLASS ChangeInAddressExtensionNew.cls
     */
     static testMethod void  testGetSubscriptions() { 
        ChangeInAddressExtensionNew changeInAddressExtensionNewTest  =  new ChangeInAddressExtensionNew(new ApexPages.StandardController (new Case()));
        Test.startTest();
        Test.setCurrentPage(Page.ChangeInAddressCaseNewPage);
        changeInAddressExtensionNewTest.getSubscriptions();
         System.assert(true);
        Test.stopTest();
    }
    /*
     *@name testCheckAllSubs() 
     *@return void 
     *@description This method for checkAllSubs () In CLASS ChangeInAddressExtensionNew.cls
     */
     static testMethod void  testCheckAllSubs() { 
        ChangeInAddressExtensionNew changeInAddressExtensionNewTest  =  new ChangeInAddressExtensionNew(new ApexPages.StandardController (new Case()));
        Test.startTest();
        Test.setCurrentPage(Page.ChangeInAddressCaseNewPage);
        changeInAddressExtensionNewTest.checkAllSubs();
         System.assert(true);
        Test.stopTest();
    }
    /*
     *@name testCheckAddressType() 
     *@return void 
     *@description This method for checkAddressType () In CLASS ChangeInAddressExtensionNew.cls
     */
     static testMethod void  testCheckAddressType() { 
        ChangeInAddressExtensionNew changeInAddressExtensionNewTest  =  new ChangeInAddressExtensionNew(new ApexPages.StandardController (new Case()));
        Test.startTest();
        Test.setCurrentPage(Page.ChangeInAddressCaseNewPage);
        Boolean booleanTest = changeInAddressExtensionNewTest.checkAddressType();
         System.assert(true);
        Test.stopTest();
    }
    /*
     *@name testCompareAddress() 
     *@return void 
     *@description This method for compareAddress () In CLASS ChangeInAddressExtensionNew.cls
     */
     static testMethod void  testCompareAddress() { 
        ChangeInAddressExtensionNew changeInAddressExtensionNewTest  =  new ChangeInAddressExtensionNew(new ApexPages.StandardController (new Case()));
        Test.startTest();
        Test.setCurrentPage(Page.ChangeInAddressCaseNewPage);
        changeInAddressExtensionNewTest.compareAddress();
         System.assert(true);
        Test.stopTest();
    }
    /*
     *@name testCreateAssignment() 
     *@return void 
     *@description This method for createAssignment () In CLASS ChangeInAddressExtensionNew.cls
     */
     static testMethod void  testCreateAssignment() { 
        ChangeInAddressExtensionNew changeInAddressExtensionNewTest  =  new ChangeInAddressExtensionNew(new ApexPages.StandardController (new Case()));
        Test.startTest();
        Test.setCurrentPage(Page.ChangeInAddressCaseNewPage);
        changeInAddressExtensionNewTest.createAssignment();
         System.assert(true);
        Test.stopTest();
    }
    /*
     *@name testPopulatePOPStartDate() 
     *@return void 
     *@description This method for populatePOPStartDate () In CLASS ChangeInAddressExtensionNew.cls
     */
     static testMethod void  testPopulatePOPStartDate() { 
        ChangeInAddressExtensionNew changeInAddressExtensionNewTest  =  new ChangeInAddressExtensionNew(new ApexPages.StandardController (new Case()));
        Test.startTest();
        Test.setCurrentPage(Page.ChangeInAddressCaseNewPage);
        changeInAddressExtensionNewTest.populatePOPStartDate();
         System.assert(true);
        Test.stopTest();
    }
    /*
     *@name testExecuteOnload() 
     *@return void 
     *@description This method for executeOnload () In CLASS ChangeInAddressExtensionNew.cls
     *@modified by : Hazel Jurna M. Limot
     *@modified date : 06/19/15 02:29 PM
     */
    /*
     static testMethod void  testExecuteOnload() { 
        ChangeInAddressExtensionNew changeInAddressExtensionNewTest  =  new ChangeInAddressExtensionNew(new ApexPages.StandardController (new Case()));
        Test.startTest();
        Test.setCurrentPage(Page.ChangeInAddressCaseNewPage);
        changeInAddressExtensionNewTest.executeOnload();
         System.assert(true);
        Test.stopTest();
    } 
     */
    /*
     *@name testCancel() 
     *@return void 
     *@description This method for cancel () In CLASS ChangeInAddressExtensionNew.cls
     */
     static testMethod void  testCancel() { 
        ChangeInAddressExtensionNew changeInAddressExtensionNewTest  =  new ChangeInAddressExtensionNew(new ApexPages.StandardController (new Case()));
        Test.startTest();
        Test.setCurrentPage(Page.ChangeInAddressCaseNewPage);
        PageReference pagereferenceTest = changeInAddressExtensionNewTest.cancel();
         System.assert(true);
        Test.stopTest();
    }
}