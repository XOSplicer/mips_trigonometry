# System Programming Project

### Students
- Jonas Balsfulland (MatrNr. 6660582)
- Felix Stegmaier (MatrNr. 6079153)

### Submitted Files
| Filename | Description     |
| :------------- | :------------- |
| project.java          | High-Level implementation of the algorithm |
| project.s             | MIPS assembly implementation |
| documentation.md      | This documentation in markdown format |
| documentation.pdf     | This documentation in PDF format |
| ProjectTINF15AIA.pdf  | The project assignment |

### Assignment
Write a MIPS assembly program to compute _sin(x)_, _cos(x)_ and _tan(x)_.
The concrete project assignment was handed out and can be found attached.

### Algorithm and Optimization

#### Taylor approximation

The taylor approximation for _sin(x)_ can be found in the project assignment.
However is is more efficient to approximate _cos(x)_
using taylor around the center point 0 with the following formula:

```
cos(x)  = sum[(-1)^i * x^(2*i) / ((2*i)!)]
          from i=0 to infinity
        = 1 - x^2/2! + x^4/4! - x^6/6! + x^8/8! - ...
```

We chose to implement _cos(x)_ over _sin(x)_ because:
- _cos(x)_ is axially symmetric to the y=0 axis, so _cos(x) = cos(-x)_
- the taylor approximation of _cos(x)_ uses smaller values inside the sum since _2i_ is used instead of _2i+1_, therefore the error will be smaller.
-  _(2i)!_ is smaller than _(2i+1)!_ by a factor of _2i+1_ and can better fit into an 32-bit integer.

The calculation of each term can be simplified by defining the following series:

```
k_(i+1) = (-1)^i * k_i * x^2 / (2*i * (2*i-1)) for k >= 0
with k_0 = 1
```

So summing over _k_i_ from 0 to infinity is equal to the formula given above.
Using this iterative approach the result of the calculation of the previous
term can be used to calculate the next one.

#### Mapping x to the right quadrant

Since this formula is centered around _x=0_ and the sum can only be
performed for a finite amount of terms, the result of the calculation will
have an error of _R(x) ~ x^m+1_ where _m_ is the last index of the sum.

But because _cos(x)_ is symmetric, periodic with a period of _2*Pi_
and because it is symmetric within the period
it is possible to reduce the range that is needed to be calculated correctly
to the interval _[0, Pi/2)_.

The mapping to calculate _cos(x)_ can be performed as following:
1. _cos(x) = cos( abs(x) )_
2. _cos(x) = cos( x mod (2*Pi) )_
3.  
  * _0 <= x < Pi/2 ==> cos(x) = cos(x)_
  * _Pi/2 <= x < Pi ==> cos(x) = -cos(Pi - x)_
  * _Pi <= x < 2Pi ==> cos(x) = cos(x - Pi)_

#### Calculating sin(x) and tan(x)

_sin(x)_ and _tan(x)_ can be computed from _cos(x)_ using the following conversions:
- _sin(x) = cos(x - Pi/2)_
- _tan(x) = sin(x) / cos(x)_

### Output table

As input the user should provide three numbers, _n_, _x_min_ and _x_max_.
As output the program should generate a table  containing _n_
equidistant values in the interval of _[x_min, x_max]_.
Therefore the distance between each value needs to be _(x_max - x_min) / (n-1)_
given that _x_max > x_min_ and _n > 1_.
If _n=1_ is given, only the calculations for _x_min_ will be performed.

For the table itself the following considerations were taken:  
SPIM outputs between 1 and around 20 characters when printing a double using
systemcall 3.
However finding out how many characters were actually printed is tedious,
so a really 'pretty' table layout is hard to achieve.
A solution to this would be implementing `printf`,
which is out of scope for this project.

```
| x | sin(x) | cos(x) | tan(x) |
| --- | --- | --- | --- |
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
