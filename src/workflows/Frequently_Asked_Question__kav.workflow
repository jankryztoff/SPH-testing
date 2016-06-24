<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FAQ_UncheckedExternalChannels</fullName>
        <field>IsVisibleInPrm</field>
        <literalValue>0</literalValue>
        <name>FAQ UncheckedExternalPartner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FAQ_UncheckedExternalCustomer</fullName>
        <field>IsVisibleInCsp</field>
        <literalValue>0</literalValue>
        <name>FAQ UncheckedExternalCustomer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FAQ_UncheckedExternalPublicKB</fullName>
        <field>IsVisibleInPkb</field>
        <literalValue>0</literalValue>
        <name>FAQ UncheckedExternalPublicKB</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <knowledgePublishes>
        <fullName>FAQ_Pub_Article</fullName>
        <action>Publish</action>
        <label>FAQ- Pub Article</label>
        <language>en_US</language>
        <protected>false</protected>
    </knowledgePublishes>
    <knowledgePublishes>
        <fullName>FAQ_PublishArticle</fullName>
        <action>Publish</action>
        <label>FAQ-PublishArticle</label>
        <language>en_US</language>
        <protected>false</protected>
    </knowledgePublishes>
    <rules>
        <fullName>FAQ PublishedExternally</fullName>
        <actions>
            <name>FAQ_UncheckedExternalChannels</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FAQ_UncheckedExternalCustomer</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FAQ_UncheckedExternalPublicKB</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(IsVisibleInPkb  ||  IsVisibleInCsp  ||  IsVisibleInPrm) &amp;&amp;  $User.Can_Publish_Externally__c = false</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
