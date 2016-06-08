/**
 * Class Name: ExceptionLogger
 * @author: John Dacutan
 * Date: 02/03/2015
 * Requirement/Project Name: CRSM Project
 * @description: Utility class to log the exception within try-catch
 *
 */

public class ExceptionLogger {

    static integer numberOfAttempt = 0;
    
    public static void log(list<exception> exceptionList) {
        
        list<Log__c> logList = new list<Log__c>();
        list<string> splittedStackTrace = new list<string>();
        Log__c log;
        
        for (exception e : exceptionList) {
            log = new Log__c();
            log.Detail__c = e.getTypeName();
            log.Stack_Trace__c = e.getStackTraceString();
            if (log.Stack_Trace__c != null) {
                splittedStackTrace = log.Stack_Trace__c.split(':');
                log.Instance__c = splittedStackTrace[0];
            }
            log.Message__c = e.getMessage();
            logList.add(log);
        }
        //START: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
        try {
            if (numberOfAttempt < 3) {
                insert logList;
                numberOfAttempt++;
            }
        } catch (exception e) {
            log(new list<exception>{e});
        }
        //END: D-2535 JLedesma 3/18/2015 Too many DML 151 fix.
    }
}