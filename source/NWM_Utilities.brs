function NWM_Utilities()
	this = {
		GetStringFromURL:			NWM_UT_GetStringFromURL
		ResolveRedirect:      NWM_UT_ResolveRedirect
		GetStringFromURLPost:	NWM_UT_GetStringFromURLPost
		HTMLEntityDecode:			NWM_UT_HTMLEntityDecode
		HTMLStripTags:				NWM_UT_HTMLStripTags
		SimpleJSONParser:			NWM_UT_SimpleJSONParser
		GetIPAddress:         NWM_UTIL_GetIPAddress
		Chunk:                NWM_UTIL_Chunk
	}
	
	return this
end function

function NWM_UT_ResolveRedirect(url)
	result = url
	done = false
	
	prefix = result
	prefixRX = CreateObject("roRegEx", "(http://.*?)/", "")
	matches = prefixRX.Match(result)
	if matches.Count() > 1
	  prefix = matches[1]
	end if
	
	ut = CreateObject("roURLTransfer")
	ut.SetPort(CreateObject("roMessagePort"))
  ut.AddHeader("user-agent", "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543 Safari/419.3")
	while not done
		ut.SetURL(result)
	
		if ut.AsyncHead()
			while true
				msg = wait(10000, ut.GetPort())
				
				if msg <> invalid
					h = msg.GetResponseHeaders()
					PrintAA(h)
					if ValidStr(h.location) <> ""
						result = ValidStr(h.location)
						if not result.InStr(0, "http://") = 0
						  result = prefix + result
						end if
					else
						done = true
					end if
				else
					done = true
				end if
				exit while
			end while
		else 
			done = true
		end if
	end while
	
	return result
end function

function NWM_UT_GetStringFromURLPost(url, postData, userAgent = "")
	print "NWM_UT_GetStringFromURLPost"
	result = ""
	timeout = 10000
	
  ut = CreateObject("roURLTransfer")
  ut.SetPort(CreateObject("roMessagePort"))
  ut.AddHeader("content-type", "text/xml")
  if userAgent <> ""
	  ut.AddHeader("user-agent", userAgent)
	end if
  ut.SetURL(url)
	if ut.AsyncPostFromString(postData)
		event = wait(timeout, ut.GetPort())
		print type(event)
		if type(event) = "roUrlEvent"
				print ValidStr(event.GetResponseCode())
				printAA(event.GetResponseHeaders())
				print event.GetString()
				result = event.GetString()
				'exit while        
		elseif event = invalid
				ut.AsyncCancel()
				REM reset the connection on timeouts
				'ut = CreateURLTransferObject(url)
				'timeout = 2 * timeout
		else
				print "roUrlTransfer::AsyncGetToString(): unknown event"
		endif
	end if
	
	return result
end function

function NWM_UT_GetStringFromURL(url, timeout = 10000, userAgent = "")
	result = ""
	
  ut = CreateObject("roURLTransfer")
  ut.SetPort(CreateObject("roMessagePort"))
  if userAgent <> ""
	  ut.AddHeader("user-agent", userAgent)
	end if
  ut.SetURL(url)
  print "~~~FETCHING: " + ut.GetURL()
	if ut.AsyncGetToString()
		event = wait(timeout, ut.GetPort())
		if type(event) = "roUrlEvent"
				'print ValidStr(event.GetResponseCode())
				result = event.GetString()
				'exit while        
		elseif event = invalid
				ut.AsyncCancel()
				REM reset the connection on timeouts
				'ut = CreateURLTransferObject(url)
				'timeout = 2 * timeout
		else
				print "roUrlTransfer::AsyncGetToString(): unknown event"
		endif
	end if
	
	return result
end function

function NWM_UT_HTMLEntityDecode(inStr)
	result = inStr
	
	rx = CreateObject("roRegEx", "&#39;", "")
	result = rx.ReplaceAll(result, "'")

	rx = CreateObject("roRegEx", "&amp;", "")
	result = rx.ReplaceAll(result, "&")

	rx = CreateObject("roRegEx", "&(quot|rsquo|lsquo);", "")
	result = rx.ReplaceAll(result, Chr(34))
	
	rx = CreateObject("roRegEx", "&\w+;", "")
	result = rx.ReplaceAll(result, Chr(34))
	
	rx = CreateObject("roRegEx", "&#8211;", "")
	result = rx.ReplaceAll(result, "-")
	
	return result
end function

function NWM_UT_HTMLStripTags(inStr)
	result = inStr
	
	rx = CreateObject("roRegEx", "<.*?>", "")
	result = rx.ReplaceAll(result, "")

	return result
end function

'	SimpleJSONParser is adapted from code contributed by the Roku developer community
'	http://forums.roku.com/viewtopic.php?f=34&t=32208
Function NWM_UT_SimpleJSONParser( jsonString As String ) As Object
	q = chr(34)

	beforeKey  = "[,{]"
	keyFiller  = "[^:]*?"
	keyNospace = "[-_\w\d]+"
	valueStart = "[" +q+ "\d\[{]|true|false|null"
	reReplaceKeySpaces = "("+beforeKey+")\s*"+q+"("+keyFiller+")("+keyNospace+")\s+("+keyNospace+")\s*"+q+"\s*:\s*(" + valueStart + ")"

	regexKeyUnquote = CreateObject( "roRegex", q + "([a-zA-Z0-9_\-\s]*)" + q + "\:", "i" )
	regexValueQuote = CreateObject( "roRegex", "\:(\d+)([,\}])", "i" )
	regexValueUnslash = CreateObject( "roRegex", "\\/", "i" )
	regexKeyUnspace = CreateObject( "roRegex", reReplaceKeySpaces, "i" )
	regexQuote = CreateObject( "roRegex", "\\" + q, "i" )

	' setup "null" variable
	null = invalid

	' Replace escaped quotes
	jsonString = regexQuote.ReplaceAll( jsonString, q + " + q + " + q )

	while regexKeyUnspace.isMatch( jsonString )
					jsonString = regexKeyUnspace.ReplaceAll( jsonString, "\1"+q+"\2\3\4"+q+": \5" )
	end while

	jsonString = regexKeyUnquote.ReplaceAll( jsonString, "\1:" )
	jsonString = regexValueQuote.ReplaceAll( jsonString, ":" + q + "\1" + q + "\2" )
	jsonString = regexValueUnslash.ReplaceAll( jsonString, "/" )

	jsonObject = invalid
	' Eval the BrightScript formatted JSON string
	Eval( "jsonObject = " + jsonString )
	Return jsonObject
End Function

function NWM_UTIL_GetIPAddress()
	result = ""
	
	addrs = CreateObject("roDeviceInfo").GetIPAddrs()
	PrintAA(addrs)
	
	if addrs.eth0 <> invalid ' WIRED
		result = addrs.eth0.Trim()
	else if addrs.eth1 <> invalid ' WIFI
		result = addrs.eth1.Trim()
	end if
	
	return result
end function

function NWM_UTIL_Chunk(str, len)	
  result = []
	
	while str.Len() > 0
		result.Push(str.Left(len))
		str = str.Right(str.Len() - len)
	end while
	
	return result
end function
