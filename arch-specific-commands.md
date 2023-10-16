# Arch specific

Cleanup orphaned packages
```
pacman -Rsn $(pacman -Qdtq)
```

Use the awesome tool to look for large stuff in current directory - remember to install first `pacman -S ncdu`
```
ncdu
```

Clear out pacman cache
```
pacman -Sc
```

Clear down old journals
```
journalctl --vacuum-size=50M
```
