/**
 * Class Name: Logger
 * @Author: Wenjun Zhu
 * @Date: 18/06/2015
 * @Description: Utility class for logging
 *
 */

public class Logger {
    
    public static Boolean isDebugOn = false;
    List<Log__c> lstLogs; 
    String className;
    String jobID;
    String apexJobID; //START/End UD-3043 07-Oct-2015 Added by Raviteja - Added apexJobID variable
    
    //Initialise isBebugOn based on Custom Setting
    static
    {
        String strVal = ConstantsSLB.getOther('LOG_DEBUG_ON');
        if(strVal == 'true') isDebugOn = true;  
    }

    //constructor for Non-batch Loggin: Parameter - Class Name e.g. MyClass.class.getName()
    public Logger(String className)
    {
        this.className = className;
        this.lstLogs = new List<Log__c>();
    }
    
    //constructor for Batch Logging: Parameter - Class Name and Job ID
    public Logger(String className, String jobID)
    {
        this.className = className;
        this.jobID = jobID;
        this.lstLogs = new List<Log__c>();
    }
    //START UD-3043 07-Oct-2015 Added by Raviteja - Creatin a New constructor for ApexJob Id
    //constructor for Batch Logging: Parameter - Class Name, Job Code and Apex Job ID
    public Logger(String className, String batchjobcode, String apexjobID)
    {
        this.className = className;
        this.jobID = batchjobcode;
        this.apexJobID = apexjobID;        
        this.lstLogs = new List<Log__c>();
    }    
    // Method used to Failed log Exceptions
    public void logBatchFailure(String message,List<SObject> failedScope) 
    {      
        Log__c log = new Log__c();
        log.Instance__c = this.className;
        log.Message__c = message;
        log.isAbortLog__c = True;
        if(this.jobID != null) log.Job_ID__c = this.jobID;
        if(this.apexJobID != null) log.ApexJob_Id__c = this.apexJobID;
        String failedid='';
        for (SObject SObj : failedScope) {  
                if(failedid.length() > 131000){ break; }  //Handling String length, length should not increase 131,072            
                failedid = failedid+'\'';
                failedid = failedid+SObj.get('ID');
                failedid = failedid+'\',';                    
            }
        log.Failed_Record_ID__c = failedid;
        this.lstLogs.add(log);
    }    
    //End UD-3043 07-Oct-2015 Added by Raviteja
    
    //START D-3667 LISEN 10/14/2015 - added logic for batch logging
    public void logBatchFailure(Exception e,List<SObject> failedScope) 
    {      
        String exceptionMessage = '';
        exceptionMessage= 'Stack trace: '+ e.getStackTraceString();    
        exceptionMessage = exceptionMessage + '; Message: ' + e.getMessage();  
        
        Log__c log = new Log__c();
        log.Instance__c = this.className;
        log.Message__c = exceptionMessage;
        log.isAbortLog__c = True;
        if(this.jobID != null) log.Job_ID__c = this.jobID;
        if(this.apexJobID != null) log.ApexJob_Id__c = this.apexJobID;
        String failedid='';
        for (SObject SObj : failedScope) {  
                if(failedid.length() > 131000){ break; }  //Handling String length, length should not increase 131,072            
                failedid = failedid+'\'';
                failedid = failedid+SObj.get('ID');
                failedid = failedid+'\',';                    
            }
        log.Failed_Record_ID__c = failedid;
        this.lstLogs.add(log);
    }
    //START: D-3672 11/13/2015 Added by Kristine Balaoing - added for batch recovery
    public void logBatchFailure(Exception e,List<SObject> failedScope,String additionalMessage) 
    {      
        String exceptionMessage = '';
        exceptionMessage= 'Stack trace: '+ e.getStackTraceString();    
        exceptionMessage = exceptionMessage + '; Message: ' + e.getMessage();  
        
        Log__c log = new Log__c();
        log.Instance__c = this.className;
        log.Message__c = exceptionMessage;
        log.Stack_Trace__c = additionalMessage;
        log.isAbortLog__c = True;
        if(this.jobID != null) log.Job_ID__c = this.jobID;
        if(this.apexJobID != null) log.ApexJob_Id__c = this.apexJobID;
        String failedid='';
        for (SObject SObj : failedScope) {  
                if(failedid.length() > 131000){ break; }  //Handling String length, length should not increase 131,072            
                failedid = failedid+'\'';
                failedid = failedid+SObj.get('ID');
                failedid = failedid+'\',';                    
            }
        log.Failed_Record_ID__c = failedid;
        this.lstLogs.add(log);
    }
    //END: D-3672 11/13/2015 Added by Kristine Balaoing
       
    public Boolean isEmpty(){
        return this.lstLogs.isEmpty();
    }
    //END D-3667 LISEN 10/14/2015 - added logic for batch logging    

    //START D-3733 20-Oct-2015 LISEN - added logic for batch logging
    /**
    * Method used to log Exceptions
    */
    public void log(Exception e) 
    {
        Log__c log = new Log__c();
        
        log.Instance__c = this.className;
        log.Detail__c = e.getTypeName();
        log.Stack_Trace__c = e.getStackTraceString();
        log.Message__c = e.getMessage();
        if(this.jobID != null) log.Job_ID__c = this.jobID;
        if(this.apexJobID != null) log.ApexJob_Id__c = this.apexJobID;
        
        this.lstLogs.add(log);
    }

    /**
    * Method used to log messages without record ID
    */
    public void log(Boolean isDebug, String message) 
    {
        if(isDebug && !isDebugOn) return;
        
        Log__c log = new Log__c();
        log.Instance__c = this.className;
        log.Message__c = message;
        if(this.jobID != null) log.Job_ID__c = this.jobID;
        if(this.apexJobID != null) log.ApexJob_Id__c = this.apexJobID;
        
        this.lstLogs.add(log);
    }
    
    /**
    * Method used to log messages with specific record ID
    */
    public void log(Boolean isDebug, String message, String recordID) 
    {
        if(isDebug && !isDebugOn) return;
        
        Log__c log = new Log__c();
        log.Instance__c = className;
        log.Message__c = message;
        log.Record_ID__c = recordID;
        if(this.jobID != null) log.Job_ID__c = this.jobID;
        if(this.apexJobID != null) log.ApexJob_Id__c = this.apexJobID;
        
        this.lstLogs.add(log);
    }
    //END D-3733 20-Oct-2015 LISEN - added logic for batch logging

    /**
    * Method used to save the logs. This shall be called only once per transaction at the end
    */
    public void save() 
    {
        if(!this.lstLogs.isEmpty())
        {
            try{
                insert this.lstLogs;
            }
            catch (Exception e) {}
        }
    }
    
    //START D-3667 LISEN 10/14/2015 - added logic for batch logging
    public void setApexJobID(String apexJobID){
        this.apexJobID = apexJobID;
    }

    public void setJobID(String jobID){
        this.jobID = jobID;
    }
    //END D-3667 LISEN 10/14/2015 - added logic for batch logging
}