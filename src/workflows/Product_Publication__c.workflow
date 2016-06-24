<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PopulateStringIds</fullName>
        <field>UniquenessCheck__c</field>
        <formula>ZProduct__c + Publication_Code__c</formula>
        <name>PopulateStringIds</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>PopulateIdStringForUniquenessCheck</fullName>
        <actions>
            <name>PopulateStringIds</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>True</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
