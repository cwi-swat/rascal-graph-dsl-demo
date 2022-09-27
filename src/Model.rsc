module Model

import Syntax;
import ParseTree;

// imagine your own DSL/PL intermediate representations here:
//    * call graph
//    * control flow graph
//    * data flow graph
//    * type dependencies
//    * import graphs
//    * state machines
// |java+interface:///java/util/List|

// data TypeSymbol = \int();

data Model = model(
   Graph g,
   
   set[str] topNodes = { "<x>" | Node x <- g.top},

   rel[str from, str to] edges = {<"<from>", "<to>"> | /(Edge) `<Node from> -- <Node to>` := g},

   rel[str label, loc src] froms = {<"<from>", from.src> | /(Edge) `<Node from> -- <Node to>` := g} + { <"<x>",x.src> | Node x <- g.top},

   rel[str label, loc src] tos = {<"<to>", to.src> | /(Edge) `<Node from> -- <Node to>` := g},

   set[str] nodes = { from, to | <from, to> <- edges} + topNodes
);