ruleset my-twilio-app {
    meta {
        name "My Twilio App"
        author "Joshua Willis"

        use module org.twilio.sdk alias twilio
            with
              accountSID = meta:rulesetConfig{"twilio-account-sid"}
              authToken = meta:rulesetConfig{"twilio-auth-token"}
              serviceSID = meta:rulesetConfig{"twilio-message-service-sid"}
        
        shares getMessages
    }

    global {
        getMessages = function(to, from) {
            twilio:getMessages(to, from)
        }
    }

    rule sendSMS {
        select when send sms
        pre {
            recipient = event:attrs{"recipient"}
            message = event:attrs{"message"}
        }
        twilio:sendMessage(recipient, message) setting(response)
        fired {
            ent:lastResponse := response
            ent:lastTimestamp := time:now()
            raise sms event "sent" attributes event:attrs
          }
    }


}