package inter;

import lexer.*;
import symbols.*;

public class Unary extends Op
{
    public Expr expr;
    public Unary( Token tok,Expr x)
    {
        super(tok,null)
    }

}
