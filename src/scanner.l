/*=================================================================================================================*/
/* scanner.l -- This is the scanner for the Ada compiler                                                           */
/*                                                                                                                 */
/*        Copyright (c)  2019 -- Adam Clark                                                                        */
/*        Licensed under "THE BEER-WARE LICENSE"                                                                   */
/*        See License.md for details.                                                                              */
/*                                                                                                                 */
/* --------------------------------------------------------------------------------------------------------------- */
/*                                                                                                                 */
/*     Date      Tracker  Version  Pgmr  Description                                                               */
/*  -----------  -------  -------  ----  ------------------------------------------------------------------------- */
/*  2019-May-17  Initial   0.0.1   ADCL  Initial version                                                           */
/*                                                                                                                 */
/*=================================================================================================================*/


%{

#include <unicode/uchar.h>
#include <unicode/uclean.h>
#include <unicode/ustream.h>
#include "StringTables.h"
#include "tokens.h"

#include <iostream>

extern icu::UnicodeString stringVal;
extern UErrorCode uError;
extern int commentLength;
extern int idLength;
extern int idCount;


%}

/* The following are some very specific code points that are used directly in the scanner */
U0009       \x09
U000A       \x0a
U000B       \x0b
U000C       \x0c
U000D       \x0d
U0020       \x20
U0085       \xc2\x85
U00A0       \xc2\xa0
U1680       \xe1\x9a\x80
U2000       \xe2\x80\x80
U2001       \xe2\x80\x81
U2002       \xe2\x80\x82
U2003       \xe2\x80\x83
U2004       \xe2\x80\x84
U2005       \xe2\x80\x85
U2006       \xe2\x80\x86
U2007       \xe2\x80\x87
U2008       \xe2\x80\x88
U2009       \xe2\x80\x89
U200A       \xe2\x80\x8a
U2028       \xe2\x80\xa8
U2029       \xe2\x80\xa9
U202F       \xe2\x80\xaf
U205F       \xe2\x81\x9f
U3000       \xe3\x80\x80
UFEFF       \xef\xbb\xbf


/* General Unicode recognition */
ASC         [\x00-\x7f]
ASCN        [\x00-\t\v-\x7f]
U           [\x80-\xbf]
U2          [\xc2-\xdf]
U3          [\xe0-\xef]
U4          [\xf0-\xf4]

UANY        {ASC}|{U2}{U}|{U3}{U}{U}|{U4}{U}{U}{U}
UANYN       {ASCN}|{U2}{U}|{U3}{U}{U}|{U4}{U}{U}{U}
UONLY       {U2}{U}|{U3}{U}{U}|{U4}{U}{U}{U}


/* The following are consifered format_effectors and also qualify as EOL: 2.1 (16) and 2.2 (2) */
EOL         \n\r|\r\n|{U000A}|{U000B}|{U000C}|{U000D}|{U0085}|{U2028}|{U2029}


/* The following are considered white space */
WS1         {U0020}|{U0009}|{U00A0}|{U1680}|{U2000}|{U2001}|{U2002}|{U2003}|{U2004}
WS2         {U2005}|{U2006}|{U2007}|{U2008}|{U2009}|{U200A}|{U202F}|{U205F}|{U3000}
WS          {WS1}|{WS2}


/* The following starts a comment */
CMT         --


/* The following is used for defining numeric values */
BASE        0*(2|3|4|5|6|7|8|9|10|11|12|13|14|15|16)
DECIMAL     [0-9]((_)?[0-9])*
BASED_NBR   [0-9a-fA-F]((_)?[0-9a-fA-F])*
E           [eE]


%x          CMT
%x          STR
%x          STR_SKIP
%x          IDENT

%%


{WS}*                       {}
{CMT}                       { BEGIN CMT; commentLength = 2; yymore(); }
<CMT>{EOL}                  { yyless(commentLength); BEGIN INITIAL; }
<CMT>.                      { commentLength ++; yymore(); }
{UFEFF}                     { return (TOK_BOM); }
{EOL}                       { yylineno ++; }


 /* handle the keywords */
(?i:ABORT)                  { return (TOK_ABORT); }
(?i:ABS)                    { return (TOK_ABS); }
(?i:ABSTRACT)               { return (TOK_ABSTRACT); }
(?i:ACCEPT)                 { return (TOK_ACCEPT); }
(?i:ACCESS)                 { return (TOK_ACCESS); }
(?i:ALIASED)                { return (TOK_ALIASED); }
(?i:ALL)                    { return (TOK_ALL); }
(?i:AND)                    { return (TOK_AND); }
(?i:ARRAY)                  { return (TOK_ARRAY); }
(?i:AT)                     { return (TOK_AT); }
(?i:BEGIN)                  { return (TOK_BEGIN); }
(?i:BODY)                   { return (TOK_BODY); }
(?i:CASE)                   { return (TOK_CASE); }
(?i:CONSTANT)               { return (TOK_CONSTANT); }
(?i:DECLARE)                { return (TOK_DECLARE); }
(?i:DELAY)                  { return (TOK_DELAY); }
(?i:DELTA)                  { return (TOK_DELTA); }
(?i:DIGITS)                 { return (TOK_DIGITS); }
(?i:DO)                     { return (TOK_DO); }
(?i:ELSE)                   { return (TOK_ELSE); }
(?i:ELSIF)                  { return (TOK_ELSIF); }
(?i:END)                    { return (TOK_END); }
(?i:ENTRY)                  { return (TOK_ENTRY); }
(?i:EXCEPTION)              { return (TOK_EXCEPTION); }
(?i:EXIT)                   { return (TOK_EXIT); }
(?i:FOR)                    { return (TOK_FOR); }
(?i:FUNCTION)               { return (TOK_FUNCTION); }
(?i:GENERIC)                { return (TOK_GENERIC); }
(?i:GOTO)                   { return (TOK_GOTO); }
(?i:IF)                     { return (TOK_IF); }
(?i:IN)                     { return (TOK_IN); }
(?i:INTERFACE)              { return (TOK_INTERFACE); }
(?i:IS)                     { return (TOK_IS); }
(?i:LIMITED)                { return (TOK_LIMITED); }
(?i:LOOP)                   { return (TOK_LOOP); }
(?i:MOD)                    { return (TOK_MOD); }
(?i:NEW)                    { return (TOK_NEW); }
(?i:NOT)                    { return (TOK_NOT); }
(?i:NULL)                   { return (TOK_NULL); }
(?i:OF)                     { return (TOK_OF); }
(?i:OR)                     { return (TOK_OR); }
(?i:OTHERS)                 { return (TOK_OTHERS); }
(?i:OUT)                    { return (TOK_OUT); }
(?i:OVERRIDING)             { return (TOK_OVERRIDING); }
(?i:PACKAGE)                { return (TOK_PACKAGE); }
(?i:PRAGMA)                 { return (TOK_PRAGMA); }
(?i:PRIVATE)                { return (TOK_PRIVATE); }
(?i:PROCEDURE)              { return (TOK_PROCEUDRE); }
(?i:PROTECTED)              { return (TOK_PROTECTED); }
(?i:RAISE)                  { return (TOK_RAISE); }
(?i:RANGE)                  { return (TOK_RANGE); }
(?i:RECORD)                 { return (TOK_RECORD); }
(?i:REM)                    { return (TOK_REM); }
(?i:RENAMES)                { return (TOK_RENAMES); }
(?i:REQUEUE)                { return (TOK_REQUEUE); }
(?i:RETURN)                 { return (TOK_RETURN); }
(?i:REVERSE)                { return (TOK_REVERSE); }
(?i:SELECT)                 { return (TOK_SELECT); }
(?i:SEPARATE)               { return (TOK_SEPARATE); }
(?i:SOME)                   { return (TOK_SOME); }
(?i:SUBTYPE)                { return (TOK_SUBTYPE); }
(?i:SYNCHRONIZED)           { return (TOK_SYNCHRONIZED); }
(?i:TAGGED)                 { return (TOK_TAGGED); }
(?i:TASK)                   { return (TOK_TASK); }
(?i:TERMINATE)              { return (TOK_TERMINATE); }
(?i:THEN)                   { return (TOK_THEN); }
(?i:TYPE)                   { return (TOK_TYPE); }
(?i:UNTIL)                  { return (TOK_UNTIL); }
(?i:USE)                    { return (TOK_USE); }
(?i:WHEN)                   { return (TOK_WHEN); }
(?i:WHILE)                  { return (TOK_WHILE); }
(?i:WITH)                   { return (TOK_WITH); }
(?i:XOR)                    { return (TOK_XOR); }


 /* handle the individual characters */
[-&()*+,./;:<=>|']          { return yytext[0]; }


 /* handle the multi-character tokens */
=>                          { return TOK_ARROW; }
\.\.                        { return TOK_DOUBLE_DOT; }
\*\*                        { return TOK_DOUBLE_STAR; }
:=                          { return TOK_BECOMES; }
\/=                         { return TOK_NOT_EQUAL; }
>=                          { return TOK_GREATER_THAN_OR_EQUAL; }
\<=                         { return TOK_LESS_THAN_OR_EQUAL; }
\<\<                        { return TOK_LEFT_LABEL_BRACKET; }
>>                          { return TOK_RIGHT_LABEL_BRACKET; }
\<>                         { return TOK_BOX; }


 /* here we recognize numeric values */
{BASE}\#{BASED_NBR}(\.{BASED_NBR})?\#((({E}\+?{DECIMAL})|({E}-{DECIMAL})))? {
                                yylval.nbr = numberTable.add(icu::UnicodeString::fromUTF8(yytext));

                                if (U_SUCCESS(uError)) {
                                    return (yylval.nbr->GetType()==ada::NumberEntry::NBR_INT
                                            ?(TOK_INT_LIT)
                                            :(TOK_REAL_LIT));
                                } else {
                                    yylval.err = new icu::UnicodeString("ERROR: Unable to parse number");
                                    return (TOK_ERROR);
                                }
                            }

{DECIMAL}(\.{DECIMAL})?((({E}\+?{DECIMAL})|({E}-{DECIMAL})))? {
                                yylval.nbr = numberTable.add(icu::UnicodeString::fromUTF8(yytext));

                                if (U_SUCCESS(uError)) {
                                    return (yylval.nbr->GetType()==ada::NumberEntry::NBR_INT
                                            ?(TOK_INT_LIT)
                                            :(TOK_REAL_LIT));
                                } else {
                                    yylval.err = new icu::UnicodeString("ERROR: Unable to parse number");
                                    return (TOK_ERROR);
                                }
                            }


 /* here we recognize single characters -- must be a graphic character */
\'{UANYN}\'                 {
                                icu::UnicodeString temp = icu::UnicodeString::fromUTF8(yytext + 1);
                                icu::UnicodeString *val = new icu::UnicodeString(temp.tempSubString(1, 1));

                                if (U_SUCCESS(uError)) {
                                    yylval.character = val;
                                    return TOK_CHAR_LIT;
                                } else {
                                    yylval.err = new icu::UnicodeString("ERROR: Invalid Unicode Code Point");
                                    return TOK_ERROR;
                                }
                            }


 /* Here we recognize a string of characters -- yymore() is not used here because a string is */
 /* constructed independently */
\"                          { stringVal.truncate(0); BEGIN STR; }
<STR>{EOL}                  {
                                yylval.err = new icu::UnicodeString("ERROR: End of Line exists in a string");
                                yylineno ++;
                                return (TOK_ERROR);
                            }
<STR>\t                     {
                                yylval.err = new icu::UnicodeString("ERROR: Tab exists in a string");
                                return (TOK_ERROR);
                            }
<STR>\"\"                   {
                                stringVal = stringVal.append(icu::UnicodeString::fromUTF8("\""));

                                if (U_FAILURE(uError)) {
                                    BEGIN STR_SKIP;
                                }
                            }
<STR>\"                     {
                                yylval.str = stringTable.add(icu::UnicodeString(stringVal));
                                BEGIN INITIAL;

                                if (U_SUCCESS(uError)) {
                                    return (TOK_STRING_LIT);
                                } else {
                                    yylval.err = new icu::UnicodeString("ERROR: Invalid Unicode Code Point");
                                    return (TOK_ERROR);
                                }
                            }
<STR>{UANYN}                {
                                stringVal += icu::UnicodeString::fromUTF8(yytext);

                                if (U_FAILURE(uError)) {
                                    BEGIN STR_SKIP;
                                }
                            }
<STR_SKIP>(\"\"|{UANYN})    {}
<STR_SKIP>(\"|\t|{EOL})     {
                                yylval.err = new icu::UnicodeString("ERROR: Invalid String");
                                yylineno ++;
                                BEGIN INITIAL;
                                return (TOK_ERROR);
                            }

 /* finally take care of identifiers...  this is a little messy since the sheer volume */
 /* of allowed characters is significant.  To get around this, I am building logic into here to */
 /* determine if the first character is a valid identifier start and if it is, move off to a */
 /* more robust identifier recognition scheme. */
{UANY}                      {
                                UChar32 cp;
                                icu::UnicodeString(yytext).toUTF32(&cp, 1, uError);

                                if (u_charType(cp) == U_UPPERCASE_LETTER ||
                                        u_charType(cp) == U_LOWERCASE_LETTER ||
                                        u_charType(cp) == U_TITLECASE_LETTER||
                                        u_charType(cp) == U_MODIFIER_LETTER ||
                                        u_charType(cp) == U_OTHER_LETTER ||
                                        u_charType(cp) == U_LETTER_NUMBER) {
                                    BEGIN IDENT;
                                    idLength = yyleng;
                                    idCount = 1;
                                    yymore();
                                } else {
                                    yylval.err = new icu::UnicodeString("ERROR: Illegal Code Point");
                                    return (TOK_ERROR);
                                }
                            }

<IDENT>{UANY}               {
                                UChar32 cp;
                                icu::UnicodeString str(yytext);
                                cp = str.char32At(idCount);

                                if (u_charType(cp) == U_UPPERCASE_LETTER ||
                                        u_charType(cp) == U_LOWERCASE_LETTER ||
                                        u_charType(cp) == U_TITLECASE_LETTER||
                                        u_charType(cp) == U_MODIFIER_LETTER ||
                                        u_charType(cp) == U_OTHER_LETTER ||
                                        u_charType(cp) == U_LETTER_NUMBER ||
                                        u_charType(cp) == U_NON_SPACING_MARK ||
                                        u_charType(cp) == U_COMBINING_SPACING_MARK ||
                                        u_charType(cp) == U_DECIMAL_DIGIT_NUMBER ||
                                        u_charType(cp) == U_CONNECTOR_PUNCTUATION) {
                                    idLength = yyleng;
                                    idCount ++;
                                    yymore();
                                } else {
                                    yyless(idLength);
                                    BEGIN INITIAL;

                                    yylval.id = identTable.add(icu::UnicodeString(yytext));

                                    if (U_SUCCESS(uError)) {
                                        return (TOK_IDENT);
                                    } else  {
                                        yylval.err = new icu::UnicodeString("ERROR: Invalid Unicode Code Point");
                                        return (TOK_ERROR);
                                    }
                                }
                            }

%%

icu::UnicodeString stringVal;
UErrorCode uError = U_ZERO_ERROR;
int commentLength;
int idLength;
int idCount;


#ifdef SCANNER


//
// -- return 1 if there is no more input
//    ----------------------------------
int yywrap(void) { return 1; }


//
// -- The main entry point for the scanner
//    ------------------------------------
int main(int argc, char *argv[])
{
    if (argc > 1) {
        if (!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return (1);
        }
    }

    int rv;
    yylineno = 1;
    char buffer[1024];

    while ((rv = yylex())) {
        switch (rv) {
        case TOK_IDENT:
            yylval.id->GetKey().extract(buffer, 1024, NULL, uError);
            printf("%s (%d): identifier %s\n", argv[1], yylineno, buffer);
            break;

        case TOK_STRING_LIT:
            yylval.str->GetKey().extract(buffer, 1024, NULL, uError);
            printf("%s (%d): string literal \"%s\"\n", argv[1], yylineno, buffer);
            break;

        case TOK_CHAR_LIT:
            yylval.character->extract(buffer, 1024, NULL, uError);
            printf("%s (%d): character literal \"%s\"\n", argv[1], yylineno, buffer);
            break;

        case TOK_INT_LIT:
            printf("%s (%d): integer literal %lld\n", argv[1], yylineno, yylval.nbr->IntVal());
            break;

        case TOK_REAL_LIT:
            printf("%s (%d): real literal %g\n", argv[1], yylineno, yylval.nbr->RealVal());
            break;

        case TOK_BOM:
            printf("%s (%d): BOM found\n", argv[1], yylineno);
            break;

        case TOK_ARROW:
            printf("%s (%d): compound symbol =>\n", argv[1], yylineno);
            break;

        case TOK_DOUBLE_DOT:
            printf("%s (%d): compound symbol ..\n", argv[1], yylineno);
            break;

        case TOK_DOUBLE_STAR:
            printf("%s (%d): compound symbol **\n", argv[1], yylineno);
            break;

        case TOK_BECOMES:
            printf("%s (%d): compound symbol :=\n", argv[1], yylineno);
            break;

        case TOK_NOT_EQUAL:
            printf("%s (%d): compound symbol /=\n", argv[1], yylineno);
            break;

        case TOK_GREATER_THAN_OR_EQUAL:
            printf("%s (%d): compound symbol <=\n", argv[1], yylineno);
            break;

        case TOK_LESS_THAN_OR_EQUAL:
            printf("%s (%d): compound symbol >=\n", argv[1], yylineno);
            break;

        case TOK_LEFT_LABEL_BRACKET:
            printf("%s (%d): compound symbol <<\n", argv[1], yylineno);
            break;

        case TOK_RIGHT_LABEL_BRACKET:
            printf("%s (%d): compound symbol >>\n", argv[1], yylineno);
            break;

        case TOK_BOX:
            printf("%s (%d): compound symbol <>\n", argv[1], yylineno);
            break;

        case TOK_ABORT:
            printf("%s (%d): keyword ABORT\n", argv[1], yylineno);
            break;

        case TOK_ABS:
            printf("%s (%d): keyword ABS\n", argv[1], yylineno);
            break;

        case TOK_ABSTRACT:
            printf("%s (%d): keyword ABSTRACT\n", argv[1], yylineno);
            break;

        case TOK_ACCEPT:
            printf("%s (%d): keyword ACCEPT\n", argv[1], yylineno);
            break;

        case TOK_ACCESS:
            printf("%s (%d): keyword ACCESS\n", argv[1], yylineno);
            break;

        case TOK_ALIASED:
            printf("%s (%d): keyword ALIASED\n", argv[1], yylineno);
            break;

        case TOK_ALL:
            printf("%s (%d): keyword ALL\n", argv[1], yylineno);
            break;

        case TOK_AND:
            printf("%s (%d): keyword AND\n", argv[1], yylineno);
            break;

        case TOK_ARRAY:
            printf("%s (%d): keyword ARRAY\n", argv[1], yylineno);
            break;

        case TOK_AT:
            printf("%s (%d): keyword AT\n", argv[1], yylineno);
            break;

        case TOK_BEGIN:
            printf("%s (%d): keyword BEGIN\n", argv[1], yylineno);
            break;

        case TOK_BODY:
            printf("%s (%d): keyword BODY\n", argv[1], yylineno);
            break;

        case TOK_CASE:
            printf("%s (%d): keyword CASE\n", argv[1], yylineno);
            break;

        case TOK_CONSTANT:
            printf("%s (%d): keyword CONSTANT\n", argv[1], yylineno);
            break;

        case TOK_DECLARE:
            printf("%s (%d): keyword DECLARE\n", argv[1], yylineno);
            break;

        case TOK_DELAY:
            printf("%s (%d): keyword DELAY\n", argv[1], yylineno);
            break;

        case TOK_DELTA:
            printf("%s (%d): keyword DELTA\n", argv[1], yylineno);
            break;

        case TOK_DIGITS:
            printf("%s (%d): keyword DIGITS\n", argv[1], yylineno);
            break;

        case TOK_DO:
            printf("%s (%d): keyword DO\n", argv[1], yylineno);
            break;

        case TOK_ELSE:
            printf("%s (%d): keyword ELSE\n", argv[1], yylineno);
            break;

        case TOK_ELSIF:
            printf("%s (%d): keyword ELSIF\n", argv[1], yylineno);
            break;

        case TOK_END:
            printf("%s (%d): keyword END\n", argv[1], yylineno);
            break;

        case TOK_ENTRY:
            printf("%s (%d): keyword ENTRY\n", argv[1], yylineno);
            break;

        case TOK_EXCEPTION:
            printf("%s (%d): keyword EXCEPTION\n", argv[1], yylineno);
            break;

        case TOK_EXIT:
            printf("%s (%d): keyword EXIT\n", argv[1], yylineno);
            break;

        case TOK_FOR:
            printf("%s (%d): keyword FOR\n", argv[1], yylineno);
            break;

        case TOK_FUNCTION:
            printf("%s (%d): keyword FUNCTION\n", argv[1], yylineno);
            break;

        case TOK_GENERIC:
            printf("%s (%d): keyword GENERIC\n", argv[1], yylineno);
            break;

        case TOK_GOTO:
            printf("%s (%d): keyword GOTO\n", argv[1], yylineno);
            break;

        case TOK_IF:
            printf("%s (%d): keyword IF\n", argv[1], yylineno);
            break;

        case TOK_IN:
            printf("%s (%d): keyword IN\n", argv[1], yylineno);
            break;

        case TOK_INTERFACE:
            printf("%s (%d): keyword INTERFACE\n", argv[1], yylineno);
            break;

        case TOK_IS:
            printf("%s (%d): keyword IS\n", argv[1], yylineno);
            break;

        case TOK_LIMITED:
            printf("%s (%d): keyword LIMITED\n", argv[1], yylineno);
            break;

        case TOK_LOOP:
            printf("%s (%d): keyword LOOP\n", argv[1], yylineno);
            break;

        case TOK_MOD:
            printf("%s (%d): keyword MOD\n", argv[1], yylineno);
            break;

        case TOK_NEW:
            printf("%s (%d): keyword NEW\n", argv[1], yylineno);
            break;

        case TOK_NOT:
            printf("%s (%d): keyword NOT\n", argv[1], yylineno);
            break;

        case TOK_NULL:
            printf("%s (%d): keyword NULL\n", argv[1], yylineno);
            break;

        case TOK_OF:
            printf("%s (%d): keyword OF\n", argv[1], yylineno);
            break;

        case TOK_OR:
            printf("%s (%d): keyword OR\n", argv[1], yylineno);
            break;

        case TOK_OTHERS:
            printf("%s (%d): keyword OTHERS\n", argv[1], yylineno);
            break;

        case TOK_OUT:
            printf("%s (%d): keyword OUT\n", argv[1], yylineno);
            break;

        case TOK_OVERRIDING:
            printf("%s (%d): keyword OVERRIDING\n", argv[1], yylineno);
            break;

        case TOK_PACKAGE:
            printf("%s (%d): keyword PACKAGE\n", argv[1], yylineno);
            break;

        case TOK_PRAGMA:
            printf("%s (%d): keyword PRAGMA\n", argv[1], yylineno);
            break;

        case TOK_PRIVATE:
            printf("%s (%d): keyword PRIVATE\n", argv[1], yylineno);
            break;

        case TOK_PROCEUDRE:
            printf("%s (%d): keyword PROCEDURE\n", argv[1], yylineno);
            break;

        case TOK_PROTECTED:
            printf("%s (%d): keyword PROTECTED\n", argv[1], yylineno);
            break;

        case TOK_RAISE:
            printf("%s (%d): keyword RAISE\n", argv[1], yylineno);
            break;

        case TOK_RANGE:
            printf("%s (%d): keyword RANGE\n", argv[1], yylineno);
            break;

        case TOK_RECORD:
            printf("%s (%d): keyword RECORD\n", argv[1], yylineno);
            break;

        case TOK_REM:
            printf("%s (%d): keyword REM\n", argv[1], yylineno);
            break;

        case TOK_RENAMES:
            printf("%s (%d): keyword RENAMES\n", argv[1], yylineno);
            break;

        case TOK_REQUEUE:
            printf("%s (%d): keyword REQUEUE\n", argv[1], yylineno);
            break;

        case TOK_RETURN:
            printf("%s (%d): keyword RETURN\n", argv[1], yylineno);
            break;

        case TOK_REVERSE:
            printf("%s (%d): keyword REVERSE\n", argv[1], yylineno);
            break;

        case TOK_SELECT:
            printf("%s (%d): keyword SELECT\n", argv[1], yylineno);
            break;

        case TOK_SEPARATE:
            printf("%s (%d): keyword SEPARATE\n", argv[1], yylineno);
            break;

        case TOK_SOME:
            printf("%s (%d): keyword SOME\n", argv[1], yylineno);
            break;

        case TOK_SUBTYPE:
            printf("%s (%d): keyword SUBTYPE\n", argv[1], yylineno);
            break;

        case TOK_SYNCHRONIZED:
            printf("%s (%d): keyword SYNCHRONIZED\n", argv[1], yylineno);
            break;

        case TOK_TAGGED:
            printf("%s (%d): keyword TAGGED\n", argv[1], yylineno);
            break;

        case TOK_TASK:
            printf("%s (%d): keyword TASK\n", argv[1], yylineno);
            break;

        case TOK_TERMINATE:
            printf("%s (%d): keyword TERMIANTE\n", argv[1], yylineno);
            break;

        case TOK_THEN:
            printf("%s (%d): keyword THEN\n", argv[1], yylineno);
            break;

        case TOK_TYPE:
            printf("%s (%d): keyword TYPE\n", argv[1], yylineno);
            break;

        case TOK_UNTIL:
            printf("%s (%d): keyword UNTIL\n", argv[1], yylineno);
            break;

        case TOK_USE:
            printf("%s (%d): keyword USE\n", argv[1], yylineno);
            break;

        case TOK_WHEN:
            printf("%s (%d): keyword WHEN\n", argv[1], yylineno);
            break;

        case TOK_WHILE:
            printf("%s (%d): keyword WHILE\n", argv[1], yylineno);
            break;

        case TOK_WITH:
            printf("%s (%d): keyword WITH\n", argv[1], yylineno);
            break;

        case TOK_XOR:
            printf("%s (%d): keyword XOR\n", argv[1], yylineno);
            break;

        case TOK_ERROR:
            yylval.err->extract(buffer, 1024, NULL, uError);
            printf("%s (%d): SCANNING ERROR: %s\n", argv[1], yylineno, buffer);
            break;

        default:
            printf("%s (%d): character %c\n", argv[1], yylineno, (char)(rv & 0xff));
            break;
        }
    }
    return 0;
}

#endif

