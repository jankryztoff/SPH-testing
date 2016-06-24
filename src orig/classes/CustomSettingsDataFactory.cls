@isTest
public class CustomSettingsDataFactory {
  
  public static List<Zuora_HPM_Settings__c> createZuora_HPM_Settings(){
      List<Zuora_HPM_Settings__c> listZhs = new List<Zuora_HPM_Settings__c>();
      listZhs.add(new Zuora_HPM_Settings__c(Name = 'Default',Zuora_Url__c = 'apisandbox.zuora.com',Tenant_Id__c = '12213',Id__c = '2c92c0f9479f7eb10147aadd21634797',Api_Security_Key__c = '7rAtGAFh0vXd0yLqtN1Q4NXJsizOvApONvuLw-HT6pY='));        
      listZhs.add(new Zuora_HPM_Settings__c(Name = 'Amex',Zuora_Url__c = 'apisandbox.zuora.com',Tenant_Id__c = '12213',Id__c = '2c92c0f951af6bbb0151afa5cf72439b',Api_Security_Key__c = '7rAtGAFh0vXd0yLqtN1Q4NXJsizOvApONvuLw-HT6pY='));        
      return listZhs; 
  }
  
  public static List<Zuora_Configuration__c> createZuora_Configuration(){
       List<Zuora_Configuration__c> listZconf = new List<Zuora_Configuration__c>();
       listZconf.add(new Zuora_Configuration__c(Name='APISecurityKey', Apex_Class_Trigger__c='Test_HPMController', Value__c='7rAtGAFh0vXd0yLqtN1Q4NXJsizOvApONvuLw-HT'));
       listZconf.add(new Zuora_Configuration__c(Name='tenantId', Apex_Class_Trigger__c='Test_HPMController', Value__c='12213'));
       listZconf.add(new Zuora_Configuration__c(Name='ID', Apex_Class_Trigger__c='Test_HPMController', Value__c='2c92c0f9479f7eb10147aadd21634797'));
       listZconf.add(new Zuora_Configuration__c(Name='ZuoraURL', Apex_Class_Trigger__c='Test_HPMController', Value__c='apisandbox.zuora.com'));
       listZconf.add(new Zuora_Configuration__c(Name='apiKey', Apex_Class_Trigger__c='INT_PageRestToolController', Value__c='5jhxpcu9ezqvv22kkp4exccy'));
       listZconf.add(new Zuora_Configuration__c(Name='myReturn', Apex_Class_Trigger__c='INT_PageRestToolController', Value__c='https://mrdr.accenture.com/1033_MRDR/Int'));
       listZconf.add(new Zuora_Configuration__c(Name='sharedSecret', Apex_Class_Trigger__c='INT_PageRestToolController', Value__c='sh7kmWFeQQZvvE6Um9NMJG3g'));
       return listZconf;
  }
  
  public static List<Uom__c> createUom(){
       List<Uom__c> listUom = new List<Uom__c>();
       String[] keyName = new String[]{'Copy Sun','PostageCharge' ,'Credit Copy AIO Online Thu','Credit Copy AIO Tablet Mon','Credit Copy AIO Online Sat','Credit Copy Smartphone Tue','Credit Copy Tablet Wed','Credit Copy Online Sat','Credit Copy Smartphone Mon','Credit Copy Fri','Credit Copy Smartphone Wed','Credit Copy Tablet Sun','Credit Copy AIO Tablet Wed','Credit Copy AIO Smartphone Wed','Credit Copy Tablet Sat','Credit Copy AIO Tablet Sat','Credit Copy Sun','Credit Copy Online Wed','Credit Copy Tablet Thu','Credit Copy AIO Online Mon','Credit Copy Online Tue','Credit Copy Tablet Tue','Credit Copy AIO Online Wed','Credit Copy Wed','Credit Copy Online Fri','Credit Copy AIO Smartphone Sat','Credit Copy Thu','Credit Copy Smartphone Sun','Credit Copy AIO Smartphone Tue','Credit Copy AIO Smartphone Sun','Credit Copy AIO Tablet Sun','Credit Copy Mon','Credit Copy Online Mon','Credit Copy Tablet Fri','Credit Copy AIO Online Sun','Credit Copy AIO Online Tue','Credit Copy Online Thu','Credit Copy AIO Smartphone Mon','Credit Copy AIO Smartphone Thu','Credit Copy AIO Tablet Tue','Credit Copy Sat','Credit Copy Online Sun','Credit Copy Tue','Credit Copy Smartphone Thu','Credit Copy Tablet Mon','Credit Copy Smartphone Sat','Credit Copy AIO Online Fri','Credit Copy AIO Smartphone Fri','Credit Copy AIO Tablet Fri','Credit Copy AIO Tablet Thu','Credit Copy Smartphone Fri','Discount-Percentage','Credit Copy Weekday','CreditPostageCharge' ,'Copy Weekday','Copy Sat'};
       String[] keyVal = new String[]{ 'Copy Sun','Postage Charge','Credit Copy AIO Online Thu','Credit Copy AIO Tablet Mon','Credit Copy AIO Online Sat','Credit Copy Smartphone Tue','Credit Copy Tablet Wed','Credit Copy Online Sat','Credit Copy Smartphone Mon','Credit Copy Fri','Credit Copy Smartphone Wed','Credit Copy Tablet Sun','Credit Copy AIO Tablet Wed','Credit Copy AIO Smartphone Wed','Credit Copy Tablet Sat','Credit Copy AIO Tablet Sat','Credit Copy Sun','Credit Copy Online Wed','Credit Copy Tablet Thu','Credit Copy AIO Online Mon','Credit Copy Online Tue','Credit Copy Tablet Tue','Credit Copy AIO Online Wed','Credit Copy Wed','Credit Copy Online Fri','Credit Copy AIO Smartphone Sat','Credit Copy Thu','Credit Copy Smartphone Sun','Credit Copy AIO Smartphone Tue','Credit Copy AIO Smartphone Sun','Credit Copy AIO Tablet Sun','Credit Copy Mon','Credit Copy Online Mon','Credit Copy Tablet Fri','Credit Copy AIO Online Sun','Credit Copy AIO Online Tue','Credit Copy Online Thu','Credit Copy AIO Smartphone Mon','Credit Copy AIO Smartphone Thu','Credit Copy AIO Tablet Tue','Credit Copy Sat','Credit Copy Online Sun','Credit Copy Tue','Credit Copy Smartphone Thu','Credit Copy Tablet Mon','Credit Copy Smartphone Sat','Credit Copy AIO Online Fri','Credit Copy AIO Smartphone Fri','Credit Copy AIO Tablet Fri','Credit Copy AIO Tablet Thu','Credit Copy Smartphone Fri','Discount-Percentage','Credit Copy Weekday','Credit Postage Month','Copy Weekday','Copy Sat'};
       for(Integer i = 0 ; i < keyName.size(); i++ )
       {
         listUom.add(new Uom__c(Name=keyName[i],Label__c=keyVal[i]));
       }
       return listUom;
  }
  
  public static List<Unit_of_Measure__c> createUnit_of_Measure(){
      List<Unit_of_Measure__c> listUom = new List<Unit_of_Measure__c>();
      String[] keyName = new String[]{'Copy Sun','Credit Copy Month ST','Credit Copy Month SUT','Credit Copy Month TABL','Credit Copy Month TBS','Credit Copy Month TM','Credit Copy Month TMS','Credit Copy Month TNPS','Credit Copy Month TUP','Credit Copy Month TUPJ','Credit Copy Month STS','Credit Copy Month STS1','Credit Copy Month STT','Credit Copy Month STT1','Credit Copy Month NPO','Credit Copy Month NPO1','Credit Copy Month NPS','Credit Copy Month NPS1','Credit Copy Month WBO','Copy Online','Copy Smartphone','Copy Tablet','Copy AIO Online','Copy AIO Smartphone','Copy AIO Tablet','Credit Copy Weekday','Credit Copy Sat','Credit Copy Sun','Credit Copy Month WB','Credit Copy Month WSJA','Credit Copy Month ZB','Credit Copy Month ZBCM','Credit Copy Month BHO','Credit Copy Month BHO1','Credit Copy Month BHS','Credit Copy Month BHS1','Credit Copy Month BHT','Credit Copy Month WBO1','Credit Copy Month WBP','Credit Copy Month WBS','Credit Copy Month WBS1','Credit Copy Month WBT','Credit Copy Month WBT1','Credit Copy Month ZBBZ','Credit Copy Month ZBAP','Credit Copy Month ZBO','Credit Copy Online','Credit Copy Smartphone','Credit Copy Tablet','Credit Copy AIO Online','Credit Copy AIO Smartphone','Credit Copy AIO Tablet','Goodwill Credit Copy','Goodwill Credit Copy Online','Goodwill Credit Copy Smartphone','Credit Copy Month BHT1','Credit Copy Month BTO','Credit Copy Month BTO1','Credit Copy Month BTAP','Credit Copy Month BTS','Credit Copy Month BTS1','Credit Copy Month ZBO1','Credit Copy Month ZBS','Credit Copy Month ZBS1','Credit Copy Month ZBT','Credit Copy Month ZBT1','No Credit Copy Weekday','No Credit Copy Sat','No Credit Copy Sun','No Credit Copy Online','Goodwill Credit Copy Tablet','Credit Copy Issue CLEO','Credit Copy Issue COSM','Credit Copy Issue FINS','Credit Copy Issue FML','Credit Copy Issue FMLB','Credit Copy Issue GDS','Credit Copy Issue HAWS','Credit Copy Issue HBS','No Credit Copy Smartphone','No Credit Copy Tablet','No Credit Copy AIO Online','No Credit Copy AIO Smartphone','No Credit Copy AIO Tablet','HDB','APT','LANDED','Credit HDB','Credit Copy Issue HD','Credit Copy Issue HH1','Credit Copy Issue HOT','Credit Copy Issue HW','Credit Copy Issue HWB','Credit Copy Issue ICON','Credit Copy Issue MEN','Credit Copy Issue NUYU','Credit Copy Issue PS','Credit Copy Month BTT','Credit Copy Month BTT1','Credit Copy Month SIOP','Credit Copy Month STAA','Credit Copy Month STAP','Credit Copy Month STI','Credit Copy Month STI1','Credit APT','Credit LANDED','Postage Charge','Credit Postage Month','Dummy Charge','Copy','Issue Weekday','Issue Sat','Issue Sun','Credit Copy Issue SHA','Credit Copy Issue SHER','Credit Copy Issue SWW','Credit Copy Issue TFAH','Credit Copy Issue TORQ','Credit Copy Issue YOU','Credit Copy Issue YP','Credit Copy Issue ZBBZ','Credit Copy Month AFR','Credit Copy Month AFRW','Credit Copy Month BH','Credit Copy Month BM','Credit Copy Month BT','Credit Copy Month FT','Credit Copy Month FTW','Credit Copy Month MY','Credit Copy Month NP','Credit Copy Month SM','Issue Online','Issue Smartphone','Issue Tablet','Issue AIO Online','Issue AIO Smartphone','Issue AIO Tablet','Copy Weekday','Copy Sat'};
      String[] usedFor = new String[]{'Proration Charge Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Charge Usage','Proration Charge Usage','Proration Charge Usage','Proration Charge Usage','Proration Charge Usage','Proration Charge Usage','Proration Credit Usage','Proration Credit Usage','Proration Credit Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credit Usage','Proration Credit Usage','Proration Credit Usage','Proration Credit Usage','Proration Credit Usage','Proration Credit Usage','Proration Goodwill Credit Usage','Proration Goodwill Credit Usage','Proration Goodwill Credit Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Non Chargeable Copy Usage','Non Chargeable Copy Usage','Non Chargeable Copy Usage','Non Chargeable Copy Usage','Proration Goodwill Credit Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Non Chargeable Copy Usage','Non Chargeable Copy Usage','Non Chargeable Copy Usage','Non Chargeable Copy Usage','Non Chargeable Copy Usage','Delivery Charge Usage','Delivery Charge Usage','Delivery Charge Usage','Delivery Credits Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Delivery Credits Usage','Delivery Credits Usage','Postage Charge','Postage Credits Usage','Dummy Charge Usage','Prepaid Monthly','Postpaid Usage','Postpaid Usage','Postpaid Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Issue Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Proration Credits by Month Usage','Postpaid Usage','Postpaid Usage','Postpaid Usage','Postpaid Usage','Postpaid Usage','Postpaid Usage','Proration Charge Usage','Proration Charge Usage'};
      String[] issueDays = new String[]{'Sunday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Saturday','Sunday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Saturday','Sunday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Saturday','Sunday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Monday,Tuesday,Wednesday,Thursday,Friday','Saturday'};
      for(Integer i = 0 ; i < keyName.size(); i++ )
      {
        listUom.add(new Unit_of_Measure__c(Name=keyName[i],Used_for__c=usedFor[i],Issue_Days__c=usedFor[i],Is_Monthly__c=FALSE));
      }
      return listUom;
  }
  
  public static List<Special_Product_Families__c> createSpecial_Product_Families(){
    List<Special_Product_Families__c> listSpf = new List<Special_Product_Families__c>();
    listSpf.add(new Special_Product_Families__c(Name='1',Product_Family_Name__c='The Straits Times'));
    listSpf.add(new Special_Product_Families__c(Name='2',Product_Family_Name__c='The New Paper'));
    listSpf.add(new Special_Product_Families__c(Name='3',Product_Family_Name__c='Berita Harian'));
    listSpf.add(new Special_Product_Families__c(Name='4',Product_Family_Name__c='Tamil Murasu'));
    return listSpf;
  }

  public static List<SMS_Integration_Gateway__c> createSMS_Integration_Gateway(){
    List<SMS_Integration_Gateway__c> listIg = new List<SMS_Integration_Gateway__c>();
    listIg.add(new SMS_Integration_Gateway__c(Name='SMS Commzgate',SMS_Country_Code__c='63',SMS_Gateway_ID__c='59660002',SMS_Gateway_URL__c = 'https://www.commzgate.net/gateway/SendMsg?',SMS_Password__c = 'SPH_admin',SMS_Type__c = 'A'));
    return listIg;    
  }

  public static List<Renewal_Notifications__c> createRenewal_Notifications(){
    List<Renewal_Notifications__c> listRN = new List<Renewal_Notifications__c>();
    listRN.add(new Renewal_Notifications__c(Name='Renewal Notifications Values',X1st_Expiry_Notification_Date__c = 28,X1st_Notification_Magazine__c = 42,X1st_Notification_Newspaper__c = 42,X2nd_Expiry_Notification_Date__c = 10,X2nd_Notification_Magazine__c = 14,X2nd_Notification_Newspaper__c = 14));
    return listRN;    
  }

  public static List<Record_Type_Field_Setup__c> createRecord_Type_Field_Setup(){
    List<Record_Type_Field_Setup__c> listRtSetup = new List<Record_Type_Field_Setup__c>();
    String[] keyName = new String[]{'13','12','61','62','63','14','15','16','17','18','65','66','67','64','68','69','70','71','72','19','23','20','21','22','24','25','26','27','28','74','73','75','76','34','35','29','30','31','32','33','36','77','78','45','46','37','38','39','40','41','42','43','44','79','80','81','47','48','49','50','51','52','53','82','83','84','85','86','87','88','89','1','54','55','56','90','91','92','93','2','3','5','4','6','57','58','59','60','94','95','96','97','7','8','9','10','11'};
    String[] valueFieldName = new String[]{'Name','Attention_Seeking_Subs__c','Attention_To_Care_Of__c','Attention_To_Care_Of_Indicator__c','Attention_To_Care_Of_Salutation__c','NRIC__c','Office_Extension__c','Office_Number__c','Passport__c','Phone','GST_Out_of_Scope__c','Language__c','Date_of_Birth__c','Date_Since__c','Name','RecordTypeId','Staff_ID__c','Sub_Group__c','VIP_Email__c','Race__c','Attention_To_Care_Of__c','RecordTypeId','Renewal_Letter__c','SMS_Renewal_Notification__c','Sub_Group__c','VIP_Email__c','VIP_Mobile__c','VIP_Staff_Home_Phone__c','Acknowledgement_Letter__c','VIP_Staff_Home_Phone__c','VIP_Mobile__c','Level_Number__c','Postal_Code__c','Attention_To_Care_Of_Indicator__c','Business_Nature__c','Airline_Indicator__c','Attention_Seeking_Subs__c','Attention_To_Care_Of__c','Attention_To_Care_Of_Indicator__c','Attention_To_Care_Of_Salutation__c','Contact_Person__c','RecordTypeId','Date_Since__c','Attention_To_Care_Of_Salutation__c','Mobile__c','Credit_Alert__c','Date_Since__c','Email__c','Email_Secondary__c','Eshop_Ref_No__c','GST_Invoice__c','GST_Out_of_Scope__c','Language__c','Unit_Number__c','Address_1__c','Address_2__c','Name','Office_Extension__c','Office_Number__c','Phone','RecordTypeId','Renewal_Letter__c','SMS_Renewal_Notification__c','Address_3__c','Address_4__c','Country__c','Country_Code__c','RecordTypeId','Company_Code__c','Department__c','Designation__c','Acknowledgement_Letter__c','Sub_Group__c','Unique_Entity_Number__c','Credit_Alert__c','Division_Code__c','Location_Code__c','RecordTypeId','Section_Code__c','Education__c','Email__c','Eshop_Ref_No__c','Email_Secondary__c','Gender__c','VIP_Email__c','VIP_Mobile__c','VIP_Staff_Home_Phone__c','Attention_Seeking_Subs__c','Additional_Info__c','City__c','Packing_Code__c','RecordTypeId','GST_Invoice__c','GST_Out_of_Scope__c','Income_Range__c','Language__c','Mobile__c'};
    String[] keyRTName = new String[]{'Direct Individual','Direct Individual','Direct SPH Inter-Division','Direct SPH Inter-Division','Direct SPH Inter-Division','Direct Individual','Direct Individual','Direct Individual','Direct Individual','Direct Individual','Direct SPH Inter-Division','Direct SPH Inter-Division','Direct Individual','Direct SPH Inter-Division','Direct SPH Inter-Division','Direct SPH Inter-Division','Direct SPH Inter-Division','Direct SPH Inter-Division','Direct SPH Inter-Division','Direct Individual','Direct Individual','Direct Individual','Direct Individual','Direct Individual','Direct Individual','Direct Individual','Direct Individual','Direct Individual','Direct Corporate','Direct SPH Inter-Division','Direct SPH Inter-Division','Local','Local','Direct Individual','Direct Corporate','Direct Corporate','Direct Corporate','Direct Corporate','Direct Corporate','Direct Corporate','Direct Corporate','Local','Direct Individual','Direct Individual','Direct Corporate','Direct Corporate','Direct Corporate','Direct Corporate','Direct Corporate','Direct Corporate','Direct Corporate','Direct Corporate','Direct Corporate','Local','Overseas','Overseas','Direct Corporate','Direct Corporate','Direct Corporate','Direct Corporate','Direct Corporate','Direct Corporate','Direct Corporate','Overseas','Overseas','Overseas','Overseas','Overseas','Internal','Internal','Direct Individual','Direct Individual','Direct Corporate','Direct Corporate','Direct Individual','Internal','Internal','Internal','Internal','Direct Individual','Direct Individual','Direct Individual','Direct Individual','Direct Individual','Direct Corporate','Direct Corporate','Direct Corporate','Direct SPH Inter-Division','Airline','Airline','Airline','Airline','Direct Individual','Direct Individual','Direct Individual','Direct Individual','Direct Individual'};
    
    for(Integer i = 0 ; i < keyName.size(); i++ )
    {
      listRtSetup.add(new Record_Type_Field_Setup__c(Name=keyName[i],Field_Name__c=valueFieldName[i],Record_Type_Name__c=keyRTName[i]));
    }
    return listRtSetup;
  }

  public static List<Public_Holiday_Pub_Indiators__c> createPublic_Holiday_Pub_Indiators(){
    List<Public_Holiday_Pub_Indiators__c> listPHPI = new List<Public_Holiday_Pub_Indiators__c>();
    listPHPI.add(new Public_Holiday_Pub_Indiators__c(Name='Pub Indicators',Weekday__c=TRUE,Weekend__c=TRUE));
    return listPHPI;
  }

  public static List<Product_Frequency__c> createProduct_Frequency(){
    List<Product_Frequency__c> listPF = new List<Product_Frequency__c>();
    listPF.add(new Product_Frequency__c(Name='0',Frequency__c='Default'));
    listPF.add(new Product_Frequency__c(Name='1',Frequency__c='Mon - Fri'));
    listPF.add(new Product_Frequency__c(Name='2',Frequency__c='Sat - Sun'));
    listPF.add(new Product_Frequency__c(Name='3',Frequency__c='Mon - Sat'));
    return listPF;
  }

  public static List<Product_Code__c> createProduct_Code(){
    List<Product_Code__c> listProdCode = new List<Product_Code__c>();
    listProdCode.add(new Product_Code__c(Name='MY',Product_Code__c='MY'));
    listProdCode.add(new Product_Code__c(Name='STSU',Product_Code__c='STSU'));
    listProdCode.add(new Product_Code__c(Name='TABL',Product_Code__c='TABL'));
    return listProdCode;
  }

  public static List<Postage_Charge__c> createPostage_Charge(){
    List<Postage_Charge__c> listPostage = new List<Postage_Charge__c>();
    listPostage.add(new Postage_Charge__c(Name='SEA',Amount__c=5.00));
    return listPostage;
  }

  
  public static List<packinglabebatch__c> createPackingLabeBatch(){
    List<packinglabebatch__c> listplb = new List<packinglabebatch__c>();
    listplb.add(new packinglabebatch__c(Name='Packing1',ToAddress__c ='TJ Mailroom 1',ToEmailID__c   ='emskdv1@sph.com.sg',ToName__c ='World Reach (Fax : 6267 5912)'));
    return listplb;    
  }
  

  public static List<Out_Of_Office__c> createOut_Of_Office(){
    List<Out_Of_Office__c> listOff = new List<Out_Of_Office__c>();
    listOff.add(new Out_Of_Office__c(Name='1',Out_of_Office_Keyword__c='Out of office'));
    listOff.add(new Out_Of_Office__c(Name='2',Out_of_Office_Keyword__c='ooo'));
    return listOff;
  }

  public static List<Other__c> createOther(){
      List<Other__c> listOther = new List<Other__c>();

      listOther.add(new Other__c(Name='CN_NUMBER_MIN',Value__c='26000000'));
      listOther.add(new Other__c(Name='CN_NUMBER_MAX',Value__c='26999999'));
      listOther.add(new Other__c(Name='APT DELIVERY CHARGE',Value__c='Apt Delivery Charge'));
      listOther.add(new Other__c(Name='HDB DELIVERY CHARGE',Value__c='HDB Delivery Charge'));
      listOther.add(new Other__c(Name='Zero Charge Amount',Value__c='Zero Charge Amount'));
      listOther.add(new Other__c(Name='LANDED DELIVERY CHARGE',Value__c='Landed Delivery Charge'));
      listOther.add(new Other__c(Name='CSO Admin',Value__c='CSO Admin'));
      listOther.add(new Other__c(Name='GST',Value__c='7'));
      listOther.add(new Other__c(Name='ARMS Latest Invoice ID',Value__c='27105597'));
      listOther.add(new Other__c(Name='ARMS SPH System Admin 2',Value__c='SPH System Admin 2'));
      listOther.add(new Other__c(Name='ARMS System Administrator',Value__c='System Administrator'));
      listOther.add(new Other__c(Name='CSO',Value__c='CSO'));
      listOther.add(new Other__c(Name='Evergreen',Value__c='EVERGREEN'));
      listOther.add(new Other__c(Name='Friday',Value__c='Fri'));
      listOther.add(new Other__c(Name='Invoice',Value__c='Invoice'));
      listOther.add(new Other__c(Name='Latest Credit Number',Value__c='20034807'));
      listOther.add(new Other__c(Name='Latest Debit Number',Value__c='13000217'));
      listOther.add(new Other__c(Name='LOG_DEBUG_ON',Value__c='TRUE'));
      listOther.add(new Other__c(Name='CN_NUMBER_NEXT',Value__c='26000030'));
      listOther.add(new Other__c(Name='OrderUpload|2015-12-22 22:36:14',Value__c='14'));
      listOther.add(new Other__c(Name='VDC_BILL_MTH',Value__c='9'));
      listOther.add(new Other__c(Name='BCC Email Set up',Value__c='cirsub@sph.com.sg'));
      listOther.add(new Other__c(Name='Saturday',Value__c='Sat'));
      listOther.add(new Other__c(Name='Sunday',Value__c='Sun'));
      listOther.add(new Other__c(Name='Postage',Value__c='Postage'));
      listOther.add(new Other__c(Name='SPH System Admin 2',Value__c='SPH System Admin 2'));
      listOther.add(new Other__c(Name='Stop Subscription',Value__c='Stop Subscription'));
      listOther.add(new Other__c(Name='TEMPSTOPCANCELLEDSTATUS',Value__c='Cancelled'));
      listOther.add(new Other__c(Name='Other',Value__c='Other'));
      listOther.add(new Other__c(Name='Mon - Sat',Value__c='Monday,Tuesday,Wednesday,Thursday,Friday,Saturday'));
      listOther.add(new Other__c(Name='Subscription Stop Completed',Value__c='Subscription Stop Completed'));
      listOther.add(new Other__c(Name='System Administrator',Value__c='System Administrator'));
      listOther.add(new Other__c(Name='ARMS Log',Value__c='ARMS Log'));
      listOther.add(new Other__c(Name='Complaint counter weeks',Value__c='112'));
      listOther.add(new Other__c(Name='ARMS Log Key',Value__c='TRUE'));
      listOther.add(new Other__c(Name='Complaint counter days',Value__c='30'));
      listOther.add(new Other__c(Name='SP18_SDT1',Value__c='',DATETIME__C=datetime.now()));//'18/04/2016 19:07'
      listOther.add(new Other__c(Name='SP18_SDT2',Value__c='',DATETIME__C=datetime.now()));//'19/04/2016 13:32'
      listOther.add(new Other__c(Name='SP18_InitializedBatch',Value__c='0'));
      listOther.add(new Other__c(Name='Invoice Total Package Char',Value__c='50'));
      listOther.add(new Other__c(Name='Invoice Total Lines',Value__c='20'));
      listOther.add(new Other__c(Name='SPH Logo v2',Value__c='SPH Logo v2'));
      listOther.add(new Other__c(Name='OrderUpload|2015-12-21 15:46:27',Value__c='12'));
      listOther.add(new Other__c(Name='Contact_Recordtype_Internal',Value__c='Internal'));
      listOther.add(new Other__c(Name='Contact_Recordtype_Airline',Value__c='Airline'));
      listOther.add(new Other__c(Name='Contact_Recordtype_Local',Value__c='Local'));
      listOther.add(new Other__c(Name='Contact_Recordtype_Overseas',Value__c='Overseas'));
      listOther.add(new Other__c(Name='Vendor Rep',Value__c='Vendor Rep'));
      listOther.add(new Other__c(Name='Vendor Sr. Manager',Value__c='Vendor Sr. Manager'));
      listOther.add(new Other__c(Name='Vendor Exec / Manager',Value__c='Vendor Exec / Manager'));
      listOther.add(new Other__c(Name='Fri - Sun',Value__c='Friday,Saturday,Sunday'));
      listOther.add(new Other__c(Name='Sat - Sun',Value__c='Saturday,Sunday'));
      listOther.add(new Other__c(Name='Grace Number of Days for Temp Stop',Value__c='8'));
      listOther.add(new Other__c(Name='Order_Line_Item Downgrade',Value__c='Downgrade'));
      listOther.add(new Other__c(Name='Product_Category Digital',Value__c='Digital'));
      listOther.add(new Other__c(Name='Order_Type COS_Package',Value__c='Change of Subscription Package'));
      listOther.add(new Other__c(Name='ARMS_CrLmtExt',Value__c='0'));
      listOther.add(new Other__c(Name='ARMS_userID',Value__c='arcrcl01'));
      listOther.add(new Other__c(Name='ARMS_CusSts',Value__c='A'));
      listOther.add(new Other__c(Name='ARMS_CoyCd',Value__c='A101'));
      listOther.add(new Other__c(Name='ARMS_AccTyp',Value__c='SS'));
      listOther.add(new Other__c(Name='ARMS CSO Admin',Value__c='CSO Admin'));
      listOther.add(new Other__c(Name='ARMS CSO Team Leader',Value__c='CSO Team Leader'));
      listOther.add(new Other__c(Name='ARMS_SysId',Value__c='SS'));
      listOther.add(new Other__c(Name='ARMS_CrLmtInt',Value__c='0'));
      listOther.add(new Other__c(Name='ARMS_password',Value__c='arms1234'));
      listOther.add(new Other__c(Name='ARMS_Unlnk',Value__c='Y'));
      listOther.add(new Other__c(Name='Vendor Conversion Cut-off Day',Value__c='20'));
      listOther.add(new Other__c(Name='DTL',Value__c='14:30'));
      listOther.add(new Other__c(Name='TempStopOnGoing',Value__c='On-Going'));
      listOther.add(new Other__c(Name='TempStopNotStarted',Value__c='Not Started'));
      listOther.add(new Other__c(Name='TempStopCompleted',Value__c='Completed'));
      listOther.add(new Other__c(Name='Order_Type Renewal',Value__c='Renewal'));
      listOther.add(new Other__c(Name='Order_Line_Item Upgrade',Value__c='Upgrade'));
      listOther.add(new Other__c(Name='Order_Line_Item Invalid',Value__c='Invalid Product Platform.'));
      listOther.add(new Other__c(Name='Order_Type Start',Value__c='Start'));
      listOther.add(new Other__c(Name='Order_Line_Item Neutral',Value__c='Neutral/Flat'));
      listOther.add(new Other__c(Name='Reason_Code Correction',Value__c='Correction'));
      listOther.add(new Other__c(Name='Mon - Fri',Value__c='Monday,Tuesday,Wednesday,Thursday,Friday'));
      listOther.add(new Other__c(Name='Order_Type Stop',Value__c='Stop'));
      listOther.add(new Other__c(Name='Product_Category Print',Value__c='Print'));
      listOther.add(new Other__c(Name='Order_Type COS_Quantity',Value__c='Change of Subscription Quantity'));
      listOther.add(new Other__c(Name='Product_Category AIO',Value__c='All in One (AIO)'));
      listOther.add(new Other__c(Name='Order_Line_Item Qty Increase',Value__c='Qty Increase'));
      listOther.add(new Other__c(Name='Reason_Code Customer Request',Value__c='Customer Request'));
      listOther.add(new Other__c(Name='Order_Line_Item Qty Decrease',Value__c='Qty Decrease'));
      listOther.add(new Other__c(Name='Product_Category Magazine',Value__c='Magazine'));
      listOther.add(new Other__c(Name='Reason_Code Auto Renew',Value__c='Auto Renew'));
      listOther.add(new Other__c(Name='ARMS_CrTrm',Value__c='30'));
      listOther.add(new Other__c(Name='ARMS UpdateID',Value__c='SS'));
      listOther.add(new Other__c(Name='ARMS_DbtStrt',Value__c='NORM'));
      listOther.add(new Other__c(Name='ARMS_CrTrmRef',Value__c='I'));
      listOther.add(new Other__c(Name='ARMS_DbtExp',Value__c='0'));
      listOther.add(new Other__c(Name='ARMS Creator Id',Value__c='SS'));
      //Start UD-3207: VPernicia
      listOther.add(new Other__c(Name='ARMS Initial Invoice',Value__c='0027000000'));
      //End UD-3207: VPernicia

      return listOther;
  }

  public static void createZuora_MigrationSettings(){
    // Not available 
  }

  public static List<MASS_CONFIG__c> createMASS_CONFIG(){
    List<MASS_CONFIG__c> listMassConf = new List<MASS_CONFIG__c>();

    listMassConf.add(new MASS_CONFIG__c(Name='APT_PRICE',Value__c='2'));
    listMassConf.add(new MASS_CONFIG__c(Name='HDB_PRICE',Value__c='6'));
    listMassConf.add(new MASS_CONFIG__c(Name='LANDED_PRICE',Value__c='10'));
    listMassConf.add(new MASS_CONFIG__c(Name='MCOP_PRD_CODES',Value__c='STSU,BHBM'));
    return listMassConf;
  }

  public static List<Key_Id__c> createKey_Id(){
    /*List<Key_Id__c> listKeyId = new List<Key_Id__c>();
    String[] keyName = new String[]{'BILL_RUN_TESTING','PaymentMethodId_Check','DeliveryCharge_W','VendorCredit_A','VendorCredit_B','VendorCredit_C','VendorCredit_G','VendorCredit_K','VendorCredit_P','VendorCredit_U','DeliveryCharge_S','VendorCredit_S','Default Mailing Agent','Profile_Standard User Custom','Vendor Subscriber','Default Quote Charge','Read Only Quote','Case_Enquiry','Start Subscription','Case_Start Sub','Case_Stop','Case_Temp Stop','Temp Stop Subscription','Complaint_Newspaper','Case_Complaint Magazine','Case_Reset Password','Case_Digital','Reset_Password','Create_User','Deactivate_User','Force_Logout','Case_Refund','Case_Change of Credit Card','Case_Change of Payment Type','Case_Change in Address','Case_Particulars','Case_Retention','Case_Change of Subscription','Case Renewal of Subscription','Case_Bypass Credit Card','Case_Adjustments','Vendor Predefined Case Role','Vendor Rep Role','CSO Admin','AddAirline','Batch Number','Cir Predefined Case Team','CSO Predefined Case Team','Predefine Case Team: CSO Admin','SubTypeDel','AddInternal','AddLocal','AddOverseas','SubTypePub','VendorCredit_H','VendorCredit_W','DeliveryCharge','DeliveryCharge_A','DeliveryCharge_B','DeliveryCharge_C','DeliveryCharge_G','DeliveryCharge_K','DeliveryCharge_P','DeliveryCharge_U','Renewal of Subscription','DELCHG_APT','DELCHG_HDB','DELCHG_LAND','DELCHG_ZERO','CurrencySGD','QuoteInvoiceProcessingAccount','QuoteInvoiceProcessingSubscription','SubTermTypeEvergreen','SubTermTypeTermed','Retention_Outbound_Queue','SubTypeGift','Publication Delivered By','EshopDuration','CRSMDuration','Billing_Account_Case_Field','ZuoraPaymentMethod_Other','DaysBeforeSubEndDate_RenewalOfSub','DaysBeforeSubscriptionEndDate','CSO Queue','UpdateARMSInfoResultId','Contact_Customer Contact','GracePeriodDaysBeforeEndDate','Add On','Head of Customer Service Queue','CSO Asst. Manager/ Manager Queue','CSO TL Queue','Retention Queue','NEXT_RECIPIENT_NUMBER','Case_Complaint Newspaper','RetentionOutboundSixWeeks','Ven Ops N&E Cir Reps Queue','Case_Complaint Digital','BAfieldID','ZUORA_RETRY_TIMES','Ven Ops W&C Cir Reps Queue','SMS104DX Invalid characters','SubTypePostage','Profile_Partner Community User','Profile_Read Only','Profile_Solution Manager','Profile_Standard Platform User','Profile_Standard User','Profile_System Administrator','Account_Direct Corporate','Account_Direct Individual','Account_Direct SPH Inter-Division','Account_Mailing Agent','Account_Vendor','Account_Vendor Subscriber','Address_Airline','Address_Internal','Address_Local','Address_Overseas','Contact_Billing Contact','Contact_Recipient Contact','Contact_Vendor Contact','Contact_Vendor Staff','Contact_Vendor-MA','Package Item_Base Product','Package Item_Bundle Discount','Package Item_Bundle Product','Package Item_Discount','Package Item_Extension Discount','Package Item_Extension Product','Profile_Chatter External User','Profile_Chatter Free User','Profile_Chatter Moderator User','Profile_Contract Manager','Profile_Marketing User','Zuora_PaymentMethodId_Cash','PaymentMethodId_Cash'};
    String[] keyType = new String[]{'Boolean','PaymentMethodId','Delivery Charge','Vendor Credit','Vendor Credit','Vendor Credit','Vendor Credit','Vendor Credit','Vendor Credit','Vendor Credit','Delivery Charge','Vendor Credit','','Profile','RecordType','Record','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','Record Type','RecordType','RecordType','Record Type','RecordType','RecordType','RecordType','Case Team Role','Case Team Role','Case Team Role','Name','Field','Name','Name','Name','Name','Name','Name','Name','Name','Vendor Credit','Vendor Credit','Delivery Charge','Delivery Charge','Delivery Charge','Delivery Charge','Delivery Charge','Delivery Charge','Delivery Charge','Delivery Charge','RecordType','Delivery Charge Type','Delivery Charge Type','Delivery Charge Type','Delivery Charge Type','Name','Name','Name','Name','Name','Queue','Name','Vendor or Mailing Agent','Number of Months','Number of Months','Custom Field Id','ZuoraPaymentMethodId','Integer','Integer','Id','ID','Record Type','Integer','PackageType','Id','Id','Id','String','','Record Type','Integer','Queue','RecordType','BillingAccountFieldID','Integer','Queue','','Name','Profile','Profile','Profile','Profile','Profile','Profile','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','RecordType','Profile','Profile','Profile','Profile','Profile','Zuora Id','PaymentMethodId'};
    String[] keyId = new String[]{'TRUE','2c92c0f843dca14e0143e429e79c6f08','4','4','4','4','4','4','4','4','5','5','001N000000cC5v4','00eN0000000HnG8','01290000001AgH8AAK','01290000001Ag0MAAS','01290000001Ag0NAAS','01290000001AgHOAA0','01290000001AgHSAA0','01290000001AgHSAA0','01290000001AgHTAA0','01290000001AgHUAA0','01290000001AgHUAA0','01290000001AgHNAA0','01290000001AgHMAA0','01290000001AgHfAAK','01290000001AgHFAA0','01290000001AgHfAAK','01290000001AgHcAAK','01290000001AgHdAAK','01290000001AgHeAAK','01290000001AgHPAA0','01290000001AgHIAA0','01290000001AgHKAA0','01290000001AgHHAA0','01290000001AgHJAA0','01290000001AgHRAA0','01290000001AgHLAA0','01290000001AgHQAA0','01290000001AgHEAA0','01290000001AgHDAA0','0B490000000L0D2CAK','0B790000000KzelCAC','0B790000000KzeWCAS','Airline','Batch20','Cir Planner','CSO Admin','CSO Admin','Delivery','Internal','Local','Overseas','Publication','3','3','4','4','4','4','4','4','4','4','01290000001AgHQAA0','Delivery Charge Condo/Office','Delivery Charge HDB','Delivery Charge Landed','Zero Charge Amount','SGD','Account','Subscription','Evergreen','Termed','00G90000001dVKB','Gift','Vendor or Mailing Agent','3','6','CF00N9000000DmvrN','2c92c0f843dca14e0143e429e7ea6f1c','42','1','00G90000001dVK5EAM','123vd','01290000001AgHXAA0','2','Add On','00G90000001dVK9EAM','00G90000001dVK4EAM','00G90000001dVK6EAM','00G90000001dVKB','30465087','01290000001AgHNAA0','14','00G90000001dVKD','01290000001AgHFAA0','00N9000000DmeNu','3','00G90000001dVKE','\'/$/"','Postage','00e90000000gfKNAAY','00e90000001VZOxAAO','00e90000001VZOyAAO','00e90000000gh1LAAQ','00e90000001VZOwAAO','00e90000001VZOqAAO','01290000001AgH3AAK','01290000001AgH4AAK','01290000001AgH5AAK','01290000001AgH6AAK','01290000001AgH7AAK','01290000001AgH8AAK','01290000001AgH9AAK','01290000001AgHAAA0','01290000001AgHBAA0','01290000001AgHCAA0','01290000001AgHWAA0','01290000001AgHYAA0','01290000001AgHZAA0','01290000001AgHbAAK','01290000001AgHaAAK','01290000001AgHhAAK','01290000001AgHiAAK','01290000001AgHjAAK','01290000001AgHkAAK','01290000001AgHlAAK','01290000001AgHmAAK','00e90000001VZP3AAO','00e90000001VZOtAAO','00e90000001VZP2AAO','00e90000001VZP0AAO','00e90000001VZOzAAO','2c92c0f843dca14e0143e429e7d96f18','2c92c0f843dca14e0143e429e7d96f18'};
     for(Integer i = 0 ; i < keyName.size(); i++ )
      {
        listKeyId.add(new Key_Id__c(Name=keyName[i],Id__c=keyId[i],Type__c=keyType[i]));
      }
    return listKeyId;*/
    List<Key_Id__c> listKeyId = new List<Key_Id__c>();

    ///////////////////////////////////////////////////////
    // SFDC RecordType Id's
    Map<String,String> mapRT = new Map<String,String>();
    
    mapRT.put('Case_Change in Address','Change_of_Address');
    mapRT.put('Case_Change of Subscription','Change_of_Subscription');
    mapRT.put('Case_Complaint Newspaper','Complaint_Newspaper');
    mapRT.put('Contact_Customer Contact','Customer_Contact');
    mapRT.put('Account_Direct Corporate','Direct_Corporate');
    mapRT.put('Account_Direct Individual','Direct_Individual');
    mapRT.put('Account_Direct SPH Inter-Division','Direct_SPH_Inter_Division');
    mapRT.put('Account_Mailing Agent','Mailing_Agent');
    mapRT.put('Account_Vendor','Vendor');
    mapRT.put('Account_Vendor Subscriber','Vendor_Subscriber');
    mapRT.put('Address_Airline','Airline');
    mapRT.put('Address_Internal','Internal');
    mapRT.put('Address_Local','Local');
    mapRT.put('Address_Overseas','Overseas');
    mapRT.put('Case Renewal of Subscription','Renewal_of_Subscription');
    mapRT.put('Case_Adjustments','Adjustments');
    mapRT.put('Case_Bypass Credit Card','Bypass_Credit_Card');
    mapRT.put('Case_Change of Credit Card','Change_of_Credit_Card');
    mapRT.put('Case_Change of Payment Type','Change_of_Payment_Type');
    mapRT.put('Case_Complaint Digital','Case_Complaint_Digital');
    mapRT.put('Case_Complaint Magazine','Complaint_Magazine');
    mapRT.put('Case_Digital','Case_Complaint_Digital');
    mapRT.put('Case_Enquiry','Enquiry');
    mapRT.put('Case_Particulars','Change_of_Particulars');
    mapRT.put('Case_Refund','Refund');
    mapRT.put('Case_Reset Password','Reset_Password');
    mapRT.put('Case_Retention','Retention_Outbound');
    mapRT.put('Case_Start Sub','Start_Subscription');
    mapRT.put('Case_Stop','Stop_Subscription');
    mapRT.put('Case_Temp Stop','Temp_Stop_Subscription');
    mapRT.put('Complaint_Newspaper','Complaint_Newspaper');
    mapRT.put('Contact_Billing Contact','Billing_Contact');
    mapRT.put('Contact_Recipient Contact','Recipient_Contact');
    mapRT.put('Contact_Vendor Contact','Vendor_Contact');
    mapRT.put('Contact_Vendor Staff','Vendor_Staff');
    mapRT.put('Contact_Vendor-MA','Vendor_MA');
    mapRT.put('Create_User','Create_User');
    mapRT.put('Deactivate_User','Deactivate_User');
    mapRT.put('Force_Logout','Force_Logout');
    mapRT.put('Package Item_Base Product','Base_Product');
    mapRT.put('Package Item_Bundle Discount','Bundle_Discount');
    mapRT.put('Package Item_Bundle Product','Bundle_Product');
    mapRT.put('Package Item_Discount','Discount');
    mapRT.put('Package Item_Extension Discount','Extension_Discount');
    mapRT.put('Package Item_Extension Product','Extension_Product');
    mapRT.put('Read Only Quote','ReadOnly');
    mapRT.put('Renewal of Subscription','Renewal_of_Subscription');
    mapRT.put('Reset_Password','Reset_Password');
    mapRT.put('Start Subscription','Start_Subscription');
    mapRT.put('Temp Stop Subscription','Temp_Stop_Subscription');
    mapRT.put('Vendor Subscriber','Vendor_Subscriber');

    List<RecordType> listRT = [SELECT id,DeveloperName,SobjectType FROM RecordType WHERE DeveloperName IN: mapRT.values()];
    for(RecordType tmp : listRT){
        Set<String> tempKeyList = new Set<String>();
        for(String mapKey : mapRT.keySet()){
            if(mapRT.get(mapKey) == tmp.DeveloperName && tmp.SobjectType != 'zqu__QuoteCharge__c'){
                //tempKeyList.add(mapKey);
                listKeyId.add(new Key_Id__c(Name=mapKey , Id__c=tmp.id,Type__c='RecordType'));
            }
        }
        /*
        for(String tmpSet : tempKeyList){
            listKeyId.add(new Key_Id__c(Name=tmpSet,Id__c=tmp.id,Type__c='RecordType'));
        }
        */
    }

    ///////////////////////////////////////////////////////////////////////////
    // Profile
    Map<String,String> mapProfile = new Map<String,String>();
    mapProfile.put('Profile_Chatter External User','Chatter External User');
    mapProfile.put('Profile_Chatter Free User','Chatter Free User');
    mapProfile.put('Profile_Chatter Moderator User','Chatter Moderator User');
    mapProfile.put('Profile_Contract Manager','Contract Manager');
    mapProfile.put('Profile_Marketing User','Marketing User');
    mapProfile.put('Profile_Partner Community User','Partner Community User');
    mapProfile.put('Profile_Read Only','Read Only');
    mapProfile.put('Profile_Solution Manager','Solution Manager');
    mapProfile.put('Profile_Standard Platform User','Standard Platform User');
    mapProfile.put('Profile_Standard User','Standard User');
    //mapProfile.put('Profile_Standard User Custom','00eN0000000HnG8');
    mapProfile.put('Profile_System Administrator','System Administrator');
    List<Profile> listProf = [SELECT Id,Name FROM Profile WHERE Name IN: mapProfile.values()];
    for(Profile tmp : listProf){
        Set<String> tempKeyList = new Set<String>();
        for(String mapKey : mapProfile.keySet()){
            if(mapProfile.get(mapKey) == tmp.Name){
                tempKeyList.add(mapKey);
            }
        }

        for(String tmpSet : tempKeyList){
            listKeyId.add(new Key_Id__c(Name=tmpSet,Id__c=tmp.id,Type__c='Profile'));
        }

    }

    /////////////////////////////////////////////////////////////////////////
    // OTHERS
    listKeyId.add(new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER',Id__c='30000000')); //START/END Gdelrosario PD-0138
    listKeyId.add(new Key_Id__c(Name='VendorCredit_A',Id__c='4',Type__c='Vendor Credit'));
    listKeyId.add(new Key_Id__c(Name='VendorCredit_B',Id__c='4',Type__c='Vendor Credit'));
    listKeyId.add(new Key_Id__c(Name='VendorCredit_C',Id__c='4',Type__c='Vendor Credit'));
    listKeyId.add(new Key_Id__c(Name='VendorCredit_G',Id__c='4',Type__c='Vendor Credit'));
    listKeyId.add(new Key_Id__c(Name='VendorCredit_H',Id__c='3',Type__c='Vendor Credit'));
    listKeyId.add(new Key_Id__c(Name='VendorCredit_K',Id__c='4',Type__c='Vendor Credit'));
    listKeyId.add(new Key_Id__c(Name='VendorCredit_P',Id__c='4',Type__c='Vendor Credit'));
    listKeyId.add(new Key_Id__c(Name='VendorCredit_S',Id__c='5',Type__c='Vendor Credit'));
    listKeyId.add(new Key_Id__c(Name='VendorCredit_U',Id__c='4',Type__c='Vendor Credit'));
    listKeyId.add(new Key_Id__c(Name='VendorCredit_W',Id__c='3',Type__c='Vendor Credit'));
    listKeyId.add(new Key_Id__c(Name='Publication Delivered By',Id__c='Vendor or Mailing Agent',Type__c='Vendor or Mailing Agent'));
    listKeyId.add(new Key_Id__c(Name='Zuora_PaymentMethodId_Cash',Id__c='2c92c0f843dca14e0143e429e7d96f18',Type__c='Zuora Id'));
    listKeyId.add(new Key_Id__c(Name='ZuoraPaymentMethod_Other',Id__c='2c92c0f843dca14e0143e429e7ea6f1c',Type__c='ZuoraPaymentMethodId'));
    //listKeyId.add(new Key_Id__c(Name='NEXT_RECIPIENT_NUMBER',Id__c='30465094'));
    listKeyId.add(new Key_Id__c(Name='DeliveryCharge',Id__c='4',Type__c='Delivery Charge'));
    listKeyId.add(new Key_Id__c(Name='DeliveryCharge_A',Id__c='4',Type__c='Delivery Charge'));
    listKeyId.add(new Key_Id__c(Name='DeliveryCharge_B',Id__c='4',Type__c='Delivery Charge'));
    listKeyId.add(new Key_Id__c(Name='DeliveryCharge_C',Id__c='4',Type__c='Delivery Charge'));
    listKeyId.add(new Key_Id__c(Name='DeliveryCharge_G',Id__c='4',Type__c='Delivery Charge'));
    listKeyId.add(new Key_Id__c(Name='DeliveryCharge_K',Id__c='4',Type__c='Delivery Charge'));
    listKeyId.add(new Key_Id__c(Name='DeliveryCharge_P',Id__c='4',Type__c='Delivery Charge'));
    listKeyId.add(new Key_Id__c(Name='DeliveryCharge_S',Id__c='5',Type__c='Delivery Charge'));
    listKeyId.add(new Key_Id__c(Name='DeliveryCharge_U',Id__c='4',Type__c='Delivery Charge'));
    listKeyId.add(new Key_Id__c(Name='DeliveryCharge_W',Id__c='4',Type__c='Delivery Charge'));
    listKeyId.add(new Key_Id__c(Name='DELCHG_APT',Id__c='Delivery Charge Condo/Office',Type__c='Delivery Charge Type'));
    listKeyId.add(new Key_Id__c(Name='DELCHG_HDB',Id__c='Delivery Charge HDB',Type__c='Delivery Charge Type'));
    listKeyId.add(new Key_Id__c(Name='DELCHG_LAND',Id__c='Delivery Charge Landed',Type__c='Delivery Charge Type'));
    listKeyId.add(new Key_Id__c(Name='DELCHG_ZERO',Id__c='Zero Charge Amount',Type__c='Delivery Charge Type'));
    listKeyId.add(new Key_Id__c(Name='Batch Number',Id__c='Batch20',Type__c='Field'));
    listKeyId.add(new Key_Id__c(Name='DaysBeforeSubEndDate_RenewalOfSub',Id__c='42',Type__c='Integer'));
    listKeyId.add(new Key_Id__c(Name='DaysBeforeSubscriptionEndDate',Id__c='1',Type__c='Integer'));
    listKeyId.add(new Key_Id__c(Name='GracePeriodDaysBeforeEndDate',Id__c='2',Type__c='Integer'));
    listKeyId.add(new Key_Id__c(Name='RetentionOutboundSixWeeks',Id__c='14',Type__c='Integer'));
    listKeyId.add(new Key_Id__c(Name='ZUORA_RETRY_TIMES',Id__c='3',Type__c='Integer'));
    listKeyId.add(new Key_Id__c(Name='AddAirline',Id__c='Airline',Type__c='Name'));
    listKeyId.add(new Key_Id__c(Name='AddInternal',Id__c='Internal',Type__c='Name'));
    listKeyId.add(new Key_Id__c(Name='AddLocal',Id__c='Local',Type__c='Name'));
    listKeyId.add(new Key_Id__c(Name='AddOverseas',Id__c='Overseas',Type__c='Name'));
    listKeyId.add(new Key_Id__c(Name='Cir Predefined Case Team',Id__c='Cir Planner',Type__c='Name'));
    listKeyId.add(new Key_Id__c(Name='CSO Predefined Case Team',Id__c='CSO Admin',Type__c='Name'));
    listKeyId.add(new Key_Id__c(Name='CurrencySGD',Id__c='SGD',Type__c='Name'));
    listKeyId.add(new Key_Id__c(Name='Predefine Case Team: CSO Admin',Id__c='CSO Admin',Type__c='Name'));
    listKeyId.add(new Key_Id__c(Name='QuoteInvoiceProcessingAccount',Id__c='Account',Type__c='Name'));
    listKeyId.add(new Key_Id__c(Name='QuoteInvoiceProcessingSubscription',Id__c='Subscription',Type__c='Name'));
    listKeyId.add(new Key_Id__c(Name='SubTermTypeEvergreen',Id__c='Evergreen',Type__c='Name'));
    listKeyId.add(new Key_Id__c(Name='SubTermTypeTermed',Id__c='Termed',Type__c='Name'));
    listKeyId.add(new Key_Id__c(Name='SubTypeDel',Id__c='Delivery',Type__c='Name'));
    listKeyId.add(new Key_Id__c(Name='SubTypeGift',Id__c='Gift',Type__c='Name'));
    listKeyId.add(new Key_Id__c(Name='SubTypePostage',Id__c='Postage',Type__c='Name'));
    listKeyId.add(new Key_Id__c(Name='SubTypePub',Id__c='Publication',Type__c='Name'));
    listKeyId.add(new Key_Id__c(Name='CRSMDuration',Id__c='6',Type__c='Number of Months'));
    listKeyId.add(new Key_Id__c(Name='EshopDuration',Id__c='3',Type__c='Number of Months'));
    listKeyId.add(new Key_Id__c(Name='Add On',Id__c='Add On',Type__c='PackageType'));
    listKeyId.add(new Key_Id__c(Name='BILL_RUN_TESTING',Id__c='TRUE',Type__c='Boolean'));
    listKeyId.add(new Key_Id__c(Name='UpdateARMSInfoResultId',Id__c='123vd',Type__c='ID'));
    listKeyId.add(new Key_Id__c(Name='SMS104DX Invalid characters',Id__c='\'/$/"',Type__c=''));


    ////////////////////////////////////////////////////////////////
    // QUEUE
    List<String> listQueueName = new List<String>();
    listQueueName.add('Ven_Ops_W_C_Cir_Reps_Queue');
    listQueueName.add('Retention_Queue');
    listQueueName.add('Ven_Ops_N_E_Cir_Reps_Queue');
    listQueueName.add('Head_of_Customer_Service_Queue');
    listQueueName.add('CSO_Queue');
    listQueueName.add('CSO_Team_Leader_Queue');
    listQueueName.add('CSO_Asst_Manager_Manager_Queue');
    for(Group tmp : [SELECT DeveloperName,Id,Name,Type FROM Group WHERE Type = 'Queue' AND DeveloperName IN: listQueueName]){
        if(tmp.DeveloperName == 'Ven_Ops_W_C_Cir_Reps_Queue'){
            listKeyId.add(new Key_Id__c(Name='Ven Ops N&E Cir Reps Queue',Id__c=tmp.id,Type__c='Queue'));
        }else if(tmp.DeveloperName == 'Retention_Queue'){
            listKeyId.add(new Key_Id__c(Name='Retention_Outbound_Queue',Id__c=tmp.id,Type__c='Queue'));
            listKeyId.add(new Key_Id__c(Name='Retention Queue',Id__c=tmp.id,Type__c='String')); 
        }else if(tmp.DeveloperName == 'Ven_Ops_N_E_Cir_Reps_Queue'){
            listKeyId.add(new Key_Id__c(Name='Ven Ops W&C Cir Reps Queue',Id__c=tmp.id,Type__c='Queue'));
        }else if(tmp.DeveloperName == 'Head_of_Customer_Service_Queue'){
            listKeyId.add(new Key_Id__c(Name='Head of Customer Service Queue',Id__c=tmp.id,Type__c='Id'));
        }else if(tmp.DeveloperName == 'CSO_Queue'){
            listKeyId.add(new Key_Id__c(Name='CSO Queue',Id__c=tmp.id,Type__c='Id'));
        }else if(tmp.DeveloperName == 'CSO_Team_Leader_Queue'){
            listKeyId.add(new Key_Id__c(Name='CSO TL Queue',Id__c=tmp.id,Type__c='Id'));
        }else if(tmp.DeveloperName == 'CSO_Asst_Manager_Manager_Queue'){
            listKeyId.add(new Key_Id__c(Name='CSO Asst. Manager/ Manager Queue',Id__c=tmp.id,Type__c='Id'));
        }
    }


    ///////////////////////////////////////////////////////////////////////////
    // HARDCODED
    listKeyId.add(new Key_Id__c(Name='BAfieldID',Id__c='00N9000000DmeNu',Type__c='BillingAccountFieldID'));
    listKeyId.add(new Key_Id__c(Name='CSO Admin',Id__c='0B790000000KzeWCAS',Type__c='Case Team Role'));
    listKeyId.add(new Key_Id__c(Name='Vendor Predefined Case Role',Id__c='0B490000000L0D2CAK',Type__c='Case Team Role'));
    listKeyId.add(new Key_Id__c(Name='Vendor Rep Role',Id__c='0B790000000KzelCAC',Type__c='Case Team Role'));
    listKeyId.add(new Key_Id__c(Name='Billing_Account_Case_Field',Id__c='CF00N9000000DmvrN',Type__c='Custom Field Id'));
   
   
    listKeyId.add(new Key_Id__c(Name='PaymentMethodId_Cash',Id__c='2c92c0f843dca14e0143e429e7d96f18',Type__c='PaymentMethodId'));
    listKeyId.add(new Key_Id__c(Name='PaymentMethodId_Check',Id__c='2c92c0f843dca14e0143e429e79c6f08',Type__c='PaymentMethodId'));
    listKeyId.add(new Key_Id__c(Name='Default Quote Charge',Id__c='01290000001Ag0MAAS',Type__c='Record'));
    listKeyId.add(new Key_Id__c(Name='Default Mailing Agent',Id__c='001N000000cC5v4',Type__c=''));


    return listKeyId;
  }

  public static List<Integration_Settings__c> createIntegration_Settings(){
    List<Integration_Settings__c> listIntSet = new List<Integration_Settings__c>();
    listIntSet.add(new Integration_Settings__c(Name='ApplicationJSON',Value__c='application/json'));
    listIntSet.add(new Integration_Settings__c(Name='Content-Type',Value__c='ContentType'));
    listIntSet.add(new Integration_Settings__c(Name='Endpoint Delegator',Value__c='http://tstcrsm.sph.com.sg/sqeaone/Asia1/RegAuth2/asiaOneDelegator'));
    listIntSet.add(new Integration_Settings__c(Name='PostMethod',Value__c='POST'));
    return listIntSet;
  }

  public static List<Error_Messages__c> createError_Messages(){
      List<Error_Messages__c> listEMsg = new List<Error_Messages__c>();
      listEMsg.add(new Error_Messages__c(Name='CAMPostalCodeError',APEX_CLASS_TRIGGER_NAME__C='CAM_CreateModifyContactAddressController',DESCRIPTION__C='Need postal code to avoid soql',MESSAGE__C='Please input postal code for refined address search.',METHOD_NAME__C='search()'));
      listEMsg.add(new Error_Messages__c(Name='SingPostError',APEX_CLASS_TRIGGER_NAME__C='AddressTriggerHandler',DESCRIPTION__C='',MESSAGE__C='Address does not exist in AddressDetails object. Please create desired address in Address Details to continue.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='BundleStopSubsOverrideValDiffError',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='All Subscriptions within the same Bundle must be overriden or not!',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='BundleStopSubsFeeWaiverDifferenceError',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='All Subscriptions within the same Bundle must have the same Fee Waiver Value!',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Error Encountered',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='An error was encountered while trying to process your request.',MESSAGE__C='An error was encountered while trying to process your request.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Status Code',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Status Code:',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Adjustment to Zuora Error',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Error sending the Adjustment to Zuora',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Error Fetching Account Details',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Error trying to fetch Account details.',MESSAGE__C='Error trying to fetch Account details.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='No Recipient Contact',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Account must have existing Recipient Contact.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='PleaseSelectPostalCode',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Please Select Postal Code',MESSAGE__C='Please Select Postal Code',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='SuccessfullyCreatedRefund',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Successfully Created Refund',MESSAGE__C='Successfully Created Refund',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='UnitAtLeastTwoChars',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Unit must be at least two characters',MESSAGE__C='Unit must be at least two characters',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='FailedCreateRefundForBA',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Failed to create Refund for Billing Account',MESSAGE__C='Failed to create Refund for Billing Account',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='BlankPostalCode',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Postal Code cannot be empty.',MESSAGE__C='Postal Code cannot be empty.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='InvalidPaymentDate',APEX_CLASS_TRIGGER_NAME__C='CreateAdhocPayment',DESCRIPTION__C='Invalid Payment Date',MESSAGE__C='Invalid Payment Date. Payment date should less than or equal to today.',METHOD_NAME__C='CreateAdhocPayment'));
      listEMsg.add(new Error_Messages__c(Name='PleaseSelectAddressOrNewOne',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Please select an existing Address record or create a New one',MESSAGE__C='Please select an existing Address record or create a New one',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='PleaseSelectAddressType',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Please select an address type',MESSAGE__C='Please select an address type',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='InvalidBillingAccount',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Invalid Billing Account',MESSAGE__C='Invalid Billing Account',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='InvalidTempStopDurationCRSM',APEX_CLASS_TRIGGER_NAME__C='TempStopDirectController',DESCRIPTION__C='Custom Setting Value of CRSMMax Duration is @Key Id.',MESSAGE__C='Temp Stop Duration for CRSM is Invalid.',METHOD_NAME__C='setSelectedRecords'));
      listEMsg.add(new Error_Messages__c(Name='ARMS Unlink Confirm',APEX_CLASS_TRIGGER_NAME__C='ARMS_UnlinkArmsAccController',DESCRIPTION__C='',MESSAGE__C='The ARMS Account will be unlinked.',METHOD_NAME__C='updateBillAccount'));
      listEMsg.add(new Error_Messages__c(Name='ARMS select one Customer only',APEX_CLASS_TRIGGER_NAME__C='Please select one Customer only.',DESCRIPTION__C='',MESSAGE__C='SM_StartSubscriptionEntryController',METHOD_NAME__C='addPopAcc'));
      listEMsg.add(new Error_Messages__c(Name='InvalidDTLtime',APEX_CLASS_TRIGGER_NAME__C='SM_SubscriptionHelper Apex Class',DESCRIPTION__C='',MESSAGE__C='Warning: Invalid DTL time configured in custom settings. Default value (14:00) is now use.',METHOD_NAME__C='getDtlDate'));
      listEMsg.add(new Error_Messages__c(Name='PlsTickBillingIndicatorRecipientOrBoth',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Please tick Billing Indicator, Recipient Indicator or both.',MESSAGE__C='Please tick Billing Indicator, Recipient Indicator or both.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='ErrorFetchingAccountDetails',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Error trying to fetch Account details.',MESSAGE__C='Error trying to fetch Account details. Error:',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='No Order in Retention Record',APEX_CLASS_TRIGGER_NAME__C='SM_RenewalOfSubscriptionDetail',DESCRIPTION__C='This is for custom button',MESSAGE__C='Record has no order record associated to it. Renewal cannot proceed.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='No Order Line Item',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='No Order Line Item associated to the Order.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Error Test',APEX_CLASS_TRIGGER_NAME__C='xPlaygroundController',DESCRIPTION__C='This error will display when clicking the Fire Me button from xPlayground VF page.',MESSAGE__C='This error will display when clicking the Fire Me button from xPlayground VF page.',METHOD_NAME__C='demoError'));
      listEMsg.add(new Error_Messages__c(Name='Prevent Email Deletion',APEX_CLASS_TRIGGER_NAME__C='EmailMessageTriggerHandler',DESCRIPTION__C='Records created via email cannot be deleted.',MESSAGE__C='Email record cannot be deleted!',METHOD_NAME__C='beforeDelete(SObject so)'));
      listEMsg.add(new Error_Messages__c(Name='Error for Out of Office Replies',APEX_CLASS_TRIGGER_NAME__C='EmailMessageTriggerHandler',DESCRIPTION__C='There will be no created case records for out of office replies.',MESSAGE__C='Out of office email cant be added to email records.',METHOD_NAME__C='beforeInsert(SObject so)'));
      listEMsg.add(new Error_Messages__c(Name='Duplicate Address Error',APEX_CLASS_TRIGGER_NAME__C='AssignSubscriptionExtension',DESCRIPTION__C='New Address  after CoA cannot be equal to Old Address on the Contact record',MESSAGE__C='New Address cannot be equal to Old Address',METHOD_NAME__C='submit'));
      listEMsg.add(new Error_Messages__c(Name='Required Asia1',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Displays when creating an Order Line Item that the associated product is digital and no Asia1 has been attached to it.',MESSAGE__C='Asia1 must be created if Product is digital.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Generic Error',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='error message to be thrown for generic exceptions.',MESSAGE__C='An error was encountered while processing your request. Stack Trace:',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Required Field',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Can be reused in any apex components',MESSAGE__C='Required Field is Missing',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Terms And Condition',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Displays when creating an Order Line Item but not accepting the Terms and Condition.',MESSAGE__C='Tems and Condition must be accepted.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Invalid_Amount',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Invalid Amount. Please provide amount greater than Zero.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Invalid_Date',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Invalid Date',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='ARMS Existing invoice',APEX_CLASS_TRIGGER_NAME__C='SM_StartSubscriptionEntryController',DESCRIPTION__C='Shows the error message if there is an existing invoice billing account.',MESSAGE__C='There is an existing Invoice Billing Account, please use the Search ARMS Customer or use the existing Invoice Billing Account.',METHOD_NAME__C='getBillAccName'));
      listEMsg.add(new Error_Messages__c(Name='CS_VendorField Error',APEX_CLASS_TRIGGER_NAME__C='SubscriptionTriggerHandler',DESCRIPTION__C='For Change of Subscription validation of vendor field.',MESSAGE__C='Vendor Field is required.',METHOD_NAME__C='validateVendorField'));
      listEMsg.add(new Error_Messages__c(Name='Contact RecordType not valid',APEX_CLASS_TRIGGER_NAME__C='ChangeInAddressExtensionNew',DESCRIPTION__C='Selected Conatct record type cannot create case with Change of Billing Address and Change of Billing Address and Delivery',MESSAGE__C='Contact RecordType not valid',METHOD_NAME__C='save'));
      listEMsg.add(new Error_Messages__c(Name='ErrorTryingToSaveCaseError',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Error trying to save case. Error:',MESSAGE__C='Error trying to save case. Error:',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Effective Date',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Input date must be greater than today.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Invalid Restart Date 3',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Restart Date cannot be earlier than Temp Stop Date.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='InvalidStopRequestDate',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Stop Request Date must be later than today.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='No Subscription Selected',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Please add subscription.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Invalid Temp Stop Request Dates',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Temp Stop - Vendor',MESSAGE__C='New temp stop request dates overlap with an existing temp stop request.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Invalid Restart Date 2',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='New Restart Date overlaps with an existing temp stop request.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Invalid Restart Date',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Temp Stop Subs - Vendor error message',MESSAGE__C='Restart date should be publication day',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Overlapping',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='The date inputs overlap with an existing Temp Stop Record.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='No Subscription',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='No subscription associated to this account. Subscription Status = Active Subscripton. Main Package is not empty. Subscription Type is not Delivery.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Invalid Subscription Id',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Invalid subscription Id or no subscription has been selected.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Validate Temp Stop Limit',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Temp Stop Quantity must not exceed the Current Quantity',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Required Billing Account',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Displays when saving an Order where Use Existing Billing Account was selected and no Billing Account was entered',MESSAGE__C='Billing Account must be provided.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Required Recipient Contact',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Displays when try to saving an Order when no Recipient Contact was entered',MESSAGE__C='Recipient Contact must be provided.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='InvalidStopRequestDateNonPub',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Stop Request Date must be a Publication Day.',MESSAGE__C='Stop Request Date must not fall on Non - Publication Day.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Invalid Temp Stop Date2',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Temp Stop date must be greater than the current date.',MESSAGE__C='Tempstop date should be greater than current date.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Non Publication Date',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Stop request date must not fall in Non Publication Dates',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Invalid Restart Date 4',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Restart Date cannot be equal to Temp Stop Date.',MESSAGE__C='Restart Date cannot be equal to Temp Stop Date.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Incomplete Inputs',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Please complete the required fields',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Invalid Date Input',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Please enter a valid date',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='SearchPackageResultLimit',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Displays when searching a Package that returns more than 100 results.',MESSAGE__C='Your search found more than 100. You may refine your search.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='SearchNotFound',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Displays when searching a product and returns no result.',MESSAGE__C='No result found.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='SearchPromotionResultLimit',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Displays when searching a Package that returns more than 100 results.',MESSAGE__C='Your search found more than 100. You may refine your search.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Start Sub Start date missing',APEX_CLASS_TRIGGER_NAME__C='SM_StartSubscriptionEntrylController',DESCRIPTION__C='',MESSAGE__C='Start Date Missing',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Select Temp Stop Transaction',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Please select Temp Stop Type.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Temp Stop Blank Values',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Please complete the required fields',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Start Sub Term Length missing',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Term Length missing',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Invalid Address Type',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Invalid Recipient Address Type. Valid values are; P, B, W, H, K, A, C, S, G, U.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Start Sub New Contract Period missing',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='New Contract Period missing',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='SameCase',APEX_CLASS_TRIGGER_NAME__C='ChangeInAddressExtensionNew',DESCRIPTION__C='',MESSAGE__C='Case with the same details already exist.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Change of Package Effective Date',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Start Date must not be less than today\'s date or not later than Subscription End date.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='No Asia1 Subscription',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='[Kristine Campang 11/27/20014] D-917. Deactivate user in DigitalComplaintItemsExtension',MESSAGE__C='No Asia1 Subscription is associated with this Asia1 account. Please select another.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Invalid Response',APEX_CLASS_TRIGGER_NAME__C='SM_StartSubscriptionEntryController',DESCRIPTION__C='',MESSAGE__C='Invalid response from server. Please try again later.',METHOD_NAME__C='searchCusName'));
      listEMsg.add(new Error_Messages__c(Name='NewAddressNotEqualToOldAddress',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='New Address cannot be equal to Old Address',MESSAGE__C='New Address cannot be equal to Old Address',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='ContactToUpdateRequired',APEX_CLASS_TRIGGER_NAME__C='ChangeInAddressExtensionNew',DESCRIPTION__C='Contact To Update field is required for the Change of Address Type selected.',MESSAGE__C='Contact To Update field is required for the Change of Address Type selected.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='VendorRequired',APEX_CLASS_TRIGGER_NAME__C='ChangeInAddressExtensionNew',DESCRIPTION__C='Vendor field is required for Change of Vendor.',MESSAGE__C='Vendor field is required for Change of Vendor.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='RecipIndicatorRequired',APEX_CLASS_TRIGGER_NAME__C='ChangeInAddressExtensionNew',DESCRIPTION__C='Please select a valid contact. Contact to update should have at least a recipient indicator checked.',MESSAGE__C='Please select a valid contact. Contact to update should have at least a recipient indicator checked.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='SelectSubscriptionForChangOfAddress',APEX_CLASS_TRIGGER_NAME__C='ChangeInAddressExtensionNew',DESCRIPTION__C='',MESSAGE__C='Select Subscriptions to update.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='BlankAddressinCase',APEX_CLASS_TRIGGER_NAME__C='ChangeInAddressExtensionNew',DESCRIPTION__C='For Change of address with address type of Change of Billing address and Delivery address or Change of Billing',MESSAGE__C='Address cannot be empty.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='BillIndicatorRequired',APEX_CLASS_TRIGGER_NAME__C='ChangeInAddressExtensionNew',DESCRIPTION__C='Please select a valid contact. Contact to update should have at least a billing indicator checked.',MESSAGE__C='Please select a valid contact. Contact to update should have at least a billing indicator checked.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='BillRecipIndicatorRequired',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Please select a valid contact. Contact to update should have recipient and billing indicator checked.',MESSAGE__C='Please select a valid contact. Contact to update should have recipient and billing indicator checked.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='CSO Admin Edit Complaint Magazine',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='CSO Admin cannot edit fields under Publication Information. Please contact CSO',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='CaseClosedRefund',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='You cannot create refund once case is closed.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Check New ARMS Account',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Please select "Create New ARMS Customer & Account account" when creating a new ARMS account.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Other Payment Mode is Null',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Please select Other Payment Mode.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Invalid Billing Contact Inputted',APEX_CLASS_TRIGGER_NAME__C='SM_StartSubscriptionEntryController',DESCRIPTION__C='Catch force input of invalid billing contact.',MESSAGE__C='Select billing contact related to Account.',METHOD_NAME__C='save'));
      listEMsg.add(new Error_Messages__c(Name='BundleStopSubscriptionError',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='All Subscriptions within the same Bundle must have the same Stop Date!',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Zuora Cancellation Error 1',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Error encountered when cancellation a subscription via zuora callout',MESSAGE__C='Only activated subscription can be cancelled.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='AmountToRefund',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Amount to Refund cannot be greater than Total Credit Balance Amount',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='ARMS search for ARMS customer contact',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Please search for a ARMS Customer or tick the Create New ARMS Customer and Account',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='ARMS Unlink Error',APEX_CLASS_TRIGGER_NAME__C='ARMS_UnlinkArmsAccController',DESCRIPTION__C='',MESSAGE__C='Please check if Billing Account is Invoice and ARMS Information is correct.',METHOD_NAME__C='updateBillAccount'));
      listEMsg.add(new Error_Messages__c(Name='ARMSBusProfDebtMgt',APEX_CLASS_TRIGGER_NAME__C='SM_StartSubscriptionEntryController',DESCRIPTION__C='',MESSAGE__C='ARMS Business Profile and Debt Management cannot be "NONE" if payment method is Invoice.',METHOD_NAME__C='save'));
      listEMsg.add(new Error_Messages__c(Name='At least one asia1 id',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='At least one Asia1 ID should be created when selected package is digital',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='AttachmentDeleteError',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='You cannot delete attachment',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='CaseRefundCheck',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='You already created a refund. Please close the case to complete the Refund process.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Check asia1 list versus quantity',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Please decrease the AsiaOne account based on the Quantity inputted.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='ARMS Business Profile',APEX_CLASS_TRIGGER_NAME__C='SM_StartSubscriptionEntryController',DESCRIPTION__C='IF there is an existing ARMS account. business Profile and debt Management should not be updated.',MESSAGE__C='There is an exisiting ARMS account. Debt Management should not be updated.',METHOD_NAME__C='save'));
      listEMsg.add(new Error_Messages__c(Name='ExistingCOSOrder',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='if the sub to PSTOP having a COS Order (regardless of status), throw validation error',MESSAGE__C='The subscription to PSTOP has an existing Change Of Subscription Order. For Orders in ‘Draft’ or ‘New’ Status, you shall VOID them first.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='ExistingPSTOPOrder',APEX_CLASS_TRIGGER_NAME__C='SM_ChangeOfSubscriptionEntryController',DESCRIPTION__C='if the sub to COS having a PSTOP Order (regardless of status), throw validation error',MESSAGE__C='The subscription to Change has an existing Stop Subscription Order. For Orders in ‘Draft’ or ‘New’ Status, you shall VOID them first.',METHOD_NAME__C='onChange Subscription'));
      listEMsg.add(new Error_Messages__c(Name='RefundApproval',APEX_CLASS_TRIGGER_NAME__C='RefundButtonExtension',DESCRIPTION__C='',MESSAGE__C='Request for Refund must Be Approved',METHOD_NAME__C='activateRefund'));
      listEMsg.add(new Error_Messages__c(Name='RefundError',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Error: Invalid Data. Review all error messages below to correct your data.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Return To Previous Page',APEX_CLASS_TRIGGER_NAME__C='ALL',DESCRIPTION__C='Generic, output text for redirection link',MESSAGE__C='Click here to return to previous page.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Start_PaymentModeForRecurring',APEX_CLASS_TRIGGER_NAME__C='SM_StartSubscriptionEntryController',DESCRIPTION__C='If Billing Type of Package is Recurring it should only pay via Credit Card or Invoice.',MESSAGE__C='For recurirng packages please pay via the following payment modes: -Credit Card -Invoice -External Parties -Internal Charge',METHOD_NAME__C='save'));
      listEMsg.add(new Error_Messages__c(Name='Stop Sub Invoice Error',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='The stop request date cannot be earlier than the subscription\'s last invoice target date',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='COATypeNoSubscription',APEX_CLASS_TRIGGER_NAME__C='ChangInAddressExtensionNew',DESCRIPTION__C='Subscription is required for this type of Change of Address.',MESSAGE__C='Subscription is required for this type of Change of Address.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='COS Invoice Error1',APEX_CLASS_TRIGGER_NAME__C='SM_ChangeOfSubscriptionEntryController',DESCRIPTION__C='Used to check if COS start date is earlier that Invoice date.',MESSAGE__C='Start date cannot be earlier than Invoice Target Date.',METHOD_NAME__C='checkInvoiceForBillingAccount'));
      listEMsg.add(new Error_Messages__c(Name='COS Invoice Error2',APEX_CLASS_TRIGGER_NAME__C='SM_ChangeOfSubscriptionEntryController',DESCRIPTION__C='Checks if there is an existing invoice from the Billing Account. Invoice is critical for subscription cancellation.',MESSAGE__C='Please click Sync Data from Z-Billing button on the Billing Account of the Subscription being changed.',METHOD_NAME__C='checkInvoiceForBillingAccount'));
      listEMsg.add(new Error_Messages__c(Name='ARMS search for arms account',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Please search for a ARMS Account before submitting.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='CreateCaseOnBillingAccount',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Please create case record on Billing Account.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='DigitalComplaint_NoFunctionality',APEX_CLASS_TRIGGER_NAME__C='DigitalComplaintItemsPage',DESCRIPTION__C='Displayed when user accesses digital complaint page and case sub category is either “Service Flag not Updated” or “App Crash/Slow Loading/Sys Issues.',MESSAGE__C='Updating Service Flags cannot be done in CRSM.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Full Prepaid Evergreen',APEX_CLASS_TRIGGER_NAME__C='SM_ChangeOfSubscriptionEntryController',DESCRIPTION__C='Full Prepaid cannot be evergreen.',MESSAGE__C='Invalid data. Full Prepaid Evergreen Subscription.',METHOD_NAME__C='retrieveAdminFee'));
      listEMsg.add(new Error_Messages__c(Name='Insufficient Privileges',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Insufficient Privileges',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='StopRequestDateNotNull',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Stop request date cannot be null',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Validate Complaint- Newspaper',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Package platform should be Newspaper.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Vendor Stop Subscription Error',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='No Associated Contact. Please create new.',MESSAGE__C='No Associated Contact. Please create new.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Vendor Sub Populate Start Date',APEX_CLASS_TRIGGER_NAME__C='CreateVendorOrderEntryController',DESCRIPTION__C='Start Date cannot be null in Vendor Start Subscription.',MESSAGE__C='Please enter Start Date.',METHOD_NAME__C='AddOn'));
      listEMsg.add(new Error_Messages__c(Name='Validate Temp Stop Date 2',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Tempstop date should be less than sub stop date',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Validate Temp Stop Date 3',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Tempstop date Should be greater than or equal to sub start date',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Validate Restart Date 5',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Restart date should be publication day',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Validate Restart Date 3',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Restart date should not be equal or greater than the Subscription\'s end date.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Validate Restart Date 1',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Restart date Should be greater than or equal to sub start date',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Invalid Date Inputs',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Restart Date should be greater than Temp Stop Date.',MESSAGE__C='Restart Date should be greater than Temp Stop Date.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Invalid Subscription',APEX_CLASS_TRIGGER_NAME__C='StopSubOrderEntryDirectController',DESCRIPTION__C='Error in Subscription used.',MESSAGE__C='Invalid Subscription.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='MoreThanAsia1Creation',APEX_CLASS_TRIGGER_NAME__C='SM_StartSubscriptionEntryController',DESCRIPTION__C='',MESSAGE__C='Number of Asia1 id creation cannot be more than to Quantity.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='No Vendor for Airlines',APEX_CLASS_TRIGGER_NAME__C='SM_StartSubscriptionEntryController',DESCRIPTION__C='',MESSAGE__C='Order line items should be delivered by Mailing Agent if the recipient contact is Airline.',METHOD_NAME__C='addOrderLineItem'));
      listEMsg.add(new Error_Messages__c(Name='No Vendor for Internal',APEX_CLASS_TRIGGER_NAME__C='SM_StartSubscriptionEntryController',DESCRIPTION__C='',MESSAGE__C='Order line items should be delivered by Mailing Agent if the recipient contact is Internal.',METHOD_NAME__C='addOrderLineItem'));
      listEMsg.add(new Error_Messages__c(Name='No Vendor for Overseas',APEX_CLASS_TRIGGER_NAME__C='addOrderLineItem',DESCRIPTION__C='',MESSAGE__C='Order line items should be delivered by Mailing Agent if the recipient contact is Overseas.',METHOD_NAME__C='SM_StartSubscriptionEntryController'));
      listEMsg.add(new Error_Messages__c(Name='NoPaymentMethodID',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='No Payment Method ID. Please Save Payment ID.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='OverlappingNotApproved',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Overlapping input with PENDING Temp Stop Subscription Case',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='OverlappingPeriod',APEX_CLASS_TRIGGER_NAME__C='ComplaintNewsPaperController',DESCRIPTION__C='For Complaint cases with overlapping period',MESSAGE__C='There is an overlapping complaint case for the selected subscription and complaint period',METHOD_NAME__C='save'));
      listEMsg.add(new Error_Messages__c(Name='Validate Restart Date 2',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Restart date Should be less than Subscription\'s end date',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Validate Temp Stop Date 1',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Tempstop date should be greater than current date',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Renewal Start Date Missing',APEX_CLASS_TRIGGER_NAME__C='SM_RenewalOfSubscriptionEntryController',DESCRIPTION__C='Requires subscription start date.',MESSAGE__C='Subscription Start Date is missing.',METHOD_NAME__C='save'));
      listEMsg.add(new Error_Messages__c(Name='Vendor Sub Stop Date Invalid',APEX_CLASS_TRIGGER_NAME__C='CreateVendorOrderEntryController',DESCRIPTION__C='To prevent user inputting and saving records that has stop date earlier that start date.',MESSAGE__C='Stop Date should not be earlier that Start Date.',METHOD_NAME__C='addOn'));
      listEMsg.add(new Error_Messages__c(Name='Validate Complaint- Magazine',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Package platform should be Magazine.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Temp Stop Edit Error',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Temp Stop record cannot be edited manually.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Temp Stop no issue for record',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='There are no issues to temp stop for the period chosen',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Temp Stop Pending Cases',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='There is still a Pending Case related to the Subscription selected.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='TempStopDateRestartDatePart1',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Restart Date must be at least',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='PublicationNotMain',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Invalid Selection. Please choose a Main Publication.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Asia1 Quantity Not Equal',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Validation if the number of asia1 accounts created is not the same as the quantity inputted.',MESSAGE__C='The number of Asia1 accounts should be the same as the quantity inputted.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='ARMS Customer Number Used',APEX_CLASS_TRIGGER_NAME__C='SM_StartSubscriptionEntryController',DESCRIPTION__C='This error is shown if an ARMS Customer is selected but is currently used by other Billing Account under different Account.',MESSAGE__C='ARMS Customer selected is currently used by Billing Account:',METHOD_NAME__C='save'));
      listEMsg.add(new Error_Messages__c(Name='Billing Contact Required',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Please specify a Billing Contact under the Billing Section.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='SameContactCase',APEX_CLASS_TRIGGER_NAME__C='ChangeInAddressExtensionNew',DESCRIPTION__C='A case with the same Contact To Update and Effective Date already exists.',MESSAGE__C='A case with the same Contact To Update and Effective Date already exists.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='BundleSubscription',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='You cannot change a bundle subscription.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='asia1quantity',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Number of Asia1 id creation cannot be more than against Quantity',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='FeeOverridePositiveAmount',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Please enter a positive value for the Fee Override Amount.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='TempStopDateRestartDatePart2',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='days from the Temp Stop Date',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='TempStopEditErrorMessage',APEX_CLASS_TRIGGER_NAME__C='ErrorPageController',DESCRIPTION__C='Temp Stop Case cannot be edited manually.',MESSAGE__C='Temp Stop Case cannot be edited manually.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='TempStopMinGapDaysPart1',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='New Temp Stop Request cannot be less than',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Vendor Newspaper Complaint',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Vendor cannot add/remove subscription.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Missing Earliest Start Date',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Cannot create temp stop without earliest start date',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='PleaseSelectBillingOrNewOne',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Please select an existing Billing Account or create a New one',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='InvalidAccount',APEX_CLASS_TRIGGER_NAME__C='Vendor_Assignment',DESCRIPTION__C='',MESSAGE__C='Invalid Account. Account must be a Vendor or Mailing Agent.',METHOD_NAME__C='Assign_Vendor_To_Order_line_Items'));
      listEMsg.add(new Error_Messages__c(Name='ARMS Profile Error',APEX_CLASS_TRIGGER_NAME__C='ARMS_UnlinkArmsAccController',DESCRIPTION__C='',MESSAGE__C='Only SPH System Admin, CSO Admin and CSO Team Leader can use this button.',METHOD_NAME__C='updateBillAccount'));
      listEMsg.add(new Error_Messages__c(Name='Invalid Amount',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Invalid Amount',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='COS ILI Error',APEX_CLASS_TRIGGER_NAME__C='SM_ChangeOfSubscriptionEntryController',DESCRIPTION__C='For Billing Accounts that have invoices, invoice line items are required for successful cancellation of subscription.',MESSAGE__C='Please generate Invoice Line Item to have a successful Change of Subscription.',METHOD_NAME__C='checkInvoiceForBillingAccount'));
      listEMsg.add(new Error_Messages__c(Name='COA fields null',APEX_CLASS_TRIGGER_NAME__C='ChangeInAddressExtensionNew',DESCRIPTION__C='Show error message if the fields are null',MESSAGE__C='Please select Category, Sub Category, and Change of Address Type.',METHOD_NAME__C='save'));
      listEMsg.add(new Error_Messages__c(Name='Negative Goodwill',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Error message when goodwill amount is a negative value',MESSAGE__C='Goodwill Amount cannot be a negative value.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='VendorTStopQuantity',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Please specify a Temp Stop Quantity less than or equal to',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='InvalidLdapSubscription',APEX_CLASS_TRIGGER_NAME__C='AsiaOneBulkCreationTriggerHandler',DESCRIPTION__C='',MESSAGE__C='Subscription must be Active, Publication type and Digitial',METHOD_NAME__C='verifyData'));
      listEMsg.add(new Error_Messages__c(Name='LdapIdMultipleDisplayNames',APEX_CLASS_TRIGGER_NAME__C='AsiaOneBulkCreationTriggerHandler',DESCRIPTION__C='',MESSAGE__C='Multiple entries with the same LDAP ID but different Display Names.',METHOD_NAME__C='verifyData'));
      listEMsg.add(new Error_Messages__c(Name='DuplicateAsia1DisplayName',APEX_CLASS_TRIGGER_NAME__C='AsiaOnceBulkCreationTriggerHandler',DESCRIPTION__C='',MESSAGE__C='Display Name already exist or cannot have duplicate entry',METHOD_NAME__C='verify'));
      listEMsg.add(new Error_Messages__c(Name='DuplicateAsia1Subscription',APEX_CLASS_TRIGGER_NAME__C='AsiaOnceBulkCreationTriggerHandler',DESCRIPTION__C='',MESSAGE__C='Subscription already existing under LDAP ID.',METHOD_NAME__C='verify'));
      listEMsg.add(new Error_Messages__c(Name='Account RecodType not valid',APEX_CLASS_TRIGGER_NAME__C='CaseNewOverrideController',DESCRIPTION__C='Account RecordType invalid',MESSAGE__C='Selected Account record type cannot create Start Subscription Case.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='ARMS Timed-out',APEX_CLASS_TRIGGER_NAME__C='SM_StartSubscriptionEntryController',DESCRIPTION__C='',MESSAGE__C='Timed-out. Please click Search button again.',METHOD_NAME__C='searchCusName'));
      listEMsg.add(new Error_Messages__c(Name='BlankContactInCase',APEX_CLASS_TRIGGER_NAME__C='ChangeInAddressExtensionNew',DESCRIPTION__C='For Change of address with address type of Change of Billing address and Delivery address or Change of Billing',MESSAGE__C='Contact cannot be empty.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='TempStopMinGapDaysPart2',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='days than the last Temp Stop request',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='TempStopQtyGreaterLesserPart2',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Subscriber will not be eligible for any Refund.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='TempStopQtyGreaterPart1',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Temp Stop Qty is less than',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='TempStopQtyLesserPart1',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Temp Stop Qty is more than',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='COS_PrepaidToPostpaid',APEX_CLASS_TRIGGER_NAME__C='SM_ChangeOfSubscriptionEntryController',DESCRIPTION__C='',MESSAGE__C='Cannot change Prepaid Subscriptions to Postpaid Subscriptions.',METHOD_NAME__C='checkBillingTypes()'));
      listEMsg.add(new Error_Messages__c(Name='STOP_InvoiceTargetDate',APEX_CLASS_TRIGGER_NAME__C='StopSubOrderEntryDirectController',DESCRIPTION__C='',MESSAGE__C='Stop Request Date cannot be earlier than Invoice Target Date.',METHOD_NAME__C='saveAsDraft'));
      listEMsg.add(new Error_Messages__c(Name='DisplayNameMultipleLdapIds',APEX_CLASS_TRIGGER_NAME__C='AsiaOneBulkCreationTriggerHandler',DESCRIPTION__C='',MESSAGE__C='Multiple entries with the same Display Name but different LDAP IDs.',METHOD_NAME__C='verifyData'));
      listEMsg.add(new Error_Messages__c(Name='Asia1vsQuantity',APEX_CLASS_TRIGGER_NAME__C='SM_StartSubscriptionEntryController',DESCRIPTION__C='when qty != asia1 records then error',MESSAGE__C='Number of Asia1 records should not be more than Subscription Number of Copies/Qty.',METHOD_NAME__C='addOrderLineItem()'));
      listEMsg.add(new Error_Messages__c(Name='CompDateBehindSubStartDate',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Complaint Dates should not be less than Subscription Start Date.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='DuplicateLdapId',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='LDAP ID already exist or cannot have duplicate entry.',METHOD_NAME__C='AsiaOneBulkCreationTriggerHandler'));
      listEMsg.add(new Error_Messages__c(Name='ReselectCheckBillingAccount',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Please reselect Billing Account for additional payment. Credit and Charges were recalculated.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='StartSubStartDateValue',APEX_CLASS_TRIGGER_NAME__C='SM_StartSubscriptionEntryController',DESCRIPTION__C='coded validation same with oob validation to prevent lost data during update of oli in Start Sub.',MESSAGE__C='Start Date must be greater than today.',METHOD_NAME__C='UpdateOrderLineItem'));
      listEMsg.add(new Error_Messages__c(Name='No Start Date',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Please select a Start Date.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='ZUORA_AMEND_RETRY_MSG',APEX_CLASS_TRIGGER_NAME__C='SM_SubscriptionCancellationHelper',DESCRIPTION__C='Error message for cancellation.',MESSAGE__C='Operation failed due to a lock competition, please retry later.;',METHOD_NAME__C='amendApiCall'));
      listEMsg.add(new Error_Messages__c(Name='No Billing Account',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='When saving as draft without billing account.',MESSAGE__C='Please provide billing details.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='ChequeCaseValidation',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Cheque Number is required for payment mode of type \'Cheque\'.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='InvalidTempStopDurationEshop',APEX_CLASS_TRIGGER_NAME__C='TempStopDirectController',DESCRIPTION__C='Custom Setting Value of Eshop Max Duration is @Key Id.',MESSAGE__C='Temp Stop Duration for Eshop is Invalid.',METHOD_NAME__C='setSelectedRecords'));
      listEMsg.add(new Error_Messages__c(Name='ARMS account too many record',APEX_CLASS_TRIGGER_NAME__C='More than one account is retrieved with',DESCRIPTION__C='',MESSAGE__C='SM_StartSubscriptionEntryController',METHOD_NAME__C='searchAccName'));
      listEMsg.add(new Error_Messages__c(Name='ARMS customer is not existing',APEX_CLASS_TRIGGER_NAME__C='ARMS customer is not existing.',DESCRIPTION__C='',MESSAGE__C='SM_StartSubscriptionEntryController',METHOD_NAME__C='searchCusName'));
      listEMsg.add(new Error_Messages__c(Name='ARMS account is not existing',APEX_CLASS_TRIGGER_NAME__C='SM_StartSubscriptionEntryController',DESCRIPTION__C='',MESSAGE__C='ARMS account is not existing.',METHOD_NAME__C='searchAccName'));
      listEMsg.add(new Error_Messages__c(Name='LevelATLeastTwoChars',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Level must be at least two characters',MESSAGE__C='Level must be at least two characters',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Indicators',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='Please tick Billing Indicator, Recipient Indicator or both.',MESSAGE__C='Please tick Billing Indicator, Recipient Indicator or both.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='Message',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Message:',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='HasCaseWaitingForVendorAssignment',APEX_CLASS_TRIGGER_NAME__C='ChangeInAddressExtensionNew',DESCRIPTION__C='Account still has a Case that is Waiting for Vendor Assignment. Please assign vendor to the subscriptions before performing Change of Address/Vendor.',MESSAGE__C='Account still has a Case that is Waiting for Vendor Assignment. Please assign vendor to the subscriptions before performing Change of Address/Vendor.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='ChequeAmountChecking',APEX_CLASS_TRIGGER_NAME__C='SM_StartSubscriptionEntryController',DESCRIPTION__C='Cheking amount if greater than total due to sph.',MESSAGE__C='Check amount is less than total due amount to SPH.',METHOD_NAME__C='Save'));
      listEMsg.add(new Error_Messages__c(Name='Has Existing Invoice',APEX_CLASS_TRIGGER_NAME__C='',DESCRIPTION__C='',MESSAGE__C='Account already has existing Invoice Billing Account with the same Billing Type.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='CompDateBeyondSubEndDate',APEX_CLASS_TRIGGER_NAME__C='ComplaintNewsPaperController',DESCRIPTION__C='Added for defect D-4271',MESSAGE__C='Complaint Dates should not be greater than Subscription End Date.',METHOD_NAME__C='save'));
      listEMsg.add(new Error_Messages__c(Name='ComplaintErrorForFutureDateSubs',APEX_CLASS_TRIGGER_NAME__C='complaint newspaper cont and magazine',DESCRIPTION__C='Cannot perform complaint case for future dated subs',MESSAGE__C='Cannot create complaint case for future active subscriptions.',METHOD_NAME__C='save'));
      listEMsg.add(new Error_Messages__c(Name='ARMS Create OLI first',APEX_CLASS_TRIGGER_NAME__C='SM_StartSubscriptionEntryController',DESCRIPTION__C='To prevent ARMS info not being copied to Billing Account.',MESSAGE__C='Complete order details needed. Please add to line item.',METHOD_NAME__C=''));
      listEMsg.add(new Error_Messages__c(Name='ARMS Debt Management',APEX_CLASS_TRIGGER_NAME__C='SM_StartSubscriptionEntryController',DESCRIPTION__C='If there is an existing ARMS account. business Profile and debt Management should not be updated.',MESSAGE__C='There is an existing ARMS account. Debt Management should not be updated.',METHOD_NAME__C='Save'));
      listEMsg.add(new Error_Messages__c(Name='NoExistingPaymentForPayPal',APEX_CLASS_TRIGGER_NAME__C='CreateRefundController',DESCRIPTION__C='',MESSAGE__C='No existing payment from PayPal. Kindly create payment first for Payment Id.',METHOD_NAME__C=''));

      return listEMsg;
  }
    
    
/*********************************************************************
Author          Rozelle Villanueva
Description     Test Builder for Custom Settings
Date Created:   April 22, 2016
*********************************************************************/

  public static List<ARMSInterface_Settings__c> createARMSInterface () {
      List <ARMSInterface_Settings__c> armsInterfList = new List <ARMSInterface_Settings__c>();
      ARMSInterface_Settings__c armsInterface =  new ARMSInterface_Settings__c();
      armsInterface.Name = 'Endpoint Delegator';
      armsInterface.Value__c = 'http://armsuatws.sph.com.sg/arws/CAMService';
      armsInterfList.add(armsInterface);
      return armsInterfList;
  }

  public static List <Batch_Configuration_Settings__c> createBatchConfig () {
    List <Batch_Configuration_Settings__c> batchConfigList = new List <Batch_Configuration_Settings__c> ();
    
    Batch_Configuration_Settings__c batchConfig1 =  new Batch_Configuration_Settings__c();
    batchConfig1.Name = 'SP_ActivateServiceFlagBatch';
    batchConfig1.Batch_Size__c = 10;
    batchConfigList.add(batchConfig1);
    
    Batch_Configuration_Settings__c batchConfig2 =  new Batch_Configuration_Settings__c();
    batchConfig2.Name = 'SP_MidMonthStartProrationBatch';
    batchConfig2.Batch_Size__c = 200;
    batchConfig2.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
    batchConfig2.Number_Of_Days_To_Retrieve__c = 30;
    batchConfigList.add(batchConfig2);
    
    Batch_Configuration_Settings__c batchConfig3 =  new Batch_Configuration_Settings__c();
    batchConfig3.Name = 'SP_MidMonthTempStopBatch';
    batchConfig3.Batch_Size__c = 200;
    batchConfig3.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
    batchConfig3.Number_Of_Days_To_Retrieve__c = 30;
    batchConfigList.add(batchConfig3);
    
    Batch_Configuration_Settings__c batchConfig4 =  new Batch_Configuration_Settings__c();
    batchConfig4.Name = 'SP_PDFGenerator';
    batchConfig4.Batch_Size__c = 5;
    batchConfigList.add(batchConfig4);
    
    Batch_Configuration_Settings__c batchConfig5 =  new Batch_Configuration_Settings__c();
    batchConfig5.Name = 'SP_VendorNotificationsBatch';
    batchConfig5.Batch_Size__c = 200;
    batchConfig5.Notification_Recipients__c = 'karl.wilson.l.tan@accenture.com';
    batchConfig5.Number_Of_Days_To_Retrieve__c = 30;
    batchConfigList.add(batchConfig5);
    
    return batchConfigList;
  }

  public static List <Batch_Control_Settings__c> createBatchControl() {
    List <Batch_Control_Settings__c> batchControlList = new List <Batch_Control_Settings__c>();
    
    Batch_Control_Settings__c batchControl1 = new Batch_Control_Settings__c();
    batchControl1.Name = 'Number of Parallel Jobs';
    batchControl1.Number_of_Parallel_Jobs__c = 1;
    batchControlList.add(batchControl1);
    
    Batch_Control_Settings__c batchControl2 = new Batch_Control_Settings__c();
    batchControl2.Name = 'SP028';
    batchControl2.Number_of_Parallel_Jobs__c = 1;
    batchControl2.Batch_Size__c = 100;
    batchControlList.add(batchControl2);
    
    return batchControlList;
  }

  public static List <BatchInterface_Settings__c> createBatchInterface() {
    List <BatchInterface_Settings__c> batchInterfList = new List <BatchInterface_Settings__c>();
    
    BatchInterface_Settings__c batchIntf1 = new BatchInterface_Settings__c();
    batchIntf1.Name = 'ApplicationJSON';
    batchIntf1.Value__c = 'application/json';
    batchInterfList.add(batchIntf1);
    
    BatchInterface_Settings__c batchIntf2 = new BatchInterface_Settings__c();
    batchIntf2.Name = 'Content-Type';
    batchIntf2.Value__c = 'ContentType';
    batchInterfList.add(batchIntf2);
    
    BatchInterface_Settings__c batchIntf3 = new BatchInterface_Settings__c();
    batchIntf3.Name = 'Endpoint Delegator';
    batchIntf3.Value__c = 'http://tstcrsm.sph.com.sg/sqebatch/Batch/BatchAuth2/BatchDelegator';
    batchInterfList.add(batchIntf3);
    
    BatchInterface_Settings__c batchIntf4 = new BatchInterface_Settings__c();
    batchIntf4.Name = 'PostMethod';
    batchIntf4.Value__c = 'POST';
    batchInterfList.add(batchIntf4);
    
    return batchInterfList;
    
  }

  public static List <Billing_Batch__c> createBillingBatch() {
    List <Billing_Batch__c> billingBatchList = new List <Billing_Batch__c>();
    
    Billing_Batch__c billingBatch1 = new Billing_Batch__c();
    billingBatch1.Name = 'Default';
    billingBatch1.Batch__c = '19';
    billingBatchList.add(billingBatch1);
    
    Billing_Batch__c billingBatch2 = new Billing_Batch__c();
    billingBatch2.Name = 'Full Prepaid';
    billingBatch2.Batch__c = '13,14,15';
    billingBatch2.Next_Batch_Number__c = 15;
    billingBatchList.add(billingBatch2);
    
    Billing_Batch__c billingBatch3 = new Billing_Batch__c();
    billingBatch3.Name = 'Recurring Postpaid';
    billingBatch3.Batch__c = '16';
    billingBatch3.Next_Batch_Number__c = 16;
    billingBatchList.add(billingBatch3);
    
    Billing_Batch__c billingBatch4 = new Billing_Batch__c();
    billingBatch4.Name = 'Recurring Prepaid';
    billingBatch4.Batch__c = '1,2,3,4,5,6,7,8,9,10,11,12';
    billingBatch3.Next_Batch_Number__c = 10;
    billingBatchList.add(billingBatch4);
    
    return billingBatchList;
  }

  /* commented out. object not existing in other environment
  public static List <Billing_Batch_Current_Load__c> createBatchCurrentLoad() {
    List <Billing_Batch_Current_Load__c> currentLoadList = new List <Billing_Batch_Current_Load__c>();
    
    currentLoadList.add(new Billing_Batch_Current_Load__c(Name = 'Batch1',Current_Load__c = 14));
    currentLoadList.add(new Billing_Batch_Current_Load__c(Name = 'Batch2',Current_Load__c = 13));
    currentLoadList.add(new Billing_Batch_Current_Load__c(Name = 'Batch3',Current_Load__c = 13));
    currentLoadList.add(new Billing_Batch_Current_Load__c(Name = 'Batch4',Current_Load__c = 13));
    currentLoadList.add(new Billing_Batch_Current_Load__c(Name = 'Batch5',Current_Load__c = 13));
    currentLoadList.add(new Billing_Batch_Current_Load__c(Name = 'Batch6',Current_Load__c = 13));
    currentLoadList.add(new Billing_Batch_Current_Load__c(Name = 'Batch7',Current_Load__c = 13));
    currentLoadList.add(new Billing_Batch_Current_Load__c(Name = 'Batch8',Current_Load__c = 13));
    currentLoadList.add(new Billing_Batch_Current_Load__c(Name = 'Batch9',Current_Load__c = 13));
    currentLoadList.add(new Billing_Batch_Current_Load__c(Name = 'Batch10',Current_Load__c = 14));
    currentLoadList.add(new Billing_Batch_Current_Load__c(Name = 'Batch11',Current_Load__c = 14));
    currentLoadList.add(new Billing_Batch_Current_Load__c(Name = 'Batch12',Current_Load__c = 14));
    currentLoadList.add(new Billing_Batch_Current_Load__c(Name = 'Batch13',Current_Load__c = 127));
    currentLoadList.add(new Billing_Batch_Current_Load__c(Name = 'Batch14',Current_Load__c = 128));
    currentLoadList.add(new Billing_Batch_Current_Load__c(Name = 'Batch15',Current_Load__c = 128));
    currentLoadList.add(new Billing_Batch_Current_Load__c(Name = 'Batch16',Current_Load__c = 61));
    currentLoadList.add(new Billing_Batch_Current_Load__c(Name = 'Batch19',Current_Load__c = 2));

    return currentLoadList;
  }
  */

  public static List <BT_CS_Interface_Parameters__c> createInterfParam() {
    List <BT_CS_Interface_Parameters__c> interfParamList = new List <BT_CS_Interface_Parameters__c>();
    
    BT_CS_Interface_Parameters__c interfParam1 = new BT_CS_Interface_Parameters__c();
    interfParam1.Name = 'AGD042DX Currency Code';
    interfParam1.Value__c = 'SGD';
    interfParam1.Description__c ='AGD042DX Currency Code';
    interfParamList.add(interfParam1);
    
    BT_CS_Interface_Parameters__c interfParam2 = new BT_CS_Interface_Parameters__c();
    interfParam2.Name = 'AGD042DX Description';
    interfParam2.Value__c = 'AGD042DX Description';
    interfParam2.Description__c = 'AGD042DX Description';
    interfParamList.add(interfParam2);
    
    BT_CS_Interface_Parameters__c interfParam3 = new BT_CS_Interface_Parameters__c();
    interfParam3.Name = 'AGD042DX Freight Amount';
    interfParam3.Value__c = '0.0';
    interfParam3.Description__c ='AGD042DX Freight Amount';
    interfParamList.add(interfParam3);
    
    BT_CS_Interface_Parameters__c interfParam4 = new BT_CS_Interface_Parameters__c();
    interfParam4.Name = 'AGD042DX Vendor ID';
    interfParam4.Value__c = '198402868E';
    interfParam4.Description__c ='AGD042DX Vendor ID';
    interfParamList.add(interfParam4);
    
    BT_CS_Interface_Parameters__c interfParam5 = new BT_CS_Interface_Parameters__c();
    interfParam5.Name = 'Case TempStop Type CREATE';
    interfParam5.Value__c = 'New|Create';
    interfParam5.Description__c ='Stores the Case - TempStop Type values to be used by the VSS/HDS interfaces';
    interfParamList.add(interfParam5);
    
    BT_CS_Interface_Parameters__c interfParam6 = new BT_CS_Interface_Parameters__c();
    interfParam6.Name = 'Stores the Case - TempStop Type values to be used by the VSS/HDS interfaces';
    interfParam6.Value__c = 'T04:00:00.000Z';
    interfParam6.Description__c ='Stores value for timestamp to be used for current day calculations';
    interfParamList.add(interfParam6);
    
    BT_CS_Interface_Parameters__c interfParam7 = new BT_CS_Interface_Parameters__c();
    interfParam7.Name = 'Default Timestamp';
    interfParam7.Value__c = 'T16:00:00.000Z';
    interfParam7.Description__c ='Default timestamp value of T11:00:00.000Z';
    interfParamList.add(interfParam7);
    
    BT_CS_Interface_Parameters__c interfParam8 = new BT_CS_Interface_Parameters__c();
    interfParam8.Name = 'Delim';
    interfParam8.Value__c = '|';
    interfParam8.Description__c ='Default Delimiter';
    interfParamList.add(interfParam8);
    
    BT_CS_Interface_Parameters__c interfParam9 = new BT_CS_Interface_Parameters__c();
    interfParam9.Name = 'HDS036DX Case Record Types';
    interfParam9.Value__c = 'Temp_Stop_Subscription|Case_Temp Stop|Temp Stop';
    interfParam9.Description__c ='Case Record Types for HDS036DX';
    interfParamList.add(interfParam9);
    
    BT_CS_Interface_Parameters__c interfParam10 = new BT_CS_Interface_Parameters__c();
    interfParam10.Name = 'HDS036DX Default Stop Date';
    interfParam10.Value__c = '2099-12-31';
    interfParam10.Description__c ='HDS036DX Default Stop Date';
    interfParamList.add(interfParam10);
    
    BT_CS_Interface_Parameters__c interfParam11 = new BT_CS_Interface_Parameters__c();
    interfParam11.Name = 'HDS037DX Case Record Types';
    interfParam11.Value__c = 'Change_of_Address|Change_of_Vendor|Start_Subscription|Stop_Subscription|Change_of_Subscription|Renewal_of_Subscription';
    interfParam11.Description__c ='Case Record Types of HDS037DX';
    interfParamList.add(interfParam11);
    
    BT_CS_Interface_Parameters__c interfParam12 = new BT_CS_Interface_Parameters__c();
    interfParam12.Name = 'HDS037DX Case Status';
    interfParam12.Value__c = 'Closed';
    interfParam12.Description__c ='HDS037DX Case Status';
    interfParamList.add(interfParam12);
    
    BT_CS_Interface_Parameters__c interfParam13 = new BT_CS_Interface_Parameters__c();
    interfParam13.Name = 'HDS037DX Default Stop Date';
    interfParam13.Value__c = '2099-12-31';
    interfParam13.Description__c ='HDS036DX Default Subscription Stop Date';
    interfParamList.add(interfParam13);
    
    BT_CS_Interface_Parameters__c interfParam14 = new BT_CS_Interface_Parameters__c();
    interfParam14.Name = 'HDS038DX Case Record Types';
    interfParam14.Value__c = 'Start_Subscription|Stop_Subscription';
    interfParam14.Description__c ='Case Record Types of HDS038DX';
    interfParamList.add(interfParam14);
    
    BT_CS_Interface_Parameters__c interfParam15 = new BT_CS_Interface_Parameters__c();
    interfParam15.Name = 'HDS038DX Case Status';
    interfParam15.Value__c = 'Closed';
    interfParam15.Description__c ='HDS038DX Case Status';
    interfParamList.add(interfParam15);
    
    BT_CS_Interface_Parameters__c interfParam16 = new BT_CS_Interface_Parameters__c();
    interfParam16.Name = 'VSS090DX Case Record Types';
    interfParam16.Value__c = 'Case_Start Sub|Case_Stop|Case_Temp Stop|Start_Subscription|Stop_Subscription|Temp_Stop_Subscription';
    interfParam16.Description__c ='Case Record Types for Interface VSS090DX';
    interfParamList.add(interfParam16);
    
    BT_CS_Interface_Parameters__c interfParam17 = new BT_CS_Interface_Parameters__c();
    interfParam17.Name = 'VSS090DX Case Status';
    interfParam17.Value__c = 'Closed|Void';
    interfParam17.Description__c ='Case Status Set for VSS090DX';
    interfParamList.add(interfParam17);
    
    BT_CS_Interface_Parameters__c interfParam18 = new BT_CS_Interface_Parameters__c();
    interfParam18.Name = 'VSS090DX Publication Codes';
    interfParam18.Value__c = 'BH|BM|BT|NP|TNPS|SM|ST|SUT|TM|TMS|WB|ZB|MY';
    interfParam18.Description__c ='VSS090DX Publication Codes';
    interfParamList.add(interfParam18);
    
    return interfParamList;
  }

  public static BT_CS_Timestamp__c createTimeStamp() {
    BT_CS_Timestamp__c timeStamp = new BT_CS_Timestamp__c();
    timeStamp.Name = 'Default Timestamp';
    timeStamp.Daily_Timestamp__c = 'T16:00:00.000Z';
    return timeStamp;
  }

  /* temporarily commented out
  public static List <BuildingCodeToHouseTypeMapping__c> createBuildingCode() {
    List <BuildingCodeToHouseTypeMapping__c> buildingCodeList = new list <BuildingCodeToHouseTypeMapping__c>();
    
    BuildingCodeToHouseTypeMapping__c buildingCode1 = new BuildingCodeToHouseTypeMapping__c();
    buildingCode1.Name = 'C01';
    buildingCode1.Building_Type_Code__c = 'C01';
    buildingCode1.Building_Type_Description__c = 'HDB IND';
    buildingCode1.House_Type__c = 'H';
    buildingCodeList.add(buildingCode1);
    
    BuildingCodeToHouseTypeMapping__c buildingCode2 = new BuildingCodeToHouseTypeMapping__c();
    buildingCode2.Name = 'C02';
    buildingCode2.Building_Type_Code__c = 'C02';
    buildingCode2.Building_Type_Description__c = 'HDB HAWKER /FOOD CENTRE';
    buildingCode2.House_Type__c = 'C';
    buildingCodeList.add(buildingCode2);
    
    BuildingCodeToHouseTypeMapping__c buildingCode3 = new BuildingCodeToHouseTypeMapping__c();
    buildingCode3.Name = 'C03';
    buildingCode3.Building_Type_Code__c = 'C03';
    buildingCode3.Building_Type_Description__c = 'HDB (WET / DRY) MARKET';
    buildingCode3.House_Type__c = 'C';
    buildingCodeList.add(buildingCode3);
    
    BuildingCodeToHouseTypeMapping__c buildingCode4 = new BuildingCodeToHouseTypeMapping__c();
    buildingCode4.Name = 'C04';
    buildingCode4.Building_Type_Code__c = 'C04';
    buildingCode4.Building_Type_Description__c = 'HDB SHOPHOUSE';
    buildingCode4.House_Type__c = 'C';
    buildingCodeList.add(buildingCode4);
    
    BuildingCodeToHouseTypeMapping__c buildingCode5 = new BuildingCodeToHouseTypeMapping__c();
    buildingCode5.Name = 'C05';
    buildingCode5.Building_Type_Code__c = 'C05';
    buildingCode5.Building_Type_Description__c = 'OFFICE BLDG';
    buildingCode5.House_Type__c = 'C';
    buildingCodeList.add(buildingCode5);
    
    BuildingCodeToHouseTypeMapping__c buildingCode6 = new BuildingCodeToHouseTypeMapping__c();
    buildingCode6.Name = 'C06';
    buildingCode6.Building_Type_Code__c = 'C06';
    buildingCode6.Building_Type_Description__c = 'OFFICE BLDG W COMMERCIAL';
    buildingCode6.House_Type__c = 'C';
    buildingCodeList.add(buildingCode6);
    
    BuildingCodeToHouseTypeMapping__c buildingCode7 = new BuildingCodeToHouseTypeMapping__c();
    buildingCode7.Name = 'C07';
    buildingCode7.Building_Type_Code__c = 'C07';
    buildingCode7.Building_Type_Description__c = 'SHOPPING MALL';
    buildingCode7.House_Type__c = 'C';
    buildingCodeList.add(buildingCode7);
    
    BuildingCodeToHouseTypeMapping__c buildingCode8 = new BuildingCodeToHouseTypeMapping__c();
    buildingCode8.Name = 'C08';
    buildingCode8.Building_Type_Code__c = 'C08';
    buildingCode8.Building_Type_Description__c = 'FACTORY/ JTC FLATTED ETC.';
    buildingCode8.House_Type__c = 'C';
    buildingCodeList.add(buildingCode8);
    
    BuildingCodeToHouseTypeMapping__c buildingCode9 = new BuildingCodeToHouseTypeMapping__c();
    buildingCode9.Name = 'C09';
    buildingCode9.Building_Type_Code__c = 'C09';
    buildingCode9.Building_Type_Description__c = 'SHOPHOUSE (NON-HDB)';
    buildingCode9.House_Type__c = 'C';
    buildingCodeList.add(buildingCode9);
    
    BuildingCodeToHouseTypeMapping__c buildingCode10 = new BuildingCodeToHouseTypeMapping__c();
    buildingCode10.Name = 'C10';
    buildingCode10.Building_Type_Code__c = 'C10';
    buildingCode10.Building_Type_Description__c = 'HOTEL / RESORTS';
    buildingCode10.House_Type__c = 'C';
    buildingCodeList.add(buildingCode10);
    
    BuildingCodeToHouseTypeMapping__c buildingCode11 = new BuildingCodeToHouseTypeMapping__c();
    buildingCode11.Name = 'C11';
    buildingCode11.Building_Type_Code__c = 'C11';
    buildingCode11.Building_Type_Description__c = 'CHALETS / YOUTH HOSTEL';
    buildingCode11.House_Type__c = 'C';
    buildingCodeList.add(buildingCode11);
    
    BuildingCodeToHouseTypeMapping__c buildingCode12 = new BuildingCodeToHouseTypeMapping__c();
    buildingCode12.Name = 'C12';
    buildingCode12.Building_Type_Code__c = 'C12';
    buildingCode12.Building_Type_Description__c = 'PTE RESTAURANT / FOOD COURT';
    buildingCode12.House_Type__c = 'C';
    buildingCodeList.add(buildingCode12);
    
    BuildingCodeToHouseTypeMapping__c buildingCodeE1 = new BuildingCodeToHouseTypeMapping__c();
    buildingCodeE1.Name = 'E01';
    buildingCodeE1.Building_Type_Code__c = 'E01';
    buildingCodeE1.Building_Type_Description__c = 'CHILDCARE (STANDALONE)';
    buildingCodeE1.House_Type__c = 'C';
    buildingCodeList.add(buildingCodeE1);
    
    BuildingCodeToHouseTypeMapping__c buildingCodeE2 = new BuildingCodeToHouseTypeMapping__c();
    buildingCodeE2.Name = 'E02';
    buildingCodeE2.Building_Type_Code__c = 'E02';
    buildingCodeE2.Building_Type_Description__c = 'PRIMARY SCHOOL';
    buildingCodeE2.House_Type__c = 'C';
    buildingCodeList.add(buildingCodeE2);
    
    BuildingCodeToHouseTypeMapping__c buildingCodeE3 = new BuildingCodeToHouseTypeMapping__c();
    buildingCodeE3.Name = 'E03';
    buildingCodeE3.Building_Type_Code__c = 'E03';
    buildingCodeE3.Building_Type_Description__c = 'SECONDARY SCHOOL';
    buildingCodeE3.House_Type__c = 'C';
    buildingCodeList.add(buildingCodeE3);
    
    BuildingCodeToHouseTypeMapping__c buildingCodeE4 = new BuildingCodeToHouseTypeMapping__c();
    buildingCodeE4.Name = 'E04';
    buildingCodeE4.Building_Type_Code__c = 'E04';
    buildingCodeE4.Building_Type_Description__c = 'ITE';
    buildingCodeE4.House_Type__c = 'C';
    buildingCodeList.add(buildingCodeE4);
    
    BuildingCodeToHouseTypeMapping__c buildingCodeE5 = new BuildingCodeToHouseTypeMapping__c();
    buildingCodeE5.Name = 'E05';
    buildingCodeE5.Building_Type_Code__c = 'E05';
    buildingCodeE5.Building_Type_Description__c = 'POLYTECHNIC';
    buildingCodeE5.House_Type__c = 'C';
    buildingCodeList.add(buildingCodeE5);
    
    BuildingCodeToHouseTypeMapping__c buildingCodeE6 = new BuildingCodeToHouseTypeMapping__c();
    buildingCodeE6.Name = 'E06';
    buildingCodeE6.Building_Type_Code__c = 'E06';
    buildingCodeE6.Building_Type_Description__c = 'JUNIOR COLLEGE / PRE-U';
    buildingCodeE6.House_Type__c = 'C';
    buildingCodeList.add(buildingCodeE6);
    
    BuildingCodeToHouseTypeMapping__c buildingCodeE7 = new BuildingCodeToHouseTypeMapping__c();
    buildingCodeE7.Name = 'E07';
    buildingCodeE7.Building_Type_Code__c = 'E07';
    buildingCodeE7.Building_Type_Description__c = 'UNIVERSITY';
    buildingCodeE7.House_Type__c = 'C';
    buildingCodeList.add(buildingCodeE7);
    
    BuildingCodeToHouseTypeMapping__c buildingCodeH1 = new BuildingCodeToHouseTypeMapping__c();
    buildingCodeH1.Name = 'H01';
    buildingCodeH1.Building_Type_Code__c = 'H01';
    buildingCodeH1.Building_Type_Description__c = 'POLYCLINIC';
    buildingCodeH1.House_Type__c = 'C';
    buildingCodeList.add(buildingCodeH1);
    
    BuildingCodeToHouseTypeMapping__c buildingCodeH2 = new BuildingCodeToHouseTypeMapping__c();
    buildingCodeH2.Name = 'H02';
    buildingCodeH2.Building_Type_Code__c = 'H02';
    buildingCodeH2.Building_Type_Description__c = 'HOSPITAL';
    buildingCodeH2.House_Type__c = 'C';
    buildingCodeList.add(buildingCodeH2);
    
    BuildingCodeToHouseTypeMapping__c buildingCodeH3 = new BuildingCodeToHouseTypeMapping__c();
    buildingCodeH3.Name = 'H03';
    buildingCodeH3.Building_Type_Code__c = 'H03';
    buildingCodeH3.Building_Type_Description__c = 'NURSING HOME / HOSPICE';
    buildingCodeH3.House_Type__c = 'C';
    buildingCodeList.add(buildingCodeH3);
    
    BuildingCodeToHouseTypeMapping__c buildingCodeL1 = new BuildingCodeToHouseTypeMapping__c();
    buildingCodeL1.Name = 'L01';
    buildingCodeL1.Building_Type_Code__c = 'L01';
    buildingCodeL1.Building_Type_Description__c = 'PUBLIC LIBRARY';
    buildingCodeL1.House_Type__c = 'C';
    buildingCodeList.add(buildingCodeL1);
    
    BuildingCodeToHouseTypeMapping__c buildingCodeL2 = new BuildingCodeToHouseTypeMapping__c();
    buildingCodeL2.Name = 'L02';
    buildingCodeL2.Building_Type_Code__c = 'L02';
    buildingCodeL2.Building_Type_Description__c = 'PLACES OF INTEREST (E.G ZOO)';
    buildingCodeL2.House_Type__c = 'C';
    buildingCodeList.add(buildingCodeL2);
    
    BuildingCodeToHouseTypeMapping__c buildingCodeL3 = new BuildingCodeToHouseTypeMapping__c();
    buildingCodeL3.Name = 'L03';
    buildingCodeL3.Building_Type_Code__c = 'L03';
    buildingCodeL3.Building_Type_Description__c = 'FARMS';
    buildingCodeL3.House_Type__c = 'C';
    buildingCodeList.add(buildingCodeL3);
    
    return buildingCodeList;
  }
  */

  public static List <Bulk_Order_Configuration__c> createBulkOrder() {
    List <Bulk_Order_Configuration__c> bulkOrderList = new List <Bulk_Order_Configuration__c>();
    
    Bulk_Order_Configuration__c bulkOrder1 = new Bulk_Order_Configuration__c();
    bulkOrder1.Name = 'AccountDateOfBirth';
    bulkOrder1.Field_Name__c = 'Date_of_Birth__c';
    bulkOrder1.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder1);
    
    Bulk_Order_Configuration__c bulkOrder2 = new Bulk_Order_Configuration__c();
    bulkOrder2.Name = 'AccountEmail';
    bulkOrder2.Field_Name__c = 'Email__c';
    bulkOrder2.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder2);
    
    Bulk_Order_Configuration__c bulkOrder3 = new Bulk_Order_Configuration__c();
    bulkOrder3.Name = 'AccountGender';
    bulkOrder3.Field_Name__c = 'Gender__c';
    bulkOrder3.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder3);
    
    Bulk_Order_Configuration__c bulkOrder4 = new Bulk_Order_Configuration__c();
    bulkOrder4.Name = 'AccountName';
    bulkOrder4.Field_Name__c = 'Name';
    bulkOrder4.Identifier__c = 'Account';
    bulkOrder4.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder4);
    
    Bulk_Order_Configuration__c bulkOrder5 = new Bulk_Order_Configuration__c();
    bulkOrder5.Name = 'AccountNRIC';
    bulkOrder5.Field_Name__c = 'NRIC__c';
    bulkOrder5.Identifier__c = 'Account';
    bulkOrder5.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder5);
    
    Bulk_Order_Configuration__c bulkOrder6 = new Bulk_Order_Configuration__c();
    bulkOrder6.Name = 'AccountNumber';
    bulkOrder6.Field_Name__c = 'AccountNumber';
    bulkOrder6.Identifier__c = 'Account';
    bulkOrder6.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder6);
    
    Bulk_Order_Configuration__c bulkOrder7 = new Bulk_Order_Configuration__c();
    bulkOrder7.Name = 'AccountRecordType';
    bulkOrder7.Field_Name__c = 'RecordTypeId';
    bulkOrder7.Identifier__c = 'Account';
    bulkOrder7.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder7);
    
    Bulk_Order_Configuration__c bulkOrder8 = new Bulk_Order_Configuration__c();
    bulkOrder8.Name = 'AcknowledgementLetter';
    bulkOrder8.Field_Name__c = 'Acknowledgement_Letter__c';
    bulkOrder8.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder8);
    
    Bulk_Order_Configuration__c bulkOrder9 = new Bulk_Order_Configuration__c();
    bulkOrder9.Name = 'AddonPackageCode';
    bulkOrder9.Field_Name__c = 'Addon_Package__c';
    bulkOrder9.Object_Name__c = 'OrderLineItem';
    bulkOrderList.add(bulkOrder9);
    
    Bulk_Order_Configuration__c bulkOrder10 = new Bulk_Order_Configuration__c();
    bulkOrder10.Name = 'AirlineIndicator';
    bulkOrder10.Field_Name__c = 'Airline_Indicator__c';
    bulkOrder10.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder10);
    
    Bulk_Order_Configuration__c bulkOrder11 = new Bulk_Order_Configuration__c();
    bulkOrder11.Name = 'ArmsAccountNumber';
    bulkOrder11.Field_Name__c = 'ARMS_Account_Number__c';
    bulkOrder11.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder11);
    
    Bulk_Order_Configuration__c bulkOrder12 = new Bulk_Order_Configuration__c();
    bulkOrder12.Name = 'ArmsBusinessProfile';
    bulkOrder12.Field_Name__c = 'Business_Profile__c';
    bulkOrder12.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder12);
    
    Bulk_Order_Configuration__c bulkOrder13 = new Bulk_Order_Configuration__c();
    bulkOrder13.Name = 'ArmsCustomerNumber';
    bulkOrder13.Field_Name__c = 'Customer_No__c';
    bulkOrder13.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder13);
    
    Bulk_Order_Configuration__c bulkOrder14 = new Bulk_Order_Configuration__c();
    bulkOrder14.Name = 'ArmsDebtManagementTreatment';
    bulkOrder14.Field_Name__c = 'Debt_Management_Treatment__c';
    bulkOrder14.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder14);
    
    Bulk_Order_Configuration__c bulkOrder15 = new Bulk_Order_Configuration__c();
    bulkOrder15.Name = 'AttentionSeekingSubs';
    bulkOrder15.Field_Name__c = 'Attention_Seeking_Subs__c';
    bulkOrder15.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder15);
    
    Bulk_Order_Configuration__c bulkOrder16 = new Bulk_Order_Configuration__c();
    bulkOrder16.Name = 'AttentionToCareOf';
    bulkOrder16.Field_Name__c = 'Attention_To_Care_Of__c';
    bulkOrder16.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder16);
    
    Bulk_Order_Configuration__c bulkOrder17 = new Bulk_Order_Configuration__c();
    bulkOrder17.Name = 'AttentionToCareOfIndicator';
    bulkOrder17.Field_Name__c = 'Attention_To_Care_Of_Indicator__c';
    bulkOrder17.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder17);
    
    Bulk_Order_Configuration__c bulkOrder18 = new Bulk_Order_Configuration__c();
    bulkOrder18.Name = 'AttentionToCareOfSalutation';
    bulkOrder18.Field_Name__c = 'Attention_To_Care_Of_Salutation__c';
    bulkOrder18.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder18);
    
    Bulk_Order_Configuration__c bulkOrder19 = new Bulk_Order_Configuration__c();
    bulkOrder19.Name = 'AutoRenew';
    bulkOrder19.Field_Name__c = 'Auto_Renew__c';
    bulkOrder19.Object_Name__c = 'OrderLineItem';
    bulkOrderList.add(bulkOrder19);
    
    Bulk_Order_Configuration__c bulkOrder20 = new Bulk_Order_Configuration__c();
    bulkOrder20.Name = 'BCAccountName2';
    bulkOrder20.Field_Name__c = 'Billing_Account_Name_2__c';
    bulkOrder20.Object_Name__c = 'BillingContact';
    bulkOrderList.add(bulkOrder20);
    
    Bulk_Order_Configuration__c bulkOrder21 = new Bulk_Order_Configuration__c();
    bulkOrder21.Name = 'BCAdditionalInfo';
    bulkOrder21.Field_Name__c = 'Additional_Info__c';
    bulkOrder21.Object_Name__c = 'BillingAddress';
    bulkOrderList.add(bulkOrder21);
    
    Bulk_Order_Configuration__c bulkOrder22 = new Bulk_Order_Configuration__c();
    bulkOrder22.Name = 'BCAddress1';
    bulkOrder22.Field_Name__c = 'Address_1__c';
    bulkOrder22.Identifier__c = 'BillingAddress';
    bulkOrder22.Object_Name__c = 'BillingAddress';
    bulkOrderList.add(bulkOrder22);
    
    Bulk_Order_Configuration__c bulkOrder23 = new Bulk_Order_Configuration__c();
    bulkOrder23.Name = 'BCAddress2';
    bulkOrder23.Field_Name__c = 'Address_2__c';
    bulkOrder23.Identifier__c = 'BillingAddress';
    bulkOrder23.Object_Name__c = 'BillingAddress';
    bulkOrderList.add(bulkOrder23);
    
    Bulk_Order_Configuration__c bulkOrder24 = new Bulk_Order_Configuration__c();
    bulkOrder24.Name = 'BCAddress3';
    bulkOrder24.Field_Name__c = 'Address_3__c';
    bulkOrder24.Identifier__c = 'BillingAddress';
    bulkOrder24.Object_Name__c = 'BillingAddress';
    bulkOrderList.add(bulkOrder24);
    
    Bulk_Order_Configuration__c bulkOrder25 = new Bulk_Order_Configuration__c();
    bulkOrder25.Name = 'BCAddress4';
    bulkOrder25.Field_Name__c = 'Address_4__c';
    bulkOrder25.Identifier__c = 'BillingAddress';
    bulkOrder25.Object_Name__c = 'BillingAddress';
    bulkOrderList.add(bulkOrder25);
    
    
    
    //Start UD-3660 For Test Class
    Bulk_Order_Configuration__c bulkOrder26 = new Bulk_Order_Configuration__c();
    bulkOrder26.Name = 'BCAddressRecordType';
    bulkOrder26.Field_Name__c = 'RecordTypeId';
    bulkOrder26.Identifier__c = 'BillingAddress';
    bulkOrder26.Object_Name__c = 'BillingAddress';
    bulkOrderList.add(bulkOrder26);
    
    Bulk_Order_Configuration__c bulkOrder27 = new Bulk_Order_Configuration__c();
    bulkOrder27.Name = 'BCAttnToName';
    bulkOrder27.Field_Name__c = 'Company_Name__c';
    bulkOrder27.Object_Name__c = 'BillingContact';
    bulkOrderList.add(bulkOrder27);
    
    Bulk_Order_Configuration__c bulkOrder28 = new Bulk_Order_Configuration__c();
    bulkOrder28.Name = 'BCBusinessAddressIndicator';
    bulkOrder28.Field_Name__c = 'Business_Address_Indicator__c';
    bulkOrder28.Object_Name__c = 'BillingContact';
    bulkOrderList.add(bulkOrder28);
    
    Bulk_Order_Configuration__c bulkOrder29 = new Bulk_Order_Configuration__c();
    bulkOrder29.Name = 'BCCityCode';
    bulkOrder29.Field_Name__c = 'City__c';
    bulkOrder29.Identifier__c = 'BillingAddress';
    bulkOrder29.Object_Name__c = 'BillingAddress';
    bulkOrderList.add(bulkOrder29);
    
    Bulk_Order_Configuration__c bulkOrder30 = new Bulk_Order_Configuration__c();
    bulkOrder30.Name = 'BCCompanyCode';
    bulkOrder30.Field_Name__c = 'Company_Code__c';
    bulkOrder30.Identifier__c = 'BillingAddress';
    bulkOrder30.Object_Name__c = 'BillingAddress';
    bulkOrderList.add(bulkOrder30);
    
    Bulk_Order_Configuration__c bulkOrder31 = new Bulk_Order_Configuration__c();
    bulkOrder31.Name = 'BCCountryCode';
    bulkOrder31.Field_Name__c = 'Country__c';
    bulkOrder31.Identifier__c = 'BillingAddress';   
    bulkOrder31.Object_Name__c = 'BillingAddress';
    bulkOrderList.add(bulkOrder31);
    
    Bulk_Order_Configuration__c bulkOrder32 = new Bulk_Order_Configuration__c();
    bulkOrder32.Name = 'BCDepartmentCode';
    bulkOrder32.Field_Name__c = 'Department__c';
    bulkOrder32.Identifier__c = 'BillingAddress';   
    bulkOrder32.Object_Name__c = 'BillingAddress';
    bulkOrderList.add(bulkOrder32);
    
    Bulk_Order_Configuration__c bulkOrder33 = new Bulk_Order_Configuration__c();
    bulkOrder33.Name = 'BCDivisionCode';
    bulkOrder33.Field_Name__c = 'Division_Code__c';
    bulkOrder33.Identifier__c = 'BillingAddress';
    bulkOrder33.Object_Name__c = 'BillingAddress';
    bulkOrderList.add(bulkOrder33);
    
    Bulk_Order_Configuration__c bulkOrder34 = new Bulk_Order_Configuration__c();
    bulkOrder34.Name = 'BCEmail';
    bulkOrder34.Field_Name__c = 'Email__c';
    bulkOrder34.Identifier__c = '';
    bulkOrder34.Object_Name__c = 'BillingContact';
    bulkOrderList.add(bulkOrder34);
    
    Bulk_Order_Configuration__c bulkOrder35 = new Bulk_Order_Configuration__c();
    bulkOrder35.Name = 'BCEmailSecondary';
    bulkOrder35.Field_Name__c = 'Email_Secondary__c';
    bulkOrder35.Identifier__c = ''; 
    bulkOrder35.Object_Name__c = 'BillingContact';
    bulkOrderList.add(bulkOrder35);
    
    Bulk_Order_Configuration__c bulkOrder36 = new Bulk_Order_Configuration__c();
    bulkOrder36.Name = 'BCFax';
    bulkOrder36.Field_Name__c = 'Fax__c';
    bulkOrder36.Identifier__c = ''; 
    bulkOrder36.Object_Name__c = 'BillingContact';
    bulkOrderList.add(bulkOrder36);
    
    Bulk_Order_Configuration__c bulkOrder37 = new Bulk_Order_Configuration__c();
    bulkOrder37.Name = 'BCFirstName';
    bulkOrder37.Field_Name__c = 'FirstName';
    bulkOrder37.Identifier__c = 'BillingContact';
    bulkOrder37.Object_Name__c = 'BillingContact';
    bulkOrderList.add(bulkOrder37);
    
    Bulk_Order_Configuration__c bulkOrder38 = new Bulk_Order_Configuration__c();
    bulkOrder38.Name = 'BCHomeNumber';
    bulkOrder38.Field_Name__c = 'Email__c';
    bulkOrder38.Identifier__c = '';
    bulkOrder38.Object_Name__c = 'BillingContact';
    bulkOrderList.add(bulkOrder38);
    
    Bulk_Order_Configuration__c bulkOrder39 = new Bulk_Order_Configuration__c();
    bulkOrder39.Name = 'BCLastName';
    bulkOrder39.Field_Name__c = 'LastName';
    bulkOrder39.Identifier__c = 'BillingContact';   
    bulkOrder39.Object_Name__c = 'BillingContact';
    bulkOrderList.add(bulkOrder39);
    
    Bulk_Order_Configuration__c bulkOrder40 = new Bulk_Order_Configuration__c();
    bulkOrder40.Name = 'BCLevelNumber';
    bulkOrder40.Field_Name__c = 'Level_Number__c';
    bulkOrder40.Identifier__c = 'BillingAddress';   
    bulkOrder40.Object_Name__c = 'BillingAddress';
    bulkOrderList.add(bulkOrder40);
    
    Bulk_Order_Configuration__c bulkOrder41 = new Bulk_Order_Configuration__c();
    bulkOrder41.Name = 'BCLocationCode';
    bulkOrder41.Field_Name__c = 'Location_Code__c';
    bulkOrder41.Identifier__c = 'BillingAddress';
    bulkOrder41.Object_Name__c = 'BillingAddress';
    bulkOrderList.add(bulkOrder41);
    
    Bulk_Order_Configuration__c bulkOrder42 = new Bulk_Order_Configuration__c();
    bulkOrder42.Name = 'BCMobileNumber';
    bulkOrder42.Field_Name__c = 'Mobile_Number__c';
    bulkOrder42.Identifier__c = '';
    bulkOrder42.Object_Name__c = 'BillingContact';
    bulkOrderList.add(bulkOrder42);
    
    Bulk_Order_Configuration__c bulkOrder43 = new Bulk_Order_Configuration__c();
    bulkOrder43.Name = 'BCMobileNumber2';
    bulkOrder43.Field_Name__c = 'Mobile_Number_2__c';
    bulkOrder43.Identifier__c = ''; 
    bulkOrder43.Object_Name__c = 'BillingContact';
    bulkOrderList.add(bulkOrder43);
    
    Bulk_Order_Configuration__c bulkOrder44 = new Bulk_Order_Configuration__c();
    bulkOrder44.Name = 'BCNRIC';
    bulkOrder44.Field_Name__c = 'NRIC__c';
    bulkOrder44.Identifier__c = ''; 
    bulkOrder44.Object_Name__c = 'BillingContact';
    bulkOrderList.add(bulkOrder44);
    
    Bulk_Order_Configuration__c bulkOrder45 = new Bulk_Order_Configuration__c();
    bulkOrder45.Name = 'BCOfficeExtension';
    bulkOrder45.Field_Name__c = 'Office_Extension__c';
    bulkOrder45.Identifier__c = '';
    bulkOrder45.Object_Name__c = 'BillingContact';
    bulkOrderList.add(bulkOrder45);
    
    Bulk_Order_Configuration__c bulkOrder46 = new Bulk_Order_Configuration__c();
    bulkOrder46.Name = 'BCOfficeNumber';
    bulkOrder46.Field_Name__c = 'Office_Number__c';
    bulkOrder46.Identifier__c = '';
    bulkOrder46.Object_Name__c = 'BillingContact';
    bulkOrderList.add(bulkOrder46);
    
    Bulk_Order_Configuration__c bulkOrder47 = new Bulk_Order_Configuration__c();
    bulkOrder47.Name = 'BCPackingCode';
    bulkOrder47.Field_Name__c = 'Packing_Code__c';
    bulkOrder47.Identifier__c = 'BillingAddress';   
    bulkOrder47.Object_Name__c = 'BillingAddress';
    bulkOrderList.add(bulkOrder47);
    
    Bulk_Order_Configuration__c bulkOrder48 = new Bulk_Order_Configuration__c();
    bulkOrder48.Name = 'BCPassport';
    bulkOrder48.Field_Name__c = 'Passport__c';
    bulkOrder48.Identifier__c = ''; 
    bulkOrder48.Object_Name__c = 'BillingContact';
    bulkOrderList.add(bulkOrder48);
    
    Bulk_Order_Configuration__c bulkOrder49 = new Bulk_Order_Configuration__c();
    bulkOrder49.Name = 'BCPostalCode';
    bulkOrder49.Field_Name__c = 'Postal_Code__c';
    bulkOrder49.Identifier__c = 'BillingAddress';
    bulkOrder49.Object_Name__c = 'BillingAddress';
    bulkOrderList.add(bulkOrder49);
    
    Bulk_Order_Configuration__c bulkOrder50 = new Bulk_Order_Configuration__c();
    bulkOrder50.Name = 'BCSalutation';
    bulkOrder50.Field_Name__c = 'Salutation';
    bulkOrder50.Identifier__c = '';
    bulkOrder50.Object_Name__c = 'BillingContact';
    bulkOrderList.add(bulkOrder50);
    
    Bulk_Order_Configuration__c bulkOrder51 = new Bulk_Order_Configuration__c();
    bulkOrder51.Name = 'BCSectionCode';
    bulkOrder51.Field_Name__c = 'Section_Code__c';
    bulkOrder51.Identifier__c = 'BillingAddress';   
    bulkOrder51.Object_Name__c = 'BillingAddress';
    bulkOrderList.add(bulkOrder51);
    
    Bulk_Order_Configuration__c bulkOrder52 = new Bulk_Order_Configuration__c();
    bulkOrder52.Name = 'BCUnitNumber';
    bulkOrder52.Field_Name__c = 'Unit_Number__c';
    bulkOrder52.Identifier__c = 'BillingAddress';   
    bulkOrder52.Object_Name__c = 'BillingAddress';
    bulkOrderList.add(bulkOrder52);
    
    Bulk_Order_Configuration__c bulkOrder53 = new Bulk_Order_Configuration__c();
    bulkOrder53.Name = 'BillingAccountNumber';
    bulkOrder53.Field_Name__c = 'Billing_Account__c';
    bulkOrder53.Identifier__c = '';
    bulkOrder53.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder53);
    
    Bulk_Order_Configuration__c bulkOrder54 = new Bulk_Order_Configuration__c();
    bulkOrder54.Name = 'BusinessNature';
    bulkOrder54.Field_Name__c = 'Business_Nature__c';
    bulkOrder54.Identifier__c = '';
    bulkOrder54.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder54);
    
    Bulk_Order_Configuration__c bulkOrder55 = new Bulk_Order_Configuration__c();
    bulkOrder55.Name = 'CashAmountPaid';
    bulkOrder55.Field_Name__c = 'Amount_Paid__c';
    bulkOrder55.Identifier__c = ''; 
    bulkOrder55.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder55);
    
    Bulk_Order_Configuration__c bulkOrder56 = new Bulk_Order_Configuration__c();
    bulkOrder56.Name = 'CheckAmount';
    bulkOrder56.Field_Name__c = 'Check_Amount__c';
    bulkOrder56.Identifier__c = ''; 
    bulkOrder56.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder56);
    
    Bulk_Order_Configuration__c bulkOrder57 = new Bulk_Order_Configuration__c();
    bulkOrder57.Name = 'CheckDated';
    bulkOrder57.Field_Name__c = 'Check_Dated__c';
    bulkOrder57.Identifier__c = '';
    bulkOrder57.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder57);

    Bulk_Order_Configuration__c bulkOrder58 = new Bulk_Order_Configuration__c();
    bulkOrder58.Name = 'CheckIssuingBank';
    bulkOrder58.Field_Name__c = 'Check_Issuing_Bank__c';
    bulkOrder58.Identifier__c = '';
    bulkOrder58.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder58);
    
    Bulk_Order_Configuration__c bulkOrder59 = new Bulk_Order_Configuration__c();
    bulkOrder59.Name = 'CheckNumber';
    bulkOrder59.Field_Name__c = 'Check_No__c';
    bulkOrder59.Identifier__c = ''; 
    bulkOrder59.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder59);
    
    Bulk_Order_Configuration__c bulkOrder60 = new Bulk_Order_Configuration__c();
    bulkOrder60.Name = 'CheckRemarks';
    bulkOrder60.Field_Name__c = 'Remarks_Check__c';
    bulkOrder60.Identifier__c = ''; 
    bulkOrder60.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder60);
    
    Bulk_Order_Configuration__c bulkOrder61 = new Bulk_Order_Configuration__c();
    bulkOrder61.Name = 'ContactPerson';
    bulkOrder61.Field_Name__c = 'Contact_Person__c';
    bulkOrder61.Identifier__c = '';
    bulkOrder61.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder61);
    
    Bulk_Order_Configuration__c bulkOrder62 = new Bulk_Order_Configuration__c();
    bulkOrder62.Name = 'CostCentre';
    bulkOrder62.Field_Name__c = 'Cost_Centre__c';
    bulkOrder62.Identifier__c = '';
    bulkOrder62.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder62);
    
    Bulk_Order_Configuration__c bulkOrder63 = new Bulk_Order_Configuration__c();
    bulkOrder63.Name = 'CreditAlert';
    bulkOrder63.Field_Name__c = 'Credit_Alert__c';
    bulkOrder63.Identifier__c = ''; 
    bulkOrder63.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder63);
    
    Bulk_Order_Configuration__c bulkOrder64 = new Bulk_Order_Configuration__c();
    bulkOrder64.Name = 'CreditCardAddress1';
    bulkOrder64.Field_Name__c = 'CreditCardAddress1';
    bulkOrder64.Identifier__c = ''; 
    bulkOrder64.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder64);
    
    Bulk_Order_Configuration__c bulkOrder65 = new Bulk_Order_Configuration__c();
    bulkOrder65.Name = 'CreditCardCity';
    bulkOrder65.Field_Name__c = 'CreditCardCity';
    bulkOrder65.Identifier__c = '';
    bulkOrder65.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder65);
    
    Bulk_Order_Configuration__c bulkOrder66 = new Bulk_Order_Configuration__c();
    bulkOrder66.Name = 'CreditCardCountry';
    bulkOrder66.Field_Name__c = 'CreditCardCountry';
    bulkOrder66.Identifier__c = '';
    bulkOrder66.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder66);
    
    Bulk_Order_Configuration__c bulkOrder67 = new Bulk_Order_Configuration__c();
    bulkOrder67.Name = 'CreditCardCVV';
    bulkOrder67.Field_Name__c = 'CreditCardSecurityCode';
    bulkOrder67.Identifier__c = ''; 
    bulkOrder67.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder67);
    
    Bulk_Order_Configuration__c bulkOrder68 = new Bulk_Order_Configuration__c();
    bulkOrder68.Name = 'CreditCardExpirationMonth';
    bulkOrder68.Field_Name__c = 'CreditCardExpirationMonth';
    bulkOrder68.Identifier__c = ''; 
    bulkOrder68.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder68);
    
    Bulk_Order_Configuration__c bulkOrder69 = new Bulk_Order_Configuration__c();
    bulkOrder69.Name = 'CreditCardExpirationYear';
    bulkOrder69.Field_Name__c = 'CreditCardExpirationYear';
    bulkOrder69.Identifier__c = '';
    bulkOrder69.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder69);
    
    Bulk_Order_Configuration__c bulkOrder70 = new Bulk_Order_Configuration__c();
    bulkOrder70.Name = 'CreditCardHolderName';
    bulkOrder70.Field_Name__c = 'CreditCardHolderName';
    bulkOrder70.Identifier__c = '';
    bulkOrder70.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder70);
    
    Bulk_Order_Configuration__c bulkOrder71 = new Bulk_Order_Configuration__c();
    bulkOrder71.Name = 'CreditCardNumber';
    bulkOrder71.Field_Name__c = 'CreditCardNumber';
    bulkOrder71.Identifier__c = ''; 
    bulkOrder71.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder71);
    
    Bulk_Order_Configuration__c bulkOrder72 = new Bulk_Order_Configuration__c();
    bulkOrder72.Name = 'CreditCardType';
    bulkOrder72.Field_Name__c = 'CreditCardType';
    bulkOrder72.Identifier__c = ''; 
    bulkOrder72.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder72);
    
    Bulk_Order_Configuration__c bulkOrder73 = new Bulk_Order_Configuration__c();
    bulkOrder73.Name = 'DateSince';
    bulkOrder73.Field_Name__c = 'Date_Since__c';
    bulkOrder73.Identifier__c = '';
    bulkOrder73.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder73);
    
    Bulk_Order_Configuration__c bulkOrder74 = new Bulk_Order_Configuration__c();
    bulkOrder74.Name = 'DeliveredBy';
    bulkOrder74.Field_Name__c = 'Delivered_By__c';
    bulkOrder74.Identifier__c = '';
    bulkOrder74.Object_Name__c = 'OrderLineItem';
    bulkOrderList.add(bulkOrder74);
    
    Bulk_Order_Configuration__c bulkOrder75 = new Bulk_Order_Configuration__c();
    bulkOrder75.Name = 'DeliveryChargeType';
    bulkOrder75.Field_Name__c = 'Delivery_Charge_Type__c';
    bulkOrder75.Identifier__c = 'Order';    
    bulkOrder75.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder75);
    
    Bulk_Order_Configuration__c bulkOrder76 = new Bulk_Order_Configuration__c();
    bulkOrder76.Name = 'Designation';
    bulkOrder76.Field_Name__c = 'Designation__c';
    bulkOrder76.Identifier__c = ''; 
    bulkOrder76.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder76);
    
    Bulk_Order_Configuration__c bulkOrder77 = new Bulk_Order_Configuration__c();
    bulkOrder77.Name = 'Education';
    bulkOrder77.Field_Name__c = 'Education__c';
    bulkOrder77.Identifier__c = '';
    bulkOrder77.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder77);
    
    Bulk_Order_Configuration__c bulkOrder78 = new Bulk_Order_Configuration__c();
    bulkOrder78.Name = 'EmailSecondary';
    bulkOrder78.Field_Name__c = 'Email_Secondary__c';
    bulkOrder78.Identifier__c = '';
    bulkOrder78.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder78);
    
    Bulk_Order_Configuration__c bulkOrder79 = new Bulk_Order_Configuration__c();
    bulkOrder79.Name = 'EshopRefNo';
    bulkOrder79.Field_Name__c = 'Eshop_Ref_No__c';
    bulkOrder79.Identifier__c = ''; 
    bulkOrder79.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder79);
    
    Bulk_Order_Configuration__c bulkOrder80 = new Bulk_Order_Configuration__c();
    bulkOrder80.Name = 'GenerateInvoice';
    bulkOrder80.Field_Name__c = 'Generate_Invoice__c';
    bulkOrder80.Identifier__c = ''; 
    bulkOrder80.Object_Name__c = 'OrderLineItem';
    bulkOrderList.add(bulkOrder80);
    
    Bulk_Order_Configuration__c bulkOrder81 = new Bulk_Order_Configuration__c();
    bulkOrder81.Name = 'GiftCodes';
    bulkOrder81.Field_Name__c = 'Promotion_Gift__c';
    bulkOrder81.Identifier__c = 'OrderLineItemGift';
    bulkOrder81.Object_Name__c = 'OrderLineItemGift';
    bulkOrderList.add(bulkOrder81);

    Bulk_Order_Configuration__c bulkOrder82 = new Bulk_Order_Configuration__c();
    bulkOrder82.Name = 'GlCode';
    bulkOrder82.Field_Name__c = 'GL_Code__c';
    bulkOrder82.Identifier__c = '';
    bulkOrder82.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder82);
    
    Bulk_Order_Configuration__c bulkOrder83 = new Bulk_Order_Configuration__c();
    bulkOrder83.Name = 'GstInvoice';
    bulkOrder83.Field_Name__c = 'GST_Invoice__c';
    bulkOrder83.Identifier__c = ''; 
    bulkOrder83.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder83);
    
    Bulk_Order_Configuration__c bulkOrder84 = new Bulk_Order_Configuration__c();
    bulkOrder84.Name = 'GstOutOfScope';
    bulkOrder84.Field_Name__c = 'GST_Out_of_Scope__c';
    bulkOrder84.Identifier__c = ''; 
    bulkOrder84.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder84);
    
    Bulk_Order_Configuration__c bulkOrder85 = new Bulk_Order_Configuration__c();
    bulkOrder85.Name = 'IncomeRange';
    bulkOrder85.Field_Name__c = 'Income_Range__c';
    bulkOrder85.Identifier__c = '';
    bulkOrder85.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder85);
    
    Bulk_Order_Configuration__c bulkOrder86 = new Bulk_Order_Configuration__c();
    bulkOrder86.Name = 'Language';
    bulkOrder86.Field_Name__c = 'Language__c';
    bulkOrder86.Identifier__c = '';
    bulkOrder86.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder86);
    
    Bulk_Order_Configuration__c bulkOrder87 = new Bulk_Order_Configuration__c();
    bulkOrder87.Name = 'MailingAgentCode';
    bulkOrder87.Field_Name__c = 'Vendor_Mailing_Agent__c';
    bulkOrder87.Identifier__c = ''; 
    bulkOrder87.Object_Name__c = 'OrderLineItem';
    bulkOrderList.add(bulkOrder87);
    
    Bulk_Order_Configuration__c bulkOrder88 = new Bulk_Order_Configuration__c();
    bulkOrder88.Name = 'NewContractPeriod';
    bulkOrder88.Field_Name__c = 'New_Contract_Period__c';
    bulkOrder88.Identifier__c = ''; 
    bulkOrder88.Object_Name__c = 'OrderLineItem';
    bulkOrderList.add(bulkOrder88);
    
    Bulk_Order_Configuration__c bulkOrder89 = new Bulk_Order_Configuration__c();
    bulkOrder89.Name = 'OtherPaymentMode';
    bulkOrder89.Field_Name__c = 'Other_Payment_Mode__c';
    bulkOrder89.Identifier__c = '';
    bulkOrder89.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder89);
    
    Bulk_Order_Configuration__c bulkOrder90 = new Bulk_Order_Configuration__c();
    bulkOrder90.Name = 'PackageCode';
    bulkOrder90.Field_Name__c = 'Main_Package_ID__c';
    bulkOrder90.Identifier__c = 'OrderLineItem';
    bulkOrder90.Object_Name__c = 'OrderLineItem';
    bulkOrderList.add(bulkOrder90);
    
    Bulk_Order_Configuration__c bulkOrder91 = new Bulk_Order_Configuration__c();
    bulkOrder91.Name = 'Passport';
    bulkOrder91.Field_Name__c = 'Passport__c';
    bulkOrder91.Identifier__c = ''; 
    bulkOrder91.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder91);
    
    Bulk_Order_Configuration__c bulkOrder92 = new Bulk_Order_Configuration__c();
    bulkOrder92.Name = 'Payment Mode';
    bulkOrder92.Field_Name__c = 'Payment_Mode__c';
    bulkOrder92.Identifier__c = 'Order';    
    bulkOrder92.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder92);
    
    Bulk_Order_Configuration__c bulkOrder93 = new Bulk_Order_Configuration__c();
    bulkOrder93.Name = 'PromotionCode';
    bulkOrder93.Field_Name__c = 'Promotion_Id__c';
    bulkOrder93.Identifier__c = 'OrderLineItem';
    bulkOrder93.Object_Name__c = 'OrderLineItem';
    bulkOrderList.add(bulkOrder93);
    
    Bulk_Order_Configuration__c bulkOrder94 = new Bulk_Order_Configuration__c();
    bulkOrder94.Name = 'Quantity';
    bulkOrder94.Field_Name__c = 'Qty__c';
    bulkOrder94.Identifier__c = '';
    bulkOrder94.Object_Name__c = 'OrderLineItem';
    bulkOrderList.add(bulkOrder94);
    
    Bulk_Order_Configuration__c bulkOrder95 = new Bulk_Order_Configuration__c();
    bulkOrder95.Name = 'Race';
    bulkOrder95.Field_Name__c = 'Race__c';
    bulkOrder95.Identifier__c = ''; 
    bulkOrder95.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder95);
    
    Bulk_Order_Configuration__c bulkOrder96 = new Bulk_Order_Configuration__c();
    bulkOrder96.Name = 'RCAccountName2';
    bulkOrder96.Field_Name__c = 'Billing_Account_Name_2__c';
    bulkOrder96.Identifier__c = ''; 
    bulkOrder96.Object_Name__c = 'RecipientContact';
    bulkOrderList.add(bulkOrder96);
    
    Bulk_Order_Configuration__c bulkOrder97 = new Bulk_Order_Configuration__c();
    bulkOrder97.Name = 'RCAdditionalInfo';
    bulkOrder97.Field_Name__c = 'Additional_Info__c';
    bulkOrder97.Identifier__c = '';
    bulkOrder97.Object_Name__c = 'RecipientAddress';
    bulkOrderList.add(bulkOrder97);
    
    Bulk_Order_Configuration__c bulkOrder98 = new Bulk_Order_Configuration__c();
    bulkOrder98.Name = 'RCAddress1';
    bulkOrder98.Field_Name__c = 'Address_1__c';
    bulkOrder98.Identifier__c = 'RecipientAddress';
    bulkOrder98.Object_Name__c = 'RecipientAddress';
    bulkOrderList.add(bulkOrder98);
    
    Bulk_Order_Configuration__c bulkOrder99 = new Bulk_Order_Configuration__c();
    bulkOrder99.Name = 'RCAddress2';
    bulkOrder99.Field_Name__c = 'Address_2__c';
    bulkOrder99.Identifier__c = 'RecipientAddress'; 
    bulkOrder99.Object_Name__c = 'RecipientAddress';
    bulkOrderList.add(bulkOrder99);
    
    Bulk_Order_Configuration__c bulkOrder100 = new Bulk_Order_Configuration__c();
    bulkOrder100.Name = 'RCAddress3';
    bulkOrder100.Field_Name__c = 'Address_3__c';
    bulkOrder100.Identifier__c = 'RecipientAddress';    
    bulkOrder100.Object_Name__c = 'RecipientAddress';
    bulkOrderList.add(bulkOrder100);
    
    Bulk_Order_Configuration__c bulkOrder101 = new Bulk_Order_Configuration__c();
    bulkOrder101.Name = 'RCAddress4';
    bulkOrder101.Field_Name__c = 'Address_4__c';
    bulkOrder101.Identifier__c = 'RecipientAddress';
    bulkOrder101.Object_Name__c = 'RecipientAddress';
    bulkOrderList.add(bulkOrder101);
    
    Bulk_Order_Configuration__c bulkOrder102 = new Bulk_Order_Configuration__c();
    bulkOrder102.Name = 'RCAddressRecordType';
    bulkOrder102.Field_Name__c = 'RecordTypeId';
    bulkOrder102.Identifier__c = 'RecipientAddress';
    bulkOrder102.Object_Name__c = 'RecipientAddress';
    bulkOrderList.add(bulkOrder102);
    
    Bulk_Order_Configuration__c bulkOrder103 = new Bulk_Order_Configuration__c();
    bulkOrder103.Name = 'RCAttnToName';
    bulkOrder103.Field_Name__c = 'Company_Name__c';
    bulkOrder103.Identifier__c = '';    
    bulkOrder103.Object_Name__c = 'RecipientContact';
    bulkOrderList.add(bulkOrder103);
    
    Bulk_Order_Configuration__c bulkOrder104 = new Bulk_Order_Configuration__c();
    bulkOrder104.Name = 'RCBusinessAddressIndicator';
    bulkOrder104.Field_Name__c = 'Business_Address_Indicator__c';
    bulkOrder104.Identifier__c = '';    
    bulkOrder104.Object_Name__c = 'RecipientContact';
    bulkOrderList.add(bulkOrder104);
    
    Bulk_Order_Configuration__c bulkOrder105 = new Bulk_Order_Configuration__c();
    bulkOrder105.Name = 'RCCityCode';
    bulkOrder105.Field_Name__c = 'City__c';
    bulkOrder105.Identifier__c = 'RecipientAddress';
    bulkOrder105.Object_Name__c = 'RecipientAddress';
    bulkOrderList.add(bulkOrder105);
    
    Bulk_Order_Configuration__c bulkOrder106 = new Bulk_Order_Configuration__c();
    bulkOrder106.Name = 'RCCompanyCode';
    bulkOrder106.Field_Name__c = 'Company_Code__c';
    bulkOrder106.Identifier__c = 'RecipientAddress';
    bulkOrder106.Object_Name__c = 'RecipientAddress';
    bulkOrderList.add(bulkOrder106);
    
    Bulk_Order_Configuration__c bulkOrder107 = new Bulk_Order_Configuration__c();
    bulkOrder107.Name = 'RCCountryCode';
    bulkOrder107.Field_Name__c = 'Country__c';
    bulkOrder107.Identifier__c = 'RecipientAddress';    
    bulkOrder107.Object_Name__c = 'RecipientAddress';
    bulkOrderList.add(bulkOrder107);
    
    Bulk_Order_Configuration__c bulkOrder108 = new Bulk_Order_Configuration__c();
    bulkOrder108.Name = 'RCDepartmentCode';
    bulkOrder108.Field_Name__c = 'Department__c';
    bulkOrder108.Identifier__c = 'RecipientAddress';    
    bulkOrder108.Object_Name__c = 'RecipientAddress';
    bulkOrderList.add(bulkOrder108);
    
    Bulk_Order_Configuration__c bulkOrder109 = new Bulk_Order_Configuration__c();
    bulkOrder109.Name = 'RCDivisionCode';
    bulkOrder109.Field_Name__c = 'Division_Code__c';
    bulkOrder109.Identifier__c = 'RecipientAddress';
    bulkOrder109.Object_Name__c = 'RecipientAddress';
    bulkOrderList.add(bulkOrder109);
    
    Bulk_Order_Configuration__c bulkOrder110 = new Bulk_Order_Configuration__c();
    bulkOrder110.Name = 'RCEmail';
    bulkOrder110.Field_Name__c = 'Email__c';
    bulkOrder110.Identifier__c = '';
    bulkOrder110.Object_Name__c = 'RecipientContact';
    bulkOrderList.add(bulkOrder110);
    
    Bulk_Order_Configuration__c bulkOrder111 = new Bulk_Order_Configuration__c();
    bulkOrder111.Name = 'RCEmailSecondary';
    bulkOrder111.Field_Name__c = 'Email_Secondary__c';
    bulkOrder111.Identifier__c = '';    
    bulkOrder111.Object_Name__c = 'RecipientContact';
    bulkOrderList.add(bulkOrder111);
    
    Bulk_Order_Configuration__c bulkOrder112 = new Bulk_Order_Configuration__c();
    bulkOrder112.Name = 'RCFax';
    bulkOrder112.Field_Name__c = 'Fax__c';
    bulkOrder112.Identifier__c = '';    
    bulkOrder112.Object_Name__c = 'RecipientContact';
    bulkOrderList.add(bulkOrder112);
    
    Bulk_Order_Configuration__c bulkOrder113 = new Bulk_Order_Configuration__c();
    bulkOrder113.Name = 'RCFirstName';
    bulkOrder113.Field_Name__c = 'FirstName';
    bulkOrder113.Identifier__c = 'RecipientContact';
    bulkOrder113.Object_Name__c = 'RecipientContact';
    bulkOrderList.add(bulkOrder113);
    
    Bulk_Order_Configuration__c bulkOrder114 = new Bulk_Order_Configuration__c();
    bulkOrder114.Name = 'RCHomeNumber';
    bulkOrder114.Field_Name__c = 'HomePhone__c';
    bulkOrder114.Identifier__c = '';
    bulkOrder114.Object_Name__c = 'RecipientContact';
    bulkOrderList.add(bulkOrder114);
    
    Bulk_Order_Configuration__c bulkOrder115 = new Bulk_Order_Configuration__c();
    bulkOrder115.Name = 'RCLastName';
    bulkOrder115.Field_Name__c = 'LastName';
    bulkOrder115.Identifier__c = 'RecipientContact';    
    bulkOrder115.Object_Name__c = 'RecipientContact';
    bulkOrderList.add(bulkOrder115);
    
    Bulk_Order_Configuration__c bulkOrder116 = new Bulk_Order_Configuration__c();
    bulkOrder116.Name = 'RCLevelNumber';
    bulkOrder116.Field_Name__c = 'Level_Number__c';
    bulkOrder116.Identifier__c = 'RecipientAddress';    
    bulkOrder116.Object_Name__c = 'RecipientAddress';
    bulkOrderList.add(bulkOrder116);
    
    Bulk_Order_Configuration__c bulkOrder117 = new Bulk_Order_Configuration__c();
    bulkOrder117.Name = 'RCLocationCode';
    bulkOrder117.Field_Name__c = 'Location_Code__c';
    bulkOrder117.Identifier__c = 'RecipientAddress';
    bulkOrder117.Object_Name__c = 'RecipientAddress';
    bulkOrderList.add(bulkOrder117);
    
    Bulk_Order_Configuration__c bulkOrder118 = new Bulk_Order_Configuration__c();
    bulkOrder118.Name = 'RCMobileNumber';
    bulkOrder118.Field_Name__c = 'Mobile_Number__c';
    bulkOrder118.Identifier__c = '';
    bulkOrder118.Object_Name__c = 'RecipientContact';
    bulkOrderList.add(bulkOrder118);
    
    Bulk_Order_Configuration__c bulkOrder119 = new Bulk_Order_Configuration__c();
    bulkOrder119.Name = 'RCMobileNumber2';
    bulkOrder119.Field_Name__c = 'Mobile_Number_2__c';
    bulkOrder119.Identifier__c = '';    
    bulkOrder119.Object_Name__c = 'RecipientContact';
    bulkOrderList.add(bulkOrder119);
    
    Bulk_Order_Configuration__c bulkOrder120 = new Bulk_Order_Configuration__c();
    bulkOrder120.Name = 'RCNRIC';
    bulkOrder120.Field_Name__c = 'NRIC__c';
    bulkOrder120.Identifier__c = '';    
    bulkOrder120.Object_Name__c = 'RecipientContact';
    bulkOrderList.add(bulkOrder120);
    
    Bulk_Order_Configuration__c bulkOrder121 = new Bulk_Order_Configuration__c();
    bulkOrder121.Name = 'RCOfficeExtension';
    bulkOrder121.Field_Name__c = 'Office_Extension__c';
    bulkOrder121.Identifier__c = '';
    bulkOrder121.Object_Name__c = 'RecipientContact';
    bulkOrderList.add(bulkOrder121);
    
    Bulk_Order_Configuration__c bulkOrder122 = new Bulk_Order_Configuration__c();
    bulkOrder122.Name = 'RCOfficeNumber';
    bulkOrder122.Field_Name__c = 'Office_Number__c';
    bulkOrder122.Identifier__c = '';
    bulkOrder122.Object_Name__c = 'RecipientContact';
    bulkOrderList.add(bulkOrder122);
    
    Bulk_Order_Configuration__c bulkOrder123 = new Bulk_Order_Configuration__c();
    bulkOrder123.Name = 'RCPackingCode';
    bulkOrder123.Field_Name__c = 'Packing_Code__c';
    bulkOrder123.Identifier__c = 'RecipientAddress';    
    bulkOrder123.Object_Name__c = 'RecipientAddress';
    bulkOrderList.add(bulkOrder123);
    
    Bulk_Order_Configuration__c bulkOrder124 = new Bulk_Order_Configuration__c();
    bulkOrder124.Name = 'RCPassport';
    bulkOrder124.Field_Name__c = 'Passport__c';
    bulkOrder124.Identifier__c = '';    
    bulkOrder124.Object_Name__c = 'RecipientContact';
    bulkOrderList.add(bulkOrder124);
    
    Bulk_Order_Configuration__c bulkOrder125 = new Bulk_Order_Configuration__c();
    bulkOrder125.Name = 'RCPostalCode';
    bulkOrder125.Field_Name__c = 'Postal_Code__c';
    bulkOrder125.Identifier__c = 'RecipientAddress';
    bulkOrder125.Object_Name__c = 'RecipientAddress';
    bulkOrderList.add(bulkOrder125);
    
    Bulk_Order_Configuration__c bulkOrder126 = new Bulk_Order_Configuration__c();
    bulkOrder126.Name = 'RCSalutation';
    bulkOrder126.Field_Name__c = 'Salutation';
    bulkOrder126.Identifier__c = '';
    bulkOrder126.Object_Name__c = 'RecipientContact';
    bulkOrderList.add(bulkOrder126);
    
    Bulk_Order_Configuration__c bulkOrder127 = new Bulk_Order_Configuration__c();
    bulkOrder127.Name = 'RCSectionCode';
    bulkOrder127.Field_Name__c = 'Section_Code__c';
    bulkOrder127.Identifier__c = 'RecipientAddress';    
    bulkOrder127.Object_Name__c = 'RecipientAddress';
    bulkOrderList.add(bulkOrder127);
    
    Bulk_Order_Configuration__c bulkOrder128 = new Bulk_Order_Configuration__c();
    bulkOrder128.Name = 'RCUnitNumber';
    bulkOrder128.Field_Name__c = 'Unit_Number__c';
    bulkOrder128.Identifier__c = 'RecipientAddress';    
    bulkOrder128.Object_Name__c = 'RecipientAddress';
    bulkOrderList.add(bulkOrder128);
    
    Bulk_Order_Configuration__c bulkOrder129 = new Bulk_Order_Configuration__c();
    bulkOrder129.Name = 'RenewalLetter';
    bulkOrder129.Field_Name__c = 'Renewal_Letter__c';
    bulkOrder129.Identifier__c = '';
    bulkOrder129.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder129);
    
    Bulk_Order_Configuration__c bulkOrder130 = new Bulk_Order_Configuration__c();
    bulkOrder130.Name = 'SmsRenewalNotification';
    bulkOrder130.Field_Name__c = 'SMS_Renewal_Notification__c';
    bulkOrder130.Identifier__c = '';
    bulkOrder130.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder130);
    
    Bulk_Order_Configuration__c bulkOrder131 = new Bulk_Order_Configuration__c();
    bulkOrder131.Name = 'Sponsor';
    bulkOrder131.Field_Name__c = 'Sponsor__c';
    bulkOrder131.Identifier__c = '';    
    bulkOrder131.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder131);
    
    Bulk_Order_Configuration__c bulkOrder132 = new Bulk_Order_Configuration__c();
    bulkOrder132.Name = 'StaffId';
    bulkOrder132.Field_Name__c = 'Staff_ID__c';
    bulkOrder132.Identifier__c = '';    
    bulkOrder132.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder132);
    
    Bulk_Order_Configuration__c bulkOrder133 = new Bulk_Order_Configuration__c();
    bulkOrder133.Name = 'StartDate';
    bulkOrder133.Field_Name__c = 'Start_Date__c';
    bulkOrder133.Identifier__c = 'OrderLineItem';
    bulkOrder133.Object_Name__c = 'OrderLineItem';
    bulkOrderList.add(bulkOrder133);
    
    Bulk_Order_Configuration__c bulkOrder134 = new Bulk_Order_Configuration__c();
    bulkOrder134.Name = 'SubGroup';
    bulkOrder134.Field_Name__c = 'Sub_Group__c';
    bulkOrder134.Identifier__c = '';
    bulkOrder134.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder134);
    
    Bulk_Order_Configuration__c bulkOrder135 = new Bulk_Order_Configuration__c();
    bulkOrder135.Name = 'SuppressAcknoweledgementLetter';
    bulkOrder135.Field_Name__c = 'Supressed_Acknowledgement_Letter__c';
    bulkOrder135.Identifier__c = '';    
    bulkOrder135.Object_Name__c = 'OrderLineItem';
    bulkOrderList.add(bulkOrder135);
    
    Bulk_Order_Configuration__c bulkOrder136 = new Bulk_Order_Configuration__c();
    bulkOrder136.Name = 'SuppressRenewalAndReminderLetter';
    bulkOrder136.Field_Name__c = 'Suppress_Renewal_and_Reminder_Letter__c';
    bulkOrder136.Identifier__c = '';    
    bulkOrder136.Object_Name__c = 'OrderLineItem';
    bulkOrderList.add(bulkOrder136);
    
    Bulk_Order_Configuration__c bulkOrder137 = new Bulk_Order_Configuration__c();
    bulkOrder137.Name = 'SuppressVendorNotification';
    bulkOrder137.Field_Name__c = 'Supressed_Vendor_Notification_New_Sub__c';
    bulkOrder137.Identifier__c = '';
    bulkOrder137.Object_Name__c = 'OrderLineItem';
    bulkOrderList.add(bulkOrder137);
    
    Bulk_Order_Configuration__c bulkOrder138 = new Bulk_Order_Configuration__c();
    bulkOrder138.Name = 'UniqueEntityNumber';
    bulkOrder138.Field_Name__c = 'Unique_Entity_Number__c';
    bulkOrder138.Identifier__c = '';
    bulkOrder138.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder138);
    
    Bulk_Order_Configuration__c bulkOrder139 = new Bulk_Order_Configuration__c();
    bulkOrder139.Name = 'VendorCommunicationPreference';
    bulkOrder139.Field_Name__c = 'Vendor_Communication_Preference__c';
    bulkOrder139.Identifier__c = '';    
    bulkOrder139.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder139);
    
    Bulk_Order_Configuration__c bulkOrder140 = new Bulk_Order_Configuration__c();
    bulkOrder140.Name = 'VendorSmsRemark';
    bulkOrder140.Field_Name__c = 'Vendor_Sms_Remarks__c';
    bulkOrder140.Identifier__c = '';    
    bulkOrder140.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder140);
    
    Bulk_Order_Configuration__c bulkOrder141 = new Bulk_Order_Configuration__c();
    bulkOrder141.Name = 'VipStaffEmail';
    bulkOrder141.Field_Name__c = 'VIP_Email__c';
    bulkOrder141.Identifier__c = '';
    bulkOrder141.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder141);
    
    Bulk_Order_Configuration__c bulkOrder142 = new Bulk_Order_Configuration__c();
    bulkOrder142.Name = 'VipStaffHomePhone';
    bulkOrder142.Field_Name__c = 'VIP_Staff_Home_Phone__c';
    bulkOrder142.Identifier__c = '';    
    bulkOrder142.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder142);
    
    Bulk_Order_Configuration__c bulkOrder143 = new Bulk_Order_Configuration__c();
    bulkOrder143.Name = 'VipStaffMobilePhone';
    bulkOrder143.Field_Name__c = 'VIP_Mobile__c';
    bulkOrder143.Identifier__c = '';
    bulkOrder143.Object_Name__c = 'Account';
    bulkOrderList.add(bulkOrder143);
    
    Bulk_Order_Configuration__c bulkOrder144 = new Bulk_Order_Configuration__c();
    bulkOrder144.Name = 'DeliveryAmount';
    bulkOrder144.Field_Name__c = 'Subscriber_Charge__c';
    bulkOrder144.Identifier__c = '';
    bulkOrder144.Object_Name__c = 'Order';
    bulkOrderList.add(bulkOrder144);
    
    //End UD-3660 For Test Class    

    
    return bulkOrderList;

  }

  public static BulkAsiaOneConfigParams__c createBulkAsiaOne() {
    BulkAsiaOneConfigParams__c bulkAsiaOne = new BulkAsiaOneConfigParams__c();
    bulkAsiaOne.Name = 'AsiaOne';
    bulkAsiaOne.Enable__c = 'yes';
    bulkAsiaOne.ip__c = '202.17.111.2';
    bulkAsiaOne.Password__c = 'Password1';
    bulkAsiaOne.passwordChallenge__c = 'what is the capital of the UK';
    bulkAsiaOne.passwordResponse__c = 'London';
    return bulkAsiaOne;
  }

  public static List <Charge__c> createCharge() {
    List <Charge__c> chargeList = new List <Charge__c>();
    
    chargeList.add(new Charge__c(Name ='AddressType_A',Charge_Amount__c = 4,Charge_Type__c = 'Address Type',House_Type_c__c = 'A'));
    chargeList.add(new Charge__c(Name ='AddressType_B',Charge_Amount__c = 4,Charge_Type__c = 'Address Type',House_Type_c__c = 'A'));
    chargeList.add(new Charge__c(Name ='AddressType_C',Charge_Amount__c = 4,Charge_Type__c = 'Address Type',House_Type_c__c = 'A'));
    chargeList.add(new Charge__c(Name ='AddressType_G',Charge_Amount__c = 4,Charge_Type__c = 'Address Type',House_Type_c__c = 'A'));
    chargeList.add(new Charge__c(Name ='AddressType_H',Charge_Amount__c = 3,Charge_Type__c = 'Address Type',House_Type_c__c = 'H'));
    chargeList.add(new Charge__c(Name ='AddressType_K',Charge_Amount__c = 4,Charge_Type__c = 'Address Type',House_Type_c__c = 'A'));
    chargeList.add(new Charge__c(Name ='AddressType_P',Charge_Amount__c = 4,Charge_Type__c = 'Address Type',House_Type_c__c = 'A'));
    chargeList.add(new Charge__c(Name ='AddressType_S',Charge_Amount__c = 5,Charge_Type__c = 'Address Type',House_Type_c__c = 'L'));
    chargeList.add(new Charge__c(Name ='AddressType_U',Charge_Amount__c = 4,Charge_Type__c = 'Address Type',House_Type_c__c = 'A'));
    chargeList.add(new Charge__c(Name ='AddressType_W',Charge_Amount__c = 4,Charge_Type__c = 'Address Type'));
    
    chargeList.add(new Charge__c(Name ='DeliveryCharge_9',Charge_Amount__c = 0,Charge_Type__c = 'Delivery Charge'));
    chargeList.add(new Charge__c(Name ='DeliveryCharge_C',Charge_Amount__c = 4,Charge_Type__c = 'Delivery Charge'));
    chargeList.add(new Charge__c(Name ='DeliveryCharge_H',Charge_Amount__c = 4,Charge_Type__c = 'Delivery Charge'));
    chargeList.add(new Charge__c(Name ='DeliveryCharge_L',Charge_Amount__c = 4,Charge_Type__c = 'Delivery Charge'));
    chargeList.add(new Charge__c(Name ='DeliveryCharge_N',Charge_Amount__c = 0,Charge_Type__c = 'Delivery Charge'));
    chargeList.add(new Charge__c(Name ='DeliveryCharge_S',Charge_Amount__c = 0,Charge_Type__c = 'Delivery Charge'));
    chargeList.add(new Charge__c(Name ='DeliveryCharge_Z',Charge_Amount__c = 0,Charge_Type__c = 'Delivery Charge'));
    
    chargeList.add(new Charge__c(Name = 'VendorCredit_C',Charge_Amount__c = 4,Charge_Type__c = 'Vendor Credit'));
    chargeList.add(new Charge__c(Name = 'VendorCredit_H',Charge_Amount__c = 4,Charge_Type__c = 'Vendor Credit'));
    chargeList.add(new Charge__c(Name = 'VendorCredit_L',Charge_Amount__c = 4,Charge_Type__c = 'Vendor Credit'));
    chargeList.add(new Charge__c(Name = 'VendorCredit_S',Charge_Amount__c = 0,Charge_Type__c = 'Vendor Credit'));
    chargeList.add(new Charge__c(Name = 'VendorCredit_Z',Charge_Amount__c = 0,Charge_Type__c = 'Vendor Credit'));
    
    return chargeList;
    
  }

  public static Cir_Planner_Schedule__c createPlannerSched() {
    Cir_Planner_Schedule__c plannerSched = new Cir_Planner_Schedule__c();
    plannerSched.Name = 'CIR Plan Schedule';
    plannerSched.Mon_Fri_End_Time__c = datetime.newInstance(2016, 04, 13, 23, 59, 0);       
    plannerSched.Mon_Fri_Start_Time__c = datetime.newInstance(2014, 8, 19, 1, 0, 0);        
    plannerSched.Sat_PH_End_Time__c = datetime.newInstance(2014, 8, 18, 17, 0, 0);          
    plannerSched.Sat_PH_Start_Time__c = datetime.newInstance(2014, 8, 18, 8, 0, 0);     
    plannerSched.Sun_End_Time__c = datetime.newInstance(2014, 8, 18, 17, 0, 0);         
    plannerSched.Sun_Start_Time__c = datetime.newInstance(2014, 8, 18, 10, 0, 0);           
    return plannerSched ;

  }

  Public static List <Courier_Charge__c> createCourier() {
    List <Courier_Charge__c> courierList = new List <Courier_Charge__c>();
    
    Courier_Charge__c courier1 = new Courier_Charge__c();
    courier1.Name = 'Fri';
    courier1.Courier_Fee__c = 10;
    courierList.add(courier1);
    
    Courier_Charge__c courier2 = new Courier_Charge__c();
    courier2.Name = 'Mon';
    courier2.Courier_Fee__c = 10;
    courierList.add(courier2);
    
    Courier_Charge__c courier3 = new Courier_Charge__c();
    courier3.Name = 'PH';
    courier3.Courier_Fee__c = 20;
    courierList.add(courier3);
    
    Courier_Charge__c courier4 = new Courier_Charge__c();
    courier4.Name = 'Sat';
    courier4.Courier_Fee__c = 20;
    courierList.add(courier4);
    
    Courier_Charge__c courier5 = new Courier_Charge__c();
    courier5.Name = 'Sun';
    courier5.Courier_Fee__c = 20;
    courierList.add(courier5);
    
    Courier_Charge__c courier6 = new Courier_Charge__c();
    courier6.Name = 'Thu';
    courier6.Courier_Fee__c = 10;
    courierList.add(courier6);
    
    Courier_Charge__c courier7 = new Courier_Charge__c();
    courier7.Name = 'Tue';
    courier7.Courier_Fee__c = 10;
    courierList.add(courier7);
    
    Courier_Charge__c courier8 = new Courier_Charge__c();
    courier8.Name = 'Wed';
    courier8.Courier_Fee__c = 10;
    courierList.add(courier8);
    
    return courierList;
  }

  public static List <Date_Configuration__c> createDateConfig() {
    List <Date_Configuration__c> dateConfigList = new List <Date_Configuration__c>();
    
    Date_Configuration__c dateConfig1 = new Date_Configuration__c();
    dateConfig1.Name = 'PAYMENT_FAILURE_TEST_PSTOP_DATE';
    dateConfig1.Date__c = date.newInstance(2016,5,16);
    dateConfigList.add(dateConfig1);
    
    Date_Configuration__c dateConfig2 = new Date_Configuration__c();
    dateConfig2.Name = 'Usage Reference Date';
    dateConfig2.Date__c = date.newInstance(2016,5,11);
    dateConfigList.add(dateConfig2);
    
    return dateConfigList;
  }

 
  public static List <Delivery_Charge_Type__c> createChargeType() {
    List <Delivery_Charge_Type__c> chargeTypeList = new List <Delivery_Charge_Type__c>();
    
    Delivery_Charge_Type__c chargeTypeA = new Delivery_Charge_Type__c();
    chargeTypeA.Name = 'A';
    chargeTypeA.Default_Delivery_Charge_Type__c = 'C';
    chargeTypeList.add(chargeTypeA);
    
    Delivery_Charge_Type__c chargeTypeB = new Delivery_Charge_Type__c();
    chargeTypeB.Name = 'B';
    chargeTypeB.Default_Delivery_Charge_Type__c = 'C';
    chargeTypeList.add(chargeTypeB);
    
    Delivery_Charge_Type__c chargeTypeC = new Delivery_Charge_Type__c();
    chargeTypeC.Name = 'C';
    chargeTypeC.Default_Delivery_Charge_Type__c = 'C';
    chargeTypeList.add(chargeTypeC);
    
    Delivery_Charge_Type__c chargeTypeG = new Delivery_Charge_Type__c();
    chargeTypeG.Name = 'G';
    chargeTypeG.Default_Delivery_Charge_Type__c = 'C';
    chargeTypeList.add(chargeTypeG);
    
    Delivery_Charge_Type__c chargeTypeH = new Delivery_Charge_Type__c();
    chargeTypeH.Name = 'H';
    chargeTypeH.Default_Delivery_Charge_Type__c = 'H';
    chargeTypeList.add(chargeTypeH);
    
    Delivery_Charge_Type__c chargeTypeK = new Delivery_Charge_Type__c();
    chargeTypeK.Name = 'K';
    chargeTypeK.Default_Delivery_Charge_Type__c = 'C';
    chargeTypeList.add(chargeTypeK);
    
    Delivery_Charge_Type__c chargeTypeP = new Delivery_Charge_Type__c();
    chargeTypeP.Name = 'P';
    chargeTypeP.Default_Delivery_Charge_Type__c = 'C';
    chargeTypeList.add(chargeTypeP);
    
    Delivery_Charge_Type__c chargeTypeS = new Delivery_Charge_Type__c();
    chargeTypeS.Name = 'S';
    chargeTypeS.Default_Delivery_Charge_Type__c = 'L';
    chargeTypeList.add(chargeTypeS);
    
    Delivery_Charge_Type__c chargeTypeU = new Delivery_Charge_Type__c();
    chargeTypeU.Name = 'U';
    chargeTypeU.Default_Delivery_Charge_Type__c = 'C';
    chargeTypeList.add(chargeTypeU);
    
    Delivery_Charge_Type__c chargeTypeW = new Delivery_Charge_Type__c();
    chargeTypeW.Name = 'W';
    chargeTypeW.Default_Delivery_Charge_Type__c = 'C';
    chargeTypeList.add(chargeTypeW);
    
    return chargeTypeList;
  }

  public static List <Email__c> createEmail() {
    List <Email__c> emailList = new List <Email__c>();
    
    Email__c email1 = new Email__c();
    email1.Name = 'Direct Subs Newsvendor Recipient';
    email1.Email__c = 'crsm_reports@sph.com.sg.dummy';
    emailList.add(email1);
    
    Email__c email2 = new Email__c();
    email2.Name = 'Usage Email';
    email2.Email__c = 'crisanto.f.de.llamas@accenture.com';
    emailList.add(email2);
    
    return emailList;
    
  }
  
  //Created by: JPSulit 4/26/2016
  public static List<Other__c> createOther(Integer recCount) {
      Other__c oth;
      List<Other__c> othList = new List<Other__c>();
      for(Integer i = 0; i < recCount; i++) {
          oth = new Other__c();
          oth.Name = 'DTL';
          oth.Value__c = '23:59';
          othList.add(oth);
      }
      return othList;
  }
  //Created by: JPSulit 4/26/2016

}