<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Manual_Vendor_CR_DR_Set_Approval_Date</fullName>
        <description>Manual Vendor CR/DR: Set Approval Date</description>
        <field>Approval_Date__c</field>
        <formula>TODAY()</formula>
        <name>Manual Vendor CR/DR: Set Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Approval Date</fullName>
        <actions>
            <name>Manual_Vendor_CR_DR_Set_Approval_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Manual_Vendor_Credits_Debits__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Manual_Vendor_Credits_Debits__c.Approval_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Update Approval Date when Status changes to &apos;Approval&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
