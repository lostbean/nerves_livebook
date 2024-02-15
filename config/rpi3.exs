import Config

# Configure the network using vintage_net
# See https://github.com/nerves-networking/vintage_net for more information
config :vintage_net,
  config: [
    {"eth0", %{type: VintageNetEthernet, ipv4: %{method: :dhcp}}},
    {"wlan0",
     %{
       type: VintageNetWiFi,
       vintage_net_wifi: %{
         networks: [
           %{
             key_mgmt: System.get_env("WIFI_KEY_MANAGEMENT", "wpa_psk") |> String.to_atom(),
             ssid: System.fetch_env!("WIFI_SSID"),
             psk: System.fetch_env!("WIFI_PSK")
           }
         ]
       },
       ipv4: %{method: :dhcp}
     }}
  ]

config :delux, indicators: %{default: %{green: "ACT"}}
