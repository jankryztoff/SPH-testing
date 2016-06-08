global class OnlineExceptions{
    private static Map<String, String> excpCodes = new Map<String, String>();
    public static String SUCCESS = 'SUCCESS';
    public static String FAILURE = 'FAILURE';
    static{
        excpCodes.put('EXGN0000','GenericException'); // to be used in case of unrecoverable exceptions / errors
        excpCodes.put('EXWS0001','Could not get response from Server');
        excpCodes.put('EXWS0002','Could not Establish Connection');
        excpCodes.put('EXES0001','Mandatory validation failed');
        excpCodes.put('EXES0002','Invalid Credentials');
        excpCodes.put('EXES0003','Customer not found');
        excpCodes.put('EXES0004','Invalid input, Back-end Validation Failure');
        excpCodes.put('EXES0005','No Data Found for the Promotion + Gift Combination');
        excpCodes.put('EXES0006','Too Many Records Fetched');
        excpCodes.put('EXES0007','No Records Fetched');
        //Start [K. Ibalio  1/19/2015 D-1509] Changing expected error message for EXES0008
        excpCodes.put('EXES0008','Gift code not found');
        //End [K. Ibalio  1/19/2015 D-1509] Changing expected error message for EXES0008
        excpCodes.put('EXES0009','Overlapping temp stop period');
        excpCodes.put('EXES0010','Temp Stop mandatory parameters missing');
        excpCodes.put('EXES0011','Subscriber subscription combo invalid');
        excpCodes.put('EXES0012','Country Code is invalid. ');
        excpCodes.put('EXES0013','Postal Code is invalid. ');
        excpCodes.put('EXES0014','Account cannot be created. ');
        excpCodes.put('EXES0015','Account Number is invalid. ');
        //[Krithika D added for ARMS ]
        excpCodes.put('EXARMS0001','Mandatory validation field');
        excpCodes.put('EXARMS0002','SystemID should be SS');
        excpCodes.put('EXARMS0004','No records are fetched');
        excpCodes.put('EXARMS0003','Change of address failure/Update failure');
        //[KristineCampang added for 1.3.1.10.  Tagging LDAP id to print Subscribers]
        excpCodes.put('EXES0016','The subscriber already has existing digital subscription, please contact the CSO');
        excpCodes.put('EXES0017','No valid subscriptions to tag the asia one id to');
        //end [KC 1.3.1.10. Tagging LDAP id to print Subscribers]
        //[ChristopherManawatao added for ES; FetchTempSub]
        excpCodes.put('EXES0018','Too many Temp Stop Subscriptions fetched');
        //end [CM FetchTempSub]
        // Start D-1766 01/23/2015 JohnD building name error
        excpCodes.put('EXES0019','Building name does not match the postal code');
        // End D-1766 01/23/2015 JohnD
		//START: D-1933,1938 01/28/2015 Added by S.Puli update fields
		excpCodes.put('EXES0020','Temp stop not possible on cancelled/expired subscription');
		excpCodes.put('EXES0021 ','Customer not eligible for promotion.');
        //END: D-1933,1938 01/28/2015 Added by S.Puli update fields
    }
    
    public static String getErrorMessage(String errCode){
        return excpCodes.get(errCode);
    }
}