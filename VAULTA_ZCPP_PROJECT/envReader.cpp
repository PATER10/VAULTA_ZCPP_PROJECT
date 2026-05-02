#include <fstream>
#include <sstream>
#include <string>
#include <map>

class Env {
public:
    static void load(const std::string& path = ".env") {
        std::ifstream file(path);
        std::string line;
        while (std::getline(file, line)) {
            // Pomiń puste linie i komentarze
            if (line.empty() || line[0] == '#') continue;

            size_t sep = line.find('=');
            if (sep != std::string::npos) {
                std::string key = line.substr(0, sep);
                std::string value = line.substr(sep + 1);
                // Ustawiamy w środowisku systemowym, żeby std::getenv działało
#ifdef _WIN32
                _putenv_s(key.c_str(), value.c_str());
#else
                setenv(key.c_str(), value.c_str(), 1);
#endif
            }
        }
    }
};