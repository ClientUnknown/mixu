function main(args as dynamic) as void
    print("Mixu started")
    RunUserInterface()
end function

sub Init()
    print readText("client.txt")
    if m.oa = invalid then m.oa = InitOauth(client_id, client_secret)
    if m.mixu = invalid then m.mixu = InitMixu()
end sub

function LoadMixu() as object
    return m.mixu
end function

function InitMixu() as object
    this = CreateObject("roAssociativeArray")

    return this
end function

sub RunUserInterface()
    initTheme()

    Init()
    oa = Oauth()
    'mixu = LoadMixu()

    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    m.global = screen.getGlobalNode()
    m.global.id = "GlobalNode"
    m.global.addFields({
        oa: oa
    })

    'm.global.oa = Oauth()
    scene = screen.createScene("mixer")
    screen.Show()
    'doRegistration()

    while true
        msg = wait(0, m.port)
        if type(msg) = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub

sub initTheme()
    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")

    app.SetTheme(theme)
end sub

sub readText(url as string) as string
    r = CreateObject("roUrlTransfer")
    r.SetURL(url)

    return r.GetToString()
end sub
