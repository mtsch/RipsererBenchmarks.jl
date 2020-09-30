using Eirene

# Translate kwarg names.
function _eirene(data; dim_max=1, threshold=nothing, model)
    if isnothing(threshold)
        return eirene(data; maxdim=dim_max, model=model)
    else
        return eirene(data; maxdim=dim_max, maxrad=threshold, model=model)
    end
end

function eirene_benchmark(b::Benchmark)
    if b.data isa Vector
        data = Ripserer.to_matrix(b.data)
        model = "pc"
    else
        data = b.data
        model = "vr"
    end
    return @benchmarkable _eirene(
        $data; $(b.kwargs)..., threshold=$(b.threshold), model=$model
    ) samples=5 seconds=1000 gcsample=true
end
