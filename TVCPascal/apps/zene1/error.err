program zene1;

const
	cMusicMax = 56;
	cMusic2Max = 16;

var
	music : array[1..56] of word = [3349,10,3503,10,3349,10,3503,10,3598,20,4095,1,3598,20,
		3349,10,3503,10,3349,10,3503,10,3598,20,4095,1,3598,20, 
		3723,10,3701,10,3652,10,3598,10,3537,20,3652,20, 
		3598,10,3537,10,3503,10,3431,10,3349,20,4095,1,3349,20,4095,40];
		
	music2 : array[1..16] of word = [3500,1,3000,1,2500,1,2000,1,1500,1,1000,1,500,1,1,1];
		
	bKottaID : byte = 1;
	i,bBillKod, bSoundPlaying : byte;


begin

	Cls;
	SoundInit;
	SoundVolume(14);
	SoundPlay(music2[bKottaID], music2[bKottaID + 1]);	{Lejátszás elindítása}
	
	repeat
		bSoundPlaying := SoundPlaying;
		if (bSoundPlaying = 0) then
		begin
			bKottaID := bKottaID + 2;
			if (bKottaID > cMusic2Max) then bKottaID := 1;
			SoundPlay(music2[bKottaID], music2[bKottaID + 1]);
		end;
		
		bBillKod := GetKeyMatrixState(7);		{billentyűzet mátrix 7. sorának lekérdezése!!}
	until	AndByte(bBillKod, 32) <> 0;			{SPACE-re kilépés}
	
	SoundStop;
end.
