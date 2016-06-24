/**
 * Class Name: LoggerTest
 * @Author: Wenjun Zhu
 * @Date: 18/06/2015
 * @Description: Test Class for Logger
 *
 */

@IsTest (SeeAllData=true)
public class LoggerTest {
    
    public static testMethod void executeNormal()
    {
        //Initialise Logger - Non Batch Scenarios
        Logger logger = new Logger(LoggerTest.class.getName());
        
     
        
        //Sample 1: Log Exception
        try
        {
            throw new CustomException('Test Logger ...');
        }
        catch(Exception e)
        {
            logger.log(e);
        }
        
        //Sample 2: log debug messages without record ID
        logger.log(true,'Sample Debug Message...');
        
        //Sample 3: log non-debug messages without record ID
        logger.log(false,'Sample Error Message...');
        
        //Sample 4: log debug messages with record ID
        logger.log(true,'Sample Debug Message...','a1AN0000000ZjyI');
        
        //Sample 5: log non-debug messages with record ID
        logger.log(false,'Sample Error Message...','a1AN0000000ZjyI');
        
        //Save all Logs - Perform DML operation
        logger.save();
    }
    
    public static testMethod void executeBatch()
    {
        //Initialise Logger - Non Batch Scenarios
        Logger logger = new Logger(LoggerTest.class.getName(),'SP0XX');
        
        //Sample 1: Log Exception
        try
        {
            throw new CustomException('Test Logger ...');
        }
        catch(Exception e)
        {
            logger.log(e);
        }
        
        //Sample 2: log debug messages without record ID
        logger.log(true,'Sample Debug Message...');
        
        //Sample 3: log non-debug messages without record ID
        logger.log(false,'Sample Error Message...');
        
        //Sample 4: log debug messages with record ID
        logger.log(true,'Sample Debug Message...','a1AN0000000ZjyI');
        
        //Sample 5: log non-debug messages with record ID
        logger.log(false,'Sample Error Message...','a1AN0000000ZjyI');
        
        //Save all Logs - Perform DML operation
        logger.save();
    }
    
    public static testMethod void testLOgger(){
        //start test data
        List<Account> acc = TestDataFactory.createAccount(2, 'Direct Corporate');
        insert acc;
        //end test data
    
        test.startTest();
            Logger log = new Logger('Class Name', 'jobID01', 'APEXjobid');
            log.logBatchFailure('Message', acc);
            log.isEmpty();
            log.setApexJobID('apexjobid');
            log.setJobID('jobId');
        
            try{
                insert acc;
            }
            catch(Exception e){
                log.logBatchFailure(e, acc);   
                log.logBatchFailure(e, acc, 'Additional Message');   
            }
        test.stopTest();
    }
}