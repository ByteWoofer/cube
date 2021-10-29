
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

init proc					; plant mines, set player position to 1,1,1
mov [minefield], 0			; clear the minefield
mov eax, 0					; set loop count to zero

initloop:
push eax					; push loop count on stack

failloop:

							;;; get new position for mine
mov edx, 0					; set upper 32 bits of dividend to zero
call rand					; put random value into eax
mov ebx, 24					; set divisor to 24
div ebx						; divide to get remainder

							;;; convert position to format for minefield
mov eax, 1					; add one to remainder so it can't be at player start
mov ecx, edx				; move into cl (lower half of ecx)
add ecx, 1					; set single bit to shift
shl eax, cl					; shift (This is equivalent to 2^cl)

and eax, [minefield]		; check for mine
cmp eax, 0					; 0 if no mine
jnz failloop				; restart if mine exists

add eax, 1					; set single bit to shift
shl eax, cl					; recalculate mine value
or [minefield], eax			; add mine to field

pop eax						; get back loop count
add eax, 1					; add one to loop count
cmp eax, 5					; check if we have added 5 mines
jnz initloop				; continue loop if not
mov position, 0				; set player position to 1,1,1
ret
init endp

checkValid proc				; check movement input is valid
mov eax, 0
ret
checkValid endp

checkMine proc				; check if mine at position
mov ecx, [position]
mov eax, 1
shl eax, cl
and eax, [minefield]
ret
checkMine endp

checkWin proc				; check if position in winning position
cmp [position], 26
jz setWin
mov eax, 0
ret
setWin:
mov eax, 1
ret
checkWin endp

win proc					; Player wins the round
mov eax, [money]
add eax, wager 
add eax, wager
mov money, eax				; double wagered money and add to money

push money
push offset winMsg
call printf					; display win message
add esp,8

ret
win endp

lose proc					; Player loses the round
push offset bangMsg	
call printf					; Display bang message
add esp,4

push money
push offset loseMsg			; Display lose message
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


call checkValid				; Check move is valid
cmp eax,0
jnz lose

call convertPos
mov [position], eax			; store player position

call checkMine				; Check if there's a mine
cmp eax,0
jnz lose

call checkWin				; Check if they're on 3,3,3
cmp eax,0
jnz win

jmp play					; Continue game if no conditions met
play endp

game proc					; handle prompting and setting up rounds/wagers
call askwager
call init
call play
ret
game endp

convertPos proc				; convert input position to a single value, return in eax
							; pos = (x-1)+3(y-1)+9(z-1)
push ebx					; store state
push ecx

mov eax, responsePos+8		; load Z into eax
sub eax, 1					
mov ebx, 9
mul ebx
mov ecx, eax				; store result in ecx

mov eax, responsePos+4		; load Y into eax
sub eax, 1
mov ebx, 3
mul ebx

add eax, ecx				
add eax, responsePos		; add X to result
sub eax, 1					; subtract 1 for x

pop ecx						; restore state
pop ebx

ret
convertPos endp

end