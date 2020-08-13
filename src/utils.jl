# Utility file I/O functions. Not fit for general purpose use.
using CSV
using Ripserer
using SparseArrays

function load_dipha(filename)
    open(filename, "r") do f
        magic = read(f, Int)
        @assert magic == 8067171840
        type = read(f, Int)
        @assert type == 1
        len = read(f, Int)
        dim = read(f, Int)
        if dim == 2
            m = read(f, Int)
            n = read(f, Int)
            result = Array{Float64}(undef, (m, n))
            read!(f, result)

            return result
        elseif dim == 3
            m = read(f, Int)
            n = read(f, Int)
            o = read(f, Int)
            result = Array{Float64}(undef, (m, n, o))
            read!(f, result)

            return result
        else
            error("not implemented for dim=$dim")
        end
    end
end

function save_dipha(filename, data)
    open(filename, "w") do f
        write(f, 8067171840)
        write(f, 1)
        write(f, length(data))
        write(f, length(size(data)))
        for s in size(data)
            write(f, s)
        end
        for i in data
            write(f, Float64(i))
        end
    end
end

function load_points(filename)
    # ripser uses Float32
    table = CSV.read(filename, header=0, type=Float32, delim=' ')
    nrow, dim = size(table)
    result = Vector{NTuple{dim, Float32}}(undef, nrow)
    for i in 1:nrow
        result[i] = Tuple(table[i, :])
    end
    return result
end

function load_dist(filename)
    return Matrix(CSV.read(filename, header=0, type=Float32, delim=' '))
end

function save_sparse(filename, data)
    I, J, V = findnz(sparse(LowerTriangular(data)))
    return CSV.write(joinpath(filename), (I=I.-1, J=J.-1, V=V), writeheader=false, delim=' ')
end

function load_sparse(filename)
    table = CSV.read(filename, header=0, type=Float32, delim=' ')
    I = table[:, 1] .+ 1
    J = table[:, 2] .+ 1
    V = table[:, 3] .+ 1
    sparse([I; J], [J; I], [V; V])
end

"""
    run_ripserer(filename; kwargs...)

Read file and run Ripserer.
"""
function run_ripserer(filename; sparse=false, threshold=nothing, kwargs...)
    ext = splitext(filename)[2]
    if ext == ".dist"
        data = load_dist(filename)
        ftype = sparse ? SparseRips : Rips
    elseif ext == ".pts"
        data = load_points(filename)
        ftype = sparse ? SparseRips : Rips
    elseif ext == ".dipha"
        data = load_dipha(filename)
        ftype = Cubical
    elseif ext == ".spdist"
        data = load_sparse(filename)
        ftype = SparseRips
    else
        error("invalid extension `$ext`")
    end
    if !isnothing(threshold)
        return ripserer(ftype(data, threshold=threshold); kwargs...)
    else
        return ripserer(ftype(data); kwargs...)
    end
end
