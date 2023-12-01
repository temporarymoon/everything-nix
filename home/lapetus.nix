{
  imports = [ ./global.nix ];

  # Arbitrary extra packages
  home.packages = [ ];

  # Set up my custom imperanence wrapper
  satellite.persistence = {
    enable = true;

    # Actual data/media (eg: projects, images, videos, etc)
    at.data.path = "/persist/data";
    at.data.prefixDirectories = false;

    # App state I want to keep
    at.state.path = "/persist/state";

    # App state which I should be able to delete at any point
    at.cache.path = "/persist/local/cache";
  };
}
