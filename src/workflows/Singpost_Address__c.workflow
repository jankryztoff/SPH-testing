<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Singpost_Key</fullName>
        <field>SingPost_Key__c</field>
        <formula>(Name &amp; &apos;|&apos; &amp; (Service_Number__c + House_Block_Number__c))</formula>
        <name>Singpost Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Singpost Key</fullName>
        <actions>
            <name>Singpost_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Singpost_Address__c.Name</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <description>Update Singpost Key</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
