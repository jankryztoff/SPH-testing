<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AutoPopulate_UserExternalIds</fullName>
        <field>User_External_ID__c</field>
        <formula>Username</formula>
        <name>AutoPopulate_UserExternalIds</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AutoPopulate_UserExternalIds</fullName>
        <actions>
            <name>AutoPopulate_UserExternalIds</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.Username</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>CCB059 - This field should be automatically populated with the username when a user is created in the system</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
