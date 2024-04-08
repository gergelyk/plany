# Event Formats

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
