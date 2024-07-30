import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from "lightning/messageService";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import callUIJobMessageChannel from "@salesforce/messageChannel/Call_UIJob__c";
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';
import CONFIRMATION_MESSAGE from '@salesforce/label/c.LWCJobOrchestrator_Confirmation_Message';
import SUCCESS_MESSAGE from '@salesforce/label/c.LWCJobOrchestrator_Success_Message';
export default class lwcJobOrchestratorTriggerJob extends LightningElement {
    @api recordId;
    @api metaDataName;
    @api someParam;
    confirmationMessage = CONFIRMATION_MESSAGE;
    successMessage = SUCCESS_MESSAGE;
    
    @wire(MessageContext)
    messageContext;

    async handleMessageChannel() {
    let inputJSON = {
            someParam : this.someParam
        };
        let payload = { 
            recordIdStr: this.recordId, 
            metaDataName: this.metaDataName, 
            inputJSON : JSON.stringify(inputJSON)
        };
        /* await startProcess({ costSheetId : this.recordId})
        .then(result => {
            console.log('result '+result);
            this.showToast(
                "Success",
                this.successMessage,
                "Success",
                "dismissable"
            );
            publish(this.messageContext, callUIJobMessageChannel, payload);
        }).catch( error => {
            const logger = this.template.querySelector('c-logger');
            logger.error(error);
            logger.saveLog();
            this.showToast(
                "Error Occured",
                "Error occured. Please contact your admin",
                "Error",
                "dismissable"
            );
        }); */
        publish(this.messageContext, callUIJobMessageChannel, payload);
        this.showToast(
            "Success",
            this.successMessage,
            "Success",
            "dismissable"
        );
        this.dispatchEvent(new FlowNavigationFinishEvent());
    } 

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
          title: title,
          message: message,
          variant: variant,
          mode: mode
        });
        this.dispatchEvent(event);
    }
}