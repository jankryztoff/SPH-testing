/*
 * Class Name: PubIssueHelper
 * @Author: Wenjun Zhu
 * @Date: 11/Feb/2015
 * @Description: This is the utility class for managing Publication and Publication Issue related data
 * 
 * History: 
 */
public class PubIssueHelper 
{
    /**@description: generate Publication Pattern for a Publication
     * @param publication : A Publication Record
     * @return PublicationPattern
     */ 
    public static PublicationPattern generatePubPattern(Publication__c publication)
    {
        String publishDays = publication.Published_Days__c;
        
        PublicationPattern pattern = new PublicationPattern();
        pattern.isPHd = publication.Public_Holiday_Weekday_Pub_Indicator__c;
        pattern.isPHe = publication.Public_Holiday_Weekend_Pub_Indicator__c;
        try
        {
            pattern.isMon = publishDays.mid(0,1) == 'Y'? true : false;
            pattern.isTue = publishDays.mid(1,1) == 'Y'? true : false;
            pattern.isWed = publishDays.mid(2,1) == 'Y'? true : false;
            pattern.isThu = publishDays.mid(3,1) == 'Y'? true : false;
            pattern.isFri = publishDays.mid(4,1) == 'Y'? true : false;
            pattern.isSat = publishDays.mid(5,1) == 'Y'? true : false;
            pattern.isSun = publishDays.mid(6,1) == 'Y'? true : false; 
        }
        Catch (Exception e)
        {
            System.debug(System.LoggingLevel.ERROR,e.getMessage());
            throw new CustomException(System.Label.ERR_PUB_CONFIG);
        }
        return pattern;
    }
    
    /**@description: generate User Subscription Frequency for a Publication - Using the frequency indicator on Main Package
     * @param publication : A Publication Record
     * @param sub : A Zuora__Subscription__c Record
     * @return PublicationPattern
     */
    public Static PublicationPattern generateSubPattern(Publication__c publication, Zuora__Subscription__c sub){
        //START UAT Hotfix Wenjun 18 Aug - Using Subscription Frequency instead
        /*
        String freqIdentifier = sub.Main_Package_1__r.Frequency_Identifier__c;
        String userFrequency = 'NNNNNNN';
        
        if(freqIdentifier == '0')
            userFrequency = publication.Published_Days__c;
        else if(freqIdentifier == '1') //Mon - Fri
            userFrequency = 'YYYYYNN';
        else if(freqIdentifier== '2') //Weekend only
            userFrequency = 'NNNNNYY';
        else if(freqIdentifier == '3') //Mon - Sat
            userFrequency = 'YYYYYYN';
        */
        String subFreq = sub.Frequency_1__c;
        String userFrequency = 'NNNNNNN';
        
        if(subFreq == GlobalVariableClass.FREQ_DEFAULT)

            userFrequency = publication.Published_Days__c;
        else if(subFreq == GlobalVariableClass.FREQ_MONFRI) //Mon - Fri

            userFrequency = 'YYYYYNN';
        else if(subFreq== GlobalVariableClass.FREQ_SATSUN) //Weekend only

            userFrequency = 'NNNNNYY';
        else if(subFreq == GlobalVariableClass.FREQ_MONSAT) //Mon - Sat

            userFrequency = 'YYYYYYN';
        //END UAT Hotfix Wenjun 18 Aug 
        
        PublicationPattern pattern = new PublicationPattern();
        pattern.isPHd = sub.Ph_d__c;
        pattern.isPHe = sub.Ph_e__c;
        try
        {
            pattern.isMon = userFrequency.mid(0,1) == 'Y'? true : false;
            pattern.isTue = userFrequency.mid(1,1) == 'Y'? true : false;
            pattern.isWed = userFrequency.mid(2,1) == 'Y'? true : false;
            pattern.isThu = userFrequency.mid(3,1) == 'Y'? true : false;
            pattern.isFri = userFrequency.mid(4,1) == 'Y'? true : false;
            pattern.isSat = userFrequency.mid(5,1) == 'Y'? true : false;
            pattern.isSun = userFrequency.mid(6,1) == 'Y'? true : false; 
        }
        Catch (Exception e)
        {
            System.debug(System.LoggingLevel.ERROR,e.getMessage());
            throw new CustomException(System.Label.ERR_PUB_CONFIG);
        }
        return pattern;
    }
    
    /**@description: this method checks if the input Public Holiday is a publish date for the Publication
     * @param publication : the publication to check
     * @param inputDate : a Public Holiday Date
     * @return Boolean
     */ 
    public static Boolean isHolidayPublishDate(Publication__c publication, Date inputDate)
    {
        String dayInWeek = DateUtility.dayInWeekEEE(inputDate);
        if(dayInWeek == 'Sat' || dayInWeek == 'Sun') //Public Holiday on Weekend
            return (publication.Public_Holiday_Weekend_Pub_Indicator__c);
        else //Public Holiday on Weekdays
            return (publication.Public_Holiday_Weekday_Pub_Indicator__c);
    }
    
    /**@description: this method checks if the input Public Holiday is a publish date for the Publication Pattern
     * @param pattern : the publication pattern to check
     * @param inputDate : a Public Holiday Date
     * @return Boolean
     */ 
    public static Boolean isHolidayPublishDate(PublicationPattern pattern, Date inputDate)
    {
        String dayInWeek = DateUtility.dayInWeekEEE(inputDate);
        if(dayInWeek == 'Sat' || dayInWeek == 'Sun') //Public Holiday on Weekend
            return (pattern.isPHe);
        else //Public Holiday on Weekdays
            return (pattern.isPHd);
    }
    
    /**@description: this method checks if the input date is a Publish Date based on the Publication Pattern
     * @param pattern : the publication pattern of a Publication
     * @param inputDate : a input Date to check
     * @return Boolean
     */ 
    public static Boolean isPublishDate(PublicationPattern pattern, Date inputDate)
    {
        String dayInWeek = DateUtility.dayInWeekEEE(inputDate);
        
        if(dayInWeek == 'Mon') return pattern.isMon;
        else if(dayInWeek == 'Tue') return pattern.isTue;
        else if(dayInWeek == 'Wed') return pattern.isWed;
        else if(dayInWeek == 'Thu') return pattern.isThu;
        else if(dayInWeek == 'Fri') return pattern.isFri;
        else if(dayInWeek == 'Sat') return pattern.isSat;
        else if(dayInWeek == 'Sun') return pattern.isSun;
        
        return false;
    }
    
    /**@description: this method checks if the input date is a Publish Date based on frequency Code and next issue date
     * @param pattern : the publication pattern of a Publication
     * @param inputDate : a input Date to check
     * @return Boolean
     */ 
    public static Boolean isPublishDateForNonDailyPub(Publication__c publication, Date inputDate)
    {
        String frequencyCode = publication.Frequency_Code__c;
        Date nextIssueDate = publication.Publication_Next_Start_Date__c;

        if(frequencyCode == 'W') //Weekly
            return (Math.mod(inputDate.daysBetween(nextIssueDate), 7) == 0);
        else if(frequencyCode == 'F') //Fortnightly
            return (Math.mod(inputDate.daysBetween(nextIssueDate), 14) == 0); 
        else if(frequencyCode == 'M') //Monthly
            return (inputDate.day() == nextIssueDate.day()); 
        else if(frequencyCode == 'B') //Bi-Monthly
            return (inputDate.day() == nextIssueDate.day() && Math.mod(inputDate.monthsBetween(nextIssueDate), 2) == 0); 
        else if(frequencyCode == 'Q') //Quarterly
            return (inputDate.day() == nextIssueDate.day() && Math.mod(inputDate.monthsBetween(nextIssueDate), 3) == 0); 
        else if(frequencyCode == 'H') //Half-Yearly
            return (inputDate.day() == nextIssueDate.day() && Math.mod(inputDate.monthsBetween(nextIssueDate), 6) == 0); 
        else if(frequencyCode == 'Y') //Yearly
            return (inputDate.day() == nextIssueDate.day() && Math.mod(inputDate.monthsBetween(nextIssueDate), 12) == 0); 
            
        return false;
    }
    
    public Class PublicationPattern
    {
        public Boolean isMon {get; set;}
        public Boolean isTue {get; set;}
        public Boolean isWed {get; set;}
        public Boolean isThu {get; set;}
        public Boolean isFri {get; set;}
        public Boolean isSat {get; set;}
        public Boolean isSun {get; set;}
        public Boolean isPHd {get; set;}
        public Boolean isPHe {get; set;}
    }
}