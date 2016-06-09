/*
* Class Name: <BT_AB_ESH1002DX_ESHOPProductTest>
* @author: Reszel Garrie Pineda
* Date: 2/05/2015
* Requirement/Project Name: <SPH>
* @description: Test class for BT_AB_ESH1002DX_ESHOPProduct
*/
@isTest
private class BT_AB_ESH1002DX_ESHOPProductTest {
    
    /* @description: This method checks DeleteProductFamiliesClass method */
    static testmethod void testBT_AB_ESH1002DX_ESHOPProduct()
    {
        
        //creation of test data
        zqu__ZProduct__c zProduct = TestDataFactory.createZProduct(1)[0];
        insert zProduct;
        
        List<BT_INT_PARAM_CONFIG__c> bipcList = new List<BT_INT_PARAM_CONFIG__c>();
        for(Integer i=0;i<11;i++){
            BT_INT_PARAM_CONFIG__c bipc = new BT_INT_PARAM_CONFIG__c();
            bipc.From_Object__c = 'zqu__ZProduct__c';
            bipc.field_sequence__c = i+1;
            bipc.interface_Name__c = 'ESH1001DX';
            bipc.postopfieldname__c = 'Name '+i;
            bipc.name = 'ESHOP000'+i;
            if(i==0){
                bipc.field_name__c = 'Sequence__c';
            } 
            
            else if(i==1){
                bipc.field_name__c = 'ProductFamily__c';
            } 
            
            else if(i==2){
                bipc.field_name__c = 'ProductCode__c';
            } 
            
            else if(i==3){
                bipc.field_name__c = 'createdby.name';
            }
            else if(i==4){
                bipc.field_name__c = 'createddate';
            }
            else if(i==5){
                bipc.field_name__c = 'lastmodifiedby.name';
            }
            else if(i==6){
                bipc.field_name__c = 'lastmodifieddate';
            }
            else if(i==7){
                bipc.field_name__c = 'name';
            }
            else if(i==8){
                bipc.field_name__c = 'zqu__Description__c';
            }
            else if(i==9){
                bipc.field_name__c = 'zqu__EffectiveStartDate__c';
            }
            else if(i==10){
                bipc.field_name__c = 'zqu__EffectiveEndDate__c';
            }
            bipcList.add(bipc);
            System.assertEquals('ESH1001DX', bipc.interface_Name__c);
        }
        insert bipcList;
        
        BatchInterface_Settings__c batchInterface = new BatchInterface_Settings__c();
        batchInterface.Name = 'Endpoint Delegator';
        batchInterface.Value__c = '10';
        insert batchInterface;
        //end of test data creation        
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new BatchServiceFacadeMockTest()); 
        BT_AB_ESH1002DX_ESHOPProduct batch = new BT_AB_ESH1002DX_ESHOPProduct('ESH1001DX');
        Database.executeBatch(batch, 200);       
       
        Test.StopTest();
        
    }//end of testBT_AB_ESH1002DX_ESHOPProduct() method
}//end of BT_AB_ESH1002DX_ESHOPProductTest