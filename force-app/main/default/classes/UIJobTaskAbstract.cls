/**
 * @description       : JI Job Task Abstract Class
 * @group             : 
 * @last modified on  : 25-09-2023
**/
public virtual class UIJobTaskAbstract implements UIJobTaskInterface {
    public String paramOne='';
    public String paramTwo='';
    public String paramThree='';
    public String lastString='';
    public String taskType='';
    public String errorMessage='';
 /**
    * @description ResultWrapper
    * type Class Wrapper
    **/
    Public class ResultWrapper{
        /**
        * @description 
        * type isSuccess 
        **/
        @AuraEnabled
        public Boolean isSuccess{get;set;}
        /**
        * @description 
        * type message 
        **/
        @AuraEnabled
        public String message{get;set;}
        /**
        * @description 
        * type jobId 
        **/
        @AuraEnabled
        public Id jobId{get;set;}
        /**
        * @description 
        * type outputJSON 
        **/
        @AuraEnabled
        public String outputJSON{get;set;}

        /**
        * @description 
        * type outputJSON 
        **/
        @AuraEnabled
        public boolean isEnd{get;set;}
        /**
        * @description 
        * type outputJSON 
        **/
        @AuraEnabled
        public String lastString{get;set;}
    }
    /**
    * @description run method 
    * @param recordIdStr 
    * @param inputJSON 
    * @return ResultWrapper   
    **/   
    public protected virtual ResultWrapper run(String recordIdStr,String inputJSON){return null;}
    public Map<String,Object> convertJsonToMap(String inputJSON)
    {
        return ( ( Map<String,Object> ) JSON.deserializeUntyped(inputJSON));
    }

    public ResultWrapper successResult()
    {
        return successResult(null);
    }
    public ResultWrapper successResult(String lastId)
    {
        return successResult(lastId,'');
    }
    public ResultWrapper successResult(String lastId,String message)
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
    public class MyException extends Exception {}
    /** 
    * @description raise custom error based on message
    * @param message error message
    */    
    public static void raiseError(String message)
    {
        throw new MyException(message);
    }  
}