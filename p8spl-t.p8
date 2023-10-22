pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function _init()   
    netherY=128   
    gravity=3
    qualRects={}
    allRectDistances={{0,0}}
    debug=1
    countScore=0
    countSplit=0
    typeSplit=0 -- "1" is vertical. "0" is horizontal.
    currentColor=7
    selectColor=10
    maxX=80
    maxY=126
    -- minArea=90
    minWidth=3
    minHeight=2
    playSurfaceCol=13
    allRects={}
    -- Create first rect and add it to array.
    add(allRects,createnewRect(0,0,maxX,maxY,playSurfaceCol,playSurfaceCol))
end

function get_key_for_value( t, value )
    for k,v in pairs(t) do
      if v==value then return k end
    end
    return 0
  end

function sort(arr) -- Slow sort, expects {{key,obj}...}. Returns array in ascending values of key.
    for i=1,#arr do
      for j=i,#arr do
        if arr[j][1] < arr[i][1] then
          add(arr,deli(arr,j),i) --slow swap
        end
      end
    end
  end

function createnewRect(i1,j1,i2,j2,fColor,bColor,midpoint,area)
    newRect={x1=i1,y1=j1,x2=i2,y2=j2,fColor=fColor,bColor=bColor,midpoint=0,area=0}
    newRect.midpoint={x=getMidpoint(newRect)[1], y=getMidpoint(newRect)[2]}
    newRect.area=(newRect.x2-newRect.x1)*(newRect.y2-newRect.y1)
    return newRect
end

function splitRect(selectedRect, typeSplit)
    local x1=selectedRect.x1
    local y1=selectedRect.y1
    local x2=selectedRect.x2
    local y2=selectedRect.y2
    if typeSplit==0 then
        newx2=(x2-x1)/2+x1
        add(allRects,createnewRect(x1,y1,newx2,y2,currentColor,playSurfaceCol),count(allRects)+1)
        add(allRects,createnewRect(newx2,y1,x2,y2,currentColor,playSurfaceCol),count(allRects)+1)
    end
    if typeSplit==1 then
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
    if (((selectedRect.y2 - selectedRect.y1)>2*minHeight)and((selectedRect.x2 - selectedRect.x1)>2*minWidth)) then
        if (countSplit%2>0) typeSplit=1
        if (countSplit%2==0) typeSplit=0
        splitRect(selectedRect, typeSplit)
        countSplit+=1
    else
        selectedRect.fColor=8 -- Red
        print("Not allowed!", maxX+2, 18,currentColor)
    end
end

function getMidpoint(selectedRect) -- returns {x,y}
    return {(selectedRect.x2-selectedRect.x1)/2+selectedRect.x1,(selectedRect.y2-selectedRect.y1)/2+selectedRect.y1}
end

function getDistance(rectA, rectB) -- Return {number, rect}
    distance=((rectA.midpoint.x-rectB.midpoint.x)^2+(rectA.midpoint.y-rectB.midpoint.y)^2)^0.5
    return {distance, rectB}
end

function directionOps(direction)
    for i in all(allRects) do 
        i.fColor=currentColor
        i.bColor=playSurfaceCol
    end
    allRectDistances={}
    for i in all(allRects) do
        if ((direction=="right") and (i.midpoint.x>selectedRect.midpoint.x) and get_key_for_value(allRects,selectedRect)~=get_key_for_value(allRects,i)) add(allRectDistances, getDistance(selectedRect, i))
        
        if ((direction=="left") and (i.midpoint.x<selectedRect.midpoint.x) and get_key_for_value(allRects,selectedRect)~=get_key_for_value(allRects,i)) add(allRectDistances, getDistance(selectedRect, i))

        if ((direction=="up") and (i.midpoint.y<selectedRect.midpoint.y) and get_key_for_value(allRects,selectedRect)~=get_key_for_value(allRects,i)) add(allRectDistances, getDistance(selectedRect, i))
        
        if ((direction=="down") and (i.midpoint.y>selectedRect.midpoint.y) and get_key_for_value(allRects,selectedRect)~=get_key_for_value(allRects,i)) add(allRectDistances, getDistance(selectedRect, i))
    end
    
    if (count(allRectDistances)==0) then
        allRectDistances={{0,0}} 
        selectedRect.fColor=selectColor
    else
        sort(allRectDistances)
        allRectDistances[1][2].fColor=selectColor
        selectedRect=allRectDistances[1][2]
    end
end

function findqualifiedRects(allRects)
    for i in all(allRects) do 
        for j in all(allRects) do 
            if ((i~=j) and  (i.area==j.area) and (i.midpoint.y==j.midpoint.y)) then
                for k in all(allRects) do
                    if ( (j~=k) and (j.area==k.area) and (j.midpoint.x==k.midpoint.x)) then
                        for l in all(allRects) do
                            if ( (k~=l) and (k.area==l.area) and (k.midpoint.y==l.midpoint.y) and (i.midpoint.x==l.midpoint.x)) then
                                add(qualRects,{i,j,k,l,splitsLeft=countSplit}) -- Todo: Del i,j,k,l from allRects. Draw qualRects separately from allRects.
                                del(allRects,i)
                                del(allRects,j)
                                del(allRects,k)
                                del(allRects,l)
                            end
                        end
                    end
                end
            end
        end
    end
end

function doeachturn()
    for i in all(qualRects) do 
        i.splitsLeft-=1
        if (i.splitsLeft==0) del(qualRects,i)
    end
    findtop()
end

function bottomCheck(RectC)
    local bottomIsClear=0
    local bottomMatrix={}
    local x1=RectC.x1+1
    local x2=RectC.x2-1
    local y1=RectC.y1
    local y2=RectC.y2
    local x9=x1
    local xtemp=0
    local ytemp=0
    -- if (x2<x1) print("ouch") xtemp=x2 x2=x1 x1=xtemp ytemp=y2 y2=y1 y1=ytemp 

    while (x9<=x2) do
        add(bottomMatrix,{x9,y2})
        x9=x9+minWidth
    end

    for j in all(bottomMatrix) do
        if (j[2]>=126) bottomIsClear+=1 return bottomIsClear
        if (pget(j[1],j[2]+1)~=0) bottomIsClear+=1 return bottomIsClear
    end

    return bottomIsClear
end

function findtop()
    possibleRects={}
    for i=0, maxX, 1 do  
        if (pget(i,0)==0) then -- find x1 if first pixel is black (eg empty)
            for j=minWidth, maxX+1, 1 do -- then try to find x2
                if ((pget(j,0)~=0) or ((j==maxX)and(pget(maxX,0)==0)) )then -- upon hitting the first pixel that is not black
                    for k=minHeight, 126, 1 do -- go down and try to find y2
                        if (pget(j-1,k)~=0) then -- upon hitting the first pixel below that is not black
                            newRect=createnewRect(i,0-netherY,j-1,k-1-netherY,currentColor,playSurfaceCol)  -- netherY for rectangles to appear off screen first
                            add(possibleRects,{newRect.area,newRect})
                            if (count(possibleRects)>2) break
                        end
                        if (count(possibleRects)>2) break                        
                    end
                    if (count(possibleRects)>2) break
                end
                if (count(possibleRects)>2) break
            end
            if (count(possibleRects)>2) break
        end
        if (count(possibleRects)>2) break
    end                     



    for i=40, maxX, 1 do  
        if (pget(i,0)==0) then -- find x1 if first pixel is black (eg empty)
            for j=minWidth, maxX+1, 1 do -- then try to find x2
                if ((pget(j,0)~=0))then -- upon hitting the first pixel that is not black
                    for k=minHeight, 126, 1 do -- go down and try to find y2
                        if (pget(j-1,k)~=0) then -- upon hitting the first pixel below that is not black
                            newRect=createnewRect(i,0-netherY,j-1,k-1-netherY,currentColor,playSurfaceCol)  -- netherY for rectangles to appear off screen first
                            add(possibleRects,{newRect.area,newRect})
                            if (count(possibleRects)>4) break
                        end
                        if (count(possibleRects)>4) break                        
                    end
                    if (count(possibleRects)>4) break
                end
                
                if ((j==maxX)and(pget(maxX,0)==0)) then 
                    for k=minHeight, 126, 1 do -- go down and try to find y2
                        if (pget(j-1,k)==0) then -- upon hitting the first pixel below that is not black
                            newRect=createnewRect(i,0-netherY,j-1,k-1-netherY,currentColor,playSurfaceCol)  -- netherY for rectangles to appear off screen first
                            add(possibleRects,{newRect.area,newRect})
                            if (count(possibleRects)>4) break
                        end
                        if (count(possibleRects)>4) break                        
                    end
                    if (count(possibleRects)>4) break
                end
                if (count(possibleRects)>4) break
            end
            if (count(possibleRects)>4) break
        end
        if (count(possibleRects)>4) break
    end                     





    if (count(possibleRects)>0) then
        sort(possibleRects)
        add(allRects,possibleRects[(count(possibleRects))][2])
        return 1
    else
        return 0
    end
end     

function _update()

    for i in all(allRects) do
        if (bottomCheck(i)==0) i.y1=i.y1+1*gravity i.y2=i.y2+1*gravity -- i.midpoint=getMidpoint(i)
    end

    if count(qualRects)>0 then
        for j in all(qualRects) do
                for k=1, 4, 1 do
                    if (bottomCheck(j[k])==0) j[k].y1=j[k].y1+1*gravity j[k].y2=j[k].y2+1*gravity -- j[k].midpoint=getMidpoint(j[k])
                end 
        end
    end
    
    if btnp(➡️) then 
        directionOps("right")
    end

    if btnp(⬅️) then 
        directionOps("left")  
    end

    if btnp(⬆️) then 
        directionOps("up")
    end
    
    if btnp(⬇️) then 
        directionOps("down")
    end

    -- if (btnp(4)) currentColor=flr(rnd(15))
    
    if (btnp(5)) attemptSplit(selectedRect) selectedRect=allRects[count(allRects)] selectedRect.fColor=selectColor findqualifiedRects(allRects) doeachturn()

    if count(allRects) <= 1 then -- Selected default rectangle if there is only 1 rectangle.
        selectedRect=allRects[count(allRects)]
    end

end

function _draw()
    cls()
    for i in all(allRects) do
        drawnewRect(i)
    end

    for i in all(qualRects) do 
        drawnewRect(i[1])
        drawnewRect(i[2])
        drawnewRect(i[3])
        drawnewRect(i[4])
        i[1].fColor=11
        i[2].fColor=11
        i[3].fColor=11
        i[4].fColor=11
        print(i.splitsLeft,(max(max(i[1].midpoint.x,i[2].midpoint.x),i[3].midpoint.x)-min(min(i[1].midpoint.x,i[2].midpoint.x)-3,i[3].midpoint.x))/2+min(min(i[1].midpoint.x,i[2].midpoint.x),i[3].midpoint.x),min(min(i[1].y2,i[2].y2),i[3].y2)-3,7)
    end

    print("score:"..countScore, maxX+2, 0,currentColor)
    print("split:"..countSplit, maxX+2, 6,currentColor)
    print("type:"..typeSplit, maxX+2, 12,currentColor)
    
    if debug==1 then
        -- print("rArea: "..selectedRect.area, maxX+2, 70,currentColor)
        -- print("sRect: "..get_key_for_value(allRects,selectedRect), maxX+2, 70,currentColor)
        -- print("rectC: "..count(allRects), maxX+2, 64,currentColor)
        -- print("qRect: "..count(qualRects), maxX+2, 76,currentColor)
        -- print("qcount: "..debugqcount, maxX+2, 82,currentColor)
        -- print("s:x: "..selectedRect.midpoint.x, maxX+2, 88,currentColor)
        -- print("s:y: "..selectedRect.midpoint.y, maxX+2, 94,currentColor)
        -- if count(allRectDistances)>2 then
        --     for k in all(allRectDistances) do k[2].bColor=12 
        --     end
        -- end
    end
    
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
