public class ArmsInvoiceCsvController {
    public String fullCsv {get;set;}
    public ArmsInvoiceCsvController() {
        List<Account> acclist = [Select id,name , CreatedDate , lastModifiedDate from Account limit 10];
        string header = 'Record Id, Name , Created Date, Modified Date \n';
        string finalstr = header;
        for(Account a: acclist){
           string recordString = a.id+','+a.Name+','+a.CreatedDate+','+a.LastModifiedDate +'\n';
           finalstr = finalstr +recordString;
        }
        //fullCsv = finalstr;
        
        //calloutARMS.genInvoice(finalstr); //<---this is for callout to ARMS       
    }
}