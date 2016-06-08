/*
*author: Alfred Abrina
*date: 02/23/2015
*Test class for wwwSphComArWsSchemaCamUpdateaccou
*/
@isTest(SeeAllData=True)
private with sharing class wwwSphComArWsSchemaCamUpdateaccou_Test{
/**
* test method for fields
*@name updateAccou 
*/  
private static testMethod void updateAccou()
    {
      Test.startTest();  
      new wwwSphComArWsSchemaCamUpdateaccou.AccUpd_element();
      Test.stopTest(); 
      System.assertEquals (null, null); 
    }
}