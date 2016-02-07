---
title: "Copying music from an iPod: a command-line win"
layout: post
published: true
abstract: "The effectiveness of a command-line environment is nicely demonstrated
by the task of copying an iPod's music to a computer."
published: false
---

Being a somewhat outspoken Unix advocate, I'm sometimes asked to explain why
using an operating system that takes the command-line seriously
is advantageous over using an OS that relegates it in favor of graphical
interfaces. In other words, what makes the CLI so useful over a GUI?

Usually I'll respond with a flurry of jargon, using words like "programmatic,"
"scriptable," and "expressive," but I usually lack a clutch example to
illustrate what these terms mean to those who haven't sipped the Unix Koolaid.

I hit a problem today that struck me as an especially good illustration of why
the command-line is such a useful tool to be familiar with.

## My music is stuck on my iPod

After realizing the that I'd be ripping my music collection off of the iPod, I
was presented with two options:

1. Pay $19.95 for a nice looking [piece of
software](http://thelittleappfactory.com/irip/) that'd do this whole thing
   for me.
2. Laboriously [copy the music
over](http://macs.about.com/od/backupsarchives/ss/copy-ipod-music-to-mac.htm) from the iPod in the graphical file browser
   from each of the 49 hidden files from the mounted iPod. The reason we have to
   copy from one of the 49 files at a time is because we're ultimately going to use iTunes
   to reorganize the obscured files into a pleasant hierarchy; in order to do
   this, the files cannot be nested within the directory we import.

Being a part-time cheapskate, I jettisoned the possibility of (1) almost
immediately. Option (2) seemed feasible, and in fact I started the monotonous
task of dragging and dropping. 

By folder number 3, I asked myself what the hell I was doing.

## Salt and pepper

The drag-and-drop approach is slightly embarrassing and, worse, error-prone.
What if I accidentally skipped over folder 38? There goes half of my Stereolab
collection. I came to my senses and saw through to a better approach using the
command-line. Without further ado, here's

### jamesob's recipe for restoring a music collection from an iPod

1. Ensure iTunes isn't open and the iPod is disconnected.
2. Mount your iPod without syncing by holding Option+Command and connecting the
iPod to your computer.
3. Hold down Option+Command until you see a message along the lines of "Your
iPod is in safe mode."

    * If you are prompted to sync, *do not answer*.

4. Fire up a terminal window. Navigate to the iPod.

        $ cd /Volumes/James\ O\'Beirne's\ iPod/

5. Navigate to where the music files are stored.

        $ cd iPod_Control/Music
        $ ls 
        F00 F03 F06 F09 F12 F15 F18 F21 F24 F27 F30 F33 F36 F39 F42 F45 F48
        F01 F04 F07 F10 F13 F16 F19 F22 F25 F28 F31 F34 F37 F40 F43 F46 F49
        F02 F05 F08 F11 F14 F17 F20 F23 F26 F29 F32 F35 F38 F41 F44 F47

6. Easy, now. These files all contain your raw music, so be careful. This is the
step where the programmatic beauty of the command-line comes into play. We're
going to create an intermediary folder somewhere on the computer, then step in
and out of each directory, copying its innards to the intermediate folder[^2]
using some quick BASH.

        $ mkdir ~/iPod_music   # make a temporary directory
        $ for i in `ls`; do \       # for each of these crazy folders
        >   echo $i \               # let me know which folder we're in
        >   && cd $i \              # step into the folder
        >   && cp * ~/iPod_music/ \ # copy all music files onto computer
        >   && cd .. \              # return to the parent directory
        > done
        F00
        F01
        F02
        ...
        F47

7. Boom, now all of your files are on-system. Easy and error-free. Copy the
files into iTunes and your music collection is automatically reorganized.


## Prompt

That was a very basic way to 

