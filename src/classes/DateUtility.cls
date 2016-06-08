/**
 * Class Name: DateUtility
 * Author: Kevin Evasco
 * Date: 09/19/2014
 * Project/Requirement: SPH Integration
 * Description: This class contains reusable methods for processing Date information.
 * History: 
 *      09/19/2014 Kevin Evasco         - Created Utility Class
 *      09/25/2014 Renino Niefes        - Added convertDateFromYYYY_MM_DDtHH_MM_SSz method
 *      09/27/2014 Renino Niefes        - Added convertDateFromYYYY_MM_DDtHH_MM_SSzToMonthStart method
 *      09/27/2014 Renino Niefes        - Added convertDateFromYYYY_MM_DDtHH_MM_SSzToMonthEnd method
 *      09/28/2014 Kay Lorica           - Added Kevin's created getNthLastWorkingDay and isWorkingDay methods
 *      11/04/2014 Renino Niefes        - Modified ConvertDate method to inlcude YMD format
 *      01/10/2015 Michael Francisco    - Modified isDateDD_MM_YYYY to have initial checks to prevent false positives 
 *  02/11/2015 Wenjun       - Added dayInWeekEEE and dayInWeekEEEE method
 *      03/20/2015 REnino Niefes        - Added convertDateFromYYYY_MM_DD_CustomSettings (D-2584)
 *      03/31/2015 Renino Niefes        - Added overloaded method convertDateFromYYYY_MM_DD_CustomSettings.  Created getOverrideDate method for Batch Interface (UD-0639)
 *      08/25/2015 UD-2438 Renino Niefes - Modify the Date Utility method.  If the end date and start date differnce is < 7, use the default date instead
 *      08/27/2015 UD-2437 Renino Niefes - removing the call to the new method created.  It causes CPU time exceeded
 *      09/30/2015 UD-2768 Renino Niefes - Add another order by field (Batch Run Date).  Add new overloaded method of getOverrideDate
 */
 
public class DateUtility
{

    /* @description This converts the given date text input to Salesforce Date instance.  
     * 
     * @param inputDate - a string date
     * @param delimiter - delimiter used to separate day, month and year
     * @param format - arrangement of date information. Accepted values are DMY/MDY
     * @return void
     */ 
    public static Date convertDate(String inputDate, String delimiter, String format)
    {
        String[] strDate = inputDate.split(delimiter);
        Integer myIntDay;
        Integer myIntMonth;
        Integer myIntYear;
        
        if(format == 'DMY')
        {
            myIntDay = integer.valueOf(strDate[0]);
            myIntMonth = integer.valueOf(strDate[1]);
            myIntYear = integer.valueOf(strDate[2]);
        }
        else if(format == 'MDY')
        {
            myIntMonth = integer.valueOf(strDate[0]);
            myIntDay = integer.valueOf(strDate[1]);
            myIntYear = integer.valueOf(strDate[2]);
        }
        else if(format == 'YMD')
        {
            myIntMonth = integer.valueOf(strDate[1]);
            myIntDay = integer.valueOf(strDate[2]);
            myIntYear = integer.valueOf(strDate[0]);
        }        
        else
        {
            return null;
        }

        Date d = Date.newInstance(myIntYear, myIntMonth, myIntDay);
        return d;
    
    }
    
    /* @description This converts the given date text input to Salesforce Date instance.  
     * 
     * @param inputDate - a string date
     * @return void
     */ 
    public static Date convertDateFromYYYYMMDD(String inputDate)
    {    
        String myStrYear = inputDate.subString(0,4);
        String myStrMonth = inputDate.subString(4,6);
        String myStrDay = inputDate.subString(6,8);
        Integer myIntYear = Integer.valueOf(myStrYear);
        Integer myIntMonth = Integer.valueOf(myStrMonth);
        Integer myIntDay = Integer.valueOf(myStrDay);
        
        Date d = Date.newInstance(myIntYear, myIntMonth, myIntDay);
        return d;    
    }        
    
    /* @description Validates if the input date is a valid date.  
     * 
     * @param inputDate - a string date
     * @param delimiter - delimiter used to separate day, month and year
     * @return void
     */ 
    public static Boolean isDateDD_MM_YYYY(String inputDate, String delimiter)
    {
        //START D-1493 - Michael Francisco - 01.10.2015 - Changed isValid to be "false" by default to avoid false positives...
        Boolean isValid = false;
        //END D-1493 - Michael Francisco - 01.10.2015
        
        String[] strDate = inputDate.split(delimiter);
        String myStrDay;
        String myStrMonth;
        String myStrYear;
        Integer myIntDay;
        Integer myIntMonth;
        Integer myIntYear;        
        
        try
        {
            myStrDay = strDate[0];
            myStrMonth = strDate[1];
            myStrYear = strDate[2];
            myIntDay = integer.valueOf(myStrDay);
            myIntMonth = integer.valueOf(myStrMonth);
            myIntYear = integer.valueOf(myStrYear);
            
            //START D-1493 - Michael Francisco - 01.10.2015 - Added logic to check if Salesforce Date MIN - MAX limits were met 
            // Salesforce Date Limits ...               
            if (myIntYear <= 4000 && myIntYear >= 1700 &&
                myIntMonth <= 12 && myIntMonth >= 1 &&
                myIntDay <= 31 && myIntMonth >= 1) {
                
                // If within Salesforce limits then return TRUE ...
                isValid = true;
            } else {
            
                // Else return FALSE ...
                isValid = false;            
            }   
                
            // If values passed initial checks then see if valid DATE object can be created (i.e. 30.02.2015 should NOT return as a valid date)
            if (isValid) {
                Date d = Date.newInstance(myIntYear, myIntMonth, myIntDay);                     
            }
            //END D-1493 - Michael Francisco - 01.10.2015
        }
        catch(Exception e)
        {
            isValid = false;
        }
        
        return isValid;
    }
    
    /* @description Validates if the input date is a valid date.  
     * 
     * @param inputDate - a string date
     * @return void
     */ 
    public static Boolean isDateYYYYMMDD(String inputDate)
    {
        Boolean isValid = true;
        try
        {
            convertDateFromYYYYMMDD(inputDate);
        }
        catch(Exception e)
        {
            isValid = false;
        }
        
        return isValid;
    }
    
    /* @description This converts the given date text input to Salesforce Date instance.  
     * 
     * @param inputDate - a string date
     * @return void
     * format: yyyy-dd-ddThh:MM:ssZ
     */ 
    public static DateTime convertDateFromYYYY_MM_DDtHH_MM_SSz(String inputDate)
    {    
        String myStrYear = inputDate.subString(0,4);
        String myStrMonth = inputDate.subString(5,7);
        String myStrDay = inputDate.subString(8,10);
        String myStrHour = inputDate.subString(11,13);
        String myStrMinute = inputDate.subString(14,16);
        String myStrSecond = inputDate.subString(17,19);
        
        Integer myIntYear = Integer.valueOf(myStrYear);
        Integer myIntMonth = Integer.valueOf(myStrMonth);
        Integer myIntDay = Integer.valueOf(myStrDay);
        Integer myIntHour = Integer.valueOf(myStrHour);
        Integer myIntMinute = Integer.valueOf(myStrMinute);
        Integer myIntSecond = Integer.valueOf(myStrSecond);
        
        DateTime d = DateTime.newInstanceGmt(myIntYear, myIntMonth, myIntDay, myIntHour, myIntMinute, myIntSecond); //[START/END 2015-03-20 Renz Niefes D-2584] use newInstanceGMT instead
        return d;    
    }        
    
    
    //[START D-2584 Renz]
    //[START UD-0639 Renz 2015-03-30] Use the new custom settings instead
   /* @description This converts the given date text input to Salesforce Date instance.  
     * 
     * @param inputDate - a string date (Time string is appended from Custom Settings)
     * @return void
     * format: yyyy-dd-dd
     */ 
    public static DateTime convertDateFromYYYY_MM_DD_CustomSettings(String inputDate)
    {           
        List<BT_CS_Interface_Parameters__c> mcs = [SELECT Value__c FROM BT_CS_Interface_Parameters__c WHERE Name = 'Default Timestamp'];
        String cutOffTime = '';
        try {
            cutOffTime = mcs[0].Value__c;
        } catch (Exception e) {
            cutOffTime = 'T00:00:00.000Z';
        }
        inputDate += cutOffTime;
        
        System.debug(inputDate);
        
        String myStrYear = inputDate.subString(0,4);
        String myStrMonth = inputDate.subString(5,7);
        String myStrDay = inputDate.subString(8,10);
        String myStrHour = inputDate.subString(11,13);
        String myStrMinute = inputDate.subString(14,16);
        String myStrSecond = inputDate.subString(17,19);
        
        Integer myIntYear = Integer.valueOf(myStrYear);
        Integer myIntMonth = Integer.valueOf(myStrMonth);
        Integer myIntDay = Integer.valueOf(myStrDay);
        Integer myIntHour = Integer.valueOf(myStrHour);
        Integer myIntMinute = Integer.valueOf(myStrMinute);
        Integer myIntSecond = Integer.valueOf(myStrSecond);
        
        DateTime d = DateTime.newInstanceGmt(myIntYear, myIntMonth, myIntDay, myIntHour, myIntMinute, myIntSecond);
        return d;    
    }
    //[END UD-0639 Renz 2015-03-30] Use the new custom settings instead
    //[END D-2584 Renz]
    
   //[START UD-0639 Renz]
   /* @description This converts the given date text input to Salesforce Date instance.  
     * 
     * @param inputDate - a string date (Time string is appended from Custom Settings)
     * @param settingsName - name of the custom settings to use e.g. 
     * @return void
     * format: yyyy-dd-dd
     */
   public static DateTime convertDateFromYYYY_MM_DD_CustomSettings(String inputDate, String settingsName)
    {
        
        List<BT_CS_Interface_Parameters__c> mcs = [SELECT Value__c FROM BT_CS_Interface_Parameters__c WHERE Name = :settingsName];
        String cutOffTime = '';
        try {
            cutOffTime = mcs[0].Value__c;
        } catch (Exception e) {
            cutOffTime = 'T00:00:00.000Z';
        }
        inputDate += cutOffTime;
        
        System.debug(inputDate);
        
        String myStrYear = inputDate.subString(0,4);
        String myStrMonth = inputDate.subString(5,7);
        String myStrDay = inputDate.subString(8,10);
        String myStrHour = inputDate.subString(11,13);
        String myStrMinute = inputDate.subString(14,16);
        String myStrSecond = inputDate.subString(17,19);
        
        Integer myIntYear = Integer.valueOf(myStrYear);
        Integer myIntMonth = Integer.valueOf(myStrMonth);
        Integer myIntDay = Integer.valueOf(myStrDay);
        Integer myIntHour = Integer.valueOf(myStrHour);
        Integer myIntMinute = Integer.valueOf(myStrMinute);
        Integer myIntSecond = Integer.valueOf(myStrSecond);
        
        DateTime d = DateTime.newInstanceGmt(myIntYear, myIntMonth, myIntDay, myIntHour, myIntMinute, myIntSecond);
        return d;    
    }
    //[END UD-0639 Renz]        
    
    
   //[START UD-0639 Renz]
   /* @description This converts the given date text input to Salesforce Date instance.  
     * 
     * @param inputDate - a string date (Time string is appended from Custom Settings)
     * @param interfaceId - id of the interface
     * @return void
     * format: yyyy-dd-dd
     */
    public static DateTime getOverrideDate(String interfaceId)
    {
        DateTime d = null;      
        List<BT_CO_Batch_Run_Request__c> brr = [SELECT CreatedDate 
            FROM BT_CO_Batch_Run_Request__c 
            WHERE Interface_ID__c = :interfaceId 
            AND End_Time__c != NULL 
            ORDER BY Batch_Run_Date__c DESC, CreatedDate DESC NULLS FIRST LIMIT 1];    //START/END 09/30/2015 UD-2768 Renino Niefes - Add another order by field (Batch Run Date)
            
        try {
            d = brr[0].CreatedDate;
        } catch (Exception e) {
            d =  DateTime.now();
        }
        
        return d;
    
    }    
    //[END UD-0639 Renz] 

	//START UD-2768 2015-09-30 Renz Niefes overloaded this method to add batch run date in the critera
	public static DateTime getOverrideDate(String interfaceId, Date batchRunDate)
    {
        DateTime d = null;      
        List<BT_CO_Batch_Run_Request__c> brr = [SELECT CreatedDate 
            FROM BT_CO_Batch_Run_Request__c 
            WHERE Interface_ID__c = :interfaceId 
            AND End_Time__c != NULL AND Batch_Run_Date__c <= :batchRunDate
            ORDER BY Batch_Run_Date__c DESC, CreatedDate DESC NULLS FIRST LIMIT 1];
            
        try {
            d = brr[0].CreatedDate;
        } catch (Exception e) {
            d =  DateTime.now();
        }
        
        return d;
    
    }
	//END UD-2768 2015-09-30 Renz Niefes overloaded this method to add batch run date in the critera
	
    
   /* @description This converts the given date text input to Salesforce Date instance.  Returns the first day of that month
     * 
     * @param inputDate - a string date
     * @return void
     * format: yyyy-dd-dd
     */ 
    public static DateTime convertDateFromYYYY_MM_DD_ToMonthStart(String inputDate)
    {    
        String myStrYear = inputDate.subString(0,4);
        String myStrMonth = inputDate.subString(5,7);       
        Integer myIntYear = Integer.valueOf(myStrYear);
        Integer myIntMonth = Integer.valueOf(myStrMonth);
        
        DateTime d = DateTime.newInstanceGmt(myIntYear, myIntMonth, 1, 0, 0, 0); //[START/END 2015-03-20 Renz Niefes D-2584] use newInstanceGMT instead
        return d;    //e.g. 2014-09-27 becomes 2014-09-01
    }    


   /* @description This converts the given date text input to Salesforce Date instance.  Returns the last day of that month
     * 
     * @param inputDate - a string date
     * @return void
     * format: yyyy-dd-dd
     */ 
    public static DateTime convertDateFromYYYY_MM_DD_ToMonthEnd(String inputDate)
    {    
        String myStrYear = inputDate.subString(0,4);
        String myStrMonth = inputDate.subString(5,7);
        
        Integer myIntYear = Integer.valueOf(myStrYear);
        Integer myIntMonth = Integer.valueOf(myStrMonth);

        if (myIntMonth<12) {
            myIntMonth++;
        } else {
            myIntMonth=1;
            myIntYear++;
        }
        DateTime d = DateTime.newInstanceGmt(myIntYear, myIntMonth, 1, 23, 59, 59); //[START/END 2015-03-20 Renz Niefes D-2584] use newInstanceGMT instead
        d = d.addDays(-1);  
        return d;    
    }
    
    
   /* @description This converts the given date text input to Salesforce Date instance.  Returns the nth last working day of that month
     * 
     * @param currentDate - a string date, nthDay - integer 
     * @return void
     */
    public static DateTime getNthLastWorkingDay(Date currentDate, Integer nthDay){
        Integer daysInMonth = Date.daysInMonth(currentDate.year(), currentDate.month()) ; 
         system.debug('Days in month: '+ daysInMonth );
        Date dateIterator = Date.newInstance(currentDate.year(), currentDate.month(), daysInMonth);  
        system.debug('Initial dateIterator: '+ dateIterator);
        Integer counter = 0; 
        do 
        {
            system.debug('DateIterator formatted: '+ ((DateTime)dateIterator).format('EEEE'));
            if(isWorkingDay(((DateTime)dateIterator).format('EEEE')) == true)
            {        
                counter++;                
            } 
            if(counter < nthDay)
            {
                dateIterator = dateIterator.addDays(-1);
                system.debug('Counter is less than nthDay: ' + counter + ' - ' + nthDay);
                system.debug('Inside dateIterator: '+ dateIterator);           
            }
         
        } while(counter < nthDay);    
        system.debug('Final dateIterator: '+ dateIterator);                    
        return dateIterator;
    }

    public static Boolean isWorkingDay(String day)
    {
        if(day == 'Monday' || day == 'Tuesday' || day == 'Wednesday' || day == 'Thursday' || day == 'Friday')
            return true;
        else
            return false;
    }      

    public static String convertDateToString(Date dateValue)
    {
        Integer day = dateValue.day();
        Integer month = dateValue.month();
        Integer year= dateValue.year();
        
        String dayString;
        String monthString;
        String yearString = String.valueOf(year);
        
        if(day<10)
        {
            dayString = '0' + String.valueOf(day);
        }
        else
        {
            dayString = String.valueOf(day);
        }
        
        if(month<10)
        {
            monthString = '0' + String.valueOf(month);
        }
        else
        {
            monthString = String.valueOf(month);
        }
        
        String dateString = monthString + '/' + dayString + '/' + yearString;
        
        return dateString;
    } 

   /** @description: this method returns the day name in the week
     * @param inputDate : A date value
     * @return String: 'Mon' , "Tue', 'Wed' etc.
     */ 
    public static String dayInWeekEEE(Date inputDate)
    {    
        Datetime dt = (DateTime) inputDate;
        return dt.format('EEE');   
    }
    
    /** @description: this method returns the day name in the week
     * @param inputDate : A date value
     * @return String: 'Monday' , "Tuesday', 'Wednesday' etc.
     */ 
    public static String dayInWeekEEEE(Date inputDate)
    {    
        Datetime dt = (DateTime) inputDate;
        return dt.format('EEEE');   
    }
    
    /** @description: this method returns the first date in the given date range that is based on applicable to given publish pattern
     * @param inputDate :date range and publish pattern e.g. YYYYYYYNN
     * @return Date: 2015-05-14
     */ 
    public static Date getFirstPublicationDate(DateTime dateFrom, DateTime dateTo, String publishPattern)
    {
        Date effectiveDate = null;  
        try {
            //2015-08-27 UD-2437 Renz Removing this for now
            //if (daysBetweenDateTime(dateFrom, dateTo)<=7) dateTo = getDefaultEndDate(); //start/end UD-2438 Renino Niefes override the dateTo if < 7 days
            //2015-08-27 UD-2437 Renz Removing this for now
            Map<String,Integer> weekDayMap = new Map<String,Integer>();
            weekDayMap.put('Mon',0);
            weekDayMap.put('Tue',1);
            weekDayMap.put('Wed',2);
            weekDayMap.put('Thu',3);
            weekDayMap.put('Fri',4);
            weekDayMap.put('Sat',5);
            weekDayMap.put('Sun',6);
            if (dateFrom!=null&&publishPattern!=null) {
                DateTime datePointer = dateFrom;
                boolean dateFound = false;
                if (publishPattern.replaceAll('[nN]','').trim().length() > 0) {
                    if (dateTo==null) dateTo = dateFrom;
                    while (datePointer<=dateTo&&!dateFound) {
                        String dayString = datePointer.format('EEE');
                        Integer intDayOfWeek = weekDayMap.get(dayString);           
                        String dayPattern = publishPattern.subString(intDayOfWeek, intDayOfWeek+1);
                        if (dayPattern.equalsIgnoreCase('Y')) {
                            dateFound = true;
                            effectiveDate = datePointer.date();
                        }               
                        datePointer = datePointer.addDays(1);
                    }                   
                }
            }           
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        return effectiveDate;
    }
    
    public static Date getDefaultEndDate() {
        return Date.newInstance(2099, 12, 31);
    }

    //start UD-2438 Renino Niefes override the dateTo if < 7 days   
    public static Integer daysBetweenDateTime(Datetime startDate, Datetime endDate) {
        Integer i = 0;

        while (startDate < endDate) {
            i++;
            startDate = startDate.addDays(1);
        }
        return i;
    }
    //end UD-2438 Renino Niefes override the dateTo if < 7 days 
}