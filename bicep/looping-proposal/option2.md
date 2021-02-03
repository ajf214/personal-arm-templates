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

>**Note:** function signature for `@copies` decorator
>
>`@copies(count: int, iteratorSymbol: string, [batchSize: int])`


**Simple loop for resources**

```
@copies(length(things), 'i')
resource foo 'microsoft.foo/bar@0000-00-00' = {
  name: things[i].name
}
```

**Access properties of one of the declared resources**

```
var fooId = foo[0].id
```

**Loop with filtering**

```
@copies(length(things), 'i')
resource foo 'microsoft.foo/bar@0000-00-00' = if(things[i].enabled) {
  name: things[i].name
}
```

**Loop on properties**

```
resource foo 'microsoft.foo/bar@0000-00-00' = {
  name: 'foo'
  properties: {
    someArray: [
      @copies(length(things), 'i')
      {
        prop1: things[i].name
      }
    ]
  }
}
```

**Support all modifiers of ARM template copy**

```
@copies(length(things), 'i', 3)
resource foo 'microsoft.foo/bar@0000-00-00' = {
  name: things[i].name
}
```

**With nested child resource**

```
resource foo 'microsoft.foo/bar@0000-00-00' = {
  name: 'blah'

  @copies(length(things), 'i')
  resource childOfFoo 'baz' = {
    name: thing[i].name
  }
}
```