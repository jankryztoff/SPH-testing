/**
     * Class Name: FileUploadController
     * @author: Rica Kirsten Joy Mayo
     * Date: 10/2/2014
     * Requirement/Project Name: SPH
     * @description Controller for FileUploaderAll VF page
     * 
     */

    public class FileUploader 
    {
    public string nameFile{get;set;}
    public Blob contentFile{get;set;}
    /**public integer invalidAccountCount = 0;
    public integer invalidContactCount = 0;
    public integer invalidOrderCount = 0;
    public integer invalidOrderLineCount = 0;
    public integer invalidAddressCount = 0;*/
    String[] filelines = new String[]{};
    List<Order__c> orderToUpload;
    List<Account> accountToUpload;
    List<Contact> contactToUpload;
    List<Order_Line_Item__c> orderlineToUpload;
    List<Address__c> addressToUpload;
    public Document document {get;set;}
    
    
    public void Message() {    
        String result = ApexPages.currentPage().getParameters().get('result');
        
        if(result == 'Failed') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file.'));
        }
        else if(result == 'Successful') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'File uploaded successfully.'));
        }
    }
    
    public PageReference cancel() {

        PageReference pRef = new PageReference('/apex/FileUploaderAll');
        return pRef;

    }


    public Pagereference ReadFile() {
        nameFile=contentFile.toString();
        //nameFile = EncodingUtil.base64Encode(contentFile);
        filelines = nameFile.split('\n');

        orderToUpload = new List<Order__c>();
        accountToUpload = new List<Account>();
        contactToUpload = new List<Contact>();
        orderlineToUpload = new List<Order_Line_Item__c>(); 
        addressToUpload = new List<Address__c>();     
        
        for (Integer i=1;i<filelines.size();i++)
        {
            String[] inputvalues = new String[]{};
            inputvalues = filelines[i].split(',');
            //10-27-2010 added by April Banaag; for creation of account record
            Account acc = new Account();
            String accId  = inputvalues[0];
            List<Account> accResultList = [SELECT Name from Account WHERE Id =: accId LIMIT 1];
            acc.Name = accResultList[0].Name;
            acc.NRIC__c = inputvalues[1];
            acc.Email__c = inputvalues[2];
            acc.Phone = inputvalues[3];
            acc.Mobile__c = inputvalues[4];
            acc.RecordTypeId = ConstantsSLB.getKeyId('Account_' + inputvalues[5]);
            acc.Date_of_Birth__c = Date.valueOf(inputvalues[6]);
            acc.Gender__c = inputvalues[7];
            accountToUpload.add(acc);
            
            //20-27-2010 added by April Banaag to create contact upload
            Contact con = new Contact();
            con.FirstName = inputvalues[8];
            con.LastName = inputvalues[9];
            con.HomePhone__c = inputvalues[10];
            con.Mobile_Number__c = inputvalues[11];
            con.Email__c = inputvalues[12];
            contactToUpload.add(con);
            
            
            //10-27-2010 edited by April Banaag to match requirement
            Order__c ord = new Order__c();            
            //ord.Package_Name__c = inputvalues[13]; //field type is autonumber
            //package code  = inputvalues[14];
            ord.Subscription_Start_Date__c = Date.ValueOf(inputvalues[15]);
            ord.Subscription_End_Date__c = Date.ValueOf(inputvalues[16]);
            ord.Delivery_Charge_Type__c = inputvalues[17];
            ord.Payment_Mode__c = inputvalues[18];
            ord.Vendor_Credit__c = Double.ValueOf(inputvalues[19]);
            ord.Credit_Balance__c = Double.ValueOf(inputvalues[20]);
            ord.Credit_Balance__c = Double.ValueOf(inputvalues[21]);
            //cash  = inputvalues[22];
            ord.Check_Amount__c = Double.ValueOf(inputvalues[23]);
            ord.Check_Dated__c = Date.ValueOf(inputvalues[24]);
            ord.Check_Issuing_Bank__c = inputvalues[25];
            ord.Check_No__c = inputvalues[26];            
            ordertoupload.add(ord);
            
            //11-07-2014 added by Kirsten Mayo: for creation of Order Line Item record
            Order_Line_Item__c oline= new Order_Line_Item__c(); 
            oline.Qty__c = Double.Valueof(inputvalues[27]);
            
            orderlineToUpload.add(oline);

            
            //10-27-2010 added by April Banaag; for creation of address record
            Address__c add = new Address__c();
            add.Postal_Code__c = inputvalues[28];
            //add.Street_Name__c = inputvalues[28];  //Field is not writeable: Address__c.Street_Name__c
            //add.Building_Name__c = inputvalues[29];  //Field is not writeable: Address__c.Street_Name__c
            add.Block_House_Number__c = inputvalues[29];    
            add.Level_Number__c = inputvalues[30];
            add.Unit_Number__c = inputvalues[31];
            addressToUpload.add(add);
            
        }
        
        try{
            insert accountToUpload;
            insert contactToUpload;
            insert orderToUpload;
            insert orderlineToUpload;
            insert addressToUpload;
        }
        catch (Exception e)
        {
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured. Please check the template or try again later');
            ApexPages.addMessage(errormsg);
        }    
        return null;
        
        
    }
    
    
    /**integer invalidAccountCount = 0;
    integer invalidContactCount = 0;
    integer invalidOrderCount = 0;
    integer invalidOrderLineCount = 0;
    integer invalidAddressCount = 0;
    
    
       
         if(accountToUpload.size() > 0) {
            List<Database.SaveResult> saveResults = Database.insert(accountToUpload, false); 
            for(Database.SaveResult sr : saveResults) {
                if(!sr.isSuccess()) {
                    System.debug('InsertResult: ' + sr);
                    
                    invalidAccountCount++;
                }
            } 
        }
   return null;
    }
    
        {
         if(contactToUpload.size() > 0) {
                List<Database.SaveResult> saveResults = Database.insert(contactToUpload, false); 
                for(Database.SaveResult sr : saveResults) {
                    if(!sr.isSuccess()) {
                        System.debug('InsertResult: ' + sr);
                        
                        invalidContactCount++;
                    }
                } 
            }
       return null;
        }
    
    
        {
        if(orderToUpload.size() > 0) {
                List<Database.SaveResult> saveResults = Database.insert(orderToUpload, false); 
                for(Database.SaveResult sr : saveResults) {
                    if(!sr.isSuccess()) {
                        System.debug('InsertResult: ' + sr);
                        
                        invalidOrderCount++;
                    }
                } 
            }
       return null;
        }
    
    
        
        {
        if(orderlineToUpload.size() > 0) {
                List<Database.SaveResult> saveResults = Database.insert(orderlineToUpload, false); 
                for(Database.SaveResult sr : saveResults) {
                    if(!sr.isSuccess()) {
                        System.debug('InsertResult: ' + sr);
                        
                        invalidOrderLineCount++;
                    }
                } 
            }
       return null;
        }
        

        {
        if(addressToUpload.size() > 0) {
                List<Database.SaveResult> saveResults = Database.insert(addressToUpload, false); 
                for(Database.SaveResult sr : saveResults) {
                    if(!sr.isSuccess()) {
                        System.debug('InsertResult: ' + sr);
                        
                        invalidAddressCount++;
                    }
                } 
            }
       return null;
        }*/
        
   
    
    
    public PageReference upload() {
    //Message();
    document = new Document();
    document.AuthorId = UserInfo.getUserId();
    document.FolderId = UserInfo.getUserId();
    
    String result;
    try {
        insert document;
        result = 'Success';
    } 
    catch (DMLException e) {
        result = 'Failed';
    } 
    finally {
        document.body = null; 
        document = new Document();
    }
    
    
    PageReference pRef = new PageReference('/apex/FileUpload?result=' + result);
    pRef.setRedirect(true);
    return pRef;

    }
    
    public List<Order__c> getuploadedOrder()
    {
        if (ordertoupload!= NULL)
            if (ordertoupload.size() > 0)
                return ordertoupload;
            else
                return null;                    
        else
            return null;
    }            
}