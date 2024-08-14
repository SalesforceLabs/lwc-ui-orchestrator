import { LightningElement, wire ,api} from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import Call_UIJob from '@salesforce/messageChannel/Call_UIJob_Hidden__c';
export default class UiJobCaller extends LightningElement {
  @api recordId;
  @api metaDataName ='Test_Job';
  @api buttonLabel ='Start';
  @api inputJSON ='';

  @wire(MessageContext)
  messageContext;
  sendRequest() {
    // this.counter++;
    const payload = { 
      recordIdStr: this.recordId,
      metaDataName: this.metaDataName,
      inputJSON: this.inputJSON
    };
    publish(this.messageContext, Call_UIJob, payload);
  }
}