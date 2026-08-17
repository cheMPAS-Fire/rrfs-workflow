#!/usr/bin/env bash
# shellcheck disable=SC2154,SC2153,SC2012
# Remove any old files
rm -f "${UMBRELLA_PREP_CHEM_DATA}"/goes.aod.init*nc # why we need this?
# 
ln -sf ${FIXrrfs}/goes19_abi_conus_interpolated_lat_lon.nc ${GOES_OUTPUTDIR}
ln -sf ${FIXrrfs}/goes18_abi_conus_lat_lon.nc ${GOES_OUTPUTDIR}
# output directories
GOES_OUTPUTDIR=${DATA}
OUTPUTFILE=${UMBRELLA_PREP_CHEM_DATA}/goes.aod.init.nc

#
srun python -u "${SCRIPT}" \
               "${GOES_DATASET_NAME}" \
               "${DATA}" \
               "${GOES_INPUT}" \
               "${GOES_OUTPUTDIR}" \
               "${INTERP_WEIGHTS_DIR}" \
               "${YYYY}${MM}${DD}${HH}"
mkdir -p logs
mv ./*.log ./*.ESMF_LogFile logs || echo "could not move logs"

