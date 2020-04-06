domain-name-from-wikipedia
==========================

dfw.sh (`d`omain name `f`rom `w`ikipedia) can fetch website official URL from Wikipedia.

## How to use

```
Usage:
  ./dfw.sh <search_text>

Open link in browser:
  DFW_OPEN_BROWSER=true ./dfw.sh <search_text>
```

### Example

- Fetch URL link of `Apple`:

```bash
~$ ./dfw.sh apple company
http://www.apple.com
```

- Open `Twitter` webpage:

```bash
~$ DFW_OPEN_BROWSER=true ./dfw.sh twitter
```

## Credits

Inspired by project [DNS over Wikipedia](https://github.com/aaronjanse/dns-over-wikipedia)
