from marionette_driver.marionette import Marionette

client = Marionette(host="localhost", port=2828)
client.start_session()
print("Session started")
client.set_context(client.CONTEXT_CHROME)
print("Context switched to chrome")
result = client.execute_script("return 1 + 1;")
print("1+1 =", result)
result2 = client.execute_script("return typeof window;")
print("typeof window =", result2)
client.delete_session()
