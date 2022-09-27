module GraphLang

import IO;
import util::LanguageServer;
import util::IDEServices;
import util::Reflective;
import ParseTree;

import Visual;
import Model;
import Syntax; 

set[LanguageService] contributions() 
  = {
  parser(Tree (str input, loc src) {
        return parse(#start[Graph], input, src);
  })

  ,summarizer(Summary (loc l, start[Graph] g) {
     return graphSummarizer(l, g.top);
  })
  
  ,outliner(list[DocumentSymbol] (start[Graph] g) {
     return outline(g);
  })

  // ,outliner(list[DocumentSymbol] (start[Graph] g) {
  //    return simpleOutline(g);
  // })

  ,lenses(createLenses)
  ,executor(commandHandler)
};

list[DocumentSymbol] simpleOutline(start[Graph] g) 
  = [symbol("<n>", key(), n.src) | /Node n := g];

list[DocumentSymbol] outline(start[Graph] g) = outline(g.top);
list[DocumentSymbol] outline(Graph g) = [outline(model(g), [n], n) | n <- model(g).topNodes];

loc locForNode(Model m, str n) = l when  loc l <- m.froms[n] || loc l <- m.tos[n];

DocumentSymbol outline(Model m, list[str] stack, str n) {
  l = locForNode(m, n);

  kids = [outline(m, stack + [to], to) | str to <- m.edges[n], to notin stack];

  return symbol(n, key(), l, children=kids);
}

Summary graphSummarizer(loc l, Graph g) {
    m = model(g);

    rel[str, loc] defs = { <"<x>",x.src> | Node x <- g.top} + m.tos;
    rel[loc, str] uses = m.froms<1, 0> + m.tos<1,0>;
    
    reachable = (m.edges+)[m.topNodes] + m.topNodes;
    unreachable = m.nodes - reachable;

    return summary(l,
        references = (uses o defs)<1,0>,
        definitions = uses o defs,
        messages = {<l, warning("<n> is not reachable", L)> | <n,L> <- m.froms, n in unreachable}
    );
}

data Command 
  = flipEdge(Edge e) 
  | visualize(start[Graph] g)
  ;

void commandHandler(flipEdge(Edge e)) {
    applyDocumentsEdits([flipEdit(e)]);
}

void commandHandler(visualize(start[Graph] g)) {
    showInteractiveContent(graphWebApp(model(g.top)));
}

DocumentEdit flipEdit((Edge) `<Node f> -- <Node t>`)
   = changed(f.src.top, [replace(f.src, "<t>"), replace(t.src, "<f>")]);

rel[loc,Command] createLenses(start[Graph] g) 
  = {<e.src, flipEdge(e, title="flip to <e.to> -- <e.from>")> | /Edge e := g, "<e.to>" != "<e.from>" }
  + {<g.src, visualize(g, title="visualize")>}
  ;

void main() {
    pcfg = getProjectPathConfig(|project://langdev-demo|);
    pcfg.srcs += [|project://salix/src|];
    
    lang = language(pcfg, "GraphLanguage", "graph", "GraphLang", "contributions");
    
    registerLanguage(lang);
}