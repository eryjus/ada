--===================================================================================================================
-- scanner.ads
--
--  This file contains the a sample of the lexical components we need to be able to recognize and convert
--  into tokens.
--===================================================================================================================



--
-- -- These examples are from the Ada Specification
--    ---------------------------------------------
& ' ( ) * + , - . / : ; < = > |
=> .. ** := /= >= <= << >> <>

Count X Get_Symbol Ethelyn Marion
Snobol_4 X1 Page_Count Store_Next_Item
Πλάτων -- Plato
Чайковский -- Tchaikovsky
θ φ -- Angles


12   0   1E6     123_456     -- integer literals
12.0     0.0     0.456   3.14159_26 -- real literals


2#1111_1111# 16#FF# 016#0ff# -- integer literals of value 255
16#E#E1 2#1110_0000# -- integer literals of value 224
16#F.FF#E+2 2#1.1111_1111_1110#E11 -- real literals of value 4095.0



'A' '*' ''' ' ' 'L' 'Л' 'Λ' -- Various els.
'∞' 'א' -- Big numbers - infinity and aleph.


"Message of the day:"
""  -- a null string literal
" "  "A"  """"  -- three string literals of length 1
"Characters such as $, %, and } are allowed in string literals"
"Archimedes said ""Εύρηκα"""
"Volume of cylinder (πr2h) = "



abort
 else
 new
 return
abs
 elsif
 not
 reverse
abstract
 end
 null
select
accept
 entry
of
 separate
access
 exception
or
 some
aliased
 exit
others
 subtype
all
for
 out
 synchronized
and
function
 overriding
array
 tagged
at
 generic
 package
 task
goto
 pragma
 terminate
begin
private
 then
body
 if
procedure
 type
in
case
 protected
interface
 until
constant
is
 raise
 use
declare
 range
limited
 when
delay
 record
loop
 while
delta
 rem
with
digits
 mod
 renames
do
 requeue
 xor
