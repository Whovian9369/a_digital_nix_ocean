{pkgs, ...}:
{
  services = {
    xrdp = {
      enable = true;
      defaultWindowManager = "${pkgs.xfce.xfce4-session}/bin/xfce4-session";
      openFirewall = false;
    };

    xserver = {
      enable = true;
      desktopManager = {
        xfce.enable = true;
      };
      displayManager = {
        lightdm.enable = true;
    };
  };

    displayManager.defaultSession = "xfce";

  };

  environment.systemPackages = [
    pkgs.dejavu_fonts
    pkgs.emojione
    pkgs.firefox
    pkgs.xclip
    pkgs.xorg.xeyes
    pkgs.xfce.thunar
    pkgs.xfce.thunar-volman
    pkgs.xfce.xfce4-cpugraph-plugin
    pkgs.xfce.xfce4-dict
    pkgs.xfce.xfce4-eyes-plugin
    pkgs.xfce.xfce4-netload-plugin
    pkgs.xfce.xfce4-notes-plugin
    pkgs.xfce.xfce4-notifyd
    pkgs.xfce.xfce4-pulseaudio-plugin
    pkgs.xfce.xfce4-screensaver
    pkgs.xfce.xfce4-screenshooter
    pkgs.xfce.xfce4-session
    pkgs.xfce.xfce4-settings
    pkgs.xfce.xfce4-systemload-plugin
    pkgs.xfce.xfce4-taskmanager
    pkgs.xfce.xfce4-terminal
    pkgs.xfce.xfce4-verve-plugin
    pkgs.xfce.xfce4-weather-plugin
    pkgs.xfce.xfce4-whiskermenu-plugin
    pkgs.xfce.xfwm4-themes
  ];
}
