from marionette_driver.marionette import Marionette

client = Marionette(host="localhost", port=2828)
client.start_session()
client.set_context(client.CONTEXT_CHROME)

script = "return window.location ? window.location.href : 'no location';"
print("Window location:", client.execute_script(script))

script = "return window.document ? window.document.title : 'no doc';"
print("Window title:", client.execute_script(script))

script = "return window.document ? window.document.documentElement.tagName : 'no doc';"
print("Root element:", client.execute_script(script))

client.delete_session()
