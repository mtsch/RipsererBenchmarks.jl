"""
    grind_ripserer(b::Benchmark; extras=false, sparse=false, kwargs...)

Run `valgrind --tool=massif` on Ripserer.

!!! warning
    If you get `ERROR: Unable to find compatible target in system image.`, see:
    https://github.com/JuliaLang/julia/issues/27131
"""
function grind_ripserer(b::Benchmark; extras=false, sparse=false, kwargs...)
    if !isnothing(b.threshold)
        complex_kwargs = (;threshold=b.threshold)
    else
        complex_kwargs = (;)
    end
    if !isnothing(sparse)
        complex_kwargs = (;complex_kwargs..., sparse=sparse)
    end
    kwargs = (;kwargs..., b.kwargs...)
    project_dir = joinpath(@__DIR__, "..")
    if !isnothing(sparse) && sparse
        outfile = joinpath(
            @__DIR__, "../results/massif", "ripserer-sparse-" * b.name * ".massif.out"
        )
    else
        outfile = joinpath(
            @__DIR__, "../results/massif", "ripserer-" * b.name * ".massif.out"
        )
    end

    f = b.filename
    c = string(b.complex)
    ca = string(complex_kwargs)
    a = string(kwargs)

    cmd = `valgrind --tool=massif --massif-out-file=$outfile
           --smc-check=all-non-file julia -O3 --project=$project_dir -e
           'using RipsererBenchmarks;
            using Ripserer;
            RipsererBenchmarks._ripserer("'$f'", '$c', '$ca', '$a')
          '
          `
    run(cmd)
end

"""
    grind_ripser(b::Benchmark)

Run `valgrind --tool=massif` on (Cubical) Ripser.
"""
function grind_ripser(b::Benchmark)
    @info "grinding ripser for $filename"
    outfile = joinpath(
        @__DIR__, "../results/massif", "ripser-" * b.name * ".massif.out"
    )
    infile = joinpath(@__DIR__, "../datasets/", filename)
    ripser = ripsers_cmd(b.filename, true; b.kwargs..., threshold=b.threshold)
    cmd = `valgrind --tool=massif --massif-out-file=$outfile $ripser`
    run(cmd)
end
