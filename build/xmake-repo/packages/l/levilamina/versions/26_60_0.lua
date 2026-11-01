local deps_common = {
    "ctre 3.8.1",
    "entt v4.0.0",
    "expected-lite v0.8.0",
    "fmt 11.2.0",
    "gsl v4.2.0",
    "glm 1.0.1",
    "leveldb 1.23",
    "magic_enum v0.9.7",
    "nlohmann_json v3.12.0",
    "rapidjson 2025.02.05",
    "type_safe v0.2.4",
    "mimalloc v3.5.3",
    "cpr[ssl=y] 1.11.1",
    "parallel-hashmap v2.0.0",
    "concurrentqueue v1.0.4",
    "stb 2025.03.14",
    "zlib v1.3.2",
    "pcg_cpp v1.0.0",
    "pfr 2.1.1",
    "demangler v17.0.7",
    "levibuildscript 0.6.1",
    "preloader v1.16.2",
    "symbolprovider v1.3.0",
    "trampoline 2024.11.7",
    "libhat 0.4.0",
}

local deps_client = {
    "bedrockdata v26.60.5-client.1"
}

local deps_server = {
    "bedrockdata v26.60.6-server.1"
}

function load(package)
    for _, dep in ipairs(deps_common) do
        package:add("deps", dep)
    end

    local target_type = package:config("target_type")
    local selected = target_type == "client" and deps_client or deps_server
    for _, dep in ipairs(selected) do
        package:add("deps", dep)
    end
end
