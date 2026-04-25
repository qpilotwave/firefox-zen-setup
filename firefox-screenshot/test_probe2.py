from marionette_driver.marionette import Marionette

client = Marionette(host="localhost", port=2828)
client.start_session()
client.set_context(client.CONTEXT_CHROME)

script = "return typeof Components;"
print("typeof Components:", client.execute_script(script))

script = "return typeof Cc;"
print("typeof Cc:", client.execute_script(script))

script = "return typeof Services;"
print("typeof Services:", client.execute_script(script))

script = "return typeof ChromeUtils;"
print("typeof ChromeUtils:", client.execute_script(script))

client.delete_session()
