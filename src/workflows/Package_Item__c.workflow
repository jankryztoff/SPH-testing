<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Platform</fullName>
        <field>Platform__c</field>
        <formula>Product_Platform__c</formula>
        <name>Update Platform</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Package__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Update Platform on Package</fullName>
        <actions>
            <name>Update_Platform</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 or 4)</booleanFilter>
        <criteriaItems>
            <field>Package_Item__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Package__c.Platform__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Package_Item__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Base Product</value>
        </criteriaItems>
        <criteriaItems>
            <field>Package_Item__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Bundle Product</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
