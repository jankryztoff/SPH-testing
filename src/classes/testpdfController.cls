public class testpdfController
{
    public string subId;
    
    public string billingContactName { get; set; }
    public string contactName { get; set; }
    public string contactMailingAddress { get; set; }
    public double paymentAmount { get; set; }
    public date expirationDate { get; set; }
    
    public string mailingBlk { get; set; }
    public string mailingStreet { get; set; }
    public string mailingLevel { get; set; }
    public string mailingUnit { get; set; }
    public string mailingBuilding { get; set; }
    public string mailingPostalCode { get; set; }
    
    public string pubCode { get; set; }
    public string giftName { get; set; }
    public string giftDescription { get; set; }
    public string subAccountNum { get; set; }
    public string accountName { get; set; }
    public string recipientName { get; set; }
    public string recAccountNum { get; set; }
    
    public string pub1 { get; set; }
    public string frequency { get; set; }
    public double numberOfCopies { get; set; }
    public string subscriptionExpiry { get; set; }
    
    public string rCode1Sub { get; set; }
    public string rCode1Disc { get; set; }
    public string rCode2Sub { get; set; }
    public string rCode2Disc { get; set; }
    
    public string acct { get; set; }
    
    public List<Zuora__Subscription__c> z { get; set; }
    public Map<Id, Set<String>> sMap { get; set; }
    public Map<Id, Set<String>> pMap1 { get; set; }
    public Map<Id, Set<String>> pMap2 { get; set; }
    public Map<Id, Set<String>> pMap3 { get; set; }
    public Map<Id, Set<String>> pMap4 { get; set; }
    
    public testpdfController()
    {
        subId = ApexPages.currentPage().getParameters().get('subscriptionId');
        //subId = 'a0XN0000000bfNyMAI'; //BA-S00000190
    }

    public Date Today 
    { 
        get 
        { 
            return Date.Today(); 
        }
    }
    
    public void initialize()
    {
        //setContactDetails();
        setFields();
    }
    
    public void setFields()
    {
        Zuora__Subscription__c zSub;
        
        zSub = [SELECT Subscriber_Contact__c, Recipient_Contact__c, 
                       Recipient_Contact__r.Name, Contact__r.Name, 
                       Order_Number_1__c, Zuora__Account__r.Name, 
                       Order_Line_Item_Number_1__c, Frequency_1__c, Number_of_Copies__c, 
                       Subscription_End_Date__c, Main_Package_1__c,
                       Contact__r.Address__r.Block_House_Number__c,
                       Contact__r.Address__r.Postal_Code__r.Street_Name__c,
                       Contact__r.Address__r.Level_Number__c,
                       Contact__r.Address__r.Unit_Number__c,
                       Contact__r.Address__r.Postal_Code__r.Building_Name__c,
                       Contact__r.Address__r.Postal_Code__r.Name,
                       Subscriber_Contact__r.Account.AccountNumber,
                       Zuora__Account__c
                FROM Zuora__Subscription__c WHERE Id =: subId];
        
        //subAccountNum = subAcc.AccountNumber;
        subAccountNum = zSub.Subscriber_Contact__r.Account.AccountNumber;
        accountName = zSub.Zuora__Account__r.Name;
        recipientName = zSub.Recipient_Contact__r.Name;
        
        acct = zSub.Zuora__Account__c;
        
        
        
        
        billingContactName = zSub.Contact__r.Name;
                      
        if(zSub.Contact__r.Address__r.Block_House_Number__c != Null)
        {
            mailingBlk = zSub.Contact__r.Address__r.Block_House_Number__c;
        }
        else
        {
            mailingBlk = 'No Blk';
        }
        
        if(zSub.Contact__r.Address__r.Postal_Code__r.Street_Name__c != Null)
        {
            mailingStreet = zSub.Contact__r.Address__r.Postal_Code__r.Street_Name__c;
        }
        else
        {
            mailingStreet = 'No Street';
        }
        
        if(zSub.Contact__r.Address__r.Level_Number__c != Null)
        {
            mailingLevel = zSub.Contact__r.Address__r.Level_Number__c;
        }
        else
        {
            mailingLevel = 'No Level';
        }
        
        if(zSub.Contact__r.Address__r.Unit_Number__c != Null)
        {
            mailingUnit = zSub.Contact__r.Address__r.Unit_Number__c;
        }
        else
        {
            mailingUnit = 'No Unit';
        }
        
        if(zSub.Contact__r.Address__r.Postal_Code__r.Building_Name__c != Null)
        {
            mailingBuilding = zSub.Contact__r.Address__r.Postal_Code__r.Building_Name__c;
        }
        else
        {
            mailingBuilding = 'No Building';
        }
        
        if(zSub.Contact__r.Address__r.Postal_Code__r.Name != Null)
        {
            mailingPostalCode = zSub.Contact__r.Address__r.Postal_Code__r.Name;
        }
        else
        {
            mailingPostalCode = 'No Postal Code';
        }
        //////////////////////////////////////////////////////////////////getting the publication code
        Order_Line_Item__c olItem;
        Publication__c pub;
        Package_Item__c pi;
        
        olItem = [SELECT Publication_1__c FROM Order_Line_Item__c WHERE Id =: zSub.Order_Line_Item_Number_1__c];
        pub = [SELECT Publication_Code__c FROM Publication__c WHERE Name =: olItem.Publication_1__c];
        pub1 = pub.Publication_Code__c;
        ///////////////////////////////////////////////////////////////////////getting the frequency
        frequency = zSub.Frequency_1__c.toUpperCase();
        ///////////////////////////////////////////////////////////////////////getting the number of copies
        numberOfCopies = zSub.Number_of_Copies__c;
        ///////////////////////////////////////////////////////////////////////getting expiration date
        subscriptionExpiry = zSub.Subscription_End_Date__c;
        ///////////////////////////////////////////////////////////////////////getting renewal values
        /*pi = [SELECT RenewalPkgCodeMag1YrBase__c, RenewalPkgCodeMag1YrDisc__c, RenewalPkgCodeMag2YrBase__c, RenewalPkgCodeMag2YrDisc__c FROM Package_Item__c WHERE Package__c =: zSub.Main_Package_1__c];
        rCode1Sub = pi.RenewalPkgCodeMag1YrBase__c;
        rCode1Disc = pi.RenewalPkgCodeMag1YrDisc__c;
        rCode2Sub = pi.RenewalPkgCodeMag2YrBase__c;
        rCode2Disc = pi.RenewalPkgCodeMag2YrDisc__c;*/
        
        //////////////////////////////////////////////////////////////////
        Set<Id> setZuoraId = new Set<Id>(); 
        sMap = new Map<Id, Set<String>>();
        
        Set<Id> setPackageId = new Set<Id>();
        pMap1 = new Map<Id, Set<String>>(); 
        pMap2 = new Map<Id, Set<String>>();
        pMap3 = new Map<Id, Set<String>>();
        pMap4 = new Map<Id, Set<String>>();
        
        z = [SELECT Id, Subscriber_Contact__c, Recipient_Contact__c, 
                     Recipient_Contact__r.Name, Contact__r.Name,
                     Main_Package_1__r.Name, 
                     Order_Number_1__c, Zuora__Account__r.Name, 
                     Order_Line_Item_Number_1__c, Frequency_1__c, Number_of_Copies__c, 
                     Subscription_End_Date__c, Main_Package_1__c,
                     Contact__r.Address__r.Block_House_Number__c,
                     Contact__r.Address__r.Postal_Code__r.Street_Name__c,
                     Contact__r.Address__r.Level_Number__c,
                     Contact__r.Address__r.Unit_Number__c,
                     Contact__r.Address__r.Postal_Code__r.Building_Name__c,
                     Contact__r.Address__r.Postal_Code__r.Name,
                     Subscriber_Contact__r.Account.AccountNumber
              FROM Zuora__Subscription__c WHERE Zuora__Account__c =: acct];
              
        for(Zuora__Subscription__c zs : z)
        {
            setZuoraId.add(zs.Id);
            setPackageId.add(zs.Main_Package_1__c);
        }  
        
        List<Zuora__SubscriptionProductCharge__c> SPCList = [SELECT PublicationCode__c, Zuora__Subscription__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c IN : setZuoraId];          
        for(Zuora__SubscriptionProductCharge__c spc : SPCList)
        {
            if(sMap.containsKey(spc.Zuora__Subscription__c))
            {
                sMap.get(spc.Zuora__Subscription__c).add(spc.PublicationCode__c);
            }
            else
            {
                sMap.put(spc.Zuora__Subscription__c, new Set<String> {spc.PublicationCode__c});
            }
        }
        //////////////////////////////////////////////////////////////////
        // START : UD-3048 11/11/2015 Alyana Navarro 
        List<Package_Item__c> PIList = new List<Package_Item__c>(); 
        PIList = [SELECT Id, Package__c FROM Package_Item__c WHERE Package__c IN : setPackageId];
        for(Package_Item__c pil : PIList)
        {
            /*if(pMap1.containsKey(pil.Package__c) || pMap2.containsKey(pil.Package__c) || pMap3.containsKey(pil.Package__c) || pMap4.containsKey(pil.Package__c))
            //if(pMap.containsKey(pil.Package__c))
            {
                pMap1.get(pil.Package__c).add(pil.RenewalPkgCodeMag1YrDisc__r.Package_Code__c);
                pMap2.get(pil.Package__c).add(pil.RenewalPkgCodeMag1YrBase__r.Package_Code__c);
                pMap3.get(pil.Package__c).add(pil.RenewalPkgCodeMag2YrBase__r.Package_Code__c);
                pMap4.get(pil.Package__c).add(pil.RenewalPkgCodeMag2YrDisc__r.Package_Code__c);
            }
            else
            {
                pMap1.put(pil.Package__c, new Set<String> {pil.RenewalPkgCodeMag1YrBase__r.Package_Code__c});
                //pMap.put(pil.Package__c, new Set<String> {pil.RenewalPkgCodeMag1YrDisc__c});
                pMap2.put(pil.Package__c, new Set<String> {pil.RenewalPkgCodeMag1YrDisc__r.Package_Code__c});
                //pMap2.put(pil.Package__c, new Set<String> {pil.RenewalPkgCodeMag2YrDisc__c});
                pMap3.put(pil.Package__c, new Set<String> {pil.RenewalPkgCodeMag2YrBase__r.Package_Code__c});
                pMap4.put(pil.Package__c, new Set<String> {pil.RenewalPkgCodeMag2YrDisc__r.Package_Code__c});
            }*/
        }
        // END : UD-3048 11/11/2015 Alyana Navarro     
    } 
}