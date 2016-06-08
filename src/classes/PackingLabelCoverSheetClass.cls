public class PackingLabelCoverSheetClass{
    public list<wrapperclass> wrplist {get;set;}
    public Date DtIssue {get;set;}
    public String DtIssuedis {get;set;}
    public String toname {get;set;}
    public String toaddress {get;set;}
    public String Dtday {get;set;}
    public PackingLabelCoverSheetClass()
    {
       packinglabebatch__c mc = packinglabebatch__c.getValues('Packing1');
       toname =  String.valueOf(mc.get('ToName__c'));
       toaddress =  String.valueOf(mc.get('ToAddress__c'));
       Integer i = Integer.valueOf(mc.get('DaysfromCurrentdate__c'));
       //DtIssue = [select Publication_Issue_Date__c from CMIS_POP_Packing_label_Batch__c order by Publication_Issue_Date__c desc][0].Publication_Issue_Date__c;
       DtIssue = Date.valueof(ApexPages.currentPage().getParameters().get('d'));
       DateTime dt1=DateTime.newInstance(DtIssue.year(), DtIssue.month(), DtIssue.day());
     Dtday = String.valueof(dt1.format('EEEE'));
     system.debug('tesssssss' + Dtday);
       DtIssuedis  = 'Issue Date: ' + String.ValueoF(DtIssue);
       generategrid();
    }
    public void generategrid()
    {
    
      wrapperclass c;
      wrplist = new list <wrapperclass>();
      Date st = Date.newInstance(Integer.valueOf(DtIssue.Year()), Integer.valueOf(DtIssue.month()), Integer.valueOf(DtIssue.day()));
      
        
        
       //system.debug('dddd111' +st);
       AggregateResult[] groupedResults
                  = [select Publication_Code__c, Sum(Total_Overseas_Freelist_Copies__c) freelistcopies, 
                     Sum(Total_Overseas_Subscription_Copies__c) overseascopies from CMIS_POP_Packing_label_Batch__c 
                     Where Publication_Issue_Date__c = :DtIssue group by Publication_Code__c];
      system.debug('dddd111' +groupedResults);
    if(groupedResults.size() > 0)
    {
        
        for(Integer i = 0; i <= 2; i ++)
        {
            c = new wrapperclass();
        
          for(AggregateResult ar : groupedResults)
          {         
           
                
                  if(i == 0)
                    {
                             c.type = 'Subscription';
                            if(String.Valueof(ar.get('Publication_Code__c')) == 'ST')
                                c.st  = Integer.ValueOf(ar.get('overseascopies'));
                            else  if(String.Valueof(ar.get('Publication_Code__c')) == 'BT')
                                c.bt  = Integer.ValueOf(ar.get('overseascopies'));
                            else  if(String.Valueof(ar.get('Publication_Code__c')) == 'BH')
                                c.bh  = Integer.ValueOf(ar.get('overseascopies'));
                            else  if(String.Valueof(ar.get('Publication_Code__c')) == 'NP')
                                c.np  = Integer.ValueOf(ar.get('overseascopies'));    
                            else  if(String.Valueof(ar.get('Publication_Code__c')) == 'ZB')
                                c.zb  = Integer.ValueOf(ar.get('overseascopies'));
                            else  if(String.Valueof(ar.get('Publication_Code__c')) == 'TM')
                               c.tm  = Integer.ValueOf(ar.get('overseascopies'));    
                            else  if(String.Valueof(ar.get('Publication_Code__c')) == 'WB')
                                c.wb  = Integer.ValueOf(ar.get('overseascopies'));
                           else  if(String.Valueof(ar.get('Publication_Code__c')) == 'SM')
                                c.sm  = Integer.ValueOf(ar.get('overseascopies'));
                           else  if(String.Valueof(ar.get('Publication_Code__c')) == 'MY')
                               c.my  = Integer.ValueOf(ar.get('overseascopies'));    
                           
              }
        
                  else if (i == 1)
                  {
                          c.type = 'Freelist';
                            if(String.Valueof(ar.get('Publication_Code__c')) == 'ST')
                                c.st  = Integer.ValueOf(ar.get('freelistcopies'));
                            else  if(String.Valueof(ar.get('Publication_Code__c')) == 'BT')
                                c.bt  = Integer.ValueOf(ar.get('freelistcopies'));
                            else  if(String.Valueof(ar.get('Publication_Code__c')) == 'BH')
                                c.bh  = Integer.ValueOf(ar.get('freelistcopies'));
                            else  if(String.Valueof(ar.get('Publication_Code__c')) == 'NP')
                                c.np  = Integer.ValueOf(ar.get('freelistcopies'));    
                            else  if(String.Valueof(ar.get('Publication_Code__c')) == 'ZB')
                                c.zb  = Integer.ValueOf(ar.get('freelistcopies'));
                            else  if(String.Valueof(ar.get('Publication_Code__c')) == 'TM')
                               c.tm  = Integer.ValueOf(ar.get('freelistcopies'));    
                            else  if(String.Valueof(ar.get('Publication_Code__c')) == 'WB')
                                c.wb  = Integer.ValueOf(ar.get('freelistcopies'));
                           else  if(String.Valueof(ar.get('Publication_Code__c')) == 'SM')
                                c.sm  = Integer.ValueOf(ar.get('freelistcopies'));
                           else  if(String.Valueof(ar.get('Publication_Code__c')) == 'MY')
                                c.my  = Integer.ValueOf(ar.get('freelistcopies'));       
                            
                   
          }                
                
                   else if (i == 2)
                    {
                   
                            c.type = 'Total';
                            if(String.Valueof(ar.get('Publication_Code__c')) == 'ST')
                                c.st  = Integer.ValueOf(ar.get('overseascopies')) + Integer.ValueOf(ar.get('freelistcopies'));
                            else  if(String.Valueof(ar.get('Publication_Code__c')) == 'BT')
                                c.bt  = Integer.ValueOf(ar.get('overseascopies')) + Integer.ValueOf(ar.get('freelistcopies'));
                            else  if(String.Valueof(ar.get('Publication_Code__c')) == 'BH')
                                c.bh  = Integer.ValueOf(ar.get('overseascopies')) + Integer.ValueOf(ar.get('freelistcopies'));
                            else  if(String.Valueof(ar.get('Publication_Code__c')) == 'NP')
                                c.np  = Integer.ValueOf(ar.get('overseascopies')) + Integer.ValueOf(ar.get('freelistcopies'));
                            else  if(String.Valueof(ar.get('Publication_Code__c')) == 'ZB')
                                c.zb  = Integer.ValueOf(ar.get('overseascopies')) + Integer.ValueOf(ar.get('freelistcopies'));
                            else  if(String.Valueof(ar.get('Publication_Code__c')) == 'TM')
                               c.tm  = Integer.ValueOf(ar.get('overseascopies')) + Integer.ValueOf(ar.get('freelistcopies'));    
                            else  if(String.Valueof(ar.get('Publication_Code__c')) == 'WB')
                                c.wb  = Integer.ValueOf(ar.get('overseascopies')) + Integer.ValueOf(ar.get('freelistcopies'));
                           else  if(String.Valueof(ar.get('Publication_Code__c')) == 'SM')
                                c.sm  = Integer.ValueOf(ar.get('overseascopies')) + Integer.ValueOf(ar.get('freelistcopies'));
                           else  if(String.Valueof(ar.get('Publication_Code__c')) == 'MY')
                                c.my  = Integer.ValueOf(ar.get('overseascopies')) + Integer.ValueOf(ar.get('freelistcopies'));  
                    }  
               
            }
            
            wrplist.add(c);
            
        }
    
    }
 
    }
    
    
    public  class wrapperclass
    {
        public string type {get;set;}
        public integer st {get;set;}
        public integer bt {get;set;}
        public integer bh {get;set;}
        public integer np {get;set;}
        public integer zb {get;set;}
        public integer tm {get;set;}
        public integer wb {get;set;}
        public integer sm {get;set;}
        public integer my {get;set;}
        
        
    }
}