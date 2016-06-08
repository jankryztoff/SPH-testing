global class InvoiceLineItemRetrieveCallOutScheduler implements Schedulable {

    global void execute(SchedulableContext SC) {
        InvoiceLineItemRetrieveCallOut invLineItemCallOut = new InvoiceLineItemRetrieveCallOut();
        invLineItemCallOut.retrieveInvoiceLineItem();  
    }
}