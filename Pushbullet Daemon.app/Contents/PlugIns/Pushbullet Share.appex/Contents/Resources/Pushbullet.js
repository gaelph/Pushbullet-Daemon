var MyExtensionJavaScriptClass = function() {};

MyExtensionJavaScriptClass.prototype = {
run: function(arguments) {
    
    
    if (document.baseURI.indexOf("google") != -1) {
        if (document.baseURI.index("maps") != -1) {
            var address = "";
            console.log("Pushbullet share : We are on a Google Maps page");
            
            //We are on a google Maps page;
            console.log("Pushbullet share : Finding the place's name");
            var addressTitleDivElmt = document.getElementsByClassName("cards-entity-title");
            if (addressTitleDivElmt.count > 0) {
                addressTitleDivElmt[0].firstChild.textContent;
                address = address.concat(address, addressTitleDivElmt.firstChild.textContent);
                console.log("Pushbullet share : found " + address);
            }
            
            address = address.concat(address, " ");
            
            console.log("Pushbullet share : Finding the place's address");
            var addressDivElmt = document.getElementsByClassName("cards-entity-address");
            if (addressDivElmt.count > 0) {
                for (elmt in addressDivElmt) {
                    for (child = elmt.firstChild; child; child = child.nextSibling) {
                        var span = child.firstChild;
                        address = address.concat(address, span.textContent);
                        address = address.concat(address, " ");
                        console.log("Pushbullet share : found " + span.textContent);
                    }
                }
                console.log("Pushbullet share : found " + address);
            }
            
            arguments.completionFunction({"baseURI": document.baseURI, "title": document.title, "address": address});
            return;
        }
    }
    
    
    // Pass the baseURI of the webpage to the extension.
    arguments.completionFunction({"baseURI": document.baseURI, "title": document.title});
}

};

// The JavaScript file must contain a global object named "ExtensionPreprocessingJS".
var ExtensionPreprocessingJS = new MyExtensionJavaScriptClass;