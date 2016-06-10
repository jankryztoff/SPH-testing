public class ToolBox
{
    public static void submitQuotes(String orderID)
    {
        string returnValue = 'select Id';
        set<string> orderFields = new set<string>();
        
            // start order fields
            orderFields.add('Name');
            orderFields.add('Status__c');
            orderFields.add('Acquisition_Type__c');
            orderFields.add('Recipient_Contact__c');
            orderFields.add('Recipient_Contact__r.FirstName');
            orderFields.add('Recipient_Contact__r.LastName');
            orderFields.add('Vendor_Sms_Remarks__c');
            orderFields.add('Cost_Centre__c');
            orderFields.add('Account__c');
            orderFields.add('Total_Full_Prepaid_Charge__c');
            orderFields.add('Total_Monthly_Recurring_Charge__c');
            orderFields.add('Parent_Case__c');
            orderFields.add('Credit_Balance__c');
            orderFields.add('Total_Monthly_Postage_Charge__c');
            orderFields.add('Total_Gift_Charge__c');
            orderFields.add('Delivery_Charge__c');
            orderFields.add('Monthly_Delivery_Charge_for_Full_Payment__c');
            orderFields.add('Full_Prepaid_Inc_Del_Charge__c');
            orderFields.add('Recurring_Inc_Del_Charge__c');
            orderFields.add('Delivery_Charge_Type__c');
            orderFields.add('Subscriber_Charge__c');
            orderFields.add('Vendor_Credit__c');
            orderFields.add('Recipient_Type__c');
            orderFields.add('Check_Issuing_Bank__c');
            orderFields.add('Check_No__c');
            orderFields.add('Check_Dated__c');
            orderFields.add('Check_Amount__c');
            orderFields.add('Remarks_Check__c');
            orderFields.add('PO_Number__c');
            orderFields.add('Payment_Method_ID__c');
            orderFields.add('Payment_Mode__c');
            orderFields.add('Other_Payment_Mode__c');
            orderFields.add('Billing_Account__c');
            orderFields.add('Billing_Account__r.Zuora__External_Id__c');
            orderFields.add('Sponsor__c');
            orderFields.add('Credit_Amount__c');
            orderFields.add('Total_Due_to_SPH__c');
            orderFields.add('Request_for_Waiving_of_Admin_Charge__c');
            orderFields.add('Amount_Paid__c');
            orderFields.add('Billing_Contact__c');
            orderFields.add('Billing_Account_Creation_Mode__c');
            orderFields.add('Total_Due_to_Customer__c');
            orderFields.add('Subscription_Rate__c');
            orderFields.add('Admin_Charge__c');
            orderFields.add('Remarks__c');
            orderFields.add('Creation_Mode__c');
            orderFields.add('Subject__c');
            orderFields.add('Order_Type__c');
            orderFields.add('Reason_for_Waiver__c');
            orderFields.add('Order_Action__c');
            orderFields.add('Reason_Code__c');
            orderFields.add('Business_Profile__c');
            orderFields.add('ARMS_Account_Number__c');
            orderFields.add('ARMS_Credit_Term__c');
            orderFields.add('Credit_Term_Reference__c');
            orderFields.add('Credit_Limit_Internal_Limit__c');
            orderFields.add('Credit_Limit_External_Limit__c');
            orderFields.add('Approved_Debt_Exposure_Amount__c');
            orderFields.add('Debt_Management_Treatment__c');
            orderFields.add('Cust_Giro_Acct_Number__c');
            orderFields.add('Cust_Giro_Bank_Number__c');
            orderFields.add('Business_Sector__c');
            orderFields.add('Company_Code__c');
            orderFields.add('SOA_Suppression_Indicator__c');
            orderFields.add('Transient_Indicator__c');
            orderFields.add('GL_Code__c');
            orderFields.add('Base_Subscription__c');
            orderFields.add('Subscription__c');
            orderFields.add('Total_Subscription_Rate__c');
            orderFields.add('No_Vendor_Needed__c');
            orderFields.add('Total_Line_Item__c');
            orderFields.add('Billing_Type__c');
            orderFields.add('FP_Del_Usage__c');
            orderFields.add('Total_Full_Prepaid__c');
            orderFields.add('Subscription__r.Zuora__CustomerAccount__c');
            orderFields.add('Subscription__r.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c');
           
            for (string field : orderFields) {
              returnValue += ', ' + field;
            }
            
            returnValue += ' from Order__c';
        
        returnValue += ' where Id = \'' + orderID +'\'';
        system.debug('===>' + returnValue);
        
        list<Order__c> orderList = database.query(returnValue);
        Order__c lOrder = orderList[0];
        Subscription_Handler hanlder = new Subscription_Handler();
        hanlder.CreateQuotes(lOrder,'Change of Subscription');
    }
}