global with sharing class UIJobFlow_UITask extends UIJobTaskAbstract{

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
        System.debug(LoggingLevel.Debug,recordIdStr);
        System.debug(LoggingLevel.Debug,inputJSON);
        Map<String,object> inputMap= new Map<String,object>();
        if(String.isNotEmpty(inputJSON))
        {
            inputMap =convertJsonToMap(inputJSON);
        }
        inputMap.put('recordId'      ,recordIdStr);
        inputMap.put('paramOne'         ,paramOne);
        inputMap.put('paramTwo'         ,paramTwo);
        inputMap.put('paramThree'       ,paramThree);
        inputMap.put('lastString'       ,lastString);
      

        Flow.Interview myFlow ;
        try{
            myFlow = Flow.Interview.createInterview(paramOne, inputMap);
        }catch(Exception e)
        {
            myFlow = Flow.Interview.createInterview('lwcorch',paramOne, inputMap);
        }
        myFlow.start();
        lastString = (String)myFlow.getVariableValue('lastString');
        String outputMessage = (String)myFlow.getVariableValue('outputMessage');
        String outputJSON = (String)myFlow.getVariableValue('outputJSON');
        ResultWrapper result=  successResult(lastString,outputMessage);
        if(String.isNotEmpty(outputJSON ))
        {
            result.outputJSON = outputJSON;
        }
        return result;
    }
    
}