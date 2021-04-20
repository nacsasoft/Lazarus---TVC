unit editor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ColorBox, StdCtrls;

type

  { TfrmEditor }

  TfrmEditor = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    shpAktivSzin: TShape;
    shpFeher: TShape;
    shpFekete1: TShape;
    shpFekete2: TShape;
    shpKek: TShape;
    shpKekeszold: TShape;
    shpLila: TShape;
    shpSarga: TShape;
    shpSKek: TShape;
    shpSKekeszold: TShape;
    shpSLila: TShape;
    shpSSarga: TShape;
    shpSVoros: TShape;
    shpSZold: TShape;
    shpSzurke: TShape;
    shpVoros: TShape;
    shpZold: TShape;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure shpFeherMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shpFekete1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shpFekete2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shpKekeszoldMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shpKekMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shpLilaMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shpSargaMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shpSKekeszoldMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shpSKekMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shpSLilaMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shpSSargaMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shpSVorosMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shpSZoldMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shpSzurkeMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shpVorosMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shpZoldMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private

  public

  end;

var
  frmEditor: TfrmEditor;

implementation

{$R *.lfm}

{ TfrmEditor }

uses
  mainunit;

procedure TfrmEditor.FormActivate(Sender: TObject);
begin


end;

procedure TfrmEditor.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  frmEditor.Hide;
  frmMain.Show;
end;

procedure TfrmEditor.shpFeherMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  shpAktivSzin.Brush.Color:=shpFeher.Brush.Color;
end;

procedure TfrmEditor.shpFekete1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  shpAktivSzin.Brush.Color:=shpFekete1.Brush.Color;
end;

procedure TfrmEditor.shpFekete2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  shpAktivSzin.Brush.Color:=shpFekete2.Brush.Color;
end;

procedure TfrmEditor.shpKekeszoldMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  shpAktivSzin.Brush.Color:=shpKekeszold.Brush.Color;
end;

procedure TfrmEditor.shpKekMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  shpAktivSzin.Brush.Color:=shpKek.Brush.Color;
end;

procedure TfrmEditor.shpLilaMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  shpAktivSzin.Brush.Color:=shpLila.Brush.Color;
end;

procedure TfrmEditor.shpSargaMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  shpAktivSzin.Brush.Color:=shpSarga.Brush.Color;
end;

procedure TfrmEditor.shpSKekeszoldMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  shpAktivSzin.Brush.Color:=shpSKekeszold.Brush.Color;
end;

procedure TfrmEditor.shpSKekMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  shpAktivSzin.Brush.Color:=shpSKek.Brush.Color;
end;

procedure TfrmEditor.shpSLilaMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  shpAktivSzin.Brush.Color:=shpSLila.Brush.Color;
end;

procedure TfrmEditor.shpSSargaMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  shpAktivSzin.Brush.Color:=shpSSarga.Brush.Color;
end;

procedure TfrmEditor.shpSVorosMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  shpAktivSzin.Brush.Color:=shpSVoros.Brush.Color;
end;

procedure TfrmEditor.shpSZoldMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  shpAktivSzin.Brush.Color:=shpSZold.Brush.Color;
end;

procedure TfrmEditor.shpSzurkeMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  shpAktivSzin.Brush.Color:=shpSzurke.Brush.Color;
end;

procedure TfrmEditor.shpVorosMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  shpAktivSzin.Brush.Color:=shpVoros.Brush.Color;
end;

procedure TfrmEditor.shpZoldMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  shpAktivSzin.Brush.Color:=shpZold.Brush.Color;
end;

end.

