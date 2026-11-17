#pragma once

#include <cstdlib>
#include <optional>
#include <string>

// Points the current user's home folder at another folder until it goes out of
// scope. Lute finds the home folder through libuv, which reads USERPROFILE on
// Windows and HOME everywhere else.
class HomeDirectoryOverride
{
public:
    explicit HomeDirectoryOverride(const std::string& directory)
    {
        if (const char* previous = std::getenv(kVariable))
            previousValue = previous;

        set(directory.c_str());
    }

    ~HomeDirectoryOverride()
    {
        if (previousValue)
            set(previousValue->c_str());
        else
            unset();
    }

    HomeDirectoryOverride(const HomeDirectoryOverride&) = delete;
    HomeDirectoryOverride& operator=(const HomeDirectoryOverride&) = delete;

private:
#ifdef _WIN32
    static constexpr const char* kVariable = "USERPROFILE";

    static void set(const char* value)
    {
        _putenv_s(kVariable, value);
    }

    static void unset()
    {
        _putenv_s(kVariable, "");
    }
#else
    static constexpr const char* kVariable = "HOME";

    static void set(const char* value)
    {
        setenv(kVariable, value, 1);
    }

    static void unset()
    {
        unsetenv(kVariable);
    }
#endif

    std::optional<std::string> previousValue;
};
