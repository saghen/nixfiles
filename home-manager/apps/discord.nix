{ config, ... }:
# TODO: finish theming this, need hex -> rgb func
{
  programs.firefoxNativefy = {
    enable = true;
    apps = {
      discord = {
        name = "Discord";
        id = 1;
        url = "https://discord.com/channels/@me";
        icon = "discord";
        defaultPermissions = {
          microphone = true;
          camera = true;
        };
        settings = {
          "layout.frame_rate" = config.machine.refreshRate;

          "privacy.annotate_channels.strict_list.enabled" = true;
          "privacy.donottrackheader.enabled" = true;
          "privacy.fingerprintingProtection" = true;
          "privacy.globalprivacycontrol.enabled" = true;
          "privacy.query_stripping.enabled" = true;
          "privacy.query_stripping.enabled.pbmode" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.emailtracking.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.userContext.enabled" = true;
          "privacy.userContext.ui.enabled" = true;

          "media.ffmpeg.vaapi.enabled" = true;

          # always ask for download location
          "browser.download.useDownloadDir" = false;

          "browser.contentblocking.category" = "strict";
        };
        userContent = ''
          html {
            --bg-darker: #11111b;
            --bg-primary: #1e1e2e;
            --bg-secondary: #2c2c3f;
            --bg-tertiary: #313244;

            --primary: #5f8cfb;
            --primary-rgb: 95, 140, 251;
            --secondary: #89b4fa;
          }

          .theme-dark, .theme-darker, .visual-refresh.theme-darker, .visual-refresh .theme-darker  {
            --background-primary: var(--bg-primary) !important;
            --background-secondary: var(--bg-primary) !important;
            --background-secondary-alt: var(--bg-primary) !important;
            --background-tertiary: var(--bg-primary) !important;

            --background-base-lowest: var(--bg-primary) !important;
            --background-base-lower: var(--bg-primary) !important;
            --background-base-low: var(--bg-secondary) !important;

            --background-surface-high: var(--bg-secondary) !important;

            --bg-base-primary: var(--bg-primary) !important;
            --bg-base-secondary: var(--bg-primary) !important;
            --bg-base-tertiary: var(--bg-darker) !important;

            --border-subtle: var(--bg-secondary);
            --border-normal: var(--bg-secondary);


            --chat-background-default: var(--bg-secondary) !important;

            --background-message-hover: var(--bg-primary) !important;
            --background-accent: var(--bg-tertiary) !important;
            --background-floating: var(--bg-tertiary) !important;
            --background-modifier-selected: var(--bg-secondary) !important;
            --activity-card-background: var(--bg-secondary) !important;
            --deprecated-panel-background: var(--bg-primary) !important;
            --channeltextarea-background: var(--bg-secondary) !important;

            --text-link: var(--secondary);

            --bg-overlay-hover: var(--bg-secondary) !important;
          }

          .theme-dark, .theme-darker, .visual-refresh.theme-darker, .visual-refresh .theme-darker {
            --font-display: "Whitney", "Helvetica Neue", Helvetica, Arial, sans-serif !important;

            --brand-experiment: var(--primary);
            --brand-experiment-05a: rgba(var(--primary-rgb), 0.05);
            --brand-experiment-10a: rgba(var(--primary-rgb), 0.1);
            --brand-experiment-15a: rgba(var(--primary-rgb), 0.15);
            --brand-experiment-20a: rgba(var(--primary-rgb), 0.2);
            --brand-experiment-25a: rgba(var(--primary-rgb), 0.25);
            --brand-experiment-30a: rgba(var(--primary-rgb), 0.3);
            --brand-experiment-35a: rgba(var(--primary-rgb), 0.35);
            --brand-experiment-40a: rgba(var(--primary-rgb), 0.4);
            --brand-experiment-45a: rgba(var(--primary-rgb), 0.45);
            --brand-experiment-50a: rgba(var(--primary-rgb), 0.5);
            --brand-experiment-55a: rgba(var(--primary-rgb), 0.55);
            --brand-experiment-60a: rgba(var(--primary-rgb), 0.6);
            --brand-experiment-65a: rgba(var(--primary-rgb), 0.65);
            --brand-experiment-70a: rgba(var(--primary-rgb), 0.7);
            --brand-experiment-75a: rgba(var(--primary-rgb), 0.75);
            --brand-experiment-80a: rgba(var(--primary-rgb), 0.8);
            --brand-experiment-85a: rgba(var(--primary-rgb), 0.85);
            --brand-experiment-90a: rgba(var(--primary-rgb), 0.9);
            --brand-experiment-95a: rgba(var(--primary-rgb), 0.95);

            /* Generate with https://coolors.co/3498db SHADES AND TINTS */
            --brand-experiment-100: #f0f8fc;
            --brand-experiment-130: #f0f8fc;
            --brand-experiment-160: #e2f0fa;
            --brand-experiment-200: #e2f0fa;
            --brand-experiment-230: #d3e9f7;
            --brand-experiment-260: #c5e2f5;
            --brand-experiment-300: #a8d3f0;
            --brand-experiment-330: #99cbed;
            --brand-experiment-360: #8bc4ea;
            --brand-experiment-400: #7cbde8;
            --brand-experiment-430: #6db5e5;
            --brand-experiment-460: #429fde;
            --brand-experiment-500: var(--primary);
            --brand-experiment-530: #268fd5;
            --brand-experiment-560: #2384c5;
            --brand-experiment-600: #2384c5;
            --brand-experiment-630: #2079b5;
            --brand-experiment-660: #1d6ea4;
            --brand-experiment-700: #175883;
            --brand-experiment-730: #144d73;
            --brand-experiment-760: #114262;
            --brand-experiment-800: #0e3752;
            --brand-experiment-830: #0c2c42;
            --brand-experiment-860: #092131;
            --brand-experiment-900: #061621;
          }

          /* Hide ads */
          section[aria-label="User area"] > div[aria-hidden="false"] {
            display: none;
          }

          /* Activity */
          /*
          .theme-dark [class^="container"] {
            background-color: var(--bg-primary);
          }
          */
          /*.theme-dark [class^="container"] {
            background-color: unset;
          }*/

          /* Modal */

          .theme-dark [class^="uploadModal"] {
            background-color: var(--bg-primary);
          }

          /*
          .theme-dark [class^="footer"] {
            background-color: var(--bg-secondary);
            box-shadow: none;
          }
          */

          /* Autocomplete */

          .theme-dark [class*="autocomplete-"] {
            background-color: var(--bg-primary);
          }

          .theme-dark [class*="selectorSelected"] {
            background-color: var(--bg-secondary);
          }

          .theme-dark [class*="autocomplete-"] [class*="selected"] {
            background-color: var(--bg-tertiary);
          }

          /* Scrollbar */
          .theme-dark [class*="scroller"][class*="auto"]::-webkit-scrollbar-track-piece {
            background: transparent;
          }

          .theme-dark [class*="scroller"][class*="auto"]::-webkit-scrollbar-thumb,
          .theme-dark [class*="scroller"][class*="thin"]::-webkit-scrollbar-thumb {
            background-color: var(--bg-tertiary) !important;
            border: 0;
          }

          .theme-dark [class*="scroller"][class*="auto"]::-webkit-scrollbar {
            width: 8px;
          }

          .theme-dark [class*="scroller"][class*="thin"]::-webkit-scrollbar {
            width: 6px;
          }

          .theme-dark [class*="scroller"][class*="auto"]::-webkit-scrollbar-track-piece {
            border: 0;
          }

          /* Hide annoying reaction popup */
          [class*="message"][class*="selected"]
            [class*="buttons"]
            .mouse-mode
            [class*="message"]:hover
            [class*="buttons"] {
            display: none;
          }

          /* More space on new message */
          [class*="divider"] {
            margin-top: 11px !important;
            margin-bottom: 12px !important;
          }

          *[class*="markup"] code {
            background: var(--bg-secondary);
            border-color: var(--bg-tertiary);
          }
        '';
      };
    };
  };
}
