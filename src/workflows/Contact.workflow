<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>RecipientNumberGlobalSearch</fullName>
        <field>Recipient_Number_Show__c</field>
        <formula>SUBSTITUTE(TEXT(Recipient_Number__c ),&apos;,&apos;,&apos;&apos;)</formula>
        <name>RecipientNumberGlobalSearch</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStandardEmail</fullName>
        <field>Email</field>
        <formula>Email__c</formula>
        <name>UpdateStandardEmail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Auto Populate Recipient Number 1 for Global Search</fullName>
        <actions>
            <name>RecipientNumberGlobalSearch</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>True</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>PopulateStandardEmail</fullName>
        <actions>
            <name>UpdateStandardEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK(Email__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
