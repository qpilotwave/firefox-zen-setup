from marionette_driver.marionette import Marionette

client = Marionette(host="localhost", port=2828)
client.start_session()
client.set_context(client.CONTEXT_CHROME)

script = """
let x = 1 + 1;
return x;
"""
print("Multi-line result:", client.execute_script(script))

script = """
(() => {
    return 1 + 1;
})();
"""
print("IIFE result:", client.execute_script(script))

client.delete_session()
