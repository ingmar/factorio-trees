---- These defaults can be overwritten from the command line using lua -e 'BLA=foo' (or just set them in Makefile)
-- Where the Factorio data/ folder lives
FACTORIO_ROOT = FACTORIO_ROOT or "/Applications/factorio.app/Contents/"
-- Choose your language here
LANGUAGE = LANGUAGE or "en"
-- Set to false to disable string translation
TRANSLATE = TRANSLATE or true

translations = {}

function Img(src)
    -- Convenience function for IMG tags
    return string.format([[<IMG SRC="%s" />]], src)
end

function VizAttr(tbl)
    -- Convert a table of attributes and values into Graphviz syntax
    pair_array = {}
    for attr, value in pairs(tbl) do
        table.insert(pair_array, string.format('%s=%s', attr, value))
    end
    return table.concat(pair_array, ",")
end

-- Extendable table (for the data:extend calls in Factorio LUA)
ExtendTable = {}
function ExtendTable:new(o)
    o = o or {}    -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end
function ExtendTable:extend(other)
    -- Merge tables
    for key, value in pairs(other) do
        while self[key] ~= nil do
            key = key + math.random(1024)    -- Nasty hack to resolve key conflicts.
        end
        self[key] = value
    end
end

function trim(s)
    return s:match('^%s*(.*%S)') or ''
end

function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        f:close()
        return true
    else
        return false
    end
end

data = ExtendTable:new({})
function load_data(files, rel_path)
    for _, filename in ipairs(files) do
        path = FACTORIO_ROOT..rel_path..filename
        dofile(path)
    end
end

-- Load string translations
function load_translations(language_sections)
    language_files = {
        "base.cfg",
    }
    for _, filename in ipairs(language_files) do
        path = FACTORIO_ROOT.."data/base/locale/"..LANGUAGE.."/"..filename
        local f = io.open(path, "r")
        local section
        while true do
            local line = f:read("*line")
            if line == nil then break end
            line = trim(line)
            if line ~= "" then
                if line:sub(1, 1) == "[" then
                    section = line:sub(2, -2)
                    -- io.stderr:write("[", section, "]\n")
                else
                    -- io.stderr:write("-- ", line, "\n")
                    if language_sections[section] then
                        local eq_pos = line:find("=")
                        local lookup = line:sub(1, eq_pos-1)
                        local translation = line:sub(eq_pos+1, -1)
                        translations[lookup] = translation
                        -- io.stderr:write(lookup, "=", translation, "\n")
                    end
                end
            end
        end
        f:close()
    end
end

function T(lookup)
    if not TRANSLATE then
        return lookup
    end
    -- Look up translation for string, returning lookup if none was found
    local translation = translations[lookup]
    if translation == nil then
        io.stderr:write('No translation found for ', lookup, "\n")
        return lookup
    end
    return translation
end

function HtmlLabel(name, img, energy)
    -- Cough up a Graphviz label in their HTML-like syntax
    local clock_icon = FACTORIO_ROOT.."data/core/graphics/clock-icon.png"
    local img_tag = ""
    local energy_tag = ""
    if img ~= nil then img_tag = string.format([[<IMG SRC="%s" />]], img) end
    -- energy_required seems to refer to the time it needs (clock icon)
    if energy ~= nil then energy_tag = string.format([[<TD><IMG SRC="%s" /></TD><TD>%g</TD>]], clock_icon, energy) end
    return trim(string.format([[
    <
    <TABLE BORDER="0" CELLBORDER="0" CELLSPACING="0">
        <TR><TD>%s</TD><TD>%s</TD>%s</TR>        
    </TABLE>
    >
    ]], img_tag, name or "nil", energy_tag))
end

function GetIcon(tbl)
    -- Try and find an icon for the recipe/ingredient/result in tbl.
    if tbl == nil then return nil end
    if tbl.icon ~= nil then return tbl.icon:gsub("__base__", FACTORIO_ROOT.."data/base") end
    png_path = FACTORIO_ROOT.."data/base/graphics/icons/"..tbl.name..".png"
    if file_exists(png_path) then return png_path end
    -- Not found? Try the fluid folder
    png_path = FACTORIO_ROOT.."data/base/graphics/icons/fluid/"..tbl.name..".png"
    if file_exists(png_path) then return png_path end
    io.stderr:write('Icon not found for ', tbl.name, " at ", png_path, "\n")
    return nil
end
