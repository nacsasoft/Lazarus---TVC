unit global;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  cFekete = 0;
  cSotet_Kek_1 = 2;
  cSotet_Kek_2 = 1;
  cSotet_Voros_1 = 8;
  cSotet_Voros_2 = 4;
  cSotet_Lila_1 = 10;
  cSotet_Lila_2 = 5;
  cSotet_Zold_1 = 32;
  cSotet_Zold_2 = 16;
  cSotet_KekesZold_1 = 34;
  cSotet_KekesZold_2 = 17;
  cSotet_Sarga_1 = 40;
  cSotet_Sarga_2 = 20;
  cSzurke_1 = 42;
  cSzurke_2 = 21;
  cKek_1 = cSotet_Kek_1 + 128;
  cKek_2 = cSotet_Kek_2 + 64;
  cVoros_1 = cSotet_Voros_1 + 128;
  cVoros_2 = cSotet_Voros_2 + 64;
  cLila_1 = cSotet_Lila_1 + 128;
  cLila_2 = cSotet_Lila_2 + 64;
  cZold_1 = cSotet_Zold_1 + 128;
  cZold_2 = cSotet_Zold_2 + 64;
  cKekes_Zold_1 = cSotet_KekesZold_1 + 128;
  cKekes_Zold_2 = cSotet_KekesZold_2 + 64;
  cSarga_1 = cSotet_Sarga_1 + 128;
  cSarga_2 = cSotet_Sarga_2 + 64;
  cFeher_1 = cSzurke_1 + 128;
  cFeher_2 = cSzurke_2 + 64;


  function rgbToPixelValue(r,g,b : integer; pixelId : integer) : integer;


implementation

function rgbToPixelValue(r,g,b : integer; pixelId : integer) : integer;
//r,g,b értékekből kiszámítja a pixelID -hoz tartozó értéket
begin

  if (r = 0) and (g = 0) and (b = 0) then Result := cFekete;

  if (r = 0) and (g = 0) and (b = 145) and (pixelId = 1) then Result := cSotet_Kek_1;
  if (r = 0) and (g = 0) and (b = 145) and (pixelId = 2) then Result := cSotet_Kek_2;

  if (r = 145) and (g = 0) and (b = 0) and (pixelId = 1) then Result := cSotet_Voros_1;
  if (r = 145) and (g = 0) and (b = 0) and (pixelId = 2) then Result := cSotet_Voros_2;

  if (r = 145) and (g = 0) and (b = 145) and (pixelId = 1) then Result := cSotet_Lila_1;
  if (r = 145) and (g = 0) and (b = 145) and (pixelId = 2) then Result := cSotet_Lila_2;

  if (r = 0) and (g = 145) and (b = 0) and (pixelId = 1) then Result := cSotet_Zold_1;
  if (r = 0) and (g = 145) and (b = 0) and (pixelId = 2) then Result := cSotet_Zold_2;

  if (r = 0) and (g = 145) and (b = 145) and (pixelId = 1) then Result := cSotet_KekesZold_1;
  if (r = 0) and (g = 145) and (b = 145) and (pixelId = 2) then Result := cSotet_KekesZold_2;

  if (r = 145) and (g = 145) and (b = 0) and (pixelId = 1) then Result := cSotet_Sarga_1;
  if (r = 145) and (g = 145) and (b = 0) and (pixelId = 2) then Result := cSotet_Sarga_2;

  if (r = 145) and (g = 145) and (b = 145) and (pixelId = 1) then Result := cSzurke_1;
  if (r = 145) and (g = 145) and (b = 145) and (pixelId = 2) then Result := cSzurke_2;

  if (r = 0) and (g = 0) and (b = 255) and (pixelId = 1) then Result := cKek_1;
  if (r = 0) and (g = 0) and (b = 255) and (pixelId = 2) then Result := cKek_2;

  if (r = 255) and (g = 0) and (b = 0) and (pixelId = 1) then Result := cVoros_1;
  if (r = 255) and (g = 0) and (b = 0) and (pixelId = 2) then Result := cVoros_2;

  if (r = 255) and (g = 0) and (b = 255) and (pixelId = 1) then Result := cLila_1;
  if (r = 255) and (g = 0) and (b = 255) and (pixelId = 2) then Result := cLila_2;

  if (r = 0) and (g = 255) and (b = 0) and (pixelId = 1) then Result := cZold_1;
  if (r = 0) and (g = 255) and (b = 0) and (pixelId = 2) then Result := cZold_2;

  if (r = 0) and (g = 255) and (b = 255) and (pixelId = 1) then Result := cKekes_Zold_1;
  if (r = 0) and (g = 255) and (b = 255) and (pixelId = 2) then Result := cKekes_Zold_2;

  if (r = 255) and (g = 255) and (b = 0) and (pixelId = 1) then Result := cSarga_1;
  if (r = 255) and (g = 255) and (b = 0) and (pixelId = 2) then Result := cSarga_2;

  if (r = 255) and (g = 255) and (b = 255) and (pixelId = 1) then Result := cFeher_1;
  if (r = 255) and (g = 255) and (b = 255) and (pixelId = 2) then Result := cFeher_2;


end;

end.

