ruleset wovyn_base {
    meta {
        name "Wovyn Base"
        author "Josh Willis"

        shares currTemp

        use module org.twilio.sdk alias twilio
            with
              accountSID = meta:rulesetConfig{"twilio-account-sid"}
              authToken = meta:rulesetConfig{"twilio-auth-token"}
              serviceSID = meta:rulesetConfig{"twilio-message-service-sid"}
    }

    global {
        currTemp = function() {
            ent:currTemp
        }
    }

    rule set_threshold {
        select when wovyn set_threshold
        pre {
            temp = event:attrs{"threshold"}.klog("set threshold new temp: ")
        }
        always {
            ent:threshold := temp
        }
    }

    rule set_phone_number {
        select when wovyn set_phone_number
        pre {
            number = event:attrs{"smsNum"}
        }
        always {
            ent:phone_number := number
        }
    }

    rule process_heartbeat {
        select when wovyn heartbeat where event:attrs{"genericThing"} != null

        send_directive(ent:threshold || 75, event:attrs{"genericThing"})

        fired {
            temp = event:attrs{"genericThing"}.get(["data", "temperature"]).klog("temp reading: ")
            raise wovyn event "new_temperature_reading" attributes {
                "temperature" : temp[0],
                "timestamp" : time:now()
            }
        }
    }

    rule find_high_temps {
        select when wovyn new_temperature_reading
        
        pre {
            temp = event:attrs{"temperature"}.get(["temperatureF"]).klog("temp from sensor: ")
            timestamp = event:attrs{"timestamp"}
        }

        send_directive(temp)

        always {
            ent:currTemp := temp
            raise wovyn event "threshold_violation" attributes {
                "temperature": temp,
                "timestamp" : timestamp
            }.klog("I called violation rule!")
            if ent:threshold.defaultsTo(75) < temp
        }

    }

    rule threshold_notification {
        select when wovyn threshold_violation
        pre {
            message = "Temperature threshold violation! temp: " + event:attrs{"temperature"} + " threshold: " + ent:threshold || 75
        }
        
        twilio:sendMessage(ent:phone_number || "8438267813", message)
    }
}