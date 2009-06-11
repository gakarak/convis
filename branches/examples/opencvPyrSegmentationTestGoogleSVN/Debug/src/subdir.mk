################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/main0.cpp \
../src/simplemath.cpp \
../src/smalllib.cpp 

OBJS += \
./src/main0.o \
./src/simplemath.o \
./src/smalllib.o 

CPP_DEPS += \
./src/main0.d \
./src/simplemath.d \
./src/smalllib.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/opt/dev/opencv-1.1.0-octave/include/opencv -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


