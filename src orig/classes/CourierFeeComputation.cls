/**
 * Class Name: CourierFeeComputation
 * @author: Kristine Campang
 * Date: 10/30/2014
 * Requirement/Project Name: Singapore Press Holdings
 * @description Class that computes for the courier fee in Complaint NewsPaper
 *
 */
public class CourierFeeComputation{
    
    //variable declaration
    Decimal courierFee = 0;
    String dayOfWeek;
    
    public Decimal computeCourierFee(Date replaceFromDate, Date replaceToDate){

        for(replaceFromDate= replaceFromDate; replaceFromDate<= replaceToDate; replaceFromDate= replaceFromDate.addDays(1)) {
                dayOfWeek = ((DateTime)replaceFromDate).format('EEE');
                //gets Courier Fee
                 courierFee += ConstantsSLB.getCourierFee(dayOfWeek);       
        }
        
        return courierFee;
    }
}