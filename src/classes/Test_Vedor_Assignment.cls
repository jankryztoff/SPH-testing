//*********************************************************************************************
//
// Author: Glen Anthony Abanes Cubinar
// Date: 1/13/2015
// Description: Test Class for Vendor_Assignment
//
//*********************************************************************************************

@isTest
Private Class Test_Vedor_Assignment {

    Public Static testMethod void Test_Vendor_Order_line_Items() {

        List<Order_Line_Item_Vendor__c> lOLI = new  List<Order_Line_Item_Vendor__c>();
        List<Publication__c> lP = new List<Publication__c>();
        List<Account> lA = new List<Account>();
        List<Contact> lC = new List<Contact>();
        List<Order__c> lO = new List<Order__c>();
        List<Key_Id__c> lkID = new List<Key_Id__c>();
        List<Other__c> lOtr = new List<Other__c>();
        List<Vendor_Allocation__c> lvAll = new List<Vendor_Allocation__c>();
        List<Singpost_Address__c> lsAdd = new List<Singpost_Address__c>();
        List<Address__c> lAdd = new List<Address__c>();
        List<Project__c> lproj = new List<Project__c>();
        List<Parcel__c> lparc = new List<Parcel__c>();        
        
        //GAAC: Insert Key Id
        Key_Id__c kID = new Key_Id__c();
        kID.Name = 'Default Mailing Agent';
        kID.Id__c = '001N000000ICcIv';
        kID.Type__c = '';
        
        Key_Id__c kID1 = new Key_Id__c();
        kID1.Name = 'Account_Vendor Subscriber';
        kID1.Id__c = '012N00000008ibwIAA';
        kID1.Type__c = 'RecordType';
        
        Key_Id__c kID2 = new Key_Id__c();
        kID2.Name = 'Account_Direct Individual';
        kID2.Id__c = '012N00000008ic1IAA';
        kID2.Type__c = 'RecordType';        
        
        Key_Id__c kID3 = new Key_Id__c();
        kID3.Name = 'Contact_Customer Contact';
        kID3.Id__c = '012N00000008r43IAA';
        kID3.Type__c = 'RecordType';        
        
        Key_Id__c kID4 = new Key_Id__c();
        kID4.Name = 'Contact_Recipient Contact';
        kID4.Id__c = '012N00000008id4IAA';
        kID4.Type__c = 'RecordType';      
        
        lkID.add(kID);
        lkID.add(kID1);
        lkID.add(kID2);
        lkID.add(kID3);
        lkID.add(kID4);
        Insert lkID;
        
        //GAAC: Insert Other
        Other__c Otr = new Other__c();
        Otr.Name = 'Product_Category Digital';
        Otr.Value__c = 'Digital';
        
        Other__c Otr1 = new Other__c();
        Otr1.Name = 'Product_Category Print';
        Otr1.Value__c = 'Print';
        
        Other__c Otr2 = new Other__c();
        Otr2.Name = 'Product_Category AIO';
        Otr2.Value__c = 'All in One (AIO)';
        
        Other__c Otr3 = new Other__c();
        Otr3.Name = 'Product_Category Magazine';
        Otr3.Value__c = 'Magazine';
        
        Other__c Otr4 = new Other__c();
        Otr4.Name = 'Order_Type Start';
        Otr4.Value__c = 'Start';
        
        Other__c Otr5 = new Other__c();
        Otr5.Name = 'Order_Line_Item Neutral';
        Otr5.Value__c = 'Neutral/Flat';
        
        Other__c Otr6 = new Other__c();
        Otr6.Name = 'Reason_Code Correction';
        Otr6.Value__c = 'Correction';
        
        Other__c Otr7 = new Other__c();
        Otr7.Name = 'Order_Type COS_Quantity';
        Otr7.Value__c = 'Change of Subscription Quantity';
        
        Other__c Otr8 = new Other__c();
        Otr8.Name = 'Order_Type COS_Package';
        Otr8.Value__c = 'Change of Subscription Package';
        
        Other__c Otr9 = new Other__c();
        Otr9.Name = 'Order_Type Renewal';
        Otr9.Value__c = 'Renewal';
        
        Other__c Otr10 = new Other__c();
        Otr10.Name = 'Order_Type Stop';
        Otr10.Value__c = 'Stop';
        
        lOtr.add(Otr);
        lOtr.add(Otr1);
        lOtr.add(Otr2);
        lOtr.add(Otr3);
        lOtr.add(Otr4);
        lOtr.add(Otr5);
        lOtr.add(Otr6);
        lOtr.add(Otr7);
        lOtr.add(Otr8);
        lOtr.add(Otr9);
        lOtr.add(Otr10);
        Insert lOtr;

        //GAAC: Get RecordType Id
        Map<String, Id> mappedRecordType = new Map<String, Id>();
        for(RecordType crt : [SELECT Name, id FROM RecordType WHERE SObjectType =: 'Account']) {
        
            MappedRecordType.put(crt.Name, crt.id);
        }

        //GAAC: Insert Singpost Address
        Singpost_Address__c sAdd = new Singpost_Address__c();
        sAdd.Name = '1850';
        sAdd.SingPost_Key__c = 'Test Address';

        Singpost_Address__c sAdd1 = new Singpost_Address__c();
        sAdd1.Name = '1234';
        sAdd1.SingPost_Key__c = 'Test Address1';
        
        lsAdd.add(sAdd);        
        lsAdd.add(sAdd1);
        Insert lsAdd;
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'NEXT_RECIPIENT_NUMBER';
        key.Id__c = '123457397';
        key.Type__c = 'Number';
        insert key; 
 
        //GAAC: Insert Address
        Address__c Add = new Address__c();
        Add.Name = 'Address1';
        Add.Postal_Code__c = sAdd.Id;
        Add.Legacy_Created_By__c = 'Glen Cubinar';
        Add.Legacy_Created_Date__c = '12/1/2015';
        Add.Legacy_Updated_By__c = 'Glen Cubinar';
        Add.Legacy_Updated_Date__c = '12/1/2015';

        Address__c Add1 = new Address__c();
        Add1.Name = 'Address1';
        Add1.Postal_Code__c = sAdd1.Id;
        Add1.Legacy_Created_By__c = 'Glen Cubinar';
        Add1.Legacy_Created_Date__c = '12/1/2015';
        Add1.Legacy_Updated_By__c = 'Glen Cubinar';
        Add1.Legacy_Updated_Date__c = '12/1/2015';
        
        lAdd.add(Add);        
        lAdd.add(Add1);
        Insert lAdd;
        
        //GAAC: Insert Account
        Account a = new Account();
        a.Name = 'accountOne';
        a.RecordTypeId = MappedRecordType.get('Vendor');
                
        lA.add(a);
        Insert lA;
        
        //GAAC: Insert Contact
        Contact c = new Contact();
        c.AccountId = a.Id;
        c.FirstName = 'Glen';
        c.LastName = 'Cubinar';
        c.Recipient_Indicator__c = TRUE;
        c.MailingPostalCode = '1850';
        c.Address__c = Add.Id;

        Contact c1 = new Contact();
        c1.AccountId = a.Id;
        c1.FirstName = 'Glen1';
        c1.LastName = 'Cubinar1';
        c1.Recipient_Indicator__c = TRUE;
        c1.MailingPostalCode = '1234';
        c1.Address__c = Add1.Id;
        
        lC.add(c);        
        lC.add(c1);
        Insert lC;
        
        //GAAC: Insert Order
        Order__c o = new Order__c();
        o.Account__c = a.Id;
        o.Order_Legacy_Id__c = '0001';
        o.Legacy_Create_Date__c = '12/1/2015';
        o.Legacy_Create_By__c = 'Glen Cubinar';
        o.Legacy_Update_Date__c = '12/1/2015';
        o.Legacy_Update_By__c= 'Glen Cubinar';
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;

        Order__c o1 = new Order__c();
        o1.Account__c = a.Id;
        o1.Order_Legacy_Id__c = '0002';
        o1.Legacy_Create_Date__c = '12/1/2015';
        o1.Legacy_Create_By__c = 'Glen Cubinar';
        o1.Legacy_Update_Date__c = '12/1/2015';
        o1.Legacy_Update_By__c= 'Glen Cubinar';
        o1.Delivery_Charge__c = 10000;
        o1.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o1.Credit_Balance__c = 10000;
        o1.Informed_Customer__c = TRUE;
        o1.Recipient_Contact__c = c1.Id;
        
        lO.add(o);        
        lO.add(o1);
        Insert lO;
        
        //GAAC: Insert Publication
        Publication__c p = new Publication__c();
        p.Name = 'publicationOne';
        p.Publication_Code__c = '0001';
        p.Published_Days__c = '12/1/15';
        p.Publication_Type__c = 'N';
        
        lP.add(p);        
        Insert lP;
         
        //GAAC: Insert Order Line Item Vendor
        Order_Line_Item_Vendor__c oLI = new Order_Line_Item_Vendor__c();
        oLI.Publication__c  = p.id;
        oLI.Order__c = o.id;
        oLI.Start_Date__c = System.Today();

        Order_Line_Item_Vendor__c oLI1 = new Order_Line_Item_Vendor__c();
        oLI1.Publication__c  = p.id;
        oLI1.Order__c = o1.id;
        oLI1.Start_Date__c = System.Today();
        
        lOLI.add(oLI);        
        lOLI.add(oLI1);
        Insert lOLI;

 
        
        //GAAC: Insert Project
        Project__c proj = new Project__c();
        proj.Name = 'Test Proj1';
        proj.Project_Description__c = 'Test';
        proj.Legacy_Created_Date__c = '12/1/2015';
        proj.Legacy_Created_By__c = 'Glen Cubinar';
        proj.Legacy_Updated_Date__c = '12/1/2015';
        proj.Legacy_Updated_By__c = 'Glen Cubinar';
        
        lproj.add(proj);
        Insert lproj;
        
        //GAAC: Insert Parcel
        Parcel__c parc = new Parcel__c();
        parc.Name = 'Parcel1';
        parc.Project_Name__c = proj.Id;
        parc.Description__c = 'Test';
        parc.Allocation_Type__c = 'Normal';
        parc.Vendor_Code__c = '00001';
        
        lparc.add(parc);
        Insert lparc;
        
        //GAAC: Insert Vendor Allocation
        Vendor_Allocation__c vAll = new Vendor_Allocation__c();
        vAll.SingPost_Address__c = sAdd.Id;
        vAll.Vendor_Account__c = a.Id;
        vAll.Legacy_Created_Date__c = '12/1/2015';
        vAll.Legacy_Updated_By__c = 'Glen Cubinar';
        vAll.Legacy_Updated_Date__c = '12/1/2015';
        vAll.Legacy_Updated_By__c = 'Glen Cubinar';
        vAll.Parcel_Name__c = parc.Id;
        vAll.Effective_Start_Date__c = System.Today();
        
        lvAll.add(vAll);
        Insert lvAll;
        
    Test.StartTest();
    
        try {
        
            List<Order_Line_Item_Vendor__c> ord0 = [SELECT Id, Order__c, Order__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name, Recipient_Postal_Code__c FROM Order_Line_Item_Vendor__c  WHERE Id =: oLI.id];      
            List<Order_Line_Item_Vendor__c> ord1 = [SELECT Id, Order__c, Order__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name, Recipient_Postal_Code__c FROM Order_Line_Item_Vendor__c  WHERE Id =: oLI1.id];      
        
            Vendor_Assignment vA = new Vendor_Assignment();
            vA.Assign_Vendor_To_Order_line_Items(ord0);
            vA.Assign_Vendor_To_Order_line_Items(ord1);
            
        } catch (Exception e) {
        
            system.assertEquals('ERROR:', string.valueOf(e));
        }
    
    Test.StopTest();            

    }

    Public Static testMethod void Test_Order_line_Items() {

        List<Order_Line_Item__c> lOLI = new  List<Order_Line_Item__c>();
        List<Package__c> lPck = new List<Package__c>();
        List<Account> lA = new List<Account>();
        List<Contact> lC = new List<Contact>();
        List<Order__c> lO = new List<Order__c>();
        List<Key_Id__c> lkID = new List<Key_Id__c>();
        List<Other__c> lOtr = new List<Other__c>();
        List<Vendor_Allocation__c> lvAll = new List<Vendor_Allocation__c>();
        List<Singpost_Address__c> lsAdd = new List<Singpost_Address__c>();
        List<Address__c> lAdd = new List<Address__c>();
        List<Project__c> lproj = new List<Project__c>();
        List<Parcel__c> lparc = new List<Parcel__c>();
        
        //GAAC: Insert Key Id
        Key_Id__c kID = new Key_Id__c();
        kID.Name = 'Default Mailing Agent';
        kID.Id__c = '001N000000ICcIv';
        kID.Type__c = '';
        
        Key_Id__c kID1 = new Key_Id__c();
        kID1.Name = 'Account_Vendor Subscriber';
        kID1.Id__c = '012N00000008ibwIAA';
        kID1.Type__c = 'RecordType';
        
        Key_Id__c kID2 = new Key_Id__c();
        kID2.Name = 'Account_Direct Individual';
        kID2.Id__c = '012N00000008ic1IAA';
        kID2.Type__c = 'RecordType';        
        
        Key_Id__c kID3 = new Key_Id__c();
        kID3.Name = 'Contact_Customer Contact';
        kID3.Id__c = '012N00000008r43IAA';
        kID3.Type__c = 'RecordType';        
        
        Key_Id__c kID4 = new Key_Id__c();
        kID4.Name = 'Contact_Recipient Contact';
        kID4.Id__c = '012N00000008id4IAA';
        kID4.Type__c = 'RecordType';      
        
        lkID.add(kID);
        lkID.add(kID1);
        lkID.add(kID2);
        lkID.add(kID3);
        lkID.add(kID4);
        Insert lkID;
        
        //GAAC: Insert Other
        Other__c Otr = new Other__c();
        Otr.Name = 'Product_Category Digital';
        Otr.Value__c = 'Digital';
        
        Other__c Otr1 = new Other__c();
        Otr1.Name = 'Product_Category Print';
        Otr1.Value__c = 'Print';
        
        Other__c Otr2 = new Other__c();
        Otr2.Name = 'Product_Category AIO';
        Otr2.Value__c = 'All in One (AIO)';
        
        Other__c Otr3 = new Other__c();
        Otr3.Name = 'Product_Category Magazine';
        Otr3.Value__c = 'Magazine';
        
        Other__c Otr4 = new Other__c();
        Otr4.Name = 'Order_Type Start';
        Otr4.Value__c = 'Start';
        
        Other__c Otr5 = new Other__c();
        Otr5.Name = 'Order_Line_Item Neutral';
        Otr5.Value__c = 'Neutral/Flat';
        
        Other__c Otr6 = new Other__c();
        Otr6.Name = 'Reason_Code Correction';
        Otr6.Value__c = 'Correction';
        
        Other__c Otr7 = new Other__c();
        Otr7.Name = 'Order_Type COS_Quantity';
        Otr7.Value__c = 'Change of Subscription Quantity';
        
        Other__c Otr8 = new Other__c();
        Otr8.Name = 'Order_Type COS_Package';
        Otr8.Value__c = 'Change of Subscription Package';
        
        Other__c Otr9 = new Other__c();
        Otr9.Name = 'Order_Type Renewal';
        Otr9.Value__c = 'Renewal';
        
        Other__c Otr10 = new Other__c();
        Otr10.Name = 'Order_Type Stop';
        Otr10.Value__c = 'Stop';
        
        lOtr.add(Otr);
        lOtr.add(Otr1);
        lOtr.add(Otr2);
        lOtr.add(Otr3);
        lOtr.add(Otr4);
        lOtr.add(Otr5);
        lOtr.add(Otr6);
        lOtr.add(Otr7);
        lOtr.add(Otr8);
        lOtr.add(Otr9);
        lOtr.add(Otr10);
        Insert lOtr;
        
        //GAAC: Get RecordType Id
        Map<String, Id> mappedRecordType = new Map<String, Id>();
        for(RecordType crt : [SELECT Name, id FROM RecordType WHERE SObjectType =: 'Account']) {
        
            MappedRecordType.put(crt.Name, crt.id);
        }
        
        
        //GAAC: Insert Singpost Address
        Singpost_Address__c sAdd = new Singpost_Address__c();
        sAdd.Name = '1850';
        sAdd.SingPost_Key__c = 'Test Address';
        
        lsAdd.add(sAdd);
        Insert lsAdd;
        
        Key_Id__c key = new Key_Id__c();
        key.Name = 'NEXT_RECIPIENT_NUMBER';
        key.Id__c = '123457397';
        key.Type__c = 'Number';
        insert key; 


        //GAAC: Insert Address
        Address__c Add = new Address__c();
        Add.Name = 'Address1';
        Add.Postal_Code__c = sAdd.Id;
        Add.Legacy_Created_By__c = 'Glen Cubinar';
        Add.Legacy_Created_Date__c = '12/1/2015';
        Add.Legacy_Updated_By__c = 'Glen Cubinar';
        Add.Legacy_Updated_Date__c = '12/1/2015';
        
        lAdd.add(Add);
        Insert lAdd;
                
        //GAAC: Insert Account
        Account a = new Account();
        a.Name = 'accountOne';
        a.RecordTypeId = MappedRecordType.get('Vendor');
        
        lA.add(a);
        Insert lA;
        
        //GAAC: Insert Contact
        Contact c = new Contact();
        c.AccountId = a.Id;
        c.FirstName = 'Glen';
        c.LastName = 'Cubinar';
        c.Recipient_Indicator__c = TRUE;
        c.MailingPostalCode = '1850';
        c.Address__c = Add.Id;
        
        lC.add(c);
        Insert lC;
        
        //GAAC: Insert Order
        Order__c o = new Order__c();
        o.Account__c = a.Id;
        o.Order_Legacy_Id__c = '0001';
        o.Legacy_Create_Date__c = '12/1/2015';
        o.Legacy_Create_By__c = 'Glen Cubinar';
        o.Legacy_Update_Date__c = '12/1/2015';
        o.Legacy_Update_By__c= 'Glen Cubinar';
        o.Delivery_Charge__c = 10000;
        o.Monthly_Delivery_Charge_for_Full_Payment__c = 1000;
        o.Credit_Balance__c = 10000;
        o.Informed_Customer__c = TRUE;
        o.Recipient_Contact__c = c.Id;
        
        lO.add(o);
        Insert lO;      
        
        //GAAC: Insert Package
        Package__c p = new Package__c();
        p.Name = 'packageOne';
        p.Package_Type__c = 'Base';
        p.Package_Code__c = 'PCKO0001';
        p.Effective_Start_Date__c = System.Today();
        p.Effective_End_Date__c = System.Today()+1;
        
        lPck.add(p);        
        Insert lPck;
         
        //GAAC: Insert Order Line Item
        Order_Line_Item__c oLI = new Order_Line_Item__c();
        oLI.Earliest_Start_Date__c = System.Today();
        oLI.Start_Date__c = System.Today();
        oLI.Main_Package_Period__c = 100;
        oLI.Order__c = o.Id;
        oLI.Qty__c = 1;
        oLI.Term_Length__c = 10;
        oLI.Main_Package_ID__c = p.Id;
        oLI.Delivered_By__c = 'Vendor';
        oLI.Main_Package_Billing_Type__c = 'Full Prepaid';
        oLI.Main_Package_Type__c = 'Base';
        oLI.Main_Package_Sub_Type__c = 'Evergreen';
        oLI.Main_Package_Frequency__c = 'Default';

        Order_Line_Item__c oLI1 = new Order_Line_Item__c();
        oLI1.Earliest_Start_Date__c = System.Today();
        oLI1.Start_Date__c = System.Today();
        oLI1.Main_Package_Period__c = 100;
        oLI1.Order__c = o.Id;
        oLI1.Qty__c = 1;
        oLI1.Term_Length__c = 10;
        oLI1.Main_Package_ID__c = p.Id;
        oLI1.Delivered_By__c = 'Mailing Agent';
        oLI1.Main_Package_Billing_Type__c = 'Full Prepaid';
        oLI1.Main_Package_Type__c = 'Base';
        oLI1.Main_Package_Sub_Type__c = 'Evergreen';
        oLI1.Main_Package_Frequency__c = 'Default';
        
        lOLI.add(oLI1);        
        lOLI.add(oLI);
        Insert lOLI;
 
        
        //GAAC: Insert Project
        Project__c proj = new Project__c();
        proj.Name = 'Test Proj1';
        proj.Project_Description__c = 'Test';
        proj.Legacy_Created_Date__c = '12/1/2015';
        proj.Legacy_Created_By__c = 'Glen Cubinar';
        proj.Legacy_Updated_Date__c = '12/1/2015';
        proj.Legacy_Updated_By__c = 'Glen Cubinar';
        
        lproj.add(proj);
        Insert lproj;
        
        //GAAC: Insert Parcel
        Parcel__c parc = new Parcel__c();
        parc.Name = 'Parcel1';
        parc.Project_Name__c = proj.Id;
        parc.Description__c = 'Test';
        parc.Allocation_Type__c = 'Normal';
        parc.Vendor_Code__c = '00001';
        
        lparc.add(parc);
        Insert lparc;
        
        //GAAC: Insert Vendor Allocation
        Vendor_Allocation__c vAll = new Vendor_Allocation__c();
        vAll.SingPost_Address__c = sAdd.Id;
        vAll.Vendor_Account__c = a.Id;
        vAll.Legacy_Created_Date__c = '12/1/2015';
        vAll.Legacy_Updated_By__c = 'Glen Cubinar';
        vAll.Legacy_Updated_Date__c = '12/1/2015';
        vAll.Legacy_Updated_By__c = 'Glen Cubinar';
        vAll.Parcel_Name__c = parc.Id;
        vAll.Effective_Start_Date__c = System.Today();
        
        lvAll.add(vAll);
        Insert lvAll;
        
    Test.StartTest();
    
        try {
            
            List<Order_Line_Item__c> ord0 = [SELECT Id, Order__c, Delivered_By__c, Order__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name, Recipient_Postal_Code__c FROM Order_Line_Item__c WHERE Id =: oLI.id];
            List<Order_Line_Item__c> ord1 = [SELECT Id, Order__c, Delivered_By__c, Order__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name, Recipient_Postal_Code__c FROM Order_Line_Item__c WHERE Id =: oLI1.id];
            
            Vendor_Assignment vA = new Vendor_Assignment();
            vA.Assign_Vendor_To_Order_Line_Items(ord0);
            vA.Assign_Vendor_To_Order_Line_Items(ord1);
                        
        } catch (Exception e) {
        
            system.assertEquals('ERROR:', string.valueOf(e));
        }
    
    Test.StopTest();            

    }    
    
}