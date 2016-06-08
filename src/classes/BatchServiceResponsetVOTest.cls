/* Class Name: BatchServiceResponsetVO
* @author: Reuben James V. San Diego
* Date: 2/7/2015
* @Description: This is the test class for LP_May14GiftLetterController.
* History: Patrick Pancho - 2/11/2015 - Updated Test Class for additional coverage
*April Veloso - 07/16/2015 for addtional coverage
*Joyrem Zarmaine Ayuman - 10/15/2015 for additional coverage
*/
@isTest(SeeAllData=true)
public class BatchServiceResponsetVOTest{

    static testMethod void  testBatch(){
        
        /*String BatchAPIFunction = null;*/
        Map<String, String> reqValueObject = new Map<String, String>();
        reqValueObject.put('a','sunny');
        
        String BatchAPIFunction = 'a';
        

     
        Test.startTest();           
        BatchServiceResponsetVO batch = new BatchServiceResponsetVO(reqValueObject, BatchAPIFunction);
        batch.getReqValueObject();
        Test.stopTest();
    }
}