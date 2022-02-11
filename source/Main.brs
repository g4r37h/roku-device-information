sub Main(args as dynamic)
    initialiseApp(args)

    while true
        msg = wait(0, m._messagePort)
        msgType = type(msg)

        if msgType <> "roInvalid"
            if msgType = "roSGScreenEvent"
                if msg.isScreenClosed() then exit while
            end if
        end if
    end while
end sub

sub initialiseApp(args as object)
    m.screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    m.screen.setMessagePort(m.port)
    m.scene = m.screen.CreateScene("AppScene")

    m.screen.show()
end sub
