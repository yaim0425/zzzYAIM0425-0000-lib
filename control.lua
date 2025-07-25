---------------------------------------------------------------------------------------------------
---> control.lua <---
---------------------------------------------------------------------------------------------------

--- Validar si se cargó antes
if GPrefix and GPrefix.name then return end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Cargar las funciones y constantes <---
---------------------------------------------------------------------------------------------------

require("__CONSTANTS__")
require("__FUNCTIONS__")
require("util")

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Funciones globales <---
---------------------------------------------------------------------------------------------------

--- Crea un consolidado de variables para usar en tiempo de ejecuión
--- @param event table
--- @param that_mod table
--- @return table
function GPrefix.create_data(event, that_mod)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Variable de salida
    local Data = { Event = event }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Entidad en el evento
    if event.entity and event.entity.valid then
        Data.Entity = event.entity
    elseif event.created_entity and event.created_entity.valid then
        Data.Entity = event.created_entity
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Identificar al jugador
    if event.player_index then
        Data.Player = game.get_player(event.player_index)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Buscar y crear los forces
    for Key, Value in pairs({ player = Data.Player, entity = Data.Entity }) do
        --- Agregar prefijo
        Key = "Force_" .. Key

        --- Cargar el force de forma directa
        if not GPrefix.is_string(Value.force) then
            Data[Key] = Value.force
        end

        --- Cargar el force usando el nombre o id
        if GPrefix.is_string(Value.force) then
            Data[Key] = game.forces[Value.force]
        end
    end

    --- Reducir los forces a uno de ser posible
    if Data.Force_player == Data.Force_entity then
        Data.Force = Data.Force_entity
        Data.Force_entity = nil
        Data.Force_player = nil
    elseif not Data.Force_player and Data.Force_entity then
        Data.Force = Data.Force_entity
        Data.Force_entity = nil
    elseif Data.Force_player and not Data.Force_entity then
        Data.Force = Data.Force_player
        Data.Force_player = nil
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Espacio guardable para TODOS los MODs
    storage[GPrefix.name] = storage[GPrefix.name] or {}
    Data.gPrefix = storage[GPrefix.name]

    --- Espacio guardable para este MOD
    Data.gPrefix[that_mod.id] = Data.gPrefix[that_mod.id] or {}
    Data.gMOD = Data.gPrefix[that_mod.id]

    --- Crear el espacio guardable para los forces
    Data.gMOD.Forces = Data.gMOD.Forces or {}
    Data.gForces = Data.gMOD.Forces

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear el espacio NO guardable para los forces
    that_mod.Forces = that_mod.Forces or {}
    Data.GForces = that_mod.Forces

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear el espacio para un forces
    for _, force in pairs({ Data.Force_player, Data.Force_entity, Data.Force }) do
        --- Espacio guardable
        Data.gForce = Data.gForces
        Data.gForce[force.index] = Data.gForce[force.index] or {}
        Data.gForce = Data.gForce[force.index]

        --- Espacio NO guardable
        Data.GForce = Data.GForces
        Data.GForce[force.index] = Data.GForce[force.index] or {}
        Data.GForce = Data.GForce[force.index]
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Espacio NO guardable para los jugadores
    that_mod.Players = that_mod.Players or {}
    Data.GPlayers = that_mod.Players

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Espacio guardable para los jugadores
    Data.gMOD.Players = Data.gMOD.Players or {}
    Data.gPlayers = Data.gMOD.Players

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- No se tiene un jugador
    if not Data.Player then return Data end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Identificador del jugador
    local ID_Player = Data.Player.index

    --- Espacio NO guardable del jugador
    Data.GPlayers[ID_Player] = Data.GPlayers[ID_Player] or {}
    Data.GPlayer = Data.GPlayers[ID_Player]

    --- Espacio para el GUI
    Data.GPlayer.GUI = Data.GPlayer.GUI or {}
    Data.GUI = Data.GPlayer.GUI

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Espacio guardable del jugador
    Data.gPlayers[ID_Player] = Data.gPlayers[ID_Player] or {}
    Data.gPlayer = Data.gPlayers[ID_Player]

    --- Devolver el consolidado de los datos
    return Data

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Funciones internas <---
---------------------------------------------------------------------------------------------------

--- Contenedor de funciones y datos usados
--- unicamente en este archivo
local This_MOD = {}

--- Ejecutar las acciones propias de este archivo
function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Clasificar la información de data.raw
    --- Crearción de:
    --- GPrefix.Items
    --- GPrefix.Tiles
    --- GPrefix.Fluids
    --- GPrefix.Recipes
    --- GPrefix.Entities
    --- GPrefix.Equipments
    This_MOD.filter_data()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

--- Clasificar la información de data.raw
--- Crearción de:
--- GPrefix.items
--- GPrefix.tiles
--- GPrefix.fluids
--- GPrefix.recipes
--- GPrefix.entities
--- GPrefix.equipments
function This_MOD.filter_data()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Agregar el suelo a GPrefix.Tiles
    local function addTitle(tile)
        local results = tile.mineable_properties.products
        if not results then return end

        for _, result in pairs(results) do
            GPrefix.tiles[result.name] = GPrefix.tiles[result.name] or {}
            table.insert(GPrefix.tiles[result.name], tile)
        end
    end

    --- Agregar la receta a GPrefix.recipes
    local function addRecipe(recipe)
        local results = recipe.products
        if not results then return end

        for _, result in pairs(results) do
            GPrefix.recipes[result.name] = GPrefix.tiles[result.name] or {}
            table.insert(GPrefix.recipes[result.name], recipe)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Renombrar las variables
    GPrefix.items = prototypes.item
    GPrefix.fluids = prototypes.fluid
    GPrefix.entities = prototypes.entity
    GPrefix.equipments = prototypes.equipment

    --- Agrupar los suelos
    GPrefix.tiles = {}
    for _, tile in pairs(prototypes.tile) do
        addTitle(tile)
    end

    --- Agrupar las recetas
    GPrefix.recipes = {}
    for _, recipe in pairs(prototypes.recipe) do
        addRecipe(recipe)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Ejecutar las funciones internas <---
---------------------------------------------------------------------------------------------------

--- Ejecutar las acciones propias de este archivo
This_MOD.start()

---------------------------------------------------------------------------------------------------
