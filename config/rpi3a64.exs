import Config

# Configure the network using vintage_net
# See https://github.com/nerves-networking/vintage_net for more information
config :vintage_net,
  config: [
    {"usb0", %{type: VintageNetDirect}},
    {"wlan0",
     %{
       type: VintageNet.Technology.WiFi,
       wifi: %{
         key_mgmt: System.get_env("WIFI_KEY_MANAGEMENT", "wpa_psk") |> String.to_atom(),
         ssid: System.fetch_env!("WIFI_SSID"),
         psk: System.fetch_env!("WIFI_PSK")
       },
       ipv4: %{
         method: :dhcp
       }
     }}
  ]

config :delux, indicators: %{default: %{green: "led0"}}

config :nerves, :firmware, fwup_conf: "config/rpi3a64/fwup.conf"
