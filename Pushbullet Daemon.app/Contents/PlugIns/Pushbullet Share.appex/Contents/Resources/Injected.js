var MyExtensionJavaScriptClass = function() {};

MyExtensionJavaScriptClass.prototype = {
run: function(arguments) {
    
    
    if (document.baseURI.indexOf("google") != -1) {
        if (document.baseURI.indexOf("maps") != -1) {
            
            arguments.completionFunction({"baseURI": document.baseURI, "title": document.title, "maps": "true"});
        } else {
            arguments.completionFunction({"baseURI": document.baseURI, "title": document.title});
        }
    }
    
    
    // Pass the baseURI of the webpage to the extension.
    arguments.completionFunction({"baseURI": document.baseURI, "title": document.title});
}

};

// The JavaScript file must contain a global object named "ExtensionPreprocessingJS".
var ExtensionPreprocessingJS = new MyExtensionJavaScriptClass;