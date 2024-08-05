({
    handleMessage: function(component, message) {

        // Read the message argument to get the values in the message payload
        if (message != null){
            if(message.getParam("recordIdStr") != null) component.set("v.recordIdStr", message.getParam("recordIdStr"));
            if(message.getParam("metaDataName") != null)component.set("v.metaDataName", message.getParam("metaDataName"));
            if(message.getParam("inputJSON") != null)component.set("v.inputJSON", message.getParam("inputJSON"));
        }
        
        component.find('uiJobLWC').initPage(true);   
        var utilityAPI = component.find("utilitybar");
        utilityAPI.openUtility();  

    },
    handleJobEnd: function (component) {
        var utilityAPI = component.find("utilitybar");
        utilityAPI.minimizeUtility();  
    }
    
})