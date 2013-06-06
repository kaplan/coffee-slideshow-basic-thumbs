Basic Slideshow with Controls and Thumbs
========================================

This is the next step in the basic slideshow, no libraries, but using thumbnail images to navigate in addition to the toggle playback, next and previous.

Super basic like the [previous version](https://github.com/kaplan/coffee-slideshow-basic), using the pretty much the same files and setup. CoffeeScript and understanding what's going on underneath a framework or an (as best I can) is the primary focus here.

More Details
------------
This version of the slideshow is built on the original non-thumb one Somewhat fewer comments as a guide for myself in this version, thought being I can always go back to the original-original for reference, which I seem to do with lots of stuff. Just like the original I'm trying to do as much plain JavaScript through learning CoffeeScript as I can, later libraries.

The thumbs have a custom attribute, data-, that is pretty neat for semantic markup that you can use in your JavaScript. The ones used here are very simple, just an id for the thumb/slide that will help in setting the current image. If you look at the very bottom I have a little explaination copied from the [HTML5Doctor page](http://html5doctor.com/html5-custom-data-attributes/) where I learned about these.

Future Goals
------------
* Learn how to use Docco and do a better job of comment and documenting
* Leave no dead code or concept exploration code
* Future version: Add jQuery and Greesock Animation Library
