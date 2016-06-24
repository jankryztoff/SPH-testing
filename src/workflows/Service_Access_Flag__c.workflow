<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Migration_Update_Service_Access_Ext</fullName>
        <field>Flag_Code_Ext__c</field>
        <formula>Name</formula>
        <name>Migration Update Service Access Ext</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Migration Service Access Ext</fullName>
        <actions>
            <name>Migration_Update_Service_Access_Ext</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Access_Flag__c.Flag_Code_Ext__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
