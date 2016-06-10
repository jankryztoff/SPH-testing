/*
 * Class Name: AdminCharge_Amendment
 * Developer: EBM
 * Date: 9/22/2014
 * Description: Add Admin Charge in a Subscription
 *
*/

public with sharing class AdminCharge_Amendment {

    public static string sProductRatePlanId = '';
    public static string sProductRatePlanChargeId = '';


   /* public void CreateAdminCharge_TESTCALLER(){ 
        decimal AdminCharge = 17.00;
        String subscriptionId = '2c92c0f94891b98201489d4fc5396855';
    
        amendForNewProduct(subscriptionId, AdminCharge, system.today(), system.today(), system.today(), system.today());
    }*/
    
    // Start D-2712 14Apr15 JohnD - added async method
    @future (callout=true)
    public static void amendForNewProductFutureCallout(String subscriptionId, decimal AdminCharge,
                                        Date ContractEffectiveDate, Date CustomerAcceptanceDate, 
                                        Date EffectiveDate, Date ServiceActivationDate) {
        
        AdminCharge_Amendment adminChargeCall = new AdminCharge_Amendment();
        adminChargeCall.amendForNewProduct(subscriptionId, AdminCharge, ContractEffectiveDate, CustomerAcceptanceDate, 
                EffectiveDate, ServiceActivationDate);
    }
    // End D-2712 14Apr15 JohnD - added async method

    public Boolean amendForNewProduct(String subscriptionId, decimal AdminCharge,
                                        Date ContractEffectiveDate, Date CustomerAcceptanceDate, 
                                        Date EffectiveDate, Date ServiceActivationDate) {
        
                                                                    
        Zuora.zObject amendment = new Zuora.zObject('Amendment');

        
        
        amendment.setValue('ContractEffectiveDate', Zuora.Zutil.getZuoraDate(ContractEffectiveDate));
        amendment.setValue('CustomerAcceptanceDate', Zuora.Zutil.getZuoraDate(CustomerAcceptanceDate));
        amendment.setValue('Description', 'Amendment - Add new Admin Charge');
        amendment.setValue('EffectiveDate', Zuora.Zutil.getZuoraDate(EffectiveDate));
        amendment.setValue('Name', 'Admin Charge');
        amendment.setValue('ServiceActivationDate', Zuora.Zutil.getZuoraDate(ServiceActivationDate));
        amendment.setValue('Status', 'Completed');
        amendment.setValue('SubscriptionId', subscriptionId);
        amendment.setValue('Type', 'NewProduct');                                                           
       
    
        GetRatePlan_And_RatePlanCharge_Id();
        
        // Properties to set
        amendment.setValue('RatePlanData', createRatePlanData(sProductRatePlanId, sProductRatePlanChargeId, AdminCharge));
        
        return amendApiCall(amendment);
    }

    
    public static Zuora.zObject createRatePlanData(String productRatePlanId, String productRatePlanChargeId, decimal AdminCharge) {
        Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
        ratePlanData.setValue('RatePlan', createRatePlan(productRatePlanId));
        ratePlanData.setValue('RatePlanChargeData', new List < Zuora.zObject > {
          createRatePlanChargeDataForNewProduct(productRatePlanChargeId, AdminCharge)
        });
        return ratePlanData;
    }
    
    public static Zuora.zObject createRatePlan(String productRatePlanId) {
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', productRatePlanId);
        return ratePlan;
    }

    public static Zuora.zObject createRatePlanChargeDataForNewProduct(String productRatePlanChargeId, decimal AdminCharge) {
        Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
        ratePlanChargeData.setValue('RatePlanCharge', createRatePlanCharge(productRatePlanChargeId, AdminCharge));
        return ratePlanChargeData;
    }

    public static Zuora.zObject createRatePlanCharge(String productRatePlanChargeId, decimal AdminCharge) {
        Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge.setValue('ProductRatePlanChargeId', productRatePlanChargeId);
        ratePlanCharge.setValue('Price', AdminCharge);
        return ratePlanCharge;
    }


    public static Boolean amendApiCall(Zuora.zObject amendment) {
        Zuora.zApi zuorApi = new Zuora.zApi();
		//START D-3268 Modified By C.I.Salas - Test Coverage
		if (!Test.isRunningTest()) {
			zuorApi.zlogin();
		}
		//END D-3268 Modified By C.I.Salas - Test Coverage
        
        Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
        Zuora.zObject[] amendments = new List < Zuora.zObject > {
          amendment
        };
        
        amendRequest.amendments = amendments;
    
        Zuora.zApi.AmendOptions amendmentOption = new Zuora.zApi.AmendOptions();
        amendmentOption.GenerateInvoice = false;
        amendmentOption.ProcessPayments = false;
    
        amendRequest.amendOptions = amendmentOption;
    
        Zuora.zApi.AmendResult result = zuorApi.zamend(new List < Zuora.zApi.AmendRequest > {
          amendRequest
        });
    
        return result.success;
    }

    private void GetRatePlan_And_RatePlanCharge_Id(){
        //START D-1545 1/29/2015 Added By C. Lin - Change to list and add deleted field is false and limit 1 in the query.
        list<zqu__ProductRatePlanCharge__c> AdminCharge = [SELECT zqu__ZuoraId__c, zqu__ProductRatePlan__r.zqu__ZuoraId__c, zqu__ProductRatePlan__c 
            FROM zqu__ProductRatePlanCharge__c
            WHERE  name =: GlobalVariableClass.ADMIN_CHARGE AND zqu__Deleted__c = false limit 1];
        
        if(AdminCharge.size() == 1){
            sProductRatePlanId = AdminCharge[0].zqu__ProductRatePlan__r.zqu__ZuoraId__c;
            sProductRatePlanChargeId = AdminCharge[0].zqu__ZuoraId__c;
        }
        //END D-1545 1/29/2015 Added By C. Lin
        
    }

    //START UD-2549 3/20/2016 Added by J.Sarion - Bulk Admin Charge Amendment
    public List<Map<String, Object>> bulkAdminChargeAmendment(Map<String, Decimal> subZuoraIdToAdminChargeMap, Map<String, Date> subZuoraIdToStopDateMap) {
        //Maps
        Map<String, Object> amendmentMap = new Map<String, Object>();
        
        //Lists
        List<Map<String, Object>> amendmentMapList = new List<Map<String, Object>>();
        
        GetRatePlan_And_RatePlanCharge_Id();
        
        for(String subZuoraId :subZuoraIdToAdminChargeMap.keySet()) {
            Decimal adminCharge = subZuoraIdToAdminChargeMap.get(subZuoraId);
            if(subZuoraIdToStopDateMap.containsKey(subZuoraId)) {
                Date stopDate = subZuoraIdToStopDateMap.get(subZuoraId);
                
                amendmentMap = new Map<String, Object>();
                
                amendmentMap.put('ContractEffectiveDate', Zuora.Zutil.getZuoraDate(stopDate));
                amendmentMap.put('CustomerAcceptanceDate', Zuora.Zutil.getZuoraDate(stopDate));
                amendmentMap.put('Description', 'Amendment - Add new Admin Charge');
                amendmentMap.put('EffectiveDate', Zuora.Zutil.getZuoraDate(stopDate));
                amendmentMap.put('Name', 'Admin Charge');
                amendmentMap.put('ServiceActivationDate', Zuora.Zutil.getZuoraDate(stopDate));
                amendmentMap.put('Status', 'Completed');
                amendmentMap.put('SubscriptionId', subZuoraId);
                amendmentMap.put('Type', 'NewProduct');
                amendmentMap.put('RatePlanData', createRatePlanData(sProductRatePlanId, sProductRatePlanChargeId, adminCharge));
                
                amendmentMapList.add(amendmentMap);
            }
        }
        
        return amendmentMapList;
    }
    //END UD-2549 3/20/2016 Added by J.Sarion - Bulk Admin Charge Amendment
}