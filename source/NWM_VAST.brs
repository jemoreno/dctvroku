'
'  NWM_Vast.brs
'  chagedorn@roku.com
'
'  Compatible with VAST 2.0.1 (http://www.iab.net/vast)
'  
'  This module supports the <impression> and <tracking>
'  tags for defining tracking events.
'
'  TRACKING EVENTS RELY ON AN ACCURATE <duration> TAG FOR TIMING.
'  If a creative has an incorrect <duration> tag, the tracking
'  events for that creative will not fire at the correct times.
'

function NWM_VAST()
  this = {
    GetPrerollFromURL:  NWM_VAST_GetPrerollFromURL
  }
  
  return this
end function

function NWM_VAST_GetPrerollFromURL(url)
  print "NWM_VAST::GetPrerollFromURL"
  
  result = {
    streamFormat:   "mp4"
    streams:        []
    trackingEvents: []
  }
  colonRX = CreateObject("roRegEx", ":", "")
  timestampRX = CreateObject("roRegEx", "\[timestamp\]", "i")
  util = NWM_Utilities()
  dt = CreateObject("roDateTime")
  timestamp = dt.AsSeconds().ToStr()
  
  util = NWM_Utilities()
  raw = util.GetStringFromURL(url)
  xml = CreateObject("roXMLElement")
  if xml.Parse(raw)
    ' follow any VAST redirects
    while xml <> invalid and xml.ad.wrapper.Count() > 0 and ValidStr(xml.ad.wrapper.vastAdTagURI.GetText()) <> ""
      ' collect any impressions in this VAST before we process the redirect
      if xml.ad.wrapper.impression.Count() > 0
        for each url in xml.ad.wrapper.impression
          result.trackingEvents.Push({
            time: 0
            url:  ValidStr(url.GetText())
          })
        next
        for each url in xml.wrapper.wrapper.impression.url
          result.trackingEvents.Push({
            time: 0
            url:  ValidStr(url.GetText())
          })
        next
      end if
  
      ' collect any tracking events in this VAST before we process the redirect
      for each trackingEvent in xml.ad.wrapper.creatives.creative.linear.trackingEvents.tracking
        if ValidStr(trackingEvent.GetText()) <> ""
          result.trackingEvents.Push({
            timing: UCase(ValidStr(trackingEvent@event))
            time:   0
            url:    ValidStr(trackingEvent.GetText())
          })
        end if
        for each url in trackingEvent.url
          result.trackingEvents.Push({
            timing: UCase(ValidStr(trackingEvent@event))
            time:   0
            url:    ValidStr(url.GetText())
          })
        next
      next
  
      ' follow the redirect
      url = timestampRX.Replace(ValidStr(xml.ad.wrapper.vastAdTagURI.GetText()), timestamp)
      print url
      raw = util.GetStringFromURL(url)
      xml.Parse(raw)
    end while
    
    if xml.ad.inLine.video.Count() > 0
      creative = xml.ad.inLine.video[0]
      
      for each mediaFile in creative.mediaFiles.mediaFile
        ' step through the various media files for the creative
        if UCase(ValidStr(mediaFile@type)) = "VIDEO/MP4"
          newStream = {
            url:      ValidStr(mediaFile.url.GetText()).Trim()
          }
          if StrToI(ValidStr(mediaFile@bitrate)) > 0
            newStream.bitrate = StrToI(ValidStr(mediaFile@bitrate))
          end if
          
          result.streams.Push(newStream)
        end if
      next
  
      if result.streams.Count() > 0
        ' we found playable content
        durationBits = colonRX.Split(ValidStr(creative.duration.GetText()))
        length = 0
        secondsPerUnit = 1
        i = durationBits.Count() - 1
        while i >= 0
          length = length + (StrToI(durationBits[i]) * secondsPerUnit)
          secondsPerUnit = secondsPerUnit * 60
          i = i - 1
        end while
        if length > 0
          result.length = length
        else
          result.length = 1
        end if
        
        if xml.ad.inline.impression.Count() > 0
          for each url in xml.ad.inline.impression
            result.trackingEvents.Push({
              time: 0
              url:  ValidStr(url.GetText())
            })
          next
          for each url in xml.ad.inline.impression.url
            result.trackingEvents.Push({
              time: 0
              url:  ValidStr(url.GetText())
            })
          next
        end if
        
        for each trackingEvent in xml.ad.inline.trackingEvents.tracking
          time = invalid
          if UCase(ValidStr(trackingEvent@event)) = "FIRSTQUARTILE"
            time = Int(result.length * 0.25)
          else if UCase(ValidStr(trackingEvent@event)) = "MIDPOINT"
            time = Int(result.length * 0.5)
          else if UCase(ValidStr(trackingEvent@event)) = "THIRDQUARTILE"
            time = Int(result.length * 0.75)
          else if UCase(ValidStr(trackingEvent@event)) = "COMPLETE"
            ' fire two seconds before the end just in case the duration tag isn't exactly accurate
            time = result.length - 2
          else if UCase(ValidStr(trackingEvent@event)) = "START"
            time = 0
          end if
          
          if time <> invalid
            if ValidStr(trackingEvent.GetText()) <> ""
              result.trackingEvents.Push({
                time: time
                url:  ValidStr(trackingEvent.GetText())
              })
            end if
            for each url in trackingEvent.url
              result.trackingEvents.Push({
                time: time
                url:  ValidStr(url.GetText())
              })
            next
          end if
        next
      end if
    else 
      for each creative in xml.ad.inLine.creatives.creative
        if creative.linear.mediaFiles.Count() > 0
          creative = creative.linear
          
          for each mediaFile in creative.mediaFiles.mediaFile
            ' step through the various media files for the creative
            if UCase(ValidStr(mediaFile@type)) = "VIDEO/MP4"
              newStream = {
                url:      ValidStr(mediaFile.GetText()).Trim()
              }
              if StrToI(ValidStr(mediaFile@bitrate)) > 0
                newStream.bitrate = StrToI(ValidStr(mediaFile@bitrate))
              end if
              
              result.streams.Push(newStream)
            end if
          next
      
          if result.streams.Count() > 0
            ' we found playable content
            
            durationBits = colonRX.Split(ValidStr(creative.duration.GetText()))
            length = 0
            secondsPerUnit = 1
            i = durationBits.Count() - 1
            while i >= 0
              length = length + (StrToI(durationBits[i]) * secondsPerUnit)
              secondsPerUnit = secondsPerUnit * 60
              i = i - 1
            end while
            if length > 0
              result.length = length
            else
              result.length = 1
            end if
            
            if xml.ad.inline.impression.Count() > 0
              for each url in xml.ad.inline.impression
                result.trackingEvents.Push({
                  time: 0
                  url:  ValidStr(url.GetText())
                })
              next
              for each url in xml.ad.inline.impression.url
                result.trackingEvents.Push({
                  time: 0
                  url:  ValidStr(url.GetText())
                })
              next
            end if
            
            for each trackingEvent in creative.trackingEvents.tracking
              time = invalid
              if UCase(ValidStr(trackingEvent@event)) = "FIRSTQUARTILE"
                time = Int(result.length * 0.25)
              else if UCase(ValidStr(trackingEvent@event)) = "MIDPOINT"
                time = Int(result.length * 0.5)
              else if UCase(ValidStr(trackingEvent@event)) = "THIRDQUARTILE"
                time = Int(result.length * 0.75)
              else if UCase(ValidStr(trackingEvent@event)) = "COMPLETE"
                ' fire two seconds before the end just in case the duration tag isn't exactly accurate
                time = result.length - 2
              else if UCase(ValidStr(trackingEvent@event)) = "START"
                time = 0
              end if
              
              if time <> invalid
                result.trackingEvents.Push({
                  time: time
                  url:  ValidStr(trackingEvent.GetText())
                })
                for each url in trackingEvent.url
                  result.trackingEvents.Push({
                    time: time
                    url:  ValidStr(url.GetText())
                  })
                next
              end if
            next
          end if
        end if
      next
    end if
    
    i = 0
    while i < result.trackingEvents.Count()
      ' go back and calculate the times for any events we stumbled across before we knew the length of the video
      trackingEvent = result.trackingEvents[i]
      
      if trackingEvent.timing <> invalid
        time = invalid
        if trackingEvent.timing = "FIRSTQUARTILE"
          time = Int(result.length * 0.25)
        else if trackingEvent.timing = "MIDPOINT"
          time = Int(result.length * 0.5)
        else if trackingEvent.timing = "THIRDQUARTILE"
          time = Int(result.length * 0.75)
        else if trackingEvent.timing = "COMPLETE"
          ' fire two seconds before the end just in case the duration tag isn't exactly accurate
          time = result.length - 2
        else if trackingEvent.timing = "START"
          time = 0
        end if
        
        if time <> invalid
          trackingEvent.time = time
          i = i + 1
        else
          ' purge any events we dont care about (mute, fullscreen, etc)
          result.trackingEvents.Delete(i)
        end if
      else
        i = i + 1
      end if
    end while
  end if
  
  'PrintAA(result)
  return result
end function

' I have only come here seeking knowledge
' Things they would not teach me of in college
