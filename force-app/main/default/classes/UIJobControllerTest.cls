
@isTest
public without sharing class UIJobControllerTest {
              
    @isTest
    static void testUIJobController() {  
        String recordIdStr ='TestRecordId';
        String metaDataNameStr ='Test_Job';
        String lastString ='';
        UIJobTaskAbstract.ResultWrapper result = new UIJobTaskAbstract.ResultWrapper();
        UI_Job_Status__c jobStatus;
        UIJobController.initPage(recordIdStr, metaDataNameStr);
        
        Id successTaskId = [select id from UI_Task_Configuration__mdt Where DeveloperName = 'Test_Success_Sync'][0].id;
        Id failTaskId = [select id from UI_Task_Configuration__mdt Where DeveloperName = 'Test_Fail_Sync'][0].id;
        
        Id taskId = successTaskId;

        UIJobController.startTask(recordIdStr,taskId);
        jobStatus =[Select Id,Task_Configuration_Id__c,Request_Id__c,Status__c,Error_Message__c from UI_Job_Status__c where Request_Id__c =:recordIdStr][0];  
        System.AssertEquals('In Progress', jobStatus.Status__c , 'After Starting a Task,the status of Job is In Progress');

        UIJobController.endTask(recordIdStr,taskId,'');
        jobStatus =[Select Id,Task_Configuration_Id__c,Request_Id__c,Status__c,Error_Message__c from UI_Job_Status__c where Request_Id__c =:recordIdStr][0];  
        System.AssertEquals('In Progress', jobStatus.Status__c , 'No Error. The status of Job is In Progress');
        System.AssertEquals(taskId, jobStatus.Task_Configuration_Id__c , 'Task Id Should be set');
        
        UIJobController.endTask(recordIdStr,taskId,'Error Message');
        jobStatus =[Select Id,Task_Configuration_Id__c,Request_Id__c,Status__c,Error_Message__c from UI_Job_Status__c where Request_Id__c =:recordIdStr][0];  
        System.AssertEquals('Failed', jobStatus.Status__c , 'Error. The status of Job is Failed');
        System.AssertEquals('Error Message', jobStatus.Error_Message__c , 'Error Message should be set.'); 


        UIJobController.endSuccessJob( recordIdStr,successTaskId);
        jobStatus =[Select Id,Task_Configuration_Id__c,Request_Id__c,Status__c,Error_Message__c from UI_Job_Status__c where Request_Id__c =:recordIdStr][0];  

        System.AssertEquals('Success', jobStatus.Status__c , 'End Job is called, The status of job should be Success.');
        System.AssertEquals(true, String.isEmpty(jobStatus.Error_Message__c) , 'Error Message should be reset.');

        result = UIJobController.runServerTask(recordIdStr,successTaskId,'',true,lastString,false);
        result = UIJobController.runServerTask(recordIdStr,failTaskId,'',true,lastString,false);
        
        AsyncApexJob aaj;
        Test.startTest();
            result =  UIJobController.runQueueableServerTask(recordIdStr, metaDataNameStr,taskid,'',lastString);
            aaj =  UIJobController.checkQueueableStatus(result.JobId,recordIdStr,taskid);
            System.AssertEquals('Queued', aaj.Status , 'Job will be queued');
            jobStatus =[Select Id,Task_Configuration_Id__c,Request_Id__c,Status__c,Error_Message__c from UI_Job_Status__c where Request_Id__c =:recordIdStr][0];  
            System.AssertEquals('In Progress', jobStatus.Status__c , 'Error. The status of Job is In Progress');
            
        Test.stopTest();   
        aaj =  UIJobController.checkQueueableStatus(result.JobId,recordIdStr,taskid);  
        System.AssertEquals('Completed', aaj.Status , 'Job will be Completed');
        jobStatus =[Select Id,Task_Configuration_Id__c,Request_Id__c,Status__c,Error_Message__c from UI_Job_Status__c where Request_Id__c =:recordIdStr][0];  
        System.AssertEquals('In Progress', jobStatus.Status__c , 'No Error. The status of Job is In Progress');

            
    }
    @isTest
    static void testUIJobControllerQueueError() {  
        String recordIdStr ='TestRecordId';
        String metaDataNameStr ='Test_Job';
        String lastString ='';
        UI_Job_Status__c jobStatus;
        UIJobTaskAbstract.ResultWrapper result = new UIJobTaskAbstract.ResultWrapper();
        UIJobController.initPage(recordIdStr, metaDataNameStr);
        
        Id failTaskId = [select id from UI_Task_Configuration__mdt Where DeveloperName = 'Test_Fail_Sync'][0].id;
        AsyncApexJob aaj;
        try{
            Test.startTest();
                result = UIJobController.runQueueableServerTask(recordIdStr, metaDataNameStr,failTaskId,'',lastString);
                aaj =  UIJobController.checkQueueableStatus(result.JobId,recordIdStr,failTaskId);
                System.AssertEquals('Queued', aaj.Status , 'Job will be queued');
                jobStatus =[Select Id,Task_Configuration_Id__c,Request_Id__c,Status__c,Error_Message__c from UI_Job_Status__c where Request_Id__c =:recordIdStr][0];  
                System.AssertEquals('In Progress', jobStatus.Status__c , 'The status of Job is In Progress');          
            Test.stopTest();   
        }catch(Exception e)
        {
            System.assert(true,'Error Case');
        }

       
            
    }
}