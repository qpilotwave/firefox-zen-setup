from marionette_driver.marionette import Marionette
import base64

client = Marionette(host="localhost", port=2828)
client.start_session()
client.set_context(client.CONTEXT_CHROME)

b64_data = client.screenshot(format="base64", full=True)
client.delete_session()

png_bytes = base64.b64decode(b64_data)
with open("test_inject.png", "wb") as f:
    f.write(png_bytes)
print(f"Saved test_inject.png ({len(png_bytes)} bytes)")
