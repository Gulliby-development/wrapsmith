<p align="center"><img src="docs/logo.svg" width="96" alt="" /></p>

# wrapsmith

[![CI](https://github.com/Gulliby-development/wrapsmith/actions/workflows/ci.yml/badge.svg)](https://github.com/Gulliby-development/wrapsmith/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

wrapsmith reshapes plain ASCII text from the command line. It handles paragraph flow, alignment, indentation, numbering, whitespace, tabs, columns, boxes, tables, and statistics. It is for people who maintain plain-text documentation, README files, commit messages, and terminal output.

The module and CLI require PowerShell 7.2 or newer and run on Windows, macOS, and Linux. The runtime has no external dependency.

## Use the CLI

In a bash-compatible shell, redirect a reader-supplied file into the command:

```bash
pwsh bin/wrapsmith.ps1 fill -w 60 < in.txt
```

The file `in.txt` is supplied by you; it is not bundled with wrapsmith.

## Use the module

```powershell
Import-Module ./Wrapsmith.psd1
$result = Invoke-Wrapsmith -Argv @('fill', '-w', '60') -InputText "A paragraph`ncontinued on another line."
$result.ExitCode
$result.Out
$result.Err
```

`Invoke-Wrapsmith` returns `ExitCode`, `Out`, and `Err`. Success uses status 0 and an empty error string. A failure has empty output and an LF-terminated diagnostic. The CLI writes those strings to standard output and standard error and exits with that status.

## Commands

Command names and options are case-sensitive. Widths count characters except where tabs are explicitly expanded.

| Synopsis | Behavior |
|---|---|
| `wrap [-w N] [--break]` | Greedily wraps each input line independently; default width 72. Long words stay whole unless `--break` splits them into width-sized lines and carries the remainder forward. |
| `fill [-w N] [--sentence]` | Fills each paragraph greedily; default width 72. Paragraphs are separated by one blank line. `--sentence` inserts two spaces after words ending in ., !, or ? when another word follows on that line. |
| `justify [-w N]` | Fills paragraphs at width 72 by default, then spreads spaces across gaps on non-final multiword lines to reach the width; extra spaces go to leftmost gaps. |
| `center [-w N]` | Trims edge spaces and tabs, then centers short lines at width 72 by default. Blank and width-sized-or-longer lines stay unpadded. |
| `right [-w N]` | Trims edge spaces and tabs, then right-aligns short lines at width 72 by default. Blank and width-sized-or-longer lines stay unpadded. |
| `indent N [--hang M]` | Indents each paragraph's first line by N spaces and later lines by M (default N). N and M range from 0 to 80. Blank lines stay empty. |
| `dedent` | Removes the minimum leading-space indentation from nonblank lines; tabs are not spaces. Blank lines become empty. |
| `number [--start N] [--width W] [--skip-blank]` | Numbers lines from 1 by default. Start ranges 0–99999; width 1–9 defaults to the digits needed by the last number. `--skip-blank` leaves blank lines empty and unnumbered. |
| `trunc N [--mark S]` | Limits lines to N characters using a mark (default `...`). N ranges 1–200 and must be at least the mark length; marks are 1–10 printable characters. |
| `expand [-t N]` | Replaces tabs with spaces up to tab stops; tab size defaults to 8 and ranges 1–16. |
| `unexpand [-t N]` | Converts complete tab stops in leading whitespace to tabs and leaves remaining columns as spaces. Tab size defaults to 8 and ranges 1–16; the rest of each line is untouched. |
| `trim [--leading]` | Removes trailing spaces and tabs; `--leading` also removes them at the start. |
| `squeeze [--blank]` | Joins words with single spaces and removes surrounding whitespace. `--blank` keeps at most one blank line between text and drops blank lines at either end. |
| `cols N [-w W] [--gap G]` | Arranges lines top-to-bottom in N columns (2–8). Width defaults to the longest line or can be 1–200; gap defaults to 2 spaces and ranges 0–20. |
| `box [-w N] [--style ascii|star|hash] [--pad P]` | Frames lines at their longest width or an explicit width 1–200. Style defaults to `ascii`; padding defaults to 1 and ranges 0–8. |
| `table [--sep C] [--align SPEC] [--header]` | Splits rows at comma by default (or a literal separator from `!` through `~`, or `tab`), trims cells, and sizes columns globally. Alignment is 1–20 letters, each `l`, `r`, or `c`; unspecified columns are left-aligned. `--header` adds a rule after the first line of output. |
| `stats` | Reports lines, words, characters, longest line, paragraphs, and blank lines. |

Integer values must contain one to five unsigned decimal digits with no spaces; leading zeroes are allowed. Option ranges: `-w` 1–200, `--hang` 0–80, `--start` 0–99999, `--width` 1–9, `-t` 1–16, `--gap` 0–20, and `--pad` 0–8. Positional ranges are given in the synopsis descriptions. A literal `--sep` is one character from `!` through `~`; the word `tab` selects a tab.

## Examples

Examples pass inline LF-separated text. The shown output is exact; leading spaces are significant.

### Paragraph flow

```powershell
$r = Invoke-Wrapsmith -Argv @('fill', '-w', '24') -InputText "Plain text can flow across lines.`nwithout losing paragraph breaks."
$r.Out
```

```text
Plain text can flow
across lines. without
losing paragraph breaks.
```

### Alignment and indentation

```powershell
$r = Invoke-Wrapsmith -Argv @('center', '-w', '10') -InputText "cat`ndog`n"
$r.Out
```

```text
   cat
   dog
```

```powershell
$r = Invoke-Wrapsmith -Argv @('indent', '2', '--hang', '4') -InputText "one`ntwo`n`nthree`n"
$r.Out
```

```text
  one
    two

  three
```

### Numbering and statistics

```powershell
$r = Invoke-Wrapsmith -Argv @('number', '--start', '7', '--width', '2') -InputText "alpha`nbeta`n"
$r.Out
```

```text
 7: alpha
 8: beta
```

```powershell
$r = Invoke-Wrapsmith -Argv @('stats') -InputText "red blue`n`ngreen`n"
$r.Out
```

```text
lines 3
words 3
chars 13
longest 8
paragraphs 2
blank 1
```

### Tabs and whitespace

The input contains a tab between `a` and `b`:

```powershell
$r = Invoke-Wrapsmith -Argv @('expand', '-t', '4') -InputText "a`tb`n"
$r.Out
```

```text
a   b
```

```powershell
$r = Invoke-Wrapsmith -Argv @('trim', '--leading') -InputText "  tidy  `n`tx  `n"
$r.Out
```

```text
tidy
x
```

### Layout

```powershell
$r = Invoke-Wrapsmith -Argv @('cols', '2') -InputText "one`ntwo`nthree`nfour`n"
$r.Out
```

```text
one    three
two    four
```

## Text and output rules

Input splits at LF. A final unterminated line counts; a final LF adds no extra line; empty input has no lines. Output lines each end in LF, while no output lines produce an empty string.

Only printable ASCII (space through tilde) and tab are accepted. Carriage returns, other controls, and non-ASCII characters are rejected. A blank line is empty or contains only spaces and tabs. A word is a maximal run excluding spaces and tabs; a paragraph is a maximal run of nonblank lines. Tabs count as one character for widths except in `expand` and `unexpand`, which measure tab stops.

## Help and errors

The first argument `help`, `-h`, or `--help` prints all seventeen synopses; `--version` prints `wrapsmith 0.1.0`. Both return 0 regardless of later arguments. No arguments writes usage to standard error and returns 2. An unknown or differently cased command reports `wrapsmith: unknown command WORD` and returns 2.

Arguments are checked left-to-right, before text is inspected. Unknown options report `wrapsmith: unknown option WORD`; duplicate options report `wrapsmith: WORD given twice`; excess positional values report `wrapsmith: unexpected argument WORD`. Missing positional values report `wrapsmith: COMMAND needs N`. Bad positional integers report `wrapsmith: COMMAND needs an integer from LOW to HIGH`; bad integer options report `wrapsmith: OPTION needs an integer from LOW to HIGH`. Truncation also checks `wrapsmith: trunc needs an integer of at least the length of the mark`.

Other typed-option diagnostics are `wrapsmith: --mark needs 1 to 10 printable characters`, `wrapsmith: --style needs one of ascii, star, hash`, `wrapsmith: --sep needs one printable character or tab`, and `wrapsmith: --align needs 1 to 20 letters l, r or c`. For `--sep`, the accepted literal range is `!` through `~` (space is excluded), or the word `tab`. Invalid input reports `wrapsmith: line N has an unsupported character`. Overlong layout lines report `wrapsmith: line I is longer than the column width W` for columns or `wrapsmith: line I is longer than the box width N` for boxes. The placeholders represent the actual option, command, line number, or bound. Command-line errors return 2; text and handler errors return 1; success returns 0. Failures have empty standard output and one LF-terminated `wrapsmith: ...` standard-error line.

## Development

```powershell
Invoke-Pester
Invoke-ScriptAnalyzer -Path . -Recurse
```

To apply Script Analyzer fixes to a file:

```powershell
Invoke-ScriptAnalyzer -Fix -Path FILE
```

Pester and PSScriptAnalyzer are development tools, not runtime dependencies. See the [MIT License](LICENSE).

---

Built with [BAKED](https://github.com/Gulliby-development/baked), an open-source coding agent (bench round R84).
