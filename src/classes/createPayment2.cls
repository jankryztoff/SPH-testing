public class createPayment2{

    public Zuora.zApi zApiInstance;
    public createPayment2()
    {
        zApiInstance = new Zuora.zApi();
        try{
            zApiInstance.zlogin();
        }
        catch(Zuora.zRemoteException ex){
            system.debug('Error:'+ex);
        }
        catch(Zuora.zAPIException ex){
            system.debug('Error:'+ex); 
        }
        catch(Zuora.zForceException ex){
            system.debug('Error:'+ex); 
        } 
    }

    public Map<String,String> createZObject(Map<String,String> objectMap, String obj)
    {
        Map<String,String> resultMap = new Map<String,String>();
        String createdId; 
        try
        { 
            Zuora.zObject zObj = new Zuora.zObject(obj);
            for(String key:objectMap.keyset()) {
                zObj.setValue(key,objectMap.get(key));
            }
            
            List<Zuora.zObject> objs = new List<Zuora.zObject>{zObj};
            List<Zuora.zApi.SaveResult> results = zApiInstance.zcreate(objs);

            for (Zuora.zApi.SaveResult result : results){
                if(result.Success){
                    createdId = result.Id;
                    resultMap.put('Status','Success');
                    resultMap.put('Id',createdId);
                }
            else{
                Zuora.zObject[] errors = result.errors;

                for(Zuora.zObject error : errors) 
                {
                    String errorCode = (String)error.getValue('Code');
                    String message = (String)error.getValue('Message'); 
                    resultMap.put('Status','Failed');
                    resultMap.put('Code',errorCode); 
                    resultMap.put('Message',message);
                }
            }
            }

        }
        catch(Zuora.zRemoteException ex){
            system.debug('Error:'+ex);
        }
        catch(Zuora.zAPIException ex){
            system.debug('Error:'+ex);
        }
        catch(Zuora.zForceException ex) {
            system.debug('Error:'+ex); 
        } 
        return resultMap;
    }
}