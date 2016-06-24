@isTest                   
public class BT_CO_CMIS_POP_NumberOfVendorInsertsTest{

static testMethod void numberOfVendorInsertsTest(){
    
    Integer i;
    List<BT_CO_CMIS_POP_NumberOfVendorInserts__c> vList = new List<BT_CO_CMIS_POP_NumberOfVendorInserts__c>();
    List<BT_CO_CMIS_POP_NumberOfVendorInserts__c> vendorList = new List<BT_CO_CMIS_POP_NumberOfVendorInserts__c>();
    List<BT_CO_CMIS_POP_NumberOfVendorInserts__c> vendorListUpdate = new List<BT_CO_CMIS_POP_NumberOfVendorInserts__c>();
    List<Vendor_Inserts__c> vendorListInsert = new List<Vendor_Inserts__c>();
    
    
    Publication__c p = new Publication__c();
    p.Name = 'Test';
    p.Publication_Code__c = 'D462';
    p.Published_Days__c = 'YYYYYYN';
    p.Publication_Type__c = 'M';
    
    insert p;
    
    Publication__c pid = [select id from Publication__c where Publication_Code__c = :'D462'];
    
    for(i=3; i<5; i++){
        Vendor_Inserts__c v = new Vendor_Inserts__c();
        v.Publication_Code__c = 'D462';
        v.Publication_Issue_Date__c = Date.parse('05/05/2015');
        v.Publication__c = pid.id;
        v.Vendor_Number__c = '2'+i;
        v.Number_of_Inserts__c = 57;
        v.Vendor_Group__c = 'M';
        vendorListInsert.add(v);
    }
    
    insert vendorListInsert;
    
   
    
    for(i=0; i<2; i++){
        BT_CO_CMIS_POP_NumberOfVendorInserts__c nvi = new BT_CO_CMIS_POP_NumberOfVendorInserts__c();
        nvi.publicationCode__c = 'D462';
        nvi.publicationIssueDate__c = '02.07.2015';
        nvi.numberOfInserts__c = '57';
        nvi.Batch_Job_Id__c = 'F564729Test';
        nvi.Validation_Status__c = 'Passed';
        nvi.vendorGroup__c = 'M';
        nvi.vendorNumber__c = '23';
        vendorList.add(nvi);
    }
    insert vendorList;
   
    for(i=0; i<2; i++){
        BT_CO_CMIS_POP_NumberOfVendorInserts__c nvi = new BT_CO_CMIS_POP_NumberOfVendorInserts__c();
        nvi.publicationCode__c = '';
        nvi.publicationIssueDate__c = '02072015';
        nvi.vendorGroup__c = 'D';
        nvi.vendorNumber__c = '';
        vList.add(nvi);
    }
    try{
    insert vList;
    }catch(exception e){}
    
    
        BT_CO_CMIS_POP_NumberOfVendorInserts__c nvirecord = new BT_CO_CMIS_POP_NumberOfVendorInserts__c();
        nvirecord.publicationCode__c = 'D807';
        nvirecord.publicationIssueDate__c = '';
        nvirecord.vendorGroup__c = '';
        nvirecord.vendorNumber__c = '';
    
        insert nvirecord;
        
        BT_CO_CMIS_POP_NumberOfVendorInserts__c nvirecord1 = new BT_CO_CMIS_POP_NumberOfVendorInserts__c();
        nvirecord1.publicationCode__c = '';
        nvirecord1.publicationIssueDate__c = '';
        nvirecord1.vendorGroup__c = '';
        nvirecord1.vendorNumber__c = '';
    
        insert nvirecord1;
}
}