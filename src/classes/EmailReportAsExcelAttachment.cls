/**
* Class Name: EmailReportAsExcelAttachment
* @author: Kay Lorica
* Date: 9/24/2014
* Requirement/Project Name: <SPH>
* @description Scheduling this report to be emailed to the user as an excel attachment
*
*/
 
global class EmailReportAsExcelAttachment implements System.Schedulable {
    global void execute(SchedulableContext sc) {

        
        List<Report> schedulableReports = new List<Report>();
        Set<id> userIds = new Set<id>();
        List<string> emailRecipients = new List<string>();
        String groupName; 
        String groupId;
        String emailAdd;  
     

       
        schedulableReports = [SELECT Id, Name FROM Report WHERE Name = 'Monthly CSS-KPI' OR Name = 'Direct Sub. Crediting (Newsvendor)' OR
                                                                Name = 'Direct Sub. Crediting (Publications)' OR Name = 'Amount Debited to Newsvendor' OR
                                                                Name = 'PayPal Refund Report' OR Name = 'PayPal Refund Report – Successful Trans' ];
        Date dateReference = date.today();        
        String reportName;
       
        for (Report schedReport :schedulableReports) {

            reportName = null;
            if (schedReport.Name == 'Monthly CSS-KPI') {
                if (dateReference.day() == 10) {
                    reportName = schedReport.Name;
                    groupName = '';
                    emailAdd = ''; 
                }
            }
            if (schedReport.Name == 'Direct Sub. Crediting (Newsvendor)') {
                if (dateReference.day() == 1) {
                    reportName = schedReport.Name;
                    groupName = '';
                    emailAdd = ConstantsSLB.getEmail('Direct Subs Newsvendor Recipient'); //CRSM_reports@sph.com.sg            
                }
            }
            if (schedReport.Name == 'Direct Sub. Crediting (Publications)') {
                if (dateReference.day() == 1) {
                    reportName = schedReport.Name;
                    groupName = '';
                    emailAdd = '';            
                }
            }
            if (schedReport.Name == 'Amount Debited to Newsvendor') {
                if (dateReference.day() == 1) {
                    reportName = schedReport.Name;
                    groupName = '';
                    emailAdd = '';            
                }
            }          
            if(Date.today() == DateUtility.getNthLastWorkingDay(Date.today() ,2)) {
                if (schedReport.Name == 'PayPal Refund Report') {
                    reportName = schedReport.Name;
                    groupName = 'CSO Admin';
                    emailAdd = '';  
                } 
            }
            if (schedReport.Name == 'PayPal Refund Report – Successful Trans') {
                if (dateReference.day() == 1) {
                    reportName = schedReport.Name;
                    groupName = 'CSO Admin';
                    emailAdd = '';            
                }   
            }

        if (reportName != null) {
            ApexPages.PageReference report = new ApexPages.PageReference('/' + schedReport.Id + '?excel=1');
           
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(reportName + '.xls');
                attachment.setBody(report.getContent());
                attachment.setContentType('application/vnd.ms-excel');
           
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
                message.setSubject('Report');
                message.setPlainTextBody('Please find attached the report excel file.');
        
        
        if (groupName != '' && groupName != null ) {
            for (Group pubGroupName : [Select Id From Group Where Name =: groupName limit 1]) {
                 groupId = pubGroupName.id;
            }
            userIds = GetUserIdsFromGroup(groupId);                            
            for (User userRecord : [Select email from user where id in: userIds]) {
                emailRecipients.add(userRecord.Email);     
            }

                message.setToAddresses( emailRecipients ); 
            } 
        else {
            message.setToAddresses( new String[] { emailAdd } );
        }     
            Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
        }
        }
    }

    public static Set<id> GetUserIdsFromGroup(Id groupId) {
        Set<Id> result = new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
    
        for (GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId = :groupId]){
            if (((String)m.UserOrGroupId).startsWith(userType)){
                result.add(m.UserOrGroupId);
            }
            else if (((String)m.UserOrGroupId).startsWith(groupType)){
                result.addAll(GetUSerIdsFromGroup(m.UserOrGroupId));
            }
        }
        return result; 
    }                    

}