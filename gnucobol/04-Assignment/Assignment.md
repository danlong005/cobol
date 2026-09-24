# Assignment 04

Let's talk about separate compilation. The days of combining all the source 
code into one source file should be long gone. We need to move into reusable 
code. That is how we make our job easier. Now, the best thing is to have 
reusable object code or shared libraries. However, reusable source is an 
option too. We will do that in this first assignment on the topic. CopyBooks
are a way for us to share our source code in different programs. In this 
assignment we will have the same input file. We will still calculate the 
age of each employee. However, we are putting the calculation into a 
copybook.

# Precompiler note
```
OceSQL, the precompiler this used to be built with, tripled a copybook
placed on the last line of the code. esqlOC doesn't have that problem.

We aren't using SQL in this example, but it still goes through esqlOC so
every assignment builds the same way.
```


# Input
```
001Clark          Kent                1980-01-01
002Tony           Stark               1999-05-04
003Bruce          Wayne               1965-07-04
```

# Output
The ages are as of 2026-09-23, so they depend on the date you run it.
```
001Clark          Kent                1980-01-01 046
002Tony           Stark               1999-05-04 027
003Bruce          Wayne               1965-07-04 061
```