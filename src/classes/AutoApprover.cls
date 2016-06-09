/**
 * Class Name: <AutoApprover>
 * @author: <C. Lin>
 * Date: <02Feb2016>
 * Requirement/Project Name: <SPH>
 * @description: <Auto Approve or Reject of Temp Stop Case>
 */

public class AutoApprover implements Queueable, Database.allowsCallouts {
    
	Map<Id, List<ProcessInstance>> mapReturnPI = new Map<Id, List<ProcessInstance>>();
    Map<Id, Id> tObjIdToworkItemIdMap = new Map<Id, Id>();
	
	set<id> approvedCaseIdSet = new set<id>();
	string action;

	public AutoApprover(set<id> approvedCaseIdSetParam, string actionParam) {
		this.approvedCaseIdSet = approvedCaseIdSetParam;
		this.action = actionParam;
	}

	public void execute(QueueableContext context) {
		if (action == 'Approved') {
			approveRecord(approvedCaseIdSet);
		} else if (action == 'Reject') {
			rejectRecord(approvedCaseIdSet);
		}
	}


    /**
    * This method will Approve the Case Record
    **/
    @TestVisible // Start/End PD-0236 Vpernicia: Test Class enhancement
    private void approveRecord(Set<Id> approvedCasesSet)
    {
        Set<Id> caseIdToAppSet = new Set<Id>();
        Set<Id> tempStopSubIdSet = new Set<Id>();
        Set<Id> OLIIdSet = new Set<Id>();
		Map<Id, Zuora__Subscription__c> subIdToSubscriptionMap = new Map<Id, Zuora__Subscription__c>();
		Map<Id, List<Case>> approveBundleCaseTS = new Map<Id, List<Case>>();
		Logger logger = new Logger(AutoApprover.class.getName(), null, null);
		
		List<Case> casesList = [SELECT Id, Temp_Stop_Sub__c, Temp_Stop_Date__c, Restart_Date__c, Temp_Stop_Type__c FROM Case WHERE Id IN :approvedCasesSet];
        
		if(!casesList.isEmpty()){
			for(Case cas : casesList){
				if(cas.Temp_Stop_Sub__c != null){
					tempStopSubIdSet.add(cas.Temp_Stop_Sub__c);
				}
			}
		}
		
		if(!tempStopSubIdSet.isEmpty()){
            for(Zuora__Subscription__c sub : [SELECT Id, Name, Order_Line_Item_Number_1__c FROM Zuora__Subscription__c WHERE Id IN :tempStopSubIdSet]){
                subIdToSubscriptionMap.put(sub.Id, sub);
            }
        }
		
		if(!casesList.isEmpty()){
			for(Case cas : casesList){
				if(subIdToSubscriptionMap.containsKey(cas.Temp_Stop_Sub__c)){
					if(subIdToSubscriptionMap.get(cas.Temp_Stop_Sub__c).Order_Line_Item_Number_1__c != null){
						OLIIdSet.add(subIdToSubscriptionMap.get(cas.Temp_Stop_Sub__c).Order_Line_Item_Number_1__c);
					}
				}
			}
		}
		
        if(!OLIIdSet.isEmpty()){
            for(Case casR : [SELECT Id, Temp_Stop_Date__c, Restart_Date__c, Temp_Stop_Type__c FROM Case WHERE Temp_Stop_Sub__r.Order_Line_Item_Number_1__c IN :OLIIdSet AND Temp_Stop_Sub__c NOT IN :tempStopSubIdSet AND Sub_Status__c != 'Temp Stop Approved' AND Sub_Status__c != 'Temp Stop Rejected]']){
				for(Case theCase : casesList){
                    if(casR.Temp_Stop_Date__c == theCase.Temp_Stop_Date__c && casR.Restart_Date__c == theCase.Restart_Date__c && casR.Temp_Stop_Type__c == theCase.Temp_Stop_Type__c){
                        if(approveBundleCaseTS.containsKey(theCase.Id)){
                            approveBundleCaseTS.get(theCase.Id).add(casR);
                        }else{
                            approveBundleCaseTS.put(theCase.Id, new List<Case> {casR});
                        }
                    }
                }
			}
		}
		
        for(Id cId : approveBundleCaseTS.keySet()){
            if(approveBundleCaseTS.containsKey(cId)){
                for(Case caseRec : approveBundleCaseTS.get(cId)){
                    caseIdToAppSet.add(caseRec.Id);
                }
            }
        }
        
        getProcessInstance(approvedCasesSet);
        getProcessInstanceWorkitem(caseIdToAppSet);
        
        for(Id cId : approvedCasesSet){
            String comments = mapReturnPI.get(cId)[0].Steps[0].Comments;
            
            if(approveBundleCaseTS.containsKey(cId)){
                for(Case caseRec : approveBundleCaseTS.get(cId)){
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    
                    req.setComments(comments);
                    req.setAction('Approve');
                    Id workItemId = tObjIdToworkItemIdMap.get(caseRec.Id);
                    
                    if(workItemId == null)
                    {
						logger.log(true, 'Error Occured in Trigger for Approving Case. workItemId is null.');
                        system.debug('Error Occured in Trigger for Approving Case. workItemId is null.');
                    }
                    else
                    {
                        req.setWorkitemId(workItemId);
                        // Submit the request for approval
						try{
							Approval.ProcessResult result =  Approval.process(req);
						}catch(Exception e){
							logger.log(e);
						}
                    }
                }
            }
        }
		
		logger.save();
    }
    
    /**
    * This method will Reject the Case Record
    **/
    private void rejectRecord(Set<Id> approvedCasesSet)
    {
        Set<Id> caseIdToRejSet = new Set<Id>();
        Set<Id> tempStopSubIdSet = new Set<Id>();
        Set<Id> OLIIdSet = new Set<Id>();
		Map<Id, Zuora__Subscription__c> subIdToSubscriptionMap = new Map<Id, Zuora__Subscription__c>();
		Map<Id, List<Case>> rejectBundleCaseTS = new Map<Id, List<Case>>();
		Logger logger = new Logger(AutoApprover.class.getName(), null, null);
		
		List<Case> casesList = [SELECT Id, Temp_Stop_Sub__c, Temp_Stop_Date__c, Restart_Date__c, Temp_Stop_Type__c FROM Case WHERE Id IN :approvedCasesSet];
        
		if(!casesList.isEmpty()){
			for(Case cas : casesList){
				if(cas.Temp_Stop_Sub__c != null){
					tempStopSubIdSet.add(cas.Temp_Stop_Sub__c);
				}
			}
		}
		
		if(!tempStopSubIdSet.isEmpty()){
            for(Zuora__Subscription__c sub : [SELECT Id, Name, Order_Line_Item_Number_1__c FROM Zuora__Subscription__c WHERE Id IN :tempStopSubIdSet]){
                subIdToSubscriptionMap.put(sub.Id, sub);
            }
        }
		
		if(!casesList.isEmpty()){
			for(Case cas : casesList){
				if(subIdToSubscriptionMap.containsKey(cas.Temp_Stop_Sub__c)){
					if(subIdToSubscriptionMap.get(cas.Temp_Stop_Sub__c).Order_Line_Item_Number_1__c != null){
						OLIIdSet.add(subIdToSubscriptionMap.get(cas.Temp_Stop_Sub__c).Order_Line_Item_Number_1__c);
					}
				}
			}
		}
		
        if(!OLIIdSet.isEmpty()){
            for(Case casR : [SELECT Id, Temp_Stop_Date__c, Restart_Date__c, Temp_Stop_Type__c FROM Case WHERE Temp_Stop_Sub__r.Order_Line_Item_Number_1__c IN :OLIIdSet AND Temp_Stop_Sub__c NOT IN :tempStopSubIdSet AND Sub_Status__c != 'Temp Stop Approved' AND Sub_Status__c != 'Temp Stop Rejected]']){
				for(Case theCase : casesList){
                    if(casR.Temp_Stop_Date__c == theCase.Temp_Stop_Date__c && casR.Restart_Date__c == theCase.Restart_Date__c && casR.Temp_Stop_Type__c == theCase.Temp_Stop_Type__c){
                        if(rejectBundleCaseTS.containsKey(theCase.Id)){
                            rejectBundleCaseTS.get(theCase.Id).add(casR);
                        }else{
                            rejectBundleCaseTS.put(theCase.Id, new List<Case> {casR});
                        }
                    }
                }
			}
		}
		
        for(Id cId : rejectBundleCaseTS.keySet()){
            if(rejectBundleCaseTS.containsKey(cId)){
                for(Case caseRec : rejectBundleCaseTS.get(cId)){
                    caseIdToRejSet.add(caseRec.Id);
                }
            }
        }
        
        getProcessInstance(approvedCasesSet);
        getProcessInstanceWorkitem(caseIdToRejSet);
        
        for(Id cId : approvedCasesSet){
			String comments = mapReturnPI.get(cId)[0].Steps[0].Comments;
                
            if(rejectBundleCaseTS.containsKey(cId)){
                for(Case caseRec : rejectBundleCaseTS.get(cId)){
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setComments(comments);
                    req.setAction('Reject');
                    Id workItemId = tObjIdToworkItemIdMap.get(caseRec.Id);
                    if(workItemId == null)
                    {
						logger.log(true, 'Error Occured in Trigger for Approving Case. workItemId is null.');
                        system.debug('Error Occured in Trigger for Rejecting Case. workItemId is null.');
                    }
                    else
                    {
                        req.setWorkitemId(workItemId);
                        // Submit the request for approval
						try{
							Approval.ProcessResult result =  Approval.process(req);
						}catch(Exception e){
							logger.log(e);
						}
                    }
                }
            }
        }
		
		logger.save();
    }
    
    private void getProcessInstance(Set<Id> caseIds){
        List<ProcessInstance> listTemp;
        
        if(!caseIds.isEmpty()){
            for(ProcessInstance PI: [SELECT Id, TargetObjectId,(SELECT Id, StepStatus, Comments FROM Steps WHERE StepStatus = 'Approved' OR StepStatus = 'Rejected'),(SELECT Id, ActorId, ProcessInstanceId FROM Workitems) FROM ProcessInstance where TargetObjectId IN :caseIds]){
                if(mapReturnPI.ContainsKey(PI.TargetObjectId)){
                    listTemp = mapReturnPI.get(PI.TargetObjectId);
                }else{
                    listTemp = new list<ProcessInstance>();
                }

                listTemp.add(PI);
                mapReturnPI.put(PI.TargetObjectId, listTemp);
            }
        }
    }
    
    private void getProcessInstanceWorkitem(Set<Id> caseIds){
        if(!caseIds.isEmpty()){
            for(ProcessInstanceWorkitem workItem  : [SELECT p.Id, p.ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem p WHERE p.ProcessInstance.TargetObjectId IN :caseIds])
            {
                tObjIdToworkItemIdMap.put(workItem.ProcessInstance.TargetObjectId, workItem.Id);
            }
        }
    }
}