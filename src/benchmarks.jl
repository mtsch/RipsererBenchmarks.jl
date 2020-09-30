struct Benchmark{D, T, K1, K2}
    filename::String
    name::String
    complex::UnionAll
    data::D
    threshold::T
    kwargs::K1
    extra_kwargs::K2
end

Base.show(io::IO, b::Benchmark) = print(io, "Benchmark($(b.name))")

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
get_meta(arg) = function(b)
    return if arg == :threshold
        b.threshold
    elseif arg == :size
        Ripserer.nv(b)
    elseif arg == :complex
        nameof(b.complex)
    elseif haskey(b.kwargs, arg)
        b.kwargs[arg]
    elseif haskey(b.extra_kwargs, arg)
        b.extra_kwargs[arg]
    else
        ""
    end
end
