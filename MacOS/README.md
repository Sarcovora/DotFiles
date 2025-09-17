# Additional Changes

Use the mocha maroon theme from Catpuccin for LazyGit ([Github](https://github.com/catppuccin/lazygit))

- Use `lazygit --print-config-dir` to show where the config directory is.
- Paste the corresponding file from the lazygit config file in this repo into the `config.yml` there already.

Sample ssh configs:

```sh
Host <nickname1> # <nickname2 (optional)>
  HostName <destination>
  User <username>
  ForwardX11 yes # (optional)
  LocalForward 16006 127.0.0.1:6006 # forwarding for something like summary writer
  SetEnv TERM=xterm-256color # for ghostty
```
