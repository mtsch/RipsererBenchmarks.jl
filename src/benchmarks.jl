struct Benchmark{F, D, T, K1, K2}
    filename::String
    name::String
    complex::F
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
    else
        Rips
    end
    T = typeof(threshold)
    return Benchmark{typeof(complex), typeof(data), T, typeof(kwargs), K}(
        filename, name, complex, data, threshold, kwargs, extra
    )
end

Ripserer.nv(b::Benchmark) = Ripserer.nv(b.complex(b.data))
