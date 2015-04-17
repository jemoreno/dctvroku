function PlayVideo(episode)
  result = false
  
	canvas = CreateObject("roImageCanvas")
	canvas.SetMessagePort(CreateObject("roMessagePort"))
	canvas.SetLayer(1, {color: "#ebebeb"})
	canvas.Show()
	
	' get a preroll ad for this video
	'vast = NWM_VAST()
	'episode.preroll = vast.GetPrerollFromURL("http://api.example.com/vast/xml")

  ' play the pre-roll
  adCompleted = true
  if episode.preroll <> invalid and episode.preroll.streams.Count() > 0
    adCompleted = ShowPreRoll(canvas, episode.preroll)
  end if

  'Sleep(1000)
  if adCompleted
    ' if the ad completed without the user pressing UP, play the content
    result = ShowVideoScreen(episode)
  end if
	
	canvas.Close()
	return result
end function

function ShowVideoScreen(episode)
  result = true
	util = NWM_Utilities()
  bookmarkTimer = CreateObject("roTimespan")
	screen = CreateObject("roVideoScreen")
	screen.SetMessagePort(CreateObject("roMessagePort"))
	screen.SetPositionNotificationPeriod(1)
	
	screen.SetContent(episode)
	screen.Show()
	print "~~~CONTENT"
	PrintAA(episode)
	
	hasBeentracked = false
	while true
		msg = wait(0, screen.GetMessagePort())
		
		if type(msg) = "roVideoScreenEvent"
			if msg.isScreenClosed()
			  print "isScreenClosed"
				exit while
			else if msg.isRequestFailed()
			  print "isRequestFailed"
			  print msg.GetMessage()
			  PrintAA(msg.GetInfo())
			  exit while
			else if msg.isPartialResult()
			  print "isPartialResult"
			  result = false
			  exit while
			else if msg.isStreamStarted()
			  print "isStreamStarted"
			  PrintAA(msg.GetInfo())
    	  bookmarkTimer.Mark()

        if not hasBeentracked
          hasBeentracked = true
        end if
			else if msg.isPlaybackPosition()
			  if bookmarkTimer.TotalSeconds() > 14
          episode.bookmarkPosition = msg.GetIndex()
          m.content.bookmarks.UpdateBookmarkForVideo(episode)

			    bookmarkTimer.Mark()
			  end if
			end if
		end if
	end while

	screen.Close()
	return result
end function

function ShowPreRoll(canvas, ad)
	result = true
	util = NWM_Utilities()
	
	print "~~~AD"
	PrintAA(ad)

	player = CreateObject("roVideoPlayer")
	' be sure to use the same message port for both the canvas and the player
	player.SetMessagePort(canvas.GetMessagePort())
  player.SetDestinationRect(canvas.GetCanvasRect())
  player.SetPositionNotificationPeriod(1)
  
  ' set up some messaging to display while the pre-roll buffers
  canvas.SetLayer(2, [{
    color: "#ebebeb" 
  },{ 
		url: "pkg:/images/homescreen_focus_HD.png"
		targetRect: {
			x:	Int(canvas.GetCanvasRect().w / 2) - 168
			y:	Int(canvas.GetCanvasRect().h / 2) - 105
			w:	336
			h:	210
		}
	},{ 
    text: "Your program will begin after this message"
    textAttrs:  { color: "#101010" }
    targetRect: { x: 0, y: canvas.GetCanvasRect().h - 150, w: canvas.GetCanvasRect().w, h: 20 }
  }])
  canvas.Show()
  
	player.AddContent(ad)
	player.Play()
	
	isStreamStarted = false
	hasBeentracked = false
	while true
		msg = wait(0, canvas.GetMessagePort())
		'print msg.GetMessage()
		
		if type(msg) = "roVideoPlayerEvent"
			if msg.isFullResult()
				exit while
			else if msg.isRequestFailed()
				exit while
			else if msg.isPlaybackPosition()
			  print msg.GetIndex().ToStr()
			  for each trackingEvent in ad.trackingEvents
			    if trackingEvent.time = msg.GetIndex()
			      FireTrackingEvent(trackingEvent)
			    end if
			  next
			else if msg.isPartialResult()
				result = false
				exit while
			else if msg.isStatusMessage()
				if msg.GetMessage() = "startup progress"
				  if isStreamStarted
				    canvas.SetLayer(2, { text: "Loading..." })
				    canvas.Show()
				    isStreamStarted = false
				  end if
				else if msg.GetMessage() = "start of play"
				  ' once the video starts, clear out the canvas so it doesn't cover the video
					canvas.ClearLayer(2)
					canvas.SetLayer(1, {color: "#00000000", CompositionMode: "Source"})
					canvas.Show()
					isStreamStarted = true
					
					if not hasBeentracked
					  hasBeentracked = true
					end if
				end if
			end if
		else if type(msg) = "roImageCanvasEvent"
      if msg.isRemoteKeyPressed()
        index = msg.GetIndex()
        if index = 2 or index = 0  '<UP> or BACK
        	result = false
        	exit while
        end if
      end if
		end if
	end while
	
	player.Stop()
	return result
end function

function FireTrackingEvent(trackingEvent)
  result = true
  timeout = 3000
  port = CreateObject("roMessagePort")
  xfer = CreateObject("roURLTransfer")
  xfer.SetPort(port)
  timer = CreateObject("roTimespan")

  xfer.SetURL(trackingEvent.url)
  print "~~~TRACKING: " + xfer.GetURL()
  ' have to do this synchronously so that we don't colide with 
  ' other tracking events firing at or near the same time
  if xfer.AsyncGetToString()
    timer.Mark()
    event = wait(timeout, port)
    
    if event = invalid
      ' we waited long enough, moving on
      print "Request timed out"
      xfer.AsyncCancel()
      result = false
    else
      print "Request took " + timer.TotalMilliseconds().ToStr()
    end if
  end if
  
  return result
end function
