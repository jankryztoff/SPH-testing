@isTest
public class StartSubscriptionServiceMock implements HttpCalloutMock {
	public class StartSubscriptionServiceResponse {
            public String svc_status;
            public String error_code;
            public String error_message = '';
            public String subscriberId;
            public String subscriptionId;
            public String orderid;
            public String accountId;
            public String debug = '';
    }

	public HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HTTPResponse();

		StartSubscriptionServiceResponse subServRes = new StartSubscriptionServiceResponse();
		subservRes.svc_status = '';
        String JSONStr = JSON.serializePretty(subServRes);
		res.setHeader('Content-Type', 'application/json');
        res.setBody(JSONStr);
        res.setStatusCode(200);

        return res;
	}
}
/*
@isTest
public class SingleRequestMock implements HttpCalloutMock {
		protected Integer code;
		protected String status;
		protected String bodyAsString;
		protected Blob bodyAsBlob;
		protected Map<String, String> responseHeaders;

		public SingleRequestMock(Integer code, String status, String body,
                                         Map<String, String> responseHeaders) {
			this.code = code;
			this.status = status;
			this.bodyAsString = body;
			this.bodyAsBlob = null;
			this.responseHeaders = responseHeaders;
		}

		public SingleRequestMock(Integer code, String status, Blob body,
                                         Map<String, String> responseHeaders) {
			this.code = code;
			this.status = status;
			this.bodyAsBlob = body;
			this.bodyAsString = null;
			this.responseHeaders = responseHeaders;
		}

	    public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse resp = new HttpResponse();
			resp.setStatusCode(code);
			resp.setStatus(status);
			if (bodyAsBlob != null) {
				resp.setBodyAsBlob(bodyAsBlob);
			} else {
				resp.setBody(bodyAsString);
			}

			if (responseHeaders != null) {
			     for (String key : responseHeaders.keySet()) {
				resp.setHeader(key, responseHeaders.get(key));
			     }
			}
			return resp;
	    }
}*/