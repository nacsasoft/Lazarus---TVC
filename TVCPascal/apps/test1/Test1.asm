      ORG 6639                  ;{BASIC Header
      DEFB $0F,$0A,$0,$DD 	    ; "10 PRINT" - basic token
      DEFB ' USR' 			      ; " USR"
      DEFB $96 				          ; "("
      DEFB '6659'  			      ; "6659"
      DEFB $95,$FF,0,0,0,0,0 		; ")"
      jp    MAIN
_PLAYERUPDATE
      ld    a,(_SPRX_OLD)
      ld    (SPRITE_X),a
      ld    a,(_SPRY_OLD)
      ld    (SPRITE_Y),a
      ld    hl,SPRITE1
      ld    (SPRITE_DATA_ADDRESS),hl
      ld    a,1
      ld    (SPRITE_DRAW_MODE),a
      call  putsprite
      ld    a,(_SPRX_NEW)
      ld    (SPRITE_X),a
      ld    a,(_SPRY_NEW)
      ld    (SPRITE_Y),a
      ld    hl,SPRITE1
      ld    (SPRITE_DATA_ADDRESS),hl
      ld    a,1
      ld    (SPRITE_DRAW_MODE),a
      call  putsprite
      ret
_MUSICUPDATE
      call  sound_playing
      ld    a,l
      ld    (_BSOUNDPLAYING),a
      ld    de,0
      ex    de,hl
      and   a
      sbc   hl,de
      jp    nz,L0
L1
      ld    a,(_BKOTTAID)
      ld    l,a
      ld    h,0
      ld    de,2
      add   hl,de
      ld    a,l
      ld    (_BKOTTAID),a
      ld    de,56
      ex    de,hl
      and   a
      sbc   hl,de
      jp    nc,L3
L4
      ld    a,1
      ld    (_BKOTTAID),a
L3
L5
      ld    hl,_MUSIC+0
      ld    (addr_arrayword_index111),hl
      push  hl
      ld    a,(_BKOTTAID)
      ld    l,a
      ld    h,0
      dec   hl
      add   hl,hl
      pop   de
      add   hl,de
      ld    e,(hl)
      inc   hl
      ld    d,(hl)
      ex    de,hl
      ld    (SOUND_PITCH),hl
      ld    hl,(addr_arrayword_index111)
      push  hl
      ld    a,(_BKOTTAID)
      ld    l,a
      ld    h,0
      add   hl,hl
      pop   de
      add   hl,de
      ld    e,(hl)
      inc   hl
      ld    d,(hl)
      ex    de,hl
      ld    (SOUND_DURATION),hl
      call  sound_play
L0
L2
      ret
MAIN
      ld    hl,1
      call  graphics
      ld    a,(3)                   ; Aktualis lapozas kiolvasasa
      ld    (SAVED_MEM_PAGES),a     ; Aktualis memorialap eltarolasa
      ld    a,$50                   ; A video memoria belapozasa a $8000-$0BFFF teruletre (2.lap): U0, U1, VID, SYS
      ld    (P_SAVE),a              ; ertek beirasa a P_SAVE rendszervaltozoba
      out   (MEM_PAGES_PORT),a      ; es kikuldese a portra, hogy azonnal vegrehajtodjon
      ld    a,1
      ld    (_XLEPES),a
      ld    a,4
      ld    (_YLEPES),a
      ld    a,10
      ld    (_SPRX_NEW),a
      ld    a,100
      ld    (_SPRY_NEW),a
      ld    a,(_SPRX_NEW)
      ld    (_SPRX_OLD),a
      ld    a,(_SPRY_NEW)
      ld    (_SPRY_OLD),a
      ld    a,(_SPRX_OLD)
      ld    (SPRITE_X),a
      ld    a,(_SPRY_OLD)
      ld    (SPRITE_Y),a
      ld    hl,SPRITE1
      ld    (SPRITE_DATA_ADDRESS),hl
      xor   a
      ld    (SPRITE_DRAW_MODE),a
      call  putsprite
      ld    a,1
      ld    (PRINTAT_X),a
      ld    (PRINTAT_Y),a
      ld    hl,string_temp
      ld    (hl),0
      ld    de,_NEVEM
      call  add_string
      ld    hl,string_temp
      call  printat
      ld    a,10
      ld    (PRINTAT_X),a
      ld    (PRINTAT_Y),a
      ld    hl,string_temp
      ld    (hl),0
      ld    de,_NEVEM
      call  add_string
      ld    hl,string_temp
      call  printat
      ld    a,3
      ld    (PRINTAT_X),a
      ld    a,18
      ld    (PRINTAT_Y),a
      ld    hl,string_temp
      ld    (hl),0
      ld    de,_NEVEM
      call  add_string
      ld    hl,string_temp
      call  printat
      call  sound_stop
      ld    a,14
      ld    (SOUND_VOLUME),a
      call  sound_volume
      ld    hl,_MUSIC+0
      ld    (addr_arrayword_index111),hl
      push  hl
      ld    a,(_BKOTTAID)
      ld    l,a
      ld    h,0
      dec   hl
      add   hl,hl
      pop   de
      add   hl,de
      ld    e,(hl)
      inc   hl
      ld    d,(hl)
      ex    de,hl
      ld    (SOUND_PITCH),hl
      ld    hl,(addr_arrayword_index111)
      push  hl
      ld    a,(_BKOTTAID)
      ld    l,a
      ld    h,0
      add   hl,hl
      pop   de
      add   hl,de
      ld    e,(hl)
      inc   hl
      ld    d,(hl)
      ex    de,hl
      ld    (SOUND_DURATION),hl
      call  sound_play
L6
      ld    hl,1
      call  pause
      call  _MUSICUPDATE
      ld    hl,8
      ld	de,2897
      add	hl,de
      ld	l,(hl)
      ld	h,0
      ld    a,l
      ld    (_BBILLKOD),a
      ld    a,l
      ld    (LOGICAL_A),a
      ld    a,4
      ld    (LOGICAL_B),a
      call  andbyte
      ld    de,0
      ex    de,hl
      and   a
      sbc   hl,de
      jp    z,L9
      ld    a,(_SPRY_OLD)
      ld    l,a
      ld    h,0
      ld    a,(_YLEPES)
      ld    e,a
      ld    d,0
      add   hl,de
      ld    de,200
      ex    de,hl
      and   a
      sbc   hl,de
      jp    z,L9
      jp    c,L9
L10
      ld    a,(_SPRY_OLD)
      ld    l,a
      ld    h,0
      ld    a,(_YLEPES)
      ld    e,a
      ld    d,0
      add   hl,de
      ld    a,l
      ld    (_SPRY_NEW),a
      call  _PLAYERUPDATE
      ld    a,(_SPRY_NEW)
      ld    (_SPRY_OLD),a
L9
L11
      ld    a,(_BBILLKOD)
      ld    (LOGICAL_A),a
      ld    a,2
      ld    (LOGICAL_B),a
      call  andbyte
      ld    de,0
      ex    de,hl
      and   a
      sbc   hl,de
      jp    z,L12
      ld    a,(_SPRY_OLD)
      ld    l,a
      ld    h,0
      ld    a,(_YLEPES)
      ld    e,a
      ld    d,0
      and   a
      sbc   hl,de
      ld    de,1
      ex    de,hl
      and   a
      sbc   hl,de
      jp    z,L14
      jp    nc,L12
L14
L13
      ld    a,(_SPRY_OLD)
      ld    l,a
      ld    h,0
      ld    a,(_YLEPES)
      ld    e,a
      ld    d,0
      and   a
      sbc   hl,de
      ld    a,l
      ld    (_SPRY_NEW),a
      call  _PLAYERUPDATE
      ld    a,(_SPRY_NEW)
      ld    (_SPRY_OLD),a
L12
L15
      ld    a,(_BBILLKOD)
      ld    (LOGICAL_A),a
      ld    a,32
      ld    (LOGICAL_B),a
      call  andbyte
      ld    de,0
      ex    de,hl
      and   a
      sbc   hl,de
      jp    z,L16
      ld    a,(_SPRX_OLD)
      ld    l,a
      ld    h,0
      ld    a,(_XLEPES)
      ld    e,a
      ld    d,0
      add   hl,de
      ld    de,60
      ex    de,hl
      and   a
      sbc   hl,de
      jp    z,L16
      jp    c,L16
L17
      ld    a,(_SPRX_OLD)
      ld    l,a
      ld    h,0
      ld    a,(_XLEPES)
      ld    e,a
      ld    d,0
      add   hl,de
      ld    a,l
      ld    (_SPRX_NEW),a
      call  _PLAYERUPDATE
      ld    a,(_SPRX_NEW)
      ld    (_SPRX_OLD),a
L16
L18
      ld    a,(_BBILLKOD)
      ld    (LOGICAL_A),a
      ld    a,64
      ld    (LOGICAL_B),a
      call  andbyte
      ld    de,0
      ex    de,hl
      and   a
      sbc   hl,de
      jp    z,L19
      ld    a,(_XLEPES)
      ld    hl,_SPRX_OLD
      cp    (hl)
      jp    nc,L19
L20
      ld    a,(_SPRX_OLD)
      ld    l,a
      ld    h,0
      ld    a,(_XLEPES)
      ld    e,a
      ld    d,0
      and   a
      sbc   hl,de
      ld    a,l
      ld    (_SPRX_NEW),a
      call  _PLAYERUPDATE
      ld    a,(_SPRX_NEW)
      ld    (_SPRX_OLD),a
L19
L21
      ld    hl,113
      push  hl
      call  inkey
      pop   de
      and   a
      sbc   hl,de
      jp    nz,L8
      jp    L7
L8
      jp    L6
L7
      call  sound_stop
      call  get
      ld    a,l
      ld    (_BBILLKOD),a
      ld    a,(SAVED_MEM_PAGES)	    ; Bekapcsolaskori memoria konfiguraciot kiolvassuk a valtozonkbol, ahova elmentettuk
      ld    (3),a			              ; majd beirjuk a P_SAVE rendszervaltozoba
      out   (2),a			              ; es kikuldjuk a portra is, hogy azonnal vegrehajtodjon
      ld    hl,100
      ld    (PRINTPLOT_X),hl
      ld    hl,700
      ld    (PRINTPLOT_Y),hl
      ld    hl,_STR0
      call  printplot
      ret    ; Kilepes a programbol



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



; ***** Library Code ***** 

; Kurzor megszakitas atallitasa a sprite y koordinataja ala.
; input:  lsd: _sprite_vars 

set_cursor_it		LD A,(SPRITE_Y)		; A = SHIP_Y
			ADD A,10 		; par sort meg hozzaadunk
			LD L,A 			; L = SHIP_Y + par sor
			AND 3 			; 1-2. bit kivetelevel mindet toroljuk
			LD E,A 			; E regiszterbe elmentjuk
			LD A,L 			; A = (SPRITE_Y+par sor)
			SUB E 			; A = (SPRITE_Y+par sor)-((SPRITE_Y + par sor) mod 4)
			LD L,A 			; L = (SPRITE_Y+par sor)-((SPRITE_Y + par sor) mod 4)
			LD H,0 			; H = 0
			ADD HL,HL 		; HL = HL * 2
			ADD HL,HL 		; HL = HL * 4
			ADD HL,HL 		; HL = HL * 8
			ADD HL,HL 		; HL = HL * 16 -> HL=16 * HL
			INC HL 			; 1-el noveljuk a HL-t
			; cursor-megszakitas poziciojanak beallitasa
			DI 			; letiltjuk a megszakitasokat
			LD A,14
			OUT ($70),A 	; cursor-megszak.poz.felso byte reg.
			LD A,H
			OUT ($71),A 	; kiszamolt felso byte kikuldese
			LD A,15 
			OUT ($70),A 	; cursor-megszak.poz.also byte reg.
			LD A,L
			OUT ($70),A 	; kiszamolt also byte kikuldese
			; karaktersorban a kezdo- es befejezo TV sor beallitasa
			LD A,10
			OUT ($70),A 	; kezdo TV sort beallito regiszterenek kivalasztasa
			LD A,E 			; A = ((SPRITE_Y+SPRITE_HEIGHT) / 4) muvelet maradeka
			OUT ($71),A 	; kikuldjuk a portra
			LD A,11
			OUT ($70),A 	; befejezo TV sort beallito reg. kivalasztasa
			LD A,E 			; A = ((SPRITE_Y+SPRITE_HEIGHT) / 4) muvelet maradeka
			OUT ($71),A 	; ide is kikuldjuk ugyanazt
			EI 			; engedelyezzuk a megszakitasokat
			RET


; Sprite kirakasa felulirassal
; input:  lsd: _sprite_vars 

putsprite		call	set_cursor_it
			ld	hl,VRAM_START
			ld	a,(SPRITE_Y)
			cp	0
			jp	z,put_spr_Y_zero	; ha Y=0 akkor marad az alap VRAM kezdocim
			ld	bc,64
put_spr_sor_iter	add	hl,bc	
			dec	a
			jp	NZ,put_spr_sor_iter	; VRAM kezdocimhez hozzaadjuk a sor*64 -et
put_spr_Y_zero		ld	d,0
			ld	a,(SPRITE_X)
			ld	e,a
			add	hl,de			; x-pozicio is hozzaadva (megvan a sprite helye a vramban)
			ex	de,hl
			ld	hl,(SPRITE_DATA_ADDRESS)	; HL = a sprite-unk memoriacime
			ld	a,(hl)
			ld	(SPRITE_WIDTH),a
			inc	hl			; lepes a kovetkezo byte-ra 
			ld 	b,(hl) 			; b = a sprite magassaga pixelsorokban 
			ld 	ixl,b 			; ixl = b -> azaz a sprite magassaga 
			inc 	hl			; lepes a kovetkezo byte-ra 
			ld	a,(SPRITE_DRAW_MODE)	; kirajzolas modja?
			cp	1			; XOR ??
			jp	z,put_spr_draw_xor	; igen, maskepp kell kirajzolni!! Ugras...
put_spr_y_iter		ld 	bc,64 			; bc = 64 -> ennyi byte szeles a kepernyo 
			ld 	a,(SPRITE_WIDTH)	; a = a sprite szelessege byte-okban 
put_spr_x_iter		ldi 				; egy byte sprite kirakasa 
			dec 	a			; a = a - 1 
			jp 	nz,put_spr_x_iter	; ha a nem nulla, akkor folytatjuk 
			ex 	de,hl 			; de <=> hl csere 
			add 	hl,bc 			; hl = hl + bc 
			ex 	de,hl 			; de <=> hl csere vissza 
			dec 	ixl 			; ixl = ixl - 1 -> ennyi sort kell meg kirakni 
			jp 	nz,put_spr_y_iter	; ha ixl nem nulla, akkor meg vannak sorok			
			ret

; kirajzolas XOR-muvelettel...
; hl  = a sprite-unk memoriacime
; de  = kirajzolas pozicioja a vramban
; ixl = sprite magassaga
 	
put_spr_draw_xor	ld 	a,(SPRITE_WIDTH)	; a = sprite szelessege byte-okban
			ld	iyl,a			; elmentjuk kesobbre
			ld	a,64			; mivel itt mashogy leptetjuk a sorokat
			sub	iyl			; ezert b-be nem 64-et kell rakni hanem
			ld 	b,0 			; 64-SPRITE_WIDTH -t!!
			ld	c,a
put_spr_xor_x_iter	ld	a,(de)			; a-ba kerul a vram tartalma
			xor	(hl)			; xor muvelet elvegzese a sprite es a vram byte-ok kozott
			ld	(de),a			; xor eredmenye kiirasra kerul a vramba
			inc	hl
			inc	de
			dec	iyl
			jp	nz,put_spr_xor_x_iter
			ex 	de,hl 			; de <=> hl csere 
			add 	hl,bc 			; hl = hl + bc   (64-egy sor) 
			ex 	de,hl 			; de <=> hl csere vissza 
			dec 	ixl 			; ixl = ixl - 1 -> ennyi sort kell meg kirakni 
			jp 	nz,put_spr_draw_xor	; ha ixl nem nulla, akkor meg vannak sorok
			ret
			
			



; sound eljarasok:
; uj hang lejatszasanak elinditasa
; output: nincs
; input: SOUND_PITCH es SOUND_DURATION

sound_play	ld	hl,SOUND_PITCH			; hl = PITCH ertek
		ld	a,(hl) 				; A = PITCH also byte a kottabol 
		ld 	e,a 				; elrakjuk E regiszterbe 
		inc	hl
		ld 	a,(hl) 				; A = PITCH felso byte a kottabol 
		ld	d,a				; DE = PITCH 
		
		; hang kiadasa  
		ld	a,e 				; A = PITCH also 8 bitje
		out	(SOUND_PORT_LO),a 		; kikuldjuk a 4-es portra
		ld	a,(PORT_5_MEM_MIRROR) 		; A = 5-os port tukre
		and	128+64+32			; kinullazzuk az also 4 bitet
		or	16 				; Hangjel bit 1-esre allitasa
		or	d				; majd hozzaadjuk a PITCH felso 4 bitjet
		ld	(PORT_5_MEM_MIRROR),a 		; visszairjuk a rendszervaltozoba
		out	(SOUND_PORT_HI),a		; es kikuldjuk az 5-os portra
		ret					 


; hang lejatszas figyelese
;output: hl=1 ha a hang szol; hl=0 le lehet jatszani a kovetkezo hangot

sound_playing	;halt					; EGY SIMA DELAY(1) -EL KELL BEALLITANI A PROGIBAN!!!!!
		ld	hl,1				; hl=1 hanglejatszas folyamatban van!
		ld	de,(SOUND_DURATION)
		ld 	a,e				; A = hang kitartasbol hatralevo ido 
		or	a 				; a = 0?
		jp	nz,s_p_dur_dec			; meg nem nulla, ugras hangkitartasra 
		
		; hang lejatszassal vegeztunk
		dec	hl				; hl=0 (ha van kovetkezo akkor most johet)
		ret
				
		; hangkitartas idozitese 
s_p_dur_dec 	dec	a 				; SOUND_DURATION = SOUND_DURATION - 1 
		ld	d,0
		ld	e,a
		ld	(SOUND_DURATION),de		; elmentjuk a valtozoba (WORD!!!)
		ret		 

; hangero beallitasa

sound_volume		ld	a,(SOUND_VOLUME)
			sla	a
			sla	a
			ld	l,a
			ld	a,(PORT_6_MEM_MIRROR)
			and 	128+64+2+1
			or	l
			ld	(PORT_6_MEM_MIRROR),a
			out	(VOLUME_PORT),a
			ret

; hang kikapcsolasa

sound_stop		ld	a,(PORT_5_MEM_MIRROR) 		; A = 5-os port tukre 
			and 	128+64 				; toroljuk a "HANGJEL" bitet 
			ld	(PORT_5_MEM_MIRROR),a 		; visszairjuk a rendszervaltozoba 
			out	(SOUND_PORT_HI),a 		; majd kikuldjuk a portra
			xor	a
			ld	(SOUND_DURATION),a		; nullazni kell mert a SoundPlaying ezt nezi
			ret


; AND logikai vizsgalat LOGICAL_A es LOGICAL_B kozott, eredmeny = hl
; input: LOGICAL_A es LOGICAL_B byte tipusu valtozok
; output: hl a vizsgalat eredmenye

andbyte			ld	hl,(LOGICAL_A)
                        ld	a,l
                        and	h
                        ld	h,0
                        ld	l,a
                        ret 


; Billentyuzet allapot leolvasasa, ha nyomtak le vmit akkor visszaadja a kodjat.

inkey			ld	hl,0
			rst	$30
			db	$93
			ld	a,c			; c=255 ha van karakter amit be lehet olvasni
			cp	0
			ret	z			; nincs beolvashato karakter, kilepes
			rst	$30			
			db	$91			; lenyomott billentyu leolvasasa
			ld	l,c
			ld	h,0
			ret
			
			


; Varakozas amig le nem nyomunk egy gombot majd visszaadja a lenyomott billentyu kodjat.

get			rst	$30
			db	$91
			ld	l,c
			ld	h,0
			ret



; Szoveg vagy string kiirasa az adott karakter pozicioba.
; input: printat_x : (1-64, 32, 16), printat_y : (1-24), hl = string (hossz,karakterek)
; output: nincs

printat			ld	a,(PRINTAT_X)
			ld	b,a
			ld	a,(PRINTAT_Y)
			ld	c,a
			rst	$30
			db	$23
			ld	b,0
			ld	c,(hl)
			inc	hl			
			ld	d,h
			ld	e,l
			rst	$30
			db	$22
			ret



; Szoveg vagy string kiirasa az adott rajzolasi pozicioba.
; input: printplot_x : (0-1023), printplot_y : (0-959), hl = string (hossz,karakterek)
; output: nincs

printplot		ld	bc,(PRINTPLOT_X)
			ld	de,(PRINTPLOT_Y)
			rst	$30
			db	6
			ld	b,0
			ld	c,(hl)
			inc	hl
			ld	d,h
			ld	e,l
			rst	$30
			db	2
			ret



; Grafikus mod beallitasa
; input: l = felbontas (0=2-es, 1=4-es, 2=16-os)
; output: nincs

graphics		ld c,l
			rst $30
			db 4
			ret




; szunet 50 = 1 masodperces kesleltetes!
; input: hl = masodperc 1/50 intervallumok szama
; output: nem

pause			halt
			dec	hl
			ld	a,h
			or	l
			jr	nz,pause
			ret



; Stringek osszefuzese
; input: hl = a hol sor cime, de = a ahol sor cime
; output: nem

add_string			ld	a,(de)		; szoveg1 hossza
				and	a		; ha = 0 akkor kilepes
				ret	z

				push	de		; szoveg1 cim elmentese (elso byte = hossz)

				ld	e,(hl)		; szoveg2 hossza
				ld	d,0
				ld	c,a		; c = szoveg1 hossza ennyit kell masolni
				ld	b,0
				add	a,e		; a = szoveg1 + szoveg2
				ld	(hl),a		; szoveg2 hossza = ket szoveg hossza egyutt

				inc	hl		; szoveg2 kezdocimenek novelese mert az elso byte a hosszt mutatja
				add	hl,de		; hl = szoveg2 cim + szoveg2 hossz
				ex	de,hl

				pop	hl		; hl = szoveg1 cim (elso byte = hossz)
				inc	hl		; hl novelese hogy a szoveg1 szovegere mutasson

				ldir			; hl --> de -be es bc-1 amig bc=0

				ret



string_temp			defb	0					; kozbenso karakterlanc valtoza
				defs	255,32


addr_arraybyte_index		defw	0					; cella cime egy tomb tipusban - arraybyte
addr_arrayword_index		defw	0					; cella cime egy tomb tipusban - arrayword
addr_arraystring_index		defw	0					; cella cime egy tomb tipusban - arraystring
addr_arraystring_index_2	defw	0					; cella cime egy tomb tipusban - arraystring kiosztaskor
addr_arraybyte_index111		defw	0					; cella cime egy tomb tipusban - arraybyte kiosztaskor
addr_arrayword_index111		defw	0					; cella cime egy tomb tipusban - arrayword kiosztaskor






; szokoz es numerikus ascii kezdet

s_sp             equ     32
s__0             equ     48



; atmeneti tarolasra

PRINTPLOT_X			defw	0
PRINTPLOT_Y			defw	0


; atmeneti tarolasra

PRINTAT_X			defb	0
PRINTAT_Y			defb	0



; hanggal kapcsolatos valtozok, konstansok

SOUND_VOLUME		defb	0		; hangero	0-15
SOUND_PITCH		defw	0		; hangmagassag	0-4095
SOUND_DURATION		defw	0		; kesleltetes	1/50sec (WORD KELL!!!)
SOUND_PORT_LO		EQU 	4 		; 0-7.bitek: sound PITCH also 8 bit 
SOUND_PORT_HI 		EQU 	5 		; 0-3.bitek: sound PITCH felso 4 bit 
VOLUME_PORT 		EQU 	6 		; 2-5.bitek: sound VOLUME portja 
PORT_5_MEM_MIRROR 	EQU 	2834 		; az 5-os port tukorkepe a memoriaban 
PORT_6_MEM_MIRROR 	EQU 	2835 		; a 6-os port tukorkepe a memoriaban



P_SAVE              		EQU     3                           		; memoria lapozas memoria tukre
MEM_PAGES_PORT      		EQU     2                           		; memoria lapozas beallitas portja
SAVED_MEM_PAGES			db	0					; Bekapcsolaskori memorialapozas
VRAM_START			EQU	$8000		; videomemoria kezdocime : 32768


; AndByte, OrByte, XorByte valtozoi

LOGICAL_A		defb	0
LOGICAL_B		defb	0


; sprite koordinatak, felulirasi mod (0=feluliras, 1=and, 2=or, 3=xor)

SPRITE_X		defb	0
SPRITE_Y		defb	0
SPRITE_WIDTH		defb	0
SPRITE_HEIGHT		defb	0
SPRITE_DRAW_MODE	defb	0
SPRITE_DATA_ADDRESS	defw	0	; itt kezdodnek a sprite adatok (szel, magassag, dat1, dat2, dat3, ....)
SPRITE_SP_SAVE		db	0	; ide mentjuk el SP-t az XOR kirakasnal

; ***** Library Ends *****

; Variable Area
_MYRANDBYTE	defb	0
_I	defb	0
_J	defb	0
_BBILLKOD	defb	0
_MYRANDWORD	defw	0
_NEVEM	defb	9
	defb	78,97,67,115,65,115,79,102,84
_BB	defb	112
_XPOS	defw	0
_NAGYSZAM	defw	0
_KISSZAM	defb	0
_CHARKEYID	defb	128
_BKILEPKARAKTER	defb	13
_X	defw	0
_Y	defw	0
_LEPES	defb	0
_BSOUNDPLAYING	defb	0
_WDURATION	defw	1
_BKOTTAID	defb	1
_MUSIC
	defw	3349
	defw	10
	defw	3503
	defw	10
	defw	3349
	defw	10
	defw	3503
	defw	10
	defw	3598
	defw	20
	defw	4095
	defw	1
	defw	3598
	defw	20
	defw	3349
	defw	10
	defw	3503
	defw	10
	defw	3349
	defw	10
	defw	3503
	defw	10
	defw	3598
	defw	20
	defw	4095
	defw	1
	defw	3598
	defw	20
	defw	3723
	defw	10
	defw	3701
	defw	10
	defw	3652
	defw	10
	defw	3598
	defw	10
	defw	3537
	defw	20
	defw	3652
	defw	20
	defw	3598
	defw	10
	defw	3537
	defw	10
	defw	3503
	defw	10
	defw	3431
	defw	10
	defw	3349
	defw	20
	defw	4095
	defw	1
	defw	3349
	defw	20
	defw	4095
	defw	40
_SPRX_NEW	defb	0
_SPRY_NEW	defb	0
_SPRX_OLD	defb	0
_SPRY_OLD	defb	0
_XLEPES	defb	0
_YLEPES	defb	0

; String constants
_STR0	defb	1
	defb	32
