function main(args as dynamic) as void
    print("Mixu started")
    RunUserInterface()
end function

sub Init()
    print readText("client.txt")
    if m.oa = invalid then m.oa = InitOauth("6a35d7f57ab8c214692a2a734acbe07ee62a33f4ebeacf1f","d3688f9f7dc2d31d0379eeb911fc29752f22fa549f8f936adcbb05ddd29956cf")
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