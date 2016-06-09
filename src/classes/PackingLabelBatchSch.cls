/*Name: e.g. trigger name/ class name
Author: SPH (karthick)
Created Date:
Description: Schduler class to generate packing label cover sheet.
History: SPH (karthick) 25/04/2016 [Governor limit issue.]
*/

global class PackingLabelBatchSch Implements Schedulable
            {
            
                    public date dtissue;
                
                       global void execute(SchedulableContext sc)
                        {
                                    sendmail();
                        }
                        public void sendmail()
                        {
                                    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                                    Blob body;
                                    list<Blob> bodylist = new list<Blob>();
                                    
                                    
                                    //Start [UD-4725] [Karthick] [25-04-2016]:Added limit to soql
                                    Date CrDate = [select Batch_Run_Date__c from CMIS_POP_Packing_label_Batch__c order by Batch_Run_Date__c desc limit 1][0].Batch_Run_Date__c;
                                    AggregateResult[] groupedResults
                                                              = [select Publication_Issue_Date__c from CMIS_POP_Packing_label_Batch__c 
                                                                 Where Batch_Run_Date__c = :CrDate group by Publication_Issue_Date__c];
                                     //END [UD-4725] [Karthick] [[25-04-2016]
                                     
                                     for(AggregateResult ar : groupedResults)
                                     {
                                        dtissue = Date.ValueOf(ar.get('Publication_Issue_Date__c'));
                                         try {

                                         PageReference pdf = new PageReference('/apex/PackingLabelCoverSheetpage?d='+dtissue);

                                          body = pdf.getContent();
                                          system.debug('fffff' + body);
                                          Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                                          efa.setContentType('application/pdf');
                                          efa.setFileName('PackingLabelBatchCoverSheet.pdf');
                                          efa.setBody(body);
                                          efa.setInline(false);
                                          fileAttachments.add(efa);
                                          
                                          // need to pass unit test -- current bug  
                                    } catch (VisualforceException e) {
                                      body = Blob.valueOf('Batch failed');
                                    }
                                         
                                     }
                                    
                                   
                                    
                                   
                                   packinglabebatch__c mc = packinglabebatch__c.getValues('Packing1');
                                    
                                    string stemail =  String.valueOf(mc.get('ToEmailID__c'));
                                    
                                    
                                    /*Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                                    attach.setContentType('application/pdf');
                                    attach.setFileName('PackingLabelBatchCoverSheet.pdf');
                                    attach.setInline(false);
                                    attach.Body = body;*/
                                    
                                    
                        
                                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                    string [] toaddress= New string[]{stemail};
                                    email.setSubject('Packing Label Batch Cover Sheet');
                                    email.setPlainTextBody('Please find the file attached');
                                    email.setToAddresses(toaddress);
                                    
                                    
                                     
                
                                    
                                    
                                    //email.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
                                    email.setFileAttachments(fileAttachments);
                                    
                                    Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});
                        }
            }