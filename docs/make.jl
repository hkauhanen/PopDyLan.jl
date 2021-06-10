using Documenter
using PopDyLan

makedocs(
    sitename = "PopDyLan.jl",
    format = Documenter.HTML(prettyurls=false),
    modules = [PopDyLan],
    pages = [
             "Home" => "index.md",
             "Getting started" => "quickguide.md",
             "Philosophy" => "philosophy.md",
             "Examples" => "underconstruction.md",
             #"Reference" => "reference.md"
             "Reference" => ["Community reference" => "communities.md",
                             "Speaker reference" => "speakers.md",
                             "Grammar reference" => "grammars.md",
                             "Auxiliary reference" => "auxiliaries.md"]
            ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
