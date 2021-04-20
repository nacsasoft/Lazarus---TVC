unit mainunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtDlgs, global, {$ifdef LINUX}gtk2, gdk2, Clipbrd{$endif};

type
  tvcPixel16 = record
    r,g,b : byte;
    tvcColor : byte;           //0-15 színek
    tvcPontID : byte;          //16 színnél a pont azáma 1 v. 2 (byte-on belüli)
  end;

  { TForm1 }

  TForm1 = class(TForm)
    btnKonvertKep : TButton;
    btnASMKepadat : TButton;
    btnKonvertalas : TButton;
    edtSpriteSzelesseg : TEdit;
    edtSpriteMagassag : TEdit;
    edtAsmKepazonosito : TEdit;
    edtAdatPerSor : TEdit;
    edtImage : TEdit;
    edtAsmData : TEdit;
    Label1 : TLabel;
    Label2 : TLabel;
    Label3 : TLabel;
    Label4 : TLabel;
    Label5 : TLabel;
    Label6 : TLabel;
    Label8 : TLabel;
    Memo1 : TMemo;
    OpenDialog1 : TOpenDialog;
    SaveDialog1 : TSaveDialog;
  procedure btnASMKepadatClick(Sender : TObject);
  procedure btnKonvertalasClick(Sender : TObject);
  procedure btnKonvertKepClick(Sender : TObject);
  procedure FormActivate(Sender: TObject);
  procedure FormClose(Sender : TObject; var CloseAction : TCloseAction);
  private

  asmColorValue : array of integer;

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormActivate(Sender: TObject);
begin

end;

procedure TForm1.FormClose(Sender : TObject; var CloseAction : TCloseAction);
var
  c: PGtkClipboard;
  t: string;
begin
    {$ifdef LINUX}
    c := gtk_clipboard_get(GDK_SELECTION_CLIPBOARD);
    t := Clipboard.AsText;
    gtk_clipboard_set_text(c, PChar(t), Length(t));
    gtk_clipboard_store(c);
    {$endif}

end;

procedure TForm1.btnKonvertKepClick(Sender : TObject);
var
  sFileName                                : string;

begin
    OpenDialog1.Filter := 'GIMP nyers képadat fájl|*.data';
    if OpenDialog1.Execute then
       edtImage.Text := OpenDialog1.FileName;
    sFileName := ExtractFileName(OpenDialog1.FileName);
    Delete(sFileName,Length(sFileName)-4,5);
    edtAsmKepazonosito.Text := sFileName;
end;

procedure TForm1.btnASMKepadatClick(Sender : TObject);
begin
  if SaveDialog1.Execute then
  begin
    edtAsmData.Text := SaveDialog1.FileName;
  end;
end;

procedure TForm1.btnKonvertalasClick(Sender : TObject);
var
    tfIn                  : file of byte; //kép fájl
    tfOut                 : TextFile;
    sOutFile              : string;
    r,g,b,ff              : byte;           //rgb (az ff-et berakja a gimp...) pixel adat (bájtban!!) 16 szín
    p1color,p2color       : integer;

    sImageFile            : string;
    i,j                   : integer;

begin

  if Trim(edtImage.Text) = '' then
  begin
    ShowMessage('Nincs kiválasztva a konvertálandó kép adatfájl!');
    edtAsmKepazonosito.SetFocus;
    exit;
  end;

  if Trim(edtAsmData.Text) = '' then
  begin
    ShowMessage('Nincs beállítva az assembly adatfájl!');
    edtAsmData.SetFocus;
    exit;
  end;

  if Trim(edtAsmKepazonosito.Text) = '' then
  begin
    ShowMessage('Sprite név nincs beállítva!');
    edtAsmKepazonosito.SetFocus;
    exit;
  end;

  if StrToInt(edtSpriteSzelesseg.Text) < 1 then
  begin
    ShowMessage('Sprite szélessége túl kicsi!');
    edtSpriteSzelesseg.SetFocus;
    exit;
  end;

  if StrToInt(edtSpriteMagassag.Text) < 1 then
  begin
    ShowMessage('Sprite magassága túl kicsi!');
    edtSpriteMagassag.SetFocus;
    exit;
  end;

  sImageFile := edtImage.Text;  //ExtractFilePath(ParamStr(0)) + 'image/Arany.data';
  AssignFile(tfIn, sImageFile);

  try
    // fájl megnyitása olvasásra
    Reset(tfIn);

    // összes pixel adat beolvasása:
    i := 1;
    while not eof(tfIn) do
    begin
      SetLength(asmColorValue, i);
      read(tfIn, r);
      read(tfIn, g);
      read(tfIn, b);
      read(tfIn, ff);
      p1color := rgbToPixelValue(r,g,b,1);

      read(tfIn, r);
      read(tfIn, g);
      read(tfIn, b);
      read(tfIn, ff);
      p2color := rgbToPixelValue(r,g,b,2);

      asmColorValue[i-1] := p1color + p2color;
      Inc(i);
    end;

    // fájl bezárása:
    CloseFile(tfIn);

  except
    on E: EInOutError do
     ShowMessage('Fájlkezelési hiba. Részletek: ' + E.Message);
  end;

  //konvertált adatok kimentése:
  sImageFile := edtAsmData.Text;
  AssignFile(tfOut, sImageFile);

  Rewrite(tfOut);

  Memo1.Clear;

  sOutFile := edtAsmKepazonosito.Text + #9 + 'DB' + #9 +
              edtSpriteSzelesseg.Text + ', ' + edtSpriteMagassag.Text + ', ' + #10 + #9 + #9;

  j := 0;
  for i := 0 to Length(asmColorValue) - 1 do
  begin

    if j = StrToInt(edtAdatPerSor.Text) then
    begin
         sOutFile := sOutFile + #10; //új sor...
         sOutFile := sOutFile + #9 + #9;
         j := 0;
    end;
    sOutFile := sOutFile + IntToStr(asmColorValue[i]);
    if i < Length(asmColorValue) - 1 then sOutFile := sOutFile + ', ';
    Inc(j);
  end;

  Write(tfOut,sOutFile);
  CloseFile(tfOut);

  Memo1.Text := sOutFile;
  Memo1.SelectAll;
  Clipboard.AsText := Memo1.Text;

  ShowMessage('Konvertálás sikerült!' + #10 + 'A konvertált adatok a vágólapra is ki lettek másolva!!');

end;

end.

