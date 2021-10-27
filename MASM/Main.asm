
.386						; enables assembly of nonpriviledged instructions for 80386 processor
.model flat,c			; Flat Memory Model, C conventions
.stack 1000h			; Create stack size in bytes

.data
;variables
money		dd		500
wager		dd		0
position	dd		0
responsePos	dd		0,0,0
response	dd		0
minefield	dd		0

;prompts
infoQry		db		"Do you want to see the instructions? (yes--1,no--0)",10,"? ",0
info		db		"This is a game...",10,0
moneyMsg	db		"You have $%d.",10,0
wagerMsg	db		"Want to make a wager?",10,"? ",0
wagerAmt	db		"How much: ",0
wagerNo		db		"How boring...",10,0
remainMsg	db		"You wager $%d.",10,"You have $%d left.",10,0
greedyMsg	db		"You're all in! at %d",0
moveMsg		db		"It's your move",10,"? ",0
bangMsg		db		"****BANG****",10,"you lose",10,0
takePos		db		"%u,%u,%u",0
takePrmpt	db		"%u",0
loseMsg		db		"You have %d dollars!",10,"Do you want to try again?",10,"? ",0 ;push money
winMsg		db		"Congrats, you have %d dollars!",10,"Do you want to try again?",10,"? ",0 ;push money (Could optimize by 
goodMsg		db 		"Congrats, you made money!",0
badMsg		db		"Tough luck",0
byeMsg		db		"Goodbye",0

.code
; informing the linker that the current module should be linked w/ these libraries
includelib libcmt.lib
includelib libvcruntime.lib
includelib libucrt.lib
includelib legacy_stdio_definitions.lib

; external linkages, these are symbols to functions/procedures in another library/module/object (Libraries included above)
extrn scanf:near
extrn printf:near
extrn exit:near
extrn rand:near

public main
main proc
push offset infoQry
call printf
push offset response
push offset takePrmpt
call scanf
cmp	 response, 0
jz skip_info
push offset info
call printf
skip_info:
call game
push offset response
push offset takePrmpt
call scanf
add esp, 8
cmp response, 0
jnz skip_info
call exit
main endp

askwager proc
setwager:
push offset wagerMsg		; Ask if they would like to make a wager
call printf
add esp, 4

push offset response		; Read response
push offset takePrmpt
call scanf
add esp, 8

cmp response, 0				; Skip setting wager if they don't want it
jz skip_wager

push money					; anounce remaining money
push offset moneyMsg
call printf
add esp, 8

push offset wagerAmt		; ask for wager amount
call printf
add esp, 4

push offset wager			; read wager amount
push offset takePrmpt
call scanf
add esp, 8

mov eax, money				; load current money into register
sub eax, [wager]			; subtract the value at address wager from register holding money
mov money, eax				; write result back to address of money

push money					; announce remaining money
push wager
push offset remainMsg
call printf
add esp, 12
ret

skip_wager:					; clear wager if not set
mov wager, 0
ret
askwager endp

init proc					; plant mines, set player position to 0,0,0
mov minefield, 0
mov position, 0
ret
init endp

checkValid proc				; check movement input is valid
mov eax, 0
ret
checkValid endp

checkMine proc				; check if mine at position
mov eax, 0
ret
checkMine endp

checkWin proc				; check if position in winning position
mov eax, 0
ret
checkWin endp

win proc
mov eax, [money]
add eax, wager 
add eax, wager
mov money, eax
push money
push offset winMsg
call printf
add esp,8
ret
win endp

lose proc
push offset bangMsg
call printf
add esp,4

push money
push offset loseMsg
call printf
add esp,8
ret
lose endp

play proc					; loop through movement till win/loss

push offset moveMsg			; prompt move
call printf
add esp, 4

push offset responsePos+8	; read move
push offset responsePos+4
push offset responsePos
push offset takePos
call scanf
add esp, 4*4
call checkValid
cmp responsePos,0
jnz lose
call checkMine
cmp responsePos+4,0
jnz lose
call checkWin
cmp responsePos+8,0
jnz win
jmp play
ret
play endp

game proc
call askwager
call init
call play
ret
game endp

end