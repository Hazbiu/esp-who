# The following lines of boilerplate have to be in your project's
# CMakeLists in this exact order for cmake to work correctly
cmake_minimum_required(VERSION 3.5)

set(EXTRA_COMPONENT_DIRS ../../components/who_task
                         ../../components/who_peripherals/who_usb
                         ../../components/who_peripherals/who_cam
                         ../../components/who_peripherals/who_lcd
                         ../../components/who_peripherals/who_spiflash_fatfs
                         ../../components/who_frame_cap
                         ../../components/who_frame_lcd_disp
                         ../../components/who_detect
                         ../../components/who_recognition
                         ../../components/who_app/who_recognition_app)

add_compile_options(-fdiagnostics-color=always)
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
if (NOT DEFINED BSP)
    message(FATAL_ERROR "BSP is not defined, please make sure that the environment variable IDF_EXTRA_ACTIONS_PATH is properly set.")
endif()
idf_build_set_property(DEPENDENCIES_LOCK dependencies.lock.${BSP})
set(EXTRA_COMPONENT_DIRS
    ${CMAKE_CURRENT_LIST_DIR}/../../components/who_app/who_recognition_app
    ${CMAKE_CURRENT_LIST_DIR}/../../components/who_detect
    ${CMAKE_CURRENT_LIST_DIR}/../../components/who_frame_cap
    ${CMAKE_CURRENT_LIST_DIR}/../../components/who_frame_lcd_disp
    ${CMAKE_CURRENT_LIST_DIR}/../../components/who_peripherals/who_cam
    ${CMAKE_CURRENT_LIST_DIR}/../../components/who_peripherals/who_lcd
    ${CMAKE_CURRENT_LIST_DIR}/../../components/who_peripherals/who_spiflash_fatfs
    ${CMAKE_CURRENT_LIST_DIR}/../../components/who_peripherals/who_usb
    ${CMAKE_CURRENT_LIST_DIR}/../../components/who_recognition
    ${CMAKE_CURRENT_LIST_DIR}/../../components/who_task
    ${CMAKE_CURRENT_LIST_DIR}/local_components/waveshare__esp_lcd_jd9365
    ${CMAKE_CURRENT_LIST_DIR}/local_components/waveshare__esp_lcd_dsi
)
project(human_face_recognition)
