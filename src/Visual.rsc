module Visual

import salix::App;
import salix::HTML;
import salix::lib::dagre::Dagre;

import Model;

SalixApp[Model] graphApp(Model m, str id = "graphDemo") = makeApp(id, Model () { return m; }, gview, gupdate); 

App[Model] graphWebApp(Model m) 
  = webApp(
      graphApp(m), 
      |project://salix/src|  
    );
 
data Msg; 

Model gupdate(Msg msg, Model m)  = m;

void gview(Model m) {
  div(() {
    
    h2("Hello Langdev people!");
    
    dagre("mygraph", rankdir("TD"), width(960), height(600), (N n, E e) {

      for (str x <- m.nodes) {
        n(x, [shape(x in m.topNodes ? "rect" : "ellipse"), () { 
          div(() {
	          h4(x);
	        });
        }]);
      }

      for (<str x, str y> <- m.edges) {
        e(x, y, [lineInterpolate("basis")]);
      }
    });    
  });
}