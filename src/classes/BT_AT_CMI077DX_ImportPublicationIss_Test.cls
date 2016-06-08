/**
  * Class Name: BT_AT_CMI077DX_ImportPublicationIss_Test
  * @author: Accenture IDC - Nilesh
  * Date: 12 Feb 2015
  * Requirement/Project Name: SPH Project
  * @description Test Class for BT_AT_CMI077DX_ImportPublicationIssue
  */
@isTest
public class BT_AT_CMI077DX_ImportPublicationIss_Test
{   
    static testMethod void executeTrigger()
    {
        List<BT_CO_CMIS_POP_ImportPublicationIssue__c> testImportPublicationIssueList = new List<BT_CO_CMIS_POP_ImportPublicationIssue__c>();
        String publicationCode = '01';
        Date today = date.today();
        String strToday = DateTime.now().format('dd.MM.yyyy');
        String strNextday = DateTime.now().addDays(1).format('dd.MM.yyyy');
        
        Publication__c testPublication = TestDataFactory.createPublication(1)[0];
            testPublication.Publication_Code__c = publicationCode;
            testPublication.Published_Days__c = 'NNNNYYY';
            testPublication.Publication_Type__c = 'Y';
        insert testPublication;
        
        Publication_Daily_Issue_Data__c testIssueData = new Publication_Daily_Issue_Data__c();
            testIssueData.Publication_Issue_Date__c = today;
            testIssueData.Publication__c = testPublication.id;
            testIssueData.Publication_Code__c = publicationCode;
            testIssueData.Consolidation_Date__c = today;
            testIssueData.Order_Closed_Indicator__c = 'Y';
        insert testIssueData;
        
        BT_CO_CMIS_POP_ImportPublicationIssue__c testImportPublicationIssue = new BT_CO_CMIS_POP_ImportPublicationIssue__c();
            testImportPublicationIssue.Name = 'XXX000XX';
            testImportPublicationIssue.pagination__c = '5';
            testImportPublicationIssue.publicationCode__c = publicationCode;
            testImportPublicationIssue.publicationIssueDate__c = strToday;
            testImportPublicationIssue.publicationIssueNumber__c = '111';
            testImportPublicationIssue.consolidationDate__c = strToday;
            testImportPublicationIssue.orderClosedIndicator__c = 'Y';
            testImportPublicationIssue.orderCloseDate__c = strToday;
        
        testImportPublicationIssueList.add(testImportPublicationIssue);
        
            testImportPublicationIssue = new BT_CO_CMIS_POP_ImportPublicationIssue__c();
            testImportPublicationIssue.Name = 'XXX000XX';
            testImportPublicationIssue.pagination__c = '5';
            testImportPublicationIssue.publicationCode__c = publicationCode;
            testImportPublicationIssue.publicationIssueDate__c = strNextday;
            testImportPublicationIssue.publicationIssueNumber__c = '111';
            testImportPublicationIssue.consolidationDate__c = strNextday;
            testImportPublicationIssue.orderClosedIndicator__c = 'Y';
            testImportPublicationIssue.orderCloseDate__c = strNextday;
        
        testImportPublicationIssueList.add(testImportPublicationIssue);

        Test.startTest();
            insert testImportPublicationIssueList;
        Test.stopTest();
    }
    
    static testMethod void executeTriggerException()
    {
        List<BT_CO_CMIS_POP_ImportPublicationIssue__c> testImportPublicationIssueList = new List<BT_CO_CMIS_POP_ImportPublicationIssue__c>();
        String strToday = DateTime.now().format('dd.MM.yyyy');
        
        BT_CO_CMIS_POP_ImportPublicationIssue__c testImportPublicationIssue = new BT_CO_CMIS_POP_ImportPublicationIssue__c();
            testImportPublicationIssue.Name = 'XXX000XX';
            testImportPublicationIssue.publicationIssueDate__c = strToday;
        testImportPublicationIssueList.add(testImportPublicationIssue);

        Test.startTest();
            insert testImportPublicationIssueList;
        Test.stopTest();
    }
    
    static testMethod void executeTriggerExceptionFalse()
    {
        List<BT_CO_CMIS_POP_ImportPublicationIssue__c> testImportPublicationIssueList = new List<BT_CO_CMIS_POP_ImportPublicationIssue__c>();
        String strToday = DateTime.now().format('dd.MM.yyyy');
        
        BT_CO_CMIS_POP_ImportPublicationIssue__c testImportPublicationIssue = new BT_CO_CMIS_POP_ImportPublicationIssue__c();
            testImportPublicationIssue.Name = 'XXX000XX';
            testImportPublicationIssue.publicationIssueDate__c = '';
        testImportPublicationIssueList.add(testImportPublicationIssue);

        Test.startTest();
            insert testImportPublicationIssueList;
        Test.stopTest();
    }
    static testMethod void executeTriggerExceptionFalse2()
    {
        List<BT_CO_CMIS_POP_ImportPublicationIssue__c> testImportPublicationIssueList = new List<BT_CO_CMIS_POP_ImportPublicationIssue__c>();
        String strToday = DateTime.now().format('dd.MM.yyyy');
        
        BT_CO_CMIS_POP_ImportPublicationIssue__c testImportPublicationIssue = new BT_CO_CMIS_POP_ImportPublicationIssue__c();
            testImportPublicationIssue.Name = 'XXX000XX';
            testImportPublicationIssue.publicationIssueDate__c = strToday;
            testImportPublicationIssue.orderClosedIndicator__c = 'Y';
        testImportPublicationIssueList.add(testImportPublicationIssue);

        Test.startTest();
            insert testImportPublicationIssueList;
        Test.stopTest();
    }
}