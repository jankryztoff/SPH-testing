/**
     * Class Name: UsageHelper 
     * @author: John Dacutan
     * Date: 02/02/2015
     * Requirement/Project Name: CRSM Project
     * @description: Helper class to any Usage related functionalities
     * History : 2/3/2015 : Joban - Added utility method for issues calculation
     * -- 3/30/2015 D - 2656 Added by Joban - Added logic to check for the published days string
     */
    public class UsageHelper {

        // start constants declaration
        //START: D-2565 03/21/2015 Added by S.PULI - add public tag
        public final static string DAY_NAME_DATE_PATTERN = 'EEEE';
        public final static string DEFAULT_SUBSCRIPTION_FREQUENCY = 'Default';
        public final static string MONDAY = 'Monday';
        public final static string TUESDAY = 'Tuesday';
        public final static string WEDNESDAY = 'Wednesday';
        public final static string THURSDAY = 'Thursday';
        public final static string FRIDAY = 'Friday';
        public final static string SATURDAY = 'Saturday';
        public final static string SUNDAY = 'Sunday';
        public final static string USAGE_STATUS = 'New';
        public final static string PUBLISHED_DAY_YES = 'Y';
        public final static string CSV_DELIMITER = ',';
        public final static integer REQUEST_MAX_USAGE = 50;
        public final static string REQUEST_FIELD_SUBSCRIPTION_NUMBER = 'SubscriptionNumber';
        public final static string REQUEST_FIELD_ACCOUNT_NUMBER = 'AccountNumber';
        public final static string REQUEST_FIELD_UOM = 'UOM';
        public final static string REQUEST_FIELD_START_DATE_TIME = 'StartDateTime';
        public final static string REQUEST_FIELD_QUANTITY = 'Quantity';
        //public final static string REQUEST_FIELD_STOP_TYPE = 'StopType'; // Start/End D-2826 08May15 Von/JohnD
        public final static string REQUEST_TYPE = 'Usage';
        public final static string RESPONSE_FIELD_STATUS = 'Status';
        public final static string RESPONSE_FIELD_ID = 'Id';
        public final static string RESPONSE_FIELD_MESSAGE = 'Message';
        //END: D-2565 03/21/2015 Added by S.PULI
                // START 03/30/2015 D-2610 Kevin Evasco - New Utility Constants
                public final static string REQUEST_FIELD_STOP_TYPE = 'StopType__c'; // Start/End D-2826 08May15 Von/JohnD
                public final static string REQUEST_FIELD_CHARGE_NUMBER = 'ChargeNumber';
                public final static string USAGE_STATUS_SUCCESS = 'Success';
                public final static string USAGE_STATUS_FAILED = 'Failed';  
                public final static string USAGE_TYPE_FULL_PREPAID_STOP = 'FullPrepaid_Stop';
                public final static string USAGE_TYPE_RECURRING_PREPAID_START = 'RecurringPrepaid_Start';
                public final static string USAGE_TYPE_RECURRING_PREPAID_STOP = 'RecurringPrepaid_Stop';
                public final static string USAGE_TYPE_RECURRING_PREPAID_EXPIRY = 'RecurringPrepaid_Expiry';
                public final static string USAGE_TYPE_RECURRING_POSTPAID_MONTHLY = 'RecurringPostpaid_Monthly';
                public final static string USAGE_TYPE_RECURRING_POSTPAID_STOP = 'RecurringPostpaid_Stop';   // Start/End UD-1767 15Jul15 JohnD
                public final static string USAGE_TYPE_GOODWILL = 'Goodwill';
                public final static string USAGE_TYPE_NONDELIVERY = 'NonDelivery';
                public final static string USAGE_TYPE_TSTOP = 'Tstop';
                public final static string USAGE_TYPE_DELIVERY_CHARGE = 'DeliveryCharge';
                public final static string USAGE_TYPE_POSTAGE_CHARGE = 'PostageCharge';
                public final static string USAGE_TYPE_GRACE = 'Grace';
                
                public final static string UOM_PRORATION_CREDITS_BY_MONTH = 'Proration Credits by Month Usage';
                public final static string UOM_NON_CHARGEABLE_COPY = 'Non Chargeable Copy Usage';
                public final static string UOM_DELIVERY_CHARGE = 'Delivery Charge Usage';
                public final static string UOM_DELIVERY_CREDITS = 'Delivery Credits Usage';
                public final static string UOM_POSTAGE_CHARGE = 'Postage Charge';
                public final static string UOM_POSTAGE_CREDITS = 'Postage Credits Usage';
                public final static string UOM_PREPAID_MONTHLY = 'Prepaid Monthly';
                public final static string UOM_POSTPAID_USAGE = 'Postpaid Usage';
                public final static string UOM_PRORATION_CHARGE = 'Proration Charge Usage';
                public final static string UOM_PRORATION_CREDIT = 'Proration Credit Usage';
                public final static string UOM_PRORATION_GOODWILL_CREDIT = 'Proration Goodwill Credit Usage';
                public final static string UOM_PRORATION_CREDITS_BY_ISSUE = 'Proration Credits by Issue Usage';
                // END 03/30/2015 D-2610 Kevin Evasco - New Utility Constants
        // end constants declaration
        
        list<exception> exceptionList = new list<exception>();
        //Start : 2/3/2015 Joban - Code for Issue calculation
        
        //@Description: Method to populate the collections used in the IssueCalculation utility method
        public static void initialize(){
            if(NonPublicationDate == null){
                getNonPubDate();
            }
            if(PublicHolidaysFortheMonth == null){
                getPublicHolidaysFortheMonth();
            }
            if(PublicationInformation == null){
                getPublicationInformation();
            }
        }
        //@Description: Method to clear the data present in the data structures
        public static void uninitialize(){
            NonPublicationDate.clear();
            PublicHolidaysFortheMonth.clear();
            PublicationInformation.clear();
        }
        
        public static map<String,Set<Date>> NonPublicationDate = null;
        public static Set<Date> PublicHolidaysFortheMonth = null;
        public static map<String,Publication__c> PublicationInformation = null;
        
        // Returns the map of Publication code and corresponding non publication dates
        public static void getNonPubDate(){
            Set<Date> tempDateList;
            NonPublicationDate = new map<String,Set<Date>>();
            for(Non_Publication_Day__c nonPubDay : [Select Publication_Code__c,Non_Publication_Date__c from Non_Publication_Day__c]){
                if(NonPublicationDate.containsKey(nonPubDay.Publication_Code__c)){
                    NonPublicationDate.get(nonPubDay.Publication_Code__c).add(nonPubDay.Non_Publication_Date__c);
                }else{
                    tempDateList = new Set<Date>();
                    tempDateList.add(nonPubDay.Non_Publication_Date__c);
                    NonPublicationDate.put(nonPubDay.Publication_Code__c,tempDateList);
                }
            }
        }
        // Returns a set of all the public holidays
        public static void getPublicHolidaysFortheMonth(){
            PublicHolidaysFortheMonth = new Set<Date>();
            for(Public_Holiday__c pubHol : [Select Holiday_Date__c from Public_Holiday__c]){
                PublicHolidaysFortheMonth.add(pubHol.Holiday_Date__c);
            }
        }   
        
        // Returns a map of Publication records
        public static void getPublicationInformation(){
            PublicationInformation = new map<String,Publication__c>();
            //START UD-2657 09/16/2015 Added by J.Sarion - Added Publication_Next_Start_Date__c
            for(Publication__c pubRec : [Select Publication_Code__c,Published_Days__c,Frequency_Code__c,Public_Holiday_Weekday_Pub_Indicator__c, Publication_Next_Start_Date__c,
                                                Public_Holiday_Weekend_Pub_Indicator__c,Earliest_Start_Date__c,Publication_Type__c,Platform_Type__c from Publication__c]){
                PublicationInformation.put(pubRec.Publication_Code__c,pubRec);
            }
            //END UD-2657 09/16/2015 Added by J.Sarion - Added Publication_Next_Start_Date__c
        }
        public static PublicationIssueWrapper IssueCalculation (String pubCode , Date StartDate, Date EndDate, Zuora__Subscription__c subsRecord, Integer quantity){

            // counter for number of issues on saturday
            integer satNumberOfCopies = 0;
            // counter for number of issues on sunday
            integer sunNumberOfCopies = 0;
            // counter for number of issues on a weekday
            integer weekdayNumberOfCopies = 0;
            integer interval = 0;
            // counter for number of issues for magazine subscriptions
            integer oddFreqCopies = 0;
            // temp variable to maintain current date
            Date currDate;
            Datetime dt;
            // temp variable to maintain current day of the week
            String dayOfWeek;
            Boolean applicableIssueDay;
            Boolean isNonPublicationDay = false;
            Boolean isPublicHoliday;
            String freq = '';
            //Start UD-0104 03/11/2015 JLedesma - Year To Date Temp Stop Calculation
            Integer currentYear = 0;
            Integer nextYear = 0;
            Integer satPrevious = 0;
            Integer weekdayPrevious = 0;
            Integer sunPrevious = 0;
            //START: UD-0309 03/20/2015 Year To Date computation
            Map<String,List<Map<Date, Map<String, Integer>>>> pubToDateIssue = new Map<String,List<Map<Date, Map<String, Integer>>>>();
            //END: UD-0309 03/20/2015 Year To Date computation
            //End UD-0104 03/11/2015 JLedesma - Year To Date Temp Stop Calculation
            
            //START UD-2657 09/12/2015 Added by J.Sarion - Update publish day logic
            Set<String> addDaysSet = new Set<String>{'D', 'W', 'F'};
            Date currDate2;
            
            //START UD-1156 and D-0077 15-June-2015 Added by Raviteja  - Implementing the Public_Holiday_Weekday_Pub_Indicator__c and Public_Holiday_Weekend_Pub_Indicator__c from custom settings
            Map<String,Public_Holiday_Pub_Indiators__c> pubholidayCodes = Public_Holiday_Pub_Indiators__c.getAll();  
            //End UD-1156 and D-0077 15-June-2015 Added by Raviteja
            
            if(PublicationInformation.containsKey(pubCode)){  
                Pattern pPublishedDays = Pattern.compile('((?=.*[YN]).{7,9})');
                Matcher mPublishedDays = pPublishedDays.matcher(PublicationInformation.get(pubCode).Published_Days__c);

                if(subsRecord.Frequency_1__c != null){
                    if(subsRecord.Frequency_1__c == GlobalVariableClass.FREQ_DEFAULT){
                        freq = PublicationInformation.get(pubCode).Published_Days__c;
                    }else if(subsRecord.Frequency_1__c == GlobalVariableClass.FREQ_MONFRI){
                        freq = GlobalVariableClass.FREQ_MONFRI_DAYS;
                    }else if(subsRecord.Frequency_1__c == GlobalVariableClass.FREQ_MONSAT){
                        freq = GlobalVariableClass.FREQ_MONSAT_DAYS;
                    }else if(subsRecord.Frequency_1__c == GlobalVariableClass.FREQ_SATSUN){
                        freq = GlobalVariableClass.FREQ_SATSUN_DAYS;
                    }else if(subsRecord.Frequency_1__c == GlobalVariableClass.FREQ_FRISUN){
                        freq = GlobalVariableClass.FREQ_FRISUN_DAYS;
                    }
                }
                
                if(PublicationInformation.get(pubCode).Frequency_Code__c == 'D'){
                    interval = 1;
                }else if(PublicationInformation.get(pubCode).Frequency_Code__c == 'W'){
                    interval = 7;
                }else if(PublicationInformation.get(pubCode).Frequency_Code__c == 'F'){
                    interval = 14;
                }
                else if(PublicationInformation.get(pubCode).Frequency_Code__c == 'M'){
                    interval = 1;
                }else if(PublicationInformation.get(pubCode).Frequency_Code__c == 'B'){
                    interval = 2;
                }else if(PublicationInformation.get(pubCode).Frequency_Code__c == 'Q'){
                    interval = 3;
                }else if(PublicationInformation.get(pubCode).Frequency_Code__c == 'H'){
                    interval = 6;
                }else if(PublicationInformation.get(pubCode).Frequency_Code__c == 'Y'){
                    interval = 12;
                }
                //START D-3703 05-Oct-2015 Added by S.Puli - avoid cpu timeout
                else{
                    //invalid data returning null
                    return null;
                }
                //END D-3703 05-Oct-2015 Added by S.Puli - avoid cpu timeout
                
                
                
                //START UD-2657 09/16/2015 Added by J.Sarion - Update publish day logic
                if(addDaysSet.contains(PublicationInformation.get(pubCode).Frequency_Code__c)){
                    currDate2 = PublicationInformation.get(pubCode).Publication_Next_Start_Date__c;
                    if(StartDate < currDate2){
                        while(StartDate < currDate2){
                            currDate2 = currDate2.addDays(-1*interval);
                        }
                        if(StartDate > currDate2){
                            currDate2 = currDate2.addDays(interval);
                        }
                        
                    }
                    else{
                        while(StartDate > currDate2){
                            currDate2 = currDate2.addDays(interval);
                        }
                    }
                    StartDate = currDate2;
                }
                else{
                    currDate2 = PublicationInformation.get(pubCode).Publication_Next_Start_Date__c;
                    if(StartDate < currDate2){
                        while(StartDate < currDate2){
                            currDate2 = currDate2.addMonths(-1*interval);
                        }
                        if(StartDate > currDate2){
                            currDate2 = currDate2.addMonths(interval);
                        }
                        
                    }
                    else{
                        while(StartDate > currDate2){
                            currDate2 = currDate2.addMonths(interval);
                        }
                    }
                    StartDate = currDate2;
                }
                //END UD-2657 09/16/2015 Added by J.Sarion - Update publish day logic
                
                Matcher mFreq = pPublishedDays.matcher(freq);
               
                if(mFreq.matches()){
                    //START UD-2657 09/16/2015 Added by J.Sarion - Update publish day logic
                    if(addDaysSet.contains(PublicationInformation.get(pubCode).Frequency_Code__c)){
                    //END UD-2657 09/16/2015 Added by J.Sarion - Update publish day logic
                        for(currDate = StartDate; currDate <= EndDate; currDate = currDate.addDays(interval)){                      
                            sunPrevious = sunNumberOfCopies;
                            satPrevious = satNumberOfCopies;
                            weekdayPrevious = weekdayNumberOfCopies;
                            //END UD-0104 03/11/2015 JLedesma - Year To Date Temp Stop Calculation
                            dt = DateTime.newInstance(currDate, Time.newInstance(0, 0, 0, 0));
                            dayOfWeek = dt.format('EEEE');
                            //START: UD-0085 3/20/2015 Total issue of computation
                            if(dayOfWeek == 'Monday' && freq.substring(0,1) == 'Y' && PublicationInformation.get(pubCode).Published_Days__c.substring(0,1) == 'Y'){
                                applicableIssueDay = true;
                            }else if(dayOfWeek == 'Tuesday' && freq.substring(1,2) == 'Y' && PublicationInformation.get(pubCode).Published_Days__c.substring(1,2) == 'Y'){
                                applicableIssueDay = true;
                            }else if(dayOfWeek == 'Wednesday' && freq.substring(2,3) == 'Y' && PublicationInformation.get(pubCode).Published_Days__c.substring(2,3) == 'Y'){
                                    applicableIssueDay = true;
                            }else if(dayOfWeek == 'Thursday' && freq.substring(3,4) == 'Y' && PublicationInformation.get(pubCode).Published_Days__c.substring(3,4) == 'Y'){
                                    applicableIssueDay = true;
                            }else if(dayOfWeek == 'Friday' && freq.substring(4,5) == 'Y' && PublicationInformation.get(pubCode).Published_Days__c.substring(4,5) == 'Y'){
                                    applicableIssueDay = true;
                            }else if(dayOfWeek == 'Saturday' && freq.substring(5,6) == 'Y' && PublicationInformation.get(pubCode).Published_Days__c.substring(5,6) == 'Y'){
                                    applicableIssueDay = true;
                            }else if(dayOfWeek == 'Sunday' && freq.substring(6,7) == 'Y' && PublicationInformation.get(pubCode).Published_Days__c.substring(6,7) == 'Y'){
                                    applicableIssueDay = true;
                            }else{
                                applicableIssueDay = false;
                            }
                            //END: UD-0085 3/20/2015 Total issue of computation
                            if(applicableIssueDay == true){ // check for applicable issue day
                                
                                //START UD-0620 3/26/2015 Added By C. Lin - add containsKey to check for pubcodes that are not in the map of NonPublicationDate. Need to compute copies for these.
                                if(NonPublicationDate.containsKey(pubCode)){
                                    //START D-2550 03-22-2015 Jerella Check non-pub date 
                                    if(NonPublicationDate.get(pubCode) != null && !NonPublicationDate.get(pubCode).contains(currDate)){ // is a publication day
                                        if(PublicHolidaysFortheMonth.contains(currDate)){
                                            isPublicHoliday = true;
                                        }else{
                                            isPublicHoliday = false;
                                        }
                                    //END D-2550 03-22-2015 Jerella Check non-pub date 
                                    }
                                    //START D-2443 04-09-2015 J.Sarion Check non-pub date 
                                    else {// is a non-publication day
                                        continue;
                                    }
                                    //END D-2443 04-09-2015 J.Sarion Check non-pub date 
                                } else{
                                    if(PublicHolidaysFortheMonth.contains(currDate)){
                                        isPublicHoliday = true;
                                    }else{
                                        isPublicHoliday = false;
                                    }
                                }
                                //END START UD-0620 3/26/2015 Added By C. Lin

                                    if(isPublicHoliday == true){ // is a public holiday
                                        if(dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday'){
                                            // PUBLIC HOLIDAY AND WEEKEND
                                           //START UD-1156 and D-0077 15-June-2015 Added by Raviteja  - Commented PublicationInformation.get(pubCode).Public_Holiday_Weekend_Pub_Indicator__c condition and getting value from custom settings                               
                                            //if(subsRecord.Order_Line_Item_Number_1__r.Ph_e__c ==true && PublicationInformation.get(pubCode).Public_Holiday_Weekend_Pub_Indicator__c == true){
                                            if(subsRecord.Order_Line_Item_Number_1__r.Ph_e__c ==true && pubholidayCodes.get('Pub Indicators').Weekend__c == true){
                                            //End UD-1156 and D-0077 15-June-2015 Added by Raviteja
                                                if(PublicationInformation.get(pubCode).Platform_Type__c != 'Print'){

                                                    oddFreqCopies = oddFreqCopies + 1;
                                                }else{
                                                    //issue weekend day
                                                    //START UD-2657 09/16/2015 Added by J.Sarion - Update publish day logic
                                                    if(PublicationInformation.get(pubCode).Publication_Type__c == 'N'){
                                                        if(dayOfWeek == 'Sunday'){
                                                            sunNumberOfCopies = sunNumberOfCopies + 1;
                                                        }else if(dayOfWeek == 'Saturday'){
                                                            satNumberOfCopies = satNumberOfCopies + 1;
                                                        }
                                                    }
                                                    else{
                                                        oddFreqCopies = oddFreqCopies + 1;
                                                    }
                                                    //END UD-2657 09/16/2015 Added by J.Sarion - Update publish day logic
                                                }
                                            }// else public holiday on weekend and not issue day
                                        }else{
                                            //PUBLIC HOLIDAY AND WEEKDAY
                                           //START UD-1156 and D-0077 15-June-2015 Added by Raviteja  - Commented PublicationInformation.get(pubCode).Public_Holiday_Weekday_Pub_Indicator__c condition and getting value from custom settings                                     
                                            //if(subsRecord.Order_Line_Item_Number_1__r.Ph_d__c ==true && PublicationInformation.get(pubCode).Public_Holiday_Weekday_Pub_Indicator__c == true){
                                            if(subsRecord.Order_Line_Item_Number_1__r.Ph_d__c ==true && pubholidayCodes.get('Pub Indicators').Weekday__c == true){
                                            //End UD-1156 and D-0077 15-June-2015 Added by Raviteja  
                                                if(PublicationInformation.get(pubCode).Platform_Type__c != 'Print'){
                                                    oddFreqCopies = oddFreqCopies + 1;
                                                }else{
                                                    //START UD-2657 09/16/2015 Added by J.Sarion - Update publish day logic
                                                    if(PublicationInformation.get(pubCode).Publication_Type__c == 'N'){
                                                        weekdayNumberOfCopies = weekdayNumberOfCopies + 1;
                                                    }
                                                    else{
                                                        oddFreqCopies = oddFreqCopies + 1;
                                                    }
                                                    //END UD-2657 09/16/2015 Added by J.Sarion - Update publish day logic
                                                }
                                            }// else public holiday on weekday not issue day
                                        }
                                    }else{// else not a public holiday but it is issue day
                                    //issue week day
                                        if(PublicationInformation.get(pubCode).Platform_Type__c != 'Print'){
                                            oddFreqCopies = oddFreqCopies + 1;
                                        }else{
                                            //START UD-2657 09/16/2015 Added by J.Sarion - Update publish day logic
                                            if(PublicationInformation.get(pubCode).Publication_Type__c == 'N'){
                                                if(dayOfWeek == 'Sunday'){
                                                    sunNumberOfCopies = sunNumberOfCopies + 1;
                                                }else if(dayOfWeek == 'Saturday'){
                                                    satNumberOfCopies = satNumberOfCopies + 1;
                                                }else{
                                                    weekdayNumberOfCopies = weekdayNumberOfCopies + 1;
                                                }
                                            }
                                            else{
                                                oddFreqCopies = oddFreqCopies + 1;
                                            }
                                            //END UD-2657 09/16/2015 Added by J.Sarion - Update publish day logic
                                        }
                                    }
                                //START UD-0620 3/26/2015 Added By C. Lin - Remove if condition
                                //} // else not issue day exit
                                //END UD-0620 3/26/2015 Added By C. Lin
                            }// else not issue day exit
                            //START UD-0104 03/11/2015 JLedesma - Year To Date Temp Stop Calculation
                            if(satNumberOfCopies > satPrevious || sunNumberOfCopies > sunPrevious || weekdayNumberOfCopies > weekdayPrevious){
                                if(currDate.year() == date.today().year())
                                {
                                    currentYear+=1;
                                }
                                else{
                                    nextYear+=1;
                                }
                            }
                            //END UD-0104 03/11/2015 JLedesma - Year To Date Temp Stop Calculation
                        }
                    }
                    //START UD-2657 09/16/2015 Added by J.Sarion - Update publish day logic
                    else{
                        for(currDate = StartDate; currDate <= EndDate; currDate = currDate.addMonths(interval)){                        
                            sunPrevious = sunNumberOfCopies;
                            satPrevious = satNumberOfCopies;
                            weekdayPrevious = weekdayNumberOfCopies;
                            //END UD-0104 03/11/2015 JLedesma - Year To Date Temp Stop Calculation
                            dt = DateTime.newInstance(currDate, Time.newInstance(0, 0, 0, 0));
                            dayOfWeek = dt.format('EEEE');
                            //START: UD-0085 3/20/2015 Total issue of computation
                            if(dayOfWeek == 'Monday' && freq.substring(0,1) == 'Y' && PublicationInformation.get(pubCode).Published_Days__c.substring(0,1) == 'Y'){
                                applicableIssueDay = true;
                            }else if(dayOfWeek == 'Tuesday' && freq.substring(1,2) == 'Y' && PublicationInformation.get(pubCode).Published_Days__c.substring(1,2) == 'Y'){
                                applicableIssueDay = true;
                            }else if(dayOfWeek == 'Wednesday' && freq.substring(2,3) == 'Y' && PublicationInformation.get(pubCode).Published_Days__c.substring(2,3) == 'Y'){
                                    applicableIssueDay = true;
                            }else if(dayOfWeek == 'Thursday' && freq.substring(3,4) == 'Y' && PublicationInformation.get(pubCode).Published_Days__c.substring(3,4) == 'Y'){
                                    applicableIssueDay = true;
                            }else if(dayOfWeek == 'Friday' && freq.substring(4,5) == 'Y' && PublicationInformation.get(pubCode).Published_Days__c.substring(4,5) == 'Y'){
                                    applicableIssueDay = true;
                            }else if(dayOfWeek == 'Saturday' && freq.substring(5,6) == 'Y' && PublicationInformation.get(pubCode).Published_Days__c.substring(5,6) == 'Y'){
                                    applicableIssueDay = true;
                            }else if(dayOfWeek == 'Sunday' && freq.substring(6,7) == 'Y' && PublicationInformation.get(pubCode).Published_Days__c.substring(6,7) == 'Y'){
                                    applicableIssueDay = true;
                            }else{
                                applicableIssueDay = false;
                            }
                            //END: UD-0085 3/20/2015 Total issue of computation
                            if(applicableIssueDay == true){ // check for applicable issue day
                                
                                //START UD-0620 3/26/2015 Added By C. Lin - add containsKey to check for pubcodes that are not in the map of NonPublicationDate. Need to compute copies for these.
                                if(NonPublicationDate.containsKey(pubCode)){
                                    //START D-2550 03-22-2015 Jerella Check non-pub date 
                                    if(NonPublicationDate.get(pubCode) != null && !NonPublicationDate.get(pubCode).contains(currDate)){ // is a publication day
                                        if(PublicHolidaysFortheMonth.contains(currDate)){
                                            isPublicHoliday = true;
                                        }else{
                                            isPublicHoliday = false;
                                        }
                                    //END D-2550 03-22-2015 Jerella Check non-pub date 
                                    }
                                    //START D-2443 04-09-2015 J.Sarion Check non-pub date 
                                    else {// is a non-publication day
                                        continue;
                                    }
                                    //END D-2443 04-09-2015 J.Sarion Check non-pub date 
                                } else{
                                    if(PublicHolidaysFortheMonth.contains(currDate)){
                                        isPublicHoliday = true;
                                    }else{
                                        isPublicHoliday = false;
                                    }
                                }
                                //END START UD-0620 3/26/2015 Added By C. Lin

                                    if(isPublicHoliday == true){ // is a public holiday
                                        if(dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday'){
                                            // PUBLIC HOLIDAY AND WEEKEND
                                           //START UD-1156 and D-0077 15-June-2015 Added by Raviteja  - Commented PublicationInformation.get(pubCode).Public_Holiday_Weekend_Pub_Indicator__c condition and getting value from custom settings                               
                                            //if(subsRecord.Order_Line_Item_Number_1__r.Ph_e__c ==true && PublicationInformation.get(pubCode).Public_Holiday_Weekend_Pub_Indicator__c == true){
                                            if(subsRecord.Order_Line_Item_Number_1__r.Ph_e__c ==true && pubholidayCodes.get('Pub Indicators').Weekend__c == true){
                                            //End UD-1156 and D-0077 15-June-2015 Added by Raviteja
                                                if(PublicationInformation.get(pubCode).Platform_Type__c != 'Print'){

                                                    oddFreqCopies = oddFreqCopies + 1;
                                                }else{
                                                    //START UD-2657 09/16/2015 Added by J.Sarion - Update publish day logic
                                                    if(PublicationInformation.get(pubCode).Publication_Type__c == 'N'){
                                                        //issue weekend day
                                                        if(dayOfWeek == 'Sunday'){
                                                            sunNumberOfCopies = sunNumberOfCopies + 1;
                                                        }else if(dayOfWeek == 'Saturday'){
                                                            satNumberOfCopies = satNumberOfCopies + 1;
                                                        }
                                                    }
                                                    else{
                                                        oddFreqCopies = oddFreqCopies + 1;
                                                    }
                                                    //END UD-2657 09/16/2015 Added by J.Sarion - Update publish day logic
                                                }
                                            }// else public holiday on weekend and not issue day
                                        }else{
                                            //PUBLIC HOLIDAY AND WEEKDAY
                                           //START UD-1156 and D-0077 15-June-2015 Added by Raviteja  - Commented PublicationInformation.get(pubCode).Public_Holiday_Weekday_Pub_Indicator__c condition and getting value from custom settings                                     
                                            //if(subsRecord.Order_Line_Item_Number_1__r.Ph_d__c ==true && PublicationInformation.get(pubCode).Public_Holiday_Weekday_Pub_Indicator__c == true){
                                            if(subsRecord.Order_Line_Item_Number_1__r.Ph_d__c ==true && pubholidayCodes.get('Pub Indicators').Weekday__c == true){
                                            //End UD-1156 and D-0077 15-June-2015 Added by Raviteja  
                                                if(PublicationInformation.get(pubCode).Platform_Type__c != 'Print'){
                                                    oddFreqCopies = oddFreqCopies + 1;
                                                }else{
                                                    //START UD-2657 09/16/2015 Added by J.Sarion - Update publish day logic
                                                    if(PublicationInformation.get(pubCode).Publication_Type__c == 'N'){
                                                        weekdayNumberOfCopies = weekdayNumberOfCopies + 1;
                                                    }
                                                    else{
                                                        oddFreqCopies = oddFreqCopies + 1;
                                                    }
                                                    //END UD-2657 09/16/2015 Added by J.Sarion - Update publish day logic
                                                }
                                            }// else public holiday on weekday not issue day
                                        }
                                    }else{// else not a public holiday but it is issue day
                                    //issue week day
                                        if(PublicationInformation.get(pubCode).Platform_Type__c != 'Print'){
                                            oddFreqCopies = oddFreqCopies + 1;
                                        }else{
                                            //START UD-2657 09/16/2015 Added by J.Sarion - Update publish day logic
                                            if(PublicationInformation.get(pubCode).Publication_Type__c == 'N'){
                                                if(dayOfWeek == 'Sunday'){
                                                    sunNumberOfCopies = sunNumberOfCopies + 1;
                                                }else if(dayOfWeek == 'Saturday'){
                                                    satNumberOfCopies = satNumberOfCopies + 1;
                                                }else{
                                                    weekdayNumberOfCopies = weekdayNumberOfCopies + 1;
                                                }
                                            }
                                            else{
                                                oddFreqCopies = oddFreqCopies + 1;
                                            }
                                            //END UD-2657 09/16/2015 Added by J.Sarion - Update publish day logic
                                        }
                                    }
                                //START UD-0620 3/26/2015 Added By C. Lin - Remove if condition
                                //} // else not issue day exit
                                //END UD-0620 3/26/2015 Added By C. Lin
                            }// else not issue day exit
                            //START UD-0104 03/11/2015 JLedesma - Year To Date Temp Stop Calculation
                            if(satNumberOfCopies > satPrevious || sunNumberOfCopies > sunPrevious || weekdayNumberOfCopies > weekdayPrevious){
                                if(currDate.year() == date.today().year())
                                {
                                    currentYear+=1;
                                }
                                else{
                                    nextYear+=1;
                                }
                            }
                            //END UD-0104 03/11/2015 JLedesma - Year To Date Temp Stop Calculation
                        }
                    }
                   
                    //END UD-2657 09/16/2015 Added by J.Sarion - Update publish day logic
                }
            }
            //END UD-2657 09/12/2015 Added by J.Sarion - Update published days logic
            //START UD-0104 03/11/2015 JLedesma - Year To Date Temp Stop Calculation
            PublicationIssueWrapper pubIssueWrapperObject = new PublicationIssueWrapper(pubCode,weekdayNumberOfCopies*quantity,satNumberOfCopies*quantity,sunNumberOfCopies*quantity,oddFreqCopies*quantity, currentYear, nextYear);
            //END UD-0104 03/11/2015 JLedesma - Year To Date Temp Stop Calculation
            return pubIssueWrapperObject;
        }
        //End : 2/3/2015 Joban - Code for Issue calculation
            
        /*
         * @description : object that will pass as parameter to generate the Usage
         */
        public class UsageParamWrapper {
            public set<string> subscriptionProductChargeUom;    // set of UOM where Usage will be created
            public string subscriptionName;                     // subscrption name
            public string billingAccountNumber;                 // billing account number
            public string frequency;                            // subscription frequency
            public date startDate;                              // date when the usage calculation starts
            public date endDate;                                // date when the usage calculation ends
            public boolean isPhd;                               // subscription Ph_d__c
            public boolean isPhe;                               // subscription Ph_e__c
            public integer subscriptionQuantity;                // subscription number of copies
        }
        
        /*
         * @description : method to generate the Usage
         * @param : subscriptionId_UsageParamWrapper map variable where subscription id is the key 
         *      and UsageParamWrapper object as its value
         * @return : list of generated Usages 
         */
        public static list<Usage__c> generateUsage(map<id, UsageParamWrapper> subscriptionId_UsageParamWrapper) {
        
            // start variables declaration
            map<string, Zuora__SubscriptionProductCharge__c> subIdUom_spc = new map<string, Zuora__SubscriptionProductCharge__c>();
            map<string, Usage__c> subIdUom_usage = new map<string, Usage__c>();
            map<date, set<string>> publicationDate_publicationCodeSet = new map<date, set<string>>();
            map<date, set<string>> nonpulibcationDate_publicationCodeSet = new map<date, set<string>>();
            map<string, set<id>> publicationCode_subscriptionIdSet = new map<string, set<id>>();
            map<string, set<string>> publicationCode_publishedDaySet = new map<string, set<string>>();
            map<string, integer> spcIdentifierKey_usageQuantityCounter = new map<string, integer>();
            list<Usage__c> generatedUsageList = new list<Usage__c>();
            list<date> coveredDates = new list<date>();
            set<id> validSubscriptionIdSet = new set<id>();
            set<string> tmpPublicationCodeSet = new set<string>();
            set<id> subscriptionIdSet = new set<id>();
            set<string> publicationCodeSet = new set<string>();
            set<date> holidayDates = new set<date>();
            set<string> coveredUomSet = new set<string>();
            set<string> tmpPubCodeSet;
            set<string> subscriptionPublishedDaySet = new set<string>();
            set<string> uomIssuedDays = new set<string>();
            Zuora__SubscriptionProductCharge__c subscriptionProductCharge = new Zuora__SubscriptionProductCharge__c();
            Usage__c usage = new Usage__c();
            UsageParamWrapper usageParamWrapperTmp = new UsageParamWrapper();
            date coveredDateStart;
            date coveredDateEnd;
            date coverDate;
            string spcIdentifierKey;
            string formattedPubDate;
            boolean isCreateUpdateUsage;
            integer usageQuantityCounter;
            integer multiplier;
            // end variables declaration
            
             //START UD-1156 and D-0077 15-June-2015 Added by Raviteja  - Implementing the Public_Holiday_Weekday_Pub_Indicator__c and Public_Holiday_Weekend_Pub_Indicator__c from custom settings
            Map<String,Public_Holiday_Pub_Indiators__c> pubholidayCodes = Public_Holiday_Pub_Indiators__c.getAll();  
            //End UD-1156 and D-0077 15-June-2015 Added by Raviteja
            
            // start retrieve the valid subscription ids and the dates from the paramater
            for (id subId : subscriptionId_UsageParamWrapper.keySet()) {
                UsageParamWrapper tmpWrapper = subscriptionId_UsageParamWrapper.get(subId);
                if (tmpWrapper != null) {
                    if (tmpWrapper.subscriptionProductChargeUom != null && tmpWrapper.startDate != null && tmpWrapper.endDate != null) {
                        if (tmpWrapper.subscriptionProductChargeUom.isEmpty() == false && tmpWrapper.startDate <= tmpWrapper.endDate) {
                            validSubscriptionIdSet.add(subId);
                            coveredUomSet.addAll(tmpWrapper.subscriptionProductChargeUom);
                            coveredDates.add(tmpWrapper.startDate);
                            coveredDates.add(tmpWrapper.endDate);
                        }
                    }
                }
            }
            // end retrieve the valid subscription ids and the dates from the paramater
            
            coveredDates.sort();    // sort the covered dates to get the starting and ending dates
            
            // start validate necessary details needed
            if (coveredDates.size() > 0) {
            
                coveredDateStart = coveredDates[0];
                coveredDateEnd = coveredDates[coveredDates.size() - 1];
                
                // start retrieve the related subscription product and charges as well as well as the publication code
                for (Zuora__SubscriptionProductCharge__c spc : [select Zuora__Subscription__c, Product_Code__c, Zuora__UOM__c, 
                        Zuora__ChargeNumber__c, PublicationCode__c from Zuora__SubscriptionProductCharge__c where Zuora__Subscription__c in :validSubscriptionIdSet  
                        and Zuora__UOM__c in :coveredUomSet]) {
                    
                    usageParamWrapperTmp = subscriptionId_UsageParamWrapper.get(spc.Zuora__Subscription__c);
                    if (usageParamWrapperTmp.subscriptionProductChargeUom.contains(spc.Zuora__UOM__c) == true 
                            && spc.PublicationCode__c != null && spc.Zuora__UOM__c != null && spc.Zuora__ChargeNumber__c != null) {
                        
                        if (usageParamWrapperTmp.subscriptionProductChargeUom.size() > 0) {
                            if (usageParamWrapperTmp.subscriptionProductChargeUom.contains(spc.Zuora__UOM__c) == true) {
                                
                                subscriptionIdSet = new set<id>();
                                
                                spcIdentifierKey = generateSpcIndentifierKey(string.valueOf(spc.Zuora__Subscription__c), spc.Zuora__UOM__c);
                                subIdUom_spc.put(spcIdentifierKey, spc);
                                publicationCodeSet.add(spc.PublicationCode__c);
                                
                                if (publicationCode_subscriptionIdSet.get(spc.PublicationCode__c) != null) {
                                    subscriptionIdSet.addAll(publicationCode_subscriptionIdSet.get(spc.PublicationCode__c));
                                }
                                
                                subscriptionIdSet.add(spc.Zuora__Subscription__c);
                                
                                publicationCode_subscriptionIdSet.put(spc.PublicationCode__c, subscriptionIdSet);
                                
                            }
                        }
                    }
                    
                }
                // end retrieve the related subscription product and charges as well as well as the publication code
                
                // start retrieve non publication dates
                for (Non_Publication_Day__c tmp : [select Publication_Code__c, Non_Publication_Date__c from Non_Publication_Day__c 
                        where Publication_Code__c in :publicationCodeSet and Non_Publication_Date__c >= :coveredDateStart 
                        and Non_Publication_Date__c <= :coveredDateEnd]) {
                
                    tmpPublicationCodeSet = new set<string>();
                    
                    if (nonpulibcationDate_publicationCodeSet.get(tmp.Non_Publication_Date__c) != null) {
                        tmpPublicationCodeSet.addAll(nonpulibcationDate_publicationCodeSet.get(tmp.Non_Publication_Date__c));
                    }
                    
                    if (tmp.Publication_Code__c != null) {
                        tmpPublicationCodeSet.add(tmp.Publication_Code__c);
                    }
                    
                    nonpulibcationDate_publicationCodeSet.put(tmp.Non_Publication_Date__c, tmpPublicationCodeSet);
                }
                // end retrieve non publication dates
            
                // start retrieve holiday dates
                for (Public_Holiday__c tmp : [select Holiday_Date__c from Public_Holiday__c where Holiday_Date__c >= :coveredDateStart 
                        and Holiday_Date__c <= :coveredDateEnd]) {
                    
                    holidayDates.add(tmp.Holiday_Date__c);
                }
                // end retrieve holiday dates
                
                // start retrieve publication published days
                publicationCode_publishedDaySet = retrievePublishedDays(publicationCodeSet);
                // end retrieve publication published days
                
                // start retrieve publication dates
                for (coverDate = coveredDateStart; coverDate <= coveredDateEnd; coverDate = coverDate.addDays(1)) {
                    tmpPubCodeSet = new set<string>();
                    for (string pubCode : publicationCode_publishedDaySet.keySet()) {
                        if (publicationCode_publishedDaySet.get(pubCode) != null) {
                            if (publicationCode_publishedDaySet.get(pubCode).contains(((datetime)coverDate).format(DAY_NAME_DATE_PATTERN))) {
                                if (nonpulibcationDate_publicationCodeSet.get(coverDate) != null) {
                                    if (nonpulibcationDate_publicationCodeSet.get(coverDate).contains(pubCode) == false) { // filter the unpublished publication
                                        if (publicationDate_publicationCodeSet.get(coverDate) != null) {
                                            tmpPubCodeSet.addAll(publicationDate_publicationCodeSet.get(coverDate));
                                        }
                                        tmpPubCodeSet.add(pubCode); 
                                        publicationDate_publicationCodeSet.put(coverDate, tmpPubCodeSet);
                                    }
                                } else {
                                    if (publicationDate_publicationCodeSet.get(coverDate) != null) {
                                        tmpPubCodeSet.addAll(publicationDate_publicationCodeSet.get(coverDate));
                                    }
                                    tmpPubCodeSet.add(pubCode); 
                                    publicationDate_publicationCodeSet.put(coverDate, tmpPubCodeSet);
                                    
                                    
                                }
                            }
                        }
                    }
                }
                // end retrieve publication dates
                
                // start calculation
                //publicationCode_subscriptionIdSet
                
                for (date pubDate : publicationDate_publicationCodeSet.keySet()) {
                    system.debug('pubDate>>>214'+pubDate);
                    for (string pubCode : publicationDate_publicationCodeSet.get(pubDate)) {
                        // start retrieve related subscriptions
                        for (string subId : publicationCode_subscriptionIdSet.get(pubCode)) {
                            // start retrieve subscription details
                            usageParamWrapperTmp = subscriptionId_UsageParamWrapper.get(subId);
                            if (pubDate >= usageParamWrapperTmp.startDate && pubDate <= usageParamWrapperTmp.endDate) {
                            
                                if (usageParamWrapperTmp.frequency == DEFAULT_SUBSCRIPTION_FREQUENCY) {
                                    subscriptionPublishedDaySet = publicationCode_publishedDaySet.get(pubCode);
                                } else if(ConstantsSLB.getOther(usageParamWrapperTmp.frequency) != null) {
                                    subscriptionPublishedDaySet.addAll(delimitedStrToList(ConstantsSLB.getOther(usageParamWrapperTmp.frequency), CSV_DELIMITER));
                                }
                             
                                if (subscriptionPublishedDaySet != null) {
                                    if (subscriptionPublishedDaySet.isEmpty() == false && publicationCode_publishedDaySet.get(pubCode) != null) {
                                        formattedPubDate = ((datetime)pubDate).format(DAY_NAME_DATE_PATTERN);
                                        if (subscriptionPublishedDaySet.contains(formattedPubDate)) {
                                            for (string uom : usageParamWrapperTmp.subscriptionProductChargeUom) {
                                                // start retrieve uom issue days from custom settings
                                                
                                                uomIssuedDays = getUomIssueDays(uom);
                                                if (uomIssuedDays != null) {
                                                    if (uomIssuedDays.contains(formattedPubDate) == true) {
                                                        
                                                        isCreateUpdateUsage = false;
                                                        
                                                        if (holidayDates.contains(pubDate) == true) {
                                                        system.debug('pubDate>>>242'+pubDate);
                                                        system.debug('holidayDates>>>'+holidayDates);
                                                            if (formattedPubDate == SATURDAY || formattedPubDate == SUNDAY) {
                                                                //START UD-1156 and D-0077 15-June-2015 Added by Raviteja  - Commented pub.Public_Holiday_Weekday_Pub_Indicator__c condition and getting value from custom settings
                                                                //if ( usageParamWrapperTmp.isPhe == true && pub.Public_Holiday_Weekday_Pub_Indicator__c) {
                                                                 if ( usageParamWrapperTmp.isPhe == true && pubholidayCodes.get('Pub Indicators').Weekday__c) {
                                                                //End UD-1156 and D-0077 15-June-2015 Added by Raviteja 
                                                                    isCreateUpdateUsage = true;
                                                                }
                                                            } else {
                                                                //START UD-1156 and D-0077 15-June-2015 Added by Raviteja  - Commented pub.Public_Holiday_Weekend_Pub_Indicator__c condition and getting value from custom settings
                                                                //if ( usageParamWrapperTmp.isPhd == true && pub.Public_Holiday_Weekend_Pub_Indicator__c) {
                                                                 if ( usageParamWrapperTmp.isPhd == true && pubholidayCodes.get('Pub Indicators').Weekend__c) {
                                                                //End UD-1156 and D-0077 15-June-2015 Added by Raviteja  
                                                                    isCreateUpdateUsage = true;
                                                                }
                                                            }
                                                        } else {
                                                            isCreateUpdateUsage = true;
                                                        }
                                                        
                                                        if (isCreateUpdateUsage == true) {
                                                            system.debug('pubDate>>>'+pubDate);
                                                            spcIdentifierKey = generateSpcIndentifierKey(subId, uom); 
                                                            subscriptionProductCharge = subIdUom_spc.get(spcIdentifierKey);
                                                            usage = new Usage__c();
                                                            
                                                            if (subscriptionProductCharge != null) {
                                                                
                                                                multiplier = 1;
                                                                
                                                                if (usageParamWrapperTmp.subscriptionQuantity != null) {
                                                                    multiplier = usageParamWrapperTmp.subscriptionQuantity;
                                                                }
                                                                
                                                                if (subIdUom_usage.get(spcIdentifierKey) != null) {
                                                                    
                                                                    usageQuantityCounter = spcIdentifierKey_usageQuantityCounter.get(spcIdentifierKey) + 1;
                                                                    usage = subIdUom_usage.get(spcIdentifierKey);
                                                                    usage.Quantity__c = usageQuantityCounter * multiplier;
                                                                    
                                                                } else {
                                                                    
                                                                    usageQuantityCounter = 1;
                                                                    usage.Account_Id__c = usageParamWrapperTmp.billingAccountNumber;
                                                                    usage.Subscription_Id__c = usageParamWrapperTmp.subscriptionName;
                                                                    usage.Start_Date__c = usageParamWrapperTmp.startDate;
                                                                    usage.End_Date__c = usageParamWrapperTmp.endDate;
                                                                    usage.UOM__c = subscriptionProductCharge.Zuora__UOM__c;
                                                                    usage.Rate_Plan_Charge_Id__c = subscriptionProductCharge.Zuora__ChargeNumber__c;
                                                                    usage.Publication_Code__c = subscriptionProductCharge.PublicationCode__c; //START/END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier
                                                                    usage.Status__c = USAGE_STATUS;
                                                                    usage.Quantity__c = 1 * multiplier;
                                                                            usage.Usage_Type__c = USAGE_TYPE_NONDELIVERY; //START/END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only                                                        
                                                                }
                                                                
                                                                spcIdentifierKey_usageQuantityCounter.put(spcIdentifierKey, usageQuantityCounter);
                                                                subIdUom_usage.put(spcIdentifierKey, usage);
                                                                
                                                            }
                                                        }
                                                    }
                                                }
                                                // end retrieve uom issue days from custom settings
                                            }
                                        }
                                    }
                                }
                            }
                            // end retrieve subscription details
                        }
                        // end retrieve related subscriptions
                    }
                }
                // end calculation
            }
            // end validate necessary details needed
            
            if (subIdUom_usage.isEmpty() == false) {
                generatedUsageList = subIdUom_usage.values();
            }
            
            return generatedUsageList;
        }

        
        /*
         * @description : method to send the usage to zuora
         * @param : set of usage ids
         * @return : reponse from the callout request 
         */
         //START 04/01/2015 D-2686 Kevin Evasco - Only non future methods can be called in batchable's execute method
         //START 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only 
        @future(callout=true) //START/END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only        
        public static void sendToZuoraCallOut(set<id> usageIdSet) { 
            sentToZuoraCalloutNonFuture(usageIdSet);
        }
        
        // Start UD-1544 Marvin/John 05Jul15
        public static boolean isByPassUsageUpdateInSFDC = false;
        public static list<Usage__c> usageListForUpdateInSFDC;
        // End UD-1544 Marvin/John 05Jul15
        public static void sentToZuoraCalloutNonFuture(set<id> usageIdSet) {
        //END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only    
        //END 04/01/2015 D-2686 Kevin Evasco - Only non future methods can be called in batchable's execute method
            list<map<string, string>> response = new list<map<string, string>>();
            ZuoraCallOut UsageCallOut = new ZuoraCallOut();
            list<map<string, object>> requestParam_requestValue_list = new list<map<string, object>>();
            list<map<string, object>> requestParam_requestValue_batchOfMax = new list<map<string, object>>();
            list<Usage__c> usageList = new list<Usage__c>();
            map<string, object> requestParam_requestValue;
            integer index = 0;
            integer currentBatchIndex = 0;
            integer counter = 0;
            integer batchOfMax = 0;
            integer j = 0;
            
            // Start D-2826 08May15 Von/JohnD - added request field "StopType__c"
            for (Usage__c usage : [select Id, Account_Id__c, Subscription_Id__c, UOM__c, Quantity__c, Start_Date__c, StopType__c, 
                            Zuora_Id__c, Send_to_Zuora_Error_Message__c, Send_to_Zuora_Time__c, Rate_Plan_Charge_Id__c, Case__c 
                            from Usage__c where Id in :usageIdSet]) {    // Start/End D-4470 08Apr16 JohnD - added Case__c field
            // End D-2826 08May15 Von/JohnD - added request field "StopType__c"

                requestParam_requestValue = new map<string, object>();
                requestParam_requestValue.put(REQUEST_FIELD_SUBSCRIPTION_NUMBER, usage.Subscription_Id__c);
                requestParam_requestValue.put(REQUEST_FIELD_ACCOUNT_NUMBER, usage.Account_Id__c);
                requestParam_requestValue.put(REQUEST_FIELD_UOM, usage.UOM__c);
                requestParam_requestValue.put(REQUEST_FIELD_QUANTITY, usage.Quantity__c);
                        requestParam_requestValue.put(REQUEST_FIELD_CHARGE_NUMBER, usage.Rate_Plan_Charge_Id__c); //START/END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only    
                // Start D-2826 08May15 Von/JohnD - added request field
                if (usage.StopType__c != '' && usage.StopType__c != null) {
                    requestParam_requestValue.put(UsageHelper.REQUEST_FIELD_STOP_TYPE, usage.StopType__c);
                }
                // End D-2826 08May15 Von/JohnD - added request field
                
                if (usage.Start_Date__c != null) {
                    requestParam_requestValue.put(REQUEST_FIELD_START_DATE_TIME, zuora.zUtil.getZuoraDate(usage.Start_Date__c));
                    //START D-3187 13-July-2015 Added By S.Puli - Remove logic that deducts 1 day if Start date is end of month
                    /**
                    if (date.daysInMonth(usage.Start_Date__c.year(), usage.Start_Date__c.month()) == usage.Start_Date__c.day()) {
                        requestParam_requestValue.put(REQUEST_FIELD_START_DATE_TIME, zuora.zUtil.getZuoraDate(usage.Start_Date__c.addDays(-1)));
                    }
                    **/
                    //END D-3187 13-July-2015 Added By S.Puli
                }
                
                requestParam_requestValue_list.add(requestParam_requestValue);
                usageList.add(usage);
            }
            
            
                //
            
            if (usageList.isEmpty() == false && requestParam_requestValue_list.isEmpty() == false) {
                
                for (counter = 0; counter < requestParam_requestValue_list.size(); counter++) {
                    
                    currentBatchIndex = (batchOfMax * REQUEST_MAX_USAGE);       
                    requestParam_requestValue_batchOfMax.add(requestParam_requestValue_list[counter]);
                    
                    if (math.mod(counter + 1, REQUEST_MAX_USAGE) == 0 || counter == (requestParam_requestValue_list.size() - 1)) {
                        
                        index = currentBatchIndex;
                        
                        for (map<string, string> result : UsageCallOut.loadZObjects(requestParam_requestValue_batchOfMax, REQUEST_TYPE)) {
                            
                            if (usageList[index] != null) {
                            
                                usageList[index].Status__c = result.get(RESPONSE_FIELD_STATUS);
                                usageList[index].Send_to_Zuora_Time__c = datetime.now();
                                usageList[index].Send_to_Zuora_Error_Message__c = null;
                                
                                if (result.get(RESPONSE_FIELD_ID) != null) {
                                    usageList[index].Zuora_Id__c = result.get(RESPONSE_FIELD_ID);
                                } else if (result.get(RESPONSE_FIELD_MESSAGE) != null) {
                                    usageList[index].Send_to_Zuora_Error_Message__c = result.get(RESPONSE_FIELD_MESSAGE);
                                }
                            }
                            
                            response.add(result);
                            index++;
                        }
                        
                        requestParam_requestValue_batchOfMax = new list<map<string, object>>();
                        batchOfMax++;                   
                    }
                }
                
                // Start UD-1544 Marvin/John 05Jul15
                if (isByPassUsageUpdateInSFDC == true) {
                    usageListForUpdateInSFDC = usageList;
                } else {
                    try {
                        
                        Database.update(usageList,false);  //START/END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only               
                    } catch (exception e) {
                        ExceptionLogger.log(new list<exception> { e });
                    }
                }
                // End UD-1544 Marvin/John 05Jul15
            }
        }   


        /*
         * @description : method to send the usage to zuora asynchronously
         * @param : set of usage ids
         * @return : none 
         */
        @future(callout = true)
        public static void sendToZuoraFutureCallOut(set<id> usageIdSet) {
            sendToZuoraFutureCallOut(usageIdSet);
        }

        
        /************************ start miscelaneous methods ************************/
        /*
         * @description : this method is use to check the specified char on the published_days__c from publication
         * @param : yn - value can be Y or N
         * @param : expectedDayName - name of day (i.e. Monday, Tuesday, Wednesday, ...)
         * @return : if yn is Y, return the expectedDayName
         */
        private static string getDayName(string yn, string expectedDayName) {
            
            string returnValue;
            if (yn.toLowerCase() == PUBLISHED_DAY_YES.toLowerCase()) {
                returnValue = expectedDayName;
            }
            return returnValue;
        }
        
        /*
         * @description : this method is use to retrieve the days applicable defined on the published_days__c from publication
         * @param : pubCodeSet - set of publication codes
         * @return : map where publication code is the key and set of days as its values
         */
        private static map<string, set<string>> retrievePublishedDays(set<string> pubCodeSet) {
        
            map<string, set<string>> returnValue = new map<string, set<string>>();
        
            set<string> publishedDaySet = new set<string>();
            list<string> daySet = new list<string>{ MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY };
            integer i = 0;
            string tmpDayName;
            
            for (Publication__c tmp : [select Publication_Code__c, Published_Days__c from Publication__c where Publication_Code__c in : pubCodeSet]) {
                
                publishedDaySet = new set<string>();
                if (tmp.Publication_Code__c != null) {
                    if (tmp.Published_Days__c.length() == 7) {
                        
                        for (i = 0; i < 7; i++) {
                            tmpDayName = getDayName(tmp.Published_Days__c.substring(i, i + 1), daySet[i]);
                            if (tmpDayName != null) {
                                publishedDaySet.add(tmpDayName);
                            }
                        }
                    }
                }
        
                returnValue.put(tmp.Publication_Code__c, publishedDaySet);
            }
        
            return returnValue;
        }
        
        /*
         * @description : this method is use to generate a unique key to be used in a map variable for usage quantity incrementation
         * @param : subscriptionId - id of subscription
         * @param : uom - Unit of Measure
         * @return : concatenation of subscription id and Unit of Measure
         */
        private static string generateSpcIndentifierKey(string subscriptionId, string uom) {
            return subscriptionId + uom;
        }
        
        
        /*
         * @description : this method is use to get the defined days from custom settings
         * @param : subscriptionFrequency - frequency of the subscription
         * @return : set of days
         */
        private static set<string> getUomIssueDays(string subscriptionFrequency) {
            
            set<string> uomIsseDaySet = new set<string>();
            
            Unit_of_Measure__c uom = Unit_of_Measure__c.getInstance(subscriptionFrequency); 
            if (uom != null) {
                if (uom.Issue_Days__c != null) {
                    uomIsseDaySet.addAll(delimitedStrToList(uom.Issue_Days__c, CSV_DELIMITER));
                }
            }
                
            return uomIsseDaySet;
        }
        
        
        /*
         * @description : this method is use to convert the given string into list
         * @param : strToConvert - string to convert with delimited character
         * @param : delimiter - character to p
         * @return : set of days
         */
        private static list<string> delimitedStrToList(string strToConvert, string delimiter) {
            list<string> convertedStr = new list<string>();
            if (strToConvert != null && delimiter != null) {
                for (string s : strToConvert.split(delimiter)) {
                    convertedStr.add(s.trim());
                }
            }
            return convertedStr;
        }
        
        /************************ end miscelaneous methods ************************/
        
        // START 03/30/2015 D-2606 Kevin Evasco - New Utility Methods
        /*
        * @description : method to send the usage to zuora
        * @author: John Dacutan
        * @param : list of new usage (not yet created)
        * @return : none 
        */ 
        public static void sendToZuoraCallOut(list<Usage__c> usageListParam) {

            list<map<string, string>> response = new list<map<string, string>>();
            ZuoraCallOut UsageCallOut = new ZuoraCallOut();
            list<map<string, object>> requestParam_requestValue_list = new list<map<string, object>>();
            list<map<string, object>> requestParam_requestValue_batchOfMax = new list<map<string, object>>();
            list<Usage__c> usageList = new list<Usage__c>();
            map<string, object> requestParam_requestValue;
            integer index = 0; 
            integer currentBatchIndex = 0;
            integer counter = 0;
            integer batchOfMax = 0;
            integer j = 0;
            

            
            for (Usage__c usage : usageListParam) {

                requestParam_requestValue = new map<string, object>();
                requestParam_requestValue.put(UsageHelper.REQUEST_FIELD_SUBSCRIPTION_NUMBER, usage.Subscription_Id__c);
                requestParam_requestValue.put(UsageHelper.REQUEST_FIELD_ACCOUNT_NUMBER, usage.Account_Id__c);
                requestParam_requestValue.put(UsageHelper.REQUEST_FIELD_UOM, usage.UOM__c);
                requestParam_requestValue.put(UsageHelper.REQUEST_FIELD_QUANTITY, usage.Quantity__c);
                requestParam_requestValue.put(REQUEST_FIELD_CHARGE_NUMBER, usage.Rate_Plan_Charge_Id__c);
                // Start D-2826 08May15 Von/JohnD - added request field
                if (usage.StopType__c != '' && usage.StopType__c != null) {
                    requestParam_requestValue.put(UsageHelper.REQUEST_FIELD_STOP_TYPE, usage.StopType__c);
                }
                // End D-2826 08May15 Von/JohnD - added request field
                
                if (usage.Start_Date__c != null) {
                    requestParam_requestValue.put(UsageHelper.REQUEST_FIELD_START_DATE_TIME, zuora.zUtil.getZuoraDate(usage.Start_Date__c));
                //START: D-3067 6-24-2015 K. Tan - To removed line of codes that decreases the usage start date by 1 day for Full Prepaid - Start date of the Subscription is End of the month.
                  /*  if (date.daysInMonth(usage.Start_Date__c.year(), usage.Start_Date__c.month()) == usage.Start_Date__c.day()) {
                        requestParam_requestValue.put(UsageHelper.REQUEST_FIELD_START_DATE_TIME, zuora.zUtil.getZuoraDate(usage.Start_Date__c.addDays(-1)));
                    }*/
                }
                //END: D-3067 6-24-2015 K. Tan - To removed line of codes that decreases the usage start date by 1 day for Full Prepaid - Start date of the Subscription is End of the month.            
                requestParam_requestValue_list.add(requestParam_requestValue);
                usageList.add(usage);
            }


                        //
            

            
            
            
            
            
            
            if (usageList.isEmpty() == false && requestParam_requestValue_list.isEmpty() == false) {
                
                for (counter = 0; counter < requestParam_requestValue_list.size(); counter++) {
                    
                    currentBatchIndex = (batchOfMax * UsageHelper.REQUEST_MAX_USAGE);       
                    requestParam_requestValue_batchOfMax.add(requestParam_requestValue_list[counter]);
                    
                    if (math.mod(counter + 1, UsageHelper.REQUEST_MAX_USAGE) == 0 || counter == (requestParam_requestValue_list.size() - 1)) {
                                
                            index = currentBatchIndex;
                                
                            for (map<string, string> result : UsageCallOut.loadZObjects(requestParam_requestValue_batchOfMax, UsageHelper.REQUEST_TYPE)) {                  
                                if (usageList[index] != null) {
                                
                                    usageList[index].Status__c = result.get(UsageHelper.RESPONSE_FIELD_STATUS);
                                    usageList[index].Send_to_Zuora_Time__c = datetime.now();
                                    usageList[index].Send_to_Zuora_Error_Message__c = null;
                                    
                                    if (result.get(UsageHelper.RESPONSE_FIELD_ID) != null) {
                                        usageList[index].Zuora_Id__c = result.get(UsageHelper.RESPONSE_FIELD_ID);
                                    } else if (result.get(UsageHelper.RESPONSE_FIELD_MESSAGE) != null) {
                                        usageList[index].Send_to_Zuora_Error_Message__c = result.get(UsageHelper.RESPONSE_FIELD_MESSAGE);
                                    }
                                }
                                
                                response.add(result);
                                index++;
                            }
                            
                            
                            requestParam_requestValue_batchOfMax = new list<map<string, object>>();
                            batchOfMax++;
                        }
                        }
                    
                try {
                        Database.insert(usageList,false);
                        
                            } catch (exception e) {
                                ExceptionLogger.log(new list<exception> { e });
                        }
                    }
                }
        
        
        public static Date getUsageReferenceDate() {
            Date referenceDate = null;
            try{
                referenceDate = Date_Configuration__c.getInstance('Usage Reference Date').Date__c;
            }catch(Exception e) {
                System.debug('Usage Reference Date is not existing.');
                referenceDate = Date.today();
            }
            
            return referenceDate;
        }   
        // END 03/30/2015 D-2606 Kevin Evasco - New Utility Methods
        
        // START 03/27/2015 D-2610 Kevin Evasco - New Utility Methods           
        public static List<Usage__c> filterAndUpdateUniqueUsages(List<Usage__c> usageListParam, Boolean populateChargeNumber) {
            List<Usage__c> newUsagesList = filterNewUsages(usageListParam);
            
            if(populateChargeNumber == true) {
                Map<String,Zuora__SubscriptionProductCharge__c> spcMap = generateSPCMap(usageListParam);
                System.debug(spcMap);
                updateChargeNumberForUsageList(newUsagesList, spcMap);
            }
            
            return newUsagesList;
        }
        
        public static void loadUniqueUsages(List<Usage__c> usageListParam, Boolean populateChargeNumber) {
            List<Usage__c> newUsagesList = filterNewUsages(usageListParam);
            
            //START 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier
            //if(populateChargeNumber == true) {
            Map<String,Zuora__SubscriptionProductCharge__c> spcMap = generateSPCMap(usageListParam);
            System.debug(spcMap);
            updateChargeNumberForUsageList(newUsagesList, spcMap);
            //}
            //END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier
            
            sendToZuoraCallOut(newUsagesList);
        }
        
        public static void insertUniqueUsages(List<Usage__c> usageListParam) {
            List<Usage__c> newUsagesList = filterNewUsages(usageListParam);
            
            if(newUsagesList.size() > 0)
                Database.insert(newUsagesList, false);
        }

        public static List<Usage__c> filterNewUsages(List<Usage__c> usageListParam) {
        
            //START 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier
            for(Usage__c usageElement : usageListParam) {
                usageElement.Unique_Identifier__c = constructPrimaryKey(usageElement);
            }
            //END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier
            List<Usage__c> existingUsagesList = getExistingUsages(usageListParam);
            Set<String> existingUsagesPrimaryKeySet = getPrimaryKeys(existingUsagesList);
            
            List<Usage__c> newUsagesList = new List<Usage__c>();
            System.debug('existingUsagesPrimaryKeySet' + existingUsagesPrimaryKeySet);
            for(Usage__c usageElement : usageListParam) {
                String usageElementPrimaryKey = constructPrimaryKey(usageElement);
                if(!existingUsagesPrimaryKeySet.contains(usageElementPrimaryKey)) {
            // REMOVED FOR D-2698 if(isValidUOM(usageElement)) { // START/END 04/07/2015 D-2698 Kevin Evasco - BatchPostageMonthlyUsage fix
                        newUsagesList.add(usageElement);
            // REMOVED FOR D-2698 } // START/END 04/07/2015 D-2698 Kevin Evasco - BatchPostageMonthlyUsage fix
                    existingUsagesPrimaryKeySet.add(usageElementPrimaryKey);
                }
            }
            
            return newUsagesList;
        }
        
        public static Boolean isValidUOM(Usage__c usageRecordParam) {
            Boolean result = true;
            
            if(usageRecordParam.Account_Id__c == null) {
                result = false;
            } else if (usageRecordParam.Subscription_Id__c == null) {
                result = false;
            } else if (usageRecordParam.UOM__c == null) {
                result = false;
            } else if (usageRecordParam.Quantity__c == null) {
                result = false;
            } else if (usageRecordParam.Rate_Plan_Charge_Id__c == null) {
                result = false;
            } else if (usageRecordParam.Start_Date__c == null) {
                result = false;
            }
            
            if(result == false) {
                System.debug('Invalid Usage Record. Required Fields are missing. Usage: ' + usageRecordParam);
            }
            
            return result;
        }

        public static List<Usage__c> getExistingUsages(List<Usage__c> usageListParam) {
            Set<String> primaryKeySet = getPrimaryKeys(usageListParam);
            List<Usage__c> existingUsagesList = queryUsages(primaryKeySet);
            
            return existingUsagesList;
        }

        public static Set<String> getPrimaryKeys(List<Usage__c> usageListParam) {
            Set<String> primaryKeySet = new Set<String>();
            
            for(Usage__c usageElement : usageListParam) {
                String primaryKey = constructPrimaryKey(usageElement);
                if(primaryKey != null) {
                    primaryKeySet.add(primaryKey);
                }
            }
            
            return primaryKeySet;
        }

        public static List<Usage__c> queryUsages(Set<String> primaryKeySetParam) {
            // Start D-4470 08Apr16 JohnD - added Case__c field
            List<Usage__c> usageList = [SELECT Id, Subscription_Id__c, Usage_Type__c, UOM__c, StopType__c, Start_Date__c, 
                Unique_Identifier__c, Publication_Code__c, Case__c FROM Usage__c 
                WHERE Unique_Identifier__c IN :primaryKeySetParam]; //START 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier
            // End D-4470 08Apr16 JohnD - added Case__c field
            
            return usageList;
        }

        public static String constructPrimaryKey(Usage__c usageRecordParam) {
            String primaryKey = '';
            primaryKey += usageRecordParam.Subscription_Id__c + '_';
            primaryKey += usageRecordParam.Usage_Type__c + '_';
            primaryKey += usageRecordParam.Publication_Code__c + '_'; //START/END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier
            primaryKey += usageRecordParam.UOM__c + '_';
            primaryKey += usageRecordParam.StopType__c + '_';
            if(usageRecordParam.Start_Date__c != null){
                primaryKey += String.valueOf(usageRecordParam.Start_Date__c).subString(0,10);
            } else {
                primaryKey += 'null';
            }
            
            system.debug('Johnxxxx :: ' + usageRecordParam);
            // Start D-4470 02Apr16 JohnD - added case id. this will allow to create multiple usages
            // for multiple complaints or other case transactions, if applicable.
            if (usageRecordParam.Case__c != null) { 
                primaryKey += usageRecordParam.Case__c;
            }
            // End D-4470 02Apr16 JohnD - added case id.
            
            return primaryKey;
        }
        
        public static String constructPrimaryKey(Map<String,Object> usageMapParam, String usageTypeParam) {
            String primaryKey = '';
            primaryKey += String.valueOf(usageMapParam.get(REQUEST_FIELD_SUBSCRIPTION_NUMBER)) + '_';
            primaryKey += usageTypeParam + '_';
            primaryKey += String.valueOf(usageMapParam.get(REQUEST_FIELD_UOM)) + '_';
            primaryKey += String.valueOf(usageMapParam.get(REQUEST_FIELD_STOP_TYPE)) + '_';
            if(usageMapParam.get(REQUEST_FIELD_START_DATE_TIME) != null){
                primaryKey += String.valueOf((usageMapParam.get(REQUEST_FIELD_START_DATE_TIME))).subString(0,10);
            } else {
                primaryKey += 'null';
            }
            
            return primaryKey;
        }   

        public static List<Map<String,String>> loadUsage(List<Map<String, Object>> usageMapListParam) {
            List<Map<String,String>> result = new List<Map<String,String>>();       
            List<Map<String, Object>> usageMapListTemp = new List<Map<String, Object>>();
            ZuoraCallOut zCallOut = new ZuoraCallOut();
            
            integer counter = 0;
            for(Map<String, Object> usageMap : usageMapListParam) {
                usageMapListTemp.add(usageMap);
                if(Math.mod(counter,REQUEST_MAX_USAGE) == 0 || counter == usageMapListParam.size()-1) {
                    result.addAll(zCallOut.loadZObjects(usageMapListTemp, 'Usage'));
                    usageMapListTemp = new List<Map<String, Object>>();
                }
                counter++;
            }
            
            return result;
        }
        
        public static Map<String,Boolean> getUsageLoadSucessMap(List<Map<String, Object>> usageMapListParam, List<Map<String,String>> resultsParam, String usageTypeParam) {
            Map<String,Boolean> primaryKey_SuccessFlag_map = new Map<String,Boolean>();
            Integer counter = 0;
            for (Map<String,String> resultMap : resultsParam) {
                Map<String, Object> usageMap = usageMapListParam.get(0);
                String primaryKey = constructPrimaryKey(usageMap, usageTypeParam);
                system.debug('resultMap: ' + resultMap);
                if (resultMap.get('Status') == 'Success') {
                    primaryKey_SuccessFlag_map.put(primaryKey,true);
                }
                else {              
                    primaryKey_SuccessFlag_map.put(primaryKey,false);
                }
                counter++;
            }
            
            return primaryKey_SuccessFlag_map;
        }
        
        public static void updateUsageStatus(Map<String,Boolean> primaryKey_SuccessFlag_mapParam) {
            List<Usage__c> usageList = queryUsages(primaryKey_SuccessFlag_mapParam.keySet());
            
            for(Usage__c usageElement : usageList) {
                String primaryKey = constructPrimaryKey(usageElement);
                Boolean successFlag = primaryKey_SuccessFlag_mapParam.get(primaryKey);
                if(successFlag == true) {
                    usageElement.Status__c = USAGE_STATUS_SUCCESS;
                } else if(successFlag == false) {
                    usageElement.Status__c = USAGE_STATUS_FAILED;
                }
            }
            
            Database.update(usageList, false);
        }
        
        public static void insertUniqueUsages(List<Usage__c> usageListParam, Map<String,Boolean> primaryKey_SuccessFlag_mapParam) {         
            for(Usage__c usageElement : usageListParam) {
                String primaryKey = constructPrimaryKey(usageElement);
                Boolean successFlag = primaryKey_SuccessFlag_mapParam.get(primaryKey);
                
                if(successFlag == true) {
                    usageElement.Status__c = USAGE_STATUS_SUCCESS;
                } else if(successFlag == false) {
                    usageElement.Status__c = USAGE_STATUS_FAILED;
                }
            }
            
            Database.insert(usageListParam, false);
        }
        
        public static Usage__c createUsage(Map<String,Object> usageMapParam, Zuora__Subscription__c subscriptionParam, Date startDateParam, String usageTypeparam) {
            Usage__c usageRecord = new Usage__c();
            
            if(usageMapParam.get(REQUEST_FIELD_ACCOUNT_NUMBER) != null) {
                usageRecord.Account_Id__c = String.valueOf(usageMapParam.get(REQUEST_FIELD_ACCOUNT_NUMBER));    
            }       
            if(usageMapParam.get(REQUEST_FIELD_SUBSCRIPTION_NUMBER) != null) {
                usageRecord.Subscription_Id__c = String.valueOf(usageMapParam.get(REQUEST_FIELD_SUBSCRIPTION_NUMBER));
            }
            if(usageMapParam.get(REQUEST_FIELD_UOM) != null) {
                usageRecord.UOM__c = String.valueOf(usageMapParam.get(REQUEST_FIELD_UOM));
            }
            if(usageMapParam.get(REQUEST_FIELD_CHARGE_NUMBER) != null) {
                usageRecord.Rate_Plan_Charge_Id__c = String.valueOf(usageMapParam.get(REQUEST_FIELD_CHARGE_NUMBER));  
            }        
            if(usageMapParam.get(REQUEST_FIELD_QUANTITY) != null) {
                usageRecord.Quantity__c = Integer.valueOf(usageMapParam.get(REQUEST_FIELD_QUANTITY));
            }
            usageRecord.Usage_Type__c = usageTypeparam;
            usageRecord.Start_Date__c = startDateParam;
            usageRecord.Status__c = USAGE_STATUS;
            
            Date endDate;
            Integer year = date.today().year();
            Integer month = date.today().month();       
            if (subscriptionParam.Zuora__TermSettingType__c != 'EVERGREEN') {
                if (subscriptionParam.Zuora__SubscriptionEndDate__c.monthsBetween(date.today()) == 0 || subscriptionParam.Grace_Period_Subscription__c != null) {
                    endDate = subscriptionParam.Zuora__SubscriptionEndDate__c;
                } else {
                    endDate = date.newInstance(year, month, Date.daysInMonth(year, month));
                }
            } else {
                endDate = date.newInstance(year, month, Date.daysInMonth(year, month));
            }       
            usageRecord.End_Date__c = endDate;
            
            return usageRecord;
        }
        
        public static Map<String,Zuora__SubscriptionProductCharge__c> generateSPCMap(List<Usage__c> usageListParam) {
            Map<String,Zuora__SubscriptionProductCharge__c> spcMap = new Map<String,Zuora__SubscriptionProductCharge__c>();
            Map<String,Set<String>> spcKeySetMap = generateSPCKeySetMap(usageListParam);
            Set<String> subscriptionNumberSet = spcKeySetMap.get(REQUEST_FIELD_SUBSCRIPTION_NUMBER);
            Set<String> uomSet = spcKeySetMap.get(REQUEST_FIELD_UOM);
            List<Zuora__SubscriptionProductCharge__c> spcList = getSPCList(subscriptionNumberSet, uomSet);
            
            for(Zuora__SubscriptionProductCharge__c spcElement : spcList) {
                String spcKey = generateSPCKey(spcElement.Zuora__Subscription__r.Name, spcElement.Zuora__UOM__c);
                spcMap.put(spcKey, spcElement);
            }
            
            return spcMap;
        }
        
        public static String generateSPCKey(String subscriptionNameParam, String uomParam) {
            return subscriptionNameParam + ' ' + uomParam;
        }
        
        public static Map<String,Set<String>> generateSPCKeySetMap(List<Usage__c> usageListParam) {
            Map<String,Set<String>> spcKeySetMap = new Map<String,Set<String>>();
            spcKeySetMap.put(REQUEST_FIELD_SUBSCRIPTION_NUMBER, new Set<String>());
            spcKeySetMap.put(REQUEST_FIELD_UOM, new Set<String>());
            
            for(Usage__c usageElement : usageListParam) {
                if(usageElement.Subscription_Id__c != null) {
                    spcKeySetMap.get(REQUEST_FIELD_SUBSCRIPTION_NUMBER).add(usageElement.Subscription_Id__c);
                }
                if(usageElement.UOM__c != null) {
                    spcKeySetMap.get(REQUEST_FIELD_UOM).add(usageElement.UOM__c);
                }
            }
            
            return spcKeySetMap;
        }
        
        public static List<Zuora__SubscriptionProductCharge__c> getSPCList (Set<String> subscriptionNumberSetParam, Set<String> uomSetParam) {
            List<Zuora__SubscriptionProductCharge__c> spcList = [SELECT Id, Zuora__UOM__c, Zuora__Subscription__r.Name, Zuora__ChargeNumber__c, PublicationCode__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__r.Name IN :subscriptionNumberSetParam AND Zuora__UOM__c IN :uomSetParam AND Zuora__Subscription__r.Zuora__Status__c = 'Active' AND isDeleted = false]; //START/END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier
            
            return spcList;
        }
        
        public static void updateChargeNumberForUsageList(List<Usage__c> usageListParam, Map<String,Zuora__SubscriptionProductCharge__c> spcMapParam) {
            for(Usage__c usageElement : usageListParam) {
                if(usageElement.Rate_Plan_Charge_Id__c == null) {
                    String spcKey = generateSPCKey(usageElement.Subscription_Id__c, usageElement.UOM__c);
                    Zuora__SubscriptionProductCharge__c spcRecord = spcMapParam.get(spcKey);
            // START 04/07/2015 D-2698 Kevin Evasco - BatchPostageMonthlyUsage fix
            if(spcRecord != null) {
                usageElement.Rate_Plan_Charge_Id__c = spcRecord.Zuora__ChargeNumber__c;
                usageElement.Publication_Code__c = spcRecord.PublicationCode__c; //START 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier
            }
            // END 04/07/2015 D-2698 Kevin Evasco - BatchPostageMonthlyUsage fix
            }
        }
    }
        
        public static void updateChargeNumberForUsageMap(List<Map<String, Object>> usageMapListParam, Map<String,Zuora__SubscriptionProductCharge__c> spcMapParam) {
            for(Map<String, Object> usageMap : usageMapListParam) {
                if(usageMap.get(REQUEST_FIELD_CHARGE_NUMBER) == null) {
                    String subscriptionNumber = String.valueOf(usageMap.get(REQUEST_FIELD_SUBSCRIPTION_NUMBER));
                    String uom = String.valueOf(usageMap.get(REQUEST_FIELD_UOM));
                    String spcKey = generateSPCKey(subscriptionNumber, uom);
                    usageMap.put(REQUEST_FIELD_CHARGE_NUMBER, spcMapParam.get(spcKey));
                }
            }
        }   
        
        public static String getUsageType(Zuora__Subscription__c subscriptionParam) {
            String usageType;
            if (subscriptionParam.Billing_Type__c == 'Recurring Prepaid' && subscriptionParam.Grace_Period_Subscription__c == null)
                usageType = USAGE_TYPE_RECURRING_PREPAID_START;
            else if (subscriptionParam.Billing_Type__c == 'Recurring Postpaid' && subscriptionParam.Grace_Period_Subscription__c == null)
                usageType = USAGE_TYPE_RECURRING_POSTPAID_MONTHLY;
            else if (subscriptionParam.Grace_Period_Subscription__c != null)
                usageType = USAGE_TYPE_GRACE;
                
            return usageType;
        }
        // END 03/27/2015 D-2610 Kevin Evasco - New Utility Methods
        
        //START PD-0324 06072016 Gdelrosario : added new method for bulk generate usage
        /*
         * @description : method to generate the BULK Usage
         * @param : subscriptionId_ListOfUsageParamWrapper map variable where subscription id is the key 
         *      and LIST of UsageParamWrapper object as its value
         * @return : list of generated Usages 
         */
        public static list<Usage__c> generateUsage(map<id, List<UsageParamWrapper>> subscriptionId_ListOfUsageParamWrapper) {
            
            // start variables declaration
            map<string, Zuora__SubscriptionProductCharge__c> subIdUom_spc = new map<string, Zuora__SubscriptionProductCharge__c>();
            map<string, Usage__c> subIdUom_usage = new map<string, Usage__c>();
            map<date, set<string>> publicationDate_publicationCodeSet = new map<date, set<string>>();
            map<date, set<string>> nonpulibcationDate_publicationCodeSet = new map<date, set<string>>();
            map<string, set<id>> publicationCode_subscriptionIdSet = new map<string, set<id>>();
            map<string, set<string>> publicationCode_publishedDaySet = new map<string, set<string>>();
            map<string, integer> spcIdentifierKey_usageQuantityCounter = new map<string, integer>();
            list<Usage__c> generatedUsageList = new list<Usage__c>();
            list<date> coveredDates = new list<date>();
            set<id> validSubscriptionIdSet = new set<id>();
            set<string> tmpPublicationCodeSet = new set<string>();
            set<id> subscriptionIdSet = new set<id>();
            set<string> publicationCodeSet = new set<string>();
            set<date> holidayDates = new set<date>();
            set<string> coveredUomSet = new set<string>();
            set<string> tmpPubCodeSet;
            set<string> subscriptionPublishedDaySet = new set<string>();
            set<string> uomIssuedDays = new set<string>();
            Zuora__SubscriptionProductCharge__c subscriptionProductCharge = new Zuora__SubscriptionProductCharge__c();
            Usage__c usage = new Usage__c();
            UsageParamWrapper usageParamWrapperTmp = new UsageParamWrapper();
            date coveredDateStart;
            date coveredDateEnd;
            date coverDate;
            string spcIdentifierKey;
            string spcIdentifierKeyDate;
            string formattedPubDate;
            boolean isCreateUpdateUsage;
            integer usageQuantityCounter;
            integer multiplier;
            // end variables declaration
            
             //START UD-1156 and D-0077 15-June-2015 Added by Raviteja  - Implementing the Public_Holiday_Weekday_Pub_Indicator__c and Public_Holiday_Weekend_Pub_Indicator__c from custom settings
            Map<String,Public_Holiday_Pub_Indiators__c> pubholidayCodes = Public_Holiday_Pub_Indiators__c.getAll();  
            //End UD-1156 and D-0077 15-June-2015 Added by Raviteja
            
            // start retrieve the valid subscription ids and the dates from the paramater
            for (id subId : subscriptionId_ListOfUsageParamWrapper.keySet()) {
                for(UsageParamWrapper tmpWrapper : subscriptionId_ListOfUsageParamWrapper.get(subId)){
                    if (tmpWrapper != null) {
                        if (tmpWrapper.subscriptionProductChargeUom != null && tmpWrapper.startDate != null && tmpWrapper.endDate != null) {
                            if (tmpWrapper.subscriptionProductChargeUom.isEmpty() == false && tmpWrapper.startDate <= tmpWrapper.endDate) {
                                validSubscriptionIdSet.add(subId);
                                coveredUomSet.addAll(tmpWrapper.subscriptionProductChargeUom);
                                coveredDates.add(tmpWrapper.startDate);
                                coveredDates.add(tmpWrapper.endDate);
                            }
                        }
                    }
                }    
            }
            // end retrieve the valid subscription ids and the dates from the paramater

            coveredDates.sort();    // sort the covered dates to get the starting and ending dates
            
            // start validate necessary details needed
            if (coveredDates.size() > 0) {
            
                coveredDateStart = coveredDates[0];
                coveredDateEnd = coveredDates[coveredDates.size() - 1];
                    
                    
                // start retrieve the related subscription product and charges as well as well as the publication code
                for (Zuora__SubscriptionProductCharge__c spc : [select Zuora__Subscription__c, Product_Code__c, Zuora__UOM__c, 
                        Zuora__ChargeNumber__c, PublicationCode__c from Zuora__SubscriptionProductCharge__c where Zuora__Subscription__c in :validSubscriptionIdSet  
                        and Zuora__UOM__c in :coveredUomSet]) {
                    for(UsageParamWrapper usageParamWrapperTmp1 : subscriptionId_ListOfUsageParamWrapper.get(spc.Zuora__Subscription__c)){
                        if (usageParamWrapperTmp1.subscriptionProductChargeUom.contains(spc.Zuora__UOM__c) == true 
                            && spc.PublicationCode__c != null && spc.Zuora__UOM__c != null && spc.Zuora__ChargeNumber__c != null) {
                            if (usageParamWrapperTmp1.subscriptionProductChargeUom.size() > 0) {
                                if (usageParamWrapperTmp1.subscriptionProductChargeUom.contains(spc.Zuora__UOM__c) == true) {
                                    
                                    subscriptionIdSet = new set<id>();
                                    
                                    spcIdentifierKey = generateSpcIndentifierKey(string.valueOf(spc.Zuora__Subscription__c), spc.Zuora__UOM__c);
                                    subIdUom_spc.put(spcIdentifierKey, spc);
                                    publicationCodeSet.add(spc.PublicationCode__c);
                                    
                                    if (publicationCode_subscriptionIdSet.get(spc.PublicationCode__c) != null) {
                                        subscriptionIdSet.addAll(publicationCode_subscriptionIdSet.get(spc.PublicationCode__c));
                                    }
                                    
                                    subscriptionIdSet.add(spc.Zuora__Subscription__c);
                                    
                                    publicationCode_subscriptionIdSet.put(spc.PublicationCode__c, subscriptionIdSet);
                                    
                                }
                            }
                        }
                    }
                    
                }
                
                // end retrieve the related subscription product and charges as well as well as the publication code
                
                // start retrieve non publication dates
                for (Non_Publication_Day__c tmp : [select Publication_Code__c, Non_Publication_Date__c from Non_Publication_Day__c 
                        where Publication_Code__c in :publicationCodeSet and Non_Publication_Date__c >= :coveredDateStart 
                        and Non_Publication_Date__c <= :coveredDateEnd]) {
                
                    tmpPublicationCodeSet = new set<string>();
                    
                    if (nonpulibcationDate_publicationCodeSet.get(tmp.Non_Publication_Date__c) != null) {
                        tmpPublicationCodeSet.addAll(nonpulibcationDate_publicationCodeSet.get(tmp.Non_Publication_Date__c));
                    }
                    
                    if (tmp.Publication_Code__c != null) {
                        tmpPublicationCodeSet.add(tmp.Publication_Code__c);
                    }
                    
                    nonpulibcationDate_publicationCodeSet.put(tmp.Non_Publication_Date__c, tmpPublicationCodeSet);
                }
                // end retrieve non publication dates
            
                // start retrieve holiday dates
                for (Public_Holiday__c tmp : [select Holiday_Date__c from Public_Holiday__c where Holiday_Date__c >= :coveredDateStart 
                        and Holiday_Date__c <= :coveredDateEnd]) {
                    
                    holidayDates.add(tmp.Holiday_Date__c);
                }
                // end retrieve holiday dates
                
                // start retrieve publication published days
                publicationCode_publishedDaySet = retrievePublishedDays(publicationCodeSet);
                // end retrieve publication published days
                
                // start retrieve publication dates
                for (coverDate = coveredDateStart; coverDate <= coveredDateEnd; coverDate = coverDate.addDays(1)) {
                    tmpPubCodeSet = new set<string>();
                    for (string pubCode : publicationCode_publishedDaySet.keySet()) {
                        if (publicationCode_publishedDaySet.get(pubCode) != null) {
                            if (publicationCode_publishedDaySet.get(pubCode).contains(((datetime)coverDate).format(DAY_NAME_DATE_PATTERN))) {
                                if (nonpulibcationDate_publicationCodeSet.get(coverDate) != null) {
                                    if (nonpulibcationDate_publicationCodeSet.get(coverDate).contains(pubCode) == false) { // filter the unpublished publication
                                        if (publicationDate_publicationCodeSet.get(coverDate) != null) {
                                            tmpPubCodeSet.addAll(publicationDate_publicationCodeSet.get(coverDate));
                                        }
                                        tmpPubCodeSet.add(pubCode); 
                                        publicationDate_publicationCodeSet.put(coverDate, tmpPubCodeSet);
                                    }
                                } else {
                                    if (publicationDate_publicationCodeSet.get(coverDate) != null) {
                                        tmpPubCodeSet.addAll(publicationDate_publicationCodeSet.get(coverDate));
                                    }
                                    tmpPubCodeSet.add(pubCode); 
                                    publicationDate_publicationCodeSet.put(coverDate, tmpPubCodeSet);
                                    
                                    
                                }
                            }
                        }
                    }
                }
                // end retrieve publication dates
                
                // start calculation
                //publicationCode_subscriptionIdSet
                
                for (date pubDate : publicationDate_publicationCodeSet.keySet()) {
                    system.debug('pubDate>>>214'+pubDate);
                    for (string pubCode : publicationDate_publicationCodeSet.get(pubDate)) {
                        // start retrieve related subscriptions
                        for (string subId : publicationCode_subscriptionIdSet.get(pubCode)) {
                            // start retrieve subscription details
                            for(UsageParamWrapper usageParamWrapperTmp1 : subscriptionId_ListOfUsageParamWrapper.get(subId)){
                                if (pubDate >= usageParamWrapperTmp1.startDate && pubDate <= usageParamWrapperTmp1.endDate) {
                                
                                    if (usageParamWrapperTmp1.frequency == DEFAULT_SUBSCRIPTION_FREQUENCY) {
                                        subscriptionPublishedDaySet = publicationCode_publishedDaySet.get(pubCode);
                                    } else if(ConstantsSLB.getOther(usageParamWrapperTmp1.frequency) != null) {
                                        subscriptionPublishedDaySet.addAll(delimitedStrToList(ConstantsSLB.getOther(usageParamWrapperTmp1.frequency), CSV_DELIMITER));
                                    }
                                 
                                    if (subscriptionPublishedDaySet != null) {
                                        if (subscriptionPublishedDaySet.isEmpty() == false && publicationCode_publishedDaySet.get(pubCode) != null) {
                                            formattedPubDate = ((datetime)pubDate).format(DAY_NAME_DATE_PATTERN);
                                            if (subscriptionPublishedDaySet.contains(formattedPubDate)) {
                                                for (string uom : usageParamWrapperTmp1.subscriptionProductChargeUom) {
                                                    // start retrieve uom issue days from custom settings
                                                    
                                                    uomIssuedDays = getUomIssueDays(uom);
                                                    if (uomIssuedDays != null) {
                                                        if (uomIssuedDays.contains(formattedPubDate) == true) {
                                                            
                                                            isCreateUpdateUsage = false;
                                                            
                                                            if (holidayDates.contains(pubDate) == true) {
                                                            system.debug('pubDate>>>242'+pubDate);
                                                            system.debug('holidayDates>>>'+holidayDates);
                                                                if (formattedPubDate == SATURDAY || formattedPubDate == SUNDAY) {
                                                                    //START UD-1156 and D-0077 15-June-2015 Added by Raviteja  - Commented pub.Public_Holiday_Weekday_Pub_Indicator__c condition and getting value from custom settings
                                                                    //if ( usageParamWrapperTmp.isPhe == true && pub.Public_Holiday_Weekday_Pub_Indicator__c) {
                                                                     if ( usageParamWrapperTmp1.isPhe == true && pubholidayCodes.get('Pub Indicators').Weekday__c) {
                                                                    //End UD-1156 and D-0077 15-June-2015 Added by Raviteja 
                                                                        isCreateUpdateUsage = true;
                                                                    }
                                                                } else {
                                                                    //START UD-1156 and D-0077 15-June-2015 Added by Raviteja  - Commented pub.Public_Holiday_Weekend_Pub_Indicator__c condition and getting value from custom settings
                                                                    //if ( usageParamWrapperTmp.isPhd == true && pub.Public_Holiday_Weekend_Pub_Indicator__c) {
                                                                     if ( usageParamWrapperTmp1.isPhd == true && pubholidayCodes.get('Pub Indicators').Weekend__c) {
                                                                    //End UD-1156 and D-0077 15-June-2015 Added by Raviteja  
                                                                        isCreateUpdateUsage = true;
                                                                    }
                                                                }
                                                            } else {
                                                                isCreateUpdateUsage = true;
                                                            }
                                                            
                                                            if (isCreateUpdateUsage == true) {
                                                                system.debug('pubDate>>>'+pubDate);
                                                                spcIdentifierKey = generateSpcIndentifierKey(subId, uom); 
                                                                spcIdentifierKeyDate = generateSpcIndentifierKeyDate(subId, uom, usageParamWrapperTmp1.startDate); 
                                                                subscriptionProductCharge = subIdUom_spc.get(spcIdentifierKey);
                                                                usage = new Usage__c();
                                                                
                                                                if (subscriptionProductCharge != null) {
                                                                    
                                                                    multiplier = 1;
                                                                    
                                                                    if (usageParamWrapperTmp1.subscriptionQuantity != null) {
                                                                        multiplier = usageParamWrapperTmp1.subscriptionQuantity;
                                                                    }
                                                                    
                                                                    if (subIdUom_usage.get(spcIdentifierKeyDate) != null) {
                                                                        
                                                                        usageQuantityCounter = spcIdentifierKey_usageQuantityCounter.get(spcIdentifierKey) + 1;
                                                                        usage = subIdUom_usage.get(spcIdentifierKeyDate);
                                                                        usage.Quantity__c = usageQuantityCounter * multiplier;
                                                                        
                                                                    } else {
                                                                        
                                                                        usageQuantityCounter = 1;
                                                                        usage.Account_Id__c = usageParamWrapperTmp1.billingAccountNumber;
                                                                        usage.Subscription_Id__c = usageParamWrapperTmp1.subscriptionName;
                                                                        usage.Start_Date__c = usageParamWrapperTmp1.startDate;
                                                                        usage.End_Date__c = usageParamWrapperTmp1.endDate;
                                                                        usage.UOM__c = subscriptionProductCharge.Zuora__UOM__c;
                                                                        usage.Rate_Plan_Charge_Id__c = subscriptionProductCharge.Zuora__ChargeNumber__c;
                                                                        usage.Publication_Code__c = subscriptionProductCharge.PublicationCode__c; //START/END 05/04/2015 D-2844 Kevin Evasco - Add Publication Code in the Unique Identifier
                                                                        usage.Status__c = USAGE_STATUS;
                                                                        usage.Quantity__c = 1 * multiplier;
                                                                        usage.Usage_Type__c = USAGE_TYPE_NONDELIVERY; //START/END 03/31/2015 D-2610 Kevin Evasco - Insert unique usages only                                                        
                                                                    }
                                                                    
                                                                    spcIdentifierKey_usageQuantityCounter.put(spcIdentifierKey, usageQuantityCounter);
                                                                    subIdUom_usage.put(spcIdentifierKeyDate, usage);
                                                                    
                                                                }
                                                            }
                                                        }
                                                    }
                                                    // end retrieve uom issue days from custom settings
                                                }
                                            }
                                        }
                                    }
                                }
                                // end retrieve subscription details
                            }
                            
                        }
                        // end retrieve related subscriptions
                    }
                }
                // end calculation
            }
            // end validate necessary details needed
            
            if (subIdUom_usage.isEmpty() == false) {
                generatedUsageList = subIdUom_usage.values();
            }
            
            return generatedUsageList;
        }
        
        
                
        /*
         * @description : this method is use to generate a unique key to be used in a map variable for usage quantity incrementation
         * @param : subscriptionId - id of subscription
         * @param : uom - Unit of Measure another is date to be unique
         * @return : concatenation of subscription id and Unit of Measure
         */
        private static string generateSpcIndentifierKeyDate(string subscriptionId, string uom, date startDate) {
            return subscriptionId + uom + String.valueOf(startDate);
        }
        
        //END PD-0324 06072016 Gdelrosario : added new method for bulk generate usage
        
    }