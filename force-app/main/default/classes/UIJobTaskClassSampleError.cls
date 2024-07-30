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
            if(Schema.sObjectType.Account.isCreateable() &&
            Schema.sObjectType.Account.fields.name.isCreateable())
            {
                for(integer i=0 ; i< 100; i++)
                {
                    String nameStr = 'Test '+ i;
                    accList.add( new Account(Name=nameStr));
                }
                insert accList;
            }
            raiseError('Error After Insert');
            return successResult();          
    }
  
}