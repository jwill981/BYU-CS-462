ruleset temperature_store {
    meta {
        name "Temperature Store"
        author "Josh Willis"

        shares temperatures, threshold_violations, inrange_temperatures
        provides temperatures, threshold_violations, inrange_temperatures
    }

    global {
        temperatures = function() {
            ent:allTemps
        }

        threshold_violations = function() {
            ent:thresholdViolations
        }

        inrange_temperatures = function() {
            ent:allTemps.difference(ent:thresholdViolations)
        }
    }


    rule collect_temperatures {
        select when wovyn new_temperature_reading
        pre {
            temp = event:attrs{"temperature"}.get(["temperatureF"])
            timestamp = event:attrs{"timestamp"}
            data = {"temp": temp, "timestamp": timestamp}
        }
        always {
            ent:allTemps := ent:allTemps.defaultsTo([]).append(data)
        }
    }

    rule collect_threshold_violations {
        select when wovyn threshold_violation
        pre {
            temp = event:attrs{"temperature"}
            timestamp = event:attrs{"timestamp"}
            data = {"temp": temp, "timestamp": timestamp}
        }
        always {
            ent:thresholdViolations := ent:thresholdViolations.defaultsTo([]).append(data)
        }
    }

    rule clear_temperatures {
        select when sensor reading_reset
        always {
            clear ent:allTemps
            clear ent:thresholdViolations
        }

    }
}