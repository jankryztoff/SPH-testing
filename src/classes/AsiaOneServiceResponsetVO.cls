public class AsiaOneServiceResponsetVO{

        /*String asia1APIFunction = null;*/
        public Map<String, Object> reqValueObject = null;
        
        public Map<String, Object> getReqValueObject(){
            return this.reqValueObject;        
        }
        
        /*public String getasia1APIFunction(){
            return this.asia1APIFunction;
        }*/
               
        public AsiaOneServiceResponsetVO(Map<String, String> reqValueObject, String asia1APIFunction){
            this.reqValueObject = reqValueObject;   
            /*this.asia1APIFunction = asia1APIFunction;    */
        }
}