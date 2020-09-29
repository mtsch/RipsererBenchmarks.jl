# TODO
function grind_ripserer(filename; sparse=false, threshold=nothing, kwargs...)
    utils_file = joinpath(@__DIR__, "utils.jl")
    args = (;sparse=sparse, threshold=threshold, kwargs...)
    if sparse
        @info "grinding sparse ripserer for $filename"
        outfile = joinpath(
            @__DIR__, "../results/massif", "ripserer-sparse-" * splitext(filename)[1] * ".massif.out"
        )
    else
        @info "grinding ripserer for $filename"
        outfile = joinpath(
            @__DIR__, "../results/massif", "ripserer-" * splitext(filename)[1] * ".massif.out"
        )
    end
    infile = joinpath(@__DIR__, "../datasets/", filename)
    cmd = `valgrind --tool=massif --massif-out-file=$outfile
           --smc-check=all-non-file julia -O3 -e
           'include("'$utils_file'"); run_ripserer("'$infile'"; '$(string(args))'...)'`
    run(cmd)
end

function grind_ripser(filename; threshold=nothing, kwargs...)
    @info "grinding ripser for $filename"
    args = (;threshold=threshold, kwargs...)
    outfile = joinpath(
        @__DIR__, "../results/massif", "ripser-" * splitext(filename)[1] * ".massif.out"
    )
    infile = joinpath(@__DIR__, "../datasets/", filename)
    ripser = ripsers_cmd(infile, true; threshold=threshold, args...)
    cmd = `valgrind --tool=massif --massif-out-file=$outfile $ripser`
    run(cmd)
end
