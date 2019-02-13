Image Utils
===========

Image / video tools I've written over the years, mostly for use with netpbm
or pbmplus tools. The oldest are from 1999 and the newest are current. Some
are used basically daily by me still, and some were one-offs or used only
briefly.

The PBM/PGM/PPM... image formats are designed as programmer-friendly
intermediate files. They have no compression and somewhat ungainly file sizes,
but are easy to read and write. The original tools were the `pbmplus` package
from 1988, but many newer tools are in the `netpbm` package.

1. PBM is a 1 bit per pixel image format
2. PGM is a gray scale image, usually 8 bit but potentially up to 16 bit per pixel
3. PPM is an RGB image format, usually 8 bits per channel (24 bits per pixel) but potentially up to 16 bits per channel (48 bits per pixel)
4. PNM is a wildcard name for the those three formats
5. PAM is an extension to arbitrary images (eg non-RGB color) used by some netpbm tools, but less widely supported

Tools
-----

* addtext - adds text to an image in a limited fashion
* apply-rain - overlay `mkrain` output on an image
* asci - view an image as ascii (pbmtoascii)
* asciiversion - makes an ascii art image (`pbmtoascii`), then converts that text to pgm
* asciiversion2color - makes red/green/blue ASCII versions, and an HTML file that overlays the channels

* blowaway - a many scraps of paper blowing away effect

* colorascii-2014 - makes multiple sized and colored ASCII art versions then overlays them all to one image
* colorizeascii - from a PPM file and a text file, create color html
* contactsheet - make a pan-n-scan "contact" sheet  by chopping an image into multiple overlapping tiles and reassembling them, uses `mkfilmframe` and `pnmchop`

* frames-to-video - `mencoder` wraper to turn a series of JPEGs into a video clip

* histo - very succinct summary of `ppmhist` output
* histochart - quant then `ppmhist` then make fig format color swatch chart

* generic-subtitles - subtitle template generator for video-explode
* gifexplode - explode an animated gif into frames

* jpeg2000toppm - makes `j2k_to_image` from openjpeg-tools behave like a regular `*toppm` tool
* joydivision - duplicate the graph effect of Joy Division's _Unknown Pleasures_ -- coded against prerelease Image::Xfig 0.20

* ledpixelize - pixelize an image in the style of an LED screen
* linenormalize - normalize image contrast on a line-by-line basis

* mkanimgif - make an animated gif with `gifsicle` or `convert`
* mkbmp - convert a large number of pnm files to bmp
* mkcenter - pad an image to be in the center of a box
* mkfavicon - from one image create a favicon.ico with multiple embedded icon sizes
* mkfilmframe - make film frame border
* mkgif - convert a large number of pnm files to gif
* mkjpg - convert a large number of pnm files to jpg
* mkmasks - create many pbm single color specific image masks from one image
* mkmanymosaic - I made a lot of index mosaics with this
* mkmosaic - pnmcat in to rows and columns
* mkpng - convert a large number of pnm files to png
* mkppm - convert a large number of pnm files to ppm
* mkrain - rain drop effect
* mkrotate - make sets of rotated images or make a line be level
* mkspinner - rotate in small increments to maximize distortion, make animation of results
* mktextframes - convert free form text to block frames for use with `pbmtext` or `texttopnm`
* mkthnail - convert a large number of files to thumbnails
* mktiled - pnmcat in to rows and columns (less complex than `mkmosaic`)
* mktiledimage - fill a space by tiling an image
* mkvector - "Vectorizes" an image, after Randal L. Schwartz's image duplicate identification algorithm (**not** vector art)
* mkvidpano - naively turns frames of a video pan into a panorama

* padimage - pad an image to a particular size
* pgmtoascii - Convert PGM to ASCII art.
* pgmtoibmascii - Convert PGM to block character art (IBM/ANSI) blocks
* pgmtohalftonepbm - Expand pixels in a PGM to make "halftone" pbm images
* pgmtomosaic - makes a mosaic using tiles selected from a small number of images
* pnmchdim - Change the dimensions of a PBM/PGM/PPM file without changing the image data.
* pnmchop - chop an image into tiles with or without overlap
* pnminfo - Print information about PBM/PGM/PPM files
* pnminfomax - find min/max sizes for a group of PBM/PGM/PPM files
* pnmsupersampler - Simulates the effect of a multishutter supersampler type camera
* ppmlowbit - Extract low order bits from an image and make those high order bits (steganographic tool)
* ppmmosaic - enlarge pixels to create mosaic-like images
* ppmstegan - trivial steganographic tool

* redact - randomly blackout (censor) parts of an image
* reverse-clip - `video-explode | reverse | frames-to-video`
* rgbtriptych - create red/green/blue triptych from an image
* rorschach - reduce colors, halve, and mirror an image for a Rorschach test version

* sliceoflife - create an image from random bands of an original
* stripehide - hide a PBM/PGM image in stripes, pops out from a distance

* texttopnm - replacement for `pbmtext` that uses one image per character

* video-explode - `mplayer` wrapper to turn video into jpeg frames


Libraries used
--------------

* fonts.tar.gz font files for use with `texttopnm`

* Image::PBMlib.pm - version 2 of my PBM (and PGM, and PPM) Perl library

* Image::Xfig.pm - a library for creating .fig files for Xfig

