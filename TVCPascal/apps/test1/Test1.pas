program Test1;

const
    {aa = 120;
    ii = 210;}
    
    cMyCharId = 223;
    
    cKilepKarakter = 113;	{q -ascii kódja}
    {cMemoriaCim = 42123;	egy pont a videoban....}
    
    cMusicMax = 56;
  
    



var
	myRandByte,i,j, bBillKod : byte;
	myRandWord : word;
	{nev : array[1..4] of string[2] = ['A1','B2','C3','D4'];}
	nevem : string[9] = 'NaCsAsOfT';
	{arr_ta : array[1..10, 1..10] of byte;}
	bb : byte = 112;
	xpos : word = 0;
	nagyszam : word = 0;
	kisszam : byte;
	{arrBorder_color : array[1..16] of byte = [$0,$2,$8,$A,$20,$22,$28,$2A,$80,$82,$88,$8A,$A0,$A2,$A8,$AA];}
    
	{charKey : array[1..10] of byte = [255,195,195,255,24,24,24,30,30,16];	sajat kulcs karakter...}
	{charIze : array[1..10] of byte = [255,255,195,195,195,195,195,195,255,255];	{sajat karakter...}
	charKeyId : byte = 128;

	bKilepKarakter : byte = 13;

	{arrInputText : string[5];	max 5 karaktert fogunk bekérni}

	{arrPoke : array[1..64] of byte;}

	x, y : word;	{kulcs koordinátái}
	lepes : byte;


	bSoundPlaying : byte;
	wDuration : word = 1;
	bKottaID : byte = 1;
	
	music : array[1..56] of word = [3349,10,3503,10,3349,10,3503,10,3598,20,4095,1,3598,20,
		3349,10,3503,10,3349,10,3503,10,3598,20,4095,1,3598,20, 
		3723,10,3701,10,3652,10,3598,10,3537,20,3652,20, 
		3598,10,3537,10,3503,10,3431,10,3349,20,4095,1,3349,20,4095,40];  
		
	sprx_new, spry_new, sprx_old, spry_old, xlepes, ylepes : byte;
	  
    
procedure PlayerUpdate;
begin
	PutSprite(sprx_old, spry_old, sprite1, 1);
	PutSprite(sprx_new, spry_new, sprite1, 1);
end;

procedure MusicUpdate;
begin
	bSoundPlaying := SoundPlaying;
	if (bSoundPlaying = 0) then
	begin
		bKottaID := bKottaID + 2;
		if (bKottaID > cMusicMax) then bKottaID := 1;
		SoundPlay(music[bKottaID], music[bKottaID + 1]);
	end;
end;



BEGIN

	Graphics(4);
	VideoOn(0);		{	Videomemoria belapozasa (U0,U1,VID,SYS)			- OK}
	
	xlepes := 1;
	ylepes := 4;
	sprx_new := 10;
	spry_new := 100;
	sprx_old := sprx_new;
	spry_old := spry_new;
	
	PutSprite(sprx_old, spry_old, sprite1, 0);
	
	PrintAt(1,1,nevem);
	PrintAt(10,10,nevem);
	PrintAt(3,18,nevem);
	
	SoundInit;
	SoundVolume(14);
	SoundPlay(music[bKottaID], music[bKottaID + 1]);	{Lejátszás elindítása}
	
	repeat 
		Delay(1);	{20msec késleltetés - Kell a zene miatt is!!!}
		
		MusicUpdate;		
		
		bBillKod:=GetKeyMatrixState(8);		
		
		if AndByte(bBillKod, 4) <> 0 and (spry_old + ylepes) < 200 then
		begin
			spry_new := spry_old + ylepes;
			PlayerUpdate;
			spry_old := spry_new;
		end;
		
		if AndByte(bBillKod, 2) <> 0 and (spry_old - ylepes) >= 1 then
		begin
			spry_new := spry_old - ylepes;
			PlayerUpdate;
			spry_old := spry_new;
		end;
		
		if AndByte(bBillKod, 32) <> 0 and (sprx_old + xlepes) < 60 then
		begin
			sprx_new := sprx_old + xlepes;
			PlayerUpdate;
			sprx_old := sprx_new;
		end;
		
		if AndByte(bBillKod, 64) <> 0 and sprx_old > xlepes then
		begin
			sprx_new := sprx_old - xlepes;
			PlayerUpdate;
			sprx_old := sprx_new;
		end;
	
	until cKilepKarakter = Inkey;
	
	SoundStop;
	
	
	
	{---------------------------- SoundInit ; SoundVolume ; SoundPlaying ; SoundPlay ; SoundStop -------------------------------}
	{
	SoundInit;
	SoundVolume(12);
	 
	x:=300;
	y:=400;
	PrintPlot(x,y,'*');
	
	repeat 
		bBillKod:=GetKeyMatrixState(8);		
		bSoundPlaying := SoundPlaying;
		if (bSoundPlaying = 1) then begin
			PrintAt(1,1,'Sound ON  ');
			end
		else begin		
			PrintAt(1,1,'Sound OFF');
			SoundStop;
			end;
		
		if AndByte(bBillKod, 1) <> 0 then	
			lepes:=4
		else
			lepes:=2;
		
		if AndByte(bBillKod, 2) <> 0 and (y+lepes) < 950 then
		begin
			y:=y+lepes;
			SoundPlay(3500,wDuration);
		end;
		
		if AndByte(bBillKod, 4) <> 0 and (y-lepes) > 40 then
		begin
			y:=y-lepes;
			SoundPlay(3500,wDuration);
		end;
		
		if AndByte(bBillKod, 32) <> 0 and (x+lepes) < 980 then
		begin
			x:=x+lepes;
			SoundPlay(3500,wDuration);
		end;
		
		if AndByte(bBillKod, 64) <> 0 and x > lepes then
		begin
			x:=x-lepes;		
			SoundPlay(3500,wDuration);
		end;
		
		PrintPlot(x,y,'*');
	
	until cKilepKarakter = Inkey;
	
	SoundStop; }

	{osztás maradéka nagyszam=86}
	{nagyszam := 500;
	nagyszam := nagyszam % 138;	
	PrintAt(1,1,nagyszam);}
	
	
	{---------------------------------------------- Poke ; Peek ----------------------------------------------------}
	{nagyszam := 32768
	for i := 0 to 63 do Poke(nagyszam + i, RandomByte());
	for i := 0 to 63 do arrPoke[i+1] := Peek(i + nagyszam);
	for i := 0 to 63 do Poke(nagyszam + 40 * 64 + i, arrPoke[i+1]);  }
	{nagyszam := 32768;
	Poke(cMemoriaCim, cMyCharId);
	Poke(32768 + 5000, 222);
	Poke(40000,245);
	Poke(nagyszam,233);
	Poke(nagyszam + 16383 ,233);
	
	kisszam := Peek(cMemoriaCim);
	PrintAt(1,1,kisszam);}
	
	
	{SetKeyRepeatRate (1);		bill. várakozási idő: 25ms}
	
	
	{---------------------------------- SetMode ; LineStyle ; Plot ; PlotRect -----------------------------------------}
	{SetMode(0);			Vonal kereszteződési mód
	LineStyle(0);			
	SetInk(11);
	Plot(cMyCharId,0,1023,959);
	SetInk(15);
	Plot(0,959,charKey[4],0);
	SetInk(12);
	PlotRect(300,300,100,150);
	Fill(310,290,6);
	Plot(123,654,432,888);}
	
	
	{-----------------------------------  Get ; Inkey ; InputAtString ; InputAtNumber  ---------------------------------}
	{bBillKod := Get; 
	if bBillKod = cKilepKarakter then PrintAt(1,1,nevem);
	
	
	PrintAt(1,1,'Text here (max. 5 char):');
	InputAtString(25,1,arrInputText);
	
	PrintAt(1,2,'Please a word:');
	InputAtNumber(15,2,myRandWord);
			
	PrintAt(1,10, 'Quit: q');
	
	repeat until cKilepKarakter = Inkey();
	
	PrintAt(1,13,'Input char=');
	PrintAt(12,13, arrInputText);
	PrintAt(1,14,'Input word=');
	PrintAt(12,14, myRandWord); 	}
	
	{---------------------------------- SetChar ; PrintChar ; PrintPlotChar -----------------------------------------}
	{for i:=0 to 9 do SetChar(i+128, charKey);}		{10 db sajat karakter definialasa}
	{SetChar(cMyCharId, charIze);
	
	for i:=0 to 25 do PrintChar(i,15,charKeyId);
	
	For j:=0 to 24 do PrintPlotChar(j*40, 700, cMyCharId);}
	
	
	{SetChar(cc, charKey);
	SetChar(charKeyId+cc+cc, charIze);}
	

	{---------------------------------- RandomByte ; RandomWord -----------------------------------------}
	{j := 1;
	repeat
		myRandByte := RandomByte();
		myRandWord := RandomWord();
		
		PrintPlot(1,300,'Random Byte:');
		PrintPlot(400,300,'    ');
		PrintPlot(400,300,myRandByte);
		
		PrintPlot(1,200,'Random Word:');
		PrintPlot(400,200,'      ');
		PrintPlot(400,200,myRandWord);
		
		Delay(17);
		
		j := j+1;
	until j > 15;}
	
	{repeat}

		{Tömb feltöltése véletlenszámokkal :
		for i := 1 to 10 do
		begin
			arr_ta[i,3] := RandomByte();
		end;}

		{ asm(tvc_SetGraphics16);	INCLUDE teszt 						- OK}
		{Graphics(4);			Grafikus mód beállítása 2, 4, 16		 	- OK}
		{delay(100);			2 sec késleltetés 					- OK}

		{nev[2,2] := 255; 		Tömb értékadás						- OK}

		{Cls;			Kepernyotorles							- OK}

		{---------------------------------- PrintPlot -----------------------------------------}
		{PrintPlot(1, 50, 16380);
		{PrintPlot(1,150,nevem);
		{PrintPlot(1,200,bb);
		{PrintPlot(1,250,nevem + ' && HuNoR');
		{PrintPlot(1,300,'Random number : ');
		PrintPlot(450,300,myRand); }


		{---------------------------------- PrintAt -------------------------------------------}
		{for i := 1 to 10 do
		begin
			PrintAt(i, 1,arr_ta[i,3]);
		end;

		if myRand >= 6 then PrintAt(1,2,'Random number >= 6');
		if arr_ta[5,3] <=5 then
		begin
			PrintAt(1,3,'arr_ta[5,3] = ');
			PrintAt(15,3, arr_ta[5,3]);
		end;

		PrintAt(1,4,nev[2]);

		xpos := random(9);
		PrintAt(1,6,nevem + nevem + 'huj');
		nagyszam := 5555 * xpos;
		PrintAt(27,6,nagyszam);}

		{SetInk (j);}
		{SetPaper (j);}

		{PrintAt(1, j,nevem);}


		{j:=j+1;}

	{until j > 15;}


	{-------------------------SetInk - SetPaper - SetBorder - SetPalette ---------------------------------}

	{SetInk (15);
	SetPaper (1);
	Cls;
	Delay(15);

	for i := 1 to 100 do
	begin
		SetBorder (arrBorder_color[random(9)]);
		Delay(5);
	end;

	j := 80;
	SetPalette(j, j, 80, 84);
	SetInk(3);
	SetPaper(1);
	Cls;
	SetBorder(2);}
	
	bBillKod := Get;
	
	VideoOff;		{	Lapozás visszaállítása az elmentettre VideoOn()		- OK}
	
	{Graphics(4);}

	{PrintAt(2,14,'?');}
	PrintPlot(100,700,' ')

END.

; a sprite pixelei byte-okban (16x28 pixel = 4x28 byte) 
SPRITE1 db 4,28
	DB 48,0,0,192 
	DB 112,176,208,224 
	DB 112,240,240,224 
	DB 112,240,240,224 
	DB 48,48,192,192 
	DB 96,240,240,96 
	DB 112,240,240,224 
	DB 112,48,192,224 
	DB 48,48,192,192 
	DB 48,240,240,192
	DB 112,192,48,224 
	DB 112,224,112,224 
	DB 48,176,208,192 
	DB 16,192,48,128 
	DB 2,112,224,4 
	DB 7,56,193,12 
	DB 7,12,3,14 
	DB 15,15,15,15 
	DB 9,14,7,9 
	DB 120,15,15,225 
	DB 112,14,7,224 
	DB 1,15,15,8 
	DB 32,0,0,64 
	DB 48,240,240,192 
	DB 16,240,240,128 
	DB 0,224,112,0 
	DB 0,14,7,0 
	DB 3,14,7,12


