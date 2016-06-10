@isTest(seeAllData = TRUE)

public class SP_CourierChargesDebitBatchSchedTest {

   // private void sampleBatcheable01() { // <-- DUMMY
        static testmethod void unitTest1() {  // <-- This is the Original Test Method Signature
    
        Case c = new Case();
        c.Effective_Date__c = date.today();
        c.Vendor_Chargeable_Courier__c = true;
        insert c;
        
        List<Case> casList = [Select Id FROM Case WHERE Effective_Date__c = THIS_MONTH AND Vendor_Chargeable_Courier__c = TRUE Limit 10000];
        
        SP_CourierChargesDebitBatch batch = new SP_CourierChargesDebitBatch();
        /**try{
            if(!casList.isEmpty()){
                ID batchprocessid = Database.executeBatch(batch,casList.size());
                System.assertNotEquals(null, batchprocessid);
            }else{
                ID batchprocessid = Database.executeBatch(batch,null);
                System.assertNotEquals(null, batchprocessid);
            }
        }catch(exception e){}
        **/
      }  
    
    }
