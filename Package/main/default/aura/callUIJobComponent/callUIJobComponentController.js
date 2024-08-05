({
    handleClick: function(component) {
        var metaDataName = component.get('v.metaDataName');
        var recordId = component.get('v.recordId');
 
        var payload = {
            recordIdStr: recordId,
            metaDataName: metaDataName
        };     
        component.find("callUIJobMessageChannel").publish(payload);
    }
})