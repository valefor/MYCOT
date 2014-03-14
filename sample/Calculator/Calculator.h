#ifndef __GOLDPARSER_H_
#define __GOLDPARSER_H_

// Symbols
#define Symbol_Eof             0 // (EOF)
#define Symbol_Error           1 // (Error)
#define Symbol_Comment         2 // Comment
#define Symbol_Newline         3 // NewLine
#define Symbol_Whitespace      4 // Whitespace
#define Symbol_Timesdiv        5 // '*/'
#define Symbol_Divtimes        6 // '/*'
#define Symbol_Divdiv          7 // '//'
#define Symbol_Minus           8 // '-'
#define Symbol_Lparen          9 // '('
#define Symbol_Rparen         10 // ')'
#define Symbol_Times          11 // '*'
#define Symbol_Div            12 // '/'
#define Symbol_Plus           13 // '+'
#define Symbol_Decliteral     14 // DecLiteral
#define Symbol_Print          15 // print
#define Symbol_Calculate      16 // <Calculate>
#define Symbol_Calculations   17 // <Calculations>
#define Symbol_Expression     18 // <Expression>
#define Symbol_Multiplydivide 19 // <MultiplyDivide>
#define Symbol_Value          20 // <Value>

// Rules
#define Rule_Calculations                   0 // <Calculations> ::= <Calculate> <Calculations>
#define Rule_Calculations2                  1 // <Calculations> ::= 
#define Rule_Calculate_Print_Lparen_Rparen  2 // <Calculate> ::= print '(' <Expression> ')'
#define Rule_Expression_Plus                3 // <Expression> ::= <MultiplyDivide> '+' <Expression>
#define Rule_Expression_Minus               4 // <Expression> ::= <MultiplyDivide> '-' <Expression>
#define Rule_Expression                     5 // <Expression> ::= <MultiplyDivide>
#define Rule_Multiplydivide_Times           6 // <MultiplyDivide> ::= <Value> '*' <MultiplyDivide>
#define Rule_Multiplydivide_Div             7 // <MultiplyDivide> ::= <Value> '/' <MultiplyDivide>
#define Rule_Multiplydivide                 8 // <MultiplyDivide> ::= <Value>
#define Rule_Value_Decliteral               9 // <Value> ::= DecLiteral
#define Rule_Value_Lparen_Rparen           10 // <Value> ::= '(' <Expression> ')'

#include "goldparser.h"

/** \class GoldParserCtrl

    This class loads the proper grammar file, and uses the wxGoldParser object to parse the grammar and call
    the reduce methods accordingly to act upon the reductions.

    Fill this class with your methods, and act upon the reduction cases, to compile your own syntax tree,
    or perform calculations of any kind. See samples in the goldparser engine code for wxWidgets for more
    clarification.
*/

class GoldParserCtrl
{
private:
    wxGoldParser *_parser;

public:
    // TODO: Create with grammar file already in place. Like GoldParserCtrl("grammar.cgt"); and
    // use GoldParserCtrl::IsOk to check op it
    
    GoldParserCtrl();
    ~GoldParserCtrl();
    
    /** Sets the grammar file, and loads it. Whenever the grammar can't be loaded, the
        method returns with -1 for invalid file, and -2 for invalid grammar. if it returns
        with 0, everything is ok */
    int SetGrammarFile(const wxString &filename);

    /** Calls the parser. This will only work when there is a valid grammar file loaded.
        It will return with 0 if the grammar was succesfully accepted, -1 means there were
        errors */
    int Parse(const wxString &source, bool trimReductions = false, wxArrayString *messages = 0, wxArrayString *errors = 0);

    /** The heart of the parser. Every reduction is acted upon. For example when you have the reduction
        <Result> ::= <RValue> '+' <LValue> and the <RValue>, <LValue> are numbers, you can return in the
        current reduction something like this:

        \code
        // <Result> ::= <RValue> '+' <LValue>
        case Result_RValue_Plus_LValue:
            R->SetTag(R->GetToken(0)->GetTag() + R->GetToken(2)->GetTag());
            break;

        // now where Result has been used in the rule, can be used to get that token back
        // again, like

        // <PrintStat> ::= print <Result>;
        case PrintStat_print_Result:
            printf("The value is             break;

        // this way per reduction tree the user can act upon the current reduction and
        // send a value back up..

        \endcode
    */
    int ReplaceReduction(GpReduction *R, wxArrayString *errors = 0, wxArrayString *messages = 0);
};

#endif
