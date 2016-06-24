@isTest 
public class BT_AB_ESH1001DX_ESHOPPublicationTest {

    static testMethod void unitTest1() {
        
                    bt_int_param_config__c paramConfig = new bt_int_param_config__c();
                    paramConfig.field_name__c = 'Publication_Code__c';
                    paramConfig.from_object__c = 'Product_Publication__c';
                    paramConfig.interface_name__c = 'Test';
                    paramConfig.field_sequence__c = 10;
                    paramConfig.postOpFieldName__c = 'Field Name';
                    database.insert(paramConfig);
                    
                    BA_INT_DATA_POOL__c datapoolHRecord = new BA_INT_DATA_POOL__c();    
                    datapoolHRecord.name = 'ESH1001DX';
                    datapoolHRecord.job_id__c = 'Test';
                    datapoolHRecord.group_id__c = 'Master';
                    datapoolHRecord.run_for_date__c = Date.today();      
                    datapoolHRecord.insert_time__c = DateTime.now(); 
                    datapoolHRecord.export_data__c = 'H,' + DateTime.now();       
                    insert datapoolHRecord;   
                    
                    Publication__c pub = testdatafactory.createPublication(1)[0];
                    pub.Name = 'test';
                    pub.platform_type__c = 'Print';
                    pub.publication_type__c = '1';  
                    database.insert(pub);
                    
                    zqu__ZProduct__c zProduct = testdatafactory.createZProduct(1)[0];
                    zProduct.ProductCode__c = '1234';
                    database.insert(zProduct);
                    
                    Product_Publication__c prodPubRec =  testdatafactory.createProductPublication(1)[0];
                    prodPubRec.Publication_Code__c = pub.id;
                    prodPubRec.ZProduct__c =  zProduct.id;
                    database.insert(prodPubRec);
                    
                   
                
                    String interfacename = 'Test';
                    try{
                    Test.StartTest();
                    BT_AB_ESH1001DX_ESHOPPublication batch = new BT_AB_ESH1001DX_ESHOPPublication(interfacename);
                    ID batchprocessid = Database.executeBatch(batch, 1);

                    Test.StopTest();
                    }catch(exception e){}
    }
}