{ config, lib, pkgs, inputs, ... }:
with lib;
let
  hm = config.home-manager.users.${config.rde.username};
  emacs-init = "${hm.xdg.configHome}/emacs/init.el";
  emacs-early-init = "${hm.xdg.configHome}/emacs/early-init.el";
in {

  imports = [ ./tmp.nix ];
  options = {
    rde.emacs = {
      enable = mkEnableOption "Enable rde emacs";
      layers = {
        enableEverything = mkEnableOption
          "Enable all rde emacs layers with all keybindings and features";
        use-package = { enable = true; };
        reasonable-defaults = { a = { }; };
        mu4e = {
          system-packages = with pkgs; [ offlineimap mu4e ];

          config = { rde.email-sync.enable = true; };
          keybindings = false;
          enchanceBehaviour = true;
        };
      };
    };
  };

  config = mkIf config.rde.emacs.enable {
    _module.args.emacs-dir = "${hm.xdg.configHome}" /emacs;
    home-manager.users.${config.rde.username} = {
      home.file."${emacs-init}".text = mkBefore (readFile ./init.el);
      home.file."${emacs-early-init}".source = ./early-init.el;

      home.packages = with pkgs; [ emacs-all-the-icons-fonts sqlite ];
      programs.emacs = {
        enable = true;
        package = pkgs.emacsGit;
        extraPackages = epkgs:
          with epkgs; [
            use-package
            nix-mode
            magit
            modus-operandi-theme
            org
            org-roam
            company-org-roam
            company
            ivy
            olivetti
            restart-emacs
            keycast
          ];
      };
    };
  };
}
