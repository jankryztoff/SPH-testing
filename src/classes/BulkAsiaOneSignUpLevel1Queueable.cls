// max of 2500 asia1 ids

public class BulkAsiaOneSignUpLevel1Queueable implements Queueable {

    set<id> asia1IdSet = new set<id>();
    
    public BulkAsiaOneSignUpLevel1Queueable (set<id> asia1IdSetParam) {
        this.asia1IdSet = asia1IdSetParam;
    }
    

    public void execute(QueueableContext context) {
        
        integer MAX_ASIA1_LEVEL_2 = 50;
        integer batchCounter = 1;
        integer counter = 1;
        integer totalAsia1 = asia1IdSet.size();
        set<id> asia1IdSetLevel2 = new set<id>();
        
        for (id asia1Id : asia1IdSet) {
            
            asia1IdSetLevel2.add(asia1Id);
            
            if (batchCounter == MAX_ASIA1_LEVEL_2 || counter == totalAsia1) {
                
                BulkAsiaOneSignUpLevel2Batchable batch = new BulkAsiaOneSignUpLevel2Batchable(asia1IdSetLevel2);
                Database.executeBatch(batch);
                asia1IdSetLevel2 = new set<id>();
                batchCounter = 0;
            }
            
            batchCounter++;
            counter++;
            
        }
    }
}