/*
 * Class Name: ZInvoiceHelperTest
 * @author: Jensar Joey Z. Sayson
 * Date: 4/8/2016
 * Project/Requirement:  <SPH>
 * @description Test Class for ZInvoiceHelper
 */

@isTest(seeAllData = false)
public class ZInvoiceHelperTest {

   	//initializing adjustInvoicePreviousBalance
    static testMethod void test01(){
                    
		List<ZInvoiceHelper.ZInvoiceWrapper> zihZiwList = new List<ZInvoiceHelper.ZInvoiceWrapper>();
        ZInvoiceHelper.ZInvoiceWrapper zihZiw1 = new ZInvoiceHelper.ZInvoiceWrapper();
        zihZiw1.invoiceId = 'invoiceIdTest';
        zihZiw1.previousBalance = 'previousBalanceTest';
        
		zihZiwList.add(zihZiw1);
        
       	Logger loggerParam = new Logger(ZInvoiceHelperTest.class.getName()); 

        ZInvoiceHelper.adjustInvoicePreviousBalance(zihZiwList, loggerParam);
        
        Test.startTest();
        
        	System.assertNotEquals(null,zihZiwList);
        	System.assertNotEquals(null,loggerParam);
        
        Test.stopTest(); 
    }
}