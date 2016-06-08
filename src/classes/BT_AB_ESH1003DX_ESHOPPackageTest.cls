@isTest
private class BT_AB_ESH1003DX_ESHOPPackageTest {  

/*
* Class Name: BT_AB_ESH1003DX_ESHOPPackageTest
* @author: Accenture IDC : Rashmi.G.P
* Requirement/Project Name: SPH
* @description: BT_AB_ESH1003DX_ESHOPPackage
*/

 public static List<BA_INT_DATA_POOL__c> blist = new List<BA_INT_DATA_POOL__c>(); 
 
    static testMethod void unitTest1() { 
       
       
        bt_int_param_config__c paramConfig = new bt_int_param_config__c();
        paramConfig.field_name__c = 'Publication_Code__c';
        paramConfig.from_object__c = 'Product_Publication__c';
        paramConfig.interface_name__c = 'Test';
        paramConfig.field_sequence__c = 10;
        paramConfig.postOpFieldName__c = 'Field Name';
        database.insert(paramConfig);
        String interfaceName = 'ESH1003DX';
        List<BT_INT_PARAM_CONFIG__c> bipcList = new List<BT_INT_PARAM_CONFIG__c>();
        List<String> fieldName = new List<String> { 'Package__r.Package_Code__c',
                                                    'Product_Rate_Plan__r.zqu__ZProduct__c',
                                                    'Package__r.name',
                                                    'package__r.Subscription_Period__c',
                                                    'Product_Rate_Plan__r.zqu__Description__c',
                                                    'package__r.Package_Type__c',
                                                    'package__r.Effective_Start_Date__c',
                                                    'package__r.Effective_End_Date__c',
                                                    'createddate',
                                                    'lastmodifiedby.name',
                                                    'createdby.name',
                                                    'lastmodifieddate',
                                                    'Product_Rate_Plan__r.SubscriptionFrequency__c',
                                                    'Package__r.Channel_E_shop_public__c',
                                                    'Package__r.Channel_E_shop_overseas__c',
                                                    'Package__r.Channel_E_shop_private__c',
                                                    'Package__r.Channel_Direct__c' 
                                                     };
                                                    
        List<String> postOpName= new List<String> { 'Package_Code__c',
                                                    'zqu__ZProduct__c',
                                                    'name',
                                                    'Subscription_Period__c',
                                                    'zqu__Description__c',
                                                    'Package_Type__c',
                                                    'Effective_Start_Date__c',
                                                    'Effective_End_Date__c',
                                                    'lastmodifieddate',
                                                    'createddate',
                                                    'name',
                                                    'name',
                                                    'SubscriptionFrequency__c',
                                                    'Channel_E_shop_public__c',
                                                    'Channel_E_shop_overseas__c',
                                                    'Channel_E_shop_private__c',                                                    
                                                    'Channel_Direct__c'
                                                    };
        
        for (Integer i=0; i<fieldName.size(); i++) {
        
            BT_INT_PARAM_CONFIG__c bipc = new BT_INT_PARAM_CONFIG__c();
            bipc.From_Object__c = 'Package_Item__c';
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
        
        Package__c p = new Package__c();
        p.Package_Type__c = 'Add On';
        p.Package_Code__c = 'RashPc';
        p.Subscription_Period__c= '1';
        p.Effective_Start_Date__c = Date.Today();
        p.Effective_End_Date__c = Date.Today();
        p.Channel_E_shop_public__c = true;
        p.Channel_E_shop_overseas__c = true;
        p.Channel_E_shop_private__c = true;
        p.Channel_Direct__c = true;
        p.Subscription_Type__c = 'Termed';
        insert p;
        
        zqu__ZProduct__c zpr = new zqu__ZProduct__c();
        zpr.ProductCode__c = 'RashmiPrd';
        zpr.zqu__SKU__c='XYZ';
        zpr.zqu__ZuoraId__c='1234';
        insert zpr;
    
        zqu__ProductRatePlan__c zprp = new zqu__ProductRatePlan__c();
        zprp.zqu__ZProduct__c = zpr.id;
        zprp.zqu__Description__c = 'ABCD';
        zprp.SubscriptionFrequency__c = '0';
        zprp.RatePlanCode__c = 'RPrd';
        zprp.RatePlanType__c = 'Bill Plan';
        zprp.zqu__ZuoraId__c = '1234';
        insert zprp;
     
        Product_Family__c pf = new Product_Family__c();
        pf.Product_Family__c = 'profly';
        insert pf;
        
        list<Package__c> lst = [select id from Package__c limit 1];
        list<zqu__ProductRatePlan__c> lst2 = [select id from zqu__ProductRatePlan__c limit 1];
        list<Product_Family__c> lst3 = [select id from Product_Family__c limit 1];
        Package_Item__c pi = new Package_Item__c();
        pi.Package__c = lst[0].id;
        pi.Product_Rate_Plan__c = lst2[0].id;
        pi.Product_Family__c = lst3[0].id;
        //insert pi;  
        try{
        Test.StartTest(); 
            Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest()); 
            BT_AB_ESH1003DX_ESHOPPackage a = new BT_AB_ESH1003DX_ESHOPPackage (interfaceName); 
            ID batchprocessid = Database.executeBatch(a, 200); 
                  
            //Database.executeBatch(a);
        Test.stopTest();
        }catch(exception e){}
   
   }//end of unitTest1      
}