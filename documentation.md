# System Programming Project

## Students
- Jonas Balsfulland
- Felix Stegmaier

## Assignment
Write a MIPS assembly program to compute `sin(x)`, `cos(x)` and `tan(x)`

## Agorithm

## Optimization

## Output table

SPIM outputs between 1 and around 20 characters when printing a double using
systemcall 3.
However finding out how many characters were actually printed is tedious,
so a really 'pretty' table layout is hard to achieve.

```
| x | sin(x) | cos(x) | tan(x) |
| ------------- | ------------- | ------------- | ------------- |
| 0.0 | 0.0 | 1.0 | 0.0 |
| ... | ... | ... | ... |
```
One solution is to use a more flexible table layout, like the one above.
This syntax is compatible to markdown table syntax, so it can be easily
rendered into a proper table.

This Example renders into the following table.

| x | sin(x) | cos(x) | tan(x) |
| ------------- | ------------- | ------------- | ------------- |
| 0.0 | 0.0 | 1.0 | 0.0 |
| ... | ... | ... | ... |
