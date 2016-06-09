global class CreditCardFailure implements Messaging.InboundEmailHandler 
{
    global Messaging.InboundEmailResult handleInboundEmail (Messaging.InboundEmail email,Messaging.InboundEnvelope envelope)
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        String subToCompare = 'Create Contact';
        
        //if(email.subject.equalsIgnoreCase(subToCompare))
        //{
            Contact con = new Contact();
            con.LastName = email.subject;
            con.Phone = '123345';
            insert con;
            /*
            //save attachment if any
            for (Messaging.Inboundemail.TextAttachment tAttachment :email.textAttachments)
            {
                Attachment attachment = new Attachment();
                
                attachment.Name = tAttachment.fileName;
                attachment.Body = Blob.valueOf(tAttachment.body);
                attachment.ParentId = con.Id;
                insert attachment;
                
            }
            
            //Save any Binary Attachment
            for (Messaging.Inboundemail.BinaryAttachment bAttachment :email.binaryAttachments)
            {
                Attachment attachment = new Attachment();
                
                attachment.Name = bAttachment.fileName;
                attachment.Body = bAttachment.body;
                attachment.ParentId = con.Id;
                insert attachment;
            }
        //}*/
        result.success = true;
        return result;
    }
    
}