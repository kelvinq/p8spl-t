pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function get_key_for_value( t, value )
    for k,v in pairs(t) do
      if v==value then return k end
    end
    return 0
  end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function sort(arr) -- slow sort, expects {{key,obj}...}
    for i=1,#arr do
      for j=i,#arr do
        if arr[j][1] < arr[i][1] then
          add(arr,deli(arr,j),i) --slow swap
        end
      end
    end
  end

function createnewRect(i1,j1,i2,j2,fColor,bColor,midpoint)
    newRect={x1=i1,y1=j1,x2=i2,y2=j2,fColor=fColor,bColor=bColor,midpoint=0}
    newRect.midpoint={x=getMidpoint(newRect)[1], y=getMidpoint(newRect)[2]}
    return newRect
end

function splitRect(selectedRect, typeSplit)
    local x1=selectedRect.x1
    local y1=selectedRect.y1
    local x2=selectedRect.x2
    local y2=selectedRect.y2
    if typeSplit==1 then
        newx2=(x2-x1)/2+x1
        add(allRects,createnewRect(x1,y1,newx2,y2,currentColor,playSurfaceCol),count(allRects)+1)
        add(allRects,createnewRect(newx2,y1,x2,y2,currentColor,playSurfaceCol),count(allRects)+1)
    end
    if typeSplit==0 then
        newy2=(y2-y1)/2+y1
        add(allRects,createnewRect(x1,y1,x2,newy2,currentColor,playSurfaceCol),count(allRects)+1)
        add(allRects,createnewRect(x1,newy2,x2,y2,currentColor,playSurfaceCol),count(allRects)+1)
    end
    del(allRects,selectedRect)
end
    
function drawnewRect(newRect)
    rectfill(newRect.x1,newRect.y1,newRect.x2,newRect.y2,newRect.fColor)
    rect(newRect.x1,newRect.y1,newRect.x2,newRect.y2,newRect.bColor)
end

function attemptSplit(selectedRect)
    if area(selectedRect)>minArea then
        if (countSplit%2>0) typeSplit=1
        if (countSplit%2==0) typeSplit=0
        splitRect(selectedRect, typeSplit)
        countSplit+=1
    else
        selectedRect.fColor=8 -- Red
        print("Not allowed!", maxX+2, 18,currentColor)
        selectedRect.fColor=currentColor
    end
end

function area(selectedRect)
    return (selectedRect.x2-selectedRect.x1)*(selectedRect.y2-selectedRect.y1)
end

function nearestRect(selectedRect, direction)
    local allRectscopy = shallowcopy(allRects)
    deli(allRectDistances,get_key_for_value(allRects,selectedRect))
    
    for i in all(allRectscopy) do
        if ((direction=="right")and(i.midpoint.x>selectedRect.midpoint.x)) add(allRectDistances, getDistance(selectedRect, i)) circfill(i.midpoint.x,i.midpoint.y,1,8)
        if ((direction=="left")and(i.midpoint.x<selectedRect.midpoint.x)) add(allRectDistances, getDistance(selectedRect, i)) circfill(i.midpoint.x,i.midpoint.y,1,8)
        if ((direction=="up")and(i.midpoint.y<selectedRect.midpoint.y)) add(allRectDistances, getDistance(selectedRect, i)) circfill(i.midpoint.x,i.midpoint.y,1,8)
        if ((direction=="down")and(i.midpoint.y>selectedRect.midpoint.y)) add(allRectDistances, getDistance(selectedRect, i)) circfill(i.midpoint.x,i.midpoint.y,1,8)
    end
    if (count(allRectDistances)<1) return selectedRect
    sort(allRectDistances)
    return allRectDistances[1][2]
end

function getMidpoint(selectedRect) -- returns {x,y}
    --return {,(selectedRect.y2-selectedRect.y1)/2+selectedRect.y1}
    return {(selectedRect.x2-selectedRect.x1)/2+selectedRect.x1,(selectedRect.y2-selectedRect.y1)/2+selectedRect.y1}
end

function getDistance(rectA, rectB) -- Return {number, rect}
    closestDistance=((rectA.midpoint.x-rectB.midpoint.x)^2+(rectA.midpoint.y-rectB.midpoint.y)^2)^0.5
    return {closestDistance, rectB}
end

function _init()        
    printRectD={}
    allRectDistances={{0,0}}
    previousRectCount=0
    previousRectIndex=2
    currentRectIndex=2
    debug=1
    countScore=0
    countSplit=0
    typeSplit=0 -- "1" is vertical. "0" is horizontal.
    currentCur={x=64,y=64}
    currentColor=7
    selectColor=10
    maxX=80
    maxY=126
    minArea=16
    playSurfaceCol=13
    allRects={}
    -- Create the first rectangle and that is the game surface
    add(allRects,createnewRect(0,0,maxX,maxY,playSurfaceCol,playSurfaceCol))
    add(allRects,createnewRect(0,0,maxX,maxY,playSurfaceCol,playSurfaceCol)) -- Draw again to avoid zero error. To fix later.
end

function _update()
    if ((countSplit==1)and(count(allRects)==3)) deli(allRects,1)
end

function _draw()
    if count(allRects) <= 2 then
        selectedRect=allRects[count(allRects)]
    end
    
    cls()
    for i in all(allRects) do
        drawnewRect(i)
    end

    -- Draw the selected rectangle
    if btnp(➡️) then 
        allRectDistances={}
        for i in all(allRects) do 
            i.fColor=currentColor
        end
        selectedRect=nearestRect(allRects[currentRectIndex], "right")
        selectedRect.fColor=selectColor
    end

    if btnp(⬅️) then 
        allRectDistances={}
        for i in all(allRects) do 
            i.fColor=currentColor
        end
        selectedRect=nearestRect(allRects[currentRectIndex], "left")
        selectedRect.fColor=selectColor    
    end

    if btnp(⬆️) then 
        allRectDistances={}
        for i in all(allRects) do 
            i.fColor=currentColor
        end
        selectedRect=nearestRect(allRects[currentRectIndex], "up")
        selectedRect.fColor=selectColor
    end
    
    if btnp(⬇️) then 
        allRectDistances={}
        for i in all(allRects) do 
            i.fColor=currentColor
        end
        selectedRect=nearestRect(allRects[currentRectIndex], "down")
        selectedRect.fColor=selectColor
    end

    if (btnp(4)) currentColor=flr(rnd(15))
    
    if (btnp(5)) attemptSplit(selectedRect) selectedRect=allRects[count(allRects)] selectedRect.fColor=selectColor

    print("score:"..countScore, maxX+2, 0,currentColor)
    print("split:"..countSplit, maxX+2, 6,currentColor)
    print("type:"..typeSplit, maxX+2, 12,currentColor)
    if debug==1 then
        -- print(closestDistance, maxX+2, 64, currentColor)
        print("thisRect: "..get_key_for_value(allRects, selectedRect), maxX+2, 59, currentColor)
        print(selectedRect.midpoint.x..", "..selectedRect.midpoint.y..":midpoint "..get_key_for_value(allRects, selectedRect), maxX+2, 64, currentColor)
        print("MaxRect: "..count(allRects), maxX+2, 69, currentColor)
        --print("current x: "..currentCur.x..", current x: "..currentCur.y, 0, 114,7)
        -- print("rect count: "..count(allRects)..", area: "..area(selectedRect), 0, 120,7)
        -- print(getDistance(allRects[1],allRects[currentRectIndex])[1].."allrectcount: "..allRectDistances[1][1], 0, 115,7)
        -- print(testArrayUnsorted[1][2].." "..testArrayUnsorted[2][2].." "..testArrayUnsorted[3][2].." "..testArrayUnsorted[99][2], maxX+2, 64, currentColor)
        -- print(testArray[1][2].." "..testArray[2][2].." "..testArray[3][2].." "..testArray[99][2], maxX+2, 64+5, currentColor)
    end
    
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
