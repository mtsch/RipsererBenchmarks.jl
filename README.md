# RipsererBenchmarks.jl

This repository contains the datasets and benchmarking code for
[Ripserer.jl](https://github.com/mtsch/Ripserer.jl). Only benchmarks that we were able to
run on a laptop with 8GB RAM are included.

It contains code for comparing Ripserer.jl with [Ripser](https://github.com/Ripser/ripser),
[Cubical Ripser](https://github.com/CubicalRipser/), and
[Eirene.jl](https://github.com/Eetion/Eirene.jl), as well as benchmarks comparing Ripserer's
cohomology, homology, and involuted homology algorithms.

The benchmarks consist of two parts, a timing benchmark based on
[BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl/) and memory profiling
using [Valgrind's Massif heap
profiler](https://www.valgrind.org/docs/manual/ms-manual.html).

The datasets can be found in the [`datasets`](datasets) directory. Results are located in
[`results`](results). To load the `.json` file into Julia, use `BenchmarkTools.load`. Also,
see [the BenchmarkTools.jl
manual](https://github.com/JuliaCI/BenchmarkTools.jl/blob/master/doc/manual.md) for more
info. Massif results can be viewed with
[`massif-visualizer`](https://github.com/KDE/massif-visualizer).

The code is sparsely documented. If you are interested in running the benchmarks yourself,
feel free to open an issue, or [contact me](mailto:matijacufar@gmail.com). I would be
very interested in seeing results on larger datasets performed on a more powerful computer.

## Acknowledgments

* Datasets `celegans`, `hiv`, `dragon1000`, `dragon2000`, `random16`, `fract-r`, `kelin400`,
  and `klein900` were taken from [the PH-roadmap
  repository](https://github.com/n-otter/PH-roadmap). Also, see the reference below.

* Datasets `sphere_3_192`, `o3_1024`, and `o3_4096` were taken from
  [the Ripser repository](https://github.com/Ripser/ripser).

* Datasets `bonsai` and `head` were taken from [Open Scientific Visualization
  Datasets](https://klacansky.com/open-scivis-datasets/) and downsampled to appropriate
  sizes. `bonsai` was created by S. Roettger, VIS, University of Stuttgart, and `head` was
  created by Michael Meißner, Viatronix Inc., USA.

* `lena512` is a standard test image that can be found in many places, for example
  [here](https://en.wikipedia.org/wiki/Lenna#/media/File:Lenna_(test_image).png). A
  greyscale version is used in these benchmarks. The 1999×999 version was created by first
  upscaling the image to 2048×2048 and then extracting a 1999×999 region from the image.

## Refrences

Bauer, U. (2019). Ripser: efficient computation of Vietoris-Rips persistence barcodes. arXiv
preprint arXiv:1908.02518.

Kaji, S., Sudo, T., & Ahara, K. (2020). Cubical Ripser: Software for computing persistent
homology of image and volume data. arXiv preprint arXiv:2005.12692.

Henselman, G., & Ghrist, R. (2016). Matroid filtrations and computational persistent
homology. arXiv preprint arXiv:1606.00199.

Otter, N., Porter, M. A., Tillmann, U., Grindrod, P., & Harrington, H. A. (2017). A roadmap
for the computation of persistent homology. EPJ Data Science, 6(1), 17.
