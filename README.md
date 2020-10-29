# Pico-8 High Scores

## How to Use

### Demo

&#8593; - Cycle characters up/Submit score

&#8595; - Cycle characters down

&#8592; - Increase score/Select next initial

&#8594; - Decrease score/Select previous initial

`z` - Submit initials

`x` - Submit score

---

`high_score_table.update()`
- Keeps track of &#8593;, &#8595; &#8592;, &#8594;, `z`, `x` keyboard inputs for cycling characters and entering scores.
- Accumulates and is applied to `sin()` during `draw()` for animation effect.

`high_score_table.draw()`
- Draws high score table and initial entry.

### Library

`add_current_score(_value)`
- Accumulates bit shifted value in `high_score_table.current_score`

`submit_score()`
- Inserts high score into list.  For the demo this also starts initial entry state and initializes character list to default values.
- This function likely needs to be tailored specifically for the project it is included in.

`load_scores()`
- Loads high score data saved in Pico-8.
- If no data is found, initializes high score list with default values.

`save_scores()`
- Saves high score to persitant data using `dset()`

`reset_high_scores()`
- Resets persistant high score data to default values.

`get_score_text(_score_value)`
- `_score_value` is a `scores[i].score` entry in `high_score_table`.
- Converts score value to string.
- Pads score with leading zeroes.

`array_to_string(_array)`
`char_to_int(_char)`
`int_to_char(_int)`

## About

This is a fork of Persistent High Score Table Demo by Grumpydev.

The original can be found at https://www.lexaloffle.com/bbs/?tid=31901


