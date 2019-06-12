-- TODO:
--  Define Quantum control block that creates circuit, etc.
--  Right click places circuit_gate
--  Make left click drop gate entity
--  Utilize is_gate boolean parameter of register_circuit_block function to
--      identify circuit blocks that are circuit gates
--  Remove circuit_gate group code

dofile(minetest.get_modpath("circuit_blocks").."/circuit_node_types.lua");

-- our API object
circuit_blocks = {}

-- returns circuit_blocks object or nil
function circuit_blocks:get_circuit_block(pos)
	local node_name = minetest.get_node(pos).name
	if minetest.registered_nodes[node_name] then
        -- Retrieve metadata
        local meta = minetest.get_meta(pos)
        local node_type = meta:get_int("node_type")
        local radians = meta:get_float("radians")
        local ctrl_a = meta:get_int("ctrl_a")
        local ctrl_b = meta:get_int("ctrl_b")

        -- 1 if node is a gate, 0 of node is not a gate
        local node_is_gate = meta:get_int("is_gate")

        -- Retrieve circuit_specs metadata
        local circuit_num_wires = meta:get_int("circuit_specs_num_wires")
        local circuit_num_columns = meta:get_int("circuit_specs_num_columns")
        local circuit_is_on_grid = meta:get_int("circuit_specs_is_on_grid")
        local circuit_pos_x = meta:get_int("circuit_specs_pos_x")
        local circuit_pos_y = meta:get_int("circuit_specs_pos_y")
        local circuit_pos_z = meta:get_int("circuit_specs_pos_z")

		return {
			pos = pos,

            -- Circuit node type, integer
            get_node_type = function()
				return node_type
			end,

            -- Rotation in radians, float
            get_radians = function()
				return radians
			end,

            -- Control wire A, integer
            get_ctrl_a = function()
				return ctrl_a
			end,

            -- Control wire B, integer
            get_ctrl_b = function()
				return ctrl_b
			end,

            -- Indicates whether node is a gate, boolean
            is_gate = function()
				return is_gate == 1
			end,

            --
            -- Number of circuit wires, integer
            get_circuit_num_wires = function()
				return circuit_num_wires
			end,

            -- Number of circuit columns, integer
            get_circuit_num_columns = function()
				return circuit_num_columns
			end,

            -- Indicates whether node is on the circuit grid, boolean
            is_on_circuit_grid = function()
				return circuit_is_on_grid == 1
			end,

            -- Position of lower-left node of the circuit grid
            get_circuit_pos = function()
                local ret_pos = {}
                ret_pos.x = circuit_pos_x
                ret_pos.y = circuit_pos_y
                ret_pos.z = circuit_pos_z
				return ret_pos
			end
		}
	else
		return nil
	end
end


function circuit_blocks:set_node_with_circuit_specs_meta(pos, node_name)
    -- Retrieve circuit_specs metadata
    local meta = minetest.get_meta(pos)
    local circuit_num_wires = meta:get_int("circuit_specs_num_wires")
    local circuit_num_columns = meta:get_int("circuit_specs_num_columns")
    local circuit_is_on_grid = meta:get_int("circuit_specs_is_on_grid")
    local circuit_pos_x = meta:get_int("circuit_specs_pos_x")
    local circuit_pos_y = meta:get_int("circuit_specs_pos_y")
    local circuit_pos_z = meta:get_int("circuit_specs_pos_z")

    minetest.set_node(pos, {name = node_name})

    -- Put circuit_specs metadata on placed node
    meta = minetest.get_meta(pos)
    meta:set_int("circuit_specs_num_wires", circuit_num_wires)
    meta:set_int("circuit_specs_num_columns", circuit_num_columns)
    meta:set_int("circuit_specs_is_on_grid", circuit_is_on_grid)
    meta:set_int("circuit_specs_pos_x", circuit_pos_x)
    meta:set_int("circuit_specs_pos_y", circuit_pos_y)
    meta:set_int("circuit_specs_pos_z", circuit_pos_z)


end


function circuit_blocks:toggle_control_qubit(pos)
    -- TODO: LEFT OFF HERE
    local meta = minetest.get_meta(pos)
    local circuit_num_wires = meta:get_int("circuit_specs_num_wires")
    local circuit_num_columns = meta:get_int("circuit_specs_num_columns")
    local circuit_is_on_grid = meta:get_int("circuit_specs_is_on_grid")
    local circuit_pos_x = meta:get_int("circuit_specs_pos_x")
    local circuit_pos_y = meta:get_int("circuit_specs_pos_y")
    local circuit_pos_z = meta:get_int("circuit_specs_pos_z")

    minetest.set_node(pos, {name = node_name})

    -- Put circuit_specs metadata on placed node
    meta = minetest.get_meta(pos)
    meta:set_int("circuit_specs_num_wires", circuit_num_wires)
    meta:set_int("circuit_specs_num_columns", circuit_num_columns)
    meta:set_int("circuit_specs_is_on_grid", circuit_is_on_grid)
    meta:set_int("circuit_specs_pos_x", circuit_pos_x)
    meta:set_int("circuit_specs_pos_y", circuit_pos_y)
    meta:set_int("circuit_specs_pos_z", circuit_pos_z)
end


function circuit_blocks:register_circuit_block(circuit_node_type,
                                               connector_up,
                                               connector_down,
                                               rotational,
                                               is_gate)
    local texture_name = ""
    if circuit_node_type == CircuitNodeTypes.EMPTY then
        texture_name = "circuit_blocks_empty_wire"
    elseif circuit_node_type == CircuitNodeTypes.X then
        texture_name = "circuit_blocks_x_gate"
        if connector_up and not connector_down then
            texture_name = "circuit_blocks_not_gate_up"
        elseif connector_down and not connector_up then
            texture_name = "circuit_blocks_not_gate_down"
        elseif connector_up and connector_up then
            texture_name = "circuit_blocks_not_gate"
        end
    elseif circuit_node_type == CircuitNodeTypes.H then
        texture_name = "circuit_blocks_h_gate"
    elseif circuit_node_type == CircuitNodeTypes.CTRL then
        texture_name = "circuit_blocks_control"
        if connector_up and not connector_down then
            texture_name = "circuit_blocks_control_up"
        elseif connector_down and not connector_up then
            texture_name = "circuit_blocks_control_down"
        end
    elseif circuit_node_type == CircuitNodeTypes.TRACE then
        texture_name = "circuit_blocks_trace"
    end
    minetest.register_node("circuit_blocks:"..texture_name, {
        description = texture_name,
        tiles = {texture_name..".png"},
        groups = {circuit_gate=1, oddly_breakable_by_hand=2},
        on_construct = function(pos)
            local meta = minetest.get_meta(pos)
            meta:set_int("node_type", circuit_node_type)
            meta:set_float("radians", 0.0)
            meta:set_int("ctrl_a", -1)
            meta:set_int("ctrl_b", -1)
            meta:set_int("is_gate", (is_gate and 1 or 0))
            minetest.debug("In on_construct: meta:to_table():\n" .. dump(meta:to_table()))
        end,
        on_punch = function(pos, node, player)
            local meta = minetest.get_meta(pos)
            local node_type = meta:get_int("node_type")
            local radians = meta:get_float("radians")
            local ctrl_a = meta:get_int("ctrl_a")
            local ctrl_b = meta:get_int("ctrl_b")
            local is_gate = meta:get_int("is_gate")
            local is_on_grid = meta:get_int("circuit_specs_is_on_grid")
            -- minetest.debug("In on_punch: meta:to_table():\n" .. dump(meta:to_table()))

            local wielded_item = player:get_wielded_item()

            if is_on_grid and is_on_grid == 1 then
                if wielded_item:get_name() == "circuit_blocks:control_tool" then
                    --
                else
                    circuit_blocks:set_node_with_circuit_specs_meta(pos,
                        "circuit_blocks:circuit_blocks_empty_wire")
                end
            end
            return
        end,
        can_dig = function(pos, player)
            local meta = minetest.get_meta(pos)
            local node_type = meta:get_int("node_type")
            local radians = meta:get_float("radians")
            local ctrl_a = meta:get_int("ctrl_a")
            local ctrl_b = meta:get_int("ctrl_b")
            local is_gate = meta:get_int("is_gate")
            local is_on_grid = meta:get_int("circuit_specs_is_on_grid")
            --minetest.debug("In can_dig: meta:to_table():\n" .. dump(meta:to_table()))
            return is_on_grid == 0
        end,
        on_rightclick = function(pos, node, clicker, itemstack)
            local meta = minetest.get_meta(pos)
            local node_type = meta:get_int("node_type")
            local radians = meta:get_float("radians")
            local ctrl_a = meta:get_int("ctrl_a")
            local ctrl_b = meta:get_int("ctrl_b")
            local is_gate = meta:get_int("is_gate")
            local is_on_grid = meta:get_int("circuit_specs_is_on_grid")
            local player_name = clicker:get_player_name()

            -- minetest.debug("In on_rightclick: meta:to_table():\n" .. dump(meta:to_table()))

            if is_on_grid == 1 then
                if node_type == CircuitNodeTypes.EMPTY then
                    local itemstack_name = itemstack:get_name()
                    local itemstack_meta = itemstack:get_meta()
                    -- minetest.debug("itemstack_meta:to_table():\n" .. dump(itemstack_meta:to_table()))

                    -- TODO: How best to get metadata for this item?
                    -- if itemstack_meta and itemstack_meta:get_int(is_gate) then

                    -- TODO: Perhaps use naming convention that indicates this is a gate
                    if itemstack_name:sub(1, 14) == "circuit_blocks" then
                        circuit_blocks:set_node_with_circuit_specs_meta(pos,
                                itemstack:get_name())
                    end
                elseif itemstack:get_name() == "circuit_blocks:control_tool" then
                    ctrl_a = ctrl_a * -1
                    meta:set_int("ctrl_a", ctrl_a)
                    minetest.chat_send_player(player_name, "ctrl_a is now: " .. tostring(ctrl_a))
                end
            end
        end
    })
end

minetest.register_node("circuit_blocks:qubit_0", {
    description = "Qubit 0 block",
    tiles = {"circuit_blocks_qubit_0.png"},
    groups = {oddly_breakable_by_hand=2}
})

minetest.register_node("circuit_blocks:qubit_1", {
    description = "Qubit 1 block",
    tiles = {"circuit_blocks_qubit_1.png"},
    groups = {oddly_breakable_by_hand=2}
})


minetest.register_tool("circuit_blocks:control_tool", {
	description = "Control tool",
	inventory_image = "circuit_blocks_control_tool.png",
	wield_image = "circuit_blocks_control_tool.png",
	wield_scale = { x = 1, y = 1, z = 1 },
	range = 10,
	tool_capabilities = {},
})

circuit_blocks:register_circuit_block(CircuitNodeTypes.EMPTY, false, false, false, false)
circuit_blocks:register_circuit_block(CircuitNodeTypes.X, false, false, false, true)
circuit_blocks:register_circuit_block(CircuitNodeTypes.X, true, true, false, true)
circuit_blocks:register_circuit_block(CircuitNodeTypes.X, true, false, false, true)
circuit_blocks:register_circuit_block(CircuitNodeTypes.X, false, true, false, true)
circuit_blocks:register_circuit_block(CircuitNodeTypes.H, false, false, false, true)
circuit_blocks:register_circuit_block(CircuitNodeTypes.CTRL, true, true, false, false)
circuit_blocks:register_circuit_block(CircuitNodeTypes.CTRL, true, false, false, false)
circuit_blocks:register_circuit_block(CircuitNodeTypes.CTRL, false, true, false, false)
circuit_blocks:register_circuit_block(CircuitNodeTypes.TRACE, false, false, false, false)
