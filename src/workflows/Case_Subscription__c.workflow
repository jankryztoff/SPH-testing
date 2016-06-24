<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PopulateAccount</fullName>
        <field>Account_on_Case__c</field>
        <formula>Case__r.Account.Name</formula>
        <name>PopulateAccount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PopulateVendorCode</fullName>
        <description>Populate Vendor Code from Subscription__r.Vendor_1__r.Vendor_Code__c</description>
        <field>Vendor_Code__c</field>
        <formula>Subscription__r.Vendor_1__r.Vendor_Code__c</formula>
        <name>PopulateVendorCode</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>PopulateAccountonCaseSubCreation</fullName>
        <actions>
            <name>PopulateAccount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>PopulateVendorcodeonCaseSub</fullName>
        <actions>
            <name>PopulateVendorCode</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case_Subscription__c.Vendor_Code__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populate Vendor Code from Subscription__r.Vendor_1__r.Vendor_Code__c</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
