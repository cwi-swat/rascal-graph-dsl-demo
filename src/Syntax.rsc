module Syntax

start syntax Graph = "graph" Node+ top "{" Edge* edges "}";

syntax Edge = Node from "--" Node to;

layout Whitespace = [\ \t\n\r]*;

lexical Node = [$A-Za-z0-9\-]+;