/**
   @Author <Ana Fe Dumangas>
   @name <SP_GenerateLetterPrintBatchMockTest>
   @Description <Test class for SP_GenerateLetterPrintBatch>
   @CreateDate <7/30/15>
   @Version <1.0>
  */

@isTest                         
global class SP_GenerateLetterPrintBatchMockTest implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        Map<String, String> reqBody = new Map<String, String>(); 
        reqBody.put('failedRecordsSet', '["001N000000FXra2IAD"]');
        reqBody.put('recordID_attachmentID_map', '{"001N000000FXra2IAD" : "00PN0000002BLFaMAO"}');
        reqBody.put('recordID_dateOfGeneration_map', '{"001N000000FXra2IAD" : "2015-06-20"}');
        reqBody.put('recordID_filename_map', '{"001N000000FXra2IAD" : "Acknowledgment_Letter_SFID001N000000SU8DnIAL_201579.pdf"}');
        reqBody.put('packLabelRecId_AttachmentID_Map', '{"00PN0000002BLFaMAO" : "001N000000SU8DnIAL"}');
        
        res.setBody(JSON.serialize(reqBody));
        res.setStatusCode(200);
        return res;       
    }
}