add_rules("mode.debug", "mode.release")
set_xmakever("3.0.0")

local local_repo = path.join(os.scriptdir(), "build", "xmake-repo")
add_repositories("flypremium-26.60 " .. local_repo)
add_repositories("levimc-repo https://github.com/LiteLDev/xmake-repo.git")

option("target_type")
    set_default("client")
    set_showmenu(true)
    set_values("client")
option_end()

add_requires("levilamina 26.60.0", {configs = {target_type = "client"}})
add_requires("levibuildscript 0.6.1")

if not has_config("vs_runtime") then
    set_runtimes("MD")
end

target("FlyPremium")
    add_rules("@levibuildscript/linkrule")
    add_rules("@levibuildscript/modpacker")

    if is_plat("windows") then
        add_defines("NOMINMAX", "UNICODE", "_HAS_CXX23=1", "WIN32_LEAN_AND_MEAN")
        set_exceptions("none")
        add_cxflags("/EHa", "/utf-8", "/W4", "/w44265", "/w44289", "/w44296", "/w45263", "/w44738", "/w45204")
        add_cxflags(
            "/EHs",
            "-Wno-microsoft-cast",
            "-Wno-invalid-offsetof",
            "-Wno-c++2b-extensions",
            "-Wno-microsoft-include",
            "-Wno-overloaded-virtual",
            "-Wno-ignored-qualifiers",
            "-Wno-missing-field-initializers",
            "-Wno-potentially-evaluated-expression",
            "-Wno-pragma-system-header-outside-header",
            {tools = {"clang_cl"}}
        )
        set_toolchains("clang-cl")
        add_shflags("/IGNORE:4217")
    end

    add_packages("levilamina")
    set_kind("shared")
    set_languages("c++20")
    set_symbols("debug")
    add_headerfiles("src/**.h")
    add_files("src/**.cpp")
