global class ScheduledReport implements System.Schedulable {
    global void execute(SchedulableContext sc) {
        ApexPages.PageReference report = new ApexPages.PageReference('/00ON0000000L0bT?excel=printable+view');
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('report.xls');
        attachment.setBody(report.getContent());
        attachment.setContentType('application/vnd.ms-excel');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
        message.setSubject('Report');
        message.setPlainTextBody('Please see attached file for the report.');
        message.setToAddresses( new String[] { 'jason.a.abolac@accenture.com' } );
        Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );   
    }
}