using BenchmarkTools

include(joinpath(@__DIR__, "utils.jl"))

function get_ripser()
    exedir = joinpath(@__DIR__, "../exes")
    if isfile("$exedir/ripser-mod2") && isfile("$exedir/ripser-coef")
        @info "ripser exists"
    else
        rm("ripser-mod2"; force=true)
        rm("ripser-coef"; force=true)
        run(`git clone https://github.com/Ripser/ripser`)
        cd("ripser")
        run(`make all`)
        mv("ripser", "$exedir/ripser-mod2")
        mv("ripser-coeff", "$exedir/ripser-coef")
        cd("..")
        rm("ripser", force=true, recursive=true)
    end
end

function get_cubical_ripser()
    exedir = joinpath(@__DIR__, "../exes")
    if isfile("$exedir/CR2") && isfile("$exedir/CR3")
        @info "cubical ripser exists"
    else
        for d in (2, 3)
            rm("CR$d"; force=true)
            run(`git clone https://github.com/CubicalRipser/CubicalRipser_$(d)dim`)
            cd("CubicalRipser_$(d)dim")
            run(`make`)
            mv("CR$d", "$exedir/CR$d")
            cd("..")
            rm("CubicalRipser_$(d)dim"; force=true, recursive=true)
        end
    end
end

"""
    ripsers_cmd(filename, string=false; dim_max, modulus, threshold)

Generate a Ripser or Cubical Ripser command for benchmarking, taking file extension and
keyword args into account. If `string=false`, return a `Cmd`, else return a vector of
`String`s.
"""
function ripsers_cmd(filename, string=false; dim_max=1, modulus=2, threshold=nothing)
    ext = splitext(filename)[2]
    exedir = joinpath(@__DIR__, "../exes")
    if ext == ".dipha"
        if dim_max == 2
            cmd_strings = ["$exedir/CR2", filename]
        elseif dim_max == 3
            cmd_strings = ["$exedir/CR3", filename]
        else
            error("invalid dim_max for cubical ripser")
        end
    else
        thresh = isnothing(threshold) ? String[] : ["--threshold", "$threshold"]
        if ext == ".dist"
            format = "distance"
        elseif ext == ".spdist"
            format = "sparse"
        elseif ext == ".pts"
            format = "point-cloud"
        else
            error("invalid extension `$ext`")
        end
        ripser = modulus == 2 ? "$exedir/ripser-mod2" : "$exedir/ripser-coef"
        mod = modulus == 2 ? String[] : ["--modulus", "modulus"]
        cmd = "$ripser --dim $dim_max $mod $thresh $format $(filename)"
        cmd_strings = [
            [ripser, "--dim", "$dim_max"]; mod; thresh; ["--format", format, filename]
        ]
    end
    if string
        return cmd_strings
    else
        return Cmd(cmd_strings)
    end
end

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

function run_benchmarks_ripsers(benchmark_list, sparse=false)
    get_ripser()
    get_cubical_ripser()
    @info "setting up ripser..."
    group = BenchmarkGroup()
    for arg in benchmark_list
        filename = joinpath(@__DIR__, "../datasets", arg.filename)
        group[arg.filename] = @benchmarkable read(
            $(ripsers_cmd(filename; arg.args...))
        ) gcsample=true samples=5 seconds=1000
    end
    @info "running ripsers"
    @time run(group)
end

function run_benchmarks_ripserer(benchmark_list; sparse=false)
    @info "setting up ripserer..."
    group = BenchmarkGroup()
    for arg in benchmark_list
        filename = joinpath(@__DIR__, "../datasets", arg.filename)
        group[arg.filename] = @benchmarkable run_ripserer(
            $filename; sparse=$sparse, $(arg.args)...
        ) gcsample=true samples=5 seconds=1000
    end
    if sparse
        @info "running sparse ripserer"
    else
        @info "running ripserer"
    end
    @time run(group)
end

function run_and_save_all()
    @info "running alpha benchmarks"
    BenchmarkTools.save(
        "alpha-ripserer.json", run_benchmarks_ripserer(alpha_benchmarks)
    )
    BenchmarkTools.save(
        "alpha-ripser.json", run_benchmarks_ripsers(alpha_benchmarks)
    )
    @info "running cubical benchmarks"
    BenchmarkTools.save(
        "cubical-ripserer.json", run_benchmarks_ripserer(cubical_benchmarks)
    )
    BenchmarkTools.save(
        "cubical-ripser.json", run_benchmarks_ripsers(cubical_benchmarks)
    )
    @info "running rips benchmarks"
    BenchmarkTools.save(
        "rips-ripserer.json", run_benchmarks_ripserer(rips_benchmarks)
    )
    BenchmarkTools.save(
        "rips-ripserer-sparse.json", run_benchmarks_ripserer(rips_benchmarks, sparse=true)
    )
    BenchmarkTools.save(
        "rips-ripser.json", run_benchmarks_ripsers(rips_benchmarks)
    )
end

function grind_all()
    for benchmark in alpha_benchmarks
        grind_ripserer(benchmark.filename; benchmark.args...)
        grind_ripser(benchmark.filename; benchmark.args...)
    end
    for benchmark in cubical_benchmarks
        grind_ripserer(benchmark.filename; benchmark.args...)
        grind_ripser(benchmark.filename; benchmark.args...)
    end
    for benchmark in rips_benchmarks
        grind_ripserer(benchmark.filename; benchmark.args...)
        grind_ripserer(benchmark.filename; sparse=true, benchmark.args...)
        grind_ripser(benchmark.filename; benchmark.args...)
    end
end

function print_results(ripserer_res, ripser_res)
    judgement = judge(minimum(ripserer_res), minimum(ripser_res))
    for k in keys(judgement)
        println(k, ": ", judgement[k])
    end
end

cubical_benchmarks=[
    (filename="lena512.dipha",
     args=(;dim_max=2)
     ),
    (filename="lena1999x999.dipha",
     args=(;dim_max=2),
     ),
    (filename="bonsai64.dipha",
     args=(;dim_max=3),
     ),
    (filename="bonsai128.dipha",
     args=(;dim_max=3),
     ),
    (filename="head128.dipha",
     args=(;dim_max=3),
     ),
]

rips_benchmarks = [
    (filename="sphere_3_192.dist",
     args=(;dim_max=2),
     ),
    (filename="o3_1024.pts",
     args=(;dim_max=3, threshold=1.8),
     ),
    (filename="o3_4096.pts",
     args=(;dim_max=3, threshold=1.4),
     ),
    (filename="dragon2000.pts",
     args=(;dim_max=1),
     ),
    (filename="fract-r.dist",
     args=(;dim_max=2),
     ),
    (filename="random16.dist",
     args=(;dim_max=2),
     ),
]

alpha_benchmarks = [
    (filename="alpha_torus_10_000.spdist",
     args=(;dim_max=2),
     ),
    (filename="alpha_5_sphere_1000.spdist",
     args=(;dim_max=5),
     ),
    (filename="alpha_4_sphere_2000.spdist",
     args=(;dim_max=4),
     ),
    (filename="alpha_3_sphere_3000.spdist",
     args=(;dim_max=3),
     ),
    (filename="alpha_dragon_2000.spdist",
     args=(;dim_max=2),
     )
]
