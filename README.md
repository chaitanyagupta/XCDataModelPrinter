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

The project contains a script, `print_xcdatamodel`, which prints a
textual representation of a .xcdatamodel file. This script as the
textconv program for a diff driver in git (see Installation below).

`print_xcdatamodel` works by compiling the xcdatamodel file to a mom
file using the `momc` compiler. The compiled mom file is then read by
another program, `MOMPrinter`, which also ships with this
project. `MOMPrinter` takes a .mom file as input and prints a detailed
description of the data model on standard output.

Installation
------------

1. Copy `print_xcdatamodel` to your $PATH

2. Build MOMPrinter and copy the binary to your path

    * Open the MOMPrinter project in Xcode and build with release
      configuration
    * Right click on Products > MOMPrinter in the project navigator,
      then click 'Show in Finder' to locate the binary
    * Copy the binary to your $PATH

    Alternatively, you can build the project on the command line using
    xcodebuild.

3. Ensure that `momc` is available in your $PATH. For Xcode 4.3.2, the
`momc` binary can be found at
/Applications/Xcode.app/Contents/Developer/usr/bin/momc

4. Set up `git diff` to use `print_xcdatamodel` for xcdatamodel files

    * Add the following line to your projects `.gitattributes` file
      (if you want this to apply globally, you can use
      `~/.gitattributes`)

            elements diff=xcdatamodel

      This tells to use `xcdatamodel` as the diff driver for
      .xcdatamodel/elements files (which contain your model's entire
      definition). What exactly is this `xcdatamodel` driver? That is
      defined in the next section.

    * We can set up the `xcdatamodel` driver using `git config`. Use
      these commands to set up the driver (use the `--global` option
      if you want to set up the driver for all your projects)

            git config diff.xcdatamodel.xcfuncname ^Entity
            git config diff.xcdatamodel.textconv print_xcdatamodel

Now, whenever you use any git command which shows a diff output
(e.g. `git diff`, `git log -p`, `git show`, etc.) and there's a change
in an xcdatamodel file, you should be able to understand easily what
changes have been made to the data model.
