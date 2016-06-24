/*
 * @description: this method will calculate the applicable delivery charge for full-prepaid transaction.
 *      this will cater different scenarios
 *      1. multiple order line items with the same start and end dates (year-month)
 *      2. over lapping start/end dates
 *      3. existing full delivery subscription
 */
@isTest
public class FullPrepaidDeliveryChargeCalculator_test {
    
    // Start D-2809 05May15 JohnD - added variables
    static date latestStartDate;
    static date latestEndDate;
    static date currentStartDate;
    static date currentEndDate;
    static date endDate;
    static date startDate;
    // End D-2809 05May15 JohnD - added variables
    
    /*
     * @description: this method will calculate the applicable delivery charge and create usages if applicable.
     *      this method is invoke from subscriptiontriggerhandler
     * @param lstSub : list of newly created subscriptions
     * @return: list of temporarily modified subscriptions values to be used in creating the usages. 
     *      the changes will not be saved 
     * 
     */
    public static list<Zuora__Subscription__c> calculate(list<Zuora__Subscription__c> lstSub) {

        // Start D-2809 06May15 JohnD - variable re-organinzation
        map<string, list<Zuora__Subscription__c>> uniqueIdentifier_deliverySubscriptionList = new map<string, list<Zuora__Subscription__c>>();
        map<string, Zuora__Subscription__c> uniqueIdentifier_latestExistingFullDelSub = new map<string, Zuora__Subscription__c>();
        map<string, Zuora__Subscription__c> uniqueIdentifier_EarliestExistingFullDelSub = new map<string, Zuora__Subscription__c>();
        map<id, date> subscriptionId_startDate = new map<id, date>(); // Start/End D-2809 06May15 JohnD
        list<Zuora__Subscription__c> filteredSubscriptionList = new list<Zuora__Subscription__c>();
        list<Zuora__Subscription__c> deliverySubscriptionList;
        set<id> accountIdSet = new set<id>();
        set<id> deliverySubscriptionIdSet = new set<id>();
        set<string> recipientAddressSet = new set<string>();
        Zuora__Subscription__c latestFullDelSub;
        Zuora__Subscription__c earliestFullDelSub;
        integer lastIndex;
        string uniqueIdentifier;
        
        // Start D-2809 06May15 JohnD commented out no longer used
        /* 
        integer yearMonthStartX;
        integer yearMonthStartY;
        integer yearMonthEndX;
        integer yearMonthEndY;
        */
        // End D-2809 06May15 JohnD commented out no longer used
        // End D-2809 06May15 JohnD - variable re-organinzation
        for (Zuora__Subscription__c sub : lstSub) {
            
            if (sub.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_POSTAGE) {
            
                filteredSubscriptionList.add(sub);
            
            } else if (sub.Subscription_Type_1__c == GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY) {
                
                deliverySubscriptionIdSet.add(sub.Id);
                
                if (sub.Zuora__Account__c != null) {
                    accountIdSet.add(sub.Zuora__Account__c);
                }
            }
        }
        
        // start retrieve existing full-prepaid delivery subscriptions
        for (Zuora__Subscription__c sub : [select Id, Zuora__Account__c, Recipient_Contact__r.Address__c, 
                Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c from Zuora__Subscription__c 
                where Zuora__Account__c in : accountIdSet and Subscription_Type_1__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY 
                and Billing_Type__c = :GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID 
                and Zuora__Status__c = :GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE 
                order by Zuora__SubscriptionEndDate__c desc]) {
            
            if (!deliverySubscriptionIdSet.contains(sub.Id)) {
                if (sub.Zuora__Account__c != null && sub.Recipient_Contact__r.Address__c != null) {
                    
                    uniqueIdentifier = sub.Zuora__Account__c + '' + sub.Recipient_Contact__r.Address__c;
                    
                    if (uniqueIdentifier_latestExistingFullDelSub != null && !uniqueIdentifier_latestExistingFullDelSub.keySet().contains(uniqueIdentifier)) {
                        uniqueIdentifier_latestExistingFullDelSub.put(uniqueIdentifier, sub);
                    }
                    
                    uniqueIdentifier_EarliestExistingFullDelSub.put(uniqueIdentifier, sub);
                }
            }
        }
        // end retrieve existing full-prepaid delivery subscriptions
        
        // start retrieve new full-prepaid deliver susbscriptions     
        for (Zuora__Subscription__c sub : [select Id, Subscription_Type_1__c, Order_Number_1__c, Zuora__SubscriptionStartDate__c,
                Term_Length__c, Name, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, Zuora__Account__c, Zuora__SubscriptionEndDate__c, 
                Recipient_Contact__r.Address__c from Zuora__Subscription__c where Id in :deliverySubscriptionIdSet 
                order by Zuora__SubscriptionStartDate__c asc]) {
            
            // Start D-2809 06May15 JohnD commented out no longer used
            /*
            yearMonthStartX = sub.Zuora__SubscriptionStartDate__c.year() + sub.Zuora__SubscriptionStartDate__c.month();
            yearMonthEndX = sub.Zuora__SubscriptionEndDate__c.year() + sub.Zuora__SubscriptionEndDate__c.month();
            */
            // End D-2809 06May15 JohnD commented out no longer used
            
            // Start D-2809 06May15 JohnD - added variable assignments
            startDate = sub.Zuora__SubscriptionStartDate__c;
            endDate = sub.Zuora__SubscriptionEndDate__c;
            currentStartDate = sub.Zuora__SubscriptionStartDate__c.toStartOfMonth();
            currentEndDate = sub.Zuora__SubscriptionEndDate__c.toStartOfMonth();
            latestStartDate = sub.Zuora__SubscriptionStartDate__c;
            subscriptionId_startDate.put(sub.Id, sub.Zuora__SubscriptionStartDate__c);
            // End D-2809 06May15 JohnD - added variable assignments
            
            if (sub.Zuora__Account__c != null && sub.Recipient_Contact__r.Address__c != null) {
                
                uniqueIdentifier = sub.Zuora__Account__c + '' + sub.Recipient_Contact__r.Address__c;
                deliverySubscriptionList = new list<Zuora__Subscription__c>();
                
                // start first record of each account
                if (uniqueIdentifier_deliverySubscriptionList.get(uniqueIdentifier) == null) {
                    
                    latestFullDelSub = uniqueIdentifier_latestExistingFullDelSub.get(uniqueIdentifier);
                    earliestFullDelSub = uniqueIdentifier_earliestExistingFullDelSub.get(uniqueIdentifier);
                    
                    if (latestFullDelSub == null) {
                        
                        deliverySubscriptionList.add(sub);
                        
                    } else {

                        // Start D-2809 06May15 JohnD commented out no longer used
                        /*
                        yearMonthStartY = earliestFullDelSub.Zuora__SubscriptionStartDate__c.year() + earliestFullDelSub.Zuora__SubscriptionStartDate__c.month();
                        yearMonthEndY = latestFullDelSub.Zuora__SubscriptionEndDate__c.year() + latestFullDelSub.Zuora__SubscriptionEndDate__c.month();
                        */
                        // End D-2809 06May15 JohnD commented out no longer used
                        
                        // Start D-2809 06May15 JohnD - update existing logic in computing the term length for overlapping dates
                        latestStartDate = earliestFullDelSub.Zuora__SubscriptionStartDate__c.toStartOfMonth();
                        latestEndDate = latestFullDelSub.Zuora__SubscriptionEndDate__c.toStartOfMonth();
                        
                        if (latestStartDate > currentStartDate) {
                            
                            if (latestStartDate < currentEndDate) {
                                sub.Zuora__SubscriptionEndDate__c = earliestFullDelSub.Zuora__SubscriptionStartDate__c.addMonths(1);
                            }
                            
                            sub.Term_Length__c = sub.Zuora__SubscriptionStartDate__c.monthsBetween(sub.Zuora__SubscriptionEndDate__c);
                            deliverySubscriptionList.add(sub);
                        }
 
                        if (latestEndDate < currentEndDate) {
                            
                            // Start 07May15
                            if (latestEndDate > currentStartDate) {
                                sub.Zuora__SubscriptionStartDate__c = latestFullDelSub.Zuora__SubscriptionEndDate__c;
                            }
                            // End 07May15
                            
                            sub.Zuora__SubscriptionEndDate__c = endDate;
                            sub.Term_Length__c = sub.Zuora__SubscriptionStartDate__c.monthsBetween(sub.Zuora__SubscriptionEndDate__c) + 1;
                            deliverySubscriptionList.add(sub);
                        }
                        // End D-2809 06May15 JohnD - update existing logic in computing the term length for overlapping dates
                    }
                    
                    if (deliverySubscriptionList != null && !deliverySubscriptionList.isEmpty()) {
                        uniqueIdentifier_deliverySubscriptionList.put(uniqueIdentifier, deliverySubscriptionList);
                    }
                
                } else {
                    
                    deliverySubscriptionList = uniqueIdentifier_deliverySubscriptionList.get(uniqueIdentifier);

                    lastIndex = deliverySubscriptionList.size() - 1;
                    latestFullDelSub =  deliverySubscriptionList[lastIndex];
                    
                    // Start D-2809 06May15 JohnD commented out no longer used
                    /*
                    yearMonthStartY = latestFullDelSub.Zuora__SubscriptionStartDate__c.year() + latestFullDelSub.Zuora__SubscriptionStartDate__c.month();
                    yearMonthEndY = latestFullDelSub.Zuora__SubscriptionEndDate__c.year() + latestFullDelSub.Zuora__SubscriptionEndDate__c.month();
                    */
                    // End D-2809 06May15 JohnD commented out no longer used
                    
                    // Start D-2809 06May15 JohnD - update existing logic in computing the term length for overlapping dates
                    latestStartDate = latestFullDelSub.Zuora__SubscriptionStartDate__c.toStartOfMonth();
                    latestEndDate = latestFullDelSub.Zuora__SubscriptionEndDate__c.toStartOfMonth();
                    
                    if (currentEndDate > latestEndDate) {
                        
                        if (currentStartDate == latestStartDate) {
                            deliverySubscriptionList[lastIndex] = sub;
                        } else {
                            sub.Zuora__SubscriptionStartDate__c = latestFullDelSub.Zuora__SubscriptionEndDate__c.addMonths(1);
                            sub.Term_Length__c = sub.Zuora__SubscriptionStartDate__c.addDays(1).monthsBetween(sub.Zuora__SubscriptionEndDate__c.addDays(1)) + 1;
                            deliverySubscriptionList.add(sub);
                        }
                        
                        uniqueIdentifier_deliverySubscriptionList.put(uniqueIdentifier, deliverySubscriptionList);
                    }
                    // End D-2809 06May15 JohnD - update existing logic in computing the term length for overlapping dates
                }
                
            }
        }
        // end retrieve new full-prepaid deliver susbscriptions
        
        
        // start add delivery subscriptions into the filteredSubscriptionList
        for (list<Zuora__Subscription__c> subList : uniqueIdentifier_deliverySubscriptionList.values()) {
            
            // Start D-2809 06May15 JohnD - set back the original subscription start date
            list<Zuora__Subscription__c> tmpSubList = new list<Zuora__Subscription__c>();
            for (Zuora__Subscription__c sub : subList) {
                sub.Zuora__SubscriptionStartDate__c = subscriptionId_startDate.get(sub.Id);
                tmpSubList.add(sub);
            }
            
            filteredSubscriptionList.addAll(tmpSubList);
            // End D-2809 06May15 JohnD - set back the original subscription start date
        }
        // end add delivery subscriptions into the filteredSubscriptionList
        
        return filteredSubscriptionList;
        
    }
    
    /*
     * @description: this method will calculate the applicable delivery charge fo full-prepaid order line item.
     *      this method is invoke from sm_startsubscriptionentrycontroller, sm_changeofsubscriptionentrycontroller,
     *      and sm_renewalofsubscriptionetnrycontroller
     * @param orderId : the id of the order
     * @param subscriberCharge : the monthly delivery charge according to the configured values or user input
     * @return: total applicable delivery charge
     */
    public static map<string, decimal> calculate(id orderId, decimal subscriberCharge) {

        // Start D-2809 06May15 JohnD - variable re-organinzation
        map<string, list<Order_Line_Item__c>> uniqueIdentifier_deliveryOrderLineItemList = new map<string, list<Order_Line_Item__c>>();
        map<string, Zuora__Subscription__c> uniqueIdentifier_latestExistingFullDelSub = new map<string, Zuora__Subscription__c>();
        map<string, Zuora__Subscription__c> uniqueIdentifier_EarliestExistingFullDelSub = new map<string, Zuora__Subscription__c>();
        map<string, decimal> chargeName_amount = new map<string, decimal>(); // Start/End D-2809 06May15 JohnD - renamed variable
        list<Order_Line_Item__c> deliveryOrderLineItemList = new list<Order_Line_Item__c>();
        set<list<date>> fullDateListSet = new set<list<date>>();
        set<list<date>> recurringDateListSet = new set<list<date>>();
        set<date> fullDateSet = new set<date>();
        set<date> recurringDateSet = new set<date>();
        set<string> recipientAddressSet = new set<string>();
        Zuora__Subscription__c latestFullDelSub;
        Zuora__Subscription__c earliestFullDelSub;
        Order_Line_Item__c latestFullDelOli;
        decimal fullPrepaidSubscriberCharge = 0.0;
        decimal recurringSubscriberCharge = 0.0;
        integer lastIndex;
        string uniqueIdentifier;
        string uniqueIdentifierPre;
        id accountId;
        // Start D-2809 06May15 JohnD commented out no longer used
        /* 
        integer yearMonthStartX;
        integer yearMonthStartY;
        integer yearMonthEndX;
        integer yearMonthEndY;
        */
        // End D-2809 06May15 JohnD commented out no longer used
        // End D-2809 06May15 JohnD - variable re-organinzation        
        
        list<Order_Line_Item__c> orderLineItemList = [select Name, Order__r.Account__c, Order__r.Recipient_Contact__r.Address__c, 
                Start_Date__c, End_Date__c, Term_Length__c, Order__r.Subscriber_Charge__c, Main_Package_Billing_Type__c 
                from Order_Line_Item__c where Order__c = :orderId and Delivered_By__c = :GlobalVariableClass.VENDOR 
                order by Start_Date__c asc];
        
        if (!orderLineItemList.isEmpty()) {
            
            accountId = orderLineItemList[0].Order__r.Account__c;
            if (orderLineItemList[0].Order__r.Account__c != null && orderLineItemList[0].Order__r.Recipient_Contact__r.Address__c != null) {
                uniqueIdentifierPre = orderLineItemList[0].Order__r.Account__c + '' + orderLineItemList[0].Order__r.Recipient_Contact__r.Address__c;
            }
            
            for (Order_Line_Item__c oli : orderLineItemList) {
                
                if (oli.Main_Package_Billing_Type__c == GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID) {
                    fullDateListSet.add(new list<date> {oli.Start_Date__c, oli.End_Date__c});
                } else {
                    recurringDateListSet.add(new list<date> {oli.Start_Date__c, oli.End_Date__c});
                }
            }
        }
        
        
        // start retrieve existing full-prepaid delivery subscriptions
        for (Zuora__Subscription__c sub : [select Id, Zuora__Account__c, Recipient_Contact__r.Address__c, 
                Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c from Zuora__Subscription__c 
                where Zuora__Account__c = :accountId and Subscription_Type_1__c = :GlobalVariableClass.SUBSCRIPTION_TYPE_DELIVERY 
                and Billing_Type__c = :GlobalVariableClass.SUBSCRIPTION_BILLING_TYPE_FULL_PREPAID 
                and Zuora__Status__c = :GlobalVariableClass.SUBSCRIPTION_STATUS_ACTIVE 
                order by Zuora__SubscriptionEndDate__c desc]) {
            
            if (sub.Zuora__Account__c != null && sub.Recipient_Contact__r.Address__c != null) {
                
                uniqueIdentifier = sub.Zuora__Account__c + '' + sub.Recipient_Contact__r.Address__c;
                 
                if (uniqueIdentifier_latestExistingFullDelSub != null && !uniqueIdentifier_latestExistingFullDelSub.keySet().contains(uniqueIdentifier)) {
                    uniqueIdentifier_latestExistingFullDelSub.put(uniqueIdentifier, sub);
                }
                
                uniqueIdentifier_EarliestExistingFullDelSub.put(uniqueIdentifier, sub);
                
                if (uniqueIdentifier == uniqueIdentifierPre) {
                    fullDateListSet.add(new list<date>{sub.Zuora__SubscriptionStartDate__c, sub.Zuora__SubscriptionEndDate__c});
                }
            }
        }
        // end retrieve existing full-prepaid delivery subscriptions       
        
        // start put all dates covered in the set for comparison
        for (list<date> dt : fullDateListSet) {
            for (date d = dt[0]; d <= dt[1]; d = d.addMonths(1)) {
                fullDateSet.add(d.toStartOfMonth());
            }
        }

        for (list<date> dt : recurringDateListSet) {
            for (date d = dt[0]; d <= dt[1]; d = d.addMonths(1)) {
                recurringDateSet.add(d.toStartOfMonth());
            }
        }
        
        for (date dt : recurringDateSet) {
            if (!fullDateSet.contains(dt)) {
                recurringSubscriberCharge = subscriberCharge;
            }
        }
        // end put all dates covered in the set for comparison

        latestFullDelSub = uniqueIdentifier_latestExistingFullDelSub.get(uniqueIdentifier);
        earliestFullDelSub = uniqueIdentifier_earliestExistingFullDelSub.get(uniqueIdentifier);
        
        if (earliestFullDelSub.Zuora__SubscriptionStartDate__c != null && latestFullDelSub.Zuora__SubscriptionEndDate__c != null) {
            latestStartDate = earliestFullDelSub.Zuora__SubscriptionStartDate__c.toStartOfMonth();
            latestEndDate = latestFullDelSub.Zuora__SubscriptionEndDate__c.toStartOfMonth();
        }
        
        for (Order_Line_Item__c oli : orderLineItemList) {
            system.debug(oli.Name);
            Order_Line_Item__c origOli = oli;
            if (oli.Start_Date__c != null && oli.End_Date__c != null) {
         
                // Start D-2809 06May15 JohnD commented out no longer used
                /*
                yearMonthStartX = oli.Start_Date__c.year() + oli.Start_Date__c.month();
                yearMonthEndX = oli.End_Date__c.year() + oli.End_Date__c.month();
                */
                // End D-2809 06May15 JohnD commented out no longer used
                
                // Start D-2809 06May15 JohnD - variable assignments
                endDate = oli.End_Date__c;
                currentStartDate = oli.Start_Date__c.toStartOfMonth();
                currentEndDate = oli.End_Date__c.toStartOfMonth();
                // End D-2809 06May15 JohnD - variable assignments
                
                if (oli.Order__r.Account__c != null && oli.Order__r.Recipient_Contact__r.Address__c != null) {
                    
                    uniqueIdentifier = oli.Order__r.Account__c + '' + oli.Order__r.Recipient_Contact__r.Address__c;
                    //deliveryOrderLineItemList = new list<Order_Line_Item__c>();
                    
                    // start first record of each account
                    if (uniqueIdentifier_deliveryOrderLineItemList.get(uniqueIdentifier) == null) {
                        
                        if (latestFullDelSub == null) {
                            
                            deliveryOrderLineItemList.add(oli);
                            
                        } else {
    
                            if (latestStartDate != null && latestEndDate != null) {
                                // Start D-2809 06May15 JohnD commented out no longer used
                                /*
                                yearMonthStartY = earliestFullDelSub.Zuora__SubscriptionStartDate__c.year() + earliestFullDelSub.Zuora__SubscriptionStartDate__c.month();
                                yearMonthEndY = latestFullDelSub.Zuora__SubscriptionEndDate__c.year() + latestFullDelSub.Zuora__SubscriptionEndDate__c.month();
                                */
                                // End D-2809 06May15 JohnD commented out no longer used
                                
                                // Start D-2809 06May15 JohnD - update existing logic in computing the term length for overlapping dates
                                system.debug('latestStartDate ' + latestStartDate);
                                system.debug('latestEndDate ' + latestEndDate);
                                system.debug('currentStartDate ' + currentStartDate);
                                system.debug('currentEndDate' + currentEndDate);
                                if (latestStartDate > currentStartDate) {
                                    system.debug('latestStartDate > currentStartDate');
                                    if (latestStartDate < currentEndDate) {
                                        system.debug('latestStartDate < currentEndDate');
                                        oli.End_Date__c = latestStartDate;
                                    }
                                    system.debug('>>>>>Start_Date__c ' + oli.Start_Date__c);
                                    system.debug('>>>>>End_Date__c ' + oli.End_Date__c);
                                    oli.Term_Length__c = oli.Start_Date__c.monthsBetween(oli.End_Date__c);
                                    //origOli.Term_Length__c = oli.Term_Length__c;
                                    deliveryOrderLineItemList.add(oli);
                                    latestStartDate = currentStartDate;
                                    system.debug('>>>>>term length ' + oli.Term_Length__c);
                                }
         
                                if (latestEndDate < currentEndDate) {
                                    system.debug('latestEndDate < currentEndDate');
                                    // Start 07May15
                                    if (latestEndDate > currentStartDate) {
                                        system.debug('latestEndDate > currentStartDate');
                                        oli.Start_Date__c = latestEndDate;
                                    }
                                    // End 07May15
                                    
                                    oli.End_Date__c = endDate;
                                    system.debug('>>>>>Start_Date__c ' + oli.Start_Date__c);
                                    system.debug('>>>>>End_Date__c ' + oli.End_Date__c);
                                    oli.Term_Length__c = oli.Start_Date__c.monthsBetween(oli.End_Date__c);
                                    //origOli.Term_Length__c = oli.Term_Length__c;
                                    deliveryOrderLineItemList.add(oli);
                                    latestEndDate = currentEndDate;
                                    
                                    system.debug('>>>>>Start_Date__c ' + oli.Start_Date__c);
                                    system.debug('>>>>>End_Date__c ' + oli.End_Date__c);
                                    system.debug('>>>>>term length ' + oli.Term_Length__c);
                                }

                                // End D-2809 06May15 JohnD - update existing logic in computing the term length for overlapping dates
                            }
                        }
                        system.debug('deliveryOrderLineItemList ' + deliveryOrderLineItemList);
                        system.debug('deliveryOrderLineItemList ' + !deliveryOrderLineItemList.isEmpty());
                        if (deliveryOrderLineItemList != null && !deliveryOrderLineItemList.isEmpty()) {
                            uniqueIdentifier_deliveryOrderLineItemList.put(uniqueIdentifier, deliveryOrderLineItemList);
                        }
                    
                    } else {
                        
                        //deliveryOrderLineItemList = uniqueIdentifier_deliveryOrderLineItemList.get(uniqueIdentifier);
    
                        //lastIndex = deliveryOrderLineItemList.size() - 1;
                        //latestFullDelOli =  deliveryOrderLineItemList[lastIndex];
                        
                        // Start D-2809 06May15 JohnD commented out no longer used
                        /*
                        yearMonthStartY = latestFullDelOli.Start_Date__c.year() + latestFullDelOli.Start_Date__c.month();
                        yearMonthEndY = latestFullDelOli.End_Date__c.year() + latestFullDelOli.End_Date__c.month();
                        */
                        // End D-2809 06May15 JohnD commented out no longer used
                        //latestStartDate = latestFullDelOli.Start_Date__c.toStartOfMonth();
                        //latestEndDate = latestFullDelOli.End_Date__c.toStartOfMonth();
                        system.debug('latestStartDate ' + latestStartDate);
                        system.debug('latestEndDate ' + latestEndDate);
                        system.debug('currentStartDate ' + currentStartDate);
                        system.debug('currentEndDate' + currentEndDate);
                        system.debug('currentEndDate > latestEndDate ' + currentEndDate + ' ' + latestEndDate);
                        if (currentEndDate > latestEndDate) {
                            if (currentStartDate == latestStartDate) {
                                deliveryOrderLineItemList[lastIndex] = oli;
                            } else {
                                oli.Start_Date__c = latestEndDate;
                                system.debug('JohnD :: ' + oli.Start_Date__c + ' :: ' + oli.End_Date__c.addDays(1));
                                system.debug('Start Date ' + oli.Start_Date__c + ' oli.End_Date__c ' + oli.End_Date__c);
                                oli.Term_Length__c = oli.Start_Date__c.monthsBetween(oli.End_Date__c);
                                //origOli.Term_Length__c = oli.Term_Length__c;
                                system.debug('JohnD :: Term Length : ' + oli.Term_Length__c);
                                deliveryOrderLineItemList.add(oli);
                                latestEndDate = currentEndDate;
                                system.debug('>>>>>term length ' + oli.Term_Length__c);
                            }
                        }
                        system.debug('currentStartDate < latestStartDate ' + currentStartDate + ' ' + latestStartDate);
                        if (currentStartDate < latestStartDate) {
                            oli.End_Date__c = latestStartDate;
                            system.debug('>>>>>Start_Date__c ' + oli.Start_Date__c);
                            system.debug('>>>>>End_Date__c ' + oli.End_Date__c);
                            oli.Term_Length__c = oli.Start_Date__c.monthsBetween(oli.End_Date__c);
                            //origOli.Term_Length__c = oli.Term_Length__c;
                            deliveryOrderLineItemList.add(oli);
                            latestStartDate = currentStartDate;
                            system.debug('>>>>>term length ' + oli.Term_Length__c);
                        }
                        
                        uniqueIdentifier_deliveryOrderLineItemList.put(uniqueIdentifier, deliveryOrderLineItemList);
                    }               
                }
            }
        }
        
        for (list<Order_Line_Item__c> oliList : uniqueIdentifier_deliveryOrderLineItemList.values()) {
            
            system.debug('oliList ' + oliList);
            for (Order_Line_Item__c oli : oliList) {
                
                system.debug('JohnD ::: ' + oli.Term_Length__c);
                if (oli.Term_Length__c != null && subscriberCharge != null) {
                    fullPrepaidSubscriberCharge += subscriberCharge * oli.Term_Length__c; 
                }               
            }
        }
        
        // Start D-2809 06May15 JohnD - renamed variable
        chargeName_amount.put(GlobalVariableClass.BILLING_TYPE_FULL, fullPrepaidSubscriberCharge);
        chargeName_amount.put(GlobalVariableClass.BILLING_TYPE_RECURRING, recurringSubscriberCharge);
        
        system.debug('JohnFull ' + chargeName_amount);
        return chargeName_amount;
        // End D-2809 06May15 JohnD - renamed variable
    }
}