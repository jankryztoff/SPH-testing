/**
* Class Name: MyClass
* @author: April Veloso
* Date: 07/16/2015
* @Description: This is the test class for MyClass
*
*/
@isTest(SeeAllData=true)
public class MyClassTest{

    static testMethod void testMClass(){
        
        MyClass testNew = new MyClass ();
        MyClass.myMethod();
    
    }
}