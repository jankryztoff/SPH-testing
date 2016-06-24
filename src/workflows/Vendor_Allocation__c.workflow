<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Unique_SPH</fullName>
        <field>SPH_Unique__c</field>
        <formula>Parcel_Name__c &amp;   Parcel_Name__r.Project_Name__c   &amp;  SingPost_Address__c   &amp;  Vendor_Account__c</formula>
        <name>Unique</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Unique_record_Vendor_Allocation</fullName>
        <actions>
            <name>Unique_SPH</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Vendor_Allocation__c.Record_Type_SPH__c</field>
            <operation>contains</operation>
            <value>Vendor</value>
        </criteriaItems>
        <criteriaItems>
            <field>Vendor_Allocation__c.Record_Type_SPH__c</field>
            <operation>contains</operation>
            <value>Mailing</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Unique_record_Vendor_Allocation_SPH</fullName>
        <actions>
            <name>Unique_SPH</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Vendor_Allocation__c.Record_Type_SPH__c</field>
            <operation>contains</operation>
            <value>Vendor</value>
        </criteriaItems>
        <criteriaItems>
            <field>Vendor_Allocation__c.Record_Type_SPH__c</field>
            <operation>contains</operation>
            <value>Mailing</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
