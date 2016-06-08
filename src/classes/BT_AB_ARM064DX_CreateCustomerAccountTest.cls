/**
Class Name: BT_AB_ARM064DX_CreateCustomerAccountTest
@author: Accenture IDC (Shruti Kishore)
Date: 02/10/2015
Project/Requirement: SPH Integration - ARM063DX Interface 
@description This class is test class for BT_AB_ARM064DX_CreateCustomerAccount
*/

@isTest (Seealldata = TRUE)
public class BT_AB_ARM064DX_CreateCustomerAccountTest{

    static testmethod void unitTest1()
    {
    
            Test.startTest();           
            BT_AB_ARM064DX_CreateCustomerAccount batch = new BT_AB_ARM064DX_CreateCustomerAccount(); 
            ID batchprocessid = Database.executeBatch(batch, 200);
            Test.stopTest();
            
     
      }               
}