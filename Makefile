FRAMEWORKS = Foundation

CXXFLAGS=-std=c++11 -O3 -Isimbple/src
CFLAGS=-O3 -Isimbple/src
LDFLAGS =-framework ${FRAMEWORKS}

TARGET = matcher

# Parts of simbple needed for the matcher.
# Ideally this should be simplified by extracting the appropriate
# sandbox data from libsandbox.1.dylib at runtime.
C_OBJECTS = \
	simbple/src/platform_data/platforms.o \
	simbple/src/sb/operations/data.o \
	simbple/src/platform_data/sierra/operations.o \
	simbple/src/platform_data/sierra/filters.o \
	simbple/src/platform_data/high_sierra/operations.o \
	simbple/src/platform_data/high_sierra/filters.o \
	simbple/src/platform_data/mojave/operations.o \
	simbple/src/platform_data/mojave/filters.o \
	simbple/src/platform_data/catalina/operations.o \
	simbple/src/platform_data/catalina/filters.o
OBJC_OBJECTS = simbple/src/misc/os_support.o
OBJECTS = $(C_OBJECTS) $(OBJC_OBJECTS)

all: ${TARGET}

$(C_OBJECTS): %.o: %.c
$(OBJC_OBJECTS): %.o: %.m

${TARGET}: match_rules.cpp ${OBJECTS}
	${CXX} -o $@ ${CXXFLAGS} ${LDFLAGS} match_rules.cpp ${OBJECTS}

$(OBJECTS):
	$(CC) $< $(CFLAGS) -c -o $@

clean:
	rm -f ${TARGET} ${OBJECTS}
	@echo "Removed build files."
