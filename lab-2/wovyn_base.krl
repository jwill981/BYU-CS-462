ruleset wovyn_base {
    meta {
        name "Wovyn Base"
        author "Josh Willis"

        use module org.twilio.sdk alias twilio
            with
              accountSID = meta:rulesetConfig{"twilio-account-sid"}
              authToken = meta:rulesetConfig{"twilio-auth-token"}
              serviceSID = meta:rulesetConfig{"twilio-message-service-sid"}
    }

    global {
        temperature_threshold = 75
        phone_number = "+18438267813"
    }

    rule process_heartbeat {
        select when wovyn heartbeat where event:attrs{"genericThing"} != null

        send_directive(temperature_threshold, event:attrs{"genericThing"})

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
            raise wovyn event "threshold_violation" attributes {
                "temperature": temp,
                "timestamp" : timestamp
            }.klog("I called violation rule!")
            if temperature_threshold < temp
        }

    }

    rule threshold_notification {
        select when wovyn threshold_violation
        pre {
            message = "Temperature threshold violation! temp: " + event:attrs{"temperature"} + " threshold: " + temperature_threshold
        }
        
        twilio:sendMessage(phone_number, message) setting(response)
    }
}