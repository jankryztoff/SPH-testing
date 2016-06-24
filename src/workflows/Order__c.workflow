<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Change_Record_Type_To_ReadOnly</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Locked_Record</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change Record Type To ReadOnly</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Monthly_Delivery_Charge_for_Full_Payment</fullName>
        <description>Monthly Delivery Charge for Full Payment</description>
        <field>Monthly_Delivery_Charge_for_Full_Payment__c</field>
        <formula>0</formula>
        <name>Monthly Delivery Charge for Full Payment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Subscriber_Charge</fullName>
        <field>Subscriber_Charge__c</field>
        <formula>0</formula>
        <name>Subscriber Charge</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Vendor_Credit</fullName>
        <field>Vendor_Credit__c</field>
        <formula>0</formula>
        <name>Vendor Credit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Change Order Record Type</fullName>
        <actions>
            <name>Change_Record_Type_To_ReadOnly</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order__c.Status__c</field>
            <operation>equals</operation>
            <value>Void</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order__c.Case_Record_Type__c</field>
            <operation>equals</operation>
            <value>Stop Subscription</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Delivery Charges Field Update</fullName>
        <actions>
            <name>Monthly_Delivery_Charge_for_Full_Payment</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Subscriber_Charge</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Vendor_Credit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Order__c.No_Vendor_Needed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>- Monthly Delivery Charge for Full Payment
- Subscriber Charge
- Vendor Credit</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
