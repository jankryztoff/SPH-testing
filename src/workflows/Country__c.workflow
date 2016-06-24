<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>zonalCodeFieldUpdate</fullName>
        <field>Zonal_Code__c</field>
        <formula>Zone__r.Name</formula>
        <name>zonalCodeFieldUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Populate Zone Code for Country</fullName>
        <actions>
            <name>zonalCodeFieldUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate the zone code in the country object whenever the zonal code is looked up</description>
        <formula>NOT(ISBLANK(Zone__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
