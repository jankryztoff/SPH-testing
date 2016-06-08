/**
 * Class Name: <CreditNoteTriggerHandler> 
 * @author: <Kevin Herrera Evasco>
 * Date: <11/13/2014>
 * Requirement/Project Name: <SPH>
 * @description <Creates a new letter print request record for each credit note record>
 * History: []S.Puli: Rewrite the whole class to support new Credit Note object due to Change Request. UD-3253
 */
public class CreditNoteTriggerHandler{
    
    public Other__c creditNoteNumber = new Other__c();
    public Other__c minCreditNoteNumber = new Other__c();
    public Other__c maxCreditNoteNumber = new Other__c();
    Integer latestCreditNote = 0;
    Logger logger = new Logger(CreditNoteTriggerHandler.class.getName());
    
    //Before Insert logic - Call seperate method for detail processing - Leave Blank for not in use
    public void doBeforeInsert(List<Credit_Note__c> lstNewCreditNotes) {}
    
    //After Insert logic - Call seperate method for detail processing - Leave Blank for not in use
    public void doAfterInsert(List<Credit_Note__c> lstNewCreditNotes, Map<Id, Credit_Note__c> mapNewCreditNotes)
    {
        generateCreditNoteNumber(mapNewCreditNotes);
    }
    
    //Before Update logic - Call seperate method for detail processing - Leave Blank for not in use
    public void doBeforeUpdate(List<Credit_Note__c> lstNewCreditNotes, Map<Id, Credit_Note__c> mapNewCreditNotes,
                               List<Credit_Note__c> lstOldCreditNotes, Map<Id, Credit_Note__c> mapOldCreditNotes)
    {}

    //After Update logic - Call seperate method for detail processing - Leave Blank for not in use
    public void doAfterUpdate(List<Credit_Note__c> lstNewCreditNotes, Map<Id, Credit_Note__c> mapNewCreditNotes,
                               List<Credit_Note__c> lstOldCreditNotes, Map<Id, Credit_Note__c> mapOldCreditNotes)
    {}
    
    //Before Delete logic - Call seperate method for detail processing - Leave Blank for not in use
    public void doBeforeDelete(List<Credit_Note__c> lstOldCreditNotes, Map<Id, Credit_Note__c> mapOldCreditNotes)
    {}
    
    //After Delete logic - Call seperate method for detail processing - Leave Blank for not in use
    public void doAfterDelete(List<Credit_Note__c> lstOldCreditNotes, Map<Id, Credit_Note__c> mapOldCreditNotes)
    {}
    
    //populate Credit Note Number based on the custom setting record
    public void generateCreditNoteNumber(Map<Id, Credit_Note__c> mapNewCreditNotes){
        try{
            List<Credit_Note__c> initialCreditNotes = new List<Credit_Note__c>();
            List<Credit_Note__c> creditNotesToUpdate = new List<Credit_Note__c>();
            
            //Set<Id> cnIds = new Set<Id>();
            creditNoteNumber = Other__c.getInstance('CN_NUMBER_NEXT');
            minCreditNoteNumber = Other__c.getInstance('CN_NUMBER_MIN');
            maxCreditNoteNumber = Other__c.getInstance('CN_NUMBER_MAX');
            latestCreditNote = Integer.valueOf(creditNoteNumber.Value__c);
            
            if(!mapNewCreditNotes.isEmpty()){
                initialCreditNotes = [SELECT Id,Credit_Note_Number__c,ARMS_Number__c, Name
                                        FROM Credit_Note__c 
                                        WHERE Id IN :mapNewCreditNotes.keySet()];
            }
                
            if(!initialCreditNotes.isEmpty()){
                for(Credit_Note__c cnRec : initialCreditNotes){
                    if(cnRec.Credit_Note_Number__c == null || cnRec.Credit_Note_Number__c == ''){
                        if(cnRec.ARMS_Number__c <> null){
                            cnRec.Credit_Note_Number__c =  '00' + String.valueOf(latestCreditNote);
                            latestCreditNote++;
                            if(latestCreditNote > Integer.valueOf(maxCreditNoteNumber.Value__c)){
                                latestCreditNote = Integer.valueOf(minCreditNoteNumber.Value__c);
                            }
                        }else{
                            cnRec.Credit_Note_Number__c = cnRec.Name;
                        }
                        creditNotesToUpdate.add(cnRec);
                    }
                }
                creditNoteNumber.Value__c = String.valueOf(latestCreditNote);
                update creditNoteNumber;
                update creditNotesToUpdate;
            }
        } catch (exception e) {
            logger.log(e);
        }    
        logger.save();
    }
}