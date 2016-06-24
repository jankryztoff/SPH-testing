<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Null_Contract_End_Date_OLI</fullName>
        <field>Contract_End_Date__c</field>
        <name>Null Contract End Date OLI</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Null_New_Contract_Period_OLI</fullName>
        <field>New_Contract_Period__c</field>
        <name>Null New Contract Period OLI</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Remove Contract End Date OLI</fullName>
        <actions>
            <name>Null_Contract_End_Date_OLI</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Null_New_Contract_Period_OLI</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order_Line_Item__c.Contract_End_Date__c</field>
            <operation>equals</operation>
            <value>1/1/1970</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
