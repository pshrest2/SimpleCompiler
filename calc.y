%{
#define YYDEBUG 1

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream> 

#include "calc.tab.h"

using namespace std;

// Control flow graph (CFG)
Graph* CFG;

// very first block
BasicBlock* beginBlock;

// declare a pointer to the current block
BasicBlock* currentBlock;

// declare a symbol table
SymbolTable symbolTable;

// structure of if_block_ids
typedef struct if_stmt_struct {
  BasicBlock* begin_block;
  BasicBlock* true_block;
  BasicBlock* end_block;
} if_stmt_blocks;

// structure of for_loop
typedef struct for_stmt_struct {
  BasicBlock* body_block;
  BasicBlock* end_block;
  BasicBlock* update_block;
} for_stmt_blocks;

if_stmt_blocks if_stmt;
for_stmt_blocks for_stmt;


extern int yylex();
extern void yyerror(string s);

int getRegister();
int getBlockID();

int registerCount = 0;
int blockCount = 0;


%}



%code requires {
  #include "utils/Operand.hpp"
  #include "utils/BasicBlock.hpp"
  #include "utils/Instruction.hpp"
  #include "utils/Type.hpp"
  #include "utils/SymbolTable.hpp"
  #include "utils/ControlFlowGraph.hpp" 
  #include "utils/VariableEntry.hpp"

  struct structure {
    Operand* op;
    char* var_name;
  };

  typedef structure decl_init_struct;

} 




%union {
  int val;
  char *identifier;
  Operand* operand_ptr;

  Type* type_ptr;
  decl_init_struct* decl_init_struct_ptr;
}

%token <val> NUM
%token<identifier>  TOK_ID

%token TOK_INT
%token TOK_RETURN
%token TOK_DECREMENT
%token TOK_INCREMENT
%token  TOK_CURLY_BRACE_CLOSE
%token  TOK_CURLY_BRACE_OPEN
%token TOK_SEMICOLON
%token TOK_IF
%nonassoc TOK_ELSE
%token TOK_FOR


%type  <operand_ptr> exp maybe_exp 
%type<identifier> lvalue    // char*

%type<operand_ptr> init               // Operand*
%type<decl_init_struct_ptr> init_list // Operand*

%type<type_ptr> type_name             // Type*
%type<type_ptr> type_spec             // Type*
%type<type_ptr> declarator            // Type*
%type<type_ptr> declarator_list       // Type*


%start input

%right  TOK_EQUAL TOK_ADD_EQUAL TOK_MINUS_EQUAL
  TOK_MULT_EQUAL TOK_DIV_EQUAL TOK_MOD_EQUAL 

%left   TOK_PLUS TOK_MINUS
%left   TOK_MULT TOK_DIV TOK_MOD
%left TOK_EQUALITY TOK_INEQUALITY
%left TOK_GREATER TOK_LESS TOK_GREATER_EQUAL TOK_LESS_EQUAL
%left   TOK_PAR_OPEN TOK_PAR_CLOSE

%left MINUS


%%

input : stmt_list
      | stmt_list input
      ;


lvalue: TOK_ID


stmt_list
  : /*empty*/
  | stmt_or_stmt_list stmt_list
  ;

stmt_or_stmt_list
  : stmt
  {

  }
  | TOK_CURLY_BRACE_OPEN stmt_list TOK_CURLY_BRACE_CLOSE
  {

  }
  ;

stmt
  : maybe_exp TOK_SEMICOLON
  {
    delete $1;
  }
  
  | declaration
  {
    // done!
  }

  | for_loop
  | if_stmt  
  ;

maybe_exp
  : /*empty*/
  {
    $$ = NULL;
  } 
  | exp
  {
    $$ = $1;
  }
  
  ;


init
  : /*empty*/
  {
    // declaration without initialization is not allowed
    yyerror("Error: Declaration without initialization");

    $$ = NULL;
  }
  
  | TOK_EQUAL exp
  {
    $$ = $2;  // return an operand*
  } 
  ;

init_list
  : TOK_ID init %prec TOK_MULT
  {
    // declare a block of decl_init_struct
    decl_init_struct *decl_init = (decl_init_struct*) malloc (sizeof(decl_init_struct));

    decl_init->op = $2;
    decl_init->var_name = $1;

    // return decl_init_struct pointer
    $$ = decl_init;   
  } 
  ;

declarator_list
  : declarator
  {
    $$ = $1;
  }
  | declarator_list declarator
  ;

declarator
  : type_spec 
  {
    $$ = $1;
  }
  ;

type_spec
  : type_name
  {
    $$ = $1;
  }


type_name
  : TOK_INT 
  {
    Type* type = new Type(Type::INT);
    $$ = type;
  }
  ;


//int a;
declaration
  : declarator_list init_list TOK_SEMICOLON
  {
    string var_name($2->var_name);
    Operand* op = $2->op;

    int assignedReg = 0;

    // check operand type
    if (op->getOperandType() == Operand::CONST || op->getOperandType() == Operand::MEM_ADDRESS){
      assignedReg = getRegister();

      // emit a LD instruction 
      Instruction inst(Instruction::LOAD, Operand(Operand::REGISTER, assignedReg), *op);

      // push back to current block
      currentBlock->pushBackInstruction(inst);      
    } else {
      // get the assigned reg
      assignedReg = op->getOperandValue();
    }

    // create an entry in symbol table
    if (!symbolTable.insertNewVariable(var_name, (*$1), assignedReg)){
      yyerror("Double declaration");
    } 
  
    delete $1;        // delete Type*
    free($2->var_name);     // free up the space allocated to store     
    free($2);       // free up the space for decl_init_struct
  }
  ;



//If Statement
if_stmt
  : if %prec TOK_PLUS
  {
    // emit jump without condition instruction
    Instruction inst(Instruction::JUMP, Operand(Operand::LABEL, if_stmt.end_block->blockID));

    // push it to the begin_block
    if_stmt.begin_block->pushBackInstruction(inst);

    // add blocks to graph
    CFG->addEdge(CFG->lastAddedBlockID, *(if_stmt.begin_block));
    CFG->addEdge(if_stmt.begin_block->blockID, *(if_stmt.true_block));

    // continue codes after if-statement
    currentBlock = if_stmt.end_block;

    delete if_stmt.begin_block;
    delete if_stmt.true_block;
  }
  | TOK_ELSE 
  {
    currentBlock = if_stmt.begin_block;
  }
  stmt_or_stmt_list %prec TOK_MULT    // all instructions here are added to begin_block
  {
    // emit jump without condition instruction
    Instruction inst(Instruction::JUMP, Operand(Operand::LABEL, if_stmt.end_block->blockID));

    // push it to the begin_block
    if_stmt.begin_block->pushBackInstruction(inst);

    // add blocks to graph
    CFG->addEdge(CFG->lastAddedBlockID, *(if_stmt.begin_block));
    CFG->addEdge(if_stmt.begin_block->blockID, *(if_stmt.true_block));

    // continue codes after if-statement
    currentBlock = if_stmt.end_block;

    delete if_stmt.begin_block;
    delete if_stmt.true_block;
  }
  ;

if
  :  TOK_IF TOK_PAR_OPEN exp TOK_PAR_CLOSE 
  { 
    /****** if condition part ******/
    if_stmt.begin_block = currentBlock; 

    if_stmt.true_block = new BasicBlock(getBlockID()); 

    // emit jump with condition instruction
    Instruction inst(Instruction::JUMP_TRUE, Operand(Operand::LABEL, if_stmt.true_block->blockID), *$3);

    // push it to the begin_block
    if_stmt.begin_block->pushBackInstruction(inst);

    // set currentBlock to true_block
    currentBlock = if_stmt.true_block;
    
    delete $3;
  }
  stmt_or_stmt_list   // all statements here are added to true_block
  {
    /***** if_true block ****/
    if_stmt.end_block = new BasicBlock(getBlockID());

    Instruction inst(Instruction::JUMP, Operand(Operand::LABEL, if_stmt.end_block->blockID));

    // push it to the true_block
    if_stmt.true_block->pushBackInstruction(inst);
  } 
  ;


//For Loop
for_loop
  : for_loop_header stmt_or_stmt_list
  {
    // jump from body_block to update_block
    Instruction inst1(Instruction::JUMP, Operand(Operand::LABEL, for_stmt.update_block->blockID));
    
    // push it into body_block
    for_stmt.body_block->pushBackInstruction(inst1);

    // jump back to body block
    Instruction inst2(Instruction::JUMP, Operand(Operand::LABEL, for_stmt.body_block->blockID));
    for_stmt.update_block->pushBackInstruction(inst2);  // currentBlock = update_block;

    // add the body block to the CFG
    CFG->addEdge(CFG->lastAddedBlockID, *(for_stmt.body_block));
    CFG->addEdge(CFG->lastAddedBlockID, *(for_stmt.update_block));    // from body_block -> update_block
    CFG->addEdge(CFG->lastAddedBlockID, *(for_stmt.body_block));
  
    // delete the body_block (currentBlock); 
    delete currentBlock;
    delete for_stmt.update_block;

    currentBlock = for_stmt.end_block;
  }
  
  ;


for_loop_header
  : TOK_FOR TOK_PAR_OPEN maybe_exp TOK_SEMICOLON
  {
    // create blocks for for_stmt
    for_stmt.body_block = new BasicBlock(getBlockID());
    for_stmt.update_block = new BasicBlock(getBlockID());
    for_stmt.end_block = new BasicBlock(getBlockID());

    /* Initialization */
    // emit a jump instruction to the body
    Instruction inst(Instruction::JUMP, Operand(Operand::LABEL, for_stmt.body_block->blockID));

    // push it to the current block
    currentBlock->pushBackInstruction(inst);

    // add the current block to the CFG
    CFG->addEdge(CFG->lastAddedBlockID, *currentBlock);
    delete currentBlock;

    currentBlock = for_stmt.body_block;
    
    if ($<operand_ptr>3 != NULL) delete $<operand_ptr>3;
  }
  
  maybe_exp TOK_SEMICOLON
  {
    /* Condition */
    if ($<operand_ptr>6 != NULL){
      // emit a jump with false condition 
      Instruction inst(Instruction::JUMP_FALSE, Operand(Operand::LABEL, for_stmt.end_block->blockID), *$<operand_ptr>6);

      // push it to the currentBlock (body_block)
      currentBlock->pushBackInstruction(inst);

      delete $<operand_ptr>6;
    }

    // before parsing the update block
    currentBlock = for_stmt.update_block;   

    // otherwise, no condition is provided
  }
  
  maybe_exp TOK_PAR_CLOSE
  {
    currentBlock = for_stmt.body_block;
    /* Update */
    if ($<operand_ptr>9 != NULL) delete $<operand_ptr>9;
  }
  
  | TOK_FOR TOK_PAR_OPEN declaration
  {
    yyerror("Does not support inline declartion in for-loop");
  }
  
  maybe_exp TOK_SEMICOLON
  
  maybe_exp TOK_PAR_CLOSE
  
  ;


exp:exp TOK_PLUS exp 
    { 
        // create destination operand
        Operand* dest = new Operand(Operand::REGISTER, getRegister());

        // emit comp instruction 
        Instruction inst(Instruction::ADD, *dest, *$1, *$3);

        // add instruction to current block
        currentBlock->pushBackInstruction(inst);

        // remove source operands
        delete $1;
        delete $3;

        // return destination operand
        $$ = dest;
    }

  | exp TOK_MINUS exp 
    { 
        Operand* dest = new Operand(Operand::REGISTER, getRegister());

        Instruction inst(Instruction::SUB, *dest, *$1, *$3);

        currentBlock->pushBackInstruction(inst);

        delete $1;
        delete $3;

        $$ = dest;
    }

  | exp TOK_MULT exp 
    { 
        Operand* dest = new Operand(Operand::REGISTER, getRegister());

        Instruction inst(Instruction::MUL, *dest, *$1, *$3);

        currentBlock->pushBackInstruction(inst);

        delete $1;
        delete $3;

        $$ = dest;
    }

  | exp TOK_DIV exp 
    { 
        Operand* dest = new Operand(Operand::REGISTER, getRegister());

        Instruction inst(Instruction::DIV, *dest, *$1, *$3);

        currentBlock->pushBackInstruction(inst);

        delete $1;
        delete $3;

        $$ = dest;    
    }

  | exp TOK_EQUALITY exp
  {
    // create destination operand
    Operand* dest = new Operand(Operand::REGISTER, getRegister());

    // emit comp instruction 
    Instruction inst(Instruction::EQUAL, *dest, *$1, *$3);

    // add instruction to current block
    currentBlock->pushBackInstruction(inst);

    // remove source operands
    delete $1;
    delete $3;

    // return destination operand
    $$ = dest;
  } 

  | exp TOK_INEQUALITY exp
  {
     // create destination operand
        Operand* dest = new Operand(Operand::REGISTER, getRegister());

        // emit comp instruction 
        Instruction inst(Instruction::INEQUAL, *dest, *$1, *$3);

        // add instruction to current block
        currentBlock->pushBackInstruction(inst);

        // remove source operands
        delete $1;
        delete $3;

        // return destination operand
        $$ = dest;
  }

  | exp TOK_LESS exp
  {
     // create destination operand
        Operand* dest = new Operand(Operand::REGISTER, getRegister());

        // emit comp instruction 
        Instruction inst(Instruction::LESS_THAN, *dest, *$1, *$3);

        // add instruction to current block
        currentBlock->pushBackInstruction(inst);

        // remove source operands
        delete $1;
        delete $3;

        // return destination operand
        $$ = dest;
  }
  
  | exp TOK_GREATER exp
  {
     // create destination operand
    Operand* dest = new Operand(Operand::REGISTER, getRegister());

    // emit comp instruction 
    Instruction inst(Instruction::GREATER_THAN, *dest, *$1, *$3);

    // add instruction to current block
    currentBlock->pushBackInstruction(inst);

    // remove source operands
    delete $1;
    delete $3;

    // return destination operand
    $$ = dest;
  }
  
  | exp TOK_LESS_EQUAL exp
  {
    // create destination operand
    Operand* dest = new Operand(Operand::REGISTER, getRegister());

    // emit comp instruction 
    Instruction inst(Instruction::LESS_EQUAL, *dest, *$1, *$3);

    // add instruction to current block
    currentBlock->pushBackInstruction(inst);

    // remove source operands
    delete $1;
    delete $3;

    // return destination operand
    $$ = dest;
  }
  
  | exp TOK_GREATER_EQUAL exp
  {
    // create destination operand
    Operand* dest = new Operand(Operand::REGISTER, getRegister());

    // emit comp instruction 
    Instruction inst(Instruction::GREATER_EQUAL, *dest, *$1, *$3);

    // add instruction to current block
    currentBlock->pushBackInstruction(inst);

    // remove source operands
    delete $1;
    delete $3;

    // return destination operand
    $$ = dest;
  }

  | lvalue TOK_EQUAL exp
  {
    string var_name($1);

    int lvalue_assigned_reg = symbolTable.getAssignedRegister(var_name);
      
    Operand* dest = new Operand(Operand::REGISTER, lvalue_assigned_reg);
    Operand* src_op = $3;

    // create an instruction 
    Instruction* inst;
  
    if (src_op->getOperandType() == Operand::CONST || src_op->getOperandType() == Operand::MEM_ADDRESS){
      inst = new Instruction(Instruction::LOAD, *dest, *src_op);
    } else {
      inst = new Instruction(Instruction::MOVE, *dest, *src_op);
    }

    // add inst to current block
    currentBlock->pushBackInstruction(*inst);

    delete src_op;
    delete inst;
    free($1);

    // return destination operand
    $$ = dest;
  }

  | NUM 
    {
        Operand *op = new Operand(Operand::CONST, $1);
        $$ = op;
    } 
  ;

%%

#include <stdio.h>

int main(void){
  beginBlock = new BasicBlock(0);

  // add it to the graph as a base block
  CFG = new Graph(*beginBlock);

  // create the current block
  currentBlock = new BasicBlock(getBlockID());

  // call parser
  yyparse();

  // add the current block to CFG
  CFG->addEdge(CFG->lastAddedBlockID, *currentBlock);

  CFG->dumpGraph();

  cout << "\n\n... Symbol table ... \n" << symbolTable.dumpSymbolTable() << endl;

  delete currentBlock;
  delete CFG;

  return 0;
}


int getRegister(){
    registerCount++;
    return registerCount;
}

int getBlockID(){
    blockCount++;
    return blockCount;
}

void yyerror(string s)
{
  fflush(stdout);
  cout << s << endl;

  exit(1);
}

















