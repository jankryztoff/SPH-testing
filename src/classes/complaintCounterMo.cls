public class complaintCounterMo{
    Id cId;
    Integer count = 0;
    Integer count1 = 0;
    List<Case> cases;
    Contact con;
    
    public void complaintCounter(List<Case> newCases)
    {
        for(Case newCase : newCases)
        {
            cId = newCase.ContactId;
        }
        
        cases = new List<Case>([SELECT CreatedDate 
                                FROM Case 
                                WHERE ContactId =: cId 
                                AND RecordTypeId =: ConstantsSLB.getKeyId('Complaint_Newspaper')]);
       
                                
        if(!cases.isEmpty())
        {
            for(Case c : cases)
            {
                if(c.CreatedDate.date() >= (Date.Today() - 112))
                {
                    if (c.CreatedDate.date() >= (Date.Today() - 30))
                    {
                    count++;
                    }
                count1++;
                }

            }
        }
        
        con = [SELECT Non_Delivery_Complaint_Cases_30_days__c, Non_Delivery_Complaint_Cases_s__c FROM Contact WHERE Id =: cId];
        if(con != Null)
        {
            con.Non_Delivery_Complaint_Cases_30_days__c = count;
            con.Non_Delivery_Complaint_Cases_s__c = count1;
        }
        update con;
    }
}