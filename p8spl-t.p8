pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function createnewRect(i1,j1,i2,j2,fColor,bColor)
    newRect={x1=i1,y1=j1,x2=i2,y2=j2,fColor=fColor,bColor=bColor}
    return newRect
end

function splitRect(selectedRect, typeSplit)
    local x1=selectedRect.x1
    local y1=selectedRect.y1
    local x2=selectedRect.x2
    local y2=selectedRect.y2
    if typeSplit==1 then
        newx2=(x2-x1)/2+x1
        add(allRects,createnewRect(x1,y1,newx2,y2,currentColor,playSurfaceCol))
        add(allRects,createnewRect(newx2,y1,x2,y2,currentColor,playSurfaceCol))
    end
    if typeSplit==0 then
        newy2=(y2-y1)/2+y1
        add(allRects,createnewRect(x1,y1,x2,newy2,currentColor,playSurfaceCol))
        add(allRects,createnewRect(x1,newy2,x2,y2,currentColor,playSurfaceCol))
    end
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
        -- Delete previous rectangle
        previousRectIndex=currentRectIndex
        deli(allRects, previousRectIndex)
        currentRectIndex=count(allRects)
        allRects[currentRectIndex].fColor=selectColor
    else
        selectedRect.bColor=8 -- Red
        print("Not allowed!", maxX+2, 18,currentColor)
        selectedRect.bColor=playSurfaceCol
    end
end

function area(selectedRect)
    return (selectedRect.x2-selectedRect.x1)*(selectedRect.y2-selectedRect.y1)
end

function _init()
    previousRectIndex=1
    currentRectIndex=1
    debug=1
    countScore=0
    countSplit=0
    typeSplit=0 -- "1" is vertical. "0" is horizontal.
    currentCur={x=64,y=64}
    currentColor=11
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
    -- Control player
    -- if (btn(⬅️)) verts.i-=1
    -- if (btn(➡️)) verts.i+=1    
end

function _draw()
    cls()
    for i in all(allRects) do
        drawnewRect(i)
    end

    -- Draw the selected rectangle
    if btnp(⬆️) then 
        if currentRectIndex < count(allRects) then
            currentRectIndex+=1 
        end
        allRects[currentRectIndex].fColor=selectColor allRects[currentRectIndex-1].fColor=currentColor
    end
    
    if btnp(⬇️) then 
        if currentRectIndex-1 > 0 then
            currentRectIndex-=1
        end
        allRects[currentRectIndex].fColor=selectColor allRects[currentRectIndex+1].fColor=currentColor
    end

    if (btnp(4)) currentColor=flr(rnd(15))
    
    if count(allRects) <= 1 then
        selectedRect=allRects[1]
    else
        selectedRect=allRects[currentRectIndex]
    end
    
    if (btnp(5)) attemptSplit(selectedRect)

    print("score:"..countScore, maxX+2, 0,currentColor)
    print("split:"..countSplit, maxX+2, 6,currentColor)
    print("type:"..typeSplit, maxX+2, 12,currentColor)
    if debug==1 then
        print(allRects[currentRectIndex].y2..":y2 "..": "..currentRectIndex, maxX+2, 64, currentColor)
        --print("current x: "..currentCur.x..", current x: "..currentCur.y, 0, 114,7)
        print("rect count: "..count(allRects)..", area: "..area(selectedRect), 0, 120,7)
    end
    
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
