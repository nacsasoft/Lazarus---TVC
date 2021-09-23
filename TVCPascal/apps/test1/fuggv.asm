
TVC_SETGRAPHICS16
	LD C,2
	RST $30
	DB 4
	RST $30 			; $30-as rendszer rutin hívás
	DB $5 				; Képernyö törlése paraméterrel
	ret
