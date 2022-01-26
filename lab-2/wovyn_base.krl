ruleset wovyn_base {
    meta {
        name "Wovyn Base"
        author "Josh Willis"

    }

    global {

    }

    rule process_heartbeat {
        select when wovyn heartbeat where event:attrs{"genericThing"} != null
        pre {
            msg = "I am in the base class and got a temp read!"
        }

        send_directive(msg)

        fired {
            raise wovyn event "new_temperature_reading" attributes {
                "temperature" : event:attrs{"genericThing"}.get(["data", "temperature"]),
                "timestamp" : time:now()
            }
        }
    }

    rule new_temperature_reading {
        select when wovyn new_temperature_reading

        send_directive("new temp reading!")
    }
}