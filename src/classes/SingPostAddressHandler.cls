/**
 * Class Name: <SingPostAddressHandler>
 * @author: <VPernicia>
 * Date: <1/28/2016>
 * Requirement/Project Name: <SPH>
**/

public class SingPostAddressHandler{
    
    list<Singpost_Address__c> listSingPostAddress = new list<Singpost_Address__c>();
    
    public void doBeforeInsert(List<Singpost_Address__c> lstNewSingpost)
    {}
    
    //After Insert logic - Call separate method for detail processing - Leave Blank for not in use
    public void doAfterInsert(List<Singpost_Address__c> lstNewSingpost, Map<Id, Singpost_Address__c> mapNewSingpost)
    {}
    
    //Before Update logic - Call separate method for detail processing - Leave Blank for not in use
    public void doBeforeUpdate(List<Singpost_Address__c> lstNewSingpost, Map<Id, Singpost_Address__c> mapNewSingpost,
                               List<Singpost_Address__c> lstOldSingpost, Map<Id, Singpost_Address__c> mapOldSingpost)
    {
       map<string, string> mapPostalZone = new map<string, string>();
       
       for (Postal_Zone__c pz: [select Postal_Sector__c, id from Postal_Zone__c]) {

           mapPostalZone.put(pz.Postal_Sector__c, pz.id);
       }
       
       for (Singpost_Address__c SingAdd: lstNewSingpost) {
       
           SingAdd.Postal_Sector_Zone__c = (id) mapPostalZone.get(string.valueof(SingAdd.name.left(2)));
           listSingPostAddress.add(SingAdd);
       }
      
    }

    //Issue Note: Wenjun - A lot of operations does not check Old Value. So the action may be triggered unnecessarily
    public void doAfterUpdate(List<Singpost_Address__c> lstNewSingpost, Map<Id, Singpost_Address__c> mapNewSingpost,
                               List<Singpost_Address__c> lstOldSingpost, Map<Id, Singpost_Address__c> mapOldSingpost)
    {}
    
    //Before Delete logic - Call separate method for detail processing - Leave Blank for not in use
    public void doBeforeDelete(List<Singpost_Address__c> lstOldSingpost, Map<Id, Singpost_Address__c> mapOldSingpost)
    {}
    
    //After Delete logic - Call separate method for detail processing - Leave Blank for not in use
    public void doAfterDelete(List<Singpost_Address__c> lstOldSingpost, Map<Id, Singpost_Address__c> mapOldSingpost)
    {}
    
    private void andFinally() 
    {}
}