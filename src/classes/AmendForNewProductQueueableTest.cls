/**
 * Class Name: AmendForNewProductQueueableTest
 * @author: Recuerdo Bregente
 * Date: 07.17.2015
 * Requirement/Project Name: SPH
 * @description Test Class for AmendForNewProductQueueable
 */
@isTest(seeAllData=True)
private class AmendForNewProductQueueableTest {

    // Test Data
    static AmendForNewProductQueueable testClass;
    static String subscriptionIdParam;
    static Decimal adminChargeParam;
    static Date contractEffectiveDateParam;
    static Date customerAcceptanceDateParam;
    static Date effectiveDateParam;
    static Date serviceActivationDateParam;

        
    /**
    * @author : Recuerdo Bregente
    * @description : Prepares the test data objects.
    * @date: 07/17/2015
    */ 
    static void prepareTestData(){
            subscriptionIdParam = '';
            adminChargeParam  = 0.0;
            contractEffectiveDateParam = Date.today();
            customerAcceptanceDateParam = Date.today();
            effectiveDateParam = Date.today();
            serviceActivationDateParam = Date.today();
    }
    
    /**
    * @name: testConstructorAndExecuteMethod
    * @author : Recuerdo B. Bregente
    * @description : Tests the constructor and execute method.
    * @date: 07/13/2015
    */
    static testMethod void testConstructorAndExecuteMethod(){
    
        try{
             Test.startTest();
             prepareTestData();
             testClass =  new AmendForNewProductQueueable(subscriptionIdParam,
                                                        adminChargeParam,
                                                        contractEffectiveDateParam,
                                                        customerAcceptanceDateParam,
                                                        effectiveDateParam,
                                                        serviceActivationDateParam);
                                                        
             System.assertNotEquals(null, testClass);     
             QueueableContext context;
             testClass.execute(context);
             Test.stopTest();
         } catch(Zuora.zRemoteException e){
             System.assertNotEquals(null, e);
         }
    }
}