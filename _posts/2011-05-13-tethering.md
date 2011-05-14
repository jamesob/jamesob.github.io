---
title: Tether your droid to Arch Linux
layout: post
---

Before Mike and I head out on our adventure on Wednesday, I wanted to get Droid
tethering working so that we can blog about our horrific roadside deaths as
they happen (I am a progeny of web2.0, after all). 

The process only took an afternoon and was surprising straightforward. Here are
the steps I followed.

## Root the Droid

I followed [these
steps](http://www.droidforums.net/forum/droid-labs/74028-root-droid-1-regardless-os-version.html)
without much snag. I did have to google for a copy of RSD Lite 4.6
and fare the unsavory waters of mediafire, but that wasn't a big deal.
The most complex part of this step was operating a Windows 7 machine without
getting violently sick.

## Flash with a ROM

I googled around for a Droid ROM that was reputed to have good battery life and
found this [steaming pile of
gloss](http://www.droidforums.net/forum/android-roms/101662-rom-charity-smoked-glass-themed-version-11-froyo-2-2-1-frg83d.html).
I flashed it in pretty much the same way that the root patch was flashed, first
clearing all data from the phone:

1. copy the zip to the base of the Droid SD card,
2. boot into SPRecovery by holding 'x,'
3. select `wipe data/factory reset`,
4. select `Allow update.zip installation`,
5. finally, `Install /sdcard/update.zip (deprecated)`.

Make sure you do step 3; I ended up in a bootloop the first time I tried this
because of a dirty cache.

## Tether for profit

If you're on one of the major Linux distros, namely Ubuntu or Fedora,
you're done: see [this guy's
page](http://www.humans-enabled.com/2009/12/how-to-tether-your-verizon-droid-as.html).

If, on the other hand, you regularly forgo sex in lieu of supporting inanity like
"design principles" in software, you may be an Arch Linux user. If so, there's a
little work left to be done.

1. Install `android-sdk`, `android-sdk-platform-tools` from AUR.  I had to
   enable multilib mirrors in `/etc/pacman.conf` to find the dependencies necessary
   for `android-sdk`.

2. Clone [this](https://github.com/jamesob/droid-arch-tethering) and run 
my modified version of [Shannon
VanWagner](http://www.humans-enabled.com/2009/12/how-to-tether-your-verizon-droid-as.html)'s
crazy-ass script. Things I know about
this script: 

	1. it tunnels traffic through a VPN to your phone 
	2. it looks like it was written by Ghengis Khan (before python2.7).

 Make sure your Droid is connected during install. Follow the instructions
 included in his original README.

## Enjoy your data

Feels good, bro.

