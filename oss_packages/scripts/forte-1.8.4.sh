#!/bin/sh

# download link for the sources to be stored in dl directory
PKG_DOWNLOAD="http://git.eclipse.org/c/4diac/org.eclipse.4diac.forte.git/snapshot/org.eclipse.4diac.forte-1.8.4.tar.gz"

# md5 checksum of archive in dl directory
PKG_CHECKSUM="83b106d0b270f958ad58151706dda496"

# name of directory after extracting the archive in working directory
PKG_DIR="org.eclipse.4diac.forte-1.8.4"

# name of the archive in dl directory
PKG_ARCHIVE_FILE="${PKG_DIR}.tar.gz"


SCRIPTSDIR="$(dirname $0)"
HELPERSDIR="${SCRIPTSDIR}/helpers"
TOPDIR="$(realpath ${SCRIPTSDIR}/../..)"

. ${TOPDIR}/scripts/common_settings.sh
. ${HELPERSDIR}/functions.sh

PKG_ARCHIVE="${DOWNLOADS_DIR}/${PKG_ARCHIVE_FILE}"
PKG_SRC_DIR="${SOURCES_DIR}/${PKG_DIR}"
PKG_BUILD_DIR="${BUILD_DIR}/${PKG_DIR}"
PKG_INSTALL_DIR="${PKG_BUILD_DIR}/install"

configure()
{
    cd "${PKG_BUILD_DIR}"
    export CFLAGS="${M3_CFLAGS}"
    export LDFLAGS="${M3_LDFLAGS}" 
	export M3_MAKEFLAGS="-j1"
    export M3_CROSS_COMPILE="/usr/bin/armv7a-hardfloat-linux-gnueabi-"
    
	echo "----------------------------------------------------------------------------"
	echo " Automatically set up development environment for POSIX-platform"
	echo "----------------------------------------------------------------------------"
	echo ""
	echo " Includes 64bit-datatypes, float-datatypes, Ethernet-Interface,"
	echo " ASN1-encoding, ..."
	echo ""
	echo "----------------------------------------------------------------------------"

	export forte_bin_dir="bin/posix"

	if [ ! -d "$forte_bin_dir" ]; then
	  mkdir -p "$forte_bin_dir"
	fi

	if [ -d "$forte_bin_dir" ]; then
	  
	  cd "${PKG_BUILD_DIR}/bin/posix"
	  
	  cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=DEBUG -DFORTE_ARCHITECTURE=Posix -DFORTE_LOGLEVEL=LOGDEBUG -DFORTE_TESTS=OFF \
			-DCMAKE_AR=${AR} -DCMAKE_CXX_COMPILER=${M3_CROSS_COMPILE}g++ \
			-DCMAKE_CXX_FLAGS="${CFLAGS} -std=gnu++14 -w -s -I${STAGING_INCLUDE} -L${STAGING_LIB}" \
			-DCMAKE_C_COMPILER=${M3_CROSS_COMPILE}gcc -DCMAKE_C_FLAGS="${CFLAGS}" \
			-DCMAKE_LINKER=${M3_CROSS_COMPILE}ld -DCMAKE_NM=${NM} -DCMAKE_OBJCOPY=${M3_CROSS_COMPILE}objcopy \
			-DCMAKE_OBJDUMP=${M3_CROSS_COMPILE}objdump -DCMAKE_RANLIB=${RANLIB} -DCMAKE_STRIP=${M3_CROSS_COMPILE}strip \
			-DFORTE_COM_ETH=ON -DFORTE_COM_FBDK=ON -DFORTE_COM_LOCAL=ON -DFORTE_COM_MODBUS=OFF \
			-DFORTE_COM_PAHOMQTT=ON -DFORTE_COM_RAW=ON -DFORTE_COM_SER=ON -DFORTE_COM_PAHOMQTT_DIR=${STAGING_LIB} \
			-DFORTE_MODULE_CONVERT=ON -DFORTE_MODULE_I2C-Dev=ON -DFORTE_MODULE_IEC61131=ON -DFORTE_MODULE_INSYS_Functionblocks=ON -DFORTE_MODULE_RECONFIGURATION=ON -DFORTE_MODULE_UTILS=ON \
			-DCMAKE_INSTALL_PREFIX=${STAGING_DIR} ../../
			#OPC UA is available at version 1.9
			#-DFORTE_COM_OPC_UA=ON -DFORTE_COM_OPC_UCA_LIB=libopen62541.so -DFORTE_COM_OPC_UCA_DIR=${OPC_UA_DIR}
			
	else
	  echo "unable to create ${forte_bin_dir}"
	  exit 1
	fi
    
    copy_overlay
}

compile()
{  	
	cd "${PKG_BUILD_DIR}/bin/posix/src"
	export M3_MAKEFLAGS="-j1"
	
    make ${M3_MAKEFLAGS} || exit_failure "failed to build ${PKG_DIR}"
}

install_staging()
{
    cd "${PKG_BUILD_DIR}/bin/posix"
    make install || exit_failure "failed to install ${PKG_DIR}"
}

. ${HELPERSDIR}/call_functions.sh
