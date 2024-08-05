public with sharing class UIJobFlowDemo_Action {

    public class RequestParameters {
        @InvocableVariable(label = 'Last Id' description = 'The Last Id of the previous query' required=false)
        public string lastString;
        @InvocableVariable(label = 'No of Records' description = 'No of record to be retrieved' required=true)
        public integer noOfRecords;
       
    }
    public class ResponseParameters {
        @InvocableVariable(label = 'List Of Records' description = 'List of Records' required=true)
        public List<sObject> listOfRecords;
           
    }
    @InvocableMethod(callout = true label ='Retrieve Demo Accounts with limit' category = 'Utility')
    public static List<ResponseParameters> retrieveRecordWithLimit(List<RequestParameters> listOfreqParam){ 
        RequestParameters reqParam =listOfreqParam[0];
        String lastString = reqParam.lastString;
        Integer noOfRecord = reqParam.noOfRecords;
        
        String soqlStr = 'Select Id,Name from Account';
        String condStr = ' Where ';
        if(String.isNotEmpty(lastString))
        {
            condStr += ' Id > :lastString AND ';  
        }
        condStr += ' name like \'LWC Orchestration Test Account%\'';
        System.debug(loggingLevel.debug, soqlStr);
        System.debug(loggingLevel.debug, condStr);
        soqlStr += condStr +  ' Order by Id limit ' +noOfRecord ;
        
        ResponseParameters result = new ResponseParameters();
        result.listOfRecords = Database.query(soqlStr);
        return new List<ResponseParameters>{result};
    } 
    
}