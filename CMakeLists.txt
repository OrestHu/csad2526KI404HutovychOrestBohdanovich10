cmake_minimum_required(VERSION 3.14)

project(csad2526KI404HutovychOrestBohdanovich10 VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

include(FetchContent)
include(CTest)

add_library(math_operations STATIC
	math_operations.cpp
)
target_include_directories(math_operations PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(${PROJECT_NAME}
	main.cpp
)
target_link_libraries(${PROJECT_NAME} PRIVATE math_operations)

if(BUILD_TESTING)
	enable_testing()

	set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
	FetchContent_Declare(
		googletest
		URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
		DOWNLOAD_EXTRACT_TIMESTAMP TRUE
	)
	FetchContent_MakeAvailable(googletest)

	add_executable(unit_tests
		tests/unit_tests.cpp
	)
	target_link_libraries(unit_tests PRIVATE math_operations GTest::gtest_main)

	include(GoogleTest)
	gtest_discover_tests(unit_tests)

	add_custom_target(run_tests
		COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure $<$<BOOL:${CMAKE_CONFIGURATION_TYPES}>:-C $<CONFIG>>
		DEPENDS unit_tests
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
	)
endif()
