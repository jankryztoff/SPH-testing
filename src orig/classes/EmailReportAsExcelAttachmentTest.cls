/**
   @author AMiranda
   @name EmailReportAsExcelAttachmentTest
   @createDate 18 Feb 2015
   @description Test for class EmailReportAsExcelAttachment
   @version 1.0 
*/
@isTest (seeAllData=true)
private class EmailReportAsExcelAttachmentTest {

    /**
        @name executeTest
        @param none
        @return void
        @description tests the execute method
    */
    /*
    public static testMethod void executeTest() {
        
        Test.StartTest();   
        
        EmailReportAsExcelAttachment obj = new EmailReportAsExcelAttachment();
        String sched1 = '0 0 0 14 5 ? 2016';    //JMG Edited Date   
        String jobID = system.schedule('sched1', sched1, obj);
         
        System.assertNotEquals(jobID, null);        
        Test.StopTest();  
              
    }
    */
    
   /**
        @name GetUserIdsFromGroupTest
        @param none
        @return void
        @description tests the GetUserIdsFromGroup method
    */ 
   public static testMethod void GetUserIdsFromGroupTest() {  
   
        Test.StartTest();
        
        List<GroupMember> myList = [Select Id, UserOrGroupId, GroupId From GroupMember Where GroupId IN (Select Id From Group) LIMIT 5];  //Where Id ='00GN0000000br5bMAA' OR Id ='00GN0000000c6DkMAI')]; 

        System.assert(myList.size() > 0);
        
        for (GroupMember gm : myList) {
            EmailReportAsExcelAttachment.GetUserIdsFromGroup(gm.GroupId);
        }
        
        Test.StopTest();
    }
    
    /*
     public static testMethod void executeTest2() {
        
        Test.StartTest();   
        
        EmailReportAsExcelAttachment obj = new EmailReportAsExcelAttachment();
        String sched1 = '0 0 0 14 5 ? 2016';  //JMG Edited Date      
        String jobID = system.schedule('sched1', sched1, obj);
         
        System.assertNotEquals(jobID, null);        
        Test.StopTest();
      
       Report schedulableReports = [SELECT Name FROM Report WHERE Name = 'Monthly CSS-KPI' OR Name = 'Direct Sub. Crediting (Newsvendor)' OR
                                                                Name = 'Direct Sub. Crediting (Publications)' OR Name = 'Amount Debited to Newsvendor' OR
                                                                Name = 'PayPal Refund Report' OR Name = 'PayPal Refund Report – Successful Trans' LIMIT 1];
                                                                
                                                                
                                                                
                                                                
       // upsert schedulableReports;       
           
             
    }
    */
     
     }