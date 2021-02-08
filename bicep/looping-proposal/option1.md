# Option 1 - List comprehension style

Assume the existence of a list of things:


```
var things = [
  {
    name: 'value'
    enabled: true
  }
  {
    name: 'second value'
    enabled: false
  }
]
```

#
#
#
#
#
#

**Simple loop for resources**

```
resource[] foo 'microsoft.foo/bar@0000-00-00' = [for thing in things: {
  name: thing.name
}]
```
#
#
#
#
#
#

**Access properties of one of the declared resources**

```
var fooId = foo[0].id
```
#
#
#
#
#
#

**Loop with filtering**

```
resource[] foo 'microsoft.foo/bar@0000-00-00' = [for thing in things if (thing.enabled): {
  name: thing.name
}]
```
#
#
#
#
#
#

**Loop on properties**

```
resource foo 'microsoft.foo/bar@0000-00-00' = {
  name: 'foo'
  properties: {
    listOfThings: [for thing in things: {
      prop1: thing.name
    }]
  }
}
```

#
#
#
#
#
#


**Support all modifiers of ARM template copy**

```
@batchSize(3)
resource[] foo 'microsoft.foo/bar@0000-00-00' = [for thing in things: {
  name: thing.name
}]
```

#
#
#
#
#
#

**With nested child resource**

```
resource foo 'microsoft.foo/bar@0000-00-00' = {
  name: 'blah'

  resource childOfFoo 'baz' = [for thing in things: {
    name: thing[i].name
  }]
}
```