<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>How_To_UncheckedExternalCustomer</fullName>
        <field>IsVisibleInCsp</field>
        <literalValue>0</literalValue>
        <name>How- To UncheckedExternalCustomer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>How_To_UncheckedExternalPartner</fullName>
        <field>IsVisibleInPrm</field>
        <literalValue>0</literalValue>
        <name>How- To UncheckedExternalPartner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>How_To_UncheckedExternalPublicKB</fullName>
        <field>IsVisibleInPkb</field>
        <literalValue>0</literalValue>
        <name>How- To UncheckedExternalPublicKB</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <knowledgePublishes>
        <fullName>How_To_PublishArticle</fullName>
        <action>Publish</action>
        <label>How-To PublishArticle</label>
        <language>en_US</language>
        <protected>false</protected>
    </knowledgePublishes>
    <rules>
        <fullName>How- To PublishedExternally</fullName>
        <actions>
            <name>How_To_UncheckedExternalCustomer</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>How_To_UncheckedExternalPartner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>How_To_UncheckedExternalPublicKB</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(IsVisibleInPkb || IsVisibleInCsp || IsVisibleInPrm) &amp;&amp; $User.Can_Publish_Externally__c = false</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
