/**
 * @description       : Sample class which will be used test for UI Job
 * @group             : 
 * @last modified on  : 25-09-2023
**/
public with sharing class UIJobTaskClassSampleError extends UIJobTaskAbstract{
    /**
     * @description       : Function which will contain logic for Task 
     * @last modified on  :25-09-2023
     * @param recordIdStr - record Id
     * @param inputJSON - input JSON 
     * @return UIJobTaskAbstract.ResultWrapper
    **/
    public override ResultWrapper run(String recordIdStr,String inputJSON)
    {
        
            List<Account> accList = new List<Account>();
            for(integer i=0 ; i< 100; i++)
            {
                accList.add( new Account(Name='Test '+ i));
            }
            insert accList;
            raiseError('Error After Insert');
            return successResult();          
    }
  
}