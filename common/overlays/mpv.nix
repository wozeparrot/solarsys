self: super:
{
  mpv = super.mpv-with-scripts.override {
    scripts = [
      self.mpvScripts.mpris
      self.mpvScripts.autoload
      self.mpvScripts.thumbnail

    ];
  };
}
