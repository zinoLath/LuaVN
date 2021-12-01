local Interpolate = math.lerp
voidfunc = function()  end
function SetFieldInTime(tb,time,func,...)
    local args = {...}
    for k,v in ipairs(args) do
        v[0] = tb[v[1]]
    end
    func = func or Linear
    for i=0, 1, 1/time do
        local j = func(i)
        for k,v in ipairs(args) do
            tb[v[1]] = Interpolate(v[0], v[2], j)
        end
        coroutine.yield()
    end
    for k,v in ipairs(args) do
        tb[v[1]] = v[2]
    end
end

local lerp = math.lerp
---times, variables, function
---function = (var1, var2, var3, ..., index)
---variables = {type, args}
---
---incremental = {start, increment}
---linear = {from, to, precisely, tween}
---sinwave = {from, to, initial_angle, periodn, precisely}
function AdvancedFor(times,...)
    local args = {...}
    local func = args[#args]
    table.remove(args)
    local variables = {}
    for k,v in ipairs(args) do
        if v[1] ~= 'sinwave' then
            variables[k] = v[2]
        else
            variables[k] = lerp(v[2],v[3],0.5 + 0.5 * sin(v[4]))
        end
    end
    for i=1, times do
        for k,v in ipairs(args) do
            if v[1] == 'incremental' then
                variables[k] = variables[k] + v[3]
            elseif v[1] == 'linear' then
                variables[k] = lerp(v[2], v[3], v[4] and i/(times-1) or i/times)
            elseif v[1] == 'sinwave' then
                variables[k] = lerp(v[2], v[3], 0.5 + 0.5 * sin(v[4] + v[6] and (360*v[5])/(times-1) or (360*v[5])/times))
            end
        end
        func(unpack(variables),i)
    end
end

function PrintTable(tb)
    local ret = ""
    for k,v in pairs(tb) do
        ret = ret .. string.format("Key: %s | Value: %s\n\n", k,tostring(v))
    end
    return ret
end

function FindKey(tb, value)
    for k,v in pairs(tb) do
        if v == value then
            return k
        end
    end
end
function InterpolateColor(a,b,t)
    return Color(
            Interpolate(a.a,b.a,t),
            Interpolate(a.r,b.r,t),
            Interpolate(a.g,b.g,t),
            Interpolate(a.b,b.b,t)
    )
end