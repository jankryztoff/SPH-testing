@isTest(SeeAllData=true)

private class PDFGenerationOverseasNewspaper_Test{


    static testMethod void testPDFGenerationOverseasNewspaper(){
        Integer counter;
    
        //start test data
        Account acc = TestDataFactory.createAccount(1, 'Direct Corporate')[0];
        acc.accountNumber = '123456789';
        acc.Fax = '123456';
        insert acc;
        
        Address__c add = TestDataFactory.createAddress(1)[0];
        add.RecordTypeId = ConstantsSLB.getKeyId('Address_Overseas');
        insert add;
        
        Contact con = TestDataFactory.createContact(1)[0];
        con.Address__c = add.Id;
        insert con;
        
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(1)[0];
        billAcc.Zuora__Account__c = acc.Id;
        insert billAcc;
        
        List<Zuora__Subscription__c> subRecs = TestDataFactory.createSubscription(7);
        for(Zuora__Subscription__c sb:subRecs){
            sb.Zuora__CustomerAccount__c = billAcc.Id;
            sb.Recipient_Contact__c = con.Id;
            sb.subscription_type__c = 'Publication';
            sb.Zuora__SubscriptionStartDate__c = date.today();
            sb.Qty1__c = '1';
        }
        insert subRecs;
        
        counter=0;
        List<Zuora__SubscriptionProductCharge__c> spc = TestDataFactory.createSubscriptionProductCharge(7);
        for(Zuora__SubscriptionProductCharge__c sp:spc){
            sp.Zuora__Subscription__c = subRecs[counter].Id;
            sp.PublicationCode__c = 'BH';
            sp.Zuora__UOM__c = 'UOM001';
            if(counter==1){
                sp.PublicationCode__c = 'WB';
            }
            else if(counter==2){
                sp.PublicationCode__c = 'ZB';
            }
            else if(counter==3){
                sp.PublicationCode__c = 'TM';
            }
            else if(counter==4){
                sp.PublicationCode__c = 'BT';
            }
            else if(counter==5){
                sp.PublicationCode__c = 'ST';
            }
            else if(counter==6){
                sp.Zuora__Subscription__c = subRecs[0].Id;
                sp.PublicationCode__c = 'NP';
            }
            counter++;
        }
        insert spc;
        
        Account accQ = [SELECT accountNumber FROM Account WHERE id=:acc.Id];
        
        counter=0;
        List<Packing_Label_Batch__c> plb = new List<Packing_Label_Batch__c>();
        for(counter=0;counter<6;counter++){
            Packing_Label_Batch__c p = new Packing_Label_Batch__c();
            p.Mailing_Agent_Account_Number__c = accQ.accountNumber;
            p.Subscription_Type__c = 'Newspaper';
            p.Record_Type__c = 'Overseas';
            p.Issue_Date__c = date.today();
            p.subscription__c = subRecs[counter++].Id;
            p.Copy_Type__c = 'FreeList';
            p.Publication_Code__c = 'BH';
            p.Number_of_Copies__c = 3;
            plb.add(p);
        }
        
        for(counter=0;counter<6;counter++){
            Packing_Label_Batch__c p = new Packing_Label_Batch__c();
            p.Mailing_Agent_Account_Number__c = accQ.accountNumber;
            p.Subscription_Type__c = 'Newspaper';
            p.Record_Type__c = 'Overseas';
            p.Issue_Date__c = date.today();
            p.subscription__c = subRecs[counter++].Id;
            p.Copy_Type__c = 'Subscription';
            p.Publication_Code__c = 'BH';
            p.Number_of_Copies__c = 3;
            plb.add(p);
        }
        
        insert plb;
        
        Packing_Label_Batch__c plbQ = [SELECT Mailing_Agent_Account_Number__c, Subscription_Type__c, Record_Type__c, Issue_Date__c FROM Packing_Label_Batch__c WHERE id=:plb[0].Id];
        system.assertEquals(plbQ.Mailing_Agent_Account_Number__c, accQ.accountNumber);
        system.assertEquals(plbQ.Subscription_Type__c, 'Newspaper');
        system.assertEquals(plbQ.Record_Type__c, 'Overseas');
        system.assertEquals(plbQ.Issue_Date__c, date.today());
        //end test data
    
        test.startTest();
            pageReference pageRef = page.OverseasNewspaperReportHardCopy;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('issueDate', string.valueOf(system.now()));
            ApexPages.currentPage().getParameters().put('id', accQ.accountNumber);
            
            PDFGenerationOverseasNewspaper pdf = new PDFGenerationOverseasNewspaper();
            pdf.generatePDF();
            pdf.PackagingLabel = null;
            pdf.fax = '';
        test.stopTest();
    }
}