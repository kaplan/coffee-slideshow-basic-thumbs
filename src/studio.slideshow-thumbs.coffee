###
Slideshow Application with Thumbs
Description: Basic slideshow with thumbnail images fading with controls sans library (why? idk). Just learning so this is me winging it.

Neat stuff: There is also a Rake file you can run in the Terminal to start the watch on the scss and coffeescript. I'm not sure what the last parts are, I should find out more. The Rake comes from a great post, by Nick Quaranto: http://quaran.to/blog/2013/01/09/use-jekyll-scss-coffeescript-without-plugins/

Dependencies: Modernizr, for js detection

Version:      1.0
Created:      2013-06-05
Last Mod:     2013-06-06

Notes: This version of the slideshow is built on the original non-thumb one ( https://github.com/kaplan/coffee-slideshow-basic ). Somewhat fewer comments as a guide for myself in this version, thought being I can always go back to the original-original for reference, which I seem to do with lots of stuff. Just like the original I'm trying to do as much plain JavaScript through learning CoffeeScript as I can, later libraries.

The thumbs have a custom attribute, data-, that is pretty neat for semantic markup that you can use in your JavaScript. The ones used here are very simple, just an id for the thumb/slide that will help in setting the current image. If you look at the very bottom I have a little explaination copied from the HTML5Doctor page: http://html5doctor.com/html5-custom-data-attributes/ where I learned about these.

Working on make the JavaScript unobtrusive: I started to pull out the eventhandlers from the markup, removed the onclick="STUDIO.slideshow.pauseSlideshow()" from the toggle, next and prev. Those are now in here, where they should be for the separation between structure and behavior.

Next: I'd like to add some better or more clear documentation for the methods and properties and begin really eleminating and comments or console.logs. At this point it's very handy for me to watch the Browser's console log to see what the application is doing. In the end the comments don't compile into the JavaScript from CoffeeScript and I think that's one of my favorite things about CS. My JavaScript files were a mess with commented out logs and notes that I would leave out of fear of forgetting what I was doing, but it made for a very littered looking code, not at all crafsman like. Maybe it's the quality of my comments and the fact I try different snippets within before I settle on an approach.

Found this on Docco, which I need to start using:
http://jashkenas.github.io/docco/
http://lostechies.com/derickbailey/2011/12/14/annotated-source-code-as-documentation-with-docco/
###


# Using addLoadEvent instead of jQuery ready, but not sure if this is the best approach.
addLoadEvent = (func) ->
  oldonload = window.onload
  if typeof window.onload isnt 'function'
    window.onload = func
  else
    window.onload = ->
      oldonload()
      func()


# Namespace the application using this with an empty object if is not null
@STUDIO = @STUDIO ? {}

@STUDIO.slideshow = do ->

  # private

  slideshow = slides = photos = thumbset = thumbs = toggle = next = prev = "unknown"
  curImage = slideCount = totalImageCount = loadedSlideCount = 0
  fadeInContainerTimeout = slideshowTimeout = fadeOutTimeout = null
  slideshowPaused = false

  # FOR IMAGE LOADED COUNTING
  onImageLoad = (slideOrder) ->
    # after each imaage is loaded make sure it's display is not 'none'
    # bc in the CSS these all start display none, which hides them before they completely load in IE
    slides[slideOrder].style.display = "block";

    loadedSlideCount++
    # console.log "loading an image #{slideOrder}"
    # console.log "loadedSlideCount is #{loadedSlideCount}"

    if totalImageCount is loadedSlideCount
      console.log "+ ================== +"
      console.log "+ ALL IMAGES LOADED! +"
      console.log "+ ================== +"

      #  After all the images are loaded fade up the container with: fadeInContainer()
      #  Then when the container fade up is done, start the slideshow running.
      #  Increase compatibility with unnamed functions

      fadeInContainerTimeout = setTimeout(->
        # console.log "!! ALL IMAGES LOADED: FADE IN THE SLIDESHOW CONTAINER !!"
        # the 0 is what we're fading up from, 500 is a delay of .5 seconds
        fadeInContainer slideshow, 0, 500)

      fadeInThumbs = setTimeout(->
        fadeInObject thumbset, 0, 500)


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
      # console.log '*** done with fadeInObject ***'


  # FOR INITAL WRAPPER FADE UP INTERVAL
  fadeInContainer = (obj, opacity) ->
    if opacity <= 100
      # console.log "fade in slide #{opacity}"
      setOpacity(obj, opacity)
      opacity += 2
      fadeInTimeout = setTimeout(->
        fadeInContainer obj, opacity, 200)
    else
      # console.log "+++ fadeInContainer complete +++"
      # clear the timeout that did this fading
      clearTimeout(fadeInTimeout);

      # clear the timeout that called this method
      clearTimeout fadeInContainerTimeout

      # anonymous setTimeout with multiple methods or property settings,
      # you need the new line that has comma with delay amount or an error is thrown
      slideshowTimeout = setTimeout(->
        console.log  "*** slideshow playing, first time start ***"
        runSlideshow()
        toggle.innerHTML = "Slideshow is playing, &#9785; Pause it."
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

  fadeOutSlideAdvance = (obj, opacity) ->
    if opacity >= 0
      # console.log "fade out slide #{opacity}"
      setOpacity(obj, opacity)
      opacity -= 10
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
        # console.log (curImage - 1) % slides.length
        slides[(curImage - 1) % slides.length].style.visibility = 'visible'
      else
        break


  showSlideOnThumbClick = (thumbId) ->
    console.log "+++ thumb #{thumbId} clicked +++"
    console.log "curImage is #{curImage}"

    # make sure the slide you are about to reveal is visible
    slides[thumbId].style.visibility = 'visible'

    # make sure the slide you are about to reveal is opaque
    setOpacity(slides[thumbId], 100)

    # now you can fade out the current image
    fadeOutSlideAdvance(slides[curImage % slides.length], 100)

    # assign the curImage to the slide you just clicked, but first convert it to a number
    # tip: you can also convert by taking a string and multiplying by 1 as in "2" * 1
    curImage = parseInt(thumbId, 10)

    # if you want to keep the slideshow playing after clicking to advance clearTimeout for calling it
    # because you call runSlideshow again with a new timeout in the complete on fadeOutSlideAdvance
    # clearTimeout slideshowTimeout


  reorderLayerStack = ->
    # console.log "+++ shuffle z-index +++"
    # console.log "+++ shuffle z-index: #{slides.length} +++"

    shuffle = ->
      slides[_i].style.zIndex = (((slides.length) - _i) + curImage) % slides.length
    shuffle slide for slide in slides
    return true

  # public
  # ------

  initSlides: (slideWrapper) ->
    console.log "+++ initSlides called +++"
    curImage = 0
    loadedSlideCount = 0
    slideshow = document.getElementById(slideWrapper)
    slides = slideshow.getElementsByTagName("div")
    photos = slideshow.getElementsByTagName("img")
    thumbset = document.getElementById("thumb-wrapper")
    thumbs = thumbset.getElementsByTagName("img")
    totalImageCount = photos.length

    # SET THE PLAYBACK NEXT PREV UI
    # you use the name property to determine which direction the slide clicks are going
    # you have a switch set against that direction
    next = document.getElementById("next")
    next.innerHTML = "next &#10095;"
    next.name = "NEXT"
    next.onclick = ->
      STUDIO.slideshow.nextSlide()
    prev = document.getElementById("previous")
    prev.innerHTML = "&#10094; prev"
    prev.name = "PREV"
    prev.onclick = ->
      STUDIO.slideshow.prevSlide()
    toggle = document.getElementById("toggle")
    toggle.onclick = ->
      STUDIO.slideshow.pauseSlideshow()

    # FADE DOWN THE SLIDESHOW WRAPPER (50% for now)
    setOpacity(slideshow, 50)

    # SETTINGS FOR EACH SLIDE: z-index, opacity, offset position, visibility (for IE8)
    # after you do the initial settings, turn up the first slide
    for slide in slides
      slide.style.zIndex = ((slides.length-1)-_i)
      # FADE DOWN EACH SLIDE (20% for now)
      setOpacity(slide, 20)
      slide.style.visibility = 'hidden';

      # Setting the thumbnail data for changing the main slide later
      # console.log "img src is  #{thumbs[_i].getAttribute('src')}"
      # console.log "---> #{thumbs[_i]}"
      # console.log thumbs[_i].parentNode
      link = thumbs[_i].parentNode
      # console.log "link is:  #{link}"

      # looking at several ways to store that id, but
      # won't work for clicks, b/c it's always going to be the last item
      # better to get it during the actual onclick
      # thumbId = thumbs[_i].parentNode.dataset.slideshowId
      # thumbId = link.dataset.slideshowId
      # link.id = thumbId
      # console.log thumbId
      # link.id = link.dataset.slideshowId
      # console.log link.id

      # attach a handler to the link elememt
      link.onclick = ->
      # thumbs[_i].parentNode.onclick = ->
        # console.log "#{this}"
        # console.log this.dataset.slideshowId
        this.slideId = parseInt(this.dataset.slideshowId, 10)
        console.log this.slideId

        showSlideOnThumbClick(this.slideId) unless curImage is this.slideId
        return false # prevent default behavior of clicking link


    # SHOW and FADE UP the first slide, after you've hidden them all
    setOpacity(slides[0], 100)
    slides[0].style.visibility = 'visible'

    # CHECK THE LOAD STATUS
    # console.log "totalImageCount is #{totalImageCount}"
    # console.log "loadedSlideCount is #{loadedSlideCount}"

    if totalImageCount is loadedSlideCount
      console.log "+ ================== +"
      console.log "+ IMAGES WERE CACHED +"
      console.log "+ ================== +"

      # Fade up or show the first slide code goes here
      fadeInTimeout = setTimeout(->
        fadeInContainer obj, opacity, 20)

    # otherwise check for the total images loaded to match the total image count
    else
      # console.log "load slide images"
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
      toggle.innerHTML = "Slideshow is paused, &#9787; Play it."
    else
      console.log "slideshow playing"
      runSlideshow()
      slideshowPaused = false
      toggle.innerHTML = "Slideshow is playing, &#9785; Pause it."


  # It would be sweet if you could DRY up the next and prev methods... they are very similar.

  nextSlide: ->
    console.log "+++ next slide button clicked +++"
    console.log "curImage is #{curImage}"

    # if you want to keep the slideshow playing after clicking to advance. little hazy on this still, yes.
    # oh... i think this might clear any slideshowTimeouts about to run and don't worry b/c you call it...
    # because you call runSlideshow again with a new slideshowTimeout in the complete on fadeOutSlideAdvance
    clearTimeout slideshowTimeout

    # make sure the next slide is visible before the current one fades out
    setVisibilityForAdvance(next)

    # clear any current image fade out timeouts, needed if you're quickly advancing
    # I don't think you need to worry about completing the fade b/c we set opacity and visibilty.
    clearTimeout fadeOutTimeout

    # set the opacity on the slide about to be revealed during the current image fade out
    setOpacity(slides[(curImage + 1) % slides.length], 100)

    # fade out for advancing slide
    fadeOutSlideAdvance(slides[curImage % slides.length], 100)

    # current image iteration
    curImage++

    # current image reset if needed
    curImage = 0 if curImage % slides.length is 0

  prevSlide: ->
    console.log "+++ prev slide button clicked +++"
    console.log "curImage is #{curImage}"

    # if you want to keep the slideshow playing after clicking to advance. little hazy on this still, yes.
    # oh... i think this might clear any slideshowTimeouts about to run and don't worry b/c you call it...
    # because you call runSlideshow again with a new slideshowTimeout in the complete on fadeOutSlideAdvance
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
    fadeOutSlideAdvance(slides[curImage % slides.length], 100)

    # current image iteration
    curImage--

  # DEBUGGING in browser console...
  # methods you can call in the browser's console
  getCurImage: ->
    return curImage

  # CUSTOM attributes in your markup yay html5!
  # http://html5doctor.com/html5-custom-data-attributes/
  # Below are 2 examples from the doctor page, one is more 'modern'
  # DATASET element attributes that can be totally customized in markup that you can to pass into JS
  # This was studied for using an "id" within the thumb markup instead of a class or id attribute

  # MODERN BROWSERS can use dataset, check caniuse.com
  # <div id='sunflower' data-leaves='47' data-plant-height='2.4m'></div>
  # // 'Getting' data-attributes using dataset
  # var plant = document.getElementById('sunflower');
  # var leaves = plant.dataset.leaves; // leaves = 47;
  # // 'Setting' data-attributes using dataset
  # var tallness = plant.dataset.plantHeight; // 'plant-height' -> 'plantHeight'
  # plant.dataset.plantHeight = '3.6m';  // Cracking fertiliser


  # the older way is to use getAttribute and setAttribute,
  # but caniuse says 65% support at the time of this development
  # <div id='strawberry-plant' data-fruit='12'></div>
  # // 'Getting' data-attributes using getAttribute
  # var plant = document.getElementById('strawberry-plant');
  # var fruitCount = plant.getAttribute('data-fruit'); // fruitCount = '12'
  # // 'Setting' data-attributes using setAttribute
  # plant.setAttribute('data-fruit','7'); // Pesky birds
  # </script>

  # <a href="images/beercan-image-a.jpg" data-slideshow-id="0">
  getSlideId: (id) ->
    # 'Getting' data-attributes using dataset
    thumbId = thumbs[id].parentNode.dataset.slideshowId
    return thumbId

