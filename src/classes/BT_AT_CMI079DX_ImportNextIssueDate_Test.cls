@isTest
private class BT_AT_CMI079DX_ImportNextIssueDate_Test
{   
    /**
     * Class Name: BT_AT_CMI079DX_ImportNextIssueDate_Test
     * @author : Accenture IDC : Rashmi.G.P
     * Date: 12 Feb 2015
     * Requirement/Project Name: SPH Project
     * @description Test Class for BT_AT_CMI079DX_ImportNextIssueDateInfo Trigger
     * 
     */
    
    static testMethod void unittest1()
    {
    String inputPublicationCode = '12X';
    
   
    
    Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '12X';
        pub.Published_Days__c = '1';
        pub.Publication_Type__c = 'b';
        insert pub;
        
      List<BT_CO_CMIS_POP_ImportNextIssueDateInfo__c> BTissuedateList = new List<BT_CO_CMIS_POP_ImportNextIssueDateInfo__c>();
      
        BT_CO_CMIS_POP_ImportNextIssueDateInfo__c issuedateinfo= new BT_CO_CMIS_POP_ImportNextIssueDateInfo__c();
        issuedateinfo.Name = 'CMI079DX';
        issuedateinfo.publicationCode__c = '12X';
        issuedateinfo.publicationNextStartDate__c = '02/04/2015';
    
     Test.startTest();
       BTissuedateList.add(issuedateinfo);
       Test.stopTest();
       
       
     }
      
    
   static testMethod void unittest2()
    {
     String inputPublicationCode = '12X';
     
    List<BT_CO_CMIS_POP_ImportNextIssueDateInfo__c> BTissuedateList = new List<BT_CO_CMIS_POP_ImportNextIssueDateInfo__c>();
    
        BT_CO_CMIS_POP_ImportNextIssueDateInfo__c issuedateinfo= new BT_CO_CMIS_POP_ImportNextIssueDateInfo__c();
        issuedateinfo.Name = 'CMI079DX';
        issuedateinfo.publicationCode__c = '12X';
        issuedateinfo.publicationNextStartDate__c = null;

        BTissuedateList.add(issuedateinfo);
        
           Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '12X';
        pub.Published_Days__c = '1';
        pub.Publication_Type__c = 'b';
        insert pub;
            
        Test.startTest();
        insert BTissuedateList;
        Test.stopTest();
    }
    
     
      static testMethod void unittest3()
    {   
         String inputPublicationCode = '12X';
            
       List<BT_CO_CMIS_POP_ImportNextIssueDateInfo__c> BTissuedateList = new List<BT_CO_CMIS_POP_ImportNextIssueDateInfo__c>();
     
        BT_CO_CMIS_POP_ImportNextIssueDateInfo__c issuedateinfo = new BT_CO_CMIS_POP_ImportNextIssueDateInfo__c();
        issuedateinfo.Name = 'CMI079DX';
        issuedateinfo.publicationCode__c = '12X';
        issuedateinfo.publicationNextStartDate__c = '';

        BTissuedateList.add(issuedateinfo);
        
        Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '12X';
        pub.Published_Days__c = '1';
        pub.Publication_Type__c = 'b';
        insert pub;
                   
        Test.startTest();
        insert BTissuedateList;
        Test.stopTest();
     }
     
     static testMethod void unittest4()
    {
     String inputPublicationCode = '';
     
    List<BT_CO_CMIS_POP_ImportNextIssueDateInfo__c> BTissuedateList = new List<BT_CO_CMIS_POP_ImportNextIssueDateInfo__c>();
    
        BT_CO_CMIS_POP_ImportNextIssueDateInfo__c issuedateinfo= new BT_CO_CMIS_POP_ImportNextIssueDateInfo__c();
        issuedateinfo.Name = 'CMI079DX';
        issuedateinfo.publicationCode__c = '';
        issuedateinfo.publicationNextStartDate__c = null;

        BTissuedateList.add(issuedateinfo);
        
           Publication__c pub = TestDataFactory.createPublication(1)[0];
        pub.Publication_Code__c = '';
        pub.Published_Days__c = '1';
        pub.Publication_Type__c = 'b';
        insert pub;
            
        Test.startTest();
        insert BTissuedateList;
        Test.stopTest();
    }
        
}