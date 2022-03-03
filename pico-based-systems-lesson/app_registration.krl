ruleset app_registration {
    meta {
        use module io.picolabs.wrangler alias wrangler
    }

    rule allow_student_to_register {
      select when student arrives
        name re#(.+)# setting(name)
      pre {
        backgroundColor = event:attr("backgroundColor") || "#CCCCCC"
      }
      event:send({"eci":wrangler:parent_eci(),
        "domain":"wrangler", "type":"new_child_request",
        "attrs":{
          "name":name,
          "backgroundColor": backgroundColor,
          "wellKnown_Rx":ent:sectionCollectionECI
        }
      })
    }

    rule make_a_subscription {
      select when student new_subscription_request
      event:send({"eci":ent:wellKnown_Rx,
        "domain":"wrangler", "name":"subscription",
        "attrs": {
          "wellKnown_Tx":subs:wellKnown_Rx(){"id"},
          "Rx_role":"registration", "Tx_role":"student",
          "name":ent:name+"-registration", "channel_type":"subscription"
        }
      })
    }
}