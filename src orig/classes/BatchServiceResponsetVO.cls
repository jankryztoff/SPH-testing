public class BatchServiceResponsetVO{

        /*String BatchAPIFunction = null;*/
        public Map<String, Object> reqValueObject = null;
        
        public Map<String, Object> getReqValueObject(){
            return this.reqValueObject;        
        }
        
        /*public String getBatchAPIFunction(){
            return this.BatchAPIFunction;
        }*/
               
        public BatchServiceResponsetVO(Map<String, String> reqValueObject, String BatchAPIFunction){
            this.reqValueObject = reqValueObject;   
            /*this.BatchAPIFunction = BatchAPIFunction;    */
        }
}