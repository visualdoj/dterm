{$MODE FPC}
{$MODESWITCH DEFAULTPARAMETERS}
{$MODESWITCH OUT}
{$MODESWITCH RESULT}

uses
  sysutils,
  dterm;

const
  Stage: array[0 .. 3] of Char = ('/', '-', '\', '|');

var
  I: LongInt;
  Percent: AnsiString;

//  If user interrupts the loop with Ctrl+C, color for the terminal would not
//  be restored at the end of the program, so we want to do it in the Ctrl+C
//  handler.
function OnCtrlC(CtrlBreak: Boolean): Boolean;
begin
  ResetTerminalColor;
  Exit(False);
end;

begin
  SysSetCtrlBreakHandler(@OnCtrlC);

  StartTerminalStatusLine;

  for I := 0 to 100 do begin
    Percent := IntToStr(I);
    while Length(Percent) < 3 do
      Percent := ' ' + Percent;

    case I of
      10: begin
            SetTerminalColor(TERMINAL_COLOR_GREEN);
            UpdateTerminalStatusLine('A line can be emitted while maintaining progress bar');
            FinishTerminalStatusLine;
            StartTerminalStatusLine;
            ResetTerminalColor;
          end;
      20: begin
            SetTerminalColor(TERMINAL_COLOR_YELLOW);
            UpdateTerminalStatusLine('And even');
            FinishTerminalStatusLine;
            SetTerminalColor(TERMINAL_COLOR_YELLOW);
            Writeln('several');
            Writeln('lines');
            StartTerminalStatusLine;
            ResetTerminalColor;
          end;
      30: begin
            SetTerminalColor(TERMINAL_COLOR_RED);
            UpdateTerminalStatusLine('Now just wait until 100% or interrupt it with Ctrl-C');
            FinishTerminalStatusLine;
            StartTerminalStatusLine;
            ResetTerminalColor;
          end;
    end;

    UpdateTerminalStatusLine('[' + Percent + '%]'
      + ' simulating activity '
      + Stage[I mod Length(Stage)]
      + ' (Ctrl-C to stop)');

    if ParamStr(1) <> 'nosleep' then
      Sleep(600);
  end;

  SetTerminalColor(TERMINAL_COLOR_GREEN);
  UpdateTerminalStatusLine('[100%] completed!');
  FinishTerminalStatusLine;

  // don't forget to restore color
  ResetTerminalColor;
end.
