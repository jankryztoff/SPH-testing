/**
 * Class Name: StringUtility
 * Author: Renino Niefes
 * Date: 01/22/2015 
 * Project/Requirement: SPH Integration
 * Description: This class contains reusable methods for processing String information.
 * History: 2015/01/22 Renino Niefes Created Utility Class
 *          2015/03/06 Michael Francisco    - D-2446 - Created method to enclose String in double quote characters 
 *          2015/03/30 Michael Francisco    - UD-0624 - Created method to split custom setting values and return a Set
 *              2015/06/09 Michael Francisco    - Created new getAccountingPeriod() method. Hot Fix for INET054DX - Share Investor Charge Out File.
 */
 
public class StringUtility
{
    public static String formatValue(Decimal inputNumber, String padValue, String padDirection, Integer padLength)
    {
        String newValue = '';
        if (inputNumber!=null) {
            newValue = String.valueOf(inputNumber.intValue());
            if (padDirection.equalsIgnoreCase('left')) {
                newValue = newValue.leftPad(padLength).replace(' ',padValue);
            } else {
                newValue = newValue.rightPad(padLength).replace(' ',padValue);
            }
        } else {
            newValue = String.valueOf(0).leftPad(padLength).replace(' ',padValue);
        }       
        return newValue;
    }
    
    public static String formatDateValue(Date inputDate, String dateFormat) {
        String newValue = '';
           
        if (dateFormat.equalsIgnoreCase('dd.mm.yyyy')) {
            if (inputDate!=null) {
                newValue = String.valueOf(inputDate.day()).leftPad(2).replace(' ','0') + '.' 
                + String.valueOf(inputDate.month()).leftPad(2).replace(' ','0') + '.' 
                + String.valueOf(inputDate.year()).leftPad(4).replace(' ','0');
            }   
        }
        
        if (dateFormat.equalsIgnoreCase('yyyymmdd')) {
            if (inputDate!=null) {
                newValue = String.valueOf(inputDate.year()).leftPad(4).replace(' ','0')
                + String.valueOf(inputDate.month()).leftPad(2).replace(' ','0')
                + String.valueOf(inputDate.day()).leftPad(2).replace(' ','0');              
            }   
        }       
        
        return newValue;
    }
    
    //START D-2446 2015/03/06 Michael Francisco - Created new method to perform String replace / double quote encasement 
    public static String quoteReplaceStr(String inputStr) {
        String outputStr = inputStr;
        if (outputStr != null && outputStr.length() > 0 ) {
            outputStr = inputStr.replaceAll('["]','').replaceAll('[\']','');
            outputStr = '"' + outputStr + '"';
        }
        return outputStr;
    }
    //END D-2446 2015/03/06 Michael Francisco 
    
    //START UD-0624 2015/03/30 Michael Francisco - Created method to split custom setting values and return a Set
    public static Set<String> getValues(String inputStr) {
        Set<String> outputSet = new Set<String>();
        if (inputStr != null && inputStr.length() > 0 ) {
            String delim = getDelimiter();
            List<String> l = inputStr.split('['+delim+']');
            if (l.size() > 0) {
                for (String rec:l) {
                    if (rec != null && rec.length() > 0) {
                        outputSet.add(rec);                     
                    }
                }
            }
        }
        return outputSet;
    }
    
    public static String getCustomSetting(String name) {
        String resultStr = '';
        if (name != null && name.length() > 0) {
            List<BT_CS_Interface_Parameters__c> valueList = new List<BT_CS_Interface_Parameters__c>();
            valueList = [SELECT 
                            Value__c 
                        FROM BT_CS_Interface_Parameters__c
                        WHERE Name = :name
                        ORDER BY CreatedDate DESC NULLS LAST 
                        LIMIT 1];   
            if (valueList.size() == 1) {
                String check = valueList.get(0).Value__c;
                if (check != null && check.length() > 0) {
                    resultStr = check;
                }
            }   
        }   
        return resultStr;
    }
    
    private static String getDelimiter() {
        String delim = '|';
        String check = getCustomSetting('Delim');
        if (check != null && check.length() > 0) {
            delim = check;
        }
        return delim;
    }
    
    public static String getCopies(String type, Integer quantity, String pattern) {
        String result_data = StringUtility.formatValue(0,'0', 'left', 4);
        if (pattern != null && pattern.length() == 9 && type != null) {
            try {
                if (type == null || type.equalsIgnoreCase('DEFAULT')) {
                    String zeroes = StringUtility.formatValue(0,'0', 'left', 3);
                    String qty = StringUtility.formatValue(quantity,'0', 'left', 3);
                    result_data = pattern.replaceAll('[Y]',qty).replaceAll('[N]',zeroes);
                } else {
                    String wPattern = pattern.replaceAll('[Y]', '1').replaceAll('[N]','0');
                    if (type.equalsIgnoreCase('DAY1')) {
                        Integer iMon = Integer.valueOf(wPattern.substring(0,1)) * quantity;
                        result_data = StringUtility.formatValue(iMon,'0', 'left', 4); //Day 1 Copy  
            
                    } else if (type.equalsIgnoreCase('DAY2')) {             
                        Integer iTue = Integer.valueOf(wPattern.substring(1,2)) * quantity;
                        result_data = StringUtility.formatValue(iTue,'0', 'left', 4); //Day 2 Copy 

                    } else if (type.equalsIgnoreCase('DAY3')) {             
                        Integer iWed = Integer.valueOf(wPattern.substring(2,3)) * quantity;
                        result_data = StringUtility.formatValue(iWed,'0', 'left', 4); //Day 3 Copy 

                    } else if (type.equalsIgnoreCase('DAY4')) {             
                        Integer iThu = Integer.valueOf(wPattern.substring(3,4)) * quantity;
                        result_data = StringUtility.formatValue(iThu,'0', 'left', 4); //Day 4 Copy 

                    } else if (type.equalsIgnoreCase('DAY5')) {             
                        Integer iFri = Integer.valueOf(wPattern.substring(4,5)) * quantity;
                        result_data = StringUtility.formatValue(iFri,'0', 'left', 4); //Day 5 Copy 

                    } else if (type.equalsIgnoreCase('DAY6')) {             
                        Integer iSat = Integer.valueOf(wPattern.substring(5,6)) * quantity;
                        result_data = StringUtility.formatValue(iSat,'0', 'left', 4); //Day 6 Copy 

                    } else if (type.equalsIgnoreCase('DAY7')) {             
                        Integer iSun = Integer.valueOf(wPattern.substring(6,7)) * quantity;
                        result_data = StringUtility.formatValue(iSun,'0', 'left', 4); //Day 7 Copy 

                    } else if (type.equalsIgnoreCase('PHD')) {              
                        Integer iPHd = Integer.valueOf(wPattern.substring(7,8)) * quantity;
                        result_data = StringUtility.formatValue(iPHd,'0', 'left', 4); //PHd week end copy   

                    } else if (type.equalsIgnoreCase('PHE')) {              
                        Integer iPHe = Integer.valueOf(wPattern.substring(8)) * quantity;
                        result_data = StringUtility.formatValue(iPHe,'0', 'left', 4); //PHe week end copy   

                    }                   
                }       
            } catch (Exception e) {
                result_data = StringUtility.formatValue(0, '0', 'left', 4);
            }
        }       
        return result_data;
    }

    public static String getPublishedDays(String zSubscriptionFrequency, String zPublishedDays) {
        String result_data = '';
        if (zPublishedDays != null) {
            result_data = zPublishedDays;
        }       
        if (zSubscriptionFrequency !=null && !zSubscriptionFrequency.equalsIgnoreCase('default')) {
            if (zSubscriptionFrequency.equalsIgnoreCase('Mon - Fri')) {
                result_data = 'YYYYYNN';
            } else if (zSubscriptionFrequency.equalsIgnoreCase('Mon - Sat')) {
                result_data = 'YYYYYYN';
            } else if (zSubscriptionFrequency.equalsIgnoreCase('Sat - Sun')) {  
                result_data = 'NNNNNYY';
            }       
        } 
        return result_data;
    }
    
    public static String formatDate(DateTime inputDate) {
        String format_date = '';
        if (inputDate!=null) {
            format_date =   String.valueOf(inputDate.day()).leftPad(2).replace(' ','0') + '.'
                          + String.valueOf(inputDate.month()).leftPad(2).replace(' ','0') + '.' 
                          + String.valueOf(inputDate.year());
        } else {
            format_date = null;
        }
        return format_date;
    }   
    //END UD-0624 2015/03/30 Michael Francisco  
    
    
    //START Code Review 2015-05-15 Renz Migrated reuseable codes into String Utility from Batch Classes
    public static String validate(Object zInput) {
        String resultStr = (zInput!=null) ? '0':'1';
        return resultStr;
   }
    public static  String validate(String zInput) { 
        String resultStr = (String.isNotBlank(zInput)) ? '0':'1';
        return resultStr;
    }
    
    public static String getVendor(String zVendorGroup, String zVendorCode) {
        String zResultStr = '';
        if (String.isNotBlank(zVendorCode)) {
            if (String.isNotBlank(zVendorGroup)) {
                zResultStr = zVendorGroup + zVendorCode;
            } else {
                zResultStr = 'V' + zVendorCode;
            }
        } else {
            zResultStr = null;
        }
        return zResultStr;
    }   
    //END Code Review 2015-05-15 Renz Migrated reuseable codes into String Utility from Batch Classes
    
    public static String getAccountingPeriod(String zBatchRunDate) {
        String zResult = '';
        if (String.isNotBlank(zBatchRunDate)) {
            Integer iMonth = 0;
            Integer iYear = 0;
            try {
                Date dBatchRunDate = Date.valueOf(zBatchRunDate);
                iMonth = dBatchRunDate.month();
                iYear = dBatchRunDate.year();                               
            } catch (Exception e) {
                Date dToday = Date.today();
                iMonth = dToday.month();
                iYear = dToday.year();                  
            }           
            String zMonth = (iMonth < 10) ? ('0'+iMonth) : String.valueOf(iMonth);
            String zYear = String.valueOf(iYear).substring(2,4);
            String zAccountingPeriod = zMonth + zYear;
            if (String.isNotBlank(zAccountingPeriod)) {
                zResult = zAccountingPeriod;
            }               
        }
        return zResult;
    }
    
    //START 25 February 2016 NCR015-5 Kevin Evasco - Packing Label CR
    public static string wrapEscape(String mainStr, String specialChar, String wrapper){
        String result = mainStr;
        if(result != null)
            result = result.replaceAll(specialChar, wrapper + specialChar + wrapper);
        else
            result = ' ';
        return result;
    }
    //END 25 February 2016 NCR015-5 Kevin Evasco - Packing Label CR
}