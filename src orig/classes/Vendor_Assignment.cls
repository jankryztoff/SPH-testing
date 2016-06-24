/**
 * Class Name: Vendor_Assignment
 * @author: Eugene Basiano Mutya
 * Date: 8/10/2014
 * Requirement/Project Name: SPH Project
 * @description : After the Order Line Item is submitted, the vendor/mailing agent is assigned to Order line items 
            so that it will reflect in Quote and Subscription. Assignment is based on the recipient postal code compare 
            against the vendor allocation
 * History: 03/16/15 D-2284 Kevin Evasco - ApexPages.addMessage will only be executed for VF Page calls.
 * History: 03/Aug/15 D-3382 CCB-135 Wenjun - Mailing Agent Assignment Logic & Code Optimization
 * History: 03/Aug/15 D-3423 Wenjun - Moving all assignment logic to this class. This is to handle the change in Deliveryed by in COS/Renewal
 */

public class Vendor_Assignment {
    
    public final String MAILING_AGENT = GlobalVariableClass.OLIDELIVEREDBY_MAILING_AGENT;
    public final String LOCAL = GlobalVariableClass.STRING_LOCAL;
    public final String OVERSEAS = GlobalVariableClass.STRING_OVERSEAS;
    public final String INTERNAL = GlobalVariableClass.STRING_INTERNAL;
    public final String DIGITAL = GlobalVariableClass.DIGITAL;
    
    public final Id MAILING_AGENT_RECORDTYPE_ID = ConstantsSLB.getKeyId('Account_Mailing Agent'); //START/END 04 November 2015 D-3865 Kevin Evasco - Non-selective query fix

    // Assign Vendor/Mailing Agent to Order Line Items of Vendor Subscription
    Public void Assign_Vendor_To_Order_line_Items(List<Order_Line_Item_Vendor__c> lOrderLineItems){
        
        Set<string> setPostalCodes = new Set<string>();
        Set<ID> setPubIDs = new Set<ID>();
        List<Order_Line_Item_Vendor__c> lstOliToUpd = new List<Order_Line_Item_Vendor__c> ();
        
        for(Order_Line_Item_Vendor__c oli: lOrderLineItems){
            setPostalCodes.add(oli.Recipient_Postal_Code__c);
            setPubIDs.add(oli.Publication__c);
        }
        
        if(!setPostalCodes.isEmpty() && !setPubIDs.isEmpty())
        {
            Set<ID> setPubByMailing = new Set<ID>();
            Map<String, List<ID>> mapCodeToVenLst = getVendorAllocations(setPostalCodes);
            Map<String, ID> mapAgentAssignment = new Map<String, ID>();
            
            //Get Publications delviered by Mailing Agent
            for (Publication__c pub :[SELECT Id from Publication__c where Id in :setPubIDs and Vendor_Sub_Delivery_Method__c = :MAILING_AGENT])
            {
                setPubByMailing.add(pub.ID);
            }
            
            if(!setPubByMailing.isEmpty())  
                mapAgentAssignment = getMailingAgents();
                
            for(Order_Line_Item_Vendor__c oli: lOrderLineItems)
            {
                //Check if Pub is to be delviered by Mailing Agent
                if(setPubByMailing.contains(oli.Publication__c))
                {
                    String addressType = oli.Order__r.Recipient_Contact__r.Address__r.Recordtype.DeveloperName;
                    if(mapAgentAssignment.containskey(addressType))
                    {
                        oli.Vendor__c = mapAgentAssignment.get(addressType);
                        lstOliToUpd.add(oli);
                    }           
                }
                else
                {
                    String strCode = oli.Recipient_Postal_Code__c;
                    //Assign vendor if there is one and only one vendor for the Postal Code
                    if(mapCodeToVenLst.containskey(strCode) && mapCodeToVenLst.get(strCode).size() == 1)
                    {
                      oli.Vendor__c = mapCodeToVenLst.get(strCode).get(0);
                      lstOliToUpd.add(oli);
                    } 
                }               
            }
            
            if (!lstOliToUpd.isEmpty())
                update lstOliToUpd;  
        }       
    }
        
    // Assign Vendor to Order Line Items of Direct Subscription and auto assign Mailing Agent for Local / Internal / Overseas
    Public void Assign_Vendor_To_Order_Line_Items(List<Order_Line_Item__c> lOrderLineItems){
        
        List<Order_Line_Item__c> lstOliToUpd = new List<Order_Line_Item__c>();

        //For COS/Renewal Vendor to Vendor, reuse existing Vendor assigned
        List<Order_Line_Item__c> lstReuseV = new List<Order_Line_Item__c>();
        //For Olis with Delivered By as "Mailing Agent", go thru Mailing Agentment logic
        List<Order_Line_Item__c> lstAssignM = new List<Order_Line_Item__c>();
        //For Start or COS/Renewal Mailing Agent to Vendor, go thru Vendor Agentment logic
        List<Order_Line_Item__c> lstAssignV = new List<Order_Line_Item__c>();
        
        //Categorize the Olis
        for(Order_Line_Item__c oli: lOrderLineItems)
        {
            if(oli.Delivered_By__c == MAILING_AGENT)
            {
                lstAssignM.add(oli);
            }
            else if(oli.Delivered_By__c == 'Vendor' && oli.Case__r.Subscription_Name__c != NULL 
            && 'Vendor' == oli.Case__r.Subscription_Name__r.Delivered_By_1__c && oli.Case__r.Subscription_Name__r.Vendor_1__c != NULL)
            {
                lstReuseV.add(oli);
            }
            else if(oli.Delivered_By__c == 'Vendor')
            {
                lstAssignV.add(oli);
            }
        }
        
        if(!lstAssignM.isEmpty())
            lstOliToUpd.addAll(assignMailingAgent(lstAssignM));
        
        if(!lstReuseV.isEmpty())
            lstOliToUpd.addAll(assignExistingVendor(lstReuseV));
        
        if(!lstAssignV.isEmpty())
            lstOliToUpd.addAll(assignNewVendor(lstAssignV));
        
        if (!lstOliToUpd.isEmpty())
        {
            //Create OLI Map
            Map<ID, Order_Line_Item__c> mapOli = new Map<ID, Order_Line_Item__c>();
            
            for(Order_Line_Item__c oli:lstOliToUpd)
            {
                mapOli.put(oli.ID, oli);
            }
            
            //Fetch quotes to update - ignore quotes already have vendor/mailing-agent assigned (i.e. Bundle Pakcage Overrite)
            List<zqu__Quote__c> lstQuotes = [SELECT ID, Name, Vendor__c, Order_Line_Item_Number_1__c From zqu__Quote__c 
                                    WHERE Order_Line_Item_Number_1__c in :lstOliToUpd AND Vendor__c = NULL];
            
            for(zqu__Quote__c quote : lstQuotes)
            {
                quote.Vendor__c = mapOli.get(quote.Order_Line_Item_Number_1__c).Vendor_Mailing_Agent__c;
            }
            
            UPDATE lstQuotes;
            UPDATE lstOliToUpd;  
        }

    }

    public List<Order_Line_Item__c> assignMailingAgent(List<Order_Line_Item__c> lstOliToAssign)
    {
        List<Order_Line_Item__c> lstResult = new List<Order_Line_Item__c>();
        Map<String, ID> mapAgentAssignment = getMailingAgents();
        
        for(Order_Line_Item__c oli : lstOliToAssign)
        {
            //Check if the Order Line Item is digital
            if(oli.Main_Package_Product_Platform__c == GlobalVariableClass.PLATFORM_PRINT || oli.Main_Package_Product_Platform__c == GlobalVariableClass.PLATFORM_AIO)
            {
                String addressType = oli.Order__r.Recipient_Contact__r.Address__r.Recordtype.DeveloperName;
                if(mapAgentAssignment.containskey(addressType))
                {
                    oli.Vendor_Mailing_Agent__c = mapAgentAssignment.get(addressType);
                    lstResult.add(oli);
                }
            }
            else //Digital
            {
                if(mapAgentAssignment.containskey(DIGITAL))
                {
                    oli.Vendor_Mailing_Agent__c = mapAgentAssignment.get(DIGITAL);
                    lstResult.add(oli);
                }
            }
        }
        
        return lstResult;
    }
    
    public List<Order_Line_Item__c> assignExistingVendor(List<Order_Line_Item__c> lstOliToAssign)
    {
        List<Order_Line_Item__c> lstResult = new List<Order_Line_Item__c>();
        
        for(Order_Line_Item__c oli : lstOliToAssign)
        {
            oli.Vendor_Mailing_Agent__c = oli.Case__r.Subscription_Name__r.Vendor_1__c; 
            lstResult.add(oli);
        }
        
        return lstResult;
    }
    
    public List<Order_Line_Item__c> assignNewVendor(List<Order_Line_Item__c> lstOliToAssign)
    {
        List<Order_Line_Item__c> lstResult = new List<Order_Line_Item__c>();
        
        // Gather Postal Codes of Recipients
        Set<String> setPostalCodes = new Set<String>(); 
        Map<String, List<ID>> mapCodeToVenLst = new Map<String, List<ID>>();
        
        for(Order_Line_Item__c oli : lstOliToAssign)
        {
            setPostalCodes.add(oli.Recipient_Postal_Code__c);
        }
        mapCodeToVenLst = getVendorAllocations(setPostalCodes);
        
        //Assign Vendor or Mailing Agent    
        for(Order_Line_Item__c oli: lstOliToAssign)
        {
            String strCode = oli.Recipient_Postal_Code__c;
            //Assign vendor if there is one and only one vendor for the Postal Code
            if(mapCodeToVenLst.containskey(strCode) && mapCodeToVenLst.get(strCode).size() == 1)
            {
              oli.Vendor_Mailing_Agent__c = mapCodeToVenLst.get(strCode).get(0);
              lstResult.add(oli);
            }             
        }
        
        return lstResult;
    }
    
    //Get Vendor Allocation Records
    public Map<String, List<ID>> getVendorAllocations(Set<String> setCodes)
    {
        Map<String, List<ID>> mapCodeToVenLst = new Map<String, List<ID>>();
        
        for(Vendor_Allocation__c allocRec : [SELECT SingPost_Address__r.Name,  Vendor_Account__c FROM Vendor_Allocation__c 
                                            WHERE SingPost_Address__r.Name IN :setCodes and Status__c='Active'])
        {
            String strPostalCode = allocRec.SingPost_Address__r.Name;
            if(mapCodeToVenLst.containsKey(strPostalCode))
                mapCodeToVenLst.get(strPostalCode).add(allocRec.Vendor_Account__c);
            else
                mapCodeToVenLst.put(strPostalCode, new List<ID> {allocRec.Vendor_Account__c});
        }
        return mapCodeToVenLst;
    }
    
    //Assign Mailing Agent for Local / Internal / Overseas. 
    //Airline is only supported in CSO Channel and will be selected from UI
    public Map<String, ID> getMailingAgents()
    {
        Map<String, ID> mapAgentAssignment = new Map<String, ID>();
        for(Account mAgent : [SELECT ID, Name, Type FROM ACCOUNT 
                             WHERE RecordTypeId = :MAILING_AGENT_RECORDTYPE_ID and Active__c = true]) //START/END 04 November 2015 D-3865 Kevin Evasco - Non-selective query fix
         {
             if( LOCAL == mAgent.type)
                 mapAgentAssignment.put(LOCAL, mAgent.ID);
             else if( OVERSEAS == mAgent.type)
                 mapAgentAssignment.put(OVERSEAS, mAgent.ID);
             else if( INTERNAL == mAgent.type)
                 mapAgentAssignment.put(INTERNAL, mAgent.ID);
             else if( DIGITAL == mAgent.type)
                 mapAgentAssignment.put(DIGITAL, mAgent.ID);
         }
        return mapAgentAssignment;
    }
}