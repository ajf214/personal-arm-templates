# Option 1

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

**Simple loop for resources**

```
for thing in things:
resource foo 'microsoft.foo/bar@0000-00-00' = {
  name: thing.name
}
```

**Access properties of one of the declared resources**

```
var fooId = foo[0].id
```

**Loop with filtering**

```
for thing in things if (thing.exists):
resource foo 'microsoft.foo/bar@0000-00-00' = {
  name: thing.name
}
```

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

**Support all modifiers of ARM template copy**

```
@batchSize(3)
for thing in things:
resource foo 'microsoft.foo/bar@0000-00-00' = {
  name: thing.name
}
```

**With nested child resource**

```
resource foo 'microsoft.foo/bar@0000-00-00' = {
  name: 'blah'

  for thing in things:
  resource childOfFoo 'baz' = {
    name: thing.name
  }
}
```