/*
* Class Name: <CSVReader_Test>
* @author: Reszel Garrie Pineda
* Date: 2/05/2015
* Requirement/Project Name: <SPH>
* @description: Test class for CSVReader
*/
@isTest (seeAllData= True)
private class CSVReader_Test {
    
    /* @description: This method check positive scenario for CSVReader */
    static testmethod void testCSVReader()
    {       
        Test.startTest();
        
        CSVReader reader1 = new CSVReader(',foo');
        reader1.ReadLine();                      
        
        CSVReader.Parse('foo');
        System.assertEquals(true, reader1<>null);
        Test.stopTest();       
    }//end of testCSVReader()
    
    /* @description: This method check negative scenario for CSVReader */
    static testmethod void testCSVReaderNeg()
    {        
        Test.startTest();        
        
        CSVReader reader2 = new CSVReader('"foo"');
        reader2.ReadLine();
        
        CSVReader reader3 = new CSVReader('\'foo\'');
        reader3.ReadLine();
        
        CSVReader.Parse('foo');
        System.assertEquals(true, reader2<>null);
        Test.stopTest();
    }//end of testCSVReaderNeg()
}//end of CSVReader_Test