ruleset hello_world {
    meta {
      name "Hello World"
      description <<
  A first ruleset for the Quickstart
  >>
      author "Phil Windley"
      shares hello
    }
     
    global {
      hello = function(obj) {
        msg = "Hello " + obj;
        msg
      }
    }
     
    rule hello_world {
      select when echo hello
      send_directive("say", {"something": "Hello World"})
    }
 
    rule monkey {
      select when echo monkey
      pre {
        name = (event:attrs{"name"}) => event:attrs{"name"}.klog("Special name to be used.") | "Monkey".klog("Default name.")
      }

      send_directive("say", {"something": "Hello " + name})
    }
     
  }