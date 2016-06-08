public class TestQueueable implements queueable, Database.AllowsCallouts  {
    public void execute(QueueableContext context) {
       System.debug('========> Execute Queueable ...');
        
        //Test Callout
        //ZuoraCallOut zCallout = new ZuoraCallOut();
        //List<Zuora.zObject> lstRecs = zCallout.zquerymoreInvoice('xxx');
        
        // Send GET request to google
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://www.zuora.com');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);

        System.debug('====>' + res.getBody());
        
        //System.debug('========> Call Out Size:' + lstRecs.size());
    }
}