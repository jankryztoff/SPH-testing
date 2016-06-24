//START UD-2549 3/21/2016 Added by J.Sarion - prevent deletion
trigger InvoiceNoDelTrigger on Zuora__ZInvoice__c (before delete) {
    if(Trigger.isBefore && Trigger.isDelete)
    {
        //Lists
        /*
        List<Zuora__ZInvoice__c> invoiceList = new List<Zuora__ZInvoice__c>();
        
        //Maps
        Map<Id, Zuroa__CustomerAccount__c> billAccIdToBillAccMap = new Map<Id, Zuora__CustomerAccount__c>();
        
        //Sets
        Set<Id> billAccIdSet = new Set<Id>();
        
        for(Zuora__ZInvoice__c inv :trigger.old) {
            billAccIdSet.add(inv.Zuora__BillingAccount__c);
            inv.Zuora__Status__c = 'Cancelled';
            inv.Is_CN_Processed__c = false;
            
            invoiceList.add(inv);
        }
        
        if(!billAccIdSet.isEmpty()) {
            billAccIdToBillAccMap = new Map<Id, Zuora__CustomerAccount__c>()
        }
        
        if(!invoiceList.isEmpty()) {
            update invoiceList;
        }
        */
        
        throw new CustomException('Custom Sync : cannot delete Invoice!');
        /*
        List<Exception> exceptionList = new List<Exception>();
        String message = '';
        for(Zuora__ZInvoice__c invoice : Trigger.Old)
        {
            message += invoice.Name +'|';
        }
        exceptionList.add(new CustomException(message));
        
        // Reserve email capacity for the current Apex transaction to ensure
        // that we won't exceed our daily email limits when sending email after
        // the current transaction is committed.
        Messaging.reserveSingleEmailCapacity(7);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        String[] toAddresses = new String[] {'michael.f.de.lara@accenture.com', 'wen.jun.zhu@accenture.com', 'nitin.b.khanna@accenture.com', 'ankit.kushwaha@accenture.com'};

        String[] ccAddresses = new String[] {'william.tan@accenture.com', 'edwin.cy.tan@accenture.com', 'anup.arora@accenture.com'};

        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);

        // Specify the address used when the recipients reply to the email.
        mail.setReplyTo('wen.jun.zhu@accenture.com');
 
        // Specify the name used as the display name.
        mail.setSenderDisplayName('InvoiceNoDelTrigger');

        // Specify the subject line for your email address.
        mail.setSubject('[SPH] Invoice DELETED!!!');

        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);

        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);


        // Specify the text content of the email. 
        mail.setPlainTextBody('The following invoices have been deleted: ' + message );

        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        ExceptionLogger.log(exceptionList);  
        */
        //END UD-2549 3/21/2016 Added by J.Sarion - prevent deletion
    }
}