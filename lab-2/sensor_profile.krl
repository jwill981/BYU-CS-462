ruleset sensor_profile {
    meta {
        author "Josh Willis"

        shares data
    }

    global {
        data = function() {
            data = {
                "name": ent:name,
                "location": ent:location,
                "number": ent:smsNum,
                "threshold": ent:threshold
            }
            data
        }
    }

    rule profile_updated {
        select when sensor profile_updated
        pre {
            location = event:attrs{"location"}
            name = event:attrs{"name"}
            smsNum = event:attrs{"smsNum"}
            threshold = event:attrs{"threshold"}
            data = {
                "name": name,
                "location": location,
                "smsNum": smsNum,
                "threshold": threshold
            }
        }

        send_directive(data)

        always {
            ent:location := location
            ent:name := name
            ent:smsNum := smsNum
            ent:threshold := threshold

            raise wovyn event "set_phone_number" attributes {
                "smsNum": smsNum
            }
            raise wovyn event "set_threshold" attributes {
                "threshold": threshold
            }
            raise sensor event "reading_reset"
        }
    }
}