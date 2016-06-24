<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateProductFamilyTextCode</fullName>
        <description>Updates the Product_Family__c text field that acts as a formula field.</description>
        <field>Product_Family__c</field>
        <formula>Product_Family_Lookup__r.Product_Family__c</formula>
        <name>UpdateProductFamilyTextCode</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Test</fullName>
        <apiVersion>36.0</apiVersion>
        <endpointUrl>https://gmail.com</endpointUrl>
        <fields>Commission_Rate_Fri__c</fields>
        <fields>Commission_Rate_PHD__c</fields>
        <fields>Commission_Rate_Sat__c</fields>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>francis.m.b.benzon@accenture.com</integrationUser>
        <name>Test</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>PopulateProductFamilyCodeRule</fullName>
        <actions>
            <name>UpdateProductFamilyTextCode</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow updates the chosen picklist value of the Product_Family__c field.</description>
        <formula>ISCHANGED(Product_Family_Lookup__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
