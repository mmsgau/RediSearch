#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "parser.h"
#include "expression.h"
#include "exprast.h"

#include "token.h"

/* forward declarations of stuff generated by lemon */
void RSExprParser_Parse(void *yyp, int yymajor, RSExprToken yyminor, RSExprParseCtx *ctx);
void *RSExprParser_ParseAlloc(void *(*mallocProc)(size_t));
void RSExprParser_ParseFree(void *p, void (*freeProc)(void *));

%%{

machine expr;

inf = ['+\-']? 'inf' $ 3;
number = '-'? digit+('.' digit+)? (('E'|'e') '-'? digit+)? $ 2;

lp = '(';
rp = ')';
minus = '-';
plus = '+';
div = '/';
times = '*';
mod = '%';
pow = '^';
comma = ',';
escape = '\\';
quote = '"';
squote = "'";
eq = '==';
not = '!';

ne = '!=';
lt = '<';
le = '<=';
gt = '>';
ge = '>=';
land = '&&';
lor = '||';
escaped_character = escape (punct | space | escape);
string_literal =	(quote . ((any - quote - '\n' )|escaped_character)* . quote) | (squote . ((any - squote - '\n' )|escaped_character)* . squote);
symbol = alpha.(alnum|'_')* $0;
property = '@'.(((any - (punct | cntrl | space | escape)) | escaped_character) | '_')+ $ 1;

main := |*

  number => { 
    tok.s = ts;
    tok.len = te-ts;
    char *ne = (char*)te;
    tok.numval = strtod(tok.s, &ne);
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, NUMBER, tok, &ctx);
    if (!ctx.ok) {
      fbreak;
    }
    
  };

  property => {
    tok.pos = ts-ctx.raw;
    tok.len = te - (ts + 1);
    tok.s = ts+1;
    RSExprParser_Parse(pParser, PROPERTY, tok, &ctx);
    if (!ctx.ok) {
      fbreak;
    }
  };

  symbol => {
    tok.pos = ts-ctx.raw;
    tok.len = te - ts;
    tok.s = ts;
    RSExprParser_Parse(pParser, SYMBOL, tok, &ctx);
    if (!ctx.ok) {
      fbreak;
    }
  };
  
  inf => { 
    tok.pos = ts-ctx.raw;
    tok.s = ts;
    tok.len = te-ts;
    
    tok.numval = *ts == '-' ? -INFINITY : INFINITY;
    RSExprParser_Parse(pParser, NUMBER, tok, &ctx);
    if (!ctx.ok) {
      fbreak;
    }
  };

  lp => { 
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, LP, tok, &ctx);
    if (!ctx.ok) {
      fbreak;
    }
  };
  
  rp => { 
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, RP, tok, &ctx);
    if (!ctx.ok) {
      fbreak;
    }
  };

  minus =>  { 
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, MINUS, tok, &ctx);  
    if (!ctx.ok) {
      fbreak;
    }
  };
  lt =>  { 
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, LT, tok, &ctx);  
    if (!ctx.ok) {
      fbreak;
    }
  };
  le =>  { 
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, LE, tok, &ctx);  
    if (!ctx.ok) {
      fbreak;
    }
  };
  gt =>  { 
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, GT, tok, &ctx);  
    if (!ctx.ok) {
      fbreak;
    }
  };
   ge =>  { 
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, GE, tok, &ctx);  
    if (!ctx.ok) {
      fbreak;
    }
  };
   eq =>  { 
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, EQ, tok, &ctx);  
    if (!ctx.ok) {
      fbreak;
    }
  };
  not =>  { 
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, NOT, tok, &ctx);  
    if (!ctx.ok) {
      fbreak;
    }
  };
   ne =>  { 
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, NE, tok, &ctx);  
    if (!ctx.ok) {
      fbreak;
    }
  };
   land =>  { 
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, AND, tok, &ctx);  
    if (!ctx.ok) {
      fbreak;
    }
  };
    lor =>  { 
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, OR, tok, &ctx);  
    if (!ctx.ok) {
      fbreak;
    }
  };

  plus =>  { 
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, PLUS, tok, &ctx);  
    if (!ctx.ok) {
      fbreak;
    }
  };
  mod =>  { 
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, MOD, tok, &ctx);  
    if (!ctx.ok) {
      fbreak;
    }
  };
  pow =>  { 
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, POW, tok, &ctx);  
    if (!ctx.ok) {
      fbreak;
    }
  };
  div =>  { 
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, DIVIDE, tok, &ctx);  
    if (!ctx.ok) {
      fbreak;
    }
  };
 
  times => { 
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, TIMES, tok, &ctx);    
    if (!ctx.ok) {
      fbreak;
    }
  }; 
  comma => { 
    tok.pos = ts-ctx.raw;
    RSExprParser_Parse(pParser, COMMA, tok, &ctx);  
    if (!ctx.ok) {
      fbreak;
    }
  };


  string_literal => {

    tok.len = te-ts;
    tok.s = ts;
    tok.numval = 0;
    tok.pos = ts-ctx.raw;

    RSExprParser_Parse(pParser, STRING, tok, &ctx);
    if (!ctx.ok) {
      fbreak;
    }
  };
  space;
  punct;
  cntrl;
*|;
}%%

%% write data;



RSExpr *RSExpr_Parse(const char *expr, size_t len, char **err) {
  RSExprParseCtx ctx = {
    .raw = expr,
    .len = len, 
    .errorMsg = NULL,
    .root = NULL,
    .ok = 1,
  };
  void *pParser = RSExprParser_ParseAlloc(rm_malloc);

  
  int cs, act;
  const char* ts = ctx.raw;
  const char* te = ctx.raw + ctx.len;
  %% write init;
#ifdef __cplusplus
  RSExprToken tok = {s: 0, len: 0, pos: 0, numval: 0};
#else
  RSExprToken tok = {.len = 0, .pos = 0, .s = 0, .numval = 0};
#endif
  
  //parseCtx ctx = {.root = NULL, .ok = 1, .errorMsg = NULL, .q = q};
  const char* p = ctx.raw;
  const char* pe = ctx.raw + ctx.len;
  const char* eof = pe;
  
  %% write exec;
  

  if (ctx.ok) {
    RSExprParser_Parse(pParser, 0, tok, &ctx);
  } else if (ctx.root) {
    RSExpr_Free(ctx.root);
    ctx.root = NULL;
  }
  RSExprParser_ParseFree(pParser, rm_free);
  if (err) {
    *err = ctx.errorMsg;
  }
 
  return ctx.root;
}

