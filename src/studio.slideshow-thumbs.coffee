###

Slideshow Application
========================================================================================================

Description:  Basic slideshow with thumbnail images fading with controls sans library (why? idk)

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

  slideshow = slides = photos = thumbs = playback = next = prev = "unknown"
  curImage = slideCount = totalImageCount = loadedSlideCount = 0
  fadeInContainerTimeout = slideshowTimeout = fadeOutTimeout = null
  slideshowPaused = false

  # FOR IMAGE LOADED COUNTING
  onImageLoad = (slideOrder) ->
    # after each imaage is loaded make sure it's display is not 'none'
    # bc in the CSS these all start display none, which hides them before they completely load in IE
    slides[slideOrder].style.display = "block";

    loadedSlideCount++
    console.log "loading an image #{slideOrder}"
    console.log "loadedSlideCount is #{loadedSlideCount}"

    if totalImageCount is loadedSlideCount
      console.log "+ ================== +"
      console.log "+ ALL IMAGES LOADED! +"
      console.log "+ ================== +"

      #  After all the images are loaded fade up the container with: fadeInContainer()
      #  Then when the container fade up is done, start the slideshow running.
      #  Increase compatibility with unnamed functions

      fadeInContainerTimeout = setTimeout(->
        console.log "!! ALL IMAGES LOADED: FADE IN THE SLIDESHOW CONTAINER !!"
        # the 0 is what we're fading up from, 500 is a delay of .5 seconds
        fadeInContainer slideshow, 0, 500)

      fadeInThumbs = setTimeout(->
        fadeInObject thumbs, 0, 500)


  # FOR ALL FADING INTERVAL CALLS
  setOpacity = (obj, opacity) ->
    # Firefox flicker fix ?
    # opacity = (opacity == 100)?99.999:opacity;

    # IE/Win
    obj.style.filter = "alpha(opacity:"+opacity+")"

    # Safari<1.2, Konqueror
    obj.style.KHTMLOpacity = opacity/100

    # Older Mozilla and Firefox
    obj.style.MozOpacity = opacity/100

    # Safari 1.2, newer Firefox and Mozilla, CSS3
    obj.style.opacity = opacity/100

    # opacity = (opacity == 100)?99.999:opacity;
    obj.style.opacity = opacity / 100


  # FADE IN for general purpose
  fadeInObject = (obj, opacity) ->
    if opacity <= 100
      setOpacity(obj, opacity)
      opacity += 2
      fadeInObjectTimeout = setTimeout(->
        fadeInObject obj, opacity, 200)
    else
      clearTimeout fadeInObjectTimeout
      console.log '*** done with fadeInObject ***'


  # FOR INITAL WRAPPER FADE UP INTERVAL
  fadeInContainer = (obj, opacity) ->
    if opacity <= 100
      # console.log "fade in slide #{opacity}"
      setOpacity(obj, opacity)
      opacity += 2
      fadeInTimeout = setTimeout(->
        fadeInContainer obj, opacity, 200)
    else
      console.log "+++ fadeInContainer complete +++"
      # clear the timeout that did this fading
      clearTimeout(fadeInTimeout);

      # clear the timeout that called this method
      clearTimeout fadeInContainerTimeout

      # anonymous setTimeout with multiple methods or property settings,
      # you need the new line that has comma with delay amount or an error is thrown
      slideshowTimeout = setTimeout(->
        console.log  "*** slideshow playing, first time start ***"
        runSlideshow()
        slideshowPaused = false
      , 4000)


  runSlideshow = ->
    console.log "+++ runSlideshow called +++"
    console.log "curImage is #{curImage}"
    console.log "next image is: #{photos[(curImage + 1) % slides.length].alt}"

    # SETTINGS ON NEXT IMAGE IN STACK
    # make the next image in the stack visible (look in the top from some modulus info, which you always forget)
    # and that it's opaque when you fade out the current image, which will reveal the one under
    slides[(curImage + 1) % slides.length].style.visibility = 'visible'
    setOpacity(slides[(curImage + 1) % slides.length], 100)

    # clear the timeout that called this method
    console.log "slideshowTimeout ID: #{slideshowTimeout}"
    clearTimeout slideshowTimeout
    console.log "slideshowTimeout ID: #{slideshowTimeout}"

    # FADE OUT current image
    fadeOutSlide(slides[curImage % slides.length], 100)

  fadeOutSlide = (obj, opacity) ->
    if opacity >= 0
      # console.log "fade out slide #{opacity}"
      setOpacity(obj, opacity)
      opacity -= 2
      fadeOutTimeout = setTimeout( ->
        fadeOutSlide obj, opacity, 200)
    else
      console.log "+++ fadeOutSlide complete +++"

      # clear the timeout used to fade the current image, just finished
      clearTimeout fadeOutTimeout

      # HIDE the current image that just had the next one faded over it
      slides[curImage % slides.length].style.visibility = 'hidden'

      # SHUFFLE INDEX
      reorderLayerStack()

      # increase the curImage
      curImage++

      # check to see if the curImage is 0, in that case we'll reset
      # if curImage % (slides.length) is 0
      #   curImage = 0
      #   console.log "*** reset curImage ***"
      # shorter still, but no logging
      curImage = 0 if curImage % slides.length is 0

      # check to see if the slideshow is paused, if not runSlideshow again
      slideshowTimeout = setTimeout(runSlideshow, 3500) unless slideshowPaused

  fadeOutSlideAdvance = (obj, opacity, direction) ->
    if opacity >= 0
      console.log "fade out slide #{opacity}"
      setOpacity(obj, opacity)
      opacity -= 2
      fadeOutTimeout = setTimeout( ->
        # note: you're looking at passing arguments in () no commas used outside of there but you need a new line
        # fadeOutSlideAdvance(obj, opacity)
        # 200)
        fadeOutSlideAdvance obj, opacity, 10)
    else
      console.log "+++ fadeOutSlideAdvance complete for advancing slide +++"
      obj.style.visibility = 'hidden'

      # call the runSlideshow so the show keeps running
      slideshowTimeout = setTimeout(runSlideshow, 3500) unless slideshowPaused

      # Reorder the layer stack
      shuffle = ->
        slides[_i].style.zIndex = ((slides.length - _i) + (curImage - 1)) % slides.length
      shuffle slide for slide in slides
      return true


  setVisibilityForAdvance = (direction) ->
    console.log "+++ setVisibilityForAdvance called: slide advance direction #{direction.name} +++"

    # check the direction to determine which 'next or prev' image should be visible
    # so that it is visible when the current image fades out.
    switch direction
      when next
        slides[(curImage + 1) % slides.length].style.visibility = 'visible'
      when prev
        console.log (curImage - 1) % slides.length
        slides[(curImage - 1) % slides.length].style.visibility = 'visible'
      else
        break


  reorderLayerStack = ->
    # console.log "+++ shuffle z-index +++"
    # console.log "+++ shuffle z-index: #{slides.length} +++"

    shuffle = ->
      slides[_i].style.zIndex = (((slides.length) - _i) + curImage) % slides.length
    shuffle slide for slide in slides
    return true


  # public

  initSlides: (slideWrapper) ->
    console.log "+++ initSlides called +++"
    curImage = 0
    loadedSlideCount = 0
    slideshow = document.getElementById(slideWrapper)
    slides = slideshow.getElementsByTagName("div")
    photos = slideshow.getElementsByTagName("img")
    thumbs = document.getElementById("thumb-wrapper")
    totalImageCount = photos.length

    # SET THE PLAYBACK NEXT PREV UI
    # you use the name property to determine which direction the slide clicks are going
    # you have a switch set against that direction
    next = document.getElementById("next")
    next.innerHTML = "next &#10095;"
    next.name = "NEXT"
    prev = document.getElementById("previous")
    prev.innerHTML = "&#10094; prev"
    prev.name = "PREV"
    playback = document.getElementById("toggle")

    # FADE DOWN THE SLIDESHOW WRAPPER (50% for now)
    setOpacity(slideshow, 50)

    # SETTINGS FOR EACH SLIDE: z-index, opacity, offset position, visibility (for IE8)
    # after you do the initial settings, turn up the first slide
    for slide in slides
      slide.style.zIndex = ((slides.length-1)-_i)
      # FADE DOWN EACH SLIDE (20% for now)
      setOpacity(slide, 20)
      slide.style.visibility = 'hidden';

    # SHOW and FADE UP the first slide, after you've hidden them all
    setOpacity(slides[0], 100)
    slides[0].style.visibility = 'visible'

    # CHECK THE LOAD STATUS
    console.log "totalImageCount is #{totalImageCount}"
    console.log "loadedSlideCount is #{loadedSlideCount}"

    if totalImageCount is loadedSlideCount
      console.log "+ ================== +"
      console.log "+ IMAGES WERE CACHED +"
      console.log "+ ================== +"

      # Fade up or show the first slide code goes here
      fadeInTimeout = setTimeout(->
        fadeInContainer obj, opacity, 20)

    # otherwise check for the total images loaded to match the total image count
    else
      console.log "load a slide image"
      i = 0
      while i < totalImageCount
        photos[i].onLoad = onImageLoad(i)
        # console.log slides[i].offsetWidth
        i += 1

    return true
    # end initSlides

  pauseSlideshow: ->
    # console.log "+++ currently slideshowPaused is #{slideshowPaused} +++"
    unless slideshowPaused
      console.log "slideshow paused"
      clearTimeout slideshowTimeout
      slideshowPaused = true
      playback.innerHTML = "Slideshow is paused, &#9787; Play it."
    else
      console.log "slideshow playing"
      runSlideshow()
      slideshowPaused = false
      playback.innerHTML = "Slideshow is playing, &#9785; Pause it."

  nextSlide: ->
    console.log "+++ next slide button clicked +++"

    # if you want to keep the slideshow playing after clicking to advance clearTimeout for calling it
    # because you call runSlideshow again with a new timeout in the complete on fadeOutSlideAdvance
    clearTimeout slideshowTimeout

    # make sure the next slide is visible before the current one fades out
    setVisibilityForAdvance(next)

    # clear any current image fade out timeouts, needed if you're quickly advancing
    # I don't think you need to worry about completing the fade b/c we set opacity and visibilty.
    clearTimeout fadeOutTimeout

    # set the opacity on the slide about to be revealed during the current image fade out
    setOpacity(slides[(curImage + 1) % slides.length], 100)

    # fade out for advancing slide
    fadeOutSlideAdvance(slides[curImage % slides.length], 100, next)

    # current image iteration
    curImage++

    # current image reset if needed
    curImage = 0 if curImage % slides.length is 0

  prevSlide: ->
    console.log "+++ prev slide button clicked +++"
    console.log "curImage is #{curImage}"

    # if you want to keep the slideshow playing after clicking to advance clearTimeout for calling it
    # because you call runSlideshow again with a new timeout in the complete on fadeOutSlideAdvance
    clearTimeout slideshowTimeout

    # clear any current image fade out timeouts, needed if you're quickly advancing
    # I don't think you need to worry about completing the fade b/c we set opacity and visibilty.
    clearTimeout fadeOutTimeout

    # if you're at the start (0) set the curImg to the slide total,
    # so it can loop backwards (can't go -1 on curImage, so (curImage - 1) % slides.length gives -1 )
    curImage = slides.length if curImage % slides.length is 0

    # make sure the prev slide is visible before the current one fades out
    setVisibilityForAdvance(prev)

    # set the opacity on the slide about to be revealed during the current image fade out
    setOpacity(slides[(curImage - 1) % slides.length], 100)

    # fade out for advancing slide
    fadeOutSlideAdvance(slides[curImage % slides.length], 100, prev)

    # current image iteration
    curImage--
