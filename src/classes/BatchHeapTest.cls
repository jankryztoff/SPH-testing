global class BatchHeapTest implements Database.Batchable<sObject>, Database.Stateful{

   global Map<String, Vendor_POP_Batch__c> mapPOP;

   global Database.QueryLocator start(Database.BatchableContext BC){
      mapPOP = new Map<String, Vendor_POP_Batch__c>();
      return Database.getQueryLocator('SELECT ID FROM Singpost_Address__c LIMIT 6000');
   }

   global void execute(Database.BatchableContext BC, List<Singpost_Address__c> scope){
        Long timeCount = DateTime.now().getTime();
        String Strkey = '';
        for(Integer count = 0; count < 200; count ++)
        {
            Strkey = '' + timeCount + count;
            Vendor_POP_Batch__c popRec = new Vendor_POP_Batch__c();
            popRec.Publication_Code__c = 'ST'+ count; 
            popRec.Publication_Issue_Date__c= Date.today(); 
            popRec.Total_Direct_Subscriptions__c = count + 1; 
            popRec.Vendor_Number__c= 'V00' + count; 
            mapPOP.put(Strkey,popRec);
            System.debug(mapPOP); 
        }
        System.debug('===>1: ' + Limits.getHeapSize());
        System.debug('===>1: ' + Limits.getLimitHeapSize());
    }

   global void finish(Database.BatchableContext BC)
   {
       System.debug('============>' + mapPOP.keySet().size());
   }
   }