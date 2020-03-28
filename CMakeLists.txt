#Minimum allowed version of cmake for this configuration.
cmake_minimum_required(VERSION 3.2)

#Project name is mandatory
project(cilisp)

#Creating an executable
add_executable(cilisp)

#Forcing all compilation to be with C11 Standard
set_property(TARGET cilisp PROPERTY C_STANDARD 11)
set_property(TARGET cilisp PROPERTY C_STANDARD_REQUIRED ON)

#Turning on MANY warnings
target_compile_options(cilisp PRIVATE -Wall)

#Allow folders/files in ./scr to be includable to all .c/.h files
target_include_directories(cilisp PRIVATE src)

#Allow build directory to be #include-able to all .c/.h files
target_include_directories(cilisp PRIVATE src/flex)
target_include_directories(cilisp PRIVATE src/bison)

#include Flex and Bison in this project
find_package(FLEX)
find_package(BISON)

#Create a Flex target and a Bison target that output .c files
#These targets (unlike cilisp) don't create executables nor libraries
FLEX_TARGET(ciLispScanner src/ciLisp.l ${CMAKE_SOURCE_DIR}/src/flex/ciLispScanner.c COMPILE_FLAGS)
BISON_TARGET(ciLispParser src/ciLisp.y ${CMAKE_SOURCE_DIR}/src/bison/ciLispParser.c VERBOSE COMPILE_FLAGS)
#Make the bison target also generate a .h file
ADD_FLEX_BISON_DEPENDENCY(ciLispScanner ciLispParser)

#Add all the source files to cilisp target
target_sources(cilisp PRIVATE src/ciLisp.c src/ciLisp.h)
target_sources(cilisp PRIVATE ${BISON_ciLispParser_OUTPUTS})
target_sources(cilisp PRIVATE ${FLEX_ciLispScanner_OUTPUTS})

#Link the math library to cilisp because math.h needs it :/
target_link_libraries(cilisp m)