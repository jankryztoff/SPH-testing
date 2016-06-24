/**
 * Class Name: ChangeOfParticularsTest
 * @author: Leuwend Job Hapa
 * Date: 01/22/2015
 * Requirement/Project Name: Singapore Press Holdings
 * @description Test class for EshopFetchTempStopDetails
 *
 */

@isTest ( seeAllData = true )
public class EshopFetchTempStopDetailsTest {
    
    static testMethod void myUnitTest() {
        
        EshopFetchTempStopDetails.EshopFetchTempStopDetailsRequest detailsRequest = new EshopFetchTempStopDetails.EshopFetchTempStopDetailsRequest();
        EshopFetchTempStopDetails.TempStopDetails details = new EshopFetchTempStopDetails.TempStopDetails();
        List<EshopFetchTempStopDetails.TempStopDetails> detailsList = new List<EshopFetchTempStopDetails.TempStopDetails>();
        EshopFetchTempStopDetails.EshopFetchTempStopDetailsResponse detailsResponse = new EshopFetchTempStopDetails.EshopFetchTempStopDetailsResponse( detailsList, new ErrorResponseWrapper( '', '', '' ) );
        
        detailsRequest.setSubscriberId( detailsRequest.getSubscriberId() );
        EshopFetchTempStopDetails.fetchTempStopDetails( detailsRequest );
        
        detailsRequest.setSubscriberId( '' );
        EshopFetchTempStopDetails.fetchTempStopDetails( detailsRequest );
        
        detailsRequest.setSubscriberId( 'xxxxxxxxx' );
        EshopFetchTempStopDetails.fetchTempStopDetails( detailsRequest );
        
        List<Zuora__Subscription__c> subscriptions = [ select id, Zuora__Account__r.account_auto_number__c from Zuora__Subscription__c where Zuora__Status__c ='Active' limit 5 ];
        
        for( Zuora__Subscription__c subscription : subscriptions ) {
            detailsRequest.setSubscriberId( subscription.Zuora__Account__r.account_auto_number__c );
            EshopFetchTempStopDetails.fetchTempStopDetails( detailsRequest );   
        }
        
    }

}