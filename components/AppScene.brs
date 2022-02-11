sub init()
    m.deviceInformation = DeviceInformation()
    m.registry = CreateObject("roRegistry")

    setupUi()
    updateBody()

    m.timer = m.top.findNode("updateTimer")
    m.timer.observeFieldScoped("fire", "updateBody")
    m.timer.control = "start"
end sub

sub setupUi()
    textGroup = m.top.findNode("textGroup")
    title = textGroup.findNode("title")
    title.font.size = 22

    m.body = textGroup.findNode("body")
    m.body.font.size = 18

    m.body.setFocus(true)
end sub

sub updateBody()
    m.body.text = ""

    m.body.text += _addField("Model Display Name", m.deviceInformation.getModelDisplayName())
    m.body.text += _addField("Model", m.deviceInformation.getModel())

    version = m.deviceInformation.getOSVersion()
    m.body.text += _addField("Firmware", version.major.toStr() + "." + version.minor.toStr() + "." + version.build.toStr())
    m.body.text += _addField("Channel Client ID", m.deviceInformation.getChannelClientId())

    m.body.text += _addField("Country Code", m.deviceInformation.getCountryCode())
    m.body.text += _addField("Locale", m.deviceInformation.getCurrentLocale())
    m.body.text += _addField("Time Zone", m.deviceInformation.getTimeZone())

    resolution = m.deviceInformation.getUIResolution()
    m.body.text += _addField("Resolution", resolution.name + " | " + resolution.width.toStr() + " x " + resolution.height.toStr())
    m.body.text += _addField("Graphics Platform", ucase(m.deviceInformation.getGraphicsPlatform()))

    if m.deviceInformation.hasNetworkConnection()
        connectionInfo = m.deviceInformation.getConnectionInfo()
        m.body.text += _addField("Network Connection Type", connectionInfo.lan.type + (function(lan as object) as string
            if lan.type = "WiFi" then return " (" + lan.ssid + ")"
            return ""
        end function)(connectionInfo.lan))
        m.body.text += _addField("Internal IP Address", connectionInfo.lan.ip)
        m.body.text += _addField("External IP Address", connectionInfo.wan.ip)
    else
        m.body.text += _addField("Network Connection Type", "Not Connected")
    end if

    m.body.text += _addField("Available Registry Space", m.registry.getSpaceAvailable().toStr() + " bytes")

    m.body.text += _addField("Closed Captions", ternary(m.deviceInformation.getCaptionsEnabled(), "Enabled", "Disabled"))
    m.body.text += _addField("Tracking via Roku ID for Advertisers (RIDA)", ternary(not m.deviceInformation.isRIDADisabled(), "Enabled", "Disabled"))
end sub

function _addField(name as string, value as string) as string
    return name + ": " + value + chr(10)
end function
