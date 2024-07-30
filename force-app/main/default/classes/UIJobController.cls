/**
 * @description       : UI Job Controller Class
 * @group             : 
 * @last modified on  : 25-09-2023
**/
@SuppressWarnings('PMD.EagerlyLoadedDescribeSObjectResult')
public with sharing class UIJobController {
    /**
    * @description 
    * type Class Wrapper
    **/
    Public class DataWrapper{
        /**
        * @description 
        * type List<String> 
        **/
        @AuraEnabled
        public String titleLabel{get;set;}
        /**
        * @description 
        * type List<String> 
        **/
  
        @AuraEnabled
        public List<UITask> tasks{get;set;}

    }

    Public class UITask{
        /**
        * @description 
        * label  
        **/
        @AuraEnabled
        public String uiJobId{get;set;}
        /**
        * @description 
        * label  
        **/
        @AuraEnabled
        public String id{get;set;}
        /**
        * @description 
        * label  
        **/
        @AuraEnabled
        public String label{get;set;}
        /**
        * @description 
        * type  
        **/
        @AuraEnabled
        public String type{get;set;}
        /**
        * @description 
        * className  
        **/
        @AuraEnabled
        public String className{get;set;}
        /**
        * @description 
        * result  
        **/
        @AuraEnabled
        public String result{get;set;}

        /**
        * @description 
        * errorMessage  
        **/
        @AuraEnabled
        public String errorMessage{get;set;}
        /**
        * @description 
        * subTasks 
        **/
        @AuraEnabled
        public List<UITask> subTasks{get;set;}
    } 

    /**
    * @description initPage initialize UI Job LWC
    * @param recordIdStr 
    * @param metaDataNameStr 
    * @return DataWrapper 
    **/
    @AuraEnabled
    public static DataWrapper initPage(String recordIdStr, String metaDataNameStr){  
        recordIdStr = String.escapeSingleQuotes(recordIdStr);
        metaDataNameStr = String.escapeSingleQuotes(metaDataNameStr);
        List<UITask> tasks = new List<UITask>();
        Map<Id,List<UI_Task_Configuration__mdt>> subTaskMap =getSubTaskMap( metaDataNameStr);
        //Get Plan Target Configuration 
       UI_Job_Configuration__mdt parConf =getJobConfig( metaDataNameStr);
       if(parConf != null)
       {
            
            for(UI_Task_Configuration__mdt tskconf : parConf.UI_Tasks__r)
            {
                UITask task = new UITask();
                task.id = tskconf.Id;
                task.uiJobId = parConf.Id;
                task.type = tskconf.Type__c;
                task.label = tskconf.label;
                task.result = 'Not Started';
                task.errorMessage = '';             
                if(task.type == 'Parellel')
                {
                    List<UI_Task_Configuration__mdt> listOfsubTasks = subTaskMap.get(tskconf.Parellel_Job__c);
                    if(listOfsubTasks.isEmpty())
                    {
                        raiseError('The Parellel Task (' + tskconf.label+ ') has no subtasks.' );
                    }
                    List<UITask> subTasks = new List<UITask>();           
                    for( UI_Task_Configuration__mdt subTaskconf: listOfsubTasks)
                    {
                        UITask subtask = new UITask();
                        subtask.Id = subTaskconf.Id;
                        subtask.uiJobId = parConf.Id;
                        subtask.type = subTaskconf.Type__c;
                        subtask.label = subTaskconf.label;
                        subtask.result = 'Not Started';                        
                        subtask.errorMessage = '';  
                        subTasks.add(subtask);
                    }    
                    task.subTasks = subTasks;   
                }
                tasks.add(task);
            }
        
        }
        DataWrapper dataWrapper = new DataWrapper();
        dataWrapper.titleLabel =parConf.label;
        dataWrapper.tasks = tasks;
        return dataWrapper;
    } 
    /**
    * @description get UI Job configuration
    * @param metaDataNameStr 
    * @return UI_Job_Configuration__mdt 
    **/
    public static UI_Job_Configuration__mdt getJobConfig(String metaDataNameStr)
    {
        metaDataNameStr = String.escapeSingleQuotes(metaDataNameStr);

        List<UI_Job_Configuration__mdt> listOfJobConf = [SELECT  Id,Label,DeveloperName ,ClassNames__c,
        Parameter_String_1__c,Parameter_String_2__c,Parameter_String_3__c,
        (SELECT  Id,Label,DeveloperName,ClassNames__c,Type__c,Sequence__c,Parellel_Job__c 
        FROM UI_Tasks__r 
        ORDER BY Sequence__c ASC) 
        FROM UI_Job_Configuration__mdt 
        WHERE DeveloperName =:metaDataNameStr WITH SYSTEM_MODE];
        if(listOfJobConf.isEmpty())
        {
            raiseError( ' UI Job Configuration ('+ metaDataNameStr+') is not existing.' );
            
        }else
        {
            return listOfJobConf[0];
        }
        return new UI_Job_Configuration__mdt();

               
    }
    /**
    * @description get UI Job configuration
    * @param metaDataNameStr 
    * @return UI_Job_Configuration__mdt 
    **/
    public static Map<Id,List<UI_Task_Configuration__mdt>> getSubTaskMap(String metaDataNameStr)
    {
        
        Map<Id,List<UI_Task_Configuration__mdt>> subTaskMap = new Map<Id,List<UI_Task_Configuration__mdt>>();
        set<Id>  pallelJobIdList= new set<Id>();
        for(UI_Task_Configuration__mdt subjob : [SELECT  Parellel_Job__c,Label 
                                FROM UI_Task_Configuration__mdt 
                                Where UI_Job__r.DeveloperName =:metaDataNameStr
                                And Parellel_Job__c  != null
                                With SYSTEM_MODE])
        {
            pallelJobIdList.add(subjob.Parellel_Job__c);
        }
        for(UI_Job_Configuration__mdt palljab : [SELECT  Id,Label,DeveloperName ,
                    (SELECT  Id,Label,DeveloperName,ClassNames__c,Type__c,Sequence__c ,Parellel_Job__c
                    FROM UI_Tasks__r) 
                FROM UI_Job_Configuration__mdt 
                WHERE Id in  :pallelJobIdList
                With SYSTEM_MODE])
        {
            List<UI_Task_Configuration__mdt> subtasks= new List<UI_Task_Configuration__mdt>();
            for(UI_Task_Configuration__mdt subtask : palljab.UI_Tasks__r)
            {
                subtasks.add(subtask);
            }

            subTaskMap.put(palljab.Id, subtasks);
        }
        return subTaskMap;
    }
    /**
    * @description get UI Task configuration
    * @param taskId 
    * @return UI_Task_Configuration__mdt 
    **/    
    public static UI_Task_Configuration__mdt getTaskConfig(String taskId)
    {
        List<UI_Task_Configuration__mdt> listOfTaskConf = [SELECT  Id,Label,DeveloperName,ClassNames__c,Type__c,Sequence__c,
        Parameter_String_1__c,Parameter_String_2__c,Parameter_String_3__c,
        UI_Job__r.ClassNames__c,UI_Job__r.Parameter_String_1__c,UI_Job__r.Parameter_String_2__c,UI_Job__r.Parameter_String_3__c        
                FROM UI_Task_Configuration__mdt where id = :taskId 
        ];

        if(listOfTaskConf.isEmpty())
        {
            raiseError( 'The Task Configuration ('+ taskId+') is not existing.' );
            
        }else
        {
            return listOfTaskConf[0];
        }
        return new UI_Task_Configuration__mdt();


    }
    /**
    * @description startJob
    * @param recordIdStr 
    * @param metaDataNameStr 
    **/
    @AuraEnabled
    public static void endSuccessJob(String recordIdStr,Id taskId){
        recordIdStr = String.escapeSingleQuotes(recordIdStr);
        taskId = String.escapeSingleQuotes(taskId);
        String status ='Success';
        String errorMessage ='';
 
        UI_Task_Configuration__mdt taskConfig = getTaskConfig( taskId);     
        UIJobTaskAbstract.ResultWrapper result = runTaskClass(taskconfig,recordIdStr,'','',true);    
        if(!result.isSuccess)
        {
           status ='Failed';
           errorMessage += result.message;
        }    
        if(Test.isRunningTest())
        {
            if(Schema.sObjectType.UI_Job_Status__c.isCreateable() && Schema.sObjectType.UI_Job_Status__c.isUpdateable() )
            {
                Database.Upsert(new UI_Job_Status__c(Request_Id__c=recordIdStr,Status__c=status,Error_Message__c =errorMessage),UI_Job_Status__c.Request_Id__c,true,AccessLevel.SYSTEM_MODE);
            }
        }
        //delete([Select id from UI_Job_Status__c where Request_Id__c=:recordIdStr]);
    }
    /**
    * @description startTask
    * @param sobjectList 
    * @param taskId 
    **/
    @AuraEnabled
    public static void startTask(String recordIdStr,String taskId){
        recordIdStr = String.escapeSingleQuotes(recordIdStr);
        taskId = String.escapeSingleQuotes(taskId);
        if(Test.isRunningTest())
        {
            String inProgStatus = 'In Progress';
            String errorMessage='';


            if(Schema.sObjectType.UI_Job_Status__c.isCreateable() && Schema.sObjectType.UI_Job_Status__c.isUpdateable() )
            {
                Database.Upsert(new UI_Job_Status__c(Task_Configuration_Id__c=taskid,Request_Id__c=recordIdStr,Status__c=inProgStatus,Error_Message__c=errorMessage),UI_Job_Status__c.Request_Id__c,true,AccessLevel.SYSTEM_MODE);
            }
        }
    }
     /**
    * @description endTask
    * @param recordIdStr 
    * @param taskId 
    * @param ErrorMessage 
    **/
    @AuraEnabled
    public static void endTask(String recordIdStr,String taskId,String errorMessage){   
        recordIdStr = String.escapeSingleQuotes(recordIdStr);
        taskId = String.escapeSingleQuotes(taskId);
        errorMessage = String.escapeSingleQuotes(errorMessage);

        String status ='In Progress';
        if(String.isNotEmpty(errorMessage))
        {
            errorMessage = errorMessage.left(255);
            status = 'Failed';     
            UI_Task_Configuration__mdt taskConfig = getTaskConfig( taskId);     
            UIJobTaskAbstract.ResultWrapper result = runTaskClass(taskconfig,recordIdStr,'','',true,errorMessage);    
            if(!result.isSuccess)
            {
                errorMessage += '   ' + result.message;
            }    
        }
        if(Test.isRunningTest())
        {
            recordIdStr = String.escapeSingleQuotes(recordIdStr);
            taskId = String.escapeSingleQuotes(taskId);
            if(Schema.sObjectType.UI_Job_Status__c.isCreateable() && Schema.sObjectType.UI_Job_Status__c.isUpdateable())
            {
                Database.Upsert(new UI_Job_Status__c(Task_Configuration_Id__c=taskid,Request_Id__c=recordIdStr,Status__c=status,Error_Message__c =ErrorMessage), UI_Job_Status__c.Request_Id__c,true,AccessLevel.SYSTEM_MODE);
            }
        }
    }
     /**
    * @description checkQueueableStatus
    * @param jobId 
    **/
    @AuraEnabled
    public static AsyncApexJob checkQueueableStatus(String jobId,String recordIdStr,Id taskid){
        AsyncApexJob jobInfo = new AsyncApexJob();
        taskId = String.escapeSingleQuotes(taskId);
        recordIdStr = String.escapeSingleQuotes(recordIdStr);
        jobId = String.escapeSingleQuotes(jobId);
        List<AsyncApexJob> jobInfoList = [SELECT Status,ExtendedStatus FROM AsyncApexJob WHERE Id=:jobID with SYSTEM_MODE];
        if(!jobInfoList.isEmpty())
        {
            jobInfo = jobInfoList[0];
    
            if (jobInfo.Status =='Completed' || jobInfo.Status =='Aborted' || jobInfo.Status =='Failed') {
                String message = '';
                if( jobInfo.Status =='Aborted' || jobInfo.Status =='Failed') {  
                    message = jobInfo.ExtendedStatus;                  
                    if(String.isEmpty(message))
                    {
                        message = jobId + ' is Failed';
                    }           
                }
                endTask(recordIdStr,taskid,message); 
            }
        }
        return jobInfo;
    }

  /**
    * @description runQueueableServerTask
    * @param recordIdStr 
    * @param metaDataNameStr 
    * @param taskClassName 
    * @param inputJSON    
    * @return UIJobTaskAbstract.ResultWrapper 
    **/
    @AuraEnabled
    public static UIJobTaskAbstract.ResultWrapper runQueueableServerTask(String recordIdStr, String metaDataNameStr,
    Id taskid,String inputJSON,String lastString){
        recordIdStr = String.escapeSingleQuotes(recordIdStr);
        taskId = String.escapeSingleQuotes(taskId);
        metaDataNameStr = String.escapeSingleQuotes(metaDataNameStr);
        lastString = String.escapeSingleQuotes(lastString);
        UI_Task_Configuration__mdt taskConfig = getTaskConfig( taskId);
        String taskClassName = taskConfig.ClassNames__c;

        try{
            startTask(recordIdStr,taskId);
            Id jobId = null;     
            jobID = System.enqueueJob(new UIJobTaskQueueable(recordIdStr, metaDataNameStr,taskid,inputJSON, lastString) );
            UIJobTaskAbstract.ResultWrapper result = new  UIJobTaskAbstract.ResultWrapper();
            result.jobId =jobID;
            result.isSuccess = true;
            result.message ='';
            return result;
        }catch(Exception objException){
            UIJobTaskAbstract.ResultWrapper result = new UIJobTaskAbstract.ResultWrapper();
            result.isSuccess = false;
            result.message = objException.getMessage();
            endTask(recordIdStr,taskId,result.message);
            return result;
        }   
    }
    /**
    * @description runServerTask
    * @param recordIdStr 
    * @param taskClassName 
    * @param inputJSON    
    * @return UIJobTaskAbstract.ResultWrapper 
    **/
    @AuraEnabled
    public static UIJobTaskAbstract.ResultWrapper runServerTask(String recordIdStr,Id taskId,String inputJSON ,
    Boolean isStart,String lastString,Boolean isSub){
        recordIdStr = String.escapeSingleQuotes(recordIdStr);
        taskId = String.escapeSingleQuotes(taskId);
        lastString = String.escapeSingleQuotes(lastString);
        UI_Task_Configuration__mdt taskConfig = getTaskConfig( taskId);
        UIJobTaskAbstract.ResultWrapper result = new UIJobTaskAbstract.ResultWrapper();
        System.debug(LoggingLevel.DEBUG,'Task :  ' +  taskConfig.label + ' Start ' + taskConfig.ClassNames__c + ' lastString ' + lastString);
        if(isStart)
        {
            startTask(recordIdStr,taskId);
        } 
        Savepoint sp = Database.setSavepoint();     
        try{
            result = runTaskClass(taskconfig,recordIdStr,inputJSON,lastString,false);
        }catch(Exception objException){
            Database.rollback(sp);     
            result.isSuccess = false;
            result.message = objException.getMessage();       
        }finally
        {
            if(!isSub)
            {
                if( result.isSuccess)
                {
                    endTask(recordIdStr,taskId,'');
                }else
                {
                    endTask(recordIdStr,taskId,result.message);
                }
            }
            return result;
        }  
        return result; 
    }
    public static UIJobTaskAbstract.ResultWrapper runTaskClass(UI_Task_Configuration__mdt taskconfig,String recordIdStr,String inputJSON,String lastString,boolean isFinal)
    {
        return runTaskClass(taskconfig,recordIdStr,inputJSON,lastString,isFinal,'');
    }
    /**
    * @description getTaskClassInstance
    * @param taskconfig  
    * @return UIJobTaskAbstract Instance of TaskClass 
    **/
    public static UIJobTaskAbstract.ResultWrapper runTaskClass(UI_Task_Configuration__mdt taskconfig,String recordIdStr,String inputJSON,
    String lastString,boolean isFinal,String errorMessage)
    {
        UIJobTaskAbstract.ResultWrapper result = new UIJobTaskAbstract.ResultWrapper();
        sObject taskconf = taskconfig;
        if(isFinal)
        {
            System.debug(LoggingLevel.debug,'It is Final Task :' + taskconf);
            System.debug(LoggingLevel.debug,'It is Final Task :' + taskconfig.UI_Job__r.ClassNames__c);
            if(String.isNotEmpty(taskconfig.UI_Job__r.ClassNames__c ))
            {
                taskconf =  taskconfig.UI_Job__r;
                System.debug(LoggingLevel.debug,'There are Final Task :' + taskconf);
            }else
            {
                result.isSuccess = true;
                result.message ='';
                return result;
            }
        }
        String taskClassName = (String)taskconf.get('ClassNames__c');
        Type taskClassType;
        UIJobTaskAbstract taskClass;
        try{
            taskClassType = Type.forName(taskClassName);
            taskClass = (UIJobTaskAbstract)taskClassType.newInstance();
        }catch(Exception e)
        {
            raiseError(taskClassName + ' is not able to instanciated.' );
        }
        if(!isFinal)
        {
            taskClass.taskType = (String)taskconf.get('Type__c');
        }
        taskClass.paramOne = (String)taskconf.get('Parameter_String_1__c');
        taskClass.paramTwo = (String)taskconf.get('Parameter_String_2__c'); 
        taskClass.paramThree = (String)taskconf.get('Parameter_String_3__c'); 
        taskClass.errorMessage = errorMessage;
        taskClass.lastString = lastString;
        result = taskClass.run(recordIdStr,inputJSON);
        if(result.isSuccess)
        {
            //result.message ='';
        }else {
            if(String.isEmpty(result.message))
            {
                result.message ='Task is failed.';
            }
        }
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