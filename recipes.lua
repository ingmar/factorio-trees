-- Factorio recipe tree

require "utils"


-- Recipes to load
RECIPE_FILES = {
    "ammo.lua",
    "capsule.lua",
    "demo-furnace-recipe.lua",
    "demo-recipe.lua",
    "demo-turret.lua",
    "equipment.lua",
    "fluid-recipe.lua",
    "furnace-recipe.lua",
    "inserter.lua",
    "module.lua",
    "recipe.lua",
    "turret.lua",
}
-- Which string translation sections to use (now always in base.cfg)
LANGUAGE_SECTIONS = {
    ["item-name"] = true,
    ["entity-name"] = true,
    ["fluid-name"] = true,
    ["equipment-name"] = true,
}
-- Recipes to exclude from graph
RECIPE_EXCLUDE = {
    -- Recipes that have better alternatives
    ["basic-armor"] = true,
    ["basic-bullet-magazine"] = true,
    ["heavy-armor"] = true,
    ["iron-axe"] = true,
    ["iron-chest"] = true,
    ["shotgun"] = true,
    ["shotgun-shell"] = true,
    ["small-electric-pole"] = true,
    ["wooden-chest"] = true,
    ["power-armor"] = true,
    ["basic-modular-armor"] = true,

    -- Outdated tech
    ["burner-mining-drill"] = true,
    ["pistol"] = true,
    ["steel-furnace"] = true,
    ["stone-furnace"] = true,
    
    -- Unknown Use
    ["player-port"] = true,
    ["railgun-dart"] = true,
    ["railgun"] = true,
    ["small-plane"] = true,
    
    -- Filter away for factory plan
    ["wood"] = true,
    ["combat-shotgun"] = true,
    ["basic-oil-processing"] = true,
    ["fill-crude-oil-barrel"] = true,
    ["iron-plate"] = true,
    ["copper-plate"] = true,
    ["flame-thrower-ammo"] = true,
    ["steel-axe"] = true,
    ["storage-tank"] = true,
    ["boiler"] = true,
    ["cargo-wagon"] = true,
    ["steel-chest"] = true,
    ["oil-refinery"] = true,
    ["flame-thrower"] = true,
    ["chemical-plant"] = true,
    ["small-lamp"] = true,
    ["steam-engine"] = true,
    ["pumpjack"] = true,
    ["train-stop"] = true,
    ["offshore-pump"] = true,
    ["combat-shotgun"] = true,
    ["rocket-launcher"] = true,
    ["basic-mining-drill"] = true,
    ["radar"] = true,
    ["submachine-gun"] = true,
    ["assembling-machine-1"] = true,
    ["gun-turret"] = true,
    ["basic-electric-discharge-defense-remote"] = true,
    ["green-wire"] = true,
    ["red-wire"] = true,
    ["rail-signal"] = true,
    ["car"] = true,
    ["basic-transport-belt-to-ground"] = true,
    ["diesel-locomotive"] = true,
    ["smart-chest"] = true,
    ["lab"] = true,
    ["basic-splitter"] = true,
    ["assembling-machine-2"] = true,
    ["land-mine"] = true,
    ["electric-furnace"] = true,
    ["fast-transport-belt-to-ground"] = true,
    ["roboport"] = true,
    --["substation"] = true,
    ["basic-beacon"] = true,
    ["energy-shield-equipment"] = true,
    ["deconstruction-planner"] = true,
    ["blueprint"] = true,
    ["night-vision-equipment"] = true,
    ["logistic-chest-requester"] = true,
    ["logistic-chest-storage"] = true,
    ["logistic-chest-active-provider"] = true,
    ["logistic-chest-passive-provider"] = true,
    ["fast-splitter"] = true,
    ["small-pump"] = true,
    ["basic-exoskeleton-equipment"] = true,
    ["solar-panel-equipment"] = true,
    ["express-transport-belt-to-ground"] = true,
    ["energy-shield-mk2-equipment"] = true,
    ["express-splitter"] = true,
    ["battery-equipment"] = true,
    ["assembling-machine-3"] = true,
    ["fusion-reactor-equipment"] = true,
    ["battery-mk2-equipment"] = true,
    ["basic-laser-defense-equipment"] = true,
    ["basic-electric-discharge-defense-equipment"] = true,
    ["power-armor-mk2"] = true,
    ["rocket-defense"] = true,
    ["arithmetic-combinator"] = true,
    ["decider-combinator"] = true,
    ["constant-combinator"] = true,
    ["arithmetic-combinator"] = true,
    ["arithmetic-combinator"] = true,
    ["arithmetic-combinator"] = true,
    ["arithmetic-combinator"] = true,
}

-- Ingredients that are basic resources
RESOURCES = {
    ["copper-ore"] = true,
    ["crude-oil"] = true,
    ["iron-ore"] = true,
    ["stone"] = true,
    ["raw-wood"] = true,
    ["water"] = true,
}

-- Try and map recipe categories to the (minimum) type of crafting station needed
CATEGORY_LABEL = {
    default = Img(FACTORIO_ROOT.."data/base/graphics/icons/assembling-machine-1.png"),
    crafting = Img(FACTORIO_ROOT.."data/base/graphics/icons/assembling-machine-1.png"),
    ["crafting-with-fluid"] = Img(FACTORIO_ROOT.."data/base/graphics/icons/assembling-machine-2.png"),
    ["advanced-crafting"] = Img(FACTORIO_ROOT.."data/base/graphics/icons/assembling-machine-2.png"),
    smelting = Img(FACTORIO_ROOT.."data/base/graphics/icons/stone-furnace.png"),
    ["oil-processing"] = Img(FACTORIO_ROOT.."data/base/graphics/icons/oil-refinery.png"),
    chemistry = Img(FACTORIO_ROOT.."data/base/graphics/icons/chemical-plant.png"),
}


load_data(RECIPE_FILES, "data/base/prototypes/recipe/")
load_translations(LANGUAGE_SECTIONS)


-- Graphviz output
print('strict digraph factorio {')
-- Change rankdir to LR or TB to change direction of graph
print('layout=dot; splines=polyline; rankdir=LR; color="#ffffff"; bgcolor="#332200"; ratio=auto; ranksep=2.0; nodesep=0.15;')
-- Node default attributes
node_default = {}
node_default.color = '"#e4e4e4"'
node_default.fontname = '"TitilliumWeb-SemiBold"'
node_default.fontcolor = '"#ffffff"'
node_default.shape = 'box'
node_default.style = 'filled'
print(string.format('node [%s]', VizAttr(node_default)))
-- Edge default attributes
edge_default = {}
edge_default.penwidth = 2
edge_default.color = '"#DDDD22"'
edge_default.fontname = node_default.fontname
edge_default.fontcolor = node_default.fontcolor
print(string.format('edge [%s]', VizAttr(edge_default)))

-- Raw resources go on the top/leftmost rank on their own
print('{ rank=source;')
for res in pairs(RESOURCES) do
    print(string.format('"%s";', res))
end
print('}')

for id, recipe in pairs(data) do
    -- First do a few sanity checks
    if recipe.type ~= "recipe" then
        io.stderr:write(string.format('Found unknown type "%s" instead of "recipe" for %s', recipe.type, recipe.name), "\n")
        os.exit(1)
    end
    if recipe.enabled ~= "false" then
        print("// ENABLED:", recipe.name)    -- Initially unlocked recipes?
    end
    
    if not FILTER or (FILTER and not RECIPE_EXCLUDE[recipe.name]) then
        -- Recipe has .result data, convert to new .results format for easier handling
        if recipe.result ~= nil then    
            recipe.results = {{name = recipe.result, amount = recipe.result_count}}
        end
    
        -- Define the recipe node first
        attr = {}
        -- If energy_required isn't specified, it defaults to 0.5
        if recipe.energy_required == nil then recipe.energy_required = 0.5 end
        attr.label = HtmlLabel(CATEGORY_LABEL[recipe.category or 'default'], nil, recipe.energy_required)
        attr.tooltip = string.format('"%s"', recipe.name) -- Put the untranslated name into the tooltip
        attr.fillcolor = '"#6d7235"'
        attr.color = attr.fillcolor
        attr.shape = "cds"
        print(string.format('"Recipe: %s" [%s];', recipe.name, VizAttr(attr)))
    
        -- Make edges from each ingredient to the recipe
        print(string.format("  // Ingredients"))
        for ing_id, ing in pairs(recipe.ingredients) do
            -- Convert old array syntax into new descriptive one
            if ing.type == nil then
                ing.name = ing[1]
                ing.amount = ing[2]
            end

            -- Define ingredient node
            attr = {}
            attr.label = HtmlLabel(T(ing.name), GetIcon(ing))
            if ing.type == "fluid" then
                attr.shape = "ellipse"
                attr.fillcolor = '"#3d3c6e"'
            else
                attr.fillcolor = '"#8f8f90"'
            end
            attr.color = attr.fillcolor
            print(string.format('"%s" [%s];', ing.name, VizAttr(attr)))

            -- Ingredient -> Recipe edge
            attr = {}
            attr.label = string.format('"x%d"', ing.amount)
            if ing.type == "fluid" then
                attr.color = '"#45A7F3"'
            elseif ing.name == "copper-plate" then
                attr.color = '"#C77362"'
            elseif ing.name == "iron-plate" then
                attr.color = '"#838588"'
            elseif ing.name == "steel-plate" then
                attr.color = '"#96ff8B"'
            else
                attr.color = edge_default.color
            end
            -- For raw resources, set fixed rank
            if RESOURCES[ing.name] ~= nil then
                attr.rank="source"
            end
            print(string.format('  "%s" -> "Recipe: %s" [%s];', ing.name, recipe.name, VizAttr(attr)))
        end
    
        -- And from the recipe to each result
        print("  // Results")
        for res_id, res in pairs(recipe.results) do
            -- Define result node
            attr = {}
            attr.label = HtmlLabel(T(res.name), GetIcon(res))
            if res.type == "fluid" then
                attr.fillcolor = '"#3d3c6e"'
            else
                attr.fillcolor = '"#8f8f90"'
            end
            attr.color = attr.fillcolor
            print(string.format('"%s" [%s];', res.name, VizAttr(attr)))
        
            -- Recipe -> Result edge
            attr = {}
            attr.weight = 100  -- Shorten result edges so results are close to recipe/factory
            attr.label = string.format('x%d', res.amount or 1)
            if res.type == "fluid" then
                attr.color = '"#9999ff"'
            else
                attr.color = edge_default.color
            end
            print(string.format('  "Recipe: %s" -> "%s" [%s];', recipe.name, res.name, VizAttr(attr)))
        end
        print("")
    end
end
print("}") -- Done!
