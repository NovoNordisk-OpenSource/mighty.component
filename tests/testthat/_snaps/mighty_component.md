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

# ms_print

    Code
      expect_s3_class(expect_invisible(print(mighty_component$new(readLines(test_path(
        "_input", "test_component.mustache"))))), "mighty_component")
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

