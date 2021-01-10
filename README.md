# dterminal

Cross-platform Terminal/TTY utils. Supports:

* Colorful output
* Status line (e.g. for progress bar)

Works for Windows and Unix, fallbacks on other platforms.

## dterm: simple procedural API

`SetTerminalColor` changes color of followed `Write`/`Writeln` calls (for both
stdout and stderr):

```pascal
uses
  dterm;


// print colorful text
SetTerminalColor(TERMINAL_COLOR_GREEN);
Write('Hello ');
SetTerminalColor(TERMINAL_COLOR_YELLOW);
Write('world');
SetTerminalColor(TERMINAL_COLOR_MAGENTA);
Write('!');
Writeln;

// always restore default colors
ResetTerminalColor;
```

See [colors](example/colors/colors.pas) example.

Progress bar starts with `StartTerminalStatusLine('Initial status')` and finishes
with `FinishTerminalStatusLine`. Write and Writeln are not allowed between these
two calls, use `UpdateTerminalStatusLine('New status')`. See
[progressbar](example/progressbar/progressbar.pas) example.

## Terminal or not?

`IsStdoutTerminal` return true whenever output is a terminal. This may be used for teawking output, e.g. how ls works: by default it prints a "human readable" table if output is a terminal and a sequence of lines otherwise.

`IsStderrTerminal` is for stderr.

Colors and status line are automatically disabled for non-terminal pipes.

## dterminal: wrapper unit

[dterm](dterm.pas) unit provides stateless interface: it does not know which
funcions did you call before, are we in status line, what color is set now etc.
It's client responsibility in restoring terminal state.

[dterminal](dterminal.pas) unit implements a wrapper object TTerminal. For now
it does not do much more than the dterm. It provides similar interface,
additionaly it keeps tacking if we are in staus line or not (with
TTerminal.InStatusLine) and auto resets state in destructor.

```pascal
uses
  dterm,
  dterminal;

var
  Terminal: TTerminal;

begin
  Terminal.Init;

  Terminal.SetColor(TERMINAL_COLOR_GREEN);
  Writeln('Hello world!');

  Terminal.Done;
end;
```

See [example](example/terminal/terminal.pas).
