# carp

_Call Aware Radio Player_

![](logo.jpg)

A radio player which stops playing whenever a call is joined. Playing is resumed after the call has ended.

Tested on Ubuntu Linux with:

- MS Teams
- Slack Hangouts

carp is implemented in a single shell script.

## Preconditions

- Linux with Pulse Audio Environment
- _mpg123_ and _pactl_ installed.

On Ubuntu you can satisfy the preconditions with

`sudo apt install mpg123 pulseaudio-utils`


## Working Principle

`carp.sh` is a shell script which polls the status of your microphone(s) every second.

- whenever a microphone becomes used, `carp.sh` assumes that a call has started.
- whenever all microphones become available again, `carp.sh` assumes that the call has ended.

In order to pause / resume a radio station it needs to know two things from you:

## Execution

Just run `./carp.sh` in your terminal. It will offer you a list of predefined radio stations and play on your default output device.

Use these available options to override the default behaviour:

```
./carp.sh --help
Call Aware Radio Player

USAGE:
 ./carp.sh [OPTIONS]

OPTIONS:
-u, --url <radio_stream>     Radio stream to play (see https://streamurl.link/)
-o, --output <pa_device>     Pulse Audio device to play on (see 'pactl list short sinks')
```
