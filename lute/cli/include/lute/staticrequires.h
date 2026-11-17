#pragma once

#include "lute/reporter.h"

#include "Luau/DenseHash.h"

#include <optional>
#include <string>
#include <vector>

class StaticRequireTracer
{
public:
    StaticRequireTracer(LuteReporter& reporter);

    // Trace dependencies starting from an entry point file
    // entryPoint: absolute path to entry point file
    void trace(const std::string& entryPoint);

    // Get discovered files as pairs of (bundlePath, absolutePath)
    // bundlePath is the absolute path with the lowest common prefix stripped,
    // or "~/" plus the path inside the home folder (see bundledHomeDirectory)
    std::vector<std::pair<std::string, std::string>> getStaticRequirePairs() const;

    // Check if an absolute path exists in the discovered files
    bool containsAbsolute(const std::string& absolutePath) const;

    const std::string& getLowestCommonRoot() const
    {
        return lowestCommonRoot;
    }

    // Get discovered .luaurc and .config.luau files as a map of (bundlePath -> content)
    // bundlePath follows the same rules as getStaticRequirePairs
    const Luau::DenseHashMap<std::string, std::string>& getLuauConfigFiles() const
    {
        return luauConfigFiles;
    }

    void printRequireGraph() const;
    // Find the lowest common root directory from a collection of absolute paths
    static std::string findLowestCommonRoot(const std::vector<std::string>& paths);

private:
    Luau::DenseHashSet<std::string> visited;
    std::vector<std::string> discovered;                                    // Absolute paths
    Luau::DenseHashMap<std::string, std::vector<std::string>> requireGraph; // Absolute paths
    Luau::DenseHashMap<std::string, std::string> luauConfigFiles;           // Bundle path -> content
    std::string lowestCommonRoot;

    std::optional<std::string> homeDirectory;

    // A compiled program resolves a "~/" alias, such as a dependency in the
    // Loom store at "~/.loom/store", against a "~" folder at the top of its
    // bundle, or against the bundle's root when there is no such folder.
    // When the bundle holds files from inside and outside the home folder,
    // files from inside it are stored under that "~" folder, and this is the
    // home folder they came from. Otherwise it's empty and every path is
    // relative to lowestCommonRoot.
    std::string bundledHomeDirectory;

    std::string toBundlePath(const std::string& absolutePath) const;

    // Extract all require() paths from source code
    std::vector<std::string> extractRequires(const std::string& source);

    // Resolve a require path relative to the requiring file
    std::optional<std::string> resolveModule(const std::string& requirer, const std::string& required);
    LuteReporter& reporter;
};
