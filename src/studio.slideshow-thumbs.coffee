###

Slideshow Application
========================================================================================================

Description:  Basic slideshow with thumbnail images, no frameworks, fading with controls.

Dependencies: Modernizr, for js detection

Version:      1.0
Created:      2013-06-05
Last Mod:

Notes:

========================================================================================================

###

# ===============================================
# Coffeescript Module Pattern for reference

# SAMPLE COFFEE MODULE PATTERN
# Namespace the application using this with an empty object if is not null
# @STUDIO = @STUDIO ? {}

# STUDIO Module for Slideshow
# @STUDIO.sampleModulePattern = do ->

#   # Private

#   # private properties
#   myPrivateVar = "myPrivateVar accessed from within the Studio.sampleModulePattern"

#   # private methods
#   myPrivateMethod = ->
#     console.log("myPrivateMethod accessed from within the Studio.sampleModulePattern")

#   # Public

#   # using the : with the property adds a return
#   # the return opens the properties and methods public access
#   # from within the public interface you can access the private methods and properties

#   # public properties
#   myPublicProperty: "myPublicProperty is being accessed in here!"

#   # public methods
#   myPublicMethod: ->
#     console.log("<--- myPublicMethod called ---> ");
#     # Within sampleModulePattern, you can access private
#     console.log(myPrivateVar)
#     myPrivateMethod()


# MODULUS info, because you're not so good at math or remembering remainder action
# 30 % 10 = 0 -> the remainder is .0 ( 30/10 = 3.0 )
# 43 % 10 = 3 -> the remainder is .3 ( 43/10 = 4.3 )
# 1 % 4 = 1 -> the remainder is rounded to 1 from ( 1/4 = 0.25 ) ??


# Window attached instead of a namespaced module
addLoadEvent = (func) ->
  oldonload = window.onload
  if typeof window.onload isnt 'function'
    window.onload = func
  else
    window.onload = ->
      oldonload()
      func()


# ===============================================

# Namespace the application using this with an empty object if is not null
@STUDIO = @STUDIO ? {}

@STUDIO.slideshow = do ->

  # private
  # slideshow = slides = photos = playback = next = prev = "unknown"

  # public
  initSlides: (slideWrapper) ->
    console.log "+++ initSlides called +++"
    curImage = 0
    loadedSlideCount = 0
    slideshow = document.getElementById(slideWrapper)
    slides = slideshow.getElementsByTagName("div")
    photos = slideshow.getElementsByTagName("img")
    # thumbs = slideshow.getElementById("thumbs")
    totalImageCount = photos.length
