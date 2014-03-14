import java.io.*;

/*
 * Licensed Material - Property of Matthew Hawkins (hawkini@4email.net) 
 */
 
public class MyParser implements GPMessageConstants
{
 
    private interface SymbolConstants 
    {
       final int SYM_EOF            =  0;  // (EOF)
       final int SYM_ERROR          =  1;  // (Error)
       final int SYM_COMMENT        =  2;  // Comment
       final int SYM_NEWLINE        =  3;  // NewLine
       final int SYM_WHITESPACE     =  4;  // Whitespace
       final int SYM_TIMESDIV       =  5;  // '*/'
       final int SYM_DIVTIMES       =  6;  // '/*'
       final int SYM_DIVDIV         =  7;  // '//'
       final int SYM_MINUS          =  8;  // '-'
       final int SYM_LPAREN         =  9;  // '('
       final int SYM_RPAREN         = 10;  // ')'
       final int SYM_TIMES          = 11;  // '*'
       final int SYM_DIV            = 12;  // '/'
       final int SYM_PLUS           = 13;  // '+'
       final int SYM_DECLITERAL     = 14;  // DecLiteral
       final int SYM_PRINT          = 15;  // print
       final int SYM_CALCULATE      = 16;  // <Calculate>
       final int SYM_CALCULATIONS   = 17;  // <Calculations>
       final int SYM_EXPRESSION     = 18;  // <Expression>
       final int SYM_MULTIPLYDIVIDE = 19;  // <MultiplyDivide>
       final int SYM_VALUE          = 20;  // <Value>
    };

    private interface RuleConstants
    {
       final int PROD_CALCULATIONS                  =  0;  // <Calculations> ::= <Calculate> <Calculations>
       final int PROD_CALCULATIONS2                 =  1;  // <Calculations> ::= 
       final int PROD_CALCULATE_PRINT_LPAREN_RPAREN =  2;  // <Calculate> ::= print '(' <Expression> ')'
       final int PROD_EXPRESSION_PLUS               =  3;  // <Expression> ::= <MultiplyDivide> '+' <Expression>
       final int PROD_EXPRESSION_MINUS              =  4;  // <Expression> ::= <MultiplyDivide> '-' <Expression>
       final int PROD_EXPRESSION                    =  5;  // <Expression> ::= <MultiplyDivide>
       final int PROD_MULTIPLYDIVIDE_TIMES          =  6;  // <MultiplyDivide> ::= <Value> '*' <MultiplyDivide>
       final int PROD_MULTIPLYDIVIDE_DIV            =  7;  // <MultiplyDivide> ::= <Value> '/' <MultiplyDivide>
       final int PROD_MULTIPLYDIVIDE                =  8;  // <MultiplyDivide> ::= <Value>
       final int PROD_VALUE_DECLITERAL              =  9;  // <Value> ::= DecLiteral
       final int PROD_VALUE_LPAREN_RPAREN           = 10;  // <Value> ::= '(' <Expression> ')'
    };

   private static BufferedReader buffR;

    /***************************************************************
     * This class will run the engine, and needs a file called config.dat
     * in the current directory. This file should contain two lines,
     * The first should be the absolute path name to the .cgt file, the second
     * should be the source file you wish to parse.
     * @param args Array of arguments.
     ***************************************************************/
    public static void main(String[] args)
    {
       String textToParse = "", compiledGrammar = "";

       try
       {
           buffR = new BufferedReader(new FileReader(new File("./config.dat")));
           compiledGrammar = buffR.readLine();
           textToParse = buffR.readLine();

           buffR.close();
       }
       catch(FileNotFoundException fnfex)
       {
           System.out.println("Config File was not found.\n\n" +
                              "Please place it in the current directory.");
           System.exit(1);
       }
       catch(IOException ioex)
       {
          System.out.println("An error occured while reading config.dat.\n\n" +
                             "Please re-try ensuring the file can be read.");
          System.exit(1);
       }

       GOLDParser parser = new GOLDParser();

       try
       {
          parser.loadCompiledGrammar(compiledGrammar);
          parser.openFile(textToParse);
       }
       catch(ParserException parse)
       {
          System.out.println("**PARSER ERROR**\n" + parse.toString());
          System.exit(1);
       }

       boolean done = false;
       int response = -1;

       while(!done)
       {
          try
            {
                  response = parser.parse();
            }
            catch(ParserException parse)
            {
                System.out.println("**PARSER ERROR**\n" + parse.toString());
                System.exit(1);
            }

            switch(response)
            {
               case gpMsgTokenRead:
                   /* A token was read by the parser. The Token Object can be accessed
                      through the CurrentToken() property:  Parser.CurrentToken */
                   break;

               case gpMsgReduction:
                   /* This message is returned when a rule was reduced by the parse engine.
                      The CurrentReduction property is assigned a Reduction object
                      containing the rule and its related tokens. You can reassign this
                      property to your own customized class. If this is not the case,
                      this message can be ignored and the Reduction object will be used
                      to store the parse tree.  */

                      switch(parser.currentReduction().getParentRule().getTableIndex())
                      {
                         case RuleConstants.PROD_CALCULATIONS:
                            //<Calculations> ::= <Calculate> <Calculations>
                            break;
                         case RuleConstants.PROD_CALCULATIONS2:
                            //<Calculations> ::= 
                            break;
                         case RuleConstants.PROD_CALCULATE_PRINT_LPAREN_RPAREN:
                            //<Calculate> ::= print '(' <Expression> ')'
                            break;
                         case RuleConstants.PROD_EXPRESSION_PLUS:
                            //<Expression> ::= <MultiplyDivide> '+' <Expression>
                            break;
                         case RuleConstants.PROD_EXPRESSION_MINUS:
                            //<Expression> ::= <MultiplyDivide> '-' <Expression>
                            break;
                         case RuleConstants.PROD_EXPRESSION:
                            //<Expression> ::= <MultiplyDivide>
                            break;
                         case RuleConstants.PROD_MULTIPLYDIVIDE_TIMES:
                            //<MultiplyDivide> ::= <Value> '*' <MultiplyDivide>
                            break;
                         case RuleConstants.PROD_MULTIPLYDIVIDE_DIV:
                            //<MultiplyDivide> ::= <Value> '/' <MultiplyDivide>
                            break;
                         case RuleConstants.PROD_MULTIPLYDIVIDE:
                            //<MultiplyDivide> ::= <Value>
                            break;
                         case RuleConstants.PROD_VALUE_DECLITERAL:
                            //<Value> ::= DecLiteral
                            break;
                         case RuleConstants.PROD_VALUE_LPAREN_RPAREN:
                            //<Value> ::= '(' <Expression> ')'
                            break;
                      }

                          //Parser.Reduction = //Object you created to store the rule

                    // ************************************** log file
                    System.out.println("gpMsgReduction");
                    Reduction myRed = parser.currentReduction();
                    System.out.println(myRed.getParentRule().getText());
                    // ************************************** end log

                    break;

                case gpMsgAccept:
                    /* The program was accepted by the parsing engine */

                    // ************************************** log file
                    System.out.println("gpMsgAccept");
                    // ************************************** end log

                    done = true;

                    break;

                case gpMsgLexicalError:
                    /* Place code here to handle a illegal or unrecognized token
                           To recover, pop the token from the stack: Parser.PopInputToken */

                    // ************************************** log file
                    System.out.println("gpMsgLexicalError");
                    // ************************************** end log

                    parser.popInputToken();

                    break;

                case gpMsgNotLoadedError:
                    /* Load the Compiled Grammar Table file first. */

                    // ************************************** log file
                    System.out.println("gpMsgNotLoadedError");
                    // ************************************** end log

                    done = true;

                    break;

                case gpMsgSyntaxError:
                    /* This is a syntax error: the source has produced a token that was
                           not expected by the LALR State Machine. The expected tokens are stored
                           into the Tokens() list. To recover, push one of the
                              expected tokens onto the parser's input queue (the first in this case):
                           You should limit the number of times this type of recovery can take
                           place. */

                    done = true;

                    Token theTok = parser.currentToken();
                    System.out.println("Token not expected: " + (String)theTok.getData());

                    // ************************************** log file
                    System.out.println("gpMsgSyntaxError");
                    // ************************************** end log

                    break;

                case gpMsgCommentError:
                    /* The end of the input was reached while reading a comment.
                             This is caused by a comment that was not terminated */

                    // ************************************** log file
                    System.out.println("gpMsgCommentError");
                    // ************************************** end log

                    done = true;

                              break;

                case gpMsgInternalError:
                    /* Something horrid happened inside the parser. You cannot recover */

                    // ************************************** log file
                    System.out.println("gpMsgInternalError");
                    // ************************************** end log

                    done = true;

                    break;
            }
        }
        try
        {
              parser.closeFile();
        }
        catch(ParserException parse)
        {
            System.out.println("**PARSER ERROR**\n" + parse.toString());
            System.exit(1);
        }
    }
}

