# plany

Manage your calendar in YAML.

## Why

It's yet another calendar application. Build with the following goals in mind:

- Events should be minimal. They consist of a title and date specification.
- Date specification should be human readable and intuitive.
- Data should be stored in a common file format. Easy to backup and edit in a text editor.
- Application should provide clear overview showing as much of the timeline as possible.
- All the functions should have intuitive key bindings assigned.

## Data Files

Data files should be placed in `$XDG_DATA_HOME/plany` (typically `~/.local/share/plany`).

Structure of sub-directories is fully defined by the user. Example can be found in `example/data`.

Calendar events are stored in YAML files. Each YAML file consists of dictionaries building a tree.
Leaves of the tree define events. Structure of dictionaries is a continuation of directory structure.

There are three formats of the leaves available.

### Format-1

The most condense and natural format.

```
date_spec1: title1
date_spec2: title2
date_spec3: title3
```

Note that from YAML perspective it is a dictionary. This is what makes it applicable only when
events are described by unique date specifications.

As an example, take a look at `public`in `example/data/vacations.yaml`

### Format-2

Similar to *Format-1*, but it is expressed as a list in YAML. It is suitable when we want allow
for duplication of the date specifications.

```
- date_spec1: title1
- date_spec2: title2
- date_spec3: title3
```

As an example, take a look at `example/data/anniv/birthdays.yaml`


### Format-3

Convenient for the events that include long list of dates. Especially when we expect this list
to be edited often.

```
title:
- date_spec1
- date_spec2
- date_spec3
```

Alternative over the list of date specifications is calculated.

As an example, take a look at `customer visits` in `example/data/work.yaml`

## Date Specifications

Date specs determine when events occur. They consist of primitives combined by operators. For instance:

```
1,5 2025/6- !wed
```

Means *1st and 5th day of each month from June 2025 onward, as long as it isn't Wednesday*.
`1`, `5`, `2025/6-`, `wed` are primitives. `,`, `!` and space are operators. We will take a closer
look at them in the following chapters.

Note that the application can be run as `plany play`, which allows for testing different data specs.

### Primitives

#### Literal

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

#### *Triple*

Triple consists of one, two or three integers separated by `/`. Following logic applies:

- Single digit denotes day of a month if it is lower or equal 31. Otherwise it denotes a year.
- Two digits denote a month and day of that month if the first digit is lower or equal 12. Otherwise they denote a year and month.
- Three digits denote a year, month and day respectively.


#### *Prefix*

There are following primitives of this type:

- `qX`, where X is form 1 to 4. This denotes quarter of a year. E.g. `q2` is the same as `apr may jun`.
- `mX`, where X is from 1 to 12. This denotes a month. E.g. `m6` is the same as `june`.

Internally prefixes are translated to other expressions, e.g. *triples* or *ranges*.


### Operators

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

## Configuration Files

Configuration files should be placed in `$XDG_CONFIG_HOME/plany` (typically `~/.config/plany`).

There is currently one configuration file required: `views.yaml`. It should contain a dictionary where keys
are names of the *views* and values are lists of paths. Paths point to the branches or leaves in the data files. Each path corresponds to a single row in the user interface.

For an example take a look at `example/config/views.yaml`.

**Currently only one view called `default` is supported.**

## Installation

Currently we don't distribute binaries. Only installation from sources is available:

1. Install [crystal](https://crystal-lang.org/) ~1.11.2 compiler.
2. Clone this repository and enter into it.
3. Build executable and copy to the place of you choice.

```sh
shards build --production --release --no-debug
cp bin/plany ~/.local/bin/
```

## Development

Building:

```sh
shards build --debug
```

Running tests:

```sh
crystal spec
```

### ToDo

- Support multiple views
- Implement vertical scroll bar
- Consider new primitives in the date specs
