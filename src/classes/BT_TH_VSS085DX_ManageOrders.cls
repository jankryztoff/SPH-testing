/**
 * Trigger Name: BT_TH_VSS085DX_ManageOrders
 * Author: Renino Niefes
 * Date: 2015/05/22
 * Project/Requirement: SPH Integration - VSS085DX Interface
 * Description: This trigger contains the business logic for VSS085DX interface.
 * History: 2015/05/22 Renino Niefes broken down the original code into multiple Trigger Handlers
 * History: 2015/06/03 Renino Niefes hotfix (not yet confirmed by Nitin) only add orders/order line items if the subs indicator is A
 * History: 2015/09/24 Renino Niefes D-3606 RETROFIT ONLY. NO CODE CHANGE BELOW 
 */
 
 
public class BT_TH_VSS085DX_ManageOrders
{   
    public void execute(List<BT_CO_VSS_ImportVendorSubscription__c> recordsList, BT_TH_VSS085DX_ManageMaps mapManager) {
        List<Subscription_Vendor_Publication__c> newSVPList = null;
        newSVPList = mapManager.getSubVenPubListForInsert();
        Map<String, Account> hdsAccountsMap = null;
        Map<String, Contact> contactsMap = null;
        Map<String, Account> vendorMap = null;
        Map<String, Publication__c> publicationMap = mapManager.getPublicationMap();
        Map<String, Subscription_Vendor_Publication__c> newSVPMap = new Map<String, Subscription_Vendor_Publication__c>();
        Set<String> hdsRecipientIDSet = new Set<String>();
        
        List<Order__c> ordersForInsert = new List<Order__c>();
        List<Order_Line_Item_Vendor__c> orderItemsForInsert = new List<Order_Line_Item_Vendor__c>();
        
        hdsAccountsMap = mapManager.getAccountsMapByHDSRecipientId(null, false);
        contactsMap = mapManager.getContactsMap(null,false);
        vendorMap = mapManager.getVendorMap(null);
        
        System.debug('VSS085DX: r1 ');
        for (Subscription_Vendor_Publication__c svpRec : newSVPList) {
            newSVPMap.put(svpRec.HDS_Subscription_Id__c, svpRec);
            System.debug('VSS085DX: r2 ' + svpRec.HDS_Subscription_Id__c);
        }
        
        System.debug('VSS085DX: r3 ');
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            System.debug('VSS085DX: r4 ');
            String vHdsRecipientId = so.HdsRecipientId__c;
            String vHdsContactId = so.HdsContactId__c;
            String vHdsSubscriptionId = so.HdsSubscriptionId__c;
            String vStartDate = so.StartDate__c;
            String vSubscriptionUpdateIndicator = so.SubscriptionUpdateIndicator__c;
            
            if (vSubscriptionUpdateIndicator.equalsIgnoreCase('A')) {
                if (newSVPMap.containsKey(vHdsSubscriptionId)) {            
                    System.debug('VSS085DX: r5 ');
                    Subscription_Vendor_Publication__c svpRec = newSVPMap.get(vHdsSubscriptionId);

                    Account accountRecord = hdsAccountsMap.get(vHdsRecipientId);
                    Contact contactRecord = contactsMap.get(vHdsContactId);
                    
                    //Create Order
                    if (!hdsRecipientIDSet.contains(vHdsRecipientId)) {
                        System.debug('VSS085DX: r6 ');
                    
                        Order__c newOrder = new Order__c();                 
                        newOrder.Account__c = accountRecord.Id;
                        if (vStartDate!=null&&vStartDate.trim()!='') newOrder.DTL_Date__c = DateUtility.convertDate(vStartDate,'\\.','DMY');
                        newOrder.Recipient_Contact__c = contactRecord.Id;
                        newOrder.Status__c = 'New';
                        newOrder.Delivery_Charge__c = 0.0;
                        newOrder.Reason__c = vHdsRecipientId;
                        newOrder.Credit_Balance__c = 0.0;
                        
                        ordersForInsert.add(newOrder);
                    }
                    
                    hdsRecipientIDSet.add(vHdsRecipientId);
                }
            }
            
        }
        
        //Savepoint savepointBeforeDML = Database.setSavepoint();
        try {
            insert ordersForInsert;
        } catch(Exception e) {    
            //Database.rollback(savepointBeforeDML);
            BT_CO_INT_Utilities.log('VSS085DX: Manage Orders Processing Failed.' + e.getMessage());
        }
        
        Map<String, Order__c> hdsRecipientIDOrderMap = new Map<String, Order__c>();
        for (Order__c order : ordersForInsert) {
            hdsRecipientIDOrderMap.put(order.Reason__c, order);
            System.debug('VSS085DX: r7 ' + order.Reason__c + ' ' + order.ID);
        }
        
        
        for(BT_CO_VSS_ImportVendorSubscription__c so : recordsList) {
            System.debug('VSS085DX: r8 ');
            String vHdsRecipientId = so.HdsRecipientId__c;
            String vHdsContactId = so.HdsContactId__c;
            String vHdsSubscriptionId = so.HdsSubscriptionId__c;
            String vPublicationCode = so.PublicationCode__c;
            String vSubscriptionCopies = so.SubscriptionCopies__c;
            String vStartDate = so.StartDate__c;
            String vStopDate = so.StopDate__c;
            String vVendorNumber = so.VendorNumber__c;
            String vSubscriptionUpdateIndicator = so.SubscriptionUpdateIndicator__c;
            
            if (vSubscriptionUpdateIndicator.equalsIgnoreCase('A')) {
                if (newSVPMap.containsKey(vHdsSubscriptionId)) {
                    System.debug('VSS085DX: r9 ');
                    Account vendorRecord = vendorMap.get(vVendorNumber);
                    Publication__c publication = publicationMap.get(vPublicationCode);
                    Order__c order = hdsRecipientIDOrderMap.get(vHdsRecipientId);
                    Subscription_Vendor_Publication__c svpRecord = newSVPMap.get(vHdsSubscriptionId);
                    
                    Order_Line_Item_Vendor__c orderLine = new Order_Line_Item_Vendor__c();
                    //orderLine.Order__c
                    //if (vStartDate!=null&&vStartDate.trim()!='') orderLine.DTL_Date__c = DateUtility.convertDate(vStartDate,'\\.','DMY');
                    //if (vStartDate!=null&&vStartDate.trim()!='') orderLine.Start_Date__c = DateUtility.convertDate(vStartDate,'\\.','DMY');
                    //if (vStopDate!=null&&vStopDate.trim()!='') orderLine.Stop_Date__c = DateUtility.convertDate(vStopDate,'\\.','DMY');                       
                    orderLine.DTL_Date__c = Date.Today();
                    orderLine.Start_Date__c = Date.Today().addDays(1);
                    orderLine.Vendor__c = vendorRecord.Id;              
                    orderLine.Publication__c = publication.Id;
                    orderLine.Order__c = order.Id;
                    orderLine.Subscription_Vendor_Publication__c = svpRecord.ID;
                    orderLine.Subscription_Vendor__c = svpRecord.Subscription_Vendor__r.ID;
                    
                    Decimal vMon = null;
                    Decimal vTue = null;
                    Decimal vWed = null;
                    Decimal vThu = null;
                    Decimal vFri = null;
                    Decimal vSat = null;
                    Decimal vSun = null;
                    Decimal vPHd = null;
                    Decimal vPHe = null;
                                
                    try {
                        vMon = Decimal.valueOf(vSubscriptionCopies.subString(0,3));
                        vTue = Decimal.valueOf(vSubscriptionCopies.subString(3,6));
                        vWed = Decimal.valueOf(vSubscriptionCopies.subString(6,9));
                        vThu = Decimal.valueOf(vSubscriptionCopies.subString(9,12));
                        vFri = Decimal.valueOf(vSubscriptionCopies.subString(12,15));
                        vSat = Decimal.valueOf(vSubscriptionCopies.subString(15,18));
                        vSun = Decimal.valueOf(vSubscriptionCopies.subString(18,21));
                        vPHd = Decimal.valueOf(vSubscriptionCopies.subString(21,24));
                        vPHe = Decimal.valueOf(vSubscriptionCopies.subString(24,27));
                        
                        orderLine.Mon__c = vMon;
                        orderLine.Tue__c = vTue;
                        orderLine.Wed__c = vWed;
                        orderLine.Thu__c = vThu;
                        orderLine.Fri__c = vFri;
                        orderLine.Sat__c = vSat;
                        orderLine.Sun__c = vSun;
                        orderLine.PHd__c = vPHd;
                        orderLine.PHe__c = vPHe;
                        
                    } catch (Exception e) {
                        BT_CO_INT_Utilities.log('VSS085DX: Error parsing Subscription Copies ' + e.getMessage());
                        System.debug('VSS085DX: r10 ');
                    }
                    
                    orderItemsForInsert.add(orderLine);
                    
                }
            }
        }
        
        Savepoint savepointBeforeDML2 = Database.setSavepoint();
        try {
            insert orderItemsForInsert;
        } catch(Exception e) {    
            Database.rollback(savepointBeforeDML2);
            BT_CO_INT_Utilities.log('VSS085DX: Manage Orders Items Processing Failed.' + e.getMessage());
        }       
    }
        
}