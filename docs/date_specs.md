# Date Specs

## Primitives

### Literal

There are several literals that can be used interchangeably. Literals are case-insensitive.

We have weekdays:

* `mo`/`mon`/`monday`
* `tu`/`tue`/`tuesday`
* `we`/`wed`/`wednesday`
* `th`/`thu`/`thursday`
* `fr`/`fri`/`friday`
* `sa`/`sat`/`saturday`
* `su`/`sun`/`sunday`

We have months:

* `ja`/`jan`/`january`
* `fe`/`feb`/`february`
* `mr`/`mar`/`march`
* `ap`/`apr`/`april`
* `my`/`may`/`may`
* `jn`/`jun`/`jun`
* `jl`/`jul`/`july`
* `au`/`aug`/`august`
* `se`/`sep`/`september`
* `oc`/`oct`/`october`
* `no`/`nov`/`november`
* `de`/`dec`/`december`

And we have a special literal to describe events that occur every day: `daily`.

Internally literals are translated to other expressions, e.g. *triples* or *ranges*.

### Triple

Triple consists of one, two or three integers separated by `/`. Following logic applies:

- Single digit denotes day of a month if it is lower or equal 31. Otherwise it denotes a year.
- Two digits denote a month and day of that month if the first digit is lower or equal 12. Otherwise they denote a year and month.
- Three digits denote a year, month and day respectively.


### Prefix

There are following primitives of this type:

- `qX`, where X is form 1 to 4. This denotes quarter of a year. E.g. `q2` is the same as `apr may jun`.
- `mX`, where X is from 1 to 12. This denotes a month. E.g. `m6` is the same as `june`.

Internally prefixes are translated to other expressions, e.g. *triples* or *ranges*.


## Operators

There are following operators, listed from the highest to the lowest priority:

| Symbol   | Name |
| -------- | ---- |
| `-`      | range |
| `!`      | inversion (not) |
| `,`      | alternative (or) |
| ` ` (space) | conjunction (and) |

Note that range is inclusive. It can have two operands, only one of them, or none of them. The only allowed operands are *triples*. If right-hand side *triple* has any of the components missing, it inherits them from the left-side triple. For instance:

- `7/1-4` means first four days of July each year.
- `12/20-` means from 20th of December each year.
- `-2` means first two days of each month.
- `-` means every day and is the same as `daily`.

