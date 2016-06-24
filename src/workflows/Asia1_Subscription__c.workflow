<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Disable_Asia1_Sub_Status</fullName>
        <field>Status__c</field>
        <literalValue>Disabled</literalValue>
        <name>Disable Asia1 Sub Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Asia1_Status</fullName>
        <field>Status__c</field>
        <literalValue>Enabled</literalValue>
        <name>Update Asia1 Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Asia1 Subscription Status Disable</fullName>
        <actions>
            <name>Disable_Asia1_Sub_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Subscription is successfully tied up to subscription after sync then status asia1 will be enabled.</description>
        <formula>ISBLANK(Subscription__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Asia1 Subscription Status</fullName>
        <actions>
            <name>Update_Asia1_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Subscription is successfully tied up to subscription after sync then status asia1 will be enabled.</description>
        <formula>(NOT(ISBLANK(Subscription__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
