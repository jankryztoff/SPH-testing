/* April Veloso
*  07/16/2015
*/

@isTest (Seealldata = TRUE)
public class Asia1BatchUpdateTest2 {
    
    static testmethod void unitTest1(){
    
            List<Asia1__c> asiaOne = TestDataFactory.createAsiaOne(1);
            asiaOne[0].Display_Name__c = 'Unknown';
            asiaOne[0].Password__c = 'Unknown';
            asiaOne[0].User_ID_LDAP_ID__c = 'User Ldap Id';
            
            insert asiaOne;
            
           /* Database.BatchableContext BC;
            List<sobject> sObjectList= new List<sobject>();
            
            Asia1__c obj = [SELECT Display_Name__c, Password__c FROM Asia1__c WHERE Id = :asiaOne[0].Id];
            System.assertEquals('', obj.Display_Name__c + ', '+ obj.Password__c);
        
            String querystr = 'SELECT Id, User_ID_LDAP_ID__c, Display_Name__c FROM Asia1__c WHERE Display_Name__c =\'Unknown\' AND Password__c = \'Unknown\'';
            
            database.query(querystr);
            List<Asia1__c> me = database.query(querystr);
            System.assertEquals(-1, me.size());*/
            
            
            Set<String> idSet = new Set<String>();
            Asia1BatchUpdate batch = new Asia1BatchUpdate(idSet);
            ID batchprocessid = Database.executeBatch(batch,2);
            //batch.execute(BC, sObjectList); 
             
            System.assertNotEquals(null, batchprocessid);
        }//end of unitTest1
    
    static testmethod void testCatch(){
    
       /* List<Asia1__c> asiaOne = TestDataFactory.createAsiaOne(1);
        asiaOne[0].Display_Name__c = 'Unknown';
        asiaOne[0].Password__c = 'Unknown';
        asiaOne[0].User_ID_LDAP_ID__c = 'User Ldap Id';
        
        insert asiaOne;
        
        Database.BatchableContext BC;
        List<sobject> sObjectList= new List<sobject>();
        
        Asia1__c obj = [SELECT Display_Name__c, Password__c FROM Asia1__c WHERE Id = :asiaOne[0].Id];
        System.assertEquals('', obj.Display_Name__c + ', '+ obj.Password__c);

        String querystr = 'SELECT Id, User_ID_LDAP_ID__c, Display_Name__c FROM Asia1__c WHERE Display_Name__c =\'Unknown\' AND Password__c = \'Unknown\'';
        
        database.query(querystr);
        List<Asia1__c> me = database.query(querystr);
        System.assertEquals(-1, me.size());*/
        
        
        Set<String> idSet = new Set<String>();
        Asia1BatchUpdate batch = new Asia1BatchUpdate(idSet);
       // ID batchprocessid = Database.executeBatch(batch,2);
        //batch.execute(BC, sObjectList); 
         
       // System.assertNotEquals(null, batchprocessid);
    }//end of testCatch
}