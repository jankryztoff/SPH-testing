/*
 * Class Name: <NumberToWord_Test>
 * @author: <Joyrem Zarmaine D. Ayuman>
 * Date: <7/15/2015>
 * Requirement/Project Name: <SPH>
 * @description<Test Class for NumberToWord>
 */
 
@isTest(SeeAllData=true)

public class NumberToWord_Test

    {
    
        static testmethod void testmethod1(){
        
           NumberToWord.convert_nn(101);
           NumberToWord.convert_nn(100);
           NumberToWord.convert_nnn(2);
           NumberToWord.convert_nnn(100);           
           NumberToword.english_number(1010.00);
           
           
           }
           
    }