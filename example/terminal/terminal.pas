{$MODE FPC}
{$MODESWITCH DEFAULTPARAMETERS}
{$MODESWITCH OUT}
{$MODESWITCH RESULT}

uses
  sysutils,
  dterm,
  dterminal;

var
  Terminal: TTerminal;

begin
  Terminal.Init;

  Terminal.SetColor(TERMINAL_COLOR_RED);
  Write('red ');
  Terminal.SetColor(TERMINAL_COLOR_GREEN);
  Write('green ');
  Terminal.SetColor(TERMINAL_COLOR_BLUE);
  Writeln('blue');

  Terminal.ResetColor;
  Terminal.StartStatusLine('status line 1');
  Terminal.UpdateStatusLine('in status line 1: ' + IntToStr(Ord(Terminal.InStatusLine)));
  Terminal.UpdateStatusLine('status line 2');
  Terminal.UpdateStatusLine('in status line 2: ' + IntToStr(Ord(Terminal.InStatusLine)));

  Terminal.Done;
end.
