{ pkgs, ... }:

let
  serverCheckScript = pkgs.writeShellScript "check-server" ''
    SERVER_URL="https://home.super.fish"
    KUBE_CONTEXT="super-fish"

    # Check HTTP status
    HTTP_STATUS=$(${pkgs.curl}/bin/curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$SERVER_URL" 2>/dev/null)
    if [ "$HTTP_STATUS" != "200" ]; then
      ${pkgs.libnotify}/bin/notify-send -u critical "🐟️ Fish Drowned 🐠" "OH GOD OH FUCK WE'RE DOWN"
      exit
    fi

    # Check all pods are Running and Ready
    NOT_READY=$(${pkgs.kubectl}/bin/kubectl --context "$KUBE_CONTEXT" get pods --all-namespaces --no-headers 2>&1 | while read -r namespace name ready status restarts age; do
      if [ "$status" != "Running" ] && [ "$status" != "Succeeded" ]; then
        echo "$namespace/$name is $status"
      elif [ "$status" = "Running" ]; then
        # Check readiness (e.g. "1/1" vs "0/1")
        READY_COUNT=$(echo "$ready" | cut -d'/' -f1)
        TOTAL_COUNT=$(echo "$ready" | cut -d'/' -f2)
        if [ "$READY_COUNT" != "$TOTAL_COUNT" ]; then
          echo "$namespace/$name is not ready ($ready)"
        fi
      fi
    done)
    if [ -n "$NOT_READY" ]; then
      ${pkgs.libnotify}/bin/notify-send -u critical "🐟️ Fish Drowned 🐠" "OH GOD OH FUCK $NOT_READY"
    fi
  '';
in
{
  systemd.user.services.super-fish-monitor = {
    Unit.Description = "Super Fish Monitor";
    Service = {
      Type = "oneshot";
      ExecStart = "${serverCheckScript}";
    };
  };

  systemd.user.timers.super-fish-monitor = {
    Unit.Description = "Run super fish monitor every 5 minutes";
    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";
      Unit = "super-fish-monitor.service";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
