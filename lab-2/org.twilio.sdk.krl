ruleset org.twilio.sdk {
    meta {
        configure using
            accountSID = ""
            authToken = ""
            serviceSID = ""

        provides getMessages, sendMessage
    }

    global {
        baseUrl = "https://api.twilio.com/2010-04-01"

        getMessages = function(to, from) {
            body = {"To": to, "From": from}
            response = http:get(<<#{baseUrl}/Accounts/#{accountSID}/Messages.json>>
                , qs=body, auth={"username":accountSID, "password":authToken})
            response{"content"}.decode()
        }

        sendMessage = defaction(recipient, message) {
            body = {"MessagingServiceSid":serviceSID, "Body":message,"To":recipient }
            http:post(<<#{baseUrl}/Accounts/#{accountSID}/Messages.json>>
                ,form=body, auth={"username":accountSID, "password":authToken}) setting(response)
            return response
        }
    }
}