function create_coloring(elements)
    # Contains the elements that each node contain
    cell_containing_node = Dict{Int, Set{Int}}()
    for element in elements
        interpolate(element, "geometry", time)
        for v in nodes
            if !haskey(cell_containing_node, v)
                cell_containing_node[v] = Set{Int}()
            end
            push!(cell_containing_node[v], cellid)
        end
    end

    I, J, V = Int[], Int[], Bool[]
    for (node, cells) in cell_containing_node
        for cell1 in cells # All these cells have a neighboring node
            for cell2 in cells
                if cell1 != cell2
                    push!(I, cell1)
                    push!(J, cell2)
                    push!(V, true)
                end
            end
        end
    end

    incidence_matrix = sparse(I, J, V)
    # cell -> color of cell
    cell_colors = Dict{Int, Int}()
    # color -> list of cells
    final_colors = Set{Int}[]
    occupied_colors = Set{Int}()
    # Zero represents no color set yet
    for (cellid, _) in elements
        cell_colors[cellid] = 0
    end
    total_colors = 0
    for (cellid, _) in elements
        empty!(occupied_colors)
        # loop over neighbors
        for r in nzrange(incidence_matrix, cellid)
            cell_neighbour = incidence_matrix.rowval[r]
            color = cell_colors[cell_neighbour]
            if color != 0
                push!(occupied_colors, color)
            end
        end

        # occupied colors now contains all the colors we are not allowed to use
        free_color = 0
        for attempt_color in 1:total_colors
            if attempt_color ∉ occupied_colors
                free_color = attempt_color
                break
            end
        end

        if free_color == 0 # no free color found, need to bump max colors
            total_colors += 1
            free_color = total_colors
            push!(final_colors, Set{Int}())
        end

        cell_colors[cellid] = free_color
        push!(final_colors[free_color], cellid)
    end

    return cell_colors
end
