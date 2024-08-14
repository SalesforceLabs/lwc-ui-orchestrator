import { LightningElement, track ,api, wire} from 'lwc';
//lightning confirm popup
import initPlanPage from '@salesforce/apex/UIJobController.initPage';
import runServerTask from '@salesforce/apex/UIJobController.runServerTask';
import runQueueableServerTask from '@salesforce/apex/UIJobController.runQueueableServerTask';
import checkQueueableStatus from '@salesforce/apex/UIJobController.checkQueueableStatus';
import endServerTask from '@salesforce/apex/UIJobController.endTask';
import endSuccessJob from '@salesforce/apex/UIJobController.endSuccessJob';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { RefreshEvent } from "lightning/refresh";
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    subscribe,
    MessageContext
} from 'lightning/messageService';
import callUIJob from '@salesforce/messageChannel/Call_UIJob_Hidden__c';


//import custom label
const columns = [
    { label: 'Task Name', fieldName: 'label' },
    { label: 'Status', fieldName: 'result', type: 'text' },
    { label: 'Message', fieldName: 'errorMessage', type: 'text' }
];
export default class uiJobController extends LightningElement {
    @api recordid;
    @api metadataname;
    @api isdisplaybutton;
    @api flownsucessaction;
    @api isUtility =false;
    @api errormessage;
    @api inputJSON = '';
    @track isLoading = false;
    @track isInProgress = false;
    
    @track tasks = [];
    subscription = null;
    columns = columns;
    inJSON=''
    titleLabel ='UI Job';
    jobCompletionMessage = 'Job is completed sucessfully';

    @wire(MessageContext)
    messageContext;


    // Handler for message received by component
    handleMessage(message) {
        this.recordid = message.recordId;
        this.metadataname = message.metaDataName;
        this.inputJSON = message.inputJSON;
        let ev = new CustomEvent('popUp',{});
        this.dispatchEvent(ev);  
        this.initPage(true);
    }

    connectedCallback(){
        if(!this.isdisplaybutton && (this.flownsucessaction === 'Close' || this.flownsucessaction === 'Next') )
        {
            this.initPage(true);
        }else
        {
            this.initPage();
        }
        if (!this.subscription && this.isUtility) {
            this.subscription = subscribe(
                this.messageContext,
                callUIJob,
                (message) => this.handleMessage(message)
            );
        }
        

    }
    handleException(error,raiseToast)
    {
       
        if(error.body)
        {
            this.errormessage =error.body.message;     
        }else
        {
            this.errormessage = error.message;        
        }
        if(raiseToast)
        {
            this.showToastEvent('Error', this.errormessage , 'error');
        }
    }
    // Initializing Page

    @api initPage(isRunJob){
        if(this.isInProgress)
        {
            this.showToastEvent('Error', 'Another Job is still running.', 'error');
            return;
        }
        this.inJSON = this.inputJSON;
        this.isLoading = true;
        initPlanPage({ recordIdStr: this.recordid,metaDataNameStr : this.metadataname }).then(result => {
            if(result && result.tasks){
                this.titleLabel = result.titleLabel;
                this.tasks = result.tasks;
            }
            this.isInProgress = false;
            this.isLoading = true;
            if(isRunJob)
            {
                this.startJob();
            }
        }).catch(error => {
            this.handleException(error,true);
            this.isInProgress = false;
            this.isLoading = true;
        })
    }
    handleQueueableCall(curSeq,taskid,lastString)
    {
        //Run Class using Queueable call  
        runQueueableServerTask({ recordIdStr: this.recordid,metaDataNameStr : this.metaDataName ,taskid : taskid,lastString :lastString}).then(result => {   
            if(result.isSuccess){
                let jobId = result.jobId;
                //Repeatedly getting Status until Queuable job is finished
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                this.setTimeInterval = setInterval(() => {
                    checkQueueableStatus({ jobId : jobId,recordIdStr: this.recordid,taskid : taskid}).then(batchresult => {  
                        if (batchresult.Status ==='Completed' || batchresult.Status ==='Aborted' || batchresult.Status ==='Failed') {
                            try{
                                    //When job is finished with Abort / Failed status end Task
                                    clearInterval(this.setTimeInterval);
                                    if( batchresult.Status ==='Aborted' || batchresult.Status ==='Failed') {                             
                                        this.endTask(curSeq,'Failed',batchresult.ExtendedStatus);
                                    }else
                                    {
                                        //When job is finished with Completed status, call a next task
                                        this.successTaskEnd(curSeq);
                                        curSeq +=1;
                                        this.startTask(curSeq);
                                    }
                                }catch(error)
                                { 
                                    clearInterval(this.setTimeInterval);
                                    this.endJob(error,taskid);
                                }
                        }
                    }).catch(error => {
                    this.endJob(error,taskid);
                })}, 1000);  
            }
        }).catch(error => {
            this.endJob(error,taskid);
        })
        
    }
    callServerTask(curSeq,subSeq,isStart,isSub)
    {
       
        let taskid          = this.tasks[curSeq].id;
        let lastString      = this.tasks[curSeq].lastString;
        let inputJSON       = this.inJSON;
        if(this.tasks[curSeq].type === 'Chain' && this.tasks[curSeq].inputJSON)
        {
            inputJSON       = this.tasks[curSeq].inputJSON;
        }
        if(this.tasks[curSeq].type === 'Queueable' )
        {
           //Run Class using Queueable call  
           this.handleQueueableCall(curSeq,taskid,lastString);
        }else
        {
            if(this.tasks[curSeq].type === 'Parellel')
            {          
                
                taskid      =  this.tasks[curSeq].subTasks[subSeq].id;
                lastString = this.tasks[curSeq].subTasks[subSeq].lastString;
                if(this.tasks[curSeq].subTasks[subSeq].inputJSON)
                {
                    inputJSON  = this.tasks[curSeq].subTasks[subSeq].inputJSON;
                }
                this.tasks[curSeq].subTasks[subSeq].result = 'In progress';
                this.tasks[curSeq].subTasks[subSeq].class='inprogressRowColor';
            }
            runServerTask({ recordIdStr: this.recordid ,                        
                            taskId : taskid, 
                            inputJSON : inputJSON ,
                            isStart : isStart ,
                            lastString : lastString,
                            isSub : isSub }).then(result => {   
                let isCallNextTask = true;  
                if(result.isSuccess){                            
                    if(this.tasks[curSeq].type === 'Parellel')
                    {
                        this.tasks[curSeq].subTasks[subSeq].inputJSON  = result.outputJSON;  
                        this.tasks[curSeq].subTasks[subSeq].lastString = result.lastString; 
                        //Check whether Task is Failed (whether Other sub task is failed)
                        if(this.tasks[curSeq].result !== 'Failed')
                        {
                            if(this.tasks[curSeq].subTasks[subSeq].type === 'Chain' && !result.isEnd)
                            {    
                                isCallNextTask          =false;                 
                                this.callServerTask(curSeq,subSeq,false,true);
                            }else
                            {
                                this.tasks[curSeq].subTasks[subSeq].result = 'Success';      
                            }   
                            this.tasks[curSeq].errorMessage = result.message;    
                        }else
                        {
                            //Sub Task is Success but Task is Failed due to fail of other sub task
                            if(this.tasks[curSeq].subTasks[subSeq].type === 'Chain'  && !result.isEnd)
                            {    
                                this.tasks[curSeq].subTasks[subSeq].result = 'Stopped';  
                            }else
                            {
                                this.tasks[curSeq].subTasks[subSeq].result = 'Success';      
                            }   
                        }
                    }else if(this.tasks[curSeq].type === 'Chain')
                    {
                        if(!result.isEnd)
                        {
                            isCallNextTask          =false;
                            this.tasks[curSeq].inputJSON  = result.outputJSON;  
                            this.tasks[curSeq].lastString = result.lastString; 
                            this.tasks[curSeq].errorMessage = result.message;  
                            this.startTask(curSeq);
                        }
                    } 
                    this.inJSON =  result.outputJSON;              
                }else
                {     
                    //When Task / Sub Task is failed 
                    isCallNextTask = false;      
                    this.tasks[curSeq].result = 'Failed';
                    this.tasks[curSeq].class='failedRowColor';
                    this.tasks[curSeq].errorMessage = result.message;   
                    // When Task is Parellel set the result of sub task too   
                    if(this.tasks[curSeq].type === 'Parellel')
                    {
                        //For Parellel , Task will not make end until all current running sub task is ended 
                        // So not call end task
                        this.tasks[curSeq].subTasks[subSeq].result = 'Failed';
                        this.tasks[curSeq].subTasks[subSeq].class='failedRowColor';
                        this.tasks[curSeq].subTasks[subSeq].errorMessage = result.message;   
                    }else
                    {
                        
                        this.endTask(curSeq,'Failed',result.message); 
                    }
                }
                
                if(this.tasks[curSeq].type === 'Parellel')
                {
                    //Check whether there is any running or not started Task
                    let isTaskInprogress = this.tasks[curSeq].subTasks.find(function(task){
                        return (task.result === 'In progress' || task.result === 'Not Started') ;
                    }); 
                          
                    if(isTaskInprogress)
                    {
                        isCallNextTask=false;
                    }else
                    {
                        //when there are no running task and Task is failed ( one of sub failed)
                        if(this.tasks[curSeq].result === 'Failed')
                        {
                            isCallNextTask=false;
                            this.endTask(curSeq,'Failed',this.tasks[curSeq].errorMessage); 
                            //The End Server Task will be called from browser Only for Parallel Task 
                            // Other Type will be called End task when Task is failed in Server ( Reduce the travel to browser to server)
                            endServerTask({ recordIdStr: this.recordid ,taskId : this.tasks[curSeq].id, errorMessage : this.tasks[curSeq].errorMessage}).catch(error => {
                                this.endJob(error,taskid);
                            })  
                               
                        }
                    }
                }
               
                
                if(isCallNextTask)
                {
                    this.inJSON = result.outputJSON;   
                    this.successTaskEnd(curSeq,result.outputJSON)
                    curSeq+=1;
                    this.startTask(curSeq);
                }

            }).catch(error => {
                this.endJob(error,taskid);
            })
        }
    }
    startTask(curSeq)
    {
        if(this.tasks[curSeq])
        {   
            if(curSeq === 0)
            {
                this.tasks[curSeq].inputJSON = this.inputJSON;
            }    
            this.tasks[curSeq].result ='In progress';
            this.tasks[curSeq].class='inprogressRowColor';
            if(this.tasks[curSeq].type === 'Parellel')
            {

                this.tasks[curSeq].subTasks.forEach(async (subTask,index)=>{  
                    if(curSeq === 0)
                    {
                        subTask.inputJSON = this.inputJSON;
                    }     
                    let isStart = false;    
                    //Only first one make the progress record             
                    if(index ===0)  isStart = true;  
                    this.callServerTask(curSeq,index,isStart,true);
                });  
            }else
            {
                this.callServerTask(curSeq,0,true,false);
            }
        }else
        {
            //This is end of job 
            this. endJob(null,this.tasks[curSeq - 1].id);
        }
    }
    startJob(){
        if(this.isInProgress)
        {
            this.showToastEvent('Error', 'Job is still running.', 'error');
            return;
        }
        this.isInProgress = true;
        this.tasks.forEach((task)=>{
            task.result='Not Started';
            task.errorMessage='';
            task.class='notStartedRowColor';

        });
       if(this.tasks){
            this.startTask(0);        
        }
    }
    successTaskEnd(curSeq,outputJSON)
    {
        this.endTask(curSeq,'Success','',outputJSON);
    }
    endTask(curSeq,result,message,outputJSON){
        let task =  this.tasks[curSeq];
        if(result === 'Failed')
        {
            this.isInProgress = false;
            task.result = 'Failed';
            task.class='failedRowColor';
            task.errorMessage = message;  
            this.endJob(new Error(message),task.id);      
        }else
        {
            task.outputJSON = outputJSON;
            task.result = 'Success';
            task.class='successRowColor';
            task.errorMessage = message;  
        }
        task.lastString     = '';
        task.inputJSON      = '';
    }
    endJob(exception,taskid){
        if(exception)
        {
            this.handleException(exception,true);          
        }else
        {

            endSuccessJob({ recordIdStr: this.recordid ,taskId : taskid}).then(result=>{
                console.log(result);
                this.inputJSON      = '';
                this.inJSON         = '';
                this.dispatchEvent(new RefreshEvent());
                notifyRecordUpdateAvailable([{recordId: this.recordid}]);
                this.showToastEvent('Job Done',this.jobCompletionMessage, 'info');

            }).catch(error => {
                this.handleException(error,true);  
            })    
        }
        this.isInProgress = false;
        let ev = new CustomEvent('jobEnd',{});
        this.dispatchEvent(ev);  
        if(this.flownsucessaction==='Close')
        {
            this.dispatchEvent(new FlowNavigationFinishEvent());
                
        }else if(this.flownsucessaction==='Next')
        {
            this.dispatchEvent(new FlowNavigationNextEvent());       
        }              
    }
    showToastEvent(titleValue, messageValue, variantValue){
        const event = new ShowToastEvent({
            title: titleValue, 
            message: messageValue,
            variant: variantValue
        });
        this.dispatchEvent(event);
    }
}