Introduction
------------

This project aims to make it easy to see differences in different
versions (e.g. `git diff`) of .xcdatamodel files used to describe Core
Data managed object models. An example `git diff` output follows:

    diff --git a/Recipes.xcdatamodel/elements b/Recipes.xcdatamodel/elements
    index 35a20f3..939bc61 100644
    --- a/Recipes.xcdatamodel/elements
    +++ b/Recipes.xcdatamodel/elements
    @@ -2,8 +2,8 @@ Entity: Image (NSManagedObject)
       Att: image                     Transformable                                            O   dafQGIhBFATAxE1hyQd5z5cpRg0OLP4+M+W3+xhA6jU=
       Rel: recipe                    Recipe          image                            Nullify   I fVH2lmmkHE4j/FvzfJ2et3KsNxcA8p5BJp2d/xd4hH0=

    -Entity: Ingredient (Ingredient)                                                               5tCLlA1r9p1UWdOTr3XJ+ZzBr6bxraWAs3Vt9zCAZek=
    -  Att: amount                    String                                                   O   b9/jjR2iJtm4oldVJwj25X+/hpEL6/1CM5hLhgV48Iw=
    +Entity: Ingredient (Ingredient)                                                               7nbTTDaWG1lAddHYHum4xP4IA/N90NYv9GLkGK+sueQ=
    +  Att: amount                    Integer16                                                O   RmH9Sk61kxsb8+GUEqlEkIuV4tDjxxhMNsHUu/tBW6I=
       Att: displayOrder              Integer16                                                    kMPJ+qU+fnBipO5Ajep+KT3rKB9zeOPrav0q4rMSt7k=
       Att: name                      String                                                       jLmWXAAxrGiROYTzEQlBrZZTlb6f2bF9575UvHrUaJA=
       Rel: recipe                    Recipe          ingredients                      Nullify O I GvmjTsOh76OGkr0Lmnxdh8u6FO4E+iuEYa0mRZPuKJQ=

The project source compiles to a binary, `XCDataModelPrinter`, which
prints a textual representation of a .xcdatamodel file. This binary
acts as the textconv program for a diff driver in git (see
Installation below).

`XCDataModelPrinter` works by compiling the .xcdatamodel file
(actually, its a directory) to a .mom file using the `momc`
compiler. The program should usually be able to find `momc`, but if it
can't, you can help it by setting the environment variable
`MOMC_PATH`. Once it has a compiled .mom file, it uses the
`NSManagedObjectModel` interface to print a textual representation on
standard output.

Installation
------------

1) Build `XCDataModelPrinter` and copy the binary to your path

  * Open the `XCDataModelPrinter` project in Xcode and build with release
    configuration
  * Right click on Products > XCDataModelPrinter in the project navigator,
    then click 'Show in Finder' to locate the binary
  * Copy the binary to your `$PATH`

    Alternatively, you can build the project on the command line using
    xcodebuild.

2) Test with an existing .xcdatamodel file.

    XCDataModelPrinter /path/to/your/project.xcdatamodeld/project 1.xcdatamodel

   If you see a textual representation of the data model printed on
   stdout, skip to the next section. If you see an error that says
   "Couldn't find momc", you need to help `XCDataModelPrinter` find
   the the `momc` binary. You can do this by setting the environment
   variable `MOMC_PATH` to the path of the `momc` binary.

Adding the git-diff driver
--------------------------

1) Add the following line to your project's `.gitattributes` file (if
   you want this to apply globally, you can use `~/.gitattributes`)

    elements diff=xcdatamodel

  This tells git to use `xcdatamodel` as the diff driver for
  .xcdatamodel/elements files (which contain your model's entire
  definition). What exactly is this `xcdatamodel` driver? That is
  defined in the next section.

2) We can set up the `xcdatamodel` driver using `git config`. Use
   these commands to set up the driver (use the `--global` option if you
   want to set up the driver for all your projects)

    git config diff.xcdatamodel.xfuncname ^Entity.*$
    git config diff.xcdatamodel.textconv XCDataModelPrinter

   Now, whenever you use any git command which shows a diff output
   (e.g. `git diff`, `git log -p`, `git show`, etc.) and there's a
   change in an xcdatamodel file, you should be able to understand
   easily what changes have been made to the data model.
