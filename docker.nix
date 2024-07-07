{
  config,
  ...
}:

{
  virtualisation.docker = {
  /*
    enable = true;
    extraOptions = "";
      # Supports strings concatenated with " "
        # wtf does that mean in this context????
        # Is it just "-a -b -c -d -e -f"?
    extraPackages = [
      pkgs.PACKAGE_NAME
    ];

    listenOptions = [
      "/run/docker.sock"
    ];
  */
    rootless = {
      # daemon.settings = { };
      enable = true;
      setSocketVariable = true;
    };
    storageDriver = "overlay2";
  };
}
