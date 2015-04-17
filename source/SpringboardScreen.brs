function ShowSpringboardScreen(episodes, selectedEpisode, leftBread, rightBread)
	episode = episodes[selectedEpisode]
	
	screen = CreateObject("roSpringboardScreen")
	screen.SetMessagePort(CreateObject("roMessagePort"))
	screen.SetPosterStyle("rounded-rect-16x9-generic")
	screen.SetBreadcrumbText(leftBread, rightBread)
	screen.SetStaticRatingEnabled(false)
	UpdateSpringboardScreen(screen, episode)
	print episode
	while true
		msg = wait(0, screen.GetMessagePort())
		
		if msg <> invalid
			if msg.isScreenClosed()
				exit while
			else if msg.isButtonPressed()
				if msg.GetIndex() = 1 ' PLAY
				  episode.playStart = 0
					PlayVideo(episode)
					UpdateSpringboardScreen(screen, episode)
				else if msg.GetIndex() = 2 ' RESUME
				  episode.playStart = episode.bookmarkPosition
					PlayVideo(episode)
					UpdateSpringboardScreen(screen, episode)
				else if msg.GetIndex() = 3 ' PLAY ALL
					canvas = CreateObject("roImageCanvas")
					canvas.SetLayer(0, { Color: "#101010" })
					canvas.Show()
					shouldContinue = true
					while selectedEpisode < episodes.Count() and shouldContinue
  					episode = episodes[selectedEpisode]
  				  episode.playStart = 0
						shouldContinue = PlayVideo(episode)
						selectedEpisode = selectedEpisode + 1
					end while
					selectedEpisode = selectedEpisode - 1
					episode = episodes[selectedEpisode]
					UpdateSpringboardScreen(screen, episode)
					canvas.Close()
				else if msg.GetIndex() = 99 ' BACK
				  exit while
				end if
			else if msg.isRemoteKeyPressed()
				if msg.getIndex() = 4 ' LEFT
				  foundValidItem = false
				  while not foundValidItem
            if selectedEpisode = 0
              selectedEpisode = episodes.Count() - 1
            else
              selectedEpisode = selectedEpisode - 1
            end if
  					episode = episodes[selectedEpisode]
            
            if not episode.title = "Search"
              foundValidItem = true
            end if
          end while
					UpdateSpringboardScreen(screen, episode)
				else if msg.getIndex() = 5 ' RIGHT
				  foundValidItem = false
				  while not foundValidItem
            if selectedEpisode = episodes.Count() - 1
              selectedEpisode = 0
            else
              selectedEpisode = selectedEpisode + 1
            end if
            episode = episodes[selectedEpisode]
            
            if not episode.title = "Search"
              foundValidItem = true
            end if
          end while
					UpdateSpringboardScreen(screen, episode)
				end if
			end if
		end if
	end while
	
	return selectedEpisode
end function 

sub UpdateSpringboardScreen(screen, episode)
	'PrintAA(episode)
	Sleep(500) ' to keep the screen from becoming unresponsive
	
	screen.ClearButtons()
	screen.SetContent(episode)

	if episode.bookmarkPosition > 0
		screen.AddButton(2, "Resume")
  	screen.AddButton(1, "Play from beginning")
	else
  	screen.AddButton(1, "Play")
	end if
	screen.AddButton(3, "Play all")

	screen.Show()
end sub
