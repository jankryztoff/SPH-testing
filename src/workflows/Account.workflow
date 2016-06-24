<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Populate_Account_Number</fullName>
        <field>AccountNumber</field>
        <formula>Account_Auto_Number__c</formula>
        <name>Populate Account Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Populate Account Number</fullName>
        <actions>
            <name>Populate_Account_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.AccountNumber</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Account_Legacy_Id__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This is to populate the Account Number for migration purposes</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
