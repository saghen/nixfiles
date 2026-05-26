{ ... }:
{
  services.pipewire = {
    enable = true;
    wireplumber.enable = true; # Session / policy manager
    audio.enable = true; # Use as primary audio server
    pulse.enable = true; # PulseAudio compatibility
    alsa.enable = true; # ALSA compatibility
    alsa.support32Bit = true; # Wiki says to do it and I don't ask questions

    extraConfig.pipewire = {
      # Auto switches between sample rates based on current audio
      "10-clock-rate" = {
        "context.properties" = {
          "default.clock.rate" = "48000";
          "default.clock.allowed-rates" = [
            "44100"
            "48000"
          ];
        };
      };

      # Higher resampling quality makes 44.1khz -> 48khz audibly transparent
      "20-resample-quality" = {
        "stream.properties" = {
          "resample.quality" = "10";
        };
      };
    };
  };

  # disable applications changing volume
  environment.etc."wireplumber/main.lua.d/51-disable-mic-volume.lua".text = ''
    rule = {
      matches = {
        {
          { "node.name", "matches", "alsa_input.*" },
        },
      },
      apply_properties = {
        ["node.param.Props"] = "{ softVolumes: false }",
      },
    }

    table.insert(alsa_monitor.rules, rule)
  '';

}
