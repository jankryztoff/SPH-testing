<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Asia1_Activation_Email_Alert</fullName>
        <description>Asia1 Activation Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Activation_Email_Asia1</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Asia_1_Expiry_Date</fullName>
        <field>Base_Date_Expiration__c</field>
        <formula>today() + 7</formula>
        <name>Update Asia 1 Expiry Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Send Asia1 Activation Email</fullName>
        <actions>
            <name>Asia1_Activation_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Asia_1_Expiry_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Asia1__c.Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Asia1__c.EnabledCount__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asia1__c.Status__c</field>
            <operation>equals</operation>
            <value>Created</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asia1__c.Is_Link_Expired_Used__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow rule send activation email to customer when Asia1 ID is not yet active in Asia1.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
