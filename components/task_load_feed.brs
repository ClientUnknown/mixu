sub init()
    m.top.functionname = "request"
    m.top.response = ""
end sub

function request()
    api_prefix = "https://mixer.com/api/v1"
    payload_empty = {"":""}
    auth = "Bearer " + m.accessToken
    headers = {"Authorization":auth}

    url = m.top.url

    oa = Oauth()
    mixu = LoadMixu()

    r = Requests().get(m.api_prefix + "/users/current", {"json":payload_empty})
    while r.statuscode <> 200
        if r.statuscode = 401
            print "Token needs to be refreshed, re-authenticating..."
            doRegistration()
        else if r.statuscode = 403
            print "Fatal error 403 Forbidden"
            return 0
        else if r.statuscode = 429
            print "Too many requests recently, please try again in a few minutes."
            return 0
        end if
        r = Requests().get(m.api_prefix + "/users/current", {"json":payload_empty})
    end while

    print "r info in request: "; r
end function