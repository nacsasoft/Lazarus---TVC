unit Unit1;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnPascalToASM: TButton;
    GroupBox1: TGroupBox;
    OpenDialog1: TOpenDialog;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    Edit1: TEdit;
    Label2: TLabel;
    procedure btnPascalToASMClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  Type_Mas_Lib = record
    flag: boolean;
    name: string;
  end;

  Type_Mas01_Lib = record
    flag,flag_out: boolean;
    name: string;
  end;

  Type_Mas_Code = record
    com: string;
    num: longint;
    str: string;
    par1,par2,par3: string;
  end;


const
  value_mas_lib=51;
  value_mas01_lib=8;

var
  Form1: TForm1;
  Source,Dest,lib,fError : Text;
  //fCommand: Text;

  Mas_Lib: array[1..value_mas_lib] of Type_Mas_Lib;
  Mas01_Lib: array[1..value_mas01_lib] of Type_Mas01_Lib;
  CodeCounter,MaxCodeCounter: word;
  Mas_Code: array[1..65535] of Type_Mas_Code;
  curr_addr_mas_init: Word;
  Mas_Init: array[1..65535] of String[10];

implementation

{$R *.lfm}

procedure TForm1.btnPascalToASMClick(Sender: TObject);

Const

  CR  = ^M;
  LF  = ^J;
  Tab = ^I;
  HexCode   = '0123456789ABCDEF';
{
  MASM      = 'C:\MASM\MASM.EXE';
  LINK      = 'C:\OS2\LINK386.EXE';
}

Type
  Str32     = String[32];
  Token     = (_Unknown,_string_constant,_numeric_Constant,_name,
               _program,_Const,_Var,_Begin,_While,_do,_repeat,_Until,
               _Emit,
               _period,_comma,_lsqbkt,_rsqbkt,
               _plus,_minus,_mul,_div,_mod,_lparen,_rparen,_separator,
               _assign,_equal,_greater,_less,_less_eq,_greater_eq,_not_eq,
               _colon,
               _if,_then,_else,_and,_or,_case,_of,_for,_to,_downto,
               _procedure,_function,
               _delay, _Pause,
               _randomize,_random_byte,_random_word,
               _arrayclear,
               _asm,
               _end,
               _graphics,
               _videoon,
               _videooff,
               _cls,
               _PrintPlot, _PrintAt,
               _SetInk, _SetPaper, _SetBorder, _SetPalette,
               _SetChar, _PrintChar, _PrintPlotChar,
               _LineStyle, _SetMode, _Plot, _PlotRect, _Fill,
               _Get, _Inkey, _SetKeyRepeatRate, _InputAtString, _InputAtNumber,
               _Poke, _Peek,
               _AndByte, _OrByte, _XorByte,
               _GetKeyMatrixState,
               _SoundInit, _SoundStop, _SoundVolume, _SoundPlaying, _SoundPlay,
               _PutSprite);

Const
  MaxToken  = Ord(_PutSprite);

  TokenName : Array[0..MaxToken] of Str32 =
              ('','','','',
               'PROGRAM','CONST','VAR','BEGIN','WHILE','DO','REPEAT','UNTIL',
               'EMIT',
               '.',',','[',']',
               '+','-','*','/','%','(',')',';',
               ':=','=','>','<','<=','>=','<>',':',
               'IF','THEN','ELSE','AND','OR','CASE','OF','FOR','TO','DOWNTO',
               'PROCEDURE','FUNCTION',
               'DELAY', 'PAUSE',
               'RANDOMIZE','RANDOMBYTE','RANDOMWORD',
               'ARRAYCLEAR',
               'ASM',
               'END',
               'GRAPHICS',
               'VIDEOON',
               'VIDEOOFF',
               'CLS',
               'PRINTPLOT', 'PRINTAT',
               'SETINK', 'SETPAPER', 'SETBORDER', 'SETPALETTE',
               'SETCHAR', 'PRINTCHAR', 'PRINTPLOTCHAR',
               'LINESTYLE', 'SETMODE', 'PLOT', 'PLOTRECT', 'FILL',
               'GET', 'INKEY', 'SETKEYREPEATRATE', 'INPUTATSTRING', 'INPUTATNUMBER',
               'POKE', 'PEEK',
               'ANDBYTE', 'ORBYTE', 'XORBYTE',
               'GETKEYMATRIXSTATE',
               'SOUNDINIT', 'SOUNDSTOP', 'SOUNDVOLUME', 'SOUNDPLAYING', 'SOUNDPLAY',
               'PUTSPRITE');


Type
  NameStr   = String;
  LabelStr  = String;

Var
  Look           : Char;
  Current_String : String;
  Current_Token  : Token;
  Current_Number : Longint;


  Name           : String;
  LineCount      : Longint;
  GlobalLabel    : String;
  temp_name_string: String;

function  numb(i : integer):string;
var
  s : string;
begin
  str(i,s);
  numb := s;
end;

Procedure Abort(S : String); Forward;

Procedure GetChar;
begin
  if Not Eof(Source)
    then
      begin
        Read(Source,Look);
        Write(fError,Look);
      end
    else Look := '.';
  {                      Abort('Unexpected end of file'); }
  If Look = #13 then Inc(LineCount);
end;

procedure SkipSpace;
begin
  While (look in [Cr,Lf,Tab,' ']) AND (Not Eof(Source)) do
    GetChar;
end;

Procedure GetToken;
label
  restart,
  done;
var
  i,j : word;
  x   : boolean;
  last: char;
begin
RESTART:
  Current_String := '';
  Current_Token  := _Unknown;
  Current_Number := 0;
  SkipSpace;

  //ShowMessage(Look);

  Case Look of
    '{'  : begin
             repeat
               GetChar;
             until Look = '}';
             GetChar;
             Goto Restart;
           end;

    '('  : begin
             getchar;
             if look = '*' then
             begin
               getchar;
               repeat
                 last := look;
                 getchar;
               until (last = '*') and (look = ')');
               getchar;

               Goto Restart;
             end
             else
               current_token := _lparen;
           end;

    '''' : begin
             getchar;
             current_string := '';
             x := false;
             repeat
               case look of
                 cr    : abort('String exceeds line');
                 ''''  : begin
                           getchar;
                           if look <> '''' then
                             x := true
                           else
                           begin
                             current_string := current_string + look;
                             getchar;
                           end;
                         end;
               else
                 current_string := current_string + look;
                 getchar;
               end;
             until x;
             current_token := _string_constant;
           end;

    '$'  : begin
             GetChar;
             While (UpCase(Look) in ['0'..'9','A'..'F']) do
             begin
               Current_Number := Current_Number SHL 4 +
                                 Pos(UpCase(Look),HexCode)-1;
               GetChar;
             end;
             Current_Token := _numeric_constant;
           end;
    '0'..'9' : begin
                 while look in ['0'..'9'] do
                 begin
                   Current_Number := Current_Number * 10 +
                                     Pos(Look,HexCode)-1;
                   GetChar;
                 end;
                 current_token := _numeric_constant;
               end;
    '_','A'..'Z',
        'a'..'z'   : begin
                       While UpCase(Look) in ['_','0'..'9',
                                                  'A'..'Z',
                                                  'a'..'z' ] do
                       begin
                         Current_String := Current_String + UpCase(Look);
                         GetChar;

                         if UpCase(Look) in ['_','0'..'9',
                                                  'A'..'Z',
                                                  'a'..'z' ]
                         then
                         else

                         for i := 0 to MaxToken do
                           if Current_String = TokenName[i] then
                           begin
                             Current_Token := Token(i);
                          {   goto done; }
                           end;
                       end;
                       If Current_Token = _Unknown then
                         Current_Token := _name;
                     end;
  else
    Current_String := UpCase(Look); GetChar;
    Repeat
      J := 0;
      For i := 0 to MaxToken do
        if (Current_string+UpCase(Look)) = TokenName[i] then
          J := i;
      If J <> 0 then
      begin
        Current_String := Current_String + UpCase(Look);
        GetChar;
      end;
    Until J = 0;

    For i := 0 to MaxToken do
      if Current_String = TokenName[i] then
        J := i;
    Current_Token := Token(j);
  end; { Case Look }

{ If we get here, we have a string that makes no sense! }

DONE:
end;

(*********************
    Error Reporting
 *********************)

procedure Error(s : string);
begin
  Write(fError,'      << Error: ',s,' >>');
  //ShowMessage('Error: '+s+'. See file error.err');
  Writeln('Error: '+s+'. See file error.err');
  CloseFile(fError);
end;

procedure Abort(S : String);
begin
  Error(S);
  Halt;
end;

procedure Expected(s : string);
begin
  Abort(s + ' expected');
end;

(*************************
     Symbol Table Stuff
 *************************)
Const
  _Word    = 0;
  _Byte    = 1;
  _Long    = 2;
  _String = 3;
  _Void    = 4;
  _ArrayWord = 5;
  _ArrayByte = 6;
  _ArrayString = 7;
  _Array = 8;
  _ConstType = 9;

Type
  TType    = Record
               Name  : String[32];
               Size  : Word;
             End;

  TStringConst = Record
                    Name: String;
                    Len: Word;
                 End;

  Symbol   = Record
               Name  : String[32];
               Kind  : Integer;
               IsVar : Boolean;
               CountIndex: Byte;
               Index1Size : Word;
               Index2Size : Word;
               Addr_mas_init : Word;
             End;

Const
  TypeWord     : TType = (Name : '_WORD';    Size :2);
  TypeByte     : TType = (Name : '_BYTE';    Size :1);
  TypeLong     : TType = (Name : '_LONG';    Size :4);
  TypeString   : TType = (Name : '_STRING';    Size :2);
  TypeVoid     : TType = (Name : '_VOID';    Size :0);
  TypeArrayWord    : TType = (Name : '_ARRAYWORD';    Size :2);
  TypeArrayByte    : TType = (Name : '_ARRAYBYTE';    Size :1);
  TypeArrayString  : TType = (Name : '_ARRAYSTRING';    Size :1);
  TypeArray        : TType = (Name : '_ARRAY';    Size :1);
Var
  SymbolTable  : Array[0..512] of Symbol;
  SymbolCount  : Integer;

  TypeTable    : Array[0..512] of TType;
  TypeCount    : Integer;

  StringConst  : Array[0..1024]  of TStringConst;
  StringCount  : Integer;
  prom_str_mas : Array[0..1024]  of Word;

function ToUpper(S : String):String;
begin
ToUpper:=UpperCase(s);
end;

function GetName:String;
begin
     //showmessage(Current_String);
  If Current_Token = _Name then
    GetName := '_' + ToUpper(Current_String)
  else
    Expected('Name');
  GetToken;
end;

function GetNumber:Word;
begin
  GetNumber := Current_Number;
  GetToken;
end;

Procedure AddSymbol(_Name : String; _Kind : Integer; _IsVar : Boolean;
              _CountIndex: Byte; _Index1Size,_Index2Size,_Addr_mas_init: Word);
Begin
  SymbolTable[SymbolCount].Name  := _Name;
  SymbolTable[SymbolCount].Kind  := _Kind;
  SymbolTable[SymbolCount].IsVar := _IsVar;
  SymbolTable[SymbolCount].CountIndex := _CountIndex;
  SymbolTable[SymbolCount].Index1Size := _Index1Size;
  SymbolTable[SymbolCount].Index2Size := _Index2Size;
  SymbolTable[SymbolCount].Addr_mas_init := _Addr_mas_init;
  Inc(SymbolCount);
End; { AddSymbol }

Function LookSymbol(_Name : String):Integer;
{ True if _NAME is in table }
Var
  q,r : Integer;
Begin
  r := -1;
  For q := 0 to SymbolCount-1 do
    If SymbolTable[q].Name = _Name then
      r := q;
  If r <> -1 then
    LookSymbol := SymbolTable[r].Kind
  else
    LookSymbol := -1;
End;

Function CheckSymbol(_Name : String): Integer;
Var
  tmp : integer;
Begin
  tmp := LookSymbol(_Name);
  if tmp = -1 then
    Expected('identifier');
  CheckSymbol := tmp;
End;

Procedure DumpSymbols;
var
  i,j,k : word;
Begin
  WriteLn(Dest,#13);
  WriteLn(Dest,'; Variable Area');
  for i := 0 to SymbolCount - 1 do
    If SymbolTable[i].IsVar then
      case SymbolTable[i].Kind of

        _Byte:
          if SymbolTable[i].Addr_mas_init=0
            then WriteLn(Dest,SymbolTable[i].Name,TAB,'defb',TAB,'0')
            else WriteLn(Dest,SymbolTable[i].Name,TAB,'defb',TAB,Mas_Init[SymbolTable[i].Addr_mas_init]);

        _Word{,_Long,_Void}:
          if SymbolTable[i].Addr_mas_init=0
            then WriteLn(Dest,SymbolTable[i].Name,TAB,'defw',TAB,'0')
            else WriteLn(Dest,SymbolTable[i].Name,TAB,'defw',TAB,Mas_Init[SymbolTable[i].Addr_mas_init]);

        _String:
          if SymbolTable[i].Addr_mas_init=0
            then
              begin
				WriteLn(Dest,SymbolTable[i].Name,TAB,'defb',TAB,inttostr(SymbolTable[i].Index1Size));
				WriteLn(Dest,TAB,'defs',TAB,SymbolTable[i].Index1Size,',','32');

                {WriteLn(Dest,SymbolTable[i].Name,TAB,'defb',TAB,'0');
                WriteLn(Dest,TAB,'dup',TAB,SymbolTable[i].Index1Size);
                WriteLn(Dest,TAB,'defb',TAB,'32');
                WriteLn(Dest,TAB,'edup');}
              end
            else
              begin
                WriteLn(Dest,SymbolTable[i].Name,TAB,'defb',TAB,Mas_Init[SymbolTable[i].Addr_mas_init]);
                Write(Dest,TAB,'defb',TAB);
                for j:=1 to SymbolTable[i].Index1Size-1 do
                  Write(Dest,Mas_Init[SymbolTable[i].Addr_mas_init+j],',');
                Writeln(Dest,Mas_Init[SymbolTable[i].Addr_mas_init+SymbolTable[i].Index1Size]);
              end;

        _ArrayByte:
          if SymbolTable[i].Addr_mas_init=0
            then
              begin
                WriteLn(Dest,SymbolTable[i].Name,TAB,'defs',TAB,SymbolTable[i].Index1Size * SymbolTable[i].Index2Size,',','0');
                {*WriteLn(Dest,SymbolTable[i].Name,TAB,'dup',TAB,SymbolTable[i].Index1Size,'*',SymbolTable[i].Index2Size);
                WriteLn(Dest,TAB,'defb',TAB,'0');
                WriteLn(Dest,TAB,'edup');*}
              end
            else
              begin
                WriteLn(Dest,SymbolTable[i].Name);
                for j:=1 to SymbolTable[i].Index1Size do
                  begin
                    Write(Dest,TAB,'defb',TAB);
                    for k:=1 to SymbolTable[i].Index2Size-1 do
                      Write(Dest,Mas_Init[SymbolTable[i].Addr_mas_init+(j-1)*SymbolTable[i].Index2Size+k-1],',');
                    Writeln(Dest,Mas_Init[SymbolTable[i].Addr_mas_init+j*SymbolTable[i].Index2Size-1]);
                  end;
              end;

        _ArrayWord:
          if SymbolTable[i].Addr_mas_init=0
            then
              begin
				WriteLn(Dest,SymbolTable[i].Name,TAB,'defs',TAB,(SymbolTable[i].Index1Size * SymbolTable[i].Index2Size) * 2,',','0');
                {WriteLn(Dest,SymbolTable[i].Name,TAB,'dup',TAB,SymbolTable[i].Index1Size,'*',SymbolTable[i].Index2Size);
                WriteLn(Dest,TAB,'defw',TAB,'0');
                WriteLn(Dest,TAB,'edup');}
              end
            else
              begin
                WriteLn(Dest,SymbolTable[i].Name);
                for j:=1 to SymbolTable[i].Index1Size do
                  begin
                    Write(Dest,TAB,'defw',TAB);
                    for k:=1 to SymbolTable[i].Index2Size-1 do
                      Write(Dest,Mas_Init[SymbolTable[i].Addr_mas_init+(j-1)*SymbolTable[i].Index2Size+k-1],',');
                    Writeln(Dest,Mas_Init[SymbolTable[i].Addr_mas_init+j*SymbolTable[i].Index2Size-1]);
                  end;
              end;

        _ArrayString:
          if SymbolTable[i].Addr_mas_init=0
            then
              begin
				WriteLn(Dest,SymbolTable[i].Name,TAB,'defs',TAB,SymbolTable[i].Index1Size * SymbolTable[i].Index2Size,',','0');
                {WriteLn(Dest,SymbolTable[i].Name,TAB,'dup',TAB,SymbolTable[i].Index1Size,'*',SymbolTable[i].Index2Size);
                WriteLn(Dest,TAB,'defb',TAB,'0');
                WriteLn(Dest,TAB,'edup');}
              end
            else
              begin
                WriteLn(Dest,SymbolTable[i].Name);
                for j:=1 to SymbolTable[i].Index1Size do
                  begin
                    Write(Dest,TAB,'defb',TAB);
                    for k:=1 to SymbolTable[i].Index2Size-1 do
                      Write(Dest,Mas_Init[SymbolTable[i].Addr_mas_init+(j-1)*(SymbolTable[i].Index2Size+1)+k-1],',');
                    Writeln(Dest,Mas_Init[SymbolTable[i].Addr_mas_init+(j-1)*(SymbolTable[i].Index2Size+1)+SymbolTable[i].Index2Size-1]);
                  end;
              end;

      end;
End;

Function LookIdName(_Name : String):Integer;
{ True if _NAME is in table }
Var
  q,r : Integer;
Begin
  r := -1;
  For q := 0 to SymbolCount-1 do
    If SymbolTable[q].Name = _Name then
      r := q;
  LookIdName:=r;
End;

Function LookType(    _Name : String):Integer;
{ True if _NAME is in table }
Var
  q,r : Integer;
Begin
  r := -1;
  For q := 0 to TypeCount-1 do
    If TypeTable[q].Name = _Name then
      r := q;
  LookType := r;
End;

Procedure CheckType(_Name : String);
Begin
  If (LookType(_Name) = -1) then
    Expected('type');
End;

Function DoStringConst(S : String):String;
Begin
  StringConst[StringCount].Name := S;
  StringConst[StringCount].Len := Length(S);
  DoStringConst := '_STR'+Numb(StringCount);
  Inc(StringCount);
End;

Function CharToByte(s_fun: char):byte;
Begin
        case s_fun of
          ' ': CharToByte:=32;
          '!': CharToByte:=33;
          '"': CharToByte:=34;
          '#': CharToByte:=35;
          '$': CharToByte:=36;
          '%': CharToByte:=37;
          '&': CharToByte:=38;
          '''': CharToByte:=39;
          '(': CharToByte:=40;
          ')': CharToByte:=41;
          '*': CharToByte:=42;
          '+': CharToByte:=43;
          ',': CharToByte:=44;
          '-': CharToByte:=45;
          '.': CharToByte:=46;
          '/': CharToByte:=47;
          '0': CharToByte:=48;
          '1': CharToByte:=49;
          '2': CharToByte:=50;
          '3': CharToByte:=51;
          '4': CharToByte:=52;
          '5': CharToByte:=53;
          '6': CharToByte:=54;
          '7': CharToByte:=55;
          '8': CharToByte:=56;
          '9': CharToByte:=57;
          ':': CharToByte:=58;
          ';': CharToByte:=59;
          '<': CharToByte:=60;
          '=': CharToByte:=61;
          '>': CharToByte:=62;
          '?': CharToByte:=63;
          '@': CharToByte:=64;
          'A': CharToByte:=65;
          'B': CharToByte:=66;
          'C': CharToByte:=67;
          'D': CharToByte:=68;
          'E': CharToByte:=69;
          'F': CharToByte:=70;
          'G': CharToByte:=71;
          'H': CharToByte:=72;
          'I': CharToByte:=73;
          'J': CharToByte:=74;
          'K': CharToByte:=75;
          'L': CharToByte:=76;
          'M': CharToByte:=77;
          'N': CharToByte:=78;
          'O': CharToByte:=79;
          'P': CharToByte:=80;
          'Q': CharToByte:=81;
          'R': CharToByte:=82;
          'S': CharToByte:=83;
          'T': CharToByte:=84;
          'U': CharToByte:=85;
          'V': CharToByte:=86;
          'W': CharToByte:=87;
          'X': CharToByte:=88;
          'Y': CharToByte:=89;
          'Z': CharToByte:=90;
          '[': CharToByte:=91;
          '\': CharToByte:=92;
          ']': CharToByte:=93;
          '^': CharToByte:=94;
          '_': CharToByte:=95;
          '`': CharToByte:=96;
          'a': CharToByte:=97;
          'b': CharToByte:=98;
          'c': CharToByte:=99;
          'd': CharToByte:=100;
          'e': CharToByte:=101;
          'f': CharToByte:=102;
          'g': CharToByte:=103;
          'h': CharToByte:=104;
          'i': CharToByte:=105;
          'j': CharToByte:=106;
          'k': CharToByte:=107;
          'l': CharToByte:=108;
          'm': CharToByte:=109;
          'n': CharToByte:=110;
          'o': CharToByte:=111;
          'p': CharToByte:=112;
          'q': CharToByte:=113;
          'r': CharToByte:=114;
          's': CharToByte:=115;
          't': CharToByte:=116;
          'u': CharToByte:=117;
          'v': CharToByte:=118;
          'w': CharToByte:=119;
          'x': CharToByte:=120;
          'y': CharToByte:=121;
          'z': CharToByte:=122;
          '{': CharToByte:=123;
          '|': CharToByte:=124;
          '}': CharToByte:=125;
          '~': CharToByte:=126;
     end;


End;


Procedure DumpStrings;
Var
  i,k : integer;
  j : byte;
  s : string;
  s_byte: byte;
Begin
  WriteLn(Dest,#13);
  WriteLn(Dest,'; String constants');

  for i := 0 to StringCount-1 do

  if prom_str_mas[i]=i then

  begin
    s := StringConst[i].Name;

    if Length(s)>0 then
    begin //----------------------------

    WriteLn(Dest,'_STR'+Numb(i),TAB,
                 'defb',TAB,
                 Numb(Length(S)));
    Write(Dest,TAB,'defb',TAB);
    k:=length(s);
    For j := 1 to k do
      begin
        s_byte:=CharToByte(s[j]);
        if j<k
          then Write(Dest,s_byte,',')
          else Write(Dest,s_byte);
      end;
    Writeln(Dest,#13);

    end; //----------------------------

  end;
End;


(*************************
      Code Generator
 *************************)
Var
  LabelCount : Word;

procedure Emit(s : string);
begin
  Write(Dest,'      ', s);
end;

procedure EmitLn(s : string);
begin
  Emit(s);
  WriteLn(Dest);
end;

function  NewLabel:LabelStr;
var
  tmp : string;
begin
  Str(LabelCount,tmp); Inc(LabelCount);
  tmp := 'L'+tmp;
  NewLabel := tmp;
end;


Procedure GenRealCode(c : string;
                   n : integer;
                   s : string);
Var
 Tmp : String;
 x,y : integer;
Begin

//ShowMessage('C : ' + c + ' ; N : ' + inttostr(n) + ' ; S : ' + s);

if c='_Call' then       EmitLn('call  '+S);
if c='_Return' then    EmitLn('ret');

if c='_LoadConst' then EmitLn('ld    hl,'+Numb(N));

if c='_LoadVarByte' then  begin
                            EmitLn('ld    a,('+s+')');
                            EmitLn('ld    l,a');
                            EmitLn('ld    h,0');
                  end;

if c='_LoadVarWord' then  EmitLn('ld    hl,('+s+')');

if c='_LoadLabel' then EmitLn('ld    hl,'+s);

if c='_LoadArrayByte' then begin
                    EmitLn('ld    l,(hl)');
                    EmitLn('ld    h,0');
                  end;

if c='_LoadArrayWord' then  begin
                    EmitLn('ld    e,(hl)');
                    EmitLn('inc   hl');
                    EmitLn('ld    d,(hl)');
                    EmitLn('ex    de,hl');
                  end;

if c='_Push' then   EmitLn('push  hl');

if c='_PopAdd' then    begin
                    EmitLn('pop   de');
                    EmitLn('add   hl,de');
                  end;
if c='_PopSub' then     begin
                    EmitLn('pop   de');
                    EmitLn('ex    de,hl');
                    EmitLn('and   a');
                    EmitLn('sbc   hl,de');
                  end;
if c='_PopMul' then     begin
                    EmitLn('ld    b,h');
                    EmitLn('ld    c,l');
                    EmitLn('pop   de');
                    EmitLn('call  mul');

                    Mas_Lib[7].flag:=true;
                  end;
if c='_PopDiv' then    begin
                    EmitLn('ld    b,h');
                    EmitLn('ld    c,l');
                    EmitLn('pop   de');
                    EmitLn('call  div');

                    Mas_Lib[8].flag:=true;
                  end;
if c='_PopMod' then    begin
                    EmitLn('ld    b,h');
                    EmitLn('ld    c,l');
                    EmitLn('pop   de');
                    EmitLn('call  div');
                    EmitLn('ex    de,hl');

                    Mas_Lib[8].flag:=true;
                  end;

if c='_StoreString' then      begin
                          EmitLn('ld    de,'+S);
                          EmitLn('call  add_string');

                          Mas_Lib[23].flag:=true;
                        end;

if c='_StoreByte' then   Begin
                    EmitLn('ld    a,l');
                    EmitLn('ld    ('+s+'),a');
                  End;

if c='_StoreWord' then   Begin
                    EmitLn('ld    ('+s+'),hl');
                  End;

if c='_ResetStringLength' then begin
                          EmitLn('ld    hl,'+S);
                          EmitLn('ld    (hl),0');
                         end;

if c='_StoreArrayByte' then  begin
                    EmitLn('pop   de');
                    EmitLn('ld    a,l');
                    EmitLn('ld    (de),a');
                  end;

if c='_StoreArrayWord' then  begin
                    EmitLn('pop   de');
                    EmitLn('ex    de,hl');
                    EmitLn('ld    (hl),e');
                    EmitLn('inc   hl');
                    EmitLn('ld    (hl),d');
                  end;

if c='_PutLabel' then   WriteLn(Dest,S);
if c='_PutWord' then   begin
                    EmitLn('call  convert_16bit_to_string');
                    EmitLn('ld    hl,string_number');

                    Mas_Lib[2].flag:=true;
                    Mas_Lib[9].flag:=true;
                    Mas_Lib[11].flag:=true;
                    Mas_Lib[12].flag:=true;
                    end;

if c='_PutString' then Begin
                    EmitLn('ld    hl,'+S);

                    Mas_Lib[9].flag:=true;
                    Mas_Lib[10].flag:=true;
                    Mas_Lib[11].flag:=true;
                  End;

if c='_JumpTo' then     EmitLn('jp    '+S);
if c='_IfLessTo' then   Begin
                    EmitLn('jp    c,'+S);
                  End;
if c='_IfEqualMoreTo' then Begin
                    EmitLn('jp    nc,'+S);
                  End;

if c='_ProgramExit' then Begin
                    EmitLn('ret    ; Kilepes a programbol');
                  End;

if c='_Logical' then   Begin
                    EmitLn('jp    z,'+S);
                  End;

if c='_Logical_Not' then Begin
                    EmitLn('jp    nz,'+S);
                  End;

if c='_GreaterCode' then    Begin
                    EmitLn('pop   de');
                    EmitLn('and   a');
                    EmitLn('sbc   hl,de');
                  end;

if c='_PutRandomize' then Begin
                    EmitLn('ld    hl,(23672)');
                    EmitLn('ld    (rnd),hl');
                    Mas_Lib[12].flag:=true;
                  End;

if c='_ClearArray' then Begin
                    EmitLn('ld    hl,'+s);
                    EmitLn('ld    de,'+s+'+1');
                    EmitLn('ld    bc,'+Numb(N));
                    EmitLn('ld    (hl),0');
                    EmitLn('ldir');
                  End;

if c='_LoadStoreVarByte' then  begin
                    if N<>0
                      then EmitLn('ld    a,'+numb(N))
                      else EmitLn('xor   a');
                    EmitLn('ld    ('+s+'),a');
                  end;

if c='_LoadConst2Add' then    begin
		  case N of
                  0: ;
                  1: EmitLn('inc   hl');
                  else
                   begin
                    EmitLn('ld    de,'+Numb(N));
                    EmitLn('add   hl,de');
		   end;
                  end;
                              end;

if c='_LoadVarByte2Add' then    begin
                    EmitLn('ld    a,('+s+')');
                    EmitLn('ld    e,a');
                    EmitLn('ld    d,0');
                    EmitLn('add   hl,de');
                  end;

if c='_LoadVarWord2Add' then    begin
                    EmitLn('ld    de,('+s+')');
                    EmitLn('add   hl,de');
                  end;

if c='_LoadConst2Sub' then    begin
		  case N of
                  0: ;
                  1: EmitLn('dec   hl');
                  else
                   begin
                    EmitLn('ld    de,'+Numb(N));
                    EmitLn('and   a');
                    EmitLn('sbc   hl,de');
		   end;
                  end;
                              end;

if c='_LoadVarByte2Sub' then    begin
                    EmitLn('ld    a,('+s+')');
                    EmitLn('ld    e,a');
                    EmitLn('ld    d,0');
                    EmitLn('and   a');
                    EmitLn('sbc   hl,de');
                  end;

if c='_LoadVarWord2Sub' then    begin
                    EmitLn('ld    de,('+s+')');
                    EmitLn('and   a');
                    EmitLn('sbc   hl,de');
                  end;

if c='_LoadConst2Mul' then    begin
                    EmitLn('ld    bc,'+Numb(N));
                    EmitLn('ex    de,hl');
                    EmitLn('call  mul');

                    Mas_Lib[7].flag:=true;
                  end;

if c='_LoadConst2MulNum2' then    begin
                    EmitLn('add   hl,hl');
                  end;

if c='_LoadConst2MulNum3' then    begin
                    EmitLn('ld    d,h');
                    EmitLn('ld    e,l');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,de');
                  end;

if c='_LoadConst2MulNum4' then    begin
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                  end;

if c='_LoadConst2MulNum5' then    begin
                    EmitLn('ld    d,h');
                    EmitLn('ld    e,l');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,de');
                  end;

if c='_LoadConst2MulNum6' then    begin
                    EmitLn('add   hl,hl');
                    EmitLn('ld    d,h');
                    EmitLn('ld    e,l');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,de');
                  end;

if c='_LoadConst2MulNum8' then    begin
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                  end;

if c='_LoadConst2MulNum10' then    begin
                    EmitLn('add   hl,hl');
                    EmitLn('ld    d,h');
                    EmitLn('ld    e,l');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,de');
                  end;

if c='_LoadConst2MulNum12' then    begin
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('ld    d,h');
                    EmitLn('ld    e,l');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,de');
                  end;

if c='_LoadConst2MulNum15' then    begin
                    EmitLn('ld    d,h');
                    EmitLn('ld    e,l');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('and   a');
                    EmitLn('sbc   hl,de');
                  end;

if c='_LoadConst2MulNum16' then    begin
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                  end;

if c='_LoadConst2MulNum20' then    begin
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('ld    d,h');
                    EmitLn('ld    e,l');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,de');
                  end;

if c='_LoadConst2MulNum24' then    begin
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('ld    d,h');
                    EmitLn('ld    e,l');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,de');
                  end;

if c='_LoadConst2MulNum25' then    begin
                    EmitLn('ld    d,h');
                    EmitLn('ld    e,l');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('ld    b,h');
                    EmitLn('ld    c,l');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,bc');
                    EmitLn('add   hl,de');
                  end;

if c='_LoadConst2MulNum32' then    begin
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                  end;

if c='_LoadConst2MulNum50' then    begin
                    EmitLn('add   hl,hl');
                    EmitLn('ld    d,h');
                    EmitLn('ld    e,l');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('ld    b,h');
                    EmitLn('ld    c,l');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,bc');
                    EmitLn('add   hl,de');
                  end;

if c='_LoadConst2MulNum64' then    begin
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                  end;

if c='_LoadConst2MulNum100' then    begin
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('ld    d,h');
                    EmitLn('ld    e,l');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('ld    b,h');
                    EmitLn('ld    c,l');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,bc');
                    EmitLn('add   hl,de');
                  end;

if c='_LoadConst2MulNum128' then    begin
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                    EmitLn('add   hl,hl');
                  end;

if c='_LoadConst2MulNum256' then    begin
                    EmitLn('ld    h,l');
                    EmitLn('ld    l,0');
                  end;

if c='_LoadVarByte2Mul' then    begin
                    EmitLn('ld    a,('+s+')');
                    EmitLn('ld    c,a');
                    EmitLn('ld    b,0');
                    EmitLn('ex    de,hl');
                    EmitLn('call  mul');

                    Mas_Lib[7].flag:=true;
                  end;

if c='_LoadVarWord2Mul' then    begin
                    EmitLn('ld    bc,('+s+')');
                    EmitLn('ex    de,hl');
                    EmitLn('call  mul');

                    Mas_Lib[7].flag:=true;
                  end;

if c='_LoadConst2Div' then    begin
                    EmitLn('ld    bc,'+Numb(N));
                    EmitLn('ex    de,hl');
                    EmitLn('call  div');

                    Mas_Lib[8].flag:=true;
                  end;

if c='_LoadConst2DivNum2' then    begin
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                  end;

if c='_LoadConst2DivNum4' then    begin
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                  end;

if c='_LoadConst2DivNum8' then    begin
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                  end;

if c='_LoadConst2DivNum16' then    begin
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                  end;

if c='_LoadConst2DivNum32' then    begin
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                  end;

if c='_LoadConst2DivNum64' then    begin
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                  end;

if c='_LoadConst2DivNum128' then    begin
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                    EmitLn('srl   h');
                    EmitLn('rr    l');
                  end;

if c='_LoadConst2DivNum256' then    begin
                    EmitLn('ld    l,h');
                    EmitLn('ld    h,0');
                  end;

if c='_LoadVarByte2Div' then    begin
                    EmitLn('ld    a,('+s+')');
                    EmitLn('ld    c,a');
                    EmitLn('ld    b,0');
                    EmitLn('ex    de,hl');
                    EmitLn('call  div');

                    Mas_Lib[8].flag:=true;
                  end;

if c='_LoadVarWord2Div' then    begin
                    EmitLn('ld    bc,('+s+')');
                    EmitLn('ex    de,hl');
                    EmitLn('call  div');

                    Mas_Lib[8].flag:=true;
                  end;

if c='_LoadConst2Mod' then    begin
                    EmitLn('ld    bc,'+Numb(N));
                    EmitLn('ex    de,hl');
                    EmitLn('call  div');
                    EmitLn('ex    de,hl');

                    Mas_Lib[8].flag:=true;
                  end;

if c='_LoadVarByte2Mod' then    begin
                    EmitLn('ld    a,('+s+')');
                    EmitLn('ld    c,a');
                    EmitLn('ld    b,0');
                    EmitLn('ex    de,hl');
                    EmitLn('call  div');
                    EmitLn('ex    de,hl');

                    Mas_Lib[8].flag:=true;
                  end;

if c='_LoadVarWord2Mod' then    begin
                    EmitLn('ld    bc,('+s+')');
                    EmitLn('ex    de,hl');
                    EmitLn('call  div');
                    EmitLn('ex    de,hl');

                    Mas_Lib[8].flag:=true;
                  end;

if c='_LoadConst2Greater' then    begin
                    EmitLn('ld    de,'+Numb(N));
                    EmitLn('ex    de,hl');
                    EmitLn('and   a');
                    EmitLn('sbc   hl,de');
                  end;

if c='_LoadVarByte2Greater' then    begin
                    EmitLn('ld    a,('+s+')');
                    EmitLn('ld    e,a');
                    EmitLn('ld    d,0');
                    EmitLn('ex    de,hl');
                    EmitLn('and   a');
                    EmitLn('sbc   hl,de');
                  end;

if c='_LoadVarWord2Greater' then    begin
                    EmitLn('ld    de,('+s+')');
                    EmitLn('ex    de,hl');
                    EmitLn('and   a');
                    EmitLn('sbc   hl,de');
                  end;

if c='_LoadResetVarByte' then  begin
                    EmitLn('ld    hl,'+s);
                    EmitLn('ld    (hl),0');
                  end;

if c='_LoadLabel2Add' then    begin
                    EmitLn('ld    de,'+s);
                    EmitLn('add   hl,de');
                  end;

if c='_LoadLabel2Sub' then    begin
                    EmitLn('ld    de,'+s);
                    EmitLn('and   a');
                    EmitLn('sbc   hl,de');
                  end;

if c='_LoadConst2StoreArrayByte' then    begin
                    EmitLn('ld    (hl),'+Numb(N));
                  end;

if c='_LoadVarByte2StoreArrayByte' then    begin
                    EmitLn('ld    a,('+s+')');
                    EmitLn('ld    (hl),a');
                  end;

if c='_LoadConst2StoreArrayWord' then    begin
                    EmitLn('ld    de,'+Numb(N));
                    EmitLn('ld    (hl),e');
                    EmitLn('inc   hl');
                    EmitLn('ld    (hl),d');
                  end;

if c='_LoadVarByte2StoreArrayWord' then    begin
                    EmitLn('ld    a,('+s+')');
                    EmitLn('ld    (hl),a');
                    EmitLn('inc   hl');
                    EmitLn('ld    (hl),0');
                  end;

if c='_LoadVarWord2StoreArrayWord' then    begin
                    EmitLn('ld    de,('+s+')');
                    EmitLn('ld    (hl),e');
                    EmitLn('inc   hl');
                    EmitLn('ld    (hl),d');
                  end;

if c='_LoadByteConst' then begin
                    if N<>0
                      then EmitLn('ld    a,'+numb(N))
                      else EmitLn('xor   a');
                  end;

if c='_LoadAccum' then begin
                    EmitLn('ld    a,('+s+')');
                  end;

if c='_StoreAccum' then begin
                    EmitLn('ld    ('+s+'),a');
                  end;

if c='_CompareByte2Byte' then begin
                    EmitLn('ld    hl,'+s);
                    EmitLn('cp    (hl)');
                  end;

if c='_CompareByte2Const' then begin
                    if N<>0
                      then EmitLn('cp    '+numb(N))
                      else EmitLn('and   a');
                  end;

if c='_CompareArrayByte2Byte' then begin
                    EmitLn('ld    a,('+s+')');
                    EmitLn('cp    (hl)');
                  end;

if c='_CompareArrayByte2Const' then begin
                    if N<>0
                      then EmitLn('ld    a,'+numb(N))
                      else EmitLn('xor   a');
                    EmitLn('cp    (hl)');
                  end;

if c='_IncVarByte' then begin
                    EmitLn('ld    hl,'+s);
                    EmitLn('inc   (hl)');
                  end;

if c='_DecVarByte' then begin
                    EmitLn('ld    hl,'+s);
                    EmitLn('dec   (hl)');
                  end;

//-------------------- EGYÉB SAJÁT -------------------


//-------------------- T V C ------------------------

if c='_Cls' then begin
   				 	  EmitLn('rst	$30');
                      EmitLn('db	5');
                    end;

if c='_Video_On' then begin
                      EmitLn('ld    a,(3)                   ; Aktualis lapozas kiolvasasa');
                      EmitLn('ld    (SAVED_MEM_PAGES),a     ; Aktualis memorialap eltarolasa');
                      if N = 0 then EmitLn('ld    a,$50                   ; A video memoria belapozasa a $8000-$0BFFF teruletre (2.lap): U0, U1, VID, SYS');
					  if N = 1 then EmitLn('ld    a,$70                   ; A video memoria belapozasa : U0, U1, VID, U3');
                      if N = 2 then EmitLn('ld    a,$90                   ; A video memoria belapozasa : U0, U1, U2, U3');
                      EmitLn('ld    (P_SAVE),a              ; ertek beirasa a P_SAVE rendszervaltozoba');
                      EmitLn('out   (MEM_PAGES_PORT),a      ; es kikuldese a portra, hogy azonnal vegrehajtodjon');
                      Mas_Lib[20].flag := true;             //_tvc_mem_pager - változókat is be kell fordítani!
                  end;

if c='_Video_Off' then begin
                      EmitLn('ld    a,(SAVED_MEM_PAGES)	    ; Bekapcsolaskori memoria konfiguraciot kiolvassuk a valtozonkbol, ahova elmentettuk');
                      EmitLn('ld    (3),a			              ; majd beirjuk a P_SAVE rendszervaltozoba');
                      EmitLn('out   (2),a			              ; es kikuldjuk a portra is, hogy azonnal vegrehajtodjon');
                      Mas_Lib[20].flag := true;             //_tvc_mem_pager - változókat is be kell fordítani!
                  end;

if c='_SetInk' then begin
                      EmitLn('ld    a,l');
                      EmitLn('ld    (2893),a');
                  end;

if c='_SetPaper' then begin
                      EmitLn('ld    a,l');
                      EmitLn('ld    (2894),a');
                  end;

if c='_SetBorder' then begin
                      EmitLn('ld  a,l');
                      EmitLn('ld	(2895),a');
                  end;

if c='_LoadVarToDE' then begin
						EmitLn('ld	de,'+Numb(N));
                      end;

if c='_ExchangeDEHL' then begin
 						EmitLn('ex	de,hl');
                      end;

if c='_SetMode' then begin
						EmitLn('ld	a,l');
                        EmitLn('ld	(2891),a');
						end;

if c='_LineStyle' then begin
						EmitLn('ld	a,l');
                        EmitLn('ld	(2892),a');
						end;

if c='_Pause' then begin	//várakozás egy billentyű lenyomására
   				 	  EmitLn('rst	$30');
                      EmitLn('db	$91');
                    end;

if c='_SetKeyRepeatRate' then begin
						EmitLn('ld	a,l');
                        EmitLn('ld	(2917),a');
						end;

if c='_Poke' then begin
						EmitLn('ld	a,(POKE_DATA)');
                        EmitLn('ld	hl,(POKE_ADDRESS)');
						EmitLn('ld	(hl),a');
                        end;

if c='_Peek' then begin
						EmitLn('ld	hl,(PEEK_ADDRESS)');
                        EmitLn('ld	a,(hl)');
                        EmitLn('ld	h,0');
                        EmitLn('ld	l,a');
                        end;

if c='_GetKeyMatrixState' then begin		//Billentyuzet matrix n-edik soranak allapotat adja vissza l-be
						EmitLn('ld	de,2897');
						EmitLn('add	hl,de');
						EmitLn('ld	l,(hl)');
						EmitLn('ld	h,0');
                        end;


if c='_PutSpriteName' then Begin
					EmitLn('ld    hl,'+s);
					EmitLn('ld    (SPRITE_DATA_ADDRESS),hl');
                    //EmitLn('ld    hl,'+s);
                    //EmitLn('push  hl');
                  End;


End;


Procedure GenCode(c : string;
                   n : integer;
                   s,p1,p2,p3 : string);
begin
mas_code[CodeCounter].com:=c;
mas_code[CodeCounter].num:=n;
mas_code[CodeCounter].str:=s;
mas_code[CodeCounter].par1:=p1;
mas_code[CodeCounter].par2:=p2;
mas_code[CodeCounter].par3:=p3;
inc(CodeCounter);
end;


Procedure OutputCommands;
begin

{
writeln(fCommand,'');
writeln(fCommand,'');
writeln(fCommand,'------------------------------------------------------------');
writeln(fCommand,'');
writeln(fCommand,'');
for CodeCounter:=1 to MaxCodeCounter do
  writeln(fCommand,mas_code[CodeCounter].com,' ',
                 mas_code[CodeCounter].num,' ',
                 mas_code[CodeCounter].str,' ',
                 mas_code[CodeCounter].par1,' ',
                 mas_code[CodeCounter].par2,' ',
                 mas_code[CodeCounter].par3);
}
end;


Procedure DeleteCommand(number: word);
begin
mas_code[number].com:='None';
mas_code[number].num:=0;
mas_code[number].str:='';
mas_code[number].par1:='';
mas_code[number].par2:='';
mas_code[number].par3:='';
end;

Procedure DeleteNone;
var
  i,j,c: word;
begin
c:=MaxCodeCounter;
i:=1;
while i<=c do
  begin
    if mas_code[i].com='None' then
      begin
        for j:=i to c-1 do
          mas_code[j]:=mas_code[j+1];
        dec(MaxCodeCounter);
        dec(i);
        end;
    inc(i);
  end;
end;



Procedure Optimization;
type
   TypeMasCalcIndex=record
      NameBegin,NameEnd,AddrIndexCode: string;
   end;
label
	LabelOpt01;
label
  LabelOpt02;
var
  i,j,k,l,m,n,value_opt: word;
  flag_proc,flag01_proc: boolean;
  CurrentTypeIndex,VarCounter: word;
  MasCalcIndex: array[1..5] of TypeMasCalcIndex;
  mas_var: array[1..200] of string;
  prom_str_proc: string;
  prom_proc: longint;
begin

for i:=2 to MaxCodeCounter do
  if ((mas_code[i].com='=== Statement begin ===') and (mas_code[i-1].com='=== Statement end ===')) then
    begin
      DeleteCommand(i);
      DeleteCommand(i-1);
    end;
//DeleteNone;


// 1. Óäàëåíèå jp MAIN, åñëè íåò ïðîöåäóð

if ((mas_code[2].com='_PutLabel') and (mas_code[2].str='MAIN'))
  then DeleteCommand(1);
//DeleteNone;

OutputCommands;


// 1a. Óäàëåíèå ïîâòîðíûõ ñòðîê

if StringCount>=1 then
  begin

    for i:=0 to StringCount-1 do
      prom_str_mas[i]:=i;

    for i:=0 to StringCount-2 do
	    for j:=1 to StringCount-1 do
		    if StringConst[j].name=StringConst[i].name
          then prom_str_mas[j]:=i;

    for j:=0 to StringCount-1 do
      for k:=1 to MaxCodeCounter do
        if mas_code[k].str='_STR'+Numb(j)
          then mas_code[k].str:='_STR'+Numb(prom_str_mas[j]);
  end;

MasCalcIndex[1].NameBegin:='+++ CalcArrayIndexByte begin +++';
MasCalcIndex[2].NameBegin:='+++ CalcArrayIndexWord begin +++';
MasCalcIndex[3].NameBegin:='+++ CalcArrayIndexString begin +++';
MasCalcIndex[4].NameBegin:='+++ CalcArrayIndexByte111 begin +++';
MasCalcIndex[5].NameBegin:='+++ CalcArrayIndexWord111 begin +++';
MasCalcIndex[1].NameEnd:='+++ CalcArrayIndexByte end +++';
MasCalcIndex[2].NameEnd:='+++ CalcArrayIndexWord end +++';
MasCalcIndex[3].NameEnd:='+++ CalcArrayIndexString end +++';
MasCalcIndex[4].NameEnd:='+++ CalcArrayIndexByte111 end +++';
MasCalcIndex[5].NameEnd:='+++ CalcArrayIndexWord111 end +++';
MasCalcIndex[1].AddrIndexCode:='addr_arraybyte_index';
MasCalcIndex[2].AddrIndexCode:='addr_arrayword_index';
MasCalcIndex[3].AddrIndexCode:='addr_arraystring_index';
MasCalcIndex[4].AddrIndexCode:='addr_arraybyte_index111';
MasCalcIndex[5].AddrIndexCode:='addr_arrayword_index111';

for i:=1 to MaxCodeCounter do
 begin
   if ((mas_code[i].com='+++ CalcArrayIndexByte begin +++')
        or (mas_code[i].com='+++ CalcArrayIndexWord begin +++')
        or (mas_code[i].com='+++ CalcArrayIndexString begin +++')
        or (mas_code[i].com='+++ CalcArrayIndexByte111 begin +++')
        or (mas_code[i].com='+++ CalcArrayIndexWord111 begin +++')) then
     begin

     	if mas_code[i].com='+++ CalcArrayIndexByte begin +++' then CurrentTypeIndex:=1;
     	if mas_code[i].com='+++ CalcArrayIndexWord begin +++' then CurrentTypeIndex:=2;
    	if mas_code[i].com='+++ CalcArrayIndexString begin +++' then CurrentTypeIndex:=3;
      if mas_code[i].com='+++ CalcArrayIndexByte111 begin +++' then CurrentTypeIndex:=4;
     	if mas_code[i].com='+++ CalcArrayIndexWord111 begin +++' then CurrentTypeIndex:=5;

	j:=i;
	repeat
	   inc(j);
	until mas_code[j].com=MasCalcIndex[CurrentTypeIndex].NameEnd;

	k:=i;
	repeat
	   dec(k);
	until ((mas_code[k].com=MasCalcIndex[CurrentTypeIndex].NameBegin) or (k=0));

	if k>0 then
	   begin

		l:=k;
		repeat
	   	   inc(l);
		until mas_code[l].com=MasCalcIndex[CurrentTypeIndex].NameEnd;

		VarCounter:=0;
		for m:=i to j do
		   if ((mas_code[m].com='_LoadVarByte') or (mas_code[m].com='_LoadVarWord')) then
			begin
				inc(VarCounter);
				mas_var[VarCounter]:=mas_code[m].str;
			end;

        m:=i;
        n:=k;
        flag_proc:=false;
        repeat
           if ((mas_code[m].com<>mas_code[n].com)
               or (mas_code[m].num<>mas_code[n].num)
               or (mas_code[m].str<>mas_code[n].str)) then flag_proc:=true;
           inc(m);
           inc(n);
        until ((m>j) or (flag_proc=true));

        if flag_proc=true then goto LabelOpt01;

        flag_proc:=false;
        m:=i-1;

		repeat

			if ((mas_code[m].com='_StoreByte') or (mas_code[m].com='_StoreWord')) then
			   begin
				flag01_proc:=false;
				for n:=1 to VarCounter do
				   if mas_code[m].str=mas_var[n] then flag01_proc:=true;
				if flag01_proc=true then break;
			   end;


      if ((mas_code[m].com='=== For begin ===') or (mas_code[m].com='=== While begin ===')
          or (mas_code[m].com='=== Repeat begin ===') or (mas_code[m].com='=== Procedure begin ===')) then break;

      if ((mas_code[m].com='=== If end ===') or (mas_code[m].com='=== Case end ===')
          or (mas_code[m].com='=== For end ===') or (mas_code[m].com='=== While end ===')
          or (mas_code[m].com='=== Repeat end ===') or (mas_code[m].com='=== Call procedure end ===')
          or (mas_code[m].com='=== Procedure end ===')) then break;

      if ((mas_code[m].com='=== If title end ===') or (mas_code[m].com='=== Case title end ==='))
        then flag_proc:=false;

			if mas_code[m].com='=== Statement begin ===' then flag_proc:=true;

			if ((m=l) and (flag_proc=false)) then
			   begin
				CodeCounter:=i;
				GenCode('_LoadVarWord',0,MasCalcIndex[CurrentTypeIndex].AddrIndexCode,'','','');
				for n:=i+1 to j do
					DeleteCommand(n);
				CodeCounter:=l+1;
				GenCode('_StoreWord',0,MasCalcIndex[CurrentTypeIndex].AddrIndexCode,'','','');

                Mas_Lib[15].flag:=true;
				break;
			   end;

			dec(m);

		until m=0;

           LabelOpt01:

	   end;
     end;
 end;

OutputCommands;



for i:=1 to MaxCodeCounter do
   if ((Pos('===',mas_code[i].com)<>0) or (Pos('+++',mas_code[i].com)<>0))
	then DeleteCommand(i);

DeleteNone;

repeat //+++++++++++++++++++++++++++++++++++++++++++++

OutputCommands;

value_opt:=0;

// 1c. _LoadConst X & N*_StoreByte & _LoadConst X & _StoreByte => _LoadConst X & N*_StoreByte & _StoreAccum

if value_opt=0 then
for i:=4 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_StoreByte') and (mas_code[i-1].com='_LoadConst'))
    then
	begin
		j:=i-2;
		while ((mas_code[j].com='_StoreByte') or (mas_code[j].com='_StoreAccum')) do
			dec(j);
		if j<(i-2) then
			if ((mas_code[j].com='_LoadConst') and (mas_code[j].num=mas_code[i-1].num))
				then
					begin
						CodeCounter:=i-1;
						GenCode('_StoreAccum',0,mas_code[i].str,'','','');
						DeleteCommand(i);
						inc(value_opt);
					end;

	end;

  end;
DeleteNone;

// 1d. _LoadConst X & N*_StoreWord & _LoadConst X & _StoreWord => _LoadConst X & (N+1)*_StoreWord

if value_opt=0 then
for i:=4 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_StoreWord') and (mas_code[i-1].com='_LoadConst'))
    then
	begin
		j:=i-2;
		while mas_code[j].com='_StoreWord' do
			dec(j);
		if j<(i-2) then
			if ((mas_code[j].com='_LoadConst') and (mas_code[j].num=mas_code[i-1].num))
				then
					begin
						DeleteCommand(i-1);
						inc(value_opt);
					end;

	end;

  end;
DeleteNone;

// 2. _LoadConst & _StoreByte => _LoadStoreVarByte

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_StoreByte') and (mas_code[i-1].com='_LoadConst'))
    then
      begin
        CodeCounter:=i-1;
        GenCode('_LoadStoreVarByte',mas_code[i-1].num,mas_code[i].str,'','','');
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 3. _Push & _LoadConst & _PopAdd => _LoadConst2Add

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_PopAdd') and (mas_code[i-1].com='_LoadConst') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadConst2Add',mas_code[i-1].num,'','','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 4. _Push & _LoadVarByte & _PopAdd => _LoadVarByte2Add

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_PopAdd') and (mas_code[i-1].com='_LoadVarByte') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadVarByte2Add',0,mas_code[i-1].str,'','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 5. _Push & _LoadVarWord & _PopAdd => _LoadVarWord2Add

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_PopAdd') and (mas_code[i-1].com='_LoadVarWord') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadVarWord2Add',0,mas_code[i-1].str,'','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 6. _Push & _LoadConst & _PopSub => _LoadConst2Sub

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_PopSub') and (mas_code[i-1].com='_LoadConst') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadConst2Sub',mas_code[i-1].num,'','','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 7. _Push & _LoadVarByte & _PopSub => _LoadVarByte2Sub

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_PopSub') and (mas_code[i-1].com='_LoadVarByte') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadVarByte2Sub',0,mas_code[i-1].str,'','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 8. _Push & _LoadVarWord & _PopSub => _LoadVarWord2Sub

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_PopSub') and (mas_code[i-1].com='_LoadVarWord') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadVarWord2Sub',0,mas_code[i-1].str,'','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 9. _Push & _LoadConst & _PopMul => _LoadConst2Mul

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_PopMul') and (mas_code[i-1].com='_LoadConst') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadConst2Mul',mas_code[i-1].num,'','','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 10. _Push & _LoadVarByte & _PopMul => _LoadVarByte2Mul

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_PopMul') and (mas_code[i-1].com='_LoadVarByte') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadVarByte2Mul',0,mas_code[i-1].str,'','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 11. _Push & _LoadVarWord & _PopMul => _LoadVarWord2Mul

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_PopMul') and (mas_code[i-1].com='_LoadVarWord') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadVarWord2Mul',0,mas_code[i-1].str,'','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 12. _Push & _LoadConst & _PopDiv => _LoadConst2Div

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_PopDiv') and (mas_code[i-1].com='_LoadConst') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadConst2Div',mas_code[i-1].num,'','','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 13. _Push & _LoadVarByte & _PopDiv => _LoadVarByte2Div

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_PopDiv') and (mas_code[i-1].com='_LoadVarByte') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadVarByte2Div',0,mas_code[i-1].str,'','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 14. _Push & _LoadVarWord & _PopDiv => _LoadVarWord2Div

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_PopDiv') and (mas_code[i-1].com='_LoadVarWord') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadVarWord2Div',0,mas_code[i-1].str,'','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 15. _Push & _LoadConst & _PopMod => _LoadConst2Mod

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_PopMod') and (mas_code[i-1].com='_LoadConst') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadConst2Mod',mas_code[i-1].num,'','','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 16. _Push & _LoadVarByte & _PopMod => _LoadVarByte2Mod

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_PopMod') and (mas_code[i-1].com='_LoadVarByte') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadVarByte2Mod',0,mas_code[i-1].str,'','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 17. _Push & _LoadVarWord & _PopMod => _LoadVarWord2Mod

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_PopMod') and (mas_code[i-1].com='_LoadVarWord') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadVarWord2Mod',0,mas_code[i-1].str,'','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 18. _LoadConst & _LoadConst2Add => _LoadConst

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadConst2Add') and (mas_code[i-1].com='_LoadConst'))
    then
      begin
        CodeCounter:=i-1;
        GenCode('_LoadConst',mas_code[i-1].num+mas_code[i].num,'','','','');
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 19. _LoadConst & _LoadConst2Sub => _LoadConst

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadConst2Sub') and (mas_code[i-1].com='_LoadConst'))
    then
      begin
        CodeCounter:=i-1;
        GenCode('_LoadConst',mas_code[i-1].num-mas_code[i].num,'','','','');
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 20. _LoadConst & _LoadConst2Mul => _LoadConst

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadConst2Mul') and (mas_code[i-1].com='_LoadConst'))
    then
      begin
        CodeCounter:=i-1;
        GenCode('_LoadConst',mas_code[i-1].num*mas_code[i].num,'','','','');
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 21. _LoadConst & _LoadConst2Div => _LoadConst

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadConst2Div') and (mas_code[i-1].com='_LoadConst'))
    then
      begin
        CodeCounter:=i-1;
        GenCode('_LoadConst',mas_code[i-1].num div mas_code[i].num,'','','','');
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 22. _LoadConst & _LoadConst2Mod => _LoadConst

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadConst2Mod') and (mas_code[i-1].com='_LoadConst'))
    then
      begin
        CodeCounter:=i-1;
        GenCode('_LoadConst',mas_code[i-1].num mod mas_code[i].num,'','','','');
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 23. _StoreByte & _LoadVarByte => _StoreByte

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadVarByte') and (mas_code[i-1].com='_StoreByte') and (mas_code[i].str=mas_code[i-1].str))
    then
      begin
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 24. _StoreWord & _LoadVarWord => _StoreWord

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadVarWord') and (mas_code[i-1].com='_StoreWord') and (mas_code[i].str=mas_code[i-1].str))
    then
      begin
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 25. _Push & _LoadConst & _GreaterCode => _LoadConst2Greater

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_GreaterCode') and (mas_code[i-1].com='_LoadConst') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadConst2Greater',mas_code[i-1].num,'','','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 26. _Push & _LoadVarByte & _GreaterCode => _LoadVarByte2Greater

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_GreaterCode') and (mas_code[i-1].com='_LoadVarByte') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadVarByte2Greater',0,mas_code[i-1].str,'','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 27. _Push & _LoadVarWord & _GreaterCode => _LoadVarWord2Greater

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_GreaterCode') and (mas_code[i-1].com='_LoadVarWord') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadVarWord2Greater',0,mas_code[i-1].str,'','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 28. _LoadConst2Mul X^2 => _LoadConst2Mul Fast

if value_opt=0 then
for i:=1 to MaxCodeCounter do
  begin

  if mas_code[i].com='_LoadConst2Mul'
    then
     begin
      CodeCounter:=i;
      case mas_code[i].num of
        0: begin GenCode('_LoadConst',0,'','','',''); inc(value_opt); end;
        1: begin DeleteCommand(i); inc(value_opt); end;
        2: begin GenCode('_LoadConst2MulNum2',0,'','','',''); inc(value_opt); end;
        3: begin GenCode('_LoadConst2MulNum3',0,'','','',''); inc(value_opt); end;
        4: begin GenCode('_LoadConst2MulNum4',0,'','','',''); inc(value_opt); end;
        5: begin GenCode('_LoadConst2MulNum5',0,'','','',''); inc(value_opt); end;
        6: begin GenCode('_LoadConst2MulNum6',0,'','','',''); inc(value_opt); end;
        8: begin GenCode('_LoadConst2MulNum8',0,'','','',''); inc(value_opt); end;
        10: begin GenCode('_LoadConst2MulNum10',0,'','','',''); inc(value_opt); end;
        12: begin GenCode('_LoadConst2MulNum12',0,'','','',''); inc(value_opt); end;
        15: begin GenCode('_LoadConst2MulNum15',0,'','','',''); inc(value_opt); end;
        16: begin GenCode('_LoadConst2MulNum16',0,'','','',''); inc(value_opt); end;
        20: begin GenCode('_LoadConst2MulNum20',0,'','','',''); inc(value_opt); end;
        24: begin GenCode('_LoadConst2MulNum24',0,'','','',''); inc(value_opt); end;
        25: begin GenCode('_LoadConst2MulNum25',0,'','','',''); inc(value_opt); end;
        32: begin GenCode('_LoadConst2MulNum32',0,'','','',''); inc(value_opt); end;
        50: begin GenCode('_LoadConst2MulNum50',0,'','','',''); inc(value_opt); end;
        64: begin GenCode('_LoadConst2MulNum64',0,'','','',''); inc(value_opt); end;
        100: begin GenCode('_LoadConst2MulNum100',0,'','','',''); inc(value_opt); end;
        128: begin GenCode('_LoadConst2MulNum128',0,'','','',''); inc(value_opt); end;
        256: begin GenCode('_LoadConst2MulNum256',0,'','','',''); inc(value_opt); end;
      end;
     end;

  end;
DeleteNone;

// 29. _LoadConst2Div X^2 => _LoadConst2Div Fast

if value_opt=0 then
for i:=1 to MaxCodeCounter do
  begin

  if mas_code[i].com='_LoadConst2Div'
    then
     begin
      CodeCounter:=i;
      case mas_code[i].num of
        0: begin GenCode('_LoadConst',0,'','','',''); inc(value_opt); end;
        1: begin DeleteCommand(i); inc(value_opt); end;
        2: begin GenCode('_LoadConst2DivNum2',0,'','','',''); inc(value_opt); end;
        4: begin GenCode('_LoadConst2DivNum4',0,'','','',''); inc(value_opt); end;
        8: begin GenCode('_LoadConst2DivNum8',0,'','','',''); inc(value_opt); end;
        16: begin GenCode('_LoadConst2DivNum16',0,'','','',''); inc(value_opt); end;
        32: begin GenCode('_LoadConst2DivNum32',0,'','','',''); inc(value_opt); end;
        64: begin GenCode('_LoadConst2DivNum64',0,'','','',''); inc(value_opt); end;
        128: begin GenCode('_LoadConst2DivNum128',0,'','','',''); inc(value_opt); end;
        256: begin GenCode('_LoadConst2DivNum256',0,'','','',''); inc(value_opt); end;
      end;
     end;

  end;
DeleteNone;

// 30. _ResetStringLength X & _LoadLabel X => _LoadResetVarByte X

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadLabel') and (mas_code[i-1].com='_ResetStringLength') and (mas_code[i].str=mas_code[i-1].str))
    then
      begin
        CodeCounter:=i-1;
        GenCode('_LoadResetVarByte',0,mas_code[i-1].str,'','','');
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 31. _Push & _LoadLabel & _PopAdd => _LoadLabel2Add

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_PopAdd') and (mas_code[i-1].com='_LoadLabel') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadLabel2Add',0,mas_code[i-1].str,'','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 32. _Push & _LoadLabel & _PopSub => _LoadLabel2Sub

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_PopSub') and (mas_code[i-1].com='_LoadLabel') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadLabel2Sub',0,mas_code[i-1].str,'','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 33. _Push & _LoadConst & _StoreArrayByte => _LoadConst2StoreArrayByte

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_StoreArrayByte') and (mas_code[i-1].com='_LoadConst') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadConst2StoreArrayByte',mas_code[i-1].num,'','','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 34. _Push & _LoadVarByte & _StoreArrayByte => _LoadVarByte2StoreArrayByte

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_StoreArrayByte') and (mas_code[i-1].com='_LoadVarByte') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadVarByte2StoreArrayByte',0,mas_code[i-1].str,'','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 35. _Push & _LoadVarWord & _StoreArrayByte => _LoadVarByte2StoreArrayByte

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_StoreArrayByte') and (mas_code[i-1].com='_LoadVarWord') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadVarByte2StoreArrayByte',0,mas_code[i-1].str,'','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 36. _Push & _LoadConst & _StoreArrayWord => _LoadConst2StoreArrayWord

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_StoreArrayWord') and (mas_code[i-1].com='_LoadConst') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadConst2StoreArrayWord',mas_code[i-1].num,'','','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 37. _Push & _LoadVarByte & _StoreArrayWord => _LoadVarByte2StoreArrayWord

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_StoreArrayWord') and (mas_code[i-1].com='_LoadVarByte') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadVarByte2StoreArrayWord',0,mas_code[i-1].str,'','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 38. _Push & _LoadVarWord & _StoreArrayWord => _LoadVarWord2StoreArrayWord

if value_opt=0 then
for i:=3 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_StoreArrayWord') and (mas_code[i-1].com='_LoadVarWord') and (mas_code[i-2].com='_Push'))
    then
      begin
        CodeCounter:=i-2;
        GenCode('_LoadVarWord2StoreArrayWord',0,mas_code[i-1].str,'','','');
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 39. _LoadVarByte X & _StoreByte X => _LoadVarByte X

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_StoreByte') and (mas_code[i-1].com='_LoadVarByte') and (mas_code[i].str=mas_code[i-1].str))
    then
      begin
        CodeCounter:=i-1;
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 40. _LoadVarWord & _StoreWord => _LoadVarWord

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_StoreWord') and (mas_code[i-1].com='_LoadVarWord') and (mas_code[i].str=mas_code[i-1].str))
    then
      begin
        CodeCounter:=i-1;
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 41. _LoadConst,_LoadVarByte,_LoadVarWord,_LoadLabel &&

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadConst') or (mas_code[i].com='_LoadVarByte')
	or (mas_code[i].com='_LoadVarWord') or (mas_code[i].com='_LoadLabel'))
		then
	if ((mas_code[i-1].com='_LoadConst') or (mas_code[i-1].com='_LoadVarByte')
		or (mas_code[i-1].com='_LoadVarWord') or (mas_code[i-1].com='_LoadLabel'))
    then
      begin
        CodeCounter:=i-1;
        DeleteCommand(i-1);
	inc(value_opt);
      end;

  end;
DeleteNone;


// 42. _LoadVarByte & _LoadVarByte2Greater => _LoadAccum & _CompareByte2Byte

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadVarByte2Greater') and (mas_code[i-1].com='_LoadVarByte'))
    then
      begin
        CodeCounter:=i-1;
        prom_str_proc:=mas_code[i-1].str;
        GenCode('_LoadAccum',0,mas_code[i].str,'','','');
        GenCode('_CompareByte2Byte',0,prom_str_proc,'','','');
	inc(value_opt);
      end;

  end;
DeleteNone;

// 43. _LoadArrayByte & _LoadVarByte2Greater => _CompareArrayByte2Byte

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadVarByte2Greater') and (mas_code[i-1].com='_LoadArrayByte'))
    then
      begin
        CodeCounter:=i-1;
        GenCode('_CompareArrayByte2Byte',0,mas_code[i].str,'','','');
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 44. _LoadStoreVarByte X & _LoadAccum X => _LoadStoreVarByte X

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadAccum') and (mas_code[i-1].com='_LoadStoreVarByte') and (mas_code[i].str=mas_code[i-1].str))
    then
      begin
        CodeCounter:=i-1;
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;


// 45. _LoadVarByte & _LoadConst2Greater => _LoadByteConst & _CompareByte2Byte

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadConst2Greater') and (mas_code[i-1].com='_LoadVarByte'))
    then
      begin
        CodeCounter:=i-1;
	prom_str_proc:=mas_code[i-1].str;
        GenCode('_LoadByteConst',mas_code[i].num,'','','','');
        GenCode('_CompareByte2Byte',0,prom_str_proc,'','','');
	inc(value_opt);
      end;

  end;
DeleteNone;


// 46. _LoadArrayByte & _LoadConst2Greater => _CompareArrayByte2Const

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadConst2Greater') and (mas_code[i-1].com='_LoadArrayByte'))
    then
      begin
        CodeCounter:=i-1;
        GenCode('_CompareArrayByte2Const',mas_code[i].num,mas_code[i-1].str,'','','');
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;


// 47. _LoadVarByte & _StoreByte => _LoadAccum & _StoreAccum

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_StoreByte') and (mas_code[i-1].com='_LoadVarByte') and (mas_code[i].str<>mas_code[i-1].str))
    then
      begin
        CodeCounter:=i-1;
	GenCode('_LoadAccum',0,mas_code[i-1].str,'','','');
        GenCode('_StoreAccum',0,mas_code[i].str,'','','');
	inc(value_opt);
      end;

  end;
DeleteNone;


// 48. _LoadConst & _LoadVarByte2Greater => _LoadAccum & _CompareByte2Const

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadVarByte2Greater') and (mas_code[i-1].com='_LoadConst'))
    then
      begin
        CodeCounter:=i-1;
        prom_proc:=mas_code[i-1].num;
        GenCode('_LoadAccum',0,mas_code[i].str,'','','');
        GenCode('_CompareByte2Const',prom_proc,'','','','');
	inc(value_opt);
      end;

  end;
DeleteNone;


// 49. _StoreByte,_StoreAccum X & _LoadAccum X => _StoreByte,_StoreAccum X

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadAccum') and (mas_code[i].str=mas_code[i-1].str)) then
    if ((mas_code[i-1].com='_StoreByte') or (mas_code[i-1].com='_StoreAccum'))
    then
      begin
        DeleteCommand(i);
	      inc(value_opt);
      end;

  end;
DeleteNone;


// 50. _LoadVarByte,_LoadAccum X & _StoreAccum X => _LOadVarByte,_LoadAccum X

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_StoreAccum') and (mas_code[i].str=mas_code[i-1].str)) then
    if ((mas_code[i-1].com='_LoadVarByte') or (mas_code[i-1].com='_LoadAccum'))
    then
      begin
        DeleteCommand(i);
	      inc(value_opt);
      end;

  end;
DeleteNone;


// 51. _LoadConst2Add X & _LoadConst2Sub X => None

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadConst2Sub') and (mas_code[i-1].com='_LoadConst2Add') and (mas_code[i].num=mas_code[i-1].num))
    then
      begin
        CodeCounter:=i-1;
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 52. _LoadConst2Sub X & _LoadConst2Add X => None

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadConst2Add') and (mas_code[i-1].com='_LoadConst2Sub') and (mas_code[i].num=mas_code[i-1].num))
    then
      begin
        CodeCounter:=i-1;
        DeleteCommand(i-1);
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 53. _LoadConst & _LoadVarByte2Add X => _LoadVarByte X

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadVarByte2Add') and (mas_code[i-1].com='_LoadConst'))
    then
      begin
        CodeCounter:=i-1;
        GenCode('_LoadVarByte',0,mas_code[i].str,'','','');
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 54. _LoadConst & _LoadVarWord2Add X => _LoadVarWord X

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadVarWord2Add') and (mas_code[i-1].com='_LoadConst'))
    then
      begin
        CodeCounter:=i-1;
        GenCode('_LoadVarWord',0,mas_code[i].str,'','','');
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

// 55. _LoadConst X & _LoadLabel2Add Y => _LoadLabel X+Y

if value_opt=0 then
for i:=2 to MaxCodeCounter do
  begin

  if ((mas_code[i].com='_LoadLabel2Add') and (mas_code[i-1].com='_LoadConst'))
    then
      begin
        CodeCounter:=i-1;
	prom_proc:=mas_code[i-1].num;
        GenCode('_LoadLabel',0,mas_code[i].str+'+'+IntToStr(prom_proc),'','','');
        DeleteCommand(i);
	inc(value_opt);
      end;

  end;
DeleteNone;

until value_opt=0;  //+++++++++++++++++++++++++++++++++++++++++++++

OutputCommands;

//âûâîä îïòèìèçèðîâàííîãî êîäà

for CodeCounter:=1 to MaxCodeCounter do
  GenRealCode(mas_code[CodeCounter].com,mas_code[CodeCounter].num,mas_code[CodeCounter].str);

end;


(**********************
    Parsing Routines
 **********************)

function IsCompareOp(x : token): boolean;
begin
  IsCompareOp := x in [_equal.._not_eq];
end;

function IsAddOp(x : token): boolean;
begin
  IsAddOp := x in [_plus,_minus];
end;

function IsMulOp(x : token): boolean;
begin
  IsMulOp := x in [_mul,_div,_mod];
end;

procedure Match(x : Token);
begin
  If Current_Token <> X then
  begin
    If Ord(X) <= MaxToken then
      Expected(TokenName[ord(x)])
    else
      Abort('Unknown Token expected, compiler error!');
  end
  else
    GetToken;
end;

(*************************
    Expression Parser
 *************************)

function  Expression:integer; Forward;


function  Value:integer;
var
  kind : integer;
  proc_i: word;
  temp_name: string;
begin
  kind := -1;
  If Current_Token = _lparen then
  begin
    Match(_lparen);
    kind := Expression;
    Match(_rparen);
  end
  else
  begin
    case Current_Token of

    _name:

     begin
     	try
	   temp_name:='_'+Current_String;
      	   kind:=SymbolTable[LookIdName(temp_name)].Kind;
	Except
	      Abort('Error in expression');
	end;


      case kind of

        _ArrayByte:
          begin
            GenCode('+++ CalcArrayIndexByte begin +++',0,'','','','');
            GenCode('+++ CalcArrayIndexByte111 begin +++',0,'','','','');
            proc_i:=LookIdName(temp_name);
            Match(_name);
            Match(_lsqbkt);
            if SymbolTable[proc_i].CountIndex=2 then
              begin
                Expression;

                GenCode('_Push',0,'','','','');
                GenCode('_LoadConst',1,'','','','');
                GenCode('_PopSub',0,'','','','');
                GenCode('_Push',0,'','','','');
                GenCode('_LoadConst',SymbolTable[proc_i].Index2Size,'','','','');
                GenCode('_PopMul',0,'','','','');

                Match(_comma);
              end
            else GenCode('_LoadConst',0,'','','','');

            GenCode('_Push',0,'','','','');
            GenCode('_LoadLabel',0,temp_name,'','','');
            GenCode('_PopAdd',0,'','','','');

            GenCode('+++ CalcArrayIndexByte111 end +++',0,'','','','');
            GenCode('None',0,'','','','');

            GenCode('_Push',0,'','','','');
            Expression;

            GenCode('_Push',0,'','','','');
            GenCode('_LoadConst',1,'','','','');
            GenCode('_PopSub',0,'','','','');
            GenCode('_PopAdd',0,'','','','');

            GenCode('+++ CalcArrayIndexByte end +++',0,'','','','');
            GenCode('None',0,'','','','');

            Match(_rsqbkt);
            GenCode('_LoadArrayByte',0,'','','','');
          end;

        _ArrayWord:
          begin
            GenCode('+++ CalcArrayIndexWord begin +++',0,'','','','');
            GenCode('+++ CalcArrayIndexWord111 begin +++',0,'','','','');
            proc_i:=LookIdName(temp_name);
            Match(_name);
            Match(_lsqbkt);
            if SymbolTable[proc_i].CountIndex=2 then
              begin
                Expression;

                GenCode('_Push',0,'','','','');
                GenCode('_LoadConst',1,'','','','');
                GenCode('_PopSub',0,'','','','');
                GenCode('_Push',0,'','','','');
                GenCode('_LoadConst',SymbolTable[proc_i].Index2Size*2,'','','','');
                GenCode('_PopMul',0,'','','','');

                Match(_comma);
              end
            else GenCode('_LoadConst',0,'','','','');

            GenCode('_Push',0,'','','','');
            GenCode('_LoadLabel',0,temp_name,'','','');
            GenCode('_PopAdd',0,'','','','');

            GenCode('+++ CalcArrayIndexWord111 end +++',0,'','','','');
            GenCode('None',0,'','','','');

            GenCode('_Push',0,'','','','');
            Expression;

            GenCode('_Push',0,'','','','');
            GenCode('_LoadConst',1,'','','','');
            GenCode('_PopSub',0,'','','','');
            GenCode('_Push',0,'','','','');
            GenCode('_LoadConst',2,'','','','');
            GenCode('_PopMul',0,'','','','');
            GenCode('_PopAdd',0,'','','','');

            GenCode('+++ CalcArrayIndexWord end +++',0,'','','','');
            GenCode('None',0,'','','','');

            Match(_rsqbkt);
            GenCode('_LoadArrayWord',0,'','','','');
          end;

         _Byte: GenCode('_LoadVarByte',0,GetName,'','','');

         _Word: GenCode('_LoadVarWord',0,GetName,'','','');

      _ConstType:
	   begin
		proc_i:=LookIdName(temp_name);
		Match(_name);
		GenCode('_LoadConst',SymbolTable[proc_i].Index1Size,'','','','');
	   end;

      end

     end;

    _numeric_constant:
          GenCode('_LoadConst',GetNumber,'','','','');

    _random_byte:
        begin
          Match(_random_byte);
          Match(_lparen);
          //Expression;
          GenCode('_Call',0,'random_byte','','','');
          Match(_rparen);
          Mas_Lib[14].flag:=true;
        end;

    _random_word:
        begin
          Match(_random_word);
          Match(_lparen);
          //Expression;
          GenCode('_Call',0,'random_word','','','');
          Match(_rparen);
          Mas_Lib[28].flag:=true;
        end;

//------------------------- T V C ----------------------------

	_get:				//Várakozás amíg le nem nyomunk egy gombot majd visszaadja a lenyomott billentyű kódját.
        begin
          Match(_get);
          //Match(_lparen);
          GenCode('_Call',0,'get','','','');
          //Match(_rparen);
          Mas_Lib[37].flag:=true;
        end;

    _inkey:				//Billentyűzet állapot leolvasása ha nyomtak le vmit akkor visszaadja a kódját.
        begin
          Match(_inkey);
          //Match(_lparen);
          GenCode('_Call',0,'inkey','','','');
          //Match(_rparen);
          Mas_Lib[38].flag:=true;
        end;

    _peek:				//Memóriacím tartalmának lekérdezése
      	begin
         Match(_peek);
         Match(_lparen);
         Expression;
         GenCode('_StoreWord',0,'PEEK_ADDRESS','','','');
         GenCode('_Peek',0,'','','','');
         Match(_rparen);
         Mas_Lib[42].flag:=true;
		end;

    _AndByte:				//AND logikai vizsgalat LOGICAL_A es LOGICAL_B kozott, eredmeny = hl.
        begin
          Match(_AndByte);
          Match(_lparen);
		  Expression;
          GenCode('_StoreByte',0,'LOGICAL_A','','','');
          Match(_comma);
          Expression;
          GenCode('_StoreByte',0,'LOGICAL_B','','','');
          GenCode('_Call',0,'andbyte','','','');
          Match(_rparen);
          Mas_Lib[43].flag:=true;	//változók kellenek (LOGICAL_A es LOGICAL_B)
          Mas_Lib[44].flag:=true;	//AND vizsgálat ASM függvény
        end;

    _OrByte:				//OR logikai vizsgalat LOGICAL_A es LOGICAL_B kozott, eredmeny = hl.
        begin
          Match(_OrByte);
          Match(_lparen);
		  Expression;
          GenCode('_StoreByte',0,'LOGICAL_A','','','');
          Match(_comma);
          Expression;
          GenCode('_StoreByte',0,'LOGICAL_B','','','');
          GenCode('_Call',0,'orbyte','','','');
          Match(_rparen);
          Mas_Lib[43].flag:=true;	//változók kellenek (LOGICAL_A es LOGICAL_B)
          Mas_Lib[45].flag:=true;	//OR vizsgálat ASM függvény
        end;

    _XorByte:				//XOR logikai vizsgalat LOGICAL_A es LOGICAL_B kozott, eredmeny = hl.
        begin
          Match(_XorByte);
          Match(_lparen);
		  Expression;
          GenCode('_StoreByte',0,'LOGICAL_A','','','');
          Match(_comma);
          Expression;
          GenCode('_StoreByte',0,'LOGICAL_B','','','');
          GenCode('_Call',0,'xorbyte','','','');
          Match(_rparen);
          Mas_Lib[43].flag:=true;	//változók kellenek (LOGICAL_A es LOGICAL_B)
          Mas_Lib[46].flag:=true;	//OR vizsgálat ASM függvény
        end;

    _GetKeyMatrixState:		//Bill. mátrix adott sorát adja vissza
      	begin
         	Match(_GetKeyMatrixState);
            Match(_lparen);
            if (Current_Number < 0) or (Current_Number > 9) then Abort('GetKeyMatrixState : Unknown variable  (0-9 - OK)');
     		Expression;
     		GenCode('_GetKeyMatrixState',0,'GetKeyMatrixState','','','');
     		Match(_rparen);
		end;

    _SoundPlaying:		//hanglejátszás állapota (ha = 1 akkor szól még az utolsó hang)
      	begin
         	Match(_SoundPlaying);
            //Match(_lparen);
            GenCode('_Call',0,'sound_playing','','','');
            //Match(_rparen);
			Mas_Lib[48].flag:=true;	//sound eljárások
		end


    else
        Error('Error in expression');

    end;

  end;

end;


procedure Factor;
var
  tmp : token;
  kind : integer;
  temp_label: LabelStr;
begin
  kind := Value;
  while IsCompareOp(Current_Token) do
  begin
    GenCode('_Push',kind,'','','','');
    tmp := Current_Token;
    Match(tmp);
    Value;

    case tmp of
      _equal       : begin
                       GenCode('_GreaterCode',kind,'','','','');
                       GenCode('_Logical_Not',0,GlobalLabel,'','','');
                     end;
      _not_eq      : begin
                       GenCode('_GreaterCode',kind,'','','','');
                       GenCode('_Logical',0,GlobalLabel,'','','');
                     end;
      _greater     : begin
                       GenCode('_GreaterCode',kind,'','','','');
                       GenCode('_IfEqualMoreTo',0,GlobalLabel,'','','');
                     end;
      _less        : begin
                       GenCode('_GreaterCode',kind,'','','','');
                       GenCode('_Logical',0,GlobalLabel,'','','');
                       GenCode('_IfLessTo',0,GlobalLabel,'','','');
                     end;
      _greater_eq  : begin
                       temp_label:=NewLabel;
                       GenCode('_GreaterCode',kind,'','','','');
                       GenCode('_Logical',0,temp_label,'','','');
                       GenCode('_IfEqualMoreTo',0,GlobalLabel,'','','');
                       GenCode('_PutLabel',0,temp_label,'','','');
                     end;
      _less_eq     : begin
                       GenCode('_GreaterCode',kind,'','','','');
                       GenCode('_IfLessTo',0,GlobalLabel,'','','');
                     end;
    end;
  end;
end;

procedure Multiply;
begin
  Match(_mul);
  Factor;
  GenCode('_PopMul',0,'','','','');
end;

procedure Divide;
begin
  Match(_div);
  Factor;
  GenCode('_PopDiv',0,'','','','');
end;

procedure Modulo;
begin
  Match(_mod);
  Factor;
  GenCode('_PopMod',0,'','','','');
end;

procedure Term;
begin
  Factor;
  while IsMulOp(Current_Token) do
  begin
    GenCode('_Push',0,'','','','');
    case Current_Token of
      _mul : Multiply;
      _div : Divide;
      _mod : Modulo;
    end;
  end;
end;

procedure Add;
begin
  Match(_plus);
  Term;
  GenCode('_PopAdd',0,'','','','');
end;

procedure Subtract;
begin
  Match(_minus);
  Term;
  GenCode('_PopSub',0,'','','','');
end;

function Expression : integer;     { returns expression type }
var
  kind : integer;
begin
  kind := -1;
  If IsAddOp(Current_Token) then GenCode('_LoadConst',0,'','','','')
                            else Term;
  while IsAddOp(Current_Token) do
  begin
    GenCode('_Push',0,'','','','');
    case Current_Token of
      _plus   : Add;
      _minus  : Subtract;
    end;
  end;
  Expression := kind;
end;

procedure StringTerm;
var
  sx: string;
  proc_ii: word;
  proc_temp_integer: integer;
begin

Case Current_Token of
    _String_Constant:
      begin
        sx := DoStringConst(Current_String);
        Match(_String_Constant);
        if StringConst[StringCount-1].Len>0 then
          begin
            GenCode('_LoadLabel',0,temp_name_string,'','','');
            GenCode('_StoreString',0,sx,'','','');
          end;
      end;

    _Name:
      begin
        sx:=GetName;
        proc_temp_integer:=LookSymbol(sx);

        case proc_temp_integer of

          _String:
            begin
              proc_ii:=LookIdName(sx);
              GenCode('_LoadLabel',0,temp_name_string,'','','');
              GenCode('_StoreString',0,sx,'','','');
            end;

          _ArrayString:
            begin
              GenCode('+++ CalcArrayIndexString begin +++',0,'','','','');
              proc_ii:=LookIdName(sx);
              Match(_lsqbkt);
              Expression;

              GenCode('_Push',0,'','','','');
              GenCode('_LoadConst',1,'','','','');
              GenCode('_PopSub',0,'','','','');
              GenCode('_Push',0,'','','','');
              GenCode('_LoadConst',SymbolTable[proc_ii].Index2Size,'','','','');
              GenCode('_PopMul',0,'','','','');
              GenCode('_Push',0,'','','','');
              GenCode('_LoadLabel',0,sx,'','','');
              GenCode('_PopAdd',0,'','','','');
              //GenCode('_CalcIndexString',SymbolTable[proc_ii].Index2Size,sx,'','','');

              Match(_rsqbkt);
              GenCode('+++ CalcArrayIndexString end +++',0,'','','','');
              GenCode('_StoreWord',0,'addr_arraystring_index','','','');
              
              sx:='(addr_arraystring_index)';

              GenCode('_LoadLabel',0,temp_name_string,'','','');
              GenCode('_StoreString',0,sx,'','','');
              //ShowMessage('OK');
            end;

          else Abort('Uncompatible type');
        end;
      end;

  else Abort('Invalid string expression');
  end;

end;

function StringExpression: integer;
var
  kind : integer;
begin
  kind := -1;

StringTerm;

while Current_Token=_plus do
  begin
    Match(_plus);
    StringTerm;
  end;

StringExpression := kind;

end;


(*************************
     Statement Parser
 *************************)

procedure Statement; Forward;

procedure Assignment;
var
  tmp : string;
  proc_i: word;
  id_type_symbol: integer;
begin
  Tmp := GetName;
  id_type_symbol:=LookSymbol(Tmp);

  case id_type_symbol of
          _Byte:
            begin
              Match(_assign);
              Expression;
              GenCode('_StoreByte',0,Tmp,'','','');
            end;

          _Word:
            begin
              Match(_assign);
              Expression;
              GenCode('_StoreWord',0,Tmp,'','','');
            end;

          _String:
            begin
              Match(_assign);

              temp_name_string:='string_temp';
              GenCode('_ResetStringLength',0,temp_name_string,'','','');
              StringExpression;
              GenCode('_ResetStringLength',0,Tmp,'','','');
              GenCode('_StoreString',0,'string_temp','','','');

              Mas_Lib[16].flag:=true;
            end;

          _Void:
             if LookIdName(Tmp)<>-1
              then
                 begin
                     GenCode('=== Call procedure begin ===',0,'','','','');
                     GenCode('_Call',0,Tmp,'','','');
                     GenCode('=== Call procedure end ===',0,'','','','');
                 end
              else Abort('Unknown name');

          _ArrayByte:
            begin
              if Current_Token=_lsqbkt then
                begin
                  GenCode('+++ CalcArrayIndexByte begin +++',0,'','','','');
                  GenCode('+++ CalcArrayIndexByte111 begin +++',0,'','','','');
                  proc_i:=LookIdName(Tmp);
                  Match(_lsqbkt);
                  if SymbolTable[proc_i].CountIndex=2 then
                    begin
                      Expression;

                      GenCode('_Push',0,'','','','');
                      GenCode('_LoadConst',1,'','','','');
                      GenCode('_PopSub',0,'','','','');
                      GenCode('_Push',0,'','','','');
                      GenCode('_LoadConst',SymbolTable[proc_i].Index2Size,'','','','');
                      GenCode('_PopMul',0,'','','','');

                      Match(_comma);
                    end
                  else GenCode('_LoadConst',0,'','','','');

                  GenCode('_Push',0,'','','','');
                  GenCode('_LoadLabel',0,Tmp,'','','');
                  GenCode('_PopAdd',0,'','','','');

                  GenCode('+++ CalcArrayIndexByte111 end +++',0,'','','','');
                  GenCode('None',0,'','','','');

                  GenCode('_Push',0,'','','','');
                  Expression;

                  GenCode('_Push',0,'','','','');
                  GenCode('_LoadConst',1,'','','','');
                  GenCode('_PopSub',0,'','','','');
                  GenCode('_PopAdd',0,'','','','');

                  GenCode('+++ CalcArrayIndexByte end +++',0,'','','','');
                  GenCode('None',0,'','','','');

                  Match(_rsqbkt);
                  GenCode('_Push',0,'','','','');
                end;

              Match(_assign);
              Expression;
              GenCode('_StoreArrayByte',0,'','','','')
            end;

          _ArrayWord:
            begin
              if Current_Token=_lsqbkt then
                begin
                  GenCode('+++ CalcArrayIndexWord begin +++',0,'','','','');
                  GenCode('+++ CalcArrayIndexWord111 begin +++',0,'','','','');
                  proc_i:=LookIdName(Tmp);
                  Match(_lsqbkt);
                  if SymbolTable[proc_i].CountIndex=2 then
                    begin
                      Expression;

                      GenCode('_Push',0,'','','','');
                      GenCode('_LoadConst',1,'','','','');
                      GenCode('_PopSub',0,'','','','');
                      GenCode('_Push',0,'','','','');
                      GenCode('_LoadConst',SymbolTable[proc_i].Index2Size*2,'','','','');
                      GenCode('_PopMul',0,'','','','');

                      Match(_comma);
                    end
                  else GenCode('_LoadConst',0,'','','','');

                  GenCode('_Push',0,'','','','');
                  GenCode('_LoadLabel',0,Tmp,'','','');
                  GenCode('_PopAdd',0,'','','','');

                  GenCode('+++ CalcArrayIndexWord111 end +++',0,'','','','');
                  GenCode('None',0,'','','','');

                  GenCode('_Push',0,'','','','');
                  Expression;

                  GenCode('_Push',0,'','','','');
                  GenCode('_LoadConst',1,'','','','');
                  GenCode('_PopSub',0,'','','','');
                  GenCode('_Push',0,'','','','');
                  GenCode('_LoadConst',2,'','','','');
                  GenCode('_PopMul',0,'','','','');
                  GenCode('_PopAdd',0,'','','','');

                  GenCode('+++ CalcArrayIndexWord end +++',0,'','','','');
                  GenCode('None',0,'','','','');

                  Match(_rsqbkt);
                  GenCode('_Push',0,'','','','');
                end;

              Match(_assign);
              Expression;
              GenCode('_StoreArrayWord',0,'','','','')
            end;

          _ArrayString:
            begin
              if Current_Token=_lsqbkt then
                begin
                  GenCode('+++ CalcArrayIndexString begin +++',0,'','','','');
                  proc_i:=LookIdName(Tmp);
                  Match(_lsqbkt);
                  Expression;

                  GenCode('_Push',0,'','','','');
                  GenCode('_LoadConst',1,'','','','');
                  GenCode('_PopSub',0,'','','','');
                  GenCode('_Push',0,'','','','');
                  GenCode('_LoadConst',SymbolTable[proc_i].Index2Size,'','','','');
                  GenCode('_PopMul',0,'','','','');
                  GenCode('_Push',0,'','','','');
                  GenCode('_LoadLabel',0,Tmp,'','','');
                  GenCode('_PopAdd',0,'','','','');
                  //GenCode('_CalcIndexString',SymbolTable[proc_i].Index2Size,Tmp,'','','');
                  //GenCode('_StoreWord',0,'addr_array_string_assign','','','');

                  Match(_rsqbkt);

                  GenCode('+++ CalcArrayIndexString end +++',0,'','','','');
                  GenCode('_StoreWord',0,'addr_arraystring_index_2','','','');
                end;

              Match(_assign);

              temp_name_string:='string_temp';
              GenCode('_ResetStringLength',0,temp_name_string,'','','');
              StringExpression;
              GenCode('_ResetStringLength',0,'(addr_arraystring_index_2)','','','');
              GenCode('_StoreString',0,'string_temp','','','');

              Mas_Lib[16].flag:=true;

            end;

          else Abort('Unknown name');
  end;
end;

procedure While_Loop;
var
  TestLabel,
  DoneLabel,
  EndLabel : LabelStr;
begin
  Match(_While);

  TestLabel := NewLabel;
  DoneLabel := NewLabel;
  EndLabel := NewLabel;
  GlobalLabel:=EndLabel;

  GenCode('=== While begin ===',0,'','','','');

  GenCode('_PutLabel',0,TestLabel,'','','');
  Expression;

  while Current_Token in [_and,_or] do
  case Current_Token of
     _and:
        begin
           Match(_and);
           Expression;
        end;
     _or:
        begin
           Match(_or);
           GenCode('_JumpTo',0,DoneLabel,'','','');
           GenCode('_PutLabel',0,EndLabel,'','','');
           EndLabel := NewLabel;
           GlobalLabel:=EndLabel;
           Expression;
        end;
  end;

  Match(_do);
  GenCode('_PutLabel',0,DoneLabel,'','','');
  Statement;
  GenCode('_JumpTo',0,TestLabel,'','','');

  GenCode('_PutLabel',0,EndLabel,'','','');

  GenCode('=== While end ===',0,'','','','');

end;

procedure For_Loop;
var
  DoneLabel,
  TestLabel   : LabelStr;
  Index,Limit : String;
begin
  Match(_For);
  TestLabel  := NewLabel;
  DoneLabel  := NewLabel;
  GlobalLabel:=DoneLabel;

  GenCode('=== For begin ===',0,'','','','');

  Index := GetName;
  Limit := 'Lim'+Index;
  if LookIdName(Limit)=-1 then
    case LookSymbol(Index) of
      _Byte: AddSymbol(Limit,_Byte,True,0,0,0,0);
      _Word: AddSymbol(Limit,_Word,True,0,0,0,0);
    else Abort('Uncompatible type');
    end;
  Match(_assign);

  Expression;
  case LookSymbol(Index) of
     _Byte: GenCode('_StoreByte',0,Index,'','','');
     _Word: GenCode('_StoreWord',0,Index,'','','');
  else Abort('Uncompatible type');
  end;

  case Current_Token of
	_to :
	begin
		Match(_to);
    Expression;
    case LookSymbol(Index) of
     _Byte: GenCode('_StoreByte',0,Limit,'','','');
     _Word: GenCode('_StoreWord',0,Limit,'','','');
    else Abort('Uncompatible type');
    end;
    GenCode('_PutLabel',0,TestLabel,'','','');
    Match(_do);
		Statement;
    case LookSymbol(Index) of
      _Byte: GenCode('_LoadVarByte',0,Index,'','','');
      _Word: GenCode('_LoadVarWord',0,Index,'','','');
    end;
		GenCode('_Push',0,'','','','');
    case LookSymbol(Index) of
      _Byte: GenCode('_LoadVarByte',0,Limit,'','','');
      _Word: GenCode('_LoadVarWord',0,Limit,'','','');
    end;
		GenCode('_GreaterCode',0,'','','','');
		GenCode('_Logical',0,DoneLabel,'','','');
		case LookSymbol(Index) of
		  _Byte:
			begin
				GenCode('_IncVarByte',0,Index,'','','');
			end;
		  _Word:
			begin
				GenCode('_LoadVarWord',0,Index,'','','');
				GenCode('_LoadConst2Add',1,'','','','');
				GenCode('_StoreWord',0,Index,'','','');
			end;
		end;
		GenCode('_JumpTo',0,TestLabel,'','','');
	end;
	_downto :
	begin
		Match(_downto);
    Expression;
    case LookSymbol(Index) of
     _Byte: GenCode('_StoreByte',0,Limit,'','','');
     _Word: GenCode('_StoreWord',0,Limit,'','','');
    else Abort('Uncompatible type');
    end;
    GenCode('_PutLabel',0,TestLabel,'','','');
    Match(_do);
		Statement;
    case LookSymbol(Index) of
      _Byte: GenCode('_LoadVarByte',0,Limit,'','','');
      _Word: GenCode('_LoadVarWord',0,Limit,'','','');
    end;
		GenCode('_Push',0,'','','','');
    case LookSymbol(Index) of
      _Byte: GenCode('_LoadVarByte',0,Index,'','','');
      _Word: GenCode('_LoadVarWord',0,Index,'','','');
    end;
		GenCode('_GreaterCode',0,'','','','');
		GenCode('_Logical',0,DoneLabel,'','','');
		case LookSymbol(Index) of
		  _Byte:
			begin
				GenCode('_DecVarByte',0,Index,'','','');
			end;
		  _Word:
			begin
				GenCode('_LoadVarWord',0,Index,'','','');
				GenCode('_LoadConst2Sub',1,'','','','');
				GenCode('_StoreWord',0,Index,'','','');
			end;
		end;
		GenCode('_JumpTo',0,TestLabel,'','','');
	end
	else Abort('DO or DOWNTO expected');
  end;

  GenCode('_PutLabel',0,DoneLabel,'','','');

  GenCode('=== For end ===',0,'','','','');

end;

procedure If_Then_Else;
var
  ElseLabel,
  DoneLabel  : LabelStr;
begin
  Match(_If);

  ElseLabel := NewLabel;
  DoneLabel := NewLabel;
  GlobalLabel:=ElseLabel;

  GenCode('=== If begin ===',0,'','','','');

  Expression;

  GenCode('=== If title end ===',0,'','','','');

  while Current_Token in [_and,_or] do
  case Current_Token of
     _and:
        begin
           Match(_and);
           Expression;
        end;
     _or:
        begin
           Match(_or);
           GenCode('_JumpTo',0,DoneLabel,'','','');
           GenCode('_PutLabel',0,ElseLabel,'','','');
           ElseLabel := NewLabel;
           GlobalLabel:=ElseLabel;
           Expression;
        end;
  end;

  Match(_then);
  GenCode('_PutLabel',0,DoneLabel,'','','');
  DoneLabel := NewLabel;
  Statement;

  If Current_Token = _Separator then
    GenCode('_PutLabel',0,ElseLabel,'','','')
  else
  begin
    Match(_else);
    GenCode('_JumpTo',0,DoneLabel,'','','');
    GenCode('_PutLabel',0,ElseLabel,'','','');
    Statement;
  end;

  GenCode('_PutLabel',0,DoneLabel,'','','');

  GenCode('=== If end ===',0,'','','','');

end;



procedure Case_Op;
var
  ElseLabel,
  DoneLabel,
  CaseVar,CaseLabel,CaseLabelNext  : LabelStr;
begin
  Match(_case);

  CaseVar := '_'+NewLabel;
  DoneLabel := NewLabel;
  ElseLabel := NewLabel;
  GlobalLabel:=ElseLabel;

  GenCode('=== Case begin ===',0,'','','','');

  case LookSymbol('_'+Current_string) of
     _Byte,_ArrayByte: AddSymbol(CaseVar,_Byte,True,0,0,0,0);
     _Word,_ArrayWord: AddSymbol(CaseVar,_Word,True,0,0,0,0);
  else Abort('Uncorrect variable');
  end;

  Value;
  GenCode('=== Case title end ===',0,'','','','');

  case LookSymbol(CaseVar) of
     _Byte: GenCode('_StoreByte',0,CaseVar,'','','');
     _Word: GenCode('_StoreWord',0,CaseVar,'','','');
  end;

  Match(_of);

  repeat
     CaseLabel := NewLabel;
     CaseLabelNext := NewLabel;

     Value;
     GenCode('_Push',0,'','','','');
     case LookSymbol(CaseVar) of
        _Byte: GenCode('_LoadVarByte',0,CaseVar,'','','');
        _Word: GenCode('_LoadVarWord',0,CaseVar,'','','');
     end;
     GenCode('_GreaterCode',0,'','','','');
     GenCode('_Logical',0,CaseLabel,'','','');

     while Current_Token=_comma do
        begin
           Match(_comma);
           Value;
           GenCode('_Push',0,'','','','');
           case LookSymbol(CaseVar) of
              _Byte: GenCode('_LoadVarByte',0,CaseVar,'','','');
              _Word: GenCode('_LoadVarWord',0,CaseVar,'','','');
           end;
           GenCode('_GreaterCode',0,'','','','');
           GenCode('_Logical',0,CaseLabel,'','','');
        end;

     Match(_colon);
     GenCode('_JumpTo',0,CaseLabelNext,'','','');
     GenCode('_PutLabel',0,CaseLabel,'','','');
     Statement;
     GenCode('_JumpTo',0,DoneLabel,'','','');
     GenCode('_PutLabel',0,CaseLabelNext,'','','');
     Match(_separator);

  until ((Current_Token = _end) or (Current_Token = _else));

  If Current_Token = _end
    then
       begin
          Match(_end);
          //Match(_separator);
       end
    else
       begin
          Match(_else);
          Statement;
          Match(_separator);
          Match(_end);
          //Match(_separator);
       end;

  GenCode('_PutLabel',0,DoneLabel,'','','');

  GenCode('=== Case end ===',0,'','','','');

end;



procedure BlockStatement;
var
  tmp : NameStr;
begin
  Match(_Begin);

  while Current_Token <> _End do
  begin
    If Current_Token = _Separator then
      GetToken
    else
      Statement;
  end;
  Match(_End);
end;


procedure ConstBlock;
var
  Name  : NameStr;
  Number : Word;
  kind : integer;
begin
  Match(_Const);
  while (Current_Token = _Name) do
  begin
    Name:=GetName;
    if LookIdName(Name)<>-1 then Abort('Duplicate name');
    Match(_equal);
    Number:=Current_Number;
    Match(_numeric_constant);
    Match(_separator);

    kind := _ConstType;
    AddSymbol(Name,kind,False,0,Number,0,0);
    //GenCode('_PutConst',Number,Name,'','','');

  end;
end;


procedure VarStatement(var kind : integer);
var
  Name : NameStr;
  proc_mas_name: array[1..255] of NameStr;
  proc_i,proc_j,proc_i_max: integer;
  proc_CountIndex: Byte;
  proc_Index1Size,proc_Index2Size: Word;
  proc_curr_addr_mas_init: Word;
begin

Name:=GetName;
if LookIdName(Name)<>-1 then Abort('Duplicate name');
proc_i:=1;

while Current_Token=_Comma do
  begin
    proc_mas_name[proc_i]:=Name;
    Match(_Comma);
    Name:=GetName;
    if LookIdName(Name)<>-1 then Abort('Duplicate name');
    inc(proc_i);
  end;

proc_mas_name[proc_i]:=Name;
proc_i_max:=proc_i;

Match(_Colon);
kind := LookType(GetName);

case kind of

      _String:
        begin
          Match(_lsqbkt);
          proc_CountIndex:=1;
          proc_Index1Size:=Current_Number;
          proc_Index2Size:=1;
          Match(_numeric_Constant);
          Match(_rsqbkt);
        end;

      _Array:
        begin
          Match(_lsqbkt);
          if Current_Number<>1 then Abort('Invalid number');
          Match(_numeric_Constant);
          Match(_period);
          Match(_period);
          proc_CountIndex:=1;
          proc_Index1Size:=Current_Number;
          proc_Index2Size:=1;
          Match(_numeric_Constant);
          If Current_Token <> _rsqbkt
            then
              begin
                Match(_comma);
                if Current_Number<>1 then Abort('Invalid number');
                Match(_numeric_Constant);
                Match(_period);
                Match(_period);
                proc_CountIndex:=2;
                proc_Index2Size:=Current_Number;
                Match(_numeric_Constant);
              end;
          Match(_rsqbkt);
          Match(_of);
          kind := LookType(GetName);

          case kind of
            _Byte:
              kind:=_ArrayByte;
            _Word:
              kind:=_ArrayWord;
            _String:
              begin
                Match(_lsqbkt);
                proc_CountIndex:=2;
                proc_Index2Size:=Current_Number+1;
                Match(_numeric_Constant);
                Match(_rsqbkt);
                kind:=_ArrayString;
              end;
            -1,_ArrayByte,_ArrayWord,_ArrayString: Expected('TYPE');
          end;

        end;

      -1,_ArrayByte,_ArrayWord,_ArrayString: Expected('TYPE');
end;

proc_curr_addr_mas_init:=0;

if Current_Token=_equal then
  begin

    Match(_equal);
    proc_curr_addr_mas_init:=curr_addr_mas_init;

    case kind of

      _Byte,_Word:
        begin
          Mas_Init[curr_addr_mas_init]:=IntToStr(Current_Number);
          Match(_numeric_Constant);
          inc(curr_addr_mas_init);
        end;

      _String:
        begin
          if Length(Current_String)>proc_Index1Size then Abort('Too long string');
          Mas_Init[curr_addr_mas_init]:=IntToStr(Length(Current_String));
          inc(curr_addr_mas_init);
          for proc_i:=1 to Length(Current_String) do
            begin
              Mas_Init[curr_addr_mas_init]:=IntToStr(CharToByte(Current_String[proc_i]));
              inc(curr_addr_mas_init);
            end;
          for proc_i:=Length(Current_String)+1 to proc_Index1Size do
            begin
              Mas_Init[curr_addr_mas_init]:='32';
              inc(curr_addr_mas_init);
            end;
          Match(_string_Constant);
        end;

      _ArrayByte,_ArrayWord:
        begin
          Match(_lsqbkt);
          for proc_i:=1 to (proc_Index1Size*proc_Index2Size-1) do
              begin
                Mas_Init[curr_addr_mas_init]:=IntToStr(Current_Number);
                Match(_numeric_Constant);
                inc(curr_addr_mas_init);
                Match(_comma);
              end;
          Mas_Init[curr_addr_mas_init]:=IntToStr(Current_Number);
          Match(_numeric_Constant);
          inc(curr_addr_mas_init);
          Match(_rsqbkt);
        end;

      _ArrayString:
        begin
          Match(_lsqbkt);
          for proc_i:=1 to proc_Index1Size-1 do
              begin
                if Length(Current_String)>proc_Index2Size then Abort('Too long string');
                Mas_Init[curr_addr_mas_init]:=IntToStr(Length(Current_String));
                inc(curr_addr_mas_init);
                for proc_j:=1 to Length(Current_String) do
                  begin
                    Mas_Init[curr_addr_mas_init]:=IntToStr(CharToByte(Current_String[proc_j]));
                    inc(curr_addr_mas_init);
                  end;
                for proc_j:=Length(Current_String)+1 to proc_Index2Size do
                  begin
                    Mas_Init[curr_addr_mas_init]:='32';
                    inc(curr_addr_mas_init);
                  end;
                Match(_string_Constant);
                Match(_comma);
              end;
          Mas_Init[curr_addr_mas_init]:=IntToStr(Length(Current_String));
          inc(curr_addr_mas_init);
          for proc_j:=1 to Length(Current_String) do
            begin
              Mas_Init[curr_addr_mas_init]:=IntToStr(CharToByte(Current_String[proc_j]));
              inc(curr_addr_mas_init);
            end;
          for proc_j:=Length(Current_String)+1 to proc_Index2Size do
            begin
              Mas_Init[curr_addr_mas_init]:='32';
              inc(curr_addr_mas_init);
            end;
          Match(_string_Constant);
          Match(_rsqbkt);
        end;

    end;

  end;

for proc_i:=1 to proc_i_max do
  if LookIdName(proc_mas_name[proc_i])<>-1
    then Abort('Duplicate name')
    else AddSymbol(proc_mas_name[proc_i],kind,True,proc_CountIndex,proc_Index1Size,proc_Index2Size,proc_curr_addr_mas_init);

end;


procedure VarBlock;
var
  tmp  : NameStr;
  kind : integer;
begin
  Match(_Var);
  while (Current_Token = _Name) do
  begin
    VarStatement(kind);
    Match(_separator);
  end;
end;



procedure Repeat_Loop;
var
  tmp   : NameStr;
  Start,DoneLabel,EndLabel : LabelStr;
begin
  Match(_Repeat);

  Start := NewLabel;
  DoneLabel  := NewLabel;
  EndLabel := NewLabel;
  GlobalLabel:= EndLabel;

  GenCode('=== Repeat begin ===',0,'','','','');

  GenCode('_PutLabel',0,Start,'','','');

  repeat
    If Current_Token <> _Until then
    begin
      Statement;
      Match(_separator);
    end;
  until Current_Token = _Until;

  Match(_Until);

  GlobalLabel:= EndLabel; // !!!!!!!!!!!!!
  Expression;

  while Current_Token in [_and,_or] do
  case Current_Token of
     _and:
        begin
           Match(_and);
           Expression;
        end;
     _or:
        begin
           Match(_or);
           GenCode('_JumpTo',0,DoneLabel,'','','');
           GenCode('_PutLabel',0,EndLabel,'','','');
           EndLabel := NewLabel;
           GlobalLabel:=EndLabel;
           Expression;
        end;
  end;

  GenCode('_JumpTo',0,DoneLabel,'','','');
  GenCode('_PutLabel',0,EndLabel,'','','');
  GenCode('_JumpTo',0,Start,'','','');

  GenCode('_PutLabel',0,DoneLabel,'','','');

  GenCode('=== Repeat end ===',0,'','','','');

end;

Procedure put_sprite_var;
Var
  sx : string;
begin
	Match(_lparen);
	if Current_Number > 63 then Abort('Unknown variable  (X-position : 0-63 - OK)');
	Expression;
	GenCode('_StoreByte',0,'SPRITE_X','','','');
	Match(_comma);
	if Current_Number > 239 then Abort('Unknown variable  (Y-position : 0-239 - OK)');
	Expression;
	GenCode('_StoreByte',0,'SPRITE_Y','','','');
	Match(_comma);
  	sx := Current_String;
  	GenCode('_PutSpriteName',0,sx,'','','');
  	Match(_name);
	Match(_comma);
	if Current_Number > 3 then Abort('Unknown variable  (Mode : 0=Rewrite, 1=Xor - OK)');
  	Expression;
    GenCode('_StoreByte',0,'SPRITE_DRAW_MODE','','','');
  	Match(_rparen);
end;

Procedure put_array_name;
Var
  sx : string;
  proc_ii: word;
begin
  sx := GetName;
  proc_ii:=LookIdName(sx);
  Case LookSymbol(sx) of
     _ArrayByte,_ArrayString: GenCode('_ClearArray',SymbolTable[proc_ii].Index1Size*SymbolTable[proc_ii].Index2Size-1,sx,'','','');
     _ArrayWord: GenCode('_ClearArray',SymbolTable[proc_ii].Index1Size*SymbolTable[proc_ii].Index2Size*2-1,sx,'','','');
     else Abort('Uncompatible type');
  end;
end;


Procedure DoProcedure;
Var
  ProcName : NameStr;
Begin
  Match(_Procedure);
  ProcName := GetName;
  Match(_Separator);
  GenCode('=== Procedure begin ===',0,'','','','');
  GenCode('_PutLabel',0,ProcName,'','','');
  AddSymbol(ProcName,_Void,False,0,0,0,0);
  BlockStatement;
  GenCode('_Return',0,'','','','');
  GenCode('=== Procedure end ===',0,'','','','');
End;

procedure Statement;
Var
  sx : string;
  id_type_symbol, proc_i, iDat1, iDat2: integer;
  x1,y1,szel,mag : word;

begin

  GenCode('=== Statement begin ===',0,'','','','');

  Case Current_Token of
    _while  : while_Loop;
    _repeat : repeat_loop;
    _for    : for_loop;
    _if     : if_then_else;
    _case   : case_op;
    _begin  : BlockStatement;
    _delay  : begin
                Match(_delay);
                Match(_lparen);
                Expression;
                GenCode('_Call',0,'pause','','','');
                Match(_rparen);
                Mas_Lib[13].flag:=true;
              end;
    _randomize : begin
                Match(_randomize);
                GenCode('_PutRandomize',0,'','','','');
              end;
    _arrayclear : begin
                Match(_arrayclear);
                Match(_lparen);
                put_array_name;
                Match(_rparen);
              end;
    _asm : begin
                Match(_asm);
                Match(_lparen);
                GenCode('_Call',0,Current_String,'','','');
                Match(_name);
                Match(_rparen);
              end;

//----------------------- EGYÉB SAJÁT ----------------------------



//------------------------- T V C ---------------------------------

     _graphics : begin
               Match(_graphics);
               Match(_lparen);
			   //showmessage(inttostr(Current_Number));
               case Current_Number of
                  2 : Current_Number := 0;
                  4 : Current_Number := 1;
                  16: Current_Number := 2;
               else
                  Abort('Graphics : Unknown variable  (2, 4, 16 - OK)');
               end;
               Expression;
               GenCode('_Call',0,'graphics','','','');
               Match(_rparen);
               Mas_Lib[19].flag:=true;
               end;

     _videoon : begin
                Match(_videoon);
                Match(_lparen);
                GenCode('_Video_On',Current_Number,'','','','');
				GetNumber;
                Match(_rparen);
                end;
     _videooff : begin
                Match(_videooff);
                GenCode('_Video_Off',0,'','','','');
                end;
     _cls : begin
                Match(_cls);
                //Match(_lparen);
                GenCode('_Cls',0,'','','','');
                //Match(_rparen);
                end;

     _PrintAt : begin
              Match(_PrintAt);
	      Match(_lparen);
	      Expression;
              GenCode('_StoreByte',0,'PRINTAT_X','','','');
              Match(_comma);
              Expression;
              GenCode('_StoreByte',0,'PRINTAT_Y','','','');
              Match(_comma);

              {az átvett 3. paraméter ellenörzése:}
              case Current_Token of
                  _string_constant :
                    begin
                         //szöveg konstans kiírása: pl.: PrintAt(3,3,'TEST');
                         temp_name_string := DoStringConst(Current_String);
                         //showmessage(inttostr(length(Current_String)));
                         //Üres stringet ne tudunk kiírni!!
                         if (length(Current_String) = 0) then
                            Abort('PrintAt : String must have character!');
                         Match(_String_Constant);
                         GenCode('_LoadLabel',0,temp_name_string,'','','');
                    end;
                  _numeric_Constant :
                    begin
                      //Szám kiírása: pl.: PrintAt(3,3,234);
                      GenCode('_LoadConst',GetNumber,'','','','');
	       			  GenCode('_PutWord',0,'','','','');
                    end;
	      else
       	          begin
        	       id_type_symbol:=LookSymbol('_'+Current_String);
                       case id_type_symbol of
                                _String,_ArrayString:
                                  begin
                                    //nevem : string[9] = 'NaCsAsOfT'; PrintAt(1,3,nevem);
                                    temp_name_string:='string_temp';
                                    GenCode('_ResetStringLength',0,temp_name_string,'','','');
                                    StringExpression;
                                    GenCode('_PutString',0,temp_name_string,'','','');
                                    Mas_Lib[15].flag:=true;
                                    Mas_Lib[16].flag:=true;
                                  end;

                                _Byte,_Word,_ArrayByte,_ArrayWord:
                                  begin
                                    //PrintAt(4,4, arr_ta[5,3]);
                                    Expression;
                                    GenCode('_PutWord',0,'','','','');
                                  end

                                else Abort('PrintAt : Unknown variable');
                              end;
					          end;
                end;	//case end.
                //lib-ben lévő asm eljárás meghívása:
		GenCode('_Call',0,'printat','','','');
		Match(_rparen);
                Mas_Lib[24].flag:=true;
		Mas_Lib[25].flag:=true;
              end;

     _PrintPlot : begin
                       Match(_PrintPlot);
		       Match(_lparen);
		       Expression;
		       GenCode('_StoreWord',0,'PRINTPLOT_X','','','');
                       Match(_comma);
                       Expression;
                       GenCode('_StoreWord',0,'PRINTPLOT_Y','','','');
                       Match(_comma);

                {az átvett 3. paraméter ellenörzése:}
                case Current_Token of
                  _string_constant :
                    begin
                     //szöveg konstans kiírása: pl.: PrintPlot(100,100,'TEST');
		     temp_name_string := DoStringConst(Current_String);
                     //Üres stringet ne tudunk kiírni!!
                     if (length(Current_String) = 0) then
                            Abort('PrintPlot : String must have character!');
                     Match(_String_Constant);
                     GenCode('_LoadLabel',0,temp_name_string,'','','');
                    end;
                  _numeric_Constant :
                    begin
                      //Szám kiírása: pl.: PrintPlot(100,100,234);
                      GenCode('_LoadConst',GetNumber,'','','','');
	       			  GenCode('_PutWord',0,'','','','');
                    end;
				else
       			  begin
        			  id_type_symbol:=LookSymbol('_'+Current_String);

                      case id_type_symbol of

                        _String,_ArrayString:
                          begin
                            {nevem : string[9] = 'NaCsAsOfT';
                            PrintPlot(1,150,nevem); }
                            temp_name_string:='string_temp';
                            GenCode('_ResetStringLength',0,temp_name_string,'','','');
                            StringExpression;
                            GenCode('_PutString',0,temp_name_string,'','','');
                            Mas_Lib[15].flag:=true;
                            Mas_Lib[16].flag:=true;
                          end;

                        _Byte,_Word,_ArrayByte,_ArrayWord:
                          begin
                            {arr_ta : array[1..10, 1..10] of byte;
    						bb : byte = 112;
                            PrintPlot(450,450, arr_ta[5,3]);}
                            Expression;
                            GenCode('_PutWord',0,'','','','');
                          end

                        else Abort('PrintPlot : Unknown variable');
                      end;
					  end;
                end;	//case end.

                //lib-ben lévő asm eljárás meghívása:
				        GenCode('_Call',0,'printplot','','','');
				        Match(_rparen);

                Mas_Lib[21].flag:=true;
				Mas_Lib[22].flag:=true;
     			end;

     _SetInk : begin            //Tintaszín beállítása
                Match(_SetInk);
                Match(_lparen);
                if (Current_Number < 0) or (Current_Number > 15) then
               		Abort('SetInk : Unknown variable  (0 - 15 - OK)');
                Expression;
                GenCode('_SetInk',0,'','','','');
                Match(_rparen);
          end;

     _SetPaper : begin        //Háttér szín beállítása
                Match(_SetPaper);
                Match(_lparen);
                Expression;
                GenCode('_SetPaper',0,'','','','');
                Match(_rparen);
          end;

     _SetBorder : begin     //Keretszín beállítása.
                Match(_SetBorder);
                Match(_lparen);
                Expression;
                GenCode('_SetBorder',0,'','','','');
                Match(_rparen);
          end;

     _SetPalette : begin
              Match(_SetPalette);
			  Match(_lparen);
              Expression;
              GenCode('_StoreByte',0,'PALETTE_00','','','');
              Match(_comma);

              Expression;
              GenCode('_StoreByte',0,'PALETTE_01','','','');
              Match(_comma);

              Expression;
              GenCode('_StoreByte',0,'PALETTE_02','','','');
              Match(_comma);

              Expression;
              GenCode('_StoreByte',0,'PALETTE_02','','','');
              Match(_rparen);
              GenCode('_Call',0,'setpalette','','','');

              Mas_Lib[26].flag:=true;
              Mas_Lib[27].flag:=true;
              end;

     _SetChar : begin
               	  Match(_SetChar);
               	  Match(_lparen);
                  Expression;
                  GenCode('_StoreByte',0,'CHAR_NR','','','');
               	  Match(_comma);
				  //pontmátrixnak array[1..10] of byte -ban kell lenni!!
               	  sx := GetName;
               	  if LookSymbol(sx)<>_ArrayByte then
                  	Abort('SetCharUncompatible type (array[1..10] of byte - OK)');	//ha nem Byte tömb akkor hiba
		  GenCode('_LoadLabel',0,sx,'','','');
		  //setchar libasm-rutin meghívása (pontmátrix másolása a tömbből a megfelelő helyre...)
               	  GenCode('_Call',0,'setchar','','','');
               	  Match(_rparen);
               	  Mas_Lib[29].flag:=true;	//setchar eljárás betöltése a lib-ből
                  Mas_Lib[30].flag:=true;	//karakter azonosító betöltése a lib-ből
               	end;

     _PrintChar : begin
		                Match(_PrintChar);
					    Match(_lparen);
					    Expression;
		                GenCode('_StoreByte',0,'PRINTAT_X','','','');
		                Match(_comma);
		                Expression;
		                GenCode('_StoreByte',0,'PRINTAT_Y','','','');
		                Match(_comma);
		                Expression;
		                GenCode('_StoreByte',0,'CHAR_NR','','','');
					    //lib-ben lévő asm eljárás meghívása:
					    GenCode('_Call',0,'printchar','','','');
		                Match(_rparen);
					    Mas_Lib[25].flag:=true;	//pozíció
                        Mas_Lib[30].flag:=true;	//karakter azonosító betöltése a lib-ből
                        Mas_Lib[31].flag:=true;	//printchar eljárás
              end;

     _PrintPlotChar : begin
		                Match(_PrintPlotChar);
					    Match(_lparen);
					    Expression;
		                GenCode('_StoreWord',0,'PRINTPLOT_X','','','');
		                Match(_comma);
		                Expression;
		                GenCode('_StoreWord',0,'PRINTPLOT_Y','','','');
		                Match(_comma);
		                Expression;
		                GenCode('_StoreByte',0,'CHAR_NR','','','');
					    //lib-ben lévő asm eljárás meghívása:
					    GenCode('_Call',0,'printplotchar','','','');
		                Match(_rparen);
					    Mas_Lib[22].flag:=true;	//printplot pozíció
                        Mas_Lib[30].flag:=true;	//karakter azonosító betöltése a lib-ből
                        Mas_Lib[32].flag:=true;	//printplotchar eljárás
              end;

     _linestyle : begin			//Vonalstílus beállítása 0-16 a Operációs rendszer - 11-es függelék
               Match(_LineStyle);
               Match(_lparen);
               if (Current_Number < 0) or (Current_Number > 16) then
               		Abort('LineStyle : Unknown variable  (0 - 16 - OK)');
               Expression;
               GenCode('_LineStyle',0,'','','','');
               Match(_rparen);
               end;

     _setmode : begin			//Vonal kereszteződési módja : 0 – Felülírás ; 1 – OR ; 2 – AND ; 3 – XOR
               Match(_SetMode);
               Match(_lparen);
               if (Current_Number < 0) or (Current_Number > 3) then
               		Abort('SetMode : Unknown variable  (0 - 3 - OK)');
               Expression;
               GenCode('_SetMode',0,'','','','');
               Match(_rparen);
               end;

     _plot : begin			//Vonal rajzolása
               Match(_Plot);
               Match(_lparen);
               if (Current_Number < 0) or (Current_Number > 1023) then
               		Abort('Plot : Unknown variable  (0 - 1023 - OK)');
               Expression;
               GenCode('_StoreWord',0,'LINEPOS_X1','','','');
               Match(_comma);
               if (Current_Number < 0) or (Current_Number > 959) then
               		Abort('Plot : Unknown variable  (0 - 959 - OK)');
			   Expression;
               GenCode('_StoreWord',0,'LINEPOS_Y1','','','');
               Match(_comma);
               if (Current_Number < 0) or (Current_Number > 1023) then
               		Abort('Plot : Unknown variable  (0 - 1023 - OK)');
			   Expression;
               GenCode('_StoreWord',0,'LINEPOS_X2','','','');
               Match(_comma);
               if (Current_Number < 0) or (Current_Number > 959) then
               		Abort('Plot : Unknown variable  (0 - 959 - OK)');
			   Expression;
               GenCode('_StoreWord',0,'LINEPOS_Y2','','','');
               GenCode('_Call',0,'plot','','','');
               Match(_rparen);
               Mas_Lib[33].flag:=true;	//pozíciók
     		   Mas_Lib[34].flag:=true;	//line eljárás
               end;

     _plotrect : begin			//Téglalap rajzolása
               Match(_PlotRect);
               Match(_lparen);
			   //Bal felső koordináta :
               x1 := Current_Number;
               if (x1 < 0) or (x1 > 1023) then Abort('PlotRect : Unknown variable  (0 - 1023 - OK)');
               Expression;
               GenCode('_StoreWord',0,'LINEPOS_X1','','','');
               Match(_comma);
               y1 := Current_Number;
               if (y1 < 0) or (y1 > 959) then Abort('PlotRect : Unknown variable  (0 - 959 - OK)');
			   Expression;
               GenCode('_StoreWord',0,'LINEPOS_Y1','','','');
               Match(_comma);
			   //szélesség :
               szel := Current_Number;
			   if (x1 + szel > 1023 ) then Abort('PlotRect : Unknown variable (X + Width > 1023)');
               Current_Number:=x1+szel;
			   Expression;
               GenCode('_StoreWord',x1 + szel,'LINEPOS_X2','','','');
               Match(_comma);
               //magasság:
               mag := Current_Number;
			   if (y1 - mag < 0) then Abort('PlotRect : Unknown variable (Y - Height < 0)');
               Current_Number:=y1-mag;
			   Expression;
               GenCode('_StoreWord',y1 - mag,'LINEPOS_Y2','','','');
               GenCode('_Call',0,'plotrect','','','');
               Match(_rparen);
               Mas_Lib[33].flag:=true;	//pozíciók
     		   Mas_Lib[35].flag:=true;	//line eljárás
               end;

     _fill : begin				//Terület kifestése adott pontból kiindulva adott színnel
               Match(_Fill);
               Match(_lparen);
               if (Current_Number < 0) or (Current_Number > 1023) then Abort('Fill : Unknown variable  (0 - 1023 - OK)');
               Expression;
               GenCode('_StoreWord',0,'LINEPOS_X1','','','');
               Match(_comma);
               if (Current_Number < 0) or (Current_Number > 959) then Abort('Fill : Unknown variable  (0 - 959 - OK)');
			   Expression;
               GenCode('_StoreWord',0,'LINEPOS_Y1','','','');
               Match(_comma);
               if (Current_Number < 0) or (Current_Number > 15) then Abort('Fill : Unknown variable  (0 - 15 - OK)');
               Expression;
               GenCode('_StoreWord',0,'LINEPOS_X2','','','');	//x2 most a színt fogja tartalmazni
               GenCode('_Call',0,'fill','','','');
               Match(_rparen);
               Mas_Lib[33].flag:=true;	//pozíciók (linepos_x2 -festés színe most!!
     		   Mas_Lib[36].flag:=true;	//line eljárás
               end;

     _pause : begin						//várakozás egy billentyű lenyomására
                Match(_pause);
                Match(_lparen);
                GenCode('_Pause',0,'','','','');
                Match(_rparen);
                end;

     _SetKeyRepeatRate : begin
       			Match(_SetKeyRepeatRate);
                Match(_lparen);
                Expression;
                GenCode('_SetKeyRepeatRate',0,'','','','');
                Match(_rparen);
                end;

     _InputAtString : begin		//Szöveg beolvasása az adott (x,y) pozíciótól az arrInputString -tömbbe amit előzőleg deklarálni kell.
				Match(_InputAtString);
                Match(_lparen);
                Expression;
              	GenCode('_StoreByte',0,'PRINTAT_X','','','');
              	Match(_comma);
              	Expression;
              	GenCode('_StoreByte',0,'PRINTAT_Y','','','');
              	Match(_comma);
                sx := GetName;
               	if LookSymbol(sx)<>_String then
                  	Abort('InputAtString : Uncompatible type (string[n] - OK)');	//ha nem Byte tömb akkor hiba
			   	GenCode('_LoadLabel',0,sx,'','','');
                GenCode('_Call',0,'inputatstring','','','');
                Match(_rparen);
				Mas_Lib[25].flag:=true;		//pozíciók
				Mas_Lib[39].flag:=true;		//inputatstring -eljárás
     			end;

     _InputAtNumber : begin		//Szöveg beolvasása az adott (x,y) pozíciótól az arrInputString -tömbbe amit előzőleg deklarálni kell.
				Match(_InputAtNumber);
                Match(_lparen);
                Expression;
              	GenCode('_StoreByte',0,'PRINTAT_X','','','');
              	Match(_comma);
              	Expression;
              	GenCode('_StoreByte',0,'PRINTAT_Y','','','');
              	Match(_comma);
                sx := GetName;
               	if LookSymbol(sx) <> _Word then
                  	Abort('InputAtNumber : Uncompatible type (WORD - OK)');	//ha nem Word típus akkor hiba
			   	GenCode('_LoadLabel',0,sx,'','','');
                GenCode('_Call',0,'inputatnumber','','','');
                Match(_rparen);
                Mas_Lib[7].flag:=true;		//_mul	-kell a konvertáláshoz!!
                Mas_Lib[12].flag:=true;		//_put_number_variable		-ide kerül majd a szám!!
				Mas_Lib[25].flag:=true;		//pozíciók
				Mas_Lib[40].flag:=true;		//inputatnumber -eljárás
                Mas_Lib[41].flag:=true;		//_convert_string_to_16bit
     			end;

     _Poke : begin
				Match(_Poke);
                Match(_lparen);
                Expression;
                GenCode('_StoreWord',0,'POKE_ADDRESS','','','');
              	Match(_comma);
              	Expression;
              	GenCode('_StoreByte',0,'POKE_DATA','','','');
                GenCode('_Poke',0,'','','','');
                Match(_rparen);
                Mas_Lib[42].flag:=true;
       			end;

     _SoundVolume : begin	//Hangerő beállítása (n – byte, 0-15)
               Match(_SoundVolume);
               Match(_lparen);
               if Current_Number > 15 then Abort('SoundVolume : Unknown variable  (0-15 - OK)');
               Expression;
               GenCode('_StoreByte',0,'SOUND_VOLUME','','','');
               GenCode('_Call',0,'sound_volume','','','');
               Match(_rparen);
               Mas_Lib[47].flag:=true;	//sound változók
               Mas_Lib[48].flag:=true;	//sound eljárások
               end;

     _SoundInit : begin		//Hang lejátszás leállítása
               Match(_SoundInit);
               GenCode('_Call',0,'sound_stop','','','');
               Mas_Lib[48].flag:=true;	//sound eljárások
               end;

     _SoundStop : begin		//Hang lejátszás leállítása
               Match(_SoundStop);
               GenCode('_Call',0,'sound_stop','','','');
               Mas_Lib[48].flag:=true;	//sound eljárások
               end;

     _SoundPlay : begin	//Hang lejátszás indítása (PITCH, DURATION)
               Match(_SoundPlay);
               Match(_lparen);
               if Current_Number > 4095 then Abort('SoundPlay : Unknown variable  (0-4095 - OK)');
               Expression;
               GenCode('_StoreWord',0,'SOUND_PITCH','','','');
               Match(_comma);
               Expression;
			   GenCode('_StoreWord',0,'SOUND_DURATION','','','');
               GenCode('_Call',0,'sound_play','','','');
               Match(_rparen);
               Mas_Lib[47].flag:=true;	//sound változók
               Mas_Lib[48].flag:=true;	//sound eljárások
               end;

     _PutSprite : begin
                Match(_PutSprite);
                put_sprite_var;
                GenCode('_Call',0,'putsprite','','','');
               	Mas_Lib[49].flag:=true;	//sprite változók
                Mas_Lib[50].flag:=true;	//putsprite eljárás
                Mas_Lib[51].flag:=true;	//set_cursot_it eljárás
                end;


  else
    Assignment;
  end;

  GenCode('=== Statement end ===',0,'','','','');

end;

(****************************
         Program Parser
 ****************************)
var
  ProgramName : NameStr;



procedure _Program_;
var
  tmp : NameStr;

  buf,buf1 : string;
  i_proc, i_mirror: word;
  done,flag_output,flag_output01,flag_output02 : boolean;
begin

  If Current_Token = _Program then
  begin
    Match(_Program);
    ProgramName := GetName;
    Match(_separator);
  end;

  Done := False;
  Repeat
    Case Current_Token of
      _Const     : ConstBlock;
      _Var       : VarBlock;
      _Procedure : DoProcedure;
      _Separator : Match(_Separator);
    else
      Done := True;
    End;
  Until Done;

  GenCode('_PutLabel',0,'MAIN','','','');
  AddSymbol('Main',_Void,False,0,0,0,0);

  i_mirror:=CodeCounter;
  //GenCode('_Call',0,'put_table_mirror','','','');              // for mirror initial

  BlockStatement;

  GenCode('_ProgramExit',0,'','','','');

  MaxCodeCounter:=CodeCounter-1;
  Optimization;

  WriteLn(Dest,#13);

  while not eof(Source) do
    begin
      readln(Source,buf);
      writeln(Dest,buf);
    end;

  WriteLn(Dest,#13);
  WriteLn(Dest,'; ***** Library Code ***** ');

  AssignFile(Lib,'libasm.lib');
  Reset(Lib);
  If IOresult = 0 then

  begin

    flag_output:=true;

    while not eof(lib) do

    begin //--------------------------

      readln(lib,buf);
      flag_output02:=false;

      if length(buf)>9 then
      if ((buf[1]=';') and (buf[3]='=') and (buf[4]='=') and (buf[5]='=')
          and (buf[6]='=') and (buf[7]='='))
          then
            begin
              buf1:='';
              i_proc:=9;

              while buf[i_proc]<>' ' do
              begin
                buf1:=buf1+buf[i_proc];
                inc(i_proc);
              end;

              flag_output:=false;
              i_proc:=1;
              while i_proc<=value_mas_lib do
                begin
                  if ((Mas_Lib[i_proc].name=buf1) and (Mas_Lib[i_proc].flag=true))
                    then flag_output:=true;
                  inc(i_proc);
                end;
              flag_output02:=true;
            end;

      if length(buf)>9 then
      if ((buf[1]=';') and (buf[3]='+') and (buf[4]='+') and (buf[5]='+')
          and (buf[6]='+') and (buf[7]='+'))
          then
            begin
              buf1:='';
              i_proc:=9;

              while buf[i_proc]<>' ' do
              begin
                buf1:=buf1+buf[i_proc];
                inc(i_proc);
              end;

              i_proc:=1;
              while i_proc<=value_mas01_lib do
                begin
                  if Mas01_Lib[i_proc].name=buf1 then Mas01_Lib[i_proc].flag_out:=true;
                  inc(i_proc);
                end;
              flag_output02:=true;

            end;

      if length(buf)>9 then
      if ((buf[1]=';') and (buf[3]='-') and (buf[4]='-') and (buf[5]='-')
          and (buf[6]='-') and (buf[7]='-'))
          then
            begin
              buf1:='';
              i_proc:=9;

              while buf[i_proc]<>' ' do
              begin
                buf1:=buf1+buf[i_proc];
                inc(i_proc);
              end;

              i_proc:=1;
              while i_proc<=value_mas01_lib do
                begin
                  if Mas01_Lib[i_proc].name=buf1 then Mas01_Lib[i_proc].flag_out:=false;
                  inc(i_proc);
                end;
              flag_output02:=true;

            end;

      if flag_output=true then
         begin

            flag_output01:=true;

            i_proc:=1;
            while i_proc<=value_mas01_lib do
                begin
                  if ((Mas01_Lib[i_proc].flag=false) and (Mas01_Lib[i_proc].flag_out=true))
                     then flag_output01:=false;
                  inc(i_proc);
                end;

            if ((flag_output01=true) and (flag_output02=false)) then writeln(Dest,buf);

         end;

    end; //--------------------------

    CloseFile(lib);
  end;

  WriteLn(Dest,#13);
  WriteLn(Dest,'; ***** Library Ends *****');
  DumpSymbols;
  DumpStrings;
  //EmitLn('db      100 dup(0)');
  //EmitLn('end     main   ');
end;

(**************************
        Main Program
 **************************)

procedure Init;
begin
  LineCount   := 0;
  LabelCount  := 0;
  SymbolCount := 0;
  StringCount := 0;

  TypeTable[0] := TypeWord;
  TypeTable[1] := TypeByte;
  TypeTable[2] := TypeLong;
  TypeTable[3] := TypeString;
  TypeTable[4] := TypeVoid;
  TypeTable[5] := TypeArrayWord;
  TypeTable[6] := TypeArrayByte;
  TypeTable[7] := TypeArrayString;
  TypeTable[8] := TypeArray;
  TypeCount    := 9;

  ProgramName := 'NONAME';
  GetChar;
  GetToken;
end;


Var
  Err : Byte;
  F   : file;
  id_param: integer;
  i: word;
  BeginAddress: string;
Begin

     Form1.Hide;

  for i:=1 to value_mas01_lib do
    begin
      Mas01_Lib[i].flag:=false;
      Mas01_Lib[i].flag_out:=false;
    end;

  Mas01_Lib[1].name:='_flag_attr_text';
  Mas01_Lib[2].name:='_flag_attr_window';
  Mas01_Lib[3].name:='_flag_attr_sprite';
  Mas01_Lib[4].name:='_flag_attr_map';
  Mas01_Lib[5].name:='_flag_edge_screen_sprite';
  Mas01_Lib[6].name:='_flag_virt_scr_text';
  Mas01_Lib[7].name:='_flag_virt_scr_sprite';
  Mas01_Lib[8].name:='_flag_virt_scr_map';

id_param:=3;
if ParamCount>0
  then
    begin
      Name:=ParamStr(1);
      BeginAddress:=ParamStr(2);
      while id_param<=ParamCount do
        begin
          if ParamStr(id_param)='-a' then Mas01_Lib[1].flag:=true;
          if ParamStr(id_param)='-b' then Mas01_Lib[2].flag:=true;
          if ParamStr(id_param)='-c' then Mas01_Lib[3].flag:=true;
          if ParamStr(id_param)='-d' then Mas01_Lib[4].flag:=true;
          if ParamStr(id_param)='-e' then Mas01_Lib[5].flag:=true;
          if ParamStr(id_param)='-f' then Mas01_Lib[6].flag:=true;
          if ParamStr(id_param)='-g' then Mas01_Lib[7].flag:=true;
          if ParamStr(id_param)='-h' then Mas01_Lib[8].flag:=true;
          inc(id_param);
        end;
    end
  else
    begin
      if OpenDialog1.execute then Name:=Opendialog1.Filename;
      BeginAddress:=Form1.Edit1.Text;
      if Form1.CheckBox1.Checked=true then Mas01_Lib[1].flag:=true;
      if Form1.CheckBox2.Checked=true then Mas01_Lib[2].flag:=true;
      if Form1.CheckBox3.Checked=true then Mas01_Lib[3].flag:=true;
      if Form1.CheckBox4.Checked=true then Mas01_Lib[4].flag:=true;
      if Form1.CheckBox5.Checked=true then Mas01_Lib[5].flag:=true;
      if Form1.CheckBox6.Checked=true then Mas01_Lib[6].flag:=true;
      if Form1.CheckBox7.Checked=true then Mas01_Lib[7].flag:=true;
      if Form1.CheckBox8.Checked=true then Mas01_Lib[8].flag:=true;
    end;


  AssignFile(Source,Name);
  Reset(Source);

  AssignFile(Dest,Leftstr(Name, length(Name)-4)+'.asm');
  ReWrite(Dest);

  AssignFile(fError,'error.err');
  Rewrite(fError);

  //AssignFile(fCommand,'non_opt_code.txt');
  //Rewrite(fCommand);

  for i:=2 to value_mas_lib do
    Mas_Lib[i].flag:=false;

  Mas_Lib[1].flag:=false;

  Mas_Lib[1].name:='_all';
  Mas_Lib[2].name:='_convert_16bit_to_string';
  Mas_Lib[3].name:='_print64';				      //Nincs használva
  Mas_Lib[4].name:='_move_cr64';			      //Nincs használva
  Mas_Lib[5].name:='_calc_addr_scr';		    //Nincs használva
  Mas_Lib[6].name:='_scroll_up8';			      //Nincs használva
  Mas_Lib[7].name:='_mul_proc';
  Mas_Lib[8].name:='_div_proc';
  Mas_Lib[9].name:='_font64';  				      //string konvertálásokhoz kell
  Mas_Lib[10].name:='_table_addr_scr';
  Mas_Lib[11].name:='_put_text_variable';
  Mas_Lib[12].name:='_put_number_variable';
  Mas_Lib[13].name:='_delay';				//késleltetés (50 = 1 másodperces késleltetés!)
  Mas_Lib[14].name:='_random_byte';			//8 bites random szám
  Mas_Lib[15].name:='_array_index';
  Mas_Lib[16].name:='_put_string_temp';
  Mas_Lib[17].name:='_put_addr_array_string';
  Mas_Lib[18].name:='_window';
  Mas_Lib[19].name:='_graphics';		    //felbontás beállítása
  Mas_Lib[20].name:='_tvc_mem_pager';  	    //memórialapozással kapcsolatos változók
  Mas_Lib[21].name:='_printplot';			//string, változó, stb. kiírása egy kurzor pozícióba
  Mas_Lib[22].name:='_printplot_pos';		//sugár pozíció
  Mas_Lib[23].name:='_add_string';		    //string muveletekhez
  Mas_Lib[24].name:='_printat';				//string, változó, stb. kiírása egy kurzor pozícióba
  Mas_Lib[25].name:='_printat_pos';			//karakter pozíció
  Mas_Lib[26].name:='_tvc_palette_codes';   //Paletta kódok
  Mas_Lib[27].name:='_setpalette';          //Paletta beállítása a palettakódokból
  Mas_Lib[28].name:='_random_word';			//16 bites random szám
  Mas_Lib[29].name:='_setchar';	   			//egyéni karakter definiálása (SET CHARACTER...)
  Mas_Lib[30].name:='_tvc_setchar_vars';
  Mas_Lib[31].name:='_printchar';			//egyedi karakter kiírása egy kurzor pozícióba
  Mas_Lib[32].name:='_printplotchar';		//egyedi karakter kiírása egy sugár pozícióba
  Mas_Lib[33].name:='_line_pos_vars';		//rajzolásokkal kapcsolatos pozíciók tárolása
  Mas_Lib[34].name:='_plot';				//Vonal rajzolása start: x1,y1 ; end: x2,y2
  Mas_Lib[35].name:='_plotrect';			//Téglalap rajzolása start: x1,y1 ; szél: x2 ; mag: y2
  Mas_Lib[36].name:='_fill';				//Terület kifestése adott pontból kiindulva adott színnel
  Mas_Lib[37].name:='_get';					//Várakozás amíg le nem nyomunk egy gombot majd visszaadja a lenyomott billentyű kódját.
  Mas_Lib[38].name:='_inkey';				//Billentyűzet állapot leolvasása ha nyomtak le vmit akkor visszaadja a kódját.
  Mas_Lib[39].name:='_inputatstring';		//Szöveg beolvasása az adott (x,y) pozíciótól az arrInputString -tömbbe amit előzőleg deklarálni kell.
  Mas_Lib[40].name:='_inputatnumber';		//Szám (0-65535) beolvasása az adott (x,y) pozíciótól.
  Mas_Lib[41].name:='_convert_string_to_16bit';		//string átalakítása 16bites számmá!
  Mas_Lib[42].name:='_tvc_poke_peek_vars';	//Poke és Peek változói
  Mas_Lib[43].name:='_logical_vars';		//Logikai vizsgálatok adatai (AndByte, OrByte, XorByte)
  Mas_Lib[44].name:='_andbyte';				//AND logikai vizsgalat LOGICAL_A es LOGICAL_B kozott, eredmeny = hl
  Mas_Lib[45].name:='_orbyte';				//OR logikai vizsgalat LOGICAL_A es LOGICAL_B kozott, eredmeny = hl
  Mas_Lib[46].name:='_xorbyte';   			//XOR logikai vizsgalat LOGICAL_A es LOGICAL_B kozott, eredmeny = hl
  Mas_Lib[47].name:='_sound_vars';   		//hangal kapcsolatos változók (SOUND_VOLUME; SOUND_PITCH; SOUND_DURATION)
  Mas_Lib[48].name:='_sound';   			//hang : SoundStop; SoundVolume; SoundPlaying; SoundPlay
  Mas_Lib[49].name:='_sprite_vars';			//sprite változók (X,Y pozíciók; felülírási mód (Rewrite; Xor))
  Mas_Lib[50].name:='_putsprite';			//putsprite eljárás
  Mas_Lib[51].name:='_set_cursor_it';		//set_cursot_it eljárás


  CodeCounter:=1;

  curr_addr_mas_init:=1;

  //EmitLn('org   '+BeginAddress);
  EmitLn('ORG 6639                  ;{BASIC Header');
  EmitLn('DEFB $0F,$0A,$0,$DD 	    ; "10 PRINT" - basic token');
  EmitLn('DEFB '' USR'' 			      ; " USR"');
  EmitLn('DEFB $96 				          ; "("');
  EmitLn('DEFB ''6659''  			      ; "6659"');
  EmitLn('DEFB $95,$FF,0,0,0,0,0 		; ")"');

  GenCode('_JumpTo',0,'MAIN','','','');

  Init;
  _Program_;

  CloseFile(Source);
  CloseFile(Dest);
  CloseFile(fError);

  //CloseFile(fCommand);

  //windows alatt a writeln halott!!!....
  {$IfDef WINDOWS}
    ShowMessage('File compiled successfully in '+Leftstr(Name, length(Name)-4)+'.asm !');
  {$Else}
    WriteLn('File compiled successfully in '+Leftstr(Name, length(Name)-4)+'.asm !');
  {$EndIf}

  Application.Terminate;

end;

procedure TForm1.FormActivate(Sender: TObject);
begin
 self.Hide;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
     Self.Hide;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     self.Hide;
     if ParamCount<>0 then btnPascalToASMClick(self);
end;

end.
