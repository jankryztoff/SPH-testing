@isTest
public class ZuoraLoginTest {
    public Zuora.zApi zApiInstance;
    
    public ZuoraLoginTest() {
        zApiInstance = new Zuora.zApi();
        zApiInstance.zlogin(); 
    }
}