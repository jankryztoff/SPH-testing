@isTest (Seealldata = TRUE)
private class BT_DEV_DebuggerTest {

    static testmethod void unitTest1(){
        //prepares the data needed for executing test data
        BT_DEV_Debugger bdd = new BT_DEV_Debugger();
        bdd.addDebugLogs('Sample Interface', 'Sample Message');
        bdd.saveDebugLogs();
        bdd.clearDebugLogs('Sample Interface');
    }//end of unitTest1
    
}