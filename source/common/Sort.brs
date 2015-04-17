sub internalQSort(A as Object, left as integer, right as integer)
    i = left
    j = right
    pivot = A[(left+right)/2]
    while i <= j
        while A[i] < pivot
            i = i + 1
        end while
        while A[j] > pivot
            j = j - 1
        end while
        if (i <= j)
            tmp = A[i]
            A[i] = A[j]
            A[j] = tmp
            i = i + 1
            j = j - 1
        end if
    end while
    if (left < j)
        internalQSort(A, left, j)
    endif
    if (i < right)
        internalQSort(A, i, right)
    end if        
end sub

sub internalKeyQSort(A as Object, key as dynamic, left as integer, right as integer)
    i = left
    j = right
    pivot = key(A[(left+right)/2])
    while i <= j
        while key(A[i]) < pivot
            i = i + 1
        end while
        while key(A[j]) > pivot
            j = j - 1
        end while
        if (i <= j)
            tmp = A[i]
            A[i] = A[j]
            A[j] = tmp
            i = i + 1
            j = j - 1
        end if
    end while
    if (left < j)
        internalKeyQSort(A, key, left, j)
    endif
    if (i < right)
        internalKeyQSort(A, key, i, right)
    end if        
end sub

' quicksort an array using an indentically sized array that holds the comparison values
Function internalKeyArrayQSort(A as Object, keys as object, left as integer, right as integer) as void
    i = left
    j = right
    pivot = keys[A[(left+right)/2]]
    while i <= j
        while keys[A[i]] < pivot
            i = i + 1
        end while
        while keys[A[j]] > pivot
            j = j - 1
        end while
        if (i <= j)
            tmp = A[i]
            A[i] = A[j]
            A[j] = tmp
            i = i + 1
            j = j - 1
        end if
    end while
    if (left < j)
        internalKeyArrayQSort(A, keys, left, j)
    endif
    if (i < right)
        internalKeyArrayQSort(A, keys, i, right)
    end if        
End function

'******************************************************
' QuickSort(Array, optional keys function or array)
' Will sort an array directly
' If key is a function it is called to get the value for comparison
' If key is an identically sized array as the array to be sorted then
' the comparison values are pulled from there. In this case the Array
' to be sorted should be an array if integers 0 .. arraysize-1
'******************************************************
Function QuickSort(A as Object, key=invalid as dynamic) as void
    atype = type(A)
    if atype<>"roArray" then return
    ' weed out trivial arrays
    arraysize = A.Count()
    if arraysize < 2 then return
    if (key=invalid) then
        internalQSort(A, 0, arraysize - 1)
    else
        keytype = type(key)
        if keytype="Function" then
            internalKeyQSort(A, key, 0, arraysize - 1)
        else if (keytype="roArray" or keytype="Array") and key.count() = arraysize then
            internalKeyArrayQSort(A, key, 0, arraysize - 1)
        end if
    end if
End Function


'***************************************************************************
' MakeLowestLast
' finds the lowest value item and exchanges it with the end of the array.
' If it is already at the end of the array don't do anything.
' This is designed to make it easy to use pop to extract the element
' Pop/Push is more efficient then shift/unshift when manipulating arrays
'***************************************************************************
Sub MakeLowestLast(A as Object, key=invalid as dynamic)
    if type(A)<>"roArray" then return
    array_end = A.count()-1
    if array_end <= 0 then return ' fewer than two things in the list
    lowest = array_end
    if (key=invalid) then
        lowestval = A[lowest]
        for i = 0 to A.Count()-2
            value = A[i]
            if lowestval > value
                lowestval = value
                lowest = i              ' remember new lowest
            endif
        next
        if lowest<array_end
            A[lowest] = A[array_end]
            A[array_end] = lowestval
        endif
    else
        tk = type(key)
        if tk<>"Function" and tk<>"roFunction" then return
        lowestval = key(A[lowest])
        for i = 0 to A.Count()-2
            value = key(A[i])
            if lowestval > value
                lowestval = value
                lowest = i
            endif
        next
        if lowest<array_end
            t = A[array_end]
            A[array_end] = A[lowest]
            A[lowest] = t
        endif
    end if
End Sub

