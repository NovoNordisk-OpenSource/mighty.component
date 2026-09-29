# Rendered mighty component

Class for a rendered mighty component.

Once rendered a component can be used to:

- Stream into an R script

- Evaluate the generated code in an environment

## See also

[`get_rendered_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md)

## Super class

[`mighty_component`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.md)
-\> `mighty_component_rendered`

## Methods

### Public methods

- [`mighty_component_rendered$new()`](#method-mighty_component_rendered-initialize)

- [`mighty_component_rendered$print()`](#method-mighty_component_rendered-print)

- [`mighty_component_rendered$stream()`](#method-mighty_component_rendered-stream)

- [`mighty_component_rendered$eval()`](#method-mighty_component_rendered-eval)

- [`mighty_component_rendered$clone()`](#method-mighty_component_rendered-clone)

Inherited methods

- [`mighty_component$document()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.html#method-document)
- [`mighty_component$render()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.html#method-render)

------------------------------------------------------------------------

### `mighty_component_rendered$new()`

Create component from rendered template.

#### Usage

    mighty_component_rendered$new(template, id)

#### Arguments

- `template`:

  `character` Rendered template such as output from
  `mighty_component$render()`.

- `id`:

  `character` ID of the component.

------------------------------------------------------------------------

### `mighty_component_rendered$print()`

Print rendered component

#### Usage

    mighty_component_rendered$print()

#### Returns

(`invisible`) self

------------------------------------------------------------------------

### `mighty_component_rendered$stream()`

Stream rendered code into a script (appended)

#### Usage

    mighty_component_rendered$stream(path)

#### Arguments

- `path`:

  `character(1)` path to the R script to stream code into.

------------------------------------------------------------------------

### `mighty_component_rendered$eval()`

Evaluate code in a specified environment.

#### Usage

    mighty_component_rendered$eval(envir = parent.frame())

#### Arguments

- `envir`:

  Environment to evaluate in. Parsed to
  [`eval()`](https://rdrr.io/r/base/eval.html). Defaults to using the
  current environment with
  [`parent.frame()`](https://rdrr.io/r/base/sys.parent.html).

------------------------------------------------------------------------

### `mighty_component_rendered$clone()`

The objects of this class are cloneable with this method.

#### Usage

    mighty_component_rendered$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
