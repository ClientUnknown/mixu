sub init()
    m.content_grid = m.top.FindNode("content_grid")
    m.header = m.top.FindNode("header")
end sub

sub on_feed_changed(obj)
    feed = obj.getData()
    m.header.text = feed.title
    postercontent = createObject("roSGNode", "ContentNode")

    for each item in feed.items
        node = createObject("roSGNode", "ContentNode")
    end for
end sub

sub showpostergrid(content)
    m.content_grid.content = content
    m.content_grid.visible = true
    m.content_grid.setFocus(true)
end sub