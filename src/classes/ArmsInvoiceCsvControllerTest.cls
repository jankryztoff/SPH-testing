@isTest (Seealldata = TRUE)
public class ArmsInvoiceCsvControllerTest {

    static testmethod void unitTest1(){
        ArmsInvoiceCsvController aicc = new ArmsInvoiceCsvController();
        aicc.fullCsv = 'full';
    }//end of unitTest1
    
}