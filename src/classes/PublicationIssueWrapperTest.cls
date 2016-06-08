/**********************************************************************/
/* Class Name: PublicationIssueWrapperTest 
/* Author: 
/* Description: 
/* Updated By: 
/* Date Last Modified: 
/**********************************************************************/
@isTest(seeAllData = TRUE)

private class PublicationIssueWrapperTest{
    static testmethod void publicationIssueWrapperTest(){
        PublicationIssueWrapper piw = new PublicationIssueWrapper('string', 1, 2, 3, 4, 5, 6);
        system.debug(piw);
    }
}