function ShowCategoryGridScreen(selection, backgroundCanvas = invalid, facade = invalid)
	result = invalid

  '	
  ' the content provider class MUST implment GetCategoryGridRows and GetCategoryItemsForGridRow
  '
  contentProvider = m.content

	screen = CreateObject("roGridScreen")
	screen.SetMessagePort(CreateObject("roMessagePort"))
	screen.SetGridStyle("flat-16x9")
	screen.SetTitle("DCTV")
	lists = contentProvider.GetCategoryGridRows()
	
	screen.SetupLists(lists.Count())
	
	listNames = []
	for i = 0 to lists.Count() - 1
		list = lists[i]
		
		listNames.Push(list.title)
		if list.items.Count() > 0
			screen.SetContentList(i, list.items)
		else if i > selection.focusedList - 2 and  i < selection.focusedList + 2
			list.items = contentProvider.GetCategoryItemsForGridRow(list)
			screen.SetContentList(i, list.items)
		end if
	next
	screen.SetListNames(listNames)
	screen.SetFocusedListItem(selection.focusedList, selection.focusedItem)
	
	if facade <> invalid
	  facade.Show()
	end if

	screen.Show()
	
	if backgroundCanvas <> invalid
	  backgroundCanvas.Close()
	end if
	
	backgroundIndex = 0
	while true
		msg = wait(0, screen.GetMessagePort())
		
		if msg = invalid
		  if backgroundIndex < lists.Count()
		    list = lists[backgroundIndex]
		    if list.items.Count() = 0
					list.items = contentProvider.GetCategoryItemsForGridRow(list)
		    end if
				screen.SetContentList(backgroundIndex, list.items)
		    
		    backgroundIndex = backgroundIndex + 1
		  end if
	  else if type(msg) = "roGridScreenEvent"
			if msg.isScreenClosed()
				exit while
			elseif msg.isListItemFocused()
				rowsToUpdate = [msg.GetIndex(), msg.GetIndex() - 1, msg.GetIndex() + 1]
				for each i in rowsToUpdate
          if i >= 0 and i < lists.Count()
            list = lists[i]
            if list.items.Count() = 0
              list.items = contentProvider.GetCategoryItemsForGridRow(list)
            end if
            
            screen.SetContentList(i, list.items)
          end if
        next
			else if msg.isListItemSelected()
				result = lists[msg.GetIndex()]
				result.focusedList = msg.GetIndex()
				result.focusedItem = msg.GetData()
				exit while
			end if
		end if
	end while
	
	screen.Close()
	
	return result
end function
