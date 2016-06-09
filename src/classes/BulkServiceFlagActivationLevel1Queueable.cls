public class BulkServiceFlagActivationLevel1Queueable implements Queueable {

    list<ServiceFlagActivationParamWrapper> paramList = new list<ServiceFlagActivationParamWrapper>();
    
    public BulkServiceFlagActivationLevel1Queueable (list<ServiceFlagActivationParamWrapper> serviceFlagParamWrapperListParam) {
        this.paramList = serviceFlagParamWrapperListParam;
    }
    

    public void execute(QueueableContext context) {
        
        integer MAX_ASIA1_LEVEL_2 = 50;
        integer batchCounter = 1;
        integer counter = 1;
        integer totalServiceFlagWrapper = paramList.size();
        list<ServiceFlagActivationParamWrapper> paramListLevel2 = new list<ServiceFlagActivationParamWrapper>();
        
        for (ServiceFlagActivationParamWrapper param : paramList) {
            
            paramListLevel2.add(param);
            
            if (batchCounter == MAX_ASIA1_LEVEL_2 || counter == totalServiceFlagWrapper) {
                
                BulkServiceFlagActivationLevel2Batchable batch = new BulkServiceFlagActivationLevel2Batchable(paramListLevel2);
                Database.executeBatch(batch);
                paramListLevel2 = new list<ServiceFlagActivationParamWrapper>();
                batchCounter = 0;
            }
            
            batchCounter++;
            counter++;           
        }
    }
}