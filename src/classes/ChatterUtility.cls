/*
 * Class Name: ChatterUtility
 * Author: Kevin Evasco
 * Date: 03/23/2014
 * Project/Requirement: Singapore Press Holdings
 *
 * History: 03/23/2015 Kevin Evasco Created Apex Class
 */
 
public class ChatterUtility{

    public static HTTPResponse addMentionComment(String recordId, String userId, String message, String sessionId) {
        String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();         
        String url =  salesforceHost + '/services/data/v26.0/chatter/feeds/record/' + RecordId + '/feed-items';

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(url);
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'OAuth ' + sessionId);
        req.setBody('{ "body" : { "messageSegments" : [ { "type": "mention", "id" : "' + UserId + '" }, { "type": "text",  "text" : "' + ' ' + message +  '" } ] } }');

        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        return res;
    }
}