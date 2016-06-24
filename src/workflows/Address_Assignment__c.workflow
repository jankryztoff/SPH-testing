<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>old_address_data_insert</fullName>
        <field>old_address__c</field>
        <formula>Contact__r.Contact_Address_Detail__c</formula>
        <name>old address data insert</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Old address field data assignment</fullName>
        <actions>
            <name>old_address_data_insert</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Address_Assignment__c.Name</field>
            <operation>notEqual</operation>
            <value>Null</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
