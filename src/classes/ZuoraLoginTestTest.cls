@isTest
public class ZuoraLoginTestTest {

    static testMethod void testZuoraLogin() {
        try
        {
            new ZuoraLoginTest();
        }catch(exception e) {
            system.debug(':::ERROR ' + e);
        }
        
    }
}