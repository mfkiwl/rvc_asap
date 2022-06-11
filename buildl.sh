#!/bin/bash -li
#========== Project   : rvc_asap ===========================================#
#========== File      : buildl.sh ==========================================#
#========== Descrition: This Script - ======================================#
#==========             (1) Compile the C programs to assembly =============#
#==========             (2) Compile the assembly programs to elf ===========#
#==========             (3) Compile the elf files to sv ====================#
#==========             (4) Build the test with vlog.exe ===================#
#==========             (5) Simulte the tests with vsim.exe ================#
#==========             (6) Check the results ==============================#
#===========================================================================#
#========== Author    : Gil Ya'akov & Matan Eshel ==========================#
#===========================================================================#
#========== Date      : 04DEC21 ============================================#

main(){
	export APPS="./apps"
	export APPS_C="./apps/C"
	export APPS_ASM="./apps/asm"
    export APPS_ASM_VERIF="./apps/asm_verif"
	export APPS_ELF="./apps/elf"
	export APPS_ELF_TXT="./apps/elf_txt"
	export APPS_SV="./apps/sv"
	export MODELSIM_RUN="./modelsim_run"
	export VERIF="./verif"
	export TARGET="./target"
	export GOLDEN_IMAGE="./verif/golden_image"
    export APPS_LIB_ELF="./apps/library/out/bin"

	#==== Check build flags ====#
    sc=0
	pl=0
	gui=0
    compile=0
    asmverif=0
    lib=0
    debug=0

    for flag in "$@"
    do	
    if [ "$flag" == "-sc" ]; then
        sc=1
    fi
    if [ "$flag" == "-5pl" ]; then
        pl=1
    fi
    if [ "$flag" == "-gui" ]; then
        gui=1
    fi
    if [ "$flag" == "-compile" ]; then
        compile=1
    fi
    if [ "$flag" == "-asm_verif" ]; then
        asmverif=1
    fi
    if [ "$flag" == "-lib" ]; then
        lib=1
    fi
    if [ "$flag" == "-debug" ]; then
        debug=1
    fi
    if [ "$flag" == "--help" ]; then
		echo "usage: $0 [arch] [gui] [test_0] [test_1] ... [test_n]"
    	echo "  all                             Build all tests    "
    	echo "  All                             Build all tests    "
		echo "  arch                            [-sc] [-5pl]       "
		echo "                                  Basic arch is 5pl  "
		echo "  gui                             [-gui]             "
        echo "  compile                         [-compile]         "
        echo "  just asm                        [-asm_verif]       "
        echo "  library examples                [-lib]             "
        echo "  don't clean compilation files   [-debug]           "
    	echo "  example_1 : ./build.sh all                         "
        echo "  example_2 : ./build.sh ALL                         "
        echo "  example_3 : ./build.sh basic_commands1 basic_commands2 ... basic_commandsn"
		echo "  example_4 : ./build.sh -sc -gui basic_commands1 basic_commands2 ... basic_commandsn"
		echo "  example_5 : ./build.sh -5pl -gui basic_commands1 basic_commands2 ... basic_commandsn"
		echo "  example_5 : ./build.sh -5pl basic_commands1 basic_commands2 ... basic_commandsn"
    	exit 1
    fi
    done

	#==== Print usage in case there are no argumnets provided by the user ====# 
	if [ $# -eq 1 ]; then
		echo "usage: $0 [arch] [gui] [test_0] [test_1] ... [test_n]"
    	echo "  all                             Build all tests    "
    	echo "  All                             Build all tests    "
		echo "  arch                            [-sc] [-5pl]       "
		echo "                                  Basic arch is 5pl  "
		echo "  gui                             [-gui]             "
        echo "  compile                         [-compile]         "
        echo "  just asm                        [-asm_verif]       "
        echo "  library examples                [-lib]             "
        echo "  don't clean compilation files   [-debug]           "
    	echo "  example_1 : ./build.sh all                         "
        echo "  example_2 : ./build.sh ALL                         "
        echo "  example_3 : ./build.sh basic_commands1 basic_commands2 ... basic_commandsn"
		echo "  example_4 : ./build.sh -sc -gui basic_commands1 basic_commands2 ... basic_commandsn"
		echo "  example_5 : ./build.sh -5pl -gui basic_commands1 basic_commands2 ... basic_commandsn"
		echo "  example_5 : ./build.sh -5pl basic_commands1 basic_commands2 ... basic_commandsn"
    	exit 1
	fi

    #==== Check if the directories apps/elf apps/elf_txt apps/sv exist - if not create them ====#
    if [ -d $APPS_ELF ] 
    then
        echo "Directory $APPS_ELF exists." 
    else
        mkdir $APPS_ELF
    fi

    if [ -d $APPS_ELF_TXT ] 
    then
        echo "Directory $APPS_ELF_TXT exists." 
    else
        mkdir $APPS_ELF_TXT
    fi

    if [ -d $APPS_SV ] 
    then
        echo "Directory $APPS_SV exists." 
    else
        mkdir $APPS_SV
    fi

    if [ -d $APPS_ASM ] 
    then
        echo "Directory $APPS_ASM exists." 
    else
        mkdir $APPS_ASM
    fi

    #==== Clean target directory and compilation directories ====#
    rm -r $TARGET/*
    rm -r $APPS_ELF/* $APPS_ELF_TXT/* $APPS_SV/*

    if [ $lib == 0 ]; then # Because if lib == 1 we will make all this steps from the make file of apps/library
        if [ $asmverif == 0 ]; then
            #===== 1. Compile the C files in apps/C to apps/asm =====#
            for f in "$APPS_C"/*; do
                file_name="$(basename -- $f)"
                clean_file_name="${file_name%.*}"
                #==== 1.1 Compile Only the tests that were specified by the user ====#
                for test in "$@"; do	
                    if [ "$test" = "$clean_file_name" ] || [ "$test" = "all" ] || [ "$test" = "ALL" ] || [ $# -eq 1 ]; then
                        rv_gcc -S -ffreestanding -march=rv32i $APPS_C/$file_name  -o $APPS_ASM/$clean_file_name.s
                    fi
                done
            done
        fi

            #===== 2. Compile the Assembly files in apps/asm to apps/elf =====#
            if [ $asmverif == 1 ]; then
                APPS_ASM=$APPS_ASM_VERIF
            fi

            for f in "$APPS_ASM"/*; do
                file_name="$(basename -- $f)"
                clean_file_name="${file_name%.*}"
                #==== 2.1 Compile Only the tests that were specified by the user ====#
                for test in "$@"; do	
                    if [ "$test" == "$clean_file_name" ] || [ "$test" == "all" ] || [ "$test" == "ALL" ] || [ $# -eq 1 ]; then
                        if [ $asmverif == 0 ]; then
                            rv_gcc -O3 -march=rv32i -T$APPS/link.common.ld -nostartfiles -D__riscv__ $APPS/crt0.s $APPS_ASM/$file_name -o $APPS_ELF/$clean_file_name.elf # for C files
                        else
                            rv_gcc -O3 -march=rv32i -T$APPS/link.common.ld -nostartfiles -D__riscv__ $APPS_ASM/$file_name -o $APPS_ELF/$clean_file_name.elf # for just asm files
                        fi
                        if [[ ! -d "./target/$clean_file_name" ]]; then
                            mkdir ./target/$clean_file_name
                        fi
                    fi
                done
            done
    fi

    if [ $lib == 1 ]; then
        cd ./apps/library
        make all
        cp ./out/bin/* ../elf/
        cd ../..
    fi
	#===== 3. Compile all the elf files in apps/elf to apps/sv =====#
	for f in "$APPS_ELF"/*; do
	file_name="$(basename -- $f)"
	clean_file_name="${file_name%.*}"
		#==== 3.1 Compile Only the tests that were specified by the user ====#
		for test in "$@"
		do	
			if [ "$test" == "$clean_file_name" ] || [ "$test" == "all" ] || [ "$test" == "ALL" ] || [ $# -eq 1 ]; then	
    			rv_objcopy --srec-len 1 --output-target=verilog $APPS_ELF/$file_name $APPS_SV/$clean_file_name-inst_mem_rv32i.sv
    			rv_objdump -gd -M numeric $APPS_ELF/$file_name > $APPS_ELF_TXT/$file_name.txt  
				#==== 3.2 Split the .sv file to instruction memory and data memory ====# 
                if grep -q @00001000 "$APPS_SV/$clean_file_name-inst_mem_rv32i.sv"; then
                   c=`cat $APPS_SV/$clean_file_name-inst_mem_rv32i.sv | wc -l`
                   y=`cat $APPS_SV/$clean_file_name-inst_mem_rv32i.sv | grep -n @00001000 | cut -d ':' -f 1 |tail -n 1`
                   (( y-- ))
                   cat $APPS_SV/$clean_file_name-inst_mem_rv32i.sv | tail -n $(( c-y )) > $APPS_SV/$clean_file_name-data_mem_rv32i.sv
                   cat $APPS_SV/$clean_file_name-inst_mem_rv32i.sv | head -n $(( y )) > $APPS_SV/$clean_file_name-inst_mem_rv32i.sv
                else
                   echo "@00001000" > $APPS_SV/$clean_file_name-data_mem_rv32i.sv
                fi
                if [[ ! -d "./target/$clean_file_name" ]]; then
                    mkdir ./target/$clean_file_name
                fi  
			fi
		done
	done

    if [ $lib == 1 ]; then
        APPS_ASM=$APPS_LIB_ELF
    fi

	#===== 4 & 5. Build the tests with vlog.exe & vsim.exe =====#
	for f in "$APPS_ASM"/*; do
	file_name="$(basename -- $f)"
	clean_file_name="${file_name%.*}"
		#==== 4.1 Compile Only the tests that were specified by the user ====#
		for test in "$@"
		do	
			if [ "$test" == "$clean_file_name" ] || [ "$test" == "all" ] || [ "$test" == "ALL" ] || [ $# -eq 1 ]; then	
				MSG="Test: $clean_file_name" BG="46m" FG="30m"
				echo "========================================================="
				echo "========================================================="
				echo -en "              \033[$FG\033[$BG$MSG\033[0m\n"
				echo "========================================================="
				echo "========================================================="
				cd modelsim_run
                if [ $pl == 1 ]; then
                    vlog.exe +define+HPATH=$clean_file_name -f rvc_asap_5pl_list.f
                elif [ $sc == 1 ]; then
                    vlog.exe +define+HPATH=$clean_file_name -f rvc_asap_sc_list.f
                else
                    vlog.exe +define+HPATH=$clean_file_name -f rvc_asap_5pl_list.f # Default is 5pl
				fi

                if [ $pl == 1 ]; then
                    if [ $gui == 1 ]; then
                        vsim.exe -gui work.rvc_asap_5pl_tb 
                    else
                        vsim.exe work.rvc_asap_5pl_tb -c -do 'run -all' # Default is not gui
                    fi
                elif [ $sc == 1 ]; then
                      if [ $gui == 1 ]; then
                          vsim.exe -gui work.rvc_asap_sc_tb 
                      else
                          vsim.exe work.rvc_asap_sc_tb -c -do 'run -all' # Default is not gui
                      fi
                else
                      if [ $gui == 1 ]; then
                          vsim.exe -gui work.rvc_asap_5pl_tb 
                      else
                          vsim.exe work.rvc_asap_5pl_tb -c -do 'run -all' # Default is not gui
                      fi # Default is 5pl
                fi
				cd ..
				echo "========================================================="
				echo "========================================================="
				MSG="End Test: $clean_file_name" BG="46m" FG="30m"
				echo -en "              \033[$FG\033[$BG$MSG\033[0m\n"
				echo "========================================================="
				echo "========================================================="
			fi
		done
    done

    #===== Clean compilation files =====#
    if [ $lib == 1 ]; then
        cd ./apps/library
        make clean
        cd ../..
    fi

    if [ $debug == 0 ]; then
        rm -r $APPS_ELF/* $APPS_ELF_TXT/* $APPS_SV/*
    fi

    #===== If compile flag is set in this stage we exit - no check tests results =====#
    if [ $compile == 1 ]; then
        exit        
    fi

	#===== 6. Check the results  =====#
	for f in "$TARGET"/*; do
	file_name="$(basename -- $f)"
	clean_file_name="${file_name%.*}"
		#==== 6.1 Check Only the tests that were specified by the user ====#
		for test in "$@"
		do	
			if [ "$test" == "$clean_file_name" ] || [ "$test" == "all" ] || [ "$test" == "ALL" ] || [ $# -eq 1 ]; then	
				MSG="Check: $clean_file_name" BG="103m" FG="30m"
				echo "========================================================="
				echo -en "              \033[$FG\033[$BG$MSG\033[0m\n"
				echo "========================================================="
                input1="$TARGET/$clean_file_name/mem_snapshot.log"
                input2="$GOLDEN_IMAGE/$clean_file_name/mem_snapshot.log"
                if [ -f "$input1" ] && [ -f "$input2" ]; then
                   error=0
                   while read compareFile1 <&3 && read compareFile2 <&4; do     
                   if [ "$compareFile1" != "$compareFile2" ]; then
                      MSG1="Error: Inequality" BG="101m" FG="30m"
                      echo -en "              \033[$FG\033[$BG$MSG1\033[0m\n"
                      echo "Real line: $compareFile1"
                      echo "Gold line: $compareFile2"
                      error=1
                   fi 
                   done 3<$input1 4<$input2
                   if [ $error == 0 ]; then
                       MSG2="The test ended successfully!" BG="42m" FG="30m"
                       echo -en "              \033[$FG\033[$BG$MSG2\033[0m\n"
                       echo -n $'                        \U1F600\n'
                   fi
                else
                   echo "           This test have no memory snapshot             "
                fi
                echo "========================================================="
                MSG="End Check: $clean_file_name" BG="103m" FG="30m"
                echo -en "              \033[$FG\033[$BG$MSG\033[0m\n"
                echo "========================================================="
            fi
        done
    done
}

main "$@" "$#" # End main
