//===================================================================================================================
//
//  StringTables.h -- These classes are used to manage capture the strings from the source file.
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


#ifndef __STRING_TABLES_H__
#define __STRING_TABLES_H__


#include <unicode/uclean.h>
#include <unicode/ustream.h>
#include <map>
#include <exception>


namespace ada {


//
// -- This is the basic entry into one of the string tables
//    -----------------------------------------------------
class Entry {
protected:
    icu::UnicodeString value;

protected:
    Entry(const icu::UnicodeString &v) : value(v) {};
    Entry(const std::string &v) : value(v.c_str()) {};
    Entry(const char *v) : value(v) {};

public:
    const icu::UnicodeString &GetKey(void) const { return value; }

public:
    static icu::UnicodeString MakeLower(const icu::UnicodeString &v) { return icu::UnicodeString(v).toLower(); }
    static icu::UnicodeString MakeLower(const std::string &v) { return icu::UnicodeString(v.c_str()).toLower(); }
    static icu::UnicodeString MakeLower(const char *v) { return icu::UnicodeString(v).toLower(); }
    static icu::UnicodeString MakeUpper(const icu::UnicodeString &v) { return icu::UnicodeString(v).toUpper(); }
    static icu::UnicodeString MakeUpper(const std::string &v) { return icu::UnicodeString(v.c_str()).toUpper(); }
    static icu::UnicodeString MakeUpper(const char *v) { return icu::UnicodeString(v).toUpper(); }
};


//
// -- Here we define a basic table -- we will specialize these in a moment
//    --------------------------------------------------------------------
template <class T>
class Table : protected std::map<const icu::UnicodeString,T *> {
public:
    Table() : std::map<const icu::UnicodeString,T *>() {};

public:
    T *add(const icu::UnicodeString &k) {
        T *rv = lookup(k);
        if (!rv) { rv = new T(k); this->insert(std::pair<const icu::UnicodeString,T *>(k, rv)); }
        return rv;
    };

public:
    T *lookup(const icu::UnicodeString &k) {
        auto search = this->find(k);
        if (search == this->end()) return NULL;
        else return search->second;
    }
};


//
// == This is the number table
//    ========================

//
// -- This is a number entry in the string table
//    ------------------------------------------
class NumberEntry : public Entry {
public:
    typedef enum {NBR_UNK, NBR_INT, NBR_REAL} Type_t;

private:
    Type_t type;                            // scalar or real number
    icu::UnicodeString canonicalValue;      // this is a value that can be outputted to LLVM
    long intVal;                            // this is the integer value if NBR_INT
    double realVal;                         // this is the real value if NBR_REAL

protected:
    void MakeCanonicalValue(void);

public:
    NumberEntry(const icu::UnicodeString &v) : Entry(Entry::MakeLower(v)), type(NBR_UNK) { MakeCanonicalValue(); };
    NumberEntry(const std::string &v) : Entry(Entry::MakeLower(v)), type(NBR_UNK) { MakeCanonicalValue(); };
    NumberEntry(const char *v) : Entry(Entry::MakeLower(v)), type(NBR_UNK) { MakeCanonicalValue(); };

    const Type_t GetType(void) const { return type; }
    const icu::UnicodeString &CanonicalValue(void) const { return canonicalValue; }
    const long long IntVal(void) const { if (type != NBR_INT) throw new std::logic_error("Number not int"); else return intVal; }
    const double RealVal(void) const { if (type != NBR_REAL) throw new std::logic_error("Number not real"); else return realVal; }
};


//
// -- and this is the number table
//    ----------------------------
class NumberTable : public Table<NumberEntry> {
public:
    NumberTable() : Table() {};

    NumberEntry *findNumber(const icu::UnicodeString &n) { return lookup(n); }
    NumberEntry *addNumber(const icu::UnicodeString &n) { return add(n); }
};


//
// == This is the string literal table
//    ================================


//
// -- This is a string entry in the string table
//    ------------------------------------------
class StringEntry : public Entry {
public:
    StringEntry(const icu::UnicodeString &v) : Entry(v) {};
    StringEntry(const std::string &v) : Entry(v) {};
    StringEntry(const char *v) : Entry(v) {};
};


//
// -- and this is the string table
//    ----------------------------
class StringTable : public Table<StringEntry> {
public:
    StringTable() : Table() {};

    StringEntry *findString(const icu::UnicodeString &n) { return lookup(n); }
    StringEntry *addString(const icu::UnicodeString &n) { return add(n); }
};


//
// == This is the indentifier literal table
//    =====================================


//
// -- This is a identifier entry in the string table
//    ----------------------------------------------
class IdentEntry : public Entry {
public:
    IdentEntry(const icu::UnicodeString &v) : Entry(Entry::MakeLower(v)) {};
    IdentEntry(const std::string &v) : Entry(Entry::MakeLower(v)) {};
    IdentEntry(const char *v) : Entry(Entry::MakeLower(v)) {};
};


//
// -- and this is the indetifier table
//    --------------------------------
class IdentTable : public Table<IdentEntry> {
public:
    IdentTable() : Table() {};

    IdentEntry *findString(const icu::UnicodeString &n) { return lookup(n); }
    IdentEntry *addString(const icu::UnicodeString &n) { return add(n); }
};


}   // namespace ada


//
// -- These are the actual table declarations
//    ---------------------------------------
extern ada::NumberTable numberTable;
extern ada::StringTable stringTable;
extern ada::IdentTable identTable;

#endif


