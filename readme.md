# sedscripts
## What is sedscripts?

**sedscripts** is a command line tool that is used for blazing fast replacements of text in config files. It feels like english language and does not use the awkward awk patterns or sed commands seperated by percentages and other symbols. Instead the syntax of sedscript is very simple.For example, say if you want to get the value of `fading` in   `picom.conf`. 
Usually people perfer to use `cat picom.conf | grep fading` which produces some output like `fading = true;`.

But wait. What if you need just the value? You need to get the value of `fading` and the output should be only `true` and not `fading = true`. Then each time you have to use `sed` to filter it to output just `true`. And that one is a bit messy with patterns.

**sedscripts** helps you in this context. Give me that one exact value. It is very useful when you are editting configuration files.

> [!NOTE]
> I have not added support for .ini files yet. It works well with the following configuration files.

## File Supports and Formats
sedscripts can extract and edit variables or values only from the below given file formats.

### 1) Bash Variables files

Say you have a `shell script` in which you have stored system variables for running a specific command which uses them. For example, in my **bspwm configurations**, I have a **settings.sh** file which consists variables for applying configurations to my `bspwm` and is sourced in another file **configs.sh** so that I could directly call it in `bspwmrc` like `bspc config border_width $WIDTH` where the `$WIDTH` is specified in `settings.sh`

From this below given shell, if I want to get the value of `IS_BSPWM_BORDER` variable, then I could get it very easily like given below.

```bash
#!/bin/bash

#################### Paths and exports ############################


PTH="$HOME/.config/bspwm/bspwm.d"
source "$PTH/exports.sh"



################### Borders ############################
#------------------ Border Color -----------------------

# focused border color
BSPWM_FBC='#414868'

# normal border color
BSPWM_NBC='#1e1e2e'

# active border color
BSPWM_ABC='#000000'

#------------------ Border Properties ------------------

# Is border enabled?
IS_BSPWM_BORDER=true

# Border width or thichness
if [[ $IS_BSPWM_BORDER == true ]]; then
    BSPWM_BORDER='2'
else
    BSPWM_BORDER='0'
fi
```

**Getting values**

```bash
# sedscripts followed by get_kv <flags> <key> <seperator> <fallback> <filename>
sedscripts get_kv --strict IS_BSPWM_BORDER = "does not exist" settings.sh
# outputs true
```

**English Explanation?**
All you want to know is how to command in english. That's it and you have learnt the sedscripts.
The above command simple says : 
*hey sedscripts, get the key value of IS_BSPWM_BORDER seperated by "=" and if it does not have, give me fallback value "does not exist" in strict mode from `settings.sh`*

**Modes?**
Yeah, `get_kv` subcommand of sedscripts has modes, which can be supplied with flags.

- `--strict` : removes all whitespaces, quotes, comments, trailing semicolons
- `--trim-quotes` : trims trailing quotes
- `--trim-comments, --trim-spaces, --trim-semicolon` : They all remove trailing comments, spaces, semicolons respectively.

> [!NOTE]
> It is better to go with `--strict` flag always. And if you ever wanted to use the other flags, use it wisely. Say you have a variable defined as `var :  "   this is a var ";# This is a comment followed by variable ` you should use the flags recursively. First trim the comments, then trim the semicolons, spaces and finally strip the quotes. See the exact command, assuming that this variable is located in file crim.sh, below 

```bash

sedscripts get_kv --trim-comments --trim-semicolon --trim-spaces --trim-quotes var : "dne" crim.sh 

# Output : this is a var
```

**Alternatively, just use strict mode and it solves the problems**
In the previous example we saw that the `var` includes comments, spaces, quotes, semicolons, i.e that is everything `--strict` flag removes. 

```bash
sedscripts get_kv --strict var : "dne" crim.sh
```

also gives us the same output.

### .conf files
sedscripts supports `.conf` files too. For example picom.conf, which is usually laid out in the format : 

```bash
fading = false;

fade-in-step = 0.1;
fade-out-step = 0.1;
no-fading-destroyed-argb = true
fade-delta = 1

animations = false

animation-stiffness = 100;
animation-dampening = 30;
animation-clamping = false;
animation-easing = "ease-out";

# animation-for-open-window = "slide-right";
animation-for-unmap-window = "slide-left";
#animation-for-transient-window = "slide-down";
```

Here, each value either ends with a semicolon or a quote. Strict mode usually works fine here.

To get the value of `animation-for-unmap-window` we can use sedscripts like 

```bash
sedscripts get_kv --strict animation-for-unmap-window = fallback picom.conf
# output : slide-left
```

Alternatively use 

```bash
sedscripts get_kv --trim-spaces --trim-semicolon --trim-quotes animation-for-unmap-window = fallback picom.conf
```

### In General
sedscripts can write and extract values from any files which do not have repeated variables (in most of the cases the config.ini files repeats the variables **so sedscripts is unsupported**).

**Even weird files seperators are supported**

Say there exists a configuration file which does not use default `=` or `:` as it's seperator, but instead uses `-->` as it's seperator? Yeah. `sedscripts` work well here as well.

```bash
# This is the sample weird file : weird.weird
key1 --> "value1"
key2 --> "value2"

```

Let's say that you want to get the value of `key1` from that file `weird.weird` then all you want to do is just change the seperator.

```bash
sedscripts get_kv --strict key1 "-->" "give some fallback value" weird.weird

# output : value1
```

