unit dterm;

// Cross-platform Terminal/TTY utils:
//  * Colorful output
//  * Status line (e.g. for progress bar)

{$MODE FPC}
{$MODESWITCH DEFAULTPARAMETERS}
{$MODESWITCH OUT}
{$MODESWITCH RESULT}

interface

type
TTerminalColor = (
  TERMINAL_COLOR_DEFAULT = 0,
  TERMINAL_COLOR_BLACK,
  TERMINAL_COLOR_RED,
  TERMINAL_COLOR_GREEN,
  TERMINAL_COLOR_BLUE,
  TERMINAL_COLOR_YELLOW,
  TERMINAL_COLOR_MAGENTA,
  TERMINAL_COLOR_CYAN,
  TERMINAL_COLOR_WHITE,
  TERMINAL_COLOR_BRIGHT_BLACK,
  TERMINAL_COLOR_BRIGHT_RED,
  TERMINAL_COLOR_BRIGHT_GREEN,
  TERMINAL_COLOR_BRIGHT_BLUE,
  TERMINAL_COLOR_BRIGHT_YELLOW,
  TERMINAL_COLOR_BRIGHT_MAGENTA,
  TERMINAL_COLOR_BRIGHT_CYAN,
  TERMINAL_COLOR_BRIGHT_WHITE
);

const
  // additional constants
  TERMINAL_COLOR_GRAY = TERMINAL_COLOR_BRIGHT_BLACK;

function IsStdoutTerminal: Boolean;
function IsStderrTerminal: Boolean;

procedure ResetTerminalColor;
procedure SetTerminalColor(Color: TTerminalColor; BackgroundColor: TTerminalColor = TERMINAL_COLOR_DEFAULT);
procedure SetTerminalRGB(R, G, B: Byte; BackR: Byte = 0; BackG: Byte = 0; BackB: Byte = 0);

procedure StartTerminalStatusLine(const Line: AnsiString = '');
procedure UpdateTerminalStatusLine(Line: AnsiString);
procedure FinishTerminalStatusLine;

implementation

{$IF Defined(UNIX)}
uses
  BaseUnix, // FpIOCtl, see UNIX_GetTerminalWidth
  termio; // IsATTY
{$ELSEIF Defined(WINDOWS)}
uses
  windows;
{$ENDIF}

{$IF Defined(UNIX)}
const
UNIX_COLORS: array[TTerminalColor] of PAnsiChar = (
  #27'[1;0m',
  #27'[1;30m',
  #27'[1;31m',
  #27'[1;32m',
  #27'[1;34m',
  #27'[1;33m',
  #27'[1;35m',
  #27'[1;36m',
  #27'[1;37m',
  #27'[1;90m',
  #27'[1;91m',
  #27'[1;92m',
  #27'[1;94m',
  #27'[1;93m',
  #27'[1;95m',
  #27'[1;96m',
  #27'[1;97m'
);
UNIX_BACKGROUND_COLORS: array[TTerminalColor] of PAnsiChar = (
  #27'[1;0m',
  #27'[1;40m',
  #27'[1;41m',
  #27'[1;42m',
  #27'[1;44m',
  #27'[1;43m',
  #27'[1;45m',
  #27'[1;46m',
  #27'[1;47m',
  #27'[1;100m',
  #27'[1;101m',
  #27'[1;102m',
  #27'[1;104m',
  #27'[1;103m',
  #27'[1;105m',
  #27'[1;106m',
  #27'[1;107m'
);

procedure UNIX_SetColor(var Handle: TextFile; Color, BackgroundColor: TTerminalColor); inline;
begin
  Write(Handle, #27'[1;0m');
  if Color <> TERMINAL_COLOR_DEFAULT then
    Write(Handle, UNIX_COLORS[Color]);
  if BackgroundColor <> TERMINAL_COLOR_DEFAULT then
    Write(Handle, UNIX_BACKGROUND_COLORS[BackgroundColor]);
end;

procedure UNIX_SetRGB(var Handle: TextFile; R, G, B, BackR, BackG, BackB: Byte);
begin
  Write(Handle, #27'[38;5;', (R div 51) * 36 + (G div 51) * 6 + (B div 51) + 16, 'm',
                #27'[48;5;', (BackR div 51) * 36 + (BackG div 51) * 6 + (BackB div 51) + 16, 'm');
end;

function UNIX_GetTerminalWidth(var Handle: TextFile): PtrInt;
var
  ws: TWinSize;
begin
  FpIOCtl(textrec(Handle).handle, TIOCGWINSZ, @ws);
  Exit(ws.ws_col);
end;
{$ENDIF}

{$IF Defined(WINDOWS)}
const
WINAPI_COLORS: array[TTerminalColor] of UInt16 = (
  windows.FOREGROUND_RED or windows.FOREGROUND_GREEN or windows.FOREGROUND_BLUE,
  0,
  windows.FOREGROUND_RED,
  windows.FOREGROUND_GREEN,
  windows.FOREGROUND_BLUE,
  windows.FOREGROUND_RED or windows.FOREGROUND_GREEN,
  windows.FOREGROUND_RED or windows.FOREGROUND_BLUE,
  windows.FOREGROUND_GREEN or windows.FOREGROUND_BLUE,
  windows.FOREGROUND_RED or windows.FOREGROUND_GREEN or windows.FOREGROUND_BLUE,
  FOREGROUND_INTENSITY,
  windows.FOREGROUND_RED or FOREGROUND_INTENSITY,
  windows.FOREGROUND_GREEN or FOREGROUND_INTENSITY,
  windows.FOREGROUND_BLUE or FOREGROUND_INTENSITY,
  windows.FOREGROUND_RED or windows.FOREGROUND_GREEN or FOREGROUND_INTENSITY,
  windows.FOREGROUND_RED or windows.FOREGROUND_BLUE or FOREGROUND_INTENSITY,
  windows.FOREGROUND_GREEN or windows.FOREGROUND_BLUE or FOREGROUND_INTENSITY,
  windows.FOREGROUND_RED or windows.FOREGROUND_GREEN or windows.FOREGROUND_BLUE or FOREGROUND_INTENSITY
);
WINAPI_BACKGROUND_COLORS: array[TTerminalColor] of UInt16 = (
  0,
  0,
  windows.BACKGROUND_RED,
  windows.BACKGROUND_GREEN,
  windows.BACKGROUND_BLUE,
  windows.BACKGROUND_RED or windows.BACKGROUND_GREEN,
  windows.BACKGROUND_RED or windows.BACKGROUND_BLUE,
  windows.BACKGROUND_GREEN or windows.BACKGROUND_BLUE,
  windows.BACKGROUND_RED or windows.BACKGROUND_GREEN or windows.BACKGROUND_BLUE,
  BACKGROUND_INTENSITY,
  windows.BACKGROUND_RED or BACKGROUND_INTENSITY,
  windows.BACKGROUND_GREEN or BACKGROUND_INTENSITY,
  windows.BACKGROUND_BLUE or BACKGROUND_INTENSITY,
  windows.BACKGROUND_RED or windows.BACKGROUND_GREEN or BACKGROUND_INTENSITY,
  windows.BACKGROUND_RED or windows.BACKGROUND_BLUE or BACKGROUND_INTENSITY,
  windows.BACKGROUND_GREEN or windows.BACKGROUND_BLUE or BACKGROUND_INTENSITY,
  windows.BACKGROUND_RED or windows.BACKGROUND_GREEN or windows.BACKGROUND_BLUE or BACKGROUND_INTENSITY
);

procedure WinApi_SetColor(Handle: windows.DWORD; Color, BackgroundColor: TTerminalColor); inline;
begin
  windows.SetConsoleTextAttribute(Handle, WINAPI_COLORS[Color] or WINAPI_BACKGROUND_COLORS[BackgroundColor]);
end;

procedure WinApi_SetRGB(Handle: windows.DWORD; R, G, B, BackR, BackG, BackB: Byte); inline;
var
  Color: UInt16;
begin
  Color := (Ord(R > 0) * windows.FOREGROUND_RED)
        or (Ord(G > 0) * windows.FOREGROUND_GREEN)
        or (Ord(B > 0) * windows.FOREGROUND_BLUE)
        or (Ord(R or G or B > 127) * windows.FOREGROUND_INTENSITY)
        or (Ord(BackR > 0) * windows.BACKGROUND_RED)
        or (Ord(BackG > 0) * windows.BACKGROUND_GREEN)
        or (Ord(BackB > 0) * windows.BACKGROUND_BLUE)
        or (Ord(BackR or BackG or BackB > 127) * windows.BACKGROUND_INTENSITY);
  windows.SetConsoleTextAttribute(Handle, Color);
end;

function WinApi_GetTerminalWidth(Handle: windows.DWORD): DWORD;
var
  c: windows.CONSOLE_SCREEN_BUFFER_INFO;
begin
  if GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), @c) then
    Exit(c.srWindow.Right - c.srWindow.Left);
  Exit(0); // not a terminal
end;
{$ENDIF}

function IsStdoutTerminal: Boolean;
{$IF Defined(WINDOWS)}
var
  Handle: windows.HANDLE;
{$ENDIF}
begin
{$IF Defined(UNIX)}
  Exit(IsATTY(output) = 1);
{$ELSEIF Defined(WINDOWS)}
  Handle := windows.GetStdHandle(windows.STD_OUTPUT_HANDLE);
  Exit(GetFileType(Handle) = FILE_TYPE_CHAR);
{$ELSE}
  Exit(False);
{$ENDIF}
end;

function IsStderrTerminal: Boolean;
{$IF Defined(WINDOWS)}
var
  Handle: windows.HANDLE;
{$ENDIF}
begin
{$IF Defined(UNIX)}
  Exit(IsATTY(stderr) = 1);
{$ELSEIF Defined(WINDOWS)}
  Handle := windows.GetStdHandle(windows.STD_ERROR_HANDLE);
  Exit(GetFileType(Handle) = FILE_TYPE_CHAR);
{$ELSE}
  Result := False;
{$ENDIF}
end;

procedure ResetTerminalColor;
begin
  SetTerminalColor(TERMINAL_COLOR_DEFAULT);
end;

procedure SetTerminalColor(Color: TTerminalColor; BackgroundColor: TTerminalColor = TERMINAL_COLOR_DEFAULT);
begin
{$IF Defined(UNIX)}
  if IsStdoutTerminal then
    UNIX_SetColor(output, Color, BackgroundColor);
  if IsStderrTerminal then
    UNIX_SetColor(stderr, Color, BackgroundColor);
{$ELSEIF Defined(WINDOWS)}
  if IsStdoutTerminal then
    WinApi_SetColor(windows.GetStdHandle(windows.STD_OUTPUT_HANDLE), Color, BackgroundColor);
  if IsStderrTerminal then
    WinApi_SetColor(windows.GetStdHandle(windows.STD_ERROR_HANDLE), Color, BackgroundColor);
{$ELSE}
  // Do nothing
{$ENDIF}
end;

procedure SetTerminalRGB(R, G, B: Byte; BackR: Byte = 0; BackG: Byte = 0; BackB: Byte = 0);
begin
{$IF Defined(UNIX)}
  if IsStdoutTerminal then
    UNIX_SetRGB(output, R, G, B, BackR, BackG, BackB);
  if IsStderrTerminal then
    UNIX_SetRGB(stderr, R, G, B, BackR, BackG, BackB);
{$ELSEIF Defined(WINDOWS)}
  if IsStdoutTerminal then
    WinApi_SetRGB(windows.GetStdHandle(windows.STD_OUTPUT_HANDLE), R, G, B, BackR, BackG, BackB);
  if IsStderrTerminal then
    WinApi_SetRGB(windows.GetStdHandle(windows.STD_ERROR_HANDLE), R, G, B, BackR, BackG, BackB);
{$ELSE}
  // Do nothing
{$ENDIF}
end;

procedure StartTerminalStatusLine(const Line: AnsiString = '');
begin
  if not IsStdoutTerminal then begin
    Writeln(Line);
    Exit;
  end;
{$IF Defined(UNIX) or Defined(WINDOWS)}
  // Nothing to do here
{$ENDIF}
  UpdateTerminalStatusLine(Line);
end;

procedure UpdateTerminalStatusLine(Line: AnsiString);
var
  TerminalWidth: PtrInt;
begin
  if not IsStdoutTerminal then begin
    Writeln(Line);
    Exit;
  end;
{$IF Defined(UNIX)}
  TerminalWidth := UNIX_GetTerminalWidth(output);
  if TerminalWidth <= 0 then
    TerminalWidth := 60;
  // Clear previous status line first
  Write(#$0D);
  Write(Space(TerminalWidth));
  // Now the actual output
  if Length(Line) > TerminalWidth then
    SetLength(Line, TerminalWidth);
  Write(#$0D);
  Write(Line);
{$ELSEIF Defined(WINDOWS)}
  TerminalWidth := WinApi_GetTerminalWidth(windows.GetStdHandle(windows.STD_OUTPUT_HANDLE));
  if TerminalWidth <= 0 then
    TerminalWidth := 60;
  // Clear previous status line first
  Write(#$0D);
  Write(Space(TerminalWidth));
  // Now the actual output
  if Length(Line) > TerminalWidth then
    SetLength(Line, TerminalWidth);
  Write(#$0D);
  Write(Line);
{$ELSE}
  Writeln(Line);
{$ENDIF}
end;

procedure FinishTerminalStatusLine;
begin
  if not IsStdoutTerminal then
    Exit;
{$IF Defined(UNIX) or Defined(WINDOWS)}
  Writeln;
{$ENDIF}
end;

end.
