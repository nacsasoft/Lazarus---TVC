
TVC_SETGRAPHICS16
	LD C,2
	RST $30
	DB 4
	RST $30 			; $30-as rendszer rutin h�v�s
	DB $5 				; K�perny� t�rl�se param�terrel
	ret
