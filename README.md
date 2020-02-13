# DynamicJson

[![Swift version](https://img.shields.io/badge/Swift-5-orange.svg)](https://swift.org/download)
[![Version](https://img.shields.io/badge/version-1.0-green.svg)](https://github.com/illescasDaniel/DynamicJson/releases)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/illescasDaniel/DynamicJson/blob/master/LICENSE)

An enjoyable way to manage json objects.

### Examples:
```swift
let json = """
{
  "name": "Daniel",
  "age": 22,
  "favouriteFoods": ["pizza"]
}
"""

// Get a json from a raw string, from data or from an object (like a dictionary)
let danielJson = Json(raw: json)

// Get stuff
print(danielJson.name.string ?? "")
print(danielJson.favouriteFoods[0].string ?? "")

// You can also change the values inside
danielJson.favouriteFoods = ["hamburger", "you"]
print(danielJson.favouriteFoods.array ?? [])
print(danielJson)
```

Easily convert to a Codable object.
```swift
struct Person: Codable {
  let name: String
  let age: UInt
  var favouriteFoods: [String]
}

let daniel: Person? = danielJson.decoded()
print(daniel ?? "nope")
```

Fast Json traversal with `NSDictionary#value(forKeyPath: String)`.
```swift
let otherJson = """
{
  "fullName": {
    "firstName": "Daniel",
    "lastName": "Illescas",
    "parent": {
      "fullName": {
        "firstName": "Peter",
        "lastName": "Illescas"
      }
    }
  },
  "age": 22
}
"""
let me = Json(raw: otherJson)
print(me[\.fullName.parent.fullName.firstName].string ?? "nope")
// or
print(me["fullName.parent.fullName.firstName"] ?? "nope")
```
