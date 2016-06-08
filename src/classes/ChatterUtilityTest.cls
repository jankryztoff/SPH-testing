@isTest(SeeAllData=True)
private class ChatterUtilityTest{
     static testmethod void testChatterUtility(){
         test.startTest();
         try{
         HTTPResponse res = ChatterUtility.addMentionComment('','','','');
         test.stopTest();
         }
         catch(Exception e){}
     }
}