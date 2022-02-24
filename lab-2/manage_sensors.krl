ruleset manage_sensors {
    meta{
        use module io.picolabs.wrangler alias wrangler

        shares sensors, nameFromID, showChildren, getChildTemps
        provides nameFromID
    }
    global{
        nameFromID = function(sensor_id) {
            "Sensor #" + sensor_id + " Pico"
        }

        sensors = function() {
            ent:sensors
        }

        showChildren = function() {
            wrangler:children()
        }

        rulesets = [
            "org.twilio.sdk",
            "wovyn_base",
            "wovyn_emitter",
            "temperature_store",
            "sensor_profile"
          ]


        getChildTemps = function() {
            children = wrangler:children()
            childTemps = children.map( function(child){
                wrangler:picoQuery(child{"eci"}, "wovyn_base", "currTemp")
            })
            childTemps
        }
    }

    rule initialize_sensors {
        select when sensors needs_initialization
        always {
          ent:sensors := {}
        }
    }

    rule sensor_exists {
        select when sensor new_sensor
        pre {
            sensor_id = event:attrs{"sensor_id"}
            exists = ent:sensors && ent:sensors >< sensor_id
            name = event:attrs{"name"}
            sms = event:attrs{"sms"}
        }
        if exists then
            send_directive("sensor_ready", {"sensor_id":sensor_id})
    }

    rule sensor_does_not_exist {
        select when sensor new_sensor
        pre {
            sensor_id = event:attrs{"sensor_id"}
            exists = ent:sensors && ent:sensors >< sensor_id
            sensor_name = event:attrs{"name"}
            sms = event:attrs{"sms"}
        }
        if not exists then send_directive("creating new sensor")
        fired {
            raise wrangler event "new_child_request"
            attributes { "name": nameFromID(sensor_id),
                         "backgroundColor": "#ff69b4",
                         "sensor_id": sensor_id,
                         "sensor_name": sensor_name,
                         "sms": sms,
                        }
        }
    }

    rule store_new_sensor {
        select when wrangler new_child_created
        foreach rulesets setting (rid)
        pre {
          the_sensor = {"eci": event:attrs{"eci"}}
          sensor_id = event:attrs{"sensor_id"}

          config = {
            "twilio-account-sid":meta:rulesetConfig{"twilio-account-sid"},
            "twilio-auth-token":meta:rulesetConfig{"twilio-auth-token"},
            "twilio-message-service-sid":meta:rulesetConfig{"twilio-message-service-sid"},
          }
        }

        if sensor_id.klog("found sensor_id") then 
          event:send(
            { "eci": the_sensor.get("eci").klog("sensor eci: "), 
              "eid": "install-ruleset", // can be anything, used for correlation
              "domain": "wrangler", "type": "install_ruleset_request",
              "attrs": {
                "absoluteURL": meta:rulesetURI.klog("rule set uri: "),
                "rid": rid.klog("rid: "),
                "config": config,
                "sensor_id": sensor_id,
              }
            }
          )
          
        fired {
          ent:sensors{sensor_id} := the_sensor
        }
    }

    rule initialize_sensor_profile {
        select when wrangler child_initialized
        pre {
            the_sensor = {"eci": event:attrs{"eci"}}
            sensor_name = event:attrs{"sensor_name"}
            sms = event:attrs{"sms"}
            threshold = 72
        }
        if sms && sensor_name then
            event:send(
                { "eci": the_sensor.get("eci").klog("sensor eci: "), 
                  "eid": "update-profile", // can be anything, used for correlation
                  "domain": "sensor", "type": "profile_updated",
                  "attrs": {
                    "name": sensor_name,
                    "location": "No location set",
                    "smsNum": sms,
                    "threshold": threshold
                  }
                }
            )
    }

    rule unneeded_sensor {
        select when sensor unneeded_sensor
        pre {
            sensor_id = event:attrs{"sensor_id"}
            exists = ent:sensors >< sensor_id
            eci_to_delete = ent:sensors{[sensor_id, "eci"]}
        }
        if exists && eci_to_delete then 
            send_directive("Deleting sensor", {"sensor_id":sensor_id})
        fired {
            raise wrangler event "child_deletion_request" attributes {
                "eci": eci_to_delete
            }
            clear ent:sensors{sensor_id}
        }
    }
}