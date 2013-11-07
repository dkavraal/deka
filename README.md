deka
===============
Deka Thumb Generator

You could use this script(s) to generate your own thumbnail gallery for the pictures/photos you have. Here is a screenshot taken from browser window to know what to expect.
![capture](https://f.cloud.github.com/assets/4558966/1492573/3edfb9c0-47c2-11e3-8dbd-6fd6316a5f99.PNG)


Requirements
===============
- bash | GNU bash, version 4.2.25(1)-release (x86_64-pc-linux-gnu)
    - ls,find,echo,printf,|,mkdir :)
- imagemagick | ImageMagick 6.6.9-7 2012-08-17 Q16 http://www.imagemagick.org
- wget (for the sample directory)
- no need for root access

Used Libraries
===============
- lib_progress_bar | http://www.brianhare.com/wordpress/2011/03/02/bash-progress-bar/#codesyntax_1
- Thumbnail Grid | http://tympanus.net/codrops/2013/03/19/thumbnail-grid-with-expanding-preview/

How To Use/See Sample
==============
- download this repository as a zip / or as you like
- run as:
    - # /bin/bash queries/deka.sh SAMPLEPICS
    - this will generate required files and "my.html" inside the show/ folder, you can see that (maybe you should set variables inside the "./queries/deka.sh", you will see there.

