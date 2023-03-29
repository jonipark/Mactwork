//
//  ContentView.swift
//  Mactwork
//
//  Created by Joeun Park on 3/28/23.
//

import SwiftUI
import SystemConfiguration
import CoreWLAN

struct ContentView: View {
    @State private var ethernetAddress: String = ""
    @State private var wifiAddress: String = ""
    @State private var ethernetMACAddress: String = ""
    @State private var wifiMACAddress: String = ""
    @State private var connectionStatus: String = "Not Connected"
    @State private var wifiSSID: String = ""
    @State private var signalStrength: Int = 0
    @State private var linkSpeed: Int = 0
    @State private var networkUsageByProcess: [(name: String, usage: String)] = []


    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            if !ethernetAddress.isEmpty {
                HStack {
                    Text("This device is")
                        .font(.body)
                        .foregroundColor(.gray)
                    Text("\(connectionStatus)")
                        .font(.body)
                        .foregroundColor(connectionStatus == "Connected" ? .green : .red)
                    Text("to")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    Text("Wi-Fi")
                        .font(.body)
                        .foregroundColor(.gray)
                    Text(" | ")
                        .font(.body)
                        .foregroundColor(.gray)
                    Text("Ethernet")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                HStack {
                    Text("Address:")
                        .font(.title)
                        .foregroundColor(.blue)
                    Spacer()
                    Text(ethernetAddress)
                        .font(.title)
                        .foregroundColor(.green)
                }
                HStack {
                    Text("Ethernet MAC Address:")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(ethernetMACAddress)
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            if !wifiAddress.isEmpty {
                HStack {
                    Text("This device is")
                        .font(.body)
                        .foregroundColor(.gray)
                    Text("\(connectionStatus)")
                        .font(.body)
                        .foregroundColor(connectionStatus == "Connected" ? .green : .red)
                    Text("to")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    Text("Wi-Fi")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text(" | ")
                        .font(.body)
                        .foregroundColor(.gray)
                    Text("Ethernet")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("Address:")
                        .font(.title)
                        .foregroundColor(.blue)
                    Spacer()
                    Text(wifiAddress)
                        .font(.title)
                        .foregroundColor(.green)
                }
                HStack {
                    Text("Wi-Fi MAC Address:")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(ethernetMACAddress)
                        .font(.title2)
                        .foregroundColor(.orange)
                }
                if !wifiSSID.isEmpty {
                    HStack {
                        Text("Wi-Fi SSID:")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(wifiSSID)")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
                HStack {
                    Text("Signal Strength:")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(signalStrength) dBm")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
                
                if linkSpeed != 0 {
                    HStack {
                        Text("Link Speed:")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(linkSpeed) Mbps")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
        }
        .padding()
        .onAppear(perform: {
            getConnectionStatus()
            getNetworkAddresses()
            getMACAddresses()
            getWiFiInfo()
            getLinkSpeed()
        })
    }

    func getConnectionStatus() {
        let reachability = SCNetworkReachabilityCreateWithName(nil, "www.google.com")
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability!, &flags)

        if flags.contains(.reachable) {
            connectionStatus = "Connected"
        } else {
            connectionStatus = "Not Connected"
        }
    }

    func getNetworkAddresses() {
        let interfaces = SCNetworkInterfaceCopyAll() as! [SCNetworkInterface]

        for interface in interfaces {
            if let bsdName = SCNetworkInterfaceGetBSDName(interface) as String? {
                if let address = getIPAddress(for: bsdName) {
                    if SCNetworkInterfaceGetInterfaceType(interface) as String? == kSCNetworkInterfaceTypeEthernet as String {
                        ethernetAddress = address
                    } else if SCNetworkInterfaceGetInterfaceType(interface) as String? == kSCNetworkInterfaceTypeIEEE80211 as String {
                        wifiAddress = address
                    }
                }
            }
        }
    }

    func getIPAddress(for interfaceName: String) -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }

                let interface = ptr?.pointee

                if interface?.ifa_addr.pointee.sa_family == UInt8(AF_INET),
                   let ifaName = interface?.ifa_name,
                   let ifaNameString = String(cString: ifaName, encoding: .utf8),
                   ifaNameString == interfaceName {

                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface?.ifa_addr,
                                socklen_t(interface?.ifa_addr.pointee.sa_len ?? 0),
                                &hostname,
                                socklen_t(hostname.count),
                                nil,
                                0,
                                NI_NUMERICHOST)

                    address = String(cString: hostname)
                }
            }
            freeifaddrs(ifaddr)
        }

        return address
    }
    
    func getMACAddresses() {
        let interfaces = SCNetworkInterfaceCopyAll() as! [SCNetworkInterface]

        for interface in interfaces {
            if let bsdName = SCNetworkInterfaceGetBSDName(interface) as String?,
               let macAddress = SCNetworkInterfaceGetHardwareAddressString(interface) as String? {
                if SCNetworkInterfaceGetInterfaceType(interface) as String? == kSCNetworkInterfaceTypeEthernet as String {
                    ethernetMACAddress = macAddress
                } else if SCNetworkInterfaceGetInterfaceType(interface) as String? == kSCNetworkInterfaceTypeIEEE80211 as String {
                    wifiMACAddress = macAddress
                }
            }
        }
    }
    
    func getWiFiInfo() {
        let wifiClient = CWWiFiClient.shared()
        let currentInterface = wifiClient.interface()
        if let ssid = currentInterface?.ssid() {
            wifiSSID = ssid
        }
        if let rssi = currentInterface?.rssiValue() {
            signalStrength = rssi
        }
    }
    
    func getLinkSpeed() {
        let wifiClient = CWWiFiClient.shared()
        let currentInterface = wifiClient.interface()

        if let linkSpeedValue = currentInterface?.transmitRate() {
            linkSpeed = Int(linkSpeedValue)
        }
    }


}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
