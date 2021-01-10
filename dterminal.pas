unit dterminal;

{$MODE FPC}
{$MODESWITCH DEFAULTPARAMETERS}
{$MODESWITCH OUT}
{$MODESWITCH RESULT}

interface

uses
  dterm;

type
  TTerminalColor = dterm.TTerminalColor;

TTerminal = object
public
  procedure Init;
  procedure Done;
  procedure SetColor(Color: TTerminalColor; BackgroundColor: TTerminalColor = TERMINAL_COLOR_DEFAULT);
  procedure ResetColor;
  procedure StartStatusLine(const Line: AnsiString = '');
  procedure UpdateStatusLine(Line: AnsiString);
  procedure FinishStatusLine;
private
  FInStatusLine: Boolean;
public
  property InStatusLine: Boolean read FInStatusLine;
end;

implementation

procedure TTerminal.Init;
begin
  FInStatusLine := False;
end;

procedure TTerminal.Done;
begin
  if FInStatusLine then
    FinishStatusLine;
  ResetTerminalColor;
end;

procedure TTerminal.SetColor(Color: TTerminalColor; BackgroundColor: TTerminalColor);
begin
  SetTerminalColor(Color, BackgroundColor);
end;

procedure TTerminal.ResetColor;
begin
  ResetTerminalColor;
end;

procedure TTerminal.StartStatusLine(const Line: AnsiString = '');
begin
  if FInStatusLine then begin
    UpdateStatusLine(Line);
    Exit;
  end;
  StartTerminalStatusLine(Line);
  FInStatusLine := True;
end;

procedure TTerminal.UpdateStatusLine(Line: AnsiString);
begin
  if not FInStatusLine then
    Exit;
  UpdateTerminalStatusLine(Line);
end;

procedure TTerminal.FinishStatusLine;
begin
  if not FInStatusLine then
    Exit;
  FinishTerminalStatusLine;
  FInStatusLine := False;
end;

end.
