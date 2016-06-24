/**
 * Class Name: SP_VSSDebitForComplaint 
 * @author: Raviteja Kumar
 * Date: 11-Mar-2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description Batch Class that creates Vendor Credit / Debit data for VSS
 *  History : D-3653 19Nov15 AddedBy FrancisBenzon : logging mechanism for batch status
 * START-End UD-3393_UD-3702_D-4287 18-Jan-2016 Added by Raviteja - Restructure the class
 * History: D-4421-UD-3393 and UD-3702 Raviteja 11-Feb-2016 - Restructure the class
 */
global class SP_VSSDebitForComplaint implements Database.Batchable<sObject>, Database.Stateful
{
   /* @description Called at the beginning of the apex job to collect the objects
    * to be passed to the execute method
    * @param bcTemp - predefined parameter 
    * @return list of objects from Case Object
    */     
    
     global Datetime startDate;
     global Datetime endDate;
     global Date postingDate;
  
     global Boolean ismanualrun = False;   
     Boolean isApexJobSuccessful = true;  
        
    //Applying New Logic for ManualRun  - Default Constructor 
    public SP_VSSDebitForComplaint()
    {            
        Date dToday = Date.today();
        Date firstDate = dToday.toStartOfMonth();
        Date lastDate = firstDate.addDays(date.daysInMonth(dToday.year() , dToday.month())  - 1);
        startDate = Datetime.newInstance(firstDate.year(), firstDate.month(), firstDate.day(), 0, 0, 0); 
        endDate   = Datetime.newInstance(lastDate.year(), lastDate.month(), lastDate.day(), 23, 59, 59);
        postingDate = lastDate;
        
    }
   
    public SP_VSSDebitForComplaint(Integer month, Integer year)
    {    
        Date manualDate = Date.newInstance(year, month, 01);
        Date firstDate = manualDate.toStartOfMonth();
        Date lastDate = firstDate.addDays(date.daysInMonth(manualDate.year() , manualDate.month())  - 1);
        startDate = Datetime.newInstance(firstDate.year(), firstDate.month(), firstDate.day(), 0, 0, 0); 
        endDate   = Datetime.newInstance(lastDate.year(), lastDate.month(), lastDate.day(), 23, 59, 59);
        postingDate = lastDate;
        ismanualrun = True;
    }   
    
    global database.QueryLocator start(database.BatchableContext bcTemp){        
                                                
         return database.getQueryLocator([SELECT Courier_Fee__c, Paper_Fee__c, Subscription_Name__r.Vendor_1__c,CaseNumber,
                                                Subscription_Name__r.Vendor_1__r.AccountNumber,
                                                Subscription_Name__r.Vendor_1__r.Vendor_Group__c,Vendor_Chargeable_Paper__c,Vendor_Chargeable_Courier__c
                                                FROM Case      
                                                WHERE ClosedDate >= :startDate AND ClosedDate <= :endDate
                                                AND Status = 'Closed'
                                                AND Recordtype.DeveloperName = 'Complaint_Newspaper' 
                                                AND (Vendor_Chargeable_Paper__c = TRUE OR  Vendor_Chargeable_Courier__c = TRUE)
                                                ]);                                        
    }
    
    /* @description Executes the business logic and creates Vendor Monthly Data object
     * 
     * @param bcTemp - predefined parameter 
     * @param allScopes - a list of sObjects from the initial database query
     * @return void
     */
    global void execute(database.batchableContext bcTemp, list<Case> allScopes){  
        //START D-3653 19Nov15 AddedBy FrancisBenzon : logging mechanism for batch status
        //START PD-0236 11May15 AddedBy VinceCanlas : Added a condition for logger call
        Logger logger;
        if(!test.IsRunningTest()){
            logger = new Logger(SP_VSSDebitForComplaint.class.getName(), 'SP003', bcTemp.getJobID());
        }
        //END PD-0236 11May15 AddedBy VinceCanlas : Added a condition for logger call
        
        Savepoint sp = Database.setSavepoint();        
        
        try 
        {
            //START/End D-4400 04-Feb-2016 Added by Raviteja - added Subscription__r.Recipient_Contact__r.Address__c in SOQL
            List<Case_Subscription__c> casesublist = [SELECT Complaint_From__c,Complaint_To__c,Complaint_Copies__c,Case__r.Courier_Fee__c, Case__r.Paper_Fee__c, 
                                                                Case__r.Subscription_Name__r.Vendor_1__c, Subscription__c, 
                                                                Case__r.Subscription_Name__r.Vendor_1__r.AccountNumber,Case__r.Subscription_Name__r.Vendor_1__r.Vendor_Group__c,
                                                                Case__r.ClosedDate,Case__r.Status, Case__r.Recordtype.DeveloperName, Case__r.CaseNumber, Subscription__r.Recipient_Contact__r.Address__c, 
                                                                Case__r.Vendor_Chargeable_Paper__c, Case__r.Vendor_Chargeable_Courier__c, Vendor_Code__c, Address__c,  
                                                                Subscription__r.Recipient_Contact__c,Subscription__r.Vendor_1__r.Vendor_Code__c,Subscription__r.Vendor_1__r.Vendor_Group__c                                           
                                                    FROM Case_Subscription__c
                                                    WHERE Case__c In :allScopes
                                                    ];
        
            Map<String,Id> recipientContactmap  = New Map<String,Id>();
            Map<String,String> vendorNumbermap = New Map<String,String>();
            Map<String,String> vendorGroupmap = New Map<String,String>();           
            Map<String,Date> caseFromdatemap  = New Map<String,Date>();
            Map<String,Date> caseTodatemap  = New Map<String,Date>();
            Map<String,Decimal> caseCopiesmap  = New Map<String,Decimal>();
            Map<String,Id> caseAddressmap  = New Map<String,Id>();
            Map<Id,Id> SubOldaddressmap  = New Map<Id,Id>();
            Map<Id,String> SubOldvendormap  = New Map<Id,String>();
            
            Set<Id> setSubIds = New Set<Id>();
           
            // Calculating End of the Month date
            Date firstDayOfMonth = System.today().toStartOfMonth();           
            Date lastDayOfMonth = postingDate;           
            
            for(Case_Subscription__c casesub: casesublist){
                if(casesub.Subscription__c != Null) setSubIds.add(casesub.Subscription__c);
            }
            
            //Fetch COA Old Address
           for(Case_Subscription__c CaseSubs :  [SELECT ID, Name, Case__c, Subscription__c, Vendor_Code__c, Address__c 
                                                       FROM Case_Subscription__c WHERE Subscription__c in :setSubIds AND Case__r.Status = :GlobalVariableClass.STATUS_CLOSED                        
                                                       AND Case__r.Effective_Date__c > :Date.valueOf(endDate) 
                                                       AND (Case__r.Change_of_Address_Type__c = :GlobalVariableClass.BILLDELIVERYADD                            
                                                            OR Case__r.Change_of_Address_Type__c = :GlobalVariableClass.DELIVERYADDLOC) Order by LastmodifiedDate ASC])
            {        
                if(!SubOldvendormap.containsKey(CaseSubs.Subscription__c)){
                     SubOldvendormap.put(CaseSubs.Subscription__c,CaseSubs.Vendor_Code__c);
                }                                 
            }
            
            //Fetch COV Cases
            for(Case_Subscription__c CaseSubs : [SELECT ID, Name, Case__c, Subscription__c, Vendor_Code__c, Address__c  
                                                   FROM Case_Subscription__c WHERE Subscription__c in :setSubIds AND Case__r.Status = :GlobalVariableClass.STATUS_CLOSED                        
                                                   AND Case__r.Effective_Date__c > :Date.valueOf(endDate) 
                                                   AND Case__r.Change_of_Address_Type__c = :GlobalVariableClass.CHANGEVENDOR Order by LastmodifiedDate ASC])
                           
            {
                if(!SubOldaddressmap.containsKey(CaseSubs.Subscription__c)){
                    SubOldaddressmap.put(CaseSubs.Subscription__c,CaseSubs.Address__c);        
                    }
            }
            
            for(Case_Subscription__c casesub: casesublist){
                 
                recipientContactmap.put(casesub.Case__r.CaseNumber,casesub.Subscription__r.Recipient_Contact__c);
                
                //START UD-3393_UD-3702_D-4287 18-Jan-2016 Added by Raviteja - Updating logic for old vendor
                /*
                if(casesub.Subscription__r.Vendor_1__r.Vendor_Code__c != Null){
                    vendorNumbermap.put(casesub.Case__r.CaseNumber,casesub.Subscription__r.Vendor_1__r.Vendor_Code__c);
                }else system.debug(loggingLevel.warn, casesub.Subscription__r + 'Skip Subscription As Vendor_1__r.Vendor_Code__c is Null' );                
                System.debug('vendorNumbermap: '+vendorNumbermap);                
                if(casesub.Subscription__r.Vendor_1__r.Vendor_Group__c != Null){
                vendorGroupmap.put(casesub.Case__r.CaseNumber,casesub.Subscription__r.Vendor_1__r.Vendor_Group__c );
                }else system.debug(loggingLevel.warn, casesub.Subscription__r + 'Skip Subscription As Vendor_1__r.Vendor_Group__c is Null' );
                System.debug('vendorGroupmap: '+vendorGroupmap);
                */
                if(casesub.Vendor_Code__c != Null){
                    vendorNumbermap.put(casesub.Case__r.CaseNumber,casesub.Vendor_Code__c);
                }else if(SubOldvendormap.containsKey(casesub.Subscription__c)){
                     vendorNumbermap.put(casesub.Case__r.CaseNumber,SubOldvendormap.get(casesub.Subscription__c));   
                }else if(casesub.Subscription__r.Vendor_1__r.Vendor_Code__c != Null){
                    vendorNumbermap.put(casesub.Case__r.CaseNumber,casesub.Subscription__r.Vendor_1__r.Vendor_Code__c);
                }else system.debug(loggingLevel.warn, casesub.Subscription__r + 'Skip Subscription As Vendor_1__r.Vendor_Code__c is Null' );                
                System.debug('vendorNumbermap: '+vendorNumbermap);       
                         
                if(casesub.Vendor_Code__c != Null){
                    vendorGroupmap.put(casesub.Case__r.CaseNumber,'V' );
                }else if(SubOldvendormap.containsKey(casesub.Subscription__c)){
                    vendorGroupmap.put(casesub.Case__r.CaseNumber,'V' ); 
                }else if(casesub.Subscription__r.Vendor_1__r.Vendor_Group__c != Null){
                    vendorGroupmap.put(casesub.Case__r.CaseNumber,casesub.Subscription__r.Vendor_1__r.Vendor_Group__c );
                }else system.debug(loggingLevel.warn, casesub.Subscription__r + 'Skip Subscription As Vendor_1__r.Vendor_Group__c is Null' );
                System.debug('vendorGroupmap: '+vendorGroupmap);                
                
                if(casesub.Address__c != Null){
                    caseAddressmap.put(casesub.Case__r.CaseNumber,casesub.Address__c); //Capturing Old Address
                }else if(SubOldaddressmap.containsKey(casesub.Subscription__c)){
                    caseAddressmap.put(casesub.Case__r.CaseNumber,SubOldaddressmap.get(casesub.Subscription__c)); //Capturing Old Address after batch month
                }else if(casesub.Subscription__r.Recipient_Contact__r.Address__c != Null){
                    caseAddressmap.put(casesub.Case__r.CaseNumber,casesub.Subscription__r.Recipient_Contact__r.Address__c);
                }else system.debug(loggingLevel.warn, casesub.Subscription__r + 'Skip Subscription As Vendor_1__r.Vendor_Code__c is Null' );                
                System.debug('caseAddressmap: '+caseAddressmap); 
                
                //End UD-3393_UD-3702_D-4287 18-Jan-2016 Added by Raviteja - Updating logic for old vendor                
             
                caseFromdatemap.put(casesub.Case__r.CaseNumber,casesub.Complaint_From__c);
                caseTodatemap.put(casesub.Case__r.CaseNumber,casesub.Complaint_To__c);
                caseCopiesmap.put(casesub.Case__r.CaseNumber,casesub.Complaint_Copies__c);              
                
            }     
        
            // Insert records into BT_CO_VSS_CreditDebit__c from Case records
            List<BT_CO_VSS_CreditDebit__c> vssCreditDebitlst = new List<BT_CO_VSS_CreditDebit__c>();        
            
            
             for (Case caseObj :allScopes) {
                 BT_CO_VSS_CreditDebit__c vssCreditDebit = New BT_CO_VSS_CreditDebit__c();
                 if(caseObj.Vendor_Chargeable_Courier__c){            
                     vssCreditDebit.Credit_Debit__c = GlobalVariableClass.DEBIT_IND; //'D';
                     vssCreditDebit.Posting_Date__c = lastDayOfMonth;
                     vssCreditDebit.Recipient_Contact__c = recipientContactmap.get(caseObj.CaseNumber);                
                      
                     if(caseObj.Courier_Fee__c > 0){
                          vssCreditDebit.Total_Amount__c = caseObj.Courier_Fee__c;   
                     }else{
                         vssCreditDebit.Total_Amount__c = 0;                 
                     }
                   
                     System.debug('caseObj.CaseNumber: '+caseObj.CaseNumber); 
                     if(vendorNumbermap.get(caseObj.CaseNumber) != Null && vendorGroupmap.get(caseObj.CaseNumber)!= Null){ 
                     vssCreditDebit.Vendor_Number__c = vendorNumbermap.get(caseObj.CaseNumber);
                     vssCreditDebit.Vendor_Group__c = vendorGroupmap.get(caseObj.CaseNumber);
                    
                     vssCreditDebit.From__C = caseFromdatemap.get(caseObj.CaseNumber);
                     vssCreditDebit.To__c = caseTodatemap.get(caseObj.CaseNumber);
                     
                     //START / End UD-2640 05-Nov-2015 Added by Raviteja  - Commented Copies__c logic
                     //vssCreditDebit.Copies__c = caseCopiesmap.get(caseObj.CaseNumber);
                   
                     vssCreditDebit.Address__c = caseAddressmap.get(caseObj.CaseNumber);
                      
                     System.debug('vssCreditDebit: '+vssCreditDebit);  
                     vssCreditDebit.Job_Id__c = 'SP003'; 
                     vssCreditDebitlst.add(vssCreditDebit);
                     }
                 }   
              }                  
                
            List<Case_Vendor_Fee__c> casevendorlst = new List<Case_Vendor_Fee__c>();
                         
            // Insert records into BT_CO_VSS_CreditDebit__c from Case_Vendor_Fee__c list
             for (Case_Vendor_Fee__c cvfee :[Select Id,Name,Case__c,Case__r.CaseNumber,Copies__c,Paper_Fee__c,Publication__c,Publication__r.Publication_Code__c,
                                                         Subscription__c,Case__r.Vendor_Chargeable_Paper__c,Subscription__r.Vendor_1__r.Vendor_Code__c,
                                                         Subscription__r.Vendor_1__r.Vendor_Group__c 
                                                         From Case_Vendor_Fee__c
                                                            Where Case__c In :allScopes 
                                                                And Case__r.Vendor_Chargeable_Paper__c = TRUE])
             {
                 BT_CO_VSS_CreditDebit__c vssCreditDebitcvf = New BT_CO_VSS_CreditDebit__c();               
                 vssCreditDebitcvf.Credit_Debit__c = GlobalVariableClass.DEBIT_IND; //'D';
                 vssCreditDebitcvf.Copies__c = cvfee.Copies__c;
                 vssCreditDebitcvf.Posting_Date__c = lastDayOfMonth;
                 vssCreditDebitcvf.Publication_Code__c= cvfee.Publication__r.Publication_Code__c;
                 vssCreditDebitcvf.Subscription__c = cvfee.Subscription__c;
                 //START UD-3702 11-Feb-2016 Added by Raviteja - Assiging values into Address and Recipient Contact
                 vssCreditDebitcvf.Address__c = caseAddressmap.get(cvfee.Case__r.CaseNumber);
                 vssCreditDebitcvf.Recipient_Contact__c = recipientContactmap.get(cvfee.Case__r.CaseNumber);   
                 //END UD-3702 11-Feb-2016 Added by Raviteja                 
                 
                 //START UD-2207 - HotFix 15-Oct-2015 Added by Raviteja - Applying Total_Amount__c defacult value as '0'
                 //vssCreditDebitcvf.Total_Amount__c = cvfee.Paper_Fee__c;
                 if(cvfee.Paper_Fee__c > 0){
                      vssCreditDebitcvf.Total_Amount__c = cvfee.Paper_Fee__c;   
                 }else{
                     vssCreditDebitcvf.Total_Amount__c = 0;                 
                 }
                 //End UD-2207 - HotFix 15-Oct-2015 Added by Raviteja 
                 if(cvfee.Subscription__r.Vendor_1__r.Vendor_Code__c != Null && cvfee.Subscription__r.Vendor_1__r.Vendor_Group__c!= Null){
                     vssCreditDebitcvf.Vendor_Number__c = cvfee.Subscription__r.Vendor_1__r.Vendor_Code__c;
                     vssCreditDebitcvf.Vendor_Group__c =  cvfee.Subscription__r.Vendor_1__r.Vendor_Group__c;               
                     vssCreditDebitcvf.From__C = caseFromdatemap.get(cvfee.Case__r.CaseNumber);
                     vssCreditDebitcvf.To__c = caseTodatemap.get(cvfee.Case__r.CaseNumber);                      
                     vssCreditDebitcvf.Job_Id__c = 'SP003'; 
                     vssCreditDebitlst.add(vssCreditDebitcvf);
                 }
                 else
                 system.debug(loggingLevel.warn, cvfee.Subscription__r + 'Skip Subscription As Vendor_1__r.Vendor_Code__c OR Vendor_1__r.Vendor_Group__c is Null' );
                  
                 if(vendorNumbermap.get(cvfee.Case__r.CaseNumber) != Null){
                     vssCreditDebitcvf.Vendor_Number__c = vendorNumbermap.get(cvfee.Case__r.CaseNumber);
                     vssCreditDebitcvf.Vendor_Group__c =  'V';   
                 }  
                   
                 System.debug('vssCreditDebitcvf : '+vssCreditDebitcvf);        
                 
                 
             }   
            System.debug('vssCreditDebitlst.size() : '+vssCreditDebitlst.size());
            if(vssCreditDebitlst.size() > 0){
                insert vssCreditDebitlst;
            }
            
        }
        catch(Exception e) {
            Database.rollback(sp);
            logger.logBatchFailure(e, allScopes);
            logger.save();
            
            isApexJobSuccessful = false;
            System.debug('Error in inserting BT_CO_VSS_CreditDebit__c records  : '+ e);
        }       
                                
    }
    
    global void finish(Database.BatchableContext BC) {   
        Id jobID = BC.getJobId();        
        SP_VBSDebitForComplaint batchJob;
        
        if(isManualrun){          
            batchJob = new SP_VBSDebitForComplaint(jobID, date.newinstance(startDate.year(),startDate.month(),startDate.day()), date.newinstance(endDate.year(),endDate.month(),endDate.day()));
            Database.executeBatch(batchJob,2);          
        }else {
            batchJob = new SP_VBSDebitForComplaint(jobID);
           Database.executeBatch(batchJob,2);
        }
               
       if(!isApexJobSuccessful){
            BatchJobHelper.updateJobStatus(BC.getJobId(), false); 
        }else{
            BatchJobHelper.updateJobStatus(BC.getJobId(), true);
        }
      
    } 
    
}