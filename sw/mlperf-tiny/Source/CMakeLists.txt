
if (USE_VEXT)
    add_subdirectory(NMSIS-NN)
    #add_subdirectory(muRISCV-NN)
else()
    add_subdirectory(muRISCV-NN)
endif()