/**
 * Class Name: PublicationIssueWrapper
 * @author: Joban Bir Singh
 * Date: 05/03/2015
 * Requirement/Project Name: CRSM Project
 * @description: Wrapper class which would contain the data returned by issue calculation method
 *
 */
public class PublicationIssueWrapper{

    public String publication_code;
    public integer weekday_no_of_copies;
    public integer sat_no_of_copies;
    public integer sun_no_of_copies;
    public integer odd_freq_copies;
    //Start: D-0104 UAT Defect JLedesma 3/13/2015 Calculation of year to date days
    public integer current_year_days;
    public integer next_year_days;
    

    public PublicationIssueWrapper(String pubCode, Integer weekdayNoCopies, Integer satNoCopies, Integer sunNoCopies, Integer oddNoCopies, Integer currentYearDays, Integer nextYearDays){
        this.publication_code = pubCode;
        this.weekday_no_of_copies = weekdayNoCopies;
        this.sat_no_of_copies = satNoCopies;
        this.sun_no_of_copies = sunNoCopies;
        this.odd_freq_copies = oddNoCopies;
        this.current_year_days = currentYearDays;
        this.next_year_days = nextYearDays;
    }
    //END: D-0104 UAT Defect 3/13/2015 Calculation of year to date days
}