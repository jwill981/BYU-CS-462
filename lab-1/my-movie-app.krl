ruleset my-movie-app {
    meta {
        name "My Movie App"
        author "Joshua Willis"

        use module org.themoviedb.sdk alias sdk
            with
              apiKey = "5e4af8d41cff8588281aee64004e09ca"
              sessionID = "1234"
        
        shares getPopular 
    }

    global {
        getPopular = function() {
          sdk:getPopular()
        }

        lastResponse = function() {
            {}.put(ent:lastTimestamp,ent:lastResponse)
        }
    }


    rule rate_movie {
        select when movie new_rating
          movieID re#(.+)#
          rating re#^(\d+([.]\d+)?)$#
          setting(movieID,rating)
        pre {
          rating_value = rating.as("Number")
          valid_rating = 0.5 <= rating_value && rating_value <= 10
        }
        if valid_rating then sdk:rateMovie(movieID,rating) setting(response)
        fired {
          ent:lastResponse := response
          ent:lastTimestamp := time:now()
          raise movie event "rated" attributes event:attrs
        }
    }

}