{$MODE FPC}
{$MODESWITCH DEFAULTPARAMETERS}
{$MODESWITCH OUT}
{$MODESWITCH RESULT}

uses
  sysutils,
  dateutils,
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

function ModDiv(var V: PtrUInt; Q: PtrUInt): PtrUInt;
begin
  Result := V mod Q;
  V := V div Q;
end;

function StrDecimal(V: PtrUInt; Digits: PtrUInt): AnsiString;
begin
  Str(V, Result);
  while Length(Result) > Digits do
    SetLength(Result, Length(Result) - 1);
  while Length(Result) < Digits do
    Result := '0' + Result;
end;

var
  StartTime: TDateTime;
  Delta: PtrUInt;
  Ms, S, M, H: PtrUInt;
begin
  SysSetCtrlBreakHandler(@OnCtrlC);

  StartTerminalStatusLine;

  StartTime := SysUtils.Now;
  while True do begin
    Delta := DateUtils.MilliSecondsBetween(StartTime, SysUtils.Now);
    Ms := ModDiv(Delta, 1000);
    S := ModDiv(Delta, 60);
    M := ModDiv(Delta, 60);
    H := ModDiv(Delta, 24);
    UpdateTerminalStatusLine('uptime: ' +
                             StrDecimal(H, 2) + ':' +
                             StrDecimal(M, 2) + ':' +
                             StrDecimal(S, 2) + '.' +
                             StrDecimal(Ms, 3));
    Sleep(1);
  end;

  FinishTerminalStatusLine;

  // don't forget to restore color
  ResetTerminalColor;
end.
