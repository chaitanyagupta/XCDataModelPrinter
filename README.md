Introduction
------------

This project aims to make it easy to see differences in different
versions (e.g. `git diff`) of .xcdatamodel files used to describe Core
Data managed object models. An example `git diff` output follows (see
the "Output Format" section below for a more details):

    diff --git a/Recipes.xcdatamodel/elements b/Recipes.xcdatamodel/elements
    index 35a20f3..939bc61 100644
    --- a/Recipes.xcdatamodel/elements
    +++ b/Recipes.xcdatamodel/elements
    @@ -3,7 +3,7 @@ Entity: Image (NSManagedObject)
       Rel: recipe                    Recipe          image                            Nullify   I fVH2lmmkHE4j/FvzfJ2et3KsNxcA8p5BJp2d/xd4hH0=

     Entity: Ingredient (Ingredient)
    -  Att: amount                    String                                                   O   b9/jjR2iJtm4oldVJwj25X+/hpEL6/1CM5hLhgV48Iw=
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
   
Usage
-----

Typical usage:

    XCDataModelPrinter [--compact] /path/to/your/project.xcdatamodeld

Following parameters are supported:

  * --compact or -c : change output mode, so when printing properties of a given Entity
      its superclasses' properties won't be included.   

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

Output Format
-------------

`<flags>` are:
  O: is optional
  T: is transient
  I: is indexed

    Entity: <name> [: <superentity name>] (<class name>)
      // Attributes
      Att: <name>               <type>                                                                [flags] <version hash>
      // Relationships
      Rel: <name>               <destination entity>  <inverse>                [ToMany] <delete rule> [flags] <version hash>
      // Fetched properties
      Fpr: <name>                                                                                     [flags] <version hash>

    Configuration: <name>
      Entity: <entity name>

    Fetch Request: <name>
      <fetch request description>
