/**
 * @description       : interface class for UI Job Task 
 * @group             : 
 * @last modified on  : 25-09-2023
**/
public interface UIJobTaskInterface {
    /**
     * @description       : Function which will contain logic for Task 
     * @last modified on  :25-09-2023
     * @param recordIdStr - record Id
     * @param inputJSON - input JSON 
     * @return UIJobTaskAbstract.ResultWrapper
    **/
    UIJobTaskAbstract.ResultWrapper run(String recordIdStr,String inputJSON);

}