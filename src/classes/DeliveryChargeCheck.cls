/*
 * Class Name: DeliveryChargeCheck
 * Developer: EBM
 * Date: 9/24/2014
 * Description: Called by eShop to check the delivery charge
 *
*/


@RestResource(urlMapping='/DeliveryChargeCheck/*')  
global with sharing class DeliveryChargeCheck {

    private static DeliveryChargeCheckResponse response = new DeliveryChargeCheckResponse();
    
    global class DeliveryChargeCheckResponse {
        public String delivery_charge;
        public String svc_status;
        public String error_code;
        public String error_message;
    }
    
    global class DeliveryChargeCheckRequest {
        public String postalcode;
        public String blkno;
        public String levelno;
        public String unitno;
        public string subscriberid; //this is the Account_Auto_Number__c field in salesforce Account object
    }
    
    
    @HttpPost
    global static DeliveryChargeCheckResponse processRequest(DeliveryChargeCheckRequest request) {
               
        try{
            //START - 04/16/2015 UD - 0930,0931,0932 Joban - Added null check for the request parameters
            List<Account> accountList = new List<Account>();  
            //START UD-1219 13-May-2015 Added by Raviteja - update the if condition - Only Postal Code is mandatory                  
            /*if(request.postalcode == null || request.postalcode == ''||
               request.blkno == null || request.blkno == ''||
               request.levelno == null || request.levelno == ''||
               
               //request.unitno == null || request.unitno == ''||
               //request.subscriberid == null || request.subscriberid == ''){ */
               if(request.postalcode == null || request.postalcode == ''){
               //End UD-1219 13-May-2015 Added by Raviteja 
                   response.svc_status = 'FAILURE';         
                   response.error_code = 'EXES0001';
                   response.error_message = 'Mandatory validation failed.';                 
            }else {
                //START UD-1219 13-May-2015 Added by Raviteja -Added if condition verifying request.subscriberid doesnot contain null
                if(request.subscriberid != Null){
                   accountList = [SELECT Id FROM Account WHERE Account_Auto_Number__c =: request.subscriberid];
                   if(accountList.isEmpty()){
                       response.svc_status = 'FAILURE';         
                       response.error_code = 'EXES0003';
                       response.error_message = 'Customer Not Found.';          
                    }
                }
                //End UD-1219 13-May-2015 Added by Raviteja 
                ProcessDeliveryChargeCheck(request);        
            }
            //END - 04/16/2015 UD - 0930,0931,0932 Joban - Added null check for the request parameters
        }
        catch(Exception e){           
            response.svc_status = 'FAILURE';
            response.error_code = 'EXGN0000';
            response.error_message = 'Generic Error.';
        }
        
        return response;     
    }
    
    private static void ProcessDeliveryChargeCheck(DeliveryChargeCheckRequest request){
        
        map<Id, Id> mRecipientId_AddressId = new map<Id, Id>();
        map<Id, Address__c> mAddress = new map<Id, Address__c>();
        boolean bFound = false;  
        Account acc = new Account();
        list<Account> lAcc = new list<Account>();
        string pcd, blk, lvl, unt;
        
        if(request.subscriberid != null){

            lAcc = [select id from Account where Account_Auto_Number__c =: request.subscriberid];
                
            if(lAcc.size() > 0){
                
                acc = lAcc[0];
                
                for(Zuora__Subscription__c zSub : [Select Zuora__Account__c, Subscription_Type__c, Recipient_Contact__r.Address__c, Recipient_Contact__c, Id 
                                                   From Zuora__Subscription__c
                                                   where Zuora__Account__c =: acc.Id 
                                                   and Subscription_Type__c =: 'Delivery']){                                                       
                    
                    mRecipientId_AddressId.put(zSub.Recipient_Contact__c, zSub.Recipient_Contact__r.Address__c);                                                                                       
                }
                
                mAddress = new map<Id, Address__c>([Select Id, Postal_Code__r.Name, Block_House_Number__c, Level_Number__c, Unit_Number__c 
                                                    From Address__c WHERE Id IN: mRecipientId_AddressId.values()]);
                
                for(Address__c add: mAddress.values()){
                    
                    pcd = add.Postal_Code__r.Name == null ? '': add.Postal_Code__r.Name;
                    blk = add.Block_House_Number__c == null ? '': add.Block_House_Number__c;
                    lvl = add.Level_Number__c == null ? '': add.Level_Number__c;
                    unt = add.Unit_Number__c == null ? '': add.Unit_Number__c;
                    
                    if(pcd == request.postalcode && blk == request.blkno && lvl == request.levelno && unt == request.unitno){                    
                        response.delivery_charge = '0';
                        response.svc_status = 'SUCCESS';
                        bFound = true;
                    }
                }
                if(!bFound){
                    getDeliveryChargeOfAddress(request);
                }                                                         
            }
        }
        else{
            getDeliveryChargeOfAddress(request);
        }    
    }
    
    private static void getDeliveryChargeOfAddress(DeliveryChargeCheckRequest request){
        //START UD-1219 13-May-2015 Added by Raviteja - Getting Address Type from Singpost_Address__c
        /*Address__c addr = new Address__c();
        list<Address__c> lAddr = new list<Address__c>();
        System.debug(' request.postalcode: '+request.postalcode);
        lAddr = [SELECT Id, Postal_Code__r.Name, Block_House_Number__c, Level_Number__c, Unit_Number__c, Address_Type__c
                    FROM Address__c
                    
                    WHERE Postal_Code__r.Name =: request.postalcode
                    AND Block_House_Number__c =: request.blkno
                    AND Level_Number__c =: request.levelno
                    AND Unit_Number__c =: request.unitno];                    
                    
                    WHERE Postal_Code__r.Name =: request.postalcode AND Address_Type__c != Null];
                    
        */
        Singpost_Address__c addr = new Singpost_Address__c();
        list<Singpost_Address__c> lAddr = new list<Singpost_Address__c>();
        lAddr = [SELECT Id, Address_Type__c,Name FROM Singpost_Address__c where Name =: request.postalcode AND Address_Type__c != Null];
        //End UD-1219 13-May-2015 Added by Raviteja
        if(lAddr.size() > 0){
            addr = lAddr[0];
            string sAddTyp = addr.Address_Type__c; 

            //START UD-1219 13-May-2015 Added by Raviteja - commented existing if condition and added new one
            //START UD-1758 30-June-2015 Added by Raviteja - Getting Delivery Charge from ProductRatePlanCharge 
            // Added by Raviteja - commenting current develivery charge calculation
            /*string defaultdelichargeType = ConstantsSLB.getDefaultDeliveryChargeType(sAddTyp);  
            Decimal delivery_charge;           
            sAddTyp = sAddTyp + defaultdelichargeType;           
            delivery_charge = ConstantsSLB.getSubscriberCharge(sAddTyp);  */        
            Decimal delivery_charge;
            Decimal priceInternal;
            Decimal priceHDB;
            Decimal priceApartment;
            Decimal priceLanded;
                      
            for (zqu__ProductRatePlanCharge__c prpc : [select Name, sum__c, zqu__ProductRatePlan__r.Name 
                        from zqu__ProductRatePlanCharge__c
                        where zqu__ProductRatePlan__r.zqu__ZProduct__r.ProductCode__c = :GlobalVariableClass.PRODUCT_CODE_DELCHG 
                        and (not Name like 'Credit%') and (not Name like 'Dummy%') and zqu__Deleted__c = false]) {
                    System.debug('prpc  : '+prpc );
                    if (prpc.zqu__ProductRatePlan__r.Name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('Zero Charge Amount'))) {
                        priceInternal = prpc.sum__c;
                    } else if (prpc.zqu__ProductRatePlan__r.Name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('HDB DELIVERY CHARGE'))) {
                        System.debug('priceHDB : '+priceHDB );
                        priceHDB = prpc.sum__c;
                    } else if (prpc.zqu__ProductRatePlan__r.Name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('APT DELIVERY CHARGE'))) {
                        priceApartment = prpc.sum__c;
                    } else if (prpc.zqu__ProductRatePlan__r.Name.contains(ConstantsSLB.getProductRatePlanDeliveryCharge('LANDED DELIVERY CHARGE'))) {
                        priceLanded = prpc.sum__c;
                    }       
                }  
             System.debug('sAddTyp : '+sAddTyp );    
            if (sAddTyp == 'H') {
                        delivery_charge = priceHDB;                        
                    }
                    else if (sAddTyp == 'S') {
                        delivery_charge = priceLanded;                        
                    }else{
                        delivery_charge = priceApartment;                        
                    }
            //End UD-1758 30-June-2015 Added by Raviteja 
            /*if(ConstantsSLB.getSubscriberCharge(sAddTyp) != null){
                response.svc_status = 'SUCCESS';            
                response.delivery_charge =  string.valueof(ConstantsSLB.getSubscriberCharge(sAddTyp));
             }*/
             if(delivery_charge != null){
                response.svc_status = 'SUCCESS';            
                response.delivery_charge =  string.valueof(delivery_charge);
                System.debug('delivery_charge 2 : '+delivery_charge );
             }          
            //End UD-1219 13-May-2015 Added by Raviteja 
        }
        else{    
            response.svc_status = 'FAILURE';        
            response.error_code = 'EXES0004';
            response.error_message = 'Postal Code/Block/Level/Unit not found.';              
        }
    }
    /* ---------------------------  THIS IS THE REQUEST PARAMETERS
    {
        "request" : 
        {        
            "postalcode" : "680224",                   
            "blkno" : "224",                   
            "levelno" : "12",               
            "unitno" : "868",                
            "subscriberid" : "30075348" 
        }
    }
    
    Sample Test in Workbench: /services/apexrest/DeliveryChargeCheck/data/v29.0
    --------------------------------------------------------------- */ 
}