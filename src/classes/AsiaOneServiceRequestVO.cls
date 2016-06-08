public class AsiaOneServiceRequestVO{
        String asia1APIFunction = null;
        Map<String, String> reqValueObject = new Map<String, String>();
        
        public void setReqValueObject(Map<String, String> reqVO){
            this.reqValueObject = reqVO;
        }      
         
        public void setAsia1APIFunction (String asia1APIFunc){
            this.asia1APIFunction = asia1APIFunc;
        }     
    }