# Rendered component class

R6 class for a rendered component, created by
[mighty_component](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.md)`$render()`
or
[`get_rendered_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md).

A rendered component can be:

- Streamed into an R script with `$stream()`.

- Evaluated in an environment with `$eval()`.

## See also

[`get_rendered_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md),
[mighty_component](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.md)

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

Create a rendered component from a rendered template. The code is
validated. See the Validation section in
[mighty_component](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.md).

#### Usage

    mighty_component_rendered$new(template, id)

#### Arguments

- `template`:

  `character` Rendered template, one element per line.

- `id`:

  `character(1)` Component ID.

------------------------------------------------------------------------

### `mighty_component_rendered$print()`

Print the rendered component, including its code.

#### Usage

    mighty_component_rendered$print()

#### Returns

(`invisible`) self

------------------------------------------------------------------------

### `mighty_component_rendered$stream()`

Write the code to an R script. The code is appended if the file exists.

#### Usage

    mighty_component_rendered$stream(path)

#### Arguments

- `path`:

  `character(1)` Path to the R script.

#### Returns

(`invisible`) self

------------------------------------------------------------------------

### `mighty_component_rendered$eval()`

Evaluate the code.

#### Usage

    mighty_component_rendered$eval(envir = parent.frame())

#### Arguments

- `envir`:

  Environment to evaluate the code in. Defaults to the calling
  environment.

#### Returns

Value of the last evaluated expression of the code.

------------------------------------------------------------------------

### `mighty_component_rendered$clone()`

The objects of this class are cloneable with this method.

#### Usage

    mighty_component_rendered$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
