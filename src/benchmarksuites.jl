cubical_benchmarks=[
    Benchmark("lena512.dipha"; dim_max=1),
    Benchmark("lena1999x999.dipha"; dim_max=1),
    Benchmark("bonsai64.dipha"; dim_max=2),
    Benchmark("bonsai128.dipha"; dim_max=2),
    Benchmark("head128.dipha"; dim_max=2),
]

rips_benchmarks = [
    Benchmark("sphere_3_192.dist"; dim_max=2),
    Benchmark("o3_1024.pts"; dim_max=3, threshold=1.8, extra=(;sparse=true)),
    Benchmark("o3_4096.pts"; dim_max=3, threshold=1.4, extra=(;sparse=true)),
    Benchmark("dragon2000.pts"; dim_max=1),
    Benchmark("fract-r.dist"; dim_max=2),
    Benchmark("random16.dist"; dim_max=2),
]

alpha_rips_benchmarks = [
    Benchmark("alpha_torus_10_000.spdist"; dim_max=2),
    Benchmark("alpha_5_sphere_1000.spdist"; dim_max=5),
    Benchmark("alpha_4_sphere_2000.spdist"; dim_max=4),
    Benchmark("alpha_3_sphere_3000.spdist"; dim_max=3),
    Benchmark("alpha_dragon_2000.spdist"; dim_max=2),
]

eirene_benchmarks = [
    Benchmark("gcycle.dist"; dim_max=3),
    Benchmark("celegans.dist"; dim_max=2),
    Benchmark("dragon1000.dist"; dim_max=1),
    Benchmark("hiv.dist"; dim_max=1),
]

involuted_benchmarks = [
    Benchmark("gcycle.dist"; dim_max=3),
    Benchmark("celegans.dist"; dim_max=2),
    Benchmark("dragon1000.dist"; dim_max=1),
    Benchmark("hiv.dist"; dim_max=1),
    Benchmark("lena2048.dipha"; dim_max=1),
    Benchmark("bonsai128.dipha"; dim_max=2),
    Benchmark("alpha_dragon2000.alpha"; dim_max=2),
]

test_ripser = [
    Benchmark("lena512.dipha"; dim_max=1),
    Benchmark("alpha_dragon_2000.spdist"; dim_max=2),
    Benchmark("gcycle.dist"; dim_max=2),
]

test_eirene = [
    Benchmark("gcycle.dist"; dim_max=2),
]

test_involuted = [
    Benchmark("alpha_dragon_2000.spdist"; dim_max=2),
]

function setup_suite(type, benchmarks; sparse=false)
    suite = BenchmarkGroup()
    if type == :ripser
        suite["ripser"] = BenchmarkGroup()
        suite["ripserer"] = BenchmarkGroup()
        if sparse
            suite["ripserer"]["sparse"] = BenchmarkGroup()
            suite["ripserer"]["dense"] = BenchmarkGroup()
        end
        for b in benchmarks
            suite["ripser"][b.name] = ripser_benchmark(b)
            if sparse
                suite["ripserer"]["dense"][b.name] = ripserer_benchmark(
                    b; from_file=true, sparse=false
                )
                suite["ripserer"]["sparse"][b.name] = ripserer_benchmark(
                    b; from_file=true, sparse=true
                )
            else
                suite["ripserer"][b.name] = ripserer_benchmark(b; from_file=true)
            end
        end
    elseif type == :eirene
        suite["eirene"] = BenchmarkGroup()
        suite["ripserer"] = BenchmarkGroup()
        for b in benchmarks
            suite["eirene"][b.name] = eirene_benchmark(b)
            suite["ripserer"][b.name] = ripserer_benchmark(b; alg=:involuted)
        end
    elseif type == :involuted
        suite["cohomology"] = BenchmarkGroup()
        suite["homology"] = BenchmarkGroup()
        suite["involuted"] = BenchmarkGroup()
        for b in benchmarks
            suite["cohomology"][b.name] = ripserer_benchmark(b; extras=true)
            suite["involuted"][b.name] = ripserer_benchmark(b; extras=true, alg=:involuted)
            if b.complex ≠ Rips
                suite["homology"][b.name] = ripserer_benchmark(b; extras=true, alg=:homology)
            end
        end
    end
    return suite
end

function setup_all()
    suite = BenchmarkGroup()
    suite["ripser"] = BenchmarkGroup()
    suite["ripser"]["rips"] = setup_suite(:ripser, rips_benchmarks; sparse=true)
    suite["ripser"]["cubical"] = setup_suite(:ripser, cubical_benchmarks)
    suite["ripser"]["alpha_rips"] = setup_suite(:ripser, alpha_rips_benchmarks)
    suite["eirene"] = setup_suite(:eirene, eirene_benchmarks)
    suite["involuted"] = setup_suite(:involuted, involuted_benchmarks)

    suite["test"] = BenchmarkGroup()
    suite["test"]["eirene"] = setup_suite(:eirene, test_eirene)
    suite["test"]["ripser"] = setup_suite(:ripser, test_ripser)
    suite["test"]["involuted"] = setup_suite(:involuted, test_involuted)

    return suite
end
