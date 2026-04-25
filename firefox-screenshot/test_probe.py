from marionette_driver.marionette import Marionette

client = Marionette(host="localhost", port=2828)
client.start_session()
client.set_context(client.CONTEXT_CHROME)

script = """
(() => {
    let out = [];
    out.push("Components: " + (typeof Components !== "undefined"));
    out.push("Cc: " + (typeof Cc !== "undefined"));
    out.push("Ci: " + (typeof Ci !== "undefined"));
    out.push("Services: " + (typeof Services !== "undefined"));
    
    try {
        if (typeof Cc !== "undefined") {
            let sss = Cc["@mozilla.org/style-sheet-service;1"];
            out.push("Cc[sss] type: " + typeof sss);
        }
    } catch(e) {
        out.push("Cc[sss] error: " + e.message);
    }
    
    try {
        if (typeof Components !== "undefined" && Components.classes) {
            let sss = Components.classes["@mozilla.org/style-sheet-service;1"];
            out.push("Components.classes[sss] type: " + typeof sss);
        }
    } catch(e) {
        out.push("Components.classes[sss] error: " + e.message);
    }
    
    try {
        if (typeof Services !== "undefined") {
            let keys = [];
            for (let k in Services) {
                if (k.toLowerCase().includes("style") || k.toLowerCase().includes("sheet")) {
                    keys.push(k);
                }
            }
            out.push("Services keys: " + keys.join(", "));
        }
    } catch(e) {
        out.push("Services keys error: " + e.message);
    }
    
    return out.join(" | ");
})();
"""

print("Result:", client.execute_script(script))
client.delete_session()
