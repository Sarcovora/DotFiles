# My Dotfiles and Custom Scripts

- `/dev` is a directory for all my custom scripts

## Sudo-less installs

### Tree

```mkdir ~/deb && cd ~/deb```
```apt download tree```
```dpkg-deb -xv ./*deb ./```

Now add the following to your `.rc` file: `alias tree="$HOME/deb/usr/bin/tree"`
