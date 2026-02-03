# print

    Code
      print(get_rendered_component(test_path("_components", "test_component.mustache"),
      params = list(domain = "domain", x1 = 5, x2 = 3)))
    Message
      <mighty_component_rendered/mighty_component/R6>
      _components/test_component.mustache: This is a test component used for unit
      testing
      Type: derivation
      Depends:
      * domain.A
      * Y.B
      Outputs:
      * NEWVAR
      Code:
      domain$NEWVAR <- 5 * Y$B + domain$A - 3

