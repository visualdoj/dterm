{$MODE FPC}
{$MODESWITCH DEFAULTPARAMETERS}
{$MODESWITCH OUT}
{$MODESWITCH RESULT}

uses
  sysutils,
  dterm;

procedure WriteLabel(S: AnsiString; Color: TTerminalColor);
begin
  SetTerminalColor(Color);
  while Length(S) < 10 do
    S := S + ' ';
  Write(S);
end;

procedure WriteLabelBackground(S: AnsiString; Color: TTerminalColor);
begin
  SetTerminalColor(TERMINAL_COLOR_DEFAULT, Color);
  Write(S);
  SetTerminalColor(TERMINAL_COLOR_DEFAULT, TERMINAL_COLOR_DEFAULT);
  while Length(S) < 10 do begin
    S := S + ' ';
    Write(' ');
  end;
end;

procedure DrawLine(DirR, DirG, DirB: LongInt);
const
  W = 60;
var
  I: LongInt;
begin
  for I := 0 to W - 1 do begin
    SetTerminalRGB(DirR * Round(I/W*255),
                   DirG * Round(I/W*255),
                   DirB * Round(I/W*255));
    Write('#');
  end;
  Writeln;
end;

var
  I, J: LongInt;

begin
  WriteLabel('default:', TERMINAL_COLOR_DEFAULT);
  WriteLabel('red', TERMINAL_COLOR_RED);
  WriteLabel('green', TERMINAL_COLOR_GREEN);
  WriteLabel('blue', TERMINAL_COLOR_BLUE);
  WriteLabel('yellow', TERMINAL_COLOR_YELLOW);
  WriteLabel('magenta', TERMINAL_COLOR_MAGENTA);
  WriteLabel('cyan', TERMINAL_COLOR_CYAN);
  WriteLabel('white', TERMINAL_COLOR_WHITE);
  Writeln;

  WriteLabel('bright:', TERMINAL_COLOR_DEFAULT);
  WriteLabel('red', TERMINAL_COLOR_BRIGHT_RED);
  WriteLabel('green', TERMINAL_COLOR_BRIGHT_GREEN);
  WriteLabel('blue', TERMINAL_COLOR_BRIGHT_BLUE);
  WriteLabel('yellow', TERMINAL_COLOR_BRIGHT_YELLOW);
  WriteLabel('magenta', TERMINAL_COLOR_BRIGHT_MAGENTA);
  WriteLabel('cyan', TERMINAL_COLOR_BRIGHT_CYAN);
  WriteLabel('white', TERMINAL_COLOR_BRIGHT_WHITE);
  Writeln;

  WriteLabelBackground('backgrnd:', TERMINAL_COLOR_DEFAULT);
  WriteLabelBackground('red', TERMINAL_COLOR_RED);
  WriteLabelBackground('green', TERMINAL_COLOR_GREEN);
  WriteLabelBackground('blue', TERMINAL_COLOR_BLUE);
  WriteLabelBackground('yellow', TERMINAL_COLOR_YELLOW);
  WriteLabelBackground('magenta', TERMINAL_COLOR_MAGENTA);
  WriteLabelBackground('cyan', TERMINAL_COLOR_CYAN);
  WriteLabelBackground('white', TERMINAL_COLOR_WHITE);
  Writeln;

  WriteLabelBackground('', TERMINAL_COLOR_DEFAULT);
  WriteLabelBackground('red', TERMINAL_COLOR_BRIGHT_RED);
  WriteLabelBackground('green', TERMINAL_COLOR_BRIGHT_GREEN);
  WriteLabelBackground('blue', TERMINAL_COLOR_BRIGHT_BLUE);
  WriteLabelBackground('yellow', TERMINAL_COLOR_BRIGHT_YELLOW);
  WriteLabelBackground('magenta', TERMINAL_COLOR_BRIGHT_MAGENTA);
  WriteLabelBackground('cyan', TERMINAL_COLOR_BRIGHT_CYAN);
  WriteLabelBackground('white', TERMINAL_COLOR_BRIGHT_WHITE);
  Writeln;

  SetTerminalColor(TERMINAL_COLOR_BLACK, TERMINAL_COLOR_WHITE);
  Write('black on white ');
  SetTerminalColor(TERMINAL_COLOR_GRAY, TERMINAL_COLOR_WHITE);
  Write('gray on white ');
  SetTerminalColor(TERMINAL_COLOR_WHITE, TERMINAL_COLOR_GRAY);
  Write('white on gray ');
  ResetTerminalColor;
  Writeln;

  DrawLine(1, 0, 0);
  DrawLine(0, 1, 0);
  DrawLine(0, 0, 1);
  DrawLine(1, 1, 0);
  DrawLine(1, 0, 1);
  DrawLine(0, 1, 1);
  DrawLine(1, 1, 1);

  ResetTerminalColor;
end.
