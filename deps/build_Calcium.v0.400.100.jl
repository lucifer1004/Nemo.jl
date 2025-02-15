using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libcalcium"], :libcalcium),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaBinaryWrappers/Calcium_jll.jl/releases/download/Calcium-v0.400.100+0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/Calcium.v0.400.100.aarch64-linux-gnu.tar.gz", "f8ae7ba98a13d4305634ca96adc98523505efe525706f44255345f3e17f8fee3"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/Calcium.v0.400.100.aarch64-linux-musl.tar.gz", "33e5fe8d6bd78abca275b7b2c2c89000c00e1aade8ea872f9a670fdab0727e2d"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/Calcium.v0.400.100.armv7l-linux-gnueabihf.tar.gz", "d618a6110c28e04143afb56640c132cf4e1b40a7f7b245e00b4f37b1a12e6f44"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/Calcium.v0.400.100.armv7l-linux-musleabihf.tar.gz", "ca9f70d649f04c4be6466e9b934e41ed0a154de31f2b961a807b4485c9372a56"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/Calcium.v0.400.100.i686-linux-gnu.tar.gz", "298dd9e8d6c214f10d4991971161ff2deb8cc0e9419102b2ea08e407a9bebac7"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/Calcium.v0.400.100.i686-linux-musl.tar.gz", "b673869a807e84487164e8f7d7bae700611a915d34c25ec1eae875d96910b180"),
    Windows(:i686) => ("$bin_prefix/Calcium.v0.400.100.i686-w64-mingw32.tar.gz", "97f0b57a22c5070ebbe75faec7bf05a24dee0fb007123b53aaf6b977a67de5d8"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/Calcium.v0.400.100.powerpc64le-linux-gnu.tar.gz", "c3d1e07c76f9edabcc0763963ccc152128f19ff8b8d61de4b20da07d6c9b76ac"),
    MacOS(:x86_64) => ("$bin_prefix/Calcium.v0.400.100.x86_64-apple-darwin.tar.gz", "4520c75c0c784916f24d6fe02f529f3eb9f17ee2d85934ca1a9aa0212819ed89"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/Calcium.v0.400.100.x86_64-linux-gnu.tar.gz", "fa7f674fdf11581d635650f6d01a847cdaf518f8807c97810538432493e4bcd3"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/Calcium.v0.400.100.x86_64-linux-musl.tar.gz", "b7edb7b9c7e321907ee485e849d92b2765701eb61a301cff85400fca5550798c"),
    FreeBSD(:x86_64) => ("$bin_prefix/Calcium.v0.400.100.x86_64-unknown-freebsd.tar.gz", "5b24d00a64af0713687d1ea5d9dc951386c0e78f48811cd58d9f51802feefbf5"),
    Windows(:x86_64) => ("$bin_prefix/Calcium.v0.400.100.x86_64-w64-mingw32.tar.gz", "6f39cc7348cd9f845e6b4b865fa338570fcc9cb55e263166581fed209c3bfeb6"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
