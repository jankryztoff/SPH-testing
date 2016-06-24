public class BatchServiceRequestVO{
      //  String BatchAPIFunction = null;
      private integer jobStatus;
      private String jobID='';
      private Date jobDate;
      
      public integer getJobStatus() {
      return jobStatus;
      }
      
      public void setJobStatus(integer jobStatus) {
      this.jobStatus = jobStatus;
      }
      
      public String getJobID() {
      return jobID;
      }
      
      public void setJobID(String jobID)
      {
       this.jobID = jobID;
       }
       public Date getJobDate() {
       return jobDate;
       }
       public void setJobDate(Date jobDate) {
       this.jobDate = jobDate;
       }
       
      
         
     //   public void setBatchAPIFunction (String BatchAPIFunc){
    //        this.BatchAPIFunction = BatchAPIFunc;
    //    }     
    }