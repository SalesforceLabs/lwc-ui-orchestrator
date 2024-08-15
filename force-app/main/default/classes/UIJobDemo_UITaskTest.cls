
@isTest
public without sharing class UIJobDemo_UITaskTest {
    @TestSetup
    static void setupData(){
        PermissionSet ps =  [select id from PermissionSet where name ='UI_Job'][0];   
        List< PermissionSetAssignment> paList = [Select id from PermissionSetAssignment where  AssigneeId = :UserInfo.getUserId() and  PermissionSetId = :ps.Id];
        if(paList.isEmpty())   
        { 
            insert new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = ps.Id);
        }
    }          
    @isTest
    static void TesUIJobDemo_UITask() {  
        String recordIdStr ='Test';
        String lastString ='';
        String inputJSON = '';
        User u =  [select id from user where Id = :UserInfo.getUserId()][0];   
        system.runas(u)
        {
            UIJobTaskAbstract.ResultWrapper result = new UIJobTaskAbstract.ResultWrapper();
            
            Id syncCreateRecordTaskId = [select id from UI_Task_Configuration__mdt Where DeveloperName = 'Demo_Task_1'][0].id;
            Id chainUpdateTaskId = [select id from UI_Task_Configuration__mdt Where DeveloperName = 'Demo_Task_3'][0].id;
            Id purgeTaskId = [select id from UI_Task_Configuration__mdt Where DeveloperName = 'Demo_Purge_Task'][0].id;
            
            Boolean isStart = true;
            Boolean isSub = false;
            //Sync Task
            result = UIJobController.runServerTask( recordIdStr,syncCreateRecordTaskId, inputJSON , isStart, lastString, isSub);
            List<Account> queryResult = [Select Id from Account where name like 'LWC Orchestration Test Account'];

            System.AssertEquals(140, queryResult.size() , '140 Account need to be created.');
     
        

        
            Test.startTest();
            //Start Chain Task 
                result = UIJobController.runServerTask( recordIdStr,chainUpdateTaskId, result.outputJSON , false, result.lastString, isSub);
                // The chain number and record count should be added into 100 records therefore 49 records will be remaining
                queryResult = [Select Id from Account where name = 'LWC Orchestration Test Account'];
                System.AssertEquals(40, queryResult.size() , 'The chain number and record count should be added into 100 records therefore 49 records will be remaining.');
                System.AssertEquals(false, result.isEnd , 'Not all records has been processed therefore isEnd is false.');
                
                isStart = false;
                result = UIJobController.runServerTask( recordIdStr,chainUpdateTaskId, result.outputJSON , false, result.lastString, isSub);
                queryResult = [Select Id from Account where name = 'LWC Orchestration Test Account'];
                System.AssertEquals(0, queryResult.size() , 'The chain number and record count should be added into 140 records therefore 0 records will be remaining.');
                System.AssertEquals(false, result.isEnd , 'isEnd will be set to true when there is no record for processing.');
        
                isStart = false;
                result = UIJobController.runServerTask( recordIdStr,chainUpdateTaskId, result.outputJSON , false, result.lastString, isSub);
                System.AssertEquals(true, result.isEnd , 'No record are processed isEnd is true.');
                queryResult = [Select Id from Account where name = 'LWC Orchestration Test Account'];
                System.AssertEquals(0, queryResult.size() , 'The chain number and record count should be added into 140 records therefore 0 records will be remaining.');
                queryResult = [Select Id from Account where name like 'LWC Orchestration Test Account%'];
                System.AssertEquals(140, queryResult.size() , 'All records has the chain number and record count as surfix');
            Test.stopTest();
            //Start Purge 
            result = UIJobController.runServerTask( recordIdStr,purgeTaskId, inputJSON , isStart, lastString, isSub);
            queryResult = [Select Id from Account where name like 'LWC Orchestration Test Account%'];
            System.AssertEquals(0, queryResult.size() , '140 Account need to be deleted.');
        }
            
    }
}