@isTest
private class BT_AB_ESH1001DX_TestClass{

/**
     * Class Name: BT_AB_CMI101DX_DirectSubNewspaperTest
     * @author : Nitin,Rashmi.G.P
     * Date: 12 Feb 2015
     * Requirement/Project Name: SPH Project
     * @description Test Class for BT_AB_CMI101DX_DirectSubNewspaper
     * 
     */
     
    static testmethod void unitTest1() {
   
        String interfaceName = 'ESH1001DX';
        List<BT_INT_PARAM_CONFIG__c> bipcList = new List<BT_INT_PARAM_CONFIG__c>();
        List<String> fieldName = new List<String> { 'ZProduct__r.ProductCode__c',
                                                    'Publication_Code__r.Publication_Code__c',
                                                    'Publication_Code__r.name',
                                                    'lastmodifieddate',
                                                    'createddate',
                                                    'lastmodifiedby.name',
                                                    'createdby.name',
                                                    'Publication_Code__r.publication_type__c',
                                                    'Publication_Code__r.platform_type__c'
                                                    };
        List<String> postOpName= new List<String> { 'ProductCode__c',
                                                    'Publication_Code__c',
                                                    'name',
                                                    'lastmodifieddate',
                                                    'createddate',
                                                    'name',
                                                    'name',
                                                    'publication_type__c',
                                                    'platform_type__c'
                                                    };
                                                    
        for (Integer i=0; i<fieldName.size(); i++) {
        
            BT_INT_PARAM_CONFIG__c bipc = new BT_INT_PARAM_CONFIG__c();
            bipc.From_Object__c = 'Product_Publication__c';
            bipc.field_sequence__c = i+1;
            bipc.interface_Name__c = interfaceName;
            bipc.postopfieldname__c = postOpName[i];
            bipc.name = 'ESHOP000'+i;
            bipc.field_name__c = fieldName[i];
            
            bipcList.add(bipc);
        }
    
    insert bipcList;
    
    BT_CO_Batch_Run_Request__c brr = new BT_CO_Batch_Run_Request__c();
    brr.interface_id__c='ESH1001DX';
    brr.batch_run_date__c = Date.today();
    insert brr;
        
    BatchInterface_Settings__c bis = new BatchInterface_Settings__c();
        bis.name='Endpoint Delegator';
        bis.value__c='http://localhost';
    insert bis;
    
    zqu__ZProduct__c zpr = new zqu__ZProduct__c();
    zpr.ProductCode__c = 'NitinPrd';
    zpr.zqu__SKU__c='XYZ';
    zpr.zqu__ZuoraId__c='1234';
    insert zpr;
    
    Publication__c pc = new Publication__c();
    pc.publication_type__c = 'P';
    pc.platform_type__c='O';
    pc.Published_Days__c='YYYYYYY';
    insert pc;
    
    list<zqu__ZProduct__c > lst = [select id from zqu__ZProduct__c limit 1];
    list<publication__c > lst2 = [select id from publication__c limit 1];
    Product_Publication__c ppc = new Product_Publication__c();
    ppc.ZProduct__c = lst[0].id;
    ppc.Publication_Code__c = lst2[0].id;
    insert ppc;  

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest()); 
        BT_AB_ESH1001DX_ESHOPPublication c = new BT_AB_ESH1001DX_ESHOPPublication(interfaceName);
        Database.executeBatch(c);
        Test.stopTest();
    }//end of unitTest1
}