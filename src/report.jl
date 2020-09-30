using DataFrames

function _frame(
    agg=minimum;
    baseline,
    target,
    benchmarks,
    extra_meta=("size" => :size,
                "complex" => :complex,
                "dim" => :dim_max,
                )
)
    names = collect(intersect(keys(baseline), keys(target)))
    targets = [agg(target[name]) for name in names]
    baselines = [agg(baseline[name]) for name in names]
    ratios = [round(r.ratio.time, digits=3) for r in judge.(targets, baselines)]
    bs = [benchmarks[findfirst(b -> b.name == name, benchmarks)] for name in names]
    metas = [key => get_meta(value).(bs)
        for (key, value) in extra_meta
    ]

    ix = [
        "name" => names,
        metas...,
        target => targets,
        baseline => baselines,
        "ratio" => ratios,
     ]

    DataFrame([
        "name" => names,
        metas...,
        "target" => targets,
        "baseline" => baselines,
        "ratio" => ratios,
     ])
end

function save_all(result)
    res(f) = joinpath(@__DIR__, "..", "results", "csv", f)
    # involuted
    CSV.write(
        res("involuted-vs-cohomology.csv"),
        _frame(
            baseline=result["involuted"]["involuted"],
            target=result["involuted"]["cohomology"],
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
            target=result["ripser"]["rips"]["ripser"]["sparse"],
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
            target=result["ripser"]["rips"]["ripser"]["dense"],
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
            baseline=result["ripser"]["alpha"]["ripser"],
            target=result["ripser"]["alpha"]["ripserer"],
            benchmarks=alpha_rips_benchmarks,
            extra_meta=(
                "size" => :size,
                "dim" => :dim_max,
                "threshold" => :threshold,
            )
        )
    )
end

#=
save_latex(
    "test", res,
    baseline="homology",
    target="cohomology",
    benchmarks=RipsererBenchmarks.involuted_benchmarks
)
=#
