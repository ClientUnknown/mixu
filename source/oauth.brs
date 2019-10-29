function Oauth() as object
    return m.oa
end function

function InitOauth(clientId as string, clientSecret as string, port=invalid as dynamic) as object
    this = CreateObject("roAssociativeArray")

    this.oauth_prefix            = "https://mixer.com/oauth/authorize"
    this.token_prefix            = "https://mixer.com/api/v1/oauth/token"
    this.short_prefix            = "https://mixer.com/api/v1/oauth/shortcode"

    this.clientId                = "6a35d7f57ab8c214692a2a734acbe07ee62a33f4ebeacf1f"
    this.clientSecret            = "d3688f9f7dc2d31d0379eeb911fc29752f22fa549f8f936adcbb05ddd29956cf"

    this.RequestUserCode         = oauth_request_user_code
    this.PollForTokens           = oauth_poll_for_tokens
    this.CurrentAccessToken      = oauth_current_access_token
    this.RefreshTokens           = oauth_refresh_tokens

    this.sign                    = oauth_sign
    this.section                 = "Mixu-Auth"
    this.items                   = CreateObject("roList")
    this.load                    = loadReg    ' from regScreen.brs
    this.save                    = saveReg    ' from regScreen.brs
    this.erase                   = eraseReg   ' from regScreen.brs
    this.linked                  = definedReg ' from regScreen.brs
    this.dump                    = dumpReg    ' from regScreen.brs

    this.deviceCode              = ""
    this.userCode                = ""
    this.verificationUrl         = ""
    this.handle                  = ""
    this.pollExpiresIn           = 0
    this.tokenExpiresIn          = 0
    this.interval                = 0
    this.accessToken             = ""
    this.tokenType               = ""
    this.refreshToken            = ""
    this.port                    = port

    this.pollDelay               = 0
    this.errorMsg                = ""

    this.items.push("accessToken")
    this.items.push("refreshToken")

    this.load()

    return this
end function

function oauth_request_user_code() as integer
    status                       = 0        ' 0 => Success, <> 0 => failed
    m.errorMsg                   = ""

    m.accessToken                = ""
    m.refreshToken               = ""

    m.deviceCode                 = ""
    m.userCode                   = ""
    m.verificationUrl            = ""
    m.handle                     = ""
    m.pollExpiresIn              = 0
    m.interval                   = 0

    m.pollDelay                  = 0

    mixu = LoadMixu()

    payload = {"client_id": m.clientId, "client_secret": m.clientSecret, "scope": "user:act_as"}

    r = Requests().post(m.short_prefix, {"json":payload})
    if r.statuscode <> 200
        m.errorMsg = r.getfailurereason
        status = 1
    else
        json = ParseJson(r.text)
        if json = invalid
            m.errorMsg = "Unable to parse Json response"
            status = 1
        else if type(json) <> "roAssociativeArray"
            m.errorMsg = "Json response is not an associative array"
            status = 1
        else if json.DoesExist("error")
            m.errorMsg = "Json error response: " + json.error
            status = 1
        else
            m.userCode              = getString(json,"code")
            m.pollExpiresIn         = getInteger(json,"expires_in")
            m.handle                = getString(json, "handle")
            if m.userCode           = ""    then m.errorMsg = "Missing user_code"           : status = 1
            if m.handle             = ""    then m.errorMsg = "Missing handle"              : status = 1
            if m.pollExpiresIn      = 0     then m.errorMsg = "Missing expires_in"          : status = 1   
        end if
    end if

    return status
end function

function oauth_poll_for_tokens() as integer
    status              = 0    ' 0 => Finished (got tokens), < 0 => Retry needed, > 0 => fatal error
    m.errorMsg          = ""

    m.accessToken       = ""
    m.tokenType         = ""
    m.tokenExpiresIn    = 0
    m.refreshToken      = ""

    payload_empty = {"":""}

    r = Requests().get(m.short_prefix + "/check/" + m.handle, {"json":payload_empty})
    while r.statuscode = 204
        r = Requests().get(m.short_prefix + "/check/" + m.handle, {"json":payload_empty})
    end while

    if r.statuscode = 403
        print "User denied access: "; r.statuscode
        return -1
    else if r.statuscode = 404
        print "Handle invalid: "; r.statuscode
        return -1
    end if
    
    json = ParseJson(r.text)
    m.deviceCode = getString(json,"code")

    payload = {"client_id":m.clientId, "client_secret":m.clientSecret, "code":m.deviceCode, "grant_type":"authorization_code"}

    r = Requests().post(m.token_prefix, {"json":payload})
    if r.statuscode <> 200
        m.errorMsg = r.getfailurereason
        status = 1
    else
        json = ParseJson(r.text)
        if json = invalid
            m.errorMsg = "Unable to parse Json response"
            status = 1
        else if type(json) <> "roAssociativeArray"
            m.errorMsg = "Json response is not an associative array"
            status = 1
        else if json.DoesExist("error")
            print "oauth_poll_for_tokens: Json error response: "; json.error
            if json.error = "authorization_pending"
                status = -1    ' Retry
            else if json.error = "slow_down"
                m.pollDelay = m.pollDelay + 2        ' Increase polling interval
                status = -1    ' Retry
            else
                m.errorMsg = "Json error response: " + json.error
                status = 1
            end if
        else
            ' We have our tokens
            m.accessToken        = getString(json,"access_token")
            m.tokenType          = getString(json,"token_type")
            m.tokenExpiresIn     = getInteger(json,"expires_in")
            m.refreshToken       = getString(json,"refresh_token")
            if m.accessToken     = ""    then m.errorMsg = "Missing access_token"    : status = 1
            if m.tokenType       = ""    then m.errorMsg = "Missing token_type"      : status = 1
            if m.tokenExpiresIn  = 0     then m.errorMsg = "Missing expires_in"      : status = 1
            if m.refreshToken    = ""    then m.errorMsg = "Missing refresh_token"   : status = 1
        end if
    end if

    return status
end function

function oauth_current_access_token() as string
    return m.accessToken
end function

function oauth_refresh_tokens() as integer
    status        = 0        ' 0 => Success, <> 0 => failed
    m.errorMsg    = ""

    payload = {"client_id":m.clientId, "client_secret":m.clientSecret, "grant_type":"refresh_token", "refresh_token":m.refreshToken}

    r = Requests().post(m.token_prefix, {"json":payload})
    if r.statuscode <> 200
        m.errorMsg = r.getfailurereason
        status = 1
    else
        json = ParseJson(r)
        if json = invalid
            m.errorMsg = "Unable to parse Json response"
            status = 1
        else if type(json) <> "roAssociativeArray"
            m.errorMsg = "Json response is not an associative array"
            status = 1
        else if json.DoesExist("error")
            m.errorMsg = "Json error response: " + json.error
            status = 1
        else
			' Extract data from the response. Note, the refresh_token is optional
            m.accessToken        = getString(json,"access_token")
            m.tokenType          = getString(json,"token_type")
            m.tokenExpiresIn     = getInteger(json,"expires_in")
            refreshToken		 = getString(json,"refresh_token")
			if refreshToken <> ""
				m.refreshToken   = refreshToken
			end if

            if m.accessToken     = ""    then m.errorMsg = "Missing access_token"    : status = 1
            if m.tokenType       = ""    then m.errorMsg = "Missing token_type"      : status = 1
            if m.tokenExpiresIn  = 0     then m.errorMsg = "Missing expires_in"      : status = 1
        end if
    end if

    return status
end function

function oauth_sign(http as object, protected=true as boolean)
    if protected and m.accessToken <> ""
        http.AddHeader("Authorization", "Bearer " + m.accessToken)
    end if
end function

Function getString(json As Dynamic,fieldName As String,defaultValue="" As String) As String
    returnValue = defaultValue
    if json <> Invalid
        if type(json) = "roAssociativeArray" or GetInterface(json,"ifAssociativeArray")
            fieldValue = json.LookupCI(fieldName)
            if fieldValue <> Invalid
                if type(fieldValue) = "roString" or type(fieldValue) = "String" or GetInterface(fieldValue,"ifString") <> Invalid
                    returnValue = fieldValue
                end if
            end if
        end if
    end if
    return returnValue
End Function

Function getInteger(json As Dynamic,fieldName As String,defaultValue=0 As Integer) As Integer
    returnValue = defaultValue
    if json <> Invalid
        if type(json) = "roAssociativeArray" or GetInterface(json,"ifAssociativeArray")
            fieldValue = json.LookupCI(fieldName)
            if fieldValue <> Invalid
                if type(fieldValue) = "roInteger" or type(fieldValue) = "Integer" or type(fieldValue) = "roInt" or GetInterface(fieldValue,"ifInt") <> Invalid
                    returnValue = fieldValue
                end if
            end if
        end if
    end if
    return returnValue
End Function