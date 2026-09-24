using StaticStrings
using Documenter

DocMeta.setdocmeta!(StaticStrings, :DocTestSetup, :(using StaticStrings); recursive=true)

makedocs(;
    modules=[StaticStrings],
    authors="Mark Kittisopikul <markkitt@gmail.com> and contributors",
    repo="https://github.com/JuliaStrings/StaticStrings.jl/blob/{commit}{path}#{line}",
    sitename="StaticStrings.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://juliastrings.github.io/StaticStrings.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaStrings/StaticStrings.jl",
    devbranch="main",
)
