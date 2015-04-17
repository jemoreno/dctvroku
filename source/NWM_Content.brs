function NWM_Content()
  this = {
    opmlURL:            "http://media.dcccd.edu/roku/xml/home.xml"
    bookmarks:          NWM_Bookmarks()
    gridRows:           []
    
    GetGridRows:        NWM_CONTENT_GetGridRows
    GetItemsForGridRow: NWM_CONTENT_GetItemsForGridRow
    GetCategoryGridRows:        NWM_CONTENT_GetCategoryGridRows
    GetCategoryItemsForGridRow: NWM_CONTENT_GetCategoryItemsForGridRow
  }
  
  return this
end function

function NWM_CONTENT_GetGridRows()
  if m.gridRows.Count() = 0
    util = NWM_Utilities()
  
    raw = util.GetStringFromURL(m.opmlURL)
    xml = CreateObject("roXMLElement")
    if xml.Parse(raw)
      for each category in xml.body.category
        newRow = {
          title:        ValidStr(category@title)
          description:  ValidStr(category@description)
          feed:         ValidStr(category@url)
          items:        []
        }
        
        m.gridRows.Push(newRow)
      next
    else
      print "~~~PARSE FAILED: " + m.opmlURL
    end if
  end if
  
  return m.gridRows
end function

function NWM_CONTENT_GetItemsForGridRow(row)
  result = []
  
  mrss = NWM_MRSS(row.feed)
  result = mrss.GetEpisodes(row.title)
  
  return result
end function

function NWM_CONTENT_GetCategoryGridRows()
  if m.gridRows.Count() = 0
    util = NWM_Utilities()
  
    raw = util.GetStringFromURL(m.opmlURL)
    xml = CreateObject("roXMLElement")
    if xml.Parse(raw)
      for each category in xml.body.category
        newRow = {
          title:        ValidStr(category@title)
          description:  ValidStr(category@description)
          feed:         ValidStr(category@url)
          duration:		ValidStr(category@runtime)
          items:        []
        }
        
        m.gridRows.Push(newRow)
      next
    else
      print "~~~PARSE FAILED: " + m.opmlURL
    end if
  end if
  
  return m.gridRows
end function

function NWM_CONTENT_GetCategoryItemsForGridRow(row)
  result = []
  
  mrss = NWM_MRSS(row.feed)
  result = mrss.GetEpisodes(row.title)
  
  return result
end function