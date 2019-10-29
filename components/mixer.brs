function init()
    ? "[mixer] init"

    m.category_screen = m.top.findNode("category_screen")
    m.content_screen = m.top.findNode("content_screen")
    m.reg_screen = m.top.findNode("reg_screen")

    m.category_screen.observeField("category_selected", "on_category_selected")

    m.category_screen.setFocus(true)
end function

function onKeyEvent(key, press) as boolean
    ? "[mixer] on_key_event", key, press
    return false
end function

sub on_category_selected(obj)
    list = m.category_screen.findNode("category_list")
    item = list.content.getChild(obj.getData())
    if item.TITLE = "REGISTER DEVICE"
        print "Register device was selected"
        print(m.reg_screen)
        m.reg_screen.visible = true
    else
        load_feed(item.feed_url)
    end if
end sub

sub load_feed(url)
    ? "load_feed: "; url

    m.feed_task = createObject("roSGNode", "task_load_feed")
    m.feed_task.observeField("response", "on_feed_response")
    m.feed_task.url = url
    m.feed_task.control = "RUN"
end sub

sub on_feed_response(obj)
    response = obj.getData()
    data = parseJSON(response)

    if data <> invalid and data.items <> invalid
        m.category_screen.visible = false
        m.content_screen.visible = false
        m.content_screen.feed_data = data
    else
        print "Feed response empty"
    end if
end sub