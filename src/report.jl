function timestring(t)
    if t < 1e3
        unit = "ns"
    elseif t < 1e6
        t /= 1e3
        unit = "μs"
    elseif t < 1e9
        t /= 1e6
        unit = "ms"
    else
        t /= 1e9
        unit = "s"
    end
    return string(round(t, digits=3)) * " " * unit
end

function _frame(
    agg=minimum;
    baseline,
    target,
    benchmarks,
    extra_meta=(
        "size" => :size,
        "complex" => :complex,
        "dim" => :dim_max,
    )
)
    names = collect(intersect(keys(baseline), keys(target)))
    targets = [agg(target[name]) for name in names]
    baselines = [agg(baseline[name]) for name in names]
    ratios = [string(round(r.ratio.time, digits=3)) for r in judge.(targets, baselines)]
    bs = [benchmarks[findfirst(b -> b.name == name, benchmarks)] for name in names]
    metas = [key => get_meta(value).(bs)
        for (key, value) in extra_meta
    ]

    return DataFrame([
        "name" => names,
        metas...,
        "target" => [timestring(t.time) for t in targets],
        "baseline" => [timestring(b.time) for b in baselines],
        "ratio" => ratios,
     ])
end

function save_csv()
    result = BenchmarkTools.load(
        joinpath(@__DIR__, "..", "results" , "all_results.json")
    )[1]
    res(f) = joinpath(@__DIR__, "..", "results", "csv", f)
    CSV.write(
        res("involuted-vs-cohomology.csv"),
        _frame(
            baseline=result["involuted"]["cohomology"],
            target=result["involuted"]["involuted"],
            benchmarks=involuted_benchmarks,
            extra_meta=(
                "size" => :size,
                "dim" => :dim_max,
                "threshold" => :threshold,
                "complex" => :complex
            )
        )
    )
    CSV.write(
        res("involuted-vs-homology.csv"),
        _frame(
            baseline=result["involuted"]["homology"],
            target=result["involuted"]["involuted"],
            benchmarks=involuted_benchmarks,
            extra_meta=(
                "size" => :size,
                "dim" => :dim_max,
                "threshold" => :threshold,
                "complex" => :complex
            )
        )
    )
    CSV.write(
        res("involuted-vs-eirene.csv"),
        _frame(
            baseline=result["eirene"]["eirene"],
            target=result["eirene"]["ripserer"],
            benchmarks=eirene_benchmarks,
            extra_meta=(
                "size" => :size,
                "dim" => :dim_max,
                "threshold" => :threshold,
                "complex" => :complex
            )
        )
    )
    CSV.write(
        res("rips-vs-ripser-sparse.csv"),
        _frame(
            baseline=result["ripser"]["rips"]["ripser"],
            target=result["ripser"]["rips"]["ripserer"]["sparse"],
            benchmarks=rips_benchmarks,
            extra_meta=(
                "size" => :size,
                "dim" => :dim_max,
                "threshold" => :threshold,
            )
        )
    )
    CSV.write(
        res("rips-vs-ripser-dense.csv"),
        _frame(
            baseline=result["ripser"]["rips"]["ripser"],
            target=result["ripser"]["rips"]["ripserer"]["dense"],
            benchmarks=rips_benchmarks,
            extra_meta=(
                "size" => :size,
                "dim" => :dim_max,
                "threshold" => :threshold,
            )
        )
    )
    CSV.write(
        res("cubical-vs-ripser-dense.csv"),
        _frame(
            baseline=result["ripser"]["cubical"]["ripser"],
            target=result["ripser"]["cubical"]["ripserer"],
            benchmarks=cubical_benchmarks,
            extra_meta=(
                "size" => :size,
                "dim" => :dim_max,
                "threshold" => :threshold,
            )
        )
    )
    CSV.write(
        res("alpha-rips-vs-ripser.csv"),
        _frame(
            baseline=result["ripser"]["alpha_rips"]["ripser"],
            target=result["ripser"]["alpha_rips"]["ripserer"],
            benchmarks=alpha_rips_benchmarks,
            extra_meta=(
                "size" => :size,
                "dim" => :dim_max,
                "threshold" => :threshold,
            )
        )
    )
end
