OPTION STRICT

DIM M_MEMORY#[0]
DIM M_ALLOCATED%[0]
VAR M_CAPACITY% = 0
VAR M_STACK_PTR% = 0
VAR M_BASE_PTR% = 0

VAR STACK_HEAP_COLLISION% = 1
VAR NO_FREE_MEMORY% = 2
VAR STACK_UNDERFLOW% = 3

DEF PANIC C%
 ? "panic: ";
 IF C% == 1 THEN
  ?"stack and heap collision during push"
 ELSEIF C% == 2 THEN
  ?"no free memory left"
 ELSEIF C% == 2 THEN
  ?"stack underflow"
 ELSE
  ?"unknown error code"
 ENDIF
 STOP
END

DEF MACHINE_DUMP
 VAR I%=0
 ?"stack: [";
 FOR I%=0TO M_STACK_PTR%-1
  ?M_MEMORY#[I%]; " ";
 NEXT
 FOR I%=M_STACK_PTR%TO M_CAPACITY%-1
  ?"  ";
 NEXT
 ?"]"?"heap: ["
 FOR I%=0TO M_STACK_PTR% 
  ?"  ";
 NEXT
 FOR I%=M_STACK_PTR%TO M_CAPACITY%-1
  ?M_MEMORY#[I%]; " ";
 NEXT
 ?"]"?"alloc: ["
 FOR I%=0TO M_CAPACITY%
  ?M_ALLOCATED%[I%]; " ";
 NEXT
 ?"]"
 VAR TOTAL%=0
 FOR I%=0TO M_CAPACITY%-1
  INC TOTAL%, M_ALLOCATED%[I%]
 NEXT
 ?"STACK SIZE    "; M_STACK_PTR%
 ?"TOTAL ALLOC'D "; TOTAL%
END

DEF MACHINE_PUSH N#
 IF M_ALLOCATED%[M_STACK_PTR%] THEN
  PANIC STACK_HEAP_COLLISION%
 ENDIF

 M_MEMORY#[M_STACK_PTR%] = N#
 INC M_STACK_PTR%
END

DEF MACHINE_POP#()
 IF M_STACK_PTR%==0THEN
  PANIC STACK_UNDERFLOW%
 ENDIF

 DEC M_STACK_PTR%
 VAR RESULT# = M_MEMORY#[M_STACK_PTR%]
 M_MEMORY#[M_STACK_PTR%] = 0
 RETURN RESULT#
END

DEF MACHINE_NEW GLOBAL_SCOPE_SIZE%, CAPACITY%
 M_CAPACITY% = CAPACITY%
 DIM NEW_MEMORY#[CAPACITY%]
 DIM NEW_ALLOCATED%[CAPACITY%]
 M_MEMORY# = NEW_MEMORY#
 M_ALLOCATED% = NEW_ALLOCATED%
 M_STACK_PTR% = 0
 FILL M_MEMORY#, 0
 FILL M_ALLOCATED%, 0
 M_BASE_PTR% = 0
END

DEF MACHINE_DROP
 ' this does nothing
END

DEF MACHINE_LOAD_BASE_PTR
 MACHINE_PUSH M_BASE_PTR%
END

DEF MACHINE_ESTABLISH_STACK_FRAME ARG_SIZE%, LOCAL_SCOPE_SIZE%
 DIM ARGS#[ARG_SIZE%]
 VAR I%=0
 FOR I%=ARG_SIZE%-1 TO 0 STEP -1
  ARGS#[I%] = MACHINE_POP#()
 NEXT
 MACHINE_LOAD_BASE_PTR
 M_BASE_PTR% = M_STACK_PTR%
 FOR I%=0TO LOCAL_SCOPE_SIZE%-1
  MACHINE_PUSH 0
 NEXT
 FOR I%=0TO ARG_SIZE%-1
  MACHINE_PUSH ARGS#[I%]
 NEXT
END

DEF MACHINE_END_STACK_FRAME RETURN_SIZE%, LOCAL_SCOPE_SIZE%
 DIM RETURN_VAL#[RETURN_SIZE%]
 VAR I%=0
 FOR I%=RETURN_SIZE%-1 TO 0 STEP -1
  RETURN_VAL#[I%] = MACHINE_POP#()
 NEXT
 FOR I%=0TO LOCAL_SCOPE_SIZE%-1
  VAR T#=MACHINE_POP#()
 NEXT
 M_BASE_PTR% = MACHINE_POP#()
 FOR I%=0TO RETURN_SIZE%-1
  MACHINE_PUSH RETURN_VAL#[I%]
 NEXT
END

DEF MACHINE_ALLOCATE
 VAR I%, SIZE%=MACHINE_POP#(), ADDR%=0, CONSECUTIVE_FREE_CELLS%=0
 FOR I%=M_CAPACITY%-1TO M_STACK_PTR%+1STEP -1
  IF NOT M_ALLOCATED%[I%] THEN INC CONSECUTIVE_FREE_CELLS% ELSE CONSECUTIVE_FREE_CELLS% = 0
  IF CONSECUTIVE_FREE_CELLS% == SIZE% THEN
   ADDR% = I%
   BREAK
  ENDIF
 NEXT

 IF ADDR% <= M_STACK_PTR% THEN PANIC NO_FREE_MEMORY%
 FOR I%=0TO SIZE%-1
  M_ALLOCATED%[ADDR%+I%] = TRUE
 NEXT
 MACHINE_PUSH ADDR%
 RETURN ADDR%
END

DEF MACHINE_FREE
 VAR I%, ADDR%=MACHINE_POP#(), SIZE%=MACHINE_POP#()
 FOR I%=0TO SIZE%-1
  M_ALLOCATED%[ADDR%+I%] = FALSE
  M_MEMORY#[ADDR%+I%] = 0
 NEXT
END

DEF MACHINE_STORE SIZE%
 VAR I%, ADDR%=MACHINE_POP#()
 FOR I%=SIZE%-1TO 0 STEP-1
  M_MEMORY#[ADDR%+I%] = MACHINE_POP#()
 NEXT
END

DEF MACHINE_LOAD SIZE%
 VAR I%, ADDR%=MACHINE_POP#()
 FOR I%=0TO SIZE%-1
  MACHINE_PUSH M_MEMORY#[ADDR%+I%]
 NEXT
END

DEF MACHINE_ADD
 MACHINE_PUSH MACHINE_POP#()+MACHINE_POP#()
END

DEF MACHINE_SUBTRACT
 VAR B# = MACHINE_POP#()
 VAR A# = MACHINE_POP#()
 MACHINE_PUSH A#-B#
END

DEF MACHINE_MULTIPLY
 MACHINE_PUSH MACHINE_POP#()*MACHINE_POP#()
END

DEF MACHINE_DIVIDE
 VAR B# = MACHINE_POP#()
 VAR A# = MACHINE_POP#()
 MACHINE_PUSH A#/B#
END

DEF MACHINE_SIGN
 VAR X# = MACHINE_POP#()
 IF X# >= 0 THEN MACHINE_PUSH 1 ELSE MACHINE_PUSH -1
END
