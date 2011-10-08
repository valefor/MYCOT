package parser;

import java.io.*;
import lexer.*;
import symbols.*;

public class Parser
{
    private Lexer lex;
    private Token look;
    Env top = null;
    int used = 0;

    public Parser(Lexer l) throws IOException { lex = l;move(); }
    void move() throws IOException { look = lex.scan(); }
    void error(String s) { throw new Error("near line" +lex.line+ ": " + s );}
    void match(String s) throws IOException 
    {
        if(look.tag == t) move();
        else error("syntax error");
    }

    public void program() throws IOException
    {
        Stmt s = block();
        int begin = s.newlabel();
        int after = s.newlabel();
        s.emitlabel(begin);
        s.gen(begin, after);
        s.emitlabel(after);
    }

    public block() throws IOException
    {
        match('{');
        Env savedEnv = top;
        top = new Env(top);
        decls();
        Stmt s = stmts();
        match('}');
        top = savedEnv;
        return s;
    }

    public decls() throws IOException
    {
        while( look.tag == Tag.BASIC )
        {
            Type p = type();
            Token tok = look();
            match(Tag.ID);
            match(';');
            Id id = new Id((Word)tok,p,used);
            top.put(tok,id);
            used = used + p.width;
        }
    }

    public type() throws IOException
    {
        Type p = (Type)look;
        match(Tag.BASIC);
        if(look.tag != '[') return p;
        else return dims(p);
    }

    public dims(Type p ) throws IOException
    {
        match('[');
        Token tok = look;
        match(Tag.NUM);
        matct(']');
        // Multidimensional Array
        if( look.tag == '[' ) p = dims(p);
        return new Array(((Num)tok).value, p);
    }

    Stmt stmts() throws IOException
    {
        if( look.tag == '}') return Stmt.Null;
        else return new Seq( stmt(), stmts() );
    }

    Stmt stmt() throws IOException
    {
        Expr x; Stmt s,s1,s2;
        Stmt savedStmt;

        switch( look.tag )
        {
            case ';':
                move();
                return Stmt.Null;
            case Tag.IF:
                match(Tag.IF)
        }

    }

}
