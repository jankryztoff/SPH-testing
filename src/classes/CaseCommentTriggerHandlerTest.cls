/**
* Test Class Name: <CaseCommentTriggerHandlerTest>
* @author: <Maria Jessica Palapal>
* Date: <10/10/2014>
* Requirement/Project Name: <SPH>
* @description<>
*/ 
 
@isTest (seeAllData = TRUE)
public class CaseCommentTriggerHandlerTest{   

    public static List<Account> createAccount(Integer numAccts, String recType) {
    List<Account> accountList = new List<Account>();
    List<RecordType> rt = [SELECT id, Name FROM RecordType WHERE SobjectType='Account' AND Name=: recType LIMIT 1];

    for(Integer i=0;i<numAccts;i++){
    Account accountRecord = new Account(Name='TestAccount' + i, Phone='00000' + i, RecordTypeId = rt[0].id);

    if(recType == 'Direct Corporate'){
    accountRecord.AccountNumber='ACC0000' + i;
    accountRecord.Unique_Entity_Number__c='UEN0000' + i;
    accountRecord.Contact_Person__c='contact' + i;
    }
    else if(recType == 'Direct SPH Inter-Division'){
    accountRecord.Contact_Person__c='contact' + i; 
    //START: D-1091 Modified by FrancisBenzon corrected assignment String to String
    accountRecord.Staff_ID__c='00' + i; 
    //END: D-1091 Modified by FrancisBenzon corrected assignment String to String  
    }
    accountList.add(accountRecord);
    }
    system.debug('debug:'+accountList);
    return accountList;
    }

    static User cso;
    static Account acc;
        
    
    static testMethod void test() {        
        prepareTestUsersAccount(); 
            Case cs = TestDataFactory.createCase(1,'Complaint - Digital')[0];
            //System.assert(cs.id!=null);
            cs.ownerid = cso.id;
            insert cs;
                System.runAs(cso) {            
                    CaseComment cc = new CaseComment(CommentBody = 'Test Comment 1',IsPublished=True,ParentID=cs.id ); 
                    //CaseComment cc2 = new CaseComment(CommentBody = 'Test Comment 2',IsPublished=True,ParentID=cs.id );
                        Test.startTest();                            
                        Database.insert(cc);
                        //insert cc;
                        //update cc;
                        Database.delete(cc);                                               
                        Test.stopTest();  
                }               
    }  
    
    static testMethod void test2(){
        prepareTestUsersAccount();
            Case cs = TestDataFactory.createCase(1, 'Complaint - Digital')[0];
            cs.ownerid = cso.id;
            insert cs;
        System.runAs(cso){
            CaseComment cc = new CaseComment(CommentBody = 'Test Comment 2', IsPublished=True,ParentID=cs.id);
            CaseComment cc2 = new CaseComment(CommentBody = 'Test Comment 3', IsPublished=True,ParentID=cs.id); 
                    insert new List<CaseComment>{cc, cc2};
            
                Test.startTest();   
                update cc2;
                Test.stopTest(); 
                
        }
        
     CaseCommentTriggerHandler ccth = new CaseCommentTriggerHandler();
     ccth.runBeforeInsertTrigger();
     ccth.runBeforeUpdateTrigger();
     ccth.runBeforeDeleteTrigger();
     ccth.runAfterInsertTrigger();
     ccth.runAfterUpdateTrigger();
     ccth.runAfterDeleteTrigger();
        
    }
    
    static void prepareTestUsersAccount() {        
        cso = TestDataFactory.prepareTestusers('CSO'); 
        insert cso;   
    }   
}