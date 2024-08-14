({
    handlePopup: function(component) {
        var utilityAPI = component.find("utilitybar");
        utilityAPI.openUtility();  

    },
    handleJobEnd: function (component) {
        var utilityAPI = component.find("utilitybar");
        utilityAPI.minimizeUtility();  
    }
    
})