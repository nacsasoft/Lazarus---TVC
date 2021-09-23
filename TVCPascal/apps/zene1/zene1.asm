      ORG 6639                  ;{BASIC Header
      DEFB $0F,$0A,$0,$DD 	    ; "10 PRINT" - basic token
      DEFB ' USR' 			      ; " USR"
      DEFB $96 				          ; "("
      DEFB '6659'  			      ; "6659"
      DEFB $95,$FF,0,0,0,0,0 		; ")"
MAIN
      rst	$30
      db	5
      call  sound_stop
      ld    a,14
      ld    (SOUND_VOLUME),a
      call  sound_volume
      ld    hl,_MUSIC2+0
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
      call  sound_playing
      ld    a,l
      ld    (_BSOUNDPLAYING),a
      ld    de,0
      ex    de,hl
      and   a
      sbc   hl,de
      jp    nz,L3
L4
      ld    a,(_BKOTTAID)
      ld    l,a
      ld    h,0
      ld    de,2
      add   hl,de
      ld    a,l
      ld    (_BKOTTAID),a
      ld    de,16
      ex    de,hl
      and   a
      sbc   hl,de
      jp    nc,L6
L7
      ld    a,1
      ld    (_BKOTTAID),a
L6
L8
      ld    hl,_MUSIC2+0
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
L3
L5
      ld    hl,7
      ld	de,2897
      add	hl,de
      ld	l,(hl)
      ld	h,0
      ld    a,l
      ld    (_BBILLKOD),a
      ld    a,l
      ld    (LOGICAL_A),a
      ld    a,32
      ld    (LOGICAL_B),a
      call  andbyte
      ld    de,0
      ex    de,hl
      and   a
      sbc   hl,de
      jp    z,L2
      jp    L1
L2
      jp    L0
L1
      call  sound_stop
      ret    ; Kilepes a programbol


; ***** Library Code ***** 

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

addr_arraybyte_index		defw	0					; cella cime egy tomb tipusban - arraybyte
addr_arrayword_index		defw	0					; cella cime egy tomb tipusban - arrayword
addr_arraystring_index		defw	0					; cella cime egy tomb tipusban - arraystring
addr_arraystring_index_2	defw	0					; cella cime egy tomb tipusban - arraystring kiosztaskor
addr_arraybyte_index111		defw	0					; cella cime egy tomb tipusban - arraybyte kiosztaskor
addr_arrayword_index111		defw	0					; cella cime egy tomb tipusban - arrayword kiosztaskor



; hanggal kapcsolatos valtozok, konstansok

SOUND_VOLUME		defb	0		; hangero	0-15
SOUND_PITCH		defw	0		; hangmagassag	0-4095
SOUND_DURATION		defw	0		; kesleltetes	1/50sec (WORD KELL!!!)
SOUND_PORT_LO		EQU 	4 		; 0-7.bitek: sound PITCH also 8 bit 
SOUND_PORT_HI 		EQU 	5 		; 0-3.bitek: sound PITCH felso 4 bit 
VOLUME_PORT 		EQU 	6 		; 2-5.bitek: sound VOLUME portja 
PORT_5_MEM_MIRROR 	EQU 	2834 		; az 5-os port tukorkepe a memoriaban 
PORT_6_MEM_MIRROR 	EQU 	2835 		; a 6-os port tukorkepe a memoriaban



; AndByte, OrByte, XorByte valtozoi

LOGICAL_A		defb	0
LOGICAL_B		defb	0


; ***** Library Ends *****

; Variable Area
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
_MUSIC2
	defw	3500
	defw	1
	defw	3000
	defw	1
	defw	2500
	defw	1
	defw	2000
	defw	1
	defw	1500
	defw	1
	defw	1000
	defw	1
	defw	500
	defw	1
	defw	1
	defw	1
_BKOTTAID	defb	1
_I	defb	0
_BBILLKOD	defb	0
_BSOUNDPLAYING	defb	0

; String constants
