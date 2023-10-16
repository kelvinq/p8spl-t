pico-8 cartridge // http://www.pico-8.com
version 41
__lua__


function get_key_for_value( t, value )
    for k,v in pairs(t) do
      if v==value then return k end
    end
    return 0
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
    if selectedRect.area>minArea then
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
        if ((direction=="right") and (i.midpoint.x>selectedRect.midpoint.x) and get_key_for_value(allRects,selectedRect)~=get_key_for_value(allRects,i)) add(allRectDistances, getDistance(selectedRect, i)) circfill(i.midpoint.x,i.midpoint.y,1,8)
        
        if ((direction=="left") and (i.midpoint.x<selectedRect.midpoint.x) and get_key_for_value(allRects,selectedRect)~=get_key_for_value(allRects,i)) add(allRectDistances, getDistance(selectedRect, i)) circfill(i.midpoint.x,i.midpoint.y,1,8)

        if ((direction=="up") and (i.midpoint.y<selectedRect.midpoint.y) and get_key_for_value(allRects,selectedRect)~=get_key_for_value(allRects,i)) add(allRectDistances, getDistance(selectedRect, i)) circfill(i.midpoint.x,i.midpoint.y,1,8)
        
        if ((direction=="down") and (i.midpoint.y>selectedRect.midpoint.y) and get_key_for_value(allRects,selectedRect)~=get_key_for_value(allRects,i)) add(allRectDistances, getDistance(selectedRect, i)) circfill(i.midpoint.x,i.midpoint.y,1,8)
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

function _init()      
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
    minArea=90
    playSurfaceCol=13
    allRects={}
    -- Create first rect and add it to array.
    add(allRects,createnewRect(0,0,maxX,maxY,playSurfaceCol,playSurfaceCol))
end

function findqualifiedRects(allRects)
    for i in all(allRects) do 
        for j in all(allRects) do 
            if ((i~=j) and  (i.area==j.area) and (i.midpoint.y==j.midpoint.y)) then
                for k in all(allRects) do
                    if ( (j~=k) and (j.area==k.area) and (j.midpoint.x==k.midpoint.x)) then
                        for l in all(allRects) do
                            if ( (k~=l) and (k.area==l.area) and (k.midpoint.y==l.midpoint.y) and (i.midpoint.x==l.midpoint.x)) then
                            add(qualRects,{i,j,k,l,countSplit}) -- Todo: Del i,j,k,l from allRects. Draw qualRects separately from allRects.
                            end
                        end
                    end
                end
            end
        end
    end
end

function _update()

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

    if (btnp(4)) currentColor=flr(rnd(15))
    
    if (btnp(5)) attemptSplit(selectedRect) selectedRect=allRects[count(allRects)] selectedRect.fColor=selectColor findqualifiedRects(allRects)

    if count(allRects) <= 1 then -- Selected default rectangle if there is only 1 rectangle.
        selectedRect=allRects[count(allRects)]
    end

end

function _draw()
    cls()
    for i in all(allRects) do
        drawnewRect(i)
    end

    if count(qualRects)>=4 then
        for i in all(qualRects) do 
            
            i[1].fColor=flr(rnd(15))
            i[2].fColor=flr(rnd(15))
            i[3].fColor=flr(rnd(15))
            i[4].fColor=flr(rnd(15))
        
            print(i[5],i[1].midpoint.x,i[1].midpoint.y,7)
        end
    end

    print("score:"..countScore, maxX+2, 0,currentColor)
    print("split:"..countSplit, maxX+2, 6,currentColor)
    print("type:"..typeSplit, maxX+2, 12,currentColor)
    
    if debug==1 then
        print("rArea: "..selectedRect.area, maxX+2, 70,currentColor)
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
