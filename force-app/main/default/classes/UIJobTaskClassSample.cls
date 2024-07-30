/**
 * @description       : Sample class which will be used test for UI Job
 * @group             : 
 * @last modified on  : 25-09-2023
**/
public with sharing class UIJobTaskClassSample extends UIJobTaskAbstract{
     /**
     * @description       : Function which will contain logic for Task 
     * @last modified on  :25-09-2023
     * @param recordIdStr - record Id
     * @param inputJSON - input JSON 
     * @return UIJobTaskAbstract.ResultWrapper
    **/
    public override ResultWrapper run(String recordIdStr,String inputJSON)
    {    
        /* 
            Parameters from Abstract  Details:

             - paramOne : From Parameter_String_1__c Task Configuration 
             - paramTwo : From Parameter_String_2__c Task Configuration
             - paramThree : From Parameter_String_3__c Task Configuration
             - taskType :  From Type__c Task Configuration
             - lastString : From previous Chain Task Call
             - errorMessage: From previous Chain Task Call
            */

            List<Account> accList = new List<Account>();

            accList.add( new Account(Name='Test'));
            insert accList;
                     
            return successResult();  
            /*
            Different function to return Result (Predefined function)
            - successResult()
            - successResult(string lastString)
            - failureResult(errorMessage)
            - failureResult(string lastString, string errorMessage)
            */
        
    }

}