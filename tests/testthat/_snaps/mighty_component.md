# mighty_component

    Code
      test_component
    Message
      <mighty_component/R6>
      Type: derivation
      Parameters:
      * x1: First input
      * x2: Second input
      Depends:
      * .self.A
      * Y.B
      Outputs:
      * NEWVAR

---

    Code
      test_component_rendered
    Message
      <mighty_component_rendered/mighty_component/R6>
      Type: derivation
      Depends:
      * .self.A
      * Y.B
      Outputs:
      * NEWVAR
      Code:
      .self$NEWWAR <- 1 * Y$B + .self$A - 2

# ms_print

    Code
      expect_s3_class(expect_invisible(print(mighty_component$new(readLines(test_path(
        "_components", "test_component.mustache"))))), "mighty_component")
    Message
      <mighty_component/R6>
      Type: derivation
      Parameters:
      * x1: First input
      * x2: Second input
      Depends:
      * .self.A
      * Y.B
      Outputs:
      * NEWVAR

# create_bullets

    Code
      create_bullets(header = "mytest", bullets = c("first item", "second item"))
    Message
      mytest
      * first item
      * second item

