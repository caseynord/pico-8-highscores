pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- fork of 'Persistant High Score Demo Table' by GrumpyDev
-- https://www.lexaloffle.com/bbs/?tid=31901


-- input enumerations
up=2
down=3
left=0
right=1
btn_1=5
btn_2=4


function _init()
    -- unique key for save data
    cartdata("nord_high_score_demo")

    high_score_table.reset_high_scores()  --for debugging
    high_score_table.load_scores()
end

function _update60()
    -- when not entering a score, inputs should modify values
    if not score_entry.entering then
        if btnp(left) then  -- decrease
            high_score_table.add_current_score(-100)
        end
        if btn(right) then  -- increase
            high_score_table.add_current_score(100)
        end 
        if btnp(up) or btn(btn_1) then  -- enter score
            high_score_table.submit_score(high_score_table.current_score)
        end
    end

    -- main update
    high_score_table.update()
end

function _draw()
    cls()

    -- moving score animation
    high_score_table.draw()

    -- centered 'score' displayed at bottom center of screen
    local debug_string="score: "..high_score_table.get_score_text(high_score_table.current_score)
    print(debug_string, 64-#debug_string*2, 114, 8)
end

-->8
-- high score code
high_score_table={ 
    magic_number=42,  -- for identifying save data
    pad_digits=8,     -- score limit (default is 99,999,999)
    base_address=0,
    a=0,              -- animation value for included draw function
    current_score=0,
    scores={}         -- table of high scores (needs to be loaded)
}

-- defines allowed characters
high_score_table.characters={"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9"," "}

score_entry={
    entering=false,
    entry_number=1,
    entry_character=1,
    characters={0,0,0},
    cycle_colours={10,9,8,14},
    current_colour=1,
    cycle_count=0
}

function high_score_table.update()
    if score_entry.entering then
        score_entry.cycle_count+=1

        -- flashing text
        if score_entry.cycle_count>5 then
            score_entry.cycle_count=0
            score_entry.current_colour+=1
            if score_entry.current_colour>#score_entry.cycle_colours then
                score_entry.current_colour=1
            end
        end

        -- cycle letters
        if btnp(up) then
            score_entry.characters[score_entry.entry_character]+=1
            if score_entry.characters[score_entry.entry_character]>#high_score_table.characters then
                score_entry.characters[score_entry.entry_character]=1
            end
        end
        if btnp(down) then
            score_entry.characters[score_entry.entry_character]-=1
            if score_entry.characters[score_entry.entry_character]<1 then
                score_entry.characters[score_entry.entry_character]=#high_score_table.characters
            end
        end

        -- cycle places
        if btnp(right) then 
            score_entry.entry_character=min(3, score_entry.entry_character+1)
        end
        if btnp(left) then
            score_entry.entry_character=max(1, score_entry.entry_character-1)
        end

        -- save score
        if btnp(btn_2) then
            high_score_table.scores[score_entry.entry_number].name=high_score_table.array_to_string(score_entry.characters)
            score_entry.entering=false
            high_score_table.save_scores()
        end
    end

    -- accumulates for animated waving text
    high_score_table.a+=0.0157
end

function high_score_table.draw()
    local title_text="high scores"
    print(title_text, 64-#title_text*2, 10, 8)

    -- display each score row
    for i=0, #high_score_table.scores-1 do
        local _score=high_score_table.scores[i+1]
        local _score_name=_score.name
        local _score_c=8

        -- live characters while entering initials
        if score_entry.entering and score_entry.entry_number==i+1 then
            _score_name=high_score_table.array_to_string(score_entry.characters)
            _score_c=score_entry.cycle_colours[score_entry.current_colour]
        end

        -- get initials and score string and x draw position
        local score_text=_score_name.."...."..high_score_table.get_score_text(_score.score)
        local score_x=64-#score_text*2

        -- animate if not entering initials
        if not score_entry.entering then
            score_x+=sin(high_score_table.a+i/10)*5
        end

        print(score_text, score_x, 8*i+20, _score_c)

        -- draw line under character if entering initials
        if score_entry.entering and score_entry.entry_number==i+1 then
            local start_x=score_x+(score_entry.entry_character-1)*4
            line (start_x, 8*i+26, start_x+2, 8*i+26, _score_c)
        end
    end
end

-- adding scores using bit shifting to allow for higher values
-- taken from this thread https://www.lexaloffle.com/bbs/?tid=3577
function high_score_table.add_current_score(_value)
    high_score_table.current_score+=shr(_value, 16)
end

function high_score_table.submit_score()
    for i=1,10 do
        if high_score_table.current_score>high_score_table.scores[i].score then
            for j=10,i+1,-1 do
                high_score_table.scores[j]=high_score_table.scores[j-1]
            end
            score_entry.entering=true
            score_entry.entry_number=i
            score_entry.entry_character=1
            score_entry.characters={1,1,1}
            high_score_table.scores[i]={name="aaa", score=high_score_table.current_score}
            return true
        end
    end
    return false
end

function high_score_table.load_scores()
    local _value=dget(high_score_table.base_address)

    if _value~=high_score_table.magic_number then
        for i=1,10 do
            high_score_table.scores[i]={name="aaa", score=shr((11000-i*1000),16)}
        end
        return false
    end

    local _current_address=high_score_table.base_address+1
    high_score_table.scores={}
    for i=1,10 do
        local _digits=""
        score=dget(_current_address)
        _digits=_digits..high_score_table.int_to_char(dget(_current_address+1))
        _digits=_digits..high_score_table.int_to_char(dget(_current_address+2))
        _digits=_digits..high_score_table.int_to_char(dget(_current_address+3))
        high_score_table.scores[i]={name=_digits, score=score}
        _current_address+=4
    end
   
    return true
end

function high_score_table.save_scores()
    dset(high_score_table.base_address, high_score_table.magic_number)

    local _current_address=high_score_table.base_address+1
    for i=1,10 do
        dset(_current_address, high_score_table.scores[i].score)

        dset(_current_address+1, high_score_table.char_to_int(sub(high_score_table.scores[i].name,1,1)))
        dset(_current_address+2, high_score_table.char_to_int(sub(high_score_table.scores[i].name,2,2)))
        dset(_current_address+3, high_score_table.char_to_int(sub(high_score_table.scores[i].name,3,3)))

        _current_address+=4
    end
end

function high_score_table.reset_high_scores()
	for i=1,10 do
		high_score_table.scores[i]={name="aaa", score=shr((11000-i*1000),16)}
	end

	high_score_table.save_scores()
end

function high_score_table.get_score_text(_score_value)
    if _score_value==nil then
        return "0"
    end

    local _s=""
    local _v=abs(_score_value)
    repeat
      _s=shl(_v%0x0.000a, 16).._s
      _v/=10
    until _v==0

	for p=1,high_score_table.pad_digits-#_s do
		_s="0".._s
	end

    if _score_value<0 then
        _s="-".._s
    end

    return _s 
end

function high_score_table.array_to_string(_array)
    local _string=""
    for i=1,#_array do
        _string=_string..high_score_table.int_to_char(_array[i])
    end
    return _string
end

function high_score_table.char_to_int(_char)
    for k,v in pairs(high_score_table.characters) do
        if v==_char then
            return k
        end
    end

    return -1
end

function high_score_table.int_to_char(_int)
    for k,v in pairs(high_score_table.characters) do
        if k==_int then
            return v
        end
    end

    return ""
end
