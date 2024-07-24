set WORK_DIR        [pwd]
set VIVADO_ARTF_DIR ./../pl/artf/
set XSA_NAME        xsa_24_07_24_18_33_12.xsa
set XSA             ${VIVADO_ARTF_DIR}/${XSA_NAME}

platform create -name {platform} \
                -hw ${XSA} \
                -proc {psu_cortexa53_0} -os {standalone} \
                -arch {64-bit} \
                -fsbl-target {psu_cortexa53_0} \
                -out ${WORK_DIR}

domain active standalone_domain
bsp setlib -name xiltimer -ver 1.1
bsp regenerate

platform generate 
