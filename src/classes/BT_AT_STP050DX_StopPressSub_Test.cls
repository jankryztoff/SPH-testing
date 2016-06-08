/*
 * Class Name: BT_AT_STP050DX_StopPressSub_Test
 * @author: Kevin H. Evasco
 * Date: 09/03/2014
 * Project/Requirement: SPH Integration - STP050DX Interface
 * @description A test class for BT_AT_STP050DX_StopPressSubscription 
 * History: 08/21/2014 Kevin Evasco Created Skeletal Apex Trigger Test Class
 */

@isTest
private class BT_AT_STP050DX_StopPressSub_Test
{   
    /* @description This method executes during class instantiation.  
     * @param SC a ScheduleContext which is a predefined parameter
     * @return void
     */ 
    static testMethod void testInterfaceApexTrigger()
    {
        List<BT_CO_STPPRS_StopPressSubscription__c> interfaceRecordList = new List<BT_CO_STPPRS_StopPressSubscription__c>();
        
        BT_CO_STPPRS_StopPressSubscription__c interfaceRecord = new BT_CO_STPPRS_StopPressSubscription__c();
        interfaceRecord.Name = 'STP050DX';
        interfaceRecord.amount_paid__c = 'a';
        interfaceRecord.auto_renewal_indicator__c = 'b';
        interfaceRecord.card_expiry_date__c = 'c';
        interfaceRecord.credit_card_type__c = 'd';
        interfaceRecord.delivery_fee_indicator__c = 'e';
        interfaceRecord.filler__c = 'f';
        interfaceRecord.free_gift__c = 'g';
        interfaceRecord.free_gift2__c = 'h';
        interfaceRecord.free_gift3__c = 'i';
        interfaceRecord.free_gift4__c = 'j';
        interfaceRecord.hse_type__c = 'k';
        interfaceRecord.mlgagt__c = 'l';
        interfaceRecord.online_order_num__c = 'm';
        interfaceRecord.payment_number__c = 'n';
        interfaceRecord.pay_type__c = 'o';
        interfaceRecord.product_code__c = 'p';
        interfaceRecord.promo_indicator__c = 'q';
        interfaceRecord.recipient_age_group__c = 'r';
        interfaceRecord.recipient_blgm__c = 's';
        interfaceRecord.recipient_country__c = 't';
        interfaceRecord.recipient_country_code__c = 'u';
        interfaceRecord.recipient_coym__c = 'v';
        interfaceRecord.recipient_date_of_birth__c = 'w';
        interfaceRecord.recipient_dsg__c = 'x';
        interfaceRecord.recipient_email_id__c = 'y';
        interfaceRecord.recipient_fax_num__c = 'z';
        interfaceRecord.recipient_home_tel_num__c = 'A';
        interfaceRecord.recipient_house_block_num__c = 'B';
        interfaceRecord.recipient_house_level_number__c = 'C';
        interfaceRecord.recipient_house_unit_number__c = 'D';
        interfaceRecord.recipient_hphnn__c = 'E';
        interfaceRecord.recipient_icn__c = 'F';
        interfaceRecord.recipient_income_range__c = 'G';
        interfaceRecord.recipient_local_address__c = 'H';
        interfaceRecord.recipient_name__c = 'I';
        interfaceRecord.recipient_office_ext_num__c = 'J';
        interfaceRecord.recipient_office_tel_num__c = 'K';
        interfaceRecord.recipient_overseas_add1__c = 'L';
        interfaceRecord.recipient_overseas_add2__c = 'M';
        interfaceRecord.recipient_overseas_add3__c = 'N';
        interfaceRecord.recipient_overseas_add4__c = 'O';
        interfaceRecord.recipient_postal_code__c = 'P';
        interfaceRecord.recipient_privacy_indicator__c = 'Q';
        interfaceRecord.recipient_profession__c = 'R';
        interfaceRecord.recipient_race__c = 'S';
        interfaceRecord.recipient_salutation__c = 'T';
        interfaceRecord.recipient_sex__c = 'U';
        interfaceRecord.recipient_strm__c = 'V';
        interfaceRecord.recurring_indicator__c = 'W';
        interfaceRecord.referred_start_date__c = 'X';
        interfaceRecord.sub_copies__c = 'Y';
        interfaceRecord.sub_period__c = 'Z';
        interfaceRecord.subscribe_local_address__c = 'a';
        interfaceRecord.subscriber_age_group__c = 'b';
        interfaceRecord.subscriber_blgm__c = 'c';
        interfaceRecord.subscriber_country__c = 'd';
        interfaceRecord.subscriber_country_code__c = 'e';
        interfaceRecord.subscriber_coym__c = 'f';
        interfaceRecord.subscriber_date_of_birth__c = String.escapeSingleQuotes('1.1.1');//'g';
        interfaceRecord.subscriber_dsg__c = 'h';
        interfaceRecord.subscriber_email_id__c = 'i';
        interfaceRecord.subscriber_fax_number__c = 'j';
        interfaceRecord.subscriber_home_tel_number__c = 'k';
        interfaceRecord.subscriber_house_block_number__c = 'l';
        interfaceRecord.subscriber_house_level_number__c = 'm';
        interfaceRecord.subscriber_house_unit_number__c = 'n';
        interfaceRecord.subscriber_hphnn__c = 'o';
        interfaceRecord.subscriber_icn__c = 'p';
        interfaceRecord.subscriber_income_range__c = 'q';
        interfaceRecord.subscriber_name__c = 'r';
        interfaceRecord.subscriber_office_ext_number__c = 's';
        interfaceRecord.subscriber_office_tel_number__c = 't';
        interfaceRecord.subscriber_overseas_add1__c = 'u';
        interfaceRecord.subscriber_overseas_add2__c = 'v';
        interfaceRecord.subscriber_overseas_add3__c = 'w';
        interfaceRecord.subscriber_overseas_add4__c = 'x';
        interfaceRecord.subscriber_postal_code__c = 'y';
        interfaceRecord.subscriber_privacy_indicator__c = 'z';
        interfaceRecord.subscriber_profession__c = 'A';
        interfaceRecord.subscriber_race__c = 'B';
        interfaceRecord.subscriber_salutation__c = 'C';
        interfaceRecord.subscriber_sex__c = 'D';
        interfaceRecord.subscriber_strm__c = 'E';
        interfaceRecord.subscriber_type__c = 'F';
        interfaceRecord.subscription_package_code__c = 'G';
        interfaceRecord.unit_discount_price__c = 'H';

        interfaceRecordList.add(interfaceRecord);
            
        Test.startTest();
        insert interfaceRecordList;
        Test.stopTest();
    }
}