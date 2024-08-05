import { LightningElement, wire ,api} from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import Call_UIJob from '@salesforce/messageChannel/Call_UIJob__c';
export default class UiJobCaller extends LightningElement {
  @api recordId;
  @api metaDataName ='Test_Job';
  @wire(MessageContext)
  messageContext;
  sendRequest() {
    // this.counter++;
    const payload = { 
      recordIdStr: this.recordId,
      metaDataName: this.metaDataName
    };
    publish(this.messageContext, Call_UIJob, payload);
  }
}