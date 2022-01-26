ruleset wovyn_base {
    meta {
        name "Wovyn Base"
        author "Josh Willis"

    }

    global {

    }

    rule process_heartbeat {
        select when wovyn heartbeat
        pre {
            msg = "I got a temp read!"
        }

        send_directive(msg)
    }
}