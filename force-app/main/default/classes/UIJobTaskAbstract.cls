/**
 * @description       : JI Job Task Abstract Class
 * @group             : 
 * @last modified on  : 25-09-2023
**/
global virtual class UIJobTaskAbstract implements UIJobTaskInterface {
    global String paramOne='';
    global String paramTwo='';
    global String paramThree='';
    global String lastString='';
    global String taskType='';
    global String errorMessage='';
 /**
    * @description ResultWrapper
    * type Class Wrapper
    **/
    global class ResultWrapper{
        /**
        * @description 
        * type isSuccess 
        **/
        @AuraEnabled
        global Boolean isSuccess{get;set;}
        /**
        * @description 
        * type message 
        **/
        @AuraEnabled
        global String message{get;set;}
        /**
        * @description 
        * type jobId 
        **/
        @AuraEnabled
        global Id jobId{get;set;}
        /**
        * @description 
        * type outputJSON 
        **/
        @AuraEnabled
        global String outputJSON{get;set;}

        /**
        * @description 
        * type outputJSON 
        **/
        @AuraEnabled
        global boolean isEnd{get;set;}
        /**
        * @description 
        * type outputJSON 
        **/
        @AuraEnabled
        global String lastString{get;set;}
    }
    /**
    * @description run method 
    * @param recordIdStr 
    * @param inputJSON 
    * @return ResultWrapper   
    **/   
    global protected virtual ResultWrapper run(String recordIdStr,String inputJSON){return null;}
    global Map<String,Object> convertJsonToMap(String inputJSON)
    {
        return ( ( Map<String,Object> ) JSON.deserializeUntyped(inputJSON));
    }

    global ResultWrapper successResult()
    {
        return successResult(null);
    }
    global ResultWrapper successResult(String lastId)
    {
        return successResult(lastId,'');
    }
    global ResultWrapper successResult(String lastId,String message)
    {
        ResultWrapper result = new ResultWrapper();
        result.isSuccess = true;
        result.isEnd = false;
        result.message = message;
        if(String.isEmpty(lastId))
        {
            result.isEnd = true;
        }            
        result.lastString = lastId;
        return result;
    }
    /** 
    * @description Exception Class for custom exception
    */  
    global class MyException extends Exception {}
    /** 
    * @description raise custom error based on message
    * @param message error message
    */    
    global static void raiseError(String message)
    {
        throw new MyException(message);
    }  
}