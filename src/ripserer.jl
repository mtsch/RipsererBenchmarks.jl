# Make sure filtration building is also benchmarked.
function _ripserer(data, complex, complex_kwargs, ripserer_kwargs)
    return ripserer(complex(data; complex_kwargs...); ripserer_kwargs...)
end

function _ripserer(filename::String, complex, complex_kwargs, ripserer_kwargs)
    data = load_data(filename)
    return ripserer(complex(data; complex_kwargs...); ripserer_kwargs...)
end

function ripserer_benchmark(
    b::Benchmark; extras=false, from_file=false, sparse=nothing, kwargs...
)
    if !isnothing(b.threshold)
        complex_kwargs = (;threshold=b.threshold)
    else
        complex_kwargs = (;)
    end
    if extras
        complex_kwargs = (;complex_kwargs..., b.extra_kwargs...)
    end
    if !isnothing(sparse)
        complex_kwargs = (;complex_kwargs..., sparse=sparse)
    end
    if from_file
        input = b.filename
    else
        input = b.data
    end
    kwargs = (;kwargs..., b.kwargs...)
    return @benchmarkable _ripserer(
        $(input), $(b.complex), $(complex_kwargs), $(kwargs)
    ) samples=5 seconds=1000 gcsample=true
end
