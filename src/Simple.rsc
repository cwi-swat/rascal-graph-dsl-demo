module Simple

import util::LanguageServer;
import util::Reflective;
import ParseTree;
import IO;

start syntax Graph = "graph" Node+ top "{" Edge* edges "}";

syntax Edge = Node from "--" Node to;

layout Whitespace = [\ \t\n\r]*;

lexical Node = [$A-Za-z0-9\-]+;

void registerSimple() {
    pcfg = getProjectPathConfig(|project://strumenta-demo|);
    
    lang = language(pcfg, "GraphLanguage", "graph", "GraphLang", "contributions");
    
    registerLanguage(lang);
}

void experiment() {
    g = parse(#start[Graph], |project://strumenta-demo/src/example.graph|);
   
    rel[str from, str to] edges = { <"<from>", "<to>"> | /(Edge) `<Node from> -- <Node to>` := g};

    iprintln(edges);
}