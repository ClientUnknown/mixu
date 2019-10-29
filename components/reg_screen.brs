function init()
    print "Init for reg_screen"
    m.button = m.top.findNode("button")
    m.token = m.top.findNode("token")
    m.how_to = m.top.findNode("how_to")
    m.reg_task = m.top.findNode("RegistryTask")
    m.register_timer = m.top.findNode("register_timer")

    m.token.font.size = 90

    oa = m.global.oa

    doRegistration()
    print "usercode: "; m.global.oa.userCode

    m.reg_task.observeField("result", "on_read_finished")
    m.button.observeField("button_selected", "on_button_press")
    m.button.setFocus(true)
end function

sub on_read_finished(event as object)
    print "on_read_finished"
end sub

sub on_button_press(event as object)
    print "on_button_press"

    if m.button.text <> "Unlink The Device"

    else

    end if
end sub