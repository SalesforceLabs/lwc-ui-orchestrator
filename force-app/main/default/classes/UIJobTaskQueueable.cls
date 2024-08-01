public class UIJobTaskQueueable implements Queueable {
    private String recordIdStr;
    private String metaDataNameStr;
    private String inputJSON;
    private String lastString;
    private UI_Task_Configuration__mdt taskconfig ;
    private UI_Job_Configuration__mdt jobconfig;

    public UIJobTaskQueueable(String recordIdStrParam, String metaDataNameStrParam,Id taskid,String inputJSONParam,String lastStringParam) {

        jobconfig = UIJobController.getJobConfig(metaDataNameStrParam);
        taskConfig = UIJobController.getTaskConfig( taskId);
        recordIdStr =recordIdStrParam;
        metaDataNameStr =metaDataNameStrParam;
        lastString =lastStringParam;
        inputJSON= inputJSONParam;
    }
    public void execute(QueueableContext context) {
        Savepoint sp = Database.setSavepoint();
        try{
            String taskClassName = taskConfig.ClassNames__c;
            Type taskClassType = Type.forName('',taskClassName);
            if (taskClassType == null)
            {
                taskClassType = Type.forName(taskClassName);
            }
            if(taskClassType == null)
            {
                UIJobTaskAbstract.raiseError(taskClassName + ' is not found.' );
            }
            UIJobTaskAbstract taskClass = (UIJobTaskAbstract)taskClassType.newInstance();
            taskClass.paramOne = taskconfig.Parameter_String_1__c;
            taskClass.paramTwo = taskconfig.Parameter_String_2__c;
            taskClass.paramThree = taskconfig.Parameter_String_3__c;
            taskClass.lastString = lastString;
            UIJobTaskAbstract.ResultWrapper result = taskClass.run(recordIdStr,inputJSON);
            
            if(!result.isSuccess)
            {
                UIJobTaskAbstract.raiseError(result.message);
            }
        }catch(Exception objException){
            Database.rollback(sp);
            throw objException;
        }   
    }
}
