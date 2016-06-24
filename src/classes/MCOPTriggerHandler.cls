/**
 * Class Name: <MCOPTriggerHandler>
 * @author: <Raviteja Kumar> 22 June 2016
 * Requirement/Project Name: <SPH>
 * @description : Trigger Handler Class for Mass Change of Package Trigger
 */
 
public class MCOPTriggerHandler {
   
    public MCOP_Batch__c baseMCOP = New MCOP_Batch__c();
    
    public void doBeforeInsert(List<MCOP_Batch__c> lstNewtMCOP)
    {        
        List<MCOP_Batch__c> lstmcop = [Select id,From_Package__c, Account_Type__c, Payment_Mode__c, Sub_Qty_From__c, Sub_Qty_To__c, On_Contract__c, 
                                        Contract_End_Date_From__c, Contract_End_Date_To__c,Effective_Date__c, Start_Time__c, Job_Status__c, To_Package__c  
                                        from MCOP_Batch__c where Job_Status__c = 'Not Started'];              
        if(lstmcop.size() > 0){
            baseMCOP =  lstmcop[0];      
         }        
        else{
            baseMCOP = lstNewtMCOP[0];
        }
        
        Set<Id> setToPackage = New Set<Id>();
        for(MCOP_Batch__c mcop : lstmcop){
            setToPackage.add(mcop.To_Package__c);            
        }
        
        Set<Id> setnewToPackage = New Set<Id>();
        for(MCOP_Batch__c mcop : lstNewtMCOP){            
            if( (baseMCOP.From_Package__c != mcop.From_Package__c) ||
                     (baseMCOP.Account_Type__c != mcop.Account_Type__c) ||
                        (baseMCOP.Payment_Mode__c != mcop.Payment_Mode__c) ||
                            (baseMCOP.Sub_Qty_From__c != mcop.Sub_Qty_From__c) ||
                                (baseMCOP.Sub_Qty_To__c != mcop.Sub_Qty_To__c) ||
                                    (baseMCOP.On_Contract__c != mcop.On_Contract__c) ||
                                        (baseMCOP.Start_Time__c != mcop.Start_Time__c) ||
                                            (baseMCOP.Job_Status__c != mcop.Job_Status__c) || 
                                                 (baseMCOP.Effective_Date__c != mcop.Effective_Date__c) ||
                                                    (baseMCOP.Contract_End_Date_From__c != mcop.Contract_End_Date_From__c) ||
                                                        (baseMCOP.Contract_End_Date_To__c != mcop.Contract_End_Date_To__c)  ){
                mcop.addError(Label.MCOP_INVALID_CONFIG_0);
            }
            else if (!setToPackage.isEmpty() && setToPackage.contains(mcop.To_Package__c)){
                mcop.addError(Label.MCOP_INVALID_CONFIG_0);
            }
            else if (!setnewToPackage.isEmpty() && setnewToPackage.contains(mcop.To_Package__c)){
                mcop.addError(Label.MCOP_INVALID_CONFIG_0);
            }
            else{
                setnewToPackage.add(mcop.To_Package__c);
                mcop.Job_Status__c = 'Not Started';
            }
        }
    }
    public void doBeforeUpdate(List<MCOP_Batch__c> lstNewtMCOP, Map<Id, MCOP_Batch__c> mapNewtMCOP,
                               List<MCOP_Batch__c> lstOldMCOP, Map<Id, MCOP_Batch__c> mapOldMCOP)
    {}
    public void doBeforeDelete(List<MCOP_Batch__c> lstOldMCOP, Map<Id, MCOP_Batch__c> mapOldMCOP)
    {}
    public void doAfterInsert(List<MCOP_Batch__c> lstNewtMCOP, Map<Id, MCOP_Batch__c> mapNewtMCOP)
    {
      for(MCOP_Batch__c MCOP : lstNewtMCOP){
          String Jobid;
          BatchMassCOP batch = new BatchMassCOP();
          Jobid = System.scheduleBatch(batch, 'Mass Change of Package Batch',Integer.valueOf(MCOP.Start_Time__c), 100);
      }
    }
    public void doAfterUpdate(List<MCOP_Batch__c> lstNewtMCOP, Map<Id, MCOP_Batch__c> mapNewtMCOP,
                               List<MCOP_Batch__c> lstOldMCOP, Map<Id, MCOP_Batch__c> mapOldMCOP)
    {}
    public void doAfterDelete(List<MCOP_Batch__c> lstOldMCOP, Map<Id, MCOP_Batch__c> mapOldMCOP)
    {}
}