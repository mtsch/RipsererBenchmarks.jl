"""
Pull Ripser from github and build it.
"""
function get_ripser()
    if isfile("ripser-mod2") && isfile("ripser-coef")
        @info "ripser exists"
    else
        rm("ripser-mod2"; force=true)
        rm("ripser-coef"; force=true)
        rm("ripser", force=true, recursive=true)

        run(`git clone https://github.com/Ripser/ripser`)
        cd("ripser")
        run(`make all`)
        mv("ripser", "../ripser-mod2")
        mv("ripser-coeff", "../ripser-coef")
        cd("..")

        rm("ripser", force=true, recursive=true)
    end
end

"""
Pull Cubical Ripser from github and build it.
"""
function get_cubical_ripser()
    if isfile("CR2") && isfile("CR3")
        @info "cubical ripser exists"
    else
        for d in (2, 3)
            rm("CR$d"; force=true)
            rm("CubicalRipser_$(d)dim"; force=true, recursive=true)

            run(`git clone https://github.com/CubicalRipser/CubicalRipser_$(d)dim`)
            cd("CubicalRipser_$(d)dim")
            run(`make`)
            mv("CR$d", "../CR$d")
            cd("..")

            rm("CubicalRipser_$(d)dim"; force=true, recursive=true)
        end
    end
end
