from marionette_driver.marionette import Marionette

client = Marionette(host="localhost", port=2828)
client.start_session()
client.set_context(client.CONTEXT_CHROME)

script = """
let doc = window.document;
let toolbox = doc.getElementById("navigator-toolbox");
if (!toolbox) {
    return "no toolbox";
}
toolbox.style.backgroundColor = "red";
return "set red on toolbox";
"""

print("Inject result:", client.execute_script(script))

b64_data = client.screenshot(format="base64", full=True)
client.delete_session()

import base64
png_bytes = base64.b64decode(b64_data)
with open("test_inject3.png", "wb") as f:
    f.write(png_bytes)
print(f"Saved test_inject3.png ({len(png_bytes)} bytes)")
