from marionette_driver.marionette import Marionette

client = Marionette(host="localhost", port=2828)
client.start_session()
client.set_context(client.CONTEXT_CHROME)

script = 'return typeof Cc["@mozilla.org/style-sheet-service;1"];'
print("typeof Cc[sss]:", client.execute_script(script))

script = 'return Cc["@mozilla.org/style-sheet-service;1"] ? "exists" : "undefined";'
print("Cc[sss] exists?:", client.execute_script(script))

script = 'return typeof Services.styleSheetService;'
print("typeof Services.styleSheetService:", client.execute_script(script))

client.delete_session()
