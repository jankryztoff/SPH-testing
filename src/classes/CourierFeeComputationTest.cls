/**
 * Class Name: CourierFeeComputationTest
 * @author: Alfred Abrina
 * Date: 02.15.2015
 * Requirement/Project Name: SPH
 * @description Test Class for CourierFeeComputation
 */
@isTest(SeeAllData=True)
private class CourierFeeComputationTest{    

/**
* test the computation
* @name test1
* @param res, 30
* @return 30
*/  
static testMethod void test1(){
      CourierFeeComputation comput = new CourierFeeComputation();  
      Decimal res = comput.computeCourierFee( date.today(), Date.Today().addDays(2));
      System.assertEquals (res, 30);
    }
}