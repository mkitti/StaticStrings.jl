using NStrings
using Documenter

DocMeta.setdocmeta!(NStrings, :DocTestSetup, :(using NStrings); recursive=true)

makedocs(;
    modules=[NStrings],
    authors="Mark Kittisopikul <markkitt@gmail.com> and contributors",
    repo="https://github.com/mkitti/NStrings.jl/blob/{commit}{path}#{line}",
    sitename="NStrings.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mkitti.github.io/NStrings.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mkitti/NStrings.jl",
    devbranch="main",
)
