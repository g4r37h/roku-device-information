function DeviceInformation() as object

    return {

        _deviceInfo: CreateObject("roDeviceInfo")

        getCaptionsEnabled: function() as boolean
            return lcase(m._deviceInfo.getCaptionsMode()) <> "off"
        end function

        getChannelClientId: function() as string
            return m._deviceInfo.getChannelClientId()
        end function

        getConnectionInfo: function() as object
            lanConnection = m._deviceInfo.getConnectionInfo()
            lanConnection.type = getValue(lanConnection.type, "Unknown").replace("Connection", "")
            return {
                lan: lanConnection
                wan: {
                    ip: m._deviceInfo.getExternalIp()
                }
            }
        end function

        getCountryCode: function() as string
            return m._deviceInfo.getCountryCode()
        end function

        getCurrentLocale: function() as string
            return m._deviceInfo.getCurrentLocale()
        end function

        getGraphicsPlatform: function() as string
            return m._deviceInfo.getGraphicsPlatform()
        end function

        getModel: function() as string
            return m._deviceInfo.getModel()
        end function

        getModelDisplayName: function() as string
            return m._deviceInfo.getModelDisplayName()
        end function

        getTimeZone: function() as string
            return m._deviceInfo.getTimeZone()
        end function

        getOSVersion: function() as object
            return m._deviceInfo.getOSVersion()
        end function

        getUIResolution: function() as object
            return m._deviceInfo.getUIResolution()
        end function

        hasNetworkConnection: function() as boolean
            return m._deviceInfo.getConnectionType() <> ""
        end function

        isRIDADisabled: function() as boolean
            return m._deviceInfo.isRIDADisabled()
        end function
    }

end function
