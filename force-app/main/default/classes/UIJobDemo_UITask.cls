/**
 * @description       : Sample class which will be used test for UI Job
 * @group             : 
 * @last modified on  : 31-07-2024 Sung Rin Park
**/
public with sharing class UIJobDemo_UITask extends UIJobTaskAbstract{
    /**
    * @description       : Function which will contain logic for Task 
    * @last modified on  : 30-07-2024
    * @param recordIdStr - record Id
    * @param inputJSON - input JSON 
    * @return UIJobTaskAbstract.ResultWrapper
   **/
  public override ResultWrapper run(String recordIdStr,String inputJSON)
  {  
        // Use parmOne (Parameter_String_1__c) in Task Configuration) to make one class can work in different tasks
        switch on paramOne {
          // 1. Purge all Demo data
          when 'purgeData' {
              return purgeData();
          }
          // 2. Create 140 demo account with 140 dml
          // DML in loop to show tasks are running seperately and Orchestrated by UI
          when 'createDemoAccount' {
              return createAccount();
          }
          // 3. Update all demo account for 3 chain tasks (update 100 record per chain task);
          // DML in loop to show tasks are running seperately and Orchestrated by UI
          when 'updateAccountChain' {
              return updateAccountChain(inputJSON);
          }
        }
        return successResult();

    }
    /**
    * @description       : Purge all data 
    * @last modified on  : 30-07-2024
    * @param recordIdStr - record Id
    * @param inputJSON - input JSON 
    * @return UIJobTaskAbstract.ResultWrapper
   **/
    private ResultWrapper purgeData()
    { 

        List<sObject> queryResult = [Select Id from Account where name like 'LWC Orchestration Test Account%'];
        Database.delete(queryResult,true,AccessLevel.SYSTEM_MODE);    
        return  successResult();
    }
    /**
    * @description       : insert 140 accounts . insert dml in loop to run just before hit dml limit . This function doen't follow code best practice. it is created to show how UI task works 
    * @last modified on  : 30-07-2024
    * @return UIJobTaskAbstract.ResultWrapper
   **/
    private ResultWrapper createAccount()
    {    

           List<Account> accList = new List<Account>();
           String nameStr = 'LWC Orchestration Test Account';
           for(integer i=0 ; i< 140; i++)
           {
               insert as system new Account(Name=nameStr);
           }
         
           return successResult();  
   }
    /**
    * @description       : update 100 accounts . update dml in loop . This function doen't follow the code best practice. it is created as purpose to show how Chain task works 
    * @last modified on  : 30-07-2024
    * @param inputJSON - input JSON 
    * @return UIJobTaskAbstract.ResultWrapper
   **/
   private ResultWrapper updateAccountChain(String inputJSON)
   {    

        Map<String,Object> inputMap = new Map<String,Object>();
        integer count = 1;
        integer chainNum = 1;
        if(String.isNotEmpty(inputJSON))
        {
            //Covert Input JSON string into Map using convertJsonToMap function (from Abstract)
            inputMap= convertJsonToMap(inputJSON);
            count = Integer.valueOf(inputMap.get('count'));
            chainNum = Integer.valueOf(inputMap.get('chainNum'));
        }
        List<Account> accList = new List<Account>();
        Id lastId =null ;
        String nameStr = 'LWC Orchestration Test Account';
        for(Account acc : [Select id from account 
                                where name like 'LWC Orchestration Test Account%' 
                                and Id > :lastString 
                                Order by Id limit 100 ])
        {
             lastId = acc.id;
             acc.name = nameStr + ' Chain : ' + String.valueOf(chainNum).leftPad(3, '0')  + ' recordNo : ' + String.valueOf(count).leftPad(3, '0'); 
             update as system acc;
             count +=1;
        }
        chainNum +=1;
        //Set the variable to pass to next chain call.
        inputMap.put('count',count);    
        inputMap.put('chainNum',chainNum);          
        //Add message to show the status of Task
        ResultWrapper result = successResult(lastId,'Data before Id(' + lastId +' ) has been Updated.');
        result.outputJSON= JSON.serialize(inputMap);

        return result;  
    }


   

}
