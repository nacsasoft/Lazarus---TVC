unit mainunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnOK: TButton;
    edtSzelesseg: TEdit;
    edtMagassag: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    RadioGroup1: TRadioGroup;
    procedure btnOKClick(Sender: TObject);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

uses
  editor;

procedure TfrmMain.btnOKClick(Sender: TObject);
begin
  frmMain.Hide;
  frmEditor.Show;
end;

end.

