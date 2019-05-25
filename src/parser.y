/*=================================================================================================================*/
/* parser.l -- This is the parser for the Ada compiler                                                             */
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

#include <unicode/uclean.h>
#include <unicode/ustream.h>

#include "StringTables.h"

extern int parse_error;
extern int curr_lineno;
extern int yylex(void);

#define yyerror(x)  do {                                                                                        \
                        fprintf(stderr, "%s[%d@%d]: %s\n", __FILE__, __LINE__, curr_lineno, (x), "\n");         \
                        parse_error ++;                                                                         \
                    } while (0)

%}


/*
 * -- These are the 2-character symbols
 *    ---------------------------------
 */
%token      TOK_ARROW
%token      TOK_DOUBLE_DOT
%token      TOK_DOUBLE_STAR
%token      TOK_BECOMES
%token      TOK_NOT_EQUAL
%token      TOK_GREATER_THAN_OR_EQUAL
%token      TOK_LESS_THAN_OR_EQUAL
%token      TOK_LEFT_LABEL_BRACKET
%token      TOK_RIGHT_LABEL_BRACKET
%token      TOK_BOX

/*
 * -- These are the literals we can have
 *    ----------------------------------
 */
%token      TOK_CHAR_LIT
%token      TOK_INT_LIT
%token      TOK_REAL_LIT
%token      TOK_STRING_LIT
%token      TOK_IDENT


/*
 * -- the reserved words of Ada
 *    -------------------------
 */
%token      TOK_ABORT
%token      TOK_ABS
%token      TOK_ABSTRACT
%token      TOK_ACCEPT
%token      TOK_ACCESS
%token      TOK_ALIASED
%token      TOK_ALL
%token      TOK_AND
%token      TOK_ARRAY
%token      TOK_AT
%token      TOK_BEGIN
%token      TOK_BODY
%token      TOK_CASE
%token      TOK_CONSTANT
%token      TOK_DECLARE
%token      TOK_DELAY
%token      TOK_DELTA
%token      TOK_DIGITS
%token      TOK_DO
%token      TOK_ELSE
%token      TOK_ELSIF
%token      TOK_END
%token      TOK_ENTRY
%token      TOK_EXCEPTION
%token      TOK_EXIT
%token      TOK_FOR
%token      TOK_FUNCTION
%token      TOK_GENERIC
%token      TOK_GOTO
%token      TOK_IF
%token      TOK_IN
%token      TOK_INTERFACE
%token      TOK_IS
%token      TOK_LIMITED
%token      TOK_LOOP
%token      TOK_MOD
%token      TOK_NEW
%token      TOK_NOT
%token      TOK_NULL
%token      TOK_OF
%token      TOK_OR
%token      TOK_OTHERS
%token      TOK_OUT
%token      TOK_OVERRIDING
%token      TOK_PACKAGE
%token      TOK_PRAGMA
%token      TOK_PRIVATE
%token      TOK_PROCEUDRE
%token      TOK_PROTECTED
%token      TOK_RAISE
%token      TOK_RANGE
%token      TOK_RECORD
%token      TOK_REM
%token      TOK_RENAMES
%token      TOK_REQUEUE
%token      TOK_RETURN
%token      TOK_REVERSE
%token      TOK_SELECT
%token      TOK_SEPARATE
%token      TOK_SOME
%token      TOK_SUBTYPE
%token      TOK_SYNCHRONIZED
%token      TOK_TAGGED
%token      TOK_TASK
%token      TOK_TERMINATE
%token      TOK_THEN
%token      TOK_TYPE
%token      TOK_UNTIL
%token      TOK_USE
%token      TOK_WHEN
%token      TOK_WHILE
%token      TOK_WITH
%token      TOK_XOR


/*
 * -- optional BOM marker
 *    -------------------
 */
%token      TOK_BOM


/*
 * -- an error marker
 *    ---------------
 */
%token      TOK_ERROR


//
// -- This is the inforamtion needed to properly identify a node
//    ----------------------------------------------------------
%union {
    icu::UnicodeString *err;                    // -- This is en error token
    ada::IdentEntry *id;                        // -- An identifier
    ada::NumberEntry *nbr;                      // -- A number
    ada::StringEntry *str;                      // -- A string literal
    icu::UnicodeString *character;              // -- A single code point
}


%%


file : TOK_BOM


%%

int curr_lineno = 1;
int parse_error = 0;

