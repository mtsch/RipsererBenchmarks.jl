import Pkg
Pkg.activate(@__DIR__)

using RipsererBenchmarks

time_start = time_ns()

#RipserComparison.run_and_save_all()
#RipserComparison.grind_all()
RipsererBenchmarks.EireneComparison.run_and_save_all()
Involuted.run_and_save_all()

elapsed = (time_ns() - time_start)/1e9
@info "Time $(ProgressMeter.durationstring(elapsed))"
