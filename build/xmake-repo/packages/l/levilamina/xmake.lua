package("levilamina")

add_urls("https://github.com/LiteLDev/LeviLamina.git")
add_versionfiles("versions/versions.txt")
add_defines("ENTT_PACKED_PAGE=128", "ENTT_SPARSE_PAGE=4096", "ENTT_NO_MIXIN")
add_configs("target_type", {default = "server", values = {"server", "client"}})

on_load(function(package)
    local version = package:version_str():gsub("%.", "_")
    import("versions." .. version).load(package)
    if package:config("target_type") == "server" then
        package:add("defines", "LL_PLAT_S")
    else
        package:add("defines", "LL_PLAT_C")
    end
end)

on_install(function(package)
    if package:config("target_type") == "client" then
        import("package.tools.xmake").install(package, {"--target_type=client"})
    else
        import("package.tools.xmake").install(package)
    end
end)
