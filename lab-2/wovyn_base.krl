ruleset wovyn_base {
    meta {
        name "Wovyn Base"
        author "Josh Willis"

    }

    global {

    }

    rule process_heartbeat {
        select when wovyn heartbeat where event:attr("genericThing") != null
        pre {
            msg = "I am in the base class and got a temp read!"
        }

        send_directive(msg)
    }
}