using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libantic"], :libantic),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaBinaryWrappers/Antic_jll.jl/releases/download/Antic-v0.200.300+0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/Antic.v0.200.300.aarch64-linux-gnu.tar.gz", "9a908953acb29679026935dcce4feb4ea217120bfd5ed645deb9d70778098bb8"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/Antic.v0.200.300.aarch64-linux-musl.tar.gz", "59573a7e486298beddc6b2ecd245095b0531c0008d68e1b0bdc02b75c0d814fa"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/Antic.v0.200.300.armv7l-linux-gnueabihf.tar.gz", "5c354246049277bf06c05733394b593ae6389a9fa7a056f5e7cc95fabdf3d0f4"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/Antic.v0.200.300.armv7l-linux-musleabihf.tar.gz", "8192c95ad57568dd5e491e141e7da9e5b1d6192e2d0ac01a2f70ba4ab4114177"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/Antic.v0.200.300.i686-linux-gnu.tar.gz", "de42f196564a39fc3e07465f74dbc8f2120915db6fc481d550aca22149cae76d"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/Antic.v0.200.300.i686-linux-musl.tar.gz", "93500d9eb34b567864c2b1a5d0bd40864f85f9cd0a7e91a990861068c316cb11"),
    Windows(:i686) => ("$bin_prefix/Antic.v0.200.300.i686-w64-mingw32.tar.gz", "e1e75078e15b2021e74aaba136c755e9e5e9e0c819c65c23f84c3229fe307a6f"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/Antic.v0.200.300.powerpc64le-linux-gnu.tar.gz", "2774b2eb3740b15db19304bea750a4b53cb9eb5eef8aaf6ece3cf2d4e1c62305"),
    MacOS(:x86_64) => ("$bin_prefix/Antic.v0.200.300.x86_64-apple-darwin.tar.gz", "0208ffba20c369b07a948a70c204c205903ada8bbddc8ccdeaea0bff6253a29f"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/Antic.v0.200.300.x86_64-linux-gnu.tar.gz", "f7072a274d564c03e9ef749d46ad5f341430817429a666f5e54b736ca2c0f883"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/Antic.v0.200.300.x86_64-linux-musl.tar.gz", "87133a0223ccef178c70c10158661b7c552887ac53469e34aecaa7b1febd113f"),
    FreeBSD(:x86_64) => ("$bin_prefix/Antic.v0.200.300.x86_64-unknown-freebsd.tar.gz", "f0d97deade30141bc0cd37f3dc1a57a724d74f4df39d22191330f5550e255a28"),
    Windows(:x86_64) => ("$bin_prefix/Antic.v0.200.300.x86_64-w64-mingw32.tar.gz", "ded490bcda4b39567045fdbe500747492ca1339e4a29bb09cb63616e41631cb7"),
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
