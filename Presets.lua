local addonName, addonTable = ...
local GatherTracker = addonTable.GatherTracker or _G["GatherTracker"]

GatherTracker.Presets = {
    {
        name = "Profesiones: Ingeniería (1-300)",
        id = "PRESET_CAT_ENG",
        sub = {
            {
                name = "Apprentice (1-75)",
                id = "PRESET_ENG_APPRENTICE",
                items = {
                    { id = 2770, count = 60 }, -- Mena de cobre
                    { id = 2835, count = 40 }, -- Piedra tosca
                }
            },
            {
                name = "Journeyman (75-150)",
                id = "PRESET_ENG_JOURNEYMAN",
                items = {
                    { id = 2770, count = 20 }, -- Mena de cobre
                    { id = 2771, count = 40 }, -- Mena de estaño
                    { id = 2836, count = 40 }, -- Piedra burda
                    { id = 2592, count = 20 }, -- Paño de lana
                }
            },
            {
                name = "Expert (150-225)",
                id = "PRESET_ENG_EXPERT",
                items = {
                    { id = 2772, count = 80 }, -- Mena de hierro
                    { id = 2776, count = 20 }, -- Mena de oro
                    { id = 2775, count = 10 }, -- Mena de plata
                    { id = 7912, count = 20 }, -- Piedra sólida
                    { id = 2838, count = 40 }, -- Piedra pesada
                    { id = 4306, count = 20 }, -- Paño de seda
                }
            },
            {
                name = "Artisan (225-300)",
                id = "PRESET_ENG_ARTISAN",
                items = {
                    { id = 3858, count = 150 }, -- Mena de mitril
                    { id = 10620, count = 100 }, -- Mena de torio
                    { id = 12365, count = 20 }, -- Piedra densa
                    { id = 4338, count = 40 }, -- Paño de tejido mágico
                    { id = 14047, count = 20 }, -- Paño rúnico
                }
            }
        }
    },
    {
        name = "Alquimia: Ingredientes (Para Farmear)",
        id = "PRESET_CAT_ALCH_FARM",
        sub = {
            {
                name = "Pack: 20x Elixir de Mangosta",
                id = "PRESET_ALCH_FARM_MONGOOSE",
                items = {
                    { id = 13465, count = 40 }, -- Salvia de montaña
                    { id = 13466, count = 40 }, -- Flor de peste
                    { id = 3371,  count = 20 }, -- Vial de cristal
                }
            },
            {
                name = "Pack: 20x Poder Arcano Mayor",
                id = "PRESET_ALCH_FARM_ARCANE",
                items = {
                    { id = 13464, count = 60 }, -- Hoja de sueño
                    { id = 8831,  count = 20 }, -- Loto cárdeno
                    { id = 3371,  count = 20 }, -- Vial de cristal
                }
            },
            {
                name = "Pack: 20x Poder de Fuego Superior",
                id = "PRESET_ALCH_FARM_FIREPOWER",
                items = {
                    { id = 4625,  count = 60 }, -- Carolina
                    { id = 13464, count = 20 }, -- Hoja de sueño
                    { id = 3371,  count = 20 }, -- Vial de cristal
                }
            },
            {
                name = "Pack: 20x Sanación/Maná Mayor",
                id = "PRESET_ALCH_FARM_HEAL_MANA",
                items = {
                    { id = 13463, count = 40 }, -- Sansam dorado
                    { id = 13465, count = 20 }, -- Salvia de montaña (para sanación)
                    { id = 13464, count = 40 }, -- Hoja de sueño (para maná)
                    { id = 13467, count = 20 }, -- Capuchina (para maná)
                    { id = 3371,  count = 40 }, -- Vial de cristal
                }
            },
            {
                name = "Pack: 1x Frasco de Titán",
                id = "PRESET_ALCH_FARM_TITAN",
                items = {
                    { id = 13468, count = 1 },  -- Loto negro
                    { id = 13465, count = 30 }, -- Salvia de montaña
                    { id = 13463, count = 10 }, -- Sansam dorado
                    { id = 18256, count = 1 },  -- Vial imbuido
                }
            }
        }
    },
    {
        name = "Alquimia: Consumibles (Raid/PvP)",
        id = "PRESET_CAT_ALCH_CONSUM",
        sub = {
            {
                name = "Melee Prep (Physical)",
                id = "PRESET_ALCH_CONSUM_MELEE",
                items = {
                    { id = 13451, count = 20 }, -- Elixir de mangosta (Mongoose)
                    { id = 9206, count = 20 },  -- Elixir de gigantes (Giants)
                    { id = 13446, count = 40 }, -- Poción de sanación mayor
                    { id = 5634, count = 10 },  -- Poción de acción libre
                }
            },
            {
                name = "Caster Prep (Magic)",
                id = "PRESET_ALCH_CONSUM_CASTER",
                items = {
                    { id = 13454, count = 20 }, -- Elixir de poder arcano superior
                    { id = 13444, count = 40 }, -- Poción de maná mayor
                    { id = 21546, count = 20 }, -- Elixir de potencia de fuego superior
                    { id = 9264, count = 20 },  -- Elixir de poder de las sombras
                }
            },
            {
                name = "Tank Prep (Survival)",
                id = "PRESET_ALCH_CONSUM_TANK",
                items = {
                    { id = 8951, count = 20 },  -- Elixir de defensa superior
                    { id = 13452, count = 20 }, -- Elixir de agilidad superior
                    { id = 13446, count = 40 }, -- Poción de sanación mayor
                    { id = 13510, count = 5 },  -- Frasco de titán
                }
            },
            {
                name = "Protecciones (Resistances)",
                id = "PRESET_ALCH_CONSUM_PROT",
                items = {
                    { id = 6048, count = 20 },  -- Prot. Fuego
                    { id = 6052, count = 20 },  -- Prot. Naturaleza
                    { id = 6050, count = 20 },  -- Prot. Escarcha
                    { id = 13462, count = 10 }, -- Purificación
                }
            }
        }
    },
    {
        name = "Profesiones: Alquimia (1-300)",
        id = "PRESET_CAT_ALCH_GRL",
        sub = {
            {
                name = "Apprentice (1-60)",
                id = "PRESET_ALCH_GRL_APPRENTICE",
                items = {
                    { id = 2447, count = 60 }, -- Flor de paz
                    { id = 765,  count = 60 }, -- Hojaplata
                    { id = 3371, count = 60 }, -- Vial de cristal
                }
            },
            {
                name = "Journeyman (60-150)",
                id = "PRESET_ALCH_GRL_JOURNEYMAN",
                items = {
                    { id = 2449, count = 40 }, -- Raíz de tierra
                    { id = 785,  count = 40 }, -- Marregal
                    { id = 2453, count = 20 }, -- Cardo veloz
                    { id = 2450, count = 30 }, -- Brezospina
                }
            },
            {
                name = "Expert (150-225)",
                id = "PRESET_ALCH_GRL_EXPERT",
                items = {
                    { id = 3820, count = 20 }, -- Sangrerregia
                    { id = 3355, count = 20 }, -- Vidarraíz
                    { id = 3356, count = 20 }, -- Hierba cardenal
                    { id = 3818, count = 20 }, -- Hojasangre
                    { id = 3369, count = 10 }, -- Tumbamusgo
                }
            },
            {
                name = "Artisan (225-300)",
                id = "PRESET_ALCH_GRL_ARTISAN",
                items = {
                    { id = 8831, count = 40 }, -- Sansam dorado
                    { id = 8839, count = 20 }, -- Clavelespectro
                    { id = 8838, count = 20 }, -- Solea
                    { id = 13464, count = 30 }, -- Hoja de sueño
                    { id = 13463, count = 30 }, -- Claverreal
                }
            }
        }
    },
    {
        name = "Profesiones: Herrería (1-300)",
        id = "PRESET_CAT_SMITH",
        sub = {
            {
                name = "Apprentice (1-75)",
                id = "PRESET_SMITH_APPRENTICE",
                items = {
                    { id = 2770, count = 80 }, -- Mena de cobre
                    { id = 2835, count = 20 }, -- Piedra tosca
                }
            },
            {
                name = "Journeyman (75-125)",
                id = "PRESET_SMITH_JOURNEYMAN",
                items = {
                    { id = 2770, count = 100 }, -- Mena de cobre (Bronze)
                    { id = 2771, count = 100 }, -- Mena de estaño
                    { id = 2836, count = 40 }, -- Piedra burda
                }
            },
            {
                name = "Expert (125-225)",
                id = "PRESET_SMITH_EXPERT",
                items = {
                    { id = 2772, count = 120 }, -- Mena de hierro
                    { id = 2776, count = 20 }, -- Mena de oro
                    { id = 2838, count = 60 }, -- Piedra pesada
                    { id = 3858, count = 80 }, -- Mena de mitril
                }
            },
            {
                name = "Artisan (225-300)",
                id = "PRESET_SMITH_ARTISAN",
                items = {
                    { id = 3858, count = 200 }, -- Mena de mitril
                    { id = 10620, count = 300 }, -- Mena de torio
                    { id = 12365, count = 50 }, -- Piedra densa
                }
            }
        }
    },
    {
        name = "Kits de Farm (Rutas)",
        id = "PRESET_CAT_FARMS",
        sub = {
            {
                name = "Starter: Cobre & Estaño",
                id = "PRESET_FARM_STARTER",
                items = {
                    { id = 2770, count = 100 }, -- Cobre
                    { id = 2771, count = 50  }, -- Estaño
                    { id = 774,  count = 5   }, -- Malaquita
                    { id = 818,  count = 5   }, -- Ojo de tigre
                }
            },
            {
                name = "Mid: Hierro & Mitril",
                id = "PRESET_FARM_MID",
                items = {
                    { id = 2772, count = 100 }, -- Hierro
                    { id = 3858, count = 100 }, -- Mitril
                    { id = 2776, count = 10 }, -- Oro
                    { id = 7912, count = 20 }, -- Piedra sólida
                }
            },
            {
                name = "High: Torio & Arcano",
                id = "PRESET_FARM_HIGH_THORIUM",
                items = {
                    { id = 10620, count = 200 }, -- Torio
                    { id = 12363, count = 10 }, -- Cristal Arcano
                    { id = 12365, count = 40 }, -- Piedra densa
                }
            },
            {
                name = "High: Plaguebloom & Dreamfoil",
                id = "PRESET_FARM_HIGH_HERBS",
                items = {
                    { id = 13466, count = 50 }, -- Flor de peste
                    { id = 13464, count = 50 }, -- Hoja de sueño
                    { id = 13465, count = 30 }, -- Salvia de montaña
                }
            }
        }
    },
    {
        name = "Aventurero / Utiles",
        id = "PRESET_CAT_UTIL",
        sub = {
            {
                name = "Primeros Auxilios (1-300)",
                id = "PRESET_UTIL_FIRSTAID",
                items = {
                    { id = 2589, count = 100 }, -- Lino
                    { id = 2592, count = 100 }, -- Lana
                    { id = 4306, count = 100 }, -- Seda
                    { id = 4338, count = 100 }, -- Mageweave
                    { id = 14047, count = 80 }, -- Rúnico
                }
            },
            {
                name = "Cocina: Supervivencia",
                id = "PRESET_UTIL_COOKING",
                items = {
                    { id = 769,  count = 20 }, -- Carne de jabalí
                    { id = 2672, count = 20 }, -- Carne de lobo
                    { id = 12209, count = 20 }, -- Carne de oso
                    { id = 12223, count = 20 }, -- Carne de araña
                }
            },
            {
                name = "Pícaro: Venenos y Té",
                id = "PRESET_UTIL_ROGUE",
                items = {
                    { id = 2453, count = 20 }, -- Cardo veloz
                    { id = 3818, count = 10 }, -- Hojasangre
                    { id = 8926, count = 20 }, -- Vial vacío
                }
            }
        }
    }
}

-- Mapeo interno de nombres comunes (Español/Inglés) a IDs para evitar problemas de cache
GatherTracker.ItemLookup = {
    -- METALES / BARS
    ["lingote de cobre"] = 2840, ["copper bar"] = 2840,
    ["lingote de bronce"] = 2841, ["bronze bar"] = 2841,
    ["lingote de estaño"] = 3576, ["tin bar"] = 3576,
    ["lingote de hierro"] = 3575, ["iron bar"] = 3575,
    ["lingote de plata"] = 2842, ["silver bar"] = 2842,
    ["lingote de oro"] = 3577, ["gold bar"] = 3577,
    ["lingote de acero"] = 3859, ["steel bar"] = 3859,
    ["lingote de mitril"] = 3860, ["mithril bar"] = 3860,
    ["lingote de torio"] = 12359, ["thorium bar"] = 12359,
    ["lingote de arcanita"] = 12360, ["arcanite bar"] = 12360,
    ["lingote de veraplata"] = 6037, ["truesilver bar"] = 6037,
    ["lingote de hierro negro"] = 11371, ["dark iron bar"] = 11371,

    -- MENAS / ORES
    ["mena de cobre"] = 2770, ["copper ore"] = 2770,
    ["mena de estaño"] = 2771, ["tin ore"] = 2771,
    ["mena de hierro"] = 2772, ["iron ore"] = 2772,
    ["mena de mitril"] = 3858, ["mithril ore"] = 3858,
    ["mena de torio"] = 10620, ["thorium ore"] = 10620,
    ["mena de plata"] = 2775, ["silver ore"] = 2775,
    ["mena de oro"] = 2776, ["gold ore"] = 2776,
    ["mena de veraplata"] = 7911, ["truesilver ore"] = 7911,
    ["mena de hierro negro"] = 11370, ["dark iron ore"] = 11370,
    ["cristal arcano"] = 12363, ["arcane crystal"] = 12363,

    -- HIERBAS / HERBS (Vanilla Complete)
    ["flor de paz"] = 2447, ["peacebloom"] = 2447,
    ["hojaplata"] = 765, ["silverleaf"] = 765,
    ["raíz de tierra"] = 2449, ["earthroot"] = 2449,
    ["marregal"] = 785, ["mageroyal"] = 785,
    ["brezospina"] = 2450, ["briarthorn"] = 2450,
    ["hierba cardenal"] = 3356, ["bruiseweed"] = 3356,
    ["alga estranguladora"] = 3821, ["stranglekelp"] = 3821,
    ["vidarraíz"] = 3355, ["liferoot"] = 3355,
    ["sangrerregia"] = 3820, ["kingsblood"] = 3820,
    ["hojasangre"] = 3818, ["fadeleaf"] = 3818,
    ["espina de oro"] = 3357, ["goldthorn"] = 3357,
    ["tumbamusgo"] = 3369, ["grave moss"] = 3369,
    ["mostacho de khadgar"] = 3358, ["khadgar's whisker"] = 3358,
    ["espina de hielo"] = 8836, ["wintersbite"] = 8836,
    ["carolina"] = 4625, ["firebloom"] = 4625,
    ["loto cárdeno"] = 8831, ["purple lotus"] = 8831,
    ["hierba de artemisa"] = 8845, ["arthas' tears"] = 8845,
    ["solea"] = 8838, ["sungrass"] = 8838,
    ["clavelespectro"] = 8839, ["ghost mushroom"] = 8839,
    ["sansam dorado"] = 13463, ["golden sansam"] = 13463,
    ["hoja de sueño"] = 13464, ["dreamfoil"] = 13464,
    ["salvia de montaña"] = 13465, ["mountain silversage"] = 13465,
    ["flor de peste"] = 13466, ["plaguebloom"] = 13466,
    ["capuchina"] = 13467, ["icecap"] = 13467,
    ["loto negro"] = 13468, ["black lotus"] = 13468,
    ["cardo veloz"] = 2453, ["swiftthistle"] = 2453,

    -- CUEROS / LEATHER
    ["cuero ligero"] = 2318, ["light leather"] = 2318,
    ["cuero medio"] = 2319, ["medium leather"] = 2319,
    ["cuero pesado"] = 2320, ["heavy leather"] = 2320,
    ["cuero grueso"] = 2321, ["thick leather"] = 2321,
    ["cuero basto"] = 8170, ["rugged leather"] = 8170,
    ["pellejo ligero"] = 783, ["light hide"] = 783,
    ["pellejo medio"] = 2312, ["medium hide"] = 2312,
    ["pellejo pesado"] = 2314, ["heavy hide"] = 2314,
    ["pellejo grueso"] = 8169, ["thick hide"] = 8169,
    ["pellejo basto"] = 8171, ["rugged hide"] = 8171,

    -- PAÑOS / CLOTH
    ["paño de lino"] = 2589, ["linen cloth"] = 2589,
    ["paño de lana"] = 2592, ["wool cloth"] = 2592,
    ["paño de seda"] = 4306, ["silk cloth"] = 4306,
    ["paño de tejido mágico"] = 4338, ["mageweave cloth"] = 4338,
    ["paño rúnico"] = 14047, ["runecloth"] = 14047,
    ["paño de fieltro de sombra"] = 14256, ["felcloth"] = 14256,

    -- PIEDRAS / STONES
    ["piedra tosca"] = 2835, ["rough stone"] = 2835,
    ["piedra burda"] = 2836, ["coarse stone"] = 2836,
    ["piedra pesada"] = 2838, ["heavy stone"] = 2838,
    ["piedra sólida"] = 7912, ["solid stone"] = 7912,
    ["piedra densa"] = 12365, ["dense stone"] = 12365,

    -- ELEMENTALES / ESSENCES
    ["aire elemental"] = 7068, ["elemental air"] = 7068,
    ["fuego elemental"] = 7067, ["elemental fire"] = 7067,
    ["tierra elemental"] = 7069, ["elemental earth"] = 7069,
    ["agua elemental"] = 7070, ["elemental water"] = 7070,
    ["esencia de aire"] = 12803, ["essence of air"] = 12803,
    ["esencia de fuego"] = 12808, ["essence of fire"] = 12808,
    ["esencia de tierra"] = 12809, ["essence of earth"] = 12809,
    ["esencia de agua"] = 12804, ["essence of water"] = 12804,
    ["esencia de no-muerto"] = 12810, ["essence of undeath"] = 12810,

    -- GEMAS / GEMS
    ["malaquita"] = 774, ["malachite"] = 774,
    ["ojo de tigre"] = 818, ["tigerseye"] = 818,
    ["sombrita"] = 1206, ["shadowgem"] = 1206,
    ["ágata musgosa"] = 1209, ["moss agate"] = 1209,
    ["citrino"] = 3864, ["citrine"] = 3864,
    ["aguamarina"] = 7910, ["aquamarine"] = 7910,
    ["rubí estrella"] = 7909, ["star ruby"] = 7909,
    ["diamante de azeroth"] = 12361, ["azerothian diamond"] = 12361,
    ["zafiro azul"] = 12364, ["blue sapphire"] = 12364,
    ["esmeralda enorme"] = 12362, ["huge emerald"] = 12362,

    -- ALQUIMIA / VIALS & REAGENTS
    ["vial de cristal"] = 3371, ["crystal vial"] = 3371,
    ["vial vacío"] = 8926, ["empty vial"] = 8926,
    ["vial de plomo"] = 3372, ["leaded vial"] = 3372,
    ["vial imbuido"] = 18256, ["imbued vial"] = 18256,
    ["aceite de bocanegra"] = 6358, ["blackmouth oil"] = 6358,
    ["aceite de fuego"] = 6359, ["fire oil"] = 6359,

    -- POTIONS
    ["pocion de sanacion"] = 929, ["healing potion"] = 929,
    ["pocion de sanacion superior"] = 1710, ["greater healing potion"] = 1710,
    ["pocion de sanacion excelente"] = 3928, ["superior healing potion"] = 3928,
    ["pocion de sanacion mayor"] = 13446, ["major healing potion"] = 13446,
    ["pocion de maná"] = 3827, ["mana potion"] = 3827,
    ["pocion de maná superior"] = 6149, ["greater mana potion"] = 6149,
    ["pocion de maná excelente"] = 13443, ["superior mana potion"] = 13443,
    ["pocion de maná mayor"] = 13444, ["major mana potion"] = 13444,
    ["pocion de combatiente"] = 1711, ["swiftness potion"] = 1711,
    ["pocion de invisibilidad"] = 9172, ["invisibility potion"] = 9172,
    ["pocion de accion libre"] = 5634, ["free action potion"] = 5634,
    ["pocion de proteccion contra el fuego"] = 6048, ["fire protection potion"] = 6048,
    ["pocion de proteccion contra la naturaleza"] = 6052, ["nature protection potion"] = 6052,
    ["pocion de proteccion contra la escarcha"] = 6050, ["frost protection potion"] = 6050,
    ["pocion de purificacion"] = 13462, ["purification potion"] = 13462,

    -- ELIXIRS
    ["elixir de agilidad inferior"] = 3390, ["lesser agility elixir"] = 3390,
    ["elixir de agilidad"] = 8949, ["elixir of agility"] = 8949,
    ["elixir de agilidad superior"] = 13452, ["elixir of greater agility"] = 13452,
    ["elixir de defensa superior"] = 8951, ["elixir of superior defense"] = 8951,
    ["elixir de fuerza de gigante"] = 9206, ["elixir of giants"] = 9206,
    ["elixir de mangosta"] = 13451, ["elixir of the mongoose"] = 13451,
    ["elixir de poder arcano"] = 13454, ["elixir of greater arcane power"] = 13454,
    ["elixir de potencia de fuego"] = 21546, ["elixir of greater firepower"] = 21546,
    ["elixir de poder de las sombras"] = 9264, ["elixir of shadow power"] = 9264,
    ["elixir de sabiduria superior"] = 13445, ["elixir of greater wisdom"] = 13445,

    -- FLASKS
    ["frasco de poder de titán"] = 13510, ["flask of the titans"] = 13510,
    ["frasco de Sabiduría destilada"] = 13511, ["flask of distilled wisdom"] = 13511,
    ["frasco de Poder supremo"] = 13512, ["flask of supreme power"] = 13512,
    ["frasco de Resistencia cromática"] = 13513, ["flask of chromatic resistance"] = 13513,
}
