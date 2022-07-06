local function OffsetCoords(pos, heading, distance)
    heading = math.rad((heading - 180) * -1)
    return v3(pos.x + (math.sin(heading) * -distance), pos.y + (math.cos(heading) * -distance), pos.z)
end  -- function codenz by proddy

local function reqCtrl(ent)
    local check_time = utils.time_ms() + 1000
    network.request_control_of_entity(ent)
    while not network.has_control_of_entity(ent) and entity.is_an_entity(ent) and check_time > utils.time_ms() do
        system.yield(0)
    end
    return network.has_control_of_entity(ent)
end

local function reqHash(hash)
    streaming.request_model(hash)
    while (not streaming.has_model_loaded(hash)) do
        system.wait(0)
    end
    return hash
end

gmremover = {}
gmremover.parent = menu.add_player_feature("Godmode Removal", "parent", 0).id
gmremover.hashes = {782665360,562680400,2859440138}
gmremover.kill = menu.add_player_feature("Kill Player", "action", gmremover.parent, function(f, pid)
    local gmvehicles = {}

    gmremoveron = menu.get_player_feature(gmremover.remove.id).feats[pid].on
    if not gremoveron then
        menu.get_player_feature(gmremover.remove.id).feats[pid].on = true
    end

    ped.clear_ped_tasks_immediately(player.get_player_ped(pid))

    gmremover.playerpos = player.get_player_coords(pid)
    gmremover.playerpos.z = gmremover.playerpos.z + 4.5

    gmvehicles[1] = vehicle.create_vehicle(reqHash(782665360), gmremover.playerpos, player.get_player_heading(pid), true, false)
    for i=1,3 do
        gmvehicles[#gmvehicles+1] = vehicle.create_vehicle(reqHash(gmremover.hashes[i]), gmremover.playerpos, 0.0, true, false)
    end

    for i=1,4 do
        reqCtrl(player.get_player_vehicle(gmvehicles[i]))
    end

    entity.attach_entity_to_entity(gmvehicles[2], gmvehicles[1], 0, v3(0, 3, 0), v3(0, 0, -180), false, true, false, 0, true)
    entity.attach_entity_to_entity(gmvehicles[3], gmvehicles[1], 0, v3(3, 3, 0), v3(0, 0, -180), false, true, false, 0, true)
    entity.attach_entity_to_entity(gmvehicles[4], gmvehicles[1], 0, v3(3, 0, 0), v3(0, 0, 0), false, true, false, 0, true)
    entity.apply_force_to_entity(gmvehicles[1], 1, 0, 0, -10, 0, 0, 0, true, true)
    entity.set_entity_visible(gmvehicles[1], false)
    fire.add_explosion(gmremover.playerpos, 8, false, true,0, pid)
    system.yield(7500)
    for i=1,4 do
        reqCtrl(gmvehicles[i])
        entity.delete_entity(gmvehicles[i])
    end
    menu.get_player_feature(gmremover.remove.id).feats[pid].on = gmremoveron
end)

gmremover.remove = menu.add_player_feature("Remove Godmode", "toggle", gmremover.parent, function(f, pid)
    while f.on and player.is_player_valid(pid) do
        script.trigger_script_event(801199324, pid, {pid, 869796886})
        system.yield()
    end
end)