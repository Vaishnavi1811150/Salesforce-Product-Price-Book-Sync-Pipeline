%dw 2.0
output application/java
var body = if (typeOf(payload) as String == "Object") payload else {}
---
if (payload == null)
    { valid: true, error: null }
else if (body.fullSync != null and !(typeOf(body.fullSync) as String == "Boolean" or body.fullSync == true or body.fullSync == false))
    { valid: false, error: "Field 'fullSync' must be a boolean (true/false)" }
else if (body.productCodes != null and !(typeOf(body.productCodes) as String == "Array"))
    { valid: false, error: "Field 'productCodes' must be an array of strings" }
else
    { valid: true, error: null }
