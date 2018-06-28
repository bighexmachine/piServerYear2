
val put            = 1;
val get            = 2;
||
val instream       = 0;
val messagestream  = 0;
val binstreaml     = 512;
val binstreamh     = 768;
||
val EOF           = 255;
||
| tree node field selectors |
val t0            = 0;
val t1            = 1;
val t2            = 2;
val t3            = 3;
||
| symbols |
val s_null        = 0;
val s_name        = 1;
val s_number      = 2;
val s_lbracket    = 3;
val s_rbracket    = 4;
val s_lparen      = 6;
val s_rparen      = 7;
||
val s_fncall      = 8;
val s_pcall       = 9;
val s_if          = 10;
val s_then        = 11;
val s_else        = 12;
val s_while       = 13;
val s_do          = 14;
val s_ass         = 15;
val s_skip        = 16;
val s_begin       = 17;
val s_end         = 18;
val s_semicolon   = 19;
val s_comma       = 20;
val s_var         = 21;
val s_vari        = 22;
val s_array       = 23;
val s_scope       = 24;
val s_proc        = 25;
val s_func        = 26;
val s_is          = 27;
val s_stop        = 28;
val s_module      = 29;
val s_in          = 30;
||
val s_not         = 32;
val s_neg         = 34;
val s_val         = 35;
val s_string      = 36;
||
val s_true        = 42;
val s_false       = 43;
val s_return      = 44;
||
val s_input       = 45;
val s_output      = 46;
||
val s_endfile     = 60;
||
val s_diadic      = 64;
||
val s_plus        = s_diadic + 0;
val s_minus       = s_diadic + 1;
val s_or          = s_diadic + 5;
val s_and         = s_diadic + 6;
||
val s_eq          = s_diadic + 10;
val s_ne          = s_diadic + 11;
val s_ls          = s_diadic + 12;
val s_le          = s_diadic + 13;
val s_gr          = s_diadic + 14;
val s_ge          = s_diadic + 15;
||
val s_sub         = s_diadic + 16;
val s_dot         = s_diadic + 17;
||
| up instruction codes |
val i_ldam        = #0;
val i_ldbm        = #1;
val i_stam        = #2;

val i_ldac        = #3;
val i_ldbc        = #4;
val i_ldap        = #5;

val i_ldai        = #6;
val i_ldbi        = #7;
val i_stai        = #8;

val i_br          = #9;
val i_brz         = #A;
val i_brn         = #B;
val i_brb         = #C;

val i_opr         = #D;

val i_pfix        = #E;
val i_nfix        = #F;
||
val o_add         = #0;
val o_sub         = #1;
||
val o_in          = #2;
val o_out         = #3;
val o_svc         = #4;
||
val r_areg        = 0;
val r_breg        = 1;
||
val m_sp          = 2;
||
val bytesperword  = 4;
||
| lexical analyser |
val linemax = 200;
val nametablesize = 101;
array nametable[nametablesize];
||
var outstream;
||
val treemax = 25000;
array tree[treemax];
var treep;

var namenode;
var nullnode;
var zeronode;
var numval;

var symbol;
||
array wordv[100];
var wordp;
var wordsize;
||
array charv[100];
var charp;
var ch;
||
array linev[linemax];
var linep;
var linelength;
var linecount;
var errcount;

||
| name scoping stack |
array names_d[500];
array names_v[500];

var namep;
var nameb;
var namem;
var nameg;

| set to 1 if the name is used |
array procs_u[100];
var procs_uc;

val pflag = #1000;
||
var codesize;
var arraybase;

var procdef;
var proclabel;
var infunc;
||
var stackp;
var stk_max;
| constants, strings and labels |
array consts[500];
var constp;
||
array tables[1000];
var tablep;
var tablesize;
||
array strings[1000];
var stringp;
var stringsize;
||
val labval_size  = 2000;
array labval[labval_size];
var labelcount;
||
val cb_size      = 15000;
||
| code buffer flags |
val cbf_inst     = 1;

val cbf_lab      = 2;
val cbf_fwdref   = 3;
val cbf_bwdref   = 4;

val cbf_stack    = 5;

val cbf_const    = 6;
val cbf_string   = 7;
val cbf_entry    = 8;
val cbf_pexit    = 9;
val cbf_fnexit   = 10;

val cbf_var      = 11;
val cbf_constp   = 12;
val cbf_table    = 13;

val cb_flag      = #10000000;
val cb_high      = #01000000;

var cbv_flag;
var cbv_high;
var cbv_low;

||
| code buffer variables |
array codebuffer[cb_size];
var cb_bufferp;
var cb_buffergp;
var cb_loadbase;
var cb_entryinstp;
var cb_blockstart;
var cb_loadpoint;
var cb_conststart;
var cb_tablestart;
var cb_stringstart;

var entrylab;
var lowbyte;

var mul_x;
var div_x;

||
val maxaddr      = 32000;

func main() is
  var t;
{
  selectoutput(messagestream);

  t := formtree();

  prints("tree size: "); printn(treep - tree); newline();

  if(errcount = 0)
  then
    translate(t)
  else
    skip;

  prints("program size: "); printn(codesize); newline();

  prints("size: ");
  printn(codesize + mul((maxaddr - arraybase), 2));
  newline();

  prints("total errors:");
  printn(errcount);
  newline();

  prints("data section:");
  printn(cb_conststart);
  prints(",");
  printn(cb_stringstart + stringsize);
  newline();

  prints("total errors:");
  printn(errcount);
  newline();

  if (errcount = 0)
  then
    return 0
  else
    return 1
}

proc selectoutput(c) is outstream := c

proc putval(c) is put(c, outstream)

proc newline() is putval('\n')


func lsu(x, y) is
  if (x < 0) = (y < 0)
  then
    return x < y
  else
    return y < 0

func mul_step(b, y) is
  var r;
{ if (b < 0) or (~lsu(b, mul_x))
  then
    r := 0
  else
    r := mul_step(b + b, y + y);
  if ~lsu(mul_x, b)
  then
  { mul_x := mul_x - b;
    r := r + y
  }
  else
    skip;
  return r
}

func mul(n, m) is
{ mul_x := m;
  return mul_step(1, n)
}

func div_step(b, y) is
  var r;
{ if (y < 0) or (~lsu(y, div_x))
  then
    r := 0
  else
    r := div_step(b + b, y + y);
  if ~lsu(div_x, y)
  then
  { div_x := div_x - y;
    r := r + b
  }
  else
    skip;
  return r
}

func div(n, m) is
{ div_x := n;
  if lsu(n, m)
  then
    return 0
  else
    return div_step(1, m)
}

func rem(n, m) is
  var x;
{ x := div(n, m);
  return div_x
}

func mul2(x, y) is
  var n;
  var r;
{ r := x;
  n := 1;
  while  n ~= y do
  { r := r + r;
    n := n + n
  };
  return r
}

func exp2(n) is
  var r;
  var i;
{ i := n;
  r := 1;
  while i > 0 do
  { r := r + r;
    i := i - 1
  };
  return r
}

func packstring(s,  v) is
  var n;
  var si;
  var vi;
  var w;
  var b;
{ n := s[0];
  si := 0;
  vi := 0;
  b := 0;
  w := 0;
  while si <= n do
  { w :=  w + mul(s[si], exp2(mul2(b, 8)));
    b := b + 1;
    if (b = bytesperword)
    then
    { v[vi] := w;
      vi := vi + 1;
      w := 0;
      b := 0
    }
    else skip;
    si := si + 1
  };
  if (b = 0)
  then
    vi := vi - 1
  else
    v[vi] := w;
  return vi
}

proc unpackstring(s,  v) is
  var si;
  var vi;
  var b;
  var w;
  var n;
{ si := 0;
  vi := 0;
  b := 0;
  w := s[0];
  n := rem(w, 256);
  while vi <= n do
  { v[vi] := rem(w, 256);
    w := div(w, 256);
    vi := vi + 1;
    b := b + 1;
    if b = bytesperword
    then
    { b := 0;
      si := si + 1;
      w := s[si]
    }
    else skip
  }
}

proc prints(s) is
  var n;
  var p;
  var w;
  var l;
  var b;
{ n := 1;
  p := 0;
  w := s[p];
  l := rem(w, 256);
  w := div(w, 256);
  b := 1;
  while (n <= l) do
  { putval(rem(w, 256));
    w := div(w, 256);
    n := n + 1;
    b := b + 1;
    if (b = bytesperword)
    then
    { b := 0;
      p := p + 1;
      w := s[p]
    }
    else skip
  }
}

proc printn(n) is
  if n < 0
  then
  { putval('-');
    printn(-n)
  }
  else
  { if n > 9
    then
      printn(div(n, 10))
    else skip;
    putval(rem(n, 10) + '0')
  }

proc printhex(n) is
  var d := div(n, 16);
{ if d = 0 then skip else printhex(d);
  d := rem(n, 16);
  if d < 10
  then putval(d + '0')
  else putval((d - 10) + 'a')
}

func formtree() is

{ linep := 0;
  wordp := 0;
  charp := 0;

  treep := tree;

  nullnode := cons1(s_null);

  zeronode := cons2(s_number, 0);

  var i := 0;
  while i < nametablesize do
  { nametable[i] := nullnode;
    i := i + 1
  };

  declsyswords();

  linecount := 0;

  rdline();
  rch();

  nextsymbol();

  return rprogram()
}

proc cmperror(s) is
{
  cmperror_internal(s); newline()
}

proc cmperror_internal(s) is
{ prints("error near line ");
  printn(linecount); prints(": ");
  prints(s);
  errcount := errcount + 1
}

| tree node constructors |

func newvec(n) is
  var t := treep;
{ treep := treep + n
; if treep > (tree + treemax) then cmperror("out of space") else skip
; return t
}

func cons1(op) is
  var t := newvec(1);
{ t.t0 := op
; return t
}

func cons2(op, op1) is
  var t := newvec(2);
{ t.t0 := op
; t.t1 := op1
; return t
}

func cons3(op, op1, op2) is
  var t := newvec(3);
{ t.t0 := op
; t.t1 := op1
; t.t2 := op2
; return t
}

func cons4(op, op1, op2, op3) is
  var t := newvec(4);
{ t.t0 := op
; t.t1 := op1
; t.t2 := op2
; t.t3 := op3
; return t
}

| name table lookup |

func lookupword() is
  var a := wordv[0];
  var hashval := rem(a, nametablesize);
  var found := false;
  var searching := true;
  var op;
{ namenode := nametable[hashval];
  while searching do
  { if namenode = nullnode
    then
    { found := false;
      searching := false
    }
    else
    var i := 0;
    { while (i <= wordsize) and (namenode[i+2] = wordv[i]) do
        i := i + 1;
      if i <= wordsize
      then
        namenode := namenode[1]
      else
      { op := namenode[t0];
        found := true;
        searching := false
      }
    }
  };
  if found
  then
    skip
  else
  { namenode := newvec(wordsize+3);
    namenode[t0] := s_name;
    namenode[1] := nametable[hashval];
    var i := 0;
    while i <= wordsize do
    { namenode[i+2] := wordv[i];
      i := i + 1
    };
    nametable[hashval] := namenode;
    op := s_name
  };
  return op
}


proc declare(s, item) is
{ unpackstring(s, charv);
  wordsize := packstring(charv, wordv);
  lookupword();
  namenode.t0 := item
}

proc declsyswords() is
{ declare("and", s_and);
  declare("array", s_array);
  declare("do", s_do);
  declare("else", s_else);
  declare("false", s_false);
  declare("func", s_func);
  declare("if", s_if);
  declare("in", s_in);
  declare("is", s_is);
  declare("module", s_module);
  declare("or", s_or);
  declare("proc", s_proc);
  declare("return", s_return);
  declare("skip", s_skip);
  declare("stop", s_stop);
  declare("then", s_then);
  declare("true", s_true);
  declare("val", s_val);
  declare("var", s_var);
  declare("while", s_while)
 }

func getchar() is
  return get(instream)

proc rdline() is
{ linelength := 1;
  linep := 1;
  linecount := linecount + 1;
  ch := getchar();
  linev[linelength] := ch;
  while (ch ~= '\n') and (ch ~= EOF) and (linelength < linemax) do
  { ch := getchar();
    linelength := linelength + 1;
    linev[linelength] := ch
  }
}

proc rch() is
{ if (linep > linelength) then rdline() else skip;
  ch := linev[linep];
  linep := linep + 1
}

proc rdtag() is
{ charp := 0;
  while ((ch>='A') and (ch<='Z')) or ((ch>='a') and (ch<='z')) or ((ch>='0') and (ch<='9')) or (ch = '_') do
  { charp := charp + 1;
    charv[charp] := ch;
    rch()
  };
  charv[0] := charp;
  wordsize := packstring(charv, wordv)
}

proc readnumber(base) is
  var d := value(ch);
{ numval := 0;
  if (d >= base) then
    cmperror("error in number")
  else
    while (d < base) do
    { numval := mul(numval, base) + d;
      rch();
      d := value(ch)
    }
}

func value(c) is
  if (c >= '0') and (c <= '9')
  then
    return c - '0'
  else
  if (c >= 'A') and (c <= 'Z')
  then
    return (c + 10) - 'A'
  else
  if (c >= 'a') and (c <= 'z')
  then
    return (c + 10) - 'a'
  else
    return 500

func readcharco() is
  var v;
{ if (ch = '\\')
  then
  { rch();
    if (ch = '\\')
    then
     v := '\\'
    else
    if (ch = '\'')
    then
      v := '\''
    else
    if (ch = '\"')
    then
      v := '\"'
    else
    if (ch = 'n')
    then
      v := '\n'
    else
    if (ch = 'r')
    then
      v := '\r'
    else
    if (ch = 't')
    then
      v := '\t'
    else
      cmperror("error in character constant")
  }
  else
    v := ch;
  rch();
  return v
}

proc readstring() is
  var charc;
{ charp := 0;
  while (ch ~= '\"') do
  { if (charp = 255)
    then cmperror("error in string constant")
    else skip;
    charc := readcharco();
    charp := charp + 1;
    charv[charp] := charc
  };
  charv[0] := charp;
  wordsize := packstring(charv, wordv)
}

| lexical analyser main procedure |

proc skipwhitespace() is
{
  while (ch = '\n') or (ch = '\r') or (ch = '\t') or (ch = ' ') do
  {
    rch()
  }
}

proc nextsymbol() is
{ skipwhitespace();
  if (ch = '|')
  then
  { rch();
    while (ch ~= '|') and (ch ~='\n') do rch();

    if (ch = '\n')
    then
      cmperror("missing end of comment")
    else
      skip;

    rch();
    nextsymbol()
  }
  else
  if ((ch >= 'A') and (ch <= 'Z')) or ((ch >= 'a') and (ch <= 'z'))
  then
  { rdtag();
    symbol := lookupword()
  }
  else
  if (ch >= '0') and (ch <= '9')
  then
  { symbol := s_number;
    readnumber(10)
  }
  else
  if (ch = '#')
  then
  { rch();
    symbol := s_number;
    if ch = 'b'
    then
    { rch();
      readnumber(2)
    }
    else
      readnumber(16)
  }
  else
  if (ch = '[')
  then
  { rch();
    symbol := s_lbracket
  }
  else
  if (ch = ']')
  then
  { rch();
    symbol := s_rbracket
  }
  else
  if (ch = '(')
  then
  { rch();
    symbol := s_lparen
  }
  else
  if (ch = ')')
  then
  { rch();
    symbol := s_rparen
  }
  else
  if (ch = '{')
  then
  { rch();
    symbol := s_begin
  }
  else
  if (ch = '}')
  then
  { rch();
    symbol := s_end
  }
  else
  if (ch = ';')
  then
  { rch();
    symbol := s_semicolon
  }
  else
  if (ch = ',')
  then
  { rch();
    symbol := s_comma
  }
  else
  if (ch = '.')
  then
  { rch();
    symbol := s_dot
  }
  else
  if (ch = '+')
  then
  { rch();
    symbol := s_plus
  }
  else
  if (ch = '-')
  then
  { rch();
    symbol := s_minus
  }
  else
  if (ch = '=')
  then
  { rch();
    symbol := s_eq
  }
  else
  if (ch = '<')
  then
  { rch();
    if (ch = '=')
    then
    { rch();
      symbol := s_le
    }
    else
      symbol := s_ls
  }
  else
  if (ch = '>')
  then
  { rch();
    if (ch = '=')
    then
    { rch();
      symbol := s_ge
    }
    else
      symbol := s_gr
  }
  else
  if (ch = '~')
  then
  { rch();
    if (ch = '=')
    then
    { rch();
      symbol := s_ne
    }
    else
      symbol := s_not
  }
  else
  if (ch = ':')
  then
  { rch();
    if (ch = '=')
    then
    { rch();
      symbol := s_ass
    }
    else
      cmperror("\'=\' expected")
  }
  else
   if (ch = '?')
  then
  { rch();
    symbol := s_input
  }
  else
  if (ch = '!')
  then
  { rch();
    symbol := s_output
  }
  else
  if (ch = '\'')
  then
  { rch();
    numval := readcharco();
    if (ch = '\'')
    then
      rch()
    else
      cmperror("error in character constant");
    symbol := s_number
  }
  else
  if (ch = '\"')
  then
  { rch();
    readstring();
    if (ch = '\"')
    then
      rch()
    else
      cmperror("error in string constant");
    symbol := s_string
  }
  else
  if (ch = EOF)
  then
    symbol := s_endfile
  else
    cmperror("illegal character")
}

| syntax analyser |

proc checkfor(s,  m) is
  if symbol = s
  then
    nextsymbol()
  else
    cmperror(m)

func rname() is
  var a;
{ if symbol = s_name
  then
  { a := namenode;
    nextsymbol()
  }
  else
    cmperror("name expected");
  return a
}

func relement() is
  var a;
  var b;
  var i;
{ if (symbol = s_name)
  then
  { a := rname();
    if (symbol = s_lbracket)
    then
    { nextsymbol();
      b := rexpression();
      checkfor(s_rbracket, "\']\' expected");
      a := cons3(s_sub, a, b)
    }
    else
    if (symbol = s_lparen)
    then
    { nextsymbol();
      if (symbol = s_rparen)
      then
        b := nullnode
      else
        b := rexplist();
      checkfor(s_rparen, "\')\' expected");
      a := cons3(s_fncall, a, b)
    }
    else
      skip
  }
  else
  if (symbol = s_number)
  then
  {  a := cons2(s_number, numval);
     nextsymbol()
  }
  else
  if ((symbol = s_true) or (symbol = s_false))
  then
  { a := namenode;
    nextsymbol()
  }
  else
  if (symbol = s_string)
  then
  { a := newvec(wordsize + 2);
    a[t0] := s_string;
    i := 0;
    while i <= wordsize do
    { a[i + 1] := wordv[i];
      i := i + 1
    };
    nextsymbol()
  }
  else
  if (symbol = s_lbracket)
  then
  { nextsymbol();
    a := rexplist();
    checkfor(s_rbracket, "\']\' expected")
  }
  else
  if (symbol = s_lparen)
  then
  {  nextsymbol();
     a := rexpression();
     checkfor(s_rparen, "\')\' expected")
  }
  else
    cmperror("error in expression");
  return a
}

func rexpression() is
  var a;
  var b;
  var s;
{ if (symbol = s_minus)
  then
  {  nextsymbol();
     b := relement();
     return cons2(s_neg, b)
  }
  else
  if (symbol = s_not)
  then
  {  nextsymbol();
     b := relement();
     return cons2(s_not, b)
  }
  else
  { a := relement();
    if diadic(symbol)
    then
    { s := symbol;
      nextsymbol();
      return cons3(s, a, rright(s))
    }
    else
      return a
  }
}

func rright(s) is
  var b := relement();
  if (associative(s) and (symbol = s))
  then
  { nextsymbol();
    return cons3(s, b, rright(s))
  }
  else
    return b


func associative(s) is
  return (s = s_and) or (s = s_or) or (s = s_plus)


func rexplist() is
  var a;
{ a := rexpression();
  if (symbol = s_comma)
  then
  { nextsymbol();
    return cons3(s_comma, a, rexplist())
  }
  else
    return a
}

func rstatement() is
  var a;
  var b;
  var c;
  var pn;
{ if (symbol = s_var) or (symbol = s_val) or (symbol = s_array)
  then
  { a := rdecl();
    return cons3(s_scope, a, rstatement())
  }
  else
  if (symbol = s_skip)
  then
  { nextsymbol();
    return cons1(s_skip)
  }
  else
  if (symbol = s_stop)
  then
  { nextsymbol();
    return cons1(s_stop)
  }
  else
  if (symbol = s_return)
  then
  { nextsymbol();
    return cons2(s_return, rexpression())
  }
  else
  if (symbol = s_if)
  then
  { nextsymbol();
    a := rexpression();
    checkfor(s_then, "\'then\' expected");
    b := rstatement();
    checkfor(s_else, "\'else\' expected");
    c := rstatement();
    return cons4(s_if, a, b, c)
  }
  else
  if (symbol = s_while)
  then
  { nextsymbol();
    a := rexpression();
    checkfor(s_do, "\'do\' expected");
    b := rstatement();
    return cons3(s_while, a, b)
  }
  else
  if (symbol = s_begin)
  then
  { nextsymbol();
    a := rstatements();
    checkfor(s_end, "\'}\' expected");
    return a
  }
  else
  if (symbol = s_name) or (symbol = s_number) or (symbol = s_lparen)
  then
  { a := rexpression();
    if (a.t0) = s_fncall
    then
    { a.t0 := s_pcall;

      setprocused(a.t1);

      |namemessage("calling ", a.t1);|
      return a
    }
    else
    if (symbol = s_ass)
    then
      if ((a.t0) = s_name) or ((a.t0) = s_sub) or ((a.t0) = s_dot)
      then
      { nextsymbol();
        return cons3(s_ass, a, rexpression())
      }
      else
      { cmperror("error in destination");
        return cons1(s_stop)
      }
    else
    if (symbol = s_input)
    then
    { nextsymbol();
      return cons3(s_input, a, rexpression())
    }
    else
    if (symbol = s_output)
    then
    { nextsymbol();
      return cons3(s_output, a, rexpression())
    }
    else
    { cmperror("\':=\', \'!\' or \'?\' expected");
      return cons1(s_stop)
    }
  }
  else
  { cmperror("error in command");
    return cons1(s_stop)
  }
}

func rstatements() is
  var a := rstatement();
  if symbol = s_semicolon
  then
  { nextsymbol();
    return cons3(s_semicolon, a, rstatements())
  }
  else
    return a

func rprocdecls() is
  var a := rprocdecl();
  if (symbol = s_proc) or (symbol = s_func)
  then
    return cons3(s_semicolon, a, rprocdecls())
  else
    return a


func rprocdecl() is
  var s;
  var a;
  var b;
{ s := symbol;
  nextsymbol();
  a := rname();
  checkfor(s_lparen, "\'(\' expected");
  if symbol = s_rparen
  then
    b := nullnode
  else
    b := rformals();
  checkfor(s_rparen, "\')\' expected");
  checkfor(s_is, "\'is\' expected");

  return cons4(s, a, b, rstatement())
}

func rformals() is
  var a := cons2(s_var, rname());
  if (symbol = s_comma)
  then
  { nextsymbol();
    return cons3(s_comma, a, rformals())
  }
  else
    return a

func rprogram() is
  var a;
  var b;
  if symbol = s_module
  then
  { nextsymbol();
    checkfor(s_lparen, "\'(\' expected");
    a := rformals();
    checkfor(s_rparen, "\')\' expected");
    checkfor(s_is, "\'is\' expected");
    b := rmodule();
    checkfor(s_in, "\'in\' expected");
    return cons4(s_module, a, b, rprogram())
  }
  else
    return rmodule()


func rmodule() is
  if (symbol = s_val) or (symbol = s_var) or (symbol = s_array)
  then
  {
    var a := rdecl();
    return cons3(s_scope, a, rprogram())
  }
  else
    return rprocdecls()


func rdecl() is
  var a;
  var b;
{ if (symbol = s_var)
  then
  { nextsymbol();
    a := rname();
    if (symbol = s_ass)
    then
    { nextsymbol();
      b := rexpression();
      a := cons3(s_vari, a, b)
    }
    else
      a := cons2(s_var, a)
  }
  else
  if (symbol = s_array)
  then
  { nextsymbol();
    a := rname();
    checkfor(s_lbracket, "\'[\' expected");
    b := rexpression();
    checkfor(s_rbracket, "\']\' expected");

    if (symbol = s_eq)
    then
    {
      prints("array has initialiser");
      newline();
      nextsymbol();
      checkfor(s_lbracket, "\'[\' expected");
      |TODO : Parse and handle the array default value|
      checkfor(s_rbracket, "\']\' expected")
    }
    else
      skip;

    a := cons3(s_array, a, b)
  }
  else
  if (symbol = s_val)
  then
  { nextsymbol();
    a := rname();
    checkfor(s_eq, "\'=\' expected");
    b := rexpression();
    a := cons3(s_val, a, b)
  }
  else
    skip;
  checkfor(s_semicolon, "\';\' expected");
  return a
}

proc namemessage(s, x) is
{
  namemessage_internal(s, x); newline()
}

proc namemessage_internal(s, x) is
  var n;
  var p;
  var w;
  var l;
  var b;
{ prints(s);
  if (x.t0) = s_name
  then
  { n := 1;
    p := 2;
    w := x[p];
    l := rem(w, 256);
    w := div(w, 256);
    b := 1;
    while (n <= l) do
    { putval(rem(w, 256));
      w := div(w, 256);
      n := n + 1;
      b := b + 1;
      if (b = bytesperword)
      then
      { b := 0;
        p := p + 1;
        w := x[p]
      }
      else skip
    }
  }
  else skip
}

proc generror(s) is
{
  generror(s); newline()
}

proc generror_internal(s) is
{ namemessage_internal("error near ", procdef.t1);
  prints(":"); prints(s);
  errcount := errcount + 1
}

| translator |

proc declprocs(x) is
  if (x.t0) = s_semicolon
  then
  { declprocs(x.t1);
    declprocs(x.t2)
  }
  else
    var n := -1;
    {
      n := findname_internal(x.t1);

      |namemessage("adding proc ", x.t1);|

      if n < 0
      then
        addname(x, getlabel())
      else
      { names_d[n] := x;

        cmperror_internal("procedure already defined");
        namemessage_internal(" \'", x.t1);
        prints("\'");
        newline();

        addname(x, names_v[n])
      }
    }

proc declexports(x) is
  if (x.t0) = s_comma
  then
  { declexports(x.t1);
    declexports(x.t2)
  }
  else
    addname(x, getlabel())


proc declformals(x) is
  var op := x.t0;
  if op = s_null
  then
    skip
  else
  if op = s_comma
  then
  { declformals(x.t1);
    declformals(x.t2)
  }
  else
  { addname(x, stackp + pflag);
    stackp := stackp + 1
  }

func numgvars(n) is
  var op := n.t0;
  if op = s_module
  then
    return numgvars(n.t2) + numgvars(n.t3)
  else
  if op = s_scope
  then
    return numgvars(n.t1) + numgvars(n.t2)
  else
    if (op = s_var) or (op = s_array)
  then
    return 1
  else
    return 0

proc declglobal(x) is
  var op := x.t0;
  if (op = s_var)
  then
  { geng(0);
    addname(x, stackp);
    stackp := stackp + 1
  }
  else
  if (op = s_vari)
  then
    generror("error in global declaration")
  else
  if (op = s_val)
  then
  { x.t2 := optimiseexpr(x.t2);
    if isval(x.t2)
    then
      addname(x, getval(x.t2))
    else
      generror("constant expression expected")
  }
  else
  if (op = s_array)
  then
  { x.t2 := optimiseexpr(x.t2);
    if isval(x.t2)
    then
    { arraybase := arraybase - getval(x.t2);
      geng(arraybase);
      addname(x, stackp);
      stackp := stackp + 1
    }
    else
      generror("constant expression expected")
  }
  else
    skip

proc addname(x, v) is
{ names_d[namep] := x;
  names_v[namep] := v;
  namep := namep + 1
}


proc setprocused(x) is
{
  if isprocused(x)
  then
    skip
  else
  {
    procs_u[procs_uc] := x;
    procs_uc := procs_uc + 1
  }
}

func isprocused(x) is
  var n;
  var found;
{
  n := 0;
  found := false;

  while ((n < procs_uc) and (found = false))
  do
  {
    if (procs_u[n]) = x
    then
    {
      found := true
    }
    else
      n := n + 1
  };

  return found
}

func findname(x) is
  var n;
{
  n := findname_internal(x);

  if n < 0
  then
  {
    generror_internal(" ");
    namemessage("name not declared ", x)
  }
  else
    skip;

  return n
}

func findname_internal(x) is
  var n := namep - 1;
  var found := false;
{ while ((found = false) and (n >= 0)) do
  { if (names_d[n].t1) = x
    then
      found := true
    else
      n := n - 1
  };

  if found
  then
    skip
  else
  {
    n := -1
  };

  return n
}

func islocal(n) is
  return n >= nameb

proc optimise(x) is
  var op;
  var d;
  var np;
{ op := x.t0;
  if (op = s_scope)
  then
   { np := namep;
    d := x.t1;
    if (d.t0) = s_val
    then
    { d.t2 := optimiseexpr(d.t2);
      if isval(d.t2)
      then
        addname(d, getval(d.t2))
      else
        generror("constant expression expected")
    }
    else
    if (d.t0) = s_vari
    then
    { d.t2 := optimiseexpr(d.t2);
      addname(d, 0)
    }
    else
    if (d.t0) = s_var
    then
      addname(d, 0)
    else
    if (d.t0) = s_array
    then
    { d.t2 := optimiseexpr(d.t1);
      addname(d, 0)
    }
    else
      skip;
    optimise(x.t2);
    namep := np
  }
  else
  if (op = s_skip) or (op = s_stop)
  then
    skip
  else
  if (op = s_return)
  then
    x.t1 := optimiseexpr(x.t1)
  else
  if (op = s_if)
  then
  { x.t1 := optimiseexpr(x.t1);
    optimise(x.t2);
    optimise(x.t3)
  }
  else
  if (op = s_while)
  then
  { x.t1 := optimiseexpr(x.t1);
    optimise(x.t2)
  }
  else
  if (op = s_ass)
  then
  { x.t2 := optimiseexpr(x.t2);
    x.t1 := optimiseexpr(x.t1)
  }
  else
  if (op = s_pcall)
  then
  { x.t2 := optimiseexpr(x.t2);
    x.t1 := optimiseexpr(x.t1)
  }
  else
  if (op = s_semicolon)
  then
  { optimise(x.t1);
    optimise(x.t2)
  }
  else skip
}

func optimiseexpr(x) is
  var op;
  var name;
  var r;
  var temp;
  var left;
  var right;
  var leftop;
  var rightop;
{ r := x;
  op := x.t0;
  if (op = s_name)
  then
  { name := findname(x);
    if (names_d[name].t0) = s_val
    then
      r := names_d[name].t2
    else skip
  }
  else
  if (monadic(op))
  then
  { x.t1 := optimiseexpr(x.t1);
    if (isval(x.t1))
    then
    { x.t1 := evalmonadic(x);
      x.t0 := s_number
    }
    else
    if op = s_neg
    then
      r := cons3(s_minus, zeronode, x.t1)
    else
      skip
  }
  else
  if (op = s_fncall)
  then
  { x.t2 := optimiseexpr(x.t2);
    x.t1 := optimiseexpr(x.t1)
  }
  else
  if (diadic(op))
  then
  { x.t2 := optimiseexpr(x.t2);
    x.t1 := optimiseexpr(x.t1);
    left := x.t1;
    right := x.t2;
    leftop := left.t0;
    rightop := right.t0;
    if (op = s_sub) or (op = s_dot)
    then
      skip
    else
    if (isval(left) and isval(right))
    then
    { x.t1 := evaldiadic(x);
      x.t0 := s_number
    }
    else
    if (op = s_eq)
    then
    { if (leftop = s_not) and (rightop = s_not)
      then
      { x.t1 := left.t1;
        x.t2 := right.t1
      }
      else skip
    }
    else
    if (op = s_ne)
    then
    { x.t0 := s_eq;
      r := cons2(s_not, x);
      if (leftop = s_not) and (rightop = s_not)
      then
      { x.t1 := left.t1;
        x.t2 := right.t1
      }
      else skip
    }
    else
    if (op = s_ge)
    then
    { x.t0 := s_ls;
      r := cons2(s_not, x)
    }
    else
    if (op = s_gr)
    then
    { temp := x.t1;
      x.t1 := x.t2;
      x.t2 := temp;
      x.t0 := s_ls
    }
    else
    if (op = s_le)
    then
    { temp := x.t1;
      x.t1 := x.t2;
      x.t2 := temp;
      x.t0 := s_ls;
      r := cons2(s_not, x)
    }
    else
    if ((op = s_or) or (op = s_and))
    then
    { if (leftop = s_not) and (rightop = s_not)
      then
      { r := cons2(s_not, x);
        if (x.t0) = s_and
        then
          x.t0 := s_or
        else
          x.t0 := s_and;
        x.t1 := left.t1;
        x.t2 := right.t1
      }
      else
        skip
    }
    else
    if ((op = s_plus) or (op = s_or)) and (iszero(x.t1) or iszero(x.t2))
    then
    { if (iszero(x.t1))
      then
        r := x.t2
      else
      if (iszero(x.t2))
      then
        r := x.t1
      else skip
    }
    else
    if (op = s_minus) and iszero(x.t2)
    then
      r := x.t1
    else skip
  }
  else
  if (op = s_comma)
  then
  { x.t2 := optimiseexpr(x.t2);
    x.t1 := optimiseexpr(x.t1)
  }
  else skip;
  return r
}

func isval(x) is
  var op;
{ op := x.t0;
  return (op = s_true) or (op = s_false) or (op = s_number)
}

func getval(x) is
  var op;
{ op := x.t0;
  if (op = s_true)
  then
    return 1
  else
  if (op = s_false)
  then
    return 0
  else
  if (op = s_number)
  then
    return x.t1
  else
    return 0
}

func evalmonadic(x) is
  var op;
  var opd;
{ op := x.t0;
  opd := getval(x.t1);
  if (op = s_neg)
  then
    return - opd
  else
  if (op = s_not)
  then
    return ~ opd
  else
  { generror("compiler error");
    return 0
  }
}

func evaldiadic(x) is
  var op;
  var left;
  var right;
{ op := x.t0;
  left := getval(x.t1);
  right := getval(x.t2);
  if (op = s_plus)
  then
      return left + right
  else
  if (op = s_minus)
  then
      return left - right
  else
  if (op = s_eq)
  then
      return left = right
  else
  if (op = s_ne)
  then
      return left ~= right
  else
  if (op = s_ls)
  then
      return left < right
  else
  if (op = s_gr)
  then
      return left > right
  else
  if (op = s_le)
  then
      return left <= right
  else
  if (op = s_ge)
  then
      return left >= right
  else
  if (op = s_or)
  then
      return left or right
  else
  if (op = s_and)
  then
      return left and right
  else
  { cmperror("optimise error");
    return 0
  }
}


proc translate(t) is

{ namep := 0;
  nameb := 0;

  labelcount := 1;
  initlabels();

  initbuffer(numgvars(t) + 1);

  arraybase := maxaddr;
  stk_init(m_sp + 1);

  initsp(arraybase - 2);
  gen(cbf_constp, 0, 0);

  tprog(t);

  flushbuffer()
}

proc tmodule(x) is
  if (x.t0) = s_scope
  then
  { declglobal(x.t1);
    tmodule(x.t2)
  }
  else
  { declprocs(x);
    nameb := namep;
    genprocs(x)
  }

proc tprog(x) is
  if (x.t0) = s_scope
  then
  { declglobal(x.t1);
    tprog(x.t2)
  }
  else
  {
    if (x.t0) = s_module
    then
    { namem := namep;
      declexports(x.t1);
      nameg := namep;
      tmodule(x.t2);
      tprog(x.t3);
      namep := nameg
    }
    else
    {
      genmain(x)
    }
  }

proc genmain(x) is
  var link;
  var mainlab;
{ declprocs(x);
  nameb := namep;
  entrylab := getlabel();
  mainlab := getlabel();
  link := getlabel();
  setlab(entrylab);
  genref(i_ldap, link);
  genref(i_br, mainlab);
  setlab(link);

  geni(i_ldai, 1);
  geni(i_br, -2);

  setlab(mainlab);

  setprocused(x.t1);
  namemessage("main function: ", x.t1);
  genprocs(x)
}

proc genprocs(x) is
  var body;
  var savetreep;
  var pn;
{ if (x.t0) = s_semicolon
  then
  { genprocs(x.t1);
    genprocs(x.t2)
  }
  else
  { savetreep := treep;
    namep := nameb;

    pn := findname(x.t1);
    proclabel := names_v[pn];
    procdef := names_d[pn];

    if isprocused(procdef.t1)
    then
    {
      |namemessage("generating ", procdef.t1);|

      infunc := (procdef.t0) = s_func;
      body := x.t3;
      stk_init(1);
      declformals(x.t2);
      setlab(proclabel);
      genentry();
      stk_init(1);
      setstack();
      optimise(body);
      genstatement(body, true, 0, true);
      genexit();
      treep := savetreep
    }
    else
      |skip|
      namemessage("skipping ", procdef.t1)
  }
}

func funtail(tail) is
  return infunc and tail

proc genstatement(x, seq, clab, tail) is
  var op;
  var op1;
  var lab;
  var np;
  var sp;
  var thenpart;
  var elsepart;
  var elselab;
{ op := x.t0;
  if (op = s_scope)
  then
  { np := namep;
    sp := stackp;
    op1 := x.t1;
    if (op1.t0) = s_val
    then
      skip
    else
    if (op1.t0) = s_var
    then
    { addname(op1, stackp);
      stackp := stackp + 1;
      setstack()
    }
    else
    if (op1.t0) = s_vari
    then
    { texp(op1.t2);
      addname(op1, stackp);
      stackp := stackp + 1;
      setstack();
      geni(i_ldbm, m_sp);
      gensref(i_stai, sp)
    }
    else
    if (op1.t0) = s_array
    then
    { geni(i_ldbm, m_sp);
      geni(i_ldac, stackp + 1);
      geni(i_opr, o_add);
      geni(i_stai, stackp);
      addname(op1, stackp);
      stackp := stackp + getval(op1.t1) + 1;
      setstack()
    }
    else cmperror("error in declaration");
    genstatement(x.t2, seq, clab, tail);
    stackp := sp;
    namep := np
  }
  else
  if (op = s_semicolon)
  then
  { genstatement(x.t1, true, 0, false);
    genstatement(x.t2, seq, clab, tail)
  }
  else
  if (op = s_if) and (clab = 0)
  then
  { lab := getlabel();
    genstatement(x, true, lab, tail);
    setlab(lab)
  }
  else
  if op = s_if
  then
  { thenpart := x.t2;
    elsepart := x.t3;
    if (~ funtail(tail)) and (((thenpart.t0)=s_skip) or ((elsepart.t0)=s_skip))
    then
    { gencondjump(x.t1, (thenpart.t0) = s_skip, clab);
      if (thenpart.t0) = s_skip
      then
        genstatement(elsepart, seq, clab, tail)
      else
        genstatement(thenpart, seq, clab, tail)
    }
    else
    { elselab := getlabel();
      gencondjump(x.t1, false, elselab);
      genstatement(thenpart, false, clab, tail);
      setlab(elselab);
      genstatement(elsepart, seq, clab, tail)
    }
  }
  else
  if funtail(tail)
  then
    if op = s_return
    then
    { texp(x.t1);
      genbr(seq, clab)
    }
    else
      generror("\"return\" expected")
  else
  if (op = s_while) and (clab = 0)
  then
  { lab := getlabel();
    genstatement(x, false, lab, false);
    setlab(lab)
  }
  else
  if (op = s_while)
  then
  { lab := getlabel();
    setlab(lab);
    gencondjump(x.t1, false, clab);
    genstatement(x.t2, false, lab, false)
  }
  else
  if (op = s_stop)
  then
  { geni(i_ldai, 1);
    geni(i_br, -2)
  }
  else
  { if (op = s_skip)
    then
      skip
    else
    if (op = s_ass)
    then
      genassign(x.t1, x.t2)
    else
    if (op = s_pcall)
    then
      tcall(x, false)
    else
    if op = s_return
    then
      generror("misplaced \"return\"")
    else
      skip;
    genbr(seq, clab)
  }
}

proc tbool(x, cond) is
  var op;
  var lab;
{ op := x.t0;
  if (op = s_not)
  then
    tbool(x.t1, ~cond)
  else
  if (op = s_and) or (op = s_or)
  then
  { lab := getlabel();
    gencondjump(x, cond, lab);
    geni(i_ldac, 0);
    geni(i_br, 1);
    setlab(lab);
    geni(i_ldac, 1)
  }
  else
  if op = s_eq
  then
  { if iszero(x.t1)
    then
      texp(x.t2)
    else
    if iszero(x.t2)
    then
      texp(x.t1)
    else
      texp2(s_minus, x.t1, x.t2);
    if cond
    then
    { geni(i_brz, 2);
      geni(i_ldac, 0);
      geni(i_br, 1);
      geni(i_ldac, 1)
    }
    else
    { geni(i_brz, 1);
      geni(i_ldac, 1)
    }
  }
  else
  if op = s_ls
  then
  { if iszero(x.t2)
    then
      texp(x.t1)
    else
      texp2(s_minus, x.t1, x.t2);
    if cond
    then
    { geni(i_brn, 2);
      geni(i_ldac, 0);
      geni(i_br, 1);
      geni(i_ldac, 1)
    }
    else
    { geni(i_brn, 2);
      geni(i_ldac, 1);
      geni(i_br, 1);
      geni(i_ldac, 0)
    }
  }
  else
  { texp(x);
    if cond
    then
      skip
    else
    { geni(i_brz, 2);
      geni(i_ldac, 0);
      geni(i_br, 1);
      geni(i_ldac, 1)
    }
  }
}

proc gencondjump(x, cond, target) is
  var op;
  var lab;
{ op := x.t0;
  if (op = s_not)
  then
    gencondjump(x.t1, ~cond, target)
  else
  if (op = s_and) or (op = s_or)
  then
    if ((op = s_and) and cond) or ((op = s_or) and (~cond))
    then
    { lab := getlabel();
      gencondjump(x.t1, ~cond, lab);
      gencondjump(x.t2, cond, target);
      setlab(lab)
    }
    else
    { gencondjump(x.t1, cond, target);
      gencondjump(x.t2, cond, target)
    }
  else
  if op = s_eq
  then
  { if iszero(x.t1)
    then
      texp(x.t2)
    else
    if iszero(x.t2)
    then
      texp(x.t1)
    else
      texp2(s_minus, x.t1, x.t2);
    genjump(i_brz, cond, target)
  }
  else
  if op = s_ls
  then
  { if iszero(x.t2)
    then
      texp(x.t1)
    else
      texp2(s_minus, x.t1, x.t2);
    genjump(i_brn, cond, target)
  }
  else
  { texp(x);
    genjump(i_brz, ~cond, target)
  }
}

proc genjump(inst, cond, target) is
  var lab;
{ if cond
  then
    genref(inst, target)
  else
  { lab := getlabel();
    genref(inst, lab);
    genref(i_br, target);
    setlab(lab)
  }
}

proc tcall(x, fncall) is
  var sp;
  var entry;
  var actuals;
  var def;
  var n;
{ sp := stackp;
  actuals := x.t2;
  n := numps(actuals);
  if (n = 0) and fncall
  then
    tactuals(actuals, 1)
  else
    tactuals(actuals, n);
  if isval(x.t1)
  then
  { texp(x.t1);
    geni(i_opr, o_svc);
    if fncall
    then
    { geni(i_ldam, m_sp);
      geni(i_ldai, 1)
    }
    else
      skip
  }
  else
  { entry := findname(x.t1);
    gencall(entry, actuals);
    if fncall
    then
      geni(i_ldai, 1)
    else
      skip
  };
  stackp := sp
}

proc tactuals(aps, n) is
  var sp;
{ sp := stackp;
  preparecalls(aps);
  loadaps(aps, 1);
  stackp := stackp + n;
  setstack();
  stackp := sp;
  loadcalls(aps, 1);
  stackp := sp
}

func numps(x) is
  if (x.t0) = s_null
  then
    return 0
  else
  if (x.t0) = s_comma
  then
    return 1 + numps(x.t2)
  else
    return 1

proc gencall(entry, actuals) is
  var link;
  var def;
{ link := getlabel();
  genref(i_ldap, link);
  if islocal(entry)
  then
  { loadvar(r_breg, entry);
    geni(i_brb, 0)
  }
  else
  { def := names_d[entry];
    checkps(def.t2, actuals);
    genref(i_br, names_v[entry])
  };
  setlab(link)
}

proc preparecalls(x) is
  if (x.t0) = s_comma
  then
  { preparecalls(x.t2);
    preparecall(x.t1)
  }
  else
    preparecall(x)

proc preparecall(x) is
  var op;
  var vn;
  var sp;
{ op := x.t0;
  if op = s_null
  then
    skip
  else
  if containscall(x)
  then
  { sp := stackp;
    texp(x);
    stackp := stackp + 1;
    setstack();
    geni(i_ldbm, m_sp);
    gensref(i_stai, sp)
  }
  else
    skip
}

proc loadcalls(x, n) is
  if (x.t0) = s_comma
  then
  { loadcalls(x.t2, n + 1);
    loadcall(x.t1, n)
  }
  else
    loadcall(x, n)

proc loadcall(x, n) is
  var op;
  var vn;
  var sp;
{ op := x.t0;
  if op = s_null
  then
    skip
  else
  if containscall(x)
  then
  { geni(i_ldam, m_sp);
    gensref(i_ldai, stackp);
    stackp := stackp + 1;
    geni(i_ldbm, m_sp);
    geni(i_stai, n)
  }
  else
    skip
}

proc loadaps(x, n) is
  if (x.t0) = s_comma
  then
  { loadaps(x.t2, n + 1);
    loadap(x.t1, n)
  }
  else
    loadap(x, n)

proc loadap(x, n) is
  var op;
  var vn;
  var aptype;
{ op := x.t0;
  if op = s_null
  then
    skip
  else
  if containscall(x)
  then
    skip
  else
  { texp(x);
    geni(i_ldbm, m_sp);
    geni(i_stai, n)
  }
}

proc checkps(ax, fx) is
  if ((fx.t0) = s_comma) and ((ax.t0) = s_comma)
  then
    checkps(fx.t2, ax.t2)
  else
  if ((fx.t0) = s_comma) or ((ax.t0) = s_comma)
  then
    generror("parameter mismatch")
  else
    skip

func containscall(x) is
  var op;
{ op := x.t0;
  if op = s_null
  then
    return 0
  else
  if monadic(op)
  then
    return containscall(x.t1)
  else
  if diadic(op)
  then
    return containscall(x.t1) or containscall(x.t2)
  else
   return op = s_fncall
}

func iszero(x) is
  return isval(x) and (getval(x) = 0)

func immop(x) is
  var value;
{ value := getval(x);
  return isval(x) and (value > (-65536)) and (value < 65536)
}

func viabreg(x) is
  var op;
{ op := x.t0;
  if (op = s_sub) or (op = s_dot)
  then
    if isval(x.t2)
    then
      return viabreg(x.t1)
    else
      return false
  else
    return isval(x) or (op = s_string) or (op = s_name)
}

func regsfor(x) is
  var op;
  var rleft;
  var rright;
{ op := x.t0;
  if op = s_fncall
  then
    return 10
  else
  if monadic(op)
  then
    return regsfor(x.t1)
  else
  if diadic(op)
  then
  { rleft := regsfor(x.t1);
    rright := regsfor(x.t2);
    if rleft = rright
    then
      return 1 + rleft
    else
    if rleft > rright
    then
      return rleft
    else
      return rright
  }
  else
    return 1
}

proc loadbase(reg, base) is
  var name;
  var def;
  var op;
  var offset;
{ if isval(base)
  then
    loadconst(reg, getval(base))
  else
  { op := base.t0;
    if (op = s_sub) or (op = s_dot)
    then
    { loadbase(reg, base.t1);
      offset := getval(base.t2);
      if reg = r_areg
      then
        geni(i_ldai, offset)
      else
        geni(i_ldbi, offset)
    }
    else
    { name := findname(base);
      loadvar(reg, name)
    }
  }
}

proc genassign(left, right) is
  var sp;
  var leftop;
  var name;
  var base;
  var offset;
  var value;
{ leftop := left.t0;
  if leftop = s_name
  then
  { name := findname(left);
    texp(right);
    storevar(name)
  }
  else
  { base := left.t1;
    offset := left.t2;
    if viabreg(left)
    then
    { value := getval(offset);
      texp(right);
      loadbase(r_breg, base);
      geni(i_stai, value)
    }
    else
    { sp := stackp;
      texp2(s_plus, base, offset);
      stackp := stackp + 1;
      setstack();
      geni(i_ldbm, m_sp);
      gensref(i_stai, sp);
      texp(right);
      geni(i_ldbm, m_sp);
      gensref(i_ldbi, sp);
      geni(i_stai, 0);
      stackp := sp
    }
  }
}

proc geninput(ch, right) is
  var sp;
  var rightop;
  var name;
  var base;
  var offset;
  var value;
{ rightop := right.t0;
  if rightop = s_name
  then
  { name := findname(right);
    texp(ch);
    geni(i_opr, o_in);
    storevar(name)
  }
  else
  { base := right.t1;
    offset := right.t2;
    if viabreg(right)
    then
    { value := getval(offset);
      texp(ch);
      geni(i_opr, o_in);
      loadbase(r_breg, base);
      geni(i_stai, value)
    }
    else
    { sp := stackp;
      texp2(s_plus, base, offset);
      stackp := stackp + 1;
      setstack();
      geni(i_ldbm, m_sp);
      gensref(i_stai, sp);
      texp(ch);
      geni(i_opr, o_in);
      geni(i_ldbm, m_sp);
      gensref(i_ldbi, sp);
      geni(i_stai, 0);
      stackp := sp
    }
  }
}

proc genoutput(ch, x) is
  var sp;
{ if viabreg(ch)
  then
  { texp(x);
    tbexp(ch);
    geni(i_opr, o_out)
  }
  else
  { sp := stackp;
    texp(ch);
    stackp := stackp + 1;
    setstack();
    geni(i_ldbm, m_sp);
    gensref(i_stai, sp);
    texp(x);
    geni(i_ldbm, m_sp);
    gensref(i_ldbi, sp);
    geni(i_opr, o_out);
    stackp := sp
  }
}

proc texp(x) is
  var op;
  var left;
  var right;
  var offs;
  var value;
  var def;
  var sp;
{ op := x.t0;
  if isval(x)
  then
  { value := getval(x);
    loadconst(r_areg, value)
  }
  else
  if op = s_string
  then
    genstring(x)
  else
  if op = s_comma
  then
    gentable(x)
  else
  if (op = s_name)
  then
  { left := findname(x);
    def := names_d[left];
    if (def.t0) = s_val
    then
      loadconst(r_areg, names_v[left])
    else
    if ((def.t0)= s_var) or ((def.t0)= s_vari) or ((def.t0) = s_array)
    then
      loadvar(r_areg, left)
    else
    if ((def.t0) = s_proc) or ((def.t0) = s_func)
    then
      genref(i_ldap, names_v[left])
    else
      skip
  }
  else
  if (op = s_not) or (op = s_and) or (op = s_or) or (op = s_eq) or (op = s_ls)
  then
    tbool(x, true)
  else
  if (op = s_sub) or (op = s_dot)
  then
  { left := x.t1;
    if isval(x.t2)
    then
    { texp(left);
      value := getval(x.t2);
      geni(i_ldai, value)
    }
    else
    { texp2(s_plus, x.t1, x.t2);
      geni(i_ldai, 0)
    }
  }
  else
  if op = s_fncall
  then
    tcall(x, true)
  else
    texp2(op, x.t1, x.t2)
}

proc texp2(op, op1, op2) is
  var left;
  var right;
  var sp;
{ left := op1;
  right := op2;
  if (op = s_plus) and (regsfor(left) < regsfor(right))
  then
  { left := op2;
    right := op1
  }
  else
    skip;
  if viabreg(right)
  then
  { texp(left);
    tbexp(right)
  }
  else
  { sp := stackp;
    texp(right);
    stackp := stackp + 1;
    setstack();
    geni(i_ldbm, m_sp);
    gensref(i_stai, sp);
    texp(left);
    geni(i_ldbm, m_sp);
    gensref(i_ldbi, sp);
    stackp := sp
  };
  if (op = s_plus)
  then
    geni(i_opr, o_add)
  else
  if (op = s_minus)
  then
    geni(i_opr, o_sub)
  else
    skip
}

proc tbexp(x) is
  var op;
  var left;
  var value;
  var def;
{ op := x.t0;
  if isval(x)
  then
  { value := getval(x);
    loadconst(r_breg, value)
  }
  else
  if op = s_string
  then
    genstring(x)
  else
  if (op = s_sub) or (op = s_dot)
  then
  { loadbase(r_breg, x.t1);
    geni(i_ldbi, getval(x.t2))
  }
  else
  if (op = s_name)
  then
  { left := findname(x);
    def := names_d[left];
    if (def.t0) = s_val
    then
      loadconst(r_breg, names_v[left])
    else
      loadvar(r_breg, left)

  }
  else
    skip
}

proc stk_init(n) is
{ stackp := n;
  stk_max := n
}

proc setstack() is
  if stk_max < stackp
  then
    stk_max := stackp
  else
    skip

proc loadconst(reg, value) is
  if (value > (-65536)) and (value < 65536)
  then
  if reg = r_areg
  then
    geni(i_ldac, value)
  else
    geni(i_ldbc, value)
  else
    gen(cbf_const, reg, genconst(value))

proc loadvar(reg, vn) is
  var offs;
{ offs := names_v[vn];
  if islocal(vn)
  then
    if reg = r_areg
    then
    { geni(i_ldam, m_sp);
      gensref(i_ldai, offs)
    }
    else
    { geni(i_ldbm, m_sp);
      gensref(i_ldbi, offs)
    }
  else
    if reg = r_areg
    then
      geni(i_ldam, offs)
    else
      geni(i_ldbm, offs)
}

proc storevar(vn) is
  var offs;
{ offs := names_v[vn];
  if islocal(vn)
  then
  { geni(i_ldbm, m_sp);
    gensref(i_stai, offs)
  }
  else
    geni(i_stam, offs)
}

func monadic(op) is
  return (op = s_not) or (op = s_neg)

func diadic(op) is
  return (div(op, s_diadic) ~= 0)

proc geni(i, opd) is
  gen(cbf_inst, i, opd)

proc genref(inst, lab) is
  if labval[lab] = 0
  then
    gen(cbf_fwdref, inst, lab)
  else
    gen(cbf_bwdref, inst, lab)

proc gensref(i, offs) is
  gen(cbf_stack, i, offs)

proc genbr(seq, lab) is
  if seq
  then
    skip
  else
    genref(i_br, lab)


func genconst(n) is
  var i;
  var cp;
  var found;
{ found := false;
  i := 0;
  while ((i < constp) and (found = false)) do
    if (consts[i] = n)
    then
    { found := true;
      cp := i
    }
    else
      i := i + 1;
  if found
  then
    skip
  else
  { consts[constp] := n;
    cp := constp;
    constp := constp + 1
  };
  return cp
}

proc genstring(x) is
  var i;
  var sa;
  var sl;
{ sa := stringsize;
  sl := rem(x[1], 256);
  i := 0;
  while i <= div(sl, 4) do
  { strings[stringp] := x[i + 1];
    stringp := stringp + 1;
    i := i + 1
  };
  stringsize := stringsize + div(sl + 2, 2);
  gen(cbf_string, 0, sa)
}

proc gentable(x) is
  var tp;
{ tp := tablep;
  tablep := tablep + 1;
  gen(cbf_table, 0, tablesize);
  gentabvals(x);
  tables[tp] := tablep
}

proc gentabvals(x) is
  if (x.t0) = s_comma
  then
  { gentabvals(x.t1);
    gentabvals(x.t2)
  }
  else
  if isval(x)
  then
  { tables[tablep] := getval(x);
    tablesize := tablesize + 1;
    tablep := tablep + 1
  }
  else
    cmperror("non-constant in table")


proc gen(t, h, l) is
{ cb_loadpoint := cb_loadpoint + 1;
  codebuffer[cb_bufferp] := mul2(t, cb_flag) + mul2(h, cb_high) + (l + 65536);
  cb_bufferp := cb_bufferp + 1;
  if (cb_bufferp = cb_size)
  then
    generror("code buffer overflow")
  else skip
}

proc geng(gv) is
{ codebuffer[cb_buffergp] := mul2(cbf_var, cb_flag) + (gv + 65536);
  cb_buffergp := cb_buffergp + 1
}

proc initsp(gv) is
  codebuffer[0] := mul2(cbf_var, cb_flag) + (gv + 65536)


proc initlabels() is
  var l;
{ l := 0;
  while l < labval_size do
  { labval[l] := 0;
    l := l + 1
  }
}

func getlabel() is
{ if labelcount < labval_size
  then
    labelcount := labelcount + 1
  else
    generror("too many labels");
  return labelcount
}

proc setlab(l) is
{ labval[l] := cb_loadpoint;
  gen(cbf_lab, 0, l)
}

proc genentry() is
{ cb_entryinstp := cb_bufferp;
  gen(cbf_entry, 0, 0)
}

proc genexit() is
{ cb_setlow(cb_entryinstp, stk_max);
  if (procdef.t0) = s_proc
  then
    gen(cbf_pexit, 0, 0)
  else
    gen(cbf_fnexit, 0, 0)
}

proc initbuffer(n) is
{ cb_loadpoint := n;
  constp := 0;
  tablep := 0;
  tablesize := 0;
  stringp := 0;
  stringsize := 0;
  cb_bufferp := n;
  cb_buffergp := 1
}

proc cb_unpack(p) is
  var x;
{ x := codebuffer[p];
  cbv_flag := div(x, cb_flag);
  x := rem(x, cb_flag);
  cbv_high := div(x, cb_high);
  x := rem(x, cb_high) - 65536;
  cbv_low := x
}

proc cb_setlow(p, f) is
  var t;
{ t := div(codebuffer[p], cb_high);
  codebuffer[p] := mul2(t, cb_high) + (f + 65536)
}

func instlength(opd) is
  var v;
  var n;
{ if (opd >= 0) and (opd < 16)
  then
    n := 1
  else
  { n := 8;
    if opd < 0
    then
    { v := mul2(div(opd, 256), 256);
      while div(v, #10000000) = #F do
      { v := mul2(v, 16);
        n := n - 1
      }
    }
    else
    { v := opd;
      while div(v, #10000000) = 0 do
      { v := mul2(v, 16);
        n := n - 1
      }
    }
  };
  return n
}

func cb_laboffset(p) is
  return labval[cbv_low] - (cb_loadpoint + cb_reflength(p))

func cb_reflength(p) is
  var ilen;
  var labaddr;
{ ilen := 1;
  labaddr := labval[cbv_low];
  while ilen < instlength(labaddr - (cb_loadpoint + ilen)) do
    ilen := ilen + 1;
  return ilen
}

func cb_stackoffset(p, stksize) is
  var offs;
{ offs := cbv_low;
  if (offs - pflag) < 0
    then
      return (stksize - offs)
    else
      return stksize + (offs - pflag)
}

proc expand() is
  var bufferp;
  var offset;
  var stksize;
  var flag;
{ bufferp := 0;
  while bufferp < cb_bufferp do
  { cb_unpack(bufferp);
    flag := cbv_flag;
    if flag = cbf_constp
    then
    { cb_conststart := div(cb_loadpoint, 2);
      cb_tablestart := cb_conststart + constp;
      cb_stringstart := cb_tablestart + tablesize;
      cb_loadpoint := cb_loadpoint + mul2(constp, 2) + mul2(tablesize, 2) + mul2(stringsize, 2)
    }
    else
    if flag = cbf_entry
    then
    { stksize := cbv_low;
      cb_loadpoint := cb_loadpoint + instlength(- stksize) + 4
    }
    else
    if flag = cbf_pexit
    then
      cb_loadpoint := cb_loadpoint + mul2(instlength(stksize), 2) + 4
    else
    if flag = cbf_fnexit
    then
      cb_loadpoint := cb_loadpoint + mul2(instlength(stksize), 2) + instlength(stksize + 1) + 4
    else
    if flag = cbf_inst
    then
      cb_loadpoint := cb_loadpoint + instlength(cbv_low)
    else
    if flag = cbf_stack
    then
    { offset := cb_stackoffset(bufferp, stksize);
      cb_loadpoint := cb_loadpoint + instlength(offset)
    }
    else
    if flag = cbf_lab
    then
      labval[cbv_low] := cb_loadpoint
    else
    if flag = cbf_bwdref
    then
      cb_loadpoint := cb_loadpoint + cb_reflength(bufferp)
    else
    if flag = cbf_fwdref
    then
    { offset := cb_laboffset(bufferp);
      if offset > 0
      then
        cb_loadpoint := cb_loadpoint + cb_reflength(bufferp)
      else
        cb_loadpoint := cb_loadpoint + 1
    }
    else
    if flag = cbf_const
    then
    { offset := cbv_low + cb_conststart;
      cb_loadpoint := cb_loadpoint + instlength(offset)
    }
    else
    if flag = cbf_table
    then
    { offset := cbv_low + cb_tablestart;
      cb_loadpoint := cb_loadpoint + instlength(offset)
    }
    else
    if flag = cbf_string
    then
    { offset := cbv_low + cb_stringstart;
      cb_loadpoint := cb_loadpoint + instlength(offset)
    }
    else
    if flag = cbf_var
    then
      cb_loadpoint := cb_loadpoint + 2
    else
    { cmperror("code buffer error ");
      printn(bufferp); newline()
    };
    bufferp := bufferp + 1
  }
}

proc flushbuffer() is
  var bufferp;
  var last;
  var offset;
  var stksize;
  var flag;
  var loadstart;
{ loadstart := mul2(m_sp, 2);
  cb_loadpoint := loadstart;
  last := 0;
  expand();
  while cb_loadpoint ~= last do
  { last := cb_loadpoint;
    cb_loadpoint := loadstart;
    expand()
  };
  codesize := cb_loadpoint;
  lowbyte := true;
  outhdr();
  bufferp := 0;
  cb_loadpoint := loadstart;
  while bufferp < cb_bufferp do
  { cb_unpack(bufferp);
    flag := cbv_flag;
    if flag = cbf_constp
    then
    { cb_conststart := div(cb_loadpoint, 2);
      cb_tablestart := cb_conststart + constp;
      cb_stringstart := cb_tablestart + tablesize;
      cb_loadpoint := cb_loadpoint + mul2(constp, 2) + mul2(tablesize, 2) + mul2(stringsize, 2);
      outconsts();
      outtables();
      outstrings()
    }
    else
    if flag = cbf_entry
    then
    { stksize := cbv_low;
      outinst(i_ldbm, m_sp);
      outinst(i_stai, 0);
      outinst(i_ldac, (-stksize));
      outinst(i_opr, o_add);
      outinst(i_stam, m_sp);
      cb_loadpoint := cb_loadpoint + instlength(- stksize) + 4
    }
    else
    if flag = cbf_pexit
    then
    { outinst(i_ldbm, m_sp);
      outinst(i_ldac, stksize);
      outinst(i_opr, o_add);
      outinst(i_stam, m_sp);
      outinst(i_ldbi, stksize);
      outinst(i_brb, 0);
      cb_loadpoint := cb_loadpoint + mul2(instlength(stksize), 2) + 4
    }
    else
    if flag = cbf_fnexit
    then
    { outinst(i_ldbm, m_sp);
      outinst(i_stai, stksize + 1);
      outinst(i_ldac, stksize);
      outinst(i_opr, o_add);
      outinst(i_stam, m_sp);
      outinst(i_ldbi, stksize);
      outinst(i_brb, 0);
      cb_loadpoint := cb_loadpoint + mul2(instlength(stksize), 2) + instlength(stksize + 1) + 4
    }
    else
    if flag = cbf_inst
    then
    { outinst(cbv_high, cbv_low);
      cb_loadpoint := cb_loadpoint + instlength(cbv_low)
    }
    else
    if flag = cbf_stack
    then
    { offset := cb_stackoffset(bufferp, stksize);
      outinst(cbv_high, offset);
      cb_loadpoint := cb_loadpoint + instlength(offset)
    }
    else
      if flag = cbf_lab
    then
      skip
    else
    if (flag = cbf_bwdref) or (flag = cbf_fwdref)
    then
    { offset := cb_laboffset(bufferp);
      outinst(cbv_high, offset);
      cb_loadpoint := cb_loadpoint + cb_reflength(bufferp)
    }
    else
    if flag = cbf_const
    then
    { offset := cbv_low + cb_conststart;
      if cbv_high = r_areg
      then
        outinst(i_ldam, offset)
      else
        outinst(i_ldbm, offset);
      cb_loadpoint := cb_loadpoint + instlength(offset)
    }
    else
    if flag = cbf_table
    then
    { offset := cbv_low + cb_tablestart;
      outinst(i_ldac, offset);
      cb_loadpoint := cb_loadpoint + instlength(offset)
    }
    else
    if flag = cbf_string
    then
    { offset := cbv_low + cb_stringstart;
      outinst(i_ldac, offset);
      cb_loadpoint := cb_loadpoint + instlength(offset)
    }
    else
    if flag = cbf_var
    then
    { outvar(cbv_low);
      cb_loadpoint := cb_loadpoint + 2
    }
    else
      skip;
    bufferp := bufferp + 1
  }
}

proc outinst(inst, opd) is
  var v;
  var n;
{ if (opd >= 0) and (opd < 16)
  then
    out1(inst, opd)
  else
  { n := 28;
    if opd < 0
    then
    { v := mul2(div(opd, 256), 256);
      while div(v, #10000000) = #F do
      { v := mul2(v, 16);
        n := n - 4
      };
      out1(i_nfix, div(opd, exp2(n)));
      n := n - 4
    }
    else
    { v := opd;
      while div(v, #10000000) = 0 do
      { v := mul2(v, 16);
        n := n - 4
      }
    };
    while n > 0 do
    { out1(i_pfix, div(opd, exp2(n)));
      n := n - 4
    };
    out1(inst, opd)
  }
}

proc outconsts() is
  var count;
{ count := 0;
  while (count < constp) do
  { out2(consts[count]);
    count := count + 1
  }
}

proc outtables() is
  var count;
  var top;
{ count := 0;
  while (count < tablep) do
  { top := tables[count];
    count := count + 1;
    while count < top do
    { out2(tables[count]);
      count := count + 1
    }
  }
}


proc outstrings() is
  var count;
  var bytes;
  var b;
{ while (count < stringp) do
  { bytes := rem(strings[count], 256) + 1;
    b := 0;
    while b < bytes do
    { out2(strings[count]);
      b := b + 2;
      if b < bytes
      then
      { out2(div(strings[count], 65536));
        b := b + 2
      }
      else
        skip;
      count := count + 1
    }
  }
}

proc outvar(d) is
  out2(d)

proc out2(x) is
{ outbin(x);
  outbin(div(x, #100))
}

proc out1(inst, opd) is
  outbin(mul2(inst, 16) + rem(opd, 16))

proc outbin(d) is
  var b;
{ if lowbyte
  then selectoutput(binstreaml)
  else selectoutput(binstreamh);
  b := rem(d, 256);
  puthex(div(b, 16));
  puthex(rem(b, 16));
  putval(' ');
  lowbyte := ~ lowbyte;
  selectoutput(messagestream)
}

proc puthex(d) is
  if d < 10
  then
    putval(d + '0')
  else
    putval((d - 10) + 'A')


proc outhdr() is
  var entrypoint;
  var offset;
{ entrypoint := labval[entrylab];
  offset := entrypoint - 4;
  out1(i_pfix, div(offset, #1000));
  out1(i_pfix, div(offset, #100));
  out1(i_pfix, div(offset, #10));
  out1(i_br, offset)
}
