from marionette_driver.marionette import Marionette

client = Marionette(host="localhost", port=2828)
client.start_session()
client.set_context(client.CONTEXT_CHROME)

# Test injecting a style into the chrome window
script = """
(() => {
    let doc = window.document;
    let style = doc.createElement("style");
    style.textContent = "#navigator-toolbox { background: red !important; }";
    doc.documentElement.appendChild(style);
    return "injected";
})();
"""

print("Inject result:", client.execute_script(script))
client.delete_session()
