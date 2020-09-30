"""
    get_ripsers()

Download latest versions of Ripser and Cubical Ripser from GitHub and build them.
"""
function get_ripsers()
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
        if dim_max == 1
            cmd_strings = ["$exedir/CR2", filename]
        elseif dim_max == 2
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

function ripser_benchmark(b::Benchmark)
    return @benchmarkable read(
        $(ripsers_cmd(b.filename; b.kwargs..., b.threshold))
    ) gcsample=true samples=5 seconds=1000
end
