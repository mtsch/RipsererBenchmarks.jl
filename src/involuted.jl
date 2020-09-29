using BenchmarkTools
using Ripserer

include(joinpath(@__DIR__, "utils.jl"))
include(joinpath(@__DIR__, "benchmarks.jl"))

function run_benchmarks(benchmark_list; alg)
    @info "setting up $alg"
    group = BenchmarkGroup()
    for arg in benchmark_list
        data = load_data(joinpath(@__DIR__, "../datasets", arg.filename))
        group[arg.filename] = @benchmarkable ripserer(
            $data; $(arg.args)..., $(arg.best)..., alg=Symbol($alg)
        ) gcsample=true samples=5 seconds=1000
    end
    @info "running $alg"
    @time run(group)
end

"""
    run_and_save_all()

Run all involuted homology benchmarks.
"""
function run_and_save_all()
    timings(f) = joinpath(@__DIR__, "..", "results", "involuted", f)
    @info "cubical"
    BenchmarkTools.save(
        timings("cubical-cohomology.json"), run_benchmarks(cubical_benchmarks; alg="involuted")
    )
    BenchmarkTools.save(
        timings("cubical-involuted.json"), run_benchmarks(cubical_benchmarks; alg="cohomology")
    )
    BenchmarkTools.save(
        timings("cubical-homology.json"), run_benchmarks(cubical_benchmarks; alg="homology")
    )
    @info "rips"
    BenchmarkTools.save(
        timings("rips-cohomology.json"), run_benchmarks(rips_benchmarks; alg="involuted")
    )
    BenchmarkTools.save(
        timings("rips-involuted.json"), run_benchmarks(rips_benchmarks; alg="cohomology")
    )
    BenchmarkTools.save(
        timings("rips-homology.json"), run_benchmarks(rips_benchmarks; alg="homology")
    )
end
