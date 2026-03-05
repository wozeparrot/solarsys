PLUGIN_NAME = edge-glow.so

SOURCE_FILES = $(wildcard *.cpp)
HEADER_FILES = $(wildcard *.hpp)

CXXFLAGS = -shared -fPIC --no-gnu-unique -g -O2 -std=c++2b \
	$(shell pkg-config --cflags hyprland pixman-1 libdrm) \
	-DGIT_COMMIT_HASH='"$(HYPRLAND_COMMIT)"'

all: $(PLUGIN_NAME)

$(PLUGIN_NAME): $(SOURCE_FILES) $(HEADER_FILES)
	g++ $(CXXFLAGS) -o $@ $(SOURCE_FILES)

clean:
	rm -f $(PLUGIN_NAME)

.PHONY: all clean
