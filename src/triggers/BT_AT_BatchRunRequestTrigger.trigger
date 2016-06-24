/**
 * Trigger Name: BT_AT_AGD043DX_AGD_EINVOICE
 * Author: Kevin Evasco
 * Date: 08/10/2014
 * Project/Requirement: SPH Integration - SF2LEG Interfaces
 * Description: This trigger executes the batch jobs given the Interface ID of the created Batch Run Request.
 * History: 09/10/2014 Kevin Evasco Created Apex Trigger
 * History: 09/23/2014 Renino Niefes added validation if an existing batch run request is still alive.  If yes, add an error to prevent insertion.
 * History: 09/29/2014 Renino Niefes - added the list of interfaces that will require validation 
 * History: 11/03/2014 Renino Niefes - added the list of interfaces that will require validation 
 * History: 11/09/2014 Renino Niefes - added new list of interfaces that will require validation and new classes. splitted HDS039DX into two
 * History: 2015/03/04 Renino Niefes - D-2434 added a new layer for Delete Records in the data pool. Moved the dynamic instantiation of apex classes into that layer
 *          2015/03/13 Michael Francisco - added an entry for the new SMS104DX interface
 */

trigger BT_AT_BatchRunRequestTrigger on BT_CO_Batch_Run_Request__c (before insert) {

    List<BT_CO_Batch_Run_Request__c> batchRunRequestList = trigger.new;
    
    List<String> interfaceIdList = new List<String>();
    for(BT_CO_Batch_Run_Request__c batchRunRequest: batchRunRequestList)        
    {
        interfaceIdList.add(batchRunRequest.Interface_ID__c);
    }
    
    List<BT_CO_Batch_Run_Request__c> brrList = [SELECT End_Time__c,Id,Interface_ID__c FROM BT_CO_Batch_Run_Request__c WHERE Interface_ID__c IN :interfaceIdList];
    
    /*
        Loop through all Batch Run Request object and put to Map those records that are still active.
    */
    Map<String, String> brrMap = new Map<String, String>(); 
    for (BT_CO_Batch_Run_Request__c brrRecord: brrList)
    {
        if (brrRecord.End_Time__c == null) {
            brrMap.put(brrRecord.Interface_ID__c,'Any value here');
        }
    }
    
    for(BT_CO_Batch_Run_Request__c batchRunRequest: batchRunRequestList)
    {
        String interfaceId = batchRunRequest.Interface_ID__c;
        batchRunRequest.Start_Time__c = DateTime.now();
        Set<String> interfaceSet = new Set<String>();
        
        //Add all interfaces that will implement validation (Concurrent job validation)
        //Note: this will be removed later on since all batch job requests must implement concurrent job validation.
        interfaceSet.add('ARM063DX');
        interfaceSet.add('ARM064DX');
        interfaceSet.add('ARM065DX');       
        interfaceSet.add('ARM066DX');
        
        interfaceSet.add('CMI087DX');
        
        interfaceSet.add('REW031DX');
        interfaceSet.add('REW040DX');
        interfaceSet.add('REW041DX');

        interfaceSet.add('VSS088DX');
        interfaceSet.add('VSS089DX');
        interfaceSet.add('VSS090DX');       
        interfaceSet.add('VSS093DX');
        
        interfaceSet.add('MIRO055DX');

        interfaceSet.add('DIR094DX');
        
        interfaceSet.add('VBS103DX');
        
        interfaceSet.add('AGD042DX');

        interfaceSet.add('INET052DX');        
        interfaceSet.add('INET054DX');
        
        interfaceSet.add('SAP072DX');
        
        interfaceSet.add('HDS038DX');
        interfaceSet.add('HDS036DX');
        interfaceSet.add('HDS037DX');
        
        interfaceSet.add('PPS056DX');
   
        //START MD-54 2015/03/13 Michael Francisco - Added entry for SMS104DX interface 
        interfaceSet.add('SMS104DX');
        //END MD-54 2015/03/13 Michael Francisco 
   
        //complex Tasks
        interfaceSet.add('HDS039DX');
        interfaceSet.add('CMI101DX');
        interfaceSet.add('ARM067DX');
        
        interfaceSet.add('HDS039DX_CR');
        interfaceSet.add('HDS039DX_DB');
        
        interfaceSet.add('ARM067DX_2');     
        
        //START 25 February 2016 NCR015-5 Kevin Evasco - Packing Label CR 
        interfaceSet.add('CMI102DX');     
        //END 25 February 2016 NCR015-5 Kevin Evasco - Packing Label CR 
        
        //START 25 February 2016 NCR016 Kevin Evasco - Singpost Address 
        interfaceSet.add('DIR097DX');     
        //END 25 February 2016 NCR016 Kevin Evasco - Singpost Address
        
        //START 11 March 2016 UD-3247 Kevin Evasco - Credit Adjustment Interface
        interfaceSet.add('ARM068DX');     
        //START 11 March 2016 UD-3247 Kevin Evasco - Credit Adjustment Interface
        
        //START 28 March 2016 UD-3207 Kevin Evasco - Added ARM105DX
        interfaceSet.add('ARM105DX'); 
        interfaceSet.add('AGD106DX'); 
        //END 28 March 2016 UD-3207 Kevin Evasco - Added ARM105DX
        
        /*
        Check if an existing batch run request is still active.  if yes, add an error to prevent insertion.
        NOTE: remove this "&&batchRunRequest.Interface_ID__c=='ARM065DX'" in the condition later.  this is
              just temporary so that other interfaces won't get affected by this change.  For now, this applies to
              ARM065DX only...
        */
        if (brrMap.get(batchRunRequest.Interface_ID__c)!=null && interfaceSet.contains(batchRunRequest.Interface_ID__c))
        {
            batchRunRequest.addError('Cannot execute this batch run because it is currently active. ');
        }
        else 
        {
            //[Start D-2434 Renz 2015-03-04] Added a new layer DeleteRecords class. Transferred all the execution of Apex Classes to BT_AB_DATAPOOL_DeleteRecords
            BT_AB_DATAPOOL_DeleteRecords delJob = new BT_AB_DATAPOOL_DeleteRecords();
            delJob.setInterfaceId(interfaceId);
            Database.executeBatch(delJob);
            //[END D-2434 Renz Niefes 2015-03-04]
        }
    }
}