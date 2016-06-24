<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Product_UncheckedExternalCustomer</fullName>
        <field>IsVisibleInCsp</field>
        <literalValue>0</literalValue>
        <name>Product UncheckedExternalCustomer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Product_UncheckedExternalPartner</fullName>
        <field>IsVisibleInPrm</field>
        <literalValue>0</literalValue>
        <name>Product UncheckedExternalPartner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Product_UncheckedExternalPublicKB</fullName>
        <field>IsVisibleInPkb</field>
        <literalValue>0</literalValue>
        <name>Product UncheckedExternalPublicKB</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <knowledgePublishes>
        <fullName>Product_PublishArticle</fullName>
        <action>Publish</action>
        <label>Product PublishArticle</label>
        <language>en_US</language>
        <protected>false</protected>
    </knowledgePublishes>
    <rules>
        <fullName>Product PublishedExternally</fullName>
        <actions>
            <name>Product_UncheckedExternalCustomer</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Product_UncheckedExternalPartner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Product_UncheckedExternalPublicKB</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(IsVisibleInPkb || IsVisibleInCsp || IsVisibleInPrm) &amp;&amp; $User.Can_Publish_Externally__c = false</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
