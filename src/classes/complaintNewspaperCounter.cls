public class complaintNewspaperCounter{
    //UD-3821 START Added by Dags to cater Vendor Subs
    Id cId, addId;
    Integer count = 1;
    Integer count1 = 1;
    Integer count2 = 0;
    List<Case_Subscription__c> cases;
    Integer vcount = 0;
    Integer vcount1 = 0;
    Integer vcount2 = 0;
    Integer ctrDays = Integer.valueOf(ConstantsSLB.getOther('Complaint counter days')); 
    Integer ctrWeeks = Integer.valueOf(ConstantsSLB.getOther('Complaint counter weeks'));
    List<Case_Vendor_Subscription__c> vcases;
    Contact con;
    Contact conAdd;

    public void complaintCounter(List<Case> newCases)
    {
        for(Case newCase : newCases)
        {
            cId = newCase.ContactId;
        }
        if(cId != null){
            conAdd = [SELECT Address__c FROM Contact WHERE Id=:cId];
        }
        if(conAdd != null){
            addId = conAdd.Address__c;
        }
        //UD-3821 END Added by Dags to cater Vendor Subs
        
        /*cases = new List<Case>([SELECT CreatedDate, Goodwill_Amount__c , Check_Goodwill_Amount__c 
                                FROM Case 
                                WHERE ContactId =: cId 
                                AND RecordTypeId =: ConstantsSLB.getKeyId('Complaint_Newspaper')]);*/
                                //START - hotfix for UD-1446 S.Puli
        if(ConstantsSLB.getKeyId('Complaint_Newspaper') != null) { //patrick.c.villarica, Code review, 2/18/15                     
            cases = new List<Case_Subscription__c>([SELECT case__r.CreatedDate, Goodwill_Amount__c,case__r.Status, 
                                case__r.Goodwill_Approval_Status__c, Case__r.Contact.Address__c //UD-3821 START/END Added by Dags to cater Vendor Subs
                                //END - hotfix for UD-1446 S.Puli
                                FROM Case_Subscription__c
                                WHERE (Case__r.ContactId =: cId OR Case__r.Contact.Address__c =:addId)  //UD-3821 START/END Added by Dags to cater Vendor Subs
                                AND Case__r.RecordTypeId =: ConstantsSLB.getKeyId('Complaint_Newspaper')]);                        
        } else { //patrick.c.villarica, Code review, 2/18/15
            cases = new List<Case_Subscription__c>();
        }

        //UD-3821 START Added by Dags to cater Vendor Subs
        if(ConstantsSLB.getKeyId('Complaint_Newspaper') != null) { //patrick.c.villarica, Code review, 2/18/15                     
            vcases = new List<Case_Vendor_Subscription__c>([SELECT case__r.CreatedDate, Goodwill_Amount__c,case__r.Status, 
                                case__r.Goodwill_Approval_Status__c, Case__r.Contact.Address__c 
                                //END - hotfix for UD-1446 S.Puli
                                FROM Case_Vendor_Subscription__c
                                WHERE (Case__r.ContactId =: cId OR Case__r.Contact.Address__c =:addId) 
                                AND Case__r.RecordTypeId =: ConstantsSLB.getKeyId('Complaint_Newspaper')]);                        
        } else { //patrick.c.villarica, Code review, 2/18/15
            vcases = new List<Case_Vendor_Subscription__c>();
        }
        //UD-3821 END Added by Dags to cater Vendor Subs
        
        if(!cases.isEmpty())
        {
            for(Case_Subscription__c c : cases)
            {        

                if(c.case__r.CreatedDate.date() >= (Date.Today() - ctrWeeks))  //UD-3821 START/END Added by Dags to cater Vendor Subs
                {
                    if (c.case__r.CreatedDate.date() >= (Date.Today() - ctrDays))  //UD-3821 START/END Added by Dags to cater Vendor Subs
                    {
                        //system.assertequals(c.Goodwill_Amount__c, 20100.00 );
                        //UD-1446 Start Added additional criteria for number of goodwill
                        if (c.Goodwill_Amount__c > 0 && c.case__r.Status =='Closed' && c.case__r.Goodwill_Approval_Status__c=='Approved'){
                            //system.debug('asjfbag'+c.Goodwill_Amount__c );       
                        //UD-1446 End Added additional criteria for number of goodwill   
                         //UD-3821 START Added by Dags to cater Vendor Subs
                            if(c.Case__r.ContactId == cId)  {
                                count2++;
                            }                    
                        }
                        
                        if(c.Case__r.Contact.Address__c == addId){
                            count++;
                        }   
                    }
                    if(c.Case__r.Contact.Address__c == addId){
                        count1++;
                    }
                     //UD-3821 END Added by Dags to cater Vendor Subs
                }
            }
        }   
       
     //UD-3821 START Added by Dags to cater Vendor Subs  
     if(!vcases.isEmpty())
        {
            for(Case_Vendor_Subscription__c c : vcases)
            {               
                if(c.case__r.CreatedDate.date() >= (Date.Today() - ctrWeeks))
                {
                    if (c.case__r.CreatedDate.date() >= (Date.Today() - ctrDays))
                    {
                        //system.assertequals(c.Goodwill_Amount__c, 20100.00 );
                        //UD-1446 Start Added additional criteria for number of goodwill
                        if (c.Goodwill_Amount__c > 0 && c.case__r.Status =='Closed' && c.case__r.Goodwill_Approval_Status__c=='Approved'){
                            //system.debug('asjfbag'+c.Goodwill_Amount__c );       
                        //UD-1446 End Added additional criteria for number of goodwill             
                            if(c.Case__r.ContactId == cId)  {
                                vcount2++;
                            }   
                        }
                       if(c.Case__r.Contact.Address__c == addId){
                            vcount++;
                        }
                    }
                if(c.Case__r.Contact.Address__c == addId){
                    vcount1++;
                }
                }
            }
        }                                

        
        try{
            if (cId != null) { //patrick.c.villarica, Code review, 2/18/15 
                con = [SELECT Number_of_goodwill__c, Non_Delivery_Complaint_Cases_30_days__c, Non_Delivery_Complaint_Cases_s__c, Address__r.Id, Address__r.Non_Delivery_Complaint_Cases_30_days__c, Address__r.Non_Delivery_Complaint_Cases_16_wks__c FROM Contact WHERE Id =: cId];
            } else { //patrick.c.villarica, Code review, 2/18/15 
                con = new Contact();
            }
            if(con != Null)
            {
                    con.Number_of_goodwill__c = count2;
                    con.Non_Delivery_Complaint_Cases_30_days__c = count;
                    con.Non_Delivery_Complaint_Cases_s__c = count1;
                    update con; 

                    Address__c add = new Address__c();
                    add.Id = con.Address__r.Id;
                    add.Non_Delivery_Complaint_Cases_30_days__c = count + vcount;
                    add.Non_Delivery_Complaint_Cases_16_wks__c = count1 + vcount1;
                    update add;
            }
         //UD-3821 END Added by Dags to cater Vendor Subs            
        } catch(Exception e){
            system.debug('Error occurred: ' + e.getMessage());
        }
    }
    
}