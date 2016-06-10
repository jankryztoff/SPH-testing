@isTest
private class SM_SubscriptionHelper_Test01 {

    static void setCustomSettings() {
    
        //Cir_Planner_Schedule__c
        List<Cir_Planner_Schedule__c> cpsList = new List<Cir_Planner_Schedule__c>{
                new Cir_Planner_Schedule__c(Name='CIR Plan Schedule',
                                            Mon_Fri_End_Time__c=Date.today(),
                                            Mon_Fri_Start_Time__c=Date.today(),
                                            Sat_PH_End_Time__c=Date.today(),
                                            Sat_PH_Start_Time__c=Date.today(),
                                            Sun_End_Time__c=Date.today(),
                                            Sun_Start_Time__c=Date.today())
        };
        Database.insert(cpsList);
        
        //
        RecordType Case_ChangeinAddress = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Change of Address/Vendor' LIMIT 1];
        RecordType Case_TempStop        = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Temp Stop Subscription' LIMIT 1];
        RecordType Contact_VendorStaff     = [SELECT id, Name FROM RecordType WHERE SobjectType='Contact' AND Name='Vendor Staff' LIMIT 1];
        RecordType Contact_CustomerContact = [SELECT id, Name FROM RecordType WHERE SobjectType='Contact' AND Name='Customer Contact' LIMIT 1];
        RecordType Case_Stop = [SELECT id, Name FROM RecordType WHERE SobjectType='Case' AND Name='Stop Subscription' LIMIT 1];
        
        //Key_Id__c
        //.getInstance('Vendor Rep Role')
        //ConstantsSLB.getKeyId('Contact_Customer Contact');
        /*
        final string AIRLINE = ConstantsSLB.getKeyId('AddAirline');
        final string OVERSEAS = ConstantsSLB.getKeyId('AddOverseas');
        final string LOCAL = ConstantsSLB.getKeyId('AddLocal');
        final string INTERNAL = ConstantsSLB.getKeyId('AddInternal');
        */
        List<Key_Id__c> kisList = new List<Key_Id__c>{
            new Key_Id__c(Name='Vendor Rep Role',       Id__c='123456789', Type__c='Number'),
            new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER', Id__c='123456789', Type__c='Number'),
            
            new Key_Id__c(Name='Case_Change in Address', Id__c=Case_ChangeinAddress.id, Type__c='RecordType'),
            new Key_Id__c(Name='Case_Temp Stop',         Id__c=Case_TempStop.id,        Type__c='RecordType'),
            
            new Key_Id__c(Name='Contact_Vendor Staff',     Id__c=Contact_VendorStaff.id,     Type__c='RecordType'),
            new Key_Id__c(Name='Contact_Customer Contact', Id__c=Contact_CustomerContact.id, Type__c='RecordType'),
            
            new Key_Id__c(Name='Case_Stop', Id__c=Case_Stop.id ,Type__c='RecordType'),
            
            new Key_Id__c(Name='AddInternal', Id__c='Internal', Type__c='Name'),
            new Key_Id__c(Name='AddLocal',    Id__c='Local',     Type__c='Name')
        };
        Database.insert(kisList);
        
        //Batch_Configuration_Settings__c.getInstance('SP_VendorNotificationsBatch');
        List<Batch_Configuration_Settings__c> bcsList = new List<Batch_Configuration_Settings__c>{
            new Batch_Configuration_Settings__c(Name='SP_VendorNotificationsBatch', Batch_Size__c=10, 
                Max_Retries__c=10, Notification_Recipients__c='', Number_Of_Days_To_Retrieve__c=30)
        };
        Database.insert(bcsList);
        
        //Other__c
        // List<Other__c> otherList = new List<Other__c>{
        //     //new Other__c(Name='DTL', Value__c='2:00'),
            
        //     new Other__c(Name='Zero Charge Amount',     Value__c='Zero Charge Amount'),
        //     new Other__c(Name='HDB DELIVERY CHARGE',    Value__c='HDB Delivery Charge'),
        //     new Other__c(Name='APT DELIVERY CHARGE',    Value__c='Apt Delivery Charge'),
        //     new Other__c(Name='LANDED DELIVERY CHARGE', Value__c='Landed Delivery Charge')
        // };        
        // Database.insert(otherList);
        
        //Delivery_Charge_Type__c
        List<Delivery_Charge_Type__c> delCharTypeList = new List<Delivery_Charge_Type__c>{
            new Delivery_Charge_Type__c(Name='H', Default_Delivery_Charge_Type__c='H'),
            new Delivery_Charge_Type__c(Name='L', Default_Delivery_Charge_Type__c='L'),
            new Delivery_Charge_Type__c(Name='C', Default_Delivery_Charge_Type__c='C')
        };
        Database.insert(delCharTypeList);
    }
    static void testGetDtlDate01() {
    
        setCustomSettings();
    
        //Public_Holiday__c
        Public_Holiday__c publicHoliday = new Public_Holiday__c(
            Holiday_Date__c=Date.today(), Holiday_Description__c='National Day'
        );
        Database.insert(publicHoliday);
        
        SM_SubscriptionHelper.getDtlDate();
    }
}