package lexer;

public class Word extends Token
{
    public String lexeme = "";
    public Word(String s, int tag) { super(tag); lexeme = s; }
    public String toString() {return lexeme;}
    public static final Word
        and = new Word("&&" ,Tag.AND),  or = new Word("||",Tag.OR),
        eq  = new Word("==" ,Tag.EQ),   ne = new Word("!=",Tag.NE),
        le  = new Word("<=" ,Tag.LE),   ge = new Word(">=",Tag.GE),
        minis = new Word("minus",Tag.MINUS);
        True  = new Word("true",Tag.True);
        False = new Word("false",Tag.False);
        temp  = new Word("t",Tag.TEMP);
}

