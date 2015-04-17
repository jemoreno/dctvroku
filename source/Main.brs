sub Main()
	canvas = CreateObject("roImageCanvas")
	canvasRect = canvas.GetCanvasRect()
	canvas.SetLayer(0, { color: "#303030" })
	canvas.SetLayer(1, [{ 
		url: "http://media.dcccd.edu/roku/images/advert.png"
		targetRect: {
			x:	Int(canvas.GetCanvasRect().w / 2) - 450
			y:	Int(canvas.GetCanvasRect().h / 2) - 275
			w:	900
			h:	275
		}
	},{
	  text:       "For more information go to http://dcccd.edu"
	  textAttrs:  { color: "#606060", vAlign: "top" }
	  targetRect: { x: 0, y: canvasRect.h - 150, w: canvasRect.w, h: 30 }
	},
	{
	  text: "Loading..."
	  textAttrs: { color: "#606060", vAlign: "top" }
	  targetRect: { x: 0, y: canvasRect.h - 100, w: canvasRect.w, h: 30 }
	}])
	canvas.Show()


	app = CreateObject("roAppManager")
	theme = CreateObject("roAssociativeArray")

	theme.GridScreenBackgroundColor = "#303030"
	theme.BackgroundColor = "#303030"
	theme.PosterScreenLine1Text = "#f0f0f0"
	theme.PosterScreenLine2Text = "#a0a0a0"
	theme.EpisodeSynopsisText = "#a0a0a0"
	theme.BreadcrumbTextLeft = "#f0f0f0"
	theme.BreadcrumbDelimiter = "#a0a0a0"
	theme.BreadcrumbTextRight = "#a0a0a0"
	theme.SpringboardTitleText = "#f0f0f0"
	theme.SpringboardSynopsisColor = "#f0f0f0"
	theme.SpringboardActorColor = "#a0a0a0"
	theme.SpringboardDirectorColor = "#a0a0a0"
	theme.SpringboardRuntimeColor = "#a0a0a0"
	theme.SpringboardReleaseDateColor = "#a0a0a0"
	theme.SpringboardGenreColor = "#a0a0a0"
	theme.ButtonMenuHighlightText = "#f0f0f0"
	theme.ButtonMenuNormalText = "#a0a0a0"

	theme.OverhangSliceSD = "pkg:/images/overhang_slice_sd.png"
	theme.OverhangSliceHD = "pkg:/images/overhang_slice_hd.png"
	theme.GridScreenOverhangSliceHD = "pkg:/images/overhang_slice_hd.png"
	theme.GridScreenOverhangSliceSD = "pkg:/images/overhang_slice_sd.png"
  theme.OverhangLogoHD  = "pkg:/images/overhang_logo_hd.png"
  theme.OverhangLogoSD  = "pkg:/images/overhang_logo_sd.png"
	theme.OverhangOffsetSD_X = "50"
	theme.OverhangOffsetSD_Y = "10"
	theme.OverhangOffsetHD_X = "50"
	theme.OverhangOffsetHD_Y = "10"
	theme.GridScreenLogoHD = "pkg:/images/overhang_logo_hd.png"
	theme.GridScreenLogoSD = "pkg:/images/overhang_logo_sd.png"
	theme.GridScreenLogoOffsetSD_X = "50"
	theme.GridScreenLogoOffsetSD_Y = "10"
	theme.GridScreenLogoOffsetHD_X = "50"
	theme.GridScreenLogoOffsetHD_Y = "10"
	'theme.CounterTextLeft = "#79b8dd"
	'theme.GridScreenOverhangHeightSD = "45" ' to avoid collision with breadcrumbs

    ' to use your own focus ring artwork 
    theme.GridScreenFocusBorderSD        = "pkg:/images/GridCenter_Border_16x9_SD43.png"
    'theme.GridScreenBorderOffsetSD  = "(-26,-25)"
    theme.GridScreenFocusBorderHD        = "pkg:/images/GridCenter_Border_16x9_HD.png"
    'theme.GridScreenBorderOffsetHD  = "(-28,-20)"
	
	' to use your own description background artwork
    'theme.GridScreenDescriptionImageSD  = "pkg:/images/Grid_Description_Background_SD43.png"
    'theme.GridScreenDescriptionOffsetSD = "(125,170)"
    'theme.GridScreenDescriptionImageHD  = "pkg:/images/Grid_Description_Background_HD.png"
    'theme.GridScreenDescriptionOffsetHD = "(190,255)


	app.SetTheme(theme)
	For i=8000 To 1 Step -1 
    	'print i
	End For
	m.content = NWM_Content()
	
	facade = CreateObject("roPosterScreen")
	selection = ShowCategoryGridScreen({ focusedList: 1, focusedItem: 0 }, canvas, facade)
	while selection <> invalid
    	selection.focusedItem = ShowSpringboardScreen(selection.items, selection.focusedItem, "", "")
 		
		selection = ShowCategoryGridScreen(selection)
	end while

	facade.Close()
end sub
