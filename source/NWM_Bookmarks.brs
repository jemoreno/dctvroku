'
' NWM_Bookmarks.brs
' chris@thenowhereman.com
'
' A BrightScript class for local storage of video bookmarks
' Useful for implementing "resume" functionality when the
' associated API does not support bookmarks
'
' REQUIREMENTS
' Each video you use with this class must have a guid attribute
' on its content-meta-data whose value is a string that uniquely
' identifies the video.
'

function NWM_Bookmarks()
  this = {
    LoadBookmarks:          NWM_BOOKMARKS_LoadBookmarks
    CompareBookmarks:       NWM_BOOKMARKS_CompareBookmarks
    SaveBookmarks:          NWM_BOOKMARKS_SaveBookmarks
    UpdateBookmarkForVideo: NWM_BOOKMARKS_UpdateBookmarkForVideo
    GetBookmarkForVideo:    NWM_BOOKMARKS_GetBookmarkForVideo
  }
  
  return this
end function

sub NWM_BOOKMARKS_LoadBookmarks()
  print "NWM_BOOKMARKS_LoadBookmarks"
  m.bookmarks = []
  
  raw = ValidStr(RegRead("bookmarks", "nwm_bookmarks"))
  xml = CreateObject("roXMLElement")
  if xml.Parse(raw)
    for each bookmark in xml.bookmark
      m.bookmarks.Push({
        id:         ValidStr(bookmark@id)
        position:   StrToI(ValidStr(bookmark@position))
        lastUpdate: StrToI(ValidStr(bookmark@lastUpdate))
      })
    next
  end if
  
  QuickSort(m.bookmarks, NWM_BOOKMARKS_CompareBookmarks)
end sub

function NWM_BOOKMARKS_CompareBookmarks(item)
  'print "NWM_BOOKMARKS_CompareBookmarks"
  result = 0
  if item.lastUpdate <> invalid 
    result = item.lastUpdate * -1 ' negative will give us a reverse sort
  end if
  
  return result
end function

sub NWM_BOOKMARKS_SaveBookmarks()
  print "NWM_BOOKMARKS_SaveBookmarks"
  QuickSort(m.bookmarks, NWM_BOOKMARKS_CompareBookmarks)

  xml = CreateObject("roXMLElement")
  xml.SetName("bookmarks")
  for each bookmark in m.bookmarks
    if xml.bookmark.Count() < 10
      node = xml.AddElement("bookmark")
      node.AddAttribute("id", bookmark.id)
      node.AddAttribute("position", bookmark.position.ToStr())
      node.AddAttribute("lastUpdate", bookmark.lastupdate.ToStr())
    end if
  next
  
  'print xml.GenXML(true)
  RegWrite("bookmarks", xml.GenXML(false), "nwm_bookmarks")
end sub

sub NWM_BOOKMARKS_UpdateBookmarkForVideo(video)
  print "NWM_BOOKMARKS_UpdateBookmarkForVideo"

  if m.bookmarks = invalid
    m.LoadBookmarks()
  end if
  
  success = false
  for each bookmark in m.bookmarks
    if bookmark.id = video.guid
      bookmark.position = video.bookmarkPosition
      bookmark.lastUpdate = CreateObject("roDateTime").AsSeconds()
      success = true
    end if
  next
  
  if not success
    m.bookmarks.Push({
      id:         video.guid
      position:   video.bookmarkPosition
      lastUpdate: CreateObject("roDateTime").AsSeconds()
    })
  end if
  
  m.SaveBookmarks()
end sub

function NWM_BOOKMARKS_GetBookmarkForVideo(video)
  print "NWM_BOOKMARKS_GetBookmarkForVideo"
  result = 0
  
  if m.bookmarks = invalid
    m.LoadBookmarks()
  end if

  for each bookmark in m.bookmarks
    if bookmark.id = video.guid
      result = bookmark.position
      exit for
    end if
  next
  
  return result
end function

' I have only come here seeking knowledge
' Things they would not teach me of in college
