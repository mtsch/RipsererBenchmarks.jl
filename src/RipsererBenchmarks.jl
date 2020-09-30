module RipsererBenchmarks

using BenchmarkTools
using CSV
using DataFrames
using Eirene
using Logging
using ProgressMeter
using Ripserer
using SparseArrays
using TerminalLoggers

export Benchmark, ripser_benchmark, ripserer_benchmark, eirene_benchmark,
    nv, load_data, setup_all, grind_ripser, grind_ripserer, run_and_save, save_csv

include("utils.jl")
include("benchmarks.jl")
include("ripserer.jl")
include("ripser.jl")
include("eirene.jl")
include("benchmarksuites.jl")
include("valgrind.jl")
include("report.jl")

function run_and_save(selected=nothing)
    get_ripsers()

    start_time = time_ns()
    if isnothing(selected)
        suite = setup_all()
        file = "all_results.json"
        @info "running all"
    else
        suite = setup_all()[selected]
        file = "$selected.json"
        @info "running $selected"
    end
    result = with_logger(TerminalLogger()) do
        run(suite)
    end
    BenchmarkTools.save(joinpath(@__DIR__, "..", "results", file), result)
    elapsed = (time_ns() - start_time) / 1e9
    @info "Took $(ProgressMeter.durationstring(elapsed))"
    return result
end


end
