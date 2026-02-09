local vehicleFilterList = {
    -- --- EARLY / HORSE-DRAWN VEHICLES ---
    "horse_cart_as_1850.mdl", "american_horse_cart_stake_v2.mdl", "american_horse_cart_universal_v2.mdl",
    "horsewagon_1850_usa_v2.mdl", "horsewagon_1850_v2.mdl", "horse_cart_stake_v2.mdl",
    "horse_cart_universal_v2.mdl", "horse_carriage_v2.mdl",

    -- --- LOCOMOTIVES ---
    "borsig_1860_v2.mdl", "br89_v2.mdl", "br53_preus_g3_v2.mdl", "baldwin_class_56_v2.mdl", "heavy_mikado_v2.mdl",
    "milw_ep_2_v2.mdl", "m_300_v2.mdl", "alco_pa_front_v2.mdl", "emd_gp9_v2.mdl", "br_218_v2.mdl",
    "emd_sd40_v2.mdl", "br_185_traxx_v2.mdl",

    -- --- WAGONS (GOODS) ---
    "open_1850.mdl", "goods_1850_v2.mdl", "rungenwagen_1850.mdl", "kesselwagen_1860.mdl",
    "verbandswagen_v3.mdl", "kesselwagen_1910_v2.mdl", "boxcar_as_1900.mdl", "hbi1_v3.mdl",
    "open_1975.mdl", "kesselwagen_1950_v2.mdl",

    -- --- COACHES (PASSENGER) ---
    "d1_spanischb_v2.mdl", "wagen_bayrisch_1865_v2.mdl", "compartment_car_v2.mdl", "3axes_person_v2.mdl",
    "donnerbuechse_v2.mdl", "bc4_v2.mdl", "streamlined_santa_fe_v2.mdl", "ew_ii_v2.mdl", "ew_iv_v2.mdl", "bilevel_v2.mdl",

    -- --- SHIPS ---
    "rigi.mdl", "wilhelm_v2.mdl", "zoroaster_v4.mdl", "dunara_castle_v2.mdl", "frontenac_v2.mdl",
    "ds_schaffhausen_v2.mdl", "zurich_v2.mdl", "srn6_v2.mdl", "virgo_universal_v3.mdl", "virgo_tanker_v3.mdl",

    -- --- PLANES ---
    "junkers_f_13_v2.mdl", "dornier_b_merkur_v2.mdl", "douglas_dc3_v2.mdl", "douglas_dc4_v2.mdl",
    "super_connie_v2.mdl", "junkers_ju_52_v2.mdl", "boeing_737_v2.mdl", "boeing_737_700_v2.mdl",
    "airbus_a320_v2.mdl", "bombardier_q400_v2.mdl", "hercules_l100_v2.mdl",

    -- --- TRUCKS ---
    "benz1912_lkw_stake_v2.mdl", "steam_lorry_universal_v2.mdl", "mack_ac_universal_v2.mdl",
    "amo_f15_tanker_v2.mdl", "studebaker_us_universal_v2.mdl", "man_19_304_1970_universal_v2.mdl", "cascadia_2009_universal_v2.mdl",

    -- --- BUSES ---
    "landauer_v2.mdl", "dux_v2.mdl", "gaggenau_c40_v2.mdl", "aboag_v2.mdl",
    "saurer_tuescher_v2.mdl", "benz_o6600_v2.mdl", "maz_103_v2.mdl", "berkhof_duvedec_v2.mdl",
    "volvo_5000_v2.mdl", "wright_streetcar_rtv_v2.mdl",

    -- --- TRAMS (MOTORIZED ONLY) ---
    "st_petersburg_v2.mdl", "halle_v2.mdl", "san_diego_v2.mdl", "schst_v2.mdl",
    "peter_witt_streetcar_v2.mdl", "be4_6mirage_v2.mdl", "be5_6_v2.mdl",
}

local multipleUnitFilterList = {
    -- --- MULTIPLE UNITS (EMU/DMU) ---
    "shinkansen_0s.lua",
    "ice1.lua",
    "avelia_liberty.lua",
    "twindexx.lua",
    "es1_lastochka.lua",
    "russian_class_ed9m.lua",
}

function data()
    return {
        runFn = function (settings, modParams)
            -- Filter for individual vehicle models (.mdl files)
            addFileFilter("model/vehicle", function (fileName)
                -- Only filter base game files (not starter/deluxe or other mods)
                if fileName:match("^res/models/model/vehicle/") then -- Base game path
                    local baseFileName = fileName:match("([^/]+)$")
                    for _, filter in ipairs(vehicleFilterList) do
                        if baseFileName == filter then
                            return true -- Keep this base game vehicle
                        end
                    end
                    return false -- Exclude other base game vehicles
                end
                return true -- Allow all non-base game vehicles (from other mods)
            end)

            -- Filter for multiple unit definitions (.lua files that define the unit as a whole)
            addFileFilter("multipleUnit", function (fileName)
                -- Only filter base game multiple units
                if fileName:match("^res/config/multiple_unit/") then -- Base game path for multiple units
                    local baseFileName = fileName:match("([^/]+)$")
                    for _, filter in ipairs(multipleUnitFilterList) do
                        if baseFileName == filter then
                            return true -- Keep this base game multiple unit
                        end
                    end
                    return false -- Exclude other base game multiple units
                end
                return true -- Allow all non-base game multiple units (from other mods)
            end)
        end
    }
end

return M