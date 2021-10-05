## Token files
ls3all-realization.tok has all the tokens for the vowel experiment. There are 400,000 tokens.

## Tables
A tab file is a table of vowel realizations.  Make a table file for `CANae1` like this.
```
make CANae1.tab
cat ls3all-realization.hist | awk '$2=="CANae1" {print}' | sort -nr > CANae1.tab
```
