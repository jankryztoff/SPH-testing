<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_TL_for_Enquiry_Case_Open_for_2_days</fullName>
        <description>Alert TL for Enquiry Case Open for 2 days</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>CSO_TL</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Notify_TL_for_Enquiry_Case_Open_for_2_Days</template>
    </alerts>
    <alerts>
        <fullName>AutoResponseTemplate1</fullName>
        <description>AutoResponseTemplate1</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>circs_autoresponse@sph.com.sg</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Email2Case_Auto_Email_Response/Email_to_Case_AutoResponse_Message_1</template>
    </alerts>
    <alerts>
        <fullName>AutoResponseTemplate2</fullName>
        <description>AutoResponseTemplate2</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>circs_autoresponse@sph.com.sg</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Email2Case_Auto_Email_Response/Email_to_Case_AutoResponse_Message_2</template>
    </alerts>
    <alerts>
        <fullName>AutoResponseTemplate3</fullName>
        <description>AutoResponseTemplate3</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>circs_autoresponse@sph.com.sg</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Email2Case_Auto_Email_Response/Email_to_Case_AutoResponse_Message_3</template>
    </alerts>
    <alerts>
        <fullName>CaseChannels_ReassignCaseUserDeactivated</fullName>
        <description>CaseChannels_ReassignCaseUserDeactivated</description>
        <protected>false</protected>
        <recipients>
            <recipient>CSO_Admin</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/CaseChannels_DeactivatedUserReassign</template>
    </alerts>
    <alerts>
        <fullName>EmailCSOCloseCase</fullName>
        <description>EmailCSOCloseCase</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Email_Alert_to_Owners_for_Case_Closed</template>
    </alerts>
    <alerts>
        <fullName>EmailNewCaseOwnerOnStart</fullName>
        <description>EmailNewCaseOwnerOnStart</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Change_Owner_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>EmailToAdminAlertTimed</fullName>
        <description>EmailToAdminAlertTimed</description>
        <protected>false</protected>
        <recipients>
            <recipient>Supervisor_Group</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Alert_to_Admin</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_to_CSO</fullName>
        <description>Email alert to CSO</description>
        <protected>false</protected>
        <recipients>
            <recipient>CSO_Admin</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Change_of_Subscription_Approval_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Email_for_closed_case</fullName>
        <ccEmails>maria.m.m.santoyo@accenture.com</ccEmails>
        <description>Email Notification for an incoming email is associated to a case that has been closed for more than a week.</description>
        <protected>false</protected>
        <recipients>
            <recipient>Technical CSO</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Email_Alert_to_Owners_for_Case_Closed</template>
    </alerts>
    <alerts>
        <fullName>Email_notification_because_owner_is_changed</fullName>
        <description>Email notification because owner is changed.</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Change_Owner_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Enquiry_escalation</fullName>
        <description>Enquiry escalation</description>
        <protected>false</protected>
        <recipients>
            <type>campaignMemberDerivedOwner</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Escalation_Rule_Notification_Team_Lead</template>
    </alerts>
    <alerts>
        <fullName>Notification_for_urgent_escalation_after_3hours</fullName>
        <description>Notification for urgent escalation after 3hours</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>Executives</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Approver_Notification_Team_Lead</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_CSO_for_Approved_Urgent_approval</fullName>
        <description>Notification to CSO for Approved Urgent approval</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Approved_Notification_CSO</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_CSO_for_Approved_Waived_approval</fullName>
        <description>Notification to CSO for Approved Waived approval</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Approved_Notification_for_Waived_CSO</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_CSO_for_Rejected_Urgent_approval</fullName>
        <ccEmails>jerella.m.v.ledesma@accenture.com</ccEmails>
        <ccEmails>marjorie.g.gaelo@accenture.com</ccEmails>
        <description>Notification to CSO for Rejected Urgent approval</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Rejection_Notification_CSO</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_CSO_for_Rejected_Waived_approval</fullName>
        <description>Notification to CSO for Rejected Waived approval</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Rejection_Notification_for_Waived_CSO</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_Team_Lead_for_Urgent_approval</fullName>
        <description>Notification to Team Lead for Urgent approval</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Approver_Notification_Team_Lead</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_Vendor_Case_Team</fullName>
        <description>Notification to Vendor Case Team</description>
        <protected>false</protected>
        <recipients>
            <recipient>Vendor</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Vendor Rep</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Case_Team_Member_Email_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_Team_Lead_for_Urgent_COA</fullName>
        <description>Notify Team Lead for Urgent COA</description>
        <protected>false</protected>
        <recipients>
            <recipient>CSO_TL</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Approver_Notification_Team_Lead</template>
    </alerts>
    <alerts>
        <fullName>Notify_Team_Lead_for_Urgent_Stop_Subscription</fullName>
        <description>Notify Team Lead for Urgent Stop Subscription is Pending for 2 days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Approver_Notification_Team_Lead</template>
    </alerts>
    <alerts>
        <fullName>Notify_Team_Lead_for_Urgent_Stop_Subscription_is_Pending_for_3_days</fullName>
        <description>Notify Team Lead for Urgent Stop Subscription is Pending for 3 days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Escalation_Rule_Notification_Team_Lead</template>
    </alerts>
    <alerts>
        <fullName>Notify_Team_Lead_for_Urgent_Stop_Subscription_is_Pending_for_4_days</fullName>
        <description>Notify Team Lead for Urgent Stop Subscription is Pending for 4 days</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Escalation_Rule_Notification_CSO</template>
    </alerts>
    <alerts>
        <fullName>Notify_Team_lead_pending_2days</fullName>
        <description>Notify Team lead that a case is pending for 2 days.</description>
        <protected>false</protected>
        <recipients>
            <recipient>CSO_TL</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Escalation_Rule_Notification_Team_Lead</template>
    </alerts>
    <alerts>
        <fullName>Notify_Team_lead_that_a_case_is_pending_for_2_days</fullName>
        <description>Notify Team lead that a case is pending for 2 days.</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Escalation_Rule_Notification_Team_Lead</template>
    </alerts>
    <alerts>
        <fullName>Notify_Team_lead_that_a_case_is_pending_for_3_days</fullName>
        <description>Notify Team lead that a case is pending for 3 days.</description>
        <protected>false</protected>
        <recipients>
            <recipient>CSO_Asst_Manager_Manager_Queue</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Escalation_Rule_Notification_Manager</template>
    </alerts>
    <alerts>
        <fullName>Notify_Team_lead_that_a_case_is_pending_for_4_days</fullName>
        <description>Notify Team lead that a case is pending for 4 days.</description>
        <protected>false</protected>
        <recipients>
            <recipient>Head_of_Customer_Service_Queue</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Escalation_Rule_Notification_CSO</template>
    </alerts>
    <alerts>
        <fullName>Notify_Team_lead_that_there_is_case_needed_for_approval_for_the_urgent_start</fullName>
        <description>Notify Team lead that there is case needed for approval for the urgent start.</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Approver_Notification_Team_Lead</template>
    </alerts>
    <alerts>
        <fullName>Renewal_of_Subscription_Notification_to_CS_Head</fullName>
        <description>Renewal of Subscription Notification to CS Head</description>
        <protected>false</protected>
        <recipients>
            <recipient>Head_of_Customer_Service</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Renewal_of_Subscription_Notification_CS_Head</template>
    </alerts>
    <alerts>
        <fullName>Renewal_of_Subscription_Notification_to_Manager1</fullName>
        <description>Renewal of Subscription Notification to Manager1</description>
        <protected>false</protected>
        <recipients>
            <recipient>CSO_Managers</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Renewal_of_Subscription_Notification_Manager</template>
    </alerts>
    <alerts>
        <fullName>Renewal_of_Subscription_Notification_to_TL</fullName>
        <description>Renewal of Subscription Notification to TL</description>
        <protected>false</protected>
        <recipients>
            <recipient>CSO_Team_Leader_Admin</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Renewal_of_Subscription_Notification_Team_Lead</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_to_Supervisor_Group</fullName>
        <description>Send Email to Supervisor Group</description>
        <protected>false</protected>
        <recipients>
            <recipient>Supervisor_Group</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Send_Email_to_Supervisor_for_Email_to_Case_on_Case_Where_Owner_is_Inactive</template>
    </alerts>
    <alerts>
        <fullName>Send_notification_to_CSO_Admin_team</fullName>
        <description>Send notification to CSO Admin team</description>
        <protected>false</protected>
        <recipients>
            <recipient>CSO Admin</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Case_Team_Member_Email_Notification</template>
    </alerts>
    <alerts>
        <fullName>Send_notification_to_Cir_planner_team</fullName>
        <description>Send notification to Cir-planner team</description>
        <protected>false</protected>
        <recipients>
            <recipient>Cir-Planner</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Case_Team_Member_Email_Notification</template>
    </alerts>
    <alerts>
        <fullName>Send_notification_to_Vendor_Ops_Rep</fullName>
        <description>Send notification to Vendor Ops Rep</description>
        <protected>false</protected>
        <recipients>
            <recipient>Vendor Rep</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Case_Team_Member_Email_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Actual_Approver_Name</fullName>
        <field>Actual_Approver_Name__c</field>
        <formula>$User.FirstName + &quot; &quot; +  $User.LastName</formula>
        <name>Actual Approver Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Adjustment_Sub_Status_Approved</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Adjustment Sub Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Adjustment_Sub_Status_Rejected</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Adjustment Sub Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Admin_Charge_Zeroed</fullName>
        <field>Admin_Charges__c</field>
        <formula>0</formula>
        <name>Admin Charge Zeroed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Process_Submission_Date</fullName>
        <field>Approval_Process_Submission_Date__c</field>
        <formula>NOW()</formula>
        <name>Approval Process Submission Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approved_Refund</fullName>
        <field>Approved_Refund__c</field>
        <literalValue>0</literalValue>
        <name>Approved Refund</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approved_Refund_Amount</fullName>
        <field>Approved_Refund__c</field>
        <literalValue>1</literalValue>
        <name>Approved Refund Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approved_Refund_Checked</fullName>
        <field>Approved_Refund__c</field>
        <literalValue>1</literalValue>
        <name>Approved Refund Checked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approved_Status</fullName>
        <field>Status</field>
        <literalValue>Pending</literalValue>
        <name>Approved Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approved_Urgent_route_to_Case_Ownner</fullName>
        <field>OwnerId</field>
        <lookupValue>CSO_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Approved Urgent route to Case Ownner</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>COA_Case_Closed</fullName>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>COA Case Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CS_UpdateSubStatToComplete</fullName>
        <description>Change of Subscription process to update case sub status to Change of Subscription Completed.</description>
        <field>Sub_Status__c</field>
        <literalValue>Change Subscription Completed</literalValue>
        <name>CS_UpdateSubStatToComplete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CS_WaitingForVendorAssignment</fullName>
        <description>This is for Change of Subscription.</description>
        <field>Sub_Status__c</field>
        <literalValue>Waiting for Vendor Assignment</literalValue>
        <name>CS_WaitingForVendorAssignment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CaseSubStatusToUrgentStart</fullName>
        <description>Update case sub status to &quot;Waiting for Urgent Start Approval&quot;</description>
        <field>Sub_Status__c</field>
        <literalValue>Waiting for Urgent Start Approval</literalValue>
        <name>CaseSubStatusToUrgentStart</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CaseToRetentionQueue</fullName>
        <description>Ability to route Case to Retention Queue.</description>
        <field>OwnerId</field>
        <lookupValue>Retention_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>CaseToRetentionQueue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Approved_Vendor</fullName>
        <field>Approval_Submitted__c</field>
        <literalValue>1</literalValue>
        <name>Case Approved Vendor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Owner_Update</fullName>
        <field>OwnerId</field>
        <lookupValue>CSO_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Case Owner Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Owner_Update1</fullName>
        <field>OwnerId</field>
        <lookupValue>CSO_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Case Owner Update1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Owner_to_TL_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CSO_Team_Leader_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Case Owner to TL Queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Retention_Accepted_By_Owner</fullName>
        <field>Route_to_Retention__c</field>
        <literalValue>0</literalValue>
        <name>Case Retention Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Status_Close</fullName>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Case Status: Close</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Status_Closed</fullName>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Case Status Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Status_Pending</fullName>
        <description>Update field Status for Case Object</description>
        <field>Status</field>
        <literalValue>Pending</literalValue>
        <name>Case Status: Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Status_to_VOID</fullName>
        <description>After approval rejection change case stat to VOID</description>
        <field>Status</field>
        <literalValue>Void</literalValue>
        <name>Case Status to VOID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Sub_Status_Provisioning</fullName>
        <description>Sets Case Sub Status = &apos;Provisioning&apos; when urgent change of subscription is approved</description>
        <field>Sub_Status__c</field>
        <literalValue>Provisioning</literalValue>
        <name>Case Sub Status: Provisioning</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Sub_Status_to_Closed</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Case Sub Status to Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Update_Case_owner_to_Cir_Planner</fullName>
        <field>OwnerId</field>
        <lookupValue>Cir_Planner</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Case: Update Case owner to Cir Planner</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_to_CSO</fullName>
        <field>OwnerId</field>
        <lookupValue>CSO_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Case to CSO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Charges_Waived</fullName>
        <field>Charges_Waived__c</field>
        <literalValue>1</literalValue>
        <name>Charges Waived</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CheckAutoResponseFlag</fullName>
        <field>Sent_Auto_Response_Flag__c</field>
        <literalValue>1</literalValue>
        <name>CheckAutoResponseFlag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Close_Case</fullName>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Close Case Status: Close</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contac_Number_Update</fullName>
        <field>Contact_Number__c</field>
        <formula>Contact.HomePhone__c</formula>
        <name>Contac Number Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_Mobile_Update</fullName>
        <field>Contact_Mobile__c</field>
        <formula>Contact.Mobile_Number__c</formula>
        <name>Contact Mobile Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DuplicateEffectiveDate</fullName>
        <field>KeyDuplicateEffectiveDate__c</field>
        <formula>TEXT( Effective_Date__c ) + TEXT( Change_of_Address_Type__c )</formula>
        <name>DuplicateEffectiveDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Goodwill_Approval_Status_Approved</fullName>
        <field>Goodwill_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Goodwill Approval Status: Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Goodwill_Approval_Status_Rejected</fullName>
        <description>Field update – Update Goodwill Approval Status to Goodwill Rejected</description>
        <field>Goodwill_Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Goodwill Approval Status: Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Goodwill_Approver</fullName>
        <field>Goodwill_Approver__c</field>
        <formula>$User.FirstName + &apos; &apos; + $User.LastName</formula>
        <name>Goodwill Approver</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Last_Approved_Date</fullName>
        <description>Last Approved Date</description>
        <field>Last_Approved_Date__c</field>
        <formula>NOW()</formula>
        <name>Last Approved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Owner_Vendor</fullName>
        <description>Assign Case to Vendor</description>
        <field>OwnerId</field>
        <lookupValue>Ven_Ops_N_E_Cir_Reps_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Owner_Vendor</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ownership_to_CSO_Team_Lead_Queue</fullName>
        <description>Transfer ownership of Case to CSO Team Lead Queue after submission for approval.</description>
        <field>OwnerId</field>
        <lookupValue>CSO_Team_Leader_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Ownership to CSO Team Lead Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Provisioning</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Provisioning</literalValue>
        <name>Provisioning</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ready_Submission</fullName>
        <description>Ready for Submission</description>
        <field>Sub_Status__c</field>
        <literalValue>Ready for Submission</literalValue>
        <name>Ready for Submission</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ready_Subscription</fullName>
        <description>Ready for Subscription</description>
        <field>Sub_Status__c</field>
        <literalValue>Ready for Subscription</literalValue>
        <name>Ready for Subscription</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ready_for_Submission</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Urgent Stop Approved</literalValue>
        <name>Ready for Submission</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ready_for_Subsm_ission_change_Owner</fullName>
        <field>OwnerId</field>
        <lookupValue>CSO_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Ready for Subsm,ission change Owner</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ready_for_Subsmission_change_Owner</fullName>
        <field>OwnerId</field>
        <lookupValue>CSO_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Ready for Subsmission change Owner</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reclass_Submitted_by</fullName>
        <field>Reclass_Submitted_by__c</field>
        <formula>LastModifiedBy.FirstName + &apos; &apos; + LastModifiedBy.LastName</formula>
        <name>Reclass Submitted by</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reclass_Update_Reclass_Approve_Reject_2</fullName>
        <field>Reclass_Approved_Rejected_By__c</field>
        <formula>$User.FirstName + &apos; &apos; + $User.LastName</formula>
        <name>Reclass: Update Reclass Approve/Reject 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reclass_Update_Reclass_Approved_Rejecte</fullName>
        <field>Reclass_Approved_Rejected_By__c</field>
        <formula>$User.FirstName + &apos; &apos; +  $User.LastName</formula>
        <name>Reclass: Update Reclass Approved/Rejecte</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reclass_Update_Reclass_Code</fullName>
        <description>Reclass: Update Reclass Code</description>
        <field>Reclass_Code__c</field>
        <formula>&apos;TBD&apos;</formula>
        <name>Reclass: Update Reclass Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reclass_Update_Reclass_Date</fullName>
        <description>Reclass: Update Reclass Date</description>
        <field>Reclass_Date__c</field>
        <formula>NOW()</formula>
        <name>Reclass: Update Reclass Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reclass_Update_Reclass_Status</fullName>
        <description>Reclass: Update Reclass Status - Approved</description>
        <field>Reclass_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Reclass: Update Reclass Status-Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reclass_Update_Reclass_Status_Rejected</fullName>
        <description>Reclass: Update Reclass Status - Rejected</description>
        <field>Reclass_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Reclass: Update Reclass Status-Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Record_Lock</fullName>
        <field>Record_Locked__c</field>
        <literalValue>1</literalValue>
        <name>Record Lock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Record_Unlock</fullName>
        <field>Record_Locked__c</field>
        <literalValue>0</literalValue>
        <name>Record Unlock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Refund_Process_Approval</fullName>
        <field>OwnerId</field>
        <lookupValue>CSO_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Refund Process Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Refund_Process_Approval2</fullName>
        <field>OwnerId</field>
        <lookupValue>CSO_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Refund Process Approval2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Refund_Process_Approval3</fullName>
        <field>OwnerId</field>
        <lookupValue>CSO_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Refund Process Approval3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Refund_Substatus_to_Approved</fullName>
        <description>[UD-0891] RBustarde 04/24/2015 - Set the Case substatus to Approved if the Approval Process status is Approved</description>
        <field>Sub_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Refund Substatus to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Refund_Substatus_to_Pending</fullName>
        <description>[UD-0891] RBustarde 04/24/2015 - Set the Case substatus to Pending if the Approval Process status is Pending</description>
        <field>Sub_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Refund Substatus to Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Refund_Substatus_to_Rejected</fullName>
        <description>[UD-0891] RBustarde 04/24/2015 - Set the Case substatus to Rejected if the Approval Process status is rejected</description>
        <field>Sub_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Refund Substatus to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejected_Renewal</fullName>
        <field>Rejected_Renewal__c</field>
        <literalValue>1</literalValue>
        <name>Rejected Renewal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejected_Status</fullName>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Rejected Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejected_Temp_Stop</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Temp Stop Rejected</literalValue>
        <name>Rejected Temp Stop</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejected_Urgent_route_to_Case_CSO</fullName>
        <field>OwnerId</field>
        <lookupValue>CSO_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Rejected Urgent route to Case CSO</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Retention_Outcome</fullName>
        <description>Update the Sub Status of the Case to Ready for Submission after Retention Offering.</description>
        <field>Sub_Status__c</field>
        <literalValue>Ready for Submission</literalValue>
        <name>Retention Outcome</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SendToRetentionQueue</fullName>
        <description>Ability to route case to retention queue.</description>
        <field>OwnerId</field>
        <lookupValue>Retention_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>SendToRetentionQueue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_New_Record_Value</fullName>
        <field>New_Record__c</field>
        <literalValue>0</literalValue>
        <name>Set New Record Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Notification_Sent_Indicator_to_False</fullName>
        <field>Notification_Sent_Indicator__c</field>
        <literalValue>0</literalValue>
        <name>Set Notification Sent Indicator to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Start_Charging_Credit_Card</fullName>
        <field>Charge_Status__c</field>
        <literalValue>Charge</literalValue>
        <name>Start Charging Credit Card</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_for_Request</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Waiting for Waiving of Charges Approval</literalValue>
        <name>Sub Status for Request for Waiving Admin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_for_Request_for_Waiving_Pending</fullName>
        <field>Status</field>
        <literalValue>Pending</literalValue>
        <name>Status for Request for Waiving Admin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_to_Pending</fullName>
        <field>Status</field>
        <literalValue>Pending</literalValue>
        <name>Status to Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_to_Provisioined</fullName>
        <field>Status</field>
        <literalValue>Provisioned</literalValue>
        <name>Status to Provisioined</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stop_Charging_Credit_Card</fullName>
        <field>Charge_Status__c</field>
        <literalValue>Do Not Charge</literalValue>
        <name>Stop Charging Credit Card</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SubStatusRequestRecalled</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Request Recalled</literalValue>
        <name>SubStatusRequestRecalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_Change_of_Sub_Completed</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Change of Subscription Completed</literalValue>
        <name>Sub Status Change of Sub Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_Goodwill_Approved</fullName>
        <description>Update Sub Status to Goodwill Approved.</description>
        <field>Sub_Status__c</field>
        <literalValue>Goodwill Approved</literalValue>
        <name>Sub Status: Goodwill Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_Goodwill_Rejected</fullName>
        <description>Update Sub Status to Goodwill Rejected.</description>
        <field>Sub_Status__c</field>
        <literalValue>Goodwill Rejected</literalValue>
        <name>Sub Status: Goodwill Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_Reclassification_Approved</fullName>
        <description>Field update – Update Sub-Status to Reclassification Approved</description>
        <field>Sub_Status__c</field>
        <literalValue>Reclassification Approved</literalValue>
        <name>Sub-Status: Reclassification Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_Reclassification_Rejected</fullName>
        <description>Field update – Update Sub-Status to Reclassification Rejected</description>
        <field>Sub_Status__c</field>
        <literalValue>Reclassification Rejected</literalValue>
        <name>Sub-Status: Reclassification Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_Waiting_for_Reclassification</fullName>
        <description>Field update – Update Sub-Status to Waiting for Reclassification Approval</description>
        <field>Sub_Status__c</field>
        <literalValue>Waiting for Reclassification Approval</literalValue>
        <name>Sub-Status:Waiting for Reclassification</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_Waiting_for_Urgent_Approval</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Waiting for Urgent Approval</literalValue>
        <name>Sub Status Waiting for Urgent Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_to_Customer_Retained</fullName>
        <description>D-1500</description>
        <field>Sub_Status__c</field>
        <literalValue>Customer Retained</literalValue>
        <name>Sub Status to Customer Retained</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_to_No_Retention</fullName>
        <description>D-1505</description>
        <field>Sub_Status__c</field>
        <literalValue>No Retention</literalValue>
        <name>Sub Status to No Retention</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_to_Stop_Approved</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Urgent Stop Approved</literalValue>
        <name>Sub Status to Stop Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_to_Stop_Completed</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Subscription Stop Completed</literalValue>
        <name>Sub Status to Stop Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_to_Stop_Rejected</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Urgent Stop Rejected</literalValue>
        <name>Sub Status to Stop Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_to_Urgent_Stop_Approved</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Ready for Submission</literalValue>
        <name>Sub Status to Urgent Stop Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_to_Urgent_Stop_Rejected</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Urgent Stop Rejected</literalValue>
        <name>Sub Status to Urgent Stop Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_to_Waived_Approval</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Waiting for Waiver Approval</literalValue>
        <name>Sub Status to Waived Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_to_Waived_Rejected</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Waived Rejected</literalValue>
        <name>Sub Status to Waived Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sub_Status_to_Waiver_Approved</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Waived Approved</literalValue>
        <name>Sub Status to Waiver Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Temp_Stop_Sub_Status_Temp_Stop_Approved</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Temp Stop Approved</literalValue>
        <name>Temp Stop Sub Status: Temp Stop Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateOriginalOwner</fullName>
        <field>Original_Owner__c</field>
        <formula>Original_Owner__c + &apos;-Recalled&apos;</formula>
        <name>UpdateOriginalOwner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateOriginalOwnerWaiver</fullName>
        <description>Once the Urgent Stop step is approved, the String &quot;Waiting for Waiver Approval&quot; will be added to the Original Owner field. So when the Waiting for Waiver Approval is recalled, and then it is resubmitted again, the sub status will be changed back to waiver</description>
        <field>Original_Owner__c</field>
        <formula>Original_Owner__c + &apos;-Waiting for Waiver Approval&apos;</formula>
        <name>UpdateOriginalOwnerWaiver</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Origin_to_Email</fullName>
        <description>This will update the case origin to &quot;Email&quot;</description>
        <field>Origin</field>
        <literalValue>Email</literalValue>
        <name>Update Case Origin to Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Subject_Field</fullName>
        <field>Subject</field>
        <formula>RecordType.DeveloperName</formula>
        <name>Update Case Subject Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Notify_Vendor_Indicator</fullName>
        <field>Notify_Vendor__c</field>
        <literalValue>1</literalValue>
        <name>Update Notify Vendor Indicator</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Pending</fullName>
        <description>status == Pending if origin != (Web || Email)</description>
        <field>Status</field>
        <literalValue>Pending</literalValue>
        <name>Update Status to Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sub_Status</fullName>
        <description>This will update the Sub Status of the Case</description>
        <field>Sub_Status__c</field>
        <literalValue>Ready for Submission</literalValue>
        <name>Update Sub Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sub_Status_to_Waiting</fullName>
        <description>Field update – Update Sub-Status to Waiting for Goodwill Approval</description>
        <field>Sub_Status__c</field>
        <literalValue>Waiting for Goodwill Approval</literalValue>
        <name>Sub-Status:Waiting for Goodwill Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sub_Status_to_Waiting_for_Urgent</fullName>
        <description>Update Sub Status of the Case to &apos;Waiting for Urgent Stop Approval&apos; after Retention offer when Urgent Request is equal to &apos;True&apos;.</description>
        <field>Sub_Status__c</field>
        <literalValue>Waiting for Urgent Stop Approval</literalValue>
        <name>Update Sub Status to Waiting for Urgent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Urgent_Approved_Checkbox</fullName>
        <field>Urgent_Approved__c</field>
        <literalValue>1</literalValue>
        <name>Urgent Approved Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Urgent_COA_Approved</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Urgent CoA Approved</literalValue>
        <name>Urgent COA Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Urgent_COA_Rejected</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Urgent CoA Rejected</literalValue>
        <name>Urgent COA Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Urgent_Rejected</fullName>
        <description>Field update – Update Sub-Status to Urgent Request Rejected</description>
        <field>Sub_Status__c</field>
        <literalValue>Urgent Rejected</literalValue>
        <name>Urgent Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Urgent_Start_Rejected</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Urgent Start Rejected</literalValue>
        <name>Urgent Start Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Urgent_Stop_Approved</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Urgent Stop Approved</literalValue>
        <name>Urgent Stop Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Urgent_Stop_Approved_Close</fullName>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Urgent Stop Approved Close</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Urgent_Stop_Rejected</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Urgent Stop Rejected</literalValue>
        <name>Urgent Stop Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Urgent_Temp_Stop_Approved</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Temp Stop Approved</literalValue>
        <name>Urgent Temp Stop Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Urgent_Temp_Stop_Subs_Approved</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Temp Stop Approved</literalValue>
        <name>Urgent Temp Stop Subs Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Urgent_Temp_Stop_Subs_Rejected</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Temp Stop Rejected</literalValue>
        <name>Urgent Temp Stop Subs Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waiting_Sub_Status</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Waiting for Waiving of Charges Approval</literalValue>
        <name>Waiting Sub Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waiting_for_Urgent_Approval</fullName>
        <description>Field update – Update Sub-Status to Waiting for Urgent Approval</description>
        <field>Sub_Status__c</field>
        <literalValue>Waiting for Urgent Approval</literalValue>
        <name>Waiting for Urgent Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waiting_for_Urgent_COA_Approval</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Waiting for Urgent CoA Approval</literalValue>
        <name>Waiting for Urgent COA Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waive_Admin_Charges</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Ready for Submission</literalValue>
        <name>Waive Admin Charges</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waive_Approval_Final</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Ready for Submission</literalValue>
        <name>Waive Approval Final</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waive_Approved_for_0_100</fullName>
        <field>OwnerId</field>
        <lookupValue>CSO_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Waive Approved for 0 -100</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waived_Approved_for_101_500</fullName>
        <field>OwnerId</field>
        <lookupValue>CSO_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Waived Approved for 101 - 500</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waived_Approved_for_501_5001</fullName>
        <field>OwnerId</field>
        <lookupValue>CSO_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Waived Approved for 501 - 5001</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waived_Rejected_for_101_500</fullName>
        <field>OwnerId</field>
        <lookupValue>CSO_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Waived Rejected for 101 - 500</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waived_Rejected_for_501_5001</fullName>
        <field>OwnerId</field>
        <lookupValue>CSO_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Waived Rejected for 501 - 5001</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waived_Request_Approved</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Waived Approved</literalValue>
        <name>Waived Request Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waived_Request_Approved_101_500</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Waived Approved</literalValue>
        <name>Waived Request Approved 101 - 500</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waived_Request_Approved_501_5000</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Waived Approved</literalValue>
        <name>Waived Request Approved 501 - 5000</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waived_Request_Rejected</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Waived Rejected</literalValue>
        <name>Waived Request Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waived_Request_Rejected_101_500</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Waived Rejected</literalValue>
        <name>Waived Request Rejected 101 - 500</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waived_Request_Rejected_501_5000</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Waived Rejected</literalValue>
        <name>Waived Request Rejected 501 - 5000</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waived_Rrejected_for_0_100</fullName>
        <field>OwnerId</field>
        <lookupValue>CSO_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Waived Rrejected for 0 -100</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waiving_of_Charges_Rejected</fullName>
        <field>Sub_Status__c</field>
        <literalValue>Waiving of Charges Rejected</literalValue>
        <name>Waiving of Charges Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updateWasRecalled</fullName>
        <field>wasRecalled__c</field>
        <literalValue>1</literalValue>
        <name>updateWasRecalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CSO Admin Case Team Member Email Notification</fullName>
        <actions>
            <name>Send_notification_to_CSO_Admin_team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint - Magazine</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Notification_Sent_Indicator__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This workflow sends email notification to CSO Admin Case Team Members.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CS_SubStatusCompleted</fullName>
        <actions>
            <name>CS_UpdateSubStatToComplete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>For change of subscription update of sub-status.</description>
        <formula>AND( RecordType.Name = &apos;Change of Subscription&apos;,  Subscription_Name__r.Vendor_1__c != null,  Urgent_Request__c != TRUE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CS_UpdateSubStatToWaitUrgentApproval</fullName>
        <actions>
            <name>Sub_Status_Waiting_for_Urgent_Approval</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Charges_Waived__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Admin_Charges__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Urgent_Request__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sub Status can be Waiting for Urgent Approval if case charges are waived and request is urgent.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CS_WaitingForVendorAssignment</fullName>
        <actions>
            <name>CS_WaitingForVendorAssignment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This is for Change of Subscription. Updates sub status if vendor assignment is required.</description>
        <formula>AND(Subscription_Name__r.Vendor_1__c == null,  ISPICKVAL(Sub_Status__c,  &apos;Waiting for Waiving of Charges Approval&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Auto Response Template1</fullName>
        <actions>
            <name>AutoResponseTemplate1</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CheckAutoResponseFlag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6 OR 7)</booleanFilter>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sent_Auto_Response_Flag__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_to_Case_Address__c</field>
            <operation>contains</operation>
            <value>stics@sph.com.sg</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_to_Case_Address__c</field>
            <operation>contains</operation>
            <value>zbocs@sph.com.sg</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_to_Case_Address__c</field>
            <operation>contains</operation>
            <value>btocs@sph.com.sg</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_to_Case_Address__c</field>
            <operation>contains</operation>
            <value>circs@sph.com.sg</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_to_Case_Address__c</field>
            <operation>contains</operation>
            <value>circssph@gmail.com</value>
        </criteriaItems>
        <description>Work around for auto response rule for Email-to-Case records 1</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Auto Response Template2</fullName>
        <actions>
            <name>AutoResponseTemplate2</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CheckAutoResponseFlag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sent_Auto_Response_Flag__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_to_Case_Address__c</field>
            <operation>contains</operation>
            <value>sphrewards@sph.com.sg</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_to_Case_Address__c</field>
            <operation>contains</operation>
            <value>sphreward@gmail.com</value>
        </criteriaItems>
        <description>Work around for auto response rule for Email-to-Case records 2</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Auto Response Template3</fullName>
        <actions>
            <name>AutoResponseTemplate3</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CheckAutoResponseFlag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6)</booleanFilter>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sent_Auto_Response_Flag__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_to_Case_Address__c</field>
            <operation>contains</operation>
            <value>ostics@sph.com.sg</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_to_Case_Address__c</field>
            <operation>contains</operation>
            <value>cirmyp@sph.com.sg</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_to_Case_Address__c</field>
            <operation>contains</operation>
            <value>paypal_cir@sph.com.sg</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_to_Case_Address__c</field>
            <operation>contains</operation>
            <value>sph.cir.testmail@gmail.com</value>
        </criteriaItems>
        <description>Work around for auto response rule for Email-to-Case records 3</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Enquiry Escalation</fullName>
        <active>false</active>
        <description>Notify Team lead that a case is pending for number of days.</description>
        <formula>AND((ISPICKVAL(Status, &quot;New&quot;)||ISPICKVAL(Status, &quot;Pending&quot;)),(ISPICKVAL(Category__c, &quot;Collection/Payment&quot;)||  ISPICKVAL(Category__c, &quot;General Enquiry&quot;) || ISPICKVAL(Category__c, &quot;Collection/Payment&quot;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Enquiry_escalation</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>48</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Case Owner Assign to Team Lead</fullName>
        <actions>
            <name>Case_Owner_to_TL_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Waiting for Urgent Start Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Category__c</field>
            <operation>equals</operation>
            <value>Start Subscription</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Pending Start Escalation</fullName>
        <active>false</active>
        <description>Notify Team lead that a case is pending for number of days.</description>
        <formula>AND((ISPICKVAL(Status, &quot;Pending&quot;)), RecordType.Name == &apos;Start Subscription&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Team_lead_that_a_case_is_pending_for_4_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Approval_Process_Submission_Date__c</offsetFromField>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Team_lead_pending_2days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Approval_Process_Submission_Date__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Team_lead_that_a_case_is_pending_for_3_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Approval_Process_Submission_Date__c</offsetFromField>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Case Refund Approval Process</fullName>
        <actions>
            <name>Refund_Substatus_to_Pending</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Refund</value>
        </criteriaItems>
        <description>Check the status of the Approval Process and reflect it in the Case Substatus</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Status Update</fullName>
        <actions>
            <name>Update_Status_to_Pending</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>((1 OR 2) AND 3) AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>Email</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>Web</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint - Newspaper,Complaint - Magazine</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CASE_Legacy_Id__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Case Status is New if Case Origin is Email or Web else Case Status is Pending.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Sub Status Customer Retained</fullName>
        <actions>
            <name>Sub_Status_to_Customer_Retained</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Case.Send_to_Retention__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Eligible_for_Retention_Offer__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>For Retention Offer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Urgent_Request__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Stop Subscription</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Outcome__c</field>
            <operation>equals</operation>
            <value>Retained</value>
        </criteriaItems>
        <description>D-1500</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Sub Status No Retention</fullName>
        <actions>
            <name>Sub_Status_to_No_Retention</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Case.Send_to_Retention__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Eligible_for_Retention_Offer__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Ready for Submission</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Urgent_Request__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Stop Subscription</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Outcome__c</field>
            <operation>equals</operation>
            <value>Not Retained</value>
        </criteriaItems>
        <description>D-1505</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Sub Status update</fullName>
        <actions>
            <name>Retention_Outcome</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Outcome__c</field>
            <operation>equals</operation>
            <value>Retained,Not Retained</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Urgent_Request__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This will update the Sub Status of the Case after Retention offer</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case TempStop Sub Status</fullName>
        <actions>
            <name>Temp_Stop_Sub_Status_Temp_Stop_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Category__c</field>
            <operation>equals</operation>
            <value>Subscription Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Ready for Subscription</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Temp Stop Subscription</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case To Retention Queue</fullName>
        <actions>
            <name>Case_Retention_Accepted_By_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SendToRetentionQueue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Send_to_Retention__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Eligible_for_Retention_Offer__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Ability to route case to retention queue.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Urgent Start Escalation</fullName>
        <active>false</active>
        <description>Notify Team lead that a case is pending for number of days.</description>
        <formula>AND((ISPICKVAL(Status, &quot;Pending&quot;)), (ISPICKVAL(Sub_Status__c, &quot;Wating for Urgent Start Approval&quot;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Team_lead_that_a_case_is_pending_for_3_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Approval_Process_Submission_Date__c</offsetFromField>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Team_lead_that_a_case_is_pending_for_4_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Approval_Process_Submission_Date__c</offsetFromField>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Team_lead_pending_2days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Approval_Process_Submission_Date__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Case Urgent Stop Escalation</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Waiting for Urgent Stop Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Approval_Process_Submission_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Notify Team lead that a case is pending for number of days.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Team_Lead_for_Urgent_Stop_Subscription_is_Pending_for_3_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Approval_Process_Submission_Date__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Team_Lead_for_Urgent_Stop_Subscription_is_Pending_for_4_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Approval_Process_Submission_Date__c</offsetFromField>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Team_Lead_for_Urgent_Stop_Subscription</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Approval_Process_Submission_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Case%3A Update Owner to Cir Planner</fullName>
        <actions>
            <name>Case_Update_Case_owner_to_Cir_Planner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Within_Circulation_Planning_Schedule__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint - Newspaper</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Replacement_Required__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Closed,Void</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CaseChannels_DeactivatedUserReassign</fullName>
        <actions>
            <name>CaseChannels_ReassignCaseUserDeactivated</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Records of deactivated users should be reassigned manually. Change owner to CSO Admin Queue for notification for the process.</description>
        <formula>AND( RecordType.Name = &quot;Enquiry&quot;, ISCHANGED(Email_Message_Counter__c), OR( Owner:User.IsActive  = false, ISPICKVAL(Status , &quot;Closed&quot;)  )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CaseToRetentionQueue</fullName>
        <actions>
            <name>CaseToRetentionQueue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SendToRetentionQueue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Send_to_Retention__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Eligible_for_Retention_Offer__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Outcome__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Ability to route case to retention queue.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case_Owner_Vendor</fullName>
        <actions>
            <name>Owner_Vendor</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Submitted to Vendor</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Waiting for Vendor Assignment</value>
        </criteriaItems>
        <description>Assign Case to Vendor</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Change Email to Case Owner</fullName>
        <actions>
            <name>Email_notification_because_owner_is_changed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>ISCHANGED( OwnerId )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Charging Date for Bypass CC</fullName>
        <actions>
            <name>Charging_Date_for_Bypass_CC</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Charging_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Cir-planner Case Team Member Email Notification</fullName>
        <actions>
            <name>Send_notification_to_Cir_planner_team</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint - Newspaper</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Within_Circulation_Planning_Schedule__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Replacement_Required__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Notification_Sent_Indicator__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This workflow sends email notification to Cir-Planner Case Team Members.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Create Follow Up Task Urgent</fullName>
        <actions>
            <name>TS_CreateFollowUpTaskUrgent</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Urgent_Approved__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Temp Stop Subscription</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Create Task</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Temp Stop Subscription</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Waiting for Urgent Temp Stop/Restart Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CASE_Legacy_Id__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Create Task for Vendor Ops to Call the Vendor</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CreateTaskOnCaseMagazine</fullName>
        <actions>
            <name>Follow_up</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint - Magazine</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CASE_Legacy_Id__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CreateTaskOnCaseNewspaper</fullName>
        <actions>
            <name>Follow_up_Call</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint - Newspaper</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CASE_Legacy_Id__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CreateTaskonStopSubscription</fullName>
        <actions>
            <name>Deactivate_Asia_1</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 AND 2 AND 3) AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Stop Subscription</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Number_of_Asia1_Account__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Vendor Subscriber,Vendor</value>
        </criteriaItems>
        <description>[KCampang 9/25/2014] Stop Subscription. Breakdown of Order Entry Section VI.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DuplicateEffectiveDate</fullName>
        <actions>
            <name>DuplicateEffectiveDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change of Address</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email to Case Origin Update</fullName>
        <actions>
            <name>Update_Case_Origin_to_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>SPH Rewards,SPH Paypal,SPH Circulation</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EmailToAdmin</fullName>
        <active>false</active>
        <description>If there is no action on a case an email alert should be sent to the administrator</description>
        <formula>LastModifiedDate == CreatedDate</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EmailToAdminAlertTimed</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>IncomingEmailWhenCaseStatIsClosed</fullName>
        <actions>
            <name>Email_for_closed_case</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Workflow to check if the case has been closed. An email notification will be sent to the CSO if the incoming email associated to a case has been closed for more than a week.</description>
        <formula>IF( Email_Message_Counter__c &gt; 0 &amp;&amp;  ISPICKVAL(Status , &apos;Closed&apos;) &amp;&amp; (ClosedDate + 7) &lt; NOW()  , true , false)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification for Urgent Start Case Approval</fullName>
        <active>false</active>
        <description>Notify Team lead that there is case needed for approval for the urgent start.</description>
        <formula>AND(ISPICKVAL( Sub_Status__c , &quot;Wating for Urgent Start Approval&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification on Renewal of Subscription Case %28to CS Head%29</fullName>
        <actions>
            <name>Renewal_of_Subscription_Notification_to_CS_Head</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND( ISPICKVAL(Status, &quot;Pending&quot;), DATEVALUE(CreatedDate) - TODAY() = 4)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification on Renewal of Subscription Case %28to Manager%29</fullName>
        <actions>
            <name>Renewal_of_Subscription_Notification_to_Manager1</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND( ISPICKVAL(Status, &quot;Pending&quot;), DATEVALUE(CreatedDate) - TODAY() = 3)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification on Renewal of Subscription Case %28to TL%29</fullName>
        <actions>
            <name>Renewal_of_Subscription_Notification_to_TL</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(  ISPICKVAL(Status, &quot;Pending&quot;),  DATEVALUE(CreatedDate) -  TODAY() = 2)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NotifyCSOforCloseCaseEmail</fullName>
        <actions>
            <name>EmailCSOCloseCase</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>ISCHANGED(Email_Message_Counter__c) &amp;&amp; ISPICKVAL(Status,  &quot;Closed&quot; ) &amp;&amp;  RecordType.DeveloperName = &quot;Enquiry&quot; || ISCHANGED(Email_Message_Counter__c) &amp;&amp; ISPICKVAL(Status,  &quot;Closed&quot; ) &amp;&amp;  RecordType.DeveloperName = &quot;Enquiry&quot; &amp;&amp;  (ClosedDate + 7) &lt;= NOW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>NotifyTLFor2DaysOpenCase</fullName>
        <active>false</active>
        <booleanFilter>(1 AND 2) OR (3 AND 4 AND 5)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New,Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Enquiry</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint - Newspaper</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Category__c</field>
            <operation>notEqual</operation>
            <value>Late Delivery,Missing Inserts,Non Delivery,Non Start,Non-Start (Temp-Stop),Non-Stop,Non-Stop (Temp Stop)</value>
        </criteriaItems>
        <description>Enquiry Case open for 2 days.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Alert_TL_for_Enquiry_Case_Open_for_2_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Ops Rep Case Team Member Email Notification</fullName>
        <actions>
            <name>Send_notification_to_Vendor_Ops_Rep</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint - Newspaper</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Notification_Sent_Indicator__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This workflow sends email notification to Vendor Ops Rep team member.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Case Subject</fullName>
        <actions>
            <name>Update_Case_Subject_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change of Subscription</value>
        </criteriaItems>
        <description>Populate Case subject based on case type</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Request for Waiving of Admin Charge</fullName>
        <actions>
            <name>Status_for_Request</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Status_for_Request_for_Waiving_Pending</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Request_for_Waiving_of_Admin_Charge__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Retention to Urgent Request</fullName>
        <actions>
            <name>Update_Sub_Status_to_Waiting_for_Urgent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.Send_to_Retention__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Urgent_Request__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Eligible_for_Retention_Offer__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Stop Subscription</value>
        </criteriaItems>
        <description>This will update the Sub Status of the Case to &apos;Waiting for Urgent Stop Approval&apos;  after Retention Offer when Urgent Request is equal to &apos;True&apos;.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SendEmailToSupervisorForClosedCaseDeactivatedOwner</fullName>
        <actions>
            <name>Send_Email_to_Supervisor_Group</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>Owner:User.IsActive = False &amp;&amp; IsPickVal(Status, &apos;Closed&apos;) &amp;&amp;      ISCHANGED(Email_Message_Counter__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Start Charging Credit Card</fullName>
        <actions>
            <name>Start_Charging_Credit_Card</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Start_Charging_Credit_Card__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Stop Charging Credit Card</fullName>
        <actions>
            <name>Stop_Charging_Credit_Card</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Stop_Charging_Credit_Card__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TS_CreateFollowUpTask</fullName>
        <actions>
            <name>TS_CreateFollowUpTask</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Case.Create_Follow_Up_Task__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Contact fields</fullName>
        <actions>
            <name>Contac_Number_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Contact_Mobile_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Contact_Name_Formula__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Urgent_Escalation_after3hours</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sub_Status__c</field>
            <operation>equals</operation>
            <value>Waiting for Urgent Temp Stop/Restart Approval</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notification_for_urgent_escalation_after_3hours</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Vendor Case Team Member Notification</fullName>
        <actions>
            <name>Notification_to_Vendor_Case_Team</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Notify_Vendor_Indicator</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint - Newspaper</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Notify_Vendor__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This workflow sends email notification to Vendor.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Charging_Date_for_Bypass_CC</fullName>
        <assignedToType>creator</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Case.Charging_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Charging Date for Bypass CC</subject>
    </tasks>
    <tasks>
        <fullName>Credit_Vendor</fullName>
        <assignedToType>creator</assignedToType>
        <description>Once urgent COA approved a task to be created for CSO to credit vendor.
Manual crediting should be done if the urgent Change of Address is approved after 10AM.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Case.Effective_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Manual crediting should be done if the urgent Change of Address is approved after 10AM</subject>
    </tasks>
    <tasks>
        <fullName>Deactivate_Asia_1</fullName>
        <assignedTo>Cir_Planners</assignedTo>
        <assignedToType>role</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Case.Stop_Request_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Deactivate Asia 1</subject>
    </tasks>
    <tasks>
        <fullName>Follow_up</fullName>
        <assignedToType>creator</assignedToType>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Follow up</subject>
    </tasks>
    <tasks>
        <fullName>Follow_up_Call</fullName>
        <assignedToType>creator</assignedToType>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Follow up: Call</subject>
    </tasks>
    <tasks>
        <fullName>New_Task</fullName>
        <assignedToType>creator</assignedToType>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>New Task</subject>
    </tasks>
    <tasks>
        <fullName>Please_call_and_remind_the_vendor</fullName>
        <assignedToType>creator</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Case.Approval_Process_Submission_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Please call and remind the vendor</subject>
    </tasks>
    <tasks>
        <fullName>TS_CreateFollowUpTask</fullName>
        <assignedToType>creator</assignedToType>
        <dueDateOffset>-1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Case.Restart_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Temp Stop Follow Up</subject>
    </tasks>
    <tasks>
        <fullName>TS_CreateFollowUpTaskUrgent</fullName>
        <assignedToType>creator</assignedToType>
        <dueDateOffset>-1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Case.Restart_Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Urgent Temp Stop Approved - Notify Vendor Ops</subject>
    </tasks>
</Workflow>
