/**
Class Name: ComplaintMagazineControllerTest
@author: Flores, Emmanuel D.
@Date: 10/23/2015
@Project/Requirement: SPH 
@description This class is test class for ComplaintMagazineController
**/
@isTest (Seealldata = false)
private class ComplaintMagazineControllerTest{

     static testmethod void unitTest1() {
     
        Cir_Planner_Schedule__c cir = new Cir_Planner_Schedule__c();
        cir.Name = 'CIR Plan Schedule';
        cir.Mon_Fri_End_Time__c = DateTime.newInstance(2014, 08, 19, 22, 0, 0);
        cir.Mon_Fri_Start_Time__c = DateTime.newInstance(2014, 08, 19, 8, 0, 0);
        cir.Sat_PH_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sat_PH_Start_Time__c = DateTime.newInstance(2014, 08, 18, 8, 0, 0);
        cir.Sun_End_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        cir.Sun_Start_Time__c = DateTime.newInstance(2014, 08, 18, 17, 0, 0);
        database.insert(cir);
         
         ComplaintMagazineController compmagctrl = new ComplaintMagazineController();
             compmagctrl.getCase();
             //compmagctrl.ComplaintMagazineController();
             compmagctrl.CustomController();
             compmagctrl.save();
             compmagctrl.cancel();
     
     }
     
}