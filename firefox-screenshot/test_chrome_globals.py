from marionette_driver.marionette import Marionette

client = Marionette(host="localhost", port=2828)
client.start_session()
client.set_context(client.CONTEXT_CHROME)

script = """
(() => {
    let results = [];
    results.push("typeof Components: " + typeof Components);
    results.push("typeof Services: " + typeof Services);
    results.push("typeof Cc: " + typeof Cc);
    results.push("typeof Ci: " + typeof Ci);
    results.push("typeof Cu: " + typeof Cu);
    results.push("typeof ChromeUtils: " + typeof ChromeUtils);
    if (typeof Components !== "undefined") {
        try {
            let sss = Components.classes["@mozilla.org/style-sheet-service;1"];
            results.push("sss via Components.classes: " + (sss ? "found" : "undefined"));
        } catch(e) {
            results.push("sss via Components.classes: ERROR " + e.message);
        }
    }
    if (typeof Cc !== "undefined") {
        try {
            let sss = Cc["@mozilla.org/style-sheet-service;1"];
            results.push("sss via Cc: " + (sss ? "found" : "undefined"));
        } catch(e) {
            results.push("sss via Cc: ERROR " + e.message);
        }
    }
    if (typeof Services !== "undefined") {
        let keys = Object.keys(Services).filter(k => k.toLowerCase().includes("style") || k.toLowerCase().includes("sheet"));
        results.push("Services style/sheet keys: " + keys.join(", "));
    }
    return results.join("\\n");
})();
"""

print(client.execute_script(script))
client.delete_session()
