//===================================================================================================================
//
//  StringTables.cc -- The class implementation used to manage capture the strings from the source file
//
//        Copyright (c)  2019 -- Adam Clark
//        Licensed under "THE BEER-WARE LICENSE"
//        See License.md for details.
//
// -----------------------------------------------------------------------------------------------------------------
//
//     Date      Tracker  Version  Pgmr  Description
//  -----------  -------  -------  ----  ---------------------------------------------------------------------------
//  2019-May-19  Initial   0.0.1   ADCL  Initial version
//
//===================================================================================================================


#ifndef __DEBUG__
#   define __DEBUG__ 0
#endif

#include "StringTables.h"

#include <unicode/uclean.h>
#include <unicode/ustream.h>
#include <unicode/schriter.h>

#include <cmath>


extern UErrorCode uError;


//
// -- These are the global string tables
//    ----------------------------------
ada::NumberTable numberTable;
ada::StringTable stringTable;
ada::IdentTable identTable;


//
// -- take a number and make is decimal based so that it can be emitted to LLVM
//    -------------------------------------------------------------------------
void ada::NumberEntry::MakeCanonicalValue(void)
{
    icu::UnicodeString baseStr = "";
    icu::UnicodeString expStr = "";
    icu::UnicodeString wholeStr = "";
    icu::UnicodeString decimalStr = "";
    icu::UnicodeString number = "";
    icu::UnicodeString work = "";
    icu::UnicodeString temp = "";
    icu::UnicodeString val = value;
    bool hasDecimal = false;
    char buffer[1024];


    //
    // -- before anything else, strip out the '_' characters, which have no semantic value
    //    --------------------------------------------------------------------------------
    for (int i = 0; i < val.length(); i ++) {
        if (val.char32At(i) != '_') {
            work += val.char32At(i);
        }
    }

    val = work;
    work = "";

#if __DEBUG__ == 1
    val.extract(buffer, 1024, NULL, uError);
    printf("The cleaned up original string is %s\n", buffer);
#endif


    //
    // -- separate out the components
    //    ---------------------------
    int n = val.indexOf('#');
    if (n != -1) {
        // -- extract out the base
        val.extract(0, n, baseStr);

        // -- extract out the rest of the number (whole.decimal)
        val.extract(n + 1, val.length() - (n + 1), temp);
        n = temp.indexOf('#');

        if (n == -1) {
            uError = U_PARSE_ERROR;
            return;
        }

        temp.extract(0, n, number);
        temp.extract(n + 1, temp.length() - (n + 1), expStr);

        // -- extract out the exponent (if any)
        if (expStr.length() > 0) {
            if (expStr.char32At(0) != 'e') {
                uError = U_PARSE_ERROR;
                return;
            }

            expStr.extract(1, expStr.length() - 1, temp);
            expStr = temp;
        }

        // -- finally separate the whole and decimal parts
        n = number.indexOf('.');
        if (n == -1) {
            wholeStr = number;
        } else {
            number.extract(0, n, wholeStr);
            number.extract(n + 1, number.length() - (n + 1), decimalStr);
            hasDecimal = true;
        }
    } else {
        // -- extract out the number (whole.decimal)
        n = val.indexOf('e');
        if (n == -1) n = val.indexOf('E');

        if (n == -1) {
            number = val;     // sometimes a number is just a number
        } else {
            val.extract(0, n, number);
            val.extract(n + 1, val.length() - (n + 1), expStr);
        }

        // -- finally separate the whole and decimal parts
        n = number.indexOf('.');
        if (n == -1) {
            wholeStr = number;
        } else {
            number.extract(0, n, wholeStr);
            number.extract(n + 1, number.length() - (n + 1), decimalStr);
            hasDecimal = true;
        }
    }

#if __DEBUG__ == 1
    baseStr.extract(buffer, 1024, NULL, uError);
    printf("The base string is %s\n", buffer);

    wholeStr.extract(buffer, 1024, NULL, uError);
    printf("The whole string is %s\n", buffer);

    decimalStr.extract(buffer, 1024, NULL, uError);
    printf("The decimal string is %s\n", buffer);

    expStr.extract(buffer, 1024, NULL, uError);
    printf("The exp string is %s\n", buffer);
#endif


    //
    // -- calculate the value of the components
    //    -------------------------------------
    int base = 10;
    int exp = 0;
    long whole = 0;
    long decimal = 0;

    uError = U_ZERO_ERROR;


    //
    // -- first, determine if we are dealing with a based number -- search for '#'
    //    ------------------------------------------------------------------------
    if (baseStr.length() > 0) {
#if __DEBUG__ == 1
        printf("base...\n");
#endif
        icu::StringCharacterIterator iter(baseStr);
        base = 0;

        UChar32 cp;

        for (cp = iter.first(); cp != icu::StringCharacterIterator::DONE; cp = iter.next()) {
            if (cp < '0' || cp > '9') {
                uError = U_PARSE_ERROR;
                return;
            }

            base = (base * 10) + (cp - '0');
        }

        if (base < 2 || base > 16) {
            uError = U_PARSE_ERROR;
            return;
        }
    }


    //
    // -- now, work contains a whole number or a floating point number, either with a possible exponent
    //    ---------------------------------------------------------------------------------------------
    if (expStr.length() > 0) {
#if __DEBUG__ == 1
        printf("exp..\n");
#endif
        icu::StringCharacterIterator iter(expStr);
        exp = 0;
        bool neg = false;

        UChar32 cp;

        for (cp = iter.first(); cp != icu::StringCharacterIterator::DONE; cp = iter.next()) {
            if (cp == '-') {
                neg = true;
                continue;
            } else if (cp == '+') continue;

            if (cp < '0' || cp > '9') {
                uError = U_PARSE_ERROR;
                return;
            }

            exp = (exp * 10) + (cp - '0');
        }

        if (neg) exp = -exp;
    }


    //
    // -- Now, we work on the whole part of the number
    //    --------------------------------------------
    {       // create a scope!
#if __DEBUG__ == 1
        printf("whole...\n");
#endif
        icu::StringCharacterIterator iter(wholeStr);
        whole = 0;

        UChar32 cp;

        for (cp = iter.first(); cp != icu::StringCharacterIterator::DONE; cp = iter.next()) {
#if __DEBUG__ == 1
            printf("whole digit: %ld\n", cp);
#endif

            int digit;
            if (cp >= '0' && cp <= '9') digit = cp - '0';
            else if (cp >= 'a' && cp <= 'f') digit = cp - 'a' + 10;
            else if (cp >= 'A' && cp <= 'F') digit = cp - 'A' + 10;
            else {
                uError = U_PARSE_ERROR;
                return;
            }

            if (digit >= base) {
                uError = U_PARSE_ERROR;
                return;
            }

            whole = (whole * base) + digit;
        }
    }


    //
    // -- Finally, the decimal part
    //    -------------------------
    if (decimalStr.length() > 0 && hasDecimal) {
#if __DEBUG == 1
        printf("decimals...\n");
#endif
        icu::StringCharacterIterator iter(decimalStr);
        decimal = 0;

        UChar32 cp;

        for (cp = iter.first(); cp != icu::StringCharacterIterator::DONE; cp = iter.next()) {
            int digit;

            if (cp >= '0' && cp <= '9') digit = cp - '0';
            else if (cp >= 'a' && cp <= 'f') digit = cp - 'a' + 10;
            else if (cp >= 'A' && cp <= 'F') digit = cp - 'A' + 10;
            else {
                uError = U_PARSE_ERROR;
                return;
            }

            if (digit >= base) {
                uError = U_PARSE_ERROR;
                return;
            }

            decimal = (decimal * base) + digit;
        }
    }


#if __DEBUG__ == 1
    printf("   assembling number -- base: %d; whole: %ld; decimal: %ld; exp: %ld; real? %c\n",
            base, whole, decimal, exp, (hasDecimal?'Y':'N'));
#endif

    //
    // -- now, we can put it all together
    //    -------------------------------
    if (hasDecimal) {
        realVal = (double)whole;
        realVal += ((double)decimal * pow(base, -decimalStr.length()));
        realVal *= pow(base, exp);
        type = NBR_REAL;
    } else {
        intVal = whole * pow(base, exp);
        type = NBR_INT;
    }
}

