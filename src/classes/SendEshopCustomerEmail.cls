public with sharing class SendEshopCustomerEmail {


    list<Messaging.SingleEmailMessage> mails= new List<Messaging.SingleEmailMessage>();
    
    
    public void SendEshopCustomerEmail(){
        
    }

    
    public void SendEshopCustomerEmail(Zuora__Subscription__c zSub){
        String[] EmailAdd = new String[]{};
        
        Zuora__Subscription__c zEmail = [select Id, Zuora__CustomerAccount__r.Zuora__SoldToName__c, 
                                                Contact__r.Email__c
                                            from Zuora__Subscription__c
                                            where Id =: zSub.Id];
                                            
        EmailAdd.add('kevin.h.evasco@accenture.com');
        EmailAdd.add('krithika.dharmarajan@accenture.com');
        EmailAdd.add('nitin.b.khanna@accenture.com');
        EmailAdd.add(zEmail.Contact__r.Email__c);
        
        mails.add(this.NewMail(EmailAdd, 'Success: Subscription Creation', 
                                BodySuccess(zEmail.Zuora__CustomerAccount__r.Zuora__SoldToName__c, zSub.Id, zSub.Zuora__Zuora_Id__c, zSub.Order_Number__c)));
        
        if (mails.size()>0){        
            Messaging.sendEmail(mails);    
        }
    }
    
    public void SendEshopCustomerEmailFailure(String Name, String EmailAddress, String PackageCode){
        String[] EmailAdd = new String[]{};
                                                    
        EmailAdd.add('kevin.h.evasco@accenture.com');
        EmailAdd.add('rica.kirsten.o.mayo@accenture.com');
        EmailAdd.add(EmailAddress);
        
        mails.add(this.NewMail(EmailAdd, 'Failed: Subscription Failure', 
                                BodyFailure(Name, PackageCode)));
        
        if (mails.size()>0){        
            Messaging.sendEmail(mails);    
        }
    }

    private Messaging.SingleEmailMessage NewMail(String[] eAdd, String sSubject, String sBody){
            
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            
        mail.setToAddresses(eAdd);
        mail.setSubject(sSubject);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setHtmlBody(sBody);
        return mail;    
        
    }
    
    public string BodySuccess(string sName, string sSFSubId, string sZSubId, string sOrderId){
        string HtmlString = '';
        
        HtmlString = 'Hi <b>' + sName + '</b>,'; 
        HtmlString += '<br/> <br/>';
        HtmlString += 'Your subscription request has been completed:';
        HtmlString += '<br/> <br/> <br/> <br/>';
        HtmlString += '<b> ORDER ID: </b>' + sOrderId;
        HtmlString += '<br/>';
        HtmlString += '<b> SUBSCRIPTION ID SF: </b>' + sSFSubId;
        HtmlString += '<br/>';
        HtmlString += '<b> SUBSCRIPTION ID Zuora: </b>' + sZSubId;
        HtmlString += '<br/> <br/> <br/> <br/>';
        HtmlString += 'Thank you,'; 
        HtmlString += '<br/>';
        HtmlString += 'SPH';
        HtmlString = '<FONT FACE="arial" SIZE="2">' + HtmlString + '</FONT>';
        return HtmlString;
    }
    
    public string BodyFailure(string sName, string PackageCode){
        string HtmlString = '';
        
        HtmlString = 'Hi <b>' + sName + '</b>,'; 
        HtmlString += '<br/> <br/>';
        HtmlString += 'Your subscription request failed for the following package(s): <br/>' + PackageCode;
        HtmlString += '<br/> <br/> <br/> <br/>';
        HtmlString += 'Thank you,'; 
        HtmlString += '<br/>';
        HtmlString += 'SPH';
        HtmlString = '<FONT FACE="arial" SIZE="2">' + HtmlString + '</FONT>';
        return HtmlString;
    
    }
          
}