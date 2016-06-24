<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Gift_Redemption_Number</fullName>
        <field>Gift_Redemption_Number__c</field>
        <formula>Salesforce_Redemption_Number__c</formula>
        <name>Update Gift Redemption Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Gift Redemption Number</fullName>
        <actions>
            <name>Update_Gift_Redemption_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
