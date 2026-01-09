{
  config,
  limbo,
  ...
}:
let
  colors = config.colors;
in
{
  imports = [ limbo.homeManagerModules.default ];

  services.limbo-rs = {
    enable = true;
    # settings = {
    #   general = {
    #     lon = -79.38;
    #     lat = 43.65;
    #   };
    #   theme = {
    #     font = "IBM Plex Mono";
    #   };
    #   bar = {
    #     notifications = {
    #       weather = {
    #         onPrimaryClick = "xdg-open https://merrysky.net/forecast/Toronto/CA";
    #       };
    #     };
    #     quickSettings = {
    #       tray = {
    #         ignoredApps = [ "spotify" ];
    #         appIconMappings = {
    #           sunshine = {
    #             name = "inner-shadow-bottom-left";
    #             color = colors.yellow;
    #           };
    #           steam = {
    #             name = "brand-steam";
    #             color = colors.text;
    #           };
    #           obs = {
    #             name = "player-record";
    #             color = colors.text;
    #           };
    #         };
    #       };
    #       dnd = {
    #         toggleCmd = "dunstctl set-paused toggle";
    #         statusCmd = "dunstctl is-paused";
    #         historyCmd = "dunstctl history-pop";
    #       };
    #       network = {
    #         ethernetIcon = {
    #           name = "wifi";
    #           color = colors.blue;
    #         };
    #         ethernetOffIcon = {
    #           name = "wifi-off";
    #           color = colors.red;
    #         };
    #       };
    #     };
    #     sysmon = {
    #       onPrimaryClick = "gnome-system-monitor";
    #       temp = {
    #         path = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon2/temp3_input";
    #       };
    #     };
    #     twitch = {
    #       channels = [
    #         "simply"
    #         "tarik"
    #         "jerma985"
    #         "clintstevens"
    #         "liam"
    #       ];
    #     };
    #   };
    # };
  };

  sops.secrets.limbo = {
    sopsFile = ../../keys/sops/limbo.yaml;
    path = "${config.xdg.configHome}/limbo/secrets.json";
  };
}
