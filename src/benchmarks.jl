struct Benchmark{D, T, K1, K2}
    filename::String
    name::String
    complex::UnionAll
    data::D
    threshold::T
    kwargs::K1
    extra_kwargs::K2
end

function Benchmark(filename; threshold=nothing, extra::K=(;), kwargs...) where K
    name, ext = splitext(filename)
    filename = joinpath(@__DIR__, "..", "datasets", filename)
    data = load_data(filename)
    complex = if ext == ".dipha"
        Cubical
    elseif ext == ".alpha"
        Alpha
    else
        Rips
    end
    T = typeof(threshold)
    return Benchmark{typeof(data), T, typeof(kwargs), K}(
        filename, name, complex, data, threshold, kwargs, extra
    )
end

Ripserer.nv(b::Benchmark) = Ripserer.nv(b.complex(b.data))
