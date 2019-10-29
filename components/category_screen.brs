function init()
    m.category_list = m.top.findNode("category_list")
    m.category_list.setFocus(true)
    m.top.observeField("visible", "on_visible_change")
end function

sub on_visible_change()
    if m.top.visible = true then
        m.category_list.setFocus(true)
    end if
end sub