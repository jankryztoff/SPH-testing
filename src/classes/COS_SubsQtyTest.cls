/**
* Class Name: COS_SubsQtyTest
* @author: George Santos
* Date: 2/13/2015
* Requirement/Project Name: SPH
* @description: Test Class for COS_SubsQty
*/

@isTest(seeAllData = True)
public with sharing class COS_SubsQtyTest {
	
	static testmethod void test(){
		
		test.startTest();
		COS_SubsQty sub = new COS_SubsQty();
		sub.getResponse();
		COS_SubsQty.updateZuoraSubFields('aaaaaaa', '100');
	    test.stopTest();
	}

}